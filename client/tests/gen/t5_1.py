from mesh4 import *
import struct
t=mk(5,1,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 1 (shared facts): 1.1 the table facts (MeshTransformer scaling users, PartPose scaling, texel to UV, baby selection and ageScale,",
 "the shadow radius rule with the turtle exception, head look, the rotLerp quirk and rotLerpRad, the table Mth.sin and Mth.cos, the model-to-world frame), 1.2 the keyframe engine (sample index and fraction, walk time and scale, AnimationState",
 "operations), 1.3 the quadruped base, 1.4 the dye colour table. Values are worked by an independent script from the formulas of the document."],ck=True)
f32=lambda x: struct.unpack('f',struct.pack('f',x))[0]
SC=10430.378350470453
def msin(x): return f32(math.sin(((int(x*SC))&65535)/SC))
def mcos(x): return f32(math.sin(((int(x*SC+16384.0))&65535)/SC))
for x in (0,0.5,1,2.5,3.14159,-1.2,10,100.3,-45.6):
    t.call('EF5-MTH-SIN',[x],[msin(x)],'1.1 Mth.sin(%s) table value'%x)
    t.call('EF5-MTH-COS',[x],[mcos(x)],'1.1 Mth.cos(%s) table value'%x)
for ent,e in (('cat',0.8),('cat_collar',0.8),('cat_baby_collar',1.01),('polar_bear',1.2),('wolf',1),('panda',1)):
    t.raw('MOVE "%s" TO WS-X24'%ent,'CALL "EF5-MESH-SCALE" USING WS-X24 WS-IV(1)'); t.num('1.1 mesh scaling factor of %s'%ent,e,'WS-IV(1)')
for s in (0.8,1.2,1.01):
    t.call('EF4-SCALE-STEP',[0,1,s],[24.016*(1-s),s],'1.1 root after scaling by %s'%s)
t.call('EF5-POSE-SCALED',[1,2,3,1,1,1,2,3,4],[2,6,12,2,3,4],'1.1 PartPose.scaled multiplies position and scale')
t.call('EF5-POSE-SCALED',[-2,0.5,7,0.5,2,1,0.5,0.5,2],[-1,0.25,14,0.25,1,2],'1.1 PartPose.scaled second case')
for x,y,w,h in ((0,0,64,64),(18,14,64,32),(-2,-3,16,16),(30,47,128,64)):
    t.call('EF5-TEXEL-UV',[x,y,w,h],[x/w,y/h],'1.1 texel (%d,%d) in %dx%d is (U,V)'%(x,y,w,h))
for b in (0,1): t.call('EF5-AGE-SCALE',[b],[0.5 if b else 1],'1.1 ageScale baby %d'%b)
for ent,b,rad,sc,e in (('wolf',0,0.5,1,0.5),('wolf',1,0.5,1.5,0.75),('turtle',0,0.7,1,0.7),('turtle',1,0.7,1,0.7*0.83),('turtle',1,0.7,2,1.4*0.83),('bat',0,0.25,1,0.25)):
    t.raw('MOVE "%s" TO WS-X24'%ent,'MOVE %d TO WS-FL'%b,'MOVE %s TO WS-IV(1)'%lit(rad),'MOVE %s TO WS-IV(2)'%lit(sc),'CALL "EF5-SHADOW" USING WS-X24 WS-FL WS-IN WS-OUT')
    t.num('1.1 shadow radius %s baby %d radius %s scale %s'%(ent,b,rad,sc),e,'WS-OV(1)')
def wrap(x):
    x=x-360*math.floor(x/360)
    return x-360 if x>=180 else x
for hy,by,pitch,up in ((50,10,20,0),(-170,170,0,0),(30,-30,-15,0),(200,10,5,0),(40,10,5,1)):
    yr=wrap(hy-by)
    t.call('EF5-HEAD-LOOK',[hy,by,pitch,up],[-yr if up else yr],'1.1 head look yRot head %s body %s upside-down %d'%(hy,by,up))
for tt,a,b in ((0.5,0.2,1.0),(0.25,-1,2),(0.5,0,200),(0.75,10,-170),(1,0,359)):
    t.call('EF5-ROT-LERP',[tt,a,b],[a+tt*wrap(b-a)],'1.1 rotLerp t %s %s to %s (wrap in degrees)'%(tt,a,b))
def wrapr(d):
    while d>=math.pi: d-=2*math.pi
    while d<-math.pi: d+=2*math.pi
    return d
for tt,a,b in ((0.5,0.2,1.0),(0.5,0,5),(0.25,3,-3),(0.5,-3,3)):
    t.call('EF5-ROT-LERP-RAD',[tt,a,b],[a+tt*wrapr(b-a)],'1.1 rotLerpRad t %s %s to %s (wrap to -pi..pi)'%(tt,a,b))
