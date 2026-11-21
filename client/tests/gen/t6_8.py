from warden6 import *
from ref4 import apply,keytests,KWS
define()
t=mk(6,8,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 8 (Warden): 8.1 the mesh, 8.2 setupAnim (head look, walk, idle, tendrils, the six keyframe animations; examples 15.9 and 15.11), 8.3 the render state lerps,",
 "heartbeat delay, entity events and pose changes, 8.4 texture, 8.5 the five emissive layer meshes (retainExactParts) with their alpha rule (example 15.10) and 8.6 every channel of the six WardenAnimation definitions sampled by an independent engine."],ck=True)
t.LP='EF6-LAYER'; t.extra_ws+='\n'+KWS
mesh_checks(t,IDS,'8')
keytests(t,'EF6W',None,NM,AN,'8.6')
STOP=-2147483648
def warden(st):
    xr,yr,wp,ws,age,tend,at,sb,dg,em,ro,sn=st
    P=base_parts('WARDEN')
    h,b,la,ra,ll,rl,lt,rt=P['head'],P['body'],P['left_arm'],P['right_arm'],P['left_leg'],P['right_leg'],P['left_tendril'],P['right_tendril']
    h[3]=xr*0.017453292; h[4]=yr*0.017453292
    p=wp*0.8662; m=min(0.5,3*ws); m2=min(0.35,m)
    h[5]+=0.3*math.sin(p)*m; h[3]+=1.2*math.cos(p+1.5707964)*m2
    b[5]=0.1*math.sin(p)*m; b[3]=1.0*math.cos(p)*m2
    ll[3]=math.cos(p)*m; rl[3]=math.cos(p+3.1415927)*m
    la[3]=-(0.8*math.cos(p)*m); la[5]=0; ra[3]=-(0.8*math.sin(p)*m); ra[5]=0
    la[4]=0; ra[4]=0; la[2]=1; ra[2]=1; la[0]=13; la[1]=-13; ra[0]=-13; ra[1]=-13
    a=age*0.1
    h[5]+=0.06*math.cos(a); h[3]+=0.06*math.sin(a); b[5]+=0.025*math.sin(a); b[3]+=0.025*math.cos(a)
    v=tend*(math.cos(age*2.25)*math.pi*0.10000000149011612); lt[3]=v; rt[3]=-v
    for nm,s0 in (('WARDEN_ATTACK',at),('WARDEN_SONIC_BOOM',sb),('WARDEN_DIG',dg),('WARDEN_EMERGE',em),('WARDEN_ROAR',ro),('WARDEN_SNIFF',sn)):
        if s0!=STOP: apply(AN[NM.index(nm)],int((age-s0)*50),1,P)
    return P
#  xRot yRot wp ws age tendril attack sonic dig emerge roar sniff
STS=[(10,-20,1.0,0.2,0,0,STOP,STOP,STOP,STOP,STOP,STOP),(-15,30,2.5,0.05,12.5,0.7,STOP,STOP,STOP,STOP,STOP,STOP),(0,0,0,0,0,0,0,0,0,0,0,0),
     (5,5,3.5,0.4,20.25,1,4,STOP,STOP,STOP,STOP,STOP),(5,5,3.5,0.4,40,0.3,STOP,25,STOP,STOP,STOP,STOP),(0,10,1.5,0.1,60.5,0,STOP,STOP,45,STOP,STOP,STOP),
     (-5,25,0.5,0.9,30.25,0.5,STOP,STOP,STOP,2,STOP,STOP),(20,-10,2,0.3,55,0.2,STOP,STOP,STOP,STOP,30,STOP),(0,0,1,0.2,26,0,STOP,STOP,STOP,STOP,STOP,10),(12,12,1.25,0.6,70,0.9,60,50,40,30,20,10)]
for st in STS:
    pose_check(t,'WARDEN','EF6-WARDEN-ANIM',st,warden(st))
