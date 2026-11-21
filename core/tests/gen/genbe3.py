import sys,math
sys.path.insert(0,'core/tests/gen')
from genbe import *
OUT="core/tests"
ONLY=set(int(a) for a in sys.argv[1:])
# Independent Python models of docs/protocol/31-block-entities-3-signs-banners-skulls-pots-shelves.md (T0889 to T0904; core/src/be-31-3.cob, BE3- programs).
WS=''.join(' 01 WS-%s                 BINARY-LONG.\n'%c for c in 'ABCEFGH')+''.join(' 01 WS-F%s                FLOAT-LONG.\n'%c for c in 'ABCDEF')+''' 01 WS-U16                PIC X(16) VALUE "0123456789abcdef".
 01 WS-V16                PIC X(16) VALUE "fedcba9876543210".
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(384).
 01 WS-LINES.
    05 WS-LINE            OCCURS 4 TIMES.
       10 WS-LINE-LEN     BINARY-LONG.
       10 WS-LINE-TEXT    PIC X(384).
'''
def GG(n,subj,tasks,desc): return G('TEST-BE-31-3-%d'%n,'31-3§%d'%n,subj,'Test of 31-3 section %d, %s (core/src/be-31-3.cob; %s): %s'%(n,subj,tasks,desc),WS)
def W(g,n):
    if not ONLY or n in ONLY: g.write(OUT+'/test_be_31_3_%d.cob'%n)
def mk(typ,key): return create(typ,key)
SIGN=mk(7,'oak_sign'); HSIGN=mk(8,'oak_hanging_sign')
EMPTYS='{messages:[,,,],color:black,has_glowing_text:0}'
# ===== 1
g=GG(1,'Types and owning blocks','T0889','the six types, the sizes of sign text, the valid blocks of the skull type, the update tags and that the pot and the shelf have slots.')
reg={7:(90,10,1,0),8:(60,9,1,0),20:(0,0,0,0),16:(0,0,0,0),41:(0,0,0,1),39:(0,0,0,3)}
g.case('registration (1): text width and line height (sign 90 and 10, hanging sign 60 and 9), the sign ticker (2.9), no ticker for banner, skull, pot and shelf on the server, pot one slot, shelf 3 slots',
  "".join('MOVE %d TO WS-NV\nCALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E\n'%t for t in reg),
  [],'') if False else None
body="";show=[];exp=[]
for t,v in reg.items():
    body+='MOVE %d TO WS-NV\nCALL "BE3-REGISTRATION" USING WS-NV WS-A WS-B WS-C WS-E\n'%t
    body+=shw(*['n:WS-A','n:WS-B','n:WS-C','n:WS-E']); exp+=[x for x in v]
g.case('registration (1): text width and line height (sign 90 and 10, hanging sign 60 and 9), the sign ticker (2.9), no ticker for banner, skull, pot and shelf on the server, pot one slot, shelf 3 slots',body,show,exp)
body="";show=[];exp=[]
for t,k in ((7,'sign'),(8,'hanging_sign'),(20,'banner'),(16,'skull'),(41,'decorated_pot'),(39,'shelf')):
    body+='MOVE %d TO WS-NV\nCALL "BE-TYPE-INFO" USING WS-NV WS-N24 WS-LEN WS-A\n'%t
    body+=shw('t:WS-N24,WS-LEN'); exp.append(k)
g.case('type keys by registry id (1): sign 7, hanging_sign 8, banner 20, skull 16, decorated_pot 41, shelf 39',body,show,exp)
SK=['skeleton_skull','skeleton_wall_skull','creeper_head','creeper_wall_head','dragon_head','dragon_wall_head','zombie_head','zombie_wall_head','wither_skeleton_skull','wither_skeleton_wall_skull','player_head','player_wall_head','piglin_head','piglin_wall_head']
body='MOVE 0 TO WS-F\n'
for k in SK+['zombie_skull','creeper_skull']:
    body+='MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-SVL\nMOVE 16 TO WS-NV\nCALL "BE-VALID-BLOCK" USING WS-NV WS-KEY WS-SVL WS-A\nADD WS-A TO WS-F\n'%(k,10+len(k))
g.case('skull valid blocks (1): the 14 listed head and skull blocks, floor and wall, are valid for the skull type; zombie_skull and creeper_skull are not (14 accepted of 16 offered)',body,['n:WS-F'],[14])
body="";show=[];exp=[]
syn={7:(1,1),8:(1,1),20:(2,1),16:(1,1),41:(1,1),39:(6,1)}
for t,v in syn.items():
    body+='MOVE %d TO WS-NV\nCALL "BE-SYNC-INFO" USING WS-NV WS-A WS-B\n'%t
    body+=shw(*['n:WS-A','n:WS-B']); exp+=list(v)
g.case('update tags and packets (1, 2.10, 3.3, 4.3, 5.6, 6.2): sign, hanging sign, skull and pot send the custom-only tag (kind 1), the banner the tag without metadata (2), the shelf its own (6); all have a Block Entity Data packet',body,show,exp)
W(g,1)
# ===== 2
def wrap(x): return ((x+180)%360)-180
def facing(sign,px,pz,bx,bz,cx,cz,yaw):
    if not sign: return 1
    dx=px-(bx+cx); dz=pz-(bz+cz)
    a=math.atan2(dz,dx)*57.2957763671875-90
    return 1 if abs(wrap(yaw-a))<=90 else 0
g=GG(2,'Signs and hanging signs','T0891','state, SignText and its codec, the slot ids, the facing side, the use with an item and an empty hand, click commands, the edit packet, the editor lock, persistence and the text rendering rules.')
g.case('state (2.1): a new sign has empty black unglowing text on both sides and is not waxed; the saved form (2.10) writes front_text, back_text and is_waxed, and allow_op_features only when true',SIGN+'MOVE WS-IDX TO WS-SVL\nMOVE 2 TO WS-FORM\n',['SAVE'],['{front_text:%s,back_text:%s,is_waxed:0}'%(EMPTYS,EMPTYS)])
g.case('chunk form (2.10): id, x, y, z and components follow the sign keys; a hanging sign saves the same keys under its own type id',SIGN+'MOVE 1 TO WS-FORM\n',['SAVE'],['{front_text:%s,back_text:%s,is_waxed:0,components:{},id:minecraft:sign,x:5,y:70,z:5}'%(EMPTYS,EMPTYS)])
LOAD1=(nb_begin()+nb_b('allow_op_features',1)+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'Hi')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')
  +nb_l('filtered_messages',8,4)+nb_s(None,'H')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_s('color','red')+nb_b('has_glowing_text',1)+nb_e()
  +nb_c('back_text')+nb_l('messages',8,4)+nb_s(None,'a')+nb_s(None,'b')+nb_s(None,'c')+nb_s(None,'d')+nb_s('color','blue')+nb_e()+nb_b('is_waxed',1))
