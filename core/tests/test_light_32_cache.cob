*> Test of the bridge between the chunk cache and the light engine (core/src/light-32g.cob L32-LOAD-CHUNK, L32-LIGHT-ROW, L32-STORE-LIGHT; T0697): the engine lights a cached chunk of the
*> cobolcraft world with its 3 x 3 neighbourhood. Its block light agrees byte for byte with the stand-in's (the same rule through non-opaque cells, light across the borders of the
*> neighbours) and so does its sky light except in the one cell where the rules differ: the stand-in is dark at and below a column's top block, lucite included, while 32 section 5.2
*> lets sky light pass lucite (non-opaque, dampening 0) and the cell beside the open column holds 15 minus 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-32-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY CBLOCKS.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SAVE-SKY            PIC X(53248).
 01 WS-SAVE-SKY-T REDEFINES WS-SAVE-SKY.
    05 WS-SS               BINARY-CHAR UNSIGNED OCCURS 53248 TIMES.
 01 WS-SAVE-BLK            PIC X(53248).
 01 WS-SAVE-BLK-T REDEFINES WS-SAVE-BLK.
    05 WS-SB               BINARY-CHAR UNSIGNED OCCURS 53248 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DIFF-SKY            BINARY-LONG.
 01 WS-DIFF-BLK            BINARY-LONG.
 01 WS-SUM-BLK             BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 8.
 01 WS-Y                   BINARY-LONG VALUE 58.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-STATE               BINARY-LONG.
 01 WS-SHOW1               PIC -(9)9.
 01 WS-SHOW2               PIC -(9)9.
 01 WS-SHOW4               PIC -(9)9.
 01 WS-SHOW5               PIC -(9)9.
 01 WS-SHOW3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CE-SKYS TO WS-SAVE-SKY
     MOVE CE-BLOCK-LIGHTS TO WS-SAVE-BLK
     CALL "L32-LIGHT-ROW" USING WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO WS-DIFF-SKY WS-DIFF-BLK WS-SUM-BLK WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 53248
         IF CE-SKY(WS-I) NOT = WS-SS(WS-I)
             ADD 1 TO WS-DIFF-SKY
             MOVE WS-I TO WS-AT
         END-IF
         IF CE-BLOCK-LIGHT(WS-I) NOT = WS-SB(WS-I)
             ADD 1 TO WS-DIFF-BLK
         END-IF
         ADD CE-BLOCK-LIGHT(WS-I) TO WS-SUM-BLK
     END-PERFORM

     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 32§5.1 engine block light of the chunk equals the stand-in's in every byte (and is not all dark: sum above 100000)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = WS-DIFF-BLK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 32§5.1 the stand-in's block light of the chunk is not dark" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1
     IF WS-SUM-BLK > 100000
         COMPUTE TL-OBSERVED-N = 1
     ELSE
         COMPUTE TL-OBSERVED-N = 0
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 32§5.2 the engine's sky light differs from the stand-in's in one byte only" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1
     COMPUTE TL-OBSERVED-N = WS-DIFF-SKY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   That byte is light section 4 (Y 48 to 63), cell (8, 58, 8): the pillar's lucite top. Engine 14 (the open column beside it, 15, less 1), stand-in 0, the neighbour cell 15 in both.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 32§5.2 the cell where the sky light differs is lucite at (8, 58, 8): engine 14, stand-in 0, its east neighbour 15 in both" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-AT TO WS-SHOW1
     COMPUTE WS-SHOW2 = FUNCTION MOD(CE-SKY(WS-AT), 16)
     COMPUTE WS-SHOW3 = FUNCTION MOD(WS-SS(WS-AT), 16)
     MOVE CE-SKY(WS-AT) TO WS-SHOW4
     MOVE WS-SS(WS-AT) TO WS-SHOW5
     IF WS-STATE = CR-LUCITE
         STRING FUNCTION TRIM(WS-SHOW1) " lucite " FUNCTION TRIM(WS-SHOW2) " " FUNCTION TRIM(WS-SHOW3) " "
             FUNCTION TRIM(WS-SHOW4) " " FUNCTION TRIM(WS-SHOW5) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-SHOW1) " not lucite" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "9541 lucite 14 0 254 240" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-LIGHT-32-CACHE.

 COPY CORETEST.
