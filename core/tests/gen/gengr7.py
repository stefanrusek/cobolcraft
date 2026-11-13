import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-7-%d'%n,'29b-7§%d'%n,subj,'Test of 29b part 7 section %d, %s (core/src/growth-29b-7*.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_growth_29b_7_%d.cob'%n)
def show(*v): return "/".join(str(x) for x in v)
def rnd(x): return int(math.floor(x+0.5))
DOC=" 01 WS-DOC                PIC X(64).\n"
def textcase(g,text,prog,inputs,exps):
    g.case(text,[(i,'CALL "%s" USING %s WS-DOC\nMOVE WS-DOC TO WS-T1\nMOVE SPACES TO WS-T2'%(prog,args),'TEXT') for i,args in inputs]," ".join(e+"|" for e in exps))
def U(*a): return " ".join("WS-I(%d)"%i for i in a)
def O(n): return " ".join("WS-R(%d)"%i for i in range(1,n+1))
def run(g,text,prog,vecs,nin,nout,model,infx=()):
    # nin inputs (WS-I or WS-FX when index in infx), nout outputs
    args=" ".join(("WS-FX(%d)" if i in infx else "WS-I(%d)")%i for i in range(1,nin+1))
    g.run(text,[S(*v) for v in vecs],'CALL "%s" USING %s %s'%(prog,args,O(nout)),nout," ".join(show(*model(*v)) if isinstance(model(*v),tuple) else str(model(*v)) for v in vecs))
# ===== 1
if not ONLY or 1 in ONLY:
    g=GG(1,'Scope and cross-references','T0645','the owner table, the block-to-section table, the flags and helpers and the coral count.')
    g.extra=DOC
    OWN=["24","24 p1 s6","31-4","33 s4","29a; 25-5","29a; 44-1 s4.3","44-1 RQ-1.9; 13","44-x1 s2.1","44-4; 19","44-x1 s2.3","17 s3.3","29b-3 s10.3, s9.2","29b-6 s7, s8","29b-5","42; 21","advancement round"]
    NM=["registry rows","shape helpers","BeehiveBlockEntity","level-tick precipitation","fluid ticks","inside-block effects","speed and jump factor","honey slide formulas","turtle and sniffer mobs","bubble columns","flint and steel lighting","magma and lightning rod","pointed dripstone","weathering copper","particles and sounds","advancement triggers"]
    for a in range(0,16,8):
        idx=range(a,a+8)
        textcase(g,'owner table (1.1): '+", ".join(NM[i] for i in idx),'GC7-OWNER',[(str(i+1),'WS-I(1)') for i in idx],[OWN[i] for i in idx])
    textcase(g,'a row outside the owner table gives blank (1.1)','GC7-OWNER',[("17",'WS-I(1)')],[""])
    SEC=["2.3","2.4","2.5","2.6","2.2","2.4","2.5","2.6","3","4","5","6","7","8.2","8.3","8.4","9.2","9.3","9.4","10.1","10.2","10.3"]
    BN=["coral blocks","coral plants","coral fans","coral wall fans","dead coral blocks","dead coral plants","dead coral fans","dead coral wall fans","turtle_egg","sniffer_egg","frogspawn","honey_block","beehive and bee_nest","cauldron","water and powder snow cauldron","lava_cauldron","candles","candle cakes","cake","soul_sand","magma_block","lightning_rod"]
    for a in range(0,22,8):
        idx=range(a,min(a+8,22))
        textcase(g,'block to section table (1.3): '+", ".join(BN[i] for i in idx),'GC7-BLOCK-SECTION',[(str(i+1),'WS-I(1)') for i in idx],[SEC[i] for i in idx])
    textcase(g,'a block outside the table gives blank (1.3)','GC7-BLOCK-SECTION',[("23",'WS-I(1)')],[""])
    FL=[2,3,11,5]
    run(g,'flags and helpers (1.2): setBlock flags 2, setBlockAndUpdate 3, setLit 11, scheduled fluid tick delay 5',"GC7-FLAGS",[(i,) for i in range(1,5)],1,1,lambda i:FL[i-1])
    g.run('coral count (1): 5 species times 4 forms times 2 states = 40 registry blocks (species, forms, states, total)',["0"],'CALL "GC7-CORAL-COUNT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"5/4/2/40")
    W(g,1)
# ===== 2
if not ONLY or 2 in ONLY:
    g=GG(2,'Corals','T0647','the die rule, the coral block, plant, fan and wall fan rules, support, placement, shapes and facing rotation.')
    g.extra=DOC
    run(g,'die tick delay (2.1, validation): 60 + nextInt(40), so 60 to 99 (draw 17 gives 77, worked example 1)',"GC7-CORAL-DELAY",[(0,),(17,),(39,),(1,)],1,1,lambda d:60+d)
    def wet(k,wl,n): return int((k==2 and wl) or n>0)
    wc=[(1,0,0),(1,1,0),(1,0,1),(1,0,6),(2,0,0),(2,1,0),(2,0,1),(2,1,3)]
    run(g,'water test (2.1): a plant type is wet when waterlogged or any of the 6 neighbours holds water, a coral block only by a neighbour (kind 1 block, 2 plant type, waterlogged, wet neighbours)',"GC7-CORAL-WET",wc,3,1,wet)
    def blk(t,w):
        if t in(1,2): return (int(not w),0,0)
        return (0,int(not w),2 if not w else 0)
    run(g,'coral block rules (2.3): placement and shape update schedule the die tick when dry, the block tick writes the dead block (flags 2) when dry; wet does nothing (trigger 1 PL 2 ST 3 BT, wet; schedule, dead write, flags)',"GC7-CORAL-BLOCK",[(t,w) for t in (1,2,3) for w in (0,1)],2,3,blk)
    def die(w): return (int(not w),0,2 if not w else 0)
    run(g,'plant die tick (2.4, 2.5, 2.6): dry writes the dead state with waterlogged false (flags 2), wet nothing (wet; dead, waterlogged, flags)',"GC7-CORAL-DIE",[(0,),(1,)],1,3,die)
    def st(alive,down,surv,w,wl):
        if alive:
            if down and not surv: return (1,0,0)
            return (0,int(not w),wl)
        return (int(down and not surv),0,wl)
    stc=[(a,d,s,w,wl) for a in (1,0) for d in (1,0) for s in (1,0) for w in (0,1) for wl in (0,1)]
    run(g,'shape update (2.4, 2.6): an alive block returns air when the support side update cannot survive, else schedules the die tick when dry and a fluid tick when waterlogged; a dead one schedules the fluid tick and then gives air (alive, support side, survives, wet, waterlogged; air, die tick, fluid tick)',"GC7-CORAL-ST",stc[:16],5,3,st)
    run(g,'shape update continued (2.4, 2.6): the other half of the combinations',"GC7-CORAL-ST",stc[16:],5,3,st)
    run(g,'placement state (2.4): waterlogged = the fluid at the clicked position is water and full; the fluid state is the water source when waterlogged (water, full; waterlogged, source)',"GC7-CORAL-PLACE",[(1,1),(1,0),(0,1),(0,0)],2,2,lambda w,f:(int(w and f),int(w and f)))
    def shp(f,fc):
        if f==1: return (2,0,2,14,15,14)
        if f==2: return (2,0,2,14,4,14)
        return {1:(0,4,5,16,12,16),3:(0,4,0,16,12,11),2:(0,4,0,11,12,16),4:(5,4,0,16,12,16)}[fc]
    run(g,'shapes (2.4 to 2.6, pixels x0 y0 z0 x1 y1 z1): the plant column(12, 0, 15), the fan column(12, 0, 4), the wall fan boxZ(16, 8, 5, 16) turned to each facing (form 1 plant 2 fan 3 wall fan, facing 1 N 2 E 3 S 4 W)',"GC7-CORAL-SHAPE",[(1,1),(2,1),(3,1),(3,2),(3,3),(3,4)],2,6,shp)
    def opp(f): return {1:3,2:4,3:1,4:2,5:6,6:5}[f]
    run(g,'opposite direction (2.6, wall fan placement, 7 placement): N S, E W, up down',"GC7-OPPOSITE",[(f,) for f in range(1,7)],1,1,opp)
    def rot(f,r): return f if f>4 else (f-1+r)%4+1
    run(g,'rotate (2.6, 7.2): facing turned clockwise by 0 to 3 quarter turns; vertical never changes',"GC7-ROTATE",[(1,1),(2,1),(3,1),(4,1),(1,2),(2,3),(4,3),(3,0),(5,1),(6,2)],2,1,rot)
    def mir(f,m):
        if m==1 and f in(1,3): return rot(f,2)
        if m==2 and f in(2,4): return rot(f,2)
        return f
    run(g,'mirror (2.6, 7.2): rotation of the mirror\'s rotation of facing: left-right (1) turns north and south by 180, front-back (2) east and west, none (0) nothing',"GC7-MIRROR",[(f,m) for f in (1,2,3,4,5) for m in (0,1,2)],2,1,mir)
    def wf(dirs,sv):
        for d in dirs:
            if d>4: continue
            f=opp(d)
            if sv[f-1]: return f
        return 0
    wfc=[([2,1,6,3,4,5],[0,0,0,0]),([2,1,6,3,4,5],[0,0,0,1]),([2,1,6,3,4,5],[1,0,0,1]),([2,1,6,3,4,5],[1,0,1,0]),([5,6,3,1,2,4],[0,0,0,0]),([5,6,3,1,2,4],[0,1,0,0]),([6,5,4,3,2,1],[1,1,1,1]),([5,6,5,6,5,6],[1,1,1,1])]
    g.run('wall fan placement (2.6, worked example 2): the nearest looking directions in order, vertical ones skipped, facing = the direction\'s opposite; the first facing that can survive wins, none gives no state (0) (directions N1 E2 S3 W4 up5 down6, survive per facing)',[S(*d,*s) for d,s in wfc],'CALL "GC7-WALLFAN-PLACE" USING WS-ISG WS-R(1)',1," ".join(str(wf(d,s)) for d,s in wfc))
    g.run('dead coral block and registry data (2.2): strength 1.5 and 6.0 (x 10), forceSolidOn on dead, off on alive, no tick, requires the correct tool',[str(i) for i in range(1,7)],'CALL "GC7-CORAL-BLOCK-DATA" USING WS-I(1) WS-R(1)',1,"15 60 1 0 0 1")
    COL=["blue","pink","purple","red","yellow"]
    textcase(g,'map colours (2.2): tube blue, brain pink, bubble purple, fire red, horn yellow; every dead species gray','GC7-CORAL-COLOUR',[("%d 0"%(i+1),'WS-I(1) WS-I(2)') for i in range(5)]+[("%d 1"%(i+1),'WS-I(1) WS-I(2)') for i in (0,4)],COL+["gray","gray"])
    W(g,2)
# ===== 3
if not ONLY or 3 in ONLY:
    g=GG(3,'Turtle egg','T0649','the shape, placement, replacement, the random tick gate and stages, trampling and breaking.')
    g.extra=DOC
    run(g,'shape (3): one egg box(3, 0, 3, 12, 7, 12), more column(14, 0, 7)',"GC7-EGG-SHAPE",[(1,),(2,),(4,)],1,6,lambda e:(3,0,3,12,7,12) if e==1 else (1,0,1,15,7,15))
    run(g,'placement (3.1): a turtle egg at the clicked position gets eggs = min(4, eggs + 1), else the default 1 (clicked is egg, eggs)',"GC7-EGG-PLACE",[(0,1),(1,1),(1,3),(1,4)],2,1,lambda c,e:min(4,e+1) if c else 1)
    run(g,'replaceable (3.1): true when not secondary use, the held item is the egg and eggs < 4, else the default rule (0) (secondary, held egg, eggs)',"GC7-EGG-REPLACEABLE",[(0,1,1),(0,1,3),(0,1,4),(1,1,1),(0,0,1)],3,1,lambda s,h,e:int((not s) and h and e<4))
    run(g,'onPlace (3.1): sand below on a server level fires level event 2012 with data 15, else nothing (sand, server; event, data)',"GC7-EGG-ONPLACE",[(1,1),(1,0),(0,1),(0,0)],2,2,lambda s,sv:(2012,15) if s and sv else (0,0))
    def attr(t):
        t%=24000
        return 1000000 if 21062<=t<=21904 else 2000
    run(g,'turtle_egg_hatch_chance (3.2, x 1e6): 0.002 before tick 21062, 1.0 from 21062 to 21904, 0.002 from 21905, repeating with the day',"GC7-EGG-ATTR",[(t,) for t in (0,21061,21062,21500,21904,21905,23999,24000+21062,48000+21904)],1,1,attr)
    def gate(c,d):
        if c<=0: return (0,0)
        return (int(d*1e6<c),1)
    run(g,'hatch gate (3.2 step 1): the float is drawn only when the chance is above 0 and must be below it (chance x 1e6, nextFloat; gate, drew)',"GC7-EGG-GATE",[(2000,0.001),(2000,0.0021),(2000,0.5),(1000000,0.99),(1000000,0.0),(0,0.1)],2,2,gate,infx=(2,))
    def rt(g_,sand,h,e):
        if not(g_ and sand): return (0,h,0,0,0,0)
        if h<2: return (1,h+1,0,1,1,0)
        return (2,h,e,0,2,e)
    rtc=[(0,1,0,1),(1,0,0,1),(0,0,2,2),(1,1,0,1),(1,1,1,3),(1,1,2,2),(1,1,2,4)]
    run(g,'random tick (3.2 steps 2 to 4): the gate and sand below must both hold; below hatch 2 crack (hatch + 1, flags 2, onPlace runs again), at 2 hatch (block removed, one level event 2001 and one baby per egg) (gate, sand, hatch, eggs; action 1 crack 2 hatch, hatch, babies, onPlace again, game event 1 block_change 2 block_destroy, events 2001)',"GC7-EGG-RT",rtc,4,6,rt)
    run(g,'sound pitch (3.2, 3.3): volume 0.7, pitch 0.9 + nextFloat x 0.2 (x 1e6) for crack, hatch and break (nextFloat; volume x 100, pitch)',"GC7-PITCH",[(0.0,),(0.5,),(0.25,),(0.9999,)],1,2,lambda f:(70,rnd((0.9+f*0.2)*1e6)),infx=(1,))
    run(g,'baby turtle (3.2 step 4, worked example 4): spawn x = x + 0.3 + i x 0.2 and z = z + 0.3 (x 1000), age -24000, spawn reason breeding (egg index; x, z, age)',"GC7-EGG-BABY",[(0,),(1,),(2,),(3,)],1,3,lambda i:(300+200*i,300,-24000))
    def cd(k,sp,mg):
        if k in(1,2): return 0
        if k==3: return int(not sp)
        if k==4: return mg
        return 0
    cdc=[(1,0,1),(2,0,1),(3,0,1),(3,1,1),(4,0,1),(4,0,0),(5,0,1)]
    run(g,'canDestroyEgg (3.3): a turtle or bat never; a player unless under spawn protection; another living entity by mob_griefing; any other entity never (kind 1 turtle 2 bat 3 player 4 other living 5 other, spawn protected, mob_griefing)',"GC7-EGG-CAN",cdc,3,1,cd)
    def ds(e,sv,c,ch,d):
        if e and sv and c: return (int(d==0),1)
        return (0,0)
    dsc=[(1,1,1,100,0),(1,1,1,100,57),(1,1,1,3,0),(1,1,1,3,2),(0,1,1,3,0),(1,0,1,3,0),(1,1,0,3,0)]
    run(g,'destroyEgg (3.3): the state is an egg, server level and canDestroyEgg checked in that order, then nextInt(chance) must be 0 (egg, server, can, chance, the draw; destroyed, drew)',"GC7-EGG-DESTROY",dsc,5,2,ds)
    def stp(t,c,z):
        if t==1: return 0 if c else 100
        return 0 if z else 3
    run(g,'which chance a call uses (3.1, worked example 3): stepOn 100 unless stepping carefully; fallOn 3 unless the entity is a zombie (trigger 1 stepOn 2 fallOn, careful, zombie)',"GC7-EGG-CHANCE",[(1,0,0),(1,1,0),(2,0,0),(2,0,1),(2,1,0)],3,1,stp)
    def dec(e):
        if e<=1: return (1,0,1,0)
        return (0,e-1,1,1)
    run(g,'decreaseEggs (3.3): break sound; one egg destroys the block, more lower eggs by 1 (flags 2) with game event block_destroy and level event 2001 (eggs; destroyed, eggs, level event, game event)',"GC7-EGG-DECREASE",[(1,),(2,),(3,),(4,)],1,4,dec)
    W(g,3)
# ===== 4
if not ONLY or 4 in ONLY:
    g=GG(4,'Sniffer egg','T0651','the constants, shape, the onPlace schedule, the stage tick and the baby sniffer.')
    g.extra=DOC
    run(g,'constants (4): regular hatch 24000, boosted 12000, random offset 300',"GC7-SNIFFER-CONST",[(1,),(2,),(3,)],1,1,lambda i:[24000,12000,300][i-1])
    g.run('shape (4): column(14, 12, 0, 16), 14 wide in x and 12 in z over the full height',["0"],'CALL "GC7-SNIFFER-SHAPE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,"1/0/2/15/16/14")
    def pl(b,sv,d):
        tot=12000 if b else 24000
        return (3009 if b and sv else 0,tot,tot//3,tot//3+d,1)
    run(g,'onPlace (4): a moss block below on the server fires level event 3009 (data 0); total 12000 or 24000, stage a third, next tick at stage + nextInt(300), game event block_place (boost, server, draw; event, total, stage, delay, game event)',"GC7-SNIFFER-PLACE",[(1,1,0),(1,1,123),(1,0,299),(0,1,0),(0,1,299),(0,0,150)],3,5,pl)
    g.case('timing (4, worked example 5): moss gives three stages of 4000 + nextInt(300), 12000 to 12897 ticks in all; otherwise 8000 + nextInt(300) per stage, 24000 to 24897',[("1 1 0",'CALL "GC7-SNIFFER-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5),("0 1 299",'CALL "GC7-SNIFFER-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5)],"3009/12000/4000/4000/1 0/24000/8000/8299/1")
    def tk(h):
        if h!=2: return (1,h+1,1,0)
        return (2,h,0,1)
    run(g,'block tick (4): not ready (hatch 0 or 1) cracks, setBlock hatch + 1 with flags 2, whose onPlace schedules the next stage; at 2 the egg hatches: block destroyed and a baby sniffer created (hatch; action 1 crack 2 hatch, hatch, onPlace again, baby)',"GC7-SNIFFER-TICK",[(0,),(1,),(2,)],1,4,tk)
    def yaw(f):
        v=(f*360.0)%360.0
        if v>=180: v-=360
        return rnd(v*1000)
    run(g,'baby sniffer yaw (4, worked example 5): wrapDegrees(nextFloat x 360), in [-180, 180) (x 1000)',"GC7-SNIFFER-YAW",[(0.0,),(0.25,),(0.4999,),(0.5,),(0.75,),(0.9999,)],1,1,yaw,infx=(1,))
    W(g,4)
