from aq8b import *
import math
define_aq()
t=mk(8,7,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 7 (boats and rafts): 7.1 the boat, chest boat, raft, chest raft and water patch meshes (every part, pose and box), 7.2 the paddle animation (set, not added;",
 "the right paddle mirrored), 7.4 the render pose (translate 0.375, Y rotation 180 - yaw, the hurt tilt, the bubble column tilt, scale, Y rotation 90) with the worked examples E12 and E13, 7.4 step 7 (the water patch only for a boat that is not under water),",
 "7.5 passenger seats and the leash offset, and the Validation rows for the boat and the raft. The paddle clock and bubble tick of 7.3 are proved by test_entity_boats and test_entity_boat_hurt."],ck=True)
t.LP='EF8-LAYER'
t.extra_ws+='\n COPY CLSTATE.'
mesh_checks(t,['BOAT','CHEST_BOAT','RAFT','CHEST_RAFT','BOAT_WATER_PATCH'],'7')
def clerp(f,a,b): return a if f<0 else b if f>1 else a+(b-a)*f
def paddles(layer,tl,tr):
    P=base_parts(layer)
    for nm,tt in (('left_paddle',tl),('right_paddle',tr)):
        P[nm][3]=clerp((math.sin(-tt)+1)/2,-1.0471976,-0.2617994)
        y=clerp((math.sin(-tt+1)+1)/2,-0.7853982,0.7853982)
        P[nm][4]=3.1415927-y if nm=='right_paddle' else y
    return P
for layer in ('BOAT','CHEST_BOAT','RAFT','CHEST_RAFT'):
    for tl,tr in ((0,0),(0.3926991,1.2),(2.5,-1.5),(7,3.3)):
        P=paddles(layer,tl,tr)
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin([0,0,tl,tr]); t.raw('CALL "EF8-BOAT-ANIM" USING EMM-MODEL WS-IN')
        for part in ('left_paddle','right_paddle','bottom'):
            for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
# E12: both paddles at rest
t.raw('MOVE "BOAT" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,0,0]); t.raw('CALL "EF8-BOAT-ANIM" USING EMM-MODEL WS-IN')
t.cur('left_paddle','xrot',-0.6544985); t.cur('left_paddle','yrot',0.66089); t.cur('right_paddle','yrot',2.48070); t.cur('left_paddle','zrot',0.19634955)
# 7.4: the ops of the render pose (count, then code and three values per op; 1 translate, 2 scale, 3 rotate Y degrees, 5 rotate X degrees, 8 rotate by the angle about (1, 0, 1))
def seq(yaw,ht,bdm,bhd,bba,buw):
    ops=[(1,0,0.375,0),(3,180-yaw,0,0)]
    h=ht-1
    if h>0: ops.append((5,math.sin(h)*h*max(bdm-1,0)/10*bhd,0,0))
    if buw==0 and abs(bba)>0.00001: ops.append((8,bba,0,0))
    ops+=[(2,-1,-1,1),(3,90,0,0)]
    return [len(ops)]+[v for o in ops for v in o]
for yaw,ht,bdm,bhd,bba,buw in ((90,0,0,1,0,0),(90,6,21,1,0,0),(0,3,11,-1,0,0),(45,0,0,1,4.5,0),(45,0,0,1,4.5,1),(10,6,21,1,-3,0),(10,1,5,1,0.000001,0)):
    t.raw('MOVE 1 TO WS-FL','MOVE %s TO EN-YAW(1)'%lit(yaw),'MOVE %s TO EN-BHT(1)'%lit(ht),'MOVE %s TO EN-BDM(1)'%lit(bdm),'MOVE %s TO EN-BHD(1)'%lit(bhd),'MOVE %s TO EN-BBA(1)'%lit(bba),'MOVE %d TO EN-BUW(1)'%buw,'CALL "ENTITY-BOAT-SEQUENCE" USING CLIENT-STATE WS-FL WS-OUT')
    for k,v in enumerate(seq(yaw,ht,bdm,bhd,bba,buw)): t.num('7.4 pose yaw %s hurtTime %s damage %s dir %s bubble %s under water %d value %d'%(yaw,ht,bdm,bhd,bba,buw,k+1),v,'WS-OV(%d)'%(k+1))
t.num('E13 hurt tilt of the worked example',-9.589,'WS-OV(1) * 0 - 9.589')  if False else None
t.raw('MOVE 1 TO WS-FL','MOVE 90 TO EN-YAW(1)','MOVE 6 TO EN-BHT(1)','MOVE 21 TO EN-BDM(1)','MOVE 1 TO EN-BHD(1)','MOVE 0 TO EN-BBA(1)','MOVE 0 TO EN-BUW(1)','CALL "ENTITY-BOAT-SEQUENCE" USING CLIENT-STATE WS-FL WS-OUT')
t.num('E13 the damaged boat rotates about X by -9.589 degrees',math.sin(5)*5*20/10,'WS-OV(11)'); t.num('E13 the Y rotation is 180 - 90',90,'WS-OV(7)')
# 7.4 step 7
for raft,uw,e in ((0,0,1),(0,1,0),(1,0,0),(1,1,0)):
    t.call('EF8-BOAT-PATCH-DRAWN',[raft,uw],[e],'7.4 water patch for raft %d under water %d'%(raft,uw))
# 7.5 seats and leash
SEAT=((0,0,1,0,0,0,0.1875,2),(1,0,1,0,0,0,0.5,2),(0,1,1,0,0,0.15,0.1875,1),(1,1,1,0,0,0.15,0.5,1),(0,0,0,0,0,0,0.1875,2),
      (0,0,2,0,0,0.2,0.1875,2),(0,0,2,1,0,-0.6,0.1875,2),(0,0,2,0,1,0.4,0.1875,2),(0,0,2,1,1,-0.4,0.1875,2),(1,0,2,1,0,-0.6,0.5,2))
for raft,chest,n,idx,an,xo,y,mx in SEAT:
    t.call('EF8-BOAT-SEAT',[raft,chest,n,idx,an],[0,y,xo,mx],'7.5 seat raft %d chest %d passengers %d index %d animal %d (x, y, z, maximum passengers)'%(raft,chest,n,idx,an))
t.call('EF8-BOAT-LEASH',[1.375,0.5625],[0,0.495,0.88],'7.5 leash offset of the 1.375 x 0.5625 box (x, y, z)')
t.call('EF8-BOAT-LEASH',[2,1],[0,0.88,1.28],'7.5 leash offset of a 2 x 1 box')
save(t,8,7)
