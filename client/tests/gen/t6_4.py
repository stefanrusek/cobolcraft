from worm6 import *
r,z=worm(EMITE); setlayer('ENDERMITE',r,64,32)
t=mk(6,4,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 4 (Endermite): 4.1 the four segments (size and texture table, z recurrence, pivots; worked example 15.6), 4.2 setupAnim (segment yaw and sideways",
 "shift from the age wave), texture, shadow and flip."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['ENDERMITE'],'4.1')
t.build('ENDERMITE')
for i,(zz,py) in enumerate(zip((-3.5,0,3,4),(21,20,21,22))):
    t.cur('segment%d'%i,'z',zz); t.cur('segment%d'%i,'y',py)
PI=3.1415927
def emite(age):
    P=base_parts('ENDERMITE')
    for i in range(4):
        a=age*0.9+i*0.15*PI
        P['segment%d'%i][4]=math.cos(a)*PI*0.01*(1+abs(i-2)); P['segment%d'%i][0]=math.sin(a)*PI*0.1*abs(i-2)
    return P
for age in (0,10.5,33.25,100,2.75):
    pose_check(t,'ENDERMITE','EF6-ENDERMITE-ANIM',[age],emite(age))
t.build('ENDERMITE'); t.setin([0]); t.raw('CALL "EF6-ENDERMITE-ANIM" USING EMM-MODEL WS-IN')
for i,(yr,x) in enumerate(zip((0.09425,0.05598,0.01847,0.00983),(0,0.14263,0,0.31029))): t.cur('segment%d'%i,'yrot',yr); t.cur('segment%d'%i,'x',x)
text_check(t,'EF6-ENDERMITE-TEXTURE',[0],'4 texture','textures/entity/endermite/endermite.png')
save(t,6,4)
