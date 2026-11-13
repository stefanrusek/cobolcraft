import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-6-%d'%n,'29b-6§%d'%n,subj,'Test of 29b part 6 section %d, %s (core/src/growth-29b-6*.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_growth_29b_6_%d.cob'%n)
def TBL(name,cnt): return " 01 WS-%sG.\n    05 WS-%s BINARY-LONG OCCURS %d TIMES.\n"%(name,name,cnt)
def setarr(name,vals): return "".join('MOVE %d TO WS-%s(%d)\n'%(v,name,i+1) for i,v in enumerate(vals))
def show(*v): return "/".join(str(x) for x in v)
def fl(v): return int(math.floor(v))
def rnd(x): return int(math.floor(x+0.5))
# ===== 1
g=GG(1,'Scope and where each behaviour is specified','T0627','the tag members read in this round and the behaviour-to-document table.')
g.extra=" 01 WS-DOC                PIC X(48).\n"
TAGS={1:["pointed_dripstone","sulfur_spike"],2:["amethyst_block"],3:["sulfur","cinnabar"],4:["arrow","spectral_arrow","firework_rocket","snowball","fireball","small_fireball","egg","trident","dragon_fireball","wither_skull","wind_charge","breeze_wind_charge"]}
probe=["pointed_dripstone","sulfur_spike","amethyst_block","budding_amethyst","sulfur","cinnabar","dripstone_block","stone","arrow","spectral_arrow","trident","firework_rocket","snowball","fireball","small_fireball","egg","dragon_fireball","wither_skull","wind_charge","breeze_wind_charge","zombie"]
def tagcall(k): return 'MOVE "minecraft:%s" TO WS-T1\n'%k+"\n".join('MOVE %d TO WS-I(15)\nCALL "GC6-TAG" USING WS-I(15) WS-T1 WS-R(%d)'%(t,t) for t in range(1,5))
for a in range(0,len(probe),7):
    ch=probe[a:a+7]
    g.case('tag members (1, 11 checks 1): speleothems, vibration_resonators, sulfur_spike_replaceable_blocks and impact_projectiles (tags 1 to 4), one group per probe, group %d'%(a//7+1),[("0",tagcall(k),4) for k in ch]," ".join("/".join(str(int(k in TAGS[t])) for t in range(1,5)) for k in ch))
ROWS=["31-8 s3","31-8 s4.1-4.4","31-8 s5","44-x2 s2; 31-8 s6","31-8 s7.1-7.4","31-8 s7.3","35-6 s8.3-8.6","35-6 s4-7","29b-1 s4","9.3","24-8","29b-1..5, 7","42-3","17","29 s3, s4","29b-2 s9.5",""]
NAMES=["vibration system","sensor phases","calibrated sensor","shrieker","catalyst","live spreader","cursor, vein, block","speleothem worldgen","falling block entity","potent sulfur","registry rows","sibling parts","client drip","damage amounts","ticks and updates","pushEntitiesUp","a row outside the table"]
for a_ in range(0,17,6):
    idx=range(a_,min(a_+6,17))
    g.case('behaviour to document table (1): '+", ".join(NAMES[i] for i in idx),[(str(i+1),'CALL "GC6-SCOPE" USING WS-I(1) WS-DOC\nMOVE WS-DOC TO WS-T1\nMOVE SPACES TO WS-T2','TEXT') for i in idx]," ".join(ROWS[i]+"|" for i in idx))
W(g,1)
# ===== 2
g=GG(2,'Sculk family: live behaviour','T0629','the constants, the charge rules, the level event 3006 data and the catalyst, shrieker and cursor rules of the sculk family.')
CONST=[32,1000,1024,11,24,50,10,4,10,5,30,10,10,90,10,5]
g.run('constants re-read (2.2): cursor limit 32, max charge 1000, max distance 1024, shrieker rate 11, growth radius 24, max decay 0.5 (x 100), live spreader 10, 4, 10, 5, sensor active 30, cooldown 10, calibrated 10, shrieking 90, warning radius 10, experience 5',[str(i) for i in range(1,17)],'CALL "GC6-SCULK-CONST" USING WS-I(1) WS-R(1)',1," ".join(map(str,CONST)))
def ev(S_,fac,nn):
    if not(S_>0 and nn): return (0,0)
    d=2.2999999523162842
    return (1,((int(math.log(1+S_)/d))+1)*64+fac)
ec=[(1,0,1),(1,5,1),(5,17,1),(9,63,1),(12,1,1),(99,2,1),(0,3,1),(7,0,0),(1000,63,1),(30,8,1)]
g.run('level event 3006 (2.2): sent when the summed charge S is above 0 and the facing set is not null; data = ((int)(ln(1 + S) / 2.2999999523162842) + 1) << 6 plus the packed facings',[S(*c) for c in ec],'CALL "GC6-SCULK-EVENT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*ev(*c)) for c in ec))
g.run('discharge (2.2): a cursor whose charge is 0 or less sends event 3006 with data 0 at its own position (sent, data)',["0","-3","1","5"],'CALL "GC6-SCULK-DISCHARGE" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/0 1/0 0/0 0/0")
def decay(ch,d2,r):
    t=f32(f32(math.sqrt(d2))-r)
    q=f32(f32(t*t)/f32((24-r)*(24-r)))
    q=min(1.0,q)
    v=f32(f32(ch*q)*0.5)
    return max(1,int(v))
dc=[(5,100,4),(40,400,4),(40,576,4),(1000,1000,4),(1000,81,4),(3,196,4),(2,36,0),(10,2,4),(500,300,10)]
g.run('decay penalty (2.2): max(1, (int)(charge x min(1, square(sqrt(distSqr) - r) / square(24 - r)) x 0.5)) in single precision',[S(*c) for c in dc],'CALL "GC6-SCULK-DECAY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(decay(*c)) for c in dc))
gc=[(1,0,0),(0,1,2),(0,1,3),(1,0,2),(0,0,0),(0,1,0),(1,0,3)]
g.run('growth cell test (2.2): the cell above is air or a water source and at most 2 blocks of tag sculk_growth_inhibitors are in the box (-4, 0, -4) to (+4, +2, +4)',[S(*c) for c in gc],'CALL "GC6-SCULK-GROWCELL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(int((a or b) and c<=2)) for a,b,c in gc))
def charge(ch,A,near,usable,B,C,pen):
    if ch==0: return (0,0,0)
    if A!=0: return (ch,0,1)
    if near or not usable:
        if B!=0: return (ch,0,2)
        return ((ch-1) if near else (ch-pen),0,2)
    placed=0; dr=3
    if C<ch:
        placed=1; dr=4
    return (max(0,ch-10),placed,dr)
ch_=[(0,0,0,1,0,0,1),(5,3,0,1,0,0,1),(5,0,1,1,3,0,1),(5,0,1,1,0,0,1),(5,0,0,0,0,0,2),(5,0,0,0,0,1,2),(5,0,0,1,0,4,1),(5,0,0,1,0,5,1),(20,0,0,1,0,3,1),(8,0,0,0,2,0,3),(12,0,1,1,1,0,3)]
g.run('SculkBlock.attemptUseCharge (2.2, 2.4): charge 0 returns 0; a non-zero nextInt(10) keeps the charge; near or an unusable cell: a non-zero nextInt(5) keeps it, zero lowers it by 1 (near) or the decay penalty; the growth branch places when nextInt(10) is below the charge (5 of 10 for charge 5) and always leaves max(0, charge - 10) (charge, placed, draws incl. the growth state draw)',[S(*c) for c in ch_],'CALL "GC6-SCULK-CHARGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*charge(*c)) for c in ch_))
cu=[(1,1,5),(0,1,5),(1,0,5),(1,1,0),(1,1,-2)]
g.run('a cursor updates only on a server level, only when its position is in an entity-ticking area and only when charge > 0 (2.1 step 4)',[S(*c) for c in cu],'CALL "GC6-SCULK-CURSOR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 0 0 0 0")
g.run('catalyst block tick (2.1): bloom true is set false (acts); false does nothing',["1","0"],'CALL "GC6-CATALYST-TICK" USING WS-I(1) WS-R(1) WS-R(2)',2,"0/1 0/0")
g.run('shrieker block tick (2.2): when shrieking set it false with setBlockAndUpdate, then tryRespond; otherwise nothing (new shrieking, responds)',["1","0"],'CALL "GC6-SHRIEKER-TICK" USING WS-I(1) WS-R(1) WS-R(2)',2,"0/1 0/0")
g.run('shrieker step (2.2): server level only, a player resolved by tryGetPlayer makes the block entity tryShriek',["1 1","1 0","0 1","0 0"],'CALL "GC6-SHRIEKER-STEP" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
g.run('shrieker state (2.3): waterlogged = the fluid at the clicked position is water; a waterlogged state schedules a water fluid tick of delay 5; can_summon is false unless world generation placed it; shape column(16, 0, 8) and light occlusion by shape (waterlogged, tick, delay, can_summon, shape height, occlusion)',["1 0","0 1","0 0","1 1"],'CALL "GC6-SHRIEKER-STATE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,"1/1/5/0/8/1 0/0/0/1/8/1 0/0/0/0/8/1 1/1/5/1/8/1")
g.run('experience when broken (2.2): sculk 1, sensor 5, shrieker 5, catalyst 5; none when experience drops are not allowed',["1 1","2 1","3 1","4 1","4 0","1 0"],'CALL "GC6-SCULK-XP" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 5 5 5 0 0")
g.run('no sculk block is random-ticking (2.3): sculk, sculk_vein, sculk_catalyst, sculk_sensor, calibrated_sculk_sensor, sculk_shrieker',[str(i) for i in range(1,7)],'CALL "GC6-SCULK-RANDOM" USING WS-I(1) WS-R(1)',1,"0 0 0 0 0 0")
W(g,2)
# ===== 3
g=GG(3,'Amethyst','T0631','the chime, the cluster and bud rules and the budding amethyst random tick.')
g.run('projectile chime (3.1): server level only; pitch = 0.5 + nextFloat x 1.2 (x 1e6), range [0.5, 1.7)',["1 0","1 0.5","1 0.99999","0 0.5"],'CALL "GC6-AMETHYST-HIT" USING WS-I(1) WS-FX(2) WS-R(1) WS-R(2)',2,"1/%d 1/%d 1/%d 0/0"%(rnd(0.5*1e6),rnd(1.1*1e6),rnd((0.5+0.99999*1.2)*1e6)))
g.run('cluster survival (3.2): the block opposite to facing is sturdy towards facing',["1","0"],'CALL "GC6-CLUSTER-SURVIVE" USING WS-I(1) WS-R(1)',1,"1 0")
def csu(w,d,s):
    return (int(w),5 if w else 0,int(d and not s))
cs=[(1,1,0),(1,1,1),(1,0,0),(0,1,0),(0,0,1),(0,1,1)]
g.run('cluster shape update (3.2, 9.2): a waterlogged crystal schedules a water tick (delay 5); the update from the support side that cannot survive gives air; otherwise unchanged (water tick, delay, air)',[S(*c) for c in cs],'CALL "GC6-CLUSTER-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*csu(*c)) for c in cs))
g.run('cluster placement and fluid (3.2): waterlogged = the clicked fluid is water, facing = the clicked face; getFluidState is the water source when waterlogged (waterlogged, facing, fluid source)',["1 1","0 2","1 6","0 3"],'CALL "GC6-CLUSTER-PLACE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 0/2/0 1/6/1 0/3/0")
CYC=[3,6,4,5]
def rot(f,r):
    if f<3: return f
    return CYC[(CYC.index(f)+r)%4]
def mir(f,m):
    ax=0 if f in(3,4) else (1 if f in (5,6) else 2)
    if (m==1 and ax==0) or (m==2 and ax==1): return rot(f,2)
    return f
rt=[(f,r) for f in range(1,7) for r in (1,)]+[(3,2),(4,3),(5,0)]
g.run('rotate (3.2): facing through Rotation.rotate (clockwise 90 turns north to east, up and down unchanged)',[S(*c) for c in rt],'CALL "GC6-CLUSTER-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(str(rot(*c)) for c in rt))
mi=[(f,m) for f in range(1,7) for m in (1,2)]+[(3,0)]
g.run('mirror (3.2): facing through Mirror.getRotation: left-right turns a north or south facing by 180, front-back an east or west facing; up and down never change',[S(*c) for c in mi],'CALL "GC6-CLUSTER-MIRROR" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(str(mir(*c)) for c in mi))
def bud(a,b,k,fw):
    if a!=0: return (1,0,0,0)
    N={1:1,2:1,3:2,4:3,5:4}.get(k,0)
    wl=int(fw) if N else 0
    return (2,b+1,N,wl)
bc=[(3,0,1,0),(0,3,1,0),(0,1,2,1),(0,2,3,0),(0,4,4,0),(0,5,5,1),(0,0,6,0),(0,0,0,0),(1,2,1,0),(0,3,1,1),(0,2,3,1),(0,1,0,0)]
g.run('budding amethyst random tick (3.3, E1): nextInt(5) not 0 stops; nextInt(6) picks the direction (0 down, 1 up, 2 north, 3 south, 4 west, 5 east); air or a full water block gives small, a bud facing that direction the next stage, anything else nothing; waterlogged from the fluid being water (draws, direction 1-6, new block 0 none 1 small 2 medium 3 large 4 cluster, waterlogged)',[S(*c) for c in bc],'CALL "GC6-BUD-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*bud(*c)) for c in bc))
g.run('rate (3.3): one face advances with 1/30 per random tick (x 1e6), four stages 120 ticks, about 163840 game ticks at random_tick_speed 3 (3/4096 per game tick); GROWTH_CHANCE 5',["0"],'CALL "GC6-BUD-RATE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"33333/120/163840/5")
g.run('push reaction (3.1, 3.3): amethyst_block keeps the default PUSH_PULL (1), budding_amethyst is POPPED (2)',["1","2"],'CALL "GC6-AMETHYST-PUSH" USING WS-I(1) WS-R(1)',1,"1 2")
W(g,3)
# ===== 4
g=GG(4,'The speleothem model','T0633','the constants, the helper predicates, placement, survival, shape update and the thickness rules of the speleothem blocks.')
g.extra=TBL('A12',12)
SC=[2,60,100,40,6,11377778,7,10,5,2]
g.run('constants (4.1): DELAY_BEFORE_FALLING 2, trident velocity 0.6 (x 100), damage per fall distance and size 1.0 (x 100), max damage 40, max height for damage 6, growth probability 0.011377778 (x 1e9), MAX_GROWTH_LENGTH 7, stalagmite search range 10, days per growth 5, sulfur spike MAX_GROWING_LENGTH 2',[str(i) for i in range(1,11)],'CALL "GC6-SPEL-CONST" USING WS-I(1) WS-R(1)',1," ".join(map(str,SC)))
def st(t,d,th,wl,inc):
    sl=int(t and d==1); sm=int(t and d==2)
    tip=int(t and (th==2 or (inc and th==1)))
    free=int(sl and th==2 and not wl)
    return sl,sm,tip,free
stc=[(1,1,2,0,0),(1,1,2,1,0),(1,1,1,0,0),(1,1,1,0,1),(1,2,2,0,0),(1,2,1,0,1),(1,2,3,0,1),(0,1,2,0,1),(1,1,4,0,1),(1,1,5,0,0),(0,2,2,0,0)]
g.run('predicates (4.2): isStalactite (tip down), isStalagmite (tip up), isTip (tip, or tip_merge when merged are included), isFreeHangingStalactite (a stalactite with thickness exactly tip, not waterlogged); thickness 1 tip_merge, 2 tip, 3 frustum, 4 middle, 5 base',[S(*c) for c in stc],'CALL "GC6-SPEL-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*st(*c)) for c in stc))
g.run('isValidSpeleothemPlacement (4.2): the support is sturdy on its face toward the tip, or is a speleothem of this block with that direction',["0 0","1 0","0 1","1 1"],'CALL "GC6-SPEL-VALID" USING WS-I(1) WS-I(2) WS-R(1)',1,"0 1 1 1")
def tipdir(t,vt,vo):
    if vt: return t
    if vo: return 3-t
    return 0
tdc=[(1,1,1),(1,1,0),(1,0,1),(1,0,0),(2,1,1),(2,0,1),(2,0,0)]
g.run('calculateTipDirection (4.2): T when the placement toward T is valid; else the opposite when that is valid; else null (0); T 1 down, 2 up',[S(*c) for c in tdc],'CALL "GC6-SPEL-TIPDIR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(tipdir(*c)) for c in tdc))
g.run('isStalactiteStartPos (4.2): a stalactite whose block above is not the same block (the topmost piece)',["1 0","1 1","0 0","0 1"],'CALL "GC6-SPEL-STARTPOS" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
def fv(mi,cells):
    for i in range(1,mi):
        c=cells[i-1]
        if c==1: return i
        if c!=2: return 0
    return 0
fvc=[(11,[2,2,2,1]),(11,[1]),(11,[0,1]),(4,[2,2,2,1]),(4,[2,2,1]),(2,[2,1]),(11,[2]*11),(7,[2]*6+[1]),(7,[2]*5+[1]),(1,[1]),(11,[2,0,1]),(11,[2]*9+[1,1])]
def fvcall(mi,cells): return setarr('A12',cells+[0]*(12-len(cells)))+'MOVE %d TO WS-I(1)\nCALL "GC6-FIND-VERT" USING WS-I(1) WS-A12G WS-R(1)'%mi
g.case('findBlockVertical (4.2): cells 1 to maxIter - 1 only (cell code 1 stop, 2 pass, 0 neither); the first stop is returned, a blocking cell or the end gives none (0); maxIter 7 examines 6 cells, 11 examines 10',[("0",fvcall(*c),1) for c in fvc]," ".join(str(fv(*c)) for c in fvc))
def ft(tp,mi,cells):
    if tp: return (1,0)
    i=fv(mi,cells)
    return (int(i>0),i)
ftc=[(1,7,[]),(0,7,[2,2,1]),(0,7,[2]*6),(0,7,[2]*5+[1]),(0,7,[2]*6+[1]),(0,11,[2]*9+[1]),(0,11,[0,1])]
def ftcall(tp,mi,cells): return setarr('A12',cells+[0]*(12-len(cells)))+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nCALL "GC6-FIND-TIP" USING WS-I(1) WS-I(2) WS-A12G WS-R(1) WS-R(2)'%(tp,mi)
g.case('findTip (4.2): the position itself when it is a tip; else the first tip below within maxIter - 1 cells (found, offset): with MAX_GROWTH_LENGTH 7 a tip 6 cells below is found, 7 cells below is not, so a pointed dripstone stalactite stops at 8 pieces',[("0",ftcall(*c),2) for c in ftc]," ".join(show(*ft(*c)) for c in ftc))
def dt(air,sol,fl_,inter):
    if air: return 1
    if sol: return 0
    if fl_: return 0
    return int(not inter)
dtc=[(1,0,0,0),(1,1,1,1),(0,1,0,0),(0,0,1,0),(0,0,0,1),(0,0,0,0)]
g.run('canDripThrough (4.2): true for air; false for a full opaque cube and for a non-empty fluid; else true exactly when the collision shape misses the central 4 x 4 column',[S(*c) for c in dtc],'CALL "GC6-DRIP-THROUGH" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(dt(*c)) for c in dtc))
def pl(pitch,vd,vo,sn,w):
    D=1 if pitch<0 else 2
    T=D if vd else ((3-D) if vo else 0)
    if not T: return (0,0,0,0)
    return (1,T,int(not sn),int(w))
plc=[(-30,1,0,0,0),(-30,0,1,0,1),(-30,0,0,0,0),(0,1,0,1,0),(45,0,1,0,0),(45,1,1,0,1),(-0.5,1,1,0,0),(0.5,1,0,0,0)]
g.run('placement (4.3): D = opposite of the vertical look direction (pitch below 0 looks up and gives tip down); T from calculateTipDirection; merge is not sneaking; waterlogged = the fluid is water (placed, tip direction, merge, waterlogged)',[S(*c) for c in plc],'CALL "GC6-SPEL-PLACE" USING WS-FX(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*pl(*c)) for c in plc))
g.run('survival (4.4): canSurvive is isValidSpeleothemPlacement toward the state\'s tip direction',["0","1"],'CALL "GC6-SPEL-VALID" USING WS-I(1) WS-I(2) WS-R(1)',1,"0 1")
def su(w,d,T,sched,surv):
    wt=int(w)
    if d==3: return (wt,0,0)
    if T==1 and sched: return (wt,0,0)
    opp=2 if T==1 else 1
    if d==opp and not surv: return (wt,1,2 if T==1 else 1)
    return (wt,2,0)
suc=[(1,3,1,0,1),(0,3,2,0,0),(0,2,1,1,0),(0,2,1,0,0),(0,1,2,0,0),(0,1,2,0,1),(0,2,1,0,1),(1,2,1,0,0),(0,1,1,0,0),(0,2,2,1,0)]
g.run('shape update (4.4): a waterlogged state schedules a water tick; a horizontal update returns the state; a stalactite with a tick already scheduled returns it; the update from the support side that cannot survive schedules a tick (2 for a stalactite, 1 for a stalagmite); else the thickness is recomputed (water tick, 0 unchanged 1 tick 2 thickness, delay)',[S(*c) for c in suc],'CALL "GC6-SPEL-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*su(*c)) for c in suc))
def th(opp,mg,nm,spT,tm,bT):
    if opp: return 1 if (mg or nm) else 2
    if not spT: return 2
    if tm: return 3
    if not bT: return 5
    return 4
thc=[(1,1,0,0,0,0),(1,0,1,0,0,0),(1,0,0,0,0,0),(0,0,0,0,0,1),(0,0,0,1,1,0),(0,0,0,1,1,1),(0,0,0,1,0,0),(0,0,0,1,0,1)]
g.run('thickness (4.5): an opposing tip of this block gives tip_merge when merging or when it is merged, else tip; nothing continuing beyond gives tip; a tip or merged tip beyond gives frustum; no speleothem behind gives base; else middle',[S(*c) for c in thc],'CALL "GC6-SPEL-THICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1," ".join(str(th(*c)) for c in thc))
def colcall(k,i): return 'MOVE 0 TO WS-I(1)\nMOVE 0 TO WS-I(2)\nMOVE 0 TO WS-I(3)\nMOVE %d TO WS-I(4)\nMOVE %d TO WS-I(5)\nMOVE %d TO WS-I(6)\nCALL "GC6-SPEL-THICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)'%(int(i+1<k),int(i+1==k-1),int(i>0))
cols={1:[2],2:[3,2],3:[5,3,2],4:[5,4,3,2]}
g.case('a downward column of height 1, 2, 3, 4 read from the support: [tip], [frustum, tip], [base, frustum, tip], [base, middle, frustum, tip] (4.5, validation 4)',[("0",colcall(k,i),1) for k in range(1,5) for i in range(k)]," ".join(str(x) for k in range(1,5) for x in cols[k]))
W(g,4)
# ===== 5
g=GG(5,'Growth','T0635','the random tick gate, canGrow, findTip, the growth choice, the stalagmite scan and growing, merging and creating pieces.')
g.extra=TBL('A60',60)
g.run('growth probability (5.1, validation 2): 1 / (5 x 24000 x 3 / 4096) = 0.011377778 (x 1e9)',["0"],'CALL "GC6-GROW-RATE" USING WS-R(1)',1,"11377778")
def gt(k,d,start):
    dr=2 if k==1 else 1
    return int(d<0.011377778 and start),dr
gtc=[(1,0.0,1),(1,0.01,1),(1,0.0113,1),(1,0.0114,1),(1,0.5,1),(1,0.0,0),(2,0.0,1),(2,0.0114,1),(2,0.0,0),(2,0.9,0)]
g.run('random tick (5.1): one nextFloat below 0.011377778 and a stalactite start position continue; the pointed dripstone makes two draws (fluid transfer first), the sulfur spike one (kind 1 pointed, 2 sulfur; proceeds, draws)',[S(*c) for c in gtc],'CALL "GC6-GROW-TICK" USING WS-I(1) WS-FX(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*gt(*c)) for c in gtc))
cg=[(1,1,1),(1,1,0),(1,0,1),(1,0,0),(2,1,0),(2,1,1),(2,0,1),(2,0,0)]
g.run('canGrow (5.2 step 1): the block above is the block of blockToGrowOn; the pointed dripstone also needs a water source two above, the sulfur spike no fluid condition',[S(*c) for c in cg],'CALL "GC6-CAN-GROW" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(int(a if k==2 else (a and b))) for k,a,b in [(c[0],c[1],c[2]) for c in cg]).replace("True","1"))
g.run('getMaxGrowthLength (5.2 step 2, 9.1): 7 for the pointed dripstone (stops at 8 pieces), 2 for the sulfur spike (stops at 3 pieces) (max length, piece cap)',["1","2"],'CALL "GC6-MAX-LEN" USING WS-I(1) WS-R(1) WS-R(2)',2,"7/8 2/3")
def ctg(fl_,air,tip):
    if fl_: return 0
    if air: return 1
    return int(tip)
ctc=[(1,1,1),(1,0,1),(0,1,0),(0,0,1),(0,0,0)]
g.run('canTipGrow (5.2 step 3): false when the cell below has a fluid; true when it is air; else it must be an unmerged tip of this block pointing up',[S(*c) for c in ctc],'CALL "GC6-TIP-GROW" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(ctg(*c)) for c in ctc))
def gch(free,ctgv,nb):
    if not(free and ctgv): return (0,0)
    return (1 if nb else 2,1)
gcc=[(1,1,1),(1,1,0),(0,1,1),(1,0,1),(0,0,0)]
g.run('growth choice (5.2 steps 3, 4): a free-hanging tip that can grow draws nextBoolean: true grows the stalactite (1), false grows a stalagmite below (2); otherwise stop (0) without a draw (action, draws)',[S(*c) for c in gcc],'CALL "GC6-GROW-CHOICE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*gch(*c)) for c in gcc))
def scan(k,cells):
    for i,(fl_,tu,ctg_,vp,bw,bs) in enumerate(cells,1):
        if fl_: return (0,0)
        if tu and ctg_: return (1,i)
        if vp and not bw: return (2,i)
        if k==1 and bs: return (0,0)
    return (0,0)
def scall(k,cells):
    flat=[]
    for c in cells: flat+=list(c)
    flat+=[0]*(60-len(flat))
    return setarr('A60',flat)+'MOVE %d TO WS-I(1)\nCALL "GC6-STALAGMITE-SCAN" USING WS-I(1) WS-A60G WS-R(1) WS-R(2)'%k
Z=(0,0,0,0,0,0)
sc_=[(1,[Z]*10),(1,[(0,1,1,0,0,0)]+[Z]*9),(1,[Z,Z,(0,1,0,1,0,0)]+[Z]*7),(1,[Z,(0,1,0,1,1,0),(0,0,0,1,0,0)]+[Z]*7),(1,[(1,1,1,1,0,0)]+[Z]*9),(1,[(0,0,0,0,0,1),(0,1,1,1,0,0)]+[Z]*8),(2,[(0,0,0,0,0,1),(0,0,0,1,0,1)]+[Z]*8),(1,[Z]*9+[(0,0,0,1,0,0)]),(2,[Z]*9+[(0,0,0,0,0,1)]),(1,[(0,1,0,0,0,0),(0,0,0,1,0,0)]+[Z]*8)]
g.case('stalagmite scan (5.3): up to 10 cells downward; a fluid stops; an unmerged tip up that can grow grows (1); a valid placement with no water below places a new tip at that cell (2); a block that stops a drop ends the pointed dripstone scan, never the sulfur spike scan (action, cell)',[("0",scall(*c),2) for c in sc_]," ".join(show(*scan(*c)) for c in sc_))
def gtg(op,air,wb):
    if op: return 1
    if air or wb: return 2
    return 0
gtc2=[(1,0,0),(0,1,0),(0,0,1),(0,0,0),(1,1,1)]
g.run('grow (5.4): an opposing unmerged tip of this block merges the tips (1); air or any water block creates a tip (2); otherwise nothing (0)',[S(*c) for c in gtc2],'CALL "GC6-GROW-TARGET" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(gtg(*c)) for c in gtc2))
g.run('createSpeleothem (5.4): waterlogged = the fluid at the position is water; written with setBlockAndUpdate (flags 3), the thickness given (no calculation)',["1","0"],'CALL "GC6-CREATE" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/3 0/3")
g.run('createMergedTips (5.4, E3): the existing tip direction up: lower = pos, upper = pos + up; down: upper = pos, lower = pos + down; the upper piece is written first (tip down), then the lower (tip up), both tip_merge (1) (upper dy, lower dy, thickness, first written 1 upper)',["2","1"],'CALL "GC6-MERGE-TIPS" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"1/0/1/1 0/-1/1/1")
W(g,5)
# ===== 6
g=GG(6,'Falling and breaking','T0637','the block tick, the walk that spawns falling pieces, the landing and damage rules and the projectile break.')
g.extra=TBL('A12',12)
g.run('block tick (6.1): an unsupported stalagmite is destroyed with drops (1); every other state runs spawnFallingStalactite (2), which does nothing for a surviving stalagmite',["1 0","1 1","0 0","0 1"],'CALL "GC6-FALL-TICK" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 2 2 2")
def spawn(cells):
    n=0;h=0
    for k,c in enumerate(cells):
        if c==0: break
        n+=1
        if c==2:
            h=max(1+k,6); break
    return n,h,100*h if h else 0,40 if h else 0
spc=[[2],[1,1,2],[1,1,1,1,2],[1,2,2],[1,1,0],[0],[1,1,1,1,1,1,1,1,2],[1,1,1,1,1,1,1,1,1,1,1,1],[2,1]]
def spcall(cells): return setarr('A12',cells+[0]*(12-len(cells)))+'CALL "GC6-FALL-SPAWN" USING WS-A12G WS-R(1) WS-R(2) WS-R(3) WS-R(4)'
g.case('spawnFallingStalactite (6.2, E4): from the ticking piece down, one falling entity per stalactite piece until the tip (cell 2, a tip or merged tip); the tip entity hurts: h = max(1 + pos.y - c.y, 6), damage per fall distance 1.0 x h (x 100), maximum 40; a column ending before a tip gives no damage (pieces, h, per distance, maximum)',[("0",spcall(c),4) for c in spc]," ".join(show(*spawn(c)) for c in spc))
g.run('landing (6.3): onBrokenAfterFall sends level event 1045 (pointed dripstone) or 1052 (sulfur spike) unless the entity is silent; the damage source is falling_stalactite (1) for both; onLand is not overridden',["1 0","2 0","1 1","2 1"],'CALL "GC6-FALL-LAND" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"1045/1 1052/1 0/1 0/1")
def dmg(h,d):
    n=math.ceil(d-1)
    return n,min(math.floor(n*h),40)
dgc=[(6,5),(6,8),(6,2),(6,1),(7,3.5),(6,6.5),(6,30),(10,10)]
g.run('damage (6.3, E4): n = ceil(fallDistance - 1), damage = min(floor(n x h), 40): h 6 after 5 blocks 24, after 8 blocks 42 capped to 40',[S(*c) for c in dgc],'CALL "GC6-FALL-DAMAGE" USING WS-I(1) WS-FX(2) WS-R(1) WS-R(2)',2," ".join(show(*dmg(*c)) for c in dgc))
def rest(ok,di,er):
    return (ok,int(not ok),int((not ok) and di and er))
rsc=[(0,1,1),(0,0,1),(0,1,0),(1,1,1)]
g.run('does the piece place itself (6.3): only with a sturdy block or speleothem above (normally no); it is then discarded and the block item drops when dropItem and the entity_drops rule hold (places, discarded, item drops)',[S(*c) for c in rsc],'CALL "GC6-FALL-REST" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*rest(*c)) for c in rsc))
def inter(o,pm,mg): return pm if o==1 else (mg if o==2 else 1)
ic=[(0,0,0),(1,1,0),(1,0,1),(2,0,1),(2,1,0),(2,0,0)]
g.run('mayInteract (6.4): no owner true; a player owner uses the player\'s own mayInteract; another entity needs the game rule mob_griefing',[S(*c) for c in ic],'CALL "GC6-PROJ-INTERACT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(inter(*c)) for c in ic))
def adv(o,a,cb):
    if o==2: return cb
    return int(not a)
avc=[(0,0,0),(0,1,0),(1,0,0),(1,1,1),(2,0,0),(2,1,0),(2,0,1)]
g.run('canBreakBlockInAdventureMode (6.4): no owner true unless the server default is adventure; a player owner unless in adventure; another entity ends at the projectile\'s own canBreak predicate (false for ordinary projectiles)',[S(*c) for c in avc],'CALL "GC6-PROJ-ADVENTURE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(adv(*c)) for c in avc))
g.run('mayBreak (6.4): the entity type is in impact_projectiles and the game rule projectiles_can_break_blocks is true and the adventure test passes',["1 1 1","0 1 1","1 0 1","1 1 0"],'CALL "GC6-PROJ-MAYBREAK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 0 0 0")
def brk(sv,mi,mb,tr,sp): return int(sv and mi and mb and tr and sp>0.6)
bkc=[(1,1,1,1,0.9),(1,1,1,1,0.6),(1,1,1,1,0.61),(1,1,1,0,2.0),(1,1,0,1,2.0),(1,0,1,1,2.0),(0,1,1,1,2.0),(1,1,1,1,0)]
g.run('projectile break (6.4): the speleothem is destroyed with drops on a server level when the projectile may interact, may break, is a trident and its speed is greater than 0.6',[S(*c) for c in bkc],'CALL "GC6-PROJ-BREAK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-FX(5) WS-R(1)',1," ".join(str(brk(*c)) for c in bkc))
W(g,6)
# ===== 7
g=GG(7,'Pointed dripstone: fluid, cauldron, mud, damage','T0639','the fluid above a stalactite, the fluid transfer random tick, mud to clay, the search lengths and the stalagmite fall damage.')
g.extra=TBL('A12',12)
FLUIDS={0:'empty',1:'water',2:'flowing water',3:'lava',4:'flowing lava'}
def fa(st,rf,mud,ev,fluid):
    if not st or not rf: return (0,0,0)
    f=1 if (mud and not ev) else fluid
    return (1,f,int(mud))
fac=[(1,1,0,0,1),(1,1,0,0,2),(1,1,0,0,3),(1,1,0,0,0),(1,1,1,0,0),(1,1,1,1,0),(1,1,1,1,1),(1,0,0,0,1),(0,1,0,0,1),(1,1,1,0,3),(1,1,0,1,4)]
g.run('getFluidAboveStalactite (7.1): nothing unless a stalactite with a root; mud above the root with water_evaporates false reports still water whatever the mud holds, otherwise the fluid type of the cell (1 water, 2 flowing water, 3 lava, 4 flowing lava, 0 empty): flowing water drips nothing (exists, fluid, source is mud)',[S(*c) for c in fac],'CALL "GC6-FLUID-ABOVE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*fa(*c)) for c in fac))
g.run('getCauldronFillFluidType (7.1): the fluid when it is water (1) or lava (3), else EMPTY (0)',["0","1","2","3","4"],'CALL "GC6-FILL-TYPE" USING WS-I(1) WS-R(1)',1,"0 1 0 3 0")
def fv(mi,cells):
    for i in range(1,mi):
        c=cells[i-1]
        if c==1: return i
        if c!=2: return 0
    return 0
def fvcall(mi,cells): return setarr('A12',cells+[0]*(12-len(cells)))+'MOVE %d TO WS-I(1)\nCALL "GC6-FIND-VERT" USING WS-I(1) WS-A12G WS-R(1)'%mi
sr=[(11,[2,2,2,1]),(11,[2]*9+[1]),(11,[2]*10+[1]),(11,[2,2,0,1]),(11,[1]),(11,[2]*11)]
g.case('the searches of 7.1 and 7.3 use maxIter 11 and examine 10 cells: the root above a column (pass = same block and direction, stop = another block): E6 finds the cauldron 4 below the tip; a column taller than 10 pieces gives nothing',[("0",fvcall(*c),1) for c in sr]," ".join(str(fv(*c)) for c in sr))
def tr(roll,start,info,fluid,tip,mud,cauldron,dy):
    z=(0,0,0,0,0)
    if roll>0.17578125: return z
    if not start or not info: return z
    th={1:0.17578125,3:0.05859375}.get(fluid)
    if th is None or roll>=th: return z
    if not tip: return z
    if mud and fluid==1: return (1,1504,0,1,1)
    if not cauldron: return z
    return (2,1504,50+dy,0,0)
trc=[(0.1,1,1,1,1,0,1,4),(0.1,1,1,1,1,1,1,4),(0.1,1,1,1,1,1,0,4),(0.1,1,1,1,1,0,0,4),(0.1,1,1,1,0,0,1,4),(0.17,1,1,1,1,0,1,10),(0.18,1,1,1,1,0,1,4),(0.1,0,1,1,1,0,1,4),(0.1,1,0,1,1,0,1,4),(0.05,1,1,3,1,0,1,8),(0.06,1,1,3,1,0,1,8),(0.1,1,1,2,1,0,1,4),(0.0,1,1,3,1,1,1,4),(0.0,1,1,1,1,1,1,4)]
g.run('maybeTransferFluid (7.2): a roll above 0.17578125, a piece that is not a start position, no fluid info, a fluid other than water and lava, a roll at or above the fluid threshold (water 0.17578125, lava 0.05859375) or no tip below all stop; mud with water becomes clay (action 1, event 1504, push entities up, game event); else a cauldron below gets event 1504 and a tick after 50 + (tip y - cauldron y) (action 2, event, delay, push, game event)',[S(*c) for c in trc],'CALL "GC6-TRANSFER" USING WS-FX(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(*tr(*c)) for c in trc))
DC=[17578125,5859375,11,25,2,1045,2,12,45,15]
g.run('constants (7.2, 7.3): water 0.17578125 and lava 0.05859375 (x 1e8), search length 11, STALAGMITE_FALL_DISTANCE_OFFSET 2.5 (x 10), damage modifier 2, landing sound 1045, drip probabilities 0.02 and 0.12 (x 100), water 45/256, lava 15/256',[str(i) for i in range(1,11)],'CALL "GC6-DRIP-CONST" USING WS-I(1) WS-R(1)',1," ".join(map(str,DC)))
def fo(pt,up,tip,d):
    if pt and up and tip: return (1,int(round((d+2.5)*1000)),2000)
    return (0,0,0)
foc=[(1,1,1,5),(1,1,1,0.5),(1,1,0,5),(1,0,1,5),(0,1,1,5)]
g.run('fallOn (7.3): a pointed dripstone with tip up and thickness exactly tip calls causeFallDamage(distance + 2.5, 2.0); any other state uses the base rule (special, distance x 1000, modifier x 1000)',[S(*c) for c in foc],'CALL "GC6-FALL-ON" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*fo(*c)) for c in foc))
def fc(d,mod,safe,mult): return max(0,math.floor((d+0.000001-safe)*mod*mult))
fcc=[(7.5,2,3,1),(5,1,3,1),(5,2,3,1),(2,1,3,1),(10.5,2,3,1),(7.5,2,3,0.5)]
g.run('fall damage (7.3, E5): floor((distance + 0.000001 - safe distance) x modifier x multiplier): 7.5 with modifier 2 gives 9, a frustum landing from 5 blocks gives 2',[S(*c) for c in fcc],'CALL "GC6-FALL-CAUSE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-FX(4) WS-R(1)',1," ".join(str(fc(*c)) for c in fcc))
W(g,7)
# ===== 8
g=GG(8,'The cauldron side, level events and sounds','T0641','the cauldron tick, the three receivers and the level events of the part.')
def ct(tip,fluid,can): return int(tip and fluid!=0 and can)
ctc_=[(1,1,1),(1,3,1),(0,1,1),(1,0,1),(1,1,0)]
g.run('AbstractCauldronBlock.tick (8.1): receives only when a tip is found above, the fill fluid is not EMPTY and canReceiveStalactiteDrip holds',[S(*c) for c in ctc_],'CALL "GC6-CAULDRON-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(ct(*c)) for c in ctc_))
def rv(cl,fl_,lv):
    can={1:0,2:1,3:int(fl_==1),4:0}[cl]
    if not can: return (0,0,0,0,0)
    if cl==2:
        if fl_==1: return (1,1,1,1047,1)
        if fl_==3: return (1,2,1,1046,1)
        return (1,0,0,0,0)
    if lv==3: return (1,0,lv,0,0)
    return (1,3,lv+1,1047,1)
rvc=[(1,1,0),(1,3,0),(2,1,0),(2,3,0),(2,2,0),(3,1,1),(3,1,2),(3,1,3),(3,3,1),(4,1,1),(4,3,2)]
g.run('receivers (8.1): the lava cauldron never accepts; the empty cauldron takes any fluid but only water and lava change it (water_cauldron level 1 with event 1047, lava_cauldron with 1046, game event block_change); the water cauldron takes water only: level + 1 with event 1047, nothing when full; the powder snow cauldron never accepts (class 1 lava, 2 empty, 3 water, 4 powder snow; can, action 0 none 1 water cauldron 2 lava cauldron 3 level + 1, level, event, game event)',[S(*c) for c in rvc],'CALL "GC6-CAULDRON-RECV" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(*rv(*c)) for c in rvc))
def lvl(e):
    t={1045:(1,20,90,10),1052:(1,20,90,10),1046:(1,20,90,10),1047:(1,20,90,10),1504:(3,0,0,0),3006:(2,0,0,0),3007:(4,0,0,0)}
    return t.get(e,(0,0,0,0))
lec=[1045,1052,1046,1047,1504,3006,3007,1048,0]
g.run('level events (8.2): 1045, 1052, 1046, 1047 play a local sound at the block with volume 2.0 and pitch 0.9 + nextFloat x 0.1; 1504 spawns the drip particle without sound; 3006 particles only; 3007 belongs to the shrieker; others are not of this part (kind 1 sound 2 particles 3 drip 4 other part, volume x 10, pitch base x 100, pitch range x 100)',[str(e) for e in lec],'CALL "GC6-LEVEL-EVENT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*lvl(e)) for e in lec))
SND={1045:"block.pointed_dripstone.land",1052:"block.sulfur_spike.land",1046:"block.pointed_dripstone.drip_lava_into_cauldron",1047:"block.pointed_dripstone.drip_water_into_cauldron",1504:""}
g.extra=" 01 WS-NAME               PIC X(64).\n"
g.case('sound keys (8.2): the sound of each level event of the part',[(str(e),'CALL "GC6-LEVEL-SOUND" USING WS-I(1) WS-NAME\nMOVE WS-NAME TO WS-T1\nMOVE SPACES TO WS-T2','TEXT') for e in (1045,1052,1046,1047,1504)]," ".join(SND[e]+"|" for e in (1045,1052,1046,1047,1504)))
W(g,8)
# ===== 9
g=GG(9,'Sulfur spike differences and the behaviour rows','T0643','the sulfur spike against the pointed dripstone, the behaviour rows and the potent sulfur block.')
g.extra=" 01 WS-NAME               PIC X(16).\n"
def diff(k):
    if k==1: return (1,1,7,1,2,1,1,1045,1,8)
    return (2,0,2,0,1,0,0,1052,1,3)
g.run('SulfurSpikeBlock against PointedDripstoneBlock (9.1): blockToGrowOn (1 dripstone_block, 2 sulfur), a water source two above (1 or none), getMaxGrowthLength 7 or 2, blocksStalagmiteScan (not canDripThrough or never), nextFloat draws per random tick 2 or 1, drip and cauldron and mud (yes or none), fallOn damage (yes or none), landing event 1045 or 1052, damage source falling_stalactite for both, piece cap 8 or 3',["1","2"],'CALL "GC6-SULFUR-DIFF" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7) WS-R(8) WS-R(9) WS-R(10)',10," ".join(show(*diff(k)) for k in (1,2)))
def tagcall(k): return 'MOVE "minecraft:%s" TO WS-T1\nMOVE 3 TO WS-I(15)\nCALL "GC6-TAG" USING WS-I(15) WS-T1 WS-R(1)'%k
g.case('tag for world generation replacement (9.1): sulfur_spike_replaceable_blocks is exactly sulfur and cinnabar',[("0",tagcall(k),1) for k in ("sulfur","cinnabar","dripstone_block","stone")],"1 1 0 0")
ROWS9=[(1,3,0),(2,0,0),(3,0,0),(2,0,0),(4,3,1045),(1,3,0),(1,3,1504),(4,3,1047),(4,3,0),(4,3,0),(4,0,0),(0,0,3006)]
g.run('behaviour rows (9.2): trigger (1 RT, 2 SU, 3 EV, 4 ST, 0 driven by the spreader), setBlock flags (0 via the update or none) and the level event: budding RT 3, cluster SU, chime EV, speleothem SU, speleothem ST 3 with 1045 or 1052 on landing, RT 3, drip RT 3 with 1504, cauldron ST 3 with 1046 or 1047, shrieker ST, catalyst ST, sensor ST, sculk spreader 3006',[str(i) for i in range(1,13)],'CALL "GC6-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*r) for r in ROWS9))
def pot(w,bc,bp,bf,cur):
    if not w: return (0,0)
    if bc and bf: return (4,0)
    if bp and bf:
        rs=int(cur not in (3,2))
        return (3 if cur==3 else 2,rs)
    return (1,0)
ptc=[(0,1,0,1,0),(0,0,0,0,3),(1,1,0,1,0),(1,1,0,0,0),(1,0,1,1,3),(1,0,1,1,2),(1,0,1,1,0),(1,0,1,1,4),(1,0,1,0,2),(1,0,0,1,0),(1,1,1,1,0),(1,0,0,0,3)]
g.run('PotentSulfurBlock.validBlockState (9.3): no water source above gives dry (0); lava below with an empty or source fluid gives continuous (4); magma_block below gives erupting when the state is erupting else dormant (resetCountdown first when the state is neither erupting nor dormant); otherwise wet (1) (state 0 dry, 1 wet, 2 dormant, 3 erupting, 4 continuous; new state, resetCountdown)',[S(*c) for c in ptc],'CALL "GC6-POTENT-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2," ".join(show(*pot(*c)) for c in ptc))
def pl(s):
    return (int(s in (3,4)),{3:2,4:1}.get(s,0),int(s in (3,4)))
g.run('onPlace (9.3): an erupting or continuous state sends blockEvent (pos, block, 0, 0), the sound geyser_eruption_start (2) or geyser_continuous_start (1) at volume 1 pitch 1 and the game event block_activate (blockEvent, sound, game event)',[str(i) for i in range(5)],'CALL "GC6-POTENT-PLACE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*pl(s)) for s in range(5)))
TK={0:(0,0,0),1:(1,1,0),2:(1,2,0),3:(2,3,1),4:(2,4,2)}
g.run('getTicker (9.3): dry none; wet client noxious gas, server nausea; dormant client noxious gas, server waiting countdown then nausea; erupting client plume then launch, server launch then waiting countdown; continuous client plume then launch, server launch alone (client code 0 none 1 noxious gas 2 plume and launch, server code 0 none 1 nausea 2 countdown and nausea 3 launch and countdown 4 launch, plume sound 1 geyser_eruption_active 2 geyser_continuous_active)',[str(i) for i in range(5)],'CALL "GC6-POTENT-TICKER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*TK[s]) for s in range(5)))
PC=[4,10,80,30,25,20,40,3,2,-904011478,6]
g.run('constants (9.3): ALLOWED_WATER_BLOCKS_ABOVE 4, nausea every 10 ticks for 80 ticks, effect range 3.0 and box 2.5 (x 10), particle period 20, sound period 40, geyser base launch speed 0.3 and launch force 0.2 (x 10), geyser salt -904011478, scan limit 6',[str(i) for i in range(1,12)],'CALL "GC6-POTENT-CONST" USING WS-I(1) WS-R(1)',1," ".join(map(str,PC)))
def an(s,w,d):
    if s==0 or not w: return (0,0)
    return (2,int(d==0))
anc=[(0,1,0),(1,0,0),(1,1,0),(2,1,3),(3,1,0),(4,1,9)]
g.run('animateTick (9.3, client): nothing when dry or without a water source above; otherwise two sulfur_bubbles bursts at the cell above and, with nextInt(10) of 0, the ambient sound noxious_gas (bursts, sound)',[S(*c) for c in anc],'CALL "GC6-POTENT-ANIM" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*an(*c)) for c in anc))
NM=["dry","wet","dormant","erupting","continuous"]
g.case('the property state (9.3): serialized names dry, wet, dormant, erupting, continuous; default dry',[(str(i),'CALL "GC6-POTENT-NAME" USING WS-I(1) WS-NAME\nMOVE WS-NAME TO WS-T1\nMOVE SPACES TO WS-T2','TEXT') for i in range(5)]," ".join(n+"|" for n in NM))
W(g,9)
