import sys,math,struct
sys.path.insert(0,'core/tests/gen')
from gen40d import *
ONLY=set(a for a in sys.argv[1:])
# Shared models and helpers of gen40_9 and gen40_x1 (docs/protocol/40-menus-9-block-editor-screens.md (sections 1 to 9, 10 and 11 as cases of section 9).
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
def c38(eid,cmd,tr): return (call9('MN9-BODY38',I_(eid)+[('t',cmd)]+I_(len(cmd),tr)),body38(eid,cmd,tr))
def c3b(x,y,z,n,t,p,f,j,sp,pp):
    return (call9('MN9-BODY3B',I_(x,y,z)+[('t',n)]+I_(len(n))+[('t',t)]+I_(len(t))+[('t',p)]+I_(len(p))+[('t',f)]+I_(len(f),j,sp,pp)),body3b(x,y,z,n,t,p,f,j,sp,pp))
def c3c(x,y,z,ut,mode,name,ox,oy,oz,sx,sy,sz,mirror,rot,meta,integ,seed,ign,air,bbox,strict):
    return (call9('MN9-BODY3C',I_(x,y,z,ut,mode)+[('t',name)]+I_(len(name),ox,oy,oz,sx,sy,sz,mirror,rot)+[('t',meta)]+I_(len(meta))+[('f',integ),('d',seed)]+I_(ign,air,bbox,strict)),
            body3c(x,y,z,ut,mode,name,ox,oy,oz,sx,sy,sz,mirror,rot,meta,integ,seed,ign,air,bbox,strict))
def c3d(x,y,z,mode,msg): return (call9('MN9-BODY3D',I_(x,y,z,mode)+[('t',msg)]+I_(len(msg))),body3d(x,y,z,mode,msg))
def c1b(x,y,z,l,k): return (call9('MN9-BODY1B',I_(x,y,z,l,k)),body1b(x,y,z,l,k))
