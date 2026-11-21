from g4 import *
import json,os
ORDER=['cow','cold_cow','warm_cow','cow_baby','pig','pig_saddle','cold_pig','pig_baby','sheep','sheep_wool','sheep_baby','chicken','cold_chicken','chicken_baby','goat','goat_baby',
'horse','horse_armor','horse_saddle','horse_baby','donkey','donkey_saddle','donkey_baby','llama','llama_baby','llama_spit','camel','camel_baby','camel_saddle','happy_ghast','happy_ghast_baby','happy_ghast_harness','happy_ghast_baby_harness','rabbit','rabbit_baby']
_ls=layers(4); assert len(_ls)==len(ORDER)
SRC={n:l for n,l in zip(ORDER,_ls)}
def rows_of(key):
    if '+' in key:
        b,a=key.split('+'); return SRC[b]['rows'],float(a),SRC[b]['tex']
    return SRC[key]['rows'],0.0,SRC[key]['tex']
def final_rows(key):
    r,a,tex=rows_of(key)
    return (grow_add(r,a) if a else list(r)),tex
LAY={}
def al(ids,src,sc=()):
    for i in ids.split(): LAY[i]=(src,list(sc))
al('COW','cow'); al('COLD_COW','cold_cow'); al('WARM_COW','warm_cow'); al('COW_BABY','cow_baby')
al('MOOSHROOM','cow'); al('MOOSHROOM_BABY WARM_COW_BABY COLD_COW_BABY','cow_baby')
al('PIG','pig'); al('PIG_SADDLE','pig_saddle'); al('COLD_PIG','cold_pig'); al('PIG_BABY','pig_baby')
al('SHEEP SHEEP_WOOL_UNDERCOAT','sheep'); al('SHEEP_WOOL','sheep_wool'); al('SHEEP_BABY SHEEP_BABY_WOOL','sheep_baby')
al('CHICKEN','chicken'); al('COLD_CHICKEN','cold_chicken'); al('CHICKEN_BABY','chicken_baby')
al('GOAT','goat'); al('GOAT_BABY','goat_baby')
al('HORSE','horse',[1.1]); al('SKELETON_HORSE ZOMBIE_HORSE','horse'); al('HORSE_ARMOR','horse_armor',[1.1]); al('UNDEAD_HORSE_ARMOR','horse_armor')
al('HORSE_SADDLE','horse_saddle',[1.1]); al('SKELETON_HORSE_SADDLE ZOMBIE_HORSE_SADDLE','horse_saddle')
al('HORSE_BABY SKELETON_HORSE_BABY ZOMBIE_HORSE_BABY','horse_baby')
al('DONKEY','donkey',[0.87]); al('MULE','donkey',[0.92]); al('DONKEY_SADDLE','donkey_saddle',[0.87]); al('MULE_SADDLE','donkey_saddle',[0.92]); al('DONKEY_BABY MULE_BABY','donkey_baby')
al('LLAMA TRADER_LLAMA','llama'); al('LLAMA_BABY TRADER_LLAMA_BABY','llama_baby'); al('LLAMA_DECOR','llama+0.5'); al('LLAMA_BABY_DECOR','llama_baby+0.2'); al('LLAMA_SPIT','llama_spit')
al('CAMEL','camel'); al('CAMEL_BABY','camel_baby'); al('CAMEL_SADDLE CAMEL_HUSK_SADDLE','camel_saddle')
al('HAPPY_GHAST','happy_ghast',[4]); al('HAPPY_GHAST_BABY','happy_ghast_baby',[4,0.2375]); al('HAPPY_GHAST_HARNESS','happy_ghast_harness',[4]); al('HAPPY_GHAST_BABY_HARNESS','happy_ghast_baby_harness',[4,0.2375,0.2375])
al('HAPPY_GHAST_ROPES','happy_ghast+0.2',[4]); al('HAPPY_GHAST_BABY_ROPES','happy_ghast_baby+0.2',[4,0.2375])
al('RABBIT','rabbit'); al('RABBIT_BABY','rabbit_baby')
def expected(layer):
    key,sc=LAY[layer]; r,tex=final_rows(key)
    for s in sc: r=scale_rows(r,s)
    return r,tex
