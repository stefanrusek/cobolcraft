*> Test of the fixed_placement modifier compiled from data (docs/protocol/35-worldgen-features-1-model-and-placement.md section 7.18, 35-7 section 10.2): the placed
*> feature compiles (status 1), a non-integer coordinate or more than four positions makes it unsupported (status 2); over many input positions (every chunk of a
*> window, with a seed-driven offset inside the chunk and a seed-driven y) FR-MODIFY emits, in list order, exactly the listed positions that lie in the chunk of the
*> input (the shadow model compares the chunk by floor division of each coordinate by 16 with its own arithmetic) and draws nothing; FR-PLACE-PF of the platform
*> placed feature builds the obsidian floor (5 x 5 at y 48) and the air box only while chunk (6, 0) is decorated.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-FIXED-PL.
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
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
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
 01 WS-X0 BINARY-LONG.
 01 WS-X1 BINARY-LONG.
 01 WS-Y0 BINARY-LONG.
 01 WS-Y1 BINARY-LONG.
 01 WS-Z0 BINARY-LONG.
 01 WS-Z1 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SH-X                BINARY-LONG.
 01 WS-SH-Z                BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG VALUE 0.
 01 WS-LIST.
    05 WS-L OCCURS 4 TIMES.
       10 WS-LX            BINARY-LONG.
       10 WS-LY            BINARY-LONG.
       10 WS-LZ            BINARY-LONG.
 01 WS-OUT.
    05 WS-O OCCURS 4096 TIMES.
       10 WS-OX            BINARY-LONG.
       10 WS-OY            BINARY-LONG.
       10 WS-OZ            BINARY-LONG.
 01 WS-EXPOUT.
    05 WS-E OCCURS 4 TIMES.
       10 WS-EX            BINARY-LONG.
       10 WS-EY            BINARY-LONG.
       10 WS-EZ            BINARY-LONG.
 01 WS-S-ENDSTONE          BINARY-LONG.
 01 WS-S-OBS               BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG VALUE 0.
 01 WS-N-OBS               BINARY-LONG.
 01 WS-N-AIR               BINARY-LONG.
 01 WS-N-OTHER             BINARY-LONG.
 01 WS-CASETXT            PIC 9.
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
     MOVE "end_stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-ENDSTONE
     MOVE "obsidian" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-OBS

*>   compile: status 1, 2, 2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:pl_fixed" TO WS-PFKEY
                 MOVE 1 TO WS-EXP
                 MOVE "four listed positions" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:pl_one" TO WS-PFKEY
                 MOVE 1 TO WS-EXP
                 MOVE "the single position of end_platform" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:pl_fixed_bad" TO WS-PFKEY
                 MOVE 2 TO WS-EXP
                 MOVE "a string coordinate (unsupported)" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:pl_fixed_many" TO WS-PFKEY
                 MOVE 2 TO WS-EXP
                 MOVE "five positions (unsupported)" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-PF" USING WS-PFKEY WS-PF
         CALL "FD-ENSURE-PF" USING WS-PF
         MOVE SPACES TO WS-CASE
         STRING "35-1§7.18: " FUNCTION TRIM(WS-NAME) " compiles to its status" DELIMITED BY SIZE INTO WS-CASE
         MOVE PF-STATUS(WS-PF) TO WS-OBS
         PERFORM ASSERT-N
     END-PERFORM

*>   the shadow model: the listed positions in the chunk of the input
     MOVE 100 TO WS-LX(1)
     MOVE 49 TO WS-LY(1)
     MOVE 0 TO WS-LZ(1)
     MOVE 101 TO WS-LX(2)
     MOVE 10 TO WS-LY(2)
     MOVE -1 TO WS-LZ(2)
     MOVE 20 TO WS-LX(3)
     MOVE 5 TO WS-LY(3)
     MOVE 5 TO WS-LZ(3)
     MOVE 96 TO WS-LX(4)
     MOVE 7 TO WS-LY(4)
     MOVE 15 TO WS-LZ(4)
     MOVE "minecraft:pl_fixed" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-N
     MOVE 99 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 7
         PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 2
             PERFORM 3 TIMES
                 MOVE 16 TO WS-DRAW
                 CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-R
                 COMPUTE WS-X = WS-CX * 16 + WS-R
                 CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-R
                 COMPUTE WS-Z = WS-CZ * 16 + WS-R
                 MOVE 256 TO WS-DRAW
                 CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-Y
*>               the shadow list
                 MOVE 0 TO WS-CNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                     PERFORM FLOOR-OF-LIST
                     IF WS-SH-X = WS-CX AND WS-SH-Z = WS-CZ
                         ADD 1 TO WS-CNT
                         MOVE WS-L(WS-I) TO WS-E(WS-CNT)
                     END-IF
                 END-PERFORM
                 CALL "FR-MODIFY" USING XR-STATE PF-MD-FIRST(WS-PF) WS-TOP WS-X WS-Y WS-Z WS-RESULT WS-OUT
                 IF WS-RESULT NOT = WS-CNT
                     ADD 1 TO WS-BAD
                 ELSE
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
                         IF WS-O(WS-I) NOT = WS-E(WS-I)
                             ADD 1 TO WS-BAD
                         END-IF
                     END-PERFORM
                 END-IF
                 ADD WS-CNT TO WS-N
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-1§7.18: every input over the window emits the listed positions of its chunk in list order" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
*>   chunk (6,0) holds positions 1 and 4, (6,-1) holds 2, (1,0) holds 3: 90 inputs * ... 3 draws per chunk: 4 positions emitted in 3 draws of each of the 4 chunks
     MOVE "35-1§7.18: the total emitted is 3 per chunk that holds a position, 2 positions chunk counted twice" TO WS-CASE
     MOVE WS-N TO WS-OBS
     MOVE 12 TO WS-EXP
     PERFORM ASSERT-N