g.case('round trip (2.2, 2.10): messages, a filtered list that differs, colour, glow, waxed and allow_op_features load and save again; filtered_messages is written only when it differs; has_glowing_text defaults to 0 and is always written; the keys come in the order allow_op_features, front_text, back_text, is_waxed',
  SIGN+LOAD1+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{allow_op_features:1,front_text:{messages:[Hi,,,],filtered_messages:[H,,,],color:red,has_glowing_text:1},back_text:{messages:[a,b,c,d],color:blue,has_glowing_text:0},is_waxed:1}'])
LOAD2=(nb_begin()+nb_c('front_text')+nb_l('messages',8,3)+nb_s(None,'a')+nb_s(None,'b')+nb_s(None,'c')+nb_s('color','red')+nb_e()
  +nb_c('back_text')+nb_l('messages',8,4)+nb_s(None,'a')+nb_s(None,'b')+nb_s(None,'c')+nb_s(None,'d')+nb_l('filtered_messages',8,3)+nb_s(None,'a')+nb_s(None,'b')+nb_s(None,'c')+nb_e())
g.case('decode failures (2.2): a messages list of 3 and a filtered list whose size differs from the messages both give SignText.EMPTY for that side',SIGN+LOAD2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{front_text:%s,back_text:%s,is_waxed:0}'%(EMPTYS,EMPTYS)])
LOAD3=nb_begin()+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'x')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_s('color','lime')+nb_e()
g.case('colour and filtered defaults (2.2): an absent filtered_messages equals messages (not written back); the colour name is by DyeColor.CODEC',SIGN+LOAD3+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{front_text:{messages:[x,,,],color:lime,has_glowing_text:0},back_text:%s,is_waxed:0}'%EMPTYS])
LOAD3B=nb_begin()+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'x')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_s('color','nope')+nb_e()+nb_c('back_text')+nb_s('color','red')+nb_e()
g.case('decode failure by colour (2.2): a colour that is no dye name fails the SignText (EMPTY), and so does a side without messages',SIGN+LOAD3B+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{front_text:%s,back_text:%s,is_waxed:0}'%(EMPTYS,EMPTYS)])
ids=[0,1,2,7,-1,100]
g.case('SignTextSlot (2.3): BACK is 0 and FRONT is 1; a VarInt out of range reads as BACK',"".join('MOVE %d TO WS-NV\nCALL "BE3-SLOT-DECODE" USING WS-NV WS-A\n'%i for i in ids) and "".join('MOVE %d TO WS-NV\nCALL "BE3-SLOT-DECODE" USING WS-NV WS-A\nMOVE WS-A TO WS-%s\n'%(i,c) for i,c in zip(ids,'BCEFGH')),['n:WS-B','n:WS-C','n:WS-E','n:WS-F','n:WS-G','n:WS-H'],[1 if i==1 else 0 for i in ids])
body=SIGN+'MOVE WS-IDX TO WS-NV\n'
body+='MOVE 1 TO WS-A\nCALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-B\n'
LOADH=nb_begin()+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'')+nb_s(None,'')+nb_s(None,'Z')+nb_s(None,'')+nb_s('color','black')+nb_e()+nb_c('back_text')+nb_l('messages',8,4)+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_e()
g.case('predicates (2.2): hasMessage is true when any line has text; a side of four empty lines has none',SIGN+LOADH+'PERFORM LOAD-BUFFER\nMOVE 1 TO WS-A\nCALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-B\nMOVE 0 TO WS-A\nCALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-C\n',['n:WS-B','n:WS-C'],[1,0])
fr=[(1,0.5,5.5,0,0,0.5,0.5,0.0),(1,0.5,-5.5,0,0,0.5,0.5,0.0),(1,10.5,0.5,0,0,0.5,0.5,90.0),(1,10.5,0.5,0,0,0.5,0.5,-90.0),(1,0.5,0.5,0,0,0.5,0.5,0.0),(1,5.5,0.5,0,0,0.5,0.5,0.0),(1,0.5,2.0,3,4,0.5,0.9375,180.0),(1,0.5,9.0,3,4,0.5,0.5,90.0),(1,0.5,9.0,3,4,0.5,0.5,0.0),(0,0.5,-5.5,0,0,0.5,0.5,0.0)]
body="";show=[];exp=[]
for r in fr:
    body+='MOVE %d TO WS-A\nCOMPUTE WS-FA = %s\nCOMPUTE WS-FB = %s\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nCOMPUTE WS-FC = %s\nCOMPUTE WS-FD = %s\nCOMPUTE WS-FE = %s\nCALL "BE3-SIGN-FACING" USING WS-A WS-FA WS-FB WS-B WS-C WS-FC WS-FD WS-FE WS-E\n'%(r[0],r[1],r[2],r[3],r[4],r[5],r[6],r[7])
    body+=shw('n:WS-E'); exp.append(facing(*r))
g.case('side a player faces (2.4): only for a sign block (else FRONT); angle atan2(dz, dx) in degrees minus 90 against the sign yaw, FRONT when the wrapped difference is at most 90 (the boundary 90 is front)',body,show,exp)
# use with an item
def use_item(waxed,glow,color,msg,kind,dye,mayb,conflict):
    res=2;ev=0
    if (not mayb) or waxed or conflict: return (2,0,waxed,glow,color)
    if kind!=4 and not msg: return (2,0,waxed,glow,color)
    if kind==1:
        if dye<0 or dye==color: return (2,0,waxed,glow,color)
        color=dye
    if kind==2:
        if not glow: return (2,0,waxed,glow,color)
        glow=0
    if kind==3:
        if glow: return (2,0,waxed,glow,color)
        glow=1
    if kind==4: waxed=1; ev=3003
    return (1,ev,waxed,glow,color)
def mkload(msg,glow,color,waxed): # a sign with the given front side
    return (nb_begin()+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'Hi' if msg else '')+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_s('color',color)+nb_b('has_glowing_text',glow)+nb_e()+nb_b('is_waxed',waxed)+'PERFORM LOAD-BUFFER\n')
DY=['white','orange','magenta','light_blue','yellow','lime','pink','gray','light_gray','cyan','purple','blue','brown','green','red','black']
cases=[(0,0,'black',1,1,14,1,0),(0,0,'red',1,1,14,1,0),(0,0,'black',1,1,-1,1,0),(0,0,'black',0,1,14,1,0),(0,0,'black',1,1,14,0,0),(1,0,'black',1,1,14,1,0),(0,0,'black',1,1,14,1,1),
 (0,1,'black',1,2,0,1,0),(0,0,'black',1,2,0,1,0),(0,0,'black',1,3,0,1,0),(0,1,'black',1,3,0,1,0),(0,0,'black',0,4,0,1,0),(0,0,'black',1,4,0,1,0),(0,0,'black',0,3,0,1,0)]
body="";show=[];exp=[]
for (waxed,glow,color,msg,kind,dye,mayb,conf) in cases:
    body+=SIGN+mkload(msg,glow,color,waxed)
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nMOVE 1 TO WS-C\nMOVE %d TO WS-E\nMOVE %d TO WS-F\n'%(kind,dye,mayb,conf)
    body+='IF WS-F = 1\nMOVE "%s" TO WS-U16\nELSE\nMOVE "0123456789abcdef" TO WS-U16\nEND-IF\n'%('fedcba9876543210' if conf else '0123456789abcdef')
    if conf: body+='MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)\n'
    body+='CALL "BE3-SIGN-USE-ITEM" USING WS-IDX WS-A WS-B WS-C WS-E WS-U16 WS-G WS-H\n'
    body+=shw(*['n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 1)','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 4)'])
    r=use_item(waxed,glow,DY.index(color),msg,kind,dye,mayb,conf)
    exp+=[r[0],r[1],r[2],r[3],r[4]]
