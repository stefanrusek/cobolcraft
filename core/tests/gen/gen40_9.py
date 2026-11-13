import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40d import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-9-block-editor-screens.md (sections 1 to 9, 10 and 11 as cases of section 9).
# Programs under test: MN9- of core/src/menu-40-9.cob. Texts are one byte per UTF-16 code unit; all text parameters are PIC X(2000) with a length.
EXTRA=(' 01 WS-TC                PIC X(2000).\n 01 WS-TD                PIC X(2000).\n 01 WS-TH                PIC X(2000).\n'
       ' 01 WS-D1                BINARY-DOUBLE.\n 01 WS-D2                BINARY-DOUBLE.\n 01 WS-D3                BINARY-DOUBLE.\n 01 WS-DSH               PIC -(19)9.\n 01 WS-JS.\n'+''.join('    05 WS-J%d BINARY-LONG.\n'%i for i in range(1,9)))
def G9(n,subj,tasks,desc,mod='9'):
    g=GenT('TEST-MENU-40-%s-%d'%(mod,n),'40-%s§%d'%(mod,n),subj,'Test of 40-%s section %d, %s (%s): %s'%(mod,n,subj,tasks,desc))
    g.extra+=EXTRA
    return g
def W9(g,n,mod='9'):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_%s_%d.cob'%(mod,n))
def chunked(g,text,rows,make,mstr,limit=880):
    # one case per chunk of rows whose expected text stays under limit characters
    chunks=[]; cur=[]; ln=0
    for r in rows:
        e=mstr(r)
        if cur and ln+len(e)+1>limit: chunks.append(cur); cur=[]; ln=0
        cur.append(r); ln+=len(e)+1
    if cur: chunks.append(cur)
    for k,c in enumerate(chunks):
        t=text if len(chunks)==1 else text+' (part %d of %d)'%(k+1,len(chunks))
        g.case(t,[make(r) for r in c]," ".join(mstr(r) for r in c))
def irow(fn,name,nin,nout):
    # call of an all-integer program: WS-I1..nin then WS-R1..nout; the result line is the outputs joined by /
    return lambda r:(S(*r),'CALL "%s" USING %s'%(name," ".join(["WS-I%d"%(i+1) for i in range(nin)]+["WS-R%d"%(i+1) for i in range(nout)])),nout)
def ints(g,text,name,nin,nout,rows,model):
    chunked(g,text,rows,irow(model,name,nin,nout),lambda r:out(model(*r)))
