#!/usr/bin/env python3
"""Resource pack fixture generator (test infrastructure, excluded from coverage; research R9).

usage: gen_packs.py [OUTDIR]

Writes the local and server pack fixtures of the US18 client tests (08 §1, §2, §3) into OUTDIR
(default: the `packs` directory next to this script): pack folders `<name>/` and zip packs
`<name>.zip` (deflated entries, fixed timestamps), and for each zip `<name>.zip.sha1` (its lowercase
hex SHA-1, 08 §9.3). Textures are PNG files written by an independent stdlib encoder (RGBA, 8 bits,
filter 0). A file is rewritten only when its content changed. Quiet on success.

Colours used (RGBA): alpha greystone 10,200,10; beta greystone 10,10,200; beta trowel 200,200,10;
overlay root 1,2,3, active overlay 4,5,6, inactive overlay 7,8,9; ov_texture greystone 250,0,250;
server greystone 0,250,250; server2 greystone 250,250,0.
"""
import hashlib
import io
import json
import os
import struct
import sys
import zipfile
import zlib

STAMP = (2026, 1, 1, 0, 0, 0)


def png(width, height, pixel):
    """A PNG (colour type 6, depth 8, filter 0) of pixel(x, y) -> (r, g, b, a)."""
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            raw.extend(pixel(x, y))

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
            + chunk(b"IEND", b""))


def noise(size, seed):
    """A size x size image of deterministic noise (it hardly compresses)."""
    state = [seed]

    def pixel(x, y):
        state[0] = (state[0] * 1103515245 + 12345) % 2147483648
        v = state[0]
        return (v & 255, (v >> 8) & 255, (v >> 16) & 255, 255)
    return png(size, size, pixel)


def solid(rgb, size=16):
    return png(size, size, lambda x, y: (rgb[0], rgb[1], rgb[2], 255))


def meta(description, **pack):
    body = {"pack": dict({"description": description}, **pack)}
    return json.dumps(body, indent=1).encode()


def new_style(description, **extra):
    return meta(description, min_format=97, max_format=97, **extra)


GREYSTONE = "assets/cobolcraft/textures/block/greystone.png"
LOAM = "assets/cobolcraft/textures/block/loam.png"

