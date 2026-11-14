from g4 import *
import doc8,json,os
# layer id -> (rows, texture w, texture h, root scales); rows are doc8 rows (P and C records)
LAY={}
SRC={}; RET={}; TEXO={}
def setlayer(i,rows,w,h,sc=(),src=None,retain=None):
    LAY[i]=(rows,w,h,list(sc)); SRC[i]=src or i; RET[i]=retain
    TEXO[i]=[w,h] if (src and src in LAY and (LAY[src][1],LAY[src][2])!=(w,h)) else None
    if retain: LAY[i]=(retained(rows,*retain),w,h,list(sc))
def retained(rows,mode,names):
    par={}
    for r in rows:
        x=r.split()
        if x[0]=='P': par[x[1]]=x[2]
    def anc(n):
        a=par.get(n)
        while a and a!='root':
            if a in names: return True
            a=par.get(a)
        return False
    keep=set(n for n in par if (mode==1 and n in names and not anc(n)) or (mode==2 and (n in names or anc(n))))
    return [r for r in rows if r.split()[0]=='P' or r.split()[1] in keep]
def expected(layer):
    rows,w,h,sc=LAY[layer]; r=list(rows)
    for s in sc: r=scale_rows(r,s)
    return r,(w,h)
def pname(layer): return 'EF8-M-'+layer.replace('_','-')
def mesh_program(layer):
    rows,w,h,sc=LAY[layer]
    r=rows
    assert all(len(x)<=100 for x in r),[x for x in r if len(x)>100]
    # chunks of at most 80 rows, split before a P row
    chunks=[];cur=[]
    for x in r:
        if x[0]=='P' and len(cur)>=70: chunks.append(cur); cur=[]
        cur.append(x)
    chunks.append(cur)
    o=[' IDENTIFICATION DIVISION.',' PROGRAM-ID. %s.'%pname(layer),' DATA DIVISION.',' WORKING-STORAGE SECTION.']
    for k,ch in enumerate(chunks,1):
        assert len(ch)<=80
        o.append(' 01 WS-ROWS%d.'%k)
        for x in ch: o.append('    05 FILLER PIC X(100) VALUE "%s".'%x)
        o.append('    05 FILLER PIC X(100) VALUE SPACES OCCURS %d TIMES.'%(80-len(ch)))
        o+=[' 01 WS-ROWS%d-R REDEFINES WS-ROWS%d.'%(k,k),'    05 WS-ROW%d             PIC X(100) OCCURS 80 TIMES.'%k,' 01 WS-N%d                  BINARY-LONG VALUE %d.'%(k,len(ch))]
    o+=[' 01 WS-ZERO                FLOAT-LONG VALUE 0.',' LINKAGE SECTION.',' COPY CLEMM.',' PROCEDURE DIVISION USING EMM-MODEL.','     CALL "EMM-INIT" USING EMM-MODEL']
    for k in range(1,len(chunks)+1): o.append('     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS%d-R WS-N%d WS-ZERO'%(k,k))
    o+=['     MOVE %s TO MM-TEXW'%w,'     MOVE %s TO MM-TEXH'%h,'     GOBACK.',' END PROGRAM %s.'%pname(layer),'']
    return '\n'.join(o)
