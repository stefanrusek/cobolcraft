import sys,math
from fractions import Fraction as Fr
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-2-furnaces-brewing-crafter.md (sections 3 to 8), exact rational arithmetic where the document uses floats.
DOC='40-2'
def G(n,subj,tasks,desc): return GG('TEST-MENU-40-2-%d'%n,'40-2§%d'%n,subj,tasks,desc,None)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_menu_40_2_%d.cob'%n)
def ceil(x): return int(math.ceil(x))
def clamp01(x): return max(Fr(0),min(Fr(1),x))
# ===== 3
g=G(3,'The furnace family screens','T1013','frame, recipe book button, flame and arrow arithmetic, per-kind data (core/src/menu-40-2.cob).')
def frame(sw,sh,tw): return ((sw-176)//2,(sh-166)//2,(176-tw)//2,6,72)
run(g,'frame (1.1, 3.1): leftPos = (screenWidth - 176) / 2, topPos = (screenHeight - 166) / 2, the title centred at (176 - titleWidth) / 2, y 6, the inventory label at y 72','MN2-FRAME','iii',5,[(854,480,60),(400,300,0),(176,166,176),(1000,700,31)],frame)
run(g,'recipe book button (3.1): 20 x 18 at (leftPos + 20, screenHeight / 2 - 49), integer division','MN2-FURNACE-BUTTON','ii',4,[(339,480),(100,301),(0,0),(5,3)],lambda l,h:(l+20,h//2-49,20,18))
def flame(d0,d1,l,t):
    if d0<=0: return (0,0,0,0)
    dd=d1 if d1!=0 else 200
    lp=clamp01(Fr(d0,dd))
    h=ceil(lp*13)+1
    return (h,14-h,l+56,t+36+14-h)
fr=[(1200,1600,339,157),(1,1600,339,157),(1600,1600,339,157),(5,0,0,0),(100,0,0,0),(300,200,10,20),(0,1600,339,157),(-3,1600,339,157),(7,-5,0,0),(1600,1600,0,0),(13,26,1,1)]
run(g,'flame (3.2, E3): lit when data 0 > 0; h = ceil(litProgress x 13) + 1, source (0, 14 - h), destination (leftPos + 56, topPos + 36 + 14 - h); data 1 = 0 divides by 200 (h, source v, x, y)','MN2-FLAME','iiii',4,fr,flame)
def arrow(p,t,l,tp):
    if t<0: p,t=-p,-t
    w=0 if (p==0 or t==0) else ceil(clamp01(Fr(p,t))*24)
    return (w,l+79,tp+34)
ar=[(57,200,339,157),(1,200,339,157),(200,200,339,157),(0,200,0,0),(30,0,0,0),(500,200,5,5),(-4,200,0,0),(-57,-200,0,0),(100,-200,0,0),(100,200,1,2)]
run(g,'arrow (3.2, V9): w = ceil(burnProgress x 24) with burnProgress = clamp(p / t, 0, 1) and 0 when either value is 0; the arrow is at (leftPos + 79, topPos + 34) (w, x, y)','MN2-ARROW','iiii',3,ar,arrow)
KINDS={1:('textures/gui/container/furnace.png','gui.recipebook.toggleRecipes.smeltable','container/furnace/lit_progress','container/furnace/burn_progress','FURNACE','furnace_food:porkchop;furnace_blocks:stone;furnace_misc:lava_bucket+emerald'),
 2:('textures/gui/container/blast_furnace.png','gui.recipebook.toggleRecipes.blastable','container/blast_furnace/lit_progress','container/blast_furnace/burn_progress','BLAST_FURNACE','blast_furnace_blocks:redstone_ore;blast_furnace_misc:iron_shovel+golden_leggings'),
 3:('textures/gui/container/smoker.png','gui.recipebook.toggleRecipes.smokable','container/smoker/lit_progress','container/smoker/burn_progress','SMOKER','smoker_food:porkchop')}
runt(g,'per-kind data (3.3): the background texture and the filter label key of furnace, blast furnace and smoker','MN2-FURNACE-TEXTURE','i',[(k,) for k in (1,2,3)],lambda k:(KINDS[k][0],KINDS[k][1]))
runt(g,'per-kind data (3.3): the flame and arrow sprites','MN2-FURNACE-SPRITES','i',[(k,) for k in (1,2,3)],lambda k:(KINDS[k][2],KINDS[k][3]))
runt(g,'per-kind data (3.3): the recipe book category and the tabs with their icons','MN2-FURNACE-TABS','i',[(k,) for k in (1,2,3)],lambda k:(KINDS[k][4],KINDS[k][5]))
W(g,3)
# ===== 4
g=G(4,'The brewing stand menu','T1015','slots, slot rules, quick-move order, data slots (core/src/menu-40-2.cob).')
def bslot(s):
    own={0:(56,51,1),1:(79,58,1),2:(102,51,1),3:(79,17,2),4:(17,17,3)}
    if s in own: x,y,c=own[s]; return (1,x,y,c)
    if 5<=s<=40:
        x,y=std_inv(s-5); return (2,x,y,0)
    return (0,0,0,0)
run(g,'slot table (4.2, V2): five own slots (bottles 0 to 2, ingredient 3, fuel 4: class 1 potion, 2 ingredient, 3 fuel) then the standard block 5 to 40; part 0 outside 41 slots (part, x, y, class)','MN2-BREW-SLOT','i',4,[(s,) for s in (0,1,2,3,4,5,13,31,32,40,41,-1)],bslot)
def bmay(s,inp,tag,rea,fuel):
    if 0<=s<=2: return (int(bool(inp or tag)),1)
    if s==3: return (int(bool(rea)),0)
    if s==4: return (int(bool(fuel)),0)
    return (1,0)
run(g,'slot rules (4.3, V10): a bottle slot takes a brewing_input or brewing_potion_inputs item and has cap 1 (no emptiness check); the ingredient slot takes a reagent; the fuel slot takes brewing_fuel; others anything (slot, input, tag, reagent, fuel -> ok, cap)','MN2-BREW-MAYPLACE','iiiii',2,[(s,a,b,c,d) for s in (0,1,3,4,9) for (a,b,c,d) in ((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1),(0,0,0,0))],bmay)
def broute(s,fuel,rea,pot):
    if 0<=s<=4: return (1,5,41,1,1)
    if fuel: return (2,4,5,0,2)
    if rea: return (3,3,4,0,0)
    if pot: return (4,0,3,0,0)
    if 5<=s<32: return (5,32,41,0,0)
    if 32<=s<41: return (6,5,32,0,0)
    return (7,5,41,0,0)
run(g,'quick-move order (4.4, V11, E5): bottles, ingredient and fuel go to [5, 41) in reverse with onQuickCraft; then fuel before reagent before potion input; main to hotbar, hotbar to main, else the whole inventory (rule, first, end, reverse, mode 0 tail, 1 onQuickCraft and tail, 2 empty at once on success)','MN2-BREW-ROUTE','iiii',5,[(0,0,0,0),(4,1,1,1),(20,1,1,0),(20,0,1,1),(33,0,0,1),(20,0,0,0),(33,0,0,0),(41,0,0,0),(32,0,0,0),(31,0,0,0)],broute)
run(g,'fuel move failed (4.4 rule 2, E5b): a reagent goes on to [3, 4) and then the common tail; otherwise nothing more is moved (proceed, first, end)','MN2-BREW-FALLBACK','i',3,[(1,),(0,)],lambda r:(1,3,4) if r else (0,0,0))
def tail(after,orig): 
    ret=int(after!=orig)
    return (int(after==0),ret,ret)
run(g,'common tail (1.3): an emptied source is written back as empty, else marked changed; an unchanged count returns empty; otherwise onTake runs and the copy is returned (cleared, returned, onTake)','MN2-QUICK-TAIL','ii',3,[(0,5),(16,40),(40,40),(0,0),(64,1),(63,64)],tail)
run(g,'quick-move loop (1.3): the click repeats while a non-empty stack came back and the slot still holds the same item (returned non-empty, same item -> again)','MN2-QUICK-LOOP','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:int(a and b))
def bdata(i,a,b,c,d):
    return [a,b,c,d][i] if 0<=i<=3 else 0
run(g,'data slots (4.5): 0 remaining brew ticks, 1 remaining fuel uses, 2 total brew ticks, 3 total fuel uses; other indexes read 0 (index, brewTime, fuel, totalBrewTime, totalFuel)','MN2-BREW-DATA','iiiii',1,[(i,400,19,400,20) for i in (0,1,2,3,4,-1)],bdata)
W(g,4)
# ===== 5
g=G(5,'The brewing stand screen','T1017','fuel bar, brewing arrow and bubbles arithmetic (core/src/menu-40-2.cob).')
def fbar(f,T,l,t):
    w=0
    if T>0:
        a=18*f
        w=max(0,min(18,-((-a)//T)))
    return (w,l+60,t+44)
fb=[(20,20),(19,20),(10,20),(1,20),(0,20),(20,0),(5,-3),(-4,20),(40,20),(7,3)]
run(g,'fuel bar (5, E6): w = clamp(ceilDiv(18 x f, T), 0, 18), 0 when T <= 0, drawn at (leftPos + 60, topPos + 44) (w, x, y)','MN2-BREW-FUEL-BAR','iiii',3,[(f,T,339,157) for f,T in fb],fbar)
def barrow(b,B,l,t):
    a=0
    if b>0 and B>0:
        v=Fr(28*(B-b),B); a=int(v)
        if a<0: a=0
    return (a,l+97,t+16)
ab=[(400,400),(200,400),(1,400),(0,400),(100,400),(300,400),(401,400),(50,0),(5,-9)]
run(g,'brewing arrow (5, E6): runs only while b > 0 and B > 0; a = trunc(28 x (1 - b / B)); drawn at (leftPos + 97, topPos + 16) (a, x, y)','MN2-BREW-ARROW','iiii',3,[(b,B,339,157) for b,B in ab],barrow)
TAB=[29,24,20,16,11,6,0]
def bub(b,B,l,t):
    if not(b>0 and B>0): return (0,0,0,0,0)
    i=(b//2)%7; L=TAB[i]
    if L>0: return (i,L,29-L,l+63,t+14+29-L)
    return (i,0,0,0,0)
run(g,'bubbles (5, E6): index (b / 2) mod 7 into 29, 24, 20, 16, 11, 6, 0; with L > 0 the bottom L rows at (leftPos + 63, topPos + 14 + 29 - L); only while a brew runs (index, L, source v, x, y)','MN2-BREW-BUBBLES','iiii',5,[(b,400,339,157) for b in (400,200,1,12,13,14,2,3,0)]+[(5,0,0,0)],bub)
run(g,'bubble sequence (5): as b counts down from 14 to 1 the index falls 6, 5, 4, 3, 2, 1, 0 in steps of two ticks and index 6 (no bubbles) holds for b mod 14 = 12 or 13 (the lengths for b = 14 .. 1)','MN2-BREW-BUBBLES','iiii',5,[(b,400,0,0) for b in range(14,0,-1)],bub)
W(g,5)
# ===== 6
g=G(6,'The crafter menu','T1019','slots, slot rules, data slots, preview rule and quick-move (core/src/menu-40-2.cob).')
def cslot(s):
    if 0<=s<=8: return (1,26+18*(s%3),17+18*(s//3))
    if 9<=s<=44:
        x,y=std_inv(s-9); return (2,x,y)
    if s==45: return (3,134,35)
    return (0,0,0)
run(g,'slot table (6.2, V3): nine crafting slots index = column + 3 row at (26 + 18 c, 17 + 18 r), the standard block 9 to 44, the result slot 45 at (134, 35) (part, x, y)','MN2-CRAFTER-SLOT','i',3,[(s,) for s in (0,1,2,3,4,8,9,35,36,44,45,46,-1)],cslot)
dis=lambda i,d:int(-1<i<9 and d==1)
run(g,'isSlotDisabled (6.4): true only for 0 <= index <= 8 with data 1; the result slot 45 and the inventory slots are never disabled (index, data)','MN2-CRAFTER-DISABLED','ii',1,[(i,d) for i in (0,4,8,9,45,-1) for d in (0,1)],dis)
run(g,'CrafterSlot.mayPlace (6.2): accepted exactly when the slot is not disabled (index, data)','MN2-CRAFTER-MAYPLACE','ii',1,[(i,d) for i in (0,4,8) for d in (0,1)],lambda i,d:1-dis(i,d))
run(g,'menu setSlotState (6.4): data[slot] = 0 when enabled, 1 when disabled (slot, enabled)','MN2-CRAFTER-MENU-SET','ii',1,[(4,0),(4,1),(0,0),(8,1)],lambda s,e:0 if e else 1)
def beset(s,empty,en):
    if 0<=s<=8 and empty: return (1,0 if en else 1)
    return (0,-1)
run(g,'block entity setSlotState (6.4, 7.2): ignored unless the index is 0 to 8 and the slot is empty; then the same value is written (slot, empty, enabled -> changed, value or -1)','MN2-CRAFTER-BE-SET','iii',2,[(4,1,0),(4,1,1),(4,0,0),(9,1,0),(-1,1,1),(0,1,0),(8,0,1)],beset)
cq=lambda s:(9,45,1) if 0<=s<=8 else (0,9,0)
run(g,'quick-move (6.5): a crafting slot moves into [9, 45) in reverse, anything else into [0, 9) forward; the result slot 45 is outside the first range (first, end, reverse)','MN2-CRAFTER-QUICK','i',3,[(s,) for s in (0,8,9,30,44)],cq)
run(g,'result preview (6.3): the client does nothing; the server sets the result container to the recipe product or to empty (isServer, recipe found -> 0 nothing, 1 product, 2 empty)','MN2-CRAFTER-PREVIEW','ii',1,[(0,0),(0,1),(1,1),(1,0)],lambda s,r:0 if not s else (1 if r else 2))
run(g,'NonInteractiveResultSlot (6.2, V15): mayPlace, mayPickup, allowModification and highlightable are false and the slot is fake','MN2-CRAFTER-RESULT','',5,[()],lambda :(0,0,0,0,1))
run(g,'powered flag (6.4): isPowered is data 9 equal to 1 (any other value is false)','MN2-CRAFTER-POWERED','i',1,[(0,),(1,),(2,),(-1,)],lambda d:int(d==1))
run(g,'data synchronisation (6.4, 1.4): broadcastChanges sends Container Set Data for a changed property, the value as a signed 16-bit short (last, current -> send, wire value)','MN2-DATA-SYNC','ii',2,[(0,1),(1,1),(0,0),(0,32768),(5,70000),(0,-1)],lambda a,b:(int(a!=b),wire(b)))
W(g,6)
# ===== 7
g=G(7,'The crafter screen','T1021','the slot toggle, its packet and sound, the drawing rules (core/src/menu-40-2.cob).')
def click(isc,has,spec,ty,dis_,cur,swp):
    if not(isc and not has and not spec): return 0
    if ty==0:
        if dis_: return 1
        if cur: return 2
        return 0
    if ty==1:
        if dis_ and swp: return 1
    return 0
rows=[(isc,has,sp,ty,d,cu,sw) for isc in (1,) for has in (0,) for sp in (0,) for ty in (0,1,2) for d in (0,1) for cu in (0,1) for sw in (0,1)]
rows+=[(0,0,0,0,1,1,1),(1,1,0,0,1,1,1),(1,0,1,0,1,1,1)]
run(g,'toggle rule (7.2, V13): only on an empty CrafterSlot and not as a spectator; PICKUP enables a disabled slot or disables an enabled one with an empty cursor; SWAP enables a disabled slot when the inventory stack is not empty; other types nothing (crafter slot, has item, spectator, type 0 pickup 1 swap 2 other, disabled, cursor empty, swap stack not empty -> 0 none, 1 enable, 2 disable)','MN2-CRAFTER-CLICK','iiiiiii',1,rows,click)
def upd(a,s,c):
    return (0 if a==1 else 1,s,c,1 if a==1 else 0,40,100 if a==1 else 75)
run(g,'enableSlot / disableSlot (7.2, E7): local data 0 or 1, Container Slot State Changed (slot id, container id, new state), sound ui.button.click volume 0.4 and pitch 1.0 when enabling, 0.75 when disabling (volume and pitch x 100) (action 1 enable 2 disable, slot, container -> data, slot, container, new state, volume, pitch)','MN2-CRAFTER-UPDATE','iii',6,[(2,4,7),(1,4,7),(1,0,1),(2,8,3)],upd)
srv=lambda sp,idm,ism,be:int((not sp) and idm and ism and be)
run(g,'server handling of 0x14 (7.2): ignored for a spectator, a different container id, a menu that is not a crafter menu or a container that is not the crafter block entity (spectator, id matches, crafter menu, block entity)','MN2-CRAFTER-SERVER','iiii',1,[(0,1,1,1),(1,1,1,1),(0,0,1,1),(0,1,0,1),(0,1,1,0)],srv)
def draw(s,d,mx,my,l,t):
    x=26+18*(s%3); y=17+18*(s//3)
    x0=l+x-2; y0=t+y-2
    p=int(x0<mx<x0+19 and y0<my<y0+19)
    return (d,x-1,y-1,p)
dr=[(4,1,339+44,157+35,339,157),(4,0,339+44,157+35,339,157),(4,0,339+25,157+16,339,157),(4,0,339+24,157+16,339,157),(4,0,339+25,157+35,339,157),(4,0,339+43,157+35,339,157),(4,0,339+44,157+53,339,157),(4,0,339+44,157+54,339,157),(0,1,100,100,0,0),(8,0,26+18*2+17,17+18*2+17,0,0)]
run(g,'drawing (7.3, E7): a disabled slot shows the 18 x 18 sprite at (slot.x - 1, slot.y - 1); the pointing hand is requested inside the 19 x 19 box from (leftPos + x - 2, topPos + y - 2), exclusive on all sides (slot, disabled, mouse x, mouse y, leftPos, topPos -> disabled sprite, sprite x, sprite y, pointer)','MN2-CRAFTER-DRAW','iiiiii',4,dr,draw)
tt=lambda h,d,c,i,s:int(h and not d and c and not i and not s)
run(g,'tooltip (7.3): gui.togglable_slot only for the hovered CrafterSlot that is enabled, with an empty cursor, no item and not a spectator (hovered crafter slot, disabled, cursor empty, has item, spectator)','MN2-CRAFTER-TOOLTIP','iiiii',1,[(1,0,1,0,0),(0,0,1,0,0),(1,1,1,0,0),(1,0,0,0,0),(1,0,1,1,0),(1,0,1,0,1)],tt)
def pw(w,h,p): return (w//2+9,h//2-48,int(bool(p)))
run(g,'powered indicator (7.3): a 16 x 16 sprite at (screenWidth / 2 + 9, screenHeight / 2 - 48), the powered one when data 9 is 1 (x, y, sprite 1 powered 0 unpowered)','MN2-CRAFTER-POWER','iii',3,[(854,480,1),(854,480,0),(853,481,1),(400,300,0)],pw)
run(g,'powered indicator (7.3): for even screen sizes it is (leftPos + 97, topPos + 35) with leftPos = (w - 176) / 2 and topPos = (h - 166) / 2 (x, y, sprite)','MN2-CRAFTER-POWER','iii',3,[(854,480,1),(400,300,0),(1000,700,1)],lambda w,h,p:((w-176)//2+97,(h-166)//2+35,int(p)))
W(g,7)
# ===== 8
g=G(8,'Packet summary for this part','T1023','menu type ids, slot and data counts, the data wire format and the packet table (core/src/menu-40-2.cob).')
KIND2={1:('crafter_3x3',7,10,46),2:('blast_furnace',10,4,39),3:('brewing_stand',11,4,41),4:('furnace',14,4,39),5:('smoker',22,4,39)}
run(g,'menu type ids (8, V16): crafter_3x3 7, blast_furnace 10, brewing_stand 11, furnace 14, smoker 22','MN2-PART-TYPE','i',1,[(k,) for k in range(1,6)],lambda k:KIND2[k][1])
run(g,'data slot counts and slot totals (V1 to V4): furnace family 4 data and 39 slots, brewing 4 and 41, crafter 10 and 46 (data slots, total slots)','MN2-PART-SIZE','i',2,[(k,) for k in range(1,6)],lambda k:(KIND2[k][2],KIND2[k][3]))
run(g,'Container Set Data (8, 1.4): property and value are 16-bit shorts, an out-of-range value wraps modulo 65536 (32768 arrives as -32768)','MN2-DATA-WIRE','i',1,[(v,) for v in (0,1200,32767,32768,65535,65536,-1,-32768,-32769,70000)],lambda v:wire(v))
PK=[(19,1),(17,0),(18,1),(20,1),(77,1),(47,1),(48,1),(39,1),(64,1)]
run(g,'packet table (8): Container Set Data 0x13, Container Button Click 0x11 (not used by this part), Container Click 0x12, Slot State Changed 0x14, Recipe Book Settings 0x4D, Change Settings 0x2F, Seen Recipe 0x30, Place Recipe 0x27, Place Ghost Recipe 0x40 (id, used here)','MN2-PART-PACKET','i',2,[(i,) for i in range(1,10)],lambda i:PK[i-1])
W(g,8)
