import sys,struct,math
sys.path.insert(0,'core/tests/gen')
from gentest import *
f32=lambda x: struct.unpack('f',struct.pack('f',x))[0]
def stage(p): return int(f32(f32(f32(p)*10.0)))
def sc(x,n): return int(round(x*n))
# ---------------- section 10
g=Gen('TEST-BLOCKUPD-29-10','29§10','Breaking a block',
 'Test of 29 section 10, Breaking a block (core/src/blockupd-29-break.cob; T0473): the start, stop and abort digging decisions of 10.1 to 10.3, the per-tick progress of 10.2, destroyBlock of 10.4, the drop positions and checks of 10.5 and the non-player break of 10.6, with the worked example 13.5 and 13.6.')
g.run('the stage sent is (int)(progress * 10) in single precision',["0","0.15","0.5","0.99","1.0","0.3","0.7","0.04"],'CALL "BK-STAGE" USING WS-FX(1) WS-R(1)',1," ".join(str(stage(float(x))) for x in "0 0.15 0.5 0.99 1.0 0.3 0.7 0.04".split()))
S='CALL "BK-START" USING %s WS-FX(10) WS-R(1) WS-R(2) WS-R(3)'%I(*range(1,10))
g.run('START: out of range returns silently; above max y or a refused mayInteract or a restricted action re-sends the state (outcome 1); spawn protection only shows the message (2); creative is destroyAndAck (3); instant break (4); else digging starts (5) with the stage and a re-send of the previous position',
 ["0 64 319 0 1 0 0 0 0 0.04","1 320 319 0 1 0 0 0 0 0.04","1 64 319 1 1 0 0 0 0 0.04","1 64 319 0 0 0 0 0 0 0.04","1 64 319 0 1 1 0 0 0 0.04","1 64 319 0 1 0 1 0 0 0.04",
  "1 64 319 0 1 0 0 0 0 1.0","1 64 319 0 1 0 0 0 0 0.04","1 64 319 0 1 0 0 0 1 0.5","1 64 319 0 1 0 0 1 0 0.04","1 64 319 0 1 1 1 0 0 0.04","1 320 319 1 1 0 0 0 0 0.04"],S,3,
 "0/0/0 1/0/0 2/0/0 1/0/0 3/0/0 1/0/0 4/0/0 5/0/0 5/5/1 5/10/0 3/0/0 1/0/0")
