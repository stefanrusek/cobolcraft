import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from genbe import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/31-block-entities-4-jukebox-lectern-bell-campfire-brushable-beehive.md (T0905 to T0920; core/src/be-31-4.cob, BE4- programs).
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
WS=''.join(' 01 WS-%s                 BINARY-LONG.\n'%c for c in 'ABCEFGH')+' 01 WS-EV                BINARY-LONG.\n'+''.join(' 01 WS-F%s                FLOAT-LONG.\n'%c for c in 'ABCDEFG')+''' 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(64).
 01 WS-DROPS.
    05 WS-DROP            OCCURS 4 TIMES.
       10 WS-DROP-ITEM    BINARY-LONG.
       10 WS-DROP-COUNT   BINARY-LONG.
       10 WS-DROP-VAR     BINARY-LONG.
 01 WS-KINDS.
    05 WS-KIND            BINARY-LONG OCCURS 6 TIMES.
 01 WS-DRAWS.
    05 WS-DRAW            BINARY-LONG OCCURS 16 TIMES.
 COPY CTRECIPE.
'''
def GG(n,subj,tasks,desc): return G('TEST-BE-31-4-%d'%n,'31-4§%d'%n,subj,'Test of 31-4 section %d, %s (core/src/be-31-4.cob; %s): %s'%(n,subj,tasks,desc),WS)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_4_%d.cob'%n)
def call(name,*args): return 'CALL "%s" USING %s\n'%(name," ".join(args))
def mv(**kw): return ''.join('MOVE %s TO WS-%s\n'%(v,k) for k,v in kw.items())
def fv(**kw): return ''.join('COMPUTE WS-F%s = %s\n'%(k,v) for k,v in kw.items())
ST={'1':'ITEMX'}
# ===== 1
g=GG(1,'Overview and shared facts','T0905','the seven types, their keys and ids, packets, tickers, the direction numbering, the squared-distance rule, the table sine, the drop helpers.')
rows=[(4,'jukebox',0,0,0),(29,'lectern',1,0,0),(30,'bell',0,0,0),(32,'campfire',0,5,1),(13,'enchanting_table',0,0,0),(40,'brushable_block',0,4,1),(33,'beehive',0,0,0)]
body="";exp=[]
for t,k,op,kind,pk in rows:
    body+='MOVE %d TO WS-A\n'%t+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+call('BE-SYNC-INFO','WS-A','WS-C','WS-E')+shw('t:WS-N24,WS-LEN','n:WS-B','n:WS-C','n:WS-E')
    exp+=[k,op,kind,pk]
