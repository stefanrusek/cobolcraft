from genbex import *
ONLY=only()
# Independent Python models of docs/protocol/31-block-entities-6-command-structure-jigsaw-test.md (T0933 to T0954; core/src/be-31-6.cob, BE6- programs).
def GG(n,subj,tasks,desc): return mk(None,n,subj,tasks,desc,6)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_6_%d.cob'%n)
CB='cr23'
def CBE(): return cr(23,'command_block')
def SBE(): return cr(21,'structure_block')
def JGE(): return cr(31,'jigsaw')
def TBE(): return cr(45,'test_block')
def TIE(): return cr(46,'test_instance_block')
def begin(): return nb_begin()
def load(): return 'PERFORM LOAD-BUFFER\n'
SAVE2=render(2)
# ===== 1
g=GG(1,'Types, blocks and state at a glance','T0933','types, valid blocks, update tags and the automatic flag of the three command blocks.')
body="";exp=[]
for t,k,op,kind,pk in [(23,'command_block',1,0,0),(21,'structure_block',0,1,1),(31,'jigsaw',0,1,1),(45,'test_block',0,1,1),(46,'test_instance_block',0,1,1)]:
    body+='MOVE %d TO WS-A\n'%t+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+call('BE-SYNC-INFO','WS-A','WS-C','WS-E')+shw('t:WS-N24,WS-LEN','n:WS-B','n:WS-C','n:WS-E'); exp+=[k,op,kind,pk]
g.case('types (1): keys by registry id (command_block 23, structure_block 21, jigsaw 31, test_block 45, test_instance_block 46), operator-only (command block only), update tag kind (1 custom only, 0 empty for the command block) and the Block Entity Data packet (none for the command block)',body,[],exp)
body="";exp=[]
for t,b,r in [(23,'command_block',1),(23,'chain_command_block',1),(23,'repeating_command_block',1),(23,'structure_block',0),(21,'structure_block',1),(21,'command_block',0),(31,'jigsaw',1),(45,'test_block',1),(46,'test_instance_block',1),(45,'test_instance_block',0),(31,'structure_block',0)]:
    body+='MOVE %d TO WS-A\n'%t+key('minecraft:'+b)+call('BE-VALID-BLOCK','WS-A','WS-N48','WS-SVL','WS-B')+shw('n:WS-B'); exp.append(r)
g.case('valid blocks (1): the command block type takes the three command blocks, every other type exactly the block of its name',body,[],exp)
body="";exp=[]
for b,a in [('command_block',0),('repeating_command_block',0),('chain_command_block',1),('stone',0)]:
    body+=key('minecraft:'+b)+call('BE6-AUTOMATIC','WS-N48','WS-SVL','WS-A')+shw('n:WS-A'); exp.append(a)
g.case('automatic flag (1.1): command_block false, repeating_command_block false, chain_command_block true',body,[],exp)
W(g,1)
# ===== 2
g=GG(2,'The command block entity','T0935','state, saved keys in write order, lenient load, mode of the block.')
g.case('fresh entity saves the keys of 12.1 in order (Command empty here; no CustomName, LastOutput, LastExecution), defaults trackOutput 1 and updateLastExecution 1, lastExecution -1',CBE()+SAVE2+shw('SAVE','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 7)','n:BE-SEED(WS-IDX)'),[],['{Command:,SuccessCount:0,TrackOutput:1,UpdateLastExecution:1,powered:0,conditionMet:0,auto:0} 1 1 -1'])
L=begin()+nb_s('Command','say hi')+nb_i('SuccessCount',3)+nb_s('CustomName','Boss')+nb_b('TrackOutput',1)+nb_s('LastOutput','[14:03:07]hi')+nb_b('UpdateLastExecution',1)+nb_long('LastExecution',99)+nb_b('powered',1)+nb_b('conditionMet',1)+nb_b('auto',1)
g.case('round trip (2.2, 2.3): every key loads and saves back in the order Command, SuccessCount, CustomName, TrackOutput, LastOutput, UpdateLastExecution, LastExecution, powered, conditionMet, auto',CBE()+L+load()+SAVE2+shw('SAVE','n:BE-SEED(WS-IDX)','n:BE-XI(WS-IDX, 6)'),[],['{Command:say hi,SuccessCount:3,CustomName:Boss,TrackOutput:1,LastOutput:[14:03:07]hi,UpdateLastExecution:1,LastExecution:99,powered:1,conditionMet:1,auto:1} 99 12'])
L=begin()+nb_s('Command','x')+nb_b('TrackOutput',0)+nb_s('LastOutput','gone')+nb_b('UpdateLastExecution',0)+nb_long('LastExecution',5)
g.case('load rules (2.3, validation 2): with TrackOutput false LastOutput is dropped, with UpdateLastExecution false LastExecution is -1; neither is written',CBE()+L+load()+SAVE2+shw('SAVE','n:BE-SEED(WS-IDX)','n:BE-XI(WS-IDX, 6)'),[],['{Command:x,SuccessCount:0,TrackOutput:0,UpdateLastExecution:0,powered:0,conditionMet:0,auto:0} -1 0'])
L=begin()+nb_s('LastOutput','late')+nb_b('TrackOutput',0)+nb_long('LastExecution',5)+nb_b('UpdateLastExecution',0)
g.case('load rules (2.3): the dropping does not depend on the order of the keys',CBE()+L+load()+shw('n:BE-XI(WS-IDX, 6)','n:BE-SEED(WS-IDX)'),[],[0,-1])
body=CBE()+begin()+'MOVE ALL "a" TO WS-OUT\nMOVE "Command" TO WS-NM\nMOVE 7 TO WS-NML\nMOVE 300 TO WS-SVL\nCALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-OUT WS-SVL\n'+load()+SAVE2
g.case('load (2.3): a command longer than the 256 bytes kept is cut',body+shw('n:BE-CMD-LENGTH(WS-IDX)'),[],[256])
g.case('load (2.3): an empty compound gives the defaults (Command empty, count 0, track and update true, no last execution, not powered, no condition, not auto); a key of the wrong tag type is ignored',CBE()+'MOVE 4 TO BE-XI(WS-IDX, 4)\n'+begin()+nb_i('Command',5)+load()+shw('n:BE-CMD-LENGTH(WS-IDX)','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 7)','n:BE-SEED(WS-IDX)'),[],[0,0,1,1,-1])
g.case('LastExecution of the current game time is written when updateLastExecution is set and the value is not -1',CBE()+'MOVE 77 TO BE-SEED(WS-IDX)\n'+SAVE2+shw('SAVE'),[],['{Command:,SuccessCount:0,TrackOutput:1,UpdateLastExecution:1,LastExecution:77,powered:0,conditionMet:0,auto:0}'])
body="";exp=[]
for b,m in [('command_block',2),('repeating_command_block',1),('chain_command_block',0),('stone',2)]:
    body+=key('minecraft:'+b)+call('BE6-MODE','WS-N48','WS-SVL','WS-A')+shw('n:WS-A'); exp.append(m)
g.case('mode (2.4): command_block REDSTONE 2, repeating AUTO 1, chain SEQUENCE 0 (the order of the packet), any other block REDSTONE',body,[],exp)
body="";exp=[]
for lv,blk,prop in [(1,1,1),(1,1,0),(0,1,1),(1,0,1)]:
    body+=mv(A=lv,B=blk,C=prop)+call('BE6-IS-CONDITIONAL','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-E'); exp.append(int(lv and blk and prop))
g.case('isConditional (2.4): false without a level or when the block is not a command block, else the property (level, block is command block, property in)',body,[],exp)
W(g,2)
# ===== 3
g=GG(3,'When a command block runs','T0937','markConditionMet, setAutomatic, power edges, the scheduled tick, the chain walk, the comparator and performCommand.')
body="";exp=[]
for cond,behind in [(0,-1),(0,5),(1,3),(1,0),(1,-1),(1,1)]:
    body+=CBE()+mv(A=cond,B=behind)+call('BE6-MARK-CONDITION','WS-IDX','WS-A','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 2)')
    r=1 if not cond else int(behind>0); exp+=[r,r]
g.case('markConditionMet (3.2): a non-conditional block is always met; a conditional one is met only when the block behind is a command block with successCount > 0 (-1 = no command block there); the result is stored in conditionMet (conditional, behind count in; met, stored out)',body,[],exp)
def setauto(old,new,powered,lv,mode): return int(old==0 and new==1 and powered==0 and lv and mode!=0)
body="";exp=[]
for old,new,pw,lv,m in [(0,1,0,1,1),(0,1,0,1,2),(0,1,0,1,0),(1,1,0,1,1),(0,1,1,1,1),(0,1,0,0,1),(1,0,0,1,1)]:
    body+=CBE()+mv(A=old)+'MOVE WS-A TO BE-XI(WS-IDX, 3)\nMOVE %d TO BE-XI(WS-IDX, 1)\n'%pw+mv(B=new,C=lv,E=m)+call('BE6-SET-AUTOMATIC','WS-IDX','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F','n:BE-XI(WS-IDX, 3)')
    exp+=[setauto(old,new,pw,lv,m),new]
