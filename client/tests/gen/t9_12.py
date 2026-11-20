from mesh8 import *
import g4
setlayer('LEASH_KNOT',['P knot root 0 0 0 0 0 0','C knot 0 0 -3 -8 -3 6 8 6 0 0'],32,32)
t=mk(9,12,["Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 12 (lead knot): the one part model (texture 32 x 32, cuboid (-3, -8, -3) size 6 x 8 x 6), the submit (scale (-1, -1, 1), no shadow) and the texture path."],ck=True)
t.LP='EF9-LAYER'
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
mesh_checks(t,['LEASH_KNOT'],'12')
t.call('EF9-KNOT-OPS',[],[1,2,-1,-1,1],'12 submit ops (count, scale code, -1, -1, 1)')
t.raw('MOVE SPACES TO WS-X60','CALL "EF9-KNOT-TEXTURE" USING WS-IN WS-X60'); t.text('12 texture','entity/lead_knot/lead_knot.png','WS-X60')
t.raw('MOVE "NO_SUCH_LAYER" TO WS-LAYER','CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.num('12 a layer that is not of this part is not known',0,'WS-OK')
g4.save(t,9,12)
