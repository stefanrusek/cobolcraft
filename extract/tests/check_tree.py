#!/usr/bin/env python3
"""Independent check of the extraction tool's output (test infrastructure, stdlib only; T0312, docs/protocol/22 §5.2, §6, §12).

usage: python3 -I check_tree.py JAR GENERATED_DIR

Reads the jar with zipfile and the tree with os, and prints one `CHECK <name> <value>` line per fact; the test
asserts the values. Nothing here is the tool's own code: the mapping of 22 §6.1 is written again from the document.
"""
import json
import os
import struct
import sys
import zlib
import zipfile

jar_path, root = sys.argv[1], sys.argv[2]


def out(name, value):
    print("CHECK %s %s" % (name, value))


jar = zipfile.ZipFile(jar_path)
expected = []  # (dest path, bytes) in central directory order, pack.png twice
skipped = 0
for info in jar.infolist():
    name = info.filename
    if name.endswith("/"):
        continue
    if name in ("assets/.mcassetsroot", "data/.mcassetsroot", "version.json"):
        skipped += 1
    elif name == "pack.png":
        data = jar.read(name)
        expected.append(("vanilla-resources/pack.png", data))
        expected.append(("vanilla-data/pack.png", data))
    elif name.startswith("assets/"):
        expected.append(("vanilla-resources/" + name, jar.read(name)))
    elif name.startswith("data/minecraft/datapacks/"):
        expected.append(("featurepacks/" + name[len("data/minecraft/datapacks/"):], jar.read(name)))
    elif name.startswith("data/"):
        expected.append(("vanilla-data/" + name, jar.read(name)))
    else:
        skipped += 1
out("skipped", skipped)

# Every payload file: bytes equal to the jar's (T6).
different = 0
missing = 0
for dest, data in expected:
    path = os.path.join(root, dest)
    if not os.path.isfile(path):
        missing += 1
        continue
    with open(path, "rb") as handle:
        if handle.read() != data:
            different += 1
out("payload-files", len(expected))
out("payload-missing", missing)
out("payload-different", different)

# Every file of the tree is a payload file, a generated pack.mcmeta or one of the three tool files.
listed = set(dest for dest, _ in expected) | {"vanilla-resources/pack.mcmeta", "vanilla-data/pack.mcmeta"}
tool_files = {".cobolcraft-generated", "manifest.txt", "index.txt"}
extra = 0
counts = {"vanilla-resources": 0, "vanilla-data": 0, "featurepacks": 0}
dirs = {"vanilla-resources": 0, "vanilla-data": 0, "featurepacks": 0}
for folder, subdirs, files in os.walk(root):
    rel = os.path.relpath(folder, root)
    top = rel.split(os.sep)[0]
    # Directories below the pack's own root: a feature pack's root is featurepacks/<name>.
    depth = 0 if rel == "." else len(rel.split(os.sep))
    if top in dirs and depth >= (3 if top == "featurepacks" else 2):
        dirs[top] += 1
    for name in files:
        relative = os.path.normpath(os.path.join(rel, name)).replace(os.sep, "/")
        if relative in tool_files:
            continue
        counts[relative.split("/")[0]] += 1
        if relative not in listed:
            extra += 1
out("extra-files", extra)
out("files-resource", counts["vanilla-resources"])
out("files-data", counts["vanilla-data"])
out("files-feature", counts["featurepacks"])
out("dirs-resource", dirs["vanilla-resources"])
out("dirs-data", dirs["vanilla-data"])
out("dirs-feature", dirs["featurepacks"])

# index.txt: one line per payload file, the generated pack.mcmeta first, then central directory order (6.5).
lines = open(os.path.join(root, "index.txt"), encoding="utf-8").read().split("\n")
out("index-final-newline", "yes" if lines[-1] == "" else "no")
lines = lines[:-1]
want = [("vanilla-resources/pack.mcmeta", None), ("vanilla-data/pack.mcmeta", None)] + expected
bad = 0
for line, (dest, data) in zip(lines, want):
    crc, size, path = line.split(" ", 2)
    if data is None:
        with open(os.path.join(root, dest), "rb") as handle:
            data = handle.read()
    if path != dest or int(size) != len(data) or crc != "%08x" % (zlib.crc32(data) & 0xFFFFFFFF):
        bad += 1
out("index-lines", len(lines))
out("index-bad-lines", bad + abs(len(lines) - len(want)))

# The generated pack.mcmeta (6.2).
for pack, text in (("vanilla-resources", '{\n  "pack": {\n    "description": "The default look and feel of Minecraft",\n    "min_format": [97, 1],\n    "max_format": 97\n  }\n}\n'),
                   ("vanilla-data", '{\n  "pack": {\n    "description": "The default data for Minecraft",\n    "min_format": [121, 0],\n    "max_format": 121\n  }\n}\n')):
    with open(os.path.join(root, pack, "pack.mcmeta"), "rb") as handle:
        data = handle.read()
    out("mcmeta-%s" % pack, "ok" if data == text.encode() else "different")
    out("mcmeta-%s-crc" % pack, "%08x" % (zlib.crc32(data) & 0xFFFFFFFF))
    out("mcmeta-%s-size" % pack, len(data))

# Content kinds (T7).
json_files = json_bad = nbt = nbt_bad = png = png_bad = mcmeta_orphans = 0
for dest, data in expected:
    if dest.endswith(".json") or dest.endswith(".mcmeta"):
        json_files += 1
        try:
            json.loads(data.decode("utf-8"))
        except ValueError:
            json_bad += 1
    if dest.endswith(".nbt"):
        nbt += 1
        if data[:2] != b"\x1f\x8b":
            nbt_bad += 1
    if dest.endswith(".png") and dest.startswith("vanilla-resources/assets/"):
        png += 1
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            png_bad += 1
    if dest.endswith(".png.mcmeta") and ("vanilla-resources/" + dest[len("vanilla-resources/"):-len(".mcmeta")], None) and \
            not os.path.isfile(os.path.join(root, dest[:-len(".mcmeta")])):
        mcmeta_orphans += 1
out("json-files", json_files)
out("json-unparsable", json_bad)
out("nbt-files", nbt)
out("nbt-without-gzip-magic", nbt_bad)
out("png-files", png)
out("png-without-signature", png_bad)
out("texture-mcmeta-without-png", mcmeta_orphans)
