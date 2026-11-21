import sys,math
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-3-anvil-grindstone-smithing.md (integer arithmetic exactly as the document gives it).
def G(n,subj,tasks,desc): return GG('TEST-MENU-40-3-%s'%n,'40-3§%s'%n,subj,tasks,desc,None)
def W(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_3_%s.cob'%n)
MAXI=2147483647
# ===== 1
g=G(1,'Identity and shared facts','T1025','table M1: type ids, slot counts, titles, bound blocks, stats, level events, stillValid (core/src/menu-40-3.cob).')
ID={1:(8,3,39,1),2:(15,3,39,0),3:(21,4,40,1)}
run(g,'M1: anvil type 8 with 3 + 36 = 39 slots and 1 data slot, grindstone 15 with 39 and none, smithing 21 with 4 + 36 = 40 and 1 (type id, own slots, total slots, data slots)','MN3-IDENT','i',4,[(k,) for k in (1,2,3)],lambda k:ID[k])
TT={1:('container.repair','Repair & Name'),2:('container.grindstone_title','Repair & Disenchant'),3:('container.upgrade','Upgrade Gear')}
runt(g,'M1: default title key and English text','MN3-TITLE','i',[(k,) for k in (1,2,3)],lambda k:TT[k])
BS={1:('tag anvil','interact_with_anvil'),2:('grindstone','interact_with_grindstone'),3:('smithing_table','interact_with_smithing_table')}
runt(g,'M1: bound block (the anvil by block tag) and the interaction statistic','MN3-BOUND','i',[(k,) for k in (1,2,3)],lambda k:BS[k])
EV={1029:(1,100),1030:(2,100),1031:(3,30),1042:(4,100),1044:(5,100)}
run(g,'level events (1): 1029 anvil.destroy, 1030 anvil.use, 1031 anvil.land at volume 0.3, 1042 grindstone.use, 1044 smithing_table.use, volume x 100; other ids are not used (sound code 1 to 5 or 0, volume)','MN3-LEVEL-EVENT','i',2,[(e,) for e in (1029,1030,1031,1042,1044,1000,0)],lambda e:EV.get(e,(0,0)))
run(g,'stillValid (1): true with the NULL access; otherwise the block must be the right one and the player within interaction range + 4.0 (null access, block ok, in range)','MN3-VALID','iii',1,[(n,b,r) for n in (0,1) for b in (0,1) for r in (0,1)],lambda n,b,r:int(n or (b and r)))
W(g,1)
# ===== 2
g=G(2,'The item combiner base','T1027','slot definition rules, layouts, result slot, quick-move table M5, slotsChanged (core/src/menu-40-3.cob).')
def dfn(n,cont,res,has):
    if n==0 or not has: return 3
    if not cont: return 1
    if res!=n: return 2
    return 0
run(g,'build rules (2.1): inputs 0, 1, 2, ... in order and the result index = the number of inputs; no inputs or no result is an error (3 missing, 1 not continuous, 2 result index wrong, 0 valid) (inputs, continuous, result index, has result)','MN3-DEF-CHECK','iiii',1,[(2,1,2,1),(3,1,3,1),(2,0,2,1),(2,1,3,1),(0,1,0,1),(2,1,2,0),(1,1,1,1)],dfn)
OWN={1:3,2:3,3:4}
POS={1:[(27,47),(76,47),(134,47)],2:[(49,19),(49,40),(129,34)],3:[(8,48),(26,48),(44,48),(98,48)]}
def lay(k,s):
    o=OWN[k]
    if 0<=s<o: return (1,)+POS[k][s]
    if o<=s<o+36:
        x,y=std_inv(s-o); return (2,x,y)
    return (0,0,0)
run(g,'layout (2.2, 3.1, 4.1, 5.1): inputs 0 .. n-1, the result n, then the standard block (8, 84): anvil (27, 47), (76, 47), (134, 47); grindstone (49, 19), (49, 40), (129, 34); smithing (8, 48), (26, 48), (44, 48), (98, 48) (kind, slot -> part, x, y)','MN3-LAYOUT','ii',3,[(k,s) for k,t in ((1,(0,1,2,3,29,30,38,39)),(2,(0,1,2,3,38,39)),(3,(0,1,2,3,4,30,31,39,40))) for s in t],lay)
run(g,'result slot (2.3): mayPlace is always false; mayPickup is the menu hook (hook value -> mayPlace, mayPickup)','MN3-RESULT-SLOT','i',2,[(0,),(1,)],lambda h:(0,h))
run(g,'slotsChanged (2.4): a change of the input container recomputes the result, a change of the result container does not (0 input, 1 result -> createResult)','MN3-SLOTS-CHANGED','i',1,[(0,),(1,)],lambda c:int(c==0))
def cq(R,i,can):
    I0=R+1; I1=I0+27; H1=I1+9
    if i==R: return (1,I0,H1,1,1)
    if 0<=i<R: return (2,I0,H1,0,0)
    if I0<=i<H1 and can: return (3,0,R,0,0)
    if I0<=i<I1: return (4,I1,H1,0,0)
    if I1<=i<H1: return (5,I0,I1,0,0)
    return (0,0,0,0,0)
rows=[(2,2,1),(2,0,1),(2,1,1),(2,3,1),(2,29,1),(2,30,1),(2,38,1),(2,39,1),(3,3,1),(3,0,0),(3,4,1),(3,4,0),(3,30,0),(3,31,0),(3,39,0),(3,40,0),(3,-1,0)]
run(g,'quick-move table M5 (2.5, 3.6, 5.4): result to the whole inventory in reverse with onQuickCraft, inputs to the inventory, inventory to the inputs when canMoveIntoInputSlots, else main to hotbar and hotbar to main (R, source index, can move -> branch, first, end, reverse, onQuickCraft)','MN3-COMBINER-QUICK','iii',5,rows,cq)
run(g,'quick-move ending (2.5): an unchanged count returns empty, so a shift-click into full anvil inputs changes nothing; an emptied source is written back as empty, else marked changed (count after, count before -> cleared, returned, onTake)','MN2-QUICK-TAIL','ii',3,[(5,5),(0,5),(3,5)],lambda a,b:(int(a==0),int(a!=b),int(a!=b)))
W(g,2)
# ===== 3
g=G(3,'Anvil','T1029','createResult steps, taking the result, the rename rules and the screen arithmetic (core/src/menu-40-3.cob).')
def path(le,re_,dam,val,book,same):
    if le: return (0,0)
    if re_: return (1,0)
    if dam and val: return (2,0)
    if (not book) and ((not same) or (not dam)): return (3,0)
    return (4,int(dam and not book))
rows=[(le,r,d,v,b,s) for le in (0,1) for r in (0,1) for d in (0,1) for v in (0,1) for b in (0,1) for s in (0,1)]
rows=[r for r in rows if not(r[0]==1 and (r[1:]!=(0,0,0,0,0)))]+[(1,1,1,1,1,1)]
run(g,'step flow (3.3 steps 2, 4, 6, 7, 8): early exit A for an empty left stack (0), rename only for an empty right stack (1), repair with material (2), early exit C (3), merge (4) with the durability merge only for a damageable item without a book (left empty, right empty, damageable, valid repair item, book, same item -> path, durability merge)','MN3-ANVIL-PATH','iiiiii',2,rows,path)
def repair(dm,mx,cnt):
    step=min(dm,mx//4)
    if step<=0: return (1,0,0,dm)
    used=0;cost=0
    while step>0 and used<cnt:
        dm=max(dm-step,0); cost+=1; step=min(dm,mx//4); used+=1
    return (0,used,cost,dm)
run(g,'repair with material (3.3 step 6, E1): step = min(damage, max / 4), each unit costs 1 and repairs one step; early exit B when step <= 0; pickaxe 250 damage 100 with 3 ingots uses 2 for cost 2 (early, used, cost, new damage)','MN3-ANVIL-REPAIR','iii',4,[(100,250,3),(100,250,1),(250,250,64),(0,250,3),(10,3,2),(62,250,5),(300,250,2)],repair)
def dur(mL,dL,mR,dR):
    a=mL-dL; b=mR-dR; bonus=b+mL*12//100; rem=a+bonus; nd=max(mL-rem,0)
    return (nd,2) if nd<dL else (dL,0)
run(g,'durability merge (3.3 step 8): bonus = remaining of the right + max x 12 / 100, new damage = max(max - remaining, 0), applied with cost 2 only when it is lower (max left, damage left, max right, damage right -> damage, cost)','MN3-ANVIL-DURABILITY','iiii',2,[(250,100,250,200),(250,10,250,0),(250,0,250,0),(100,99,100,99),(1561,500,1561,1500),(250,250,250,250)],dur)
def ench(ll,lr,can0,inf,book,inc,mx,ac,badd,cnt):
    n=lr+1 if ll==lr else max(lr,ll)
    can=bool(can0 or inf or book); cost=0
    if inc>0: can=False; cost+=inc
    if not can: return (0,1,ll,cost,0)
    n=min(n,mx)
    ac2=max(1,ac//2) if badd else ac
    cost+=ac2*n
    st=0 if n<=0 else min(n,255)
    return (1,0,st,cost,int(cnt>1))
rows=[(3,3,1,0,1,0,5,1,1,1),(2,2,1,0,1,1,5,1,1,1),(0,2,1,0,0,0,5,4,0,1),(0,1,0,0,0,0,3,2,0,1),(0,1,0,1,0,0,3,2,0,1),(0,1,0,0,1,0,3,2,0,1),(5,5,1,0,0,0,5,2,0,1),(4,5,1,0,0,0,5,2,0,3),(0,9,1,1,0,0,3,2,0,1),(0,1,1,0,0,2,3,8,0,1),(0,0,1,0,0,0,0,1,0,1),(0,1,1,0,0,0,300,1,0,1),(0,255,1,1,0,0,400,1,0,1),(2,3,1,0,0,0,5,10,1,2)]
run(g,'enchantment merge (3.3 step 9, E3 to E5): n = lr + 1 for equal levels else the maximum; supported items are forced true for creative and books but each incompatible enchantment already present adds 1 and rejects; the cap at the maximum level always applies; cost += anvil_cost x n (half, at least 1, for a book); a count above 1 assigns 40 (ll, lr, supported, creative, left is a book, incompatible count, max level, anvil cost, book added, left count -> applied, rejected, stored level, cost, assign 40)','MN3-ANVIL-ENCH','iiiiiiiiii',5,rows,ench)
run(g,'early exit D (3.3 step 10): a rejection without any applied enchantment gives no result (rejected, applied -> exit)','MN3-ANVIL-EXIT-D','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda r,a:int(r and not a))
def ren(blank,cust,diff):
    if blank:
        return (1,1,1) if cust else (0,0,0)
    return (1,1,2) if diff else (0,0,0)
run(g,'rename (3.3 step 11): a blank or null name removes an existing custom_name for cost 1; a non-blank name different from the hover name sets it for cost 1; otherwise nothing (name blank, has custom_name, differs from hover -> rename cost, cost added, action 0 none 1 remove 2 set)','MN3-ANVIL-RENAME','iii',3,[(b,c,d) for b in (0,1) for c in (0,1) for d in (0,1)],ren)
def tot(base,cost,rc,inf):
    total=0 if cost<=0 else max(0,min(base+cost,MAXI))
    emp=int(cost<=0); only=0
    if rc==cost and rc>0:
        if total>=40: total=39
        only=1
    if total>=40 and not inf: emp=1
    return (total,emp,only)
rows=[(0,2,0,0),(0,0,0,0),(0,1,1,0),(63,1,1,0),(31,10,0,0),(31,10,0,1),(0,0,0,1),(63,1,1,1),(2147483647,5,0,1),(2147483647,5,0,0),(0,39,0,0),(1,39,0,0),(0,40,0,1),(5,-1,0,0)]
run(g,'total and limits (3.3 steps 12 to 15, E2, E5): total = clamp(base + cost, 0, 2147483647) or 0; a rename-only cost lowers 40 or more to 39; 40 or more is too expensive for a survival player (base, cost, rename cost, creative -> data slot, result empty, only renaming)','MN3-ANVIL-TOTAL','iiii',3,rows,tot)
def nrc(a,b,rc_,cost):
    rc=a
    if rc<b: rc=b
    if not(rc_==cost and rc_!=0): rc=min(2*rc+1,MAXI)
    return rc
run(g,'new repair cost (3.3 step 16, E6): 2 x max(rc(L), rc(R)) + 1 unless the change is a pure rename; the ladder 0, 1, 3, 7, 15, 31, 63 (rc result, rc right, rename cost, cost)','MN3-ANVIL-NEWREPAIR','iiii',1,[(0,0,0,2),(1,0,0,2),(3,0,0,1),(7,0,0,1),(15,0,0,3),(31,0,0,3),(0,7,0,2),(5,3,1,1),(63,0,1,1),(1073741823,0,0,4),(2147483647,0,0,4),(0,0,0,0)],nrc)
run(g,'repair cost ladder (3.3, E6): an item enchanted six times goes 0, 1, 3, 7, 15, 31, 63','MN3-ANVIL-NEWREPAIR','iiii',1,[(r,0,0,1) for r in (0,1,3,7,15,31)],nrc)
run(g,'mayPickup (3.4): creative or the level at least the cost, and the cost greater than 0 (creative, level, cost)','MN3-ANVIL-PICKUP','iii',1,[(i,l,c) for i in (0,1) for l in (0,5,30) for c in (-5,0,5)],lambda i,l,c:int((i or l>=c) and c>0))
def take(inf,cost,lv,ru,rc,only):
    if not inf:
        lv=lv-cost
        lv=min(lv,MAXI)
        if lv<0: lv=0
    if ru>0:
        if rc>0 and rc>ru: return (lv,1,rc-ru)
        return (lv,2,0)
    if not only: return (lv,2,0)
    return (lv,0,rc)
rows=[(0,2,5,2,3,0),(0,2,5,2,2,0),(0,2,5,2,1,0),(0,4,10,0,1,0),(0,1,10,0,1,1),(1,9,3,0,1,0),(0,9,3,2,5,0),(1,2,30,3,64,0),(0,0,7,0,0,0),(0,-5,2147483647,0,0,0)]
run(g,'take (3.5, E1): the level drops by the cost unless creative (not below 0); the right slot loses the repair units, or all of it for a merge, or nothing for a pure rename (creative, cost, level, repair units, right count, only renaming -> level, right action 0 keep 1 shrink 2 empty, right count)','MN3-ANVIL-TAKE','iiiiii',3,rows,take)
def dmg(inf,tag,roll,st):
    drawn=int((not inf) and tag)
    if drawn and roll<0.12:
        if st==2: return (1,3,1029)
        return (1,st+1,1030)
    return (drawn,0,1030)
rows=[(0,1,0.11,0),(0,1,0.12,0),(0,1,0.5,1),(0,1,0.0,1),(0,1,0.05,2),(1,1,0.0,0),(0,0,0.0,0),(0,1,0.99,2)]
run(g,'anvil wear (3.5 step 6): only for a survival player and a block of the tag anvil one random float is drawn; below 0.12 the anvil becomes chipped, chipped becomes damaged, damaged is removed (event 1029); every other case sends 1030 (creative, in tag, roll, state 0 anvil 1 chipped 2 damaged -> drawn, new state 0 same 1 chipped 2 damaged 3 removed, event)','MN3-ANVIL-DAMAGE','iifi',3,rows,dmg)
run(g,'data slot on the wire (3.2, E7 of 8.12): a cost above 32767 is truncated to 16 bits and sign-extended: 70000 arrives as 4464, 65540 as 4, 40000 as -25536','MN2-DATA-WIRE','i',1,[(70000,),(65540,),(40000,),(39,),(32767,),(0,)],lambda v:wire(v))
run(g,'name characters (3.7): a character is kept unless it is 167, below 32 or 127; newlines are dropped','MN3-NAME-CHAR','i',1,[(c,) for c in (65,32,31,10,167,127,126,128,0,168,166)],lambda c:int(not(c==167 or c<32 or c==127)))
BL=set(list(range(9,14))+list(range(28,33))+[0xA0,0x1680]+list(range(0x2000,0x200B))+[0x2028,0x2029,0x202F,0x205F,0x3000])
run(g,'blank test (3.7): whitespace and space-separator characters count as blank','MN3-BLANK-CHAR','i',1,[(c,) for c in (32,9,13,14,28,27,160,0x2007,0x2003,0x200B,0x3000,65,0x2029)],lambda c:int(c in BL))
def nset(ln,eq,rh,bl):
    if ln>50 or eq: return (0,0)
    if rh: return (1,1 if bl else 2)
    return (1,0)
run(g,'setItemName (3.7): a name longer than 50 after filtering is rejected, an unchanged name returns false; otherwise it is stored and a result item is edited in place (blank removes custom_name, else sets it) (length, equals the current name, result slot has an item, blank -> accepted, edit 0 none 1 remove 2 set)','MN3-NAME-SET','iiii',2,[(51,0,1,0),(50,0,1,0),(5,1,1,0),(5,0,0,0),(5,0,1,0),(0,0,1,1),(0,0,0,1)],nset)
def nchg(has,cust,eq,acc):
    if not has: return (0,0,0)
    return (1,int((not cust) and eq),acc)
run(g,'onNameChanged (3.8): without an item nothing happens; an unchanged default name is sent as the empty name; the packet is sent only when setItemName returned true (has item, has custom_name, text equals hover name, accepted -> proceed, use empty name, send)','MN3-ANVIL-NAMECHG','iiii',3,[(0,0,0,1),(1,0,1,1),(1,1,1,1),(1,0,0,1),(1,0,0,0)],nchg)
def schg(slot,emp):
    if slot!=0: return (0,0,0,0)
    return (1,0 if emp else 1,0 if emp else 1,1)
run(g,'slotChanged (3.8): only slot 0: the field value becomes empty or the hover name, the field is editable when the stack is not empty and takes focus (slot, stack empty -> applies, value is hover name, editable, focus)','MN3-ANVIL-SLOT-CHANGED','ii',4,[(0,0),(0,1),(1,0),(2,1)],schg)
def scr(l,t,h0,h1,rh):
    return (l+62,t+24,l+59,t+20,int(not h0),l+99,t+45,int((h0 or h1) and not rh),60)
run(g,'screen (3.8, E11): the name field at (leftPos + 62, topPos + 24), its 110 x 16 sprite at (leftPos + 59, topPos + 20) (the disabled one when slot 0 is empty), the error sprite at (leftPos + 99, topPos + 45) while an input is present and the result is empty, titleLabelX 60 (left, top, slot 0 has item, slot 1 has item, result has item)','MN3-ANVIL-SCREEN','iiiii',9,[(339,157,1,0,0),(339,157,0,1,0),(339,157,0,0,0),(339,157,1,1,1),(0,0,1,1,0)],scr)
def lab(c,inf,rh,mp,w):
    if c<=0: return (0,0,0,0,0,0,0,0)
    if c>=40 and not inf: k=1; col=-40864
    elif not rh: return (0,0,0,0,0,0,0,0)
    else: k=2; col=-40864 if not mp else -8323296
    x=166-w
    return (k,col,x-2,67,168,79,x,69)
run(g,'cost label (3.8): nothing when the cost is 0 or less; Too Expensive in red for 40 or more without infinite materials; no box without a result; otherwise the cost in green or red when it cannot be taken; the box runs from (164 - W, 67) to (168, 79) and the text at (166 - W, 69) (cost, creative, result has item, mayPickup, text width -> kind 1 expensive 2 cost, colour, box x0, y0, x1, y1, text x, y)','MN3-ANVIL-LABEL','iiiii',8,[(0,0,1,1,50),(-3,0,1,1,50),(41,0,1,1,80),(41,1,1,1,80),(5,0,0,1,60),(5,0,1,1,60),(5,0,1,0,60),(39,0,1,1,100)],lab)
def key(esc,hd,cc):
    if esc: return 1
    if hd or cc: return 2
    return 3
run(g,'keys (3.8): Escape closes the container; a key the field handled or can consume is consumed; otherwise the generic handling (escape, field handled, field can consume input -> 1 close, 2 consumed, 3 generic)','MN3-ANVIL-KEY','iii',1,[(1,0,0),(0,1,0),(0,0,1),(0,0,0)],key)
W(g,3)
# ===== 4
g=G(4,'Grindstone','T1031','mayPlace, computeResult and mergeItems, the experience and result rules, quick-move and the error sprite (core/src/menu-40-3.cob).')
run(g,'mayPlace (4.1): the stack is damageable or carries any enchantments (enchantments or stored_enchantments non-empty, whatever the item) (damageable, has any enchantments)','MN3-GRIND-MAYPLACE','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:int(a or b))
def comp(ae,be,ac,bc,sen,same):
    if ae and be: return 0
    if ac>1 or bc>1: return 0
    if not(not ae and not be):
        return 1 if sen else 0
    return 2 if same else 0
rows=[(1,1,0,0,0,0),(0,1,2,0,1,0),(1,0,0,3,1,0),(0,1,1,0,0,0),(0,1,1,0,1,0),(1,0,0,1,1,0),(0,0,1,1,0,1),(0,0,1,1,0,0),(0,0,2,1,0,1),(0,0,1,2,1,1)]
run(g,'computeResult (4.3): nothing for no inputs or a count above 1; a single item without enchantments gives nothing, with enchantments the stripped copy (1); two items merge (2) only when they are the same item (left empty, right empty, left count, right count, single has enchantments, same item -> 0 empty 1 stripped 2 merge)','MN3-GRIND-COMPUTE','iiiiii',1,rows,comp)
def mrg(mA,dA,mB,dB,dam,ms,mt):
    M=max(mA,mB); rem=(mA-dA)+(mB-dB)+M*5//100; cnt=1
    if not dam:
        if ms<2 or not mt: return (0,0,0,0)
        cnt=2
    if dam: return (1,cnt,M,max(M-rem,0))
    return (1,cnt,0,0)
run(g,'mergeItems (4.3, E7): remaining = ra + rb + max x 5 / 100, damage = max(max - remaining, 0) with max_damage set to the larger maximum; an undamageable pair needs a stack size of at least 2 and equal stacks and gives count 2 (max a, damage a, max b, damage b, damageable, max stack size, stacks match -> ok, count, max damage, damage)','MN3-GRIND-MERGE','iiiiiii',4,[(250,100,250,200,1,1,1),(250,0,250,0,1,1,1),(250,250,250,250,1,1,1),(100,50,200,150,1,1,1),(0,0,0,0,0,64,1),(0,0,0,0,0,1,1),(0,0,0,0,0,64,0),(0,0,0,0,0,16,1)],mrg)
def mench(cur,rl,lv):
    app=int((not cur) or rl==0)
    if not app: return (0,rl)
    if lv<=0: return (1,rl)
    return (1,max(rl,min(lv,255)))
run(g,'mergeEnchants (4.3, 9): a non-curse is upgraded to the higher level (at most 255); a curse of the second item is carried only when the result lacks it; a level of 0 or less changes nothing (is a curse, level in the result, level of the second item -> applied, new level)','MN3-GRIND-MERGE-ENCH','iii',2,[(0,3,5),(0,5,3),(0,0,2),(1,0,1),(1,1,1),(0,2,0),(0,0,-4),(0,200,300),(1,0,300)],mench)
def rem(book,k):
    rc=0
    for _ in range(k): rc=2*rc+1
    return (int(book and k==0),rc)
run(g,'removeNonCurses (4.3, 9, E8): an enchanted book with nothing left becomes a book; repair_cost is n -> 2n + 1 once for each remaining curse, so 2^k - 1 (is a book, remaining curses -> becomes book, repair cost)','MN3-GRIND-REMOVE','ii',2,[(b,k) for b in (0,1) for k in (0,1,2,3)],rem)
run(g,'minimum cost (4.4, E7, E8): minCost.base + per_level_above_first x (level - 1): efficiency 3 = 1 + 10 x 2, unbreaking 2 = 5 + 8, sharpness 5 = 1 + 11 x 4, mending 25 (base, per level, level)','MN3-GRIND-MINCOST','iii',1,[(1,10,3),(5,8,2),(1,11,4),(25,25,1),(5,8,3),(10,0,5)],lambda b,p,l:b+p*(l-1))
def xp(T,d):
    if T<=0: return (0,0,0)
    h=(T+1)//2
    return (h,h+d,1)
run(g,'experience (4.4, E7, E8): T = sum of minimum costs; h = ceil(T / 2), xp = h + nextInt(h), one draw; T = 0 gives no experience and no draw (T, the draw -> h, xp, draws)','MN3-GRIND-XP','ii',3,[(34,0),(34,16),(70,34),(21,10),(1,0),(0,0),(-4,0),(35,20)],xp)
def gq(i,e0,e1):
    if i==2: return (1,3,39,1,1)
    if i in (0,1): return (2,3,39,0,0)
    if i>=3 and (e0 or e1): return (3,0,2,0,0)
    if 3<=i<30: return (4,30,39,0,0)
    if 30<=i<39: return (5,3,30,0,0)
    return (0,0,0,0,0)
rows=[(2,0,0),(0,0,0),(1,1,1),(5,1,0),(5,0,1),(5,0,0),(29,0,0),(30,0,0),(38,0,0),(39,0,0),(3,0,0),(31,1,1)]
run(g,'quick-move (4.5): result to [3, 39) in reverse; inputs to [3, 39); any other stack to [0, 2) while an input is empty; both occupied: main to hotbar and hotbar to main (source, slot 0 empty, slot 1 empty -> branch, first, end, reverse, onQuickCraft)','MN3-GRIND-QUICK','iii',5,rows,gq)
run(g,'error sprite (4.7): 28 x 21 at (leftPos + 92, topPos + 31) while an input is present and the result is empty (left, top, slot 0 has item, slot 1 has item, result has item -> x, y, show)','MN3-GRIND-ERROR','iiiii',3,[(339,157,1,0,0),(339,157,0,1,0),(339,157,0,0,0),(339,157,1,1,1)],lambda l,t,a,b,r:(l+92,t+31,int((a or b) and not r)))
W(g,4)
# ===== 5
g=G(5,'Smithing table','T1033','mayPlace by property set, the error flag, createResult, taking, quick-move, cycling hint icons, tooltips and the preview (core/src/menu-40-3.cob).')
def smp(s,t,b,a): return [t,b,a][s] if 0<=s<=2 else 1
run(g,'mayPlace (5.1): slot 0 takes an item of the smithing_template set, slot 1 of smithing_base, slot 2 of smithing_addition (slot, in template set, in base set, in addition set)','MN3-SMITH-MAYPLACE','iiii',1,[(s,t,b,a) for s in (0,1,2) for (t,b,a) in ((1,0,0),(0,1,0),(0,0,1),(0,0,0))],smp)
def flag(sv,h0,h1,h2,rh,old):
    if not sv: return old
    return int(h0 and h1 and h2 and not rh)
run(g,'error flag (5.2, 8.9): on a server level 1 exactly when the three inputs are present and the result is empty; on a client level it keeps the packet value (server, has 0, has 1, has 2, result has item, old flag)','MN3-SMITH-FLAG','iiiiii',1,[(1,1,1,1,0,0),(1,1,1,1,1,1),(1,1,1,0,0,1),(1,0,1,1,0,1),(1,1,0,1,0,1),(0,1,1,1,0,0),(0,0,0,0,0,1)],flag)
def cre(sv,fo,ae):
    if sv and fo: return (1,int(not ae))
    return (0,0)
run(g,'createResult (5.3): on a client level no recipe, so the result is emptied; on a server level the first matching recipe sets the recipe used and the assembled result (empty when the same trim is present) (server, recipe found, assemble gives empty -> recipe used, result stored)','MN3-SMITH-CREATE','iii',2,[(1,1,0),(1,1,1),(1,0,0),(0,1,0),(0,0,0)],cre)
run(g,'take (5.4, E9): one item is taken from each non-empty input slot and level event 1044 is sent (count 0, count 1, count 2 -> new counts, event)','MN3-SMITH-TAKE','iii',4,[(1,1,1),(1,64,1),(0,3,1),(2,0,0),(0,0,0)],lambda a,b,c:(max(a-1,0),max(b-1,0),max(c-1,0),1044))
run(g,'canMoveIntoInputSlots (5.4): an item the template set accepts while slot 0 is empty, or base set and slot 1 empty, or addition set and slot 2 empty (template accepts, base accepts, addition accepts, slot 0 empty, slot 1 empty, slot 2 empty)','MN3-SMITH-CANMOVE','iiiiii',1,[(1,0,0,1,0,0),(1,0,0,0,1,1),(0,1,0,0,1,0),(0,1,0,1,0,0),(0,0,1,0,0,1),(0,0,1,1,1,0),(0,0,0,1,1,1),(1,1,1,0,0,0)],lambda t,b,a,e0,e1,e2:int((t and e0) or (b and e1) or (a and e2)))
run(g,'double-click gather (5.4): only the result slot 3 is excluded (slot -> canTakeItemForPickAll)','MN3-SMITH-PICKALL','i',1,[(s,) for s in (0,1,2,3,4,39)],lambda s:int(s!=3))
rows=[(1,4,0,0),(1,4,29,0),(1,4,29,1),(0,4,29,0),(0,4,59,3),(1,0,5,0),(0,0,5,0),(1,2,59,1),(1,2,29,1),(0,7,89,6)]
def ctk(eq,sz,tk,ix):
    if not eq: ix=0
    if sz>0:
        tk+=1
        if tk%30==0: ix=(ix+1)%sz
    return (tk,ix)
run(g,'cycling hint icons, tick (5.6): a different list is stored and the icon index reset (the tick counter is not); a non-empty list counts the tick and at every multiple of 30 the index advances modulo the list size (list equal, list size, tick, icon index -> tick, icon index)','MN3-CYCLE-TICK','iiii',2,rows,ctk)
def cdr(sz,tk,ix,pt,has):
    if sz==0 or has: return (0,0,0,0,0,0)
    tr=int(sz>1 and tk>=30)
    al=min((tk%30)+pt,4)/4 if tr else 1.0
    if al<1.0: return (1,tr,sc(al,1000000),1,(ix-1)%sz,sc(1-al,1000000))
    return (1,tr,sc(al,1000000),0,0,0)
rows=[(2,0,0,0.0,0),(2,29,1,0.5,0),(2,30,1,0.0,0),(2,31,1,0.5,0),(2,31,0,0.25,0),(2,33,1,0.75,0),(2,34,0,0.0,0),(2,35,1,0.5,0),(4,95,3,0.5,0),(1,100,0,0.5,0),(0,5,0,0.5,0),(4,40,2,0.5,1),(4,60,0,0.25,0)]
run(g,'cycling hint icons, draw (5.6): nothing for an empty list or an occupied slot; transitioning for a list of 2 or more from tick 30; alpha = min((tick mod 30) + partialTick, 4) / 4; below 1 the previous icon (index - 1 modulo the size) is drawn first with 1 - alpha (alphas x 1e6) (list size, tick, icon index, partial tick, slot has item -> draw, transitioning, alpha, previous drawn, previous index, previous alpha)','MN3-CYCLE-DRAW','iiifi',6,rows[:7],cdr)
run(g,'cycling hint icons, draw again (5.6): nothing for an empty list or an occupied slot; transitioning for a list of 2 or more from tick 30; alpha = min((tick mod 30) + partialTick, 4) / 4; below 1 the previous icon (index - 1 modulo the size) is drawn first with 1 - alpha (alphas x 1e6) (list size, tick, icon index, partial tick, slot has item -> draw, transitioning, alpha, previous drawn, previous index, previous alpha)','MN3-CYCLE-DRAW','iiifi',6,rows[7:],cdr)
IC={(1,1):['helmet','chestplate','leggings','boots'],(1,2):['ingot','redstone_dust','lapis_lazuli','quartz','diamond','emerald','amethyst_shard'],(2,1):['helmet','sword','chestplate','pickaxe','leggings','axe','boots','hoe','shovel','nautilus_armor','spear'],(2,2):['ingot']}
run(g,'icon lists (5.6): armor trim has 4 base and 7 addition icons, netherite upgrade 11 base and 1 addition; no template gives none (kind 1 armor trim 2 netherite 0 none, slot 1 base 2 addition)','MN3-ICON-COUNT','ii',1,[(k,s) for k in (0,1,2) for s in (1,2)],lambda k,s:len(IC.get((k,s),[])))
for (k_,s_),l_ in IC.items():
    rows=[(k_,s_,i) for i in range(1,len(l_)+1)]
    runt(g,'icon lists (5.6): the sprite of each icon of kind %d slot %d, in order (kind, slot, position from 1)'%(k_,s_),'MN3-ICON-NAME','iii',rows,lambda k,s,i:('container/slot/'+IC[(k,s)][i-1],IC[(k,s)][i-1]))
runt(g,'icon lists (5.6): the two template icons of slot 0 (position 1 or 2)','MN3-TEMPLATE-ICON','i',[(1,),(2,)],lambda i:('container/slot/'+['smithing_template_armor_trim','smithing_template_netherite_upgrade'][i-1],['armor_trim','netherite_upgrade'][i-1]))
def tip(err,ptr,hv,t0e,t0t,he):
    c=0
    if err and ptr: c=1
    if hv>=0:
        if t0e:
            if hv==0: c=2
        elif t0t and he:
            if hv==1: c=3
            if hv==2: c=4
    return c
rows=[(1,1,-1,0,0,0),(1,0,-1,0,0,0),(0,1,-1,0,0,0),(1,1,0,1,0,0),(0,0,0,1,0,0),(0,0,1,1,0,0),(0,0,1,0,1,1),(0,0,2,0,1,1),(0,0,0,0,1,1),(0,0,1,0,1,0),(0,0,1,0,0,1),(0,0,3,0,1,1),(1,1,1,0,1,1)]
run(g,'tooltip choice (5.7): the error tooltip over the 28 x 21 box, overridden by Add Smithing Template over an empty slot 0, or by the base or addition description of the template in slot 0 over an empty slot 1 or 2 (error flag, pointer in the box, hovered slot or -1, slot 0 empty, slot 0 is a template, hovered stack empty -> 0 none 1 error 2 missing template 3 base 4 addition)','MN3-SMITH-TOOLTIP','iiiiii',1,rows,tip)
TX={1:('container.upgrade.error_tooltip',"Item can't be upgraded this way"),2:('container.upgrade.missing_template_tooltip','Add Smithing Template'),(3,1):('item.minecraft.smithing_template.armor_trim.base_slot_description','Add a piece of armor'),(4,1):('item.minecraft.smithing_template.armor_trim.additions_slot_description','Add ingot or crystal'),(3,2):('item.minecraft.smithing_template.netherite_upgrade.base_slot_description','Add diamond armor, weapon, or tool'),(4,2):('item.minecraft.smithing_template.netherite_upgrade.additions_slot_description','Add Netherite Ingot')}
for part,rows_ in (('the error and the missing template',[(1,1),(2,1)]),('the armor trim descriptions',[(3,1),(4,1)]),('the netherite upgrade descriptions',[(3,2),(4,2)])):
    runt(g,'tooltip texts (5.7): keys and English text of %s (code, template kind 1 armor trim 2 netherite)'%part,'MN3-TOOLTIP-TEXT','ii',rows_,lambda c,k:TX[c if c<3 else (c,k)])
def prv(he,sl,sr,re_):
    if re_: return 0
    if not he: return 6
    if sl==1: return 1 if sr else 2
    return {2:3,3:4,4:5}.get(sl,6)
rows=[(1,1,1,0),(1,1,0,0),(1,2,0,0),(1,3,0,0),(1,4,0,0),(1,5,0,0),(0,0,0,0),(1,1,1,1)]
run(g,'armor stand preview (5.8, E9): an empty result clears everything; a head item that passes HumanoidArmorLayer.shouldRender is the head equipment, else the head item model; chest, legs and feet go to their equipment; anything else, or no equippable, is the left-hand stack (has equippable, slot 1 head 2 chest 3 legs 4 feet 5 other, shouldRender, result empty -> 0 none 1 head equipment 2 head item 3 chest 4 legs 5 feet 6 left hand)','MN3-PREVIEW','iiii',1,rows,prv)
run(g,'preview update (5.8): updateArmorStandPreview runs from subInit and whenever slot 3 changes (slot -> update)','MN3-SMITH-SLOT-CHANGED','i',1,[(0,),(3,),(4,)],lambda s:int(s==3))
run(g,'screen (5.5, E11): the error sprite 28 x 21 at (leftPos + 65, topPos + 46), the preview box (leftPos + 121, topPos + 20) to (leftPos + 161, topPos + 80), titleLabel (44, 15) (left, top -> error x, y, box x0, y0, x1, y1, title x, title y)','MN3-SMITH-SCREEN','ii',8,[(339,157),(0,0)],lambda l,t:(l+65,t+46,l+121,t+20,l+161,t+80,44,15))
W(g,5)
# ===== 6
g=G(6,'Smithing recipe data the engine reads','T1035','lookup order and the optional ingredient rule (core/src/menu-40-3.cob).')
def first(*m):
    for i,v in enumerate(m,1):
        if v: return i
    return 0
rows=[(0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0),(0,0,1,1,0,0,0,0),(0,0,0,0,0,0,0,1),(1,1,1,1,1,1,1,1)]
run(g,'lookup order (6, 27 3.3): the first loaded smithing recipe that matches in registry order wins; 0 when none matches (match flags of recipes 1 to 8 -> index)','MN3-SMITH-FIRST','i'*8,1,rows,first)
def ingok(ab,em,mt):
    return int(em) if ab else int((not em) and mt)
run(g,'optional ingredients (5.3, 6): an absent template or addition ingredient needs the slot to be empty; a present one needs a non-empty slot whose item matches (ingredient absent, slot empty, item matches)','MN3-INGREDIENT-OK','iii',1,[(a,e,m) for a in (0,1) for e in (0,1) for m in (0,1)],ingok)
W(g,6)
# ===== 9
g=G(9,'Differences from earlier prose','T1037','the corrections of 17 5.4 and 5.5 as cases of the programs of sections 3 and 4 (core/src/menu-40-3.cob).')
run(g,'9.1: the grindstone result repair_cost is 2^n - 1 for n remaining curses, not 2n + 1 (n = 0 to 5)','MN3-GRIND-REMOVE','ii',2,[(0,k) for k in range(6)],rem)
run(g,'9.2: a curse of the second grindstone item is carried over only when the result lacks it; a non-curse is upgraded to the higher level (curse, level in result, level)','MN3-GRIND-MERGE-ENCH','iii',2,[(1,2,3),(1,0,3),(0,2,3),(0,4,3)],mench)
run(g,'9.3: a non-damageable grindstone merge needs max stack size 2 or more and equal stacks, and gives count 2 (max a, damage a, max b, damage b, damageable, max stack, stacks match)','MN3-GRIND-MERGE','iiiiiii',4,[(0,0,0,0,0,1,1),(0,0,0,0,0,16,1),(0,0,0,0,0,16,0),(0,0,0,0,0,64,1)],mrg)
run(g,'9.4: in creative only the supported-item test is forced true; an incompatible pair still adds 1 and is rejected (ll, lr, supported, creative, book, incompatible, max, cost, book added, count)','MN3-ANVIL-ENCH','iiiiiiiiii',5,[(0,2,0,1,0,1,3,2,0,1),(0,2,0,1,0,0,3,2,0,1),(0,2,0,0,0,0,3,2,0,1)],ench)
run(g,'9.5: the maximum level cap applies in every mode, creative included (ll, lr, supported, creative, book, incompatible, max, cost, book added, count)','MN3-ANVIL-ENCH','iiiiiiiiii',5,[(0,9,0,1,0,0,3,2,0,1),(0,9,1,0,0,0,3,2,0,1),(4,4,1,1,0,0,4,1,0,1)],ench)
run(g,'9.6: the smithing error flag is 1 exactly with all three inputs and an empty result; on a client it is only changed by packets (server, has 0, has 1, has 2, result has item, old flag)','MN3-SMITH-FLAG','iiiiii',1,[(1,1,1,1,0,0),(1,1,1,1,1,1),(0,1,1,1,0,1),(0,0,0,0,0,0)],flag)
W(g,9)
