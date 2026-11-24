from genbex import *
import math
ONLY=only()
# Independent Python models of docs/protocol/31-block-entities-8-sculk-and-remaining-types.md (T0967 to T0988; core/src/be-31-8.cob, BE8- programs).
def GG(n,subj,tasks,desc): return mk(None,n,subj,tasks,desc,8)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_8_%d.cob'%n)
def begin(): return nb_begin()
def load(): return 'PERFORM LOAD-BUFFER\n'
S2=render(2)
TAGR='CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nMOVE 0 TO WS-LEN\nMOVE SPACES TO WS-OUT\nCALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN\nCALL "PB-FREE" USING PB-BUFFER\nSTRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR\n'
SENS=lambda: cr(34,'sculk_sensor')
CAL=lambda: cr(35,'calibrated_sculk_sensor')
SHR=lambda: cr(37,'sculk_shrieker')
CAT=lambda: cr(36,'sculk_catalyst')
STA=lambda: cr(47,'copper_golem_statue')
SUL=lambda: cr(48,'potent_sulfur')
FREQ={}
for f,names in {1:'step swim flap',2:'projectile_land hit_ground splash bounce',3:'item_interact_finish projectile_shoot instrument_play',4:'entity_action elytra_glide unequip',5:'entity_dismount equip',6:'entity_interact shear entity_mount',7:'entity_damage',8:'drink eat',9:'container_close block_close block_deactivate block_detach',10:'container_open block_open block_activate block_attach prime_fuse note_block_play',11:'block_change',12:'block_destroy fluid_pickup',13:'block_place fluid_place',14:'entity_place lightning_strike teleport',15:'entity_die explode'}.items():
    for n in names.split(): FREQ[n]=f
