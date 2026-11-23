#!/usr/bin/env python3
"""Expected numbers of tests/test_inventory_preview.cob: the player-model preview of the inventory screen, from the formulas of
docs/protocol/49 section 4 (angles, turn, offset, scale), 12 section 7.4 (the player model's head and hat cuboids) and 34-1 section 1.5/6
(the render sequence: translate (0, -1.501, 0), scale (-1, -1, 1) x 0.9375, rotate Y by 180 - body yaw), written independently of the COBOL.
Prints, for the frames of the test (window 854 x 480, GUI scale 2, leftPos 125, topPos 37: box centre (175.5, 80)), the device pixel of the
centre of the hat's front face (model point (0, -4, -4.5) pixels: the hat is the head's cuboid grown by 0.5), and of the lowest and the highest
edge of the figure at rest. usage: python3 gen_preview.py"""
import math

SCALE = 30.0      # 49 section 4.1: GUI pixels a block
LIFT = 1.8 / 2 + 0.0625   # 49 section 4.3: half the standing height plus the offset
CX, CY, G = 175.5, 80.0, 2


def rx(p, t):
    x, y, z = p
    c, s = math.cos(t), math.sin(t)
    return (x, y * c - z * s, y * s + z * c)


def ry(p, t):
    x, y, z = p
    c, s = math.cos(t), math.sin(t)
    return (x * c + z * s, y, z * c - x * s)


def point(p_px, mouse, on_head=True):
    a = math.atan((CX - mouse[0]) / 40)
    b = math.atan((CY - mouse[1]) / 40)
    body = 180 + a * 20
    head = body + a * 20
    p = tuple(v / 16 for v in p_px)
    if on_head:
        p = rx(p, math.radians(-b * 20))                 # the head's pitch, xRot = -b x 20
        p = ry(p, math.radians(head - body))             # the head's yaw relative to the body
    p = (p[0], p[1] - 1.501, p[2])
    p = (-p[0] * 0.9375, -p[1] * 0.9375, p[2] * 0.9375)
    p = ry(p, math.radians(180 - body))
    p = rx(p, math.radians(b * 20))                      # the whole figure
    p = (-p[0], -p[1], p[2])                             # half a turn about Z
    p = (p[0], p[1] + LIFT, p[2])
    return ((CX + p[0] * SCALE) * G, (CY + p[1] * SCALE) * G)


if __name__ == "__main__":
    for name, mouse in (("first frame (pointer 0, 0)", (0, 0)), ("pointer at the centre", (175, 80)), ("pointer 40 left", (135, 80)),
                        ("pointer 40 above", (175, 40))):
        x, y = point((0, -4, -4.5), mouse)
        print("%-28s hat front centre x %.3f y %.3f" % (name, x, y))
    print("feet bottom edge y %.3f (the pants' front face, 24.25 pixels down)" % point((0, 24.25, -2.25), (175, 80), False)[1])
    print("hat top edge y %.3f" % point((0, -8.5, -4.5), (175, 80))[1])