g.case('setAutomatic (3.3): a tick is scheduled only when auto turns from false to true while not powered, with a level and a mode other than SEQUENCE (old auto, powered, new, has level, mode in; schedule, stored out)',body,[],exp)
body="";exp=[]
for m,pw,au,lv in [(1,1,0,1),(1,0,1,1),(1,0,0,1),(1,1,0,0),(2,1,1,1),(0,1,1,1)]:
    body+=CBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\n'%(pw,au)+mv(A=m,B=lv)+call('BE6-MODE-SWITCH','WS-IDX','WS-A','WS-B','WS-C')+shw('n:WS-C')
    exp.append(int(m==1 and (pw or au) and lv))
g.case('onModeSwitch (3.3): a tick is scheduled when the new mode is AUTO and the block is powered or automatic and has a level',body,[],exp)
body="";exp=[]
for old,new,m,au in [(0,1,1,0),(0,1,2,0),(0,1,0,0),(0,1,1,1),(1,1,1,0),(1,0,1,0),(0,0,1,0)]:
    body+=CBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\n'%(old,au)+mv(A=new,B=m)+call('BE6-SET-POWERED','WS-IDX','WS-A','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 1)')
    s=int(new==1 and old!=new and not au and m!=0); exp+=[s,new]
g.case('setPoweredAndUpdate (3.4): only a rising edge schedules, and not for an automatic block or a chain block; a power-off stores and schedules nothing; an equal value does nothing (old powered, new, mode, auto)',body,[],exp)
def placed(hasdata,fb,bauto,sig,m):
    track=1; au=0; sched=0
    if not hasdata:
        track=fb; sched=setauto(0,bauto,0,1,m); au=bauto
    if sig==1 and not (au or m==0): sched=1
    return sched,track,au
body="";exp=[]
for hd,fb,ba,sig,m in [(0,0,1,0,1),(0,1,0,1,1),(0,1,1,0,0),(1,0,1,0,1),(1,0,0,1,2),(0,0,0,0,2)]:
    body+=CBE()+mv(A=hd,B=fb,C=ba,E=sig,F=m)+call('BE6-PLACED','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-G','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 3)')
    s,t,a=placed(hd,fb,ba,sig,m); exp+=[s,t,a]
g.case('placement (3.4): without block_entity_data trackOutput takes send_command_feedback and the block automatic flag is applied through setAutomatic; with it neither; the neighbour signal then goes through setPoweredAndUpdate (has data, feedback, block flag, signal, mode in; schedule, track, auto out)',body,[],exp)
def tick(prev,cond,hascmd,newmet,m,pw,au):
    xi4=7; ex=0; pf=0; rs=0; xi2=prev
    if m==1:
        xi2=newmet
        if prev:
            ex=1
            if hascmd: pf=1
            else: xi4=0
        elif cond: xi4=0
        rs=int(pw or au)
    elif m==2:
        if prev:
            ex=1
            if hascmd: pf=1
            else: xi4=0
        elif cond: xi4=0
    return ex,pf,rs,xi4,xi2
body="";exp=[]
for m in (1,2,0):
    for prev,cond,hc,nm,pw,au in [(1,0,1,1,1,0),(1,0,0,1,0,1),(0,1,1,1,0,0),(0,0,1,0,0,0),(1,1,1,0,0,0)]:
        body+=CBE()+'MOVE 7 TO BE-XI(WS-IDX, 4)\nMOVE %d TO BE-XI(WS-IDX, 2)\nMOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\n'%(prev,pw,au)+mv(A=m,B=cond,C=hc,E=nm)+call('BE6-TICK','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-F','n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 2)')
        exp+=list(tick(prev,cond,hc,nm,m,pw,au))
g.case('scheduled tick (3.5, 3.6): AUTO recomputes the flag and runs on the previous one, repeats while powered or automatic; REDSTONE runs on the previous flag and never repeats; SEQUENCE does nothing; a block that does not run and is conditional gets successCount 0; execute without a command gives successCount 0 (mode, previous flag, conditional, has command, new flag in; execute, perform, reschedule, successCount, flag out)',body,[],exp)
def chain(ischain,iscbe,m,active,cond,met,ok):
    if not ischain or not iscbe or m!=0: return 0
    if active:
        if met: return 1 if ok else 2
        return 4 if cond else 3
    return 3
body="";exp=[]
for ic,ie,m,ac,cond,met,ok in [(0,0,0,1,0,1,1),(1,0,0,1,0,1,1),(1,1,1,1,0,1,1),(1,1,0,1,0,1,1),(1,1,0,1,0,1,0),(1,1,0,1,1,0,1),(1,1,0,1,0,0,1),(1,1,0,0,0,1,1)]:
    body+=CBE()+'MOVE 6 TO BE-XI(WS-IDX, 4)\n'+mv(A=ic,B=ie,C=m,E=ac,F=cond,G=met,H=ok)+call('BE6-CHAIN-BLOCK','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-P','n:BE-XI(WS-IDX, 4)')
    a=chain(ic,ie,m,ac,cond,met,ok); exp+=[a,0 if a==4 else 6]
g.case('chain step (3.7 steps 2 and 3): leave the walk when the block is not a chain command block entity in mode SEQUENCE; run when powered or automatic and met (leave when the run returns false); a conditional block that is not met gets successCount 0; a block neither powered nor automatic is skipped but the walk goes on (action 0 leave, 1 ran, 2 ran and failed, 3 skipped, 4 not met)',body,[],exp)
body="";exp=[]
for rule in (1,2,3):
    rem=rule; body+='MOVE %d TO WS-A\n'%rule
    rem=rule; steps=[]
    # layout: one chain block B (active), then air
    seq=[]
    for it in (1,2):
        ent=1 if rem>0 else 0
        if ent: rem-=1
        body+=call('BE6-CHAIN-LIMIT','WS-A','WS-B')+shw('n:WS-B')
        exp.append(ent)
        if not ent: break
        if it==2: break
    # air step then check
    body+='MOVE %d TO WS-P\n'%rule+call('BE6-CHAIN-WARN','WS-A','WS-P','WS-C','WS-E')+shw('n:WS-C','n:WS-E')
    exp+=[1 if rem<=0 else 0, max(rule,0)]
g.case('chain counter (3.7 worked example): with max_command_sequence_length 1 the counter is spent after block B so the warning is logged; with 2 it is spent when the step finds air, so the warning is logged too; with 3 it is not (two limit checks, then the warning: enter, enter, warn, value)',body,[],exp)
g.case('chain limit (3.7): the counter is tested before it is decremented; at 0 or below the loop is not entered; a negative rule logs the warning with 0',
  mv(A=0,P=0)+call('BE6-CHAIN-LIMIT','WS-A','WS-B')+shw('n:WS-B','n:WS-A')+call('BE6-CHAIN-WARN','WS-A','WS-P','WS-C','WS-E')+shw('n:WS-C','n:WS-E')+mv(A=-5,P=-5)+call('BE6-CHAIN-WARN','WS-A','WS-P','WS-C','WS-E')+shw('n:WS-C','n:WS-E'),[],[0,0,1,0,1,0])
body="";exp=[]
for c in (12,0,20):
    body+=CBE()+'MOVE %d TO BE-XI(WS-IDX, 4)\nMOVE 1 TO WS-A\n'%c+call('BE6-COMPARATOR','WS-A','WS-IDX','WS-B')+shw('n:WS-B'); exp.append(c)
body+='MOVE 0 TO WS-A\n'+call('BE6-COMPARATOR','WS-A','WS-IDX','WS-B')+shw('n:WS-B'); exp.append(0)
g.case('comparator output (3.8): the raw successCount (not clamped to 15 here), 0 when the entity is not a command block entity',body,[],exp)
def perform(t,last,work,cb,cmd,upd=1,track=1):
    kind=0 if cmd=='' else 2 if cmd.lower()=='searge' else 1
    count=5; lo=0; ret=1; run=0; le=last
    if t==last: return 0,0,count,lo,le
    if kind==2: return 1,0,1,len('#itzlipofutzli'),last
    count=0
    if work and kind==1:
        lo=0; run=1; count+=cb
    le=t if upd else -1
    return ret,run,count,lo,le
body="";exp=[]
CASES=[(5,-1,1,2,'say hi',1),(5,5,1,2,'say hi',1),(6,5,1,2,'SearGe',1),(7,5,0,2,'say hi',1),(7,5,1,2,'',1),(8,5,1,1,'say hi',0)]
for t,last,work,cb,cmd,upd in CASES:
    body+=CBE()+'MOVE %d TO BE-SEED(WS-IDX)\nMOVE 5 TO BE-XI(WS-IDX, 4)\nMOVE %d TO BE-XI(WS-IDX, 7)\n'%(last,upd)+txtv('WS-T256',cmd)+'MOVE %d TO WS-LEN\n'%len(cmd)+call('BE6-SET-COMMAND','WS-IDX','WS-T256','WS-LEN')+'MOVE 5 TO BE-XI(WS-IDX, 4)\nMOVE %d TO WS-LONG1\n'%t+mv(A=work,B=cb)+call('BE6-PERFORM','WS-IDX','WS-LONG1','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-C','n:WS-E','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 6)','n:BE-SEED(WS-IDX)')
    r,run,count,lo,le=perform(t,last,work,cb,cmd,upd); exp+=[r,run,count,lo,le]
