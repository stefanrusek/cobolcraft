# Shared writer of the 31-2..31-5 block entity tests (python3 core/tests/gen/genbe<N>.py [sections], from the repository root).
# A case is COBOL statements (setup and calls) followed by the shown items; expected text comes from independent Python models or from the tables of the docs.
import re,sys
HEAD='''*> %(comment)s
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. %(program)s.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(10)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-IA.
    05 WS-IAV              BINARY-LONG OCCURS 8 TIMES.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
%(ws)s PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
'''
TAIL='''     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-IA.
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WS-NM WS-NML WS-LC WS-IA
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM %(program)s.

 COPY CORETEST.
'''
def num(e): return '     MOVE %s TO WS-SHOW\n     PERFORM ADD-N\n'%e
def flo(e,sc=1000000): return '     COMPUTE WS-SHOW ROUNDED = (%s) * %d\n     PERFORM ADD-N\n'%(e,sc)
def txt(e,l): return '     STRING %s(1:%s) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR\n'%(e,l)
ITEMS=[]
def shw(*items):
    s=''
    for it in items:
        ITEMS.append(it)
        s+=_show(it)
    return s
def _show(it):
    if it=='SAVE': return '     PERFORM SAVE-RENDER\n'
    if it.startswith('n:'): return num(it[2:])
    if it.startswith('f:'): return flo(it[2:])
    if it.startswith('f4:'): return flo(it[3:],10000)
    if it.startswith('t:'):
        e,l=it[2:].split(',')
        return txt(e,l)
    raise Exception(it)
class G:
    def __init__(self, program, section, subject, comment, ws=""):
        self.program=program; self.prefix="acceptance US12 %s %s: "%(section,subject); self.comment=comment; self.out=[]; self.ws=ws
    def case(self, text, body, show, exp):
        text=self.prefix+text
        if len(text)>230: text=text[:230].rsplit(' ',1)[0]
        s='     MOVE "%s" TO TL-CASE\n     PERFORM BEGIN-CASE\n'%text.replace('"',"'")
        for l in body.strip('\n').split('\n'):
            if l.strip(): s+='     %s\n'%l.strip() if not l.startswith(' ') else '     %s\n'%l.lstrip(' ') if False else '     %s\n'%l.strip()
        used=list(ITEMS); del ITEMS[:]
        for it in show: s+=_show(it)
        show=used+list(show)
        if isinstance(exp,(list,tuple)) and len(exp)==len(show):
            import math
            ne=[]
            for it,x in zip(show,exp):
                sc=1000000 if it.startswith('f:') else 10000 if it.startswith('f4:') else 0
                if sc: x=int(math.floor(abs(x)*sc+0.5))*(1 if x>=0 else -1)
                ne.append(x)
            exp=ne
        exp=" ".join(str(x) for x in exp) if isinstance(exp,(list,tuple)) else str(exp)
        e=exp.replace('"',"'")
        lit=' &\n         '.join('"%s"'%e[i:i+100] for i in range(0,max(len(e),1),100))
        s+='     MOVE %s TO TL-EXPECTED\n     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n\n'%lit
        self.out.append(s)
    def write(self, path):
        h=HEAD%dict(comment=self.comment,program=self.program,ws=self.ws)
        open(path,'w').write((h+"".join(self.out)+TAIL%dict(program=self.program)).replace('MOVE "" TO','MOVE SPACES TO'))

def _nm(n): return 'MOVE "%s" TO WS-NM\nMOVE %d TO WS-NML\n'%(n,len(n)) if n is not None else 'MOVE SPACES TO WS-NM\nMOVE -1 TO WS-NML\n'
def nb_s(n,v): return _nm(n)+('MOVE "%s" TO WS-SV\n'%v if v else 'MOVE SPACES TO WS-SV\n')+'MOVE %d TO WS-SVL\nPERFORM NB-S\n'%len(v.encode())
def nb_i(n,v): return _nm(n)+'MOVE %d TO WS-NV\nPERFORM NB-I\n'%v
def nb_b(n,v): return _nm(n)+'MOVE %d TO WS-NV\nPERFORM NB-B\n'%v
def nb_long(n,v): return _nm(n)+'MOVE %d TO WS-LV\nPERFORM NB-LONG\n'%v
def nb_intarr(n,vals): return _nm(n)+''.join('MOVE %d TO WS-IAV(%d)\n'%(v,i+1) for i,v in enumerate(vals))+'MOVE %d TO WS-LC\nPERFORM NB-IA\n'%len(vals)
def nb_c(n): return _nm(n)+'PERFORM NB-C\n'
def nb_e(): return 'PERFORM NB-E\n'
def nb_l(n,t,c): return _nm(n)+'MOVE %d TO WS-LT\nMOVE %d TO WS-LC\nPERFORM NB-L\n'%(t,c)
def nb_begin(): return 'CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\n'
def create(typ,key,x=5,y=70,z=5,dim=1):
    """a block entity of the type at a position; index in WS-IDX"""
    return 'MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-NV\nMOVE %d TO WS-J\nMOVE %d TO WS-K\nMOVE %d TO WS-LEN\nCALL "BE-CREATE" USING WS-D WS-J WS-K WS-LEN WS-NV WS-KEY WS-SVL WS-IDX\n'%(key,typ,x,y,z) if False else (
        'MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-SVL\nMOVE %d TO WS-NV\nMOVE %d TO WS-X\nMOVE %d TO WS-Y\nMOVE %d TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX\n'%(key,len("minecraft:"+key),typ,x,y,z))
def nb_stack(item,count): return 'MOVE %d TO WS-ITEM\nMOVE %d TO WS-NV\nPERFORM NB-STACK\n'%(item,count)
ITEMNAME={1:'cobolcraft:baseplate',2:'cobolcraft:greystone',3:'cobolcraft:loam'}
