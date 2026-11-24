import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40d import *
ONLY=set(a for a in sys.argv[1:])
# Independent Python models of docs/protocol/40-menus-8-book-and-sign-editors.md (sections 1 to 7; the validation examples of section 8 are cases of the sections they exercise).
# Texts are one byte per UTF-16 code unit; every glyph advance is the uniform fixture advance of section 8 (real advances are 12 section 5.10).
def G8(n,subj,tasks,desc,ed=False,fld=False):
    return GenT('TEST-MENU-40-8-%d'%n,'40-8§%d'%n,subj,'Test of 40-8 section %d, %s (%s): %s'%(n,subj,tasks,desc),ed,fld)
def W(g,n):
    if not ONLY or str(n) in ONLY: g.write(OUT+'/test_menu_40_8_%d.cob'%n)
# ===== 1
g=G8(1,'Overview and how each screen is opened','T1091','who opens which screen, what a close sends (core/src/menu-40-8.cob).')
def opengui(side,wr,wn):
    if side==1: return 1 if wr else 0
    return 2 if wn else 0
rowcase(g,'1.1: openItemGui acts per side: the client pushes BookEditScreen only for a stack with writable_book_content (1), the server acts only for written_book_content and sends Open Book 0x3B (2), a writable book makes the server send nothing (side 1 client 2 server, writable content, written content -> action)',[(s,w,n) for s in (1,2) for w in (0,1) for n in (0,1)],'CALL "MN8-OPENGUI" USING WS-I1 WS-I2 WS-I3 WS-R1',1,opengui)
def openbook(wn,wr): return 1 if wn else (2 if wr else 0)
rowcase(g,'1.1 handleOpenBook: a written_book_content gives the pages as text (1), else a writable_book_content literal pages (2), else nothing opens (0) (written, writable -> source)',[(a,b) for a in (0,1) for b in (0,1)],'CALL "MN8-OPENBOOK" USING WS-I1 WS-I2 WS-R1',1,openbook)
def opensign(be,h): return 0 if not be else (2 if h else 1)
rowcase(g,'1.2 handleOpenSignEditor: a client block entity that is a sign opens SignEditScreen (1) or HangingSignEditScreen (2) for a hanging one; any other entity logs a warning and opens nothing (0) (is a sign entity, is hanging -> screen)',[(0,0),(0,1),(1,0),(1,1)],'CALL "MN8-OPENSIGN" USING WS-I1 WS-I2 WS-R1',1,opensign)
def closep(sc,how):
    if sc==1: return (24,0) if how==1 else (0,0)
    if sc==2: return (24,1) if how in (1,2) else (0,0)
    return (62,0)
rows=[(sc,h) for sc in (1,2,3) for h in (1,2,3,4)]
rowcase(g,'1 overview table: BookEditScreen sends 0x18 without a title only by Done; BookSignScreen sends 0x18 with the title by Sign and Close or Enter (how 1, 2), Cancel and Escape send nothing; a sign editor always sends 0x3E when it is removed (screen 1 book edit 2 book sign 3 sign edit; how 1 Done or Sign and Close 2 Enter in the title field 3 Escape 4 Cancel or any other removal -> packet id, title present)',rows,'CALL "MN8-CLOSE" USING WS-I1 WS-I2 WS-R1 WS-R2',2,closep)
W(g,1)
# ===== 2 models
def allowed(c): return c>=32 and c!=127 and c!=167
def filt(s,nl): return ''.join(ch for ch in s if allowed(ord(ch)) or (nl and ch=='\n'))
def split_lines(t,wd,adv):
    lim=max(wd,1); res=[]; start=0; n=len(t)
    while start<n:
        i=start; last=None; nz=False; w=0; brk=None
        while i<n:
            c=t[i]
            if c=='\n': brk=i; break
            if c==' ': last=i
            w+=adv
            if nz and w>lim:
                brk=last if last is not None else i; break
            nz=nz or adv>0
            i+=1
        if brk is None: res.append((start,n)); start=n
        else:
            res.append((start,brk)); start=brk+1 if t[brk] in ' \n' else brk
    return res
def views(t,wd,adv):
    if not t: return [(0,0)]
    r=split_lines(t,wd,adv)
    if t[-1]=='\n': r.append((len(t),len(t)))
    return r
def ends_nl(t): return 1 if t and ord(t[-1]) in (10,11,12,13,133) else 0
def ovcount(t,wd,adv): return len(views(t,wd,adv))-(1 if t and t[-1]=='\n' else 0)+ends_nl(t)
def lineat(vs,c):
    for i,(b,e) in enumerate(vs):
        if b<=c<=e: return i
    return len(vs)-1
class St:
    def __init__(s,t,cur=None,anc=None,cl=1024,ll=14,wd=114,adv=6,clip=''):
        s.t=t; s.cur=len(t) if cur is None else cur; s.anc=s.cur if anc is None else anc; s.cl=cl; s.ll=ll; s.wd=wd; s.adv=adv; s.clip=clip; s.chg=0; s.hand=0
    def views(s): return views(s.t,s.wd,s.adv)
def insert(s,ins):
    sel=s.cur!=s.anc
    if ins=='' and not sel: return
    f=filt(ins,True)[:max(s.cl-len(s.t),0)]
    a=min(s.cur,s.anc); b=max(s.cur,s.anc)
    cand=s.t[:a]+f+s.t[b:]
    if ovcount(cand,s.wd,s.adv)>s.ll: return
    s.t=cand; s.cur=s.anc=a+len(f); s.chg=1
def setvalue(s,v,force):
    v=v[:s.cl]
    if not force and ovcount(v,s.wd,s.adv)>s.ll: return
    s.t=v; s.cur=s.anc=len(v); s.chg=1
ws=lambda c: c in ' \t\n\x0b\x0c\r\x1c\x1d\x1e\x1f'
def prevword(t,c):
    if not t: return (0,0)
    i=min(max(c,0),len(t)-1)
    while i>0 and ws(t[i-1]): i-=1
    while i>0 and not ws(t[i-1]): i-=1
    j=i
    while j<len(t) and not ws(t[j]): j+=1
    return (i,j)
def nextword(t,c):
    if not t: return 0
    i=min(max(c,0),len(t)-1)
    while i<len(t) and not ws(t[i]): i+=1
    while i<len(t) and ws(t[i]): i+=1
    return i
def idxat(t,b,e,budget,adv):
    n=0
    for _ in range(e-b):
        budget-=adv
        if budget<0: break
        n+=1
    return n
def seek(s,dy):
    vs=s.views(); i=lineat(vs,s.cur); target=(s.cur-vs[i][0])*s.adv+2
    j=min(max(i+dy,0),len(vs)-1); b,e=vs[j]
    return b+idxat(s.t,b,e,target,s.adv)
def delete(s,n):
    if s.cur==s.anc: s.anc=min(max(s.cur+n,0),len(s.t))
    insert(s,'')
def move(s,pos,shift):
    s.cur=pos
    if not shift: s.anc=pos
def key(s,kc,mods,mac):
    shift=bool(mods&3); alt=bool(mods&768); sc=bool(mods&(3072 if mac else 192))
    s.hand=1; sel=lambda: s.t[min(s.cur,s.anc):max(s.cur,s.anc)]
    if kc==97 and sc and not shift and not alt: s.cur=len(s.t); s.anc=0
    elif kc==99 and sc and not shift and not alt: s.clip=sel()
    elif kc==118 and sc and not shift and not alt: insert(s,s.clip)
    elif kc==120 and sc and not shift and not alt: s.clip=sel(); insert(s,'')
    elif kc==8:
        if sc: delete(s,prevword(s.t,s.cur)[0]-s.cur)
        else: delete(s,-1)
    elif kc==127:
        if sc: delete(s,nextword(s.t,s.cur)-s.cur)
        else: delete(s,1)
    elif kc in (13,1073741912): insert(s,'\n')
    elif kc==1073741904: move(s,prevword(s.t,s.cur)[0] if sc else max(s.cur-1,0),shift)
    elif kc==1073741903: move(s,nextword(s.t,s.cur) if sc else min(s.cur+1,len(s.t)),shift)
    elif kc in (1073741906,1073741905):
        if not sc: move(s,seek(s,-1 if kc==1073741906 else 1),shift)
    elif kc==1073741898:
        move(s,0 if sc else s.views()[lineat(s.views(),s.cur)][0],shift)
    elif kc==1073741901:
        move(s,len(s.t) if sc else s.views()[lineat(s.views(),s.cur)][1],shift)
    elif kc==1073741899: move(s,0,shift)
    elif kc==1073741902: move(s,len(s.t),shift)
    else: s.hand=0
def point(s,mx,my,bx,by,scroll):
    x=math.floor(mx-bx-4); y=my-by-4+scroll
    vs=s.views(); ln=min(max(math.floor(y/9),0),len(vs)-1); b,e=vs[ln]
    return b+idxat(s.t,b,e,x,s.adv)
