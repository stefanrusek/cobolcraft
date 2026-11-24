import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from genbe import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/31-block-entities-5-beacon-conduit-end-piston-creaking.md (T0921 to T0932; core/src/be-31-5.cob, BE5- programs).
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
WS=''.join(' 01 WS-%s                 BINARY-LONG.\n'%c for c in 'ABCEFGH')+' 01 WS-EV                BINARY-LONG.\n'+''.join(' 01 WS-O%d                 BINARY-LONG.\n'%i for i in range(1,8))+''.join(' 01 WS-F%s                FLOAT-LONG.\n'%c for c in 'ABCDEF')+''' 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-PK                 PIC X(32).
 01 WS-SK                 PIC X(32).
 01 WS-PASSES.
    05 WS-PASS            BINARY-LONG OCCURS 4 TIMES.
 01 WS-OFFS.
    05 WS-OFF             OCCURS 64 TIMES.
       10 WS-OX           BINARY-LONG.
       10 WS-OY           BINARY-LONG.
       10 WS-OZ           BINARY-LONG.
 01 WS-TX                 PIC X(64).
'''
def GG(n,subj,tasks,desc): return G('TEST-BE-31-5-%d'%n,'31-5§%d'%n,subj,'Test of 31-5 section %d, %s (core/src/be-31-5.cob; %s): %s'%(n,subj,tasks,desc),WS)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_5_%d.cob'%n)
def call(name,*args): return 'CALL "%s" USING %s\n'%(name," ".join(args))
def mv(**kw): return ''.join('MOVE %s TO WS-%s\n'%(v,k) for k,v in kw.items())
def fv(**kw): return ''.join('COMPUTE WS-F%s = %s\n'%(k,v) for k,v in kw.items())
def txtv(var,v):
    return ('MOVE SPACES TO %s\nMOVE "%s" TO %s\n'%(var,v,var)) if v else 'MOVE SPACES TO %s\n'%var
# ===== 1
g=GG(1,'Types, blocks, tickers','T0921','the six types with keys, ids, valid blocks, tag kinds and tickers.')
rows=[(15,'beacon',1,1),(25,'conduit',1,1),(14,'end_portal',0,0),(22,'end_gateway',1,1),(11,'piston',1,0),(10,'creaking_heart',1,1)]
body="";exp=[]
for t,k,kind,pk in rows:
    body+='MOVE %d TO WS-A\n'%t+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+call('BE-SYNC-INFO','WS-A','WS-C','WS-E')+shw('t:WS-N24,WS-LEN','n:WS-C','n:WS-E'); exp+=[k,kind,pk]
