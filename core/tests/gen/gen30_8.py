import sys,math,random
from decimal import Decimal as Dc
sys.path.insert(0,'core/tests/gen')
from gen30c import *
class SuiteN(Suite):
    def gen(self,n,subj,tasks,desc,extra=''):
        key=str(n)
        g=Gen('TEST-REDSTONE-30-8-%s'%key.upper(),'30-8§%s'%key,subj,'Test of 30 part 8 section %s, %s (core/src/redstone-30-8.cob; %s): %s'%(key,subj,tasks,desc),extra)
        g.nn=key
        return g
    def write(self,g):
        if not self.only or g.nn in self.only:
            p=OUT+'/test_redstone_30_8_%s.cob'%g.nn
            g.write(p)
            t=open(p).read().replace('PIC -(9)9.','PIC -(10)9.')
            open(p,'w').write(t)
SU=SuiteN(8,'30-8','RS3-','redstone-30-8.cob',sys.argv[1:])
RNG=random.Random(88)
def chunks(rows,model,limit=190):
    out=[];cur=[];ln=0
    for r in rows:
        e=len(show(model(*r)))+1
        if cur and ln+e>limit: out.append(cur);cur=[];ln=0
        cur.append(r);ln+=e
    if cur: out.append(cur)
    return out
_T=T
def T(g,text,call,nout,rows,model):
    cs=chunks(rows,model)
    for k,part in enumerate(cs): _T(g,text+('' if len(cs)==1 else ' (part %d)'%(k+1)),call,nout,part,model)
_TN=TN
def TN(g,text,call,nout,rows,model):
    cs=chunks(rows,model)
    for k,part in enumerate(cs): _TN(g,text+('' if len(cs)==1 else ' (part %d)'%(k+1)),call,nout,part,model)
