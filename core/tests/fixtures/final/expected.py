#!/usr/bin/env python3
"""Fixture generator and independent reference for core/tests/test_density_final.cob (T0416).

Writes the density function tree of this folder (data/minecraft/worldgen/density_function/...) and prints the expected
float32 results as the COBOL table of the test. The tree has the structure of final_density written in docs/protocol/10
section 6.5 and docs/protocol/11 section 2.1 to 2.6 (the squeeze of an interpolated blend_density of the lerp pair around
the range_choice, the min with the noodle, the beardifier), with every noise leaf replaced by a gradient or a constant so
that the values can be computed here without noise code; the real data are checked by a Convergence test later.
The evaluation rules are those of docs/protocol/10 section 4 and 16 (float32 after every operation) written again in
Python with struct rounding, not read from core/src/density.cob."""
import json, os, struct, sys

def f32(x):
    return struct.unpack('f', struct.pack('f', x))[0]

def bits(x):
    return struct.unpack('<q', struct.pack('<d', x))[0]

def grad(axis, c0, c1, v0, v1):
    return {"type": "minecraft:gradient", "axis": axis, "from_coordinate": c0, "to_coordinate": c1, "from_value": v0, "to_value": v1}
def op(t, a, b): return {"type": "minecraft:" + t, "left": a, "right": b}
def un(t, a): return {"type": "minecraft:" + t, "input": a}
def rc(i, lo, hi, a, b): return {"type": "minecraft:range_choice", "input": i, "min_inclusive": lo, "max_exclusive": hi, "when_in_range": a, "when_out_of_range": b}
def interp(a): return {"type": "minecraft:interpolated", "cell_size_xz": 4, "cell_size_y": 8, "input": a}
def lerp(al, a, b): return {"type": "minecraft:lerp", "alpha": al, "first": a, "second": b}
def clamp(a, lo, hi): return {"type": "minecraft:clamp", "input": a, "min": lo, "max": hi}
Y = "minecraft:y"
def ygate(f, other): return rc(Y, -60.0, 321.0, f, other)
def ref(n): return "minecraft:overworld/" + n

FUNCS = {
    "y": grad("y", -4064, 4062, -4064.0, 4062.0),
    "overworld/sloped_cheese": op("add", grad("y", -64, 320, 3.0, -3.0), grad("x", -100, 100, -0.5, 0.5)),
    "overworld/caves/entrances": grad("y", -64, 320, 0.75, -0.75),
    "overworld/caves/spaghetti_2d": grad("y", -64, 320, 0.5, -0.5),
    "overworld/caves/spaghetti_roughness_function": {"type": "minecraft:constant", "value": 0.03125},
    "overworld/caves/pillars": grad("y", -64, 320, -0.5, 0.5),
    "overworld/caves/noodle": rc(
        interp(ygate(grad("y", -64, 320, -0.5, 0.5), -1.0)), -1000000.0, 0.0, 64.0,
        op("add",
           interp(ygate({"type": "minecraft:constant", "value": -0.0625}, 0.0)),
           op("mul", 1.5, op("max",
               un("abs", interp(ygate(grad("z", -100, 100, 0.25, -0.25), 0.0))),
               un("abs", interp(ygate(grad("x", -100, 100, -0.125, 0.125), 0.0))))))),
}
RC = rc(ref("sloped_cheese"), -1000000.0, 1.5625,
        op("min", ref("sloped_cheese"), op("mul", ref("caves/entrances"), 5.0)),
        op("max",
           op("min",
              op("min",
                 op("add", op("mul", 4.0, un("square", grad("y", -64, 320, 0.0, 0.5))),
                    op("add", clamp(op("add", grad("y", -64, 320, -0.75, 0.25), 0.27), -1.0, 1.0),
                       clamp(op("add", op("mul", ref("sloped_cheese"), -0.64), 1.5), 0.0, 0.5))),
                 ref("caves/entrances")),
              op("add", ref("caves/spaghetti_2d"), ref("caves/spaghetti_roughness_function"))),
           rc(ref("caves/pillars"), -1000000.0, 0.03, -1000000.0, ref("caves/pillars"))))
L = lerp(grad("y", -64, -40, 0.0, 1.0), 0.1171875,
         lerp(grad("y", 240, 256, 1.0, 0.0), -0.078125, RC))
FUNCS["overworld/final_density"] = op("add",
    op("min", un("squeeze", interp(op("mul", {"type": "minecraft:blend_density", "input": L}, 0.64))), ref("caves/noodle")),
    {"type": "minecraft:beardifier"})