g.case('performCommand (3.9): a second run in the same game tick returns false and does nothing; Searge (any case) sets lastOutput to #itzlipofutzli, successCount 1 and keeps lastExecution; otherwise successCount is 0 plus the callbacks, the command runs only when command_blocks_work holds and the command is not empty, lastExecution is the time or -1 without updateLastExecution (time, last, work, callbacks; result, run, count, lastOutput length, lastExecution)',body,[],exp)
g.case('setCommand (3.9): stores the command and resets successCount to 0',CBE()+'MOVE 9 TO BE-XI(WS-IDX, 4)\n'+txtv('WS-T256','say hi')+'MOVE 6 TO WS-LEN\n'+call('BE6-SET-COMMAND','WS-IDX','WS-T256','WS-LEN')+shw('n:BE-XI(WS-IDX, 4)','n:BE-CMD-LENGTH(WS-IDX)','t:BE-CMD(WS-IDX)|BE-CMD-LENGTH(WS-IDX)'),[],[0,6,'say hi'])
W(g,3)
# ===== 4
g=GG(4,'The command source of a command block','T0939','yaw table, source position, permission level, name and the output capture.')
YAW={0:270,1:270,2:180,3:0,4:90,5:270}
body="";exp=[]
for f in range(6):
    body+='MOVE %d TO WS-A\n'%f+call('BE6-YAW','WS-A','WS-B')+shw('n:WS-B'); exp.append(YAW[f])
g.case('yaw (4.1): south 0, west 90, north 180, east 270, up and down 270 (directions 0 down, 1 up, 2 north, 3 south, 4 west, 5 east)',body,[],exp)
body=CBE()+'MOVE 4 TO WS-A\n'+call('BE6-SOURCE','WS-IDX','WS-A','WS-FA','WS-FB','WS-FC','WS-B','WS-C','WS-T64','WS-LEN')+shw('f:WS-FA','f:WS-FB','f:WS-FC','n:WS-B','n:WS-C','t:WS-T64,WS-LEN')
body+='MOVE "Boss" TO BE-NAME(WS-IDX)\nMOVE 4 TO BE-NAME-LENGTH(WS-IDX)\nMOVE 2 TO WS-A\n'+call('BE6-SOURCE','WS-IDX','WS-A','WS-FA','WS-FB','WS-FC','WS-B','WS-C','WS-T64','WS-LEN')+shw('n:WS-B','t:WS-T64,WS-LEN')
g.case('source (4.1): the block centre (x + 0.5, y + 0.5, z + 0.5), yaw from the facing, permission level 2, the name @ or the custom name (facing west: yaw 90; then north with the name Boss: yaw 180)',body,[],[5.5,70.5,5.5,90,2,'@',180,'Boss'])
body="";exp=[]
for cl in (0,1):
  for fb in (0,1):
    for out in (0,1):
      for q in (1,2,3):
        body+=mv(A=cl,B=fb,C=out,E=q)+call('BE6-CAPTURE','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F')
        exp.append(int((not cl) and {1:fb,2:1,3:out}[q]))
g.case('output capture (4.2): acceptsSuccess is not closed and send_command_feedback, acceptsFailure is not closed, shouldInformAdmins is not closed and command_block_output (closed, feedback, output, query 1 success 2 failure 3 admins in)',body,[],exp)
body=CBE()+txtv('WS-N48','hi')+'MOVE 0 TO WS-A\nMOVE 14 TO WS-B\nMOVE 3 TO WS-C\nMOVE 7 TO WS-E\nMOVE 2 TO WS-LEN\n'+call('BE6-MESSAGE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-N48','WS-LEN')+shw('t:BE-XT(WS-IDX, 1)|BE-XI(WS-IDX, 6)')
body+=txtv('WS-N48','later')+'MOVE 9 TO WS-B\nMOVE 5 TO WS-C\nMOVE 0 TO WS-E\nMOVE 5 TO WS-LEN\n'+call('BE6-MESSAGE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-N48','WS-LEN')+shw('t:BE-XT(WS-IDX, 1)|BE-XI(WS-IDX, 6)')
body+='MOVE 1 TO WS-A\n'+txtv('WS-N48','ignored')+'MOVE 7 TO WS-LEN\n'+call('BE6-MESSAGE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-N48','WS-LEN')+shw('t:BE-XT(WS-IDX, 1)|BE-XI(WS-IDX, 6)')
g.case('sendSystemMessage (4.2): lastOutput is [HH:mm:ss] immediately followed by the text (no space), each message replaces the last, a closed capture ignores messages (closed, hour 14, minute 3, second 7 in)',body,[],['[14:03:07]hi','[09:05:00]later','[09:05:00]later'])
W(g,4)
# ===== 5
g=GG(5,'Command block packets and sync','T0941','Set Command Block handler, the block for a mode, what clients receive.')
def setcb(can,work,oldm,m,flags,cmd):
    if not can: return (1,0,1,0,0,1)  # msg, sched, track(unchanged 1), cmdlen..., 
def model5(can,work,oldm,m,flags,cmd):
    if not can: return dict(msg=1,sched=0,upd=0,track=1,lo=1,auto=0,cl=0)
    track=flags&1; au=(flags>>2)&1
    s1=setauto(0,au,0,1,m); s2=int(m!=oldm and m==1 and (au) )
    return dict(msg=(2 if work else 3) if cmd else 0,sched=int(s1 or s2),upd=int(work),track=track,lo=1 if track else 0,auto=au,cl=len(cmd))
body="";exp=[]
for can,work,oldm,m,flags,cmd in [(0,1,1,1,1,'x'),(1,1,1,1,5,'say hi'),(1,0,2,1,1,''),(1,1,2,2,0,'give'),(1,1,0,2,6,'a'),(1,1,2,1,0,'b')]:
    body+=CBE()+'MOVE 1 TO BE-XI(WS-IDX, 6)\nMOVE "x" TO BE-XT(WS-IDX, 1)\nMOVE 4 TO BE-XI(WS-IDX, 4)\n'+txtv('WS-T256',cmd)+'MOVE %d TO WS-LEN\n'%len(cmd)+mv(A=can,B=work,C=oldm,E=m,F=flags)+call('BE6-SET-CB-PACKET','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-F','WS-T256','WS-LEN','WS-G','WS-H','WS-P')+shw('n:WS-G','n:WS-H','n:WS-P','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 6)','n:BE-XI(WS-IDX, 3)','n:BE-CMD-LENGTH(WS-IDX)','n:BE-XI(WS-IDX, 4)')
    r=model5(can,work,oldm,m,flags,cmd)
    exp+=[r['msg'],r['sched'],r['upd'],r['track'],r['lo'],r['auto'],r['cl'] if can else 0,0 if can else 4]
g.case('Set Command Block (5.1): without the game master rights only advMode.notAllowed (message 1) and nothing changes; otherwise the command is set (successCount 0), trackOutput comes from flag 1 and a false value drops lastOutput, automatic from flag 4 (side effect of 3.3), a changed mode runs onModeSwitch, the update is sent when command_blocks_work holds, and a non-empty command answers advMode.setCommand.success (2) or .disabled (3) (can use, work, old mode, mode, flags in; message, schedule, update sent, track, lastOutput length, auto, command length, successCount out)',body,[],exp)
body="";exp=[]
for m,k in [(0,'minecraft:chain_command_block'),(1,'minecraft:repeating_command_block'),(2,'minecraft:command_block')]:
    body+='MOVE %d TO WS-A\n'%m+call('BE6-BLOCK-FOR-MODE','WS-A','WS-N48','WS-LEN')+shw('t:WS-N48,WS-LEN'); exp.append(k)
