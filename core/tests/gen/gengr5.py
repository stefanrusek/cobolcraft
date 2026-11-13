import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-5-%d'%n,'29b-5§%d'%n,subj,'Test of 29b part 5 section %d, %s (core/src/growth-29b-5.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_growth_29b_5_%d.cob'%n)
def TBL(name,cnt): return " 01 WS-%sG.\n    05 WS-%s BINARY-LONG OCCURS %d TIMES.\n"%(name,name,cnt)
def setarr(name,vals): return "".join('MOVE %d TO WS-%s(%d)\n'%(v,name,i+1) for i,v in enumerate(vals))
def show(*v): return "/".join(str(x) for x in v)
# ===== 1
g=GG(1,'`MushroomBlock`','T0611','survival, random tick spread and bone meal of the brown and red mushroom.')
sv=[(0,0,1),(0,12,1),(0,13,1),(0,5,0),(1,15,0),(1,15,1),(1,0,0),(0,14,1),(0,13,0)]
def msurv(o,l,s):
    ok=1 if o else int(l<13 and s)
    return s,ok
g.run('survival (1.1): mayPlaceOn is a full opaque cube below; canSurvive is true at any light over a tag overrides_mushroom_light_requirement block, else raw brightness below 13 and a solid support',[S(*c) for c in sv],'CALL "GC5-MUSH-SURVIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*msurv(*c)) for c in sv))
gc=[(0,1),(0,4),(1,0),(1,4),(1,5),(24,0),(24,9),(7,3),(0,5),(0,6)]
def gate(d,c):
    p=int(d==0); a=int(p and c<=4)
    return p,a,(21 if a else 1)
g.run('spread gate (1.2): nextInt(25) of 0 (1/25) and a count of the same block in the 9 x 3 x 9 box (itself included) of at most 4 allow the spread, which then makes 1 + 4 + 16 = 21 draws; otherwise one draw (V11, V12)',[S(*c) for c in gc],'CALL "GC5-MUSH-GATE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*gate(*c)) for c in gc))
oc=[(0,0,0,0),(2,1,0,2),(1,1,1,1),(2,0,1,0),(0,1,0,2),(1,0,0,1)]
g.run('target offset (1.2 step 3): the draws nextInt(3), nextInt(2), nextInt(2), nextInt(3) in the order dx, dy-first, dy-second, dz give dx = a - 1, dy = first - second (-1..1, weights 1:2:1), dz = d - 1',[S(*c) for c in oc],'CALL "GC5-MUSH-OFFSET" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(c[0]-1,c[1]-c[2],c[3]-1) for c in oc))
tg=[(1,1),(1,0),(0,1),(0,0)]
g.run('the walk and the final place (1.2 steps 4 and 5) act only on an air target where the mushroom state can survive (light below 13 or an override support)',[S(*c) for c in tg],'CALL "GC5-MUSH-TARGET" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
dr=[0,0.1,0.39999,0.4,0.40001,0.5,0.99999]
g.run('bone meal success (1.3): one nextFloat widened to double, success when below 0.4 (40%, V13)',[str(d) for d in dr],'CALL "GC5-BONE-SUCCESS" USING WS-FX(1) WS-R(1)',1," ".join(str(int(d<0.4)) for d in dr))
bv=[(1,1,1,64,3,-64,320),(0,1,1,64,3,-64,320),(1,0,1,64,3,-64,320),(1,1,0,64,3,-64,320),(1,1,1,312,3,-64,320),(1,1,1,313,3,-64,320),(1,1,1,-71,3,-64,320),(1,1,1,-70,3,-64,320),(1,1,1,100,0,0,320),(1,1,1,-4,0,-1,320),(1,1,1,-5,0,-1,320)]
def mbv(s,e,h,y,r,mn,mx):
    top=y+4+r
    return int(s and e and h and mn<=top<mx)
g.run('bone meal target (1.3): server level only, the feature exists and is a huge mushroom feature, and pos.above(4 + foliageRadius) is inside the build height',[S(*c) for c in bv],'CALL "GC5-MUSH-BONE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-R(1)',1," ".join(str(mbv(*c)) for c in bv))
gr=[(1,1),(1,0),(0,1),(0,0)]
def mgr2(e,p):
    if not e: return (0,0,0)
    return (1,int(not p),int(p))
g.run('growMushroom (1.3): without the feature nothing changes and false; else the mushroom is removed, then restored when place fails (the player still loses the bone meal), true when it places (V13)',[S(*c) for c in gr],'CALL "GC5-MUSH-GROW" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*mgr2(*c)) for c in gr))
W(g,1)
# ===== 2
g=GG(2,'`HugeMushroomBlock` and `ShelfMushroomBlock`','T0613','the face connection state of the huge mushroom block and the shelf mushroom rules.')
g.extra=TBL('A6',16)+TBL('B6',6)
FN=["N","E","S","W","U","D"]
sames=[[0]*6,[1,0,0,0,0,0],[0,0,0,0,1,1],[1,1,1,1,1,1],[0,1,0,1,0,0],[1,0,1,0,1,0]]
def hc(arr,call): return setarr('A6',arr)+call
pl=[(hc(s,'CALL "GC5-HUGE-PLACE" USING WS-A6G WS-B6G\nMOVE WS-B6(1) TO WS-R(1)\nMOVE WS-B6(2) TO WS-R(2)\nMOVE WS-B6(3) TO WS-R(3)\nMOVE WS-B6(4) TO WS-R(4)\nMOVE WS-B6(5) TO WS-R(5)\nMOVE WS-B6(6) TO WS-R(6)'),6) for s in sames]
g.case('placement state (2.1, V17): each face is true when the block in that direction is NOT the same block (north, east, south, west, up, down)',[("0",c,n) for c,n in pl]," ".join(show(*[1-x for x in s]) for s in sames))
# su
suc=[([1,1,1,1,1,1],d,s) for d in range(1,7) for s in (1,)]+[([1,1,1,1,1,1],3,0),([0,1,0,1,1,0],1,0),([0,1,0,1,1,0],1,1),([1,0,1,1,0,1],6,1)]
def suexp(f,d,s):
    f=list(f)
    if s: f[d-1]=0
    return f
def su_call(f,d,s):
    return setarr('A6',f)+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nCALL "GC5-HUGE-SU" USING WS-A6G WS-I(1) WS-I(2) WS-B6G\n'%(d,s)+"".join('MOVE WS-B6(%d) TO WS-R(%d)\n'%(i,i) for i in range(1,7)).rstrip('\n')
g.case('shape update (2.1): the face of the update direction becomes false when that neighbour is the same block; otherwise the state is unchanged, and a false face is never set back to true',[("0",su_call(*c),6) for c in suc]," ".join(show(*suexp(*c)) for c in suc))
base=[1,0,0,1,1,0]
def rot(f,r):
    o=list(f)
    for i in range(4): o[(i+r)%4]=f[i]
    return o
def mir(f,m):
    o=list(f)
    perm={0:{},1:{0:2,2:0},2:{1:3,3:1}}[m]
    for i in range(6): o[perm.get(i,i)]=f[i]
    return o
rc=[(base,r) for r in range(4)]+[([1,0,1,1,0,0],1),([1,1,0,0,1,1],3)]
def rcall(f,r,prog):
    return setarr('A6',f)+'MOVE %d TO WS-I(1)\nCALL "%s" USING WS-A6G WS-I(1) WS-B6G\n'%(r,prog)+"".join('MOVE WS-B6(%d) TO WS-R(%d)\n'%(i,i) for i in range(1,7)).rstrip('\n')
g.case('rotation (2.1): the face of the rotated direction takes the value of the original direction (clockwise 90 sends north to east); up and down map to themselves',[("0",rcall(f,r,"GC5-HUGE-ROTATE"),6) for f,r in rc]," ".join(show(*rot(f,r)) for f,r in rc))
mc=[(base,m) for m in range(3)]+[([1,0,1,1,0,0],1),([1,1,0,0,1,1],2),([0,1,1,0,0,1],1),([0,1,1,0,0,1],2)]
g.case('mirror (2.1, V20): each direction passes through Mirror.mirror: left-right swaps the north and south faces, front-back the east and west faces; up and down never change',[("0",rcall(f,m,"GC5-HUGE-MIRROR"),6) for f,m in mc]," ".join(show(*mir(f,m)) for f,m in mc))
g.run('shelf mushroom survival (2.2): the block opposite to facing has a sturdy face towards facing',["0","1"],'CALL "GC5-SHELF-SURVIVE" USING WS-I(1) WS-R(1)',1,"0 1")
def place(pairs):
    for i,(h,c) in enumerate(pairs):
        if h and c: return i+1
    return 0
pcs=[[(1,1)]*6,[(0,1),(0,1),(1,0),(1,1),(0,1),(1,1)],[(0,1)]*6,[(1,0)]*6,[(0,1),(0,1),(0,1),(0,1),(0,1),(1,1)],[(1,0),(1,0),(1,0),(1,0),(1,0),(1,0)][:5]+[(1,1)],[(1,1),(1,1),(1,1),(1,1),(1,1),(1,1)][:3]+[(0,0)]*3]
g.case('placement (2.2): the first of the nearest looking directions that is horizontal and gives a state that can survive; none gives no placement (index 0)',[("0",setarr('A6',[x for p in pc for x in p])+'CALL "GC5-SHELF-PLACE" USING WS-A6G WS-R(1)',1) for pc in pcs]," ".join(str(place(pc)) for pc in pcs))
g.run('shape update (2.2): the update from the side opposite to facing with a state that cannot survive gives air; any other update gives the horizontal-directional default',["1 0","1 1","0 0","0 1"],'CALL "GC5-SHELF-SU" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
g.run('bone meal (2.2): valid while age is below 1, the test always succeeds, performBonemeal sets age + 1',["0","1"],'CALL "GC5-SHELF-BONE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 0/1/2")
g.run('bounce (2.2): the sound plays unless the entity is an item entity or a primed TNT; volume 1 and pitch 1 (x 100), restitution 0.75 (x 100)',["0","1","2"],'CALL "GC5-SHELF-BOUNCE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"1/100/100/75 0/100/100/75 0/100/100/75")
W(g,2)
# ===== 3
g=GG(3,'Nether fungi, roots, sprouts and the moss blocks','T0615','the Nether fungus, roots and sprouts rules, the moss block bone meal and the pale moss carpet entry points.')
g.extra=TBL('A6',16)
ft={1:(1,1,1,1,8,9,1),2:(2,2,2,2,8,9,1),3:(3,0,0,12,13,0),4:(4,0,0,12,13,0),5:(5,0,0,12,3,0)}
def fte(b):
    if b<=2: return (b,b,b,8,9,1)
    return (b,0,0,12,3 if b==5 else 13,0)
g.run('table (3.1, 3.2): support tag, required nylium, planted feature, shape column(width, 0, height) and whether the block has bone meal behaviour (crimson and warped fungus: crimson and warped nylium, column(8,0,9); roots column(12,0,13); sprouts column(12,0,3), no bone meal, V18)',[str(b) for b in range(1,6)],'CALL "GC5-FUNGUS-TABLE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6," ".join(show(*fte(b)) for b in range(1,6)))
fb=[(1,1,1),(1,1,0),(1,0,1),(0,1,1),(0,0,0)]
g.run('fungus bone meal (3.1, V14): valid when the block below IS the required nylium and pos.above() is inside the build height; performBonemeal places the feature when it exists, never removes the fungus first and restores nothing on failure',[S(*c) for c in fb],'CALL "GC5-FUNGUS-BONE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(int(a and b),int(c),0) for a,b,c in fb))
mb=[(1,1),(1,0),(0,1),(0,0)]
g.run('moss block bone meal (3.3, V15): valid when the cell above is air; always successful; type NEIGHBOR_SPREADER (1); the feature is placed at pos.above() when it exists; the particle is at pos.above()',[S(*c) for c in mb],'CALL "GC5-MOSS-BONE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(a,1,1,b,1) for a,b in mb))
g.run('feature keys (3.3): moss_block uses moss_patch_bonemeal, pale_moss_block pale_moss_patch_bonemeal',["1","2"],'CALL "GC5-MOSS-FEATURE" USING WS-I(1) WS-R(1)',1,"1 2")
def side(att,ab,base,bel):
    s=0
    if att: s=2 if ab else 1
    if not base and bel: s=0
    return s
sc=[(0,0,0,0),(1,0,0,0),(1,1,0,0),(0,1,0,0),(1,0,0,1),(1,1,0,1),(0,0,0,1),(1,0,1,1),(1,1,1,1)]
g.run('carpet side (3.4 step 2, force-low true): a supported side is low, tall when the carpet above has that side with base false, none otherwise; with the candidate base false it is none when the carpet below has none there',[S(*c) for c in sc],'CALL "GC5-CARPET-SIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(side(*c)) for c in sc))
tc=[(0,0,[1,0,0,0],1),(0,0,[0,0,0,0],1),(0,0,[2,2,1,0],1),(0,0,[0,0,0,1],1),(1,0,[1,1,1,1],1),(0,1,[1,1,1,1],1),(0,0,[1,1,1,1],0),(0,0,[0,2,0,0],1),(0,0,[0,0,2,0],1)]
def top(ab,bl,s,d): return int((not ab) and (not bl) and d and any(s))
def tcall(ab,bl,s,d): return setarr('A6',s)+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nCALL "GC5-CARPET-TOPPER" USING WS-I(1) WS-I(2) WS-A6G WS-I(3) WS-R(1)'%(ab,bl,d)
g.case('topper (3.4 steps 1, 4): air when the cell above is a carpet with base true, or a block that is not a carpet and cannot be replaced; with the constant true side chance no side is removed; air also without any face or with the same state as at A',[("0",tcall(*c),1) for c in tc]," ".join(str(top(*c)) for c in tc))
g.run('carpet bone meal (3.4): valid when base is true and the topper is not air; always successful; performBonemeal sets the topper at pos.above() when it is not air',["1 1","1 0","0 1","0 0"],'CALL "GC5-CARPET-BONE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 0/1/0 0/1/0 0/1/0")
W(g,3)
# ===== 4
g=GG(4,'The oxidation engine','T0617','the constants, the neighbour scan, the probability and the draws of changeOverTime.')
g.extra=TBL('NB',16)
GATE=0.05688889
g.run('constants (4.1): SCAN_DISTANCE 4 and the gate 0.05688889 (x 1e8)',["0"],'CALL "GC5-OX-CONST" USING WS-R(1) WS-R(2)',2,"4/5688889")
g.run('chance modifier (4.1, V5): 0.75 (x 1000) for an unaffected block, 1.0 for exposed, weathered and oxidized',["0","1","2","3"],'CALL "GC5-OX-MODIFIER" USING WS-I(1) WS-R(1)',1,"750 1000 1000 1000")
dg=[0,0.01,0.05688,0.05688889,0.0569,0.5,0.99999]
g.run('first draw (4.1 step 1, V1): nextFloat below 0.05688889 passes; one draw is consumed either way',[str(d) for d in dg],'CALL "GC5-OX-GATE" USING WS-FX(1) WS-R(1) WS-R(2)',2," ".join(show(int(d<GATE),1) for d in dg))
def region():
    by=[0]*5
    for x in range(-5,6):
        for y in range(-5,6):
            for z in range(-5,6):
                d=abs(x)+abs(y)+abs(z)
                if d<=4: by[d]+=1
    t=sum(by)
    return [t,t-1]+by
g.run('Manhattan region (4.2 step 1, V3): offsets with |dx| + |dy| + |dz| <= 4 are 129 including the centre, 128 examined; by depth 1, 6, 18, 38, 66',["0"],'CALL "GC5-OX-REGION" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)',7,show(*region()))
def scan(a,nb):
    H=S=0
    for b in nb:
        if b<0: continue
        if b<a: return 1,H,S
        if b>a: H+=1
        else: S+=1
    return 0,H,S
sc=[(0,[]),(1,[1,1,1,2,-1]),(1,[2,1,3]),(0,[3,3,2,-1,-1,1]),(2,[2,1,3]),(2,[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]),(3,[3,3,-1,-1]),(1,[-1,-1,-1]),(0,[0,0,0,1,2,3,3,0,-1,0,0,0,0,0,0,3])]
def scall(a,nb):
    return setarr('NB',nb+[0]*(16-len(nb)))+'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nCALL "GC5-OX-SCAN" USING WS-I(1) WS-I(2) WS-NBG WS-R(1) WS-R(2) WS-R(3)'%(a,len(nb))
g.case('neighbour scan (4.2 steps 2, 3, V2, V4): a counted neighbour younger than the block aborts; older adds to H, equal to S; waxed or non-copper cells (-1) count nothing; the result is aborted, H, S',[("0",scall(*c),3) for c in sc]," ".join(show(*scan(*c)) for c in sc))
def prob(H,S,a):
    f=f32((H+1)/(H+S+1)); p=f32(f32(f*f)*(f32(0.75) if a==0 else 1.0))
    return p
pr=[(0,0,0),(3,0,2),(1,3,1),(0,5,1),(2,2,0),(4,0,1),(0,7,3)]
g.run('probability (4.2 step 4): f = (H + 1) / (H + S + 1) in single precision, p = f x f x modifier (x 1e6): isolated unaffected block 0.75 (9.1); exposed with H 1, S 3: 0.16 (9.2)',[S(*c) for c in pr],'CALL "GC5-OX-PROB" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-RF(1)',1," ".join(str(int(math.floor(prob(*c)*1e6+0.5))) for c in pr))
def rate(H,S,a):
    p=prob(H,S,a); ch=GATE*p
    return int(math.floor(ch*1e6+0.5)),int(math.floor(10/ch+0.5))
g.run('per random tick chance (x 1e6) and the expected wait in random ticks (x 10): 9.1 isolated copper 0.04266667 per tick, about 23.4 ticks; 9.2 crowded exposed copper 0.0091022',[S(*c) for c in pr[:2]],'CALL "GC5-OX-RATE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join(show(*rate(*c)) for c in pr[:2]))
def engine(d1,a,nb,d2):
    if not d1<GATE: return 0,1
    ab,H,S=scan(a,nb)
    if ab: return 0,1
    return int(d2<prob(H,S,a)),2
ec=[(0.9,0,[],0.1),(0.02,0,[],0.5),(0.02,0,[],0.9),(0.02,1,[0,2],0.0),(0.02,1,[1,1,1,2,-1],0.1),(0.02,1,[1,1,1,2,-1],0.2),(0.02,2,[-1],0.74),(0.02,0,[],0.74)]
def ecall(d1,a,nb,d2):
    return setarr('NB',nb+[0]*(16-len(nb)))+'MOVE %s TO WS-FX(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nMOVE %s TO WS-FX(4)\nCALL "GC5-OX-ENGINE" USING WS-FX(1) WS-I(2) WS-I(3) WS-NBG WS-FX(4) WS-R(1) WS-R(2)'%(d1,a,len(nb),d2)
g.case('changeOverTime (4.1, 4.2, V1, V2): draw 1 at or above the gate stops after one draw; an abort makes no second draw; otherwise the second draw below p advances the block (changed, draws made)',[("0",ecall(*c),2) for c in ec]," ".join(show(*engine(*c)) for c in ec))
g.run('isRandomlyTicking (4.3, V6): a weathering block ticks only when it has a next block; oxidized blocks and waxed blocks do not',["1","0"],'CALL "GC5-OX-TICKING" USING WS-I(1) WS-R(1)',1,"1 0")
W(g,4)
# ===== 5
g=GG(5,'The ladder, the families and the tables','T0619','the weather state ladder, the 15 families, the block ids and names and the next, previous, first and waxed lookups.')
FAM=[("copper_block",1124,"WeatheringCopperFullBlock","Block"),("cut_copper",1134,"WeatheringCopperFullBlock","Block"),("chiseled_copper",1142,"WeatheringCopperFullBlock","Block"),
("cut_copper_stairs",1150,"WeatheringCopperStairBlock","StairBlock"),("cut_copper_slab",1158,"WeatheringCopperSlabBlock","SlabBlock"),("copper_door",1166,"WeatheringCopperDoorBlock","DoorBlock"),
("copper_trapdoor",1174,"WeatheringCopperTrapDoorBlock","TrapDoorBlock"),("copper_grate",1182,"WeatheringCopperGrateBlock","WaterloggedTransparentBlock"),("copper_bulb",1190,"WeatheringCopperBulbBlock","CopperBulbBlock"),
("copper_chest",1198,"WeatheringCopperChestBlock","CopperChestBlock"),("copper_golem_statue",1206,"WeatheringCopperGolemStatueBlock","CopperGolemStatueBlock"),("lightning_rod",1214,"WeatheringLightningRodBlock","LightningRodBlock"),
("copper_bars",392,"WeatheringCopperBarsBlock","IronBarsBlock"),("copper_chain",401,"WeatheringCopperChainBlock","ChainBlock"),("copper_lantern",941,"WeatheringLanternBlock","LanternBlock")]
g.extra=" 01 WS-NAME               PIC X(48).\n"
WP=["","exposed_","weathered_","oxidized_"]
def bname(f,o):
    base=FAM[f-1][0]
    if base=="copper_block":
        return ["copper_block","exposed_copper","weathered_copper","oxidized_copper"][o%4] if o<4 else ["waxed_copper_block","waxed_exposed_copper","waxed_weathered_copper","waxed_oxidized_copper"][o%4]
    return ("waxed_" if o>=4 else "")+WP[o%4]+base
def clamp(x): return max(0,min(3,x))
g.run('WeatherState (5.1): unaffected 0, exposed 1, weathered 2, oxidized 3; next and previous are ordinal plus or minus one clamped at the ends',["0","1","2","3"],'CALL "GC5-LADDER-STEP" USING WS-I(1) WS-R(1) WS-R(2)',2," ".join(show(clamp(s+1),clamp(s-1)) for s in range(4)))
g.run('counts (5.2): 15 collections, 15 x 4 = 60 wax pairs, 15 x 3 = 45 oxidation steps, 8 blocks per family',["0"],'CALL "GC5-LADDER-COUNTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"15/60/45/8")
g.run('families (5.2 table): the first block id of each of the 15 collections, in the table order',[str(i) for i in range(1,16)],'CALL "GC5-FAMILY-FIRST" USING WS-I(1) WS-R(1)',1," ".join(str(f[1]) for f in FAM))
def cl(f,k): return 'MOVE %d TO WS-I(2)\nCALL "GC5-FAMILY-CLASS" USING WS-I(1) WS-I(2) WS-NAME\nMOVE WS-NAME TO WS-T1\nMOVE SPACES TO WS-T2'%k
for k,lab in ((1,'weathering class'),(2,'waxed class')):
    for a in range(0,15,5):
        g.case(lab+' of the families %d to %d (5.2 table; the waxed lantern is a LanternBlock)'%(a+1,a+5),[(str(i+1),cl(i+1,k),'TEXT') for i in range(a,a+5)]," ".join(FAM[i][1+k]+"|" for i in range(a,a+5)))
ids=[(1,0),(1,7),(2,3),(5,4),(13,2),(15,5),(12,1),(4,6),(10,0),(14,7),(3,3),(6,2),(7,1),(8,0),(9,5),(11,6)]
g.run('block id (5.2): the first id plus the offset 0 to 7 (unaffected, exposed, weathered, oxidized, then the four waxed)',[S(*c) for c in ids],'CALL "GC5-BLOCK-ID" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(str(FAM[f-1][1]+o) for f,o in ids))
def nm(f,o): return 'MOVE %d TO WS-I(2)\nCALL "GC5-BLOCK-NAME" USING WS-I(1) WS-I(2) WS-NAME\nMOVE WS-NAME TO WS-T1\nMOVE SPACES TO WS-T2'%o
g.case('names of the copper_block family (5.2): copper_block, exposed_copper, weathered_copper, oxidized_copper, waxed_copper_block, waxed_exposed_copper, waxed_weathered_copper, waxed_oxidized_copper',[("1",nm(1,o),'TEXT') for o in range(8)]," ".join(bname(1,o)+"|" for o in range(8)))
nms=[(f,o) for f in range(2,16) for o in (0,5)]+[(4,3),(4,7),(13,2),(15,6)]
for a in range(0,len(nms),6):
    ch=nms[a:a+6]
    g.case('names of the other families (5.2) %d: prefixes "", exposed_, weathered_, oxidized_ and waxed_ in front'%(a//6+1),[(str(f),nm(f,o),'TEXT') for f,o in ch]," ".join(bname(f,o)+"|" for f,o in ch))
def lookup(i):
    for n,(nmx,first,_,_) in enumerate(FAM):
        if first<=i<first+8: return n+1,i-first,1
    return 0,0,0
lk=[1124,1131,1132,1133,1141,1142,1213,1221,392,408,409,941,948,400,1123,1222,0,780]
g.run('lookup by id: family 1 to 15 and offset for the 8 blocks of a family; ids outside every family (copper ore, stone, 1133 between families) are not found (found 0)',[str(i) for i in lk],'CALL "GC5-BLOCK-LOOKUP" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*lookup(i)) for i in lk))
def nxt(i):
    f,o,fd=lookup(i)
    if not fd: return (0,0,0,0,0,0)
    st=o%4; wx=o>=4
    nx=i+1 if (not wx and st<3) else 0
    pv=i-1 if (not wx and st>0) else 0
    first=i-st if not wx else i
    waxed=i+4 if not wx else 0
    off=i-4 if wx else 0
    tick=int((not wx) and st<3)
    return nx,pv,first,waxed,off,tick
nl=[1124,1125,1126,1127,1128,1131,1135,1210,1214,392,395,396,399,941,942,945,1132,5,0]
for a in range(0,len(nl),5):
    ch=nl[a:a+5]
    g.run('getNext, getPrevious, getFirst (5.1, 4.3), the waxed block (wax on), the unwaxed block (wax off) and isRandomlyTicking, group %d; 0 when there is none: an oxidized block has no next, a waxed block has no previous, getFirst of a waxed block is itself'%(a//5+1),[str(i) for i in ch],'CALL "GC5-BLOCK-NEXT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6," ".join(show(*nxt(i)) for i in ch))
W(g,5)
# ===== 6
g=GG(6,'Per-class hooks','T0621','the conditions of the random tick per class, the door shape update, the chest partner flow and the statue use.')
def runs(cl_,half,tp,be,op):
    if cl_==2: return int(half==0)
    if cl_==3: return int(tp!=2 and be==1 and op==0)
    return 1
rc=[(1,0,0,0,0),(5,0,0,0,0),(2,0,0,0,0),(2,1,0,0,0),(3,0,0,1,0),(3,0,1,1,0),(3,0,2,1,0),(3,0,0,0,0),(3,0,0,1,1),(3,0,1,1,2),(4,0,0,0,0),(1,1,2,0,5)]
g.run('which classes run changeOverTime (6, V7): a door only for the lower half (0; upper 1), a chest when its type is not right (0 single, 1 left, 2 right), the block entity is a chest and no entity has the container open; the statue and the other classes always',[S(*c) for c in rc],'CALL "GC5-HOOK-RUNS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(runs(*c)) for c in rc))
def dsu(half,d,isd,df,sv):
    other=2 if half==0 else 1
    if d==other:
        return 1 if (isd and df) else 2
    if half==0 and d==1 and not sv: return 2
    return 0
dc=[(0,2,1,1,1),(1,1,1,1,1),(0,2,0,1,1),(0,2,1,0,1),(1,1,0,0,1),(1,1,1,0,1),(0,1,0,0,0),(0,1,0,0,1),(1,2,0,0,0),(0,3,1,1,0),(1,3,0,0,0),(1,1,1,1,0)]
g.run('door shape update (6.1, 9.3): from the other half\'s direction a door of the other half gives the neighbour state with this half; a non-door or the same half gives air; the lower half with a down update that cannot survive gives air; else unchanged (0 unchanged, 1 neighbour state, 2 air)',[S(*c) for c in dc],'CALL "GC5-DOOR-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(dsu(*c)) for c in dc))
csu=[(1,1,1),(0,1,1),(1,0,1),(1,1,0),(0,0,0)]
g.run('chest shape update (6.2 (a)): the result is the neighbour\'s block with this chest\'s properties when the changed neighbour is a copper chest, this chest\'s type is not single and the direction is the connected one',[S(*c) for c in csu],'CALL "GC5-CHEST-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"1 0 0 0 0")
def least(both,ns,tw,ow,to,oo):
    if not (both and ns): return (0,0,tw)
    un=int(tw!=ow)
    win=1 if to<=oo else 2
    wx=(tw if win==1 else ow)
    if un: wx=0
    return (un,win,wx)
lc=[(1,1,0,0,0,0),(1,1,1,0,0,1),(1,1,0,1,1,0),(1,1,1,1,3,2),(1,1,1,1,1,1),(1,1,0,0,2,2),(1,1,0,1,0,3),(1,0,1,0,0,0),(0,1,0,1,0,0),(1,1,1,0,2,1)]
g.run('least oxidized chest (6.2 (b), V19, 9.7): for a double chest of two copper chests, exactly one waxed unwaxes both first; the smaller or equal ordinal wins (this chest on a tie); a pair stays waxed only when both were waxed (unwaxed flag, winner 1 this 2 other 0 none, result waxed)',[S(*c) for c in lc],'CALL "GC5-CHEST-LEAST" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)',3," ".join(show(*least(*c)) for c in lc))
def stu(be,ax,un,hc,prod):
    if not be: return (0,0,0,0,0)
    if ax:
        if un: return (1,1,1,prod,1)
        return (0,0,0,0,0)
    if hc: return (0,0,0,0,0)
    return (1,2,0,0,0)
sc_=[(1,1,1,0,1),(1,1,1,0,0),(1,1,0,0,0),(1,0,0,1,0),(1,0,0,0,0),(1,0,1,0,0),(0,1,1,0,0),(1,1,0,1,0)]
g.run('golem statue use (6.3): an axe on an unaffected statue removes the statue, damages the axe by 1, adds the produced entity and removes the block (success); an axe on an aged statue passes; honeycomb passes; any other item changes the pose (result 1 success 0 pass, action 1 remove 2 pose, damage, entity added, block removed)',[S(*c) for c in sc_],'CALL "GC5-STATUE-USE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(show(*stu(*c)) for c in sc_))
g.run('door oxidation (9.3 example): the lower half becomes the next weather state and the upper half takes it with half = upper: the lower half ticks (1), the upper never (0)',["2 0 0 0 0","2 1 0 0 0"],'CALL "GC5-HOOK-RUNS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1,"1 0")
W(g,6)
