#!/usr/bin/env python3
"""BatchTimer mark — four Swiss color arcs around a timer tick."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
PAPER = (247, 244, 238)
RED = (226, 61, 61)
YELLOW = (245, 196, 0)
BLUE = (36, 88, 245)
GREEN = (31, 122, 77)
INK = (17, 17, 17)


def main() -> None:
    canvas = Image.new('RGB', (SIZE, SIZE), PAPER)
    d = ImageDraw.Draw(canvas)
    cx = cy = SIZE / 2
    r_outer = 380
    r_inner = 250
    colors = [RED, YELLOW, BLUE, GREEN]
    for i, color in enumerate(colors):
        start = 270 + i * 90
        end = start + 82
        d.pieslice(
            (cx - r_outer, cy - r_outer, cx + r_outer, cy + r_outer),
            start=start,
            end=end,
            fill=color,
        )
    d.ellipse(
        (cx - r_inner, cy - r_inner, cx + r_inner, cy + r_inner),
        fill=PAPER,
    )
    # tick
    d.ellipse((cx - 28, cy - 28, cx + 28, cy + 28), fill=INK)
    d.line((cx, cy - 20, cx, cy - 160), fill=INK, width=28)
    d.line((cx, cy, cx + 110, cy + 40), fill=BLUE, width=22)

    root = Path(__file__).resolve().parents[1]
    assets = root / 'assets'
    assets.mkdir(exist_ok=True)
    canvas.save(assets / 'logo.png', optimize=True)
    pad = int(SIZE * 0.12)
    inner = canvas.resize((SIZE - pad * 2, SIZE - pad * 2), Image.Resampling.LANCZOS)
    fg = Image.new('RGB', (SIZE, SIZE), PAPER)
    fg.paste(inner, (pad, pad))
    fg.save(assets / 'icon_foreground.png', optimize=True)
    print('wrote assets/logo.png')


if __name__ == '__main__':
    main()
