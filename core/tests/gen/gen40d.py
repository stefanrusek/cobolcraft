import sys
sys.path.insert(0,'core/tests/gen')
from gentest import *
from gen40c import *
# Shared helpers of the generators of the menu parts 8, 9 and x1 (gen40_8, gen40_9, gen40_x1): a Gen whose cases can print any text
# and several tokens; texts live in WS-TA, WS-TB (PIC X(1100)); the page editor state MN8-ED is in the test through COPY MN8ED.
class GenT(Gen):
    def __init__(self, program, section, subject, comment, ed=False, fld=False):
        extra=' 01 WS-TA                PIC X(2000).\n 01 WS-TB                PIC X(2000).\n 01 WS-TL                BINARY-LONG.\n 01 WS-TV                PIC X(2000).\n'
        if ed: extra+=' COPY MN8ED.\n COPY MN8LINES.\n'
        extra+=' 01 WS-PG                PIC X(100).\n'
        if fld: extra+=' COPY MN8FLD.\n'
        self.fld=fld
        self.ed=ed
        Gen.__init__(self,program,section,subject,comment,extra)
    def case(self, text, calls, exp):
        text=(self.prefix+text).replace('"',"'")
        if len(text)>195: text=text[:195].rsplit(' ',1)[0]
        s=mv(text,'TL-CASE')+'     PERFORM BEGIN-CASE\n'
        for inp,call,n in calls:
            s+=mv(inp,'WS-IN')+'     PERFORM LOAD-IN\n'
            for l in call.split('\n'): s+='     %s\n'%l
            if n=='TEXT': s+='     PERFORM ADD-TEXT\n'
            elif n is not None: s+='     MOVE %d TO WS-N\n     PERFORM ADD-N\n'%n
        s+=mv(exp,'TL-EXPECTED')+'     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n'
        self.out.append(s)
    def write(self, path):
        Gen.write(self, path)
        t=open(path).read().replace("PIC -(9)9.","PIC -(10)9.")
        par=''' SHOW-TA.
     MOVE WS-TA TO WS-TV
     IF WS-TL > 0
         INSPECT WS-TV(1:WS-TL) REPLACING ALL " " BY "_"
         INSPECT WS-TV(1:WS-TL) REPLACING ALL X"0A" BY "~"
         INSPECT WS-TV(1:WS-TL) REPLACING ALL X"09" BY "^"
         STRING WS-TV(1:WS-TL) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     ELSE
         STRING "<> " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     .

 '''
        if self.ed: par+=''' SHOW-ED.
     MOVE MN8-TEXT TO WS-TA
     MOVE MN8-LEN TO WS-TL
     PERFORM SHOW-TA
     .

'''
        if self.ed: par+=''' SHOW-LINES.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-R1
         MOVE MN8-LB(WS-J) TO WS-SHOW
         STRING FUNCTION TRIM(WS-SHOW) "-" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE MN8-LE(WS-J) TO WS-SHOW
         STRING FUNCTION TRIM(WS-SHOW) "," DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

'''
        if self.ed: par+=''' SHOW-CLIP.
     MOVE MN8-CLIP TO WS-TA
     MOVE MN8-CLIPLEN TO WS-TL
     PERFORM SHOW-TA
     .

'''
        if self.fld: par+=''' SHOW-FLD.
     MOVE SPACES TO WS-TA
     MOVE MN8-FTEXT TO WS-TA(1:256)
     MOVE MN8-FLEN TO WS-TL
     PERFORM SHOW-TA
     .

 SHOW-FCLIP.
     MOVE SPACES TO WS-TA
     MOVE MN8-FCLIP TO WS-TA(1:256)
     MOVE MN8-FCLIPLEN TO WS-TL
     PERFORM SHOW-TA
     .

'''
        k=t.rindex(' END PROGRAM')
        open(path,'w').write(t[:k]+par+t[k:])
