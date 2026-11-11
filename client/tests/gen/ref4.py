import math
from app4 import parse
DEG=0.017453292
def vec(target,x,y,z):
    x,y,z=float(x),float(y),float(z)
    if target==2: return (x*DEG,y*DEG,z*DEG)
    if target==1: return (x,-y,z)
    return (x-1,y-1,z-1)
def sample(ch,t,scale):
    keys=ch['keys']; n=len(keys)
    ts=[float(k[0]) for k in keys]
    post=[vec(ch['target'],*k[1:4]) for k in keys]
    f=n
    for idx in range(n):
        if t<=ts[idx]: f=idx; break
    i=max(0,f-1); j=min(n-1,i+1)
    a=0.0 if i==j else min(1,max(0,(t-ts[i])/(ts[j]-ts[i])))
    inter=keys[j][4]
    out=[]
    for c in range(3):
        if inter==1: v=post[i][c]+(post[j][c]-post[i][c])*a
        else:
            p0=post[max(0,i-1)][c]; p1=post[i][c]; p2=post[j][c]; p3=post[min(n-1,j+1)][c]
            v=0.5*(2*p1+(p2-p0)*a+(2*p0-5*p1+4*p2-p3)*a*a+(3*p1-p0-3*p2+p3)*a**3)
        out.append(v*scale)
    return out
def apply(a,ms,scale,parts):
    s=ms/1000.0
    if a['loop'] and float(a['length'])>0:
        L=float(a['length']); s=s-L*math.floor(s/L)
    for ch in a['ch']:
        v=sample(ch,s,scale); p=parts[ch['bone']]
        base={1:0,2:3,3:6}[ch['target']]
        for c in range(3): p[base+c]+=v[c]
def keytests(t,prefix,call,names,anims,tag):
    """info, bone/target/keys and evaluation of every channel (call: program prefix like EF4C)"""
    for ai,(name,a) in enumerate(zip(names,anims),1):
        t.call(prefix+'-ANIM-INFO',[ai],[float(a['length']),a['loop'],len(a['ch'])],'%s %s length, looping, channels'%(tag,name))
        t.raw('MOVE %d TO WS-ANIM'%ai,'CALL "%s-ANIM-NAME" USING WS-ANIM WS-NAME2'%prefix); t.text('%s animation %d is %s'%(tag,ai,name),name,'WS-NAME2')
        for ci,ch in enumerate(a['ch'],1):
            t.raw('MOVE %d TO WS-ANIM'%ai,'MOVE %d TO WS-I2'%ci,'CALL "%s-ANIM-BONE" USING WS-ANIM WS-I2 WS-BONE WS-TARGET WS-KEYS'%prefix)
            t.text('%s %s channel %d bone'%(tag,name,ci),ch['bone'],'WS-BONE'); t.num('%s %s channel %d target'%(tag,name,ci),ch['target'],'WS-TARGET'); t.num('%s %s channel %d keys'%(tag,name,ci),len(ch['keys']),'WS-KEYS')
            ts=[float(k[0]) for k in ch['keys']]
            times=[ts[0],(ts[0]+ts[1])/2 if len(ts)>1 else ts[0]+0.01,ts[len(ts)//2],ts[-1],ts[-1]+0.3]
            for tm in times:
                e=sample(ch,tm,0.75)
                t.call(prefix+'-ANIM-EVAL',[ai,ci,tm,0.75],e,'%s %s %s %s t=%.4f'%(tag,name,ch['bone'],['pos','rot','scale'][ch['target']-1],tm))
KWS=""" 01 WS-BONE               PIC X(24).
 01 WS-TARGET             BINARY-LONG.
 01 WS-KEYS               BINARY-LONG.
 01 WS-ANIM               BINARY-LONG.
 01 WS-NAME2              PIC X(48).
 01 WS-I2                 BINARY-LONG."""