def click(s,mx,my,bx,by,scroll,mode,shift):
    if mode==2:
        b,e=prevword(s.t,s.cur); s.anc=b; s.cur=e
    elif mode==1:
        move(s,point(s,mx,my,bx,by,scroll),shift)
    else: s.cur=point(s,mx,my,bx,by,scroll)
def lines_str(vs): return "".join('%d-%d,'%v for v in vs)+" "
# ===== 2 cases
g=G8(2,'The book page editor engine','T1093','character rules, wrapping, limits, keys, words, vertical motion, mouse and drawing rules (core/src/menu-40-8.cob).',True)
rowcase(g,'2.2: a typed character is allowed when its code point is 32 or more, not 127 and not 167 (the section sign) (code point -> allowed)',[(c,) for c in (0,9,10,13,31,32,65,126,127,128,166,167,168,255,8232)],'CALL "MN8-ALLOWED" USING WS-I1 WS-R1',1,lambda c:int(allowed(c)))
def filtcase(texts,nl):
    calls=[]; exp=""
    for t in texts:
        calls.append(("0",settext('WS-TA',t)+'\nMOVE %d TO WS-TL\nMOVE %d TO WS-J\nMOVE SPACES TO WS-TB\nCALL "MN8-FILTER" USING WS-TA WS-TL WS-J WS-TB WS-R1\nMOVE WS-TB TO WS-TA\nMOVE WS-R1 TO WS-TL\nPERFORM SHOW-TA'%(len(t),nl),None))
        exp+=txt(filt(t,nl))
    return calls,exp
T=["ab\tc\x01d\xa7e\nf\rg","","\t\r\x0b","plain text 123","\n\nx\xa7\xa7y","a"+chr(127)+"z\xa7"]
c,e=filtcase(T,1); g.case('2.2 filterText with newline allowed keeps allowed characters and the line feed and drops tab, carriage return, controls, the section sign and 127 (texts printed with _ for a space, <> for empty)',c,e)
c,e=filtcase(T,0); g.case('2.2 the same text filtered without line feeds (the single-line fields) drops the line feed too',c,e)
def wrapcalls(items):
    calls=[];exp=""
    for (t,wd,adv) in items:
        calls.append(("0",ed(t,wd=wd,adv=adv)+'\nCALL "MN8-WRAP" USING MN8-ED MN8-LINES WS-R1\nPERFORM SHOW-LINES',None))
        exp+=lines_str(views(t,wd,adv))
    return calls,exp
c,e=wrapcalls([("a"*25,114,6),("hello world foo",66,6),("ab\n",114,6),("",114,6),("\n",114,6),("a b",114,6)])
g.case('2.3 and 8 examples 1 to 3: 25 letters at width 114 and advance 6 break at index 19 (lines 0-19 and 19-25); "hello world foo" at width 66 breaks at the space 11 and the next line starts at 12; "ab" + line feed gives 0-2 and the extra empty view 3-3; empty text is the single view 0-0',c,e)
c,e=wrapcalls([("a  b  c",12,6),("aaa bbb ccc",24,6),("x"*7,1,6),("ab cd",0,6),("   ",6,6),(" a b",12,6),("abcdefgh",100,0),("ab\ncd\n\nef",114,6),("ab cdefgh ij",36,6),("aaaaaa bb",30,6),("ab  cd  ef",18,6)])
g.case('2.3 consequences: a space that overflows the limit is consumed on the line it overhangs; consecutive spaces break after only the first; a long word breaks mid-word; the first character of a line always fits however wide; the limit is at least 1; advance 0 never breaks; line feeds consume themselves',c,e)
def ovcalls(items):
    calls=[];exp=""
    for t in items:
        calls.append(("0",ed(t)+'\nCALL "MN8-LINECOUNT" USING MN8-ED WS-R1 WS-R2 WS-R3',3 if False else None))
        calls[-1]=("0",calls[-1][1]+'\nMOVE 3 TO WS-N\nPERFORM ADD-N',None)
        exp+=nums(len(views(t,114,6)),ovcount(t,114,6),ends_nl(t))
    return calls,exp
c,e=ovcalls(["ab","ab\n","ab\r","ab\x0b","ab\x0c","ab\x85","","ab\n\n","a\nb\nc"])
g.case('2.4 overflowsLineLimit counts the split lines plus 1 when the page ends in a line terminator (LF, VT, FF, CR, U+0085 in one byte); only a real line feed adds the extra display view (display lines, overflow count, ends with a terminator)',c,e)
calls=[];exp=""
for (t,cur,wd) in [("a"*25,19,114),("a"*25,25,114),("a"*25,0,114),("hello world foo",11,66),("hello world foo",12,66),("",0,114),("ab\n",3,114),("ab\n",2,114),("ab\ncd",3,114)]:
    calls.append(("0",ed(t,cur=cur,wd=wd)+'\nMOVE %d TO WS-I1\nCALL "MN8-LINEAT" USING MN8-ED WS-I1 WS-R1 WS-R2 WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N'%cur,None)); vs=views(t,wd,6); ln=lineat(vs,cur); exp+=nums(ln,*vs[ln])
g.case('2.3 the line of a cursor: a cursor shared by two lines (the end of one equals the start of the next) belongs to the earlier line (text, cursor -> 0 based line, its begin and end; 25 letters wrap at 19 at width 114, "hello world foo" at width 66)',calls,exp)

SHOWSTL='MOVE MN8-CUR TO WS-R1\nMOVE MN8-ANC TO WS-R2\nMOVE MN8-CHANGED TO WS-R3\nMOVE MN8-LEN TO WS-R4\nMOVE 4 TO WS-N\nPERFORM ADD-N'
def stcase(items,call,model,show=SHOWST,pre=None,lens=False):
    calls=[];exp=""
    for it in items:
        s0=it[0]; extra=it[1:]
        calls.append(("0",ed(s0.t,s0.cur,s0.anc,s0.cl,s0.ll,s0.wd,s0.adv,s0.clip)+"\n"+call(*extra)+"\n"+(SHOWSTL if lens else show),None))
        model(s0,*extra)
        exp+=(nums(s0.cur,s0.anc,s0.chg,len(s0.t)) if lens else nums(s0.cur,s0.anc,s0.chg)+txt(s0.t))
    return calls,exp
def ins_call(x): return settext('WS-TA',x)+'\nMOVE %d TO WS-TL\nCALL "MN8-INSERT" USING MN8-ED WS-TA WS-TL'%len(x)
def sv_call(x,f): return settext('WS-TA',x)+'\nMOVE %d TO WS-TL\nMOVE %d TO WS-J\nCALL "MN8-SETVALUE" USING MN8-ED WS-TA WS-TL WS-J'%(len(x),f)
c,e=stcase([(St("abc",1,1),"X"),(St("abc",1,3),"X"),(St("abc"),""),(St("abc",3,3),"\t"),(St("abc",1,3),"\t"),(St("abc"),"d\te\x01f\n"),(St("abc",cl=4),"xyz"),(St("abc",cl=3),"x"),(St("a"*1024,cl=1024,wd=2000),"")], ins_call,lambda s,x:insert(s,x),lens=True)
g.case('2.4 insert: an empty raw string with no selection does nothing; text is filtered then cut to the room left in the whole text (a selection is not credited); the selection is replaced and the cursor goes after the inserted text; a non-empty raw string that filters to nothing still stores (changed 1) and moves the cursor to the selection start (cursor, anchor, changed, text)',c,e)
c,e=stcase([(St("a"*1024,0,5,wd=2000),"x"),(St("a"*1024,1019,1024,wd=2000),"x"),(St("a"*1024,1024,1024,wd=2000),"x")],ins_call,lambda s,x:insert(s,x),lens=True)
g.case('2.4 and 8 example 5: a page of exactly 1024 characters with 5 selected and the user types x: room 0, the 5 selected are deleted and nothing is inserted (length 1019); with no selection nothing is added',c,e)
fourteen="\n".join("l%d"%i for i in range(14))
c,e=stcase([(St(fourteen),"\n"),(St(fourteen[:-1]),"\n"),(St("",wd=114),"\n".join(["q"]*20)),(St("",wd=114),"a"*1500),(St("",wd=2000,cl=1024),"a"*1500),(St("ab",wd=114,ll=2),"\n"),(St("ab",wd=114,ll=2),"cd"),(St("ab\ncd",1,1,ll=2),"\n")],ins_call,lambda s,x:insert(s,x),lens=True)
g.case('2.4 and 8 example 4: when the result would overflow the line limit the whole insertion is rejected (no truncation): a trailing line feed on a full page, a 20-line paste, a 1500-character paste (cut to 1024 first, then rejected at width 114; accepted at a very wide width), insert within the limit of 2 lines',c,e)
c,e=stcase([(St("abc",cl=5,ll=14),"hello",1),(St("abc",cl=5,ll=14),"hello",0),(St("x",ll=1,wd=6,adv=6),"abcdefgh",0),(St("x",ll=1,wd=6,adv=6),"abcdefgh",1),(St("x",ll=14),"a\nb\n",0),(St("",cl=1024),"",0)],lambda x,f:sv_call(x,f),lambda s,x,f:setvalue(s,x,f))
g.case('2.4 setValue: the text is cut to the limit first; with force 0 a text over the line limit is ignored entirely, with force 1 it is accepted (how a page is loaded); the cursor and anchor go to the end (cursor, anchor, changed, text)',c,e)

