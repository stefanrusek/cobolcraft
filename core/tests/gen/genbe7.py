from genbex import *
ONLY=only()
# Independent Python models of docs/protocol/31-block-entities-7-spawners-trial-vaults.md (T0955 to T0966; core/src/be-31-7.cob, BE7- programs).
def GG(n,subj,tasks,desc): return mk(None,n,subj,tasks,desc,7)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_7_%d.cob'%n)
def SP(): return cr(9,'spawner')
def TS(): return cr(43,'trial_spawner')
def VA(): return cr(44,'vault')
def begin(): return nb_begin()
def load(): return 'PERFORM LOAD-BUFFER\n'
S2=render(2)
TAGR='CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nMOVE 0 TO WS-LEN\nMOVE SPACES TO WS-OUT\nCALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN\nCALL "PB-FREE" USING PB-BUFFER\nSTRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR\n'
def sd(idv,rules=None):
    s=nb_c('entity')+(nb_s('id',idv) if idv else '')+nb_e()
    if rules: s+=nb_c('custom_spawn_rules')+nb_c('block_light_limit')+nb_i('min_inclusive',rules[0])+nb_i('max_inclusive',rules[1])+nb_e()+nb_c('sky_light_limit')+nb_i('min_inclusive',rules[2])+nb_i('max_inclusive',rules[3])+nb_e()+nb_e()
    return s
# ===== 1
g=GG(1,'Scope and decisions','T0955','the three types of the spawner family with their ids, keys and operator flags.')
body="";exp=[]
for k,t,op in [('mob_spawner',9,1),('trial_spawner',43,1),('vault',44,0)]:
    body+=txtv('WS-N24',k)+'MOVE %d TO WS-LEN\n'%len(k)+call('BE-TYPE-ID','WS-N24','WS-LEN','WS-A')+'MOVE WS-A TO WS-B\n'+call('BE-TYPE-INFO','WS-B','WS-N24','WS-LEN','WS-C')+shw('n:WS-A','t:WS-N24,WS-LEN','n:WS-C'); exp+=[t,k,op]
