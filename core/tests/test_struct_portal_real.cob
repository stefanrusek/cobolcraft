*> Real-data probe of the ruined portals through the generation job (skipped as a pass without the generated packs; docs/design/world-types.md structures part 9): on the generated
*> vanilla-data (CC_GENERATED_DIR, read only) each ruined portal structure but the swamp one (this seed has no swamp start in the area) is switched on alone (STRUCT-GATE-ON), the first chunk of a 300 x 300 chunk area whose start is that structure is
*> found by STRUCT-CHUNK-STARTS (the biome rules of the data apply, with the cold test of the biome), and that chunk and its neighbours to the south and north are generated whole by the atomic
*> path (GEN-JOB-RUN-ALL) with the structure off and on, and by a worker process (the queue): the structure changes the chunk, the worker's chunk equals the atomic chunk byte for byte, and
*> the times with and without the structure are printed as the cost evidence. A structure with no start in the area is reported and fails its case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-PORTAL-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY GENQUEUE.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NAME                PIC X(40).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-JD                  PIC S9 SIGN LEADING SEPARATE.
 01 WS-NEED-MANY           PIC 9 VALUE 0.
 01 WS-MIN-PIECES           BINARY-LONG VALUE 2.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FV                  BINARY-LONG.
 01 WS-ROUND               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-SLEEP               PIC 9(2)V9(2) VALUE 0.05.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-REF2                PIC X(304640).
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAME                BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-ON-MS               BINARY-LONG.
 01 WS-OFF-MS              BINARY-LONG.
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
 01 WS-EDIT3               PIC -(7)9.
 01 WS-EDIT4               PIC -(7)9.
 01 WS-STRUCT-ROW          BINARY-LONG.
 01 WS-WANT-NAME           PIC X(3) VALUE SPACES.
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
         MOVE "test struct portal real no generated packs here, skipped" TO TL-CASE
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
     MOVE CW-DIM(1) TO WS-DIM
     MOVE "minecraft:ruined_portal" TO WS-KEY
     PERFORM ONE-STRUCTURE
     MOVE "minecraft:ruined_portal_desert" TO WS-KEY
     PERFORM ONE-STRUCTURE
     MOVE "minecraft:ruined_portal_jungle" TO WS-KEY
     PERFORM ONE-STRUCTURE
     MOVE "minecraft:ruined_portal_mountain" TO WS-KEY
     PERFORM ONE-STRUCTURE
     MOVE "minecraft:ruined_portal_ocean" TO WS-KEY
     PERFORM ONE-STRUCTURE
     STOP RUN.

 ONE-STRUCTURE.
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE 0 TO WS-STRUCT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-KEY
             MOVE WS-I TO WS-STRUCT-ROW
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FOUND
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-SX FROM -150 BY 1 UNTIL WS-SX > 149 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -150 BY 1 UNTIL WS-SZ > 149 OR WS-FOUND = 1
             CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-SX WS-SZ WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 IF SC-STRUCT(WS-I) = WS-STRUCT-ROW AND WS-FOUND = 0
                     MOVE 1 TO WS-FOUND
                     IF WS-NEED-MANY = 1
                         CALL "STRUCT-FIND-POINT" USING WS-STRUCT-ROW CW-SEED WS-SX WS-SZ WS-FX WS-FY WS-FZ WS-FV
                         IF SP-COUNT < WS-MIN-PIECES
                             MOVE 0 TO WS-FOUND
                         END-IF
                     END-IF
                     IF WS-FOUND = 1
                         MOVE WS-SX TO WS-CX
                         MOVE WS-SZ TO WS-CZ
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-ON-MS = WS-T0 - WS-T1
     MOVE WS-ON-MS TO WS-EDIT
     MOVE WS-CX TO WS-EDIT3
     MOVE WS-CZ TO WS-EDIT4
     DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) ": first start in the area at chunk (" FUNCTION TRIM(WS-EDIT3) "," FUNCTION TRIM(WS-EDIT4)
         ") found = " WS-FOUND ", scan " FUNCTION TRIM(WS-EDIT) " ms"
     MOVE SPACES TO TL-CASE
     STRING "test struct portal real given " FUNCTION TRIM(WS-KEY) " alone and many pieces " WS-NEED-MANY " when 300 x 300 chunks are scanned then a start is found" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 1
         PERFORM CHUNK-CHECKS
     END-IF.

 CHUNK-CHECKS.
     PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 1
         COMPUTE WS-SZ = WS-CZ + WS-J
         MOVE WS-J TO WS-JD
*>       atomic with the structure off (after a warm-up), then on
         CALL "STRUCT-GATE-RESET"
         CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-SZ WS-REF2 WS-REF-Y
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         MOVE WS-T0 TO WS-T1
         CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-SZ WS-REF2 WS-REF-Y
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         COMPUTE WS-OFF-MS = WS-T0 - WS-T1
         CALL "STRUCT-GATE-ON" USING WS-KEY
         MOVE WS-T0 TO WS-T1
         CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-SZ WS-REF WS-REF-Y
         MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
         PERFORM CLOCK-MS
         COMPUTE WS-ON-MS = WS-T0 - WS-T1
         MOVE WS-ON-MS TO WS-EDIT
         MOVE WS-OFF-MS TO WS-EDIT2
         DISPLAY "PROBE " FUNCTION TRIM(WS-KEY) " chunk +" WS-JD " of the start: " FUNCTION TRIM(WS-EDIT) " ms with it, " FUNCTION TRIM(WS-EDIT2) " ms without"
         MOVE 0 TO WS-DIFF
         IF WS-REF NOT = WS-REF2
             MOVE 1 TO WS-DIFF
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "test struct portal real given " FUNCTION TRIM(WS-KEY) " when its start chunk " WS-JD " and pieces " WS-NEED-MANY " is generated then the structure changes the chunk" DELIMITED BY SIZE INTO TL-CASE
         IF WS-J = 0
             MOVE 1 TO TL-EXPECTED-N
             MOVE WS-DIFF TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
*>       the worker makes the same chunk
         CALL "GEN-QUEUE-RESET"
         CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
         CALL "GEN-QUEUE-WANT" USING WS-DIM WS-CX WS-SZ
         MOVE 0 TO WS-TICKS
         MOVE 0 TO WS-ROW
         PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 12000
             CALL "GEN-QUEUE-TICK"
             ADD 1 TO WS-TICKS
             CALL "C$SLEEP" USING WS-SLEEP
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-SZ WS-ROW
         END-PERFORM
         MOVE 0 TO WS-SAME
         IF WS-ROW > 0
             SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
             IF WS-A = WS-REF
                 MOVE 1 TO WS-SAME
             END-IF
         END-IF
         MOVE 0 TO WS-WORKERS
         CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
         MOVE 1 TO WS-WORKERS
         MOVE SPACES TO TL-CASE
         STRING "test struct portal real given " FUNCTION TRIM(WS-KEY) " when its start chunk " WS-JD " and pieces " WS-NEED-MANY " is made by a worker then it equals the atomic chunk byte for byte" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-SAME TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-STRUCT-PORTAL-REAL.

 COPY CORETEST.
