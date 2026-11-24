from mesh6 import *
def lit_(x):
    return lit(float(x)) if not float(x).is_integer() else str(int(x))
def worm(bodies,layers=()):
    """bodies: (w,h,d,u,v); z_0 = -3.5, z_(i+1) = z_i + (d_i + d_(i+1)) x 0.5; layers: (name,u,v,ox,oy,oz,w,h,d,pivot y,segment index of the pivot z)"""
    z=[-3.5]
    for i in range(1,len(bodies)): z.append(z[-1]+(bodies[i-1][2]+bodies[i][2])*0.5)
    r=[]
    for i,(w,h,d,u,v) in enumerate(bodies):
        r.append('P segment%d root 0 %s %s 0 0 0'%(i,lit_(24-h),lit_(z[i])))
        r.append('C segment%d %d %d %s 0 %s %d %d %d 0 0'%(i,u,v,lit_(-w*0.5),lit_(-d*0.5),w,h,d))
    for (n,u,v,ox,oy,oz,w,h,d,py,zi) in layers:
        r.append('P %s root 0 %s %s 0 0 0'%(n,lit_(py),lit_(z[zi])))
        r.append('C %s %d %d %s %s %s %d %d %d 0 0'%(n,u,v,lit_(ox),lit_(oy),lit_(oz),w,h,d))
    return r,z
EMITE=[(4,3,2,0,0),(6,4,5,0,5),(3,3,1,0,14),(1,2,1,0,18)]
SILVER=[(3,2,2,0,0),(4,3,2,0,4),(6,4,3,0,9),(3,3,3,0,16),(2,2,3,0,22),(2,1,2,11,0),(1,1,2,13,4)]
SLAYERS=[('layer0',20,0,-5,0,-1.5,10,8,3,16,2),('layer1',20,11,-3,0,-1.5,6,4,3,20,4),('layer2',20,18,-3,0,-1.5,6,5,2,19,1)]
