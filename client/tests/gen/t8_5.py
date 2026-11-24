from aq8b import *
import math
define_aq()
t=mk(8,5,["Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 5 (fish): 5.1 cod, 5.2 salmon (three sizes through MeshTransformer.scaling), 5.3 pufferfish (three models), 5.4 tropical fish (base and pattern layers, grow 0.008),",
 "the meshes (every part, pose and box of the tables), setupAnim of every fish in water and out of it, setupRotations (ENTITY-FISH-SEQUENCE), the salmon size ids (clamped), the pufferfish model and shadow by puff state, the tropical fish packed variant",
 "(12 patterns, the sparse id map with default kob, the dye id map with default white, the tints and pattern textures), and the worked examples E7 to E10 and the Validation rows for the fish."],ck=True)
t.LP='EF8-LAYER'
t.extra_ws+='''
 COPY CLSTATE.
 COPY CLMODELS.
 01 WS-RMODEL              BINARY-LONG.
 01 WS-RKEY                PIC X(24).
 01 WS-RR                  FLOAT-LONG.
 01 WS-RG                  FLOAT-LONG.
 01 WS-RB                  FLOAT-LONG.
 01 WS-RCODE               BINARY-LONG.
 01 WS-RPATH               PIC X(64).
 01 WS-RK20                PIC X(20).'''
