from mesh5 import *
t=mk(5,13,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 13 (Turtle): 13.1 the adult and baby meshes, 13.2 setupAnim (the quadruped base, then land gait with the laying factors, the water paddle,",
 "the egg belly and the root offset of the adult), 13.3 textures, the shadow radius with the baby factor and the state flags. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
mesh_checks(t,['TURTLE','TURTLE_BABY'],'13.1')
PI=math.pi
def turtle(layer,baby,st):
    xr,yr,p,s,land,lay,egg=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    H=P['head']; H[3]=xr*D; H[4]=yr*D
    RH,LH,RF,LF=P['right_hind_leg'],P['left_hind_leg'],P['right_front_leg'],P['left_front_leg']
    RH[3]=math.cos(0.6662*p)*1.4*s; LH[3]=math.cos(0.6662*p+PI)*1.4*s; RF[3]=math.cos(0.6662*p+PI)*1.4*s; LF[3]=math.cos(0.6662*p)*1.4*s
    if land:
        f1=4 if lay else 1; f2=2 if lay else 1; q=5*p; c1=math.cos(f1*q); c2=math.cos(q)
        RF[4]=-c1*8*s*f2; LF[4]=c1*8*s*f2; RH[4]=-c2*3*s; LH[4]=c2*3*s
    else:
        m=0.5*s; u=math.cos(0.6662*0.6*p)*m
        RH[3]=u; LH[3]=-u; RF[5]=-u; LF[5]=u
    vis=None; rooty=0
    if not baby:
        vis=egg
        if egg: rooty=-1
    return P,vis,rooty
#  xRot yRot p s land laying egg
STS=[(10,-20,1.0,1.0,1,0,0),(10,-20,1.0,1.0,1,1,0),(-15,30,2.5,0.5,0,0,1),(5,5,0.7,0.3,1,1,1),(0,0,0,0,0,0,0),(25,-40,3.3,0.8,1,0,1),(-5,12,4.1,0.6,0,1,0)]
for layer,baby in (('TURTLE',0),('TURTLE_BABY',1)):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby]); t.raw('CALL "EF5-TURTLE-ANIM" USING EMM-MODEL WS-IN')
        P,vis,ry=turtle(layer,baby,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
        if vis is not None: t.vis('egg_belly',vis)
        t.num('13.2 root y',ry,'MM-CY(1)')
# E13
t.raw('MOVE "TURTLE" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1,1,1,0,0,0]); t.raw('CALL "EF5-TURTLE-ANIM" USING EMM-MODEL WS-IN')
t.cur('right_front_leg','yrot',-math.cos(5)*8); t.cur('right_hind_leg','yrot',-math.cos(5)*3)
t.raw('MOVE "TURTLE" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1,1,1,1,0,0]); t.raw('CALL "EF5-TURTLE-ANIM" USING EMM-MODEL WS-IN')
t.cur('right_front_leg','yrot',-math.cos(20)*8*2)
for b in (0,1):
    t.raw('MOVE SPACES TO WS-X120','MOVE %d TO WS-IV(1)'%b,'CALL "EF5-TURTLE-TEXTURE" USING WS-IN WS-X120'); t.text('13.3 texture baby %d'%b,'textures/entity/turtle/turtle%s.png'%('_baby' if b else ''),'WS-X120')
for b,sc in ((0,1),(0,2),(1,1),(1,2),(1,0.5)):
    t.call('EF5-TURTLE-SHADOW',[b,sc],[0.7*sc*(0.83 if b else 1)],'13.3 shadow baby %d scale %s'%(b,sc))
for w,g,lay,egg,baby in ((0,1,0,1,0),(1,1,0,1,0),(0,0,0,1,0),(0,1,1,0,0),(0,1,0,1,1),(1,0,1,0,1)):
    land=1 if (not w and g) else 0
    t.call('EF5-TURTLE-STATE',[w,g,lay,egg,baby],[land,lay,1 if (egg and not baby) else 0],'13.3 state in water %d on ground %d laying %d has egg %d baby %d (isOnLand, isLayingEgg, hasEgg)'%(w,g,lay,egg,baby))
save(t,5,13)
