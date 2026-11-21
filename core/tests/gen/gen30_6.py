import sys,random
from decimal import Decimal as Dc
from fractions import Fraction as Fr
sys.path.insert(0,'core/tests/gen')
from gen30c import *
_w=Suite.write
def _w2(self,g):
    _w(self,g)
    if not self.only or g.n in self.only:
        p=OUT+'/test_redstone_30_%d_%d.cob'%(self.part,g.n)
        t=open(p).read().replace('PIC -(9)9.','PIC -(10)9.')
        open(p,'w').write(t)
Suite.write=_w2
SU=Suite(6,'30-6','RS3-','redstone-30-6.cob',[int(a) for a in sys.argv[1:]])
RNG=random.Random(66)
def ch(rows,n=40): return [rows[i:i+n] for i in range(0,len(rows),n)]
def TT(g,text,call,nout,rows,model):
    # long row lists are split over several cases of at most 40 calls
    for k,part in enumerate(ch(rows)): T(g,text+('' if k==0 and len(rows)<=40 else ' (part %d)'%(k+1)),call,nout,part,model)
SHN=['north_south','east_west','ascending_east','ascending_west','ascending_north','ascending_south','south_east','south_west','north_west','north_east']
NS_,EW_,AE,AW,AN,AS_,SE,SW,NW,NE=range(10)
# ===== 1 The ten rail shapes
g=SU.gen(1,'The ten rail shapes','T0782','ordinals and names, isSlope, the two shape properties, the four block rows, connection lists, rotation and mirror.',NAME)
TN(g,'serialized names (1): the ten values in declaration order, ordinal 0 to 9 (an unknown name gives -1)','CALL "RS3-SHAPE-ORDINAL" USING WS-NM WS-R(1)',1,[(n,) for n in SHN]+[('bogus',),('north_eas',)],lambda n:(SHN.index(n),) if n in SHN else (-1,))
T(g,'isSlope (1): true exactly for ordinals 2 to 5','CALL "RS3-SHAPE-IS-SLOPE" USING WS-I(1) WS-R(1)',1,[(o,) for o in range(10)],lambda o:(int(2<=o<=5),))
T(g,'RAIL_SHAPE allows all ten, RAIL_SHAPE_STRAIGHT ordinals 0 to 5 (property 1 or 2; ordinal 10 is no shape)','CALL "RS3-SHAPE-ALLOWED" USING WS-I(1) WS-I(2) WS-R(1)',1,[(p,o) for p in (1,2) for o in range(-1,11)],lambda p,o:(int(0<=o<=9 and (p==1 or o<=5)),))
BR=[(10,0,20,0),(6,1,24,1),(6,1,24,1),(6,1,24,1)]
T(g,'block rows (1.1): rail 10 shapes, no powered, 20 states, not straight; powered, activator and detector rail 6 shapes, powered, 24 states, straight; all strength 0.7 (tenths), no collision (block 1 rail, 2 powered, 3 activator, 4 detector)','CALL "RS3-RAIL-BLOCK-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(b,) for b in range(0,6)],lambda b:(BR[b-1]+(7,0)) if 1<=b<=4 else (0,0,0,0,0,0))
CONN={NS_:[('N',0),('S',0)],EW_:[('W',0),('E',0)],AE:[('W',0),('E',1)],AW:[('W',1),('E',0)],AN:[('N',1),('S',0)],AS_:[('N',0),('S',1)],SE:[('E',0),('S',0)],SW:[('W',0),('S',0)],NW:[('W',0),('N',0)],NE:[('E',0),('N',0)]}
DV={'N':N,'S':S_,'W':W,'E':E}
T(g,'connection list (1.2): two entries per shape in the order of the table, direction data value (north 2, south 3, west 4, east 5) and up flag (the high end of a slope is one block up)','CALL "RS3-SHAPE-CONN" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(o,i) for o in range(10) for i in (1,2)],lambda o,i:(DV[CONN[o][i-1][0]],CONN[o][i-1][1]))
# rotation and mirror, the table of 1.3 (names)
def nm(*a): return [SHN.index(x) for x in a]
CW90=nm('east_west','north_south','ascending_south','ascending_north','ascending_east','ascending_west','south_west','north_west','north_east','south_east')
CW180=nm('north_south','east_west','ascending_west','ascending_east','ascending_south','ascending_north','north_west','north_east','south_east','south_west')
CCW90=nm('east_west','north_south','ascending_north','ascending_south','ascending_west','ascending_east','north_east','south_east','south_west','north_west')
MLR=nm('north_south','east_west','ascending_east','ascending_west','ascending_south','ascending_north','north_east','north_west','south_west','south_east')
MFB=nm('north_south','east_west','ascending_west','ascending_east','ascending_north','ascending_south','south_west','south_east','north_east','north_west')
# the geometry check: a shape is the pair of its ends; the tables must agree with turning the ends
ENDS={o:frozenset(CONN[o][i][0]+('+' if CONN[o][i][1] else '') for i in (0,1)) for o in range(10)}
def tr(e,m): return ''.join(m.get(c,c) for c in e)
for tab,m in ((CW90,{'N':'E','E':'S','S':'W','W':'N'}),(CCW90,{'N':'W','W':'S','S':'E','E':'N'}),(MLR,{'N':'S','S':'N'}),(MFB,{'E':'W','W':'E'})):
    for o in range(10):
        assert frozenset(tr(e,m) for e in ENDS[o])==ENDS[tab[o]],(o,tab[o])
for o in range(10):
    assert CW180[o]==CW90[CW90[o]] and CW90[CCW90[o]]==o and MLR[MLR[o]]==o and MFB[MFB[o]]==o
ROT=[list(range(10)),CW90,CW180,CCW90]
T(g,'rotation (1.3): none leaves every shape, CW 90, CW 180 and CCW 90 as the table (rotation 0 none, 1 CW 90, 2 CW 180, 3 CCW 90)','CALL "RS3-SHAPE-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(o,r) for r in range(4) for o in range(10)],lambda o,r:(ROT[r][o],))
MIR=[list(range(10)),MLR,MFB]
T(g,'mirror (1.3): none leaves every shape, left-right swaps north and south, front-back swaps east and west (0 none, 1 left-right, 2 front-back)','CALL "RS3-SHAPE-MIRROR" USING WS-I(1) WS-I(2) WS-R(1)',1,[(o,m) for m in range(3) for o in range(10)],lambda o,m:(MIR[m][o],))
rot4='CALL "RS3-SHAPE-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)\nMOVE WS-R(1) TO WS-I(1)\n'*3+'CALL "RS3-SHAPE-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)'
T(g,'validation (9.2): CW 90 four times is the identity','MOVE 1 TO WS-I(2)\n'+rot4,1,[(o,1) for o in range(10)],lambda o,r:(o,))
mir2='CALL "RS3-SHAPE-MIRROR" USING WS-I(1) WS-I(2) WS-R(1)\nMOVE WS-R(1) TO WS-I(1)\nCALL "RS3-SHAPE-MIRROR" USING WS-I(1) WS-I(2) WS-R(1)'
T(g,'validation (9.2): both mirrors are involutions','MOVE 1 TO WS-I(2)\n'+mir2,1,[(o,1) for o in range(10)],lambda o,r:(o,))
T(g,'validation (9.2): both mirrors twice again, front-back','MOVE 2 TO WS-I(2)\n'+mir2,1,[(o,2) for o in range(10)],lambda o,r:(o,))
T(g,'validation (9.1): the shape enum order and isSlope for 2 to 5 and the straight values 0 to 5 (ordinal, slope, straight allowed)','CALL "RS3-SHAPE-IS-SLOPE" USING WS-I(1) WS-R(1)\nCALL "RS3-SHAPE-ALLOWED" USING WS-I(2) WS-I(1) WS-R(2)',2,[(o,2) for o in range(10)],lambda o,p:(int(2<=o<=5),int(o<=5)))
SU.write(g)
# ===== 2 Shared behaviour
g=SU.gen(2,'Shared behaviour of all rail blocks','T0784','what counts as a rail, outline, support, water, placement, the neighbour-driven updates and the signal-source rule.',NAME)
TN(g,'rails tag (2.1): exactly rail, powered_rail, detector_rail and activator_rail','CALL "RS3-RAIL-TAG" USING WS-NM WS-R(1)',1,[(n,) for n in ('rail','powered_rail','detector_rail','activator_rail','stone','minecart','rails','ascending_east')],lambda n:(int(n in ('rail','powered_rail','detector_rail','activator_rail')),))
T(g,'isRail (2.1): the state is in the tag AND the block is a BaseRailBlock (tagged, class)','CALL "RS3-IS-RAIL" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,))
T(g,'selection height (2.2): 2/16 for the non-slope shapes (0, 1, 6 to 9) and 8/16 for slopes','CALL "RS3-RAIL-OUTLINE" USING WS-I(1) WS-R(1)',1,[(o,) for o in range(10)],lambda o:(8 if 2<=o<=5 else 2,))
T(g,'canSurvive (2.2): the state below has a sturdy rigid top face','CALL "RS3-RAIL-SURVIVE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda r:(r,))
T(g,'waterlogging (2.2): the fluid is water while waterlogged; updateShape then schedules a water tick of 5 ticks, otherwise falls through (fluid, scheduled, delay)','CALL "RS3-RAIL-WATER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(0,),(1,)],lambda w:(w,w,5*w))
T(g,'placement state (2.2): east_west when the placer faces east or west, else north_south; waterlogged when the clicked fluid is water (facing 2 to 5, water)','CALL "RS3-RAIL-PLACE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(f,w) for f in (N,S_,W,E) for w in (0,1)],lambda f,w:(int(f in (W,E)),w))
T(g,'onPlace (2.3 step 1): a property change of the same block returns, else updateState runs','CALL "RS3-RAIL-ON-PLACE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(int(not s),))
T(g,'updateState (2.3 step 2): a straight block then calls neighborChanged on itself','CALL "RS3-RAIL-UPDATE-STATE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(s,))
def nbr(server,same,rem,cls):
    if not server or not same: return 0
    if rem: return 1
    return {1:2,2:3,3:4}[cls]
T(g,'neighborChanged (2.3 step 3): server only and only while the block is still this one; removal with drops when shouldBeRemoved, else plain rail 3.1 (2), powered or activator rail 5.2 (3), detector rail nothing (4); 0 does nothing (server, same, removed, class 1 plain 2 powered 3 detector)','CALL "RS3-RAIL-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(s,m,r,c) for s in (0,1) for m in (0,1) for r in (0,1) for c in (1,2,3)],lambda *a:(nbr(*a),))
def shrem(o,below,high):
    if not below: return 1
    if 2<=o<=5 and not high: return 1
    return 0
T(g,'shouldBeRemoved (2.3 step 4): true when the block below has no rigid top; for the slopes also when the high-side neighbour has none (shape, below rigid, high side rigid)','CALL "RS3-RAIL-SHOULD-REMOVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(o,b,h) for o in (0,1,2,3,4,5,6,9) for b in (0,1) for h in (0,1)],lambda *a:(shrem(*a),))
HIGH={AE:E,AW:W,AN:N,AS_:S_}
T(g,'high side of a slope (2.3 step 4): ascending_east east, ascending_west west, ascending_north north, ascending_south south (0 for a flat shape)','CALL "RS3-SLOPE-HIGH-SIDE" USING WS-I(1) WS-R(1)',1,[(o,) for o in range(10)],lambda o:(HIGH.get(o,0),))
T(g,'updateDir (2.3 step 5): the client returns the state unchanged, the server runs place (1 runs)','CALL "RS3-RAIL-UPDATE-DIR" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(s,))
def rem(moved,o,st):
    if moved: return (0,0,0)
    return (int(2<=o<=5),st,st)
T(g,'affectNeighborsAfterRemoval (2.3 step 6): nothing by a piston; a slope updates above, a straight block updates at and below (moved, shape, straight; above, at, below)','CALL "RS3-RAIL-REMOVAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,[(m,o,s) for m in (0,1) for o in (0,2,4,7) for s in (0,1)],rem)
T(g,'hasNeighborSignal (2.3): true at the first of down, up, north, south, west, east with a signal above 0 (result, index of the first hit)','CALL "RS1-HAS-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,[(0,0,0,0,0,0),(0,0,3,0,0,0),(9,0,0,0,0,0),(0,0,0,0,0,15)],lambda *v:next(((1,i+1) for i,x in enumerate(v) if x>0),(0,0)))
T(g,'signal source (2.4): only the detector rail (kind 1 rail, 2 powered, 3 activator, 4 detector)','CALL "RS3-RAIL-SOURCE" USING WS-I(1) WS-R(1)',1,[(k,) for k in (1,2,3,4)],lambda k:(int(k==4),))
T(g,'wire connection (2.4): the default rule, a signal source and a non-null direction; of the rails only the detector rail (kind, direction given)','CALL "RS3-RAIL-WIRE-CONNECT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(k,d) for k in (1,2,3,4) for d in (0,1)],lambda k,d:(int(k==4 and d),))
SU.write(g)
# ===== 3 Plain rail
g=SU.gen(3,'Plain rail','T0786','the reaction to a signal-source neighbour, the potential connection count and hasRail.')
T(g,'hasRail (3.1): a rail at the position, above it or below it','CALL "RS3-HAS-RAIL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a or b or c),))
T(g,'countPotentialConnections (3.1): the horizontal directions with hasRail true (four flags)','CALL "RS3-COUNT-POTENTIAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[tuple((i>>k)&1 for k in range(4)) for i in range(16)],lambda *a:(sum(a),))
T(g,'reaction to a signal source (3.1): acts only when the default state of the source block is a signal source AND exactly 3 potential connections; then updateDir with forceUpdate false (acts, force)','CALL "RS3-PLAIN-REACT" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(s,c) for s in (0,1) for c in range(5)],lambda s,c:(int(s==1 and c==3),0))
SU.write(g)
# ===== 4 Shape resolution
g=SU.gen(4,'Shape resolution','T0788','getRail, connectsTo, canConnectTo, removeSoftConnections, hasNeighborRail, place steps 1 to 8, connectTo and the worked examples.')
T(g,'getRail (4.1): the rail at p, else at p.above(), else at p.below() (1, 2, 3; 0 none)','CALL "RS3-GET-RAIL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(1 if a else 2 if b else 3 if c else 0,))
def cts(n,x1,z1,x2,z2,ox,oz):
    return (int((n>=1 and (x1,z1)==(ox,oz)) or (n>=2 and (x2,z2)==(ox,oz))),)
T(g,'connectsTo (4.1): the list holds a position with the same x and z as the other rail (count, two entries, other x z)','CALL "RS3-CONNECTS-TO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1,[(0,5,5,6,6,5,5),(1,5,5,6,6,5,5),(1,5,5,6,6,6,6),(2,5,5,6,6,6,6),(2,5,5,6,6,7,7),(1,5,5,6,6,5,6),(2,5,6,6,5,5,5)],cts)
T(g,'canConnectTo (4.1): connectsTo is false OR the list does not have exactly 2 entries (connects, entries)','CALL "RS3-CAN-CONNECT-TO" USING WS-I(1) WS-I(2) WS-R(1)',1,[(c,n) for c in (0,1) for n in (0,1,2)],lambda c,n:(int(not c or n!=2),))
T(g,'removeSoftConnections (4.1): an entry is kept (with the real y) when its rail exists and connects back, else dropped (rail exists, connects back)','CALL "RS3-SOFT-KEEP" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,))
T(g,'hasNeighborRail (4.1): false without a rail; else the neighbour list is cleaned (side effect) and canConnectTo is the result (rail, canConnect; result, cleaned)','CALL "RS3-HAS-NEIGHBOR-RAIL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,a))
def place(st,pw,old,n,s,w,e,aN,aS,aE,aW):
    NSx=n or s; EWx=w or e
    SEf=s and e; SWf=s and w; NEf=n and e; NWf=n and w
    sh=None
    if NSx and not EWx: sh=NS_
    if EWx and not NSx: sh=EW_
    if not st:
        if SEf and not n and not w: sh=SE
        elif SWf and not n and not e: sh=SW
        elif NWf and not s and not e: sh=NW
        elif NEf and not s and not w: sh=NE
    if sh is None:
        base=old if (NSx and EWx) else NS_ if NSx else EW_ if EWx else None
        sh=base
        if not st:
            order=[(NWf,NW),(NEf,NE),(SWf,SW),(SEf,SE)] if pw else [(SEf,SE),(SWf,SW),(NEf,NE),(NWf,NW)]
            for f,c in order:
                if f: sh=c; break
    if sh==NS_:
        if aN: sh=AN
        if aS: sh=AS_
    elif sh==EW_:
        if aE: sh=AE
        if aW: sh=AW
    if sh is None: sh=old
    return (sh,)
PL='CALL "RS3-PLACE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-I(10) WS-I(11) WS-R(1)'
def nb(i): return tuple((i>>k)&1 for k in range(4))
rows=[(st,pw,old)+nb(i)+(0,0,0,0) for st in (0,1) for pw in (0,1) for old in ((0,1,4) if True else ()) for i in range(16) if not (st and old>5)]
TT(g,'place steps 1 to 7 (4.2), every neighbour combination, straight and plain rails, unpowered and powered, old shape 0, 1 or 4 (straight, powered, old, n s w e, no slopes)',PL,1,rows,place)
rows=[(0,pw,old)+nb(i)+nb(j) for pw in (0,) for old in (0,) for i in (1,2,4,8,3,12,5) for j in range(16)]
TT(g,'place step 5 slopes (4.2): north_south checks north.above then south.above (south wins), east_west east.above then west.above (west wins)',PL,1,rows,place)
rows=[(0,pw,old)+nb(i)+(0,0,0,0) for pw in (0,1) for old in (2,3,6,9) for i in (0,5,10,15)]
TT(g,'place step 6 and curve bases (4.2): nothing around gives the old shape; both axes with a curve base',PL,1,rows,place)
EX=[('example 1 (4.4): free rails at east and south only give south_east',(0,0,NS_,0,1,0,1,0,0,0,0),SE),
 ('example 2 (4.4): T-junction north, south, east, unpowered: south_east',(0,0,NS_,1,1,0,1,0,0,0,0),SE),
 ('example 2 (4.4): the same T-junction powered: north_east',(0,1,NS_,1,1,0,1,0,0,0,0),NE),
 ('example 3 (4.4): free rails at west and east and a rail at east.above gives ascending_east',(0,0,0,0,0,1,1,0,0,1,0),AE),
 ('example 4 (4.4): a powered rail with neighbours at north and east only keeps its old shape north_south and stays straight',(1,1,NS_,1,0,0,1,0,0,0,0),NS_)]
for tx,r,exp in EX:
    T(g,tx,PL,1,[r],lambda *a,e=exp:(e,))
for tx,r,exp in EX:
    assert place(*r)==(exp,),tx
T(g,'junction priority (4.5): the plain rail with three potential neighbours resolves by powered; north, south, west: unpowered south_west, powered north_west','CALL "RS3-PLACE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-I(10) WS-I(11) WS-R(1)',1,[(0,0,0,1,1,1,0,0,0,0,0),(0,1,0,1,1,1,0,0,0,0,0)],place)
def conn_shape(st,n,s,w,e,aN,aS,aE,aW):
    sh=None
    if n or s: sh=NS_
    if w or e: sh=EW_
    if not st:
        if (s and e) and not n and not w: sh=SE
        if (s and w) and not n and not e: sh=SW
        if (n and w) and not s and not e: sh=NW
        if (n and e) and not s and not w: sh=NE
    if sh==NS_:
        if aN: sh=AN
        if aS: sh=AS_
    if sh==EW_:
        if aE: sh=AE
        if aW: sh=AW
    if sh is None: sh=NS_
    return (sh,)
rows=[(st,)+nb(i)+(0,0,0,0) for st in (0,1) for i in range(16)]+[(0,)+nb(i)+nb(j) for i in (1,2,4,8,5,10,3) for j in (1,2,4,8,15)]
TT(g,'connectTo (4.3): north_south for north or south, east_west for west or east (the later wins), the exclusive curves for a plain rail, the slope step, north_south when nothing is linked','CALL "RS3-CONNECT-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1,rows,conn_shape)
T(g,'place step 8 (4.2): the state is written when forceUpdate is true OR the current state is not the identical new state (force, identical)','CALL "RS3-PLACE-WRITE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(f,s) for f in (0,1) for s in (0,1)],lambda f,s:(int(f or not s),))
SU.write(g)
# ===== 5 Powered rail and activator rail
TB6=TBL('KD',64)+TBL('DR',64)+TBL('PW',64)
g=SU.gen(5,'Powered rail and activator rail','T0790','the signal status, the powering decision, the search step table, the same-rail test and the chain reach of 8 rails.',TB6)
T(g,'signal status (5.1): powered rails and activator rails are not signal sources (kind 2 powered, 3 activator)','CALL "RS3-RAIL-SOURCE" USING WS-I(1) WS-R(1)',1,[(2,),(3,)],lambda k:(0,))
def pdec(h,f,b,cur,sl):
    sh=int(h or f or b); ch_=int(sh!=cur)
    return (sh,ch_,ch_,int(ch_ and sl))
T(g,'powering decision (5.2): shouldBePowered is the neighbour signal OR a powered rail found forward OR backward; a difference writes powered, updates below and, for a slope, above (neighbour signal, forward, backward, current powered, slope; should, changed, below, above)','CALL "RS3-POWER-DECISION" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(h,f,b,c,s) for h in (0,1) for f in (0,1) for b in (0,1) for c in (0,1) for s in (0,1)],pdec)
# search table: shape -> forward (dx dy dz checkBelow), backward, axis shape
SR={NS_:((0,0,1,1),(0,0,-1,1),NS_),EW_:((-1,0,0,1),(1,0,0,1),EW_),AE:((-1,0,0,1),(1,1,0,0),EW_),AW:((-1,1,0,0),(1,0,0,1),EW_),AN:((0,0,1,1),(0,1,-1,0),NS_),AS_:((0,1,1,0),(0,0,-1,1),NS_)}
def sstep(o,f):
    a,b,ax=SR[o]; v=a if f else b
    return (v[0],v[1],v[2],v[3],ax)
T(g,'search step (5.3 step 2): the move by shape for forward and backward, whether the cell below is also checked, and the axis shape passed on (shape 0 to 5, forward; dx dy dz checkBelow axis)','CALL "RS3-SEARCH-STEP" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(o,f) for o in range(6) for f in (1,0)],sstep)
def same(sb,axis,ns,pw,hs):
    if not sb: return 0
    if axis==EW_ and ns in (NS_,AN,AS_): return 0
    if axis==NS_ and ns in (EW_,AE,AW): return 0
    if not pw: return 0
    return 1 if hs else 2
TT(g,'isSameRailWithPower (5.3): the same block, a shape not excluded by the axis, powered, then true with a direct signal else the search goes on (2) (same block, axis 0 or 1, neighbour shape, powered, neighbour signal; 0 false, 1 true, 2 continue)','CALL "RS3-SAME-RAIL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(sb,ax,ns,pw,hs) for sb in (0,1) for ax in (0,1) for ns in range(6) for pw in (0,1) for hs in (0,1)],lambda *a:(same(*a),))
# the chain model: the literal recursion of 5.3 over a line of rails along the east-west axis (index = x)
def find(n,kd,dr,pw,x,fwd,count):
    if count>=8: return 0
    nx=x-1 if fwd else x+1       # forward = toward west on the east-west axis
    def isame(p):
        if not(1<=p<=n): return 0
        if kd[p]!=kd[x]: return 0
        if not pw[p]: return 0
        if dr[p]: return 1
        return find(n,kd,dr,pw,p,fwd,count+1)
    return int(isame(nx))
def chain(n,idx,kd,dr,pw):
    K={i+1:v for i,v in enumerate(kd)}; Dd={i+1:v for i,v in enumerate(dr)}; P={i+1:v for i,v in enumerate(pw)}
    return (int(Dd[idx] or find(n,K,Dd,P,idx,1,0) or find(n,K,Dd,P,idx,0,0)),)
def lcall(n,idx,kd,dr,pw):
    return setarr('KD',kd)+setarr('DR',dr)+setarr('PW',pw)+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nCALL "RS3-LINE-POWER" USING WS-I(1) WS-I(2) WS-KDG WS-DRG WS-PWG WS-R(1)'%(n,idx)
def lc(text,n,idx,kd,dr,pw):
    kd=list(kd)+[0]*(64-len(kd)); dr=list(dr)+[0]*(64-len(dr)); pw=list(pw)+[0]*(64-len(pw))
    return (text,[("0",lcall(n,i,kd,dr,pw),1) for i in idx]," ".join(str(chain(n,i,kd,dr,pw)[0]) for i in idx))
w=lc('example 1 (5.4): five rails east-west, a lever block touching rail 3 (index 1 to 5): rail 3 powers, rails 2 and 4 find it, rails 1 and 5 find it through the chain',5,[1,2,3,4,5],[1]*5,[0,0,1,0,0],[0,1,1,1,0])
g.case(*w)
g.case(*lc('example 2 (5.4): the lever removed, rail 3 finds no source and unpowers',5,[1,2,3,4,5],[1]*5,[0]*5,[0,1,1,1,0]))
g.case(*lc('example 3 (5.4): sixteen rails, source touching rail 1: rails 1 to 9 powered (count below 8), rails 10 to 16 not',16,list(range(1,17)),[1]*16,[1]+[0]*15,[1]*16))
g.case(*lc('example 5 (5.4): a powered line next to an activator line on the same axis never conducts between them',6,[1,2,3,4,5,6],[1,1,1,2,2,2],[1,0,0,0,0,0],[1,1,1,1,1,1]))
g.case(*lc('chain breaks (5.3): an unpowered rail in the middle stops the search; a direct signal on the far rail of the same kind ends it',7,[1,2,3,4,5,6,7],[1]*7,[1,0,0,0,0,0,1],[1,1,0,1,1,1,1]))
SU.write(g)
# ===== 6 Detector rail
g=SU.gen(6,'Detector rail','T0792','the signal output, the detection box and queries, the press cycle, its triggers and the comparator output.')
T(g,'signal output (6.1): ownSignal 15 when powered else 0; getDirectSignal 15 only when powered and the direction is UP (powered, direction, query 0 getSignal 1 getDirectSignal)','CALL "RS3-DETECTOR-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(p,d,q) for p in (0,1) for d in (0,1,2,5) for q in (0,1)],lambda p,d,q:(15 if p and (q==0 or d==U) else 0,))
T(g,'detection box (6.2): (x + 0.2, y, z + 0.2) to (x + 0.8, y + 0.8, z + 0.8), in thousandths of a block','CALL "RS3-DETECTOR-BOX" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(0,)],lambda x:(200,0,200,800,800,800))
DQ={1:(1,0),2:(2,0),3:(1,1)}
T(g,'queries (6.2): pressed check AbstractMinecart always true (class 1, predicate 0), command block cart MinecartCommandBlock (2, 0), container cart AbstractMinecart with the container selector (1, 1)','CALL "RS3-DETECTOR-QUERY" USING WS-I(1) WS-R(1) WS-R(2)',2,[(u,) for u in (1,2,3)],lambda u:DQ[u])
T(g,'container selector (6.2): implements Container and is alive','CALL "RS3-CONTAINER-SELECTOR" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,))
def trig(k,s,p):
    return int({1:s and not p,2:p,3:1}[k])
T(g,'triggers (6.3): entityInside only on the server while not powered, tick only when powered, onPlace always (kind 1 entityInside 2 tick 3 onPlace; server, powered)','CALL "RS3-DETECTOR-TRIGGER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(k,s,p) for k in (1,2,3) for s in (0,1) for p in (0,1)],lambda *a:(trig(*a),))
def chk(surv,same_,was,cart):
    if not surv or not same_: return (0,was,0,0,0)
    new=cart
    return (1,new,int(new!=was),20 if cart else 0,1)
T(g,'checkPressed (6.3): returns when the rail cannot survive or is not this block; a cart powers it, none unpowers it (with updates), a cart schedules a tick in 20, always the comparator update (survives, this block, was powered, any cart; ran, powered, changed, tick delay, comparators)','CALL "RS3-CHECK-PRESSED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(a,b,c,d) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1)],chk)
T(g,'updatePowerToConnected (6.3): a neighborChanged for each position in the connection list of the shape (shape 0 to 5, entry; direction, up)','CALL "RS3-SHAPE-CONN" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(o,i) for o in range(6) for i in (1,2)],lambda o,i:(DV[CONN[o][i-1][0]],CONN[o][i-1][1]))
def ana(p,hc,sc,hct,cs):
    if not p: return 0
    if hc: return sc
    if hct: return cs
    return 0
T(g,'comparator output (6.4): 0 unpowered; else the success count of the first command block cart, else the container fullness of the first container cart, else 0 (powered, command cart, success count, container cart, fullness)','CALL "RS3-DETECTOR-ANALOG" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(0,1,3,1,9),(1,1,3,1,9),(1,0,3,1,9),(1,0,3,0,9),(1,1,0,0,0),(1,0,0,1,0)],lambda *a:(ana(*a),))
T(g,'worked example 4 (6.5): command block cart with success count 3 on a powered rail reads 3; an empty plain cart reads 0','CALL "RS3-DETECTOR-ANALOG" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(1,1,3,0,0),(1,0,0,0,0)],lambda *a:(ana(*a),))
CP6='CALL "RS3-CHECK-PRESSED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)'
g.case('worked example 1 to 3 (6.5): a cart arrives (powers, tick in 20), stands still (stays powered, no change), leaves (unpowers, no tick)',[("1 1 0 1",CP6,5),("1 1 1 1",CP6,5),("1 1 1 0",CP6,5)],"1/1/1/20/1 1/1/0/20/1 1/0/1/0/1")
SU.write(g)
# ===== 7 Summary of reactions
g=SU.gen(7,'Summary of reactions','T0794','the handler of each event and the placement chain.')
def placed(kind):
    st=int(kind>=2)
    return (1,st,{1:0,2:1,3:1,4:2}[kind])
T(g,'block placed (7): place with forceUpdate; straight rails then run their own neighborChanged: powered and activator rails compute powered (1), the detector rail runs checkPressed (2), the plain rail nothing (0) (kind; force, self neighborChanged, what runs)','CALL "RS3-PLACED-EFFECT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(k,) for k in (1,2,3,4)],placed)
HID={1:1,2:2,3:3,4:4}
T(g,'handler table (7): placed 1 onPlace/updateState, neighbour update 2 neighborChanged, removed 3 affectNeighborsAfterRemoval, rotation and mirror 4 rotate/mirror','CALL "RS3-HANDLER-ID" USING WS-I(1) WS-R(1)',1,[(e,) for e in (1,2,3,4,9)],lambda e:(HID.get(e,0),))
T(g,'neighbour update by kind (7): unsupported removes with drops; else plain rail 3.1, powered and activator rail 5.2, detector rail nothing','CALL "RS3-RAIL-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,1,1,1),(1,1,0,1),(1,1,0,2),(1,1,0,3)],lambda *a:(nbr(*a),))
T(g,'removal by kind (7): neighbour updates at above (slopes), at and below (straight), nothing by a piston','CALL "RS3-RAIL-REMOVAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,[(0,2,1),(0,0,1),(0,4,0),(1,2,1)],rem)
T(g,'rotation and mirror (7): table 1.3 (CW 90 of ascending_east is ascending_south; mirror left-right of ascending_north is ascending_south)','CALL "RS3-SHAPE-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)\nCALL "RS3-SHAPE-MIRROR" USING WS-I(3) WS-I(4) WS-R(2)',2,[(AE,1,AN,1)],lambda a,b,c,d:(CW90[a],MLR[c]))
SU.write(g)
# ===== 8 Minecart hooks
g=SU.gen(8,'Minecart hooks that depend on rail shape and power','T0796','the movement flag, the rail under a cart, the activator hooks, the old movement steps, the other rails, the exits and the experimental movement.',NAME)
TN(g,'movement flag (8 introduction): minecart_improvements is its own flag, apart from vanilla, so the default flags do not hold it (flag name; in the default flags)','CALL "RS3-FEATURE-DEFAULT" USING WS-NM WS-R(1)',1,[(n,) for n in ('vanilla','minecart_improvements','trade_rebalance','redstone_experiments')],lambda n:(int(n=='vanilla'),))
T(g,'movement choice (8 introduction): the experimental movement only with the flag enabled (flag on the level)','CALL "RS3-USE-EXPERIMENTAL" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda f:(f,))
T(g,'rail under a cart, old movement (8.1): the cart block y, or y - 1 when the block below is in the rails tag (y, below in tag)','CALL "RS3-RAIL-POS-OLD" USING WS-I(1) WS-I(2) WS-R(1)',1,[(64,0),(64,1),(-3,1)],lambda y,t:(y-t,))
def floor_(x): return int(Dc(x).__floor__())
def probe(y): return (floor_(Dc(y)-Dc('0.1')-Dc('0.000009999999747378752')),)
for y in ('64.5','64.1','64.2','65','64.10001','64.1000099'):
    pass
g.case('probe height (8.1): py = y - 0.1 - 1e-5 (9.999999747378752E-6), its floor',[(y,'CALL "RS3-PROBE-Y" USING WS-FX(1) WS-R(1)',1) for y in ('64.5','64.1','64.2','65','64.10001','64.1000099')]," ".join(show(probe(y)) for y in ('64.5','64.1','64.2','65','64.10001','64.1000099')))
T(g,'rail under a cart, experimental movement (8.1): the probe cell when it holds a rail (its y is floor(py)), else the cart own floor y, with no y - 1 test (floor y, probe floor, rail at probe)','CALL "RS3-RAIL-POS-EXP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(64,63,1),(64,63,0),(64,64,1)],lambda y,p,t:(p if t else y,))
T(g,'on a rail or off it (8.1): a rail runs the track step, else comeOffTrack (is a rail)','CALL "RS3-ON-TRACK" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda r:(r,))
SU.write(g)
# --- 8.2 activator hook
T(g,'activator call (8.2): made when the state is exactly the activator rail, every tick, after the track step (old movement) or before it (experimental) (kind 1 rail 2 powered 3 activator 4 detector, experimental; called, before the track step)','CALL "RS3-ACTIVATOR-CALL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(k,e) for k in (1,2,3,4) for e in (0,1)],lambda k,e:(int(k==3),e))
CART={1:1,2:2,3:3,4:4,5:0,6:0,7:0}
T(g,'cart classes (8.2): rideable 1, TNT 2, hopper 3, command block 4 override the call; chest 5, furnace 6 and spawner 7 carts have none (0)','CALL "RS3-ACT-KIND" USING WS-I(1) WS-R(1)',1,[(c,) for c in range(0,9)],lambda c:(CART.get(c,0),))
def rid(p,ps,ht):
    if not p: return (0,0,ht,0)
    hurt=int(ht==0)
    return (int(ps>0),hurt,10 if hurt else ht,500 if hurt else 0)
T(g,'rideable cart (8.2): powered ejects the passengers, then when the hurt time is 0 the hurt direction is negated, hurt time 10, damage 50.0 (tenths) and markHurt; unpowered nothing (powered, passengers, hurt time; eject, hurt, new hurt time, damage tenths)','CALL "RS3-ACT-RIDEABLE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(p,ps,h) for p in (0,1) for ps in (0,2) for h in (0,7)],rid)
def tnt(p,f,ex):
    if p and f<0: return (1,80 if ex else f)
    return (0,f)
T(g,'TNT cart (8.2): when powered and the fuse is below 0 primeFuse(none) runs, which sets the fuse to 80 only when tnt_explodes is true (powered, fuse, tnt_explodes; called, fuse)','CALL "RS3-ACT-TNT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(p,f,e) for p in (0,1) for f in (-1,0,40) for e in (0,1)],tnt)
def pf(sv,ex,src,ign,sil):
    if sv and not ex: return (0,0,0,0,0)
    return (1,80,int(sv and src and not ign),1,int(not sil))
T(g,'primeFuse (8.2): returns at once on a server when tnt_explodes is false; else fuse 80, the ignition source only on the server for a non-null source and no source yet, entity event 70, the TNT_PRIMED sound unless silent (server, tnt_explodes, source, has ignition, silent; ran, fuse, ignition set, event 70, sound)','CALL "RS3-PRIME-FUSE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(a,b,c,d,e) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1) for e in (0,1)],pf)
def hop(p,en):
    want=int(not p)
    return (int(want!=en),want if want!=en else en)
T(g,'hopper cart (8.2): enabled becomes not powered, the setter called only on a change (powered, enabled; setter called, enabled)','CALL "RS3-ACT-HOPPER" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(p,e) for p in (0,1) for e in (0,1)],hop)
def cmd(p,t,l):
    if p and t-l>=4: return (1,t)
    return (0,l)
T(g,'command block cart (8.2): when powered and tickCount - lastActivated >= 4 the command runs once and lastActivated = tickCount (powered, tick count, last; ran, last)','CALL "RS3-ACT-COMMAND" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(p,t,l) for p in (0,1) for t,l in ((100,96),(100,97),(100,0),(3,0))],cmd)
# --- 8.3 old movement (velocities in nanoblocks per tick)
def dv(d): return int(Dc(d)*Dc(10)**9)
def trunc(x): return int(x)
def pull(o,wat):
    d=Dc('0.0078125')*(Dc('0.2') if wat else 1)
    vx=vz=Dc(0)
    if o==AE: vx=-d
    if o==AW: vx=d
    if o==AN: vz=d
    if o==AS_: vz=-d
    return (dv(vx),dv(vz),int(2<=o<=5))
T(g,'slope pull (8.3 step 1): d = 0.0078125, times 0.2 in water; ascending_east x -d, ascending_west x +d, ascending_north z +d, ascending_south z -d; the base y is raised by 1 for slopes (nanoblocks; shape, in water; added x, added z, raised)','CALL "RS3-SLOPE-PULL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(o,w) for o in range(10) for w in (0,1)],pull)
EXI={NS_:((0,0,-1),(0,0,1)),EW_:((-1,0,0),(1,0,0)),AE:((-1,-1,0),(1,0,0)),AW:((-1,0,0),(1,-1,0)),AN:((0,0,-1),(0,-1,1)),AS_:((0,-1,-1),(0,0,1)),SE:((0,0,1),(1,0,0)),SW:((0,0,1),(-1,0,0)),NW:((0,0,-1),(-1,0,0)),NE:((0,0,-1),(1,0,0))}
T(g,'exit vectors (8.5): the two exits of every shape (shape, which exit; x y z)','CALL "RS3-EXIT" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(o,i) for o in range(10) for i in (1,2)],lambda o,i:EXI[o][i-1])
for o in (AE,AW,AN,AS_):
    lows=[e for e in EXI[o] if e[1]==-1]
    assert len(lows)==1
    hs={AE:(1,0),AW:(-1,0),AN:(0,-1),AS_:(0,1)}[o]
    assert (lows[0][0],lows[0][2])==(-hs[0] if hs[0] else 0,-hs[1] if hs[1] else 0)
def isqrt_round(x):
    return int((Dc(x).sqrt()).quantize(Dc(1)))
def hz(vx,vz): return (Dc(vx)**2+Dc(vz)**2).sqrt()
def rnd(x): 
    x=Dc(x); return int(x.quantize(Dc(1),rounding='ROUND_HALF_UP')) if x>=0 else -int((-x).quantize(Dc(1),rounding='ROUND_HALF_UP'))
def align(o,vx,vz):
    a,b=EXI[o]; dx=b[0]-a[0]; dz=b[2]-a[2]; ln=Dc(dx*dx+dz*dz).sqrt()
    if vx*dx+vz*dz<0: dx,dz=-dx,-dz
    sp=min(Dc(2000000000),hz(vx,vz))
    return (rnd(sp*dx/ln),rnd(sp*dz/ln))
T(g,'align with the rail (8.3 step 2): the horizontal velocity projected on the exit pair (second minus first), sign chosen to keep the travel sense, magnitude min(2.0, horizontal speed) (shape, vx, vz in nanoblocks)','CALL "RS3-ALIGN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(NS_,0,300000000),(NS_,0,-300000000),(EW_,400000000,0),(EW_,-100000000,0),(AE,60000000,80000000),(AS_,-30000000,-40000000),(SE,100000000,0),(NW,0,-200000000),(EW_,2100000000,0),(EW_,1500000000,2000000000)],align)
def nudge(pp,sp,ix,iz,h,brake):
    nz=(ix!=0 or iz!=0) if sp else False
    if pp and nz and h<100000000: return (ix*1000,iz*1000,0)
    return (0,0,brake)
T(g,'player nudge (8.3 step 3): the first passenger is a player, the intent (only a server player has one) is not zero and the horizontal speed squared is below 0.01 (h < 0.1): add 0.001 times the RAW intent and clear the brake flag (player, server player, intent x, z in thousandths, h nanoblocks, brake; added x, added z, brake)','CALL "RS3-NUDGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3,[(1,1,500,-250,0,1),(1,1,500,0,99999999,1),(1,1,0,0,0,1),(1,1,500,0,100000000,1),(0,1,500,0,0,1),(1,0,500,0,0,1),(1,1,-1000,1000,50000000,0)],nudge)
def brake(b,vx,vz):
    if not b: return (vx,vz)
    if hz(vx,vz)<30000000: return (0,0)
    return (vx//2 if vx>=0 else -((-vx)//2),vz//2 if vz>=0 else -((-vz)//2))
T(g,'brake (8.3 step 4): on an unpowered powered_rail horizontal speed below 0.03 gives zero, else x and z halved (0.2 gives 0.1) (brake flag, vx, vz nanoblocks)','CALL "RS3-BRAKE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,200000000,0),(1,0,-200000000),(1,29999999,0),(1,30000000,0),(1,18000000,24000000),(0,200000000,0)],brake)
def mclamp(vx,vz,pa,wat):
    f=Dc('0.75') if pa else Dc(1); m=Dc(200000000 if wat else 400000000)
    c=lambda v:max(-m,min(m,Dc(v)*f))
    return (trunc(c(vx)),trunc(c(vz)))
T(g,'move (8.3 step 5): x and z are multiplied by 0.75 with a passenger (1.0 without), then clamped to the maximum speed 0.4 (0.2 in water) (vx, vz, passenger, in water)','CALL "RS3-MOVE-CLAMP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(100000000,-100000000,0,0),(100000000,-100000000,1,0),(600000000,-600000000,1,0),(500000000,-500000000,0,0),(300000000,-300000000,0,1),(200000000,0,1,1)],mclamp)
def slow(mv,pa,wat,vx,vy,vz):
    f=Dc('0.997') if pa else (Dc('0.96') if mv==0 else Dc('0.975'))
    x,z=Dc(vx)*f,Dc(vz)*f
    x,z=Dc(trunc(x)),Dc(trunc(z))
    y=Dc(0)
    if wat:
        k=Dc('0.949999988079071')
        x,y,z=Dc(trunc(x*k)),Dc(trunc(y*k)),Dc(trunc(z*k))
    return (int(x),int(y),int(z))
T(g,'natural slowdown (8.3 step 5a): (f, 0, f), f 0.997 with a passenger, else 0.96 old movement and 0.975 experimental; the vertical velocity is zeroed; in water the whole vector is multiplied by the float 0.95 (0.949999988079071) (movement 0 old 1 experimental, passenger, water, vx, vy, vz)','CALL "RS3-SLOWDOWN" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3,[(m,p,w,100000000,50000000,-100000000) for m in (0,1) for p in (0,1) for w in (0,1)],slow)
def exdrop(o,rx,rz):
    a,b=EXI[o]
    if a[1]!=0 and (rx,rz)==(a[0],a[2]): return (a[1],)
    if b[1]!=0 and (rx,rz)==(b[0],b[2]): return (b[1],)
    return (0,)
T(g,'exit-block drop (8.3 step 5b): the first exit, else only if that did not apply the second: a non-zero exit y and the cart in the block just beyond that end lowers it by one (shape, floor x - railX, floor z - railZ; y change)','CALL "RS3-EXIT-DROP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(o,rx,rz) for o in (AE,AW,AN,AS_,NS_,SE) for rx,rz in ((-1,0),(1,0),(0,-1),(0,1),(0,0))],exdrop)
def hcorr(h0,p0,p1,vx,vz):
    if not h0: return (vx,vz)
    h=hz(vx,vz)
    dy=Dc(p0-p1)*Dc('0.05')*1000      # micro to nano
    if h>0:
        f=(h+dy)/h
        return (trunc(Dc(vx)*f),trunc(Dc(vz)*f))
    return (vx,vz)
T(g,'height along the rail (8.3 step 5c): dy = (p0.y - p1.y) * 0.05 (rail-surface heights, microblocks); with h > 0 x and z are multiplied by (h + dy) / h; skipped when a rail point is absent (both points, p0.y, p1.y, vx, vz nanoblocks; vx, vz)','CALL "RS3-HEIGHT-CORR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,[(1,2000000,1000000,100000000,0),(1,1000000,2000000,100000000,0),(1,1000000,1000000,60000000,80000000),(0,2000000,1000000,100000000,0),(1,2000000,1000000,0,0)],hcorr)
def redir(rx,rz,vx,vz):
    if rx==0 and rz==0: return (vx,vz)
    h=hz(vx,vz); return (rnd(h*rx),rnd(h*rz))
T(g,'redirect on block change (8.3 step 5d): when the cart left the rail block the horizontal speed continues along the axis of the step (floor x - railX, floor z - railZ, vx, vz)','CALL "RS3-REDIRECT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(1,0,60000000,80000000),(0,-1,30000000,40000000),(0,0,60000000,80000000),(-1,0,0,50000000)],redir)
def snap(o,px,pz):
    a,b=EXI[o]
    p1x=500+500*a[0]; p1z=500+500*a[2]; p2x=500+500*b[0]; p2z=500+500*b[2]
    ex=Fr(p2x-p1x); ez=Fr(p2z-p1z)
    if ex==0: t=Fr(pz)
    elif ez==0: t=Fr(px)
    else: t=((Fr(px-p1x)*ex+Fr(pz-p1z)*ez)*2)/1000000*1000
    def r(q):
        q=Fr(q); n=int(q+Fr(1,2)) if q>=0 else -int(-q+Fr(1,2)); return n
    return (r(p1x+ex*t/1000),r(p1z+ez*t/1000))
T(g,'snap to the rail (8.3 step 5e): the cart is projected on the line through the two half-exit points: t = z for a north-south line, x for an east-west line, else the dot product form times 2 (shape, x and z inside the block in thousandths; new x, z in thousandths)','CALL "RS3-RAIL-SNAP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(NS_,300,700),(NS_,900,100),(EW_,200,100),(EW_,800,999),(AE,400,500),(AN,500,250),(SE,500,500),(SE,700,700),(NW,250,250),(NE,900,100),(SW,100,900)],snap)
def boost(pf,o,vx,vz,wc,ec,nc,sc):
    if not pf: return (vx,vz)
    h=hz(vx,vz)
    if h>Dc(10000000):
        return (vx+rnd(Dc(60000000)*vx/h),vz+rnd(Dc(60000000)*vz/h))
    if o==EW_:
        if wc: return (20000000,vz)
        if ec: return (-20000000,vz)
    if o==NS_:
        if nc: return (vx,20000000)
        if sc: return (vx,-20000000)
    return (vx,vz)
BR_=[]
for pf in (0,1):
    BR_+= [(pf,EW_,100000000,0,0,0,0,0),(pf,NS_,0,-80000000,0,0,0,0),(pf,EW_,30000000,40000000,0,0,0,0)]
for o in (EW_,NS_,AE):
    for c in range(1,16):
        BR_.append((1,o,0,0)+tuple((c>>k)&1 for k in range(4)))
T(g,'boost (8.3 step 6): on a powered powered_rail with h > 0.01 add 0.06 along the travel direction; otherwise by shape the 0.02 push away from a conducting wall (east_west west, else east; north_south north, else south), only the named axis set, other shapes nothing (powered, shape, vx, vz nanoblocks, west, east, north, south conducting)','CALL "RS3-BOOST" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2)',2,BR_[:40],boost)
T(g,'boost, every wall combination (8.3 step 6)','CALL "RS3-BOOST" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2)',2,BR_[40:],boost)
def offt(vx,vy,vz,m,gr,gra):
    c=lambda v:max(-m,min(m,v))
    x,y,z=Dc(c(vx)),Dc(vy),Dc(c(vz))
    if gr: x,y,z=Dc(trunc(x*Dc('0.5'))),Dc(trunc(y*Dc('0.5'))),Dc(trunc(z*Dc('0.5')))
    if not gra:
        k=Dc('0.949999988079071'); x,y,z=Dc(trunc(x*k)),Dc(trunc(y*k)),Dc(trunc(z*k))
    return (int(x),int(y),int(z))
T(g,'off the rails (8.3 step 7, comeOffTrack): x and z clamped to [-m, m], on the ground the whole velocity times 0.5, after the move not on the ground the velocity times the air drag 0.95 (vx, vy, vz, m nanoblocks, ground before, ground after)','CALL "RS3-OFF-TRACK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3,[(600000000,-100000000,-500000000,400000000,gr,ga) for gr in (0,1) for ga in (0,1)]+[(100000000,0,-100000000,200000000,1,1)],offt)
# --- 8.4 other rails
RB={1:(1,0,0),2:(1,1,0),3:(1,0,1),4:(1,0,0)}
T(g,'other rails (8.4, 8.3): the slope pull is the same for every rail shape; only the powered_rail brakes and boosts; only the activator rail calls activateMinecart (kind; slope pull, brake and boost, activator call; 44 wins where 8.4 says the activator rail only calls)','CALL "RS3-RAIL-BEHAVIOR" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(k,) for k in (1,2,3,4)],lambda k:RB[k])
# --- 8.6 experimental movement
T(g,'iteration loop (8.6): continues while it is the first iteration or movementLeft exceeds 1e-5 (10000 nanoblocks) and the cart is alive (first, movementLeft, alive)','CALL "RS3-TRACK-LOOP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,0,1),(1,0,0),(0,10000,1),(0,10001,1),(0,50000,0),(0,0,1)],lambda f,l,a:(int(a==1 and (f==1 or l>10000)),))
T(g,'movementLeft (8.6 step 3): the horizontal length of the result on the first iteration, later movementLeft plus (new horizontal length minus old) (first, movementLeft, new length, old length)','CALL "RS3-MOVEMENT-LEFT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,0,300,100),(0,500,300,100),(0,500,100,300)],lambda f,l,n,o:(n if f else l+(n-o),))
def truns(order,first,ga,ha,bo):
    return {1:not ga,2:first,3:not ha,4:first,5:not bo}[order]
T(g,'transforms run when (8.6 table): slope pull while hasGainedSlopeSpeed is false, nudge first iteration only, halt while hasHalted is false, slowdown first iteration only, boost while hasBoosted is false (order 1 to 5, first iteration, gained, halted, boosted)','CALL "RS3-TRANSFORM-RUNS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(o,f,a,b,c) for o in (1,2,3,4,5) for f in (0,1) for a,b,c in ((0,0,0),(1,1,1))],lambda *a:(int(truns(*a)),))
FL_={1:1,2:2,3:2,4:0,5:3}
T(g,'flag set (8.6 table): the slope pull sets hasGainedSlopeSpeed (1), the nudge and the halt set hasHalted (2), the slowdown none, the boost hasBoosted (3), each only when horizontal speed squared changed; the slope pull does not set hasHalted (order, changed; flag)','CALL "RS3-TRANSFORM-FLAG" USING WS-I(1) WS-I(2) WS-R(1)',1,[(o,c) for o in (1,2,3,4,5) for c in (0,1)],lambda o,c:(FL_[o] if c else 0,))
def xpull(o,wat,h):
    d=max(Dc('0.0078125'),Dc(h)*Dc('0.02')/Dc(10)**9 if False else Dc(h)*Dc('0.02')/ (Dc(1)))
    d=max(Dc(7812500),Dc(h)*Dc('0.02'))
    if wat: d=d*Dc('0.2')
    d=Dc(trunc(d))
    vx=vz=0
    if o==AE: vx=-d
    if o==AW: vx=d
    if o==AN: vz=d
    if o==AS_: vz=-d
    return (int(vx),int(vz))
T(g,'experimental slope pull (8.6): d = max(0.0078125, horizontal speed * 0.02), times 0.2 in water, direction as in 8.3 step 1, other shapes unchanged (shape, in water, horizontal speed nanoblocks)','CALL "RS3-EXP-SLOPE-PULL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(o,w,h) for o in (AE,AW,AN,AS_,NS_,SE) for w in (0,1) for h in (0,100000000,1000000000)],xpull)
def xnudge(sp,ix,iz,h):
    if not sp or (ix==0 and iz==0) or h>=100000000: return (0,0)
    ln=Dc(ix*ix+iz*iz).sqrt()
    return (rnd(Dc(1000000)*ix/ln),rnd(Dc(1000000)*iz/ln))
T(g,'experimental player nudge (8.6): a server player, the intent normalized (length zero: no effect), speed squared below 0.01: add 0.001 times the unit vector of the intent (server player, intent x, z, horizontal speed nanoblocks)','CALL "RS3-EXP-NUDGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(1,3,4,0),(1,-5,0,0),(1,0,0,0),(0,3,4,0),(1,3,4,100000000),(1,0,2000,99999999)],xnudge)
def halt(f,vx,vy,vz):
    if not f: return (vx,vy,vz)
    if hz(vx,vz)<30000000: return (0,0,0)
    q=lambda v: v//2 if v>=0 else -((-v)//2)
    return (q(vx),q(vy),q(vz))
T(g,'halt (8.6): an unpowered powered_rail only: speed below 0.03 gives zero velocity, else all components halved (flag, vx, vy, vz nanoblocks)','CALL "RS3-HALT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,[(1,20000000,10,0),(1,30000000,0,0),(1,200000000,60,-100000000),(0,200000000,60,0)],halt)
T(g,'max speed (8.6): the game rule max_minecart_speed times 0.5 in water or 1.0 otherwise, divided by 20, in microblocks per tick: 8 gives 0.4 on land and 0.2 in water (rule, in water)','CALL "RS3-MAX-SPEED" USING WS-I(1) WS-I(2) WS-R(1)',1,[(8,0),(8,1),(1,0),(7,1),(1000,0)],lambda r,w:(r*(25000 if w else 50000),))
def xboost(pf,o,sp,vx,vz,wc,ec,nc,sc):
    if not pf: return (vx,vz)
    if sp>10000000:
        return (rnd(Dc(vx)*(sp+60000000)/sp),rnd(Dc(vz)*(sp+60000000)/sp))
    d=None
    if o==EW_: d=(1,0) if wc else (-1,0) if ec else None
    if o==NS_: d=(0,1) if nc else (0,-1) if sc else None
    if d is None: return (vx,vz)
    return (d[0]*(sp+200000000),d[1]*(sp+200000000))
XB=[(1,EW_,100000000,100000000,0,0,0,0,0),(1,NS_,50000000,0,-50000000,0,0,0,0),(0,EW_,100000000,100000000,0,0,0,0,0),(1,EW_,0,0,0,1,0,0,0),(1,EW_,5000000,0,0,1,1,0,0),(1,EW_,5000000,0,0,0,1,0,0),(1,NS_,0,0,0,0,0,1,0),(1,NS_,10000000,0,0,0,0,1,1),(1,NS_,0,0,0,0,0,0,1),(1,EW_,0,0,0,0,0,1,1),(1,AE,0,0,0,1,1,1,1),(1,NS_,0,0,0,0,0,0,0),(1,EW_,0,0,0,0,0,0,0)]
T(g,'experimental boost (8.6): on a powered powered_rail speed above 0.01 gives speed + 0.06 along the same direction; otherwise getRedstoneDirection (east_west west conducting (+1,0,0) else east (-1,0,0); north_south north (0,0,+1) else south (0,0,-1); else none) sets the velocity to that unit vector times (speed + 0.2) (powered, shape, speed, vx, vz nanoblocks, west, east, north, south)','CALL "RS3-EXP-BOOST" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1) WS-R(2)',2,XB,xboost)
T(g,'step along the track constants (8.6): minimum movement 1e-5 and minimum horizontal velocity 1e-5 (nanoblocks), the 0.1 lift (nanoblocks), the 1e-5 nudge, the V rest speed squared limit 0.005 (nanoblocks squared)','CALL "RS3-STEP-CONST" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(10000,10000,100000000,10000,5000000))
T(g,'step along the track, rest (8.6): movementLeft below 1e-5 or horizontal velocity below 1e-5 returns 0 and zeroes the velocity (movementLeft, horizontal velocity nanoblocks)','CALL "RS3-STEP-ZERO" USING WS-I(1) WS-I(2) WS-R(1)',1,[(9999,50000),(50000,9999),(10000,10000),(0,0)],lambda m,h:(int(m<10000 or h<10000),))
def tgt(o,vx,vz):
    a,b=EXI[o]
    d1=a[0]*vx+a[2]*vz; d2=b[0]*vx+b[2]*vz
    return (2 if d2>d1 else 1,)
T(g,'step along the track target (8.6): the end point whose half exit has the larger dot product with the horizontal velocity (shape, vx, vz; 1 first exit, 2 second)','CALL "RS3-STEP-TARGET" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(NS_,0,5),(NS_,0,-5),(EW_,5,0),(EW_,-5,0),(AE,-5,0),(AN,0,-3),(SE,0,5),(NE,5,0)],tgt)
T(g,'slope step (8.6): the target is raised 1 block unless the cart is descending; a cart at rest at the bottom of a V (speed squared below 0.005, a slope under it, descending into the next, not descending from it) is stopped (descending; speed squared, slope under, descending into, not descending from)','CALL "RS3-STEP-RAISE" USING WS-I(1) WS-R(1)\nCALL "RS3-STEP-V-REST" USING WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(2)',2,[(0,4999999,1,1,1),(1,5000000,1,1,1),(0,4999999,0,1,1),(0,4999999,1,0,1),(0,4999999,1,1,0)],lambda d,s,a,b,c:(int(not d),int(s<5000000 and a and b and c)))
SU.write(g)
