# Shared helpers of the redstone generators gen30_1.py, gen30_2.py, gen30_3.py (tests of docs/protocol/30-redstone-1..3).
# Models here are written from the documents' prose and tables, independent of core/src/redstone-30-*.cob.
import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
D,U,N,S_,W,E=0,1,2,3,4,5          # Direction.values() order, the 3D data values
def opp(d): return d^1
STEP={D:(0,-1,0),U:(0,1,0),N:(0,0,-1),S_:(0,0,1),W:(-1,0,0),E:(1,0,0)}
def cw(d): return {N:E,E:S_,S_:W,W:N}[d]
def ccw(d): return {N:W,W:S_,S_:E,E:N}[d]
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def S(*a): return " ".join(str(x) for x in a)
def flat(v):
    if isinstance(v,(tuple,list)):
        o=[]
        for x in v: o+=flat(x)
        return o
    return [v]
def show(*v): return "/".join(str(x) for x in flat(v))
class Suite:
    def __init__(self,part,prefix,progpfx,srcfile,only):
        self.part=part; self.prefix=prefix; self.pp=progpfx; self.src=srcfile; self.only=set(only)
    def gen(self,n,subj,tasks,desc,extra=''):
        g=Gen('TEST-REDSTONE-30-%d-%d'%(self.part,n),'30-%d§%d'%(self.part,n),subj,'Test of 30 part %d section %d, %s (core/src/%s; %s): %s'%(self.part,n,subj,self.src,tasks,desc),extra)
        g.n=n; g.suite=self
        return g
    def write(self,g):
        if not self.only or g.n in self.only: g.write(OUT+'/test_redstone_30_%d_%d.cob'%(self.part,g.n))
NAME=" 01 WS-NM                PIC X(40).\n"
def T(g,text,call,nout,rows,model):
    g.run(text,[S(*r) for r in rows],call,nout," ".join(show(model(*r)) for r in rows))
def TN(g,text,call,nout,rows,model):
    # rows: tuples (name, ints...) ; the name goes into WS-NM, the rest into WS-I(1..)
    cs=[]
    for r in rows:
        cs.append((S(*r[1:]) or "0",'MOVE "%s" TO WS-NM\n%s'%(r[0],call),nout))
    g.case(text,cs," ".join(show(model(*r)) for r in rows))

def TBL(name,cnt): return " 01 WS-%sG.\n    05 WS-%s BINARY-LONG OCCURS %d TIMES.\n"%(name,name,cnt)
def setarr(name,vals): return "".join('MOVE %d TO WS-%s(%d)\n'%(v,name,i+1) for i,v in enumerate(vals))
