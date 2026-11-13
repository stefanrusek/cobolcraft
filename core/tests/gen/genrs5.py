import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/30-redstone-5-switches-plates-sensors-notes.md. Directions: 1 north, 2 east, 3 south, 4 west, 5 up, 6 down.
def S(*a): return " ".join(str(x) for x in a)
def show(*v): return "/".join(str(x) for x in v)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
def GG(n,subj,tasks,desc): return Gen('TEST-REDSTONE-30-5-%d'%n,'30-5§%d'%n,subj,'Test of 30 part 5 section %d, %s (core/src/redstone-30-5.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_redstone_30_5_%d.cob'%n)
def C(name,ins,nout):
    toks=[]
    for j,c in enumerate(ins): toks.append(("WS-I(%d)" if c=='i' else "WS-FX(%d)")%(j+1))
    toks+=["WS-R(%d)"%(k+1) for k in range(nout)]
    return 'CALL "%s" USING %s'%(name," ".join(toks))
def run(g,text,name,ins,nout,rows,model):
    g.run(text,[S(*r) or "0" for r in rows],C(name,ins,nout),nout," ".join(show(*model(*r)) if isinstance(model(*r),tuple) else str(model(*r)) for r in rows))
def namerun(g,text,name,nout,names,model,pre=""):
    calls=[("0",'MOVE "%s" TO WS-NM\nCALL "%s" USING WS-NM %s'%(n,name," ".join("WS-R(%d)"%(k+1) for k in range(nout))),nout) for n in names]
    g.case(text,calls," ".join(show(*model(n)) if isinstance(model(n),tuple) else str(model(n)) for n in names))
def rnd(x): return int(math.floor(abs(x)+0.5))*(1 if x>=0 else -1)
def sc(x,s): return rnd(x*s)
OPP={1:3,2:4,3:1,4:2,5:6,6:5}
STEP={1:(0,0,-1),2:(1,0,0),3:(0,0,1),4:(-1,0,0),5:(0,1,0),6:(0,-1,0)}
NM=' 01 WS-NM                PIC X(32).\n'
def G5(n,subj,tasks,desc):
    g=GG(n,subj,tasks,desc); g.extra=NM; return g
# ===== 0
g=G5(0,'Conventions','T0762','the signal defaults, the sound defaults and the push reaction table.')
run(g,'defaults of BlockBehaviour (0): isSignalSource false, ownSignal 0, getDirectSignal 0 (source, own, direct)',"RS2-SIGNAL-DEFAULT","",3,[()],lambda :(0,0,0))
run(g,'getSignal returns ownSignal for every direction, so an ownSignal-only block powers weakly all around (own, direction)',"RS2-GET-SIGNAL","ii",1,[(o,d) for o in (0,7,15) for d in range(1,7)],lambda o,d:o)
run(g,'playSound without volume and pitch uses 1.0 and 1.0 (x 100)',"RS2-SOUND-DEFAULT","",2,[()],lambda :(100,100))
def pushr(k): return int(k<=5)
run(g,'push reaction (0): POPPED for the lever (1), buttons (2), pressure plates (3), weighted plates (4) and the lightning rod (5); not for the note block (6), the daylight detector (7), the target block (8) and the jukebox (9)',"RS2-PUSH-REACTION","i",1,[(k,) for k in range(1,10)],pushr)
W(g,0)
# ===== 1
g=G5(1,'The face-attached base','T0764','the connected direction, the support, the shape update and the placement search.')
def conn(face,f): return 5 if face==0 else (6 if face==2 else f)
run(g,'connected direction (1): floor gives up, ceiling down, wall the facing (face 0 floor 1 wall 2 ceiling)',"RS2-FACE-CONNECTED","ii",1,[(0,1),(0,3),(2,2),(2,4),(1,1),(1,2),(1,3),(1,4)],conn)
run(g,'support position (1): the block hangs on pos + opposite(C): a floor button sits on the block below, a wall block facing north on the block to its south (C, support direction, dx, dy, dz)',"RS2-FACE-SUPPORT","i",4,[(d,) for d in range(1,7)],lambda c:(OPP[c],)+tuple(-v for v in STEP[c]))
run(g,'shape update (1): the block becomes air when the changed neighbour is the one at opposite(C) and canSurvive is false (changed direction, C, can survive)',"RS2-FACE-SHAPE-UPDATE","iii",1,[(OPP[c],c,s) for c in (1,5) for s in (0,1)]+[(1,1,0),(2,1,0)],lambda ch,c,s:int(ch==OPP[c] and not s))
def place(ds,ss,h):
    for i,(d,s) in enumerate(zip(ds,ss)):
        if d>=5: face=2 if d==5 else 0; fac=h
        else: face=1; fac=OPP[d]
        if s: return (i+1,face,fac)
    return (0,-1,0)
