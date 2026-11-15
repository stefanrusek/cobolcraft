#!/usr/bin/env python3
"""Independent model of the jigsaw assembly (docs/protocol/36-structures-3 sections 4 to 14, 36-9) for core/tests/test_struct_jigsaw.cob (prints the expected pieces the test embeds).
A Java LCG (10 section 2.6), setLargeFeatureSeed (36-4 2.1), the template pools and structure files of the generated vanilla-data (JSON), the templates (gzip NBT: size and jigsaw
blocks only) and the assembler of 36-3 (start piece, free volumes as a limit box minus a list of removed boxes, the queue, candidates, rotations, the expansion hack, junctions).
The terrain is synthetic: the first free height of a column is SURFACE(x, z) (the test sets the same function in the core through JIG-TEST-SURFACE).
usage: gen_jigsaw.py GENERATED_DIR STRUCTURE SEED CX CZ"""
import gzip, json, os, struct, sys

M48 = (1 << 48) - 1
def s64(v): v &= (1 << 64) - 1; return v - (1 << 64) if v >= 1 << 63 else v

class Lcg:
    def __init__(self, seed): self.s = (seed ^ 0x5DEECE66D) & M48
    def next(self, bits):
        self.s = (self.s * 0x5DEECE66D + 0xB) & M48
        v = self.s >> (48 - bits)
        return v - (1 << bits) if bits == 32 and v >= 1 << 31 else v
    def next_int(self, bound):
        if bound & (bound - 1) == 0: return (bound * self.next(31)) >> 31
        while True:
            bits = self.next(31); v = bits % bound
            if bits - v + (bound - 1) < (1 << 31): return v
    def next_long(self): return s64((self.next(32) << 32) + self.next(32))
    def next_float(self): return self.next(24) / 16777216.0
    def shuffle(self, lst):
        for i in range(len(lst), 1, -1):
            j = self.next_int(i); lst[i - 1], lst[j] = lst[j], lst[i - 1]

def start_random(seed, cx, cz):
    r = Lcg(seed); a = r.next_long(); b = r.next_long()
    r.s = ((s64(cx * a) ^ s64(cz * b) ^ seed) ^ 0x5DEECE66D) & M48
    return r

