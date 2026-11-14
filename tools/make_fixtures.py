#!/usr/bin/env python3
"""Generator of the hand-made content trees and reject archives (T0056, T0057). Test infrastructure, stdlib only.

usage: make_fixtures.py [--out DIR] [--check]

Writes DIR/content/ (small generated directories, docs/protocol/22-extraction-tool.md sections 5.2, 6.2, 6.4, 6.5
and 8.2) and DIR/extract/ (small reject archives for 22 sections 4.2 and 7.4, and the baseline archive), default DIR
contract/fixtures. With --check it generates into a scratch directory and compares with DIR, printing
`<path>: differs|missing|extra` per difference, then `make_fixtures: <n> differences`; exits 1 if any.
No real jar or Faithful file is read or copied; every byte is made here (SC-012).

content/ trees: valid (status ok), stale (digest changed), damaged (a data sentinel removed), incomplete (marker
but no manifest), damaged-manifest (a key out of order). `absent` is the missing directory and has no tree.
extract/ archives: see the header of extract/expected.txt, which lists the code each one is meant to give.
"""
import json
import os
import shutil
import struct
import sys
import tempfile
import zlib

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

JAR_SHA = "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d"

# ----------------------------------------------------------------------------------------------
# Content trees


def j(value):
    return json.dumps(value, indent=2) + "\n"


def png_1x1():
    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    raw = b"\x00" + bytes([255, 0, 255, 255])  # one RGBA pixel, filter 0 (the missing-texture magenta)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


RESOURCE_MCMETA = ('{\n  "pack": {\n    "description": "The default look and feel of Minecraft",\n'
                   '    "min_format": [97, 1],\n    "max_format": 97\n  }\n}\n')
DATA_MCMETA = ('{\n  "pack": {\n    "description": "The default data for Minecraft",\n'
               '    "min_format": [121, 0],\n    "max_format": 121\n  }\n}\n')


def dimension(scale, skylight, ceiling, fixed, min_y, height, logical, burn, ambient, spawn_light, block_limit, skybox, cardinal):
    return {
        "has_fixed_time": fixed, "has_skylight": skylight, "has_ceiling": ceiling, "has_ender_dragon_fight": False,
        "coordinate_scale": scale, "min_y": min_y, "height": height, "logical_height": logical, "infiniburn": burn,
        "ambient_light": ambient, "monster_spawn_light_level": spawn_light, "monster_spawn_block_light_limit": block_limit,
        "skybox": skybox, "cardinal_light": cardinal,
    }


def content_files():
    """{relative path: bytes} of the valid generated directory, without manifest.txt, index.txt and the marker."""
    files = {
        "vanilla-resources/pack.mcmeta": RESOURCE_MCMETA.encode(),
        "vanilla-resources/pack.png": png_1x1(),
        "vanilla-resources/assets/minecraft/lang/en_us.json": j({"gui.done": "Done", "menu.quit": "Quit Game", "block.minecraft.stone": "Stone"}).encode(),
        "vanilla-resources/assets/minecraft/atlases/blocks.json": j({"sources": [{"type": "minecraft:directory", "source": "block", "prefix": "block/"}]}).encode(),
        "vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png": png_1x1(),
        "vanilla-resources/assets/minecraft/textures/block/stone.png": png_1x1(),
        "vanilla-data/pack.mcmeta": DATA_MCMETA.encode(),
        "vanilla-data/pack.png": png_1x1(),
        "vanilla-data/data/minecraft/worldgen/biome/plains.json": j({"has_precipitation": True, "temperature": 0.8, "downfall": 0.4, "effects": {"water_color": 4159204}}).encode(),
        "vanilla-data/data/minecraft/worldgen/biome/desert.json": j({"has_precipitation": False, "temperature": 2.0, "downfall": 0.0, "effects": {"water_color": 4159204}}).encode(),
        "vanilla-data/data/minecraft/worldgen/noise_settings/overworld.json": j({"sea_level": 63, "legacy_random_source": False, "default_block": {"Name": "minecraft:stone"}}).encode(),
        "vanilla-data/data/minecraft/dimension_type/overworld.json": j(dimension(1.0, True, False, False, -64, 384, 384, "#minecraft:infiniburn_overworld", 0.0, {"type": "minecraft:uniform", "min_inclusive": 0, "max_inclusive": 7}, 0, "overworld", "default")).encode(),
        "vanilla-data/data/minecraft/dimension_type/the_nether.json": j(dimension(8.0, False, True, True, 0, 256, 128, "#minecraft:infiniburn_nether", 0.1, 7, 15, "none", "nether")).encode(),
        "vanilla-data/data/minecraft/dimension_type/the_end.json": j(dimension(1.0, True, False, True, 0, 256, 256, "#minecraft:infiniburn_end", 0.25, 15, 0, "end", "default")).encode(),
        "vanilla-data/data/minecraft/damage_type/generic.json": j({"message_id": "generic", "scaling": "when_caused_by_living_non_player", "exhaustion": 0.0}).encode(),
        "vanilla-data/data/minecraft/chat_type/chat.json": j({"chat": {"translation_key": "chat.type.text", "parameters": ["sender", "content"]}, "narration": {"translation_key": "chat.type.text.narrate", "parameters": ["sender", "content"]}}).encode(),
        "vanilla-data/data/minecraft/recipe/stick.json": j({"type": "minecraft:crafting_shaped", "category": "misc", "key": {"#": "#minecraft:planks"}, "pattern": ["#", "#"], "result": {"count": 4, "id": "minecraft:stick"}}).encode(),
        "vanilla-data/data/minecraft/recipe/crafting_table.json": j({"type": "minecraft:crafting_shaped", "category": "misc", "key": {"#": "#minecraft:planks"}, "pattern": ["##", "##"], "result": {"id": "minecraft:crafting_table"}}).encode(),
        "vanilla-data/data/minecraft/tags/block/planks.json": j({"values": ["minecraft:oak_planks", "minecraft:spruce_planks"]}).encode(),
        "vanilla-data/data/minecraft/tags/item/planks.json": j({"values": ["minecraft:oak_planks", "minecraft:spruce_planks"]}).encode(),
        "featurepacks/minecart_improvements/pack.mcmeta": j({"pack": {"description": "Minecart Improvements", "min_format": 121, "max_format": 121}}).encode(),
        "featurepacks/redstone_experiments/pack.mcmeta": j({"pack": {"description": "Redstone Experiments", "min_format": 121, "max_format": 121}}).encode(),
        "featurepacks/trade_rebalance/pack.mcmeta": j({"pack": {"description": "Trade Rebalance", "min_format": 121, "max_format": 121}}).encode(),
        "featurepacks/trade_rebalance/data/minecraft/tags/point_of_interest_type/acquirable_job_site.json": j({"values": ["minecraft:armorer"]}).encode(),
    }
    return files