pl=[((6,1,2,3,4,5),(1,1,1,1,1,1),3),((5,1,2,3,4,6),(1,0,0,0,0,0),2),((1,5,2,3,4,6),(0,1,0,0,0,0),1),((2,1,3,4,5,6),(0,0,1,0,0,0),4),((3,5,6,1,2,4),(0,0,0,1,0,0),1),((4,5,6,1,2,3),(0,0,0,0,1,0),2),((1,2,3,4,5,6),(0,0,0,0,0,1),3),((1,2,3,4,5,6),(0,0,0,0,0,0),1)]
run(g,'placement (1): the first nearest looking direction whose candidate can survive wins; a vertical one gives floor (down) or ceiling (up) facing the player, a horizontal one a wall block facing its opposite; none refuses (index, face, facing)',"RS2-FACE-PLACE","i"*13,3,[tuple(d)+tuple(s)+(h,) for d,s,h in pl],lambda *a:place(a[0:6],a[6:12],a[12]))
run(g,'default state (1): facing north, face wall, powered false (facing, face, powered)',"RS2-FACE-DEFAULT","",3,[()],lambda :(1,1,0))
W(g,1)
# ===== 2
g=G5(2,'Lever','T0766','signals, use, pull, explosion, removal, the neighbour update pair, particles and shapes.')
def lsig(p,d,c): return (15 if p else 0,15 if (p and d==c) else 0)
run(g,'signals (2.1): ownSignal 15 when powered; getDirectSignal 15 only towards C (the support): a floor lever powers the block below, a wall lever facing north the block to its south (powered, direction, C)',"RS2-LEVER-SIGNAL","iii",2,[(p,d,c) for p in (0,1) for (d,c) in ((5,5),(1,5),(1,1),(3,1))],lsig)
def pull(p): n=1-p; return (n,30,60 if n else 50,1 if n else 2,1,1)
run(g,'pull (2.2): powered flipped and written, neighbours updated, block.lever.click volume 0.3 and pitch 0.6 (on) or 0.5 (off), game event BLOCK_ACTIVATE (1) or BLOCK_DEACTIVATE (2), no tick scheduled (new powered, volume x 100, pitch x 100, game event, written, updated)',"RS2-LEVER-PULL","i",6,[(0,),(1,)],pull)
def use(sv,p):
    if sv: return (1,0,0,1)
    n=1-p
    return (1,10 if n else 0,1 if n else 0,0)
run(g,'use (2.2): the server pulls (no player passed, so nobody is excluded) and returns SUCCESS; the client predicts only: red dust with alpha 1.0 when the new value is true, no write, no sound (result, alpha x 10, client particle, server pulls)',"RS2-LEVER-USE","ii",4,[(1,0),(1,1),(0,0),(0,1)],use)
run(g,'explosion (2.3): onExplosionHit pulls when the explosion can trigger blocks',"RS2-LEVER-EXPLOSION","i",1,[(0,),(1,)],lambda c:c)
run(g,'removal (2.3): a powered lever that was not moved by a piston updates its neighbours (powered, moved by piston)',"RS2-LEVER-REMOVAL","ii",1,[(p,m) for p in (0,1) for m in (0,1)],lambda p,m:int(p and not m))
def upair(c,f):
    s=OPP[c]; up=5 if s<=4 else f
    return (s,up)+STEP[s]
run(g,'neighbour update pair (2.4): s = opposite(C); the orientation is built from s and UP when s is horizontal, else the lever facing; the neighbours at the lever and at pos + s are updated (s, up direction, support dx, dy, dz)',"RS2-FACE-UPDATE-PAIR","ii",5,[(5,1),(6,3),(1,1),(2,2),(3,4)],upair)
def part(f,c,x,y,z,r,p):
    sp=int(bool(p) and r<0.25)
    a=STEP[OPP[f]]; b=STEP[OPP[c]]
    return (sp,)+tuple(sc(v+0.5+0.1*a[i]+0.2*b[i],1000000) for i,v in enumerate((x,y,z)))
pr=[(1,1,10,64,10,0.1,1),(1,1,10,64,10,0.25,1),(1,1,10,64,10,0.2499,1),(1,1,10,64,10,0.1,0),(2,5,0,5,0,0.0,1),(3,6,-4,70,8,0.24,1)]
run(g,'particles (2.5): a powered lever spawns red dust when nextFloat < 0.25, at (X + 0.5 + 0.1 * step(opposite(facing)) + 0.2 * step(opposite(C)), same for Y and Z) (spawn, x, y, z x 1e6; inputs facing, C, X, Y, Z, draw, powered)',"RS2-LEVER-PARTICLE","iiiiifi",4,pr,part)
def box_h(box,f):
    x0,y0,z0,x1,y1,z1=box
    pts=[(x,z) for x in (x0,x1) for z in (z0,z1)]
    fn={1:lambda x,z:(x,z),2:lambda x,z:(16-z,x),3:lambda x,z:(16-x,16-z),4:lambda x,z:(z,16-x)}[f]
    q=[fn(x,z) for x,z in pts]
    return (min(a for a,b in q),y0,min(b for a,b in q),max(a for a,b in q),y1,max(b for a,b in q))