g.case('use with an item (2.5): dyes, ink sac, glow ink sac and honeycomb change the faced side only when the action changes it (honeycomb also works on blank text and raises level event 3003); a player who may not build, a waxed sign or another editor sends TRY_WITH_EMPTY_HAND (result 2, no consume, no change). Shown: result, event, waxed, glow, colour',body,show,exp)
# use empty hand
def use_empty(waxed,ran,conflict,mayb):
    if waxed: return (1,1,0)
    if ran: return (1,0,0)
    if (not conflict) and mayb: return (1,2,1)
    return (0,0,0)
body="";show=[];exp=[]
for (waxed,ran,conf,mayb) in [(1,0,0,1),(1,1,0,1),(0,1,0,1),(0,0,0,1),(0,0,1,1),(0,0,0,0),(1,0,1,0)]:
    body+=SIGN+mkload(1,0,'black',waxed)
    if conf: body+='MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "fedcba9876543210" TO BE-XT(WS-IDX, 17)\n'
    body+='MOVE 1 TO WS-A\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nCALL "BE3-SIGN-USE-EMPTY" USING WS-IDX WS-A WS-U16 WS-B WS-C WS-G WS-H\n'%(mayb,ran)
    body+=shw(*['n:WS-G','n:WS-H','n:BE-XI(WS-IDX, 3)'])
    r=use_empty(waxed,ran,conf,mayb); exp+=[r[0],r[1],r[2] if r[1]==2 else (1 if conf else 0)]
g.case('use with an empty hand (2.6): a waxed sign plays the interaction-failed sound (action 1); a click command ran gives SUCCESS (1) with no editor; otherwise the editor opens (action 2, the lock is set for this player) when nobody else holds the lock and the player may build; else PASS (0). Shown: result, action, lock set',body,show,exp)
body="";show=[];exp=[]
for k in range(5):
    for ao in (0,1):
        body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-CLICK-ACTION" USING WS-A WS-B WS-C WS-E\nCALL "BE3-CLICK-SUMMARY" USING WS-B WS-E WS-F\n'%(k,ao)
        counted=1 if k in (1,2,3) else 0
        body+=shw(*['n:WS-C','n:WS-E','n:WS-F']); exp+=[counted and ao,counted,int(counted and not ao)]
for w,r in ((0,0),(0,1),(1,0),(1,1)):
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-CLICK-CAN" USING WS-A WS-B WS-C\n'%(w,r); body+=shw('n:WS-C'); exp.append(w and r)
g.case('click commands (2.7): run_command, show_dialog and custom clicks count (run only when allow_op_features is true; the red overlay sign.click_actions_disabled follows when something counted and was not allowed); any other click is ignored; canExecuteClickCommands is waxed and a run_command line. Shown per kind 0..4 and allow 0/1: ran, counted, message; then canExecute for waxed and run_command 00 01 10 11',body,show,exp)
import re as _re
def strip(s): return _re.sub('(?i)§[0-9a-fk-or]','',s)
tests=['§aGreen','plain','','x§r','§§1y','§zq§','§K§l§N']
body="";show=[];exp=[]
for t in tests:
    body+='MOVE SPACES TO WS-TX\nMOVE "%s" TO WS-TX\nMOVE %d TO WS-A\nCALL "BE3-SIGN-STRIP" USING WS-TX WS-A\n'%(t,len(t.encode()))
    body+=shw(*['n:WS-A','t:WS-TX,WS-A' if len(strip(t).encode())>0 else 'n:0']); exp+=[len(strip(t).encode())]+([strip(t)] if len(strip(t).encode())>0 else [0])
g.case('edit packet strings (2.8 step 1): every section sign followed by 0-9, a-f, k-o or r (either case) is removed with its character; other section signs stay',body,show,exp)
def setlines(ls):
    b=''
    for i,t in enumerate(ls):
        b+='MOVE SPACES TO WS-LINE-TEXT(%d)\nMOVE "%s" TO WS-LINE-TEXT(%d)\nMOVE %d TO WS-LINE-LEN(%d)\n'%(i+1,t,i+1,len(t.encode()),i+1)
    return b
