from g4 import *
import doc6,json,os
# layer id -> (rows, texture w, texture h, root scales); rows are doc6 rows (P and C records)
LAY={}
def setlayer(i,rows,w,h,sc=()): LAY[i]=(rows,w,h,list(sc))
def expected(layer):
    rows,w,h,sc=LAY[layer]; r=list(rows)
    for s in sc: r=scale_rows(r,s)
    return r,(w,h)
def pname(layer): return 'EF6-M-'+layer.replace('_','-')
def mesh_program(layer):
    rows,w,h,sc=LAY[layer]
    r=rows
    assert all(len(x)<=100 for x in r),[x for x in r if len(x)>100]
    assert len(r)<=80,len(r)
    o=[' IDENTIFICATION DIVISION.',' PROGRAM-ID. %s.'%pname(layer),' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-ROWS.']
    for x in r: o.append('    05 FILLER PIC X(100) VALUE "%s".'%x)
    o.append('    05 FILLER PIC X(100) VALUE SPACES OCCURS %d TIMES.'%(80-len(r)))
    o+=[' 01 WS-ROWS-R REDEFINES WS-ROWS.','    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.',' 01 WS-N                   BINARY-LONG VALUE %d.'%len(r),' 01 WS-ZERO                FLOAT-LONG VALUE 0.',' LINKAGE SECTION.',' COPY CLEMM.',
        ' PROCEDURE DIVISION USING EMM-MODEL.','     CALL "EMM-INIT" USING EMM-MODEL','     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO','     MOVE %s TO MM-TEXW'%w,'     MOVE %s TO MM-TEXH'%h,'     GOBACK.',' END PROGRAM %s.'%pname(layer),'']
    return '\n'.join(o)
STATE=HERE+'/state/layers6_done.json'
def done(): return json.load(open(STATE)) if os.path.exists(STATE) else []
def write_layers(new_ids):
    d=done()
    for i in new_ids:
        if i not in d: d.append(i)
    json.dump(d,open(STATE,'w'))
    o=['*> Entity models part 6: EF6-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-6 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.','*> The mesh programs EF6-M-<name> are in client/src/entmodel-34-6-<n>.cob.','',
       ' IDENTIFICATION DIVISION.',' PROGRAM-ID. EF6-LAYER.',' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-S                   FLOAT-LONG.',' LINKAGE SECTION.',' COPY CLEMM.',' 01 L-LAYER                PIC X(32).',' 01 L-OK                   BINARY-LONG.',
       ' PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.','     MOVE 1 TO L-OK','     EVALUATE L-LAYER']
    for i in d:
        rows,w,h,sc=LAY[i]
        o.append('         WHEN "%s"'%i); o.append('             CALL "%s" USING EMM-MODEL'%pname(i))
        for s in sc: o.append('             MOVE %s TO WS-S'%lit(s)); o.append('             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S')
    o+=['         WHEN OTHER','             MOVE 0 TO L-OK','     END-EVALUATE','     GOBACK.',' END PROGRAM EF6-LAYER.','']
    open(REPO+'client/src/entmodel-34-6-layers.cob','w').write('\n'.join(o))
def write_section_src(n,header,ids,extra=''):
    body=''.join(mesh_program(i)+'\n' for i in ids)
    open(REPO+('client/src/entmodel-34-6.cob' if n==1 else 'client/src/entmodel-34-6-%d.cob'%n),'w').write(header+'\n\n'+body+extra)
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
        if x[0]=='P': P[x[1]]=[float(v) for v in x[3:9]]+[1,1,1]
    return P
def pose_check(t,layer,prog,st,P,vis=None,tag=''):
    t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "%s" USING EMM-MODEL WS-IN'%prog)
    for part in sorted(P):
        for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
    for k,v in (vis or {}).items(): t.vis(k,v)
def text_check(t,prog,args,name,expected_text):
    t.raw('MOVE SPACES TO WS-X120'); t.setin(args); t.raw('CALL "%s" USING WS-IN WS-X120'%prog); t.text(name,expected_text,'WS-X120')
