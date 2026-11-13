import sys,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
def S(*a): return " ".join(str(x) for x in a)
class Gen2(Gen):
    def case(self, text, calls, exp):
        text=self.prefix+text
        if len(text)>195: text=text[:195].rsplit(' ',1)[0]
        s='     MOVE "%s" TO TL-CASE\n     PERFORM BEGIN-CASE\n'%text
        for inp,call,n in calls:
            s+='     MOVE "%s" TO WS-IN\n     PERFORM LOAD-IN\n'%inp
            for l in call.split('\n'): s+='     %s\n'%l
            if n is None: pass
            elif n=='TEXT': s+='     PERFORM ADD-TEXT\n'
            else: s+='     MOVE %d TO WS-N\n     PERFORM ADD-N\n'%n
        s+='     MOVE "%s" TO TL-EXPECTED\n     CALL "TEST-ASSERT" USING TESTLIB-ASSERT\n'%exp
        self.out.append(s)
    def run(self, text, inputs, call, n, exp):
        self.case(text,[(i,call,n) for i in inputs],exp)
def GL(n,subj,tasks,desc): return Gen2('TEST-LIGHT-32-%d'%n,'32§%d'%n,subj,'Test of 32 section %d, %s (core/src/light-32*.cob; %s): %s'%(n,subj,tasks,desc),'')
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_light_32_%d.cob'%n)
def M(x): return int(math.floor(x*1000000+0.5))
# ===================== 1
g=GL(1,'Overview and constants','T0679','constants, nibble layout, dimension rules and the brightness queries.')
g.extra=" 01 WS-LAYER             PIC X(2048).\n"
g.run('light section count (1): block sections + 2, minimum light section Y = minimum section Y - 1, maximum = minimum + count (exclusive)',["24 -4","4 0","1 0"],'CALL "L32-LIGHT-SECTIONS" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"26/-5/21 6/-1/5 3/-1/2")
def ni(x,y,z):
    i=(y<<8)|(z<<4)|x; return i,i>>1,int(i%2==0)
nic=[(0,0,0),(1,0,0),(0,0,1),(0,1,0),(15,15,15),(5,3,9)]
g.run('nibble index (1): (y << 8) | (z << 4) | x, byte index >> 1, low nibble for an even index',[S(*c) for c in nic],'CALL "L32-NIBBLE-INDEX" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3," ".join("%d/%d/%d"%ni(*c) for c in nic))
g.case('nibble storage (1): index 0 low nibble and index 1 high nibble of byte 0; set keeps the other nibble; reads give 0 to 15',[
 ("0 5",'MOVE LOW-VALUES TO WS-LAYER\nCALL "L32-NIBBLE-SET" USING WS-LAYER WS-I(1) WS-I(2)\nCALL "L32-NIBBLE-GET" USING WS-LAYER WS-I(1) WS-R(1)\nCOMPUTE WS-R(2) = FUNCTION ORD(WS-LAYER(1:1)) - 1',2),
 ("1 9",'CALL "L32-NIBBLE-SET" USING WS-LAYER WS-I(1) WS-I(2)\nCALL "L32-NIBBLE-GET" USING WS-LAYER WS-I(1) WS-R(1)\nCOMPUTE WS-R(2) = FUNCTION ORD(WS-LAYER(1:1)) - 1',2),
 ("0 15",'CALL "L32-NIBBLE-SET" USING WS-LAYER WS-I(1) WS-I(2)\nCALL "L32-NIBBLE-GET" USING WS-LAYER WS-I(1) WS-R(1)\nCOMPUTE WS-R(2) = FUNCTION ORD(WS-LAYER(1:1)) - 1',2),
 ("4095 7",'CALL "L32-NIBBLE-SET" USING WS-LAYER WS-I(1) WS-I(2)\nCALL "L32-NIBBLE-GET" USING WS-LAYER WS-I(1) WS-R(1)\nCOMPUTE WS-R(2) = FUNCTION ORD(WS-LAYER(2048:1)) - 1',2),
 ("4094 0",'CALL "L32-NIBBLE-GET" USING WS-LAYER WS-I(1) WS-R(1)\nMOVE 0 TO WS-R(2)',2)],"5/5 9/149 15/159 7/112 0/0")
g.run('constants (1): MAX_LEVEL 15, MIN_OPACITY 1, light section padding 1, array 2048 bytes of 4096 nibbles',["1","2","3","4","5"],'CALL "L32-CONSTANT" USING WS-I(1) WS-R(1)',1,"15 1 1 2048 4096")
dirs=[(0,-1,0),(0,1,0),(0,0,-1),(0,0,1),(-1,0,0),(1,0,0)]
g.run('directions (1): DOWN, UP, NORTH, SOUTH, WEST, EAST are ordinals 0 to 5 in that propagation order; the opposite flips the low bit',[str(i) for i in range(6)],'CALL "L32-DIRECTION" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join("%d/%d/%d/%d"%(d[0],d[1],d[2],i^1) for i,d in enumerate(dirs)))
dims=[(1,1,0,0,0,1,7),(2,1,1,0,0,1,7),(3,0,1,10,15,2,7),(4,1,0,25,0,2,15)]
g.run('dimension rules (1.1): has_skylight, has_ceiling, ambient_light x 100, monster_spawn_block_light_limit, spawn light kind (1 uniform 0..n, 2 constant) and value, for overworld, overworld_caves, the_nether, the_end',[str(d[0]) for d in dims],'CALL "L32-DIM-RULES" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6," ".join("/".join(map(str,d[1:])) for d in dims))
wc=[(1,0,0),(1,1,0),(0,0,0),(1,0,1),(0,1,0)]
g.run('canHaveWeather (1.1): has_skylight and not has_ceiling and the dimension key is not the End',[S(*c) for c in wc],'CALL "L32-CAN-HAVE-WEATHER" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1," ".join(str(int(a and not b and not c)) for a,b,c in wc))
wl=[(1,0.95,0.3),(1,0.9,0.2),(1,0.91,0.21),(0,0.99,0.99),(1,0.0,1.0)]
g.run('isThundering is canHaveWeather and thunder level > 0.9; isRaining is canHaveWeather and rain level > 0.2',[S(*c) for c in wl],'CALL "L32-WEATHER-STATE" USING WS-I(1) WS-FX(2) WS-FX(3) WS-R(1) WS-R(2)',2," ".join("%d/%d"%(int(c and t>0.9),int(c and r>0.2)) for c,t,r in wl))
rb=[(5,12,3,1),(5,12,10,1),(5,12,12,1),(14,12,0,1),(5,12,3,0),(0,0,3,1),(0,15,15,1)]
g.run('raw brightness (1): max(block, sky - darken); a missing sky engine contributes 0, not -darken',[S(*c) for c in rb],'CALL "L32-RAW-BRIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(max(b,(s-d) if k else 0)) for b,s,d,k in rb))
ml=[(0,0,9,3,0),(-30000001,0,9,3,0),(0,-30000001,9,3,0),(30000000,0,9,3,0),(0,30000000,9,3,0),(-30000000,29999999,9,3,0),(29999999,-30000000,9,3,2)]
def mlx(x,z,b,s,d): return 15 if (x<-30000000 or z<-30000000 or x>=30000000 or z>=30000000) else max(b,s-d)
g.run('getMaxLocalRawBrightness (1.2): 15 when x or z is outside +-30 000 000 (x < -30 000 000, x >= 30 000 000, same for z), else the raw brightness',[S(*c[:4],c[4]) for c in ml],'MOVE 1 TO WS-I(6)\nCALL "L32-MAX-LOCAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1," ".join(str(mlx(*c)) for c in ml))
g.run('effective sky brightness (1.2) is max(0, sky - skyDarken); canSeeSky is sky >= 15',["15 4","3 4","0 0","14 0"],'CALL "L32-EFFECTIVE-SKY" USING WS-I(1) WS-I(2) WS-R(1)\nCALL "L32-CAN-SEE-SKY" USING WS-I(1) WS-R(2)',2,"11/1 0/0 0/0 14/0")
def curve(l,a):
    r=l/15; f=r/(4-3*r); return f+a*(1-f)
mc=[(0,0.0),(15,0.0),(7,0.0),(7,0.1),(15,0.25),(0,0.25),(10,0.1)]
g.run('light-level dependent magic value (1.2) and Lightmap.getBrightness (1.1): r = L / 15, f = r / (4 - 3r), f + ambient (1 - f); the pathfinding cost is that value - 0.5 (x 1 000 000)',[S(a,b) for a,b in mc],'CALL "L32-BRIGHTNESS-CURVE" USING WS-I(1) WS-FX(2) WS-RF(1)\nCALL "L32-PATH-COST" USING WS-I(1) WS-FX(2) WS-RF(2)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000000',2," ".join("%d/%d"%(M(curve(l,a)),M(curve(l,a)-0.5)) for l,a in mc))
def dlx(s,inv,deg):
    if inv: v=15-s
    elif s>0:
        a=deg*0.017453292
        tgt=0.0 if a<math.pi else 2*math.pi
        a=a+(tgt-a)*0.2
        v=int(math.floor(s*math.cos(a)+0.5))
    else: v=0
    return max(0,min(15,v))
dc=[(15,1,0),(0,1,0),(15,0,0),(15,0,90),(12,0,200),(0,0,45),(15,0,180),(8,0,10)]
g.run('daylight detector power (1.2): inverted gives 15 - s; else for s > 0 round(s cos(a)) with a (degrees to radians, 0.017453292) moved 20 percent of the way to 0 when a < pi else to 2 pi; clamp 0..15',[S(*c) for c in dc],'CALL "L32-DAYLIGHT" USING WS-I(1) WS-I(2) WS-FX(3) WS-R(1)',1," ".join(str(dlx(*c)) for c in dc))
def mon(sky,d32,lim,blk,thund,m10,mdef,smp):
    if sky>d32: return 0
    if lim<15 and blk>lim: return 0
    m=m10 if thund else mdef
    return int(m<=smp)
mo=[(0,0,0,0,0,5,5,7),(3,2,0,0,0,5,5,7),(2,2,0,1,0,5,5,7),(0,0,15,15,0,5,5,7),(0,0,0,0,1,9,5,7),(0,0,0,0,1,8,2,7),(0,0,0,0,0,9,8,7),(0,0,0,0,0,9,7,7),(1,5,0,0,1,12,3,7)]
g.run('Monster.isDarkEnoughToSpawn (1.2): reject when sky > nextInt(32); reject when the block limit is below 15 and block > limit; then raw brightness (darken 10 when thundering) must be <= the sample',[S(*c) for c in mo],'CALL "L32-MONSTER-DARK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1)',1," ".join(str(mon(*c)) for c in mo))
def gates(a,b,c,d,e,f): return "%d/%d/%d/%d/%d"%(int(a<=b),int(a<=c),int(d>8),int(d>=9 and e<f),int(d>=8))
gc=[(2,2,3,9,0,8),(3,2,3,9,7,7),(0,0,0,10,3,7),(1,0,1,8,3,8),(4,5,3,9,8,7),(0,0,0,0,0,0)]
g.run('spawn and growth light gates (1.2): bat rejects when brightness > nextInt(4); slime when > nextInt(8); animal needs raw > 8; crop growth needs raw >= 9 and age below maximum; crop survival raw >= 8',[S(*c) for c in gc],'CALL "L32-LIGHT-GATES" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5," ".join(gates(*c) for c in gc))

def ssb(y,sea,pos_sees,sea_sees,cells):
    if y>=sea: return int(pos_sees)
    if not sea_sees: return 0
    for (d,l) in cells:
        if not (d==0 or l): return 0
    return 1
sb=[(70,64,1,1,[]),(70,64,0,1,[]),(64,64,0,1,[]),(60,64,0,1,[(0,0),(0,0),(0,0)]),(60,64,0,0,[(0,0),(0,0),(0,0)]),(60,64,0,1,[(1,1),(0,0),(0,0)]),(60,64,0,1,[(1,0),(0,0),(0,0)]),(62,64,0,1,[(15,0)]),(62,64,0,1,[(0,0),(2,0)]),(63,64,0,1,[])]
def sbcall(c):
    y,sea,ps,ss,cells=c
    # cells hold the cells from sea - 1 down to y + 1 (count sea - 1 - y)
    n=max(0,sea-1-y); cells=(cells+[(0,0)]*6)[:6]
    s=S(y,sea,ps,ss,*[v for p in cells for v in p])
    return s
def sbexp(c):
    y,sea,ps,ss,cells=c
    n=max(0,sea-1-y)
    return ssb(y,sea,ps,ss,cells[:n])
g.run('canSeeSkyFromBelowWater (1.2): at or above the sea level canSeeSky(pos); below it the sea-level cell must see the sky, then every cell from sea level - 1 down to pos.y + 1 needs dampening 0 or a liquid',[sbcall(c) for c in sb],'CALL "L32-SKY-BELOW-WATER" USING WS-IST WS-R(1)',1," ".join(str(sbexp(c)) for c in sb))

def mr(kind,reason,dark,sees,mob):
    ign=int(reason==2); sp=int(reason in (1,2))
    chk=int((ign or dark) and mob)
    if kind==1: return chk
    if kind==2: return int(chk and (sp or sees))
    return mob
mrc=[(k,r,d,s,m) for k in (1,2,3) for (r,d,s,m) in [(3,1,1,1),(3,0,1,1),(2,0,0,1),(1,0,0,1),(3,1,0,1),(3,1,1,0),(1,1,0,1)]]
g.run('Monster spawn rules (1.2): check = (reason ignores light [TRIAL_SPAWNER only] or dark) and mob rules; surface adds (reason is a spawner [SPAWNER, TRIAL_SPAWNER] or canSeeSky); any-light is the mob rules only',[S(*c) for c in mrc],'CALL "L32-MONSTER-RULES" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(mr(*c)) for c in mrc))
W(g,1)
# ===================== 2
g=GL(2,'Inputs read from block states','T0681','opacity, empty shape, differing light properties, occlusion between two cells and the unloaded cell.')
STATES={0:(0,0,0,0,[0]*6),1:(0,15,1,0,[15]*6),2:(0,15,1,0,[15]*6),3:(0,1,1,0,[15]*6),4:(14,0,0,0,[0]*6),5:(0,0,1,1,[15,0,3,3,3,3]),6:(0,0,0,1,[15]*6),7:(0,1,0,0,[0]*6),8:(5,0,1,1,[15,0,3,3,3,3]),9:(0,0,1,1,[0,15,12,12,12,12])}
def define(i):
    e,d,o,u,f=STATES[i]
    return S(i,e,d,o,u,*f)
DEF='CALL "L32-DEFINE-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-I(10) WS-I(11)'
setup=[("1",'CALL "L32-INIT" USING WS-I(1)',None)]+[(define(i),DEF,None) for i in range(2,10)]
def opacity(i): return max(1,STATES[i][1])
def empty(i): return int(STATES[i][2]==0 or STATES[i][3]==0)
g.case('getOpacity is max(1, dampening): air 1, water-like 1, leaves 1, stone 15; the preset states 0 (air) and 1 (bedrock, the unloaded cell) are defined by the engine',setup[:1]+[(define(i),DEF+'\nCALL "L32-OPACITY" USING WS-I(1) WS-R(1)',1) for i in (2,3,7,4)]+[("0",'CALL "L32-OPACITY" USING WS-I(1) WS-R(1)',1),("1",'CALL "L32-OPACITY" USING WS-I(1) WS-R(1)',1)],"%d %d %d %d %d %d"%(opacity(2),opacity(3),opacity(7),opacity(4),1,15))
g.case('isEmptyShape is true when canOcclude is false or useShapeForLightOcclusion is false (every ordinary full block); false only for an occluding state that uses its shape',setup+[(str(i),'CALL "L32-IS-EMPTY-SHAPE" USING WS-I(1) WS-R(1)',1) for i in (0,2,5,6,7,8)]," ".join(str(empty(i)) for i in (0,2,5,6,7,8)))
def diff(a,b):
    if a==b: return 0
    A,B=STATES[a],STATES[b]
    return int(A[1]!=B[1] or A[0]!=B[0] or A[3]==1 or B[3]==1)
dp=[(2,2),(2,3),(2,4),(2,5),(5,2),(5,5),(2,6),(0,0),(3,7),(0,7),(2,0)]
g.case('hasDifferentLightProperties: false for the same state; true when the dampening or the emission differs or either uses its shape for occlusion; else false (two stones of different ids with equal properties: false)',setup+[(S(a,b),'CALL "L32-DIFF-PROPS" USING WS-I(1) WS-I(2) WS-R(1)',1) for a,b in dp]," ".join(str(diff(a,b)) for a,b in dp))
def fo(a,b): return 0 if a==0 and b==0 else int((a|b)==15)
fm=[(0,0),(15,0),(0,15),(3,12),(3,3),(5,10),(5,9),(1,2),(7,8),(7,7),(0,14)]
g.run('Shapes.faceShapeOccludes: two empty faces never block; otherwise light is blocked when the faces together cover the whole face (faces are quadrant masks 0 to 15)',[S(*c) for c in fm],'CALL "L32-FACE-OCCLUDES" USING WS-I(1) WS-I(2) WS-R(1)',1," ".join(str(fo(*c)) for c in fm))
def face(i,d):
    return 0 if empty(i) else STATES[i][4][d]
def occ(s,n,d): return fo(face(s,d),face(n,d^1))
oc=[(2,2,0),(2,2,1),(5,5,1),(5,5,0),(5,5,2),(5,5,4),(5,2,0),(5,2,1),(2,5,1),(2,5,0),(9,5,2),(9,5,3),(9,9,1),(9,9,0),(6,6,0),(0,5,0),(8,2,0)]
g.case('shapeOccludes (2.1): the face of S in direction d and the face of N toward S, each empty when isEmptyShape (a full block uses opacity only); blocked when the faces cover the face; bottom slab against bottom slab across UP, DOWN and a side',setup+[(S(*c),'CALL "L32-OCCLUDES" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1) for c in oc]," ".join(str(occ(*c)) for c in oc))
def dinto(f,t,d,df):
    if empty(f) and empty(t): return df
    return 16 if occ(f,t,d) else df
di=[(2,2,0,7),(5,5,1,7),(5,5,0,3),(5,2,1,4),(5,9,0,0),(9,5,1,1),(8,8,2,5)]
g.case('getLightDampeningInto (2.1, informational helper): the default when both occlusion shapes are empty; 16 when the facing shapes occlude; else the default',setup+[(S(*c),'CALL "L32-DAMPING-INTO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1) for c in di]," ".join(str(dinto(*c)) for c in di))
def SA(i): return (i,'CALL "L32-STATE-AT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1)
g.case('state of an unloaded cell (2.2): bedrock (opaque) for a chunk that is not available or outside the window; air above or below the block sections of an available chunk; the stored state otherwise',[setup[0],
 SA("0 0 0"),
 ("0 0 1",'CALL "L32-AVAIL-CHUNK" USING WS-I(1) WS-I(2) WS-I(3)',None),
 SA("0 0 0"),
 ("1 2 3 2",'CALL "L32-SET-CELL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4)\nCALL "L32-STATE-AT" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1),
 SA("1 70 3"),SA("1 -3 3"),SA("17 5 3"),SA("100 5 3"),SA("-1 5 3")],"1 0 2 0 0 1 1 1")
W(g,2)
# ===================== 3
g=GL(3,'Queue entries','T0683','the packed entry: level, direction bits, flags and its six constructors.')
def bit(d): return 1<<(4+d)
ALL=1008
def entry(kind,l,e,d):
    if kind==1: return l|ALL
    if kind==2: return l|(ALL&~bit(d))
    if kind==3: return l|ALL|2048|(1024 if e else 0)
    if kind==4: return l|(ALL&~bit(d))|(1024 if e else 0)
    return l|bit(d)|(1024 if e else 0)
ec=[(1,5,0,0),(1,15,0,0),(2,7,0,1),(2,14,1,5),(3,14,0,0),(3,9,1,0),(4,13,0,1),(4,13,1,2),(4,1,1,5),(5,3,0,0),(5,15,1,3),(5,0,0,4)]
g.run('constructors (3): decreaseAllDirections, decreaseSkipOneDirection, increaseLightFromEmission, increaseSkipOneDirection, increaseOnlyOneDirection; level in bits 0-3, one bit per direction at 4 + ordinal, 1024 from-empty-shape, 2048 increase-from-emission',[S(*c) for c in ec],'CALL "L32-ENTRY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1," ".join(str(entry(*c)) for c in ec))
def sky(dn,n,s,w,e): return 15|sum(bit(i) for i,f in ((0,dn),(2,n),(3,s),(4,w),(5,e)) if f)
sc=[(1,1,1,1,1),(0,0,0,0,0),(1,0,0,0,0),(0,1,0,0,0),(0,0,1,0,0),(0,0,0,1,0),(0,0,0,0,1),(1,0,1,0,1)]
g.run('increaseSkySourceInDirections (3): level 15 and the true ones of DOWN, NORTH, SOUTH, WEST, EAST; UP never',[S(*c) for c in sc],'CALL "L32-ENTRY-SKY" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1)',1," ".join(str(sky(*c)) for c in sc))
dc=[entry(*c) for c in ec]+[sky(*c) for c in sc]
def dec(e): return "%d/%d/%d/%d"%(e&15,(e>>4)&63,(e>>10)&1,(e>>11)&1)
g.run('entry fields (3): from level 0-15, direction bits (mask 1008 >> 4), from-empty-shape flag, increase-from-emission flag',[str(e) for e in dc],'CALL "L32-ENTRY-DECODE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4," ".join(dec(e) for e in dc))
g.run('constants (3): PULL_LIGHT_IN_ENTRY is decreaseAllDirections(1); REMOVE_TOP_SKY_SOURCE_ENTRY decreaseAllDirections(15); REMOVE_SKY_SOURCE_ENTRY decreaseSkipOneDirection(15, UP); ADD_SKY_SOURCE_ENTRY increaseSkipOneDirection(15, false, UP)',["1","2","3","4"],'CALL "L32-ENTRY-CONST" USING WS-I(1) WS-R(1)',1,"%d %d %d %d"%(entry(1,1,0,0),entry(1,15,0,0),entry(2,15,0,1),entry(4,15,0,1)))
W(g,3)
# ===================== 6 (model of the section storage, 6.1 to 6.8)
INF=2147483647
class Store:
    """Independent model of LayerLightSectionStorage (+ sky variant) over the window: sections (sx, sy, sz) with sx, sz -1..2 and sy -1..4."""
    def __init__(s,sky):
        s.sky=sky; s.state={}; s.work={}; s.vis={}; s.queue={}; s.pending=set(); s.changed=set(); s.aff=set(); s.incons=False
        s.retain=set(); s.on=set(); s.lowest=INF; s.top={}; s.vlowest=INF; s.vtop={}; s.notify={}; s.queued_same=set()
    @staticmethod
    def ok(p): return -1<=p[0]<=2 and -1<=p[2]<=2 and -1<=p[1]<=4
    def stores(s,p): return p in s.work
    def nbrs(s,p):
        for dx in (-1,0,1):
            for dy in (-1,0,1):
                for dz in (-1,0,1):
                    if (dx,dy,dz)!=(0,0,0):
                        q=(p[0]+dx,p[1]+dy,p[2]+dz)
                        if s.ok(q): yield q
    def create(s,p):
        if p in s.queue: s.queued_same.add(p); return list(s.queue[p])
        if not s.sky: return [0]*4096
        col=(p[0],p[2]); has=col in s.top
        if not has or p[1]>=s.top[col]:
            return [15]*4096 if col in s.on else [0]*4096
        for y in range(p[1]+1,5):
            q=(p[0],y,p[2])
            if q in s.work:
                row=s.work[q][:256]; return row*16
        return [0]*4096
    def node_added(s,p):
        if not s.sky: return
        if p[1]<s.lowest: s.lowest=p[1]
        col=(p[0],p[2])
        if col not in s.top or s.top[col]<p[1]+1: s.top[col]=p[1]+1
    def node_removed(s,p):
        if not s.sky: return
        col=(p[0],p[2])
        if col in s.top and s.top[col]==p[1]+1:
            y=p[1]
            while not ((p[0],y,p[2]) in s.work) and y>=s.lowest: y-=1
            if (p[0],y,p[2]) in s.work: s.top[col]=y+1
            else: del s.top[col]
    def init(s,p):
        if p in s.pending: s.pending.discard(p); return
        s.work[p]=s.create(p); s.changed.add(p); s.node_added(p)
        s.aff.add(p)
        for q in s.nbrs(p): s.aff.add(q)
        s.incons=True
    def setbyte(s,p,v):
        old=s.state.get(p,0)
        if v==old: return
        if v==0: s.state.pop(p,None)
        else: s.state[p]=v
        if old==0: s.init(p)
        elif v==0: s.pending.add(p); s.incons=True
    def status(s,p,empty):
        old=s.state.get(p,0)
        new=(old&31)|(0 if empty else 32)
        if new==old: return
        s.setbyte(p,new)
        d=-1 if empty else 1
        for q in s.nbrs(p):
            o=s.state.get(q,0); s.setbyte(q,(o&32)|((o&31)+d))
    def queue_data(s,p,fill):
        if fill<0: s.queue.pop(p,None); s.queued_same.discard(p)
        else: s.queue[p]=[fill]*4096; s.queued_same.discard(p); s.incons=True
    def finish(s):
        if s.incons:
            s.incons=False
            held={}
            for p in sorted(s.pending):
                q=s.queue.pop(p,None); r=s.work.pop(p,None)
                col=(p[0],p[2])
                if col in s.retain:
                    if q is not None and p not in s.queued_same: held[p]=q
                    elif p in s.queued_same: held[p]=r
                    elif r is not None: held[p]=r
                s.queued_same.discard(p)
            for p,v in held.items(): s.queue[p]=v
            for p in sorted(s.pending):
                s.node_removed(p); s.changed.add(p)
            s.pending=set()
            for p in sorted(list(s.queue)):
                if p in s.work:
                    if p not in s.queued_same: s.work[p]=list(s.queue[p]); s.changed.add(p)
                    del s.queue[p]; s.queued_same.discard(p)
        if s.changed:
            s.vis={p:list(v) for p,v in s.work.items()}; s.vtop=dict(s.top); s.vlowest=s.lowest; s.changed=set()
        for p in sorted(s.aff): s.notify[p]=s.notify.get(p,0)+1
        s.aff=set()
    def setlevel(s,x,y,z,v):
        p=(x>>4,y>>4,z>>4); s.work[p][(y&15)*256+(z&15)*16+(x&15)]=v; s.changed.add(p)
        for dx in (-1,0,1):
            for dy in (-1,0,1):
                for dz in (-1,0,1):
                    q=((x+dx)>>4,(y+dy)>>4,(z+dz)>>4)
                    if s.ok(q): s.aff.add(q)
    def pub(s,x,y,z):
        p=(x>>4,y>>4,z>>4); idx=(y&15)*256+(z&15)*16+(x&15)
        if not s.sky: return s.vis[p][idx] if p in s.vis else 0
        col=(p[0],p[2])
        if col not in s.vtop or p[1]>=s.vtop[col]: return 15
        sy=p[1]
        while True:
            q=(p[0],sy,p[2])
            if q in s.vis: return s.vis[q][idx if sy==p[1] else (z&15)*16+(x&15)]
            sy+=1
            if sy>=s.vtop[col]: return 15
    def wlevel(s,x,y,z):
        p=(x>>4,y>>4,z>>4); idx=(y&15)*256+(z&15)*16+(x&15); col=(p[0],p[2])
        if not s.sky: return s.work[p][idx] if p in s.work else 0
        if col not in s.top or p[1]>=s.top[col]: return 15 if col in s.on else 0
        sy=p[1]
        while True:
            q=(p[0],sy,p[2])
            if q in s.work: return s.work[q][idx if sy==p[1] else (z&15)*16+(x&15)]
            sy+=1
            if sy>=s.top[col]: return 15 if col in s.on else 0
    def info(s,p):
        return (s.state.get(p,0),int(p in s.work),int(p in s.vis),int(p in s.queue),int(p in s.pending),s.notify.get(p,0))
def colidx(p): return (p[2]+1)*4+p[0]+2
class Scn:
    def __init__(self,k,sky=1):
        self.k=k; self.m=Store(k==2); self.calls=[]; self.exp=[]
        self.calls.append(("%d"%sky,'CALL "L32-INIT" USING WS-I(1)',None))
    def op(self,inp,call,n=None): self.calls.append((inp,call,n))
    def status(self,sx,sy,sz,empty):
        self.m.status((sx,sy,sz),empty); self.op(S(self.k,sx,sy,sz,empty),'CALL "L32-STORAGE-STATUS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def queue(self,sx,sy,sz,fill):
        self.m.queue_data((sx,sy,sz),fill); self.op(S(self.k,sx,sy,sz,fill),'CALL "L32-QUEUE-DATA" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def finish(self):
        self.m.finish(); self.op(S(self.k),'CALL "L32-STORAGE-FINISH" USING WS-I(1)')
    def retain(self,cx,cz,f):
        col=(cx,cz)
        (self.m.retain.add if f else self.m.retain.discard)(col); self.op(S(self.k,colidx((cx,0,cz)),f),'CALL "L32-STORAGE-RETAIN" USING WS-I(1) WS-I(2) WS-I(3)')
    def enable(self,cx,cz,f):
        col=(cx,cz)
        (self.m.on.add if f else self.m.on.discard)(col); self.op(S(self.k,colidx((cx,0,cz)),f),'CALL "L32-STORAGE-ENABLE" USING WS-I(1) WS-I(2) WS-I(3)')
    def setl(self,x,y,z,v):
        self.m.setlevel(x,y,z,v); self.op(S(self.k,x,y,z,v),'CALL "L32-SET-STORED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def obs(self,sx,sy,sz):
        self.exp.append("/".join(map(str,self.m.info((sx,sy,sz))))); self.op(S(self.k,sx,sy,sz),'CALL "L32-SECTION-INFO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6)
    def pub(self,x,y,z):
        self.exp.append(str(self.m.pub(x,y,z))); self.op(S(self.k,x,y,z),'CALL "L32-GET-PUBLISHED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
    def wl(self,x,y,z):
        self.exp.append(str(self.m.wlevel(x,y,z))); self.op(S(self.k,x,y,z),'CALL "L32-GET-WORKING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
    def below(self,y):
        self.exp.append(str(int(y>=self.m.lowest))); self.op(S(y),'CALL "L32-DATA-AT-OR-BELOW" USING WS-I(1) WS-R(1)',1)
    def above(self,cx,cz,sy):
        col=(cx,cz); self.exp.append(str(int(col not in self.m.top or sy>=self.m.top[col]))); self.op(S(colidx((cx,0,cz)),sy),'CALL "L32-IS-ABOVE-DATA" USING WS-I(1) WS-I(2) WS-R(1)',1)
    def top(self,cx,cz):
        col=(cx,cz); self.exp.append(str(self.m.top.get(col,self.m.lowest))); self.op(S(self.k,colidx((cx,0,cz))),'CALL "L32-TOP-SECTION" USING WS-I(1) WS-I(2) WS-R(1)',1)
    def lowest(self):
        self.exp.append(str(self.m.lowest)); self.op(S(self.k),'CALL "L32-BOTTOM-SECTION" USING WS-I(1) WS-R(1)',1)
    def run(self,g,text): g.case(text,self.calls," ".join(self.exp))
g=GL(6,'Section storage','T0689','section states and neighbour counts, layer creation, pending data, double buffering and notification, column flags, reading a level, the sky predicates.')
s=Scn(1)
s.status(0,1,0,0)
for p in [(0,1,0),(0,0,0),(1,2,1),(-1,0,-1),(0,3,0),(2,2,2)]: s.obs(*p)
s.finish()
for p in [(0,1,0),(0,0,0),(1,2,1),(0,3,0)]: s.obs(*p)
s.run(g,'updateSectionStatus (6.2): the section gets bit 5 and its 26 neighbours a count of 1, each stores a layer from initialise; after the run the layers are published; a section outside the 27 does not store light')
s=Scn(1)
s.status(0,1,0,0); s.finish(); s.status(0,1,0,1)
for p in [(0,1,0),(0,0,0),(1,2,1)]: s.obs(*p)
s.finish()
for p in [(0,1,0),(0,0,0),(1,2,1)]: s.obs(*p)
s.status(0,1,0,1); s.status(0,1,0,0); s.status(0,1,0,0)
s.obs(0,1,0)
s.run(g,'remove (6.2, 6.3): a section whose byte went to 0 keeps its layer (stores light) until the pending removal is processed at the end of the next run; an unchanged state byte does nothing; the same section again before the run is taken out of the pending set')
s=Scn(1)
s.queue(1,1,0,7); s.obs(1,1,0); s.finish(); s.obs(1,1,0)
s.status(1,1,0,0); s.obs(1,1,0); s.finish(); s.obs(1,1,0); s.pub(17,17,2); s.pub(17,17,3)
s.queue(2,2,2,5); s.finish(); s.obs(2,2,2); s.queue(2,2,2,-1); s.obs(2,2,2)
s.run(g,'queued data (6.3, 6.6): a queued layer for a section that does not store light stays queued through a run; initialise takes the queued layer as the new layer and the run removes it from the queue; a null layer removes the queued entry')
s=Scn(1)
s.retain(0,0,1); s.status(0,1,0,0); s.finish(); s.queue(0,1,0,9); s.finish(); s.pub(1,17,2)
s.setl(1,17,2,3); s.finish(); s.pub(1,17,2); s.status(0,1,0,1); s.finish(); s.obs(0,1,0); s.status(0,1,0,0); s.finish(); s.obs(0,1,0); s.pub(1,17,2)
s.status(0,1,0,1); s.queue(0,1,0,6); s.finish(); s.obs(0,1,0)
s.queue(0,1,0,4); s.status(0,1,0,0); s.status(0,1,0,1); s.finish(); s.obs(0,1,0)
s.run(g,'retain data (6.3 step 1, 6.5): while the column is retained the removed layer (or a queued one) goes back into the queue, so initialising the section again gets its old levels; a queued layer for a storing section is installed by the run')
s=Scn(1)
s.status(0,1,0,0); s.finish()
s.setl(5,21,5,3); s.wl(5,21,5); s.pub(5,21,5); s.wl(100,21,5); s.setl(15,21,5,4); s.setl(15,31,5,5); s.setl(15,31,15,6); s.finish()
for p in [(0,1,0),(1,1,0),(0,2,0),(1,2,0),(0,1,1),(1,1,1),(0,2,1),(1,2,1),(-1,1,0)]: s.obs(*p)
s.pub(5,21,5); s.pub(15,31,15)
s.run(g,'notification (6.4): initialise marks the 27 sections around the new one; a written level marks its own section and the ones its faces, edges and corner touch (1, 2, 3 and 7 sections); the published map shows a write only after the run; each marked section is notified once per run')
# sky storage
s=Scn(2)
s.enable(0,0,1); s.status(0,1,0,0)
for p in [(0,1,0),(0,0,0),(0,2,0),(1,1,0),(-1,1,-1)]: s.obs(*p)
s.top(0,0); s.top(1,0); s.lowest()
s.finish()
s.wl(1,17,2); s.wl(1,200,2); s.wl(33,17,2); s.below(0); s.below(-1); s.below(5); s.above(0,0,2); s.above(0,0,3); s.above(1,1,0); s.above(2,2,0)
s.pub(1,17,2); s.pub(1,1,2); s.pub(1,200,2); s.pub(33,17,2); s.pub(-1,17,-1)
s.run(g,'sky storage (6.6, 6.7, 6.8): a section at or above the column top, or without an entry, is created all 15 when the column has light enabled; a section below it takes the first row of the first section above; the top table is highest storing section + 1, the lowest section the lowest ever initialised')
s=Scn(2)
s.enable(0,0,1); s.status(0,2,0,0); s.finish(); s.setl(3,16,4,5); s.finish(); s.pub(3,2,4); s.pub(4,2,4); s.wl(3,2,4); s.status(0,1,0,0); s.finish()
s.obs(0,0,0); s.pub(3,2,4); s.pub(3,9,4); s.pub(4,9,4); s.pub(3,2,5); s.top(0,0); s.lowest()
s.setl(3,16,4,8); s.pub(3,16,4); s.finish(); s.pub(3,16,4)
s.run(g,'sky layer below the top (6.6): the new layer repeats the first Y row (256 nibbles) of the first layer above 16 times, so every Y row equals it; a write is read back only once published')
s=Scn(2)
s.enable(0,0,1); s.status(0,1,0,0); s.status(0,2,0,0); s.finish(); s.top(0,0); s.lowest()
s.status(0,2,0,1); s.status(0,1,0,1); s.finish()
s.top(0,0); s.top(1,1); s.lowest(); s.pub(1,17,2); s.pub(1,50,2); s.obs(0,1,0); s.obs(0,0,0)
s.run(g,'sky storage removal (6.3 step 2, 6.8): removing the highest storing section rewrites the column top by walking down while the section stores no light and hasLightDataAtOrBelow holds, else drops the entry; the lowest section is never raised')
s=Scn(2)
s.status(2,1,2,0); s.wl(33,17,34); s.wl(33,45,34); s.finish(); s.pub(33,17,34); s.pub(33,40,34); s.obs(2,1,2); s.enable(2,2,1); s.status(2,3,2,0); s.finish(); s.pub(33,56,34); s.top(2,2); s.obs(2,3,2)
s.run(g,'sky layer of a column without light enabled (6.6): all zero below the top and above it; with the column enabled a new top section is all 15; a read at or above the top is 15')

import itertools
def lo(bp,sp,bon,son):
    if not bp: return 1
    if not bon: return 0
    return int((not sp) or son)
cl=[("1",'CALL "L32-INIT" USING WS-I(1)',None)]; ce=[]
for bp,sp,bon,son in itertools.product((0,1),repeat=4):
    cl.append((S(1,1,bon),'CALL "L32-STORAGE-ENABLE" USING WS-I(1) WS-I(2) WS-I(3)',None))
    cl.append((S(2,1,son),'CALL "L32-STORAGE-ENABLE" USING WS-I(1) WS-I(2) WS-I(3)',None))
    cl.append((S(bp,sp,1),'CALL "L32-LIGHT-ON-IN-COLUMN" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1)); ce.append(str(lo(bp,sp,bon,son)))
g.case('lightOnInColumn (6.5): no block engine gives true; with a block engine and its column not enabled false (even without a sky engine); otherwise true when the sky engine is absent or has the column enabled',cl," ".join(ce))
W(g,6)
