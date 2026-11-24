from mesh8 import *
import g4,math
setlayer('CUSHION',['P cushion root 23 4 -7 0 0 0','C cushion 0 0 -31 -4 -1 16 4 16 -0.005 0'],64,64)
t=mk(9,16,["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 16 (cushion): the model (texture 64 x 64, offset (23, 4, -7), cuboid (-31, -4, -1) size 16 x 4 x 16 with deformation -0.005), the texture of each of the 16 dye colours and the submit",
 "(rotate Y by 180 - the direction's yaw, rotate X by 180, translate (0, -0.25, 0); Direction.fromYRot of 24-4 section 2 for the yaw)."],ck=True)
t.LP='EF9-LAYER'
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
mesh_checks(t,['CUSHION'],'16')
DYES=['white','orange','magenta','light_blue','yellow','lime','pink','gray','light_gray','cyan','purple','blue','brown','green','red','black']
for i,n in enumerate(DYES):
    t.raw('MOVE %d TO WS-IV(1)'%i,'MOVE SPACES TO WS-X60','CALL "EF9-CUSHION-TEXTURE" USING WS-IN WS-X60'); t.text('16 texture of dye %d (%s)'%(i,n),'entity/cushion/%s_cushion.png'%n,'WS-X60')
for y,d in ((0,0),(44,0),(45,1),(90,1),(134,1),(135,2),(180,2),(224,2),(225,3),(270,3),(-90,3),(-45,0),(-46,3),(360,0),(-180,2)):
    assert d==math.floor(y/90+0.5)%4
    t.call('EF9-CUSHION-OPS',[y],[3,3,180-d*90,0,0,6,180,0,0,1,0,-0.25,0],'16 submit ops for the entity yRot %s (direction data %d)'%(y,d))
t.raw('MOVE "NO_SUCH_LAYER" TO WS-LAYER','CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.num('16 a layer that is not of this part is not known',0,'WS-OK')
g4.save(t,9,16)
