from g9 import *
import math
D = 0.017453292
t = mk9(17, ["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 17 (display entities): the billboard orientation table (the four constraints, Validation 11), the brightness override unpacked, the item display's Y rotation, the text display's flag bits,",
             "layout (line height 10, height = lines x 10 - 1, translate (1 - width / 2, -height), the default background's alpha 63) and the lines' x for the three alignments, with the worked example of two lines of widths 40 and 60 centred, and the text colour."], title='display entities')
doc = open(REPO + DOCS[9]).read()
tab = doc[doc.index('| Constraint (id, 44 part 9) | yaw | pitch |'):]
rows = [r for r in tab.split('\n')[2:6]]
def orient(c, ey, ex, cy, cx):
    camy = cy - 180; camx = -cx
    return [(-D * ey, D * ex), (-D * camy, D * ex), (-D * ey, D * camx), (-D * camy, D * camx)][c]
for r in rows: assert r.startswith('| ')   # fixed (0), vertical (1), horizontal (2), center (3), in this order (checked below against the cells)
cells = [[x.strip() for x in r.strip().strip('|').split('|')] for r in rows]
assert 'fixed' in cells[0][0] and 'vertical' in cells[1][0] and 'horizontal' in cells[2][0] and 'center' in cells[3][0]
assert '-D * entityYRot' in cells[0][1] and 'cameraYRot - 180' in cells[1][1] and 'entityYRot' in cells[2][1] and 'cameraYRot - 180' in cells[3][1]
for c in range(4):
    for ey, ex, cy, cx in ((90, 0, 0, 0), (0, 30, 45, -20), (-135, 15, 200, 60), (270, -45, -90, 80)):
        y, p = orient(c, ey, ex, cy, cx)
        t.call('EF9-DISPLAY-ORIENT', [c, ey, ex, cy, cx], [y, p], '17.1 constraint %d entity (%s, %s) camera (%s, %s) (yaw, pitch)' % (c, ey, ex, cy, cx))
t.call('EF9-DISPLAY-ORIENT', [0, 90, 0, 0, 0], [-1.5707964, 0], '17 Validation 11: fixed with entityYRot 90 gives yaw -1.5707964, pitch 0')
for packed, bl, sk in ((-1, 3, 9), (15728880, 3, 9), (0, 15, 15), (15728850, 1, 1), ((7 << 4) | (2 << 20), 0, 0)):
    exp = [bl, sk] if packed == -1 else [(packed >> 4) & 15, (packed >> 20) & 15]
    t.call('EF9-DISPLAY-LIGHT', [packed, bl, sk], exp, '17.1 override %d level (%d, %d) (block, sky)' % (packed, bl, sk))
t.call('EF9-DISPLAY-ITEM-OPS', [], [1, 3, 180, 0, 0], '17.3 the item display rotates about Y by pi')
t.call('EF9-DISPLAY-BLOCK-OPS', [], [0], '17.2 the block display adds no transform')
for flags in (0, 1, 2, 4, 8, 16, 3, 5, 9, 17, 24, 31, 6, 12):
    align = 0 if flags & 8 else 1 if flags & 16 else 2
    t.call('EF9-TEXT-FLAGS', [flags], [1 if flags & 2 else 0, 1 if flags & 1 else 0, 1 if flags & 4 else 0, align], '17.4 flags %d (see-through, shadow, default background, alignment 0 left 1 right 2 centre)' % flags)
for flags, lines, width in ((0, 1, 40), (4, 2, 60), (1, 3, 91), (5, 5, 7)):
    lh = 10; h = lines * lh - 1
    t.call('EF9-TEXT-LAYOUT', [flags, lines, width], [lh, h, 1 - width / 2, -h, int(0.25 * 255) if flags & 4 else 0], '17.4 layout flags %d lines %d width %d' % (flags, lines, width))
def linex(flags, w, lw):
    if flags & 8: return 0
    if flags & 16: return w - lw
    return w / 2 - lw / 2
for flags in (0, 8, 16, 24):
    for w, lw, idx in ((60, 40, 0), (60, 60, 1), (91, 17, 2), (10, 0, 3)):
        t.call('EF9-TEXT-LINE', [flags, w, lw, idx], [linex(flags, w, lw), idx * 10], '17.4 line %d of width %d in a block of %d, flags %d (x, y)' % (idx, lw, w, flags))
# worked example: widths 40 and 60 centred, defaults: width 60, height 19, translate (-29, -19), x 10 and 0, y 0 and 10
t.call('EF9-TEXT-LAYOUT', [0, 2, 60], [10, 19, -29, -19, 0], '17.4 worked example layout')
t.call('EF9-TEXT-LINE', [0, 60, 40, 0], [10, 0], '17.4 worked example first line')
t.call('EF9-TEXT-LINE', [0, 60, 60, 1], [0, 10], '17.4 worked example second line')
assert abs((-29 * 0.025) - (-0.725)) < 1e-9 and abs((-29 + 60) * 0.025 - 0.775) < 1e-9 and abs(19 * 0.025 - 0.475) < 1e-9
for op in (0, 25, 26, 127, 128, 200, 255, 256, -1):
    b = op & 255; b = b - 256 if b >= 128 else b
    t.call('EF9-TEXT-COLOR', [op], [(b & 255) * 16777216 + 16777215, b], '17.4 text colour of opacity %d (ARGB unsigned, narrowed byte)' % op)
save9(t, 17)
