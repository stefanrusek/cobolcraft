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
