from blaze7 import *
setlayer('GHAST',ghast_rows(LENS),64,32,[4.5])
t=mk(7,3,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 3 (Ghast): 3.1 the mesh through the 4.5 scaling transformer (body centre at model y -4.856), the nine tentacles with the lengths drawn from the generator seeded 1660,",
 "3.2 setupAnim (tentacle swing), the shooting texture selected by the charging flag and the shadow radius 1.5."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['GHAST'],'3.1')
t.build('GHAST'); t.cur('body','y',-4.856); t.cur('body','ys',4.5)
for i,(x,z) in enumerate(zip((-3.75,1.25,6.25,-6.25,-1.25,3.75,-3.75,1.25,6.25),(-5,-5,-5,0,0,0,5,5,5))): t.cur('tentacle%d'%i,'x',x*4.5); t.cur('tentacle%d'%i,'z',z*4.5)
def ghast(age):
    P=base_parts('GHAST')
    for i in range(9): P['tentacle%d'%i][3]=0.2*math.sin(age*0.3+i)+0.4
    return P
for age in (0,10.5,33.25,100):
    pose_check(t,'GHAST','EF7-GHAST-ANIM',[age],ghast(age))
t.call('EF7-GHAST-LENGTHS',[],LENS,'3.1 tentacle lengths nextInt(7) + 8 from seed 1660')
for ch,e in ((0,'ghast.png'),(1,'ghast_shooting.png')): text_check(t,'EF7-GHAST-TEXTURE',[ch],'3 texture charging %d'%ch,'textures/entity/ghast/'+e)
t.call('EF7-GHAST-SHADOW',[],[1.5],'3 shadow radius')
save(t,7,3)