g.case('types (1): key by registry id (beacon 15, conduit 25, end_portal 14, end_gateway 22, piston 11, creaking_heart 10), update tag kind (1 custom only) and the Block Entity Data packet flag (none for the end portal, the piston has a tag kind but no packet)',body,[],exp)
body="";exp=[]
for t,blk,r in [(15,'beacon',1),(25,'conduit',1),(14,'end_portal',1),(22,'end_gateway',1),(11,'moving_piston',1),(10,'creaking_heart',1),(11,'piston',0),(15,'conduit',0)]:
    body+='MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-SVL\nMOVE %d TO WS-A\n'%(blk,10+len(blk),t)+call('BE-VALID-BLOCK','WS-A','WS-KEY','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(r)
g.case('valid blocks (1): each type has the block of its name (the piston entity belongs to moving_piston, not to the piston block)',body,[],exp)
tk={15:(1,1),25:(3,2),14:(0,0),22:(5,4),11:(6,6),10:(7,0)}
body="";exp=[]
for t,v in tk.items():
    body+='MOVE %d TO WS-A\n'%t+call('BE5-REGISTRATION','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=list(v)
g.case('tickers (1): server and client ticker per type (1 beacon tick on both sides, 3 conduit serverTick and 2 clientTick, 5 gateway portalTick and 4 beamAnimationTick, 6 piston on both, 7 creaking heart server only, 0 none)',body,[],exp)
W(g,1)
# ===== 2
EFF={'speed':1,'haste':1,'resistance':2,'jump_boost':2,'strength':3,'regeneration':4}
def req(n): return EFF.get(n,2147483647) if n else 0
def validate(p,s,levels):
    if s and levels<4: return 0
    rp=req(p);rs=req(s)
    if rp>levels or rs>levels: return 0
    if rp>=4: return 0
    if rs!=0 and rs<4 and not p: return 0
    if rs!=0 and rs<4 and p!=s: return 0
    return 1
g=GG(2,'Beacon','T0923','the effect tiers, validateEffects, the effect numbers, the base scan, the beam sections, the pulse and the saved keys.')
body="";exp=[]
for n in ['speed','haste','resistance','jump_boost','strength','regeneration','levitation','','minecraft:speed','abcdefghijklmn']:
    body+=txtv('WS-PK',n)+'MOVE %d TO WS-A\n'%len(n)+call('BE5-BEACON-REQUIRED','WS-PK','WS-A','WS-B')+shw('n:WS-B'); exp.append(req(n) if n!='minecraft:speed' else 1)
g.case('tier table (2.1): speed and haste need 1, resistance and jump_boost 2, strength 3, regeneration 4, any other effect 2147483647, none 0 (a key with the minecraft: namespace is the same effect)',body,[],exp)
body="";exp=[]
cases=[('speed','regeneration',4),('regeneration','',4),('speed','speed',4),('speed','',1),('speed','speed',3),('resistance','speed',4),('strength','',3),('strength','',2),('haste','resistance',4),('','speed',4),('','regeneration',4),('','',0),('jump_boost','jump_boost',4),('levitation','',4),('speed','levitation',4)]
cases+=[('speed','haste',4),('','speed',4)]
for p,s_,lv in cases:
    body+=txtv('WS-PK',p)+txtv('WS-SK',s_)+'MOVE %d TO WS-A\nMOVE %d TO WS-B\nMOVE %d TO WS-C\n'%(len(p),len(s_),lv)+call('BE5-BEACON-VALIDATE','WS-PK','WS-A','WS-SK','WS-B','WS-C','WS-E')+shw('n:WS-E'); exp.append(validate(p,s_,lv))
g.case('validateEffects (2.5, worked example 3): a secondary needs levels 4; both required levels must be within the levels; a primary of tier 4 (regeneration) is invalid; a secondary below tier 4 must repeat the primary (a missing primary with such a secondary is refused)',body,[],exp)
body="";exp=[]
for lv,same,prim,sec in [(1,0,1,0),(2,0,1,0),(3,0,1,0),(4,0,1,1),(4,1,1,1),(4,1,1,0),(4,0,0,1)]:
    body+=mv(A=lv,B=same,C=prim,E=sec)+call('BE5-BEACON-EFFECTS','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-EV')+shw('n:WS-F','n:WS-G','n:WS-H','n:WS-EV')
    amp=1 if (lv>=4 and same) else 0
    exp+=[lv*10+10,(9+2*lv)*20,amp if prim else 0,int(lv>=4 and not same and sec and prim)]
g.case('effects (2.4, worked example 1): range levels * 10 + 10, duration (9 + 2 * levels) * 20 ticks (260 at levels 2), amplifier 1 only at levels 4 when the primary equals the secondary, the secondary applies at levels 4 when different and set (levels, same, primary set, secondary set in; range, duration, amplifier, secondary applies out)',body,[],exp)
def base(y,miny,passes):
    r=0
    for i in range(1,5):
        yy=y-i
        if yy<miny: break
        if not passes[i-1]: break
        r=i
    return r
body="";exp=[]
for y,miny,p in [(64,-64,(1,1,0,0)),(64,-64,(1,1,1,1)),(64,-64,(0,1,1,1)),(64,-64,(1,0,0,0)),(63,62,(1,1,1,1)),(-62,-64,(1,1,1,1)),(-63,-64,(1,1,1,1))]:
    body+=mv(A=y,B=miny)+''.join('MOVE %d TO WS-PASS(%d)\n'%(v,i+1) for i,v in enumerate(p))+call('BE5-BEACON-BASE','WS-A','WS-B','WS-PASSES','WS-C')+shw('n:WS-C'); exp.append(base(y,miny,p))
g.case('base scan (2.3, worked example 1): layer i is a (2i + 1) square below the beacon; the first failing layer or a layer below the world minimum stops the scan (levels 0 to 4)',body,[],exp)
def avg(a,b): return ((((a>>16)&255)+((b>>16)&255))//2<<16)|((((a>>8)&255)+((b>>8)&255))//2<<8)|(((a&255)+(b&255))//2)
WHITE=0xF9FFFE;RED=0xB02E26;BLUE=0x3C44AA
cells=[(2,0),(1,RED),(1,RED),(1,BLUE),(2,0)]
sec=[]
for kind,c in [(1,WHITE)]+cells:
    if kind==1:
        if len(sec)<=1: sec.append([c,1])
        elif sec[-1][0]==c: sec[-1][1]+=1
        else: sec.append([avg(sec[-1][0],c),1])
    else:
        sec[-1][1]+=1
body=BEX if False else ''
body='MOVE 15 TO WS-A\nMOVE "minecraft:beacon" TO WS-KEY\nMOVE 16 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
for kind,c in [(1,WHITE)]+cells:
    body+=mv(A=kind,B=c)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')
body+=shw('n:BE-XI(WS-IDX, 5)')
for i in range(len(sec)): body+=shw('n:BE-XI(WS-IDX, %d)'%(6+2*i),'n:BE-XI(WS-IDX, %d)'%(7+2*i))
exp=[len(sec)]
for c,h in sec: exp+=[c,h]
g.case('beam sections (2.2 step 3, worked example 2): the beacon cell creates the white base, red glass starts its own section (the first glass above the base), the second red adds a cell, blue starts a section with the average colour, transparent cells after it add height (colour, height shown; the average is per channel)',body,[],exp)
body='MOVE 15 TO WS-A\nMOVE "minecraft:beacon" TO WS-KEY\nMOVE 16 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
body+=mv(A=3,B=0)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 5)','n:WS-C')
body+=mv(A=1,B=WHITE)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+mv(A=2,B=0)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 7)')
body+=mv(A=3,B=0)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 5)','n:WS-C')
body+=mv(A=1,B=WHITE)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+mv(A=4,B=0)+call('BE5-BEACON-CELL','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 7)','n:WS-C')
g.case('blocked beam (2.2 step 3): a non-beam cell with no section yet blocks the beam (sections cleared, blocked 1); a cell with light dampening 15 (kind 3) blocks too; bedrock (kind 4) does not (it adds height); a transparent cell adds height (sections, height, blocked shown)',body,[],[0,1, 1,2, 0,1, 1,2,0])
body="";exp=[]
for t,beams,lv in [(80,1,2),(160,0,2),(81,1,2),(0,1,0),(80,0,0)]:
    body+=mv(A=t,B=beams,C=lv)+call('BE5-BEACON-PULSE','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-E','n:WS-F')
    exp+=[int(t%80==0 and beams>0), int(t%80==0 and beams>0 and lv>0)]
