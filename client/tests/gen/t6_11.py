from guard6 import *
define()
t=mk(6,11,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 11 (Guardian and elder guardian): 11.1 the mesh (five head boxes, tail fin) and the elder layer scaled 2.35, 11.2 the twelve spikes (worked example 15.12),",
 "11.3 setupAnim (head look, spike positions, the eye tracking the look target, tail wave), 11.4 render state lerps, the client tail and spike value tables, attack timing, 11.5 textures and the cull box, 11.6 the beam (colour, matrix angles, points, quads),",
 "11.7 the elder apparition particle."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['GUARDIAN','ELDER_GUARDIAN'],'11.1')
def guard(layer,st):
    xr,yr,sa,age,ta,have,lay_,eyey,ldx,ldz,ex,ez,lax,laz=st
    P=base_parts(layer)
    P['head'][3]=xr*0.017453292; P['head'][4]=yr*0.017453292
    e=(1-sa)*0.55; sc=P['head']  # spikes are children of the head; positions are in the unscaled head space
    for i,(xr_,yr_,zr_,sx,sy,sz) in enumerate(SP):
        k=o(i,age,e)
        n=P['spike%d'%i]
        if layer=='ELDER_GUARDIAN': pass
        n[0]=sx*k; n[1]=16+sy*k; n[2]=sz*k
    if have:
        dy=lay_-eyey_ if False else lay_-eyey
        P['eye'][1]=0 if dy>0 else 1
        vx,vz=ex-lax,ez-laz; ln=math.hypot(vx,vz)
        if ln<1e-5: d=0
        else:
            vx/=ln; vz/=ln; c=math.cos(1.5707964); s=math.sin(1.5707964)
            rx=vx*c+vz*s; rz=vz*c-vx*s
            d=ldx*rx+ldz*rz
        P['eye'][0]=math.sqrt(abs(d))*2*(1 if d>0 else -1 if d<0 else 0)
    P['tail0'][4]=math.sin(ta)*math.pi*0.05; P['tail1'][4]=math.sin(ta)*math.pi*0.1; P['tail2'][4]=math.sin(ta)*math.pi*0.15
    return P
#   xRot yRot spikes age tail have lookAtY eyeY ldx ldz eyeX eyeZ lookAtX lookAtZ
STS=[(10,-20,1,0,0,0,0,0,0,0,0,0,0,0),(0,0,0,0,0,0,0,0,0,0,0,0,0,0),(-15,40,0.5,12.5,1.3,1,66,65,0.6,0.8,10,10,13,14),(5,5,0,2,2.5,1,64,65,0,1,0,0,1,0),
     (5,5,1,33.25,0.4,1,70,65,1,0,0,0,0,5),(0,0,0.25,7,5,1,60,65,-1,0,3,3,3,3),(25,-90,0.8,20.5,3.7,1,65,65,0.3,-0.9,-4,6,2,-1)]
for layer in ('GUARDIAN','ELDER_GUARDIAN'):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF6-GUARDIAN-ANIM" USING EMM-MODEL WS-IN')
        P=guard(layer,st)
        for part in sorted(P):
            for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
        t.vis('eye',1)
# example 15.12: spike 2 at age 0
t.build('GUARDIAN')
for p,e in (('spike0',(0,7.92,8.08)),('spike2',(7.9667,8.0333,0))):
    for k,v in zip('xyz',e): t.cur(p,k,v)
