#!/usr/bin/env python3
"""Independent expected values of client/tests/test_hand_doc.cob and test_hand_pickaxe.cob (T32900 ff.): the first-person wooden pickaxe at rest, 12 sections 6.7 to 6.10, V21.

Everything is computed from the texture (argument 1: textures/item/wooden_pickaxe.png of the generated vanilla pack) and the formulas of the document only:
  M = A . D with A = translate(0.56, -0.52, -0.72) and D = translate(1.13, 3.2, 1.13)/16 . Rx(0) Ry(-90) Rz(25) . scale 0.68 . translate(-0.5)  (6.3, 6.7.3, 8.2)
  mesh (6.8): front quad z 8.5 px, back quad z 7.5 px (u grows with +x on both), one wall per exposed edge of an opaque texel, uv inside the pixel (0.1 .. 0.9)
  projection (6.9): vertical fov 70, aspect 16:9, near 0.05; ndc = (0.803333 x / -z, 1.428148 y / -z); a quad is drawn when its counter-clockwise (y up) ndc area is positive.
Prints: quads and drawn quads by kind, the window fractions of the front quad's corners, the number of opaque texel centres on screen and their bounding box, and the first three
drawn walls in the order the client emits them (rows top to bottom, columns left to right, sides up, down, west, east) with the uv of their first vertex.
With --raster FILE.ppm the picture is rasterised (flat colour per quad: the texel colour times the front-face shade 0.497) at 480 x 270 for a look."""
import math
import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    pos = 8
    idat = b""
    trns = b""
    plte = b""
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
        if kind == b"PLTE":
            plte = body
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
    img = []
    for y in range(h):
        out = []
        for x in range(w):
            if ctype == 6:
                out.append(tuple(rows[y][x * 4:x * 4 + 4]))
            else:
                bit = x * depth
                index = (rows[y][bit // 8] >> (8 - depth - bit % 8)) & ((1 << depth) - 1)
                out.append((plte[index * 3], plte[index * 3 + 1], plte[index * 3 + 2], trns[index] if index < len(trns) else 255))
        img.append(out)
    return w, h, img


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


w, h, img = read_png(sys.argv[1])
op = [[img[y][x][3] > 0 for x in range(w)] for y in range(h)]
m = mul(tr(0.56, -0.52, -0.72), tr(1.13 / 16, 3.2 / 16, 1.13 / 16))
for part in (rot("x", 0), rot("y", -90), rot("z", 25), sc(0.68, 0.68, 0.68), tr(-0.5, -0.5, -0.5)):
    m = mul(m, part)
F = 1 / math.tan(math.radians(35))
ASPECT = 16 / 9


def view(p):
    v = [p[0], p[1], p[2], 1]
    return [sum(m[i][k] * v[k] for k in range(4)) for i in range(3)]


def ndc(p):
    return (F / ASPECT * p[0] / -p[2], F * p[1] / -p[2])


def frac(n):
    return ((n[0] + 1) / 2, (1 - n[1]) / 2)


def area(pts):
    """Signed ndc area, positive counter-clockwise with y up."""
    s = 0
    for i in range(len(pts)):
        x0, y0 = pts[i]
        x1, y1 = pts[(i + 1) % len(pts)]
        s += x0 * y1 - x1 * y0
    return s / 2


zn, zf = 7.5 / 16, 8.5 / 16
c = 1.0 / w
quads = []  # (kind, doc-order corners (model units), uv list in sprite fractions, pixel)
quads.append(("front", [(0, 1, zf), (0, 0, zf), (1, 0, zf), (1, 1, zf)], [(0, 0), (0, 1), (1, 1), (1, 0)], None))
quads.append(("back", [(1, 1, zn), (1, 0, zn), (0, 0, zn), (0, 1, zn)], [(1, 0), (1, 1), (0, 1), (0, 0)], None))
walls = []
for py in range(h):
    for px in range(w):
        if not op[py][px]:
            continue
        x0, x1, y0, y1 = px * c, (px + 1) * c, 1 - (py + 1) * c, 1 - py * c
        a, b = px + 0.1, px + 0.9
        t, u = py + 0.1, py + 0.9
        for kind, dx, dy, cs, uv in (
            ("up", 0, -1, [(x0, y1, zn), (x0, y1, zf), (x1, y1, zf), (x1, y1, zn)], [(a, t), (a, u), (b, u), (b, t)]),
            ("down", 0, 1, [(x0, y0, zf), (x0, y0, zn), (x1, y0, zn), (x1, y0, zf)], [(a, t), (a, u), (b, u), (b, t)]),
            ("west", -1, 0, [(x0, y1, zn), (x0, y0, zn), (x0, y0, zf), (x0, y1, zf)], [(b, t), (b, u), (a, u), (a, t)]),
            ("east", 1, 0, [(x1, y1, zf), (x1, y0, zf), (x1, y0, zn), (x1, y1, zn)], [(b, t), (b, u), (a, u), (a, t)]),
        ):
            nx, ny = px + dx, py + dy
            if 0 <= nx < w and 0 <= ny < h and op[ny][nx]:
                continue
            quads.append((kind, cs, [(p[0] / w, p[1] / h) for p in uv], (px, py)))
counts = {}
drawn = {}
drawn_walls = []
for kind, cs, uv, pix in quads:
    counts[kind] = counts.get(kind, 0) + 1
    pts = [view(p) for p in cs]
    if area([ndc(p) for p in pts]) > 0:
        drawn[kind] = drawn.get(kind, 0) + 1
        if pix is not None:
            drawn_walls.append((kind, pix, uv))
print("quads", len(quads), sorted(counts.items()))
print("drawn", sum(drawn.values()), sorted(drawn.items()))
front = [view(p) for p in quads[0][1]]
for name, p in zip(("v0 top-left", "v1 bottom-left", "v2 bottom-right", "v3 top-right"), front):
    n = ndc(p)
    f = frac(n)
    print("front", name, "view %.5f %.5f %.5f" % tuple(p), "ndc %.5f %.5f" % n, "frac %.4f %.4f" % f)
inside = 0
fx, fy, gx, gy = [], [], [], []
for py in range(h):
    for px in range(w):
        if not op[py][px]:
            continue
        p = view(((px + 0.5) * c, 1 - (py + 0.5) * c, zf))
        f = frac(ndc(p))
        fx.append(f[0])
        fy.append(f[1])
        if 0 <= f[0] <= 1 and 0 <= f[1] <= 1:
            inside += 1
        for cx in (px, px + 1):
            for cy in (py, py + 1):
                g = frac(ndc(view((cx * c, 1 - cy * c, zf))))
                gx.append(g[0])
                gy.append(g[1])
print("opaque", len(fx), "inside", inside, "bbox fx %.4f %.4f fy %.4f %.4f" % (min(fx), max(fx), min(fy), max(fy)))
print("texel corners bbox fx %.4f %.4f fy %.4f %.4f" % (min(gx), max(gx), min(gy), max(gy)))
print("on screen: right %.1f%% of the width, lower %.1f%% of the height" % (100 * (1 - min(max(min(gx), 0), 1)), 100 * (1 - min(max(min(gy), 0), 1))))
# the client's emission order: pixel rows, columns, sides up down west east (quads[] is already in that order)
for kind, pix, uv in drawn_walls[:3]:
    print("wall", kind, "pixel", pix, "first uv %.5f %.5f" % uv[0], "second uv %.5f %.5f" % uv[1])
if "--raster" in sys.argv:
    out = sys.argv[sys.argv.index("--raster") + 1]
    W, H = 480, 270
    pix = [[(90, 140, 70)] * W for _ in range(H)]
    shade = {"front": 0.497, "back": 0.497, "up": 1.0, "down": 0.4, "west": 0.5027, "east": 0.9127}
    depth = [[1e9] * W for _ in range(H)]
    for kind, cs, uv, px in quads:
        pts = [view(p) for p in cs]
        nd = [ndc(p) for p in pts]
        if area(nd) <= 0:
            continue
        sp = [((n[0] + 1) / 2 * W, (1 - n[1]) / 2 * H) for n in nd]
        for tri in ((0, 1, 2), (0, 2, 3)):
            a, b, cc = [sp[i] for i in tri]
            za, zb, zc = [-pts[i][2] for i in tri]
            ua, ub, uc = [uv[i] for i in tri]
            den = (b[1] - cc[1]) * (a[0] - cc[0]) + (cc[0] - b[0]) * (a[1] - cc[1])
            if abs(den) < 1e-12:
                continue
            for y in range(max(0, int(min(a[1], b[1], cc[1]))), min(H, int(max(a[1], b[1], cc[1])) + 1)):
                for x in range(max(0, int(min(a[0], b[0], cc[0]))), min(W, int(max(a[0], b[0], cc[0])) + 1)):
                    l1 = ((b[1] - cc[1]) * (x + 0.5 - cc[0]) + (cc[0] - b[0]) * (y + 0.5 - cc[1])) / den
                    l2 = ((cc[1] - a[1]) * (x + 0.5 - cc[0]) + (a[0] - cc[0]) * (y + 0.5 - cc[1])) / den
                    l3 = 1 - l1 - l2
                    if l1 < 0 or l2 < 0 or l3 < 0:
                        continue
                    # perspective-correct depth and uv
                    iw = l1 / za + l2 / zb + l3 / zc
                    z = 1 / iw
                    u = (l1 * ua[0] / za + l2 * ub[0] / zb + l3 * uc[0] / zc) * z
                    v = (l1 * ua[1] / za + l2 * ub[1] / zb + l3 * uc[1] / zc) * z
                    tx, ty = min(w - 1, max(0, int(u * w))), min(h - 1, max(0, int(v * h)))
                    texel = img[ty][tx]
                    if texel[3] < 26 or z >= depth[y][x]:
                        continue
                    depth[y][x] = z
                    s = shade[kind]
                    pix[y][x] = (int(texel[0] * s), int(texel[1] * s), int(texel[2] * s))
    with open(out, "w") as f:
        f.write("P3\n%d %d\n255\n" % (W, H))
        for row in pix:
            f.write(" ".join("%d %d %d" % p for p in row) + "\n")