g.case('types (1.1): key, operator-only flag (the lectern is in OP_ONLY_CUSTOM_DATA), tag kind and packet flag of the 7 types by registry id (jukebox 4, lectern 29, bell 30, campfire 32, enchanting table 13, brushable block 40, beehive 33)',body,[],exp)
body="";exp=[]
for blk,t,r in [('campfire',32,1),('soul_campfire',32,1),('suspicious_sand',40,1),('suspicious_gravel',40,1),('bee_nest',33,1),('beehive',33,1),('jukebox',4,1),('lectern',29,1),('bell',30,1),('enchanting_table',13,1),('campfire',33,0),('sand',40,0)]:
    body+='MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-SVL\nMOVE %d TO WS-A\n'%(blk,10+len(blk),t)+call('BE-VALID-BLOCK','WS-A','WS-KEY','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(r)
g.case('valid blocks (1.1): campfire and soul_campfire, suspicious sand and gravel, bee nest and beehive, jukebox, lectern, bell and enchanting table belong to their types and to no other',body,[],exp)
tk={4:(1,1),29:(0,0),30:(2,2),32:(3,3),13:(0,4),40:(0,0),33:(5,0)}
body="";exp=[]
for t,v in tk.items():
    body+='MOVE %d TO WS-A\n'%t+call('BE4-REGISTRATION','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C'); exp+=list(v)
g.case('tickers (1.1): server and client ticker per type (1 jukebox when has_record, 2 bell on both sides, 3 campfire cook or cool down and particles, 4 enchanting table client only, 5 beehive server only, 0 none)',body,[],exp)
body="";exp=[]
D2={0:-1,1:-1,2:2,3:0,4:1,5:3}; ST3={0:(0,-1,0),1:(0,1,0),2:(0,0,-1),3:(0,0,1),4:(-1,0,0),5:(1,0,0)}; CW={2:5,5:3,3:4,4:2,0:-1,1:-1}
for d in range(6):
    body+=mv(A=d)+call('BE4-DIR-INFO','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-B','n:WS-C','n:WS-E','n:WS-F','n:WS-G','n:WS-H')
    exp+=[D2[d],(D2[d]&3)*90,CW[d]]+list(ST3[d])
g.case('directions (1.3): 2D data value (south 0, west 1, north 2, east 3, vertical -1), toYRot (data2D and 3) * 90, getClockWise (north east, east south, south west, west north) and the steps of the six directions',body,[],exp)
body="";exp=[]
for (px,py,pz,bx,by,bz,d) in [(0.5,0.5,0.5,0,0,0,1.0),(1.5,0.5,0.5,0,0,0,0.99),(1.5,0.5,0.5,0,0,0,1.0),(1.5,0.5,0.5,0,0,0,1.01),(3.5,64.5,-2.5,2,64,-3,2.0),(35.0,0.5,0.5,0,0,0,32.0),(32.4,0.5,0.5,0,0,0,32.0)]:
    body+=fv(A=px,B=py,C=pz,D=d)+mv(A=bx,B=by,C=bz)+'CALL "BE4-CLOSER" USING WS-FA WS-FB WS-FC WS-A WS-B WS-C WS-FD WS-E\n'+shw('n:WS-E')
    exp.append(int((px-(bx+0.5))**2+(py-(by+0.5))**2+(pz-(bz+0.5))**2 < d*d))
g.case('closerToCenterThan (1.3): the squared distance from the block centre is strictly less than d * d (exactly d is not closer)',body,[],exp)
def msin(d):
    k=int(d*10430.378350470453)&65535
    return f32(math.sin(k/10430.378350470453))
def mcos(d):
    k=int(d*10430.378350470453+16384.0)&65535
    return f32(math.sin(k/10430.378350470453))
body="";exp=[]
vals=[0.0,0.5,1.0,1.5707,3.0,-1.0,-0.25,6.0,100.5,1/math.pi*7]
for v in vals:
    body+=fv(A=repr(v))+call('BE4-MTH-SIN','WS-FA','WS-FB')+call('BE4-MTH-COS','WS-FA','WS-FC')+shw('f:WS-FB','f:WS-FC'); exp+=[msin(v),mcos(v)]
g.case('Mth.sin and Mth.cos (1.3): SIN[(long)(d * 10430.378350470453) and 65535] as a float, cos with 16384.0 added before the cast (negative arguments wrap)',body,[],exp)
body="";exp=[]
for (x,y,z,r1,r2,r3) in [(0,64,0,0.0,0.0,0.0),(0,64,0,1.0,1.0,1.0),(10,5,-3,0.5,0.25,0.75),(-4,70,9,0.125,0.5,0.875)]:
    body+=mv(A=x,B=y,C=z)+fv(A=r1,B=r2,C=r3)+call('BE4-DROP-POS','WS-A','WS-B','WS-C','WS-FA','WS-FB','WS-FC','WS-FD','WS-FE','WS-FF')+shw('f:WS-FD','f:WS-FE','f:WS-FF')
    exp+=[x+r1*0.75+0.125,y+r2*0.75,z+r3*0.75+0.125]
g.case('dropItemStack position (1.3): px = floor(x) + r1 * (1 - w) + w / 2 and pz likewise, py = floor(y) + r2 * (1 - w) with w = 0.25 (draw order x, y, z)',body,[],exp)
body="";exp=[]
for (c,d,a,b) in [(0.2,0.11485000171139836,0.75,0.25),(0.0,0.11485000171139836,0.5,0.5),(1.0,0.2,0.125,0.875)]:
    body+=fv(A=c,B=d,C=a,D=b)+call('BE4-TRIANGLE','WS-FA','WS-FB','WS-FC','WS-FD','WS-FE')+shw('f:WS-FE'); exp.append(c+d*(a-b))
for rem,r in [(64,0),(64,20),(15,10),(5,3),(30,20)]:
    body+=mv(A=rem,B=r)+call('BE4-DROP-SPLIT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(min(rem,10+r))
g.case('drop helpers (1.3): triangle(c, d) = c + d * (a - b); the stack is split in chunks of nextInt(21) + 10 or the rest',body,[],exp)
W(g,1)
# ===== 2
g=GG(2,'Jukebox','T0907','the song length rules, the song player events and tick, setTheItem, the container rules, the signal, persistence with the resume of a loaded tick count.')
JB=create(4,'jukebox')
body="";exp=[]
for sec in (178.0,59.1,0.05,1.0,2.5):
    body+='COMPUTE WS-FA = %s\nMOVE WS-FA TO BE-XF(1, 1)\n'%sec+call('BE4-SONG-TICKS','BE-XF(1, 1)','WS-A')+shw('n:WS-A'); exp.append(math.ceil(f32(f32(sec)*20.0)))
for t,l in [(3579,3560),(3580,3560),(3581,3560),(0,0),(20,0),(19,0)]:
    body+=mv(A=t,B=l)+call('BE4-SONG-FINISHED','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(t>=l+20))
g.case('song length (2.1): lengthInTicks = ceil(length_in_seconds * 20) in float arithmetic (178 s is 3560); hasFinished(t) is t >= lengthInTicks + 20',body,[],exp)
em=0;ticks=0;stop_at=0
for step in range(1,3600):
    if ticks>=3580: stop_at=step; break
    if ticks%20==0: em+=1
    ticks+=1
body=JB+mv(A=13,B=3560)+call('BE4-JUKEBOX-PLAY','WS-IDX','WS-A','WS-B','WS-E','WS-F')+shw('n:WS-E','n:WS-F','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 1)')
body+='MOVE 0 TO WS-G\nMOVE 0 TO WS-H\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3600\nCALL "BE4-JUKEBOX-TICK" USING WS-IDX WS-A WS-C\nADD WS-A TO WS-G\nIF WS-C = 1\nMOVE WS-J TO WS-H\nEND-IF\nEND-PERFORM\n'+shw('n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 1)')
g.case('song player (2.4, worked example): play sets the song and ticks 0 with level event 1010 and the song id; ticks 0, 20, ... 3560 emit jukebox_play (179 times); the tick that sees 3580 stops it (stopped, event 1011 for the caller) and nothing runs after',body,[],[1010,13,1,0,em,stop_at,0,0])
body=JB+call('BE4-JUKEBOX-STOP','WS-IDX','WS-A','WS-B')+shw('n:WS-A','n:WS-B')+mv(A=7,B=100)+call('BE4-JUKEBOX-PLAY','WS-IDX','WS-A','WS-B','WS-E','WS-F')+call('BE4-JUKEBOX-STOP','WS-IDX','WS-G','WS-H')+shw('n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 1)')
g.case('stop (2.4): nothing happens without a song; with one the song is cleared, ticks reset and level event 1011 is raised',body,[],[0,0,1,1011,0,0])
body=JB+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 5 TO WS-C\nMOVE 3560 TO WS-E\nMOVE 1 TO WS-F\n'+call('BE4-JUKEBOX-SET-ITEM','WS-IDX','WS-A','WS-B','WS-F','WS-C','WS-E','WS-F','WS-G','WS-H')
# item=WS-A, count=WS-B, var=WS-F? use distinct vars
body=JB+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE 5 TO WS-E\nMOVE 3560 TO WS-F\nMOVE 1 TO WS-G\n'+call('BE4-JUKEBOX-SET-ITEM','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-EV')
body+=shw('n:WS-H','n:WS-EV','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 5)','n:BE-SLOT-COUNT(WS-IDX, 1)')
body+='MOVE 0 TO WS-B\nMOVE -1 TO WS-E\n'+call('BE4-JUKEBOX-SET-ITEM','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-EV')+shw('n:WS-H','n:WS-EV','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 5)','n:BE-SLOT-COUNT(WS-IDX, 1)')
body+=call('BE4-JUKEBOX-SET-ITEM','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-EV')+shw('n:WS-H','n:WS-EV')
g.case('setTheItem (2.3): a disc with a song is stored, has_record is set, the song starts (event 1010) and the comparator output is the song\'s; an empty slot clears has_record, stops the song (1011) and the comparator is 0; stopping again raises nothing',body,[],[1,1010,1,5,1,1, 0,1011,0,0,0, 0,0])
body=''.join(call('BE4-JUKEBOX-RULES','WS-A','WS-B','WS-C','WS-E').replace('WS-A','WS-A') for _ in [])
body=""
exp=[]
for k,a,b in [(1,1,1),(1,1,0),(1,0,1),(2,1,0),(2,0,0)]:
    body+=mv(A=k,B=a,C=b)+call('BE4-JUKEBOX-RULES','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E'); exp.append((a and b) if k==1 else a)
g.case('container rules (2.3): canPlaceItem needs a jukebox_playable stack and an empty slot; canTakeItem needs the destination to have an empty slot',body,[],exp)
body=JB+call('BE4-JUKEBOX-SIGNAL','WS-IDX','WS-A','WS-B')+shw('n:WS-A','n:WS-B')+mv(A=1,B=100)+call('BE4-JUKEBOX-PLAY','WS-IDX','WS-A','WS-B','WS-E','WS-F')+call('BE4-JUKEBOX-SIGNAL','WS-IDX','WS-G','WS-H')+shw('n:WS-G','n:WS-H')
g.case('signal (2.5): ownSignal is 15 while the song player plays, else 0; the comparator output is that of the stored disc',body,[],[0,0,15,0])
body=JB+'MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 1)\nMOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)\nMOVE 2 TO WS-FORM\n'+'MOVE 1 TO WS-A\nMOVE 100 TO WS-B\n'+call('BE4-JUKEBOX-PLAY','WS-IDX','WS-A','WS-B','WS-E','WS-F')+'MOVE 40 TO BE-XI(WS-IDX, 1)\n'+shw('SAVE')
g.case('save (2.2): RecordItem when the stored item is not empty and ticks_since_song_started (a Long) while a song plays; an idle jukebox with an item saves only RecordItem',body+'MOVE 0 TO BE-XI(WS-IDX, 2)\n'+shw('SAVE'),[],['{RecordItem:{id:cobolcraft:greystone,count:1},ticks_since_song_started:40} {RecordItem:{id:cobolcraft:greystone,count:1}}'])
LJ=nb_begin()+nb_c('RecordItem')+nb_stack(2,1)+nb_e()+nb_long('ticks_since_song_started',4000)
body=JB+LJ+'PERFORM LOAD-BUFFER\n'+'MOVE 1 TO WS-A\nMOVE 3560 TO WS-B\n'+call('BE4-JUKEBOX-RESUME','WS-IDX','WS-A','WS-B','WS-E')+shw('n:BE-SLOT-COUNT(WS-IDX, 1)','n:WS-E','n:BE-XI(WS-IDX, 2)')+'MOVE 2 TO WS-FORM\n'+shw('SAVE')
LJ2=nb_begin()+nb_c('RecordItem')+nb_stack(2,1)+nb_e()+nb_long('ticks_since_song_started',500)
body+=JB+LJ2+'PERFORM LOAD-BUFFER\n'+call('BE4-JUKEBOX-RESUME','WS-IDX','WS-A','WS-B','WS-E')+shw('n:WS-E','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 1)')
body+=JB+call('BE4-JUKEBOX-RESUME','WS-IDX','WS-A','WS-B','WS-E')+shw('n:WS-E')
g.case('load (2.2, V2): the record loads; a stored tick count of 4000 for the 3560-tick song is finished, so the resume is ignored and saving writes RecordItem only; 500 resumes the song at tick 500 without events; no stored count resumes nothing',body,[],[1,0,0,'{RecordItem:{id:cobolcraft:greystone,count:1}}',1,1,500,0])
LJ3=nb_begin()+nb_c('RecordItem')+nb_stack(3,1)+nb_e()
body=JB+LJ2+'PERFORM LOAD-BUFFER\n'+call('BE4-JUKEBOX-RESUME','WS-IDX','WS-A','WS-B','WS-E')+LJ3+'PERFORM LOAD-BUFFER\n'+shw('n:BE-XI(WS-IDX, 2)','n:BE-SLOT-ITEM(WS-IDX, 1)')
g.case('load of another record (2.2 step 2, V3): while a song plays a RecordItem of another disc stops the player before the new item is stored',body,[],[0,3])
W(g,2)
# ===== 3
LC=create(29,'lectern')
def sig(page,pc,hasbook=1):
    f=f32(page/(pc-1)) if pc>1 else 1.0
    return int(math.floor(f32(f*14)))+hasbook
g=GG(3,'Lectern','T0909','state and operations, the page clamp, the redstone signal, the menu buttons, the use and placement rules, persistence.')
body=LC+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE 5 TO WS-E\n'+call('BE4-LECTERN-SET-BOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E')+call('BE4-LECTERN-SIGNAL','WS-IDX','WS-F')+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:WS-F')
exp=[0,5,1]
for n in (1,2):
    body+='MOVE 2 TO WS-A\n'+call('BE4-LECTERN-BUTTON','WS-IDX','WS-A','WS-B','WS-G','WS-H','WS-C')+shw('n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 1)'); exp+=[1,1,n]
body+=call('BE4-LECTERN-SIGNAL','WS-IDX','WS-F')+shw('n:WS-F'); exp.append(sig(2,5))
body+='MOVE 104 TO WS-A\n'+call('BE4-LECTERN-BUTTON','WS-IDX','WS-A','WS-B','WS-G','WS-H','WS-C')+call('BE4-LECTERN-SIGNAL','WS-IDX','WS-F')+shw('n:BE-XI(WS-IDX, 1)','n:WS-F'); exp+=[4,sig(4,5)]
body+='MOVE 109 TO WS-A\n'+call('BE4-LECTERN-BUTTON','WS-IDX','WS-A','WS-B','WS-G','WS-H','WS-C')+shw('n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 1)'); exp+=[1,0,4]
g.case('worked example 1 (3.3, 3.5): a 5-page book set gives page 0 and signal 1; next page twice (button 2) is page 2 with signal 8, each change raising the page signal; jump to page 4 (button 104) gives 15; button 109 clamps to page 4 and changes nothing (handled, no change)',body,[],exp)
body=""; exp=[]
for pc,page in [(1,0),(0,0),(2,1),(3,2),(14,13),(14,7)]:
    body+=LC+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE %d TO WS-E\n'%pc+call('BE4-LECTERN-SET-BOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E')+'MOVE %d TO BE-XI(WS-IDX, 1)\n'%page+call('BE4-LECTERN-SIGNAL','WS-IDX','WS-F')+shw('n:WS-F'); exp.append(sig(page,pc) if pc>0 else 15)
g.case('signal (3.3): floor((pageCount > 1 ? page / (pageCount - 1) : 1.0) * 14) plus 1 with a book (a 1-page or 0-page book gives 15; 14 pages at page 13 gives 15; page 7 of 14 gives 7 in float arithmetic)',body,[],exp)
body=LC+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE 0 TO WS-E\n'+call('BE4-LECTERN-SET-BOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E')+'MOVE 5 TO WS-A\n'+call('BE4-LECTERN-PAGE','WS-IDX','WS-A','WS-B','WS-C','WS-E')+shw('n:BE-XI(WS-IDX, 1)','n:WS-B','n:WS-C','n:WS-E')
g.case('page clamp (3.2, 3.3): setPage on a book with 0 pages clamps to -1 (min(max(n, 0), -1)); the change is signalled with a 2-tick delay and level event 1043 (page 0 to -1)',body,[],[-1,1,2,1043])
body=LC+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE 3 TO WS-E\n'+call('BE4-LECTERN-SET-BOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E')+nb_begin()
LL=nb_begin()+nb_c('Book')+nb_stack(2,1)+nb_e()+nb_i('Page',7)
body=LC+LL+'PERFORM LOAD-BUFFER\n'+'MOVE 3 TO WS-A\n'+call('BE4-LECTERN-RESOLVE','WS-IDX','WS-A')+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')+'MOVE 2 TO WS-FORM\n'+shw('SAVE')
body+=LC+'MOVE 0 TO WS-A\n'+call('BE4-LECTERN-RESOLVE','WS-IDX','WS-A')+shw('n:BE-XI(WS-IDX, 1)')+'MOVE 2 TO WS-FORM\n'+shw('SAVE')
g.case('persistence (3.2, V8): Book and Page load; with a 3-page book Page 7 is page 2; saved as Book then Page (an empty lectern saves nothing, an empty book is page -1 after the resolve)',body,[],[2,3,'{Book:{id:cobolcraft:greystone,count:1},Page:2}',-1,'{}'])
body=LC+'MOVE 2 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\nMOVE 5 TO WS-E\n'+call('BE4-LECTERN-SET-BOOK','WS-IDX','WS-A','WS-B','WS-C','WS-E')
for mb in (0,1):
    body+='MOVE %d TO WS-A\nMOVE 3 TO WS-B\n'%mb  # b: mayBuild in A
    body+='MOVE 3 TO WS-A\nMOVE %d TO WS-B\n'%mb+call('BE4-LECTERN-BUTTON','WS-IDX','WS-A','WS-B','WS-G','WS-H','WS-C')+shw('n:WS-G','n:WS-C','n:BE-SLOT-COUNT(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')
body+=LC+'MOVE 77 TO WS-A\n'+call('BE4-LECTERN-BUTTON','WS-IDX','WS-A','WS-B','WS-G','WS-H','WS-C')+shw('n:WS-G')
g.case('menu button 3 (3.5, V7): a player who may not build gets false and the book stays; otherwise the book is taken (handled, taken, the slot and the page count are emptied: onBookItemRemove); an unknown button is not handled',body,[],[0,0,1,5, 1,1,0,0, 0])
body=""; exp=[]
for hb,tag,empty,main in [(1,0,0,1),(0,1,0,1),(0,0,1,1),(0,0,1,0),(0,0,0,1),(1,1,1,1)]:
    body+=mv(A=hb,B=tag,C=empty,E=main)+call('BE4-LECTERN-USE-ITEM','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
    exp.append(1 if hb else 2 if tag else 3 if (empty and main) else 1)
g.case('use with an item (3.7): a lectern with a book tries the empty hand (1); a book of lectern_books is placed (2); an empty main hand passes (3); anything else tries the empty hand (1)',body,[],exp)
body=""; exp=[]
for gm,key in [(1,1),(1,0),(0,1),(0,0)]:
    body+=mv(A=gm,B=key)+call('BE4-LECTERN-PLACEMENT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(gm and key))
for pw,d in [(1,1),(1,0),(0,1),(0,0)]:
    body+=mv(A=pw,B=d)+call('BE4-LECTERN-DIRECT','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(15 if (pw and d==1) else 0)
g.case('placement and signals (3.7): has_book is set at placement only for a player who may use game-master blocks with a Book key in the item data; getDirectSignal is 15 for direction UP (1) while powered',body,[],exp)
W(g,3)
# ===== 4
BL=create(30,'bell')
def bell_sim():
    ticks=0;shaking=1;rt=0;res=0;log=[]
    # event at time 0: ticks 0, shaking 1, rt 0
    for n in range(1,61):
        if shaking: ticks+=1
        if ticks>=50: shaking=0;ticks=0
        rs=0;end=0
        if ticks>=5 and rt==0:
            res=1;rs=1
        if res:
            if rt<40: rt+=1
            else: end=1;res=0
        log.append((n,rs,end,ticks,shaking,rt))
    return log
g=GG(4,'Bell','T0911','ringing and the event, the tick with resonance, the end actions, the particle count and colours, the proper hit test, the ring conditions, the redstone edge and the animation.')
body=BL+mv(A=3)+call('BE4-BELL-HIT','WS-IDX','WS-A','WS-F','WS-G')+shw('n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 2)','n:WS-F','n:WS-G')
body+='MOVE 20 TO BE-XI(WS-IDX, 1)\n'+mv(A=5)+call('BE4-BELL-HIT','WS-IDX','WS-A','WS-F','WS-G')+shw('n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 1)','n:WS-F','n:WS-G')
g.case('onHit (4.2): the click direction is stored; a bell that is not shaking starts (shaking true), one that shakes restarts (ticks 0); the block event is type 1 with the direction value as data',body,[],[3,1,1,3, 5,0,1,5])
body=BL+'MOVE 1000 TO BE-XI(WS-IDX, 4)\nMOVE 33 TO BE-XI(WS-IDX, 5)\nMOVE 7 TO BE-XI(WS-IDX, 1)\n'+mv(A=1,B=4)+call('BE4-BELL-EVENT','WS-IDX','WS-A','WS-B','WS-E')+shw('n:WS-E','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 5)')
body+=mv(A=2,B=4)+'MOVE 9 TO BE-XI(WS-IDX, 1)\n'+call('BE4-BELL-EVENT','WS-IDX','WS-A','WS-B','WS-E')+shw('n:WS-E','n:BE-XI(WS-IDX, 1)')
g.case('triggerEvent (4.2): type 1 sets clickDirection from the data, ticks 0, shaking true and resonationTicks 0 (handled); any other type goes to the base class (not handled, state kept)',body,[],[1,4,0,1,0, 0,9])
body=BL+mv(A=100)+call('BE4-BELL-REFRESH','WS-IDX','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 6)')
for t in (160,161,200):
    body+=mv(A=t)+call('BE4-BELL-REFRESH','WS-IDX','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 6)')
g.case('updateEntities (4.2): the list is refreshed when there is none or gameTime is above lastRingTimestamp + 60 (at 160 it is reused; at 161 it is refreshed and the timestamp moves; at 200 it is reused)',body,[],[1,100,0,100,1,161,0,161])
log=bell_sim()
body=BL+mv(A=1,B=2)+call('BE4-BELL-EVENT','WS-IDX','WS-A','WS-B','WS-E')+'MOVE 0 TO WS-G\nMOVE 0 TO WS-H\nMOVE 0 TO WS-C\nMOVE 1 TO WS-F\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 60\nCALL "BE4-BELL-TICK" USING WS-IDX WS-F WS-A WS-B\nIF WS-A = 1\nMOVE WS-J TO WS-G\nEND-IF\nIF WS-B = 1\nMOVE WS-J TO WS-H\nEND-IF\nIF BE-XI(WS-IDX, 2) = 0 AND WS-C = 0\nMOVE WS-J TO WS-C\nEND-IF\nEND-PERFORM\n'+shw('n:WS-G','n:WS-H','n:WS-C','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 4)')
rs=[l[0] for l in log if l[1]][0]; en=[l[0] for l in log if l[2]][0]; sh=[l[0] for l in log if l[4]==0][0]
g.case('tick (4.3, worked example 4.6): after the event, with a raider near, tick 5 starts the resonance (sound), ticks 5 to 44 raise resonationTicks to 40, tick 45 runs the end action and ends the resonance, tick 50 stops the shake; resonationTicks stays 40 so there is no second resonance',body,[],[rs,en,sh,40,0])
body=BL+mv(A=1,B=2)+call('BE4-BELL-EVENT','WS-IDX','WS-A','WS-B','WS-E')+'MOVE 0 TO WS-F\nMOVE 0 TO WS-G\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 20\nCALL "BE4-BELL-TICK" USING WS-IDX WS-F WS-A WS-B\nADD WS-A TO WS-G\nEND-PERFORM\n'+shw('n:WS-G','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 4)')
g.case('tick without raiders (4.3): the shake runs (ticks 20, shaking) but no resonance starts without a raider within 32',body,[],[0,20,1,0])
body="";exp=[]
for c in (1,2,3,15,17,25,40):
    body+=mv(A=c)+call('BE4-BELL-COUNT','WS-A','WS-B')+shw('n:WS-B'); exp.append(min(15,max(3,int((c-21)/-2))))
for k in (1,2,9):
    body+=mv(A=k)+call('BE4-BELL-COLOR','WS-A','WS-B')+shw('n:WS-B'); exp.append(16700985+5*k)
g.case('client particles (4.3, V10): n = clamp((c - 21) / -2, 3, 15) with truncating division gives 10, 9, 9, 3, 3, 3, 3 for c = 1, 2, 3, 15, 17, 25, 40; the colour starts at 16700985 and rises by 5 per particle (first 16700990)',body,[],exp)
def proper(att,facing,d,y):
    ax=lambda x:0 if x<2 else 1 if x<4 else 2
    if ax(d)==0 or y>0.8123999834060669: return 0
    if att==0: return int(ax(d)==ax(facing))
    if att in (2,3): return int(ax(d)!=ax(facing))
    return 1
body="";exp=[]
for att in range(4):
    for facing,d,y in [(2,2,0.5),(2,4,0.5),(4,5,0.5),(2,1,0.5),(2,2,0.9),(2,2,0.8124),(3,0,0.1)]:
        body+=mv(A=att,B=facing,C=d)+fv(A=y)+call('BE4-BELL-PROPER','WS-A','WS-B','WS-C','WS-FA','WS-E')+shw('n:WS-E'); exp.append(proper(att,facing,d,y))
g.case('isProperHit (4.5, V11): never on the Y axis or above relative y 0.8123999834060669 (0.8124 is already above); floor needs the facing axis, walls the other axis, ceiling any horizontal hit (attachment 0 floor, 1 ceiling, 2 single wall, 3 double wall)',body,[],exp)
body="";exp=[]
for (srv,ent,d,f) in [(1,1,3,2),(1,1,-1,4),(0,1,3,2),(1,0,3,2)]:
    body+=mv(A=srv,B=ent,C=d,E=f)+call('BE4-BELL-RING','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-F','n:WS-G')
    exp+=[ (d if d>=0 else f) if (srv and ent) else -1, int(srv and ent)]
for sg,pw in [(1,0),(1,1),(0,1),(0,0)]:
    body+=mv(A=sg,B=pw)+call('BE4-BELL-NEIGHBOR','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:WS-E'); exp+=[int(sg==1 and pw==0),sg]
g.case('attemptToRing and the redstone edge (4.5): a bell entity on the server rings in the direction hit, or its facing when none (dir used, ring 1); the client or a missing entity does not ring (-1, 0); a rising signal rings and powered follows the signal (ring, new powered)',body,[],exp)
body="";exp=[]
for t,d in [(0.0,2),(10.5,2),(10.5,3),(10.5,5),(10.5,4),(10.5,0),(10.5,-1)]:
    body+=fv(A=t)+mv(A=d)+call('BE4-BELL-ANIM','WS-FA','WS-A','WS-FB','WS-FC')+shw('f:WS-FB','f:WS-FC')
    if d<2 : exp+=[0,0]; continue
    a=f32(msin(t/math.pi) if False else 0)
    k=int((t/math.pi)*10430.378350470453)&65535
    a=f32(math.sin(k/10430.378350470453))/(4+t/3)
    xr=-a if d==2 else a if d==3 else 0
    zr=-a if d==5 else a if d==4 else 0
    exp+=[xr,zr]
g.case('bell animation (4.4): a = Mth.sin(ticks / PI) / (4 + ticks / 3) (the table sine); north tilts x by -a, south by +a, east z by -a, west by +a; other directions leave both 0 (x then z rotation)',body,[],exp)
W(g,4)
# ===== 5
CF=create(32,'campfire')
RECIPE='MOVE 1 TO RC-COUNT\nMOVE 17 TO RR-SERIALIZER(1)\nMOVE SPACES TO RR-ING(1, 1)\nMOVE "cobolcraft:loam" TO RR-ING(1, 1)\nMOVE "cobolcraft:greystone" TO RR-RESULT-ID(1)\nMOVE 1 TO RR-RESULT-COUNT(1)\nMOVE 600 TO RR-COOK-TIME(1)\n'
g=GG(5,'Campfire','T0913','slots and saved keys, the cooking recipe lookup, placing food, the cook tick and the cool down, the smoke offsets and the hive smoke rule, the update tag.')
body=RECIPE+'MOVE 3 TO WS-A\n'+call('FURN-RECIPE','WS-NV','WS-A','WS-B','WS-C','WS-E','WS-F','WS-FA')
body=RECIPE+'MOVE 32 TO WS-NV\nMOVE 3 TO WS-A\n'+call('BE4-CAMPFIRE-RECIPE','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-B','n:WS-C','n:WS-E','n:WS-F')+'MOVE 1 TO WS-A\n'+call('BE4-CAMPFIRE-RECIPE','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-B','n:WS-C')
g.case('recipe (5.5): the campfire_cooking recipe whose ingredient holds the item (loam gives greystone x1 in 600 ticks, row 1); an item without a recipe gives row 0',body,[],[1,2,1,600,0,0])
body=CF+RECIPE+'MOVE 3 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\n'+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:WS-E','n:BE-SLOT-ITEM(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 1)','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 1)')
body+='MOVE 600 TO BE-XI(WS-IDX, 1)\nMOVE 77 TO BE-XI(WS-IDX, 2)\n'+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:BE-SLOT-ITEM(WS-IDX, 2)','n:BE-XI(WS-IDX, 6)','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')
body+='MOVE 1 TO WS-A\n'+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:BE-SLOT-COUNT(WS-IDX, 3)')
body+='MOVE 3 TO WS-A\n'+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:BE-SLOT-COUNT(WS-IDX, 4)')
body+=call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
g.case('placeFood (5.4, V14): the first empty slot takes one item, cookingTime from the recipe and progress 0 (the old progress is reset); an item without a recipe is refused even with empty slots left (the scan stops); with all four slots used the food is refused',body,[],[1,1,3,1,600,0, 1,3,600,600,0, 0,0, 1,1, 0])
body=CF+RECIPE+'MOVE 3 TO WS-A\nMOVE 1 TO WS-B\nMOVE 0 TO WS-C\n'+call('BE4-CAMPFIRE-PLACE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+'MOVE 1 TO BE-SLOT-ITEM(WS-IDX, 2)\nMOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)\nMOVE 5 TO BE-XI(WS-IDX, 2)\nMOVE 5 TO BE-XI(WS-IDX, 6)\n'
body+=call('BE4-CAMPFIRE-COOK','WS-IDX','WS-DROPS','WS-G')+shw('n:WS-G','n:WS-DROP-ITEM(2)','n:WS-DROP-COUNT(2)','n:BE-SLOT-COUNT(WS-IDX, 2)','n:BE-XI(WS-IDX, 2)')
body+='PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 598\nCALL "BE4-CAMPFIRE-COOK" USING WS-IDX WS-DROPS WS-G\nEND-PERFORM\n'+shw('n:BE-XI(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 1)','n:WS-DROP-COUNT(1)')
body+=call('BE4-CAMPFIRE-COOK','WS-IDX','WS-DROPS','WS-G')+shw('n:WS-G','n:BE-XI(WS-IDX, 1)','n:BE-SLOT-COUNT(WS-IDX, 1)','n:WS-DROP-ITEM(1)','n:WS-DROP-COUNT(1)','n:BE-XI(WS-IDX, 2)')
body+=call('BE4-CAMPFIRE-COOK','WS-IDX','WS-DROPS','WS-G')+shw('n:WS-G','n:BE-XI(WS-IDX, 1)','n:WS-DROP-COUNT(1)')
g.case('cook tick (5.3, worked example 1, V12): each lit tick adds 1 to the progress of a non-empty slot; at 600 the recipe result drops (item 2 x1) and the slot empties, the progress stays 600 and an empty slot is skipped; an item with no recipe drops itself (item 1, its progress 6 of 5 on the first tick)',body,[],[1,1,1,0,6, 599,1,0, 1,600,0,2,1,6, 0,600,0])
body=CF
for i,(p,t) in enumerate([(250,600),(1,600),(0,600),(599,600)]):
    body+='MOVE %d TO BE-XI(WS-IDX, %d)\nMOVE %d TO BE-XI(WS-IDX, %d)\n'%(p,i+1,t,i+5)
body+='PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 125\nCALL "BE4-CAMPFIRE-COOLDOWN" USING WS-IDX WS-G\nEND-PERFORM\n'+shw('n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 4)')+call('BE4-CAMPFIRE-COOLDOWN','WS-IDX','WS-G')+shw('n:BE-XI(WS-IDX, 1)','n:WS-G')+'MOVE 0 TO BE-XI(WS-IDX, 4)\n'+call('BE4-CAMPFIRE-COOLDOWN','WS-IDX','WS-G')+shw('n:WS-G')
g.case('cool down (5.3, worked example 2, V13): an unlit campfire lowers every progress above 0 by 2 per tick, never below 0, whether the slot holds food or not (250 reaches 0 after 125 ticks; 599 of 600 is 349 after 125 ticks); the tick reports a change only while a progress was above 0',body,[],[0,0,0,349,0,1,0])
body="";exp=[]
CWd={0:1,1:2,2:3,3:0}
SX={0:0,1:-1,2:0,3:1};SZ={0:1,1:0,2:-1,3:0}
for facing in range(4):
    for i in range(4):
        d=(i+facing)%4; c=CWd[d]
        body+=mv(A=facing,B=i)+call('BE4-CAMPFIRE-SMOKE','WS-A','WS-B','WS-FA','WS-FB')+shw('f:WS-FA','f:WS-FB')
        exp+=[0.5-SX[d]*0.3125+SX[c]*0.3125,0.5-SZ[d]*0.3125+SZ[c]*0.3125]
g.case('smoke offsets (5.3, 5.8): slot i smokes from d = from2DDataValue(floorMod(i + facing2D, 4)) at x = 0.5 - stepX(d) * 0.3125 + stepX(clockWise(d)) * 0.3125 (z likewise)',body,[],exp)
def smokey(k):
    for i in range(5):
        b=k[i]
        if b==1: return 1
        if b==2: return int(k[i+1]==1)
    return 0
cases=[(0,0,1,0,0,0),(2,1,0,0,0,0),(2,0,1,0,0,0),(0,0,0,0,0,1),(2,0,0,0,0,0),(0,2,1,0,0,0),(1,0,0,0,0,0),(2,2,1,0,0,0),(0,0,0,0,2,1)]
body="";exp=[]
for k in cases:
    body+=''.join(mv(**{})+'MOVE %d TO WS-KIND(%d)\n'%(v,i+1) for i,v in enumerate(k))+call('BE4-SMOKEY','WS-KINDS','WS-A')+shw('n:WS-A'); exp.append(smokey(k))
g.case('isSmokeyPos (5.9, V25): scanning the 5 blocks below the hive (0 free, 1 lit campfire, 2 blocks the centre column): a lit campfire is true; a blocking block counts only when the next one down is a lit campfire; a campfire 6 below is out of reach',body,[],exp)
body=CF+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+'MOVE 3 TO BE-SLOT-ITEM(WS-IDX, 2)\nMOVE 1 TO BE-SLOT-COUNT(WS-IDX, 2)\nMOVE 10 TO BE-XI(WS-IDX, 2)\nMOVE 600 TO BE-XI(WS-IDX, 6)\n'+shw('SAVE')
body+='MOVE 6 TO WS-A\nCALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nMOVE 0 TO WS-LEN\nMOVE SPACES TO WS-OUT\nCALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN\nCALL "PB-FREE" USING PB-BUFFER\nMOVE WS-LEN TO WS-A\n'+shw('t:WS-OUT,WS-A')
g.case('saved keys and update tag (5.2, 5.6, V15): Items is written even when empty with CookingTimes and CookingTotalTimes (always 4 ints); the update tag holds only Items',body,[],['{Items:[],CookingTimes:I[0,0,0,0],CookingTotalTimes:I[0,0,0,0]} {Items:[{Slot:1,id:cobolcraft:loam,count:1}],CookingTimes:I[0,10,0,0],CookingTotalTimes:I[0,600,0,0]} {Items:[{Slot:1,id:cobolcraft:loam,count:1}]}'])
LCF=nb_begin()+nb_l('Items',10,2)+nb_b('Slot',1)+nb_stack(3,1)+nb_e()+nb_b('Slot',4)+nb_stack(3,1)+nb_e()+nb_intarr('CookingTimes',[10,0])+nb_intarr('CookingTotalTimes',[600])
g.case('load (5.2, worked example 4): slots 0 to 3 load (4 is ignored); each present array is copied for min(length, 4) entries, the rest stays 0 (progress 10,0,0,0, totals 600,0,0,0); absent arrays read as 0',CF+LCF+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE')+CF+nb_begin()+nb_intarr('CookingTimes',[1,2,3,4,5,6])+'PERFORM LOAD-BUFFER\n'+shw('SAVE'),[],['{Items:[{Slot:1,id:cobolcraft:loam,count:1}],CookingTimes:I[10,0,0,0],CookingTotalTimes:I[600,0,0,0]} {Items:[],CookingTimes:I[1,2,3,4],CookingTotalTimes:I[0,0,0,0]}'])
W(g,5)
# ===== 6
EN=create(13,'enchanting_table')
def st(): return dict(flip=0.0,oflip=0.0,flipT=0.0,flipA=0.0,open=0.0,oopen=0.0,rot=0.0,orot=0.0,tRot=0.0,time=0)
PI=f32(3.1415927);TWO=f32(6.2831855)
def norm(v):
    while v>=PI: v=f32(v-TWO)
    while v<-PI: v=f32(v+TWO)
    return v
def tick(s,present,dx,dz,draws):
    s['oopen']=s['open'];s['orot']=s['rot']
    d=list(draws)
    def nxt():
        return d.pop(0)
    if present:
        s['tRot']=f32(math.atan2(dz,dx))
        s['open']=f32(s['open']+f32(0.1))
        if s['open']<0.5 or nxt()==0:
            while True:
                old=s['flipT']
                a=nxt();b=nxt()
                s['flipT']=f32(s['flipT']+float(a-b))
                if s['flipT']!=old: break
    else:
        s['tRot']=f32(s['tRot']+f32(0.02)); s['open']=f32(s['open']-f32(0.1))
    s['rot']=norm(s['rot']); s['tRot']=norm(s['tRot'])
    delta=norm(f32(s['tRot']-s['rot']))
    s['rot']=f32(s['rot']+f32(delta*f32(0.4)))
    s['open']=min(1.0,max(0.0,s['open']))
    s['time']+=1
    s['oflip']=s['flip']
    f=min(f32(0.2),max(f32(-0.2),f32(f32(s['flipT']-s['flip'])*f32(0.4))))
    s['flipA']=f32(s['flipA']+f32(f32(f-s['flipA'])*f32(0.9)))
    s['flip']=f32(s['flip']+s['flipA'])
    return len(draws)-len(d)
g=GG(6,'Enchanting table','T0915','the client animation tick with its random draws, the open book, the naming and the saved key.')
def run_ticks(n,present,dx,dz,drawlist):
    s=st(); used=0
    body=EN
    for i in range(n):
        dr=drawlist[i]
        for j,v in enumerate(dr): body+='MOVE %d TO WS-DRAW(%d)\n'%(v,j+1)
        body+=('MOVE %d TO WS-A\nCOMPUTE WS-FA = %s\nCOMPUTE WS-FB = %s\n'%(present,dx,dz))+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')
        k=tick(s,present,dx,dz,dr)
    return body,s
# player at dx = 2: open grows 0.1 per tick; draws: below 0.5 pairs until the sum changes
draws=[[3,1],[2,2,0,2],[1,0],[0,0,1,3],[2,1]]
body,s=run_ticks(5,1,2.0,0.0,draws)
g.case('player near (6.3, worked example 6): atan2(0, 2) is 0; open rises by 0.1f per tick (0.3 after 3 ticks, 0.5 after 5), each tick below 0.5 draws pairs of nextInt(4) until flipT moves; flip follows with a velocity (flipT, flip, open, tRot shown after 5 ticks)',body+shw('f:BE-XF(WS-IDX, 3)','f:BE-XF(WS-IDX, 1)','f:BE-XF(WS-IDX, 5)','f:BE-XF(WS-IDX, 9)','f:BE-XF(WS-IDX, 7)','n:BE-XI(WS-IDX, 1)'),[],[s['flipT'],s['flip'],s['open'],s['tRot'],s['rot'],5])
body=EN
s=st()
for (dx,dz) in [(2.0,0.0),(0.0,1.0),(-2.0,0.0),(0.0,-1.0),(0.0,0.0)]:
    body+='MOVE 1 TO WS-A\nCOMPUTE WS-FA = %s\nCOMPUTE WS-FB = %s\nMOVE 1 TO WS-DRAW(1)\nMOVE 0 TO WS-DRAW(2)\n'%(dx,dz)+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')+shw('f:BE-XF(WS-IDX, 9)')
    tick(s,1,dx,dz,[1,0])
exp=[]
s=st()
for (dx,dz) in [(2.0,0.0),(0.0,1.0),(-2.0,0.0),(0.0,-1.0),(0.0,0.0)]:
    tick(s,1,dx,dz,[1,0]); exp.append(s['tRot'])
g.case('target angle (6.3 step 3): tRot = Mth.atan2(dz, dx) of the shim (east 0, north of the table 1.5707964, west -PI after the normalising, and so on; the cases are the exact multiples of PI / 2)',body,[],exp)
draws=[[1,0]]*1
body,s=run_ticks(1,1,2.0,0.0,[[1,0]])
s3=st()
bodyx=EN
for i in range(5):
    bodyx+='MOVE 1 TO WS-DRAW(1)\nMOVE 0 TO WS-DRAW(2)\nMOVE 1 TO WS-A\nCOMPUTE WS-FA = 2.0\nCOMPUTE WS-FB = 0.0\n'+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')+(shw('f:BE-XF(WS-IDX, 5)') if i in (2,3,4) else '')
    tick(s3,1,2.0,0.0,[1,0])
g.case('open book (6.3, 6.6): open after 3, 4 and 5 ticks is 0.30000001192092896, 0.4000000059604645 and 0.5 in single precision (so open < 0.5 is false from the fifth tick on)',bodyx,[],[s3['open']] if False else [f32(f32(f32(0.1)+f32(0.1))+f32(0.1)),f32(f32(f32(f32(0.1)+f32(0.1))+f32(0.1))+f32(0.1)),0.5])
# from open >= 0.5 : nextInt(40) first
body=EN+'MOVE 1.0 TO BE-XF(WS-IDX, 5)\n'
s=st(); s['open']=1.0
dr=[[5],[0,3,3,2,0],[39],[0,2,1]]
for i,d in enumerate(dr):
    for j,v in enumerate(d): body+='MOVE %d TO WS-DRAW(%d)\n'%(v,j+1)
    body+='MOVE 1 TO WS-A\nCOMPUTE WS-FA = 2.0\nCOMPUTE WS-FB = 0.0\n'+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')+shw('n:WS-B')
    tick(s,1,2.0,0.0,d)
g.case('draw order (6.3 step 3): with open >= 0.5 only nextInt(40) is drawn first and the pairs only when it is 0 (draw counts 1, 5 with a repeat of an unchanged flipT, 1, 3)',body+shw('f:BE-XF(WS-IDX, 3)'),[],[1,5,1,3,s['flipT']])
body=EN+'MOVE 1.0 TO BE-XF(WS-IDX, 5)\nMOVE 1 TO BE-XF(WS-IDX, 9)\n'
s=st(); s['open']=1.0; s['tRot']=1.0
for i in range(12):
    body+='MOVE 0 TO WS-A\nCOMPUTE WS-FA = 0.0\nCOMPUTE WS-FB = 0.0\n'+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')
    tick(s,0,0.0,0.0,[])
g.case('player away (6.3 step 4, V24): tRot rises by 0.02 per tick and open falls by 0.1 per tick (a book opened to 1.0 is closed after 10 ticks and stays at 0); rot approaches tRot by 40 percent of the gap',body+shw('f:BE-XF(WS-IDX, 5)','f:BE-XF(WS-IDX, 9)','f:BE-XF(WS-IDX, 7)','n:BE-XI(WS-IDX, 1)'),[],[s['open'],s['tRot'],s['rot'],12])
body=''
exp=[]
for rot,trot in [(3.5,-3.0),(-3.0,3.0)]:
    s=st(); s['rot']=f32(rot); s['tRot']=f32(trot)
    body+=EN+'MOVE %s TO BE-XF(WS-IDX, 7)\nMOVE %s TO BE-XF(WS-IDX, 9)\n'%(rot,trot)
    body+='MOVE 0 TO WS-A\nCOMPUTE WS-FA = 0.0\nCOMPUTE WS-FB = 0.0\n'+call('BE4-ENCH-TICK','WS-IDX','WS-A','WS-FA','WS-FB','WS-DRAWS','WS-B')+shw('f:BE-XF(WS-IDX, 7)','f:BE-XF(WS-IDX, 9)','f:BE-XF(WS-IDX, 8)')
    tick(s,0,0.0,0.0,[])
    exp+=[s['rot'],s['tRot'],s['orot']]
g.case('angle normalising (6.3 steps 5 and 6): rot and tRot are kept in [-PI, PI) and the gap is normalised too, so a book turns the short way round (rot 3.5 to tRot -3.0 and rot -3.0 to tRot 3.0; rot, tRot and oRot shown)',body,[],exp)
g.case('name and key (6.2): the default name is container.enchant, a CustomName replaces it and is saved back (CustomName only when set)',EN+call('BE4-ENCH-NAME','WS-IDX','WS-N32','WS-A')+shw('t:WS-N32,WS-A')+nb_begin()+nb_s('CustomName','Arcane')+'PERFORM LOAD-BUFFER\n'+call('BE4-ENCH-NAME','WS-IDX','WS-N32','WS-A')+shw('t:WS-N32,WS-A')+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+EN+'MOVE 2 TO WS-FORM\n'+shw('SAVE'),[],['container.enchant Arcane {CustomName:Arcane} {}'])
W(g,6)
# ===== 7
BR=create(40,'suspicious_sand')
def cstate(c): return 0 if c==0 else 1 if c<3 else 2 if c<6 else 3
g=GG(7,'Brushable block','T0917','the brush rules with cooldown and reset, the decay, the completion drop position, the saved keys and the update tag.')
class Br:
    def __init__(s): s.cnt=0;s.reset=0;s.cool=0;s.hit=-1;s.dusted=0
    def brush(s,t,d):
        if s.hit<0: s.hit=d
        s.reset=t+40
        if t<s.cool: return (0,0,cstate(s.cnt),0)
        s.cool=t+10
        before=cstate(s.cnt); s.cnt+=1
        if s.cnt>=10: return (1,0,cstate(s.cnt),int(before!=cstate(s.cnt)))
        after=cstate(s.cnt)
        return (0,2,after,int(before!=after))
    def check(s,t):
        ch=0;nd=cstate(s.cnt)
        if s.cnt!=0 and t>=s.reset:
            b=cstate(s.cnt); s.cnt=max(0,s.cnt-2); a=cstate(s.cnt); ch=int(a!=b); s.reset=t+4
        if s.cnt==0: s.hit=-1;s.reset=0;s.cool=0;sched=0
        else: sched=2
        return (cstate(s.cnt),ch,sched)
b=Br(); body=BR; exp=[]
for t in (100,109,110,120,130,140,150,160,170,180,190):
    body+=mv(A=t,B=1)+call('BE4-BRUSH','WS-IDX','WS-A','WS-B','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-E','n:WS-F','n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)')
    r=b.brush(t,1); exp+=[r[0],r[1],r[2],r[3],b.cnt,b.reset]
g.case('brushing (7.4, V16, worked example 4): the second brush 9 ticks after the first is ignored by the cooldown but moves the reset time (T+49 shows as 149); a brush exactly 10 ticks later counts; counts 1 to 9 schedule a tick in 2 and change dusted at counts 1, 3 and 6; the tenth completes (completed 1; shown: completed, schedule, dusted, changed, count, reset time)',body,[],exp)
b=Br(); b.cnt=4; b.reset=100; b.hit=3
body=BR+'MOVE 4 TO BE-XI(WS-IDX, 1)\nMOVE 100 TO BE-XI(WS-IDX, 2)\nMOVE 3 TO BE-XI(WS-IDX, 4)\n'; exp=[]
for t in (99,100,104,108,112):
    body+=mv(A=t)+call('BE4-BRUSH-RESET','WS-IDX','WS-A','WS-E','WS-F','WS-G')+shw('n:WS-E','n:WS-F','n:WS-G','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 4)')
    r=b.check(t) if t>=0 else None
    exp+=[r[0],r[1],r[2],b.cnt,b.reset,b.hit]
g.case('checkReset (7.6, V18, worked example 3): the count of 4 is untouched until its reset time; then it loses 2 every 4 ticks (to 2 then 0, dusted 2 then 1 then 0); at 0 the hit direction and the timestamps clear and no tick is scheduled (dusted, changed, schedule, count, reset, hit shown)',body,[],exp)
body="";exp=[]
for c in range(0,11):
    body+=mv(A=c)+call('BE4-BRUSH-STATE','WS-A','WS-B')+shw('n:WS-B'); exp.append(cstate(c))
g.case('completionState (7.4): 0 for no brush, 1 below 3, 2 below 6, else 3 (counts 0 to 10)',body,[],exp)
body="";exp=[]
for (bx,by,bz,d) in [(0,64,0,1),(5,70,-2,2),(5,70,-2,-1),(1,1,1,0),(3,3,3,5)]:
    body+=mv(A=bx,B=by,C=bz,E=d)+call('BE4-BRUSH-DROP-POS','WS-A','WS-B','WS-C','WS-E','WS-FA','WS-FB','WS-FC')+shw('f:WS-FA','f:WS-FB','f:WS-FC')
    st_={0:(0,-1,0),1:(0,1,0),2:(0,0,-1),3:(0,0,1),4:(-1,0,0),5:(1,0,0)}[d if d>=0 else 1]
    px,py,pz=bx+st_[0],by+st_[1],bz+st_[2]
    exp+=[px+0.5*0.75+0.125,py+0.5+0.125,pz+0.5*0.75+0.125]
g.case('dropContent position (7.7): the centre of the neighbouring block on the hit face (UP when none) plus 0.625 high: x = pX + 0.5 * f + 0.125 with f = 0.75 and y = pY + 0.5 + h / 2',body,[],exp)
LB=nb_begin()+nb_s('LootTable','minecraft:archaeology/desert_pyramid')+nb_long('LootTableSeed',123)+nb_c('item')+nb_stack(2,1)+nb_e()+nb_i('hit_direction',3)
g.case('saved keys (7.2, V19): LootTable and a non-zero LootTableSeed are written, item only with no loot table (it is dropped when a LootTable is read), hit_direction is read but never saved',BR+LB+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE','n:BE-SLOT-COUNT(WS-IDX, 1)','n:BE-XI(WS-IDX, 4)'),[],['{LootTable:minecraft:archaeology/desert_pyramid,LootTableSeed:123} 0 3'])
LB2=nb_begin()+nb_c('item')+nb_stack(2,1)+nb_e()
g.case('item without a loot table (7.2): item loads and saves; hit_direction absent is none (-1)',BR+LB2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n'+shw('SAVE','n:BE-XI(WS-IDX, 4)'),[],['{item:{id:cobolcraft:greystone,count:1}} -1'])
def tagtext(hit,item):
    return '{'+','.join(([ 'hit_direction:%d'%hit] if hit>=0 else [])+(['item:{id:cobolcraft:greystone,count:1}'] if item else []))+'}'
TAG='MOVE 0 TO WS-A\nCALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nMOVE 0 TO WS-LEN\nMOVE SPACES TO WS-OUT\nCALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN\nCALL "PB-FREE" USING PB-BUFFER\nSTRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR\n'
body=BR+TAG+'MOVE 4 TO BE-XI(WS-IDX, 4)\n'+TAG+'MOVE 2 TO BE-SLOT-ITEM(WS-IDX, 1)\nMOVE 1 TO BE-SLOT-COUNT(WS-IDX, 1)\n'+TAG+'MOVE -1 TO BE-XI(WS-IDX, 4)\n'+TAG
g.case('update tag (7.3): hit_direction (the 3D data value, omitted when none) and the item when not empty; an empty entity sends an empty compound (V19)',body,[],'{} {hit_direction:4} {hit_direction:4,item:{id:cobolcraft:greystone,count:1}} {item:{id:cobolcraft:greystone,count:1}}')
W(g,7)
# ===== 8
BH=create(33,'beehive')
g=GG(8,'Beehive','T0919','the occupants, entering, the release rules and position, the honey step, the bee age and love time, the anger and the saved keys.')
body=BH
exp=[]
body+='MOVE 1 TO WS-A\nMOVE 0 TO WS-B\n'+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-A')
# params: idx nectar flowerset fx(fy,fz packed?) -> simplified: nectar, bee-has-flower, rnd, added, adopted
body=BH
steps=[(1,0,0),(0,1,0),(1,1,0),(0,1,1)]
for n,fl,r in steps:
    body+=mv(A=n,B=fl,C=r)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-E','n:WS-F','n:BE-XI(WS-IDX, 5)')
g.case('addOccupant (8.4, 8.1): a bee with nectar is stored with min_ticks_in_hive 2400, one without 600; the hive adopts the bee\'s flower when it has none, or on a true coin flip when it has one; the fourth bee is refused at 3 (added, adopted, count)',body+'MOVE 6 TO WS-A\n'+shw('n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 11)','n:BE-XI(WS-IDX, 8)','n:BE-XI(WS-IDX, 12)','n:BE-XI(WS-IDX, 1)'),[],[1,0,1, 1,1,2, 1,0,3, 0,0,3, 2400,600,1,0,1])
body=BH+mv(A=0,B=1,C=0)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')+mv(A=0,B=1,C=1)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')+'MOVE 0 TO WS-C\n'+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
g.case('flower adoption (8.4 step 4): the first bee gives its flower to a hive that has none; with one already the bee\'s flower is adopted only when nextBoolean is true (1, 1, 0)',body,[],[1,1,0])
body=BH+mv(A=1,B=0,C=0)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')
body+='PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2400\nCALL "BE4-HIVE-BEE-TICK" USING WS-IDX WS-A WS-B\nEND-PERFORM\n'+shw('n:WS-B','n:BE-XI(WS-IDX, 6)')
body+='MOVE 1 TO WS-A\n'+call('BE4-HIVE-BEE-TICK','WS-IDX','WS-A','WS-B')+shw('n:WS-B')+call('BE4-HIVE-BEE-TICK','WS-IDX','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 6)')
body+=BH+mv(A=0,B=0,C=0)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+'MOVE 1 TO WS-A\nPERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 600\nCALL "BE4-HIVE-BEE-TICK" USING WS-IDX WS-A WS-B\nEND-PERFORM\n'+shw('n:WS-B')+call('BE4-HIVE-BEE-TICK','WS-IDX','WS-A','WS-B')+shw('n:WS-B')
g.case('tick of a stored bee (8.3, 8.8, worked examples 1 and 2): the counter exceeds min_ticks_in_hive after 2401 ticks for a nectar bee (status 0 honey delivered) and after 601 for a bee without (status 1 released); before that -1; the counter keeps growing while the release is blocked',body,[],[-1,2400,0,0,2402,-1,1])
body=BH+mv(A=0,B=1,C=0)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+mv(A=1,B=0,C=0)+call('BE4-HIVE-ENTER','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F')+'MOVE 1 TO WS-A\n'+call('BE4-HIVE-REMOVE','WS-IDX','WS-A')+shw('n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 8)','n:BE-XI(WS-IDX, 7)')
g.case('removal (8.8): a released bee is removed and the later ones move up (the nectar bee is first afterwards: count 1, nectar 1, min 2400)',body,[],[1,1,2400])
body="";exp=[]
for stay,status,blocked in [(1,0,0),(1,1,0),(1,2,0),(0,0,0),(0,1,1),(0,2,1),(0,2,0),(1,2,1)]:
    body+=mv(A=stay,B=status,C=blocked)+call('BE4-HIVE-ALLOWED','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E')
    ok=1
    if stay and status!=2: ok=0
    if ok and blocked and status!=2: ok=0
    exp.append(ok)
g.case('release conditions (8.5 steps 1, 2, V20, V21): the daylight attribute bees_stay_in_hive and a blocked exit stop every release except EMERGENCY (2)',body,[],exp)
body="";exp=[]
for lv,r in [(4,0),(4,5),(0,0),(0,50),(3,0),(5,0)]:
    body+=mv(A=lv,B=r)+call('BE4-HIVE-HONEY','WS-A','WS-B','WS-C')+shw('n:WS-C')
    if lv>=5: exp.append(lv)
    else:
        inc=2 if r==0 else 1
        if lv+inc>5: inc-=1
        exp.append(lv+inc)
g.case('honey delivery (8.5 step 4b, worked example 1): the level rises by 1, by 2 on nextInt(100) = 0, reduced by one when it would pass 5; a full hive stays at 5',body,[],exp)
body="";exp=[]
for (fc,blocked,wd,hh,bx,by,bz) in [(2,0,0.4,0.3,0,64,0),(3,0,0.7,0.6,5,70,-2),(4,1,0.4,0.3,0,64,0),(5,0,0.4,0.5,1,1,1)]:
    body+=mv(A=fc,B=blocked,C=bx,E=by,F=bz)+fv(A=wd,B=hh)+call('BE4-HIVE-POS','WS-A','WS-B','WS-FA','WS-FB','WS-C','WS-E','WS-F','WS-FC','WS-FD','WS-FE')+shw('f:WS-FC','f:WS-FD','f:WS-FE')
    stx={2:0,3:0,4:-1,5:1}[fc];stz={2:-1,3:1,4:0,5:0}[fc]
    off=0 if blocked else 0.55+wd/2
    exp+=[bx+0.5+off*stx,by+0.5-hh/2,bz+0.5+off*stz]
g.case('release position (8.5 step 4d): the bee appears 0.55 + width / 2 out of the exit face (0 when the exit is blocked, at the hive\'s centre column), at y + 0.5 - height / 2',body,[],exp)
body="";exp=[]
for age,t in [(-100,40),(-10,40),(100,40),(10,40),(0,40)]:
    body+=mv(A=age,B=t)+call('BE4-HIVE-AGE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(min(0,age+t) if age<0 else max(0,age-t) if age>0 else 0)
for lv,t in [(100,40),(10,40),(0,5)]:
    body+=mv(A=lv,B=t)+call('BE4-HIVE-LOVE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(max(0,lv-t))
g.case('released bee (8.6): a baby (age below 0) grows by the ticks in the hive up to 0, an adult\'s breeding cool-down shrinks by them to 0, the love time shrinks to 0',body,[],exp)
body="";exp=[]
for d2,sed in [(16.0,0),(16.1,0),(4.0,1),(20.0,1),(0.0,0)]:
    body+=fv(A=d2)+mv(A=sed)+call('BE4-HIVE-ANGER','WS-FA','WS-A','WS-B')+shw('n:WS-B'); exp.append(0 if d2>16.0 else 2 if sed else 1)
for cnt,r in [(0,0.001),(2,0.001),(2,0.005),(2,0.0049999)]:
    body+=mv(A=cnt)+fv(A=r)+call('BE4-HIVE-WORK','WS-A','WS-FA','WS-B')+shw('n:WS-B'); exp.append(int(cnt>0 and r<0.005))
g.case('emptyAllLivingFromHive and the work sound (8.7, 8.8): a released bee within squared distance 16 of the player targets the player (1) unless the hive is sedated (2: 400-tick stay-out); further away nothing (0); the work sound plays when the hive holds bees and nextDouble < 0.005',body,[],exp)
IG=['Air','drop_chances','equipment','Brain','CanPickUpLoot','DeathTime','fall_distance','FallFlying','Fire','HurtTime','LeftHanded','Motion','NoGravity','OnGround','PortalCooldown','Pos','Rotation','sleeping_pos','CannotEnterHiveTicks','TicksSincePollination','CropsGrownSincePollination','hive_pos','Passengers','leash','UUID']
assert len(IG)==25
body="";exp=[]
for n in IG+['HasNectar','id','air','Health','']:
    body+='MOVE SPACES TO WS-N32\nMOVE "%s" TO WS-N32\nMOVE %d TO WS-A\n'%(n or ' ',len(n))+call('BE4-IGNORED-TAG','WS-N32','WS-A','WS-B')+shw('n:WS-B'); exp.append(int(n in IG))
g.case('ignored tags (8.3): the 25 names removed from a stored or released bee (case matters); HasNectar, id, a lower-case air, Health and the empty name are kept',body,[],exp)
LH=nb_begin()+nb_l('bees',10,2)+nb_c('entity_data')+nb_s('id','minecraft:bee')+nb_b('HasNectar',1)+nb_s('Brain','x')+nb_e()+nb_i('ticks_in_hive',500)+nb_i('min_ticks_in_hive',2400)+nb_i('extra',1)+nb_e()+nb_c('entity_data')+nb_s('id','minecraft:bee')+nb_e()+nb_i('ticks_in_hive',3)+nb_i('min_ticks_in_hive',600)+nb_e()+nb_intarr('flower_pos',[1,2,3])
g.case('save and load (8.3, worked example 5, V23): bees is always written (an empty list for none); a stored bee keeps id, HasNectar, ticks_in_hive and min_ticks_in_hive (the counter continues from 500) and none of the ignored tags; flower_pos only when set',BH+'MOVE 2 TO WS-FORM\n'+shw('SAVE')+LH+'PERFORM LOAD-BUFFER\n'+shw('SAVE','n:BE-XI(WS-IDX, 6)'),[],['{bees:[]} {bees:[{entity_data:{id:minecraft:bee,HasNectar:1},ticks_in_hive:500,min_ticks_in_hive:2400},{entity_data:{id:minecraft:bee},ticks_in_hive:3,min_ticks_in_hive:600}],flower_pos:I[1,2,3]} 500'])
W(g,8)