def lshape(face,f):
    base=(5,4,10,11,12,16)  # boxZ(6, 8, 10, 16): x 5 to 11, height 8 about y 8, z 10 to 16
    x0,y0,z0,x1,y1,z1=base
    if face==0: base=(x0,16-z1,y0,x1,16-z0,y1)   # X_270: (x, y, z) -> (x, 16 - z, y)
    elif face==2: base=(x0,z0,16-y1,x1,z1,16-y0) # X_90: (x, y, z) -> (x, z, 16 - y)
    return box_h(base,f)
run(g,'shape (2.6): base box(5, 4, 10)-(11, 12, 16) turned per face and facing: wall north x 5 to 11 z 10 to 16, floor north y 0 to 6, ceiling y 10 to 16; independent of powered (face 0 floor 1 wall 2 ceiling, facing, box in sixteenths)',"RS2-LEVER-SHAPE","ii",6,[(fc,f) for fc in (1,0,2) for f in (1,2,3,4)],lshape)
W(g,2)
# ===== 3
WOOD=['oak','spruce','birch','jungle','acacia','cherry','dark_oak','pale_oak','mangrove','poplar','bamboo']
SETID={'stone':1,'oak':2,'spruce':3,'birch':4,'jungle':5,'acacia':6,'cherry':7,'dark_oak':8,'pale_oak':9,'mangrove':10,'poplar':11,'bamboo':12,'crimson':13,'warped':14,'iron':15,'copper':16,'gold':17,'polished_blackstone':18}
BT={'stone_button':(20,0,'stone'),'polished_blackstone_button':(20,0,'stone')}
for w in WOOD+['crimson','warped']: BT[w+'_button']=(30,1,w)
g=G5(3,'Buttons','T0768','the table of 15 buttons, the arrow rule, press, release and the arrow re-check.')
namerun(g,'table (3.1, V1, V3, V4): 15 buttons: stone and polished blackstone press 20 ticks, ignore arrows and use the stone set type; the 13 wood-type buttons press 30 ticks, accept arrows and use their own set type (ticks, arrows, set type)',"RS2-BUTTON-INFO",3,list(BT),lambda n:(BT[n][0],BT[n][1],SETID[BT[n][2]]))
ARR={t:int(t in range(2,15)) for t in range(1,19)}
run(g,'arrow rule (3.1): wood types (2 to 12), crimson and warped (13, 14) accept arrows; stone (1), iron (15), copper (16), gold (17) and polished blackstone (18) do not',"RS2-ARROW-RULE","i",1,[(t,) for t in range(1,19)],lambda t:ARR[t])
run(g,'signals (3.2): the same as the lever (powered, direction, C)',"RS2-BUTTON-SIGNAL","iii",2,[(p,d,c) for p in (0,1) for (d,c) in ((5,5),(1,5),(2,2),(4,2))],lsig)
run(g,'use (3.3): a powered button returns CONSUME (2) and does nothing; otherwise it presses and returns SUCCESS (1) (result, press)',"RS2-BUTTON-USE","i",2,[(0,),(1,)],lambda p:(2,0) if p else (1,1))
run(g,'press (3.3): written powered, neighbours updated, a tick scheduled for the press time, click-on volume 1.0 pitch 1.0 excluding the pressing player, game event BLOCK_ACTIVATE (written, updated, ticks, volume, pitch, excluded, game event)',"RS2-BUTTON-PRESS","i",7,[(20,),(30,)],lambda t:(1,1,t,100,100,1,1))
def chk(al,ov,p,t):
    ap=int(al and ov); n=int(ap!=p)
    return (ap,n,ap if n else p,(1 if ap else 2) if n else 0,(1 if ap else 2) if n else 0,n,t if ap else 0)
cr=[(al,ov,p,30) for al in (0,1) for ov in (0,1) for p in (0,1)]
run(g,'checkPressed (3.5): arrowPresent only for a type that allows arrows and with an arrow in the outline; a change writes, updates, plays click-on or click-off and the game event; an arrow re-arms the tick (arrow present, written, powered, sound 1 on 2 off, game event, updated, re-armed ticks)',"RS2-BUTTON-CHECK","iiii",7,cr,chk)
def tk(p,al,ov,t):
    if not p: return (0,0,0,p,0,0,0,0)
    return (1,)+chk(al,ov,p,t)
run(g,'tick (3.4): an unpowered button does nothing; a powered one runs checkPressed (ran, then the checkPressed results); a stone button releases at the tick, a wooden one only when no arrow overlaps (worked examples 3 and 4)',"RS2-BUTTON-TICK","iiii",8,[(0,1,1,30),(1,0,0,20),(1,1,1,30),(1,1,0,30)],tk)
run(g,'entityInside (3.6): acts only on the server, for an arrow type and an unpowered button (server, arrows allowed, powered)',"RS2-BUTTON-INSIDE","iii",1,[(s,a,p) for s in (0,1) for a in (0,1) for p in (0,1)],lambda s,a,p:int(s and a and not p))
run(g,'explosion (3.3): presses when the explosion can trigger blocks and the button is not yet powered',"RS2-BUTTON-EXPLOSION","ii",1,[(c,p) for c in (0,1) for p in (0,1)],lambda c,p:int(c and not p))
def bshape(p):
    z0=14 if not p else 15
    return (5,6,z0,11,10,16)
