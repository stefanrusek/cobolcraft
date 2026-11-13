import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40c import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-7-creative-inventory.md (sections 1 to 10).
# Tab numbers 1..14 are the registry order of 2.2. Tab types: 1 CATEGORY, 2 INVENTORY, 3 HOTBAR, 4 SEARCH. Rows: 0 TOP, 1 BOTTOM.
# ContainerInput numbers of 40-1 3.4: 0 PICKUP, 1 QUICK_MOVE, 2 SWAP, 3 CLONE, 4 THROW, 5 QUICK_CRAFT, 6 PICKUP_ALL.
EXTRA=' 01 WS-NM                PIC X(32).\n 01 WS-T3                 PIC X(96).\n'
def G7(n,subj,tasks,desc):
    return Gen10('TEST-MENU-40-7-%d'%n,'40-7§%d'%n,subj,'Test of 40-7§%d section, %s (%s): %s'%(n,subj,tasks,desc),EXTRA)
def W(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_7_%d.cob'%n)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def clamp(v,lo,hi): return lo if v<lo else min(v,hi)
def tcase(g,text,name,rows,model,nout=1):
    # rows of up to three texts into WS-T1..T3; the program returns nout numbers
    calls=[]; exp=[]
    for r in rows:
        mv="".join('MOVE "%s" TO WS-T%d\n'%(t,i+1) for i,t in enumerate(r))
        args=" ".join("WS-T%d"%(i+1) for i in range(len(r)))
        calls.append(('0',mv+'CALL "%s" USING %s %s'%(name," ".join(["WS-T%d"%(i+1) for i in range(len(r))])," ".join("WS-R(%d)"%(k+1) for k in range(nout))),nout))
        m=model(*r); exp.append("/".join(str(x) for x in (m if isinstance(m,tuple) else (m,))))
    g.case(text,calls," ".join(exp)+" ")
def ttext(g,text,name,rows,model):
    # one to three input texts, WS-T1 and WS-T2 receive text outputs of the model (name, program USING in-texts out-texts)
    calls=[]; exp=[]
    for (ins,nin) in rows:
        mv="".join('MOVE "%s" TO WS-T%d\n'%(t,i+1) for i,t in enumerate(ins))
        calls.append(('0',mv+'MOVE SPACES TO WS-T2\nCALL "%s" USING WS-T1 WS-T2'%name,'TEXT'))
        exp.append("%s|%s"%model(*ins))
    g.case(text,calls," ".join(exp))
TABS=[ # number: key, title key, English, icon, row, col, type, right, background, scroll, show title
 ('building_blocks','itemGroup.buildingBlocks','Building Blocks','bricks',0,0,1,0,1,1,1),
 ('colored_blocks','itemGroup.coloredBlocks','Colored Blocks','cyan_wool',0,1,1,0,1,1,1),
 ('natural_blocks','itemGroup.natural','Natural Blocks','grass_block',0,2,1,0,1,1,1),
 ('functional_blocks','itemGroup.functional','Functional Blocks','oak_sign',0,3,1,0,1,1,1),
 ('redstone_blocks','itemGroup.redstone','Redstone Blocks','redstone',0,4,1,0,1,1,1),
 ('hotbar','itemGroup.hotbar','Saved Hotbars','bookshelf',0,5,3,1,1,1,1),
 ('search','itemGroup.search','Search Items','compass',0,6,4,1,3,1,1),
 ('tools_and_utilities','itemGroup.tools','Tools & Utilities','diamond_pickaxe',1,0,1,0,1,1,1),
 ('combat','itemGroup.combat','Combat','netherite_sword',1,1,1,0,1,1,1),
 ('food_and_drinks','itemGroup.foodAndDrink','Food & Drinks','golden_apple',1,2,1,0,1,1,1),
 ('ingredients','itemGroup.ingredients','Ingredients','iron_ingot',1,3,1,0,1,1,1),
 ('spawn_eggs','itemGroup.spawnEggs','Spawn Eggs','creeper_spawn_egg',1,4,1,0,1,1,1),
 ('op_blocks','itemGroup.op','Operator Utilities','command_block',1,5,1,1,1,1,1),
 ('inventory','itemGroup.inventory','Survival Inventory','chest',1,6,2,1,2,0,0)]
def tab(n): t=TABS[n-1]; return t[4:]
def tabx(right,col,w=195): return w-27*(7-col)+1 if right else 27*col
def taby(row): return 136 if row else -32
def drawy(row): return 132 if row else -28
# ===== 1
g=G7(1,'Identity','T1071','image size, availability, operator permission and tick behaviour (core/src/menu-40-7.cob).')
run(g,'1: image 195 x 136 on a 256 sheet, no menu type (-1), container id 0, the default selected tab is building_blocks (1)','MN7-IDENT','',6,[()],lambda:(195,136,256,-1,0,1))
run(g,'1 available when: the player has infinite materials, else the screen replaces itself with the survival InventoryScreen (infinite -> 1 creative screen, 2 survival screen)','MN7-AVAILABLE','i',1,[(0,),(1,)],lambda i:1 if i else 2)
run(g,'1 operator permission: canUseGameMasterBlocks needs instabuild and game master permission; hasPermissions also needs the operatorItemsTab option (instabuild, game master, option -> can use, has permission)','MN7-PERMS','iii',2,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(a&b,a&b&c))
run(g,'1 tick: with a local player the tabs are refreshed, and a player without infinite materials replaces the screen (has player, infinite -> refresh, replace)','MN7-TICK','ii',2,[(0,1),(1,1),(1,0),(0,0)],lambda p,i:(p,int(p and not i)))
W(g,1)
# ===== 2
g=G7(2,'Tab model','T1073','the 14 tabs, derived rules, builder check and displayed counts (core/src/menu-40-7.cob).')
run(g,'2.2: row, column, type, right aligned, background (1 items 2 inventory 3 search), scrollbar, title shown of each tab 1 to 14','MN7-TAB','i',7,[(n,) for n in range(1,15)],tab)
runt(g,'2.2: resource key and title key of each tab','MN7-TABNAME','i',[(n,) for n in range(1,15)],lambda n:(TABS[n-1][0],TABS[n-1][1]))
runt(g,'2.2: en_us title and icon item of each tab','MN7-TABTITLE','i',[(n,) for n in range(1,15)],lambda n:(TABS[n-1][2],TABS[n-1][3]))
BG={1:'minecraft:textures/gui/container/creative_inventory/tab_items.png',2:'minecraft:textures/gui/container/creative_inventory/tab_inventory.png',3:'minecraft:textures/gui/container/creative_inventory/tab_item_search.png'}
runt(g,'2.1: background texture locations (1 tab_items, 2 tab_inventory, 3 tab_item_search), 256 x 256','MN7-TABBG','i',[(k,) for k in (1,2,3)],lambda k:(BG[k],"256x256"))
run(g,'2.1: shouldDisplay: true unless the type is CATEGORY and the tab has no items (type, has items -> display)','MN7-DISPLAY','ii',1,[(t,h) for t in (1,2,3,4) for h in (0,1)],lambda t,h:0 if (t==1 and not h) else 1)
run(g,'2.1: the builder refuses a HOTBAR or INVENTORY tab with a display items generator (type, has generator -> allowed)','MN7-TABOK','ii',1,[(t,h) for t in (1,2,3,4) for h in (0,1)],lambda t,h:0 if (t in (2,3) and h) else 1)
run(g,'2.2: no two registered tabs share a row and column (clashes)','MN7-TABCHECK','',1,[()],lambda:0)
run(g,'2.2, 11.9, 12: tabs() of 14 with the operator tab, else 13; 7 in the top row, 7 or 6 in the bottom row (operator list not empty -> total, top row, bottom row)','MN7-TABCOUNTS','i',3,[(1,),(0,)],lambda o:(14,7,7) if o else (13,7,6))
W(g,2)
# ===== 3
g=G7(3,'Tab layout on screen','T1075','tabX, tab geometry, sprites, hit test, hover, cursor, selection and outside rule (core/src/menu-40-7.cob).')
run(g,'3.1: tabX = 27 x column, or imageWidth - 27 x (7 - column) + 1 for a right-aligned tab (right aligned, column, image width -> tabX)','MN7-TABX','iii',1,[(0,0,195),(0,6,195),(1,5,195),(1,6,195),(0,3,195),(1,5,200)],lambda r,c,w:tabx(r,c,w))
def geo(n,l,t):
    row,col,ty,right=tab(n)[0],tab(n)[1],tab(n)[2],tab(n)[3]
    x=tabx(right,col); dy=drawy(row)
    return (x,taby(row),l+x,t+dy,l+x+5,t+dy+(7 if row else 9),min(col,7)+1)
run(g,'3.1, 11.1: tab geometry for window 854 x 480 (leftPos 329, topPos 172): hit y -32 or 136, drawn at (leftPos + tabX, topPos - 28 or + 132), icon cell +5 and +9 (top) or +7 (bottom), sprite index (tab -> tabX, hit y, drawn x, drawn y, icon x, icon y, sprite)','MN7-TABGEO','iii',7,[(n,329,172) for n in range(1,15)],geo)
SP=lambda row,sel,col:"container/creative_inventory/tab_%s_%s_%d"%("bottom" if row else "top","selected" if sel else "unselected",min(col,7)+1)
runt(g,'3.1: tab sprite names: tab_top or tab_bottom, selected or unselected, index column + 1 (row, selected, column)','MN7-SPRITE','iii',[(r,s,c) for r in (0,1) for s in (0,1) for c in (0,3,6)],lambda r,s,c:(SP(r,s,c),"26x32"))
def hit(x,y,tx,ty): return int(tx<=x<=tx+26 and ty<=y<=ty+32)
rows=[(0,-32,0,-32),(26,0,0,-32),(27,0,0,-32),(0,1,0,-32),(-1,-32,0,-32),(169,136,169,136),(195,168,169,136),(196,168,169,136),(195,169,169,136),(100,50,0,-32)]
run(g,'3.2 checkTabClicked: tabX <= x <= tabX + 26 and tabY <= y <= tabY + 32, inclusive (x, y, tabX, tabY -> hit)','MN7-HIT','iiii',1,rows,hit)
def hov(x,y,tx,ty): return int(tx+2<=x<tx+25 and ty+2<=y<ty+33)
rows=[(2,-30,0,-32),(24,-1,0,-32),(25,-1,0,-32),(1,-30,0,-32),(10,-31,0,-32),(10,0,0,-32),(10,1,0,-32),(170,140,169,136)]
run(g,'3.2 hover: the box (tabX + 3, tabY + 3) of 21 x 27 widened by one pixel on each side (x, y, tabX, tabY -> hover)','MN7-HOVER','iiii',1,rows,hov)
def cur(sel,px,py,dx,dy): return int(not sel and dx<px<dx+26 and dy<py<dy+32)
rows=[(0,10,10,0,0),(1,10,10,0,0),(0,0,10,0,0),(0,26,10,0,0),(0,10,0,0,0),(0,10,32,0,0),(0,25,31,0,0),(0,1,1,0,0)]
run(g,'3.2 cursor: the pointing hand over an unselected tab\'s drawn box with strict low edges (selected, pointer x, y, drawn x, y -> hand)','MN7-CURSOR','iiiii',1,rows,cur)
def pick(x,y,op):
    for n in range(1,15):
        row,col,ty,right=tab(n)[:4]
        if n==13 and not op: continue
        if hit(x,y,tabx(right,col),taby(row)): return n
    return 0
rows=[(5,-10,1),(30,-10,1),(150,-10,1),(180,-10,1),(150,140,1),(150,140,0),(100,140,0),(100,50,1),(0,-32,1),(27,140,1),(190,168,1),(100,-40,1),(142,140,0),(168,150,0),(169,150,0)]
run(g,'3.3 release: the first displayed tab in registry order that the point hits is selected; a miss selects none; the operator tab exists only with permission (x, y relative, operator tab available -> tab number or 0)','MN7-TABPICK','iii',1,rows,pick)
def outside(px,py,l,t,sel):
    ob=px<l or py<t or px>=l+195 or py>=t+136
    row,col,ty,right=tab(sel)[:4]
    return int(ob and not hit(px-l,py-t,tabx(right,col),taby(row)))
rows=[(0,0,329,172,1),(329,172,329,172,1),(329,150,329,172,1),(329+194,172+135,329,172,1),(329+195,200,329,172,1),(329+10,150,329,172,1),(329+10,172-33,329,172,1),(329+10,172-33,329,172,2),(329+30,150,329,172,2),(329+170,172+140,329,172,14),(329+170,172+140,329,172,1),(329+10,172+136,329,172,1)]
run(g,'3.3 hasClickedOutside: outside the image rectangle and not on the selected tab\'s box (pointer x, y, leftPos, topPos, selected tab -> outside)','MN7-OUTSIDE','iiiii',1,rows,outside)
W(g,3)
# ===== 4
g=G7(4,'Content lists','T1077','display parameters, rebuild passes, output rules, generators, search list order and refresh (core/src/menu-40-7.cob).')
run(g,'4.1 needsUpdate: true when the feature set differs, the permission flag differs or the provider is a different object (features equal, permission equal, provider same -> needs update)','MN7-NEEDS','iii',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:int(not(a and b and c)))
run(g,'4.1 tryRebuildTabContents: nothing is done when parameters are cached and still valid (cached, needs update -> rebuilt)','MN7-REBUILD','ii',1,[(0,0),(0,1),(1,0),(1,1)],lambda c,n:int(not(c and not n)))
run(g,'4.2 two passes: CATEGORY tabs are built first, the other types after (type -> pass)','MN7-PASS','i',1,[(1,),(2,),(3,),(4,)],lambda t:1 if t==1 else 2)
def acc(c,ph,v,en):
    if c!=1: return (1,0,0)
    if ph and v!=2: return (2,0,0)
    if not en: return (0,0,0)
    return (0,int(v in (0,1)),int(v in (0,2)))
rows=[(1,0,0,1),(1,0,1,1),(1,0,2,1),(2,0,0,1),(0,0,0,1),(1,1,0,1),(1,1,1,1),(1,1,2,1),(1,0,0,0),(1,1,2,0),(1,1,0,0),(3,1,1,0)]
run(g,'4.2 output rules in order: count must be 1 (error 1), a duplicate in the parent list is an error unless search-only (error 2), a disabled item is skipped, then the visibility chooses the lists (count, parent list has it, visibility 0 both 1 parent only 2 search only, enabled -> error, to parent, to search)','MN7-ACCEPT','iiii',3,rows,acc)
GT=[(10,0,0),(9,0,0),(10,0,0),(10,0,0),(8,9,0),(8,0,0),(11,0,1),(11,0,2),(2,4,0),(1,4,0),(4,0,0),(13,0,0)]
run(g,'4.4 special generators: potions (food and drinks), tipped arrows (combat), suspicious stews and ominous bottles (food), fireworks (tools and combat), goat horns (tools), enchanted books max level (ingredients, parent only) and all levels (search only), coloured families (colored and functional), copper (building and functional), placeable paintings (functional), non-placeable (op) (generator 1 to 12 -> tab, second tab, visibility)','MN7-GENTABLE','i',3,[(i,) for i in range(1,13)],lambda i:GT[i-1])
def gl(k,i):
    if k==1: return (5,i-1)
    if k==2: return (3,i)
    return (16,16-i)
run(g,'4.4 generated lists: 5 ominous bottles with amplifiers 0 to 4, 3 firework durations 1 to 3, 16 light levels 15 down to 0 (kind 1 ominous 2 firework 3 light, position from 1 -> count, value)','MN7-GENLIST','ii',2,[(1,1),(1,5),(2,1),(2,3),(3,1),(3,16),(3,9)],gl)
OPL=['command_block','chain_command_block','repeating_command_block','command_block_minecart','jigsaw','structure_block','structure_void','barrier','debug_stick','test_instance_block']
runt(g,'4.4 operator utilities plain items in order (position 1 to 10; then four test_block modes start, log, fail, accept, then 16 light stacks, then the non-placeable paintings)','MN7-OPITEM','i',[(i,) for i in range(1,11)],lambda i:(OPL[i-1],"-"))
runt(g,'4.4 test block modes in declaration order','MN7-TESTMODE','i',[(i,) for i in range(1,5)],lambda i:(['start','log','fail','accept'][i-1],"-"))
def opc(p,pa): return (10 if p else 0,4 if p else 0,16 if p else 0,pa if p else 0,(30+pa) if p else 0)
run(g,'4.4 the op_blocks generator produces nothing without permission, else 10 plain items, 4 test blocks, 16 light blocks and the non-placeable paintings (permission, paintings -> plain, test blocks, light, paintings, total)','MN7-OPCOUNT','ii',5,[(0,3),(1,3),(1,0),(0,0)],opc)
COL=['white','light_gray','gray','black','brown','red','orange','yellow','lime','green','cyan','light_blue','blue','purple','magenta','pink']
runt(g,'4.4 coloured families: the 16 colours in the fixed order (position 1 to 16)','MN7-COLOR','i',[(i,) for i in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)],lambda i:(COL[i-1],"-"))
def pc(a1,w1,a2,w2):
    k1=(a1,w1); k2=(a2,w2)
    return -1 if k1<k2 else 1 if k1>k2 else 0
