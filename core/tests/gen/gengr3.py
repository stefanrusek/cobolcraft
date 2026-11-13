import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
def m(x,n=1000000): return int(math.floor(x*n+0.5))
def GG(n,subj,tasks,desc): return Gen('TEST-GROWTH-29B-3-%d'%n,'29b-3§%d'%n,subj,'Test of 29b part 3 section %d, %s (core/src/growth-29b-3.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_growth_29b_3_%d.cob'%n)
# ===== 1
g=GG(1,'Scope and cross-references','T0561','the block-to-section table of 1.3 and the tag members of 1.4.')
rows=[("grass_block",30),("mycelium",30),("podzol",31),("crimson_nylium",40),("warped_nylium",40),("netherrack",43)]
rows+=[(x+"_leaves",50) for x in ["oak","birch","jungle","acacia","dark_oak","spruce","cherry","pale_oak","red_poplar","orange_poplar","yellow_poplar","azalea","flowering_azalea"]]
rows+=[("mangrove_leaves",57),("leaf_litter",58),("snow",60),("snow_block",65),("powder_snow",80),("ice",71),("packed_ice",72),("blue_ice",72),("frosted_ice",73),("sponge",101),("wet_sponge",102),("magma_block",103),("stone",0),("dirt",0),("leaves",0)]
rows1=rows[:16]; rows2=rows[16:]
g.case('registry blocks of 1.3 map to their section x10 (3.1 is 31, 4.3 is 43, 5.7 is 57, 10.1 is 101); other names to 0 (part 1)',[("0",'MOVE "minecraft:%s" TO WS-T1\nCALL "GC3-PART" USING WS-T1 WS-R(1)'%k,1) for k,_ in rows1]," ".join(str(s) for _,s in rows1))
g.case('registry blocks of 1.3 map to their section x10 (part 2)',[("0",'MOVE "minecraft:%s" TO WS-T1\nCALL "GC3-PART" USING WS-T1 WS-R(1)'%k,1) for k,_ in rows2]," ".join(str(s) for _,s in rows2))
tags={1:["snow","snow_block","powder_snow"],2:["crimson_nylium","warped_nylium"],3:["ice","packed_ice","barrier"],4:["honey_block","soul_sand","mud"],5:[k for k,s_ in rows if s_ in (50,57)]}
probe=["snow","snow_block","powder_snow","crimson_nylium","warped_nylium","ice","packed_ice","barrier","honey_block","soul_sand","mud","oak_leaves","mangrove_leaves","stone"]
def tagcall(k):
    return 'MOVE "minecraft:%s" TO WS-T1\n'%k+"\n".join('MOVE %d TO WS-I(15)\nCALL "GC3-IN-TAG" USING WS-I(15) WS-T1 WS-R(%d)'%(t,t) for t in range(1,6))
