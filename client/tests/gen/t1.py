from g4 import *
t=mk(4,1,["Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 1 (shared rules specific to these animals): 1.1 layer ids, 1.2 variants (model types, a null variant draws nothing),",
 "1.3 equipment layers (a baby with a null baby model never shows the item) and the layer type ordinals, 1.5 the layer registry table (shadow, models, layers in order), 1.6 ageScale and the baby shadow radius."])
REG=[('cow',0.7,'COW','COW_BABY',0),('mooshroom',0.7,'MOOSHROOM','MOOSHROOM_BABY',1),('pig',0.7,'PIG','PIG_BABY',1),('sheep',0.7,'SHEEP','SHEEP_BABY',2),('chicken',0.3,'CHICKEN','CHICKEN_BABY',0),
('goat',0.7,'GOAT','GOAT_BABY',0),('horse',0.75,'HORSE','HORSE_BABY',3),('donkey',0.75,'DONKEY','DONKEY_BABY',1),('mule',0.75,'MULE','MULE_BABY',1),('skeleton_horse',0.75,'SKELETON_HORSE','SKELETON_HORSE_BABY',2),
('zombie_horse',0.75,'ZOMBIE_HORSE','ZOMBIE_HORSE_BABY',2),('llama',0.7,'LLAMA','LLAMA_BABY',1),('trader_llama',0.7,'TRADER_LLAMA','TRADER_LLAMA_BABY',1),('llama_spit',0,'LLAMA_SPIT','',0),
('camel',0.7,'CAMEL','CAMEL_BABY',1),('camel_husk',0.7,'CAMEL','',1),('happy_ghast',2,'HAPPY_GHAST','HAPPY_GHAST_BABY',2),('rabbit',0.3,'RABBIT','RABBIT_BABY',0)]
for ent,sh,a,b,n in REG:
    t.raw('MOVE "%s" TO WS-X24'%ent,'CALL "EF4-REGISTRY" USING WS-X24 WS-IV(1) WS-X32 WS-X32B WS-FL')
    t.num('1.5 %s shadow radius'%ent,sh,'WS-IV(1)')
    t.text('1.5 %s adult model layer'%ent,a,'WS-X32'); t.text('1.5 %s baby model layer'%ent,b,'WS-X32B')
    t.num('1.5 %s layers after the body'%ent,n,'WS-FL')
for ent,base,ba in (('goat',0.7,0.55),('camel',0.7,0.6),('camel_husk',0.7,0.6),('happy_ghast',2,0.2375),('cow',0.7,0.5),('pig',0.7,0.5),('sheep',0.7,0.5),('llama',0.7,0.5),('horse',0.75,0.5),('donkey',0.75,0.5),('skeleton_horse',0.75,0.5),('chicken',0.3,0.5),('rabbit',0.3,0.5)):
    for baby in (0,1):
        a=ba if baby else 1
        t.raw('MOVE "%s" TO WS-X24'%ent,'MOVE %d TO WS-FL'%baby,'CALL "EF4-AGE-SCALE" USING WS-X24 WS-FL WS-IV(1)','CALL "EF4-SHADOW" USING WS-X24 WS-FL WS-IV(2)')
        t.num('1.6 %s baby %d ageScale'%(ent,baby),a,'WS-IV(1)')
        t.num('1.6 %s baby %d shadow radius'%(ent,baby),round(base*a,6),'WS-IV(2)')
for ent in ('goat','camel','happy_ghast','cow'):
    pass
# worked: sheep and equine inside-model ageScale
t.call('EF4-HEAD-EAT',[0.8,1],[7.2],'1.6 adult sheep head y += 0.8 x 9 x 1')
t.call('EF4-HEAD-EAT',[0.8,0.5],[3.6],'1.6 baby sheep head y += 0.8 x 9 x 0.5')
t.call('EF4-TAIL-OFFSET',[0.6,1],[0.6,1.2],'1.6 adult equine tail y and z offsets for s 0.6')
t.call('EF4-TAIL-OFFSET',[0.6,0.5],[0.3,0.6],'1.6 baby equine tail y and z offsets for s 0.6')
# 1.3
for eq in (0,1):
  for ass in (0,1):
    for baby in (0,1):
      for bm in (0,1):
        e=1 if (eq and ass and not (baby and not bm)) else 0
        t.call('EF4-EQUIP-DRAWN',[eq,ass,baby,bm],[e],'1.3 equippable %d asset %d baby %d baby model %d drawn'%(eq,ass,baby,bm))
for nm,o in (('horse_body',5),('llama_body',6),('pig_saddle',7),('camel_saddle',9),('camel_husk_saddle',10),('horse_saddle',11),('donkey_saddle',12),('mule_saddle',13),('zombie_horse_saddle',14),('skeleton_horse_saddle',15),('happy_ghast_body',16),('unknown_type',0)):
    t.raw('MOVE "%s" TO WS-X40'%nm,'CALL "EF4-LAYER-TYPE" USING WS-X40 WS-FL')
    t.num('1.3 layer type %s ordinal'%nm,o,'WS-FL')
for ent,k,o in (('horse',1,2),('horse',2,2),('donkey',2,0),('skeleton_horse',1,0),('skeleton_horse',2,0),('zombie_horse',2,0),('camel',2,0),('happy_ghast',1,0),('pig',2,0)):
    t.raw('MOVE "%s" TO WS-X24'%ent,'MOVE %d TO WS-FL'%k,'CALL "EF4-LAYER-ORDER" USING WS-X24 WS-FL WS-IV(1)')
    t.num('1.3 %s layer kind %d sub-order'%(ent,k),o,'WS-IV(1)')
# 1.2 variants
for kind,typ,baby,exp in (('cow','normal',0,'COW'),('cow','normal',1,'COW_BABY'),('cow','warm',0,'WARM_COW'),('cow','warm',1,'WARM_COW_BABY'),('cow','cold',0,'COLD_COW'),('cow','cold',1,'COLD_COW_BABY'),
  ('pig','normal',0,'PIG'),('pig','normal',1,'PIG_BABY'),('pig','cold',0,'COLD_PIG'),('pig','cold',1,'PIG_BABY'),('chicken','normal',0,'CHICKEN'),('chicken','normal',1,'CHICKEN_BABY'),('chicken','cold',0,'COLD_CHICKEN'),('chicken','cold',1,'CHICKEN_BABY')):
    t.raw('MOVE "%s" TO WS-X24'%kind,'MOVE "%s" TO WS-X40'%typ,'MOVE %d TO WS-FL'%baby,'CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32')
    t.text('1.2 %s model type %s baby %d layer'%(kind,typ,baby),exp,'WS-X32')
t.call('EF4-VARIANT-DRAW',[1],[0,1],'1.2 null variant: draws nothing, texture is the missing texture')
t.call('EF4-VARIANT-DRAW',[0],[1,0],'1.2 resolved variant: draws, texture from the variant')
save(t,4,1)
