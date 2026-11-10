from mesh7 import *
import rng7
t=mk(7,1,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 1 (shared pieces): 1.1 part pose application ops and the PartPose helpers, 1.2 box corners, face rectangles, vertex slots, vertex uvs and normals, 1.3 the scaling transformer on a point,",
 "1.4 Mth sine and cosine tables, wrapDegrees, rotLerp and lerp, 1.5 the 48-bit random generator (the ghast tentacle lengths of section 3 are the check), 1.6 setupRotations ops, the body render choice, overlay texels and coordinates, light and shadow radius."],ck=False)
PI=math.pi
def partops(p):
    x,y,z,rx,ry,rz,sx,sy,sz=p
    ops=[(1,x/16,y/16,z/16)]
    if rx or ry or rz: ops.append((7,rz,ry,rx))
    if sx!=1 or sy!=1 or sz!=1: ops.append((2,sx,sy,sz))
    return [len(ops)]+[v for o in ops for v in o]
for p in ((0,0,0,0,0,0,1,1,1),(8,-16,4,0.5,0,0,1,1,1),(1,2,3,0,0.25,-0.5,1,1,1),(0,24,0,0,0,0,0.875,0.875,0.875),(-2,6.9,-0.5,0.2,0.1,0.3,2,1,2)):
    t.call('EF7-PART-OPS',list(p),partops(p),'1.1 part ops for pose %s (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values)'%(p,))
for op,pose,a,e in ((1,(1,2,3,0.1,0.2,0.3,1,1,1),(2,2,2),(1,2,3,0.1,0.2,0.3,2,2,2)),(2,(1,2,3,0.1,0.2,0.3,2,3,4),(2,2,2),(2,4,6,0.1,0.2,0.3,4,6,8)),(3,(1,2,3,0.1,0.2,0.3,1,1,1),(1,-2,0.5),(2,0,3.5,0.1,0.2,0.3,1,1,1))):
    t.call('EF7-POSE-OP',[op]+list(pose)+list(a),list(e),'1.1 PartPose op %d (1 withScale, 2 scaled, 3 translated) on %s with %s'%(op,pose,a))
def corners(x,y,z,w,h,d,gx,gy,gz,mir):
    x0=x-gx; x1=x+w+gx; y0=y-gy; y1=y+h+gy; z0=z-gz; z1=z+d+gz
    if mir: x0,x1=x1,x0
    A=(x0,y0,z0);B=(x1,y0,z0);C=(x1,y1,z0);D=(x0,y1,z0);E=(x0,y0,z1);F=(x1,y0,z1);G=(x1,y1,z1);H=(x0,y1,z1)
    return [v for c in (A,B,C,D,E,F,G,H) for v in c]
for a in ((-4,-4,-4,8,8,8,0,0,0,0),(-4,-4,-4,8,8,8,0.5,0.5,0.5,0),(-10,3.9,-0.5,20,3,3,0,0,0,1),(0,0,0,2,8,2,0.25,0,0.1,1)):
    t.call('EF7-BOX-CORNERS',list(a),corners(*a),'1.2 corners of box %s (A..H x y z)'%(a,))
def rects(u,v,w,h,d,W,H):
    r=[(u+d,v,u+d+w,v+d),(u+d+w,v,u+d+2*w,v+d),(u,v+d,u+d,v+d+h),(u+d,v+d,u+d+w,v+d+h),(u+d+w,v+d,u+2*d+w,v+d+h),(u+2*d+w,v+d,u+2*d+2*w,v+d+h)]
    return [q for (a,b,c,e) in r for q in (a/W,b/H,c/W,e/H)]
for a in ((0,0,8,8,8,64,32),(32,0,6,6,6,64,64),(0,16,20,3,3,64,64),(24,22,11,2,2,64,64)):
    t.call('EF7-BOX-RECTS',list(a),rects(*a),'1.2 face rectangles of box tex (%d,%d) size %dx%dx%d in %dx%d (down, up, west, north, east, south: u min, v min, u max, v max)'%a)
SLOTS={0:'FEAB',1:'CDHG',2:'AEHD',3:'BADC',4:'FBCG',5:'EFGH'}
for face in range(6):
    for mir in (0,1):
        s=SLOTS[face]; idx=[ 'ABCDEFGH'.index(c)+1 for c in s]
        if mir: idx=idx[::-1]
        t.call('EF7-FACE-VERTS',[face,mir],idx,'1.2 corner indexes of face %d (0 down 1 up 2 west 3 north 4 east 5 south) mirror %d, in vertex slot order'%(face,mir))
for slot,e in ((0,(1,0)),(1,(0,0)),(2,(0,1)),(3,(1,1))):
    t.call('EF7-VERTEX-UV',[slot,10,20,30,40],[10 if e[0]==0 else 30,20 if e[1]==0 else 40] if False else [30 if e[0]==1 else 10,40 if e[1]==1 else 20],'1.2 vertex slot %d uv of rectangle u 10..30 v 20..40 (u, v)'%slot)
NORM={0:(0,-1,0),1:(0,1,0),2:(-1,0,0),3:(0,0,-1),4:(1,0,0),5:(0,0,1)}
for face in range(6):
    for mir in (0,1):
        n=NORM[face]
        if mir and face in (2,4): n=(-n[0],n[1],n[2])
        t.call('EF7-FACE-NORMAL',[face,mir],list(n),'1.2 normal of face %d mirror %d'%(face,mir))
