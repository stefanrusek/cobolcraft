from mesh4 import *
t=mk(4,3,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 3 (Mooshroom): 3.1 the layers (geometry of cow and cow_baby), variant enum with the clamping id map, the texture table, setupAnim as the cow,",
 "3.2 the mushroom layer (when it is drawn, the outline-only case, the pose operations of the three block copies). Mesh rows are the tables of 2.3 reached through the layer ids of 3.1."],ck=True)
IDS=['MOOSHROOM','MOOSHROOM_BABY','WARM_COW_BABY','COLD_COW_BABY']
mesh_checks(t,IDS,'3.1')
for vid,e in ((0,0),(1,1),(2,0),(5,0),(-1,0)):
    # id map clamps: out-of-range ids give the nearest valid ordinal
    e={-1:0,2:1,5:1}.get(vid,vid)
    t.call('EF4-MOOSHROOM-VARIANT',[vid],[e],'3.1 variant id %d clamps to ordinal'%vid)
for v,b,tx in ((0,0,'textures/entity/cow/mooshroom_red.png'),(0,1,'textures/entity/cow/mooshroom_red_baby.png'),(1,0,'textures/entity/cow/mooshroom_brown.png'),(1,1,'textures/entity/cow/mooshroom_brown_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%v,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-MOOSHROOM-TEXTURE" USING WS-IN WS-X120')
    t.text('3.1 texture variant %d baby %d'%(v,b),tx,'WS-X120')
for v,blk in ((0,'red_mushroom_block'),(1,'brown_mushroom_block')):
    t.raw('MOVE %d TO WS-IV(1)'%v,'CALL "EF4-MOOSHROOM-BLOCK" USING WS-IN WS-X120')
    t.text('3.1 variant %d block state'%v,blk,'WS-X120')
for baby in (0,1):
  for hasm in (0,1):
    for inv in (0,1):
      for glow in (0,1):
        outl=1 if (inv and glow) else 0
        draw=1 if (not baby and hasm and not (inv and not outl)) else 0
        t.call('EF4-MUSHROOM-DRAW',[baby,hasm,inv,glow],[draw,outl if draw else 0],'3.2 baby %d model %d invisible %d glowing %d draw and outline-only'%(baby,hasm,inv,glow))
COPIES={1:[(1,.2,-.35,.5),(2,-48,0,0),(3,-1,-1,1),(1,-.5,-.5,-.5)],
 2:[(1,.2,-.35,.5),(2,42,0,0),(1,.1,0,-.6),(2,-48,0,0),(3,-1,-1,1),(1,-.5,-.5,-.5)],
 3:[(4,0,0,0),(1,0,-.7,-.2),(2,-78,0,0),(3,-1,-1,1),(1,-.5,-.5,-.5)]}
for c,ops in COPIES.items():
    t.call('EF4-MUSHROOM-OPS',[c],[len(ops)]+[x for o in ops for x in o],'3.2 copy %d pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each)'%c)
t.call('EF4-MUSHROOM-OPS',[9],[0],'3.2 a copy number outside 1..3 has no operations (coverage-only addition)')
# setupAnim as cow on the mooshroom layers
for lay in ('MOOSHROOM','MOOSHROOM_BABY'):
    t.raw('MOVE "%s" TO WS-LAYER'%lay,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([8,-14,3.1,0.4]); t.raw('CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN')
    a=math.cos(0.6662*3.1)*1.4*.4; b=math.cos(0.6662*3.1+math.pi)*1.4*.4
    t.cur('head','xrot',8*D); t.cur('head','yrot',-14*D); t.cur('right_hind_leg','xrot',a); t.cur('left_front_leg','xrot',a); t.cur('left_hind_leg','xrot',b); t.cur('right_front_leg','xrot',b)
save(t,4,3)
