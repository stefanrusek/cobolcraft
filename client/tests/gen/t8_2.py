from aq8 import *
define()
t=mk(8,2,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 2 (squid and glow squid): 2.1 the adult and baby meshes with the eight tentacles on a ring (double precision cos and sin), 2.2 setupAnim (tentacle xRot set from the angle),",
 "the render state lerps, the entity tentacle angle and body rotation updates (Squid.aiStep), setupRotations, textures and the glow squid block light."],ck=True)
t.LP='EF8-LAYER'
mesh_checks(t,['SQUID','SQUID_BABY','GLOW_SQUID','GLOW_SQUID_BABY'],'2.1')
t.build('SQUID')
for i,(x,z,ry) in enumerate(((5,0,1.5708),(3.53553,3.53553,0.7854),(0,5,0),(-3.53553,3.53553,-0.7854),(-5,0,-1.5708),(-3.53553,-3.53553,-2.3562),(0,-5,-3.1416),(3.53553,-3.53553,-3.9270))):
    t.cur('tentacle%d'%i,'x',x); t.cur('tentacle%d'%i,'z',z); t.cur('tentacle%d'%i,'yrot',ry)
for layer in ('SQUID','SQUID_BABY','GLOW_SQUID'):
    for ang in (0,0.3,-0.5,0.785):
        P=base_parts(layer)
        for i in range(8): P['tentacle%d'%i][3]=ang
        pose_check(t,layer,'EF8-SQUID-ANIM',[ang],P)
for p,oa,a,ox,x,oz,z in ((0.5,0.2,0.4,10,20,30,50),(0,1,2,3,4,5,6),(1,-1,1,0,-90,10,-10)):
    t.call('EF8-SQUID-STATE',[p,oa,a,ox,x,oz,z],[oa+p*(a-oa),ox+p*(x-ox),oz+p*(z-oz)],'2 state lerps partial %s (tentacleAngle, xBodyRot, zBodyRot)'%p)
PI=3.1415927
def tent(m,sp,water):
    m=m+sp
    if m>2*PI: m=2*PI
    rs=None
    if water:
        if m<PI:
            p=m/PI; ang=math.sin(p*p*PI)*PI*0.25; rs=('set1' if p>0.75 else 'x0.8')
        else: ang=0; rs='x0.99'
    else: ang=abs(math.sin(m))*PI*0.25
    return m,ang,rs
def rsp(rs,r):
    return 1 if rs=='set1' else r*0.8 if rs=='x0.8' else r*0.99 if rs=='x0.99' else r
for m,sp,water,r in ((2.5,0.1,1,0.5),(0,0.15,1,0.5),(2.0,0.15,1,0.5),(3.0,0.15,1,0.5),(3.1,0.15,1,0.7),(6.2,0.15,1,0.9),(1.0,0.2,0,0.5),(5.0,0.2,0,0.5)):
    m2,ang,rs=tent(m,sp,water)
    t.call('EF8-SQUID-TENTACLE',[m,sp,water,r],[m2,ang,rsp(rs,r)],'2 client tentacle update movement %s speed %s in water %d rotate speed %s (movement, angle, rotate speed)'%(m,sp,water,r))
def body(water,rs,yb,zb,xb,vx,vy,vz):
    if water:
        h=math.hypot(vx,vz)
        yb=yb+(-math.atan2(vx,vz)*57.295776-yb)*0.1
        zb=zb+PI*rs*1.5
        xb=xb+(-math.atan2(h,vy)*57.295776-xb)*0.1
    else: xb=xb+(-90-xb)*0.02
    return [yb,zb,xb]
for a in ((1,0.5,10,5,20,0.2,0.1,0.3),(1,1,-50,0,0,-0.1,-0.2,0.05),(0,0.5,10,5,20,0,0,0),(1,0.8,170,30,-45,0,0.4,-0.3)):
    t.call('EF8-SQUID-BODY',list(a),body(*a),'2 body rotation update %s (yBodyRot, zBodyRot, xBodyRot)'%(a,))
def rot(body_,xb,zb,baby):
    return [5,1,0,0.25 if baby else 0.5,0, 3,180-body_,0,0, 6,xb,0,0, 3,zb,0,0, 1,0,-0.6 if baby else -1.2,0]
def rotops(b,xb,zb,baby):
    ops=[(1,0,0.25 if baby else 0.5,0),(3,180-b,0,0),(6,xb,0,0),(3,zb,0,0),(1,0,-0.6 if baby else -1.2,0)]
    return [len(ops)]+[v for o in ops for v in o]
for a in ((30,10,20,0),(30,10,20,1),(-90,-45,5,0)):
    t.call('EF8-SQUID-ROT-OPS',list(a),rotops(*a),'2.2 setupRotations body %s xBodyRot %s zBodyRot %s baby %s (count; code 1 translate, 3 rotate Y deg, 6 rotate X deg)'%a)
for g,b,e in ((0,0,'squid/squid.png'),(0,1,'squid/squid_baby.png'),(1,0,'squid/glow_squid.png'),(1,1,'squid/glow_squid_baby.png')):
    text_check(t,'EF8-SQUID-TEXTURE',[g,b],'2.2 texture glow %d baby %d'%(g,b),e)
def clamped(t_,a,b): return a if t_<0 else b if t_>1 else a+(b-a)*t_
for d,n in ((-5,3),(5,3),(0,3),(10,3),(12,8),(100,2),(3,15),(7.5,0)):
    i=int(clamped(1-d/10,0,15)); e=15 if i==15 else max(i,n)
    t.call('EF8-GLOW-LIGHT',[d,n],[e],'2.2 glow squid block light dark ticks %s normal %s'%(d,n))
t.call('EF8-GLOW-LIGHT',[5,0],[7],'2.2 counter 5 gives i = 7'); t.call('EF8-GLOW-LIGHT',[0,2],[15],'2.2 counter 0 gives 15'); t.call('EF8-GLOW-LIGHT',[10,0],[0],'2.2 counter 10 gives 0')
t.raw('MOVE "NO_SUCH_LAYER" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.num('2 a layer that is not of this document is not known (coverage-only addition)',0,'WS-OK')
save(t,8,2)
