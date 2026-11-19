#!/usr/bin/env python3
"""Independent expected values of client/tests/test_special_items.cob (lane bugbeitems, T42400 and on): the quads of the code-drawn item models
(docs/protocol/52 sections 3.5, 3.10, 4.2 to 4.5, 6.2, 6.4, 6.7 for the chest family, the shulker boxes and the banners; 31-4 section 4.4 for the bell).

Every part is a cuboid (origin, size, texture offset, pivot, texture size) unwrapped as 34-1 section 1.3 (corner letters A to H, the strip U0..U5 and V0..V2,
the face table of corners and rectangles, vertex 0 to 3 texture corners (maxU, minV), (minU, minV), (minU, maxV), (maxU, maxV)); a model with y up (the chest, the
bell: no flip between the model and the world) takes the letters with the two ends of y exchanged (52 open question 1, the implementer's finding), a model with y
down (the shulker box, the banner) the letters as they are. A model pixel (x, y, z) goes to T + S * (x, y, z) / 16 (T the translation, S the scale of the item
definition's transformation, 52 sections 4.5 and 6.7). Prints, per item kind, the number of quads, the corners and the texture coordinates (in texels of the
texture) of the quads named on the command line and the sums over all quads. Usage: gen_special_items.py [kind ...] with kind in chest, shulker, banner, bell."""
import math
import sys

FACES = [  # direction, corners (letters), minU, minV, maxU, maxV as indices into U0..U5 and V0..V2
    ("DOWN", "FEAB", 1, 0, 2, 1),
    ("UP", "CDHG", 2, 1, 3, 0),
    ("WEST", "AEHD", 0, 1, 1, 2),
    ("NORTH", "BADC", 1, 1, 2, 2),
    ("EAST", "FBCG", 2, 1, 4, 2),
    ("SOUTH", "EFGH", 4, 1, 5, 2),
]


def cuboid(o, size, tex, pivot, tsize, exchange, hide=(), grow=0.0, xrot=0.0):
    ox, oy, oz = o
    w, h, d = size
    u, v = tex
    px, py, pz = pivot
    U = [u, u + d, u + d + w, u + d + 2 * w, u + 2 * d + w, u + 2 * d + 2 * w]
    V = [v, v + d, v + d + h]
    x0, y0, z0 = ox - grow, oy - grow, oz - grow
    x1, y1, z1 = ox + w + grow, oy + h + grow, oz + d + grow
    ya, yb = (y0, y1) if not exchange else (y1, y0)
    corner = {
        "A": (x0, ya, z0), "B": (x1, ya, z0), "C": (x1, yb, z0), "D": (x0, yb, z0),
        "E": (x0, ya, z1), "F": (x1, ya, z1), "G": (x1, yb, z1), "H": (x0, yb, z1),
    }
    quads = []
    for name, letters, mnu, mnv, mxu, mxv in FACES:
        if name in hide:
            continue
        pts = []
        for L in letters:
            cx, cy, cz = corner[L]
            cx, cy, cz = cx + px, cy + py, cz + pz
            if xrot:
                dy, dz = cy - py, cz - pz
                cy = py + dy * math.cos(xrot) - dz * math.sin(xrot)
                cz = pz + dy * math.sin(xrot) + dz * math.cos(xrot)
            pts.append((cx, cy, cz))
        uv = [(U[mxu], V[mnv]), (U[mnu], V[mnv]), (U[mnu], V[mxv]), (U[mxu], V[mxv])]
        if not exchange:
            # the letters of a y-down model wind the other way once the model is turned into the world (a proper rotation): the vertices
            # 0, 3, 2, 1 (each with its own texture corner) are clockwise seen from outside, the winding of the terrain.
            pts = [pts[0], pts[3], pts[2], pts[1]]
            uv = [uv[0], uv[3], uv[2], uv[1]]
        quads.append((name, pts, uv, tsize))
    return quads


def place(quads, t, s, slot=1, tint=None):
    out = []
    for name, pts, uv, tsize in quads:
        pp = [(t[0] + s[0] * x / 16, t[1] + s[1] * y / 16, t[2] + s[2] * z / 16) for x, y, z in pts]
        out.append((name, pp, uv, tsize, slot, tint))
    return out


def chest():
    q = []
    q += cuboid((1, 0, 1), (14, 10, 14), (0, 19), (0, 0, 0), 64, True, hide=("DOWN",))
    q += cuboid((1, 0, 0), (14, 5, 14), (0, 0), (0, 9, 1), 64, True, hide=("UP",))
    q += cuboid((7, -2, 14), (2, 4, 1), (0, 0), (0, 9, 1), 64, True)
    return place(q, (0, 0, 0), (1, 1, 1))


def shulker():
    q = []
    q += cuboid((-8, -16, -8), (16, 12, 16), (0, 0), (0, 24, 0), 64, False, hide=("UP",))
    q += cuboid((-8, -8, -8), (16, 8, 16), (0, 28), (0, 24, 0), 64, False, hide=("DOWN",))
    return place(q, (0.5, 1.4995, 0.5), (0.9995, -0.9995, -0.9995))


def banner():
    q = []
    q += place(cuboid((-1, -42, -1), (2, 42, 2), (44, 0), (0, 0, 0), 64, False), (0.5, 0, 0.5), (2 / 3, -2 / 3, -2 / 3))
    q += place(cuboid((-10, -44, -1), (20, 2, 2), (0, 42), (0, 0, 0), 64, False), (0.5, 0, 0.5), (2 / 3, -2 / 3, -2 / 3))
    flag = math.radians(-0.45)
    q += place(cuboid((-10, 0, -2), (20, 40, 1), (0, 0), (0, -44, 0), 64, False, xrot=flag), (0.5, 0, 0.5), (2 / 3, -2 / 3, -2 / 3))
    q += place(cuboid((-10, 0, -2), (20, 40, 1), (0, 0), (0, -44, 0), 64, False, grow=0.05, xrot=flag), (0.5, 0, 0.5),
               (2 / 3, -2 / 3, -2 / 3), slot=2, tint=True)
    return q


