from mesh5 import *
from ref4 import sample,apply,keytests,KWS
import app5
t=mk(5,10,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 10 (Armadillo): 10.1 the adult and baby meshes, 10.2 setupAnim (hiding in the shell, head clamp, the walk keyframes, the roll up, roll out and peek states),",
 "the ARMADILLO and ARMADILLO_BABY keyframe tables of sections 15.4 and 15.5 (every channel sampled by an independent engine), 10.3 texture, shadow, the state enum, shouldHideInShell and the animation state machine. Mesh rows are the tables of the document."],ck=True)
t.extra_ws+='\n'+KWS
mesh_checks(t,['ARMADILLO','ARMADILLO_BABY'],'10.1')
A1=app5.parse('15.4'); A2=app5.parse('15.5')
N1=[a['name'] for a in A1]; N2=[a['name'] for a in A2]
keytests(t,'EF5A',None,N1,A1,'15.4')
keytests(t,'EF5D',None,N2,A2,'15.5')
STOP=-2147483648
def clamp(v,a,b): return max(a,min(b,v))
def arm(layer,baby,st):
    xr,yr,p,s,age,hide,ro,ru,pk=st
    AN=A2 if baby else A1; N=N2 if baby else N1
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    vis={'right_hind_leg':1,'left_hind_leg':1,'tail':1,'cube':0}
    skip=0
    if hide:
        skip=1; vis={'right_hind_leg':0,'left_hind_leg':0,'tail':0,'cube':1}
    else:
        P['head'][3]=clamp(xr,-22.5,25)*0.017453292; P['head'][4]=clamp(yr,-32.5,32.5)*0.017453292
        apply(AN[N.index('ARMADILLO_BABY_WALK' if baby else 'ARMADILLO_WALK')],int(p*50*16.5),min(s*2.5,1),P)
    for nm,s0 in (('ROLL_OUT',ro),('ROLL_UP',ru),('PEEK',pk)):
        if s0!=STOP: apply(AN[N.index('ARMADILLO_BABY_'+nm if baby else 'ARMADILLO_'+nm)],int((age-s0)*50),1,P)
    return P,vis,skip
#   xRot yRot p s age hide rollOut rollUp peek
STS=[(10,-20,1.25,0.5,30.5,0,STOP,STOP,STOP),(-40,50,2.75,0.9,12,0,STOP,3,STOP),(40,-50,0.5,1,20.25,0,4,STOP,6),(0,0,0,0,0,0,STOP,STOP,STOP),
     (5,5,3.5,0.3,44.5,1,STOP,STOP,STOP),(5,5,3.5,0.3,44.5,1,40,STOP,STOP),(-20,15,4,0.6,18.75,1,STOP,10,STOP),(20,-31,1.25,0.4,60,1,STOP,STOP,2),(22,10,2.5,0.7,9.5,0,1,5,7)]
for layer,baby in (('ARMADILLO',0),('ARMADILLO_BABY',1)):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby,0]); t.raw('CALL "EF5-ARMADILLO-ANIM" USING EMM-MODEL WS-IN')
        P,vis,skip=arm(layer,baby,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
        for k,v in vis.items(): t.vis(k,v)
        t.num('10.2 body skipDraw',skip,'WS-IV(11)')
for b in (0,1):
    t.raw('MOVE SPACES TO WS-X120','MOVE %d TO WS-IV(1)'%b,'CALL "EF5-ARMADILLO-TEXTURE" USING WS-IN WS-X120'); t.text('10.3 texture baby %d'%b,'textures/entity/armadillo/armadillo%s.png'%('_baby' if b else ''),'WS-X120')
t.call('EF5-ARMADILLO-SHADOW',[],[0.4],'10.3 shadow radius')
INFO={0:(0,0),1:(1,10),2:(1,50),3:(1,30)}
for sid,(th,du) in INFO.items(): t.call('EF5-ARMADILLO-INFO',[sid],[th,du],'10.3 state %d threatened and duration ticks'%sid)
t.call('EF5-ARMADILLO-INFO',[7],[0,0],'10.3 unknown state is not threatened, duration 0')
def hide(s,n): return {0:0,1:1 if n>5 else 0,2:1,3:1 if n<26 else 0}[s]
for s,n in ((0,0),(0,100),(1,5),(1,6),(1,0),(2,0),(2,99),(3,0),(3,25),(3,26),(3,40)):
    t.call('EF5-ARMADILLO-HIDE',[s,n],[hide(s,n)],'10.3 shouldHideInShell state %d inStateTicks %d'%(s,n))
def machine(s,n,tick,ro,ru,pk,recv):
    if s==0: return [STOP,STOP,STOP,recv]
    if s==1: return [STOP,tick if ru==STOP else ru,STOP,recv]
    if s==3: return [tick if ro==STOP else ro,STOP,STOP,recv]
    pk2=pk
    if recv: pk2=STOP; recv=0
    if n==0: pk2=tick-50
    elif pk2==STOP: pk2=tick
    return [STOP,STOP,pk2,recv]
for s,n,tick,ro,ru,pk,recv in ((0,0,100,5,6,7,0),(1,3,100,5,STOP,7,0),(1,3,100,5,6,7,0),(3,3,100,STOP,6,7,1),(3,3,100,5,6,7,0),(2,0,100,5,6,STOP,0),(2,0,100,5,6,20,0),(2,4,100,5,6,STOP,0),(2,4,100,5,6,20,0),(2,4,100,5,6,20,1),(2,0,100,5,6,20,1)):
    t.call('EF5-ARMADILLO-STATES',[s,n,tick,ro,ru,pk,recv],machine(s,n,tick,ro,ru,pk,recv),'10.3 animation states state %d inStateTicks %d tick %d roll out %s roll up %s peek %s peek received %d (roll out, roll up, peek, peek received)'%(s,n,tick,ro,ru,pk,recv))
save(t,5,10)
