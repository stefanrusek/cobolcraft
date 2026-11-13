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
# ===== 4
STEP={1:(0,0,-1),2:(1,0,0),3:(0,0,1),4:(-1,0,0),5:(0,1,0),6:(0,-1,0)}
YROT={1:180,2:270,3:0,4:90,5:0,6:0}
g=GG(4,'The behaviours','T0756','every behaviour of the registry: projectile table, positions and velocities, armor stand, chest, boats, buckets, heads, equipment, flint and steel, spawn eggs, sulfur cubes, bone meal, TNT, shulker boxes, glass bottle, glowstone, shears, brush, honeycomb, potion and minecarts.')
PT={1:(0,6.0,1.1,1002),2:(0,6.0,1.1,1002),3:(0,6.0,1.1,1002),4:(0,6.0,1.1,1002),5:(0,6.0,1.1,1002),6:(0,6.0,1.1,1002),7:(0,6.0,1.1,1002),8:(0,3.0,1.375,1002),9:(0,3.0,1.375,1002),10:(0,3.0,1.375,1002),11:(1,1.0,0.5,1004),12:(2,6.6666665,1.0,1018),13:(2,6.6666665,1.0,1051)}
def pcfg(i):
    k,u,p,e=PT[i]
    return (k,sc(u,10000000),sc(p,10000000),e,6 if k==2 else 0,6)
run(g,'projectile table (4.1): position kind (0 centre + 0.7 step + y 0.1, 1 firework 0.5000099999997474, 2 charge 1.0), uncertainty and power x 1e7, sound event, level-random draws of asProjectile (6 for the charges) and projectile draws of shoot (6): 13 items in the order arrow, tipped_arrow, spectral_arrow, egg, blue_egg, brown_egg, snowball, experience_bottle, splash_potion, lingering_potion, firework_rocket, fire_charge, wind_charge',"RS2-PROJ-CONFIG","i",6,[(i,) for i in range(1,14)],pcfg)
def ppos(k,ix,iy,iz,sx,sy,sz):
    off,ey={0:(0.7,0.1),1:(0.5000099999997474,0.0),2:(1.0,0.0)}[k]
    return (sc(ix+0.5+off*sx,1000000),sc(iy+0.5+off*sy+ey,1000000),sc(iz+0.5+off*sz,1000000))
run(g,'projectile position (4.1): the default centre + 0.7 * step + (0, 0.1, 0) (worked example 1: (1.2, 64.6, 0.5)), the firework 0.5000099999997474 * step with no extra y, the charges 1.0 * step',"RS2-PROJ-POSITION","iiiiiii",3,[(0,0,64,0,1,0,0),(0,3,5,-2,0,0,1),(1,0,64,0,0,1,0),(1,0,64,0,-1,0,0),(2,0,64,0,0,0,-1),(2,5,5,5,0,-1,0)],ppos)
def fv(sx,sy,sz,nm,*d):
    v=[s+0.11485000000000001*(d[2*i]-d[2*i+1]) for i,s in enumerate((sx,sy,sz))]
    if nm:
        n=math.sqrt(sum(x*x for x in v)); v=[x/n for x in v]
    return tuple(sc(x,10000000) for x in v)
fvr=[(1,0,0,1,0.5,0.25,0.75,0.5,0.125,0.875),(0,0,-1,0,0.5,0.5,0.25,0.75,0.9,0.1),(0,1,0,1,0.0,1.0,0.5,0.5,0.0,1.0),(0,-1,0,0,0.75,0.25,0.5,0.5,0.5,0.5)]
run(g,'fire charge and wind charge velocity (4.1): v = (triangle(stepX, 0.11485000000000001), triangle(stepY, ...), triangle(stepZ, ...)) from six level draws in x, y, z order; the fire charge normalises it, the wind charge keeps it (x 1e7)',"RS2-CHARGE-VELOCITY","iiii"+"f"*6,3,fvr,fv)
def sv(dx,dy,dz,p,u,*d):
    n=math.sqrt(dx*dx+dy*dy+dz*dz)
    k=0.0172275*u
    return tuple(sc((c/n+k*(d[2*i]-d[2*i+1]))*p,10000000) for i,c in enumerate((dx,dy,dz)))
