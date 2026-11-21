from mesh5 import *
t=mk(5,7,["Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 7 (Parrot): 7.1 the mesh, 7.2 the pose choice and setupAnim for each of the five poses (prepare, head look, party, standing legs,",
 "the common block), 7.3 the texture table (grey spelling), flapAngle, the flap counters and the shoulder layer translation. Mesh rows are the table of the document; formula values were worked by an independent script."],ck=True)
mesh_checks(t,['PARROT'],'7.1')
PI=math.pi
def parrot(st):
    xr,yr,p,s,A,pose,F=st
    P={}
    for r in expected('PARROT')[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]
    H,B,T,LW,RW,LL,RL=P['head'],P['body'],P['tail'],P['left_wing'],P['right_wing'],P['left_leg'],P['right_leg']
    if pose==0: LL[3]+=0.6981317; RL[3]+=0.6981317
    elif pose==2:
        for l in (H,T,B,LW,RW,LL,RL): l[1]+=1.9
        T[3]+=0.5235988; LW[5]=-0.0873; RW[5]=0.0873; LL[3]+=1.5707964; RL[3]+=1.5707964
    elif pose==3: LL[5]=-0.34906584; RL[5]=0.34906584
    H[3]=xr*D; H[4]=yr*D
    def common():
        v=F*0.3
        H[1]+=v; T[3]+=math.cos(0.6662*p)*0.3*s; T[1]+=v; B[1]+=v; LW[5]=-0.0873-F; LW[1]+=v; RW[5]=0.0873+F; RW[1]+=v; LL[1]+=v; RL[1]+=v
    if pose==2: pass
    elif pose==3:
        cs=math.cos(A); sn=math.sin(A)
        H[0]+=cs; H[1]+=sn; H[3]=0; H[4]=0; H[5]=math.sin(A)*0.4
        B[0]+=cs; B[1]+=sn; T[0]+=cs; T[1]+=sn
        LW[5]=-0.0873-F; LW[0]+=cs; LW[1]+=sn; RW[5]=0.0873+F; RW[0]+=cs; RW[1]+=sn
    elif pose==1:
        LL[3]+=math.cos(0.6662*p)*1.4*s; RL[3]+=math.cos(0.6662*p+PI)*1.4*s; common()
    else: common()
    return P
STS=[(10,-20,1.2,0.5,12.5,pose,F) for pose,F in ((0,0.4),(1,0.6),(2,0.3),(3,0.7),(4,0))]+[(0,0,0,0,0,p_,0) for p_ in range(5)]+[(-15,40,3.5,0.9,33,p_,1.2) for p_ in range(5)]
for st in STS:
    t.raw('MOVE "PARROT" TO WS-LAYER','CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "EF5-PARROT-ANIM" USING EMM-MODEL WS-IN')
    P=parrot(st)
    for part in sorted(P):
        for kx,f in enumerate(('x','y','z','xrot','yrot','zrot')): t.cur(part,f,P[part][kx])
for party,sit,fly in ((1,1,1),(1,0,0),(0,1,1),(0,1,0),(0,0,1),(0,0,0)):
    pose=3 if party else 2 if sit else 0 if fly else 1
    t.call('EF5-PARROT-POSE',[party,sit,fly],[pose],'7.2 party %d sitting %d flying %d pose (0 flying 1 standing 2 sitting 3 party)'%(party,sit,fly))
TX=['parrot_red_blue','parrot_blue','parrot_green','parrot_yellow_blue','parrot_grey']
for v in range(5):
    t.raw('MOVE %d TO WS-IV(1)'%v,'CALL "EF5-PARROT-TEXTURE" USING WS-IN WS-X120'); t.text('7.3 variant %d texture'%v,'textures/entity/parrot/%s.png'%TX[v],'WS-X120')
for tt,of,fl,os,sp in ((0.5,1,3,0.2,0.8),(0,0.5,0.5,0,0),(1,2,4,0.3,1)):
    t.call('EF5-PARROT-FLAP',[tt,of,fl,os,sp],[(math.sin(of+tt*(fl-of))+1)*(os+tt*(sp-os))],'7.3 flapAngle partial %s flap %s to %s speed %s to %s'%(tt,of,fl,os,sp))
def fc(fs,fp,fl,ground,ride,air,dy):
    f=-1 if (ground or ride) else 4
    fs=min(1,max(0,fs+f*0.3))
    if air and fp<1: fp=1
    fp=fp*0.9
    if air and dy<0: dy=dy*0.6
    fl=fl+fp*2
    return [fs,fp,fl,dy]
for a in ((0.5,0.5,3,1,0,0,0),(0.9,0.2,1,0,0,1,-0.5),(0.1,1,2,0,0,1,0.3),(0.2,0.95,0,0,1,1,-1),(0,0,0,1,0,0,0),(0.8,0.3,5,0,0,1,-0.2)):
    t.call('EF5-PARROT-FLAPPING',list(a),fc(*a),'7.3 counters flapSpeed %s flapping %s flap %s ground %d riding %d airborne %d dy %s: flapSpeed, flapping, flap, dy'%a)
for left,crouch in ((1,0),(1,1),(0,0),(0,1)):
    t.call('EF5-PARROT-SHOULDER',[left,crouch],[0.4 if left else -0.4,-1.3 if crouch else -1.5,0],'7.3 shoulder layer left %d crouching %d translate x y z'%(left,crouch))
save(t,5,7)
