from mesh5 import *
from ref4 import sample,apply,keytests,KWS
import app5
t=mk(5,11,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 11 (Frog): the mesh table (16 parts, the model root child root), setupAnim (jump, croak and tongue states, swim or walk keyframes with their factors,",
 "the swim idle state, croaking_body visibility), the FROG keyframe tables of section 15.3 (every channel sampled by an independent engine), the texture path and the shadow radius. Mesh rows are the table of the document."],ck=True)
t.extra_ws+='\n'+KWS
r,tex=expected('FROG'); t.build('FROG')
# the row of the child named root has the model root as parent; the row checker resolves parent names by lookup (which finds the child itself), so it is checked below
t.rows('%s 11 FROG'%t.prefix,[x for x in r if not x.startswith('P root root')])
t.raw('MOVE "root" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-FL'); t.num('11 the child named root has the model root (part 1) as parent',1,'MM-PARENT(WS-FL)')
for k,v in (('x',0),('y',24),('z',0)): t.cur('root',k,v)
p,c=sizes(r); t.stats('11 FROG',p,c,float(tex[0]),float(tex[1]))
AN=app5.parse('15.3')
NM=[a['name'] for a in AN]
keytests(t,'EF5G',None,NM,AN,'15.3')
STOP=-2147483648
t.raw('MOVE "FROG" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK','MOVE "root" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
t.num('11 the child root is part 2 (below the model root)',2,'WS-P')
for ch in ('body','left_leg','right_leg'):
    t.raw('MOVE "%s" TO WS-PN'%ch,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-FL')
    t.num('11 %s is a child of the child root'%ch,2,'MM-PARENT(WS-FL)')
def frog(st):
    p,s,age,swim,js,cs,ts,ws=st
    P={}
    for r in expected('FROG')[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    for nm,s0 in (('FROG_JUMP',js),('FROG_CROAK',cs),('FROG_TONGUE',ts)):
        if s0!=STOP: apply(AN[NM.index(nm)],int((age-s0)*50),1,P)
    if swim: apply(AN[NM.index('FROG_SWIM')],int(p*50*1),min(s*2.5,1),P)
    else: apply(AN[NM.index('FROG_WALK')],int(p*50*1.5),min(s*2.5,1),P)
    if ws!=STOP: apply(AN[NM.index('FROG_IDLE_WATER')],int((age-ws)*50),1,P)
    return P,(0 if cs==STOP else 1)
#  p s age swimming jump croak tongue swimIdle
STS=[(2.0,0.4,10.5,0,STOP,STOP,STOP,STOP),(1.25,0.9,30.25,0,3,STOP,STOP,STOP),(0.5,0.1,12,1,STOP,4,STOP,STOP),(3.25,1,50.5,1,STOP,STOP,45,2),(0,0,0,0,0,0,0,0),(2.75,0.6,80.75,0,60,20,70,STOP),(4.5,0.2,22.5,1,STOP,STOP,STOP,10),(1.5,0.7,100,0,STOP,STOP,STOP,STOP)]
for st in STS:
    t.raw('MOVE "FROG" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF5-FROG-ANIM" USING EMM-MODEL WS-IN')
    P,cv=frog(st)
    for part in sorted(P):
        for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
    t.vis('croaking_body',cv)
# E8: the left arm rot at t=0.15 s
t.raw('MOVE "FROG" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([2.0,0.4,0,0,STOP,STOP,STOP,STOP]); t.raw('CALL "EF5-FROG-ANIM" USING EMM-MODEL WS-IN')
t.cur('left_arm','xrot',3.857*0.017453292); t.cur('left_arm','yrot',-3.802*0.017453292); t.cur('left_arm','zrot',-3.857*0.017453292)
for a,e in (('entity/frog/frog_cold','textures/entity/frog/frog_cold.png'),('entity/frog/frog_warm','textures/entity/frog/frog_warm.png'),('','textures/entity/frog/frog_temperate.png')):
    t.raw('MOVE "%s" TO WS-X40'%a if a else 'MOVE SPACES TO WS-X40','MOVE SPACES TO WS-X120','CALL "EF5-FROG-TEXTURE" USING WS-X40 WS-X120'); t.text('11 texture of variant asset "%s"'%a,e,'WS-X120')
t.call('EF5-FROG-SHADOW',[],[0.3],'11 shadow radius')
save(t,5,11)
