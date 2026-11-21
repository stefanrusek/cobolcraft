from mesh6 import *
setlayer('ENDERMAN',doc6.rows_from(6,'### 3.1'),64,32)
t=mk(6,3,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 3 (Enderman): 3.1 the mesh (humanoid parts replaced, hat a child of the head, long limbs), 3.2 setupAnim (the humanoid base of 34-2 section 4.1, then the",
 "head visible, limb swing halved and clamped to 0.4, the carried block arm pose, the creepy head and hat offsets), 3.3 texture, render offset shake, the eyes layer texture and the carried block layer transform."],ck=True)
t.LP='EF6-LAYER'; t.extra_ws+=STATE_WS
mesh_checks(t,['ENDERMAN'],'3.1')
def clamp(v): return max(-0.4,min(0.4,v))
def ender(st,carried,creepy):
    xr,yr,wp,ws,sv,age=st
    P=base_parts('ENDERMAN'); base_humanoid(P,xr,yr,wp,ws,sv,age)
    for n in ('right_arm','left_arm','right_leg','left_leg'): P[n][3]=clamp(P[n][3]*0.5)
    if carried:
        P['right_arm'][3]=-0.5; P['left_arm'][3]=-0.5; P['right_arm'][5]=0.05; P['left_arm'][5]=-0.05
    if creepy:
        P['head'][1]-=5; P['hat'][1]+=5
    return P
for st,car,cr in (((10,-20,1.0,1.0,1,12.5),0,0),((0,0,0,0,1,0),0,0),((-15,40,3.5,0.4,1,40),1,0),((5,5,2,0.9,1,7.25),0,1),((25,-90,7.25,0.2,1,22.5),1,1),((12,3,0.5,0.1,2,3),0,0),((0,0,1.5,0.3,1,100),1,0)):
    humanoid_state(t,{1:st[0],2:st[1],3:st[2],4:st[3],5:st[4],6:st[5],12:1,13:1})
    t.raw('MOVE "ENDERMAN" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK','MOVE %d TO WS-CAR'%car,'MOVE %d TO WS-CRE'%cr,'CALL "EF6-ENDERMAN-ANIM" USING EMM-MODEL WS-ST WS-CAR WS-CRE')
    P=ender(st,car,cr)
    for part in sorted(P):
        for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
    t.vis('head',1)
t.text('3.3 texture','textures/entity/enderman/enderman.png','WS-X120') if False else None
text_check(t,'EF6-ENDERMAN-TEXTURE',[0],'3.3 texture','textures/entity/enderman/enderman.png')
text_check(t,'EF6-ENDERMAN-TEXTURE',[1],'3.3 eyes layer texture','textures/entity/enderman/enderman_eyes.png')
for creepy,g1,g2,sc,base in ((1,0.5,-1.25,1,(0,0,0)),(1,-2,0.3,1.5,(0.1,0.2,0.3)),(0,0.5,-1.25,1,(0,0,0)),(0,3,3,2,(1,2,3))):
    o=[base[0]+(g1*0.02*sc if creepy else 0),base[1],base[2]+(g2*0.02*sc if creepy else 0)]
    t.call('EF6-ENDERMAN-OFFSET',[creepy,g1,g2,sc]+list(base),o,'3.3 render offset creepy %d gaussians %s %s scale %s (x, y, z)'%(creepy,g1,g2,sc))
ops=[(1,0,0.6875,-0.75),(6,20,0,0),(3,45,0,0),(1,0.25,0.1875,0.25),(2,-0.5,-0.5,0.5),(3,90,0,0)]
t.call('EF6-ENDERMAN-BLOCK-OPS',[1],[6]+[x for o in ops for x in o],'3.3 carried block layer transform stack (count; code 1 translate 2 scale 3 rotate Y deg 6 rotate X deg; values)')
t.call('EF6-ENDERMAN-BLOCK-OPS',[0],[0],'3.3 carried block layer is skipped when no block is carried')
save(t,6,3)
