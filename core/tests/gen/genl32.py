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
    def write(self, path):
        Gen.write(self,path)
        t=open(path).read().replace('PIC -(9)9','PIC -(10)9')
        open(path,'w').write(t)
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
    def queue_layer(s,p,arr):
        s.queue[p]=list(arr); s.queued_same.discard(p); s.incons=True
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

# ===================== engine model (sections 4 and 5)
DIRS=[(0,-1,0),(0,1,0),(0,0,-1),(0,0,1),(-1,0,0),(1,0,0)]
def E_dec_all(l): return l|1008
def E_dec_skip(l,d): return l|(1008&~(16<<d))
def E_inc_em(l,e): return l|1008|2048|(1024 if e else 0)
def E_inc_skip(l,e,d): return l|(1008&~(16<<d))|(1024 if e else 0)
def E_inc_one(l,e,d): return l|(16<<d)|(1024 if e else 0)
def E_sky(dn,n,so,w,e): return 15|sum(16<<i for i,f in ((0,dn),(2,n),(3,so),(4,w),(5,e)) if f)
PULL=E_dec_all(1); ADD_SKY=E_inc_skip(15,0,1); REM_SKY=E_dec_skip(15,1); REM_TOP=E_dec_all(15)
MINV=-2147483648
class Eng:
    def __init__(s,sky=0):
        s.skyon=sky; s.states={0:(0,0,0,0,(0,)*6),1:(0,15,1,0,(15,)*6)}
        s.blocks={}; s.avail=set(); s.lay=[Store(False),Store(True)]
        s.q=[{'ck':[],'inc':[],'dec':[]} for _ in range(2)]
        s.ls={}
    def define(s,i,e,d,o,u,f): s.states[i]=(e,d,o,u,tuple(f))
    def state(s,x,y,z):
        if (x>>4,z>>4) not in s.avail: return 1
        if 0<=y<=63: return s.blocks.get((x,y,z),0)
        return 0
    def opacity(s,i): return max(1,s.states[i][1])
    def empty(s,i): e,d,o,u,f=s.states[i]; return int(o==0 or u==0)
    def face(s,i,d): return 0 if s.empty(i) else s.states[i][4][d]
    def occl(s,a,b,d):
        fa=s.face(a,d); fb=s.face(b,d^1)
        return int(not(fa==0 and fb==0) and (fa|fb)==15)
    def stores(s,k,x,y,z): return (x>>4,y>>4,z>>4) in s.lay[k].work
    def stored(s,k,x,y,z):
        w=s.lay[k].work.get((x>>4,y>>4,z>>4)); return w[(y&15)*256+(z&15)*16+(x&15)] if w else 0
    def setst(s,k,x,y,z,v): s.lay[k].setlevel(x,y,z,v)
    def emission(s,x,y,z):
        e=s.states[s.state(x,y,z)][0]
        return e if e>0 and (x>>4,z>>4) in s.lay[0].on else 0
    def pushinc(s,k,x,y,z,e): s.q[k]['inc'].append((x,y,z,e))
    def pushdec(s,k,x,y,z,e): s.q[k]['dec'].append((x,y,z,e))
    def check(s,k,x,y,z):
        if (x,y,z) not in s.q[k]['ck']: s.q[k]['ck'].append((x,y,z))
    def haswork(s,k):
        q=s.q[k]; return int(s.lay[k].incons or bool(q['ck']) or bool(q['inc']) or bool(q['dec']))
    def bcheck(s,x,y,z):
        if not s.stores(0,x,y,z): return
        e=s.emission(x,y,z); sl=s.stored(0,x,y,z)
        if e<sl:
            s.setst(0,x,y,z,0); s.pushdec(0,x,y,z,E_dec_all(sl))
        else: s.pushdec(0,x,y,z,PULL)
        if e>0: s.pushinc(0,x,y,z,E_inc_em(e,s.empty(s.state(x,y,z))))
    def pinc(s,k,x,y,z,ent,level):
        src=None; kk=s.empty_below(k,x,y,z) if k==1 else 0
        for d in range(6):
            if not (ent>>(4+d))&1: continue
            nx,ny,nz=x+DIRS[d][0],y+DIRS[d][1],z+DIRS[d][2]
            if not s.stores(k,nx,ny,nz): continue
            ns=s.stored(k,nx,ny,nz)
            if level-1<=ns: continue
            nst=s.state(nx,ny,nz); nl=level-s.opacity(nst)
            if nl<=ns: continue
            if src is None: src=0 if (ent>>10)&1 else s.state(x,y,z)
            if s.occl(src,nst,d): continue
            s.setst(k,nx,ny,nz,nl)
            if nl>1: s.pushinc(k,nx,ny,nz,E_inc_skip(nl,s.empty(nst),d^1))
            if k==1: s.from_empty(nx,ny,nz,d,nl,1,kk)
    def pdec(s,k,x,y,z,ent):
        frm=ent&15; kk=s.empty_below(k,x,y,z) if k==1 else 0
        for d in range(6):
            if not (ent>>(4+d))&1: continue
            nx,ny,nz=x+DIRS[d][0],y+DIRS[d][1],z+DIRS[d][2]
            if not s.stores(k,nx,ny,nz): continue
            ns=s.stored(k,nx,ny,nz)
            if ns==0: continue
            if ns<=frm-1:
                e=s.emission(nx,ny,nz) if k==0 else 0
                s.setst(k,nx,ny,nz,0)
                if e<ns: s.pushdec(k,nx,ny,nz,E_dec_skip(ns,d^1))
                if e>0: s.pushinc(k,nx,ny,nz,E_inc_em(e,s.empty(s.state(nx,ny,nz))))
                if k==1: s.from_empty(nx,ny,nz,d,ns,0,kk)
            else:
                s.pushinc(k,nx,ny,nz,E_inc_one(ns,0,d^1))
    def checknode(s,k,x,y,z):
        if k==0: s.bcheck(x,y,z)
        else: s.skycheck(x,y,z)
    # ---- sky sources (5.3)
    def edge_occ(s,a,b):
        if s.states[b][1]!=0: return 1
        fa=s.face(a,0); fb=s.face(b,1)
        return int(not(fa==0 and fb==0) and (fa|fb)==15)
    def blk(s,x,y,z): return s.blocks.get((x,y,z),0)
    def sky_fill(s,cx,cz):
        tab=[MINV]*256; top=-1
        for sy in range(4):
            if any(s.blk(cx*16+lx,sy*16+ly,cz*16+lz)!=0 for lx in range(16) for ly in range(16) for lz in range(16)): top=sy
        if top>=0:
            for lz in range(16):
                for lx in range(16):
                    above=0; found=MINV
                    for y in range(top*16+15,-1,-1):
                        here=s.blk(cx*16+lx,y,cz*16+lz)
                        if s.edge_occ(above,here): found=y+1; break
                        above=here
                    tab[lx+16*lz]=found
        s.ls[(cx,cz)]=tab
    def skylow(s,x,z,default):
        c=(x>>4,z>>4)
        if c not in s.avail or c not in s.ls: return default
        return s.ls[c][(x&15)+16*(z&15)]
    def find_below(s,x,y,z):
        above=s.state(x,y,z)
        for yy in range(y-1,-2,-1):
            below=s.state(x,yy,z)
            if s.edge_occ(above,below): return yy+1
            above=below
        return MINV
    def sky_step(s,x,lower,z,tab,idx):
        ny=lower+1; cur=tab[idx]
        occ=s.edge_occ(s.state(x,ny,z),s.state(x,lower,z))
        if occ and ny>cur: tab[idx]=ny; return True
        if not occ and ny==cur: tab[idx]=s.find_below(x,lower,z); return True
        return False
    def sky_update(s,x,y,z):
        tab=s.ls[(x>>4,z>>4)]; idx=(x&15)+16*(z&15)
        if y+1<tab[idx]: return False
        if s.sky_step(x,y,z,tab,idx): return True
        return s.sky_step(x,y-1,z,tab,idx)
    def update_column(s,x,z,lowest):
        L=s.lay[1]
        if L.lowest==INF: return
        bsec=L.lowest; bottom=bsec*16; col=(x>>4,z>>4)
        if lowest>bottom:
            y=lowest-1
            while True:
                sec=y//16
                if sec<bsec: break
                if not s.stores(1,x,y,z): y=sec*16-1; continue
                if s.stored(1,x,y,z)!=15: break
                s.setst(1,x,y,z,0); s.pushdec(1,x,y,z,REM_TOP if y==lowest-1 else REM_SKY); y-=1
        nbr=max(s.skylow(x-1,z,MINV),s.skylow(x+1,z,MINV),s.skylow(x,z-1,MINV),s.skylow(x,z+1,MINV))
        y=max(lowest,bottom)
        while True:
            sec=y//16
            if col not in L.top or sec>=L.top[col]: break
            if not s.stores(1,x,y,z): y=(sec+1)*16; continue
            if s.stored(1,x,y,z)==15: break
            s.setst(1,x,y,z,15)
            if y<nbr or y==lowest: s.pushinc(1,x,y,z,ADD_SKY)
            y+=1
    def skycheck(s,x,y,z):
        col=(x>>4,z>>4)
        lowest=s.skylow(x,z,INF) if col in s.lay[1].on else INF
        if lowest!=INF: s.update_column(x,z,lowest)
        if not s.stores(1,x,y,z): return
        if y>=lowest:
            s.pushdec(1,x,y,z,REM_SKY); s.pushinc(1,x,y,z,ADD_SKY)
        else:
            sl=s.stored(1,x,y,z)
            if sl>0: s.setst(1,x,y,z,0); s.pushdec(1,x,y,z,E_dec_all(sl))
            else: s.pushdec(1,x,y,z,PULL)
    def empty_below(s,k,x,y,z):
        if k!=1 or (y&15)!=0: return 0
        lx=x&15; lz=z&15
        if lx not in (0,15) and lz not in (0,15): return 0
        cnt=0; sec=(y>>4)-1
        while (x>>4,sec,z>>4) not in s.lay[1].work and sec>=s.lay[1].lowest: cnt+=1; sec-=1
        return cnt
    def from_empty(s,nx,ny,nz,d,level,inc,kk):
        if kk==0: return
        lx=nx&15; lz=nz&15
        cross={2:lz==15,3:lz==0,4:lx==15,5:lx==0}.get(d,False)
        if not cross: return
        nsec=ny>>4
        for sec in range(nsec-1,nsec-kk-1,-1):
            if (nx>>4,sec,nz>>4) not in s.lay[1].work: continue
            for yy in range(sec*16+15,sec*16-1,-1):
                if inc:
                    s.setst(1,nx,yy,nz,level)
                    if level>1: s.pushinc(1,nx,yy,nz,E_inc_skip(level,1,d^1))
                else:
                    s.setst(1,nx,yy,nz,0); s.pushdec(1,nx,yy,nz,E_dec_skip(level,d^1))
    def chunk_start_sky(s,cx,cz):
        L=s.lay[1]; L.on.add((cx,cz)); col=(cx,cz)
        top=L.top.get(col,L.lowest); bottom=L.lowest; tab=s.ls[col]; sec=top-1
        while sec>=bottom:
            if (cx,sec,cz) not in L.work: sec-=1; continue
            sb=sec*16; st=sb+15; mark=False
            for lz in range(16):
                for lx in range(16):
                    ls=tab[lx+16*lz]
                    if ls>st: continue
                    X=cx*16+lx; Z=cz*16+lz
                    lsN=s.skylow(X,Z-1,MINV); lsS=s.skylow(X,Z+1,MINV); lsW=s.skylow(X-1,Z,MINV); lsE=s.skylow(X+1,Z,MINV)
                    mx=max(lsN,lsS,lsW,lsE)
                    for y in range(st,max(sb,ls)-1,-1):
                        s.setst(1,X,y,Z,15)
                        if y==ls or y<mx: s.pushinc(1,X,y,Z,E_sky(y==ls,y<lsN,y<lsS,y<lsW,y<lsE))
                    if ls<sb: mark=True
            if not mark: break
            sec-=1
    def set_enabled(s,cx,cz,flag):
        col=(cx,cz); s.lay[0].on.add(col) if flag else s.lay[0].on.discard(col)
        if not s.skyon: return
        L=s.lay[1]; L.on.add(col) if flag else L.on.discard(col)
        if flag:
            top=L.top.get(col,L.lowest); bottom=L.lowest; tab=s.ls.get(col,[MINV]*256); H=max(tab)
            S=bottom if H==MINV else ((H-1)>>4)+1
            for sec in range(top-1,max(bottom,S)-1,-1):
                p=(cx,sec,cz)
                if p in L.work and not any(L.work[p]): L.work[p]=[15]*4096; L.changed.add(p)
    def run(s,k):
        q=s.q[k]; n=0
        for (x,y,z) in list(q['ck']): s.checknode(k,x,y,z)
        q['ck']=[]
        while q['dec']:
            x,y,z,e=q['dec'].pop(0); n+=1; s.pdec(k,x,y,z,e)
        while q['inc']:
            x,y,z,e=q['inc'].pop(0); n+=1
            frm=e&15; lv=s.stored(k,x,y,z)
            if (e>>11)&1 and lv<frm and s.stores(k,x,y,z):
                s.setst(k,x,y,z,frm); lv=frm
            if lv==frm: s.pinc(k,x,y,z,e,lv)
        s.lay[k].finish()
        return n
    def chunk_start_block(s,cx,cz):
        s.lay[0].on.add((cx,cz))
        for sy in range(4):
            for ly in range(16):
                for lz in range(16):
                    for lx in range(16):
                        x,y,z=cx*16+lx,sy*16+ly,cz*16+lz
                        st=s.state(x,y,z); e=s.states[st][0]
                        if e!=0: s.pushinc(0,x,y,z,E_inc_em(e,s.empty(st)))
    def cksum(s,k,x0,x1,y0,y1,z0,z1):
        c=0; w=0
        for x in range(x0,x1+1):
            for y in range(y0,y1+1):
                for z in range(z0,z1+1):
                    v=s.stored(k,x,y,z)
                    if v: c+=1; w+=v*(1+(x*7+y*13+z*31)%97)
        return c,w
