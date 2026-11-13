import sys,math
from decimal import Decimal as Dc
sys.path.insert(0,'core/tests/gen')
from gen30c import *
class SuiteN(Suite):
    def gen(self,n,subj,tasks,desc,extra=''):
        key=str(n)
        g=Gen('TEST-REDSTONE-30-7-%s'%key.upper(),'30-7§%s'%key,subj,'Test of 30 part 7 section %s, %s (core/src/redstone-30-7.cob; %s): %s'%(key,subj,tasks,desc),extra)
        g.nn=key
        return g
    def write(self,g):
        if not self.only or g.nn in self.only:
            p=OUT+'/test_redstone_30_7_%s.cob'%g.nn
            g.write(p)
            t=open(p).read().replace('PIC -(9)9.','PIC -(10)9.')
            open(p,'w').write(t)
SU=SuiteN(7,'30-7','RS3-','redstone-30-7.cob',sys.argv[1:])
def chunks(rows,model,limit=190):
    out=[];cur=[];ln=0
    for r in rows:
        e=len(show(model(*r)))+1
        if cur and ln+e>limit: out.append(cur);cur=[];ln=0
        cur.append(r);ln+=e
    if cur: out.append(cur)
    return out
_T=T
def T(g,text,call,nout,rows,model):
    cs=chunks(rows,model)
    for k,part in enumerate(cs): _T(g,text+('' if len(cs)==1 else ' (part %d)'%(k+1)),call,nout,part,model)
_TN=TN
def TN(g,text,call,nout,rows,model):
    cs=chunks([r for r in rows],lambda *r:model(*r))
    for k,part in enumerate(cs): _TN(g,text+('' if len(cs)==1 else ' (part %d)'%(k+1)),call,nout,part,model)
def TX(g,text,call,rows,model,limit=180):
    cs=[];cur=[];ln=0
    for r in rows:
        a,b=model(*r); e=len(a)+len(b)+2
        if cur and ln+e>limit: cs.append(cur);cur=[];ln=0
        cur.append(r);ln+=e
    cs.append(cur)
    for k,part in enumerate(cs):
        cc=[];exp=[]
        for r in part:
            cc.append((S(*[x for x in r if not isinstance(x,str)]) or "0",'MOVE SPACES TO WS-T1\nMOVE SPACES TO WS-T2\n'+''.join('MOVE "%s" TO WS-NM\n'%x for x in r if isinstance(x,str))+call,'TEXT'))
            a,b=model(*r); exp.append('%s|%s'%(a,b))
        g.case(text+('' if len(cs)==1 else ' (part %d)'%(k+1)),cc," ".join(exp))
