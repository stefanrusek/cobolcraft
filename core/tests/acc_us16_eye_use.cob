*> Acceptance test, the eye of ender item (docs/protocol/25 section 6.3 use in air, 21 section 8.12; lane featsb7, T10000): Use Item with an ender_eye in the main hand
*> asks the stronghold locate (STRUCT-NEAREST-NAMED "stronghold", radius not used) for the nearest ring chunk of the level seed; when none is found nothing is thrown and
*> nothing is consumed (CONSUME); otherwise an eye_of_ender entity appears at (x, y + 0.5 x 1.8, z) of the player, signalled to the locate position (a target beyond 12 blocks is
*> replaced by position + (dx / h x 12, 8, dz / h x 12)), a survival stack loses one and a creative stack stays; a ray that hits an end_portal_frame passes the item on (nothing thrown).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-EYE-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PLAYPKT.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EYE-ITEM            BINARY-LONG.
 01 WS-EYE-TYPE            BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct_eye".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-NAME                PIC X(40).
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-FRAME               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EYE-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-EYE-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-EYE-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
     MOVE 0 TO PSB-HAND PSB-YAW PSB-PITCH
     MOVE 0.5 TO PL-X(WS-PLAYER)
     MOVE 0.5 TO PL-Z(WS-PLAYER)
     MOVE 0 TO CW-SEED

*>   no structure data: nothing is found, the use is consumed by the item (done) and nothing is thrown or used up
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM COUNT-EYES
     MOVE "acceptance US16 25 6.3 no stronghold found: the use is handled, no eye appears" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DONE * 10 + WS-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 no stronghold found: the stack is not used up" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the stronghold set (a ring set of three chunks (-13,-106) (121,52) (-92,69) at seed 0, 36-1 12.3)
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "minecraft:forest" TO WS-NAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET

     MOVE 0 TO PSB-YAW PSB-PITCH
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM COUNT-EYES
     MOVE "acceptance US16 25 6.3 a stronghold is found: one eye_of_ender entity appears" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DONE * 10 + WS-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 the survival stack loses one" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 the eye starts at y + 0.9 (0.5 x the 1.8 height), in millimetres" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(PL-Y(WS-PLAYER) * 1000 + 900.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 the eye starts at rest" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(EN-VX(WS-ROW)) + FUNCTION ABS(EN-VY(WS-ROW)) + FUNCTION ABS(EN-VZ(WS-ROW))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the nearest ring chunk of the origin (0, y, 0) is (-13,-106) (36-5 4.1 / 36-1 12.3 vectors)
     MOVE "stronghold" TO WS-NAME
     COMPUTE WS-OX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-OY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-OZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME CW-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-LX WS-LY WS-LZ
     MOVE "acceptance US16 25 6.3 the located chunk is (-13,-106)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N TL-OBSERVED-N
     IF WS-FOUND = 1 AND WS-CX = -13 AND WS-CZ = -106
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-DX = WS-LX - EN-X(WS-ROW)
     COMPUTE WS-DZ = WS-LZ - EN-Z(WS-ROW)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE "acceptance US16 25 6.3 the target is 12 blocks along the line to the stronghold (x, millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER((WS-DX / WS-H * 12) * 1000 + 100000.5) - 100000
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PJ-R1(WS-PJ) - EN-X(WS-ROW)) * 1000 + 100000.5) - 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 the target is 12 blocks along the line to the stronghold (z, millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER((WS-DZ / WS-H * 12) * 1000 + 100000.5) - 100000
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PJ-R3(WS-PJ) - EN-Z(WS-ROW)) * 1000 + 100000.5) - 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 and 8 blocks up" TO TL-CASE
     MOVE 8000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PJ-R2(WS-PJ) - EN-Y(WS-ROW)) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 the owner is the thrower" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-PLAYER) TO TL-EXPECTED-N
     MOVE EN-TARGET-ID(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   creative keeps the stack
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US16 25 6.3 a creative player keeps the stack (consume does not use up in creative)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-EYES
     MOVE "acceptance US16 25 6.3 and the second eye appears" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   a ray that hits an end_portal_frame passes the use on to the block (nothing thrown, nothing used up)
     MOVE 0 TO WS-EYE
     MOVE 3 TO WS-FACING
     CALL "PORTAL-FRAME-STATE" USING WS-EYE WS-FACING WS-FRAME
     MOVE 0 TO WS-BX
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER) + 1.6)
     MOVE 2 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-OVERWORLD WS-BX WS-BY WS-BZ WS-FRAME
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(WS-PLAYER)
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     PERFORM COUNT-EYES
     MOVE "acceptance US16 25 6.3 looking at an end_portal_frame: not handled by the throw" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT + WS-DONE * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 25 6.3 looking at an end_portal_frame: the stack is kept" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-EYES.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-EYE-TYPE
             ADD 1 TO WS-COUNT
             IF WS-ROW = 0
                 MOVE WS-I TO WS-ROW
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US16-EYE-USE.
 COPY CORETEST.
 COPY MOBSPTEST.
