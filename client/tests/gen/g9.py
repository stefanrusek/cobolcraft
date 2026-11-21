# Helpers of the acceptance tests of docs/protocol/34-entity-models-9-non-living-entities.md (client/tests/test_entmodel_34_9_<n>.cob).
# The expected values are read from the document's tables (table9) or computed by the document's formulas in Python; the library
# programs they check (client/src/entmodel-34-9*.cob) are written by hand from the same text.
import re
from g4 import *
import doc8
NUMR = doc8.NUM
def table9(heading, nth=0):
    """the nth table after the heading: list of dicts keyed by the lower-cased header cells"""
    rows, hd = doc8.table(9, heading, nth)
    return [dict(zip(hd, r)) for r in rows]
def nums(s):
    return [float(x) for x in re.findall(NUMR, s)]
def triple(s):
    m = re.search(r'\(\s*' + NUMR + r'\s*,\s*' + NUMR + r'\s*,\s*' + NUMR + r'\s*\)', s)
    return [m.group(i) for i in (1, 2, 3)] if m else None
def pose_cell(s):
    """'(0, 4, 0)' -> offset; 'xRot = 1.57' / 'yRot = ..' / 'zRot' -> rotation; 'none' -> zero"""
    return triple(s) or ['0', '0', '0']
def rot_cell(s):
    r = ['0', '0', '0']
    for k, ax in enumerate(('xRot', 'yRot', 'zRot')):
        m = re.search(ax + r'\s*=\s*' + NUMR, s)
        if m: r[k] = m.group(1)
    return r
class T9(T):
    """cases are named 'acceptance US15 34-9§<n> <title>: <name>' (the review command of T3554 greps that text); sec() changes <n> and <title> for the cases that follow"""
    def sec(self, n, title):
        self.prefix = 'acceptance US15 34-9§%s %s' % (n, title)
        self.raw('MOVE "%s" TO WS-PFX' % self.prefix)
    def render(self):
        s = T.render(self)
        s = s.replace(' 01 WS-NAME                PIC X(160).', ' 01 WS-NAME                PIC X(160).\n 01 WS-PFX                 PIC X(100).', 1)
        s = s.replace('STRING "%s: " FUNCTION TRIM(WS-NAME)' % self.prefix0, 'STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME)')
        s = s.replace(' PROCEDURE DIVISION.\n', ' PROCEDURE DIVISION.\n     MOVE "%s" TO WS-PFX\n' % self.prefix0, 1)
        return s
def mk9(n, header, extra='', title='entity models'):
    t = T9('TEST-ENTMODEL-34-9-%d' % n, 'acceptance US15 34-9§%d %s' % (n, title), header, extra_ws=WSX + extra, ck=True)
    t.prefix0 = t.prefix
    t.LP = 'EF9-LAYER'
    return t
def save9(t, n):
    open(REPO + 'client/tests/test_entmodel_34_9_%d.cob' % n, 'w').write(t.render())
def layer_check(t, layer, rows, w, h, tag):
    t.build(layer)
    t.rows('%s %s' % (t.prefix, tag + ' ' + layer), rows)
    p, c = sizes(rows)
    t.stats('%s %s' % (tag, layer), p, c, float(w), float(h))
