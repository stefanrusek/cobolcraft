import sys,math
from fractions import Fraction as Fr
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-4-enchanting-loom-stonecutter-cartography.md, with the java.util.Random LCG of 10 section 2 written out again here.
class JR:
    M=(1<<48)-1
    def __init__(s,seed): s.s=((seed&((1<<64)-1))^0x5DEECE66D)&s.M
    def nxt(s,bits):
        s.s=(s.s*0x5DEECE66D+0xB)&s.M
        return s.s>>(48-bits)
    def nextInt(s,b):
        if b&-b==b: return (b*s.nxt(31))>>31
        while True:
            bits=s.nxt(31); v=bits%b
            if bits-v+(b-1)<(1<<31): return v
def GX(prog,sec,subj,tasks,desc,extra=''):
    return Gen10(prog,sec,subj,'Test of %s section, %s (%s): %s'%(sec,subj,tasks,desc),' 01 WS-NM                PIC X(32).\n'+extra)
ST=' 01 WS-ST                BINARY-DOUBLE UNSIGNED.\n'
def W(g,n,name=None):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/'+(name or 'test_menu_40_4_%s.cob'%n))
def col(v): return v-(1<<32) if v>=1<<31 else v
M32=(1<<32)
# ===== 1
g=GG('TEST-MENU-40-4-1','40-4§1','Common rules used by all four menus','T1039','menu type ids, slot counts, blocks, titles, close, take sounds and the data wire (core/src/menu-40-4.cob).',None)
ID={1:(13,2,38,10,0),2:(18,4,40,1,2),3:(23,3,39,0,2),4:(24,2,38,1,1)}
run(g,'rule 1, 3, 8: type ids enchantment 13, loom 18, cartography_table 23, stonecutter 24; own slots, totals, data slots and the title label y shift 0, 2, 2, 1 (kind 1 enchanting 2 loom 3 cartography 4 stonecutter -> type, own, total, data, y shift)','MN4-IDENT','i',5,[(k,) for k in (1,2,3,4)],lambda k:ID[k])
BL={1:('enchanting_table','container.enchant'),2:('loom','container.loom'),3:('cartography_table','container.cartography_table'),4:('stonecutter','container.stonecutter')}
runt(g,'rule 2, 3: the bound block and the default title key','MN4-BLOCK','i',[(k,) for k in (1,2,3,4)],lambda k:BL[k])
TI={1:'Enchant',2:'Loom',3:'Cartography Table',4:'Stonecutter'}
runt(g,'rule 3: title key and English text','MN4-TITLE','i',[(k,) for k in (1,2,3,4)],lambda k:(BL[k][1],TI[k]))
run(g,'rule 2: stillValid is the block-bound helper: true with the NULL access, otherwise block and range (null access, block ok, in range)','MN3-VALID','iii',1,[(n,b,r) for n in (0,1) for b in (0,1) for r in (0,1)],lambda n,b,r:int(n or (b and r)))
CL={1:(2,0),2:(3,0),3:(2,1),4:(1,1)}
run(g,'rule 4: close returns the input slots (enchanting 2, loom 3, cartography 2, stonecutter 1) and removes the result item silently for the stonecutter and the cartography table only (input slots, result removed)','MN4-CLOSE','i',2,[(k,) for k in (1,2,3,4)],lambda k:CL[k])
run(g,'rule 5: a take sound plays only when the game time differs from the remembered one, which then becomes the current time (game time, last sound time -> play, new last)','MN4-SOUND','ii',2,[(100,0),(100,100),(101,100),(0,0),(5,4),(5,5)],lambda t,l:(int(t!=l),t if t!=l else l))
run(g,'rule 6: a data slot value is a signed 16-bit short on the wire; the enchantment seed 0x12345678 arrives as 22136, 0x0001ABCD as -21555, 0x00018000 as -32768','MN2-DATA-WIRE','i',1,[(0x12345678,),(0x1ABCD,),(0x18000,),(-1,),(32767,),(32768,),(30,)],lambda v:wire(v))
W(g,1)
# ===== 2
g=GX('TEST-MENU-40-4-2','40-4§2','Enchanting table','T1041','slots, data slots, slotsChanged, button, quick-move, screen rows, tooltip, galactic names and the book (core/src/menu-enchanting.cob).',ST)
def eslot(s):
    if s==0: return (1,15,47,1,0)
    if s==1: return (1,35,47,0,1)
    if 2<=s<=37:
        x,y=std_inv(s-2); return (2,x,y,0,0)
    return (0,0,0,0,0)