NAME=" 01 WS-NM                PIC X(40).\n"
TB8=TBL('KD',64)+TBL('DS',64)+TBL('PW',64)
FL8=' 01 WS-FL FLOAT-LONG.\n'
D,U,N,S_,W,E=0,1,2,3,4,5
def isqrt(x): return int(math.isqrt(x))
# ===== 1 Per-block rows
g=SU.gen(1,'Per-block rows','T0818','ids, first states, state counts, delays, registry facts and the signal-source status of the eight blocks.',NAME)
B8=['tripwire_hook','tripwire','sculk_sensor','calibrated_sculk_sensor','sculk_shrieker','bell','tnt','big_dripleaf']
ROW8={'tripwire_hook':(452,11325,16),'tripwire':(453,11341,128),'sculk_sensor':(1118,30520,96),'calibrated_sculk_sensor':(1119,30616,384),'sculk_shrieker':(1123,31131,8),'bell':(938,24162,32),'tnt':(220,3833,2),'big_dripleaf':(1235,33713,32)}
TN(g,'ids (1): tripwire_hook 452 11325 16, tripwire 453 11341 128, sculk_sensor 1118 30520 96, calibrated_sculk_sensor 1119 30616 384, sculk_shrieker 1123 31131 8, bell 938 24162 32, tnt 220 3833 2, big_dripleaf 1235 33713 32 (block id, first state id, states; zeros for another name)','CALL "RS3-BLOCK8-ROW" USING WS-NM WS-R(1) WS-R(2) WS-R(3)',3,[(n,) for n in B8]+[('lever',)],lambda n:ROW8.get(n,(0,0,0)))
DL8={'tripwire_hook':(10,-1,-1),'tripwire':(10,1,-1),'sculk_sensor':(30,10,-1),'calibrated_sculk_sensor':(10,10,-1),'sculk_shrieker':(90,-1,-1),'bell':(-1,-1,-1),'tnt':(-1,-1,-1),'big_dripleaf':(10,10,100)}
TN(g,'delays (1): hook tick 10; tripwire recheck 10 and release 1; sensor active 30 and cooldown 10; calibrated 10 and 10; shrieker 90; bell and TNT none (-1); dripleaf 10, 10, 100 (first, second, third delay)','CALL "RS3-BLOCK8-DELAYS" USING WS-NM WS-R(1) WS-R(2) WS-R(3)',3,[(n,) for n in B8]+[('lever',)],lambda n:DL8.get(n,(-2,-2,-2)))
RG8={'tripwire_hook':(1,0,0),'tripwire':(1,0,0),'sculk_sensor':(0,15,1),'calibrated_sculk_sensor':(0,15,1),'sculk_shrieker':(0,30,0),'bell':(0,50,0),'tnt':(0,0,0),'big_dripleaf':(-1,-1,-1)}
TN(g,'registry facts (1): hook and tripwire no collision; sensor strength 1.5 (tenths 15) and light 1 in every state, the calibrated sensor copies it; shrieker strength 3; bell strength 5; TNT instabreak (0); the dripleaf row is not stated (-1) (collision, strength in tenths, light)','CALL "RS3-BLOCK8-REGISTRY" USING WS-NM WS-R(1) WS-R(2) WS-R(3)',3,[(n,) for n in B8]+[('lever',)],lambda n:RG8.get(n,(-2,-2,-2)))
TN(g,'signal source (1): the hook and both sensors are signal sources in every state; the tripwire, shrieker, bell, TNT and dripleaf are not','CALL "RS3-BLOCK8-SOURCE" USING WS-NM WS-R(1)',1,[(n,) for n in B8],lambda n:(int(n in ('tripwire_hook','sculk_sensor','calibrated_sculk_sensor')),))
SU.write(g)
# ===== 2 Dispatch
g=SU.gen(2,'The game-event dispatch these blocks use','T0820','the scanned section range, the notification radius, the in-range test, delivery, registration and the emitted events.',NAME)
T(g,'section range (2.1 item 3): per axis from blockToSectionCoord(B - r) to blockToSectionCoord(B + r), an arithmetic shift right by 4 (block coordinate, radius; low, high)','CALL "RS3-SECTION-RANGE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(0,16),(0,0),(15,16),(16,16),(17,1),(-1,16),(-17,16),(100,32),(-100,10)],lambda c,r:((c-r)//16,(c+r)//16))
EVR={'jukebox_play':10,'jukebox_stop_play':10,'shriek':32}
TN(g,'notification radius (2.1): 16 for every event except jukebox_play and jukebox_stop_play (10) and shriek (32)','CALL "RS3-EVENT-RADIUS" USING WS-NM WS-R(1)',1,[(n,) for n in ('step','block_activate','jukebox_play','jukebox_stop_play','shriek','explode')],lambda n:(EVR.get(n,16),))
T(g,'in range (2.1 item 4): the block distance squared between the listener and the event is at most the listener radius squared; the event radius only chooses the sections (dx, dy, dz, listener radius)','CALL "RS3-LISTENER-IN-RANGE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(8,0,0,8),(9,0,0,8),(5,5,5,8),(6,6,0,8),(6,6,3,8),(0,16,0,16),(0,0,17,16),(11,11,0,16)],lambda a,b,c,r:(int(a*a+b*b+c*c<=r*r),))
T(g,'delivery (2.1 item 5): a BY_DISTANCE listener is queued and sorted by squared distance, every other listener is called at once; the vibration listener of the sensors and the shrieker overrides nothing (immediate), so the queue never applies to this part (BY_DISTANCE; queued)','CALL "RS3-DELIVERY" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda b:(b,))
T(g,'registration (2.2): a block entity listener sits in the registry of its chunk section, floor(coordinate / 16), and its position is the block centre (block coordinate; section, centre in thousandths)','CALL "RS3-LISTENER-SECTION" USING WS-I(1) WS-R(1)\nCALL "RS3-LISTENER-CENTER" USING WS-I(1) WS-R(2)',2,[(0,),(15,),(16,),(-1,),(-16,),(-17,),(100,)],lambda b:(b//16,b*1000+500))
EM=[(10,0),(9,0),(10,0),(9,0),(6,1),(0,1),(0,1),(11,1),(11,0),(10,2)]
T(g,'events emitted by the blocks (2.3): hook activate 10, deactivate 9, attach 10, detach 9 with no source; shear 6 with the player; sensor tendrils click 0 with the entity; shriek 0 with the player; bell block_change 11 with the ringing entity; dripleaf block_change 11 with none; TNT prime_fuse 10 with the igniter or none (row 1 to 10; frequency, source 0 none 1 given 2 optional)','CALL "RS3-EMIT-ROW" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(0,12)],lambda i:EM[i-1] if 1<=i<=10 else (-1,-1))
SU.write(g)
# ===== 3 Vibration system
g=SU.gen(3,'The vibration system as the sensors use it','T0822','frequencies, strength, travel time, the listener steps, selection, the ticker, validity and occlusion.',NAME+FL8)
FR={}
for f,ns in {1:'step swim flap',2:'projectile_land hit_ground splash bounce',3:'item_interact_finish projectile_shoot instrument_play',4:'entity_action elytra_glide unequip',5:'entity_dismount equip',6:'entity_interact shear entity_mount',7:'entity_damage',8:'drink eat',9:'container_close block_close block_deactivate block_detach',10:'container_open block_open block_activate block_attach prime_fuse note_block_play',11:'block_change',12:'block_destroy fluid_pickup',13:'block_place fluid_place',14:'entity_place lightning_strike teleport',15:'entity_die explode'}.items():
    for n in ns.split(): FR[n]=f
for f in range(1,16): FR['resonate_%d'%f]=f
for n in 'item_interact_start jukebox_play jukebox_stop_play sculk_sensor_tendrils_clicking shriek'.split(): FR[n]=0
assert len(FR)==61
TN(g,'frequency of every game event (3.1): the 41 listed events, resonate_1 to resonate_15 with their own n, and the five events of frequency 0 (item_interact_start, jukebox_play, jukebox_stop_play, sculk_sensor_tendrils_clicking, shriek); a name that is not an event is 0','CALL "RS3-EVENT-FREQ" USING WS-NM WS-R(1)',1,[(n,) for n in FR]+[('not_an_event',)],lambda n:(FR.get(n,0),))
T(g,'event counts (3.1): 61 events, 56 with a non-zero frequency, 41 listed plus 15 resonance events, 5 of frequency 0','CALL "RS3-EVENT-COUNTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(61,56,41,15,5))
T(g,'getResonanceEventByFrequency (3.1): resonate_f is the entry f - 1 of a list of 15 (frequency 1 to 15; -1 outside)','CALL "RS3-RESONANCE-INDEX" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(8,),(15,),(16,)],lambda f:(f-1 if 1<=f<=15 else -1,))
def strength(r,dsq):
    q=(225*dsq)//(r*r)
    return (max(1,15-isqrt(q)),)
ST=[(8,x) for x in (0,1,2,3,4,9,16,25,36,49,64)]+[(16,x) for x in (0,1,4,16,64,256)]
T(g,'strength by block distance (3.2): max(1, 15 - floor((15 / radius) * distance)); radius 8: d 0 gives 15, 1 gives 14, sqrt 2 gives 13, sqrt 3 gives 12, 2 gives 12, 3 gives 10, 4 gives 8, 5 gives 6, 6 gives 4, 7 gives 2, 8 gives 1; radius 16: 0 and 1 give 15, 2 gives 14, 4 gives 12, 8 gives 8, 16 gives 1 (radius, distance squared)','CALL "RS3-STRENGTH" USING WS-I(1) WS-I(2) WS-R(1)',1,ST,strength)
def strm(r,dm): return (max(1,15-(15*dm)//(r*1000)),)
BND=[533,534,1066,1067,1600,1601,2133,2134,2666,2667,3200,3201,3733,3734,4266,4267,4800,4801,5333,5334,5866,5867,6400,6401,6933,6934,7466,7467,7999,8000]
T(g,'strength bands (3.2): the boundaries of the 15 bands 0.533, 1.067, 1.6, 2.133, 2.667, 3.2, 3.733, 4.267, 4.8, 5.333, 5.867, 6.4, 6.933, 7.467 and 8 for radius 8, in thousandths of a block (radius, distance)','CALL "RS3-STRENGTH-MILLI" USING WS-I(1) WS-I(2) WS-R(1)',1,[(8,x) for x in BND],strm)
T(g,'travel time (3.2): floor(distance) ticks for the exact distance between the event position and the listener centre (thousandths of a block per axis): 3.0 gives 3, 0.4 gives 0, sqrt 2 gives 1','CALL "RS3-TRAVEL-TIME" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(3000,0,0),(400,0,0),(1000,1000,0),(0,0,0),(999,0,0),(1000,0,0),(2000,2000,1000),(0,0,16000),(5000,0,-3000)],lambda a,b,c:(isqrt((a*a+b*b+c*c)//1000000),))
def hnd(fl,va,pk,cr,oc):
    if fl: return (0,1)
    if not va: return (0,2)
    if not pk: return (0,3)
    if not cr: return (0,4)
    if oc: return (0,5)
    return (1,0)
T(g,'handleGameEvent (3.3): in order, a vibration in flight, an invalid vibration, an unknown listener position, a refused canReceiveVibration, an occluded path each stop with nothing; otherwise a candidate is added (in flight, valid, position known, can receive, occluded; accepted, failing step)','CALL "RS3-V-HANDLE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,[(1,1,1,1,0),(0,0,1,1,0),(0,1,0,1,0),(0,1,1,0,0),(0,1,1,1,1),(0,1,1,1,0),(1,0,0,0,1),(0,0,0,0,0)],hnd)
def rep(hk,st,nd,kd,nf,kf):
    if not hk: return 1
    if st and nd<kd: return 1
    if st and nd==kd and nf>kf: return 1
    return 0
T(g,'selection (3.4 item 1): a new candidate replaces the kept one when none is kept, or the kept one is from the same tick and the new distance is smaller, or the same tick, equal distances and the new frequency is strictly greater; a candidate of another tick never replaces (V6) (has kept, same tick, new distance, kept distance, new frequency, kept frequency)','CALL "RS3-SELECT-REPLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1,[(0,0,0,0,0,0),(1,1,2,3,1,1),(1,1,3,2,1,1),(1,1,3,3,8,3),(1,1,3,3,3,8),(1,1,3,3,5,5),(1,0,1,9,15,1),(1,0,3,3,8,3)],lambda *a:(rep(*a),))
T(g,'ticker choice (3.4 item 2): with no vibration in flight a candidate counts only when its tick is strictly earlier than the current game time (V7) (has candidate, candidate tick, now, in flight)','CALL "RS3-TICK-CHOOSE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,99,100,0),(1,100,100,0),(0,99,100,0),(1,99,100,1),(1,101,100,0)],lambda h,c,n,f:(int(h and c<n and not f),))
T(g,'travel step (3.4 item 3): the travel time is decremented, not below 0; at 0 or less the vibration is received when the 3 by 3 chunks are loaded and block-ticking, else it waits and retries (travel after the decrement, loaded; received, waits)','CALL "RS3-RECEIVE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(2,1),(1,1),(0,1),(0,0),(-1,1),(3,0)],lambda t,l:(int(t<=0 and l),int(t<=0 and not l)))
T(g,'decrement (3.4 item 3): travel time minus 1, not below 0','CALL "RS3-TRAVEL-DEC" USING WS-I(1) WS-R(1)',1,[(3,),(1,),(0,)],lambda t:(max(0,t-1),))
T(g,'timeline (3.4, 11.1): an event posted in game tick T is chosen in tick T + 1 at the earliest and told in tick T + max(n, 1) for travel time n (V8: distance 0.4 gives T + 1; distance 3.0 gives T + 3) (T, n)','CALL "RS3-NOTIFY-TICK" USING WS-I(1) WS-I(2) WS-R(1)',1,[(100,0),(100,1),(100,3),(100,8)],lambda t,n:(t+max(n,1),))
def vd(it,hs,sp,ca,ig,cav,spl,dm,hb,bd):
    if not it: return (0,0)
    if hs:
        if sp: return (0,0)
        if ca and ig: return (0,int(cav and spl))
        if dm: return (0,0)
    if hb and bd: return (0,0)
    return (1,0)
VR=[(0,0,0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0,0,0),(1,1,1,0,0,0,0,0,0,0),(1,1,0,1,1,1,1,0,0,0),(1,1,0,1,1,1,0,0,0,0),(1,1,0,1,1,0,1,0,0,0),(1,1,0,1,0,1,1,0,0,0),(1,1,0,0,1,1,1,0,0,0),(1,1,0,0,0,0,0,1,0,0),(1,1,0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0,1,1),(1,0,0,0,0,0,0,0,1,0),(1,1,0,0,0,0,0,1,1,1),(1,1,0,0,0,0,0,0,1,1),(1,1,0,1,0,0,0,0,0,0)]
T(g,'isValidVibration (3.5): not listenable gives invalid; a spectator source, a careful (sneaking) source with an event in ignore_vibrations_sneaking (the avoid_vibration advancement fires for a server player when the user can trigger it), a source that dampens vibrations, an affected block state in dampens_vibrations are invalid; otherwise valid (listenable, has source, spectator, careful, event ignored when sneaking, can trigger avoid, server player, source dampens, has block state, block dampens; valid, advancement)','CALL "RS3-VALID" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-I(9) WS-I(10) WS-R(1) WS-R(2)',2,VR,vd)
T(g,'stepping carefully (3.5): the shift key, and for a cat or ocelot also isCrouching (shift, cat or ocelot, crouching)','CALL "RS3-STEPPING-CAREFULLY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a or (b and c)),))
T(g,'dampensVibrations (3.5): the warden, and an item entity whose stack is in the dampens_vibrations item tag (warden, item entity, item in the tag)','CALL "RS3-DAMPENS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a or (b and c)),))
T(g,'occlusion (3.6): occluded only when all six rays meet a block of occludes_vibration_signals; one clear ray lets it through (six ray results)','CALL "RS3-OCCLUDED" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1)',1,[(1,1,1,1,1,1),(1,1,1,1,1,0),(0,1,1,1,1,1),(0,0,0,0,0,0),(1,0,1,0,1,0)],lambda *a:(int(all(a)),))
T(g,'occlusion snapping (3.6): the event and listener positions are snapped to their block centres, floor(coordinate) + 0.5 per axis, in thousandths; the rays start 0.00001 (10000 nanoblocks) from the snapped event centre','CALL "RS3-SNAP-CENTER" USING WS-I(1) WS-R(1)\nCALL "RS3-OCC-CONST" USING WS-R(2)',2,[(0,),(999,),(1000,),(3400,),(-1,),(-1000,),(-1001,),(64250,)],lambda c:((c//1000)*1000+500,10000))
SU.write(g)
# ===== 4 Sculk sensor
g=SU.gen(4,'Sculk sensor block','T0824','phases, activate, the tick, the other block rules, the user, the signals and the comparator.',NAME+FL8)
TN(g,'phases (4.1): inactive 0, active 1, cooldown 2 (serialized names)','CALL "RS3-PHASE-ORDINAL" USING WS-NM WS-R(1)',1,[(n,) for n in ('inactive','active','cooldown','other')],lambda n:({'inactive':0,'active':1,'cooldown':2}.get(n,-1),))
T(g,'canActivate (4.1): true only in the inactive phase (phase)','CALL "RS3-PHASE-CAN-ACTIVATE" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(2,)],lambda p:(int(p==0),))
T(g,'activate (4.2): phase active, a tick after the active ticks (30, calibrated 10), neighbours of the position and the position below told, the tendrils-clicking event posted, sculk_clicking played when not waterlogged (calibrated, waterlogged; phase, delay, neighbours, event, clicking sound)','CALL "RS3-SENSOR-ACTIVATE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(c,w) for c in (0,1) for w in (0,1)],lambda c,w:(1,10 if c else 30,1,1,int(not w)))
NOTE=[0,0,2,4,6,7,9,10,12,14,15,18,19,21,22,24]
T(g,'resonance (4.2 step 4): note by frequency {0, 0, 2, 4, 6, 7, 9, 10, 12, 14, 15, 18, 19, 21, 22, 24} and pitch 2^((note - 12) / 12) in millionths: frequency 1 gives 0.5, 8 gives 1.0, 15 gives 4.0 (V16) (frequency; note, pitch)','CALL "RS3-RESONANCE-NOTE" USING WS-I(1) WS-R(1) WS-R(2)',2,[(f,) for f in range(1,16)],lambda f:(NOTE[f],round(2**((NOTE[f]-12)/12)*1000000)))
g.case('click pitch (4.2 step 6, 4.3): random.nextFloat() * 0.2 + 0.8 (millionths)',[(r,'CALL "RS3-CLICK-PITCH" USING WS-FX(1) WS-R(1)',1) for r in ('0.0','0.5','0.999','0.25')]," ".join(str(int((Dc(r)*Dc('0.2')+Dc('0.8'))*1000000+Dc('0.5'))) for r in ('0.0','0.5','0.999','0.25')))
def stk(p,w):
    if p==1: return (2,10,1,0)
    if p==2: return (0,-1,0,int(not w))
    return (0,-1,0,0)
T(g,'block tick (4.3): active becomes cooldown with power 0, a tick after 10 and the neighbours told; cooldown becomes inactive and plays sculk_clicking_stop when not waterlogged; inactive nothing (phase, waterlogged; new phase, delay, neighbours, stop sound)','CALL "RS3-SENSOR-TICK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(p,w) for p in (0,1,2) for w in (0,1)],lambda p,w:stk(p,w) if p!=0 else (0,-1,0,0))
T(g,'deaf period (4.3, V15): active ticks plus the cooldown of 10, 40 for the sensor and 20 for the calibrated sensor','CALL "RS3-SENSOR-DEAF" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda c:(20 if c else 40,))
T(g,'waterlogging (4.4): the fluid state is the source water when waterlogged and updateShape schedules a water tick (waterlogged; fluid, tick)','CALL "RS3-SENSOR-WATER" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda w:(w,w))
T(g,'onPlace (4.4): on the server, for a previous block that is not this one, power above 0 with no scheduled tick sets power 0 with flags 18 (server, old is this block, power, tick scheduled; clear, flags)','CALL "RS3-SENSOR-ON-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(s,o,p,t) for s in (0,1) for o in (0,1) for p in (0,5) for t in (0,1)],lambda s,o,p,t:(1,18) if s and not o and p>0 and not t else (0,0))
T(g,'affectNeighborsAfterRemoval (4.4): when the removed phase was active the neighbours are told (phase)','CALL "RS3-SENSOR-REMOVED" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(2,)],lambda p:(int(p==1),))
T(g,'stepOn (4.4): on the server, can activate, the entity is not a warden, a block entity exists and canReceiveVibration holds: forceScheduleVibration, bypassing the tag, sneaking and occlusion checks; the step frequency is 1 (server, can activate, warden, block entity, can receive; forces, frequency)','CALL "RS3-SENSOR-STEP-ON" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2)',2,[(1,1,0,1,1),(0,1,0,1,1),(1,0,0,1,1),(1,1,1,1,1),(1,1,0,0,1),(1,1,0,1,0)],lambda s,c,w,b,r:(int(s and c and not w and b and r),1))
T(g,'xp (4.4): a sensor broken with drops gives 5 experience','CALL "RS3-SENSOR-XP" USING WS-R(1)',1,[(0,)],lambda x:(5,))
def scr(sp,dp,f,ca):
    if sp and dp: return (0,)
    if f==0: return (0,)
    return (ca,)
T(g,'canReceiveVibration (4.5): false when the position is the sensor own block and the event is block_destroy or block_place; false when the frequency is 0; else canActivate (own block, destroy or place, frequency, can activate)','CALL "RS3-SENSOR-CAN-RECEIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,1,12,1),(1,0,12,1),(0,1,13,1),(0,0,0,1),(0,0,1,1),(0,0,1,0),(1,1,0,1)],scr)
T(g,'onReceiveVibration (4.5): when the state can still activate: store the frequency, strength by 3.2 from the block distance squared and the radius, activate (can activate, frequency, distance squared, radius; activates, stored frequency, strength; example 11.1 gives 10)','CALL "RS3-SENSOR-RECEIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,[(1,1,9,8),(1,5,0,8),(0,5,9,8),(1,15,64,8),(1,6,16,16)],lambda c,f,d,r:(1,f,strength(r,d)[0]) if c else (0,0,0))
T(g,'signals (4.6): weak power toward every neighbour, strong power only when asked with UP (power, direction data value, query 0 getSignal 1 getDirectSignal; signal)','CALL "RS3-SENSOR-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(10,d,q) for d in (U,N,D) for q in (0,1)],lambda p,d,q:(p if q==0 or d==U else 0,))
T(g,'comparator (4.7): while the phase is active and the block entity exists the last vibration frequency, else 0 (V1) (phase, block entity, last frequency)','CALL "RS3-SENSOR-ANALOG" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,1,1),(1,0,1),(0,1,9),(2,1,9),(1,1,15)],lambda p,b,f:(f if p==1 and b else 0,))
T(g,'worked example 11.1 (11): sensor radius 8 hears a step 3 blocks away: strength 10 (distance squared 9), the active phase for 30 ticks and the inactive phase 40 ticks after the activation tick (V1)','CALL "RS3-STRENGTH" USING WS-I(1) WS-I(2) WS-R(1)\nCALL "RS3-SENSOR-DEAF" USING WS-I(3) WS-R(2)',2,[(8,9,0)],lambda a,b,c:(10,40))
SU.write(g)
# ===== 5 Calibrated sculk sensor
g=SU.gen(5,'Calibrated sculk sensor','T0826','radius and ticks, the back input, the frequency filter and the output side.')
T(g,'constants (5, 4.1): listener radius 8 (calibrated 16), active ticks 30 (calibrated 10), cooldown 10 (calibrated, radius, active ticks, cooldown)','CALL "RS3-SENSOR-CONST" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(0,),(1,)],lambda c:(16,10,10) if c else (8,30,10))
T(g,'back side (5): the signal is read from pos.relative(opp(facing)), the side toward the placer (facing data value; back direction)','CALL "RS3-CAL-BACK" USING WS-I(1) WS-R(1)',1,[(N,),(S_,),(W,),(E,)],lambda f:(opp(f),))
def ccr(b,f,p):
    if b!=0 and f!=b: return (0,)
    return (p,)
T(g,'canReceiveVibration (5): with back = 0 every non-zero frequency is accepted; with back = n only events of frequency n; the plain sensor rule still applies (V12: back 6 accepts 6 and rejects 5) (back signal, frequency, plain rule)','CALL "RS3-CAL-CAN-RECEIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(0,1,1),(0,15,1),(6,6,1),(6,5,1),(6,10,1),(6,1,1),(0,0,0),(6,6,0)],ccr)
def csg(p,f,d,q):
    if q==0: return (0 if d==f else p,)
    return (p if d==U else 0,)
T(g,'output side (5, V13): getSignal is 0 when the direction equals facing (the back receives nothing), else the power; getDirectSignal is inherited, UP only (power, facing, direction, query 0 getSignal 1 getDirectSignal)','CALL "RS3-CAL-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(8,N,N,0),(8,N,S_,0),(8,N,E,0),(8,N,U,0),(8,N,U,1),(8,N,N,1),(8,N,D,1)],csg)
T(g,'radius 16 strength (5, V3): distance 0 or 1 gives 15, 4 gives 12, 8 gives 8, 16 gives 1 (radius, distance squared)','CALL "RS3-STRENGTH" USING WS-I(1) WS-I(2) WS-R(1)',1,[(16,0),(16,1),(16,16),(16,64),(16,256)],strength)
g.case('worked example 11.2 (11): calibrated sensor facing south, a repeater behind it outputs 6: shear (6), entity_mount (6) and entity_interact (6) pass, step (1) and block_open (10) do not; with the repeater off every non-zero frequency passes',[("6 %d 1"%f,'CALL "RS3-CAL-CAN-RECEIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1) for f in (6,6,6,1,10)]+[("0 %d 1"%f,'CALL "RS3-CAL-CAN-RECEIVE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1) for f in (1,10)],"1 1 1 0 0 1 1")
SU.write(g)
# ===== 6 Sculk shrieker
g=SU.gen(6,'Sculk shrieker','T0828','state, listening, the player of a vibration, tryShriek, the tick, tryRespond and the constants.')
T(g,'canReceiveVibration (6.2): the block must not be shrieking, then the plain rule (shrieking, plain rule)','CALL "RS3-SHRIEKER-CAN-RECEIVE" USING WS-I(1) WS-I(2) WS-R(1)',1,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(int(not a and b),))
def tp(a,b,c,d):
    if a: return (1,)
    if b: return (2,)
    if c: return (3,)
    if d: return (4,)
    return (0,)
T(g,'tryGetPlayer (6.2): the entity itself when it is a server player; else the controlling passenger of a vehicle when a player; else the owner of a projectile when a player; else the owner of an item entity when a player (self, vehicle passenger, projectile owner, item owner; 0 none)','CALL "RS3-TRY-PLAYER" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[tuple((i>>k)&1 for k in range(4)) for i in range(16)],tp)
T(g,'reaction player (6.2): the projectile owner when one is given, else the source entity (has projectile owner; 1 source entity, 2 projectile owner)','CALL "RS3-REACTION-PLAYER" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda p:(2 if p else 1,))
T(g,'stepOn (6.2): on the server, when tryGetPlayer finds a player and the block entity exists, tryShriek at once with no vibration and no travel (server, found a player, block entity; shrieks now)','CALL "RS3-SHRIEKER-STEP-ON" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(a&b&c,))
T(g,'canRespond (6.3): can_summon and the difficulty not peaceful and the game rule spawn_wardens (can summon, peaceful, rule)','CALL "RS3-CAN-RESPOND" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a and not b and c),))
def shr(hp,sh,cs,pe,ru,tw):
    if not hp or sh: return (0,0)
    cr=cs and not pe and ru
    if cr and not tw: return (0,1)
    return (1,1)
T(g,'tryShriek (6.3): nothing without a player or when already shrieking; warning_level set to 0; when canRespond the warden-spawn tracker is asked and a refusal stops without shrieking; V17: can_summon false still shrieks with no warden logic (has player, shrieking, can summon, peaceful, spawn_wardens rule, tracker warns; shrieks, warning reset)','CALL "RS3-TRY-SHRIEK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-R(1) WS-R(2)',2,[(1,0,0,0,1,1),(1,0,1,0,1,1),(1,0,1,0,1,0),(1,0,1,1,1,1),(1,0,1,0,0,1),(0,0,1,0,1,1),(1,1,1,0,1,1)],shr)
T(g,'shriek (6.3 step 4): shrieking true (flags 2), a block tick after 90, level event 3007 with data 0, the event shriek (frequency 0) with the player as source (ticks, level event, event frequency, flags)','CALL "RS3-SHRIEK-EFFECT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(90,3007,0,2))
T(g,'block tick (6.4): shrieking becomes false (setBlockAndUpdate) then tryRespond runs; breaking a shrieking block runs tryRespond once before removal (shrieking; new shrieking, responds)','CALL "RS3-SHRIEKER-TICK" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda s:(0,s))
RP={1:1,2:2,3:3,4:4}
def rsp(cr,wl,lv,sp):
    if not (cr and wl>0): return (0,0,0)
    tried=int(lv>=4)
    reply=RP.get(lv,0) if not sp else 0
    return (tried,reply,1)
T(g,'tryRespond (6.4): when canRespond and warning_level above 0: try to summon a warden (level at least 4); when it does not spawn play the reply sound of the level (1 warden_nearby_close, 2 closer, 3 closest, 4 listening_angry); then the darkness effect around the block centre (can respond, warning level, level, spawned; summon tried, reply sound, darkness)','CALL "RS3-RESPOND" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3)',3,[(1,1,1,0),(1,2,2,0),(1,3,3,0),(1,4,4,0),(1,4,4,1),(1,5,5,0),(1,0,1,0),(0,3,3,0)],rsp)
T(g,'break (6.4): a shrieking block runs tryRespond once before removal (shrieking; runs)','CALL "RS3-SHRIEKER-BREAK" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda s:(s,))
T(g,'constants (6.1, 6.4): 8 states, listener radius 8, 5 experience when broken with drops, SpawnUtil arguments 20, 5, 6, reply offset 10, reply volume 5, darkness radius 40 (states, radius, xp, spawn a, b, c, offset, volume, darkness)','CALL "RS3-SHRIEKER-CONST" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7) WS-R(8) WS-R(9)',9,[(0,)],lambda x:(8,8,5,20,5,6,10,5,40))
SU.write(g)
# ===== 7 Tripwire and hook
g=SU.gen(7,'Tripwire and tripwire hook','T0830','shapes, support, signals, the line calculation, the transition effects, the wire detection, shears and removal.',NAME+TB8+FL8)
HS={N:(5,11,0,10,10,16),S_:(5,11,0,10,0,6),E:(0,6,0,10,5,11),W:(10,16,0,10,5,11)}
T(g,'hook shape (7.1): for facing north x 5 to 11, y 0 to 10, z 10 to 16 (pixels, the box on the support side; the other facings follow the support block at pos - facing) (facing; min x, max x, min y, max y, min z, max z)','CALL "RS3-HOOK-SHAPE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,[(f,) for f in (N,S_,W,E)],lambda f:HS[f])
def hpl(*a):
    for i in range(4):
        if a[2*i+1]: return (opp(a[2*i]),)
    return (-1,)
T(g,'hook placement (7.1): of the horizontal directions in the placer nearest-looking order the first d for which facing = opp(d) survives; none: not placeable -1 (d1 ok1 d2 ok2 d3 ok3 d4 ok4)','CALL "RS3-HOOK-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-I(8) WS-R(1)',1,[(N,1,E,1,S_,1,W,1),(N,0,E,1,S_,1,W,1),(S_,0,N,0,E,0,W,1),(E,0,W,0,N,0,S_,0),(W,1,N,0,S_,0,E,0)],hpl)
T(g,'hook updateShape (7.1): when the changed direction is opp(facing) and the hook cannot survive it becomes air (facing, direction, survives; air)','CALL "RS3-HOOK-UPDATE-SHAPE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(N,S_,0),(N,S_,1),(N,N,0),(N,E,0)],lambda f,d,s:(int(d==opp(f) and not s),))
T(g,'wire shape (7.1): column(16, 1, 2.5) when attached, column(16, 0, 8) when not, in tenths of a pixel (attached; min y, max y)','CALL "RS3-WIRE-SHAPE" USING WS-I(1) WS-R(1) WS-R(2)',2,[(1,),(0,)],lambda a:(10,25) if a else (0,80))
T(g,'wire sides (7.1): side d is true when the neighbour in d is a hook with facing == opp(d) or another wire (neighbour 0 other 1 hook 2 wire, hook facing, direction)','CALL "RS3-WIRE-SIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(0,N,N),(1,S_,N),(1,N,N),(1,W,E),(1,E,E),(2,N,N),(2,E,S_)],lambda k,hf,d:(int(k==2 or (k==1 and hf==opp(d))),))
def wrot(n,e,s,w,r):
    if r==0: return (n,e,s,w)
    if r==1: return (w,n,e,s)
    if r==2: return (s,w,n,e)
    return (e,s,w,n)
T(g,'rotate (7.1): the four sides permute; clockwise 90 turns the north side into the east side (north, east, south, west, rotation 0 none 1 CW 90 2 180 3 CCW 90)','CALL "RS3-WIRE-ROTATE" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(1,0,0,0,r) for r in range(4)]+[(1,1,0,0,1),(0,1,1,0,3)],wrot)
def wmir(n,e,s,w,m):
    if m==1: return (s,e,n,w)
    if m==2: return (n,w,s,e)
    return (n,e,s,w)
T(g,'mirror (7.1): left-right swaps the north and south sides, front-back the east and west sides (north, east, south, west, mirror 0 none 1 left-right 2 front-back)','CALL "RS3-WIRE-MIRROR" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(1,0,0,1,m) for m in range(3)],wmir)
def hsig(p,f,d,q):
    if q==0: return (15 if p else 0,)
    return (15 if p and d==f else 0,)
T(g,'signals (7.2): the hook is a signal source with weak 15 to every direction while powered; getDirectSignal is 15 only when powered and the direction equals facing (powered, facing, direction, query 0 getSignal 1 getDirectSignal)','CALL "RS3-HOOK-SIGNAL" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(p,N,d,q) for p in (0,1) for d in (N,S_,U) for q in (0,1)],hsig)
def calc(valid,removing,c,Wd,Wp,wasA,wasP,cells):
    if not valid: return (0,wasA,wasP,0,0)
    attached=0 if removing else 1; anyp=0; sched=0; Dd=0
    for k in range(1,42):
        kind,dis,pw=cells[k-1]
        if kind==2: Dd=k; break
        if kind==3: Dd=0; break
        if kind==1 or k==c:
            if k==c: dis,pw=Wd,Wp
            armed=not dis
            if armed and pw: anyp=1
            if k==c:
                sched=1
                if not armed: attached=0
        else: attached=0
    attached=int(attached and Dd>1)
    return (1,attached,int(anyp and attached),Dd,sched)
def line(wires,far=True,gap=None,wire_pow=(),dis=()):
    cells=[(0,0,0)]*41
    for k in range(1,wires+1): cells[k-1]=(1,int(k in dis),int(k in wire_pow))
    if gap: cells[gap-1]=(0,0,0)
    if far: cells[wires]=(2,0,0)
    return cells
def lcall(valid,removing,c,Wd,Wp,wasA,wasP,cells):
    return (setarr('KD',[x[0] for x in cells]+[0]*23)+setarr('DS',[x[1] for x in cells]+[0]*23)+setarr('PW',[x[2] for x in cells]+[0]*23)+
            'MOVE %d TO WS-I(1)\nMOVE %d TO WS-I(2)\nMOVE %d TO WS-I(3)\nMOVE %d TO WS-I(4)\nMOVE %d TO WS-I(5)\nMOVE %d TO WS-I(6)\nMOVE %d TO WS-I(7)\n'%(valid,removing,c,Wd,Wp,wasA,wasP)+
            'CALL "RS3-HOOK-CALC" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-I(6) WS-I(7) WS-KDG WS-DSG WS-PWG WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)')
def cc(text,rows):
    calls=[];exp=[]
    for r in rows:
        valid,removing,c,Wd,Wp,wasA,wasP,cells=r
        calls.append(("0",lcall(*r),5)); exp.append("/".join(str(x) for x in calc(*r)))
    g.case(text,calls," ".join(exp))
# worked example 11.3: hook A at P facing east, wires P+1..P+3, hook B at P+4; an entity enters P+2 (c = 2, W powered armed)
L3=line(3,True)
cc('calculation, example 11.3 (11): hooks 4 apart with 3 wires, an entity powers the wire at distance 2: attached and powered, D 4, a tick scheduled',[(1,0,2,0,1,1,0,L3),(1,0,-1,0,0,1,1,[(1,0,0)]*0+L3)])
cc('calculation, idle line (7.3): no changed cell, nothing powered: attached stays true and powered false; the hook tick refresh finds the same state',[(1,0,-1,0,0,1,0,L3),(1,0,-1,0,0,0,0,L3)])
cc('calculation, V18 (12): 40 wires between the hooks (hooks 41 apart) are attached; with 41 wires the scan ends at k = 41 without finding the far hook: D 0',[(1,0,-1,0,0,1,0,line(40,True)),(1,0,-1,0,0,1,0,line(41,False))])
cc('calculation, gaps and disarmed wires (7.3 step 4): a gap does not end the scan but clears attached and powered; a disarmed changed cell clears attached; a far hook facing the wrong way ends it with D 0',[(1,0,-1,0,0,1,1,line(3,True,gap=2,wire_pow=(2,))),(1,0,2,1,0,1,0,L3),(1,0,2,0,1,1,0,[(1,0,0)]*0+[(1,0,0),(1,0,0),(1,0,0),(3,0,0)]+[(0,0,0)]*37),(1,0,-1,0,0,1,0,[(3,0,0)]+[(0,0,0)]*40)])
cc('calculation, removing and the guard (7.3): removing starts attached false; a state without a readable facing is a no-op; a hook adjacent to the far hook has D 1 so attached false',[(1,1,-1,0,0,1,1,L3),(0,0,2,0,1,1,0,L3),(1,0,-1,0,0,1,0,line(0,True))])
cc('cut with shears, example 11.4 (11): the removed wire passes as a disarmed changed cell: attached false and powered false, no pulse; a plain cut passes it powered and armed: attached and powered true, a tick scheduled; the tick finds the gap: both false',[(1,0,2,1,0,1,0,L3),(1,0,2,0,1,1,0,L3),(1,0,-1,0,0,1,1,line(3,True,gap=2,wire_pow=(1,3)))])
def hw(Dd,rem,notify,att,wa):
    return (int(Dd>0),int(Dd>0),int(not rem),int(not rem and notify),max(0,Dd-1) if att!=wa else 0)
T(g,'writes (7.3): the far hook is written and notified when D > 0; the near hook is written when not removing and notified when notify is set; when attached changed the wires between are rewritten, D - 1 cells (D, removing, notify, attached, was attached; write far, notify far, write near, notify near, cells)','CALL "RS3-HOOK-WRITES" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(4,0,1,1,1),(4,0,1,1,0),(4,0,0,0,1),(0,0,1,0,0),(4,1,1,0,1),(1,0,0,1,0),(0,1,0,0,1)],hw)
def emit(a,p,wa,wp):
    if p and not wp: return (1,600000,1,400000)
    if not p and wp: return (2,500000,2,400000)
    if a and not wa: return (3,700000,3,400000)
    if not a and wa: return (4,0,4,400000)
    return (0,0,0,0)
T(g,'transition effects (7.4): exactly one, first match: powered rose (click_on volume 0.4 pitch 0.6, block_activate), powered fell (click_off 0.5, block_deactivate), attached rose (attach 0.7, block_attach), attached fell (detach, pitch 1.2 / (nextFloat * 0.2 + 0.9), block_detach) (attached, powered, was attached, was powered; kind, pitch, event, volume in millionths)','CALL "RS3-HOOK-EMIT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(a,p,wa,wp) for a in (0,1) for p in (0,1) for wa in (0,1) for wp in (0,1)],emit)
g.case('detach pitch (7.4): 1.2 / (random.nextFloat() * 0.2 + 0.9), between 1.0909 and 1.3333 (millionths)',[(r,'CALL "RS3-DETACH-PITCH" USING WS-FX(1) WS-R(1)',1) for r in ('0.0','0.5','0.25','0.999')]," ".join(str(int(Dc('1.2')/(Dc(r)*Dc('0.2')+Dc('0.9'))*1000000+Dc('0.5'))) for r in ('0.0','0.5','0.25','0.999')))
T(g,'entityInside (7.5): on the server, only when the wire is not powered and no tick is scheduled, checkPressed runs (server, powered, tick scheduled; runs)','CALL "RS3-WIRE-INSIDE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],lambda a,b,c:(int(a and not b and not c),))
def wchk(pr,pw): return (int(pr!=pw),pr,int(pr!=pw),10 if pr else (1 if pw else 0))
T(g,'checkPressed (7.5): when pressed differs from powered set powered and run updateSource; then a pressed wire schedules a tick after 10, a wire that was powered schedules after 1 (pressed, powered; write, powered, update source, tick delay)','CALL "RS3-WIRE-CHECK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(a,b) for a in (0,1) for b in (0,1)],wchk)
T(g,'scheduled tick (7.5): nothing when the wire is not powered, else the entities overlapping the wire are gathered and checkPressed runs (V19) (powered; gathers)','CALL "RS3-WIRE-TICK" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda p:(p,))
IGN=('display','interaction','marker','ominous_item_spawner','bat')
TN(g,'entities that never trigger (7.5): Display, Interaction, Marker, OminousItemSpawner, Bat and an ArmorStand that is a marker; every other entity triggers (name, marker flag; ignores)','CALL "RS3-IGNORES-TRIGGERS" USING WS-NM WS-I(1) WS-R(1)',1,[(n,0) for n in IGN]+[('armor_stand',1),('armor_stand',0),('player',0),('zombie',0),('item',0),('experience_orb',0),('arrow',0),('boat',0)],lambda n,m:(int(n in IGN or (n=='armor_stand' and m==1)),))
T(g,'pressed (7.5): at least one entity in the list that does not ignore block triggers (triggering entities)','CALL "RS3-WIRE-PRESSED" USING WS-I(1) WS-R(1)',1,[(0,),(1,),(3,)],lambda n:(int(n>0),))
T(g,'removal state (7.5): updateSource gets the removed state with powered forced true and the disarmed flag kept (disarmed; disarmed, powered)','CALL "RS3-WIRE-REMOVAL-STATE" USING WS-I(1) WS-R(1) WS-R(2)',2,[(0,),(1,)],lambda d:(d,1))
def scan(kinds):
    for i in range(1,42):
        k=kinds[i-1]
        if k==2: return (i,)
        if k!=1: return (0,)
    return (0,)
def scall(kinds): return setarr('KD',list(kinds)+[0]*(64-len(kinds)))+'CALL "RS3-SOURCE-SCAN" USING WS-KDG WS-R(1)'
SC=[[1,1,2],[2],[1,3],[0],[1,1,0,2],[3],[1]*40+[2],[1]*41+[2],[1]*41]
g.case('updateSource scan (7.5): along one direction a wire continues, a hook facing the wire ends with its index i (1 to 41), a hook facing otherwise or any other block ends with none',[("0",scall(k),1) for k in SC]," ".join(str(scan(k)[0]) for k in SC))
T(g,'shears (7.5): on a server with shears in the main hand the wire is set disarmed with flags 260, the event shear (frequency 6) is posted, then the normal destruction (server, shears; disarms, flags, event frequency)','CALL "RS3-WIRE-SHEARS" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(a,b) for a in (0,1) for b in (0,1)],lambda a,b:(1,260,6) if a and b else (0,0,0))
T(g,'notifying neighbours (7.6): the neighbours of the position, then the neighbours of pos.relative(opp(direction)), with the hook block as source (direction; second block direction)','CALL "RS3-NOTIFY-SECOND" USING WS-I(1) WS-R(1)',1,[(N,),(S_,),(W,),(E,)],lambda d:(opp(d),))
T(g,'hook removal (7.7): a removed hook that was attached or powered runs the calculation with removing true and notify false; when it was powered its old neighbours are notified (attached, powered; calculation, notify)','CALL "RS3-HOOK-REMOVAL" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(a,p) for a in (0,1) for p in (0,1)],lambda a,p:(int(a or p),p))
HC={1:(0,0,0),2:(0,1,0),3:(0,1,1),4:(1,0,0)}
T(g,'callers (7.3): placement (removing false, notify false, no changed cell), the hook tick (notify true), a wire updateSource (notify true, changed cell c), the removal handler (removing true) (caller 1 to 4; removing, notify, has changed cell)','CALL "RS3-HOOK-CALLER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(c,) for c in (1,2,3,4)],lambda c:HC[c])
SU.write(g)
# ===== 8 Bell
g=SU.gen(8,'Bell','T0832','attachments, the hit rule, ring sources, attemptToRing, the block entity timers and resonance.',NAME+FL8)
TN(g,'attachments (8.1): floor 0, ceiling 1, single_wall 2, double_wall 3 (serialized names)','CALL "RS3-BELL-ATTACHMENT" USING WS-NM WS-R(1)',1,[(n,) for n in ('floor','ceiling','single_wall','double_wall','wall')],lambda n:({'floor':0,'ceiling':1,'single_wall':2,'double_wall':3}.get(n,-1),))
def ax(d): return 'y' if d in (D,U) else 'z' if d in (N,S_) else 'x'
def hit(at,f,face,rel):
    if face in (D,U): return 0
    if rel>Dc('0.8123999834060669'): return 0
    if at==0: return int(ax(face)==ax(f))
    if at in (2,3): return int(ax(face)!=ax(f))
    return 1
HR8=[(0,N,E,'0.5'),(0,N,N,'0.5'),(0,N,S_,'0.5'),(0,N,W,'0.5'),(0,N,N,'0.85'),(0,N,N,'0.8123999834060669'),(0,N,N,'0.8124'),(0,N,U,'0.1'),(0,N,D,'0.1'),(1,N,E,'0.5'),(1,N,U,'0.5'),(2,N,E,'0.5'),(2,N,N,'0.5'),(3,E,N,'0.5'),(3,E,E,'0.5'),(1,E,W,'0.9')]
g.case('hit rule (8.2, V21): not the top or bottom face; relative y not greater than 0.8123999834060669 (strict); floor needs the axis of the face equal to the axis of facing, single and double wall differ, ceiling always; a floor bell facing north rings from north and south, not east or west; north at 0.85 does not',[(S(att,f,face)+" "+rel,'CALL "RS3-BELL-HIT" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-R(1)',1) for att,f,face,rel in HR8]," ".join(str(hit(att,f,face,Dc(rel))) for att,f,face,rel in HR8))
T(g,'onHit (8.3): the hit counts only when isProperHit with check true (both call sites); a counted hit that rang with a known player awards the bell_ring statistic (check, proper hit, rang, player; counted, statistic)','CALL "RS3-BELL-ON-HIT" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1) WS-R(2)',2,[(1,1,1,1),(1,0,1,1),(1,1,1,0),(1,1,0,1),(0,0,1,1),(0,0,1,0)],lambda c,p,r,pl:(int(p or not c),int((p or not c) and r and pl)))
T(g,'use result (8.3): SUCCESS (1) when the hit counted, else PASS (0)','CALL "RS3-BELL-USE-RESULT" USING WS-I(1) WS-R(1)',1,[(0,),(1,)],lambda c:(c,))
BS={1:(1,0),2:(1,0),3:(0,1),4:(0,1)}
T(g,'ring sources (8.3): use without item and a projectile hit call onHit with check true; an explosion that can trigger blocks and a redstone edge ring with no direction (source 1 use, 2 projectile, 3 explosion, 4 redstone; check, no direction)','CALL "RS3-BELL-SOURCE" USING WS-I(1) WS-R(1) WS-R(2)',2,[(k,) for k in (1,2,3,4)],lambda k:BS[k])
def rng(sv,be,hd,f,d):
    if not (sv and be): return (0,0,0,0)
    return (1,d if hd else f,2000000,11)
T(g,'attemptToRing (8.3): only on a server level with a bell block entity; the direction is the state facing when absent; the block entity onHit, the sound bell_block at volume 2.0 and pitch 1.0 (millionths), block_change posted (frequency 11) with the ringing entity (server, block entity, direction given, facing, direction; rang, direction used, volume, event frequency)','CALL "RS3-BELL-RING" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(1,1,0,N,0),(1,1,1,N,E),(0,1,1,N,E),(1,0,1,N,E)],rng)
def brs(s,p):
    if s!=p: return (s,s)
    return (0,p)
T(g,'redstone (8.3, V22, 11.5): the signal differing from powered rings on the rising edge only; powered then follows the signal; the falling edge only clears powered (signal, powered; rings, new powered)','CALL "RS3-BELL-REDSTONE" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2)',2,[(1,0),(1,1),(0,1),(0,0)],brs)
T(g,'constants (8.4): shake duration 50, resonance delay 5, resonance length 40, search radius 48, hear radius 32, glow duration 60, refresh interval 60','CALL "RS3-BELL-CONST" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)',7,[(0,)],lambda x:(50,5,40,48,32,60,60))
T(g,'onHit of the entity (8.4): when already shaking ticks restart at 0, else shaking starts; the block event type 1 with the direction value is queued (shaking, ticks; new ticks, shaking, event type)','CALL "RS3-BELL-HIT-ENTITY" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(0,0),(1,20),(1,49)],lambda s,t:(0 if s else t,1,1))
T(g,'triggerEvent (8.4): ticks 0, resonationTicks 0, shaking true and the direction from the value (value; ticks, resonation ticks, shaking, direction)','CALL "RS3-BELL-TRIGGER" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(N,),(E,)],lambda v:(0,0,1,v))
T(g,'entity list refresh (8.4): when the game time is greater than lastRingTimestamp + 60 or there is no cached list it is rebuilt (game time, last ring, has list; rebuild)','CALL "RS3-BELL-REFRESH" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(161,100,1),(160,100,1),(100,100,0),(1000,100,1)],lambda t,l,h:(int(t>l+60 or not h),))
T(g,'heard bell (8.4): every cached entity that is alive, not removed and closer than 32 to the block centre gets heard_bell_time (alive, removed, distance squared in blocks; sets)','CALL "RS3-BELL-HEARS" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,[(1,0,1023),(1,0,1024),(0,0,10),(1,1,10),(1,0,0)],lambda a,r,d:(int(a and not r and d<1024),))
def btick(sh,t,rs,rt,rd):
    if sh: t+=1
    if t>=50: sh=0;t=0
    snd=0;end=0
    if t>=5 and rt==0 and rd: rs=1;snd=1
    if rs:
        if rt<40: rt+=1
        else: end=1;rs=0
    return (sh,t,rs,rt,snd,end)
BT=[(1,0,0,0,0),(1,4,0,0,1),(1,5,0,0,0),(1,49,0,0,0),(0,0,0,0,1),(1,10,0,0,1),(1,10,1,5,1),(1,10,1,39,1),(1,10,1,40,1),(0,0,1,40,0),(1,12,0,3,1),(1,4,0,0,0)]
T(g,'tick (8.4, V23): ticks + 1 while shaking; at 50 shaking false and ticks 0; at 5 or more ticks with resonationTicks 0 and a raider within 32 resonance starts (bell_resonate); while resonating the counter rises to 40 and then the end action runs (shaking, ticks, resonating, resonation ticks, raider near; shaking, ticks, resonating, resonation ticks, resonate sound, end action)','CALL "RS3-BELL-TICK" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-I(5) WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6)',6,BT,btick)
T(g,'end action (8.4, V23): every raider that is alive, not removed, tagged raiders and closer than 48 gets glowing for 60 ticks (alive, removed, raider, distance squared; glows)','CALL "RS3-BELL-GLOW" USING WS-I(1) WS-I(2) WS-I(3) WS-I(4) WS-R(1)',1,[(1,0,1,2303),(1,0,1,2304),(0,0,1,10),(1,1,1,10),(1,0,0,10)],lambda a,r,rd,d:(int(a and not r and rd and d<2304),))
SU.write(g)
# ===== 9 Catch-all
g=SU.gen(9,'Catch-all','T0834','the TNT block rows, the big dripleaf tilt machine and the pointers for the other readers.',NAME+FL8)
T(g,'TNT block (9.1): unstable default false, 2 states, never a signal source (0), never a redstone conductor (1 never) (unstable, states, signal source, conductor kind)','CALL "RS3-TNT-FACTS" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(0,)],lambda x:(0,2,0,1))
TH={1:(1,1,0),2:(1,0,0),3:(0,0,1),4:(0,0,0),5:(0,0,0),6:(0,0,1)}
T(g,'TNT hooks (9.1 table): onPlace needs a signal and the previous block not TNT, neighborChanged a signal only, playerWillDestroy is server only, wasExploded, useItemOn and onProjectileHit follow their own rules (hook 1 onPlace 2 neighborChanged 3 playerWillDestroy 4 wasExploded 5 useItemOn 6 onProjectileHit; needs a signal, checks the previous block, server only)','CALL "RS3-TNT-HOOK-ROW" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(h,) for h in (1,2,3,4,5,6)],lambda h:TH[h])
T(g,'TNT rules of 9.1 (live): onPlace and neighborChanged prime and remove; wasExploded fuse 10 to 29; breaking an unstable TNT outside creative primes; the hand and projectile rules are those of part 7 section 8','CALL "RS3-TNT-PLACE" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)\nCALL "RS3-TNT-DESTROY" USING WS-I(4) WS-I(5) WS-I(6) WS-R(3)\nCALL "RS3-TNT-SHORT-FUSE" USING WS-I(7) WS-I(8) WS-R(4) WS-R(5)',5,[(0,1,1,1,0,1,80,19)],lambda *a:(1,1,1,20,29))
TILT=['none','unstable','partial','full']
TN(g,'tilt names (9.2): none 0, unstable 1, partial 2, full 3 (serialized in that order)','CALL "RS3-DRIP-TILT" USING WS-NM WS-R(1)',1,[(n,) for n in TILT+['half']],lambda n:(TILT.index(n),) if n in TILT else (-1,))
DD={0:-1,1:10,2:10,3:100}
T(g,'delay until the next state (9.2): unstable 10, partial 10, full 100, none no tick (tilt; delay)','CALL "RS3-DRIP-DELAY" USING WS-I(1) WS-R(1)',1,[(i,) for i in range(4)],lambda i:(DD[i],))
T(g,'canEntityTilt (9.2): the entity is on the ground and its y is greater than pos.y + 0.6875 (on the ground, relative y in ten-thousandths)','CALL "RS3-DRIP-CAN-TILT" USING WS-I(1) WS-I(2) WS-R(1)',1,[(1,6876),(1,6875),(1,6874),(0,9000)],lambda g_,y:(int(g_ and y>6875),))
def dent(t,ct,sg):
    if t==0 and ct and not sg: return (1,10)
    return (0,-1)
T(g,'entity inside (9.2): when tilt is none, the entity can tilt and there is no neighbour signal: unstable with no sound, a tick after 10 (tilt, can tilt, signal; sets unstable, delay)','CALL "RS3-DRIP-ENTITY" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2)',2,[(t,c,s) for t in (0,1) for c in (0,1) for s in (0,1)],dent)
def vib(n,o): return int(n!=o and n in (0,2,3))
def dnb2(sg,t):
    if sg: return (0,2 if t!=0 else 0,vib(0,t))
    return (t,0,0)
T(g,'neighborChanged (9.2): with a neighbour signal resetTilt: tilt none, tilt_up played when the previous tilt was not none, block_change when the new tilt differs and causes a vibration (signal, tilt; new tilt, sound 1 down 2 up, vibration event)','CALL "RS3-DRIP-NEIGHBOR" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,[(s,t) for s in (0,1) for t in range(4)],dnb2)
def dtick(sg,t):
    if sg: return (0,2 if t!=0 else 0,-1,vib(0,t))
    if t==1: return (2,1,10,vib(2,1))
    if t==2: return (3,1,100,vib(3,2))
    if t==3: return (0,2,-1,vib(0,3))
    return (0,0,-1,0)
T(g,'scheduled tick (9.2, V25, 11.6): with a signal resetTilt and stop; else unstable becomes partial and partial becomes full with tilt_down, full runs resetTilt, none nothing; the delay of the new tilt (10, 100) is scheduled (signal, tilt; new tilt, sound, delay, vibration event)','CALL "RS3-DRIP-TICK" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,[(s,t) for s in (0,1) for t in range(4)],dtick)
T(g,'causes a vibration (9.2): none true, unstable false, partial true, full true, and the event only when the new tilt differs (new, old)','CALL "RS3-DRIP-VIBRATES" USING WS-I(1) WS-I(2) WS-R(1)',1,[(n,o) for n in range(4) for o in range(4)],lambda n,o:(vib(n,o),))
T(g,'projectile hit (9.2): tilt full at the hit block with tilt_down, no power check (tilt; new tilt, sound, vibration event)','CALL "RS3-DRIP-PROJECTILE" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3)',3,[(t,) for t in range(4)],lambda t:(3,1,vib(3,t)))
g.case('tilt pitch (9.2): Mth.randomBetween(random, 0.8, 1.2) = nextFloat * 0.4 + 0.8, uniform in [0.8, 1.2) (millionths)',[(r,'CALL "RS3-DRIP-PITCH" USING WS-FX(1) WS-R(1)',1) for r in ('0.0','0.5','0.999','0.25')]," ".join(str(int((Dc(r)*Dc('0.4')+Dc('0.8'))*1000000+Dc('0.5'))) for r in ('0.0','0.5','0.999','0.25')))
OWN={'DoorBlock':7,'TrapDoorBlock':7,'FenceGateBlock':7,'RedstoneLampBlock':7,'CopperBulbBlock':7,'NoteBlock':5,'DispenserBlock':4,'HopperBlock':4,'CrafterBlock':4,'BaseRailBlock':6,'PoweredRailBlock':6,'DetectorRailBlock':6,'PistonBaseBlock':3,'DiodeBlock':2,'ObserverBlock':2,'CommandBlock':316,'StructureBlock':316,'TestBlock':316,'ShelfBlock':313,'AbstractSkullBlock':313,'LecternBlock':314,'JukeboxBlock':314,'TrappedChestBlock':311,'BellBlock':8,'SculkSensorBlock':8,'TripWireHookBlock':8,'TntBlock':8,'BigDripleafBlock':8,'CarvedPumpkinBlock':0}
TN(g,'pointers (9.3): the part that specifies each block class that reads a neighbour signal (1 to 8 for 30-N, 311 for 31-1, 313 for 31-3, 314 for 31-4, 316 for 31-6, 0 not redstone; -1 unknown)','CALL "RS3-READER-OWNER" USING WS-NM WS-R(1)',1,[(n,) for n in OWN]+[('Unknown',)],lambda n:(OWN.get(n,-1),))
SU.write(g)
# ===== 10 Inventory
INV=[('redstone',301,5),('redstone_torch',301,8),('redstone_block',301,6),('repeater',302,0),('comparator',302,0),('target',305,6),('copper_bulb',307,0),('lever',305,2),('oak_button',305,3),('stone_button',305,3),('oak_pressure_plate',305,4),('stone_pressure_plate',305,4),('light_weighted_pressure_plate',305,4),('heavy_weighted_pressure_plate',305,4),('sculk_sensor',308,4),('calibrated_sculk_sensor',308,5),('sculk_shrieker',308,6),('amethyst_block',308,4),('white_wool',308,3),('tripwire_hook',308,7),('string',308,7),('lectern',314,3),('daylight_detector',305,5),('lightning_rod',305,7),('piston',303,0),('sticky_piston',303,0),('slime_block',303,4),('honey_block',303,4),('dispenser',304,0),('dropper',304,0),('crafter',304,6),('hopper',304,5),('chest',311,10),('copper_chest',311,0),('barrel',311,0),('chiseled_bookshelf',310,0),('oak_shelf',313,6),('furnace',312,0),('trapped_chest',311,10),('jukebox',314,2),('decorated_pot',313,0),('observer',302,6),('note_block',305,8),('composter',302,0),('cauldron',302,0),('rail',306,0),('powered_rail',306,5),('detector_rail',306,6),('activator_rail',306,5),('minecart',306,8),('hopper_minecart',304,5),('chest_minecart',306,8),('furnace_minecart',306,8),('tnt_minecart',306,8),('oak_chest_boat',0,0),('bamboo_chest_raft',0,0),('oak_door',307,0),('iron_door',307,0),('oak_fence_gate',307,0),('oak_trapdoor',307,0),('iron_trapdoor',307,0),('tnt',308,9),('redstone_lamp',307,0),('bell',308,8),('big_dripleaf',308,9),('armor_stand',459,11),('redstone_ore',301,7)]
g=SU.gen(10,'Inventory of the redstone category','T0836','the 67 entries of the redstone creative tab with the document that owns each, and the blocks without a tab item.',NAME)
T(g,'tab size (10): 67 entries, 66 accept calls and one forEach over the waxed copper bulbs, creative tab itemGroup.redstone (key redstone_blocks, top row, column 4) (entries, accept calls, forEach, row, column)','CALL "RS3-TAB-COUNT" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5)',5,[(0,)],lambda x:(67,66,1,0,4))
T(g,'tab rows 1 to 22 (10): item number, owning document (301 to 308 for 30-1 to 30-8, 311 for 31-1, 314 for 31-4) and section (0 none)','CALL "RS3-TAB-ROW" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(0,23)],lambda i:(INV[i-1][1],INV[i-1][2]) if 1<=i<=67 else (0,0))
T(g,'tab rows 23 to 45 (10)','CALL "RS3-TAB-ROW" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(23,46)],lambda i:(INV[i-1][1],INV[i-1][2]))
T(g,'tab rows 46 to 68 (10): rails, minecarts, the boats without redstone behaviour (0), doors, gates, trapdoors, TNT, lamp, bell, dripleaf, armor stand (459 section 11) and redstone ore; 68 is outside','CALL "RS3-TAB-ROW" USING WS-I(1) WS-R(1) WS-R(2)',2,[(i,) for i in range(46,69)],lambda i:(INV[i-1][1],INV[i-1][2]) if i<=67 else (0,0))
TN(g,'item lookup (10): the number, owner and section of an item name (0 0 0 for an item not in the tab)','CALL "RS3-TAB-ITEM" USING WS-NM WS-R(1) WS-R(2) WS-R(3)',3,[(n,) for n,_,_ in INV[:40]],lambda n:(([x[0] for x in INV].index(n)+1,)+tuple(INV[[x[0] for x in INV].index(n)][1:])))
TN(g,'item lookup, rest of the tab (10) and an unknown item','CALL "RS3-TAB-ITEM" USING WS-NM WS-R(1) WS-R(2) WS-R(3)',3,[(n,) for n,_,_ in INV[40:]]+[('diamond',)],lambda n:(([x[0] for x in INV].index(n)+1,)+tuple(INV[[x[0] for x in INV].index(n)][1:])) if n in [x[0] for x in INV] else (0,0,0))
NOTAB=('redstone_wire','redstone_wall_torch','tripwire','piston_head','moving_piston','deepslate_redstone_ore')
TN(g,'blocks of the family without a tab item of their own (10): redstone_wire, redstone_wall_torch, tripwire, piston_head, moving_piston, deepslate_redstone_ore','CALL "RS3-NO-TAB-ITEM" USING WS-NM WS-R(1)',1,[(n,) for n in NOTAB]+[('lever',)],lambda n:(int(n in NOTAB),))
SU.write(g)
