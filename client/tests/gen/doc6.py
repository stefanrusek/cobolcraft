import re
from g4 import REPO,DOCS
NUM=r'(-?[0-9]+(?:\.[0-9]+)?(?:E-?[0-9]+)?)'
def _lines(ch): return open(REPO+DOCS[ch]).read().split('\n')
def triple(s):
    m=re.search(r'\(\s*'+NUM+r'\s*,\s*'+NUM+r'\s*,\s*'+NUM+r'\s*\)',s)
    return [m.group(i) for i in (1,2,3)] if m else None
def table(ch,heading,nth=0):
    """cells of the nth table after the line starting with heading: list of [cell,...] (header and rule rows dropped)"""
    L=_lines(ch)
    s=[i for i,l in enumerate(L) if l.startswith(heading)][0]
    tabs=[];cur=None
    for l in L[s+1:]:
        if l.startswith('## ') or (l.startswith('### ') and not tabs and False): break
        if l.startswith('|'):
            c=[x.strip() for x in l.strip().strip('|').split('|')]
            if cur is None: cur=[]; tabs.append(cur)
            cur.append(c)
        else:
            cur=None
        if len(tabs)>nth and cur is None: break
    t=tabs[nth]
    return [r for r in t[2:]], [x.lower() for x in t[0]]
def rows_from(ch,heading,nth=0,D='0',parents=None):
    """convert a part table with columns Part, pivot, [rot], box, tex, grow: P and C rows (one cuboid per part)"""
    t,hd=table(ch,heading,nth)
    ib=[i for i,h in enumerate(hd) if h.startswith('box')][0]
    ipv=[i for i,h in enumerate(hd) if h.startswith('pivot')]
    irot=[i for i,h in enumerate(hd) if h.startswith('rot')]
    itex=[i for i,h in enumerate(hd) if h.startswith('tex')][0]
    igrow=[i for i,h in enumerate(hd) if h.startswith('grow')]
    out=[];prevbox=None
    for c in t:
        path=c[0].replace('`','').split()[0]
        comps=path.split('/'); name=comps[-1]
        par=re.search(r'child of (\w+)',c[0])
        parent=par.group(1) if par else (comps[-2] if len(comps)>1 else (parents or {}).get(name,'root'))
        pv=triple(c[ipv[0]]) if ipv else None
        pv=pv or ['0','0','0']
        rot=triple(c[irot[0]]) if irot and triple(c[irot[0]]) else ['0','0','0']
        out.append('P %s %s %s %s'%(name,parent,' '.join(pv),' '.join(rot)))
        cell=c[ib]
        if cell.strip().lower().startswith('none') or cell.strip().startswith('(no cubes'): continue
        if triple(cell) is None and prevbox: cell=prevbox
        prevbox=cell
        o=triple(cell)
        sz=re.search(NUM+r'\s*x\s*'+NUM+r'\s*x\s*'+NUM,cell)
        tx=re.search(r'\(\s*'+NUM+r'\s*,\s*'+NUM+r'\s*\)',c[itex])
        g='0'; mir='1' if any('mirror' in x.lower() for x in c[1:]) else '0'
        if igrow:
            gc=c[igrow[0]]
            if gc.strip()=='d': g=D
            else:
                m=re.search(r'grow\s+'+NUM,gc)
                if m: g=m.group(1)
        out.append('C %s %s %s %s %s %s %s %s %s'%(name,tx.group(1),tx.group(2),' '.join(o),sz.group(1),sz.group(2),sz.group(3),g,mir))
    return out
if __name__=='__main__':
    for r in rows_from(6,'### 2.1'): print(r)
    for r in rows_from(6,'### 3.1'): print(r)
    for r in rows_from(6,'### 6.1')[:6]: print(r)
