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
18:["tube_coral_block","brain_coral_block","bubble_coral_block","fire_coral_block","horn_coral_block"],19:["pale_oak_log","pale_oak_wood","stripped_pale_oak_log","stripped_pale_oak_wood"],20:["water","flowing_water"],21:["water"],22:TERRA+["sand","red_sand"]}
NAMES={1:"supports_vegetation",2:"substrate_overworld",3:"dirt",4:"sand",5:"supports_sugar_cane",6:"supports_sugar_cane_adjacently (block)",7:"supports_cactus",8:"support_override_cactus_flower",9:"supports_bamboo",10:"cannot_support_kelp and cannot_support_seagrass",11:"supports_chorus_plant and supports_chorus_flower",12:"supports_dry_vegetation",13:"terracotta",14:"supports_wither_rose",15:"supports_lily_pad (block)",16:"supports_small_dripleaf",17:"supports_big_dripleaf",18:"coral_blocks",19:"pale_oak_logs",20:"supports_sugar_cane_adjacently (fluid, water tag)",21:"supports_lily_pad (fluid)",22:"triggers_ambient_desert_dry_vegetation_block_sounds"}
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
# ===== 6
g=G4(6,'Bamboo','T0591','states and constants (6.1), the stalk (6.2), the sapling (6.3), worked example 6.')
rows(g,'bamboo constants (6.1): MAX_HEIGHT 16, age and stage maximum 1, large leaves shape 10 wide, other 6, collision 3, sapling 8 wide to 12, stalk strength 1.0 (x 10)','GC4-BAMBOO-CONST',0,8,[()],lambda :(16,1,1,10,6,3,8,12))
rows(g,'stalk ticking (6.1): isRandomlyTicking is stage == 0','GC4-BAMBOO-TICKING',1,1,[(0,),(1,)],lambda s:(int(s==0),))
def bpl(fe,ok,bk,bage,ak,aage):
    if not fe or not ok: return 0,-1
    if bk==1: return 1,0
    if bk==2: return 1,(1 if bage>0 else 0)
    if ak==1: return 1,aage
    return 2,-1
bpc=[(0,1,0,0,0,0),(1,0,0,0,0,0),(1,1,1,0,0,0),(1,1,2,1,0,0),(1,1,2,0,0,0),(1,1,0,0,1,1),(1,1,0,0,1,0),(1,1,0,0,0,0)]
rows(g,'stalk placement (6.2 step 1): null when the fluid is not empty or the block below is not in supports_bamboo; a sapling below gives age 0, a stalk below age 1 when its age > 0, else the stalk above gives its age, else a bamboo_sapling (fluid empty, below supported, below kind 0 other 1 sapling 2 bamboo, below age, above kind 0 other 1 bamboo, above age) (0 null 1 stalk 2 sapling; age)','GC4-BAMBOO-PLACE',6,2,bpc,bpl)
def bsu(sv,up,nb,na,age):
    tick=int(not sv); newage=-1
    if up and nb and na>age: newage=1-age
    return tick,newage
bsc=[(0,0,0,0,0),(1,1,1,1,0),(1,1,1,0,0),(1,1,1,1,1),(1,0,1,1,0),(1,1,0,1,0),(0,1,1,1,0)]
rows(g,'stalk shape update (6.2 step 2): a stalk that cannot survive schedules a tick; from UP a bamboo neighbour with a greater age cycles this age (0 becomes 1) (survive, direction is UP, neighbour is bamboo, neighbour age, age) (tick, new age or -1)','GC4-BAMBOO-SU',5,2,bsc,bsu)
def brt(stage,d,air,br,below):
    if stage!=0: return 0,0,0
    h=min(below,16)+1
    if d!=0: return 1,0,h
    return 1,int(air and br>=9 and h<16),h
brc=[(0,0,1,9,0),(0,1,1,9,0),(0,0,0,9,0),(0,0,1,8,0),(0,0,1,15,14),(0,0,1,9,15),(0,0,1,9,16),(1,0,1,9,0),(0,2,1,9,0)]
rows(g,'stalk random tick (6.2 step 4): only while stage == 0; nextInt(3) is drawn first and must be 0; then the cell above must be air with raw brightness at least 9; h is the bamboo below (at most 16) plus 1 and growth needs h < 16 (stage, draw, air above, brightness, bamboo below) (ticking, grows, h)','GC4-BAMBOO-RT',5,3,brc,brt)
def grow(h,b1,b2,age,f):
    l=0;r1=r2=0
    if h>=1:
        if b1==0 or b1==1: l=1
        else:
            l=2
            if b2: r1=r2=1
    thick=int(age==1 or b2==1)
    drew=int(h>=11)
    done=int((h>=11 and f<0.25) or h==15)
    return l,r1,r2,thick,done,drew
grc=[(0,0,0,0,0.9),(1,0,0,0,0.9),(2,1,0,0,0.9),(2,2,0,0,0.9),(3,2,1,0,0.9),(2,1,1,0,0.9),(3,1,0,1,0.9),(5,2,1,1,0.9),(10,2,1,1,0.0),(11,2,1,1,0.24),(11,2,1,1,0.25),(14,2,1,1,0.9),(15,2,1,1,0.9),(15,2,1,1,0.0),(12,0,0,0,0.1)]
rows(g,'growBamboo (6.2 step 5): leaves small when the stalk below is not bamboo or has no leaves, else large and, when a stalk two below is bamboo, the one below becomes small and the one two below none; thick when this age is 1 or a stalk two below is bamboo; done when h >= 11 and nextFloat < 0.25 (drawn only then) or h == 15 (h, below kind 0 not bamboo 1 no leaves 2 leaves, bamboo two below, age, draw) (leaves 0 none 1 small 2 large, below set small, two below set none, age, stage, drew)','GC4-BAMBOO-GROW',5,6,grc,grow,fl=(5,))
# worked example 6: the whole column by the doc rules
def simulate(steps):
    col=[(0,0),(1,0)]   # [leaves, age] from the sapling conversion
    out=[list(col)]
    for _ in range(steps):
        n=len(col); top=col[-1]; b1=col[-2] if n>=2 else None; b2=col[-3] if n>=3 else None
        h=n
        if b1 is None or b1[0]==0: leaves=1
        else:
            leaves=2
            if b2 is not None: col[-2]=(1,col[-2][1]); col[-3]=(0,col[-3][1])
        thick=1 if (top[1]==1 or b2 is not None) else 0
        col.append((leaves,thick))
        if thick: col=[(l,1) for l,a in col]
        out.append(list(col))
    return out
cols=simulate(4)
doc={2:[(0,0),(1,0)],3:[(0,0),(1,0),(1,0)],4:[(0,1),(1,1),(1,1),(2,1)],5:[(0,1),(0,1),(1,1),(2,1),(2,1)],6:[(0,1),(0,1),(0,1),(1,1),(2,1),(2,1)]}
for k,v in doc.items(): assert cols[k-2]==v,(k,cols[k-2],v)
gc=[]; ex=[]
col=[(0,0),(1,0)]
for _ in range(4):
    n=len(col); top=col[-1]; b1=col[-2]; b2=col[-3] if n>=3 else None
    b1k=1 if b1[0]==0 else 2
    inp=(n,b1k,int(b2 is not None),top[1],0.9)
    gc.append(inp); ex.append(grow(*inp)[:4])
    col=cols[len(gc)]
rows(g,'bamboo column growth (example 6): the new stalk for columns of 2, 3, 4 and 5 stalks, driven from the column states [none, small], [none, small, small], [none/1, small/1, small/1, large/1], [none, none, small, large, large] (leaves, below set small, two below set none, age, stage, drew)','GC4-BAMBOO-GROW',5,6,gc,grow,fl=(5,))
def bbv(a,b,st,hh,air): return int(a+b+1<16 and st!=1 and hh and air),1
bbc=[(0,0,0,1,1),(3,4,0,1,1),(7,8,0,1,1),(7,7,0,1,1),(0,0,1,1,1),(0,0,0,0,1),(0,0,0,1,0)]
rows(g,'bamboo bone meal validity (6.2 step 6): a + b + 1 < 16, the top stalk has stage != 1, the cell above it is inside the build height and air; success always (above count, below count, top stage, in height, air) (valid, success)','GC4-BAMBOO-BONE-VALID',5,2,bbc,bbv)
def bbone(a,b,st,free,nraw,f1,f2):
    total=a+b+1; n=1+nraw; fs=[f1,f2]; k=0; grown=0
    for _ in range(n):
        if total>=16 or st==1 or free==0: break
        if total>=11:
            d=fs[k]; k+=1; done=int(d<0.25 or total==15)
        else: done=int(total==15)
        st=done; total+=1; grown+=1; free-=1
    return n,grown,total,k