run(g,'4.4 painting order: by area ascending, then width ascending; equal keys keep the registry order (area, width, area, width -> compare)','MN7-PAINTCMP','iiii',1,[(1,1,2,1),(4,2,4,4),(4,4,4,2),(9,3,9,3),(16,4,8,2),(2,2,2,2)],pc)
SE=['spawner','trial_spawner','creaking_heart']+['chicken_spawn_egg','cow_spawn_egg','pig_spawn_egg','sheep_spawn_egg','camel_spawn_egg','donkey_spawn_egg','horse_spawn_egg','mule_spawn_egg','cat_spawn_egg','parrot_spawn_egg','wolf_spawn_egg','armadillo_spawn_egg','bat_spawn_egg','bee_spawn_egg','fox_spawn_egg','goat_spawn_egg','llama_spawn_egg','ocelot_spawn_egg','panda_spawn_egg','polar_bear_spawn_egg','rabbit_spawn_egg','axolotl_spawn_egg','cod_spawn_egg','dolphin_spawn_egg','frog_spawn_egg','glow_squid_spawn_egg','nautilus_spawn_egg','pufferfish_spawn_egg','salmon_spawn_egg','squid_spawn_egg','tadpole_spawn_egg','tropical_fish_spawn_egg','turtle_spawn_egg','allay_spawn_egg','mooshroom_spawn_egg','sniffer_spawn_egg','sulfur_cube_spawn_egg']
runt(g,'4.4 the start of the spawn_eggs list as far as the document names it: spawner, trial_spawner, creaking_heart, then the eggs from chicken to sulfur cube (position 1 to 40; the rest is not tabulated)','MN7-SPAWNITEM','i',[(i,) for i in (1,2,3,4,5,6,10,15,20,25,30,35,39,40)],lambda i:(SE[i-1],"-"))
SO=[1,2,3,4,5,8,9,10,11,12,13]
run(g,'4.5 the search tab list is the union of the other tabs\' search lists in registry order: building, colored, natural, functional, redstone, tools, combat, food, ingredients, spawn eggs, op (position 1 to 11 -> tab)','MN7-SEARCHORDER','i',1,[(i,) for i in range(1,12)],lambda i:SO[i-1])
def un(*a):
    seen=[]
    for v in a:
        if v and v not in seen: seen.append(v)
    return (len(seen),)+tuple(seen)+(0,)*(8-len(seen))
