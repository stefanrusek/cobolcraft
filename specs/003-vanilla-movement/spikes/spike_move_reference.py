#!/usr/bin/env python3
"""spike (throwaway, plan 003): reference series for spike_move_arith.cob.

Usage: spike_move_reference.py <spike output file>

Computes the same series twice, independently of the COBOL: in IEEE double, and in the single precision the documents
name (float constants, friction and drag products rounded to float, the 65536-entry sine table of docs/protocol 39).
Prints the largest absolute per-tick difference of the COBOL output against each.
"""
import math
import struct
import sys


def f32(x):
    return struct.unpack("f", struct.pack("f", x))[0]


def table_sin(x):
    return f32(math.sin((int(x * 10430.378350470453) & 65535) / 10430.378350470453))


def table_cos(x):
    return f32(math.sin((int(x * 10430.378350470453 + 16384.0) & 65535) / 10430.378350470453))


def horizontal(friction, held, total, single):
    r = f32 if single else (lambda v: v)
    f = r(friction)
    h = r(f * r(0.91))
    v = p = 0.0
    out = []
    for i in range(1, total + 1):
        if v * v < 9.0e-6:
            v = 0.0
        a = 0.0
        if i <= held:
            speed = r(0.1) if single else 0.1
            k = r(speed * r(r(0.21600002) / r(r(f * f) * f))) if single else speed * 0.21600002 / f ** 3
            a = r(0.98) * k if single else 0.98 * k
        v += a
        p += v
        out.append(p)
        v *= h
    return out


def jump():
    v, p, out = 0.41999998688697815, 0.0, []
    for _ in range(12):
        if abs(v) < 0.003:
            v = 0.0
        p += v
        out.append(p)
        v = (v - 0.08) * 0.98
    return out


def jump_single():
    v, p, out = f32(0.42), 0.0, []
    for _ in range(12):
        if abs(v) < 0.003:
            v = 0.0
        p += v
        out.append(p)
        v = (v - 0.08) * f32(0.98)
    return out


def yaw(single):
    x = vx = 0.0
    out = []
    a = f32(f32(37.5) * f32(math.pi / 180)) if single else 37.5 * math.pi / 180
    s = table_sin(a) if single else math.sin(a)
    drag = f32(f32(0.6) * f32(0.91)) if single else 0.6 * 0.91
    acc = f32(0.98) * f32(0.1) if single else 0.098
    for _ in range(40):
        vx -= acc * s
        x += vx
        out.append(x)
        vx *= drag
    return out


def crossing():
    """What the documented rules give when a steady ordinary-ground walk meets ice, and ice meets ground again."""
    v, rows = 0.0, []
    plan = [("ground, held", 0.6, True, 30), ("ice, held", 0.98, True, 12), ("ice, released", 0.98, False, 6),
            ("ice, held", 0.98, True, 60), ("ground again, held", 0.6, True, 6)]
    for label, f, held, ticks in plan:
        for _ in range(ticks):
            if v * v < 9.0e-6:
                v = 0.0
            if held:
                v += 0.098 * 0.21600002 / f ** 3
            rows.append((label, v))
            v *= f * 0.91
    return rows


def main():
    if sys.argv[1] == "--crossing":
        rows = crossing()
        for label, d in rows[27:48] + rows[-9:]:
            print(f"{label}: {d:.6f}")
        return
    got = {}
    for line in open(sys.argv[1]):
        parts = line.split()
        if parts and parts[0] == "S":
            got.setdefault(parts[1], []).append(float(parts[3]))
    refs = {
        "ground": (horizontal(0.6, 40, 55, False), horizontal(0.6, 40, 55, True)),
        "ice": (horizontal(0.98, 60, 150, False), horizontal(0.98, 60, 150, True)),
        "jump": (jump(), jump_single()),
        "yawx": (yaw(False), yaw(True)),
    }
    for name, (dbl, sgl) in refs.items():
        c = got[name]
        assert len(c) == len(dbl), (name, len(c), len(dbl))
        d1 = max(abs(a - b) for a, b in zip(c, dbl))
        d2 = max(abs(a - b) for a, b in zip(c, sgl))
        print(f"{name}: ticks={len(c)} final={c[-1]:.9f} max|cobol-double|={d1:.3e} max|cobol-single|={d2:.3e}")
    g, i = got["ground"], got["ice"]
    print(f"ground: step at tick 40={g[39] - g[38]:.6f} glide after release={g[-1] - g[39]:.6f}")
    print(f"ice: step at tick 60={i[59] - i[58]:.6f} slide after release={i[-1] - i[59]:.6f}")
    print(f"jump: peak={max(got['jump']):.6f}")


main()