for s,x,y,z in ((4.5,1,17.6,2),(1.2,-3,0,5),(0.7,2,24,1)):
    T=24.016*(1-s)
    t.call('EF7-SCALE-POINT',[s,x,y,z],[s*x,T+s*y,s*z],'1.3 model point (%s, %s, %s) after scaling %s'%(x,y,z,s))
t.call('EF7-INNER-ARMOR',[],[0.5],'1.3 INNER_ARMOR_DEFORMATION')
SC=10430.378350470453
for x in (0,0.5,1,2.5,-1.2,10,100.3):
    t.call('EF7-MTH-SIN',[x],[math.sin(((int(x*SC))&65535)/SC)],'1.4 Mth.sin(%s) table entry'%x)
    t.call('EF7-MTH-COS',[x],[math.sin(((int(x*SC+16384.0))&65535)/SC)],'1.4 Mth.cos(%s) table entry'%x)
def wrap(x):
    r=math.fmod(x,360)
    if r>=180: r-=360
    if r<-180: r+=360
    return r
for x in (0,90,180,-180,190,-190,350,720.5,-400):
    t.call('EF7-WRAP-DEGREES',[x],[wrap(x)],'1.4 wrapDegrees(%s)'%x)
for tt,a,b in ((0.5,10,100),(0.25,170,-170),(1,0,359),(0.5,-0.5,0.5)):
    t.call('EF7-ROT-LERP',[tt,a,b],[a+tt*wrap(b-a)],'1.4 rotLerp %s %s to %s'%(tt,a,b)); t.call('EF7-LERP',[tt,a,b],[a+tt*(b-a)],'1.4 lerp %s %s to %s'%(tt,a,b))
for seed,bits,n in ((1660,31,5),(0,24,4),(12345,32,3),(1660,8,6)):
    r=rng7.R(seed); t.call('EF7-RANDOM-SEQ',[1,seed,bits,0,n],[r.next(bits) for _ in range(n)],'1.5 next(%d) from seed %d, %d values'%(bits,seed,n))
for seed,n in ((1660,4),(7,3)):
    r=rng7.R(seed); t.call('EF7-RANDOM-SEQ',[2,seed,0,0,n],[r.nextFloat() for _ in range(n)],'1.5 nextFloat from seed %d, %d values'%(seed,n))
for seed,bound,n in ((1660,7,9),(5,8,5),(99,10,6),(3,1,3),(42,1000,4)):
    r=rng7.R(seed); t.call('EF7-RANDOM-SEQ',[3,seed,bound,0,n],[r.nextInt(bound) for _ in range(n)],'1.5 nextInt(%d) from seed %d, %d values'%(bound,seed,n))
r=rng7.R(1660); t.call('EF7-RANDOM-SEQ',[3,1660,7,0,9],[8-8+r.nextInt(7) for _ in range(9)],'1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4)')
def rotops(shake,age,body,death,sleep):
    ops=[]
    yaw=body
    if shake: yaw=body+math.cos(math.floor(age)*3.25)*PI*0.4000000059604645
    if not sleep: ops.append((3,180-yaw,0,0))
    if death>0: ops.append((4,min(1,math.sqrt((death-1)/20*1.6))*90,0,0))
    ops.append((2,-1,-1,1)); ops.append((1,0,-1.501,0))
    return [len(ops)]+[v for o in ops for v in o]
for a in ((0,10,30,0,0),(1,12.7,30,0,0),(0,10,-45,6,0),(1,3,0,21,0),(0,10,30,1,0),(0,5,90,0,1),(0,5,90,2,0)):
    t.call('EF7-SETUP-ROTATIONS',list(a),rotops(*a),'1.6 setupRotations shaking %d age %s body yaw %s death %s sleeping %d (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate)'%a)
for tr,vis,gl,e in ((1,0,0,(2,1)),(0,1,0,(1,0)),(0,0,1,(3,0)),(0,0,0,(0,0)),(1,1,1,(2,1))):
    t.call('EF7-BODY-RENDER',[tr,vis,gl],list(e),'1.6 body render translucent %d visible %d glowing %d (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF)'%(tr,vis,gl))
for x,y in ((0,0),(5,7),(3,8),(0,8),(15,8),(7,15),(15,15),(8,0)):
    if y<8: e=-1291911168
    else:
        al=int((1-x/15*0.75)*255); e=(al<<24)|0xFFFFFF
        if e>=1<<31: e-=1<<32
    t.call('EF7-OVERLAY-PIXEL',[x,y],[e],'1.6 overlay texel x %d y %d as signed ARGB'%(x,y))
for w,red in ((0,0),(0,1),(1,0),(0.5,1),(0.99,0)):
    t.call('EF7-OVERLAY-COORDS',[w,red],[math.floor(w*15),3 if red else 10],'1.6 overlay coordinates white progress %s red %d (u, v)'%(w,red))
for bl,sk,ov in ((5,12,0),(0,0,0),(15,15,0),(3,9,1)):
    b=15 if ov else bl
    t.call('EF7-LIGHT',[bl,sk,ov],[(b<<4)|(sk<<20)],'1.6 light coords block %d sky %d block light override %d'%(bl,sk,ov))
for r,s in ((0.5,1),(1.5,2),(0.25,0.5)): t.call('EF7-SHADOW',[r,s],[r*s],'1.6 shadow radius %s scale %s'%(r,s))
save(t,7,1)
