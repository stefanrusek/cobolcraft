#!/usr/bin/env python3
"""Independent expected values of client/tests/test_special_bed.cob (lane bugbeditem, T62600 and on): the bed item, docs/protocol/52 sections 5.3 and 5.4, 12 sections 8.1, 8.2, 1.9.

The item definition of a bed is a `minecraft:composite` of two block models (52 5.4): `block/<c>_bed_head` as it is and `block/<c>_bed_foot` translated one block along z (the straw bed:
both turned 180 degrees about Y, head translation (1, 0, 1), foot (1, 0, 2), 52 5.5). Everything is computed from the JSON of the generated vanilla pack (argument 1: its
vanilla-resources directory) with the helpers of gen_item_gui.py (same directory): the model chain, the element corners as seen from outside, the default uv, the display transform
(the `display.gui` of the head model's chain: template_bed, 52 5.3), the ITEMS_3D lights.

  gen_bed_item.py ROOT model BED     one row per quad of the item model in the unit cell (the space the display transform acts on): texture id (40 characters), the four corners'
                                     x, y, z times 1000, then the four corners' u and v times 1000, +000000 each (7 characters), all faces
  gen_bed_item.py ROOT gui BED       one row per quad that faces the viewer under display.gui, sorted far to near, in the format of gen_item_gui.py: texture id, brightness x 10000,
                                     the four corners' x, y (the 16 pixel cell), the four u and v times 1000
"""
import importlib.util
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("gen_item_gui", os.path.join(HERE, "gen_item_gui.py"))
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


def children(root, item):
    """[(model id, sign, tx, ty, tz)] of the composite: x and z are multiplied by sign (the 180 degree turn about Y) before the translation."""
    definition = G.load(root, "items", item)["model"]
    out = []
    for child in definition["models"]:
        t = child.get("transformation", {})
        left = t.get("left_rotation", [0, 0, 0, 1])
        sign = -1 if abs(left[1]) > 0.5 else 1
        tr = t.get("translation", [0, 0, 0])
        out.append((child["model"], sign, tr[0], tr[1], tr[2]))
    return out


def model_quads(root, item):
    """All faces of both children in the unit cell: (texture, [4 corners], [4 uv])."""
    quads = []
    for model, sign, tx, ty, tz in children(root, item):
        textures, elements, gui, light = G.resolve(root, model)
        for e in elements:
            for face in ("down", "up", "north", "south", "west", "east"):
                if face not in e["faces"]:
                    continue
                spec = e["faces"][face]
                pts = [[sign * p[0] / 16 + tx, p[1] / 16 + ty, sign * p[2] / 16 + tz] for p in G.corners(face, e["from"], e["to"])]
                uv = spec.get("uv") or G.default_uv(face, e["from"], e["to"])
                cuv = [(uv[0], uv[1]), (uv[2], uv[1]), (uv[2], uv[3]), (uv[0], uv[3])]
                quads.append((G.texture(textures, spec["texture"]), pts, cuv))
    return quads


def gui_display(root, item):
    model = children(root, item)[0][0]
    textures, elements, gui, light = G.resolve(root, model)
    return gui, light


def gui_quads(root, item):
    gui, light = gui_display(root, item)
    rot = (gui or {}).get("rotation", [0, 0, 0])
    tr = (gui or {}).get("translation", [0, 0, 0])
    sc = (gui or {}).get("scale", [1, 1, 1])
    d = math.pi / 180
    r = G.mm(G.mm(G.rx(rot[0] * d), G.ry(rot[1] * d)), G.rz(rot[2] * d))
    l0, l1 = G.lights()
    shown = []
    for tex, pts, cuv in model_quads(root, item):
        w = []
        for p in pts:
            q = [(p[0] - 0.5) * sc[0], (p[1] - 0.5) * sc[1], (p[2] - 0.5) * sc[2]]
            v = G.mv(r, q)
            w.append([v[0] + tr[0] / 16, v[1] + tr[1] / 16, v[2] + tr[2] / 16])
        e1 = [w[1][i] - w[0][i] for i in range(3)]
        e2 = [w[2][i] - w[1][i] for i in range(3)]
        n = [-(e1[1] * e2[2] - e1[2] * e2[1]), -(e1[2] * e2[0] - e1[0] * e2[2]), -(e1[0] * e2[1] - e1[1] * e2[0])]
        if n[2] <= 1e-9:
            continue
        n = G.norm(n)
        ng = [n[0], -n[1], n[2]]
        b = min(1.0, (max(0.0, sum(a * c for a, c in zip(ng, l0))) + max(0.0, sum(a * c for a, c in zip(ng, l1)))) * 0.6 + 0.4)
        shown.append((sum(p[2] for p in w), tex, b, [(8 + 16 * p[0], 8 - 16 * p[1]) for p in w], cuv))
    shown.sort(key=lambda q: q[0])
    return shown


def num(v):
    return "%+07d" % round(v * 1000)


def main():
    root, mode = sys.argv[1], sys.argv[2]
    for item in sys.argv[3:]:
        if mode == "model":
            for tex, pts, cuv in model_quads(root, item):
                row = "%-40s" % tex + "".join(num(p[a]) for p in pts for a in range(3)) + "".join(num(c[0]) for c in cuv) + "".join(num(c[1]) for c in cuv)
                print("%-12s %s" % (item, row))
        else:
            for z, tex, b, xy, cuv in gui_quads(root, item):
                row = "%-40s%05d" % (tex, round(b * 10000))
                row += "".join(num(p[0]) for p in xy) + "".join(num(p[1]) for p in xy)
                row += "".join(num(c[0]) for c in cuv) + "".join(num(c[1]) for c in cuv)
                print("%-12s %s" % (item, row))


if __name__ == "__main__":
    main()