run(g,'shape (3.8): wall north: base box(5, 6, 8)-(11, 10, 16) minus cube(12) unpowered or cube(14) powered, so 2 deep (z 14 to 16) or 1 deep (z 15 to 16)',"RS2-BUTTON-SHAPE","i",6,[(0,),(1,)],bshape)
W(g,3)
# ===== 4
PLATES={'stone_pressure_plate':(1,2,1),'polished_blackstone_pressure_plate':(18,2,1)}
SFAM={'oak':2,'spruce':2,'birch':2,'jungle':2,'acacia':2,'dark_oak':2,'pale_oak':2,'mangrove':2,'poplar':2,'cherry':3,'crimson':4,'warped':4,'bamboo':5}
for w in WOOD+['crimson','warped']: PLATES[w+'_pressure_plate']=(SETID[w],1,SFAM[w])
g=G5(4,'Pressure plates','T0770','the shared engine, the filter, the on and off plates, the weighted plates and the blocks-dirty notification.')
run(g,'shape (4.1): the outline is 1 high unpressed and 0.5 high pressed (x 10); the touch box is box(1, 0, 1)-(15, 4, 15)',"RS2-PLATE-SHAPE","i",7,[(0,),(1,)],lambda p:(10 if not p else 5,1,0,1,15,4,15))
run(g,'survival (4.1): the block below supports a rigid block on its upper face or supports the centre of its upper face; a shape update towards down gives air when it cannot survive (rigid, centre, down update)',"RS2-PLATE-SURVIVE","iii",2,[(r,c,d) for r in (0,1) for c in (0,1) for d in (0,1)],lambda r,c,d:(int(r or c),int(d and not (r or c))))
run(g,'signals (4.1): ownSignal is the state signal; getDirectSignal gives it only towards up (the block above is strongly powered) (state signal, direction)',"RS2-PLATE-SIGNAL","ii",2,[(s,d) for s in (0,15,7) for d in (5,6,1)],lambda s,d:(s,s if d==5 else 0))
run(g,'entityInside (4.1): nothing on the client; on the server only an unpressed plate (old 0) runs checkPressed (server, old signal)',"RS2-PLATE-INSIDE","ii",1,[(s,o) for s in (0,1) for o in (0,5)],lambda s,o:int(s and o==0))
run(g,'tick (4.1): a pressed plate re-checks, an unpressed one does nothing',"RS2-PLATE-TICK","i",1,[(0,),(1,),(15,)],lambda o:int(o>0))
def pc(o,n,t):
    w=int(o!=n); on=n>0; was=o>0
    snd=2 if (was and not on) else (1 if (on and not was) else 0)
    return (w,2 if w else 0,w,w,snd,snd,t if on else 0)
run(g,'checkPressed (4.1): a changed signal is written with flags 2, updates the plate and the block below and marks blocks dirty; only the on and off edges play a sound and fire BLOCK_ACTIVATE (1) or BLOCK_DEACTIVATE (2); a pressed plate re-arms its tick (written, flags, updated, dirty, sound, game event, re-armed ticks)',"RS2-PLATE-CHECK","iii",7,[(0,15,20),(15,15,20),(15,0,20),(0,0,20),(4,5,10),(5,4,10),(0,3,10),(3,0,10)],pc)
run(g,'counted entities (4.1): not a spectator and not ignoring block triggers',"RS2-PLATE-COUNTED","ii",1,[(s,i) for s in (0,1) for i in (0,1)],lambda s,i:int((not s) and not i))
def ign(c,m): return int(c in (1,2,3,4,6) or (c==5 and m))
run(g,'isIgnoringBlockTriggers (4.1): true for Display (1), Interaction (2), Marker (3), OminousItemSpawner (4), Bat (6) and a marker ArmorStand (5); false for every other entity (0) (class, marker flag)',"RS2-IGNORES-TRIGGERS","ii",1,[(c,m) for c in range(0,7) for m in (0,1)],ign)
run(g,'on and off plate signal (4.2): the strength is 15 when the count is above 0: EVERYTHING (1) counts every entity, MOBS (2) counts living ones (sensitivity, all entities, living entities)',"RS2-PLATE-STRENGTH","iii",1,[(s,a,l) for s in (1,2) for (a,l) in ((0,0),(1,0),(1,1),(3,2))],lambda s,a,l:15 if (a if s==1 else l)>0 else 0)
namerun(g,'table (4.2, V2, V4): 15 plates: stone and polished blackstone (set types 1 and 18) use MOBS (2); the woods, crimson and warped use EVERYTHING (1); sound families 1 stone, 2 wooden, 3 cherry wood, 4 nether wood, 5 bamboo wood; pressed time 20 (set type, sensitivity, sound family, pressed time)',"RS2-PLATE-INFO",4,list(PLATES),lambda n:PLATES[n]+(20,))
namerun(g,'weighted plates (4.3, V2): light has maxWeight 15 with gold (17), heavy 150 with iron (15), both 10 ticks and the metal click sound (6) (max weight, set type, pressed time, sound family)',"RS2-WEIGHTED-INFO",4,['light_weighted_pressure_plate','heavy_weighted_pressure_plate'],lambda n:(15,17,10,6) if n.startswith('light') else (150,15,10,6))
def wf(n,mx):
    s=min(n,mx)
    if s<=0: return 0
    return int(math.ceil(f32(f32(f32(s)/f32(mx))*f32(15.0))))