t.raw('MOVE "GUARDIAN" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,0,0,0,0,0,0,0,0,0,0,0,0]); t.raw('CALL "EF6-GUARDIAN-ANIM" USING EMM-MODEL WS-IN')
t.cur('spike2','x',3.56672); t.cur('spike2','y',12.43328); t.cur('spike2','z',0)
t.raw('MOVE "GUARDIAN" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1,0,0,0,0,0,0,0,0,0,0,0]); t.raw('CALL "EF6-GUARDIAN-ANIM" USING EMM-MODEL WS-IN')
t.cur('spike2','x',7.9667); t.cur('spike2','y',8.0333)
def gtick(w,mv,v,tail,k,rnd):
    if not w: v=2
    elif mv and v<0.5: v=4.0
    elif mv: v+=(0.5-v)*0.1
    else: v+=(0.125-v)*0.2
    if not w: k2=rnd
    elif mv: k2=k+(0-k)*0.25
    else: k2=k+(1-k)*0.06
    return [tail,tail+v,v,k,k2]
for w,mv,v,tail,k,rnd in ((0,0,1,5,0.4,0.37),(1,1,0.2,5,0.4,0.1),(1,1,0.7,6,0.9,0.1),(1,0,3,7,0.5,0.1),(1,0,0.125,8,1,0.1),(0,1,4,9,0.2,0.88)):
    t.call('EF6-GUARDIAN-TICK',[w,mv,v,tail,k,rnd],gtick(w,mv,v,tail,k,rnd),'11.4 client tick in water %d moving %d speed %s tail %s spikes %s random %s (old tail, tail, speed, old spikes, spikes)'%(w,mv,v,tail,k,rnd))
for p,a,b in ((0.5,2,4),(0,1,3),(1,0.2,0.8)): t.call('EF6-GUARDIAN-LERP',[p,a,b],[a+p*(b-a)],'11.4 client animation lerp partial %s %s to %s'%(p,a,b))
for el,e in ((0,80),(1,60)): t.call('EF6-GUARDIAN-DURATION',[el],[e],'11.4 attack duration elder %d'%el)
for p,ct,du in ((0.5,10,80),(0,0,80),(0.25,30,60),(1,59,60)):
    t.call('EF6-GUARDIAN-ATTACK',[p,ct,du],[(ct+p)/du,ct+p],'11.4 attack partial %s time %d duration %d (attackScale, attackTime)'%(p,ct,du))
for ct,tg,du in ((10,1,80),(79,1,80),(80,1,80),(10,0,80),(59,1,60),(60,1,60)):
    t.call('EF6-GUARDIAN-ATTACK-TICK',[ct,tg,du],[ct+1 if tg and ct<du else ct],'11.4 attack time tick %d target %d duration %d'%(ct,tg,du))
text_check(t,'EF6-GUARDIAN-TEXTURE',[0],'11.5 guardian texture','textures/entity/guardian/guardian.png')
text_check(t,'EF6-GUARDIAN-TEXTURE',[1],'11.5 elder guardian texture','textures/entity/guardian/guardian_elder.png')
text_check(t,'EF6-GUARDIAN-TEXTURE',[2],'11.5 beam texture','textures/entity/guardian/guardian_beam.png')
t.call('EF6-GUARDIAN-CULLBOX',[1,64,2,5,60,-3,1.8],[1,60,-3,5,64.9+0.0,2],'11.5 cull box spanned by the eye and the target centre (target y 60 plus 0.9)') if False else None
for eye,tgt,h in (((1,64,2),(5,60,-3),1.8),((0,0,0),(0,0,0),2),((-3,70,4),(-4,66.5,9),0.6)):
    cy=tgt[1]+0.5*h
    lo=[min(eye[0],tgt[0]),min(eye[1],cy),min(eye[2],tgt[2])]; hi=[max(eye[0],tgt[0]),max(eye[1],cy),max(eye[2],tgt[2])]
    t.call('EF6-GUARDIAN-CULLBOX',list(eye)+list(tgt)+[h],lo+hi,'11.5 cull box eye %s target %s height %s (min xyz, max xyz)'%(eye,tgt,h))
for sc in (0,0.5,1,0.25):
    c=sc*sc
    t.call('EF6-GUARDIAN-BEAM-COLOR',[sc],[64+int(c*191),32+int(c*191),128-int(c*64)],'11.6 beam colour attackScale %s (red, green, blue)'%sc)
t.call('EF6-GUARDIAN-BEAM-COLOR',[0],[64,32,128],'11.6 example 15.12 colour at attackScale 0'); t.call('EF6-GUARDIAN-BEAM-COLOR',[0.5],[111,79,112],'11.6 example 15.12 colour at 0.5'); t.call('EF6-GUARDIAN-BEAM-COLOR',[1],[255,223,64],'11.6 example 15.12 colour at 1')
def beam(dx,dy,dz,at):
    L=math.sqrt(dx*dx+dy*dy+dz*dz)+1; ln=L-1; ny=dy/ln; a=math.acos(ny); b=math.pi/2-math.atan2(dz/ln,dx/ln)
    ph=(at*0.5)%1; th=at*0.05*-1.5
    return [L,b*57.295776,a*57.295776,th,ph]
for d,at in (((0,3,0),12),((2,-1,3),7.5),((-4,2,1),40),((1,0,0),0),((0,1,2),3),((0,-2,-3),8.5),((-1,1,-2),4),((-2,0,0),1)):
    t.call('EF6-GUARDIAN-BEAM',list(d)+[at],beam(*d,at),'11.6 beam header delta %s attackTime %s (L, rotate Y degrees, rotate X degrees, th, ph)'%(d,at))
def quads(th,L,at):
    ph=(at*0.5)%1; v0=-1+ph; v1=v0+L*2.5
    pi=math.pi
    def pt(r,ang): return (r*math.cos(ang),r*math.sin(ang))
    A=pt(0.2,th+pi); B=pt(0.2,th); C=pt(0.2,th+pi/2); D=pt(0.2,th+3*pi/2)
    P1=pt(0.282,th+3*pi/4); P2=pt(0.282,th+pi/4); P3=pt(0.282,th+7*pi/4); P4=pt(0.282,th+5*pi/4)
    f=0.5 if math.floor(at)%2==0 else 0
    v=[(A[0],L,A[1],0.4999,v1),(A[0],0,A[1],0.4999,v0),(B[0],0,B[1],0,v0),(B[0],L,B[1],0,v1),
       (C[0],L,C[1],0.4999,v1),(C[0],0,C[1],0.4999,v0),(D[0],0,D[1],0,v0),(D[0],L,D[1],0,v1),
       (P1[0],L,P1[1],0.5,f+0.5),(P2[0],L,P2[1],1,f+0.5),(P3[0],L,P3[1],1,f),(P4[0],L,P4[1],0.5,f)]
    return [x for q in v for x in q]
for th,L,at in ((0.3,4,12),(-1.2,2.5,7.5),(0,1,0),(2.2,9.75,41.9)):
    t.call('EF6-GUARDIAN-BEAM-QUADS',[th,L,at],quads(th,L,at),'11.6 beam vertices th %s length %s attackTime %s (12 vertices of x, y, z, u, v)'%(th,L,at))
for age,part in ((0,0),(10,0.5),(30,0),(15,0.25)):
    f=(age+part)/30
    t.call('EF6-ELDER-PARTICLE',[age,part],[0.05+0.5*math.sin(f*3.1415927),3,6,60-150*f,0,0,2,0.42553192,-0.42553192,-0.42553192,1,0,-0.56,3.5],'11.7 apparition age %d partial %s (alpha, op count; rotate X degrees; scale; translate)'%(age,part))
save(t,6,11)
