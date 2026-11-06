#!/usr/bin/env python3
"""Texture reference generator (test infrastructure, excluded from coverage; research R9).

An independent stdlib-only implementation of every procedural texture recipe of
docs/design/standin-content.md: §1.4 block textures and the missing texture, §2 item icons, §3.1/§3.2
operator, §12.6 sodgrazer and abend, §14.5 drizzle and hailstorm, and the §18 font atlas `ascii`.

usage: gen_textures.py [OUTDIR]

Writes OUTDIR/<name>.rgba for every texture (default OUTDIR: the `textures` directory next to this
script): raw RGBA bytes, rows top to bottom, pixels left to right, bytes R, G, B, A, no header. A file
is rewritten only when its content changed. Quiet on success.
"""
import os
import sys

M32 = 4294967296
TRANSPARENT = (0, 0, 0, 0)


# --- §1.4.1 drawing rules ---------------------------------------------------------------------------

def mix(v):
    v = (v * 2654435761) % M32
    v = (v // 65536) + (v % 65536) * 65536
    v = (v * 2246822519) % M32
    v = (v // 65536) + (v % 65536) * 65536
    return v


def H(*values):
    h = 2166136261
    for v in values:
        h = mix((h + (v % M32)) % M32)
    return h


def colour(hexrgb, alpha=255):
    return (int(hexrgb[1:3], 16), int(hexrgb[3:5], 16), int(hexrgb[5:7], 16), alpha)


def pct(p):
    """Alpha byte of p %: round(p * 255 / 100), halves up."""
    return (p * 255 * 2 + 100) // 200


class Image:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.pixels = [TRANSPARENT] * (width * height)

    def get(self, x, y):
        return self.pixels[y * self.width + x]

    def set(self, x, y, c):
        if 0 <= x < self.width and 0 <= y < self.height:
            self.pixels[y * self.width + x] = c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.set(x, y, c)

    def border(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if x in (x0, x1) or y in (y0, y1):
                    self.set(x, y, c)

    def to_bytes(self):
        return bytes(b for p in self.pixels for b in p)


def sgn(v):
    return (v > 0) - (v < 0)


def line_pixels(x0, y0, x1, y1, w):
    dx, dy = x1 - x0, y1 - y0
    n = max(abs(dx), abs(dy))
    if n == 0:
        centres = [(x0, y0)]
    else:
        centres = [(x0 + sgn(dx) * ((2 * i * abs(dx) + n) // (2 * n)),
                    y0 + sgn(dy) * ((2 * i * abs(dy) + n) // (2 * n))) for i in range(n + 1)]
    out = []
    for (cx, cy) in centres:
        for k in range(w):
            out.append((cx, cy + k) if abs(dx) > abs(dy) else (cx + k, cy))
    return out


def line(img, x0, y0, x1, y1, w, c):
    for (x, y) in line_pixels(x0, y0, x1, y1, w):
        img.set(x, y, c)


def triangle(img, a, b, c, col):
    def edge(p, q, x, y):
        return (q[0] - p[0]) * (y - p[1]) - (q[1] - p[1]) * (x - p[0])
    for y in range(img.height):
        for x in range(img.width):
            e = (edge(a, b, x, y), edge(b, c, x, y), edge(c, a, x, y))
            if all(v >= 0 for v in e) or all(v <= 0 for v in e):
                img.set(x, y, col)


def noise_value(name, x, y):
    return H(*[ord(ch) for ch in name], x, y) % 100


def noise_pixel(name, x, y, fill, p1, c1, p2, c2):
    n = noise_value(name, x, y)
    if n < p1:
        return c1
    if n < p1 + p2:
        return c2
    return fill


def noise(name, fill, p1, c1, p2, c2, size=16):
    img = Image(size, size)
    for y in range(size):
        for x in range(size):
            img.set(x, y, noise_pixel(name, x, y, colour(fill), p1, colour(c1), p2, colour(c2)))
    return img


# --- §1.4.2 block textures --------------------------------------------------------------------------

def baseplate():
    img = Image(16, 16)
    for y in range(16):
        for x in range(16):
            hit = x % 4 == y % 4 or (x % 4) + (y % 4) == 3
            img.set(x, y, colour("#45454F" if hit else "#2B2B33"))
    return img


def turf_side(top, loam):
    img = Image(16, 16)
    for y in range(16):
        for x in range(16):
            use_top = y <= 3 or (y == 4 and x % 2 == 0)
            img.set(x, y, top.get(x, y) if use_top else loam.get(x, y))
    return img


def cardstack_end():
    img = Image(16, 16)
    img.rect(0, 0, 15, 15, colour("#EDE6CF"))
    img.border(0, 0, 15, 15, colour("#B9AE8C"))
    return img


def cardstack_side(punched):
    img = Image(16, 16)
    for y in range(16):
        for x in range(16):
            img.set(x, y, colour("#B9AE8C" if y % 2 == 1 else "#EDE6CF"))
    if punched:
        for y in (2, 10):
            for x in range(16):
                if x % 4 in (1, 2):
                    img.set(x, y, colour("#2A2A2A"))
    return img


def lucite():
    img = Image(16, 16)
    img.border(0, 0, 15, 15, colour("#BFE6F2", pct(60)))
    for (x, y) in ((2, 4), (3, 3), (4, 2)):
        img.set(x, y, colour("#FFFFFF", pct(80)))
    return img


def glowtube(fill, bar, edge):
    img = Image(16, 16)
    img.rect(0, 0, 15, 15, colour(fill))
    img.rect(6, 0, 9, 15, colour(bar))
    img.border(0, 0, 15, 15, colour(edge))
    return img


def ledger_tile():
    img = Image(16, 16)
    for y in range(16):
        for x in range(16):
            if x % 8 == 0 or y % 8 == 0:
                c = "#24425A"
            elif ((x // 4) + (y // 4)) % 2 == 0:
                c = "#3E6C8F"
            else:
                c = "#355D7B"
            img.set(x, y, colour(c))
    return img


def goto_pad():
    img = Image(16, 16)
    for y in range(16):
        for x in range(16):
            r = min(x, y, 15 - x, 15 - y)
            if r == 0:
                c = "#3B2F5C"
            elif r in (1, 3, 5):
                c = "#1F1B2E"
            elif r in (2, 4):
                c = "#6A4FB3"
            else:
                c = "#C9B8FF"
            img.set(x, y, colour(c))
    return img


def missing(width=16, height=16):
    img = Image(width, height)
    for y in range(height):
        for x in range(width):
            img.set(x, y, colour("#F28C28" if ((x + y) // 2) % 2 == 0 else "#1A1A1A"))
    return img


# --- §2 item icons ----------------------------------------------------------------------------------

def pry_bar():
    img = Image(16, 16)
    shaft = line_pixels(2, 13, 12, 3, 2)
    line(img, 2, 13, 12, 3, 2, colour("#9AA3AD"))
    line(img, 11, 2, 9, 2, 2, colour("#9AA3AD"))
    for (x, y) in shaft:
        if y >= 10:
            img.set(x, y, colour("#C24A3A"))
    return img


def trowel():
    img = Image(16, 16)
    triangle(img, (8, 1), (3, 9), (13, 9), colour("#B8BEC6"))
    line(img, 8, 10, 8, 15, 2, colour("#6B4A2B"))
    return img


def flank(meat, fat):
    img = Image(16, 16)
    img.rect(4, 5, 11, 10, colour(meat))
    triangle(img, (11, 5), (14, 8), (11, 10), colour(meat))
    line(img, 5, 6, 10, 6, 1, colour(fat))
    line(img, 1, 7, 3, 7, 2, colour("#EDE6CF"))
    return img


def sod_cake():
    img = Image(16, 16)
    img.rect(3, 7, 12, 12, colour("#7A5634"))
    img.rect(3, 5, 12, 6, colour("#4F8F3A"))
    line(img, 3, 13, 12, 13, 1, colour("#5A3F26"))
    return img


def dump_shard():
    img = Image(16, 16)
    triangle(img, (8, 1), (4, 12), (11, 9), colour("#8F7CFF"))
    line(img, 8, 3, 7, 10, 1, colour("#E8F04A"))
    return img


# --- §3.1 entity strip layout -----------------------------------------------------------------------

FACES = ("front", "back", "left", "right", "top", "bottom")


def entity_layout(parts):
    """parts: [(name, w, h, d)] -> (width, height, {part: {face: (x, y, fw, fh)}})."""
    width = max(4 * w + 2 * d for (_, w, h, d) in parts)
    s = 0
    rects = {}
    for (name, w, h, d) in parts:
        rects[name] = {
            "front": (0, s, w, h),
            "back": (w, s, w, h),
            "left": (2 * w, s, d, h),
            "right": (2 * w + d, s, d, h),
            "top": (2 * w + 2 * d, s, w, d),
            "bottom": (3 * w + 2 * d, s, w, d),
        }
        s += max(h, d)
    return width, s, rects


def each_texel(rect):
    x0, y0, fw, fh = rect
    for y in range(y0, y0 + fh):
        for x in range(x0, x0 + fw):
            yield x, y


def operator():
    width, height, rects = entity_layout([("box", 11, 28, 11)])
    img = Image(width, height)
    for face in FACES:
        for (x, y) in each_texel(rects["box"][face]):
            img.set(x, y, colour("#3A5A9A"))
    fx, fy = rects["box"]["front"][:2]
    img.rect(fx + 2, fy + 4, fx + 3, fy + 5, colour("#F0F0F0"))
    img.rect(fx + 7, fy + 4, fx + 8, fy + 5, colour("#F0F0F0"))
    return img


def sodgrazer():
    width, height, rects = entity_layout([("body", 14, 9, 12), ("head", 8, 8, 5), ("leg", 3, 3, 3)])
    img = Image(width, height)
    for face in FACES:
        for (x, y) in each_texel(rects["body"][face]):
            img.set(x, y, noise_pixel("sodgrazer", x, y, colour("#5E7A3C"), 25, colour("#4F6A31"),
                                      10, colour("#708C4A")))
        for (x, y) in each_texel(rects["head"][face]):
            img.set(x, y, colour("#8A7458"))
        for (x, y) in each_texel(rects["leg"][face]):
            img.set(x, y, colour("#6B5A44"))
    fx, fy = rects["head"]["front"][:2]
    img.rect(fx + 1, fy + 2, fx + 2, fy + 2, colour("#1C1C1C"))
    img.rect(fx + 5, fy + 2, fx + 6, fy + 2, colour("#1C1C1C"))
    return img


def abend():
    width, height, rects = entity_layout([("body", 12, 12, 12)])
    img = Image(width, height)
    for face in FACES:
        for (x, y) in each_texel(rects["body"][face]):
            img.set(x, y, noise_pixel("abend", x, y, colour("#2E2A4F"), 15, colour("#4A4580"),
                                      0, colour("#2E2A4F")))
    for face in FACES:
        x0, y0, fw, fh = rects["body"][face]
        img.border(x0, y0, x0 + fw - 1, y0 + fh - 1, colour("#8F7CFF"))
    fx, fy = rects["body"]["front"][:2]
    img.rect(fx + 2, fy + 3, fx + 4, fy + 4, colour("#E8F04A"))
    img.rect(fx + 7, fy + 3, fx + 9, fy + 4, colour("#E8F04A"))
    return img


# --- §14.5 environment textures ---------------------------------------------------------------------

def drizzle():
    img = Image(16, 16)
    for x in (1, 5, 9, 13):
        s = (x * 7) % 16
        for k in range(5):
            img.set(x, (s + k) % 16, colour("#A7C1DC", pct(66)))
    return img


def hailstorm():
    img = Image(16, 16)
    name = [ord(ch) for ch in "hailstorm"]
    for cy in range(4):
        for cx in range(4):
            r = H(*name, cx, cy)
            ox, oy = r % 3, (r // 3) % 3
            img.rect(4 * cx + ox, 4 * cy + oy, 4 * cx + ox + 1, 4 * cy + oy + 1, colour("#EEF2F7", pct(92)))
    return img


# --- §18 font atlas ---------------------------------------------------------------------------------

GLYPHS = """
00 00 00 00 00 00 00 00|20 20 20 20 20 00 20 00|50 50 50 00 00 00 00 00|50 F8 50 50 50 F8 50 00
20 78 A0 70 28 F0 20 00|C8 D0 20 20 40 B0 98 00|60 90 60 40 A8 90 68 00|20 20 00 00 00 00 00 00
10 20 40 40 40 20 10 00|40 20 10 10 10 20 40 00|00 A8 70 F8 70 A8 00 00|00 20 20 F8 20 20 00 00
00 00 00 00 00 20 20 40|00 00 00 F8 00 00 00 00|00 00 00 00 00 00 20 00|08 10 10 20 40 40 80 00
70 88 98 A8 C8 88 70 00|20 60 20 20 20 20 70 00|70 88 08 30 40 80 F8 00|F0 08 08 70 08 08 F0 00
10 30 50 90 F8 10 10 00|F8 80 F0 08 08 88 70 00|30 40 80 F0 88 88 70 00|F8 08 10 20 20 40 40 00
70 88 88 70 88 88 70 00|70 88 88 78 08 10 60 00|00 00 20 00 00 20 00 00|00 00 20 00 00 20 20 40
10 20 40 80 40 20 10 00|00 00 F8 00 F8 00 00 00|40 20 10 08 10 20 40 00|70 88 08 30 20 00 20 00
70 88 B8 A8 B8 80 78 00|20 50 88 88 F8 88 88 00|F0 88 88 F0 88 88 F0 00|78 80 80 80 80 80 78 00
E0 90 88 88 88 90 E0 00|F8 80 80 F0 80 80 F8 00|F8 80 80 F0 80 80 80 00|78 80 80 B8 88 88 70 00
88 88 88 F8 88 88 88 00|70 20 20 20 20 20 70 00|38 10 10 10 10 90 60 00|88 90 A0 C0 A0 90 88 00
80 80 80 80 80 80 F8 00|88 D8 A8 A8 88 88 88 00|88 C8 A8 98 88 88 88 00|70 88 88 88 88 88 70 00
F0 88 88 F0 80 80 80 00|70 88 88 88 A8 90 68 00|F0 88 88 F0 A0 90 88 00|78 80 80 70 08 08 F0 00
F8 20 20 20 20 20 20 00|88 88 88 88 88 88 70 00|88 88 88 50 50 50 20 00|88 88 88 A8 A8 D8 88 00
88 50 50 20 50 50 88 00|88 88 50 20 20 20 20 00|F8 08 10 20 40 80 F8 00|70 40 40 40 40 40 70 00
80 40 40 20 10 10 08 00|70 10 10 10 10 10 70 00|20 50 88 00 00 00 00 00|00 00 00 00 00 00 00 F8
40 20 00 00 00 00 00 00|00 00 70 08 78 88 78 00|80 80 F0 88 88 88 F0 00|00 00 78 80 80 80 78 00
08 08 78 88 88 88 78 00|00 00 70 88 F8 80 70 00|30 40 F0 40 40 40 40 00|00 00 78 88 88 78 08 70
80 80 F0 88 88 88 88 00|20 00 60 20 20 20 70 00|10 00 30 10 10 10 90 60|80 80 90 A0 C0 A0 90 00
60 20 20 20 20 20 70 00|00 00 D0 A8 A8 A8 88 00|00 00 F0 88 88 88 88 00|00 00 70 88 88 88 70 00
00 00 F0 88 88 F0 80 80|00 00 78 88 88 78 08 08|00 00 B0 C8 80 80 80 00|00 00 78 80 70 08 F0 00
40 40 F0 40 40 40 30 00|00 00 88 88 88 88 78 00|00 00 88 88 50 50 20 00|00 00 88 A8 A8 A8 50 00
00 00 88 50 20 50 88 00|00 00 88 88 88 78 08 70|00 00 F8 10 20 40 F8 00|18 20 20 40 20 20 18 00
20 20 20 20 20 20 20 00|C0 20 20 10 20 20 C0 00|00 00 40 A8 10 00 00 00
"""


def glyph_rows():
    """{code: [8 row bytes]} for codes 32 to 126 (§18 table, in code order)."""
    cells = [c.split() for line_ in GLYPHS.strip().splitlines() for c in line_.split("|")]
    assert len(cells) == 95
    return {32 + i: [int(b, 16) for b in rows] for i, rows in enumerate(cells)}


def ascii_atlas():
    img = Image(128, 48)
    for code, rows in glyph_rows().items():
        x0 = ((code - 32) % 16) * 8
        y0 = ((code - 32) // 16) * 8
        for r, byte in enumerate(rows):
            for k in range(8):
                if byte & (0x80 >> k):
                    img.set(x0 + k, y0 + r, (255, 255, 255, 255))
    return img


# --- all textures -----------------------------------------------------------------------------------

def textures():
    loam = noise("loam", "#7A5634", 15, "#664629", 5, "#8C6640")
    turf_top = noise("turf_top", "#4F8F3A", 20, "#447D32", 10, "#5CA044")
    return [
        ("baseplate", baseplate()),
        ("greystone", noise("greystone", "#7D7F86", 20, "#6C6E75", 8, "#8E9097")),
        ("loam", loam),
        ("turf_top", turf_top),
        ("turf_side", turf_side(turf_top, loam)),
        ("grit", noise("grit", "#D2C08A", 30, "#C2AE76", 10, "#E0D09E")),
        ("cardstack_end", cardstack_end()),
        ("cardstack_side", cardstack_side(False)),
        ("cardstack_side_punched", cardstack_side(True)),
        ("lucite", lucite()),
        ("glowtube_lit", glowtube("#FFE38A", "#FFF6D0", "#A08A3C")),
        ("glowtube_unlit", glowtube("#7A6E4A", "#8F8460", "#4E4630")),
        ("ledger_tile", ledger_tile()),
        ("goto_pad", goto_pad()),
        ("slag", noise("slag", "#4A3F3A", 25, "#3A302C", 12, "#6E4A32")),
        ("missing", missing()),
        ("pry_bar", pry_bar()),
        ("trowel", trowel()),
        ("grazer_flank", flank("#B5544A", "#E3B7A0")),
        ("seared_flank", flank("#6E3B22", "#A0623A")),
        ("sod_cake", sod_cake()),
        ("dump_shard", dump_shard()),
        ("operator", operator()),
        ("sodgrazer", sodgrazer()),
        ("abend", abend()),
        ("drizzle", drizzle()),
        ("hailstorm", hailstorm()),
        ("ascii", ascii_atlas()),
    ]


def main(argv):
    outdir = argv[1] if len(argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "textures")
    os.makedirs(outdir, exist_ok=True)
    for name, img in textures():
        data = img.to_bytes()
        path = os.path.join(outdir, name + ".rgba")
        if os.path.isfile(path):
            with open(path, "rb") as f:
                if f.read() == data:
                    continue
        with open(path, "wb") as f:
            f.write(data)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