run(g,'heavy plate thresholds (4.3, V6): ceil(float(min(150, n)) / 150f * 15f) in binary32 for n = 0 to 153: 0, then 1 for 1 to 10, 2 for 11 to 20, ... 15 from 141',"RS2-WEIGHTED-STRENGTH","ii",1,[(n,150) for n in range(0,154)],wf)
run(g,'light plate (4.3, V6): power = min(n, 15)',"RS2-WEIGHTED-STRENGTH","ii",1,[(n,15) for n in range(0,19)],wf)
run(g,'setBlocksDirty (4.4): empty on the server, a render notification on the client (client, notifies)',"RS2-BLOCKS-DIRTY","i",1,[(0,),(1,)],lambda c:c)
W(g,4)
# ===== 5
def mcos(x):
    i=int(x*10430.378350470453+16384.0)&65535
    return f32(math.sin(i/10430.378350470453))
def daylight(s,ang,inv):
    if inv: s=15-s
    elif s>0:
        a=f32(f32(ang)*f32(0.017453292))
        PI=f32(3.1415927)
        t=0.0 if a<PI else f32(6.2831855)
        a=f32(a+f32(f32(t-a)*f32(0.2)))
        s=int(math.floor(f32(f32(s)*mcos(a))+0.5))
    return max(0,min(15,s))
g=G5(5,'Daylight detector','T0772','the ticker phase, updateSignalStrength with the table cosine in binary32, the inverted mode and use.')
run(g,'ticker (5): only on a server level of a dimension with sky light, and only when game time mod 20 is 0 (server, has sky light, game time)',"RS2-DAYLIGHT-TICK","iii",1,[(1,1,0),(1,1,20),(1,1,40),(1,1,7),(0,1,20),(1,0,20)],lambda s,k,t:int(s and k and t%20==0))
dr=[(15,a,0) for a in (0,45,90,135,180,225,270,315,360)]+[(8,45,0),(1,90,0),(1,270,0),(0,45,0),(15,45,1),(0,45,1),(15,0,1),(7,180,1),(12,30.5,0),(4,60,0)]
run(g,'updateSignalStrength (5, worked example 10, V7): s * cos(a) with a = angle * 0.017453292f pulled towards 0 or 6.2831855f by 0.2, table cosine, Math.round, clamped to 0 to 15; angles 0, 45, 90, 180, 270 at brightness 15 give 15, 12, 5, 0, 5; inverted gives 15 - s whatever the angle (sky brightness, sun angle degrees, inverted)',"RS2-DAYLIGHT-POWER","ifi",1,dr,daylight)
run(g,'write rule (5 step 6): power is written with setBlockAndUpdate only when it changed',"RS2-DAYLIGHT-WRITE","ii",1,[(5,5),(5,6),(0,0),(15,0)],lambda s,p:int(s!=p))
def duse(mb,sv,inv):
    if not mb: return (0,inv,0,0,0)
    if not sv: return (1,inv,0,0,0)
    return (1,1-inv,2,1,1)
run(g,'use (5): without mayBuild the default result; on the server inverted is flipped with flags 2, game event BLOCK_CHANGE is sent and the signal is updated at once; both sides return SUCCESS (handled, new inverted, flags, game event, update now)',"RS2-DAYLIGHT-USE","iii",5,[(0,1,0),(1,0,0),(1,1,0),(1,1,1)],duse)
W(g,5)
# ===== 6
def tstr(x,y,z,face):
    fr=lambda v:abs((v-math.floor(v))-0.5)
    fx,fy,fz=fr(x),fr(y),fr(z)
    m={5:max(fx,fz),6:max(fx,fz),1:max(fx,fy),3:max(fx,fy),2:max(fy,fz),4:max(fy,fz)}[face]
    return max(1,int(math.ceil(15*max(0.0,min(1.0,(0.5-m)/0.5)))))
g=G5(6,'Target block','T0774','strength from the hit position, the hit handler, release and placement.')
tr=[(10.5,64.5,10.5,5),(10.75,64.0,10.5,5),(10.9,64.0,10.5,5),(10.5,64.5,10.0,1),(10.5,64.9,10.0,3),(10.0,64.5,10.5,2),(10.0,64.5,10.25,4),(10.0334,64.0,10.5,5),(10.04,64.0,10.5,5),(10.0,64.0,10.5,6),(10.01,64.5,10.99,5),(-3.25,70.5,-4.5,1)]
run(g,'strength (6.1, V8): m is the larger deviation from the face centre on the two axes other than the face axis; strength = max(1, ceil(15 * (0.5 - m) / 0.5)); the centre gives 15, m 0.25 gives 8, the edge gives 1 (hit x, y, z, face)',"RS2-TARGET-STRENGTH","fffi",1,tr,tstr)
def thit(arrow,pending,st,owner):
    dur=20 if arrow else 8
    w=int(not pending)
    return (w,st if w else 0,dur,w,int(owner),st if owner else 0)
