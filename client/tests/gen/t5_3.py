from mesh5 import *
t=mk(5,3,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 3 (Cat and ocelot): 3.1 the meshes (ocelot, cat scaled 0.8, cat collar grown 0.01 and scaled 0.8 with the fixed tail2 grow, baby, baby collar scaled",
 "1.01), 3.2 and 3.3 setupAnim of the adult and the baby (crouching, sprinting, gaits, sitting, lying, relaxed), 3.4 textures, the collar layer and the lying body transform, 3.5 the lie-down and relax counters. Mesh rows are the",
 "tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['OCELOT','CAT','CAT_COLLAR','OCELOT_BABY','CAT_BABY','CAT_BABY_COLLAR']
mesh_checks(t,IDS,'3.1')
PI=math.pi
def c(x): return math.cos(x)
def rl(tt,a,b): return a+tt*(b-a)
def feline(layer,baby,st):
    xr,yr,p,s,a,crouch,sprint,sit,L,Lt,R=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]
    B,H,T1,T2=P['body'],P['head'],P['tail1'],P['tail2']
    LH,RH,LF,RF=P['left_hind_leg'],P['right_hind_leg'],P['left_front_leg'],P['right_front_leg']
    if crouch:
        B[1]+=1*a; H[1]+=2*a; T1[1]+=1*a; T2[1]+=-4*a; T2[2]+=2*a; T1[3]=T2[3]=1.5707964
    elif sprint:
        T2[1]=T1[1]; T2[2]+=2*a; T1[3]=T2[3]=1.5707964
    H[3]=xr*D; H[4]=yr*D
    if not sit:
        if not baby: B[3]=1.5707964
        if sprint:
            LH[3]=c(0.6662*p)*s; RH[3]=c(0.6662*p+0.3)*s; LF[3]=c(0.6662*p+PI+0.3)*s; RF[3]=c(0.6662*p+PI)*s
            T2[3]=1.7278761+0.31415927*c(p)*s
        else:
            LH[3]=c(0.6662*p)*s; RH[3]=c(0.6662*p+PI)*s; LF[3]=c(0.6662*p+PI)*s; RF[3]=c(0.6662*p)*s
            T2[3]=1.7278761+(0.47123894 if crouch else 0.7853982)*c(p)*s
    elif not baby:
        B[3]=0.7853982; B[1]+=-4*a; B[2]+=5*a; H[1]+=-3.3*a; H[2]+=1*a; T1[1]+=8*a; T1[2]+=-2*a; T2[1]+=2*a; T2[2]+=-0.8*a
        T1[3]=1.7278761; T2[3]=2.670354
        for l in (LF,RF): l[3]=-0.15707964; l[1]+=2*a; l[2]-=2*a
        for l in (LH,RH): l[3]=-1.5707964; l[1]+=3*a; l[2]-=4*a
    else:
        B[3]+=-0.43633232; B[1]+=1.25; H[2]+=0.75; T1[3]+=0.5454154; T1[1]+=4.0; T1[2]-=0.9; LH[2]-=0.9; RH[2]-=0.9
    if L>0:
        if not baby:
            H[5]=rl(L,H[5],-1.2707963); H[4]=rl(L,H[4],1.2707963); LF[3]=-1.2707963; RF[3]=-0.47079635; RF[5]=-0.2; RF[0]+=a
            LH[3]=-0.4; RH[3]=0.5; RH[5]=-0.5; RH[0]+=0.8*a; RH[1]+=2*a
            T1[3]=rl(Lt,T1[3],0.8); T2[3]=rl(Lt,T2[3],-0.4)
        else:
            B[0]+=1; H[3]=rl(L,H[3],0.17453292); H[5]=rl(L,H[5],-1.3089969); H[0]+=1.5; H[1]+=0.75; H[2]-=0.5
            RF[3]=-0.7853982; RF[0]+=3.5; RF[1]-=0.5; LF[3]=-1.5707964; LF[0]+=1.5; LF[1]-=1; LF[2]-=2
            RH[3]=0.6981317; RH[4]=0.34906584; RH[5]=-0.34906584; RH[0]+=2.5; RH[1]-=0.25; RH[2]+=0.5; LH[0]+=1.5; LH[2]-=1
            T1[3]+=rl(Lt,T1[3],-0.5235988); T1[4]+=rl(Lt,T1[4],0); T1[5]+=rl(Lt,T1[5],-0.17453292); T1[0]+=1; T1[1]+=0.5; T1[2]-=0.25
    if R>0: H[3]=rl(R,H[3],-0.58177644)
    return P
#      xr yr p s a crouch sprint sit L Lt R
STS=[(10,-20,1.2,0.5,1,0,0,0,0,0,0),(0,0,0,0,1,1,0,0,0,0,0),(-15,30,3.5,0.9,1,0,1,0,0,0,0),(5,5,2,0.4,1,1,1,0,0,0,0),(0,0,0.5,1,1,0,0,1,0,0,0),
     (12,-8,2.5,0.7,1,0,0,0,0.6,0.3,0),(3,3,1,0.2,1,0,0,0,1,1,0.5),(7,-7,4,0.8,1,1,0,0,0.25,0.75,0.4),(0,0,0,0,1,0,0,1,0.5,0.5,0.2)]
for layer,baby in (('OCELOT',0),('CAT',0),('CAT_COLLAR',0),('OCELOT_BABY',1),('CAT_BABY',1),('CAT_BABY_COLLAR',1)):
    for st in STS:
        a=0.5 if baby else 1
        st=st[:4]+(a,)+st[5:]
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby]); t.raw('CALL "EF5-FELINE-ANIM" USING EMM-MODEL WS-IN')
        P=feline(layer,baby,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
# 3.4
for b,p in ((0,'textures/entity/cat/ocelot.png'),(1,'textures/entity/cat/ocelot_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF5-OCELOT-TEXTURE" USING WS-IN WS-X120'); t.text('3.4 ocelot baby %d texture'%b,p,'WS-X120')
for b,p in ((0,'textures/entity/cat/cat_collar.png'),(1,'textures/entity/cat/cat_collar_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF5-CAT-COLLAR-TEXTURE" USING WS-IN WS-X120'); t.text('3.4 cat collar baby %d texture'%b,p,'WS-X120')
for tame in (0,1): t.call('EF5-CAT-COLLAR',[tame],[tame],'3.4 collar drawn when tamed %d'%tame)
for L,onp in ((0,0),(0,1),(0.5,0),(1,0),(0.3,1),(1,1)):
    ops=[]
    if L>0:
        ops=[(1,0.4*L,0.15*L,0.1*L),(4,0,0,L*90)]
        if onp: ops.append((1,0.15*L,0,0))
    t.call('EF5-CAT-BODY-OPS',[L,onp],[len(ops)]+[x for o in ops for x in o],'3.4 body transform lie amount %s on a sleeping player %d (count, code 1 translate 4 rotate about Z in degrees, values)'%(L,onp))
for tt,o,n in ((0.5,0.2,0.8),(0,0.3,1),(1,0,0.6)):
    t.call('EF5-LERP',[tt,o,n],[o+tt*(n-o)],'3.4 state lerp partial %s %s to %s'%(tt,o,n))
# 3.5
def cnt(l,lt,r,lying,rf):
    l=min(1,l+0.15) if lying else max(0,l-0.22)
    lt=min(1,lt+0.08) if lying else max(0,lt-0.13)
    r=min(1,r+0.1) if rf else max(0,r-0.13)
    return [l,lt,r]
for l,lt,r,lying,rf in ((0,0,0,1,0),(0.9,0.95,0,1,1),(1,1,0.95,1,1),(0.5,0.5,0.5,0,0),(0.1,0.05,0.1,0,0),(0,0,0,0,0)):
    t.call('EF5-CAT-COUNTERS',[l,lt,r,lying,rf],cnt(l,lt,r,lying,rf),'3.5 counters lie %s tail %s relax %s lying %d relax flag %d'%(l,lt,r,lying,rf))
for lying,sp in ((1,1),(1,0),(0,1),(0,0)): t.call('EF5-CAT-ON-PLAYER',[lying,sp],[1 if (lying and sp) else 0],'3.5 lying %d sleeping player near %d: lying on top'%(lying,sp))
for tick,lying,rel in ((0,1,0),(5,0,1),(7,1,0),(10,0,0),(15,1,1)): t.call('EF5-CAT-PURR',[tick,lying,rel],[1 if ((lying or rel) and tick%5==0) else 0],'3.5 tick %d lying %d relaxed %d purr'%(tick,lying,rel))
save(t,5,3)
