from mesh7 import *
import math
def rows():
    r=['P head root 0 20 -62 0 0 0']
    for (u,v,x,y,z,w,h,d,m) in ((176,44,-6,-1,-24,12,5,16,0),(112,30,-8,-8,-10,16,16,16,0),(0,0,-5,-12,-4,2,4,6,1),(112,0,-5,-3,-22,2,2,4,1),(0,0,3,-12,-4,2,4,6,1),(112,0,3,-3,-22,2,2,4,1)):
        r.append('C head %d %d %d %d %d %d %d %d 0 %d'%(u,v,x,y,z,w,h,d,m))
    r+=['P jaw head 0 4 -8 0 0 0','C jaw 176 65 -6 0 -16 12 4 16 0 0']
    for i in range(5): r+=['P neck%d root 0 20 %d 0 0 0'%(i,-12-10*i),'C neck%d 192 104 -5 -5 -5 10 10 10 0 0'%i,'C neck%d 48 0 -1 -9 -3 2 4 6 0 0'%i]
    for i in range(12): r+=['P tail%d root 0 10 %d 0 0 0'%(i,60+10*i),'C tail%d 192 104 -5 -5 -5 10 10 10 0 0'%i,'C tail%d 48 0 -1 -9 -3 2 4 6 0 0'%i]
    r+=['P body root 0 20 8 0 0 0','C body 0 0 -12 -16 -16 24 24 64 0 0','C body 220 53 -1 -22 -10 2 6 12 0 0','C body 220 53 -1 -22 10 2 6 12 0 0','C body 220 53 -1 -22 30 2 6 12 0 0']
    for side,sx in (('left',1),('right',-1)):
        m=1 if side=='left' else 0
        if side=='left':
            r+=['P left_wing body 12 -15 -6 0 0 0','C left_wing 112 88 0 -4 -4 56 8 8 0 1','C left_wing -56 88 0 0 2 56 0 56 0 1',
                'P left_wing_tip left_wing 56 0 0 0 0 0','C left_wing_tip 112 136 0 -2 -2 56 4 4 0 1','C left_wing_tip -56 144 0 0 2 56 0 56 0 1']
        else:
            r+=['P right_wing body -12 -15 -6 0 0 0','C right_wing 112 88 -56 -4 -4 56 8 8 0 0','C right_wing -56 88 -56 0 2 56 0 56 0 0',
                'P right_wing_tip right_wing -56 0 0 0 0 0','C right_wing_tip 112 136 -56 -2 -2 56 4 4 0 0','C right_wing_tip -56 144 -56 0 2 56 0 56 0 0']
        s=side
        r+=['P %s_front_leg body %d 0 -6 1.3 0 0'%(s,12*sx),'C %s_front_leg 112 104 -4 -4 -4 8 24 8 0 0'%s,
            'P %s_front_leg_tip %s_front_leg 0 20 -1 -0.5 0 0'%(s,s),'C %s_front_leg_tip 226 138 -3 -1 -3 6 24 6 0 0'%s,
            'P %s_front_foot %s_front_leg_tip 0 23 0 0.75 0 0'%(s,s),'C %s_front_foot 144 104 -4 0 -12 8 4 16 0 0'%s,
            'P %s_hind_leg body %d -4 34 1.0 0 0'%(s,16*sx),'C %s_hind_leg 0 0 -8 -4 -8 16 32 16 0 0'%s,
            'P %s_hind_leg_tip %s_hind_leg 0 32 -4 0.5 0 0'%(s,s),'C %s_hind_leg_tip 196 0 -6 -2 0 12 32 12 0 0'%s,
            'P %s_hind_foot %s_hind_leg_tip 0 31 4 0.75 0 0'%(s,s),'C %s_hind_foot 112 0 -9 0 -20 18 6 24 0 0'%s]
    return r
def define(): setlayer('ENDER_DRAGON',rows(),256,256)
DEG=0.017453292
def wrap(x):
    r=math.fmod(x,360)
    if r>=180: r-=360
    if r<-180: r+=360
    return r
