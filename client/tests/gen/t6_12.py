from mesh6 import *
SH=doc6.rows_from(6,'### 12.1')
setlayer('SHULKER',SH,64,64); setlayer('SHULKER_BOX',[r for r in SH if r.split()[1] in ('lid','base')],64,64)
t=mk(6,12,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 12 (Shulker): 12.1 the SHULKER mesh and the SHULKER_BOX layer (lid and base only), 12.2 setupAnim (lid height and turn from the peek amount; example 15.13, head look),",
 "12.3 the render offset slide over six ticks, the peek amount data, the attach face rotation, body rotation plus 180, the sixteen dye textures and the cull box."],ck=True)
t.LP='EF6-LAYER'
mesh_checks(t,['SHULKER','SHULKER_BOX'],'12.1')
PI=3.1415927
def shulker(st):
    xr,yh,yb,p,age=st
    P=base_parts('SHULKER')
    f2=(0.5+p)*PI; f3=-1+math.sin(f2); f4=0
    if f2>PI: f4=math.sin(age*0.1)*0.7
    l=P['lid']; l[0]=0; l[1]=16+math.sin(f2)*8+f4; l[2]=0
    l[4]=(f3*f3*f3*f3)*PI*0.125 if p>0.3 else 0
    P['head'][3]=xr*0.017453292; P['head'][4]=((yh-180)-yb)*0.017453292
    return P
for st in ((10,200,170,0,0),(0,180,180,0.3,4),(-20,100,250,0.5,7),(15,90,90,1.0,0),(5,170,120,0.8,12.5),(0,0,0,0.31,3),(30,270,45,0.45,20)):
    pose_check(t,'SHULKER','EF6-SHULKER-ANIM',st,shulker(st))
t.raw('MOVE "SHULKER" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,180,180,0.3,0]); t.raw('CALL "EF6-SHULKER-ANIM" USING EMM-MODEL WS-IN')
t.cur('lid','y',16+math.sin(0.8*PI)*8); t.cur('lid','yrot',0)
t.raw('MOVE "SHULKER" TO WS-LAYER','CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,180,180,1.0,0]); t.raw('CALL "EF6-SHULKER-ANIM" USING EMM-MODEL WS-IN')
t.cur('lid','y',8); t.cur('lid','yrot',2*PI*1.0000)
for has,ti,p,sc,d in ((1,6,0,1,(2,0,-3)),(1,3,0.5,1,(1,1,1)),(1,1,0.25,2,(-4,2,0)),(1,0,0,1,(5,5,5)),(0,4,0,1,(1,1,1)),(1,-1,0,1,(1,1,1))):
    if not has or ti<=0: o=[0,0,0]
    else:
        e=((ti-p)/6)**2*sc; o=[-(e*d[0]),-(e*d[1]),-(e*d[2])]
    t.call('EF6-SHULKER-OFFSET',[has,ti,p,sc]+list(d),o,'12.3 render offset has old position %d interpolation %d partial %s scale %s delta %s (x, y, z)'%(has,ti,p,sc,d))
def peek(cur,raw):
    tg=raw*0.01
    if cur>tg: return min(1,max(tg,cur-0.05))
    if cur<tg: return max(0,min(tg,cur+0.05))
    return cur
for cur,raw in ((0,100),(0.97,100),(1,100),(0.5,0),(0.02,0),(0.3,30),(0.33,30),(0.5,20),(0.52,50),(0.2,50)):
    t.call('EF6-SHULKER-PEEK',[cur,raw],[peek(cur,raw)],'12.3 peek amount current %s raw %s'%(cur,raw))
for face,e in ((0,(0,0,0)),(1,(PI,0,0)),(2,(PI/2,0,0)),(3,(PI/2,0,PI)),(4,(PI/2,0,-PI/2)),(5,(PI/2,0,PI/2))):
    t.call('EF6-SHULKER-ROT',[face],list(e)+[0,0.5,0],'12.3 attach face %d rotationXYZ (x, y, z) about (0, 0.5, 0)'%face)
t.call('EF6-SHULKER-BODYROT',[30],[210],'12.3 setupRotations adds 180 to the body rotation'); t.call('EF6-SHULKER-BODYROT',[-90.5],[89.5],'12.3 body rotation -90.5')
DYE=['white','orange','magenta','light_blue','yellow','lime','pink','gray','light_gray','cyan','purple','blue','brown','green','red','black']
for i,n in enumerate(DYE): text_check(t,'EF6-SHULKER-TEXTURE',[i],'12.3 dye %d texture'%i,'textures/entity/shulker/shulker_%s.png'%n)
text_check(t,'EF6-SHULKER-TEXTURE',[16],'12.3 no colour (dye 16) default texture','textures/entity/shulker/shulker.png')
for has,rp,bp,h,w in ((1,(1,64,2),(3,60,1),1,1),(0,(0,0,0),(3,60,1),1,1),(1,(-5,70,9),(-5,70,9),1,1)):
    if not has: o=[0]+[0]*6
    else:
        a=(rp[0],rp[1]+h/2,rp[2]); b=(bp[0]+0.5,bp[1]+h/2,bp[2]+0.5)
        o=[1]+[min(a[0],b[0])-w/2,min(a[1],b[1])-h/2,min(a[2],b[2])-w/2,max(a[0],b[0])+w/2,max(a[1],b[1])+h/2,max(a[2],b[2])+w/2]
    t.call('EF6-SHULKER-CULLBOX',[has]+list(rp)+list(bp)+[h,w],o,'12.3 cull box has render position %d position %s block %s height %s width %s (candidate, min xyz, max xyz)'%(has,rp,bp,h,w))
save(t,6,12)
