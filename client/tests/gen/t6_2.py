from mesh6 import *
setlayer('CREEPER',doc6.rows_from(6,'### 2.1',D='0'),64,32)
setlayer('CREEPER_ARMOR',doc6.rows_from(6,'### 2.1',D='2'),64,32)
t=mk(6,2,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 2 (Creeper): 2.1 the CREEPER and CREEPER_ARMOR (grow 2.0) meshes, 2.2 setupAnim (head look, the crossed leg child names, worked example 15.2),",
 "2.3 the swell scale (example 15.1), the white overlay progress, the swelling lerp and texture, 2.4 the charged swirl offsets, texture and tint."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['CREEPER','CREEPER_ARMOR'],'2.1')
PI=3.1415927
def creeper(st):
    xr,yr,w,s=st
    P=base_parts('CREEPER'); th=w*0.6662
    P['head'][3]=xr*0.017453292; P['head'][4]=yr*0.017453292
    for n in ('left_hind_leg','right_front_leg'): P[n][3]=math.cos(th)*1.4*s
    for n in ('right_hind_leg','left_front_leg'): P[n][3]=math.cos(th+PI)*1.4*s
    return P
for st in ((10,-20,1.0,1.0),(0,0,0,0),(-15,40,3.5,0.4),(25,-90,7.25,0.9)):
    pose_check(t,'CREEPER','EF6-CREEPER-ANIM',st,creeper(st))
for layer in ('CREEPER_ARMOR',):
    st=(5,5,2,0.5); P=base_parts(layer); th=st[2]*0.6662
    P['head'][3]=5*0.017453292; P['head'][4]=5*0.017453292
    for n in ('left_hind_leg','right_front_leg'): P[n][3]=math.cos(th)*1.4*0.5
    for n in ('right_hind_leg','left_front_leg'): P[n][3]=math.cos(th+PI)*1.4*0.5
    pose_check(t,layer,'EF6-CREEPER-ANIM',st,P)
def cscale(k):
    f=1+math.sin(k*100)*k*0.01; c=max(0,min(1,k)); c4=(c*c)*(c*c)
    return [(1+c4*0.4)*f,(1+c4*0.1)/f,(1+c4*0.4)*f]
for k in (1,0.5,0,0.25,0.8,1.3,-0.2):
    t.call('EF6-CREEPER-SCALE',[k],cscale(k),'2.3 swell scale k %s (x, y, z)'%k)
t.call('EF6-CREEPER-SCALE',[1],[1.392911,1.105598,1.392911],'2.3 example 15.1 swell 1 as printed')
def white(k):
    n=int(k*10)
    v=0 if n%2==0 else max(0.5,min(1,k))
    return [v,int(v*15)]
for k in (0.05,0.15,0.55,0.5,1.0,0,0.25,0.95,0.35,1.15):
    t.call('EF6-CREEPER-WHITE',[k],white(k),'2.3 white overlay at swell %s (progress, u)'%k)
for p,o,n,mx in ((0.5,10,12,20),(0,4,5,20),(1,18,20,30),(0.25,0,0,20)):
    t.call('EF6-CREEPER-SWELLING',[p,o,n,mx],[(o+p*(n-o))/(mx-2)],'2.3 swelling partial %s old %s swell %s max %s'%(p,o,n,mx))
text_check(t,'EF6-CREEPER-TEXTURE',[0],'2.3 texture','textures/entity/creeper/creeper.png')
for age in (0,25.5,100,137.25,0.01):
    m=(age*0.01)%1
    t.call('EF6-CREEPER-SWIRL',[age],[m,m],'2.4 swirl offsets at age %s (u, v)'%age)
text_check(t,'EF6-CREEPER-SWIRL-TEXTURE',[0],'2.4 swirl texture','textures/entity/creeper/creeper_armor.png')
t.call('EF6-CREEPER-SWIRL-TINT',[],[-8355712,1],'2.4 swirl tint ARGB and draw order (tint, order)')
t.raw('MOVE "NO_SUCH_LAYER" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.num('2 a layer that is not of this document is not known',0,'WS-OK')
save(t,6,2)
