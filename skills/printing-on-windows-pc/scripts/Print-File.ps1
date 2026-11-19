<#
.SYNOPSIS
  Print a file (PDF, image, Office doc, text, or HTML/URL) to a named printer on this PC,
  bypassing the need for a registered file-type print handler.

.PARAMETER Path
  File to print, or an http(s) URL (rendered via headless Edge first).

.PARAMETER PrinterName
  Exact printer name from `Get-Printer`. If omitted, the Windows default printer is
  used, unless it is a virtual printer (Print to PDF, OneNote, XPS, Fax), in which
  case the script stops and lists the real printers. Pass it explicitly when you can.

.PARAMETER Copies
  Number of copies (default 1).

.PARAMETER Duplex
  One of: Default, Simplex, Horizontal, Vertical. Vertical = long-edge duplex
  (standard "double-sided"). Only takes effect if the printer's CanDuplex is
  true for the given paper/tray combo.

.PARAMETER Dpi
  Render DPI for PDF pages (default 300). Higher = sharper QR/text but slower.

.EXAMPLE
  .\Print-File.ps1 -Path "$HOME\Documents\sign.pdf" -PrinterName "Epson ET-2800 Series"
.EXAMPLE
  .\Print-File.ps1 -Path "$HOME\Pictures\photo.jpg" -Copies 2
.EXAMPLE
  .\Print-File.ps1 -Path "$HOME\Documents\report.docx" -Duplex Vertical
.EXAMPLE
  .\Print-File.ps1 -Path https://example.com/page
#>
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string]$PrinterName = "",
    [int]$Copies = 1,
    [ValidateSet("Default", "Simplex", "Horizontal", "Vertical")][string]$Duplex = "Default",
    [int]$Dpi = 300
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

if (-not $PrinterName) {
    $PrinterName = (Get-CimInstance -ClassName Win32_Printer -Filter "Default=True").Name
    if (-not $PrinterName -or $PrinterName -match 'PDF|OneNote|XPS|Fax') {
        $real = (Get-Printer | Where-Object { $_.Name -notmatch 'PDF|OneNote|XPS|Fax' } | Select-Object -ExpandProperty Name) -join ", "
        throw "No real default printer (default is '$PrinterName'). Pass -PrinterName. Real printers: $real"
    }
}

function Assert-PrinterValid([string]$name) {
    $ps = New-Object System.Drawing.Printing.PrinterSettings
    $ps.PrinterName = $name
    if (-not $ps.IsValid) {
        $available = (Get-Printer | Select-Object -ExpandProperty Name) -join ", "
        throw "Printer '$name' not found. Available printers: $available"
    }
    return $ps
}

function Print-ImageSequence {
    param(
        [string[]]$ImagePaths,
        [string]$PrinterName,
        [int]$Copies,
        [string]$Duplex
    )
    $printerSettings = Assert-PrinterValid $PrinterName
    $images = @($ImagePaths | ForEach-Object { [System.Drawing.Image]::FromFile($_) })

    # A plain scalar ($index++) does NOT persist across PrintPage event re-entry —
    # PowerShell scriptblocks bound as .NET event handlers write to a fresh local
    # copy each call, so $index reads back as 0 forever and HasMorePages never
    # goes false (seen in practice: 1700+ runaway "pages", all page 1).
    # [ref] sidesteps this: we mutate .Value on the SAME object every call
    # instead of rebinding the variable, so the write is never scope-local.
    $state = [ref]0

    $doc = New-Object System.Drawing.Printing.PrintDocument
    $doc.PrinterSettings.PrinterName = $PrinterName
    $doc.PrinterSettings.Copies = $Copies
    if ($Duplex -ne "Default" -and $doc.PrinterSettings.CanDuplex) {
        $doc.PrinterSettings.Duplex = [System.Drawing.Printing.Duplex]::$Duplex
    }

    $handler = {
        param($sender, $e)
        $i = $state.Value
        if ($i -ge $images.Count) {
            # Safety backstop: never draw past the known page count, no matter
            # what HasMorePages logic above did — this is what caps a runaway
            # loop at N pages instead of thousands.
            $e.HasMorePages = $false
            return
        }
        $img = $images[$i]
        $pageBounds = $e.PageBounds
        $imgRatio = $img.Width / $img.Height
        $pageRatio = $pageBounds.Width / $pageBounds.Height
        if ($imgRatio -gt $pageRatio) {
            $w = $pageBounds.Width
            $h = $w / $imgRatio
        } else {
            $h = $pageBounds.Height
            $w = $h * $imgRatio
        }
        $x = ($pageBounds.Width - $w) / 2
        $y = ($pageBounds.Height - $h) / 2
        $e.Graphics.DrawImage($img, $x, $y, $w, $h)
        $state.Value = $i + 1
        $e.HasMorePages = ($state.Value -lt $images.Count)
    }

    $doc.add_PrintPage($handler)
    $doc.Print()
    $images | ForEach-Object { $_.Dispose() }
    if ($state.Value -ne $images.Count) {
        Write-Warning "Expected $($images.Count) page(s) but PrintPage fired for $($state.Value). Check the print queue."
    }
    Write-Output "Queued $($state.Value) page(s) x$Copies copies to '$PrinterName'."
}

