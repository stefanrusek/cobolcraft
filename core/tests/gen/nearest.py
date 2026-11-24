import math, struct
K=10430.378350470453
SIN=[struct.unpack('f',struct.pack('f',math.sin(i/K)))[0] for i in range(65536)]
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def trunc(x): return int(x)
def msin(x): return SIN[trunc(x*K)&65535]
def mcos(x): return SIN[trunc(x*K+16384.0)&65535]
D=f32(0.017453292)
def near(yaw,pitch):
    p=f32(f32(pitch)*D); y=f32(f32(-yaw)*D)
    s=msin(y); c=mcos(y); sp=msin(p); cp=mcos(p)
    X=5 if s>0 else 4; Y=1 if sp<0 else 0; Z=3 if c>0 else 2
    ax=abs(s);ay=abs(sp);az=abs(c);bx=f32(ax*cp);bz=f32(az*cp)
    if ax>az:
        o=(Y,X,Z) if ay>bx else ((X,Z,Y) if bz>ay else (X,Y,Z))
    else:
        o=(Y,Z,X) if ay>bz else ((Z,X,Y) if bx>ay else (Z,Y,X))
    return list(o)+[o[2]^1,o[1]^1,o[0]^1]
def axis(yaw,pitch):
    y=f32(f32(yaw)*D)
    return (5 if -msin(y)>0 else 4, 1 if f32(pitch)<0 else 0, 3 if mcos(y)>0 else 2)
for yw,pt in [(0,0),(90,0),(-90,0),(180,0),(270,0),(45,0),(0,90),(0,-90),(135,-30),(-135,30),(30,10)]:
    print(yw,pt,near(yw,pt),axis(yw,pt))
