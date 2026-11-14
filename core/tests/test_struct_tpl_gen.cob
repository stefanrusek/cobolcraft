*> Real-data test of the template structures' start generators (skipped as a pass without the generated packs; core/src/struct-tpl-gen.cob; docs/protocol/36-structures-4 section 6, 36-structures-6 section 4):
*> on the generated vanilla-data (CC_GENERATED_DIR, read only) STRUCT-FIND-POINT builds the igloo's pieces (the draws, the basement depth, the positions and kinds of its n + 1 pieces) and the
*> shipwreck's piece (rotation, template of the 11 or 20 entry list, the height of the one-time adjustment from the base heights of the unrotated footprint, the beached draw). Expected values of the
*> draws come from core/tests/fixtures/gen_tplgen.py (an independent Java LCG model; world seed 12345); the heights are asked of STRUCT-BASE-HEIGHT with plain loops written from 36-6 4.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-TPL-GEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-I                   BINARY-LONG.
 01 WS-IGLOO               BINARY-LONG.
 01 WS-SHIP                BINARY-LONG.
 01 WS-BEACH               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LABEL               PIC X(100).
 01 WS-NAME                PIC X(60).
 01 WS-WANT-KEY            PIC X(110).
 01 WS-H                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-AREA                BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-KIND-H              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-WANT-Y              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FK                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-LX                 BINARY-LONG.
 01 WS-LY                 BINARY-LONG.
 01 WS-LZ                 BINARY-LONG.
 01 WS-MEAN               BINARY-LONG.
 01 WS-BEACHED            BINARY-LONG.
 01 WS-STRUCT             BINARY-LONG.
 01 WS-SAVE-DIR            PIC X(1100).
 01 WS-NAME-OUT           PIC X(100).
 01 WS-WANT-X             BINARY-LONG.
 01 WS-WANT-Z             BINARY-LONG.
 01 WS-ZERO-KIND          BINARY-LONG VALUE 0.
 01 WS-ED1                 PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-ED3                 PIC -(5)9.

 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct tpl gen no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         EVALUATE SDT-KEY(WS-I)
             WHEN "minecraft:igloo"
                 MOVE WS-I TO WS-IGLOO
             WHEN "minecraft:shipwreck"
                 MOVE WS-I TO WS-SHIP
             WHEN "minecraft:shipwreck_beached"
                 MOVE WS-I TO WS-BEACH
         END-EVALUATE
     END-PERFORM
     MOVE "test struct tpl gen given the standard data when the shipwreck_beached structure is read then it is the is_beached variant" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SDT-VARIANT(WS-BEACH) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct tpl gen given the standard data when the shipwreck structure is read then it is not beached" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SDT-VARIANT(WS-SHIP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   igloo: the model's rotation, piece count, first piece (kind, x, y, z) and last piece (the top: x, y, z)
     MOVE 0 TO WS-CX MOVE 0 TO WS-CZ MOVE 1 TO WS-ROT MOVE 1 TO WS-COUNT
     MOVE 1 TO WS-FK MOVE 0 TO WS-FX MOVE 90 TO WS-FY MOVE 0 TO WS-FZ MOVE 0 TO WS-LX MOVE 90 TO WS-LY MOVE 0 TO WS-LZ
     PERFORM IGLOO-CASE
     MOVE 1 TO WS-CX MOVE 0 TO WS-CZ MOVE 0 TO WS-ROT MOVE 1 TO WS-COUNT
     MOVE 1 TO WS-FK MOVE 16 TO WS-FX MOVE 90 TO WS-FY MOVE 0 TO WS-FZ MOVE 16 TO WS-LX MOVE 90 TO WS-LY MOVE 0 TO WS-LZ
     PERFORM IGLOO-CASE
     MOVE -3 TO WS-CX MOVE 5 TO WS-CZ MOVE 2 TO WS-ROT MOVE 5 TO WS-COUNT
     MOVE 3 TO WS-FK MOVE -48 TO WS-FX MOVE 75 TO WS-FY MOVE 78 TO WS-FZ MOVE -48 TO WS-LX MOVE 90 TO WS-LY MOVE 80 TO WS-LZ
     PERFORM IGLOO-CASE
     PERFORM IGLOO-LADDERS
     MOVE 7 TO WS-CX MOVE -2 TO WS-CZ MOVE 1 TO WS-ROT MOVE 1 TO WS-COUNT
     MOVE 1 TO WS-FK MOVE 112 TO WS-FX MOVE 90 TO WS-FY MOVE -32 TO WS-FZ MOVE 112 TO WS-LX MOVE 90 TO WS-LY MOVE -32 TO WS-LZ
     PERFORM IGLOO-CASE
     MOVE 5 TO WS-CX MOVE 5 TO WS-CZ MOVE 0 TO WS-ROT MOVE 12 TO WS-COUNT
     MOVE 3 TO WS-FK MOVE 80 TO WS-FX MOVE 54 TO WS-FY MOVE 78 TO WS-FZ MOVE 80 TO WS-LX MOVE 90 TO WS-LY MOVE 80 TO WS-LZ
     PERFORM IGLOO-CASE
     MOVE -9 TO WS-CX MOVE -4 TO WS-CZ MOVE 3 TO WS-ROT MOVE 12 TO WS-COUNT
     MOVE 3 TO WS-FK MOVE -144 TO WS-FX MOVE 54 TO WS-FY MOVE -66 TO WS-FZ MOVE -144 TO WS-LX MOVE 90 TO WS-LY MOVE -64 TO WS-LZ
     PERFORM IGLOO-CASE

