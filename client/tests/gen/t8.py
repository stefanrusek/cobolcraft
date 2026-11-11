from mesh4 import *
t=mk(4,8,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 8 (Equines): 8.2 the renderer registrations (saddle layer type and scale, textures), 8.3 setupAnim of AbstractEquineModel with the hook constants of",
 "the horse, baby horse and baby donkey (each of the twelve steps, the worked example 3 and 5 of the document), 8.4 chests, the baby donkey state write, the saddle reins, 8.5 variants, body textures and markings (with the wrapping id",
 "maps), 8.6 the geometry of horse, horse_armor, horse_saddle, horse_baby, donkey, donkey_saddle, donkey_baby and the unscaled and mule aliases. Mesh rows are the tables of the document; formula values were worked by an",
 "independent script. Pivot offsets of the scaled layers are carried in the pixels of the root's children (EMD-SCALE-ROOT), so an additive pivot offset is multiplied by the layer scale."],ck=True)
IDS=['HORSE','SKELETON_HORSE','ZOMBIE_HORSE','HORSE_ARMOR','UNDEAD_HORSE_ARMOR','HORSE_SADDLE','SKELETON_HORSE_SADDLE','ZOMBIE_HORSE_SADDLE','HORSE_BABY','SKELETON_HORSE_BABY','ZOMBIE_HORSE_BABY','DONKEY','MULE','DONKEY_SADDLE','MULE_SADDLE','DONKEY_BABY','MULE_BABY']
mesh_checks(t,IDS,'8.6')
# 8.2 registrations
REG=[('horse','horse_saddle',1.1,'textures/entity/horse/horse_white.png'),('donkey','donkey_saddle',0.87,'textures/entity/horse/donkey.png'),('mule','mule_saddle',0.92,'textures/entity/horse/mule.png'),
 ('skeleton_horse','skeleton_horse_saddle',1,'textures/entity/horse/horse_skeleton.png'),('zombie_horse','zombie_horse_saddle',1,'textures/entity/horse/horse_zombie.png')]
for ent,lt,sc,tx in REG:
    t.raw('MOVE "%s" TO WS-X24'%ent,'CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)')
    t.text('8.2 %s saddle layer type'%ent,lt,'WS-X40'); t.num('8.2 %s saddle model scale'%ent,sc,'WS-IV(1)')
for ent,b,tx in (('donkey',0,'textures/entity/horse/donkey.png'),('donkey',1,'textures/entity/horse/donkey_baby.png'),('mule',0,'textures/entity/horse/mule.png'),('mule',1,'textures/entity/horse/mule_baby.png'),
  ('skeleton_horse',0,'textures/entity/horse/horse_skeleton.png'),('skeleton_horse',1,'textures/entity/horse/horse_skeleton_baby.png'),('zombie_horse',0,'textures/entity/horse/horse_zombie.png'),('zombie_horse',1,'textures/entity/horse/horse_zombie_baby.png')):
    t.raw('MOVE "%s" TO WS-X24'%ent,'MOVE %d TO WS-FL'%b,'CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120'); t.text('8.2 %s baby %d texture'%(ent,b),tx,'WS-X120')
