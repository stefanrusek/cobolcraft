#!/usr/bin/env python3
"""Independent expected values of client/tests/test_item_gui.cob (lane bugguiitems, T59700 and on): the GUI icon of a block item, 12 sections 8.1, 8.2 and 1.9, 08 sections 5.1 to 5.6.

Everything is computed from the JSON of the generated vanilla pack (argument 1: its vanilla-resources directory) and the formulas of the documents only:
  item definition items/<id>.json -> "model.model" -> the model chain (parent): elements from the nearest model with elements, texture slots merged child first, display.gui and
  gui_light from the nearest model that names them (default side)                                              (08 5.1 to 5.3, 5.6)
  face corners as seen from outside the element (side faces: top is +y; up: top edge north, right edge east; down: top edge south, right edge east), default uv of 5.5.1, the
  face rotation and element rotation left out (none of the items below has one)
  M = translate(t / 16) . Rx(rx) . Ry(ry) . Rz(rz) . scale(s) . translate(-0.5)  (12 8.2), a point p of the unit cell goes to M p; the cell is 16 pixels: x = 8 + 16 p.x, y = 8 - 16 p.y
  a quad shows when it faces the viewer on the +z side: the outward normal (the view-space normal from the corners) has z above 0; far to near by the sum of the corners' z
  lighting (12 1.9): gui_light side: ITEMS_3D, the default pair L0 = normalize(0.2, 1, -0.7), L1 = normalize(-0.2, 1, 0.7) transformed by scale(1, -1, 1), rotateYXZ(1.0821, 3.2376, 0),
  rotateYXZ(-0.3927, 2.3562, 0) (JOML: Ry . Rx . Rz of the angles y, x, z), the normal taken in GUI space (y down: scale(1, -1, 1) of the view normal); light = min(1, (max(0, n.L0) +
  max(0, n.L1)) x 0.6 + 0.4); gui_light front: 1.
Prints one row per quad for each item named on the command line: item, the texture id (40 characters), brightness x 10000 (5 digits), the four corners' x, y, u, v times 1000 as
+000000 (7 characters each), ready to paste as FILLER VALUE lines of the test. Usage: gen_item_gui.py VANILLA-RESOURCES item [item ...]"""
import json
import math
import os
import sys


def load(root, kind, ident):
    ns, _, path = ident.partition(":") if ":" in ident else ("minecraft", "", ident)
    if not path:
        ns, path = "minecraft", ident
    with open(os.path.join(root, "assets", ns, kind, path + ".json")) as f:
        return json.load(f)


def resolve(root, model_id):
    chain = []
    cur = model_id
    while cur:
        m = load(root, "models", cur)
        chain.append(m)
        cur = m.get("parent")
    textures = {}
    for m in reversed(chain):
        textures.update(m.get("textures", {}))
    elements = None
    gui = None
    light = None
    for m in chain:
        if elements is None and "elements" in m:
            elements = m["elements"]
        if gui is None and "gui" in m.get("display", {}):
            gui = m["display"]["gui"]
        if light is None and "gui_light" in m:
            light = m["gui_light"]
    return textures, elements or [], gui, light or "side"


def texture(textures, ref):
    for _ in range(8):
        if not ref.startswith("#"):
            break
        ref = textures[ref[1:]]
    return ref if ":" in ref else "minecraft:" + ref


def mm(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]


def mv(m, v):
    return [sum(m[i][k] * v[k] for k in range(3)) for i in range(3)]


def rx(a):
    c, s = math.cos(a), math.sin(a)
    return [[1, 0, 0], [0, c, -s], [0, s, c]]


def ry(a):
    c, s = math.cos(a), math.sin(a)
    return [[c, 0, s], [0, 1, 0], [-s, 0, c]]


def rz(a):
    c, s = math.cos(a), math.sin(a)
    return [[c, -s, 0], [s, c, 0], [0, 0, 1]]


def norm(v):
    n = math.sqrt(sum(x * x for x in v))
    return [x / n for x in v]


def lights():
    flip = [[1, 0, 0], [0, -1, 0], [0, 0, 1]]
    r = mm(mm(ry(-0.3927), rx(2.3562)), mm(ry(1.0821), rx(3.2376)))
    out = []
    for l in (norm([0.2, 1, -0.7]), norm([-0.2, 1, 0.7])):
        out.append(mv(r, mv(flip, l)))
    return out