D,U,N,S_,W,E=0,1,2,3,4,5
SETS=['iron','copper','gold','stone','polished_blackstone','oak','spruce','birch','acacia','cherry','jungle','dark_oak','pale_oak','poplar','crimson','warped','mangrove','bamboo']
PLAIN=['oak','spruce','birch','acacia','jungle','dark_oak','pale_oak','poplar','mangrove']
WOODS=['oak','spruce','birch','acacia','cherry','jungle','dark_oak','pale_oak','poplar','crimson','warped','mangrove','bamboo']
def sidx(n): return SETS.index(n)+1
def widx(n): return WOODS.index(n)+1
# ===== 1 Shared conventions
g=SU.gen(1,'Shared conventions','T0798','the signal query, the sound call, the game events, the flags, server only and the orientation.',NAME+' 01 WS-FL FLOAT-LONG.\n')
T(g,'signal query (1): hasNeighborSignal returns at the first hit of down, up, north, south, west, east (result, index)','CALL "RS1-HAS-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,[(0,0,0,0,0,0),(0,0,0,0,7,0),(3,0,0,0,0,9),(0,15,0,0,0,0)],lambda *v:next(((1,i+1) for i,x in enumerate(v) if x>0),(0,0)))
T(g,'sound parameters (1): doors, trapdoors and gates use volume 1.0 and a random pitch from 0.9 (kind 1), the copper bulb the four-argument form with volume 1.0 and pitch 1.0 (kind 2); millionths: volume, pitch base, pitch range','CALL "RS3-SOUND-BASE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(1,),(2,)],lambda k:(1000000,900000,100000) if k==1 else (1000000,1000000,0))
def pitch(r): return int((Dc(r)*Dc('0.1')+Dc('0.9'))*1000000+Dc('0.5'))
g.case('pitch (1): nextFloat() * 0.1 + 0.9, from 0.9 to 1.0 (millionths)',[(r,'CALL "RS3-DOOR-PITCH" USING WS-FX(1) WS-R(1)',1) for r in ('0.0','0.5','0.999','0.25','0.123456')]," ".join(str(pitch(r)) for r in ('0.0','0.5','0.999','0.25','0.123456')))
T(g,'sound position (1): the block centre (x + 0.5, y + 0.5, z + 0.5) in thousandths of a block above the cell origin; the excluded entity is the acting player, null for redstone, explosions and mobs (actor present; x y z, excluded)','CALL "RS3-SOUND-POSITION" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,),(1,)],lambda a:(500,500,500,a))
T(g,'game events (1): opening emits BLOCK_OPEN (1), closing BLOCK_CLOSE (2); TNT priming PRIME_FUSE (3); the dispenser TNT item ENTITY_PLACE (4) (open flag; event)','CALL "RS3-GAME-EVENT" USING WS-I(1) WS-R(1)',1,[(1,),(0,)],lambda o:(1 if o else 2,))
FLG={1:10,2:2,3:2,4:3,5:3,6:3,7:11}
T(g,'flags used (1): hand toggles of doors and gates 10, redstone writes of doors, trapdoors, gates and the lamp 2, the trapdoor hand toggle 2, bulb writes 3, gate explosion 3, TNT removal 3, TNT hand write 11 (use 1 to 7)','CALL "RS3-WRITE-FLAGS" USING WS-I(1) WS-R(1)',1,[(k,) for k in range(0,9)],lambda k:(FLG.get(k,0),))
def sonly(b,s): return (1 if b==5 else s,)
T(g,'server only (1): the trapdoor (1), gate (2), lamp (3) and bulb (4) act on a server level only; the door (5) has no client test (block, server level; acts)','CALL "RS3-SERVER-ONLY" USING WS-I(1) WS-I(2) WS-R(1)',1,[(b,s) for b in (1,2,3,4,5) for s in (0,1)],sonly)
T(g,'orientation (1): none of the blocks of this document reads the orientation parameter (block 1 to 8)','CALL "RS3-READS-ORIENTATION" USING WS-I(1) WS-R(1)',1,[(b,) for b in range(1,9)],lambda b:(0,))
SU.write(g)
# ===== 2 BlockSetType and WoodType
g=SU.gen(2,'`BlockSetType` and `WoodType`','T0800','the 18 set types with their flags, sounds and click events, the 13 wood types and the use counts.',NAME)
TN(g,'set type order (V3): iron, copper, gold, stone, polished_blackstone, oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, poplar, crimson, warped, mangrove, bamboo (index 1 to 18, 0 unknown)','CALL "RS3-SETTYPE-INDEX" USING WS-NM WS-R(1)',1,[(n,) for n in SETS]+[('gold_block',)],lambda n:(sidx(n),) if n in SETS else (0,))
def flags(n):
    if n=='iron': return (0,0,0,0)
    if n=='copper': return (1,1,0,0)
    if n=='gold': return (0,1,0,0)
    if n in ('stone','polished_blackstone'): return (1,1,0,1)
    return (1,1,1,0)
T(g,'flags (2): canOpenByHand, canOpenByWindCharge, canButtonBeActivatedByArrows and the plate sensitivity (0 EVERYTHING, 1 MOBS) per set type: iron none, copper hand and wind, gold wind only, stone and polished blackstone hand and wind with MOBS, every wood all three','CALL "RS3-SETTYPE-FLAGS" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(i,) for i in range(0,20)],lambda i:flags(SETS[i-1]) if 1<=i<=18 else (0,0,0,0))
def stype(n):
    if n=='iron': return 1
    if n=='copper': return 2
    if n=='gold': return 3
    if n in ('stone','polished_blackstone'): return 4
    if n=='cherry': return 6
    if n in ('crimson','warped'): return 7
    if n=='bamboo': return 8
    return 5
def fam(n):
    if n in ('iron','gold','stone','polished_blackstone'): return 1
    if n=='copper': return 2
    if n=='cherry': return 4
    if n in ('crimson','warped'): return 5
    if n=='bamboo': return 6
    return 3
def plate(n):
    if n in ('iron','copper','gold'): return 1
    if n in ('stone','polished_blackstone'): return 2
    if n=='cherry': return 3
    if n in ('crimson','warped'): return 4
    if n=='bamboo': return 5
    return 6
def button(n):
    return 2 if plate(n)<=2 else plate(n)
T(g,'sound families (2): block SoundType (1 IRON 2 COPPER 3 METAL 4 STONE 5 WOOD 6 CHERRY_WOOD 7 NETHER_WOOD 8 BAMBOO_WOOD), door and trapdoor family (1 iron, 2 copper, 3 wooden, 4 cherry wood, 5 nether wood, 6 bamboo wood), plate click family (1 metal, 2 stone, 3 cherry, 4 nether, 5 bamboo, 6 wooden default), button click family (2 stone button) per set type','CALL "RS3-SETTYPE-SOUNDS" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(i,) for i in range(0,20)],lambda i:(stype(SETS[i-1]),fam(SETS[i-1]),plate(SETS[i-1]),button(SETS[i-1])) if 1<=i<=18 else (0,0,0,0))
FAMN={1:'iron',2:'copper',3:'wooden',4:'cherry_wood',5:'nether_wood',6:'bamboo_wood'}
def sname(i,k,w):
    if not 1<=i<=18: return ('','')
    f=FAMN[fam(SETS[i-1])]
    base=f+('_door' if k==1 else '_trapdoor')
    if f=='iron': base='iron_door' if k==1 else 'iron_trapdoor'
    return ('block.%s.%s'%(base,'close' if w==1 else 'open'),'')
TX(g,'door and trapdoor sound events (2 table): block.<family>_door or _trapdoor .close and .open per set type (iron, gold, stone and polished_blackstone share block.iron_door.* and block.iron_trapdoor.*)','CALL "RS3-SETTYPE-SOUND-NAME" USING WS-I(1) WS-I(2) WS-I(3) WS-T1',[(i,k,w) for i in (1,2,3,4,5,6,10,15,16,18) for k in (1,2) for w in (1,2)]+[(19,1,1)],sname)
T(g,'single-argument constructor (2): oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar and mangrove use the defaults (the flags true, EVERYTHING, WOOD)','CALL "RS3-SETTYPE-SINGLE" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(1,19)],lambda i:(int(SETS[i-1] in PLAIN),))
USES={'gold':1,'polished_blackstone':1,'iron':3,'stone':3,'copper':4}
T(g,'use counts of the set-type fields in the Blocks initializer (2): GOLD 1, POLISHED_BLACKSTONE 1, IRON 3, STONE 3, COPPER 4, each of the 13 woods 4; no door, trapdoor or gate uses gold, stone or polished_blackstone (index; uses, used by doors, trapdoors or gates)','CALL "RS3-SETTYPE-USES" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(1,19)],lambda i:(USES.get(SETS[i-1],4),int(SETS[i-1] not in ('gold','stone','polished_blackstone'))))
TN(g,'wood type order (2): oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, poplar, crimson, warped, mangrove, bamboo (poplar included; 13 entries)','CALL "RS3-WOOD-INDEX" USING WS-NM WS-R(1)',1,[(n,) for n in WOODS]+[('iron',)],lambda n:(widx(n),) if n in WOODS else (0,))
def wsound(i):
    n=WOODS[i-1]
    if n=='cherry': return (6,2,1,sidx(n))
    if n in ('crimson','warped'): return (7,3,2,sidx(n))
    if n=='bamboo': return (8,4,3,sidx(n))
    return (5,1,0,sidx(n))
T(g,'wood type sounds (2): SoundType (WOOD 5, CHERRY_WOOD 6, NETHER_WOOD 7, BAMBOO_WOOD 8), hanging sign type (1 HANGING_SIGN, 2 CHERRY, 3 NETHER, 4 BAMBOO), gate family (0 plain, 1 cherry, 2 nether, 3 bamboo) and the set type of the same name','CALL "RS3-WOOD-SOUNDS" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(i,) for i in range(1,14)]+[(0,),(14,)],lambda i:wsound(i) if 1<=i<=13 else (0,0,0,0))
GF={0:'block.fence_gate',1:'block.cherry_wood_fence_gate',2:'block.nether_wood_fence_gate',3:'block.bamboo_wood_fence_gate'}
def gname(i,w):
    if not 1<=i<=13: return ('','')
    return (GF[wsound(i)[2]]+('.close' if w==1 else '.open'),'')
TX(g,'gate sound events (2): block.fence_gate.close and .open, with cherry_wood, nether_wood and bamboo_wood variants for cherry, crimson and warped, and bamboo','CALL "RS3-WOOD-GATE-NAME" USING WS-I(1) WS-I(2) WS-T1',[(i,w) for i in (1,5,9,10,11,12,13) for w in (1,2)]+[(0,1)],gname)
def btypes(n):
    fam_=0
    base=n
    if n.endswith('_trapdoor'): fam_=2; base=n[:-9]
    elif n.endswith('_fence_gate'): fam_=3; base=n[:-11]
    elif n.endswith('_door'): fam_=1; base=n[:-5]
    else: return (0,0)
    if fam_ in (1,2):
        if base.startswith('waxed_'): base=base[6:]
        for p in ('exposed_','weathered_','oxidized_'):
            if base.startswith(p): base=base[len(p):]; break
        if base=='copper': return (fam_,sidx('copper'))
        return (fam_,sidx(base)) if base in SETS else (fam_,0)
    return (fam_,widx(base)) if base in WOODS else (fam_,0)
BN=[w+'_door' for w in WOODS]+['iron_door']+[p+'copper_door' for p in ('','exposed_','weathered_','oxidized_','waxed_','waxed_exposed_','waxed_weathered_','waxed_oxidized_')]
BN+=[w+'_trapdoor' for w in WOODS]+['iron_trapdoor','copper_trapdoor','waxed_oxidized_copper_trapdoor']+[w+'_fence_gate' for w in WOODS]+['stone','oak_planks','unknown_door','nothing_trapdoor','nothing_fence_gate']
TN(g,'set type of each block (2): doors and trapdoors take the set type of the wood in their name (iron, and copper for every weathering and waxed copper block), gates the wood type of their name (family 1 door, 2 trapdoor, 3 gate; index; the assignment by name is partly inferred in the document, Open question 3)','CALL "RS3-BLOCK-TYPES" USING WS-NM WS-R(1) WS-R(2)',2,[(n,) for n in BN],btypes)
SU.write(g)
# ===== 2a Block rows
g=SU.gen('2a','Block rows and delays of this part','T0802','ids, state counts, copper ranges, family counts and the delay column.',NAME)
IDS={}
def add(n,i,s): IDS[n]=(i,s)
add('oak_door',265,64);add('iron_door',308,64)
for k,w in enumerate(['spruce','birch','jungle','acacia','cherry','dark_oak','pale_oak','mangrove','poplar','bamboo']): add(w+'_door',702+k,64)
add('crimson_door',989,64);add('warped_door',990,64)
for k,w in enumerate(['oak','spruce','birch','jungle','acacia','cherry','dark_oak','pale_oak','mangrove','poplar','bamboo']): add(w+'_trapdoor',365+k,64)
add('iron_trapdoor',580,64);add('crimson_trapdoor',981,64);add('warped_trapdoor',982,64)
add('oak_fence_gate',419,32)
for k,w in enumerate(['spruce','birch','jungle','acacia','cherry','dark_oak','pale_oak','mangrove','poplar','bamboo']): add(w+'_fence_gate',682+k,32)
add('crimson_fence_gate',983,32);add('warped_fence_gate',984,32);add('redstone_lamp',445,2);add('tnt',220,2)
TN(g,'block ids and state counts (2a): the doors 265, 308, 702 to 711, 989, 990 (64 states), trapdoors 365 to 375, 580, 981, 982 (64), fence gates 419, 682 to 691, 983, 984 (32), redstone_lamp 445 (2), tnt 220 (2); 0 for a name not in the table','CALL "RS3-BLOCK-ID" USING WS-NM WS-R(1) WS-R(2)',2,[(n,) for n in IDS]+[('copper_door',),('copper_bulb',),('stone',)],lambda n:IDS.get(n,(0,0)))
CR={1:(1166,1173,64),2:(1174,1181,64),3:(1190,1197,4)}
T(g,'copper ranges (2a): copper doors 1166 to 1173 and trapdoors 1174 to 1181 (64 states each), copper bulbs 1190 to 1197 (4 states); the order inside a range (weathering before waxed) is 29b-5 (family 1 door, 2 trapdoor, 3 bulb; first id, last id, states)','CALL "RS3-COPPER-RANGE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(f,) for f in (1,2,3,4)],lambda f:CR.get(f,(0,0,0)))
CNT={1:22,2:22,3:13,4:1,5:8,6:1}
T(g,'counts (2a): doors 22 (13 wood, 1 iron, 8 copper), trapdoors 22, fence gates 13, lamp 1, bulbs 8, TNT 1 (family 1 door, 2 trapdoor, 3 gate, 4 lamp, 5 bulb, 6 TNT)','CALL "RS3-FAMILY-COUNT" USING WS-I(1) WS-R(1)',1,[(f,) for f in range(1,7)],lambda f:(CNT[f],))
DL={1:(-1,0,0),2:(-1,0,1),3:(-1,0,0),4:(4,0,0),5:(-1,0,0),6:(-1,0,0)}
T(g,'delay column (2a): doors, gates, bulbs and TNT none (-1); trapdoors none except the water fluid tick when waterlogged; the lamp turn-off 4 ticks at NORMAL priority (0), turn-on immediate (family; delay, priority, water tick)','CALL "RS3-DELAY-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(f,) for f in range(1,7)],lambda f:DL[f])
T(g,'state counts by family (V1): door 64 (4 x 2 x 2 x 2 x 2), trapdoor 64, fence gate 32 (4 x 2 x 2 x 2), lamp 2, bulb 4, TNT 2','CALL "RS3-FAMILY-STATES" USING WS-I(1) WS-R(1)',1,[(f,) for f in range(1,7)],lambda f:({1:64,2:64,3:32,4:2,5:4,6:2}[f],))
SU.write(g)
# ===== 3 DoorBlock
g=SU.gen(3,'`DoorBlock`','T0804','state, rotate and mirror, shape, placement, the hinge rule, power, the pairing of halves, hand and explosion use.',NAME)
T(g,'default state (3.1): facing north, half lower, hinge left, open false, powered false (facing data value, half 0 upper 1 lower, hinge 0 left 1 right, open, powered)','CALL "RS3-DOOR-DEFAULT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(N,1,0,0,0))
def cwd(d): return {N:E,E:S_,S_:W,W:N}[d]
T(g,'rotate (3.1): rotate turns facing (0 none, 1 clockwise 90, 2 180, 3 counter-clockwise 90)','CALL "RS3-DOOR-ROTATE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(f,r) for f in (N,E,S_,W) for r in range(4)],lambda f,r:(f if r==0 else cwd(f) if r==1 else cwd(cwd(f)) if r==2 else cwd(cwd(cwd(f))),))
MI={N:S_,S_:N,E:E,W:W}; MF={E:W,W:E,N:N,S_:S_}
def dmir(f,h,m):
    if m==0: return (f,h)
    return ((MI if m==1 else MF)[f],1-h)
T(g,'mirror (3.1): a mirror other than none turns facing by the mirror (left-right swaps north and south, front-back east and west) and then cycles hinge (facing, hinge, mirror)','CALL "RS3-DOOR-MIRROR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(f,h,m) for m in (0,1,2) for f in (N,E,S_,W) for h in (0,1)],dmir)
T(g,'seed (3.1): both halves share the seed of the lower half y (half 0 upper 1 lower, y)','CALL "RS3-DOOR-SEED-Y" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,64),(0,65),(0,0)],lambda h,y:(y if h else y-1,))
T(g,'isWoodenDoor (3.1): true for a door whose set type canOpenByHand, so copper doors yes and the iron door no (set type index)','CALL "RS3-IS-WOODEN-DOOR" USING WS-I(1) WS-R(1)',1,[(i,) for i in (1,2,6,10,15,18)],lambda i:(flags(SETS[i-1])[0],))
SLAB={N:(0,16,13,16),S_:(0,16,0,3),E:(0,3,0,16),W:(13,16,0,16)}
def key(f,o,h):
    if not o: return f
    ccw={N:W,W:S_,S_:E,E:N}[f]
    return ccw if h==1 else cwd(f)
T(g,'shape key (3.2): the facing when closed; when open facing turned counter-clockwise if the hinge is right, clockwise if left (facing, open, hinge; key)','CALL "RS3-DOOR-SHAPE-KEY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(f,o,h) for f in (N,E,S_,W) for o in (0,1) for h in (0,1)],lambda f,o,h:(key(f,o,h),))
T(g,'slab for a key (3.2): boxZ(16, 13, 16) turned to the side opposite to the key: north z 13 to 16, south z 0 to 3, east x 0 to 3, west x 13 to 16 (key; min x, max x, min z, max z in pixels)','CALL "RS3-DOOR-SLAB" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(k,) for k in (N,S_,W,E)],lambda k:SLAB[k])
T(g,'door pathfinding (3.2): LAND and AIR give the value of open, WATER false (1 land, 2 air, 3 water; open)','CALL "RS3-DOOR-PATHFIND" USING WS-I(1) WS-I(2) WS-R(1)',1,[(t,o) for t in (1,2,3) for o in (0,1)],lambda t,o:(0 if t==3 else o,))
T(g,'placement gate (3.3 step 1): refused unless y is below the maximum height and the cell above can be replaced (y, max y, can be replaced)','CALL "RS3-DOOR-PLACE-CHECK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(64,319,1),(319,319,1),(318,319,1),(64,319,0),(320,319,1)],lambda y,m,r:(int(y<m and r==1),))
T(g,'placement power (3.3 steps 2 and 3): powered and open are hasNeighborSignal at the cell or the cell above (signal at pos, signal above; powered and open)','CALL "RS3-DOOR-PLACE-POWER" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(a or b),int(a or b)))
T(g,'upper half (3.3 step 4): the lower half state with half upper, written with setBlockAndUpdate (flags 3) (half; flags)','CALL "RS3-DOOR-UPPER" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,)],lambda h:(0,3))
def surv(h,below_sturdy,below_same): return int(below_sturdy) if h==1 else int(below_same)
T(g,'canSurvive (3.3 step 5): the lower half needs a sturdy UP face below, the upper half needs the same door block below (half, sturdy below, same door below)','CALL "RS3-DOOR-SURVIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(h,a,b) for h in (0,1) for a in (0,1) for b in (0,1)],lambda *a:(surv(*a),))
T(g,'door item (3.3): placeBlock first writes water into the cell above when it holds water, else air, with flags 27 (1 + 2 + 8 + 16) (isWaterAt; water, flags)','CALL "RS3-DOOR-ITEM-WATER" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda w:(w,27))
T(g,'directions (3.4): counter-clockwise and clockwise seen from above (direction, turn 1 clockwise 2 counter-clockwise)','CALL "RS3-DIR-TURN" USING WS-I(1) WS-I(2) WS-R(1)',1,[(d,t) for d in (N,E,S_,W) for t in (1,2)],lambda d,t:(cwd(d) if t==1 else {N:W,W:S_,S_:E,E:N}[d],))
STEP_={N:(0,-1),S_:(0,1),W:(-1,0),E:(1,0)}
def hinge(d,a0,a1,b0,b1,ld,rd,dx,dz):
    s=-a0-a1+b0+b1
    if (ld and not rd) or s>0: return 1
    if (rd and not ld) or s<0: return 0
    sx,sz=STEP_[d]
    return int((sx<0 and dz<500) or (sx>0 and dz>500) or (sz<0 and dx>500) or (sz>0 and dx<500))
HR=[(N,1,1,0,0,0,0,500,500),(N,0,0,0,0,1,0,500,500),(N,0,0,0,0,0,1,500,500),(N,0,0,0,0,1,1,700,500),(N,0,0,0,0,0,0,700,500),(N,0,0,0,0,0,0,300,500),(E,0,0,0,0,0,0,500,800),(E,0,0,0,0,0,0,500,200),(W,0,0,0,0,0,0,500,300),(W,0,0,0,0,0,0,500,700),(S_,0,0,0,0,0,0,300,500),(S_,0,0,0,0,0,0,700,500),(N,0,0,1,0,0,0,500,500),(N,0,0,0,1,0,0,500,500),(N,1,0,0,1,0,0,500,500),(N,1,0,1,0,0,0,300,500),(N,0,0,0,0,0,0,500,500),(E,0,0,0,0,0,0,500,500)]
T(g,'hinge (3.4): score -1 for each full cell on the counter-clockwise side and +1 on the clockwise side; a left door and no right door, or a positive score, gives right; the mirror cases give left; a tie uses the click point (direction, A0 full, A1 full, B0 full, B1 full, left door, right door, click dx, dz in thousandths; 0 left, 1 right)','CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1,HR,lambda *a:(hinge(*a),))
g.case('hinge, worked examples 1 to 3 (10): a wall on the left gives left; a door on the left gives right; a tie by the click point: north dx 0.7 right, dx 0.3 left, east dz 0.8 right',[("2 1 1 0 0 0 0 500 500",'CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1),("2 0 0 0 0 1 0 500 500",'CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1),("2 0 0 0 0 0 0 700 500",'CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1),("2 0 0 0 0 0 0 300 500",'CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1),("5 0 0 0 0 0 0 500 800",'CALL "RS3-DOOR-HINGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-R(1)',1)],"0 1 1 0 1")
T(g,'redstone power (3.5 step 1): hasNeighborSignal at the cell or at the other half (signal here, signal at the other half; power)','CALL "RS3-DOOR-POWER" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(a or b),))
def dnb(p,pw,o,same):
    if same or p==pw: return (0,0,0,pw,o)
    snd=(1 if p else 2) if p!=o else 0
    return (1,snd,snd,p,p)
T(g,'neighborChanged (3.5 steps 2 to 5): nothing when the update comes from the same block or power equals powered; sound and event BLOCK_OPEN or BLOCK_CLOSE only when power differs from open; then powered = open = power at flags 2 (power, powered, open, same block; write, sound 1 open 2 close, event, powered, open)','CALL "RS3-DOOR-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(p,pw,o,s) for p in (0,1) for pw in (0,1) for o in (0,1) for s in (0,1)],dnb)
g.case('powered door, worked example 4 (10): a lever on opens a closed door with the sound and the event; off closes it; a hand-opened door that then receives power makes no sound',[("1 0 0 0",'CALL "RS3-DOOR-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5),("0 1 1 0",'CALL "RS3-DOOR-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5),("1 0 1 0",'CALL "RS3-DOOR-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5)],"1/1/1/1/1 1/2/2/0/0 1/0/0/1/1")
def hup(l,d,nd,df,sv):
    if d in (0,1) and ((l==1)==(d==1)): return 1 if (nd and df) else 2
    if l==1 and d==0 and not sv: return 2
    return 0
T(g,'half pairing (3.5 updateShape): the lower half looking up or the upper half looking down copies the other half (state with half set) when it is a door of the other half, else becomes air; the lower half looking down with no survival becomes air; else default (lower, direction data value, neighbour is a door, its half differs, can survive; 0 default, 1 copy, 2 air)','CALL "RS3-DOOR-HALF-UPDATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(l,d,nd,df,sv) for l in (0,1) for d in (0,1,2) for nd in (0,1) for df in (0,1) for sv in (0,1)],lambda *a:(hup(*a),))
T(g,'use by hand (3.6): PASS (0) when canOpenByHand is false; else open cycles at flags 10, the sound and the event of the new state, SUCCESS (1) (canOpenByHand, open; result, new open, flags, sound 1 open 2 close, event)','CALL "RS3-DOOR-USE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(h,o) for h in (0,1) for o in (0,1)],lambda h,o:(1,1-o,10,2 if o else 1,2 if o else 1) if h else (0,o,0,0,0))
T(g,'setOpen (3.6): returns unless the state is this block and its open differs; writes open at flags 10 (is this block, current open, wanted; writes)','CALL "RS3-DOOR-SET-OPEN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(b,c,w) for b in (0,1) for c in (0,1) for w in (0,1)],lambda b,c,w:(int(b and c!=w),))
T(g,'wind charge (3.6 onExplosionHit): only the lower half, only when canOpenByWindCharge and not powered: setOpen(null, not open) (lower, can open by wind charge, powered; toggles)','CALL "RS3-DOOR-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(l,c,p) for l in (0,1) for c in (0,1) for p in (0,1)],lambda l,c,p:(int(l and c and not p),))
T(g,'destruction (3.6 playerWillDestroy): on the server, when the player prevents drops or has no correct tool, the other half is removed without a drop (server, prevents drops)','CALL "RS3-DOOR-DESTROY" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,))
T(g,'random tick (3.6): only the weathering variants, lower half only; waxed copper doors are plain doors (weathering, lower; ticks)','CALL "RS3-DOOR-RANDOM-TICK" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(a&b,))
T(g,'iron door, worked example 5 (10): right-click gives PASS, a powered neighbour opens it by 3.5, a wind charge does nothing (flags of the iron set type)','CALL "RS3-DOOR-USE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)\nCALL "RS3-DOOR-EXPLOSION" USING WS-I(3) WS-I(4) WS-I(5) WS-R(6)',6,[(0,0,1,0,0)],lambda *a:(0,0,0,0,0,0))
SU.write(g)
# ===== 4 TrapDoorBlock
g=SU.gen(4,'`TrapDoorBlock`','T0806','state and shape, placement, use, redstone and explosion rules.')
T(g,'default state (4.1): facing north, open false, half bottom (1; top is 0), powered false, waterlogged false','CALL "RS3-TRAP-DEFAULT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(N,0,1,0,0))
def tkey(f,o,h): return f if o else (D if h==0 else U)
T(g,'shape key (4.1): open uses facing; closed uses DOWN (0) for half top and UP (1) for half bottom (facing, open, half 0 top 1 bottom; key)','CALL "RS3-TRAP-SHAPE-KEY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(f,o,h) for f in (N,S_,W,E) for o in (0,1) for h in (0,1)],lambda *a:(tkey(*a),))
TS={N:(2,13,16),E:(0,0,3),S_:(2,0,3),W:(0,13,16),D:(1,13,16),U:(1,0,3)}
T(g,'slab for a key (4.1): boxZ(16, 13, 16) for six keys: north z 13 to 16, east x 0 to 3, south z 0 to 3, west x 13 to 16, down y 13 to 16, up y 0 to 3 (key; axis 0 x 1 y 2 z, min, max in pixels)','CALL "RS3-TRAP-SLAB" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(k,) for k in (N,E,S_,W,D,U)],lambda k:TS[k])
def tpath(t,o,w): return (o if t in (1,3) else w,)
T(g,'pathfinding (4.1, 9): LAND gives open, WATER gives waterlogged, AIR gives open (1 land, 2 water, 3 air; open, waterlogged)','CALL "RS3-TRAP-PATHFIND" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(t,o,w) for t in (1,2,3) for o in (0,1) for w in (0,1)],tpath)
def tplace(face,rep,cy,pd,sig,water):
    if not rep and face in (N,S_,W,E):
        f=face; h=0 if cy>500 else 1
    else:
        f=opp(pd); h=1 if face==U else 0
    o=int(sig)
    return (f,o,h,o,water)
TPR=[(N,0,700,N,0,0),(E,0,300,N,0,0),(E,0,500,N,0,1),(U,0,700,N,0,0),(D,0,700,W,0,0),(N,1,700,E,0,0),(S_,1,300,S_,1,1),(U,1,700,E,1,0),(D,1,100,S_,0,1),(W,0,501,N,1,0)]
T(g,'placement (4.2): a side click on a block face (not replacing) gives facing = the clicked face and half top above 0.5; otherwise facing is the opposite of the placer direction and half bottom when the face is UP else top; powered and open from the signal at the clicked position; waterlogged from the fluid (face, replacing, click y in thousandths, placer direction, signal, water; facing, open, half, powered, waterlogged)','CALL "RS3-TRAP-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,TPR,tplace)
T(g,'placement, worked example 6 (10): east face of a stone block, click height 0.7: facing east, half top; closed key DOWN, open key EAST (facing, closed key, half, open key)','CALL "RS3-TRAP-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)\nMOVE 0 TO WS-I(7)\nMOVE 1 TO WS-I(8)\nCALL "RS3-TRAP-SHAPE-KEY" USING WS-R(1) WS-I(7) WS-R(3) WS-R(7)\nCALL "RS3-TRAP-SHAPE-KEY" USING WS-R(1) WS-I(8) WS-R(3) WS-R(8)\nMOVE WS-R(7) TO WS-R(2)\nMOVE WS-R(8) TO WS-R(4)',4,[(E,0,700,N,0,0)],lambda *a:(E,D,0,E))
T(g,'use (4.3): PASS (0) when canOpenByHand is false, else toggle and SUCCESS (1)','CALL "RS3-TRAP-USE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda h:(h,))
T(g,'toggle (4.3): cycle open, flags 2; a waterlogged result schedules the water tick; the sound and event of the new state (open, waterlogged; new open, flags, water tick, sound 1 open 2 close, event)','CALL "RS3-TRAP-TOGGLE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(o,w) for o in (0,1) for w in (0,1)],lambda o,w:(1-o,2,w,1 if not o else 2,1 if not o else 2))
def tnb(s,p,pw,o,w):
    if not s or p==pw: return (0,o,pw,0,0,0)
    no=o; snd=0
    if o!=p: no=p; snd=1 if p else 2
    return (1,no,p,snd,snd,w)
T(g,'neighborChanged (4.3): server only; power at this cell only; nothing when power equals powered; when open differs the sound and event follow, else no sound (a hand-opened trapdoor that is then powered stays as it is); powered written; the water tick when waterlogged (server, power, powered, open, waterlogged; write, open, powered, sound, event, water tick)','CALL "RS3-TRAP-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(s,p,pw,o,w) for s in (0,1) for p in (0,1) for pw in (0,1) for o in (0,1) for w in (0,1)],tnb)
T(g,'explosion (4.3): when the explosion can trigger blocks, the set type canOpenByWindCharge and not powered: toggle with no player (can trigger, can open by wind charge, powered; toggles)','CALL "RS3-TRAP-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a and b and not c),))
T(g,'updateShape (4.3): a waterlogged trapdoor schedules the water tick, then the default','CALL "RS3-TRAP-UPDATE-SHAPE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda w:(w,))
T(g,'random tick (4.3): only the weathering variant, both halves, no condition; waxed copper trapdoors are plain trapdoors','CALL "RS3-TRAP-RANDOM-TICK" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda w:(w,))
SU.write(g)
# ===== 5 FenceGateBlock
g=SU.gen(5,'`FenceGateBlock`','T0808','state, shapes, connectsToDirection, placement, in_wall, use, redstone and explosion.')
T(g,'default state (5.1): facing north, all booleans false; 32 states (facing, open, powered, in_wall)','CALL "RS3-GATE-DEFAULT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(N,0,0,0,32))
def axis(d): return 0 if d in (W,E) else 1 if d in (D,U) else 2
T(g,'connectsToDirection (5.1): true when the axis of the clockwise direction of facing equals the axis of the direction (facing, direction)','CALL "RS3-GATE-CONNECTS" USING WS-I(1) WS-I(2) WS-R(1)',1,[(f,d) for f in (N,E,S_,W) for d in (N,E,S_,W)],lambda f,d:(int(axis(cwd(f))==axis(d)),))
def gshape(iw,o): return (13 if iw else 16, 0 if o else 24, 0 if o else 5, 0 if o else 24, 3 if iw else 0)
T(g,'shapes (5.1): outline top y 16 pixels, 13 when in_wall; collision y 0 to 24 closed, empty when open; support y 5 to 24 closed, empty when open; occlusion posts moved down 3 pixels when in_wall (in_wall, open; outline top, collision top, support min, support max, occlusion drop)','CALL "RS3-GATE-SHAPE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(a,b) for a in (0,1) for b in (0,1)],gshape)
T(g,'pathfinding (5.1): LAND and AIR give open, WATER false (1 land, 2 air, 3 water; open)','CALL "RS3-GATE-PATHFIND" USING WS-I(1) WS-I(2) WS-R(1)',1,[(t,o) for t in (1,2,3) for o in (0,1)],lambda t,o:(0 if t==3 else o,))
def inwall(f,w,e,n,s):
    if f in (N,S_): return int(w or e)
    return int(n or s)
T(g,'placement (5.2): powered and open from the signal at the clicked position; in_wall: for an axis Z facing a wall to the west or east, for an axis X facing a wall to the north or south (facing, wall W, wall E, wall N, wall S; in_wall)','CALL "RS3-GATE-IN-WALL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(f,)+tuple((i>>k)&1 for k in range(4)) for f in (N,E) for i in range(16)],lambda f,*w:(inwall(f,*w),))
T(g,'placement state (5.2): powered = open = the signal, facing = the placer direction (signal, placer direction; powered, open, facing)','CALL "RS3-GATE-PLACE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(s,d) for s in (0,1) for d in (N,E)],lambda s,d:(s,s,d))
def gus(f,d,iw,e,pw):
    return (iw,e,pw)
def gup(f,d,ch,op,old):
    if axis(d)==axis(cwd(f)): return (1,int(ch or op))
    return (0,old)
T(g,'updateShape (5.2): a neighbour on the axis of the clockwise direction of facing sets in_wall to (the changed neighbour is a wall) OR (the block on the opposite side is a wall); otherwise the default shape update (facing, direction, changed is a wall, opposite is a wall, old in_wall; handled, in_wall)','CALL "RS3-GATE-UPDATE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,[(f,d,c,o,old) for f in (E,N) for d in (N,S_,E) for c in (0,1) for o in (0,1) for old in (0,1)],gup)
g.case('in_wall, worked example 7 (10): a gate facing east with walls north and south has in_wall true; removing the north wall (update from north) keeps it true through the south wall',[("5 0 0 1 1",'CALL "RS3-GATE-IN-WALL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1),("5 2 0 1 1",'CALL "RS3-GATE-UPDATE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2)],"1 1/1")
def guse(o,f,pd):
    if o: return (0,f,2,2,10)
    nf=pd if f==opp(pd) else f
    return (1,nf,1,1,10)
T(g,'use (5.3): an open gate closes; a closed gate turns to face the player when its facing is the opposite of the player direction, then opens; flags 10, sound and event of the new state, SUCCESS, never a canOpenByHand test (open, facing, player direction; new open, facing, sound 1 open 2 close, event, flags)','CALL "RS3-GATE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(o,f,pd) for o in (0,1) for f in (N,S_) for pd in (N,S_,E)],guse)
T(g,'gate use, worked example 8 (10): a gate facing north, closed, used by a player looking south: facing south, open; looking north: facing stays north, open','CALL "RS3-GATE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,N,S_),(0,N,N)],guse)
def gnb(s,p,pw,o):
    if not s or p==pw: return (0,pw,o,0,0)
    snd=(1 if p else 2) if o!=p else 0
    return (1,p,p,snd,snd)
T(g,'neighborChanged (5.3): server only; when power differs from powered write powered = open = power at flags 2; the sound and event when the old open differs from power (server, power, powered, open; write, powered, open, sound, event)','CALL "RS3-GATE-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(s,p,pw,o) for s in (0,1) for p in (0,1) for pw in (0,1) for o in (0,1)],gnb)
def gex(c,pw,o):
    if c and not pw: return (1,1-o,3,2 if o else 1,2 if o else 1)
    return (0,o,0,0,0)
T(g,'explosion (5.3): when the explosion can trigger blocks and the gate is not powered it toggles open with flags 3 (setBlockAndUpdate), the close sound if it was open else the open sound, with no entity; the wind-charge flag is not consulted (can trigger, powered, open; toggles, new open, flags, sound, event)','CALL "RS3-GATE-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(c,p,o) for c in (0,1) for p in (0,1) for o in (0,1)],gex)
SU.write(g)
# ===== 6 RedstoneLampBlock
g=SU.gen(6,'`RedstoneLampBlock`','T0810','placement, the neighbour update with its 4-tick turn-off delay, the tick and the pulse stretcher.')
T(g,'light (6): 15 when lit, 0 otherwise','CALL "RS3-LAMP-LIGHT" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda l:(15*l,))
T(g,'placement (6 step 1): lit = hasNeighborSignal at the clicked position; no onPlace check','CALL "RS3-LAMP-PLACE" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(s,))
def lnb(sv,lit,sig):
    if not sv or lit==sig: return (0,lit,0)
    if lit: return (1,lit,4)
    return (2,1,0)
T(g,'neighborChanged (6 step 2): server only; when lit differs from the signal: a lit lamp without signal schedules a tick after 4 (NORMAL), an unlit lamp with signal turns on at once with flags 2 (server, lit, signal; action 0 nothing 1 schedule 2 write, lit now, delay)','CALL "RS3-LAMP-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,[(s,l,g_) for s in (0,1) for l in (0,1) for g_ in (0,1)],lnb)
T(g,'tick (6 step 3): lit and no signal turns off (flags 2); if the signal returned nothing happens (lit, signal; lit after, write)','CALL "RS3-LAMP-TICK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(l,g_) for l in (0,1) for g_ in (0,1)],lambda l,g_:(0,1) if l and not g_ else (l,0))
T(g,'pending ticks (6, 29 section 4): scheduling the same block at the same position is ignored while a tick is pending, so repeated power losses inside the 4 ticks create one tick (pending; added)','CALL "RS1-SCHEDULE-NEW" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda p:(int(not p),))
NB='CALL "RS3-LAMP-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)'
TK='CALL "RS3-LAMP-TICK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)'
g.case('worked example 9 (10): time 100 the signal turns on, the unlit lamp lights at once; time 120 the signal drops, a tick is scheduled for 124; time 122 the signal returns, nothing; time 124 the tick finds the signal, the lamp never went out',[("1 0 1",NB,3),("1 1 0",NB,3),("1 1 1",NB,3),("1 1",TK,2)],"2/1/0 1/1/4 0/1/0 1/0")
g.case('variant of worked example 9 (10): the signal stays off, at 124 the tick turns the lamp off',[("1 1 0",NB,3),("1 0",TK,2)],"1/1/4 0/1")
SU.write(g)
# ===== 7 Copper bulbs
g=SU.gen(7,'`CopperBulbBlock` and `WeatheringCopperBulbBlock`','T0812','state, light, the toggle rule, the comparator output and the variants.',NAME)
LIGHT=[15,12,8,4]
T(g,'light (7.1): 15, 12, 8, 4 when lit for unaffected, exposed, weathered, oxidized (0 to 3), 0 when unlit (weather state, lit)','CALL "RS3-BULB-LIGHT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(w,l) for w in range(4) for l in (0,1)],lambda w,l:(LIGHT[w]*l,))
T(g,'default state (7.1): lit and powered false; 4 states; never a redstone conductor (lit, powered, states, conductor kind 1 never)','CALL "RS3-BULB-DEFAULT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(0,0,4,1))
T(g,'onPlace (7.2 step 1): the old state is the same block: nothing (a property change); otherwise on a server level checkAndFlip runs (old same block, server; runs)','CALL "RS3-BULB-ON-PLACE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(o,s) for o in (0,1) for s in (0,1)],lambda o,s:(int(not o and s),))
T(g,'neighborChanged (7.2 step 2): on a server level checkAndFlip runs (server; runs)','CALL "RS3-BULB-NEIGHBOR" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(s,))
def flip(l,p,sig):
    if sig==p: return (0,l,p,0)
    if not p:
        nl=1-l
        return (1,nl,sig,1 if nl else 2)
    return (1,l,sig,0)
T(g,'checkAndFlip (7.2 step 3): nothing when the signal equals powered; a rising edge toggles lit and plays turn_on (1) or turn_off (2), no sound otherwise; the state is written with powered = signal at flags 3; a falling edge only clears powered (lit, powered, signal; write, lit, powered, sound)','CALL "RS3-BULB-FLIP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(l,p,s) for l in (0,1) for p in (0,1) for s in (0,1)],flip)
FL_='CALL "RS3-BULB-FLIP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4)'
g.case('worked example 10 (10): placed beside a lit redstone block: lit with turn_on; the block removed: powered false, lit stays; placed again: lit false with turn_off',[("0 0 1",FL_,4),("1 1 0",FL_,4),("1 0 1",FL_,4)],"1/1/1/1 1/1/0/0 1/0/1/2")
T(g,'comparator output (7.3): 15 when lit, else 0, independent of the weather state and the comparator direction (lit, weather state, direction)','CALL "RS3-BULB-ANALOG" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(l,w,d) for l in (0,1) for w in (0,3) for d in (2,5)],lambda l,w,d:(15*l,))
BV={'copper_bulb':(0,0),'exposed_copper_bulb':(1,0),'weathered_copper_bulb':(2,0),'oxidized_copper_bulb':(3,0)}
for k,v in list(BV.items()): BV['waxed_'+k]=(v[0],1)
TN(g,'the eight blocks (7.4): copper_bulb, exposed, weathered and oxidized and their four waxed twins: identical redstone behaviour, only light and the random tick differ (weather state 0 to 3, waxed; 0 0 for an unknown name)','CALL "RS3-BULB-VARIANT" USING WS-NM WS-R(1) WS-R(2)',2,[(n,) for n in BV]+[('copper_block',)],lambda n:BV.get(n,(0,0)))
T(g,'random tick (7.1): only the weathering class has the random tick, the waxed class not; the state-preserving next block keeps lit and powered (waxed; ticks, keeps state)','CALL "RS3-BULB-RANDOM-TICK" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda w:(1-w,1))
T(g,'waxing and scraping (7.4): a block change triggers onPlace, so checkAndFlip runs on the new block and does nothing when signal equals powered (signal, powered; write)','CALL "RS3-BULB-FLIP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(1,1,1),(0,0,0)],flip)
SU.write(g)
# ===== 8 TNT
g=SU.gen(8,'`TntBlock`, priming and the primed TNT entity','T0814','prime, the ways to ignite, the unstable break, the entity creation values and the explosion constants.',' 01 WS-FL FLOAT-LONG.\n')
T(g,'state (8.1): one property unstable (default false), 2 states; fire table 15 and 100 (ignite odds, burn odds), ignited by lava, instabreak (unstable, states, ignite odds, burn odds)','CALL "RS3-TNT-STATE" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(0,2,15,100))
def prime(sv,ex,pl,adv,cb):
    if not sv or not ex: return 0
    if pl and adv and not cb: return 0
    return 1
T(g,'prime (8.2 steps 1 to 3): false on a client level, false when tnt_explodes is false, false for an adventure-mode player who may not break the block with the stack; otherwise a primed TNT is created (server, tnt_explodes, igniter is a player, adventure mode, can break; created)','CALL "RS3-TNT-PRIME" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,[(a,b,c,d,e) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1) for e in (0,1)],lambda *a:(prime(*a),))
T(g,'prime results (8.2 steps 5 to 7): the sound entity.tnt.primed at the entity at volume 1.0 and pitch 1.0, the event PRIME_FUSE (3) with the igniter as source, spawn at (x + 0.5, y, z + 0.5) in thousandths (created; sound, event, x, y, z)','CALL "RS3-TNT-PRIME-RESULT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(1,),(0,)],lambda c:(1,3,500,0,500) if c else (0,0,0,0,0))
def vel(u):
    a=Dc(repr(u))*Dc('6.2831854820251465')
    a=float(a)
    return (round(-math.sin(a)*0.02*1e10),round(0.20000000298023224*1e10),round(-math.cos(a)*0.02*1e10))
US=('0.0','0.25','0.5','0.75','0.1','0.9')
g.case('initial velocity (8.5): one nextDouble draw u; a = u * 6.2831854820251465; (-sin a * 0.02, 0.20000000298023224, -cos a * 0.02) in tenths of nanoblocks per tick',[(u,'CALL "RS3-TNT-VELOCITY" USING WS-FX(1) WS-R(1) WS-R(2) WS-R(3)',3) for u in US]," ".join("/".join(str(x) for x in vel(float(u))) for u in US))
def sfuse(f,r): return (max(1,f//4),r+f//8)
T(g,'short fuse after a neighbouring explosion (8.3): random.nextInt(max(1, fuse / 4)) + fuse / 8 with integer divisions: for 80 the draw bound is 20 and the fuse 10 to 29 (fuse, draw; bound, new fuse)','CALL "RS3-TNT-SHORT-FUSE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(80,0),(80,7),(80,19),(3,0),(7,0),(100,4)],sfuse)
T(g,'placement (8.3 onPlace): nothing when the old block is TNT; else when powered and prime succeeded the block is removed with flags 3 (old is TNT, signal, prime succeeded; prime called, remove)','CALL "RS3-TNT-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(o,s,p) for o in (0,1) for s in (0,1) for p in (0,1)],lambda o,s,p:(int(not o and s),int(not o and s and p)))
T(g,'neighborChanged (8.3): when powered prime is called, and the block is removed with flags 3 when it returned true (signal, prime succeeded; prime called, remove)','CALL "RS3-TNT-NEIGHBOR" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(s,p) for s in (0,1) for p in (0,1)],lambda s,p:(s,int(s and p)))
def tuse(h,pr,sv,ex):
    if h==0: return (0,0,0,0,0,0)
    if pr: return (1,1,int(h==1),int(h==2),1,0)
    if sv and not ex: return (2,0,0,0,0,1)
    return (1,0,0,0,0,0)
T(g,'hand (8.3 useItemOn): only flint and steel (1) or a fire charge (2), else the default result (0); on prime true: air with flags 11, flint and steel damaged by 1 or one fire charge consumed, the item_used statistic, SUCCESS (1); on false: PASS (2) with the overlay block.minecraft.tnt.disabled on a server with tnt_explodes false, else SUCCESS (held item, prime succeeded, server, tnt_explodes; result, air written, damage flint, consume charge, statistic, overlay)','CALL "RS3-TNT-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(h,p,s,e) for h in (0,1,2) for p in (0,1) for s in (0,1) for e in (0,1)],tuse)
def tproj(sv,bu,mi,ol,pr,ar):
    if not sv or not bu or not mi: return (0,0,0,0)
    return (1,ol,ar,int(pr))
T(g,'projectile (8.3 onProjectileHit): server only, a burning projectile that may interact: prime with the owner when it is living (else none) and the arrow pickup stack (else empty); removeBlock when it returned true (server, burning, may interact, owner living, prime succeeded, arrow; called, owner given, stack given, remove)','CALL "RS3-TNT-PROJECTILE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(a,b,c,d,e,f) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1) for e in (0,1) for f in (0,1)],tproj)
def texp(ex): return (1,1,0) if ex else (0,0,0)
T(g,'explosion of a neighbour (8.3 wasExploded): with tnt_explodes true a primed TNT is created with the short fuse, no sound and no game event, and the item is not dropped (tnt_explodes; created, short fuse used, drops)','CALL "RS3-TNT-EXPLODED" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(0,),(1,)],texp)
def tdes(sv,cr,un): return (int(sv and not cr and un),)
T(g,'breaking an unstable TNT (8.4): on the server, when the player is not in creative and unstable is true, prime runs (owner none, empty stack), then the normal destruction (server, creative, unstable; prime called)','CALL "RS3-TNT-DESTROY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda *a:tdes(*a))
RM={1:(1,3),2:(1,11),3:(1,0),4:(1,0),5:(0,0)}
T(g,'removal by caller (8.2): onPlace, neighborChanged and onProjectileHit removeBlock at flags 3 (1); the hand path writes air at flags 11 (2); fire has already replaced the block (3), playerWillDestroy lets the default destroy remove it (4); wasExploded does not call prime at all (5) (caller; prime called, flags, 0 when the caller removes nothing itself)','CALL "RS3-TNT-REMOVAL" USING WS-I(1) WS-R(1) WS-R(2)',2,[(c,) for c in (1,2,3,4,5)],lambda c:{1:(1,3),2:(1,11),3:(1,0),4:(1,0),5:(0,0)}[c])
T(g,'entity and explosion constants (8.5): fuse 80, metadata index 8, explosion power 4.0 (tenths), read back clamped to 0 to 128, size 0.98 (hundredths), eye 0.15 (hundredths), tracking range 10, update interval 10, fire immune (1)','CALL "RS3-TNT-CONSTANTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7) WS-R(8) WS-R(9) WS-R(10)',10,[(0,)],lambda x:(80,8,40,128,98,15,10,10,1,0))
T(g,'explosion height (8.5): y + 0.9800000190734863 * 0.0625 = y + 0.0612500011920929, in tenths of nanoblocks (not the 0.0625 of 21 section 8.3, Open question 14)','CALL "RS3-TNT-EXPLOSION-Y" USING WS-R(1)',1,[(0,)],lambda x:(round(0.0612500011920929*1e10),))
T(g,'NBT (8.5): explosion_power is written only when it is not 4.0; power read back clamped to 0 to 128 (tenths; written, clamped)','CALL "RS3-TNT-NBT-POWER" USING WS-I(1) WS-R(1) WS-R(2)',2,[(40,),(41,),(0,),(1500,),(-5,)],lambda p:(int(p!=40),max(0,min(1280,p))))
g.case('worked example 11 and 13 (10): TNT beside a powered block primes and is removed; with tnt_explodes false prime fails and the TNT stays; an adventure player without can_break gets SUCCESS and nothing else',[("1 1 0 0 0",'CALL "RS3-TNT-PRIME" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1),("1 0 0 0 0",'CALL "RS3-TNT-PRIME" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1),("1 1 1 1 0",'CALL "RS3-TNT-PRIME" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1),("1 0 1 1",'CALL "RS3-TNT-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6)],"1 0 0 1/0/0/0/0/0")
SU.write(g)
# ===== 9 Corrections
g=SU.gen(9,'Corrections to other documents','T0816','the five corrected statements and the TNT explosion height.')
T(g,'corrections table (9): the corrected rule of each row as numbers: 1 gate use turns to the player direction (1) only when facing is the opposite of it (1); 2 gate explosion toggles (1) at flags 3; 3 trapdoor pathfinding LAND 1 WATER 2 AIR 3 (the cases decoded); 4 door wind charge lower half only (1); 5 trapdoor redstone leaves open alone when it already equals power (1) (row; value a, value b, value c)','CALL "RS3-CORRECTION" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(r,) for r in (1,2,3,4,5,6)],lambda r:{1:(1,1,0),2:(1,3,0),3:(1,2,3),4:(1,0,0),5:(1,0,0)}.get(r,(0,0,0)))
T(g,'row 1 live (9, 5.3): the gate turns to face the player direction only when facing is the opposite of it (open, facing, player direction)','CALL "RS3-GATE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,N,S_),(0,S_,S_)],guse)
T(g,'row 2 live (9, 5.3): a gate explosion toggles an open gate closed and a closed gate open at flags 3 (can trigger, powered, open)','CALL "RS3-GATE-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(1,0,1),(1,0,0)],gex)
T(g,'row 3 live (9, 4.1): trapdoor pathfinding LAND open, WATER waterlogged, AIR open','CALL "RS3-TRAP-PATHFIND" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,1,0),(2,1,0),(2,0,1),(3,1,0)],tpath)
T(g,'row 4 live (9, 3.6): a wind charge opens or closes only the lower half of a door with canOpenByWindCharge that is not powered','CALL "RS3-DOOR-EXPLOSION" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,1,0),(0,1,0)],lambda l,c,p:(int(l and c and not p),))
T(g,'row 5 live (9, 4.3): a hand-opened trapdoor that is then powered plays no sound and does not change open again','CALL "RS3-TRAP-NEIGHBOR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(1,1,0,1,0)],tnb)
T(g,'open question 14 (12): the TNT explosion height is y + 0.0612500011920929, not y + 0.0625','CALL "RS3-TNT-EXPLOSION-Y" USING WS-R(1)',1,[(0,)],lambda x:(round(0.0612500011920929*1e10),))
SU.write(g)