def bell():
    q = []
    q += cuboid((-3, -6, -3), (6, 7, 6), (0, 0), (8, 12, 8), 32, True)
    q += cuboid((4, 4, 4), (8, 2, 8), (0, 13), (0, 0, 0), 32, True)
    return place(q, (0, 0, 0), (1, 1, 1))


def show(name, quads, want):
    print(name, "quads", len(quads))
    sums = [0.0] * 5
    for i, (face, pts, uv, tsize, slot, tint) in enumerate(quads):
        for (x, y, z), (u, v) in zip(pts, uv):
            sums[0] += x
            sums[1] += y
            sums[2] += z
            sums[3] += u / tsize
            sums[4] += v / tsize
        if i + 1 in want:
            print(" quad", i + 1, face, "slot", slot, "tint", tint)
            for (x, y, z), (u, v) in zip(pts, uv):
                print("   %.5f %.5f %.5f  u %.5f v %.5f" % (x, y, z, u / tsize, v / tsize))
    print(" sums x %.4f y %.4f z %.4f u %.4f v %.4f" % tuple(sums))


DISPLAY = {  # kind -> context -> (rotation, translation in sixteenths, scale); 52 sections 3.10, 4.5 and 6.7
    "chest": {"gui": ((30, 45, 0), (0, 0, 0), 0.625), "ground": ((0, 0, 0), (0, 3, 0), 0.25), "hand": ((0, 315, 0), (0, 0, 0), 0.4)},
    "shulker": {"gui": ((30, 45, 0), (0, 0, 0), 0.625), "ground": ((0, 0, 0), (0, 3, 0), 0.25), "hand": ((0, 315, 0), (0, 0, 0), 0.4)},
    "banner": {"gui": ((30, 20, 0), (0, -3.25, 0), 0.5325), "ground": ((0, 0, 0), (0, 1, 0), 0.25), "hand": ((0, 90, 0), (0, 0, 0), 0.375)},
}


def mat_mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]


def display_matrix(rot, tr, sc):
    """ItemTransform.apply: translate(t / 16) rotationXYZ(rx, ry, rz) scale(s) translate(-0.5): returns (A, t) with p' = A p + t."""
    rx, ry, rz = [math.radians(a) for a in rot]
    cx, sx, cy, sy, cz, sz = math.cos(rx), math.sin(rx), math.cos(ry), math.sin(ry), math.cos(rz), math.sin(rz)
    rxm = [[1, 0, 0], [0, cx, -sx], [0, sx, cx]]
    rym = [[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]]
    rzm = [[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]]
    a = mat_mul(mat_mul(rxm, rym), rzm)
    a = [[v * sc for v in row] for row in a]
    t = [tr[i] / 16 - sum(a[i][k] * 0.5 for k in range(3)) for i in range(3)]
    return a, t


def transformed(quads, kind, ctx, extra=(0, 0, 0)):
    a, t = display_matrix(*DISPLAY[kind][ctx])
    out = []
    for name, pts, uv, tsize, slot, tint in quads:
        pp = [tuple(sum(a[i][k] * p[k] for k in range(3)) + t[i] + extra[i] for i in range(3)) for p in pts]
        out.append((name, pp, uv, tsize, slot, tint))
    return out


def cross(pts):
    e1 = [pts[1][i] - pts[0][i] for i in range(3)]
    e2 = [pts[2][i] - pts[1][i] for i in range(3)]
    return [e1[1] * e2[2] - e1[2] * e2[1], e1[2] * e2[0] - e1[0] * e2[2], e1[0] * e2[1] - e1[1] * e2[0]]


def gui_visible(kind):
    """Quads facing the viewer (cross.z < 0, the view along -z) with the gui display, and the screen box of a 16 pixel cell at (0, 0): x 8 + 16 p.x, y 8 - 16 p.y."""
    quads = transformed({"chest": chest, "shulker": shulker, "banner": banner}[kind](), kind, "gui")
    vis = [i + 1 for i, q in enumerate(quads) if cross(q[1])[2] < 0]
    xs = [8 + 16 * p[0] for i in vis for p in quads[i - 1][1]]
    ys = [8 - 16 * p[1] for i in vis for p in quads[i - 1][1]]
    return vis, (min(xs), min(ys), max(xs), max(ys))


def hand_visible(kind, offset=(0, 0, -1.5)):
    """Quads facing an eye at the origin with the firstperson display and the model moved by offset: cross . c1 > 0; the sum of their corner coordinates."""
    quads = transformed({"chest": chest, "shulker": shulker, "banner": banner}[kind](), kind, "hand", offset)
    vis = []
    for i, q in enumerate(quads):
        c = cross(q[1])
        if sum(c[k] * q[1][0][k] for k in range(3)) > 0:
            vis.append(i + 1)
    sums = [sum(p[k] for i in vis for p in quads[i - 1][1]) for k in range(3)]
    return vis, sums


if __name__ == "__main__":
    kinds = sys.argv[1:] or ["chest", "shulker", "banner", "bell"]
    for k in kinds:
        if k in DISPLAY:
            print(k, "gui visible", *gui_visible(k))
            print(k, "hand visible", *hand_visible(k))
        show(k, {"chest": chest, "shulker": shulker, "banner": banner, "bell": bell}[k](), range(1, 40))
