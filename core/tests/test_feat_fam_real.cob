*> Real-data probe of the lichen and sculk families (skipped as a pass without the generated packs; docs/protocol/35-worldgen-features-4 section 8, 35-6 section 8): on the generated vanilla-data
*> (CC_GENERATED_DIR, read only) a standard world generates a 5 x 5 chunk area (chunks -2 to 2) whole by the atomic path; the glow lichen, sculk vein, sculk, sculk sensor and shrieker blocks of
*> the chunks are counted and the time of the area is printed as evidence of the cost; the chunk with the most of them is generated again by a worker process and equals the atomic chunk byte
*> for byte.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-FAM-REAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-SLEEP               PIC 9(2)V9(2) VALUE 0.05.
 01 WS-REF                 PIC X(304640).
 01 WS-BEST                PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAME                BINARY-LONG.
 01 WS-CLOCK               PIC X(21).
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-N-LICHEN            BINARY-LONG.
 01 WS-N-VEIN              BINARY-LONG.
 01 WS-N-SCULK             BINARY-LONG.
 01 WS-N-SENSOR            BINARY-LONG.
 01 WS-N-SHRIEKER          BINARY-LONG.
 01 WS-N-POINTED           BINARY-LONG.
 01 WS-N-DRIP              BINARY-LONG.
 01 WS-B-LICHEN            BINARY-LONG.
 01 WS-B-VEIN              BINARY-LONG.
 01 WS-B-SCULK             BINARY-LONG.
 01 WS-B-SENSOR            BINARY-LONG.
 01 WS-B-SHRIEKER          BINARY-LONG.
 01 WS-B-POINTED           BINARY-LONG.
 01 WS-B-DRIP              BINARY-LONG.
 01 WS-SCORE               BINARY-LONG.
 01 WS-BEST-SCORE          BINARY-LONG.
 01 WS-BEST-X              BINARY-LONG.
 01 WS-BEST-Z              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-EDIT                PIC Z(7)9.
 01 WS-EDIT2               PIC Z(7)9.
 01 WS-EDIT3               PIC Z(7)9.
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
         MOVE "test feat fam real no generated packs here, skipped" TO TL-CASE
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
     MOVE "glow_lichen" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-LICHEN
     ADD 1 TO WS-B-LICHEN
     MOVE "sculk_vein" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-VEIN
     ADD 1 TO WS-B-VEIN
     MOVE "sculk" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-SCULK
     ADD 1 TO WS-B-SCULK
     MOVE "sculk_sensor" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-SENSOR
     ADD 1 TO WS-B-SENSOR
     MOVE "sculk_shrieker" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-SHRIEKER
     ADD 1 TO WS-B-SHRIEKER
     MOVE "pointed_dripstone" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-POINTED
     ADD 1 TO WS-B-POINTED
     MOVE "dripstone_block" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-B-DRIP
     ADD 1 TO WS-B-DRIP
     MOVE 0 TO WS-N-LICHEN WS-N-VEIN WS-N-SCULK WS-N-SENSOR WS-N-SHRIEKER WS-N-POINTED WS-N-DRIP WS-BEST-SCORE
     MOVE 0 TO WS-BEST-X WS-BEST-Z
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     MOVE WS-T0 TO WS-T1
     PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 2
         PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 2
             CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
             PERFORM COUNT-CHUNK
             IF WS-SCORE > WS-BEST-SCORE
                 MOVE WS-SCORE TO WS-BEST-SCORE
                 MOVE WS-CX TO WS-BEST-X
                 MOVE WS-CZ TO WS-BEST-Z
                 MOVE WS-REF TO WS-BEST
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     PERFORM CLOCK-MS
     COMPUTE WS-TOTAL = WS-T0 - WS-T1
     MOVE WS-TOTAL TO WS-EDIT
     DISPLAY "PROBE 25 chunks (-2..2): " FUNCTION TRIM(WS-EDIT) " ms"
     MOVE WS-N-LICHEN TO WS-EDIT
     MOVE WS-N-VEIN TO WS-EDIT2
     MOVE WS-N-SCULK TO WS-EDIT3
     DISPLAY "PROBE glow lichen " FUNCTION TRIM(WS-EDIT) ", sculk vein " FUNCTION TRIM(WS-EDIT2) ", sculk " FUNCTION TRIM(WS-EDIT3)
     MOVE WS-N-SENSOR TO WS-EDIT
     MOVE WS-N-SHRIEKER TO WS-EDIT2
     DISPLAY "PROBE sculk sensor " FUNCTION TRIM(WS-EDIT) ", shrieker " FUNCTION TRIM(WS-EDIT2)
     MOVE WS-N-POINTED TO WS-EDIT
     MOVE WS-N-DRIP TO WS-EDIT2
     DISPLAY "PROBE pointed dripstone " FUNCTION TRIM(WS-EDIT) ", dripstone blocks " FUNCTION TRIM(WS-EDIT2)
     MOVE "test feat fam real the area holds glow lichen (the lichen family runs in the standard world)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N-LICHEN > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-BEST-SCORE = 0
         STOP RUN
     END-IF

