import sys,struct,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
f32=lambda x: struct.unpack('f',struct.pack('f',x))[0]
def m(x,n=1000000): return int(math.floor(x*n+0.5))
# ---- section 1
g=Gen('TEST-FLUIDS-29A-1','29a§1','Fluids and fluid states','Test of 29a section 1, Fluids and fluid states (core/src/fluids-29a.cob; T0479): the five fluids, the legacy liquid block levels and ids, heights, camera height and the flow vector.')
g.run('isSame accepts water with flowing water and lava with flowing lava only',["1 2","2 1","3 4","1 3","0 0","2 2","0 1"],'CALL "FL-SAME" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 1 0 0 1 0")
g.run('block level to fluid state: index min(level, 8); 0 source, 1 to 7 flowing amount 8 - index, 8 and above falling amount 8',["1 0","1 1","1 7","1 8","1 15","2 0","2 3"],'CALL "FL-FROM-LEVEL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"2/8/0 1/7/0 1/1/0 1/8/1 1/8/1 4/8/0 3/5/0")
g.run('fluid state to legacy level: source 0, flowing (8 - amount) + 8 when falling, empty is air',["2 8 0","1 7 0","1 1 0","1 8 1","0 0 0","3 5 0","1 5 1"],'CALL "FL-LEGACY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"0 1 7 8 -1 3 11")
g.run('block state ids: water 89 + level, lava 105 + level (levels 0 to 15)',["1 0","1 8","1 15","2 0","2 15"],'CALL "FL-BLOCK-ID" USING WS-I(1) WS-I(2) WS-R(1)',1,"89 97 104 105 120")
own=lambda a: f32(f32(a)/9.0)
g.run('own height is amount / 9 in single precision (source 0.8888889, empty 0)',["8","1","0","4"],'CALL "FL-OWN-HEIGHT" USING WS-I(1) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1," ".join(str(m(own(a))) for a in (8,1,0,4)))
g.run('height is 1.0 when the block above holds the same fluid, else the own height',["8 1","8 0","4 0","0 0"],'CALL "FL-HEIGHT" USING WS-I(1) WS-I(2) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1,"1000000 %d %d 0"%(m(own(8)),m(own(4))))
g.run('camera height is 1.0 for a source under a sturdy DOWN face, else the height',["1 1 8 0","1 0 8 0","0 1 5 0","0 1 5 1"],'CALL "FL-CAMERA" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1,"1000000 %d %d 1000000"%(m(own(8)),m(own(5))))
K=f32(0.8888889)
def delta(aff,h,bf,bba,bh,o):
    if not aff: return 0.0
    if h==0:
        if (not bf) and bba and bh>0: return f32(o-f32(bh-K))
        return 0.0
    return f32(o-h)
cases=[(1,own(5),0,0,0,own(8)),(1,0,0,1,own(5),own(8)),(1,0,1,1,own(5),own(8)),(1,0,0,1,0,own(8)),(0,own(5),0,0,0,own(8)),(1,0,0,0,own(5),own(8))]
g.run('flow delta of one direction: the own height difference to a fluid neighbour; for an empty neighbour that does not block flow, the drop to the fluid below it',
 ["%d %.8f %d %d %.8f %.8f"%(a,b,c,d,e,f) for a,b,c,d,e,f in cases],'CALL "FL-FLOW-DELTA" USING WS-I(1) WS-FX(2) WS-I(3) WS-I(4) WS-FX(5) WS-FX(6) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1,
 " ".join(str(m(delta(*c))) for c in cases))
def norm(x,y,z):
    d=math.sqrt(x*x+y*y+z*z); return (0.0,0.0,0.0) if d==0 else (x/d,y/d,z/d)
def flow(sx,sz,fall,solid):
    r=(sx,0.0,sz)
    if fall and solid:
        n=norm(*r); r=(n[0],n[1]-6.0,n[2])
    return norm(*r)
fc=[(3,4,0,0),(0,0,0,0),(3,4,1,1),(3,4,1,0),(-1,0,0,0),(0,0,1,1)]
g.run('flow vector: the normalised horizontal sum; a falling column next to a solid face adds (0, -6, 0) before normalising; zero stays zero',
 ["%d %d %d %d"%c for c in fc],'CALL "FL-FLOW" USING WS-FX(1) WS-FX(2) WS-I(3) WS-I(4) WS-RF(1) WS-RF(2) WS-RF(3)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(3) * 1000',3,
 " ".join("%d/%d/%d"%tuple(m(v,1000) for v in flow(*c)) for c in fc))
g.run('isSolidFace: false for the same fluid, true for UP, false for ice, else the sturdy face',["1 0 0 1","0 1 0 0","0 0 1 1","0 0 0 1","0 0 0 0"],'CALL "FL-SOLID-FACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"0 1 0 1 0")
g.write('core/tests/test_fluids_29a_1.cob')
# ---- section 2
g=Gen('TEST-FLUIDS-29A-2','29a§2','The fluid tick','Test of 29a section 2, The fluid tick (core/src/fluids-29a.cob; T0481): tick delays, the tick step, getNewLiquid, spread, holes and the slope search, passing rules, canBeReplacedWith and spreadTo.',
 extra=" 01 WS-GRID                PIC X(81).\n")
g.run('tick delay, slope find distance and drop-off: water 5, 4, 1; lava 30, 2, 2 or, with fast_lava, 10, 4, 1',["1 0","2 0","2 1"],'CALL "FL-DELAY" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"5/4/1 30/2/2 10/4/1")
g.run('lava growing taller multiplies its spread delay by 4 on 3 draws in 4; water and other lava use the plain delay',["2 0 1 1 1 1","2 0 1 1 1 0","2 0 1 1 0 1","2 1 1 1 1 2","1 0 1 1 1 1","2 0 0 1 1 1","2 0 1 0 1 1"],'CALL "FL-SPREAD-DELAY" USING %s WS-R(1)'%I(*range(1,7)),1,"120 30 30 40 5 30 30")
g.run('tick: a source does nothing here; an empty new state sets air; a changed state is written and rescheduled; an unchanged one only spreads',["1 0 0","0 1 0","0 0 0","0 0 1"],'CALL "FL-TICK-DECIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"0 1 2 3")
g.run('getNewLiquid: two sources over a solid or source floor convert (rule on); fluid above gives amount 8 falling; else the highest neighbour minus the drop-off, empty at 0',
 ["5 2 1 1 0 0 1","5 2 0 1 0 0 1","5 2 1 0 0 0 1","5 2 1 0 0 1 1","1 0 1 1 0 0 1","8 0 1 1 0 0 2","3 1 1 1 0 0 1","5 2 1 0 1 0 1"],'CALL "FL-NEW-LIQUID" USING %s WS-R(1) WS-R(2) WS-R(3)'%I(*range(1,8)),3,
 "1/8/0 2/4/0 2/4/0 2/8/1 0/0/0 2/6/0 2/2/0 1/8/0")
g.run('spread: falling into the cell below spreads down (and also to the sides with 3 source neighbours); otherwise sides for a source or a cell that is not a hole; a flowing hole does not spread',
 ["1 1 1 0 0 0","1 1 1 3 0 0","1 1 1 2 0 0","1 0 1 0 0 0","1 1 0 0 0 1","0 0 0 0 0 1","0 0 0 0 1 1","0 0 0 0 0 0"],'CALL "FL-SPREAD-DECIDE" USING %s WS-R(1)'%I(*range(1,7)),1,"1 2 1 3 0 0 3 3")
g.run('spreadToSides: amount minus the drop-off (7 when falling); nothing when it is not above 0',["5 0 1","1 0 1","3 1 2","2 0 2"],'CALL "FL-SIDES" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"4/1 0/0 7/1 0/0")
g.run('isWaterHole: needs to pass the wall below, then the same fluid below or a cell that can hold the flowing fluid',["1 1 0","1 0 1","1 0 0","0 1 1"],'CALL "FL-IS-HOLE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 1 0 0")
g.run('getSpread keeps only the directions with the smallest distance to a hole that the new fluid can replace; invalid directions are skipped',
 ["1000 0 1000 2 1 1 1 1 1 1 1 1","1 1 2 1 1 1 1 1 1 1 1 1","3 0 3 5 1 0 1 1 1 1 1 1","1 1 2 3 1 1 1 1 0 1 1 1","1000 1000 1000 1000 1 1 1 1 1 1 1 1"],'CALL "FL-SPREAD-MAP" USING WS-ISG WS-RSG',4,
 "0/1/0/0 1/1/0/1 1/0/1/0 0/1/0/0 1/1/1/1")
def slope(grid,x,z,dist,frm,find):
    best=1000
    for d,(dx,dz) in enumerate([(0,-1),(1,0),(0,1),(-1,0)]):
        if d==frm: continue
        nx,nz=x+dx,z+dz
        c=grid[nz*9+nx] if 0<=nx<9 and 0<=nz<9 else '#'
        if c=='#': continue
        if c=='H': return dist
        if dist<find:
            best=min(best,slope(grid,nx,nz,dist+1,d^2 if d in(0,2) or True else d,find))
    return best
def opp(d): return (d+2)%4
def slope2(grid,x,z,dist,frm,find):
    best=1000
    for d,(dx,dz) in enumerate([(0,-1),(1,0),(0,1),(-1,0)]):
        if d==frm: continue
        nx,nz=x+dx,z+dz
        c=grid[nz*9+nx] if 0<=nx<9 and 0<=nz<9 else '#'
        if c=='#': continue
        if c=='H': return dist
        if dist<find: best=min(best,slope2(grid,nx,nz,dist+1,opp(d),find))
    return best
def mk(cells):
    gr=['#']*81
    for (x,z),c in cells.items(): gr[z*9+x]=c
    return "".join(gr)
G1=mk({(x,4):'.' for x in range(1,8)}|{(4,4):'H'})
G2=mk({(x,4):'.' for x in range(1,8)}|{(6,4):'H'})
G3=mk({(x,4):'.' for x in range(1,8)}|{(4,3):'.',(4,2):'.',(4,1):'H'})
G4=mk({(x,4):'.' for x in range(1,8)})
cs=[(G1,1,4,1,4),(G2,1,4,1,4),(G2,1,4,1,6),(G3,3,4,1,4),(G4,1,4,1,4),(G1,5,4,1,-1)]
for gr,x,z,d,fnd in cs[:1]: pass
calls=[]
exp=[]
for gr,x,z,d,fnd in cs:
    frm=-1 if (gr,x,z,d,fnd)==cs[5] else -1
    calls.append(("%d %d %d %d"%(x,z,d,fnd),'MOVE "%s" TO WS-GRID\nCALL "FL-SLOPE" USING WS-GRID WS-I(1) WS-I(2) WS-I(3) WS-I(5) WS-I(4) WS-R(1)'%gr,1))
    exp.append(str(slope2(gr,x,z,d,-1,fnd)))
# tokens: x z dist find -> I1 I2 I3 I4 ; from fixed -1 via I5 (token 5 absent -> 0). use I(5) as from? set explicit token.
calls=[(c[0]+" -1",c[1],c[2]) for c in calls]
g.case('getSlopeDistance: the shallowest hole along each branch within the find distance returns its distance; with none in reach the distance is 1000',calls,"%s"%" ".join(exp))
g.run('canBeReplacedWith: empty always; water only by a non-water fluid falling down; lava from amount 4 up by a water fluid',["0 0 0 0","1 1 0 8","1 1 1 8","1 0 0 8","2 0 1 4","2 0 1 3","2 0 0 8","2 0 1 8"],'CALL "FL-REPLACEABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"1 1 0 0 1 0 0 1")
g.run('canPassThroughWall: false when either collision shape is the full block, true when both are empty, else unless the faces occlude',["1 0 0 0","0 1 0 0","0 0 1 1","0 0 0 1","0 0 0 0"],'CALL "FL-PASS-WALL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"0 0 1 0 1")
g.run('canHold rules: any is a container or washed away by fluids; specific asks the container; canMaybePassThrough needs a non-source neighbour, any, and a wall pass; canPassThrough adds the specific check',["1 0 1","0 1 1","0 0 1","1 0 0"],'CALL "FL-HOLD-RULES" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 1/1/1 0/1/0 1/0/0")
g.run('canMaybePassThrough and canPassThrough combine the checks',["0 1 1 1","1 1 1 1","0 0 1 1","0 1 0 1","0 1 1 0"],'CALL "FL-PASS-RULES" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,"1/1 0/0 0/0 0/0 1/0")
g.run('spreadTo: a container places the liquid; water drops the destroyed block, lava fizzes (1501) without drops; lava falling onto a water liquid block makes stone',["1 0 0 0 0 0","1 0 1 0 0 0","2 0 0 0 0 0","1 1 0 0 0 0","2 0 0 1 1 1","2 0 0 1 1 0","2 0 0 0 1 1"],'CALL "FL-SPREAD-TO" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4)'%I(*range(1,7)),4,"2/1/0/0 2/0/0/0 2/0/1/0 1/0/0/0 4/0/1/1 2/0/1/0 2/0/1/0")
g.write('core/tests/test_fluids_29a_2.cob')
