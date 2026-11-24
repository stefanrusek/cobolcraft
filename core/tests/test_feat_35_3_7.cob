*> Implementation test of the fallen tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md section 7; core/src/feat-tree-fallen.cob): the data features compile as type 16; a fallen tree
*> places its stump at the origin and, 2 or 3 cells off along a random horizontal direction, log_length - 2 logs with the axis of that direction on the ground found by the search of 7.3 (down
*> to 5 cells below); more than two unsupported cells in the walk (7.4), or a length of 2 or less, leave only the stump; the stump and log decorators (attached_to_logs, 35-4 3.3) put their block
*> above the logs with probability 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CONTENT.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/tree-types".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/feat-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOGB                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-SEEDS-OK            BINARY-LONG.
 01 WS-OFFCOL              BINARY-LONG.
 01 WS-MUDDY               BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 01 WS-ROOTS               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-TX                  BINARY-LONG VALUE 24.
 01 WS-MIN-C               BINARY-LONG.
 01 WS-LYD                 PIC 999.
 01 WS-MAX-C               BINARY-LONG.
 01 WS-NEIGH               BINARY-LONG.
 01 WS-LAYER-TOTAL         BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-STATE-NO            BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-A                   PIC X(196608) BASED.


 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-TABLE
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 4 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 5 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   the data features compile as fallen trees (type 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:t_fallen" TO WS-KEY
             WHEN 2 MOVE "minecraft:t_fallen_two" TO WS-KEY
             WHEN 3 MOVE "minecraft:t_fallen_six" TO WS-KEY
             WHEN 4 MOVE "minecraft:t_fallen_deco" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-3§7: the data feature " FUNCTION TRIM(WS-KEY) " compiles as a fallen tree" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE 16 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   thirty fallen trees (length 4 to 7, so 2 to 5 logs and the stump) on flat ground: always returns true, the stump stands at the origin, the logs lie on layer 63 on a line
*>   through the origin along the axis their state says, 2 or 3 cells from it
     MOVE "minecraft:t_fallen" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 0 TO WS-BAD
     MOVE 99 TO WS-MIN-C
     MOVE 0 TO WS-MAX-C
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 24 TO WS-LX
         MOVE 63 TO WS-LY
         MOVE 40 TO WS-LZ
         PERFORM READ-BLOCK
         IF WS-BLOCK NOT = 5
             ADD 1 TO WS-BAD
         END-IF
         PERFORM CHECK-LINE
         ADD WS-NEIGH TO WS-BAD
         IF WS-COUNT < WS-MIN-C
             MOVE WS-COUNT TO WS-MIN-C
         END-IF
         IF WS-COUNT > WS-MAX-C
             MOVE WS-COUNT TO WS-MAX-C
         END-IF
     END-PERFORM
     MOVE "35-3§7: thirty fallen trees have a stump at the origin and a straight line of logs 2 or 3 cells off with the axis of the line" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§7: the fallen logs of length 4 to 7 number 2 to 5 and not always the same" TO WS-CASE
     IF WS-MIN-C >= 2 AND WS-MAX-C <= 5 AND WS-MAX-C > WS-MIN-C
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a length of 2 leaves only the stump
     MOVE "minecraft:t_fallen_two" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§7: a length of 2 places no log, only the stump" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   length 6, ground only under the origin: the walk has more than two unsupported cells, so only the stump
     MOVE "minecraft:t_fallen_six" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             IF WS-LX NOT = 24 OR WS-LZ NOT = 40
                 MOVE 62 TO WS-LY
                 MOVE 0 TO WS-STATE
                 CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM PLACE-TREE
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§7.4: more than two unsupported cells leave only the stump" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   two unsupported cells are allowed: ground only at the 4 cells of the walk but two of them (ground at the other cells in the walk line is simply the whole floor minus a hole of 2)
*>   the ground search: floor 3 lower outside the origin cell, the logs go down to layer 61
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             IF WS-LX NOT = 24 OR WS-LZ NOT = 40
                 MOVE 62 TO WS-LY
                 MOVE 0 TO WS-STATE
                 CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
                 MOVE 59 TO WS-LY
                 MOVE CB-DEFAULT-STATE(3) TO WS-STATE
                 CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM PLACE-TREE
     MOVE 5 TO WS-LOGB
     MOVE 60 TO WS-N
     PERFORM COUNT-LAYER
     MOVE "35-3§7.3: with the ground 3 lower the six-long fallen log lies on layer 60, four logs" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 4 TO WS-EXP
     PERFORM ASSERT-N

*>   a stone in the walk: stones at 5 and 6 cells from the origin in all four directions (on layer 63) refuse the walk, only the stump stays
     MOVE "minecraft:t_fallen_six" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 63 TO WS-LY
     MOVE CB-DEFAULT-STATE(2) TO WS-STATE
     MOVE 19 TO WS-LX
     MOVE 40 TO WS-LZ
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 18 TO WS-LX
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 29 TO WS-LX
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 30 TO WS-LX
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 24 TO WS-LX
     MOVE 35 TO WS-LZ
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 34 TO WS-LZ
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 45 TO WS-LZ
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 46 TO WS-LZ
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§7.4: a solid block in the walk refuses it, only the stump stays" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the decorators: the stump and each of the four logs get a stone above them (probability 1)
     MOVE "minecraft:t_fallen_deco" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 2 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§7 and 35-4§3.3: the stump decorator and the log decorator put 1 + 4 stones above the stump and the logs" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-LX
     MOVE 64 TO WS-LY
     MOVE 40 TO WS-LZ
     PERFORM READ-BLOCK
     MOVE "35-4§3.3: the stone above the stump is at the origin plus one" TO WS-CASE
     MOVE WS-BLOCK TO WS-OBS
     MOVE 2 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-LINE.
*>   WS-COUNT = the logs other than the stump; WS-NEIGH = the faults: a log off layer 63, off the line through the origin (x = 24 or z = 40), 1 or fewer or 4 or more cells from the
*>   origin, or with an axis state that is not the one of the line (x before the default, z after it); the logs of the line are counted by distance
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-NEIGH
     MOVE 0 TO WS-N
     PERFORM VARYING WS-LY FROM 40 BY 1 UNTIL WS-LY > 100
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = 5 AND (WS-LX NOT = 24 OR WS-LZ NOT = 40)
                     ADD 1 TO WS-COUNT
                     IF WS-LY NOT = 63
                         ADD 1 TO WS-NEIGH
                     END-IF
                     IF WS-LX NOT = 24 AND WS-LZ NOT = 40
                         ADD 1 TO WS-NEIGH
                     END-IF
                     COMPUTE WS-D = FUNCTION ABS(WS-LX - 24) + FUNCTION ABS(WS-LZ - 40)
                     IF WS-D < 2 OR WS-D > 8
                         ADD 1 TO WS-NEIGH
                     END-IF
                     IF WS-LZ = 40
                         IF WS-STATE NOT = CB-DEFAULT-STATE(5) - 1
                             ADD 1 TO WS-NEIGH
                         END-IF
                     ELSE
                         IF WS-STATE NOT = CB-DEFAULT-STATE(5) + 1
                             ADD 1 TO WS-NEIGH
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COUNT-LAYER.
*>   WS-COUNT = the blocks WS-LOGB in layer y = WS-N of the chunk window
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE WS-N TO WS-LY
             PERFORM READ-BLOCK
             IF WS-BLOCK = WS-LOGB
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     .
 READ-BLOCK.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     .
 COUNT-LOGS.
*>   WS-COUNT = the blocks WS-LOGB in the chunk window from y = 40
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LY FROM 40 BY 1 UNTIL WS-LY > 100
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LOGB
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 PLACE-TREE.
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 NEW-WORLD.
*>   an empty chunk (1, 2) with a grass floor at y = 62
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE 62 TO WS-LY
             MOVE CB-DEFAULT-STATE(3) TO WS-STATE
             CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 BUILD-TABLE.
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 oak_log (3 states, default the second), 6 oak_leaves (28, default the last)
     MOVE 6 TO CB-BLOCK-COUNT
     MOVE 12 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 1 TO WS-N
         MOVE 0 TO WS-D
         EVALUATE WS-I
             WHEN 5
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 6
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
         END-EVALUATE
         MOVE WS-STATE-NO TO CB-FIRST-STATE(WS-I)
         MOVE WS-N TO CB-STATES(WS-I)
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-STATE-NO + WS-D
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= WS-N
             COMPUTE WS-Y = WS-STATE-NO + WS-X + 1
             COMPUTE CB-S-BLOCK(WS-Y) = WS-I - 1
         END-PERFORM
         ADD WS-N TO WS-STATE-NO
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE WS-STATE-NO TO CB-STATE-COUNT
     MOVE 1 TO CB-SOLID(2)
     MOVE 1 TO CB-SOLID(3)
     MOVE 1 TO CB-SOLID(4)
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:oak_log" TO CB-KEY(5)
     MOVE "minecraft:oak_leaves" TO CB-KEY(6)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-3-7.
