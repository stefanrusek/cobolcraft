from wither7 import *
define()
t=mk(7,6,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 6 (The Wither): 6.1 the WITHER and WITHER_ARMOR (grow 0.5) meshes and setupAnim (head angles from the head arrays, ribcage and tail wave; worked example 11.5),",
 "6.2 the size scale from the invulnerable ticks and the texture rule (alternating every five), 6.3 the power swirl draw rule and offsets, 6.4 the wither skull mesh, texture and the block light level."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['WITHER','WITHER_ARMOR','WITHER_SKULL'],'6')
PI=math.pi
def wither(layer,st):
    xr,yr,age,body,yh0,xh0,yh1,xh1=st
    P=base_parts(layer); c=math.cos(age*0.1)
    P['right_head'][4]=(yh0-body)*0.017453292; P['right_head'][3]=xh0*0.017453292
    P['left_head'][4]=(yh1-body)*0.017453292; P['left_head'][3]=xh1*0.017453292
    rx=(0.065+0.05*c)*PI; P['ribcage'][3]=rx
    P['tail'][1]=6.9+math.cos(rx)*10; P['tail'][2]=-0.5+math.sin(rx)*10; P['tail'][3]=(0.265+0.1*c)*PI
    P['center_head'][4]=yr*0.017453292; P['center_head'][3]=xr*0.017453292
    return P
for st in ((10,-20,0,30,5,10,-5,-10),(0,0,10,0,0,0,0,0),(-15,40,33.25,-45,70,-20,100,15),(25,-90,7.5,180,-30,5,20,-25)):
    for layer in ('WITHER','WITHER_ARMOR'): pose_check(t,layer,'EF7-WITHER-ANIM',st,wither(layer,st))
for inv,e in ((0,2.0),(110,1.75),(220,1.5),(-5,2.0),(50.5,2-50.5/220*0.5)):
    t.call('EF7-WITHER-SCALE',[inv],[e],'6.2 size scale invulnerable ticks %s'%inv)
for inv in (0,-3,1,4,5,9,10,76,79,80,81,200,12.7):
    n=math.floor(inv)
    p='wither' if n<=0 else 'wither_invulnerable' if n>80 else 'wither' if (n//5)%2==1 else 'wither_invulnerable'
    text_check(t,'EF7-WITHER-TEXTURE',[inv,0],'6.2 texture invulnerable ticks %s'%inv,'textures/entity/wither/%s.png'%p)
text_check(t,'EF7-WITHER-TEXTURE',[0,1],'6.3 armor texture','textures/entity/wither/wither_armor.png')
for age,pw in ((0,1),(10,1),(33.5,1),(100.25,0),(52,1)):
    t.call('EF7-WITHER-SWIRL',[age,pw],[pw,math.fmod(math.cos(0.02*age)*3,1),(0.01*age)%1,-8355712,1] if pw else [0,0,0,-8355712,1],'6.3 swirl age %s powered %d (draw, u, v, tint, order)'%(age,pw))
t.call('EF7-WITHER-INV',[50,0.25],[49.75],'6.2 invulnerable ticks minus the partial tick'); t.call('EF7-WITHER-INV',[0,0.25],[0],'6.2 not above 0 gives 0')
for d,e in ((0,'wither'),(1,'wither_invulnerable')): text_check(t,'EF7-WITHER-SKULL-TEXTURE',[d],'6.4 skull texture dangerous %d'%d,'textures/entity/wither/%s.png'%e)
t.call('EF7-WITHER-RENDER',[],[1.0,15,15],'6 shadow radius, block light level, skull block light level')
save(t,7,6)
