import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT=sys.argv[1] if len(sys.argv)>1 else "core/tests"
def m(x,n=1000000): return int(math.floor(x*n+0.5))
def RF(k,scale=1000000): return 'COMPUTE WS-R(%d) ROUNDED = WS-RF(%d) * %d'%(k,k,scale)
# ---------------------------------------------------------------- section 5
g=Gen('TEST-FLUIDS-29A-5','29a§5','Liquid containers','Test of 29a section 5, Liquid containers (core/src/fluids-29a-b.cob; T0487): canPlaceLiquid, placeLiquid, getFluidState and pickupBlock of waterlogged blocks, the slab variations, kelp and seagrass, tall seagrass.')
g.run('canPlaceLiquid is true exactly for the water source; a double slab refuses',["2 0","1 0","3 0","4 0","0 0","2 1"],'CALL "LC-CAN-PLACE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0 0 0")
g.run('placeLiquid waterlogs an unwaterlogged block given the water source on the server with a water tick of delay 5; the client side changes nothing; other cases are false',
 ["0 2 0 1","0 2 0 0","1 2 0 1","0 1 0 1","0 2 1 1","0 4 0 1"],'CALL "LC-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,
 "1/5/1 0/0/1 1/0/0 0/0/0 0/0/0 0/0/0")
g.run('a waterlogged block reports the water source (amount 8, not falling); otherwise empty',["1","0"],'CALL "LC-FLUID-STATE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"2/8/0 0/0/0")
g.run('pickupBlock: a waterlogged block gives a water bucket and loses the water; a block that cannot survive is destroyed with drops; an unwaterlogged block gives nothing',
 ["1 1","1 0","0 1"],'CALL "LC-PICKUP" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"0/0/1 0/1/1 0/0/0")
g.run('a placed slab is waterlogged only by a water source at the clicked position (flowing water does not); a merge into a double slab is not waterlogged',
 ["2 0","1 0","0 0","2 1","4 0"],'CALL "LC-SLAB-WATERLOGGED" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0 0")
g.run('kelp, seagrass and tall seagrass: both liquid-container methods are false, the fluid state is the water source, flow stops at them and a bucket cannot take them',
 ["2","1","0"],'CALL "LC-PLANT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,"0/0/2/0/0 0/0/2/0/0 0/0/2/0/0")
g.run('kelp and seagrass placement needs the clicked fluid in tag water and full',["2 8","1 8","2 7","4 8","0 0","1 7"],'CALL "LC-PLANT-PLACEMENT" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0 0 0 0")
g.run('seagrass: its shape update schedules a water tick when the neighbour is not air; bone meal is valid when the block above is water; the lower tall half needs support and full water, the upper half needs the lower half below; kelp may grow into water only',
 ["0 1 0 0 1 1","1 0 0 0 1 0","0 1 1 1 0 0","0 1 1 0 0 0","0 0 0 0 0 1","0 0 0 0 1 1"],
 'CALL "LC-SEAGRASS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,
 "1/1/1/1 0/0/0/0 1/1/1/1 1/1/0/1 1/0/0/0 1/0/1/0")
g.write(OUT+'/test_fluids_29a_5.cob')
# ---------------------------------------------------------------- section 6
g=Gen('TEST-FLUIDS-29A-6','29a§6','Bubble columns','Test of 29a section 6, Bubble columns (core/src/fluids-29a-b.cob; T0489): the scheduling of the column check, the column state, the surface test and the velocity changes with their caps, skips and particle rounds.')
g.run('a full water source schedules a block tick after 20 ticks when magma block or soul sand is below; flowing water, a partial level or another block below schedule nothing',
 ["2 8 1","2 8 2","2 8 0","1 8 1","2 7 2","4 8 1"],'CALL "BB-SCHEDULE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"20 20 0 0 0 0")
g.run('column state: soul sand pushes up, magma block drags, a column below copies its state, anything else is plain water',
 ["1","2","3","4","0"],'CALL "BB-COLUMN" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/0 1/1 1/0 1/1 0/0")
g.run('an entity is at the surface when the cell above has an empty collision shape and no fluid',["1 0","1 1","0 0","0 1"],'CALL "BB-SURFACE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
def vel(where,drag,kind,flying,owns,server,vy):
    reset=1 if where==2 else 0; rounds=2 if (where==1 and server==1) else 0
    if kind==1 and flying: return vy,0,0
    out=vy
    if owns:
        if where==1:
            d=-0.03 if drag else 0.1
            out=vy+d if kind==2 else (max(-0.9,vy+d) if drag else min(1.8,vy+d))
        else:
            d=-0.03 if drag else 0.06
            out=vy+d if kind==2 else (max(-0.3,vy+d) if drag else min(0.7,vy+d))
    return out,reset,rounds
cases=[(1,1,0,0,1,1,-0.5),(1,1,0,0,1,1,-0.89),(1,0,0,0,1,1,0.0),(1,0,0,0,1,1,1.75),(2,1,0,0,1,0,-0.28),(2,1,0,0,1,0,0.0),(2,0,0,0,1,0,0.0),(2,0,0,0,1,0,0.68),
 (1,1,1,1,1,1,-0.5),(2,0,1,1,1,0,0.2),(1,0,1,0,1,1,0.3),(1,1,2,0,1,1,-1.5),(1,0,2,0,1,1,1.9),(2,1,2,0,1,0,-1.0),(2,0,2,0,1,0,0.9),(2,0,0,0,0,0,0.2),(1,1,0,0,0,1,0.3)]
ins=["%d %d %d %d %d %d %s"%c for c in cases]
exp=" ".join("%d/%d/%d"%(m(vel(*c)[0]),vel(*c)[1],vel(*c)[2]) for c in cases)
g.run('velocity: above the column drag floors at -0.9 and push caps at 1.8, inside the column the floor is -0.3 and the cap 0.7; projectiles have no cap; a flying player is skipped entirely; only the owner of the movement changes velocity; the inside reset of the fall distance is not gated by that; particles are two rounds above the column on the server',
 ins,'CALL "BB-VELOCITY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-FX(7) WS-RF(1) WS-R(2) WS-R(3)\n'+RF(1),3,exp)
g.write(OUT+'/test_fluids_29a_6.cob')
# ---------------------------------------------------------------- section 7
g=Gen('TEST-FLUIDS-29A-7','29a§7','Buckets','Test of 29a section 7, Buckets (core/src/fluids-29a-b.cob; T0491): the fluid context of the ray, BucketItem.use, emptyContents with its evaporation, the result and sounds, pickup, powder snow and the dispenser.')
g.run('an empty bucket rays at fluid sources only (SOURCE_ONLY); a filled bucket and a mob bucket ignore fluids',["0 0","1 0","2 0","0 1","1 1"],'CALL "FB-CONTEXT" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0 0")
g.run('use: a miss or a non-block hit passes, a refused interaction or item use fails, otherwise go on; the target is the hit block for a liquid container and water, else the position beside the face',
 ["0 1 1 0","2 1 1 0","1 0 1 0","1 1 0 0","1 1 1 0","1 1 1 1"],'CALL "FB-USE-GATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,"1/0 1/0 1/1 1/1 1/2 0/2")
def canplace(content,air,rep,cont,acc,shift,hit):
    if content==0: return 0
    contain = rep or (cont and acc)
    if air: return 1
    if contain and (not shift or not hit): return 1
    return 2 if hit else 0
cp=[(2,1,0,0,0,0,1),(2,0,1,0,0,0,1),(2,0,1,0,0,1,1),(2,0,1,0,0,1,0),(2,0,0,0,0,0,1),(2,0,0,0,0,0,0),(2,0,0,1,1,0,1),(2,0,0,1,1,1,1),(2,0,0,1,0,1,0),(0,1,1,1,1,0,1),(1,0,0,1,0,0,1)]
g.run('emptyContents 1 to 3: air always accepts; a replaceable block or a container that accepts the fluid accepts unless the player sneaks with a hit; a refusal with a hit retries once beside the face with no hit',
 ["%d %d %d %d %d %d %d"%c for c in cp],'CALL "FB-CAN-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1," ".join(str(canplace(*c)) for c in cp))
g.run('emptyContents 4 to 6: water in an evaporating place is spent with a sound and eight large_smoke and nothing placed; a container takes water by placeLiquid; otherwise the source block is written, after destroying a replaceable block that is not a liquid with drops',
 ["1 1 0 1 0 0","1 0 0 0 0 0","0 1 1 1 1 0","0 1 0 1 0 0","0 1 0 0 1 0","0 0 0 0 1 1","0 0 0 0 1 0","1 0 1 0 0 0"],'CALL "FB-EMPTY-STEP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,
 "1/0 3/0 2/0 3/0 3/1 3/0 3/1 3/0")
g.run('emptyContents result: true when the write changed the block or the state held a source; the sound is bucket.empty, or bucket.empty_lava for lava',["1 0 0","0 1 0","0 0 0","1 0 1","0 1 1"],'CALL "FB-EMPTY-RESULT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/1 1/1 0/0 1/2 1/2")
g.run('after use: a placed fluid leaves an empty bucket (creative keeps the stack); an empty bucket that picks up a block becomes the filled item; anything else fails',
 ["1 0 0 0 0","1 0 0 0 1","0 1 1 1 0","0 1 1 0 0","0 1 0 1 0","0 0 1 1 0"],'CALL "FB-AFTER-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,"1/1 1/0 1/2 0/0 0/0 0/0")
g.run('LiquidBlock.pickupBlock works only on the source (level 0): the block becomes air and the fluid bucket is returned; a flowing block gives the empty stack',["1 0","2 0","1 3","2 15"],'CALL "FB-LIQUID-PICKUP" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"1/1 2/1 0/0 0/0")
g.run('a powder snow bucket is placed on a server only into an empty block inside the world border; the result is true on either side',["1 1 1","1 1 0","0 1 1","1 0 1"],'CALL "FB-SOLID" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/1 1/0 0/0 0/0")
g.run('dispenser: a filled bucket that empties becomes an empty bucket, otherwise it is dispensed as an item; an empty bucket in front of a pickup that returns a filled item is replaced by it',["1 1 0 0","1 0 0 0","2 0 1 1","2 0 1 0","2 0 0 1"],'CALL "FB-DISPENSE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"1 0 2 0 0")
g.write(OUT+'/test_fluids_29a_7.cob')
# ---------------------------------------------------------------- section 8
g=Gen('TEST-FLUIDS-29A-8','29a§8','Entity fluid interaction','Test of 29a section 8, Entity fluid interaction (core/src/fluids-29a-b.cob; T0493): the per-entity trackers, the cell loop, flags, the current, who is pushed, swimming, the queries and the splash.')
g.run('the fluid box is the bounding box deflated by 0.001; the cells run from floor(min) to ceil(max) - 1',["0.001 0","1.0 1","-0.5 0"],'CALL "EF-DEFLATE" USING WS-FX(1) WS-I(2) WS-RF(1)\n'+RF(1),1,"%d %d %d"%(m(0.002),m(0.999),m(-0.499)))
g.run('cell range: floor of the minimum to ceil of the maximum minus one',["0.0 1.0","0.2 0.8","-0.5 1.5","3.0 4.2","0.999 1.001"],'CALL "EF-RANGE" USING WS-FX(1) WS-FX(2) WS-R(1) WS-R(2)',2,"0/0 0/0 -1/1 3/4 0/1")
g.run('an idle tracker (height 0 and not eyes inside) is removed; any other is reset and stays',["0 0","0.5 0","0 1","0.1 1"],'CALL "EF-IDLE" USING WS-FX(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
cell=[(64,0.5,0.5,64.2,64.0,64.62,1,0.0,0),(64,0.5,0.5,64.6,64.0,64.62,1,0.0,0),(64,0.9,0.9,64.0,63.5,64.62,0,0.2,0),(64,0.9,0.9,64.0,63.5,65.0,1,0.0,0),(63,0.9,0.9,64.0,63.5,63.95,1,0.1,0),(64,0.5,0.5,64.5,64.0,64.62,1,0.0,0),(64,0.9,0.9,64.0,63.5,64.4,1,0.0,0)]
def cellx(y,h,cam,bmin,emin,eye,col,tr,eyes):
    top=y+h
    if top<bmin: return tr,eyes,0
    if col and eye>=y and eye<=y+cam: eyes=1
    tr=max(tr,top-emin)
    return tr,eyes,1
g.run('one cell: skipped when its fluid top is below the box; eyes inside when the cell is in the entity column and the eye is between y and y plus the camera height; the tracker keeps the greater of its height and top minus the entity minimum y',
 ["%d %s %s %s %s %s %d %s %d"%c for c in cell],'MOVE WS-FX(8) TO WS-RF(1)\nCALL "EF-CELL" USING WS-I(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-I(7) WS-RF(1) WS-I(9) WS-R(2)\n'+RF(1)+'\nMOVE WS-I(9) TO WS-R(3)',3,
 " ".join("%d/%d/%d"%(m(cellx(*c)[0]),cellx(*c)[2],cellx(*c)[1]) for c in cell))
def acc(tr,a,fx,fy,fz,sx,sy,sz,n):
    a=max(tr,a)
    if a<0.4: fx,fy,fz=fx*a,fy*a,fz*a
    return a,sx+fx,sy+fy,sz+fz,n+1
ac=[(0.2,0.0,1,0,0,0,0,0,0),(0.5,0.0,1,-6,0,0,0,0,0),(0.3,0.35,0,0,2,1,1,1,1),(0.1,0.6,0.5,0,0.5,0.25,0,0.25,2)]
call_acc='MOVE WS-FX(2) TO WS-RF(1)\nMOVE WS-FX(3) TO WS-RF(5)\nMOVE WS-FX(4) TO WS-RF(6)\nMOVE WS-FX(5) TO WS-RF(7)\nMOVE WS-FX(6) TO WS-RF(2)\nMOVE WS-FX(7) TO WS-RF(3)\nMOVE WS-FX(8) TO WS-RF(4)\nMOVE WS-I(9) TO WS-R(5)\nCALL "EF-ACCUM" USING WS-FX(1) WS-RF(1) WS-RF(5) WS-RF(6) WS-RF(7) WS-RF(2) WS-RF(3) WS-RF(4) WS-R(5)\n'+RF(1)+'\n'+RF(2)+'\n'+RF(3)+'\n'+RF(4)
g.run('accumulator: its height is the larger one; below 0.4 the flow is scaled by it; the flow is added and counted',
 ["%s %s %s %s %s %s %s %s %d"%c for c in ac],call_acc,5," ".join("/".join(str(m(v)) for v in acc(*c)[:4])+"/%d"%acc(*c)[4] for c in ac))
def cur(sx,sy,sz,n,pl,st,vx,vz):
    l2=sx*sx+sy*sy+sz*sz
    if n==0 or l2<9.999999747378752E-6: return 0,0,0
    if pl: k=1.0/n
    else: k=1.0/math.sqrt(l2)
    px,py,pz=sx*k*st,sy*k*st,sz*k*st
    if abs(vx)<0.003 and abs(vz)<0.003 and math.sqrt(px*px+py*py+pz*pz)<0.0045000000000000005:
        k=0.0045000000000000005/math.sqrt(px*px+py*py+pz*pz); px,py,pz=px*k,py*k,pz*k
    return px,py,pz
cc=[(0,0,0,0,0,0.014,0,0),(0.001,0,0,1,0,0.014,0,0),(3,0,4,2,0,0.014,0.1,0.1),(3,0,4,2,1,0.014,0.1,0.1),(1,-6,0,1,0,0.0023333333333333335,0.1,0.0),(1,0,0,1,0,0.014,0.0,0.0),(1,0,0,1,0,0.014,0.5,0.0),(2,0,0,3,1,0.007,0.001,0.001),(1,0,0,1,0,0.0023333333333333335,0.0,0.0),(0,2,0,1,0,0.002,0.001,0.001)]
g.run('applyCurrentTo: nothing for no flow; a player takes the average, others the normalised flow, times the strength; a slow entity is given at least 0.0045',
 ["%s %s %s %d %d %s %s %s"%c for c in cc],'CALL "EF-CURRENT" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-I(4) WS-I(5) WS-FX(6) WS-FX(7) WS-FX(8) WS-RF(1) WS-RF(2) WS-RF(3)\n'+RF(1,100000000)+'\n'+RF(2,100000000)+'\n'+RF(3,100000000),3,
 " ".join("/".join(str(m(v,100000000)) for v in cur(*c)) for c in cc))
g.run('push strength: 0.014 in water; in lava 0.007 with fast_lava, else 0.007 / 3',["1 0","1 1","2 1","2 0"],'CALL "EF-STRENGTH" USING WS-I(1) WS-I(2) WS-RF(1)\n'+RF(1,100000000),1," ".join(str(m(v,100000000)) for v in (0.014,0.014,0.007,0.007/3)))
g.run('who is pushed by fluid: all but the turtle, water animals, frog, axolotl, nautilus, a swimming drowned, an arrow stuck in the ground and a flying player',["0","1","2","3","4","5","6","7","8","9","10"],'CALL "EF-PUSHED" USING WS-I(1) WS-R(1)',1,"1 0 0 0 0 0 0 0 1 0 1")
g.run('flags: in water resets the fall distance; entering water (not touching before, not the first tick) splashes; the stored flag follows the result',["1 0 0","1 1 0","1 0 1","0 1 0","0 0 0"],'CALL "EF-FLAGS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 1/0/1 1/0/1 0/0/0 0/0/0")
def swim(sw,sp,iw,pa,un,ab):
    if sw: return int(sp and iw and not pa)
    return int(sp and un and not pa and ab)
sc=[(1,1,1,0,0,0),(1,1,0,0,0,0),(1,0,1,0,0,0),(1,1,1,1,0,0),(0,1,1,0,1,1),(0,1,1,0,0,1),(0,1,1,0,1,0),(0,0,1,0,1,1),(0,1,1,1,1,1)]
g.run('swimming: a swimmer stays while sprinting in water and not a passenger; others start when sprinting under water with water at the block position and not a passenger',
 ["%d %d %d %d %d %d"%c for c in sc],'CALL "EF-SWIM" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1," ".join(str(swim(*c)) for c in sc))
def st(wh,we,lh,was_eye,was,first):
    in_w=was; in_l=int((not first) and lh>0); liq=int(in_w or in_l); under=int(was_eye and in_w); shallow=int(in_w and not under)
    return in_w,in_l,liq,under,shallow,we
sq=[(0.5,0,0.0,0,1,0),(0.5,1,0.0,1,1,0),(0.0,0,0.3,0,0,0),(0.0,0,0.3,0,0,1),(0.7,1,0.0,0,0,0)]
g.run('queries: in water is the stored flag; in lava needs a lava height above 0 and not the first tick; under water is wasEyeInWater and in water; shallow is in water and not under water',
 ["%s %d %s %d %d %d"%c for c in sq],'CALL "EF-STATE" USING WS-FX(1) WS-I(2) WS-FX(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6," ".join("/".join(str(int(v)) for v in st(*c)) for c in sq))
g.run('the fluid jump threshold is 0.0 below an eye height of 0.4, else 0.4',["0.39","0.4","1.62","0.0"],'CALL "EF-JUMP-THRESHOLD" USING WS-FX(1) WS-RF(1)\n'+RF(1),1,"0 400000 400000 0")
def splash(vx,vy,vz,w,r1,r2,own):
    k=0.2 if own else 0.9
    v=min(1.0,math.sqrt(0.2*vx*vx+vy*vy+0.2*vz*vz)*k)
    return v,1+(r1-r2)*0.4,(1 if v<0.25 else 2),int(1+w*20)
sp=[(0,0,0,0.6,0.5,0.5,1),(0,-0.5,0,0.6,0.75,0.25,1),(0.5,-2,0.5,0.6,0.25,0.5,1),(0,-1,0,0.6,0.5,0.5,0),(0,-3,0,0.98,0.0,1.0,0),(0,-0.5,0,0.25,0.5,0.5,1)]
g.run('splash: volume is min(1, sqrt(0.2 vx^2 + vy^2 + 0.2 vz^2) * k) with k 0.2 for the own controller and 0.9 otherwise; below 0.25 the swim splash, else the high speed splash; pitch 1 + (r1 - r2) * 0.4; 1 + width * 20 particles of each kind',
 ["%s %s %s %s %s %s %d"%c for c in sp],'CALL "EF-SPLASH" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-I(7) WS-RF(1) WS-RF(2) WS-R(3) WS-R(4)\n'+RF(1)+'\n'+RF(2),4,
 " ".join("%d/%d/%d/%d"%(m(splash(*c)[0]),m(splash(*c)[1]),splash(*c)[2],splash(*c)[3]) for c in sp))
g.write(OUT+'/test_fluids_29a_8.cob')
# ---------------------------------------------------------------- section 9
g=Gen('TEST-FLUIDS-29A-9','29a§9','Tags, attributes and game rules the rules read','Test of 29a section 9, Tags, attributes and game rules the rules read (core/src/fluids-29a-b.cob; T0495): the fluid tags, the rule and attribute defaults, the water evaporation attribute, the bubble column block tags and the union block tags.')
tags={1:(1,2),2:(3,4),3:(2,),4:(1,2),5:(2,),6:(2,),7:(1,2)}
ins=[];exp=[]
for t in range(1,8):
    for k in range(0,5):
        ins.append("%d %d"%(t,k)); exp.append(str(int(k in tags[t])))
g.run('fluid tags: water and lava hold their two fluids, entity_floatable and supports_sugar_cane_adjacently include tag water, bubble_column_can_occupy, supports_lily_pad and supports_frogspawn hold the water source only',ins,'CALL "FT-FLUID-TAG" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(exp))
g.run('defaults: water_source_conversion true, lava_source_conversion false, fire_spread_radius_around_player 128, fast_lava false, water_evaporates false',["1","2","3","4","5"],'CALL "FT-RULE" USING WS-I(1) WS-R(1)',1,"1 0 128 0 0")
g.case('the attribute water_evaporates is true in the nether dimension type only',[("0",'MOVE "minecraft:the_nether" TO WS-T1\nCALL "FT-WATER-EVAPORATES" USING WS-T1 WS-R(1)',1),("0",'MOVE "minecraft:overworld" TO WS-T1\nCALL "FT-WATER-EVAPORATES" USING WS-T1 WS-R(1)',1),("0",'MOVE "cobolcraft:main" TO WS-T1\nCALL "FT-WATER-EVAPORATES" USING WS-T1 WS-R(1)',1)],"1 0 0 ")
g.case('the bubble column block tags: magma_block drags down, soul_sand pushes up',[("0",'MOVE "minecraft:magma_block" TO WS-T1\nCALL "FT-BUBBLE-DRIVER" USING WS-T1 WS-R(1)',1),("0",'MOVE "minecraft:soul_sand" TO WS-T1\nCALL "FT-BUBBLE-DRIVER" USING WS-T1 WS-R(1)',1),("0",'MOVE "minecraft:sand" TO WS-T1\nCALL "FT-BUBBLE-DRIVER" USING WS-T1 WS-R(1)',1)],"1 2 0 ")
g.run('blocks_fluid_flow is blocks_motion or all_signs; blocks_lava_fire_spread is blocks_motion',["1 1 0","1 0 1","1 0 0","2 1 0","2 0 1"],'CALL "FT-BLOCK-TAG-UNION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 1 0 1 0")
g.write(OUT+'/test_fluids_29a_9.cob')
# ---------------------------------------------------------------- section 10
g=Gen('TEST-FLUIDS-29A-10','29a§10','Client fluid mesh','Test of 29a section 10, Client fluid mesh (core/src/fluids-29a-b.cob; T0497): face selection, occlusion, neighbour and corner heights, the top face texture, geometry, backward face, shading and light. Heights are compared to four decimals.')
def avg(c,a,b,d):
    if a>=1 or b>=1: return 1.0
    s=w=0.0
    lst=[]
    if a>0 or b>0:
        if d>=1: return 1.0
        lst.append(d)
    lst+= [c,b,a]
    for v in lst:
        if v>=0.8: s+=v*10; w+=10
        elif v>=0: s+=v; w+=1
    return s/w
g.run('faces: the top is a candidate when the fluid above is not the same fluid; a side or bottom face is drawn when the neighbour is not the same fluid and the block does not occlude itself; a neighbouring block that occludes drops it',
 ["1 0 0 0","1 1 0 0","0 0 0 0","0 0 1 0","0 1 0 0","1 0 0 1","0 0 0 1"],'CALL "FM-DRAW-FACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"1 0 1 0 0 0 0")
g.run('occlusion by a neighbour block: an empty shape never; a full face always except the top face of a lower fluid; another shape by blockOccludes',
 ["0 0 1.0 0","0 1 1.0 0","1 1 1.0 0","1 1 0.8 0","0 1 0.8 0","0 2 1.0 1","0 2 1.0 0"],'CALL "FM-OCCLUDES" USING WS-I(1) WS-I(2) WS-FX(3) WS-I(4) WS-R(1)',1,"0 1 1 0 1 1 0")
g.run('neighbour heights: the fluid\'s own render height, 0.0 for a non-solid block without fluid, -1.0 (ignored) for a solid block',["1 0.5 0","1 1.0 1","0 0.5 0","0 0.5 1"],'CALL "FM-NEIGHBOUR-HEIGHT" USING WS-I(1) WS-FX(2) WS-I(3) WS-RF(1)\n'+RF(1),1,"500000 1000000 0 -1000000")
av=[(0.8888889,0.8888889,0.5,0.0),(0.5,0.0,0.0,0.9),(0.5,0.3,0.0,1.0),(0.5,1.0,0.0,0.0),(0.5,-1.0,-1.0,0.0),(0.2,0.1,0.7,0.4),(0.75,0.0,0.9,-1.0),(0.5,0.0,0.0,0.9)]
g.run('average(center, a, b, diagonal): 1 when a or b is 1 or more; the diagonal counts only when a or b is above 0 and a diagonal of 1 returns 1; heights of 0.8 and more weigh 10, lower non-negative ones 1, negative ones nothing',
 ["%s %s %s %s"%c for c in av],'CALL "FM-AVERAGE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-RF(1)\n'+RF(1,10000),1," ".join(str(m(avg(*c),10000)) for c in av))
def corners(h,n,s,e,w,dne,dnw,dse,dsw):
    if h>=1: return (1.0,)*4
    return avg(h,n,e,dne),avg(h,n,w,dnw),avg(h,s,e,dse),avg(h,s,w,dsw)
cs=[(1.0,0,0,0,0,0,0,0,0),(0.8888889,0.0,0.0,0.0,0.0,0,0,0,0),(0.5,0.5,0.3,0.0,0.2,0.1,0.0,0.4,0.0),(0.8888889,0.7777778,0.0,0.6666667,0.0,0.5,0.0,0.0,0.0),(0.5,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3)]
g.run('corner heights: a centre of 1 or more makes all four corners 1; NE averages centre, north, east and the NE diagonal, NW north, west, SE south, east, SW south, west',
 [" ".join("%s"%v for v in c) for c in cs],'CALL "FM-CORNERS" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-FX(7) WS-FX(8) WS-FX(9) WS-RF(1) WS-RF(2) WS-RF(3) WS-RF(4)\n'+RF(1,10000)+'\n'+RF(2,10000)+'\n'+RF(3,10000)+'\n'+RF(4,10000),4,
 " ".join("/".join(str(m(v,10000)) for v in corners(*c)) for c in cs))
def uv(x,z):
    if x==0 and z==0: return None
    a=math.atan2(z,x)-math.pi/2; s=math.sin(a)*0.25; c=math.cos(a)*0.25
    return (0.5-c-s,0.5-c+s,0.5-c+s,0.5+c+s,0.5+c+s,0.5+c-s,0.5+c-s,0.5-c-s)
fl=[(1,0),(0,1),(-1,0),(0,-1),(1,1),(-2,1),(0.5,-0.25),(-1,-1)]
def uvexp(x,z):
    u=uv(x,z)
    return "1/0/0/0/0/0/0/0/0" if u is None else "0/"+"/".join(str(m(v,10000)) for v in u)
g.extra=" 01 WS-UV.\n    05 WS-UVF FLOAT-LONG OCCURS 8 TIMES.\n 01 WS-NINE.\n    05 WS-NINEF BINARY-LONG OCCURS 9 TIMES.\n"
callu='CALL "FM-TOP-UV" USING WS-FX(1) WS-FX(2) WS-R(1) WS-UV\n'+"".join('COMPUTE WS-R(%d) ROUNDED = WS-UVF(%d) * 10000\n'%(k+1,k) for k in range(1,9))
g.run('top face texture: still sprite for a zero flow, else angle = atan2(z, x) - pi / 2 and the four (u, v) fractions of the flowing sprite',
 ["%s %s"%c for c in fl]+["0 0"],callu,9," ".join(uvexp(*c) for c in fl)+" 1/0/0/0/0/0/0/0/0")
g.run('geometry: top vertices sit 0.001 below the corner height; a side face starts at 0.001 when the bottom face is drawn, else 0; its v runs from (1 - corner height) * 0.5 to 0.5',
 ["1 0.8888889","0 0.5","1 1.0"],'CALL "FM-GEOMETRY" USING WS-I(1) WS-FX(2) WS-RF(1) WS-RF(2) WS-RF(3) WS-RF(4)\n'+RF(1)+'\n'+RF(2)+'\n'+RF(3)+'\n'+RF(4),4,
 " ".join("/".join(str(m(v)) for v in (h-0.001,0.001 if b else 0,(1-h)*0.5,0.5)) for b,h in ((1,0.8888889),(0,0.5),(1,1.0))))
g.case('backward up face: drawn when any of the nine cells around the cell above is neither the same fluid nor a solid render block',[("0",'INITIALIZE WS-NINE\nCALL "FM-BACKWARD-UP" USING WS-NINE WS-R(1)',1),("0",'INITIALIZE WS-NINE\nMOVE 1 TO WS-NINEF(5)\nCALL "FM-BACKWARD-UP" USING WS-NINE WS-R(1)',1),("0",'INITIALIZE WS-NINE\nMOVE 1 TO WS-NINEF(9)\nCALL "FM-BACKWARD-UP" USING WS-NINE WS-R(1)',1)],"0 1 1 ")
sh=[(0,0.9,0.5,0.8,0.6,0),(1,0.9,0.5,0.8,0.6,0),(2,0.9,0.5,0.8,0.6,0),(3,0.9,0.5,0.8,0.6,1),(2,1.0,0.5,0.8,0.6,1)]
def shade(f,u,d,n,w):
    return {0:u,1:d,2:n*u,3:w*u}[f]
g.run('brightness: top up, bottom down, a side north or west times up; a side with an overlay sprite is single sided, else both sides',
 ["%d %s %s %s %s %d"%c for c in sh],'CALL "FM-SHADE" USING WS-I(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-FX(5) WS-I(6) WS-RF(1) WS-R(2)\n'+RF(1),2," ".join("%d/%d"%(m(shade(c[0],*c[1:5])),0 if c[5] else 1) for c in sh))
g.run('light coordinates: the maximum per channel of the cell and the cell above',["3 10 12 4","15 0 0 15","7 7 7 7"],'CALL "FM-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,"12/10 15/15 7/7")
g.write(OUT+'/test_fluids_29a_10.cob')