def pname(key): return 'EF4-M-'+key.upper().replace('_','-').replace('+','-G').replace('.','P')
def mesh_program(key):
    r,tex=final_rows(key)
    assert all(len(x)<=100 for x in r)
    o=[' IDENTIFICATION DIVISION.',' PROGRAM-ID. %s.'%pname(key),' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-ROWS.']
    for x in r: o.append('    05 FILLER PIC X(100) VALUE "%s".'%x)
    o.append('    05 FILLER PIC X(100) VALUE SPACES OCCURS %d TIMES.'%(80-len(r)))
    o+=[' 01 WS-ROWS-R REDEFINES WS-ROWS.','    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.',' 01 WS-N                   BINARY-LONG VALUE %d.'%len(r),' 01 WS-ZERO                FLOAT-LONG VALUE 0.',' LINKAGE SECTION.',' COPY CLEMM.',
        ' PROCEDURE DIVISION USING EMM-MODEL.','     CALL "EMM-INIT" USING EMM-MODEL','     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO','     MOVE %s TO MM-TEXW'%tex[0],'     MOVE %s TO MM-TEXH'%tex[1],'     GOBACK.',' END PROGRAM %s.'%pname(key),'']
    return '\n'.join(o)
def sources_for(ids):
    out=[]
    for i in ids:
        k=LAY[i][0]
        if k not in out: out.append(k)
    return out
STATE=HERE+'/state/layers_done.json'
def done():
    return json.load(open(STATE)) if os.path.exists(STATE) else []
def write_layers(new_ids):
    d=done()
    for i in new_ids:
        if i not in d: d.append(i)
    json.dump(d,open(STATE,'w'))
    o=['*> Entity models part 4: EF4-LAYER model layer(X(32), the ModelLayers field name in upper case) ok(out): builds the model of a layer of 34-4 (the scaled layers carry the MeshTransformer.scaling steps of the document);','*> ok 0 when the layer is not one of this document. Records: client/copy/CLEMM.cpy. The mesh programs EF4-M-<name> are in client/src/entmodel-34-4-<n>.cob.','',
       ' IDENTIFICATION DIVISION.',' PROGRAM-ID. EF4-LAYER.',' DATA DIVISION.',' WORKING-STORAGE SECTION.',' 01 WS-S                   FLOAT-LONG.',' LINKAGE SECTION.',' COPY CLEMM.',' 01 L-LAYER                PIC X(32).',' 01 L-OK                   BINARY-LONG.',
       ' PROCEDURE DIVISION USING EMM-MODEL L-LAYER L-OK.','     MOVE 1 TO L-OK','     EVALUATE L-LAYER']
    for i in d:
        k,sc=LAY[i]
        o.append('         WHEN "%s"'%i)
        o.append('             CALL "%s" USING EMM-MODEL'%pname(k))
        for s in sc:
            o.append('             MOVE %s TO WS-S'%lit(s)); o.append('             CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-S')
    o+=['         WHEN OTHER','             MOVE 0 TO L-OK','     END-EVALUATE','     GOBACK.',' END PROGRAM EF4-LAYER.','']
    open(REPO+'client/src/entmodel-34-4-layers.cob','w').write('\n'.join(o))
def write_section_src(n,header,ids,extra=''):
    ks=sources_for(ids)
    dp=HERE+'/state/defined.json'
    dd=json.load(open(dp)) if os.path.exists(dp) else {}
    mine=[k for k,v in dd.items() if v==n]
    body=''
    for k in ks:
        if k in dd and dd[k]!=n: continue
        dd[k]=n; body+=mesh_program(k)+'\n'
    json.dump(dd,open(dp,'w'))
    open(REPO+'client/src/entmodel-34-4-%d.cob'%n,'w').write(header+'\n\n'+body+extra)
def mesh_checks(t,ids,tag):
    for i in ids:
        r,tex=expected(i)
        t.build(i); t.rows('%s %s'%(t.prefix,tag+' '+i),r)
        p,c=sizes(r)
        t.stats('%s %s'%(tag,i),p,c,float(tex[0]),float(tex[1]))
