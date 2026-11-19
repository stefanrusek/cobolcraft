from g9 import *
import math
D = 0.017453292
t = mk9(5, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 5 and 6: 5.1 the trident model part by part (the four heads are children of the pole, the right spike mirrored), 5.2 its submit (rotate Y by yRot - 90, rotate Z by xRot + 90),",
            "culling box and texture, 5.3 the spin-attack effect model and its setupAnim (box0 at -50 and box1 at -55 degrees a tick, wrapped), 6.1 the wind charge model and its setupAnim (the pose rotation of `wind` is replaced), 6.2 the texture scroll."])
# 5.1
rows = ['P pole root 0 0 0 0 0 0']
for r in table9('### 5.1'):
    n = r['part'].replace('`', '')
    if n != 'pole': rows.append('P %s pole 0 0 0 0 0 0' % n)
    sz = re.match(r'\s*' + NUMR + r' x ' + NUMR + r' x ' + NUMR, r['size']).groups()
    tx = re.search(r'\((\d+), (\d+)\)', r['tex']).groups()
    rows.append('C %s %s %s %s %s 0 %d' % (n, tx[0], tx[1], ' '.join(triple(r['cuboid origin'])), ' '.join(sz), 1 if r['mirror'] == 'yes' else 0))
rows = [rows[0], rows[1]] + rows[2:]
# order the pole's own cuboid row right after its P row (the table lists it first)
layer_check(t, 'TRIDENT', rows, 32, 32, '5.1')
for yaw, pitch in ((0, 0), (90, 30), (-45, -60), (180, 90), (270.5, -12.25)):
    t.call('EF9-TRIDENT-OPS', [yaw, pitch], [2, 3, yaw - 90, 0, 0, 7, pitch + 90, 0, 0], '5.2 submit for yRot %s xRot %s' % (yaw, pitch))
t.call('EF9-TRIDENT-CULL', [], [1.5], '5.2 culling box inflation')
t.raw('MOVE SPACES TO WS-X120'); t.setin([0]); t.raw('CALL "EF9-TRIDENT-TEXTURE" USING WS-IN WS-X120 WS-OUT'); t.text('5.2 texture', 'entity/trident/trident.png', 'WS-X120'); t.num('5.2 render type entitySolid', 1, 'WS-OV(1)')
t.setin([1]); t.raw('CALL "EF9-TRIDENT-TEXTURE" USING WS-IN WS-X120 WS-OUT'); t.num('5.2 render type of a foil trident entitySolidGlint', 2, 'WS-OV(1)')
# 5.3 spin attack: boxes from the formulas of the text
srows = []
for i in (0, 1):
    off = -3.2 + 9.6 * (i + 1); sc = 0.75 * (i + 1)
    srows.append('P box%d root 0 0 0 0 0 0 %s %s %s' % (i, lit(sc), lit(sc), lit(sc)))
    srows.append('C box%d 0 0 -8 %s -8 16 32 16 0 0' % (i, lit(-16 + off)))
layer_check(t, 'PLAYER_SPIN_ATTACK', srows, 64, 64, '5.3')
def wrap(x): return x - 360 * math.floor((x + 180) / 360)
for age in (0, 1, 3.5, 7.2, 10, 100.25, 1000.5):
    t.raw('MOVE "PLAYER_SPIN_ATTACK" TO WS-LAYER', 'CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([age]); t.raw('CALL "EF9-SPIN-ANIM" USING EMM-MODEL WS-IN')
    for i in (0, 1): t.cur('box%d' % i, 'yrot', wrap(age * -(45 + (i + 1) * 5)) * D)
# 6.1 wind charge
wrows = ['P bone root 0 0 0 0 0 0']
for r in table9('### 6.1'):
    n = r['part'].replace('`', '')
    rot = rot_cell(r['pose'])
    wrows.append('P %s bone 0 0 0 %s' % (n, ' '.join(rot)))
    txs = re.findall(r'\((\d+), (\d+)\)', r['tex'])
    for tx, bx in zip(txs, r['cuboids'].split(';')):
        sz = re.search(NUMR + r' x ' + NUMR + r' x ' + NUMR, bx).groups()
        wrows.append('C %s %s %s %s %s 0 0' % (n, tx[0], tx[1], ' '.join(triple(bx)), ' '.join(sz)))
layer_check(t, 'WIND_CHARGE', wrows, 64, 32, '6.1')
for age in (0, 1, 2.5, 10, 77.7):
    t.raw('MOVE "WIND_CHARGE" TO WS-LAYER', 'CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([age]); t.raw('CALL "EF9-WIND-ANIM" USING EMM-MODEL WS-IN')
    t.cur('wind_charge', 'yrot', -age * 16 * D); t.cur('wind', 'yrot', age * 16 * D)
    t.cur('wind', 'xrot', 0); t.cur('bone', 'yrot', 0)
for age in (0, 1, 10, 33.34, 100, 1234.5):
    t.call('EF9-WIND-SCROLL', [age], [(age * 0.03) % 1.0], '6.2 texture offset u at age %s' % age)
save9(t, 5)
