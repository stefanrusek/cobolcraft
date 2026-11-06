#!/usr/bin/env python3
"""PNG fixture generator for client/tests/test_png.cob (test infrastructure, excluded from coverage).

An independent stdlib-only PNG encoder (PNG specification: signature, chunks with CRC-32, IHDR,
PLTE, tRNS, IDAT, IEND; scanline packing of every colour type and bit depth; the five filter types;
Adam7 interlacing; zlib through the stdlib `zlib` module). 08 §7.1 places no restriction on the
PNG files a pack holds, so every combination the PNG specification allows is covered.

usage: gen_png.py [OUTDIR]

Writes OUTDIR/<name>.png for every fixture (default OUTDIR: the `png` directory next to this script)
and, for every image the decoder must read, OUTDIR/<name>.rgba: the expected decoded image as raw
RGBA bytes, rows top to bottom, pixels left to right, no header. The expected bytes are computed
from the generated sample values directly (16-bit samples keep their high byte, samples below 8 bits
are scaled to 0..255, palette entries are looked up, colour types without alpha get 255 or 0 for the
tRNS colour), never by decoding the encoded file. Images that must be rejected get no .rgba file.
A file is rewritten only when its content changed. Quiet on success.

The fixture list (name, width, height) is repeated in client/tests/test_png.cob.
"""
import os
import struct
import sys
import zlib

SIGNATURE = b"\x89PNG\r\n\x1a\n"
CHANNELS = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}
# Adam7 passes: x start, y start, x step, y step.
ADAM7 = [(0, 0, 8, 8), (4, 0, 8, 8), (0, 4, 4, 8), (2, 0, 4, 4), (0, 2, 2, 4), (1, 0, 2, 2), (0, 1, 1, 2)]


class Lcg:
    """Deterministic sample source (64-bit LCG, high bits)."""

    def __init__(self, seed):
        self.state = seed * 2862933555777941757 + 3037000493

    def next(self, bound):
        self.state = (self.state * 6364136223846793005 + 1442695040888963407) % (1 << 64)
        return (self.state >> 33) % bound


def chunk(kind, data):
    body = kind + data
    return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def ihdr(w, h, depth, ctype, comp=0, filt=0, interlace=0):
    return chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, depth, ctype, comp, filt, interlace))


class Image:
    """Sample values of an image: pixels[y][x] is a tuple of CHANNELS[ctype] samples."""

    def __init__(self, w, h, ctype, depth, seed, palette_size=0):
        self.w, self.h, self.ctype, self.depth = w, h, ctype, depth
        rng = Lcg(seed)
        bound = palette_size if ctype == 3 else (1 << depth)
        self.pixels = [[tuple(rng.next(bound) for _ in range(CHANNELS[ctype])) for _ in range(w)]
                       for _ in range(h)]
        self.palette = [(rng.next(256), rng.next(256), rng.next(256)) for _ in range(palette_size)]
        self.trns = None

    def expected_rgba(self):
        d = self.depth
        out = bytearray()

        def to8(v):
            if d == 16:
                return v >> 8
            return v * 255 // ((1 << d) - 1)

        for row in self.pixels:
            for px in row:
                if self.ctype == 0:
                    g = to8(px[0])
                    a = 0 if self.trns is not None and px[0] == self.trns else 255
                    out += bytes((g, g, g, a))
                elif self.ctype == 2:
                    a = 0 if self.trns is not None and px == self.trns else 255
                    out += bytes((to8(px[0]), to8(px[1]), to8(px[2]), a))
                elif self.ctype == 3:
                    r, g, b = self.palette[px[0]]
                    alphas = self.trns or []
                    a = alphas[px[0]] if px[0] < len(alphas) else 255
                    out += bytes((r, g, b, a))
                elif self.ctype == 4:
                    g = to8(px[0])
                    out += bytes((g, g, g, to8(px[1])))
                else:
                    out += bytes(to8(v) for v in px)
        return bytes(out)

    def trns_chunk(self):
        if self.trns is None:
            return b""
        if self.ctype == 0:
            return chunk(b"tRNS", struct.pack(">H", self.trns))
        if self.ctype == 2:
            return chunk(b"tRNS", struct.pack(">HHH", *self.trns))
        return chunk(b"tRNS", bytes(self.trns))


