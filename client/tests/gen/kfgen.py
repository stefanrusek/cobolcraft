import re
import os
raw=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'kfgen_raw.py')).read()
def gen(prefix,names,anims,header):
    """anims: list parallel to names (parsed dicts)"""
    n=len(names)
    s=raw
    s=s.replace('EM3-ANIM',prefix+'-ANIM')
    s=s.replace('UNTIL WS-I > 11','UNTIL WS-I > %d'%n).replace('L-ORD <= 11','L-ORD <= %d'%n)
    s=s.replace('OCCURS 11 TIMES','OCCURS %d TIMES'%n).replace('PIC X(40000)','PIC X(60000)').replace('OCCURS 12 TIMES','OCCURS %d TIMES'%(n+1)).replace('WS-NAME(12)','WS-NAME(%d)'%(n+1))
    s=s.replace("(ok 0 when the ordinal is not one of the eleven)","(ok 0 when the ordinal is not one of the animations)")
    # drop the header comment appends: they are the first o.append lines; we replace the whole header
    lines=s.split('\n')
    keep=[l for l in lines if not l.startswith('o.append("*>')]
    s='\n'.join(keep)
    ns={'ORDER':names}
    A={nm:a for nm,a in zip(names,anims)}
    src="def _g(ORDER,A,HEADER):\n    o=[]\n"
    # body uses names rows, o ; indent
    body=s
    body=body.replace("\no=[]\n","\n").replace("o=[]\n","",1) if False else body
    code="\n".join('    '+l for l in body.split('\n'))
    code=code.replace("    o=[]\n","") 
    full=src+code.replace("    o+=[' IDENTIFICATION DIVISION.'","    o+=HEADER\n    o+=[' IDENTIFICATION DIVISION.'",1)
    full=full.replace("'     GOBACK.',\n ''","''")
    exec(full,ns)
    return ns['_g'](names,A,header)