g.case('pulse (2.2 step 5): every 80 ticks, with an open beam the base is rescanned (recompute 1), and when the levels are above 0 the effects are applied and the ambient sound plays (apply 1); otherwise neither',body,[],exp)
body="";exp=[]
for prev,now in [(0,2),(2,0),(2,3),(0,0),(1,1)]:
    body+=mv(A=prev,B=now)+call('BE5-BEACON-SOUND','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(1 if (prev==0 and now>0) else 2 if (prev>0 and now==0) else 0)
g.case('activation sounds (2.2 step 6, 2.6): beacon.activate (1) when the levels rise from 0, beacon.deactivate (2) when they fall to 0, nothing otherwise',body,[],exp)
BC='MOVE 15 TO WS-A\nMOVE "minecraft:beacon" TO WS-KEY\nMOVE 16 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
LBC=nb_begin()+nb_s('primary_effect','minecraft:speed')+nb_s('secondary_effect','minecraft:regeneration')+nb_i('Levels',4)+nb_s('CustomName','Beam')
g.case('saved keys (2.1): primary_effect and secondary_effect load when they are valid effects and save back; Levels is written (the value of the entity, 0 after a load) but never read; CustomName is kept; a key that is no valid effect is none',BC+LBC+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE','n:BE-XI(WS-IDX, 3)')+BC+nb_begin()+nb_s('primary_effect','minecraft:levitation')+nb_s('secondary_effect','minecraft:haste')+'PERFORM LOAD-BUFFER\n'+shw('SAVE')+BC+'MOVE 3 TO BE-XI(WS-IDX, 3)\n'+shw('SAVE'),[],['{primary_effect:minecraft:speed,secondary_effect:minecraft:regeneration,Levels:0,CustomName:Beam} 0 {secondary_effect:minecraft:haste,Levels:0} {Levels:3}'])
LBL=nb_begin()+nb_c('lock')+nb_i('other',1)+nb_s('items','minecraft:key')+nb_e()
g.case('lock (2.1): the lock code is saved as lock {items} when set (kept from the load), after CustomName',BC+LBL+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE'),[],['{Levels:0,lock:{items:minecraft:key}}'])
W(g,2)
# ===== 3
CO='MOVE 25 TO WS-A\nMOVE "minecraft:conduit" TO WS-KEY\nMOVE 17 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
g=GG(3,'Conduit','T0925','the frame offsets, the 40-tick pulse with its sounds, the effect range, the target rules, the client bob and the saved key.')
offs=[(dx,dy,dz) for dx in range(-2,3) for dy in range(-2,3) for dz in range(-2,3) if not (abs(dx)<=1 and abs(dy)<=1 and abs(dz)<=1) and ((dx==0 and (abs(dy)==2 or abs(dz)==2)) or (dy==0 and (abs(dx)==2 or abs(dz)==2)) or (dz==0 and (abs(dx)==2 or abs(dy)==2)))]
assert len(offs)==42
body=call('BE5-CONDUIT-OFFSETS','WS-OFFS','WS-A')+shw('n:WS-A','n:WS-OX(1)','n:WS-OY(1)','n:WS-OZ(1)','n:WS-OX(2)','n:WS-OY(2)','n:WS-OZ(2)','n:WS-OX(42)','n:WS-OY(42)','n:WS-OZ(42)')
body+='MOVE 0 TO WS-B\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 42\nCOMPUTE WS-B = WS-B + WS-OX(WS-J) * 3 + WS-OY(WS-J) * 7 + WS-OZ(WS-J) * 11 + FUNCTION ABS(WS-OX(WS-J)) * WS-J\nEND-PERFORM\n'+shw('n:WS-B')
g.case('frame scan (3.2): the kept offsets of the three rings, in the order dx, dy, dz, are 42 (first and second shown, and the last); a checksum over all 42 offsets matches the list of the doc',body,[],[42]+list(offs[0])+list(offs[1])+list(offs[41])+[sum(o[0]*3+o[1]*7+o[2]*11+abs(o[0])*(i+1) for i,o in enumerate(offs))])
body="";exp=[]
for n in (0,15,16,41,42):
    body+=mv(A=n)+call('BE5-CONDUIT-RANGE','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=[(n//7)*16,int(n>=16)]
g.case('effects range (3.4, worked example 4): range = (n / 7) * 16 with integer division (16 frame blocks give 32, 42 give 96); the shape is active from 16',body,[],exp)
body=CO;exp=[]
sched=[(39,0,0,0),(40,1,42,5),(41,1,42,5),(80,1,42,10),(120,1,16,0),(160,0,0,0),(200,0,0,0)]
hunt=0;act=0;nx=0
for t,sa,cnt,r in sched:
    body+=mv(A=t,B=sa,C=cnt,E=r)+call('BE5-CONDUIT-TICK','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-O1','WS-O2','WS-O3','WS-O4','WS-O5','WS-O6')+shw('n:WS-O1','n:WS-O2','n:WS-O3','n:WS-O4','n:WS-O5','n:WS-O6','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 3)')
    sound=eff=att=kill=amb=sh=0
    if t%40==0:
        a=sa
        if a!=act: sound=1 if a else 2
        act=a; hunt=int(cnt>=42)
        if a: eff=1;att=1;kill=int(cnt>=42)
    if act:
        if t%80==0: amb=1
        if t>nx: nx=t+60+r; sh=1
    exp+=[sound,eff,att,kill,amb,sh,act,hunt]
g.case('server tick (3.3): the shape scan, effects and attack run only when the game time is divisible by 40: becoming active plays conduit.activate (1), becoming inactive conduit.deactivate (2); isHunting is 42 frame blocks; while active the long ambient plays on times divisible by 80 and the short ambient when the time passes nextAmbientSoundActivation (set to t + 60 + random). Per call: sound, effects, attack, can kill, ambient, short ambient, isActive, isHunting',body,[],exp)
body="";exp=[]
for ck,hc,va,cand,r in [(0,1,1,3,1),(1,0,0,0,0),(1,0,0,3,2),(1,1,1,3,2),(1,1,0,3,2)]:
    body+=mv(A=ck,B=hc,C=va,E=cand,F=r)+call('BE5-CONDUIT-TARGET','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-G','n:WS-H')
    if not ck: ac=0
    elif not hc: ac=2 if cand>0 else 0
    else: ac=1 if va else 0
    exp+=[ac,r if ac==2 else 0]
g.case('hunting target (3.5): without can kill no target; no current target selects one of the candidates by one index draw (none when there are no candidates); a current target is kept only while it is alive and within 8 (otherwise none, with no new pick on the same pulse) (action 0 none, 1 keep, 2 new; index)',body,[],exp)
body="";exp=[]
for tc in (0,1,25,100):
    body+=mv(A=tc)+call('BE5-CONDUIT-BOB','WS-A','WS-FA')+shw('f:WS-FA')
    k=int(((tc+35)*0.1)*10430.378350470453)&65535
    h=f32(math.sin(k/10430.378350470453))/2+0.5
    exp.append((h*h+h)*0.3)
g.case('client particle origin (3.6): h = Mth.sin((tickCount + 35) * 0.1) / 2 + 0.5 and the height offset b = (h * h + h) * 0.3',body,[],exp)
LCO=nb_begin()+nb_intarr('Target',[1,-2,3,-4])
g.case('saved key (3.1): Target is an entity reference stored as an Int Array of 4; present sets the target, absent leaves none; nothing else is saved',CO+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+LCO+'PERFORM LOAD-BUFFER\n'+shw('SAVE','n:BE-XI(WS-IDX, 6)')+CO+nb_begin()+nb_s('Target','x')+'PERFORM LOAD-BUFFER\n'+shw('SAVE'),[],['{} {Target:I[1,-2,3,-4]} 1 {}'])
W(g,3)
# ===== 4
GA='MOVE 22 TO WS-A\nMOVE "minecraft:end_gateway" TO WS-KEY\nMOVE 21 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
g=GG(4,'End portal and end gateway','T0927','the portal faces, the gateway counters and cooldown, the block event, the beam fractions, the use rule and the saved keys.')
body="";exp=[]
for d in range(6):
    body+=mv(A=d)+call('BE5-PORTAL-FACE','WS-A','WS-B')+shw('n:WS-B'); exp.append(int(d in (0,1)))
g.case('end portal faces (4.1): the entity has no data; only faces on the Y axis (down 0, up 1) are rendered',body,[],exp)
g.case('gateway state (4.2): Age is always written (0), exit_portal only when set, ExactTeleport only when true',GA+'MOVE 2 TO WS-FORM\n'+shw('SAVE'),[],['{Age:0}'])
body=GA+'MOVE 198 TO BE-XI(WS-IDX, 1)\nMOVE 0 TO WS-A\n'
for i in range(3):
    body+=call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 1)','n:WS-B','n:WS-C')
body+='MOVE 2398 TO BE-XI(WS-IDX, 1)\n'
for i in range(2):
    body+=call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 7)','n:WS-B','n:WS-C')
body+='PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 39\nCALL "BE5-GATEWAY-TICK" USING WS-IDX WS-A WS-B WS-C\nEND-PERFORM\n'+shw('n:BE-XI(WS-IDX, 7)','n:WS-C')+call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 7)','n:WS-B','n:WS-C')
g.case('server tick (4.3): age rises each tick; the tick that ends the 200-tick spawning is a state change (changed 1); at age 2400 the cooldown starts (40, block event 1) and counts down, the end of the cooldown is a state change too (age, cooldown, event, changed shown)',body,[],[199,0,0, 200,0,1, 201,0,0, 2399,0,0,0, 2400,40,1,1, 1,0, 0,0,1])
body=GA+'MOVE 1 TO WS-A\nMOVE 5 TO BE-XI(WS-IDX, 7)\n'+call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 7)','n:WS-B')
body+='MOVE 2399 TO BE-XI(WS-IDX, 1)\nMOVE 0 TO BE-XI(WS-IDX, 7)\n'+call('BE5-GATEWAY-TICK','WS-IDX','WS-A','WS-B','WS-C')+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 7)')
g.case('client tick (4.3): age rises and a running cooldown counts down; the client never starts a cooldown itself (only the block event does)',body,[],[2,3,0,2400,0])
body=GA+'MOVE 1 TO WS-A\n'+call('BE5-GATEWAY-EVENT','WS-IDX','WS-A','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 7)')+'MOVE 7 TO WS-A\nMOVE 0 TO BE-XI(WS-IDX, 7)\n'+call('BE5-GATEWAY-EVENT','WS-IDX','WS-A','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 7)')
g.case('block event (4.3): event 1 sets the cooldown to 40 on the client (handled); any other event goes to the base class',body,[],[1,40,0,0])
body="";exp=[]
for age,cd,p in [(0,0,0.0),(100,0,0.5),(200,0,0.0),(300,0,0.0),(250,40,0.5),(250,20,0.5),(250,1,0.3),(250,0,0.0),(0,0,-0.5),(250,0,0.5),(250,60,0.0)]:
    body+=mv(A=age,B=cd)+fv(A=p)+call('BE5-GATEWAY-PERCENT','WS-A','WS-B','WS-FA','WS-FB','WS-FC')+shw('f4:WS-FB','f4:WS-FC')
    sp=min(1,max(0,(age+p)/200)); cl=1-min(1,max(0,(cd-p)/40))
    exp+=[sp,cl]
