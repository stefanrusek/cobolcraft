import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(a for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def m(x,n=1000): return int(math.floor(x*n+0.5))
def G3(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-3-%d'%n,'29b-3§%d'%n,subj,'Test of 29b part 3 section %d, %s (core/src/growth-29b-3c.cob; %s): %s'%(n,subj,tasks,desc),'')
def G4(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-4-%d'%n,'29b-4§%d'%n,subj,'Test of 29b part 4 section %d, %s (core/src/growth-29b-4.cob; %s): %s'%(n,subj,tasks,desc),'')
def W3(g,n):
    if not ONLY or ('3_%d'%n) in ONLY: g.write(OUT+'/test_growth_29b_3_%d.cob'%n)
def W4(g,n):
    if not ONLY or ('4_%d'%n) in ONLY: g.write(OUT+'/test_growth_29b_4_%d.cob'%n)
def call(name,nin,nout,fl=()):
    # CALL "name" USING WS-I(1..nin) [floats as WS-FX(i) for i in fl] WS-R(1..nout)
    a=" ".join(("WS-FX(%d)"%i if i in fl else "WS-I(%d)"%i) for i in range(1,nin+1))
    b=" ".join("WS-R(%d)"%i for i in range(1,nout+1))
    return 'CALL "%s" USING %s %s'%(name,a,b)
def rows(g,text,name,nin,nout,cases,model,fl=()):
    g.run(text,[S(*c) or "0" for c in cases],call(name,nin,nout,fl),nout," ".join("/".join(str(v) for v in model(*c)) for c in cases))
# ===== part 3 section 10
g=G3(10,'Sponge, wet sponge, magma','T0579','sponge absorption (10.1), wet sponge (10.2), magma block (10.3) and the worked cases 8 and 9 of section 11.')
g.extra=" 01 WS-NBG.\n    05 WS-NB BINARY-LONG OCCURS 384 TIMES.\n 01 WS-VDG.\n    05 WS-VD BINARY-LONG OCCURS 64 TIMES.\n 01 WS-ORG.\n    05 WS-OR BINARY-LONG OCCURS 64 TIMES.\n"
g.run('sponge constants (10.1): MAX_DEPTH 6, MAX_COUNT 64 and maxCount 65 for the traversal (the start counts as the first accepted node)',["0"],'CALL "GC3-SPONGE-CONST" USING WS-R(1) WS-R(2) WS-R(3)',3,"6/64/65")
tc=[(1,0),(1,1),(2,0),(2,1)]
rows(g,'sponge triggers (10.1): PL does nothing when the old state is already a sponge, else tryAbsorbWater; NU always runs it (absorb)','GC3-SPONGE-TRIGGER',2,1,tc,lambda t,o:(0 if (t==1 and o==1) else 1,))
rows(g,'tryAbsorbWater (10.1): more than one accepted position (a position besides the sponge) makes a wet sponge with flags 2 and the sponge_absorb sound; else nothing (wet, flags, sound)','GC3-SPONGE-RESULT',1,3,[(1,),(2,),(3,),(65,)],lambda n:(1,2,1) if n>1 else (0,0,0))
nc=[(1,0,0,0,0),(0,0,1,1,1),(0,0,1,0,0),(0,1,1,0,0),(0,1,0,1,0),(0,1,0,0,1),(0,1,0,0,0),(0,1,1,1,1)]
def nm(p,w,pk,lq,pl):
    if p: return 1,0
    if not w: return 2,0
    if pk: return 1,1
    if lq: return 1,2
    if pl: return 1,3
    return 2,0
rows(g,'sponge node function (10.1): the sponge itself is accepted; a fluid outside tag water is skipped; a successful bucket pickup (source or waterlogged) is accepted (action 1); flowing water is set to air and accepted (2); kelp, kelp_plant, seagrass and tall_seagrass drop and are set to air and accepted (3); anything else is skipped (verdict, action)','GC3-SPONGE-NODE',5,2,nc,nm)
rows(g,'layers of a water body around the sponge (example 8): 1, 6, 18, 38 positions at traversal distance 0 to 3, cumulative 63','GC3-SPONGE-LAYER',1,1,[(0,),(1,),(2,),(3,),(4,)],lambda d:(1 if d==0 else 4*d*d+2,))
rows(g,'absorbed positions (10.1, example 8): accepted = reachable up to 65, removed = accepted - 1, wet when something was removed; a sponge with no water within 6 steps stays (accepted, removed, wet)','GC3-SPONGE-ABSORB',1,3,[(1,),(2,),(63,),(65,),(66,),(400,)],lambda r:(min(r,65),min(r,65)-1,int(min(r,65)>1)))
def bcall(md,mc,start,n,adj,vd):
    s='INITIALIZE WS-NBG WS-VDG WS-ORG\n'
    for k,l in adj.items():
        for j,x in enumerate(l): s+='MOVE %d TO WS-NB(%d)\n'%(x,(k-1)*6+j+1)
    for k in range(1,n+1): s+='MOVE %d TO WS-VD(%d)\n'%(vd.get(k,1),k)
    s+='MOVE %d TO WS-I(10)\nMOVE %d TO WS-I(11)\nMOVE %d TO WS-I(12)\n'%(md,mc,start)
    s+='CALL "GC3-BFS" USING WS-I(10) WS-I(11) WS-I(12) WS-NBG WS-VDG WS-R(1) WS-R(2) WS-ORG'
    return s
def bfs(md,mc,start,adj,vd):
    q=[(start,0)]; vis=set(); cnt=0; qi=0; taken=0
    while qi<len(q):
        k,d=q[qi]; qi+=1
        if k in vis: continue
        vis.add(k); taken+=1
        if vd.get(k,1)==2: continue
        cnt+=1
        if cnt>=mc: return cnt,taken
        if d>=md: continue
        for x in adj.get(k,[]): q.append((x,d+1))
    return cnt,taken
pond={1:[2],2:[1]}
line={k:([k-1] if k>1 else [])+([k+1] if k<9 else []) for k in range(1,10)}
cases=[(6,65,1,2,pond,{}),(6,65,1,9,line,{}),(6,65,1,9,line,{3:2}),(6,3,1,9,line,{})]
g.case('sponge traversal (10.1, 2.4): a 1x1 pond accepts the sponge and the source (count 2); a straight run of water is cut at depth 6 (7 accepted: the sponge and six more); a non-water position (skip) ends the run there; maxCount ends the search at once (accepted, nodes taken)',[("0",bcall(*c[:3],c[3],c[4],c[5]),2) for c in cases]," ".join("%d/%d"%bfs(c[0],c[1],c[2],c[4],c[5]) for c in cases))
rows(g,'wet sponge placement (10.2, example 9): only where water_evaporates at pos is true it becomes a sponge, level event 2009 and the wet_sponge_dries sound with pitch (1 + r x 0.2) x 0.7 (x 1000000); none otherwise (becomes sponge, event, sound, pitch)','GC3-WET-SPONGE',2,4,[(1,0.0),(1,0.5),(1,0.25),(0,0.5)],lambda e,r:(1,2009,1,m((1+r*0.2)*0.7,1000000)) if e else (0,0,0,0),fl=(2,))
def drip(d,st,a,b):
    if d==2 or st: return 0,0,0,0
    if d==1: return 1,-50,m(a),m(b)
    return 1,m(a*0.8),m(b),-1
dc=[(2,0,0.5,0.5),(3,1,0.5,0.5),(1,1,0.5,0.5),(1,0,0.25,0.75),(3,0,0.5,0.25),(6,0,0.125,0.5)]
rows(g,'wet sponge animateTick (10.2): a random direction other than UP, unless the neighbour in it occludes with a sturdy face toward the block, spawns dripping_water: down at y - 0.05 with a draw added to x and z; a side face at y + draw x 0.8 with a draw for the other horizontal coordinate (spawn, y, first, second; x 1000)','GC3-WET-DRIP',4,4,dc,drip,fl=(3,4))
rows(g,'magma stepOn (10.3): a living entity that is not stepping carefully takes 1.0 damage of the hotFloor source (x 10); sneaking or a non-living entity takes none','GC3-MAGMA-STEP',2,1,[(0,1),(1,1),(0,0),(1,0)],lambda c,l:(10 if (c==0 and l==1) else 0,))
g.run('magma registry values (10.3): light 3, strength 0.5, valid spawn for fire-immune types only, emissive rendering, post process, Frost Walker immunity to burn_from_stepping',["0"],'CALL "GC3-MAGMA-REG" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,"3/5/1/1/1/1")
W3(g,10)
# ===== part 4 shared data
def keycase(g,text,name,items,n=1):
    g.case(text,[("0",'MOVE "minecraft:%s" TO WS-T1\nCALL "%s" USING WS-T1 %s'%(k,name," ".join("WS-R(%d)"%i for i in range(1,n+1))),n) for k,_ in items]," ".join(str(v) for _,v in items))
FLOWERS=["dandelion","golden_dandelion","torchflower","poppy","blue_orchid","allium","azure_bluet","red_tulip","orange_tulip","white_tulip","pink_tulip","oxeye_daisy","cornflower","lily_of_the_valley"]
# (name, section x10, random-tick flag, condition: 0 none, 1 stage == 0, 2 age < 5, 3 age < 25)
CLASSES=[("kelp",33,1,3),("kelp_plant",33,0,0),("weeping_vines",34,1,3),("weeping_vines_plant",34,0,0),("twisting_vines",34,1,3),("twisting_vines_plant",34,0,0),
("cave_vines",35,1,3),("cave_vines_plant",35,0,0),("sugar_cane",40,1,0),("cactus",51,1,0),("cactus_flower",52,0,0),("bamboo",60,1,1),("bamboo_sapling",60,1,0),("vine",70,1,0),
("chorus_plant",81,0,0),("chorus_flower",82,1,2),("seagrass",92,0,0),("tall_seagrass",93,0,0),("short_grass",95,0,0),("fern",95,0,0),("tall_grass",91,0,0),("large_fern",91,0,0),("pitcher_plant",91,0,0),
("sunflower",96,0,0),("lilac",96,0,0),("rose_bush",96,0,0),("peony",96,0,0)]+[(f,101,0,0) for f in FLOWERS]+[("wither_rose",102,0,0),("open_eyeblossom",103,1,0),("closed_eyeblossom",103,1,0),
("pink_petals",104,0,0),("wildflowers",104,0,0),("bush",105,0,0),("red_shrub",105,0,0),("dead_bush",106,0,0),("short_dry_grass",106,0,0),("tall_dry_grass",106,0,0),("firefly_bush",107,0,0),
("sea_pickle",111,0,0),("lily_pad",112,0,0),("big_dripleaf",121,0,0),("big_dripleaf_stem",122,0,0),("small_dripleaf",124,0,0),("hanging_roots",131,0,0),("spore_blossom",132,0,0),
("pale_hanging_moss",133,0,0),("mangrove_roots",134,0,0),("muddy_mangrove_roots",134,0,0)]
# ===== 1
g=G4(1,'Scope, ownership and class table','T0581','the registry names and classes of 1.2 (block to section, random-tick flag) and the spot-checked rows.')
CH=[CLASSES[i:i+20] for i in range(0,len(CLASSES),20)]
for i,ch in enumerate(CH):
    keycase(g,'registry names of 1.2 map to their section x10 (3.3 is 33, 5.1 is 51, 10.1 is 101; part %d of %d)'%(i+1,len(CH)),'GC4-PART',[(k,s) for k,s,_,_ in ch])
    keycase(g,'registry random-tick flag and the per-state condition of 1.2 (0 none, 1 stage == 0, 2 age < 5, 3 age < 25; part %d of %d)'%(i+1,len(CH)),'GC4-RT-FLAG',[(k,"%d/%d"%(r,c)) for k,_,r,c in ch],2)
keycase(g,'names that are not blocks of this part map to 0 with no random tick','GC4-PART',[("stone",0),("grass_block",0),("leaves",0),("oak_sapling",0)])
keycase(g,'names that are not blocks of this part have no random tick (0/0)','GC4-RT-FLAG',[("stone","0/0"),("oak_leaves","0/0")],2)
W4(g,1)
# ===== 2
g=G4(2,'Shared base, helpers and vocabulary','T0583','VegetationBlock and BushBlock (2.1, 2.2), the helpers of 2.3, the tags of 2.4 and the flags of 2.5.')
DIRT=["dirt","coarse_dirt","rooted_dirt"]; SAND=["sand","red_sand","suspicious_sand"]
SUB=DIRT+["mud","moss_block","grass_block"]
SV=SUB+["farmland"]
TERRA=["terracotta"]+[c+"_terracotta" for c in "white orange magenta light_blue yellow lime pink gray light_gray cyan purple blue brown green red black".split()]
SMALLD=["clay","moss_block"]
TAGS={1:SV,2:SUB,3:DIRT,4:SAND,5:SUB+SAND,6:["frosted_ice"],7:SAND,8:["cactus","farmland"],9:SAND+SUB+["bamboo","bamboo_sapling","gravel","suspicious_gravel"],10:["magma_block"],11:["end_stone"],
12:SAND+TERRA+SV,13:TERRA,14:SV+["netherrack","soul_sand","soul_soil"],15:["ice","frosted_ice"],16:SMALLD,17:SMALLD+["dirt","grass_block","podzol","coarse_dirt","mycelium","rooted_dirt","moss_block","mud","muddy_mangrove_roots","farmland"],
18:["tube_coral_block","brain_coral_block","bubble_coral_block","fire_coral_block","horn_coral_block"],19:["pale_oak_log","pale_oak_wood","stripped_pale_oak_log","stripped_pale_oak_wood"],20:["water","flowing_water"],21:["water"]}
NAMES={1:"supports_vegetation",2:"substrate_overworld",3:"dirt",4:"sand",5:"supports_sugar_cane",6:"supports_sugar_cane_adjacently (block)",7:"supports_cactus",8:"support_override_cactus_flower",9:"supports_bamboo",10:"cannot_support_kelp and cannot_support_seagrass",11:"supports_chorus_plant and supports_chorus_flower",12:"supports_dry_vegetation",13:"terracotta",14:"supports_wither_rose",15:"supports_lily_pad (block)",16:"supports_small_dripleaf",17:"supports_big_dripleaf",18:"coral_blocks",19:"pale_oak_logs",20:"supports_sugar_cane_adjacently (fluid, water tag)",21:"supports_lily_pad (fluid)"}
PROBE=["dirt","coarse_dirt","rooted_dirt","mud","moss_block","grass_block","farmland","podzol","mycelium","sand","red_sand","suspicious_sand","gravel","suspicious_gravel","clay","stone","frosted_ice","ice","cactus","bamboo","bamboo_sapling","magma_block","end_stone","netherrack","soul_sand","soul_soil","terracotta","white_terracotta","black_terracotta","glazed_terracotta","muddy_mangrove_roots","tube_coral_block","dead_tube_coral_block","pale_oak_log","pale_oak_wood","stripped_pale_oak_log","stripped_pale_oak_wood","oak_log","water","flowing_water","lava","packed_ice"]
for t in sorted(TAGS):
    keys=sorted(set(TAGS[t]+PROBE)) if t not in (13,) else sorted(set(TAGS[t]+PROBE))
    first=keys[:21]; 
    cs=[(t,k) for k in keys]
    for j in range(0,len(cs),22):
        part=cs[j:j+22]
        g.case('tag %s (2.4): members and non-members (part %d)'%(NAMES[t],j//22+1),[(str(t),'MOVE "minecraft:%s" TO WS-T1\nCALL "GC4-IN-TAG" USING WS-I(1) WS-T1 WS-R(1)'%k,1) for _,k in part]," ".join("1" if k in TAGS[t] else "0" for _,k in part))
rows(g,'VegetationBlock (2.1): canSurvive is mayPlaceOn of the state below (supports_vegetation); the shape update gives air when it fails, else the state unchanged (1 keep, 0 air), and schedules no tick (survive, update, tick)','GC4-VEG-RULES',1,3,[(1,),(0,)],lambda b:(b,b,0))
rows(g,'VegetationBlock facts (2.1): propagatesSkylightDown = the fluid state is empty; isPathfindable is true for path type AIR with no collision, else the default (-1)','GC4-VEG-FACTS',3,2,[(1,1,1),(0,1,1),(1,0,1),(1,1,0),(0,0,0)],lambda f,a,n:(f,1 if (a and n) else -1))
rows(g,'BushBlock (2.2): shape height 13 unless the constructor passes another; bone meal is the neighbour spreader: valid when a neighbour can take the copy, always successful, type GROWER (1), written with flags 3 (valid, success, type, flags)','GC4-BUSH-BONE',1,4,[(1,),(0,)],lambda s:(s,1,1,3))
rows(g,'BushBlock shape (2.2): column height 13 by default, the constructor argument otherwise (bush and red_shrub use 13)','GC4-BUSH-SHAPE',1,2,[(0,),(13,),(9,)],lambda h:(16,13 if h==0 else h))
keycase(g,'FlowerBlock extends VegetationBlock, not BushBlock (2.2 correction): only bush and red_shrub use the generic spreader','GC4-BUSH-CLASS',[("bush",1),("red_shrub",1),("dandelion",0),("golden_dandelion",0),("wither_rose",0),("open_eyeblossom",0),("closed_eyeblossom",0),("poppy",0),("firefly_bush",0),("short_grass",0)])
fc=[(0,0,0),(1,0,0),(2,0,0),(2,1,5),(2,1,7),(3,0,0),(2,0,0)]
def fl(k,a,l): return (int(k in(1,2)),int(k==1),int(k==1 or k==2),int(k==2 and l==8))
rows(g,'fluid state tests (2.3): isWaterAt is the tag test (source and flowing); FluidState.is(Fluids.WATER) only the still water object; isSourceOfType; isFull is amount 8 (kind 0 empty, 1 water source, 2 flowing water, 3 lava; amount) (in tag, is WATER, source, full)','GC4-FLUID',2,4,[(0,0),(1,8),(2,8),(2,5),(3,8)],lambda k,a:(int(k in (1,2)),int(k==1),int(k==1),int(a==8)))
rows(g,'LiquidBlockContainer (2.3): canPlaceLiquid and placeLiquid both false, the fluid state always a water source (1)','GC4-LIQCONT',0,3,[()],lambda :(0,0,1))
rows(g,'copyWaterloggedFrom (2.3): with the property waterlogged it takes isWaterAt(pos); without it the state is unchanged (-1)','GC4-WATERLOG-COPY',2,1,[(1,1),(1,0),(0,1),(0,0)],lambda p,w:(w if p else -1,))
HOR=[3,6,4,5]
rows(g,'orders (2.3): Plane.HORIZONTAL is north, east, south, west (a random direction is HORIZONTAL[nextInt(4)]); Plane.VERTICAL is up, down; Direction.getRandom is nextInt(6) over down, up, north, south, west, east (3 north 4 south 5 west 6 east)','GC4-HDIR',2,1,[(1,i) for i in range(4)]+[(2,0),(2,1)]+[(3,i) for i in range(6)],lambda k,i:(HOR[i] if k==1 else [2,1][i] if k==2 else i+1,))
CW={3:6,6:4,4:5,5:3}
rows(g,'clockwise and counter-clockwise (2.3): north to east, east to south, south to west, west to north; the counter-clockwise is the inverse (kind 4 clockwise, 5 counter-clockwise)','GC4-HDIR',2,1,[(4,d) for d in (3,6,4,5)]+[(5,d) for d in (3,6,4,5)],lambda k,d:(CW[d] if k==4 else [x for x in CW if CW[x]==d][0],))
rows(g,'Mth.nextInt(r, a, b) (2.3): a when a >= b, else a + nextInt(b - a + 1) (the draw is the value of nextInt)','GC4-NEXT-INT',3,1,[(3,3,0),(5,3,0),(2,5,3),(-10,10,20),(0,0,0)],lambda a,b,d:(a if a>=b else a+d,))
rows(g,'Mth.randomBetween(r, a, b) (2.3): nextFloat * (b - a) + a, one draw (x 1000000)','GC4-RAND-BETWEEN',3,1,[(0.8,1.2,0.0),(0.8,1.2,0.5),(0.8,1.2,0.25),(0,2,0.75)],lambda a,b,r:(m(r*(b-a)+a,1000000),),fl=(1,2,3))
FLG={1:2,2:3,3:18,4:35,5:260,6:1033,7:1034,8:2001}
rows(g,'flags and events (2.5): flags 2 clients only, 3 neighbours and clients, 18 = 2 + 16, 35 = 1 + 2 + 32, 260 = 4 + 256; level events 1033, 1034 (chorus flower grew, died) and 2001 (block destroy)','GC4-FLAG',1,1,[(k,) for k in sorted(FLG)],lambda k:(FLG[k],))
rows(g,'scheduled tick of the non-vegetation blocks (2.1, 14.1): a shape update that finds the block unable to survive schedules a block tick with delay 1 (scheduled, delay); the tick destroys the block with drops when it cannot survive (destroy, drops)','GC4-SU-TICK',1,2,[(1,),(0,)],lambda s:(0,0) if s else (1,1))
rows(g,'tick of those blocks (14.1): destroyBlock with drops only when canSurvive is false','GC4-TICK-REMOVE',1,2,[(1,),(0,)],lambda s:(0,0) if s else (1,1))
W4(g,2)
# ===== 3
g=G4(3,'The growing plant family','T0585','the head and body engine (3.1, 3.2), kelp (3.3), weeping and twisting vines (3.4), cave vines and glow berries (3.5), worked examples 1 to 3.')
g.extra=" 01 WS-DRG.\n    05 WS-DR FLOAT-LONG OCCURS 16 TIMES.\n"
DN,UP=1,2
GD={1:(UP,1,140,1,1,1,16,0,9),2:(UP,1,0,0,0,1,16,0,16),3:(DN,0,100,0,2,2,8,9,16),4:(DN,0,0,0,0,2,14,0,16),5:(UP,0,100,0,2,2,8,0,15),6:(UP,0,0,0,0,2,8,0,16),7:(DN,0,100,1,2,2,14,0,16),8:(DN,0,0,0,0,2,14,0,16)}
rows(g,'constructor data (3.1) of kelp, kelp_plant, weeping_vines, weeping_vines_plant, twisting_vines, twisting_vines_plant, cave_vines, cave_vines_plant: growth direction (1 down, 2 up), scheduleFluidTicks, head probability x 1000, blocks per bone meal (0 for the NetherVines count), canGrowInto (1 water block, 2 air, 0 body), canAttachTo (1 not magma_block, 2 always), shape width, y from, y to','GC4-GROW-DATA',1,9,[(b,) for b in range(1,9)],lambda b:GD[b])
rows(g,'constants of the family (3.1, 3.2 step 5, 3.4): AGE_25 maximum 25 and default 0; NetherVines GROW_PER_TICK_PROBABILITY 0.1 (x 1000) and BONEMEAL_GROW_PROBABILITY_DECREASE_RATE 0.826 (x 1000)','GC4-GROW-CONST',0,4,[()],lambda :(25,0,100,826))
def gs(a,f,s): return int(a==1 and (f==1 or s==1))
gsc=[(0,1,1),(1,1,0),(1,0,1),(1,0,0),(0,0,0)]
rows(g,'support test (3.2 step 1): false when canAttachTo of the state behind is false; otherwise true when it is the head or the body block of the family or its face toward the plant is sturdy (attach, family, sturdy)','GC4-GROW-SURVIVE',3,1,gsc,lambda a,f,s:(gs(a,f,s),))
def gp(k,f,w,fu,d):
    if k and not (w and fu): return 0,-1
    if f: return 1,-1
    return 2,d
gpc=[(1,0,1,1,7),(1,1,1,1,7),(1,0,1,0,7),(1,0,0,1,7),(0,0,0,0,24),(0,1,0,0,24),(0,0,0,0,0),(1,1,0,0,3)]
rows(g,'placement (3.2 step 3): kelp is null unless the clicked fluid is water and full; then the body when the state in the growth direction is the head or body, else the head with age nextInt(25) (kind, family, water, full, draw) (0 null, 1 body, 2 head; age or -1)','GC4-GROW-PLACE',5,2,gpc,gp)
def hr(age,p,d,cg):
    if age>=25: return 0,0,0,age,0
    gr=int(d<p and cg)
    return 1,1,gr,age+1 if gr else age,3 if gr else 0
hrc=[(3,0.14,0.10,1),(3,0.14,0.20,1),(3,0.14,0.10,0),(25,0.14,0.0,1),(24,0.1,0.05,1),(0,0.1,0.1,1),(0,0.1,0.0999,1)]
rows(g,'head random tick (3.2 steps 5 and 6, example 1): isRandomlyTicking is age < 25; the nextDouble is drawn only then and must be below the probability; the cell beyond must accept growth; the new head has age + 1 and is written with flags 3 (ticking, drawn, grew, age after, flags)','GC4-HEAD-RANDOM',4,5,hrc,hr,fl=(2,3))
def hs(dk,sv,fam,sf):
    tick=body=0
    if dk==1:
        if not sv: tick=1
        elif fam: body=1
    elif dk==2 and fam: body=1
    return tick,body,sf
hsc=[(1,0,0,0),(1,1,1,0),(1,1,0,0),(2,1,1,0),(2,1,0,0),(0,1,1,0),(0,0,1,1),(1,1,1,1),(2,0,1,1)]
rows(g,'head shape update (3.2 step 7): from the anchor side a head that cannot survive schedules a tick (delay 1), else becomes a body when the growth cell is the head or body; from the growth side a family neighbour makes it a body; kelp also schedules a water tick (changed direction 0 other, 1 anchor, 2 growth; survive; family; fluid ticks) (tick, becomes body, water tick)','GC4-HEAD-SU',4,3,hsc,hs)
def bs(dk,sv,fam,sf,d):
    tick=head=0; age=-1
    if dk==1 and not sv: tick=1
    if dk==2 and not fam: head=1; age=d
    return tick,head,age,sf
bsc=[(1,0,1,0,9),(1,1,1,0,9),(2,1,0,0,9),(2,1,1,0,9),(0,0,0,0,9),(2,0,0,1,17),(1,1,0,1,3)]
rows(g,'body shape update (3.2 step 10): from the anchor side a body that cannot survive schedules a tick; from the growth side a neighbour that is neither body nor head turns the top body into a head with age nextInt(25); kelp also schedules a water tick (tick, head, age or -1, water tick)','GC4-BODY-SU',5,4,bsc,bs)
def bv(f,c,h): return int(f and c and h),int(f and c and h)
bvc=[(1,1,1),(0,1,1),(1,0,1),(1,1,0)]
rows(g,'bone meal validity (3.2 steps 8 and 11): a head found (the head itself, or the body\'s walk), the cell beyond it accepts growth and is inside the build height; success always (valid, success)','GC4-GROW-BONE-VALID',3,2,bvc,lambda f,c,h:(int(f and c and h),1))
def gb(age,n,fr):
    w=min(n,fr); 
    if w==0: return 0,0,0
    a=min(age+1,25); first=a; last=a
    for _ in range(w-1):
        a=min(a+1,25); last=a
    return w,first,last
gbc=[(20,2,4),(20,4,4),(20,3,2),(24,3,9),(25,2,5),(0,1,1),(5,2,0),(3,5,5)]
rows(g,'bone meal effect (3.2 step 8, example 2): up to n cells, while the cell accepts growth; each written head has age min(a + 1, 25) counting up from the clicked head (written, first age, last age)','GC4-GROW-BONE',3,3,gbc,gb)
rows(g,'finding the head of a body (3.2 step 11): the cells after pos holding the body block, then the first other cell must be the head (run, terminator is the head) (found, offset of that cell)','GC4-BODY-FIND',2,2,[(0,1),(3,1),(2,0),(0,0)],lambda r,t:(t,r+1))
rows(g,'canBeReplaced of a body (3.2 step 12): the default result, except false when the item in hand is the head item','GC4-BODY-REPLACE',2,1,[(1,0),(1,1),(0,0),(0,1)],lambda d,i:(0 if i else d,))
def nc(ds):
    t=1.0;c=0
    for d in ds:
        if d<t: t=t*0.826;c+=1
        else: break
    return c
ncc=[[0.99,0.9],[0.99,0.70,0.90],[0.5,0.5,0.5,0.5,0.9],[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.1,0.9],[0.9999,0.8,0.69,0.55,0.9]]
def ncall(ds):
    s='INITIALIZE WS-DRG\n'
    for i,d in enumerate(ds): s+='MOVE %s TO WS-DR(%d)\n'%(d,i+1)
    s+='MOVE 9.9 TO WS-DR(%d)\nCALL "GC4-NETHER-COUNT" USING WS-DRG WS-R(1)'%(len(ds)+1)
    return s
g.case('NetherVines count (3.4, example 2): threshold 1.0 and count 0; each nextDouble below the threshold multiplies it by 0.826 and counts; the first draw at or above it stops; so the count is at least 1',[("0",ncall(d),1) for d in ncc]," ".join(str(nc(d)) for d in ncc))
rows(g,'NetherVines distribution (3.4): P(count >= k) = 0.826^(k (k - 1) / 2), x 10000, for k = 1 to 6 (1, 0.826, 0.5636, 0.3176, 0.1478, 0.0568)','GC4-NETHER-P',1,1,[(k,) for k in range(1,7)],lambda k:(m(0.826**(k*(k-1)//2),10000),))
rows(g,'expected growth time (3.3, 4): with random_tick_speed 3 a head is ticked 3 / 4096 per game tick, so the game ticks per step are ticks needed x 4096 / (speed x probability): kelp 9752 (8.1 minutes), sugar cane 16 random ticks 21845 (18.2 minutes) (ticks, minutes x 10)','GC4-GROW-TIME',3,2,[(3,0.14,1),(3,1.0,16)],lambda s,p,n:(m(n*4096/(s*p),1),m(n*4096/(s*p)/1200,10)),fl=(2,))
def cg(a,d1,d2,c):
    if a>=25: return 0,a,0,0
    if not (d1<0.1 and c): return 0,a,0,1
    return 1,a+1,int(d2<0.11),2
cgc=[(3,0.05,0.08,1),(3,0.05,0.5,1),(3,0.2,0.0,1),(3,0.05,0.05,0),(25,0.0,0.0,1),(24,0.0,0.109,1)]
rows(g,'cave vines growth (3.5 step 1, example 3): nextDouble below 0.1 (only at age < 25) and air beyond; then one more draw: berries = nextFloat < 0.11 on the new head (grew, age, berries, draws made)','GC4-CAVE-GROW',4,4,cgc,cg,fl=(2,3))
rows(g,'cave vines placement (3.5 step 2): the head has age nextInt(25) and berries false','GC4-CAVE-PLACE',1,2,[(0,),(24,),(11,)],lambda d:(d,0))
rows(g,'cave vines conversions (3.5 step 3): head to body copies berries (no age); body to head copies berries onto the new head with age nextInt(25) (berries, age or -1)','GC4-CAVE-CONVERT',3,2,[(1,1,0),(1,0,0),(2,1,13),(2,0,24)],lambda k,b,d:(b,-1 if k==1 else d))
rows(g,'cave vines bone meal (3.5 step 4): valid when berries is false, success always; sets berries true with flags 2 on the clicked block only, no growth (valid, success, berries after, flags)','GC4-CAVE-BONE',1,4,[(0,),(1,)],lambda b:(int(b==0),1,1,2))
def ch(b,sv,r):
    if b==0: return 0,0,0,-1,0,0
    if not sv: return 1,0,0,-1,0,0
    return 1,1,m(r*0.4+0.8,1000000),0,2,1
chc=[(0,1,0.5),(1,0,0.5),(1,1,0.0),(1,1,0.5),(1,1,0.25)]
rows(g,'cave vines harvest (3.5 step 5, example 3): PASS without berries; with berries a client result is SUCCESS with no effect; on a server the loot is dropped, the pick sound plays with pitch randomBetween(0.8, 1.2) (x 1000000), berries become false with flags 2 and BLOCK_CHANGE is sent (result 0 PASS 1 SUCCESS; drops; pitch; berries after or -1; flags; game event)','GC4-CAVE-HARVEST',3,6,chc,ch,fl=(3,))
rows(g,'cave vines light (3.5): 14 with berries, else 0','GC4-CAVE-LIGHT',1,1,[(0,),(1,)],lambda b:(14*b,))
W4(g,3)
# ===== 4
g=G4(4,'Sugar cane','T0587','state and shape (4), survival (4.1), shape update and tick (4.2), random tick (4.3), no bone meal (4.4), worked example 4.')
rows(g,'sugar cane constants (4): age maximum 15, shape column 12 wide from 0 to 16, no bone meal (0), the age writes use flags 260','GC4-CANE-CONST',0,6,[()],lambda :(15,12,0,16,0,260))
def cs(c,t,*n): return int(c or (t and any(n)))
csc=[(1,0,0,0,0,0),(0,1,0,0,0,0),(0,1,1,0,0,0),(0,1,0,1,0,0),(0,1,0,0,1,0),(0,1,0,0,0,1),(0,0,1,1,1,1),(0,1,0,0,0,0)]
rows(g,'sugar cane survival (4 step 1): true when the block below is sugar cane; otherwise when it is in supports_sugar_cane and any of the four horizontal neighbours of the block below (north, east, south, west) has water in its fluid or frosted_ice as its block (below is cane, below in tag, then the four neighbours)','GC4-CANE-SURVIVE',6,1,csc,lambda *a:(cs(*a),))
def cr(air,c,age):
    if not air: return 0,0,-1,0,0
    h=1+c
    if h>=3: return 0,0,-1,0,h
    if age==15: return 1,1,0,260,h
    return 1,0,age+1,260,h
crc=[(0,0,3),(1,0,0),(1,1,7),(1,0,15),(1,1,15),(1,2,3),(1,2,15),(1,5,0)]
rows(g,'sugar cane random tick (4 step 3, example 4): only when the cell above is air; h is 1 plus the canes directly below; with h < 3 age 15 places a new cane above and resets the age, else age + 1, both written with flags 260; a column of 3 never changes (acted, new cane above, age after or -1, age flags, h)','GC4-CANE-RT',3,5,crc,cr)
W4(g,4)
# ===== 5
g=G4(5,'Cactus and cactus flower','T0589','cactus constants (5.1), survival (5.1 step 1), damage (step 3), random tick (step 4), worked example 5, cactus flower (5.2).')
rows(g,'cactus constants (5.1): MAX_CACTUS_GROWING_HEIGHT 3, ATTEMPT_GROW_CACTUS_FLOWER_AGE 8, flower chances 0.1 and 0.25 (x 1000), selection shape 14 wide 0 to 16, collision shape 14 wide 0 to 15, not pathfindable','GC4-CACTUS-CONST',0,9,[()],lambda :(3,8,100,250,14,0,16,15,0))
def cu(n1,n2,n3,n4,b,l): return (int(not (n1 or n2 or n3 or n4) and b and not l),)
cuc=[(0,0,0,0,1,0),(1,0,0,0,1,0),(0,1,0,0,1,0),(0,0,1,0,1,0),(0,0,0,1,1,0),(0,0,0,0,0,0),(0,0,0,0,1,1)]
rows(g,'cactus survival (5.1 step 1): false when any horizontal neighbour is solid or in fluid tag lava; then true when the block below is a cactus or in supports_cactus and the state above is not a liquid (four neighbours, below ok, above liquid)','GC4-CACTUS-SURVIVE',6,1,cuc,cu)
rows(g,'cactus entityInside (5.1 step 3): 1.0 damage (x 10) of the cactus source to every entity inside, no side test (0), called with frequency 18 (damage, side test, frequency)','GC4-CACTUS-HURT',0,3,[()],lambda :(10,0,18))
def ct(air,c,age,sa,d):
    if not air: return 0,0,0,-1,0,0
    h=1+c
    if h>=3 and age==15: return 0,0,0,-1,h,0
    fl=nc_=0; drew=0; step3=(age==8 and sa)
    if step3:
        drew=1; ch=0.25 if h>=3 else 0.1
        if d<=ch: fl=1
    elif age==15 and h<3:
        return 1,0,1,0,h,0
    na=age+1 if age<15 else -1
    return 1,fl,0,na,h,drew
ctc=[(0,0,8,1,0.0),(1,2,15,1,0.0),(1,0,15,0,0.0),(1,1,8,1,0.07),(1,1,8,1,0.5),(1,1,8,1,0.1),(1,0,8,1,0.1),(1,0,8,1,0.11),(1,2,8,1,0.25),(1,2,8,1,0.26),(1,1,8,0,0.0),(1,0,3,1,0.0),(1,0,15,1,0.0),(1,1,14,1,0.0)]
rows(g,'cactus random tick (5.1 step 4, example 5): nothing unless the cell above is air; a column of 3 refuses at age 15; at age 8, when a cactus survives above, the draw nextDouble <= 0.1 (h < 3) or 0.25 (h >= 3) places a flower; at age 15 and h < 3 a new cactus is placed and the age reset (flags 260); otherwise age + 1 (acted, flower, new cactus, age after or -1, h, drew)','GC4-CACTUS-RT',5,6,ctc,ct,fl=(5,))
rows(g,'cactus flower (5.2): no properties and no ticks; shape 14 wide 0 to 12; mayPlaceOn the block below in support_override_cactus_flower or with a CENTER-sturdy top face (properties, ticks, shape width, y from, y to)','GC4-CFLOWER-CONST',0,5,[()],lambda :(0,0,14,0,12))
rows(g,'cactus flower mayPlaceOn (5.2): the block below in support_override_cactus_flower (cactus, farmland) or its top face is CENTER sturdy (tag, sturdy)','GC4-CFLOWER-PLACE',2,1,[(1,0),(0,1),(1,1),(0,0)],lambda t,s:(int(t or s),))
W4(g,5)
