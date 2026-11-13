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