def surface(x, z): return 68 + ((x // 4) + (z // 4)) % 5

ROTS = [0, 1, 2, 3]
# directions: 0 down 1 up 2 north 3 south 4 west 5 east
STEP = {0: (0, -1, 0), 1: (0, 1, 0), 2: (0, 0, -1), 3: (0, 0, 1), 4: (-1, 0, 0), 5: (1, 0, 0)}
NAMES = {"down": 0, "up": 1, "north": 2, "south": 3, "west": 4, "east": 5}
OPP = {0: 1, 1: 0, 2: 3, 3: 2, 4: 5, 5: 4}
def rot_dir(d, rot):
    if d < 2: return d
    cyc = [2, 5, 3, 4]  # north east south west: clockwise 90 turns north into east
    return cyc[(cyc.index(d) + rot) % 4]
def rotate(x, z, rot): return [(x, z), (-z, x), (-x, -z), (z, -x)][rot]

def read_nbt(path):
    data = gzip.open(path).read(); pos = [0]
    def u(fmt):
        n = struct.calcsize(fmt); v = struct.unpack_from(fmt, data, pos[0])[0]; pos[0] += n; return v
    def string():
        n = u(">H"); s = data[pos[0]:pos[0] + n].decode("utf-8", "replace"); pos[0] += n; return s
    def payload(t):
        if t == 1: return u(">b")
        if t == 2: return u(">h")
        if t == 3: return u(">i")
        if t == 4: return u(">q")
        if t == 5: return u(">f")
        if t == 6: return u(">d")
        if t == 7: n = u(">i"); pos[0] += n; return None
        if t == 8: return string()
        if t == 9:
            et = u(">b"); n = u(">i"); return [payload(et) for _ in range(n)]
        if t == 10:
            d = {}
            while True:
                tt = u(">b")
                if tt == 0: return d
                nm = string(); d[nm] = payload(tt)
        if t == 11: n = u(">i"); return [u(">i") for _ in range(n)]
        if t == 12: n = u(">i"); return [u(">q") for _ in range(n)]
    assert u(">b") == 10; string(); return payload(10)

class World:
    def __init__(self, gen):
        self.gen = os.path.join(gen, "vanilla-data/data/minecraft")
        self.here = os.path.dirname(os.path.abspath(__file__))
        self.pools = {}; self.tpls = {}
    def key(self, k): return k if k.startswith("test:") else k.split(":", 1)[-1]
    def path(self, k, kind, ext):
        """the file of a key: the namespace test is the fixtures of core/tests (jigpool, tpl), any other the generated vanilla-data"""
        if k.startswith("test:"):
            if kind == "structure": return os.path.join(self.here, "tpl/data/test/structure", k[5:] + ext)
            return os.path.join(self.here, "jigpool/data/test/worldgen", kind, k[5:] + ext)
        if kind == "structure": return os.path.join(self.gen, "structure", k + ext)
        return os.path.join(self.gen, "worldgen", kind, k + ext)
    def template(self, loc):
        k = self.key(loc)
        if k not in self.tpls:
            t = read_nbt(self.path(k, "structure", ".nbt"))
            pal = (t["palettes"][0] if "palettes" in t else t["palette"])
            jig = []
            for b in t["blocks"]:
                st = pal[b["state"]]
                if st["id"] == "minecraft:jigsaw" and "nbt" in b:
                    n = b["nbt"]
                    ori = st["properties"]["orientation"]
                    front, top = ori.split("_")
                    fr, tp = NAMES[front], NAMES[top]
                    joint = n.get("joint")
                    if joint is None: joint = "aligned" if fr >= 2 else "rollable"
                    jig.append(dict(pos=tuple(b["pos"]), front=fr, top=tp, joint=joint, name=n.get("name", "minecraft:empty"), pool=n.get("pool", "minecraft:empty"),
                                    target=n.get("target", "minecraft:empty"), place=n.get("placement_priority", 0), select=n.get("selection_priority", 0)))
            jig.sort(key=lambda j: (j["pos"][1], j["pos"][0], j["pos"][2]))
            self.tpls[k] = (tuple(t["size"]), jig)
        return self.tpls[k]
    def pool(self, key):
        k = self.key(key)
        if k not in self.pools:
            j = json.load(open(self.path(k, "template_pool", ".json")))
            elems = []
            for e in j["elements"]: elems.append((self.element(e["element"]), e["weight"]))
            fb = j["fallback"]
            expanded = [e for e, w in elems for _ in range(w)]
            self.pools[k] = dict(key=k, expanded=expanded, fallback=fb, max=None)
        return self.pools[k]
    def element(self, e):
        t = e["element_type"].split(":")[1]
        if t in ("single_pool_element", "legacy_single_pool_element"):
            return dict(kind="single", legacy=t.startswith("legacy"), loc=e["location"], proj=e["projection"], procs=e["processors"])
        if t == "list_pool_element":
            subs = [self.element(s) for s in e["elements"]]
            for s in subs: s["proj"] = e["projection"]
            return dict(kind="list", subs=subs, proj=e["projection"])
        if t == "feature_pool_element": return dict(kind="feature", feature=e["feature"], proj=e["projection"])
        return dict(kind="empty", proj="terrain_matching")
    def max_size(self, key):
        p = self.pool(key)
        if p["max"] is None:
            best = 0
            for e in p["expanded"]:
                if e["kind"] == "empty": continue
                b = self.box(e, (0, 0, 0), 0)
                best = max(best, b[4] - b[1] + 1)
            p["max"] = best
        return p["max"]
    def box(self, e, pos, rot):
        k = e["kind"]
        if k == "single":
            (sx, sy, sz), _ = self.template(e["loc"])
            x0, z0 = rotate(0, 0, rot); x1, z1 = rotate(sx - 1, sz - 1, rot)
            return (min(x0, x1) + pos[0], pos[1], min(z0, z1) + pos[2], max(x0, x1) + pos[0], pos[1] + sy - 1, max(z0, z1) + pos[2]) if False else \
                   (min(x0, x1) + pos[0], pos[1], min(z0, z1) + pos[2], max(x0, x1) + pos[0], pos[1] + sy - 1, max(z0, z1) + pos[2])
        if k == "list":
            bs = [self.box(s, pos, rot) for s in e["subs"] if s["kind"] != "empty"]
            return (min(b[0] for b in bs), min(b[1] for b in bs), min(b[2] for b in bs), max(b[3] for b in bs), max(b[4] for b in bs), max(b[5] for b in bs))
        if k == "feature": return (pos[0], pos[1], pos[2], pos[0], pos[1], pos[2])
        raise ValueError("empty element has no box")
    def jigsaws(self, e, pos, rot, r):
        k = e["kind"]
        if k == "feature":
            return [dict(pos=tuple(pos), front=0, top=3, joint="rollable", name=None, pool="minecraft:empty", target="minecraft:empty", place=0, select=0)]
        if k == "empty": return []
        if k == "list": return self.jigsaws(e["subs"][0], pos, rot, r)
        _, jig = self.template(e["loc"])
        out = []
        for j in jig:
            x, z = rotate(j["pos"][0], j["pos"][2], rot)
            d = dict(j); d["pos"] = (x + pos[0], j["pos"][1] + pos[1], z + pos[2]); d["front"] = rot_dir(j["front"], rot); d["top"] = rot_dir(j["top"], rot)
            out.append(d)
        r.shuffle(out)
        out.sort(key=lambda j: -j["select"])
        return out

def can_attach(a, b):
    if a["front"] != OPP[b["front"]]: return False
    if a["joint"] != "rollable" and a["top"] != b["top"]: return False
    return b["name"] is None or a["target"] == b["name"]

def inside(b, p): return b[0] <= p[0] <= b[3] and b[1] <= p[1] <= b[4] and b[2] <= p[2] <= b[5]
def meets(a, b): return a[0] <= b[3] and a[3] >= b[0] and a[1] <= b[4] and a[4] >= b[1] and a[2] <= b[5] and a[5] >= b[2]
def moved(b, dy): return (b[0], b[1] + dy, b[2], b[3], b[4] + dy, b[5])
def inside_box(inner, outer): return all(outer[i] <= inner[i] for i in range(3)) and all(inner[i] <= outer[i] for i in range(3, 6))

def tdiv(a, b): return int(a / b)

def assemble(w, gen_struct, seed, cx, cz):
    st = gen_struct
    r = start_random(seed, cx, cz)
    pos = (cx * 16, st["start_height"], cz * 16)
    rotation = r.next_int(4)
    pool = w.pool(st["start_pool"])
    if not pool["expanded"]: return None
    el = pool["expanded"][r.next_int(len(pool["expanded"]))]
    if el["kind"] == "empty": return None
    box = w.box(el, pos, rotation)
    ccx, ccz = tdiv(box[3] + box[0], 2), tdiv(box[5] + box[2], 2)
    y = pos[1] + surface(ccx, ccz) if st["project"] else pos[1]
    gy = box[1] + 1
    start = dict(el=el, pos=(pos[0], pos[1] + y - gy, pos[2]), rot=rotation, box=moved(box, y - gy), ground=1, junctions=[], depth=0)
    stub_y = y
    pieces = [start]
    events = []   # the junctions in creation order: (owner piece index, x, ground y, z, delta, projection)
    start['events'] = events
    if st["size"] <= 0: return pieces
    hor, ver = st["hor"], st["ver"]
    limit = (ccx - hor, max(stub_y - ver, -64), ccz - hor, ccx + hor, min(stub_y + ver, 319), ccz + hor)
    holder0 = dict(limit=limit, removed=[start["box"]])
    queue = []   # (priority, seq, piece, holder, depth)
    seq = [0]
    def place_children(parent, holder, depth):
        y0 = parent["box"][1]
        parent_rigid = parent["el"]["proj"] == "rigid"
        own = [None]
        for J in w.jigsaws(parent["el"], parent["pos"], parent["rot"], r):
            f = J["front"]; p = J["pos"]; t = (p[0] + STEP[f][0], p[1] + STEP[f][1], p[2] + STEP[f][2])
            rel = p[1] - y0
            surf = [None]
            pk = J["pool"]
            try: pl = w.pool(pk)
            except FileNotFoundError: continue          # 10.2 step 1: no such pool
            if not pl["expanded"] and pl["key"] != "empty": continue   # step 2
            fbp = w.pool(pl["fallback"])
            if not fbp["expanded"] and fbp["key"] != "empty": continue  # step 3
            if inside(parent["box"], t):
                if own[0] is None: own[0] = dict(limit=parent["box"], removed=[])
                F = own[0]
            else: F = holder
            cands = []
            if depth != st["size"]:
                c = list(pl["expanded"]); r.shuffle(c); cands += c
            c = list(fbp["expanded"]); r.shuffle(c); cands += c
            prio = J["place"]
            placed = False
            for C in cands:
                if C["kind"] == "empty": break
                rots = list(ROTS); r.shuffle(rots)
                for rot in rots:
                    jigs = w.jigsaws(C, (0, 0, 0), rot, r)
                    box0 = w.box(C, (0, 0, 0), rot)
                    h = 0
                    if st["hack"] and box0[4] - box0[1] + 1 <= 16:
                        for K in jigs:
                            fc = (K["pos"][0] + STEP[K["front"]][0], K["pos"][1] + STEP[K["front"]][1], K["pos"][2] + STEP[K["front"]][2])
                            if inside(box0, fc):
                                kp = w.pool(K["pool"])
                                h = max(h, w.max_size(K["pool"]), w.max_size(kp["fallback"]))
                    for K in jigs:
                        if not can_attach(J, K): continue
                        q = K["pos"]; qy = q[1]
                        o = (t[0] - q[0], t[1] - q[1], t[2] - q[2])
                        box = w.box(C, o, rot)
                        child_rigid = C["proj"] == "rigid"
                        d = rel - qy + STEP[f][1]
                        if parent_rigid and child_rigid: yj = y0 + d
                        else:
                            if surf[0] is None: surf[0] = surface(p[0], p[2])
                            yj = surf[0] - qy
                        dy = yj - box[1]
                        box = moved(box, dy); child_pos = (o[0], o[1] + dy, o[2])
                        if h > 0:
                            k = max(h + 1, box[4] - box[1])
                            box = (box[0], box[1], box[2], box[3], max(box[4], box[1] + k), box[5])
                        lim = F["limit"]
                        if not inside_box(box, lim): continue
                        if any(meets(box, rb) for rb in F["removed"]): continue
                        F["removed"].append(box)
                        gparent = parent["ground"]
                        gchild = gparent - d if child_rigid else 1
                        if parent_rigid: G = y0 + rel
                        elif child_rigid: G = yj + qy
                        else:
                            if surf[0] is None: surf[0] = surface(p[0], p[2])
                            G = surf[0] + tdiv(d, 2)
                        child = dict(el=C, pos=child_pos, rot=rot, box=box, ground=gchild, junctions=[], depth=depth + 1)
                        parent["junctions"].append((t[0], G - rel + gparent, t[2], d, C["proj"]))
                        child["junctions"].append((p[0], G - qy + gchild, p[2], -d, parent["el"]["proj"]))
                        pieces.append(child)
                        events.append((pieces.index(parent), t[0], G - rel + gparent, t[2], d, C["proj"]))
                        events.append((len(pieces) - 1, p[0], G - qy + gchild, p[2], -d, parent["el"]["proj"]))
                        if depth + 1 <= st["size"]:
                            queue.append((prio, seq[0], child, F, depth + 1)); seq[0] += 1
                        placed = True
                        break
                    if placed: break
                if placed: break
    place_children(start, holder0, 0)
    while queue:
        best = min(range(len(queue)), key=lambda i: (-queue[i][0], queue[i][1]))
        _, _, piece, F, depth = queue.pop(best)
        place_children(piece, F, depth)
    return pieces

def structure(gen, name):
    j = json.load(open(os.path.join(gen, "vanilla-data/data/minecraft/worldgen/structure", name + ".json")))
    md = j["max_distance_from_center"]
    hor, ver = (md, md) if isinstance(md, int) else (md["horizontal"], md.get("vertical", 4064))
    return dict(start_pool=j["start_pool"], size=j["size"], start_height=j["start_height"]["absolute"], project="project_start_to_heightmap" in j, hack=j["use_expansion_hack"], hor=hor, ver=ver)

def describe(e):
    if e["kind"] == "single": return e["loc"].split(":", 1)[-1]
    if e["kind"] == "list": return "list:" + describe(e["subs"][0])
    if e["kind"] == "feature": return "feature:" + e["feature"].split(":", 1)[-1]
    return "empty"

def sg(v, n): return ("-" if v < 0 else "+") + str(abs(v)).zfill(n)

def cobol_rows(ps, name, cx, cz):
    """the rows of a case: H (structure, chunk, piece and junction counts), P rows (element, position, rotation, box, ground, projection), J rows (owner, source, delta, projection)"""
    rows = []
    ev = ps[0]["events"]
    rows.append(("H" + name.ljust(24) + sg(cx, 6) + sg(cz, 6) + sg(len(ps), 6) + sg(len(ev), 6)).ljust(140))
    for p in ps:
        b = p["box"]
        rows.append(("P" + describe(p["el"]).ljust(64) + sg(p["pos"][0], 6) + sg(p["pos"][1], 6) + sg(p["pos"][2], 6) + str(p["rot"]) +
                     "".join(sg(v, 6) for v in b) + sg(p["ground"], 3) + str(0 if p["el"]["proj"] == "rigid" else 1)).ljust(140))
    for o, x, y, z, d, pr in ev:
        rows.append(("J" + sg(o + 1, 6) + sg(x, 6) + sg(y, 6) + sg(z, 6) + sg(d, 6) + str(0 if pr == "rigid" else 1)).ljust(140))
    return rows

def run(gen, name, seed, cx, cz):
    w = World(gen); st = structure(gen, name)
    return assemble(w, st, seed, cx, cz)

CASES = [("pillager_outpost", 3, -2), ("pillager_outpost", -7, 5), ("village_plains", 5, 7), ("village_desert", -4, 9), ("village_plains", 5, 0)]
if __name__ == "__main__":
    if sys.argv[2] == "--cobol":
        gen = sys.argv[1]; seed = int(sys.argv[3]) if len(sys.argv) > 3 else 12345
        w = World(gen); out = []
        n = 0
        for name, cx, cz in CASES:
            ps = assemble(w, structure(gen, name), seed, cx, cz)
            if ps is None: continue
            r = cobol_rows(ps, name, cx, cz); out += r
        print("ROWS", len(out))
        for r in out: print('    05 FILLER PIC X(140) VALUE "%s".' % r)
        sys.exit(0)
    if sys.argv[2] == "--synthetic":
        w = World(sys.argv[1]); st = dict(start_pool="test:start", size=3, start_height=70, project=False, hack=False, hor=20, ver=20)
        for cx, cz in [(0, 0), (1, 0), (-2, 3), (4, 4)]:
            ps = assemble(w, st, 12345, cx, cz)
            print(cx, cz, len(ps), [(describe(p["el"]), p["pos"], p["rot"], p["box"], p["ground"]) for p in ps], ps[0]["events"])
        st2 = dict(st); st2["start_pool"] = "test:start2"
        for cx, cz in [(7, 7), (8, -6), (-9, 5)]:
            ps = assemble(w, st2, 12345, cx, cz)
            print("two", cx, cz, len(ps), [(describe(p["el"]), p["pos"], p["rot"]) for p in ps])
        sys.exit(0)
    gen, name, seed, cx, cz = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])
    ps = run(gen, name, seed, cx, cz)
    if ps is None: print("none")
    else:
        print(len(ps), "pieces")
        for p in ps: print(describe(p["el"]), p["pos"], p["rot"], p["box"], p["ground"], p["el"]["proj"], p["junctions"])
