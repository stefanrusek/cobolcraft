from mesh4 import *
from ref4 import *
import tgen
t=mk(4,10,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 10 (Camel and camel husk): 10.1 textures, the husk's single adult model, the baby-null saddle rule, jumpCooldown, 10.2 setupAnim (head clamps and the jump",
 "pitch, the walk animation, the five animation states in order, the reins), 10.3 the geometry of camel, camel_baby, camel_saddle (and the husk saddle id), Appendix A.1 and A.2 (every animation: length, looping, channels, bone,",
 "target, key count and every channel sampled by an independent engine). Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
t.extra_ws+='\n'+KWS
IDS=['CAMEL','CAMEL_BABY','CAMEL_SADDLE','CAMEL_HUSK_SADDLE']
mesh_checks(t,IDS,'10.3')
for k,b,p in ((0,0,'textures/entity/camel/camel.png'),(0,1,'textures/entity/camel/camel_baby.png'),(1,0,'textures/entity/camel/camel_husk.png'),(1,1,'textures/entity/camel/camel_husk.png')):
    t.raw('MOVE %d TO WS-IV(1)'%k,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-CAMEL-TEXTURE" USING WS-IN WS-X120'); t.text('10.1 kind %d baby %d texture'%(k,b),p,'WS-X120')
for k,b,lay in ((0,0,'CAMEL'),(0,1,'CAMEL_BABY'),(1,0,'CAMEL'),(1,1,'CAMEL')):
    t.raw('MOVE %d TO WS-IV(1)'%k,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-CAMEL-MODEL" USING WS-IN WS-X32'); t.text('10.1 kind %d baby %d model layer (the husk has no baby model)'%(k,b),lay,'WS-X32')
for raw,pt in ((22,0.25),(0,0.5),(3,3.5),(10,2)):
    t.call('EF4-CAMEL-JUMP',[raw,pt],[max(raw-pt,0)],'10.1 jumpCooldown raw %s partial %s'%(raw,pt))
t.call('EF4-CAMEL-HEAD',[40,10,22],[30*D,28*D],'10.2 worked example 6: yaw clamped to 30, pitch 10 + 45 x 22 / 55')
for yr,xr,jc in ((-80,-60,0),(80,100,0),(5,-30,10),(0,45,55),(-10,60,55),(20,0,3.3),(-31,44,0)):
    yaw=max(-30,min(30,yr)); pitch=max(-25,min(45,xr))
    if jc>0: pitch=max(-25,min(70,pitch+45*jc/55))
    t.call('EF4-CAMEL-HEAD',[yr,xr,jc],[yaw*D,pitch*D],'10.2 head yRot %s xRot %s jump %s'%(yr,xr,jc))
AD=parse('A.1'); BB=parse('A.2')
NAMES=[a['name'] for a in AD]+[a['name'] for a in BB]; ALL=AD+BB
keytests(t,'EF4C',None,NAMES,ALL,'A')
MIN=-2147483648
ORD={n:i for i,n in enumerate(NAMES,1)}
def camel(layer,baby,st):
    xr,yr,wp,ws,age,jc,rid,saddle,sit,sitp,up,idle,dash=st
    parts={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': parts[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    parts['root']=[0,0,0,0,0,0,1,1,1]
    # root pose of the model: unscaled layer root has no offset
    yaw=max(-30,min(30,yr)); pitch=max(-25,min(45,xr))
    if jc>0: pitch=max(-25,min(70,pitch+45*jc/55))
    parts['head'][4]=yaw*DEG; parts['head'][3]=pitch*DEG
    ms=int(wp*50*2); k=min(ws*2.5,1)
    pre='CAMEL_BABY_' if baby else 'CAMEL_'
    ANI={a['name']:a for a in ALL}
    apply(ANI[pre+'WALK'],ms,k,parts)
    for start,nm in ((sit,'SIT'),(sitp,'SIT_POSE'),(up,'STANDUP'),(idle,'IDLE'),(dash,'DASH')):
        if start!=MIN: apply(ANI[pre+nm],int(float(int((age-start)*50))),1,parts)
    return parts
STS=[(10,20,0,0,0,0,0,0,MIN,MIN,MIN,MIN,MIN),(40,10,1.5,0.3,0,22,1,0,MIN,MIN,MIN,MIN,MIN),(-5,-20,3.25,1,12,0,0,0,5,MIN,MIN,MIN,MIN),(0,0,2,0.5,30,0,0,0,MIN,10,MIN,MIN,MIN),
 (0,0,0.75,0.2,50.5,0,0,0,MIN,MIN,20,MIN,MIN),(15,-15,5,0.6,70,4,1,1,MIN,MIN,MIN,60,MIN),(0,0,4.5,0.9,25,0,0,0,MIN,MIN,MIN,MIN,15),(1,2,0.375,0.1,88,0,1,1,40,41,42,43,44)]
for layer,baby in (('CAMEL',0),('CAMEL_SADDLE',0),('CAMEL_BABY',1)):
    for st in STS:
        xr,yr,wp,ws,age,jc,rid,saddle,sit,sitp,up,idle,dash=st
        if baby and (sit!=MIN or sitp!=MIN or up!=MIN) : pass
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
        t.setin([xr,yr,wp,ws,age,jc,baby,rid,1 if layer=='CAMEL_SADDLE' else 0,sit,sitp,up,idle,dash])
        t.raw('CALL "EF4-CAMEL-ANIM" USING EMM-MODEL WS-IN')
        P=camel(layer,baby,st)
        pre='10.2 %s state %s '%(layer,'/'.join(lit(float(v)) for v in st[:7]))
        for part in ('root','body','head','left_ear','right_ear','left_front_leg','right_front_leg','left_hind_leg','right_hind_leg','tail'):
            if part not in P: continue
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')):
                if part=='root':
                    t.raw('MOVE 1 TO WS-P')
                    t.num(pre+'root.'+f,P[part][kx],{'x':'MM-CX','y':'MM-CY','z':'MM-CZ','xrot':'MM-CXROT','yrot':'MM-CYROT','zrot':'MM-CZROT','xs':'MM-CXSCALE','ys':'MM-CYSCALE','zs':'MM-CZSCALE'}[f]+'(1)')
                else: t.cur(part,f,P[part][kx])
        if layer=='CAMEL_SADDLE': t.vis('reins',rid)
save(t,4,10)
