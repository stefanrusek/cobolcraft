# Shared helpers of the 31-6, 31-7 and 31-8 block entity test generators (genbe6.py, genbe7.py, genbe8.py); the writer is genbe.py.
import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from genbe import *
OUT="core/tests"
def only(): return set(int(a) for a in sys.argv[1:])
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
WSV=''.join(' 01 WS-%s                 BINARY-LONG.\n'%c for c in 'ABCEFGHPQRSUVW')+' 01 WS-EV                BINARY-LONG.\n'+''.join(' 01 WS-O%d                 BINARY-LONG.\n'%i for i in range(1,8))+''.join(' 01 WS-F%s                FLOAT-LONG.\n'%c for c in 'ABCDEF')+''' 01 WS-FS1                FLOAT-SHORT.
 01 WS-FS2                FLOAT-SHORT.
 01 WS-N24                PIC X(24).
 01 WS-N48                PIC X(48).
 01 WS-T64                PIC X(64).
 01 WS-T256               PIC X(256).
 01 WS-T2                 PIC X(64).
 01 WS-TAB.
    05 WS-TV              BINARY-LONG OCCURS 64 TIMES.
 01 WS-LONG1              BINARY-DOUBLE.
 01 WS-LONG2              BINARY-DOUBLE.
'''
def call(name,*args): return 'CALL "%s" USING %s\n'%(name," ".join(args))
def mv(**kw): return ''.join('MOVE %s TO WS-%s\n'%(v,k) for k,v in kw.items())
def fv(**kw): return ''.join('COMPUTE WS-F%s = %s\n'%(k,v) for k,v in kw.items())
def txtv(var,v):
    return ('MOVE SPACES TO %s\nMOVE "%s" TO %s\n'%(var,v,var)) if v else 'MOVE SPACES TO %s\n'%var
def key(v): return 'MOVE SPACES TO WS-N48\nMOVE "%s" TO WS-N48\nMOVE %d TO WS-SVL\n'%(v,len(v))
def cr(typ,name,x=5,y=70,z=5): return create(typ,name,x,y,z)
def render(form=2): return 'MOVE %d TO WS-FORM\n'%form
def mk(prog,sec,subj,tasks,desc,part):
    return G('TEST-BE-31-%d-%d'%(part,sec),'31-%d§%d'%(part,sec),subj,'Test of 31-%d section %d, %s (core/src/be-31-%d.cob; %s): %s'%(part,sec,subj,part,tasks,desc),WSV)