g.case('beam fractions (4.2): spawn percent clamp((age + partial) / 200, 0, 1) and cooldown percent 1 - clamp((cooldown - partial) / 40, 0, 1)',body,[],exp)
body="";exp=[]
for can,srv,ent,cool in [(1,1,1,0),(1,1,1,1),(0,1,1,0),(1,0,1,0),(1,1,0,0)]:
    body+=mv(A=can,B=srv,C=ent,E=cool)+call('BE5-GATEWAY-USE','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(can and srv and ent and not cool))
g.case('entityInside (4.3): an entity that can use portals, on the server, with the block entity present and not cooling down enters the portal and starts the cooldown (1)',body,[],exp)
LG=nb_begin()+nb_long('Age',2000)+nb_intarr('exit_portal',[100,50,0])+nb_b('ExactTeleport',1)
g.case('save and load (4.2): Age, exit_portal (an int array of 3) and ExactTeleport round trip (saved in the order Age, exit_portal, ExactTeleport); ExactTeleport false is not written',GA+LG+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE','n:BE-XI(WS-IDX, 1)')+GA+nb_begin()+nb_long('Age',7)+nb_b('ExactTeleport',0)+'PERFORM LOAD-BUFFER\n'+shw('SAVE'),[],['{Age:2000,exit_portal:I[100,50,0],ExactTeleport:1} 2000 {Age:7}'])
W(g,4)
# ===== 5
g=GG(5,'Piston moving block entity','T0929','the type facts only: the entity is specified in 30-3 and nothing is added here.')
body='MOVE 11 TO WS-A\n'+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+call('BE-SYNC-INFO','WS-A','WS-C','WS-E')+shw('t:WS-N24,WS-LEN','n:WS-C','n:WS-E')
g.case('pointer only (5): the piston entity is registered as piston (id 11) for the block moving_piston, has a custom-only tag kind and no Block Entity Data packet (31-8 row 11); its keys and rules are those of 30-3 section 7',body,[],['piston 1 0'])
W(g,5)
# ===== 6
CH='MOVE 10 TO WS-A\nMOVE "minecraft:creaking_heart" TO WS-KEY\nMOVE 24 TO WS-SVL\nMOVE 5 TO WS-X\nMOVE 70 TO WS-Y\nMOVE 5 TO WS-Z\nCALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-A WS-KEY WS-SVL WS-IDX\n'
g=GG(6,'Creaking heart','T0931','the day attribute, the log rule and block states, the comparator, the server tick countdowns, the link rules, spawning, hurting, experience and the saved key.')
body="";exp=[]
for t in (0,12599,12600,20000,23400,23401,24000,24000+12600,48000+23400):
    body+=mv(A=t)+call('BE5-HEART-ACTIVE','WS-A','WS-B')+shw('n:WS-B'); exp.append(int(12600<=t%24000<23401))
g.case('creaking_active (6.1): true from tick 12600 until tick 23401 of the 24000-tick day',body,[],exp)
body="";exp=[]
for t1,a1,t2,a2 in [(1,1,1,1),(1,0,1,1),(1,1,0,1),(0,1,1,1),(0,0,0,0)]:
    body+=mv(A=t1,B=a1,C=t2,E=a2)+call('BE5-HEART-LOGS','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(t1 and a1 and t2 and a2))
g.case('hasRequiredLogs (6.1): both neighbours along the axis must be pale oak logs and have the heart\'s axis',body,[],exp)
body="";exp=[]
for logs,state,attr in [(1,0,1),(1,0,0),(1,1,1),(1,2,0),(0,0,1),(0,2,1)]:
    body+=mv(A=logs,B=state,C=attr)+call('BE5-HEART-BLOCK-STATE','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E')
    exp.append((2 if attr else 1) if (logs and state==0) else state)
for logs,link,attr in [(0,0,1),(0,1,1),(1,0,1),(1,0,0),(0,1,0)]:
    body+=mv(A=logs,B=link,C=attr)+call('BE5-HEART-ENTITY-STATE','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E')
    exp.append(0 if (not logs and not link) else (2 if attr else 1))
g.case('states (6.1, 6.3 step 5): the block turns an uprooted heart with logs awake (active) or dormant and changes nothing else; the entity gives uprooted when there are no logs and no link, otherwise awake when active else dormant (0 uprooted, 1 dormant, 2 awake)',body,[],exp)
body="";exp=[]
for lk,pr,d in [(0,0,5.0),(1,0,5.0),(1,1,0.0),(1,1,8.0),(1,1,32.0),(1,1,40.0),(1,1,31.9),(1,1,1.0),(1,1,-3.0)]:
    body+=mv(A=lk,B=pr)+fv(A=d)+call('BE5-HEART-COMPARATOR','WS-A','WS-B','WS-FA','WS-E')+shw('n:WS-E')
    exp.append(0 if not (lk and pr) else 15-int(15*min(32,max(0,d))/32))
g.case('comparator (6.6, worked example 5): 0 without a link or protector; else 15 - floor(15 * clamp(d, 0, 32) / 32) (8 blocks give 12, 0 gives 15, 32 or more 0)',body,[],exp)
body=CH+'MOVE 1 TO BE-XI(WS-IDX, 3)\n'
tk=1;te=0;exp=[]
for r,e0 in [(2,0),(3,0),(0,60),(1,30),(4,10),(2,1),(0,0)]:
    body+=mv(A=r)+'MOVE %d TO BE-XI(WS-IDX, 4)\n'%e0+call('BE5-HEART-TICK','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-FA')+shw('n:WS-B','n:WS-C','n:WS-E','f4:WS-FA','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 2)')
    te+=1
    em=e0;passes=0;snd=0;pitch=0.0
    if em>0:
        passes=2 if em>50 else 1
        if em%10==0: snd=1; pitch=0.5+(em//2)/100
        em-=1
    tk-=1;run=0
    if tk<0: tk=20+r; run=1
    exp+=[run,passes,snd,pitch,tk,em,te]
g.case('server tick (6.3 steps 1, 3, 4): ticksExisted counts; with an emitter running the trail is emitted twice above 50 and once otherwise, the hurt sound plays when emitter mod 10 is 0 with pitch 0.5 + (emitter / 2) / 100, and the emitter counts down; the logic runs when the ticker passes below 0 and is reset to 20 + nextInt(5) (run, particle passes, hurt sound, pitch, ticker, emitter, ticksExisted)',body,[],exp)
body="";exp=[]
for kind,rem,found,te in [(0,0,0,0),(1,0,0,5),(1,1,1,5),(1,1,0,5),(2,0,1,5),(2,0,0,29),(2,0,0,30),(1,1,0,40)]:
    body+=mv(A=kind,B=rem,C=found,E=te)+call('BE5-HEART-LINK','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:WS-E')
    if kind==0: r=(0,te)
    elif kind==1 and not rem: r=(1,te)
    else:
        t2=0 if kind==1 else te
        if found: r=(1,t2)
        elif t2>=30: r=(2,t2)
        else: r=(0,t2)
    exp+=list(r)
g.case('link resolution (6.5): no link gives none; a live creaking is the protector; a removed one becomes a UUID with ticksExisted reset to 0; a UUID found in the world is the protector again; one not found is cleared once ticksExisted reaches 30 (action 0 none, 1 protector, 2 link cleared; ticksExisted after)',body,[],exp)
body="";exp=[]
for at,pe,d,st_ in [(1,0,10.0,0),(0,0,10.0,0),(0,1,10.0,0),(1,0,34.0,0),(1,0,34.5,0),(1,1,5.0,1),(0,1,40.0,1)]:
    body+=mv(A=at,B=pe,C=st_)+fv(A=d)+call('BE5-HEART-DROP','WS-A','WS-B','WS-FA','WS-C','WS-E')+shw('n:WS-E')
    exp.append(int((not at and not pe) or d>34 or st_))
g.case('losing the protector (6.3 step 6): the link is removed when the attribute is false and the creaking does not require persistence, when it is farther than 34, or when a player is stuck in it',body,[],exp)
body="";exp=[]
for stt,mon,peace,near in [(2,1,0,1),(1,1,0,1),(2,0,0,1),(2,1,1,1),(2,1,0,0),(0,1,0,1)]:
    body+=mv(A=stt,B=mon,C=peace,E=near)+call('BE5-HEART-SPAWN','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int(stt==2 and mon and not peace and near))
g.case('spawn conditions (6.3 step 7): an awake heart without a link spawns a protector only when monsters spawn, the difficulty is not peaceful and a player is within 32',body,[],exp)
body="";exp=[]
for em,pr,aw,dr in [(0,1,1,2),(0,1,1,3),(0,1,0,3),(5,1,1,2),(0,0,1,2)]:
    body+=mv(A=em,B=pr,C=aw,E=dr)+call('BE5-HEART-HURT','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-F','n:WS-G','n:WS-H')
    ok=pr and em==0
    exp+=[20 if ok else 0,(dr if aw else 0) if ok else 0,100 if ok else em]
g.case('creakingHurt (6.6): with a protector and no emitter running: 20 particles, 2 or 3 resin spreads when awake (the draw) and the emitter starts at 100; otherwise nothing (particles, resin, emitter)',body,[],exp)
body="";exp=[]
for pr,sp,nat,srv,dr in [(0,0,1,1,0),(0,0,1,1,4),(1,0,1,1,2),(0,1,1,1,2),(0,0,0,1,2),(0,0,1,0,2)]:
    body+=mv(A=pr,B=sp,C=nat,E=srv,F=dr)+call('BE5-HEART-XP','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-G'); exp.append(20+dr if (not pr and not sp and nat and srv) else 0)
g.case('experience (6.1): breaking a natural heart on a server pops 20 + nextInt(5) experience unless the player prevents block drops or is a spectator',body,[],exp)
LH=nb_begin()+nb_intarr('creaking',[5,6,7,8])
g.case('saved key (6.2): creaking is the UUID of the protector as 4 ints, written only when linked; a present key sets the link (ticksExisted reset to 0), an absent key clears it',CH+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+'MOVE 9 TO BE-XI(WS-IDX, 2)\n'+LH+'PERFORM LOAD-BUFFER\n'+shw('SAVE','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 1)')+nb_begin()+'PERFORM LOAD-BUFFER\n'+shw('SAVE','n:BE-XI(WS-IDX, 1)'),[],['{} {creaking:I[5,6,7,8]} 0 1 {} 0'])
W(g,6)
