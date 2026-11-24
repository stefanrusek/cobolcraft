*> Implementation test (lane nether; docs/protocol/39-portals.md section 3.3): lighting the largest frame (21 x 21 interior, 441 portal blocks)
*> recomputes the light once per chunk row of the fill (LIGHT-BATCH-*), not once per block: the fill takes seconds, not minutes, and every cell is
*> a portal block; a LIGHT-BATCH nests (only the outermost end recomputes); the recompute after a fill matches that of the same edits made one by
*> one. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-LIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY LIGHTBATCH.
 COPY CELLS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 21.
 01 WS-H                   BINARY-LONG VALUE 21.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-T0                  PIC X(21).
 01 WS-T1                  PIC X(21).
 01 WS-S0                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-CHUNK-ROW           BINARY-LONG.
 01 WS-KEY-OBSIDIAN        PIC X(48) VALUE "minecraft:obsidian".
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-C                   PIC -(9)9.
 01 WS-LEVEL-A             BINARY-LONG.
 01 WS-LEVEL-B             BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "test portal 39 light: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM

*>   Lighting a 21 x 21 frame (interior x 1 to 21, y 100 to 120, z 4): the frame straddles the chunk border x = 16.
     MOVE 1 TO WS-X MOVE 100 TO WS-Y MOVE 4 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE "flint_and_steel" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 1 TO WS-X MOVE 99 TO WS-Y MOVE 4 TO WS-Z
     ADD 1 TO WS-SEQ
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     COMPUTE WS-S0 = FUNCTION NUMVAL(WS-T0(9:2)) * 3600 + FUNCTION NUMVAL(WS-T0(11:2)) * 60 + FUNCTION NUMVAL(WS-T0(13:2))
     COMPUTE WS-S1 = FUNCTION NUMVAL(WS-T1(9:2)) * 3600 + FUNCTION NUMVAL(WS-T1(11:2)) * 60 + FUNCTION NUMVAL(WS-T1(13:2))
     COMPUTE WS-SECONDS = FUNCTION MOD(WS-S1 - WS-S0 + 86400, 86400)
     MOVE 1 TO WS-X MOVE 100 TO WS-Y MOVE 4 TO WS-Z
     CALL "PT-PORTALS" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H WS-COUNT
     MOVE WS-COUNT TO WS-A
     MOVE "test portal 39 light lighting the 21 x 21 frame fills all 441 interior cells" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "441" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "test portal 39 light lighting the 21 x 21 frame takes under 20 seconds (light recomputed once per fill)" TO TL-CASE
     MOVE "N" TO TL-MODE
     IF WS-SECONDS < 20
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE WS-SECONDS TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE LB-DEPTH TO WS-A
     MOVE LB-COUNT TO WS-B
     MOVE "test portal 39 light after the fill no batch is open and no row is pending" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK

*>   A batch nests: an obsidian block placed inside two batches darkens the column under it (sky light 0) only when the outer one ends; the same
*>   block placed outside a batch does at once, and a column without a block keeps sky light 15.
     CALL "GEN-BLOCK-STATE" USING WS-KEY-OBSIDIAN WS-OBSIDIAN
     MOVE 0 TO WS-X
     MOVE 250 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "LIGHT-BATCH-BEGIN"
     CALL "LIGHT-BATCH-BEGIN"
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
     CALL "LIGHT-BATCH-END"
     MOVE LB-DEPTH TO WS-A
     MOVE LB-COUNT TO WS-B
     MOVE 249 TO WS-Y
     PERFORM READ-SKY
     MOVE WS-NUM TO WS-LEVEL-A
     MOVE "test portal 39 light the inner end of nested batches keeps the batch open with one row pending" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1" TO TL-EXPECTED
     PERFORM CHECK
     CALL "LIGHT-BATCH-END"
     PERFORM READ-SKY
     MOVE WS-NUM TO WS-LEVEL-A
     MOVE 0 TO WS-X
     MOVE 250 TO WS-Y
     MOVE 80 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
     MOVE 249 TO WS-Y
     PERFORM READ-SKY
     MOVE WS-NUM TO WS-LEVEL-B
     MOVE 120 TO WS-Z
     PERFORM READ-SKY
     MOVE WS-LEVEL-A TO WS-A
     MOVE WS-LEVEL-B TO WS-B
     MOVE WS-NUM TO WS-C
     MOVE "test portal 39 light a block placed in a batch darkens the column after the end like one placed outside a batch; a free column stays 15" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0 15" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 READ-SKY.
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK-ROW)
     COMPUTE WS-CELL = WS-Y * 256 + (WS-Z - WS-CZ * 16) * 16 + WS-X - WS-CX * 16 + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE WS-NUM = FUNCTION MOD(CE-SKY(WS-BYTE), 16)
     ELSE
         COMPUTE WS-NUM = CE-SKY(WS-BYTE) / 16
     END-IF.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-LIGHT.

 COPY CORETEST.
 COPY PORTALTEST.
