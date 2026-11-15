#!/usr/bin/env python3
"""Read-back checker for a 26.3 world folder: applies what the game's loader requires (docs/protocol/07 section 10) to the
files CobolCraft wrote, and prints one line per problem. Exit status 0 when there is none, 1 otherwise.
usage: validate_world.py WORLD_FOLDER [--regions N]   (N: region files to scan per folder, default 8)
Read-only; stdlib only."""
import gzip, os, struct, sys, zlib

TYPES = ["End", "Byte", "Short", "Int", "Long", "Float", "Double", "ByteArray", "String", "List", "Compound", "IntArray", "LongArray"]

class Reader:
    def __init__(self, b): self.b, self.p = b, 0
    def take(self, f):
        v = struct.unpack_from(">" + f, self.b, self.p)[0]; self.p += struct.calcsize(f); return v
    def string(self):
        n = self.take("H"); v = self.b[self.p:self.p + n].decode("utf8", "replace"); self.p += n; return v
    def payload(self, t):
        if t == 1: return self.take("b")
        if t == 2: return self.take("h")
        if t == 3: return self.take("i")
        if t == 4: return self.take("q")
        if t == 5: return self.take("f")
        if t == 6: return self.take("d")
        if t == 7: n = self.take("i"); self.p += n; return ("bytes", n)
        if t == 8: return self.string()
        if t == 9:
            it = self.take("b"); n = self.take("i"); return ("list", TYPES[it], [self.payload(it) for _ in range(n)])
        if t == 10:
            d = {}
            while True:
                tt = self.take("b")
                if tt == 0: return d
                k = self.string(); d[k] = (TYPES[tt], self.payload(tt))
        if t == 11: n = self.take("i"); self.p += 4 * n; return ("ints", n)
        if t == 12: n = self.take("i"); self.p += 8 * n; return ("longs", n)
        raise ValueError("bad tag type %d" % t)

def parse(b):
    r = Reader(b); t = r.take("b")
    if t != 10: raise ValueError("root is not a compound")
    r.string(); root = r.payload(10)
    return root

def load_gz(path):
    b = open(path, "rb").read()
    return parse(gzip.decompress(b))

def get(c, *path):
    for k in path:
        if not isinstance(c, dict) or k not in c: return None
        c = c[k][1]
    return c

problems = []
def bad(where, what): problems.append("%s: %s" % (where, what))

def need(c, where, path, typ):
    n = c
    for k in path[:-1]:
        n = get(n, k) if isinstance(n, dict) else None
        if n is None: bad(where, "missing %s" % ".".join(path)); return
    e = n.get(path[-1]) if isinstance(n, dict) else None
    if e is None: bad(where, "missing %s" % ".".join(path))
    elif e[0] != typ: bad(where, "%s is %s, the game reads %s" % (".".join(path), e[0], typ))

def check_level(folder):
    p = os.path.join(folder, "level.dat"); w = "level.dat"
    if not os.path.exists(p): bad(w, "missing: not a world"); return None
    try: root = load_gz(p)
    except Exception as e: bad(w, "unreadable (%s): the game falls back to level.dat_old" % e); return None
    if "Data" not in root or root["Data"][0] != "Compound":
        bad(w, "no root compound Data: the 26.3 loader reads root.Data (a flat file is not a vanilla level.dat)"); return None
    d = {"Data": root["Data"]}
    for path, t in [(("DataVersion",), "Int"), (("LevelName",), "String"), (("GameType",), "Int"), (("Time",), "Long"),
                    (("LastPlayed",), "Long"), (("version",), "Int"), (("initialized",), "Byte"), (("allowCommands",), "Byte"),
                    (("spawn", "dimension"), "String"), (("spawn", "pos"), "IntArray"),
                    (("difficulty_settings", "difficulty"), "String"), (("Version", "Id"), "Int"), (("Version", "Name"), "String"),
                    (("DataPacks", "Enabled"), "List")]:
        need(d, w, ("Data",) + path, t)
    vid, dv = get(d, "Data", "Version", "Id"), get(d, "Data", "DataVersion")
    if vid is not None and dv is not None and vid != dv: bad(w, "Version.Id %s differs from DataVersion %s" % (vid, dv))
    hist = get(d, "Data", "version_history")
    if hist and dv is not None and hist[2] and hist[2][-1] != dv: bad(w, "version_history ends at %s, DataVersion is %s" % (hist[2][-1], dv))
    for flat in ("WorldType", "Seed", "Clocks", "Weather", "GameRules", "Spawn", "ContentJar"):
        if flat in root: bad(w, "flat CobolCraft key %s at the root" % flat)
    return d

