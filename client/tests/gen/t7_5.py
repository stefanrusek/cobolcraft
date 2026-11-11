from nether7 import *
hoglin()
t=mk(7,5,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 5 (Hoglin and zoglin): 5.1 renderer facts (textures, shadow 0.7, shaking only for a converting hoglin), 5.2 the adult mesh, 5.3 the baby mesh,",
 "5.4 setupAnim (ear swing, head yaw, the headbutt factor and lerp with the baby offset, the diagonal leg pairs; worked example 11.4). Mesh rows are the tables of the document."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['HOGLIN','HOGLIN_BABY','ZOGLIN','ZOGLIN_BABY'],'5')
PI=math.pi
def hog(layer,st):
    yr,p,s,a,baby=st
    P=base_parts(layer)
    P['right_ear'][5]=-0.6981317-s*math.sin(p); P['left_ear'][5]=0.6981317+s*math.sin(p)
    h=P['head']; h[4]=yr*0.017453292
    f=1-abs(10-2*a)/10
    h[3]=0.87266463+f*(-0.34906584-0.87266463)
    if baby: h[1]+=f*2.5
    rf=math.cos(p)*1.2*s; lf=math.cos(p+PI)*1.2*s
    P['right_front_leg'][3]=rf; P['left_front_leg'][3]=lf; P['right_hind_leg'][3]=lf; P['left_hind_leg'][3]=rf
    return P
#   yRot p s attack
STS=[(10,1.0,0.5,0),(-20,2.5,0.3,5),(0,0,0,10),(30,3.3,1.2,3),(5,7,0.1,7)]
for layer,baby in (('HOGLIN',0),('HOGLIN_BABY',1),('ZOGLIN',0),('ZOGLIN_BABY',1)):
    for st in STS:
        st2=st+(baby,)
        pose_check(t,layer,'EF7-HOGLIN-ANIM',st2,hog(layer,st2))
t.build('HOGLIN'); t.setin([0,0,0,5,0]); t.raw('CALL "EF7-HOGLIN-ANIM" USING EMM-MODEL WS-IN'); t.cur('head','xrot',-0.34906584)
for z,b in ((0,0),(0,1),(1,0),(1,1)):
    n=('zoglin' if z else 'hoglin')+('_baby' if b else '')
    text_check(t,'EF7-HOGLIN-TEXTURE',[z,b],'5.1 texture zoglin %d baby %d'%(z,b),'textures/entity/hoglin/%s.png'%n)
t.call('EF7-HOGLIN-SHADOW',[],[0.7],'5.1 shadow radius')
for z,base,conv in ((0,0,0),(0,1,0),(0,0,1),(1,0,1),(1,1,0)): t.call('EF7-HOGLIN-SHAKING',[z,base,conv],[1 if (base or (conv and not z)) else 0],'5.1 shaking zoglin %d base %d converting %d'%(z,base,conv))
save(t,7,5)
