*> Test of would_survive of the firefly bush (docs/protocol/29b-falling-growth-fire-4-growing-plants.md section 10.7 and the survival table: the block below is in the tag
*> supports_vegetation): the placed feature patch_firefly_bush's filter (air and would_survive) compiles (status 1) and, over five seeds of a random ground (grass_block, in the
*> tag, or stone, not in it, per column, from the test's own stream) and every cell of a 16 x 16 column grid at three heights, FR-PLACE-PF puts a firefly_bush exactly in the
*> air cells whose cell below is grass_block (the shadow model reads the ground it built), and writes nothing else.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-FIREFLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/endfeat".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PFKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG VALUE 0.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-GRASS             BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-BUSH              BINARY-LONG.
 01 WS-N-BUSH              BINARY-LONG.
 01 WS-N-WANT              BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
 01 WS-RUNTXT              PIC 9.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 256 TIMES.
 01 WS-IDX                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "grass_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GRASS
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRASS
     MOVE "firefly_bush" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BUSH
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-GRASS - 1
     MOVE "minecraft:supports_vegetation" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "minecraft:pl_firefly" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "29b§10.7: the firefly bush filter (air and would_survive) compiles" TO WS-CASE
     MOVE PF-STATUS(WS-PF) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM VARYING WS-RUN FROM 1 BY 1 UNTIL WS-RUN > 5
         COMPUTE WS-SEED = WS-RUN * 31
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         SET ADDRESS OF WS-AREA TO WS-PTR
         MOVE LOW-VALUES TO WS-AREA
         MOVE 0 TO WS-QX
         MOVE 0 TO WS-QZ
         CALL "FL-OPEN" USING WS-PTR WS-QX WS-QZ WS-MIN WS-HEIGHT WS-SEA
         MOVE 0 TO WS-IDX
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 ADD 1 TO WS-IDX
                 MOVE 2 TO WS-DRAW
                 CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-R
                 MOVE WS-R TO WS-G(WS-IDX)
                 PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
                     IF WS-Y = 10 AND WS-R = 1
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-GRASS WS-FLAGS WS-OK
                     ELSE
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-S-STONE WS-FLAGS WS-OK
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
*>       the feature tries the cells at y 10 (the grass itself), 11 (air on the ground) and 12 (air with air below)
         MOVE 0 TO WS-BAD
         MOVE 0 TO WS-N-BUSH
         MOVE 0 TO WS-N-WANT
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 12
                     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE 0 TO WS-IDX
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                 ADD 1 TO WS-IDX
                 PERFORM VARYING WS-Y FROM 9 BY 1 UNTIL WS-Y > 13
                     PERFORM BLOCK-NOW
                     IF WS-Y = 11 AND WS-G(WS-IDX) = 1
                         ADD 1 TO WS-N-WANT
                         IF WS-BLOCK NOT = WS-B-BUSH
                             ADD 1 TO WS-BAD
                         END-IF
                     ELSE
                         IF WS-BLOCK = WS-B-BUSH
                             ADD 1 TO WS-BAD
                         END-IF
                     END-IF
                     IF WS-BLOCK = WS-B-BUSH
                         ADD 1 TO WS-N-BUSH
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE WS-RUN TO WS-RUNTXT
         MOVE SPACES TO WS-CASE
         STRING "29b§10.7: seed " WS-RUNTXT " a firefly bush stands exactly in the air above grass_block and nowhere else" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "29b§10.7: seed " WS-RUNTXT " the number of bushes equals the number of grass columns" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-BUSH TO WS-OBS
         MOVE WS-N-WANT TO WS-EXP
         IF WS-N-WANT = 0
             ADD 1000 TO WS-EXP
         END-IF
         PERFORM ASSERT-N
     END-PERFORM
     STOP RUN
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-FIREFLY.
 COPY CORETEST.
