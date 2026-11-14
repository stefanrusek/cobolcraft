from mesh5 import *
t=mk(5,5,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 5 (Panda): 5.1 the meshes of panda and panda_baby, 5.2 setupAnim after the quadruped base (unhappy, sneezing with the integer division, sitting for each age,",
 "eating, scared, lying on the back, rolling), 5.3 the body transform (the four roll phases, sitting, lying), 5.4 the gene textures with the unknown-gene fallback, the held item layer and the counters. Mesh rows are the tables of the",
 "document; formula values were worked by an independent script."],ck=True)
IDS=['PANDA','PANDA_BABY']
mesh_checks(t,IDS,'5.1')
PI=math.pi
def sn(x): return math.sin(x)
def wrapr(d):
    while d>=PI: d-=2*PI
    while d<-PI: d+=2*PI
    return d
def rlr(tt,a,b): return a+tt*wrapr(b-a)
def lerp(tt,a,b): return a+tt*(b-a)
def panda(layer,baby,st):
    xr,yr,p,s,A,unh,sneeze,n,S,eat,scared,B,R=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]
    H,Bd=P['head'],P['body']
    RH,LH,RF,LF=P['right_hind_leg'],P['left_hind_leg'],P['right_front_leg'],P['left_front_leg']
    a_=math.cos(0.6662*p)*1.4*s; b_=math.cos(0.6662*p+PI)*1.4*s
    H[3]=xr*D; H[4]=yr*D; RH[3]=a_; LH[3]=b_; RF[3]=b_; LF[3]=a_
    if unh:
        H[4]=0.35*sn(0.6*A); H[5]=0.35*sn(0.6*A); RF[3]=-0.75*sn(0.3*A); LF[3]=0.75*sn(0.3*A)
    else: H[5]=0
    if sneeze:
        if n<15: H[3]=(-0.7853982*n)/14
        elif n<20: H[3]=-0.7853982+0.7853982*((n-15)//5)
    if S>0:
        if not baby:
            Bd[3]=rlr(S,Bd[3],1.7407963); H[3]=rlr(S,H[3],1.5707964)
        else:
            Bd[3]=rlr(S,Bd[3],0.17453292); Bd[2]=lerp(S,Bd[2],-1.5); H[2]=lerp(S,H[2],-11.5); H[1]=lerp(S,H[1],17.5)
            RF[2]=lerp(S,RF[2],-5); LF[2]=lerp(S,LF[2],-5); RH[2]=lerp(S,RH[2],3); LH[2]=lerp(S,LH[2],3)
        RF[5]=-0.27079642; LF[5]=0.27079642; RH[5]=0.5707964; LH[5]=-0.5707964
        if eat:
            H[3]=1.5707964+0.2*sn(0.6*A); RF[3]=LF[3]=-0.4-0.2*sn(0.6*A)
        if scared:
            H[3]=2.1707964; RF[3]=LF[3]=-0.9
    else:
        for l in (RH,LH,RF,LF): l[5]=0
    if B>0:
        RH[3]=-0.6*sn(0.15*A); LH[3]=0.6*sn(0.15*A); RF[3]=0.3*sn(0.25*A); LF[3]=-0.3*sn(0.25*A); H[3]=rlr(B,H[3],1.5707964)
    if R>0:
        H[3]=rlr(R,H[3],2.0561945); RH[3]=-0.5*sn(0.5*A); LH[3]=0.5*sn(0.5*A); RF[3]=0.5*sn(0.5*A); LF[3]=-0.5*sn(0.5*A)
    return P
#      xr yr p s A unh sneeze n S eat scared B R
STS=[(10,-20,1.2,0.5,12.5,0,0,0,0,0,0,0,0),(0,0,0,0,3,1,0,0,0,0,0,0,0),(-15,30,3.5,0.9,40,0,1,7,0,0,0,0,0),(5,5,2,0.4,5,0,1,16,0,0,0,0,0),(0,0,0.5,1,3,0,1,19,0,0,0,0,0),
     (8,8,1,0.2,6.5,0,0,0,0.6,0,0,0,0),(8,8,1,0.2,6.5,0,0,0,1,1,0,0,0),(8,8,1,0.2,6.5,0,0,0,0.5,0,1,0,0),(8,8,1,0.2,6.5,0,0,0,0.5,1,1,0,0),(0,0,2,0.7,9,0,0,0,0,0,0,0.5,0),(0,0,2,0.7,9,0,0,0,0,0,0,0,0.8),(3,3,2,0.7,9,1,1,10,1,0,0,0.4,0.6)]
for layer,baby in (('PANDA',0),('PANDA_BABY',1)):
    for st in STS:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)+[baby]); t.raw('CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN')
        P=panda(layer,baby,st)
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
# 5.3 body transform
def pbody(baby,r,S,scared,A,xr,B):
    ops=[]
    h=0.3 if baby else 0.8
    if r>0:
        k=int(math.floor(r)); f=r-k; k1=k+1
        if k<=7: a0,a1,lim=90*k/7,90*k1/7,8
        elif k<=15: a0,a1,lim=90+90*(k-8)/7,90+90*(k1-8)/7,16
        elif k<=23: a0,a1,lim=180+90*(k-16)/7,180+90*(k1-16)/7,24
        elif k<=31: a0,a1,lim=270+90*(k-24)/7,270+90*(k1-24)/7,32
        else: a0=None
        if a0 is not None:
            g=lerp(f,a0,a1) if k1<lim else a0
            if k<=7: ty=(h+0.2)*(g/90)
            elif k<=15: ty=(h+0.2)+(h-0.2)*(g-90)/90
            elif k<=23: ty=h+h*(270-g)/90
            else: ty=h*(360-g)/90
            ops+=[(1,0,ty,0),(6,-g,0,0)]
    if S>0:
        ops+=[(1,0,0.8*S,0),(6,lerp(S,xr,xr+90),0,0),(1,0,-1.0*S,0)]
        if scared:
            ops.append((3,math.cos(1.25*A)*PI*0.05,0,0))
            if baby: ops.append((1,0,0.8,0.55))
    if B>0:
        c=0.5 if baby else 1.3
        ops+=[(1,0,c*B,0),(6,lerp(B,xr,xr+180),0,0)]
    return [len(ops)]+[x for o in ops for x in o]