# example 15.9 (walk part; the idle step is 0 for sin(0) in the z rotation of the body, and age 0 leaves the limb values unchanged)
t.raw('MOVE "WARDEN" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1.0,0.2,0,0,STOP,STOP,STOP,STOP,STOP,STOP]); t.raw('CALL "EF6-WARDEN-ANIM" USING EMM-MODEL WS-IN')
t.cur('left_leg','xrot',0.32386); t.cur('right_leg','xrot',-0.32386); t.cur('body','zrot',0.03809); t.cur('left_arm','xrot',-0.25909); t.cur('right_arm','xrot',-0.30475); t.cur('head','zrot',0.11428+0.06); t.cur('head','xrot',-0.31999)
# example 15.11: the emerge body rotation channel (channel 1) at t = 0.26 s
t.call('EF6W-ANIM-EVAL',[1,1,0.26,1],[0,0,-0.212712],'8.6 example 15.11 emerge body rotation at 0.26 s')
t.call('EF6-WARDEN-RENDER-STATE',[0.5,4,6,2,8],[(4+0.5*2)/10,(2+0.5*6)/10],'8.3 render state tendril and heart animation lerp / 10 (partial 0.5, tendril 4 to 6, heart 2 to 8) [heart is old 2 current 8]')
for anger,e in ((-10,40),(0,40),(40,25),(80,10),(160,10),(20,32),(79,11)):
    t.call('EF6-WARDEN-HEARTBEAT',[anger],[40-math.floor(min(1,max(0,anger/80))*30)],'8.3 heartbeat delay anger %d'%anger)
def wtick(tc,delay,tend,heart):
    beat=1 if tc%delay==0 else 0
    if beat: heart=10
    to=tend; tend=tend-1 if tend>0 else tend
    ho=heart; heart=heart-1 if heart>0 else heart
    return [to,tend,ho,heart,beat]
for tc,delay,tend,heart in ((80,40,0,0),(81,40,3,2),(40,25,10,0),(41,25,0,5),(100,30,1,1),(7,40,0,0)):
    t.call('EF6-WARDEN-TICK',[tc,delay,tend,heart],wtick(tc,delay,tend,heart),'8.3 client tick %d delay %d tendril %d heart %d (old tendril, tendril, old heart, heart, beat)'%(tc,delay,tend,heart))
for ev,tc,td,ro,at,sb in ((4,100,3,50,STOP,STOP),(61,100,3,50,7,8),(62,100,3,50,7,8),(5,100,3,50,7,8)):
    o=[td,ro,at,sb]
    if ev==4: o=[td,STOP,tc,sb]
    elif ev==61: o=[10,ro,at,sb]
    elif ev==62: o=[td,ro,at,tc]
    t.call('EF6-WARDEN-EVENT',[ev,tc,td,ro,at,sb],o,'8.3 entity event %d tick %d (tendril, roar start, attack start, sonic start)'%(ev,tc))
for pose in (1,2,3,4,0):
    o=[10,20,30,40]
    if pose: o[pose-1]=77
    t.call('EF6-WARDEN-POSE',[pose,77,10,20,30,40],o,'8.3 pose change %d at tick 77 (emerge, dig, roar, sniff starts)'%pose)
text_check(t,'EF6-WARDEN-TEXTURE',[0],'8.4 texture','textures/entity/warden/warden.png')
for k,e in ((1,'warden_bioluminescent_layer.png'),(2,'warden_pulsating_spots_1.png'),(3,'warden_pulsating_spots_2.png'),(4,'warden.png'),(5,'warden_heart.png')):
    text_check(t,'EF6-WARDEN-TEXTURE',[k],'8.5 layer %d texture'%k,'textures/entity/warden/'+e)
def alpha(k,age,tend,heart,inv):
    if inv: return [0,0]
    a={1:1.0,2:max(0,math.cos(age*0.045)*0.25),3:max(0,math.cos(age*0.045+3.1415927)*0.25),4:tend,5:heart}[k]
    return [1 if a>0.00001 else 0,a if a>0.00001 else 0]
for k in range(1,6):
    for age,tend,heart,inv in ((0,0.5,0.7,0),(20,0.5,0.7,0),(70,0,0,0),(10,0.4,0.3,1),(95.5,0.00001,0.000005,0)):
        t.call('EF6-WARDEN-LAYER-ALPHA',[k,age,tend,heart,inv],alpha(k,age,tend,heart,inv),'8.5 layer %d age %s tendril %s heart %s invisible %d (draw, alpha)'%(k,age,tend,heart,inv))
t.call('EF6-WARDEN-LAYER-ALPHA',[2,0,0,0,0],[1,0.25],'8.5 example 15.10 spots 1 alpha at age 0')
t.call('EF6-WARDEN-LAYER-ALPHA',[3,0,0,0,0],[0,0],'8.5 example 15.10 spots 2 alpha at age 0 is skipped')
t.call('EF6-WARDEN-LAYER-ALPHA',[2,20,0,0,0],[1,0.1554],'8.5 example 15.10 spots 1 alpha at age 20')
save(t,6,8)
