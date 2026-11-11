from mesh5 import *
t=mk(5,9,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 9 (Bee): 9.1 the adult, baby and stinger meshes, 9.2 setupAnim (stinger visibility, wing flap and leg angles in the air, the bob when not angry and not on the ground,",
 "antennae of the adult, the roll with rotLerpRad), 9.3 the textures by angry and nectar flags, the shadow radius, the roll counter. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
mesh_checks(t,['BEE','BEE_BABY','BEE_STINGER'],'9.1')
PI=math.pi
def wrapr(d):
    while d>=PI: d-=2*PI
    while d<-PI: d+=2*PI
    return d
def bee(layer,baby,st):
    A,sting,ground,angry,roll=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    vis=sting
    if not ground:
        w=A*120.32113*0.017453292
        rw,lw=P['right_wing'],P['left_wing']
        rw[4]=0; rw[5]=math.cos(w)*PI*0.15
        lw[3]=rw[3]; lw[4]=rw[4]; lw[5]=-rw[5]
        for n in ('front_legs','middle_legs','back_legs'): P[n][3]=0.7853982
    if not angry and not ground:
        c=math.cos(0.18*A)
        P['bone'][3]=0.1+c*PI*0.025; P['bone'][1]-=math.cos(0.18*A)*0.9
        P['front_legs'][3]=-c*PI*0.1+0.3926991; P['back_legs'][3]=-c*PI*0.05+0.7853982
        if not baby:
            P['left_antenna'][3]=c*PI*0.03; P['right_antenna'][3]=c*PI*0.03
    if roll>0:
        a=P['bone'][3]; P['bone'][3]=a+roll*wrapr(3.0915928-a)
    return P,vis
#  A  stinger ground angry roll
STS=[(10.5,1,0,0,0),(3.2,0,0,1,0),(7,1,1,0,0),(0.7,1,1,1,0.5),(22.25,0,0,0,0.6),(40,1,0,0,1),(5,1,0,1,0.25),(0,1,0,0,0)]
for layer,baby in (('BEE',0),('BEE_BABY',1)):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby]); t.raw('CALL "EF5-BEE-ANIM" USING EMM-MODEL WS-IN')
        P,vis=bee(layer,baby,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
        t.vis('stinger',vis)
# E15
t.raw('MOVE "BEE" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([1/(120.32113*0.017453292)*2.1,1,0,1,0,0]); t.raw('CALL "EF5-BEE-ANIM" USING EMM-MODEL WS-IN')
t.cur('right_wing','zrot',math.cos(2.1)*PI*0.15); t.cur('left_wing','zrot',-math.cos(2.1)*PI*0.15); t.cur('right_wing','yrot',0); t.cur('left_wing','yrot',0)
for an,ne,baby in ((1,1,0),(1,0,0),(0,1,0),(0,0,0),(1,1,1),(1,0,1),(0,1,1),(0,0,1)):
    nm='bee_angry_nectar' if an and ne else 'bee_angry' if an else 'bee_nectar' if ne else 'bee'
    t.raw('MOVE %d TO WS-IV(1)'%an,'MOVE %d TO WS-IV(2)'%ne,'MOVE %d TO WS-IV(3)'%baby,'CALL "EF5-BEE-TEXTURE" USING WS-IN WS-X120')
    t.text('9.3 texture angry %d nectar %d baby %d'%(an,ne,baby),'textures/entity/bee/%s%s.png'%(nm,'_baby' if baby else ''),'WS-X120')
t.call('EF5-BEE-SHADOW',[],[0.4],'9.3 shadow radius')
for ground,sq,e in ((1,0,1),(1,2e-7,0),(1,0.9e-7,1),(0,0,0),(0,1e-9,0)):
    t.call('EF5-BEE-ONGROUND',[ground,sq],[e],'9.3 isOnGround on ground %d squared speed %s'%(ground,sq))
for o,c,tt in ((0,0,0.5),(0.2,0.6,0.25),(1,0.4,0.75),(0.3,0.3,1)):
    t.call('EF5-BEE-ROLL-LERP',[tt,o,c],[o+tt*(c-o)],'9.3 rollAmount partial %s old %s current %s'%(tt,o,c))
def rollstep(r,rolling):
    return min(1,r+0.2) if rolling else max(0,r-0.24)
for r,ro in ((0,1),(0.9,1),(1,1),(0.5,0),(0.1,0),(0,0)):
    n=rollstep(r,ro); t.call('EF5-BEE-ROLL-TICK',[r,ro],[r,n],'9.3 roll counter %s rolling %d (old, new)'%(r,ro))
save(t,5,9)
