*> The Nether's natural-spawn predicates (docs/protocol/37-nether-6 section 9.5; T1718), as pure rules over facts the caller reads from the world: the placement type and heightmap of each
*> Nether mob, the predicate of each entity, the strider's lava walk and Monster.isDarkEnoughToSpawn in the Nether (sky 0 and the block-light limit 15).
*>
*> Entry points:
*>   NETHER-SPAWN-PLACEMENT USING entity (PIC X(20), no namespace), placement out (1 ON_GROUND, 3 IN_LAVA as MS6-PLACEMENT-OK; 0 for an entity of no Nether list), heightmap out (1 MOTION_BLOCKING_NO_LEAVES, else 0)
*>   NETHER-SPAWN-RULE USING entity, peaceful (1 on Peaceful), below wart (1 when the block below is nether_wart_block), nextInt(20) draw (ghast only), generic (1 when checkMobSpawnRules holds),
*>     ignores light (1 when the spawn reason ignores light), dark (1 when isDarkEnoughToSpawn holds), ok out
*>   NETHER-STRIDER-RULE USING cells (PIC X(16): the candidate cell then the cells above it, L lava, A air, anything else solid), ok out
*>   NETHER-DARK-ENOUGH USING sky light, nextInt(32) draw, raw brightness, monster_spawn_light_level sample, ok out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SPAWN-PLACEMENT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(20).
 01 L-PLACE                BINARY-LONG.
 01 L-HMAP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-PLACE L-HMAP.
     MOVE 0 TO L-PLACE L-HMAP
     EVALUATE L-ENTITY
         WHEN "ghast"
         WHEN "zombified_piglin"
         WHEN "piglin"
         WHEN "hoglin"
         WHEN "magma_cube"
         WHEN "enderman"
         WHEN "skeleton"
         WHEN "wither_skeleton"
         WHEN "blaze"
         WHEN "zoglin"
             MOVE 1 TO L-PLACE L-HMAP
         WHEN "strider"
             MOVE 3 TO L-PLACE
             MOVE 1 TO L-HMAP
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-SPAWN-PLACEMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SPAWN-RULE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               PIC X(20).
 01 L-PEACEFUL             BINARY-LONG.
 01 L-WART                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-GENERIC              BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-PEACEFUL L-WART L-DRAW L-GENERIC L-IGNORE L-DARK L-OK.
     MOVE 0 TO L-OK
     EVALUATE L-ENTITY
         WHEN "ghast"
             IF L-PEACEFUL = 0 AND L-DRAW = 0 AND L-GENERIC = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN "zombified_piglin"
             IF L-PEACEFUL = 0 AND L-WART = 0
                 MOVE 1 TO L-OK
             END-IF
         WHEN "piglin"
         WHEN "hoglin"
             IF L-WART = 0
                 MOVE 1 TO L-OK
             END-IF
         WHEN "magma_cube"
             IF L-PEACEFUL = 0
                 MOVE 1 TO L-OK
             END-IF
         WHEN "enderman"
         WHEN "skeleton"
         WHEN "wither_skeleton"
             IF (L-IGNORE = 1 OR L-DARK = 1) AND L-GENERIC = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN "blaze"
         WHEN "zoglin"
             MOVE L-GENERIC TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-SPAWN-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-STRIDER-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS                PIC X(16).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-OK.
     MOVE 0 TO L-OK
     MOVE 1 TO WS-POS
     PERFORM WITH TEST AFTER UNTIL WS-POS > 16 OR L-CELLS(WS-POS:1) NOT = "L"
         ADD 1 TO WS-POS
     END-PERFORM
     IF WS-POS <= 16 AND L-CELLS(WS-POS:1) = "A"
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM NETHER-STRIDER-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DARK-ENOUGH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-DRAW L-RAW L-LEVEL L-OK.
     MOVE 0 TO L-OK
     IF L-SKY <= L-DRAW AND L-RAW <= L-LEVEL
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM NETHER-DARK-ENOUGH.
