from mesh5 import *
t=mk(5,2,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 2 (Wolf): 2.1 the meshes of wolf, wolf_armor (every cuboid grown by 0.2) and wolf_baby, 2.2 setupAnim (walk swing, tail, sitting pose for each age),",
 "2.3 the shake-off roll, 2.4 the texture rule (tame wins over angry, baby assets), the wet tint, the collar and armor layer rules and the crackiness levels, 2.5 the tail angle, head roll, shake and wet shade extraction, 2.6 the per-tick",
 "counters. Mesh rows are the tables of the document; formula values were worked by an independent script."],ck=True)
IDS=['WOLF','WOLF_ARMOR','WOLF_BABY']
mesh_checks(t,IDS,'2.1')
PI=math.pi
def roll(sa,extra):
    u=min(1,max(0,(sa+extra)/1.8)); return math.sin(u*PI)*math.sin(u*PI*11)*0.15*PI
def wolf(layer,baby,st):
    xr,yr,wp,ws,ages,ang,sit,sa,hroll,tail=st
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]
    P['tail'][5]=0 if ang else math.cos(0.6662*wp)*1.4*ws
    a=ages
    if sit:
        P['body'][1]+=4*a; P['body'][2]-=2*a; P['body'][3]=0.7853982
        P['tail'][1]+=9*a; P['tail'][2]-=2*a
        for l in ('right_hind_leg','left_hind_leg'): P[l][1]+=6.7*a; P[l][2]-=5*a; P[l][3]=4.712389
        for l in ('right_front_leg','left_front_leg'): P[l][3]=5.811947; P[l][1]+=1*a
        P['right_front_leg'][0]+=0.01*a; P['left_front_leg'][0]-=0.01*a
        if not baby: P['upper_body'][1]+=2; P['upper_body'][3]=1.2566371; P['upper_body'][4]=0
        else: P['body'][3]=0.7853982-1.5707964
    else:
        P['right_hind_leg'][3]=math.cos(0.6662*wp)*1.4*ws; P['left_hind_leg'][3]=math.cos(0.6662*wp+PI)*1.4*ws
        P['right_front_leg'][3]=math.cos(0.6662*wp+PI)*1.4*ws; P['left_front_leg'][3]=math.cos(0.6662*wp)*1.4*ws
    P['body'][5]=roll(sa,-0.16)
    if not baby:
        P['real_head'][5]=hroll+roll(sa,0); P['upper_body'][5]=roll(sa,-0.08); P['real_tail'][5]=roll(sa,-0.2)
    else:
        P['head'][5]=hroll+roll(sa,0); P['tail'][5]=roll(sa,-0.2)
    P['head'][3]=xr*D; P['head'][4]=yr*D
    P['tail'][3]=tail
    return P
STS=[(10,-20,1.2,0.5,1,0,0,0,0,0.62831855),(0,0,0,0,1,1,0,0,0,1.5393804),(-15,30,3.5,0.9,0.5,0,1,0,0.2,0.9),(5,5,2,0.4,1,0,1,0.9,0.05,0.62831855),(0,0,0.5,1,0.5,1,1,0.3,0.1,1.2),(20,-40,4,0.7,1,0,0,1.5,0,0.7)]
for layer,baby in (('WOLF',0),('WOLF_ARMOR',0),('WOLF_BABY',1)):
    for st in STS:
        xr,yr,wp,ws,ages,ang,sit,sa,hroll,tail=st
        ages=0.5 if baby else 1
        st=(xr,yr,wp,ws,ages,ang,sit,sa,hroll,tail)
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF5-WOLF-ANIM" USING EMM-MODEL WS-IN')
        P=wolf(layer,baby,st)
        pre='2.2 %s state %s '%(layer,'/'.join(lit(float(v)) for v in st))
        for part in sorted(P):
            for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
for sa,ex,e in ((0,0,0),(0.9,0,roll(0.9,0)),(1.8,0,0),(0.5,-0.16,roll(0.5,-0.16)),(1.0,-0.2,roll(1.0,-0.2)),(2.5,0,0),(0.1,-0.5,0)):
    t.call('EF5-WOLF-ROLL',[sa,ex],[e],'2.3 body roll angle shake %s extra %s'%(sa,ex))