g.case('decisions (1): the three types are registered under mob_spawner 9, trial_spawner 43 and vault 44; the two spawners are operator-only for block_entity_data items, the vault is not (31-1 3.2)',body,[],exp)
W(g,1)
# ===== 2
g=GG(2,'Registration, blocks, tickers','T0957','blocks, tickers by side, light levels and update tag kinds.')
body="";exp=[]
for t,b,r in [(9,'spawner',1),(43,'trial_spawner',1),(44,'vault',1),(9,'trial_spawner',0),(44,'spawner',0),(43,'vault',0)]:
    body+='MOVE %d TO WS-A\n'%t+key('minecraft:'+b)+call('BE-VALID-BLOCK','WS-A','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(r)
g.case('valid blocks (2): each type has exactly one valid block, spawner, trial_spawner and vault',body,[],exp)
body="";exp=[]
for t,kind,pk in [(9,3,1),(43,7,1),(44,8,1)]:
    body+='MOVE %d TO WS-A\n'%t+call('BE-SYNC-INFO','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[kind,pk]
g.case('update tags (2, 3.2, 4.5, 5.4): the spawner tag is the custom form minus SpawnPotentials (kind 3), the trial spawner kind 7 and the vault kind 8; all three send the Block Entity Data packet',body,[],exp)
body="";exp=[]
for t,r in [(9,(1,2)),(43,(3,4)),(44,(5,6)),(1,(0,0))]:
    body+='MOVE %d TO WS-A\n'%t+call('BE7-REGISTRATION','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=list(r)
g.case('tickers (2): the spawner has BaseSpawner.serverTick (1) and clientTick (2), the trial spawner tickServer (3) and tickClient (4), the vault Server.tick (5) and Client.tick (6); other types none',body,[],exp)
body="";exp=[]
for st,l in enumerate([0,4,8,8,8,0]):
    body+='MOVE 43 TO WS-A\nMOVE %d TO WS-B\n'%st+call('BE7-LIGHT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(l)
for st in range(4):
    body+='MOVE 44 TO WS-A\nMOVE %d TO WS-B\n'%st+call('BE7-LIGHT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(6 if st==0 else 12)
body+='MOVE 9 TO WS-A\nMOVE 1 TO WS-B\n'+call('BE7-LIGHT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(0)
g.case('light levels (2): trial spawner 0, 4, 8, 8, 8, 0 by state in order, vault inactive 6 and the other three states 12 (type, state in)',body,[],exp)
W(g,2)
# ===== 3
g=GG(3,'Mob spawner','T0959','saved keys and their order, shorts, the spawn data and potentials, the weighted pick, the update tag, the block event, edits and the engine facts.')
g.case('fresh spawner (3.1): the seven numbers as shorts with the defaults 20, 200, 800, 4, 6, 16, 4 and the always written SpawnPotentials with one entry of weight 1 holding the empty spawn data',SP()+S2+shw('SAVE'),[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},weight:1}]}'])
g.case('spawn data (3.1, example 7.3): the id is normalised to minecraft:zombie, SpawnData is written when present, and the default SpawnPotentials is one entry of the current spawn data with weight 1',SP()+begin()+nb_c('SpawnData')+sd('zombie')+nb_e()+load()+S2+shw('SAVE'),[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{id:minecraft:zombie}},SpawnPotentials:[{data:{entity:{id:minecraft:zombie}},weight:1}]}'])
g.case('custom spawn rules (3.1): block_light_limit and sky_light_limit as inclusive ranges are kept; a limit outside 0 to 15 or an invalid id drops the rules or the id',SP()+begin()+nb_c('SpawnData')+sd('minecraft:skeleton',(2,7,0,15))+nb_e()+load()+S2+shw('SAVE')+SP()+begin()+nb_c('SpawnData')+sd('Bad Id',(0,16,0,15))+nb_e()+load()+shw('SAVE'),[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{id:minecraft:skeleton},custom_spawn_rules:{block_light_limit:{min_inclusive:2,max_inclusive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{data:{entity:{id:minecraft:skeleton},custom_spawn_rules:{block_light_limit:{min_inclusive:2,max_inclusive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},weight:1}]} {Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{}},SpawnPotentials:[{data:{entity:{}},weight:1}]}'])
def pot(entries):
    s=nb_l('SpawnPotentials',10,len(entries))
    for idv,w in entries:
        s+=nb_c('data')+sd(idv)+nb_e()+(nb_i('weight',w) if w is not None else '')+nb_e()
    return s
H='{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,'
g.case('potentials (3.1): explicit entries {data, weight} are kept in order; an entry without weight or with a negative weight fails the list, which then falls back to the default one entry list',SP()+begin()+pot([('minecraft:zombie',3),('minecraft:spider',5)])+load()+S2+shw('SAVE','n:BE-XI(WS-IDX, 15)')+SP()+begin()+nb_c('SpawnData')+sd('minecraft:pig')+nb_e()+pot([('minecraft:zombie',None)])+load()+shw('SAVE','n:BE-XI(WS-IDX, 15)')+SP()+begin()+pot([('minecraft:zombie',-1)])+load()+shw('SAVE'),[],[H+'SpawnPotentials:[{data:{entity:{id:minecraft:zombie}},weight:3},{data:{entity:{id:minecraft:spider}},weight:5}]} 2 '+H+'SpawnData:{entity:{id:minecraft:pig}},SpawnPotentials:[{data:{entity:{id:minecraft:pig}},weight:1}]} 0 '+H+'SpawnPotentials:[{data:{entity:{}},weight:1}]}'])
g.case('numbers (3.1): MinSpawnDelay, MaxSpawnDelay, SpawnCount, MaxNearbyEntities, RequiredPlayerRange and SpawnRange load from shorts or ints, Delay only from a short; the values save as shorts, a value above 32767 wraps',SP()+begin()+nb_i('Delay',5)+nb_i('MinSpawnDelay',500)+'MOVE 3 TO WS-NV\nMOVE "SpawnCount" TO WS-NM\nMOVE 10 TO WS-NML\nCALL "NBT-WRITE-SHORT" USING PB-BUFFER WS-NM WS-NML WS-NV\n'+nb_i('MaxSpawnDelay',40000)+load()+S2+shw('SAVE'),[],['{Delay:20,MinSpawnDelay:500,MaxSpawnDelay:-25536,SpawnCount:3,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},weight:1}]}'])
g.case('update tag (3.2): the custom form with SpawnPotentials removed, the client keeps only the current SpawnData',SP()+begin()+nb_c('SpawnData')+sd('minecraft:zombie')+nb_e()+load()+TAGR,[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnData:{entity:{id:minecraft:zombie}}}'])
body="";exp=[]
for side,ev,hd,d in [(0,1,1,20),(1,1,1,200),(1,2,0,20),(0,3,0,20)]:
    body+=SP()+'MOVE 300 TO BE-XI(WS-IDX, 2)\n'+mv(A=side,B=ev)+call('BE7-SPAWNER-EVENT','WS-IDX','WS-B','WS-A','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 1)'); exp+=[hd,300 if (side==1 and ev==1) else 20]
g.case('block event (3.2): id 1 is handled; on the client it sets the delay to MinSpawnDelay, on the server it has no effect; another id is not handled (side, event id in)',body,[],exp)
def pick(ws,draw):
    r=draw
    for i,w in enumerate(ws):
        r-=w
        if r<0: return i+1
    return 0
body="";exp=[]
for ws,d in [([1,2,3],0),([1,2,3],1),([1,2,3],2),([1,2,3],3),([1,2,3],5),([5],4),([],0),([0,0],0),([0,4],0)]:
    body+=''.join('MOVE %d TO WS-TV(%d)\n'%(w,i+1) for i,w in enumerate(ws))+'MOVE %d TO WS-A\nMOVE %d TO WS-B\n'%(len(ws),d)+call('BE7-WEIGHT-TOTAL','WS-TAB','WS-A','WS-C')+call('BE7-WEIGHT-PICK','WS-TAB','WS-A','WS-B','WS-E')+shw('n:WS-C','n:WS-E'); exp+=[sum(ws),pick(ws,d) if sum(ws)>0 else 0]
g.case('weighted pick (3.1): the total weight, then one draw below the total walks the entries in order subtracting each weight; an empty list or a zero total gives none (weights, count, draw in; total, entry out)',body,[],exp)
body="";exp=[]
for d2,rng in [(9,16),(256,16),(257,16),(1,-1),(0,0),(100,0)]:
    body+=mv(A=d2,B=rng)+call('BE7-NEARBY','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(rng<0 or d2<rng*rng))
g.case('nearby player (3.4 item 1): a living non-spectator player within the range (squared distance below range squared) or any such player for a negative range (distance squared, range in)',body,[],exp)
body="";exp=[]
for bl,sl,fr,pe,lim in [(3,10,1,0,(2,7,0,15)),(1,10,1,0,(2,7,0,15)),(8,10,1,0,(2,7,0,15)),(3,0,1,0,(2,7,1,15)),(3,16,1,0,(2,7,0,15)),(3,10,0,1,(2,7,0,15)),(3,10,0,0,(2,7,0,15)),(3,10,1,1,(2,7,0,15))]:
    body+=SP()+'MOVE %d TO BE-XI(WS-IDX, 10)\nMOVE %d TO BE-XI(WS-IDX, 11)\nMOVE %d TO BE-XI(WS-IDX, 12)\nMOVE %d TO BE-XI(WS-IDX, 13)\n'%lim+mv(A=bl,B=sl,C=fr,E=pe)+call('BE7-CUSTOM-RULES','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
    exp.append(int(lim[0]<=bl<=lim[1] and lim[2]<=sl<=lim[3] and (fr or not pe)))
g.case('custom spawn rules (3.4 item 2): block light and sky light inside their inclusive limits, and a mob category that is not friendly fails on Peaceful (block light, sky light, friendly, peaceful in)',body,[],exp)
body="";exp=[]
for mn,mx,dr in [(200,800,0),(200,800,599),(500,300,77),(500,500,0),(0,1,0)]:
    body+=mv(A=mn,B=mx,C=dr)+call('BE7-DELAY','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E'); exp.append(mn+dr if mx>mn else mn)
g.case('delay (7.2): MinSpawnDelay + nextInt(Max - Min) (200 to 799 for 200 and 800), exactly the minimum when the maximum is not above it (min, max, draw in)',body,[],exp)
body=cr(9,'spawner',10,64,-3)+fv(A='0.75',B='0.25',C='0.10',D='0.60')+'MOVE 2 TO WS-A\n'+call('BE7-SPAWN-POS','WS-IDX','WS-FA','WS-FB','WS-A','WS-FC','WS-FD','WS-FE','WS-FF','WS-FG','WS-TAB')+shw('f:WS-FE','f:WS-FF','f:WS-FG',*['n:WS-TV(%d)'%i for i in range(1,7)])
g.case('position draws (7.1): spawner at (10, 64, -3), range 4, draws 0.75, 0.25, 2, 0.10, 0.60 give (12.5, 65, -4.5) and the crowd box (6, 60, -7) to (15, 69, 2)',body,[],[12.5,65,-4.5,6,60,-7,15,69,2])
body="";exp=[]
for d1,d2 in [(0,0),(14,14),(14,0),(0,14)]:
    body+=mv(A=d1,B=d2)+call('BE7-BREAK-XP','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(15+d1+d2)
g.case('breaking (3.5): a broken spawner pays 15 + nextInt(15) + nextInt(15) experience, 15 to 43 (the two draws in)',body,[],exp)
body=SP()+begin()+nb_c('SpawnData')+sd('minecraft:zombie',(2,7,0,15))+nb_e()+nb_l('SpawnPotentials',10,1)+nb_c('data')+sd('minecraft:pig')+nb_e()+nb_i('weight',2)+nb_e()+load()+txtv('WS-T64','minecraft:cow')+'MOVE 13 TO WS-LEN\n'+call('BE7-SET-ENTITY-ID','WS-IDX','WS-T64','WS-LEN')+S2+shw('SAVE')
body+=SP()+txtv('WS-T64','sheep')+'MOVE 5 TO WS-LEN\n'+call('BE7-SET-ENTITY-ID','WS-IDX','WS-T64','WS-LEN')+shw('SAVE')
g.case('setEntityId (3.3): only the id of the current spawn data changes, rules and potentials stay; with no spawn data one is created; the id is normalised',body,[],[H+'SpawnData:{entity:{id:minecraft:cow},custom_spawn_rules:{block_light_limit:{min_inclusive:2,max_inclusive:7},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{data:{entity:{id:minecraft:pig}},weight:2}]} '+H+'SpawnData:{entity:{id:minecraft:sheep}},SpawnPotentials:[{data:{entity:{id:minecraft:sheep}},weight:1}]}'])
L3=SP()+begin()+nb_c('SpawnData')+nb_c('entity')+nb_i('Pos',1)+nb_s('id','zombie')+nb_e()+nb_i('zzz',1)+nb_c('custom_spawn_rules')+nb_i('foo',1)+nb_c('block_light_limit')+nb_i('junk',1)+nb_i('min_inclusive',1)+nb_i('max_inclusive',5)+nb_e()+nb_e()+nb_e()+nb_l('SpawnPotentials',3,1)+nb_i(None,5)+load()+S2+shw('SAVE')
L3+=SP()+begin()+nb_l('SpawnPotentials',10,1)+nb_c('data')+sd('minecraft:pig')+nb_e()+nb_i('weight',2)+nb_i('extra',1)+nb_e()+load()+shw('SAVE')
g.case('unknown keys (3.1): keys the spawn data does not know are skipped, an entity key other than id is not kept, a limit pair keeps its other value; a potentials list of the wrong element type or an entry with an extra key is read leniently (the first fails the list, the second keeps its entry)',L3,[],[H+'SpawnData:{entity:{id:minecraft:zombie},custom_spawn_rules:{block_light_limit:{min_inclusive:1,max_inclusive:5},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},SpawnPotentials:[{data:{entity:{id:minecraft:zombie},custom_spawn_rules:{block_light_limit:{min_inclusive:1,max_inclusive:5},sky_light_limit:{min_inclusive:0,max_inclusive:15}}},weight:1}]} '+H+'SpawnPotentials:[{data:{entity:{id:minecraft:pig}},weight:2}]}'])
g.case('setEntityId (3.3): an id that is no identifier leaves the spawn data with an empty entity',SP()+txtv('WS-T64','Bad Id')+'MOVE 6 TO WS-LEN\n'+call('BE7-SET-ENTITY-ID','WS-IDX','WS-T64','WS-LEN')+S2+shw('SAVE'),[],[H+'SpawnData:{entity:{}},SpawnPotentials:[{data:{entity:{}},weight:1}]}'])
W(g,3)
# ===== 4
g=GG(4,'Trial spawner','T0961','saved keys, the apply-with-defaults and all-or-nothing rules, the update tag, the derived totals, tracking, detection and ejection facts.')
TD='{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,target_cooldown_length:36000,required_player_range:14}'
g.case('fresh trial spawner (4.1): empty player and mob lists, times 0, total 0, and the default cooldown length 36000 and range 14 (no config references)',TS()+S2+shw('SAVE'),[],[TD])
def lst(name,arrs):
    s=nb_l(name,11,len(arrs))
    for a in arrs: s+=nb_intarr(None,a)
    return s
L=begin()+lst('registered_players',[[1,2,3,4]])+lst('current_mobs',[[5,6,7,8],[9,10,11,12]])+nb_long('cooldown_ends_at',1234)+nb_long('next_mob_spawns_at',99)+nb_i('total_mobs_spawned',3)+nb_c('spawn_data')+sd('minecraft:zombie')+nb_e()+nb_s('ejecting_loot_table','minecraft:spawners/trial_chamber/key')+nb_s('normal_config','minecraft:trial_chamber/melee/zombie/normal')+nb_s('ominous_config','minecraft:trial_chamber/melee/zombie/ominous')+nb_i('target_cooldown_length',100)+nb_i('required_player_range',20)
FULL='{registered_players:[I[1,2,3,4]],current_mobs:[I[5,6,7,8],I[9,10,11,12]],cooldown_ends_at:1234,next_mob_spawns_at:99,total_mobs_spawned:3,spawn_data:{entity:{id:minecraft:zombie}},ejecting_loot_table:minecraft:spawners/trial_chamber/key,normal_config:minecraft:trial_chamber/melee/zombie/normal,ominous_config:minecraft:trial_chamber/melee/zombie/ominous,target_cooldown_length:100,required_player_range:20}'
g.case('round trip (4.1): state data keys then configuration keys in order; the UUID sets are lists of int arrays of 4',TS()+L+load()+S2+shw('SAVE','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)'),[],[FULL+' 1 2'])
g.case('apply with defaults (4.1, validation 7): a tag with only next_mob_spawns_at empties the sets and resets every other field; the full configuration falls back to the defaults',TS()+begin()+nb_long('next_mob_spawns_at',7)+load()+S2+shw('SAVE'),[],[TD.replace('next_mob_spawns_at:0','next_mob_spawns_at:7')])
g.case('lenient state keys (4.1): a total below 0 or a key of the wrong tag type takes the default',TS()+begin()+nb_i('total_mobs_spawned',-4)+nb_s('cooldown_ends_at','x')+load()+S2+shw('SAVE'),[],[TD])
body=TS()+begin()+nb_s('normal_config','a:b')+nb_i('target_cooldown_length',50)+nb_i('required_player_range',200)+nb_s('ominous_config','a:c')+load()+S2+shw('SAVE')
body+=TS()+begin()+nb_s('normal_config','a:b')+nb_i('required_player_range',0)+load()+shw('SAVE')+TS()+begin()+nb_s('normal_config','a:b')+nb_s('target_cooldown_length','x')+load()+shw('SAVE')+TS()+begin()+nb_i('target_cooldown_length',-1)+load()+shw('SAVE')+TS()+begin()+nb_s('normal_config','a:b')+nb_i('target_cooldown_length',9)+nb_i('required_player_range',128)+load()+shw('SAVE')
g.case('all-or-nothing configuration (4.1, validation 7): a present key that is out of range (range 200, range 0, a negative cooldown) or undecodable makes the whole configuration the built-in default, the references and the other numbers included; valid keys (range 128) are kept',body,[],[TD,TD,TD,TD,'{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,normal_config:a:b,target_cooldown_length:9,required_player_range:128}'])
body="";exp=[]
for st,ns,sd_ in [(2,5,1),(0,5,1),(2,5,0),(1,5,0)]:
    body+=TS()+'MOVE %d TO BE-STATUS(WS-IDX)\nMOVE %d TO BE-TIME2(WS-IDX)\nMOVE %d TO BE-XI(WS-IDX, 4)\nMOVE "minecraft:zombie" TO BE-XT(WS-IDX, 1)\nMOVE 16 TO BE-XI(WS-IDX, 5)\n'%(st,ns,sd_)+TAGR
    parts=[]
    if st==2: parts.append('next_mob_spawns_at:5')
    if sd_: parts.append('spawn_data:{entity:{id:minecraft:zombie}}')
    exp.append('{'+','.join(parts)+'}')
g.case('update tag (4.5, validation 8): next_mob_spawns_at only in state active (state 2 of the six, held in BE-STATUS from the block), spawn_data when present, nothing else',body,[],exp)
import math
body="";exp=[]
for tm,tp,sm,sp,extra in [(6.0,2.0,2.0,1.0,0),(6.0,2.0,2.0,1.0,2),(2.0,1.0,1.0,0.5,0),(2.0,1.0,1.0,0.5,1),(2.0,1.0,1.0,0.5,2),(4.0,0.0,2.0,0.5,2),(4.0,0.0,2.0,0.5,0)]:
    body+='COMPUTE WS-FS1 = %s\n'%tm+'COMPUTE WS-FS2 = %s\n'%tp+'COMPUTE WS-FS3 = %s\nCOMPUTE WS-FS4 = %s\nMOVE %d TO WS-A\n'%(sm,sp,extra)+call('BE7-TRIAL-TOTALS','WS-FS1','WS-FS2','WS-FS3','WS-FS4','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C')
    exp+=[math.floor(tm+tp*extra),math.floor(sm+sp*extra)]
g.case('derived totals (4.2, example 7.4): targetTotalMobs = floor(total + per player * extra) and targetSimultaneousMobs likewise (default 6 and 2, breeze normal 2 and 1, breeze ominous 4 and 2; total, per player, simultaneous, simultaneous per player, extra in)',body,[],exp)
g.case('default configuration (4.2): spawn_range 4, total 6.0, simultaneous 2.0, 2.0 and 1.0 per extra player, 40 ticks between spawns, the item spawner constant 160 and the loot table keys',call('BE7-TRIAL-DEFAULT','WS-A','WS-FS1','WS-FS2','WS-FS3','WS-FS4','WS-B','WS-C')+shw('n:WS-A','n:WS-FS1','n:WS-FS2','n:WS-FS3','n:WS-FS4','n:WS-B','n:WS-C'),[],[4,6,2,2,1,40,160])
body="";exp=[]
for f,al,dm,d2 in [(1,1,1,100),(1,1,1,2209),(1,1,1,2210),(0,1,1,5),(1,0,1,5),(1,1,0,5)]:
    body+=mv(A=f,B=al,C=dm,E=d2)+call('BE7-UNTRACKED','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(not f or not al or not dm or d2>2209))
g.case('untracked rule (4.3 item 2): a mob that is missing, not alive, in another dimension or farther than squared distance 2209 (strictly) is removed (found, alive, same dimension, squared distance in)',body,[],exp)
body="";exp=[]
def packed(x,y,z): return ((x&0x3FFFFFF)<<38)|((z&0x3FFFFFF)<<12)|(y&0xFFF)
for x,y,z,t in [(0,70,0,0),(0,0,0,20),(10,70,9,3),(-5,64,7,13),(100,-3,-8,77)]:
    pk=packed(x,y,z); pk=pk-(1<<64) if pk>>63 else pk
    body+=mv(A=x,B=y,C=z)+'MOVE %d TO WS-LONG2\n'%t+call('BE7-PACK-POS','WS-A','WS-B','WS-C','WS-LONG1')+call('BE7-DETECT-THROTTLE','WS-LONG1','WS-LONG2','WS-E')+shw('n:FUNCTION MOD(WS-LONG1, 1000000007)','n:FUNCTION INTEGER(WS-LONG1 / 4294967296)','n:WS-E')
    exp+=[pk%1000000007,pk//4294967296,int((pk+t)%20==0)]
g.case('detection throttle (4.3 item 6): BlockPos.asLong (x 26 bits at 38, z 26 bits at 12, y 12 bits) plus the game time modulo 20 must be 0 (shown as the packed value modulo 1000000007, its upper half and the flag)',body,[],exp)
body="";exp=[]
for d2,rg,cr_,sp,inc,los,clear in [(181,14,0,0,0,0,0),(196,14,0,0,0,0,0),(100,14,1,0,0,0,0),(100,14,1,0,1,0,0),(100,14,0,1,1,0,0),(100,14,0,0,0,1,0),(100,14,0,0,0,1,1)]:
    body+=mv(A=d2,B=rg,C=cr_,E=sp,F=inc,G=los,H=clear)+call('BE7-PLAYER-DETECT','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-P')
    exp.append(int(d2<rg*rg and not sp and (inc or not cr_) and (not los or clear)))
g.case('player filter (4.3 item 7, example 7.7): strictly inside the range squared (181 of 196 yes, 196 no), not a spectator, not creative unless the detector includes creative players, and a clear visual ray when line of sight is asked (squared distance, range, creative, spectator, includes creative, line of sight needed, ray clear in)',body,[],exp)
body="";exp=[]
def plan(st,om,l1,omen,stored):
    if st==5 and om: return (1,0,0,0)
    ao=int((not om) and l1>0 and omen)
    stop=int(st==5 and not ao)
    src=1 if stored==0 else 2
    return (0,ao,stop,src)
for st,om,l1,omen,stored in [(5,1,2,0,0),(5,0,2,1,0),(5,0,2,0,0),(1,0,2,1,0),(1,0,0,1,0),(1,0,2,0,3),(1,1,2,1,0),(0,0,0,0,1)]:
    body+=mv(A=st,B=om,C=l1,E=omen,F=stored)+call('BE7-DETECT-PLAN','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P','WS-Q')+shw('n:WS-G','n:WS-H','n:WS-P','n:WS-Q'); exp+=list(plan(st,om,l1,omen,stored))
g.case('detection plan (4.3 item 6): an ominous spawner in cooldown does not detect; a non-ominous one becomes ominous when a listed player has the trial_omen effect; in cooldown without that it stops; the first detection (line of sight) is the candidate list when nothing is stored, else a second detection without line of sight (state 5 cooldown, ominous, step 1 count, omen player, stored count in; early return, apply ominous, stop, source out)',body,[],exp)
body="";exp=[]
for t,nx,added,omen,om in [(100,0,1,0,0),(100,500,1,0,1),(100,120,2,1,0),(100,50,0,0,0)]:
    body+=TS()+'MOVE %d TO BE-TIME2(WS-IDX)\nMOVE %d TO WS-LONG1\n'%(nx,t)+mv(A=added,B=omen,C=om)+call('BE7-DETECT-ADDED','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E','n:BE-TIME2(WS-IDX)')
    if added==0: exp+=[0,nx]
    else: exp+=[0 if omen else (3019 if om else 3013),max(t+40,nx)]
g.case('players added (4.3 item 6): next_mob_spawns_at becomes max(game time + 40, itself), and level event 3019 (ominous) or 3013 follows unless the omen flag is set; nothing when nobody was added (game time, added, omen flag, ominous in; event out)',body,[],exp)
body="";exp=[]
for t,ce,tg,det in [(60,36060,36000,2),(61,36060,36000,2),(90,36060,36000,2),(120,36060,36000,0),(30,36000,36000,1)]:
    body+='MOVE %d TO WS-LONG1\nMOVE %d TO WS-LONG2\n'%(t,ce)+mv(A=tg,B=det)+call('BE7-EJECT-TICK','WS-LONG1','WS-LONG2','WS-A','WS-B','WS-C')+shw('n:WS-C')
    exp.append(int(((t-(ce-tg))%30==0) and det>0))
g.case('ejection (4.3 item 10, example 7.6): a reward is ejected once per detected player on a tick with (game time - (cooldown_ends_at - target cooldown)) mod 30 = 0 (game time, cooldown end, cooldown length, detected players in)',body,[],exp)
body="";exp=[]
for n_ in (0,1,3):
    body+=mv(A=n_)+call('BE7-EJECT-EVENT','WS-A','WS-B')+shw('n:WS-B'); exp.append(3014 if n_ else 0)
g.case('ejection event (4.3 item 10): level event 3014 only when the roll produced at least one stack',body,[],exp)
body="";exp=[]
for sw,ov,pe,sm in [(0,1,0,1),(1,1,1,0),(1,0,1,1),(1,0,0,0),(1,0,0,1)]:
    body+=mv(A=sw,B=ov,C=pe,E=sm)+call('BE7-CAN-SPAWN','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
    exp.append(0 if not sw else 1 if ov else int((not pe) and sm))
g.case('canSpawnInLevel (4.3 item 5): false without spawner_blocks_work, true with the override, else not on Peaceful and only when spawn_mobs holds (work rule, override, peaceful, spawn_mobs in)',body,[],exp)
body="";exp=[]
for sd2,idl,pc in [(1,16,0),(0,0,2),(0,0,0),(1,0,0)]:
    body+=TS()+'MOVE %d TO BE-XI(WS-IDX, 4)\nMOVE %d TO BE-XI(WS-IDX, 5)\n'%(sd2,idl)+mv(A=pc)+call('BE7-HAS-MOB','WS-IDX','WS-A','WS-B')+shw('n:WS-B'); exp.append(int(idl>0 or pc>0))
g.case('hasMobToSpawn (4.3 item 9): the stored entity compound has an id, or the potentials list is not empty (spawn data set, id length, potentials count in)',body,[],exp)
body="";exp=[]
def jfloor(x): return math.floor(f32(x))
for sx,x,y,z in [(1000,0,0,0),(1000,59,39,61),(-5,-1,-1,-1),(123456789,300,200,-301),(9223372036854775800,30,0,0),(-9223372036854775800,-30,0,0)]:
    pk=packed(jfloor(f32(x)/f32(30)),jfloor(f32(y)/f32(20)),jfloor(f32(z)/f32(30)))
    pk=pk-(1<<64) if pk>>63 else pk
    r=(sx+pk+(1<<63))%(1<<64)-(1<<63)
    body+='MOVE %d TO WS-LONG1\n'%sx+mv(A=x,B=y,C=z)+call('BE7-ITEM-SEED','WS-LONG1','WS-A','WS-B','WS-C','WS-LONG2')+shw('n:FUNCTION MOD(WS-LONG2, 1000000007)'); exp.append(r%1000000007)
g.case('ominous item loot seed (4.3 item 11): level seed + the packed BlockPos of (floor(x / 30.0f), floor(y / 20.0f), floor(z / 30.0f)) (shown modulo 1000000007)',body,[],exp)
L4=TS()+begin()+nb_l('registered_players',8,2)+nb_s(None,'a')+nb_s(None,'b')+nb_l('current_mobs',11,1)+nb_intarr(None,[1,2,3])+nb_s('normal_config','a:b')+nb_i('normal_config',5)+load()+S2+shw('SAVE','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')
L4+=TS()+begin()+nb_c('normal_config')+nb_s('x','y')+nb_e()+nb_s('ominous_config','a:o')+load()+shw('SAVE')
g.case('lenient lists and inline configuration (4.1): a list of strings is no player set, an int array of 3 is no UUID, a configuration key of the wrong tag type fails the configuration, an inline configuration compound is skipped (its reference stays the default) while a valid reference after it is kept',L4,[],['{registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,target_cooldown_length:36000,required_player_range:14} 0 0 {registered_players:[],current_mobs:[],cooldown_ends_at:0,next_mob_spawns_at:0,total_mobs_spawned:0,ominous_config:a:o,target_cooldown_length:36000,required_player_range:14}'])
W(g,4)
# ===== 5
g=GG(5,'Vault','T0963','saved config, shared and server data, the update tag, the state machine, key insertion, display and ejection.')
VD='{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range:4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{connected_players:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}'
g.case('fresh vault (5.2, 5.3): the default config (loot table minecraft:chests/trial_chambers/reward, ranges 4.0 and 4.5, key minecraft:trial_key x 1), empty shared and server data; the keys are config, shared_data, server_data',VA()+S2+shw('SAVE'),[],[VD])
def vlist(name,arrs): return lst(name,arrs)
def item(n,idv,c): return nb_c(n)+nb_s('id',idv)+nb_i('count',c)+nb_e()
L=begin()+nb_c('config')+nb_s('loot_table','a:loot')+nb_double('activation_range','1.5')+nb_double('deactivation_range','2.5')+item('key_item','a:key',2)+nb_s('override_loot_table_to_display','a:show')+nb_e()
L+=nb_c('shared_data')+item('display_item','a:gem',3)+lst('connected_players',[[1,2,3,4]])+nb_double('connected_particles_range','3.5')+nb_e()
L+=nb_c('server_data')+lst('rewarded_players',[[9,8,7,6],[5,4,3,2]])+nb_long('state_updating_resumes_at',500)+nb_l('items_to_eject',10,2)+nb_s('id','a:x')+nb_i('count',1)+nb_e()+nb_s('id','a:y')+nb_i('count',2)+nb_e()+nb_i('total_ejections_needed',5)+nb_e()
FV='{config:{loot_table:a:loot,activation_range:1.500,deactivation_range:2.500,key_item:{id:a:key,count:2},override_loot_table_to_display:a:show},shared_data:{display_item:{id:a:gem,count:3},connected_players:[I[1,2,3,4]],connected_particles_range:3.500},server_data:{rewarded_players:[I[9,8,7,6],I[5,4,3,2]],state_updating_resumes_at:500,items_to_eject:[{id:a:x,count:1},{id:a:y,count:2}],total_ejections_needed:0}}'
g.case('round trip (5.2, 5.3): config, shared_data and server_data load and save back; total_ejections_needed is saved but not restored (the quirk of 5.3, so the next save holds 0)',VA()+L+load()+S2+shw('SAVE','n:BE-XI(WS-IDX, 59)','n:BE-XI(WS-IDX, 60)'),[],[FV+' 2 0'])
DEFC='{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range:4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{connected_players:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}'
body=VA()+begin()+nb_c('config')+nb_double('activation_range','5.0')+nb_double('deactivation_range','4.0')+nb_s('loot_table','a:bad')+nb_e()+load()+S2+shw('SAVE')+VA()+begin()+load()+shw('SAVE')
g.case('config rules (5.2): activation_range above deactivation_range rejects the config (the default); no config keeps the default',body,[],[DEFC,DEFC])
body=VA()+begin()+nb_c('config')+nb_s('loot_table','a:ok')+nb_e()+load()+S2+shw('SAVE')+VA()+begin()+nb_c('shared_data')+nb_c('display_item')+nb_s('id','a:g')+nb_e()+nb_e()+load()+shw('SAVE')
g.case('config rules (5.2): a config without key_item has the empty stack (not written); a display item without a count has count 1',body,[],['{config:{loot_table:a:ok,activation_range:4.000,deactivation_range:4.500},shared_data:{connected_players:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}','{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range:4.500,key_item:{id:minecraft:trial_key,count:1}},shared_data:{display_item:{id:a:g,count:1},connected_players:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}'])
g.case('update tag (5.4): a compound with the single key shared_data; the client config is the default config',VA()+L+load()+TAGR,[],['{shared_data:{display_item:{id:a:gem,count:3},connected_players:[I[1,2,3,4]],connected_particles_range:3.500}}'])
body="";exp=[]
for k,st,can in [(19,0,0),(19,1,1),(19,3,1),(0,1,0)]:
    body+=VA()+'MOVE %d TO BE-XI(WS-IDX, 1)\n'%k+mv(A=st)+call('BE7-VAULT-CAN-EJECT','WS-IDX','WS-A','WS-B')+shw('n:WS-B'); exp.append(can)
g.case('canEjectReward (5.7): the key item is not empty and the state is not inactive (key length, state in)',body,[],exp)
body=VA()+'MOVE 1 TO WS-A\n'+txtv('WS-T64','a:gem')+'MOVE 5 TO WS-LEN\nMOVE 3 TO WS-B\n'+call('BE7-VAULT-SET-DISPLAY','WS-IDX','WS-T64','WS-LEN','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 61)')+'MOVE 0 TO BE-XI(WS-IDX, 61)\n'+call('BE7-VAULT-SET-DISPLAY','WS-IDX','WS-T64','WS-LEN','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 61)')+'MOVE 4 TO WS-B\n'+call('BE7-VAULT-SET-DISPLAY','WS-IDX','WS-T64','WS-LEN','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 61)')
g.case('setDisplayItem (5.7): no change when the stack matches the current one (id and count), otherwise the stack is stored and the shared data is dirty (changed out)',body,[],[1,1,0,0,1,4,1])
def nxt(state,k,total,any_):
    if state in (0,1): return (1 if any_ else 0),0,0.0,k,total
    if state==2: return 3,0,0.0,k,total
    if k==0: return (1 if any_ else 0),0,0.0,0,0
    prog=1.0 if total==1 else 1-(k-1)/(total-1) if total!=1 else 1.0
    return 3,1,prog,k-1,total
body="";exp=[]
for st,k,total,any_ in [(0,0,0,1),(0,0,0,0),(1,0,0,1),(1,0,0,0),(2,0,3,1),(3,3,3,1),(3,2,3,1),(3,1,3,1),(3,0,3,1),(3,0,3,0),(3,1,1,1),(3,2,0,1)]:
    ids=['a:i1','a:i2','a:i3']
    body+=VA()+'MOVE %d TO BE-XI(WS-IDX, 59)\nMOVE %d TO BE-XI(WS-IDX, 60)\nMOVE 1000 TO WS-LONG1\n'%(k,total)+''.join('MOVE "%s" TO BE-XT(WS-IDX, %d)\n'%(ids[i],5+i) for i in range(3))+mv(A=st,B=any_)+call('BE7-VAULT-NEXT','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E','WS-FS1')+shw('n:WS-C','n:WS-E','f4:WS-FS1','n:BE-XI(WS-IDX, 59)','n:BE-XI(WS-IDX, 60)','n:BE-SEED(WS-IDX)')
    nx,ej,pr,k2,t2=nxt(st,k,total,any_)
    exp+=[nx,ej,pr,k2,t2,1020]
g.case('state tick (5.5, example 7.8): inactive and active move by the connected players and wait 20 ticks; unlocking goes to ejecting and waits 20; ejecting with items pops the last one with progress 1 - (k - 1) / (total - 1) (0 first, 1 last, 1 for a single item, k when the total is 0 after a reload) and waits 20, with none left it clears the total and decides by the connected players (state, items left, total, any connected in; next state, ejected, progress, items left, total, resume time out)',body,[],exp)
body="";exp=[]
for p in (0.0,0.5,1.0,2.0):
    body+='COMPUTE WS-FS1 = %s\n'%p+call('BE7-VAULT-PITCH','WS-FS1','WS-FS2')+shw('f4:WS-FS2'); exp.append(f32(f32(0.8)+f32(f32(0.4)*f32(p))))
g.case('eject sound (5.7, example 7.8): pitch 0.8 + 0.4 * progress (0.8, 1.0, 1.2 and 1.6 after a reload)',body,[],exp)
body=VA()+'MOVE 3 TO BE-XI(WS-IDX, 59)\nMOVE 0 TO BE-XI(WS-IDX, 60)\nMOVE "a:i1" TO BE-XT(WS-IDX, 5)\nMOVE "a:i2" TO BE-XT(WS-IDX, 6)\nMOVE "a:i3" TO BE-XT(WS-IDX, 7)\nMOVE 4 TO BE-XI(WS-IDX, 6)\nMOVE 1000 TO WS-LONG1\nMOVE 3 TO WS-A\n'+call('BE7-VAULT-NEXT','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E','WS-FS1')+shw('t:BE-XT(WS-IDX, 4)|BE-XI(WS-IDX, 6)')+call('BE7-VAULT-NEXT','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E','WS-FS1')+call('BE7-VAULT-NEXT','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E','WS-FS1')+shw('n:BE-XI(WS-IDX, 6)')
g.case('display after a pop (5.5): the new last item becomes the display item, the empty stack when none is left',body,[],['a:i2',0])
body="";exp=[]
for t,st,r in [(40,1,1),(41,1,0),(40,0,0),(60,1,1)]:
    body+='MOVE %d TO WS-LONG1\n'%t+mv(A=st)+call('BE7-VAULT-GATE','WS-LONG1','WS-A','WS-B')+shw('n:WS-B'); exp.append(r)
for t,rs in [(10,10),(9,10),(11,10)]:
    body+='MOVE %d TO WS-LONG1\nMOVE %d TO WS-LONG2\n'%(t,rs)+call('BE7-VAULT-DUE','WS-LONG1','WS-LONG2','WS-B')+shw('n:WS-B'); exp.append(int(t>=rs))
g.case('tick order (5.5): the display cycle runs when the game time is a multiple of 20 and the state is active; the state tick when the game time reaches state_updating_resumes_at',body,[],exp)
body="";exp=[]
for sh,sv in [(0,0),(0,1),(1,0),(1,1)]:
    body+=VA()+'MOVE %d TO BE-XI(WS-IDX, 61)\nMOVE %d TO BE-XI(WS-IDX, 62)\n'%(sh,sv)+call('BE7-VAULT-SYNC','WS-IDX','WS-A','WS-B')+shw('n:WS-A','n:WS-B','n:BE-XI(WS-IDX, 61)','n:BE-XI(WS-IDX, 62)'); exp+=[int(sh or sv),sh,0,0]
g.case('synchronisation (5.4): a dirty server data or shared data marks the chunk unsaved, only a dirty shared data is sent, both flags are cleared (shared dirty, server dirty in; set changed, send out)',body,[],exp)
body="";exp=[]
for o,n,om in [(1,0,0),(1,0,1),(0,1,0),(0,1,1),(1,2,0),(1,3,0),(3,1,0),(3,0,1)]:
    body+=VA()+mv(A=o,B=n,C=om)+call('BE7-VAULT-HOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-E','n:WS-F','n:WS-G','n:WS-H','n:WS-P')
    ev=3016 if n==0 else 3015 if n==1 else 0
    exp+=[ev,om if ev else 0,{2:1,3:2}.get(n,0),3 if o==3 else 0,int(n==1)]
g.case('transition hooks (5.5): entering inactive sends level event 3016 and entering active 3015 (data 1 when ominous, active also runs the display cycle when there is no display item), entering unlocking plays the insert sound (1), entering ejecting the open shutter (2), leaving ejecting the close shutter (3) (old, new, ominous in; event, data, enter sound, exit sound, cycle out)',body,[],exp)
body=VA()+'MOVE 1 TO BE-XI(WS-IDX, 6)\nMOVE 1 TO WS-A\nMOVE 0 TO WS-B\nMOVE 1 TO WS-C\n'+call('BE7-VAULT-HOOK','WS-IDX','WS-B','WS-A','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-P')
g.case('transition hooks (5.5): entering active with a display item already set does not run the cycle',body,[],[0])
def key(st,klen,held,hl,hc,cre,rewarded,rolled,time,last):
    can= klen>0 and st!=0
    if not can: return (0,0,0)
    valid= held=='a:k' and hc>=2
    if not valid: return (1,int(time>=last+15),0)
    if rewarded: return (2,int(time>=last+15),0)
    if rolled==0: return (3,0,0)
    return (4,0,0 if cre else 2)
body="";exp=[]
CASES=[(1,3,'a:k',1,2,0,0,3,100,0),(0,3,'a:k',1,2,0,0,3,100,0),(1,0,'a:k',1,2,0,0,3,100,0),(1,3,'a:o',1,5,0,0,3,100,0),(1,3,'a:k',1,1,0,0,3,100,0),(1,3,'a:k',1,2,0,0,3,100,95),(1,3,'a:k',1,2,0,1,3,100,0),(1,3,'a:k',1,2,0,1,3,100,90),(1,3,'a:k',1,2,0,0,0,100,0),(1,3,'a:k',1,4,0,0,3,100,0),(1,3,'a:k',1,2,1,0,2,100,0)]
for st,kl,held,hl,hc,cre,rw,rolled,time,last in CASES:
    body+=VA()+'MOVE "a:k" TO BE-XT(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 1)\nMOVE 2 TO BE-XI(WS-IDX, 2)\nMOVE %d TO BE-TIME2(WS-IDX)\n'%(kl,last)+('MOVE 7 TO BE-UUID(1)\nMOVE 7 TO BE-UUID(2)\nMOVE 7 TO BE-UUID(3)\nMOVE 7 TO BE-UUID(4)\nMOVE 1 TO BE-XI(WS-IDX, 25)\nMOVE 7 TO BE-UUID(WS-IDX, 1)\n' if False else '')
    body+=('MOVE 7 TO BE-UUID(WS-IDX, 1)\nMOVE 7 TO BE-UUID(WS-IDX, 2)\nMOVE 7 TO BE-UUID(WS-IDX, 3)\nMOVE 7 TO BE-UUID(WS-IDX, 4)\nMOVE 1 TO BE-XI(WS-IDX, 25)\n' if rw else '')+txtv('WS-T64',held)+'MOVE %d TO WS-LONG1\nMOVE %d TO WS-LEN\n'%(time,len(held))+mv(A=st,B=hc,C=cre,E=rolled)+'MOVE 7 TO WS-TV(1)\nMOVE 7 TO WS-TV(2)\nMOVE 7 TO WS-TV(3)\nMOVE 7 TO WS-TV(4)\n'+call('BE7-VAULT-KEY','WS-IDX','WS-A','WS-LONG1','WS-T64','WS-LEN','WS-B','WS-C','WS-TAB','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-F','n:WS-G','n:WS-H','n:BE-TIME2(WS-IDX)','n:BE-XI(WS-IDX, 59)','n:BE-SEED(WS-IDX)','n:BE-XI(WS-IDX, 25)')
    a,pl,cons=key(st,kl,held,hl,hc,cre,rw,rolled,time,last)
    exp+=[a,pl,cons,time if pl else last,rolled if a==4 else 0,time+14 if a==4 else 0,(1 if rw or a==4 else 0)]
g.case('key insertion (5.6, example 7.9): nothing without a key item or in the inactive state; a stack of another item or too few fails with the insert-fail sound; a player that already took a reward gets the reject sound (both sounds throttled to once per 15 ticks); an empty roll changes nothing; otherwise the key count is consumed (nothing in creative), the roll is stored, the machine resumes in 14 ticks and the player is marked rewarded (state, held count, creative, rolled count in; action 0 none 1 fail 2 reject 3 empty roll 4 unlocked, sound plays, consumed, fail time, items, resume time, rewarded count out)',body,[],exp)
body=VA()+'MOVE 128 TO BE-XI(WS-IDX, 25)\nPERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 128\n    COMPUTE WS-J = (WS-K - 1) * 4\n    MOVE WS-K TO BE-UUID(WS-IDX, WS-J + 1)\n    MOVE 0 TO BE-UUID(WS-IDX, WS-J + 2) BE-UUID(WS-IDX, WS-J + 3) BE-UUID(WS-IDX, WS-J + 4)\nEND-PERFORM\nMOVE 999 TO WS-TV(1)\nMOVE 0 TO WS-TV(2) WS-TV(3) WS-TV(4)\n'+call('BE7-VAULT-REWARD','WS-IDX','WS-TAB')+shw('n:BE-XI(WS-IDX, 25)','n:BE-UUID(WS-IDX, 1)','n:BE-UUID(WS-IDX, 509)','n:BE-XI(WS-IDX, 62)')+call('BE7-VAULT-REWARD','WS-IDX','WS-TAB')+shw('n:BE-XI(WS-IDX, 25)','n:BE-UUID(WS-IDX, 1)')
g.case('rewarded set (5.6 step 8, validation 17): an insertion-ordered set of at most 128; a 129th member drops the oldest; an already present player is not added again; the server data is dirty',body,[],[128,2,999,1,128,2])
body="";exp=[]
CS=[([(1,0,0,0)],[],[1],1),([(1,0,0,0)],[(1,0,0,0)],[1],0),([(1,0,0,0),(2,0,0,0)],[(2,0,0,0)],[(1,0,0,0)],0)]
def conn(cands,rewarded,stored):
    keep=[c for c in cands if c not in rewarded]
    return keep, int(keep!=stored), int(len(keep)>0)
body="";exp=[]
for cands,rew,stored in [([(1,0,0,0)],[],[]),([(1,0,0,0)],[],[(1,0,0,0)]),([(1,0,0,0),(2,0,0,0)],[(2,0,0,0)],[]),([(2,0,0,0)],[(2,0,0,0)],[(2,0,0,0)])]:
    body+=VA()+'MOVE %d TO BE-XI(WS-IDX, 25)\nMOVE %d TO BE-XI(WS-IDX, 8)\n'%(len(rew),len(stored))+''.join('MOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE 0 TO BE-UUID(WS-IDX, %d) BE-UUID(WS-IDX, %d) BE-UUID(WS-IDX, %d)\n'%(u[0],i*4+1,i*4+2,i*4+3,i*4+4) for i,u in enumerate(rew))+''.join('MOVE %d TO BE-UUID(WS-IDX, %d)\nMOVE 0 TO BE-UUID(WS-IDX, %d) BE-UUID(WS-IDX, %d) BE-UUID(WS-IDX, %d)\n'%(u[0],513+i*4,514+i*4,515+i*4,516+i*4) for i,u in enumerate(stored))+''.join('MOVE %d TO WS-TV(%d)\nMOVE 0 TO WS-TV(%d) WS-TV(%d) WS-TV(%d)\n'%(u[0],i*4+1,i*4+2,i*4+3,i*4+4) for i,u in enumerate(cands))+'MOVE %d TO WS-A\n'%len(cands)+call('BE7-VAULT-CONNECT','WS-IDX','WS-TAB','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C','n:BE-XI(WS-IDX, 8)','n:BE-XI(WS-IDX, 61)')
    keep,dirty,anyv=conn(cands,rew,stored)
    exp+=[dirty,anyv,len(keep),dirty]
g.case('connected players (5.5): the detected players that are not in the rewarded set replace the stored set when it differs (shared data dirty); a rewarded player never keeps the vault active (candidates in; changed, any connected, stored count, dirty out)',body,[],exp)
body="";exp=[]
for d2,rg in [(13,4.0),(17,4.5),(20,4.5),(25,4.5),(16,4.0)]:
    body+=mv(A=d2)+'COMPUTE WS-FA = %s\n'%rg+call('BE7-VAULT-RANGE','WS-A','WS-FA','WS-B')+shw('n:WS-B'); exp.append(int(d2<rg*rg))
g.case('ranges (5.5, example 7.10): a player connects when its squared distance is below the range squared (13 below 16 at 4.0; 17 and 20 below 20.25 stay, 25 drops at 4.5) (distance squared, range in)',body,[],exp)
L5=VA()+begin()+nb_c('config')+nb_s('zzz','q')+item('key_item','a:k',1).replace(nb_i('count',1),nb_i('count',1)+nb_s('extra','z'))+nb_e()
L5+=nb_c('shared_data')+nb_i('zzz',1)+nb_e()
L5+=nb_c('server_data')+nb_i('zzz',1)+nb_l('items_to_eject',3,1)+nb_i(None,7)+nb_e()+nb_i('zzz',2)
g.case('unknown keys (5.3): keys the vault parts do not know are skipped; a key item with an extra key keeps its id and count; a list of the wrong element type gives no items to eject',VA()+L5+load()+S2+shw('SAVE')+'MOVE 3 TO WS-A\n',[],['{config:{loot_table:minecraft:chests/trial_chambers/reward,activation_range:4.000,deactivation_range:4.500,key_item:{id:a:k,count:1}},shared_data:{connected_players:[],connected_particles_range:4.500},server_data:{rewarded_players:[],state_updating_resumes_at:0,items_to_eject:[],total_ejections_needed:0}}'])
L6=VA()+begin()+nb_c('server_data')+nb_l('items_to_eject',10,9)
for i in range(9): L6+=nb_s('id','a:i%d'%i)+nb_i('count',i+1)+nb_e()
L6+=nb_e()+load()+shw('n:BE-XI(WS-IDX, 59)','n:BE-SLOT-COUNT(WS-IDX, 8)')
g.case('items to eject (5.3): at most 8 stacks are kept (the cells of this implementation), in list order',L6,[],[8,8])
W(g,5)
# ===== 6
g=GG(6,'Persistence and synchronisation seen from the chunk','T0965','the chunk compound with full metadata, the packet entries and the update tags of the three types.')
g.case('chunk compound (6): the custom keys, then components, then id, x, y, z (the 31-1 full form) for the spawner and the trial spawner',SP()+render(1)+shw('SAVE')+TS()+shw('SAVE'),[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4,SpawnPotentials:[{data:{entity:{}},weight:1}],components:{},id:minecraft:mob_spawner,x:5,y:70,z:5} '+TD.rstrip('}')+',components:{},id:minecraft:trial_spawner,x:5,y:70,z:5}'])
body="";exp=[]
for mk_,typ in [(SP,9),(TS,43),(VA,44)]:
    body+=mk_()+'CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-DATA-PACKET" USING WS-IDX PB-BUFFER WS-A\nCALL "PB-FREE" USING PB-BUFFER\n'+shw('n:WS-A'); exp.append(1)
g.case('packets (6): each of the three types sends its Block Entity Data packet (written 1)',body,[],exp)
g.case('update tags (6): the spawner tag has no SpawnPotentials, the vault tag only shared_data, the trial spawner tag only next_mob_spawns_at and spawn_data',SP()+TAGR+TS()+'MOVE 2 TO BE-STATUS(WS-IDX)\nMOVE 4 TO BE-TIME2(WS-IDX)\n'+TAGR+VA()+TAGR,[],['{Delay:20,MinSpawnDelay:200,MaxSpawnDelay:800,SpawnCount:4,MaxNearbyEntities:6,RequiredPlayerRange:16,SpawnRange:4} {next_mob_spawns_at:4} {shared_data:{connected_players:[],connected_particles_range:4.500}}'])
W(g,6)
