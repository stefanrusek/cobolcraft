import sys
sys.path.insert(0,'core/tests/gen')
from gen30c import *
SU=Suite(2,'30-2','RS1-','redstone-30-2.cob',[int(a) for a in sys.argv[1:]])
HOR=[N,E,S_,W]
# ===== 1
g=SU.gen(1,'The signal API and update primitives these blocks use','T0716','the level queries as the diodes read them, the update primitives and updateNeighborsInFront.')
def dst(*v):
    r=0;n=0
    for x in v:
        n+=1; r=max(r,x)
        if r>=15: return r,n
    return r,n
V6=[(0,0,0,0,0,0),(3,0,9,0,0,2),(15,1,2,3,4,5),(0,0,0,0,0,15),(2,4,6,9,8,7)]
T(g,'getDirectSignalTo (1.1): maximum of D U N S W E with an early exit on 15','CALL "RS1-DIRECT-SIGNAL-TO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,dst)
T(g,'getSignal (1.1): a conductor gives max(s, getDirectSignalTo), else s','CALL "RS1-LEVEL-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(s,c,t) for s in (0,7) for c in (0,1) for t in (0,9)],lambda s,c,t:(max(s,t) if c else s,))
T(g,'getBestNeighborSignal (1.1): maximum over D U N S W E, 15 at once','CALL "RS1-BEST-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,dst)
def hasn(*v):
    for i,x in enumerate(v):
        if x>0: return 1,i+1
    return 0,0
T(g,'hasNeighborSignal (1.1): true at the first of D U N S W E above 0','CALL "RS1-HAS-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,V6,hasn)
T(g,'hasSignal and getBestOwnOrNeighbourSignal (1.1)','CALL "RS1-BEST-OWN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(b,s,o) for b in (0,6) for s in (0,1) for o in (0,9)],lambda b,s,o:(max(b,o if s else 0),))
def cis(od,dio,rb,wire,wp,src,dr):
    if od: return dr if dio else 0
    if rb: return 15
    if wire: return wp
    if src: return dr
    return 0
T(g,'getControlInputSignal (1.1): diodes only reads a diode direct signal; otherwise 15 for a redstone block, the wire power, the direct signal of a source','CALL "RS1-CONTROL-INPUT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1,[(1,1,0,0,0,0,7),(1,0,0,0,0,1,7),(0,0,1,0,0,0,3),(0,0,0,1,9,0,3),(0,0,0,0,0,1,12),(0,0,0,0,0,0,12)],cis)
T(g,'update order (1.2): updateNeighborsAt tells W E D U N S','CALL "RS1-DIR-ORDER" USING WS-I(1) WS-I(2) WS-R(1)',1,[(2,i) for i in range(1,7)],lambda k,i:([W,E,D,U,N,S_][i-1],))
T(g,'priorities (1.2): EXTREMELY_HIGH -3, VERY_HIGH -2, HIGH -1, NORMAL 0','CALL "RS1-PRIORITY-VALUE" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(1,5)],lambda i:(i-4,))
T(g,'identity (1.2): a pending tick for the same block and position is ignored','CALL "RS1-SCHEDULE-NEW" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda p:(int(not p),))
T(g,'updateNeighborsInFront (1.3): the output cell is pos + opp(f) as an offset, the skipped direction is f (dx dy dz skip)','CALL "RS1-FRONT-CELL" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(f,) for f in range(2,6)],lambda f:STEP[opp(f)]+(f,))
SU.write(g)
# ===== 2
g=SU.gen(2,'Diode base logic','T0718','placement, survival, input and side signals, outputs, prioritisation, scheduling and the tick.')
T(g,'placement (2.1): facing is the opposite of the horizontal direction of the player','CALL "RS1-DIODE-PLACE" USING WS-I(1) WS-R(1)',1,[(d,) for d in HOR],lambda d:(opp(d),))
T(g,'survival (2.1): the top face of the block below is sturdy with support type RIGID','CALL "RS1-DIODE-SURVIVE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(a and b),))
T(g,'getInputSignal (2.2.1): a signal of 15 or more is returned as is, otherwise the larger of the signal and the wire power','CALL "RS1-DIODE-INPUT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(15,3),(15,0),(4,9),(9,4),(0,0),(0,7),(14,15)],lambda s,w:(s if s>=15 else max(s,w),))
T(g,'side cells (2.2.2): cw(facing) and ccw(facing) seen from above (cw(N) = E)','CALL "RS1-DIODE-SIDES" USING WS-I(1) WS-R(1) WS-R(2)',2,[(d,) for d in HOR],lambda d:(cw(d),ccw(d)))
T(g,'getAlternateSignal (2.2.2): the larger of the two control inputs','CALL "RS1-DIODE-ALT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(0,0),(3,0),(0,4),(9,2)],lambda a,b:(max(a,b),))
T(g,'shouldTurnOn and getOutputSignal (2.2.3, 2.2.4): input above 0; output 15','CALL "RS1-DIODE-TURNON" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,),(15,)],lambda i:(int(i>0),15))
def dsig(p,o,d,f):
    own=o if p else 0
    s=own if d==f else 0
    return own,s,s
T(g,'ownSignal, getSignal, getDirectSignal (2.2.5): the output when powered; towards facing only (powered, output, direction asked, facing)','CALL "RS1-DIODE-OUTPUT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,[(p,15,d,2) for p in (0,1) for d in (2,3)]+[(1,9,4,4),(1,9,5,4)],dsig)
T(g,'shouldPrioritize (2.2.6): the output-side block is a diode that does not face away (its facing is not opp(facing)); args: is a diode, its facing, own facing','CALL "RS1-DIODE-PRIORITIZE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,2,2),(1,3,2),(1,4,2),(0,2,2),(0,3,2)],lambda dio,nf,f:(int(dio and nf!=opp(f)),))
T(g,'isLocked (2.2.7): the base class is never locked','CALL "RS1-DIODE-LOCKED" USING WS-R(1)',1,[(0,)],lambda x:(0,))
def chk(lk,on,want,will,pri):
    if lk or on==want or will: return (0,0)
    return (1,-3 if pri else (-2 if on else -1))
T(g,'checkTickOnNeighbor (2.3): nothing when locked, when on equals want, or when a tick is due this tick; else the priority EXTREMELY_HIGH when prioritised, VERY_HIGH when on, otherwise HIGH (schedule, priority)','CALL "RS1-DIODE-CHECK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,[(1,0,1,0,0),(0,1,1,0,0),(0,0,1,1,0),(0,0,1,0,1),(0,0,1,0,0),(0,1,0,0,0),(0,1,0,0,1)],chk)
T(g,'neighborChanged (2.3): not this block stops (0); a block that can survive checks the tick (1); otherwise it drops and is removed (2)','CALL "RS1-DIODE-NEIGHBOR" USING WS-I(1) WS-I(2) WS-R(1)',1,[(0,1),(1,1),(1,0)],lambda t,s:(0 if not t else (1 if s else 2),))
T(g,'setPlacedBy (2.3): when the block would turn on, a tick after 1 game tick with the default priority (schedule, delay)','CALL "RS1-DIODE-PLACED" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda w:((1,1) if w else (0,0)))
def dtick(lk,on,want):
    if lk: return (0,0)
    if on and not want: return (1,0)
    if not on: return (2,int(not want))
    return (0,0)
T(g,'tick (2.4): locked does nothing; on and not wanted turns off; off turns on and, when not wanted, schedules the end after one more delay with VERY_HIGH (action 1 off 2 on, schedule end)','CALL "RS1-DIODE-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,0,1),(0,1,0),(0,0,1),(0,0,0),(0,1,1)],dtick)
T(g,'hooks (2.5): onPlace tells the front; removal tells the front unless moved','CALL "RS1-TORCH-NOTIFY" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,0),(0,0),(0,1)],lambda p,m:(int(p or not m),))
SU.write(g)
# ===== 3
g=SU.gen(3,'Repeater','T0720','state counts, delay, use, locking, the shape update, wire connection and particles.')
T(g,'states (3.1): 64 states, defaults facing north, delay 1, locked false, powered false','CALL "RS1-REP-STATES" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(64,2,1,0,0))
T(g,'timing (3.2): getDelay is delay * 2 game ticks, output 15','CALL "RS1-REP-DELAY" USING WS-I(1) WS-R(1) WS-R(2)',2,[(d,) for d in (1,2,3,4)],lambda d:(2*d,15))
T(g,'use (3.6): without mayBuild PASS (0), else the delay cycles 1 2 3 4 1 and the result is SUCCESS (1); flags 3, no sound (result, new delay)','CALL "RS1-REP-USE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(0,2)]+[(1,d) for d in (1,2,3,4)],lambda m,d:(0,d) if not m else (1,d%4+1))
def lock(sd,sf,pw,dio,out):
    return out if (dio and pw and sf==sd) else 0
T(g,'locking (3.4): a side diode contributes its output only when its facing equals the direction from the repeater to it and it is powered (E4: X facing E locks, Y facing W does not); args direction to the side cell, its facing, powered, is a diode, its output','CALL "RS1-REP-LOCK-SIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(5,5,1,1,15),(5,4,1,1,15),(5,5,0,1,15),(5,5,1,0,15),(4,4,1,1,9)],lambda *a:(lock(*a),))
T(g,'isLocked (3.4): getAlternateSignal above 0','CALL "RS1-REP-IS-LOCKED" USING WS-I(1) WS-R(1)',1,[(0,),(15,),(3,)],lambda a:(int(a>0),))
def rsu(d,facing,canOn,server):
    if d==D and not canOn: return (0,0)
    if server and (d>>1 if d<2 else (0 if d>=4 else 1))!=(facing>>1 if facing<2 else (0 if facing>=4 else 1)): return (1,0)
    return (2,0)
def axis(d): return 1 if d<2 else (2 if d<4 else 0)
def rsu(d,facing,canOn,server):
    if d==D and not canOn: return (0,)
    if server and axis(d)!=axis(facing): return (1,)
    return (2,)
T(g,'updateShape (3.5): air when the block below cannot support (0); on a server a side neighbour (axis differs from facing) re-computes locked (1); otherwise unchanged (2)','CALL "RS1-REP-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(D,2,0,1),(D,2,1,1),(5,2,1,1),(4,2,1,0),(2,2,1,1),(3,3,1,1),(U,5,1,1)],rsu)
T(g,'wire connection (3.6): true when the direction is facing or its opposite','CALL "RS1-REP-WIRE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(2,2),(3,2),(4,2),(5,2),(4,5),(2,5)],lambda d,f:(int(d in (f,opp(f))),))
def rpar(x,y,z,f,delay,b,r1,r2,r3):
    off=(delay*2-1 if b else -5)
    px=x+0.5+(r1-0.5)*0.2+off/16*STEP[f][0]; py=y+0.4+(r2-0.5)*0.2; pz=z+0.5+(r3-0.5)*0.2+off/16*STEP[f][2]
    return tuple(round(v*1000000) for v in (px,py,pz))
RP=[(5,64,3,2,1,0,0.1,0.2,0.3),(5,64,3,2,4,1,0.1,0.2,0.3),(0,0,0,5,2,1,0.7,0.4,0.9),(-2,10,4,4,3,0,0.6,0.3,0.2)]
g.run('animateTick (3.6): x + 0.5 + (r1 - 0.5) * 0.2, y + 0.4 + (r2 - 0.5) * 0.2, z + 0.5 + (r3 - 0.5) * 0.2, then the offset -5 pixels, or delay * 2 - 1 when nextBoolean is true, divided by 16 along facing (millionths)',[S(*c[:6])+" "+" ".join(str(x) for x in c[6:]) for c in RP],'CALL "RS1-REP-PARTICLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-FX(7) WS-FX(8) WS-FX(9) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(rpar(*c)) for c in RP))
SU.write(g)
# ===== 4
g=SU.gen(4,'Comparator','T0722','states, the input rules, output and powered rules, checkTickOnNeighbor, the refresh, use, the item frame reading.')
T(g,'states (4.1): 16 states, delay 2 for every state, default facing north, mode compare, powered false','CALL "RS1-CMP-STATES" USING WS-R(1) WS-R(2) WS-R(3)',3,[(0,)],lambda x:(16,2,0))
MIN=-2147483648
def cin(inp,ah,av,cond,fr,fv,s2h,s2v):
    if ah: return av
    if inp<15 and cond:
        a=fv if fr==1 else MIN
        b=s2v if s2h else MIN
        m=max(a,b)
        if m!=MIN: return m
    return inp
CI=[(8,1,5,0,0,0,0,0),(8,0,0,1,1,4,0,0),(10,0,0,1,1,4,0,0),(15,0,0,1,1,4,0,0),(10,0,0,1,0,4,0,0),(10,0,0,1,2,4,0,0),(10,0,0,1,0,0,1,6),(10,0,0,1,1,0,1,6),(10,0,0,1,1,0,0,0),(10,0,0,0,1,4,0,0),(6,0,0,1,1,9,1,2)]
T(g,'getInputSignal (4.2): the analog output replaces the redstone input; through a conductor, with the input below 15, the item frame (exactly one) and the block two away replace it with the larger value even when lower (E8); args input, has analog, analog value, conductor, frames found, frame output, cell two has analog, its value','CALL "RS1-CMP-INPUT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1)',1,CI,lambda *a:(cin(*a),))
T(g,'item frame analog output (4.2): 0 when empty, otherwise (rotation mod 8) + 1','CALL "RS1-FRAME-ANALOG" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,0),(0,0),(0,3),(0,7),(0,8),(0,11)],lambda e,r:(0 if e else r%8+1,))
def cout(inp,side,mode):
    out=0 if inp==0 else (0 if side>inp else (inp-side if mode==1 else inp))
    on=0 if inp==0 else (1 if inp>side else (1 if inp==side and mode==0 else 0))
    return out,on
T(g,'output and powered (4.3, E5): rear 8 side 5 gives 8 compare, 3 subtract; side 8 gives 8 compare and 0 unpowered subtract; side 9 gives 0; rear 0 gives 0 (mode 0 compare 1 subtract; output, shouldTurnOn)','CALL "RS1-CMP-OUTPUT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(8,5,0),(8,5,1),(8,8,0),(8,8,1),(8,9,0),(8,9,1),(0,0,0),(0,3,1),(15,0,0)],cout)
def ccheck(will,new,old,pw,want,pri):
    if will: return (0,0,0)
    if new!=old or pw!=want: return (1,2,-1 if pri else 0)
    return (0,0,0)
T(g,'checkTickOnNeighbor (4.4): nothing when a tick is due this tick; a tick with delay 2 when the output or the powered flag would change, priority HIGH when prioritised, else NORMAL (schedule, delay, priority)','CALL "RS1-CMP-CHECK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3,[(1,5,0,0,1,0),(0,1,0,0,1,0),(0,5,5,1,1,0),(0,5,5,1,1,1),(0,5,5,0,1,1),(0,0,5,1,0,0),(0,5,5,1,0,0)],ccheck)
def cref(new,old,mode,on,want,ent):
    store=int(ent)
    if old==new and mode==1: return (store,1,0,0,0)
    sp=0
    if on and not want: sp=2
    elif not on and want: sp=1
    return (store,0,sp,1,0)
T(g,'refreshOutputState (4.5): the output is stored when the entity exists; subtract with an unchanged value stops; else powered is updated (1 on, 2 off) and the front is notified (E7); args new, old, mode, powered, want, entity (store, stop, powered change, notify)','CALL "RS1-CMP-REFRESH" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(5,5,0,1,1,1),(5,5,1,1,1,1),(5,5,1,0,1,1),(3,5,1,1,0,1),(0,5,0,1,0,1),(2,0,0,0,1,0),(2,0,1,0,0,1)],lambda *a:cref(*a)[:4])
T(g,'use (4.6): without mayBuild PASS; else the mode cycles and COMPARATOR_CLICK plays at volume 0.3, pitch 0.55 for subtract and 0.5 for compare (x 100); the refresh then runs at once (result, new mode, volume, pitch)','CALL "RS1-CMP-USE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,0),(1,0),(1,1)],lambda m,mode:(0,mode,0,0) if not m else (1,1-mode,30,55 if mode==0 else 50))
T(g,'setPlacedBy and persistence (4.5, 4.7): a tick after 1 game tick when it would turn on; the entity saves the int OutputSignal, default 0','CALL "RS1-DIODE-PLACED" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda w:((1,1) if w else (0,0)))
SU.write(g)
# ===== 5
g=SU.gen(5,'Analog output signal of every block that has one','T0724','the notification walk, the container fullness formula, the catalog rows and the fixed formulas.',TBL('CT',64)+TBL('LM',64)+NAME)
def nt(loaded,cmp_,cond,far):
    if not loaded: return 0
    if cmp_: return 1
    if cond and far: return 2
    return 0
T(g,'updateNeighbourForOutputSignal (5.1): per horizontal neighbour in the order N E S W, only when loaded; a comparator there is told (1); else a conductor with a comparator behind it tells that one (2)','CALL "RS1-OUTPUT-NOTIFY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(0,1,0,0),(1,1,0,0),(1,0,1,1),(1,0,1,0),(1,0,0,1),(1,1,1,1)],nt)
T(g,'horizontal order (5.1): N E S W','CALL "RS1-DIR-ORDER" USING WS-I(1) WS-I(2) WS-R(1)',1,[(4,i) for i in range(1,5)],lambda k,i:(HOR[i-1],))
def lerp(f):
    return math.floor(f32(f*14))+(1 if f>0 else 0)
def cont(slots):
    if not slots: return 0
    s=f32(0)
    for c,l in slots:
        if c>0: s=f32(s+f32(c/l))
    f=f32(s/len(slots))
    return lerp(f)
CC=[[(0,64)]*5,[(64,64)]*5,[(1,64)]*5,[(1,1)]*2+[(0,64)]*3,[(64,64)]*14+[(0,64)]*13,[(64,64)]*27,[(1,64)]+[(0,64)]*26,[(5,64),(3,16),(1,1),(0,64),(7,64),(2,64),(9,64),(64,64),(33,64)],[(1,64)]*54,[(1,99)]*9,[(30,64)]*3,[(0,64)]*3+[(12,64)]]
cs_=[];ex=[]
for sl in CC:
    cs_.append(("0",setarr('CT',[a for a,b in sl])+setarr('LM',[b for a,b in sl])+'MOVE %d TO WS-I(1)\nCALL "RS1-CONTAINER-SIGNAL" USING WS-I(1) WS-CTG WS-LMG WS-R(1)'%len(sl),1)); ex.append(show(cont(sl)))
g.case('container fullness (5.2, E10): sum of count / limit(i) in single precision, f = sum / size, result floor(f * 14) + (f > 0 ? 1 : 0); empty 0, one item 1, full 15, hopper of 64-stacks 15, two tools in five slots 6, 14 of 27 stacks 8',cs_," ".join(ex))
T(g,'no container (5.2): the result is 0','CALL "RS1-CONTAINER-SIGNAL" USING WS-I(1) WS-CTG WS-LMG WS-R(1)',1,[(0,)],lambda n:(0,))
AN=['ChestBlock','BarrelBlock','ShulkerBoxBlock','AbstractFurnaceBlock','BrewingStandBlock','HopperBlock','DispenserBlock','DecoratedPotBlock','CrafterBlock','ChiseledBookShelfBlock','JukeboxBlock','LecternBlock','CommandBlock','ComposterBlock','LayeredCauldronBlock','LavaCauldronBlock','CauldronBlock','CakeBlock','CandleCakeBlock','BeehiveBlock','EndPortalFrameBlock','RespawnAnchorBlock','CopperBulbBlock','CopperGolemStatueBlock','DetectorRailBlock','SculkSensorBlock','CreakingHeartBlock','ShelfBlock','AbstractCauldronBlock','AbstractFurnaceBlock']
TN(g,'catalog (5.3): the blocks that have an analog output (1) and those that do not (0)','CALL "RS1-ANALOG-HAS" USING WS-NM WS-R(1)',1,[(n,) for n in AN]+[('StoneBlock',),('RedstoneWireBlock',),('ObserverBlock',)],lambda n:(int(n in AN),))
def av(kind,a,b,c):
    if kind==1: return a
    if kind==2: return (7-a)*2
    if kind==3: return 14
    if kind==4: return 15 if a else 0
    if kind==5: return (a*15)//4
    if kind==6: return a+1
    if kind==7: return 0 if a else b+1
    if kind==8: return 0 if a else (b if b else 0)
    if kind==9:  # lectern has_book page pagecount
        if not a: return 0
        t=f32(1) if c<=1 else f32(b/(c-1))
        return math.floor(f32(t*14))+1
    if kind==10: return 0 if a!=1 else b
    if kind==11: return 0 if a else b
    if kind==12:  # shelf client dirMatches bits
        return 0 if (a or not b) else c
    if kind==13: return b if a else 0
    return 0
AV=[(1,5,0,0),(2,3,0,0),(3,0,0,0),(4,1,0,0),(4,0,0,0),(5,0,0,0),(5,1,0,0),(5,3,0,0),(5,4,0,0),(6,0,0,0),(6,3,0,0),(7,0,4,0),(7,1,4,0),(8,1,2,0),(8,0,0,0),(9,1,2,5),(9,1,4,5),(9,1,0,1),(9,1,0,5),(9,0,2,5),(10,1,9,0),(10,0,9,0),(11,1,9,0),(11,0,9,0),(12,1,1,5),(12,0,0,5),(12,0,1,5),(12,0,1,0),(13,1,12,0),(13,0,12,0)]
T(g,'fixed formulas (5.3, E11): composter level (1), cauldron level (3 as 1 to 3 via kind 1), lava 3 (kind 3 gives 14 for cake 0 bites: kind 2 is (7 - bites) * 2), end portal 15 (4), respawn anchor floor(charges / 4.0 * 15) 0 3 7 11 15 (5), copper golem pose + 1 (6), chiseled bookshelf client 0 else last slot + 1 (7), lectern (9), jukebox (10), shelf 3-bit value from the matching direction on the server (12), crafter (13); args kind a b c','CALL "RS1-ANALOG-VALUE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,AV,lambda *a:(av(*a),))
SU.write(g)
# ===== 6
g=SU.gen(6,'Observer','T0726','placement, outputs, wire connection, detection, the pulse, onPlace and removal.')
T(g,'states (6.1): 12 states, default facing south, powered false','CALL "RS1-OBS-STATES" USING WS-R(1) WS-R(2) WS-R(3)',3,[(0,)],lambda x:(12,S_,0))
T(g,'placement (6.1, E12): facing is the nearest looking direction itself','CALL "RS1-OBS-PLACE" USING WS-I(1) WS-R(1)',1,[(d,) for d in range(6)],lambda d:(d,))
T(g,'cells (6.1): watched pos + facing, output pos + opp(facing) (offsets)','CALL "RS1-OBS-CELLS" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(f,) for f in range(6)],lambda f:STEP[f]+STEP[opp(f)])
T(g,'output (6.2): 15 when powered; getSignal and getDirectSignal give it only when d equals facing (powered, facing, d; own, signal)','CALL "RS1-OBS-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(1,2,2),(1,2,3),(0,2,2),(1,4,4),(1,4,5)],lambda p,f,d:(15*p,15*p if d==f else 0))
T(g,'wire connection (6.2): true exactly when direction equals facing','CALL "RS1-OBS-CONNECT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(2,2),(3,2),(5,5),(4,5)],lambda d,f:(int(d==f),))
def osu(d,f,p,cl,pend): return (int(d==f and not p and not cl and not pend),)
T(g,'detection (6.3, E9): a shape update from the watched side with powered false on a server and no tick pending schedules a tick after 2; args direction, facing, powered, client, pending','CALL "RS1-OBS-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(2,2,0,0,0),(5,2,0,0,0),(2,2,1,0,0),(2,2,0,1,0),(2,2,0,0,1)],osu)
T(g,'pulse (6.4): a powered observer turns off; an unpowered one turns on and schedules the end after 2; both notify the front (new powered, schedule delay, notify)','CALL "RS1-OBS-TICK" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(1,),(0,)],lambda p:(0,0,1) if p else (1,2,1))
T(g,'onPlace (6.5): nothing for a state change of the same block; on a server a fresh powered observer without a pending tick is reset with flags 18 and the front told; args same block, server, powered, pending','CALL "RS1-OBS-ONPLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,1,1,0),(0,0,1,0),(0,1,0,0),(0,1,1,1),(0,1,1,0)],lambda s,sv,p,pe:(int(not s and sv and p and not pe),))
T(g,'removal (6.5): powered with a tick pending tells the front as unpowered, also for piston moves','CALL "RS1-OBS-REMOVAL" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,1),(1,0),(0,1),(0,0)],lambda p,pe:(int(p and pe),))
SU.write(g)
