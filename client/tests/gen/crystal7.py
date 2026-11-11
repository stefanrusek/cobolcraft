from mesh7 import *
import math
G=('-4','-4','-4','8','8','8')
def rows():
    return ['P outer_glass root 0 24 0 0 0 0','C outer_glass 0 0 -4 -4 -4 8 8 8 0 0',
            'P inner_glass outer_glass 0 0 0 0 0 0 0.875 0.875 0.875','C inner_glass 0 0 -4 -4 -4 8 8 8 0 0',
            'P cube inner_glass 0 0 0 0 0 0 0.765625 0.765625 0.765625','C cube 32 0 -4 -4 -4 8 8 8 0 0',
            'P base root 0 0 0 0 0 0','C base 0 16 -6 0 -6 12 4 12 0 0']
def define(): setlayer('END_CRYSTAL',rows(),64,32)
def mm(a,b): return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def roty(t): c,s=math.cos(t),math.sin(t); return [[c,0,s],[0,1,0],[-s,0,c]]
def axis(ax,ay,az,t):
    c,s=math.cos(t),math.sin(t); k=1-c
    return [[c+ax*ax*k,ax*ay*k-az*s,ax*az*k+ay*s],[ay*ax*k+az*s,c+ay*ay*k,ay*az*k-ax*s],[az*ax*k-ay*s,az*ay*k+ax*s,c+az*az*k]]
def euler(M):
    return (math.atan2(M[2][1],M[2][2]),-math.asin(max(-1,min(1,M[2][0]))),math.atan2(M[1][0],M[0][0]))
S45=0.70710677; ANG=1.0471976
def gety(a):
    f=math.sin(0.2*a)/2+0.5; f=(f*f+f)*0.4; return f-1.4