def pack_row(img, pixels):
    """Scanline bytes (without the filter byte) of a list of pixels."""
    d = img.depth
    if d == 16:
        return b"".join(struct.pack(">H", v) for px in pixels for v in px)
    if d == 8:
        return bytes(v for px in pixels for v in px)
    out = bytearray()
    acc, bits = 0, 0
    for px in pixels:
        for v in px:
            acc = (acc << d) | v
            bits += d
            if bits == 8:
                out.append(acc)
                acc, bits = 0, 0
    if bits:
        out.append(acc << (8 - bits))
    return bytes(out)


def paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def filter_row(ftype, row, prior, bpp):
    out = bytearray([ftype])
    for i, x in enumerate(row):
        a = row[i - bpp] if i >= bpp else 0
        b = prior[i]
        c = prior[i - bpp] if i >= bpp else 0
        if ftype == 0:
            v = x
        elif ftype == 1:
            v = x - a
        elif ftype == 2:
            v = x - b
        elif ftype == 3:
            v = x - (a + b) // 2
        elif ftype == 4:
            v = x - paeth(a, b, c)
        else:
            v = x
        out.append(v % 256)
    return bytes(out)


def raw_data(img, interlace, filters):
    """The filtered scanlines of every (non-empty) pass. filters(row_index) gives the filter type,
    row_index counting every scanline of the image in order."""
    bpp = max(1, CHANNELS[img.ctype] * img.depth // 8)
    passes = ADAM7 if interlace else [(0, 0, 1, 1)]
    out = bytearray()
    n = 0
    for xs, ys, xd, yd in passes:
        cols = list(range(xs, img.w, xd))
        rows = list(range(ys, img.h, yd))
        if not cols or not rows:
            continue
        prior = None
        for y in rows:
            row = pack_row(img, [img.pixels[y][x] for x in cols])
            if prior is None:
                prior = bytes(len(row))
            out += filter_row(filters(n), row, prior, bpp)
            prior = row
            n += 1
    return bytes(out)


def cycle(n):
    return n % 5


def encode(img, interlace=0, filters=cycle, idat_split=None, before_idat=b"", raw=None):
    if raw is None:
        raw = raw_data(img, interlace, filters)
    z = zlib.compress(raw, 9)
    plte = b""
    if img.palette:
        plte = chunk(b"PLTE", b"".join(bytes(c) for c in img.palette))
    if idat_split:
        idats = b"".join(chunk(b"IDAT", z[i:i + idat_split]) for i in range(0, len(z), idat_split))
        idats = chunk(b"IDAT", b"") + idats
    else:
        idats = chunk(b"IDAT", z)
    return (SIGNATURE + ihdr(img.w, img.h, img.depth, img.ctype, interlace=interlace) + plte
            + img.trns_chunk() + before_idat + idats + chunk(b"IEND", b""))


def good_fixtures():
    """(name, Image, png bytes) of every image the decoder must read."""
    out = []
    seed = [0]

    def add(name, w, h, ctype, depth, palette_size=0, trns=None, **kw):
        seed[0] += 1
        img = Image(w, h, ctype, depth, seed[0], palette_size)
        if trns == "first":
            img.trns = img.pixels[0][0] if ctype == 2 else img.pixels[0][0][0]
        elif trns is not None:
            img.trns = trns
        out.append((name, img, encode(img, **kw)))

    # Every colour type and bit depth (every row filter type in turn).
    for d in (1, 2, 4, 8, 16):
        add("g%d" % d, 13, 11, 0, d)
    for d in (8, 16):
        add("rgb%d" % d, 13, 11, 2, d)
    for d in (1, 2, 4, 8):
        add("p%d" % d, 13, 11, 3, d, palette_size=min(1 << d, 200))
    for d in (8, 16):
        add("ga%d" % d, 13, 11, 4, d)
    for d in (8, 16):
        add("rgba%d" % d, 13, 11, 6, d)
    # tRNS for grey, RGB and palette images.
    for d in (1, 2, 4, 8, 16):
        add("g%d_trns" % d, 13, 11, 0, d, trns="first")
    for d in (8, 16):
        add("rgb%d_trns" % d, 13, 11, 2, d, trns="first")
    add("p4_trns", 13, 11, 3, 4, palette_size=16, trns=[0, 128, 255, 7])
    add("p8_trns", 13, 11, 3, 8, palette_size=256, trns=[(i * 37) % 256 for i in range(256)])
    # Each filter type alone, on whole-byte and sub-byte pixels.
    for f, fname in enumerate(("none", "sub", "up", "average", "paeth")):
        add("f_%s" % fname, 9, 7, 6, 8, filters=lambda n, f=f: f)
        add("f_%s_g2" % fname, 21, 7, 0, 2, filters=lambda n, f=f: f)
        add("f_%s_rgb16" % fname, 9, 7, 2, 16, filters=lambda n, f=f: f)
    # Adam7 interlacing.
    add("i_g1", 37, 29, 0, 1, interlace=1)
    add("i_g4", 37, 29, 0, 4, interlace=1)
    add("i_g16", 37, 29, 0, 16, interlace=1)
    add("i_rgb8", 37, 29, 2, 8, interlace=1)
    add("i_p2", 37, 29, 3, 2, palette_size=4, interlace=1)
    add("i_ga16", 37, 29, 4, 16, interlace=1)
    add("i_rgba8", 37, 29, 6, 8, interlace=1)
    add("i_rgba16", 37, 29, 6, 16, interlace=1)
    add("i_rgb8_trns", 37, 29, 2, 8, trns="first", interlace=1)
    add("i_1x1", 1, 1, 6, 8, interlace=1)
    add("i_3x2", 3, 2, 0, 8, interlace=1)
    add("i_5x9", 5, 9, 3, 1, palette_size=2, interlace=1)
    # Several IDAT chunks (one of them empty) and ancillary chunks.
    text = chunk(b"tEXt", b"Comment\x00several IDAT chunks") + chunk(b"gAMA", struct.pack(">I", 45455))
    add("multi_idat", 23, 19, 6, 8, idat_split=7, before_idat=text)
    add("multi_idat_i", 23, 19, 3, 4, palette_size=16, idat_split=5, interlace=1)
    # Sizes that are not powers of two, and a larger image.
    add("size_1x1", 1, 1, 0, 8)
    add("size_1x17", 1, 17, 0, 1)
    add("size_17x1", 17, 1, 2, 8)
    add("size_255x3", 255, 3, 6, 8)
    add("size_64x64", 64, 64, 6, 16)
    # A wrong CRC: CRCs are not checked, so the image still decodes.
    seed[0] += 1
    img = Image(7, 5, 6, 8, seed[0])
    png = bytearray(encode(img))
    png[29] ^= 0xFF          # last CRC byte of IHDR (8 + 4 + 4 + 13 = byte 29 from 0)
    out.append(("bad_crc", img, bytes(png)))
    return out


def bad_fixtures():
    """(name, png bytes) of every file the decoder must reject as unreadable."""
    img = Image(7, 5, 6, 8, 900)
    good = encode(img)
    raw = raw_data(img, 0, cycle)
    z = zlib.compress(raw, 9)
    head = SIGNATURE + ihdr(7, 5, 8, 6)
    idat = chunk(b"IDAT", z)
    iend = chunk(b"IEND", b"")
    pimg = Image(7, 5, 3, 8, 901, palette_size=4)
    praw = raw_data(pimg, 0, cycle)
    pz = zlib.compress(praw, 9)
    pal = chunk(b"PLTE", bytes(12))

    def with_ihdr(w, h, depth, ctype, comp=0, filt=0, interlace=0):
        return SIGNATURE + ihdr(w, h, depth, ctype, comp, filt, interlace) + idat + iend

    corrupt = bytearray(z)
    corrupt[2:10] = b"\xff\xfe\xfd\xfc\xfb\xfa\xf9\xf8"
    bad_filter = bytearray(raw)
    bad_filter[0] = 5
    big_index = bytearray(praw)
    big_index[1] = 4         # first pixel: index 4 of a 4-entry palette
    return [
        ("bad_signature", b"\x88" + good[1:]),
        ("too_short", good[:5]),
        ("truncated_header", good[:12]),
        ("truncated_chunk", good[:len(head) + 20]),
        ("corrupt_zlib", head + chunk(b"IDAT", bytes(corrupt)) + iend),
        ("missing_ihdr", SIGNATURE + idat + iend),
        ("ihdr_not_first", SIGNATURE + chunk(b"tEXt", b"a\x00b") + ihdr(7, 5, 8, 6) + idat + iend),
        ("ihdr_twice", head + ihdr(7, 5, 8, 6) + idat + iend),
        ("ihdr_length", SIGNATURE + chunk(b"IHDR", struct.pack(">IIBBBBBB", 7, 5, 8, 6, 0, 0, 0, 0))
         + idat + iend),
        ("missing_idat", head + iend),
        ("missing_iend", head + idat),
        ("zero_width", with_ihdr(0, 5, 8, 6)),
        ("zero_height", with_ihdr(7, 0, 8, 6)),
        ("huge_width", with_ihdr(1 << 31, 5, 8, 6)),
        ("bad_rgb_depth", with_ihdr(7, 5, 4, 2)),
        ("bad_grey_depth", with_ihdr(7, 5, 3, 0)),
        ("bad_palette_depth", with_ihdr(7, 5, 16, 3)),
        ("bad_colour_type", with_ihdr(7, 5, 8, 5)),
        ("bad_compression", with_ihdr(7, 5, 8, 6, comp=1)),
        ("bad_filter_method", with_ihdr(7, 5, 8, 6, filt=1)),
        ("bad_interlace", with_ihdr(7, 5, 8, 6, interlace=2)),
        ("bad_filter_type", head + chunk(b"IDAT", zlib.compress(bytes(bad_filter))) + iend),
        ("short_data", head + chunk(b"IDAT", zlib.compress(raw[:-1])) + iend),
        ("long_data", head + chunk(b"IDAT", zlib.compress(raw + b"\x00")) + iend),
        ("raw_too_big", with_ihdr(16384, 16384, 16, 6)),
        ("palette_missing", SIGNATURE + ihdr(7, 5, 8, 3) + chunk(b"IDAT", pz) + iend),
        ("palette_index", SIGNATURE + ihdr(7, 5, 8, 3) + pal + chunk(b"IDAT", zlib.compress(bytes(big_index)))
         + iend),
        ("palette_length", SIGNATURE + ihdr(7, 5, 8, 3) + chunk(b"PLTE", bytes(10)) + chunk(b"IDAT", pz) + iend),
        ("palette_empty", SIGNATURE + ihdr(7, 5, 8, 3) + chunk(b"PLTE", b"") + chunk(b"IDAT", pz) + iend),
        ("palette_too_long", SIGNATURE + ihdr(7, 5, 8, 3) + chunk(b"PLTE", bytes(771)) + chunk(b"IDAT", pz)
         + iend),
        ("trns_length", SIGNATURE + ihdr(7, 5, 8, 0) + chunk(b"tRNS", b"\x00") + idat + iend),
        ("trns_alpha_type", head + chunk(b"tRNS", b"\x00\x00") + idat + iend),
        ("trns_long_palette", SIGNATURE + ihdr(7, 5, 8, 3) + pal + chunk(b"tRNS", bytes(5)) + chunk(b"IDAT", pz)
         + iend),
    ]


def write_if_changed(path, data):
    if os.path.isfile(path):
        with open(path, "rb") as f:
            if f.read() == data:
                return
    with open(path, "wb") as f:
        f.write(data)


def main(argv):
    outdir = argv[1] if len(argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "png")
    os.makedirs(outdir, exist_ok=True)
    for name, img, png in good_fixtures():
        write_if_changed(os.path.join(outdir, name + ".png"), png)
        write_if_changed(os.path.join(outdir, name + ".rgba"), img.expected_rgba())
    for name, png in bad_fixtures():
        write_if_changed(os.path.join(outdir, name + ".png"), png)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
