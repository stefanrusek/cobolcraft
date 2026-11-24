#!/usr/bin/env python3
"""Independent expected values of client/tests/test_hand_pickaxe.cob (T32301): the first-person wooden pickaxe at rest (12 sections 6.3 and 8.2, 08 section 5.7).

pose = translate(0.56, -0.52, -0.72) . translate(1.13, 3.2, 1.13)/16 . Rx(0) Ry(-90) Rz(25) . scale 0.68 . translate(-0.5); the generated model is a front quad at z 17/32
(south, corners top-left, top-right, bottom-right, bottom-left), a back quad at z 15/32 and, for each opaque texel with a clear (or outside) neighbour on a side, an
edge quad between the two z planes. Prints the view-space corners of the front quad, the number of quads and the number of quads that face the camera at the
origin (a quad faces it when its outward normal n, n . (centre - 0) < 0). Reads the texture of the standard resource pack given as argument 1."""
import math
import sys
import struct
import zlib


def read_png(path):
    """The opaque mask (alpha above 0) of a PNG of colour type 3 (palette with tRNS) or 6 (RGBA), bit depth 1, 2, 4 or 8."""
    data = open(path, "rb").read()
    pos = 8
    idat = b""
    trns = b""
    while pos < len(data):
        n = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + n]
        if kind == b"IHDR":
            w, h, depth, ctype = struct.unpack(">IIBB", body[:10])
        if kind == b"IDAT":
            idat += body
        if kind == b"tRNS":
            trns = body
        pos += 12 + n
    raw = zlib.decompress(idat)
    channels = {6: 4, 3: 1}[ctype]
    bpp = max(1, channels * depth // 8)
    stride = (w * channels * depth + 7) // 8
    rows = []
    prev = bytearray(stride)
    p = 0
    for _ in range(h):
        f = raw[p]
        line = bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            if f == 1:
                line[i] = (line[i] + a) & 255
            elif f == 2:
                line[i] = (line[i] + b) & 255
            elif f == 3:
                line[i] = (line[i] + (a + b) // 2) & 255
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 255
        rows.append(line)
        prev = line
    mask = []
    for y in range(h):
        out = []
        for x in range(w):
            if ctype == 6:
                out.append(rows[y][x * 4 + 3] > 0)
            else:
                bit = x * depth
                index = (rows[y][bit // 8] >> (8 - depth - bit % 8)) & ((1 << depth) - 1)
                out.append((trns[index] if index < len(trns) else 255) > 0)
        mask.append(out)
    return w, h, mask


def mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]


def tr(x, y, z):
    return [[1, 0, 0, x], [0, 1, 0, y], [0, 0, 1, z], [0, 0, 0, 1]]


def sc(x, y, z):
    return [[x, 0, 0, 0], [0, y, 0, 0], [0, 0, z, 0], [0, 0, 0, 1]]


def rot(axis, deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    if axis == "x":
        return [[1, 0, 0, 0], [0, c, -s, 0], [0, s, c, 0], [0, 0, 0, 1]]
    if axis == "y":
        return [[c, 0, s, 0], [0, 1, 0, 0], [-s, 0, c, 0], [0, 0, 0, 1]]
    return [[c, -s, 0, 0], [s, c, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]


w, h, op = read_png(sys.argv[1])
m = tr(0.56, -0.52, -0.72)
m = mul(m, tr(1.13 / 16, 3.2 / 16, 1.13 / 16))
m = mul(m, rot("x", 0))
m = mul(m, rot("y", -90))
m = mul(m, rot("z", 25))
m = mul(m, sc(0.68, 0.68, 0.68))
m = mul(m, tr(-0.5, -0.5, -0.5))


def pt(p):
    v = [p[0], p[1], p[2], 1]
    return [sum(m[i][k] * v[k] for k in range(4)) for i in range(3)]


def lin(n):
    return [sum(m[i][k] * n[k] for k in range(3)) for i in range(3)]


zf, zb = 17 / 32, 15 / 32
quads = [([(0, 1, zf), (1, 1, zf), (1, 0, zf), (0, 0, zf)], (0, 0, 1)), ([(1, 1, zb), (0, 1, zb), (0, 0, zb), (1, 0, zb)], (0, 0, -1))]
c = 1 / w
for py in range(h):
    for px in range(w):
        if not op[py][px]:
            continue
        x0, x1, y0, y1 = px * c, (px + 1) * c, 1 - (py + 1) * c, 1 - py * c
        for (dx, dy), pts, n in (((0, -1), [(x0, y1, zb), (x1, y1, zb), (x1, y1, zf), (x0, y1, zf)], (0, 1, 0)),
                                 ((0, 1), [(x0, y0, zb), (x1, y0, zb), (x1, y0, zf), (x0, y0, zf)], (0, -1, 0)),
                                 ((-1, 0), [(x0, y1, zb), (x0, y1, zf), (x0, y0, zf), (x0, y0, zb)], (-1, 0, 0)),
                                 ((1, 0), [(x1, y1, zb), (x1, y1, zf), (x1, y0, zf), (x1, y0, zb)], (1, 0, 0))):
            a, b = px + dx, py + dy
            if 0 <= a < w and 0 <= b < h and op[b][a]:
                continue
            quads.append((pts, n))
facing = 0
for pts, n in quads:
    centre = [sum(pt(p)[i] for p in pts) / 4 for i in range(3)]
    nv = lin(n)
    if sum(nv[i] * centre[i] for i in range(3)) < 0:
        facing += 1
front = [pt(p) for p in quads[0][0]]
print("front", " ".join("%.4f/%.4f/%.4f" % tuple(p) for p in front))
print("quads", len(quads), "facing", facing)
