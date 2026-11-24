#!/usr/bin/env python3
"""Generator of the format fixtures of contract/fixtures/formats (T0055). Test infrastructure, stdlib only.

usage: make_format_fixtures.py [--out DIR] [--check]

Writes DIR/zip/*.zip (hand-made archives: stored and deflated entries, a bad CRC, a zip64 marker, an encrypted
entry, an empty archive, a non-archive), DIR/json/ (strict-JSON accept and reject files with expected.txt naming the
FM-JS reason of each reject, contract/copy/FORMATS.cpy) and DIR/png/ (one valid file of every kind of
docs/protocol/22-extraction-tool.md section 2.8.1 with its expected RGBA bytes in <name>.rgba, and reject-*.png
files, one per rule of "Outside the set"), default DIR contract/fixtures/formats. The files that already live there
(basic.zip, g8.png, g8.rgba, doc.json, hello.txt) are not generated and are left alone. With --check it compares a
fresh generation with DIR, printing `<path>: differs|missing` per difference, then
`make_format_fixtures: <n> differences`; exits 1 if any. Every byte is made here; no real archive is read.
"""
import os
import struct
import sys
import zlib

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT_DEFAULT = os.path.join(REPO, "contract", "fixtures", "formats")

# ----------------------------------------------------------------------------------------------
# Zip (APPNOTE: local header 04034b50, central 02014b50, end 06054b50)


def raw_deflate(data):
    comp = zlib.compressobj(9, zlib.DEFLATED, -15)
    return comp.compress(data) + comp.flush()


def entry(name, data, method=0, flags=0, crc=None, stored=None, local_size=None, extra=b"", comp_size=None):
    """(local record, central record builder) of one entry; stored is the bytes after the header."""
    body = data if method == 0 else raw_deflate(data)
    if stored is not None:
        body = stored
    return {"name": name.encode(), "data": data, "method": method, "flags": flags, "body": body,
            "crc": zlib.crc32(data) & 0xFFFFFFFF if crc is None else crc, "extra": extra,
            "usize": len(data) if local_size is None else local_size,
            "csize": len(body) if comp_size is None else comp_size}


def build_zip(entries):
    out, central = bytearray(), bytearray()
    for e in entries:
        offset = len(out)
        header = struct.pack("<IHHHHHIIIHH", 0x04034B50, 20, e["flags"], e["method"], 0, 0x215C, e["crc"],
                             e["csize"], e["usize"], len(e["name"]), len(e["extra"]))
        out += header + e["name"] + e["extra"] + e["body"]
        central += struct.pack("<IHHHHHHIIIHHHHHII", 0x02014B50, 20, 20, e["flags"], e["method"], 0, 0x215C, e["crc"],
                               e["csize"], e["usize"], len(e["name"]), len(e["extra"]), 0, 0, 0, 0, offset)
        central += e["name"] + e["extra"]
    end = struct.pack("<IHHHHIIH", 0x06054B50, 0, 0, len(entries), len(entries), len(central), len(out), 0)
    return bytes(out) + bytes(central) + end


def zip_files():
    stored = entry("stored.txt", b"stored entry\n")
    deflated = entry("deflated.txt", b"deflated entry, repeated. " * 20, method=8)
    folder = entry("dir/", b"")
    wrong = entry("bad.txt", b"payload with a wrong crc\n", crc=0xDEADBEEF)
    # zip64: both size fields hold 0xFFFFFFFF and the extra field 0x0001 carries the 8-byte sizes.
    z64 = entry("big.txt", b"zip64 entry\n")
    sizes = struct.pack("<HHQQ", 1, 16, z64["usize"], z64["csize"])
    z64.update(extra=sizes, usize=0xFFFFFFFF, csize=0xFFFFFFFF)
    # encrypted: general purpose bit 0; the data is the 12-byte encryption header and the cipher text (made up).
    secret = entry("secret.txt", b"secret", flags=1, stored=bytes(range(12)) + b"\x5a" * 6)
    return {
        "zip/entries.zip": build_zip([stored, deflated, folder]),
        "zip/bad-crc.zip": build_zip([wrong]),
        "zip/zip64.zip": build_zip([z64]),
        "zip/encrypted.zip": build_zip([secret]),
        "zip/empty.zip": build_zip([]),
        "zip/not-a-zip.bin": b"this is not an archive\n",
    }


