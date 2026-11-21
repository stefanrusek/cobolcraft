#!/usr/bin/env python3
"""Independent model of the start of the ruined portal (docs/protocol/36-structures-4 section 8.2 and 8.3) for core/tests/test_struct_portal.cob (prints the expected values the test embeds).
A Java LCG (10 section 2.6), setLargeFeatureSeed (36-4 2.1), the setups of the structure files, the template sizes of the generated vanilla-data and the synthetic terrain of
core/tests/fixtures/gen_jigsaw.py (the first free height of a column is 68 + ((x div 4 + z div 4) mod 5), the same for both heightmaps).
usage: gen_portal.py GENERATED_DIR [SEED]"""
import json, os, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_jigsaw import Lcg, start_random, read_nbt, rotate, surface as surface1

def surface(x, z, mode=1): return {1: surface1(x, z), 2: -40, 3: 200}[mode]

def f32(v): return struct.unpack(">f", struct.pack(">f", v))[0]
PLACEMENTS = ["on_land_surface", "partly_buried", "on_ocean_floor", "in_mountain", "underground", "in_nether"]

def setups(gen, name):
    j = json.load(open(os.path.join(gen, "vanilla-data/data/minecraft/worldgen/structure", name + ".json")))
    return j["setups"]

def template_size(gen, name):
    return tuple(read_nbt(os.path.join(gen, "vanilla-data/data/minecraft/structure/ruined_portal", name + ".nbt"))["size"])

def rbi(r, lo, hi): return lo if lo >= hi else r.next_int(hi - lo + 1) + lo

def mirror_rotate(x, z, mirror, rot, px, pz):
    if mirror == 2: x = -x          # FRONT_BACK: x -> -x (36-2 3.1)
    if mirror == 1: z = -z
    if rot == 0: return x, z
    if rot == 1: return px + pz - z, pz - px + x
    if rot == 2: return 2 * px - x, 2 * pz - z
    return px - pz + z, px + pz - x

def start(gen, name, seed, cx, cz, mode=1):
    r = start_random(seed, cx, cz)
    ss = setups(gen, name)
    if len(ss) == 1: S = ss[0]
    else:
        total = f32(sum(f32(s["weight"]) for s in ss))
        x = f32(r.next_float()); S = ss[-1]
        for s in ss:
            x = f32(x - f32(f32(s["weight"]) / total))
            if x < 0: S = s; break
    p = f32(S["air_pocket_probability"])
    air = False if p <= 0 else (True if p >= 1 else r.next_float() < p)
    if r.next_float() < f32(0.05): tpl = "giant_portal_%d" % (r.next_int(3) + 1)
    else: tpl = "portal_%d" % (r.next_int(10) + 1)
    rot = r.next_int(4)
    mirror = 0 if r.next_float() < 0.5 else 2
    sx, sy, sz = template_size(gen, tpl)
    px, pz = sx // 2, sz // 2
    c0 = mirror_rotate(0, 0, mirror, rot, px, pz); c1 = mirror_rotate(sx - 1, sz - 1, mirror, rot, px, pz)
    ox, oz = cx * 16, cz * 16
    bx0, bx1 = min(c0[0], c1[0]) + ox, max(c0[0], c1[0]) + ox
    bz0, bz1 = min(c0[1], c1[1]) + oz, max(c0[1], c1[1]) + oz
    by0, by1 = 0, sy - 1
    ccx, ccz = bx0 + (bx1 - bx0 + 1) // 2, bz0 + (bz1 - bz0 + 1) // 2
    pl = S["placement"]
    surf = surface(ccx, ccz, mode) - 1
    span = sy
    min_y = 0 if pl == "in_nether" else -64
    limit = min_y + 15
    if pl == "in_nether":
        if air: y = rbi(r, 32, 100)
        else: y = rbi(r, 27, 29) if r.next_float() < 0.5 else rbi(r, 29, 100)
    elif pl == "in_mountain": v = surf - span; y = rbi(r, 70, v) if 70 < v else v
    elif pl == "underground": v = surf - span; y = rbi(r, limit, v) if limit < v else v
    elif pl == "partly_buried": y = (surf - span) + rbi(r, 2, 8)
    else: y = surf
    corners = [(bx0, bz0), (bx1, bz0), (bx0, bz1), (bx1, bz1)]
    while y > limit:
        count = sum(1 for (x, z) in corners if y < surface(x, z, mode))   # a block at y of the synthetic column: solid under the first free height
        if count >= 3: break   # the loop counts the columns one by one and stops at the third that passes (4 passing also stops)
        y -= 1
    return dict(setup=ss.index(S), air=int(air), tpl=tpl, rot=rot, mirror=mirror, pivot=(px, pz), y=y, pos=(ox, y, oz), box=(bx0, bz0, bx1, bz1), surf=surf)

CASES = [("ruined_portal", 0, 0, 1), ("ruined_portal", 5, 5, 1), ("ruined_portal", -7, 3, 1), ("ruined_portal", 11, -4, 1), ("ruined_portal", 2, 9, 1), ("ruined_portal", -3, -8, 1),
         ("ruined_portal_desert", 3, 3, 1), ("ruined_portal_desert", -6, 1, 1), ("ruined_portal_jungle", 4, -2, 1), ("ruined_portal_swamp", -1, 6, 1),
         ("ruined_portal_mountain", 8, 8, 1), ("ruined_portal_mountain", -5, -5, 1), ("ruined_portal_mountain", 1, 12, 1), ("ruined_portal_ocean", 7, -3, 1), ("ruined_portal_nether", 2, 2, 1), ("ruined_portal_nether", -9, 4, 1),
         ("ruined_portal", 5, 5, 2), ("ruined_portal", -7, 3, 2), ("ruined_portal_mountain", 8, 8, 3), ("ruined_portal_mountain", 1, 12, 3), ("ruined_portal_mountain", -5, -5, 2),
         ("ruined_portal_desert", 3, 3, 3), ("ruined_portal_swamp", -1, 6, 3), ("ruined_portal_swamp", -1, 6, 2)]

if __name__ == "__main__":
    gen = sys.argv[1]; seed = int(sys.argv[2]) if len(sys.argv) > 2 else 12345
    for name, cx, cz, mode in CASES:
        print(name, cx, cz, mode, start(gen, name, seed, cx, cz, mode))
