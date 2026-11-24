from mesh7 import *
t=mk(7,10,["Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 10 (layer and texture summary): for each of the ten entities the texture size of the layer, the shadow radius, the block light level (15 or 0 for the state default),",
 "the model layers in the order of the table and the texture images with their paths, and section 10.1 (shadow radius, extra layers)."],ck=False)
t.extra_ws+='\n 01 WS-X60               PIC X(60).'
ENT=[('blaze',64,32,0.5,15,['BLAZE'],['blaze/blaze.png']),('ghast',64,32,1.5,0,['GHAST'],['ghast/ghast.png','ghast/ghast_shooting.png']),
 ('strider',64,128,0.5,0,['STRIDER','STRIDER_SADDLE','STRIDER_BABY'],['strider/strider.png','strider/strider_cold.png','strider/strider_baby.png','strider/strider_cold_baby.png','equipment/strider_saddle/saddle.png']),
 ('hoglin',128,64,0.7,0,['HOGLIN','HOGLIN_BABY'],['hoglin/hoglin.png','hoglin/hoglin_baby.png']),('zoglin',128,64,0.7,0,['ZOGLIN','ZOGLIN_BABY'],['hoglin/zoglin.png','hoglin/zoglin_baby.png']),
 ('wither',64,64,1.0,15,['WITHER','WITHER_ARMOR'],['wither/wither.png','wither/wither_invulnerable.png','wither/wither_armor.png']),('wither_skull',64,64,0,15,['WITHER_SKULL'],['wither/wither.png','wither/wither_invulnerable.png']),
 ('end_crystal',64,32,0.5,0,['END_CRYSTAL'],['end_crystal/end_crystal.png','end_crystal/end_crystal_beam.png']),('ender_dragon',256,256,0.5,0,['ENDER_DRAGON'],['enderdragon/dragon.png','enderdragon/dragon_exploding.png','enderdragon/dragon_eyes.png']),
 ('dragon_fireball',0,0,0,15,[],['enderdragon/dragon_fireball.png'])]
for e,w,h,sh,bl,lay,tex in ENT:
    t.raw('MOVE "%s" TO WS-X24'%e,'CALL "EF7-INFO" USING WS-X24 WS-OUT')
    for k,(lab,v) in enumerate((('found',1),('texture width',w),('texture height',h),('shadow radius',sh),('block light level (0 state default)',bl),('layers',len(lay)),('textures',len(tex))),1): t.num('10 %s %s'%(e,lab),v,'WS-OV(%d)'%k)
    for i,l in enumerate(lay,1):
        t.raw('MOVE "%s" TO WS-X24'%e,'MOVE %d TO WS-FL'%i,'CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('10 %s layer %d'%(e,i),l,'WS-X32')
    for i,x in enumerate(tex,1):
        t.raw('MOVE "%s" TO WS-X24'%e,'MOVE %d TO WS-FL'%i,'CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60'); t.text('10 %s texture %d'%(e,i),x,'WS-X60')
t.raw('MOVE "blaze" TO WS-X24','MOVE 2 TO WS-FL','MOVE "x" TO WS-X32','CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32'); t.text('10 a layer past the end is blank','','WS-X32')
t.raw('MOVE "blaze" TO WS-X24','MOVE 2 TO WS-FL','MOVE "x" TO WS-X60','CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60'); t.text('10 a texture past the end is blank','','WS-X60')
t.raw('MOVE "creeper" TO WS-X24','CALL "EF7-INFO" USING WS-X24 WS-OUT'); t.num('10 an entity of another part is not found',0,'WS-OV(1)')
save(t,7,10)