svr=[(1,0,0,1.1,6.0,0.5,0.25,0.5,0.75,0.125,0.875),(0,0,-1,1.375,3.0,0.5,0.5,0.5,0.5,0.5,0.5),(0,1,0,0.5,1.0,0.25,0.75,0.0,1.0,0.5,0.25),(-1,0,0,1.0,6.6666665,0.9,0.1,0.2,0.3,0.4,0.6)]
run(g,'shoot velocity (4.1 step 3, 44-8 6.1): normalize(direction) + triangle(0, 0.0172275 * uncertainty) per axis in x, y, z order, times power (x 1e7)',"RS2-SHOOT-VELOCITY","iiiff"+"f"*6,3,svr,sv)
run(g,'armor stand (4.2): the stand is placed at the bottom centre of the front block, its yaw is the facing yaw (north 180, east 270, south 0, west 90, up and down 0) and a spawned entity costs one item (new count, yaw, x, y, z x 1e6)',"RS2-ARMORSTAND","iiiiii",5,[(1,d,bx,by,bz,5) for d,(bx,by,bz) in zip(range(1,7),[(0,64,-1),(1,64,0),(2,5,3),(-1,64,0),(0,65,0),(0,63,0)])]+[(0,1,0,64,-1,5)],lambda s,d,bx,by,bz,c:(c-s,YROT[d],sc(bx+0.5,1000000),by*1000000,sc(bz+0.5,1000000)))
def chest(c,n,*p):
    tk=0
    for i in range(n):
        if p[2*i] and p[2*i+1]: tk=i+1; break
    return (tk,c-1 if tk else c,int(tk>0),int(tk==0))
cr=[(5,0,0,0,0,0,0,0,0,0),(5,1,1,1,0,0,0,0,0,0),(5,1,1,0,0,0,0,0,0,0),(5,2,0,1,1,1,0,0,0,0),(5,3,1,0,1,0,1,1,0,0),(5,4,0,0,0,0,0,0,1,1),(5,4,1,0,1,0,1,0,1,0),(1,1,1,1,0,0,0,0,0,0)]
run(g,'chest (4.3): the first alive chest-less horse in the front box that is tamed and whose slot 499 accepts the chest takes it (index, new count, success, dropped); no taker drops it as an item (n entities with (tamed, accepted) pairs)',"RS2-CHEST-TAKE","iiiiiiiiii",4,cr,chest)
def boat(w,ix,iy,iz,sx,sy,sz,water,air,below):
    if water: off=1.0
    elif air and below: off=0.0
    else: return (0,0,0,0,1)
    d=0.5625+w/2.0
    return (1,sc(ix+0.5+sx*d,1000000),sc(iy+0.5+sy*1.125+off,1000000),sc(iz+0.5+sz*d,1000000),0)
br=[(1.375,0,64,0,0,0,-1,1,0,0),(1.375,0,64,0,0,0,-1,0,1,1),(1.375,0,64,0,0,0,-1,0,0,0),(1.375,0,64,0,0,0,-1,0,1,0),(1.375,3,10,3,1,0,0,1,0,0),(1.0,3,10,3,0,1,0,1,0,0),(1.0,3,10,3,0,-1,0,0,1,1)]
run(g,'boats (4.4): d = 0.5625 + width / 2, y gets stepY * 1.125 and then yOffset 1.0 for water in front, 0.0 for air above water; otherwise the second default object drops the boat with doubled events (placed, x, y, z, doubled)',"RS2-BOAT","fiiiiiiiii",5,br,boat)
run(g,'filled bucket (4.5): emptyContents true consumes with the empty bucket as remainder and runs checkExtraContent; false takes the fallback with doubled events (consume path, extra content, doubled)',"RS2-BUCKET-FILLED","i",3,[(0,),(1,)],lambda e:(1,1,0) if e else (0,0,1))
def be(p,e):
    if not p: return (0,0)
    if e: return (0,0)
    return (1,1)
