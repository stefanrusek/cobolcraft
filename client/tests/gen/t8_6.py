from aq8b import *
import math,re
from g4 import REPO,DOCS
define_aq()
t=mk(8,6,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 6 (nautilus and zombie nautilus): 6.1 and 6.2 the adult and baby meshes, 6.3 setupAnim (clamped body angles, the SWIMMING keyframes of Appendix A.2",
 "sampled by an independent script from the document's own table) and the three layer models (saddle: one grown shell box; armor: three shell boxes, the first two grown 0.01; coral: the adult mesh plus corals), 6.4 the coral parts and their hiding under body armor,",
 "6.5 textures, equipment ids and the zombie nautilus variants, E11 (the swim worked example) and the Validation rows for the nautilus."],ck=True)
t.LP='EF8-LAYER'
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
IDS=['NAUTILUS','ZOMBIE_NAUTILUS','NAUTILUS_BABY','NAUTILUS_SADDLE','NAUTILUS_ARMOR','ZOMBIE_NAUTILUS_CORAL']
mesh_checks(t,IDS,'6')
# Appendix A.2, SWIMMING, read from the document
L=open(REPO+DOCS[8]).read().split('\n')
s=[i for i,l in enumerate(L) if l.startswith('### A.2')][0]
TR={}
for l in L[s:]:
    if l.startswith('## Open'): break
    m=re.match(r'\|\s*`(\w+)`\s*\|\s*(\w+)\s*\|\s*(.*)\|\s*$',l)
    if m and m.group(2) in ('rotation','scale'):
        keys=[]
        for k in m.group(3).split(';'):
            q=re.match(r'\s*([0-9.]+)\s*:\s*\(([^)]*)\)\s*(\w)',k)
            keys.append((float(q.group(1)),[float(v) for v in q.group(2).split(',')],q.group(3)))
        TR[(m.group(1),m.group(2))]=keys
assert len(TR)==6,TR.keys()
def sample(keys,tm):
    for i in range(len(keys)-1):
        if keys[i][0]<=tm<keys[i+1][0] or (i==len(keys)-2 and tm>=keys[-1][0]):
            a,b=keys[i],keys[i+1]; p=(tm-a[0])/(b[0]-a[0])
            return [a[1][k]+(b[1][k]-a[1][k])*p for k in range(3)]
D=0.017453292
def naut(layer,xr,yr,pos,sp,age):
    P=base_parts(layer)
    name='nroot'
    b=P['body']; b[3]=max(-10,min(10,xr))*D; b[4]=max(-10,min(10,yr))*D
    ms=int((pos+age/5)*50*2); tm=(ms/1000.0)%1.0
    st=min((sp+0.2)*3,1)
    for (part,target),keys in TR.items():
        v=sample(keys,tm); q=P[part]
        for k in range(3):
            if target=='rotation': q[3+k]+=v[k]*D*st
            else: q[6+k]+=(v[k]-1)*st
    return P
STATES=((0,0,0,0,0),(5,-20,1,0,10),(-15,12,2.5,0.4,3),(0,0,0.371,2,7.7),(30,30,10,0.05,99))
for layer in IDS:
    for xr,yr,pos,sp,age in STATES[:3]:
        P=naut(layer,xr,yr,pos,sp,age)
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin([xr,yr,pos,sp,age]); t.raw('CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN')
        for part in ('nroot','shell','body','upper_mouth','inner_mouth','lower_mouth'):
            for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
for xr,yr,pos,sp,age in STATES[3:]:
    P=naut('NAUTILUS',xr,yr,pos,sp,age)
    t.raw('MOVE "NAUTILUS" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([xr,yr,pos,sp,age]); t.raw('CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN')
    for part in ('body','upper_mouth','inner_mouth','lower_mouth'):
        for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
# E11
t.raw('MOVE "NAUTILUS" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,1,0,10]); t.raw('CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN')
t.cur('body','zs',1.072); t.cur('upper_mouth','xrot',10.8*D*0.6/0.6*0.6/0.6) if False else None
t.cur('upper_mouth','xrot',18*0.6*D)
# the coral hides when body armor is worn (WS-IN(6) = 1)
for armor in (0,1):
    t.raw('MOVE "ZOMBIE_NAUTILUS_CORAL" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,0,0,0,armor]); t.raw('CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN')
    t.vis('corals',0 if armor else 1)
t.raw('MOVE "NAUTILUS" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,0,0,0,0,1]); t.raw('CALL "EF8-NAUTILUS-ANIM" USING EMM-MODEL WS-IN')
t.vis('body',1)
# Validation: textures, shadow and layers of the family come from section 1 (EF8-ENTITY, EF8-TEXTURE)
for e,k,p in (('nautilus',1,'nautilus/nautilus.png'),('nautilus',2,'nautilus/nautilus_baby.png')):
    t.raw('MOVE "%s" TO WS-X24'%e,'MOVE %d TO WS-FL'%k,'MOVE SPACES TO WS-X60','CALL "EF8-TEXTURE" USING WS-X24 WS-FL WS-X60'); t.text('6.5 %s texture kind %d'%(e,k),p,'WS-X60')
for e,lay in (('nautilus',['nautilus','nautilus_baby','nautilus_armor','nautilus_saddle']),('zombie_nautilus',['zombie_nautilus','zombie_nautilus_coral','nautilus_armor','nautilus_saddle'])):
    t.raw('MOVE "%s" TO WS-X24'%e,'CALL "EF8-ENTITY" USING WS-X24 WS-OUT'); t.num('6.5 %s base shadow radius'%e,0.7,'WS-OV(2)'); t.num('6.5 %s model layers baked'%e,4,'WS-OV(3)')
# 6.5: the equipment ids, the zombie nautilus variants, the baby rule and the equipment layers' draw rules run through the replica (ENTITY-OVERLAY, ENTITY-TEX-PATH, ENTITY-MODEL-ROW) and are proved by client/tests/test_entity_nautilus_more.cob
save(t,8,6)
