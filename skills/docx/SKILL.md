---
name: docx
description: |
  Create, read, edit, and manipulate Word documents (.docx files). Use when producing
  professional documents with formatting like tables of contents, headings, page numbers,
  or letterheads. Also for extracting or reorganizing content from .docx files, inserting
  or replacing images, performing find-and-replace, working with tracked changes or
  comments, or converting content into a polished Word document.
license: MIT
allowed-tools: Bash, Read, Write, Edit, Glob
---

# Word Document (.docx) Skill

Create, read, edit, and manipulate Word documents programmatically using docx-js (creation) and pandoc (reading/conversion).

## Reading .docx Files

### With pandoc (preferred)
```bash
pandoc "document.docx" -t markdown -o "document.md"
pandoc "document.docx" -t plain -o "document.txt"
```

### With python-docx (when pandoc unavailable)
```bash
pip install python-docx
python -c "
from docx import Document
doc = Document('file.docx')
for para in doc.paragraphs:
    print(f'[{para.style.name}] {para.text}')
"
```

## Creating .docx Files with docx-js

### Setup
```bash
npm init -y
npm install docx
```

### Basic Template

```javascript
const { Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
        Table, TableRow, TableCell, WidthType, BorderStyle,
        ImageRun, PageNumber, Header, Footer, TableOfContents,
        convertInchesToTwip, PageBreak } = require("docx");
const fs = require("fs");

const doc = new Document({
    sections: [{
        properties: {
            page: {
                size: { width: 12240, height: 15840 },  // Letter (8.5x11")
                margin: {
                    top: convertInchesToTwip(1),
                    bottom: convertInchesToTwip(1),
                    left: convertInchesToTwip(1),
                    right: convertInchesToTwip(1),
                },
            },
        },
        children: [
            new Paragraph({
                text: "Document Title",
                heading: HeadingLevel.HEADING_1,
                alignment: AlignmentType.CENTER,
            }),
            new Paragraph({
                children: [
                    new TextRun({ text: "Bold text", bold: true }),
                    new TextRun({ text: " and normal text." }),
                ],
            }),
        ],
    }],
});

Packer.toBuffer(doc).then((buffer) => {
    fs.writeFileSync("output.docx", buffer);
    console.log("Document created: output.docx");
});
```

## Critical docx-js Rules

1. **Always set explicit page size** - Without it, dimensions are undefined and layout breaks
2. **Landscape requires width > height** - Swap dimensions AND set orientation:
   ```javascript
   page: {
       size: { width: 15840, height: 12240, orientation: "landscape" },
   }
   ```
3. **Never use `\n` in TextRun** - Use separate Paragraphs or `break: 1` in TextRun
4. **Table widths use DXA units** - `convertInchesToTwip()` for inches, or calculate: 1 inch = 1440 DXA
5. **Images need explicit dimensions** - Always provide width and height in EMU or use transformation

## Common Components

### Tables

```javascript
new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
        new TableRow({
            children: [
                new TableCell({
                    width: { size: 50, type: WidthType.PERCENTAGE },
                    children: [new Paragraph("Cell 1")],
                }),
                new TableCell({
                    width: { size: 50, type: WidthType.PERCENTAGE },
                    children: [new Paragraph("Cell 2")],
                }),
            ],
        }),
    ],
})
```

### Images

```javascript
new Paragraph({
    children: [
        new ImageRun({
            data: fs.readFileSync("image.png"),
            transformation: { width: 400, height: 300 },
        }),
    ],
})
```

### Headers and Footers

```javascript
sections: [{
    headers: {
        default: new Header({
            children: [new Paragraph({ text: "Header Text", alignment: AlignmentType.RIGHT })],
        }),
    },
    footers: {
        default: new Footer({
            children: [new Paragraph({
                children: [
                    new TextRun("Page "),
                    new TextRun({ children: [PageNumber.CURRENT] }),
                    new TextRun(" of "),
                    new TextRun({ children: [PageNumber.TOTAL_PAGES] }),
                ],
                alignment: AlignmentType.CENTER,
            })],
        }),
    },
    children: [/* ... */],
}]
```

### Table of Contents

```javascript
new TableOfContents("Table of Contents", {
    hyperlink: true,
    headingStyleRange: "1-3",
})
```

Note: TOC requires the document to be opened in Word and "Update Fields" run to populate.

### Lists

```javascript
// Bullet list
new Paragraph({ text: "Item 1", bullet: { level: 0 } })
new Paragraph({ text: "Sub-item", bullet: { level: 1 } })

// Numbered list
new Paragraph({
    text: "First item",
    numbering: { reference: "my-numbering", level: 0 },
})
```

### Page Breaks

```javascript
new Paragraph({ children: [new PageBreak()] })
```

### Multi-column Layouts

```javascript
sections: [{
    properties: {
        column: { count: 2, space: convertInchesToTwip(0.5) },
    },
    children: [/* content flows across columns */],
}]
```

### Hyperlinks

```javascript
const { ExternalHyperlink } = require("docx");

new Paragraph({
    children: [
        new ExternalHyperlink({
            children: [new TextRun({ text: "Click here", style: "Hyperlink" })],
            link: "https://example.com",
        }),
    ],
})
```

## Editing Existing .docx Files

### Approach: Unpack, Edit XML, Repack

```bash
# Unpack
mkdir docx_unpacked
cd docx_unpacked
unzip ../document.docx

# Edit word/document.xml (the main content)
# Edit word/styles.xml (styles)
# Edit [Content_Types].xml (content types)

# Repack
zip -r ../document_edited.docx . -x ".*"
```

### Find and Replace (Python)

```python
from docx import Document

doc = Document("input.docx")
for para in doc.paragraphs:
    if "OLD_TEXT" in para.text:
        for run in para.runs:
            run.text = run.text.replace("OLD_TEXT", "NEW_TEXT")
doc.save("output.docx")
```

## Conversion

```bash
# docx to PDF (requires LibreOffice)
libreoffice --headless --convert-to pdf "document.docx"

# docx to HTML
pandoc "document.docx" -o "document.html"

# Markdown to docx
pandoc "document.md" -o "document.docx"

# docx to docx with reference styling
pandoc "document.docx" --reference-doc="template.docx" -o "styled.docx"
```

## Safety Rules

- Always back up the original file before editing
- Verify output opens correctly in Word after creation
- Test with both simple and complex content before delivering to user
- When editing XML directly, validate the zip structure after repacking