def corners(face, f, t):
    fx, fy, fz = f
    tx, ty, tz = t
    return {
        "up": [(fx, ty, fz), (tx, ty, fz), (tx, ty, tz), (fx, ty, tz)],
        "down": [(fx, fy, tz), (tx, fy, tz), (tx, fy, fz), (fx, fy, fz)],
        "north": [(tx, ty, fz), (fx, ty, fz), (fx, fy, fz), (tx, fy, fz)],
        "south": [(fx, ty, tz), (tx, ty, tz), (tx, fy, tz), (fx, fy, tz)],
        "west": [(fx, ty, fz), (fx, ty, tz), (fx, fy, tz), (fx, fy, fz)],
        "east": [(tx, ty, tz), (tx, ty, fz), (tx, fy, fz), (tx, fy, tz)],
    }[face]


def default_uv(face, f, t):
    fx, fy, fz = f
    tx, ty, tz = t
    return {
        "down": (fx, 16 - tz, tx, 16 - fz),
        "up": (fx, fz, tx, tz),
        "north": (16 - tx, 16 - ty, 16 - fx, 16 - fy),
        "south": (fx, 16 - ty, tx, 16 - fy),
        "west": (fz, 16 - ty, tz, 16 - fy),
        "east": (16 - tz, 16 - ty, 16 - fz, 16 - fy),
    }[face]


def quads(root, item):
    definition = load(root, "items", item)
    textures, elements, gui, light = resolve(root, definition["model"]["model"])
    rot = (gui or {}).get("rotation", [0, 0, 0])
    tr = (gui or {}).get("translation", [0, 0, 0])
    sc = (gui or {}).get("scale", [1, 1, 1])
    d = math.pi / 180
    r = mm(mm(rx(rot[0] * d), ry(rot[1] * d)), rz(rot[2] * d))

    def place(p):
        q = [(p[0] - 0.5) * sc[0], (p[1] - 0.5) * sc[1], (p[2] - 0.5) * sc[2]]
        w = mv(r, q)
        return [w[0] + tr[0] / 16, w[1] + tr[1] / 16, w[2] + tr[2] / 16]

    l0, l1 = lights()
    shown = []
    for e in elements:
        f = [v for v in e["from"]]
        t = [v for v in e["to"]]
        for face in ("down", "up", "north", "south", "west", "east"):
            if face not in e["faces"]:
                continue
            spec = e["faces"][face]
            pts = [place([c / 16 for c in p]) for p in corners(face, f, t)]
            uv = spec.get("uv") or default_uv(face, f, t)
            cuv = [(uv[0], uv[1]), (uv[2], uv[1]), (uv[2], uv[3]), (uv[0], uv[3])]
            e1 = [pts[1][i] - pts[0][i] for i in range(3)]
            e2 = [pts[2][i] - pts[1][i] for i in range(3)]
            n = [-(e1[1] * e2[2] - e1[2] * e2[1]), -(e1[2] * e2[0] - e1[0] * e2[2]), -(e1[0] * e2[1] - e1[1] * e2[0])]
            if n[2] <= 0:
                continue
            n = norm(n)
            if light == "front":
                b = 1.0
            else:
                ng = [n[0], -n[1], n[2]]
                b = min(1.0, (max(0.0, sum(a * c for a, c in zip(ng, l0))) + max(0.0, sum(a * c for a, c in zip(ng, l1)))) * 0.6 + 0.4)
            z = sum(p[2] for p in pts)
            shown.append((z, face, texture(textures, spec["texture"]), b, [(8 + 16 * p[0], 8 - 16 * p[1]) for p in pts], cuv))
    shown.sort(key=lambda q: q[0])
    return shown


def num(v):
    return "%+07d" % round(v * 1000)


def main():
    root = sys.argv[1]
    for item in sys.argv[2:]:
        for z, face, tex, b, xy, uv in quads(root, item):
            row = "%-40s%05d" % (tex, round(b * 10000))
            row += "".join(num(p[0]) for p in xy) + "".join(num(p[1]) for p in xy)
            row += "".join(num(c[0]) for c in uv) + "".join(num(c[1]) for c in uv)
            print('%-18s %s   # %s' % (item, row, face))


if __name__ == "__main__":
    main()