g.run('an out-of-range packet aborts first only for ABORT while destroying',["1 1","1 0","0 1"],'CALL "BK-RANGE-ABORT" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0")
st=lambda p,t: int(f32(p)*0+0) 
def accepted(p,t): return f32(f32(p)*(t+1))>=0.7
g.run('STOP at 70 percent of the server progress is accepted (13.5: 17 ticks of 0.04 accept, 16 start a delayed destroy), not while a delay is pending, not for another position or air',
 ["1 17 0 0.04 0","1 16 0 0.04 0","1 16 0 0.04 1","0 17 0 0.04 0","1 17 1 0.04 0","1 6 0 0.1 0"],'CALL "BK-STOP" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-I(5) WS-R(1)',1,
 "1 2 0 0 0 %d"%(1 if accepted(0.1,6) else 2))
g.run('the per-tick step: a pending delayed destroy is cancelled over air, breaks at progress 1.0, otherwise waits; a destroying player over air stops; otherwise level event 2020 every fourth tick and 2019 else',
 ["1 1 0 0 0 0","1 0 1 0 0 0","1 0 0 0 0 0","0 0 0 1 1 0","0 0 0 1 0 4","0 0 0 1 0 5","0 0 0 1 0 0","0 0 0 0 0 0","1 0 0 1 0 4"],'CALL "BK-TICK" USING %s WS-R(1) WS-R(2)'%I(*range(1,7)),2,
 "1/0 2/0 3/0 4/0 5/2020 5/2019 5/2020 0/0 3/0")
def inc(p,t,last):
    pp=f32(f32(p)*(t+1)); s=int(f32(pp*10.0)); return s,(1 if s!=last else 0),int(round(pp*1000))
cs=[(0.04,0,-1),(0.04,1,0),(0.04,3,0),(0.04,24,0),(0.04,23,0)]
g.run('incrementDestroyProgress: progress is the per-tick value times ticks + 1; the stage is sent only when it differs from the last (13.5: 0, 0 not re-sent, 1, then 1.0 at tick 24)',
 ["%s %d %d"%(p,t,l) for p,t,l in cs],'CALL "BK-INCREMENT" USING WS-FX(1) WS-I(2) WS-I(3) WS-R(1) WS-R(2) WS-RF(1)\nCOMPUTE WS-R(3) ROUNDED = WS-RF(1) * 1000',3,
 " ".join("%d/%d/%d"%inc(*c) for c in cs))
g.run('abortDestroyBlock clears the flag first, warns and sends -1 for the stored position only on a mismatch, and always sends -1 for the given position',["1","0"],'CALL "BK-ABORT" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"1/0/0/1 1/1/1/1")
g.run('destroyAndAck re-sends the position when destroyBlock returned false',["1","0"],'CALL "BK-DESTROY-ACK" USING WS-I(1) WS-R(1)',1,"0 1")
g.run('canDestroyBlock: an item with a tool component that forbids it in creative fails for a creative player only',["0 0 1","1 0 1","1 0 0","1 1 1"],'CALL "BK-CAN-DESTROY" USING %s WS-R(1)'%I(1,2,3),1,"1 0 1 1")
D='CALL "BK-DESTROY" USING %s WS-R(1) WS-R(2) WS-R(3) WS-R(4) WS-R(5) WS-R(6) WS-R(7)'%I(*range(1,8))
g.run('destroyBlock: a refused item, a game-master block without rights (notifies clients), or a restricted action returns false; else the block is removed before tool damage and drops; creative stops after removal; playerDestroy needs removed and the correct tool',
 ["0 0 0 0 1 0 1","1 1 0 0 1 0 1","1 1 1 0 1 0 1","1 0 0 1 1 0 1","1 0 0 0 1 0 1","1 0 0 0 1 1 1","1 0 0 0 0 0 1","1 0 0 0 1 0 0"],D,7,
 "0/0/0/0/0/0/0 0/1/0/0/0/0/0 1/0/1/1/1/1/1 0/0/0/0/0/0/0 1/0/1/1/1/1/1 1/0/1/1/1/0/0 1/0/1/1/0/1/0 1/0/1/1/1/1/0")
g.run('Item.mineBlock damages the tool only for a tool item on a server level with a non-zero destroy time and damage per block above 0',["1 1 1 1","0 1 1 1","1 0 1 1","1 1 0 1","1 1 1 0"],'CALL "BK-MINE-BLOCK" USING %s WS-R(1)'%I(1,2,3,4),1,"1 0 0 0 0")
g.run('nextDouble(min, max) is min when min >= max, else the draw times the range plus min',["0.5 -0.25 0.25","0 -0.25 0.25","0.75 0 0.1","0.9 0.3 0.3","0.9 0.5 0.3"],
 'CALL "BK-NEXT-DOUBLE" USING WS-FX(1) WS-FX(2) WS-FX(3) WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000',1,"0 -250 75 300 500")
g.run('popResource: the position is the block centre plus three draws in [-0.25, 0.25], y lowered by half the item height (13.6)',["10 64 -3 0.25 0.5 0.0 1.0"],
 'CALL "BK-POP-POS" USING WS-I(1) WS-I(2) WS-I(3) WS-FX(4) WS-FX(5) WS-FX(6) WS-FX(7) WS-RF(1) WS-RF(2) WS-RF(3)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(3) * 1000',3,"10500/64125/-2250")
PF='CALL "BK-POP-FACE" USING WS-I(7) WS-I(8) WS-I(9) WS-I(10) WS-I(11) WS-I(12) WS-FX(13) WS-FX(14) WS-FXSG WS-RFSG WS-R(7)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000\nCOMPUTE WS-R(2) ROUNDED = WS-RF(2) * 1000\nCOMPUTE WS-R(3) ROUNDED = WS-RF(3) * 1000\nCOMPUTE WS-R(4) ROUNDED = WS-RF(4) * 1000\nCOMPUTE WS-R(5) ROUNDED = WS-RF(5) * 1000\nCOMPUTE WS-R(6) ROUNDED = WS-RF(6) * 1000'
g.run('popResourceFromFace: only axes with step 0 draw (four draws for one non-zero step), the others use step times (0.5 + half width) and step times 0.1 (+ 0.1 for y)',
 ["0.5 0.5 0.5 0.5 0 0 0 0 0 0 1 0 0.25 0.25","0.0 1.0 0.5 0.5 0 0 0 0 0 1 0 0 0.25 0.25"],PF,7,"500/1000/500/0/200/0/4 1125/125/750/100/50/0/4")
g.run('an item entity is created only on a server level, for a non-empty stack, with block_drops true (the random draws happen anyway)',["1 0 1","0 0 1","1 1 1","1 0 0"],'CALL "BK-POP-CHECKS" USING %s WS-R(1)'%I(1,2,3),1,"1 0 0 0")
g.run('popExperience does nothing when block_drops is false or the amount is not positive',["1 5","0 5","1 0"],'CALL "BK-XP" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0")
g.case('non-player breaking calls no playerWillDestroy, damages no tool, honours no creative rules and drops with an empty tool',[("0",'CALL "BK-NONPLAYER" USING WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4)],"0/0/0/1")
g.case('playerDestroy adds food exhaustion 0.005',[("0",'CALL "BK-EXHAUSTION" USING WS-RF(1)\nCOMPUTE WS-R(1) ROUNDED = WS-RF(1) * 1000000',1)],"5000")
g.write('core/tests/test_blockupd_29_10.cob')
# ---------------- section 11
g=Gen('TEST-BLOCKUPD-29-11','29§11','Game mode and permission rules in one table',
 'Test of 29 section 11, Game mode and permission rules in one table (core/src/blockupd-29-break.cob; T0475): the rows of the table per game mode, blockActionRestricted and mayUseItemAt.')
g.run('abilities per mode: survival and creative may build, only creative has infinite materials',["0","1","2","3"],'CALL "GM-MODE" USING WS-I(1) WS-R(1) WS-R(2)',2,"1/0 1/1 0/0 0/0")
g.run('the table row per mode: digging, drops and tool damage, placing consumes the item, useItemOn',["0","1","2","3"],'CALL "GM-RULES" USING WS-I(1) WS-R(1) WS-R(2) WS-R(3) WS-R(4)',4,"0/1/1/0 1/0/0/0 2/1/1/1 3/0/0/2")
g.run('blockActionRestricted: false for survival and creative, true in spectator, in adventure true when the main hand is empty or can_break does not match',["0 1 0","1 1 0","3 0 1","2 1 1","2 0 0","2 0 1"],'CALL "GM-RESTRICTED" USING WS-I(1) WS-I(2) WS-I(3) WS-R(1)',1,"0 0 1 1 1 0")
g.run('mayUseItemAt is true when mayBuild, else the stack can_place_on must match',["1 0","0 1","0 0"],'CALL "GM-MAY-USE-AT" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 1 0")
g.write('core/tests/test_blockupd_29_11.cob')
# ---------------- section 12
g=Gen('TEST-BLOCKUPD-29-12','29§12','Block entities and block changes',
 'Test of 29 section 12, Block entities and block changes (core/src/blockupd-29-break.cob; T0477): creation, lazy creation, keeping across a state change, removal and the tickers of 12.')
g.run('adding an entity registers it in the chunk; the level is told only when the chunk is in the level, a listener only when it listens, and the ticker is refreshed',["1 1","0 0"],'CALL "BN-ADD" USING WS-I(1) WS-I(2) WS-R(1) WS-R(2) WS-R(3)',3,"1/1/1 0/0/1")
g.run('a state change keeps the entity by default only when the block type is unchanged; the per-block hook overrides (-1 means default)',["1 -1","0 -1","0 1","1 0"],'CALL "BN-KEEP" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 1 0")
g.run('removing an entity runs preRemoveSideEffects first only on a server level without flag 256',["0 1","1 1","0 0"],'CALL "BN-REMOVE" USING WS-I(1) WS-I(2) WS-R(1)',1,"1 0 0")
g.run('getBlockEntity: a stored entity is returned, a stored removed one is dropped (null), else a pending saved tag is promoted, else IMMEDIATE creates one, else null',
 ["1 0 0 0","1 1 1 1","0 0 1 0","0 0 1 1","0 0 0 1","0 0 0 0"],'CALL "BN-LAZY" USING %s WS-R(1)'%I(1,2,3,4),1,"1 0 2 2 3 0")
g.run('a ticker is stored when the state gives a tick function, else removed; new tickers go to the pending list while tickers run',["1","0"],'CALL "BN-TICKER-UPDATE" USING WS-I(1) WS-R(1)',1,"1 0")
g.run('addBlockEntityTicker appends to the pending list while tickers are being run, otherwise to the active list',["1","0"],'CALL "BN-TICKER-LIST" USING WS-I(1) WS-R(1)',1,"1 0")
g.run('a ticker is removed when marked removed; otherwise it runs when the tick rate allows, the chunk ticks blocks, the position is in the border and (server) the chunk is block-ticking with entities loaded',
 ["1 1 1 1 1 1 1","0 1 1 1 1 1 1","0 0 1 1 1 1 1","0 1 0 1 1 1 1","0 1 1 0 1 1 1","0 1 1 1 0 1 1","0 1 1 1 1 0 1","0 1 1 1 1 1 0","0 1 1 1 0 0 0"],'CALL "BN-TICKER-RUN" USING %s WS-R(1)'%I(*range(1,8)),1,"1 2 0 0 0 2 0 0 2")
g.run('block entities tick only while the level has been idle for fewer than 300 ticks',["0","299","300","301"],'CALL "BN-LEVEL-TICK" USING WS-I(1) WS-R(1)',1,"1 1 0 0")
g.write('core/tests/test_blockupd_29_12.cob')
