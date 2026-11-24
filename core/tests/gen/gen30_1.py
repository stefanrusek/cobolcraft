import sys
sys.path.insert(0,'core/tests/gen')
from gen30c import *
SU=Suite(1,'30-1','RS1-','redstone-30-1.cob',sys.argv[1:] and [int(a) for a in sys.argv[1:]])
I=lambda *a:" ".join("WS-I(%d)"%i for i in a)
def R(n): return " ".join("WS-R(%d)"%i for i in range(1,n+1))
# ===== 1 Terminology
g=SU.gen(1,'Terminology','T0700','the constants of the signal range, the tests of powered and the burnout constants.')
T(g,'power range (1): SIGNAL_MIN 0, SIGNAL_MAX 15, SIGNAL_NONE 0, BITS 4, MASK 15','CALL "RS1-CONSTANTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(0,15,0,4,15))
T(g,'powered tests (1): powered is a signal greater than 0 (kind 0) or equal to 15 (kind 1)','CALL "RS1-IS-POWERED" USING WS-I(1) WS-I(2) WS-R(1)',1,[(s,k) for k in (0,1) for s in (0,1,7,14,15)],lambda s,k:(int(s>0) if k==0 else int(s==15),))
T(g,'burnout (1): a torch that toggled 8 times within 60 game ticks stops for 160 ticks','CALL "RS1-BURNOUT-CONST" USING WS-R(1) WS-R(2) WS-R(3)',3,[(0,)],lambda x:(60,8,160))
SU.write(g)
# ===== 2 The signal model
g=SU.gen(2,'The signal model','T0702','the hook defaults, the direction argument, the six level queries, the conductor rule, the census and the experimental flag.',NAME)
T(g,'opposite direction (2.2): down and up, north and south, west and east swap (data values 0 to 5)','CALL "RS1-OPP" USING WS-I(1) WS-R(1)',1,[(d,) for d in range(6)],lambda d:(opp(d),))
T(g,'neighbour offset (2.2, 2.3): a receiver at R asks R + d; down (0,-1,0), up (0,1,0), north (0,0,-1), south (0,0,1), west (-1,0,0), east (1,0,0)','CALL "RS1-STEP" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(d,) for d in range(6)],lambda d:STEP[d])
ORD={1:[D,U,N,S_,W,E],2:[W,E,D,U,N,S_],3:[W,E,N,S_,D,U],4:[N,E,S_,W],5:[U,D]}
T(g,'direction orders (2.3, 2.6): Direction.values() D U N S W E; neighbour-changed W E D U N S; shape update W E N S D U; Plane.HORIZONTAL N E S W; VERTICAL U D','CALL "RS1-DIR-ORDER" USING WS-I(1) WS-I(2) WS-R(1)',1,[(k,i) for k in ORD for i in range(1,len(ORD[k])+1)],lambda k,i:(ORD[k][i-1],))
T(g,'hook defaults (2.1): isSignalSource false, ownSignal 0, getDirectSignal 0, hasAnalogOutputSignal false, getAnalogOutputSignal 0; the default getSignal is ownSignal','CALL "RS1-HOOK-DEFAULTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(0,0,0,0,0))
T(g,'default getSignal (2.1): returns ownSignal for every direction','CALL "RS1-HOOK-SIGNAL" USING WS-I(1) WS-R(1)',1,[(0,),(7,),(15,)],lambda o:(o,))
T(g,'shouldRedstoneWireConnectTo default (2.1): isSignalSource and the direction is not null','CALL "RS1-WIRE-CONNECT-DEFAULT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(a and b),))
def dst(*v):
    r=0;n=0
    for x in v:
        n+=1; r=max(r,x)
        if r>=15: return r,n
    return r,n
V6=[(0,0,0,0,0,0),(3,0,9,0,0,2),(15,1,2,3,4,5),(0,0,0,0,0,15),(4,15,0,0,0,0),(2,4,6,9,8,7),(0,1,0,0,0,0)]
T(g,'getDirectSignalTo (2.3): the maximum over D U N S W E, returning at once when 15 is reached (value, cells asked)','CALL "RS1-DIRECT-SIGNAL-TO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,dst)
T(g,'level getSignal (2.3): a conductor gives the stronger of its own weak output and the strong power around it; a non-conductor only its own output','CALL "RS1-LEVEL-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(s,c,t) for s in (0,5,15) for c in (0,1) for t in (0,3,9)],lambda s,c,t:(max(s,t) if c else s,))
T(g,'hasSignal (2.3): getSignal greater than 0','CALL "RS1-HAS-SIGNAL" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(15,)],lambda s:(int(s>0),))
T(g,'getBestNeighborSignal (2.3): maximum of getSignal(pos + d, d) in the order D U N S W E, 15 returned at once (value, cells asked)','CALL "RS1-BEST-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,dst)
def hasn(*v):
    for i,x in enumerate(v):
        if x>0: return 1,i+1
    return 0,0
T(g,'hasNeighborSignal (2.3): true at the first of D U N S W E with a signal above 0 (result, index of the first hit)','CALL "RS1-HAS-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,hasn)
T(g,'getBestOwnOrNeighbourSignal (2.3): the neighbour value or, for a signal source, its own signal when stronger','CALL "RS1-BEST-OWN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(b,s,o) for b in (0,6,15) for s in (0,1) for o in (0,9,15)],lambda b,s,o:(max(b,o if s else 0),))
def cis(od,dio,rb,wire,wp,src,dr):
    if od: return dr if dio else 0
    if rb: return 15
    if wire: return wp
    if src: return dr
    return 0
CI=[(1,1,0,0,0,0,7),(1,0,0,0,0,1,7),(1,0,1,1,9,1,7),(0,0,1,0,0,0,3),(0,0,0,1,9,0,3),(0,0,0,0,0,1,12),(0,0,0,0,0,0,12),(0,1,0,0,0,0,5),(0,0,0,0,0,1,0)]
T(g,'getControlInputSignal (2.3): diodes only gives the direct signal of a diode else 0; otherwise 15 for a redstone block, the wire power, the direct signal of a signal source, else 0','CALL "RS1-CONTROL-INPUT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1,CI,cis)
LEAVES=['oak','spruce','birch','jungle','acacia','dark_oak','mangrove','red_poplar','orange_poplar','yellow_poplar','azalea','flowering_azalea','cherry','pale_oak']
NEVER=[l+'_leaves' for l in LEAVES]+['piston','sticky_piston','white_stained_glass','lime_stained_glass','copper_grate','exposed_copper_grate','weathered_copper_grate','oxidized_copper_grate','copper_bulb','exposed_copper_bulb','weathered_copper_bulb','oxidized_copper_bulb','waxed_copper_grate','waxed_oxidized_copper_bulb','glass','moving_piston','tnt','ice','glowstone','beacon','redstone_block','sea_lantern','chorus_flower','frosted_ice','observer','bamboo','scaffolding','tinted_glass','powder_snow','pointed_dripstone','sulfur_spike']
def cond(n):
    if n in ('soul_sand','mud'): return 2
    base=n[6:] if n.startswith('waxed_') else n
    for p in ('exposed_','weathered_','oxidized_'):
        if base.startswith(p): base=base[len(p):]; break
    if n.endswith('_stained_glass') or base in ('copper_grate','copper_bulb'): return 1
    if n in NEVER: return 1
    return 0
rows=[(n,) for n in NEVER+['soul_sand','mud','stone','shulker_box','air','glass_pane','white_stained_glass_pane','copper_block','waxed_copper_block','chiseled_copper']]
TN(g,'conductor rule (2.4): 24 never sites (leaves, pistons, stained glass, copper grates and bulbs, glass, tnt, ice and the others), soul_sand and mud always, everything else the full-collision-shape default (0 default, 1 never, 2 always)','CALL "RS1-CONDUCTOR-KIND" USING WS-NM WS-R(1)',1,rows,lambda n:(cond(n),))
CEN=[]
def addc(h,names,own):
    for n,o in zip(names,own): CEN.append((h,n,o))
addc(1,['BasePressurePlateBlock','ButtonBlock','DaylightDetectorBlock','DetectorRailBlock','DiodeBlock','JukeboxBlock','LecternBlock','LeverBlock','LightningRodBlock','ObserverBlock','PoweredBlock','RedstoneTorchBlock','RedstoneWireBlock','SculkSensorBlock','TargetBlock','TrappedChestBlock','TripWireHookBlock','TestBlock'],[5,5,5,6,2,5,5,5,5,2,1,1,1,8,5,5,8,31])
addc(2,['CalibratedSculkSensorBlock','DiodeBlock','ObserverBlock','RedstoneTorchBlock','RedstoneWallTorchBlock','RedstoneWireBlock'],[8,2,2,1,1,1])
addc(3,['BasePressurePlateBlock','ButtonBlock','DetectorRailBlock','DiodeBlock','LecternBlock','LeverBlock','LightningRodBlock','ObserverBlock','RedstoneTorchBlock','RedstoneWireBlock','SculkSensorBlock','TrappedChestBlock','TripWireHookBlock'],[5,5,6,2,5,5,5,2,1,1,8,5,8])
addc(4,['AbstractCauldronBlock','AbstractFurnaceBlock','BarrelBlock','BeehiveBlock','BrewingStandBlock','CakeBlock','CandleCakeBlock','ChestBlock','ChiseledBookShelfBlock','CommandBlock','ComposterBlock','CopperBulbBlock','CopperGolemStatueBlock','CrafterBlock','CreakingHeartBlock','DecoratedPotBlock','DetectorRailBlock','DispenserBlock','EndPortalFrameBlock','HopperBlock','JukeboxBlock','LecternBlock','RespawnAnchorBlock','SculkSensorBlock','ShelfBlock','ShulkerBoxBlock'],[0]*26)
addc(5,['ObserverBlock','RepeaterBlock','RedstoneWireBlock'],[2,2,1])
cr=[(n,h) for h,n,o in CEN]+[('PoweredBlock',3),('RepeaterBlock',1),('PoweredBlock',2),('LeverBlock',5),('NoSuchBlock',1),('TestBlock',3)]
def cen(n,h):
    for hh,nn,o in CEN:
        if hh==h and nn==n: return (o,)
    return (-1,)
TN(g,'census (2.5): the owner part of every class that declares a hook (1 isSignalSource and ownSignal, 2 getSignal, 3 getDirectSignal, 4 analog output, 5 shouldRedstoneWireConnectTo); -1 when the class does not declare it; analog output owners are the family parts (0)','CALL "RS1-CENSUS" USING WS-I(1) WS-NM WS-R(1)',1,[(n,h) for n,h in cr],lambda n,h:cen(n,h))
T(g,'update order checklist (2.6): flag 1 tells the neighbours with the old block; wire writes power with flag 2 only','CALL "RS1-DIR-ORDER" USING WS-I(1) WS-I(2) WS-R(1)',1,[(2,1),(2,6),(3,5),(1,1)],lambda k,i:(ORD[k][i-1],))
T(g,'experimental evaluator (2.7): used only when the redstone_experiments flag is enabled; the default flags (vanilla) leave it off','CALL "RS1-EXPERIMENTAL" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda f:(f,))
SU.write(g)
# ===== 3 Tick conventions
g=SU.gen(3,'Tick conventions','T0704','game ticks versus redstone ticks, the identity rule, the priorities and the order of ticks due together.')
T(g,'redstone tick (3): one redstone tick is 2 game ticks; the torch delay 2 and the repeater minimum are both one','CALL "RS1-GAME-TICKS" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(2,),(4,)],lambda r:(2*r,))
T(g,'due time (3): a tick scheduled at T with delay d runs in the drain of game tick T + d','CALL "RS1-DUE-TICK" USING WS-I(1) WS-I(2) WS-R(1)',1,[(100,2),(100,160),(5,0),(0,1)],lambda t,d:(t+d,))
T(g,'identity (3): a pending tick for the same block at the same position is not added again (1 added, 0 ignored)','CALL "RS1-SCHEDULE-NEW" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda p:(int(not p),))
PN=['EXTREMELY_HIGH','VERY_HIGH','HIGH','NORMAL','LOW','VERY_LOW','EXTREMELY_LOW']
T(g,'priorities (3): EXTREMELY_HIGH -3, VERY_HIGH -2, HIGH -1, NORMAL 0, LOW 1, VERY_LOW 2, EXTREMELY_LOW 3; the blocks of part 1 use NORMAL','CALL "RS1-PRIORITY-VALUE" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(1,8)],lambda i:(i-4,))
def before(pa,sa,pb,sb):
    return int((pa,sa)<(pb,sb))
T(g,'order within one game tick (3): lower priority first, then the sub-tick order (the order scheduled); 1 when the first runs first','CALL "RS1-TICK-BEFORE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(0,5,0,6),(0,6,0,5),(-3,9,0,1),(0,1,-1,9),(2,3,2,3)],before)
T(g,'torch queue guard (3, 8.3): the torch queues at most one tick, tested with willTickThisTick (1 queue, 0 not)','CALL "RS1-SCHEDULE-NEW" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda p:(int(not p),))
SU.write(g)
# ===== 4 Doc schemas, ids and delays
g=SU.gen(4,'Doc schemas, ids and delays','T0706','the id table, the wire state index, the torch, ore and wall torch state ids and the delay table.')
IDS=[(246,5567,1296),(320,8551,2),(321,8553,2),(322,8555,2),(323,8557,8),(439,13078,1)]
T(g,'block rows (4.3): redstone_wire 246 5567 1296, redstone_ore 320 8551 2, deepslate_redstone_ore 321 8553 2, redstone_torch 322 8555 2, redstone_wall_torch 323 8557 8, redstone_block 439 13078 1','CALL "RS1-BLOCK-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(i,) for i in range(1,7)],lambda i:IDS[i-1])
def wst(n,e,s,w,p): return 5567+e*432+n*144+p*9+s*3+w
WS_=[(2,2,2,2,0),(0,0,0,0,0),(1,1,1,1,15),(0,1,2,1,7),(2,0,1,2,3),(1,2,0,1,14)]
T(g,'wire state id (4.3): 5567 + east * 432 + north * 144 + power * 9 + south * 3 + west with side digits up 0, side 1, none 2; the default (all none, power 0) is 6727','CALL "RS1-WIRE-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,WS_,lambda *a:(wst(*a),))
T(g,'wire state decode (4.3): the inverse of the index formula, in the order north east south west power','CALL "RS1-WIRE-DECODE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(wst(*a),) for a in WS_],lambda s:(((s-5567)//144)%3,(s-5567)//432,((s-5567)//3)%3,(s-5567)%3,((s-5567)//9)%16))
T(g,'torch, ore and deepslate ore ids (4.3): lit is the first state: torch 8555 lit and 8556 unlit, ore 8551 and 8552, deepslate 8553 and 8554','CALL "RS1-LIT-STATE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(k,l) for k in (1,2,3) for l in (0,1)],lambda k,l:({1:8555,2:8551,3:8553}[k]+(0 if l else 1),))
FO=[N,S_,W,E]
T(g,'wall torch id (4.3): 8557 + facing index * 2 + (lit ? 0 : 1) with the facing order north, south, west, east (default north lit 8557)','CALL "RS1-WALL-TORCH-STATE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(f,l) for f in FO for l in (0,1)],lambda f,l:(8557+FO.index(f)*2+(0 if l else 1),))
DT=[(2,0),(160,0),(-1,0),(-1,0)]
T(g,'delay table (4.4): torch re-check 2 NORMAL, torch restart 160 NORMAL, wire none, redstone block and ore none (-1 for none, priority 0 for NORMAL)','CALL "RS1-DELAY-ROW" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(1,5)],lambda i:DT[i-1])
SU.write(g)
# ===== 5 Redstone wire
import random
RNG=random.Random(5)
g=SU.gen(5,'Redstone wire','T0708','connection sides, the connection state, survival and shape updates, the power computation, the update order, the hooks, the outputs, particles, colours and shapes.',' 01 WS-FL                 FLOAT-LONG.\n')
SIDES=(0,1,2)
T(g,'side connected (5.1): up and side are connected, none is not','CALL "RS1-SIDE-CONNECTED" USING WS-I(1) WS-R(1)',1,[(s,) for s in SIDES],lambda s:(int(s!=2),))
T(g,'allowUp (5.2): the block above is not a redstone conductor','CALL "RS1-ALLOW-UP" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda c:(int(not c),))
def cside(allowUp,supports,connAbove,sturdy,shouldConn,conductor,connBelow):
    if allowUp and supports and connAbove: return 0 if sturdy else 1
    if shouldConn or (not conductor and connBelow): return 1
    return 2
cs=[(1,1,1,1,0,0,0),(1,1,1,0,0,0,0),(1,0,1,1,1,0,0),(1,1,0,1,0,1,0),(0,1,1,1,0,0,0),(0,1,1,1,1,0,0),(0,0,0,0,0,0,1),(0,0,0,0,0,1,1),(0,0,0,0,0,0,0),(1,1,0,0,0,0,1),(0,0,0,0,1,1,0)]
T(g,'getConnectingSide (5.2): a climb (supports and the cell above N connects) gives up when the face towards P is sturdy else side; otherwise side for a connecting block or a non-conductor with a wire diagonally below; else none','CALL "RS1-CONNECTING-SIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1,cs,lambda *a:(cside(*a),))
def missing(cur,comp): return tuple(c if c!=2 else m for c,m in zip(cur,comp))
mc=[((2,2,2,2),(1,2,0,2)),((1,2,2,0),(0,0,1,1)),((2,2,2,2),(2,2,2,2)),((0,1,0,1),(2,2,2,2)),((2,1,2,2),(1,0,1,1))]
T(g,'getMissingConnections (5.2): a side that is already connected stays, the others take the freshly resolved side','CALL "RS1-MISSING-CONNECTIONS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[a+b for a,b in mc],lambda *v:missing(v[:4],v[4:]))
def conn(wasDot,n,e,s,w):
    if wasDot and all(x==2 for x in (n,e,s,w)): return (n,e,s,w)
    cn,ce,cs_,cw_=[x!=2 for x in (n,e,s,w)]
    noNS=not cn and not cs_; noEW=not ce and not cw_
    N_,E_,S__,W_=n,e,s,w
    if not cw_ and noNS: W_=1
    if not ce and noNS: E_=1
    if not cn and noEW: N_=1
    if not cs_ and noEW: S__=1
    return (N_,E_,S__,W_)
cn_=[(0,2,2,2,2),(1,2,2,2,2),(0,2,1,2,2),(0,2,2,0,2),(0,1,2,1,2),(0,0,0,2,2),(0,2,2,2,0),(1,1,2,2,2),(0,1,1,1,1),(0,2,0,2,1),(0,1,2,2,2)]
T(g,'getConnectionState (5.2): a dot stays a dot; a wire with no connection becomes a cross; one side only gets a stub on the opposite side so a line shows both arms (wasDot then the resolved north, east, south, west)','CALL "RS1-CONNECTION-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,cn_,conn)
T(g,'is a dot (5.2 step 1): all four sides none','CALL "RS1-IS-DOT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(2,2,2,2),(1,2,2,2),(2,2,2,0)],lambda *a:(int(all(x==2 for x in a)),))
T(g,'placement (5.3): the cross state is not a dot, so with no neighbours the result is a cross (all four side) and a lever on the east gives a straight line (9.4)','CALL "RS1-CONNECTION-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,2,2,2,2),(0,2,1,2,2)],conn)
T(g,'survival (5.3): the top face of the block below is sturdy, or it is a hopper','CALL "RS1-WIRE-SURVIVE-ON" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(a or b),))
def wsu(d,canOn,side,stateD,cross):
    if d==0: return 1 if canOn else 0
    if d==1: return 2
    return 3 if ((side!=2)==(stateD!=2) and not cross) else 4
SUR=[(0,1,2,2,0),(0,0,2,2,0),(1,1,2,2,0),(2,1,1,2,0),(2,1,1,0,0),(3,1,2,2,0),(4,1,2,1,0),(5,1,1,1,1),(2,1,1,1,1),(5,1,0,2,0)]
T(g,'updateShape (5.3): down gives air without support else the state (1 state, 0 air); up re-resolves (2); a horizontal change with the same connected status and no cross is a local update (3); otherwise the resolved cross state (4)','CALL "RS1-WIRE-UPDATE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,SUR,lambda *a:(wsu(*a),))
def ind(side,nw,bw,aw):
    if side!=2 and not nw: return (int(bw),int(aw))
    return (0,0)
T(g,'updateIndirectNeighbourShapes (5.3): a connected side towards a non-wire block sends a shape change to the wire below and above that block (below, above)','CALL "RS1-WIRE-INDIRECT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(1,0,1,1),(0,0,1,0),(2,0,1,1),(1,1,1,1),(1,0,0,1),(1,0,1,0)],ind)
def use(mb,cr,dot,diff): return (1 if mb and (cr or dot) and diff else 0,)
T(g,'use (5.3): PASS (0) without the build ability; a cross or a dot whose new state differs gives SUCCESS (1)','CALL "RS1-WIRE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(0,1,0,1),(1,1,0,1),(1,0,1,1),(1,0,0,1),(1,1,0,0),(1,0,1,0)],use)
T(g,'use template (5.3): a cross becomes the default state (dot), a dot the cross state','CALL "RS1-WIRE-USE-TEMPLATE" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda c:(0 if c else 1,))
T(g,'updatesOnShapeChange (5.3): a changed connected status towards a conductor tells that conductor except from the wire','CALL "RS1-WIRE-SHAPE-NOTIFY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(0,1,1),(1,0,1),(1,1,1),(0,0,1),(0,1,0)],lambda o,n,c:(int(o!=n and c),))
def rot(n,e,s,w,r):
    if r==0: return (n,e,s,w)
    if r==1: return (w,n,e,s)
    if r==2: return (e,s,w,n)
    return (s,w,n,e)
def mir(n,e,s,w,m):
    if m==0: return (n,e,s,w)
    if m==1: return (s,e,n,w)
    return (n,w,s,e)
RS_=[(0,1,2,2),(1,2,0,2),(2,2,2,1)]
T(g,'rotation (5.3): clockwise 90 moves north to east, east to south, south to west, west to north; counter-clockwise 90 the other way; 180 swaps north with south and east with west (0 none, 1 cw90, 2 ccw90, 3 cw180)','CALL "RS1-WIRE-ROTATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[a+(r,) for a in RS_ for r in range(4)],rot)
T(g,'mirror (5.3): left-right swaps north and south, front-back swaps east and west; power untouched (0 none, 1 left-right, 2 front-back)','CALL "RS1-WIRE-MIRROR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[a+(m,) for a in RS_ for m in range(3)],mir)
def inc_step(r,pn,nc,ac,pa,pb):
    r=max(r,pn)
    if nc and not ac: r=max(r,pa)
    elif not nc: r=max(r,pb)
    return r
ST=[(0,5,0,0,9,9),(0,5,1,0,9,3),(0,5,1,1,9,3),(7,0,0,0,0,12),(7,0,1,1,14,14),(0,0,0,0,4,11),(2,2,1,0,2,2)]
T(g,'incoming wire signal step (5.4 step 2): the neighbour wire power, the wire on top of an adjacent conductor when the cell above P is free, else the wire diagonally below an adjacent non-conductor','CALL "RS1-WIRE-INCOMING-STEP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1,ST,lambda *a:(inc_step(*a),))
T(g,'incoming wire signal end (5.4 step 2): max(0, r - 1)','CALL "RS1-WIRE-INCOMING-END" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(15,),(14,)],lambda r:(max(0,r-1),))
T(g,'target (5.4 step 1): 15 from a block signal of 15, else the larger of the block signal and the incoming wire signal (9.1: 15, 14, 13)','CALL "RS1-WIRE-TARGET" USING WS-I(1) WS-I(2) WS-R(1)',1,[(15,3),(0,14),(0,0),(4,9),(9,4),(15,15)],lambda b,i:(15 if b==15 else max(b,i),))
def apply_(t,st,same): return (int(t!=st),int(t!=st and same),7 if t!=st else 0)
T(g,'apply (5.4 step 3): a changed target writes with flag 2 only while the block is still the same state and then updates seven positions; an unchanged target does nothing (changed, written, positions told)','CALL "RS1-WIRE-APPLY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,[(15,0,1),(14,15,1),(3,3,1),(0,5,0),(0,0,0)],apply_)
def jorder(x,y,z):
    pos=[(x,y,z)]+[(x+STEP[d][0],y+STEP[d][1],z+STEP[d][2]) for d in range(6)]
    def bucket(p):
        h=(((p[1]+p[2]*31)*31+p[0]))&0xFFFFFFFF
        return (h^(h>>16))&15
    idx=sorted(range(7),key=lambda i:(bucket(pos[i]),i))
    return tuple(-1 if i==0 else i-1 for i in idx)
CO=[(5,64,3),(0,0,0),(-5,64,-3),(30000000,319,-30000000),(-29999999,-64,29999999),(1000,70,-2000),(123456,12,654321),(-1,-1,-1)]
T(g,'update order (5.4 step 4, 9.2): the seven positions P and the six neighbours in the Java HashSet order of BlockPos (y + z * 31) * 31 + x, 16 buckets, spread h ^ (h >>> 16), insertion order inside a bucket (-1 is P, 0 to 5 the directions)','CALL "RS1-WIRE-NOTIFY-ORDER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)',7,CO,jorder)
T(g,'worked example (9.2): at (5, 64, 3) the calls are UP, NORTH, WEST, P, DOWN, SOUTH, EAST','CALL "RS1-WIRE-NOTIFY-ORDER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)',7,[(5,64,3)],lambda *a:(1,2,4,-1,0,3,5))
T(g,'onPlace (5.5): nothing when the old state is the same block or on a client; otherwise evaluate (1) then update UP and DOWN, then the neighbouring wires','CALL "RS1-WIRE-ON-PLACE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(0,0),(1,0),(0,1),(1,1)],lambda same,cl:(int(not same and not cl),))
T(g,'removal (5.5): nothing when moved by a piston; otherwise update the six neighbours, evaluate, then the neighbouring wires','CALL "RS1-WIRE-REMOVAL" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda m:(int(not m),))
T(g,'neighborChanged (5.5): nothing on a client; a wire that can survive re-evaluates (1); one that cannot drops its resources and is removed (2)','CALL "RS1-WIRE-NEIGHBOR" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,1),(1,0),(0,1),(0,0)],lambda cl,s:(0 if cl else (1 if s else 2),))
T(g,'corner target (5.5): next to a conductor the wire above it is checked (1), otherwise the wire below (0)','CALL "RS1-WIRE-CORNER-TARGET" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda c:(int(c),))
T(g,'checkCornerChangeAt (5.5): nothing when the block is not wire, else updateNeighborsAt at the cell and at its six neighbours (calls)','CALL "RS1-WIRE-CHECK-CORNER" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda w:(7 if w else 0,))
def wsig(fl,d,p,sc):
    if fl==0 or d==0 or p==0: return 0
    if d==1: return p
    return p if sc else 0
WG=[(0,2,9,1),(1,0,9,1),(1,2,0,1),(1,1,9,0),(1,2,9,1),(1,2,9,0),(1,3,15,1),(1,4,1,1),(1,5,14,0)]
T(g,'getSignal (5.6): 0 while shouldSignal is false, towards DOWN or with power 0; the power towards UP; horizontally the power when the side facing the receiver is connected (flag, direction, power, connected)','CALL "RS1-WIRE-GET-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,WG,lambda *a:(wsig(*a),))
T(g,'getDirectSignal, ownSignal, isSignalSource (5.5, 5.6): the direct signal is the same value as getSignal; isSignalSource answers the shouldSignal flag; the own signal is the stored power','CALL "RS1-WIRE-SOURCE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(0,7),(1,7),(1,0)],lambda f,p:(f,p))
T(g,'wire connects always (5.6): shouldRedstoneWireConnectTo of wire is true','CALL "RS1-WIRE-CONNECTS" USING WS-R(1)',1,[(0,)],lambda x:(1,))
def pcalls(p,s):
    if p==0: return (0,0,0,0,0,0,0)
    if s==0: return (2,1,-5,5,0,0,5)
    if s==1: return (1,0,0,5,0,0,0)
    return (1,0,0,3,0,0,0)
T(g,'animateTick (5.7): nothing at power 0; per side up two line calls (UP over -0.5 to 0.5, then DOWN over 0.0 to 0.5), side one DOWN call (0.0 to 0.5), none one DOWN call (0.0 to 0.3); values in tenths: calls, then direction (1 up, 0 down), from, to for each','CALL "RS1-WIRE-PARTICLE-CALLS" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)',7,[(p,s) for p in (0,9) for s in SIDES],pcalls)
def line(r1,fr,to,r2):
    r1,fr,to,r2=[f32(x) for x in (r1,fr,to,r2)]
    ln=f32(to-fr); lim=f32(f32(0.2)*ln)
    if not lim>r1: return (0,0)
    t=f32(fr+f32(r2*ln))
    return (1,round(t*1000000))
LN=[(0.0,0.0,1.0,0.3),(0.19999,-0.5,0.5,0.4),(0.2,0.0,1.0,0.4),(0.1,0.0,0.5,0.4),(0.09999,0.0,0.5,0.25),(0.5,0.0,0.5,0.0),(0.05,0.0,0.3,0.5)]
g.run('line spawner (5.7): the first nextFloat is the chance test, the particle is made only below 0.2 * len; the second nextFloat gives t = from + r2 * len in single precision (spawn, t in millionths)',[S(*[repr(f32(x)) for x in l]) for l in LN],'CALL "RS1-WIRE-LINE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-R(1) WS-R(2)',2," ".join(show(line(*l)) for l in LN))
def ppos(px,py,pz,da,db,t):
    return tuple(round((p+0.5+0.4375*STEP[da][i]+t*STEP[db][i])*1000000) for i,p in enumerate((px,py,pz)))
PP=[(5,64,3,2,1,0.25),(0,0,0,5,0,0.125),(-3,70,8,4,0,-0.5),(10,10,10,0,3,0.4)]
g.run('particle position (5.7): P + 0.5 + 0.4375 * step(dirA) + t * step(dirB) per axis (millionths)',[S(*c[:5],"0")+" "+str(c[5]) for c in PP],'CALL "RS1-WIRE-PARTICLE-POS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-FX(7) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(ppos(*c)) for c in PP))
DOC="4C0000 700000 7A0000 840000 8E0000 990000 A30000 AD0000 B70000 C10000 CC0000 D60000 E00000 EA0600 F41B00 FF3200".split()
def color(p):
    F=f32(p/15)
    r=f32(f32(F*f32(0.6))+f32(0.4 if F>0 else 0.3)); gg=f32(f32(f32(F*F)*f32(0.7))-f32(0.5)); gg=min(1,max(0,gg)); b=f32(f32(f32(F*F)*f32(0.6))-f32(0.7)); b=min(1,max(0,b))
    return tuple(math.floor(f32(c*255)) for c in (r,gg,b))
for p in range(16): assert "%02X%02X%02X"%color(p)==DOC[p]
T(g,'colour table (5.7): the 16 colours, floor(c * 255) of red f * 0.6 + (f > 0 ? 0.4 : 0.3), green f * f * 0.7 - 0.5 and blue f * f * 0.6 - 0.7 clamped, f = power / 15 in single precision','CALL "RS1-WIRE-COLOR" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(p,) for p in range(16)],color)
def arm(k,d):
    bx=(3,0,0,13,1,8) if k==1 else (3,0,0,13,16,1)
    x0,y0,z0,x1,y1,z1=bx
    for _ in range({2:0,5:1,3:2,4:3}[d]):
        x0,z0,x1,z1=16-z1,x0,16-z0,x1
    return (x0,y0,z0,x1,y1,z1)
T(g,'arm boxes (5.1): the side arm box(3,0,0,13,1,8) and the up arm box(3,0,0,13,16,1) are given for north and rotated for east, south and west (arm 1 side, 2 up; direction 2 north, 5 east, 3 south, 4 west)','CALL "RS1-WIRE-ARM-BOX" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(a,d) for a in (1,2) for d in (2,5,3,4)],lambda a,d:arm(a if a==1 else 2,d))
T(g,'shape (5.1): the dot box(3,0,3,13,1,13) plus for each side nothing, the side arm or the side arm and the up arm; the number of boxes of a state, independent of power','CALL "RS1-WIRE-SHAPE-COUNT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(2,2,2,2),(1,2,2,2),(0,1,2,2),(0,0,0,0),(1,1,1,1)],lambda *a:(1+sum({0:2,1:1,2:0}[x] for x in a),))
T(g,'dot box (5.1): column(10, 0, 1) is box(3,0,3,13,1,13)','CALL "RS1-WIRE-DOT-BOX" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(0,)],lambda x:(3,0,3,13,1,13))
SU.write(g)
# ===== 6 Redstone block
g=SU.gen(6,'Redstone block','T0710','the two methods of PoweredBlock and its place in the signal queries.')
T(g,'PoweredBlock (6): isSignalSource, ownSignal 15, getSignal 15 in every direction including down, getDirectSignal 0, not a conductor, getControlInputSignal 15 (direction, then source, own, signal, direct, conductor, control input)','CALL "RS1-POWERED-BLOCK" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(d,) for d in range(6)],lambda d:(1,15,15,0,0,15))
T(g,'wire connects sideways (6): a signal source with a direction connects by the default hook','CALL "RS1-WIRE-CONNECT-DEFAULT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,1)],lambda a,b:(1,))
T(g,'chain (9.1): a wire next to the block reads 15, the next wire 14: the block signal 15 gives target 15; with no source the incoming 15 - 1 gives 14, then 13','CALL "RS1-WIRE-TARGET" USING WS-I(1) WS-I(2) WS-R(1)',1,[(15,0),(0,14),(0,13)],lambda b,i:(15 if b==15 else max(b,i),))
SU.write(g)
# ===== 7 Redstone ore
g=SU.gen(7,'Redstone ore','T0712','the lit state triggers, random tick, use result, experience and particle rules of the ore.')
T(g,'interact (7): spawnParticles, then a lit false ore becomes lit true (particles, set lit)','CALL "RS1-ORE-INTERACT" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda l:(1,int(not l)))
T(g,'stepOn (7): interact unless the entity steps carefully (sneaking)','CALL "RS1-ORE-STEP" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(int(not s),))
def oreuse(sv,bi,cp): return (int(sv),0 if (bi and cp) else 1)
T(g,'useItemOn (7): the server interacts, the client only spawns particles; the result is PASS (0) when the held item is a BlockItem that canPlace, else SUCCESS (1) (interact called, result)','CALL "RS1-ORE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,[(s,b,c) for s in (0,1) for b in (0,1) for c in (0,1)],lambda s,b,c:(int(s),0 if (b and c) else 1,1))
T(g,'random tick (7): isRandomlyTicking only when lit; randomTick sets lit false when lit (ticking, becomes unlit)','CALL "RS1-ORE-RANDOM" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda l:(l,l))
T(g,'animateTick (7): client particles when lit','CALL "RS1-ORE-ANIMATE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda l:(l,))
T(g,'spawnAfterBreak (7): with dropExperience the experience is UniformInt(1, 5) (min, max), otherwise none','CALL "RS1-ORE-XP" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda d:(1,5) if d else (0,0))
T(g,'spawnParticles faces (7): a face whose neighbour is solid-rendering is skipped; otherwise a random value is drawn for each axis that is not the face axis (draws)','CALL "RS1-ORE-DRAWS" USING WS-I(1) WS-I(2) WS-R(1)',1,[(d,s) for d in range(6) for s in (0,1)],lambda d,s:(0 if s else 2,))
def coord(m,st,r): return round((0.5+0.5625*st if m else r)*1000000)
OC=[(1,1,0.3),(1,-1,0.3),(0,1,0.3),(0,-1,0.8125)]
g.run('spawnParticles coordinate (7): on the face axis 0.5 + 0.5625 * step, else the random value (millionths)',[S(m,st,0)+" "+str(r) for m,st,r in OC],'CALL "RS1-ORE-COORD" USING WS-I(1) WS-I(2) WS-FX(4) WS-R(1)',1," ".join(show(coord(*c)) for c in OC))
T(g,'ore lit states (4.3, 7): lit is the first state; light 9 when lit','CALL "RS1-LIT-STATE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(2,1),(2,0),(3,1),(3,0)],lambda k,l:({2:8551,3:8553}[k]+(0 if l else 1),))
SU.write(g)
# ===== 8 Redstone torches
g=SU.gen(8,'Redstone torches','T0714','the torch input, outputs, flip decision, tick, the toggle list and burnout, the effects and particles.',TBL('PT',64)+TBL('TM',64)+" 01 WS-X                  BINARY-LONG.\n 01 WS-NN                 BINARY-LONG.\n 01 WS-TOO                BINARY-LONG.\n")
T(g,'input direction (8.3): a standing torch asks the block below (DOWN), a wall torch the block it is attached to (opposite of facing); kind 1 standing, 2 wall','CALL "RS1-TORCH-INPUT-DIR" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,2),(2,2),(2,3),(2,4),(2,5)],lambda k,f:(0 if k==1 else opp(f),))
def tsig(k,f,lit,d):
    own=15 if lit else 0
    gs=0 if (d==1 if k==1 else d==f) else own
    dr=gs if d==0 else 0
    return (own,gs,dr)
TS=[(k,f,l,d) for k in (1,2) for f in ((2,) if k==1 else (2,3,4,5)) for l in (0,1) for d in range(6)]
T(g,'torch outputs (8.3): own 15 when lit; getSignal is the own signal except UP for a standing torch and towards facing for a wall torch; getDirectSignal is getSignal for DOWN only','CALL "RS1-TORCH-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,TS,tsig)
T(g,'neighborChanged (8.3): a lit torch with a powered input, or an unlit one without, wants to flip: one tick 2 ahead unless one is due this tick (lit, powered, due this tick; schedule, delay)','CALL "RS1-TORCH-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(l,p,w) for l in (0,1) for p in (0,1) for w in (0,1)],lambda l,p,w:((1,2) if (l==p and not w) else (0,0)))
T(g,'tick step A (8.3 steps 3 and 4): a lit torch with power turns off and records the toggle (1); an unlit one without power checks the list (2); otherwise nothing (0)','CALL "RS1-TORCH-TICK-A" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,1),(1,0),(0,0),(0,1)],lambda l,p:(1 if (l and p) else (2 if (not l and not p) else 0),))
def tickb(a,too):
    if a==1: return (0,int(too),160 if too else 0)
    return (int(not too),0,0)
T(g,'tick step B (8.3): after the recording a torch that toggled too often shows the burnout (level event 1502) and queues a tick 160 ahead; an unlit torch lights unless it toggled too often (action, too often; set lit, burnout, delay)','CALL "RS1-TORCH-TICK-B" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(1,0),(1,1),(2,0),(2,1)],tickb)
def prune(now,times):
    t=list(times)
    while t and now-t[0]>60: t.pop(0)
    return t
def listcall(entries,now,pos):
    s="MOVE %d TO WS-NN\n"%len(entries)+setarr('PT',[e[0] for e in entries])+setarr('TM',[e[1] for e in entries])
    return s
PR=[([(1,100),(1,130),(2,150)],160),([(1,100),(1,130),(2,150)],161),([(1,100),(1,130),(2,150)],210),([(1,100),(1,130),(2,150)],191),([],5),([(3,10)],70),([(3,10)],71)]
cs_=[]
for ent,now in PR:
    call=listcall(ent,now,0)+'MOVE %d TO WS-I(1)\nCALL "RS1-TORCH-PRUNE" USING WS-I(1) WS-NN WS-PTG WS-TMG\nMOVE WS-NN TO WS-R(1)\nMOVE 0 TO WS-R(2)\nIF WS-NN > 0\nMOVE WS-PT(1) TO WS-R(2)\nEND-IF'%now
    cs_.append(("0",call,2))
g.case('prune (8.3 step 2): while the list is not empty and gameTime - first.when is more than 60 the first entry is removed (a window of exactly 60 stays); entries are (position, time) (count left, position of the first)',cs_," ".join(show(len(prune(n,[e[1] for e in ent])),(ent[len(ent)-len(prune(n,[e[1] for e in ent]))][0] if prune(n,[e[1] for e in ent]) else 0)) for ent,n in PR))
cs_=[];ex=[]
for ent,pos in [([(1,10)]*7,1),([(1,10)]*8,1),([(1,10)]*7+[(2,11)]*3,1),([(2,10)]*8+[(1,11)],1),([],1),([(1,10)]*3,2)]:
    call=listcall(ent,0,0)+'MOVE %d TO WS-I(1)\nCALL "RS1-TORCH-COUNT" USING WS-I(1) WS-NN WS-PTG WS-R(1) WS-R(2)'%pos
    cs_.append(("0",call,2)); c=sum(1 for e in ent if e[0]==pos); ex.append(show(c,int(c>=8)))
g.case('count (8.3): the entries of the whole list whose position equals this position; too often when the count reaches 8',cs_," ".join(ex))
def clock(P,pos=1):
    # worked example 9.3: off transitions at 102 + k * P; returns (count after 8th, too often, ...)
    times=[];out=None
    for k in range(8):
        t=102+k*P; times=prune(t,times); times.append(t)
    return len(times),int(len(times)>=8),102+7*P+160
CL=[]
for P in (8,4):
    loop='MOVE 0 TO WS-NN\nPERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 7\nCOMPUTE WS-I(2) = 102 + WS-X * %d\nCALL "RS1-TORCH-PRUNE" USING WS-I(2) WS-NN WS-PTG WS-TMG\nCALL "RS1-TORCH-RECORD" USING WS-I(1) WS-I(2) WS-NN WS-PTG WS-TMG\nEND-PERFORM\nCALL "RS1-TORCH-COUNT" USING WS-I(1) WS-NN WS-PTG WS-R(1) WS-R(2)\nCALL "RS1-TORCH-TICK-B" USING WS-I(3) WS-R(2) WS-R(3) WS-R(4) WS-R(5)\nCOMPUTE WS-R(6) = WS-I(2) + WS-R(5)'%P
    CL.append(("1 0 1",loop,6))
g.case('burnout (8.3, 9.3): off transitions every 8 ticks from 102 record 8 entries inside the window, the 8th recording at 158 reports too often, the burnout shows and a tick is queued for 158 + 160 = 318; with spacing 4 the same rule gives 130 and 290 (count, too often, set lit, burnout, delay, tick time)',CL,"8/1/0/1/160/318 8/1/0/1/160/290")
g.case('retry (8.3, 9.3): at 318 the list is pruned (all entries older than 60), the count is 0 and the unlit torch lights',[("1 318 2",'MOVE 8 TO WS-NN\n'+setarr('PT',[1]*8)+setarr('TM',[102+8*k for k in range(8)])+'CALL "RS1-TORCH-PRUNE" USING WS-I(2) WS-NN WS-PTG WS-TMG\nCALL "RS1-TORCH-COUNT" USING WS-I(1) WS-NN WS-PTG WS-R(1) WS-R(2)\nCALL "RS1-TORCH-TICK-B" USING WS-I(3) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5)],"0/0/1/0/0")
T(g,'wall torch updateShape (8.1): the update from the side opposite to facing with a state that cannot survive gives air (1), anything else the state (0)','CALL "RS1-WALL-TORCH-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(3,2,0),(3,2,1),(2,2,0),(4,5,0),(4,5,1)],lambda d,f,c:(int(d==opp(f) and not c),))
T(g,'notifyNeighbors (8.2): onPlace always and removal when it is not a piston move; the six calls go DOWN, UP, NORTH, SOUTH, WEST, EAST (announce; first and last direction of the order)','CALL "RS1-TORCH-NOTIFY" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,0),(1,1),(0,0),(0,1)],lambda p,m:(int(p or not m),))
g.run('burnout effect (8.5): level event 1502, sound volume 0.5 (x 100), 5 smoke particles',["0"],'CALL "RS1-BURNOUT-EFFECT" USING WS-R(1) WS-R(2) WS-R(3)',3,"1502/50/5")
BP=[(0.5,0.5),(0.9,0.1),(0.1,0.9),(0.0,1.0),(0.75,0.25)]
g.run('burnout pitch (8.5): 2.6 + (random.nextFloat() - random.nextFloat()) * 0.8, the first draw minus the second (millionths)',[S(0,0,0)+" "+str(a)+" "+str(b) for a,b in BP],'CALL "RS1-BURNOUT-PITCH" USING WS-FX(4) WS-FX(5) WS-R(1)',1," ".join(show(round((2.6+(a-b)*0.8)*1000000)) for a,b in BP))
SM=[(10,64,3,0.1,0.2,0.3),(0,0,0,0.0,0.5,1.0),(-4,70,9,0.75,0.25,0.5)]
g.run('burnout smoke (8.5): each axis is pos + nextDouble * 0.6 + 0.2, drawn x then y then z (millionths)',[S(*c[:3])+" "+" ".join(str(x) for x in c[3:]) for c in SM],'CALL "RS1-BURNOUT-SMOKE" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*[round((c[i]+c[3+i]*0.6+0.2)*1000000) for i in range(3)]) for c in SM))
def tpart(k,f,x,y,z,r1,r2,r3):
    px=x+0.5+(r1-0.5)*0.2; py=y+0.7+(r2-0.5)*0.2; pz=z+0.5+(r3-0.5)*0.2
    if k==2:
        d=opp(f); px+=0.27*STEP[d][0]; py+=0.22; pz+=0.27*STEP[d][2]
    return tuple(round(v*1000000) for v in (px,py,pz))
TP=[(1,2,5,64,3,0.1,0.2,0.3),(2,2,5,64,3,0.1,0.2,0.3),(2,5,-1,70,2,0.9,0.4,0.6),(2,4,0,0,0,0.3,0.3,0.7),(2,3,7,7,7,0.2,0.8,0.2)]
g.run('torch particles (8.6): a lit standing torch spawns at x + 0.5 + (r1 - 0.5) * 0.2, y + 0.7 + (r2 - 0.5) * 0.2, z + 0.5 + (r3 - 0.5) * 0.2; a wall torch adds 0.27 * the opposite-of-facing step on x and z and 0.22 on y (millionths)',[S(*c[:5])+" "+" ".join(str(x) for x in c[5:]) for c in TP],'CALL "RS1-TORCH-PARTICLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-FX(6) WS-FX(7) WS-FX(8) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(tpart(*c)) for c in TP))
SU.write(g)
