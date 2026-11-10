import re
from g4 import REPO,DOCS
NUM=r'(-?[0-9]+(?:\.[0-9]+)?(?:E-?[0-9]+)?)'
def tables(ch=5):
    L=open(REPO+DOCS[ch]).read().split('\n')
    out=[];i=0;prev=''
    while i<len(L):
        ln=L[i]
        if ln.startswith('| Part path') and 'Cubes' in ln:
            rows=[];j=i+2
            while j<len(L) and L[j].startswith('|'):
                rows.append(L[j]); j+=1
            out.append(dict(line=i+1,prev=prev,rows=rows)); i=j; continue
        if ln.strip() and not ln.startswith('|'): prev=ln
        i+=1
    return out
def conv(rows,D='0'):
    out=[]
    for ln in rows:
        c=[x.strip() for x in ln.strip().strip('|').split('|')]
        path=c[0].replace('`','').strip(); parts=path.split('/'); name=parts[-1]; parent=parts[-2] if len(parts)>1 else 'root'
        pos=re.search(r'pos\(([^)]*)\)',c[1]); rot=re.search(r'rot\(([^)]*)\)',c[1])
        p=[x.strip() for x in pos.group(1).split(',')] if pos else ['0','0','0']
        r=[x.strip() for x in rot.group(1).split(',')] if rot else ['0','0','0']
        out.append('P %s %s %s %s'%(name,parent,' '.join(p),' '.join(r)))
        if c[2].startswith('(no cubes') or c[2]=='-': continue
        for piece in c[2].split(';'):
            piece=piece.strip()
            m=re.match(r'\[\s*'+NUM+r'\s*,\s*'+NUM+r'\s*\]\s*\(([^)]*)\)\s*'+NUM+r'\s*[×x]\s*'+NUM+r'\s*[×x]\s*'+NUM+r'(.*)',piece)
            assert m,(ln,piece)
            o=[x.strip() for x in m.group(3).split(',')]
            rest=m.group(7)
            g=re.search(r'grow\s+(\S+)',rest)
            gv='0'
            if g:
                gv=g.group(1).strip(',;')
                gv=D if gv=='D' else gv
            out.append('C %s %s %s %s %s %s %s %s'%(name,m.group(1),m.group(2),' '.join(o),m.group(4),m.group(5),m.group(6),gv)+(' %d'%(1 if 'mirror' in rest else 0)))
    return out
if __name__=='__main__':
    for t in tables(): 
        try: r=conv(t['rows']); print(t['line'],t['prev'][:70],len(r))
        except AssertionError as e: print('FAIL',t['line'],str(e)[:200])
