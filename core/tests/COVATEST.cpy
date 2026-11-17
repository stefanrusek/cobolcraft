*> Helpers of the coverage-lane tests (test_cova_*; COPY after the test program, touch the test after changing it).
*>   CA-N USING case (PIC X(240)), expected, observed (BINARY-DOUBLE): one numeric assertion.
*>   CA-RAIL USING dim, x, y, z, kind (1 rail, 2 powered, 3 activator, 4 detector), shape (PIC X(16) property text), powered (1 or 0): sets a rail block.
*>   CA-CART USING kind, dim, x, y, z (FLOAT-LONG), row out, slot out (BINARY-LONG): spawns a minecart and finds its projectile slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CA-N.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(240).
 01 L-EXPECTED             BINARY-DOUBLE.
 01 L-OBSERVED             BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM CA-N.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CA-RAIL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-MODE                BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-SHAPE                PIC X(16).
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-SHAPE L-POWERED.
     MOVE SPACES TO WS-KEY
     EVALUATE L-KIND
         WHEN 1
             MOVE "minecraft:rail" TO WS-KEY
         WHEN 2
             MOVE "minecraft:powered_rail" TO WS-KEY
         WHEN 3
             MOVE "minecraft:activator_rail" TO WS-KEY
         WHEN OTHER
             MOVE "minecraft:detector_rail" TO WS-KEY
     END-EVALUATE
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     MOVE "shape" TO WS-NAME
     MOVE SPACES TO WS-TEXT
     MOVE L-SHAPE TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-NEW
     MOVE WS-NEW TO WS-STATE
     IF L-KIND > 1
         MOVE "powered" TO WS-NAME
         MOVE SPACES TO WS-TEXT
         IF L-POWERED = 1
             MOVE "true" TO WS-TEXT
         ELSE
             MOVE "false" TO WS-TEXT
         END-IF
         CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-NEW
         MOVE WS-NEW TO WS-STATE
     END-IF
     CALL "WORLD-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     GOBACK.
 END PROGRAM CA-RAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CA-CART.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-ROW L-SLOT.
     CALL "MINECART-SPAWN" USING L-KIND L-DIM L-X L-Y L-Z L-ROW
     MOVE 0 TO L-SLOT
     IF L-ROW > 0
         CALL "PJ-FIND" USING EN-ID(L-ROW) L-SLOT
     END-IF
     GOBACK.
 END PROGRAM CA-CART.