# frame ops
for sc in (1,0.5,2):
    t.call('EF5-FRAME-OPS',[sc,30],[4, 3,sc,sc,sc, 4,30,0,0, 3,-1,-1,1, 1,0,-1.501,0][0:1]+[2,sc,sc,sc,3,30,0,0,2,-1,-1,1,1,0,-1.501,0],'1.1 model-to-world frame for entity scale %s (count, then code 1 translate 2 scale 3 rotate Y deg, values)'%sc)
# 1.2 keyframe index
def idx(ts,tt):
    n=len(ts); i=-1
    for k,x in enumerate(ts):
        if x<tt: i=k
    i=max(0,i); j=min(n-1,i+1)
    f=0 if i==j else min(1,max(0,(tt-ts[i])/(ts[j]-ts[i])))
    return i+1,j+1,f
for ts in ([0,0.5,1],[0,0.25,0.5,1.5],[0.1,0.2]):
    for tt in (-0.3,0,0.1,0.3,0.5,0.75,1.0,2.0):
        i,j,f=idx(ts,tt)
        t.call('EF5-KF-INDEX',[len(ts),tt]+ts,[i,j,f],'1.2 keyframes %s sampled at t=%s: i, j, f'%(ts,tt))
for pos,spd,pf,sf in ((2,0.5,2,2.5),(1.5,0.2,1,3),(0.75,1,2,2),(10,0.25,2,2.5),(0,0,2,2)):
    ms=int(pos*50*pf); k=min(spd*sf,1)
    t.call('EF5-WALK-TIME',[pos,spd,pf,sf],[ms/1000,k],'1.2 applyWalk pos %s speed %s factors %s %s: seconds and k'%(pos,spd,pf,sf))
MIN=-2147483648
def st(op,start,a,b,c):
    if op==1: return int(a),0
    if op==2: return (int(a) if start==MIN else start),0
    if op==3: return MIN,0
    if op==4:
        if a!=0: return (int(a2:=b) if start==MIN else start),0
        return MIN,0
    if op==5: return (start-int(b*c) if start!=MIN else start),0
    if op==6: return start,int((a-start)*50)
for op,start,a,b,c,name in ((1,MIN,40,0,0,'start'),(1,10,40,0,0,'restart'),(2,MIN,40,0,0,'startIfStopped stopped'),(2,10,40,0,0,'startIfStopped started'),(3,10,0,0,0,'stop'),
  (4,MIN,0,0,0,'animateWhen false'),(4,MIN,55,1,0,'animateWhen true from stopped'),(4,10,55,1,0,'animateWhen true started'),(5,100,0,10,1.5,'fastForward'),(5,MIN,0,10,1.5,'fastForward stopped'),(6,10,30.5,0,0,'elapsed ms')):
    if op==4: ns,r=((int(a) if start==MIN else start) if b!=0 else MIN),0
    else: ns,r=st(op,start,a,b,c)
    if op!=6: r=0 if ns==MIN else 1
    t.call('EF5-ANIM-STATE',[op,start,a,b,c],[ns,r],'1.2 AnimationState %s'%name)
# 1.3 quadruped base
for lay in ('COW',):
    for (pitch,yaw,p,s) in ((12,-30,2.5,0.6),(0,0,0,0),(-45,80,7.25,1)):
        t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([pitch,yaw,p,s]); t.raw('CALL "EF5-QUAD-POSE" USING EMM-MODEL WS-IN')
        a=math.cos(0.6662*p)*1.4*s; b=math.cos(0.6662*p+math.pi)*1.4*s
        pre='1.3 pitch %s pos %s '%(pitch,p)
        for part,f,v in (('head','xrot',pitch*D),('head','yrot',yaw*D),('right_hind_leg','xrot',a),('left_hind_leg','xrot',b),('right_front_leg','xrot',b),('left_front_leg','xrot',a)):
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
# 1.4 dye
DY=[0xF9FFFE,0xF9801D,0xC74EBD,0x3AB3DA,0xFED83D,0x80C71F,0xF38BAA,0x474F52,0x9D9D97,0x169C9C,0x8932B8,0x3C44AA,0x835432,0x5E7C16,0xB02E26,0x1D1D21]
txt=open(REPO+DOCS[5]).read()
tab=re.findall(r'\| (\d+) \| (\w+) \| ([0-9A-F]{6}) \| (\d+) \| (\w+) \| ([0-9A-F]{6}) \|',txt)
assert len(tab)==8
for a,n1,c1,b,n2,c2 in tab:
    assert DY[int(a)]==int(c1,16) and DY[int(b)]==int(c2,16)
for i,c in enumerate(DY): t.call('EF5-DYE-RGB',[i],[0xFF000000|c],'1.4 dye %d opaque texture diffuse colour'%i)
save(t,5,1)
