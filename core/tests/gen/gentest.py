import re
HEAD='''*> %(comment)s
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-I as integers and WS-FX as doubles), calls the program
*> and shows the outputs WS-R(1..WS-N) joined by "/", one group per call; expected values come from the rules and tables of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. %(program)s.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY INTERACT.
%(tables)s 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 01 WS-TEXTS.
    05 WS-T1               PIC X(96).
    05 WS-T2               PIC X(96).
%(extra)s PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
'''
TAIL='''     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 LOAD-IN.
     MOVE 1 TO WS-P
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE SPACES TO WS-TOK
         IF WS-P <= 160
             UNSTRING WS-IN DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-P
         END-IF
         COMPUTE WS-FX(WS-K) = FUNCTION NUMVAL(WS-TOK)
         COMPUTE WS-I(WS-K) = FUNCTION NUMVAL(WS-TOK)
     END-PERFORM
     .

 ADD-N.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         MOVE WS-R(WS-J) TO WS-SHOW
         IF WS-J > 1
             STRING "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 ADD-TEXT.
     STRING FUNCTION TRIM(WS-T1) "|" FUNCTION TRIM(WS-T2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM %(program)s.
'''
def tbl(grp,name,usage,cnt):
    return (" 01 WS-%sG.\n"%grp)+"".join("    05 WS-%s%d %s.\n"%(name,i,usage) for i in range(1,cnt+1))+" 01 WS-%sT REDEFINES WS-%sG.\n    05 WS-%s %s OCCURS %d TIMES.\n"%(grp,grp,name,usage,cnt)
class Gen:
    def __init__(self, program, section, subject, comment, extra=""):
        self.program=program; self.prefix="acceptance US12 %s %s: "%(section,subject); self.comment=comment; self.out=[]; self.extra=extra
    def case(self, text, calls, exp):
        text=self.prefix+text
        if len(text)>195: text=text[:195].rsplit(' ',1)[0]
        s='     MOVE "%s" TO TL-CASE\n     PERFORM BEGIN-CASE\n'%text
        for inp,call,n in calls:
            s+='     MOVE "%s" TO WS-IN\n     PERFORM LOAD-IN\n'%inp
            for l in call.split('\n'): s+='     %s\n'%l
            if n=='TEXT': s+='     PERFORM ADD-TEXT\n'
            else: s+='     MOVE %d TO WS-N\n     PERFORM ADD-N\n'%n
        s+='     MOVE "%s" TO TL-EXPECTED\n     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n'%exp
        self.out.append(s)
    def run(self, text, inputs, call, n, exp):
        self.case(text,[(i,call,n) for i in inputs],exp)
    def write(self, path):
        tables=tbl('IS','I','BINARY-LONG',16)+tbl('FXS','FX','FLOAT-LONG',16)+tbl('RS','R','BINARY-LONG',16)+tbl('RFS','RF','FLOAT-LONG',8)
        h=HEAD%dict(comment=self.comment,program=self.program,tables=tables,extra=self.extra)
        body=re.sub(r'WS-(I|FX|R|RF)\((\d+)\)',r'WS-\1\2',"".join(self.out))
        open(path,'w').write(h+body+TAIL%dict(program=self.program))
F=lambda *a:" ".join("WS-FX(%d)"%i for i in a)
I=lambda *a:" ".join("WS-I(%d)"%i for i in a)
