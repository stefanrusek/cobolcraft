import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
# Shared helpers of the generators of the menu tests (gen40_2, gen40_3, gen40_4): independent Python models of docs/protocol/40-menus-2..4.
OUT="core/tests"
def S(*a): return " ".join(str(x) for x in a)
def show(*v): return "/".join(str(x) for x in v)
class Gen10(Gen):
    # the shown outputs hold ten digits (2147483647)
    def write(self, path):
        Gen.write(self, path)
        t=open(path).read().replace("PIC -(9)9.","PIC -(10)9.")
        open(path,'w').write(t)
def GG(prog,sec,subj,tasks,desc,path):
    return Gen10(prog,sec,subj,'Test of %s section, %s (%s): %s'%(sec,subj,tasks,desc),' 01 WS-NM                PIC X(32).\n')
def C(name,ins,nout):
    toks=[]
    for j,c in enumerate(ins): toks.append(("WS-I(%d)" if c=='i' else "WS-FX(%d)")%(j+1))
    toks+=["WS-R(%d)"%(k+1) for k in range(nout)]
    return 'CALL "%s" USING %s'%(name," ".join(toks))
def out(r):
    return show(*r) if isinstance(r,tuple) else str(r)
def run(g,text,name,ins,nout,rows,model):
    g.run(text,[S(*r) or "0" for r in rows],C(name,ins,nout),nout," ".join(out(model(*r)) for r in rows))
def runt(g,text,name,ins,rows,model):
    toks=[("WS-I(%d)" if c=='i' else "WS-FX(%d)")%(j+1) for j,c in enumerate(ins)]
    call='CALL "%s" USING %s WS-T1 WS-T2'%(name," ".join(toks))
    g.run(text,[S(*r) or "0" for r in rows],call,'TEXT'," ".join("%s|%s"%model(*r) for r in rows))
def sc(x,s):
    v=x*s
    return int(math.floor(abs(v)+0.5))*(1 if v>=0 else -1)
def wire(v):
    v&=0xFFFF
    return v-65536 if v>=32768 else v
def std_inv(rel):
    # 1.2 of 40-2: the standard inventory block, rel 0..35 = main 0..26 then hotbar 27..35
    if rel<27: return (8+18*(rel%9),84+18*(rel//9))
    return (8+18*(rel-27),142)
