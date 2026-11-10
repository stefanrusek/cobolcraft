from dragon7 import *
import rng7
define()
t=mk(7,8,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 8 (Ender Dragon): 8.1 the 64 sample flight history (record, get, interpolated get), 8.2 the state extraction and head part offset, 8.3 the 36 part mesh,",
 "8.4 setupAnim (jaw, root movement, necks, head, body roll, wings, limbs, tail from the history; example 11.7), 8.5 the pose stack and passes, 8.6 the death ray counts, colours, generator values and vertices (example 11.8),",
 "8.7 the crystal beam (example 11.9) and 8.8 the flap time update. Mesh rows are the table of the document."],ck=True)
t.LP='EF7-LAYER'
t.extra_ws+='''
 01 WS-HIST.
    05 WS-HEAD              BINARY-LONG.
    05 WS-HY                FLOAT-LONG OCCURS 64 TIMES.
    05 WS-HR                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DR                  FLOAT-LONG.
 01 WS-HN                  BINARY-LONG.
 01 WS-HT                  FLOAT-LONG.'''
mesh_checks(t,['ENDER_DRAGON'],'8.3')
def hist_load(samples):
    t.raw('CALL "EF7-HIST-INIT" USING WS-HIST')
    for y,r in samples: t.raw('MOVE %s TO WS-DY'%lit(y),'MOVE %s TO WS-DR'%lit(r),'CALL "EF7-HIST-RECORD" USING WS-HIST WS-DY WS-DR')
def samples(n,ph=0):
    return [(64+5*math.sin((k+ph)*0.3), wrap((k+ph)*37.0)) for k in range(n)]
SM=samples(70)
h0=Hist()
t.raw('CALL "EF7-HIST-INIT" USING WS-HIST'); t.raw('MOVE 0 TO WS-HN','CALL "EF7-HIST-GET" USING WS-HIST WS-HN WS-DY WS-DR'); t.num('8.1 an empty history holds (0, 0): y',0,'WS-DY'); t.num('8.1 an empty history holds (0, 0): yRot',0,'WS-DR'); t.num('8.1 head starts at -1',-1,'WS-HEAD')
hist_load(SM[:1]); h=Hist(); h.record(*SM[0])
t.num('8.1 the first record fills all 64 slots and head becomes 0',0,'WS-HEAD')
t.raw('MOVE 63 TO WS-HN','CALL "EF7-HIST-GET" USING WS-HIST WS-HN WS-DY WS-DR'); t.num('8.1 slot filled by the first sample: y',SM[0][0],'WS-DY')
hist_load(SM); h=Hist()
for s in SM: h.record(*s)
t.num('8.1 after 70 records head wrapped to 5',h.head,'WS-HEAD')
for n in (0,1,5,6,10,63,64,70):
    y,r=h.get(n); t.raw('MOVE %d TO WS-HN'%n,'CALL "EF7-HIST-GET" USING WS-HIST WS-HN WS-DY WS-DR'); t.num('8.1 get(%d) y'%n,y,'WS-DY'); t.num('8.1 get(%d) yRot'%n,r,'WS-DR')
for n,tt in ((0,0.5),(5,0.25),(6,1),(10,0),(11,0.75),(62,0.3)):
    y,r=h.geti(n,tt); t.raw('MOVE %d TO WS-HN'%n,'MOVE %s TO WS-HT'%lit(tt),'CALL "EF7-HIST-GETI" USING WS-HIST WS-HN WS-HT WS-DY WS-DR'); t.num('8.1 get(%d, %s) y'%(n,tt),y,'WS-DY'); t.num('8.1 get(%d, %s) yRot'%(n,tt),r,'WS-DR')
for i,ay,by,ld,sit,dist in ((3,60,62,1,0,100),(3,60,62,1,0,2),(4,60,62,0,1,100),(6,60,62,0,0,100),(2,60,62.5,0,0,100)):
    t.call('EF7-DRAGON-OFFSET',[i,ay,by,ld,sit,dist],[offset(i,ay,by,ld,sit,dist)],'8.2 head part offset i %d a %s b %s landing %d sitting %d distance %s'%(i,ay,by,ld,sit,dist))