# ----------------------------------------------------------------------------------------------
# JSON

JSON_ACCEPT = {
    "accept-object.json": '{"a":[1,2,"x"],"b":{"c":true,"d":null}}\n',
    "accept-empty-containers.json": '{"o":{},"a":[]}',
    "accept-whitespace.json": ' \t\r\n{ "k" : [ 1 , 2 ] }\n ',
    "accept-numbers.json": '[0,-0,1,-1,0.5,1e3,1E-2,2.5e+2,123456789012]',
    "accept-escapes.json": '["a\\"b\\\\c\\/d\\b\\f\\n\\r\\t","\\u00e9\\u20ac\\ud83d\\ude00"]',
    "accept-utf8.json": '{"name":"café €"}',
    "accept-scalar.json": '"just a string"',
    "accept-nested.json": '[[[[[[[[1]]]]]]]]',
    "accept-same-name-in-two-objects.json": '{"a":{"k":1},"b":{"k":2}}',
}
# file -> (text, FM-JS reason)
JSON_REJECT = {
    "reject-comment-line.json": ('{"a":1} // note\n', "FM-JS-COMMENT"),
    "reject-comment-block.json": ('{"a":/* c */1}', "FM-JS-COMMENT"),
    "reject-trailing-comma-object.json": ('{"a":1,}', "FM-JS-TRAILING-COMMA"),
    "reject-trailing-comma-array.json": ('[1,2,]', "FM-JS-TRAILING-COMMA"),
    "reject-duplicate-key.json": ('{"a":1,"b":2,"a":3}', "FM-JS-DUPLICATE-KEY"),
    "reject-trailing-data.json": ('{"a":1} x', "FM-JS-TRAILING-DATA"),
    "reject-unquoted-name.json": ('{a:1}', "FM-JS-UNQUOTED-NAME"),
    "reject-single-quotes.json": ("{'a':1}", "FM-JS-SYNTAX"),
    "reject-unterminated-string.json": ('{"a":"x', "FM-JS-SYNTAX"),
    "reject-empty.json": ('', "FM-JS-SYNTAX"),
    "reject-leading-zero.json": ('[01]', "FM-JS-NUMBER"),
    "reject-nan.json": ('[NaN]', "FM-JS-NUMBER"),
    "reject-bad-escape.json": ('["\\x"]', "FM-JS-ESCAPE"),
    "reject-control-character.json": ('["a\tb"]', "FM-JS-ESCAPE"),
}


def json_files():
    files = {"json/" + k: v.encode("utf-8") for k, v in JSON_ACCEPT.items()}
    lines = ["# file reason (reason: FM-JS-* of contract/copy/FORMATS.cpy; accept-* files give FM-JS-OK)"]
    lines += ["%s FM-JS-OK" % k for k in JSON_ACCEPT]
    for k, (text, reason) in JSON_REJECT.items():
        files["json/" + k] = text.encode("utf-8")
        lines.append("%s %s" % (k, reason))
    files["json/expected.txt"] = ("\n".join(lines) + "\n").encode()
    return files


# ----------------------------------------------------------------------------------------------
# PNG (22 section 2.8.1)