run(g,'empty bucket (4.6): a BucketPickup that gives something fires fluid_pickup and returns the remainder item (path 1); an empty pick or a block that is not a BucketPickup runs the base execute once (path 0) (path, game event)',"RS2-BUCKET-EMPTY","ii",2,[(0,0),(1,1),(1,0)],be)
def head(k,air,can,eq):
    if air and can: return (1,1,1,1,int(k==1))
    return (0,eq,eq,0,0)
hr=[(k,a,c,e) for k in (1,2) for (a,c,e) in ((1,1,0),(1,0,1),(0,1,1),(0,0,0))]
run(g,'wither skull and carved pumpkin (4.7, 4.8): the block is placed on air when the pattern can spawn (game event block_place, success, one item; the skull also runs checkSpawn); otherwise dispenseEquipment decides success and the item (placed, success, shrink, game event, checkSpawn)',"RS2-HEAD-BLOCK","iiii",5,hr,head)
def eqcan(*a): return int(all(a))
er=[(1,1,1,1,1,1,1,1)]+[tuple(0 if j==i else 1 for j in range(8)) for i in range(8)]
run(g,'canEquipWithDispenser (4.9): alive, not a spectator, equippable with dispensable true, canUseSlot, canBeEquippedBy, an empty slot and canDispenserEquipIntoSlot must all hold',"RS2-EQUIP-CAN","i"*8,1,er,eqcan)
def rule(c,s,pk,t,own):
    if c==0: return 1
    if c==1: return pk
    if c==2: return t if s in (1,2) else own
    return int(s==1)
rr=[(0,1,0,0,0),(0,3,0,0,0),(1,1,1,0,0),(1,1,0,0,0),(2,1,0,1,0),(2,2,0,1,0),(2,1,0,0,1),(2,2,0,0,0),(2,3,0,1,1),(2,3,0,1,0),(3,1,0,0,0),(3,2,0,0,0),(3,3,0,0,0)]
run(g,'canDispenserEquipIntoSlot (4.9): living entities true, a mob only when it can pick up loot, a horse for body and saddle when tamed (else its own rule), a sulfur cube for the body slot only (class 0 living 1 mob 2 horse 3 sulfur cube; slot 1 body 2 saddle 3 other)',"RS2-EQUIP-RULE","iiiii",1,rr,rule)
run(g,'dispenseEquipment (4.9): with a matching entity one item is split off and equipped; a mob keeps it on death and never despawns; without one the default drops one item (success, shrink, guaranteed drop, persistence, dropped)',"RS2-EQUIP-RUN","ii",5,[(0,0),(1,0),(1,1)],lambda m,mob:(int(m>0),int(m>0),int(m>0 and mob>0),int(m>0 and mob>0),int(m==0)))
def flint(cube,fire,light,tnt,primed):
    if cube: r,s,g_,rm,lit=1,1,0,0,0
    elif fire: r,s,g_,rm,lit=2,1,1,0,0
    elif light: r,s,g_,rm,lit=3,1,2,0,1
    elif tnt: r,s,g_,rm,lit=4,int(primed>0),0,int(primed>0),0
    else: r,s,g_,rm,lit=5,0,0,0,0
    return (r,s,s,g_,rm,lit)
fr=[(1,1,1,1,1),(0,1,1,1,1),(0,0,1,1,1),(0,0,0,1,1),(0,0,0,1,0),(0,0,0,0,0)]
run(g,'flint and steel (4.10): first rule that applies: ignite a sulfur cube, place fire (game event block_place), light a campfire, candle or candle cake (block_change), prime TNT and remove it (fails when the prime fails), else fail; success costs one durability (rule, success, hurt, game event, block removed, lit)',"RS2-FLINT","iiiii",6,fr,flint)
def egg(tn,up,sn,ex):
    al=0 if up else 1
    if tn: return (0,0,0)
    if ex: return (al,2,0)
    if sn: return (al,0,0)
    return (al,1,1)