run(g,'M2: slot 0 at (15, 47) holds one item whatever its stack size, slot 1 at (35, 47) takes lapis lazuli and has the empty icon, then the standard block 2 to 37 (part, x, y, stack cap, lapis slot)','ENCH-SLOT','i',5,[(s,) for s in (0,1,2,10,28,29,37,38)],eslot)
run(g,'M2: mayPlace is the default for slot 0 (any item) and lapis lazuli only for slot 1 (slot, is lapis lazuli)','ENCH-MAYPLACE','ii',1,[(0,0),(0,1),(1,0),(1,1)],lambda s,l:1 if s==0 else l)
run(g,'2.4 step 1: enchantable needs the enchantable component and an enchantments component that is present and empty (component, present, empty)','ENCH-ENCHANTABLE','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:int(a and b and c))
OFF=[(dx,dy,dz) for dy in (0,1) for dx in range(-2,3) for dz in range(-2,3) if abs(dx)==2 or abs(dz)==2]
def tdiv(a): return int(a/2)
for lo in (1,9,17,25):
  run(g,'2.4 step 2 (17 6.5), offsets %d to %d of 32: 32 bookshelf offsets, dx and dz from -2 to 2 on the outer ring, dy 0 or 1; the transmitter block is at (dx / 2, dy, dz / 2) with integer division (offset index 1 to 32 -> dx, dy, dz, tx, ty, tz)'%(lo,lo+7),'ENCH-OFFSET','i',6,[(i,) for i in range(lo,lo+8)],lambda i:OFF[i-1]+(tdiv(OFF[i-1][0]),OFF[i-1][1],tdiv(OFF[i-1][2])))
run(g,'2.4 step 2: an offset counts when both the provider and the transmitter blocks are right (power so far, provider, transmitter -> power)','ENCH-POWER-ADD','iii',1,[(a,b,c) for a in (0,7) for b in (0,1) for c in (0,1)],lambda a,b,c:a+int(b and c))
run(g,'wire: the data slots are 0 to 2 costs, 3 seed, 4 to 6 clue ids, 7 to 9 clue levels (property -> group 1 cost 2 seed 3 clue 4 level clue, index)','ENCH-PROP','i',2,[(i,) for i in range(10)],lambda i:(1,i) if i<3 else (2,0) if i==3 else (3,i-4) if i<7 else (4,i-7))
def ebtn(i,lap,lv,inf,cost,ie):
    if i<0 or i>=3: return (0,0)
    need=i+1
    if (lap<need) and not inf: return (0,need)
    ok=cost>0 and not ie and ((lv>=need and lv>=cost) or inf)
    return (int(ok),need)
rows=[(0,2,5,0,2,0),(1,2,5,0,6,0),(1,0,5,0,6,0),(0,0,5,0,2,0),(0,2,0,0,2,0),(2,3,30,0,30,0),(2,2,30,0,30,0),(3,9,50,0,9,0),(-1,9,50,0,9,0),(1,0,0,1,6,0),(1,0,0,1,6,1),(0,5,5,0,0,0),(0,5,5,0,2,1),(2,3,2,0,30,0),(2,0,31,1,0,0)]
run(g,'M4, 7.2: id outside 0 to 2 returns false; lapis needs id + 1 (not for infinite materials); valid when the cost > 0, the item is present and the level is at least id + 1 and at least the cost (or infinite) (id, lapis, level, infinite, cost, item empty -> valid, lapis needed)','ENCH-BUTTON','iiiiii',2,rows,ebtn)
def eef(lv,need,inf,lap,le,book):
    if le: return (0,lv,lap,0,0,0)
    nl=max(lv-need,0)
    nlap=lap if inf else max(lap-need,0)
    return (1,nl,nlap,int(book),1,int(nlap==0))
rows=[(5,1,0,2,0,0),(30,3,0,3,0,1),(2,3,0,3,0,0),(5,1,0,2,1,0),(40,2,1,0,0,0),(10,2,0,5,0,1),(1,1,0,1,0,0)]
run(g,'M4 effect, 7.2, 7.4: the level drops by need = id + 1 (not by the cost, never below 0), a book becomes an enchanted book, lapis loses need (not with infinite materials) and an emptied stack clears the slot, the seed is renewed; an empty offer list changes nothing (level, need, infinite, lapis, list empty, is a book -> performed, level, lapis, book transformed, seed renewed, lapis slot emptied)','ENCH-EFFECT','iiiiii',6,rows,eef)
def eqk(s,lap,e0):
    if s in (0,1): return (1,2,38,1,0)
    if 2<=s<=37 and lap: return (2,1,2,1,0)
    if 2<=s<=37 and e0: return (3,0,1,0,1)
    return (0,0,0,0,0)
run(g,'M5: slots 0 and 1 go to [2, 38) in reverse; lapis from the inventory only to [1, 2); another item as ONE copy into slot 0 when it is empty, else nothing (source slot, holds lapis, slot 0 empty -> rule, first, end, reverse, single copy)','ENCH-QUICK','iii',5,[(0,0,0),(1,0,0),(9,1,0),(9,1,1),(9,0,1),(9,0,0),(37,0,1),(38,0,1)],eqk)
def erow(i,l,t): return (l+60,t+14+19*i,108,19,l+61,t+15+19*i,l+80,t+16+19*i,l+166,t+23+19*i)
run(g,'M7: row i at (60, 14 + 19 i) of size 108 x 19, the level icon at (61, 15 + 19 i), the clue text at (80, 16 + 19 i), the cost right-aligned to 166 at y 23 + 19 i (i, leftPos, topPos -> row x, y, w, h, icon x, y, text x, y, cost right x, cost y)','ENCH-SCREEN-ROW','iii',10,[(i,339,157) for i in (0,1,2)],erow)
def eclk(i,mx,my,l,t):
    rx=mx-(l+60); ry=my-(t+14+19*i)
    return (int(0<=rx<108 and 0<=ry<19),int(0<=rx<108 and 0<=ry<17))
rows=[(0,339+60,157+14,339,157),(0,339+167,157+32,339,157),(0,339+168,157+14,339,157),(0,339+59,157+14,339,157),(0,339+100,157+31,339,157),(0,339+100,157+30,339,157),(0,339+100,157+33,339,157),(1,339+100,157+14+19,339,157),(2,339+100,157+14+37,339,157),(2,339+100,157+14+38+17,339,157)]
run(g,'2.9 click and tooltip: the click rectangle is 108 x 19 at (60, 14 + 19 i), the tooltip rectangle only 17 high (i, mouse x, mouse y, leftPos, topPos -> click, tooltip)','ENCH-CLICK','iiiii',2,rows,eclk)
def ers(cost,gold,lv,inf,i,hov):
    if cost==0: return (0,0,0,80,16+19*i,23+19*i)
    en=(gold>=i+1 and lv>=cost) or inf
    if not en: return (1,col(0xFF342F25),col(0xFF407F10),80,16+19*i,23+19*i)
    return (3 if hov else 2,col(0xFFFFFF80) if hov else col(0xFF685E4A),col(0xFF80FF20),80,16+19*i,23+19*i)
rows=[(0,3,30,0,0,0),(2,0,30,0,0,0),(2,1,1,0,0,0),(2,1,5,0,0,0),(2,1,5,0,0,1),(6,2,5,0,1,1),(6,2,6,0,1,0),(30,3,30,0,2,1),(30,0,0,1,2,0),(30,2,40,0,2,0)]
run(g,'2.9 per-row drawing: cost 0 only the disabled sprite; disabled when lapis or level is short (name #FF342F25, cost #FF407F10); enabled normal #FF685E4A, highlighted #FFFFFF80, cost #FF80FF20; infinite materials always enabled (cost, lapis count, level, infinite, i, pointer inside -> state 0 empty 1 disabled 2 enabled 3 highlighted, name colour, cost colour, name x, name y, cost y)','ENCH-ROW-STATE','iiiiii',6,rows,ers)
run(g,'2.9: the name is generated for the width 86 - textWidth(cost string)','ENCH-NAME-WIDTH','i',1,[(6,),(12,),(0,),(18,)],lambda w:86-w)
def etip(c,lc,cv,inr,inf,lv,gold,i):
    show=int(inr and c>0 and lc>=0 and cv)
    if not show: return (0,0,0)
    if inf: return (1,0,0)
    if lv<c: return (1,1,0)
    return (1,2,int(gold>=i+1))
rows=[(5,2,1,1,0,10,3,0),(0,2,1,1,0,10,3,0),(5,-1,1,1,0,10,3,0),(5,2,0,1,0,10,3,0),(5,2,1,0,0,10,3,0),(5,2,1,1,1,0,0,0),(20,2,1,1,0,10,3,1),(20,2,1,1,0,25,1,1),(20,2,1,1,0,25,2,1),(30,2,1,1,0,30,3,2)]
run(g,'2.9 tooltip: shown when the pointer is in the row, the cost > 0, the clue level is not negative and the clue id is valid; then, unless infinite, a level requirement line when the level is short, else the lapis line (gray with enough lapis) and the level line (cost, clue level, clue valid, pointer in the 17-high rectangle, infinite, level, lapis count, i -> shown, lines 0 none 1 requirement 2 lapis and level, lapis gray)','ENCH-TIP','iiiiiiii',3,rows,etip)
run(g,'2.9 getFullname: red for a curse, else gray; the level suffix is omitted only for level 1 of an enchantment with maximum level 1 (is a curse, level, max level -> red, suffix)','ENCH-FULLNAME','iii',2,[(c,l,m) for c in (0,1) for (l,m) in ((1,1),(1,3),(2,3),(5,5))],lambda c,l,m:(c,int(not(l==1 and m==1))))
WORDS='the elder scrolls klaatu berata niktu xyzzy bless curse light darkness fire air earth water hot dry cold wet ignite snuff embiggen twist shorten stretch fiddle destroy imbue galvanize enchant free limited range of towards inside sphere cube self other ball mental physical grow shrink demon elemental spirit animal creature beast humanoid undead fresh stale phnglui mglwnafh cthulhu rlyeh wgahnagl fhtagn baguette'.split()
assert len(WORDS)==62
def sg(seed):
    return 'CALL "ENCH-STATE-SEED" USING WS-I(1) WS-ST'
def ename(seed,rows):
    r=JR(seed); out=[]
    for _ in range(rows):
        n=r.nextInt(2)+3; w=[r.nextInt(62) for _ in range(n)]+[0]*(4-n)
        out.append(show(n,*w))
    return " ".join(out)
for seeds in ((12345,),(0,),(-5,),(22136,),(-21555,)):
    s=seeds[0]
    calls=[(str(s),'CALL "ENCH-STATE-SEED" USING WS-I(1) WS-ST\nCALL "ENCH-NAME-DRAW" USING WS-ST WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5)]
    calls+=[(str(s),'CALL "ENCH-NAME-DRAW" USING WS-ST WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5)]
    g.case('galactic names (2.9): n = nextInt(2) + 3 words, each nextInt(62), from a generator seeded with the client seed %d; the second name continues the same stream (count, word indexes)'%s,calls,ename(s,2))
runt(g,'galactic names (2.9): the 62 words, index 0 to 61 (the first, an early, a late and the last)','ENCH-WORD','i',[(i,) for i in (0,1,29,33,60,61)],lambda i:(WORDS[i],WORDS[i]))
def lt(seed,isb,size):
    r=JR(seed) if False else None
    return None
def post(seed,pre,isb,size):
    r=JR(seed)
    for _ in range(pre): r.nextInt(50)
    idx=-1
    if isb and size>1: idx=r.nextInt(size)
    return idx
for seed,pre,isb,size in ((100,0,1,3),(100,2,1,3),(7,1,1,2),(7,0,0,3),(7,0,1,1),(-9,0,1,4)):
    g.case('getEnchantmentList step 3 (2.5, 7.4): a book with more than one entry loses one at nextInt(size) of the same stream, anything else keeps the list (seed %d, %d earlier draws, book %d, size %d)'%(seed,pre,isb,size),
       [(str(seed),'CALL "ENCH-STATE-SEED" USING WS-I(1) WS-ST\n'+''.join('CALL "ENCH-SKIP" USING WS-ST\n' for _ in range(pre))+'MOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nCALL "ENCH-LIST-POST" USING WS-ST WS-I(2) WS-I(3) WS-R(1)'%(isb,size),1)],str(post(seed,pre,isb,size)))
for seed,size in ((5,1),(5,3),(-77,2),(5,0)):
    r=JR(seed); exp=r.nextInt(size) if size>0 else -1
    g.case('clue (2.4 step 5): one clue is picked by nextInt(size) of the same random, -1 for an empty list (seed %d, size %d)'%(seed,size),[(str(seed),'CALL "ENCH-STATE-SEED" USING WS-I(1) WS-ST\nMOVE %d TO WS-I(2)\nCALL "ENCH-CLUE-DRAW" USING WS-ST WS-I(2) WS-R(1)'%size,1)],str(exp))
def bstep(fl,ft,fa,op,ac):
    op=op+0.2 if ac else op-0.2
    op=max(0.0,min(1.0,op))
    d=max(-0.2,min(0.2,(ft-fl)*0.4))
    fa=fa+(d-fa)*0.9
    fl=fl+fa
    return (sc(op,1000000),sc(fa,1000000),sc(fl,1000000))
rows=[(0.0,3.0,0.0,0.0,1),(0.5,3.0,0.1,0.8,1),(2.9,3.0,0.0,0.9,1),(5.0,3.0,0.0,0.2,0),(3.0,3.0,0.0,0.0,0),(1.0,-2.0,-0.1,1.0,1)]
run(g,'2.10 tickBook steps 2 to 4: open moves by 0.2 towards 1 with any cost, else towards 0, kept within [0, 1]; d = clamp((flipT - flip) x 0.4, -0.2, 0.2), flipA += (d - flipA) x 0.9, flip += flipA (flip, flipT, flipA, open, any cost -> open, flipA, flip, x 1e6)','ENCH-BOOK-STEP','ffffi',3,rows,bstep)
def flipt(seed,fl6,ft):
    r=JR(seed); n=0
    while True:
        ft+=r.nextInt(4)-r.nextInt(4); n+=1
        if not((ft-1)*1000000<=fl6<=(ft+1)*1000000): break
    return (ft,n)
for seed,fl6,ft in ((1,0,0),(1,0,10),(2,5000000,5),(3,-2500000,-2),(9,900000,1)):
    exp=flipt(seed,fl6,ft)
    g.case('2.10 tickBook step 1: flipT += nextInt(4) - nextInt(4) at least once, repeated while flip is within [flipT - 1, flipT + 1] (seed %d, flip x 1e6 %d, flipT %d)'%(seed,fl6,ft),[(str(seed),'CALL "ENCH-STATE-SEED" USING WS-I(1) WS-ST\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nCALL "ENCH-BOOK-FLIPT" USING WS-ST WS-I(2) WS-I(3) WS-R(1) WS-R(2)'%(fl6,ft),2)],show(*exp))
def frac(x): return x-math.floor(x)
def bdraw(oo,o,of,f,pt):
    oo_=oo+(o-oo)*pt; ff=of+(f-of)*pt
    p1=max(0.0,min(1.0,frac(ff+0.25)*1.6-0.3)); p2=max(0.0,min(1.0,frac(ff+0.75)*1.6-0.3))
    return (sc(oo_,1000000),sc(ff,1000000),sc(p1,1000000),sc(p2,1000000),sc(1.25*oo_,1000000),sc((1-oo_)*0.2,1000000),sc((1-oo_)*0.1,1000000),sc((1-oo_)*0.25,1000000),sc(-(1-oo_)*90-90,1000000))
rows=[(0.0,1.0,0.0,0.0,0.5),(1.0,1.0,2.0,2.5,0.0),(0.5,0.75,1.25,1.5,0.5),(0.0,0.0,0.0,0.0,0.0),(1.0,1.0,0.5,0.75,1.0),(0.25,0.5,3.5,3.75,0.25)]
run(g,'2.10 drawing and pose: o = lerp(pt, oOpen, open), f = lerp(pt, oFlip, flip); page flips p = clamp(frac(f + 0.25 or 0.75) x 1.6 - 0.3, 0, 1); openness 1.25 o; translate ((1 - o) x 0.2, (1 - o) x 0.1, (1 - o) x 0.25); rotate Y by -(1 - o) x 90 - 90 degrees (all x 1e6)','ENCH-BOOK-DRAW','fffff',9,rows,bdraw)
PI=3.1415927
def banim(o2,p1,p2): return tuple(sc(v,1000000) for v in (PI+o2,-o2,o2,-o2,o2-2*o2*p1,o2-2*o2*p2,math.sin(o2)))
run(g,'2.10 setupAnim: left lid yRot pi + o2, right lid -o2, left pages o2, right pages -o2, the flip pages o2 - 2 o2 p1 and o2 - 2 o2 p2, the x of the page parts sin(o2) (x 1e6)','ENCH-BOOK-ANIM','fff',7,[(0.0,0.0,0.0),(1.25,0.5,0.25),(0.625,1.0,0.0),(1.25,0.0,1.0)],banim)
PARTS=[(-6,-5,-0.005,6,10,0.005,0,0,-1,0),(0,-5,-0.005,6,10,0.005,16,0,1,0),(-1,-5,0,2,10,0.005,12,0,0,1.5707964),(0,-4,-0.99,5,8,1,0,10,0,0),(0,-4,-0.01,5,8,1,12,10,0,0),(0,-4,0,5,8,0.005,24,10,0,0),(0,-4,0,5,8,0.005,24,10,0,0)]
run(g,'2.10 model geometry: the seven cubes (origin, size x 1000, texture origin u, v, part offset z x 1000, part rotation about Y x 1e6): left lid, right lid, seam, left pages, right pages, flip pages 1 and 2','ENCH-BOOK-PART','i',10,[(i,) for i in range(1,8)],lambda i:tuple(sc(v,1000) for v in PARTS[i-1][:6])+PARTS[i-1][6:8]+(sc(PARTS[i-1][8],1000),sc(PARTS[i-1][9],1000000)))
W(g,2)
# ===== enchanting named test
g=GX('TEST-MENU-ENCHANTING-TABLE','enchanting_table','offers','T1139','bookshelf power, the three offers with their level and lapis costs, the enchantment seed, applying the chosen offer and the experience cost (core/src/menu-enchanting.cob).',ST)
def costs(seed,B,N):
    if not N: return (0,0,0)
    r=JR(seed); b=min(B,15); out=[]
    for i in range(3):
        base=r.nextInt(8)+1+(b>>1)+r.nextInt(b+1)
        c=[max(base//3,1),base*2//3+1,max(base,b*2)][i]
        out.append(c if c>=i+1 else 0)
    return tuple(out)
seeds=[0,1,2,3,12345,-1,-777,2147483647,-2147483648,987654321]
for B in (0,1,5,15,40):
    rows=[(s,B,1) for s in seeds]
    run(g,'costs with %d bookshelves (2.4 step 3 and 4, 7.1): base = nextInt(8) + 1 + (b >> 1) + nextInt(b + 1) per option from one stream, options max(base / 3, 1), base x 2 / 3 + 1, max(base, 2 b), a cost below i + 1 is 0 (seed, shelves, enchantable -> three costs)'%B,'ENCH-COSTS','iii',3,rows[:5],costs)
    run(g,'costs with %d bookshelves, more seeds (the cap of 15 applies inside the cost function)'%B,'ENCH-COSTS','iii',3,rows[5:],costs)
run(g,'an item without the enchantable component has every cost 0 and draws nothing (2.4 step 4) (seed, shelves, enchantable)','ENCH-COSTS','iii',3,[(5,15,0),(0,0,0)],costs)
run(g,'7.1: with 15 shelves option 2 always costs 30; option 0 is 2 to 10 and option 1 is 6 to 21 (30 seeds)','ENCH-COSTS','iii',3,[(s,15,1) for s in range(20,26)],costs)
def lseed(s,i):
    v=(s+i)%M32
    return v-M32 if v>=1<<31 else v
run(g,'getEnchantmentList step 1: the list is drawn from seed + slot index, an int addition widened to long, so it wraps at the int range (seed, slot)','ENCH-LIST-SEED','ii',1,[(100,0),(100,2),(-1,1),(2147483647,1),(2147483647,2),(-2147483648,0)],lseed)
run(g,'7.3: the seed travels as a signed 16-bit short; 0x12345678 arrives as 22136 and 0x0001ABCD as -21555, 0x00018000 as -32768','MN2-DATA-WIRE','i',1,[(0x12345678,),(0x1ABCD,),(0x18000,)],lambda v:wire(v))
rows=[(0,1,0,2,0,0),(1,2,5,0,6,0),(2,3,30,0,30,0),(2,3,29,0,30,0),(1,1,10,0,6,0)]
run(g,'7.2: the offers need id + 1 lapis and id + 1 levels (and the cost as a threshold): buttons 0, 1 and 2 with lapis 1, 2, 3 (id, lapis, level, infinite, cost, item empty -> valid, lapis needed)','ENCH-BUTTON','iiiiii',2,rows,ebtn)
run(g,'7.2: choosing option 0 with level 5 and 2 lapis leaves level 4 and 1 lapis; the level payment is id + 1, not the cost (level, need, infinite, lapis, list empty, book)','ENCH-EFFECT','iiiiii',6,[(5,1,0,2,0,0),(30,3,0,3,0,1),(3,3,0,3,0,0)],eef)
run(g,'7.4: a book is replaced by an enchanted book and option 2 costs 3 lapis and 3 levels, never 30 (level, need, infinite, lapis, list empty, book)','ENCH-EFFECT','iiiiii',6,[(30,3,0,3,0,1),(35,3,0,8,0,1),(2,3,0,8,0,1)],eef)
W(g,'enchanting_table','test_menu_enchanting_table.cob')
# ===== 3
g=GG('TEST-MENU-40-4-3','40-4§3','Loom','T1043','slots, selectable patterns, slotsChanged, button, take, quick-move, screen state, grid and scroll arithmetic (core/src/menu-40-4.cob).',None)
def lslot(s):
    own={0:(13,26),1:(33,26),2:(23,45),3:(143,57)}
    if s in own: return (1,)+own[s]
    if 4<=s<=39:
        x,y=std_inv(s-4); return (2,x,y)
    return (0,0,0)
run(g,'M2: banner (13, 26), dye (33, 26), pattern (23, 45), result (143, 57), then the standard block 4 to 39 (part, x, y)','MN4-LOOM-SLOT','i',3,[(s,) for s in (0,1,2,3,4,30,31,39,40)],lslot)
def lmp(s,b,d,dc,p,pc):
    return [b,int(d and dc),int(p and pc),0][s] if 0<=s<=3 else 1
run(g,'M2: the banner slot takes any banner; the dye slot an item of the tag loom_dyes with the dye component; the pattern slot loom_patterns with provides_banner_patterns; the result none (slot, banner, in dye tag, has dye, in pattern tag, has patterns)','MN4-LOOM-MAYPLACE','iiiiii',1,[(0,1,0,0,0,0),(0,0,1,1,1,1),(1,0,1,1,0,0),(1,0,1,0,0,0),(1,0,0,1,0,0),(2,0,0,0,1,1),(2,0,0,0,1,0),(2,0,0,0,0,1),(3,1,1,1,1,1)],lmp)
def lsel(pe,hc,tc,cc):
    if pe: return tc
    return cc if hc else 0
run(g,'3.4: an empty pattern slot lists the no_item_required patterns (32, or none when the tag is missing); a pattern item lists its provides_banner_patterns set, none without the component (pattern empty, has component, tag size, set size -> list size)','MN4-LOOM-SELECTABLE','iiii',1,[(1,0,32,0),(1,0,0,0),(0,1,32,1),(0,1,32,4),(0,0,32,5)],lsel)
def lch(be,de,oi,osz,nsz,fi,lay):
    if be or de: return (0,-1,1,0)
    wv=0<=oi<osz
    if nsz==1: idx=0; ch=1
    elif not wv: idx=-1; ch=0
    elif fi>=0: idx=fi; ch=1
    else: idx=-1; ch=0
    setup=0
    if ch:
        if lay>=6: idx=-1
        else: setup=1
    return (nsz,idx,int(not setup),setup)
rows=[(1,0,3,32,32,3,0),(0,1,3,32,32,3,0),(0,0,-1,0,32,-1,0),(0,0,14,32,1,-1,0),(0,0,14,32,32,3,0),(0,0,14,32,32,-1,0),(0,0,40,32,32,3,0),(0,0,14,32,32,3,6),(0,0,14,32,32,3,5),(0,0,2,0,1,0,6),(0,0,0,5,5,0,0)]
run(g,'3.5: with the banner or dye empty the list, the selection and the result are cleared; a one-entry list selects index 0; an old valid selection survives at its new position, else -1; a banner with 6 layers clears the selection and the result (banner empty, dye empty, old index, old list size, new list size, index of the old pattern in the new list, banner layers -> list size, selected, result empty, set up result)','MN4-LOOM-CHANGED','iiiiiii',4,rows,lch)
run(g,'3.6: the button id is an index into the selectable patterns: in range it selects and sets up the result and returns true; otherwise false with no change (id, list size -> ok, selected, set up)','MN4-LOOM-BUTTON','ii',3,[(14,32),(0,32),(31,32),(32,32),(-1,32),(0,0)],lambda i,s:(1,i,1) if 0<=i<s else (0,-1,0))
def lres(lay,dn,be,de):
    if be or de or dn: return -1
    return lay+1
run(g,'3.5 setupResultSlot: the result is one banner with the old layers and one new layer appended last in the dye colour; nothing without a banner, a dye or a dye colour (banner layers, dye colour is null, banner empty, dye empty -> result layers or -1)','MN4-LOOM-RESULT','iiii',1,[(0,0,0,0),(5,0,0,0),(2,1,0,0),(2,0,1,0),(2,0,0,1)],lres)
run(g,'3.7: taking removes one banner and one dye, never the pattern item; an emptied banner or dye slot resets the selection to -1 (banner count, dye count -> banner, dye, reset)','MN4-LOOM-TAKE','ii',3,[(3,1),(1,5),(1,1),(2,2)],lambda b,d:(b-1,d-1,int(b-1==0 or d-1==0)))
def lq(s,ba,dy,pt):
    if s==3: return (1,4,40,1,1)
    if 0<=s<=2: return (2,4,40,0,0)
    if ba: return (3,0,1,0,0)
    if dy: return (4,1,2,0,0)
    if pt: return (5,2,3,0,0)
    if 4<=s<=30: return (6,31,40,0,0)
    return (7,4,31,0,0)
run(g,'3.8: the result goes to [4, 40) in reverse with onQuickCraft, inputs to [4, 40); an inventory banner, dye or pattern item to its own slot even when occupied; else main to hotbar and hotbar to main (slot, banner, dye, pattern -> rule, first, end, reverse, onQuickCraft)','MN4-LOOM-QUICK','iiii',5,[(3,0,0,0),(0,0,0,0),(2,0,0,0),(10,1,0,0),(10,0,1,0),(10,0,0,1),(10,0,0,0),(30,0,0,0),(31,0,0,0),(39,0,0,0)],lq)
def lscr(ch,pd,be,de,mx,sz,sr):
    d=pd
    if ch: d=int((not be) and (not de) and (not mx) and sz>0)
    tr=(sz+3)//4
    rs=int(sr>=tr)
    return (d,rs)
rows=[(1,0,0,0,0,32,0),(1,1,1,0,0,32,0),(1,1,0,1,0,32,0),(1,0,0,0,1,32,0),(1,0,0,0,0,0,0),(0,1,0,0,0,32,2),(0,0,0,0,0,8,8),(0,1,0,0,0,16,4),(0,1,0,0,0,17,4),(0,1,0,0,0,17,5)]
run(g,'3.10 containerChanged: when an input changed the grid is shown for a banner, a dye, fewer than 6 layers and a non-empty list; the scroll resets when startRow reaches the row count ceil(size / 4) (inputs changed, previous display, banner empty, dye empty, has max layers, list size, start row -> display, reset scroll)','MN4-LOOM-STATE','iiiiiii',2,rows,lscr)
def lgr(sr,sz,r,c):
    ix=(sr+r)*4+c
    return (ix,int(ix<sz),60+14*c,13+14*r)
run(g,'3.10 grid cells: index = (startRow + r) x 4 + c, the grid stops at the first index beyond the list; the cell origin is (60 + 14 c, 13 + 14 r) (start row, list size, r, c -> index, in list, x, y)','MN4-LOOM-CELL','iiii',4,[(0,32,0,0),(2,32,1,2),(4,32,3,3),(7,32,3,3),(0,5,1,1),(0,5,1,0)],lgr)
def lcs(ix,sel,hov): return (2 if ix==sel else 1 if hov else 0,int(ix!=sel and hov),int(ix!=sel and hov))
run(g,'3.10 cell state: selected has priority; a hovered unselected cell is highlighted with a tooltip and the pointing hand (index, selected index, hovered -> sprite 0 normal 1 highlighted 2 selected, tooltip, hand)','MN4-LOOM-CELL-STATE','iii',3,[(3,3,1),(3,3,0),(4,3,1),(4,3,0),(0,-1,0)],lcs)
run(g,'3.10 scroll bar: active when the grid is shown and the list has more than 16 entries (display, list size)','MN4-LOOM-ACTIVE','ii',1,[(1,32),(1,16),(1,17),(0,32)],lambda d,s:int(d and s>16))
run(g,'3.10 thumb: y = 13 + int(41 x scrollOffs) (scrollOffs, x 1e6 stored as a float)','MN4-LOOM-THUMB','f',1,[(0.0,),(0.5,),(1.0,),(0.99,),(0.25,)],lambda s:13+int(41*s))
def ldrag(my,top,tr,so0):
    if tr-4<=0: return (0,sc(so0,1000000),0)
    so=max(0.0,min(1.0,(my-(top+13)-7.5)/41.0))
    return (1,sc(so,1000000),max(int(so*(tr-4)+0.5),0))
rows=[(157+13+7,157,8,0.0),(157+13+7+20,157,8,0.0),(157+13+7+41,157,8,0.0),(0,157,8,0.3),(157+100,157,8,0.3),(157+30,157,3,0.4),(157+30,157,4,0.4),(157+13+27,157,12,0.0)]
run(g,'3.10 drag: only with more than 4 rows; scrollOffs = clamp((mouseY - (topPos + 13) - 7.5) / 41, 0, 1) and startRow = max(int(scrollOffs x (rows - 4) + 0.5), 0); E7.5: scrollOffs 0.5 over 8 rows gives startRow 2 (mouse y, topPos, rows, scrollOffs before -> consumed, scrollOffs x 1e6, start row)','MN4-LOOM-DRAG','iiif',3,rows,ldrag)
def lwh(so,sy,tr):
    so=max(0.0,min(1.0,so-sy/(tr-4)))
    return (sc(so,1000000),max(int(so*(tr-4)+0.5),0))
run(g,'3.10 wheel: scrollOffs = clamp(scrollOffs - scrollY / (rows - 4), 0, 1), startRow as for the drag (scrollOffs, scroll y, rows -> scrollOffs x 1e6, start row)','MN4-LOOM-WHEEL','ffi',2,[(0.0,-1.0,8),(0.5,1.0,8),(1.0,-1.0,5),(0.25,0.5,6),(0.9,-3.0,6)],lwh)
def lrect(rx,ry,cell):
    return (int(0<=rx and rx<12 and 0<=ry and ry<56),int(0<=rx<12 and -4<=ry<52))
run(g,'3.10 click on the scroll bar: scrolling starts in x [119, 131), y [9, 65) while the track is drawn at y 13 to 69 (x, y relative to the window -> starts scrolling, over the drawn track)','MN4-LOOM-SCROLL-HIT','ii',2,[(119,9),(130,64),(131,20),(118,20),(125,8),(125,65),(125,13),(125,68),(125,69)],lambda x,y:(int(119<=x<131 and 9<=y<65),int(119<=x<131 and 13<=y<69)))
def luv(u0,v0,u1,v1):
    du=u1-u0; dv=v1-v0
    return (sc(u0,1000000),sc(u0+du*21/64,1000000),sc(v0+dv/64,1000000),sc(v0+dv/64+dv*40/64,1000000))
run(g,'3.10 banner on a button: the 5 x 10 box shows u from U0 to U0 + du x 21 / 64 and v from V0 + dv / 64 to V0 + dv / 64 + dv x 40 / 64 (U0, V0, U1, V1 -> u0, u1, v0, v1 x 1e6)','MN4-LOOM-BUTTON-UV','ffff',4,[(0.0,0.0,1.0,1.0),(0.25,0.5,0.5,1.0),(0.5,0.125,0.75,0.25)],luv)
run(g,'3.10 geometry: title label y 4, banner preview rectangle (141, 8) size 20 x 40 at scale 16, error icon 26 x 26 at result slot - 5 = (138, 52) (title y, preview x, y, w, h, scale, error x, error y)','MN4-LOOM-GEOM','',8,[()],lambda :(4,141,8,20,40,16,138,52))
W(g,3)
# ===== 4
g=GG('TEST-MENU-40-4-4','40-4§4','Stonecutter','T1045','slots, list and selection, button, take, quick-move, scroll and cell geometry (core/src/menu-40-4.cob).',None)
def sslot(s):
    if s==0: return (1,20,33)
    if s==1: return (1,143,33)
    if 2<=s<=37:
        x,y=std_inv(s-2); return (2,x,y)
    return (0,0,0)
run(g,'M2: input (20, 33), result (143, 33), standard block 2 to 37 (part, x, y)','MN4-STONE-SLOT','i',3,[(s,) for s in (0,1,2,28,29,37,38)],sslot)
run(g,'M2: canTakeItemForPickAll is false for the result slot only','MN4-STONE-PICKALL','i',1,[(0,),(1,),(2,)],lambda s:int(s!=1))
def sch(kd,he,osel):
    if not kd: return (0,osel,0,0)
    return (1,-1,1,int(he))
run(g,'4.4: a change of the input item kind resets the selection to -1, clears the result and refilters the list; a count-only change keeps all (kind differs, stack not empty, selected -> reset, selected, result cleared, list from the set)','MN4-STONE-CHANGED','iii',4,[(1,1,3),(1,0,3),(0,1,3),(0,0,-1)],sch)
run(g,'4.4 setupResultSlot: a result only for a non-empty list and an index in range (list size, index -> has result)','MN4-STONE-RESULT','ii',1,[(5,0),(5,4),(5,5),(5,-1),(0,0)],lambda n,i:int(n>0 and 0<=i<n))
def sbt(i,sel,n):
    if i==sel: return (0,0,0)
    if 0<=i<n: return (1,1,1)
    return (1,0,0)
run(g,'4.5: the same index as the selection returns false; an index in range selects and sets up the result; an out-of-range id returns true without effect (id, selected, list size -> returned, selected set, set up)','MN4-STONE-BUTTON','iii',3,[(3,3,10),(5,3,10),(10,3,10),(-1,3,10),(0,-1,0),(0,-1,3)],sbt)
def stk(c,sel,n):
    nc=max(c-1,0)
    if nc==0: return (0,-1,0)
    return (nc,sel,int(n>0 and 0<=sel<n))
run(g,'4.6, E7.8: taking removes one input; an emptied input has already reset the selection so the result is cleared; otherwise the result is assembled again from the rest (input count, selected, list size -> new count, selected, result)','MN4-STONE-TAKE','iii',3,[(64,3,10),(1,3,10),(2,-1,10),(5,12,10),(3,0,0)],stk)
def sq(s,acc):
    if s==1: return (1,2,38,1,1)
    if s==0: return (2,2,38,0,0)
    if s>=2 and acc: return (3,0,1,0,0)
    if 2<=s<=28: return (4,29,38,0,0)
    return (5,2,29,0,0)
run(g,'4.7: the result is crafted-by then moved to [2, 38) in reverse with onQuickCraft; the input to [2, 38); an accepted item to [0, 1); else main to hotbar and hotbar to main (slot, accepted by the set -> rule, first, end, reverse, onQuickCraft)','MN4-STONE-QUICK','ii',5,[(1,0),(0,0),(10,1),(10,0),(28,0),(29,0),(37,0),(2,1)],sq)
run(g,'4.7 ending: an emptied stack is written back as empty, setChanged always runs, an unchanged count returns empty, otherwise onTake runs and what remains of the moved result stack is dropped (count after, count before, source is the result slot -> cleared, returned, drop count)','MN4-STONE-ENDING','iii',3,[(0,5,1),(3,5,1),(5,5,1),(0,5,0),(3,5,0)],lambda a,b,r:(int(a==0),int(a!=b),a if (r and a!=b) else 0))
def soff(n): return (n+3)//4-3
run(g,'4.9: getOffscreenRows = (n + 3) / 4 - 3; the scroll bar is active with more than 12 recipes (E7.7) (recipes -> offscreen rows, active)','MN4-STONE-ROWS','i',2,[(n,) for n in (0,12,13,20,16,17,48)],lambda n:(soff(n),int(n>12)))
run(g,'4.9 thumb: y = 15 + int(41 x scrollOffs)','MN4-STONE-THUMB','f',1,[(0.0,),(0.5,),(1.0,),(0.24,)],lambda s:15+int(41*s))
def sdr(my,top,off,so0):
    so=max(0.0,min(1.0,(my-(top+14)-7.5)/39.0))
    return (sc(so,1000000),int(so*off+0.5)*4)
run(g,'4.9 drag: scrollOffs = clamp((mouseY - (topPos + 14) - 7.5) / 39, 0, 1), startIndex = int(scrollOffs x offscreenRows + 0.5) x 4; E7.7: 0.5 over 2 rows gives 4, 0.24 gives 0 (mouse y, topPos, offscreen rows, unused -> scrollOffs x 1e6, start index)','MN4-STONE-DRAG','iiif',2,[(157+14+7+19,157,2,0.0),(157+14+7+9,157,2,0.0),(157+14,157,2,0.0),(157+200,157,2,0.0),(157+14+7+19,157,8,0.0)],sdr)
def swh(so,sy,off):
    so=max(0.0,min(1.0,so-sy/off))
    return (sc(so,1000000),int(so*off+0.5)*4)
run(g,'4.9 wheel: scrollOffs = clamp(scrollOffs - scrollY / offscreenRows, 0, 1), startIndex as for the drag (scrollOffs, scroll y, offscreen rows)','MN4-STONE-WHEEL','ffi',2,[(0.0,-1.0,2),(0.5,1.0,2),(1.0,-2.0,3),(0.25,0.5,4)],swh)
def scell(k): return (52+16*(k%4),14+18*(k//4)+1,52+16*(k%4),14+18*(k//4)+2,52+16*(k%4),14+18*(k//4))
run(g,'4.9 cell geometry (E7.7): position k = index - startIndex, column k mod 4, row k / 4; the button sprite at y + 1, the highlight, item and tooltip rectangle at y + 2, the click rectangle at y + 0 (k -> sprite x, y, item x, y, click x, y)','MN4-STONE-CELL','i',6,[(k,) for k in (0,1,4,5,11)],scell)
run(g,'4.9 scroll bar click: scrolling starts in x [119, 131), y [9, 63) (x, y)','MN4-STONE-SCROLL-HIT','ii',1,[(119,9),(130,62),(131,20),(118,20),(125,8),(125,63)],lambda x,y:int(119<=x<131 and 9<=y<63))
run(g,'4.9 containerChanged: the grid is shown for an input item with recipes, and scrolling resets (has input item, list size -> display, scrollOffs, start index)','MN4-STONE-LISTEN','ii',3,[(1,5),(0,5),(1,0)],lambda h,n:(int(h and n>0),0,0))
W(g,4)
# ===== 5
g=GG('TEST-MENU-40-4-5','40-4§5','Cartography table','T1047','slots, mayPlace, result recompute, setupResultSlot, take, quick-move, the screen mode and the preview (core/src/menu-40-4.cob).',None)
def cs(s):
    own={0:(15,15),1:(15,52),2:(145,39)}
    if s in own: return (1,)+own[s]
    if 3<=s<=38:
        x,y=std_inv(s-3); return (2,x,y)
    return (0,0,0)
run(g,'M2: map (15, 15), additional (15, 52), result (145, 39), standard block 3 to 38 (part, x, y)','MN4-CARTO-SLOT','i',3,[(s,) for s in (0,1,2,3,29,30,38,39)],cs)
run(g,'M2: the map slot takes a stack with map_id; the additional slot paper, an empty map or a glass pane; the result none (slot, has map_id, is paper, is map, is glass pane)','MN4-CARTO-MAYPLACE','iiiii',1,[(0,1,0,0,0),(0,0,1,1,1),(1,0,1,0,0),(1,0,0,1,0),(1,0,0,0,1),(1,1,0,0,0),(2,1,1,1,1)],lambda s,m,p,e,g_:[m,int(p or e or g_),0][s])
def cch(rh,me,ee):
    if rh and (me or ee): return 1
    if (not rh) and not me and not ee: return 2
    return 0
run(g,'5.3: a result without a map or without the additional item is removed silently; an empty result with both inputs is set up; a result that is present with both inputs is not recomputed (result has item, map empty, additional empty -> 0 nothing, 1 remove, 2 set up)','MN4-CARTO-CHANGED','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],cch)
def cset(ek,ext,lk,sc_,df):
    if not df: return (0,0,0)
    if ek==1 and ext and not lk and sc_<4: return (2,1,1)
    if ek==3 and not lk: return (2,1,2)
    if ek==2: return (2,2,0)
    return (1,0,0)
rows=[(1,1,0,1,1),(1,1,0,4,1),(1,1,1,1,1),(1,0,0,1,1),(3,0,0,0,1),(3,0,1,0,1),(2,0,1,4,1),(2,0,0,0,1),(0,1,0,0,1),(1,1,0,1,0),(3,0,0,0,0)]
run(g,'5.3 setupResultSlot: paper on an extendable, unlocked map below scale 4 gives one SCALE copy; a glass pane on an unlocked map one LOCK copy; an empty map two copies (also of a locked map); anything else removes the result; a missing saved map changes nothing (additional kind 1 paper 2 empty map 3 glass pane 0 other, extendable, locked, scale, saved map found -> action 0 unchanged 1 remove 2 set, count, post-processing 0 none 1 SCALE 2 LOCK)','MN4-CARTO-SETUP','iiiii',3,rows,cset)
run(g,'5.4 step 1: taking removes one item from the map slot and one from the additional slot (map count, additional count -> counts)','MN4-CARTO-TAKE','ii',2,[(1,1),(3,5),(2,1)],lambda a,b:(a-1,b-1))
def cpost(p,sv,scale):
    if p==0 or not sv: return (0,scale,0)
    if p==1: return (1,scale+1,0)
    return (1,scale,1)
run(g,'5.4 step 2, 25-5: onCrafted removes the post-processing; on a server a SCALE value makes a new saved map (scale + 1, empty pixels), a LOCK value a new locked one; a copy keeps its id (post-processing 0 none 1 SCALE 2 LOCK, server, scale -> new map made, scale, locked)','MN4-CARTO-POST','iii',3,[(1,1,1),(2,1,2),(0,1,2),(1,0,1),(2,0,1)],cpost)
def cq(s,hm,pmg):
    if s==2: return (1,3,39,1,1)
    if 0<=s<=1: return (2,3,39,0,0)
    if s>=3 and hm: return (3,0,1,0,0)
    if s>=3 and pmg: return (4,1,2,0,0)
    if 3<=s<=29: return (5,30,39,0,0)
    return (6,3,30,0,0)
run(g,'5.5: the result goes to [3, 39) in reverse with onQuickCraft; inputs to [3, 39); a map to [0, 1); paper, empty map or glass pane to [1, 2); else main to hotbar and hotbar to main (slot, has map_id, paper map or glass pane -> rule, first, end, reverse, onQuickCraft)','MN4-CARTO-QUICK','iii',5,[(2,0,0),(0,0,0),(1,0,0),(10,1,0),(10,0,1),(10,0,0),(29,0,0),(30,0,0),(38,0,0)],cq)
def cmode(hm,df,lk,pa,gl,mp,ext,sc_):
    er=0; sp=0
    if hm and df:
        if lk:
            er=1
            if pa or gl: sp=1
        if pa and ((not ext) or sc_>=4): er=1; sp=1
    if pa and not er: pv=1
    elif mp: pv=2
    elif gl: pv=3
    else: pv=4
    return (er,sp,pv)
rows=[(1,1,0,1,0,0,1,1),(1,1,0,0,1,0,1,1),(1,1,0,0,0,1,1,1),(1,1,1,1,0,0,1,1),(1,1,0,1,0,0,1,4),(1,1,0,1,0,0,0,1),(1,1,1,0,1,0,1,1),(1,1,1,0,0,1,1,1),(1,1,1,0,0,0,1,1),(1,0,0,1,0,0,1,1),(0,0,0,1,0,0,1,1),(1,1,0,0,0,0,1,1)]
run(g,'5.7 mode (E9): a locked map is an error and with paper or glass shows the error sprite; paper on a map outside extendable_maps or at scale 4 is an error with the sprite; preview case: paper without error 1 scaled, empty map 2 duplicate (ignores the error), glass pane 3, else 4 (has map_id, saved map found, locked, paper, glass pane, empty map, extendable, scale -> error, error sprite, preview case)','MN4-CARTO-MODE','iiiiiiii',3,rows,cmode)
PV={1:(1,67,13,85,31,226,0,0,0,0,0),2:(2,83,13,86,16,340,2,67,29,70,32),3:(3,67,13,71,17,450,4,118,60,0,0),4:(3,67,13,71,17,450,0,0,0,0,0)}
run(g,'5.7 preview positions: scaled_map frame (67, 13) with the map at (85, 31) scale 0.226; duplicated_map frames (83, 13) and (67, 29) with maps (86, 16) and (70, 32) at 0.34; glass: map frame (67, 13), map (71, 17) at 0.45, lock sprite (118, 60); otherwise the map frame and the map at 0.45 (case -> frame sprite 1 scaled 2 duplicated 3 map, frame x, y, map x, y, scale x 1000, second sprite 2 duplicated 4 locked, its x, y, second map x, y)','MN4-CARTO-PREVIEW','i',11,[(c,) for c in (1,2,3,4)],lambda c:PV[c])
run(g,'5.7: the error sprite 28 x 21 at (35, 31); title label y 4','MN4-CARTO-ERROR','',3,[()],lambda :(35,31,4))
W(g,5)
# ===== 6
g=GG('TEST-MENU-40-4-6','40-4§6','Packets and synchronisation used here','T1049','the packet table and the enchanting data slot ids (core/src/menu-40-4.cob).',None)
PK=[(60,1),(17,1),(19,1),(20,1),(136,0)]
run(g,'6: Open Screen 0x3C, Container Button Click 0x11, Container Set Data 0x13, Container Set Slot 0x14 and Update Recipes 0x88 (the stonecutter list, sent at join, not per open) (index -> id, sent per open or action)','MN4-PACKET','i',2,[(i,) for i in range(1,6)],lambda i:PK[i-1])
run(g,'6: the loom and the stonecutter use data property 0 only; the enchanting table properties are 0 to 2 costs, 3 seed, 4 to 6 clue enchantments, 7 to 9 clue levels (menu kind 1 enchanting 2 loom 3 cartography 4 stonecutter -> data slot count, first property)','MN4-PROPERTIES','i',2,[(k,) for k in (1,2,3,4)],lambda k:{1:(10,0),2:(1,0),3:(0,-1),4:(1,0)}[k])
run(g,'6: Container Set Data carries property and value as shorts (a clue id or level of -1 round-trips; the seed wraps)','MN2-DATA-WIRE','i',1,[(-1,),(0,),(30,),(70000,),(32768,)],lambda v:wire(v))
W(g,6)
