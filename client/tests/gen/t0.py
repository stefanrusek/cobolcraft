from g4 import *
t=mk(4,0,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 0 (how this document relates to part 1 and part 3): 0.1 the scaling arithmetic (root offset and scale",
 "of one and of several MeshTransformer.scaling steps, the pivot of a part, the fixed line y = 24.016) and the baby-model choice of the renderers (AgeableMobRenderer or the three that are not).",
 "Values are worked by an independent script from the formulas of the document."])
def step(off,sc,s): return off*s+24.016*(1-s), sc*s
def chain(ss):
    o,sc=0.0,1.0
    for s in ss: o,sc=step(o,sc,s)
    return o,sc
for label,ss,eo,es in (('1.1 (horse)',[1.1],-2.4016,1.1),('0.87 (donkey)',[0.87],3.1221,0.87),('4 (happy ghast)',[4],-72.048,4),('4 then 0.2375 (baby ghast)',[4,0.2375],1.2008,0.95),('4, 0.2375, 0.2375 (baby harness)',[4,0.2375,0.2375],18.5974,0.225625),('0.92 (mule)',[0.92],None,0.92)):
    o,sc=chain(ss)
    if eo is not None: assert abs(o-eo)<2e-4,(label,o)
    t.raw('MOVE 0 TO WS-IV(1)','MOVE 1 TO WS-IV(2)')
    for i,s in enumerate(ss):
        t.raw('MOVE %s TO WS-IV(3)'%lit(s),'CALL "EF4-SCALE-STEP" USING WS-IN WS-OUT','MOVE WS-OV(1) TO WS-IV(1)','MOVE WS-OV(2) TO WS-IV(2)')
    t.num('0.1 root offset after scaling %s'%label,o,'WS-IV(1)')
    t.num('0.1 root scale after scaling %s'%label,sc,'WS-IV(2)')
for py,s in ((11,1.1),(4,1.1),(24.016,1.1),(24.016,0.87),(0,4),(16,4)):
    t.call('EF4-SCALE-PIVOT',[py,s],[py*s+24.016*(1-s)],'0.1 pivot y=%s scaled by %s'%(py,s))
t.call('EF4-SCALE-PIVOT',[24.016,0.37],[24.016],'0.1 the line y = 24.016 is a fixed point (any scale)')
for ent,e in (('cow',0),('pig',0),('chicken',0),('mooshroom',1),('sheep',1),('goat',1),('horse',1),('donkey',1),('mule',1),('skeleton_horse',1),('zombie_horse',1),('llama',1),('trader_llama',1),('camel',1),('camel_husk',1),('happy_ghast',1),('rabbit',1)):
    t.raw('MOVE "%s" TO WS-X24'%ent,'CALL "EF4-AGEABLE" USING WS-X24 WS-FL')
    t.num('0.2 %s extends AgeableMobRenderer'%ent,e,'WS-FL')
open(REPO+'client/tests/test_entmodel_34_4_0.cob','w').write(t.render())
