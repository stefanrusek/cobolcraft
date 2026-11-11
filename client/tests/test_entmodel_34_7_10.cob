*> Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 10 (layer and texture summary): for each of the ten entities the texture size of the layer, the shadow radius, the block light level (15 or 0 for the state default),
*> the model layers in the order of the table and the texture images with their paths, and section 10.1 (shadow radius, extra layers).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-7-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-X60               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "blaze" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 blaze found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze block light level (0 state default)" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 blaze textures" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "blaze" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 blaze layer 1" TO WS-NAME
     MOVE "BLAZE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "blaze" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 blaze texture 1" TO WS-NAME
     MOVE "blaze/blaze.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ghast" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 ghast found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast shadow radius" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ghast textures" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ghast" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 ghast layer 1" TO WS-NAME
     MOVE "GHAST" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ghast" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 ghast texture 1" TO WS-NAME
     MOVE "ghast/ghast.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ghast" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 ghast texture 2" TO WS-NAME
     MOVE "ghast/ghast_shooting.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 strider found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider layers" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 strider textures" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "strider" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 strider layer 1" TO WS-NAME
     MOVE "STRIDER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 strider layer 2" TO WS-NAME
     MOVE "STRIDER_SADDLE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 strider layer 3" TO WS-NAME
     MOVE "STRIDER_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 strider texture 1" TO WS-NAME
     MOVE "strider/strider.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 strider texture 2" TO WS-NAME
     MOVE "strider/strider_cold.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 strider texture 3" TO WS-NAME
     MOVE "strider/strider_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 4 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 strider texture 4" TO WS-NAME
     MOVE "strider/strider_cold_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "strider" TO WS-X24
     MOVE 5 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 strider texture 5" TO WS-NAME
     MOVE "equipment/strider_saddle/saddle.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "hoglin" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 hoglin found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 hoglin textures" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hoglin" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 hoglin layer 1" TO WS-NAME
     MOVE "HOGLIN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "hoglin" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 hoglin layer 2" TO WS-NAME
     MOVE "HOGLIN_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "hoglin" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 hoglin texture 1" TO WS-NAME
     MOVE "hoglin/hoglin.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "hoglin" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 hoglin texture 2" TO WS-NAME
     MOVE "hoglin/hoglin_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zoglin" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 zoglin found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 zoglin textures" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zoglin" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 zoglin layer 1" TO WS-NAME
     MOVE "ZOGLIN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zoglin" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 zoglin layer 2" TO WS-NAME
     MOVE "ZOGLIN_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zoglin" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 zoglin texture 1" TO WS-NAME
     MOVE "hoglin/zoglin.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zoglin" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 zoglin texture 2" TO WS-NAME
     MOVE "hoglin/zoglin_baby.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 wither found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither shadow radius" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither block light level (0 state default)" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither layers" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither textures" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wither" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 wither layer 1" TO WS-NAME
     MOVE "WITHER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 wither layer 2" TO WS-NAME
     MOVE "WITHER_ARMOR" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 wither texture 1" TO WS-NAME
     MOVE "wither/wither.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 wither texture 2" TO WS-NAME
     MOVE "wither/wither_invulnerable.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 wither texture 3" TO WS-NAME
     MOVE "wither/wither_armor.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither_skull" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 wither_skull found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull shadow radius" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull block light level (0 state default)" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 wither_skull textures" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wither_skull" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 wither_skull layer 1" TO WS-NAME
     MOVE "WITHER_SKULL" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither_skull" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 wither_skull texture 1" TO WS-NAME
     MOVE "wither/wither.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wither_skull" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 wither_skull texture 2" TO WS-NAME
     MOVE "wither/wither_invulnerable.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "end_crystal" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 end_crystal found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 end_crystal textures" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "end_crystal" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 end_crystal layer 1" TO WS-NAME
     MOVE "END_CRYSTAL" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "end_crystal" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 end_crystal texture 1" TO WS-NAME
     MOVE "end_crystal/end_crystal.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "end_crystal" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 end_crystal texture 2" TO WS-NAME
     MOVE "end_crystal/end_crystal_beam.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ender_dragon" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 ender_dragon found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon texture width" TO WS-NAME
     MOVE 256 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon texture height" TO WS-NAME
     MOVE 256 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon block light level (0 state default)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon layers" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 ender_dragon textures" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ender_dragon" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 ender_dragon layer 1" TO WS-NAME
     MOVE "ENDER_DRAGON" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ender_dragon" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 ender_dragon texture 1" TO WS-NAME
     MOVE "enderdragon/dragon.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ender_dragon" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 ender_dragon texture 2" TO WS-NAME
     MOVE "enderdragon/dragon_exploding.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ender_dragon" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 ender_dragon texture 3" TO WS-NAME
     MOVE "enderdragon/dragon_eyes.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "dragon_fireball" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 dragon_fireball found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball texture width" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball texture height" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball shadow radius" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball block light level (0 state default)" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball layers" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 dragon_fireball textures" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "dragon_fireball" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 dragon_fireball texture 1" TO WS-NAME
     MOVE "enderdragon/dragon_fireball.png" TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "blaze" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE "x" TO WS-X32
     CALL "EF7-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "10 a layer past the end is blank" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "blaze" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE "x" TO WS-X60
     CALL "EF7-INFO-TEXTURE" USING WS-X24 WS-FL WS-X60
     MOVE "10 a texture past the end is blank" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X60 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "creeper" TO WS-X24
     CALL "EF7-INFO" USING WS-X24 WS-OUT
     MOVE "10 an entity of another part is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§10 Layer and texture summary: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§10 Layer and texture summary: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-7-10.
