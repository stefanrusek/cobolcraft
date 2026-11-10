from mesh5 import *
from ref4 import sample,apply,keytests,KWS
import app5
t=mk(5,4,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 4 (Fox): 4.1 the meshes of fox and fox_baby, 4.2 setupAnim (adult leg swing, the FOX_BABY_WALK keyframes, crouching, sleeping,",
 "sitting, pouncing, head look, the sleeping head roll, faceplanted with the persistent leg counter), the FOX_BABY_WALK keyframe table (section 15.1: every channel sampled by an independent engine), 4.3 texture rule, body transform,",
 "head roll and counters, 4.4 the held item layer transform. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
t.extra_ws+='\n'+KWS
IDS=['FOX','FOX_BABY']
mesh_checks(t,IDS,'4.1')
AN=app5.parse('15.1')
keytests(t,'EF5F',None,['FOX_BABY_WALK'],AN,'15.1')
PI=math.pi
MINW=lambda p,s:(int(p*50*1)/1000,min(s*2.5,1))
def fox(layer,baby,st,lm):
    xr,yr,p,s,a,A,C,roll,crouch,sleep,sit,face,pounce=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    vis={'right_hind_leg':1,'left_hind_leg':1,'right_front_leg':1,'left_front_leg':1}
    B,H,T=P['body'],P['head'],P['tail']
    RH,LH,RF,LF=P['right_hind_leg'],P['left_hind_leg'],P['right_front_leg'],P['left_front_leg']
    H[5]=roll
    if not baby:
        RH[3]=math.cos(0.6662*p)*1.4*s; LH[3]=math.cos(0.6662*p+PI)*1.4*s; RF[3]=math.cos(0.6662*p+PI)*1.4*s; LF[3]=math.cos(0.6662*p)*1.4*s
    else:
        tt,k=MINW(p,s)
        a0=AN[0]; tm=tt-0.5*math.floor(tt/0.5)
        apply(a0,int(p*50*1),k,P)
    if crouch:
        B[3]+=0.10471976; H[1]+=C*a; w=math.cos(A)*0.05; B[4]=w; RH[5]=w; LH[5]=w; RF[5]=w/2; LF[5]=w/2
        B[1]+= C/6 if baby else C
    elif sleep:
        for k in vis: vis[k]=0
        if not baby:
            B[5]=-1.5707964; B[1]+=5; T[3]=-2.6179938; H[0]+=2; H[1]+=2.99; H[4]=-2.0943952; H[5]=0
        else:
            B[5]=-1.5707964; B[3]=-0.17453292; B[1]+=1.5; B[2]-=1.5; B[0]-=1.5; T[3]=-2.1816616; T[0]-=0.7; T[2]+=0.6; T[1]+=0.9
            H[0]-=2; H[1]+=2.8; H[2]-=4; H[4]=-2.0943952; H[5]=0
    elif sit:
        H[3]=0; H[4]=0
        if not baby:
            B[3]=0.5235988; B[1]-=7; B[2]+=3; T[3]=0.7853982; H[1]-=6.5; H[2]+=2.75; RF[3]=LF[3]=-0.2617994
            for l in (RH,LH): l[3]=-1.3089969; l[1]+=4; l[2]-=0.25
            T[2]-=1
        else:
            B[3]=-0.959931; B[2]-=4.5*a; B[1]+=3*a; T[1]-=0.6; T[2]-=2*a; T[3]=0.95993114; H[1]-=0.75
            for l in (RF,LF): l[3]=-0.2617994; l[2]-=1.5
            RF[0]+=0.01; LF[0]-=0.01
            for l in (RH,LH): l[2]-=3.75
            RH[0]+=0.01; LH[0]-=0.01
    if pounce and not baby:
        h=C/2; B[1]-=h; H[1]-=h
    if not (sleep or face or crouch):
        H[3]=xr*D; H[4]=yr*D
    if sleep:
        H[3]=0; H[4]=-2.0943952; H[5]=math.cos(0.027*A)/22
    m=lm
    if face:
        m=lm+0.67
        RH[3]=math.cos(0.4662*m)*0.1; LH[3]=math.cos(0.4662*m+PI)*0.1; RF[3]=math.cos(0.4662*m+PI)*0.1; LF[3]=math.cos(0.4662*m)*0.1
    return P,vis,m
#      xr yr p s a A C roll crouch sleep sit face pounce
STS=[(10,-20,1.25,0.5,1,12.5,0,0.1,0,0,0,0,0),(0,0,0,0,1,0,3,0,1,0,0,0,0),(-15,30,3.5,0.9,1,40,0,0.05,0,1,0,0,0),(5,5,2,0.4,1,5,0,0,0,0,1,0,0),(0,0,0.5,1,1,3,4,0,0,0,0,0,1),
     (20,-10,2.5,0.7,1,6.5,2,0.2,0,0,0,1,0),(7,-7,4,0.8,1,9,5,0.1,1,1,1,0,1),(7,-7,4,0.8,1,9,5,0.1,0,1,1,1,0)]
for layer,baby in (('FOX',0),('FOX_BABY',1)):
    for st in STS:
        a=0.5 if baby else 1
        st=st[:4]+(a,)+st[5:]
        lm=1.5
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby,lm]); t.raw('CALL "EF5-FOX-ANIM" USING EMM-MODEL WS-IN')
        P,vis,m=fox(layer,baby,st,lm)
        pre='4.2 %s state %s '%(layer,'/'.join(lit(float(v)) for v in st))
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
        for k,v in vis.items(): t.vis(k,v)
        t.num('4.2 legMotionPos persists (+0.67 each faceplanted frame)',m,'WS-IV(15)')