for p,o,c,dd,dy,hurt,e in ((0.5,2,4,0,0,0,(3,0,0,0.5)),(0.25,2,4,10,0,3,(2.5,10.25,1,0.25)),(0.5,2,4,10,1,0,(3,10.5,0,0))):
    t.call('EF7-DRAGON-STATE',[p,o,c,dd,dy,hurt],list(e),'8.2 extraction partial %s flap %s to %s death %s dying %d hurt %d (flapTime, deathTime, red overlay, partialTicks)'%(p,o,c,dd,dy,hurt))
def dstate(p,o,c,dd,dy,hurt):
    return [o+p*(c-o), dd+p if dd>0 else 0, 1 if hurt>0 else 0, 0 if dy else p]
t.call('EF7-DRAGON-STATE',[0.5,2,4,0,0,0],dstate(0.5,2,4,0,0,0),'8.2 extraction recomputed (0.5, 2 to 4)')
STS=[(0,0,0,0,50),(3.3,0.5,0,0,50),(10.75,0.25,0,0,50),(1.5,0.9,1,0,2),(7.2,0.6,0,1,50),(20,0,0,0,50),(0.4,1,0,0,50)]
for st in STS:
    P,root=anim(h,st)
    t.raw('MOVE "ENDER_DRAGON" TO WS-LAYER','CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin(list(st)); t.raw('CALL "EF7-DRAGON-ANIM" USING EMM-MODEL WS-HIST WS-IN')
    for part in sorted(P):
        for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
    t.num('8.4 root y',root[1],'MM-CY(1)'); t.num('8.4 root z',root[2],'MM-CZ(1)'); t.num('8.4 root xRot',root[3],'MM-CXROT(1)')
def poseops(yaw7,y5,y10):
    ops=[(3,-yaw7,0,0),(6,(y5-y10)*10,0,0),(1,0,0,1),(2,-1,-1,1),(1,0,-1.501,0)]
    return [len(ops)]+[v for o in ops for v in o]
for a in ((30,66,60),(-120,64,64.5),(0,70,50)): t.call('EF7-DRAGON-POSE-OPS',list(a),poseops(*a),'8.5 pose stack yaw(7) %s y(5) %s y(10) %s (count; code 3 rotate Y deg, 6 rotate X deg, 1 translate, 2 scale)'%a)
for dt,red,beam in ((0,0,0),(0,1,1),(100,0,0),(200,1,1),(0.5,0,1)):
    t.call('EF7-DRAGON-PASSES',[dt,red,beam],[1 if dt>0 else 0,(1-dt/200) if dt>0 else 1,3 if red else 10,1,1 if dt>0 else 0,dt/200,beam],'8.5 passes death %s red %d beam %d (dissolve, alpha, overlay v, eyes, rays, ray p, beam)'%(dt,red,beam))
for k,e in ((0,'dragon.png'),(1,'dragon_exploding.png'),(2,'dragon_eyes.png')): text_check(t,'EF7-DRAGON-TEXTURE',[k],'8.5 texture %d'%k,'textures/entity/enderdragon/'+e)
for p,e in ((0.5,22),(0.9,51),(1,60),(0,0),(0.25,int(((0.25+0.0625)/2)*60))):
    t.call('EF7-DRAGON-RAY-COUNT',[p],[e],'8.6 ray count p %s'%p)
for p,e in ((0.5,0),(0.9,0.5),(1,1),(0.8,0)): t.call('EF7-DRAGON-RAY-COLOR',[p],[e,1-e],'8.6 fade g and centre alpha at p %s'%p)
for p,k in ((0.5,1),(0.9,3),(1,5),(0.2,7)):
    r=rng7.R(432)
    for _ in range(8*(k-1)): r.nextFloat()
    v=[r.nextFloat() for _ in range(8)]; g=min(1,(p-0.8)/0.2) if p>0.8 else 0
    tp=2*math.pi
    t.call('EF7-DRAGON-RAY',[p,k],[v[0]*tp,v[1]*tp,v[2]*tp,v[3]*tp,v[4]*tp,v[5]*tp+p*math.pi/2,v[6]*20+5+g*10,v[7]*2+1+g*2],'8.6 ray %d at p %s (angles x1 y1 z1 x2 y2 z2, length, width)'%(k,p))
for L,W in ((10,1.5),(5,1),(24,3)):
    q=math.sqrt(3)/2*W
    A=(-q,L,-0.5*W);B=(q,L,-0.5*W);C=(0,L,W);O=(0,0,0)
    t.call('EF7-DRAGON-RAY-VERTS',[L,W],[v for tri in ((O,A,B),(O,B,C),(O,C,A)) for pt in tri for v in pt],'8.6 ray triangles length %s width %s (nine vertices x y z)'%(L,W))
for x,y,z,age in ((1,0,0,0),(3,4,-5,10),(-2,1,6,33.5),(0,5,0,7)):
    hh=math.hypot(x,z); ln=math.sqrt(x*x+y*y+z*z)
    t.call('EF7-BEAM',[x,y,z,age],[hh,ln,-math.atan2(z,x)-math.pi/2,-math.atan2(hh,y)-math.pi/2,-age*0.01,ln/32-age*0.01],'8.7 beam header vector (%s, %s, %s) age %s (h, len, rotate Y rad, rotate X rad, v0, v1)'%(x,y,z,age))
t.call('EF7-BEAM',[1,0,0,0],[1,1,-math.pi/2,-math.pi,0,1/32],'8.7 example 11.9 vector (1, 0, 0): Y angle -pi/2, X angle -pi')
def quad(k,ln,age):
    v0=-age*0.01; v1=ln/32-age*0.01
    def xy(kk): a=kk*2*math.pi/8; return (math.sin(a)*0.75,math.cos(a)*0.75)
    X,Y=xy(k); Xp,Yp=(0,0.75) if k==1 else xy(k-1)
    return [Xp*0.2,Yp*0.2,0,-16777216,(k-1)/8,v0, Xp,Yp,ln,-1,(k-1)/8,v1, X,Y,ln,-1,k/8,v1, X*0.2,Y*0.2,0,-16777216,k/8,v0]
for k in range(1,9): t.call('EF7-BEAM-QUAD',[k,12.5,5],quad(k,12.5,5),'8.7 tube quad %d length 12.5 age 5 (four vertices x y z colour u v)'%k)
for sit,wall,hs,vv,fl in ((1,0,0.5,0,3),(0,1,0.3,0.5,2),(0,0,0.1,-0.5,1),(0,0,0,0,0)):
    f=0.2/(hs*10+1)*2**vv; e=fl+(0.1 if sit else f*0.5 if wall else f)
    t.call('EF7-DRAGON-FLAP',[sit,wall,hs,vv,fl],[e],'8.8 flap time update sitting %d in wall %d horizontal speed %s vertical %s flap %s'%(sit,wall,hs,vv,fl))
t.call('EF7-DRAGON-BEAM-OFFSET',[10,70,5,3.25,8,65,2],[2,5+gety(3.25) if False else 70+(math.sin(0.2*3.25)/2+0.5 if False else 0)-65, 3],'8.2 beam offset (coded below)') if False else None
def cy(a):
    f=math.sin(0.2*a)/2+0.5; f=(f*f+f)*0.4; return f-1.4
t.call('EF7-DRAGON-BEAM-OFFSET',[10,70,5,3.25,8,65,2],[2,70+cy(3.25)-65,3],'8.2 beam offset crystal (10,70,5) time 3.25 dragon (8,65,2)')
t.call('EF7-DRAGON-DIST',[3,60,4,1,63,0],[(3.5-1)**2+(60.5-63)**2+(4.5-0)**2],'8.2 squared distance from the egg block centre')
save(t,7,8)
