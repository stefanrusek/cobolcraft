from mesh7 import *
from prog6 import *
ENT=[('blaze',64,32,0.5,15,['BLAZE'],['blaze/blaze.png']),('ghast',64,32,1.5,0,['GHAST'],['ghast/ghast.png','ghast/ghast_shooting.png']),
 ('strider',64,128,0.5,0,['STRIDER','STRIDER_SADDLE','STRIDER_BABY'],['strider/strider.png','strider/strider_cold.png','strider/strider_baby.png','strider/strider_cold_baby.png','equipment/strider_saddle/saddle.png']),
 ('hoglin',128,64,0.7,0,['HOGLIN','HOGLIN_BABY'],['hoglin/hoglin.png','hoglin/hoglin_baby.png']),('zoglin',128,64,0.7,0,['ZOGLIN','ZOGLIN_BABY'],['hoglin/zoglin.png','hoglin/zoglin_baby.png']),
 ('wither',64,64,1.0,15,['WITHER','WITHER_ARMOR'],['wither/wither.png','wither/wither_invulnerable.png','wither/wither_armor.png']),('wither_skull',64,64,0,15,['WITHER_SKULL'],['wither/wither.png','wither/wither_invulnerable.png']),
 ('end_crystal',64,32,0.5,0,['END_CRYSTAL'],['end_crystal/end_crystal.png','end_crystal/end_crystal_beam.png']),('ender_dragon',256,256,0.5,0,['ENDER_DRAGON'],['enderdragon/dragon.png','enderdragon/dragon_exploding.png','enderdragon/dragon_eyes.png']),
 ('dragon_fireball',0,0,0,15,[],['enderdragon/dragon_fireball.png'])]
hdr='''*> Entity models part 7 section 10 (layer and texture summary): per entity the layer texture size, shadow radius, block light level, model layers and texture images.
*> Entry points for the integrator (inputs; strings are X(24) lower case entity type):
*>   EF7-INFO entity OUT(64 FLOAT-LONG: 1 found, 2 texture width, 3 height, 4 shadow radius, 5 block light level (15, or 0 for the state default), 6 layers, 7 textures); EF7-INFO-LAYER entity index(BINARY-LONG) name(X(32), out; spaces past the end);
*>   EF7-INFO-TEXTURE entity index(BINARY-LONG) path(X(60), out, relative to textures/entity/; spaces past the end).
'''
info='';lay='';tex=''
def g(x): return ('%g'%x)
for e,w,h,sh,bl,ls,ts in ENT:
    info+='         WHEN "%s"\n             MOVE 1 TO L-O(1)\n             MOVE %d TO L-O(2)\n             MOVE %d TO L-O(3)\n             MOVE %s TO L-O(4)\n             MOVE %d TO L-O(5)\n             MOVE %d TO L-O(6)\n             MOVE %d TO L-O(7)\n'%(e,w,h,g(sh),bl,len(ls),len(ts))
    if ls:
        lay+='         WHEN "%s"\n             EVALUATE L-INDEX\n'%e
        for k,l in enumerate(ls,1): lay+='                 WHEN %d\n                     MOVE "%s" TO L-NAME\n'%(k,l)
        lay+='             END-EVALUATE\n'
    tex+='         WHEN "%s"\n             EVALUATE L-INDEX\n'%e
    for k,l in enumerate(ts,1): tex+='                 WHEN %d\n                     MOVE "%s" TO L-NAME\n'%(k,l)
    tex+='             END-EVALUATE\n'
body=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-ENTITY L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(5) L-O(6) L-O(7)
     EVALUATE L-ENTITY
'''+info+''' END-EVALUATE
     GOBACK.
 END PROGRAM EF7-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-INFO-LAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-ENTITY L-INDEX L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-ENTITY
'''+lay+''' END-EVALUATE
     GOBACK.
 END PROGRAM EF7-INFO-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-INFO-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(60).
 PROCEDURE DIVISION USING L-ENTITY L-INDEX L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-ENTITY
'''+tex+''' END-EVALUATE
     GOBACK.
 END PROGRAM EF7-INFO-TEXTURE.
'''
body=body.replace(' END-EVALUATE','     END-EVALUATE')
open(REPO+'client/src/entmodel-34-7-10.cob','w').write(hdr+'\n'+body)