rows=[(1,2,3,0,4,5,0,0),(1,2,3,4,1,2,5,6),(0,0,0,0,0,0,0,0),(7,7,7,7,7,7,7,7),(3,0,0,0,3,0,0,0),(1,2,0,0,2,1,3,0)]
run(g,'4.5 the union keeps the first occurrence of an equal stack in its position (two lists of up to four stack ids, 0 is no stack -> count, the merged ids)','MN7-UNION','iiiiiiii',9,rows,un)
def rt(rb,sel,ty,em):
    if not rb or not sel: return 0
    if ty==1 and em: return 1
    return 2
run(g,'4.5 tryRefreshInvalidatedTabs: after a rebuild the selected tab falls back to the default when it is an empty CATEGORY, else its contents are refreshed (rebuilt, selected, type, list empty -> 0 nothing 1 select default 2 refresh)','MN7-REFRESHTABS','iiii',1,[(0,1,1,1),(1,0,1,1),(1,1,1,1),(1,1,1,0),(1,1,4,1),(1,1,3,0)],rt)
W(g,4)
# ===== 5
g=G7(5,'The item picker menu','T1079','slots, pickup rule, scrolling arithmetic, drag rules and quick-move (core/src/menu-40-7.cob).')
def ps(s):
    if s<45: return (9+18*(s%9),18+18*(s//9),1,s)
    return (9+18*(s-45),112,2,s-45)
run(g,'5.1: grid slots 0 to 44 at (9 + 18 col, 18 + 18 row) in the shared container, slots 45 to 53 the hotbar at (9 + 18 i, 112) (slot -> x, y, class 1 grid 2 inventory, container slot)','MN7-PSLOT','i',4,[(s,) for s in (0,8,9,44,45,46,53)],ps)
def cp(b,ne,en,lk): return int(en and not lk) if (b and ne) else int(not ne)
rows=[(1,0,1,0),(1,1,1,0),(1,1,0,0),(1,1,1,1),(0,1,1,0),(0,0,1,0)]
run(g,'5.1 CustomCreativeSlot.mayPickup: with a non-empty stack only when its item is enabled and the stack has no creative_slot_lock, otherwise only when the slot is empty (base allows, non-empty, enabled, locked -> may pickup)','MN7-CPICKUP','iiii',1,rows,cp)
run(g,'5.2 calculateRowCount = ceil(size / 9) - 5, canScroll = size > 45','MN7-ROWCOUNT','i',2,[(0,),(45,),(46,),(54,),(55,),(100,),(9,)],lambda n:(-(-n//9)-5,int(n>45)))
def rowat(rc,s):
    p=f32(f32(s)*f32(rc))
    return max(0,int(p+0.5))
rows=[(7,0.5),(7,0.07),(7,0.0715),(7,1.0),(7,0.0),(1,0.5),(1,0.49),(3,0.5),(3,0.8333),(0,0.5),(-2,0.5),(-8,0.5)]
run(g,'5.2, 11.2, 12: getRowIndexForScroll = max(0, (int)(s x rowCount + 0.5)) with the product in single precision: (7, 0.5) is 4, (7, 0.07) 0, (7, 0.0715) 1, (7, 1.0) 7 (rowCount, scroll -> first row)','MN7-ROWAT','if',1,[(r,s) for r,s in rows],rowat)
run(g,'5.2 getScrollForRowIndex = clamp(r / rowCount, 0, 1) (x 1e6) (row, rowCount -> scroll)','MN7-SCROLLOF','ii',1,[(4,7),(0,7),(9,7),(3,1),(0,1),(7,7),(-2,7)],lambda r,c:sc(clamp(r/c,0,1),1e6))
def sub(s,w,c): return sc(clamp(s-w/c,0,1),1e6)
run(g,'5.2, 11.2 subtractInputFromScroll = clamp(s - wheel / rowCount, 0, 1) (x 1e6): 0.5 - 1/7 is 0.357143 (scroll, wheel, rowCount -> scroll)','MN7-SUBTRACT','ffi',1,[(0.5,1.0,7),(0.0,1.0,7),(1.0,-1.0,7),(0.5,-1.0,7),(0.5,0.0,7),(0.9,-3.0,2)],sub)
def st(first,row,col,n):
    i=col+(row+first)*9
    return i if 0<=i<n else -1
rows=[(4,0,0,100),(4,4,8,100),(7,0,0,100),(7,4,8,100),(0,0,0,0),(0,0,0,10),(0,1,0,10),(0,0,9,10),(7,3,1,100),(0,4,8,45),(1,4,8,46)]
run(g,'5.2, 11.2 scrollTo: grid slot (row, col) shows items[col + (row + first) x 9] when inside the list, else the empty stack (-1) (first row, row, col, list size -> index)','MN7-SCROLLTO','iiii',1,rows,st)
run(g,'5.3 canDragTo and canTakeItemForPickAll are true only for slots outside the shared grid container (slot in the grid -> can drag, can pick all)','MN7-DRAGGABLE','i',2,[(1,),(0,)],lambda g_:(1-g_,1-g_))
def pq(ix,tot,hi): return (int(ix>=tot-9 and hi),0)
run(g,'5.3 quickMoveStack: a hotbar slot among the last 9 with an item is set empty (deleted); the result is always the empty stack (index, slot count, has item -> deleted, moved)','MN7-PQUICK','iii',2,[(45,54,1),(53,54,1),(45,54,0),(44,54,1),(0,54,1),(46,47,1),(10,54,0)],pq)
W(g,5)
# ===== 6
g=G7(6,'The screen','T1081','init, drawing order, labels, survival wrappers, selectTab, scrollbar and cursors (core/src/menu-40-7.cob).')
run(g,'6.1 the search box at (leftPos + 82, topPos + 6), 80 x 9, at most 50 characters, text colour -1 (leftPos, topPos -> x, y, w, h, max length, colour)','MN7-SEARCHBOX','ii',6,[(329,172),(0,0)],lambda l,t:(l+82,t+6,80,9,50,-1))
DO=['dimmed world','other tabs','selected tab background','scrollbar cursor','search box','scroller','selected tab button','player preview']
runt(g,'6.2 extractBackground steps in order (step 1 to 8)','MN7-DRAWSTEP','i',[(i,) for i in range(1,9)],lambda i:(DO[i-1],"-"))
def thumb(f,t,s): return (f+175,t+18+int(f32(f32(95)*f32(s))))
run(g,'6.2, 6.6, 11.2 scroller sprite at (leftPos + 175, topPos + 18 + (int)(95 x scroll)), 12 x 15; at scroll 0.5 y is 237 for topPos 172 (leftPos, topPos, scroll -> x, y)','MN7-THUMB','iif',2,[(329,172,0.5),(329,172,0.0),(329,172,1.0),(329,172,0.999),(0,0,0.3333)],thumb)
run(g,'6.3 the selected tab title is drawn only when the tab shows it, at (8, 6) in #404040 (-12566464) without shadow (show title -> drawn, x, y, colour, shadow)','MN7-LABEL','i',5,[(0,),(1,)],lambda s:(s,8,6,-12566464,0))
def wr(i):
    if i<=4: return (-2000,-2000)
    if i<=8:
        k=i-5; return (54+(k//2)*54,6+(k%2)*27)
    if i<=35:
        j=i-9; return (9+18*(j%9),54+18*(j//9))
    if i<=44: return (9+18*((i-9)%9),112)
    return (35,20)
run(g,'6.4, 12: survival tab wrappers: 0 to 4 off screen (-2000), armour 5 to 8 at (54, 6), (54, 33), (108, 6), (108, 33), main from (9, 54), hotbar at y 112, off-hand (35, 20) (inventory menu slot -> x, y)','MN7-WRAP','i',2,[(i,) for i in (0,4,5,6,7,8,9,17,18,35,36,44,45)],wr)
run(g,'6.4 the survival tab has 46 wrappers and the delete slot at (173, 112) in the shared container slot 0: 47 slots','MN7-DELETESLOT','',4,[()],lambda:(173,112,0,47))
def sel(nt,ot,ntab,otab):
    items=1 if nt==3 else 2 if nt==1 else 0
    slots=1 if nt==2 else 2 if ot==2 else 0
    box=int(nt==4)
    clr=1
    if nt==4 and ntab==otab: clr=0
    return (items,slots,box,clr)
rows=[(1,1,1,2),(3,1,6,1),(4,1,7,1),(2,1,14,1),(1,2,1,14),(4,4,7,7),(4,2,7,14),(2,2,14,14),(3,3,6,6),(1,1,1,1)]
run(g,'6.5 selectTab: the items come from the saved hotbars (1) or a copy of the tab list (2); the survival tab replaces the slot list (1), leaving it restores (2); the search box is shown only in the search tab and its text kept only when re-selecting it (new type, old type, new tab, old tab -> items, slot list, box visible, text cleared)','MN7-SELECT','iiii',4,rows,sel)
def hb(i): return (i//9,i%9)
run(g,'6.5 step 2 and 11.10: the hotbar tab list has 81 entries, 9 per saved hotbar: list index -> hotbar and position (index 30 is hotbar 3, entry 3)','MN7-HBLIST','i',2,[(i,) for i in (0,8,9,30,80)],hb)
def hbk(h,j,em):
    if em: return 1 if j==h else 0
    return 2
run(g,'6.5 step 2: an empty saved hotbar gives a paper with creative_slot_lock named inventory.hotbarInfo at entry j = h and empty stacks elsewhere; a used hotbar gives its 9 loaded stacks (hotbar, entry, hotbar empty -> 0 empty stack 1 paper 2 loaded)','MN7-HBENTRY','iii',1,[(3,3,1),(3,2,1),(0,0,1),(8,0,1),(3,3,0),(3,2,0)],hbk)
run(g,'6.5 refreshCurrentTabContents: the search tab runs the search refresh, other tabs re-add the list (selected type -> 1 search refresh 2 list)','MN7-REFRESHCUR','i',1,[(4,),(1,),(3,)],lambda t:1 if t==4 else 2)
def sbx(px,py,l,t,tc): return int(l+175<=px<l+189 and t+18<=py<t+130 and tc)
rows=[(504,190,329,172,1),(503,190,329,172,1),(517,190,329,172,1),(518,190,329,172,1),(504,189,329,172,1),(504,301,329,172,1),(504,302,329,172,1),(504,250,329,172,0)]
run(g,'6.6, 11.1 scrollbar box: leftPos + 175 <= x < leftPos + 189, topPos + 18 <= y < topPos + 130 and the tab can scroll: x 504 to 517, y 190 to 301 for window 854 x 480 (x, y, leftPos, topPos, tab can scroll -> inside)','MN7-SCROLLBOX','iiiii',1,rows,sbx)
def dg(py,t): return sc(clamp((py-(t+18)-7.5)/97,0,1),1e6)
run(g,'6.6, 11.2 drag: scroll = clamp((pointerY - (topPos + 18) - 7.5) / 97, 0, 1) (x 1e6): pointer y 246 at topPos 172 gives 0.5 (pointer y, topPos -> scroll)','MN7-DRAG','ii',1,[(246,172),(190,172),(300,172),(100,172),(205,172),(0,0)],dg)
run(g,'6.6 press: inside the scrollbar box scrolling takes the screen\'s canScroll and the event is consumed (inside, can scroll, scrolling before -> scrolling, consumed)','MN7-PRESS','iii',2,[(1,1,0),(1,0,1),(0,1,0),(0,1,1)],lambda i,c,p:(c if i else p,i))
run(g,'6.6 wheel: after the generic handler, when it did not consume and the screen can scroll the wheel scrolls and consumes (generic consumed, can scroll -> scroll by wheel, consumed)','MN7-WHEEL','ii',2,[(0,1),(1,1),(0,0),(1,0)],lambda g_,c:(int(not g_ and c),int(g_ or c)))
run(g,'6.2, 6.6 screen canScroll: the tab flag and the menu\'s canScroll (tab flag, menu can scroll -> can scroll)','MN7-CANSC','ii',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:a&b)
def cb(i,d,c):
    if not i: return 0
    return 1 if (d and c) else 2 if c else 3
run(g,'6.2 step 4 scrollbar cursor: in the box, resize north-south while dragging and able to scroll (1), the hand when able to scroll (2), not allowed when it cannot (3), none outside (0) (inside, dragging, can scroll -> cursor)','MN7-CURSORBAR','iii',1,[(0,0,0),(1,1,1),(1,0,1),(1,1,0),(1,0,0)],cb)
run(g,'6.2 survival tab delete slot tooltip inventory.binSlot (Destroy Item): shown when the survival tab is selected and the pointer is over the 16 x 16 delete slot (selected type, pointer over -> tooltip)','MN7-DELTIP','ii',1,[(2,1),(2,0),(1,1),(4,1)],lambda t,p:int(t==2 and p))
W(g,6)
# ===== 7
g=G7(7,'Slot click rules','T1083','pre-processing, the survival tab, grid clicks, hotbar clicks, outside clicks and keys (core/src/menu-40-7.cob).')
def pre(sid,inp,se,tt,cd,mp,idl):
    quick=int(inp==1)
    if sid==-999 and inp==0: inp=4
    if inp==4 and not cd: return (0,inp,quick)
    if not se and tt!=2 and inp!=5: return (1,inp,quick)
    if se and not mp: return (0,inp,quick)
    if se and idl and quick: return (2,inp,quick)
    return (3,inp,quick)
rows=[(-999,0,0,1,1,1,0),(-999,0,0,1,0,1,0),(-1,0,0,1,1,1,0),(-1,0,0,2,1,1,0),(-1,5,0,1,1,1,0),(5,4,1,1,0,1,0),(5,4,1,1,1,1,0),(5,0,1,1,1,0,0),(5,1,1,2,1,1,1),(5,0,1,2,1,1,1),(5,1,1,2,1,1,0),(5,1,1,1,1,1,0)]
run(g,'7.1 pre-processing: an outside PICKUP becomes THROW; a THROW needs canDropItems; no slot outside the survival tab and not a drag goes to the outside handler (1); a slot that cannot be picked up stops; shift-click on the delete slot is delete-all (2) (slot id, input, slot exists, tab type, can drop, may pickup, is delete slot -> outcome 0 stop 1 outside 2 delete-all 3 go on, input, quick)','MN7-PRE','iiiiiii',3,rows,pre)
def sv(idl,inp,sw,hi,b,sid,cn,mx):
    if idl and inp!=1: return (1,0)
    if inp==4 and sw and hi: return (2,1 if b==0 else mx)
    if inp==4 and sid==-999 and cn: return (3,0)
    return (4,0)
rows=[(1,0,1,1,0,5,0,64),(1,2,1,0,0,5,0,64),(0,4,1,1,0,5,0,64),(0,4,1,1,1,5,0,64),(0,4,1,1,0,5,0,1),(0,4,0,0,0,-999,1,64),(0,4,0,0,0,-999,0,64),(0,0,1,1,0,5,0,64),(0,4,1,0,0,5,1,64),(0,1,1,1,0,5,0,64)]
run(g,'7.2 survival tab: a click on the delete slot empties the carried stack; THROW on a wrapper with an item takes 1 (button 0) or the max stack; an outside THROW drops the carried stack; anything else goes to the inventory menu (delete slot, input, wrapper, has item, button, slot id, carried non-empty, max stack -> action 1 clear carried 2 drop from slot 3 drop carried 4 forward, count)','MN7-SURV','iiiiiiii',2,rows,sv)
def case(ce,cc,cm,se,sc_,sm,same,b,q):
    if not ce and not se and same:
        if b==0:
            if q: return (1,cm)
            return (1,cc+1 if cc<cm else cc)
        return (1,cc-1) if cc-1>0 else (0,0)
    if se:
        if b==0: return (0,0)
        if not ce: return (1,cc-1) if cc-1>0 else (0,0)
        return (0,0)
    if not ce:
        if b==0: return (0,0)
        return (1,cc-1) if cc-1>0 else (0,0)
    return (2,sm if q else sc_)
rows=[(0,5,64,0,1,64,1,0,1),(0,5,64,0,1,64,1,0,0),(0,64,64,0,1,64,1,0,0),(0,5,64,0,1,64,1,1,0),(0,1,64,0,1,64,1,1,0),(0,5,64,1,0,64,0,0,0),(0,5,64,1,0,64,0,1,0),(0,1,64,1,0,64,0,1,1),(1,0,64,1,0,64,0,0,0),(1,0,64,1,0,64,0,1,0),(0,5,64,0,1,64,0,0,0),(0,5,64,0,1,64,0,1,1),(0,1,64,0,1,64,0,1,0),(1,0,64,0,1,64,0,0,1),(1,0,64,0,1,64,0,1,0),(1,0,16,0,3,16,0,0,0)]
run(g,'7.3 case table: same stack: left click +1 up to the max or the max with shift, right click -1; empty grid slot: left deletes the carried stack, right -1; different stack: left deletes, right -1; empty carried: copy of the grid stack with its count or its max stack with shift (carried empty, carried count, carried max, grid empty, grid count, grid max, same, button, quick -> result 0 empty 1 carried item 2 grid item, count)','MN7-CASE','iiiiiiiii',2,rows,case)
def swc(inp,se,ce,smx):
    if inp==2: return (0 if se else smx,0)
    return (0,0 if (not ce or se) else smx)
run(g,'7.3 SWAP copies a non-empty grid stack with its max count into the inventory slot of the button; CLONE with an empty carried stack and a non-empty grid stack carries a full stack (input 2 swap 3 clone, grid empty, carried empty, grid max -> inventory slot count, carried count)','MN7-SWAPCLONE','iiii',2,[(2,0,1,64),(2,1,1,64),(2,0,1,1),(3,0,1,64),(3,0,0,64),(3,1,1,64),(3,0,1,16)],swc)
run(g,'7.3 THROW from a grid slot drops a copy of count 1 (button 0) or the max stack size; an empty slot drops nothing (grid empty, button, max -> count)','MN7-THROWCOUNT','iii',1,[(0,0,64),(0,1,64),(1,0,64),(0,0,1)],lambda e,b,m:0 if e else (1 if b==0 else m))
run(g,'7.4 step 1: a drag whose button header (bits 0 and 1) is 2 sends the nine hotbar slots 36 to 44 (button -> send)','MN7-DRAGEND','i',1,[(2,),(0,),(1,),(6,),(10,),(4,)],lambda b:int(b&3==2))
def ht(inp,sn,cn,b,cnt):
    if inp==4 and sn and cn: return 1 if b==0 else cnt
    return 0
run(g,'7.4 step 2: THROW on a hotbar slot with both the stack and the carried stack non-empty drops 1 (button 0) or the whole count (input, stack non-empty, carried non-empty, button, count -> dropped)','MN7-HOTTHROW','iiiii',1,[(4,1,1,0,10),(4,1,1,1,10),(4,0,1,0,10),(4,1,0,0,10),(0,1,1,0,10)],ht)
def oc(cn,out,cd,b,cnt):
    if not cn or not out or not cd: return (0,0)
    if b==0: return (cnt,1)
    if b==1: return (1,0)
    return (0,0)
run(g,'7.5 outside click: needs a carried stack, hasClickedOutside and canDropItems; button 0 drops the whole stack and empties the cursor, button 1 drops one, others nothing (carried non-empty, outside, can drop, button, count -> dropped, cursor emptied)','MN7-OUTCLICK','iiiii',2,[(1,1,1,0,64),(1,1,1,1,64),(1,1,1,2,64),(0,1,1,0,64),(1,0,1,0,64),(1,1,0,0,64)],oc)
def key(tt,chat,ng,hi,dig,hh,bc,tch,cap,esc):
    if tt!=4:
        return (1,1,0) if chat else (0,0,0)
    flag=ng or hi
    if flag and dig and hh: return (2,1,0)
    if bc: return (3,0,int(tch))
    if cap and not esc: return (4,0,0)
    return (0,0,0)
rows=[(1,1,0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0,0,0),(4,0,1,0,1,1,0,0,0,0),(4,0,0,1,1,1,0,0,0,0),(4,0,0,0,1,1,0,0,0,0),(4,0,1,0,1,0,1,1,0,0),(4,0,1,0,0,0,1,0,0,0),(4,0,0,0,0,0,0,0,1,0),(4,0,0,0,0,0,0,0,1,1),(4,0,0,0,0,0,0,0,0,0),(3,1,0,0,0,0,0,0,0,0)]
run(g,'7.6 keys: outside the search tab the chat key selects it; in the search tab a digit hotbar key handled for a slot with an item or a non-grid slot is consumed, else the box gets the key (a text change refreshes), a capturing box swallows other keys but Escape (tab type, chat key, hovered slot not grid, hovered has item, digit key, hotbar key handled, box consumed, text changed, box captures, escape -> 1 select search 2 hotbar key 3 box 4 swallow 0 generic, ignore text input, refresh)','MN7-KEY','iiiiiiiiii',3,rows,key)
run(g,'7.6 charTyped: ignored while ignoreTextInput is set or outside the search tab; a text change runs the search refresh (ignore, search tab, text changed -> typed, refresh)','MN7-CHAR','iii',2,[(1,1,1),(0,0,1),(0,1,0),(0,1,1)],lambda i,s,t:(int(not i and s),int(not i and s and t)))
W(g,7)
# ===== 8
g=G7(8,'The search tab','T1085','refresh decision, visible tags, tree matching, result order and tooltip planning (core/src/menu-40-7.cob).')
def sr(qe,hc,hs):
    if qe: return 1
    if not hc: return 0
    return 3 if hs else 2
run(g,'8.1 refreshSearchResults: an empty query shows the whole search list; without a connection the list stays empty; a leading # uses the tag tree (3), else the name tree (2) (query empty, connection, starts with # -> 0 empty 1 whole list 2 name 3 tag)','MN7-SREFRESH','iii',1,[(1,1,0),(1,0,0),(0,0,0),(0,1,0),(0,1,1)],sr)
def vt(q,tag):
    ns,path=tag.split(':',1)
    if ':' in q:
        a,b=[x.strip() for x in q.split(':',1)]
        return int(a in ns and b in path)
    return int(q in path)
rows=[('log','minecraft:logs'),('log','minecraft:logs_that_burn'),('plank','minecraft:logs'),('minecraft:logs','minecraft:logs'),('mine:log','minecraft:logs'),('mine : log','minecraft:logs'),('x:log','minecraft:logs'),('minecraft:','minecraft:logs'),(':log','c:logs'),('LOG','minecraft:logs'),('c:','a:b'),('x','a:'),('longer','a:ab'),('logs','my:mylogs_two')]
tcase(g,'8.1 updateVisibleTags: without a colon the tag path contains the text; with a colon the first colon splits into namespace and path parts, each trimmed, both must be contained; case sensitive (text, tag ns:path -> selected)','MN7-VISTAG',rows,vt)
def low(s): return (s,s.lower())
ttext(g,'8.2, 12 lower-casing: ASCII letters only change, in the root locale (a capital I becomes i, never a dotless i)','MN7-S-LOWER',[((s,),1) for s in ('Iron Ingot','OAK','abc','mIxEd 123 I','I')],low)
def strip(s):
    out="";i=0
    while i<len(s):
        if s[i]=='\u00a7' and i+1<len(s): i+=2; continue
        out+=s[i]; i+=1
    return (s.strip(),out.strip().lower())  # the test harness trims the shown input
ttext(g,'8.2 indexed text per tooltip line: formatting codes (the section sign and the character after it) stripped, trimmed, lower-cased (line -> indexed text)','MN7-S-LINE',[((s,),1) for s in ('\u00a76Iron Ingot','  \u00a7lBold\u00a7r Text ','plain','\u00a7aGreen \u00a7eYellow')],strip)
tcase(g,'8.2 an indexed line that is empty after stripping and trimming is dropped (line -> dropped)','MN7-S-DROP',[('\u00a77',),(' ',),('\u00a7a  ',),('x',),('\u00a7ax',),('  y ',)],lambda s:int(strip(s)[1]==''))
def nm(q,key,txt):
    ns,path=key.split(':',1)
    if ':' in q:
        a,b=[x.strip().lower() for x in q.split(':',1)]
        return int(a in ns and (b in path or b in txt))
    q=q.lower()
    return int(q in txt or q in path)
rows=[('iron','minecraft:iron_ingot','iron ingot'),('oak','minecraft:oak_log','oak log'),('oak','minecraft:oak_planks','oak planks'),('iron','minecraft:stick','stick'),('minecraft:lea','minecraft:leather','leather'),('minecraft:lea','minecraft:stick','a leaf item'),('minecraft:lea','mod:leather','leather'),('minecraft:lea','minecraft:stick','stick'),('mine:lea','minecraft:leather_boots','leather boots'),('IRON','minecraft:iron_ingot','iron ingot'),('log','minecraft:oak_log','oak wood'),('x','minecraft:stick','stick'),('stick','minecraft:iron_ingot','long stick of iron')]
tcase(g,'8.2 name search of one stack: without a colon the lower-cased query is a substring of the indexed text or the item path; with a colon the namespace part must be contained in the namespace and the path part in the path or the text (query, item ns:path, indexed text -> matches)','MN7-S-NAME',rows,nm)
def tg(q,tags):
    ts=[t.split(':',1) for t in tags.split(',')]
    if ':' in q:
        a,b=[x.strip() for x in q.split(':',1)]
        return int(any(a in n for n,p in ts) and any(b in p for n,p in ts))
    return int(any(q in p for n,p in ts))
rows=[('logs','minecraft:logs,minecraft:logs_that_burn'),('burn','minecraft:logs,minecraft:logs_that_burn'),('minecraft:logs','minecraft:logs'),('c:logs','minecraft:logs'),('minecraft:ingots','a:ingots,minecraft:x'),('minecraft:ingots','a:ingots'),('minecraft:ingots','minecraft:other'),('zzz','minecraft:logs'),('x','a:x,b:y'),('b:y','a:x,b:y')]
tcase(g,'8.2 tag search of one stack: without a colon the text is a substring of a tag path; with a colon some tag namespace contains the first part and some tag path the second part (an intersection of two result lists) (query, tags ns:path comma separated -> matches)','MN7-S-TAG',rows,tg)
def res(*a):
    out=[]
    for i in range(0,16,2):
        sid,f=a[i],a[i+1]
        if f and sid not in out: out.append(sid)
    return (len(out),)+tuple(out)+(0,)*(8-len(out))
rows=[(1,1,2,1,3,1,4,1,5,1,6,1,7,1,8,1),(1,0,2,1,3,0,4,1,5,0,6,0,7,0,8,0),(1,1,1,1,2,1,2,0,3,1,1,1,4,0,5,1),(3,1,3,1,3,1,3,1,3,1,3,1,3,1,3,1),(1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0),(5,0,5,1,2,1,5,1,2,0,7,1,7,1,1,0)]
run(g,'8.2 result order: the matching entries in the order they were added, a stack matched through several lines once at its first position (eight (stack id, line matches) pairs -> count, stack ids)','MN7-S-RESULTS','i'*16,9,rows,res)
def tp(adv,grid,tt,le):
    if le: return (0,0,0,0,0)
    keep=int(tt==1 and grid)
    srch=int(not keep)
    return (adv,int(grid),keep,srch and int(tt==4 and grid),srch)
rows=[(0,1,1,0),(1,1,1,0),(0,1,4,0),(0,0,4,0),(0,0,1,0),(0,1,3,0),(0,1,1,1),(1,0,3,0)]
run(g,'8.3 tooltip plan: the advanced flags with the option, the creative variant on a grid slot; an empty line list is returned; a CATEGORY tab grid slot returns the lines unchanged; otherwise tab names are inserted, and visible tags only for a grid slot in the search tab (advanced option, grid slot, tab type, no lines -> advanced, creative variant, unchanged, tag lines, tab names)','MN7-TIPPLAN','iiii',5,rows,tp)
run(g,'8.3 insert positions: tag lines go in at index 1 first, then each tab title at index 1, 2, ..., so the tab names come before the tag lines (tags, tabs -> first tab title index, first tag line index)','MN7-TIPORDER','ii',2,[(0,0),(2,0),(0,2),(2,3),(1,1)],lambda t,b:(1,1+b))
W(g,8)
# ===== 9
g=G7(9,'Packets and listener','T1087','Set Creative Mode Slot rules, the server rule, the listener and the drop throttlers (core/src/menu-40-7.cob).')
run(g,'9.1 handleCreativeModeItemAdd: sent only with infinite materials and an enabled item (infinite, enabled -> send)','MN7-ADD','ii',1,[(1,1),(1,0),(0,1),(0,0)],lambda a,b:a&b)
run(g,'9.1 handleCreativeModeItemDrop: slot -1 is sent with infinite materials, not from another container screen, a non-empty stack and an enabled item; the throttler is incremented (infinite, in another container screen, non-empty, enabled -> send, increment)','MN7-DROP','iiii',2,[(1,0,1,1),(0,0,1,1),(1,1,1,1),(1,0,0,1),(1,0,1,0)],lambda a,b,c,d:(int(a and not b and c and d),)*2)
def srv(inf,en,slot,vs,under):
    if not inf or not en: return (0,0)
    if 1<=slot<=45 and vs: return (1,0)
    if slot<0 and vs:
        return (2,1) if under else (3,0)
    return (0,0)
rows=[(1,1,1,1,1),(1,1,45,1,1),(1,1,0,1,1),(1,1,46,1,1),(1,1,5,0,1),(1,1,-1,1,1),(1,1,-1,1,0),(1,1,-1,0,1),(0,1,5,1,1),(1,0,5,1,1),(1,1,-5,1,1)]
run(g,'9.1 server rule: ignored without infinite materials or for a disabled item; slots 1 to 45 with a valid stack set the slot; a negative slot drops when the throttler is under its threshold (action 2 and the throttler increments), else the too-fast drop is ignored (3); slot 0, above 45 and oversize stacks do nothing (infinite, enabled, slot, stack count valid, throttler under -> action 0 ignore 1 set slot 2 drop 3 ignored too fast, throttler incremented)','MN7-SERVER','iiiii',2,rows,srv)
run(g,'9.2 listener: slotChanged calls handleCreativeModeItemAdd with the slot index, dataChanged does nothing (1 slot changed, 2 data changed -> add called)','MN7-LISTENER','i',1,[(1,),(2,)],lambda k:int(k==1))
run(g,'9.3 throttler: increment adds step 20; tick subtracts 1 while positive; under the threshold when it is not positive or the counter is below it (counter -> incremented, ticked, under 1480, under 1280)','MN7-THROTTLE','i',4,[(0,),(1,),(20,),(1460,),(1480,),(1479,),(1500,),(1279,),(1280,)],lambda c:(c+20,c-1 if c>0 else c,int(c<1480),int(c<1280)))
run(g,'9.3, 11.7 burst: drops allowed before the counter reaches the threshold: 74 on the server (1480), 64 on the client (1280), -1 (no limit) for a threshold that is not positive (threshold, step -> drops)','MN7-BURST','ii',1,[(1480,20),(1280,20),(20,20),(21,20),(100,30),(0,20),(-5,20)],lambda th,s:next(i for i in range(0,10000) if not (i*s<th)) if th>0 else -1)
W(g,9)
# ===== 10
g=G7(10,'The saved hotbars','T1089','counts, file, loading, key use and messages (core/src/menu-40-7.cob).')
run(g,'10: 9 saved hotbars, default stored data version 1343; the file hotbar.nbt','MN7-HB-IDENT','',2,[()],lambda:(9,1343))
runt(g,'10: the file name and the entry names 0 to 8 (hotbar)','MN7-HB-FILE','i',[(i,) for i in (0,4,8)],lambda i:("hotbar.nbt",str(i)))
def hl(fe,vp,v,ok):
    if not fe: return (1,1343,0,0)
    return (0 if ok else 1,v if vp else 1343,0 if ok else 1,0)
run(g,'10 loading: a missing file keeps nine empty hotbars; an absent data version is 1343; an entry that fails to parse becomes an empty hotbar with a warning (file exists, version present, version, entry parses -> hotbar empty, version used, warning, exception logged)','MN7-HB-LOAD','iiii',3,[(0,0,0,0),(1,1,3000,1),(1,0,0,1),(1,1,3000,0),(1,0,0,0)],lambda a,b,c,d:hl(a,b,c,d)[:3])
def hk(i,sp,inf,so,ld,sv):
    if sp: return 3
    if inf and not so and (ld or sv): return 1 if ld else 2
    return 0
rows=[(3,1,1,0,1,0),(3,0,1,0,1,0),(3,0,1,0,0,1),(3,0,1,0,1,1),(3,0,1,1,1,0),(3,0,0,0,1,0),(3,0,1,0,0,0),(5,0,0,0,0,0)]
run(g,'10 key use: spectators go to the spectator hotbar (3); with infinite materials, no screen and a load or save key down the hotbar is loaded (1) or saved (2), load winning; otherwise the hotbar slot is selected (0) (hotbar, spectator, infinite, screen open, load key, save key -> action)','MN7-HB-KEY','iiiiii',1,rows,hk)
run(g,'10 load: for j 0 to 8 inventory slot j gets stack j and a creative slot packet goes to slot 36 + j (j -> packet slot)','MN7-HB-LOADSLOT','i',1,[(0,),(4,),(8,)],lambda j:36+j)
runt(g,'10 messages: inventory.hotbarSaved and inventory.hotbarInfo (message)','MN7-HB-MSG','i',[(1,),(2,)],lambda k:("inventory.hotbarSaved","Item hotbar saved (restore with %1$s + %2$s)") if k==1 else ("inventory.hotbarInfo","Save hotbar with %1$s + %2$s"))
run(g,'10 Hotbar.isEmpty: every stored entry equals the empty stack encoding (number of non-empty entries -> empty)','MN7-HB-ISEMPTY','i',1,[(0,),(1,),(9,)],lambda n:int(n==0))
W(g,10)
