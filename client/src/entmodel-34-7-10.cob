*> Entity models part 7 section 10 (layer and texture summary): per entity the layer texture size, shadow radius, block light level, model layers and texture images.
*> Entry points for the integrator (inputs; strings are X(24) lower case entity type):
*>   EF7-INFO entity OUT(64 FLOAT-LONG: 1 found, 2 texture width, 3 height, 4 shadow radius, 5 block light level (15, or 0 for the state default), 6 layers, 7 textures); EF7-INFO-LAYER entity index(BINARY-LONG) name(X(32), out; spaces past the end);
*>   EF7-INFO-TEXTURE entity index(BINARY-LONG) path(X(60), out, relative to textures/entity/; spaces past the end).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-ENTITY L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(5) L-O(6) L-O(7)
     EVALUATE L-ENTITY
         WHEN "blaze"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 15 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 1 TO L-O(7)
         WHEN "ghast"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 1.5 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 2 TO L-O(7)
         WHEN "strider"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 128 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 3 TO L-O(6)
             MOVE 5 TO L-O(7)
         WHEN "hoglin"
             MOVE 1 TO L-O(1)
             MOVE 128 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0.7 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 2 TO L-O(7)
         WHEN "zoglin"
             MOVE 1 TO L-O(1)
             MOVE 128 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0.7 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 2 TO L-O(7)
         WHEN "wither"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 1 TO L-O(4)
             MOVE 15 TO L-O(5)
             MOVE 2 TO L-O(6)
             MOVE 3 TO L-O(7)
         WHEN "wither_skull"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 64 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE 15 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 2 TO L-O(7)
         WHEN "end_crystal"
             MOVE 1 TO L-O(1)
             MOVE 64 TO L-O(2)
             MOVE 32 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 2 TO L-O(7)
         WHEN "ender_dragon"
             MOVE 1 TO L-O(1)
             MOVE 256 TO L-O(2)
             MOVE 256 TO L-O(3)
             MOVE 0.5 TO L-O(4)
             MOVE 0 TO L-O(5)
             MOVE 1 TO L-O(6)
             MOVE 3 TO L-O(7)
         WHEN "dragon_fireball"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
             MOVE 0 TO L-O(4)
             MOVE 15 TO L-O(5)
             MOVE 0 TO L-O(6)
             MOVE 1 TO L-O(7)
     END-EVALUATE
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
         WHEN "blaze"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "BLAZE" TO L-NAME
                 END-EVALUATE
         WHEN "ghast"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "GHAST" TO L-NAME
                 END-EVALUATE
         WHEN "strider"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "STRIDER" TO L-NAME
                 WHEN 2
                     MOVE "STRIDER_SADDLE" TO L-NAME
                 WHEN 3
                     MOVE "STRIDER_BABY" TO L-NAME
                 END-EVALUATE
         WHEN "hoglin"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "HOGLIN" TO L-NAME
                 WHEN 2
                     MOVE "HOGLIN_BABY" TO L-NAME
                 END-EVALUATE
         WHEN "zoglin"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "ZOGLIN" TO L-NAME
                 WHEN 2
                     MOVE "ZOGLIN_BABY" TO L-NAME
                 END-EVALUATE
         WHEN "wither"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "WITHER" TO L-NAME
                 WHEN 2
                     MOVE "WITHER_ARMOR" TO L-NAME
                 END-EVALUATE
         WHEN "wither_skull"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "WITHER_SKULL" TO L-NAME
                 END-EVALUATE
         WHEN "end_crystal"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "END_CRYSTAL" TO L-NAME
                 END-EVALUATE
         WHEN "ender_dragon"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "ENDER_DRAGON" TO L-NAME
                 END-EVALUATE
     END-EVALUATE
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
         WHEN "blaze"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "blaze/blaze.png" TO L-NAME
                 END-EVALUATE
         WHEN "ghast"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "ghast/ghast.png" TO L-NAME
                 WHEN 2
                     MOVE "ghast/ghast_shooting.png" TO L-NAME
                 END-EVALUATE
         WHEN "strider"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "strider/strider.png" TO L-NAME
                 WHEN 2
                     MOVE "strider/strider_cold.png" TO L-NAME
                 WHEN 3
                     MOVE "strider/strider_baby.png" TO L-NAME
                 WHEN 4
                     MOVE "strider/strider_cold_baby.png" TO L-NAME
                 WHEN 5
                     MOVE "equipment/strider_saddle/saddle.png" TO L-NAME
                 END-EVALUATE
         WHEN "hoglin"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "hoglin/hoglin.png" TO L-NAME
                 WHEN 2
                     MOVE "hoglin/hoglin_baby.png" TO L-NAME
                 END-EVALUATE
         WHEN "zoglin"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "hoglin/zoglin.png" TO L-NAME
                 WHEN 2
                     MOVE "hoglin/zoglin_baby.png" TO L-NAME
                 END-EVALUATE
         WHEN "wither"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "wither/wither.png" TO L-NAME
                 WHEN 2
                     MOVE "wither/wither_invulnerable.png" TO L-NAME
                 WHEN 3
                     MOVE "wither/wither_armor.png" TO L-NAME
                 END-EVALUATE
         WHEN "wither_skull"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "wither/wither.png" TO L-NAME
                 WHEN 2
                     MOVE "wither/wither_invulnerable.png" TO L-NAME
                 END-EVALUATE
         WHEN "end_crystal"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "end_crystal/end_crystal.png" TO L-NAME
                 WHEN 2
                     MOVE "end_crystal/end_crystal_beam.png" TO L-NAME
                 END-EVALUATE
         WHEN "ender_dragon"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "enderdragon/dragon.png" TO L-NAME
                 WHEN 2
                     MOVE "enderdragon/dragon_exploding.png" TO L-NAME
                 WHEN 3
                     MOVE "enderdragon/dragon_eyes.png" TO L-NAME
                 END-EVALUATE
         WHEN "dragon_fireball"
             EVALUATE L-INDEX
                 WHEN 1
                     MOVE "enderdragon/dragon_fireball.png" TO L-NAME
                 END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-INFO-TEXTURE.