*>   The chunks of the spawn area are loaded at world open and take the overflow of their neighbours (docs/design/world-types.md
*>   "Chunk borders"), so they differ from the atomic chunk by design. The worker is compared on the chunk with the most family
*>   blocks of a far area (chunks 8..10), which the world has not loaded: the worker makes it from nothing, with no overflow.
     MOVE 0 TO WS-BEST-SCORE
     PERFORM VARYING WS-CX FROM 8 BY 1 UNTIL WS-CX > 10
         PERFORM VARYING WS-CZ FROM 8 BY 1 UNTIL WS-CZ > 10
             CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
             PERFORM COUNT-CHUNK
             IF WS-SCORE > WS-BEST-SCORE OR (WS-CX = 8 AND WS-CZ = 8)
                 MOVE WS-SCORE TO WS-BEST-SCORE
                 MOVE WS-CX TO WS-BEST-X
                 MOVE WS-CZ TO WS-BEST-Z
                 MOVE WS-REF TO WS-BEST
             END-IF
         END-PERFORM
     END-PERFORM
*>   the worker makes the same chunk
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-QUEUE-WANT" USING WS-DIM WS-BEST-X WS-BEST-Z
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-ROW
     PERFORM UNTIL WS-ROW > 0 OR WS-TICKS > 12000
         CALL "GEN-QUEUE-TICK"
         ADD 1 TO WS-TICKS
         CALL "C$SLEEP" USING WS-SLEEP
         CALL "WORLD-FIND" USING WS-DIM WS-BEST-X WS-BEST-Z WS-ROW
     END-PERFORM
     MOVE 0 TO WS-SAME
     IF WS-ROW > 0
         SET ADDRESS OF WS-A TO CK-ADDR(WS-ROW)
         IF WS-A = WS-BEST
             MOVE 1 TO WS-SAME
         END-IF
     END-IF
     MOVE "test feat fam real the chunk with the most blocks of the families from a worker equals the atomic chunk byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     STOP RUN.

*> COUNT-CHUNK: adds the blocks of the families in WS-REF to the totals; WS-SCORE is their number in this chunk
 COUNT-CHUNK.
     MOVE 0 TO WS-SCORE
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-REF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         MOVE CE-STATE(WS-I) TO WS-STATE
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         EVALUATE TRUE
             WHEN WS-BLOCK = WS-B-LICHEN
                 ADD 1 TO WS-N-LICHEN WS-SCORE
             WHEN WS-BLOCK = WS-B-VEIN
                 ADD 1 TO WS-N-VEIN WS-SCORE
             WHEN WS-BLOCK = WS-B-SCULK
                 ADD 1 TO WS-N-SCULK WS-SCORE
             WHEN WS-BLOCK = WS-B-SENSOR
                 ADD 1 TO WS-N-SENSOR WS-SCORE
             WHEN WS-BLOCK = WS-B-SHRIEKER
                 ADD 1 TO WS-N-SHRIEKER WS-SCORE
             WHEN WS-BLOCK = WS-B-POINTED
                 ADD 1 TO WS-N-POINTED WS-SCORE
             WHEN WS-BLOCK = WS-B-DRIP
                 ADD 1 TO WS-N-DRIP WS-SCORE
         END-EVALUATE
     END-PERFORM
     .
 CLOCK-MS.
     COMPUTE WS-T0 = FUNCTION NUMVAL(WS-CLOCK(9:2)) * 3600000 + FUNCTION NUMVAL(WS-CLOCK(11:2)) * 60000
         + FUNCTION NUMVAL(WS-CLOCK(13:2)) * 1000 + FUNCTION NUMVAL(WS-CLOCK(15:2)) * 10.
 END PROGRAM TEST-FEAT-FAM-REAL.

 COPY NOSPAWN.
 COPY CORETEST.