class EScn:
    def __init__(self,sky=0):
        self.sky=sky; self.m=Eng(sky); self.calls=[]; self.exp=[]
        self.op("%d"%sky,'CALL "L32-INIT" USING WS-I(1)')
    def op(self,inp,call,n=None): self.calls.append((inp,call,n))
    def define(self,i,e,d,o,u,f):
        self.m.define(i,e,d,o,u,f); self.op(S(i,e,d,o,u,*f),DEF)
    def standard(self):
        for i in (2,3,4,5,6,7,8,9): self.define(i,*STATES[i][:4],STATES[i][4])
        self.define(10,15,15,1,0,[15]*6); self.define(11,0,3,0,0,[0]*6); self.define(12,5,0,0,0,[0]*6)
    def everything(self,ks=(1,)):
        for cz in range(-1,3):
            for cx in range(-1,3):
                self.avail(cx,cz,1)
        for k in ks:
            for cz in range(-1,3):
                for cx in range(-1,3):
                    for sy in range(4):
                        self.m.lay[k-1].status((cx,sy,cz),0); self.op(S(k,cx,sy,cz,0),'CALL "L32-STORAGE-STATUS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
            self.m.lay[k-1].finish(); self.op(S(k),'CALL "L32-STORAGE-FINISH" USING WS-I(1)')
    def enable(self,k,cx,cz,f):
        (self.m.lay[k-1].on.add if f else self.m.lay[k-1].on.discard)((cx,cz)); self.op(S(k,colidx((cx,0,cz)),f),'CALL "L32-STORAGE-ENABLE" USING WS-I(1) WS-I(2) WS-I(3)')
    def enable_all(self,k):
        for cz in range(-1,3):
            for cx in range(-1,3): self.enable(k,cx,cz,1)
    def cell(self,x,y,z,i):
        self.m.blocks[(x,y,z)]=i; self.op(S(x,y,z,i),'CALL "L32-SET-CELL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4)')
    def check(self,k,x,y,z):
        self.m.check(k-1,x,y,z); self.op(S(k,x,y,z),'CALL "L32-CHECK-BLOCK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4)')
    def haswork(self,k):
        self.exp.append(str(self.m.haswork(k-1))); self.op(S(k),'CALL "L32-HAS-WORK" USING WS-I(1) WS-R(1)',1)
    def run(self,k):
        self.exp.append(str(self.m.run(k-1))); self.op(S(k),'CALL "L32-RUN-UPDATES" USING WS-I(1) WS-R(1)',1)
    def probe(self,k,x0,x1,y0,y1,z0,z1):
        c,w=self.m.cksum(k-1,x0,x1,y0,y1,z0,z1); self.exp.append("%d/%d"%(c,w))
        self.op("%d"%k,'MOVE 0 TO WS-R(1) WS-R(2)\nPERFORM VARYING WS-PX FROM %d BY 1 UNTIL WS-PX > %d\n PERFORM VARYING WS-PY FROM %d BY 1 UNTIL WS-PY > %d\n  PERFORM VARYING WS-PZ FROM %d BY 1 UNTIL WS-PZ > %d\n   CALL "L32-GET-STORED" USING WS-I(1) WS-PX WS-PY WS-PZ WS-LV\n   IF WS-LV > 0\n    ADD 1 TO WS-R(1)\n    COMPUTE WS-PW = WS-PX * 7 + WS-PY * 13 + WS-PZ * 31\n    COMPUTE WS-PW = 1 + FUNCTION MOD(WS-PW, 97)\n    COMPUTE WS-R(2) = WS-R(2) + WS-LV * WS-PW\n   END-IF\n  END-PERFORM\n END-PERFORM\nEND-PERFORM'%(x0,x1,y0,y1,z0,z1),2)
    def level(self,k,x,y,z):
        self.exp.append(str(self.m.stored(k-1,x,y,z))); self.op(S(k,x,y,z),'CALL "L32-GET-STORED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
    def qpeek(self,k,which,i):
        q=self.m.q[k-1]['inc' if which==1 else 'dec']
        if i==0: self.exp.append(str(len(q)))
        else:
            x,y,z,e=q[i-1]; self.exp.append("%d/%d/%d/%d/%d"%(len(q),x,y,z,e))
        self.op(S(k,which,i),'CALL "L32-QUEUE-ENTRY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',1 if i==0 else 5)
    def chunk_block(self,cx,cz):
        self.m.chunk_start_block(cx,cz); self.op(S(cx,cz),'CALL "L32-CHUNK-START-BLOCK" USING WS-I(1) WS-I(2)')
    def pub(self,k,x,y,z):
        self.exp.append(str(self.m.lay[k-1].pub(x,y,z) if (k==1 or self.m.skyon) else 0)); self.op(S(k,x,y,z),'CALL "L32-GET-PUBLISHED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
    def fill(self,cx,cz):
        self.m.sky_fill(cx,cz); self.op(S(cx,cz),'CALL "L32-SKY-FILL" USING WS-I(1) WS-I(2)')
    def tab(self,x,z,df=777):
        self.exp.append(str(self.m.skylow(x,z,df))); self.op(S(x,z,df),'CALL "L32-SKY-LOWEST" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1)
    def skyupdate(self,x,y,z):
        r=self.m.sky_update(x,y,z); self.exp.append("%d/%d"%(int(r),self.m.skylow(x,z,777))); self.op(S(x,y,z,x,z,777),'CALL "L32-SKY-UPDATE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)\nCALL "L32-SKY-LOWEST" USING WS-I(4) WS-I(5) WS-I(6) WS-R(2)',2)
    def chunk_sky(self,cx,cz):
        self.m.chunk_start_sky(cx,cz); self.op(S(cx,cz),'CALL "L32-CHUNK-START-SKY" USING WS-I(1) WS-I(2)')
    def setlight(self,cx,cz,f):
        self.m.set_enabled(cx,cz,f); self.op(S(cx,cz,f),'CALL "L32-SET-LIGHT-ENABLED" USING WS-I(1) WS-I(2) WS-I(3)')
    def rawset(self,k,x,y,z,v):
        self.m.setst(k-1,x,y,z,v); self.op(S(k,x,y,z,v),'CALL "L32-SET-STORED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def rawinc(self,k,x,y,z,ent):
        self.m.pushinc(k-1,x,y,z,ent); self.op(S(k,x,y,z,ent),'CALL "L32-PUSH-INC" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def rawdec(self,k,x,y,z,ent):
        self.m.pushdec(k-1,x,y,z,ent); self.op(S(k,x,y,z,ent),'CALL "L32-PUSH-DEC" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def floor(self,y,id_=2):
        for x in range(-16,48):
            for z in range(-16,48): self.m.blocks[(x,y,z)]=id_
        self.op(S(y,id_),'PERFORM VARYING WS-PX FROM -16 BY 1 UNTIL WS-PX > 47\n PERFORM VARYING WS-PZ FROM -16 BY 1 UNTIL WS-PZ > 47\n  CALL "L32-SET-CELL" USING WS-PX WS-I(1) WS-PZ WS-I(2)\n END-PERFORM\nEND-PERFORM')
    def fill_all(self):
        for cz in range(-1,3):
            for cx in range(-1,3): self.fill(cx,cz)
    def status(self,k,sx,sy,sz,empty):
        self.m.lay[k-1].status((sx,sy,sz),empty); self.op(S(k,sx,sy,sz,empty),'CALL "L32-STORAGE-STATUS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def finish(self,k):
        self.m.lay[k-1].finish(); self.op(S(k),'CALL "L32-STORAGE-FINISH" USING WS-I(1)')
    def avail(self,cx,cz,f):
        (self.m.avail.add if f else self.m.avail.discard)((cx,cz)); self.op(S(cx,cz,f),'CALL "L32-AVAIL-CHUNK" USING WS-I(1) WS-I(2) WS-I(3)')
        if f: self.m.ls[(cx,cz)]=[MINV]*256
    def run_case(self,g,text): g.case(text,self.calls," ".join(self.exp))
EXTRA=" 01 WS-PX                BINARY-LONG.\n 01 WS-PY                BINARY-LONG.\n 01 WS-PZ                BINARY-LONG.\n 01 WS-PW                BINARY-LONG.\n 01 WS-LV                BINARY-LONG.\n"

def base(sky=0,enable=True):
    e=EScn(sky); e.standard(); e.everything((1,) if not sky else (1,2))
    if enable: e.enable_all(1)
    return e
BOX=(-8,24,6,34,-8,24)
# ===================== 4
g=GL(4,'The update cycle','T0685','checkBlock records work, runLightUpdates runs the checks, then the decrease queue, then the increase queue and returns the pairs processed.')
g.extra=EXTRA
e=base()
e.haswork(1); e.cell(8,20,8,4); e.check(1,8,20,8); e.haswork(1); e.check(1,8,20,8); e.run(1); e.haswork(1); e.probe(1,*BOX)
e.level(1,8,20,8); e.level(1,9,20,8); e.level(1,8,21,8); e.level(1,8,20,10)
e.run_case(g,'checkBlock adds the packed position to a set (a second check of the same position adds nothing); hasLightWork is true while the check set holds a position and false once the run ended; the run returns the number of queue pairs processed')
e=base()
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1); e.haswork(1)
e.m.lay[0].status((0,1,0),1); e.op(S(1,0,1,0,1),'CALL "L32-STORAGE-STATUS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
e.haswork(1); e.run(1); e.haswork(1); e.probe(1,*BOX)
e.run_case(g,'hasLightWork is also true while the storage has inconsistencies (a section went empty: a layer waits for removal); the run clears it (step 4 markNewInconsistencies) and a removed section drops its layer')
e=base()
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1)
e.cell(8,20,8,0); e.check(1,8,20,8); e.run(1); e.probe(1,*BOX)
e.cell(12,20,8,4); e.cell(4,20,8,4); e.check(1,12,20,8); e.check(1,4,20,8); e.run(1)
e.cell(12,20,8,0); e.check(1,12,20,8); e.run(1); e.probe(1,*BOX)
e.level(1,8,20,8); e.level(1,12,20,8); e.level(1,6,20,8)
e.run_case(g,'decreases are drained completely before increases (4): removing one of two torches clears its light first, then the increase queue refills the boundary from the other torch; the run counts decrease and increase pairs')
W(g,4)
# ===================== 5
g=GL(5,'Propagation rules','T0687','block light: checkNode, propagateIncrease, propagateDecrease, chunk start; the validation table rows 1 to 4.')
g.extra=EXTRA
e=base()
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1)
for d in range(0,16): e.level(1,8+d,20,8)
for d in range(0,15): e.level(1,8,20+d,8)
for x,y,z in [(0,20,8),(8,28,8),(12,24,10),(8,20,22),(9,21,9),(15,27,9)]: e.level(1,x,y,z)
e.probe(1,*BOX)
for d in range(0,16): assert e.m.stored(0,8+d,20,8)==max(0,14-d)
for (x,y,z) in [(0,20,8),(8,28,8),(12,24,10),(8,20,22),(9,21,9),(15,27,9)]: assert e.m.stored(0,x,y,z)==max(0,14-(abs(x-8)+abs(y-20)+abs(z-8)))
e.run_case(g,'validation 1 (5.4 example 1): a torch (emission 14) in open air gives level 14 - d at Manhattan distance d for d from 0 to 13 and 0 beyond; the stored level of the torch cell is raised to the emission first')
e=base()
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1); e.cell(8,20,8,0); e.check(1,8,20,8); e.run(1)
e.probe(1,*BOX); e.level(1,9,20,8); e.level(1,8,20,8)
assert e.m.cksum(0,*BOX)==(0,0)
e.run_case(g,'validation 2 (5.4 example 2): removing the torch: checkNode finds e = 0 < s = 14, stores 0 and queues a decrease; every cell returns to 0 after one decrease pass and one increase pass')
e=base()
e.cell(6,20,8,4); e.cell(10,20,8,4); e.check(1,6,20,8); e.check(1,10,20,8); e.run(1)
e.level(1,8,20,8); e.cell(10,20,8,0); e.check(1,10,20,8); e.run(1)
for x in (4,6,8,10,12): e.level(1,x,20,8)
e.probe(1,*BOX)
e.run_case(g,'validation 3: two torches 4 cells apart, remove one: the cells between settle at the remaining torch 14 - d and none keeps the removed torch value (the re-spreading increaseOnlyOneDirection entries of propagateDecrease)')
e=base()
e.cell(8,20,8,4); e.cell(9,20,8,2); e.cell(8,20,9,3); e.cell(8,21,8,11); e.cell(7,20,8,10)
e.check(1,8,20,8); e.check(1,9,20,8); e.check(1,8,20,9); e.check(1,8,21,8); e.check(1,7,20,8); e.run(1)
for p_ in [(9,20,8),(10,20,8),(8,20,9),(8,20,10),(8,21,8),(8,22,8),(7,20,8),(6,20,8),(8,19,8)]: e.level(1,*p_)
e.probe(1,*BOX)
e.run_case(g,'validation 4 and opacity (5.4 examples 3 and 4): a dampening-15 block next to a level-14 cell stays 0 and light does not enter; leaves (opacity 1) pass 13; dampening 3 gives 14 - 3; an opaque emitter (lamp, emission 15) stores its own level and spreads as from an empty shape')
e=base()
e.cell(8,20,8,4); e.cell(9,20,8,5); e.cell(8,21,8,8); e.cell(8,19,8,9); e.cell(7,20,8,5)
for p_ in [(8,20,8),(9,20,8),(8,21,8),(8,19,8),(7,20,8)]: e.check(1,*p_)
e.run(1)
for p_ in [(9,20,8),(10,20,8),(8,22,8),(8,18,8),(7,20,8),(6,20,8),(8,20,9),(9,20,9)]: e.level(1,*p_)
e.probe(1,*BOX)
e.run_case(g,'face-shape occlusion (2.1, 5.1 step 5): slabs that use their shape block light across faces that cover together (bottom slab above the torch, down against up) and not across a side of two half faces; the torch itself is a non-occluding source')
e=base(enable=False)
e.enable(1,1,0,1)
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1); e.probe(1,*BOX); e.cell(24,20,8,4); e.check(1,24,20,8); e.run(1); e.probe(1,*BOX); e.level(1,24,20,8)
e.run_case(g,'emission of a cell (5.1) is the state emission only when the chunk column has light enabled: a torch in a column without it stays dark and checkNode finds nothing to pull; the torch in the enabled column lights its own and the neighbouring section')
e=EScn(0); e.standard()
for cz in range(-1,3):
    for cx in range(-1,3):
        e.avail(cx,cz,1)
e.m.lay[0].status((0,1,0),0); e.op(S(1,0,1,0,0),'CALL "L32-STORAGE-STATUS" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
e.m.lay[0].finish(); e.op("1",'CALL "L32-STORAGE-FINISH" USING WS-I(1)')
e.enable_all(1)
e.cell(28,20,8,4); e.cell(12,2,8,4); e.check(1,28,20,8); e.check(1,12,2,8); e.run(1)
e.probe(1,12,44,6,34,-8,24); e.probe(1,0,24,0,16,-8,24); e.level(1,31,20,8); e.level(1,32,20,8); e.level(1,12,2,8); e.level(1,12,-2,8)
e.run_case(g,'sections that store no light are skipped (5.1 steps 1 of checkNode and propagateIncrease): with layers only around section (0, 1, 0) light stops at the section edge x = 32, and a torch in a section without a layer does nothing')
e=base()
e.avail(1,0,0)
e.cell(8,20,8,4); e.check(1,8,20,8); e.run(1)
e.level(1,15,20,8); e.level(1,16,20,8); e.level(1,17,20,8); e.probe(1,*BOX)
e.run_case(g,'an unloaded neighbour chunk reads as bedrock (2.2): opaque, so light stops at the chunk edge and the engine does not fail on the missing chunk')
e=base(enable=False)
e.cell(5,20,5,4); e.cell(2,3,9,12); e.cell(2,35,9,12); e.cell(14,50,14,10); e.cell(0,0,0,4); e.cell(15,63,15,12); e.cell(3,20,5,0)
e.chunk_block(0,0)
e.qpeek(1,1,0)
for i in range(1,6): e.qpeek(1,1,i)
e.run(1); e.probe(1,-8,24,-4,40,-8,24); e.probe(1,0,15,41,70,0,15); e.level(1,2,3,9); e.level(1,0,0,0)
e.run_case(g,'chunk start (5.1): light is enabled for the column and every emitting cell is queued as increaseLightFromEmission in storage index order (lowest section, then Y, Z, X ascending); emission of the light block is its own level and 0 is no source')
# ---- sky scenarios (5.2, 5.3)
def skybase(chunks=True):
    e=EScn(1); e.standard()
    for cz in range(-1,3):
        for cx in range(-1,3): e.avail(cx,cz,1)
    return e
e=skybase()
for p_,i in [((3,10,3),2),((4,10,4),3),((5,12,5),6),((5,3,5),2),((6,20,6),5),((7,63,7),2),((8,0,8),2),((9,30,9),7),((9,29,9),3),((10,40,10),9),((10,39,10),2),((2,5,2),12)]: e.cell(*p_,i)
e.fill(0,0)
for x,z in [(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(2,2),(0,0),(15,15)]: e.tab(x,z)
e.tab(16,0); e.tab(-1,0); e.tab(100,100)
e.m.avail.discard((1,0)); e.op(S(1,0,0),'CALL "L32-AVAIL-CHUNK" USING WS-I(1) WS-I(2) WS-I(3)'); e.tab(16,0)
e.fill(1,1)
e.tab(17,17)
e.run_case(g,'sky sources fill (5.3 fillFrom): the lowest source Y of a column is the Y of the cell above the first cell where the edge is occluded (stone 11 for y 10; leaves and water-like dampening end a column; glass passes; a bottom slab occludes at its own cell); an empty chunk or a column without ground is the minimum value; the read gives the default for an unavailable chunk')
e=skybase()
e.cell(3,10,3,2); e.cell(3,9,3,2); e.fill(0,0)
for step in [((3,11,3,2),),((3,11,3,0),),((3,10,3,0),),((3,9,3,0),),((4,5,4,2),),((4,5,4,0),),((3,2,3,2),),((5,40,5,3),),((5,40,5,6),),((5,41,5,2),),((5,41,5,0),),((5,40,5,0),),((6,20,6,5),),((6,20,6,0),),((6,21,6,5),),((6,22,6,2),),((6,22,6,0),),((6,21,6,0),)]:
    x,y,z,i=step[0]; e.cell(x,y,z,i); e.skyupdate(x,y,z)
e.run_case(g,'sky sources update (5.3): update(chunk, x, y, z) returns false when y + 1 is below the current value; a changed cell that makes the edge above it occluded raises the entry to its y + 1; one that opens the edge at the current value looks down (findLowestSourceBelow) for the next occluded edge or the minimum; the edge below the changed cell is tested the same way')
# sky light propagation on a floor with a roof
def sky_world(roof=True):
    e=EScn(1); e.standard(); e.everything((1,2)); e.floor(30)
    if roof:
        for x in range(4,10):
            for z in range(4,10): e.cell(x,40,z,2)
    e.fill_all()
    for cx,cz in [(0,0),(1,0),(0,1),(1,1)]: e.chunk_sky(cx,cz)
    return e
SBOX=(0,31,28,45,0,31)
e=sky_world()
e.qpeek(2,1,0); e.run(2); e.probe(2,*SBOX)
for p_ in [(3,35,6),(4,35,6),(6,35,6),(9,35,9),(12,35,6),(6,45,6),(6,41,6),(6,31,6),(20,35,20),(20,31,20),(20,30,20)]: e.level(2,*p_)
assert e.m.stored(1,6,35,6)==12 and e.m.stored(1,4,35,6)==14 and e.m.stored(1,3,35,6)==15 and e.m.stored(1,6,41,6)==15 and e.m.stored(1,6,31,6)==12
for x in range(0,32):
    for z in range(0,32):
        assert e.m.stored(1,x,31,z)==15 or (4<=x<10 and 4<=z<10)
e.run_case(g,'sky light 15 at and above the lowest source of the column and spreading below it (5.2 chunk start, propagateIncrease): a roof over open ground gets 14 under its edge, 12 in the middle; validation 5: the cells at Y >= the lowest source read 15 and canSeeSky is true exactly there')
e=sky_world(); e.run(2); e.probe(2,*SBOX); h0=e.m.cksum(1,*SBOX)
e.cell(12,31,12,2); e.skyupdate(12,31,12); e.check(2,12,31,12); e.run(2); e.probe(2,*SBOX)
e.level(2,12,31,12); e.level(2,12,32,12); e.level(2,13,31,12); e.level(2,12,30,12)
e.cell(12,31,12,0); e.skyupdate(12,31,12); e.check(2,12,31,12); e.run(2); e.probe(2,*SBOX)
assert e.m.cksum(1,*SBOX)==h0
e.cell(20,45,20,2); e.skyupdate(20,45,20); e.check(2,20,45,20); e.run(2); e.probe(2,*SBOX); e.level(2,20,44,20); e.level(2,20,46,20); e.level(2,21,44,20); e.level(2,20,35,20)
e.cell(20,45,20,0); e.skyupdate(20,45,20); e.check(2,20,45,20); e.run(2); e.probe(2,*SBOX)
assert e.m.cksum(1,*SBOX)==h0
e.check(2,12,20,12); e.check(2,13,31,12); e.run(2); e.probe(2,*SBOX); assert e.m.cksum(1,*SBOX)==h0
e.cell(6,40,6,0); e.skyupdate(6,40,6); e.check(2,6,40,6); e.run(2); e.probe(2,*SBOX); e.level(2,6,35,6); e.level(2,6,40,6)
e.cell(6,40,6,2); e.skyupdate(6,40,6); e.check(2,6,40,6); e.run(2); e.probe(2,*SBOX)
assert e.m.cksum(1,*SBOX)==h0
e.run_case(g,'validation 6 and checkNode (5.2): an opaque block placed at the top of a sky column raises the source Y (updateSourcesInColumn removal step clears the old source cells with the all-direction entry on the top one), the cells below fall off by the spreading rule, and after breaking it the table and the levels equal the original; same for a block higher up and a hole in the roof (addition step)')
# empty sections below a column edge
e=EScn(1); e.standard()
for cz in range(-1,3):
    for cx in range(-1,3): e.avail(cx,cz,1)
e.status(2,0,0,0,0); e.status(2,2,3,0,0); e.finish(2)
e.rawset(2,32,32,5,15); e.rawinc(2,32,32,5,ADD_SKY); e.run(2)
e.probe(2,28,36,-16,40,2,8); e.level(2,31,32,5); e.level(2,31,31,5); e.level(2,31,-16,5); e.level(2,31,-17,5); e.level(2,30,31,5); e.level(2,33,32,5); e.level(2,32,32,4)
e.rawdec(2,32,32,5,E_dec_all(15)); e.rawset(2,32,32,5,0); e.qpeek(2,2,0); e.qpeek(2,2,1); e.run(2)
e.probe(2,28,36,-16,40,2,8)
e.run_case(g,'empty sections below a column edge (5.2 worked example): a lit cell on a section bottom edge counts k = 3 sections that store no light but have data below; the neighbour that crosses the section column edge (WEST, local x 15) writes its level into those sections of its own column, 16 Y values each, and the decrease clears them again; EAST and NORTH do not cross')
e=EScn(1); e.standard()
for cz in range(-1,3):
    for cx in range(-1,3): e.avail(cx,cz,1)
e.status(2,0,0,0,0); e.status(2,2,3,0,0); e.finish(2)
e.cell(36,10,5,2); e.fill(2,0); e.enable(2,2,0,1); e.check(2,36,40,5); e.run(2)
e.probe(2,34,38,-16,80,3,7); e.level(2,36,40,5); e.level(2,36,32,5); e.level(2,36,31,5); e.level(2,36,11,5)
e.cell(36,10,5,0); e.skyupdate(36,10,5); e.check(2,36,10,5); e.run(2); e.probe(2,34,38,-16,80,3,7); e.tab(36,5)
e.run_case(g,'updateSourcesInColumn passes over sections that store no light (5.2 removal and addition steps): with layers only around two sections, a source column whose lowest source is in a section without a layer skips down and up to the next storing section and ends at the world bottom or the top')
# chunk start worked example (5.2)
e=EScn(1); e.standard()
for cz in range(-1,3):
    for cx in range(-1,3): e.avail(cx,cz,1)
e.floor(19); e.cell(5,19,5,0); e.cell(5,2,5,2); e.fill_all()
e.status(2,0,0,0,0); e.status(2,0,1,0,0); e.finish(2)
e.chunk_sky(0,0); e.qpeek(2,1,0)
assert len(e.m.q[1]['inc'])==272
for i in (1,2,16,17,255,256,257,272): e.qpeek(2,1,i)
e.level(2,5,16,5); e.level(2,5,3,5); e.level(2,5,2,5); e.level(2,5,-1,5); e.level(2,7,31,7); e.level(2,7,47,7); e.level(2,7,20,7); e.level(2,7,19,7)
e.run(2); e.probe(2,0,15,-16,50,0,15); e.level(2,5,-1,5); e.level(2,6,10,5); e.level(2,10,10,5)
e.run_case(g,'chunk start of the sky engine (5.2 worked example): sections from the highest storing one down to the lowest; every column at or above its lowest source set to 15 with increaseSkySourceInDirections entries (17 entries for the pit column (5, 5), 272 queued in all) and the mark stops the loop below section 0 (section -1 untouched)')
# setLightEnabled fill (5.2)
e=EScn(1); e.standard()
for cz in range(-1,3):
    for cx in range(-1,3): e.avail(cx,cz,1)
e.floor(19); e.fill_all()
e.status(2,0,0,0,0); e.status(2,0,1,0,0); e.status(2,1,0,1,0); e.finish(2)
e.probe(2,0,15,-16,50,0,15); e.setlight(0,0,1); e.finish(2); e.probe(2,0,15,-16,50,0,15)
e.setlight(1,1,1); e.finish(2); e.probe(2,16,31,-16,50,16,31)
e.setlight(1,1,0); e.setlight(0,0,0); e.status(2,2,2,2,0); e.finish(2); e.setlight(2,2,1); e.finish(2); e.probe(2,32,47,-16,80,32,47)
e.run_case(g,'setLightEnabled(true) on the sky engine (5.2): every writable all-zero layer from the top storing section down to max(bottom, S) is filled with 15 (S = section of H - 1 plus 1, H the highest lowest-source Y; an empty chunk fills all); layers that already hold light stay; false only clears the flag')
W(g,5)
# ===================== 7
g=GL(7,'Block-state overrides','T0691','the default dampening rule and the per-class overrides of propagatesSkylightDown, dampening and useShapeForLightOcclusion.')
CLASSES=[('LeavesBlock',1),('TintedGlassBlock',2)]+[(n,3) for n in ('LiquidBlock','PipeBlock','ShulkerBoxBlock')]+[(n,4) for n in ('BambooStalkBlock','HangingMossBlock','MossyCarpetBlock','TransparentBlock','VineBlock')]+[(n,5) for n in ('BarrierBlock','GlowLichenBlock','LightBlock','VegetationBlock')]+[(n,6) for n in ('CrossCollisionBlock','WallBlock')]+[('SlabBlock',7)]+[(n,8) for n in ('StairBlock','SnowLayerBlock','DaylightDetectorBlock','EnchantingTableBlock','EndPortalFrameBlock','FarmlandBlock','LecternBlock','PathBlock','SculkSensorBlock','SculkShriekerBlock','ShelfBlock','StonecutterBlock','PistonHeadBlock')]+[('PistonBaseBlock',9),('StoneBlock',0),('GlassBlock',0)]
def rules(cat,solid,pdef,fempty,wl,dbl,ext):
    prop=pdef; use=0; ov=None
    if cat==1: ov=1
    if cat==2: ov=15; prop=0
    if cat==3: prop=0
    if cat==4: prop=1
    if cat==5: prop=fempty
    if cat==6: prop=1-wl
    if cat==7: use=1-dbl
    if cat==8: use=1
    if cat==9: use=ext
    d=ov if ov is not None else (15 if solid else (0 if prop else 1))
    return d,prop,use
g.extra=" 01 WS-CLS               PIC X(32).\n"
def r7(name,cat,solid,pdef,fe,wl,dbl,ext):
    d,p,u=rules(cat,solid,pdef,fe,wl,dbl,ext)
    return ('%s %d %d %d %d %d %d'%(name,solid,pdef,fe,wl,dbl,ext),"%d/%d/%d"%(d,p,u))
cases=[]
for name,cat in CLASSES:
    for solid,pdef,fe,wl,dbl,ext in [(0,1,1,0,0,0),(0,0,0,1,1,1),(1,0,1,0,0,1)]:
        cases.append((name,)+r7(name,cat,solid,pdef,fe,wl,dbl,ext))
def call7(c):
    name,inp,exp=c; _,solid,pdef,fe,wl,dbl,ext=inp.split()
    return (" ".join([solid,pdef,fe,wl,dbl,ext]),'MOVE "%s" TO WS-CLS\nCALL "L32-BLOCK-RULES" USING WS-CLS WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2) WS-R(3)'%name,3)
half=len(cases)//2
g.case('overrides by class (7, part 1): leaves dampening 1; tinted glass dampening 15 and no skylight pass; liquid, pipe, shulker box never propagate skylight; bamboo, hanging moss, moss carpet, transparent blocks and vines always do; barrier, glow lichen, light block and vegetation follow the fluid; walls and fences follow waterlogging',[call7(c) for c in cases[:half]]," ".join(c[2] for c in cases[:half]))
g.case('overrides by class (7, part 2): slabs use their shape unless double; stairs, snow layers, daylight detector, enchanting table, end portal frame, farmland, lectern, path, sculk sensor and shrieker, shelf, stonecutter and piston head always; the piston base only when extended; other classes use the default rule (full block 15, else 0 when skylight passes, else 1)',[call7(c) for c in cases[half:]]," ".join(c[2] for c in cases[half:]))
W(g,7)

# ===================== engine model, feeding (section 8)
def nib(b): return b&15,(b>>4)&15
def arr_of(b):
    lo,hi=nib(b); return [lo if i%2==0 else hi for i in range(4096)]
class Feed(Eng):
    def __init__(s,sky=0):
        Eng.__init__(s,sky); s.past=set(); s.correct={}; s.note={}; s.dirty=set(); s.tasks=[]; s.cq=[]
    def sec_nonair(s,cx,sy,cz):
        return any(s.blk(cx*16+lx,sy*16+ly,cz*16+lz)!=0 for lx in range(16) for ly in range(16) for lz in range(16))
    def status_both(s,sx,sy,sz,empty):
        s.lay[0].status((sx,sy,sz),empty)
        if s.skyon: s.lay[1].status((sx,sy,sz),empty)
    def check_both(s,x,y,z):
        s.check(0,x,y,z)
        if s.skyon: s.check(1,x,y,z)
    def light_diff(s,a,b):
        if a==b: return 0
        A,B=s.states[a],s.states[b]
        return int(A[1]!=B[1] or A[0]!=B[0] or A[3]==1 or B[3]==1)
    def set_block(s,mode,x,y,z,new):
        if not 0<=y<=63: return
        col=(x>>4,z>>4); old=s.blocks.get((x,y,z),0)
        if old==new: return
        sy=y>>4; was=not s.sec_nonair(col[0],sy,col[1])
        if new: s.blocks[(x,y,z)]=new
        else: s.blocks.pop((x,y,z),None)
        now=not s.sec_nonair(col[0],sy,col[1]); chg=was!=now; diff=s.light_diff(old,new)
        if mode==0 or col in s.past:
            if chg:
                s.status_both(col[0],sy,col[1],now)
                if mode==0: s.note[(col[0],sy,col[1])]=1 if now else 2
            if diff:
                s.sky_update(x,y,z); s.check_both(x,y,z)
    def mark(s,p):
        for dx in (-1,0,1):
            for dy in (-1,0,1):
                for dz in (-1,0,1):
                    q=(p[0]+dx,p[1]+dy,p[2]+dz)
                    if Store.ok(q): s.dirty.add(q)
    def apply_light(s,cx,cz,dirty,sm,se,bm,be,arrs):
        j=0
        for lst,(mask,emp) in ((1,(sm,se)),(0,(bm,be))):
            for i in range(6):
                p=(cx,i-1,cz)
                if (mask>>i)&1: a=arrs[j]; j+=1
                elif (emp>>i)&1: a=[0]*4096
                else: continue
                if lst==1 and not s.skyon: continue
                s.lay[lst].queue_layer(p,a)
                if dirty: s.mark(p)
        s.set_enabled(cx,cz,True)
    def enable_chunk_light(s,cx,cz):
        for sy in range(4): s.status_both(cx,sy,cz,0 if s.sec_nonair(cx,sy,cz) else 1)
        for dz in (-1,0,1):
            for dx in (-1,0,1):
                for sy in range(-1,5):
                    q=(cx+dx,sy,cz+dz)
                    if Store.ok(q): s.dirty.add(q)
    def forget(s,cx,cz):
        s.set_enabled(cx,cz,False)
        for sy in range(-1,5):
            s.lay[0].queue_data((cx,sy,cz),-1)
            if s.skyon: s.lay[1].queue_data((cx,sy,cz),-1)
        for sy in range(4): s.status_both(cx,sy,cz,1)
    def retain(s,cx,cz,f):
        for k in range(2 if s.skyon else 1):
            (s.lay[k].retain.add if f else s.lay[k].retain.discard)((cx,cz))
    def leave(s,cx,cz):
        s.retain(cx,cz,0); s.forget(cx,cz)
    def run_both(s):
        n=s.run(0)
        if s.skyon: n+=s.run(1)
        return n
    def poll_count(s,n): return n if n>=1000 else min(n,max(10,n//10))
    def exec_task(s,t):
        ph,k,a,b,c,d,e=t
        if k==1: s.check_both(a,b,c)
        elif k==2: s.status_both(a,b,c,d)
        elif k==3: s.set_enabled(a,b,bool(c))
        elif k==4:
            s.chunk_start_block(a,b)
            if s.skyon: s.chunk_start_sky(a,b)
        elif k==5: s.lay[a-1].queue_data((b,c,d),e)
        elif k==6: s.retain(a,b,c)
        elif k==7: s.leave(a,b)
        elif k==8: s.correct[(a,b)]=c
    def server_run(s):
        n=min(len(s.tasks),1000); batch=s.tasks[:n]
        for t in batch:
            if t[0]==0: s.exec_task(t)
        pairs=s.run_both()
        for t in batch:
            if t[0]==1: s.exec_task(t)
        s.tasks=s.tasks[n:]
        return n,pairs
    def needs(s):
        return int(bool(s.tasks) or s.haswork(0) or (s.skyon and s.haswork(1)))
class FScn(EScn):
    def __init__(self,sky=1):
        self.sky=sky; self.m=Feed(sky); self.calls=[]; self.exp=[]
        self.op("%d"%sky,'CALL "L32-INIT" USING WS-I(1)')
    def setblock(self,mode,x,y,z,i):
        self.m.set_block(mode,x,y,z,i); self.op(S(mode,x,y,z,i),'CALL "L32-SET-BLOCK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5)')
    def past(self,cx,cz,f):
        (self.m.past.add if f else self.m.past.discard)((cx,cz)); self.op(S(cx,cz,f),'CALL "L32-PAST-INIT" USING WS-I(1) WS-I(2) WS-I(3)')
    def submit(self,ph,kind,a=0,b=0,c=0,d=0,e=0):
        self.m.tasks.append((ph,kind,a,b,c,d,e)); self.op(S(ph,kind,a,b,c,d,e),'CALL "L32-SERVER-SUBMIT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7)')
    def srun(self):
        n,p=self.m.server_run(); self.exp.append("%d/%d"%(n,p)); self.op("0",'CALL "L32-SERVER-RUN" USING WS-R(1) WS-R(2)',2)
    def needs(self):
        self.exp.append(str(self.m.needs())); self.op("0",'CALL "L32-SERVER-NEEDS" USING WS-R(1)',1)
    def flags(self,k,cx,cz):
        L=self.m.lay[k-1]; self.exp.append("%d/%d/%d"%(int((cx,cz) in L.on),int((cx,cz) in L.retain),self.m.correct.get((cx,cz),0)))
        self.op(S(k,cx,cz),'CALL "L32-COLUMN-FLAGS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',3)
    def initlight(self,cx,cz,lighted):
        m=self.m; m.sky_fill(cx,cz)
        for sy in range(4):
            if m.sec_nonair(cx,sy,cz): m.tasks.append((0,2,cx,sy,cz,0,0))
        m.tasks.append((1,3,cx,cz,lighted,0,0)); m.tasks.append((1,6,cx,cz,0,0,0))
        self.op(S(cx,cz,lighted),'CALL "L32-INIT-LIGHT" USING WS-I(1) WS-I(2) WS-I(3)')
    def lightstage(self,cx,cz,lighted):
        m=self.m; m.correct[(cx,cz)]=0
        if not lighted: m.tasks.append((0,4,cx,cz,0,0,0))
        m.tasks.append((1,8,cx,cz,1,0,0))
        self.op(S(cx,cz,lighted),'CALL "L32-LIGHT-STAGE" USING WS-I(1) WS-I(2) WS-I(3)')
    def leave(self,cx,cz):
        self.m.tasks.append((0,7,cx,cz,0,0,0)); self.op(S(cx,cz),'CALL "L32-CHUNK-LEAVE" USING WS-I(1) WS-I(2)')
    def loadstored(self,cx,cz,fills):
        m=self.m; first=True
        for sy in range(4):
            hb=fills[sy]>=0; hs=m.skyon and fills[4+sy]>=0
            if hb or hs:
                if first: m.retain(cx,cz,1); first=False
                if hb: m.lay[0].queue_data((cx,sy,cz),fills[sy])
                if hs: m.lay[1].queue_data((cx,sy,cz),fills[4+sy])
        self.op(S(cx,cz,*fills),'CALL "L32-LOAD-STORED" USING WS-IST',None)
    def obs8(self,x,y,z):
        m=self.m; sx,sy,sz=x>>4,y>>4,z>>4
        a=m.lay[0].info((sx,sy,sz)); b=m.lay[1].info((sx,sy,sz))
        self.exp.append("%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%d"%(a[0],b[0],len(m.q[0]['ck']),len(m.q[1]['ck']),m.skylow(x,z,777),m.note.get((sx,sy,sz),0),int(a[1]),int(b[1]),a[3],int((sx,sy,sz) in m.dirty),a[5]))
        self.op(S(1,sx,sy,sz,2,sx,sy,sz,x,z,777),'CALL "L32-SECTION-INFO" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(7) WS-R(12) WS-R(9) WS-R(13) WS-R(11)\nCALL "L32-SECTION-INFO" USING WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(2) WS-R(8) WS-R(14) WS-R(15) WS-R(16) WS-R(13)\nCALL "L32-CHECK-COUNT" USING WS-I(1) WS-R(3)\nCALL "L32-CHECK-COUNT" USING WS-I(5) WS-R(4)\nCALL "L32-SKY-LOWEST" USING WS-I(9) WS-I(10) WS-I(11) WS-R(5)\nCALL "L32-EMPTY-NOTE" USING WS-I(2) WS-I(3) WS-I(4) WS-R(6)\nCALL "L32-DIRTY-AT" USING WS-I(2) WS-I(3) WS-I(4) WS-R(10)',11)

def f8(sky=1,standard=True):
    e=FScn(sky); e.standard()
    e.define(13,0,0,0,0,[0]*6); e.define(14,0,0,0,0,[0]*6)
    for cz in range(-1,3):
        for cx in range(-1,3): e.avail(cx,cz,1)
    return e
# ===================== 8
g=GL(8,'When the engine is fed','T0693','block changes, the client, the server batches, the generation stages and loaded light.')
g.extra=EXTRA+" 01 WS-DATA              PIC X(24576).\n"
e=f8()
e.setblock(0,5,20,5,2); e.obs8(5,20,5); e.setblock(0,5,20,5,2); e.obs8(5,20,5)
e.setblock(0,6,21,6,13); e.obs8(6,21,6); e.setblock(0,6,21,6,4); e.obs8(6,21,6); e.setblock(0,6,21,6,0); e.obs8(6,21,6); e.setblock(0,5,20,5,0); e.obs8(5,20,5)
e.setblock(0,5,20,5,0); e.obs8(5,20,5); e.setblock(0,5,100,5,2); e.setblock(0,5,-3,5,2); e.obs8(5,20,5)
e.setblock(0,20,3,20,2); e.run(1); e.run(2); e.obs8(20,3,20); e.setblock(0,20,50,20,9); e.obs8(20,50,20); e.setblock(0,20,50,20,5); e.obs8(20,50,20)
e.run_case(g,'LevelChunk.setBlockState (8.1): a write of the identical state or air into an all-air section does nothing; the first block of a section runs updateSectionStatus on both engines and tells the chunk source (emptiness note); a state whose light properties equal the old one (two airs) leaves the sky table and the check set alone; a changed emission or dampening updates the sky table and checks the position on both engines')
e=f8()
e.setblock(1,5,20,5,2); e.obs8(5,20,5); e.past(0,0,1); e.setblock(1,5,20,5,0); e.obs8(5,20,5); e.setblock(1,5,20,5,2); e.obs8(5,20,5); e.setblock(1,5,20,5,4); e.obs8(5,20,5)
e.setblock(1,5,200,5,2); e.setblock(1,5,21,5,3); e.obs8(5,21,5); e.past(0,0,0); e.setblock(1,6,21,6,2); e.obs8(6,21,6)
e.run_case(g,'ProtoChunk.setBlockState (8.1): the cell is stored always but the light work (updateSectionStatus then the sky table update and checkBlock; no emptiness note for the chunk source) only once the chunk status is at or after INITIALIZE_LIGHT; a Y outside the build height returns')
def arrs(e,sm,se,bm,be,pats):
    parts=[]
    for j,b in enumerate(pats):
        parts.append('MOVE ALL X"%02X" TO WS-DATA(%d:2048)'%(b,j*2048+1))
    return "\n".join(parts)
e=f8()
pats=[0x35,0x12,0x7F,0x24,0x71,0x66]
for p_ in [(0,0,0)]: pass
e.setblock(0,5,20,5,2)
e.op("0",arrs(e,0,0,0,0,pats),None)
arr=[arr_of(b) for b in pats]
e.m.apply_light(0,0,0,0b000110,0b100000,0b001001,0b010000,arr)
e.op(S(0,0,0,6,32,9,16),'CALL "L32-APPLY-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-DATA',None)
for y in (-5,5,20,40,70): e.obs8(5,y,5)
e.m.enable_chunk_light(0,0); e.op(S(0,0),'CALL "L32-ENABLE-CHUNK-LIGHT" USING WS-I(1) WS-I(2)',None)
for y in (-5,5,20,40,70): e.obs8(5,y,5)
e.run(1); e.run(2)
for y in (-5,5,20,40,70): e.obs8(5,y,5)
for (x,y,z) in [(1,-10,2),(2,-10,2),(3,10,3),(4,10,3),(3,25,3),(3,40,3),(4,40,3),(3,60,3)]:
    e.pub(1,x,y,z); e.pub(2,x,y,z)
e.run_case(g,'client chunk with light (8.2): the sky list then the block list: bit i of the mask queues a layer from the next array (nibbles low then high), else bit i of the empty mask an all-zero layer, else nothing; light is enabled afterwards; enableChunkLight gives every block section its emptiness; the queued layers are installed by the next engine run')
e=f8()
e.setblock(0,5,20,5,2)
e.op("0",arrs(e,0,0,0,0,pats),None)
e.m.apply_light(0,0,1,0b000110,0b100000,0b001001,0b010000,arr)
e.op(S(0,0,1,6,32,9,16),'CALL "L32-APPLY-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-DATA',None)
for p_ in [(5,-5,5),(5,5,5),(5,20,5),(5,40,5),(5,70,5),(40,5,5),(20,20,20)]: e.obs8(*p_)
e.run_case(g,'light update packet (8.2): the same apply step with the mark-dirty flag true marks each updated section and its neighbours dirty')
e=f8()
e.setblock(0,5,20,5,2)
e.op("0",arrs(e,0,0,0,0,pats),None)
e.m.apply_light(0,0,0,0b000110,0b100000,0b001001,0b010000,arr)
e.op(S(0,0,0,6,32,9,16),'CALL "L32-APPLY-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-DATA',None)
e.m.enable_chunk_light(0,0); e.op(S(0,0),'CALL "L32-ENABLE-CHUNK-LIGHT" USING WS-I(1) WS-I(2)',None)
e.run(1); e.run(2)
for y in (5,20,40): e.obs8(5,y,5)
e.m.forget(0,0); e.op(S(0,0),'CALL "L32-FORGET-CHUNK" USING WS-I(1) WS-I(2)',None)
for y in (-5,5,20,40): e.obs8(5,y,5)
e.run(1); e.run(2)
for y in (-5,5,20,40): e.obs8(5,y,5)
cl=[]
for k in (1,2):
    for cx,cz in [(0,0),(1,0)]: cl.append((k,cx,cz))
e.m.set_enabled(1,1,True); e.op(S(1,1,1),'CALL "L32-SET-LIGHT-ENABLED" USING WS-I(1) WS-I(2) WS-I(3)',None)
e.m.set_enabled(1,1,False); e.op(S(1,1),'CALL "L32-CHUNK-UNLOAD" USING WS-I(1) WS-I(2)',None)
for k in (1,2):
    for cx,cz in [(0,0),(1,1)]:
        e.exp.append("%d/%d"%(int(cx>=0 and (cx,cz) in e.m.lay[k-1].on),int((cx,cz) in e.m.lay[k-1].retain))); e.op(S(k,cx,cz),'CALL "L32-COLUMN-FLAGS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-R(3)',2)
e.run_case(g,'forget chunk and unload (8.2): setLightEnabled(false), a null layer queued for every light section of both engines (queued data is cleared) and every block section reported empty; unloading only turns the light off')
e=f8()
pcs=[(1,0),(5,0),(9,0),(10,0),(99,0),(100,0),(999,0),(1000,0),(1500,0),(3,0)]
g.run('pollLightUpdates (8.2): with n queued it runs max(10, n / 10) tasks when n < 1000 (never more than n), else all n',[S(n) for n,_ in pcs],'CALL "L32-POLL-COUNT" USING WS-I(1) WS-R(1)',1," ".join(str(Feed().poll_count(n)) for n,_ in pcs))
e=f8()
e.setblock(0,5,20,5,2); e.setblock(0,20,20,20,2)
e.run(1); e.run(2)
for kind,cx,cz in [(1,0,0),(1,1,1),(2,0,0),(3,1,1)]:
    e.m.cq.append((kind,cx,cz)); e.op(S(kind,cx,cz),'CALL "L32-CLIENT-QUEUE" USING WS-I(1) WS-I(2) WS-I(3)',None)
def cl_update(e):
    n=len(e.m.cq); k=e.m.poll_count(n); ran=e.m.cq[:k]; e.m.cq=e.m.cq[k:]
    for kind,cx,cz in ran:
        if kind==1: e.m.enable_chunk_light(cx,cz)
        elif kind==2: e.m.forget(cx,cz)
        else: e.m.set_enabled(cx,cz,False)
    pairs=e.m.run_both(); e.exp.append("%d/%d"%(k,pairs)); e.op("0",'CALL "L32-CLIENT-UPDATE" USING WS-R(1) WS-R(2)',2)
cl_update(e)
for p_ in [(5,20,5),(20,20,20)]: e.obs8(*p_)
cl_update(e)
e.run_case(g,'client frame (8.2): ClientLevel.update polls the task deque (enable chunk light, forget, unload tasks) and then runs the engines once; the update is per frame, not per tick')

e=f8()
e.cell(5,20,5,4); e.cell(6,20,5,2)
e.needs(); e.submit(0,2,0,1,0,0,0); e.submit(0,5,1,0,1,0,9); e.submit(0,3,0,0,1,0,0); e.submit(0,1,5,20,5,0,0); e.submit(1,6,0,0,1,0,0); e.needs()
e.srun(); e.needs(); e.pub(1,1,17,2); e.level(1,5,20,5); e.level(1,6,20,5); e.level(1,5,21,5); e.level(1,4,20,5); e.flags(1,0,0); e.flags(2,0,0)
for i in range(1005): e.submit(1 if i%2 else 0,6,0,1,i%2,0,0)
e.needs(); e.srun(); e.needs(); e.srun(); e.needs(); e.flags(1,0,1)
e.run_case(g,'server batches (8.3): every call is a task; runUpdate processes at most 1000 tasks: the PRE_UPDATE ones first, then one light update run, then the POST_UPDATE ones of the same batch; tasks are removed once processed; scheduling is needed while tasks wait or the engines have work')
e=f8()
e.floor(19); e.cell(5,19,5,0); e.cell(5,2,5,2)
e.initlight(0,0,0); e.needs(); e.srun(); e.flags(1,0,0); e.flags(2,0,0)
e.lightstage(0,0,0); e.srun(); e.flags(2,0,0); e.probe(2,0,15,-16,35,0,15); e.level(2,5,3,5); e.level(2,5,25,5)
e.initlight(1,0,1); e.srun(); e.lightstage(1,0,1); e.srun(); e.flags(2,1,0); e.probe(2,16,31,-16,35,0,15)
e.leave(0,0); e.srun(); e.flags(1,0,0); e.flags(2,0,0); e.srun(); e.probe(2,0,15,-16,35,0,15); e.obs8(5,20,5)
e.run_case(g,'chunk generation stages (8.3): initializeLight fills the sky sources and queues updateSectionStatus for every non-air section, then (POST) setLightEnabled(lighted) and retainData(false); light propagates the sources only when the chunk was not lighted and marks the light correct; a chunk that leaves the stage is switched off, its data dropped and its sections reported empty')
e=f8()
e.loadstored(0,0,[3,-1,5,-1,9,-1,-1,2]); e.flags(1,0,0); e.flags(2,0,0)
for sy in range(4): e.obs8(5,sy*16+1,5)
e.status(1,0,0,0,0); e.status(2,0,0,0,0); e.status(1,0,2,0,0); e.status(2,0,2,0,0)
e.m.sky_fill(0,0); e.op(S(0,0),'CALL "L32-SKY-FILL" USING WS-I(1) WS-I(2)')
e.finish(1); e.finish(2)
for sy in range(4): e.obs8(5,sy*16+1,5)
for p_ in [(5,5,5),(5,37,5),(5,53,5),(5,21,5)]: e.pub(1,*p_); e.pub(2,*p_)
e.run_case(g,'stored light (8.4): for each saved section with a block layer, or a sky layer in a dimension with sky light, retainData(chunk, true) once and then queueSectionData for the layers present; the queued layers are installed once updateSectionStatus makes the section store light')
e=f8(sky=0)
e.loadstored(0,0,[3,-1,5,-1,9,-1,-1,2]); e.flags(1,0,0)
e.status(1,0,0,0,0); e.finish(1); e.obs8(5,5,5); e.pub(1,5,5,5); e.pub(2,5,5,5)
e.setblock(0,5,20,5,2); e.obs8(5,20,5)
e.run_case(g,'a dimension without sky light (1.1, 8.4): a stored sky layer is ignored, the sky engine does not exist (no sky state, no sky check, sky reads 0) while block light still loads')
W(g,8)
# ===================== 9
import heapq, random
g=GL(9,'Summary for an implementer','T0695','the four rules of the summary: tables, block change feeding, the light formula (independent shortest-path check) and the packet state of a layer.')
g.extra=EXTRA+" 01 WS-DATA              PIC X(24576).\n"
def dijkstra(m,sources,box):
    """independent field: level(cell) = max over sources of start - sum of the opacity of every cell entered (never below 0); sources: {(x,y,z): level}"""
    lv={}; heap=[(-l,c) for c,l in sources.items()]; heapq.heapify(heap); best=dict(sources)
    while heap:
        nl,c=heapq.heappop(heap); l=-nl
        if best.get(c,0)>l: continue
        for d in DIRS:
            n=(c[0]+d[0],c[1]+d[1],c[2]+d[2])
            if not(-16<=n[0]<=47 and -16<=n[2]<=47 and -16<=n[1]<=79): continue
            nl2=l-m.opacity(m.state(*n))
            if nl2>best.get(n,0): best[n]=nl2; heapq.heappush(heap,(-nl2,n))
    return best
def cks(best,x0,x1,y0,y1,z0,z1):
    c=w=0
    for x in range(x0,x1+1):
        for y in range(y0,y1+1):
            for z in range(z0,z1+1):
                v=best.get((x,y,z),0)
                if v>0: c+=1; w+=v*(1+(x*7+y*13+z*31)%97)
    return c,w
e=f8(sky=1)
e.setblock(0,5,20,5,4); e.run(1); e.run(2); e.level(1,5,20,5); e.level(1,8,20,5); e.level(1,5,20,9)
e.setblock(0,5,20,5,0); e.run(1); e.run(2); e.level(1,5,20,5); e.level(1,8,20,5); e.probe(1,-10,20,10,30,-10,20)
e.m.chunk_start_block(0,0); e.op(S(0,0),'CALL "L32-CHUNK-START-BLOCK" USING WS-I(1) WS-I(2)')
e.run_case(g,'summary 1 and 2: a block change goes through the section emptiness and light-property hooks of 8.1 and then the check, the decrease queue and the increase queue of 4 (place and remove a torch through the hook)')
rnd=random.Random(32)
e=f8(sky=0); e.everything((1,)); e.enable_all(1)
src={}
for i in range(60):
    x,y,z=rnd.randrange(0,32),rnd.randrange(10,31),rnd.randrange(0,32)
    st=rnd.choice([2,3,11,2,11,3,3,11])
    e.cell(x,y,z,st)
for i in range(9):
    x,y,z=rnd.randrange(0,32),rnd.randrange(10,31),rnd.randrange(0,32)
    st=rnd.choice([4,12,10]); e.cell(x,y,z,st)
for cx,cz in [(0,0),(1,0),(0,1),(1,1)]: e.chunk_block(cx,cz)
e.run(1)
for (x,y,z),i in e.m.blocks.items():
    if e.m.states[i][0]>0: src[(x,y,z)]=e.m.states[i][0]
best=dijkstra(e.m,src,None)
B9=(-14,45,-4,44,-14,45)
e.probe(1,*B9)
assert e.exp[-1]=="%d/%d"%cks(best,*B9) and cks(best,*B9)[0]>1000
e.run_case(g,'summary 3 (block light): the level at a cell is the maximum over the sources of emission minus the sum of the opacities of the cells entered along a path, never below 0 (checked against an independent shortest-path search over 60 random obstacles of opacity 1, 3 and 15 and 9 emitters)')
e=EScn(1); e.standard(); e.everything((1,2)); e.floor(30)
for x in range(4,10):
    for z in range(4,10): e.cell(x,40,z,2)
e.cell(20,35,20,2); e.cell(21,35,20,11); e.cell(20,36,21,3)
e.fill_all()
for cx,cz in [(0,0),(1,0),(0,1),(1,1)]: e.chunk_sky(cx,cz)
e.run(2)
srcs={}
for cx,cz in [(0,0),(1,0),(0,1),(1,1)]:
    for lx in range(16):
        for lz in range(16):
            ls=e.m.ls[(cx,cz)][lx+16*lz]
            for y in range(max(ls,-16),80): srcs[(cx*16+lx,y,cz*16+lz)]=15
best=dijkstra(e.m,srcs,None)
SB=(0,31,25,60,0,31)
e.probe(2,*SB)
assert e.exp[-1]=="%d/%d"%cks(best,*SB)
e.run_case(g,'summary 3 (sky light): 15 at and above the column lowest source, spreading like block light below it (shortest-path check over a roof, a floor and obstacles of opacity 15, 3 and 1)')
e=f8(sky=1)
for sy in (0,1,2): e.status(1,0,sy,0,0); e.status(2,0,sy,0,0)
e.finish(1); e.finish(2)
e.op("0",'MOVE ALL X"00" TO WS-DATA(1:2048)\nMOVE ALL X"35" TO WS-DATA(2049:2048)\nMOVE ALL X"00" TO WS-DATA(4097:2048)\nMOVE ALL X"21" TO WS-DATA(6145:2048)',None)
arr9=[arr_of(0),arr_of(0x35),arr_of(0),arr_of(0x21)]
e.m.apply_light(0,0,0,0b000011,0b000100,0b000110,0b001000,arr9)
e.op(S(0,0,0,3,4,6,8),'CALL "L32-APPLY-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-DATA',None)
e.run(1); e.run(2)
def pstate(L,p):
    if p not in L.vis: return 0
    return 1 if not any(L.vis[p]) else 2
for k in (1,2):
    for p_ in [(0,-1,0),(0,0,0),(0,1,0),(0,2,0),(0,3,0),(0,4,0),(3,0,3)]:
        e.exp.append(str(pstate(e.m.lay[k-1],p_))); e.op(S(k,*p_),'CALL "L32-PACKET-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
e.run_case(g,'summary 4 (06 section 7): a published layer with all 4096 values 0 is sent through the empty mask, anything else as the 2048-byte array, a section without a layer has no bit; validation 9')
e=f8(sky=0)
for sy in (0,1): e.status(1,0,sy,0,0); e.status(2,0,sy,0,0)
e.finish(1); e.finish(2)
e.op("0",'MOVE ALL X"00" TO WS-DATA(1:2048)\nMOVE ALL X"35" TO WS-DATA(2049:2048)',None)
e.m.apply_light(0,0,0,0b000011,0b000011,0b000000,0b000000,[arr_of(0),arr_of(0x35)])
e.op(S(0,0,0,3,3,0,0),'CALL "L32-APPLY-LIGHT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-DATA',None)
e.run(1)
for k in (1,2):
    for p_ in [(0,0,0),(0,1,0),(0,2,0)]:
        e.exp.append(str(pstate(e.m.lay[k-1],p_) if k==1 else 0)); e.op(S(k,*p_),'CALL "L32-PACKET-STATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1)
e.pub(2,5,5,5); e.pub(2,5,100,5)
e.run_case(g,'validation 7: a dimension without sky light has no sky layer: sky reads 0 everywhere and the sky arrays are absent from packets (no bit in any mask)')
W(g,9)
