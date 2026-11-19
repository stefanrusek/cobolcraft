from rt9 import *
import math
rows = []
for r in table9('### 4.1'):
    n = r['part'].replace('`', '')
    pose = r['pose']
    off = triple(re.search(r'off (\([^)]*\))', pose).group(1)) if 'off' in pose else ['0', '0', '0']
    rot = rot_cell(pose)
    sc = re.search(r'scale ' + NUMR, pose)
    s = sc.group(1) if sc else '1'
    sz = re.match(r'\s*' + NUMR + r' x ' + NUMR + r' x ' + NUMR, r['size']).groups()
    rows.append('P %s root %s %s %s %s %s' % (n, ' '.join(off), ' '.join(rot), s, s, s))
    rows.append('C %s 0 0 %s %s 0 0' % (n, ' '.join(triple(r['cuboid origin'])), ' '.join(sz)))
t = RT('TEST-ENTITY-ARROW-9', ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 4 through the renderer: an arrow draws the three planes of 4.1 (the back plane at (-11, 0, 0) turned 45 degrees at scale 0.8, the two cross planes at 45 and 135 degrees)",
   "both sides each (6 quads, 36 vertices) under the model's own scale 0.9, turned by the submit of 4.2 (rotate Y by yRot - 90, rotate Z by xRot); the extent of the vertices is computed from the document's part table by gen/rt9.py."])
t.start()
for key in ('arrow', 'spectral_arrow'):
    for yaw, pitch in ((0, 0), (90, 0), (-135, 30), (45, -60), (200, 15)):
        t.spawn(key, yaw, pitch, 21)
        t.mesh()
        t.extent('34-9§4.2 %s yaw %s pitch %s' % (key, yaw, pitch), extent(vertices(rows, [(3, yaw - 90, 0, 0), (7, pitch, 0, 0), (2, 0.9, 0.9, 0.9)]), (0.5, 0, 0.5)), 36)
t.save('test_entity_arrow_9')
