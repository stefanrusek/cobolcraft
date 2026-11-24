from nether7 import *
strider()
t=mk(7,4,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 4 (Strider): 4.1 the renderer facts (texture by suffocating and baby, shadow with the baby half, cold shaking, the saddle layer decision), 4.2 the shared animation, 4.3 the adult mesh",
 "with its bristles and the adult custom animation, 4.4 the baby mesh and its custom animation (worked value 16.75). Mesh rows are the tables of the document."],ck=True)
t.LP='EF7-LAYER'
mesh_checks(t,['STRIDER','STRIDER_BABY','STRIDER_SADDLE'],'4')
PI=math.pi
def strider_pose(layer,st):
    xr,yr,p,sp,age,ridden,baby=st
    P=base_parts(layer); s=min(sp,0.25)
    b=P['body']
    if not ridden: b[3]=xr*0.017453292; b[4]=yr*0.017453292
    b[5]=0.1*math.sin(1.5*p)*4*s
    ll,rl=P['left_leg'],P['right_leg']
    ll[3]=math.sin(1.5*p*0.5)*2*s; rl[3]=math.sin(1.5*p*0.5+PI)*2*s
    ll[5]=0.17453292*math.cos(1.5*p*0.5)*s; rl[5]=0.17453292*math.cos(1.5*p*0.5+PI)*s
    base=math.cos(1.5*p+PI)*s
    def bristle(top,mid,bot,idx):
        top[idx]+=0.6*base; mid[idx]+=1.2*base; bot[idx]+=1.3*base
        top[idx]+=0.1*math.sin(0.4*age); mid[idx]+=0.1*math.sin(0.2*age); bot[idx]+=0.05*math.sin(-0.4*age)
    if not baby:
        for n,v in (('right_top_bristle',-0.87266463),('right_middle_bristle',-1.134464),('right_bottom_bristle',-1.2217305),('left_top_bristle',0.87266463),('left_middle_bristle',1.134464),('left_bottom_bristle',1.2217305)): P[n][5]=v
        bristle(P['right_top_bristle'],P['right_middle_bristle'],P['right_bottom_bristle'],5)
        bristle(P['left_top_bristle'],P['left_middle_bristle'],P['left_bottom_bristle'],5)
        b[1]=2-2*math.cos(1.5*p)*2*s
        ll[1]=8+2*math.sin(1.5*p*0.5+PI)*2*s; rl[1]=8+2*math.sin(1.5*p*0.5)*2*s
    else:
        b[1]=17.25-2*math.cos(1.5*p)*s
        ll[1]=20+2*math.sin(1.5*p*0.5+PI)*2*s; rl[1]=20+2*math.sin(1.5*p*0.5)*2*s
        bristle(P['bristle2'],P['bristle1'],P['bristle0'],3)
    return P
#   xRot yRot p speed age ridden baby
STS=[(10,-20,1.0,0.25,0,0,0),(5,5,2.5,0.1,12.5,1,0),(0,0,0,0,0,0,0),(-15,30,3.3,0.9,40.25,0,0),(20,-40,7,0.2,6,1,0)]
for layer,baby in (('STRIDER',0),('STRIDER_BABY',1),('STRIDER_SADDLE',0)):
    for st in STS:
        st2=st[:6]+(baby,)
        pose_check(t,layer,'EF7-STRIDER-ANIM',st2,strider_pose(layer,st2))
t.build('STRIDER_BABY'); t.setin([0,0,0,0.25,0,0,1]); t.raw('CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN'); t.cur('body','y',16.75)
for sf,bb in ((0,0),(0,1),(1,0),(1,1)):
    n='strider'+('_cold' if sf else '')+('_baby' if bb else '')
    text_check(t,'EF7-STRIDER-TEXTURE',[sf,bb],'4.1 texture suffocating %d baby %d'%(sf,bb),'textures/entity/strider/%s.png'%n)
for b,sc in ((0,1),(1,1),(0,2),(1,3)): t.call('EF7-STRIDER-SHADOW',[b,sc],[0.5*sc*(0.5 if b else 1)],'4.1 shadow baby %d scale %s'%(b,sc))
for fz,sf in ((0,0),(1,0),(0,1),(1,1)): t.call('EF7-STRIDER-SHAKING',[fz,sf],[1 if (fz or sf) else 0],'4.1 shaking fully frozen %d suffocating %d'%(fz,sf))
for eq,aid,baby in ((1,1,0),(0,1,0),(1,0,0),(1,1,1)): t.call('EF7-STRIDER-SADDLE',[eq,aid,baby],[1 if (eq and aid and not baby) else 0],'4.1 saddle layer equippable %d asset id %d baby %d'%(eq,aid,baby))
text_check(t,'EF7-STRIDER-SADDLE-TEXTURE',[0],'4.1 saddle texture','textures/entity/equipment/strider_saddle/saddle.png')
save(t,7,4)
