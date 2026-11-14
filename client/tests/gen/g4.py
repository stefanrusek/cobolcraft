import sys,math,re,json
import os
HERE=os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0,HERE)
from tgen import T as _T, lit, D
import doc4
REPO=os.path.abspath(os.path.join(HERE,'..','..','..'))+'/'
import glob,os
DOCS={4:'docs/protocol/34-entity-models-4-farm-animals-equines.md'}
for _c in range(5,10):
    DOCS[_c]=glob.glob(REPO+'docs/protocol/34-entity-models-%d-*.md'%_c)[0][len(REPO):]
def tasktitle(ch,n):
    s=open(REPO+'specs/002-client-polish/tasks.md').read()
    m=re.search(r'test_entmodel_34_%d_%d\.cob` for (.*?) \(`docs'%(ch,n),s)
    return m.group(1)
WSX="""
 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG."""
class T(_T):
    def build(self,layer):
        self.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "%s" USING EMM-MODEL WS-LAYER WS-OK'%getattr(self,'LP','EF4-LAYER'),'PERFORM CK-RESET-COUNTS')
        self.num('layer %s is known'%layer,1,'WS-OK')
    def cur(self,part,field,expected):
        idx={'x':'MM-CX','y':'MM-CY','z':'MM-CZ','xrot':'MM-CXROT','yrot':'MM-CYROT','zrot':'MM-CZROT','xs':'MM-CXSCALE','ys':'MM-CYSCALE','zs':'MM-CZSCALE'}[field]
        self.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
        self.num('%s.%s'%(part,field),expected,'%s(WS-P)'%idx)
    def vis(self,part,expected):
        self.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
        self.num('%s visible'%part,expected,'MM-VISIBLE(WS-P)')
    def txt3(self,name,prog,args,exp):
        """call prog with string args (list of (var,val)) and compare the final var with exp"""
        for v,val in args: self.raw('MOVE "%s" TO %s'%(val,v))
        self.raw('CALL "%s" USING %s'%(prog,' '.join(v for v,_ in args)))
        self.text(name,exp,args[-1][0])
    def setin(self,ins):
        for i,v in enumerate(ins): self.raw('MOVE %s TO WS-IV(%d)'%(lit(v),i+1))
def mk(ch,n,header,ck=False):
    t=T('TEST-ENTMODEL-34-%d-%d'%(ch,n),'acceptance US15 34-%d§%d %s'%(ch,n,tasktitle(ch,n)),header,extra_ws=WSX,ck=ck)
    t.LP='EF%d-LAYER'%ch if ch<=9 else 'EF4-LAYER'
    return t
def save(t,ch,n):
    open(REPO+'client/tests/test_entmodel_34_%d_%d.cob'%(ch,n),'w').write(t.render())
def scale_rows(rows,s):
    out=[]
    for r in rows:
        x=r.split()
        if x[0]=='P' and x[2]=='root':
            px,py,pz=float(x[3]),float(x[4]),float(x[5])
            sx,sy,sz=[float(v) for v in x[9:12]] if len(x)>9 else (1,1,1)
            x=x[:3]+[lit(px*s),lit(py*s+24.016*(1-s)),lit(pz*s)]+x[6:9]+[lit(sx*s),lit(sy*s),lit(sz*s)]
        out.append(' '.join(x))
    return out
def layers(ch):
    return doc4.parse(REPO+DOCS[ch])
def grow_add(rows,a,skip=()):
    out=[]
    for r in rows:
        x=r.split()
        if x[0]=='C': x[10]=lit(float(x[10])+a)
        out.append(' '.join(x))
    return out
def sizes(rows):
    return sum(1 for r in rows if r[0]=='P'),sum(1 for r in rows if r[0]=='C')