function Print-Pdf {
    param([string]$Path, [string]$PrinterName, [int]$Copies, [string]$Duplex, [int]$Dpi)
    $tmpDir = Join-Path $env:TEMP ("print-pdf-" + [System.Guid]::NewGuid().ToString("N"))
    $helper = Join-Path $PSScriptRoot "pdf_to_pngs.py"
    $pages = uv run --with pymupdf python $helper $Path $tmpDir $Dpi
    if ($LASTEXITCODE -ne 0 -or -not $pages) {
        throw "PDF render failed for '$Path' (uv/pymupdf exit $LASTEXITCODE)."
    }
    try {
        Print-ImageSequence -ImagePaths $pages -PrinterName $PrinterName -Copies $Copies -Duplex $Duplex
    } finally {
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Print-OfficeDoc {
    param([string]$Path, [string]$PrinterName, [int]$Copies, [string]$Ext)
    Assert-PrinterValid $PrinterName | Out-Null
    $resolvedPath = (Resolve-Path $Path).Path
    $tempCopy = $null
    # Excel/Word COM can't open OneDrive symlink files ("cannot access the file")
    # even when they appear local — copy to a real local path first.
    if ((Get-Item $resolvedPath).LinkType -or $resolvedPath -like "*\OneDrive\*") {
        $tempCopy = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString("N") + $Ext)
        Copy-Item $resolvedPath $tempCopy -Force
        $resolvedPath = $tempCopy
    }
    try {
    switch ($Ext) {
        { $_ -in ".doc", ".docx", ".rtf" } {
            # Late-bound COM optional args (Word's PrintOut params are ByRef
            # Variant Optional) don't marshal cleanly through PowerShell with
            # explicit [ref]/Type.Missing — simplest robust path is set
            # ActivePrinter, call the zero-arg overload, loop for copies.
            $app = New-Object -ComObject Word.Application
            $app.Visible = $false
            $app.ActivePrinter = $PrinterName
            try {
                $doc = $app.Documents.Open($resolvedPath, $false, $true)
                for ($c = 0; $c -lt $Copies; $c++) { $doc.PrintOut() }
                Start-Sleep -Seconds 2
                $doc.Close($false)
            } finally { $app.Quit() }
        }
        { $_ -in ".xls", ".xlsx", ".csv" } {
            # Excel's Application.ActivePrinter setter requires the legacy
            # "Name on PortX:" string format and throws HRESULT 0x800A03EC on
            # WSD-class printer ports — so print via the Windows
            # default printer instead, temporarily switched to the target.
            $originalDefault = (Get-CimInstance -ClassName Win32_Printer -Filter "Default=True").Name
            $net = New-Object -ComObject WScript.Network
            $net.SetDefaultPrinter($PrinterName)
            $app = New-Object -ComObject Excel.Application
            $app.Visible = $false
            try {
                $wb = $app.Workbooks.Open($resolvedPath, 0, $true)
                for ($c = 0; $c -lt $Copies; $c++) { $wb.ActiveSheet.PrintOut() }
                Start-Sleep -Seconds 2
                $wb.Close($false)
            } finally {
                $app.Quit()
                if ($originalDefault) { $net.SetDefaultPrinter($originalDefault) }
            }
        }
        { $_ -in ".ppt", ".pptx" } {
            $app = New-Object -ComObject PowerPoint.Application
            try {
                $pres = $app.Presentations.Open($resolvedPath, $true, $false, $false)
                $pres.PrintOptions.ActivePrinter = $PrinterName
                for ($c = 0; $c -lt $Copies; $c++) { $pres.PrintOut() }
                Start-Sleep -Seconds 2
                $pres.Close()
            } finally { $app.Quit() }
        }
        default { throw "Unhandled Office extension '$Ext'." }
    }
    } finally {
        if ($tempCopy) { Remove-Item $tempCopy -Force -ErrorAction SilentlyContinue }
    }
    Write-Output "Sent Office print job ($Ext) to '$PrinterName' via COM automation."
}

function Print-Text {
    param([string]$Path, [string]$PrinterName)
    Assert-PrinterValid $PrinterName | Out-Null
    Get-Content -Path $Path -Raw | Out-Printer -Name $PrinterName
    Write-Output "Sent plain-text job to '$PrinterName' via Out-Printer."
}

function Convert-UrlOrHtmlToPdf {
    param([string]$Source)
    $edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edge)) {
        $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    }
    if (-not (Test-Path $edge)) { throw "msedge.exe not found for HTML/URL rendering." }
    $tmpPdf = Join-Path $env:TEMP ("print-html-" + [System.Guid]::NewGuid().ToString("N") + ".pdf")
    $target = $Source
    if ($Source -notmatch '^https?://') {
        $target = "file:///" + ((Resolve-Path $Source).Path -replace '\\', '/')
    }
    # Edge writes benign Chromium diagnostic noise to stderr even on success;
    # under $ErrorActionPreference=Stop that noise gets promoted to a
    # terminating NativeCommandError if captured, so don't redirect/capture
    # stderr here — just run it and judge success by whether the PDF exists.
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $edge --headless --disable-gpu --no-pdf-header-footer "--print-to-pdf=$tmpPdf" $target | Out-Null
    } finally {
        $ErrorActionPreference = $prevPref
    }
    Start-Sleep -Seconds 1
    if (-not (Test-Path $tmpPdf)) { throw "Edge headless print-to-pdf failed for '$Source'." }
    return $tmpPdf
}