SIG = b"\x89PNG\r\n\x1a\n"
CHANNELS = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}
ADAM7 = [(0, 0, 8, 8), (4, 0, 8, 8), (0, 4, 4, 8), (2, 0, 4, 4), (0, 2, 2, 4), (1, 0, 2, 2), (0, 1, 1, 2)]
PALETTE = [(200, 30, 30), (30, 200, 30), (30, 30, 200), (250, 250, 20), (10, 10, 10), (240, 240, 240), (128, 64, 0), (0, 128, 128)]


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def pixel(x, y, ctype, depth, ncolours):
    top = (1 << depth) - 1
    if ctype == 0:
        return [(x * 3 + y * 5 + x * y) % (top + 1)]
    if ctype == 2:
        if depth == 16:
            return [(x * 4099 + y * 257 + c * 9001) % 65536 for c in range(3)]
        return [(x * 37 + y * 11 + c * 80) % 256 for c in range(3)]
    if ctype == 3:
        return [(x + 2 * y) % ncolours]
    if ctype == 4:
        return [(x * 30 + y * 7) % 256, (x * y * 9 + 40) % 256]
    return [(x * 23 + y * 3) % 256, (y * 41 + x) % 256, (x * y * 5) % 256, 255 - (x * 11 + y * 17) % 200]


def pack_samples(vals, depth):
    if depth == 8:
        return bytes(vals)
    if depth == 16:
        return b"".join(struct.pack(">H", v) for v in vals)
    bits = "".join(format(v, "0%db" % depth) for v in vals)
    bits += "0" * (-len(bits) % 8)
    return bytes(int(bits[i:i + 8], 2) for i in range(0, len(bits), 8))


def filter_row(ftype, line, prev, bpp):
    out = bytearray()
    for i, x in enumerate(line):
        a = line[i - bpp] if i >= bpp else 0
        b = prev[i]
        c = prev[i - bpp] if i >= bpp else 0
        if ftype == 0:
            pred = 0
        elif ftype == 1:
            pred = a
        elif ftype == 2:
            pred = b
        elif ftype == 3:
            pred = (a + b) // 2
        else:
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            pred = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
        out.append((x - pred) & 255)
    return bytes(out)


def to_rgba(vals, ctype, depth, plte, trns):
    top = (1 << depth) - 1
    if ctype == 0:
        g = vals[0] * 255 // top
        return bytes([g, g, g, 0 if trns is not None and vals[0] == trns[0] else 255])
    if ctype == 2:
        rgb = [v >> 8 if depth == 16 else v for v in vals]
        return bytes(rgb + [0 if trns is not None and tuple(vals) == tuple(trns) else 255])
    if ctype == 3:
        alpha = trns[vals[0]] if trns is not None and vals[0] < len(trns) else 255
        return bytes(plte[vals[0]]) + bytes([alpha])
    if ctype == 4:
        return bytes([vals[0], vals[0], vals[0], vals[1]])
    return bytes(vals)


def make_png(w, h, ctype, depth, interlace=0, plte=None, trns=None, splits=(), before=(), after=(), filters=(0, 1, 2, 3, 4)):
    """(png bytes, expected rgba bytes). trns: palette alpha list (type 3), or the key sample tuple (types 0 and 2)."""
    ncol = len(plte) if plte else 1
    px = {(x, y): pixel(x, y, ctype, depth, ncol) for y in range(h) for x in range(w)}
    bpp = max(1, CHANNELS[ctype] * depth // 8)
    raw = bytearray()
    passes = ADAM7 if interlace else [(0, 0, 1, 1)]
    for x0, y0, dx, dy in passes:
        xs, ys = range(x0, w, dx), range(y0, h, dy)
        if not xs or not ys:
            continue
        prev = bytes((len(xs) * CHANNELS[ctype] * depth + 7) // 8)
        for n, y in enumerate(ys):
            line = pack_samples([v for x in xs for v in px[(x, y)]], depth)
            ftype = filters[n % len(filters)]
            raw += bytes([ftype]) + filter_row(ftype, line, prev, bpp)
            prev = line
    comp = zlib.compress(bytes(raw))
    out = bytearray(SIG)
    out += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, depth, ctype, 0, 0, interlace))
    for kind, data in before:
        out += chunk(kind, data)
    if plte:
        out += chunk(b"PLTE", b"".join(bytes(c) for c in plte))
    if trns is not None:
        if ctype == 3:
            out += chunk(b"tRNS", bytes(trns))
        else:
            out += chunk(b"tRNS", b"".join(struct.pack(">H", v) for v in trns))
    cuts = [0] + list(splits) + [len(comp)]
    for a, b in zip(cuts, cuts[1:]):
        out += chunk(b"IDAT", comp[a:b])
    for kind, data in after:
        out += chunk(kind, data)
    out += chunk(b"IEND", b"")
    rgba = b"".join(to_rgba(px[(x, y)], ctype, depth, plte, trns) for y in range(h) for x in range(w))
    return bytes(out), rgba