def txtmodel_str(s): return s.replace(' ','_') if s else '<>'
def hexl(h): return str(len(h)//2)
def hexs(h): return h if len(h)<=1000 else '#'+str(len(h)//2)
# ===== shared models
def cmdrect(W,H,mc,item):
    c=W//2; py=150 if mc else 135; q=H//4
    t={1:(c-150,50,300,20),2:(c-150,py,276,20),3:(c+130,py,20,20),4:(c-154,165,100,20),5:(c-50,165,100,20),6:(c+54,165,100,20),
       7:(c-154,q+132,150,20),8:(c+4,q+132,150,20),9:(c,20,0,0),10:(c-149,40,0,0),11:(c-149,py-10,0,0)}
    if mc and item in (4,5,6): return (0,0,0,0)
    return t[item]
def strrect(W,H,item):
    c=W//2
    t={1:(c-154,210,150,20),2:(c+4,210,150,20),3:(c+104,185,50,20),4:(c+104,185,50,20),5:(c-154,185,50,20),6:(c+104,120,50,20),7:(c+104,160,50,20),
       8:(c+104,120,50,20),9:(c-20,185,40,20),10:(c+104,80,50,20),11:(c+104,80,50,20),12:(c-102,185,40,20),13:(c-61,185,40,20),14:(c+21,185,40,20),
       15:(c+62,185,40,20),16:(c-152,40,300,20),17:(c-152,80,80,20),18:(c-72,80,80,20),19:(c+8,80,80,20),20:(c-152,120,80,20),21:(c-72,120,80,20),
       22:(c+8,120,80,20),23:(c-152,120,80,20),24:(c-72,120,80,20),25:(c-152,120,240,20)}
    return t[item]
def strvis(mode,item):
    if item in (1,2,5): return 1
    sets={0:(16,17,18,19,20,21,22,3,6,7,10),1:(16,17,18,19,23,24,4,7,8,9,12,13,14,15,11),2:(16,),3:(25,)}
    return 1 if item in sets[mode] else 0
def strlabel(W,mode,item):
    c=W//2
    L={1:(1,c-153,30,0),2:(1,c-153,70,0),3:(1,c+154,150,1),4:(1,c-153,110,0),5:(1,c+154,110,1),6:(1,c+154,70,1),7:(1,c-153,110,0),8:(1,c+154,110,1),9:(1,c+154,70,1),
       10:(1,c-153,110,0),11:(1,c-153,174,0)}
    shown={1:mode!=3,2:mode in (0,1),3:mode in (0,1),4:mode==0,5:mode==0,6:mode==0,7:mode==1,8:mode==1,9:mode==1,10:mode==3,11:True}[item]
    s,x,y,al=L[item]
    return (1 if shown else 0,x,y,al)
def jigrect(W,H,item):
    c=W//2
    t={1:(c-153,20,300,20),2:(c-153,55,300,20),3:(c-153,90,300,20),4:(c-153,125,300,20),5:(c-153,160,98,20),6:(c-50,160,98,20),7:(c+54,160,100,20),
       8:(c-154,185,100,20),9:(c-50,185,100,20),10:(c+54,185,100,20),11:(c-154,210,150,20),12:(c+4,210,150,20)}
    return t[item]
def jiglabel(W,item):
    c=W//2
    return {1:(c-153,10),2:(c-153,45),3:(c-153,80),4:(c-153,115),5:(c-153,150),6:(c-50,150),7:(c+53,150)}[item]
def tbrect(W,H,item):
    c=W//2
    return {1:(c-152,80,240,20),2:(c-154,185,50,20),3:(c-154,210,150,20),4:(c+4,210,150,20)}[item]
# ===== identifier grammar (7A.3)
def valid_path(s): return all(ch in 'abcdefghijklmnopqrstuvwxyz0123456789_-/.' for ch in s)
def valid_ns(s): return all(ch in 'abcdefghijklmnopqrstuvwxyz0123456789_-.' for ch in s) and s!='..'
def tryparse(s):
    i=s.find(':')
    if i<0:
        return 'minecraft:'+s if valid_path(s) else None
    path=s[i+1:]
    if not valid_path(path): return None
    if i==0: return 'minecraft:'+path
    ns=s[:i]
    if not valid_ns(ns): return None
    return ns+':'+path
# ===== encoders
def hb(b): return '%02x'%(b&255)
def varint(v):
    v&=0xFFFFFFFF; o=''
    while True:
        b=v&127; v>>=7
        if v: o+=hb(b|128)
        else: o+=hb(b); return o
def varlong(v):
    v&=0xFFFFFFFFFFFFFFFF; o=''
    while True:
        b=v&127; v>>=7
        if v: o+=hb(b|128)
        else: o+=hb(b); return o
def position(x,y,z): return '%016x'%(((x&0x3FFFFFF)<<38)|((z&0x3FFFFFF)<<12)|(y&0xFFF))
def string(s): return varint(len(s))+s.encode('latin-1').hex()
def f32(v): return struct.pack('>f',v).hex()
def flags(*a):
    f=0
    for bit,v in a:
        if v: f|=bit
    return f
def body37(x,y,z,cmd,mode,track,cond,auto): return position(x,y,z)+string(cmd)+varint(mode)+hb(flags((1,track),(2,cond),(4,auto)))
def body38(eid,cmd,track): return varint(eid)+string(cmd)+hb(track)
def body3b(x,y,z,name,target,pool,final,joint,sp,pp): return position(x,y,z)+string(tryparse(name))+string(tryparse(target))+string(tryparse(pool))+string(final)+string(['rollable','aligned'][joint])+varint(sp)+varint(pp)
def clampf(v,a,b): return min(max(v,a),b)
def body3c(x,y,z,ut,mode,name,ox,oy,oz,sx,sy,sz,mirror,rot,meta,integ,seed,ign,air,bbox,strict):
    return (position(x,y,z)+varint(ut)+varint(mode)+string(name)+hb(ox)+hb(oy)+hb(oz)+hb(sx)+hb(sy)+hb(sz)+varint(mirror)+varint(rot)+string(meta)
            +f32(clampf(integ,0.0,1.0))+varlong(seed)+hb(flags((1,ign),(2,air),(4,bbox),(8,strict))))
def body3d(x,y,z,mode,msg): return position(x,y,z)+varint(mode)+string(msg)
def body1b(x,y,z,levels,keep): return position(x,y,z)+varint(levels)+hb(keep)
# ===== 1
g=G9(1,'Overview','T1105','what each screen sends and when, none opened by a packet (core/src/menu-40-9.cob).')
# how: 1 Done 2 Enter 3 Escape 4 Cancel 5 SAVE 6 LOAD 7 DETECT 8 Generate
def screenpkt(sc,how):
    ok={1:(1,2),2:(1,2),3:(1,2,5,6,7),4:(1,2,8),5:(1,),6:(1,)}[sc]
    pk={1:55,2:56,3:60,4:59,5:61,6:65}[sc]
    if how not in ok: return (0,0)
    return (pk,27 if (sc==4 and how==8) else 0)
rows=[(sc,h) for sc in range(1,6) for h in range(1,9)]
ints(g,'1 table: screen (1 command block 2 minecart 3 structure 4 jigsaw 5 test block) and how it ends (1 Done 2 Enter 3 Escape 4 Cancel 5 SAVE 6 LOAD 7 DETECT 8 Generate) gives the packet id (0x37 0x38 0x3C 0x3B 0x3D) and the second one (0x1B after Generate); Escape and Cancel send nothing; Enter sends from the command, minecart and structure screens, never from the test block screen',
     'MN9-SCREENPKT',2,2,[r for r in rows if r[0]<=5],screenpkt)
ints(g,'1: every screen returns true from isInGameUi (screen 1..5; 6 is the test instance screen of 40-x1, 7 is no screen)','MN9-INGAMEUI',1,1,[(s,) for s in range(0,8)],lambda s:(1 if 1<=s<=6 else 0,))
W9(g,1)
# ===== 2
g=G9(2,'Opening, and who may open','T1107','the permission rule, entity events 24 to 28, the open rules and the server checks.')
def canuse(ib,lv): return 1 if ib==1 and lv>=2 else 0
ints(g,'2.2: canUseGameMasterBlocks needs instabuild and the gamemaster permission (level 2 or more) (instabuild, level 0..4 -> may open)','MN9-CANUSE',2,1,[(i,l) for i in (0,1) for l in range(0,5)],lambda i,l:(canuse(i,l),))
def permevent(e):
    if 24<=e<=28: return (e-24,1 if e-24>=2 else 0)
    return (-1,0)
ints(g,'2.2: entity events 24 to 28 store the permission set 24 empty, 25 moderator, 26 gamemaster, 27 admin, 28 owner (level 24 + n; other ids store nothing: -1) and has-gamemaster follows (event id -> level, has gamemaster)','MN9-PERMEVENT',1,2,[(e,) for e in (23,24,25,26,27,28,29)],permevent)
def permchange(sc,o,n):
    d=1 if (o>=2)!=(n>=2) else 0
    return (d,0)
ints(g,'2.2: setPermissions tells a screen only when has-gamemaster changes and none of the five screens reacts, so an open screen stays open (screen, old level, new level -> changed, screen reacts)','MN9-PERMCHANGE',3,2,[(s,o,n) for s in (1,3,5) for o,n in ((1,2),(2,1),(2,3),(0,1),(4,0))],permchange)
def opens(kind,present,cu,side):
    present=1 if kind==2 else present
    res=1 if (cu and present) else 0
    if not res: return (0,0)
    if side==1: return (1,1)
    return (1,2) if kind==1 else (1,0)
rows=[(k,p,c,s) for k in range(1,7) for p in (0,1) for c in (0,1) for s in (1,2)]
ints(g,'2.1: opening (kind 1 command block 2 minecart 3 structure 4 jigsaw 5 test block 6 test instance, entity present, may use game master blocks, side 1 client 2 server -> result 1 SUCCESS 0 PASS, action 1 client pushes the screen 2 server sends one Block Entity Data 0 nothing); the minecart needs no entity, only the command block sends data',
     'MN9-OPEN',4,2,rows,opens)
def servercheck(pk,cu,tg):
    if pk not in (55,56,59,60,61,27,65): return 0
    if not cu: return 1 if pk in (55,56) else 0
    return 2 if tg else 0
rows=[(pk,c,t) for pk in (55,56,59,60,61,27,65,99) for c in (0,1) for t in (0,1)]
ints(g,'2.3: every handler starts with canUseGameMasterBlocks: 0x37 and 0x38 answer advMode.notAllowed (action 1) when it fails, the others return silently (0); after the test a missing target returns silently; otherwise proceed (2) (packet id, may use, target ok -> action)',
     'MN9-SERVERCHECK',3,1,rows,lambda *a:(servercheck(*a),))
W9(g,2)
# ===== 3
g=G9(3,'Rules shared by the five screens','T1109','Escape, Cancel, Enter, pause and resize.')
def enter(sc,da):
    if sc in (1,2,3): return 1
    if sc==4: return da
    return 0
ints(g,'3 Enter: the command, minecart and structure screens run onDone without testing the Done button; the jigsaw screen only while Done is active; the test block and test instance screens have no keyPressed override (screen, done active -> onDone runs)','MN9-ENTER',2,1,[(s,d) for s in range(1,7) for d in (0,1)],lambda s,d:(enter(s,d),))
ints(g,'3 Escape and Cancel: the same, close with no packet; only the structure screen restores its seven initial values (screen -> restore, packet id)','MN9-ESCAPE',1,2,[(s,) for s in range(1,7)],lambda s:(1 if s==3 else 0,0))
ints(g,'3 Pause: none of the screens overrides isPauseScreen, so the single-player game is paused (screen -> pauses)','MN9-PAUSE',1,1,[(s,) for s in range(1,7)],lambda s:(1,))
def resizekind(sc): return (1 if sc<=4 else 0, 1 if sc==6 else 0)
ints(g,'3 Resize: the command, minecart, structure and jigsaw screens save and restore their texts; the test block and test instance screens are rebuilt from the entity (screen -> keeps typed texts, sends INIT again)','MN9-RESIZEKIND',1,2,[(s,) for s in range(1,7)],resizekind)
W9(g,3)
# ===== 4
g=G9(4,'Command block screens','T1111','rectangles, cycles, enabling, updateGui, previous output, onDone and tick.')
rows=[(W,H,m,i) for W in (400,320,321) for H in (300,240) for m in (0,1) for i in range(1,12)]
chunked(g,'4.1 and 4.2 rectangles x y w h (labels carry x y only; title centred at cx): command box, previous box and track cycle at previousY 135 or 150, mode, type and trigger cycles at y 165, Done and Cancel at H / 4 + 132 (W H minecart item)',rows,
        irow(None,'MN9-CMDRECT',4,4),lambda r:out(cmdrect(r[0],r[1],r[2],r[3])).replace('/','/'))
def cmdvalue(cy,ix,which):
    names={1:'advMode.mode',2:'advMode.type',3:'advMode.triggering',4:'advMode.trackOutput'}
    vals={1:['advMode.mode.sequence','advMode.mode.auto','advMode.mode.redstone'],2:['advMode.mode.conditional','advMode.mode.unconditional'],
          3:['advMode.mode.autoexec.bat','advMode.mode.redstoneTriggered'],4:['O','X']}
    return names[cy] if which==2 else vals[cy][ix]
cases=[(cy,ix,w) for cy,n in ((1,3),(2,2),(3,2),(4,2)) for ix in range(n) for w in (1,2)]
chunked(g,'4.2 cycle values in list order and names (cycle 1 mode 2 type 3 trigger 4 track output, index, 1 value label 2 name key): booleans list true first',cases,
        lambda r:('0',settext('WS-TA','')+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-CMDVALUE" USING WS-I1 WS-I2 WS-I3 WS-TA WS-TL\nPERFORM SHOW-TA'%r,None),
        lambda r:txtmodel_str(cmdvalue(*r)))
def cmdprev(track,outlen):
    if track==0: return (0,1)
    return (1,1 if outlen>0 else 0)
ints(g,'4.1 updatePreviousOutput: the box shows the last output when track is true else - ; both box and label are drawn only when the value is not empty (track, last output length -> kind 0 dash 1 output, drawn)','MN9-CMDPREV',2,2,[(t,l) for t in (0,1) for l in (0,2)],cmdprev)
def cmdgui(track,mode,cond,auto,outlen):
    pk,pd=cmdprev(track,outlen)
    return (1,1-track,mode,1-cond,1-auto,pk,pd)
ints(g,'4.3 updateGui: the five controls become enabled; the cycles take the entity values through setValue (boolean index 0 is true, mode index is the ordinal); the previous box refreshes (track mode conditional automatic last-output-length -> enabled, track index, mode index, type index, trigger index, previous kind, previous drawn)',
     'MN9-CMDGUI',5,7,[(t,m,c,a,l) for t in (0,1) for m in (0,1,2) for c in (0,1) for a in (0,1) for l in ((0,2) if (c+a+m)%2 else (2,))],cmdgui)
def cmdenable(kind,ev):
    if kind==2: return 1
    return {1:0,2:1,3:1}[ev]
ints(g,'4.2 and 4.3 enabling: the block screen starts with Done, track output and the three cycles inactive; data arriving or any resize enables them; the minecart screen is enabled from the start (kind 1 block 2 minecart, event 1 init 2 data 3 resize -> enabled)','MN9-CMDENABLE',2,1,[(k,e) for k in (1,2) for e in (1,2,3)],lambda k,e:(cmdenable(k,e),))
ints(g,'4.1 onDone: after the packet the client copy forgets the last output when tracking is off (track -> clear last output)','MN9-CMDDONE',1,1,[(0,),(1,)],lambda t:(1-t,))
ints(g,'4.1 tick: the screen closes itself with no packet when the shared block object is no longer valid (valid -> closes)','MN9-CMDTICK',1,1,[(0,),(1,)],lambda v:(1-v,))
ints(g,'4.3 refresh test: a Block Entity Data packet refreshes the open screen when the loaded entity is a command block entity and the screen is a command block screen; positions are not compared and the screen reads its own entity (entity is command block, screen is command block screen -> refresh)','MN9-CMDREFRESH',2,1,[(e,s) for e in (0,1) for s in (0,1)],lambda e,s:(e&s,))
consts={1:1,2:1,3:0,4:7,5:0,6:-2147483648,7:32500,8:135,9:150,10:-6250336,11:-1,12:20,13:50,14:300,15:276,16:150}
ints(g,'4.1 constants: suggestions commandsOnly 1, onlyShowIfCursorPastError 1, line start 0, line limit 7, anchored to the bottom 0, fill colour -2147483648, box limit 32500, previousY 135 and 150, label colour -6250336, title colour -1, title y 20, command box y 50, widths 300 and 276, the track cycle 20','MN9-CMDCONST',1,1,[(i,) for i in sorted(consts)],lambda i:(consts[i],))
W9(g,4)
# ===== 5
g=G9(5,'StructureBlockEditScreen','T1113','rectangles, visibility by mode, labels, the name filter, actions, clamps and parsers.')
rows=[(W,H,i) for W in (400,320,321) for H in (300,) for i in range(1,26)]
chunked(g,'5.1 widget rectangles x y w h (item 1 Done 2 Cancel 3 SAVE 4 LOAD 5 mode 6 DETECT 7 include entities 8 strict 9 mirror 10 show air 11 bounding box 12 to 15 rotation 0 90 180 270 16 name 17 to 19 position 20 to 22 size 23 integrity 24 seed 25 custom data) (W H item)',rows,
        irow(None,'MN9-STRRECT',3,4),lambda r:out(strrect(*r)))
ints(g,'5.2 visibility by mode (0 SAVE 1 LOAD 2 CORNER 3 DATA, item of 5.1 -> visible): mode, Done and Cancel always; SAVE: name position size SAVE DETECT include air; LOAD: name position integrity seed LOAD include strict mirror rotations bounding box; CORNER: name; DATA: custom data only','MN9-STRVIS',2,1,[(m,i) for m in range(4) for i in range(1,26)],lambda m,i:(strvis(m,i),))
rows=[(320,m,i) for m in range(4) for i in range(1,12)]
chunked(g,'5.2 labels (W mode label 1 name 2 position 3 include entities 4 size 5 detect 6 show air 7 integrity 8 strict 9 bounding box 10 custom data 11 mode description -> drawn, x, y, right aligned: right edge cx + 154)',rows,
        irow(None,'MN9-STRLABEL',3,4),lambda r:out(strlabel(*r)))
def namechar(t,cur,cp):
    colon=t.find(':'); slash=t.find('/'); c=chr(cp)
    if c==':': return 1 if (colon==-1 and (slash==-1 or cur<=slash)) else 0
    if c=='/': return 1 if cur>colon else 0
    return 1 if (c in '_-.' or 'a'<=c<='z' or '0'<=c<='9') else 0
cases=[]
for t in ('','a','a:b','a:b/c','a/b','house','a:b:c','/a'):
    for cur in sorted(set([0,len(t)//2,len(t)])):
        for ch in ':/aA_-.z09 Z':
            cases.append((t,cur,ord(ch)))
chunked(g,'5.3 name filter on typed characters: colon once and not after a slash, slash only after the colon index, only _ - . a-z 0-9 otherwise, upper case refused (text cursor code point -> accepted)',cases,
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-NAMECHAR" USING WS-TA WS-I1 WS-I2 WS-I3 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(len(r[0]),r[1],r[2]),None),
        lambda r:str(namechar(*r)),limit=400)
ints(g,'5.1 mode lists: the default list has SAVE LOAD CORNER, the list while Alt is held adds DATA (Alt held -> entries)','MN9-STRMODES',1,1,[(0,),(1,)],lambda a:(4 if a else 3,))
def strrot(r): return tuple(0 if r==k else 1 for k in range(4))
ints(g,'5.1 rotation buttons: the button for the entity rotation is inactive, the other three active (rotation 0..3 -> active of 0, 90, 180, 270)','MN9-STRROT',1,4,[(r,) for r in range(4)],strrot)
def stract(how,mode):
    if how in (1,2): return (1,0,1,0)
    if how==3: return (1,1,1,0) if mode==0 else (0,0,0,0)
    if how==4: return (1,2,1,0) if mode==1 else (0,0,0,0)
    if how==5: return (1,3,1,0) if mode==0 else (0,0,0,0)
    return (0,0,1,1)
ints(g,'5.1 and 5.5 actions (1 Done 2 Enter 3 SAVE 4 LOAD 5 DETECT 6 Cancel 7 Escape, entity mode 0 SAVE 1 LOAD 2 CORNER 3 DATA -> packet sent, update type 0 UPDATE_DATA 1 SAVE_AREA 2 LOAD_AREA 3 SCAN_AREA, screen closes, seven initial values restored); SAVE LOAD and DETECT act only in their mode','MN9-STRACT',2,4,[(h,m) for h in range(1,8) for m in range(4)],stract)
def fold(v):
    b=v%256
    return b-256 if b>=128 else b
def strclamp(k,v):
    f=fold(v)
    return min(max(f,-48),48) if k==1 else min(max(f,0),48)
rows=[(k,v) for k in (1,2) for v in (-5,0,5,44,48,49,100,127,128,200,255,256,300,-129,-48,-49,1000,-1000)]
ints(g,'5.4 byte fold then the decoder clamp: offsets -48 to 48, sizes 0 to 48 (kind 1 offset 2 size, typed value -> value read by the server): 300 gives 44, offset 200 gives -48, size 255 gives 0','MN9-STRCLAMP',2,1,rows,lambda k,v:(strclamp(k,v),))
def jint(s,lo,hi):
    import re
    if not re.fullmatch(r'[+-]?[0-9]+',s): return None
    v=int(s)
    return v if lo<=v<=hi else None
texts=['','0','5','-5','+7','abc','12a',' 5','5 ','-','+','--5','007','-0','2147483647','2147483648','-2147483648','-2147483649','99999999999','1.5','0x10','٣']
texts=[t for t in texts if t.isascii()]
cases=[(t,) for t in texts]
def pint(s,d=0):
    v=jint(s,-2147483648,2147483647)
    return d if v is None else v
chunked(g,'5.4 parseCoordinate: Integer.parseInt with 0 on failure: sign and digits only, no spaces, the int range (text -> value; the full Java grammar is recalled, not verified)',cases,
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE %d TO WS-D1\nMOVE 1 TO WS-I2\nMOVE 0 TO WS-D2\nMOVE %d TO WS-I1\nCALL "MN9-PARSENUM" USING WS-TA WS-I1 WS-I2 WS-D2 WS-D3\nMOVE WS-D3 TO WS-DSH\nSTRING FUNCTION TRIM(WS-DSH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%(0,len(r[0])),None),
        lambda r:str(pint(r[0])))
ltexts=['','0','-1','9223372036854775807','9223372036854775808','-9223372036854775808','-9223372036854775809','12345678901234567890','007','x','+3','1 ']
def plong(s,d=0):
    v=jint(s,-9223372036854775808,9223372036854775807)
    return d if v is None else v
chunked(g,'5.4 parseSeed: Long.valueOf with 0 on failure (text -> value)',[(t,) for t in ltexts],
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE 2 TO WS-I2\nMOVE 0 TO WS-D2\nMOVE %d TO WS-I1\nCALL "MN9-PARSENUM" USING WS-TA WS-I1 WS-I2 WS-D2 WS-D3\nMOVE WS-D3 TO WS-DSH\nSTRING FUNCTION TRIM(WS-DSH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%len(r[0]),None),
        lambda r:str(plong(r[0])))
import re
def pfloat(s,d=1.0):
    if not re.fullmatch(r'[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)',s): return d
    return float(s)
ftexts=['','0.5','1','1.0','.5','5.','-0.25','+2','abc','0.5x','1e3','.','-','12.375','0.123456','NaN','1,5',' 1']
chunked(g,'5.4 parseIntegrity: Float.valueOf with 1.0 on failure; plain decimals (sign, digits, one point); shown as the value times 1000000 (text -> value)',[(t,) for t in ftexts],
        lambda r:('0',settext('WS-TA',r[0])+'\nMOVE 1.0 TO WS-FX1\nMOVE %d TO WS-I1\nCALL "MN9-PARSEFLOAT" USING WS-TA WS-I1 WS-FX1 WS-RF1\nCOMPUTE WS-D3 ROUNDED = WS-RF1 * 1000000\nMOVE WS-D3 TO WS-DSH\nSTRING FUNCTION TRIM(WS-DSH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR'%len(r[0]),None),
        lambda r:str(int(round(pfloat(r[0])*1000000))))
cons={1:128,2:15,3:15,4:15,5:31,6:128,7:10,8:-6250336,9:20,10:-1}
ints(g,'5.1 and 9: box limits name 128, position 15, size 15, integrity 15, seed 31, custom data 128; the resize saves ten boxes; label colour; title y 10 and button height 20','MN9-STRCONST',1,1,[(i,) for i in sorted(cons)],lambda i:(cons[i],))
modes=['save','load','corner','data']
cases=[(m,w) for m in range(4) for w in (1,2)]
chunked(g,'5.1 and 5.2 text keys of a mode (mode, 1 cycle label key, 2 description key)',cases,
        lambda r:('0','MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN9-STRMODEKEY" USING WS-I1 WS-I2 WS-TA WS-TL\nPERFORM SHOW-TA'%r,None),
        lambda r:('structure_block.mode.' if r[1]==1 else 'structure_block.mode_info.')+modes[r[0]])
W9(g,5)
# ===== 6
g=G9(6,'JigsawBlockEditScreen','T1115','rectangles, labels, joint visibility, the Identifier grammar, validity, levels and the resize slider.')
rows=[(W,H,i) for W in (400,320,321) for H in (300,) for i in range(1,13)]
chunked(g,'6 widget rectangles x y w h (1 pool 2 name 3 target 4 final state 5 selection priority 6 placement priority 7 joint 8 levels slider 9 keep jigsaws 10 Generate 11 Done 12 Cancel) (W H item)',rows,irow(None,'MN9-JIGRECT',3,4),lambda r:out(jigrect(*r)))
rows=[(W,i) for W in (400,320) for i in range(1,8)]
chunked(g,'6 labels x y (1 pool 2 name 3 target 4 final state 5 selection priority 6 placement priority 7 joint) (W label)',rows,irow(None,'MN9-JIGLABEL',2,2),lambda r:out(jiglabel(*r)))
ints(g,'6 joint cycle and its label are visible and active only when the block front direction is vertical (direction 0 down 1 up 2 north 3 south 4 west 5 east; item 7 joint 13 joint label 1 other -> visible and active)','MN9-JIGVIS',2,1,[(i,d) for i in (7,13,1) for d in range(6)],lambda i,d:((1 if d<2 else 0) if i in (7,13) else 1,))
idtexts=['','foo','minecraft:foo',':foo','a:b:c','Foo','a b','a:Foo','x-y_z.0/9','ns.a-b:p/q.r','..:a','.:a','a..:b','a:','a/b:c','a:b/c','foo:','a*b','_:_','UP:down','m:']
def identcode(t): return settext('WS-TA',t)+'\nMOVE %d TO WS-I1\nCALL "MN9-IDENT" USING WS-TA WS-I1 WS-R1 WS-TB WS-R2\nMOVE 1 TO WS-N\nPERFORM ADD-N\nMOVE WS-TB TO WS-TA\nMOVE WS-R2 TO WS-TL\nPERFORM SHOW-TA'%len(t)
def identstr(t):
    p=tryparse(t)
    return '%d %s'%(1 if p is not None else 0,txtmodel_str(p) if p is not None else '<>')
chunked(g,'6 and 7A.3 Identifier.tryParse: split at the first colon; the path takes a-z 0-9 _ - / . (the empty text passes), the namespace a-z 0-9 _ - . but never ..; no colon or a colon at 0 is minecraft; the result text always has the namespace (text -> ok, parsed text)',[(t,) for t in idtexts],lambda r:('0',identcode(r[0]),None),lambda r:identstr(r[0]))
def valid3(a,b,c): return 1 if tryparse(a) is not None and tryparse(b) is not None and tryparse(c) is not None else 0
trip=[('a','b','c'),('minecraft:bad pool','b','c'),('a','B','c'),('a','b','x:y:z'),('','',''),('a:b','c:d','e:f')]
chunked(g,'6 validity: Done and Generate are active only while name, target and pool each parse; the final state and priorities are not validated; Enter runs onDone only while Done is active (name target pool -> valid)',trip,
        lambda r:('0',settext('WS-TA',r[0])+'\n'+settext('WS-TB',r[1])+'\n'+settext('WS-TC',r[2])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-JIGVALID" USING WS-TA WS-I1 WS-TB WS-I2 WS-TC WS-I3 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(len(r[0]),len(r[1]),len(r[2])),None),
        lambda r:str(valid3(*r)))
vals=[0.0,0.04,0.06,0.049,0.5,0.51,0.999,1.0,-0.5,1.5,0.25,0.75,0.93]
def levels(v):
    v=min(max(v,0.0),1.0); return int(math.floor(20*v))
chunked(g,'6 levels slider: levels = floor(20 * value) after clamping the value to 0..1, so 0 to 20; 0.5 gives 10 and 0.999 gives 19 (value -> levels)',[(v,) for v in vals],
        lambda r:(S(r[0]),'CALL "MN9-JIGLEVELS" USING WS-FX1 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N',None),lambda r:str(levels(r[0])))
ints(g,'6.5 resize: the slider is rebuilt at value 0.0 while its label shows the restored levels, the joint cycle is set with setValue (levels, joint -> slider value x 100, label levels, joint)','MN9-JIGRESIZE',2,3,[(l,j) for l in (0,7,20) for j in (0,1)],lambda l,j:(0,l,j))
cases=[(0,),(1,)]
chunked(g,'6 joint value label keys (index)',cases,lambda r:('0','MOVE %d TO WS-I1\nCALL "MN9-JIGJOINTTEXT" USING WS-I1 WS-TA WS-TL\nPERFORM SHOW-TA'%r[0],None),lambda r:'jigsaw_block.joint.'+['rollable','aligned'][r[0]])
cons={1:128,2:128,3:128,4:256,5:3,6:3,7:20,8:0,9:1}
ints(g,'6 limits: identifier boxes 128, final state 256, priority boxes 3, levels 0 to 20 (20 is the maximum), the slider starts at 0, keep jigsaws starts true (1)','MN9-JIGCONST',1,1,[(i,) for i in sorted(cons)],lambda i:(cons[i],))
W9(g,6)
# ===== 7
g=G9(7,'TestBlockEditScreen','T1117','rectangles, labels, message visibility, the resize rule and mode texts.')
rows=[(W,H,i) for W in (400,320,321) for H in (300,) for i in range(1,5)]
chunked(g,'7 widget rectangles x y w h (1 message box 2 mode cycle 3 Done 4 Cancel) (W H item)',rows,irow(None,'MN9-TBRECT',3,4),lambda r:out(tbrect(*r)))
def tblabel(W,mode,item):
    c=W//2
    return {1:(1,c,10),2:(1 if mode!=0 else 0,c-153,70),3:(1,c-153,174)}[item]
rows=[(W,m,i) for W in (400,320) for m in range(4) for i in (1,2,3)]
chunked(g,'7 labels (W mode item 1 title centred at cx 2 Message: 3 mode description -> drawn x y): the message label only when the mode is not START, the description always at y 174',rows,irow(None,'MN9-TBLABEL',3,3),lambda r:out(tblabel(*r)))
ints(g,'7 message box visible only when the mode is not START (mode 0 START 1 LOG 2 FAIL 3 ACCEPT -> visible)','MN9-TBVIS',1,1,[(m,) for m in range(4)],lambda m:(1 if m else 0,))
names=['start','log','fail','accept']
cases=[(m,w) for m in range(4) for w in (1,2)]
chunked(g,'7 mode text keys (mode, 1 cycle label key test_block.mode.<name>, 2 description key test_block.mode_info.<name>)',cases,
        lambda r:('0','MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN9-TBKEY" USING WS-I1 WS-I2 WS-TA WS-TL\nPERFORM SHOW-TA'%r,None),
        lambda r:('test_block.mode.' if r[1]==1 else 'test_block.mode_info.')+names[r[0]])
rs=[('hello','typed'),('','typed'),('abc','')]
chunked(g,'7 resize: no resize override, so the message box is rebuilt from the message field that only Done writes; text typed before the resize is lost (stored typed -> shown)',rs,
        lambda r:('0',settext('WS-TA',r[0])+'\n'+settext('WS-TB',r[1])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN9-TBRESIZE" USING WS-TA WS-I1 WS-TB WS-I2 WS-TC WS-R1\nMOVE WS-TC TO WS-TA\nMOVE WS-R1 TO WS-TL\nPERFORM SHOW-TA'%(len(r[0]),len(r[1])),None),
        lambda r:txtmodel_str(r[0]))
cons={1:128,2:3,3:10,4:174,5:70,6:-6250336}
ints(g,'7 constants: message limit 128, the highest mode id 3 (START LOG FAIL ACCEPT), title y 10, description y 174, message label y 70, label colour','MN9-TBCONST',1,1,[(i,) for i in sorted(cons)],lambda i:(cons[i],))
W9(g,7)
# ===== 8
g=G9(8,'Packets sent','T1119','the packet bodies as hex (position, VarInt, strings, flags) and the limits table.')
def FL(v): return '%.12f'%v
def call9(prog,toks,hexout=True):
    # toks: ('i',v) ints (WS-I1..16 then WS-J1..), ('t',s) texts (WS-TA..TD), ('f',v) floats (WS-FX1..), ('d',v) doubles (WS-D1..)
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
    return "\n".join(pre)+'\nCALL "%s" USING %s WS-TH WS-R1'%(prog," ".join(use))
def hexshow(c,e):
    return (c+'\nMOVE WS-TH TO WS-TA\nCOMPUTE WS-TL = WS-R1 * 2\nPERFORM SHOW-TA',e)
def hexlong(c,e):
    return (c+'\nMOVE WS-R1 TO WS-D3\nMOVE WS-D3 TO WS-DSH\nSTRING "#" FUNCTION TRIM(WS-DSH) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR','#%d'%(len(e)//2))
def hexcases(g,text,items):
    calls=[]; exp=[]
    for c,e in items:
        code,ex=(hexshow(c,e) if len(e)<=200 else hexlong(c,e))
        calls.append(('0',code,None)); exp.append(ex)
    g.case(text,calls," ".join(exp))
I_=lambda *a:[('i',v) for v in a]
def c37(x,y,z,cmd,mode,track,cond,auto):
    return (call9('MN9-BODY37',I_(x,y,z)+[('t',cmd)]+I_(len(cmd),mode,track,cond,auto)),body37(x,y,z,cmd,mode,track,cond,auto))
items=[c37(0,64,0,'say hi',1,1,1,0),c37(-1,-64,-30000000,'',2,0,0,0),c37(100,319,-5,'x'*127,0,0,0,1),c37(100,319,-5,'y'*128,0,1,0,1),c37(33554431,2047,33554431,'a b',2,1,1,1)]
hexcases(g,'8 0x37 Set Command Block: Position, Command (VarInt length and bytes), Mode (VarInt), Flags (0x01 track output, 0x02 conditional, 0x04 automatic); an empty command sends one length byte 00',items)
def c38(eid,cmd,tr): return (call9('MN9-BODY38',I_(eid)+[('t',cmd)]+I_(len(cmd),tr)),body38(eid,cmd,tr))
hexcases(g,'8 0x38 Set Command Minecart: entity id (VarInt), command, track output (boolean)',[c38(5,'say hi',1),c38(300,'',0),c38(1000000,'tp @s ~ ~ ~',1)])
def c3b(x,y,z,n,t,p,f,j,sp,pp):
    return (call9('MN9-BODY3B',I_(x,y,z)+[('t',n)]+I_(len(n))+[('t',t)]+I_(len(t))+[('t',p)]+I_(len(p))+[('t',f)]+I_(len(f),j,sp,pp)),body3b(x,y,z,n,t,p,f,j,sp,pp))
hexcases(g,'8 0x3B Set Jigsaw Block: Position, name, target and pool as identifiers (always with the namespace), final state, joint text rollable or aligned, selection and placement priority (VarInt, a negative value takes five bytes)',
         [c3b(1,2,3,'a','b','c','minecraft:air',0,0,0),c3b(1,2,3,'x:name','y:target','pool/x','',1,-5,999),c3b(-7,0,9,':n','t','p','stone[x=1]',0,-99,5)])
def c3c(x,y,z,ut,mode,name,ox,oy,oz,sx,sy,sz,mirror,rot,meta,integ,seed,ign,air,bbox,strict):
    return (call9('MN9-BODY3C',I_(x,y,z,ut,mode)+[('t',name)]+I_(len(name),ox,oy,oz,sx,sy,sz,mirror,rot)+[('t',meta)]+I_(len(meta))+[('f',integ),('d',seed)]+I_(ign,air,bbox,strict)),
            body3c(x,y,z,ut,mode,name,ox,oy,oz,sx,sy,sz,mirror,rot,meta,integ,seed,ign,air,bbox,strict))
hexcases(g,'8 0x3C Set Structure Block: Position, update type, mode, name, offset X Y Z and size X Y Z as single low bytes (a typed 300 is written as 44, -5 as fb), mirror, rotation, metadata, integrity (float32 clamped 0 to 1), seed (VarLong), flags 0x01 ignore 0x02 air 0x04 bounding box 0x08 strict',
         [c3c(0,64,0,0,0,'house',0,1,0,5,5,5,0,0,'',1.0,0,0,0,0,0),c3c(3,4,5,1,1,'a:b',-5,48,-48,300,0,48,2,3,'meta',0.5,123456789,1,1,1,1),c3c(-1,-1,-1,3,2,'',200,255,0,255,100,-1,1,2,'d',0.25,-1,0,1,0,1),c3c(1,1,1,2,3,'n',0,0,0,0,0,0,0,0,'m',2.0,-5,1,0,0,0)])
def c3d(x,y,z,mode,msg): return (call9('MN9-BODY3D',I_(x,y,z,mode)+[('t',msg)]+I_(len(msg))),body3d(x,y,z,mode,msg))
hexcases(g,'8 0x3D Set Test Block: Position, mode (VarInt 0 to 3), message; the message is sent whatever the mode, with the hidden box text when the mode is START',[c3d(0,0,0,0,'hello'),c3d(5,6,7,1,'hello'),c3d(-5,6,-7,3,''),c3d(1,2,3,2,'z'*130)])
def c1b(x,y,z,l,k): return (call9('MN9-BODY1B',I_(x,y,z,l,k)),body1b(x,y,z,l,k))
hexcases(g,'8 0x1B Jigsaw Generate: Position, levels (VarInt 0 to 20), keep jigsaws (boolean); sent after 0x3B',[c1b(1,2,3,0,1),c1b(-1,70,-1,20,0),c1b(30000000,-64,-30000000,13,1)])
def cvar(v): return (call9('MN9-VARINTHEX',I_(v)),varint(v))
hexcases(g,'8 VarInt: seven bits a byte, high bit set while more follow, a negative value takes five bytes',[cvar(v) for v in (0,1,127,128,255,300,16384,2097151,2147483647,-1,-5,-2147483648)])
def cvl(v): return (call9('MN9-VARLONGHEX',[('d',v)]),varlong(v))
hexcases(g,'8 VarLong: seven bits a byte up to ten bytes for a negative value',[cvl(v) for v in (0,1,127,128,123456789,4294967296,9223372036854775807,-1,-5)])
def cpos(x,y,z): return (call9('MN9-POSHEX',I_(x,y,z)),position(x,y,z))
hexcases(g,'8 Position: X in bits 38 to 63, Z in 12 to 37, Y in 0 to 11, each masked two complement (00 section 4.1)',[cpos(*p) for p in ((0,0,0),(1,2,3),(-1,-1,-1),(30000000,-64,-30000000),(-30000000,2047,29999999),(0,-2048,0))])
def cflt(v): return (call9('MN9-FLOATHEX',[('f',v)]),f32(v))
hexcases(g,'8 Float: IEEE binary32 big-endian (integrity values)',[cflt(v) for v in (0.0,1.0,0.5,0.25,0.1,0.123456,-1.0,2.5,0.75,1e-5,100.0,0.99999999)])
rows=[(t,c,a) for t in (0,1) for c in (0,1) for a in (0,1)]
ints(g,'8 0x37 flags byte: 0x01 track output, 0x02 conditional, 0x04 automatic (track, conditional, automatic -> byte)','MN9-CMDFLAGS',3,1,rows,lambda t,c,a:(t+2*c+4*a,))
rows=[(i,a,b,s) for i in (0,1) for a in (0,1) for b in (0,1) for s in (0,1)]
ints(g,'8 0x3C flags byte: 0x01 ignore entities, 0x02 show air, 0x04 show bounding box, 0x08 strict (ignore, air, bounding box, strict -> byte)','MN9-STRFLAGS',4,1,rows,lambda i,a,b,s:(i+2*a+4*b+8*s,))
lim={1:(32500,32767),2:(32500,32767),3:(128,32767),4:(128,128),5:(15,0),6:(31,0),7:(128,32767),8:(256,32767),9:(3,0),10:(128,32767),11:(32500,32767)}
ints(g,'8 limits (1 command box 2 minecart command 3 structure name 4 structure metadata 5 structure number boxes 6 seed 7 jigsaw identifiers 8 final state 9 priorities 10 test block message 11 previous output box -> screen limit, wire limit; 0 no string limit)','MN9-LIMIT',1,2,[(i,) for i in sorted(lim)],lambda i:lim[i])
W9(g,8)
# ===== 9
g=G9(9,'Cross-check with 40-x1, and what is new here','T1121','each cross-check item and the worked examples of section 10 re-run through the programs.')
# item 1: resize of the test block screen loses the message
chunked(g,'9.1 and 7: the test block screen resize loses the typed message and keeps the chosen mode (stored typed -> shown)',[('open','typed'),('last done','new typing')],
        lambda r:('0',settext('WS-TA',r[0])+'\n'+settext('WS-TB',r[1])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN9-TBRESIZE" USING WS-TA WS-I1 WS-TB WS-I2 WS-TC WS-R1\nMOVE WS-TC TO WS-TA\nMOVE WS-R1 TO WS-TL\nPERFORM SHOW-TA'%(len(r[0]),len(r[1])),None),
        lambda r:txtmodel_str(r[0]))
ints(g,'9.2: none of the five screens reacts when the player loses the gamemaster permission; the server rejection is the only defence (screen, old level, new level -> changed, reacts)','MN9-PERMCHANGE',3,2,[(s,2,1) for s in range(1,6)],lambda s,o,n:(1,0))
ints(g,'9.3: the client needs both instabuild and the gamemaster permission, levels from entity events 24 + level (instabuild, level -> may open)','MN9-CANUSE',2,1,[(1,1),(1,2),(0,2),(0,4),(1,4)],lambda i,l:(canuse(i,l),))
ints(g,'9.4: isPauseScreen true and Escape allowed on every screen (screen -> pauses)','MN9-PAUSE',1,1,[(s,) for s in range(1,6)],lambda s:(1,))
ints(g,'9.5: a Block Entity Data packet for another command block refreshes the screen from its own entity (entity is command block, screen is command block screen -> refresh)','MN9-CMDREFRESH',2,1,[(1,1),(1,0),(0,1)],lambda e,s:(e&s,))
ints(g,'9.6: Screen.resize rebuilds through init for the screens without an override; the three with an override call init themselves (screen -> keeps texts, sends INIT)','MN9-RESIZEKIND',1,2,[(s,) for s in range(1,7)],resizekind)
ints(g,'9.7: the packet classes agree with 05c: a typed 300 is written as a low byte and decoded to 44, 255 as a size reads -1 and clamps to 0 (kind, value -> value read)','MN9-STRCLAMP',2,1,[(2,300),(1,200),(2,255),(1,-5)],lambda k,v:(strclamp(k,v),))
ints(g,'9.8: the structure screen saves and restores ten boxes (name, three position, three size, integrity, seed, custom data) (id 7 -> count)','MN9-STRCONST',1,1,[(7,)],lambda i:(10,))
rows=[(400,300,m,i) for m in (0,1) for i in range(1,12)]
chunked(g,'10.1 worked example W 400 H 300: command box x 50 y 50, previous box x 50 to 326 y 135, track x 330, cycles x 46 150 254 at y 165, Done 46 207, Cancel 204 207; the minecart previous box at y 150 and label y 140 with no mode cycles (W H minecart item)',rows,irow(None,'MN9-CMDRECT',4,4),lambda r:out(cmdrect(*r)))
rows=[(400,300,i) for i in range(1,26)]
chunked(g,'10.2 worked example structure block at W 400: name x 48, positions 48 128 208, SAVE x 304, mode cycle x 46, rotation buttons x 98 139 221 262, mirror x 180 (W H item)',rows,irow(None,'MN9-STRRECT',3,4),lambda r:out(strrect(*r)))
rows=[(400,300,i) for i in range(1,13)]
chunked(g,'10.3 worked example jigsaw at W 400: pool x 47, priorities x 47 and 150, joint x 254, slider x 46, keep jigsaws x 150, Generate x 254, Done x 46, Cancel x 204 (W H item)',rows,irow(None,'MN9-JIGRECT',3,4),lambda r:out(jigrect(*r)))
rows=[(400,300,i) for i in range(1,5)]
chunked(g,'10.4 worked example test block at W 400: message box x 48 y 80 240 wide, mode cycle x 46, Done 46 and Cancel 204 at y 210 (W H item)',rows,irow(None,'MN9-TBRECT',3,4),lambda r:out(tbrect(*r)))
hexcases(g,'10.5 race: Enter on the command block screen before data arrived sends mode 2 (REDSTONE), flags 0 and the empty command; the server rebuilds an impulse non-conditional block',[c37(0,64,0,'',2,0,0,0)])
ints(g,'10.5 race: Enter runs onDone although Done is still greyed (screen 1, done active 0 -> onDone runs) and the controls start disabled','MN9-ENTER',2,1,[(1,0)],lambda s,d:(1,))
chunked(g,'10.6 jigsaw with pool minecraft:bad pool: tryParse fails on the space, Done and Generate are inactive, Enter does nothing (name target pool -> valid)',[('a','b','minecraft:bad pool')],
        lambda r:('0',settext('WS-TA',r[0])+'\n'+settext('WS-TB',r[1])+'\n'+settext('WS-TC',r[2])+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN9-JIGVALID" USING WS-TA WS-I1 WS-TB WS-I2 WS-TC WS-I3 WS-R1\nMOVE WS-R1 TO WS-I4\nMOVE 4 TO WS-I5\nMOVE 0 TO WS-R2\nCALL "MN9-ENTER" USING WS-I5 WS-I4 WS-R2\nMOVE 2 TO WS-N\nPERFORM ADD-N'%(len(r[0]),len(r[1]),len(r[2])),None),
        lambda r:'0/0')
ints(g,'10.7 permission: a creative player with level 1 (entity event 25) gets PASS and no screen from a structure block use; with level 2 (event 26) the screen opens; if the level drops to 1 the screen stays open and Done sends 0x3C which the server drops without a message (event, instabuild -> level, may open)','MN9-PERMOPEN',2,2,[(25,1),(26,1),(25,0),(28,1)],lambda e,i:(e-24,canuse(i,e-24)))
ints(g,'10.7: the server drops 0x3C silently after the level drops to 1 (packet 60, may use 0, target 1 -> action 0 silent stop)','MN9-SERVERCHECK',3,1,[(60,0,1)],lambda *a:(servercheck(*a),))
W9(g,9)