def tok(*v): return " ".join(str(x) for x in v)
def rowcase(g,text,rows,call,nout,model,pre=''):
    # rows: tuples of integers fed to WS-I(1..); call is the COBOL call text using WS-I and WS-R; model returns the output tuple
    g.case(text,[(S(*r) or "0",(pre+"\n" if pre else "")+call,nout) for r in rows]," ".join(out(model(*r)) for r in rows))
def cstr(s):
    return s
def setting(var,s):
    # COBOL lines moving s to var, with a long text cut at 100 characters; characters outside printable ASCII are not allowed here
    return mv(s,var).rstrip('\n').replace('\n','\n')
def settext(var, s):
    # COBOL lines that fill var with s (printable ASCII and control characters below 32)
    out=['MOVE SPACES TO %s'%var]
    i=0
    while i<len(s):
        if ord(s[i])<32 or ord(s[i])==127:
            out.append('MOVE X"%02X" TO %s(%d:1)'%(ord(s[i]),var,i+1)); i+=1; continue
        if ord(s[i])>=128:
            out.append('MOVE FUNCTION CHAR(%d) TO %s(%d:1)'%(ord(s[i])+1,var,i+1)); i+=1; continue
        j=i
        while j<len(s) and s[j]==s[i] and 32<=ord(s[j])<127: j+=1
        if j-i<=8:
            j=i
            while j<len(s) and 32<=ord(s[j])<127 and j-i<90: j+=1
        run=s[i:j]
        if len(run)>8 and len(set(run))==1: out.append('MOVE ALL "%s" TO %s(%d:%d)'%(run[0],var,i+1,len(run)))
        else: out.append('MOVE "%s" TO %s(%d:%d)'%(run,var,i+1,len(run)))
        i=j
    return "\n".join(out)
def ed(s,cur=None,anc=None,cl=1024,ll=14,wd=114,adv=6,clip=''):
    n=len(s)
    cur=n if cur is None else cur
    anc=cur if anc is None else anc
    lines=[settext('MN8-TEXT',s),'MOVE %d TO MN8-LEN MN8-CUR'%n if False else 'MOVE %d TO MN8-LEN'%n,'MOVE %d TO MN8-CUR'%cur,'MOVE %d TO MN8-ANC'%anc,
           'MOVE %d TO MN8-CHARLIM'%cl,'MOVE %d TO MN8-LINELIM'%ll,'MOVE %d TO MN8-WIDTH'%wd,'MOVE %d TO MN8-ADV'%adv,'MOVE 0 TO MN8-CHANGED']
    lines.append(settext('MN8-CLIP',clip)); lines.append('MOVE %d TO MN8-CLIPLEN'%len(clip))
    return "\n".join(lines)
SHOWST='MOVE MN8-CUR TO WS-R1\nMOVE MN8-ANC TO WS-R2\nMOVE MN8-CHANGED TO WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-ED'
SHOWKEY='MOVE MN8-CUR TO WS-R1\nMOVE MN8-ANC TO WS-R2\nMOVE MN8-CHANGED TO WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-ED\nPERFORM SHOW-CLIP'
def nums(*v): return "/".join(str(x) for x in v)+" "
def txt(s): return (s.replace(' ','_')
    .replace('\n','~').replace('\t','^') if s else '<>')+" "

def fld(s,cur=None,anc=None,mx=0,adv=6,maxw=0,clip=''):
    n=len(s); cur=n if cur is None else cur; anc=cur if anc is None else anc
    return "\n".join([settext('MN8-FTEXT',s),'MOVE %d TO MN8-FLEN'%n,'MOVE %d TO MN8-FCUR'%cur,'MOVE %d TO MN8-FANC'%anc,'MOVE %d TO MN8-FMAX'%mx,'MOVE %d TO MN8-FADV'%adv,'MOVE %d TO MN8-FMAXW'%maxw,
        settext('MN8-FCLIP',clip),'MOVE %d TO MN8-FCLIPLEN'%len(clip),'MOVE 0 TO MN8-FCHANGED'])
SHOWF='MOVE MN8-FCUR TO WS-R1\nMOVE MN8-FANC TO WS-R2\nMOVE MN8-FCHANGED TO WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-FLD'