# name -> (kind, {path: bytes})
PACKS = {
    "alpha": ("folder", {
        "pack.mcmeta": new_style("Alpha pack"),
        "pack.png": png(32, 32, lambda x, y: (x * 8, y * 8, 100, 255)),
        GREYSTONE: solid((10, 200, 10)),
        ".DS_Store": b"junk",
    }),
    "beta": ("zip", {
        "pack.mcmeta": json.dumps({"pack": {"description": {"text": "Beta pack"}, "min_format": 97,
                                            "max_format": 97}}).encode(),
        GREYSTONE: solid((10, 10, 200)),
        "assets/cobolcraft/textures/item/trowel.png": solid((200, 200, 10)),
        "assets/cobolcraft/textures/Block/Upper.png": solid((1, 1, 1)),
        "assets/cobolcraft/textures/../escape.png": solid((1, 1, 1)),
        "assets/cobolcraft/textures/./dot.png": solid((1, 1, 1)),
        "assets//empty.png": solid((1, 1, 1)),
        "assets/cobolcraft/textures/": b"",
        "assets/cobolcraft/.ds_store": b"junk",
    }),
    "old": ("zip", {"pack.mcmeta": meta("Old pack", pack_format=10)}),
    "newer": ("folder", {"pack.mcmeta": meta("Newer pack", min_format=99, max_format=99)}),
    "mystery": ("folder", {"pack.mcmeta": meta("Mystery pack", min_format=97), "pack.png": b"not a png"}),
    "nometa": ("zip", {GREYSTONE: solid((1, 1, 1))}),
    "badmeta": ("folder", {"pack.mcmeta": b'{"other": 1}'}),
    "notapack": ("folder", {"readme.txt": b"not a pack"}),
    "badtex": ("folder", {
        "pack.mcmeta": new_style("Bad texture pack"),
        GREYSTONE: b"\x89PNG\r\n\x1a\nbroken",
        LOAM: b"",
        "assets/cobolcraft/textures/block/grit.png": solid((5, 5, 5)),
        "assets/cobolcraft/textures/block/slag.png": solid((5, 5, 5), 600),
        "assets/cobolcraft/lang/en_us.json": b'{"cobolcraft.screen.title.packs": "Unreadable"}',
    }),
    "overlay": ("folder", {
        "pack.mcmeta": json.dumps({
            "pack": {"description": "Overlay pack", "min_format": 97, "max_format": 97},
            "overlays": {"entries": [
                {"directory": "ov_on", "min_format": 97, "max_format": 97},
                {"directory": "ov_off", "min_format": 90, "max_format": 91},
            ]},
        }).encode(),
        GREYSTONE: solid((1, 2, 3)),
        "assets/cobolcraft/textures/block/grit.png": solid((1, 2, 3)),
        LOAM + ".mcmeta": b"{}",
        "ov_on/" + GREYSTONE: solid((4, 5, 6)),
        "ov_off/" + GREYSTONE: solid((7, 8, 9)),
        "ov_off/" + LOAM: solid((7, 8, 9)),
    }),
    "filtered": ("folder", {
        "pack.mcmeta": json.dumps({
            "pack": {"description": "Filter pack", "min_format": 97, "max_format": 97},
            "filter": {"block": [{"namespace": "cobolcraft", "path": "^textures/block/(loam|grit)\\.png$"}]},
        }).encode(),
        "assets/cobolcraft/textures/block/grit.png": solid((9, 9, 9)),
    }),
    "ov_texture": ("folder", {
        "pack.mcmeta": new_style("Texture override"),
        GREYSTONE: solid((250, 0, 250)),
    }),
    "ov_blockstate": ("folder", {
        "pack.mcmeta": new_style("Block state override"),
        "assets/cobolcraft/blockstates/loam.json": json.dumps(
            {"variants": {"": {"model": "cobolcraft:block/greystone"}}}).encode(),
    }),
    "ov_model": ("folder", {
        "pack.mcmeta": new_style("Model override"),
        "assets/cobolcraft/models/block/grit.json": json.dumps(
            {"parent": "cobolcraft:block/template_uniform",
             "textures": {"all": "cobolcraft:block/slag"}}).encode(),
    }),
    "ov_itemdef": ("folder", {
        "pack.mcmeta": new_style("Item definition override"),
        "assets/cobolcraft/items/trowel.json": json.dumps(
            {"model": {"type": "minecraft:model", "model": "cobolcraft:item/pry_bar"}}).encode(),
    }),
    "ov_lang": ("folder", {
        "pack.mcmeta": new_style("Language override"),
        "assets/cobolcraft/lang/en_us.json": json.dumps(
            {"cobolcraft.screen.title.packs": "Texture Packs"}).encode(),
    }),
    "bigicon": ("folder", {
        "pack.mcmeta": new_style("Big icon pack"),
        "pack.png": noise(300, 7),
    }),
    "badzip": ("zip", {"pack.mcmeta": b'{"other": 1}'}),
    "server": ("zip", {
        "pack.mcmeta": new_style("Server pack"),
        GREYSTONE: solid((0, 250, 250)),
    }),
    "server2": ("zip", {
        "pack.mcmeta": new_style("Second server pack"),
        GREYSTONE: solid((250, 250, 0)),
    }),
}