STATE=HERE+'/state/layers8_done.json'
def done(): return json.load(open(STATE)) if os.path.exists(STATE) else {}
def write_layers(new_ids):
    d=done()
    for i in new_ids: d[i]=[LAY[i][3],SRC[i],RET[i],TEXO[i]]
    json.dump(d,open(STATE,'w'))
    o=['*> Entity models part 8: EF8-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-8 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.','*> The mesh programs EF8-M-<name> are in client/src/entmodel-34-8-<n>.cob.','',
       ' IDENTIFICATION DIVISION.',' PROGRAM-ID. EF8-LAYER.',' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-S                   FLOAT-LONG.',' 01 WS-MODE                BINARY-LONG.',' 01 WS-CNT                 BINARY-LONG.',' 01 WS-NAMES.','    05 WS-NM                PIC X(24) OCCURS 8 TIMES.',' LINKAGE SECTION.',' COPY CLEMM.',' 01 L-LAYER                PIC X(32).',' 01 L-OK                   BINARY-LONG.',
       ' PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.','     MOVE 1 TO L-OK','     EVALUATE L-LAYER']
    for i,(sc,src,ret,texo) in d.items():
        o.append('         WHEN "%s"'%i); o.append('             CALL "%s" USING EMM-MODEL'%pname(src))
        if texo:
            o.append('             MOVE %s TO MM-TEXW'%texo[0]); o.append('             MOVE %s TO MM-TEXH'%texo[1])
        if ret:
            for k,nm in enumerate(ret[1],1): o.append('             MOVE "%s" TO WS-NM(%d)'%(nm,k))
            o.append('             MOVE %d TO WS-CNT'%len(ret[1])); o.append('             MOVE %d TO WS-MODE'%ret[0]); o.append('             CALL "EF8-RETAIN" USING EMM-MODEL WS-MODE WS-NAMES WS-CNT')
        for s in sc: o.append('             MOVE %s TO WS-S'%lit(s)); o.append('             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S')
    o+=['         WHEN OTHER','             MOVE 0 TO L-OK','     END-EVALUATE','     GOBACK.',' END PROGRAM EF8-LAYER.','']
    open(REPO+'client/src/entmodel-34-8-layers.cob','w').write('\n'.join(o))
def write_section_src(n,header,ids,extra=''):
    body=''.join(mesh_program(i)+'\n' for i in ids)
    open(REPO+('client/src/entmodel-34-8.cob' if n==0 else 'client/src/entmodel-34-8-%d.cob'%n),'w').write(header+'\n\n'+body+extra)
def mesh_checks(t,ids,tag):
    for i in ids:
        r,tex=expected(i); t.build(i); t.rows('%s %s'%(t.prefix,tag+' '+i),r)
        p,c=sizes(r); t.stats('%s %s'%(tag,i),p,c,float(tex[0]),float(tex[1]))
import math
FIELDS=('x','y','z','xrot','yrot','zrot','xs','ys','zs')
def base_parts(layer):
    P={}
    for r in expected(layer)[0]:
        x=r.split()
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+([float(v) for v in x[9:12]] if len(x)>=12 else [1,1,1])
    return P
def pose_check(t,layer,prog,st,P,vis=None,tag=''):
    t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "%s" USING EMM-MODEL WS-IN'%prog)
    for part in sorted(P):
        for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
    for k,v in (vis or {}).items(): t.vis(k,v)
def text_check(t,prog,args,name,expected_text):
    t.raw('MOVE SPACES TO WS-X120'); t.setin(args); t.raw('CALL "%s" USING WS-IN WS-X120'%prog); t.text(name,expected_text,'WS-X120')
STATE_WS="""
 01 WS-ST.
    05 WS-SV               FLOAT-LONG OCCURS 48 TIMES.
 01 WS-VAR                BINARY-LONG VALUE 0.
 01 WS-CAR                BINARY-LONG.
 01 WS-CRE                BINARY-LONG."""
def humanoid_state(t,vals):
    """vals: dict index (1-based) -> value of the 48-float humanoid state; the others are 0"""
    t.raw('INITIALIZE WS-ST')
    for k,v in sorted(vals.items()): t.raw('MOVE %s TO WS-SV(%d)'%(lit(v),k))
def base_humanoid(P,xr,yr,wp,ws,sv,age):
    PI=3.1415927
    h=P['head']; h[3]=xr*0.017453292; h[4]=yr*0.017453292
    ra,la,rl,ll=P['right_arm'],P['left_arm'],P['right_leg'],P['left_leg']
    ra[3]=math.cos(wp*0.6662+PI)*2*ws*0.5/sv; la[3]=math.cos(wp*0.6662)*2*ws*0.5/sv
    rl[3]=math.cos(wp*0.6662)*1.4*ws/sv; ll[3]=math.cos(wp*0.6662+PI)*1.4*ws/sv
    rl[4]=0.005; ll[4]=-0.005; rl[5]=0.005; ll[5]=-0.005
    z=math.cos(age*0.09)*0.05+0.05; x=math.sin(age*0.067)*0.05
    ra[5]+=z; ra[3]+=x; la[5]-=z; la[3]-=x
