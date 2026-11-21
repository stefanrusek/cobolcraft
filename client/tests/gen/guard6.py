from mesh6 import *
import math
SP=[(1.75,0,0,0,-8,8),(0.25,0,0,0,-8,-8),(0,0,0.25,8,-8,0),(0,0,1.75,-8,-8,0),(0.5,0.25,0,-8,0,-8),(0.5,1.75,0,8,0,-8),(0.5,1.25,0,8,0,8),(0.5,0.75,0,-8,0,8),(1.25,0,0,0,8,8),(0.75,0,0,0,8,-8),(0,0,0.75,8,8,0),(0,0,1.25,-8,8,0)]
def o(i,a,e): return 1+math.cos(a*1.5+i)*0.01-e
def rows():
    r=['P head root 0 0 0 0 0 0','C head 0 0 -6 10 -8 12 12 16 0 0','C head 0 28 -8 10 -6 2 12 12 0 0','C head 0 28 6 10 -6 2 12 12 0 1','C head 16 40 -6 8 -6 12 2 12 0 0','C head 16 40 -6 22 -6 12 2 12 0 0']
    for i,(xr,yr,zr,sx,sy,sz) in enumerate(SP):
        k=o(i,0,0)
        r.append('P spike%d head %s %s %s %s %s %s'%(i,lit(sx*k),lit(16+sy*k),lit(sz*k),lit(math.pi*xr),lit(math.pi*yr),lit(math.pi*zr)))
        r.append('C spike%d 0 0 -1 -4.5 -1 2 9 2 0 0'%i)
    r+=['P eye head 0 0 -8.25 0 0 0','C eye 8 0 -1 15 0 2 2 1 0 0','P tail0 head 0 0 0 0 0 0','C tail0 40 0 -2 14 7 4 4 8 0 0','P tail1 tail0 -1.5 0.5 14 0 0 0','C tail1 0 54 0 14 0 3 3 7 0 0',
        'P tail2 tail1 0.5 0.5 6 0 0 0','C tail2 41 32 0 14 0 2 2 6 0 0','C tail2 25 19 1 10.5 3 1 9 9 0 0']
    return r
def define():
    setlayer('GUARDIAN',rows(),64,64); setlayer('ELDER_GUARDIAN',rows(),64,64,[2.35],src='GUARDIAN')
