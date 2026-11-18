*> Test of the Nether's natural-spawn predicates (core/src/nether-37-6b.cob; T1717; docs/protocol/37-nether-6 section 9.5): the placement type of each Nether mob, the predicate of each entity
*> (ghast, zombified piglin, piglin, hoglin, magma cube, strider, enderman / skeleton / wither skeleton, blaze / zoglin), the strider's lava walk and isDarkEnoughToSpawn in the Nether.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ENTITY              PIC X(20).
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-WART                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-IGNORE              BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PLACE               BINARY-LONG.
 01 WS-HMAP                BINARY-LONG.
 01 WS-CELLS               PIC X(16).
 01 WS-SKY                 BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-CASE                PIC X(200).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM PLACEMENT-CASES
     PERFORM GHAST-CASES
     PERFORM PIGLIN-CASES
     PERFORM OTHER-CASES
     PERFORM STRIDER-CASES
     PERFORM DARK-CASES
     GOBACK.

 CHECK-OK.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§9 Natural spawning in the Nether: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PLACEMENT-CASES.
     PERFORM VARYING WS-DRAW FROM 1 BY 1 UNTIL WS-DRAW > 11
         EVALUATE WS-DRAW
             WHEN 1 MOVE "ghast" TO WS-ENTITY
             WHEN 2 MOVE "zombified_piglin" TO WS-ENTITY
             WHEN 3 MOVE "piglin" TO WS-ENTITY
             WHEN 4 MOVE "hoglin" TO WS-ENTITY
             WHEN 5 MOVE "magma_cube" TO WS-ENTITY
             WHEN 6 MOVE "strider" TO WS-ENTITY
             WHEN 7 MOVE "enderman" TO WS-ENTITY
             WHEN 8 MOVE "skeleton" TO WS-ENTITY
             WHEN 9 MOVE "wither_skeleton" TO WS-ENTITY
             WHEN 10 MOVE "blaze" TO WS-ENTITY
             WHEN 11 MOVE "zoglin" TO WS-ENTITY
         END-EVALUATE
         CALL "NETHER-SPAWN-PLACEMENT" USING WS-ENTITY WS-PLACE WS-HMAP
         MOVE 1 TO WS-EXPECT
         IF WS-DRAW = 6
             MOVE 3 TO WS-EXPECT
         END-IF
         MOVE WS-PLACE TO WS-OK
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " placement type is ON_GROUND (1), the strider's IN_LAVA (3)" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
         MOVE 1 TO WS-EXPECT
         MOVE WS-HMAP TO WS-OK
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " heightmap is MOTION_BLOCKING_NO_LEAVES (1)" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
     END-PERFORM
     MOVE "creeper" TO WS-ENTITY
     CALL "NETHER-SPAWN-PLACEMENT" USING WS-ENTITY WS-PLACE WS-HMAP
     MOVE 0 TO WS-EXPECT
     MOVE WS-PLACE TO WS-OK
     MOVE "an entity of no Nether list has no placement (0)" TO WS-CASE
     PERFORM CHECK-OK.

 TRY-RULE.
     CALL "NETHER-SPAWN-RULE" USING WS-ENTITY WS-PEACEFUL WS-WART WS-DRAW WS-BASE WS-IGNORE WS-DARK WS-OK.

 GHAST-CASES.
     MOVE "ghast" TO WS-ENTITY
     MOVE 0 TO WS-PEACEFUL WS-WART WS-DRAW WS-IGNORE WS-DARK
     MOVE 1 TO WS-BASE
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "ghast spawns when not peaceful, nextInt(20) is 0 and the generic rule holds" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 1 TO WS-PEACEFUL
     PERFORM TRY-RULE
     MOVE 0 TO WS-EXPECT
     MOVE "ghast never spawns on peaceful" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-PEACEFUL
     MOVE 1 TO WS-DRAW
     PERFORM TRY-RULE
     MOVE "ghast does not spawn when nextInt(20) is 1" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 19 TO WS-DRAW
     PERFORM TRY-RULE
     MOVE "ghast does not spawn when nextInt(20) is 19" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-DRAW WS-BASE
     PERFORM TRY-RULE
     MOVE "ghast does not spawn when the generic rule fails" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 1 TO WS-BASE WS-WART WS-DARK
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "ghast ignores light and the block below" TO WS-CASE
     PERFORM CHECK-OK.

 PIGLIN-CASES.
     MOVE "zombified_piglin" TO WS-ENTITY
     MOVE 0 TO WS-PEACEFUL WS-WART WS-DRAW WS-IGNORE WS-DARK
     MOVE 0 TO WS-BASE
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "zombified piglin spawns when not peaceful and the block below is not a nether wart block, whatever the generic rule and light" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 1 TO WS-WART
     PERFORM TRY-RULE
     MOVE 0 TO WS-EXPECT
     MOVE "zombified piglin does not spawn on a nether wart block" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-WART
     MOVE 1 TO WS-PEACEFUL
     PERFORM TRY-RULE
     MOVE "zombified piglin does not spawn on peaceful" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-PEACEFUL
     MOVE "piglin" TO WS-ENTITY
     MOVE 1 TO WS-PEACEFUL
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "piglin spawns on peaceful (no difficulty test) when the block below is not a nether wart block" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 1 TO WS-WART
     PERFORM TRY-RULE
     MOVE 0 TO WS-EXPECT
     MOVE "piglin does not spawn on a nether wart block" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "hoglin" TO WS-ENTITY
     PERFORM TRY-RULE
     MOVE "hoglin does not spawn on a nether wart block" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-WART
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "hoglin spawns on peaceful when the block below is not a nether wart block" TO WS-CASE
     PERFORM CHECK-OK.

 OTHER-CASES.
     MOVE "magma_cube" TO WS-ENTITY
     MOVE 0 TO WS-PEACEFUL WS-WART WS-DRAW WS-IGNORE WS-DARK WS-BASE
     PERFORM TRY-RULE
     MOVE 1 TO WS-EXPECT
     MOVE "magma cube spawns when not peaceful (no light test, no generic rule)" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 1 TO WS-PEACEFUL
     PERFORM TRY-RULE
     MOVE 0 TO WS-EXPECT
     MOVE "magma cube does not spawn on peaceful" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 0 TO WS-PEACEFUL
     MOVE 1 TO WS-BASE
     PERFORM VARYING WS-DRAW FROM 1 BY 1 UNTIL WS-DRAW > 3
         EVALUATE WS-DRAW
             WHEN 1 MOVE "enderman" TO WS-ENTITY
             WHEN 2 MOVE "skeleton" TO WS-ENTITY
             WHEN 3 MOVE "wither_skeleton" TO WS-ENTITY
         END-EVALUATE
         MOVE 0 TO WS-DARK WS-IGNORE
         PERFORM TRY-RULE
         MOVE 0 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " needs darkness: a bright cell does not spawn it" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
         MOVE 1 TO WS-DARK
         PERFORM TRY-RULE
         MOVE 1 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " spawns in a dark cell when the generic rule holds" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
         MOVE 0 TO WS-BASE
         PERFORM TRY-RULE
         MOVE 0 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " does not spawn in a dark cell when the generic rule fails" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
         MOVE 1 TO WS-BASE WS-IGNORE
         MOVE 0 TO WS-DARK
         PERFORM TRY-RULE
         MOVE 1 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " ignores light when the spawn reason ignores light" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
     END-PERFORM
     MOVE 0 TO WS-DRAW
     PERFORM VARYING WS-DRAW FROM 1 BY 1 UNTIL WS-DRAW > 2
         IF WS-DRAW = 1
             MOVE "blaze" TO WS-ENTITY
         ELSE
             MOVE "zoglin" TO WS-ENTITY
         END-IF
         MOVE 1 TO WS-PEACEFUL
         MOVE 1 TO WS-BASE
         MOVE 0 TO WS-DARK WS-IGNORE
         PERFORM TRY-RULE
         MOVE 1 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " needs only the generic rule: any light, any difficulty" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
         MOVE 0 TO WS-BASE
         PERFORM TRY-RULE
         MOVE 0 TO WS-EXPECT
         MOVE SPACES TO WS-CASE
         STRING FUNCTION TRIM(WS-ENTITY) " does not spawn when the generic rule fails" DELIMITED BY SIZE INTO WS-CASE
         PERFORM CHECK-OK
     END-PERFORM
     MOVE "creeper" TO WS-ENTITY
     MOVE 1 TO WS-BASE
     PERFORM TRY-RULE
     MOVE 0 TO WS-EXPECT
     MOVE "an entity of no Nether list never spawns" TO WS-CASE
     PERFORM CHECK-OK.

 STRIDER-CASES.