def check_saved(folder):
    base = os.path.join(folder, "data", "minecraft")
    gen = os.path.join(base, "world_gen_settings.dat"); w = "data/minecraft/world_gen_settings.dat"
    if not os.path.exists(gen): bad(w, "missing: the game logs 'Unable to read or access the world gen settings file' and uses a random seed")
    else:
        try: r = load_gz(gen)
        except Exception as e: bad(w, "unreadable (%s)" % e); r = None
        if r is not None:
            need(r, w, ("data", "seed"), "Long"); need(r, w, ("DataVersion",), "Int")
            for k, t in (("generate_structures", "Byte"), ("bonus_chest", "Byte")): need(r, w, ("data", k), t)
            dims = get(r, "data", "dimensions")
            if not isinstance(dims, dict): bad(w, "no data.dimensions: 'Overworld settings missing' (IllegalStateException in WorldDimensions)")
            else:
                if "minecraft:overworld" not in dims: bad(w, "dimensions has no minecraft:overworld stem")
                for k, (t, v) in dims.items():
                    for sub in (("type",), ("generator", "type")):
                        n = v
                        for s in sub: n = get({"x": ("Compound", n)}, "x", s) if isinstance(n, dict) else None
                        if n is None: bad(w, "stem %s lacks %s" % (k, ".".join(sub)))
    for name, keys in (("weather.dat", ()), ("world_clocks.dat", ()), ("game_rules.dat", ())):
        p = os.path.join(base, name)
        if os.path.exists(p):
            try:
                r = load_gz(p)
                if "data" not in r or "DataVersion" not in r: bad("data/minecraft/" + name, "needs root data and DataVersion")
            except Exception as e: bad("data/minecraft/" + name, "unreadable (%s)" % e)

def check_region(path, label, limit):
    b = open(path, "rb").read()
    if len(b) == 0: return
    if len(b) < 8192: bad(label, "shorter than the 8192-byte header"); return
    if len(b) % 4096: bad(label, "size %d is not a multiple of 4096" % len(b))
    sectors = len(b) // 4096; used = {}; seen = 0
    for i in range(1024):
        e = struct.unpack_from(">I", b, 4 * i)[0]
        if e == 0: continue
        off, cnt = e >> 8, e & 255
        if off < 2 or cnt == 0 or off + cnt > sectors: bad(label, "slot %d offset %d count %d outside the file (%d sectors)" % (i, off, cnt, sectors)); continue
        for s in range(off, off + cnt):
            if s in used: bad(label, "slot %d overlaps slot %d at sector %d" % (i, used[s], s)); break
            used[s] = i
        ln, ct = struct.unpack_from(">IB", b, off * 4096)
        if ln < 1 or 4 + ln > cnt * 4096: bad(label, "slot %d length %d does not fit its %d sectors" % (i, ln, cnt)); continue
        if ct & 128: bad(label, "slot %d is stored in an external .mcc file" ); continue
        if ct not in (1, 2, 3, 4): bad(label, "slot %d compression type %d" % (i, ct)); continue
        seen += 1
        if seen > limit: continue
        data = b[off * 4096 + 5: off * 4096 + 4 + ln]
        try:
            raw = zlib.decompress(data) if ct == 2 else gzip.decompress(data) if ct == 1 else data if ct == 3 else None
            if raw is None: continue
            c = parse(raw)
        except Exception as e: bad(label, "slot %d payload unreadable (%s)" % (i, e)); continue
        if "DataVersion" not in c: bad(label, "slot %d chunk has no DataVersion" % i)
        elif c["DataVersion"][0] != "Int": bad(label, "slot %d DataVersion is %s" % (i, c["DataVersion"][0]))
        if "sections" in c or "xPos" in c:
            for k in ("xPos", "zPos", "yPos"):
                if k not in c: bad(label, "slot %d chunk lacks %s" % (i, k))
            if "Status" not in c: bad(label, "slot %d chunk lacks Status" % i)
            if "sections" in c and c["sections"][0] != "List": bad(label, "slot %d sections is not a list" % i)
            rx, rz = [int(x) for x in os.path.basename(path).split(".")[1:3]]
            if "xPos" in c and "zPos" in c and (c["xPos"][1] >> 5, c["zPos"][1] >> 5) != (rx, rz): bad(label, "slot %d chunk position is outside this region" % i)
            elif "xPos" in c and "zPos" in c and (c["xPos"][1] & 31) + 32 * (c["zPos"][1] & 31) != i: bad(label, "slot %d holds the chunk of slot %d" % (i, (c["xPos"][1] & 31) + 32 * (c["zPos"][1] & 31)))

def main(argv):
    folder, limit = argv[1], 8
    if "--regions" in argv: limit = int(argv[argv.index("--regions") + 1])
    check_level(folder); check_saved(folder)
    pdir = os.path.join(folder, "players", "data")
    if os.path.isdir(pdir):
        for f in sorted(os.listdir(pdir)):
            if f.endswith(".dat"):
                try:
                    r = load_gz(os.path.join(pdir, f))
                    for k, t in (("DataVersion", "Int"), ("Pos", "List"), ("Inventory", "List")):
                        if k not in r: bad("players/data/" + f, "missing " + k)
                except Exception as e: bad("players/data/" + f, "unreadable (%s)" % e)
    root = os.path.join(folder, "dimensions")
    if os.path.isdir(root):
        for dp, dn, fn in os.walk(root):
            for f in sorted(fn):
                if f.endswith(".mca"):
                    check_region(os.path.join(dp, f), os.path.relpath(os.path.join(dp, f), folder), limit)
    if os.path.isdir(os.path.join(folder, "players")):
        for f in os.listdir(os.path.join(folder, "players")):
            if f.endswith(".dat"): bad("players/" + f, "legacy path: the game reads players/data/<uuid>.dat only")
    for p in problems: print(p)
    print("%d problem(s)" % len(problems))
    return 1 if problems else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
