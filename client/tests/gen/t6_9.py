from breeze6 import *
from ref4 import apply,keytests,KWS
define()
t=mk(6,9,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 9 (Breeze): 9.1 the base mesh and the three layer models (retainPartsAndChildren, texture sizes 32, 128, 32), 9.2 setupAnim (six keyframe animations in order,",
 "each only when started), 9.3 the entity-side animation state changes, 9.4 textures and the wind scroll offset, and 9.5 every channel of the six BreezeAnimation definitions sampled by an independent engine."],ck=True)
t.LP='EF6-LAYER'; t.extra_ws+='\n'+KWS
mesh_checks(t,LAYERS,'9.1')
keytests(t,'EF6B',None,NM,AN,'9.5')
STOP=-2147483648
ORDER=[('IDLE',2),('SHOOT',3),('SLIDE',4),('SLIDE_BACK',5),('INHALE',6),('JUMP',7)]
def breeze(layer,st):
    P=base_parts(layer); age=st[0]
    for nm,idx in ORDER:
        s0=st[idx-1]
        if s0!=STOP: apply(AN[NM.index(nm)],int((age-s0)*50),1,P)
    return P
#   age idle shoot slide slideBack inhale jump
STS=[(10.5,STOP,STOP,STOP,STOP,STOP,STOP),(10.5,2,STOP,STOP,STOP,STOP,STOP),(33.25,5,20,STOP,STOP,STOP,STOP),(50,STOP,STOP,40,STOP,STOP,STOP),(22.5,0,STOP,STOP,12,STOP,STOP),(41,STOP,STOP,STOP,STOP,30,STOP),
     (60,10,STOP,STOP,STOP,STOP,50),(75.75,3,15,25,35,45,55),(0,0,0,0,0,0,0)]
for layer in ('BREEZE','BREEZE_WIND','BREEZE_EYES'):
    for st in STS[:6] if layer!='BREEZE' else STS:
        pose_check(t,layer,'EF6-BREEZE-ANIM',st,breeze(layer,st))
def pchange(pose,tick,s):
    idle,shoot,slide,sback,inhale,jump=s
    idle=shoot=inhale=jump=STOP
    if pose==1 and shoot==STOP: shoot=tick
    if pose==2 and inhale==STOP: inhale=tick
    if pose==3 and slide==STOP: slide=tick
    return [idle,shoot,slide,sback,inhale,jump]
for pose in (0,1,2,3):
    for s in ((5,6,7,8,9,10),(STOP,STOP,STOP,STOP,STOP,STOP),(STOP,6,STOP,8,STOP,10)):
        t.call('EF6-BREEZE-POSE-CHANGE',[pose,100]+list(s),pchange(pose,100,s),'9.3 pose change %d at tick 100 from %s (idle, shoot, slide, slide back, inhale, long jump)'%(pose,s))
def btick(sliding,ljump,tick,s):
    idle,shoot,slide,sback,inhale,jump=s
    if ljump and jump==STOP: jump=tick
    if idle==STOP: idle=tick
    if (not sliding) and slide!=STOP: sback=tick; slide=STOP
    return [idle,shoot,slide,sback,inhale,jump]
for sliding in (0,1):
    for ljump in (0,1):
        for s in ((STOP,STOP,STOP,STOP,STOP,STOP),(5,6,7,8,9,10),(STOP,STOP,7,STOP,STOP,10)):
            t.call('EF6-BREEZE-TICK',[sliding,ljump,200]+list(s),btick(sliding,ljump,200,s),'9.3 tick sliding %d long jumping %d from %s (idle, shoot, slide, slide back, inhale, long jump)'%(sliding,ljump,s))
for k,e in ((0,'breeze.png'),(1,'breeze_wind.png'),(2,'breeze_eyes.png')): text_check(t,'EF6-BREEZE-TEXTURE',[k],'9.4 texture kind %d'%k,'textures/entity/breeze/'+e)
for age in (0,10,50,51.5,123.25):
    t.call('EF6-BREEZE-WIND-U',[age],[(age*0.02)%1,0],'9.4 wind layer texture offset at age %s (u, v)'%age)
save(t,6,9)
