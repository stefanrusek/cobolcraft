from mesh5 import *
from ref4 import sample,apply,keytests,KWS
import app5
t=mk(5,14,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 14 (Sniffer and snifflet): 14.1 the adult and baby meshes (the baby plays the plain SnifferModel, no baby transform), 14.2 setupAnim (head look,",
 "walk or search keyframes with factors 9 and 100, then dig, long sniff, stand up, happy and sniff sniff), the SNIFFER keyframe table of section 15.6 (every channel of all nine definitions sampled by an independent engine), 14.3 textures, shadow and the culling box inflation."],ck=True)
t.extra_ws+='\n'+KWS
mesh_checks(t,['SNIFFER','SNIFFER_BABY'],'14.1')
AN=app5.parse('15.6'); NM=[a['name'] for a in AN]
keytests(t,'EF5S',None,NM,AN,'15.6')
STOP=-2147483648
def sn(layer,st):
    xr,yr,p,s,age,srch,dg,ls,su,hp,ss=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    P['head'][3]=xr*D; P['head'][4]=yr*D
    apply(AN[NM.index('SNIFFER_SNIFF_SEARCH' if srch else 'SNIFFER_WALK')],int(p*50*9),min(s*100,1),P)
    for nm,s0 in (('SNIFFER_DIG',dg),('SNIFFER_LONGSNIFF',ls),('SNIFFER_STAND_UP',su),('SNIFFER_HAPPY',hp),('SNIFFER_SNIFFSNIFF',ss)):
        if s0!=STOP: apply(AN[NM.index(nm)],int((age-s0)*50),1,P)
    return P
#  xRot yRot p s age searching dig longsniff standup happy sniffsniff
STS=[(10,-20,1.25,0.5,30.5,0,STOP,STOP,STOP,STOP,STOP),(-15,30,0.5,0.005,12,1,STOP,STOP,STOP,STOP,STOP),(0,0,0,0,0,0,0,0,0,0,0),(5,5,2.75,0.3,70.25,0,40,STOP,STOP,STOP,STOP),
     (-5,25,3.5,0.02,22.5,1,STOP,20,STOP,STOP,2),(20,-10,1.5,0.9,90,0,STOP,STOP,80,85,STOP),(0,0,4,0.0099,15.75,0,3,5,7,9,11)]
for layer in ('SNIFFER','SNIFFER_BABY'):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF5-SNIFFER-ANIM" USING EMM-MODEL WS-IN')
        P=sn(layer,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
for b in (0,1):
    t.raw('MOVE SPACES TO WS-X120','MOVE %d TO WS-IV(1)'%b,'CALL "EF5-SNIFFER-TEXTURE" USING WS-IN WS-X120'); t.text('14.3 texture baby %d'%b,'textures/entity/sniffer/%s.png'%('snifflet' if b else 'sniffer'),'WS-X120')
t.call('EF5-SNIFFER-SHADOW',[],[1.1],'14.3 shadow radius')
# culling box: minx miny minz maxx maxy maxz -> inflated by 0.6
t.call('EF5-SNIFFER-CULL',[-1,0,-2,1.5,2.25,2],[-1.6,-0.6,-2.6,2.1,2.85,2.6],'14.3 culling box inflated by 0.6 on every axis (min xyz, max xyz)')
t.call('EF5-SNIFFER-CULL',[10,64,-3.5,11.2,65.8,-2],[9.4,63.4,-4.1,11.8,66.4,-1.4],'14.3 culling box of a second entity')
save(t,5,14)
