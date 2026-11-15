import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-6-mount-inventories.md (sections 1 to 6).
# Entity numbers of the programs: 1 horse, 2 donkey, 3 mule, 4 llama, 5 trader llama, 6 skeleton horse, 7 zombie horse, 8 nautilus, 9 zombie nautilus,
# 10 pig, 11 strider, 12 camel, 13 camel husk, 14 happy ghast, 0 any other entity.
def G6(n,subj,tasks,desc):
    return GG('TEST-MENU-40-6-%d'%n,'40-6§%d'%n,subj,tasks,desc,None)
def W(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_6_%d.cob'%n)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
HORSES=(1,2,3,4,5,6,7); NAUT=(8,9)
def cls(e): return 1 if e in HORSES else 2 if e in NAUT else 0
# ===== 1
g=G6(1,'Overview','T1059','menu classes, no menu type and the open packet (core/src/menu-40-6.cob).')
run(g,'1: the menu class of an entity: horse family (1 horse, 2 donkey, 3 mule, 4 llama, 5 trader llama, 6 skeleton horse, 7 zombie horse) is HorseInventoryMenu 1, nautilus and zombie nautilus NautilusInventoryMenu 2, anything else none 0; both have no menu type id (-1) and open through packet 0x2A','MN6-CLASS','i',3,[(e,) for e in (1,2,3,4,5,6,7,8,9,10,14,0)],lambda e:(cls(e),-1,42))
W(g,1)
# ===== 2
g=G6(2,'The menu','T1061','constants, slot list, stillValid, armor slot rules, activity, icons, equip effects and quick-move (core/src/menu-40-6.cob).')
def sl(c): n=2+3*c; return (n,n+36,n,n+27)
run(g,'2.1, 2.2, 7.1: with c chest columns N = 2 + 3c; the menu has N + 36 slots, main inventory from N, hotbar from N + 27 (columns -> N, total, main start, hotbar start)','MN6-SLOTS','i',4,[(c,) for c in (0,3,5,1,4)],sl)
def slot(s,c):
    n=2+3*c
    if s==0: return (8,18,1)
    if s==1: return (8,36,2)
    if s<n:
        i=s-2; r=i//c; cc=i%c; return (80+cc*18,18+r*18,3)
    if s<n+27:
        j=s-n; return (8+18*(j%9),84+18*(j//9),4)
    if s<n+36: return (8+18*(s-n-27),142,5)
    return (0,0,0)
rows=[(0,0),(1,0),(2,3),(4,3),(5,3),(10,3),(11,3),(37,3),(38,3),(46,3),(47,3),(2,5),(16,5),(17,5),(52,5),(53,5),(2,0),(29,0),(37,0),(38,0)]
run(g,'2.2, 7.1: slot positions: saddle (8, 18), body (8, 36), chest slot index = col + row x c at (80 + 18 col, 18 + 18 row), main from (8, 84), hotbar at y 142 (slot, columns -> x, y, part 1 saddle 2 body 3 chest 4 main 5 hotbar 0 none)','MN6-SLOT','ii',3,rows,slot)
def vl(ch,cv,al,d): return int(not ch and cv and al and d<=4.0)
rows=[(0,1,1,3.0),(1,1,1,3.0),(0,0,1,3.0),(0,1,0,3.0),(0,1,1,5.0),(0,1,1,4.0),(0,1,1,4.0000001),(0,1,1,0.0)]
run(g,'2.1 stillValid: the entity still has the same container, the container is valid, the mount is alive and the player is within 4.0 (container replaced, container valid, alive, distance -> valid)','MN6-VALID','iiif',1,rows,vl)
run(g,'2.1 hasInventoryChanged: true when the entity container is not the menu container (same object -> changed)','MN6-CHANGED','i',1,[(1,),(0,)],lambda s:1-s)
def mp(he,se,cu,aa,ac): return int(he and se and cu and (aa or ac))
rows=[(1,1,1,1,0),(1,1,1,0,1),(1,1,1,0,0),(0,1,1,1,0),(1,0,1,1,0),(1,1,0,1,0),(1,1,1,1,1)]
run(g,'2.3 mayPlace: the stack has an equippable component for this slot, the mount can use the slot and the allowed set is absent or has the entity type (has component, slot equal, canUseSlot, allowed set absent, set contains -> ok)','MN6-MAYPLACE','iiiii',1,rows,mp)
run(g,'2.3 mayPickup: false when the slot is non-empty, the player is not in creative and the stack has prevent_armor_change (non-empty, creative, has prevent -> ok)','MN6-MAYPICKUP','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:0 if (a and not b and c) else 1)
def se(sv,sp,sm,ft,sl_,ne,sq,em):
    if not sv or sp or sm or ft: return (0,0)
    snd=int(not sl_ and ne and sq)
    ev=0
    if em: ev=1 if ne else 2
    return (snd,ev)
rows=[(1,0,0,0,0,1,1,1),(0,0,0,0,0,1,1,1),(1,1,0,0,0,1,1,1),(1,0,1,0,0,1,1,1),(1,0,0,1,0,1,1,1),(1,0,0,0,1,1,1,1),(1,0,0,0,0,0,0,1),(1,0,0,0,0,1,0,1),(1,0,0,0,0,1,1,0),(1,0,0,0,1,0,0,1),(1,0,0,0,0,0,0,0)]
run(g,'2.3 setByPlayer, onEquipItem: server only and not a spectator; nothing for the same item or the first tick; the sound needs a non-silent mount and an equippable of this slot, the game event (1 EQUIP, 2 UNEQUIP) is independent: UNEQUIP when the new stack has no equippable (server, spectator, same item, first tick, silent, new stack has equippable, its slot equal, emits event -> sound, event)','MN6-ONEQUIP','iiiiiiii',2,rows,se)
def esn(c,sd,uw): return 2 if (c==1 and sd) else (3 if uw else 4) if (c==2 and sd) else 1
run(g,'2.3 equip sounds: a horse saddle slot plays the horse saddle sound (2), a nautilus saddle slot the underwater (3) or the ordinary (4) saddle sound, other slots the item\'s own (1) (class, saddle slot, under water -> sound)','MN6-EQUIPSOUND','iii',1,[(1,1,0),(1,0,0),(2,1,1),(2,1,0),(2,0,1)],esn)
run(g,'2.2 the equipment container: writing a non-empty stack sets a guaranteed drop and persistence; its stillValid is riding or within 4.0 (non-empty, riding, distance -> drop and persist, valid)','MN6-EQUIPCONT','iif',2,[(1,0,2.0),(0,1,9.0),(0,0,9.0),(0,0,4.0),(1,0,4.5)],lambda n,r,d:(n,int(r or d<=4.0)))
def act(c,s,cu,ts,ta,ll):
    if c==1: return int(cu and ts) if s==0 else int(cu and (ta or ll))
    return cu
rows=[(1,0,1,1,0,0),(1,0,1,0,0,0),(1,0,0,1,0,0),(1,1,1,0,1,0),(1,1,1,0,0,1),(1,1,1,0,0,0),(1,1,0,0,1,0),(2,0,1,0,0,0),(2,1,1,0,0,0),(2,1,0,0,0,0)]
run(g,'2.4 slot activity: horse menu saddle needs canUseSlot and tag can_equip_saddle, body canUseSlot and (tag can_wear_horse_armor or a llama); nautilus menu just canUseSlot (class, slot 0 saddle 1 body, canUseSlot, saddle tag, armor tag, llama -> active)','MN6-ACTIVE','iiiiii',1,rows,act)
IC={(1,0,0):'container/slot/saddle',(1,1,1):'container/slot/llama_armor',(1,1,0):'container/slot/horse_armor',(2,0,0):'container/slot/saddle',(2,1,0):'container/slot/nautilus_armor_inventory'}
runt(g,'2.4 empty slot icons: saddle container/slot/saddle; body llama_armor for a llama, else horse_armor; nautilus nautilus_armor_inventory (class, slot, llama)','MN6-ICON','iii',[(1,0,0),(1,1,1),(1,1,0),(2,0,0),(2,1,0)],lambda c,s,l:(IC[(c,s,l)],"16x16"))
def cu(e,s,al,ba,ta):
    if e in (4,5): return 1
    if e in (1,2,3,6,7): return int(al and not ba and ta) if s==0 else 1
    if e in NAUT: return int(al and not ba and ta)
    return 0
rows=[(e,s,al,ba,ta) for e in (1,4,5,8,10) for s in (0,1) for (al,ba,ta) in ((1,0,1),(1,1,1),(1,0,0),(0,0,1))]+[(6,0,1,0,1),(7,1,0,1,0),(9,1,1,0,1)]
run(g,'2.4 canUseSlot: horses saddle alive, adult and tamed, body true; a llama or trader llama true for both; a nautilus alive, adult and tamed for both; other entities 0 (entity, slot, alive, baby, tamed -> usable)','MN6-CANUSE','iiiii',1,rows,cu)
EQ={1:(0,1,1),2:(1,1,1),3:(1,1,1),4:(1,1,1)}
run(g,'2.5 equippable data: saddle slot SADDLE, llama carpet slot BODY, horse armor BODY, nautilus armor BODY; all can be sheared and stack to 1 (item kind 1 saddle 2 llama carpet 3 horse armor 4 nautilus armor -> slot 0 saddle 1 body, can be sheared, stack size)','MN6-EQUIPPABLE','i',3,[(k,) for k in (1,2,3,4)],lambda k:(0 if k==1 else 1,1,1))
def tagm(t,e):
    if t==1: return int(e in (1,2,3,6,7,8,9,10,11,12,13))
    if t==2: return int(e in (1,7))
    if t==3: return int(e in (8,9))
    return int(e==14)
def acc(it,e):
    if it==1: return tagm(1,e)
    if it==2: return int(e in (4,5))
    if it==3: return tagm(2,e)
    return tagm(3,e)
rows=[(it,e) for it in (1,2,3,4) for e in (1,2,4,5,6,7,8,9,10,14)]
run(g,'2.5 consequences: which item kinds a mount accepts by the allowed-entities set: saddle by the can_equip_saddle tag, a carpet only llama and trader llama, horse armor horse and zombie horse, nautilus armor nautilus and zombie nautilus (item kind, entity -> accepted)','MN6-ACCEPTS','ii',1,rows,acc)
def qk(ix,c,bo,so,mv,cm):
    n=2+3*c; tot=n+36
    if ix<n: return (1,n,tot,1,int(mv))
    if bo: return (2,1,2,0,int(mv))
    if so: return (3,0,1,0,int(mv))
    if c>0 and cm: return (4,2,n,0,1)
    if n+27<=ix<n+36: return (5,n,n+27,0,0)
    if n<=ix<n+27: return (6,n+27,n+36,0,0)
    return (7,n+27,n+27,0,0)
rows=[(2,3,0,0,1,0),(10,0,0,0,0,0),(17,5,0,0,1,0),(4,3,0,0,1,0),(4,3,0,0,0,0),(10,0,1,0,1,0),(10,0,1,0,0,0),(10,0,0,1,1,0),(10,0,0,1,0,0),(12,0,0,0,1,1),(12,3,0,0,1,1),(12,3,0,0,1,0),(29,0,0,0,1,0),(38,0,0,0,1,0),(42,3,1,0,1,0),(53,3,0,0,1,0),(60,3,0,0,1,0),(5,1,0,0,1,1)]
run(g,'2.6, 7.2 quick-move: from the mount part to the player inventory in reverse; from the player part the body slot, else the saddle slot, else the chest when it exists, then the hotbar and main shuffle (returns empty) (index, columns, body accepts and empty, saddle accepts and empty, move worked, chest move worked -> rule 1 inventory 2 body 3 saddle 4 chest 5 hotbar to main 6 main to hotbar 7 none, start, end, reverse, original copy returned)','MN6-QUICK','iiiiii',5,rows,qk)
run(g,'2.6 finish step: a source stack that is now empty is set empty as a player change, else setChanged (source empty -> action 1 set empty 2 changed)','MN6-FINISH','i',1,[(1,),(0,)],lambda e:1 if e else 2)
W(g,2)
# ===== 3
g=G6(3,'Opening a mount inventory','T1063','trigger, interact order, server steps, packet bytes, client handling and close (core/src/menu-40-6.cob).')
run(g,'3.1, 7.3 trigger: the mount has no passengers or the player is a passenger, and the mount is tamed (no passengers, player is a passenger, tamed -> opens)','MN6-OPENOK','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:int((a or b) and c))
def ia(k,ba,ve,ta,sec):
    if ba or (k==1 and ve): return 0
    if ta and sec: return 1
    return 2
rows=[(1,1,0,1,1),(1,0,1,1,1),(1,0,0,1,1),(1,0,0,1,0),(1,0,0,0,1),(2,1,0,1,1),(2,0,1,1,1),(2,0,0,1,1),(2,0,0,0,0)]
run(g,'3.1 mobInteract order: a baby (horse also a vehicle) goes to the superclass (0); tamed with secondary use opens the screen and succeeds (1); only then held-item handling (2) (1 horse 2 nautilus, baby, is a vehicle, tamed, secondary use -> result)','MN6-INTERACT','iiiii',1,rows,ia)
run(g,'3.1 server steps: close a menu that is not the inventory menu; the container counter advances in 1 to 100 (current menu is the inventory, counter -> close first, new counter)','MN6-OPENSTEPS','ii',2,[(1,0),(0,5),(0,99),(0,100),(1,100),(0,1)],lambda i,c:(1-i,c%100+1))
def vi(v):
    o=b''
    while True:
        b=v&0x7f; v>>=7
        if v: o+=bytes([b|0x80])
        else:
            o+=bytes([b]); break
    return o
def pk(i,c,e): return (vi(i)+vi(c)+struct.pack('>i',e)).hex()
runt(g,'3.2, 8: the packet is VarInt container id, VarInt columns, 4-byte big-endian entity id (hex bytes, then the byte count; 1, 3, 0x102 gives 01 03 00 00 01 02)','MN6-PACKET','iii',[(1,3,0x102),(1,0,5),(127,5,1),(128,12,-1),(300,200,2147483647),(16384,4,70000)],lambda i,c,e:(pk(i,c,e),str(len(pk(i,c,e))//2)))
def cl(f,k):
    if not f: return (0,0)
    c=cls(k)
    return (c,0) if c==0 else (c,1)
run(g,'3.3 client handling: an unknown entity does nothing; a horse family entity opens the horse menu and screen (1), a nautilus the nautilus ones (2); the chest container has columns x 3 slots (found, entity, columns -> menu class, installed, chest container size)','MN6-CLIENT','iii',3,[(0,1,3),(1,10,3),(1,0,0),(1,1,0),(1,4,4),(1,8,0),(1,9,0),(1,2,5)],lambda f,k,c:(cl(f,k)[0],cl(f,k)[1],c*3 if cl(f,k)[1] else 0))
run(g,'3.4 re-created container: stacks are copied index by index for min(old, new) slots and the rest dropped (old size, new size -> copied, lost)','MN6-RESIZE','ii',2,[(15,15),(15,0),(0,15),(9,15),(15,9),(0,0)],lambda o,n:(min(o,n),max(0,o-n)))
W(g,3)
# ===== 4
g=G6(4,'Column counts','T1065','columns of each entity, llama strength (core/src/menu-40-6.cob).')
def cols(e,ch,st):
    if e in (1,6,7): return (0,0)
    if e in (2,3): return (5,15) if ch else (0,0)
    if e in (4,5): return (st,3*st) if ch else (0,0)
    return (0,0)
rows=[(1,0,0),(1,1,0),(6,1,0),(7,0,0),(2,1,0),(2,0,0),(3,1,0),(4,1,1),(4,1,3),(5,1,5),(4,0,4),(8,1,0),(9,0,0),(0,1,0)]
run(g,'4: getInventoryColumns: horse, skeleton horse, zombie horse 0; donkey and mule 5 with the chest flag; llama and trader llama their strength with the chest flag; nautilus 0 (entity, chest flag, strength -> columns, chest slots)','MN6-COLUMNS','iii',2,rows,cols)
run(g,'4: setStrength clamps into 1 to 5','MN6-STRCLAMP','i',1,[(-1,),(0,),(1,),(3,),(5,),(6,),(9,)],lambda v:max(1,min(5,v)))
def ls(f,r):
    low=f32(f)<f32(0.04)
    b=5 if low else 3
    return (b,1+r)
rows=[(0.0,0),(0.039,4),(0.04,2),(0.03999999538064003,4),(0.03999999910593033,2),(0.04000000283122063,2),(0.5,2),(0.99,0),(0.0399,3),(0.5,1)]
run(g,'4: llama strength at spawn: one nextFloat draw below the single precision 0.04 gives bound 5, else 3; strength = 1 + nextInt(bound) (float draw, nextInt result -> bound, strength); 0.03999999910593033 is 0.04F itself (not below) and 0.03999999538064003 the float before it','MN6-LLAMA','fi',2,rows,ls)
W(g,4)
# ===== 5
g=G6(5,'Per-entity-type variants','T1067','tag semantics and slot visibility per entity (core/src/menu-40-6.cob).')
rows=[(t,e) for t in (1,2,3,4) for e in (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14)]
run(g,'5.1 tag members (1 can_equip_saddle: horse, skeleton horse, zombie horse, donkey, mule, pig, strider, camel, camel husk, nautilus, zombie nautilus; 2 can_wear_horse_armor: horse, zombie horse; 3 can_wear_nautilus_armor: nautilus, zombie nautilus; 4 can_equip_harness: happy ghast) (tag, entity -> member)','MN6-TAG','ii',1,rows,tagm)
def vis(e,ta,ba,ch,st):
    al=1
    def can(s): return cu(e,s,al,ba,ta)
    c=cls(e)
    sv=0; bd=0
    if c==1:
        sv=int(can(0) and tagm(1,e)); bd=int(can(1) and (tagm(2,e) or e in (4,5)))
    elif c==2:
        sv=can(0); bd=can(1)
    co=cols(e,ch,st)[0]
    ic=0
    if bd: ic=1 if e in (4,5) else 2 if c==1 else 3
    return (sv,bd,co,ic)
rows=[(1,1,0,0,0),(6,1,0,0,0),(7,1,0,0,0),(2,1,0,1,0),(3,1,0,0,0),(4,1,0,1,3),(5,1,0,1,5),(8,1,0,0,0),(9,1,0,0,0),(1,1,1,0,0),(1,0,0,0,0),(6,1,1,0,0),(8,1,1,0,0),(8,0,0,0,0),(4,0,0,1,2),(2,1,1,1,0),(1,0,1,0,0)]
run(g,'5.2 slot visibility of a mount (entity, tamed, baby, chest flag, strength -> saddle shown, body shown, chest columns, body icon 0 none 1 llama armor 2 horse armor 3 nautilus armor): a llama never shows a saddle, a donkey never a body slot, a nautilus never a chest, a skeleton horse only the saddle; a baby or untamed nautilus shows neither','MN6-VISIBLE','iiiii',4,rows,vis)
W(g,5)
# ===== 6
g=G6(6,'The screens','T1069','frame, drawing plan, pixel table, preview rectangle and angles (core/src/menu-40-6.cob).')
run(g,'6.1: leftPos = (width - 176) / 2, topPos = (height - 166) / 2; title at (8, 6), inventory label at (8, 72) (window width, height -> left, top, title x, y, label x, y)','MN6-FRAME','ii',6,[(854,480),(176,166),(400,301),(1000,700)],lambda w,h:((w-176)//2,(h-166)//2,8,6,8,72))
def dp(c,col,sa,ba):
    cd=int(col>0 and c==1)
    return (cd,col*18 if cd else 0,sa,ba)
rows=[(1,3,1,1),(1,0,1,0),(2,0,1,1),(1,5,0,1),(2,3,0,0)]
run(g,'6.2 drawing plan: the chest area only with columns > 0 and the horse screen (width columns x 18, sprite at (79, 17)); the slot frames at (7, 17) and (7, 35) when the slots are active (screen class 1 horse 2 nautilus, columns, saddle active, body active -> chest drawn, chest width, saddle frame, body frame)','MN6-DRAWPLAN','iiii',4,rows,dp)
runt(g,'6.2 background textures and sprites (1 horse background, 2 nautilus background, 3 chest slots sprite, 4 slot frame sprite)','MN6-TEXTURE','i',[(1,),(2,),(3,),(4,)],lambda k:{1:("textures/gui/container/horse.png","176x166 of 256x256"),2:("textures/gui/container/nautilus.png","176x166 of 256x256"),3:("container/horse/chest_slots","90x54"),4:("container/slot","18x18")}[k])
PX={1:(0,0,176,166),2:(7,17,18,18),3:(7,35,18,18),4:(8,18,16,16),5:(8,36,16,16),6:(79,17,18*3,54),7:(80,18,16,16),8:(26,18,52,52),9:(8,84,162,54),10:(8,142,162,18)}
run(g,'6.3 pixel table (1 background, 2 saddle frame, 3 body frame, 4 saddle item, 5 body item, 6 chest area for 3 columns, 7 chest slot (0, 0) item, 8 entity preview box, 9 main inventory, 10 hotbar) (element -> x, y, w, h)','MN6-PIXELS','i',4,[(k,) for k in range(1,11)],lambda k:PX[k])
run(g,'6.2 an active slot with an empty item draws its icon 16 x 16 at the item position; inactive slots are skipped (active, item empty -> icon drawn, slot drawn)','MN6-ICONDRAW','ii',2,[(1,1),(1,0),(0,1),(0,0)],lambda a,e:(int(a and e),a))
run(g,'6.4 preview rectangle: (left + 26, top + 18) to (left + 78, top + 70), centre (left + 52, top + 44), scale 17, y offset 0.25 (x 1e6) (left, top -> x0, y0, x1, y1, cx, cy, scale, offset)','MN6-PREVIEW','ii',8,[(339,157),(0,0),(10,20)],lambda l,t:(l+26,t+18,l+78,t+70,l+52,t+44,17,250000))
def ang2(cx,cy,mx,my,ff):
    ax=math.atan((cx-mx)/40.0); ay=math.atan((cy-my)/40.0)
    # ax x 20 and ay x 20 are DEGREES taken from the radian-valued arctangent (the doc multiplies the arctangent by 20 and calls the product degrees)
    return (sc(ax,1e6),sc(ay,1e6),sc(180+ax*20,1e6),sc(ax*20,1e6),0 if ff else sc(-ay*20,1e6),sc(ay*20*0.017453292,1e6))
run(g,'6.4, worked example: ax = atan((cx - mouseX) / 40), ay = atan((cy - mouseY) / 40) in radians; body rotation 180 + ax x 20, head yaw ax x 20, head pitch -ay x 20 (0 when fall-flying) in degrees as the document multiplies; the X rotation ay x 20 degrees in radians with 0.017453292 per degree; all x 1e6 (centre, mouse, fall-flying -> ax, ay, body, yaw, pitch, qx)','MN6-ANGLES','iiffi',6,[(391,201,431.0,201.0,0),(391,201,391.0,201.0,0),(391,201,300.0,150.0,0),(391,201,500.0,400.0,1),(391,201,0.0,0.0,0)],ang2)
def box(w,h,sc_):
    return (sc(w/sc_,1e6),sc(h/sc_,1e6),sc(h/sc_/2+0.25,1e6))
run(g,'6.4 step 4 and 5: the bounding box width and height are divided by the state scale (then the scale is 1), the translation is (0, height / 2 + 0.25, 0); all x 1e6 (width, height, scale -> width, height, translation y)','MN6-PREVIEWBOX','fff',3,[(1.4,1.6,1.0),(0.7,0.8,0.5),(2.0,2.0,2.0),(1.3965,1.6,1.0)],box)
W(g,6)
