import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/30-redstone-4-dispensing-hoppers-crafters.md. Directions: 1 north, 2 east, 3 south, 4 west, 5 up, 6 down.
def S(*a): return " ".join(str(x) for x in a)
def show(*v): return "/".join(str(x) for x in v)
def GG(n,subj,tasks,desc): return Gen('TEST-REDSTONE-30-4-%d'%n,'30-4§%d'%n,subj,'Test of 30 part 4 section %d, %s (core/src/redstone-30-4.cob; %s): %s'%(n,subj,tasks,desc),' 01 WS-NM                PIC X(32).\n')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_redstone_30_4_%d.cob'%n)
def C(name,ins,nout):
    toks=[]
    for j,c in enumerate(ins): toks.append(("WS-I(%d)" if c=='i' else "WS-FX(%d)")%(j+1))
    toks+=["WS-R(%d)"%(k+1) for k in range(nout)]
    return 'CALL "%s" USING %s'%(name," ".join(toks))
def run(g,text,name,ins,nout,rows,model):
    g.run(text,[S(*r) or "0" for r in rows],C(name,ins,nout),nout," ".join(show(*model(*r)) if isinstance(model(*r),tuple) else str(model(*r)) for r in rows))
def rnd(x):
    return int(math.floor(abs(x)*1+0.5))*(1 if x>=0 else -1)
def sc(x,s): return rnd(x*s)
OPP={1:3,2:4,3:1,4:2,5:6,6:5}
DATA={1:2,2:5,3:3,4:4,5:1,6:0}
# ===== 1
g=GG(1,'Dispenser and dropper blocks','T0750','state, placement, use, triggering with the quasi-connectivity test, the empty-slot events and the dropper path.')
run(g,'opposite direction helper: north south, east west, up down',"RS2-DIR-OPPOSITE","i",1,[(d,) for d in range(1,7)],lambda d:OPP[d])
run(g,'placement (1.1): facing is the opposite of the nearest looking direction, including up and down',"RS2-DISP-FACING","i",1,[(d,) for d in range(1,7)],lambda d:OPP[d])
run(g,'state defaults (1.1): facing north, triggered false, TRIGGER_DURATION 4, 9 slots',"RS2-DISP-STATE","",4,[()],lambda :(1,0,4,9))
run(g,'use (1.1): dispenser awards inspect_dispenser (1), dropper inspect_dropper (2), hopper inspect_hopper (3); the result is SUCCESS (1) in every case',"RS2-USE-STAT","i",2,[(k,) for k in (1,2,3)],lambda k:(k,1))
run(g,'quasi-connectivity (1.2 step 1): powered is the signal at the position or at the position above',"RS2-DISP-POWERED","ii",1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:int(a or b))
def nb(p,t):
    if p and not t: return (1,4,1,2,1)
    if (not p) and t: return (0,0,0,2,2)
    return (0,0,t,0,0)
run(g,'neighbour change (1.2): powered and not triggered schedules a tick 4 later and sets triggered with flags 2; not powered and triggered clears it with flags 2 and no schedule; otherwise nothing (schedule, delay, triggered, flags, action)',"RS2-DISP-NEIGHBOR","ii",5,[(a,b) for a in (0,1) for b in (0,1)],nb)
def sim(*s):
    t=0; cnt=0; first=-1
    for tick,sig in enumerate(s):
        p=sig
        if p and not t: t=1; cnt+=1; first=tick+4 if first<0 else first
        elif (not p) and t: t=0
    return (cnt,first)
sims=[(1,1,0)+(0,)*9,(0,)*3+(1,)*9,(0,)*12,(1,0,1,0,1,0)+(0,)*6,(0,0,0,0,1,1,1,0,0,0,0,0),(1,)*12]
run(g,'one rising edge gives exactly one dispense however long the signal stays on; a pulse shorter than 4 ticks still dispenses once (worked example 1): number of dispenses and the tick of the first, per 12 ticks of signal',"RS2-DISP-SIM","i"*12,2,sims,sim)
def emp(slot,drop):
    if slot>=0: return (1,0,0)
    return (0,1001,0 if drop else 1)