bbe=[(0,0,0,5,0,0.9,0.9),(0,0,0,5,1,0.9,0.9),(0,0,0,1,1,0.9,0.9),(0,0,0,0,1,0.9,0.9),(0,0,1,5,1,0.9,0.9),(7,7,0,5,1,0.9,0.9),(10,0,0,5,1,0.1,0.9),(10,0,0,5,1,0.9,0.1),(10,0,0,5,1,0.9,0.9),(14,0,0,5,1,0.9,0.9),(0,15,0,5,1,0.9,0.9),(3,3,0,5,1,0.9,0.9)]
rows(g,'bamboo bone meal effect (6.2 step 6): n = 1 + nextInt(2) growths; each stops when total >= 16, the top has stage 1, the cell above is not air or outside the height; the nextFloat of growBamboo is drawn only when total >= 11 (above count, below count, top stage, free cells above, nextInt(2), two float draws) (n, grown, total after, floats drawn)','GC4-BAMBOO-BONE',7,4,bbe,bbone,fl=(6,7))
rows(g,'sapling random tick (6.3 step 1, example 6): nextInt(3) == 0, the cell above air and raw brightness >= 9 place a bamboo stalk with leaves small (age 0, stage 0) (draw, air above, brightness) (grows, leaves)','GC4-SAPLING-RT',3,2,[(0,1,9),(1,1,9),(0,0,9),(0,1,8)],lambda d,a,b:(int(d==0 and a and b>=9),1))
def ssu(sv,up,nb):
    if not sv: return (1,)
    if up and nb: return (2,)
    return (0,)
rows(g,'sapling shape update (6.3 step 2): air when it cannot survive; from UP a bamboo neighbour replaces it by the default stalk (leaves none, age 0, stage 0); else unchanged (0 unchanged 1 air 2 stalk)','GC4-SAPLING-SU',3,1,[(0,0,0),(1,1,1),(1,1,0),(1,0,1)],ssu)
rows(g,'sapling bone meal (6.3 step 3): valid when the cell above is air and inside the build height; success always','GC4-SAPLING-BONE',2,2,[(1,1),(1,0),(0,1)],lambda a,h:(int(a and h),1))
W4(g,6)
# ===== 7
g=G4(7,'Vines','T0593','the numbers of 7 re-read in the artifact: gate, crowding box, draws, flags, the re-check of the up face, replacement and shape update.')
rows(g,'vine random tick gate (7): the game rule spread_vines and nextInt(4) == 0 (rule, draw)','GC4-VINE-GATE',2,1,[(1,0),(1,1),(0,0),(0,3)],lambda r,d:(int(r and d==0),))
rows(g,'vine crowding test (7): canSpread when at most 4 vine blocks lie in the box from pos + (-4, -1, -4) to pos + (4, 1, 4), both corners inclusive, 9 x 3 x 9 = 243 cells (count in box) (can spread, volume)','GC4-VINE-CROWD',1,2,[(1,),(4,),(5,),(9,)],lambda c:(int(c<=4),243))
bx=[(0,0,0),(4,1,4),(-4,-1,-4),(5,0,0),(0,2,0),(0,-2,0),(0,0,-5),(-4,1,4)]
rows(g,'vine crowding box (7): the offsets (dx, dy, dz) inside the box are -4 to 4 in x and z and -1 to 1 in y (inside)','GC4-VINE-BOX',3,1,bx,lambda x,y,z:(int(abs(x)<=4 and abs(z)<=4 and abs(y)<=1),))
rows(g,'vine wrap-over chance (7): nextFloat() converted to double compared below 0.05, so the float nearest 0.05 (0.05000000074505806) is not below it (draw)','GC4-VINE-WRAP',1,1,[(0.049,),(0.05,),(0.05000000074505806,),(0.0,),(0.0499999,)],lambda d:(int(d<0.05),),fl=(1,))
bs4=[(a,b,c,d) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1)]
rows(g,'vine faces copied up (7): for north, east, south, west nextBoolean() is drawn first and the face survives only when the draw is false and the neighbour of the cell above is acceptable (four draws, four acceptances) (four faces)','GC4-VINE-UPFACES',8,4,[(1,0,0,1,1,1,0,0),(0,0,0,0,1,1,1,1),(1,1,1,1,1,1,1,1),(0,1,0,1,1,1,1,0),(0,0,1,1,0,1,0,1)],lambda *a:tuple(int(a[i]==0 and a[4+i]==1) for i in range(4)))
rows(g,'vine faces copied down (7): for each of north, east, south, west nextBoolean() is drawn and when true and the source vine has the face the target gets it (four draws, four source faces) (target faces)','GC4-VINE-COPYDOWN',8,4,[(1,0,0,1,1,1,1,1),(1,1,1,1,0,1,0,1),(0,0,0,0,1,1,1,1),(1,1,0,0,1,1,1,1),(0,1,0,1,1,0,1,0),(1,1,1,1,1,1,1,1)],lambda *a:tuple(int(a[i]==1 and a[4+i]==1) for i in range(4)))
rows(g,'vine horizontal connection (7): any of the four horizontal faces is true','GC4-VINE-HCONN',4,1,[(0,0,0,0),(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1)],lambda *a:(int(any(a)),))
rows(g,'vine up-face quirk (7, open question 4): the re-check of the up face (getUpdatedState, kind 1) tests the TOP face of the block above; the random tick and placement (kind 2) test its BOTTOM face (kind, top face full, bottom face full) (acceptable)','GC4-VINE-UPCHECK',3,1,[(1,1,0),(1,0,1),(2,1,0),(2,0,1),(1,1,1),(2,0,0)],lambda k,t,b:(t if k==1 else b,))
rows(g,'vine canBeReplaced (7): while it has fewer than 5 faces (the face map has five entries, no down)','GC4-VINE-REPLACE',1,1,[(0,),(1,),(4,),(5,)],lambda n:(int(n<5),))
rows(g,'vine updateShape (7): for a change from below (down, 1) the default (0); otherwise the recomputed state, or air (2) when it has no face (direction, faces after getUpdatedState)','GC4-VINE-SU',2,1,[(1,0),(1,3),(2,2),(3,0),(2,0)],lambda d,f:(0 if d==1 else (2 if f==0 else 1),))
rows(g,'vine constants (7): every write of the random tick uses flags 2; the face-property map has 5 entries','GC4-VINE-CONST',0,2,[()],lambda :(2,5))
W4(g,7)
# ===== 8
g=G4(8,'Chorus plant and chorus flower','T0595','the plant (8.1), the flower (8.2) and worked example 7.')
rows(g,'chorus plant constants (8.1): PipeBlock size 10, six boolean properties, strength 0.4 (x 10)','GC4-CHORUS-CONST',0,3,[()],lambda :(10,6,4))
def cc(d,pf,sp): return (int(pf or (d==1 and sp)),)
ccc=[(1,0,1),(1,1,0),(1,0,0),(2,0,1),(2,1,0),(3,1,1),(6,0,0),(5,0,1)]
rows(g,'chorus plant connections (8.1 step 1): DOWN is connected to a plant, a flower or a block in supports_chorus_plant; the other five directions only to a plant or a flower (direction, neighbour is plant or flower, neighbour in supports_chorus_plant) (connected)','GC4-CHORUS-CONN',3,1,ccc,cc)
def csu(sv,d,pf,sp):
    if not sv: return 1,-1
    return 0,int(pf or (d==1 and sp))
csuc=[(0,3,0,0),(1,3,1,0),(1,3,0,1),(1,1,0,1),(1,1,0,0),(1,2,1,0)]
rows(g,'chorus plant shape update (8.1 step 2): a plant that cannot survive schedules a tick; otherwise the property of the changed direction is set to connected: a plant or flower neighbour, or DOWN with a neighbour in supports_chorus_plant (survive, direction, plant or flower, supports) (tick, property or -1)','GC4-CHORUS-SU',4,2,csuc,csu)
def cs8(bok,bair,aair,*pq):
    both=not bair and not aair
    for i in range(4):
        p,q=pq[2*i],pq[2*i+1]
        if p:
            if both: return (0,)
            if q: return (1,)
    return (int(bok),)
cs8c=[(1,0,1,0,0,0,0,0,0,0,0),(0,0,1,0,0,0,0,0,0,0,0),(0,0,0,1,1,0,0,0,0,0,0),(1,0,0,1,0,0,0,0,0,0,0),(0,1,1,1,1,0,0,0,0,0,0),(0,0,1,1,0,0,0,0,0,1,1),(0,0,1,1,0,1,1,0,0,0,0),(0,1,0,0,0,0,0,0,0,1,1),(0,0,0,0,0,1,1,0,0,0,0),(0,0,0,0,0,0,0,1,0,0,0),(0,1,1,0,0,0,0,1,1,0,0),(0,0,0,0,0,0,0,0,0,1,0)]
rows(g,'chorus plant survival (8.1 step 4): for each horizontal neighbour that is a plant: false when the blocks below and above are both non-air; otherwise true at once when the block below that neighbour is a plant or in supports_chorus_plant; after the loop true when the block below is a plant or in the tag (below ok, below is air, above is air, then for north, east, south, west: neighbour is a plant, the block below it is a plant or in the tag) (survive)','GC4-CHORUS-SURVIVE',11,1,cs8c,cs8)
def fs(bok,bair,*n):
    if bok: return (1,)
    if not bair: return (0,)
    found=0
    for k in n:
        if k==1:
            if found: return (0,)
            found=1
        elif k!=0: return (0,)
    return (found,)
