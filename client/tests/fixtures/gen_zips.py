#!/usr/bin/env python3
"""Zip archive fixture generator for client/tests/test_zip.cob (test infrastructure, excluded from
coverage; docs/protocol/08-resource-packs.md §1.1).

usage: gen_zips.py [OUTDIR]

Writes OUTDIR/<name>.zip (default OUTDIR: the `zips` directory next to this script) with the stdlib
zipfile module, every entry dated 2026-01-01 00:00:00 so that the bytes are deterministic. Some
archives are patched afterwards to make one field of an entry or of the end of central directory
record wrong. A file is rewritten only when its content changed. Quiet on success.

Archives:
  basic.zip      pack.mcmeta (stored), assets/ (directory), assets/cobolcraft/lang/en_us.json
                 (deflated, 300 lines "line NNNN\\n"), empty.txt (deflated, 0 bytes)
  comment.zip    hello.txt (deflated "hello, comment\\n") and a 1000-byte archive comment
  empty.zip      no entries (only the end of central directory record)
  notzip.zip     plain text
  tiny.zip       10 bytes, shorter than an end of central directory record
  truncated.zip  the first half of basic.zip
  badcd.zip      basic.zip with the central directory offset pointing at a local header
  badcount.zip   basic.zip claiming one entry more than its central directory holds
  zip64eocd.zip  basic.zip with the entry counts 0xFFFF (a zip64 archive)
  longname.zip   a 300-byte name (skipped), a 256-byte name, short.txt
  weird.zip      good.txt and entries made unreadable one way each (see WEIRD)
"""
import io
import os
import struct
import sys
import zipfile

DATE = (2026, 1, 1, 0, 0, 0)


def build(entries, comment=b""):
    """entries: list of (name, bytes, compress_type). Returns the archive bytes."""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as z:
        for name, data, method in entries:
            info = zipfile.ZipInfo(name, date_time=DATE)
            info.compress_type = method
            info.external_attr = (0o40755 << 16) | 0x10 if name.endswith("/") else 0o100644 << 16
            info.create_system = 3
            z.writestr(info, data)
        z.comment = comment
    return bytearray(buf.getvalue())


def eocd(data):
    return data.rindex(b"PK\x05\x06")


def central(data, name):
    """Offset of the central directory header of entry `name`."""
    pos = struct.unpack_from("<I", data, eocd(data) + 16)[0]
    while data[pos:pos + 4] == b"PK\x01\x02":
        n, m, k = struct.unpack_from("<HHH", data, pos + 28)
        if bytes(data[pos + 46:pos + 46 + n]) == name.encode():
            return pos
        pos += 46 + n + m + k
    raise KeyError(name)


def local(data, name):
    return struct.unpack_from("<I", data, central(data, name) + 42)[0]


def data_start(data, name):
    at = local(data, name)
    n, m = struct.unpack_from("<HH", data, at + 26)
    return at + 30 + n + m


STORED = zipfile.ZIP_STORED
DEFLATED = zipfile.ZIP_DEFLATED


def archives():
    out = {}
    lang = b"".join(b"line %04d\n" % i for i in range(1, 301))
    basic = build([
        ("pack.mcmeta", b'{"pack":{"pack_format":97,"description":"zip test"}}\n', STORED),
        ("assets/", b"", STORED),
        ("assets/cobolcraft/lang/en_us.json", lang, DEFLATED),
        ("empty.txt", b"", DEFLATED),
    ])
    out["basic"] = basic
    out["comment"] = build([("hello.txt", b"hello, comment\n", DEFLATED)], comment=b"x" * 1000)
    out["empty"] = build([])
    out["notzip"] = bytearray(b"This is not a zip archive at all, just text.\n" * 3)
    out["tiny"] = bytearray(b"PK\x05\x06\x00\x00\x00\x00\x00\x00")
    out["truncated"] = basic[:len(basic) // 2]

    bad = bytearray(basic)
    struct.pack_into("<I", bad, eocd(bad) + 16, 0)
    out["badcd"] = bad

    bad = bytearray(basic)
    struct.pack_into("<HH", bad, eocd(bad) + 8, 5, 5)
    out["badcount"] = bad

    bad = bytearray(basic)
    struct.pack_into("<HH", bad, eocd(bad) + 8, 0xFFFF, 0xFFFF)
    out["zip64eocd"] = bad

    out["longname"] = build([
        ("a" * 296 + ".txt", b"too long\n", STORED),
        ("n" * 252 + ".txt", b"just fits\n", STORED),
        ("short.txt", b"short\n", STORED),
    ])

    weird = build([
        ("good.txt", b"good\n", STORED),
        ("bzip.txt", b"method 12\n", STORED),
        ("crypt.txt", b"encrypted\n", STORED),
        ("zip64.txt", b"zip64 sizes\n", STORED),
        ("farlocal.txt", b"far local header\n", STORED),
        ("badlocal.txt", b"bad local header\n", STORED),
        ("overrun.txt", b"overrun\n", STORED),
        ("storedsize.txt", b"stored size\n", STORED),
        ("badinflate.txt", b"inflate fails " * 8, DEFLATED),
        ("mismatch.txt", b"abcdefgh" * 4, DEFLATED),
    ])
    struct.pack_into("<H", weird, central(weird, "bzip.txt") + 10, 12)
    flags = struct.unpack_from("<H", weird, central(weird, "crypt.txt") + 8)[0]
    struct.pack_into("<H", weird, central(weird, "crypt.txt") + 8, flags | 1)
    struct.pack_into("<I", weird, central(weird, "zip64.txt") + 24, 0xFFFFFFFF)
    struct.pack_into("<I", weird, central(weird, "farlocal.txt") + 42, len(weird) + 100)
    weird[local(weird, "badlocal.txt")] = ord("Q")
    struct.pack_into("<I", weird, central(weird, "overrun.txt") + 20, len(weird) - 40)
    struct.pack_into("<I", weird, central(weird, "overrun.txt") + 24, len(weird) - 40)
    size = struct.unpack_from("<I", weird, central(weird, "storedsize.txt") + 24)[0]
    struct.pack_into("<I", weird, central(weird, "storedsize.txt") + 24, size + 1)
    start = data_start(weird, "badinflate.txt")
    comp = struct.unpack_from("<I", weird, central(weird, "badinflate.txt") + 20)[0]
    weird[start:start + comp] = b"\xff" * comp
    size = struct.unpack_from("<I", weird, central(weird, "mismatch.txt") + 24)[0]
    struct.pack_into("<I", weird, central(weird, "mismatch.txt") + 24, size + 1)
    out["weird"] = weird
    return out


def main(argv):
    outdir = argv[1] if len(argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "zips")
    os.makedirs(outdir, exist_ok=True)
    for name, data in sorted(archives().items()):
        path = os.path.join(outdir, name + ".zip")
        if os.path.isfile(path):
            with open(path, "rb") as f:
                if f.read() == data:
                    continue
        with open(path, "wb") as f:
            f.write(data)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