er2=[(1,0,0,0),(0,0,0,1),(0,1,0,1),(0,0,1,0),(0,1,1,0),(0,0,0,0),(0,1,0,0)]
run(g,'spawn egg (4.11): no entity type returns the stack; alignPosition is true unless the facing is up; an exception loses the egg (empty stack); a null spawn keeps it; a spawn shrinks it and fires entity_place (align, result 0 unchanged 1 one less 2 empty stack, game event)',"RS2-EGG","iiii",3,er2,egg)
run(g,'sulfur cube equipItem (4.12): false for a baby or for the same item as the body, else the body is replaced and a previous body is spawned as an item (ok, spawn old)',"RS2-SULFUR-EQUIP","iii",2,[(b,s,h) for b in (0,1) for s in (0,1) for h in (0,1)],lambda b,s,h:(int(not b and not s),int((not b) and (not s) and h)))
def sd(*r):
    for i,x in enumerate(r):
        if x: return (i+1,1,1)
    return (0,0,0)
run(g,'sulfur cube dispenseBlock (4.12): the first cube whose equipItem is true takes one item (index, shrink, result)',"RS2-SULFUR-DISPENSE","iiii",3,[(0,0,0,0),(1,0,0,0),(0,0,1,1),(0,1,0,0),(0,0,0,1)],sd)
def bm(c,w,cl):
    s=int(c or w)
    return (s,1505 if (s and not cl) else 0,15)
run(g,'bone meal (4.13): growCrop or growWater true succeeds and, on the server, fires level event 1505 with data 15; failure keeps the item and plays the failure click (success, event, data)',"RS2-BONEMEAL","iii",3,[(1,0,0),(0,1,0),(0,0,0),(1,1,0),(1,0,1),(0,0,1)],bm)
def tnt(ex,sw,prev,bx,by,bz):
    if not ex: return (0,0,0,0,0,0,0,0)
    if sw: return (1,prev,0,0,0,0,0,0)
    return (2,1,1,1,1,sc(bx+0.5,1000000),by*1000000,sc(bz+0.5,1000000))
tr=[(0,0,1,0,64,0),(1,1,0,2,64,3),(1,1,1,2,64,3),(1,0,0,1,64,-1),(1,0,1,-2,10,0)]
run(g,'TNT (4.14): with tnt_explodes false it fails; a swallowing cube leaves success untouched (shared flag, so the click can be 1001); otherwise PrimedTnt at (x + 0.5, block y, z + 0.5), TNT_PRIMED, game event entity_place, one item (path, success, shrink, sound, game event, x, y, z x 1e6)',"RS2-TNT","iiiiii",8,tr,tnt)
def shul(bi,be_,d,con):
    return (d if be_ else 5, int(con) if bi else 0)
run(g,'shulker box (4.15): the up direction of the place context is the facing when the block below the front block is empty, else up; success is consumesAction of a BlockItem, any other item fails without a drop (up, success)',"RS2-SHULKER","iiii",2,[(1,1,2,1),(1,0,2,1),(1,1,3,0),(0,1,2,1),(1,0,6,0)],shul)
def bot(hive,water):
    if hive: return (1,1,1,1,0)
    if water: return (2,1,2,1,0)
    return (3,0,0,0,1)
run(g,'glass bottle (4.16): a beehive with honey_level 5 gives a honey bottle, water in front a water potion bottle (both fire fluid_pickup and succeed), anything else drops the bottle with the failure click (path, success, remainder 1 honey 2 water potion, game event, dropped)',"RS2-BOTTLE","ii",5,[(1,1),(1,0),(0,1),(0,0)],bot)
def glow(a,ch):
    if not a: return (1,0,1,0)
    if ch!=4: return (0,1,1,1)
    return (0,0,0,0)
run(g,'glowstone (4.17): a respawn anchor with charge below 4 is charged and uses one item; a full anchor fails and keeps it (no drop); any other block drops one (drop, shrink, success, charged)',"RS2-GLOWSTONE","ii",4,[(0,0),(1,0),(1,3),(1,4)],glow)
def shears(cl,hive,ent):
    if cl: return (0,0,0)
    if hive: return (1,1,1)
    if ent==1: return (1,1,2)
    if ent==2: return (1,1,3)
    return (0,0,0)