run(g,'dispenseFrom with an empty slot choice (1.3 step 3, 1.4 step 2): event 1001 and game event block_activate (1) for a dispenser, only 1001 for a dropper; a chosen slot goes on (proceed, event, game event)',"RS2-DISP-EMPTY","ii",3,[(s,d) for s in (-1,0,4) for d in (0,1)],emp)
run(g,'dispenseFrom step 5 (1.3): the slot is written with the behaviour result unless the behaviour is NOOP',"RS2-DISP-APPLY","i",1,[(0,),(1,)],lambda n:1-n)
def dr(slot,empty,cont,rest,cnt):
    if slot<0: return (0,1001,cnt,0)
    if empty: return (0,0,cnt,0)
    if not cont: return (1,0,cnt-1,1)
    if rest: return (2,0,cnt-1,1)
    return (2,0,cnt,1)
rows=[(-1,0,0,0,5),(2,1,0,0,0),(3,0,0,0,5),(3,0,1,1,5),(3,0,1,0,5),(0,0,1,1,1)]
run(g,'dropper (1.4): empty slot choice event 1001 only; an empty stack stops with no write; no container uses the plain default behaviour (count - 1); a container takes one item through addItem (count - 1 when nothing is left over, else unchanged) with no event at all (outcome, event, new count, written)',"RS2-DROPPER-RUN","iiiii",4,rows,dr)
run(g,'dropper step 4 (1.4): the facing is re-read from the block state in the world, not from the state passed to the tick',"RS2-DROPPER-FACING","ii",1,[(1,2),(3,3),(4,6)],lambda a,b:b)
def quasi(k,x,y,z):
    d0=abs(x)+abs(y)+abs(z); d1=abs(x)+abs(y-1)+abs(z)
    return int(d0==1 or (k==1 and d1==1))
qr=[(k,x,y,z) for k in (1,2,3) for (x,y,z) in ((0,0,-1),(0,2,0),(0,3,0),(1,1,0),(0,1,0),(2,0,0))]
run(g,'worked example 2: a source next to the block above a dispenser triggers it (a redstone block two above does, three above does not); a crafter or hopper has no quasi-connectivity (kind, dx, dy, dz of the source)',"RS2-QUASI","iiii",1,qr,quasi)
W(g,1)
# ===== 2
g=GG(2,'The default dispense behaviour and event system','T0752','events, accuracy, the spawn position and motion, consumeWithRemainder.')
run(g,'3D data value of a direction (2): down 0, up 1, north 2, south 3, west 4, east 5 (the east smoke of worked example 1 is 5)',"RS2-FACING-DATA","i",1,[(d,) for d in range(1,7)],lambda d:DATA[d])
run(g,'dispense order (2): sound event 1000 for the default and the Optional success, 1001 for the Optional failure; the animation event is always 2000 with the 3D data value (kind, facing)',"RS2-DEF-PLAY","ii",3,[(k,d) for k in (1,2,3) for d in (1,2,5)],lambda k,d:(1001 if k==3 else 1000,2000,DATA[d]))
def ls(i,r1,r2):
    t={1000:(1,1000,1.0),1001:(1,1000,1.2),1002:(1,1000,1.2),1004:(2,1000,1.2),1018:(3,2000,(r1-r2)*0.2+1.0),1049:(1,1000,1.0),1050:(1,1000,1.0),1051:(1,500,0.4/(r1*0.4+0.8))}
    if i not in t: return (0,0,0)
    c,v,p=t[i]
    return (c,v,sc(p,1000000))
