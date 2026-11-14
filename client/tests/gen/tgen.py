# test generator DSL for COBOL entity-model tests
import re
def lit(x):
    if isinstance(x,int): return str(x)
    s='%.9f'%x
    s=s.rstrip('0')
    if s.endswith('.'): s+='0'
    return s
class T:
    def __init__(self,pid,prefix,header,extra_ws='',ck=False):
        self.ck=ck
        self.pid=pid; self.prefix=prefix; self.header=header; self.extra_ws=extra_ws
        self.body=[]; self.paras=[]; self.n=0
    def raw(self,*lines):
        for l in lines: self.body.append('     '+l)
    def comment(self,c): self.body.append('*>   '+c)
    def setarg(self,var,val):
        self.raw('MOVE SPACES TO %s'%var if val=='' else 'MOVE "%s" TO %s'%(val,var))
    def _name(self,name):
        n=name.replace('"',"'")
        self.raw('MOVE "%s" TO WS-NAME'%n)
    def num(self,name,expected,observed):
        self._name(name); self.raw('MOVE %s TO WS-E'%lit(expected),'MOVE %s TO WS-O'%observed,'PERFORM CHECK-NUM'); self.n+=1
    def text(self,name,expected,observed):
        self._name(name); self.raw('MOVE "%s" TO TL-EXPECTED'%expected if expected else 'MOVE SPACES TO TL-EXPECTED','MOVE %s TO TL-OBSERVED'%observed,'PERFORM CHECK-TEXT'); self.n+=1
    def call(self,prog,ins,outs,name,extra=None):
        """ins: list of numbers; outs: list of expected numbers (or None to skip)"""
        for i,v in enumerate(ins): self.raw('MOVE %s TO WS-IV(%d)'%(lit(v),i+1))
        self.raw('CALL "%s" USING WS-IN WS-OUT'%prog)
        for k,v in enumerate(outs):
            if v is None: continue
            self.num('%s [%d]'%(name,k+1) if len(outs)>1 else name,v,'WS-OV(%d)'%(k+1))
    def build(self,layer,label=None):
        self.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK','PERFORM CK-RESET-COUNTS')
        self.num('layer %s is known'%layer,1,'WS-OK')
    def rows(self,prefix,rows):
        self.raw('MOVE "%s" TO CK-PREFIX'%prefix.replace('"',"'"))
        for r in rows: self.raw('MOVE "%s" TO CK-ROW'%r,'PERFORM CK-ROW-CHECK'); self.n+=1
    def stats(self,label,parts,cubes,tw,th):
        self.raw('CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES')
        self.num('%s: parts below the root'%label,parts,'WS-PARTS')
        self.num('%s: cuboids'%label,cubes,'WS-CUBES')
        self.num('%s: texture width'%label,tw,'MM-TEXW')
        self.num('%s: texture height'%label,th,'MM-TEXH')
    def render(self):
        o=[]
        for h in self.header: o.append('*> '+h)
        o+=[' IDENTIFICATION DIVISION.',' PROGRAM-ID. %s.'%self.pid,' DATA DIVISION.',' WORKING-STORAGE SECTION.',' COPY CLEMM.',' COPY TESTLIB.',
            ' 01 WS-NAME                PIC X(160).',' 01 WS-E                   FLOAT-LONG.',' 01 WS-O                   FLOAT-LONG.',
            ' 01 WS-IN.','    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.',' 01 WS-OUT.','    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.']
        if self.ck: o+=[' 01 WS-LAYER              PIC X(32).',' 01 WS-OK                 BINARY-LONG.',' 01 WS-PARTS              BINARY-LONG.',' 01 WS-CUBES              BINARY-LONG.',' 01 WS-P                  BINARY-LONG.',' 01 WS-PN                 PIC X(24).',' COPY EMCHKW.']
        if self.extra_ws: o.append(self.extra_ws)
        o.append(' PROCEDURE DIVISION.')
        o+=self.body
        o.append('     STOP RUN.')
        o.append('')
        o+=self.paras
        if self.ck: o+=[' COPY EMCHKP.','']
        o+=[' CHECK-NUM.','     MOVE SPACES TO TL-CASE','     STRING "%s: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE'%self.prefix,
            '     MOVE "N" TO TL-MODE','     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002','         MOVE WS-E TO WS-O','     END-IF','     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000','     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000',
            '     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.','',' CHECK-TEXT.','     MOVE SPACES TO TL-CASE',
            '     STRING "%s: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE'%self.prefix,'     MOVE "T" TO TL-MODE',
            '     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.',' END PROGRAM %s.'%self.pid]
        return '\n'.join(o)+'\n'

# ---- helpers shared by the section generators
import math
D=0.017453292
DOC='../../docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md'
def scale_rows(rows,s):
    """expected rows after MeshTransformer.scaling(s): each direct child of the root: pos and scale times s, then y translated by 24.016 (1 - s)"""
    out=[]
    for r in rows:
        t=r.split()
        if t[0]=='P' and t[2]=='root':
            x,y,z=float(t[3]),float(t[4]),float(t[5])
            t=t[:3]+[lit(x*s),lit(y*s+24.016*(1-s)),lit(z*s)]+t[6:9]+[lit(s)]*3
        out.append(' '.join(t))
    return out
def cur(self,part,field,expected):
    idx={'x':'MM-CX','y':'MM-CY','z':'MM-CZ','xrot':'MM-CXROT','yrot':'MM-CYROT','zrot':'MM-CZROT','xs':'MM-CXSCALE','ys':'MM-CYSCALE','zs':'MM-CZSCALE'}[field]
    self.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
    self.num('%s.%s'%(part,field),expected,'%s(WS-P)'%idx)
T.cur=cur
def vis(self,part,expected):
    self.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
    self.num('%s visible'%part,expected,'MM-VISIBLE(WS-P)')
T.vis=vis
import docrows
def heading(h):
    for i,l in enumerate(open(DOC).read().split('\n'),1):
        if l.startswith(h): return i
    raise Exception(h)
def table(h,section_skip=None):
    return docrows.rows(DOC,heading(h),0)