run(g,'shears (4.18): nothing on a client level; a beehive with honey_level 5 first, then the first entity whose leash connections are cut (which 2) or which can be sheared (which 3); success costs one durability (success, hurt, which)',"RS2-SHEARS","iii",3,[(1,1,1),(0,1,0),(0,1,2),(0,0,1),(0,0,2),(0,0,0)],shears)
def brush(n,a,p):
    if n==0 or a==0: return (0,0,1001)
    return (p,16,1000 if p else 1001)
run(g,'brush (4.19): without an armadillo or when none gives a scute the shared success flag becomes false for good; the accepted brush takes 16 durability and the click follows the shared flag (new success, durability, click event)',"RS2-BRUSH","iii",3,[(0,0,1),(2,0,1),(1,1,1),(1,1,0),(3,2,1),(3,2,0)],brush)
run(g,'honeycomb (4.20): a waxed state present writes it, level event 3003, the wax-on sound and one item; otherwise one item is dropped; success is never set to false (wax, event, sound, shrink, success, dropped)',"RS2-HONEYCOMB","i",6,[(1,),(0,)],lambda w:(1,3003,1,1,1,0) if w else (0,0,0,0,1,1))
def pot(w,c):
    if w and c: return (2,5,1,1,1)
    return (1,0,0,0,0)
run(g,'potion (4.21): only a water potion on a convertible_to_mud block turns it to mud (five splash particles, BOTTLE_EMPTY, fluid_place, a glass bottle as remainder); everything else is the doubled fallback (path, particles, sound, game event, bottle)',"RS2-POTION","ii",5,[(0,0),(0,1),(1,0),(1,1)],pot)
def mc(ix,iy,iz,sx,sy,sz,fr,fs,fa,br_,bs):
    if fr: off=0.6 if fs else 0.1
    elif fa and br_: off=-0.9 if (sy==-1 or not bs) else -0.4
    else: return (0,0,0,0)
    return (1,sc(ix+0.5+sx*1.125,1000000),sc(iy+sy+off,1000000),sc(iz+0.5+sz*1.125,1000000))
mr=[(0,64,0,1,0,0,1,0,0,0,0),(0,64,0,1,0,0,1,1,0,0,0),(0,64,0,0,0,-1,0,0,1,1,0),(0,64,0,0,0,-1,0,0,1,1,1),(0,64,0,0,-1,0,0,0,1,1,1),(0,64,0,0,1,0,0,0,1,0,0),(2,5,2,0,0,1,0,0,0,0,0)]
run(g,'minecarts (4.22): x and z come from centre + step * 1.125, y from the dispenser block y + stepY; a rail in front gives yOffset 0.1 (0.6 on a slope); air above a rail gives -0.9 (-0.4 for a slope unless the facing is down); anything else is the doubled fallback (placed, x, y, z)',"RS2-MINECART","iiiiiiiiiii",4,mr,mc)
run(g,'random yaw (4.2, 4.11): the level-random nextFloat * 360 is drawn before the armor stand step overwrites the yaw (yaw x 1e6)',"RS2-SPAWN-YAW","f",1,[(0.0,),(0.25,),(0.5,),(0.75,)],lambda r:sc(r*360,1000000))
W(g,4)
# ===== 5
def rot16(box,face):
    # box (x0,y0,z0,x1,y1,z1) written as the north box; horizontal turns of 24 part 4 2.4: east (x,z)->(16-z,x), south (16-x,16-z), west (z,16-x)
    x0,y0,z0,x1,y1,z1=box
    pts=[(x,z) for x in (x0,x1) for z in (z0,z1)]
    f={1:lambda x,z:(x,z),2:lambda x,z:(16-z,x),3:lambda x,z:(16-x,16-z),4:lambda x,z:(z,16-x)}[face]
    q=[f(x,z) for x,z in pts]
    return (min(a for a,b in q),y0,min(b for a,b in q),max(a for a,b in q),y1,max(b for a,b in q))