# 2.4
for baby in (0,1):
  for tame in (0,1):
    for ang in (0,1):
        k=2 if tame else (1 if ang else 0)
        t.call('EF5-WOLF-TEXTURE-KIND',[baby,tame,ang],[k],'2.4 baby %d tame %d angry %d texture entry (0 wild 1 angry 2 tame)'%(baby,tame,ang))
for var,pre in (('pale','wolf'),('ashen','wolf_ashen')):
    for baby in (0,1):
        for k,sfx in ((0,''),(1,'_angry'),(2,'_tame')):
            fn=pre+sfx+('_baby' if baby else '')
            t.raw('MOVE "%s" TO WS-X24'%var,'MOVE %d TO WS-FL'%baby,'MOVE %d TO WS-IV(1)'%k,'CALL "EF5-WOLF-ASSET" USING WS-X24 WS-FL WS-IN WS-X120')
            t.text('2.4 %s baby %d entry %d texture'%(var,baby,k),'textures/entity/wolf/%s.png'%(fn if var!='pale' or True else fn),'WS-X120')
for wet,sa,e in ((0,0.5,1),(1,0,0.75),(1,1.0,0.875),(1,2.0,1),(1,3.0,1)):
    t.call('EF5-WOLF-WET',[wet,sa],[e],'2.4/2.5 wet shade wet %d shake %s'%(wet,sa))
for tame,inv in ((0,0),(1,0),(1,1),(0,1)): t.call('EF5-WOLF-COLLAR',[tame,inv],[1 if (tame and not inv) else 0,1],'2.4 collar tame %d invisible %d: drawn, layer order'%(tame,inv))
for eq in (0,1):
  for asset in (0,1):
    for baby in (0,1): t.call('EF5-WOLF-ARMOR',[eq,asset,baby],[1 if (eq and asset and not baby) else 0],'2.4 armor equippable %d asset %d baby %d drawn'%(eq,asset,baby))
for mx,dm,dmgable in ((100,0,1),(100,4,1),(100,5,1),(100,30,1),(100,31,1),(100,32,1),(100,68,1),(100,69,1),(100,90,1),(1,0,0),(200,20,1)):
    f=(mx-dm)/mx
    lv=0
    if dmgable:
        lv=3 if f<0.32 else 2 if f<0.69 else 1 if f<0.95 else 0
    t.call('EF5-WOLF-CRACK',[mx,dm,dmgable],[lv],'2.4 crackiness max %s damage %s damageable %d (0 none 1 low 2 medium 3 high)'%(mx,dm,dmgable))
for ang,tame,mh,h in ((1,0,20,20),(0,1,20,20),(0,1,20,10),(0,1,20,0),(0,0,20,5)):
    e=1.5393804 if ang else ((0.55-0.4*((mh-h)/mh))*PI if tame else 0.62831855)
    t.call('EF5-WOLF-TAIL',[ang,tame,mh,h],[e],'2.5 tail angle angry %d tame %d health %s of %s'%(ang,tame,h,mh))
for tt,o,n in ((0.5,0.2,0.8),(0.25,0,1),(1,0.4,0.64)):
    t.call('EF5-WOLF-HEADROLL',[tt,o,n],[(o+tt*(n-o))*0.15*PI],'2.5 headRollAngle partial %s from %s to %s'%(tt,o,n))
# 2.6 counters
def tick(ia,intr,sa,shaking):
    io=ia; ia=ia+0.4*((1 if intr else 0)-ia)
    so=sa;dry=0;part=0
    if shaking:
        so=sa; sa+=0.05
        if so>=2: dry=1; so=0; sa=0
        elif sa>0.4: part=int(math.sin((sa-0.4)*PI)*7)
    return [io,ia,so,sa,dry,part]
for ia,intr,sa,shaking in ((0,1,0,0),(0.4,1,0,0),(0.6,0,0,0),(0,0,0,1),(0,0,0.38,1),(0,0,0.7,1),(0,0,1.0,1),(0,0,1.95,1),(0,0,2.0,1)):
    t.call('EF5-WOLF-TICK',[ia,intr,sa,shaking],tick(ia,intr,sa,shaking),'2.6 tick interested angle %s interested %d shake %s shaking %d: old angle, angle, old shake, shake, dry, particles'%(ia,intr,sa,shaking))
t.raw('MOVE "NOT_A_LAYER" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
t.num('an unknown layer id is not built (ok 0; coverage-only addition)',0,'WS-OK')
save(t,5,2)
