def prog(name,body,ws=''):
    s=' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n'%name
    if ws: s+=' WORKING-STORAGE SECTION.\n'+ws
    s+=' LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-OUT.\n    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.\n PROCEDURE DIVISION USING L-IN L-OUT.\n'+body+'     GOBACK.\n END PROGRAM %s.\n\n'%name
    return s
def pathprog(name,cases,default=None):
    """cases: list of (value,path); EVALUATE L-I(1)"""
    s=' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     EVALUATE L-I(1)\n'%name
    for v,p in cases: s+='         WHEN %s\n             MOVE "%s" TO L-PATH\n'%(v,p)
    s+='         WHEN OTHER\n             MOVE "%s" TO L-PATH\n     END-EVALUATE\n     GOBACK.\n END PROGRAM %s.\n\n'%(default or cases[-1][1],name)
    return s
