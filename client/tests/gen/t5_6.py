from mesh5 import *
t=mk(5,6,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 6 (Polar bear): the meshes of the adult (128 x 64, scaled 1.2) and the baby (64 x 64), the pose after the quadruped base (standing",
 "scale squared, offsets multiplied by ageScale where the document says so; a pixel offset is multiplied by the layer scale as the root children carry the 1.2 scaling), the textures, the stand scale and its counter. Mesh rows",
 "are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['POLAR_BEAR','POLAR_BEAR_BABY']
mesh_checks(t,IDS,'6')
PI=math.pi
for layer,baby,sc in (('POLAR_BEAR',0,1.2),('POLAR_BEAR_BABY',1,1)):
    for (xr,yr,p,s,stand,a) in ((10,-20,1.2,0.5,0,1),(0,0,0,0,1/6,1),(-15,30,3.5,0.9,0.5,1),(5,5,2,0.4,1,1),(20,-10,2.5,0.7,0.75,1)):
        a=0.5 if baby else 1
        P={}
        for r in expected(layer)[0]:
            x=r.split()
            if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]
        H,B=P['head'],P['body']; RH,LH,RF,LF=P['right_hind_leg'],P['left_hind_leg'],P['right_front_leg'],P['left_front_leg']
        c1=math.cos(0.6662*p)*1.4*s; c2=math.cos(0.6662*p+PI)*1.4*s
        H[3]=xr*D; H[4]=yr*D; RH[3]=c1; LH[3]=c2; RF[3]=c2; LF[3]=c1
        e=stand*stand
        B[3]-=e*PI*0.35; B[1]+=e*a*2*sc
        RF[1]-=e*a*20*sc; RF[2]+=e*a*4*sc; RF[3]-=e*PI*0.45
        LF[1]=RF[1]; LF[2]=RF[2]; LF[3]-=e*PI*0.45
        H[1]-=e*24*sc; H[2]+=e*13*sc; H[3]+=e*PI*0.15
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin([xr,yr,p,s,stand,a]); t.raw('CALL "EF5-BEAR-ANIM" USING EMM-MODEL WS-IN')
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
for tt,o,n in ((0.5,0,3),(0.25,2,6),(1,6,6),(0,0,0),(0.75,4,5)): t.call('EF5-BEAR-STAND',[tt,o,n],[(o+tt*(n-o))/6],'6 standScale partial %s client counter %s to %s'%(tt,o,n))
def ctr(c,st): return min(6,c+1) if st else max(0,c-1)
for c,st in ((0,1),(5,1),(6,1),(3,0),(0,0),(1,0)): t.call('EF5-BEAR-COUNTER',[c,st],[ctr(c,st)],'6 client counter %s standing %d after one tick'%(c,st))
for b,p in ((0,'textures/entity/bear/polarbear.png'),(1,'textures/entity/bear/polarbear_baby.png')):
    t.raw('MOVE %d TO WS-IV(1)'%b,'CALL "EF5-BEAR-TEXTURE" USING WS-IN WS-X120'); t.text('6 baby %d texture'%b,p,'WS-X120')
save(t,5,6)