g.case('block of a mode (5.1 step 3): SEQUENCE chain_command_block, AUTO repeating_command_block, REDSTONE command_block',body,[],exp)
body="";exp=[]
for c,e in [(1,1),(1,0),(0,1),(0,0)]:
    body+=mv(A=c,B=e)+call('BE6-OPEN-USE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(c and e)
g.case('what clients receive (5.2): the data packet is sent (SUCCESS) only when a game master uses a command block entity, otherwise PASS and nothing (can use, is command block entity in; result)',body,[],exp)
W(g,5)
# ===== 6
g=GG(6,'The structure block entity','T0943','keys, enum strings, power edges, scan, placement rules, the Set Structure Block handler.')
DEF='{name:,author:,metadata:,posX:0,posY:1,posZ:0,sizeX:0,sizeY:0,sizeZ:0,rotation:NONE,mirror:NONE,mode:LOAD,ignoreEntities:1,strict:0,powered:0,showair:0,showboundingbox:1,integrity:1.000,seed:0}'
g.case('new entity (6.1): the 19 keys in order with the defaults (offset 0, 1, 0, size 0, NONE, NONE, mode LOAD from the block, ignoreEntities true, showboundingbox true, integrity 1.0, seed 0)',SBE()+SAVE2+shw('SAVE'),[],[DEF])
L=begin()+nb_s('name','demo:house')+nb_s('author','Ann')+nb_s('metadata','m1')+nb_i('posX',-3)+nb_i('posY',2)+nb_i('posZ',9)+nb_i('sizeX',4)+nb_i('sizeY',5)+nb_i('sizeZ',6)+nb_s('rotation','CLOCKWISE_90')+nb_s('mirror','FRONT_BACK')+nb_s('mode','CORNER')+nb_b('ignoreEntities',0)+nb_b('strict',1)+nb_b('powered',1)+nb_b('showair',1)+nb_b('showboundingbox',0)+nb_float('integrity','0.5')+nb_long('seed',123456789012)
g.case('round trip (6.1): every key loads and saves back unchanged in the same order',SBE()+L+load()+SAVE2+shw('SAVE','n:BE-XI(WS-IDX, 9)','n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 8)'),[],['{name:demo:house,author:Ann,metadata:m1,posX:-3,posY:2,posZ:9,sizeX:4,sizeY:5,sizeZ:6,rotation:CLOCKWISE_90,mirror:FRONT_BACK,mode:CORNER,ignoreEntities:0,strict:1,powered:1,showair:1,showboundingbox:0,integrity:0.500,seed:123456789012} 2 1 2'])
g.case('load defaults (6.1): an empty compound gives mode DATA (not the block default load), offset 0 1 0, size 0, integrity 1, ignoreEntities and showboundingbox true',SBE()+begin()+load()+SAVE2+shw('SAVE'),[],[DEF.replace('mode:LOAD','mode:DATA')])
L=begin()+nb_i('posX',99)+nb_i('posY',-99)+nb_i('posZ',48)+nb_i('sizeX',60)+nb_i('sizeY',-5)+nb_i('sizeZ',48)+nb_float('integrity','5.0')+nb_s('rotation','clockwise_90')+nb_s('mirror','LEFT_RIGHT')+nb_s('mode','save')
g.case('load clamps and legacy enums (6.1, 6.1.1): offsets clamp to -48..48, sizes to 0..48, integrity is not clamped; lower-case names do not decode (rotation NONE, mode DATA); an exact upper-case name does (mirror LEFT_RIGHT)',SBE()+L+load()+SAVE2+shw('SAVE'),[],['{name:,author:,metadata:,posX:48,posY:-48,posZ:48,sizeX:48,sizeY:0,sizeZ:48,rotation:NONE,mirror:LEFT_RIGHT,mode:DATA,ignoreEntities:1,strict:0,powered:0,showair:0,showboundingbox:1,integrity:5.000,seed:0}'])
body="";exp=[]
for nm,r in [('demo:house','demo:house'),('house','minecraft:house'),('Bad Name',''),('',''),('a:b/c','a:b/c')]:
    body+=SBE()+begin()+(nb_s('name',nm))+load()+shw('t:BE-XT(WS-IDX, 1)|BE-XI(WS-IDX, 20)') if r else SBE()+begin()+nb_s('name',nm)+load()+shw('n:BE-XI(WS-IDX, 20)')
    exp.append(r if r else 0)
g.case('structure name (6.1): an identifier is kept, a name without a namespace gets minecraft:, an unparsable or empty text is none',body,[],exp)
body="";exp=[]
for k in (1,2,3,4,5,6,7):
    for i in range({1:4,2:3,3:4,4:4,5:3,6:4,7:2}[k]):
        body+=mv(A=k,B=i)+call('BE6-ENUM-NAME','WS-A','WS-B','WS-T64','WS-LEN')+call('BE6-ENUM-ID','WS-A','WS-T64','WS-LEN','WS-C')+shw('t:WS-T64,WS-LEN','n:WS-C')
        nm={1:['NONE','CLOCKWISE_90','CLOCKWISE_180','COUNTERCLOCKWISE_90'],2:['NONE','LEFT_RIGHT','FRONT_BACK'],3:['SAVE','LOAD','CORNER','DATA'],4:['none','clockwise_90','180','counterclockwise_90'],5:['cleared','running','finished'],6:['start','log','fail','accept'],7:['rollable','aligned']}[k][i]
        exp+=[nm,i]
body+=txtv('WS-T64','Clockwise_90')+'MOVE 12 TO WS-LEN\nMOVE 1 TO WS-A\n'+call('BE6-ENUM-ID','WS-A','WS-T64','WS-LEN','WS-C')+shw('n:WS-C'); exp.append(-1)
g.case('enum strings (6.1.1, 9.1, 10.1, 8.1): kind 1 rotation, 2 mirror, 3 structure mode (upper-case constant names), 4 test instance rotation, 5 status, 6 test block mode, 7 joint (lower-case serialized names); a name round-trips to its index and a different case does not decode (-1)',body,[],exp)
body="";exp=[]
for m in (0,1,2,3):
    for sig,old in [(1,0),(1,1),(0,1),(0,0)]:
        body+=SBE()+'MOVE %d TO BE-XI(WS-IDX, 12)\n'%old+mv(A=sig,B=m)+call('BE6-POWER','WS-IDX','WS-A','WS-B','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 12)')
        tr=0; po=old
        if sig and not old: po=1; tr=m+1 if m<3 else 0
        elif not sig and old: po=0
        exp+=[tr,po]
g.case('power edge (6.2): a rising signal on an unpowered block sets powered and triggers by mode (1 save without writing the file, 2 place, 3 unload, 0 nothing for DATA); a falling signal clears powered; no change otherwise (mode, signal, old powered in; trigger, powered out)',body,[],exp)
def scan(S,name_eq,corners,mode=0):
    if mode!=0: return None
    pts=list(corners)
    if len(pts)==0: return None
    if len(pts)==1: pts=pts+[S]
    mn=[min(p[i] for p in pts) for i in range(3)]; mx=[max(p[i] for p in pts) for i in range(3)]
    if not all(mx[i]-mn[i]>1 for i in range(3)): return None
    return (mn[0]-S[0]+1,mn[1]-S[1]+1,mn[2]-S[2]+1,mx[0]-mn[0]-1,mx[1]-mn[1]-1,mx[2]-mn[2]-1)
body="";exp=[]
S=(12,64,8)
for corners,mode in [([(10,64,10),(20,70,25)],0),([(10,64,10)],0),([(20,70,25)],0),([],0),([(10,64,10),(20,70,25)],1),([(10,64,10),(20,70,25),(9,60,5)],0)]:
    body+=cr(21,'structure_block',*S)+'MOVE %d TO BE-XI(WS-IDX, 9)\n'%mode+''.join('MOVE %d TO WS-TV(%d)\n'%(v,i*3+j+1) for i,c in enumerate(corners) for j,v in enumerate(c))+'MOVE %d TO WS-A\n'%len(corners)+call('BE6-SCAN','WS-IDX','WS-TAB','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 6)')
    r=scan(S,1,corners,mode)
    exp+=([1]+list(r)) if r else [0,0,1,0,0,0,0]
g.case('corner scan (6.6, example 12.4): two corners give the box of the corners, one corner the box with this block, none or a span of 1 or less on an axis fails, only in mode SAVE; success sets the offset (min - block + 1) and size (max - min - 1) (corner table, count in; success, offset, size out)',body,[],exp)
body="";exp=[]
for m_s,m_o,n_s,n_o in [(2,2,'demo:a','demo:a'),(2,2,'demo:a','demo:b'),(2,2,'',''),(2,3,'demo:a','demo:a'),(2,2,'demo:a','')]:
    body+=SBE()+'MOVE WS-IDX TO WS-Q\n'+'MOVE %d TO BE-XI(WS-IDX, 9)\n'%m_s+(('MOVE "%s" TO BE-XT(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 20)\n'%(n_s,len(n_s))) if n_s else '')+SBE()+'MOVE %d TO BE-XI(WS-IDX, 9)\n'%m_o+(('MOVE "%s" TO BE-XT(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 20)\n'%(n_o,len(n_o))) if n_o else '')+call('BE6-SCAN-MATCH','WS-Q','WS-IDX','WS-A')+shw('n:WS-A')
    exp.append(int(m_o==2 and n_s==n_o))
g.case('scan candidates (6.6 step 2): another structure block counts when it is in mode CORNER and its name equals this one (both none counts as equal)',body,[],exp)
body="";exp=[]
for found,lm,nm,tsz,sz in [(1,1,'demo:a',(3,2,4),(3,2,4)),(1,1,'demo:a',(3,2,5),(3,2,4)),(0,1,'demo:a',(3,2,4),(3,2,4)),(1,0,'demo:a',(3,2,4),(3,2,4)),(1,1,'',(3,2,4),(3,2,4))]:
    body+=SBE()+'MOVE %d TO BE-XI(WS-IDX, 9)\n'%lm+(('MOVE "%s" TO BE-XT(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 20)\n'%(nm,len(nm))) if nm else '')+''.join('MOVE %d TO BE-XI(WS-IDX, %d)\n'%(v,4+i) for i,v in enumerate(sz))+txtv('WS-T64','Tpl')+mv(A=found,B=tsz[0],C=tsz[1],E=tsz[2])+'MOVE 3 TO WS-LEN\n'+call('BE6-SAME-SIZE','WS-IDX','WS-A','WS-B','WS-C','WS-E','WS-T64','WS-LEN','WS-F')+shw('n:WS-F','n:BE-XI(WS-IDX, 6)','n:BE-XI(WS-IDX, 21)')
    ok=found and lm==1 and nm
    if not ok: exp+=[0,sz[2],0]
    elif tsz==sz: exp+=[1,sz[2],3]
    else: exp+=[0,tsz[2],3]
g.case('placeStructureIfSameSize (6.4): needs mode LOAD, a name and a template; equal sizes place (true, with loadStructureInfo adopting the author), different sizes adopt the template size and author and return false (found, template size in; result, size z, author length out)',body,[],exp)
body="";exp=[]
for st in (0,1):
    body+=mv(A=st)+call('BE6-PLACE-FLAGS','WS-A','WS-B')+shw('n:WS-B'); exp.append(818 if st else 2)
for it,dr in [(1.0,0.5),(0.5,0.5),(0.5,0.75),(0.25,0.0),(2.0,0.99),(-1.0,0.0),(-1.0,0.5)]:
    body+='COMPUTE WS-FS1 = %s\nCOMPUTE WS-FS2 = %s\n'%(it,dr)+call('BE6-INTEGRITY','WS-FS1','WS-FS2','WS-A')+shw('n:WS-A'); exp.append(int(dr<=min(1,max(0,it))))
g.case('placement flags (6.4, validation 15): 2, or 818 when strict; integrity processor: a block is kept when its draw is <= the integrity clamped to 0..1 (integrity, draw in)',body,[],exp)
def mth(x,y,z):
    M=(1<<64)-1
    a=(x*3129871)&0xFFFFFFFF
    if a>=1<<31: a=a|(M^0xFFFFFFFF)
    l=(a^((z*116129781)&M)^(y&M))&M
    s=l-(1<<64) if l>>63 else l
    t=(s*s*42317861+s*11)&M
    s=t-(1<<64) if t>>63 else t
    return s>>16
body="";exp=[]
for x,y,z in [(0,0,0),(1,2,3),(-5,64,7),(100000,-3,-77777),(2147483647,319,-2147483648)]:
    body+=mv(A=x,B=y,C=z)+call('XORO-GET-SEED','WS-A','WS-B','WS-C','WS-LONG1')+shw('n:FUNCTION MOD(WS-LONG1, 1000000007)','n:FUNCTION INTEGER(WS-LONG1 / 4294967296)'); exp+=[mth(x,y,z)%1000000007,mth(x,y,z)//4294967296]
g.case('Mth.getSeed(pos) (6.4, the seed of the position-derived random source): l = (int)(x * 3129871) XOR z * 116129781 XOR y, then l * l * 42317861 + l * 11 with 64-bit wrap, shifted right by 16 (existing XORO-GET-SEED; shown as the value modulo 1000000007 and as its upper half)',body,[],exp)
def sbp(can,ut,loadable,placed,saveok,scanok,name):
    if not can: return 0,0
    if not name: return 8,1
    return ({0:0,1:1 if saveok else 2,2:3 if not loadable else (4 if placed else 5),3:6 if scanok else 7}[ut]),1
body="";exp=[]
for can,ut,ld,pl,sv,sc,name in [(0,1,1,1,1,1,'demo:a'),(1,0,1,1,1,1,'demo:a'),(1,1,1,1,1,1,'demo:a'),(1,1,1,1,0,1,'demo:a'),(1,2,0,1,1,1,'demo:a'),(1,2,1,1,1,1,'demo:a'),(1,2,1,0,1,1,'demo:a'),(1,3,1,1,1,1,'demo:a'),(1,3,1,1,1,0,'demo:a'),(1,1,1,1,1,1,'')]:
    body+=SBE()+'MOVE WS-IDX TO WS-Q\nMOVE 3 TO BE-XI(WS-Q, 9)\n'+(('MOVE "%s" TO BE-XT(WS-Q, 1)\nMOVE %d TO BE-XI(WS-Q, 20)\n'%(name,len(name))) if name else '')+'MOVE 2 TO BE-XI(WS-Q, 1)\nMOVE 7 TO BE-XI(WS-Q, 4)\nMOVE 9 TO BE-XI(WS-Q, 12)\nMOVE "pk" TO BE-XT(WS-Q, 2)\nMOVE 2 TO BE-XI(WS-Q, 21)\n'+SBE()+'MOVE "old" TO BE-XT(WS-IDX, 2)\nMOVE 3 TO BE-XI(WS-IDX, 21)\n'+mv(A=can,B=ut,C=ld,E=pl,F=sv,G=sc)+call('BE6-SB-PACKET','WS-IDX','WS-Q','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-H','n:WS-P','n:BE-XI(WS-IDX, 9)','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 12)','n:BE-XI(WS-IDX, 21)')
    m,ch=sbp(can,ut,ld,pl,sv,sc,name)
    exp+=[m,ch]+([3,2,7,0,3] if can else [1,0,0,0,3])
g.case('Set Structure Block (6.7): ignored silently without the rights; otherwise mode, name, offset, size and the other fields are copied (not author, not powered), then by update type: data nothing, save success or failure, load not found, load success or prepare, size success or failure; no name gives invalid_structure_name; the block is always updated (can use, update type 0 data 1 save 2 load 3 scan, loadable, placed, save ok, scan ok in; message code 0 none 1 save_success 2 save_failure 3 load_not_found 4 load_success 5 load_prepare 6 size_success 7 size_failure 8 invalid_structure_name, update sent out)',body,[],exp)
W(g,6)
# ===== 7
g=GG(7,'Bounding boxes and the client renderer','T0945','render modes, the renderable box for all mirror and rotation combinations, the draw conditions and the markers.')
body="";exp=[]
for m,air,box,r in [(2,1,1,0),(3,0,0,0),(0,1,0,2),(0,0,1,1),(0,0,0,1),(1,0,1,1),(1,1,0,0)]:
    body+=SBE()+'MOVE %d TO BE-XI(WS-IDX, 9)\nMOVE %d TO BE-XI(WS-IDX, 13)\nMOVE %d TO BE-XI(WS-IDX, 14)\n'%(m,air,box)+call('BE6-RENDER-MODE','WS-IDX','WS-A')+shw('n:WS-A'); exp.append(r)
g.case('structure block render mode (7.2): CORNER and DATA none; SAVE a box, with the invisible blocks when showAir; LOAD a box only with showBoundingBox (0 NONE, 1 BOX, 2 BOX_AND_INVISIBLE_BLOCKS)',body,[],exp)
def box(o,sz,mirror,rot):
    ox,oy,oz=o; sx,sy,sz_=sz
    x=ox;z=oz;y1=oy;y2=oy+sy
    dx,dz={0:(sx,sz_),1:(sx,-sz_),2:(-sx,sz_)}[mirror]
    if rot==0: x1=x+1 if dx<0 else x; z1=z+1 if dz<0 else z; x2=x1+dx; z2=z1+dz
    elif rot==1: x1=x if dz<0 else x+1; z1=z+1 if dx<0 else z; x2=x1-dz; z2=z1+dx
    elif rot==2: x1=x if dx<0 else x+1; z1=z if dz<0 else z+1; x2=x1-dx; z2=z1-dz
    else: x1=x+1 if dz<0 else x; z1=z if dx<0 else z+1; x2=x1+dz; z2=z1-dx
    return [min(x1,x2),min(y1,y2),min(z1,z2),abs(x2-x1),abs(y2-y1),abs(z2-z1)]
body="";exp=[]
for mir in (0,1,2):
    for rot in (0,1,2,3):
        body+=SBE()+'MOVE 1 TO BE-XI(WS-IDX, 1)\nMOVE 1 TO BE-XI(WS-IDX, 2)\nMOVE 0 TO BE-XI(WS-IDX, 3)\nMOVE 3 TO BE-XI(WS-IDX, 4)\nMOVE 2 TO BE-XI(WS-IDX, 5)\nMOVE 4 TO BE-XI(WS-IDX, 6)\nMOVE %d TO BE-XI(WS-IDX, 7)\nMOVE %d TO BE-XI(WS-IDX, 8)\n'%(rot,mir)+call('BE6-BOX','WS-IDX','WS-TAB')+shw(*['n:WS-TV(%d)'%i for i in range(1,7)])
        exp+=box((1,1,0),(3,2,4),mir,rot)
body+=SBE()+'MOVE -5 TO BE-XI(WS-IDX, 1)\nMOVE 4 TO BE-XI(WS-IDX, 2)\nMOVE 2 TO BE-XI(WS-IDX, 3)\nMOVE 0 TO BE-XI(WS-IDX, 4)\nMOVE 7 TO BE-XI(WS-IDX, 5)\nMOVE 1 TO BE-XI(WS-IDX, 6)\nMOVE 3 TO BE-XI(WS-IDX, 7)\nMOVE 2 TO BE-XI(WS-IDX, 8)\n'+call('BE6-BOX','WS-IDX','WS-TAB')+shw(*['n:WS-TV(%d)'%i for i in range(1,7)])
exp+=box((-5,4,2),(0,7,1),2,3)
g.case('renderable box (7.3, example 12.5): offset (1, 1, 0), size (3, 2, 4) for all 12 combinations of mirror (NONE, LEFT_RIGHT, FRONT_BACK) and rotation (NONE, 90, 180, -90) as local position and size; plus a flat box with a negative offset (local x y z, size x y z out)',body,[],exp)
body="";exp=[]
for c in [(1,2,3,4,0,6),(5,5,5,1,1,1),(0,0,0,-3,4,-5),(-2,3,1,2,3,1)]:
    body+=mv(A=c[0],B=c[1],C=c[2],E=c[3],F=c[4],G=c[5])+call('BE6-FROM-CORNERS','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-TAB')+shw(*['n:WS-TV(%d)'%i for i in range(1,7)])
    exp+=[min(c[0],c[3]),min(c[1],c[4]),min(c[2],c[5]),abs(c[3]-c[0]),abs(c[4]-c[1]),abs(c[5]-c[2])]
g.case('fromCorners (7.1): the local position is the minimum per axis and the size the absolute difference',body,[],exp)
body="";exp=[]
for al,m,s in [(1,1,(1,1,1)),(0,1,(1,1,1)),(1,0,(1,1,1)),(1,2,(0,1,1)),(1,2,(1,0,1)),(1,2,(1,1,0)),(1,1,(4,2,3))]:
    body+=mv(A=al,B=m,C=s[0],E=s[1],F=s[2])+call('BE6-RENDER-DRAW','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G')+shw('n:WS-G'); exp.append(int(al and m and min(s)>=1))
g.case('renderer (7.4): draws only for a game master or spectator, not for mode NONE, and only when the size is at least 1 on every axis (allowed, mode, size in)',body,[],exp)
M={0:(1,40,60,1000,500,500,1000),1:(1,45,55,1000,1000,750,750),2:(1,45,55,1000,1000,0,0),3:(1,45,55,1000,1000,1000,0),4:(0,0,0,0,0,0,0)}
body="";exp=[]
for k in range(5):
    body+='MOVE %d TO WS-A\n'%k+call('BE6-MARKER','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-B','n:WS-C','n:WS-E','n:WS-F','n:WS-G','n:WS-H','n:WS-P'); exp+=[M[k][0],M[k][1],M[k][2],M[k][3],M[k][4],M[k][5],M[k][6]]
g.case('invisible block markers (7.4): air, structure void, barrier and light are marked, others not; a marker spans 0.45 to 0.55 around the centre, 0.40 to 0.60 for air; colours alpha, red, green, blue in thousandths (air 1 .5 .5 1, void 1 1 .75 .75, barrier 0xFFFF0000, light 0xFFFFFF00) (kind 0 air 1 void 2 barrier 3 light 4 other in; marked, low, high in hundredths, then the four colour parts out)',body,[],exp)
W(g,7)
# ===== 8
g=GG(8,'The jigsaw block entity','T0947','keys and defaults, the joint default from the front, canAttach, placement top, the Set Jigsaw handler.')
JD='{name:minecraft:empty,target:minecraft:empty,pool:minecraft:empty,final_state:minecraft:air,joint:rollable,placement_priority:0,selection_priority:0}'
g.case('new entity (8.1): all seven keys are written in order with the defaults minecraft:empty (name, target, pool), minecraft:air, rollable, 0, 0',JGE()+SAVE2+shw('SAVE'),[],[JD])
L=begin()+nb_s('name','a:start')+nb_s('target','a:end')+nb_s('pool','a:pool/x')+nb_s('final_state','minecraft:stone')+nb_s('joint','aligned')+nb_i('placement_priority',3)+nb_i('selection_priority',-2)
g.case('round trip (8.1): every key loads and saves back in order',JGE()+L+load()+SAVE2+shw('SAVE'),[],['{name:a:start,target:a:end,pool:a:pool/x,final_state:minecraft:stone,joint:aligned,placement_priority:3,selection_priority:-2}'])
body="";exp=[]
for front,j in [(5,'aligned'),(1,'rollable'),(0,'rollable'),(2,'aligned')]:
    body+=JGE()+'MOVE %d TO BE-STATUS(WS-IDX)\n'%front+begin()+nb_s('name','a:b')+load()+SAVE2+shw('SAVE'); exp.append('{name:a:b,target:minecraft:empty,pool:minecraft:empty,final_state:minecraft:air,joint:%s,placement_priority:0,selection_priority:0}'%j)
body+=JGE()+'MOVE 1 TO BE-STATUS(WS-IDX)\n'+begin()+nb_s('joint','bogus')+nb_s('pool','Bad Pool')+load()+SAVE2+shw('SAVE'); exp.append('{name:minecraft:empty,target:minecraft:empty,pool:minecraft:empty,final_state:minecraft:air,joint:rollable,placement_priority:0,selection_priority:0}')
g.case('joint default (8.1, example 12.7): a missing or invalid joint is aligned when the front direction is horizontal (5 east, 2 north) and rollable when vertical (the front is BE-STATUS, set from the block); an invalid pool identifier gives minecraft:empty',body,[],exp)
OPP=lambda d: d+1 if d%2==0 else d-1
def attach(fa,fb,ja,ta,tb,tgt_ok):
    return int(fa==OPP(fb) and (ja==0 or ta==tb) and tgt_ok)
body="";exp=[]
for fa,fb,ja,ta,tb,nm in [(5,4,0,0,1,'ok'),(5,5,0,0,0,'ok'),(5,4,1,2,2,'ok'),(5,4,1,2,3,'ok'),(5,4,0,2,3,'ok'),(5,4,0,2,3,'bad'),(5,4,0,2,3,'null'),(0,1,1,2,2,'ok')]:
    body+=JGE()+'MOVE WS-IDX TO WS-Q\nMOVE "t:x" TO BE-XT(WS-Q, 2)\nMOVE 3 TO BE-XI(WS-Q, 2)\nMOVE %d TO BE-XI(WS-Q, 5)\n'%ja+JGE()+'MOVE %s TO BE-XT(WS-IDX, 1)\nMOVE 3 TO BE-XI(WS-IDX, 1)\n'%('"t:x"' if nm!='bad' else '"t:y"')+mv(A=fa,B=ta,C=fb,E=tb,F=(WS_IDX if False else 0))+call('BE6-CAN-ATTACH','WS-Q','WS-IDX' if nm!='null' else 'WS-F','WS-A','WS-B','WS-C','WS-E','WS-G')+shw('n:WS-G')
    exp.append(attach(fa,fb,ja,ta,tb,nm=='ok' or nm=='null'))
g.case('canAttach (8.1): the front of a is the opposite of the front of b, and a is rollable or the tops are equal, and b has no name or the target of a equals the name of b (index 0 for b means no name) (front a, top a, front b, top b in)',body,[],exp)
body="";exp=[]
for face,pdir in [(1,2),(0,5),(2,3),(5,3),(3,4)]:
    body+=mv(A=face,B=pdir)+call('BE6-JIGSAW-TOP','WS-A','WS-B','WS-C')+shw('n:WS-C')
    exp.append(OPP(pdir) if face in (0,1) else 1)
g.case('placement (8.2): the top is the opposite of the placer horizontal direction when the clicked face is vertical, else up (clicked face, placer direction in)',body,[],exp)
body="";exp=[]
for d,v in [(0,(0,-1,0)),(1,(0,1,0)),(2,(0,0,-1)),(3,(0,0,1)),(4,(-1,0,0)),(5,(1,0,0))]:
    body+='MOVE %d TO WS-A\n'%d+call('BE6-DIR-STEP','WS-A','WS-B','WS-C','WS-E')+shw('n:WS-B','n:WS-C','n:WS-E'); exp+=list(v)
g.case('direction step (8.2 generate start = position + front; 3.2 the block behind): the unit vector of directions 0 down 1 up 2 north 3 south 4 west 5 east',body,[],exp)
body="";exp=[]
for can in (0,1):
    body+=JGE()+'MOVE WS-IDX TO WS-Q\nMOVE "n:p" TO BE-XT(WS-Q, 1)\nMOVE 3 TO BE-XI(WS-Q, 1)\nMOVE "n:q" TO BE-XT(WS-Q, 2)\nMOVE 3 TO BE-XI(WS-Q, 2)\nMOVE "n:r" TO BE-XT(WS-Q, 3)\nMOVE 3 TO BE-XI(WS-Q, 3)\nMOVE "n:s" TO BE-XT(WS-Q, 4)\nMOVE 3 TO BE-XI(WS-Q, 4)\nMOVE 1 TO BE-XI(WS-Q, 5)\nMOVE 4 TO BE-XI(WS-Q, 6)\nMOVE 5 TO BE-XI(WS-Q, 7)\n'+JGE()+mv(A=can)+call('BE6-JIGSAW-SET','WS-IDX','WS-Q','WS-A','WS-B')+shw('n:WS-B','SAVE')
    exp+=[can,JD if not can else '{name:n:p,target:n:q,pool:n:r,final_state:n:s,joint:aligned,placement_priority:4,selection_priority:5}']
body=body.replace('PERFORM SAVE-RENDER','MOVE 2 TO WS-FORM\n     PERFORM SAVE-RENDER')
g.case('Set Jigsaw Block (8.2): ignored silently without the rights; otherwise name, target, pool, final state, joint and both priorities are copied and the block is updated (can use in; changed out)',body,[],exp)
W(g,8)
# ===== 9
g=GG(9,'The test block entity','T0949','keys, mode defaults, trigger, reset, redstone handling, output signal and the Set Test Block handler.')
g.case('new entity (9.1): mode start, empty message, not powered; saves mode, message, powered',TBE()+SAVE2+shw('SAVE'),[],['{mode:start,message:,powered:0}'])
g.case('round trip (9.1): mode log, message and powered load and save back; the transient triggered is not saved',TBE()+begin()+nb_s('mode','log')+nb_s('message','hello')+nb_b('powered',1)+load()+'MOVE 1 TO BE-XI(WS-IDX, 4)\n'+SAVE2+shw('SAVE'),[],['{mode:log,message:hello,powered:1}'])
g.case('load defaults (9.1): a missing or invalid mode gives fail',TBE()+begin()+load()+SAVE2+shw('SAVE')+TBE()+begin()+nb_s('mode','Start')+load()+shw('SAVE'),[],['{mode:fail,message:,powered:0} {mode:fail,message:,powered:0}'])
body="";exp=[]
for m,lv in [(0,1),(0,0),(1,1),(2,1),(3,1)]:
    body+=TBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE "hi" TO BE-XT(WS-IDX, 1)\nMOVE 2 TO BE-XI(WS-IDX, 2)\n'%m+mv(A=lv)+call('BE6-TB-TRIGGER','WS-IDX','WS-A','WS-B','WS-C')+shw('n:WS-B','n:WS-C','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 4)')
    start=m==0 and lv
    exp+=[int(start or m==1),int(bool(start)),int(bool(start)),0 if start else 1]
g.case('trigger (9.2, validation 17): in mode start with a level power the block, update the neighbours and log, leaving triggered false; in log mode log and set triggered; in fail or accept only set triggered; without a level mode start sets triggered (mode, has level in; log, neighbours updated, powered, triggered out)',body,[],exp)
body="";exp=[]
for m,lv,pw,tr in [(0,1,1,1),(0,0,1,1),(1,1,1,1),(2,1,0,0)]:
    body+=TBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\nMOVE %d TO BE-XI(WS-IDX, 4)\n'%(m,pw,tr)+mv(A=lv)+call('BE6-TB-RESET','WS-IDX','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 3)','n:BE-XI(WS-IDX, 4)')
    ch=m==0 and lv
    exp+=[int(bool(ch)),0 if ch else pw,0]