calls=[];exp=""
for (t,c) in [("ab  cd",6),("ab  cd",4),("ab  cd",2),("ab  cd",0),("  ab",3),("",0),("hello",5),("a\tb\nc",4),("x y",1),("ab cd",3)]:
    calls.append(("0",ed(t,cur=c)+'\nMOVE %d TO WS-I1\nCALL "MN8-PREVWORD" USING MN8-ED WS-I1 WS-R1 WS-R2\nMOVE 2 TO WS-N\nPERFORM ADD-N'%c,None)); exp+=nums(*prevword(t,c))
g.case('2.6 previous word: from the cursor clamped to the last index step back over whitespace then over non-whitespace; the view ends at the next whitespace or the end; "ab  cd" with the cursor 6 gives the word beginning at 4 (text, cursor -> begin, end)',calls,exp)
calls=[];exp=""
for (t,c) in [("ab  cd",0),("ab  cd",2),("ab  cd",4),("ab  cd",6),("",0),("a b",0),("a\tb",1),("word",1),("one two three",4)]:
    calls.append(("0",ed(t,cur=c)+'\nMOVE %d TO WS-I1\nCALL "MN8-NEXTWORD" USING MN8-ED WS-I1 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%c,None)); exp+=nums(nextword(t,c))
g.case('2.6 next word: from the cursor clamped to the last index step forward over non-whitespace then over whitespace; the position reached is the start of the next word, the end of the text when there is none (text, cursor -> position)',calls,exp)
def kcall(kc,mods,mac): return 'MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN8-KEY" USING MN8-ED WS-I1 WS-I2 WS-I3 WS-R4'%(kc,mods,mac)
def keycase(items,show=SHOWKEY):
    calls=[];exp=""
    for (s0,kc,mods,mac) in items:
        calls.append(("0",ed(s0.t,s0.cur,s0.anc,s0.cl,s0.ll,s0.wd,s0.adv,s0.clip)+"\n"+kcall(kc,mods,mac)+"\nMOVE MN8-CUR TO WS-R1\nMOVE MN8-ANC TO WS-R2\nMOVE MN8-CHANGED TO WS-R3\nMOVE 4 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-ED\nPERFORM SHOW-CLIP",None))
        key(s0,kc,mods,mac)
        exp+=nums(s0.cur,s0.anc,s0.chg,s0.hand)+txt(s0.t)+txt(s0.clip)
    return calls,exp
CTRL=192; SHIFT=1; ALT=256; CMD=3072
SA=lambda *a,**k: St(*a,**k)
c,e=keycase([(SA("hello world",3,3),97,CTRL,0),(SA("hello world",3,3),97,CTRL|SHIFT,0),(SA("hello world",3,3),97,CTRL|ALT,0),(SA("hello world",3,3),97,0,0),(SA("hello world",3,3),97,CMD,1),(SA("hello world",3,3),97,CTRL,1),
 (SA("hello world",6,1),99,CTRL,0),(SA("hello world",6,6),99,CTRL,0),(SA("hello",1,4),99,CMD,1),(SA("hello world",2,2,clip="XY"),118,CTRL,0),(SA("hello world",0,5,clip="Q"),118,CTRL,0),(SA("hello world",1,4),120,CTRL,0),(SA("hello",5,5),120,CTRL,0),(SA("hello",1,4),99,CTRL|ALT,0)])
g.case('2.5 keys select all (97), copy (99), paste (118) and cut (120): each needs the edit shortcut (Control, or Command on macOS = mask 3072) with no Shift and no Alt; copy of nothing is the empty string; paste goes through the insert rules; cut deletes the selection (cursor, anchor, changed, handled, text, clipboard)',c,e)
c,e=keycase([(SA("hello",3,3),8,0,0),(SA("hello",0,0),8,0,0),(SA("hello",1,4),8,0,0),(SA("ab  cd",6,6),8,CTRL,0),(SA("ab  cd",6,6),8,CMD,1),(SA("ab  cd",6,6),8,CMD,0),(SA("hello",2,2),127,0,0),(SA("hello",5,5),127,0,0),(SA("hello",1,3),127,0,0),(SA("ab  cd ef",0,0),127,CTRL,0),(SA("ab  cd ef",4,4),127,CTRL,0)])
g.case('2.5 and 8 example 6: Backspace (8) deletes one code unit before the cursor, or back to the previous word start with the edit shortcut; Delete (127) deletes the next unit or to the next word start; a selection is deleted instead; at the end of the text Delete does nothing; Ctrl+Backspace on "ab  cd" with the cursor 6 deletes two characters',c,e)
c,e=keycase([(SA("ab",1,1),13,0,0),(SA("ab",1,1),1073741912,0,0),(SA(fourteen),13,0,0),(SA("hello world",5,5),1073741904,0,0),(SA("hello world",0,0),1073741904,0,0),(SA("hello world",5,5),1073741904,SHIFT,0),(SA("hello world",8,8),1073741904,CTRL,0),(SA("hello world",3,3),1073741903,0,0),(SA("hello world",11,11),1073741903,0,0),(SA("hello world",3,3),1073741903,SHIFT,0),(SA("hello world",0,0),1073741903,CTRL,0),(SA("hello world",2,6),1073741904,0,0)])
g.case('2.5 Enter (13 or keypad 1073741912) inserts a line feed subject to the line limit; Left (1073741904) and Right (1073741903) move one unit clamped to the text, or one word with the edit shortcut; Shift keeps the anchor, otherwise the anchor follows the cursor',c,e)
big="aaaa bbbb cccc dddd eeee ffff gggg hhhh"
c,e=keycase([(SA(big,wd=60,adv=6),1073741906,0,0),(SA(big,30,30,wd=60,adv=6),1073741906,0,0),(SA(big,30,30,wd=60,adv=6),1073741905,0,0),(SA(big,5,5,wd=60,adv=6),1073741906,0,0),(SA(big,5,5,wd=60,adv=6),1073741905,SHIFT,0),(SA(big,5,5,wd=60,adv=6),1073741905,CTRL,0),(SA(big,5,5,wd=60,adv=6),1073741906,CTRL,0),(SA(big,len(big),len(big),wd=60,adv=6),1073741905,0,0),
 (SA(big,22,22,wd=60,adv=6),1073741898,0,0),(SA(big,22,22,wd=60,adv=6),1073741898,CTRL,0),(SA(big,22,22,wd=60,adv=6),1073741901,0,0),(SA(big,22,22,wd=60,adv=6),1073741901,CTRL,0),(SA(big,22,5,wd=60,adv=6),1073741901,SHIFT,0),(SA(big,22,22,wd=60,adv=6),1073741899,0,0),(SA(big,22,22,wd=60,adv=6),1073741902,0,0),(SA(big,22,22,wd=60,adv=6),1073741902,SHIFT,0),(SA(big,22,22,wd=60,adv=6),65,0,0),(SA(big,22,22,wd=60,adv=6),9,0,0)])
g.case('2.5 and 2.7 Up (1073741906) and Down (1073741905) move one display line to the nearest boundary at or before the pointer (width + 2 bias), clamped (the first line recomputes within itself), with the edit shortcut they do nothing but are handled; Home and End use the display line or the whole text with the shortcut; the page keys go to 0 and the end; other keys are not handled',c,e)
calls=[];exp=""
for (t,wd,adv,lb,le,bud) in [(big,60,6,0,9,20),(big,60,6,0,9,0),(big,60,6,0,9,-1),(big,60,6,0,9,54),(big,60,6,0,9,1000),("abc",100,0,0,3,5),("abc",100,6,0,3,17),("abc",100,6,0,3,18),("",100,6,0,0,5)]:
    calls.append(("0",ed(t,wd=wd,adv=adv)+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN8-INDEXAT" USING MN8-ED WS-I1 WS-I2 WS-I3 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(lb,le,bud),None)); exp+=nums(idxat(t,lb,le,bud,adv))
g.case('2.7 plainIndexAtWidth: walk the line subtracting each advance from the budget; the prefix ends before the first character that makes it negative, so there is no rounding to the nearest boundary (line begin, line end, budget -> characters that fit)',calls,exp)
calls=[];exp=""
for (mods,mac) in [(0,0),(1,0),(2,0),(3,0),(64,0),(128,0),(192,0),(768,0),(256,0),(512,0),(3072,0),(3072,1),(1024,1),(192,1),(2048,1),(1,1)]:
    sh=int(bool(mods&3)); al=int(bool(mods&768)); sc=int(bool(mods&(3072 if mac else 192)))
    calls.append(("0",'MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN8-MODS" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N'%(mods,mac),None)); exp+=nums(sh,sc,al)
g.case('2.5 modifier helpers: Shift is the mask 3, Alt the mask 768, the edit shortcut is the mask 192 (Control) except on macOS where it is 3072 (Command) (modifier word, macOS -> shift, edit shortcut, alt)',calls,exp)
def clcase(items):
    calls=[];exp=""
    for (s0,mx,my,bx,by,sc_,mode,shift) in items:
        calls.append(("0",ed(s0.t,s0.cur,s0.anc,s0.cl,s0.ll,s0.wd,s0.adv)+'\nCOMPUTE WS-FX1 = %r\nCOMPUTE WS-FX2 = %r\nMOVE %d TO WS-I3\nMOVE %d TO WS-I4\nMOVE %d TO WS-I5\nMOVE %d TO WS-I6\nMOVE %d TO WS-I7\nCALL "MN8-CLICK" USING MN8-ED WS-FX1 WS-FX2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7\n'%(mx,my,bx,by,sc_,mode,shift)+"MOVE MN8-CUR TO WS-R1\nMOVE MN8-ANC TO WS-R2\nMOVE 2 TO WS-N\nPERFORM ADD-N",None))
        click(s0,mx,my,bx,by,sc_,mode,shift)
        exp+=nums(s0.cur,s0.anc)
    return calls,exp
S1=lambda cur=0,anc=0: SA(big,cur,anc,wd=60,adv=6)
c,e=clcase([(S1(),100.7,50.2,90,40,0,1,0),(S1(2,2),100.7,50.2,90,40,0,1,1),(S1(2,2),100.7,59.9,90,40,0,1,0),(S1(),90.0,40.0,90,40,0,1,0),(S1(),500.0,500.0,90,40,0,1,0),(S1(),0.0,0.0,90,40,0,1,0),(S1(),100.0,70.0,90,40,9,1,0),(S1(4,4),120.0,60.0,90,40,0,3,0),(S1(4,4),120.0,60.0,90,40,0,3,1),(S1(8,8),0.0,0.0,0,0,0,2,0),(S1(2,2),0.0,0.0,0,0,0,2,0)])
g.case('2.7 mouse: a click lands on the boundary at or before the pointer (x = floor(mouseX - boxX - 4), y = mouseY - boxY - 4 + scroll, line = floor(y / 9) clamped); Shift keeps the anchor; a drag moves the cursor and keeps the anchor; a double click selects the word at the cursor (cursor, anchor)',c,e)
calls=[];exp=""
for (t,wd,adv,line,cur,anc,bx,bw) in [(big,60,6,0,2,6,10,122),(big,60,6,0,6,2,10,122),(big,60,6,1,2,40,10,122),(big,60,6,2,2,40,10,122),(big,60,6,1,14,14,10,122),(big,60,6,0,20,25,10,122),(big,60,6,0,0,9,10,122),(big,60,6,3,0,38,10,122)]:
    s0=SA(t,cur,anc,wd=wd,adv=adv); vs=s0.views(); sb=min(cur,anc); se=max(cur,anc); lb,le=vs[line]
    inter=int(sb<=le and lb<=se)
    x0=bx+4+adv*(max(sb,lb)-lb); x1=bx+4+(bw-4) if se>le else bx+4+adv*(se-lb)
    calls.append(("0",ed(t,cur,anc,wd=wd,adv=adv)+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nCALL "MN8-HILITE" USING MN8-ED WS-I1 WS-I2 WS-I3 WS-R1 WS-R2 WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N'%(line,bx,bw),None)); exp+=nums(inter,x0 if inter else 0,x1 if inter else 0)
g.case('2.8 step 3: the selection highlight of display line i exists when sb <= line end and line begin <= se; x0 = boxX + 4 + width(line begin .. max(sb, begin)); x1 = boxX + boxWidth when the selection goes past the line end, else boxX + 4 + width(begin .. se) (line, boxX, box width -> intersects, x0, x1)',calls,exp)
calls=[];exp=""
for (t,wd,adv,cur,foc,tm,bx,by) in [(big,60,6,2,1,0,10,20),(big,60,6,2,1,299,10,20),(big,60,6,2,1,300,10,20),(big,60,6,2,1,599,10,20),(big,60,6,2,1,600,10,20),(big,60,6,2,0,0,10,20),(big,60,6,len(big),1,0,10,20),(big,60,6,22,1,0,10,20),("ab\n",114,6,3,1,0,10,20),("",114,6,0,1,0,10,20),(big,60,6,len(big),0,0,10,20)]:
    s0=SA(t,cur,cur,wd=wd,adv=adv); vs=s0.views(); vis=foc and (tm//300)%2==0
    if not vis: r=(0,0,0)
    elif cur<len(t):
        i=lineat(vs,cur); r=(1,bx+4+adv*(cur-vs[i][0]),by+4+9*i)
    else:
        i=len(vs)-1; r=(2,bx+4+adv*(len(t)-vs[i][0]),by+4+9*i)
    calls.append(("0",ed(t,cur,cur,wd=wd,adv=adv)+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nMOVE %d TO WS-I4\nCALL "MN8-CARET" USING MN8-ED WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3\nMOVE 3 TO WS-N\nPERFORM ADD-N'%(foc,tm,bx,by),None)); exp+=nums(*r)
g.case('2.8 step 4: the cursor shows only when the box is focused and floor(t / 300) mod 2 = 0; before the end of the text it is a 1 pixel bar at the cursor of its line, at the end it is the underscore after the last line (also on the empty line after a final line feed) (focused, ms since focus, boxX, boxY -> kind 0 none 1 bar 2 append, x, y of the line)',calls,exp)
def bs(n): return (9*n,9*n+8,int(9*n+8>134))
rowcase(g,'2.8 step 5: the page box is 122 x 134 with wrap width 114; the inner text height is 9 x lines and the content height reported to the scroll bar is that plus 8, so 14 lines (126 + 8 = 134) show no scroll bar and 15 do (line count -> inner height, content height, scroll bar)',[(n,) for n in (1,2,13,14,15,20)],'CALL "MN8-BOXSIZE" USING WS-I1 WS-R1 WS-R2 WS-R3',3,bs)
W(g,2)

# ===== 3
def jdiv(a,b): return int(a/b)
g=G8(3,'BookEditScreen','T1095','layout, page turning, saving and key handling (core/src/menu-40-8.cob).',True)
def brect(w,e):
    L=jdiv(w-192,2)
    return {1:(L,2,192,192),2:(jdiv(w-114,2)-8,28,122,134),3:(L+43,2+157,23,13),4:(L+116,2+157,23,13),5:(jdiv(w,2)-100,196,98,20),6:(jdiv(w,2)+2,196,98,20),7:(L+148,2+16,0,0)}[e]
rowcase(g,'3.2 layout for W = 320 and 321 and 854: background (L, 2) 192 x 192, page box ((W - 114) / 2 - 8, 28) 122 x 134, back (L + 43, 159) and forward (L + 116, 159) 23 x 13, Sign (W / 2 - 100, 196) and Done (W / 2 + 2, 196) 98 x 20, indicator right edge L + 148 at y 18 (element 1 background 2 page box 3 back 4 forward 5 sign 6 done 7 indicator; W -> x, y, w, h); worked layout W = 320: page box (95, 28), back (107, 159), forward (180, 159), indicator 212, Sign (60, 196), Done (162, 196)',[(w,e) for w in (320,321,854) for e in range(1,8)],'CALL "MN8-BOOKRECT" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4',4,brect)
CONSTS={1:114,2:126,3:192,4:192,5:256,6:98,7:4,8:157,9:43,10:116,11:148,12:16,13:1024,14:14,15:100,16:23,17:13,18:25,19:100,20:0,21:1,22:1}
rowcase(g,'3.1, 3.2 constants: text width 114, text height 126, image 192 x 192, texture 256, menu button size 98 and margin 4, page button y 157, back x 43, forward x 116, indicator offsets 148 and 16, character limit 1024, line limit 126 / 9 = 14, page cap 100, page button 23 x 13, turn sound volume 25 (hundredths, 0.25) and pitch 100, page button takes focus after a click 0, pause screen 1, in-game UI 1 (index -> value)',[(k,) for k in sorted(CONSTS)],'CALL "MN8-BOOKCONST" USING WS-I1 WS-R1',1,lambda k:CONSTS[k])
def fwd(cur,cnt):
    if cur<cnt-1: return (cur+1,cnt,0)
    n2=cnt+1 if cnt<100 else cnt
    return (cur+1 if cur<n2-1 else cur,n2,int(cnt<100))
rowcase(g,'3.3 steps 4 and 5, 8 example 7: forward moves on, or appends an empty page and moves on (refused at 100 pages: the same page reloads); back moves only above page 0; the back button shows only above page 0 and the forward button always (current page, page count -> new page, count, appended)',[(2,3),(0,3),(1,2),(98,99),(99,100),(0,1),(0,100),(50,100)],'CALL "MN8-PAGEFWD" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3',3,fwd)
rowcase(g,'3.3 step 4 page back (current page -> new page, back button visible)',[(0,),(1,),(5,),(99,)],'CALL "MN8-PAGEBACK" USING WS-I1 WS-R1 WS-R2',2,lambda c:(max(c-1,0),int(max(c-1,0)>0)))
rowcase(g,'3.3 step 6 page keys: Page-up (1073741899) presses back and Page-down (1073741902) presses forward before the text field sees them; every other key goes on (keycode -> 1 back, 2 forward, 0 other)',[(k,) for k in (1073741899,1073741902,1073741898,1073741901,9,65,13)],'CALL "MN8-BOOKKEY" USING WS-I1 WS-R1',1,lambda k:{1073741899:1,1073741902:2}.get(k,0))
def tabnext(f,bv,sh):
    order=[1]+([2] if bv else [])+[3,4,5]
    i=order.index(f); return order[(i+(-1 if sh else 1))%len(order)]
rowcase(g,'3.3 step 6 focus order with Tab: page box, back (when visible), forward, Sign, Done, then wrapping; Shift+Tab goes the other way (focus 1 page box 2 back 3 forward 4 Sign 5 Done, back visible, Shift -> next focus)',[(f,b,sh) for f in (1,2,3,4,5) for b in (0,1) for sh in (0,1) if not (f==2 and not b)],'CALL "MN8-TABNEXT" USING WS-I1 WS-I2 WS-I3 WS-R1',1,tabnext)
def erase(flags):
    n=len(flags)
    while n>0 and flags[n-1]=='E': n-=1
    return n
calls=[];exp=""
for fl in ["xxxE","xxxx","EEEE","xExE","xEEE","","E","x"]:
    calls.append(("0",'MOVE SPACES TO WS-PG\nMOVE "%s" TO WS-PG(1:%d)\nMOVE %d TO WS-I1\nCALL "MN8-SAVEPAGES" USING WS-PG WS-I1 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(fl,max(len(fl),1),len(fl)) if fl else 'MOVE SPACES TO WS-PG\nMOVE 0 TO WS-I1\nCALL "MN8-SAVEPAGES" USING WS-PG WS-I1 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N',None)); exp+=nums(erase(fl))
g.case('3.3 step 9 and 8 example 7: Done erases trailing empty pages from the end, stopping at the first non-empty one (it can remove every page; E marks an empty page, x a page with text, a page of spaces is x) (pages -> pages sent)',calls,exp)
rowcase(g,'3.3 step 10, 8 example 15: the slot of the packet is the selected hotbar slot read at saving for the main hand and 40 for the off hand (hand 0 main 1 off, selected slot -> slot)',[(0,4),(0,0),(0,8),(1,4),(1,0)],'CALL "MN8-SLOTOF" USING WS-I1 WS-I2 WS-R1',1,lambda h,s:40 if h else s)
rowcase(g,'3.2 page indicator: the translation book.pageIndicator takes currentPage + 1 and the page count (page, count -> shown page, count); at page 4 of 4 it reads 4 and 4',[(0,1),(3,4),(98,100),(99,100)],'CALL "MN8-INDICATOR" USING WS-I1 WS-I2 WS-R1 WS-R2',2,lambda c,n:(c+1,n))
calls=[];exp=""
for (d,h) in [(1,0),(1,1),(2,0),(2,1)]:
    sprite="widget/page_%s%s"%("forward" if d==1 else "backward","_highlighted" if h else "")
    label="book.page_button.%s"%("next" if d==1 else "previous")
    calls.append(("0",'MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN8-PAGEBTN" USING WS-I1 WS-I2 WS-T1 WS-T2'%(d,h),'TEXT')); exp+="%s|%s "%(sprite,label)
g.case('3.2 PageButton: the sprite widget/page_forward or widget/page_backward (the highlighted variant when hovered or focused) and the narration label book.page_button.next or .previous (direction 1 forward 2 back, hovered -> sprite|label)',calls,exp)
def sflags(sc): return {1:(1,1,0,1),2:(1,1,0,1),3:(0,1,1,1),4:(0,1,1,1)}[sc]
rowcase(g,'3.2 and 4 and 6.2: the book editor and book sign screens are in-game UI screens that pause a single-player game (the default isPauseScreen true); the sign and hanging sign editors do not pause, capture input and close on Escape (screen 1 book edit 2 book sign 3 sign edit 4 hanging sign edit -> pauses, in-game UI, input captured, closes on Escape)',[(1,),(2,),(3,),(4,)],'CALL "MN8-SCREENFLAGS" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4',4,lambda sc:(1 if sc<3 else 0,1,0 if sc<3 else 1,1))
# page box load, sign switch, return: the setValue force rules
c,e=stcase([(St("old",1,1),"page two text",1),(St("",0,0),"x"*1024,1),(St("abc",1,2,ll=14),"q\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq\nq",1),(St("abc",1,2),"abc",1)],lambda x,f:sv_call(x,f),lambda s,x,f:setvalue(s,x,f),lens=True)
g.case('3.3 steps 1 and 8: loading a page (and returning from the sign screen) calls setValue with force: a page with more than 14 lines is shown, the cursor and the anchor are at the end, a selection is lost and the text is kept (cursor, anchor, stored, length)',c,e)
W(g,3)

# ===== 4
g=G8(4,'BookSignScreen','T1097','layout, title field, blank rule, Enter, saving (core/src/menu-40-8.cob).',False,True)
def srect(w,e):
    L=jdiv(w-192,2)
    return {1:(L,2,192,192),2:(jdiv(w,2)-100,196,98,20),3:(jdiv(w,2)+2,196,98,20),4:(jdiv(w-114,2)-3,50,114,20),5:(L+36,82,114,0)}[e]
rowcase(g,'4 layout for W = 320 and 321: background (L, 2), Sign and Close (W / 2 - 100, 196) 98 x 20, Cancel (W / 2 + 2, 196), title box ((W - 114) / 2 - 3, 50) 114 x 20, the wrapped warning from (L + 36, 82) with wrap width 114; worked layout: title box (100, 50), Sign and Close (60, 196), Cancel (162, 196), warning (100, 82) (element 1 background 2 sign and close 3 cancel 4 title box 5 warning; W -> x, y, w, h)',[(w,e) for w in (320,321,200) for e in range(1,6)],'CALL "MN8-SIGNRECT" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4',4,srect)
def labx(w,lw,k):
    L=jdiv(w-192,2); return (L+36+jdiv(114-lw,2),34 if k==1 else 60)
rowcase(g,'4 labels: Enter Book Title: at x = L + 36 + (114 - width) / 2, y 34 and the owner line at the same x rule, y 60 (Java integer division toward zero, so a label wider than 114 starts left of L + 36) (window width, text width, label 1 title 2 owner -> x, y)',[(320,60,1),(320,115,1),(320,114,2),(320,120,2),(320,0,1),(321,57,2)],'CALL "MN8-LABELX" USING WS-I1 WS-I2 WS-I3 WS-R1 WS-R2',2,labx)
SPACES_=[9,10,11,12,13,28,29,30,31,32,160,0x1680]+list(range(0x2000,0x200B))+[0x2028,0x2029,0x202F,0x205F,0x3000]
def blank(cps): return int(all(c in SPACES_ for c in cps))
rows=[[],[32],[32,32,32],[160],[160,160],[0x2007],[0x202F],[9,10,13],[65],[32,65],[160,65],[0x3000,0x2003],[0,32],[133],[127,32]]
rowcase(g,'4 behaviour 1 and 8 example 13: a title is blank (the Sign and Close button stays inactive) when it is empty or every character is whitespace or a space separator (no-break spaces U+00A0, U+2007, U+202F count) (count then code points -> blank)',[tuple([len(r)]+r) for r in rows],'CALL "MN8-ISBLANK" USING WS-IST WS-R1',1,lambda *a:blank(list(a[1:1+a[0]])))
rowcase(g,'4 behaviour 1 and 14: Sign and Close is active exactly while the title is not blank, also for a title restored after Cancel (count then code points -> active)',[tuple([len(r)]+r) for r in ([72,105],[],[32,32],[160],[65],[32,66,32])],'CALL "MN8-SIGNACTIVE" USING WS-IST WS-R1',1,lambda *a:1-blank(list(a[1:1+a[0]])))
def trim(t): 
    a=0;b=len(t)
    while a<b and ord(t[a])<=32: a+=1
    while b>a and ord(t[b-1])<=32: b-=1
    return t[a:b]
calls=[];exp=""
for t in ["  Hi  ","Hi","   ","","\tx\n","a b","\x01a\x1f"]:
    calls.append(("0",settext('WS-TA',t)+'\nMOVE %d TO WS-TL\nMOVE SPACES TO WS-TB\nCALL "MN8-TRIM" USING WS-TA WS-TL WS-TB WS-R1\nMOVE WS-TB TO WS-TA\nMOVE WS-R1 TO WS-TL\nPERFORM SHOW-TA'%len(t),None)); exp+=txt(trim(t))
g.case('4 behaviour 4: the title sent is the field value with leading and trailing whitespace removed (String.trim removes every character up to U+0020) (text printed with _ for a space, <> for empty)',calls,exp)
def finsert(f,ins):
    a=min(f.cur,f.anc); b=max(f.cur,f.anc); left=f.mx-len(f.t)+(b-a)
    if left<=0: return
    cl=filt(ins,False)[:left]; f.t=f.t[:a]+cl+f.t[b:]; f.cur=f.anc=a+len(cl); f.chg=1
class F:
    def __init__(s,t,cur=None,anc=None,mx=15,adv=6,maxw=0,clip=''):
        s.t=t; s.cur=len(t) if cur is None else cur; s.anc=s.cur if anc is None else anc; s.mx=mx; s.adv=adv; s.maxw=maxw; s.clip=clip; s.chg=0; s.hand=0
def fcase(items,call,model):
    calls=[];exp=""
    for it in items:
        f0=it[0]; ex=it[1:]
        calls.append(("0",fld(f0.t,f0.cur,f0.anc,f0.mx,f0.adv,f0.maxw,f0.clip)+"\n"+call(*ex)+"\n"+SHOWF,None))
        model(f0,*ex); exp+=nums(f0.cur,f0.anc,f0.chg)+txt(f0.t)
    return calls,exp
def fins_call(x): return settext('WS-TA',x)+'\nMOVE %d TO WS-TL\nCALL "MN8-FIELDINS" USING MN8-FLD WS-TA WS-TL'%len(x)
def fset_call(x): return settext('WS-TA',x)+'\nMOVE %d TO WS-TL\nCALL "MN8-FIELDSET" USING MN8-FLD WS-TA WS-TL'%len(x)
c,e=fcase([(F("a"*14),"b"),(F("a"*15),"b"),(F("a"*15),"b"*3),(F("ab"),"ab\ncd"),(F("hello",1,4),"XY"),(F("a"*15,0,15),"z"*20),(F(""),"\n"),(F("abc",1,1),"\t")],fins_call,finsert)
g.case('4 behaviour 2 and 8 example 13: the title field holds at most 15 code units (typing a 16th is ignored, a paste is cut to the space left), the selection counts as free space, inserted text is cleaned without line feeds (ab + line feed + cd gives abcd), the cursor goes after the inserted text (cursor, anchor, changed, text)',c,e)
def fset(f,x): f.t=x[:f.mx]; f.cur=f.anc=len(f.t); f.chg=1
c,e=fcase([(F("old"),"x"*20),(F("old"),"Hi"),(F("old"),"")],fset_call,fset)
g.case('4 behaviour 1 and 14: setValue cuts the text to the maximum length, puts the cursor at the end and always calls the responder (changed 1), as when the stored title is put back after Cancel',c,e)
rowcase(g,'4 behaviour 3: Enter (scancode 40, or 88 on the keypad) with the field focused and its value not empty saves like the button; a whitespace-only value counts as not empty (so Enter on spaces sends an empty title); an empty value, another key or a field without focus does nothing (scancode, focused, length -> saves)',[(40,1,2),(88,1,3),(40,1,0),(40,0,2),(41,1,2),(13,1,2)],'CALL "MN8-TITLEENTER" USING WS-I1 WS-I2 WS-I3 WS-R1',1,lambda k,f,n:int(k in (40,88) and f==1 and n>0))
W(g,4)
# ===== 5
g=G8(5,'The sign line editor engine','T1099','sign line insert, keys, words, clipboard (core/src/menu-40-8.cob).',False,True)
def wordpos(t,dr,c):
    sep=lambda ch: ch in ' \n'
    n=len(t)
    if dr>0:
        i=c
        while i<n and not sep(t[i]): i+=1
        while i<n and sep(t[i]): i+=1
        return i
    i=c
    while i>0 and sep(t[i-1]): i-=1
    while i>0 and not sep(t[i-1]): i-=1
    return i
def sinsert(f,ins):
    a=min(f.cur,f.anc); b=max(f.cur,f.anc)
    base=f.t[:a]+f.t[b:]; cur=a
    cand=base[:cur]+ins+base[cur:]
    if f.adv*len(cand)<=f.maxw:
        f.t=cand; f.cur=f.anc=min(len(cand),cur+len(ins)); f.chg=1
    else: f.cur=f.anc=a
def sedit_ins_call(x): return settext('WS-TA',x)+'\nMOVE %d TO WS-TL\nCALL "MN8-SIGNINS" USING MN8-FLD WS-TA WS-TL'%len(x)
c,e=fcase([(F("a"*14,mx=0,maxw=90),"b"),(F("a"*15,mx=0,maxw=90),"b"),(F("a"*9,mx=0,maxw=60),"b"),(F("a"*10,mx=0,maxw=60),"b"),(F("a"*15,2,5,0,6,90),"b"),(F("a"*15,2,5,0,6,90),"bbbbbbbb"),(F("a"*15,5,2,0,6,90),"x"),(F("ab",1,1,0,6,90),"XYZ"),(F("",0,0,0,6,90),"\t"),(F("a"*15,0,0,0,6,90),"bc"),(F("ab",2,2,0,0,0),"x")],sedit_ins_call,sinsert)
g.case('5.1, 5.2, 8 example 12: a character is inserted when the new line is at most the maximum width (advance 6: 15 characters on a sign (90), 10 on a hanging sign (60)); a selection is deleted first; a rejection leaves the text and collapses the selection to its start; the cursor goes after the inserted text (cursor, anchor, changed, text)',c,e)
def typed(f,cp):
    if allowed(cp): sinsert(f,chr(cp))
    f.hand=1
def typed_call(cp): return 'MOVE %d TO WS-I1\nCALL "MN8-SIGNTYPED" USING MN8-FLD WS-I1 WS-R4'%cp
calls=[];exp=""
for (f0,cp) in [(F("ab",mx=0,maxw=90),65),(F("ab",mx=0,maxw=90),9),(F("ab",mx=0,maxw=90),167),(F("ab",mx=0,maxw=90),127),(F("a"*15,mx=0,maxw=90),66)]:
    calls.append(("0",fld(f0.t,f0.cur,f0.anc,f0.mx,f0.adv,f0.maxw)+"\n"+typed_call(cp)+"\nMOVE MN8-FCUR TO WS-R1\nMOVE MN8-FANC TO WS-R2\nMOVE MN8-FCHANGED TO WS-R3\nMOVE 4 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-FLD",None))
    typed(f0,cp); exp+=nums(f0.cur,f0.anc,f0.chg,f0.hand)+txt(f0.t)
g.case('5.1 typing: a code point that is an allowed chat character is inserted; the call reports handled (1) always, also for tab, the section sign and 127, which are dropped (cursor, anchor, changed, handled, text)',calls,exp)
def sdelete(f,a,b):
    f.t=f.t[:a]+f.t[b:]; f.cur=f.anc=a
def skey(f,kc,sc,mods,mac):
    shift=bool(mods&3); alt=bool(mods&768); ctrl=bool(mods&(3072 if mac else 192))
    f.hand=1; sel=f.cur!=f.anc; a=min(f.cur,f.anc); b=max(f.cur,f.anc)
    if kc==97 and ctrl and not shift and not alt: f.anc=0; f.cur=len(f.t)
    elif kc==99 and ctrl and not shift and not alt: f.clip=f.t[a:b]
    elif kc==118 and ctrl and not shift and not alt: sinsert(f,f.clip); f.anc=f.cur
    elif kc==120 and ctrl and not shift and not alt: f.clip=f.t[a:b]; sdelete(f,a,b)
    elif kc==8:
        if sel: sdelete(f,a,b)
        elif ctrl: p=wordpos(f.t,-1,f.cur); sdelete(f,p,f.cur)
        else:
            if f.cur>0: sdelete(f,f.cur-1,f.cur)
    elif kc==127:
        f.hand=0
        if sel: sdelete(f,a,b)
        elif ctrl: p=wordpos(f.t,1,f.cur); sdelete(f,f.cur,p)
        else: sdelete(f,f.cur,min(f.cur+1,len(f.t)))
    elif sc==80:
        f.cur=wordpos(f.t,-1,f.cur) if ctrl else max(f.cur-1,0)
        if not shift: f.anc=f.cur
    elif sc==79:
        f.cur=wordpos(f.t,1,f.cur) if ctrl else min(f.cur+1,len(f.t))
        if not shift: f.anc=f.cur
    elif kc==1073741898:
        f.cur=0
        if not shift: f.anc=0
    elif kc==1073741901:
        f.cur=len(f.t)
        if not shift: f.anc=f.cur
    else: f.hand=0
def skey_call(kc,sc,mods,mac): return 'MOVE %d TO WS-I1\nMOVE %d TO WS-I2\nMOVE %d TO WS-I3\nMOVE %d TO WS-I4\nCALL "MN8-SIGNKEY" USING MN8-FLD WS-I1 WS-I2 WS-I3 WS-I4 WS-R4'%(kc,sc,mods,mac)
def skcase(items):
    calls=[];exp=""
    for (f0,kc,sc,mods,mac) in items:
        calls.append(("0",fld(f0.t,f0.cur,f0.anc,f0.mx,f0.adv,f0.maxw,f0.clip)+"\n"+skey_call(kc,sc,mods,mac)+"\nMOVE MN8-FCUR TO WS-R1\nMOVE MN8-FANC TO WS-R2\nMOVE MN8-FCHANGED TO WS-R3\nMOVE 4 TO WS-N\nPERFORM ADD-N\nPERFORM SHOW-FLD\nPERFORM SHOW-FCLIP",None))
        skey(f0,kc,sc,mods,mac); exp+=nums(f0.cur,f0.anc,f0.chg,f0.hand)+txt(f0.t)+txt(f0.clip)
    return calls,exp
SF=lambda t,cur=None,anc=None,clip='': F(t,cur,anc,0,6,90,clip)
c,e=skcase([(SF("hello world",3,3),97,0,CTRL,0),(SF("hello world",3,3),97,0,CTRL|SHIFT,0),(SF("hello world",3,3),97,0,0,0),(SF("hello",1,4),99,0,CTRL,0),(SF("hello",2,2),99,0,CMD,1),(SF("hello",2,2,"XY"),118,0,CTRL,0),(SF("hello",1,4,"XY"),118,0,CTRL,0),(SF("hello",1,4),120,0,CTRL,0),(SF("a"*15,5,5,"Z"),118,0,CTRL,0),(SF("hello",2,2),118,0,CTRL|ALT,0)])
g.case('5.3 select all, copy, paste and cut (keycodes 97, 99, 118, 120 with the edit shortcut, no Shift and no Alt): paste goes through the insert rules and then the anchor follows the cursor; cut removes the selection without a width test (cursor, anchor, changed, handled, text, clipboard)',c,e)
c,e=skcase([(SF("hello",3,3),8,0,0,0),(SF("hello",0,0),8,0,0,0),(SF("hello",1,4),8,0,0,0),(SF("ab  cd",6,6),8,0,CTRL,0),(SF("ab  cd",6,6),8,0,CMD,1),(SF("hello",1,4),8,0,CTRL,0),(SF("hello",2,2),127,0,0,0),(SF("hello",5,5),127,0,0,0),(SF("hello",1,3),127,0,0,0),(SF("ab  cd ef",0,0),127,0,CTRL,0),(SF("ab  cd ef",4,4),127,0,CTRL,0)])
g.case('5.3 Backspace (keycode 8) deletes one unit before the cursor or the previous word with the edit shortcut, a selection instead; Delete (127) deletes toward the end, also by word, and reports the key as NOT handled although the deletion happens (cursor, anchor, changed, handled, text, clipboard)',c,e)
c,e=skcase([(SF("hello world",5,5),0,80,0,0),(SF("hello world",0,0),0,80,0,0),(SF("hello world",5,5),0,80,SHIFT,0),(SF("hello world",8,8),0,80,CTRL,0),(SF("ab  cd",6,6),0,80,CTRL,0),(SF("hello world",3,3),0,79,0,0),(SF("hello world",11,11),0,79,0,0),(SF("hello world",3,3),0,79,SHIFT,0),(SF("hello world",0,0),0,79,CTRL,0),(SF("hello world",2,6),0,80,0,0),
 (SF("hello world",5,5),1073741898,0,0,0),(SF("hello world",5,8),1073741898,0,SHIFT,0),(SF("hello world",5,5),1073741901,0,0,0),(SF("hello world",5,2),1073741901,0,SHIFT,0),(SF("hello",2,2),65,4,0,0),(SF("hello",2,2),0,81,0,0)])
g.case('5.3 and 8 example 6: Left (scancode 80) and Right (79) move one unit or one word with the edit shortcut (Ctrl+Left on ab  cd from 6 goes to 4), Shift keeps the anchor, otherwise it follows; Home and End (keycodes 1073741898 and 1073741901) go to 0 and the end; other keys are not handled',c,e)
calls=[];exp=""
for (t,dr,c0) in [("ab  cd",-1,6),("ab  cd",-1,4),("ab  cd",-1,2),("ab  cd",1,0),("ab  cd",1,2),("ab  cd",1,4),("ab  cd",1,6),("a\nb c",1,0),("a\nb c",-1,4),("",1,0),("",-1,0),("word",1,1)]:
    calls.append(("0",fld(t,c0,c0)+'\nMOVE %d TO WS-I1\nMOVE %d TO WS-I2\nCALL "MN8-WORDPOS" USING MN8-FLD WS-I1 WS-I2 WS-R1\nMOVE 1 TO WS-N\nPERFORM ADD-N'%(dr,c0),None)); exp+=nums(wordpos(t,dr,c0))
g.case('5.3 word steps: the separators are only the space and the line feed (unlike 2.6): forward finds the next separator at or after the cursor (none: the end) and skips all following separators; backward skips separators before the cursor then steps back over non-separators (text, direction, cursor -> position)',calls,exp)
calls=[];exp=""
def clipget(t):
    t=t.replace("\r","")
    out="";i=0
    while i<len(t):
        if ord(t[i])==167 and i+1<len(t) and t[i+1] in "0123456789abcdefABCDEFkKlLmMnNoOrR": i+=2
        else: out+=t[i]; i+=1
    return out
for t in ["a\rb\r\nc","\xa7aGreen","x\xa7r","\xa7zq","\xa7","\xa7K\xa7k\xa70\xa7F\xa7gz","tab\there","\xa7a\xa7","","\xa7\xa7a"]:
    calls.append(("0",settext('WS-TA',t)+'\nMOVE %d TO WS-TL\nMOVE SPACES TO WS-TB\nCALL "MN8-CLIPGET" USING WS-TA WS-TL WS-TB WS-R1\nMOVE WS-R1 TO WS-R2\nMOVE 2 TO WS-N\nMOVE WS-TL TO WS-R1\nPERFORM ADD-N'%len(t),None)); exp+=nums(len(t),len(clipget(t)))
g.case('5.4 clipboard getter: every carriage return is deleted, then every section sign followed by one of 0-9 a-f k-o r (either case) is removed; nothing else is filtered (a tab stays, a section sign before another character stays) (text length, length after)',calls,exp)
W(g,5)

# ===== 6
g=G8(6,'AbstractSignEditScreen, SignEditScreen, HangingSignEditScreen','T1101','sign screen constants, colours, keys, tick, drawing arithmetic (core/src/menu-40-8.cob).')
rowcase(g,'6.1 step 5 and 6.4: line height and maximum line width come from the block entity: sign 10 and 90, hanging sign 9 and 60; the frame y offset is 90 or 125, the text scale 0.9765628 or 1.0 (x 1e7) and the background scale 3.9 or 4.5 (x 10) (hanging 0 sign 1 hanging -> line height, max width, y offset, text scale, background scale)',[(0,),(1,)],'CALL "MN8-SIGNDIMS" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5',5,lambda h:(9,60,125,10000000,45) if h else (10,90,90,9765628,39))
def bgm(h,wall):
    if h: return (-13,-8,-8,16,16,45)
    return (27,-12,-13,24,12 if wall else 26,39)
rowcase(g,'6.4 background: sign frame translate (0, 27), scale 3.9, blit at (-12, -13) 24 wide and 12 high when wall-mounted else 26; hanging translate (0, -13), scale 4.5, blit at (-8, -8) 16 x 16 (hanging, wall -> translate y, blit x, blit y, width, height, scale x 10)',[(0,0),(0,1),(1,0),(1,1)],'CALL "MN8-SIGNBG" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6',6,bgm)
def f32(x): return struct.unpack('f',struct.pack('f',x))[0]
DYE=[0xFFFFFF,0xFF681F,0xFF00FF,0x9AC0CD,0xFFFF00,0xBFFF00,0xFF69B4,0x808080,0xD3D3D3,0x00FFFF,0xA020F0,0x0000FF,0x8B4513,0x00FF00,0xFF0000,0x1E1B1B]
def prev(glow,rgb):
    if glow: return rgb
    out=0
    for sh in (16,8,0):
        c=(rgb>>sh)&255; v=int(f32(c*f32(0.4))); v=max(0,min(255,v)); out|=v<<sh
    return out
rowcase(g,'6.1 step 3: glowing text uses the dye text colour directly, black included (0x1E1B1B); other text scales each channel by 0.4f, truncated toward zero and clamped (glow, dye text colour RGB -> preview colour RGB, alpha 0)',[(gl,c) for gl in (1,0) for c in DYE],'CALL "MN8-PREVIEWCOLOR" USING WS-I1 WS-I2 WS-R1',1,prev)
rowcase(g,'6.1 step 2: messages[i] is the plain string of the side\'s line i, or the empty string when the list is shorter than i + 1 (list length, line -> present)',[(n,i) for n in (0,2,4) for i in (0,1,2,3)],'CALL "MN8-MSGPRESENT" USING WS-I1 WS-I2 WS-R1',1,lambda n,i:int(i<n))
def skeyk(sc,line):
    if sc==82: return (1,(line-1)&3)
    if sc in (81,40,88): return (1,(line+1)&3)
    if sc==41: return (2,line)
    return (3,line)
rowcase(g,'6.2 step 3 and 8 example 11: Up (scancode 82) selects line (line - 1) and 3, Down (81) or a confirmation key (Enter 40, keypad Enter 88) line (line + 1) and 3, the cursor going to the end; Enter never presses Done; Escape (41) closes like Done; other keys go on to the line helper (scancode, line -> kind 1 line change 2 close 3 other, new line)',[(sc,l) for sc in (82,81,40,88,41,80,44) for l in (0,3)],'CALL "MN8-SIGNSCREENKEY" USING WS-I1 WS-I2 WS-R1 WS-R2',2,skeyk)
rowcase(g,'6.2 step 3d: a focused Done button reacts to the selection keys (scancode 40, 44, 88: Enter, Space, keypad Enter) while the confirmation keys are only 40 and 88; Escape is 41 (scancode -> selection, confirmation, escape)',[(k,) for k in (40,44,88,41,82,80)],'CALL "MN8-KEYKIND" USING WS-I1 WS-R1 WS-R2 WS-R3',3,lambda k:(int(k in (40,44,88)),int(k in (40,88)),int(k==41)))
rowcase(g,'6.2 step 2: every tick the screen closes when the local player is missing, the sign block entity was removed, or the player is too far away to edit (missing, removed, too far -> close)',[(a,b,c) for a in (0,1) for b in (0,1) for c in (0,1)],'CALL "MN8-SIGNTICK" USING WS-I1 WS-I2 WS-I3 WS-R1',1,lambda a,b,c:int(a or b or c))
rowcase(g,'6.2 steps 5 to 7: an accepted line change stores the string, sets the working copy and the client sign text when it differs from the stored one and sends nothing; removal sends the 0x3E packet when the connection exists, whatever closed the screen, including Escape (same string, connection -> store and set text, packet sent now, packet on removal)',[(0,1),(1,1),(0,0)],'CALL "MN8-SIGNCHANGE" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3',3,lambda same,conn:(1-same,0,conn))
rowcase(g,'6.2 step 1 and 6.6: the Done button is bounds(W / 2 - 100, H / 4 + 144, 200, 20); the title is centred at x = W / 2, y 40 (W = 320, H = 240 gives (60, 204)) (window width, height -> x, y, w, h, title x, title y)',[(320,240),(321,241),(854,480)],'CALL "MN8-SIGNDONE" USING WS-I1 WS-I2 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6',6,lambda w,h:(jdiv(w,2)-100,jdiv(h,4)+144,200,20,jdiv(w,2),40))
def prevw(w,h,hang,wall):
    cx=10*jdiv(w,2)
    if hang:
        c=10*(125-13); return (cx+45*-8,c+45*-8,cx+45*8,c+45*8)
    c=10*(90+27); hh=12 if wall else 26
    return (cx+39*-12,c+39*-13,cx+39*12,c+39*(-13+hh))
rowcase(g,'6.6 worked layout (W = 320, in tenths of a pixel): standing sign background x 113.2 to 206.8, y 66.3 to 167.7; wall-mounted y 66.3 to 113.1; hanging sign x 124 to 196, y 76 to 148 (window width, height, hanging, wall -> x0, y0, x1, y1 x 10)',[(320,240,0,0),(320,240,0,1),(320,240,1,0)],'CALL "MN8-SIGNPREVIEW" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4',4,prevw)
def texty(h,i):
    if h: return 125*1000000+(i*9-18)*1000000
    return 90*1000000+(i-2)*9765628
rowcase(g,'6.5 and 6.6: line i of the text is drawn at y = i x lineHeight - 2 x lineHeight in the scaled frame: standing sign 70.47, 80.23, 90.0, 99.77 (scale 0.9765628) and hanging sign 107, 116, 125, 134 (screen y x 1e6) (hanging, line -> y)',[(h,i) for h in (0,1) for i in range(4)],'CALL "MN8-SIGNTEXTY" USING WS-I1 WS-I2 WS-R1',1,texty)
rowcase(g,'6.5: the line starts at x = -(width) / 2 with Java division (-floor(width / 2)): width 41 gives -20, 0 gives 0 (text width -> x)',[(0,),(1,),(41,),(90,),(91,)],'CALL "MN8-LINEX" USING WS-I1 WS-R1',1,lambda w:-(w//2))
def scaret(n,adv,c,a,lh,y,ms):
    w=adv*n; P=lambda k: adv*k-w//2
    vis=(ms//300)%2==0
    if c<0 or not vis: kind=0; x=ytop=ybot=0
    elif c>=n: kind=1; x=P(n); ytop=y-0; ybot=y   # append: drawn at y
    else: kind=2; x=P(c); ytop=y-1; ybot=y+lh
    if kind==1: ytop=y; ybot=y+lh
    hs=int(a!=c); 
    return (kind,x,ytop,ybot,hs,min(P(c),P(a)) if hs else 0,max(P(c),P(a)) if hs else 0)
rows=[(10,6,3,3,10,-20,0),(10,6,10,10,10,-20,0),(10,6,12,12,10,-20,100),(10,6,3,3,10,-20,299),(10,6,3,3,10,-20,300),(10,6,3,3,10,-20,600),(10,6,3,8,10,-20,0),(10,6,8,3,10,-20,400),(7,6,0,7,9,-18,0),(0,6,0,0,9,-18,0),(5,6,-1,-1,10,-20,0),(5,6,2,4,10,-20,300)]
rowcase(g,'6.5 cursor and selection of the current line: when the blink phase is on (floor(t / 300) even) the cursor at or past the end is the underscore at P(len), else a bar from y - 1 to y + line height at P(c); P(k) = width(first k) - width / 2; the selection a != c is the rectangle from min(P) to max(P) (length, advance, cursor, anchor, line height, y, ms since init -> kind 1 append 2 bar 0 none, x, top, bottom, selection, x0, x1)',rows,'CALL "MN8-SIGNCARET" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7',7,scaret)
W(g,6)
# ===== 7
g=G8(7,'Packet summary','T1103','the packets of the editors and what the server must accept (core/src/menu-40-8.cob).')
def pk(a): return {1:(24,0,1,1,0),2:(24,1,0,0,32),3:(62,0,0,0,0)}[a]
rowcase(g,'7 and 3.3 step 9, 4 behaviour 4: Done in the book editor sends 0x18 with the pages after the trailing-empty erase, the local stack updated and no title; Sign and Close sends 0x18 with the pages as they are now (no erase, no local copy) and the trimmed title (wire limit 32); any close of a sign editor sends 0x3E (action 1 Done 2 Sign and Close 3 sign close -> packet id, title present, erases trailing pages, updates local stack, title wire limit)',[(1,),(2,),(3,)],'CALL "MN8-PACKET" USING WS-I1 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5',5,pk)
rowcase(g,'7 the server must accept a book with zero pages, trailing empty pages (sign path), an empty title after trimming (Enter on spaces) and sign lines with a pasted line feed or tab; nothing else is promised (case 1 to 4 -> accepted, 5 -> 0)',[(1,),(2,),(3,),(4,),(5,),(0,)],'CALL "MN8-ACCEPT" USING WS-I1 WS-R1',1,lambda k:int(1<=k<=4))
rowcase(g,'7 and 8 example 9: the sign update carries the side as a VarInt (0 back, 1 front) and exactly four line strings with no count prefix (side -> side VarInt, line strings, count prefix present)',[(0,),(1,)],'CALL "MN8-SIGNPKT" USING WS-I1 WS-R1 WS-R2 WS-R3',3,lambda sd:(sd,4,0))
rowcase(g,'8 example 8: a book editor closed with Escape sends nothing and leaves the stack unchanged, Done sends one 0x18; a sign editor closed with Escape sends one 0x3E (screen 1 book edit 3 sign edit, how 1 Done 3 Escape -> packet id, title present)',[(1,3),(1,1),(3,3),(3,1)],'CALL "MN8-CLOSE" USING WS-I1 WS-I2 WS-R1 WS-R2',2,closep)
W(g,7)