run(g,'hit (6): duration 20 for an arrow, 8 for other projectiles; without a pending tick the strength is written and a tick scheduled, with one nothing changes; the owner player gets the statistic and criterion with the strength of the hit (arrow, tick pending, strength, owner is a player: written, power, duration, scheduled, criterion, criterion strength)',"RS2-TARGET-HIT","iiii",6,[(1,0,8,1),(0,0,15,0),(1,1,12,1),(0,1,3,0)],thit)
run(g,'release (6): a tick with power not 0 writes 0, otherwise nothing',"RS2-TARGET-TICK","i",1,[(0,),(1,),(15,)],lambda p:int(p!=0))
run(g,'placement (6): on the server and not replacing the same block, a power above 0 with no tick pending is written as 0 with flags 18 (server, previous state is the same block, power, tick pending: written, flags)',"RS2-TARGET-PLACE","iiii",2,[(1,0,5,0),(0,0,5,0),(1,1,5,0),(1,0,0,0),(1,0,5,1)],lambda s,sm,p,pd:(1,18) if (s and not sm and p>0 and not pd) else (0,0))
W(g,6)
# ===== 7
g=G5(7,'Lightning rod','T0776','signals, being struck, release, the redirect search, the client rules and copper cleaning.')
run(g,'signals (7): ownSignal 15 when powered; getDirectSignal 15 only towards the facing (powered, direction, facing)',"RS2-ROD-SIGNAL","iii",2,[(p,d,f) for p in (0,1) for (d,f) in ((5,5),(3,5),(1,1))],lambda p,d,f:(15 if p else 0,15 if (p and d==f) else 0))
run(g,'placement (7): facing is the clicked face; waterlogged when the fluid there is water',"RS2-ROD-PLACE","ii",2,[(d,w) for d in (1,5,6) for w in (0,1)],lambda d,w:(d,w))
AX={1:2,3:2,2:0,4:0,5:1,6:1}
run(g,'struck (7.1): powered true, the neighbours at pos + opposite(facing) updated, a tick 8 later, level event 3002 with the axis ordinal of the facing (X 0, Y 1, Z 2) (powered, support direction, ticks, event, data)',"RS2-ROD-STRIKE","i",5,[(d,) for d in range(1,7)],lambda f:(1,OPP[f],8,3002,AX[f]))
run(g,'release (7.2): the tick writes powered false and updates the support; removal of a powered rod updates it too (powered, support direction, update on removal)',"RS2-ROD-RELEASE","ii",3,[(5,0),(5,1),(1,1)],lambda f,p:(0,OPP[f],p))
run(g,'onPlace (7.2): a powered rod that is not replacing the same block and has no pending tick schedules one in 8 ticks (previous is same, powered, pending: ticks)',"RS2-ROD-PLACE-TICK","iii",1,[(0,1,0),(1,1,0),(0,0,0),(0,1,1)],lambda sm,p,pd:8 if (not sm and p and not pd) else 0)
def search(n,*c):
    best=0;bd=None
    for i in range(n):
        d,t=c[2*i],c[2*i+1]
        if t and d<=128*128 and (bd is None or d<bd): best=i+1; bd=d
    return (best,int(best>0))
sr=[(0,0,0,0,0,0,0,0,0),(1,16384,1,0,0,0,0,0,0),(1,16385,1,0,0,0,0,0,0),(1,100,0,0,0,0,0,0,0),(3,900,1,400,1,900,1,0,0),(3,900,1,900,1,100,0,0,0),(4,50000,1,16000,1,20000,1,15999,1),(2,400,1,400,1,0,0,0,0)]
run(g,'search (7.3): among rods that are the top block of their column and within the sphere (squared distance at most 128 * 128) the closest wins, the first on ties; none means no redirect (n, then squared distance and top-block flag per candidate: index, found)',"RS2-ROD-SEARCH","i"*9,2,sr,search)
run(g,'target (7.3 step 4): the strike goes to the rod position plus one block upward',"RS2-ROD-TARGET","i",1,[(64,),(-60,)],lambda y:y+1)
run(g,'client animateTick (7.5): while thundering, with nextInt(200) <= game time mod 200 and the rod at the surface (thundering, draw, game time mod 200, at surface)',"RS2-ROD-ANIMATE","iiii",1,[(1,5,5,1),(1,6,5,1),(1,0,0,1),(0,0,100,1),(1,0,100,0),(1,199,199,1)],lambda t,d,g_,s:int(t and d<=g_ and s))
run(g,'event 3002 (7.5): a valid axis ordinal spawns 10 to 19 electric_spark particles along the axis; any other data (the -1 of copper cleaning) spawns 3 to 5 on every face (branch 1 axis 2 faces, lowest, highest)',"RS2-ROD-SPARKS","i",3,[(0,),(1,),(2,),(-1,),(3,)],lambda d:(1,10,19) if 0<=d<=2 else (2,3,5))
run(g,'copper cleaning gate (7.6): a weathering copper strike block is reset to its first stage and the walks run; a waxed block (wax-off map entry) is untouched but the walks still run; any other block ends the method (strike block 0 other, 1 weathering, 2 waxed: reset, walks run)',"RS2-ROD-CLEAN","i",2,[(0,),(1,),(2,)],lambda k:(int(k==1),int(k>0)))
run(g,'walks (7.6): 3 + nextInt(3) walks (3 to 5), each of nextInt(8) + 1 steps (1 to 8) (draw nextInt(3), draw nextInt(8): walks, steps)',"RS2-ROD-WALKS","ii",2,[(0,0),(1,3),(2,7)],lambda a,b:(3+a,b+1))
def wstep(*s):
    for i,x in enumerate(s):
        if x: return (i+1,1,3002,-1)
    return (0,0,0,0)
