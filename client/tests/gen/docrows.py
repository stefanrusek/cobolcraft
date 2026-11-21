import re,sys
NUM=r'(-?[0-9]+(?:\.[0-9]+)?(?:E-?[0-9]+)?)'
def tri(s,key):
    m=re.search(key+r'\s*\(\s*'+NUM+r'\s*,\s*'+NUM+r'\s*,\s*'+NUM+r'\s*\)',s)
    return [m.group(i) for i in (1,2,3)] if m else None
def fmt(x):
    return x
def rows(path,start,end,gsym=None):
    """parse table rows of lines start..end (1-based, inclusive); return list of row strings"""
    out=[]
    L=open(path).read().split('\n')[start-1:]
    began=False
    for ln in L:
        if not ln.startswith('|'):
            if began: break
            continue
        if ln.startswith('| Part'): began=True
        if not began: continue
        c=[x.strip() for x in ln.strip().strip('|').split('|')]
        if len(c)<4 or c[0] in('Part',) or set(c[0])<=set('-'): continue
        name=re.sub(r'\s*\(.*\)','',c[0]).replace('`','').strip()
        parent=c[1].replace('`','')
        if parent=='layer root': parent='root'
        off=tri(c[2],'off') or ['0','0','0']
        rot=tri(c[2],'rot') or ['0','0','0']
        out.append('P %s %s %s %s'%(name,parent,' '.join(fmt(x) for x in off),' '.join(fmt(x) for x in rot)))
        cub=c[3]
        if cub.startswith('none'): continue
        for piece in cub.split(';'):
            t=re.search(r'tex\s*\(\s*'+NUM+r'\s*,\s*'+NUM+r'\s*\)',piece)
            if not t: continue
            o=tri(piece,'origin'); s=tri(piece,'size')
            g=re.search(r'grow\s+'+NUM,piece); gv=fmt(g.group(1)) if g else '0'
            mir='1' if 'mirror' in piece else '0'
            out.append('C %s %s %s %s %s %s %s'%(name,fmt(t.group(1)),fmt(t.group(2)),' '.join(fmt(x) for x in o),' '.join(fmt(x) for x in s),gv,mir) )
    return out
if __name__=='__main__':
    for r in rows(sys.argv[1],int(sys.argv[2]),0): print(r)
