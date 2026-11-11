from crystal7 import *
define()
t=mk(7,7,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 7 (End crystal): 7.1 the mesh (nested scales 0.875 and 0.765625), 7.2 the bob height getY (worked example 11.6) and setupAnim (base visibility, outer glass height,",
 "the two quaternion rotations converted to part angles), 7.3 the renderer pose, the beam offset vector, the shadow radius and the shouldRender rule."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['END_CRYSTAL'],'7')
for a,e in ((0,-1.1),(5,gety(5)),(12.5,gety(12.5)),(31.4,gety(31.4)),(100,gety(100))): t.call('EF7-CRYSTAL-GETY',[a],[e],'7.2 getY at age %s'%a)
t.call('EF7-CRYSTAL-GETY',[0],[-1.1],'7.2 example 11.6 getY at age 0 is -1.1')
for y,x,e in ((1,0,math.atan2(1,0)),(-1,0,math.atan2(-1,0)),(0,-1,math.atan2(0,-1)),(2,3,math.atan2(2,3)),(-2,-3,math.atan2(-2,-3)),(0,0,0),(1,-3,math.atan2(1,-3)),(-1,2,math.atan2(-1,2))):
    t.call('EF7-ATAN2',[y,x],[e],'7.2 atan2 y %s x %s'%(y,x))
def crystal(age,sb):
    P=base_parts('END_CRYSTAL')
    P['outer_glass'][1]+=gety(age)*16/2
    R=age*3*0.017453292
    A=axis(S45,0,S45,ANG)
    q1=mm(roty(R),A); q2=mm(A,roty(R))
    P['outer_glass'][3:6]=list(euler(q1)); P['inner_glass'][3:6]=list(euler(q2)); P['cube'][3:6]=list(euler(q2))
    return P,sb
for age,sb in ((0,1),(5,0),(12.5,1),(33.25,1),(100,0)):
    P,v=crystal(age,sb); pose_check(t,'END_CRYSTAL','EF7-CRYSTAL-ANIM',[age,sb],P,{'base':v})
for bx,by,bz,age in ((3,4,-5,10),(0,0,0,0),(-2.5,6,8,33.5)):
    y=gety(age); t.call('EF7-CRYSTAL-BEAM',[bx,by,bz,age],[bx,by,bz,-bx,-by+y,-bz],'7.3 beam translate and vector for offset (%s, %s, %s) age %s (translate xyz, vector xyz)'%(bx,by,bz,age))
t.call('EF7-CRYSTAL-RENDER',[],[0.5,2,2,2,1,0,-0.5,0],'7.3 shadow radius and pose ops (shadow; scale 2 2 2; translate 0 -0.5 0 as codes... see header)') if False else None
t.call('EF7-CRYSTAL-RENDER',[],[0.5,2,2,2,0,-0.5,0],'7.3 shadow radius, scale (2, 2, 2) and translate (0, -0.5, 0) (shadow; x y z; x y z)')
for b,beam in ((0,0),(1,0),(0,1),(1,1)): t.call('EF7-CRYSTAL-SHOULD',[b,beam],[1 if (b or beam) else 0],'7.3 shouldRender base %d beam target %d'%(b,beam))
text_check(t,'EF7-CRYSTAL-TEXTURE',[0],'7.3 texture','textures/entity/end_crystal/end_crystal.png')
text_check(t,'EF7-CRYSTAL-TEXTURE',[1],'7.3 beam texture','textures/entity/end_crystal/end_crystal_beam.png')
save(t,7,7)
