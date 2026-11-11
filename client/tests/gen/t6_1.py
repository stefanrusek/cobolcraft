from mesh6 import *
ENDER=doc6.rows_from(6,'### 3.1')
def inline(t,rows):
    for i,r in enumerate(rows,1): t.raw('MOVE "%s" TO WS-RRV(%d)'%(r,i))
    t.raw('MOVE %d TO WS-CNT'%len(rows),'CALL "EMM-INIT" USING EMM-MODEL','CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO')
t=mk(6,1,["Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 1 (shared facts): 1.1 the table conventions (box unwrap rectangles, MeshTransformer.scaling on the cave spider root, retainExactParts and",
 "retainPartsAndChildren), 1.2 the degrees to radians constant, 1.3 the summary table of the sixteen renderers (texture size, shadow radius, flip degrees, layers in order)."],ck=True)
t.LP='EF6-LAYER'
t.extra_ws+='\n 01 WS-RR.\n    05 WS-RRV             PIC X(100) OCCURS 80 TIMES.\n 01 WS-ZERO               FLOAT-LONG VALUE 0.\n 01 WS-SC                 FLOAT-LONG.\n 01 WS-LN                PIC X(32).\n 01 WS-NAMES.\n    05 WS-NM              PIC X(24) OCCURS 8 TIMES.\n 01 WS-CNT                BINARY-LONG.\n 01 WS-FOUND              BINARY-LONG.'
# 1.1 box unwrap
for (u,v,w,h,d) in ((0,0,8,8,8),(16,16,8,12,4),(56,0,2,30,2),(0,9,8,1,8)):
    u0,u1,u2,u3,u4=u,u+d,u+d+w,u+2*d+w,u+2*d+2*w; v0,v1,v2=v,v+d,v+d+h
    t.call('EF6-BOX-UNWRAP',[u,v,w,h,d],[u0,u1,u2,u3,u4,v0,v1,v2],'1.1 box unwrap u %d v %d size %dx%dx%d (u0..u4, v0..v2)'%(u,v,w,h,d))
# 1.1 scaling: cave spider root pose
inline(t,['P head root 0 15 -3 0 0 0','C head 32 4 -4 -4 -8 8 8 8 0 0'])
t.raw('MOVE 0.7 TO WS-SC','CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-SC')
# the scaling is carried by the top-level parts (the implementation of the root pose of 34-1 5.2): position x s, y x s + 24.016 (1 - s), scale x s
t.cur('head','y',15*0.7+24.016*0.3); t.cur('head','z',-3*0.7); t.cur('head','xs',0.7); t.cur('head','ys',0.7); t.cur('head','zs',0.7)
for y,s in ((15,0.7),(24,0.7),(0,2.35),(24,1),(10,0.5)):
    t.call('EF6-SCALED-Y',[s,y],[24.016*(1-s)+s*y],'1.1 vertex y %s after scaling %s about the ground point 24.016'%(y,s))
# 1.1 retain
def retain(mode,names):
    parts=['head','hat','body','right_arm','left_arm','right_leg','left_leg']; par={'hat':'head'}
    def anc(n):
        a=par.get(n); 
        while a:
            if a in names: return True
            a=par.get(a)
        return False
    out={}
    for p in parts:
        if mode==1: out[p]=1 if (p in names and not anc(p)) else 0
        else: out[p]=1 if (p in names or anc(p)) else 0
    return out
for mode,names in ((1,['head']),(1,['head','hat']),(1,['hat']),(1,['body','left_leg']),(2,['head']),(2,['hat']),(2,['head','arms']),(2,['right_arm','left_arm','body'])):
    inline(t,ENDER)
    for k,nm in enumerate(names,1): t.raw('MOVE "%s" TO WS-NM(%d)'%(nm,k))
    t.raw('MOVE %d TO WS-CNT'%len(names),'CALL "EF6-RETAIN" USING EMM-MODEL %d WS-NAMES WS-CNT'%mode)
    for p,e in retain(mode,names).items():
        t.raw('MOVE "%s" TO WS-PN'%p,'CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P')
        t.num('1.1 %s %s %s: cuboids kept on %s'%('retainExactParts' if mode==1 else 'retainPartsAndChildren','/'.join(names),'',p),e,'MM-NCUBES(WS-P)')
t.call('EF6-DEG-TO-RAD',[90],[90*0.017453292],'1.2 90 degrees in radians (float constant 0.017453292)')
# 1.3 summary
SUM=[('creeper','CREEPER',64,32,0.5,90,['CreeperPowerLayer']),('enderman','ENDERMAN',64,32,0.5,90,['EnderEyesLayer','CarriedBlockLayer']),('endermite','ENDERMITE',64,32,0.3,180,[]),
 ('silverfish','SILVERFISH',64,32,0.3,180,[]),('spider','SPIDER',64,32,0.8,180,['SpiderEyesLayer']),('cave_spider','CAVE_SPIDER',64,32,0.56,180,['SpiderEyesLayer']),
 ('slime','SLIME',64,32,0.25,90,['SlimeOuterLayer']),('magma_cube','MAGMA_CUBE',64,64,0.25,90,[]),('sulfur_cube','SULFUR_CUBE',128,128,0.25,90,['SulfurCubeInnerLayer','CustomHeadLayer']),
 ('warden','WARDEN',128,128,0.9,90,['LivingEntityEmissiveLayer']*5),('breeze','BREEZE',32,32,0.5,90,['BreezeWindLayer','BreezeEyesLayer']),('phantom','PHANTOM',64,64,0.75,90,['PhantomEyesLayer']),
 ('guardian','GUARDIAN',64,64,0.5,90,[]),('elder_guardian','ELDER_GUARDIAN',64,64,1.2,90,[]),('shulker','SHULKER',64,64,0,90,[]),('shulker_bullet','SHULKER_BULLET',64,32,0,0,[])]
for ent,layer,w,h,sh,fl,lays in SUM:
    t.raw('MOVE "%s" TO WS-X24'%ent,'CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32')
    t.num('1.3 %s found'%ent,1,'WS-OV(1)'); t.text('1.3 %s main model layer'%ent,layer,'WS-X32')
    t.num('1.3 %s texture width'%ent,w,'WS-OV(2)'); t.num('1.3 %s texture height'%ent,h,'WS-OV(3)'); t.num('1.3 %s shadow radius'%ent,sh,'WS-OV(4)'); t.num('1.3 %s flip degrees (0 when the entity has no model flip)'%ent,fl,'WS-OV(5)'); t.num('1.3 %s layers added'%ent,len(lays),'WS-OV(6)')
    for k,l in enumerate(lays,1):
        t.raw('MOVE "%s" TO WS-X24'%ent,'MOVE %d TO WS-FL'%k,'CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('1.3 %s layer %d'%(ent,k),l,'WS-X32')
t.raw('MOVE "zombie" TO WS-X24','CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32'); t.num('1.3 an entity of another part is not found',0,'WS-OV(1)')
t.raw('MOVE "creeper" TO WS-X24','MOVE 2 TO WS-FL','MOVE "x" TO WS-X32','CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('1.3 a layer past the end is blank','','WS-X32')
t.raw('MOVE "sulfur_cube" TO WS-X24','CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32'); t.num('1.3 the baby sulfur cube layer width (SULFUR_CUBE_SMALL)',64,'WS-OV(7)'); t.num('1.3 the baby sulfur cube layer height',64,'WS-OV(8)')
t.raw('MOVE "creeper" TO WS-X24','CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32'); t.num('1.3 other entities have the same baby size',64,'WS-OV(7)')
save(t,6,1)
