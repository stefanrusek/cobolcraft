# Render tests of 34-9 entities: spawn the entity in a standard-set client, mesh it and compare the extent of its vertices (thousandths of a block,
# relative to the eye) with the extent computed here from the document's part table and the document's render pose (a Python version of the pipeline:
# per part scale, rotate X, Y, Z (rotationZYX), translate by the pose, / 16, then the pose operations last to first).
import math, re
from g9 import *
def rotx(p, a): c, s = math.cos(a), math.sin(a); return (p[0], p[1] * c - p[2] * s, p[1] * s + p[2] * c)
def roty(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c + p[2] * s, p[1], p[2] * c - p[0] * s)
def rotz(p, a): c, s = math.cos(a), math.sin(a); return (p[0] * c - p[1] * s, p[0] * s + p[1] * c, p[2])
def parse_rows(rows):
    parts = {}; order = []
    for r in rows:
        x = r.split()
        if x[0] == 'P':
            parts[x[1]] = dict(parent=x[2], off=[float(v) for v in x[3:6]], rot=[float(v) for v in x[6:9]], sc=[float(v) for v in x[9:12]] if len(x) >= 12 else [1, 1, 1], cubes=[])
            order.append(x[1])
        else:
            parts[x[1]]['cubes'].append([float(v) for v in x[2:]])
    return parts, order
def corners(c):
    ox, oy, oz, w, h, d, g = c[2:9]
    x0, y0, z0, x1, y1, z1 = ox - g, oy - g, oz - g, ox + w + g, oy + h + g, oz + d + g
    return [(x, y, z) for x in (x0, x1) for y in (y0, y1) for z in (z0, z1)]
def vertices(rows, ops, rootscale=1):
    parts, order = parse_rows(rows)
    out = []
    for n in order:
        for c in parts[n]['cubes']:
            for p in corners(c):
                q = p; node = n
                while node != 'root':
                    pt = parts[node]
                    q = (q[0] * pt['sc'][0], q[1] * pt['sc'][1], q[2] * pt['sc'][2])
                    q = rotx(q, pt['rot'][0]); q = roty(q, pt['rot'][1]); q = rotz(q, pt['rot'][2])
                    q = (q[0] + pt['off'][0], q[1] + pt['off'][1], q[2] + pt['off'][2])
                    node = pt['parent']
                q = (q[0] / 16, q[1] / 16, q[2] / 16)
                for op in reversed(ops):
                    code, a, b, cc = op
                    if code == 1: q = (q[0] + a, q[1] + b, q[2] + cc)
                    elif code == 2: q = (q[0] * a, q[1] * b, q[2] * cc)
                    elif code == 3: q = roty(q, math.radians(a))
                    elif code == 5: q = rotx(q, math.radians(a))
                    elif code == 7: q = rotz(q, math.radians(a))
                    else: raise Exception(code)
                out.append(q)
    return out
def extent(vs, origin):
    """min and max x, y, z of the vertices plus origin (entity position less eye), in thousandths rounded half up as E9-RANGE does"""
    r = []
    for k in range(3):
        v = [p[k] + origin[k] for p in vs]
        r += [math.floor(min(v) * 1000 + 0.5), math.floor(max(v) * 1000 + 0.5)]
    return r
HEAD_RT = """ WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 7.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-FIRST               BINARY-LONG VALUE 1.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
"""
class RT:
    def __init__(self, pid, header):
        self.pid = pid; self.header = header; self.body = []; self.extra = ''
    def raw(self, *l):
        for x in l: self.body.append('     ' + x)
    def start(self):
        self.raw('CALL "CL-INIT" USING CLIENT-STATE', 'MOVE 0 TO PK-COUNT', 'CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE', 'MOVE 256 TO PL-HEIGHT', 'MOVE 0 TO SK-U',
                 'MOVE 10 TO WS-EYE(1) WS-EYE(3)', 'MOVE 64 TO WS-EYE(2)', 'MOVE 1 TO CT-OPEN', 'MOVE CT-TYPE-STANDARD TO CT-SET-TYPE', 'MOVE "N" TO TL-MODE')
    def check(self, name, exp, obs):
        self.raw('MOVE "%s" TO TL-CASE' % name.replace('"', "'"), 'MOVE %s TO TL-EXPECTED-N' % exp, 'MOVE %s TO TL-OBSERVED-N' % obs, 'CALL "TEST-ASSERT" USING TESTLIB-ASSERT')
    def spawn(self, key, yaw=0, pitch=0, ident=7):
        self.raw('CALL "ENTITIES-CLEAR" USING CLIENT-STATE', 'MOVE 0 TO EA-MT-COUNT', 'MOVE SPACES TO WS-KEY', 'MOVE "%s" TO WS-KEY' % key,
                 'CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS', 'MOVE %d TO WS-ID' % ident, 'MOVE %s TO WS-YAW' % lit(yaw), 'MOVE %s TO WS-PITCH' % lit(pitch),
                 'CALL "E9-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PITCH')
    def mesh(self):
        self.raw('CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE', 'MOVE RL-EN-COUNT TO WS-LAST', 'CALL "E9-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE')
    def gimesh(self, count=None, item=4):
        self.raw('MOVE %d TO EN-STACK-ITEM(1)' % item)
        if count is not None: self.raw('MOVE %d TO EN-STACK-COUNT(1)' % count)
        self.raw('CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE', 'MOVE RL-GI-COUNT TO WS-LAST', 'CALL "E9-GIRANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE')
    def extent(self, name, ext, n=None, count='RL-EN-COUNT'):
        if n is not None: self.check(name + ' vertices', n, count)
        for k, lab in enumerate(('min x', 'max x', 'min y', 'max y', 'min z', 'max z')):
            self.check('%s %s (thousandths)' % (name, lab), ext[k], 'WS-R(%d)' % (k + 1))
    def render(self):
        o = ['*> ' + h for h in self.header]
        o += [' IDENTIFICATION DIVISION.', ' PROGRAM-ID. %s.' % self.pid, ' DATA DIVISION.', HEAD_RT.rstrip('\n') + self.extra, ' PROCEDURE DIVISION.'] + self.body + ['     STOP RUN.', ' END PROGRAM %s.' % self.pid, ' COPY ENT9TEST.', ' COPY CLTEST.', '']
        return '\n'.join(o)
    def save(self, name):
        open(REPO + 'client/tests/%s.cob' % name, 'w').write(self.render())