*>   L lava, A air, S solid: start at the candidate, move up while lava (the first move before the first test), true when the first non-lava cell is air
     MOVE "LAS" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 1 TO WS-EXPECT
     MOVE "strider: lava candidate with air above spawns" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "LLLAS" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE "strider: three lava cells then air spawns" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "LLSA" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 0 TO WS-EXPECT
     MOVE "strider: lava under a solid cell does not spawn" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "SA" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 1 TO WS-EXPECT
     MOVE "strider: the candidate itself is not tested, only the cells above it (a solid candidate under air spawns)" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "AS" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 0 TO WS-EXPECT
     MOVE "strider: a cell above that is neither lava nor air does not spawn" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "AAS" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 1 TO WS-EXPECT
     MOVE "strider: air right above spawns" TO WS-CASE
     PERFORM CHECK-OK
     MOVE "LLLLLLLLLLLLLLLL" TO WS-CELLS
     CALL "NETHER-STRIDER-RULE" USING WS-CELLS WS-OK
     MOVE 0 TO WS-EXPECT
     MOVE "strider: lava to the top of the column (no air cell) does not spawn" TO WS-CASE
     PERFORM CHECK-OK.

 DARK-CASES.
*>   USING sky light, nextInt(32) draw, raw brightness, monster_spawn_light_level sample: the sky test, then raw <= level; the block-light test is skipped (limit 15)
     MOVE 0 TO WS-SKY WS-DRAW WS-RAW WS-LEVEL
     CALL "NETHER-DARK-ENOUGH" USING WS-SKY WS-DRAW WS-RAW WS-LEVEL WS-OK
     MOVE 1 TO WS-EXPECT
     MOVE "dark enough: sky 0 never beats the nextInt(32) draw, raw 0 against level 0" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 7 TO WS-RAW WS-LEVEL
     CALL "NETHER-DARK-ENOUGH" USING WS-SKY WS-DRAW WS-RAW WS-LEVEL WS-OK
     MOVE "dark enough: raw 7 at level 7 passes" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 8 TO WS-RAW
     CALL "NETHER-DARK-ENOUGH" USING WS-SKY WS-DRAW WS-RAW WS-LEVEL WS-OK
     MOVE 0 TO WS-EXPECT
     MOVE "dark enough: a cell of light 8 does not spawn skeletons, wither skeletons or endermen" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 5 TO WS-SKY
     MOVE 4 TO WS-DRAW
     MOVE 0 TO WS-RAW
     MOVE 7 TO WS-LEVEL
     CALL "NETHER-DARK-ENOUGH" USING WS-SKY WS-DRAW WS-RAW WS-LEVEL WS-OK
     MOVE "dark enough: sky above the draw fails the first test" TO WS-CASE
     PERFORM CHECK-OK
     MOVE 5 TO WS-DRAW
     CALL "NETHER-DARK-ENOUGH" USING WS-SKY WS-DRAW WS-RAW WS-LEVEL WS-OK
     MOVE 1 TO WS-EXPECT
     MOVE "dark enough: sky equal to the draw passes the first test" TO WS-CASE
     PERFORM CHECK-OK.
 END PROGRAM TEST-NETHER-37-6-9.