g.case('reset (9.2): clears triggered; in mode start with a level it also clears powered and updates the neighbours',body,[],exp)
body="";exp=[]
for m,sig,pw in [(0,1,0),(0,1,1),(0,0,1),(0,0,0),(1,1,0)]:
    body+=TBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\n'%(m,pw)+mv(A=sig)+call('BE6-TB-NEIGHBOUR','WS-IDX','WS-A','WS-B')+shw('n:WS-B','n:BE-XI(WS-IDX, 3)')
    if m!=0: exp+=[0,pw]
    elif sig and not pw: exp+=[1,1]
    elif not sig and pw: exp+=[0,0]
    else: exp+=[0,pw]
g.case('neighbourChanged (9.2): only in mode start a rising signal powers and triggers, a falling one unpowers (signal, powered in; trigger, powered out)',body,[],exp)
body="";exp=[]
for m,pw in [(0,1),(0,0),(1,1)]:
    body+=TBE()+'MOVE %d TO BE-XI(WS-IDX, 1)\nMOVE %d TO BE-XI(WS-IDX, 3)\n'%(m,pw)+call('BE6-TB-SIGNAL','WS-IDX','WS-A')+shw('n:WS-A'); exp.append(15 if m==0 and pw else 0)
for msg,res in [('',0),('   ',0),('x',1)]:
    body+=TBE()+txtv('WS-T64',msg)+'MOVE %d TO BE-XI(WS-IDX, 2)\nMOVE WS-T64 TO BE-XT(WS-IDX, 1)\n'%len(msg)+call('BE6-TB-LOG','WS-IDX','WS-A')+shw('n:WS-A'); exp.append(res)