# 8.5 variants
VAR=['white','creamy','chestnut','brown','black','gray','darkbrown']
for vid in (0,1,2,3,4,5,6,7,8,13,-1):
    o=vid%7
    t.call('EF4-HORSE-VARIANT',[vid],[o],'8.5 horse colour id %d (the id map wraps)'%vid)
    for b in (0,1):
        t.raw('MOVE %d TO WS-IV(1)'%o,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120')
        t.text('8.5 horse colour %d baby %d texture'%(o,b),'textures/entity/horse/horse_%s%s.png'%(VAR[o],'_baby' if b else ''),'WS-X120')
MK=['','white','whitefield','whitedots','blackdots']
for mid in (0,1,2,3,4,5,9,-2):
    o=mid%5
    t.call('EF4-HORSE-MARKING-ID',[mid],[o],'8.5 marking id %d (wraps)'%mid)
    for b in (0,1):
        t.raw('MOVE %d TO WS-IV(1)'%o,'MOVE %d TO WS-IV(2)'%b,'CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120')
        t.text('8.5 marking %d baby %d texture (spaces: none)'%(o,b),'' if o==0 else 'textures/entity/horse/horse_markings_%s%s.png'%(MK[o],'_baby' if b else ''),'WS-X120')
for has in (0,1):
    for inv in (0,1):
        t.call('EF4-MARKING-DRAW',[has,inv],[1 if (has and not inv) else 0],'8.5 marking texture %d invisible %d: layer drawn'%(has,inv))
# 8.3 anim
def lerp(a,b,c): return b+a*(c-b)
def run(layer,kind,sc,donkey,saddle,st):
    pitch_d,yaw_d,p,s,eat,stand,feed,age,ages,tail,water,chest,ridden=st
    rows=expected(layer)[0]
    init={}
    for r in rows:
        x=r.split()
        if x[0]=='P': init[x[1]]=[float(v) for v in x[3:9]]
    out={}
    yaw=max(-20,min(20,yaw_d)); pitch=pitch_d*D
    if s>0.2: pitch+=math.cos(0.8*p)*0.15*s
    w=0.2 if water else 1
    c=math.cos(w*p*0.6662+math.pi); leg=c*0.8*s
    graz=(1-max(stand,eat))*((0.5235988+pitch)+feed*math.sin(age)*0.05)
    hx=stand*(0.2617994+pitch)+eat*(2.1816616+math.sin(age)*0.05)+graz
    hy=stand*yaw*D+(1-max(stand,eat))*(yaw*D)
    hpy,hpz=init['head_parts'][1],init['head_parts'][2]
    if kind==0: hpy+=sc*lerp(eat,lerp(stand,0,-8),7); hpz=lerp(stand,hpz,-4*sc)
    elif kind==1: hpy+=lerp(eat,lerp(stand,0,-2),2); hpz=lerp(stand,hpz,-4)
    else: hpy=lerp(eat,hpy,-1.2); hpz=lerp(stand,hpz,-3.6)
    bx=stand*(-0.7853982)+(1-stand)*init['body'][3]
    legy={0:12,1:4,2:1}[kind]*sc; legz={0:4,1:0,2:0.5}[kind]*sc
    lfy=init['left_front_leg'][1]-legy*stand; lfz=init['left_front_leg'][2]+legz*stand
    ang={0:0.2617994,1:0.2617994,2:1.0471976}[kind]*stand
    x0={0:-1.0471976,1:-1.0471976,2:0}[kind]
    wv=math.cos(age*0.6+math.pi)
    fl=(x0+wv)*stand+leg*(1-stand); fr=(x0-wv)*stand-leg*(1-stand)
    lh=ang-(c*0.5*s)*(1-stand); rh=ang+(c*0.5*s)*(1-stand)
    lhy=init['left_hind_leg'][1]; rhy=init['right_hind_leg'][1]
    if kind==2:
        lhy=lerp(stand,lhy,-0.3); rhy=lerp(stand,lhy,-0.3)
    tx={0:0,1:-1.5707964,2:-0.7853982}[kind]+0.5235988+s*0.75
    ty=init['tail'][1]+s*ages; tz=init['tail'][2]+s*2*ages
    tyr=math.cos(age*0.7) if tail else 0
    if kind==2:
        p2=-30*D
        hx=stand*(0.2617994+p2)+eat*(1.5707964+math.sin(age)*0.05)+(1-max(stand,eat))*((0.5235988+p2)+feed*math.sin(age)*0.05)
    res=[('head_parts','xrot',hx),('head_parts','yrot',hy),('head_parts','y',hpy),('head_parts','z',hpz),('body','xrot',bx),('left_front_leg','y',lfy),('left_front_leg','z',lfz),('right_front_leg','y',lfy),('right_front_leg','z',lfz),
      ('left_hind_leg','xrot',lh),('right_hind_leg','xrot',rh),('left_front_leg','xrot',fl),('right_front_leg','xrot',fr),('tail','xrot',tx),('tail','y',ty),('tail','z',tz),('tail','yrot',tyr)]
    if kind==2: res+=[('left_hind_leg','y',lhy),('right_hind_leg','y',rhy)]
    if donkey: res+=[('left_chest','vis',chest),('right_chest','vis',chest)]
    if saddle: res+=[('left_saddle_line','vis',ridden),('right_saddle_line','vis',ridden)]
    return res,(-30 if kind==2 else None)
STATES=[(12,-35,1.7,0.9,0,0,0,40,1,1,0,1,1),(-20,8,3.1,0.1,0.4,0.3,0.6,17.5,0.5,0,1,0,0),(5,-10,0.5,0.5,1,0,1,3.3,1,1,0,1,0),(0,10,0,0,0,1,0,0,1,0,0,0,0),(25,15,2.2,0.7,0.2,0.8,0.3,9,0.5,1,1,1,1),(3,35,0.9,0.4,0,0.2,0,5,1,0,0,1,1)]
CASES=[('HORSE',0,1.1,0,0),('SKELETON_HORSE',0,1,0,0),('HORSE_BABY',1,1,0,0),('HORSE_SADDLE',0,1.1,0,1),('DONKEY',0,0.87,1,0),('MULE',0,0.92,1,0),('DONKEY_BABY',2,1,1,0),('DONKEY_SADDLE',0,0.87,0,1),('ZOMBIE_HORSE_BABY',1,1,0,0)]
for layer,kind,sc,donkey,saddle in CASES:
    for st in STATES:
        t.raw('MOVE "%s" TO WS-LAYER'%layer,'CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK')
        t.raw('MOVE 3 TO MM-CXROT(2)')
        args=list(st)
        pitch_d,yaw_d,p,s,eat,stand,feed,age,ages,tail,water,chest,ridden=st
        t.setin([pitch_d,yaw_d,p,s,eat,stand,feed,age,ages,tail,water,kind,chest,ridden,donkey,saddle])
        t.raw('CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN')
        res,wr=run(layer,kind,sc,donkey,saddle,st)
        pre='8.3 %s state %s '%(layer,'/'.join(lit(float(v)) for v in st[:7]))
        for part,f,v in res:
            t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
            if f=='vis': t.num(pre+part+' visible',v,'MM-VISIBLE(WS-P)')
            else: t.num(pre+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
        if wr is not None: t.num(pre+'state xRot written (-30)',wr,'WS-IV(1)')
# doc worked example 3: pivots before scaling (unscaled layer)
t.raw('MOVE "SKELETON_HORSE" TO WS-LAYER','CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([0,10,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0]); t.raw('CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN')
for part,f,v in (('head_parts','xrot',0.2617994),('head_parts','yrot',0.1745329),('head_parts','y',-4),('head_parts','z',-4),('body','xrot',-0.7853982),('left_front_leg','y',2),('left_front_leg','z',-6),('right_front_leg','y',2),('right_front_leg','z',-6),('left_front_leg','xrot',-2.0471976),('right_front_leg','xrot',-0.0471976),('left_hind_leg','xrot',0.2617994),('right_hind_leg','xrot',0.2617994),('tail','xrot',0.5235988),('tail','yrot',0)):
    t.raw('MOVE "%s" TO WS-PN'%part,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num('8.3 worked example 3 '+part+'.'+f,v,'MM-C%s(WS-P)'%f.upper())
# worked example 5
for stand,e in ((0,0),(1,-0.2617994)):
    t.raw('MOVE "DONKEY_BABY" TO WS-LAYER','CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK'); t.setin([25,0,0,0,0,stand,0,11,0.5,0,0,2,0,0,1,0]); t.raw('CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN')
    t.raw('MOVE "head_parts" TO WS-PN','CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P'); t.num('8.3 worked example 5 baby donkey head stand %d'%stand,e,'MM-CXROT(WS-P)')
save(t,4,8)