fsc=[(1,0,0,0,0,0),(0,0,0,0,0,0),(0,1,0,0,0,0),(0,1,1,0,0,0),(0,1,0,0,0,1),(0,1,1,1,0,0),(0,1,1,2,0,0),(0,1,2,0,0,0),(0,1,0,0,2,1),(0,1,0,1,0,0),(1,1,1,1,1,1)]
rows(g,'chorus flower survival (8.2 step 1): true when the block below is the plant or in supports_chorus_flower; false when it is another non-air block; with air below exactly one horizontal neighbour must be a plant and all others air (below ok, below is air, then the four neighbours 0 air 1 plant 2 other) (survive)','GC4-FLOWER-SURVIVE',6,1,fsc,fs)
rows(g,'chorus flower shape update (8.2 step 2): for any changed direction other than UP a flower that cannot survive schedules a tick (delay 1) (direction, survive) (tick)','GC4-FLOWER-SU',2,1,[(1,0),(3,0),(2,0),(3,1),(2,1)],lambda d,s:(int(d!=2 and not s),))
rows(g,'chorus flower projectile hit (8.2 step 3): on a server, when the projectile may interact with the position and may break blocks, the flower is destroyed with drops (server, mayInteract, mayBreak) (destroy)','GC4-FLOWER-PROJ',3,1,[(1,1,1),(0,1,1),(1,0,1),(1,1,0)],lambda a,b,c:(int(a and b and c),))
def col(c2,c3,c4):
    h=1;e=0
    for c in (c2,c3,c4):
        if c==1: h+=1
        else:
            e=int(c==2); break
    return h,e
colc=[(0,0,0),(2,0,0),(1,2,0),(1,1,2),(1,1,1),(1,1,0),(1,0,0)]
rows(g,'chorus flower column (8.2 step 4.3): h is 1 plus the plants below, looking at up to 3 more cells from 2 below; the first non-plant cell ends the look and sets endBelow when it is in supports_chorus_flower (cells 2, 3 and 4 below: 1 plant, 2 end stone, 0 other) (h, endBelow)','GC4-FLOWER-COLUMN',3,2,colc,col)
def fg(bk,h,e,d):
    if bk==1 or bk==3: return 1,0
    if bk==2:
        if h<2: return 1,0
        return int(h<=d),1
    return 0,0
fgc=[(1,1,0,0),(3,1,0,0),(0,1,0,0),(2,1,0,0),(2,2,0,0),(2,2,0,1),(2,2,0,2),(2,3,1,2),(2,3,1,3),(2,3,1,4),(2,4,0,3),(2,4,0,4)]
rows(g,'chorus flower growth test (8.2 step 4.2 to 4.4, example 7): end stone below or air below grows; a plant column grows when h < 2 or h <= nextInt(5 with end stone below, else 4), the draw made only when h >= 2; any other block below does not (below kind 1 supports_chorus_flower 2 plant 3 air 0 other, h, endBelow, the nextInt draw) (grow, drew)','GC4-FLOWER-GROW',4,2,fgc,fg)
def ne(n,ex):
    for i in range(4):
        if i+1!=ex and not n[i]: return (0,)
    return (1,)
nec=[((1,1,1,1),0),((0,1,1,1),0),((0,1,1,1),1),((1,0,1,1),2),((1,1,0,1),3),((1,1,1,0),4),((1,1,1,0),1),((0,0,0,0),0)]
rows(g,'allNeighborsEmpty (8.2 step 5): for each horizontal direction other than the excepted one (0 none, else the index of north, east, south, west) the neighbour must be air; up and down are not tested (four air flags, except) (all empty)','GC4-FLOWER-EMPTY',5,1,[(*n,e) for n,e in nec],lambda *a:ne(a[:4],a[4]))
def rt(air,hi,age,grow,upok,nraw,eb,*v):
    if not air or not hi or age>=5: return 0,0,0,age,0
    if grow and upok: return 1,0,1033,age,0
    if age<4:
        n=nraw+(1 if eb else 0)
        placed=sum(v[:n])
        if placed: return 2,placed,1033,age+1,n
        return 3,0,1034,5,n
    return 4,0,1034,5,0
rtc=[(0,1,0,1,1,0,0,0,0,0,0),(1,0,0,1,1,0,0,0,0,0,0),(1,1,5,1,1,0,0,0,0,0,0),(1,1,0,1,1,0,0,0,0,0,0),(1,1,2,1,0,2,0,1,0,0,0),(1,1,2,0,1,3,0,0,0,1,1),(1,1,2,0,0,0,0,1,1,1,1),(1,1,3,0,0,1,1,0,0,0,0),(1,1,3,0,0,3,1,0,0,0,1),(1,1,4,1,0,2,0,1,1,1,1),(1,1,4,0,1,0,0,0,0,0,0),(1,1,1,0,0,2,0,1,1,0,0)]
rows(g,'chorus flower random tick (8.2 step 4, example 7): nothing unless the cell above is air and in height and age < 5; growing up places a flower of the same age (event 1033); else at age < 4 nextInt(4) (plus 1 over end stone) side attempts, each valid cell receiving an age + 1 flower (1033), the flower becoming a plant when one grew, else dying (age 5, event 1034); at age 4 it dies (1034) (air above, in height, age, grow, room for growing up, nextInt(4), end stone below, validity of the first four attempts) (action 0 nothing 1 up 2 branched 3 died after branching 4 died, flowers placed, event, age of the flower, direction draws)','GC4-FLOWER-RT',11,5,rtc,rt)
rows(g,'chorus flower constants (8.2): AGE_5 maximum and DEAD_AGE 5, isRandomlyTicking is age < 5, support shape 14 wide to 15 (max age, dead age, ticking at age 4, ticking at age 5, width, y to)','GC4-FLOWER-CONST',2,6,[(4,5)],lambda a,b:(5,5,1,0,14,15))
W4(g,8)
# ===== 9
g=G4(9,'Seagrass, tall seagrass, double plants, short grass and ferns, tall flowers','T0597','the double plant base (9.1), seagrass (9.2), tall seagrass (9.3), the non-bonemealable list (9.4), short grass and ferns (9.5), tall flowers (9.6), worked examples 9 and 15.')
rows(g,'double plant placement (9.1 step 1): the lower state when the clicked y is below the maximum build height and the cell above can be replaced, else null (y below max, above replaceable) (placed)','GC4-DOUBLE-PLACE',2,1,[(1,1),(0,1),(1,0),(0,0)],lambda y,r:(int(y and r),))
def dsp(h,w): return 1,(w if h else -1),3
rows(g,'double plant setPlacedBy (9.1 step 2): the upper half (1) is written above with waterlogged copied from isWaterAt when the block has the property (-1 otherwise), flags 3 (has property, water at pos) (half, waterlogged, flags)','GC4-DOUBLE-SETPLACED',2,3,[(1,1),(1,0),(0,1),(0,0)],dsp)
rows(g,'double plant survival (9.1 step 3): the upper half needs this block below with half lower; the lower half the VegetationBlock rule (half 0 lower 1 upper, below is this block and lower, mayPlaceOn of the below) (survive)','GC4-DOUBLE-SURVIVE',3,1,[(1,1,0),(1,0,1),(0,0,1),(0,0,0),(0,1,0)],lambda h,b,m:(int(b) if h else int(m),))
def dsu(h,d,nb,nh,sv):
    if d in (1,2) and ((h==0)==(d==2)):
        return (1,) if (not nb or nh==h) else (0,)
    if h==0 and d==1 and not sv: return (1,)
    return (0,) if sv else (1,)
dsuc=[(0,2,1,1,1),(0,2,0,0,1),(0,2,1,0,1),(0,2,1,0,0),(0,2,1,1,0),(1,1,1,0,1),(1,1,1,1,1),(1,1,0,0,1),(0,1,1,0,0),(0,1,1,0,1),(1,1,1,0,0),(0,3,1,0,0),(0,3,1,0,1),(1,2,1,1,1)]
rows(g,'double plant shape update (9.1 step 4, example 15): for the partner cell (lower half with UP, upper half with DOWN) air when the neighbour is not this block or has the same half; else the lower half with DOWN gives air when it cannot survive; else the VegetationBlock update (half, direction 1 down 2 up, neighbour is this block, neighbour half, survive) (1 air, 0 unchanged)','GC4-DOUBLE-SU',5,1,dsuc,dsu)
rows(g,'double plant placeAt (9.1 step 5): the lower half then the upper half with waterlogged copied when the block has the property (has property, water at pos) (lower, upper; -1 for none)','GC4-DOUBLE-PLACEAT',2,2,[(1,1),(1,0),(0,1)],lambda h,w:((w,w) if h else (-1,-1)))
def dbk(cr,h,bl,ws):
    if not cr: return 1,0,0,0
    if h==1 and bl: return (2 if ws else 3),35,2001,0
    return 0,0,0,0
