from mesh7 import *
import math
Q=1.5707964
def blaze_rows():
    r=['P head root 0 0 0 0 0 0','C head 0 0 -4 -4 -4 8 8 8 0 0']
    for i in range(12):
        ring,k=(0,i) if i<4 else (1,i-4) if i<8 else (2,i-8)
        a0=(0,0.7853982,0.47123894)[ring]; R=(9,7,5)[ring]; a=a0+k*Q
        y=(-2+math.cos(2*i*0.25)) if ring==0 else (2+math.cos(2*i*0.25)) if ring==1 else (11+math.cos(1.5*i*0.5))
        r.append('P part%d root %s %s %s 0 0 0'%(i,lit(math.cos(a)*R),lit(y),lit(math.sin(a)*R)))
        r.append('C part%d 0 16 0 0 0 2 8 2 0 0'%i)
    return r
def ghast_rows(lens):
    r=['P body root 0 17.6 0 0 0 0','C body 0 0 -8 -8 -8 16 16 16 0 0']
    for i in range(9):
        x=((i%3)-((i//3)%2)*0.5+0.25-1)*5; z=((i//3)-1)*5
        r.append('P tentacle%d root %s 24.6 %s 0 0 0'%(i,lit(x),lit(z)))
        r.append('C tentacle%d 0 0 -1 0 -1 2 %d 2 0 0'%(i,lens[i]))
    return r
LENS=[8,13,9,11,11,10,12,9,12]
