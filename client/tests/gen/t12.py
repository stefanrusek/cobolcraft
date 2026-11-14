from mesh4 import *
from ref4 import *
t=mk(4,12,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 12 (Rabbit): 12.1 the texture rule (toast, variant, baby), 12.2 setupAnim (head turn only while the idle tilt is stopped, then hop and tilt), 12.3 the variants",
 "with their ids (the sparse id map), 12.4 the geometry of rabbit and rabbit_baby, Appendix A.3 and A.4 (every animation: length, looping, channels, bone, target, key count and every channel sampled by an independent engine).",
 "Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
t.extra_ws+='\n'+KWS
IDS=['RABBIT','RABBIT_BABY']
mesh_checks(t,IDS,'12.4')
VAR=[(0,0,'brown'),(1,1,'white'),(2,2,'black'),(3,3,'white_splotched'),(4,4,'gold'),(5,5,'salt'),(6,99,'caerbannog')]
for o,i,n in VAR:
    t.call('EF4-RABBIT-VARIANT',[i],[o],'12.3 variant id %d is ordinal %d'%(i,o))
    for b in (0,1):
        t.raw('MOVE 0 TO WS-IV(1)','MOVE %d TO WS-IV(2)'%b,'MOVE %d TO WS-IV(3)'%o,'CALL "EF4-RABBIT-TEXTURE" USING WS-IN WS-X120')
        t.text('12.1 variant %d baby %d texture'%(o,b),'textures/entity/rabbit/rabbit_%s%s.png'%(n,'_baby' if b else ''),'WS-X120')
for i in (7,8,50,98,100,-1): t.call('EF4-RABBIT-VARIANT',[i],[0],'12.3 unknown id %d gives brown'%i)
for b in (0,1):
    t.raw('MOVE 1 TO WS-IV(1)','MOVE %d TO WS-IV(2)'%b,'MOVE 3 TO WS-IV(3)','CALL "EF4-RABBIT-TEXTURE" USING WS-IN WS-X120')
    t.text('12.1 toast baby %d texture'%b,'textures/entity/rabbit/rabbit_toast%s.png'%('_baby' if b else ''),'WS-X120')
AD=parse('A.3'); BB=parse('A.4')
NAMES=['RABBIT_HOP','RABBIT_IDLE_HEAD_TILT','RABBIT_BABY_HOP','RABBIT_BABY_IDLE_HEAD_TILT']; ALL=AD+BB
keytests(t,'EF4R',None,NAMES,ALL,'A')
MIN=-2147483648
ANI=dict(zip(NAMES,ALL))
def rabbit(layer,baby,st):
    xr,yr,age,hop,tilt=st
    parts={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': parts[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    if tilt==MIN:
        parts['head'][4]=yr*DEG; parts['head'][3]=xr*DEG
    pre='RABBIT_BABY_' if baby else 'RABBIT_'
    if hop!=MIN: apply(ANI[pre+'HOP'],int(float(int((age-hop)*50))),1,parts)
    if tilt!=MIN: apply(ANI[pre+'IDLE_HEAD_TILT'],int(float(int((age-tilt)*50))),1,parts)
    return parts
STS=[(10,20,0,MIN,MIN),(10,20,17,5,MIN),(-30,45,40.5,MIN,12),(5,5,60.25,50,52),(0,0,33,10,MIN),(15,-15,100,MIN,20.5),(7,7,200,191.5,150)]
for layer,baby in (('RABBIT',0),('RABBIT_BABY',1)):
    for st in STS:
        xr,yr,age,hop,tilt=st
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
        t.setin([xr,yr,age,baby,hop,tilt]); t.raw('CALL "EF4-RABBIT-ANIM" USING EMM-MODEL WS-IN')
        P=rabbit(layer,baby,st)
        pre='12.2 %s state %s '%(layer,'/'.join(lit(float(v)) for v in st))
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot','xs','ys','zs')): t.cur(part,f,P[part][kx])
save(t,4,12)
