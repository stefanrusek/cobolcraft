import re,sys
NUM=r'(-?[0-9]+(?:\.[0-9]+)?)'
def tri(s,key=None):
    m=re.findall(NUM,s); return m[:3]
def parse(path,start=1,end=10**9):
    """returns dict layer -> dict(tex=(w,h), scale=..., rows=[...]) parsing 'Layer `x`' headings and 'Part path' tables"""
    L=open(path).read().split('\n')
    layers=[];cur=None;tex=None
    i=0
    while i<len(L):
        ln=L[i]
        m=re.match(r'Layer `([a-z_]+)`',ln)
        if m: pend=m.group(1); pendline=ln
        t=re.match(r'Texture size (\d+) x (\d+)',ln)
        if t: tex=(t.group(1),t.group(2)); 
        if ln.startswith('| Part path'):
            rows=[];j=i+2
            while j<len(L) and L[j].startswith('|'):
                c=[x.strip() for x in L[j].strip().strip('|').split('|')]
                path_=c[0].replace('`','')
                parts=path_.split('/')
                name=parts[-1]; parent=parts[-2] if len(parts)>1 else 'root'
                piv=tri(c[1]); rot=tri(c[2])
                rows.append('P %s %s %s %s'%(name,parent,' '.join(piv),' '.join(rot)))
                for cu in c[3].split('<br>'):
                    cu=cu.strip()
                    if not cu or cu.startswith('none') or cu.startswith('(none'): continue
                    mt=re.search(r'tex \(\s*'+NUM+r',\s*'+NUM+r'\)',cu)
                    o=re.search(r' o \(([^)]*)\)',cu); s=re.search(r' s \(([^)]*)\)',cu)
                    g=re.search(r'grow\s+'+NUM,cu)
                    assert o and s,(cu,L[j][:100])
                    ov=[x.strip() for x in o.group(1).split(',')]; sv=[x.strip() for x in s.group(1).split(',')]
                    rows.append('C %s %s %s %s %s %s %s'%(name,mt.group(1),mt.group(2),' '.join(ov),' '.join(sv),g.group(1) if g else '0','1' if 'mirror' in cu else '0'))
                j+=1
            layers.append(dict(name=pend,tex=tex,rows=rows,line=i+1))
            i=j; continue
        i+=1
    return layers
if __name__=='__main__':
    for l in parse(sys.argv[1]):
        r=l['rows']; print(l['name'],l['tex'],l['line'],'parts',sum(1 for x in r if x[0]=='P'),'cubes',sum(1 for x in r if x[0]=='C'))