g.case('tag members of 1.4 (snow, nylium, cannot_support_snow_layer, support_override_snow_layer, leaves: tags 1 to 5), one group per probe block',[("0",tagcall(k),5) for k in probe]," ".join("/".join(str(int(k in tags[t])) for t in range(1,6)) for k in probe))
W(g,1)
# ===== 2
g=GG(2,'Shared tests','T0563','the light-gets-through test, face cover, the draws of 2.2, the direction orders and the breadth-first traversal of 2.4.')
def li(fe,te,cv,df): return df if (fe and te) else (16 if cv else df)
lic=[(1,1,0,0),(1,1,0,1),(1,1,0,15),(1,0,1,15),(1,0,1,0),(1,0,0,0),(1,1,0,1),(0,1,0,0),(0,1,1,0),(0,0,0,7),(0,0,1,7)]
g.run('light dampening into (2.1): both shapes empty give the default; otherwise 16 when the two faces cover the unit square (a snow layer above, a bottom slab) else the default (air 0, leaves 1, opaque 15, a top slab 0)',[S(*c) for c in lic],'CALL "GC3-LIGHT-INTO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(li(*c)) for c in lic))
g.run('survives is a result below 15: air 0, leaves 1, 14 yes; 15 and 16 no',["0","1","14","15","16"],'CALL "GC3-SURVIVES" USING WS-I(1) WS-R(1)',1,"1 1 1 0 0")
g.extra=" 01 WS-FA.\n    05 WS-FA-N BINARY-LONG.\n    05 WS-FA-V BINARY-LONG OCCURS 16 TIMES.\n 01 WS-FB.\n    05 WS-FB-N BINARY-LONG.\n    05 WS-FB-V BINARY-LONG OCCURS 16 TIMES.\n"
def rects(fa,fb):
    s='INITIALIZE WS-FA WS-FB\n'
    for nm,f in (("A",fa),("B",fb)):
        s+='MOVE %d TO WS-F%s-N\n'%(len(f),nm)
        k=1
        for r in f:
            for v in r:
                s+='MOVE %d TO WS-F%s-V(%d)\n'%(v,nm,k); k+=1
    return s+'CALL "GC3-FACES-COVER" USING WS-FA WS-FB WS-R(1)'
def cover(fa,fb):
    cell=set()
    for r in fa+fb:
        for x in range(r[0],r[2]):
            for y in range(r[1],r[3]): cell.add((x,y))
    return int(len(cell)==256)
FULL=(0,0,16,16)
fcs=[([],[]),([FULL],[]),([],[FULL]),([(0,0,16,15)],[]),([(0,0,16,15)],[(0,15,16,16)]),([(0,0,8,16)],[(8,0,16,16)]),([(0,0,8,16)],[(7,0,15,16)]),([(0,0,16,8),(0,8,8,16)],[(8,8,16,16)]),([(0,0,16,8)],[(0,8,16,16),(3,3,4,4)]),([(0,0,16,8)],[(0,9,16,16)])]
g.case('faces cover (2.1 mergedFaceOccludes): true at once with a full face, else when the union of the rectangles (pixels, 16 x 16) covers the square; gaps and empty faces do not',[("0",rects(a,b),1) for a,b in fcs]," ".join(str(cover(a,b)) for a,b in fcs))
nic=[(1,2,5,3),(1,5,2,0),(1,2,2,0),(1,-1,1,1),(2,-1,1,2),(2,0,0,0),(3,5,0,4),(3,1,0,0)]
def ni(mo,a,b,d):
    if mo==1:
        if a>=b: return a,0,0
        return a+d,1,b-a+1
    if mo==2: return a+d,1,b-a+1
    return d+1,1,a
g.run('draws of 2.2: Mth.nextInt is a without a draw when a >= b, else a + nextInt(b - a + 1); nextIntBetweenInclusive always draws (between(-1, 1) is nextInt(3) minus 1); a list pick is list[nextInt(size)] (index from 1)',[S(*c) for c in nic],'CALL "GC3-NEXT-INT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%ni(*c) for c in nic))
V=[(0,-1,0),(0,1,0),(0,0,-1),(0,0,1),(-1,0,0),(1,0,0)]
H=[(0,0,-1),(1,0,0),(0,0,1),(-1,0,0)]
dc=[(1,i) for i in range(1,7)]+[(2,i) for i in range(1,5)]
g.run('orders (2.3): Direction.values() is down, up, north, south, west, east; the horizontal plane is north, east, south, west (north is z - 1)',[S(*c) for c in dc],'CALL "GC3-DIRECTION" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%(V if a==1 else H)[b-1] for a,b in dc))
g.extra+=" 01 WS-NBG.\n    05 WS-NB BINARY-LONG OCCURS 384 TIMES.\n 01 WS-VDG.\n    05 WS-VD BINARY-LONG OCCURS 64 TIMES.\n 01 WS-ORG.\n    05 WS-OR BINARY-LONG OCCURS 64 TIMES.\n"
def bfs(md,mc,start,adj,vd):
    q=[(start,0)]; vis=set(); cnt=0; order=[]; qi=0
    while qi<len(q):
        n,d=q[qi]; qi+=1
        if n in vis: continue
        vis.add(n); order.append(n)
        v=vd.get(n,1)
        if v==2: continue
        if v==3: return cnt,order
        cnt+=1
        if cnt>=mc: return cnt,order
        if d>=md: continue
        for x in adj.get(n,[]): q.append((x,d+1))
    return cnt,order
def bcall(md,mc,start,adj,vd):
    s='INITIALIZE WS-NBG WS-VDG WS-ORG\n'
    for n,l in adj.items():
        for j,x in enumerate(l): s+='MOVE %d TO WS-NB(%d)\n'%(x,(n-1)*6+j+1)
    for n in range(1,9): s+='MOVE %d TO WS-VD(%d)\n'%(vd.get(n,1),n)
    s+='MOVE %d TO WS-I(10)\nMOVE %d TO WS-I(11)\nMOVE %d TO WS-I(12)\n'%(md,mc,start)
    s+='CALL "GC3-BFS" USING WS-I(10) WS-I(11) WS-I(12) WS-NBG WS-VDG WS-R(1) WS-R(2) WS-ORG\n'
    s+='PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6\n    MOVE WS-OR(WS-K) TO WS-R(WS-K + 2)\nEND-PERFORM'
    return s
chain={1:[2],2:[1,3],3:[2,4],4:[3,5],5:[4]}
diam={1:[2,3],2:[4],3:[4],4:[]}
bc=[(2,10,1,chain,{}),(9,2,1,chain,{}),(9,10,1,chain,{2:2}),(9,10,1,chain,{2:3}),(9,10,1,diam,{}),(9,1,1,chain,{}),(0,10,1,chain,{}),(9,10,1,chain,{}),(1,10,2,chain,{})]
def bexp(*a):
    c,o=bfs(*a); o=(o+[0]*6)[:6]
    return "%d/%d/"%(c,len([x for x in o if x]))+"/".join(map(str,o))
g.case('breadth-first traversal (2.4): FIFO queue, a position taken twice is dropped, SKIP is visited but not counted or expanded, STOP returns the count, count >= maxCount returns at once, depth >= maxDepth is not expanded; count, nodes taken, then their order',[("0",bcall(*c),8) for c in bc]," ".join(bexp(*c) for c in bc))
W(g,2)
# ===== 3
g=GG(3,'Snowy blocks, grass, mycelium, podzol','T0565','the snowy property (3.1), survival, decay and spread (3.2), grass bone meal (3.3).')
snc=[(2,1,0),(2,0,1),(2,0,0),(2,1,1),(1,1,0),(3,1,0),(6,1,1),(4,0,1)]
g.run('snowy block shape update (3.1): from UP the state takes snowy = the neighbour is in tag snow; every other direction leaves the state (the new snowy, or -1 for unchanged); placement takes the block above',[S(*c) for c in snc],'CALL "GC3-SNOWY-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(c[1] if c[0]==2 else -1) for c in snc))
g.run('snowy placement (3.1): snowy is whether the block at clickedPos.above() is in tag snow',["0","1"],'CALL "GC3-SNOWY-PLACE" USING WS-I(1) WS-R(1)',1,"0 1")
def alive(snow,lay,full,d):
    if snow and lay==1: return 1
    if full: return 0
    return int(d<15)
ac=[(1,1,0,16),(1,2,0,16),(1,1,1,16),(0,0,1,0),(0,0,0,0),(0,0,0,14),(0,0,0,15),(0,0,0,16),(1,8,0,16),(1,1,1,0)]
g.run('canStayAlive (3.2): one layer of snow above passes at once; a source fluid above fails; else the light-into result must be below 15 (two layers give 16: dead)',[S(*c) for c in ac],'CALL "GC3-STAY-ALIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(alive(*c)) for c in ac))
g.run('canPropagate (3.2): canStayAlive and the fluid above is not water',["1 0","1 1","0 0","0 1"],'CALL "GC3-PROPAGATE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
def st(dirt,al,br):
    if not dirt: return 0
    if not al: return 1
    if br<9: return 2
    return 3
stc=[(1,0,15),(1,0,0),(1,1,8),(1,1,9),(1,1,15),(0,1,15),(0,0,0)]
g.run('spreading random tick (3.2): no dirt key does nothing; step 1 decays to dirt when it cannot stay alive; step 2 stops under light 9 at the cell above; else the four attempts (0 nothing, 1 decay, 2 dark, 3 spread)',[S(*c) for c in stc],'CALL "GC3-SPREAD-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(st(*c)) for c in stc))
def tg(dx,dy,dz,dirt,prop,sn):
    place=int(dirt and prop)
    return dx-1,dy-3,dz-1,place,(sn if place else 0)
tgc=[(0,0,0,1,1,0),(2,4,2,1,1,1),(1,3,1,1,1,1),(1,2,1,1,1,0),(0,4,2,0,1,0),(2,0,0,1,0,1),(1,1,1,0,0,0)]
g.run('target of an attempt (3.2): the draws nextInt(3), nextInt(5), nextInt(3) give dx -1..1, dy -3..1, dz -1..1; the target changes only for plain dirt that canPropagate, with snowy = the block above it is in tag snow',[S(*c) for c in tgc],'CALL "GC3-SPREAD-TARGET" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join("%d/%d/%d/%d/%d"%tg(*c) for c in tgc))
g.run('mycelium client particle (3.2): nextInt(10) of 0 adds a particle at y + 1.1 (x 10: 11), any other draw none',["0","1","9"],'CALL "GC3-MYCELIUM-ANIM" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/11 0/0 0/0")
g.run('grass bone meal target (3.3): valid when the block above is air and the position above is inside the build height; success is always true',["1 1","1 0","0 1","0 0"],'CALL "GC3-GRASS-VALID" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"1/1 0/1 0/1 0/1")
g.run('grass bone meal steps (3.3): i / 16 steps, 0 for 0 to 15, 1 for 16 to 31, 7 for 112 to 127',["0","15","16","31","32","111","112","127"],'CALL "GC3-GRASS-STEPS" USING WS-I(1) WS-R(1)',1,"0 0 1 1 2 6 7 7")
def trunc(a,b): return int(a/b)
gsc=[(0,0,0,0),(2,2,2,2),(1,1,1,1),(0,0,2,0),(0,2,2,2),(2,0,2,0),(0,2,1,1),(2,2,0,0),(1,0,2,1),(1,2,2,1)]
g.run('grass walk step (3.3): dx = between(-1, 1), dy = (between(-1, 1) x nextInt(3)) / 2 truncated toward zero (-1 for -2, +1 for 2, else 0), dz = between(-1, 1); draws given as the nextInt values',[S(*c) for c in gsc],'CALL "GC3-GRASS-STEP" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%(c[0]-1,trunc((c[1]-1)*c[2],2),c[3]-1) for c in gsc))
g.run('grass stopBonemealSpread (3.3): true when the block below p is not this grass block or the collision shape at p is a full block',["1 0","0 0","1 1","0 1"],'CALL "GC3-GRASS-STOP" USING WS-I(1) WS-I(2) WS-R(1)',1,"0 1 1 1")
def ge(air,short,d1,valid,inh,d2,empty,pf):
    draws=0; grow=0; res=0
    if short:
        draws+=1
        if d1<0.1 and valid: grow=1
    if air and inh:
        draws+=1
        if d2<0.125: res=3 if empty else 1
        elif pf: res=2
    return grow,res,draws
gec=[(1,0,0.5,0,1,0.5,0,1),(1,0,0.5,0,1,0.1,0,1),(1,0,0.5,0,1,0.124,1,1),(1,0,0.5,0,1,0.125,0,1),(1,0,0.5,0,1,0.9,0,0),(1,0,0.5,0,0,0.1,0,1),(0,0,0.5,0,1,0.1,0,1),(0,1,0.05,1,1,0.5,0,1),(0,1,0.05,0,1,0.5,0,1),(0,1,0.1,1,1,0.5,0,1),(0,1,0.5,1,0,0.5,0,1)]
g.run('grass placeBonemealEffect (3.3): short grass draws nextFloat() < 0.1 and grows when valid, then only air inside the height goes on (the state read before); a draw below 0.125 places a biome flower (an empty list stops), else the grass_bonemeal feature when present; results 1 flower, 2 patch, 3 empty list; grow, result, draws',[S(*c) for c in gec],'CALL "GC3-GRASS-EFFECT" USING WS-I(1) WS-I(2) WS-FX(3) WS-I(4) WS-I(5) WS-FX(6) WS-I(7) WS-I(8) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%ge(*c) for c in gec))
W(g,3)
# ===== 4
g=GG(4,'Nylium and netherrack','T0567','canBeNylium decay (4.1), nylium bone meal (4.2), netherrack bone meal (4.3).')
g.run('canBeNylium (4.1): the light-into result below 15 keeps nylium (no snow exception: one snow layer gives 16 and reverts it); a result of 15 or more reverts it to netherrack on the random tick',["0","1","14","15","16"],'CALL "GC3-NYLIUM-TICK" USING WS-I(1) WS-R(1) WS-R(2)',2,"0/1 0/1 0/1 1/0 1/0")
g.extra=" 01 WS-CUBE.\n    05 WS-CB BINARY-LONG OCCURS 27 TIMES.\n"
g.run('nylium bone meal (4.2): valid when the block above is air and inside the build height, success always; the feature nylium_bonemeal is placed above when it is inside the height and the feature exists',["1 1 1","1 1 0","0 1 1","1 0 1","0 0 0"],'CALL "GC3-NYLIUM-BONE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 1/1/0 0/1/1 0/1/0 0/1/0")
cubes=[[0]*27,[1]+[0]*26,[2]+[0]*26,[0]*13+[1]+[0]*13,[0]*13+[1]+[0]*12+[2],[3]*27,[0]*26+[2]]
def cube(c): return int(1 in c)+int(2 in c), int(1 in c), int(2 in c)
def ccall(c):
    s='INITIALIZE WS-CUBE\n'
    for i,v in enumerate(c): s+='MOVE %d TO WS-CB(%d)\n'%(v,i+1)
    return s+'CALL "GC3-CUBE-NYLIUM" USING WS-CUBE WS-R(1) WS-R(2) WS-R(3)'
g.case('netherrack cube scan (4.3): the 27 positions of pos +- 1, a cell is 1 warped_nylium, 2 crimson_nylium, else another block; count of nylium blocks, warped found, crimson found',[("0",ccall(c),3) for c in cubes]," ".join("%d/%d/%d"%cube(c) for c in cubes))
g.run('netherrack bone meal target (4.3): valid when the state above propagates skylight down and the cube holds a nylium block; success always',["1 1","1 0","0 1","1 5","0 0"],'CALL "GC3-NETHERRACK-VALID" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,"1/1 0/1 0/1 1/1 0/1")
def nr(w,c,b):
    if w and c: return (1 if b else 2),1
    if w: return 1,0
    if c: return 2,0
    return 0,0
nrc=[(1,1,1),(1,1,0),(1,0,0),(1,0,1),(0,1,1),(0,1,0),(0,0,0),(0,0,1)]
g.run('netherrack bone meal (4.3): both kinds found: nextBoolean() true gives warped, false crimson (one draw); only warped: warped; only crimson: crimson; neither: nothing (1 warped, 2 crimson; draws)',[S(*c) for c in nrc],'CALL "GC3-NETHERRACK-PERFORM" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%nr(*c) for c in nrc))
W(g,4)
# ===== 5
g=GG(5,'Leaves','T0569','distance, triggers, decay and drops (5.1 to 5.4), the variants (5.5), client behaviour (5.6), mangrove leaves (5.7), leaf litter (5.8).')
g.extra=" 01 WS-NBRS.\n    05 WS-NB BINARY-LONG OCCURS 6 TIMES.\n"
g.run('leaf state (5.1): distance 1 to 7, persistent and waterlogged give 28 states; light dampening 1',["0"],'CALL "GC3-LEAF-STATES" USING WS-R(1) WS-R(2)',2,"28/1")
def da(log,has,d): return (0 if log else (d if has else -1)), (0 if log else (d if has else 7))
dac=[(1,0,0),(1,1,4),(0,1,4),(0,1,7),(0,0,0)]
g.run('getOptionalDistanceAt (5.2): a log state is 0, else the distance of a leaves state, else empty (-1), which getDistanceAt reads as 7',[S(*c) for c in dac],'CALL "GC3-LEAF-DIST-AT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%da(*c) for c in dac))
def upd(ns):
    m=7;ex=0
    for d in ns:
        ex+=1; m=min(m,d+1)
        if m==1: break
    return m,ex
uc=[[7]*6,[0,7,7,7,7,7],[7,0,7,7,7,7],[3,7,7,7,7,7],[7,7,7,7,7,5],[6,7,7,7,7,7],[6]*6,[2,1,0,0,0,0],[7,7,7,7,7,0]]
g.run('updateDistance (5.2): 1 + the smallest neighbour distance over Direction.values() capped at 7, the loop ending early at 1 (distance, neighbours examined)',[S(*c) for c in uc],'MOVE WS-I(1) TO WS-NB(1)\nMOVE WS-I(2) TO WS-NB(2)\nMOVE WS-I(3) TO WS-NB(3)\nMOVE WS-I(4) TO WS-NB(4)\nMOVE WS-I(5) TO WS-NB(5)\nMOVE WS-I(6) TO WS-NB(6)\nCALL "GC3-LEAF-UPDATE" USING WS-NBRS WS-R(1) WS-R(2)',2," ".join("%d/%d"%upd(c) for c in uc))
g.run('leaf placement (5.3 PL): persistent true, waterlogged from the fluid at the clicked position, then the updated distance',["0 3","1 1","1 7"],'CALL "GC3-LEAF-PLACE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"1/0/3 1/1/1 1/1/7")
def lsu(w,nd,own):
    d=nd+1
    return int(w), int(d!=1 or own!=d), (1 if (d!=1 or own!=d) else 0)
lc=[(0,0,1),(0,0,2),(0,1,2),(1,0,1),(1,7,7),(0,6,7),(0,0,7)]
g.run('leaf shape update (5.3 SU): waterlogged schedules the water tick; only the sender is read: d = its distance + 1, and a block tick of delay 1 is scheduled unless d is 1 and the own distance is 1',[S(*c) for c in lc],'CALL "GC3-LEAF-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%lsu(*c) for c in lc))
g.run('leaf random ticks (5.3, 5.4): ticking only at distance 7 and not persistent; then the loot table with no tool is dropped and the block removed without a game event (ticking, drops, removes, event)',["7 0","7 1","6 0","1 0","1 1"],'CALL "GC3-LEAF-RANDOM" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"1/1/1/0 0/0/0/0 0/0/0/0 0/0/0/0 0/0/0/0")
g.run('decay drops with no tool (5.4, fortune 0): the leaves item never; sapling 5% (50000 per million), sticks 2% and 1 to 2 of them, apple 0.5%: kind 1 leaves item, 2 sapling, 3 stick, 4 apple (chance, count min, count max)',["1","2","3","4"],'CALL "GC3-LEAF-DROP" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"0/0/0 50000/1/1 20000/1/2 5000/1/1")
V=[("oak_leaves",1,100,1,0,0),("birch_leaves",1,100,1,0,0),("jungle_leaves",1,100,1,0,0),("acacia_leaves",1,100,1,0,0),("dark_oak_leaves",1,100,1,0,0),("spruce_leaves",2,0,0,0,0),("mangrove_leaves",4,100,1,0,0),("cherry_leaves",3,1000,2,0,0),("pale_oak_leaves",3,200,3,0,0),("red_poplar_leaves",3,100,4,0,1),("orange_poplar_leaves",3,100,5,0,1),("yellow_poplar_leaves",3,100,6,0,1),("azalea_leaves",3,100,1,-9399763,0),("flowering_azalea_leaves",3,100,1,-9399763,0)]
for part,vs in (("a",V[:7]),("b",V[7:])):
    g.case('variants (5.5, %s): class (1 tinted particle, 2 plain, 3 untinted, 4 mangrove), leafParticleChance x 10000, particle (1 tinted_leaves, 2 cherry, 3 pale_oak, 4 red_poplar, 5 orange_poplar, 6 yellow_poplar), fixed colour, ambient sound'%part,[("0",'MOVE "minecraft:%s" TO WS-T1\nCALL "GC3-LEAF-VARIANT" USING WS-T1 WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)'%v[0],5) for v in vs]," ".join("/".join(map(str,v[1:])) for v in vs))
g.run('rain drip (5.6 step 2): raining draws nextInt(15) (not drawn when dry); a 1 spawns dripping_water unless the block below occludes with a sturdy UP face (spawn, draws)',["1 1 0","1 1 1","1 0 0","1 14 0","0 1 0"],'CALL "GC3-LEAF-DRIP" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,"1/1 0/1 0/1 0/1 0/0")
def amb(has,d,nb):
    if not has: return 0,0
    if d!=0: return 0,1
    a=b=0
    for i,c in enumerate(nb):
        if c&1: a+=1
        if c&2: b+=1
        if a==1 and b==3: return 1,1
    return 0,1
ac=[(0,0,[1,2,2,2]),(1,5,[1,2,2,2]),(1,0,[1,2,2,2]),(1,0,[2,2,2,1]),(1,0,[2,2,2,2]),(1,0,[1,1,2,2]),(1,0,[0,2,2,2]),(1,0,[1,0,2,2]),(1,0,[1,2,2,3])]
def acall(a):
    return 'MOVE %d TO WS-NB(1)\nMOVE %d TO WS-NB(2)\nMOVE %d TO WS-NB(3)\nMOVE %d TO WS-NB(4)\nMOVE %d TO WS-I(15)\nMOVE %d TO WS-I(16)\nCALL "GC3-LEAF-AMBIENT" USING WS-I(15) WS-I(16) WS-NBRS WS-R(1) WS-R(2)'%(tuple(a[2])+(a[0],a[1]))
g.case('ambient sound (5.6 step 3): only a variant with a sound draws nextInt(300); a 0 walks the four neighbours counting the satisfying tag (bit 1) and the same block (bit 2) and plays when a is exactly 1 and b exactly 3 (play, draws)',[("0",acall(a),2) for a in ac]," ".join("%d/%d"%amb(*a) for a in ac))
fc=[(0.5,0.01,0),(0.005,0.01,0),(0.01,0.01,0),(0.0,0.01,1),(0.0,0.01,0),(0.05,0.1,0),(0.099,0.1,0),(0.1,0.1,0)]
g.run('falling leaves (5.6 step 4): nextFloat() >= chance stops, a full UP collision face below stops, else the particle spawns',[S(*c) for c in fc],'CALL "GC3-LEAF-FALL" USING WS-FX(1) WS-FX(2) WS-I(3) WS-R(1)',1," ".join(str(int(c[0]<c[1] and not c[2])) for c in fc))
g.run('face culling (5.6): with cutoutLeaves false a neighbour that is any leaves block skips the face (1), otherwise the generic rule applies (0); cutout on is the default',["1 1","1 0","0 1","0 0"],'CALL "GC3-LEAF-CULL" USING WS-I(1) WS-I(2) WS-R(1)',1,"0 0 1 0")
g.run('mangrove leaves bone meal (5.7): valid when the block below is air, no height test, success always; performs setBlock of a hanging propagule age 0 below with flags 2',["1","0"],'CALL "GC3-MANGROVE-BONE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"1/1/2/0 0/1/2/0")
g.run('leaf litter (5.8): survives on a block with a sturdy UP face; no random tick, scheduled tick or decay (survive, random tick, scheduled tick)',["1","0"],'CALL "GC3-LITTER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"1/0/0 0/0/0")
W(g,5)
# ===== 6
g=GG(6,'Snow layers and the snow block','T0571','shapes (6.1), survival, shape update, random tick, replacement and placement (6.2), drops (6.4), the snow block (6.5).')
g.run('snow shapes (6.1): outline, support and visual height 2 x layers pixels, collision 2 x (layers - 1); shade 0.2 at 8 layers else 1.0 (x 10); land pathfinding below 5 layers; view blocking from 8 layers',[str(k) for k in range(1,9)],'CALL "GC3-SNOW-SHAPE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join("%d/%d/%d/%d/%d"%(2*k,2*(k-1),2 if k==8 else 10,int(k<5),int(k>=8)) for k in range(1,9)))
def sv(cn,ov,fu,s8):
    if cn: return 0
    if ov: return 1
    return int(fu or s8)
svc=[(1,0,1,0),(1,1,1,1),(0,1,0,0),(0,0,1,0),(0,0,0,1),(0,0,0,0),(1,0,0,1)]
g.run('snow survival (6.2): not on a cannot_support_snow_layer block; always on a support_override block; else a full UP face or a snow layer of 8 layers below',[S(*c) for c in svc],'CALL "GC3-SNOW-SURVIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(sv(*c)) for c in svc))
g.run('snow shape update (6.2 SU): a failed canSurvive returns air (1), else the generic rule (0)',["0","1"],'CALL "GC3-SNOW-SU" USING WS-I(1) WS-R(1)',1,"1 0")
g.run('snow random tick (6.2 RT, 6.4): only block light above 11 melts it (sky light is ignored): dropResources, removeBlock, game event block_destroy; the drop call yields nothing (melt, drops yielded, event)',["0","11","12","15"],'CALL "GC3-SNOW-TICK" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"0/0/0 0/0/0 1/0/1 1/0/1")
def rep(it,n,rc,fu):
    if it and n<8: return fu if rc else 1
    return int(n==1)
rpc=[(1,3,1,1),(1,3,1,0),(1,3,0,0),(1,8,1,1),(0,1,1,1),(0,2,1,1),(1,8,0,0),(0,8,0,0),(1,1,1,0)]
g.run('snow canBeReplaced (6.2): holding snow below 8 layers: when replacing the clicked block only the UP face, else true; otherwise only a single layer',[S(*c) for c in rpc],'CALL "GC3-SNOW-REPLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(rep(*c)) for c in rpc))
g.run('snow placement (6.2): snow already at the clicked position gains a layer up to 8; otherwise the generic placement (0)',["1 1","1 7","1 8","0 3"],'CALL "GC3-SNOW-PLACE" USING WS-I(1) WS-I(2) WS-R(1)',1,"2 8 8 0")
def dr(silk,ent,l):
    if not ent: return 0,0
    if not silk: return 1,l
    return (2,l) if l<8 else (3,1)
drc=[(0,1,1),(0,1,8),(1,1,3),(1,1,7),(1,1,8),(0,0,4),(1,0,8)]
g.run('snow drops (6.4): the pool needs an entity (a player break; the block-light melt has none); without silk touch snowball x layers, with it the snow item x layers (1 to 7) or snow_block at 8 (item 1 snowball, 2 snow, 3 snow_block; count 1 for the block as the table names no count)',[S(*c) for c in drc],'CALL "GC3-SNOW-DROPS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%dr(*c) for c in drc))
g.run('snow block (6.5): a plain block that requires the correct tool for drops; no random tick, no melting (random tick, correct tool)',["0"],'CALL "GC3-SNOW-BLOCK" USING WS-R(1) WS-R(2)',2,"0/1")
W(g,6)
# ===== 7
g=GG(7,'Ice','T0573','IceBlock (7.1), packed and blue ice (7.2), FrostedIceBlock (7.3).')
g.extra=" 01 WS-NBRS.\n    05 WS-NB BINARY-LONG OCCURS 6 TIMES.\n"
g.run('ice random tick (7.1): block light above 11 minus the dampening (1) melts it, so above 10; sky light never melts',[S(l,1) for l in (0,10,11,12,15)],'CALL "GC3-ICE-TICK" USING WS-I(1) WS-I(2) WS-R(1)',1,"0 0 1 1 1")
g.run('ice melt (7.1): water_evaporates removes the block with no event; otherwise water, neighborChanged and the game event block_destroy (action 1 removed, 2 water; neighbour update; event)',["1","0"],'CALL "GC3-ICE-MELT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,"1/0/0 2/1/1")
def idst(pr,ev,tag,liq):
    if pr: return 0
    if ev: return 1
    return 2 if (tag or liq) else 0
icc=[(1,1,1,1),(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1),(0,0,1,1),(0,0,0,0)]
g.run('ice playerDestroy (7.1): a prevents_ice_melting tool (silk touch) leaves it; else evaporation removes it; else water when the block below is in ice_melts_when_destroyed_above OR a liquid (0 nothing, 1 removed, 2 water)',[S(*c) for c in icc],'CALL "GC3-ICE-DESTROY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(idst(*c)) for c in icc))
g.run('ice loot (7.1): the table yields ice only with silk touch (1 ice, 0 nothing)',["1","0"],'CALL "GC3-ICE-LOOT" USING WS-I(1) WS-R(1)',1,"1 0")
g.run('packed and blue ice (7.2): friction x 1000 0.98 and 0.989, strength x 10 0.5 and 2.8; neither random-ticks, melts or reacts; a face is culled against the same block for blue ice (HalfTransparentBlock) only (packed 1, blue 2)',["1","2"],'CALL "GC3-ICE-PLAIN" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"980/5/0/0 989/28/0/1")
g.run('frosted ice constants (7.3): MAX_AGE 3, NEIGHBORS_TO_AGE 4, NEIGHBORS_TO_MELT 2, 4 states (age 0 to 3), not random-ticking',["0"],'CALL "GC3-FROSTED-CONST" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,"3/4/2/4/0")
def few(fl,lim):
    c=0
    for f in fl:
        if f:
            c+=1
            if c>=lim: return 0
    return 1
fwc=[([0]*6,4),([1,1,1,0,0,0],4),([1,1,1,1,0,0],4),([1,1,1,1,1,1],4),([0,0,0,0,0,1],2),([1,0,0,0,0,1],2),([1,0,0,0,0,0],2),([0]*6,2)]
g.run('fewerNeighboursThan (7.3): counts frosted_ice neighbours over Direction.values(); false as soon as the count reaches the limit, else true',[S(*(c[0]+[c[1]])) for c in fwc],'CALL "GC3-FROSTED-FEWER" USING WS-ISG WS-I(7) WS-R(1)',1," ".join(str(few(*c)) for c in fwc))
g.run('slightlyMelt (7.3): below age 3 the age rises by 1 (flags 2) and false is returned; at age 3 it melts and returns true (new age, melted)',["0","1","2","3"],'CALL "GC3-FROSTED-SLIGHT" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/0 2/0 3/0 3/1")
g.run('frosted ice delays (7.3): placement U(60, 120) and every reschedule U(20, 40): kind 1 or 2 with the draw nextInt(range)',["1 0","1 60","2 0","2 20"],'CALL "GC3-FROSTED-DELAY" USING WS-I(1) WS-I(2) WS-R(1)',1,"60 120 20 40")
g.run('frosted ice light (7.3 step 2): the block light in the End, else getMaxLocalRawBrightness',["1 3 9","0 3 9","1 12 2","0 12 2"],'CALL "GC3-FROSTED-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"3 9 12 2")
def ft(draw,f4,L,age,damp):
    ev=int(draw!=0)
    if not (draw==0 or f4): return 1,age,ev
    if L>11-age-damp:
        if age<3: return 2,age+1,ev
        return 3,age,ev
    return 1,age,ev
ftc=[(0,0,15,0,1),(0,0,10,0,1),(0,0,11,0,1),(0,0,9,1,1),(0,0,10,1,1),(1,0,15,0,1),(1,1,15,0,1),(2,1,15,2,1),(1,1,15,3,1),(0,0,15,3,1),(1,1,0,0,1),(0,1,2,2,1)]
g.run('frosted ice scheduled tick (7.3 ST): nextInt(3) is drawn; continue on a 0 or fewer than 4 frosted neighbours (the neighbour test only when the draw is not 0); then light above 11 - age - dampening ages the block (outcome 2, reschedule) or at age 3 melts it (outcome 3, neighbours aged, no reschedule); else outcome 1 reschedules (outcome, age, neighbour test made)',[S(*c) for c in ftc],'CALL "GC3-FROSTED-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%ft(*c) for c in ftc))
def fn(fr,age):
    if not fr: return 0,age
    if age<3: return 1,age+1
    return 2,age
fnc=[(0,0),(1,0),(1,2),(1,3)]
g.run('frosted ice neighbour of a melt (7.3 ST step 4): a frosted_ice neighbour is slightly melted at once: aged and its tick scheduled with U(20, 40) (1), or melted (2, no tick); other blocks nothing (action, age)',[S(*c) for c in fnc],'CALL "GC3-FROSTED-NEIGHBOUR" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2," ".join("%d/%d"%fn(*c) for c in fnc))
g.run('frosted ice neighbour update (7.3 NU): a changed frosted_ice neighbour with fewer than 2 frosted neighbours melts the block at once; otherwise the generic rule',["1 1","1 0","0 1","0 0"],'CALL "GC3-FROSTED-NU" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0 0")
W(g,7)
# ===== 8
g=GG(8,'Powder snow','T0575','the registry facts and the snow-tag and dampening consequences this part adds (the rest is 44 part x1 section 2.2).')
g.run('powder snow registry (8): not random-ticking, strength 0.25 (x 100), dynamicShape, noOcclusion, never a redstone conductor; in tag snow',["0"],'CALL "GC3-POWDER-REG" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,"0/25/1/1/0/1")
g.run('default light dampening (8): a solid-render state 15, else 0 when it propagates skylight down, else 1 (powder snow, a full outline shape, is 1)',["1 0","0 1","0 0"],'CALL "GC3-DAMPENING" USING WS-I(1) WS-I(2) WS-R(1)',1,"15 0 1")
g.run('powder snow above grass (8, 3.1): the snowy property turns on from UP (shape update 2); light-into gives the above state its own dampening 1 (noOcclusion makes both shapes empty), below 15, so the spreader stays alive (snowy, result, alive)',["2 1 0"],'CALL "GC3-SNOWY-SU" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)\nMOVE 1 TO WS-I(5)\nMOVE 1 TO WS-I(6)\nMOVE 0 TO WS-I(7)\nMOVE 1 TO WS-I(8)\nCALL "GC3-LIGHT-INTO" USING WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(2)\nCALL "GC3-STAY-ALIVE" USING WS-I(9) WS-I(10) WS-I(11) WS-R(2) WS-R(3)',3,"1/1/1")
W(g,8)