# --- Dispatch ---
$ext = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
$isUrl = $Path -match '^https?://'

if ($isUrl -or $ext -in ".html", ".htm") {
    $pdfPath = Convert-UrlOrHtmlToPdf -Source $Path
    try {
        Print-Pdf -Path $pdfPath -PrinterName $PrinterName -Copies $Copies -Duplex $Duplex -Dpi $Dpi
    } finally {
        Remove-Item $pdfPath -Force -ErrorAction SilentlyContinue
    }
} elseif ($ext -eq ".pdf") {
    Print-Pdf -Path $Path -PrinterName $PrinterName -Copies $Copies -Duplex $Duplex -Dpi $Dpi
} elseif ($ext -in ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tif", ".tiff") {
    Print-ImageSequence -ImagePaths @($Path) -PrinterName $PrinterName -Copies $Copies -Duplex $Duplex
} elseif ($ext -in ".doc", ".docx", ".rtf", ".xls", ".xlsx", ".csv", ".ppt", ".pptx") {
    Print-OfficeDoc -Path $Path -PrinterName $PrinterName -Copies $Copies -Ext $ext
} elseif ($ext -eq ".txt") {
    Print-Text -Path $Path -PrinterName $PrinterName
} else {
    throw "No print handler mapped for extension '$ext'. Known: pdf, jpg/jpeg/png/bmp/gif/tif/tiff, doc/docx/rtf, xls/xlsx/csv, ppt/pptx, txt, html/htm, http(s) URL."
}