for baby in (0,1):
    for r,S,sc,A,xr,B in ((0,0,0,0,0,0),(3.25,0,0,0,10,0),(7.5,0,0,0,10,0),(8,0,0,0,0,0),(12.75,0,0,0,5,0),(16.5,0,0,0,5,0),(20,0,0,0,5,0),(24.25,0,0,0,5,0),(31.5,0,0,0,5,0),(32,0,0,0,5,0),(40,0,0,0,5,0),
                           (0,0.5,0,5,20,0),(0,1,1,7.5,20,0),(0,0.3,1,2,-10,0),(0,0,0,0,15,0.6),(0,0.4,1,3,12,0.7),(5.5,0.2,0,3,12,0.9)):
        t.call('EF5-PANDA-BODY',[baby,r,S,sc,A,xr,B],pbody(baby,r,S,sc,A,xr,B),'5.3 body transform baby %d roll %s sit %s scared %d age %s xRot %s lie %s (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)'%(baby,r,S,sc,A,xr,B))
GEN=['panda','panda_lazy','panda_worried','panda_playful','panda_brown','panda_weak','panda_aggressive']
BG=['panda_baby','lazy_panda_baby','worried_panda_baby','playful_panda_baby','brown_panda_baby','weak_panda_baby','aggressive_panda_baby']
for g in (0,1,2,3,4,5,6,7,9,-1):
    for b in (0,1):
        gi=g if 0<=g<=6 else 0
        t.raw('MOVE %d TO WS-IV(1)'%g,'MOVE %d TO WS-IV(2)'%b,'CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120'); t.text('5.4 gene %d baby %d texture'%(g,b),'textures/entity/panda/%s.png'%((BG if b else GEN)[gi]),'WS-X120')
for ne in (0,1):
  for sit in (0,1):
    for sc in (0,1):
      for eat in (0,1):
        A=7.5
        draw=1 if (ne and sit and not sc) else 0
        z=-0.6; y=1.4
        if eat: z=-0.6-(0.2*sn(0.6*A)+0.2); y=1.4-0.09*sn(0.6*A)
        t.call('EF5-PANDA-ITEM',[ne,sit,sc,eat,A],[draw,0.1,y,z] if draw else [0,0,0,0],'5.4 item layer item %d sitting %d scared %d eating %d: drawn, translate x y z'%(ne,sit,sc,eat))
def ctr(a,fl): return min(1,a+0.15) if fl else max(0,a-0.19)
for a,fl in ((0,1),(0.9,1),(1,1),(0.5,0),(0.1,0),(0,0)): t.call('EF5-PANDA-COUNTER',[a,fl],[ctr(a,fl)],'5.4 sit/back/roll amount %s flag %d after one tick'%(a,fl))
save(t,5,5)
