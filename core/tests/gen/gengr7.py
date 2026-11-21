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
# ===== 5
if not ONLY or 5 in ONLY:
    g=GG(5,'Frogspawn','T0653','the shape, support, hatch delay, triggers, tadpole count and spawn offsets.')
    g.extra=DOC
    g.run('shape (5): column(16, 0, 1.5), a 1.5 pixel film (box x0 y0 z0 x1, y1 x 10, z1)',["0"],'CALL "GC7-FROG-SHAPE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,"0/0/0/16/15/16")
    run(g,'support (5): (supporting fluid or supporting block below) and no fluid above (fluid below, block below, fluid above empty)',"GC7-FROG-SURVIVE",[(f,b,e) for f in (0,1) for b in (0,1) for e in (0,1)],3,1,lambda f,b,e:int((f or b) and e))
    run(g,'hatch delay (5, validation): 3600 + nextInt(8400), 3600 to 11999',"GC7-FROG-DELAY",[(0,),(8399,),(1234,)],1,1,lambda d:3600+d)
    def tr(t,s,f):
        if t==1: return 1
        if t==2: return 0 if s else 2
        if t==3: return 4 if s else 3
        return 3 if f else 0
    run(g,'triggers (5): PL schedules the hatch, ST gives air when it cannot survive, BT destroys when it cannot survive else hatches, a falling block entity inside destroys (trigger 1 PL 2 ST 3 BT 4 entity inside, survives, falling block; 0 none 1 schedule 2 air 3 destroy 4 hatch)',"GC7-FROG-TRIGGER",[(1,1,0),(2,1,0),(2,0,0),(3,1,0),(3,0,0),(4,1,1),(4,1,0)],3,1,tr)
    run(g,'tadpoles (5): nextInt(2, 6) gives 2 to 5, yaw nextInt(1, 361) gives 1 to 360, y = pos.y - 0.5 (x 1000) (count draw, yaw draw; tadpoles, yaw, y offset)',"GC7-FROG-TADPOLES",[(0,0),(3,359),(1,100)],2,3,lambda c,y:(2+c,1+y,-500))
    def off(d): return rnd(min(max(d,0.20000000298023224),0.7999999970197678)*1e9)
    run(g,'spawn offset (5): clamp(nextDouble, 0.2, 0.8) with the float constants widened (x 1e9), worked example 6',"GC7-FROG-OFFSET",[(0.0,),(0.1,),(0.5,),(0.75,),(0.9,),(0.2,)],1,1,off,infx=(1,))
    W(g,5)
# ===== 6
if not ONLY or 6 in ONLY:
    g=GG(6,'Honey block','T0655','the constants, the sliding test, slide movement and effects, entityInside and landing.')
    g.extra=DOC
    HC=[13,8,5,20,4,5,1,15,15]
    run(g,'constants (6): slide at vertical speed 0.13, minimum fall 0.08, throttled 0.05 (x 100), achievement check every 20 ticks, speed factor 0.4 and jump factor 0.5 (x 10), collision column(14, 0, 15) x0, x1, height',"GC7-HONEY-CONST",[(i,) for i in range(1,10)],1,1,lambda i:HC[i-1])
    run(g,'which entities slide (6.1): a living entity, a minecart, primed TNT or a boat (kind 1 to 4); anything else does not',"GC7-HONEY-SLIDES",[(k,) for k in range(1,6)],1,1,lambda k:int(k<=4))
    def sl(gr,py,px,pz,ey,vy,ex,ez,wd):
        if gr: return 0
        if ey>py+0.9375-1e-7: return 0
        o=vy/0.9800000190734863+0.08
        if not o<-0.08: return 0
        dx=abs(px+0.5-ex); dz=abs(pz+0.5-ez); w=0.4375+wd/2
        return int(dx+1e-7>w or dz+1e-7>w)
    slc=[(0,64,0,0,64.9,-0.5,0.9,0.5,0.6),(0,64,0,0,64.9,-0.5,1.25,0.5,0.6),(0,64,0,0,64.9,-0.5,1.3,0.5,0.6),(1,64,0,0,64.9,-0.5,1.25,0.5,0.6),(0,64,0,0,65.0,-0.5,1.25,0.5,0.6),(0,64,0,0,64.9,-0.05,1.25,0.5,0.6),(0,64,0,0,64.9,-0.5,0.5,1.3,0.6),(0,64,0,0,64.9,-0.5,0.5,0.5,0.6),(0,64,0,0,64.9,-0.5,1.2374,0.5,0.6),(0,64,0,0,64.9,-0.5,1.2376,0.5,0.6),(0,64,0,0,64.9,-0.5,-0.2376,0.5,0.6),(0,64,3,-2,64.0,-0.2,3.5,-1.2,0.6)]
    g.run('sliding test (6.2, worked example 7): not on the ground, y at most pos.y + 0.9375 - 1e-7, old vertical speed below -0.08, and hanging outside the centre column on x or z (width 0.4375 + width / 2) (on ground, pos y, pos x, pos z, y, vy, x, z, width)',[S(*c) for c in slc],'CALL "GC7-HONEY-SLIDING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-FX(5) WS-FX(6) WS-FX(7) WS-FX(8) WS-FX(9) WS-R(1)',1," ".join(str(sl(*c)) for c in slc))
    def mv(vx,vy,vz):
        o=vy/0.9800000190734863+0.08
        nd=(-0.05-0.08)*0.9800000190734863
        if o<-0.13:
            f=-0.05/o
            r=(o,f,vx*f,nd,vz*f)
        else: r=(o,1.0,vx,nd,vz)
        vals=tuple(rnd(x*1e6) for x in r)
        for x in r: assert abs((x*1e6)%1-0.5)>0.01,(vx,vy,vz,x)
        return vals
    mvc=[(1.0,-0.5,0.5),(0.2,-0.2,-0.4),(0.3,-0.2,0.7),(0.5,-0.15,0.1),(0.4,-0.1,0.3),(2.0,-1.0,-1.0)]
    g.run('slide movement (6.3, worked example 7): o = vy / 0.9800000190734863 + 0.08; below -0.13 the horizontal speed is scaled by -0.05 / o, else kept; vy becomes (-0.05 - 0.08) x 0.9800000190734863 = -0.1274 (x 1e6: o, factor, vx, vy, vz)',[S(*c) for c in mvc],'CALL "GC7-HONEY-MOVE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(*mv(*c)) for c in mvc))
    def ins(s,p,t): return (int(s and p and t%20==0),int(s),int(s))
    run(g,'entityInside (6.3): sliding gives the advancement check for a server player on game time multiples of 20, then movement and effects; not sliding nothing (sliding, server player, game time; advancement, movement, effects)',"GC7-HONEY-INSIDE",[(1,1,40),(1,1,41),(1,0,40),(0,1,40),(0,0,7)],3,3,ins)
    def ef(el,d1,sv,d2):
        if not el: return (0,0,0)
        s=int(d1==0)
        if sv: return (s,int(d2==0),1)
        return (s,0,0)
    run(g,'slide effects (6.3): only the entities of 6.1; nextInt(5) = 0 plays the sound, on the server only an independent nextInt(5) = 0 broadcasts entity event 53 (eligible, first draw, server, second draw; sound, event 53, second draw made)',"GC7-HONEY-EFFECTS",[(1,0,1,0),(1,3,1,0),(1,0,1,4),(1,0,0,0),(1,2,0,0),(0,0,1,0)],4,3,ef)
    def ld(sv,dm,vol,pit):
        return (54 if sv else 0,20,int(dm),rnd(vol*0.5*1000) if dm else 0,rnd(pit*0.75*1000) if dm else 0)
    ldc=[(1,1,1.0,1.0),(1,0,1.0,1.0),(0,1,0.8,1.2),(0,0,0.8,1.2)]
    g.run('landing (6.4): slide sound, on the server entity event 54, fall damage with multiplier 0.2 (x 100), and when damage was dealt the fall sound at volume x 0.5 and pitch x 0.75 (x 1000) (server, damage dealt, sound volume, sound pitch; event 54, multiplier, fall sound, volume, pitch)',[S(*c) for c in ldc],'CALL "GC7-HONEY-LAND" USING WS-I(1) WS-I(2) WS-FX(3) WS-FX(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(*ld(*c)) for c in ldc))
    W(g,6)
# ===== 7
if not ONLY or 7 in ONLY:
    g=GG(7,'Beehive and bee nest','T0657','the item interactions, harvest outcomes, destruction, shape update, creative break, drops, pick block, anger and constants.')
    g.extra=DOC
    run(g,'constants (7): MAX_HONEY_LEVELS 5, bee_nest hardness 0.3 and beehive 0.6 (x 10)',"GC7-BEE-DATA",[(1,),(2,),(3,)],1,1,lambda i:[5,3,6][i-1])
    def use(lvl,item,sv,sm,be,hb):
        done=0;combs=0
        if lvl>=5:
            if item==1 and sv: done=1;combs=3
            elif item==2: done=1
        st=int(sv and done)
        an=rl=rs=0
        if done:
            if not sm: an=int(hb);rl=int(be);rs=1
            else: rs=1
        return (done,combs,st,an,rl,rs,done)
    uc=[(5,1,1,0,1,1),(5,1,1,0,1,0),(5,1,1,0,0,0),(5,1,1,1,1,1),(5,1,0,0,1,1),(5,2,1,0,1,1),(5,2,0,1,1,0),(4,1,1,0,1,1),(4,2,1,0,1,1),(5,3,1,0,1,1),(0,2,1,0,1,1)]
    run(g,'item use (7.1, worked example 8): at honey level 5 shears (server only) roll 3 honeycomb and a glass bottle (both sides) fills; then without a smoky campfire bees are angered when there are some and released when the block entity exists, with one only the level resets (level, item 1 shears 2 bottle 3 other, server, smoky, block entity exists, has bees; done, honeycomb, stat, anger, release, reset, result 1 success 0 base)',"GC7-BEE-USE",uc,6,7,use)
    def bt(c,room):
        r=c-1
        if r==0: return (r,1,0,0)
        return (r,0,int(room),int(not room))
    run(g,'glass bottle result (7.1): the stack shrinks; an empty stack gets the honey_bottle in that hand, else it goes to the inventory, and when that fails it is dropped (count, inventory has room; count left, in hand, in inventory, dropped)',"GC7-BEE-BOTTLE",[(1,1),(1,0),(3,1),(3,0)],2,4,bt)
    def de(h,s):
        if not h: return (0,0,0,0)
        if s: return (0,0,0,1)
        return (1,1,1,1)
    run(g,'destroyed by a player (7.2): with a hive block entity and a tool without prevents_bee_spawns_when_mining the bees leave, neighbours update and nearby bees are angered; the criterion bee_nest_destroyed fires in every hive case (is hive, silk touch tag; empty hive, update neighbours, anger, criterion)',"GC7-BEE-DESTROY",[(1,0),(1,1),(0,0),(0,1)],2,4,de)
    run(g,'shape update (7.2): a FireBlock at the changed neighbour with a hive block entity empties the hive with no player (neighbour is fire, hive; empties)',"GC7-BEE-NEIGHBOUR",[(1,1),(1,0),(0,1),(0,0)],2,1,lambda f,h:int(f and h))
    def wd(sv,cr,bd,hv,hb,lv):
        sp=int(sv and cr and bd and hv and (hb or lv>0))
        return (sp,lv if sp else 0)
    wdc=[(1,1,1,1,1,0),(1,1,1,1,0,3),(1,1,1,1,0,0),(1,1,1,1,1,5),(0,1,1,1,1,2),(1,0,1,1,1,2),(1,1,0,1,1,2),(1,1,1,0,1,2)]
    run(g,'playerWillDestroy (7.2): only on a server for a creative player with block_drops true and a hive block entity, when it holds bees or honey_level > 0 an item is spawned carrying the honey level (server, preventsBlockDrops, block_drops, hive, has bees, level; spawned, level in block_state)',"GC7-BEE-WILL-DESTROY",wdc,6,2,wd)
    run(g,'drops (7.2): primed TNT, creeper, wither skull, wither boss or TNT minecart (kinds 1 to 5) breaking a hive empties it with no player; other entities do not (kind, hive; empties)',"GC7-BEE-DROPS",[(k,h) for k in (1,2,3,4,5,6) for h in (1,)]+[(1,0)],2,1,lambda k,h:int(k<=5 and h))
    run(g,'pick block (7.2): with includeData the stack also carries the block_state honey_level (includeData, level; has component, value)',"GC7-BEE-CLONE",[(1,3),(0,3),(1,0)],2,2,lambda d,l:(int(d),l if d else 0))
    def an(b,p,u): return (8,6,8,u if b>0 and p>0 else 0)
    run(g,'angerNearbyBees (7.2): the box is the block inflated by 8, 6, 8; only when bees and players are both present each bee without a target gets a random player (bees, players, bees without a target; box x, y, z, bees given a target)',"GC7-BEE-ANGER",[(3,1,2),(3,0,2),(0,2,0),(0,0,0),(2,2,2),(1,3,0)],3,4,an)
    g.run('explosion hit (7.2): after the base, nearby bees are angered',["0"],'CALL "GC7-BEE-EXPLODE" USING WS-R(1)',1,"1")
    g.run('placement (7): facing is the opposite of the placer\'s horizontal direction; rotate and mirror act on facing as for the wall fan',["1","2","3","4"],'CALL "GC7-OPPOSITE" USING WS-I(1) WS-R(1)',1,"3 4 1 2")
    def dr(l,f,d): return (int(l>=5),int(l>=5 and not f and d<0.3))
    run(g,'animateTick (7.3, client): at honey level 5 one attempt per tick, a dripping_honey particle with probability 0.3 when the block holds no fluid (level, holds fluid, draw; attempt, particle)',"GC7-BEE-DRIP",[(5,0,0.1),(5,0,0.5),(5,1,0.1),(4,0,0.1),(0,0,0.0)],3,2,dr,infx=(3,))
    W(g,7)
def TBL(name,cnt): return " 01 WS-%sG.\n    05 WS-%s BINARY-LONG OCCURS %d TIMES.\n"%(name,name,cnt)
def setarr(name,vals): return "".join('MOVE %d TO WS-%s(%d)\n'%(v,name,i+1) for i,v in enumerate(vals))
# ===== 8
if not ONLY or 8 in ONLY:
    g=GG(8,'Cauldrons','T0659','the family model, shapes, the interaction tables, bucket, bottle and clean rows, createFilledResult, precipitation, drips and entities on fire.')
    g.extra=TBL('A12',12)
    def fam(c,l):
        if c==1: return (0,0,0,0,0,1)
        if c==4: return (3,15,1,3,3,0)
        return (l,6+3*l,int(l==3),1 if c==2 else 2,1,1)
    fc=[(1,0),(2,1),(2,2),(2,3),(3,1),(3,3),(4,0)]
    run(g,'family model (8.1): comparator, content height pixels, isFull, fluid (1 water 2 powder snow 3 lava), inside effects, precipitation handler, per class 1 empty 2 water 3 powder snow 4 lava and level',"GC7-CAULDRON-FAMILY",fc,2,6,fam)
    def bx(p,l):
        return {1:(0,0,4,16,3,12),2:(4,0,0,12,3,16),3:(2,0,2,14,3,14),4:(2,4,2,14,16,14),5:(2,4,2,14,6+3*l,14),6:(2,4,2,14,15,14)}[p]
    run(g,'shapes (8.1, 8.3, 8.4, pixels x0 y0 z0 x1 y1 z1): the three leg and wall columns, SHAPE_INSIDE (floor top at 4), the layered fill 6 + 3 x level and the lava fill 15 (part, level)',"GC7-CAULDRON-BOX",[(1,0),(2,0),(3,0),(4,0),(5,1),(5,2),(5,3),(6,0)],2,6,bx)
    CC=[50,100,1,3,6,3,4]
    run(g,'constants (8.2, 8.3): RAIN_FILL_CHANCE 0.05 and POWDER_SNOW_FILL_CHANCE 0.1 (x 1000), MIN_FILL_LEVEL 1, MAX_FILL_LEVEL 3, BASE_CONTENT_HEIGHT 6, HEIGHT_PER_LEVEL 3, FLOOR_LEVEL 4',"GC7-CAULDRON-CONST",[(i,) for i in range(1,8)],1,1,lambda i:CC[i-1])
    def dsp(d,it):
        if d==2 and it==7: return 8
        if it in(1,2,3): return it
        T={(1,4):4,(2,5):5,(2,6):6,(2,4):7,(2,8):9,(2,9):10,(4,5):11,(3,5):12}
        return T.get((d,it),0)
    dc=[(d,i) for d in (1,2,3,4) for i in range(1,12)]
    for a in range(0,len(dc),11):
        run(g,'dispatcher lookup (8.1, 8.5): tag entries first, then item entries, DEFAULT gives 0 (try with empty hand); items 1 lava_bucket 2 water_bucket 3 powder_snow_bucket 4 potion 5 bucket 6 glass_bottle 7 dye tag 8 banner 9 dyed shulker box 10 plain shulker box 11 other (1 empty 2 water 3 powder snow 4 lava) ids 1-3 buckets, 4 potion in, 5 bucket out water, 6 bottle, 7 potion add, 8 dye, 9 banner, 10 shulker, 11 bucket out lava, 12 bucket out snow, group %d'%(a//11+1),"GC7-CAULDRON-DISPATCH",dc[a:a+11],2,1,dsp)
    def bi(it,wa,sv):
        if it==1:
            if wa: return (2,0,0,0,0)
            return (1,4,0,1,int(sv))
        if it==2: return (1,2,3,2,int(sv))
        if wa: return (2,0,0,0,0)
        return (1,3,3,3,int(sv))
    run(g,'bucket into any cauldron (8.5): lava and powder snow are refused (consume) under water, water never; each overwrites the contents at full level; only the server changes the block (bucket 1 lava 2 water 3 powder snow, water above, server; result 1 success 2 consume, class, level, sound 1 bucket_empty_lava 2 bucket_empty 3 bucket_empty_powder_snow, changed)',"GC7-CAULDRON-BUCKET-IN",[(i,w,s) for i in (1,2,3) for w in (0,1) for s in (0,1)],3,5,bi)
    def fb(c,l,sv):
        can=(l==3) if c in(2,3) else True
        if not can: return (0,0,0,c,0)
        k={2:(1,1),4:(2,2),3:(3,3)}[c]
        return (1,k[0],k[1],1,int(sv))
    run(g,'fillBucket (8.5): only a full water or powder snow cauldron and any lava cauldron give their bucket back and become empty; otherwise try with the empty hand (class 2 water 3 powder snow 4 lava, level, server; result, filled bucket, sound, class, changed)',"GC7-CAULDRON-FILL",[(2,3,1),(2,3,0),(2,2,1),(2,1,1),(3,3,1),(3,2,1),(4,0,1),(4,0,0)],3,5,fb)
    def bo(c,it,l,sv):
        z=(0,c,l,0,0,0,0)
        if c==1:
            if it==1: return (1,2,1,1,1,1,int(sv))
            return z
        if it==4:
            nl=l-1
            return (1,1 if nl==0 else 2,nl,2,2,2,int(sv))
        if it==1:
            if l==3: return z
            return (1,2,l+1,1,1,1,int(sv))
        return z
    boc=[(1,1,0,1),(1,2,0,1),(1,3,0,1),(1,4,0,1),(1,1,0,0),(2,4,3,1),(2,4,2,1),(2,4,1,1),(2,4,1,0),(2,1,1,1),(2,1,2,1),(2,1,3,1),(2,2,1,1),(2,3,1,1)]
    run(g,'bottles (8.5): an empty cauldron takes a plain water potion (level 1 water cauldron, bottle_empty, fluid_place, glass bottle); a water cauldron gives a water potion for a glass bottle at any level (lowerFillLevel, bottle_fill, fluid_pickup) and takes a plain potion below level 3 (class 1 empty 2 water, item 1 plain water potion 2 other potion 3 no potion contents 4 glass bottle, level, server; result, class, level, sound 1 bottle_empty 2 bottle_fill, game event 1 fluid_place 2 fluid_pickup, hand 1 glass bottle 2 water potion, changed)',"GC7-CAULDRON-BOTTLE",boc,4,7,bo)
    def lo(c,l):
        n=l-1
        return (1,0) if n==0 else (c,n)
    run(g,'lowerFillLevel (8.3): level - 1, the empty cauldron at 0, else the same block (class, level; class, level)',"GC7-CAULDRON-LOWER",[(2,3),(2,2),(2,1),(3,2),(3,1)],2,2,lo)
    def cl(k,c,sv):
        if k==2: ok=c>0
        else: ok=c==1
        if not ok: return (0,0,0,c)
        return (1,k if sv else 0,int(sv),c-1 if (k==2 and sv) else c)
    clc=[(1,1,1),(1,1,0),(1,0,1),(2,2,1),(2,1,1),(2,2,0),(2,0,1),(3,1,1),(3,1,0),(3,0,1)]
    run(g,'cleaning (8.5): dyed_color, a banner with layers, a dyed shulker box; the server awards clean_armor 1, clean_banner 2 or clean_shulker_box 3, lowers the level and a banner loses its top layer (kind 1 dye 2 banner 3 shulker, has dye or layer count or is shulker, server; result, stat, lowered, layers)',"GC7-CAULDRON-CLEAN",clc,3,4,cl)
    def fr(inf,lim,n,has,room):
        if inf and lim: return (n,0,int(not has),0)
        r=n-1
        if r==0: return (r,1,0,0)
        return (r,0,int(room),int(not room))
    frc=[(1,1,1,0,1),(1,1,1,1,1),(1,0,3,0,1),(0,1,1,0,1),(0,1,3,0,1),(0,1,3,0,0),(0,0,1,0,1),(1,1,5,0,0)]
    run(g,'createFilledResult (8.5): a creative player with limitToOne adds the result only when the inventory lacks it and keeps the stack; otherwise the stack shrinks and an empty stack becomes the result, else it goes to the inventory or is dropped (infinite materials, limit to one, count, inventory has it, room; count left, in hand, added, dropped)',"GC7-FILLED-RESULT",frc,5,4,fr)
    def pr(c,p,d,l):
        if c==4: return (0,4,0,0)
        drew=int(p in(1,2)); ch=0.05 if p==1 else 0.1
        h=drew and d<ch
        if c==1:
            if h: return (drew,2 if p==1 else 3,1,1)
            return (drew,1,0,0)
        own=1 if c==2 else 2
        if h and l!=3 and p==own: return (drew,c,l+1,1)
        return (drew,c,l,0)
    prc=[(1,1,0.03,0),(1,1,0.06,0),(1,2,0.09,0),(1,2,0.11,0),(1,0,0.0,0),(2,1,0.01,1),(2,1,0.01,3),(2,2,0.01,2),(2,1,0.9,2),(3,2,0.01,2),(3,2,0.01,3),(3,1,0.01,1),(3,0,0.0,1),(4,1,0.0,0)]
    run(g,'precipitation (8.2, 8.3, 8.7): one nextFloat for rain (below 0.05) or snow (below 0.1), none for another type; an empty cauldron becomes a level 1 water or powder snow cauldron, a layered one gains a level only for its own type below level 3, the draw is spent either way, lava has no handler (class, type 1 rain 2 snow 0 other, nextFloat, level; draw made, class, level, game event block_change)',"GC7-CAULDRON-PRECIP",prc,4,4,pr,infx=(3,))
    def dp(c,f,l):
        can={1:1,2:int(f==1),3:0,4:0}[c]
        if not can: return (0,c,l,0)
        if c==1:
            if f==1: return (1,2,1,1047)
            if f==3: return (1,4,0,1046)
            return (1,1,0,0)
        if l<3: return (1,2,l+1,1047)
        return (1,2,l,0)
    dpc=[(1,1,0),(1,3,0),(1,0,0),(2,1,1),(2,1,3),(2,3,1),(3,1,1),(3,3,2),(4,1,0),(4,3,0)]
    run(g,'drip fill (8.2, 8.3, 8.6): an empty cauldron takes water (level 1 water cauldron, event 1047) and lava (lava cauldron, event 1046); a water cauldron only water, one level up unless full; powder snow and lava cauldrons never (class, fluid 1 water 3 lava 0 other, level; can receive, class, level, event)',"GC7-CAULDRON-DRIP",dpc,3,4,dp)
    run(g,'AbstractCauldronBlock.tick (8.6): receives only when a stalactite tip is found above, the fill fluid is not EMPTY and canReceiveStalactiteDrip holds (tip, fluid, can)',"GC7-DRIP-TICK",[(1,1,1),(1,3,1),(1,0,1),(1,1,0),(0,1,1)],3,1,lambda t,f,c:int(t and f!=0 and c))
    run(g,'canFillCauldron (8.6): water and lava only (fluid 1 water 2 flowing 3 lava 0 empty)',"GC7-CAN-FILL",[(0,),(1,),(2,),(3,)],1,1,lambda f:int(f in(1,3)))
    run(g,'scheduled tick delay (8.6): (tip y - cauldron y) + 50 (tip y, cauldron y)',"GC7-DRIP-DELAY",[(64,60),(70,60),(61,60)],2,1,lambda t,c:50+t-c)
    def th(r,f):
        stop=int(r>0.17578125 and r>0.05859375)
        thr={1:17578125,3:5859375}.get(f,0)
        return (stop,thr,int((not stop) and thr>0 and r<thr/1e8))
    thc=[(0.1,1),(0.17578125,1),(0.17578124,1),(0.2,1),(0.05859375,3),(0.05859374,3),(0.1,3),(0.01,2),(0.0,0)]
    run(g,'drip random tick gates (8.6 steps 1 and 4): a draw above 0.17578125 stops; water passes below 0.17578125 and lava below 0.05859375, other fluids never (r, fluid; stop, threshold x 1e8, passes)',"GC7-DRIP-GATE",thc,2,3,th,infx=(1,))
    run(g,'fluid above the stalactite (8.6): mud above the root with water_evaporates false is water, otherwise the fluid of the cell (mud, evaporates, fluid)',"GC7-DRIP-FLUID",[(1,0,0),(1,0,3),(1,1,3),(1,1,1),(0,0,3),(0,0,0)],3,1,lambda m,e,f:1 if m and not e else f)
    def fv(mi,cells):
        for i in range(1,mi):
            c=cells[i-1]
            if c==1: return i
            if c!=2: return 0
        return 0
    def fvcall(mi,cells): return setarr('A12',cells+[0]*(12-len(cells)))+'MOVE %d TO WS-I(1)\nCALL "GC6-FIND-VERT" USING WS-I(1) WS-A12G WS-R(1)'%mi
    sr=[(11,[2,2,2,1]),(11,[2]*9+[1]),(11,[2]*10+[1]),(11,[2,2,0,1])]
    g.case('findBlockVertical (8.6, owned by 29b-6 section 4.2): 11 gives exactly 10 steps, so the stop is found at 4, at 10 and not at 11, and a blocking cell ends the search (the 29b-6 program is asserted here)',[("0",fvcall(*c),1) for c in sr]," ".join(str(fv(*c)) for c in sr))
    g.run('canDripThrough (8.6, owned by 29b-6 section 4.2): air passes, a full opaque block and a fluid do not, otherwise the collision shape must miss the 4 x 4 shaft (air, solid, fluid, intersects; passes)',["1 0 0 0","0 1 0 0","0 0 1 0","0 0 0 1","0 0 0 0"],'CALL "GC6-DRIP-THROUGH" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,"1 0 0 0 1")
    def fi(c,l,sv,of,may):
        cb=int(sv); ch=int(sv and of and may)
        if ch:
            nl=l-1
            return (cb,1,1 if nl==0 else 2,nl,1)
        return (cb,0,c,l,1)
    fic=[(2,2,1,1,1),(2,1,1,1,1),(2,3,1,1,1),(3,2,1,1,1),(3,1,1,1,1),(2,2,1,0,1),(2,2,1,1,0),(2,2,0,1,1),(3,3,0,0,0)]
    run(g,'entity inside (8.3): on the server a callback is registered; an entity on fire that may interact lowers a water cauldron by one level (a powder snow cauldron melts to water of the same level first); the extinguish effect is requested on both sides (class, level, server, on fire, may interact; callback, changed, class, level, extinguish)',"GC7-CAULDRON-FIRE",fic,5,5,fi)
    W(g,8)
# ===== 9
if not ONLY or 9 in ONLY:
    g=GG(9,'Candles, candle cakes and cakes','T0661','the candle block rules, candle cake rules and cake rules.')
    g.extra=DOC
    run(g,'light emission (9.2): 3 per candle when lit, so 3, 6, 9, 12; 0 unlit; LIGHT_PER_CANDLE 3 (lit, candles)',"GC7-CANDLE-LIGHT",[(1,1),(1,2),(1,3),(1,4),(0,4),(0,1)],2,1,lambda l,c:3*c if l else 0)
    SH={1:(7,0,7,9,6,9),2:(5,0,6,11,6,9),3:(5,0,6,10,6,11),4:(5,0,5,11,6,10)}
    run(g,'shapes (9.2, pixels x0 y0 z0 x1 y1 z1): 1 column(2, 0, 6), 2 box(5, 0, 6, 11, 6, 9), 3 box(5, 0, 6, 10, 6, 11), 4 box(5, 0, 5, 11, 6, 10)',"GC7-CANDLE-SHAPE",[(i,) for i in range(1,5)],1,6,lambda c:SH[c])
    run(g,'placement (9.2): the same candle at the clicked position cycles candles (1 to 3 become 2 to 4), else 1; waterlogged = the fluid is water (same candle, candles, water; candles, waterlogged)',"GC7-CANDLE-PLACE",[(1,1,0),(1,2,1),(1,3,0),(1,4,0),(0,2,0),(0,1,1)],3,2,lambda s,c,w:((c%4+1) if s else 1,w))
    run(g,'replaceable (9.2): not secondary use, the held item is this candle and candles < 4, else the default rule (0) (secondary, held, candles)',"GC7-CANDLE-REPLACE",[(0,1,1),(0,1,3),(0,1,4),(1,1,1),(0,0,1)],3,1,lambda s,h,c:int((not s) and h and c<4))
    run(g,'empty hand (9.2): an empty hand with mayBuild extinguishes a lit candle (success), anything else is the base (hand empty, may build, lit; extinguish, result 1 success)',"GC7-CANDLE-USE",[(1,1,1),(1,1,0),(1,0,1),(0,1,1)],3,2,lambda e,m,l:(int(e and m and l),)*2)
    def lt(s,t,hl,hw,l,w):
        if s==1: return int(hl and t and l)
        if s==2: return int(not l)
        if s==3: return int((not w) and (not l))
        if s==4: return int(t and hl and hw and (not l) and (not w))
        return int(t and hl and (not l))
    ltc=[(1,1,1,1,1,0),(1,1,1,1,0,0),(1,0,1,1,1,0),(1,1,0,0,1,0),(2,1,1,1,0,0),(2,1,1,1,1,0),(3,1,1,1,0,0),(3,1,1,1,0,1),(3,1,1,1,1,0),(4,1,1,1,0,0),(4,1,1,1,0,1),(4,1,1,1,1,0),(4,0,1,1,0,0),(4,1,0,1,0,0),(4,1,1,0,0,0),(5,1,1,0,0,0),(5,1,1,0,1,0),(5,0,1,0,0,0),(5,1,0,0,0,0)]
    run(g,'lit tests (9.1, 9.2, 9.3): isLit, canBeLit (!lit), the candle\'s canBeLit (!waterlogged and !lit), the static candle canLight (tag, both properties, unlit, dry) and the candle cake canLight (tag, lit property, unlit) (test 1 isLit 2 canBeLit 3 candle canBeLit 4 candle canLight 5 cake canLight, in tag, has lit, has waterlogged, lit, waterlogged)',"GC7-CANDLE-TEST",ltc,6,1,lt)
    def lq(w,f,l):
        if (not w) and f: return (1,1 if l else 2,1,1)
        return (0,0,w,0)
    run(g,'placeLiquid (9.2): only when dry and the fluid is water: waterlogged is set, a lit candle is extinguished (which writes the unlit state, flags 11), else setBlockAndUpdate, then a fluid tick is scheduled (waterlogged, fluid is water, lit; placed, action 1 extinguish 2 setBlockAndUpdate, waterlogged, tick)',"GC7-CANDLE-LIQUID",[(0,1,1),(0,1,0),(1,1,0),(0,0,0),(1,0,1)],3,4,lq)
    run(g,'extinguish (9.1): setLit(false) with flags 11, one smoke particle per particle offset with velocity y 0.1 (x 10), candle_extinguish, game event block_change (kind 1 to 4 candles 5 candle cake; particles, flags, velocity, game event)',"GC7-CANDLE-EXTINGUISH",[(i,) for i in range(1,6)],1,4,lambda k:(k if k<5 else 1,11,1,1))
    OFF={1:[(8,8,8)],2:[(6,7,8),(10,8,7)],3:[(8,5,10),(6,7,8),(9,8,7)],4:[(7,5,9),(10,7,9),(6,7,6),(9,8,6)],5:[(8,16,8)]}
    ofc=[(k,i+1) for k in OFF for i in range(len(OFF[k]))]
    run(g,'particle offsets (9.2, 9.3, pixels / 16): 1 candle (8, 8, 8); 2 (6, 7, 8), (10, 8, 7); 3 (8, 5, 10), (6, 7, 8), (9, 8, 7); 4 (7, 5, 9), (10, 7, 9), (6, 7, 6), (9, 8, 6); candle cake (8, 16, 8) (kind, index)',"GC7-CANDLE-OFFSET",ofc,2,3,lambda k,i:OFF[k][i-1])
    run(g,'explosion hit (9.1): an explosion that can trigger blocks extinguishes a lit candle (can trigger, lit)',"GC7-CANDLE-EXPLOSION",[(1,1),(1,0),(0,1),(0,0)],2,1,lambda c,l:int(c and l))
    run(g,'projectile hit (9.1): on the server a burning projectile lights a candle that can be lit (server, on fire, can be lit)',"GC7-CANDLE-PROJECTILE",[(1,1,1),(0,1,1),(1,0,1),(1,1,0)],3,1,lambda s,f,c:int(s and f and c))
    run(g,'updateShape (9.2): a waterlogged candle schedules a fluid tick, then the base update (waterlogged)',"GC7-CANDLE-ST",[(1,),(0,)],1,1,lambda w:w)
    def cc(f): return (int(f<0.3),int(f<0.17),1)
    run(g,'client animation (9.1): per offset one float f: below 0.3 a smoke particle, below 0.17 also candle_ambient; a small_flame particle always (nextFloat; smoke, ambient sound, flame)',"GC7-CANDLE-CLIENT",[(0.1,),(0.2,),(0.3,),(0.5,),(0.169,),(0.171,)],1,3,cc,infx=(1,))
    run(g,'support (9.2): placement needs canSupportCenter on the block below; updateShape has no survive test (trigger 1 placement 2 updateShape, support; allowed)',"GC7-CANDLE-SURVIVE",[(1,1),(1,0),(2,1),(2,0)],2,1,lambda t,s:s if t==1 else 1)
    def cu(it,hy,l):
        if it==1: return (3,0)
        if hy>0.5 and it==3 and l: return (1,1)
        return (2,0)
    cuc=[(1,0.9,1),(1,0.2,0),(3,0.9,1),(3,0.6,0),(3,0.5,1),(3,0.2,1),(2,0.9,1),(3,0.51,1)]
    run(g,'candle cake use with an item (9.3): flint and steel or a fire charge passes (the item lights it); clicking the candle part (hit y above 0.5) with an empty stack extinguishes a lit one; else the base (item 1 lighter 2 other 3 empty, hit y over the block, lit; result 1 success 2 base 3 pass, extinguish)',"GC7-CCAKE-USE",cuc,3,2,cu,infx=(2,))
    run(g,'candle cake use without an item (9.3): eat replaces the block by a cake with bites 1; when it consumes the action the candle item drops (can eat; result 1 success 0 pass, drop, bites)',"GC7-CCAKE-EAT",[(1,),(0,)],1,3,lambda e:(e,e,e))
    run(g,'cake shape (9.4, pixels x0 y0 z0 x1 y1 z1): box(1 + 2 x bites, 0, 1, 15, 8, 15), bites 0 to 6',"GC7-CAKE-SHAPE",[(b,) for b in range(0,7)],1,6,lambda b:(1+2*b,0,1,15,8,15))
    run(g,'candle cake shape (9.3): the candle column(2, 8, 14) united with the cake body column(14, 0, 8) (part, box)',"GC7-CCAKE-SHAPE",[(1,),(2,)],1,6,lambda p:(7,8,7,9,14,9) if p==1 else (1,0,1,15,8,15))
    run(g,'comparator (9.3, 9.4, worked example 11): a cake gives (7 - bites) x 2 = 14, 12, 10, 8, 6, 4, 2; a candle cake the full signal 14 (kind 1 cake 2 candle cake, bites)',"GC7-CAKE-SIGNAL",[(1,b) for b in range(7)]+[(2,0)],2,1,lambda k,b:(7-b)*2 if k==1 else 14)
    run(g,'support (9.3, 9.4): the block below must be solid; updateShape from below gives air when it cannot survive (below is solid, direction is down; survives, air)',"GC7-CAKE-SUPPORT",[(1,1),(0,1),(0,0),(1,0)],2,2,lambda s,d:(s,int(d and not s)))
    def ac(t,b,cb):
        if t and b==0 and cb: return (1,1,1,1,1,1)
        return (0,0,0,0,0,0)
    run(g,'a candle used on a cake (9.4, worked example 10): a candle item on an uneaten cake consumes one, plays cake_add_candle, writes the unlit candle cake, game event block_change, item_used (in tag candles, bites, candle block; consumed, sound, candle cake, game event, stat, result 1 success 0 try with empty hand)',"GC7-CAKE-ADD-CANDLE",[(1,0,1),(1,1,1),(0,0,1),(1,0,0)],3,6,ac)
    def ue(cl,ec,mh):
        if cl:
            if ec: return 1
            if mh: return 2
        return 1 if ec else 0
    run(g,'cake use without an item (9.4): the client returns success when eating works, else consume with an empty main hand, else falls through to the server path; the server returns the eat result (client, eat consumes, main hand empty; 1 success 2 consume 0 pass)',"GC7-CAKE-USE-EMPTY",[(1,1,1),(1,1,0),(1,0,1),(1,0,0),(0,1,1),(0,0,1)],3,1,ue)
    def ea(ce,b):
        if not ce: return (0,0,10,b,0,0)
        if b<6: return (1,2,10,b+1,0,0)
        return (1,2,10,b,1,1)
    run(g,'eat (9.4, worked example 11): a player who cannot eat gets pass; else 2 food points, saturation modifier 0.1 (x 100), bites + 1, and at bites 6 the block is removed with game event block_destroy: seven slices (can eat, bites; result, food, modifier, bites, removed, block_destroy event)',"GC7-CAKE-EAT",[(0,2)]+[(1,b) for b in range(7)],2,6,ea)
    W(g,9)
# ===== 10
if not ONLY or 10 in ONLY:
    g=GG(10,'Soul sand, magma block, lightning rod','T0663','the soul sand shapes, the magma block step and the lightning rod placement delta.')
    g.extra=DOC
    SV=[14,16,2,0,0]
    run(g,'soul sand (10.1): collision column(16, 0, 14), full outline, shade brightness 0.2 (x 10), no tick, no updateShape or bubble column hook',"GC7-SOUL-SAND",[(i,) for i in range(1,6)],1,1,lambda i:SV[i-1])
    run(g,'magma block stepOn (10.2): a living entity that is not stepping carefully is hurt by the hot_floor source for 1.0 (x 10) (careful, living)',"GC7-MAGMA-STEP",[(0,1),(1,1),(0,0),(1,0)],2,1,lambda c,l:10 if l and not c else 0)
    run(g,'lightning rod placement delta (10.3): facing is the clicked face, waterlogged from the fluid, a waterlogged state schedules a water fluid tick (fluid is water, clicked face; facing, waterlogged, fluid tick)',"GC7-ROD-DELTA",[(1,1),(0,2),(1,6),(0,5)],2,3,lambda w,f:(f,w,w))
    W(g,10)