def png_files():
    files = {}

    def add(name, built):
        files["png/%s.png" % name] = built[0]
        files["png/%s.rgba" % name] = built[1]

    def pal(n):
        return PALETTE[:n]

    W, H = 10, 6
    add("gray1", make_png(W, H, 0, 1))
    add("gray2", make_png(W, H, 0, 2))
    add("gray4", make_png(W, H, 0, 4))
    add("gray8", make_png(W, H, 0, 8))
    add("gray-alpha8", make_png(W, H, 4, 8))
    add("palette1", make_png(W, H, 3, 1, plte=pal(2)))
    add("palette2", make_png(W, H, 3, 2, plte=pal(3)))
    add("palette4", make_png(W, H, 3, 4, plte=pal(8)))
    add("palette8", make_png(W, H, 3, 8, plte=pal(8)))
    add("palette8-adam7", make_png(11, 10, 3, 8, 1, plte=pal(8)))
    add("rgb8", make_png(W, H, 2, 8))
    add("rgb16", make_png(W, H, 2, 16))
    add("rgba8", make_png(W, H, 6, 8))
    add("rgba8-adam7", make_png(11, 10, 6, 8, 1))
    add("rgba8-adam7-small", make_png(3, 3, 6, 8, 1))
    add("rgba8-1x1", make_png(1, 1, 6, 8))
    add("filters", make_png(8, 10, 6, 8))
    add("filters-gray2", make_png(W, 10, 0, 2))
    add("filters-rgb16", make_png(W, 10, 2, 16))
    # one image split into IDAT chunks inside the deflate stream
    add("multi-idat", make_png(16, 16, 6, 8, splits=(20, 41)))
    add("trns-palette", make_png(W, H, 3, 2, plte=pal(3), trns=[0]))
    add("trns-palette-partial", make_png(W, H, 3, 4, plte=pal(8), trns=[255, 128, 0]))
    add("trns-gray-key", make_png(W, H, 0, 8, trns=[(1 * 3 + 2 * 5 + 1 * 2) % 256]))
    add("trns-gray-key-1bit", make_png(W, H, 0, 1, trns=[0]))
    add("trns-gray-key-2bit", make_png(W, H, 0, 2, trns=[1]))
    add("trns-rgb-key", make_png(W, H, 2, 8, trns=tuple(pixel(2, 3, 2, 8, 1))))
    anc_before = [(b"sRGB", b"\x00"), (b"gAMA", struct.pack(">I", 45455)),
                  (b"pHYs", struct.pack(">IIB", 2835, 2835, 1)), (b"tEXt", b"Comment\x00made by hand"),
                  (b"zzZz", b"unknown ancillary chunk")]
    add("ancillary", make_png(W, H, 6, 8, before=anc_before, after=[(b"eXIf", b"MM\x00*\x00\x00\x00\x08")]))
    add("ancillary-palette", make_png(W, H, 3, 4, plte=pal(8), before=anc_before[:3]))

    # rejects: one per rule of 22 section 2.8.1 "Outside the set"
    base = make_png(W, H, 6, 8)[0]
    base_pal = make_png(W, H, 3, 8, plte=pal(4))[0]

    def with_ihdr(fields, data=base):
        w, h, d, c, comp, filt, inter = fields
        return SIG + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, d, c, comp, filt, inter)) + data[33:]

    def idat_chunk(data):
        pos, out = 8, []
        while pos < len(data):
            length = struct.unpack(">I", data[pos:pos + 4])[0]
            out.append((data[pos + 4:pos + 8], data[pos + 8:pos + 8 + length]))
            pos += 12 + length
        return out

    def raw_of(data):
        return zlib.decompress(b"".join(b for k, b in idat_chunk(data) if k == b"IDAT"))

    def rebuild(data, raw):
        parts = [(k, b) for k, b in idat_chunk(data) if k != b"IDAT"]
        out = bytearray(SIG)
        for k, b in parts:
            if k == b"IEND":
                out += chunk(b"IDAT", zlib.compress(raw))
            out += chunk(k, b)
        return bytes(out)

    raw = bytearray(raw_of(base))
    bad_filter = bytearray(raw)
    bad_filter[1 + W * 4] = 5
    rejects = {
        "bad-signature": b"\x89PNX\r\n\x1a\n" + base[8:],
        "too-short": base[:20],
        "ihdr-length-12": SIG + chunk(b"IHDR", base[16:28]) + base[33:],
        "first-chunk-not-ihdr": SIG + chunk(b"IHDX", base[16:29]) + base[33:],
        "bad-bit-depth": with_ihdr((W, H, 3, 6, 0, 0, 0)),
        "bad-colour-type": with_ihdr((W, H, 8, 5, 0, 0, 0)),
        "rgb-depth-1": with_ihdr((W, H, 1, 2, 0, 0, 0)),
        "palette-depth-16": with_ihdr((W, H, 16, 3, 0, 0, 0)),
        "compression-method-1": with_ihdr((W, H, 8, 6, 1, 0, 0)),
        "filter-method-1": with_ihdr((W, H, 8, 6, 0, 1, 0)),
        "interlace-method-2": with_ihdr((W, H, 8, 6, 0, 0, 2)),
        "filter-byte-5": rebuild(base, bytes(bad_filter)),
        "palette-without-plte": with_ihdr((W, H, 8, 3, 0, 0, 0), base_pal[:33] + base_pal[33 + 12 + 12:]),
        "missing-iend": base[:-12],
        "truncated-data": base[:len(base) // 2],
        "inflated-too-short": rebuild(base, bytes(raw[:len(raw) - 2 * (1 + W * 4)])),
        "not-zlib": SIG + chunk(b"IHDR", base[16:29]) + chunk(b"IDAT", b"not a zlib stream") + chunk(b"IEND", b""),
    }
    for name, data in rejects.items():
        files["png/reject-%s.png" % name] = data
    return files


# ----------------------------------------------------------------------------------------------


def generate():
    files = {}
    files.update(zip_files())
    files.update(json_files())
    files.update(png_files())
    return files


def write(out):
    for name, data in generate().items():
        path = os.path.join(out, *name.split("/"))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as handle:
            handle.write(data)


def check(out):
    problems = []
    for name, data in sorted(generate().items()):
        path = os.path.join(out, *name.split("/"))
        if not os.path.exists(path):
            problems.append("%s: missing" % name)
        else:
            with open(path, "rb") as handle:
                if handle.read() != data:
                    problems.append("%s: differs" % name)
    return problems


def main(argv):
    out = OUT_DEFAULT
    do_check = False
    args = list(argv)
    while args:
        arg = args.pop(0)
        if arg == "--out" and args:
            out = args.pop(0)
        elif arg == "--check":
            do_check = True
        else:
            print("usage: make_format_fixtures.py [--out DIR] [--check]")
            return 2
    if do_check:
        problems = check(out)
        for problem in problems:
            print(problem)
        print("make_format_fixtures: %d differences" % len(problems))
        return 1 if problems else 0
    write(out)
    print("make_format_fixtures: wrote %d files under %s" % (len(generate()), out))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
