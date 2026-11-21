#!/usr/bin/env python3
"""Independent model of the local player's knockback and elytra flight (docs/protocol 13 section 1.3, 17 section 3.13,
00 section 4.6 LpVec3). Test infrastructure of client/tests/test_motion_local.cob and test_glide_physics.cob: the expected
numbers in those tests are the output of this script (run it to see them); it shares no code with the client.

  python3 glide_model.py          prints every table the tests use
"""
import math

G = 0.08


def lp_roundtrip(v):
    """What a Set Entity Motion packet delivers: the LpVec3 encoding of v decoded again (15-bit components)."""
    m = max(abs(c) for c in v)
    if m < 3.051944088384301e-5:
        return (0.0, 0.0, 0.0)
    scale = math.ceil(m)
    out = []
    for c in v:
        q = round((c / scale * 0.5 + 0.5) * 32766)
        out.append((min(q, 32766) * 2 / 32766 - 1) * scale)
    return tuple(out)


def look(yaw_deg, pitch_deg):
    y, p = math.radians(yaw_deg), math.radians(pitch_deg)
    return (-math.sin(y) * math.cos(p), -math.sin(p), math.cos(y) * math.cos(p))


def glide_step(v, L, pitch_deg):
    """17 section 3.13 flight step: the five steps, in order."""
    vx, vy, vz = v
    lx, ly, lz = L
    p = math.radians(pitch_deg)
    lh = math.hypot(lx, lz)
    vh = math.hypot(vx, vz)
    c = math.cos(p) ** 2
    vy += G * (-1 + c * 0.75)
    if vy < 0 and lh > 0:
        a = vy * -0.1 * c
        vx += lx * a / lh
        vy += a
        vz += lz * a / lh
    if p < 0 and lh > 0:
        b = vh * -math.sin(p) * 0.04
        vx += -lx * b / lh
        vy += b * 3.2
        vz += -lz * b / lh
    if lh > 0:
        vx += (lx / lh * vh - vx) * 0.1
        vz += (lz / lh * vh - vz) * 0.1
    return (vx * 0.99, vy * 0.98, vz * 0.99)


def rocket(v, L):
    """17 section 3.13 firework boost: look x 0.1 + (look x 1.5 - velocity) x 0.5, added to the velocity."""
    return tuple(v[i] + L[i] * 0.1 + (L[i] * 1.5 - v[i]) * 0.5 for i in range(3))


def fly(pos, v, yaw, pitch, ticks, boost_at=None):
    """Positions after each tick of a glide (no obstacles); boost_at = {tick: True}: a rocket's Set Entity Motion
    (the boosted velocity, through the LpVec3 codec) arrives before that tick."""
    L = look(yaw, pitch)
    out = []
    for t in range(1, ticks + 1):
        if boost_at and t in boost_at:
            v = lp_roundtrip(rocket(v, L))
        v = glide_step(v, L, pitch)
        pos = tuple(pos[i] + v[i] for i in range(3))
        out.append((pos, v))
    return out


def knock(pos, v, ticks, floor=10.0):
    """Set Entity Motion to a walking player (13 section 1.3: velocity is applied, then gravity and drag; horizontal
    drag 0.546 on the ground, 0.91 in the air, below 0.003 it stops), a flat floor at height `floor`."""
    x, y, z = pos
    vx, vy, vz = v
    ground = True
    out = []
    for t in range(1, 41):
        y += vy
        if y < floor:
            y = floor
            vy = 0.0
        vy = (vy - 0.08) * 0.98
        x += vx
        z += vz
        f = 0.546 if ground else 0.91
        vx *= f
        vz *= f
        if abs(vx) < 0.003:
            vx = 0.0
        if abs(vz) < 0.003:
            vz = 0.0
        ground = y - 0.001 < floor
        out.append(((x, y, z), None))
    return out


def fly_floor(pos, v, yaw, pitch, floor=10.0, limit=200):
    """A glide that ends on a flat floor at height `floor`: returns the tick on which the box first rests on it (the y move
    is clipped there, the vertical speed stops) and the position."""
    L = look(yaw, pitch)
    for t in range(1, limit + 1):
        v = glide_step(v, L, pitch)
        pos = tuple(pos[i] + v[i] for i in range(3))
        if pos[1] <= floor + 0.001 and v[1] < 0:
            return t, (pos[0], floor, pos[2])
    return None, pos


def fmt(a):
    return " ".join("%.3f" % c for c in a)


if __name__ == "__main__":
    kb = lp_roundtrip((0.4, 0.36, -0.2))
    print("knockback packet decodes to", kb)
    for t in (1, 2, 5, 12, 40):
        print("knock tick", t, " ".join("%.3f" % c for c in knock((0.5, 10.0, 0.5), kb, 40)[t - 1][0]))
    start = (0.5, 100.0, -12.5)
    v0 = lp_roundtrip((0.0, -0.3, 0.6))
    print("glide start velocity", v0)
    for pitch in (0, -40, 45):
        res = fly(start, v0, 0, pitch, 20)
        for t in (1, 5, 20):
            print("glide pitch", pitch, "tick", t, fmt(res[t - 1][0]))
    # a rocket after tick 5: the boosted velocity the server would send, then ticks 6 and 12
    res = fly(start, v0, 0, 0, 12, boost_at={6: True})
    pre = fly(start, v0, 0, 0, 5)[4][1]
    boosted = rocket(pre, look(0, 0))
    print("rocket: velocity before", pre, "packet", boosted, "speed before", math.hypot(pre[0], pre[2]), "after", math.hypot(boosted[0], boosted[2]))
    for t in (5, 6, 12):
        print("rocket pitch 0 tick", t, fmt(res[t - 1][0]))
    # landing: from 4 blocks above the floor, diving at 45 degrees
    t, pos = fly_floor((0.5, 14.0, -12.5), v0, 0, 45)
    print("landing tick", t, "at", pos)
