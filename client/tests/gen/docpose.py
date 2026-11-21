# Part tables of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md sections 3 to 7: columns Part, [Parent,] Pose, Boxes.
# Pose is "off(x,y,z)" and/or "rot(x,y,z)" or "identity"; a Boxes cell is "none" or boxes separated by ";" (tex(u,v) origin(x,y,z) size(w,h,d), optional "grow g", "mirror", "G"),
# a box without tex(...) repeats the previous texture offset. Output rows are those of doc8.py: "P name parent x y z rx ry rz" and "C name u v ox oy oz w h d grow mirror".
import re
from doc8 import table, NUM
TRI = r'\(\s*' + NUM + r'\s*,\s*' + NUM + r'\s*,\s*' + NUM + r'\s*\)'
def tri(s, key):
    m = re.search(key + TRI, s)
    return [m.group(i) for i in (1, 2, 3)] if m else ['0', '0', '0']
def rows_pose(heading, nth=0, parent='root', rename=None, G='0.001', allgrow=None, rootname=None):
    t, hd = table(8, heading, nth)
    out = []
    ip = hd.index('part'); iparent = hd.index('parent') if 'parent' in hd else None
    ipose = hd.index('pose'); ibox = hd.index('boxes')
    for c in t:
        name = c[ip].replace('`', '').split()[0]
        par = c[iparent].replace('`', '') if iparent is not None else parent
        if rename:
            name = rename.get(name, name); par = rename.get(par, par)
        if rootname:
            if name == 'root': name = rootname
            elif par == 'root': par = rootname
        pose = c[ipose]
        out.append('P %s %s %s %s' % (name, par, ' '.join(tri(pose, 'off')), ' '.join(tri(pose, 'rot'))))
        cell = c[ibox]
        if cell.strip().lower().startswith('none'):
            continue
        last = None
        for bx in cell.split(';'):
            tx = re.search(r'tex\(\s*' + NUM + r'\s*,\s*' + NUM + r'\s*\)', bx)
            if tx: last = (tx.group(1), tx.group(2))
            o = tri(bx, 'origin'); sz = tri(bx, 'size')
            g = re.search(r'grow\s+' + NUM, bx)
            grow = g.group(1) if g else ('0' if allgrow is None else allgrow)
            if re.search(r'\bG\b', bx): grow = G
            mir = '1' if 'mirror' in bx else '0'
            out.append('C %s %s %s %s %s %s %s' % (name, last[0], last[1], ' '.join(o), ' '.join(sz), grow, mir))
    return out
if __name__ == '__main__':
    for h in ('### 3.1', '### 4.1', '### 5.1', '### 6.1', '### 7.1'):
        r = rows_pose(h); print(h, len(r)); print('\n'.join(r[:5]))