class Hist:
    def __init__(s): s.y=[0.0]*64; s.r=[0.0]*64; s.head=-1
    def record(s,y,r):
        if s.head<0: s.y=[y]*64; s.r=[r]*64
        s.head+=1
        if s.head==64: s.head=0
        s.y[s.head]=y; s.r[s.head]=r
    def get(s,n): i=(s.head-n)&63; return s.y[i],s.r[i]
    def geti(s,n,t):
        a=s.get(n+1); b=s.get(n)
        return a[0]+t*(b[0]-a[0]), a[1]+t*wrap(b[1]-a[1])
def offset(i,ay,by,landing,sitting,dist):
    if landing: return i/max(dist/4,1)
    if sitting: return i
    if i==6: return 0
    return by-ay
def anim(h,st):
    flap,pt,landing,sitting,dist=st
    P=base_parts('ENDER_DRAGON'); w=flap*2*math.pi
    P['jaw'][3]=(math.sin(w)+1)*0.2
    s=math.sin(w-1)+1; f=(s*s+2*s)*0.05
    root=[0,(f-2)*16,-48,f*2*DEG]
    x,y,z=0.0,20.0,-12.0
    A=h.geti(6,pt); d=wrap(h.geti(5,pt)[1]-h.geti(10,pt)[1]); ref=wrap(h.geti(5,pt)[1]+d/2)
    for i in range(5):
        B=h.geti(5-i,pt); wob=math.cos(i*0.45+w)*0.15
        n=P['neck%d'%i]
        n[4]=wrap(B[1]-A[1])*DEG*1.5; n[3]=wob+offset(i,A[0],B[0],landing,sitting,dist)*DEG*1.5*5; n[5]=-wrap(B[1]-ref)*DEG*1.5
        n[0],n[1],n[2]=x,y,z
        x=x-math.sin(n[4])*math.cos(n[3])*10; y=y+math.sin(n[3])*10; z=z-math.cos(n[4])*math.cos(n[3])*10
    hd=P['head']; hd[0],hd[1],hd[2]=x,y,z; C=h.geti(0,pt)
    hd[4]=wrap(C[1]-A[1])*DEG; hd[3]=wrap(offset(6,A[0],C[0],landing,sitting,dist))*DEG*1.5*5; hd[5]=-wrap(C[1]-ref)*DEG
    P['body'][5]=-d*1.5*DEG
    lw=P['left_wing']; lw[3]=0.125-math.cos(w)*0.2; lw[4]=-0.25; lw[5]=-(math.sin(w)+0.125)*0.8
    P['left_wing_tip'][5]=(math.sin(w+2)+0.5)*0.75
    rw=P['right_wing']; rw[3]=lw[3]; rw[4]=-lw[4]; rw[5]=-lw[5]; P['right_wing_tip'][5]=-P['left_wing_tip'][5]
    for sd in ('left','right'):
        P[sd+'_hind_leg'][3]=1.0+f*0.1; P[sd+'_hind_leg_tip'][3]=0.5+f*0.1; P[sd+'_hind_foot'][3]=0.75+f*0.1
        P[sd+'_front_leg'][3]=1.3+f*0.1; P[sd+'_front_leg_tip'][3]=-0.5-f*0.1; P[sd+'_front_foot'][3]=0.75+f*0.1
    acc=0.0; x,y,z=0.0,10.0,60.0; T=h.geti(11,pt)
    for i in range(12):
        B=h.geti(12+i,pt); acc+=math.sin(i*0.45+w)*0.05
        t=P['tail%d'%i]
        t[4]=(wrap(B[1]-T[1])*1.5+180)*DEG; t[3]=acc+(B[0]-T[0])*DEG*1.5*5; t[5]=wrap(B[1]-ref)*DEG*1.5
        t[0],t[1],t[2]=x,y,z
        y=y+math.sin(t[3])*10; z=z-math.cos(t[4])*math.cos(t[3])*10; x=x-math.sin(t[4])*math.cos(t[3])*10
    return P,root
