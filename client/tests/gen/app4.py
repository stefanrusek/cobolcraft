import re
from g4 import REPO,DOCS
def parse(part):
    """part 'A.1'..'A.4': returns list of dict(name,length,loop,ch=[dict(bone,target,keys=[(t,x,y,z,inter)])])"""
    L=open(REPO+DOCS[4]).read().split('\n')
    s=[i for i,l in enumerate(L) if l.startswith('### '+part+' ')][0]
    anims=[];cur=None
    for l in L[s+1:]:
        if l.startswith('### ') or l.startswith('## '): break
        m=re.match(r'#### ([A-Z_]+)\s+length ([0-9.]+) s(, looping)?',l)
        if m:
            cur={'name':m.group(1),'length':m.group(2),'loop':1 if m.group(3) else 0,'ch':[]}; anims.append(cur); continue
        if cur is not None and l.startswith('| ') and not l.startswith('| Bone'):
            c=[x.strip() for x in l.strip().strip('|').split('|')]
            keys=[]
            for mm in re.finditer(r'([-0-9.E]+):\(([^)]*)\)(~?)',c[2]):
                v=[x.strip() for x in mm.group(2).split(',')]
                keys.append((mm.group(1),v[0],v[1],v[2],2 if mm.group(3) else 1))
            cur['ch'].append({'bone':c[0],'target':{'POSITION':1,'ROTATION':2,'SCALE':3}[c[1]],'keys':keys})
    return anims
if __name__=='__main__':
    for p in ('A.1','A.2','A.3','A.4'):
        for a in parse(p): print(p,a['name'],a['length'],a['loop'],len(a['ch']),max((len(c['keys']) for c in a['ch']),default=0))