run(g,'a walk step (7.6): of up to 10 sampled positions the first whose block is weathering copper is set one stage less weathered, gets level event 3002 with data -1 and the walk moves there; none ends the walk (index, moved, event, data; ten flags)',"RS2-ROD-WALK-STEP","i"*10,4,[(0,)*10,(1,)+(0,)*9,(0,0,0,1)+(0,)*6,(0,)*9+(1,),(0,1,0,0,1,0,0,0,0,0)],wstep)
W(g,7)
# ===== 8
INST=[('harp','block.note_block.harp',1),('basedrum','block.note_block.basedrum',1),('snare','block.note_block.snare',1),('hat','block.note_block.hat',1),('bass','block.note_block.bass',1),('flute','block.note_block.flute',1),('bell','block.note_block.bell',1),('guitar','block.note_block.guitar',1),('chime','block.note_block.chime',1),('xylophone','block.note_block.xylophone',1),('iron_xylophone','block.note_block.iron_xylophone',1),('cow_bell','block.note_block.cow_bell',1),('didgeridoo','block.note_block.didgeridoo',1),('bit','block.note_block.bit',1),('banjo','block.note_block.banjo',1),('pling','block.note_block.pling',1),('trumpet','block.note_block.trumpet',1),('trumpet_exposed','block.note_block.trumpet_exposed',1),('trumpet_oxidized','block.note_block.trumpet_oxidized',1),('trumpet_weathered','block.note_block.trumpet_weathered',1),('zombie','block.note_block.imitate.zombie',2),('skeleton','block.note_block.imitate.skeleton',2),('creeper','block.note_block.imitate.creeper',2),('dragon','block.note_block.imitate.ender_dragon',2),('wither_skeleton','block.note_block.imitate.wither_skeleton',2),('piglin','block.note_block.imitate.piglin',2),('custom_head','ui.button.click',3)]
g=G5(8,'Note block','T0778','the instrument table and predicates, choosing the instrument, powering, playing, tuning, the block event, the pitch table and the clamp.')
g.case('instruments (8.1, V10): 27 constants in enum order with name and sound; trumpet_oxidized precedes trumpet_weathered; custom_head plays the placeholder ui.button.click',[("0","MOVE SPACES TO WS-T1 WS-T2\nCALL \"RS2-NOTE-NAME\" USING WS-I(1) WS-T1 WS-T2",'TEXT')]*0+[("%d"%n,"MOVE SPACES TO WS-T1 WS-T2\nCALL \"RS2-NOTE-NAME\" USING WS-I(1) WS-T1 WS-T2",'TEXT') for n in range(27)]," ".join(i[0]+"|"+i[1] for i in INST))
run(g,'predicates (8.1): type 1 base block, 2 mob head, 3 custom; isTunable is base block, hasCustomSound is custom, worksAboveNoteBlock is anything but base block (instrument number: type, tunable, custom sound, works above)',"RS2-NOTE-TYPE","i",4,[(n,) for n in range(27)],lambda n:(INST[n][2],int(INST[n][2]==1),int(INST[n][2]==3),int(INST[n][2]!=1)))
run(g,'counts (V10): 20 base block instruments, 6 mob heads, 1 custom (type, count)',"RS2-NOTE-COUNT","i",1,[(1,),(2,),(3,),(0,)],lambda t:{1:20,2:6,3:1,0:27}[t])
def choose(a,b):
    wa=lambda n:INST[n][2]!=1
    if wa(a): return a
    return 0 if wa(b) else b
