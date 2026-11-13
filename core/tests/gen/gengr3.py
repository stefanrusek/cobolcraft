import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT=sys.argv[1] if len(sys.argv)>1 else "core/tests"
ONLY=set(int(a) for a in sys.argv[2:])
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
