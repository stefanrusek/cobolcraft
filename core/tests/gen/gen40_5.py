import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-5-merchant-beacon-lectern.md (sections 1 to 4). Single precision steps are binary32 values.
def G5(n,subj,tasks,desc):
    return GG('TEST-MENU-40-5-%d'%n,'40-5§%d'%n,subj,tasks,desc,None)
def W(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_5_%d.cob'%n)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def fl(x): return int(math.floor(x))
def clamp(v,lo,hi): return lo if v<lo else min(v,hi)
def T(*a): return "|".join(str(x) for x in a)
def runtx(g,text,name,ins,rows,model,n2=2):
    # text outputs: the model returns the two texts
    runt(g,text,name,ins,rows,model)
# ===== 1
g=G5(1,'Shared facts','T1051','menu type ids, summary, packets, offer wire and persisted defaults (core/src/menu-40-5.cob).')
ID={1:(19,3,39,0),2:(9,1,37,3),3:(17,1,1,1)}
run(g,'1.1, 1.2: type ids merchant 19, beacon 9, lectern 17 with own slots, total slots and data slots (kind 1 merchant 2 beacon 3 lectern)','MN5-IDENT','i',4,[(k,) for k in (1,2,3)],lambda k:ID[k])
IM={1:(276,166,512,256),2:(230,219,256,256),3:(0,0,256,256)}
run(g,'1.2: image size and background texture size (the lectern is a book view, no container image: 0 x 0)','MN5-IMAGE','i',4,[(k,) for k in (1,2,3)],lambda k:IM[k])
TK={1:('',''),2:('container.beacon','Beacon'),3:('container.lectern','Lectern')}
runt(g,'3.1, 4.1: default title key and English text (the merchant title is given by the caller)','MN5-TITLEKEY','i',[(k,) for k in (2,3)],lambda k:TK[k])
PK={1:(7,0x3C,0),2:(1,0x35,0),3:(6,0x13,0),4:(4,0x11,1),5:(1,0x34,1),6:(2,0x35,1)}
run(g,'1.3: packets (1 Open Screen, 2 Merchant Offers, 3 Container Set Data, 4 Container Button Click, 5 Select Trade, 6 Set Beacon) -> menus using it (merchant 1, beacon 2, lectern 4), packet id, serverbound','MN5-PACKET','i',3,[(k,) for k in range(1,7)],lambda k:PK[k])
def bok(i,s,v,r):
    c=int(i and not s and v)
    return (c,int(c and r))
run(g,'1.3: Container Button Click is acted on only for the open container id, not for a spectator, while stillValid; broadcastChanges follows a true result (id equal, spectator, valid, result -> acted, broadcast)','MN5-BUTTON-OK','iiii',2,[(i,s,v,r) for i in (0,1) for s in (0,1) for v in (0,1) for r in (0,1)],bok)
run(g,'1.3: an offer on the wire has its out-of-stock flag applied by forcing uses to maxUses, then specialPriceDiff (uses, maxUses, flag, special -> uses, special)','MN5-OFFER-DECODE','iiii',2,[(2,12,0,-3),(2,12,1,-3),(0,4,1,5),(12,12,0,0)],lambda u,m,f,s:(m if f else u,s))
DF={1:0,2:4,3:1,4:0,5:0,6:0,7:1,8:1,9:-1}
run(g,'1.3: persisted offer defaults (1 uses 0, 2 maxUses 4, 3 rewardExp true, 4 specialPrice 0, 5 demand 0, 6 priceMultiplier 0.0, 7 xp 1, 8 item cost count 1; others -1)','MN5-OFFER-DEFAULT','i',1,[(k,) for k in range(1,10)],lambda k:DF[k])
W(g,1)
# ===== 2
g=G5(2,'Merchant','T1053','slots, container operations, offer arithmetic, updateSellItem, result slot, trade selection, quick-move, lifecycle and screen (core/src/menu-40-5.cob).')
def mslot(s):
    if s==0: return (136,37,0,1)
    if s==1: return (162,37,0,1)
    if s==2: return (220,37,1,1)
    if 3<=s<=29:
        j=s-3; return (108+18*(j%9),84+18*(j//9),0,2)
    if 30<=s<=38: return (108+18*(s-30),142,0,3)
    return (0,0,0,0)
run(g,'2.2: slot table: payment slots (136, 37) and (162, 37), the result slot (220, 37), main from (108, 84), hotbar at y 142 (slot -> x, y, result class, part)','MN5-M-SLOT','i',4,[(s,) for s in (0,1,2,3,11,12,29,30,38,39)],mslot)
run(g,'2.2: setItem limits the count to the container default 64 and the item limit (count, item max -> count)','MN5-M-LIMIT','ii',1,[(10,64),(70,64),(5,16),(40,16),(64,1)],lambda c,m:min(c,64,m))
def mrem(s,ne,n,c):
    if s==2 and ne: return (c,0)
    r=min(n,c) if ne else 0
    return (r,int(r>0 and s<2))
run(g,'2.3: removeItem: the result slot gives the whole stack; slots 0 and 1 give up to n and update the sell item when something left (slot, non-empty, n, count -> removed, update)','MN5-M-REMOVE','iiii',2,[(2,1,1,9),(2,0,1,0),(0,1,5,64),(1,1,5,3),(0,0,5,0),(1,1,0,9)],mrem)
run(g,'2.3: setItem on slots 0 and 1 runs updateSellItem (slot -> update)','MN5-M-SETUPDATE','i',1,[(0,),(1,),(2,)],lambda s:int(s<2))
def mprice(c,d,m,s,mx):
    p=f32(f32(c*d)*f32(m))
    adj=max(0,fl(p))
    return (adj,clamp(c+adj+s,1,mx))
rows=[(7,2,0.2,-3,64),(1,0,0.2,-5,64),(4,12,0.2,0,64),(4,-3,0.2,0,64),(5,2,0.2,0,64),(30,40,0.5,0,64),(10,5,0.05,0,16),(3,1,0.1,2,64),(16,100,0.5,0,16),(2,3,0.0,-9,64)]
run(g,'2.4, E1, E2: modified first cost: adj = max(0, floor(float(c x d) x m)), count = clamp(c + adj + s, 1, max stack) (c, demand, multiplier, special, max stack -> adj, count)','MN5-M-PRICE','iifii',2,rows,mprice)
run(g,'2.4: exact component predicate: an expected component matches by null-safe equality (expected null, stack null, equal -> ok)','MN5-M-COMPONENT','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:int((a and b) or (not a and not b and c)))
run(g,'2.4: an item cost matches when the stack is of the item and the predicate passes (same item, predicate ok -> match)','MN5-M-MATCH','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:a&b)
def msat(am,ac,ca,hb,bm,bc,cb,be):
    if not (am and ac>=ca): return 0
    if hb: return int(bm and bc>=cb)
    return be
rows=[(1,10,8,0,0,0,0,1),(1,8,8,0,0,0,0,1),(1,7,8,0,0,0,0,1),(0,10,8,0,0,0,0,1),(1,10,8,0,0,0,0,0),(1,10,8,1,1,5,5,0),(1,10,8,1,1,4,5,0),(1,10,8,1,0,9,5,0),(1,10,8,1,1,5,5,1),(1,5,8,1,1,5,5,0)]
run(g,'2.4: satisfiedBy: first cost matches with a count at least the modified count; a second cost matches with its own count, else the second stack is empty (a match, a count, cost, has B, b match, b count, b cost, b empty -> ok)','MN5-M-SATISFIED','iiiiiiii',1,rows,msat)
def mtake(sat,a,ca,hb,b,cb):
    if not sat: return (0,a,b)
    return (1,a-ca,b-cb if hb else b)
run(g,'2.4: take shrinks the first stack by the modified count and the second by its cost, only when satisfied (satisfied, a, cost a, has B, b, cost B -> ok, a, b)','MN5-M-TAKE','iiiiii',3,[(1,64,13,0,0,0),(1,20,8,1,9,5),(0,20,8,1,9,5),(1,13,13,1,5,5)],mtake)
def mrec(h,sz,*f):
    if 0<h<sz: return h if f[h] else -1
    for i in range(sz):
        if f[i]: return i
    return -1
rows=[(0,3,0,1,1,0,0,0,0,0),(0,3,0,0,0,0,0,0,0,0),(2,3,1,1,0,0,0,0,0,0),(2,3,1,1,1,0,0,0,0,0),(1,3,1,1,1,0,0,0,0,0),(-1,3,0,1,0,0,0,0,0,0),(5,3,0,0,1,0,0,0,0,0),(3,3,0,0,1,0,0,0,0,0),(7,8,0,0,0,0,0,0,0,1),(0,8,0,0,0,0,0,0,0,1)]
run(g,'2.4 getRecipeFor: hint 1 to size - 1 tries one offer, any other hint scans from the first (hint, size, flags of offers 0 to 7 -> index or -1)','MN5-M-RECIPE','iiiiiiiiii',1,rows,mrec)
run(g,'2.4 other offer facts: out of stock at uses >= maxUses, needs restock at uses > 0, increaseUses, updateDemand = demand + uses - (maxUses - uses) (uses, maxUses, demand -> out of stock, needs restock, uses + 1, new demand)','MN5-M-OFFERFACTS','iii',4,[(0,12,0),(1,12,3),(12,12,0),(6,4,2),(12,12,12)],lambda u,m,d:(int(u>=m),int(u>0),u+1,d+u-(m-u)))
def mupd(s0,s1,oe,o1,o2):
    if s0 and s1: return (0,0,0,0,0)
    if oe: return (0,2,0,1,0)
    if o1==1: return (1,1,1,1,0)
    act=1 if o1==2 else 0
    if o2==1: return (2,1,1,1,1)
    return (act,0,0,1,1)
rows=[(1,1,0,1,1),(0,1,0,1,0),(1,0,0,1,0),(0,0,1,1,1),(0,0,0,0,0),(0,0,0,0,1),(0,0,0,2,0),(0,0,0,2,1),(0,0,0,2,2),(0,0,0,0,2),(0,1,0,0,0)]
run(g,'2.4 updateSellItem: the merchant is notified unless the first payment is empty; an empty offer list leaves the result; a missing or out-of-stock first match tries the swapped payments; an out-of-stock first match stays active (s0 empty, s1 empty, offers empty, first lookup 0 none 1 ok 2 out, swapped -> active 0 none 1 first 2 swapped, result 0 empty 1 offer 2 unchanged, xp from offer, notify, swapped tried)','MN5-M-UPDATE','iiiii',5,rows,mupd)
run(g,'2.5: mayPickup of the result slot needs an active offer satisfied in either payment order (active, satisfied 0 1, satisfied 1 0 -> may pickup)','MN5-M-PICKUP','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:int(a and (b or c)))
def mtkn(a,t1,t2):
    if not a: return (0,0,0,0,0)
    if t1: return (1,1,1,1,1)
    if t2: return (1,2,1,1,1)
    return (0,0,0,0,1)
run(g,'2.5, E6: onTake: the first take order that succeeds shrinks the stacks, notifies the trade and counts the statistic; the XP override happens whenever an offer is active (active, take 1 ok, take 2 ok -> took, order, notify, statistic, xp override)','MN5-M-TAKEN','iii',5,[(0,1,1),(1,1,0),(1,0,1),(1,0,0),(1,1,1)],mtkn)
def mrc(op,rc,n,c):
    if op==1: return (rc+min(n,c),0)
    if op==2: return (0,rc+n)
    return (0,rc)
run(g,'2.5 removeCount: remove(n) adds min(n, count); onQuickCraft adds the delta then checks achievements; the check hands removeCount to onCraftedBy and resets it (op 1 remove 2 quick craft 3 check, removeCount, n, count -> removeCount, crafted)','MN5-M-REMCOUNT','iiii',2,[(1,0,64,1),(1,5,3,9),(2,2,4,0),(3,7,0,0),(3,0,0,0)],mrc)
def mtry(i,cnt,b0,a0,b1,a1):
    if i<0 or i>=cnt: return 0
    if b0>0:
        if a0==b0: return 1
    n0=a0 if b0>0 else 0
    if b1>0:
        if a1==b1: return 1
    n1=a1 if b1>0 else 0
    return 3 if (n0==0 and n1==0) else 2
rows=[(-1,3,0,0,0,0),(3,3,0,0,0,0),(0,3,0,0,0,0),(0,3,40,0,0,0),(0,3,40,40,0,0),(0,3,40,10,0,0),(0,3,0,0,30,0),(0,3,0,0,30,30),(1,3,40,0,30,0),(1,3,40,0,30,5)]
run(g,'2.7 tryMoveItems: index in range; return the payments (a failed move stops, a partly moved payment keeps the slot occupied); only with both empty fill from the base cost (index, offers, slot 0 before, after, slot 1 before, after -> 0 range stop 1 move failed 2 not empty 3 fill)','MN5-M-TRYMOVE','iiiiii',1,rows,mtry)
def mfill(m,sc,cur,same,mx):
    if not m or (cur>0 and not same): return (1,0,cur,0)
    n=min(mx-cur,sc)
    return (0,n,cur+n,int(cur+n>=mx))
rows=[(1,40,0,0,64),(1,30,40,1,64),(0,40,0,0,64),(1,40,10,0,64),(1,5,5,1,64),(1,64,0,0,64),(1,9,0,0,16),(1,20,16,1,16)]
run(g,'2.7 fill step: skip a stack that does not match or whose item differs from a non-empty payment; else move min(max - current, stack) and stop at a full payment (matches, stack count, current, same item, max -> skipped, moved, payment, full)','MN5-M-FILL','iiiii',4,rows,mfill)
def mfr(mx,*c):
    cur=0; r=list(c)
    for i in range(4):
        n=min(mx-cur,r[i]); cur+=n; r[i]-=n
        if cur>=mx: break
    return (cur,)+tuple(r)
run(g,'2.7, E5: filling the payment slot over main slots 3, 4, 5, 6 that all match: 40 and 30 emeralds with max 64 leave 0 and 6; a small cost still moves the whole stack (max, counts of four slots -> payment, remaining counts)','MN5-M-FILLRUN','iiiii',5,[(64,40,30,0,0),(64,10,10,10,10),(64,64,5,5,5),(16,5,5,5,5),(64,0,0,0,0)],mfr)
def mq(s):
    if s==2: return (3,39,1,1,0)
    if s in (0,1): return (3,39,0,0,0)
    if 3<=s<=29: return (30,39,0,0,0)
    if 30<=s<=38: return (3,30,0,0,0)
    return (0,0,0,0,0)
run(g,'2.8: quick-move: result to [3, 39) in reverse then onQuickCraft and the sound; payment slots forward to [3, 39); main to [30, 39); hotbar to [3, 30); pick-all never gathers (slot -> start, end, reverse, extra, canTakeItemForPickAll)','MN5-M-QUICK','i',5,[(s,) for s in (2,0,1,3,29,30,38,39)],mq)
runt(g,'2.8, 2.9: the trade sound events (kind 1 villager 2 wandering trader, yes flag)','MN5-M-SOUNDKEY','ii',[(1,1),(1,0),(2,1),(2,0)],lambda k,y:(("villager" if k==1 else "wandering_trader")+(".yes" if y else ".no"),"neutral"))
def mts(a,sv,e):
    p=int(sv and a>-60)
    return (p,-80 if p else a,int(not e))
run(g,'2.9 notifyTradeUpdated: on the server a sound plays when ambientSoundTime > -60, which then becomes -80; yes for a non-empty result (ambient time, server, result empty -> play, new time, yes)','MN5-M-TRADESOUND','iii',3,[(0,1,0),(-59,1,1),(-60,1,0),(-80,1,0),(0,0,0)],mts)
def mrm(cl,al,sp,dc):
    if cl: return 0
    if not al or (sp and dc): return 1
    return 2 if sp else 0
run(g,'2.9 removed: the client stops; on the server a dead or disconnected player drops both payments (1), a server player gets them back in the inventory (2) (client, alive, server player, disconnected -> action)','MN5-M-REMOVED','iiii',1,[(1,1,1,0),(0,0,1,0),(0,1,1,1),(0,1,1,0),(0,1,0,0),(0,0,0,0)],mrm)
run(g,'2.9 stillValid: the trading player is this player, the entity is alive and within 4.0 (trading, alive, distance -> valid)','MN5-M-VALID','iif',1,[(1,1,3.5),(1,1,4.5),(0,1,1.0),(1,0,1.0),(1,1,0.0)],lambda t,a,d:int(t and a and d<=4.0))
run(g,'2.9 Merchant Offers handling: applied only when the container id equals the open menu and the menu is a merchant menu (id, open id, is merchant -> applied)','MN5-M-OFFERS-APPLY','iii',1,[(3,3,1),(3,4,1),(3,3,0),(0,0,1)],lambda a,b,c:int(a==b and c))
run(g,'2.10 row buttons: button k is made visible when its own index is below the offer count (k, offer count -> visible)','MN5-M-ROWBTN','ii',1,[(0,0),(0,1),(6,7),(6,6),(3,12),(7,12)],lambda k,n:int(n>0 and k<n))
run(g,'2.10 row buttons: button k at (leftPos + 5, topPos + 18 + 20 k), 88 x 20 (k, leftPos, topPos -> x, y, w, h)','MN5-M-BTNPOS','iii',4,[(0,339,157),(6,339,157),(3,0,0)],lambda k,l,t:(l+5,t+18+20*k,88,20))
run(g,'2.10 rows: positions of the visible row r at y topPos + 19 + 20 r: first cost x + 10, second x + 40, arrow (x + 60, y + 3), result x + 73 (r, leftPos, topPos -> first x, y, second x, arrow x, arrow y, result x)','MN5-M-ROWPOS','iii',6,[(0,339,157),(6,339,157),(2,0,0)],lambda r,l,t:(l+10,t+19+20*r,l+40,l+60,t+19+20*r+3,l+73))
def mdr(n,so):
    if n>7: return (so,min(so+7,n))
    return (0,n)
run(g,'2.10 rows: all offers are drawn when there are at most 7, else offers scrollOff to scrollOff + 6 (offers, scrollOff -> first, end)','MN5-M-DRAWN','ii',2,[(0,0),(3,0),(7,0),(8,0),(8,1),(10,2),(10,3)],mdr)
def mdec(b,m,x,y):
    if b==m: return (0,b,x,0,0,0,0)
    return (1,1 if b==1 else b,x,1 if m==1 else m,x+14,x+7,y+12)
run(g,'2.10 first cost: equal counts are drawn once; otherwise the base count (forced 1 text for a count of 1), the modified count 14 to the right and the strike sprite at (x + 7, y + 12) (base, modified, x, y -> mode, base text, base x, modified text, modified x, strike x, strike y)','MN5-M-DECOR','iiii',7,[(8,8,349,176),(7,6,349,176),(1,2,349,176),(3,1,0,0),(1,1,10,10)],mdec)
def mscr(n0,so):
    n=n0-6
    if n<=1: return (1,n,0,0,0)
    h=139-(27+(n-1)*139//n)
    # Java integer division truncates toward zero: h can be negative for 14 or more extra offers
    step=1+int(h/n)+139//n
    t=min(113,so*step)
    if so==n-1: t=113
    return (0,n,h,step,t)
run(g,'2.10, E3, 5.7: scroller thumb: n = offers - 6; disabled for n <= 1; h = 139 - (27 + (n - 1) x 139 / n), step = 1 + h / n + 139 / n, t = min(113, scrollOff x step), 113 for the last offset (offers, scrollOff -> disabled, n, h, step, t)','MN5-M-SCROLLER','ii',5,[(7,0),(8,0),(8,1),(10,0),(10,1),(10,2),(10,3),(20,5),(20,14),(3,0)],mscr)
def mwh(n,so,sy):
    if n<=7: return so
    return clamp(int(so-sy),0,n-7)
run(g,'2.10 wheel: with more than 7 offers scrollOff = clamp(int(scrollOff - wheel), 0, offers - 7), truncated toward zero (offers, scrollOff, wheel -> scrollOff)','MN5-M-WHEEL','iif',1,[(10,0,-1.0),(10,2,1.0),(10,0,1.0),(10,3,-5.0),(7,0,-1.0),(10,1,0.5),(10,1,-0.5),(10,1,-1.7)],mwh)
def mpr(px,py,l,t,n):
    return int(n>7 and l+94<px<l+100 and py>t+18 and py<=t+18+139+1)
run(g,'2.10 press: dragging starts when scrolling is possible and the pointer is strictly inside x 94 to 100 and y above 18 to at most 158 (px, py, leftPos, topPos, offers -> dragging)','MN5-M-PRESS','iiiii',1,[(433+1,176,339,157,10),(339+95,176,339,157,10),(339+94,176,339,157,10),(339+100,176,339,157,10),(339+97,157+18,339,157,10),(339+97,157+19,339,157,10),(339+97,157+158,339,157,10),(339+97,157+159,339,157,10),(339+97,200,339,157,7)],mpr)
def mdg(my,t,n):
    f=(my-(t+18)-13.5)/(139-27.0)*(n-7)+0.5
    return clamp(int(f),0,n-7)
run(g,'2.10, E3 drag: f = (mouseY - top - 13.5) / (139 - 27) x maxOff + 0.5, scrollOff = clamp(int(f), 0, maxOff) (mouseY, topPos + 18 handled, offers -> scrollOff)','MN5-M-DRAG','iii',1,[(70+18,0,10),(0,0,10),(500,0,10),(100,0,20),(30,0,8)],mdg)
run(g,'2.10 out-of-stock cross: drawn when the offer list is not empty, the selected index is valid and out of stock; the sprite at (leftPos + 182, topPos + 35) (offers, selected, out of stock -> drawn)','MN5-M-CROSS','iii',1,[(0,0,1),(3,0,1),(3,2,1),(3,3,1),(3,-1,1),(3,1,0)],lambda n,s,o:int(n>0 and 0<=s<n and o))
def mtip(o,x,y,c): return int(o and 186<=x<208 and 35<=y<56 and c)
run(g,'2.10 out-of-stock tooltip: pointer in x 186 to 208, y 35 to 56 relative, selected offer out of stock and canRestock (out of stock, x, y, canRestock -> tooltip)','MN5-M-CROSSTIP','iiii',1,[(1,186,35,1),(1,207,55,1),(1,208,35,1),(1,185,35,1),(1,190,56,1),(1,190,40,0),(0,190,40,1)],mtip)
def mlab(lv,sh,tw,rw):
    return (int(1<=lv<=5 and sh),187-tw//2,53-rw//2,107,72)
run(g,'2.10 labels: the title carries the level for levels 1 to 5 with the progress bar; title x 187 - width / 2, trades x 53 - width / 2, inventory label (107, 72) (level, progress bar, title width, trades width -> level in title, title x, trades x, inventory x, y)','MN5-M-LABELS','iiii',5,[(1,1,60,31),(5,1,61,30),(0,1,60,31),(6,1,60,31),(3,0,60,31)],mlab)
LN=['Novice','Apprentice','Journeyman','Expert','Master']
runt(g,'2.10 merchant.level.1 to .5 and the texts of the screen (level -> level text, key)','MN5-M-LEVELNAME','i',[(k,) for k in range(1,6)],lambda k:(LN[k-1],"merchant.level.%d"%k))
TH=[0,10,70,150,250]
def mxp(lv,xp,fu):
    if lv>=5: return (0,-1,-1)
    if lv<1: return (1,-1,-1)
    mn=TH[lv-1]; mx=TH[lv]
    if xp<mn: return (1,-1,-1)
    sc=f32(102.0/(mx-mn)); cur=min(fl(f32(sc*(xp-mn))),102)
    w=-1
    if fu>0: w=min(fl(f32(fu*sc)),102-cur)
    return (1,cur,w)
rows=[(2,40,5),(1,5,0),(3,110,0),(3,100,0),(5,10,5),(1,0,0),(1,0,3),(1,9,100),(2,5,5),(4,250,1),(4,249,2),(0,3,3),(2,70,9),(1,10,0)]
run(g,'2.10, E4 xp bar: no bar at level 5; the background below it; the filled part scale x (xp - min) with scale 102 / (max - min) in single precision; the preview width min(floor(future x scale), 102 - cur) (level, xp, future xp -> background, filled width or -1, preview width or -1)','MN5-M-XPBAR','iii',3,rows,mxp)
def mrt(dx,sn):
    if dx<20: return 1
    if 30<dx<50 and sn: return 2
    if dx>65: return 3
    return 0
run(g,'2.10 row tooltips: pointer x relative to the button: below 20 the first cost, 31 to 49 the second cost when not empty, above 65 the result, otherwise none (dx, second not empty -> tooltip)','MN5-M-ROWTIP','ii',1,[(0,1),(19,1),(20,1),(30,1),(31,1),(49,1),(50,1),(31,0),(65,1),(66,1),(87,0)],mrt)
SP={1:('container/villager/trade_arrow','10x9'),2:('container/villager/trade_arrow_out_of_stock','10x9'),3:('container/villager/discount_strikethrough','9x2'),4:('container/villager/scroller','6x27'),5:('container/villager/scroller_disabled','6x27'),6:('container/villager/out_of_stock','28x21'),7:('container/villager/experience_bar_background','102x5'),8:('container/villager/experience_bar_current','102x5'),9:('container/villager/experience_bar_result','102x5')}
runt(g,'2.10 sprites of the merchant screen and their sizes (1 arrow, 2 arrow out of stock, 3 strike-through, 4 scroller, 5 scroller disabled, 6 out of stock cross, 7 to 9 experience bar)','MN5-M-SPRITE','i',[(k,) for k in range(1,10)],lambda k:SP[k])
W(g,2)
# ===== 3
g=G5(3,'Beacon','T1055','slots, data slots, effects, Set Beacon validation, quick-move, buttons and screen (core/src/menu-40-5.cob).')
def bsl(s):
    if s==0: return (136,110,1)
    if 1<=s<=27:
        j=s-1; return (36+18*(j%9),137+18*(j//9),2)
    if 28<=s<=36: return (36+18*(s-28),195,3)
    return (0,0,0)
run(g,'3.2: slot table: payment (136, 110), main from (36, 137), hotbar at y 195 (slot -> x, y, part)','MN5-B-SLOT','i',3,[(s,) for s in (0,1,10,27,28,36,37)],bsl)
PAY=['netherite_ingot','emerald','diamond','gold_ingot','iron_ingot']
runt(g,'3.2, 3.7 payment tag items and their icon x (the five items of beacon_payment_items; 0 is not one)','MN5-B-PAYITEM','i',[(k,) for k in range(1,6)],lambda k:(PAY[k-1],[20,41,63,86,108][k-1]))
g.case('3.2 mayPlace of the payment slot: the stack is in the item tag beacon_payment_items (five items, maximum stack size 1)',[('0','MOVE "%s" TO WS-T1\nCALL "MN5-B-TAGGED" USING WS-T1 WS-R(1) WS-R(2)'%nm,2) for nm in ('emerald','diamond','iron_ingot','netherite_ingot','gold_ingot','gold_block','stick','emerald_block')],"1/1 1/1 1/1 1/1 1/1 0/1 0/1 0/1 ")
EFF=[0,2,10,7,4,9]
def enc(e): return 0 if e<0 else e+1
run(g,'3.3 encodeEffect: none is 0, otherwise the registry id + 1 (speed 0 is 1, haste 2 is 3, regeneration 9 is 10)','MN5-B-ENCODE','i',1,[(-1,),(0,),(2,),(9,),(39,)],enc)
VAL={0,2,10,7,4,9}
def fil(e): return e if e in VAL else -1
run(g,'3.3 filterEffect keeps only the valid beacon effects speed 0, haste 2, resistance 10, jump boost 7, strength 4, regeneration 9 (the doc says seven but lists six: the lists are used)','MN5-B-FILTER','i',1,[(-1,),(0,),(1,),(2,),(3,),(4,),(7,),(9,),(10,),(11,)],fil)
def bsd(i,v,sv,bm):
    if i==0: return (v,0)
    st=enc(fil(v-1 if v>0 else -1))
    return (st,int(i==1 and sv and bm))
run(g,'3.3 setData: index 0 stores the levels; index 1 and 2 store filterEffect(decode(value)) encoded; only index 1, on the server with a beam, plays the power select sound (index, value, server, beam -> stored, sound)','MN5-B-SETDATA','iiii',2,[(0,3,1,1),(1,1,1,1),(1,1,0,1),(1,1,1,0),(1,2,1,1),(2,10,1,1),(2,3,1,1),(1,0,1,1),(2,0,1,1)],bsd)
RQ={0:1,2:1,10:2,7:2,4:3,9:4}
def rq(e):
    if e<0: return 0
    return RQ.get(e,2147483647)
run(g,'3.4 requiredLevels: the 1-based index of the tier list (speed, haste 1; resistance, jump boost 2; strength 3; regeneration 4), 0 for none, the int maximum for another effect','MN5-B-REQ','i',1,[(-1,),(0,),(2,),(10,),(7,),(4,),(9,),(1,),(39,)],rq)
def val(p,s,lv):
    if s>=0 and lv<4: return 0
    rp=rq(p); rs=rq(s)
    if rp>lv or rs>lv: return 0
    if rp>=4: return 0
    if rs!=0 and rs<4 and p!=s: return 0
    return 1
rows=[(0,-1,3),(0,0,4),(2,9,4),(4,7,4),(9,-1,3),(9,-1,4),(0,9,3),(4,-1,2),(-1,-1,4),(-1,9,4),(-1,0,4),(1,-1,4),(10,10,4),(7,7,4),(10,7,4),(0,-1,0),(4,-1,3),(0,-1,1),(7,-1,1),(7,-1,2)]
run(g,'3.4, E7 validateEffects (primary, secondary, levels): a secondary needs level 4; levels at least the required ones; regeneration or an invalid primary fails; a secondary below tier 4 must equal the primary','MN5-B-VALIDATE','iii',1,rows,val)
def bup(hp,p,s,lv):
    if not hp or not val(p,s,lv): return (0,0,0,0)
    return (1,enc(p),enc(s),1)
run(g,'3.4 updateEffects: false with an empty payment or invalid choices; else data slots 1 and 2 are the encoded effects and the payment shrinks by 1 (has payment, primary, secondary, levels -> performed, data 1, data 2, payment used)','MN5-B-UPDATE','iiii',4,[(1,0,-1,3),(1,0,0,4),(1,2,9,4),(1,-1,-1,4),(0,0,-1,3),(1,9,-1,4),(1,4,7,4)],bup)
def bqk(ix,cnt,pe,mp):
    if ix==0: return (1,37,1,1,1)
    if pe and mp and cnt==1: return (0,1,0,0,2)
    if 1<=ix<28: return (28,37,0,0,3)
    if 28<=ix<37: return (1,28,0,0,4)
    return (0,0,0,0,0)
rows=[(0,1,0,1),(0,1,1,1),(5,1,1,1),(5,2,1,1),(5,1,0,1),(5,1,1,0),(27,1,0,1),(28,1,0,0),(36,3,0,0),(28,1,1,1),(37,1,0,0)]
run(g,'3.5 quick-move: payment to [1, 37) in reverse with onQuickCraft; a single acceptable item to slot 0 when it is empty; main to the hotbar [28, 37); hotbar to main [1, 28) (index, count, payment empty, mayPlace -> start, end, reverse, extra, rule)','MN5-B-QUICK','iiii',5,rows,bqk)
run(g,'3.6 removed: only on the server a non-empty payment stack is dropped at the player, not placed back (server, payment not empty -> drop)','MN5-B-REMOVED','ii',1,[(1,1),(1,0),(0,1),(0,0)],lambda s,p:s&p)
def bbt(k,t,j):
    if k==1:
        n=[2,2,1][t]; w=n*22+(n-1)*2
        return (76+24*j-w//2,22+25*t)
    if k==2: return (167+24*j-23,47)
    if k==3: return (167+24-23,47)
    if k==4: return (164,107)
    return (190,107)
rows=[(1,0,0),(1,0,1),(1,1,0),(1,1,1),(1,2,0),(2,3,0),(3,3,1),(4,0,0),(5,0,0)]
run(g,'3.7, E9 button positions: primary tiers (53, 22) (77, 22), (53, 47) (77, 47), (65, 72); secondary regeneration (144, 47), the upgrade (168, 47), confirm (164, 107), cancel (190, 107) (kind 1 primary 2 secondary 3 upgrade 4 confirm 5 cancel, tier, index -> x, y)','MN5-B-BUTTON','iii',2,rows,bbt)
def bbg(ia,se,ho): return 0 if ia else 1 if se else 2 if ho else 3
run(g,'3.7 button background sprite: disabled, selected, highlighted, plain (inactive, selected, hovered or focused -> 0 disabled 1 selected 2 highlighted 3 plain)','MN5-B-BG','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],bbg)
def bpw(t,lv,eq): return (int(t<lv),eq)
run(g,'3.7 updateStatus of a power button: active when tier < levels, selected when its effect equals the screen choice (tier, levels, effect equal -> active, selected)','MN5-B-POWER','iii',2,[(0,1,0),(1,1,1),(2,3,1),(2,2,0),(3,4,1),(3,3,1)],bpw)
def bup2(p,lv,eq):
    if p<0: return (0,0,0)
    return (1,int(3<lv),eq)
run(g,'3.7 updateStatus of the upgrade button: hidden while the primary is none; else visible with tier 3, active when levels is 4, selected when the secondary equals the primary (primary, levels, secondary equals -> visible, active, selected)','MN5-B-UPGRADE','iii',3,[(-1,4,0),(0,3,0),(0,4,0),(2,4,1),(9,0,1)],bup2)
run(g,'3.7 updateStatus of the confirm button: payment present and a primary effect (has payment, primary -> active)','MN5-B-CONFIRM','ii',1,[(1,0),(1,-1),(0,0),(0,-1)],lambda h,p:int(h and p>=0))
def bpr(k,sel,e,p,s):
    if k==3: e=p
    if sel: return (p,s)
    if k==1: return (e,-1 if s!=e else s)
    return (p,e)
run(g,'3.7 presses: a primary button sets the primary and clears a secondary that differs; the secondary and upgrade buttons set the secondary (the upgrade uses the primary); nothing when already selected (kind 1 primary 2 secondary 3 upgrade, selected, effect, primary, secondary -> primary, secondary)','MN5-B-PRESS','iiiii',2,[(1,0,2,0,9),(1,0,0,0,0),(1,1,2,2,-1),(2,0,9,0,-1),(2,1,9,0,9),(3,0,0,0,-1),(3,1,7,7,7),(3,0,0,4,-1),(1,0,10,0,10)],bpr)
def blb(w,x): return ((62 if w==1 else 169)-x//2,10,-2039584,1)
runt(g,'3.7 labels: Primary Power centred on x 62 and Secondary Power on x 169, y 10, colour #e0e0e0 with shadow (which)','MN5-B-LABELTEXT','i',[(1,),(2,)],lambda k:("block.minecraft.beacon.primary" if k==1 else "block.minecraft.beacon.secondary","Primary Power" if k==1 else "Secondary Power"))
run(g,'3.7 label position: x - width / 2, y 10, colour -2039584, shadow 1 (which, text width -> x, y, colour, shadow)','MN5-B-LABEL','ii',4,[(1,90),(2,101),(1,0),(2,7)],blb)
EN={0:'speed',2:'haste',10:'resistance',7:'jump_boost',4:'strength',9:'regeneration'}
ET={0:'Speed',2:'Haste',10:'Resistance',7:'Jump Boost',4:'Strength',9:'Regeneration'}
runt(g,'3.7 power button sprite mob_effect/<name> and tooltip; the upgrade tooltip adds II (effect, upgrade)','MN5-B-EFFECTTEXT','ii',[(0,0),(2,0),(10,0),(7,0),(4,0),(9,0),(0,1),(9,1)],lambda e,u:("mob_effect/"+EN[e],ET[e]+(" II" if u else "")))
run(g,'3.7 confirm, cancel: Set Beacon sent and the container closed by confirm; cancel only closes (1 confirm 2 cancel -> send, close)','MN5-B-ENDBUTTON','i',2,[(1,),(2,)],lambda k:(int(k==1),1))
W(g,3)
# ===== 4
g=G5(4,'Lectern','T1057','slot, page data slot, buttons, redstone signal, book view layout, keys and the lectern screen (core/src/menu-40-5.cob).')
run(g,'4.2 slot 0 at (0, 0): mayPlace true, the book container canPlaceItem false for every slot (slot -> x, y, mayPlace, container canPlaceItem)','MN5-L-SLOT','i',4,[(0,)],lambda s:(0,0,1,0))
def lpc(wp,wn,rp,rn): return wn if wp else rn if rp else 0
run(g,'4.3 page count: the written book pages, else the writable book pages, else 0 (written present, pages, writable present, pages -> count)','MN5-L-PAGECOUNT','iiii',1,[(1,5,0,0),(1,5,1,9),(0,0,1,9),(0,0,0,0)],lpc)
run(g,'4.2 hasBook: the stack has writable_book_content or written_book_content (written, writable -> has book)','MN5-L-HASBOOK','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:a|b)
run(g,'4.2 stillValid: block entity in place, player in range and the lectern still has a book (block entity, in range, has book -> valid)','MN5-L-VALID','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:a&b&c)
def lcl(v,cnt,st):
    c=clamp(v,0,cnt-1); return (c,int(c!=st))
run(g,'4.3 data slot 0 set: the value clamps to 0 .. page count - 1 and counts as a change when it differs from the stored page (value, page count, stored -> stored page, changed)','MN5-L-CLAMP','iii',2,[(1,5,0),(9,5,0),(-3,5,2),(4,5,4),(0,1,0),(2,5,2)],lcl)
def lbt(i,pg,cnt,mb):
    if i>=100: n=clamp(i-100,0,cnt-1); return (1,n,0)
    if i==1: return (1,clamp(pg-1,0,cnt-1),0)
    if i==2: return (1,clamp(pg+1,0,cnt-1),0)
    if i==3: return (mb,pg,mb)
    return (0,pg,0)
rows=[(102,0,5,0),(109,0,5,0),(100,3,5,0),(1,3,5,0),(1,0,5,0),(2,0,5,0),(2,4,5,0),(3,2,5,1),(3,2,5,0),(0,2,5,1),(4,2,5,1),(99,2,5,1)]
run(g,'4.4 buttons: ids 100 and up jump to the page, 1 previous, 2 next (clamped, no permission check), 3 takes the book only with mayBuild, other ids do nothing (id, page, page count, mayBuild -> result, page, take the book)','MN5-L-BUTTON','iiii',3,rows,lbt)
run(g,'4.4 take book: the book goes into the inventory when it fits, else it is dropped (fits -> added, dropped)','MN5-L-TAKE','i',2,[(1,),(0,)],lambda f:(f,1-f))
run(g,'4.5 quick-move always returns the empty stack (index -> moved count)','MN5-L-QUICK','i',1,[(0,),(5,)],lambda i:0)
def lsg(hb,pg,cnt):
    if not hb: return 0
    f=f32(1.0) if cnt<=1 else f32(f32(pg)/f32(cnt-1))
    return fl(f32(14*f))+1
run(g,'4.6, 5.10 redstone signal: 0 without a book, else floor(14 x page / (pages - 1)) + 1, with f = 1 for a one-page book (has book, page, pages -> signal)','MN5-L-SIGNAL','iii',1,[(0,3,5),(1,0,5),(1,1,5),(1,4,5),(1,2,5),(1,0,1),(1,0,0),(1,3,8),(1,1,8),(1,5,8),(1,6,15),(1,13,15)],lsg)
def llay(w):
    b=(w-192)//2
    return (b,b+36,b+148,b+116,b+43,(w-200)//2)
run(g,'4.7, E10 layout: backgroundLeft = (width - 192) / 2; page text x + 36; indicator right edge x + 148; forward x + 116; back x + 43; the 200-wide Done at (width - 200) / 2 (window width -> left, text x, indicator x, forward x, back x, done x)','MN5-L-LAYOUT','i',6,[(854,),(192,),(400,),(255,)],llay)
run(g,'4.7 vertical layout: text lines at 32 + 9 i, indicator y 18, page buttons y 159, background top 2, menu controls top 196 (line -> y, indicator y, button y, top, controls top)','MN5-L-LAYOUTY','i',5,[(0,),(1,),(13,)],lambda i:(32+9*i,18,159,2,196))
run(g,'4.7 at most min(14, lines) lines of the split page are drawn (lines -> shown)','MN5-L-LINES','i',1,[(0,),(5,),(14,),(15,),(40,)],lambda n:min(14,n))
run(g,'4.7 page indicator: Page <page + 1> of <max(pages, 1)> (page, pages -> shown page, total)','MN5-L-INDICATOR','ii',2,[(0,0),(0,1),(1,5),(4,5),(0,9)],lambda p,n:(p+1,max(n,1)))
run(g,'4.7 button visibility: forward while page < pages - 1, back while page > 0 (page, pages -> forward, back)','MN5-L-VIS','ii',2,[(0,0),(0,1),(0,5),(2,5),(4,5)],lambda p,n:(int(p<n-1),int(p>0)))
run(g,'4.7 setBookAccess clamps the page to 0 .. pages (the upper bound is the count) (page, pages -> page)','MN5-L-SETBOOK','ii',1,[(3,5),(9,5),(5,5),(-2,5),(0,0),(4,0)],lambda p,n:clamp(p,0,n))
def lsp(p,cur,n):
    c=clamp(p,0,n-1); return (c,int(c!=cur))
run(g,'4.7 setPage clamps to 0 .. pages - 1 and reports a change only when different (page, current, pages -> page, changed)','MN5-L-SETPAGE','iii',2,[(3,3,5),(4,3,5),(9,3,5),(-1,0,5),(0,0,5)],lsp)
run(g,'4.7 keys: code 1073741899 presses the back button (1), 1073741902 the forward button (2), others nothing (code -> button)','MN5-L-KEY','i',1,[(1073741899,),(1073741902,),(1073741900,),(0,),(75,)],lambda c:1 if c==1073741899 else 2 if c==1073741902 else 0)
def ltc(b,ev,pg):
    if b!=1 or ev==0: return (0,0,0)
    if ev==1: return (1,1,pg-1)
    if ev==2: return (1,2,0)
    return (1,3,0)
run(g,'4.7 text clicks: the left button (1) with an event: change page (1-based) forces page - 1, run command closes the container on the server and runs, other events go to the default handler; any event is handled (button, event 0 none 1 change page 2 run command 3 other, page -> handled, action 0 none 1 force 2 run 3 default, target)','MN5-L-TEXTCLICK','iii',3,[(1,1,4),(1,2,0),(1,3,0),(1,0,0),(0,1,4),(2,2,0)],ltc)
run(g,'4.7, E11 forcePage: when the page differs from the menu page send button id 100 + page and report success (page, menu page -> sent, id)','MN5-L-FORCE','ii',2,[(9,0),(0,0),(4,3),(4,4)],lambda p,m:(int(p!=m),100+p if p!=m else 0))
def lct(mb,w):
    if mb: return (2,w//2-98-2,98,w//2+2,98)
    return (1,(w-200)//2,200,0,0)
run(g,'4.7, E10 controls: a player who may build gets Done (width 98) at width / 2 - 100 and Take Book at width / 2 + 2 at y 196, else a single 200-wide Done (mayBuild, window width -> buttons, done x, done width, take x, take width)','MN5-L-CONTROLS','ii',5,[(1,854),(0,854),(1,401),(0,401)],lct)
def lpp(l,w):
    if l: return (1 if w==1 else 2,0)
    return (0,1)
run(g,'4.7 page buttons: on the lectern screen the back button sends id 1 and the forward button id 2 and the page changes with the server update; on the plain book screen the page changes locally (lectern, button 1 back 2 forward -> id sent, local change)','MN5-L-PAGEPRESS','ii',2,[(1,1),(1,2),(0,1),(0,2)],lpp)
def lls(k,b):
    if k==1: return 1 if b else 2
    return 3
run(g,'4.7 listener: a slot change rebuilds the access from the book (1) or uses the empty access (2); a data change calls setPage (3) (kind 1 slot 2 data, is a book -> action)','MN5-L-LISTEN','ii',1,[(1,1),(1,0),(2,1),(2,0)],lls)
run(g,'4.7 the page turn sound plays only for a screen created with playTurnSound: the plain book screen, not the lectern (lectern -> sound)','MN5-L-TURNSOUND','i',1,[(0,),(1,)],lambda l:1-l)
W(g,4)