*>   no draw: the random state after the run equals a fresh stream that made the same number of own draws (the 3 draws per input above are the test's)
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 6 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 100 TO WS-X
     MOVE 49 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "FR-MODIFY" USING XR-STATE PF-MD-FIRST(WS-PF) WS-TOP WS-X WS-Y WS-Z WS-RESULT WS-OUT
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-EXP
     MOVE "35-1§7.18: fixed_placement draws nothing" TO WS-CASE
     PERFORM ASSERT-N

*>   the platform placed feature of the End: built by chunk (6, 0) only
     MOVE "minecraft:pl_one" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1
                 MOVE 6 TO WS-CX
                 MOVE 0 TO WS-CZ
             WHEN 2
                 MOVE 6 TO WS-CX
                 MOVE 1 TO WS-CZ
             WHEN OTHER
                 MOVE 5 TO WS-CX
                 MOVE 0 TO WS-CZ
         END-EVALUATE
         PERFORM NEW-WORLD
         COMPUTE WS-X = WS-CX * 16
         MOVE 0 TO WS-Y
         COMPUTE WS-Z = WS-CZ * 16
         CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
         MOVE 0 TO WS-N-OBS WS-N-AIR WS-N-OTHER
         COMPUTE WS-SH-X = WS-CX * 16
         COMPUTE WS-SH-Z = WS-CZ * 16
         PERFORM VARYING WS-QX FROM WS-SH-X BY 1 UNTIL WS-QX > WS-SH-X + 15
             PERFORM VARYING WS-QZ FROM WS-SH-Z BY 1 UNTIL WS-QZ > WS-SH-Z + 15
                 PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 80
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     EVALUATE TRUE
                         WHEN WS-STATE = WS-S-OBS
                             ADD 1 TO WS-N-OBS
                             IF WS-QY NOT = 48 OR WS-QX < 98 OR WS-QX > 102 OR WS-QZ < -2 OR WS-QZ > 2
                                 ADD 1 TO WS-N-OTHER
                             END-IF
                         WHEN WS-STATE = WS-S-AIR AND WS-QY >= 49 AND WS-QY <= 51
                              AND WS-QX >= 98 AND WS-QX <= 102 AND WS-QZ >= -2 AND WS-QZ <= 2
                             ADD 1 TO WS-N-AIR
                     END-EVALUATE
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE WS-I TO WS-CASETXT
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.2: platform decorated from chunk case " WS-CASETXT " obsidian cells" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-OBS TO WS-OBS
         IF WS-I = 1
             MOVE 15 TO WS-EXP
         ELSE
             MOVE 0 TO WS-EXP
         END-IF
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.2: platform decorated from chunk case " WS-CASETXT " obsidian only on the floor" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-OTHER TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.2: platform decorated from chunk case " WS-CASETXT " air cells" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-N-AIR TO WS-OBS
         IF WS-I = 1
             MOVE 45 TO WS-EXP
         ELSE
             MOVE 0 TO WS-EXP
         END-IF
         PERFORM ASSERT-N
     END-PERFORM
     STOP RUN
     .
*> the chunk of listed position WS-I by floor division, written without FUNCTION INTEGER: x - (x mod 16 in 0..15) over 16
 FLOOR-OF-LIST.
     MOVE 0 TO WS-QY
     MOVE WS-LX(WS-I) TO WS-QX
     PERFORM UNTIL WS-QX >= 0 AND WS-QX < 16
         IF WS-QX < 0
             ADD 16 TO WS-QX
             SUBTRACT 1 FROM WS-QY
         ELSE
             SUBTRACT 16 FROM WS-QX
             ADD 1 TO WS-QY
         END-IF
     END-PERFORM
     MOVE WS-QY TO WS-SH-X
     MOVE 0 TO WS-QY
     MOVE WS-LZ(WS-I) TO WS-QZ
     PERFORM UNTIL WS-QZ >= 0 AND WS-QZ < 16
         IF WS-QZ < 0
             ADD 16 TO WS-QZ
             SUBTRACT 1 FROM WS-QY
         ELSE
             SUBTRACT 16 FROM WS-QZ
             ADD 1 TO WS-QY
         END-IF
     END-PERFORM
     MOVE WS-QY TO WS-SH-Z
     .
*> NEW-WORLD: the chunk (WS-CX, WS-CZ) of the End level (min y 0, 256 high): end stone up to y 40, air above
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     COMPUTE WS-SH-X = WS-CX * 16
     COMPUTE WS-SH-Z = WS-CZ * 16
     PERFORM VARYING WS-QX FROM WS-SH-X BY 1 UNTIL WS-QX > WS-SH-X + 15
         PERFORM VARYING WS-QZ FROM WS-SH-Z BY 1 UNTIL WS-QZ > WS-SH-Z + 15
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 51
                 CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-ENDSTONE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-FIXED-PL.
 COPY CORETEST.
