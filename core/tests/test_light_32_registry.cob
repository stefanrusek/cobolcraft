*> Test of the engine's inputs from the block registry (core/src/light-32f.cob L32-LOAD-REGISTRY, L32-ENGINE-STATE, L32-DIM-RESET; T0697) over the standard content set of the generated
*> packs (skipped as a pass without them): per state emission, dampening, canOcclude, useShapeForLightOcclusion and the six face masks, as the rules of 24 part 1 section 5.2, the
*> dampening table of 24 part 2 section 5.3 (leaves 1, glass 0, cobweb 1, slabs 0 or 1 waterlogged, double slab 15) and 32 section 7 give them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-32-REGISTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CTBSHAPE.
 COPY L32.
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-ENGINE              BINARY-LONG.
 01 WS-SKY                 BINARY-LONG VALUE 1.
 01 WS-NS                  BINARY-LONG VALUE 24.
 01 WS-MIN                 BINARY-LONG VALUE -4.
 01 WS-SHOW                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 32§2 engine states from the registry: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "L32-INIT" USING WS-SKY
     CALL "L32-LOAD-REGISTRY"

     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "acceptance US12 32§2 stone: emission 0, dampening 15, can occlude, full faces" TO TL-CASE
     MOVE "0 15 1 0 15 15 15 15 15 15 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:glass" TO WS-KEY
     MOVE "acceptance US12 32§2 glass: dampening 0, cannot occlude (24 part 2 section 5.3)" TO TL-CASE
     MOVE "0 0 0 0 0 0 0 0 0 0 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:oak_leaves" TO WS-KEY
     MOVE "distance=7,persistent=false,waterlogged=false" TO WS-PAIRS
     MOVE "acceptance US12 32§7 oak leaves: dampening 1 by the LeavesBlock override, cannot occlude" TO TL-CASE
     MOVE "0 1 0 0 0 0 0 0 0 0 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:cobweb" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "acceptance US12 32§2 cobweb: dampening 1 (full outline, no occlusion)" TO TL-CASE
     MOVE "0 1 0 0 0 0 0 0 0 0 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:torch" TO WS-KEY
     MOVE "acceptance US12 32§2 torch: emission 14, dampening 0, cannot occlude" TO TL-CASE
     MOVE "14 0 0 0 0 0 0 0 0 0 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:glowstone" TO WS-KEY
     MOVE "acceptance US12 32§2 glowstone: emission 15, dampening 15" TO TL-CASE
     MOVE "15 15 1 0 15 15 15 15 15 15 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:oak_slab" TO WS-KEY
     MOVE "type=bottom,waterlogged=false" TO WS-PAIRS
     MOVE "acceptance US12 32§7 bottom slab: dampening 0, uses its shape, DOWN face full, UP empty, sides the lower half (mask 3)" TO TL-CASE
     MOVE "0 0 1 1 15 0 3 3 3 3 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "type=top,waterlogged=false" TO WS-PAIRS
     MOVE "acceptance US12 32§7 top slab: UP face full, DOWN empty, sides the upper half (mask 12)" TO TL-CASE
     MOVE "0 0 1 1 0 15 12 12 12 12 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "type=bottom,waterlogged=true" TO WS-PAIRS
     MOVE "acceptance US12 32§7 waterlogged bottom slab: dampening 1 (the fluid is not empty)" TO TL-CASE
     MOVE "0 1 1 1 15 0 3 3 3 3 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "type=double,waterlogged=false" TO WS-PAIRS
     MOVE "acceptance US12 32§7 double slab: dampening 15, does not use its shape" TO TL-CASE
     MOVE "0 15 1 0 15 15 15 15 15 15 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:water" TO WS-KEY
     MOVE "level=0" TO WS-PAIRS
     MOVE "acceptance US12 32§7 water: dampening 1 (LiquidBlock does not propagate skylight)" TO TL-CASE
     MOVE "0 1 0 0 0 0 0 0 0 0 " TO TL-EXPECTED
     PERFORM SHOW-STATE

     MOVE "minecraft:air" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "L32-ENGINE-STATE" USING WS-STATE WS-ENGINE
     MOVE "acceptance US12 32§2 air is the engine's state 0, stone the registry state + 2" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-ENGINE TO WS-SHOW
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "L32-ENGINE-STATE" USING WS-STATE WS-ENGINE
     COMPUTE WS-ENGINE = WS-ENGINE - WS-STATE
     MOVE WS-ENGINE TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "0/2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A reset for another dimension keeps the states: stone is still defined after L32-DIM-RESET and the dimension is sized.
     CALL "L32-DIM-RESET" USING WS-SKY WS-NS WS-MIN
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "acceptance US12 32§2 L32-DIM-RESET keeps the loaded states and sizes the columns: stone damp 15, 24 sections from -4" TO TL-CASE
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-ENGINE = WS-STATE + 3
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE EN-DAMP(WS-ENGINE) TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE EN-NS TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE EN-MINSEC TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "15/24/-4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Shows emission, dampening, canOcclude, useShape and the six face masks of the engine state of WS-KEY / WS-PAIRS.
 SHOW-STATE.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-ENGINE = WS-STATE + 3
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE EN-EMIT(WS-ENGINE) TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE EN-DAMP(WS-ENGINE) TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE EN-OCC(WS-ENGINE) TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE EN-USE(WS-ENGINE) TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         MOVE EN-FACE(WS-ENGINE, WS-F) TO WS-SHOW
         STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-LIGHT-32-REGISTRY.
