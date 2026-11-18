*> Acceptance test (T1616, US12-2; docs/protocol/36-structures-1 sections 4.3 and 5.2, 36-structures-9 section 2.3): on the generated vanilla-data (CC_GENERATED_DIR,
*> read only; skipped as a pass without the generated packs) a standard world of the fixed seed text 12345 places the villages at the documented position. The structure set
*> villages is a random_spread of spacing 34, separation 8 and salt 10387312 (linear): for each of the 25 cells (-3 to 1 on both axes) the potential chunk is computed here from the
*> documented formula (the Java LCG seeded with rx * 341873128712 + rz * 132897987541 + seed + salt, then two nextInt(26) draws), and the world's starts agree with it: no chunk
*> of a cell but its potential chunk holds a village start (the cell origin and the neighbours of the potential chunk are asked), and the potential chunk holds a village start
*> in at least one cell. The chunk of the first start, generated whole with the villages on and off, differs: the villages put their pieces into it, and the chunk generated twice is the same.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-STRUCTURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SALT                BINARY-LONG VALUE 10387312.
 01 WS-SPACING             BINARY-LONG VALUE 34.
 01 WS-LIMIT               BINARY-LONG VALUE 26.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-STRAYS              BINARY-LONG.
 01 WS-ABSENT              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-VILLAGE-ROW         BINARY-LONG.
 01 WS-FIRST-X             BINARY-LONG.
 01 WS-FIRST-Z             BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF2                PIC X(304640).
 01 WS-REF3                PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
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
         MOVE "acceptance US12 structures: no generated packs here, skipped" TO TL-CASE
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
     MOVE CW-SEED TO WS-SEED
     CALL "STRUCT-GATE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I)(1:18) = "minecraft:village_"
             MOVE SDT-KEY(WS-I) TO WS-KEY
             CALL "STRUCT-GATE-ON" USING WS-KEY
         END-IF
     END-PERFORM

*>   the cells: potential chunk from the documented formula, then what the world holds at and around it
     MOVE 0 TO WS-HITS WS-STRAYS WS-FOUND WS-ABSENT
     PERFORM VARYING WS-RX FROM -3 BY 1 UNTIL WS-RX > 1
         PERFORM VARYING WS-RZ FROM -3 BY 1 UNTIL WS-RZ > 1
             COMPUTE WS-V = FUNCTION MOD(WS-RX * 341873128712 + WS-RZ * 132897987541 + WS-SEED + WS-SALT, 18446744073709551616)
             CALL "JRAND-SET-SEED" USING WS-STATE WS-V
             CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-DX
             CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-LIMIT WS-DZ
             COMPUTE WS-PX = WS-RX * WS-SPACING + WS-DX
             COMPUTE WS-PZ = WS-RZ * WS-SPACING + WS-DZ
             MOVE WS-PX TO WS-CX
             MOVE WS-PZ TO WS-CZ
             PERFORM COUNT-VILLAGES
             IF WS-VILLAGES > 0
                 ADD 1 TO WS-HITS
                 IF WS-FOUND = 0
                     MOVE 1 TO WS-FOUND
                     MOVE WS-PX TO WS-FIRST-X
                     MOVE WS-PZ TO WS-FIRST-Z
                 END-IF
             ELSE
                 ADD 1 TO WS-ABSENT
             END-IF
*>           the cell origin and the four neighbours of the potential chunk hold no village start (unless they are the potential chunk)
             COMPUTE WS-CX = WS-RX * WS-SPACING
             COMPUTE WS-CZ = WS-RZ * WS-SPACING
             PERFORM STRAY-CHECK
             COMPUTE WS-CX = WS-PX + 1
             MOVE WS-PZ TO WS-CZ
             PERFORM STRAY-CHECK
             COMPUTE WS-CX = WS-PX - 1
             PERFORM STRAY-CHECK
             MOVE WS-PX TO WS-CX
             COMPUTE WS-CZ = WS-PZ + 1
             PERFORM STRAY-CHECK
             COMPUTE WS-CZ = WS-PZ - 1
             PERFORM STRAY-CHECK
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-9§2 Structure sets: no chunk of the 25 cells but the documented potential chunk holds a village start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STRAYS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§2 Structure sets: the potential chunk holds a village start in at least one cell (the biome decides the others)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HITS TO WS-A
     MOVE WS-ABSENT TO WS-B
     DISPLAY "PROBE villages: " FUNCTION TRIM(WS-A) " cells hold a start at the documented chunk, " FUNCTION TRIM(WS-B) " do not"
     IF WS-FOUND = 0
         STOP RUN
     END-IF

*>   the first start: its chunk generated with the villages off and on
     MOVE WS-FIRST-X TO WS-CX
     MOVE WS-FIRST-Z TO WS-CZ
     CALL "STRUCT-GATE-RESET"
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF2 WS-REF-Y
     MOVE WS-REF2 TO WS-REF3
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I)(1:18) = "minecraft:village_"
             MOVE SDT-KEY(WS-I) TO WS-KEY
             CALL "STRUCT-GATE-ON" USING WS-KEY
         END-IF
     END-PERFORM
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     MOVE 0 TO WS-DIFF
     IF WS-REF NOT = WS-REF2
         MOVE 1 TO WS-DIFF
     END-IF
     MOVE "acceptance US12 36-1§8 Placing pieces: the start chunk generated with the villages on differs from the same chunk with them off" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DIFF TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-REF TO WS-REF3
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF3 WS-REF-Y
     MOVE 0 TO WS-SAME
     IF WS-REF3 = WS-REF
         MOVE 1 TO WS-SAME
     END-IF
     MOVE "acceptance US12 36-1§5 Creating starts: the same world generates the start chunk again the same byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   WS-VILLAGES: the village starts at chunk (WS-CX, WS-CZ)
 COUNT-VILLAGES.
     CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-CX WS-CZ WS-COUNT
     MOVE 0 TO WS-VILLAGES
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
         MOVE SC-STRUCT(WS-J) TO WS-VILLAGE-ROW
         IF SDT-KEY(WS-VILLAGE-ROW)(1:18) = "minecraft:village_"
             ADD 1 TO WS-VILLAGES
         END-IF
     END-PERFORM.

 STRAY-CHECK.
     IF WS-CX NOT = WS-PX OR WS-CZ NOT = WS-PZ
         PERFORM COUNT-VILLAGES
         ADD WS-VILLAGES TO WS-STRAYS
     END-IF.
 END PROGRAM ACC-F2US12-STRUCTURES.

 COPY NOSPAWN.
 COPY CORETEST.