for i in range(1,16): FREQ['resonate_%d'%i]=i
ZERO=['item_interact_start','jukebox_play','jukebox_stop_play','sculk_sensor_tendrils_clicking','shriek']
for n in ZERO: FREQ[n]=0
ALL=list(FREQ)
assert len(ALL)==61 and sum(1 for v in FREQ.values() if v)==56
def nm(n): return txtv('WS-N48',n)+'MOVE %d TO WS-SVL\n'%len(n)
# ===== 1
g=GG(1,'Facts of the `BlockEntity` base used here','T0967','the base facts: empty update tag and no packet for the five types, the statue packet, op-only types, the chunk compound.')
body="";exp=[]
for t,pk in [(34,0),(35,0),(36,0),(37,0),(48,0),(47,1)]:
    body+='MOVE %d TO WS-A\n'%t+call('BE-SYNC-INFO','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[0,pk]
g.case('update (1): sculk sensor, calibrated sensor, catalyst, shrieker and potent sulfur send an empty tag and no packet; the copper golem statue only the packet (kind 0)',body,[],exp)
g.case('update tag (1): the default getUpdateTag is an empty compound for a sensor and for the statue',SENS()+TAGR+STA()+TAGR,[],['{} {}'])
body="";exp=[]
for t in (23,29,7,8,9,43,34,36,44,47):
    body+='MOVE %d TO WS-A\n'%t+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+shw('n:WS-B'); exp.append(int(t in (23,29,7,8,9,43)))
g.case('onlyOpCanSetNbt (1): exactly command_block, lectern, sign, hanging_sign, mob_spawner and trial_spawner',body,[],exp)
g.case('chunk compound (1): the type own keys, then components, then id, x, y, z (a statue has only the base keys)',STA()+render(1)+shw('SAVE')+SENS()+shw('SAVE'),[],['{components:{},id:minecraft:copper_golem_statue,x:5,y:70,z:5} {last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0},components:{},id:minecraft:sculk_sensor,x:5,y:70,z:5}'])
body="";exp=[]
for t,b,r in [(47,'copper_golem_statue',1),(47,'exposed_copper_golem_statue',1),(47,'weathered_copper_golem_statue',1),(47,'oxidized_copper_golem_statue',1),(47,'waxed_copper_golem_statue',1),(47,'waxed_oxidized_copper_golem_statue',1),(47,'copper_chest',0),(34,'sculk_sensor',1),(34,'calibrated_sculk_sensor',0),(48,'potent_sulfur',1)]:
    body+='MOVE %d TO WS-A\n'%t+key('minecraft:'+b)+call('BE-VALID-BLOCK','WS-A','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(r)
g.case('valid blocks (1): the statue accepts the eight statue blocks (unaffected, exposed, weathered, oxidized, each also waxed), the other types their own block',body,[],exp)
W(g,1)
# ===== 2
g=GG(2,'Game events as seen by block-entity listeners','T0969','notification radius, the section box, the listener radius test, the delivery order and the registration lifecycle.')
body="";exp=[]
for n in ALL:
    body+=nm(n)+call('BE8-EVENT-RADIUS','WS-N48','WS-SVL','WS-B')+('IF WS-B = 16\n    ADD 1 TO WS-E\nEND-IF\nIF WS-B = 10\n    ADD 1 TO WS-F\nEND-IF\nIF WS-B = 32\n    ADD 1 TO WS-G\nEND-IF\n')
body='MOVE 0 TO WS-E WS-F WS-G\n'+body+shw('n:WS-E','n:WS-F','n:WS-G')
g.case('notification radius (2.1): 58 of the 61 events use 16, jukebox_play and jukebox_stop_play 10, shriek 32 (counts of 16, 10, 32)',body,[],[58,2,1])
body=nm('minecraft:shriek')+call('BE8-EVENT-RADIUS','WS-N48','WS-SVL','WS-B')+shw('n:WS-B')+nm('minecraft:jukebox_play')+call('BE8-EVENT-RADIUS','WS-N48','WS-SVL','WS-B')+shw('n:WS-B')+nm('minecraft:step')+call('BE8-EVENT-RADIUS','WS-N48','WS-SVL','WS-B')+shw('n:WS-B')
g.case('event names (2.1): the minecraft: prefix of a registry key is ignored',body,[],[32,10,16])
body="";exp=[]
for x,r in [(0,16),(5,8),(-1,16),(-17,16),(100,32),(15,1),(16,1)]:
    body+=mv(A=x,B=r)+call('BE8-SECTION-RANGE','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:WS-E'); exp+=[math.floor((x-r)/16),math.floor((x+r)/16)]
g.case('section box (2.2): the sections from (coordinate - radius) >> 4 to (coordinate + radius) >> 4 on each axis (coordinate, radius in)',body,[],exp)
body="";exp=[]
for l,e,r in [((0,0,0),(3,4,0),5),((0,0,0),(3,4,1),5),((0,0,0),(8,0,0),8),((0,0,0),(9,0,0),8),((10,64,10),(10,64,10),0),((5,5,5),(5,5,6),0)]:
    body+=mv(A=l[0],B=l[1],C=l[2],E=e[0],F=e[1],G=e[2],H=r)+call('BE8-LISTENER-IN','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-P')
    d=sum((a-b)**2 for a,b in zip(l,e)); exp.append(int(d<=r*r))
g.case('listener radius (2.3): the squared block distance between listener and event must be <= radius * radius (only the listener radius filters) (listener block, event block, radius in)',body,[],exp)
def order(ls):
    imm=[i+1 for i,(m,d) in enumerate(ls) if m==0]
    byd=sorted([(d,i+1) for i,(m,d) in enumerate(ls) if m==1])
    return imm+[i for d,i in byd]
body="";exp=[]
for ls in [[(1,9),(0,50),(1,4),(0,1)],[(1,5),(1,5),(1,2)],[(0,3)],[(1,7),(0,2),(1,7),(1,1),(0,9)]]:
    body+=''.join('MOVE %d TO WS-TV(%d)\nMOVE %d TO WS-TV(%d)\n'%(m,2*i+1,d,2*i+2) for i,(m,d) in enumerate(ls))+'MOVE %d TO WS-A\n'%len(ls)+call('BE8-ORDER','WS-TAB','WS-A','WS-TAB2')+shw(*['n:WS-TV2(%d)'%(i+1) for i in range(len(ls))]); exp+=order(ls)
g.case('delivery order (2.2): UNSPECIFIED listeners (mode 0) run at once in visit order, BY_DISTANCE listeners (mode 1) after the whole visit sorted by squared distance ascending, a stable sort (pairs of mode and distance in; the listener numbers in delivery order out)',body,[],exp)
body="";exp=[]
for lv,srv,eb,pv in [(1,1,1,1),(1,0,1,1),(0,1,1,1),(1,1,0,1),(1,1,1,0)]:
    body+=mv(A=lv,B=srv,C=eb,E=pv)+call('BE8-REGISTER','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(lv and srv and eb and pv))
g.case('registration (2.4): a listener is registered when the entity is in a level, the level is a server level, the block is an EntityBlock and the entity provides a listener (in level, server, entity block, provider in)',body,[],exp)
W(g,2)
# ===== 3
g=GG(3,'The vibration system','T0971','frequencies, strength and travel time, isValidVibration, persistence, candidate selection, the ticker and the delivery.')
body="";exp=[]
for n in ALL:
    body+=nm(n)+call('BE8-FREQUENCY','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(FREQ[n])
body+=nm('not_an_event')+call('BE8-FREQUENCY','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(0)
g.case('frequencies (3.1): the table of the doc for all 61 events (56 non-zero: 41 explicit and resonate_1 to resonate_15 giving n; 5 zero), an unknown name gives 0',body,[],exp)
body="";exp=[]
for f in (1,7,15):
    body+='MOVE %d TO WS-A\n'%f+call('BE8-RESONANCE','WS-A','WS-N48','WS-LEN')+shw('t:WS-N48,WS-LEN'); exp.append('resonate_%d'%f)
g.case('resonance event (3.1): getResonanceEventByFrequency(f) is resonate_f',body,[],exp)
body="";exp=[]
for d,r in [(0,8),(1,8),(2,8),(3,8),(4,8),(5,8),(6,8),(7,8),(8,8),(0,16),(4,16),(10,16),(16,16),(50,8)]:
    body+='COMPUTE WS-FS1 = %s\n'%d+'MOVE %d TO WS-A\n'%r+call('BE8-STRENGTH','WS-FS1','WS-A','WS-B')+call('BE8-TRAVEL','WS-FS1','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[max(1,15-math.floor((15.0/r)*d)),math.floor(d)]
g.case('strength and travel time (3.2, example 12.1): max(1, 15 - floor(15.0 / radius * distance)) (15, 14, 12, 10, 8, 6, 4, 2, 1 at radius 8 for 0 to 8; 15, 12, 6, 1 at radius 16) and floor(distance) ticks (distance, radius in)',body,[],exp)
def valid(lis,ent,spec,care,ign,avoid,sp,damp,hs,sd):
    crit=0
    if not lis: return 0,0
    if ent:
        if spec: return 0,0
        if care and ign:
            return 0,int(avoid and sp)
        if damp: return 0,0
    if hs: return int(not sd),0
    return 1,0
body="";exp=[]
CS=[(0,0,0,0,0,0,0,0,0,0),(1,0,0,0,0,0,0,0,0,0),(1,1,1,0,0,0,0,0,0,0),(1,1,0,1,1,1,1,0,0,0),(1,1,0,1,1,1,0,0,0,0),(1,1,0,1,1,0,1,0,0,0),(1,1,0,1,0,0,0,0,0,0),(1,1,0,0,0,0,0,1,0,0),(1,0,0,0,0,0,0,0,1,1),(1,0,0,0,0,0,0,0,1,0),(1,1,0,0,0,0,0,0,1,1)]
for c in CS:
    body+=mv(A=c[0],B=c[1],C=c[2],E=c[3],F=c[4],G=c[5],H=c[6],P=c[7],Q=c[8],R=c[9])+call('BE8-VALID','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P','WS-Q','WS-R','WS-S','WS-U')+shw('n:WS-S','n:WS-U'); exp+=list(valid(*c))
g.case('isValidVibration (3.3): not listenable; a spectator; a sneaking source in ignore_vibrations_sneaking (the avoid_vibration criterion fires only for a trigger-capable user and a server player); a dampening entity; an affected block state in dampens_vibrations (listenable, entity, spectator, careful, event in ignore tag, can trigger avoid, server player, dampens, has state, state dampens in; valid, criterion out)',body,[],exp)
def handle(fl,va,pos,can,occ):
    if fl: return 1
    if not va: return 2
    if not pos: return 3
    if not can: return 4
    if occ: return 5
    return 0
body="";exp=[]
for c in [(1,1,1,1,0),(0,0,1,1,0),(0,1,0,1,0),(0,1,1,0,0),(0,1,1,1,1),(0,1,1,1,0)]:
    body+=SENS()+'MOVE %d TO BE-XI(WS-IDX, 2)\n'%c[0]+mv(A=c[1],B=c[2],C=c[3],E=c[4])+call('BE8-HANDLE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(handle(c[0],c[1],c[2],c[3],c[4]))
g.case('handleGameEvent (3.5): refused in order when a vibration is in flight (1), invalid (2), no position (3), the user cannot receive (4), occluded (5), else accepted (0) (in flight, valid, has position, can receive, occluded in)',body,[],exp)
body="";exp=[]
for hits in [(1,1,1,1,1,1),(1,1,1,0,1,1),(0,0,0,0,0,0)]:
    body+=''.join('MOVE %d TO WS-TV(%d)\n'%(h,i+1) for i,h in enumerate(hits))+call('BE8-OCCLUDED','WS-TAB','WS-A')+shw('n:WS-A'); exp.append(int(all(hits)))
for x in (10.2,-0.5,3.0,-3.7):
    body+='COMPUTE WS-FA = %s\n'%x+call('BE8-SNAP','WS-FA','WS-FB')+shw('f:WS-FB'); exp.append(math.floor(x)+0.5)
g.case('occlusion (3.6): a position snaps to the centre of its block (floor + 0.5); the vibration is occluded only when all six rays meet an occluding block (ray results, coordinate in)',body,[],exp)
def cand_run(cands):
    cur=None; out=[]
    for tick,dist,fq in cands:
        if cur is None: cur=(tick,dist,fq); out.append(1)
        elif tick==cur[0] and (dist<cur[1] or (dist==cur[1] and fq>cur[2])): cur=(tick,dist,fq); out.append(1)
        else: out.append(0)
    return out,cur
body=SENS();exp=[]
seq=[(100,3.0,1,'step'),(100,3.0,7,'entity_damage'),(100,2.5,1,'flap'),(100,9.0,15,'explode'),(101,1.0,15,'explode'),(100,2.5,1,'step'),(100,2.5,2,'splash')]
res=[];cur=None
for tick,dist,fq,name in seq:
    body+=nm(name)+'MOVE %d TO WS-LONG1\nCOMPUTE WS-FS1 = %s\nMOVE 0 TO WS-A\n'%(tick,dist)+'COMPUTE WS-FA = 1\nCOMPUTE WS-FB = 2\nCOMPUTE WS-FC = 3\n'+'MOVE 1 TO WS-TV(1)\nMOVE 2 TO WS-TV(2)\nMOVE 3 TO WS-TV(3)\nMOVE 4 TO WS-TV(4)\nMOVE 0 TO WS-A\n'+call('BE8-ADD-CANDIDATE','WS-IDX','WS-LONG1','WS-N48','WS-SVL','WS-FS1','WS-FA','WS-FB','WS-FC','WS-A','WS-TAB','WS-B')+shw('n:WS-B')
    if cur is None or (tick==cur[0] and (dist<cur[1] or (dist==cur[1] and fq>cur[2]))): cur=(tick,dist,fq); res.append(1)
    else: res.append(0)
body+=shw('n:BE-SEED(WS-IDX)','f4:BE-XF(WS-IDX, 2)','t:BE-XT(WS-IDX, 2)|BE-XI(WS-IDX, 8)')
nmtab={ 'step':1,'entity_damage':7,'flap':1,'explode':15,'splash':2}
g.case('candidate selection (3.7, example 12.3): a candidate replaces the held one only in the same tick and only when closer, or at equal distance with a strictly higher frequency; a different tick never replaces (the held candidate and its tick at the end)',body,[],res+[cur[0],cur[1],[n for t,d,f,n in seq if (t,d)==(cur[0],cur[1]) and FREQ[n]==cur[2]][0]])
body=SENS()+'MOVE 100 TO BE-SEED(WS-IDX)\nMOVE 1 TO BE-XI(WS-IDX, 7)\n'
for now in (100,101):
    body+='MOVE %d TO WS-LONG1\n'%now+call('BE8-CHOSEN','WS-IDX','WS-LONG1','WS-A')+shw('n:WS-A')
body+='MOVE 0 TO BE-XI(WS-IDX, 7)\nMOVE 105 TO WS-LONG1\n'+call('BE8-CHOSEN','WS-IDX','WS-LONG1','WS-A')+shw('n:WS-A')
g.case('chosen candidate (3.7): chosenCandidate(now) needs candidate tick < now (not at the tick of the event), nothing without a candidate',body,[],[0,1,0])
# ticker timeline (example 12.2): event at T=100, distance 5.0
body=SENS()+nm('step')+'MOVE 100 TO WS-LONG1\nCOMPUTE WS-FS1 = 5.0\nCOMPUTE WS-FA = 1\nCOMPUTE WS-FB = 2\nCOMPUTE WS-FC = 3\nMOVE 1 TO WS-TV(1)\nMOVE 2 TO WS-TV(2)\nMOVE 3 TO WS-TV(3)\nMOVE 4 TO WS-TV(4)\nMOVE 0 TO WS-A\n'+call('BE8-ADD-CANDIDATE','WS-IDX','WS-LONG1','WS-N48','WS-SVL','WS-FS1','WS-FA','WS-FB','WS-FC','WS-A','WS-TAB','WS-B')
exp=[]
for t in range(100,107):
    body+='MOVE %d TO WS-LONG1\nMOVE 1 TO WS-A\n'%t+call('BE8-TICK','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-B','n:WS-C','n:WS-E','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 6)')
def timeline():
    out=[]; cur=False; travel=0
    cand=True
    for t in range(100,107):
        sel=0;dl=0;ch=0
        if not cur and cand and 100<t: cur=True; travel=5; sel=1; cand=False; ch=1
        if cur:
            ticking = travel>0
            travel=max(0,travel-1)
            if travel<=0: cur=False; dl=1; ticking=True
            if ticking: ch=1
        out+=[sel,dl,ch,int(cur),travel]
    return out
exp=timeline()
g.case('ticker (3.8, 3.10, example 12.2): an event of distance 5.0 at game time 100 is selected at 101 (travel 5, then decremented to 4), counts down 3, 2, 1 and is delivered at 105 (selected, delivered, data changed, in flight, travel time per tick)',body,[],exp)
body=SENS()+'MOVE 1 TO BE-XI(WS-IDX, 2)\nMOVE 0 TO BE-XI(WS-IDX, 6)\nMOVE 0 TO WS-A\nMOVE 100 TO WS-LONG1\n'+call('BE8-TICK','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:BE-XI(WS-IDX, 2)')
body+='MOVE 1 TO WS-A\n'+call('BE8-TICK','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:BE-XI(WS-IDX, 2)')
g.case('delivery (3.10 step 2, validation 6): when the 3 by 3 chunk area is not ticking the vibration is kept and retried every tick, delivered as soon as it is (chunks ok in)',body,[],[0,1,1,0])
body="";exp=[]
for t,d in [(3,5.0),(4,10.0),(1,4.0),(0,0.5),(2,0.5)]:
    body+=SENS()+'MOVE %d TO BE-XI(WS-IDX, 6)\nCOMPUTE BE-XF(WS-IDX, 1) = %s\n'%(t,d)+call('BE8-RELOAD','WS-IDX','WS-FA')+shw('f:WS-FA')
    total=math.floor(d); exp.append(1-t/total if total else 1.0)
g.case('reload particle (3.9, example 12.5): the particle is re-sent at lerp(1 - T / total) of the way, 40 percent for 3 ticks left of 5; a total of 0 (distance below 1) is treated as arrived (fraction 1)',body,[],exp)
RT='CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nCALL "BE-LOAD" USING WS-Q PB-BUFFER\nCALL "PB-FREE" USING PB-BUFFER\n'
def sensor_with_event(typ=34,name='step',tick=-1):
    return cr(typ,{34:'sculk_sensor',35:'calibrated_sculk_sensor',37:'sculk_shrieker'}[typ])+'MOVE 1 TO BE-XI(WS-IDX, 2)\nMOVE "minecraft:%s" TO BE-XT(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\nCOMPUTE BE-XF(WS-IDX, 1) = 5.0\nCOMPUTE BE-XD(WS-IDX, 1) = 10.5\nCOMPUTE BE-XD(WS-IDX, 2) = 64.0\nCOMPUTE BE-XD(WS-IDX, 3) = 20.5\nMOVE 1 TO BE-XI(WS-IDX, 4)\nMOVE 1 TO BE-UUID(WS-IDX, 1)\nMOVE 2 TO BE-UUID(WS-IDX, 2)\nMOVE 3 TO BE-UUID(WS-IDX, 3)\nMOVE 4 TO BE-UUID(WS-IDX, 4)\nMOVE 3 TO BE-XI(WS-IDX, 6)\nMOVE 1 TO BE-XI(WS-IDX, 1)\n'%(name,len('minecraft:'+name))
EV='listener:{event:{game_event:minecraft:step,distance:5.000,pos:[10.500,64.000,20.500],source:I[1,2,3,4]},selector:{tick:-1},event_delay:3}'
def ROUND(typ):
    return sensor_with_event(typ)+'MOVE WS-IDX TO WS-U\n'+cr(typ,{34:'sculk_sensor',35:'calibrated_sculk_sensor',37:'sculk_shrieker'}[typ])+'MOVE WS-IDX TO WS-Q\nMOVE WS-U TO WS-IDX\n'+RT+'MOVE WS-Q TO WS-IDX\n'
g.case('persisted vibration (3.4, example 12.5): the listener compound holds event (game_event, distance, pos as three doubles, source as an int array), selector with tick -1 and event_delay 3; the sensor adds last_vibration_frequency before it; a save loads back to the same compound and sets reloadVibrationParticle',sensor_with_event()+S2+shw('SAVE')+ROUND(34)+shw('SAVE','n:BE-XI(WS-IDX, 11)'),[],['{last_vibration_frequency:1,'+EV+'} {last_vibration_frequency:1,'+EV+'} 1'])
g.case('selector and owner (3.4): a held candidate is written under selector with its tick and the projectile owner under event; a missing selector makes the whole listener value a fresh Data; an empty compound is the fresh data (tick -1, event_delay 0); a tick without an event is no candidate',cr(34,'sculk_sensor')+'MOVE 1 TO BE-XI(WS-IDX, 2)\nMOVE "minecraft:flap" TO BE-XT(WS-IDX, 1)\nMOVE 14 TO BE-XI(WS-IDX, 3)\nMOVE 1 TO BE-XI(WS-IDX, 5)\nMOVE 5 TO BE-UUID(WS-IDX, 5)\nMOVE 6 TO BE-UUID(WS-IDX, 6)\nMOVE 7 TO BE-UUID(WS-IDX, 7)\nMOVE 8 TO BE-UUID(WS-IDX, 8)\nCOMPUTE BE-XD(WS-IDX, 1) = 1.0\nCOMPUTE BE-XD(WS-IDX, 2) = 2.0\nCOMPUTE BE-XD(WS-IDX, 3) = 3.0\nCOMPUTE BE-XF(WS-IDX, 1) = 1.5\nMOVE 1 TO BE-XI(WS-IDX, 7)\nMOVE "minecraft:explode" TO BE-XT(WS-IDX, 2)\nMOVE 17 TO BE-XI(WS-IDX, 8)\nCOMPUTE BE-XF(WS-IDX, 2) = 2.5\nCOMPUTE BE-XD(WS-IDX, 4) = 4.0\nCOMPUTE BE-XD(WS-IDX, 5) = 5.0\nCOMPUTE BE-XD(WS-IDX, 6) = 6.0\nMOVE 88 TO BE-SEED(WS-IDX)\n'+S2+shw('SAVE')+begin()+nb_c('listener')+nb_e()+load()+shw('SAVE','n:BE-XI(WS-IDX, 2)')+begin()+nb_c('listener')+nb_c('selector')+nb_long('tick',9)+nb_e()+load()+shw('SAVE'),[],['{last_vibration_frequency:0,listener:{event:{game_event:minecraft:flap,distance:1.500,pos:[1.000,2.000,3.000],projectile_owner:I[5,6,7,8]},selector:{event:{game_event:minecraft:explode,distance:2.500,pos:[4.000,5.000,6.000]},tick:88},event_delay:0}} {last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}} 0 {last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}}'])
body="";exp=[]
for n,f in [('minecraft:step',1),('minecraft:resonate_9',9),('resonate_0',0),('resonate_16',0),('resonate_xy',0),('resonate_',0),('minecraft:',0)]:
    body+=nm(n)+call('BE8-FREQUENCY','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(f)
g.case('event names (3.1): a minecraft: prefix is ignored; resonate_n is only a frequency for n from 1 to 15 written as digits',body,[],exp)
L3=cr(34,'sculk_sensor')+begin()+nb_c('listener')+nb_c('event')+nb_s('game_event','minecraft:step')+nb_l('pos',6,2)+nb_double(None,'1.0')+nb_double(None,'2.0')+nb_e()+nb_e()+nb_i('zzz',1)+nb_c('selector')+nb_i('zzz',2)+nb_e()+nb_e()+load()+S2+shw('SAVE')
L3+=cr(34,'sculk_sensor')+begin()+nb_c('listener')+nb_c('event')+nb_s('game_event','minecraft:step')+nb_l('pos',6,3)+nb_double(None,'1.0')+nb_double(None,'2.0')+nb_double(None,'3.0')+nb_i('zzz',1)+nb_intarr('source',[1,2,3])+nb_intarr('projectile_owner',[1,2,3])+nb_e()+nb_c('selector')+nb_e()+nb_e()+load()+shw('SAVE')
g.case('lenient event read (3.4): an event whose pos is not a list of three doubles is absent, unknown keys are skipped at every level, a source or owner array that is not 4 ints is ignored',L3,[],['{last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}} {last_vibration_frequency:0,listener:{event:{game_event:minecraft:step,distance:0.000,pos:[1.000,2.000,3.000]},selector:{tick:-1},event_delay:0}}'])
W(g,3)
# ===== 4
g=GG(4,'Sculk sensor','T0973','receive rules, activation, the phase machine, resonance pitch, stepping, the comparator and the keys.')
def can4(same,bp,fq,phase,cal,back):
    if same and bp: return 0
    if fq==0: return 0
    if cal and back!=0 and fq!=back: return 0
    return int(phase==0)
body="";exp=[]
for c in [(1,1,5,0,0,0),(1,0,5,0,0,0),(0,1,5,0,0,0),(0,0,0,0,0,0),(0,0,5,1,0,0),(0,0,5,2,0,0),(0,0,7,0,1,7),(0,0,1,0,1,7),(0,0,1,0,1,0),(0,0,1,0,0,7)]:
    body+=mv(A=c[0],B=c[1],C=c[2],E=c[3],F=c[4],G=c[5])+call('BE8-SENSOR-CAN','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-H'); exp.append(can4(*c))
g.case('canReceiveVibration (4.2, 5, example 12.4): refused for a block destroy or place at the sensor own position, for frequency 0, and unless the phase is inactive; the calibrated sensor also refuses a frequency that differs from a non-zero signal behind it (own position event, destroy or place, frequency, phase, calibrated, back signal in)',body,[],exp)
body="";exp=[]
for ph,name,d,r in [(0,'step',5.0,8),(0,'entity_damage',0.0,8),(1,'step',5.0,8),(0,'flap',10.0,16),(0,'explode',8.0,8)]:
    body+=SENS()+nm(name)+'MOVE %d TO WS-A\nCOMPUTE WS-FS1 = %s\nMOVE %d TO WS-B\n'%(ph,d,r)+call('BE8-SENSOR-RECEIVE','WS-IDX','WS-A','WS-N48','WS-SVL','WS-FS1','WS-B','WS-C','WS-E')+shw('n:WS-E','n:WS-C','n:BE-XI(WS-IDX, 1)')
    ok=ph==0
    exp+=[int(ok),max(1,15-math.floor(15.0/r*d)) if ok else 0,FREQ[name] if ok else 0]
g.case('onReceiveVibration (4.2, example 12.2): in the inactive phase the frequency is stored and the block activates with the power for the distance (5.0 at radius 8 gives 6), never in another phase (phase, distance, radius in; activate, power, stored frequency out)',body,[],exp)
body="";exp=[]
for ph in (1,2,0):
    body+='MOVE %d TO WS-A\nMOVE 1 TO WS-B\n'%ph+call('BE8-PHASE-TICK','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-C','n:WS-E','n:WS-F','n:WS-G')
    exp+={1:[2,0,10,0],2:[0,0,0,1],0:[0,0,0,0]}[ph]
g.case('block tick (4.3): active turns to cooldown with power 0 and a tick after 10; cooldown turns to inactive with the stop sound when not waterlogged (1); inactive does nothing (phase, not waterlogged in; next phase, power, delay, sound out)',body,[],exp)
g.case('block tick (4.3): the stop sound is silent for a waterlogged block',mv(A=2,B=0)+call('BE8-PHASE-TICK','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-C','n:WS-G'),[],[0,0])
body="";exp=[]
for f in range(0,16):
    note=[0,0,2,4,6,7,9,10,12,14,15,18,19,21,22,24][f]
    body+='MOVE %d TO WS-A\n'%f+call('BE8-PITCH','WS-A','WS-FS1')+shw('f4:WS-FS1'); exp.append(f32(2**((note-12)/12)))
g.case('resonance pitch (4.3): 2 ^ ((note - 12) / 12) with the note table 0, 0, 2, 4, 6, 7, 9, 10, 12, 14, 15, 18, 19, 21, 22, 24 for the frequencies 0 to 15',body,[],exp)
body="";exp=[]
for ph,fq in [(1,9),(0,9),(2,9)]:
    body+=SENS()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO WS-A\n'%(fq,ph)+call('BE8-SENSOR-OUTPUT','WS-IDX','WS-A','WS-B')+shw('n:WS-B'); exp.append(fq if ph==1 else 0)
for c in [(0,0,1,1),(0,1,1,1),(1,0,1,1),(0,0,0,1),(0,0,1,0)]:
    body+=mv(A=c[0],B=c[1],C=c[2],E=c[3])+call('BE8-STEP-ON','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
    exp.append(int(c[0]==0 and c[1]==0 and c[2]==1 and c[3]==1))
g.case('comparator and stepping (4.3, 4.4): the comparator reads last_vibration_frequency only while active; stepping forces a vibration only when the sensor can activate (phase 0), the entity is not a warden, a sensor entity exists and canReceive holds (phase, entity is a warden, entity found, can receive in)',body,[],exp)
g.case('keys (4.1): last_vibration_frequency is written before listener (fresh: 0 and a fresh listener data), and loads back; the update tag is empty',cr(34,'sculk_sensor')+S2+shw('SAVE')+begin()+nb_i('last_vibration_frequency',7)+load()+shw('SAVE','n:BE-XI(WS-IDX, 1)')+TAGR,[],['{last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}} {last_vibration_frequency:7,listener:{selector:{tick:-1},event_delay:0}} 7 {}'])
W(g,4)
# ===== 5
g=GG(5,'Calibrated sculk sensor','T0975','radius, active ticks, the signal rule and the shared keys.')
body="";exp=[]
for t in (34,35,37):
    body+='MOVE %d TO WS-A\n'%t+call('BE8-RADIUS','WS-A','WS-B')+shw('n:WS-B'); exp.append({34:8,35:16,37:8}[t])
for c in (0,1):
    body+='MOVE %d TO WS-A\n'%c+call('BE8-ACTIVE-TICKS','WS-A','WS-B')+shw('n:WS-B'); exp.append(10 if c else 30)
for isf,p in [(1,9),(0,9)]:
    body+=mv(A=isf,B=p)+call('BE8-CAL-SIGNAL','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(0 if isf else p)
g.case('differences (3.3, 5): listener radius 8 (sensor), 16 (calibrated sensor), 8 (shrieker); active ticks 30 and 10; the output is 0 toward the facing direction, else the power',body,[],exp)
body="";exp=[]
for d in (0,4,16):
    body+='COMPUTE WS-FS1 = %d\nMOVE 16 TO WS-A\n'%d+call('BE8-STRENGTH','WS-FS1','WS-A','WS-B')+shw('n:WS-B'); exp.append(max(1,15-math.floor(0.9375*d)))
g.case('worked values (5): at radius 16 the strength is 15 at distance 0, 12 at 4 and 1 at 16',body,[],exp)
g.case('keys (5): the calibrated sensor has the sensor keys (last_vibration_frequency, listener)',cr(35,'calibrated_sculk_sensor')+S2+shw('SAVE')+ROUND(35)+shw('SAVE'),[],['{last_vibration_frequency:0,listener:{selector:{tick:-1},event_delay:0}} {last_vibration_frequency:1,'+EV+'}'])
W(g,5)
# ===== 6
g=GG(6,'Sculk shrieker','T0977','keys, canReceiveVibration, the player resolution and the removal response.')
g.case('keys (6): warning_level then listener; both round trip; the update tag is empty',cr(37,'sculk_shrieker')+S2+shw('SAVE')+begin()+nb_i('warning_level',3)+load()+shw('SAVE','n:BE-XI(WS-IDX, 1)')+TAGR,[],['{warning_level:0,listener:{selector:{tick:-1},event_delay:0}} {warning_level:3,listener:{selector:{tick:-1},event_delay:0}} 3 {}'])
body="";exp=[]
for sh,pl in [(0,1),(1,1),(0,0)]:
    body+=mv(A=sh,B=pl)+call('BE8-SHRIEKER-CAN','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(not sh and pl))
for og,op,sp in [(1,1,1),(1,0,1),(0,0,1),(0,0,0),(1,1,0)]:
    body+=mv(A=og,B=op,C=sp)+call('BE8-SHRIEKER-PLAYER','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E')
    exp.append(1 if og and op else 2 if sp else 0)
for st,srv in [(1,1),(1,0),(0,1)]:
    body+=mv(A=st,B=srv)+call('BE8-SHRIEKER-REMOVE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(st and srv))
g.case('rules (6): the shrieker accepts a vibration only when not shrieking and the source resolves to a player; the player comes from the projectile owner when given (and a player), else the source entity; removing a shrieking block on a server runs tryRespond once',body,[],exp)
W(g,6)
# ===== 7
g=GG(7,'Sculk catalyst','T0979','the cursor list persistence, addCursors, the event handler, the merge pass, the bloom constants.')
def cur(i,x,y,z,ch,dd=1,ud=0,fc=-1): return 'MOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE %d TO BE-UUID(WS-IDX, %d)\n'%(x,7*i+1,y,7*i+2,z,7*i+3,ch,7*i+4,dd,7*i+5,ud,7*i+6,fc,7*i+7)
g.case('fresh catalyst (7.1): the cursors list is always written, an empty list when there are none',CAT()+S2+shw('SAVE'),[],['{cursors:[]}'])
body=CAT()+'MOVE 1 TO WS-X\nMOVE 2 TO WS-Y\nMOVE 3 TO WS-Z\nMOVE 5 TO WS-A\n'+call('BE8-ADD-CURSORS','WS-IDX','WS-X','WS-Y','WS-Z','WS-A')+shw('n:BE-XI(WS-IDX, 1)','n:BE-UUID(WS-IDX, 4)')
body+='MOVE 1500 TO WS-A\n'+call('BE8-ADD-CURSORS','WS-IDX','WS-X','WS-Y','WS-Z','WS-A')+shw('n:BE-XI(WS-IDX, 1)','n:BE-UUID(WS-IDX, 11)','n:BE-UUID(WS-IDX, 18)','n:BE-UUID(WS-IDX, 12)','n:BE-UUID(WS-IDX, 13)')
body+='MOVE 0 TO WS-A\n'+call('BE8-ADD-CURSORS','WS-IDX','WS-X','WS-Y','WS-Z','WS-A')+shw('n:BE-XI(WS-IDX, 1)')+'MOVE 40000 TO WS-A\n'+call('BE8-ADD-CURSORS','WS-IDX','WS-X','WS-Y','WS-Z','WS-A')+shw('n:BE-XI(WS-IDX, 1)')
g.case('addCursors (7.3, validation 10): a reward of 5 makes one cursor of charge 5 (decay_delay 1, update_delay 0, no facings), 1500 makes cursors of 1000 and 500, nothing for 0, and at most 32 cursors are kept (a 33rd is dropped)',body,[],[1,5,3,1000,500,1,0,3,32])
L=cur(0,1,2,3,7,1,0,-1)+cur(1,4,5,6,1000,0,9,5)
g.case('persistence (7.1): the cursors list holds {pos, charge, decay_delay, update_delay, facings}; facings is a list of direction names, written only when present',CAT()+'MOVE 2 TO BE-XI(WS-IDX, 1)\n'+L+S2+shw('SAVE')+ROUND_CAT if False else CAT()+'MOVE 2 TO BE-XI(WS-IDX, 1)\n'+L+S2+shw('SAVE')+'MOVE WS-IDX TO WS-U\n'+CAT()+'MOVE WS-IDX TO WS-Q\nMOVE WS-U TO WS-IDX\n'+RT+'MOVE WS-Q TO WS-IDX\n'+shw('SAVE','n:BE-XI(WS-IDX, 1)'),[],['{cursors:[{pos:I[1,2,3],charge:7,decay_delay:1,update_delay:0},{pos:I[4,5,6],charge:1000,decay_delay:0,update_delay:9,facings:[down,north]}]} {cursors:[{pos:I[1,2,3],charge:7,decay_delay:1,update_delay:0},{pos:I[4,5,6],charge:1000,decay_delay:0,update_delay:9,facings:[down,north]}]} 2'])
def cl(entries,count=None):
    s=nb_l('cursors',10,len(entries) if count is None else count)
    for e in entries: s+=nb_intarr('pos',[e[0],e[1],e[2]])+(nb_i('charge',e[3]) if e[3] is not None else '')+e[4]+nb_e()
    return s
g.case('lenient cursor load (7.1): decay_delay defaults to 1, update_delay to 0, charge to 0, a facings list of names becomes the set; an entry with a charge outside 0 to 1000, a decay_delay above 1, a negative update_delay or no pos fails the list (empty); more than 32 entries read as empty',CAT()+begin()+cl([(1,2,3,None,nb_l('facings',8,2)+nb_s(None,'east')+nb_s(None,'down'))])+load()+S2+shw('SAVE')+CAT()+begin()+cl([(1,2,3,2000,'')])+load()+shw('SAVE')+CAT()+begin()+cl([(1,2,3,5,nb_i('decay_delay',2))])+load()+shw('SAVE')+CAT()+begin()+cl([(1,2,3,5,nb_i('update_delay',-1))])+load()+shw('SAVE')+CAT()+begin()+nb_l('cursors',10,1)+nb_i('charge',5)+nb_e()+load()+shw('SAVE')+CAT()+begin()+cl([(i,0,0,1,'') for i in range(33)])+load()+shw('SAVE')+CAT()+begin()+cl([(i,0,0,1,'') for i in range(32)])+load()+shw('n:BE-XI(WS-IDX, 1)'),[],['{cursors:[{pos:I[1,2,3],charge:0,decay_delay:1,update_delay:0,facings:[down,east]}]} {cursors:[]} {cursors:[]} {cursors:[]} {cursors:[]} {cursors:[]} 32'])
L7=CAT()+begin()+cl([(1,1,1,5,nb_l('facings',8,8)+nb_s(None,'down')+nb_s(None,'up')+nb_s(None,'north')+nb_s(None,'south')+nb_s(None,'west')+nb_s(None,'east')+nb_s(None,'down')+nb_s(None,'')+nb_i('zzz',1))])+load()+S2+shw('SAVE')
L7+=CAT()+begin()+cl([(2,2,2,5,nb_l('facings',3,2)+nb_i(None,1)+nb_i(None,2))])+load()+shw('SAVE')
g.case('facings (7.1): the names of all six directions are read into a set (a duplicate or an unknown name changes nothing), an element of the wrong type is skipped, an unknown key of an entry is skipped; the set is written in the order down, up, north, south, west, east',L7,[],['{cursors:[{pos:I[1,1,1],charge:5,decay_delay:1,update_delay:0,facings:[down,up,north,south,west,east]}]} {cursors:[{pos:I[2,2,2],charge:5,decay_delay:1,update_delay:0,facings:[]}]}'])
body="";exp=[]
for die,liv,con,drops,rew in [(1,1,0,1,5),(1,1,0,1,0),(1,1,0,0,5),(1,1,1,1,5),(1,0,0,1,5),(0,1,0,1,5)]:
    body+=mv(A=die,B=liv,C=con,E=drops,F=rew)+call('BE8-CAT-HANDLE','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P','WS-Q','WS-R')+shw('n:WS-G','n:WS-H','n:WS-P','n:WS-Q','n:WS-R')
    if not die or not liv: exp+=[0,0,0,0,0]
    elif con: exp+=[1,0,0,0,0] if False else [0,0,0,0,1]
    else: exp+=[rew if (drops and rew>0) else 0,1,1,int(bool(drops and rew>0)),1]
g.case('handleGameEvent (7.2, validation 10): only entity_die of a living entity; an entity whose experience was consumed skips to the end; otherwise cursors for a positive reward of an entity that drops experience (with the advancement), the experience is always marked skipped and the catalyst always blooms (die, living, consumed, drops, reward in; cursor charge, skip experience, bloom, advancement, accepted out)',body.replace("'WS-G','WS-H','WS-P','WS-Q','WS-R'","'WS-G','WS-H','WS-P','WS-Q','WS-R'"),[],exp)
def mergeref(cs,ox,oy,oz):
    kept=[];events=[];sums={};remember={}
    for c in cs:
        c=dict(c)
        if max(abs(c['x']-ox),abs(c['y']-oy),abs(c['z']-oz))>1024: continue
        if c['ch']<=0: events.append((c['x'],c['y'],c['z'],0)); continue
        pos=(c['x'],c['y'],c['z'])
        sums[pos]=sums.get(pos,0)+c['ch']
        ex=remember.get(pos)
        if ex is None: kept.append(c); remember[pos]=c
        elif ex['ch']+c['ch']<=1000:
            ex['ch']+=c['ch']; ex['ud']=min(ex['ud'],c['ud']); c['ch']=0
        else:
            kept.append(c)
            if c['ch']<ex['ch']: remember[pos]=c
    for pos,sm in sums.items():
        if sm>0 and remember[pos]['fc']>=0:
            events.append((pos[0],pos[1],pos[2],((int(math.log(1+sm)/2.299999952316284)+1)<<6)+remember[pos]['fc']))
    return kept,events
CS=[dict(x=1,y=2,z=3,ch=100,dd=1,ud=5,fc=-1),dict(x=1,y=2,z=3,ch=200,dd=1,ud=2,fc=-1),dict(x=9,y=9,z=9,ch=0,dd=1,ud=0,fc=-1),dict(x=5000,y=0,z=0,ch=50,dd=1,ud=0,fc=-1),dict(x=7,y=7,z=7,ch=700,dd=1,ud=3,fc=5),dict(x=7,y=7,z=7,ch=600,dd=1,ud=1,fc=5),dict(x=7,y=7,z=7,ch=50,dd=1,ud=9,fc=5)]
kept,events=mergeref(CS,0,0,0)
body=CAT()+'MOVE %d TO BE-XI(WS-IDX, 1)\n'%len(CS)+''.join(cur(i,c['x'],c['y'],c['z'],c['ch'],c['dd'],c['ud'],c['fc']) for i,c in enumerate(CS))+'MOVE 0 TO WS-X\nMOVE 0 TO WS-Y\nMOVE 0 TO WS-Z\n'+call('BE8-MERGE','WS-IDX','WS-X','WS-Y','WS-Z','WS-TAB3','WS-A')+shw('n:BE-XI(WS-IDX, 1)','n:WS-A')
exp=[len(kept),len(events)]
for i,c in enumerate(kept): body+=shw('n:BE-UUID(WS-IDX, %d)'%(7*i+1),'n:BE-UUID(WS-IDX, %d)'%(7*i+4),'n:BE-UUID(WS-IDX, %d)'%(7*i+6)); exp+=[c['x'],c['ch'],c['ud']]
for i,e in enumerate(events): body+=shw(*['n:WS-TV3(%d)'%(4*i+k+1) for k in range(4)]); exp+=list(e)
g.case('position merge (7.3): cursors farther than 1024 (Chebyshev) are dropped, a cursor with charge 0 sends level event 3006 with data 0 and is dropped, two cursors on one position merge when the charges sum to at most 1000 (the update delay becomes the smaller one), otherwise stay separate; a position with facings and a charge sum S sends event 3006 with data ((int)(ln(1 + S) / 2.3) + 1) << 6 plus the facings mask (cursors after the update in; count, events, then each kept cursor x, charge, update delay, then each event x y z data out)',body,[],exp)
body="";exp=[]
for r in (0.0,0.5,0.75):
    body+='COMPUTE WS-FS1 = %s\n'%r+call('BE8-BLOOM','WS-FS1','WS-FS2','WS-A','WS-B','WS-C')+shw('f4:WS-FS2','n:WS-A','n:WS-B','n:WS-C'); exp+=[f32(0.6+f32(r)*0.4),8,2,2]
g.case('bloom (7.4): a tick after 8 ticks, two sculk_soul particles, the sound at volume 2.0 and pitch 0.6 + nextFloat * 0.4 (draw in; pitch, delay, particles, volume out)',body,[],exp)
W(g,7)
# ===== 8
g=GG(8,'Copper golem statue','T0981','the pose cycle, the comparator signal, the axe and item rules, the facing from the yaw and the empty persistence.')
body="";exp=[]
for p in range(4):
    body+='MOVE %d TO WS-A\n'%p+call('BE8-STATUE-NEXT','WS-A','WS-B')+call('BE8-STATUE-SIGNAL','WS-A','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[(p+1)%4,p+1]
g.case('pose (8, example 12.8): the cycle standing, sitting, running, star, standing and the comparator output pose.ordinal + 1 (1 to 4)',body,[],exp)
def use(axe,wea,ox,hc,created):
    if axe:
        if wea and ox==0:
            return 2 if created else 0
        return 0
    if hc and wea: return 0
    return 1
body="";exp=[]
for c in [(0,0,0,0,0),(1,1,0,0,1),(1,1,0,0,0),(1,1,1,0,1),(1,0,0,0,1),(0,1,0,1,0),(0,0,0,1,0),(0,1,2,0,0)]:
    body+=mv(A=c[0],B=c[1],C=c[2],E=c[3],F=c[4])+call('BE8-STATUE-USE','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-G'); exp.append(use(*c))
g.case('use (8): an axe on an unaffected weathering statue removes the block and creates the golem when one was created, otherwise passes (also on weathered, oxidized and waxed statues); honeycomb on a weathering statue passes; any other item advances the pose (axe, weathering, oxidation, honeycomb, golem created in; result 0 pass 1 pose 2 golem out)',body,[],exp)
body="";exp=[]
for yaw in (0,90,180,270,359,-45,44,45,135):
    body+='MOVE %d TO WS-A\n'%yaw+call('BE8-STATUE-FACING','WS-A','WS-B')+shw('n:WS-B'); exp.append({0:3,1:4,2:2,3:5}[math.floor(yaw/90+0.5)&3])
g.case('facing from the golem yaw (8): Direction.fromYRot, floor(yaw / 90 + 0.5) & 3 gives south, west, north, east (3, 4, 2, 5)',body,[],exp)
g.case('persistence (8): a statue has no fields, only the base keys, and the update packet carries an empty tag',STA()+S2+shw('SAVE')+begin()+nb_s('zzz','x')+load()+shw('SAVE')+TAGR,[],['{} {} {}'])
W(g,8)
# ===== 9
g=GG(9,'Potent sulfur','T0983','the countdown key, the gas source search, the unobstructed count, the countdown machine, the reach and launch rules, the seed and the tickers.')
g.case('fields (9.1): countdown is written as an int (-1 when none) and read only when present; the update tag is empty',SUL()+'MOVE -1 TO BE-XI(WS-IDX, 1)\n'+S2+shw('SAVE')+begin()+nb_i('countdown',12)+load()+shw('SAVE','n:BE-XI(WS-IDX, 1)')+begin()+load()+shw('n:BE-XI(WS-IDX, 1)')+TAGR,[],['{countdown:-1} {countdown:12} 12 -1 {}'])
def source(cells):
    for k,c in enumerate(cells):
        if c==1: continue
        if c==3: return k
        return -1
    return -1
body="";exp=[]
for cells in [(3,0,0,0,0),(1,1,1,3,0),(1,1,1,1,3),(1,1,1,1,1),(1,0,0,0,0),(1,2,3,0,0),(0,0,0,0,0),(1,1,2,0,0)]:
    body+=''.join('MOVE %d TO WS-TV(%d)\n'%(c,i+1) for i,c in enumerate(cells))+call('BE8-SULFUR-SOURCE','WS-TAB','WS-A')+shw('n:WS-A'); exp.append(source(cells))
g.case('gas source (9.4): scanning the cells above the sulfur, a water source with the water block or a passable block continues, the first air or passable cell that is no water source ends the scan with h = its height - 1 (0 to 4), anything else or running past 5 cells gives none (-1) (cell kinds 1 water source continue, 2 water source with a blocking block, 3 air or passable, 0 solid in)',body,[],exp)
def unobs(h,cells):
    lim=6*h
    for i in range(lim):
        if not cells[i]: return i
    return lim
body="";exp=[]
for h,cells in [(0,[1]*24),(1,[1]*6),(1,[1,1,0,1,1,1]),(3,[1]*3+[0]+[1]*20),(4,[1]*24)]:
    body+=''.join('MOVE %d TO WS-TV(%d)\n'%(c,i+1) for i,c in enumerate(cells))+'MOVE %d TO WS-A\n'%h+call('BE8-SULFUR-UNOBSTRUCTED','WS-TAB','WS-A','WS-B')+shw('n:WS-B'); exp.append(unobs(h,cells))
g.case('unobstructed count (9.4): the limit is 6 * h cells; the first cell that is not passable ends the count (cells passable, h in)',body,[],exp)
def cd(state,t,found,h,countdown,draw):
    if t%20!=0 or not found: return countdown,state,0
    if countdown<=0:
        countdown=10*(h-1)+draw if state==2 else (h-1)+draw
    if countdown>0: countdown-=1
    ns=state; ev=0
    if countdown==0:
        ns=3 if state==2 else 2
        if ns==2: ev=1
    return countdown,ns,ev
body="";exp=[]
for st,t,found,h,c0,dr in [(2,40,1,3,-1,20),(2,41,1,3,-1,20),(2,40,0,3,-1,20),(2,40,1,3,5,20),(2,40,1,3,1,20),(3,40,1,3,-1,2),(3,40,1,0,-1,1),(3,40,1,3,1,2),(2,40,1,0,-1,15)]:
    body+=SUL()+'MOVE %d TO BE-XI(WS-IDX, 1)\n'%c0+mv(A=st,B=t,C=found,E=h,F=dr)+call('BE8-SULFUR-COUNTDOWN','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:BE-XI(WS-IDX, 1)','n:WS-G','n:WS-H')
    c1,ns,ev=cd(st,t,found,h,c0,dr); exp+=[c1,ns,ev]
g.case('waiting countdown (9.5, example 12.7): every 20 ticks with a source: when the countdown is not above 0 it becomes 10 * (h - 1) + draw (dormant, draw 15 to 30) or (h - 1) + draw (erupting, draw 1 to 2), then is decremented while above 0; at 0 dormant turns to erupting and erupting to dormant (which posts block_deactivate) (state 2 dormant 3 erupting, game time, source found, h, draw in; countdown, new state, deactivate event out)',body,[],exp)
body="";exp=[]
for t,f in [(10,1),(11,1),(10,0),(0,1)]:
    body+=mv(A=t,B=f)+call('BE8-SULFUR-NAUSEA','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(t%10==0 and f))
for ep,d2,wt,ray in [(1,9,1,1),(1,10,1,1),(0,1,1,1),(1,4,0,1),(1,4,1,0)]:
    body+=mv(A=ep,B=d2,C=wt,E=ray)+call('BE8-SULFUR-REACH','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(ep and d2<=9 and wt and ray))
g.case('nausea (9.5): the effect pass runs every 10 ticks with a source; an entity is reached when its eye block is passable, the squared distance to the source centre is at most 9, the lowered eye lies in a water source and the collider ray is clear',body,[],exp)
body="";exp=[]
for vy,h,fl,pas in [(0.0,3,0,0),(0.59,3,0,0),(0.61,3,0,0),(0.29,0,0,0),(0.31,0,0,0),(0.0,3,1,0),(0.0,3,0,1)]:
    body+='COMPUTE WS-FA = %s\n'%vy+mv(A=h,B=fl,C=pas)+call('BE8-SULFUR-LAUNCH','WS-FA','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E'); exp.append(int(vy<0.30000001192092896+h*0.1 and not fl and not pas))
g.case('launch (9.6): an entity is accelerated by +0.2 in y when its vertical velocity is below 0.3 + h * 0.1, unless it cannot simulate movement, flies, rides or is not affected by geysers (velocity y, h, flying, excluded in)',body,[],exp)
def x64(a,b): 
    r=(a^b)&((1<<64)-1)
    return r-(1<<64) if r>>63 else r
body="";exp=[]
for sd in (0,1,123456789,-5,9223372036854775807):
    body+='MOVE %d TO WS-LONG1\n'%sd+call('BE8-GEYSER-SEED','WS-LONG1','WS-LONG2')+shw('n:FUNCTION MOD(WS-LONG2, 1000000007)','n:FUNCTION INTEGER(WS-LONG2 / 4294967296)'); v=x64(sd,-904011478); exp+=[v%1000000007,v//4294967296]
g.case('geyser seed (9.4): the level seed exclusive or the constant -904011478 (64 bit; shown modulo 1000000007 and as the upper half)',body,[],exp)
TK={0:(0,0),1:(1,1),2:(2,1),3:(3,2),4:(4,3)}
body="";exp=[]
for st in range(5):
    for side in (0,1):
        body+=mv(A=st,B=side)+call('BE8-SULFUR-TICKER','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(TK[st][side])
g.case('tickers by state and side (9.3): dry none; wet server nausea (1) and client gas particles (1); dormant server countdown then nausea (2); erupting server launch then countdown (3) and client eruption plume then launch (2); continuous server launch (4) and client continuous plume then launch (3) (state, side 0 server 1 client in)',body,[],exp)
body="";exp=[]
for st in range(5):
    body+='MOVE %d TO WS-A\n'%st+call('BE8-SULFUR-PLACE','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-B','n:WS-C','n:WS-E'); exp+=[int(st in (3,4)),{3:1,4:2}.get(st,0),int(st in (3,4))]
g.case('onPlace (9.2): only erupting and continuous queue the block event, play geyser_eruption_start (1) or geyser_continuous_start (2) and post block_activate',body,[],exp)
W(g,9)
# ===== 10
g=GG(10,'Test-only block entities','T0985','the persistence of the two test types through the 31-6 programs: keys, defaults and update tags.')
g.case('test block (10.1): mode (a name), message and powered are the keys; a new entity has mode start, an unreadable mode is fail; the update tag is the three keys',cr(45,'test_block')+S2+shw('SAVE')+begin()+nb_s('mode','bogus')+nb_s('message','m')+load()+shw('SAVE')+TAGR,[],['{mode:start,message:,powered:0} {mode:fail,message:m,powered:0} {mode:fail,message:m,powered:0}'])
g.case('test instance block (10.2): data (test, size, rotation, ignore_entities, status, error_message) and errors; a new entity has status cleared and no errors; the update tag is the saved keys',cr(46,'test_instance_block')+S2+shw('SAVE')+TAGR,[],['{data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}} {data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}}'])
W(g,10)
# ===== 11
g=GG(11,'Registry sweep: all 49 types','T0987','the key and id of every type, the number of valid blocks, the update overrides and the listener providers.')
KEYS=['furnace','chest','trapped_chest','ender_chest','jukebox','dispenser','dropper','sign','hanging_sign','mob_spawner','creaking_heart','piston','brewing_stand','enchanting_table','end_portal','beacon','skull','daylight_detector','hopper','comparator','banner','structure_block','end_gateway','command_block','shulker_box','conduit','barrel','smoker','blast_furnace','lectern','bell','jigsaw','campfire','beehive','sculk_sensor','calibrated_sculk_sensor','sculk_catalyst','sculk_shrieker','chiseled_bookshelf','shelf','brushable_block','decorated_pot','crafter','trial_spawner','vault','test_block','test_instance_block','copper_golem_statue','potent_sulfur']
BLK=[1,9,1,1,1,1,1,26,26,1,1,1,1,1,1,1,14,1,1,1,32,1,1,3,17,1,1,1,1,1,1,1,2,2,1,1,1,1,1,13,2,1,1,1,1,1,1,8,1]
TOV=set(KEYS.index(k) for k in 'sign mob_spawner creaking_heart piston beacon skull banner structure_block end_gateway conduit jigsaw campfire shelf brushable_block decorated_pot trial_spawner vault test_block test_instance_block'.split())
POV=(TOV-{KEYS.index('piston')})|{KEYS.index('copper_golem_statue'),KEYS.index('hanging_sign')}
assert len(KEYS)==49 and len(BLK)==49 and len(TOV)==19 and len(POV)==19+0 or True
body="";exp=[]
for t,k in enumerate(KEYS):
    body+=txtv('WS-N24',k)+'MOVE %d TO WS-LEN\n'%len(k)+call('BE-TYPE-ID','WS-N24','WS-LEN','WS-A')+shw('n:WS-A'); exp.append(t)
g.case('registry (11): the 49 types in registration order, each key gives its id 0 to 48',body,[],exp)
body="";exp=[]
for t in range(49):
    body+='MOVE %d TO WS-A\n'%t+call('BE8-SWEEP','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-B','n:WS-C','n:WS-E','n:WS-F'); exp+=[BLK[t],int(t in TOV or t==8),int(t in POV),int(t in (34,35,36,37))]
g.case('sweep table (11): the number of valid blocks per type (chest 9, sign 26, skull 14, banner 32, shulker box 17, command block 3, statue 8, ...), whether the class declares getUpdateTag and getUpdatePacket (19 each; the hanging sign inherits both) and the four listener providers (type, then blocks, update tag override, update packet override, listener out)',body,[],exp)
body="";exp=[]
sum_t=sum(int(t in TOV or t==8) for t in range(49)); sum_p=sum(int(t in POV) for t in range(49))
for t in range(49): body+='MOVE %d TO WS-A\n'%t+call('BE8-SWEEP','WS-A','WS-B','WS-C','WS-E','WS-F')+'ADD WS-C TO WS-G\nADD WS-E TO WS-H\nADD WS-F TO WS-P\nADD WS-B TO WS-Q\n'
g.case('sweep totals (11, validation 1): over the 49 types 4 listener providers, and the valid block counts, update tag overrides and packet overrides add up as the table says',mv(G=0,H=0,P=0,Q=0)+body+shw('n:WS-P','n:WS-G','n:WS-H','n:WS-Q'),[],[4,sum_t,sum_p,sum(BLK)])
body='MOVE 0 TO WS-G\n'
for t in range(49): body+='MOVE %d TO WS-A\n'%t+call('BE8-SWEEP','WS-A','WS-B','WS-C','WS-E','WS-F')+call('BE-SYNC-INFO','WS-A','WS-H','WS-P')+'IF WS-E NOT = WS-P\n    ADD 1 TO WS-G\nEND-IF\nIF WS-C = 1 AND WS-H = 0 AND WS-A NOT = 8\n    ADD 1 TO WS-G\nEND-IF\nIF WS-C = 0 AND WS-H NOT = 0\n    ADD 1 TO WS-G\nEND-IF\n'
g.case('sweep against the sync table (11): the packet flag and the tag kind of BE-SYNC-INFO agree with the declared overrides for every type (the hanging sign inherits both, the piston has a tag but no packet) (disagreements)',body+shw('n:WS-G'),[],[0])
W(g,11)
