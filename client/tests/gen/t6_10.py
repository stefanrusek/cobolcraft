from mesh6 import *
setlayer('PHANTOM',doc6.rows_from(6,'### 10.1'),64,64)
t=mk(6,10,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 10 (Phantom): 10.1 the mesh (the mirrored right wing), 10.2 setupAnim (wing flap and tail from the flap time; example 15.5), 10.3 the flap time,",
 "the size scale and translate, the pitch rotation and the eyes layer texture."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['PHANTOM'],'10.1')
def phantom(ft):
    P=base_parts('PHANTOM'); tt=ft*7.448451*0.017453292
    z=math.cos(tt)*16*0.017453292
    P['left_wing_base'][5]=z; P['left_wing_tip'][5]=z; P['right_wing_base'][5]=-z; P['right_wing_tip'][5]=-z
    x=-(5+math.cos(2*tt)*5)*0.017453292
    P['tail_base'][3]=x; P['tail_tip'][3]=x
    return P
for ft in (0,3,10.5,47.25,120):
    pose_check(t,'PHANTOM','EF6-PHANTOM-ANIM',[ft],phantom(ft))
t.raw('MOVE "PHANTOM" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([3]); t.raw('CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN')
t.cur('left_wing_base','zrot',0.25828); t.cur('tail_base','xrot',-0.14931)
for nid,age in ((0,0),(7,12.5),(100,3.25)): t.call('EF6-PHANTOM-FLAP',[nid,age],[nid*3+age],'10.3 flap time network id %d age %s'%(nid,age))
for size in (0,1,3,10): 
    s=1+0.15*size
    t.call('EF6-PHANTOM-SCALE-OPS',[size],[2,2,s,s,s,1,0,1.3125,0.1875],'10.3 scale and translate for size %d (count; code 2 scale, 1 translate; values)'%size)
for xr in (0,30,-45.5): t.call('EF6-PHANTOM-ROT-OPS',[xr],[1,6,xr,0,0],'10.3 pitch rotation x rot %s (count; code 6 rotate X degrees)'%xr)
text_check(t,'EF6-PHANTOM-TEXTURE',[0],'10.3 texture','textures/entity/phantom/phantom.png')
text_check(t,'EF6-PHANTOM-TEXTURE',[1],'10.3 eyes texture','textures/entity/phantom/phantom_eyes.png')
save(t,6,10)
