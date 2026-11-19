#!/usr/bin/env python3
"""Render every page of a PDF to a PNG at a given DPI. Run via `uv run --with pymupdf pdf_to_pngs.py`.

Usage: pdf_to_pngs.py <input.pdf> <output_dir> [dpi]
Prints one output PNG path per line (page order preserved) so callers can parse stdout.
"""
import sys
from pathlib import Path


def main():
    pdf_path = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    dpi = int(sys.argv[3]) if len(sys.argv) > 3 else 300
    out_dir.mkdir(parents=True, exist_ok=True)

    import pymupdf

    doc = pymupdf.open(pdf_path)
    zoom = dpi / 72
    matrix = pymupdf.Matrix(zoom, zoom)
    stem = pdf_path.stem
    for i, page in enumerate(doc):
        pix = page.get_pixmap(matrix=matrix)
        out_path = out_dir / f"{stem}-p{i+1:03d}.png"
        pix.save(out_path)
        print(out_path)


if __name__ == "__main__":
    main()
