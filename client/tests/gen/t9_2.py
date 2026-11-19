from g9 import *
import math, struct
def f32(x): return struct.unpack('f', struct.pack('f', x))[0]
def msin(x): return f32(math.sin((int(x * 10430.378350470453) & 65535) / 10430.378350470453))
def mcos(x): return f32(math.sin((int(x * 10430.378350470453 + 16384.0) & 65535) / 10430.378350470453))
t = mk9(2, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 2 (conventions): Mth.sin and Mth.cos through the 65536-entry table (the argument quantised to 2 pi / 65536, negative arguments wrapping), the packed light coordinates",
            "(15728880, 15728850), the overlay texture (u(f), v(hurt), pack, the alpha of the white texels), the texture scale of addBox, PartPose.scaled and withScale."],
        title='conventions', extra='\n 01 WS-X                 FLOAT-LONG.\n 01 WS-R2                FLOAT-LONG.')
for x in (0, 1, -1, 0.5, 3.1415927, -3.1415927, 6.2831853, 100.25, -77.7, 1e-5, 12345.678):
    t.raw('MOVE %s TO WS-X' % lit(x), 'CALL "PENG-MTH-SIN" USING WS-X WS-R2'); t.num('2 Mth.sin(%s)' % x, msin(x), 'WS-R2')
    t.raw('CALL "EF9-MTH-COS" USING WS-X WS-R2'); t.num('2 Mth.cos(%s)' % x, mcos(x), 'WS-R2')
# the step of the table: arguments inside one step give the same value; cos(0) = 1 exactly
t.raw('MOVE 0 TO WS-X', 'CALL "EF9-MTH-COS" USING WS-X WS-R2'); t.num('2 Mth.cos(0) is 1', 1, 'WS-R2')
for bl, sk in ((15, 15), (13, 15), (0, 0), (7, 3)):
    t.call('EF9-LIGHT-PACK', [bl, sk], [(bl << 4) | (sk << 20)], '2.5 pack(block %d, sky %d)' % (bl, sk))
    t.call('EF9-LIGHT-UNPACK', [(bl << 4) | (sk << 20)], [bl, sk], '2.5 unpack of block %d, sky %d' % (bl, sk))
assert (15 << 4) | (15 << 20) == 15728880 and 15728640 + 210 == 15728850
t.call('EF9-LIGHT-UNPACK', [15728850], [13, 15], '2.5 15728850 is sky 15, block field 13')
for f, hurt in ((0, 0), (1.0, 0), (0.5, 1), (0.99, 0), (0.25, 1)):
    u = int(f * 15); v = 3 if hurt else 10
    t.call('EF9-OVERLAY', [f, hurt], [u, v, u | (v << 16)], '2.5 overlay f %s hurt %d (u, v, pack)' % (f, hurt))
t.call('EF9-OVERLAY', [1.0, 0], [15, 10, 15 | (10 << 16)], '2.5 the TNT flash is pack(15, 10)')
for u in range(16): t.call('EF9-OVERLAY-ALPHA', [u], [int((1 - (u / 15) * 0.75) * 255)], '2.5 alpha of the white texel in column %d' % u)
t.call('EF9-OVERLAY-ALPHA', [15], [63], '2.5 pixel (15, 10) has alpha 63')
t.call('EF9-OVERLAY-ALPHA', [0], [255], '2.5 NO_OVERLAY is pixel (0, 10), alpha 255')
for px in (0, 1, 4, 5, 16, 32):
    t.call('EF9-UV-SCALE', [px, 32, 0.8], [px / (32 * 0.8)], '2.2 texture scale: pixel %d of 32 at v scale 0.8' % px)
t.call('EF9-UV-SCALE', [4, 32, 0.8], [0.15625], '2.2 the arrow cross plane: row 4 of 25.6 is 0.15625')
t.call('EF9-UV-SCALE', [8, 64, 1], [0.125], '2.2 scale 1 divides by the layer size')
t.call('EF9-POSE-SCALED', [-11, 0, 4, 1, 1, 1, 0.9], [-9.9, 0, 3.6, 0.9, 0.9, 0.9], '2.1 PartPose.scaled(0.9) multiplies offset and scale')
t.call('EF9-POSE-WITH-SCALE', [1, 2, 3, 0.1, 0.2, 0.3, 0.75], [1, 2, 3, 0.1, 0.2, 0.3, 0.75, 0.75, 0.75], '2.1 withScale(s) keeps offset and rotation and sets all three scales')
save9(t, 2)
