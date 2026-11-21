from mesh5 import *
from ref4 import sample,apply,keytests,KWS
import app5
t=mk(5,8,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 8 (Bat): the mesh table (9 parts), setupAnim (resting head yaw, then BAT_FLYING and BAT_RESTING applied from the animation states),",
 "the BAT_RESTING and BAT_FLYING keyframe tables of section 15.2 (every channel sampled by an independent engine), the texture, the shadow radius and the entity-side state and movement rules. Mesh rows are the table of the document."],ck=True)
t.extra_ws+='\n'+KWS
mesh_checks(t,['BAT'],'8')
AN=app5.parse('15.2')
keytests(t,'EF5B',None,['BAT_RESTING','BAT_FLYING'],AN,'15.2')
STOP=-2147483648
def bat(st):
    yr,rest,age,fs,rs=st
    P={}
    for r in expected('BAT')[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    if rest: P['head'][4]=yr*0.017453292
    for a,s0 in ((AN[1],fs),(AN[0],rs)):
        if s0!=STOP: apply(a,int((age-s0)*50),1,P)
    return P
#   yRot resting age flyStart restStart
STS=[(30,0,10.5,4,STOP),(30,1,10.5,STOP,4),(-45,1,3.25,STOP,3),(15,0,0,0,STOP),(0,0,7.77,STOP,STOP),(20,1,25.25,1,10),(-20,0,31.5,12,2),(90,1,0.4,STOP,0)]
for st in STS:
    t.raw('MOVE "BAT" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF5-BAT-ANIM" USING EMM-MODEL WS-IN')
    P=bat(st)
    for part in sorted(P):
        for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
# worked example E9
t.raw('MOVE "BAT" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,1,5,STOP,5]); t.raw('CALL "EF5-BAT-ANIM" USING EMM-MODEL WS-IN')
t.cur('head','xrot',3.14159265); t.cur('head','y',16.5); t.cur('feet','xrot',0)
t.raw('MOVE SPACES TO WS-X120','CALL "EF5-BAT-TEXTURE" USING WS-X120'); t.text('8 texture','textures/entity/bat/bat.png','WS-X120')
t.call('EF5-BAT-SHADOW',[],[0.25],'8 shadow radius')
import math
def tick(rest,fs,rs,tc):
    if rest: return [STOP,tc if rs==STOP else rs]
    return [tc if fs==STOP else fs,STOP]
for rest,fs,rs,tc in ((1,5,STOP,40),(1,STOP,STOP,41),(1,STOP,12,42),(0,STOP,12,43),(0,7,STOP,44),(0,STOP,STOP,45)):
    t.call('EF5-BAT-TICK',[rest,fs,rs,tc],tick(rest,fs,rs,tc),'8 entity tick resting %d fly start %s rest start %s tick %d (new fly start, new rest start)'%(rest,fs,rs,tc))
for rest,y,h,dy in ((1,64.3,0.9,-0.2),(1,-3.5,0.9,0.4),(0,64.3,0.9,-0.5),(0,10,0.9,1.0)):
    outs=[math.floor(y)+1-h,0] if rest else [y,dy*0.6]
    t.call('EF5-BAT-MOVE',[rest,y,h,dy],outs,'8 movement resting %d y %s height %s delta y %s (y, delta y)'%(rest,y,h,dy))
save(t,5,8)
