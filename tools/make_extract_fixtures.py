#!/usr/bin/env python3
"""Archives for the extract package's own tests (extract/tests/fixtures/; test infrastructure, stdlib only).

usage: make_extract_fixtures.py [--out DIR]

The reject archives of the contract (contract/fixtures/extract/, made by make_fixtures.py) hold one entry named a.txt,
which the extraction tool's mapping (22 section 6.1) skips. These archives name entries the mapping selects, so the
plan and the walk (22 section 7.3) can be run over them, and add the one reject case the contract lacks: a central
record whose compressed size lies past the end of the file. None is or contains a real jar.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_fixtures as mf  # noqa: E402

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

MINI = [
    ("version.json", mf.version_json("26.3")),
    ("pack.png", b"\x89PNG mini icon"),
    ("assets/", b""),
    ("assets/.mcassetsroot", b""),
    ("assets/minecraft/", b""),
    ("assets/minecraft/lang/en_us.json", b'{"a": "b"}\n'),
    ("assets/minecraft/textures/block/stone.png", b"stone png bytes"),
    ("data/", b""),
    ("data/.mcassetsroot", b""),
    ("data/minecraft/recipe/stick.json", b'{"type": "x"}'),
    ("data/minecraft/worldgen/biome/plains.json", b"{}"),
    ("data/minecraft/datapacks/trade_rebalance/pack.mcmeta", b'{"pack": {}}'),
    ("data/minecraft/datapacks/trade_rebalance/data/minecraft/loot_table/a.json", b"{}"),
    ("data/minecraft/datapacks/redstone_experiments/pack.mcmeta", b'{"pack": {}}'),
    ("net/minecraft/Foo.class", b"\xca\xfe\xba\xbe"),
    ("META-INF/MANIFEST.MF", b"Manifest-Version: 1.0\n"),
]


def one(name, **kwargs):
    return mf.build_zip([mf.entry(name, mf.HELLO, **kwargs)])


def archives():
    entries = []
    for name, data in MINI:
        if name.endswith("/"):
            entries.append(mf.entry(name, b"", method=0))
        else:
            entries.append(mf.entry(name, data))
    big = b"\0" * (2 * 1048576)
    return {
        "mini.zip": mf.build_zip(entries),
        "walk-bad-crc.zip": one("assets/minecraft/a.txt", crc=0xDEADBEEF),
        "walk-bad-deflate.zip": mf.build_zip([mf.entry("assets/minecraft/a.txt", mf.HELLO, raw=b"\xff\xff\xff\xff\xff\xff", csize=6)]),
        "walk-local-mismatch.zip": one("assets/minecraft/a.txt", local_name="assets/minecraft/b.txt"),
        "walk-big.zip": mf.build_zip([mf.entry("assets/minecraft/big.bin", big)]),
        "plan-upper.zip": one("assets/minecraft/Foo.txt"),
        "plan-dot-segment.zip": one("assets/./a.txt"),
        "plan-empty-segment.zip": one("assets//a.txt"),
        "plan-high-byte.zip": one("assets/minecraft/café.txt"),
        "plan-datapack-stray.zip": one("data/minecraft/datapacks/x/other.txt"),
        "plan-datapack-bare.zip": one("data/minecraft/datapacks/readme.txt"),
        "bad-central-size.zip": mf.build_zip([mf.entry("a.txt", mf.HELLO, central_csize=100000)]),
        "zip64-end.zip": mf.build_zip([mf.entry("a.txt", mf.HELLO)], total=0xFFFF),
        "bad-version-json.zip": mf.build_zip([mf.entry("version.json", b"{not json")]),
    }


def main(argv):
    out = os.path.join(REPO, "extract", "tests", "fixtures")
    if argv[:1] == ["--out"]:
        out = argv[1]
    os.makedirs(out, exist_ok=True)
    for name, data in archives().items():
        with open(os.path.join(out, name), "wb") as handle:
            handle.write(data)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
