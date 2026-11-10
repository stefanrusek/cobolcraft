from mesh7 import *
import doc7
def strider():
    setlayer('STRIDER',doc7.rows7('### 4.3'),64,128)
    setlayer('STRIDER_BABY',doc7.rows7('### 4.4'),32,32)
    setlayer('STRIDER_SADDLE',doc7.rows7('### 4.3'),64,128,src='STRIDER')
def hoglin_baby_rows():
    r=['P head root 0 13 -7 0.8727 0 0','C head 0 0 -5 -2.2605 -10.547 10 4 12 0 0','C head 44 29 -7 -4.0981 -8.4879 2 5 2 0 0','C head 52 29 5 -4.0981 -8.4879 2 5 2 0 0',
       'P body root 0 24 0 0 0 0','C body 0 16 -4 -14 -7 8 8 14 0.02 0','C body 24 39 0 -18 -8 0 6 11 0.02 0',
       'P right_ear head -5 -1 -1.5 0 0 -0.8727','C right_ear 32 5 -5.1 -0.5 -2 6 1 4 0 0','P left_ear head 5 -1 -1.5 0 0 0.8727','C left_ear 32 0 -0.9 -0.5 -2 6 1 4 0 1']
    for n,x,z,u,v in (('right_hind_leg',-2.5,4.5,0,47),('left_hind_leg',2.5,4.5,12,47),('right_front_leg',-2.5,-4.5,0,38),('left_front_leg',2.5,-4.5,12,38)):
        r.append('P %s root %s 18 %s 0 0 0'%(n,x,z)); r.append('C %s %d %d -1.5 0 -1.5 3 6 3 0 0'%(n,u,v))
    return r
def hoglin():
    setlayer('HOGLIN',doc7.rows7('### 5.2'),128,64)
    setlayer('HOGLIN_BABY',hoglin_baby_rows(),64,64)
    setlayer('ZOGLIN',doc7.rows7('### 5.2'),128,64,src='HOGLIN')
    setlayer('ZOGLIN_BABY',hoglin_baby_rows(),64,64,src='HOGLIN_BABY')