def manifest_text(files, sha=JAR_SHA, order=None):
    counts = {"resource": 0, "data": 0, "feature": 0}
    for path in files:
        counts[{"vanilla-resources": "resource", "vanilla-data": "data", "featurepacks": "feature"}[path.split("/", 1)[0]]] += 1
    pairs = [
        ("format", "1"), ("tool", "cobolcraft-extract 1"), ("jar-version", "26.3"), ("jar-sha256", sha), ("jar-size", "41483720"),
        ("world-version", "5023"), ("protocol-version", "777"), ("resource-format", "97.1"), ("data-format", "121.0"),
        ("files-resource", str(counts["resource"])), ("files-data", str(counts["data"])), ("files-feature", str(counts["feature"])),
        ("files-total", str(len(files))),
    ]
    if order:
        pairs = [pairs[i] for i in order]
    return "".join("%s=%s\n" % p for p in pairs)


def index_text(files):
    return "".join("%08x %d %s\n" % (zlib.crc32(data) & 0xFFFFFFFF, len(data), path) for path, data in files.items())


def write_tree(root, files, manifest=True, manifest_text_override=None, marker=True, index=True):
    for path, data in files.items():
        target = os.path.join(root, path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "wb") as handle:
            handle.write(data)
    os.makedirs(root, exist_ok=True)
    if marker:
        open(os.path.join(root, ".cobolcraft-generated"), "wb").close()
    if index:
        with open(os.path.join(root, "index.txt"), "w", encoding="utf-8", newline="\n") as handle:
            handle.write(index_text(files))
    if manifest:
        with open(os.path.join(root, "manifest.txt"), "w", encoding="utf-8", newline="\n") as handle:
            handle.write(manifest_text_override if manifest_text_override is not None else manifest_text(files))


def write_content(out):
    files = content_files()
    write_tree(os.path.join(out, "valid"), files)
    stale_sha = JAR_SHA[:-1] + ("0" if JAR_SHA[-1] != "0" else "1")
    write_tree(os.path.join(out, "stale"), files, manifest_text_override=manifest_text(files, sha=stale_sha))
    damaged = dict(files)
    del damaged["vanilla-data/data/minecraft/recipe/stick.json"]
    write_tree(os.path.join(out, "damaged"), damaged, manifest_text_override=manifest_text(files))
    write_tree(os.path.join(out, "incomplete"), files, manifest=False)
    swapped = list(range(13))
    swapped[2], swapped[3] = swapped[3], swapped[2]  # jar-sha256 before jar-version: out of order
    write_tree(os.path.join(out, "damaged-manifest"), files, manifest_text_override=manifest_text(files, order=swapped))