g.case('output signal and log (9.2): 15 while powered in mode start, else 0; log() writes a line only when the message is not blank',body,[],exp)
body="";exp=[]
for can in (0,1):
    body+=TBE()+txtv('WS-T64','m1')+mv(A=can,B=2)+'MOVE 2 TO WS-LEN\n'+call('BE6-TB-SET','WS-IDX','WS-A','WS-B','WS-T64','WS-LEN','WS-C')+shw('n:WS-C','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 2)'); exp+=[can,2 if can else 0,2 if can else 0]
g.case('Set Test Block (9.2): ignored without the rights; otherwise setMode (the block property is rewritten) and the message are stored and the block is updated',body,[],exp)
W(g,9)
# ===== 10
g=GG(10,'The test instance block entity','T0951','keys, data transitions, geometry, beam colours and the action handler.')
TD='{data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}}'
g.case('new entity (10.1): data with no test, size 0 0 0, rotation none, ignore_entities false, status cleared; errors is not written when empty',TIE()+SAVE2+shw('SAVE'),[],[TD])
D=nb_c('data')+nb_s('test','minecraft:foo')+nb_intarr('size',[5,3,7])+nb_s('rotation','clockwise_90')+nb_b('ignore_entities',1)+nb_s('status','finished')+nb_s('error_message','boom')+nb_e()
L=begin()+D+nb_l('errors',10,2)+nb_intarr('pos',[1,2,3])+nb_s('text','oops')+nb_e()+nb_intarr('pos',[4,5,6])+nb_s('text','bad')+nb_e()
g.case('round trip (10.1): data keys in codec order (test, size, rotation with lower-case names, ignore_entities, status, error_message) and the errors list of {pos, text} load and save back',TIE()+L+load()+SAVE2+shw('SAVE','n:BE-XI(WS-IDX, 9)'),[],['{data:{test:minecraft:foo,size:I[5,3,7],rotation:clockwise_90,ignore_entities:1,status:finished,error_message:boom},errors:[{pos:I[1,2,3],text:oops},{pos:I[4,5,6],text:bad}]} 2'])
D2=nb_c('data')+nb_s('zzz','x')+nb_intarr('size',[1,2,3])+nb_e()
L=begin()+D2+nb_l('errors',10,5)
for i in range(5): L+=nb_intarr('pos',[i,i,i])+nb_s('junk','q')+nb_s('text','e%d'%i)+nb_e()
g.case('load (10.1): an unknown key inside data or an error marker is skipped; more than 4 markers keep the first 4',TIE()+L+load()+SAVE2+shw('SAVE','n:BE-XI(WS-IDX, 9)'),[],['{data:{size:I[1,2,3],rotation:none,ignore_entities:0,status:cleared},errors:[{pos:I[0,0,0],text:e0},{pos:I[1,1,1],text:e1},{pos:I[2,2,2],text:e2},{pos:I[3,3,3],text:e3}]} 4'])
g.case('load (10.1): a missing data compound leaves the data at its defaults (BE-LOAD resets the cells first), the error list is cleared and re-read; an invalid rotation or status gives the defaults',TIE()+'MOVE 4 TO BE-XI(WS-IDX, 2)\n'+begin()+load()+SAVE2+shw('SAVE')+TIE()+begin()+nb_c('data')+nb_s('rotation','CLOCKWISE_90')+nb_s('status','done')+nb_e()+load()+shw('SAVE'),[],['{data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}} {data:{size:I[0,0,0],rotation:none,ignore_entities:0,status:cleared}}'])
body=TIE()+'MOVE 2 TO BE-XI(WS-IDX, 7)\nMOVE "bad" TO BE-XT(WS-IDX, 2)\nMOVE 3 TO BE-XI(WS-IDX, 8)\nMOVE 0 TO WS-A\n'+call('BE6-TI-WITH-STATUS','WS-IDX','WS-A')+shw('n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 8)')
body+=txtv('WS-T64','boom')+'MOVE 4 TO WS-LEN\n'+call('BE6-TI-WITH-ERROR','WS-IDX','WS-T64','WS-LEN')+shw('n:BE-XI(WS-IDX, 7)','t:BE-XT(WS-IDX, 2)|BE-XI(WS-IDX, 8)')
body+='MOVE 1 TO WS-A\n'+call('BE6-TI-WITH-STATUS','WS-IDX','WS-A')+shw('n:BE-XI(WS-IDX, 7)','n:BE-XI(WS-IDX, 8)')
g.case('data transitions (10.2): withStatus replaces the status and clears the error message; withError sets finished and the message; setRunning and setSuccess are withStatus 1 and 2',body,[],[0,0,2,'boom',1,0])
body=TIE()+txtv('WS-T64','e1')+mv(A=1,B=2,C=3)+'MOVE 2 TO WS-LEN\n'+call('BE6-TI-MARK','WS-IDX','WS-A','WS-B','WS-C','WS-T64','WS-LEN','WS-E')+shw('n:WS-E','n:BE-XI(WS-IDX, 9)','n:BE-XI(WS-IDX, 10)','n:BE-XI(WS-IDX, 12)','t:BE-XT(WS-IDX, 3)|BE-XI(WS-IDX, 23)')
for i in range(4): body+=call('BE6-TI-MARK','WS-IDX','WS-A','WS-B','WS-C','WS-T64','WS-LEN','WS-E')
body+=shw('n:WS-E','n:BE-XI(WS-IDX, 9)')+call('BE6-TI-CLEAR','WS-IDX','WS-E')+shw('n:WS-E','n:BE-XI(WS-IDX, 9)')+call('BE6-TI-CLEAR','WS-IDX','WS-E')+shw('n:WS-E')
g.case('error markers (10.2): markError appends a marker and marks the entity changed (up to 4 here, a fifth is dropped), clearErrorMarkers empties the list and reports a change only when it was not empty (changed, count, x, z, text)',body,[],[1,1,1,3,'e1',0,4,1,0,0])
def geom(bp,pad,size,rot):
    sp=(bp[0]+pad,bp[1]+pad+1,bp[2]+pad+1)
    ts=(size[2],size[1],size[0]) if rot in (1,3) else size
    bb0=sp; bb1=(sp[0]+ts[0]-1,sp[1]+ts[1]-1,sp[2]+ts[2]-1)
    t0=(bb0[0]-pad,bb0[1]-pad,bb0[2]-pad); t1=(bb1[0]+pad,bb1[1]+pad,bb1[2]+pad)
    off={0:(0,0,0),1:(size[2]-1,0,0),2:(size[0]-1,0,size[2]-1),3:(0,0,size[0]-1)}[rot]
    sc=(sp[0]+off[0],sp[1]+off[1],sp[2]+off[2])
    return list(sp)+list(ts)+list(bb0)+list(bb1)+list(t0)+list(t1)+list(sc)+[pad,1+pad,1+pad]+list(ts)
