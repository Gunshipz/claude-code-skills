---
name: printing-on-windows-pc
description: Use when asked to print anything on a Windows PC — a PDF, image, Word/Excel/PowerPoint file, text file, web page or URL, labels, worksheets, gift tags, craft templates — or to pick the right printer and confirm the job actually printed.
---

# Printing on a Windows PC

`scripts/Print-File.ps1` prints a file or URL to a named printer without needing a
registered "print" handler for the file type. It picks a method by file extension and
works the same on any Windows 10/11 PC. It needs `uv` (for PDF rendering) and, for
Office files, the matching Office app.

## First time on a new PC: learn the printers

1. List them: `Get-Printer | Select-Object Name, Type, PortName` and the default:
   `(Get-CimInstance Win32_Printer -Filter "Default=True").Name`.
2. Virtual printers (Microsoft Print to PDF, OneNote, XPS, Fax) never put ink on paper.
   If there's exactly one real printer, use it. If there are several, ask the user once
   which is which ("the one by the desk", "the sublimation printer") with a numbered list.
3. Save the answer where you'll find it next time (the user's notes or memory), e.g.
   `Printers: everyday = "EPSON ET-2800 Series"; sublimation = "EPSON ET-15000 (Sub)"`.

## Print

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill dir>\scripts\Print-File.ps1" `
  -Path "C:\path\to\file.pdf" -PrinterName "<exact printer name>" -Copies 1 -Duplex Vertical
```

| Extension | Method |
|---|---|
| `.pdf` | PyMuPDF renders each page to PNG (`scripts/pdf_to_pngs.py`, 300 DPI), then prints them in order |
| `.jpg .jpeg .png .bmp .gif .tif .tiff` | Printed directly, **scaled to fit and centered** on the page |
| `.docx .doc .rtf` | Word, in the background |
| `.xlsx .xls .csv` | Excel, by briefly switching the Windows default printer and switching it back |
| `.pptx .ppt` | PowerPoint, in the background |
| `.txt` | `Out-Printer` |
| `.html .htm` or `http(s)://` URL | Headless Edge saves it as a PDF first, then the PDF path |

`-Duplex`: `Simplex`, `Vertical` (normal double-sided) or `Horizontal`. It's ignored if
the printer can't print double-sided. Leave `-PrinterName` off only if the Windows default
is a real printer; the script refuses a virtual default and lists the real printers.

## Exact size matters (crafts, labels, templates)

- **Images are scaled to fit the page.** For anything that must print at true size
  (sublimation transfers, iron-on templates, stencils, Avery labels), put the image on a
  correctly sized PDF page first (Letter is 8.5 × 11 in) at its real dimensions, then print
  the PDF. A Letter PDF on Letter paper prints 1:1.
- **Mirroring** for sublimation and HTV is done in the design file, before printing.
  Don't rely on a printer-driver "mirror" checkbox the script can't see.
- **Cricut Print Then Cut** prints from Cricut Design Space itself, not from this script.
- Always offer a **plain-paper test print** first for anything on expensive media
  (sublimation paper, label sheets, cardstock), and say how to check it: hold it against
  the sheet or measure one known dimension with a ruler.

## Did it actually print?

A job in the queue is not a printed page. `Get-PrintJob -PrinterName X` only shows what's
still queued; finished jobs vanish within seconds. For a real page count, read the Print
Service log (event 307 says `Pages printed: N`):

```powershell
Get-WinEvent -LogName "Microsoft-Windows-PrintService/Operational" -MaxEvents 5 |
  Where-Object Id -eq 307 | Select-Object -First 1 -ExpandProperty Message
```

That log is off on a fresh Windows install. If `wevtutil gl "Microsoft-Windows-PrintService/Operational"`
shows `enabled: false`, turn it on (needs one Windows pop-up approval):
`wevtutil sl "Microsoft-Windows-PrintService/Operational" /e:true`. Otherwise, ask the user
whether the page came out.

## Gotchas

- **Microsoft Print to PDF** always opens a Save-As dialog, so it can't be used unattended.
  To make a PDF, use Edge `--print-to-pdf` or a library instead.
- **Office files on OneDrive** can fail to open through Office automation ("cannot access
  the file") even when they look local. The script copies them to a temp folder first.
- **Excel's `ActivePrinter`** throws `0x800A03EC` on WSD network printers, which is why
  the script switches the default printer for Excel and restores it afterwards.
- **PowerShell event handlers don't keep a plain counter between calls.** The multi-page
  print handler uses a `[ref]` counter and a hard stop at the page count. Never "simplify"
  that to `$index++`, or one page prints forever.
- **Native-program stderr under `$ErrorActionPreference = "Stop"`** becomes a fatal error in
  Windows PowerShell 5.1 even on success. The Edge call runs with `Continue` and judges
  success by whether the PDF exists.

## Testing print logic without paper

Set `$doc.PrintController = New-Object System.Drawing.Printing.PreviewPrintController`
before `.Print()`. It runs the same page events with no output, so a page-loop bug shows
up as a runaway counter instead of a stack of paper.