IDS=['COD','SALMON','SALMON_SMALL','SALMON_LARGE','PUFFERFISH_SMALL','PUFFERFISH_MEDIUM','PUFFERFISH_BIG','TROPICAL_SMALL','TROPICAL_SMALL_PATTERN','TROPICAL_LARGE','TROPICAL_LARGE_PATTERN']
mesh_checks(t,IDS,'5')
# Validation: pufferfish parts 6, 11, 13
for l,n in (('PUFFERFISH_SMALL',6),('PUFFERFISH_MEDIUM',11),('PUFFERFISH_BIG',13)):
    t.raw('MOVE "%s" TO WS-LAYER'%l,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK','CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES'); t.num('Validation %s has %d parts'%(l,n),n,'WS-PARTS')
def sin(x): return math.sin(x)
def fish(layer,kind,age,wet):
    P=base_parts(layer)
    f=1 if wet else 1.5
    if kind==1: P['tail_fin'][4]=-f*0.45*sin(0.6*age)
    elif kind==2: P['tail'][4]=-f*0.45*sin(0.6*age)
    elif kind==3:
        a,b=(1,1) if wet else (1.3,1.7)
        P['body_back'][4]=-a*0.25*sin(b*0.6*age)
    else:
        r='right_fin' if 'right_fin' in P else 'right_blue_fin'; l='left_fin' if 'left_fin' in P else 'left_blue_fin'
        P[r][5]=-0.2+0.4*sin(0.2*age); P[l][5]=0.2-0.4*sin(0.2*age)
    return P
KIND={'COD':1,'TROPICAL_SMALL':2,'TROPICAL_LARGE':2,'TROPICAL_SMALL_PATTERN':2,'TROPICAL_LARGE_PATTERN':2,'SALMON':3,'SALMON_SMALL':3,'SALMON_LARGE':3,'PUFFERFISH_SMALL':4,'PUFFERFISH_MEDIUM':4,'PUFFERFISH_BIG':4}
def anim_parts(t,layer,prog,st,P,names):
    t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.raw('MOVE 3 TO MM-CXROT(2)'); t.setin(list(st)); t.raw('CALL "%s" USING EMM-MODEL WS-IN'%prog)
    for part in names:
        for kx,f in enumerate(FIELDS): t.cur(part,f,P[part][kx])
FINS={1:['tail_fin','body'],2:['tail','body'],3:['body_back','body_front'],4:['right_fin','left_fin','right_blue_fin','left_blue_fin','body']}
for layer in IDS:
    for age,wet in ((5,1),(5,0),(0,1),(12.5,0)):
        P=fish(layer,KIND[layer],age,wet)
        anim_parts(t,layer,'EF8-FISH-ANIM',[KIND[layer],age,wet],P,[n for n in FINS[KIND[layer]] if n in P])
# worked examples
def one(layer,kind,age,wet,part,field,exp,name):
    t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([kind,age,wet]); t.raw('CALL "EF8-FISH-ANIM" USING EMM-MODEL WS-IN'); t.cur(part,field,exp)
    t.comment(name)
one('COD',1,5,0,'tail_fin','yrot',-0.09526,'E7 cod on land'); one('COD',1,5,1,'tail_fin','yrot',-0.06350,'E7 cod in water')
one('SALMON_SMALL',3,5,0,'body_back','yrot',0.3009,'E8 salmon out of water'); one('SALMON_SMALL',3,5,0,'root','x',0,'E8 placeholder') if False else None
t.cur('body_back','ys',0.5) if False else None
t.raw('MOVE "SALMON_SMALL" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.cur('body_front','ys',0.5); t.cur('body_front','y',20*0.5+12.008)
t.raw('MOVE "SALMON_LARGE" TO WS-LAYER','CALL "EF8-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.cur('body_front','xs',1.5); t.cur('body_front','y',20*1.5-12.008)
one('PUFFERFISH_MEDIUM',4,20,1,'right_blue_fin','zrot',-0.2+0.4*sin(4),'E10'); t.cur('left_blue_fin','zrot',0.2-0.4*sin(4))
# setupRotations: the ops of ENTITY-FISH-SEQUENCE (count, then code and three values per op)
def seq(key,yaw,age,dry):
    ops=[]
    if key=='pufferfish': ops.append((1,0,math.cos(0.05*age)*0.08,0))
    ops.append((3,180-yaw,0,0))
    if key!='pufferfish':
        a,b=(1.3,1.7) if (key=='salmon' and dry) else (1,1)
        ops.append((3,a*4.3*sin(b*0.6*age),0,0))
        if dry:
            ops.append((1,0.1,0.1,-0.1) if key=='cod' else (1,0.2,0.1,0)); ops.append((7,90,0,0))
    ops+= [(2,-1,-1,1),(1,0,-1.501,0)]
    return [len(ops)]+[v for o in ops for v in o]
for key,yaw,age,dry in (('cod',0,5,0),('cod',30,5,1),('salmon',90,5,0),('salmon',90,5,1),('tropical_fish',-45,7.5,0),('tropical_fish',10,2,1),('pufferfish',20,20,0),('pufferfish',0,0,1)):
    t.raw('MOVE "%s" TO EN-KEY(1)'%key,'MOVE %d TO EN-DRY(1)'%dry,'MOVE %s TO EN-AGE(1)'%lit(age),'MOVE %s TO EN-YAW(1)'%lit(yaw),'MOVE 1 TO WS-FL','CALL "ENTITY-FISH-SEQUENCE" USING CLIENT-STATE WS-FL WS-OUT')
    for k,v in enumerate(seq(key,yaw,age,dry)): t.num('5 setupRotations %s yaw %s age %s dry %d value %d'%(key,yaw,age,dry,k+1),v,'WS-OV(%d)'%(k+1))
# renderer facts of 5.2 and 5.3 and the tropical fish variant fields (5.4)
for i,s in ((-3,0),(0,0),(1,1),(2,2),(3,2),(9,2)):
    t.call('EF8-SALMON-SIZE',[i],[s],'5.2 salmon variant id %d gives size %d (ids are clamped to 0..2)'%(i,s))
for p,m in ((0,0),(1,1),(2,2),(3,2),(7,2)):
    t.call('EF8-PUFFER-MODEL',[p],[m],'5.3 puff state %d draws model %d (0 small, 1 medium, any other value big)'%(p,m))
for p in (0,1,2):
    t.call('EF8-PUFFER-SHADOW',[p],[0.1+0.1*p],'5.3 shadow radius of puff state %d'%p)
PAT=[('kob',0,0),('sunstreak',0,1),('snooper',0,2),('dasher',0,3),('brinely',0,4),('spotty',0,5),('flopper',1,0),('stripey',1,1),('glitter',1,2),('blockfish',1,3),('betty',1,4),('clayfish',1,5)]
PID=[b|(n<<8) for _,b,n in PAT]
DYE=[0xF9FFFE,0xF9801D,0xC74EBD,0x3AB3DA,0xFED83D,0x80C71F,0xF38BAA,0x474F52,0x9D9D97,0x169C9C,0x8932B8,0x3C44AA,0x835432,0x5E7C16,0xB02E26,0x1D1D21]
def dec(p):
    low=p&0xFFFF; o=PID.index(low) if low in PID else 0
    bc=(p>>16)&255; pc=(p>>24)&255
    bc=bc if bc<16 else 0; pc=pc if pc<16 else 0
    return [o,PAT[o][1],PAT[o][2],bc,pc,DYE[bc],DYE[pc]]
t.comment('E9: stripey, red base, white pattern colour packs to 917761')
assert 257|(14<<16)|(0<<24)==917761
t.raw('COMPUTE WS-RMODEL = 257 + 14 * 65536'); t.num('E9 packed value stripey, red, white',917761,'WS-RMODEL')
for p in (917761,0,256,1281,257|(3<<16)|(15<<24),2,1+7*256,5|(16<<16)|(255<<24),65536*20+6,(1<<30)+1):
    t.call('EF8-TROPICAL-DECODE',[p],dec(p),'5.4 decode packed %d (ordinal, base, index, base colour id, pattern colour id, base RGB, pattern RGB)'%p)
for o,(nm,b,n) in enumerate(PAT):
    t.call('EF8-TROPICAL-DECODE',[PID[o]],dec(PID[o]),'5.4 the packed id %d is the pattern %s'%(PID[o],nm))
for k in range(16):
    t.call('EF8-TROPICAL-DECODE',[k*65536],dec(k*65536),'5.4 dye %d diffuse colour'%k)
# the replica row: model row, pattern texture code, tints (E9)
def trop(p):
    t.raw('MOVE "tropical_fish" TO EN-KEY(1)','MOVE %d TO EN-VAR(1)'%p,'MOVE "tropical_fish" TO WS-RKEY','CALL "ENTITY-MODEL-FIND" USING WS-RKEY EN-MODEL(1)','CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-FL WS-RMODEL')
for p in (917761,0,256,1281,2,1+7*256,769+(3<<16)):
    d=dec(p); trop(p)
    t.raw('MOVE 1 TO WS-FL','CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-FL WS-RMODEL','MOVE CL-MD-KEY(WS-RMODEL) TO WS-RK20')
    t.text('5.4 packed %d draws the %s model'%(p,'large' if d[1] else 'small'),'tropical_fish~l' if d[1] else 'tropical_fish','WS-RK20')
    t.raw('MOVE "tropical_pattern" TO WS-RKEY' if not d[1] else 'MOVE "tropical_pattern~l" TO WS-RKEY','CALL "ENTITY-MODEL-FIND" USING WS-RKEY WS-RMODEL')
    t.raw('CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-FL WS-RMODEL WS-RCODE'); t.num('5.4 packed %d pattern texture code (index + 1)'%p,d[2]+1,'WS-RCODE')
    t.raw('CALL "ENTITY-TINT" USING CLIENT-STATE WS-FL WS-RMODEL WS-RR WS-RG WS-RB')
    t.num('5.4 packed %d pattern tint red'%p,((d[6]>>16)&255)/255,'WS-RR'); t.num('5.4 packed %d pattern tint green'%p,((d[6]>>8)&255)/255,'WS-RG'); t.num('5.4 packed %d pattern tint blue'%p,(d[6]&255)/255,'WS-RB')
    t.raw('MOVE "tropical_fish~l" TO WS-RKEY' if d[1] else 'MOVE "tropical_fish" TO WS-RKEY','CALL "ENTITY-MODEL-FIND" USING WS-RKEY WS-RMODEL','CALL "ENTITY-TINT" USING CLIENT-STATE WS-FL WS-RMODEL WS-RR WS-RG WS-RB')
    t.num('5.4 packed %d base tint red'%p,((d[5]>>16)&255)/255,'WS-RR'); t.num('5.4 packed %d base tint green'%p,((d[5]>>8)&255)/255,'WS-RG'); t.num('5.4 packed %d base tint blue'%p,(d[5]&255)/255,'WS-RB')
save(t,8,5)
