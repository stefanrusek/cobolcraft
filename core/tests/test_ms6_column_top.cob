*> Equivalence test (002-lane-bugvlag): MS6-COLUMN-TOP (the column walk of MS6-SPAWN-CHUNK, read from the chunk's cell table) answers what walking down from the top of the dimension with
*> WORLD-GET-BLOCK answered: the height of the highest block that is not air, minY - 1 for an air column. 60 columns of the loaded chunk (stone planted at drawn heights, one at 319, one
*> all air that the floor of the world leaves), and two columns of a chunk that is not loaded (the walk through WORLD-GET-BLOCK, which loads it).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MS6-COLUMN-TOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:stone".
 01 WS-STONE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PLACE-Y             BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-REF                 BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 20261119.
 01 WS-PICK                BINARY-LONG.
 01 WS-DIFFER              BINARY-LONG VALUE 0.
 01 WS-HIGH                BINARY-LONG VALUE 0.
 01 WS-LOW                 BINARY-LONG VALUE 0.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE DM-MIN-Y(WS-DIM) TO WS-MINY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         PERFORM DRAW
         COMPUTE WS-X = WS-CX * 16 + FUNCTION MOD(WS-PICK, 16)
         PERFORM DRAW
         COMPUTE WS-Z = WS-CZ * 16 + FUNCTION MOD(WS-PICK, 16)
         PERFORM DRAW
         COMPUTE WS-PLACE-Y = FUNCTION MOD(WS-PICK, 384) - 64
         IF WS-I = 1
             MOVE 319 TO WS-PLACE-Y
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-PLACE-Y WS-Z WS-STONE
         PERFORM COMPARE-COLUMN
     END-PERFORM
     MOVE "bugvlag the column top equals the walk of WORLD-GET-BLOCK on 60 columns of a loaded chunk" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugvlag the columns hold a high block (above 200) and a low one (below 40), so the walk is not vacuous" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HIGH > 0 AND WS-LOW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   two columns of a chunk that is not loaded: the walk through WORLD-GET-BLOCK loads it
     MOVE 0 TO WS-DIFFER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-X = (WS-CX + 20 + WS-I) * 16 + 3
         COMPUTE WS-Z = (WS-CZ + 20) * 16 + 5
         PERFORM COMPARE-COLUMN
     END-PERFORM
     MOVE "bugvlag the column top equals the walk in a chunk that was not loaded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DIFFER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   WORLD-GET-BLOCK of a loaded cell answers the stored state, of a cell outside the height the void
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X 70 WS-Z WS-STONE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X 70 WS-Z WS-STATE
     MOVE "bugvlag WORLD-GET-BLOCK answers a placed block of a loaded chunk" TO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X 400 WS-Z WS-STATE
     MOVE "bugvlag WORLD-GET-BLOCK answers void above the dimension" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The walk of the replaced loop for column x, z, against MS6-COLUMN-TOP.
 COMPARE-COLUMN.
     COMPUTE WS-Y = WS-MINY + DM-HEIGHT(WS-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-Y < WS-MINY
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     MOVE WS-Y TO WS-REF
     CALL "MS6-COLUMN-TOP" USING WS-DIM WS-X WS-Z WS-GOT
     IF WS-GOT NOT = WS-REF
         ADD 1 TO WS-DIFFER
     END-IF
     IF WS-REF > 200
         ADD 1 TO WS-HIGH
     END-IF
     IF WS-REF < 40
         ADD 1 TO WS-LOW
     END-IF.

 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768).
 END PROGRAM TEST-MS6-COLUMN-TOP.
 COPY CORETEST.
 COPY MOBSPTEST.