run(g,'choosing the instrument (8.2): a head above wins; otherwise the block below, but harp when that is a head (worked example 9) (instrument above, instrument below)',"RS2-NOTE-CHOOSE","ii",1,[(0,20),(0,0),(20,6),(4,21),(26,0),(6,26),(4,6),(0,4),(21,4)],choose)
run(g,'shape update (8.2): only a change of a neighbour on the Y axis recomputes the instrument (changed direction)',"RS2-NOTE-SHAPE-UPDATE","i",1,[(d,) for d in range(1,7)],lambda d:int(d>=5))
run(g,'powering (8.3): a changed power signal writes powered; a note plays on the rising edge only, before the write (power now, powered: play, written, new powered)',"RS2-NOTE-NEIGHBOR","ii",3,[(1,0),(0,1),(1,1),(0,0)],lambda n,p:(int(n and not p),int(n!=p),n if n!=p else p))
run(g,'playNote (8.4): a block event 0 / 0 and the game event NOTE_BLOCK_PLAY are queued when the instrument works above a note block or the block above is air; a solid block above mutes it (works above, air above: event, game event)',"RS2-NOTE-PLAY","ii",2,[(0,0),(0,1),(1,0),(1,1)],lambda w,a:(int(w or a),int(w or a)))
run(g,'right click (8.4): note = (note + 1) mod 25, played, statistic tune_noteblock (1); left click: played with statistic play_noteblock (2) and no state change; holding a top instrument item on the up face passes the use on (note: new note, play, statistic)',"RS2-NOTE-TUNE","i",3,[(0,),(5,),(23,),(24,)],lambda n:((n+1)%25,1,1))
run(g,'left click and item use (8.4): attack plays without changing the note (statistic 2); useItemOn passes when the item is in note_block_top_instruments and the face is up (pass, statistic)',"RS2-NOTE-ATTACK","ii",2,[(0,0),(1,0),(1,1),(0,1)],lambda t,u:(int(t and u),2))
PT=[f32(2**((n-12)/12)) for n in range(25)]
run(g,'pitch table (8.5, V9): float(2^((n - 12) / 12)) for the 25 notes (x 1e7): 0.5000000, 0.5297316, ... 1.0000000 at note 12 ... 2.0000000 at note 24',"RS2-NOTE-PITCH","i",1,[(n,) for n in range(25)],lambda n:sc(PT[n],10000000))
run(g,'pitch clamp (8.5): the sound engine clamps the pitch to 0.5 to 2.0, leaving the note pitches alone (pitch x 1e7)',"RS2-PITCH-CLAMP","i",1,[(4000000,),(5000000,),(12345678,),(20000000,),(30000000,)],lambda p:max(5000000,min(20000000,p)))
def nev(inst,note,sk):
    t=INST[inst][2]
    if t==3:
        if not sk: return (0,0,0,0,0,0)
        return (1,2,10000000,0,0,1)
    if t==1: return (1,1,sc(PT[note],10000000),1,sc(note/24.0,10000000),1)
    return (1,1,10000000,0,0,1)
run(g,'block event (8.5): a tunable instrument takes pitch from the note and adds the note particle with x velocity note / 24; a mob head plays at pitch 1.0 with no particle; custom_head needs the skull block entity above to carry a sound, else the event returns false with no sound (instrument, note, skull sound: result, sound kind 1 instrument 2 custom, pitch x 1e7, particle, velocity x 1e7, packet)',"RS2-NOTE-EVENT","iii",6,[(6,5,0),(0,0,0),(4,24,1),(20,3,0),(24,0,1),(26,0,1),(26,7,0),(5,12,1)],nev)
def npos(x,y,z): return (sc(x+0.5,1000000),sc(y+1.2,1000000),sc(z+0.5,1000000),sc(x+0.5,1000000),sc(y+0.5,1000000),sc(z+0.5,1000000))
run(g,'positions (8.5, 8.6): the particle at (X + 0.5, Y + 1.2, Z + 0.5), the sound at (X + 0.5, Y + 0.5, Z + 0.5) with source RECORDS, volume 3.0 and a seeded nextLong (particle x, y, z, sound x, y, z x 1e6)',"RS2-NOTE-POS","iii",6,[(0,64,0),(10,5,-3)],npos)
W(g,8)
# ===== 9
g=G5(9,'Jukebox signal output','T0780','ownSignal while a song plays and the comparator output of the disc.')
run(g,'ownSignal (9): 15 when the block entity exists and its song player is playing, whatever has_record says; after the song ends 0 (block entity, playing)',"RS2-JUKEBOX-SIGNAL","ii",1,[(1,1),(1,0),(0,1),(0,0)],lambda e,p:15 if (e and p) else 0)
run(g,'analog output (9, worked example 11): the comparator reads the comparator_output of the disc song, 0 for an empty slot or a stack without a song, whether or not the song is still playing (has song, comparator output)',"RS2-JUKEBOX-ANALOG","ii",1,[(1,1),(1,13),(1,0),(0,5),(0,0)],lambda s,c:c if s else 0)
run(g,'constants (9): the jukebox is a signal source and has an analog output signal; no neighbour update from the block class when has_record changes (source, analog, update)',"RS2-JUKEBOX-FLAGS","",3,[()],lambda :(1,1,0))
W(g,9)