# ----------------------------------------------------------------------------------------------
# Reject archives (a raw zip writer, so every header field can be made wrong on purpose)


def entry(name, data, method=8, crc=None, csize=None, usize=None, flags=0, local_name=None, raw=None, central_extra=b"", version=20,
          central_csize=None, central_usize=None):
    stored = raw if raw is not None else data
    if raw is None and method == 8:  # raw deflate, no zlib header or checksum
        compressor = zlib.compressobj(9, zlib.DEFLATED, -15)
        stored = compressor.compress(data) + compressor.flush()
    return {
        "name": name, "stored": stored, "method": method, "flags": flags, "version": version,
        "crc": (zlib.crc32(data) & 0xFFFFFFFF) if crc is None else crc,
        "csize": len(stored) if csize is None else csize, "usize": len(data) if usize is None else usize,
        "local_name": name if local_name is None else local_name, "central_extra": central_extra,
        "central_csize": central_csize, "central_usize": central_usize,
    }


def build_zip(entries, disk=0, total=None, cd_size=None, eocd_sig=b"PK\x05\x06", central_sig=b"PK\x01\x02"):
    body = b""
    central = b""
    for e in entries:
        offset = len(body)
        name = e["local_name"].encode()
        body += struct.pack("<4s5H3I2H", b"PK\x03\x04", e["version"], e["flags"], e["method"], 0, 0x21, e["crc"], e["csize"], e["usize"], len(name), 0)
        body += name + e["stored"]
        cname = e["name"].encode()
        csize = e["csize"] if e["central_csize"] is None else e["central_csize"]
        usize = e["usize"] if e["central_usize"] is None else e["central_usize"]
        central += struct.pack("<4s6H3I5H2I", central_sig, e["version"], e["version"], e["flags"], e["method"], 0, 0x21, e["crc"], csize, usize,
                               len(cname), len(e["central_extra"]), 0, 0, 0, 0, offset)
        central += cname + e["central_extra"]
    count = len(entries) if total is None else total
    size = len(central) if cd_size is None else cd_size
    eocd = struct.pack("<4s4H2IH", eocd_sig, disk, 0, count, count, size, len(body), 0)
    return body + central + eocd


HELLO = b"hello world"
VERSION_JSON = {"id": "26.3", "world_version": 5023, "protocol_version": 777}


def version_json(ident):
    data = dict(VERSION_JSON)
    data["id"] = ident
    return json.dumps(data).encode()


def reject_archives():
    """[(file name, bytes, code, description)]."""
    base = [entry("a.txt", HELLO)]
    out = [
        ("ok-small.zip", build_zip([entry("a.txt", HELLO), entry("b.txt", b"stored", method=0)]), "ok",
         "two entries (deflated a.txt = 'hello world', stored b.txt): reads cleanly; the good baseline"),
        ("c-too-short.bin", b"PK\x05\x06" + b"\x00" * 6, "CCX-020", "10 bytes: too short for an end record (22 byte minimum)"),
        ("c-not-a-zip.bin", b"This is not a zip file, only text that is long enough to hold an end record search.\n", "CCX-020", "text: no end record"),
        ("c-no-end-record.zip", build_zip(base, eocd_sig=b"PK\x05\x07"), "CCX-020", "a valid archive whose end record signature is damaged: no end record"),
        ("c-central-mismatch.zip", build_zip(base, total=3, cd_size=999), "CCX-020", "end record counts 3 entries and a 999-byte central directory: does not match"),
        ("c-bad-central-record.zip", build_zip(base, central_sig=b"PK\x01\x09"), "CCX-020", "the central record signature is wrong: bad central record at entry 0"),
        ("c-zip64.zip", build_zip([entry("a.txt", HELLO, central_csize=0xFFFFFFFF, central_usize=0xFFFFFFFF, version=45,
                                        central_extra=struct.pack("<HHQQ", 1, 16, len(HELLO), len(HELLO)))]), "CCX-021", "central sizes 0xFFFFFFFF with a zip64 extra field: zip64"),
        ("c-several-disks.zip", build_zip(base, disk=1), "CCX-021", "end record disk number 1: several disks"),
        ("c-encrypted.zip", build_zip([entry("a.txt", HELLO, flags=1)]), "CCX-021", "entry a.txt has general purpose flag bit 0: encrypted entry"),
        ("c-method-99.zip", build_zip([entry("a.txt", HELLO, method=99, raw=HELLO)]), "CCX-021", "entry a.txt uses compression method 99"),
        ("c-no-version-json.zip", build_zip(base), "CCX-030", "no version.json: the id is unknown"),
        ("c-wrong-id.zip", build_zip([entry("version.json", version_json("99.9"))]), "CCX-030", "version.json says id 99.9, not in the table"),
        ("c-right-id-wrong-digest.zip", build_zip([entry("version.json", version_json("26.3"))]), "CCX-031", "version.json says 26.3 but size and digest differ from the row"),
        ("t-bad-crc.zip", build_zip([entry("a.txt", HELLO, method=0, crc=0xDEADBEEF)]), "CCX-040", "stored a.txt whose recorded CRC-32 is 0xdeadbeef"),
        ("t-bad-deflate.zip", build_zip([entry("a.txt", HELLO, raw=b"\xff\xff\xff\xff\xff\xff", csize=6)]), "CCX-041", "a.txt method 8 with data that is not deflate: bad deflate data"),
        ("t-size-mismatch.zip", build_zip([entry("a.txt", HELLO, usize=20)]), "CCX-041", "a.txt inflates to 11 bytes but the record says 20: size 11 instead of 20"),
        ("t-local-mismatch.zip", build_zip([entry("a.txt", HELLO, local_name="b.txt")]), "CCX-042", "the local header names b.txt, the central record a.txt"),
        ("t-bad-path.zip", build_zip([entry("assets/../evil.txt", HELLO)]), "CCX-043", "entry name with a .. segment cannot become a pack path"),
        ("t-duplicate-path.zip", build_zip([entry("assets/minecraft/a.txt", HELLO), entry("assets/minecraft/a.txt", b"second")]), "CCX-044", "two entries map to the same output path"),
    ]
    return out


