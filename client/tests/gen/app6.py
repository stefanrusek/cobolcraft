import re
from g4 import REPO,DOCS
def parse(ch,start_heading,end_heading=None):
    """keyframe tables of 34-6 (8.6, 9.5): '**NAME**: length L s, looping X' then rows | `bone` | rotation/position/scale | t: x, y, z; ... [L] |"""
    L=open(REPO+DOCS[ch]).read().split('\n')
    s=[i for i,l in enumerate(L) if l.startswith(start_heading)][0]
    anims=[];cur=None
    for l in L[s+1:]:
        if l.startswith('## ') or (end_heading and l.startswith(end_heading)): break
        m=re.match(r'\*\*`?([A-Z_0-9]+)`?\*\*[^:]*: length ([0-9.]+) s, looping (true|false|yes|no)',l)
        if m:
            cur={'name':m.group(1),'length':m.group(2),'loop':1 if m.group(3) in('true','yes') else 0,'ch':[]}; anims.append(cur); continue
        if cur is not None and l.startswith('| `'):
            c=[x.strip() for x in l.strip().strip('|').split('|')]
            keys=[]
            for piece in c[2].split(';'):
                piece=piece.strip()
                mm=re.match(r'^(-?[0-9.]+): (-?[0-9.]+), (-?[0-9.]+), (-?[0-9.]+)( L)?$',piece)
                assert mm,(l[:80],piece)
                keys.append((mm.group(1),mm.group(2),mm.group(3),mm.group(4),1 if mm.group(5) else 2))
            cur['ch'].append({'bone':c[0].replace('`',''),'target':{'position':1,'rotation':2,'scale':3}[c[1]],'keys':keys})
    return anims
if __name__=='__main__':
    for a in parse(6,'### 8.6'): print(a['name'],a['length'],a['loop'],len(a['ch']),sum(len(c['keys']) for c in a['ch']),max(len(c['keys']) for c in a['ch']))
    for a in parse(6,'### 9.5'): print(a['name'],a['length'],a['loop'],len(a['ch']),sum(len(c['keys']) for c in a['ch']),max(len(c['keys']) for c in a['ch']))
