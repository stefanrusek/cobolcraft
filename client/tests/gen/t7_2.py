from blaze7 import *
setlayer('BLAZE',blaze_rows(),64,32)
t=mk(7,2,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 2 (Blaze): 2.1 the mesh (the head and the twelve rods with their creation pivots on three rings), 2.2 setupAnim (the ring angles from the age, the rod heights and the head look; worked example 11.1),",
 "and the renderer facts (shadow radius, block light level 15, texture)."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['BLAZE'],'2.1')
def blaze(st):
    xr,yr,age=st
    P=base_parts('BLAZE'); P['head'][3]=xr*0.017453292; P['head'][4]=yr*0.017453292
    PI=math.pi
    for i in range(12):
        ring,k=(0,i) if i<4 else (1,i-4) if i<8 else (2,i-8)
        base=(age*PI*-0.1,0.7853982+age*PI*0.03,0.47123894+age*PI*-0.05)[ring]; R=(9,7,5)[ring]; a=base+k*Q
        y=(-2+math.cos((2*i+age)*0.25)) if ring==0 else (2+math.cos((2*i+age)*0.25)) if ring==1 else (11+math.cos((1.5*i+age)*0.5))
        P['part%d'%i][0]=math.cos(a)*R; P['part%d'%i][1]=y; P['part%d'%i][2]=math.sin(a)*R
    return P
for st in ((10,-20,0),(0,0,10),(-15,40,33.25),(25,-90,7.5),(5,5,100)):
    pose_check(t,'BLAZE','EF7-BLAZE-ANIM',st,blaze(st))
t.call('EF7-BLAZE-RENDER',[],[0.5,15],'2 shadow radius and block light level')
text_check(t,'EF7-BLAZE-TEXTURE',[0],'2 texture','textures/entity/blaze/blaze.png')
save(t,7,2)
