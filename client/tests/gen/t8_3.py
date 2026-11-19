from aq8b import *
import math
define_aq()
t=mk(8,3,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 3 (dolphin): 3.1 the adult and baby meshes (every part, pose and box of both tables), 3.2 setupAnim (body pitch and yaw, the tail swing while moving, the isMoving rule),",
 "3.3 the carried item layer translation (xRot < 0 and the else branch) and the worked example E4; the Validation row for the dolphin (8 parts, texture 64 x 64, tail parts keep the baked pose when not moving)."],ck=True)
t.LP='EF8-LAYER'
mesh_checks(t,['DOLPHIN','DOLPHIN_BABY'],'3.1')
D=0.017453292
def dol(layer,xr,yr,moving,age):
    P=base_parts(layer)
    P['body'][3]=xr*D; P['body'][4]=yr*D
    if moving:
        c=math.cos(0.3*age)
        P['body'][3]+=-0.05-0.05*c; P['tail'][3]=-0.1*c; P['tail_fin'][3]=-0.2*c
    return P
for layer in ('DOLPHIN','DOLPHIN_BABY'):
    for xr,yr,mv,age in ((0,0,0,0),(20,-35,0,7),(-30,15,1,10),(45,90,1,3.5),(0,0,1,0)):
        pose_check(t,layer,'EF8-DOLPHIN-ANIM',[xr,yr,mv,age],dol(layer,xr,yr,mv,age))
# worked example E4
c=math.cos(3)
t.num('E4 cos(3)',-0.98999,'FUNCTION COS(3)')
P=dol('DOLPHIN',0,0,1,10)
t.raw('MOVE "DOLPHIN" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1,10]); t.raw('CALL "EF8-DOLPHIN-ANIM" USING EMM-MODEL WS-IN')
t.cur('body','xrot',-0.0005); t.cur('tail','xrot',0.098999); t.cur('tail_fin','xrot',0.197998)
# isMoving: horizontal squared length of the delta movement above 1.0E-7
for dx,dz in ((0,0),(0.0003,0),(0.0004,0),(0,-0.001),(0.0002,0.0002),(0.00031,0.00001)):
    t.call('EF8-DOLPHIN-MOVING',[dx,dz],[1 if dx*dx+dz*dz>1e-7 else 0],'3.2 isMoving for the delta movement (%s, %s)'%(dx,dz))
# carried item layer
for xr in (-60,-30,-10,0,30,60,90):
    p=abs(xr)/60
    o=[0,1-0.5*p,-1+0.5*p] if xr<0 else [0,1+0.8*p,-1+0.2*p]
    t.call('EF8-DOLPHIN-CARRY',[xr],o,'3.3 carried item translate at xRot %s (x, y, z)'%xr)
t.raw('MOVE 0 TO WS-IV(2) WS-IV(3)'); t.call('EF8-DOLPHIN-CARRY',[-30],[0,0.75,-0.75],'E4 carrying at xRot -30'); t.call('EF8-DOLPHIN-CARRY',[30],[0,1.4,-0.9],'E4 carrying at xRot +30')
save(t,8,3)
