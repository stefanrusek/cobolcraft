from worm6 import *
r,z=worm(SILVER,SLAYERS); setlayer('SILVERFISH',r,64,32)
t=mk(6,5,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 5 (Silverfish): 5.1 the seven segments and three layer boxes (size table, z recurrence, pivots, the odd layer 2 box; worked example 15.6),",
 "5.2 setupAnim (segment wave and the layers copying their segments), texture, shadow and flip."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['SILVERFISH'],'5.1')
t.build('SILVERFISH')
for i,(zz,py) in enumerate(zip((-3.5,-1.5,1,4,7,9.5,11.5),(22,21,20,21,22,23,23))):
    t.cur('segment%d'%i,'z',zz); t.cur('segment%d'%i,'y',py)
PI=3.1415927
def sil(age):
    P=base_parts('SILVERFISH')
    for i in range(7):
        a=age*0.9+i*0.15*PI
        P['segment%d'%i][4]=math.cos(a)*PI*0.05*(1+abs(i-2)); P['segment%d'%i][0]=math.sin(a)*PI*0.2*abs(i-2)
    P['layer0'][4]=P['segment2'][4]
    P['layer1'][4]=P['segment4'][4]; P['layer1'][0]=P['segment4'][0]
    P['layer2'][4]=P['segment1'][4]; P['layer2'][0]=P['segment1'][0]
    return P
for age in (0,10.5,33.25,100,2.75):
    pose_check(t,'SILVERFISH','EF6-SILVERFISH-ANIM',[age],sil(age))
t.build('SILVERFISH'); t.setin([0]); t.raw('CALL "EF6-SILVERFISH-ANIM" USING EMM-MODEL WS-IN')
for i,(yr,x) in enumerate(zip((0.47124,0.27992,0.09233,0.04915,-0.14562,-0.44429,-0.74696),(0,0.28525,0,0.62058,1.19513,1.33286,0.77664))): t.cur('segment%d'%i,'yrot',yr); t.cur('segment%d'%i,'x',x)
text_check(t,'EF6-SILVERFISH-TEXTURE',[0],'5 texture','textures/entity/silverfish/silverfish.png')
save(t,6,5)