body="";exp=[]
for pad,rot in [(2,1),(0,0),(1,2),(3,3)]:
    body+=cr(46,'test_instance_block',100,64,100)+'MOVE 5 TO BE-XI(WS-IDX, 2)\nMOVE 3 TO BE-XI(WS-IDX, 3)\nMOVE 7 TO BE-XI(WS-IDX, 4)\n'+mv(A=pad,B=rot)+call('BE6-TI-GEOM','WS-IDX','WS-A','WS-B','WS-TAB')+shw(*['n:WS-TV(%d)'%i for i in range(1,28)])
    exp+=geom((100,64,100),pad,(5,3,7),rot)
g.case('geometry (10.3, example 12.8): structure origin = block + padding + (0, 1, 1), the size with x and z swapped for the quarter turns, inclusive structure box, test box inflated by the padding, start corner by rotation, renderable box local position and size (padding, effective rotation in; 27 values out)',body,[],exp)
body="";exp=[]
for a,b in [(0,0),(1,1),(2,3),(3,3),(0,2),(3,0)]:
    body+=mv(A=a,B=b)+call('BE6-ROT-COMPOSE','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append((a+b)%4)
g.case('effective rotation (10.3): the test definition rotation composed with the data rotation (a quarter-turn sum modulo 4)',body,[],exp)
body="";exp=[]
for st,er,rq in [(0,0,1),(1,0,1),(2,0,1),(2,1,1),(2,1,0)]:
    body+=mv(A=st,B=er,C=rq)+call('BE6-TI-BEAM','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H')+shw('n:WS-E','n:WS-F','n:WS-G','n:WS-H')
    exp+={(0,0,1):[0,0,0,0],(1,0,1):[1,128,128,128],(2,0,1):[1,0,255,0],(2,1,1):[1,255,0,0],(2,1,0):[1,255,128,0]}[(st,er,rq)]
g.case('beam colours (10.3): cleared none, running grey 128 128 128, finished green, finished with an error red for a required test and orange 255 128 0 for an optional one (status, error set, required in; present, r, g, b out)',body,[],exp)
body="";exp=[]
for can,ti,act in [(0,1,2),(1,0,2),(1,1,0),(1,1,1),(1,1,2),(1,1,3),(1,1,4),(1,1,5),(1,1,6)]:
    body+=mv(A=can,B=ti,C=act)+call('BE6-TI-ACTION','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-E','n:WS-F')
    ok=can and ti
    exp+=[int(ok and act in (0,1)),int(ok and act>=2)]
g.case('Test Instance Block Action (10.4): without the rights or the entity only the final block update happens; INIT and QUERY answer with a Test Instance Block Status packet; SET, RESET, SAVE, EXPORT and RUN first take the packet data (action id, can use, is entity in; status reply, takes data out)',body,[],exp)
W(g,10)
# ===== 11
g=GG(11,'Operator rules','T0953','canUseGameMasterBlocks, the op-only types, the item data rule and the tooltip warning.')
body="";exp=[]
for ib,lvl in [(1,2),(1,4),(1,1),(0,4),(0,0)]:
    body+=mv(A=ib,B=lvl)+call('BE6-CAN-USE-GM','WS-A','WS-B','WS-C')+shw('n:WS-C'); exp.append(int(ib and lvl>=2))
g.case('canUseGameMasterBlocks (11.1): creative (instabuild) AND permission level 2 or more (instabuild, permission level in)',body,[],exp)
body="";exp=[]
for t in (23,29,7,8,9,43,21,31,45,46):
    body+='MOVE %d TO WS-A\n'%t+call('BE-TYPE-INFO','WS-A','WS-N24','WS-LEN','WS-B')+shw('n:WS-B'); exp.append(int(t in (23,29,7,8,9,43)))
g.case('OP_ONLY_CUSTOM_DATA (11.2): exactly command_block, lectern, sign, hanging_sign, mob_spawner and trial_spawner; the structure, jigsaw, test and test instance blocks are not in the set',body,[],exp)
body="";exp=[]
for cl,hd,ex,same,op,pn,gm in [(1,1,1,1,0,0,0),(0,0,1,1,0,0,0),(0,1,0,1,0,0,0),(0,1,1,0,0,0,0),(0,1,1,1,1,1,1),(0,1,1,1,1,0,1),(0,1,1,1,1,1,0),(0,1,1,1,0,1,0),(0,1,1,1,0,0,0)]:
    body+=mv(A=cl,B=hd,C=ex,E=same,F=op,G=pn,H=gm)+call('BE6-ITEM-DATA','WS-A','WS-B','WS-C','WS-E','WS-F','WS-G','WS-H','WS-P')+shw('n:WS-P')
    exp.append(int(not cl and hd and ex and same and ((not op) or ((not pn) and gm))))
g.case('item data (11.2, validation 19): nothing on a client, without the component, without an entity or with another type; an operator-only type applies only for a non-null player that can use game master blocks; every other type applies for any player (client, has data, entity exists, same type, op only, player null, can use in; applied out)',body,[],exp)
body="";exp=[]
for pn,lvl,hd,op in [(0,2,1,1),(1,4,1,1),(0,1,1,1),(0,2,0,1),(0,2,1,0),(0,4,1,1)]:
    body+=mv(A=pn,B=lvl,C=hd,E=op)+call('BE6-OP-WARNING','WS-A','WS-B','WS-C','WS-E','WS-F')+shw('n:WS-F'); exp.append(int((not pn) and lvl>=2 and hd and op))
g.case('tooltip warning (11.2): shown for a non-null player with permission level 2 (creative not needed) when the block entity data names an operator-only type (player null, permission level, has data, op only in)',body,[],exp)
W(g,11)