dbc=[(0,1,1,0),(0,0,0,0),(1,1,1,1),(1,1,1,0),(1,0,1,1),(1,1,0,0)]
rows(g,'double plant breaking (9.1 step 6, example 15): a player who is not creative drops the resources (1); a creative player breaking the upper half over its lower half sets the lower position to water (2, when the fluid is the water source) or air (3) with flags 35 and level event 2001; the break itself drops nothing (creative, half, below is the lower half, water source) (action, flags, event, drops of the break)','GC4-DOUBLE-BREAK',4,4,dbc,dbk)
rows(g,'double plant offset seed (9.1 step 7): both halves use the lower half\'s y (half, y) (y of the seed)','GC4-DOUBLE-SEED',2,1,[(0,64),(1,65),(1,-3)],lambda h,y:(y if h==0 else y-1,))
rows(g,'seagrass mayPlaceOn (9.2 step 1): the face below is sturdy toward UP and the block is not in cannot_support_seagrass (sturdy, in tag)','GC4-SEAGRASS-PLACEON',2,1,[(1,0),(1,1),(0,0),(0,1)],lambda s,t:(int(s and not t),))
rows(g,'seagrass placement (9.2 step 2): null unless the clicked fluid is in tag water and full (water, full) (placed)','GC4-SEAGRASS-PLACE',2,1,[(1,1),(1,0),(0,1),(0,0)],lambda w,f:(int(w and f),))
rows(g,'seagrass shape update (9.2 step 3): the VegetationBlock update; when the result is not air a water tick is scheduled (survive) (1 air, water tick)','GC4-SEAGRASS-SU',1,2,[(1,),(0,)],lambda s:(0,1) if s else (1,0))
rows(g,'seagrass bone meal (9.2 step 5): valid when the block above is block water (any level); success always; effect tall_seagrass lower and upper, both with flags 2 (above is water) (valid, success, flags)','GC4-SEAGRASS-BONE',1,3,[(1,),(0,)],lambda a:(a,1,2))
def tsv(h,bl,mp,wf): return (int(bl) if h else int(mp and wf),)
rows(g,'tall seagrass survival (9.3): the upper half as 9.1; the lower half the DoublePlantBlock rule and the fluid at pos in tag water and full (half, below is the lower half, mayPlaceOn, water and full) (survive)','GC4-TALLSEA-SURVIVE',4,1,[(1,1,0,0),(1,0,1,1),(0,0,1,1),(0,0,1,0),(0,0,0,1)],tsv)
rows(g,'tall seagrass placement (9.3): the DoublePlantBlock placement and null unless the fluid at clickedPos.above() is in tag water and full (double plant placement ok, fluid above water and full) (placed)','GC4-TALLSEA-PLACE',2,1,[(1,1),(1,0),(0,1)],lambda d,f:(int(d and f),))
NOB=["tall_grass","large_fern","pitcher_plant","tall_seagrass"]+FLOWERS+["wither_rose","open_eyeblossom","closed_eyeblossom","sugar_cane","cactus","cactus_flower","vine","lily_pad","hanging_roots","spore_blossom","mangrove_roots","dead_bush"]
YES=["short_grass","fern","sunflower","lilac","rose_bush","peony","seagrass","bush","red_shrub","firefly_bush","short_dry_grass","tall_dry_grass","sea_pickle","big_dripleaf","small_dripleaf","pale_hanging_moss","pink_petals","wildflowers","stone"]
allk=[(k,1) for k in NOB]+[(k,0) for k in YES]
for i in range(0,len(allk),24):
    keycase(g,'not bonemealable (9.4): these blocks are not bone meal targets (1), the others are (0) (part %d)'%(i//24+1),'GC4-NOT-BONE',allk[i:i+24])
rows(g,'short grass and fern bone meal (9.5, example 9): the grown block is large_fern for fern, else tall_grass; valid when its lower state can survive at pos, the cell above is air and inside the build height; success always; DoublePlantBlock.placeAt with flags 2 (fern, can survive, above air, in height) (valid, success, grown 1 tall_grass 2 large_fern, flags)','GC4-GRASS-BONE',4,4,[(0,1,1,1),(1,1,1,1),(0,0,1,1),(0,1,0,1),(0,1,1,0)],lambda f,s,a,h:(int(s and a and h),1,2 if f else 1,2))
rows(g,'tall flower bone meal (9.6): always valid and successful; the effect is popResource of the block\'s own item (1), nothing grows (0) (valid, success, item popped, grows)','GC4-TALLFLOWER-BONE',0,4,[()],lambda :(1,1,1,0))
W4(g,9)
# ===== 10
g=G4(10,'Small plants','T0599','flowers (10.1), wither rose (10.2), eyeblossoms (10.3), flower beds (10.4), bush (10.5), dry vegetation (10.6), firefly bush (10.7).')
rows(g,'suspicious stew effect entry (10.1): (effect, floor(seconds x 20)) ticks for a duration in seconds','GC4-STEW-TICKS',1,1,[(8.0,),(0.35,),(11.0,),(7.0,),(0.5,),(5.5,)],lambda s:(int(math.floor(s*20+1e-9)),),fl=(1,))
rows(g,'FlowerBlock (10.1): shape column 6 wide 0 to 10, no tick (0), no bone meal (0), no entity effect, getBeeInteractionEffect null (0) (width, y from, y to, ticks, bone meal, bee effect)','GC4-FLOWER10-CONST',0,6,[()],lambda :(6,0,10,0,0,0))
def wh(sv,df,lv,inv): return int(sv and df!=0 and lv and not inv),40,0
whc=[(1,2,1,0),(1,0,1,0),(0,2,1,0),(1,2,0,0),(1,2,1,1),(1,3,1,0)]
rows(g,'wither rose entityInside (10.2): on a server, difficulty not peaceful (0), a LivingEntity not invulnerable to wither damage: the wither effect for 40 ticks, amplifier 0 (server, difficulty, living, invulnerable) (applies, ticks, amplifier)','GC4-WITHER-HIT',4,3,whc,wh)
EYE={1:(1,1,11,16545810),2:(0,2,7,6250335)}
rows(g,'eyeblossom types (10.3): OPEN is open with blindness for 11 seconds and colour 16545810, CLOSED is not open with nausea for 7 seconds and colour 6250335; transform() is the other type (type 1 open 2 closed) (open, effect 1 blindness 2 nausea, seconds, colour, transformed type)','GC4-EYE-TYPE',1,5,[(1,),(2,)],lambda t:EYE[t]+(3-t,))
def ec(a,o):
    w=o if a==2 else a
    return w,int(w!=o)
rows(g,'eyeblossom tryChangingState (10.3 step 1, example 13): want is the environment attribute gameplay/eyeblossom_open (2 for the default of the tri-state, which gives the block\'s own open); nothing changes when want equals the type\'s open (attribute, open) (want, changes)','GC4-EYE-CHANGE',2,2,[(1,0),(0,1),(1,1),(0,0),(2,1),(2,0)],ec)
def ed(dsq,d):
    dist=math.sqrt(dsq); lo=int(dist*5); hi=int(dist*10)
    return lo,hi,lo+d
edc=[(1,0),(1,5),(2,0),(2,7),(3,3),(4,0),(4,10),(9,0),(9,15),(18,4)]
rows(g,'eyeblossom neighbour delay (10.3 step 1, example 13): dist = sqrt(distSqr), delay = nextIntBetweenInclusive((int)(dist x 5), (int)(dist x 10)), that is the low bound plus a draw below the range (distSqr, draw) (low, high, delay)','GC4-EYE-DELAY',2,3,edc,ed)
ebx=[(0,0,0),(3,2,3),(-3,-2,-3),(4,0,0),(0,3,0),(0,-3,0),(0,0,-4),(1,0,0),(0,2,0)]
rows(g,'eyeblossom scan box (10.3 step 1): the cells from pos + (-3, -2, -3) to pos + (3, 2, 3) other than the changed block itself are candidates (dx, dy, dz) (candidate)','GC4-EYE-SCAN',3,1,ebx,lambda x,y,z:(int(abs(x)<=3 and abs(y)<=2 and abs(z)<=3 and (x,y,z)!=(0,0,0)),))
rows(g,'eyeblossom sound (10.3 steps 2, 3): a random tick that changed plays the long switch sound (1), a scheduled tick the short one (2), nothing when unchanged (trigger 1 RT 2 ST, changed) (sound)','GC4-EYE-SOUND',2,1,[(1,1),(2,1),(1,0),(2,0)],lambda t,c:((t if c else 0),))
BEE=["dandelion","open_eyeblossom","poppy","blue_orchid","allium","azure_bluet","red_tulip","orange_tulip","white_tulip","pink_tulip","oxeye_daisy","cornflower","lily_of_the_valley","wither_rose","torchflower","sunflower","lilac","peony","rose_bush","pitcher_plant","flowering_azalea_leaves","flowering_azalea","mangrove_propagule","cherry_leaves","pink_petals","wildflowers","chorus_flower","spore_blossom","cactus_flower"]
assert len(BEE)==29
def bee(k,wl,half): return int(k in BEE and wl==0 and (k!="sunflower" or half==1))
for part,ks in enumerate([[(k,0,0) for k in BEE[:15]],[(k,0,0) for k in BEE[15:]]+[("sunflower",0,1),("sunflower",1,1),("lilac",1,0),("golden_dandelion",0,0),("closed_eyeblossom",0,0),("rose",0,0),("poppy",0,1)]]):
    g.case('bee attractive tag (10.3 step 5): the 29 members of bee_attractive are true when not waterlogged, sunflower only for its upper half; golden_dandelion and closed_eyeblossom are not members (part %d)'%(part+1),[("%d %d"%(wl,hf),'MOVE "minecraft:%s" TO WS-T1\nCALL "GC4-BEE-ATTRACTS" USING WS-T1 WS-I(1) WS-I(2) WS-R(1)'%k,1) for k,wl,hf in ks]," ".join(str(bee(*x)) for x in ks))
def ei(sv,df,bee_,att,pois): return int(sv and df!=0 and bee_ and att and not pois),25,0
eic=[(1,2,1,1,0),(1,0,1,1,0),(0,2,1,1,0),(1,2,0,1,0),(1,2,1,0,0),(1,2,1,1,1)]
rows(g,'eyeblossom entityInside (10.3 step 5): on a server, difficulty not peaceful, a Bee that is attracted (Bee.attractsBees of the state) and not already poisoned gets poison for 25 ticks, amplifier 0 (server, difficulty, bee, attracts, poisoned) (applies, ticks, amplifier)','GC4-EYE-INSIDE',5,3,eic,ei)
def bp_(same,a,pd):
    return (min(4,a+1),-1) if same else (1,{3:4,4:3,5:6,6:5}[pd])
rows(g,'flower bed placement (10.4 step 1): the same block gives flower_amount min(4, amount + 1) and keeps facing (-1); otherwise the default with facing the opposite of the placer\'s horizontal direction (3 north 4 south 5 west 6 east) (same block, amount, placer direction) (amount, facing)','GC4-BED-PLACE',3,2,[(1,1,3),(1,3,3),(1,4,4),(0,1,3),(0,1,4),(0,1,5),(0,1,6)],bp_)
rows(g,'segmentable and pickle canBeReplaced (10.4 step 2, 11.1 step 3): true when not secondary use, the item in hand is this block\'s item and the amount is below 4; otherwise the default (secondary use active, item in hand is this block, amount, default)','GC4-SEG-REPLACE',4,1,[(0,1,1,0),(0,1,3,0),(0,1,4,1),(1,1,2,1),(1,1,2,0),(0,0,2,1),(0,0,2,0)],lambda sec,it,a,d:(1 if (not sec and it and a<4) else d,))
def bb(a): return 1,1,(a+1 if a<4 else -1),2,int(a>=4)
rows(g,'flower bed bone meal (10.4 step 4, example 14): always valid and successful; below 4 the amount increases by 1 (flags 2), at 4 one item is dropped (amount) (valid, success, amount after or -1, flags, item dropped)','GC4-BED-BONE',1,5,[(1,),(2,),(3,),(4,)],bb)
rows(g,'flower bed constants (10.4): default facing NORTH (3), default flower_amount 1, amount 1 to 4, shape height 3','GC4-BED-CONST',0,4,[()],lambda :(3,1,4,3))
rows(g,'bush and red_shrub (10.5): column 16 wide to height 13 (the constructor argument)','GC4-BUSH-SHAPE',1,2,[(13,)],lambda h:(16,h))
DR={1:(12,0,13,0),2:(12,0,10,2),3:(14,0,16,2)}
rows(g,'dry vegetation shapes (10.6): dead_bush column 12 wide to 13; short_dry_grass 12 wide to 10 with offset XYZ (2); tall_dry_grass 14 wide to 16 with offset XYZ (kind 1 dead_bush 2 short 3 tall) (width, y from, y to, offset)','GC4-DRY-SHAPE',1,4,[(1,),(2,),(3,)],lambda k:DR[k])
def db(k,sp):
    if k==1: return 0,0,0,0
    if k==2: return 1,1,1,3
    return int(sp),1,2 if sp else 0,3 if sp else 0
rows(g,'dry vegetation bone meal (10.6): dead_bush is not a target; short_dry_grass is always valid and grows in place into tall_dry_grass (effect 1, flags 3); tall_dry_grass is valid when a neighbour can take short_dry_grass and spreads one copy to it (effect 2, the plant itself stays) (kind, spreadable neighbour) (valid, success, effect, flags)','GC4-DRY-BONE',2,4,[(1,1),(2,0),(3,1),(3,0)],db)
rows(g,'firefly bush bone meal (10.7): valid when a neighbour can take a copy, always successful, the neighbour spreader with flags 3 (type GROWER)','GC4-BUSH-BONE',1,4,[(1,),(0,)],lambda s:(s,1,1,3))
W4(g,10)
# ===== 11
g=G4(11,'Sea pickle and lily pad','T0601','sea pickle (11.1) and lily pad (11.2), worked example 8.')
rows(g,'sea pickle light (11.1): 0 when dead (not waterlogged), else 3 + 3 x pickles (pickles, waterlogged)','GC4-PICKLE-LIGHT',2,1,[(1,1),(2,1),(3,1),(4,1),(4,0),(1,0)],lambda p,w:(3+3*p if w else 0,))
PS={1:(4,6),2:(10,6),3:(12,6),4:(12,7)}
rows(g,'sea pickle shapes (11.1): column 4 wide to 6, 10 wide to 6, 12 wide to 6, 12 wide to 7 for 1 to 4 pickles (pickles) (width, height)','GC4-PICKLE-SHAPE',1,2,[(p,) for p in (1,2,3,4)],lambda p:PS[p])
rows(g,'sea pickle mayPlaceOn (11.1 step 1): the block below has a non-empty collision face toward UP or a sturdy top face (collision face, sturdy) (survives)','GC4-PICKLE-PLACEON',2,1,[(1,0),(0,1),(1,1),(0,0)],lambda c,s:(int(c or s),))
def pp(same,p,ws): return (min(4,p+1),-1) if same else (1,ws)
rows(g,'sea pickle placement (11.1 step 2): the same block gives pickles min(4, pickles + 1), all else kept; otherwise the default with waterlogged set from FluidState.is(Fluids.WATER) (a water source) at the clicked position (same block, pickles, water source) (pickles, waterlogged or -1)','GC4-PICKLE-PLACE',3,2,[(1,1,0),(1,4,1),(0,1,1),(0,1,0)],pp)
rows(g,'sea pickle canBeReplaced (11.1 step 3): below 4 pickles with the matching item and no secondary use','GC4-SEG-REPLACE',4,1,[(0,1,3,0),(0,1,4,0),(1,1,1,1),(0,0,1,0)],lambda sec,it,a,d:(1 if (not sec and it and a<4) else d,))
rows(g,'sea pickle shape update (11.1 step 4): air when it cannot survive; a water tick when waterlogged (survive, waterlogged) (1 air, water tick)','GC4-PICKLE-SU',2,2,[(1,1),(1,0),(0,1),(0,0)],lambda s,w:(int(not s),int(w and s)))
rows(g,'sea pickle bone meal validity (11.1 step 5): valid when the pickle is not dead (waterlogged) and the block below is in coral_blocks; success always (waterlogged, coral below) (valid, success)','GC4-PICKLE-BONE-VALID',2,2,[(1,1),(1,0),(0,1),(0,0)],lambda w,c:(int(w and c),1))
cells=[]
for dx in range(-2,3):
    zs={-2:[0],-1:[-1,0,1],0:[-2,-1,0,1,2],1:[-1,0,1],2:[0]}[dx]
    for dz in zs:
        for dy in (-1,0): cells.append((dx,dz,dy))
assert len(cells)==26
rows(g,'sea pickle scan cells (11.1 step 5): 13 columns, x -2 to 2 with z 0, -1 to 1, -2 to 2, -1 to 1, 0, each at y - 1 then y, x ascending then z ascending (cell number 1 to 26) (dx, dz, dy)','GC4-PICKLE-CELL',1,3,[(i+1,) for i in range(26)],lambda i:cells[i-1])
def pst(isp,d6,w,c,d4):
    if isp: return 0,0,0
    if d6==0 and w and c: return 1,1,d4+1
    return 1,0,0
psc=[(1,0,1,1,0),(0,1,1,1,0),(0,0,0,1,0),(0,0,1,0,0),(0,0,1,1,0),(0,0,1,1,3),(0,5,1,1,2)]
rows(g,'sea pickle one cell (11.1 step 5): the clicked pos is skipped with no draw; otherwise nextInt(6) is drawn and only a 0 over block water with a coral block below draws nextInt(4) and places pickles = draw + 1 (is pos, nextInt(6), water block, coral below, nextInt(4)) (drew nextInt(6), placed, pickles)','GC4-PICKLE-STEP',5,3,psc,pst)
rows(g,'sea pickle patch totals (11.1 step 5, example 8): 26 cells scanned, 25 of them draw nextInt(6) (13 columns of 2 minus pos), the clicked pickle ends with 4 pickles written with flags 2 (cells, draws, pickles, flags)','GC4-PICKLE-CONST',0,4,[()],lambda :(26,25,4,2))
def lp(fb,bb_,own): return (int((fb or bb_) and own),)
lpc=[(1,0,1),(0,1,1),(1,1,1),(0,0,1),(1,0,0),(0,1,0)]
rows(g,'lily pad mayPlaceOn (11.2): the fluid below in fluid tag supports_lily_pad (still water) or the block below in block tag supports_lily_pad (ice, frosted_ice), and the fluid at its own position empty (fluid below, block below, own fluid empty) (ok)','GC4-LILY-PLACE',3,1,lpc,lp)
rows(g,'lily pad entityInside (11.2): on a server an AbstractBoat destroys it with drops (server, boat) (destroy, drops)','GC4-LILY-BOAT',2,2,[(1,1),(0,1),(1,0)],lambda s,b:(int(s and b),int(s and b)))
rows(g,'lily pad shape (11.2): column 14 wide from 0 to 1.5 (height x 10 = 15)','GC4-LILY-SHAPE',0,3,[()],lambda :(14,0,15))
W4(g,11)
# ===== 12
g=G4(12,'Dripleaf','T0603','big dripleaf (12.1), its stem (12.2), placeWithRandomHeight (12.3), small dripleaf (12.4), worked examples 10 and 11.')
TILT={0:(1,-1,11,15),1:(0,10,11,15),2:(1,10,11,13),3:(1,100,0,0)}
rows(g,'tilt table (12.1): causesVibration none true, unstable false, partial true, full true; delay until the next tilt step -1, 10, 10, 100; collision y range 11 to 15 for none and unstable, 11 to 13 partial, empty (0, 0) for full (tilt 0 none 1 unstable 2 partial 3 full) (vibration, delay, collision from, collision to)','GC4-DRIP-TILT',1,4,[(t,) for t in range(4)],lambda t:(TILT[t][0],{0:-1,1:10,2:10,3:100}[t],TILT[t][2],TILT[t][3]))
rows(g,'big dripleaf constants (12.1): NO_TICK -1, MAX_GEN_HEIGHT 5, stem box 6 wide to 13, leaf box 16 wide','GC4-DRIP-CONST',0,4,[()],lambda :(-1,5,6,16))
rows(g,'big dripleaf survival (12.1 step 1, 12.2 step 1): the head needs a dripleaf, a stem or supports_big_dripleaf below; the stem needs a stem or the tag below and a stem or head above (below is dripleaf or stem, below in tag) (survives)','GC4-DRIP-SURVIVE',2,1,[(1,0),(0,1),(0,0),(1,1)],lambda a,b:(int(a or b),))
def dpl(bd,bf,pd,src):
    return (bf if bd else {3:4,4:3,5:6,6:5}[pd]),src
rows(g,'big dripleaf placement (12.1 step 2): facing is the state below\'s facing when it is a dripleaf or stem, else the opposite of the placer\'s horizontal direction; waterlogged is a water source at the clicked position (below is dripleaf or stem, below facing, placer direction, water source) (facing, waterlogged)','GC4-DRIP-PLACE',4,2,[(1,5,3,1),(0,5,3,0),(0,5,4,1),(0,5,5,0),(0,5,6,1)],dpl)
def dsu2(d,sv,wl,nb):
    if d==1 and not sv: return 1,0
    return (2 if (d==2 and nb) else 0),int(wl)
dsc=[(1,0,1,0),(1,1,0,0),(2,1,1,1),(2,1,0,0),(2,1,0,1),(3,1,1,0)]
rows(g,'big dripleaf shape update (12.1 step 3): from DOWN air when it cannot survive; a water tick when waterlogged; from UP with a big_dripleaf neighbour a stem with the same properties (direction 1 down 2 up, survive, waterlogged, neighbour is big_dripleaf) (0 unchanged 1 air 2 stem, water tick)','GC4-DRIP-SU',4,2,dsc,dsu2)
cgc=[(1,1),(1,2),(1,3),(1,0),(0,1),(0,2)]
rows(g,'big dripleaf canGrowInto and canPlaceAt (12.1 step 4): inside the build height and the state is air, block water (any level) or small_dripleaf (in height, kind 1 air 2 water 3 small_dripleaf 0 other) (can grow)','GC4-DRIP-CANGROW',2,1,[(h,k) for h,k in cgc],lambda h,k:(int(h and k in (1,2,3)),))
rows(g,'place (12.1 step 5, 12.2 step 3): setBlockAndUpdate with waterlogged set from a water source of the fluid (flags 3)','GC4-DRIP-WRITE',1,2,[(1,),(0,)],lambda w:(w,3))
rows(g,'big dripleaf bone meal (12.1 step 6): valid when canGrowInto(above); the effect (this block a stem, a new head above) needs canPlaceAt(above) (can grow, can place) (valid, success, effect)','GC4-DRIP-BONE',2,3,[(1,1),(0,0),(1,0)],lambda c,p:(c,1,int(c and p)))
def dti(cl,t,og,y,py,sg):
    if cl: return -1,-1,0
    can=og and y>py+0.6875
    if t==0 and can and not sg: return 1,10,0
    return -1,-1,0
dtic=[(1,0,1,70.0,64,0),(0,0,1,65.0,64,0),(0,0,1,64.6875,64,0),(0,0,1,64.69,64,0),(0,0,0,70.0,64,0),(0,0,1,70.0,64,1),(0,1,1,70.0,64,0),(0,3,1,70.0,64,0)]
rows(g,'big dripleaf entityInside (12.1 step 7.1, example 11): server only; with tilt none, the entity on the ground with y strictly above pos.y + 0.6875 and no neighbour signal sets tilt unstable (1) and schedules a tick in 10, no sound (client, tilt, on ground, entity y, pos y, signal) (tilt after or -1, delay or -1, sound)','GC4-DRIP-INSIDE',6,3,dtic,dti,fl=(4,))
rows(g,'setTilt (12.1 step 7.3): the block is written with flags 2; the game event BLOCK_CHANGE is sent when the new tilt causes vibration (partial or full; none does too) and differs from the old tilt (old, new) (event)','GC4-DRIP-SETTILT',2,1,[(0,1),(1,2),(2,3),(3,0),(0,0),(3,3),(1,1),(2,2)],lambda o,n:(int(n in (0,2,3) and n!=o),))
rows(g,'resetTilt (12.1 step 7.4, 7.7): the tilt becomes none; the tilt-up sound plays when the given state\'s tilt was not none (tilt) (tilt after, sound 1 up)','GC4-DRIP-RESET',1,2,[(0,),(1,),(2,),(3,)],lambda t:(0,int(t!=0)))
def dtk(sg,t):
    if sg: return 0,(2 if t else 0),-1
    if t==1: return 2,1,10
    if t==2: return 3,1,100
    if t==3: return 0,2,-1
    return 0,0,-1
rows(g,'big dripleaf tick (12.1 step 7.6, example 11): with a neighbour signal the tilt resets; otherwise unstable becomes partial (sound down 1, next tick 10), partial becomes full (down, next tick 100), full resets (sound up 2), none does nothing (signal, tilt) (tilt after, sound, delay or -1)','GC4-DRIP-TICK',2,3,[(1,2),(1,0),(0,1),(0,2),(0,3),(0,0)],dtk)
rows(g,'big dripleaf neighbour change (12.1 step 7.7): a redstone signal resets the tilt at once, with the tilt-up sound when it was not none; no signal does nothing (-1) (signal, tilt) (tilt after, sound)','GC4-DRIP-NEIGHBOUR',2,2,[(1,3),(1,0),(0,2)],lambda s,t:(0,int(t!=0)) if s else (-1,0))
rows(g,'big dripleaf projectile hit (12.1 step 7.8): setTiltAndScheduleTick to full with the tilt-down sound: the leaf drops at once and resets 100 ticks later (tilt, sound, delay)','GC4-DRIP-PROJECTILE',0,3,[()],lambda :(3,1,100))
rows(g,'stem survival (12.2 step 1): a stem or supports_big_dripleaf below and a stem or head above (below ok, above ok) (survives)','GC4-STEM-SURVIVE',2,1,[(1,1),(1,0),(0,1),(0,0)],lambda a,b:(int(a and b),))
rows(g,'stem shape update (12.2 step 2): from DOWN or UP a stem that cannot survive schedules a tick (delay 1); a water tick when waterlogged (direction 1 down 2 up 3 other, survive, waterlogged) (tick, water tick)','GC4-STEM-SU',3,2,[(1,0,0),(2,0,1),(3,0,0),(1,1,1),(2,1,0)],lambda d,s,w:(int(d in (1,2) and not s),w))
rows(g,'stem finding the top (12.2 step 4): from pos move UP over stems; the first other cell must be big_dripleaf (stems from pos including pos, the cell above them is a head) (found, offset of that cell from pos)','GC4-STEM-FIND',2,2,[(1,1),(3,1),(2,0)],lambda r,h:(h,r))
rows(g,'stem bone meal (12.2 step 4): valid when the head is found and canPlaceAt(top.above()); success always; the top becomes a stem and a new head is placed above it, whichever stem was clicked (found, can place above the top) (valid, success)','GC4-STEM-BONE',2,2,[(1,1),(1,0),(0,1),(0,0)],lambda f,p:(int(f and p),1))
def hh(raw,free):
    n=2+raw; i=min(n,free); st=max(i-1,0)
    return n,i,st,st
hhc=[(0,5),(3,5),(2,4),(3,2),(1,0),(0,1),(3,1),(2,3),(3,9)]
rows(g,'placeWithRandomHeight (12.3, example 10): n = Mth.nextInt(2, 5); i counts the cells from pos up that canPlaceAt, at most n; stems fill all but the last used cell and one head sits on top; i can be below n and 0 only when pos cannot be replaced (then the head is placed at pos) (nextInt(4) draw, free cells from pos) (n, cells used, stems, head offset)','GC4-DRIP-HEIGHT',2,4,hhc,hh)
rows(g,'small dripleaf mayPlaceOn (12.4 step 1): the supporting state in supports_small_dripleaf (clay, moss_block), or a water source in the lower half\'s own cell together with a block in supports_vegetation (in tag, water source in own cell, in supports_vegetation) (ok)','GC4-SMALL-PLACEON',3,1,[(1,0,0),(0,1,1),(0,1,0),(0,0,1),(0,0,0)],lambda t,w,v:(int(t or (w and v)),))
rows(g,'small dripleaf setPlacedBy (12.4 step 4): on a server only the upper half is placed above, facing from the placed state, waterlogged copied (server) (placed)','GC4-SMALL-PLACED',1,1,[(1,),(0,)],lambda s:(s,))
rows(g,'small dripleaf shape update (12.4 step 5): a water tick when waterlogged, then the DoublePlantBlock update (waterlogged) (water tick)','GC4-SMALL-SU',1,1,[(1,),(0,)],lambda w:(w,))
rows(g,'small dripleaf bone meal (12.4 step 6): always valid and successful; from the lower half the upper cell becomes the legacy fluid block (water when it is water, else air) with flags 18, then placeWithRandomHeight at the lower half; from the upper half the same on the lower half\'s position (half 0 lower 1 upper, fluid above is water) (valid, success, y offset of the acting position, replacement 1 water 0 air, flags)','GC4-SMALL-BONE',2,5,[(0,1),(0,0),(1,1),(1,0)],lambda h,w:(1,1,-h,w,18))
rows(g,'small dripleaf constants (12.4): column 12 wide to 13, maximum vertical offset 0.1 (x 1000)','GC4-SMALL-CONST',0,4,[()],lambda :(12,0,13,100))
W4(g,12)
# ===== 13
g=G4(13,'Hanging and root blocks','T0605','hanging roots (13.1), spore blossom (13.2), pale hanging moss (13.3), mangrove roots (13.4), worked example 12.')
rows(g,'hanging roots survival (13.1 step 1): the state above has a sturdy face toward DOWN (sturdy) (survives)','GC4-ROOTS-SURVIVE',1,1,[(1,),(0,)],lambda s:(s,))
def rsu(d,sv,wl):
    if d==2 and not sv: return 1,0
    return 0,wl
rows(g,'hanging roots shape update (13.1 step 2): from UP air when it cannot survive; a water tick when waterlogged (direction 2 up, survive, waterlogged) (air, water tick)','GC4-ROOTS-SU',3,2,[(2,0,1),(2,1,1),(2,1,0),(3,0,1),(3,1,0)],rsu)
rows(g,'hanging roots placement and constants (13.1): waterlogged is a water source at the clicked position (source) (waterlogged); shape 12 wide from 10 to 16 with offset XZ (1); no bone meal (0)','GC4-ROOTS-PLACE',1,4,[(1,),(0,)],lambda s:(s,12,10,16))
rows(g,'hanging roots constants (13.1): offset type XZ (1), bone meal on the block itself (0)','GC4-ROOTS-CONST',0,2,[()],lambda :(1,0))
rows(g,'spore blossom survival (13.2): canSupportCenter above toward DOWN and the cell is not water (center support above, isWaterAt) (survives)','GC4-SPORE-SURVIVE',2,1,[(1,0),(1,1),(0,0),(0,1)],lambda c,w:(int(c and not w),))
rows(g,'spore blossom shape update (13.2): from UP air when it cannot survive, else the default (direction 2 up, survive) (air)','GC4-SPORE-SU',2,1,[(2,0),(2,1),(3,0),(3,1)],lambda d,s:(int(d==2 and not s),))
rows(g,'spore blossom shape (13.2): column 12 wide from 13 to 16','GC4-SPORE-CONST',0,3,[()],lambda :(12,13,16))
rows(g,'pale hanging moss constants (13.3): tip default true (1), base shape 14 wide 0 to 16, tip shape 14 wide 2 to 16 (default tip, base y from, tip y from)','GC4-MOSS-CONST',0,3,[()],lambda :(1,0,2))
rows(g,'pale hanging moss canStayAtPosition (13.3 step 1): the block above can be attached to by its bottom face, or is pale_hanging_moss (attachable, above is moss) (stays)','GC4-MOSS-STAY',2,1,[(1,0),(0,1),(0,0),(1,1)],lambda a,m:(int(a or m),))
rows(g,'pale hanging moss shape update (13.3 step 2, example 12): a block tick when it cannot stay (delay 1); the state takes tip = not (the state below is pale_hanging_moss) for every direction (stays, below is moss) (tick, tip)','GC4-MOSS-SU',2,2,[(1,0),(1,1),(0,0),(0,1)],lambda s,b:(int(not s),int(not b)))
rows(g,'pale hanging moss getTip (13.3 step 3): from pos move DOWN over moss; the tip is the last moss cell (moss cells from pos downward including pos) (offset of the tip, negative)','GC4-MOSS-TIP',1,1,[(1,),(3,),(5,)],lambda n:(-(n-1),))
rows(g,'pale hanging moss bone meal (13.3 step 4, example 12): valid when the cell below the tip is air and inside the build height; success always; setBlockAndUpdate (flags 3) of the cell below the tip with tip true, the old tip losing its tip by the shape update (air below, in height) (valid, success, tip written, flags)','GC4-MOSS-BONE',2,4,[(1,1),(1,0),(0,1)],lambda a,h:(int(a and h),1,int(a and h),3))
rows(g,'mangrove roots (13.4): placement waterlogged is a water source at the clicked position; the shape update schedules a water tick when waterlogged; the fluid state is the water source when waterlogged; face culling is skipped when the neighbour is mangrove_roots and the direction\'s axis is Y (waterlogged, source at clicked position, neighbour is roots, axis is Y) (placement waterlogged, water tick, water source, skip rendering)','GC4-MROOTS-RULES',4,4,[(1,1,0,0),(0,0,1,1),(1,0,1,0),(0,1,0,1),(0,0,0,0)],lambda w,s,n,a:(s,w,w,int(n and a)))
W4(g,13)
# ===== 14
g=G4(14,'The rules in one table each','T0607','can-survive and removal path (14.1), random ticks (14.2), bone meal (14.3).')
SU=["bush","red_shrub"]+FLOWERS+["open_eyeblossom","closed_eyeblossom","firefly_bush","short_grass","fern","seagrass","cactus_flower","wither_rose","dead_bush","short_dry_grass","tall_dry_grass","lily_pad","sea_pickle","tall_grass","large_fern","pitcher_plant","tall_seagrass","sunflower","lilac","rose_bush","peony","small_dripleaf","pink_petals","wildflowers","bamboo_sapling","vine","big_dripleaf","hanging_roots","spore_blossom"]
TK=["sugar_cane","cactus","bamboo","chorus_plant","chorus_flower","kelp","kelp_plant","weeping_vines","weeping_vines_plant","twisting_vines","twisting_vines_plant","cave_vines","cave_vines_plant","big_dripleaf_stem","pale_hanging_moss"]
rm=[(k,1) for k in SU]+[(k,2) for k in TK]+[("mangrove_roots",0),("muddy_mangrove_roots",0),("stone",0)]
for i in range(0,len(rm),24): keycase(g,'removal path (14.1): 1 the shape update gives air, 2 a tick (delay 1) destroys, 0 none (part %d)'%(i//24+1),'GC4-REMOVAL',rm[i:i+24])
GT={1:["bush","red_shrub","open_eyeblossom","closed_eyeblossom","firefly_bush","short_grass","fern","tall_grass","large_fern","pitcher_plant","sunflower","lilac","rose_bush","peony","pink_petals","wildflowers"]+FLOWERS,14:["wither_rose"],12:["dead_bush","short_dry_grass","tall_dry_grass"],9:["bamboo","bamboo_sapling"],17:["big_dripleaf"],8:["cactus_flower"]}
gt=[(k,t) for t,ks in GT.items() for k in ks]+[("sugar_cane",0),("sea_pickle",0),("seagrass",0),("kelp",0),("stone",0)]
for i in range(0,len(gt),24): keycase(g,'ground test tag of canSurvive (14.1): the tag of the block below that decides it (1 supports_vegetation, 14 supports_wither_rose, 12 supports_dry_vegetation, 9 supports_bamboo, 17 supports_big_dripleaf, 8 support_override_cactus_flower), 0 when the rule is something else (part %d)'%(i//24+1),'GC4-SURVIVE-TAG',gt[i:i+24])
RTT={"kelp":(1,3),"weeping_vines":(1,3),"twisting_vines":(1,3),"cave_vines":(2,3),"sugar_cane":(0,4),"cactus":(1,4),"bamboo":(2,1),"bamboo_sapling":(1,0),"vine":(2,5),"chorus_flower":(3,2),"open_eyeblossom":(1,0),"closed_eyeblossom":(1,0)}
rt=[(k,"%d/%d"%v) for k,v in RTT.items()]+[("kelp_plant","0/0"),("stone","0/0")]
keycase(g,'random tick table (14.2): the number of draws in the table row and the gate (3 age < 25, 4 the cell above is air, 1 stage == 0, 2 age < 5 and above air and in height, 5 the game rule spread_vines, 0 none)','GC4-RT-TABLE',rt,2)
BT={"kelp":1,"weeping_vines":1,"twisting_vines":1,"kelp_plant":2,"weeping_vines_plant":2,"twisting_vines_plant":2,"cave_vines":3,"cave_vines_plant":3,"bamboo":4,"bamboo_sapling":5,"seagrass":6,"short_grass":7,"fern":7,"sunflower":8,"lilac":8,"rose_bush":8,"peony":8,"pink_petals":9,"wildflowers":9,"bush":10,"red_shrub":10,"firefly_bush":10,"short_dry_grass":11,"tall_dry_grass":12,"sea_pickle":13,"big_dripleaf":14,"big_dripleaf_stem":15,"small_dripleaf":16,"pale_hanging_moss":17}
NT=["vine","cactus","sugar_cane","cactus_flower","chorus_plant","chorus_flower","lily_pad","hanging_roots","spore_blossom","mangrove_roots","dead_bush"]+FLOWERS+["wither_rose","open_eyeblossom","closed_eyeblossom","tall_seagrass","tall_grass","large_fern","pitcher_plant"]
bt=[(k,"1/%d"%v) for k,v in BT.items()]+[(k,"0/0") for k in NT]
for i in range(0,len(bt),20): keycase(g,'bone meal table (14.3): whether the block is a target and its effect (1 heads grow, 2 bodies run the head, 3 berries, 4 bamboo, 5 sapling, 6 tall seagrass, 7 tall grass or large fern, 8 drops the item, 9 flower amount, 10 neighbour spread, 11 short dry grass grows, 12 tall dry grass spreads, 13 pickle patch, 14 and 15 dripleaf stalk, 16 small dripleaf column, 17 more moss) (part %d)'%(i//20+1),'GC4-BONE-TARGET',bt[i:i+20],2)
rows(g,'bone meal success (14.3): isBonemealSuccess is true for every row of this part','GC4-BONE-SUCCESS',0,1,[()],lambda :(1,))
W4(g,14)
# ===== 15
g=G4(15,'Client-side behaviour that does not change state','T0609','the animateTick rules of 15: firefly bush, spore blossom, wither rose, pale hanging moss, eyeblossom, dry grass and dead bush sounds.')
rows(g,'day timeline attribute (10.3 step 4, 15): gameplay/eyeblossom_open and audio/firefly_bush_sounds are true from 12600 to 23401 ticks of the 24000-tick day (day tick) (value)','GC4-DAY-ATTR',1,1,[(0,),(12599,),(12600,),(20000,),(23400,),(23999,)],lambda t:(int(12600<=t<23401),))
def ff(d30,at,ho,br,dp,d1,d2,d3):
    snd=int(d30==0 and at and ho)
    prt=int(br<=13 and dp<=0.7)
    return snd,prt,(m(d1*10-5) if prt else 0),(m(d2*5) if prt else 0),(m(d3*10-5) if prt else 0)
ffc=[(0,1,1,13,0.7,0.5,0.5,0.5),(1,1,1,14,0.7,0.5,0.5,0.5),(0,0,1,13,0.71,0.5,0.5,0.5),(0,1,0,10,0.0,0.25,0.5,0.75),(5,1,1,13,0.2,0.0,1.0,0.125),(0,1,1,15,0.2,0.5,0.5,0.5)]
rows(g,'firefly bush (15): with nextInt(30) == 0, the attribute true and the position at or above the surface the local sound FIREFLY_BUSH_IDLE; then at local brightness <= 13 and nextDouble <= 0.7 the firefly particle at (x + d x 10 - 5, y + d x 5, z + d x 10 - 5), draw order x, y, z (nextInt(30), attribute, at or above the surface, brightness, the nextDouble, three draws) (sound, particle, x, y, z offsets x 1000)','GC4-FIREFLY',8,5,ffc,ff,fl=(5,6,7,8))
rows(g,'spore blossom drip (15): the particle falling_spore_blossom at (x + nextDouble, y + 0.7, z + nextDouble) (two draws) (x, y, z offsets x 1000)','GC4-SPORE-DRIP',2,3,[(0.5,0.25),(0.0,0.999)],lambda a,b:(m(a),700,m(b)),fl=(1,2))
def sa(rx,ry,rz,full,d1,d2,d3):
    dx=-10+rx; dy=-ry; dz=-10+rz
    if full: return 0,dx,dy,dz,0,0,0
    return 1,dx,dy,dz,m(d1),m(d2),m(d3)
sac=[(0,0,0,0,0.5,0.5,0.5),(20,9,20,0,0.25,0.75,0.125),(10,5,10,1,0.5,0.5,0.5),(3,2,17,0,0.0,0.0,0.0)]
rows(g,'spore blossom air particles (15): 14 attempts; p = (x + Mth.nextInt(-10, 10), y - nextInt(10), z + Mth.nextInt(-10, 10)); when the state at p has no full-block collision shape the particle spore_blossom_air at p plus a nextDouble each (the nextInt(21) draw for x, nextInt(10), the draw for z, p has a full collision shape, three draws) (particle, dx, dy, dz, offsets x 1000)','GC4-SPORE-AIR',7,7,sac,sa,fl=(5,6,7))
rows(g,'spore blossom constants (15): 14 attempts a tick','GC4-SPORE-ATTEMPTS',0,1,[()],lambda :(14,))
def wsm(b,cx,cz,d1,d2,d3):
    if not b: return 0,0,0,0
    return 1,m(cx+d1/5),m(0.5-d2),m(cz+d3/5)
wsc=[(1,0.5,0.5,0.5,0.25,0.5),(0,0.5,0.5,0.5,0.25,0.5),(1,0.25,0.75,1.0,0.0,0.0)]
rows(g,'wither rose smoke (15): three iterations, each when nextBoolean(): the particle smoke at (x + centre x + nextDouble / 5, y + 0.5 - nextDouble, z + centre z + nextDouble / 5) (nextBoolean, centre x, centre z, three draws) (particle, x, y, z offsets x 1000)','GC4-WITHER-SMOKE',6,4,wsc,wsm,fl=(2,3,4,5,6))
rows(g,'wither rose smoke iterations (15): three','GC4-WITHER-ITER',0,1,[()],lambda :(3,))
rows(g,'pale hanging moss ambient sound (15): nextInt(500) == 0 and the block above in pale_oak_logs or pale_oak_leaves (draw, above in logs, above is leaves) (sound)','GC4-MOSS-IDLE',3,1,[(0,1,0),(0,0,1),(0,0,0),(1,1,0),(499,0,1)],lambda d,l,v:(int(d==0 and (l or v)),))
rows(g,'open eyeblossom ambient sound (15): nextInt(700) == 0 and the block below pale_moss_block; only the open type plays it (draw, below is pale_moss_block, open) (sound)','GC4-EYE-IDLE',3,1,[(0,1,1),(0,1,0),(0,0,1),(5,1,1)],lambda d,b,o:(int(d==0 and b and o),))
def drys(d,t1,t2): return int(d==0 and t1 and t2),int(d==0 and t1 and t2)
rows(g,'dry grass ambient sound (15): one nextInt(200) draw; when 0 and the state below and the state two below are both in the tag triggers_ambient_desert_dry_vegetation_block_sounds: DRY_GRASS (source AMBIENT) through playPlayerSound, the player\'s own position (draw, below in tag, two below in tag) (sound, player sound)','GC4-DRY-SOUND',3,2,[(0,1,1),(0,1,0),(0,0,1),(7,1,1)],drys)
def dbs(d130,red,d3,t1,t2):
    if d130!=0: return 0,1
    dr=1
    if red:
        dr=2
        if d3!=0: return 0,2
    return int(t1 and t2),dr
dbc=[(5,0,0,1,1),(0,0,0,1,1),(0,0,0,1,0),(0,1,0,1,1),(0,1,2,1,1),(0,1,0,0,1),(0,1,0,1,0),(129,1,0,1,1)]
rows(g,'dead bush ambient sound (15): nextInt(130) must be 0; over red_sand or terracotta a second nextInt(3) must also be 0 (1/390 there); then with the two-block tag check true the local sound DEAD_BUSH_IDLE (nextInt(130), below is red_sand or terracotta, nextInt(3), below in tag, two below in tag) (sound, draws made)','GC4-DEAD-BUSH',5,2,dbc,dbs)
W4(g,15)
