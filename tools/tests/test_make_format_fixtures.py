"""Tests of tools/make_format_fixtures.py (T0055): zip, strict-JSON and PNG fixtures of contract/fixtures/formats.
The PNG tests decode every valid file with a small reference decoder written here from docs/protocol/22 section
2.8.1 (it shares no code with the generator) and compare with the stored expected RGBA; the committed files are
compared with a fresh generation."""
import io
import json
import os
import shutil
import struct
import sys
import tempfile
import unittest
import zipfile
import zlib

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import make_format_fixtures as mff

FILES = mff.generate()
PNG_SIG = b"\x89PNG\r\n\x1a\n"
ADAM7 = [(0, 0, 8, 8), (4, 0, 8, 8), (0, 4, 4, 8), (2, 0, 4, 4), (0, 2, 2, 4), (1, 0, 2, 2), (0, 1, 1, 2)]


def chunks(data):
    pos, out = 8, []
    while pos < len(data):
        length, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        crc = struct.unpack(">I", data[pos + 8 + length:pos + 12 + length])[0]
        assert crc == zlib.crc32(kind + body) & 0xFFFFFFFF, kind
        out.append((kind, body))
        pos += 12 + length
    return out


def unfilter(raw, width_bytes, bpp, rows):
    out, prev, pos = [], bytearray(width_bytes), 0
    for _ in range(rows):
        ftype, line = raw[pos], bytearray(raw[pos + 1:pos + 1 + width_bytes])
        assert ftype <= 4 and len(line) == width_bytes
        pos += 1 + width_bytes
        for i in range(width_bytes):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            if ftype == 1:
                line[i] = (line[i] + a) & 255
            elif ftype == 2:
                line[i] = (line[i] + b) & 255
            elif ftype == 3:
                line[i] = (line[i] + (a + b) // 2) & 255
            elif ftype == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 255
        out.append(bytes(line))
        prev = line
    return out, pos


def samples(line, depth, count):
    if depth == 8:
        return list(line[:count])
    if depth == 16:
        return [line[2 * i] << 8 | line[2 * i + 1] for i in range(count)]
    return [(line[i * depth // 8] >> (8 - depth - (i * depth) % 8)) & ((1 << depth) - 1) for i in range(count)]


def decode(data):
    """Reference decoder: RGBA bytes, or raises on anything outside the contract."""
    assert data[:8] == PNG_SIG
    parts = chunks(data)
    assert parts[0][0] == b"IHDR" and len(parts[0][1]) == 13 and parts[-1][0] == b"IEND"
    w, h, depth, ctype, comp, filt, inter = struct.unpack(">IIBBBBB", parts[0][1])
    legal = {0: (1, 2, 4, 8), 2: (8, 16), 3: (1, 2, 4, 8), 4: (8,), 6: (8,)}
    assert depth in legal[ctype] and comp == 0 and filt == 0 and inter in (0, 1)
    assert ctype != 3 or any(k == b"PLTE" for k, _ in parts)
    plte = next((b for k, b in parts if k == b"PLTE"), b"")
    trns = next((b for k, b in parts if k == b"tRNS"), b"")
    raw = zlib.decompress(b"".join(b for k, b in parts if k == b"IDAT"))
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    bpp = max(1, channels * depth // 8)
    pixels = {}
    passes = ADAM7 if inter else [(0, 0, 1, 1)]
    pos = 0
    for x0, y0, dx, dy in passes:
        pw, ph = (w - x0 + dx - 1) // dx, (h - y0 + dy - 1) // dy
        if pw <= 0 or ph <= 0:
            continue
        wb = (pw * channels * depth + 7) // 8
        rows, used = unfilter(raw[pos:], wb, bpp, ph)
        pos += used
        for m, line in enumerate(rows):
            vals = samples(line, depth, pw * channels)
            for n in range(pw):
                pixels[(x0 + n * dx, y0 + m * dy)] = vals[n * channels:(n + 1) * channels]
    out = bytearray()
    for y in range(h):
        for x in range(w):
            v = pixels[(x, y)]
            top = (1 << depth) - 1
            if ctype == 0:
                g = v[0] * 255 // top
                a = 0 if trns and v[0] == struct.unpack(">H", trns)[0] else 255
                out += bytes([g, g, g, a])
            elif ctype == 2:
                key = struct.unpack(">3H", trns) if trns else None
                rgb = [s >> 8 if depth == 16 else s for s in v]
                out += bytes(rgb + [0 if key and tuple(v) == key else 255])
            elif ctype == 3:
                i = v[0]
                out += plte[3 * i:3 * i + 3] + bytes([trns[i] if i < len(trns) else 255])
            elif ctype == 4:
                out += bytes([v[0], v[0], v[0], v[1]])
            else:
                out += bytes(v)
    return bytes(out)


class Png(unittest.TestCase):
    def test_every_valid_png_decodes_to_its_stored_rgba(self):
        names = [n for n in FILES if n.startswith("png/") and n.endswith(".png") and "reject-" not in n]
        self.assertGreaterEqual(len(names), 25)
        for name in names:
            self.assertEqual(decode(FILES[name]), FILES[name[:-4] + ".rgba"], name)

    def test_every_kind_of_the_survey_is_present(self):
        kinds = set()
        for name, data in FILES.items():
            if name.startswith("png/") and name.endswith(".png") and "reject-" not in name:
                ihdr = struct.unpack(">IIBBBBB", chunks(data)[0][1])
                kinds.add((ihdr[3], ihdr[2], ihdr[6]))
        want = {(0, 1, 0), (0, 2, 0), (0, 4, 0), (0, 8, 0), (4, 8, 0), (3, 1, 0), (3, 2, 0), (3, 4, 0), (3, 8, 0),
                (3, 8, 1), (2, 8, 0), (2, 16, 0), (6, 8, 0), (6, 8, 1)}
        self.assertEqual(want - kinds, set())

    def test_multi_idat_ancillary_and_trns_files(self):
        def kinds(name):
            return [k for k, _ in chunks(FILES["png/" + name + ".png"])]
        self.assertGreaterEqual(kinds("multi-idat").count(b"IDAT"), 3)
        order = kinds("ancillary")
        for kind in (b"sRGB", b"pHYs", b"gAMA", b"tEXt", b"eXIf", b"zzZz"):
            self.assertIn(kind, order)
        self.assertGreater(order.index(b"eXIf"), order.index(b"IDAT"))
        for name in ("trns-palette", "trns-gray-key", "trns-gray-key-1bit", "trns-rgb-key"):
            self.assertIn(b"tRNS", kinds(name), name)
        rgba = FILES["png/trns-palette.rgba"]
        self.assertIn(0, rgba[3::4])
        self.assertIn(255, rgba[3::4])

    def test_all_five_filter_types_occur(self):
        data = FILES["png/filters.png"]
        parts = chunks(data)
        w, h, depth, ctype = struct.unpack(">IIBB", parts[0][1][:10])
        raw = zlib.decompress(b"".join(b for k, b in parts if k == b"IDAT"))
        step = 1 + w * 4
        self.assertEqual({raw[i * step] for i in range(h)}, {0, 1, 2, 3, 4})

    def test_rejects_are_not_valid_pngs(self):
        names = [n for n in FILES if n.startswith("png/reject-")]
        self.assertGreaterEqual(len(names), 14)
        for name in names:
            with self.assertRaises(Exception, msg=name):
                decode(FILES[name])


class Zip(unittest.TestCase):
    def archive(self, name):
        return zipfile.ZipFile(io.BytesIO(FILES["zip/" + name]))

    def test_entries_stored_and_deflated(self):
        z = self.archive("entries.zip")
        info = {i.filename: i for i in z.infolist()}
        self.assertEqual(info["stored.txt"].compress_type, zipfile.ZIP_STORED)
        self.assertEqual(info["deflated.txt"].compress_type, zipfile.ZIP_DEFLATED)
        self.assertEqual(z.read("stored.txt"), b"stored entry\n")
        self.assertEqual(z.read("deflated.txt"), b"deflated entry, repeated. " * 20)
        self.assertIn("dir/", info)
        self.assertEqual(z.testzip(), None)

    def test_bad_crc(self):
        z = self.archive("bad-crc.zip")
        self.assertEqual(z.testzip(), "bad.txt")

    def test_zip64_marker(self):
        z = self.archive("zip64.zip")
        info = z.infolist()[0]
        self.assertEqual(info.file_size, len(b"zip64 entry\n"))
        data = FILES["zip/zip64.zip"]
        self.assertIn(struct.pack("<I", 0xFFFFFFFF), data)

    def test_encrypted_entry(self):
        z = self.archive("encrypted.zip")
        self.assertTrue(z.infolist()[0].flag_bits & 1)
        with self.assertRaises(RuntimeError):
            z.read("secret.txt")

    def test_empty_and_not_a_zip(self):
        self.assertEqual(len(self.archive("empty.zip").infolist()), 0)
        with self.assertRaises(zipfile.BadZipFile):
            zipfile.ZipFile(io.BytesIO(FILES["zip/not-a-zip.bin"]))


def strict(text):
    def pairs(items):
        keys = [k for k, _ in items]
        if len(keys) != len(set(keys)):
            raise ValueError("duplicate key")
        return dict(items)
    return json.loads(text, object_pairs_hook=pairs, parse_constant=lambda c: (_ for _ in ()).throw(ValueError(c)))


class Json(unittest.TestCase):
    def test_accepts_parse(self):
        names = [n for n in FILES if n.startswith("json/accept-")]
        self.assertGreaterEqual(len(names), 6)
        for name in names:
            strict(FILES[name].decode("utf-8"))

    def test_rejects_fail_for_the_documented_reason(self):
        expected = dict(line.split() for line in FILES["json/expected.txt"].decode().splitlines() if line and line[0] != "#")
        for name in [n for n in FILES if n.startswith("json/reject-")]:
            self.assertIn(os.path.basename(name), expected)
            with self.assertRaises(ValueError, msg=name):
                strict(FILES[name].decode("utf-8"))
        for needed in ("comment", "trailing-comma", "duplicate"):
            self.assertTrue(any(needed in n for n in expected), needed)


class Committed(unittest.TestCase):
    def test_check_passes_on_the_repository(self):
        self.assertEqual(mff.check(mff.OUT_DEFAULT), [])

    def test_check_reports_a_changed_and_a_missing_file(self):
        scratch = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, scratch)
        mff.write(scratch)
        os.remove(os.path.join(scratch, "zip", "empty.zip"))
        with open(os.path.join(scratch, "zip", "bad-crc.zip"), "ab") as handle:
            handle.write(b"x")
        problems = mff.check(scratch)
        self.assertIn("zip/empty.zip: missing", problems)
        self.assertIn("zip/bad-crc.zip: differs", problems)

    def test_existing_hand_made_files_are_not_generated(self):
        for name in ("basic.zip", "g8.png", "doc.json", "hello.txt", "g8.rgba"):
            self.assertNotIn(name, FILES)


if __name__ == "__main__":
    unittest.main()
