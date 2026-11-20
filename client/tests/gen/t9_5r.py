from rt9 import *
import math, re
D = 0.017453292
def mrows(heading, parent_of=None):
    rows = []
    for r in table9(heading):
        n = r['part'].replace('`', '')
        rows.append('P %s %s 0 0 0 0 0 0' % (n, (parent_of or {}).get(n, 'root')))
        sz = re.match(r'\s*' + NUMR + r' x ' + NUMR + r' x ' + NUMR, r['size']).groups()
        tx = re.search(r'\((\d+), (\d+)\)', r['tex']).groups()
        rows.append('C %s %s %s %s %s 0 %d' % (n, tx[0], tx[1], ' '.join(triple(r['cuboid origin'])), ' '.join(sz), 1 if r['mirror'] == 'yes' else 0))
    return rows
trident = mrows('### 5.1', dict(base='pole', left_spike='pole', middle_spike='pole', right_spike='pole'))
def wind(age):
    rows = ['P bone root 0 0 0 0 0 0']
    for r in table9('### 6.1'):
        n = r['part'].replace('`', '')
        yrot = (-age * 16 * D) if n == 'wind_charge' else (age * 16 * D)
        rows.append('P %s bone 0 0 0 0 %s 0' % (n, lit(yrot)))
        for tx, bx in zip(re.findall(r'\((\d+), (\d+)\)', r['tex']), r['cuboids'].split(';')):
            sz = re.search(NUMR + r' x ' + NUMR + r' x ' + NUMR, bx).groups()
            rows.append('C %s %s %s %s %s 0 0' % (n, tx[0], tx[1], ' '.join(triple(bx)), ' '.join(sz)))
    return rows
txt16 = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('Model (texture 64 x 64; layer `CUSHION`)')][0]
m = re.search(r'tex \((\d+), (\d+)\), cuboid origin \(([^)]*)\) size (\d+) x (\d+) x (\d+) with deformation \*\*(-?[0-9.]+)\*\*[^,]*, pose off \(([^)]*)\)', txt16)
cu = m.groups()
cushion = ['P cushion root %s 0 0 0' % ' '.join(x.strip() for x in cu[7].split(',')), 'C cushion %s %s %s %s %s %s %s 0' % (cu[0], cu[1], ' '.join(x.strip() for x in cu[2].split(',')), cu[3], cu[4], cu[5], cu[6])]
txt12 = [l for l in open(REPO + DOCS[9]).read().split('\n') if l.startswith('Model (texture 32 x 32; layer `LEASH_KNOT`)')][0]
k = re.search(r'tex \((\d+), (\d+)\), cuboid origin \(([^)]*)\) size (\d+) x (\d+) x (\d+)', txt12).groups()
knot = ['P knot root 0 0 0 0 0 0', 'C knot %s %s %s %s %s %s 0 0' % (k[0], k[1], ' '.join(x.strip() for x in k[2].split(',')), k[3], k[4], k[5])]
t = RT('TEST-ENTITY-NONLIVING-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 5.2, 6, 12 and 16 through the renderer: the trident, the wind charges, the lead knot and the cushion are rows of CLMODELS (family 9) and draw",
   "their models posed by the document's submit (the extent of the vertices is computed by gen/rt9.py from the document's part tables): trident rotate Y by yaw - 90 and Z by pitch + 90, wind charge no transform with both models turning 16 degrees a tick",
   "(the pose rotation of `wind` replaced), knot scale (-1, -1, 1), cushion rotate Y by 180 - the direction's yaw, X by 180 and translate (0, -0.25, 0)."])
t.start()
for yaw, pitch in ((0, 0), (90, 30), (-45, -60), (200, 15)):
    t.spawn('trident', yaw, pitch, 9)
    t.mesh()
    t.extent('34-9§5.2 trident yaw %s pitch %s' % (yaw, pitch), extent(vertices(trident, [(3, yaw - 90, 0, 0), (7, pitch + 90, 0, 0)]), (0.5, 0, 0.5)), 180)
for key in ('wind_charge', 'breeze_wind_charge'):
    for ticks in (0, 1, 5):
        t.spawn(key, 0, 0, 11)
        for _ in range(ticks): t.raw('CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE')
        t.mesh()
        t.extent('34-9§6 %s after %d ticks' % (key, ticks), extent(vertices(wind(ticks), []), (0.5, 0, 0.5)), 108)
for yaw in (0, 90, -90, 180):
    t.spawn('leash_knot', yaw, 0, 12)
    t.mesh()
    t.extent('34-9§12 leash_knot yaw %s' % yaw, extent(vertices(knot, [(2, -1, -1, 1)]), (0.5, 0, 0.5)), 36)
for yaw in (0, 44, 45, 90, 135, 180, 225, 270, -90, -46):
    data = math.floor(yaw / 90 + 0.5) % 4
    t.spawn('cushion', yaw, 0, 13)
    t.mesh()
    t.extent('34-9§16 cushion yaw %s (direction data %d)' % (yaw, data), extent(vertices(cushion, [(3, 180 - data * 90, 0, 0), (5, 180, 0, 0), (1, 0, -0.25, 0)]), (0.5, 0, 0.5)), 36)
t.save('test_entity_nonliving_9')