EXTRACT_HEADER = """# Reject archives for the extraction tool (22 sections 4.2, 7.3, 7.4, 12 T9). One line per file: <file> <code>.
# Made by tools/make_fixtures.py; every archive is tiny and hand-made, none is or contains a real jar.
# c-*: the archive as a whole, C1 to C4 of 22 section 4.2 and the zip checks (CCX-020, 021, 030, 031).
# t-*: one entry is bad; the code is the one the entry reader of 7.3 step 7 raises (CCX-040 to 044). A tool that
#      identifies the jar first (C4) reaches these only for an identified jar, so they are the tests of
#      ZIP-READ-RANGE and EX-WALK on an archive opened directly.
# ok-*: a baseline that reads cleanly (code "ok").
# C5 (CCX-045) and the size-known/digest-known rows cannot be built without the real jar and are tested with it.
"""

def write_extract(out):
    os.makedirs(out, exist_ok=True)
    lines = [EXTRACT_HEADER]
    for name, data, code, text in reject_archives():
        with open(os.path.join(out, name), "wb") as handle:
            handle.write(data)
        lines.append("# %s: %s\n%s %s\n" % (name, text, name, code))
    with open(os.path.join(out, "expected.txt"), "w", encoding="utf-8", newline="\n") as handle:
        handle.write("".join(lines))


# ----------------------------------------------------------------------------------------------


def write_all(out):
    write_content(os.path.join(out, "content"))
    write_extract(os.path.join(out, "extract"))


def _files(root):
    found = set()
    for base, _, names in os.walk(root):
        for name in names:
            found.add(os.path.relpath(os.path.join(base, name), root))
    return found


def compare(fresh, committed):
    """['<path>: differs|missing|extra'] between a fresh generation and the committed tree (content/ and extract/)."""
    problems = []
    for part in ("content", "extract"):
        a, b = _files(os.path.join(fresh, part)), _files(os.path.join(committed, part))
        for rel in sorted(a | b):
            label = "%s/%s" % (part, rel)
            if rel not in b:
                problems.append("%s: missing" % label)
            elif rel not in a:
                problems.append("%s: extra" % label)
            elif open(os.path.join(fresh, part, rel), "rb").read() != open(os.path.join(committed, part, rel), "rb").read():
                problems.append("%s: differs" % label)
    return problems


def main(argv):
    out = os.path.join(REPO, "contract", "fixtures")
    check = False
    args = list(argv)
    while args:
        arg = args.pop(0)
        if arg == "--out":
            out = args.pop(0)
        elif arg == "--check":
            check = True
        else:
            print("usage: make_fixtures.py [--out DIR] [--check]")
            return 2
    if check:
        scratch = tempfile.mkdtemp()
        try:
            write_all(scratch)
            problems = compare(scratch, out)
        finally:
            shutil.rmtree(scratch)
        for problem in problems:
            print(problem)
        print("make_fixtures: %d differences" % len(problems))
        return 1 if problems else 0
    for part in ("content", "extract"):
        shutil.rmtree(os.path.join(out, part), ignore_errors=True)
    write_all(out)
    print("make_fixtures: wrote %s and %s" % (os.path.join(out, "content"), os.path.join(out, "extract")))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
