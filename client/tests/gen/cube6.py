from mesh6 import *
def lit_(x):
    return lit(float(x)) if not float(x).is_integer() else str(int(x))
def slime_rows(): return doc6.rows_from(6,'### 7.1')
OUTER=['P cube root 0 0 0 0 0 0','C cube 0 0 -4 16 -4 8 8 8 0 0']
def magma_rows():
    r=[]
    for i in range(8):
        u,v=(0,0) if i==0 else (0,9*i) if i<4 else (32,9*i-36)
        r.append('P cube%d root 0 0 0 0 0 0'%i); r.append('C cube%d %d %d -4 %d -4 8 1 8 0 0'%(i,u,v,16+i))
    r.append('P inside_cube root 0 0 0 0 0 0'); r.append('C inside_cube 24 40 -2 18 -2 4 4 4 0 0')
    return r
def sulfur_rows(o,s,u,v): return ['P cube root 0 0 0 0 0 0','C cube %d %d %d %d %d %d %d %d 0 0'%(u,v,o,o,o,s,s,s)]
def define():
    setlayer('SLIME',slime_rows(),64,32); setlayer('SLIME_OUTER',OUTER,64,32); setlayer('MAGMA_CUBE',magma_rows(),64,64)
    setlayer('SULFUR_CUBE',sulfur_rows(-9,18,0,0),128,128); setlayer('SULFUR_CUBE_INNER',sulfur_rows(-8,16,0,36),128,128)
    setlayer('SULFUR_CUBE_SMALL',sulfur_rows(-5,10,0,0),64,64); setlayer('SULFUR_CUBE_SMALL_INNER',sulfur_rows(-4,8,0,20),64,64)
IDS=['SLIME','SLIME_OUTER','MAGMA_CUBE','SULFUR_CUBE','SULFUR_CUBE_INNER','SULFUR_CUBE_SMALL','SULFUR_CUBE_SMALL_INNER']
