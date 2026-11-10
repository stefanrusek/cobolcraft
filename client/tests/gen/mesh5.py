from g4 import *
import doc5,json,os
TAB=doc5.tables(5)
BYLINE={t['line']:t for t in TAB}
# layer id -> (table line, D, scales, texture w, h)
LAY={}
def al(ids,line,w,h,D='0',sc=()):
    for i in ids.split(): LAY[i]=(line,D,list(sc),w,h)
def expected(layer):
    line,D,sc,w,h=LAY[layer]
    r=doc5.conv(BYLINE[line]['rows'],D)
    for s in sc: r=scale_rows(r,s)
    return r,(w,h)
def pname(layer): return 'EF5-M-'+layer.replace('_','-')
def mesh_program(layer):
    line,D,sc,w,h=LAY[layer]
    r=doc5.conv(BYLINE[line]['rows'],D)
    assert all(len(x)<=100 for x in r),[x for x in r if len(x)>100]
    assert len(r)<=80
    o=[' IDENTIFICATION DIVISION.',' PROGRAM-ID. %s.'%pname(layer),' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-ROWS.']
    for x in r: o.append('    05 FILLER PIC X(100) VALUE "%s".'%x)
    o.append('    05 FILLER PIC X(100) VALUE SPACES OCCURS %d TIMES.'%(80-len(r)))
    o+=[' 01 WS-ROWS-R REDEFINES WS-ROWS.','    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.',' 01 WS-N                   BINARY-LONG VALUE %d.'%len(r),' 01 WS-ZERO                FLOAT-LONG VALUE 0.',' LINKAGE SECTION.',' COPY CLEMM.',
        ' PROCEDURE DIVISION USING EMM-MODEL.','     CALL "EMM-INIT" USING EMM-MODEL','     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO','     MOVE %s TO MM-TEXW'%w,'     MOVE %s TO MM-TEXH'%h,'     GOBACK.',' END PROGRAM %s.'%pname(layer),'']
    return '\n'.join(o)
STATE=HERE+'/state/layers5_done.json'
def done(): return json.load(open(STATE)) if os.path.exists(STATE) else []
def write_layers(new_ids):
    d=done()
    for i in new_ids:
        if i not in d: d.append(i)
    json.dump(d,open(STATE,'w'))
    o=['*> Entity models part 5: EF5-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-5 (ok 0 when the layer is not one of this document). Records: client/copy/CLEMM.cpy.','*> The mesh programs EF5-M-<name> are in client/src/entmodel-34-5-<n>.cob.','',
       ' IDENTIFICATION DIVISION.',' PROGRAM-ID. EF5-LAYER.',' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-S                   FLOAT-LONG.',' LINKAGE SECTION.',' COPY CLEMM.',' 01 L-LAYER                PIC X(32).',' 01 L-OK                   BINARY-LONG.',
       ' PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.','     MOVE 1 TO L-OK','     EVALUATE L-LAYER']
    for i in d:
        line,D,sc,w,h=LAY[i]
        o.append('         WHEN "%s"'%i); o.append('             CALL "%s" USING EMM-MODEL'%pname(i))
        for s in sc: o.append('             MOVE %s TO WS-S'%lit(s)); o.append('             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S')
    o+=['         WHEN OTHER','             MOVE 0 TO L-OK','     END-EVALUATE','     GOBACK.',' END PROGRAM EF5-LAYER.','']
    open(REPO+'client/src/entmodel-34-5-layers.cob','w').write('\n'.join(o))
def write_section_src(n,header,ids,extra=''):
    body=''.join(mesh_program(i)+'\n' for i in ids)
    open(REPO+'client/src/entmodel-34-5-%d.cob'%n,'w').write(header+'\n\n'+body+extra)
def mesh_checks(t,ids,tag):
    for i in ids:
        r,tex=expected(i); t.build(i); t.rows('%s %s'%(t.prefix,tag+' '+i),r)
        p,c=sizes(r); t.stats('%s %s'%(tag,i),p,c,float(tex[0]),float(tex[1]))
# wolf
al('WOLF',123,64,32); al('WOLF_ARMOR',123,64,32,D='0.2'); al('WOLF_BABY',145,32,32)
# cat and ocelot: tables at lines 242 (adult) and 257 (baby)
al('OCELOT',242,64,32); al('CAT',242,64,32,sc=[0.8]); al('CAT_COLLAR',242,64,32,D='0.01',sc=[0.8])
al('OCELOT_BABY CAT_BABY',257,32,32); al('CAT_BABY_COLLAR',257,32,32,sc=[1.01])
# fox: tables at 341 (adult) and 356 (baby)
al('FOX',341,48,32); al('FOX_BABY',356,32,32)
# panda 429/440, polar bear 517 (scaled 1.2)/528
al('PANDA',429,64,64); al('PANDA_BABY',440,64,64); al('POLAR_BEAR',517,128,64,sc=[1.2]); al('POLAR_BEAR_BABY',528,64,64)
al('PARROT',555,32,32)
# bat
al('BAT',620,32,32)
# bee
al('ARMADILLO',724,64,64); al('ARMADILLO_BABY',744,64,64)
al('BEE',651,64,64); al('BEE_BABY',667,32,32); al('BEE_STINGER',682,16,16)
