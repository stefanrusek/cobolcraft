from mesh7 import *
t=mk(7,9,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 9 (Dragon fireball): no model, the four vertices of the camera facing quad (positions and uvs in the order of the document), the scale of 2,",
 "the outline pass when the outline colour is non-zero, the texture, block light level 15 and the shadow radius 0 (inferred in the document, example 11.10)."],ck=False)
Q=[(0,0,0,1),(1,0,1,1),(1,1,1,0),(0,1,0,0)]
t.call('EF7-FIREBALL-QUAD',[],[v for px,py,u,vv in Q for v in (px-0.5,py-0.25,0,u,vv)],'9 quad vertices (x, y, z, u, v) in order 1 to 4')
t.call('EF7-FIREBALL-POSE',[],[1,2,2,2,2],'9 pose scale ops (count; code 2 scale; 2 2 2); the camera orientation rotation is applied by the caller after it')
for oc,e in ((0,[1,0,0]),(16711680,[1,1,16711680]),(-1,[1,1,-1])): t.call('EF7-FIREBALL-PASSES',[oc],e,'9 passes outline colour %s (main pass, outline pass, vertex colour of the outline pass)'%oc)
text_check(t,'EF7-FIREBALL-TEXTURE',[0],'9 texture','textures/entity/enderdragon/dragon_fireball.png')
t.call('EF7-FIREBALL-RENDER',[],[0,15],'9 shadow radius and block light level')
save(t,7,9)
