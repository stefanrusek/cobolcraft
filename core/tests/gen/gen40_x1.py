import sys,math,struct,decimal
sys.path.insert(0,'core/tests/gen')
from gen40m import *
# Independent Python models of docs/protocol/40-menus-x1-continuation.md (sections 1 to 8). Programs under test: MNX- of core/src/menu-40-x1.cob,
# which also calls the MN9- rule programs of menu-40-9.cob and MN8-FIELDINS, MN8-FIELDSET and MN8-ALLOWED of menu-40-8.cob (the EditBox text rules).
def GX(n,subj,tasks,desc,fld=False):
    g=GenT('TEST-MENU-40-X1-%d'%n,'40-x1§%d'%n,subj,'Test of 40-x1 section %d, %s (%s): %s'%(n,subj,tasks,desc),False,fld)
    g.extra+=EXTRA
    return g
def WX(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_x1_%d.cob'%n)
def f32r(v): return struct.unpack('>f',struct.pack('>f',v))[0]
M6=lambda v:int(math.floor(abs(v)*1000000+0.5))*(1 if v>=0 else -1)
def mcode(prog,toks,outs):
    # toks as call9 (without the hex output), outs: 'i' integer, 'f' float (shown times 1e6), 't' text (last only; WS-TB, length in the next WS-R)
    pre=[]; use=[]; ni=nt=nf=nd=0
    for k,v in toks:
        if k=='i':
            ni+=1; nm='WS-I%d'%ni if ni<=16 else 'WS-J%d'%(ni-16); pre.append('MOVE %d TO %s'%(v,nm)); use.append(nm)
        elif k=='t':
            nm='WS-T'+'ABCD'[nt]; nt+=1; pre.append(settext(nm,v)); use.append(nm)
        elif k=='f':
            nf+=1; nm='WS-FX%d'%nf; pre.append('MOVE %s TO %s'%(FL(v),nm)); use.append(nm)
        else:
            nd+=1; nm='WS-D%d'%nd; pre.append('MOVE %d TO %s'%(v,nm)); use.append(nm)
    post=[]; nr=nrf=0
    for j,o in enumerate(outs):
        last=(j==len(outs)-1); sep='" "' if last else '"/"'
        if o=='i':
            nr+=1; use.append('WS-R%d'%nr)
            post.append('MOVE WS-R%d TO WS-SHOW\nSTRING FUNCTION TRIM(WS-SHOW) %s DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%(nr,sep))
        elif o=='f':
            nrf+=1; use.append('WS-RF%d'%nrf)
            post.append('COMPUTE WS-D3 ROUNDED = WS-RF%d * 1000000\nMOVE WS-D3 TO WS-DSH\nSTRING FUNCTION TRIM(WS-DSH) %s DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%(nrf,sep))
        else:
            nr+=1; use.append('WS-TB'); use.append('WS-R%d'%nr)
            post.append('MOVE WS-TB TO WS-TA\nMOVE WS-R%d TO WS-TL\nPERFORM SHOW-TA'%nr)
    return "\n".join(pre)+'\nCALL "%s" USING %s\n'%(prog," ".join(use))+"\n".join(post)
def mstr(items):
    o=[]
    for x in items:
        if isinstance(x,str): o.append(txtmodel_str(x))
        elif isinstance(x,float): o.append(str(M6(x)))
        else: o.append(str(x))
    return "/".join(o)
def mrows(g,text,prog,intypes,outs,rows,model,limit=880):
    chunked(g,text,rows,lambda r:('0',mcode(prog,[(t,v) for t,v in zip(intypes,r)],outs),None),lambda r:mstr(model(*r)),limit)
# ===== 1
g=GX(1,'Overview','T1123','the six screens: packet and trigger, isInGameUi, nothing opened by a packet (core/src/menu-40-x1.cob).')
sends={1:(55,3),2:(56,3),3:(60,5),4:(59,9),5:(61,1),6:(65,16)}
mrows(g,'1 table: screen (1 command block 2 minecart 3 structure 4 jigsaw 5 test block 6 test instance) -> packet id and the mask of what sends it (1 Done 2 Enter 4 SAVE LOAD DETECT 8 Generate 16 several actions)','MNX-SENDS','i',['i','i'],[(s,) for s in range(1,7)],lambda s:sends[s])
mrows(g,'1: all six screens return true from isInGameUi (40-9 7A.1 says false for the command block screen; section 1 and 7A.1 of the others agree on true) (screen -> in game ui)','MN9-INGAMEUI','i',['i'],[(s,) for s in range(1,7)],lambda s:(1,))
rows=[(s,h) for s in range(1,7) for h in range(1,9)]
def pk6(sc,how):
    ok={1:(1,2),2:(1,2),3:(1,2,5,6,7),4:(1,2,8),5:(1,),6:(1,)}[sc]
    pk={1:55,2:56,3:60,4:59,5:61,6:65}[sc]
    return (0,0) if how not in ok else (pk,27 if (sc==4 and how==8) else 0)
mrows(g,'1: what each ending sends (screen, how 1 Done 2 Enter 3 Escape 4 Cancel 5 SAVE 6 LOAD 7 DETECT 8 Generate -> first packet id, second); the test instance screen sends 0x41 from Done and nothing from Escape','MN9-SCREENPKT','ii',['i','i'],rows,pk6)
WX(g,1)
# ===== 2
g=GX(2,'How each screen is opened','T1125','the trigger method of each block, the open conditions and the consequences for a server.')
trig={1:(1,1),2:(2,0),3:(3,0),4:(1,0),5:(1,0),6:(1,0)}
mrows(g,'2 table: kind (1 command block 2 minecart 3 structure block 4 jigsaw 5 test block 6 test instance) -> the method that opens it (1 useWithoutItem 2 interact 3 usedBy) and whether the server sends Block Entity Data (only the command block)','MNX-TRIGGER','i',['i','i'],[(k,) for k in range(1,7)],lambda k:trig[k])
def opens(kind,present,cu,side):
    present=1 if kind==2 else present
    res=1 if (cu and present) else 0
    if not res: return (0,0)
    if side==1: return (1,1)
    return (1,2) if kind==1 else (1,0)
rows=[(k,p,c,s) for k in range(1,7) for p in (0,1) for c in (0,1) for s in (1,2)]
mrows(g,'2: the open rule per kind and side (kind, entity present, may use game master blocks, side 1 client 2 server -> result 1 SUCCESS, action 1 push screen 2 send data); a player without rights never gets a screen','MN9-OPEN','iiii',['i','i'],rows,opens)
def servercheck(pk,cu,tg):
    if pk not in (55,56,59,60,61,27,65): return 0
    if not cu: return 1 if pk in (55,56) else 0
    return 2 if tg else 0
mrows(g,'2 consequence 3: packets from a client without the rights are ignored, only 0x37 and 0x38 answer advMode.notAllowed (packet, may use, target -> action)','MN9-SERVERCHECK','iii',['i'],[(p,c,t) for p in (55,56,59,60,61,27,65) for c in (0,1) for t in (0,1)],lambda *a:(servercheck(*a),))
WX(g,2)
# ===== 3
g=GX(3,'Generic widgets used by the screens','T1127','EditBox constants, keys and insert rules, CycleButton index maths, slider rules and the fitting text widget.',fld=True)
eb={1:32,2:-2039584,3:-9408400,4:300,5:4,6:1}
mrows(g,'3.1 EditBox constants: default maximum length 32, text colour -2039584, uneditable colour -9408400, cursor blink period 300 ms, inner padding 4, caret width 1','MNX-EBCONST','i',['i'],[(i,) for i in sorted(eb)],lambda i:(eb[i],))
def chartyped(a,f,e,cp):
    return (1 if (a and f and e and cp>=32 and cp!=127 and cp!=167) else 0,)
rows=[(a,f,e,cp) for a in (0,1) for f in (0,1) for e in (0,1) for cp in (65,31) if (a+f+e)%3!=1 or cp==65]+[(1,1,1,127),(1,1,1,167),(1,1,1,32),(1,1,1,168)]
mrows(g,'3.1 rule 2: a typed character counts only when the box is active, focused and editable and the character is an allowed chat character (code point 32 or more, not 127, not 167)','MNX-CHARTYPED','iiii',['i'],rows,chartyped)
def ebkey(k,ctrl,shift,ed):
    base={8:1,127:2,1073741904:3,1073741903:4,1073741898:5,1073741901:6,97:7,99:8,120:9,118:10}
    a=base.get(k,0)
    if a in (7,8,9,10) and not ctrl: a=0
    if a in (1,2,9,10) and not ed: a=0
    if a==0: return (0,0,0,0)
    return (1,a,1 if (ctrl and a in (1,2,3,4)) else 0,1 if (shift and a in (3,4,5,6)) else 0)
keys=[8,127,1073741904,1073741903,1073741898,1073741901,97,99,120,118,13,65]
rows=[(k,c,s,e) for k in keys for c in (0,1) for s in (0,1) for e in (0,1)]
mrows(g,'3.1 rule 4: keys 8 Backspace 127 Delete (editable only, by word with control), 1073741904 and 1073741903 Left and Right (word with control, Shift extends), 1073741898 and 1073741901 Home and End (Shift extends), control with a c x v select all copy cut paste; Enter is not handled (key, control, shift, editable -> handled, action, by word, extends selection)','MNX-EBKEY','iiii',['i','i','i','i'],rows,ebkey,limit=800)
def ebdraw(x,y,w,h,b,v,f):
    if not v: return (0,0,0,0,0)
    return (1,(2 if f else 1) if b else 0,(w-8) if b else w,x+4 if b else x,y+(h-8)//2 if b else y)
rows=[(10,50,300,20,b,v,f) for b in (0,1) for v in (0,1) for f in (0,1)]+[(3,4,80,24,1,1,0)]
mrows(g,'3.1 rule 5: a bordered box draws widget/text_field (highlighted when focused) over its rectangle, the inner width is width - 8, the text starts at x + 4 and y + (height - 8) / 2; an unbordered box uses the widget origin; nothing is drawn when not visible (x y w h bordered visible focused -> drawn, sprite 0 none 1 plain 2 highlighted, inner width, text x, text y)','MNX-EBDRAW','iiiiiii',['i']*5,rows,ebdraw)
# insert and setValue through the MN8 field programs: the shared text rules
def finsert(s,cur,anc,mx,ins):
    a=min(cur,anc); b=max(cur,anc); left=mx-len(s)+(b-a)
    f=''.join(ch for ch in ins if ord(ch)>=32 and ord(ch) not in (127,167))
    if left<=0: return (s,cur,0)
    f=f[:left]
    n=s[:a]+f+s[b:]
    return (n,a+len(f),1)
def fcase(s,cur,anc,mx,ins):
    code=fld(s,cur,anc,mx)+'\n'+settext('WS-TA',ins)+'\nMOVE %d TO WS-I1\nCALL "MN8-FIELDINS" USING MN8-FLD WS-TA WS-I1\nMOVE MN8-FCUR TO WS-R1\nMOVE MN8-FANC TO WS-R2\nMOVE MN8-FCHANGED TO WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-FLD'%len(ins)
    n,c,ch=finsert(s,cur,anc,mx,ins)
    return ('0',code,None),'%d/%d/%d %s'%(c,c,ch,txtmodel_str(n))
cs=[fcase('abc',3,3,5,'XYZ'),fcase('abc',1,3,5,'12345'),fcase('abcde',5,5,5,'x'),fcase('',0,0,3,'a'+chr(7)+'b'),fcase('ab',1,1,32,'q'),fcase('hello',0,5,5,'')]
g.case('3.1 rule 3 insertText: the selection is the replace range, the space left is the maximum minus the length plus the selected length, nothing happens when it is 0 or less, the text is cleaned and cut to the space left, the cursor goes after it',[c[0] for c in cs]," ".join(c[1] for c in cs))
def fsetcase(s,mx):
    code=fld('',0,0,mx)+'\n'+settext('WS-TA',s)+'\nMOVE %d TO WS-I1\nCALL "MN8-FIELDSET" USING MN8-FLD WS-TA WS-I1\nMOVE MN8-FCUR TO WS-R1\nMOVE MN8-FCHANGED TO WS-R2\nMOVE 2 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-FLD'%len(s)
    n=s[:mx]
    return ('0',code,None),'%d/1 %s'%(len(n),txtmodel_str(n))
cs=[fsetcase('abcdef',3),fsetcase('ab',10),fsetcase('',4)]
g.case('3.1 rule 1 setValue: the text is cut to the maximum length, the cursor goes to the end with no selection and the responder is called (changed 1)',[c[0] for c in cs]," ".join(c[1] for c in cs))
def cyc(n,i,d): return ((i+d)%n,)
rows=[(n,i,d) for n,i in ((3,0),(3,2),(2,1),(4,0),(4,3),(3,-1),(2,0)) for d in (1,-1)]
mrows(g,'3.2 behaviour 2: index = positiveModulo(index + delta, size); a boolean button holds true first so the first click from index 1 goes to 0; an index of -1 (initial value not in the list) steps to 0 on a click (size, index, delta -> new index)','MNX-CYCLE','iii',['i'],rows,cyc)
def cevent(e): return {1:(1,0),2:(-1,0),3:(-1,1),4:(1,1),5:(0,1)}[e]
mrows(g,'3.2 behaviour 1: a click cycles by +1, Shift-click by -1, the wheel up by -1 and down by +1 (always consumed), zero does nothing (event 1 click 2 shift-click 3 wheel up 4 wheel down 5 wheel zero -> delta, wheel consumed)','MNX-CYCLEEVENT','i',['i','i'],[(e,) for e in range(1,6)],lambda e:{1:(1,0),2:(-1,0),3:(-1,1),4:(1,1),5:(0,1)}[e])
mrows(g,'3.2 construction: the alt list is used while Alt is held and the button has one, else the default list (Alt held, has alt list, default size, alt size -> list size); the structure mode button has 3 and 4','MNX-CYCLELIST','iiii',['i'],[(a,h,3,4) for a in (0,1) for h in (0,1)]+[(1,1,2,2)],lambda a,h,nd,na:(na if (a and h) else nd,))
mrows(g,'3.2 behaviour 3 setValue: the index is set only when the value is in the list, the stored value is replaced in every case and the callback does not fire (index, position of the value in the list or -1 -> index, callback fired)','MNX-CYCLESET','ii',['i','i'],[(1,0),(1,2),(2,-1),(0,-1)],lambda i,p:(p if p>=0 else i,0))
mrows(g,'3.2 construction: the label is the value text for displayOnlyValue, else options.generic_value with name and value (only value -> 0 value text 1 generic value)','MNX-CYCLELABEL','i',['i'],[(0,),(1,)],lambda o:(0 if o else 1,))
cases=[(1,),(0,)]
chunked(g,'3.2 onOffBuilder texts: options.on for true and options.off for false (value 1 true)',cases,lambda r:('0','MOVE %d TO WS-I1\nCALL "MNX-ONOFF" USING WS-I1 WS-TA WS-TL\nPERFORM SHOW-TA'%r[0],None),lambda r:'options.on' if r[0] else 'options.off')
def slclick(mx,x,w): return (min(max((mx-(x+4))/(w-8),0.0),1.0),)
rows=[(mx,10,100) for mx in (0,10,14,60,106,200)]+[(6,6,100)]
mrows(g,'3.3 rule 1: a mouse press sets value = clamp((mouseX - (x + 4)) / (width - 8), 0, 1); at x + 4 + 46 it is 0.5, at the far right 1.0 (mouse x, widget x, width -> value x 1e6)','MNX-SLIDERCLICK','iii',['f'],rows,slclick)
def slkey(k,w,can,v):
    if not can or k not in (1073741904,1073741903): return (v,0)
    nv=min(max(v+(-1 if k==1073741904 else 1)/(w-8),0.0),1.0)
    return (nv,1)
rows=[(k,100,c,v) for k in (1073741904,1073741903,13) for c in (0,1) for v in (0.5,)]+[(1073741904,100,1,0.0),(1073741903,100,1,1.0)]
mrows(g,'3.3 rule 2: while canChangeValue is true Left and Right change the value by -1 or +1 times 1 / (width - 8), one pixel; other keys are not consumed (key, width, canChangeValue, value -> new value x 1e6, handled)','MNX-SLIDERKEY','iiif',['f','i'],rows,slkey)
mrows(g,'3.3 rule 3 setValue: the value is clamped to 0..1; applyValue runs only when the clamped value differs from the old one (new value, old value -> clamped x 1e6, applyValue called)','MNX-SLIDERSET','ff',['f','i'],[(0.5,0.0),(0.5,0.5),(1.5,1.0),(-1.0,0.25),(1.5,0.5)],lambda n,o:(min(max(n,0.0),1.0),1 if min(max(n,0.0),1.0)!=o else 0))
mrows(g,'3.3 drawing: the handle is drawn at x + trunc(value * (width - 8)) (x, width, value -> handle x)','MNX-SLIDERHANDLE','iif',['i'],[(10,100,0.0),(10,100,0.5),(10,100,1.0),(6,100,0.999),(0,50,0.3)],lambda x,w,v:(x+int(v*(w-8)),))
mrows(g,'3.3 rule 2: focus gives canChangeValue only when the last input was the mouse (1) or Tab navigation (2), not the keyboard (3); a selection key toggles it (last input -> canChangeValue)','MNX-SLIDERFOCUS','i',['i'],[(1,),(2,),(3,)],lambda i:(1 if i in (1,2) else 0,))
mrows(g,'3.3 rule 2: a selection key toggles canChangeValue (value -> new)','MNX-SLIDERSELECT','i',['i'],[(0,),(1,)],lambda c:(1-c,))
def fit(w,h,n): return (w-8,n*9,1 if n*9>h-8 else 0,(h-8)//9)
mrows(g,'3.4: the fitting text area has padding 4 on each side, its text width is widget width - 8, the inner height is lines x 9, it scrolls when that exceeds height - 8, and a 72 high widget shows 7 full lines (width, height, wrapped lines -> text width, inner height, scrollable, full lines shown)','MNX-FIT','iii',['i']*4,[(316,72,n) for n in (0,1,7,8,9,20)]+[(100,30,2),(100,30,3)],fit)
mrows(g,'3.5: the command block suggestions list holds 7 lines where the chat screen holds 10 (screen 1 chat 2 command block -> line limit)','MNX-SUGGLIMIT','i',['i'],[(1,),(2,)],lambda s:(10 if s==1 else 7,))
WX(g,3)
# ===== 4
g=GX(4,'The command block screens','T1129','initial state, updateGui, the worked examples at W 320 and the minecart server steps.')
mrows(g,'4.2 initial state (kind 1 block 2 minecart -> mode 2 REDSTONE, conditional 0, automatic 0, controls enabled, command empty): the block screen opens with Done and four buttons greyed','MNX-CMDINIT','i',['i']*5,[(1,),(2,)],lambda k:(2,0,0,1 if k==2 else 0,1))
rows=[(320,240,m,i) for m in (0,1) for i in range(1,12)]
chunked(g,'4.4 and 4.5 examples 1 and 2 at W 320 H 240: command box x 10 y 50, previous box x 10 to 286 y 135, output button x 290, cycles x 6 110 214 at y 165, Done 6 192, Cancel 164 192; minecart previous box y 150, label y 140 (W H minecart item)',rows,irow(None,'MN9-CMDRECT',4,4),lambda r:out(cmdrect(*r)))
def cmdprev(track,outlen):
    if track==0: return (0,1)
    return (1,1 if outlen>0 else 0)
def cmdgui(track,mode,cond,auto,outlen):
    pk,pd=cmdprev(track,outlen)
    return (1,1-track,mode,1-cond,1-auto,pk,pd)
mrows(g,'4.5 example 3: data for a block with mode AUTO, conditional true, auto false, track true, last output hi: the mode button shows Repeat (index 1), type Conditional (0), trigger Needs Redstone (1), track O (0), the previous box the output, all five enabled (track, mode, conditional, automatic, output length -> enabled, track idx, mode idx, type idx, trigger idx, prev kind, prev drawn)','MN9-CMDGUI','iiiii',['i']*7,[(1,1,1,0,2),(0,0,0,0,2),(1,2,0,1,0)],cmdgui)
mrows(g,'4.5 examples 4 and 5: turning track off shows - and keeps the label and box drawn; tracking on with no stored output draws neither (track, output length -> kind, drawn)','MN9-CMDPREV','ii',['i','i'],[(0,5),(1,0),(1,3)],cmdprev)
def mc(cu,res,tl,tr,en):
    if not cu: return (1,0,0,0,0)
    if not res: return (0,0,0,0,0)
    msg=0
    if tl>0: msg=2 if en else 3
    return (msg,1,1,1-tr,en)
rows=[(c,r,t,tr,e) for c in (0,1) for r in (0,1) for t in (0,5) for tr in (0,1) for e in (0,1) if c==1 or (r==0 and t==0 and tr==0 and e==0)]
mrows(g,'4.3 minecart server steps: not allowed answers advMode.notAllowed (1) and stops; an unresolved entity does nothing; else setCommand, setTrackOutput, last output cleared when not tracking, onUpdated when command blocks are enabled, and for a non-empty text the message success (2) or disabled (3) (may use, resolves, text length, track, enabled -> message, set command, set track, clear last output, onUpdated)','MNX-MINECART','iiiii',['i']*5,rows,mc)
mrows(g,'4.5 example 6 and 4.7: the packet sent by Enter before data arrived (position 0 64 0, empty command, mode 2, flags 0) holds the empty command, mode REDSTONE and flags 0 (track, conditional, automatic -> flags)','MN9-CMDFLAGS','iii',['i'],[(0,0,0),(1,1,0),(1,0,1),(1,1,1)],lambda t,c,a:(t+2*c+4*a,))
hexcases(g,'4.5 example 6: Enter sends mode REDSTONE (2), flags 0 and the empty command',[c37(0,64,0,'',2,0,0,0)])
hexcases(g,'4.5 example 3: Done after data for mode AUTO, conditional, not automatic, tracking, command say hi sends mode 1 and flags 0x03',[c37(5,70,-3,'say hi',1,1,1,0)])
hexcases(g,'4.3: Set Command Minecart carries the entity id, the command text and the track flag',[c38(77,'say hi',1),c38(77,'',0)])
mrows(g,'4.7 edge cases: the box allows 32500 characters while 0x37 lists 32767 (command box 1, minecart command 2 -> screen limit, wire limit)','MN9-LIMIT','i',['i','i'],[(1,),(2,)],lambda i:(32500,32767))
WX(g,4)
# ===== 5
g=GX(5,'StructureBlockEditScreen','T1131','label keys, mirror symbols, 0.0### formatting, actions, clamps and the worked examples.')
keys5={1:'structure_block.structure_name',2:'structure_block.position',3:'structure_block.include_entities',4:'structure_block.size',5:'structure_block.detect_size',
       6:'structure_block.show_air',7:'structure_block.integrity',8:'structure_block.strict',9:'structure_block.show_boundingbox',10:'structure_block.custom_data'}
chunked(g,'5.5 label keys (1 name 2 position 3 include entities 4 size 5 detect 6 show air 7 integrity and seed 8 strict 9 show bounding box 10 custom data)',[(i,) for i in sorted(keys5)],lambda r:('0','MOVE %d TO WS-I1\nCALL "MNX-STRKEY" USING WS-I1 WS-TA WS-TL\nPERFORM SHOW-TA'%r[0],None),lambda r:keys5[r[0]])
modes=['save','load','corner','data']
chunked(g,'5.5 step 7 and 5.2 mode texts (mode, 1 cycle label key, 2 description key structure_block.mode_info.<name>)',[(m,w) for m in range(4) for w in (1,2)],
        lambda r:('0','MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN9-STRMODEKEY" USING WS-I1 WS-I2 WS-TA WS-TL\nPERFORM SHOW-TA'%r,None),lambda r:('structure_block.mode.' if r[1]==1 else 'structure_block.mode_info.')+modes[r[0]])
mir={0:(124,0,0,1),1:(8592,32,8594,3),2:(8593,32,8595,3)}
mrows(g,'5.2 mirror value labels: mirror.none is the bar, mirror.left_right U+2190 U+0020 U+2192 and mirror.front_back U+2191 U+0020 U+2193 (mirror -> code points, count)','MNX-MIRRORTEXT','i',['i']*4,[(m,) for m in range(3)],lambda m:(mir[m][0],mir[m][1],mir[m][2],mir[m][3]))
def decfmt(v):
    d=decimal.Decimal(v).quantize(decimal.Decimal('0.0001'),rounding=decimal.ROUND_HALF_EVEN)
    s=format(d,'f').rstrip('0')
    if s.endswith('.'): s+='0'
    return s
vals=[1.0,0.5,0.25,0.123456,0.0,0.03125,0.09375,0.99999,2.0,0.1,12.34567,-0.25,0.0001,0.00004]
chunked(g,'5.2 and 5.9 example 4: the integrity box shows DecimalFormat 0.0### (at least one and at most four decimals, half even): 1.0 gives 1.0, 0.25 gives 0.25, 0.123456 gives 0.1235 (value -> text)',[(v,) for v in vals],
        lambda r:('0','MOVE %s TO WS-FX1\nCALL "MNX-DECFMT" USING WS-FX1 WS-TA WS-TL\nPERFORM SHOW-TA'%FL(r[0]),None),lambda r:decfmt(r[0]))
def stract(how,mode):
    if how in (1,2): return (1,0,1,0)
    if how==3: return (1,1,1,0) if mode==0 else (0,0,0,0)
    if how==4: return (1,2,1,0) if mode==1 else (0,0,0,0)
    if how==5: return (1,3,1,0) if mode==0 else (0,0,0,0)
    return (0,0,1,1)
mrows(g,'5.7 table: Done or Enter send UPDATE_DATA and close; SAVE (mode SAVE) SAVE_AREA, LOAD (mode LOAD) LOAD_AREA, DETECT (mode SAVE) SCAN_AREA, each then closes; Cancel and Esc restore the seven values and send nothing (how 1 Done 2 Enter 3 SAVE 4 LOAD 5 DETECT 6 Cancel 7 Escape, mode -> sent, update type, closes, restored)','MN9-STRACT','ii',['i']*4,[(h,m) for h in range(1,8) for m in range(4)],stract)
rows=[(1,m) for m in range(4)]
def strvis(mode,item):
    if item in (1,2,5): return 1
    sets={0:(16,17,18,19,20,21,22,3,6,7,10),1:(16,17,18,19,23,24,4,7,8,9,12,13,14,15,11),2:(16,),3:(25,)}
    return 1 if item in sets[mode] else 0
mrows(g,'5.3 table: the visible widgets per mode (mode, item 16 name 17 position X 20 size X 23 integrity 25 custom data 3 SAVE 4 LOAD 9 mirror 12 rotation 0 -> visible); DATA hides the name box','MN9-STRVIS','ii',['i'],[(m,i) for m in range(4) for i in (16,17,20,23,25,3,4,9,12)],lambda m,i:(strvis(m,i),))
def strrect(W,H,item):
    c=W//2
    t={1:(c-154,210,150,20),2:(c+4,210,150,20),3:(c+104,185,50,20),4:(c+104,185,50,20),5:(c-154,185,50,20),6:(c+104,120,50,20),7:(c+104,160,50,20),
       8:(c+104,120,50,20),9:(c-20,185,40,20),10:(c+104,80,50,20),11:(c+104,80,50,20),12:(c-102,185,40,20),13:(c-61,185,40,20),14:(c+21,185,40,20),
       15:(c+62,185,40,20),16:(c-152,40,300,20),17:(c-152,80,80,20),18:(c-72,80,80,20),19:(c+8,80,80,20),20:(c-152,120,80,20),21:(c-72,120,80,20),
       22:(c+8,120,80,20),23:(c-152,120,80,20),24:(c-72,120,80,20),25:(c-152,120,240,20)}
    return t[item]
rows=[(320,240,i) for i in range(1,26)]
chunked(g,'5.8 layout at W 320: name x 8 to 308, positions 8 88 168, integrity 8, seed 88, custom data 8 to 248, mode 6 to 56, rotations 58 99 181 222, mirror 140 to 180, SAVE 264, Done 6, Cancel 164 (W H item)',rows,irow(None,'MN9-STRRECT',3,4),lambda r:out(strrect(*r)))
def fold(v):
    b=v%256
    return b-256 if b>=128 else b
def strclamp(k,v):
    f=fold(v)
    return min(max(f,-48),48) if k==1 else min(max(f,0),48)
mrows(g,'5.9 example 2: a typed size 300 is written as 44 and read as 44; offset 200 reads -56 and clamps to -48; size 255 reads -1 and clamps to 0; offset -5 stays -5 (kind 1 offset 2 size, typed -> value read)','MN9-STRCLAMP','ii',['i'],[(2,300),(1,200),(2,255),(1,-5)],lambda k,v:(strclamp(k,v),))
def namechar(t,cur,cp):
    colon=t.find(':'); slash=t.find('/'); c=chr(cp)
    if c==':': return 1 if (colon==-1 and (slash==-1 or cur<=slash)) else 0
    if c=='/': return 1 if cur>colon else 0
    return 1 if (c in '_-.' or 'a'<=c<='z' or '0'<=c<='9') else 0
steps=[('',0,97),('a',1,58),('a:',2,98),('a:b',3,47),('a:b/',4,99),('a:b/c',5,58),('a:b/c',5,65),('a:b/c',0,47),('a:b',0,47)]
chunked(g,'5.9 example 3: typing a:b/c accepts a : b / c, then refuses a second colon and upper case A; a slash with the cursor before the colon is refused (text, cursor, code point -> accepted)',steps,
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-NAMECHAR" USING WS-TA WS-I1 WS-I2 WS-I3 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(len(r[0]),r[1],r[2]),None),lambda r:str(namechar(*r)))
def pf(s,d=1.0):
    import re
    if not re.fullmatch(r'[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)',s): return d
    return float(s)
mrows(g,'5.9 example 4: abc in the integrity box sends 1.0, 0.5 sends 0.5 (text -> value x 1e6)','MN9-PARSEFLOAT','tif',['f'],[('abc',3,1.0),('0.5',3,1.0)],lambda t,n,d:(pf(t),))
hexcases(g,'5.9 example 1: SAVE in SAVE mode sends SAVE_AREA, mode save, name house, offset 0 1 0, size 5 5 5, mirror none, rotation none, entities on (flag 0x01 clear)',
         [c3c(0,64,0,1,0,'house',0,1,0,5,5,5,0,0,'',1.0,0,0,0,0,0),c3c(0,64,0,0,0,'house',0,1,0,300,5,5,0,0,'',1.0,0,0,0,0,0)])
mrows(g,'5.9 example 5: mode cycling SAVE LOAD CORNER SAVE without Alt, a DATA entity opens at index -1 and the first click selects SAVE, with Alt the walk uses four entries (size, index, delta -> index)','MNX-CYCLE','iii',['i'],[(3,0,1),(3,1,1),(3,2,1),(3,-1,1),(4,3,1),(4,2,1)],cyc)
mrows(g,'5.9 example 6: with rotation CLOCKWISE_90 the 90 button is greyed and the others active (rotation -> active of 0 90 180 270)','MN9-STRROT','i',['i']*4,[(1,),(2,)],lambda r:tuple(0 if r==k else 1 for k in range(4)))
WX(g,5)
# ===== 6
g=GX(6,'JigsawBlockEditScreen','T1133','the slider on a pointer, Done and Generate order, validity and the worked examples.')
def jigrect(W,H,item):
    c=W//2
    t={1:(c-153,20,300,20),2:(c-153,55,300,20),3:(c-153,90,300,20),4:(c-153,125,300,20),5:(c-153,160,98,20),6:(c-50,160,98,20),7:(c+54,160,100,20),
       8:(c-154,185,100,20),9:(c-50,185,100,20),10:(c+54,185,100,20),11:(c-154,210,150,20),12:(c+4,210,150,20)}
    return t[item]
rows=[(320,240,i) for i in range(1,13)]
chunked(g,'6.6 example 1 at W 320: pool x 7 to 307 y 20, name y 55, target y 90, final state y 125, priorities x 7 to 105 and 110 to 208, joint x 214 to 314, slider x 6 to 106, keep jigsaws x 110, Generate x 214, Done x 6, Cancel x 164 (W H item)',rows,irow(None,'MN9-JIGRECT',3,4),lambda r:out(jigrect(*r)))
mrows(g,'6.6 example 2: the joint button and label are shown and enabled at orientation up_north (front vertical) and hidden at north_up (front horizontal) (item, front direction 0 down 1 up 2 north -> visible)','MN9-JIGVIS','ii',['i'],[(7,1),(13,1),(7,2),(13,2),(7,0),(1,2)],lambda i,d:((1 if d<2 else 0) if i in (7,13) else 1,))
def jigslider(mx,x,w):
    v=min(max((mx-(x+4))/(w-8),0.0),1.0)
    return (v,int(math.floor(20*v)))
mrows(g,'6.6 example 3: width 100 gives travel 92; a click at x + 4 + 46 gives value 0.5 and levels 10, at the far right 1.0 and levels 20, near the left end 0 (mouse x, slider x, width -> value x 1e6, levels)','MNX-JIGSLIDER','iii',['f','i'],[(56,6,100),(110,6,100),(200,6,100),(0,6,100),(10,6,100),(80,6,100)],jigslider)
mrows(g,'6.6 example 3: the value 0.999 gives levels 19 (floor of 19.98)','MN9-JIGLEVELS','f',['i'],[(0.999,),(0.5,),(1.0,)],lambda v:(int(math.floor(20*v)),))
def jigsend(how,valid):
    if not valid: return (0,0,0)
    if how==3: return (59,27,1)
    return (59,0,1)
mrows(g,'6.2 and 6.3: Done and Enter send 0x3B only while valid, Generate runs onDone then sends 0x1B, Enter never triggers Generate (how 1 Done 2 Enter 3 Generate, valid -> first packet, second packet, closes)','MNX-JIGSEND','ii',['i']*3,[(h,v) for h in (1,2,3) for v in (0,1)],jigsend)
trip=[('minecraft:bad pool','b','c'),('a:b','c:d','e:f')]
chunked(g,'6.6 example 4: the pool minecraft:bad pool fails tryParse on the space, Done and Generate are greyed and Enter does nothing (name target pool -> valid)',trip,
        lambda r:('0',settext('WS-TA',r[1])+'\n'+settext('WS-TB',r[2])+'\n'+settext('WS-TC',r[0])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-JIGVALID" USING WS-TA WS-I1 WS-TB WS-I2 WS-TC WS-I3 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(len(r[1]),len(r[2]),len(r[0])),None),
        lambda r:'1' if all(tryparse(x) is not None for x in r) else '0')
texts=['-5','abc','1000','','-','0','999','-99','+4']
def pint(s):
    import re
    if not re.fullmatch(r'[+-]?[0-9]+',s): return 0
    v=int(s)
    return v if -2147483648<=v<=2147483647 else 0
chunked(g,'6.6 example 5 and 6.3: priorities go through Integer.parseInt with 0 on failure: -5 sends -5, abc sends 0, a lone - or the empty text 0 (text -> value)',[(t,) for t in texts],
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE %d TO WS-I1\nMOVE 1 TO WS-I2\nMOVE 0 TO WS-D2\nCALL "MN9-PARSENUM" USING WS-TA WS-I1 WS-I2 WS-D2 WS-D3\nMOVE WS-D3 TO WS-DSH\nSTRING FUNCTION TRIM(WS-DSH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%len(r[0]),None),lambda r:str(pint(r[0])))
hexcases(g,'6.3: Done sends 0x3B and Generate then 0x1B with the position, levels and keep jigsaws; priorities -5 and 0 (a negative VarInt takes five bytes)',
         [c3b(1,2,3,'a','b','minecraft:pool','',0,-5,0),c1b(1,2,3,10,1)])
mrows(g,'6.5 resize: the slider returns to value 0 with the old level in its label (levels, joint -> slider, label, joint)','MN9-JIGRESIZE','ii',['i']*3,[(10,1),(0,0)],lambda l,j:(0,l,j))
WX(g,6)
# ===== 7
g=GX(7,'TestBlockEditScreen','T1135','Done and the hidden message, mode cycling, and the worked examples.')
def tbrect(W,H,item):
    c=W//2
    return {1:(c-152,80,240,20),2:(c-154,185,50,20),3:(c-154,210,150,20),4:(c+4,210,150,20)}[item]
rows=[(320,240,i) for i in range(1,5)]
chunked(g,'7 worked example at W 320: message box x 8 to 248 y 80 to 100, mode button x 6 to 56 y 185, Done x 6 and Cancel x 164 at y 210 (W H item)',rows,irow(None,'MN9-TBRECT',3,4),lambda r:out(tbrect(*r)))
def tblabel(W,mode,item):
    c=W//2
    return {1:(1,c,10),2:(1 if mode!=0 else 0,c-153,70),3:(1,c-153,174)}[item]
mrows(g,'7 worked example at W 320: the label Message: at (7, 70) only when the mode is not START, the mode text at (7, 174) always (W, mode, item 2 label 3 description -> drawn, x, y)','MN9-TBLABEL','iii',['i']*3,[(320,m,i) for m in (0,1) for i in (2,3)],lambda W,m,i:tblabel(W,m,i))
mrows(g,'7 onDone: the message of the box is sent whatever the mode, hidden or not, with the mode id, then the screen closes (mode, box text length -> mode sent, message length sent, closes)','MNX-TBDONE','ii',['i']*3,[(0,0),(0,5),(1,5),(3,0)],lambda m,n:(m,n,1))
mrows(g,'7 worked example: Shift-click from START goes backwards to ACCEPT (index 3); a click from START goes to LOG; Alt has no effect (size, index, delta -> index)','MNX-CYCLE','iii',['i'],[(4,0,-1),(4,0,1),(4,3,1),(4,1,1)],cyc)
hexcases(g,'7 worked example: LOG with hello sends mode 1 and hello; back to START the hidden box still sends mode 0 with hello',[c3d(1,2,3,1,'hello'),c3d(1,2,3,0,'hello')])
mrows(g,'7: the message box is visible only when the mode is not START (mode -> visible)','MN9-TBVIS','i',['i'],[(m,) for m in range(4)],lambda m:(1 if m else 0,))
mrows(g,'7: Enter does nothing on the test block screen (screen 5, done active 1 -> onDone runs)','MN9-ENTER','ii',['i'],[(5,1),(5,0)],lambda s,d:(0,))
WX(g,7)
# ===== 8
g=GX(8,'TestInstanceBlockEditScreen','T1137','layout in binary32 steps, parseSize, tryParse, rotation, save state, status text, resize, server store rules and the 0x41 body.')
def tibx(W,n,i):
    left=W//2-158
    ex=f32r((316-(n-1)*8)/n)
    step=f32r(8.0+ex)
    prod=f32r(i*step)
    return int(f32r(left+prod))
def tibsz(n): return int(f32r((316-(n-1)*8)/n))
rows=[(W,n,i) for W in (320,321,400,318) for n in (2,3,5) for i in range(n)]
mrows(g,'8.1 layout: exactWidgetSize(n) = (316 - (n - 1) * 8) / n in binary32, widgetSize its truncation, widgetX(i, n) = trunc(left + i * (8 + exact)) in binary32 steps (W, n, i -> exact x 10, widget size, x)','MNX-TIBX','iii',['i']*3,rows,lambda W,n,i:(int(round(f32r((316-(n-1)*8)/n)*10)),tibsz(n),tibx(W,n,i)),limit=800)
def tibrect(W,ide,item):
    c=3 if ide else 2; left=W//2-158
    t={1:(left,40,316,20),2:(left,70,316,72),3:(tibx(W,5,0),160,tibsz(5),20),4:(tibx(W,5,1),160,tibsz(5),20),5:(tibx(W,5,2),160,tibsz(5),20),
       6:(tibx(W,5,3),160,tibsz(5),20),7:(tibx(W,5,4),160,tibsz(5),20),8:(tibx(W,c,0),185,tibsz(c),20),9:(tibx(W,c,1),185,tibsz(c),20),
       10:(tibx(W,3,2) if False else tibx(W,c,2),185,tibsz(c),20),11:(tibx(W,3,0),210,tibsz(3),20),12:(tibx(W,3,1),210,tibsz(3),20),13:(tibx(W,3,2),210,tibsz(3),20)}
    r=t[item]
    if item==10 and not ide: return (0,0,0,0)
    return r
rows=[(W,ide,i) for W in (320,) for ide in (0,1) for i in range(1,14)]+[(321,0,i) for i in range(1,14)]
chunked(g,'8.2 and 8.4 examples at W 320 (left 2): ID box x 2 y 40 316 wide, info text y 70 316 x 72, size boxes x 2 66 131, rotation 196, include entities 261, Reset 2 and Save 164, Run 2, Done 110, Cancel 218; with the IDE flag Reset 2, Save 110, Export 218; W 321 is the same (W, IDE flag, item -> x y w h; Export is absent without the flag)',rows,
        lambda r:('0','MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MNX-TIBRECT" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2 WS-R3 WS-R4\nMOVE 4 TO WS-N\nPERFORM ADD-N'%r,None),lambda r:out(tibrect(*r)))
def tiblabel(W,item):
    left=W//2-158; c=W//2
    return {1:(c,10),2:(left,30),3:(left,150),4:(tibx(W,5,3),150),5:(tibx(W,5,4),150)}[item]
mrows(g,'8.3 point 6 drawing: title centred at (cx, 10), labels at (left, 30), (left, 150), above the rotation button and above the include entities button at y 150 (W, label -> x, y)','MNX-TIBLABEL','ii',['i','i'],[(320,i) for i in range(1,6)]+[(400,i) for i in range(1,6)],tiblabel)
def psize(s):
    v=pint(s)
    return min(max(v,1),48) if (pint(s)!=0 or s in ('0','-0','00')) and __import__('re').fullmatch(r'[+-]?[0-9]+',s) else 1
def psize(s):
    import re
    if not re.fullmatch(r'[+-]?[0-9]+',s): return 1
    v=int(s)
    if not -2147483648<=v<=2147483647: return 1
    return min(max(v,1),48)
texts=['0','99','x','-5','48','47','1','','-','+7','2147483648','12a']
chunked(g,'8.3 point 1 and 7A.3 parseSize: Integer.parseInt then clamp to 1..48, 1 on any number format error (empty, letters, a lone sign, outside the int range): 0 sends 1, 99 sends 48, x sends 1, -5 sends 1, 48 sends 48 (text -> size)',[(t,) for t in texts],
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE %d TO WS-I1\nCALL "MNX-PARSESIZE" USING WS-TA WS-I1 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%len(r[0]),None),lambda r:str(psize(r[0])))
idt=['','foo','minecraft:my_test','Bad Id',':foo','a:b:c','x y','A:b','a..:b','..:a']
def identstr(t):
    p=tryparse(t)
    return '%d %s'%(1 if p is not None else 0,txtmodel_str(p) if p is not None else '<>')
def identcode(t): return settext('WS-TA',t)+'\nMOVE %d TO WS-I1\nCALL "MN9-IDENT" USING WS-TA WS-I1 WS-R1 WS-TB WS-R2\nMOVE 1 TO WS-N\nPERFORM ADD-N\nMOVE WS-TB TO WS-TA\nMOVE WS-R2 TO WS-TL\nPERFORM SHOW-TA'%len(t)
chunked(g,'7A.3 test id of a packet: foo gives minecraft:foo, :foo gives minecraft:foo, a:b:c fails, an upper-case letter or a space fails, and the EMPTY text parses as minecraft: (text -> parsed, key text)',[(t,) for t in idt],lambda r:('0',identcode(r[0]),None),lambda r:identstr(r[0]))
mrows(g,'7A.3 rotation: the screen shows (t + d) mod 4 of the test own rotation t and the stored d, a Done stores that, and the effective rotation afterwards is (2t + d) mod 4: test rotation CLOCKWISE_90 stored NONE opens at 90, stores 1 and becomes CLOCKWISE_180 (t, d -> shown, stored by Done, effective after)','MNX-ROTATION','ii',['i']*3,[(t,d) for t in range(4) for d in range(4)],lambda t,d:((t+d)%4,(t+d)%4,(2*t+d)%4))
mrows(g,'8.3 point 3 updateSaveState: Save and Export are active exactly when the rotation is NONE and the id text parses (the empty text parses too); Reset, Run, Done and Cancel are always active (rotation, id parses -> save active)','MNX-SAVESTATE','ii',['i'],[(r,o) for r in range(4) for o in (0,1)],lambda r,o:(1 if (r==0 and o==1) else 0,))
mrows(g,'8.3 point 2 updateTestInfo: INIT (0) at the end of init, QUERY (1) after each change of the id box, one packet each; when the id does not parse the info text becomes the red Invalid test ID (init, id parses -> action, invalid text shown)','MNX-INFO','ii',['i','i'],[(i,o) for i in (0,1) for o in (0,1)],lambda i,o:(0 if i else 1,1-o))
def tact(how): return {1:(3,1,1),2:(4,1,1),3:(5,1,1),4:(6,1,1),5:(2,1,2),6:(-1,1,2),7:(-1,1,2)}[how]
mrows(g,'8.3 and 7A.3 actions (1 Reset 2 Save 3 Export 4 Run 5 Done 6 Cancel 7 Escape -> action id sent or -1, closes, how: 1 Gui.setScreen(null) directly 2 onClose); RESET 3, SAVE 4, EXPORT 5, RUN 6, Done SET 2, Cancel and Escape send nothing','MNX-TIBACTION','i',['i']*3,[(h,) for h in range(1,8)],tact)
mrows(g,'7A.4 Action ids: INIT 0 to RUN 6, an id outside 0..6 decodes as INIT (id -> action)','MNX-TIBACTID','i',['i'],[(i,) for i in (0,1,2,3,4,5,6,7,-1,100)],lambda i:(i if 0<=i<=6 else 0,))
def tibserver(a,cu,ex):
    p=1 if (cu and ex) else 0
    ac=a if 0<=a<=6 else 0
    st=1 if (p and ac>=2) else 0
    return (p,st,1 if (p and ac<2) else 0,st)
mrows(g,'7A.4 server rules: needs the permission and a test instance block entity, else no reply and no message; INIT and QUERY answer with a status packet and store nothing; SET, RESET, SAVE, EXPORT and RUN store the packet data without checks, act and end with a block update (action, may use, entity exists -> processed, stores, answers, block update)','MNX-TIBSERVER','iii',['i']*4,[(a,c,e) for a in (0,1,2,3,4,5,6,9) for c in (0,1) for e in (0,1) if (c and e) or a in (0,2)],tibserver)
def tmsg(he,err,text):
    return ('Failed: %s\n\n%s'%(err,text)) if he else text
cases=[(1,'boom','Function: foo'),(0,'','Function: foo'),(1,'x','')]
def msgcode(r):
    return settext('WS-TA',r[1])+'\n'+settext('WS-TB',r[2])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MNX-TIBMSG" USING WS-I1 WS-TA WS-I2 WS-TB WS-I3 WS-TC WS-R1\nMOVE WS-TC TO WS-TA\nMOVE WS-R1 TO WS-TL\nINSPECT WS-TA(1:WS-TL) REPLACING ALL X"0A" BY "~"\nINSPECT WS-TA(1:WS-TL) REPLACING ALL " " BY "_"\nSTRING WS-TA(1:WS-TL) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%(r[0],len(r[1]),len(r[2]))
chunked(g,'7A.3 setStatus and 8.4 example 6: the info text is Failed: boom (the argument red), two line feeds, then the reply text when the client entity has an error message; without it only the reply text (has error, error, reply -> text with line feed shown as ~)',cases,lambda r:('0',msgcode(r),None),lambda r:tmsg(*r).replace('\n','~').replace(' ','_') if tmsg(*r) else '<>')
mrows(g,'7A.3: a status reply is handled only when the current screen is this one; a late reply after Cancel does nothing (current screen is this one -> handled)','MNX-TIBSTATUS','i',['i'],[(0,),(1,)],lambda c:(c,))
chunked(g,'7A.3 and 8.4 example 6: Integer.toString of the three size values written into the boxes by a status reply with a size (value -> text)',[(3,),(0,),(48,),(-5,)],lambda r:('0','MOVE %d TO WS-I1\nCALL "MNX-ITOA" USING WS-I1 WS-TA WS-TL\nPERFORM SHOW-TA'%r[0],None),lambda r:str(r[0]))
mrows(g,'7A.5 resize: no resize override, the widgets are rebuilt from the entity (typed id, sizes, rotation and include entities are lost), the info text is empty and one INIT (0) is sent (-> action sent, info text empty, typed text kept)','MNX-TIBRESIZE','',['i','i','i'],[()],lambda:(0,1,0))
mrows(g,'7A.1 background: isInGameUi draws a vertical gradient over the whole screen from 0xC0101010 at the top (-1072689136) to 0xD0101010 at the bottom (-804253680) (row 1 top 2 bottom -> colour)','MNX-TIBBG','i',['i'],[(1,),(2,)],lambda r:(-1072689136 if r==1 else -804253680,))
def c41(x,y,z,act,idt,sx,sy,sz,rot,ign):
    return (call9('MNX-BODY41',I_(x,y,z,act)+[('t',idt)]+I_(len(idt),sx,sy,sz,rot,ign)),
            position(x,y,z)+varint(act)+(('01'+string(tryparse(idt))) if tryparse(idt) is not None else '00')+varint(sx)+varint(sy)+varint(sz)+varint(rot)+hb(ign)+'00'+'00')
hexcases(g,'7A.4 wire example: Done with id foo, size 3 3 3, rotation 0, entities on: position, 02, 01, 0D minecraft:foo, 03 03 03, 00, 00, 00, 00; QUERY differs only in the action byte; an unparseable id sends the test absent; the empty id sends the key minecraft:',
         [c41(7,8,9,2,'foo',3,3,3,0,0),c41(7,8,9,1,'foo',3,3,3,0,0),c41(7,8,9,2,'Bad Id',1,2,3,1,1),c41(1,1,1,0,'',1,1,1,0,0)])
WX(g,8)