*>   shipwreck: ocean (0) and beached (1), rotation, template and the beached draw of the model
     MOVE 0 TO WS-BEACHED MOVE 0 TO WS-CX MOVE 0 TO WS-CZ MOVE 1 TO WS-ROT MOVE "with_mast" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 1 TO WS-BEACHED MOVE 0 TO WS-CX MOVE 0 TO WS-CZ MOVE 1 TO WS-ROT MOVE "rightsideup_backhalf" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 0 TO WS-BEACHED MOVE 1 TO WS-CX MOVE 0 TO WS-CZ MOVE 0 TO WS-ROT MOVE "rightsideup_backhalf" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 1 TO WS-BEACHED MOVE 1 TO WS-CX MOVE 0 TO WS-CZ MOVE 0 TO WS-ROT MOVE "rightsideup_fronthalf_degraded" TO WS-NAME MOVE 1 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 0 TO WS-BEACHED MOVE -3 TO WS-CX MOVE 5 TO WS-CZ MOVE 2 TO WS-ROT MOVE "sideways_fronthalf" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 1 TO WS-BEACHED MOVE 7 TO WS-CX MOVE -2 TO WS-CZ MOVE 1 TO WS-ROT MOVE "rightsideup_fronthalf" TO WS-NAME MOVE 2 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 0 TO WS-BEACHED MOVE 7 TO WS-CX MOVE -2 TO WS-CZ MOVE 1 TO WS-ROT MOVE "upsidedown_full_degraded" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 1 TO WS-BEACHED MOVE 20 TO WS-CX MOVE 3 TO WS-CZ MOVE 3 TO WS-ROT MOVE "with_mast" TO WS-NAME MOVE 2 TO WS-DRAW
     PERFORM SHIP-CASE
     MOVE 0 TO WS-BEACHED MOVE 5 TO WS-CX MOVE 5 TO WS-CZ MOVE 0 TO WS-ROT MOVE "with_mast_degraded" TO WS-NAME MOVE 0 TO WS-DRAW
     PERFORM SHIP-CASE

*>   an absent template: no template file under the data folder gives no piece and an invalid start (the cache forgets what it loaded first)
     MOVE SD-DIR TO WS-SAVE-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "/nonexistent/folder" TO SD-DIR
     MOVE 0 TO WS-BEACHED MOVE 2 TO WS-CX MOVE 2 TO WS-CZ
     CALL "STRUCT-FIND-POINT" USING WS-SHIP CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE WS-SAVE-DIR TO SD-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "test struct tpl gen given no template files when a shipwreck is built then the start is invalid and has no piece" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ASSERT-CASE.
     MOVE WS-CX TO WS-ED1
     MOVE WS-CZ TO WS-ED2
     MOVE SPACES TO TL-CASE
     STRING "test struct tpl gen given " FUNCTION TRIM(WS-LABEL) " chunk " FUNCTION TRIM(WS-ED1) "," FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-NAME-OUT)
         DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 IGLOO-CASE.
     CALL "STRUCT-FIND-POINT" USING WS-IGLOO CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "igloo" TO WS-LABEL
     MOVE "when built then the stub is valid and on top of the chunk centre" TO WS-NAME-OUT
     COMPUTE WS-WANT-X = WS-CX * 16 + 8
     COMPUTE WS-WANT-Z = WS-CZ * 16 + 8
     CALL "STRUCT-BASE-HEIGHT" USING WS-WANT-X WS-WANT-Z WS-ZERO-KIND WS-H
     COMPUTE WS-WANT-Y = WS-H - 1
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VALID = 1 AND WS-X = WS-WANT-X AND WS-Z = WS-WANT-Z AND WS-Y = WS-WANT-Y
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE
     MOVE "when built then the piece count is n + 1 or 1" TO WS-NAME-OUT
     MOVE WS-COUNT TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-CASE
     MOVE "when built then the rotation of the pieces is the model's" TO WS-NAME-OUT
     MOVE WS-ROT TO TL-EXPECTED-N
     MOVE SP-T-ROT(SP-COUNT) TO TL-OBSERVED-N
     PERFORM ASSERT-CASE
     MOVE "when built then the first piece is the model's (kind, x, y, z)" TO WS-NAME-OUT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-T-AUX(1) = WS-FK AND SP-T-X(1) = WS-FX AND SP-T-Y(1) = WS-FY AND SP-T-Z(1) = WS-FZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE
     MOVE "when built then the last piece is the top at the chunk's origin, y 90" TO WS-NAME-OUT
     MOVE 0 TO TL-OBSERVED-N
     IF SP-T-AUX(SP-COUNT) = 1 AND SP-T-X(SP-COUNT) = WS-LX AND SP-T-Y(SP-COUNT) = WS-LY AND SP-T-Z(SP-COUNT) = WS-LZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE.