def column(w,y0,y1): return ((16-w)//2,y0,(16-w)//2,(16+w)//2,y1,(16+w)//2)
g=GG(5,'Hopper','T0758','placement, locking by signal, shapes, the cooldown handoff and the throughput.')
run(g,'placement (5.1): facing is the opposite of the clicked face, a vertical result replaced by down',"RS2-HOPPER-FACING","i",1,[(d,) for d in range(1,7)],lambda d:6 if d>=5 else OPP[d])
run(g,'state defaults (5.1): facing down, enabled true',"RS2-HOPPER-STATE","",2,[()],lambda :(6,1))
run(g,'checkPoweredState (5.1): shouldEnable = not hasNeighborSignal at the hopper position only; a differing value is written with flags 2 (should enable, write, flags)',"RS2-HOPPER-ENABLE","ii",3,[(s,e) for s in (0,1) for e in (0,1)],lambda s,e:(1-s,int((1-s)!=e),2 if (1-s)!=e else 0))
run(g,'locked by signal (5.1): enabled false stops tryMoveItems and entityInside pickup, but pushes from droppers and other hoppers are still accepted (try move, entity pickup, push accepted)',"RS2-HOPPER-ACTIVE","i",3,[(0,),(1,)],lambda e:(e,e,1))
SPOUT=(6,4,0,10,8,8)
def spout(f):
    if f==6: return (6,0,6,10,6,10)
    return rot16(SPOUT,f)
run(g,'spout (5.2 step 2): boxZ(4, 4, 8, 0, 8) turned to the facing about (8, 6, 8) and clipped to the block (x0, y0, z0, x1, y1, z1 in sixteenths); down gives the stub below the neck',"RS2-HOPPER-SPOUT","i",6,[(f,) for f in (1,2,3,4,6)],spout)
run(g,'bowl (5.2 step 1): the ring column(16, 10, 16), the neck column(8, 4, 10) and the removed cavity column(12, 11, 16)',"RS2-HOPPER-BOWL","i",6,[(1,),(2,),(3,)],lambda i:{1:column(16,10,16),2:column(8,4,10),3:column(12,11,16)}[i])
def stub(f):
    if f==6: return (0,0,0,0,0,0,0)
    return (1,)+rot16((6,8,0,10,10,4),f)
run(g,'interaction shape (5.2): the cavity column plus a boxZ(4, 8, 10, 0, 4) stub turned to a horizontal facing; down has the cavity alone (stub present, box)',"RS2-HOPPER-STUB","i",7,[(f,) for f in (1,2,3,4,6)],stub)
def hand(e,dh,dc,sh,dt,st):
    if not (e and dh and not dc): return 0
    k=1 if (sh and dt>=st) else 0
    return 8-k
hr2=[(1,1,0,1,100,100),(1,1,0,1,101,100),(1,1,0,1,99,100),(1,1,0,0,100,100),(0,1,0,1,100,100),(1,0,0,1,100,100),(1,1,1,1,100,100)]
run(g,'cooldown handoff (5.3 item 2): an item into an empty hopper that is not on a custom cooldown gives 8 - 1 = 7 when the source is a hopper that ticked no later in the same game tick, else 8; any other case leaves the cooldown (0) (cooldown set)',"RS2-HOPPER-HANDOFF","iiiiii",1,hr2,hand)
run(g,'throughput (5.3 item 1): one item per 8 ticks, so ticks / 8 items and 2.5 items per second (x 10)',"RS2-HOPPER-RATE","i",2,[(0,),(7,),(8,),(20,),(160,)],lambda t:(t//8,25))
W(g,5)
# ===== 6
g=GG(6,'Crafter','T0760','constants, placement, triggering, the crafting dispatch, the output paths and the silence rule.')
run(g,'constants (6.1): CRAFTING_TICK_DELAY 4, MAX_CRAFTING_TICKS 6, recipe cache 10 entries, advancement box edge 17',"RS2-CRAFTER-CONST","",4,[()],lambda :(4,6,10,17))
run(g,'placement (6.1): the top is the opposite of the horizontal direction for a down front, the horizontal direction for an up front, up for a horizontal front (front, horizontal direction of the placer)',"RS2-CRAFTER-TOP","ii",1,[(6,1),(6,2),(5,1),(5,4),(1,3),(2,1),(3,2),(4,4)],lambda f,h:OPP[h] if f==6 else (h if f==5 else 5))
run(g,'placed against a powered block (6.1): triggered starts true and the tick is scheduled; unpowered starts false (triggered, scheduled)',"RS2-CRAFTER-PLACE","i",2,[(0,),(1,)],lambda s:(s,s))
def cn(ent,p,t,c):
    if not ent: return (0,t,c,0)
    if p and not t: return (1,1,c,2)
    if (not p) and t: return (0,0,0,2)
    return (0,t,c,0)
run(g,'neighbourChanged (6.2): with the block entity, powered and not triggered schedules 4 ticks and sets triggered; not powered and triggered clears triggered and crafting (flags 2); no quasi-connectivity (schedule, triggered, crafting, flags)',"RS2-CRAFTER-NEIGHBOR","iiii",4,[(1,1,0,0),(1,1,0,1),(1,0,1,1),(1,0,0,0),(1,1,1,1),(0,1,0,0)],cn)
def cf(ent,rec,asm):
    if not ent: return (0,0,0,0,0)
    if (not rec) or (not asm): return (1,1050,0,0,0)
    return (2,0,6,1,1)
run(g,'dispenseFrom (6.3): no block entity stops; no recipe or an empty assembled result plays 1050 and leaves everything; else crafting ticks 6, crafting true and onCraftedBySystem (outcome, event, ticks, crafting, crafted)',"RS2-CRAFTER-FROM","iii",5,[(0,1,1),(1,0,1),(1,1,0),(1,1,1)],cf)
run(g,'dispenseFrom step 6 (6.3): every non-empty slot shrinks by exactly 1, empty slots are skipped',"RS2-CRAFTER-SHRINK","i",1,[(0,),(1,),(5,),(64,)],lambda c:c-1 if c>0 else 0)
def path(t,cr,c,mx):
    if not t: return 0
    return 1 if (cr or c>mx) else 2
run(g,'dispenseItem container paths (6.4): no target gives none (0); a crafter target or a stack above its max stack size gives one item at a time (1); otherwise whole-stack addItem (2) (path)',"RS2-CRAFTER-PATH","iiii",1,[(0,0,4,64),(1,0,4,64),(1,1,4,64),(1,0,65,64),(1,0,64,64),(1,0,4,16)],path)
run(g,'dispenseItem moves (6.4 steps 1 to 3): both container paths move what the target has room for and leave the rest; no target moves nothing (path, count, room, rest)',"RS2-CRAFTER-MOVE","iii",1,[(0,4,9),(1,4,9),(1,4,2),(2,4,0),(2,4,4),(2,4,3),(1,0,5)],lambda p,c,r:c if p==0 else max(c-r,0))
def aft(rest,fr):
    if rest<=0: return (0,0,0,0,0)
    return (1,1,1049,2010,DATA[fr])
run(g,'silence rule (6.4 step 4): only a leftover is spawned and then the advancement, 1049 and the 2010 smoke with the front 3D data fire; an output that fits a container in front is silent (spawn, advancement, 1049, 2010, data)',"RS2-CRAFTER-AFTER","ii",5,[(0,6),(4,6),(1,2),(2,1)],aft)
def disp(t,cr,c,mx,room,fr):
    p=path(t,cr,c,mx)
    rest=c if p==0 else max(c-room,0)
    return (p,rest)+aft(rest,fr)
dr6=[(1,0,4,64,20,6),(1,0,4,64,0,6),(0,0,4,64,0,1),(1,1,3,64,3,2),(1,1,3,64,1,2),(1,0,65,64,64,5)]
run(g,'worked example 5 and the free-air case: a crafter facing down onto a hopper with room puts 4 items in silently; a full hopper or open air spawns them with sound, smoke and advancement (path, rest, spawn, advancement, 1049, 2010, data)',"RS2-CRAFTER-DISPENSE","iiiiii",7,dr6,disp)
W(g,6)