lr=[(1000,0.5,0.25),(1001,0.5,0.25),(1002,0.5,0.25),(1004,0.5,0.25),(1018,0.75,0.25),(1018,0.25,0.75),(1049,0.5,0.25),(1050,0.5,0.25),(1051,0.5,0.25),(1051,0.0,0.25),(1051,0.875,0.25),(999,0.5,0.5)]
run(g,'level event sounds (2 table): category (1 blocks, 2 neutral, 3 hostile), volume x 1000 and pitch x 1e6; 1018 pitch (r1 - r2) * 0.2 + 1.0 with volume 2.0, 1051 pitch 0.4 / (r * 0.4 + 0.8) with volume 0.5; an id that is not in the table gives 0',"RS2-LEVEL-SOUND","iff",3,lr,ls)
def tri(c,d,a,b): return sc(c+d*(a-b),10000000)
run(g,'triangle(c, d) = c + d * (nextDouble() - nextDouble()) (2, x 1e7)',"RS2-TRIANGLE","ffff",1,[(0.2,0.1033,0.75,0.25),(0.0,0.0172275,0.5,0.5),(1.0,0.11485,0.125,0.875),(-1.0,0.2,0.0,1.0)],tri)
def dp(ix,iy,iz,sx,sy,sz,off,ey): return (sc(ix+0.5+off*sx,1000000),sc(iy+0.5+off*sy+ey,1000000),sc(iz+0.5+off*sz,1000000))
dpr=[(0,64,0,1,0,0,0.7,0),(0,64,0,0,0,-1,0.7,0.1),(10,5,-3,0,1,0,0.7,0),(10,5,-3,0,-1,0,0.5000099999997474,0),(-4,70,9,-1,0,0,1.0,0)]
run(g,'dispense position (2): centre (block position + 0.5) + offset * facing step + extra y; the default offset is 0.7 (worked example 1 gives (1.2, 64.5, 0.5))',"RS2-DISPENSE-POS","iiiiiiff",3,dpr,dp)
run(g,'spawnItem height (2): y is lowered by 0.125 when the facing axis is Y, else by 0.15625',"RS2-SPAWN-POS","if",1,[(1,64.5),(0,64.5),(1,10.25),(0,10.25)],lambda a,y:sc(y-(0.125 if a else 0.15625),1000000))
def sm(sx,sy,sz,acc,d,x1,x2,y1,y2,z1,z2):
    sp=d*0.1+0.2; u=0.0172275*acc
    return (sc(sx*sp+u*(x1-x2),10000000),sc(0.2+u*(y1-y2),10000000),sc(sz*sp+u*(z1-z2),10000000))
smr=[(1,0,0,6,0.5,0.75,0.25,0.5,0.5,0.125,0.8125),(0,0,-1,6,0.0,0.0,1.0,1.0,0.0,0.5,0.5),(0,1,0,2,0.25,0.5,0.5,0.25,0.75,0.9,0.1),(-1,0,0,2,1.0,0.3,0.6,0.7,0.2,0.1,0.4)]
run(g,'spawnItem motion (2, 31-2 6.5): speed = nextDouble * 0.1 + 0.2, then x = triangle(stepX * speed, 0.0172275 * accuracy), y = triangle(0.2, ...), z = triangle(stepZ * speed, ...) in that draw order (x 1e7)',"RS2-SPAWN-MOTION","iiii"+"f"*7,3,smr,sm)
def cw(c,f):
    if c==1: return (0,0,0)
    return (1 if f else 2,c-1,0 if f else 1)
