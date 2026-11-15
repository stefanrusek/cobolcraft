import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-8-%d'%n,'29b-8§%d'%n,subj,'Test of 29b part 8 section %d, %s (core/src/growth-29b-8*.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_growth_29b_8_%d.cob'%n)
def show(*v): return "/".join(str(x) for x in v)
def rnd(x): return int(math.floor(x+0.5))
DOC=" 01 WS-DOC                PIC X(64).\n"
def textcase(g,text,prog,inputs,exps):
    g.case(text,[(i,'CALL "%s" USING %s WS-DOC\nMOVE WS-DOC TO WS-T1\nMOVE SPACES TO WS-T2'%(prog,args),'TEXT') for i,args in inputs]," ".join(e+"|" for e in exps))
def O(n): return " ".join("WS-R(%d)"%i for i in range(1,n+1))
def run(g,text,prog,vecs,nin,nout,model,infx=()):
    args=" ".join(("WS-FX(%d)" if i in infx else "WS-I(%d)")%i for i in range(1,nin+1))
    g.run(text,[S(*v) for v in vecs],'CALL "%s" USING %s %s'%(prog,args,O(nout)),nout," ".join(show(*model(*v)) if isinstance(model(*v),tuple) else str(model(*v)) for v in vecs))
# ===== 1
if not ONLY or 1 in ONLY:
    g=GG(1,'Scope, and what other documents already hold','T0665','the owner table, the hand-off notes and the fire ambience.')
    g.extra=DOC
    OWN=["17 s3.3, s3.3a","24 p2 (rows 180, 181; s5.7)","30 p7 s8; 21 s8.3","29a (lava)","33 s4.4; 29b-3","16 s13; 33","29a; 44-1","41; 18 s2.5","42 p6 (FIRE_AMBIENT); 12","31 p4 s5","24 p7 s11.3"]
    NM=["odds table and fire tick","fire registry rows","TntBlock","lava","lightning","game rules","inside-block effects","entity fire ticks","client ambience","campfire block entity","campfire registry"]
    textcase(g,'owner table (1): '+", ".join(NM[:6]),'GC8-OWNER',[(str(i+1),'WS-I(1)') for i in range(6)],OWN[:6])
    textcase(g,'owner table (1): '+", ".join(NM[6:])+", a row outside the table",'GC8-OWNER',[(str(i+1),'WS-I(1)') for i in range(6,11)]+[("12",'WS-I(1)')],OWN[6:]+[""])
    HO=["17 s3.3a step 7: attribute at the fire position (biome data)","30 p7 s8.1, s8.3: table is 17 s3.3a, burn-out step is 2.7"]
    textcase(g,'hand-off to the owners of neighbour documents (1): 17 section 3.3a step 7 and 30 part 7 section 8','GC8-HANDOFF',[("1",'WS-I(1)'),("2",'WS-I(1)'),("3",'WS-I(1)')],HO+[""])
    def am(d,f1,f2):
        if d!=0: return (0,0,0)
        return (1,rnd((1+f1)*1e6),rnd((0.3+f2*0.7)*1e6))
    amc=[(0,0.0,0.0),(0,0.5,0.5),(0,0.25,1.0),(1,0.5,0.5),(23,0.1,0.1)]
    g.run('fire ambience (1, client): nextInt(24) = 0 plays fire.ambient at the block centre, volume 1 + nextFloat, pitch 0.3 + nextFloat x 0.7 (x 1e6) (draw, first float, second float; sound, volume, pitch)',[S(*c) for c in amc],'CALL "GC8-FIRE-AMBIENT" USING WS-I(1) WS-FX(2) WS-FX(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*am(*c)) for c in amc))
    W(g,1)
# ===== 2
if not ONLY or 2 in ONLY:
    g=GG(2,'Fire','T0667','the facts, placement state, survival, shape update, onPlace, the tick with its draws, burn-out, spread, environment inputs, soul fire, entity contact and breaking.')
    g.extra=DOC
    FA=[15,10,20,1,512,1,0,0,53,30,10,5,3]
    run(g,'facts (2.1, 2.5, 2.6): MAX_AGE 15, fire damage 1.0 and soul fire 2.0 (x 10), floor sheet 1 pixel, 512 fire states and 1 soul fire state, no random ticks, 53 spread cells, tick delay 30 + nextInt(10), 5 side flags, 3 inside effects',"GC8-FIRE-FACTS",[(i,) for i in range(1,14)],1,1,lambda i:FA[i-1])
    run(g,'odds of a state (2.1): 0 when waterlogged, else the registered pair (registered, waterlogged)',"GC8-FIRE-ODDS",[(60,0),(60,1),(0,0),(5,1)],2,1,lambda r,w:0 if w else r)
    run(g,'canBurn (2.1): fire needs odds above 0 and not waterlogged; soul fire always true (kind 1 fire 2 soul fire, registered odds, waterlogged)',"GC8-FIRE-CANBURN",[(1,60,0),(1,60,1),(1,0,0),(2,0,1),(2,60,0)],3,1,lambda k,o,w:1 if k==2 else int(o>0 and not w))
    def pl(sb,cb,st,n,e,s,w,u):
        if sb: return (2,0,0,0,0,0)
        if cb or st: return (1,0,0,0,0,0)
        return (1,n,e,s,w,u)
    plc=[(1,0,0,1,1,1,1,1),(0,1,0,1,1,1,1,1),(0,0,1,1,1,1,1,1),(0,0,0,0,0,0,0,0),(0,0,0,1,0,0,0,0),(0,0,0,0,1,0,0,0),(0,0,0,0,0,1,0,0),(0,0,0,0,0,0,1,0),(0,0,0,0,0,0,0,1),(0,0,0,1,0,1,0,1)]
    run(g,'placement state (2.2): soul fire above soul_fire_base_blocks; fire when the block below burns or has a sturdy top; else the side flags from the neighbours that can burn, with no down flag (soul base below, below can burn, below sturdy, north, east, south, west, up can burn; kind, north, east, south, west, up)',"GC8-FIRE-PLACEMENT",plc,8,6,pl)
    run(g,'getStateWithAge (2.2 step 3): a fire result takes the age, a soul fire result is returned unchanged (kind, age; kind, age)',"GC8-FIRE-AGE",[(1,0),(1,7),(2,7),(1,15)],2,2,lambda k,a:(1,a) if k==1 else (2,0))
    def sv(k,st,vl,sb): return int(sb) if k==2 else int(st or vl)
    svc=[(1,1,0,0),(1,0,1,0),(1,0,0,0),(1,1,1,0),(2,0,0,1),(2,1,1,0)]
    run(g,'survival (2.3): fire needs a sturdy top below or a valid fire location; soul fire a soul_fire_base_blocks block below (kind, sturdy below, valid location, soul base below)',"GC8-FIRE-SURVIVE",svc,4,1,sv)
    def up(k,s,sb):
        if not s: return 0
        if k==2: return 2
        return 2 if sb else 1
    upc=[(1,1,0),(1,1,1),(1,0,0),(1,0,1),(2,1,1),(2,0,0)]
    run(g,'shape update (2.3): fire recomputes its flags when it survives and becomes soul fire above soul sand or soil, else air; soul fire is its default state or air (kind, survives, soul base below; 0 air 1 fire 2 soul fire)',"GC8-FIRE-UPDATE",upc,3,1,up)
    def op(old,pd,sf,cs,k):
        por=int((not old) and pd and sf)
        rem=int((not old) and (not por) and (not cs))
        sch=int(k==1)
        return (por,rem,sch,sch)
    opc=[(1,1,1,0,1),(0,1,1,0,1),(0,1,0,0,1),(0,1,0,1,1),(0,0,0,0,1),(0,0,0,1,1),(0,0,0,0,2),(1,0,0,0,1)]
    run(g,'onPlace (2.4): the same block does nothing; in the Overworld or Nether a found empty portal shape creates the portal and ends; else a fire that cannot survive is removed; FireBlock then always schedules one tick (one draw), soul fire never (old state is the same block, portal dimension, portal shape found, canSurvive, kind; portal created, removed, scheduled, draws)',"GC8-FIRE-ONPLACE",opc,5,4,op)
    run(g,'fire tick delay (2.4, 2.5 step 1, validation 2): 30 + nextInt(10), 30 to 39',"GC8-FIRE-DELAY",[(0,),(9,),(5,)],1,1,lambda d:30+d)
    def nr(a,w,e,n,s):
        for i,x in enumerate((a,w,e,n,s),1):
            if x: return (1,i)
        return (0,5)
    nrc=[(1,0,0,0,0),(0,1,0,0,0),(0,0,1,0,0),(0,0,0,1,0),(0,0,0,0,1),(0,0,0,0,0),(1,1,1,1,1)]
    run(g,'isNearRain (2.5 step 5): rain at the position or the west, east, north, south neighbours, short circuit (at, west, east, north, south; near, tests made)',"GC8-FIRE-NEAR-RAIN",nrc,5,2,nr)
    def tk(age,spread,surv,inf,rain,near,rd,ad,valid,sturdy,d4,cbb):
        draws=1
        if not spread: return (2,0,0,age,1,0,0)
        removed=int(not surv); extra=0
        if (not inf) and rain and near:
            draws+=1
            if rd<0.2+0.03*age: return (5,1,0,age,draws,0,0)
        draws+=1
        na=min(15,age+ad//2); wrote=int(na!=age)
        if removed and wrote: extra=1; draws+=1
        if not inf:
            if not valid:
                if (not sturdy) or age>3: removed=1
                return (7,removed,wrote,na,draws,extra,0)
            if age==15:
                draws+=1
                if d4==0 and not cbb: return (7,1,wrote,na,draws,extra,0)
        return (0,removed,wrote,na,draws,extra,1)
    # age spread surv inf rain near rd ad valid sturdy d4 cbb
    tkc=[(3,0,1,0,0,0,0.5,0,1,1,1,0),
         (3,1,1,0,0,0,0.5,0,1,1,1,0),
         (3,1,1,0,0,0,0.5,2,1,1,1,0),
         (3,1,1,0,0,0,0.5,1,1,1,1,0),
         (14,1,1,0,0,0,0.5,2,1,1,1,0),
         (15,1,1,0,0,0,0.5,2,1,1,1,0),
         (3,1,1,0,1,1,0.28,0,1,1,1,0),
         (3,1,1,0,1,1,0.30,2,1,1,1,0),
         (15,1,1,0,1,1,0.64,0,1,1,1,0),
         (15,1,1,0,1,1,0.66,0,1,1,1,0),
         (3,1,1,0,1,0,0.01,0,1,1,1,0),
         (3,1,1,0,0,1,0.01,0,1,1,1,0),
         (3,1,1,1,1,1,0.01,0,1,1,1,0),
         (3,1,1,0,0,0,0.5,0,0,1,1,0),
         (4,1,1,0,0,0,0.5,0,0,1,1,0),
         (3,1,1,0,0,0,0.5,0,0,0,1,0),
         (5,1,1,0,0,0,0.5,0,1,1,0,0),
         (15,1,1,0,0,0,0.5,0,1,1,0,0),
         (15,1,1,0,0,0,0.5,0,1,1,0,1),
         (15,1,1,0,0,0,0.5,0,1,1,2,0),
         (14,1,1,0,0,0,0.5,0,1,1,0,0),
         (4,1,0,0,0,0,0.5,2,0,0,1,0),
         (4,1,0,0,0,0,0.5,0,1,1,1,0),
         (3,1,0,0,0,0,0.5,2,0,1,1,0),
         (15,1,1,1,0,0,0.5,2,0,0,1,0),
         (14,1,1,1,0,0,0.5,2,1,1,0,0)]
    run(g,'the fire tick (2.5): one reschedule draw first; no player near ends it; a failed canSurvive removes the fire but the tick goes on; rain (not infiniburn, raining, near rain) draws a float and removes below 0.2 + 0.03 x age; the age draw nextInt(3) / 2 always; 7a removes on no sturdy floor or age above 3 and ends; 7b at age 15 draws nextInt(4); quirk A: a write-back after a removal costs one more draw (age, spread allowed, survives, infiniburn, raining, near rain, rain float, age draw, valid location, sturdy below, nextInt(4), below can burn; end step 2 5 7 or 0, removed, age written, age, draws, extra draw, goes on)',"GC8-FIRE-TICK",tkc[:13],12,7,tk,infx=(7,))
    run(g,'the fire tick continued (2.5, quirks A and C, worked examples 4 to 6): isolated fires, age 15 and infiniburn floors',"GC8-FIRE-TICK",tkc[13:],12,7,tk,infx=(7,))
    run(g,'burn-out base (2.5 step 8): -50 when increased_fire_burnout is true, else 0',"GC8-FIRE-BURNOUT",[(0,),(1,)],1,1,lambda a:-50 if a else 0)
    BC=[300,300,250,250,300,300]
    run(g,'checkBurnOut chances (2.5 step 9, worked example 3): east, west, below, above, north, south at 300, 300, 250, 250, 300, 300 plus the burnout (burnout, neighbour)',"GC8-FIRE-BURN-CHANCE",[(b,i) for b in (0,-50) for i in range(1,7)],2,1,lambda b,i:BC[i-1]+b)
    def cell(i):
        r=i-1 if i<26 else i
        dx=r//18-1; rem=r%18; dz=rem//6-1; dy=rem%6-1
        return (dx,dy,dz,100 if dy<=1 else 100+(dy-1)*100)
    # independent enumeration
    cells=[]
    for dx in (-1,0,1):
        for dz in (-1,0,1):
            for dy in range(-1,5):
                if (dx,dy,dz)==(0,0,0): continue
                cells.append((dx,dy,dz,100 if dy<=1 else 100+(dy-1)*100))
    assert len(cells)==53
    ids=[1,2,6,7,8,24,25,26,27,28,52,53]
    g.run('spread loop order (2.6, validation 4): dx -1 to 1, then dz -1 to 1, then dy -1 to 4, the cell (0, 0, 0) skipped so 53 cells; bound 100 up to dy 1, then 200, 300, 400 (cell number; dx, dy, dz, bound)',[str(i) for i in ids],'CALL "GC8-FIRE-CELL" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*cells[i-1]) for i in ids))
    run(g,'ignite odds of a cell (2.6 step 2): 0 unless the cell is air, else the maximum over its neighbours (cell is air, the maximum neighbour odds)',"GC8-FIRE-CELL-ODDS",[(1,30),(1,0),(0,60),(1,5)],2,1,lambda a,o:o if a else 0)
    def ch(o,d,age,a):
        c=(o+40+7*d)//(age+30)
        return c//2 if a else c
    chc=[(5,2,0,0),(15,2,0,0),(30,0,0,0),(30,2,0,0),(30,3,0,0),(60,2,0,0),(60,3,0,0),(5,2,15,0),(15,2,15,0),(30,0,15,0),(30,2,15,0),(30,3,15,0),(60,2,15,0),(60,3,15,0),(30,2,0,1),(15,0,0,0)]
    run(g,'spread chance (2.6 step 3, table, worked example 1): (o + 40 + 7 x difficulty id) / (age + 30) in integer division, halved when increased_fire_burnout (o, difficulty, age, burnout attribute)',"GC8-FIRE-CHANCE",chc,4,1,ch)
    run(g,'catch probability (2.6 table): chance + 1 outcomes of the bound, x 10000: 2% for chance 1 and bound 100, 3% for 2, 1.5% for 2 and bound 200, 4% for 3, 5% for 4, 2.5% for 4 and bound 200',"GC8-FIRE-PROB",[(1,100),(2,100),(2,200),(3,100),(2,100),(4,100),(4,200),(0,100)],2,1,lambda c,b:(c+1)*10000//b)
    def sc(ch_,d1,rn,d2,age):
        if ch_<=0: return (0,0,0,0,age)
        if not d1<=ch_: return (1,0,0,0,age)
        if rn: return (1,1,0,0,age)
        return (1,1,1,1,min(15,age+d2//4))
    scc=[(0,5,0,0,3),(2,5,0,0,3),(2,2,0,4,3),(2,1,1,4,3),(2,0,0,3,3),(2,0,0,4,3),(2,0,0,4,15),(1,2,0,0,0)]
    run(g,'spread cell (2.6 steps 4 to 7): no draw when the chance is 0 or less; the draw nextInt(bound) catches when at most the chance; rain near the cell skips after that draw; else nextInt(5) / 4 adds 1 to the age and the cell is written (chance, first draw, raining near the cell, second draw, age; first draw made, caught, second draw made, placed, new age)',"GC8-FIRE-SPREAD-CELL",scc,5,5,sc)
    def bo(burn,chance,d1,age,d2,rain,d3,tnt):
        if not d1<burn: return (0,0,0,age,0)
        if d2<5 and not rain: return (1,1,1,min(15,age+d3//4),int(tnt))
        return (2,1,0,age,int(tnt))
    boc=[(20,300,10,0,3,0,0,0),(20,300,25,0,3,0,0,0),(20,300,19,0,7,0,0,0),(20,300,19,0,3,1,0,0),(20,250,19,5,9,0,4,0),(20,250,19,5,10,0,4,0),(100,300,50,0,2,0,0,1),(100,300,50,0,8,0,0,1),(100,300,150,0,2,0,0,1),(60,300,10,0,1,0,2,0)]
    run(g,'checkBurnOut (2.7, worked examples 2, 3 and 8): nextInt(chance) below burnOdds passes; then nextInt(age + 10) below 5 without rain turns it into fire (age + nextInt(5) / 4), else it is removed; a burnt TNT is primed in both outcomes (burn odds, chance, first draw, age, second draw, raining at it, third draw, was TNT; outcome 0 none 1 fire 2 removed, second draw made, third draw made, age, prime)',"GC8-FIRE-BURN-CHECK",boc,8,5,bo)
    def inf(d,b):
        if d in(1,2,3): return int(b in(1,2))
        return int(b in(1,2,3))
    infc=[(d,b) for d in (1,2,3,4) for b in (1,2,3,4)]
    run(g,'infiniburn (2.8, worked example 6): the overworld, overworld_caves and nether dimension types name netherrack and magma_block; the end also bedrock (dimension 1 overworld 2 overworld_caves 3 the_nether 4 the_end, block 1 netherrack 2 magma_block 3 bedrock 4 other)',"GC8-FIRE-INFINIBURN",infc,2,1,inf)
    run(g,'canSpreadFireAround (2.8): true when fire_spread_radius_around_player is -1, else when a player is close enough (rule, a player is close)',"GC8-FIRE-CAN-SPREAD",[(-1,0),(-1,1),(128,1),(128,0),(0,0)],2,1,lambda r,p:1 if r==-1 else p)
    BI=["bamboo_jungle","frozen_peaks","jagged_peaks","jungle","mangrove_swamp","mushroom_fields","snowy_slopes","swamp","plains"]
    textcase(g,'increased_fire_burnout (2.8, validation 9): true in exactly 8 biomes, default false: '+", ".join(BI),'GC8-BIOME-BURNOUT',[(str(i+1),'WS-I(1)') for i in range(9)],["true"]*8+["false"])
    def ig(im,t,pl,d):
        if im: return (t,0,0)
        dr=0
        if t<0: t+=1
        elif pl: dr=1; t+=1+d
        return (t,8 if t>=0 else 0,dr)
    igc=[(1,-5,0,0),(0,-5,0,0),(0,-1,0,0),(0,-1,1,1),(0,0,0,0),(0,0,1,0),(0,0,1,1),(0,40,0,0),(0,40,1,1),(0,-2,1,1)]
    run(g,'standing in fire (2.10): fire immune does nothing; a negative timer counts up by 1; a server player adds nextInt(1, 3), 1 or 2; when the timer is then 0 or more the entity burns for 8 seconds (immune, remaining fire ticks, server player, draw 0 or 1; ticks, ignite seconds, draw made)',"GC8-FIRE-IGNITE",igc,4,3,ig)
    run(g,'breaking fire (2.11): a player hitting fire on the server sends level event 1009 with data 0 (server; event, data)',"GC8-FIRE-BREAK",[(1,),(0,)],1,2,lambda s:(1009,0) if s else (0,0))
    PR=["17 s3.3; 30 p4 s4.10","29a; 33; 29b-3","2.6, 2.7","21","2.4 step 2 (Open question 3)"]
    textcase(g,'who places fire (2.12): flint and steel, fire charge, dispenser; lava and lightning; spread and burn-out; end crystal; portal creation','GC8-FIRE-PRODUCER',[(str(i+1),'WS-I(1)') for i in range(5)]+[("6",'WS-I(1)')],PR+[""])
    W(g,2)
# ===== 3
if not ONLY or 3 in ONLY:
    g=GG(3,'Campfire: the delta over 24 part 7 section 11.3 and 31 part 4','T0669','the constructor arguments, updateShape, canLight, contact, the missing ticks and isSmokeyPos.')
    g.extra=DOC
    run(g,'constructor arguments (3): campfire spawns particles with fire damage 1, soul campfire none with 2 (kind; spawnParticles, fireDamage)',"GC8-CAMP-CONST",[(1,),(2,)],1,2,lambda k:(1,1) if k==1 else (0,2))
    def cu(w,d,h):
        if d: return (w,1,h,0)
        return (w,0,0,1)
    run(g,'updateShape (3): a waterlogged block schedules a water tick; the DOWN direction sets signal_fire to whether the block below is hay_block and nothing else; every other direction calls the base method (waterlogged, direction is down, hay below; water tick, signal set, signal, base called)',"GC8-CAMP-UPDATE",[(1,1,1),(0,1,0),(1,0,0),(0,0,1)],3,4,cu)
    run(g,'canLight (3): in block tag campfires, not waterlogged and not lit (in tag, waterlogged, lit)',"GC8-CAMP-CANLIGHT",[(1,0,0),(1,1,0),(1,0,1),(0,0,0)],3,1,lambda t,w,l:int(t and not w and not l))
    run(g,'contact (3): a lit campfire hurts a living entity (the fire damage) and never sets it alight (lit, living; hurt, ignites)',"GC8-CAMP-CONTACT",[(1,1),(0,1),(1,0),(0,0)],2,2,lambda l,v:(int(l and v),0))
    run(g,'block tick (3): none: no scheduled tick, no random tick, no neighbour hook, no fire spread (hook 1 scheduled tick 2 random tick 3 neighbour hook 4 spreads fire)',"GC8-CAMP-HOOKS",[(i,) for i in range(1,5)],1,1,lambda i:0)
    def sm(c):
        for i in range(1,6):
            if c[i-1]==1: return (1,i)
            if c[i-1]==2: return (int(c[i]==1),i)
        return (0,5)
    smc=[[1,0,0,0,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1],[2,1,0,0,0,0],[0,0,2,0,0,0],[0,0,2,1,0,0],[0,0,0,0,2,1],[0,0,0,0,0,0],[2,2,1,0,0,0],[0,2,2,1,0,0]]
    g.run('isSmokeyPos (3, worked example 9): scan 1 to 5 cells below; a lit campfire is true; a blocking cell stops the scan but still counts a lit campfire directly under it, so one up to 6 below counts (cells 1 to 6: 0 passes 1 lit campfire 2 blocks; smoky, cells scanned)',[S(*c) for c in smc],'CALL "GC8-CAMP-SMOKEY" USING WS-ISG WS-R(1) WS-R(2)',2," ".join(show(*sm(c)) for c in smc))
    W(g,3)
# ===== 4
if not ONLY or 4 in ONLY:
    g=GG(4,'The other blocks named in the round scope','T0671','the owner and hook table of TntBlock, SpawnerBlock, TrialSpawnerBlock, VaultBlock, ConduitBlock, TargetBlock, NoteBlock, JukeboxBlock, LecternBlock, BellBlock and DaylightDetectorBlock.')
    g.extra=DOC
    NM=["TntBlock","SpawnerBlock","TrialSpawnerBlock","VaultBlock","ConduitBlock","TargetBlock","NoteBlock","JukeboxBlock","LecternBlock","BellBlock","DaylightDetectorBlock"]
    OW=["30 p7 s8","31 p7","31 p7","31 p7","24 p8 (row 626); 31-8","30 p5 s6","30 p5 s8","31 p4 s2; 30 p5 s9","31 p4 s3.7","31 p4 s4.5; 30 p8","30 p5 s5"]
    textcase(g,'owners (4): '+", ".join(NM[:6]),'GC8-OTHER-OWNER',[(str(i+1),'WS-I(1)') for i in range(6)],OW[:6])
    textcase(g,'owners (4): '+", ".join(NM[6:])+", a row outside the table",'GC8-OTHER-OWNER',[(str(i+1),'WS-I(1)') for i in range(6,11)]+[("12",'WS-I(1)')],OW[6:]+[""])
    HK=[1,0,0,0,0,1,1,0,1,1,0]
    run(g,'hooks of the sweep (4, 6): the classes that declare tick, randomTick or neighborChanged: TntBlock, TargetBlock, NoteBlock, LecternBlock and BellBlock; the other six declare none (class row)',"GC8-OTHER-HOOKS",[(i,) for i in range(1,12)],1,1,lambda i:HK[i-1])
    run(g,'target block tick (4): resets power to 0 when it is not 0 (power; new power, changed)',"GC8-TARGET-TICK",[(0,),(7,),(15,)],1,2,lambda p:(0,int(p!=0)))
    run(g,'lectern tick (4): clears powered (powered; new powered, changed)',"GC8-LECTERN-TICK",[(1,),(0,)],1,2,lambda p:(0,p))
    run(g,'conduit updateShape (4): a waterlogged conduit schedules a water tick, then the base method (waterlogged; tick)',"GC8-CONDUIT-ST",[(1,),(0,)],1,1,lambda w:w)
    W(g,4)
# ===== 5
if not ONLY or 5 in ONLY:
    g=GG(5,'Budding amethyst','T0673','the constants, the owner pointer and agreement with 29b part 6 section 3.3.')
    g.extra=DOC
    run(g,'constants (5): GROWTH_CHANCE 5, the face draw bound 6, so one face grows with probability 1/30 per random tick, the four stages',"GC8-BUDDING-CONST",[(i,) for i in range(1,5)],1,1,lambda i:[5,6,30,4][i-1])
    textcase(g,'owner (5): owned by 29b-6 section 3.3, one owner so the two cannot drift','GC8-BUDDING-OWNER',[("0",'WS-I(1)')],["29b-6 s3.3"])
    def bud(a,b,k,fw):
        if a!=0: return (1,0,0,0)
        N={1:1,2:1,3:2,4:3,5:4}.get(k,0)
        wl=int(fw) if N else 0
        return (2,b+1,N,wl)
    bc=[(0,5,3,0),(0,5,1,0),(0,5,4,0),(0,5,5,0),(0,1,6,0),(0,2,0,0),(3,5,3,0),(0,0,2,1)]
    g.run('worked example 10 (5): nextInt(5) = 0 and the face draw EAST (index 5) turn a small bud facing east into a medium bud; another face with a neighbour that is neither air nor a bud does nothing; any other first draw stops (the 29b-6 program is asserted here; draws, direction 1-6, new block 0 none 1 small 2 medium 3 large 4 cluster, waterlogged)',[S(*c) for c in bc],'CALL "GC6-BUD-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(show(*bud(*c)) for c in bc))
    g.run('rate (5): one face advances with 1/30 per random tick (x 1e6) and GROWTH_CHANCE 5 (the 29b-6 program is asserted here)',["0"],'CALL "GC6-BUD-RATE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"33333/120/163840/5")
    W(g,5)
# ===== 6
if not ONLY or 6 in ONLY:
    g=GG(6,'Method of the residual sweep','T0675','the sweep counts, the hook names and the status names.')
    g.extra=DOC
    SW=[330,410,80,105,3]
    run(g,'sweep numbers (6, validation 11): 330 top-level classes in 410 class files of which 80 are inner classes, 105 classes declare a hook, 3 hook names are matched',"GC8-SWEEP-NUM",[(i,) for i in range(1,6)],1,1,lambda i:SW[i-1])
    run(g,'the counts agree: top-level classes + inner classes = class files (330 + 80 = 410)',"GC8-SWEEP-NUM",[(1,),(3,)],1,1,lambda i:[330,80][[1,3].index(i)])
    textcase(g,'hook names (6 step 1): tick, randomTick, neighborChanged','GC8-HOOK-NAME',[(str(i),'WS-I(1)') for i in (1,2,3,4)],["tick","randomTick","neighborChanged",""])
    textcase(g,'status names (6 step 3): Covered, Partial, Unclaimed, and a Covered or Partial row','GC8-STATUS-NAME',[(str(i),'WS-I(1)') for i in (1,2,3,4,5)],["Covered","Partial","Unclaimed","Covered / Partial",""])
    W(g,6)
# ===== 7
if not ONLY or 7 in ONLY:
    g=GG(7,'Coverage matrix','T0677','the matrix rows with their status and document, and the FlowerPotBlock residual random tick.')
    g.extra=DOC
    ROWS=[("17 s3.3a; 29b-8 s2",1),("29b-1 s3",1),("29b-1 s3.7, s3.5; 31-4",1),("29b-1 s7",1),("29b-1 s6; 29b-2",1),("29b-3",1),("29b-5",1),("30 p5 s7; 29b-3",1),("29b-7 s2 to s9; 24 p6, p8",1),("29a; 29b-4 s3",4),("30 p1, p7",1),("30 p2",1),("30 p3",1),("30 p4",1),("30 p5",1),("30 p6; 29",1),("30 p7",1),("30 p8; 31 p8; 31-4",1),("31 p8",1),("31 p1",1),("31 p6",1),("31 p3; 30 p1",1),("31 p4",1),("24 p3, p6, p7, p2",1),("29b-6 s3.3",1),("29b-4 s10.3",1),("29b-8 s7.1",2),("29b-4 s7",1),("29b-4 s6",1),("29b-4 s3",1),("29b-4 s12, s13.3",1),("29b-6 s4 to s9; 29b-7 s8.6",1),("24 p6",1),("29b-1",1)]
    NMS=["Fire","FallingBlock","Scaffolding, Brushable","Sapling","Crop family","SpreadingSnowy family","Mushroom, weathering copper","LightningRod","Coral, eggs, cauldron, honey","Liquid, bubble column, growing plant head","Redstone wire family","Diode family","Piston family","Dispenser, hopper, crafter","Button, plate, target, note, daylight, lever","Rails","Door, trapdoor, gate, lamp, TNT","TripWire, sculk sensor, bell","SculkCatalyst","Barrel, chest","CommandBlock family","AbstractSkull, shelf","Lectern","Cactus, cane, chorus, composter, portal","BuddingAmethyst","Eyeblossom","FlowerPot","Vine","Bamboo","GrowingPlant","BigDripleaf, hanging moss","Speleothem","DriedGhast","DragonEgg, concrete powder"]
    assert len(ROWS)==34==len(NMS)
    for a in range(0,34,6):
        idx=range(a,min(a+6,34))
        g.case('matrix rows (7): '+", ".join(NMS[i] for i in idx),[(str(i+1),'CALL "GC8-MATRIX-STATUS" USING WS-I(1) WS-R(1)',1) for i in idx]+[],"x")
    # rebuild with interleaved status/doc calls
    g.out=[]
    for a in range(0,34,6):
        idx=list(range(a,min(a+6,34)))
        calls=[]
        for i in idx:
            calls.append((str(i+1),'CALL "GC8-MATRIX-STATUS" USING WS-I(1) WS-R(1)',1))
            calls.append((str(i+1),'CALL "GC8-MATRIX" USING WS-I(1) WS-DOC\nMOVE WS-DOC TO WS-T1\nMOVE SPACES TO WS-T2','TEXT'))
        g.case('matrix rows 1 Covered 2 Partial 4 Covered or Partial (7): '+", ".join(NMS[i] for i in idx),calls," ".join("%d %s|"%(ROWS[i][1],ROWS[i][0]) for i in idx))
    textcase(g,'a row outside the matrix is blank (7)','GC8-MATRIX',[("35",'WS-I(1)')],[""])
    run(g,'no row of the matrix is Unclaimed (7, remaining work list): the status of a row outside the table is 0',"GC8-MATRIX-STATUS",[(35,)],1,1,lambda r:0)
    def pot(k,w):
        if k not in(1,2): return (0,0,k,0,0,0)
        op=int(k==1)
        wo=int(w==1) if w!=0 else op
        if wo==op: return (1,0,k,0,0,1)
        nk=2 if op else 1
        return (1,1,nk,nk,1,1)
    potc=[(0,0),(0,1),(1,1),(1,2),(1,0),(2,2),(2,1),(2,0)]
    run(g,'FlowerPotBlock random tick (7.1): only potted_open_eyeblossom and potted_closed_eyeblossom tick; the wanted state from gameplay/eyeblossom_open (unset keeps the current); the same does nothing; a different one swaps to the other pot (setBlockAndUpdate), spawns the transform particle and plays the switch sound of the new type; the inherited tick runs in every case (pot 0 other 1 open 2 closed, wanted 0 unset 1 open 2 closed; ticks, changed, new pot, sound type, particle, inherited)',"GC8-POT-TICK",potc,2,6,pot)
    W(g,7)