POINTS = [(0, -64, 0), (3, -50, 5), (5, -41, 7), (13, 30, 22), (0, 100, 0), (7, 127, 9), (9, 238, 4), (-5, 245, -3),
          (4, 250, 4), (20, 300, -30), (-33, -60, 18), (12, 64, 12), (-100, 128, 100), (31, 17, -8), (64, 319, 64)]

# --- the reference evaluator (float32 after every step) ---
def node(n, x, y, z):
    if isinstance(n, (int, float)): return f32(n)
    if isinstance(n, str): return node(FUNCS[n.replace("minecraft:", "")], x, y, z)
    t = n["type"].replace("minecraft:", "")
    if t == "constant": return f32(n["value"])
    if t in ("add", "sub", "mul", "div"):
        a = node(n["left"], x, y, z); b = node(n["right"], x, y, z)
        return f32({"add": a + b, "sub": a - b, "mul": a * b}[t])
    if t == "min": a = node(n["left"], x, y, z); b = node(n["right"], x, y, z); return b if b < a else a
    if t == "max": a = node(n["left"], x, y, z); b = node(n["right"], x, y, z); return b if b > a else a
    if t == "abs": return abs(node(n["input"], x, y, z))
    if t == "square": a = node(n["input"], x, y, z); return f32(a * a)
    if t == "squeeze":
        a = node(n["input"], x, y, z); c = -1.0 if a < -1.0 else min(a, 1.0)
        return f32(f32(c / 2) - f32(f32(f32(c * c) * c) / 24))
    if t == "clamp":
        a = node(n["input"], x, y, z); lo = f32(n["min"]); hi = f32(n["max"]); return lo if a < lo else min(a, hi)
    if t == "blend_density": return node(n["input"], x, y, z)
    if t == "beardifier": return 0.0
    if t == "lerp":
        a = node(n["alpha"], x, y, z)
        if a == 0: return node(n["first"], x, y, z)
        if a == 1: return node(n["second"], x, y, z)
        p = node(n["first"], x, y, z); q = node(n["second"], x, y, z)
        diff = f32(q - p); scaled = f32(a * diff); return f32(p + scaled)
    if t == "range_choice":
        v = node(n["input"], x, y, z)
        return node(n["when_in_range"] if n["min_inclusive"] <= v < n["max_exclusive"] else n["when_out_of_range"], x, y, z)
    if t == "gradient":
        c = {"x": x, "y": y, "z": z}[n["axis"]]; f0 = n["from_coordinate"]; f1 = n["to_coordinate"]
        c = max(f0, min(f1, c)); lo = f32(n["from_value"]); hi = f32(n["to_value"])
        a = f32(f32(hi - lo) / f32(f1 - f0)); b = f32(f32(c - f0) * a); return f32(lo + b)
    if t == "interpolated":
        cx, cy = n["cell_size_xz"], n["cell_size_y"]
        rx, ry, rz = x % cx, y % cy, z % cx
        if rx == 0 and ry == 0 and rz == 0: return node(n["input"], x, y, z)
        x0, y0, z0 = x - rx, y - ry, z - rz
        fx = f32(f32(rx) / f32(cx)); fy = f32(f32(ry) / f32(cy)); fz = f32(f32(rz) / f32(cx))
        g = [node(n["input"], x0 + (i % 2) * cx, y0 + ((i // 2) % 2) * cy, z0 + (i // 4) * cx) for i in range(8)]
        def le(tt, a, b): return f32(a + f32(tt * f32(b - a)))
        m = [le(fx, g[0], g[1]), le(fx, g[2], g[3]), le(fx, g[4], g[5]), le(fx, g[6], g[7])]
        return le(fz, le(fy, m[0], m[1]), le(fy, m[2], m[3]))
    raise Exception(t)

if __name__ == "__main__":
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data/minecraft/worldgen/density_function")
    for name, tree in FUNCS.items():
        path = os.path.join(root, name + ".json")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w") as f:
            json.dump(tree, f)
            f.write("\n")
    for (x, y, z) in POINTS:
        v = node("minecraft:overworld/final_density", x, y, z)
        print("    05 FILLER BINARY-LONG VALUE %d.\n    05 FILLER BINARY-LONG VALUE %d.\n    05 FILLER BINARY-LONG VALUE %d.\n    05 FILLER BINARY-DOUBLE VALUE %d.   *> %r" % (x, y, z, bits(v), v))
