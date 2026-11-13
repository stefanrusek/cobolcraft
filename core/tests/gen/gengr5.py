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