body=SIGN+mkload(1,1,'red',0)+'MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)\n'+setlines(['§aGreen','plain','','x§r'])+'MOVE 1 TO WS-A\nCALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B\nMOVE 2 TO WS-FORM\n'
g.case('edit by the editor (2.8, worked example 4): the lines are stripped and stored as raw and filtered text, colour and glow stay, the lock is cleared, the result is 1',body,['n:WS-B','n:BE-XI(WS-IDX, 3)','SAVE'],[1,0,'{front_text:{messages:[Green,plain,,x],color:red,has_glowing_text:1},back_text:%s,is_waxed:0}'%EMPTYS])
body=SIGN+mkload(1,0,'black',0)+'MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)\n'+setlines(['q','','',''])+'MOVE 1 TO WS-A\nCALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-V16 WS-LINES WS-B\nMOVE BE-XI(WS-IDX, 3) TO WS-C\nMOVE 0 TO WS-A\nCALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-E\nMOVE 1 TO WS-A\nCALL "BE3-SIGN-HAS-MESSAGE" USING WS-IDX WS-A WS-F\nMOVE 2 TO WS-FORM\n'
g.case('edit by a stranger (2.8, worked example 5): nothing changes and the lock stays (result 0, lock still set; the front text keeps Hi, the back stays empty)',body,['n:WS-B','n:WS-C','n:WS-E','n:WS-F'],[0,1,0,1])
body=SIGN+mkload(1,0,'black',1)+'MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)\n'+setlines(['q','','',''])+'MOVE 1 TO WS-A\nCALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B\nMOVE BE-XI(WS-IDX, 3) TO WS-C\n'
body+=SIGN+mkload(1,0,'black',0)+setlines(['q','','',''])+'MOVE 1 TO WS-A\nCALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-E\n'
g.case('edit refused (2.8): a waxed sign, and a sign nobody opened for editing (no lock), both refuse the packet (result 0); the waxed sign keeps its lock',body,['n:WS-B','n:WS-C','n:WS-E'],[0,1,0])
LONG='L'*70
body=SIGN+mkload(1,0,'black',0)+'MOVE 1 TO BE-XI(WS-IDX, 3)\nMOVE "0123456789abcdef" TO BE-XT(WS-IDX, 17)\n'+setlines([LONG,'b','',''])+'MOVE 0 TO WS-A\nCALL "BE3-SIGN-UPDATE" USING WS-IDX WS-A WS-U16 WS-LINES WS-B\nMOVE 2 TO WS-FORM\n'
g.case('edit of the back side (2.8): side 0 stores into the back text; a line longer than the 64 bytes kept per line is cut; the front stays',body,['n:WS-B','SAVE'],[1,'{front_text:{messages:[Hi,,,],color:black,has_glowing_text:0},back_text:{messages:[%s,b,,],color:black,has_glowing_text:0},is_waxed:0}'%('L'*64)])
LOADX=nb_begin()+nb_c('front_text')+nb_l('messages',8,4)+nb_s(None,'M'*70)+nb_s(None,'')+nb_s(None,'')+nb_s(None,'')+nb_i('extra',3)+nb_e()
g.case('long and extra data (2.2): a loaded line is kept to 64 bytes; an unknown key in a text compound is skipped',SIGN+LOADX+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{front_text:{messages:[%s,,,],color:black,has_glowing_text:0},back_text:%s,is_waxed:0}'%('M'*64,EMPTYS)])
LOADY=nb_begin()+nb_c('front_text')+nb_l('messages',10,2)+nb_e()+nb_e()+nb_e()
LOADZ=nb_begin()+nb_c('front_text')+nb_l('messages',9,2)+nb_l(None,8,0)+nb_l(None,8,0)+nb_e()+nb_i('unknown',1)
g.case('lists of other element types (2.2): a messages list of 2 compounds (components) fails the text; a list of lists too; an unknown key of the sign is skipped',SIGN+LOADY+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\nPERFORM SAVE-RENDER\n'+SIGN+LOADZ+'PERFORM LOAD-BUFFER\nPERFORM SAVE-RENDER\n',[],'{front_text:%s,back_text:%s,is_waxed:0} {front_text:%s,back_text:%s,is_waxed:0}'%(EMPTYS,EMPTYS,EMPTYS,EMPTYS))
body=""; show=[]; exp=[]
for (pres,within,lock) in [(1,1,1),(0,1,1),(1,0,1),(0,0,1),(1,1,0)]:
    body+=SIGN+('MOVE %d TO BE-XI(WS-IDX, 3)\n'%lock)+'MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SIGN-TICK" USING WS-IDX WS-A WS-B\n'%(pres,within)
    body+=shw('n:BE-XI(WS-IDX, 3)'); exp.append(lock if (pres and within) else 0)
g.case('editor lock tick (2.9): the lock is cleared when the editor is not in the level or not within distance 4.0 of the sign; kept while both hold',body,show,exp)
body="";show=[];exp=[]
for h in (10,9):
    for i in range(4):
        body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SIGN-LINE-Y" USING WS-A WS-B WS-C\n'%(i,h)
        body+=shw('n:WS-C'); exp.append(i*h-(4*h)//2)
g.case('line offset (2.11): y = i * lineHeight - (4 * lineHeight) / 2 for standing (10) and hanging (9) signs',body,show,exp)
def colors(dye,glow):
    tc=[0xFFFFFF,0xFF681F,0xFF00FF,0x9AC0CD,0xFFFF00,0xBFFF00,0xFF69B4,0x808080,0xD3D3D3,0x00FFFF,0xA020F0,0x0000FF,0x8B4513,0x00FF00,0xFF0000,0x000000][dye]
    if dye==15 and glow: return (0xFFF0EBCC,)
    r,g_,b=(tc>>16)&255,(tc>>8)&255,tc&255
    return (0xFF000000|(int(r*0.4)<<16)|(int(g_*0.4)<<8)|int(b*0.4),)
body="";show=[];exp=[]
for dye,glow in [(0,0),(14,0),(15,0),(15,1),(1,1),(12,0)]:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SIGN-COLORS" USING WS-A WS-B WS-C WS-E\n'%(dye,glow)
    body+=shw(*['n:WS-C','n:WS-E'])
    tc=[0xFFFFFF,0xFF681F,0xFF00FF,0x9AC0CD,0xFFFF00,0xBFFF00,0xFF69B4,0x808080,0xD3D3D3,0x00FFFF,0xA020F0,0x0000FF,0x8B4513,0x00FF00,0xFF0000,0x000000][dye]
    dark=colors(dye,glow)[0]
    exp+=[(0xFF000000|tc)-(1<<32) if (0xFF000000|tc)>=(1<<31) else (0xFF000000|tc), dark-(1<<32) if dark>=(1<<31) else dark]
g.case('text colours (2.11, 8): the text colour is the dye text colour with alpha 0xFF; the dark outline colour scales each channel by 0.4 (truncated), except black glowing text whose dark colour is 0xFFF0EBCC (signed ints shown)',body,show,exp)
body="";show=[];exp=[]
for (dye,glow,flag,d2,scope) in [(15,1,0,300.0,0),(15,1,0,255.5,0),(15,1,0,256.0,0),(15,1,0,1000.0,1),(14,1,0,9999.0,0),(14,0,0,1.0,0),(15,0,0,1.0,0)]:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nCOMPUTE WS-FA = %s\nCALL "BE3-SIGN-OUTLINE" USING WS-A WS-B WS-FA WS-C WS-E\n'%(dye,glow,scope,d2)
    vis=1 if scope else int(d2<256.0)
    body+=shw(*['n:WS-E']); exp.append(int(glow and (dye!=15 or vis)))
g.case('glowing outline (2.11): only glowing text has an outline; it is drawn for a non-black colour or when the outline-visible flag holds (scoping first person, else squared camera distance strictly below 256)',body,show,exp)
W(g,2)
# ===== 3
PAT=['base','border','bricks','circle','creeper','cross','curly_border','diagonal_left','diagonal_right','diagonal_up_left','diagonal_up_right','flow','flower','globe','gradient','gradient_up','guster','half_horizontal','half_horizontal_bottom','half_vertical','half_vertical_right','mojang','piglin','rhombus','skull','small_stripes','square_bottom_left','square_bottom_right','square_top_left','square_top_right','straight_cross','stripe_bottom','stripe_center','stripe_downleft','stripe_downright','stripe_left','stripe_middle','stripe_right','stripe_top','triangle_bottom','triangle_top','triangles_bottom','triangles_top']
assert len(PAT)==43
NOREQ=['square_bottom_left','square_bottom_right','square_top_left','square_top_right','stripe_bottom','stripe_top','stripe_left','stripe_right','stripe_center','stripe_middle','stripe_downright','stripe_downleft','small_stripes','cross','straight_cross','triangle_bottom','triangle_top','triangles_bottom','triangles_top','diagonal_left','diagonal_up_right','diagonal_up_left','diagonal_right','circle','rhombus','half_vertical','half_horizontal','half_vertical_right','half_horizontal_bottom','border','gradient','gradient_up']
ITEMP=['curly_border','bricks','creeper','flow','flower','globe','guster','mojang','piglin','skull']
BAN=mk(20,'blue_banner')
g=GG(3,'Banners','T0893','the layer list, its codecs and defaults, the pattern registry and tags, the limits and the update tag.')
body=BAN+'MOVE 2 TO WS-FORM\n'
g.case('state (3.1): a new banner has no layers and no name, so the saved form (3.2) is empty (patterns only when not EMPTY, CustomName only when present)',body,['SAVE'],['{}'])
LB=(nb_begin()+nb_l('patterns',10,2)+nb_s('pattern','minecraft:stripe_bottom')+nb_s('color','red')+nb_e()+nb_s('pattern','minecraft:border')+nb_s('color','white')+nb_e()+nb_s('CustomName','Flag'))
g.case('NBT (3.2, worked example 6): two layers and CustomName load and save back in that order; the update tag form (no id, x, y, z) adds components (3.3)',BAN+LB+'PERFORM LOAD-BUFFER\nMOVE 0 TO WS-FORM\n',['SAVE'],['{patterns:[{pattern:minecraft:stripe_bottom,color:red},{pattern:minecraft:border,color:white}],CustomName:Flag,components:{}}'])
LB2=nb_begin()+nb_l('patterns',10,2)+nb_s('pattern','minecraft:stripe_bottom')+nb_s('color','red')+nb_e()+nb_s('pattern','minecraft:nope')+nb_s('color','white')+nb_e()
LB3=nb_begin()+nb_l('patterns',10,1)+nb_s('pattern','minecraft:stripe_bottom')+nb_e()
LB4=nb_begin()+nb_l('patterns',10,0)
g.case('decode failures (3.2): an unknown pattern id fails the whole list, as does a layer without colour, so patterns load as EMPTY (not written); an empty list is EMPTY too',
  BAN+LB2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\nPERFORM SAVE-RENDER\n'+BAN+LB3+'PERFORM LOAD-BUFFER\nPERFORM SAVE-RENDER\n'+BAN+LB4+'PERFORM LOAD-BUFFER\n',['SAVE'],['{} {} {}']) if False else None
body=BAN+LB2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\nPERFORM SAVE-RENDER\n'+BAN+LB3+'PERFORM LOAD-BUFFER\nPERFORM SAVE-RENDER\n'+BAN+LB4+'PERFORM LOAD-BUFFER\nPERFORM SAVE-RENDER\n'
g.case('decode failures (3.2): an unknown pattern id fails the whole list, as does a layer without colour, so patterns load as EMPTY (not written); an empty list is EMPTY too',body,[],'{} {} {}')
LB5=nb_begin()+nb_l('patterns',8,1)+nb_s(None,'x')
LB6=nb_begin()+nb_l('patterns',10,1)+nb_s('pattern','stripe_bottom')+nb_s('color','red')+nb_i('extra',1)+nb_e()
g.case('layer details (3.2): a patterns list of strings fails the whole list; an identifier without namespace is minecraft: (stripe_bottom); an unknown key of a layer is skipped',
  BAN+LB5+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\nPERFORM SAVE-RENDER\n'+BAN+LB6+'PERFORM LOAD-BUFFER\nPERFORM SAVE-RENDER\n',[],'{} {patterns:[{pattern:minecraft:stripe_bottom,color:red}]}')
body=""; show=[]; exp=[]
for p in ['base','border','stripe_bottom','mojang','triangles_top','nope','Base','','x'*25]:
    body+='MOVE "%s" TO WS-N32\nMOVE %d TO WS-A\nCALL "BE3-BANNER-PATTERN" USING WS-N32 WS-A WS-B\n'%(p or ' ',len(p))
    body+=shw('n:WS-B'); exp.append(PAT.index(p) if p in PAT else -1)
g.case('pattern registry (3.2): the 43 banner_pattern ids in the order of the list (base 0, border 1, stripe_bottom 31, mojang 21, triangles_top 42); an unknown or differently cased id is -1',body,show,exp)
body=""; show=[]; exp=[]
for i,p in enumerate(PAT):
    body+='MOVE %d TO WS-A\nCALL "BE3-BANNER-TAG" USING WS-A WS-B\n'%i
    body+=shw('n:WS-B'); exp.append(1 if p in NOREQ else 2 if p in ITEMP else 0)
g.case('pattern tags (3.4): 32 patterns are in no_item_required (1), 10 patterns are the only member of a pattern_item tag (2), base is in none (0); 43 patterns in registry order',body,show,exp)
body=""; show=[]; exp=[]
for c in (0,3,6,7,16,17,40):
    body+='MOVE %d TO WS-A\nCALL "BE3-BANNER-LIMITS" USING WS-A WS-B WS-C\n'%c
    body+=shw(*['n:WS-B','n:WS-C']); exp+=[min(c,6),min(c,16)]
g.case('limits (3.1): the tooltip shows at most MAX_PATTERNS 6 layers and the renderer draws at most 16; the stored list is not limited by either',body,show,exp)
g.case('name (3.1): the default display name is block.minecraft.banner; a CustomName replaces it',BAN+'CALL "BE3-BANNER-NAME" USING WS-IDX WS-N32 WS-LEN\n'+'MOVE WS-LEN TO WS-A\nMOVE WS-N32 TO WS-TX\n'+LB+'PERFORM LOAD-BUFFER\nCALL "BE3-BANNER-NAME" USING WS-IDX WS-N32 WS-B\n',['t:WS-TX,WS-A','t:WS-N32,WS-B'],['block.minecraft.banner Flag'])
W(g,3)
# ===== 4
SKU=mk(16,'dragon_head')
g=GG(4,'Skulls','T0895','the saved keys, the profile forms, the server and client tickers, the animation and the powered property.')
g.case('state (4.1): a new skull saves no keys at all',SKU+'MOVE 2 TO WS-FORM\n',['SAVE'],['{}'])
LS=nb_begin()+nb_s('profile','Notch')+nb_s('note_block_sound','minecraft:entity.piglin.ambient')+nb_s('custom_name','Head')
g.case('keys (4.1, 4.2, 4.3): a bare string profile is a profile by name; note_block_sound and custom_name (snake case) load and save back, in the order profile, note_block_sound, custom_name; the update tag is the same three keys',SKU+LS+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{profile:{name:Notch},note_block_sound:minecraft:entity.piglin.ambient,custom_name:Head}'])
LS2=nb_begin()+nb_c('profile')+nb_s('name','Alex')+nb_e()+nb_i('custom_name',5)
g.case('profile forms (4.2): a flattened compound with a name keeps it; a key of the wrong type is read as none for that field (custom_name as an Int)',SKU+LS2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{profile:{name:Alex}}'])
LS3=nb_begin()+nb_c('profile')+nb_s('name','Alex')+nb_i('extra',1)+nb_e()+nb_s('unknown','x')
g.case('profile details (4.2): an unknown key of the profile compound and an unknown key of the skull are skipped',SKU+LS3+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{profile:{name:Alex}}'])
body=""; show=[]; exp=[]
for side,blk in [(0,'dragon_head'),(0,'piglin_wall_head'),(1,'dragon_head'),(1,'dragon_wall_head'),(1,'piglin_head'),(1,'piglin_wall_head'),(1,'zombie_head'),(1,'skeleton_skull'),(1,'player_head')]:
    body+='MOVE "%s" TO WS-N32\nMOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SKULL-TICKS" USING WS-A WS-N32 WS-B WS-C\n'%(blk,side,len(blk))
    body+=shw('n:WS-C'); exp.append(int(side==1 and blk in ('dragon_head','dragon_wall_head','piglin_head','piglin_wall_head')))
g.case('which heads tick (4.4): a ticker exists on the client only and only for the dragon and piglin heads, floor and wall; never on the server',body,show,exp)
body=SKU
show=[];exp=[]
n=0; cnt=0; anim=False
seq=[(1,1)]*30+[(1,0)]*3+[(0,1)]
for hp,pw in seq:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SKULL-TICK" USING WS-IDX WS-A WS-B\n'%(hp,pw)
body+='MOVE 0.5 TO WS-FA\nCALL "BE3-SKULL-ANIM" USING WS-IDX WS-FA WS-FB\nMOVE 0 TO WS-FA\nCALL "BE3-SKULL-ANIM" USING WS-IDX WS-FA WS-FC\n'
g.case('animation (4.4, worked example 7): powered for 30 ticks counts 30; with power removed or without the property the count is kept and isAnimating is false (a later tick with the property absent changes nothing); getAnimation(0.5) after the power went off is 30.0',
  body.replace('MOVE 0.5 TO WS-FA\nCALL "BE3-SKULL-ANIM" USING WS-IDX WS-FA WS-FB','MOVE 0.5 TO WS-FA\nCALL "BE3-SKULL-ANIM" USING WS-IDX WS-FA WS-FB'),['n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 5)','f:WS-FB','f:WS-FC'],[30,0,30.0,30.0])
body=SKU+''.join('MOVE 1 TO WS-A\nMOVE 1 TO WS-B\nCALL "BE3-SKULL-TICK" USING WS-IDX WS-A WS-B\n' for _ in range(30))+'MOVE 0.5 TO WS-FA\nCALL "BE3-SKULL-ANIM" USING WS-IDX WS-FA WS-FB\n'
g.case('animation while powered (4.4, worked example 7): after 30 powered ticks isAnimating holds, so getAnimation(0.5) is 30.5',body,['n:BE-XI(WS-IDX, 4)','n:BE-XI(WS-IDX, 5)','f:WS-FB'],[30,1,30.5])
body=""; show=[]; exp=[]
for st,sig in [(0,0),(0,1),(1,1),(1,0)]:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-SKULL-POWERED" USING WS-A WS-B WS-C WS-E\n'%(st,sig)
    body+=shw(*['n:WS-C','n:WS-E']); exp+=[sig,int(st!=sig)]
g.case('powered property (4.4): the stored value follows hasNeighborSignal; a change is written with block flags 2 (new value, write flag per stored/signal 00 01 11 10)',body,show,exp)
W(g,4)
# ===== 5
SH=['angler','archer','arms_up','blade','brewer','burn','danger','explorer','flow','friend','guster','heart','heartbreak','howl','miner','mourner','plenty','prize','scrape','sheaf','shelter','skull','snort']
assert len(SH)==23
POT=mk(41,'decorated_pot')
g=GG(5,'Decorated pots','T0897','the sherd mapping, the insert rule with its fraction and pitch, the wobble event and its animation formulas, cracking and the saved keys.')
g.case('state (5.1): a new pot has no sherds and no item and saves no keys; the item key is absent for an empty pot',POT+'MOVE 2 TO WS-FORM\n',['SAVE'],['{}'])
LP=nb_begin()+nb_c('sherds')+nb_c('back')+nb_s('id','minecraft:brick')+nb_i('count',1)+nb_e()+nb_s('front','minecraft:angler_pottery_sherd')+nb_e()
g.case('sherds (5.2): each side is an item template compound or a bare item id; absent sides stay plain; saved back as compounds (back, left, right, front order)',POT+LP+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{sherds:{back:{id:minecraft:brick,count:1},front:{id:minecraft:angler_pottery_sherd,count:1}}}'])
body=""; show=[]; exp=[]
for k in ['angler_pottery_sherd','snort_pottery_sherd','flow_pottery_sherd','brick','stick_pottery_sherd','blade_sherd','pottery_sherd','angler_pottery_sherx']:
    body+='MOVE "minecraft:%s" TO WS-KEY\nMOVE %d TO WS-A\nCALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B\n'%(k,len(k)+10)
    if k.endswith('_pottery_sherd') and k[:-14] in SH:
        body+=shw(*['n:WS-B','t:WS-TX,WS-B']); exp+=[len(k[:-14]),k[:-14]]
    else:
        body+=shw(*['n:WS-B']); exp+=[0]
g.case('sherd pattern (5.2): the item <key>_pottery_sherd provides the pattern <key> for the 23 keys; any other item (the brick) has none (length 0 and plain side)',body,show,exp)
body='MOVE 0 TO WS-C\n'
for p in SH:
    body+='MOVE "minecraft:%s_pottery_sherd" TO WS-KEY\nMOVE %d TO WS-A\nCALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B\nADD WS-B TO WS-C\n'%(p,len(p)+24)
g.case('sherd patterns (5.2): all 23 keys map; the sum of the pattern key lengths is checked',body,['n:WS-C'],[sum(len(p) for p in SH)])
def ins(stored,item,maxs,var):
    # stored (item,count) ; offered item,max -> (result,count,pitch)
    if stored[1]==0: return (1,1,0.7+0.5*(1/maxs))
    if stored[0]==item and stored[1]<maxs: return (1,stored[1]+1,0.7+0.5*((stored[1]+1)/maxs))
    return (0,stored[1],0.0)
body=POT; show=[]; exp=[]
body+='MOVE 100 TO WS-A\nMOVE 0 TO WS-B\nMOVE 64 TO WS-C\n'
for step in range(3):
    body+='CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F\n'
    body+=shw(*['n:WS-E','n:BE-SLOT-COUNT(WS-IDX, 1)','f4:WS-FA','n:WS-F'])
    r=ins(('x',step) if step else ('x',0),100,64,0); exp+=[1,step+1,0.7+0.5*((step+1)/64),1]
body+='MOVE 101 TO WS-A\nCALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F\n'
body+=shw(*['n:WS-E','n:BE-SLOT-COUNT(WS-IDX, 1)','n:BE-SLOT-ITEM(WS-IDX, 1)']); exp+=[0,3,100]
body+='MOVE 100 TO WS-A\nMOVE 3 TO BE-SLOT-COUNT(WS-IDX, 1)\nMOVE 3 TO WS-C\nCALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F\n'
body+=shw(*['n:WS-E','n:BE-SLOT-COUNT(WS-IDX, 1)']); exp+=[0,3]
g.case('insert (5.3, worked example 8): an empty pot takes one item and the pitch is 0.7 + 0.5 * count / maximum; the same item grows it (2/64 ...); a different item, or a full stack, is refused (result 0, nothing changes)',body,show,exp)
body=""; show=[]; exp=[]
body+='MOVE 0 TO WS-A\nCALL "BE3-POT-DURATION" USING WS-A WS-B\nMOVE 1 TO WS-A\nCALL "BE3-POT-DURATION" USING WS-A WS-C\n'
g.case('wobble durations (5.4): POSITIVE (data 0) lasts 7 ticks, NEGATIVE (data 1) 10',body,['n:WS-B','n:WS-C'],[7,10])
LP3=nb_begin()+nb_c('item')+nb_stack(2,3)+nb_e()+nb_s('LootTable','lt:b')+nb_c('item')+nb_stack(2,3)+nb_e()+nb_c('sherds')+nb_s('top','x')+nb_c('left')+nb_s('id','minecraft:howl_pottery_sherd')+nb_s('extra','y')+nb_e()+nb_i('top',4)+nb_e()
g.case('loot table and unknown keys (5.1, 5.2): a LootTable hides the item (cleared, a later item ignored); the seed is not written when 0; unknown sherd keys of any tag type are skipped',POT+LP3+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{sherds:{left:{id:minecraft:howl_pottery_sherd,count:1}},LootTable:lt:b}'])
g.case('loot table seed load (5.1): LootTable and LootTableSeed load and save back',POT+nb_begin()+nb_s('LootTable','lt:e')+nb_long('LootTableSeed',99)+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{LootTable:lt:e,LootTableSeed:99}'])
g.case('loot table seed (5.1): a non-zero LootTableSeed is saved with the table',POT+'MOVE 4 TO BE-LOOT-LENGTH(WS-IDX)\nMOVE "lt:d" TO BE-LOOT(WS-IDX)\nMOVE 77 TO BE-SEED(WS-IDX)\nMOVE 2 TO WS-FORM\n',['SAVE'],['{LootTable:lt:d,LootTableSeed:77}'])
body=POT
for ty,da,tm in [(1,0,100),(1,1,200),(1,2,300),(2,0,400),(1,-1,500)]:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nCALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E\n'%(ty,da,tm)
    body+=shw(*['n:WS-E','n:BE-XI(WS-IDX, 5)','n:BE-XI(WS-IDX, 6)'])
exp=[1,100,0, 1,200,1, 0,200,1, 0,200,1, 0,200,1]
g.case('block event (5.4): type 1 with data 0 or 1 records the game time and the style; any other type or data goes to the base class (not handled, state kept)',body,show,exp)
def prog(t,start,style,p):
    if style<0: return 0.0
    dur=7 if style==0 else 10
    return ((t-start)+p)/dur
body=POT+'MOVE 0 TO WS-A\nMOVE 0 TO WS-B\nMOVE 100 TO WS-C\nMOVE 0.5 TO WS-FA\nCALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E\nMOVE 1 TO WS-A\nMOVE 100 TO WS-C\nCALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E\nMOVE 103 TO WS-C\nCALL "BE3-POT-PROGRESS" USING WS-IDX WS-C WS-FA WS-FB\n'
body+=POT+'MOVE 103 TO WS-C\nCALL "BE3-POT-PROGRESS" USING WS-IDX WS-C WS-FA WS-FC\n'
g.case('progress (5.5, worked example 9): (gameTime - start + partial) / duration; started at 100 as POSITIVE, time 103, partial 0.5 gives 0.5; a pot that never wobbled gives 0',body,['f:WS-FB','f:WS-FC'],[0.5,0.0])
def pose(style,p):
    if p<0 or p>1: return (0.0,0.0,0.0)
    if style==0:
        a=p*2*math.pi
        return ((-1.5*(math.cos(a)+0.5))*math.sin(a/2)*0.015625, math.sin(a)*0.015625, 0.0)
    r=math.sin(-p*3*math.pi)*0.125
    return (0.0,0.0,r*(1-p))
body="";show=[];exp=[]
for st,p in [(0,0.5),(0,0.25),(0,1.0),(0,1.5),(0,-0.1),(1,0.5),(1,0.2),(1,0.0)]:
    body+='MOVE %d TO WS-A\nCOMPUTE WS-FA = %s\nCALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD\n'%(st,p)
    body+=shw(*['f:WS-FB','f:WS-FC','f:WS-FD']); r=pose(st,p); exp+=[("%.6f"%x if False else round(x*1000000)/1000000) for x in r]
g.case('wobble animation (5.5, worked example 9): POSITIVE rotates about X by (-1.5 * (cos a + 0.5)) * sin(a / 2) * 0.015625 and about Z by sin a * 0.015625 with a = 2 pi * progress; NEGATIVE about Y by sin(-progress * 3 pi) * 0.125 * (1 - progress); nothing outside 0 to 1 (rotations X, Z, Y in radians)',body,show,exp)
body=""; show=[]; exp=[]
for br,pv in [(1,0),(1,1),(0,0),(0,1)]:
    body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nCALL "BE3-POT-BREAK" USING WS-A WS-B WS-C WS-E\n'%(br,pv)
    body+=shw(*['n:WS-C','n:WS-E']); ok=br and not pv; exp+=[int(ok),260 if ok else 0]
g.case('breaking (5.3): a main-hand item in breaks_decorated_pots without an enchantment of prevents_decorated_pot_shattering sets cracked with flags 260; otherwise the pot stays whole (cracked, flags per tool 10 11 00 01)',body,show,exp)
LP2=nb_begin()+nb_c('item')+nb_stack(2,3)+nb_e()
g.case('item (5.1): the stored stack loads and saves under item (one slot); with a LootTable pending the item key is not written',POT+LP2+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\nPERFORM SAVE-RENDER\nMOVE 4 TO BE-LOOT-LENGTH(WS-IDX)\nMOVE "lt:a" TO BE-LOOT(WS-IDX)\nPERFORM SAVE-RENDER\n',[],'{item:{id:cobolcraft:greystone,count:3}} {LootTable:lt:a}')
W(g,5)
# ===== 6
SHF=mk(39,'oak_shelf')
g=GG(6,'Shelves','T0899','the three slots and align flag, the always-written Items, the update tag, the hotbar index of a multi-swap and the swap of one slot with the sounds.')
g.case('state (6.1): Items is always written (an empty list) and align_items_to_bottom (default false) too',SHF+'MOVE 2 TO WS-FORM\n',['SAVE'],['{Items:[],align_items_to_bottom:0}'])
g.case('update tag (6.2): the same two keys with no id, x, y, z or components (kind 6 of the sync table)',SHF+'MOVE 6 TO WS-NV\nMOVE 0 TO WS-A\nMOVE 0 TO WS-FORM\nCALL "PB-INIT" USING PB-BUFFER WS-CAPACITY\nCALL "BE-TAG-ENTRIES" USING WS-IDX PB-BUFFER\nCALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER\nMOVE 0 TO PB-POS\nMOVE 0 TO WS-LEN\nMOVE SPACES TO WS-OUT\nCALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN\nCALL "PB-FREE" USING PB-BUFFER\nMOVE WS-LEN TO WS-A\n',['t:WS-OUT,WS-A'],['{Items:[],align_items_to_bottom:0}'])
LSH=nb_begin()+nb_l('Items',10,2)+nb_b('Slot',2)+nb_stack(2,2)+nb_e()+nb_b('Slot',5)+nb_stack(2,1)+nb_e()+nb_b('align_items_to_bottom',1)
g.case('load (6.1): the list is cleared, slots 0 to 2 load and a slot outside them (5) is ignored; align_items_to_bottom loads and saves back as a byte',SHF+LSH+'PERFORM LOAD-BUFFER\nMOVE 2 TO WS-FORM\n',['SAVE'],['{Items:[{Slot:2,id:cobolcraft:greystone,count:2}],align_items_to_bottom:1}'])
body=""; show=[]; exp=[]
for n in (1,2,3):
    for i in range(n):
        for j in range(3):
            body+='MOVE %d TO WS-A\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nCALL "BE3-SHELF-HOTBAR" USING WS-A WS-B WS-C WS-E\n'%(n,i,j)
            body+=shw('n:WS-E'); exp.append(9-n*3+(i*3+j))
g.case('multi-swap (6.3 step 5): the hotbar index is 9 - listSize * 3 + (shelfIndex * 3 + j) for 1, 2 and 3 connected shelves',body,show,exp)
def swap(shelf,held,creative):
    # shelf (item,count), held (item,count): returns new shelf, new held, success, s1, s2
    old=shelf
    new_shelf=held
    new_held=old
    if creative and old[1]==0: new_held=held
    ok=(new_shelf[1]>0) or (old[1]>0)
    s1=0;s2=0
    if ok:
        s1=1 if new_held[1]==0 else 2
        if new_shelf[1]>0: s2=3
    return new_shelf,new_held,int(ok),s1,s2
body=""; show=[]; exp=[]
for (sh,he,cr) in [((0,0),(7,8),0),((9,1),(7,8),0),((9,1),(0,0),0),((0,0),(0,0),0),((0,0),(7,8),1),((9,1),(7,8),1)]:
    body+=SHF+'MOVE 1 TO WS-A\nMOVE %d TO BE-SLOT-ITEM(WS-IDX, 2)\nMOVE %d TO BE-SLOT-COUNT(WS-IDX, 2)\nMOVE %d TO WS-B\nMOVE %d TO WS-C\nMOVE 0 TO WS-E\nMOVE %d TO WS-F\nCALL "BE3-SHELF-SWAP" USING WS-IDX WS-A WS-B WS-C WS-E WS-F WS-G WS-H\n'%(sh[0],sh[1],he[0],he[1],cr)
    # outputs: held item WS-B/count WS-C, success WS-G, sounds in WS-H (s1*10+s2)
    body+='MOVE WS-H TO WS-FA\n'
    ns,nh,ok,s1,s2=swap(sh,he,cr)
    body+=shw(*['n:BE-SLOT-ITEM(WS-IDX, 2)','n:BE-SLOT-COUNT(WS-IDX, 2)','n:WS-B','n:WS-C','n:WS-G','n:WS-H'])
    exp+=[ns[0] if ns[1] else (ns[0] if False else (ns[0])), ns[1], nh[0] if nh[1] else nh[0], nh[1], ok, s1*10+s2]
g.case('swap of one slot (6.3 step 4, worked example 10): the shelf slot and the held stack trade places (a creative player who put into an empty slot keeps the stack); success when the shelf stack is now non-empty or was; sound 1 take when the hand is empty afterwards else 2 swap, then 3 place when the shelf slot holds something (shown: shelf item, count, held item, count, success, sounds 10 * first + second)',body,show,exp)
W(g,6)
# ===== 7
g=GG(7,'Beds','T0901','no bed block entity type exists: the registry has no bed and a saved bed entry is skipped with the invalid-type result.')
body='MOVE "bed" TO WS-N24\nMOVE 3 TO WS-LEN\nCALL "BE-TYPE-ID" USING WS-N24 WS-LEN WS-A\nMOVE "white_bed" TO WS-N24\nMOVE 9 TO WS-LEN\nCALL "BE-TYPE-ID" USING WS-N24 WS-LEN WS-B\nMOVE 0 TO WS-F\n'
body+='PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 48\nCALL "BE-TYPE-INFO" USING WS-J WS-N24 WS-LEN WS-C\nINSPECT WS-N24 TALLYING WS-F FOR ALL "bed"\nEND-PERFORM\n'
g.case('registry (7): bed and white_bed are no block entity type and none of the 49 type keys contains bed',body,['n:WS-A','n:WS-B','n:WS-F'],[-1,-1,0])
body=nb_begin()+nb_s('id','minecraft:bed')+nb_i('x',1)+nb_i('y',64)+nb_i('z',2)+nb_b('flag',1)+nb_e()+'MOVE 0 TO PB-POS\nMOVE "minecraft:red_bed" TO WS-KEY\nMOVE 17 TO WS-SVL\nMOVE 0 TO WS-A\nMOVE 0 TO WS-B\nCALL "BE-LOAD-CHUNK-ENTRY" USING PB-BUFFER WS-D WS-A WS-B WS-KEY WS-SVL WS-C WS-IDX\nCALL "PB-FREE" USING PB-BUFFER\n'
g.case('stored bed (7): a block_entities compound with id minecraft:bed is skipped with the invalid-type result 2 (no entity is created, index 0)',body,['n:WS-C','n:WS-IDX'],[2,0])
W(g,7)
# ===== 8
DYE=[(0,'white',0xFFFFFF,0xF9FFFE,0xF0F0F0),(1,'orange',0xFF681F,0xF9801D,0xEB8844),(2,'magenta',0xFF00FF,0xC74EBD,0xC354CD),(3,'light_blue',0x9AC0CD,0x3AB3DA,0x6689D3),(4,'yellow',0xFFFF00,0xFED83D,0xDECF2A),(5,'lime',0xBFFF00,0x80C71F,0x41CD34),(6,'pink',0xFF69B4,0xF38BAA,0xD88198),(7,'gray',0x808080,0x474F52,0x434343),(8,'light_gray',0xD3D3D3,0x9D9D97,0xABABAB),(9,'cyan',0x00FFFF,0x169C9C,0x287697),(10,'purple',0xA020F0,0x8932B8,0x7B2FBE),(11,'blue',0x0000FF,0x3C44AA,0x253192),(12,'brown',0x8B4513,0x835432,0x51301A),(13,'green',0x00FF00,0x5E7C16,0x3B511A),(14,'red',0xFF0000,0xB02E26,0xB3312C),(15,'black',0x000000,0x1D1D21,0x1E1B1B)]
g=GG(8,'DyeColor','T0903','the 16 colours with their names and the three colour columns, the codec lookups by name and by id.')
body="";show=[];exp=[]
for d in DYE:
    body+='MOVE %d TO WS-A\nCALL "BE3-DYE-INFO" USING WS-A WS-N32 WS-LEN WS-B WS-C WS-E\n'%d[0]
    body+=shw(*['t:WS-N32,WS-LEN','n:WS-B','n:WS-C','n:WS-E'])
    exp+=[d[1],d[2],d[3],d[4]]
g.case('table (8): id, serialized name, text colour, texture diffuse colour and firework colour of the 16 colours (RGB as decimal)',body,show,exp)
body=""; show=[]; exp=[]
for i in (-1,16,255):
    body+='MOVE %d TO WS-A\nCALL "BE3-DYE-INFO" USING WS-A WS-N32 WS-LEN WS-B WS-C WS-E\n'%i
    body+=shw(*['t:WS-N32,WS-LEN']); exp.append('white')
g.case('stream ids (8): DyeColor.STREAM_CODEC maps an out-of-range id to white',body,show,exp)
body=""; show=[]; exp=[]
for nme in ['white','light_gray','black','Red','purple','grey','']:
    body+='MOVE "%s" TO WS-N32\nMOVE %d TO WS-A\nCALL "BE3-DYE-ID" USING WS-N32 WS-A WS-B\n'%(nme,len(nme))
    body+=shw('n:WS-B'); exp.append(next((d[0] for d in DYE if d[1]==nme),-1))
g.case('codec by name (8): DyeColor.CODEC is by the serialized name (an unknown or differently cased name, and the empty name, give -1)',body,show,exp)
W(g,8)