run(g,'consumeWithRemainder (2): shrinking the last item returns the remainder as the slot (kind 0); otherwise the stack is kept and the remainder goes in (kind 1) or is dropped through spawnItem (kind 2) (kind, new count, dropped)',"RS2-CONSUME","ii",3,[(1,1),(1,0),(5,1),(5,0),(64,0)],cw)
run(g,'default execute (2): one item is split off the stack',"RS2-DEFAULT-EXEC","i",1,[(1,),(5,),(64,)],lambda c:c-1)
run(g,'fallback through a second default object (4 intro): its dispense plays 1000 and 2000 and the outer dispense plays them again, so events come in pairs of 2; a plain fallback plays one pair (events 1000, events 2000)',"RS2-FALLBACK-EVENTS","i",2,[(0,),(1,)],lambda d:(2 if d else 1,2 if d else 1))
W(g,2)
# ===== 3
PROJ=['arrow','tipped_arrow','spectral_arrow','egg','blue_egg','brown_egg','snowball','experience_bottle','splash_potion','lingering_potion','firework_rocket','fire_charge','wind_charge']
WOODS=['oak','spruce','birch','jungle','dark_oak','acacia','cherry','mangrove','poplar','pale_oak']
BOATS=[w+'_boat' for w in WOODS]+['bamboo_raft']+[w+'_chest_boat' for w in WOODS]+['bamboo_chest_raft']
BUCKETS=['lava_bucket','water_bucket','powder_snow_bucket','salmon_bucket','cod_bucket','pufferfish_bucket','tropical_fish_bucket','axolotl_bucket','sulfur_cube_bucket','tadpole_bucket']
COLOURS=['white','orange','magenta','light_blue','yellow','lime','pink','gray','light_gray','cyan','purple','blue','brown','green','red','black']
SHULK=['shulker_box']+[c+'_shulker_box' for c in COLOURS]
CARTS=['minecart','chest_minecart','furnace_minecart','tnt_minecart','hopper_minecart','command_block_minecart']
SINGLE=[('armor_stand',2),('chest',3),('bucket',6),('flint_and_steel',10),('bone_meal',13),('tnt',14),('wither_skeleton_skull',7),('carved_pumpkin',8),('glass_bottle',16),('glowstone',17),('shears',18),('brush',19),('honeycomb',20),('potion',21)]
REG={}
for i,n in enumerate(PROJ): REG[n]=(1,i+1)
for n in BOATS: REG[n]=(4,0)
for n in BUCKETS: REG[n]=(5,0)
for n in SHULK: REG[n]=(15,0)
for n in CARTS: REG[n]=(22,0)
for n,i in SINGLE: REG[n]=(i,0)
SWALLOW=['bouncy','regular','slow_flat','fast_flat','light','fast_sliding','slow_sliding','sticky','high_resistance','explosive','hot','slow_bouncy']
g=GG(3,'The behaviour registry','T0754','the default-choice rules, the registered items by behaviour and the swallowable tag.')
def rc(en,reg,eq,sw,egg,data):
    if not en: return 0
    if reg: return reg
    if eq: return 9
    if sw: return 12
    if egg and data: return 11
    return 0
rcs=[(0,5,1,1,1,1),(1,5,1,1,1,1),(1,0,1,1,1,1),(1,0,0,1,1,1),(1,0,0,0,1,1),(1,0,0,0,1,0),(1,0,0,0,0,1),(1,0,0,0,0,0),(1,8,1,0,0,0),(1,7,1,0,0,0)]
run(g,'choosing a behaviour (3.1): a disabled item gets the default; a registered entry wins over the default rules (carved pumpkin, wither skull); else equippable (9), swallowable (12), a spawn egg with entity_data (11), the default (0)',"RS2-REG-CHOOSE","iiiiii",1,rcs,rc)
def look(n):
    return REG.get(n,(0,0))
def calls(names): return [("0","MOVE \"%s\" TO WS-NM\n%s"%(n,'CALL "RS2-REG-ITEM" USING WS-NM WS-R(1) WS-R(2)'),2) for n in names]
g.case('registered items (3.2): every one of the 82 items resolves to its behaviour (1 projectile, 2 armor stand, 3 chest, 4 boat, 5 filled bucket, 6 bucket, 7 skull, 8 pumpkin, 10 flint, 13 bone meal, 14 TNT, 15 shulker box, 16 glass bottle, 17 glowstone, 18 shears, 19 brush, 20 honeycomb, 21 potion, 22 minecart) and projectile index; other items give 0',calls(list(REG)+['stone','saddle','dirt','spawn_egg']),
  " ".join(show(*look(n)) for n in list(REG)+['stone','saddle','dirt','spawn_egg']))
cnt={}
for n,(b,_) in REG.items(): cnt[b]=cnt.get(b,0)+1
ids=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22]
run(g,'counts of 3.2: 13 projectile items, 22 boats and rafts, 10 filled buckets, 17 shulker boxes, 6 minecarts, one each of the others, 82 registered in all (id 0), none for the equipment, spawn egg and swallow rules',"RS2-REG-COUNT","i",1,[(i,) for i in ids],lambda i:len(REG) if i==0 else cnt.get(i,0))
g.case('tag sulfur_cube_swallowable (4.12): the 12 archetype references are swallowable, other names are not',[("0","MOVE \"%s\" TO WS-NM\nCALL \"RS2-SWALLOWABLE\" USING WS-NM WS-R(1)"%n,1) for n in SWALLOW+['regular2','stone']]," ".join(["1"]*12+["0","0"]))
W(g,3)
