from mesh8 import *
import math
def squid_rows(baby):
    R=3 if baby else 5
    r=['P body root 0 13 0 0 0 0','C body 0 0 -4 -5 -4 8 10 8 0 0'] if baby else ['P body root 0 8 0 0 0 0','C body 0 0 -6 -8 -6 12 16 12 0.02 0']
    for i in range(8):
        a=i*math.pi*2/8; cx=math.cos(a)*R; cz=math.sin(a)*R; ry=i*math.pi*(-2)/8+math.pi/2
        y=18.5 if baby else 15
        r.append('P tentacle%d root %s %s %s 0 %s 0'%(i,lit(cx),y,lit(cz),lit(ry)))
        r.append('C tentacle%d 0 18 -1 -0.5 -1 2 6 2 0 0'%i if baby else 'C tentacle%d 48 0 -1 0 -1 2 18 2 0 0'%i)
    return r
def define():
    setlayer('SQUID',squid_rows(0),64,32); setlayer('SQUID_BABY',squid_rows(1),32,32)
    setlayer('GLOW_SQUID',squid_rows(0),64,32,src='SQUID'); setlayer('GLOW_SQUID_BABY',squid_rows(1),32,32,src='SQUID_BABY')