# "many": 300 blocks of 16 pixels (colour (n % 256, n // 256, 7)) and 6 of 32 pixels (colour (9, 9, 100 + k)),
# for the atlas tests of any sprite size and more than 128 sprites (US3-3).
MANY = {"pack.mcmeta": new_style("Many sprites")}
for _n in range(300):
    MANY["assets/many/textures/block/b%03d.png" % _n] = solid((_n % 256, _n // 256, 7))
for _k in range(6):
    MANY["assets/many/textures/block/big%d.png" % _k] = solid((9, 9, 100 + _k), 32)
PACKS["many"] = ("folder", MANY)


def strip(colours, size=16):
    """A vertical strip of solid frames: frame k is colours[k], each size x size."""
    return png(size, size * len(colours), lambda x, y: colours[y // size] + (255,))


# Animated textures (08 §7.? animation): "animbase" holds the static yellow bad.png; "anim" holds
# flow (red, green, blue; frames 0, 2 for 4 ticks, 1; frametime 2), mix (black, grey; frametime 4,
# interpolated), bad (a malformed animation file over a two-frame strip: falls back to animbase's
# yellow), oddsize (a 16 x 20 image: not a multiple of the frame size, nothing below: missing).
PACKS["animbase"] = ("folder", {
    "pack.mcmeta": new_style("Animation base"),
    "assets/anim/textures/block/bad.png": solid((255, 255, 0)),
    "assets/anim/textures/block/broken.png": solid((0, 255, 255)),
})
PACKS["anim"] = ("folder", {
    "pack.mcmeta": new_style("Animations"),
    "assets/anim/textures/block/flow.png": strip([(255, 0, 0), (0, 255, 0), (0, 0, 255)]),
    "assets/anim/textures/block/flow.png.mcmeta": b'{"animation":{"frametime":2,"frames":[0,{"index":2,"time":4},1]}}',
    "assets/anim/textures/block/mix.png": strip([(0, 0, 0), (200, 200, 200)]),
    "assets/anim/textures/block/mix.png.mcmeta": b'{"animation":{"frametime":4,"interpolate":true}}',
    "assets/anim/textures/block/bad.png": strip([(1, 1, 1), (2, 2, 2)]),
    "assets/anim/textures/block/bad.png.mcmeta": b"{not json",
    "assets/anim/textures/block/oddsize.png": png(16, 20, lambda x, y: (5, 5, 5, 255)),
    "assets/anim/textures/block/oddsize.png.mcmeta": b'{"animation":{}}',
    "assets/anim/textures/block/broken.png": b"\x89PNG\r\n\x1a\nbroken",
    "assets/anim/textures/block/plain.png": solid((50, 60, 70)),
    "assets/anim/textures/block/plain.png.mcmeta": b'{"texture":{"blur":true}}',
})


# "ctm": connected-texture rules in the formats other clients know (OptiFine, MCPatcher, Continuity); the
# game does not support them and must ignore them without error (FR-010), loading the rest.
PACKS["ctm"] = ("folder", {
    "pack.mcmeta": new_style("Connected textures"),
    "assets/minecraft/optifine/ctm/glass/glass.properties": b"method=ctm\ntiles=0-46\nmatchBlocks=glass\n",
    "assets/minecraft/optifine/ctm/glass/0.png": solid((1, 2, 3)),
    "assets/minecraft/mcpatcher/ctm/stone/stone.properties": b"method=random\ntiles=0-3\n",
    "assets/minecraft/optifine/cit.properties": b"type=item\n",
    "assets/ctm/models/block/glass.json": b'{"loader":"continuity:ctm","parent":"block/cube_all"}',
    "assets/ctm/textures/block/after_ctm.png": solid((11, 22, 33)),
})


def zip_bytes(files):
    out = io.BytesIO()
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(files):
            info = zipfile.ZipInfo(path, STAMP)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            archive.writestr(info, files[path])
    return out.getvalue()


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if os.path.exists(path):
        with open(path, "rb") as handle:
            if handle.read() == data:
                return
    with open(path, "wb") as handle:
        handle.write(data)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "packs")
    for name, (kind, files) in PACKS.items():
        if kind == "folder":
            for path, data in files.items():
                write(os.path.join(out, name, path), data)
        else:
            data = zip_bytes(files)
            write(os.path.join(out, name + ".zip"), data)
            write(os.path.join(out, name + ".zip.sha1"), hashlib.sha1(data).hexdigest().encode())
    write(os.path.join(out, "broken.zip"), b"this is not a zip archive")
    write(os.path.join(out, "readme.txt"), b"not a pack")


if __name__ == "__main__":
    main()