for v,sl,b,fn in ((0,0,0,'fox'),(0,1,0,'fox_sleep'),(0,0,1,'fox_baby'),(0,1,1,'fox_sleep_baby'),(1,0,0,'fox_snow'),(1,1,0,'fox_snow_sleep'),(1,0,1,'fox_snow_baby'),(1,1,1,'fox_snow_sleep_baby'),(2,1,1,'fox'),(5,0,0,'fox')):
    t.raw('MOVE %d TO WS-IV(1)'%v,'MOVE %d TO WS-IV(2)'%sl,'MOVE %d TO WS-IV(3)'%b,'CALL "EF5-FOX-TEXTURE" USING WS-IN WS-X120'); t.text('4.3 variant %d sleeping %d baby %d texture'%(v,sl,b),'textures/entity/fox/%s.png'%fn,'WS-X120')
for pn,fp,xr in ((0,0,30),(1,0,30),(0,1,-12),(1,1,5)):
    t.call('EF5-FOX-BODY',[pn,fp,xr],[1,-xr] if (pn or fp) else [0,0],'4.3 body transform pouncing %d faceplanted %d xRot %s (count, rotate X degrees)'%(pn,fp,xr))
for tt,o,n in ((0.5,0.2,0.8),(1,0,1),(0.25,0.4,0.64)):
    t.call('EF5-FOX-HEADROLL',[tt,o,n],[(o+tt*(n-o))*0.11*PI],'4.3 head roll partial %s %s to %s'%(tt,o,n))
def ftick(ia,flag,ca,crouch):
    io=ia; ia=ia+0.4*((1 if flag else 0)-ia)
    co=ca; ca=min(5,ca+0.2) if crouch else 0
    return [io,ia,co,ca]
for ia,flag,ca,cr in ((0,1,0,0),(0.5,0,0,0),(0.3,1,4.9,1),(0,0,2,1),(0.2,0,3,0)):
    t.call('EF5-FOX-TICK',[ia,flag,ca,cr],ftick(ia,flag,ca,cr),'4.3 tick interested angle %s flag %d crouch %s crouching %d'%(ia,flag,ca,cr))
# 4.4 held item layer
def item(baby,sleep,h,roll,yr,xr,empty):
    if empty: return [0]
    ops=[(1,h[0]/16,h[1]/16,h[2]/16)]
    if baby: ops.append((2,0.75,0.75,0.75))
    ops+=[(5,roll,0,0),(3,yr,0,0),(6,xr,0,0)]
    off={(0,0):(0.06,0.27,-0.5),(0,1):(0.46,0.26,0.22),(1,0):(0.06,0.26,-0.5),(1,1):(0.4,0.26,0.15)}[(baby,sleep)]
    ops.append((1,)+off); ops.append((6,90,0,0))
    if sleep: ops.append((4,90,0,0))
    return [len(ops)]+[x for o in ops for x in o]
for baby in (0,1):
    for sleep in (0,1):
        for empty in (0,1):
            h=(1.5,17.25,-3.75); roll=0.3; yr=25; xr=-10
            t.call('EF5-FOX-ITEM-OPS',[baby,sleep,h[0],h[1],h[2],roll,yr,xr,empty],item(baby,sleep,h,roll,yr,xr,empty),'4.4 held item baby %d sleeping %d empty %d (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 5 rotate Z rad 6 rotate X deg; values)'%(baby,sleep,empty))
save(t,5,4)
