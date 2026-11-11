from mesh6 import *
setlayer('SHULKER_BULLET',['P main root 0 0 0 0 0 0','C main 0 0 -4 -4 -1 8 8 2 0 0','C main 0 10 -1 -4 -4 2 8 8 0 0','C main 20 0 -4 -1 -4 8 2 8 0 0'],64,32)
t=mk(6,13,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 13 (Shulker bullet): the mesh (one part, three boxes), setupAnim (yaw and pitch), the renderer submit stack (translate, three spins, scale -0.5/-0.5/0.5), the second",
 "translucent pass scaled 1.5 with tint 654311423, the spark texture and the full block light."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['SHULKER_BULLET'],'13')
for yr,xr in ((0,0),(30,-15),(-90,45.5),(180,10)):
    P=base_parts('SHULKER_BULLET'); P['main'][4]=yr*0.017453292; P['main'][3]=xr*0.017453292
    pose_check(t,'SHULKER_BULLET','EF6-BULLET-ANIM',[yr,xr],P)
for a in (0,10.5,33.25,100):
    ops=[(1,0,0.15,0),(3,math.sin(a*0.1)*180,0,0),(6,math.cos(a*0.1)*180,0,0),(4,math.sin(a*0.15)*360,0,0),(2,-0.5,-0.5,0.5)]
    t.call('EF6-BULLET-OPS',[a],[5]+[x for o in ops for x in o],'13 submit stack at age %s (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values)'%a)
t.call('EF6-BULLET-PASS',[1],[1,1,-1,0],'13 first pass (extra scale, translucent 0 or 1... see program header: scale, tint, order)') if False else None
t.call('EF6-BULLET-PASS',[1],[1,0,-1,0],'13 pass 1 (scale factor, translucent, tint -1 none, order)')
t.call('EF6-BULLET-PASS',[2],[1.5,1,654311423,1],'13 pass 2 halo (scale factor, translucent, tint, order)')
text_check(t,'EF6-BULLET-TEXTURE',[0],'13 texture','textures/entity/shulker/spark.png')
t.call('EF6-BULLET-BLOCKLIGHT',[],[15],'13 block light level')
save(t,6,13)