*> the ladders of the basement igloo built last (chunk -3, 5; n = 4): the three middle pieces of 36-4 6.2, (x0 + 2, 90 - 3 - 3 i, z0 + 4)
 IGLOO-LADDERS.
     MOVE "igloo" TO WS-LABEL
     MOVE "when built then the three ladder pieces are at (x0 + 2, 87 - 3 i, z0 + 4)" TO WS-NAME-OUT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-T-AUX(2) = 2 AND SP-T-X(2) = -46 AND SP-T-Y(2) = 87 AND SP-T-Z(2) = 84
        AND SP-T-AUX(3) = 2 AND SP-T-X(3) = -46 AND SP-T-Y(3) = 84 AND SP-T-Z(3) = 84
        AND SP-T-AUX(4) = 2 AND SP-T-X(4) = -46 AND SP-T-Y(4) = 81 AND SP-T-Z(4) = 84
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE.

*> a shipwreck of the model's rotation and template; the height is the mean of the base heights of the unrotated footprint (ocean floor, kind 1) or
*> the lowest world surface (kind 0) minus half the height and the draw (beached): 36-6 4.3
 SHIP-CASE.
     IF WS-BEACHED = 1
         MOVE WS-BEACH TO WS-STRUCT
         MOVE "shipwreck beached" TO WS-LABEL
         MOVE 0 TO WS-KIND-H
     ELSE
         MOVE WS-SHIP TO WS-STRUCT
         MOVE "shipwreck ocean" TO WS-LABEL
         MOVE 1 TO WS-KIND-H
     END-IF
     CALL "STRUCT-FIND-POINT" USING WS-STRUCT CW-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE "when built then there is one piece with the model's rotation" TO WS-NAME-OUT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-COUNT = 1 AND SP-T-ROT(1) = WS-ROT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE
     MOVE SPACES TO WS-WANT-KEY
     STRING "minecraft:shipwreck/" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-WANT-KEY
     MOVE WS-NAME TO WS-NAME-OUT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE SP-T-ROW(1) TO WS-ROW
     IF TP-KEY(WS-ROW) = WS-WANT-KEY
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE
     COMPUTE WS-GX = WS-CX * 16
     COMPUTE WS-GZ = WS-CZ * 16
     MOVE 0 TO WS-SUM
     MOVE 1000 TO WS-LOW
     PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ >= TP-SZ(WS-ROW)
         PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX >= TP-SX(WS-ROW)
             COMPUTE WS-WANT-X = WS-GX + WS-LX
             COMPUTE WS-WANT-Z = WS-GZ + WS-LZ
             CALL "STRUCT-BASE-HEIGHT" USING WS-WANT-X WS-WANT-Z WS-KIND-H WS-H
             ADD WS-H TO WS-SUM
             IF WS-H < WS-LOW
                 MOVE WS-H TO WS-LOW
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-AREA = TP-SX(WS-ROW) * TP-SZ(WS-ROW)
     IF WS-BEACHED = 1
         COMPUTE WS-MEAN = TP-SY(WS-ROW) / 2
         COMPUTE WS-WANT-Y = WS-LOW - WS-MEAN - WS-DRAW
     ELSE
         COMPUTE WS-WANT-Y = WS-SUM / WS-AREA
     END-IF
     MOVE "when built then the template position is (minX, the adjusted y, minZ)" TO WS-NAME-OUT
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-T-X(1) = WS-GX AND SP-T-Z(1) = WS-GZ AND SP-T-Y(1) = WS-WANT-Y
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-CASE.
 END PROGRAM TEST-STRUCT-TPL-GEN.

 COPY CORETEST.
