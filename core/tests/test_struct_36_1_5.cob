*> Acceptance test of docs/protocol/36-structures-1 section 5 (creating starts): the per-chunk seed and the weighted choice with removal (the vectors of
*> 12.2), the biome check at the stub position in quart cells (floor division, so negative blocks go to negative cells), the gate table (empty by
*> default: no start is made), the starts of a chunk (a set holds at most one start per chunk, a failed attempt falls to the next entry, one entry set
*> tries it alone) over 48 x 48 chunks against an independent script, and the generation hook (a no-op without a structure gated on).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY CARVER.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SET                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-TEXT                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-NAME                PIC X(40).
 01 WS-ORDER.
    05 WS-ORDER-ENTRY      BINARY-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION.
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "T" TO TL-MODE

*>   the chooser (5.2 step 4 to 5, 12.2)
     MOVE 1 TO WS-SET
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM ORDER-TEXT
     MOVE "acceptance US12 36-1§5 Creating starts: weights 2 1 1, chunk (0,0), seed 0: the second entry is chosen first, then the first, then the third" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "2 1 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 42 TO WS-SEED
     MOVE 3 TO WS-CX
     MOVE -2 TO WS-CZ
     PERFORM ORDER-TEXT
     MOVE "acceptance US12 36-1§5 Creating starts: chunk (3,-2), seed 42: the first entry first (nextInt(4) is 0), then the third and the second" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 3 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-SEED
     MOVE -5 TO WS-CX
     MOVE 9 TO WS-CZ
     PERFORM ORDER-TEXT
     MOVE "acceptance US12 36-1§5 Creating starts: chunk (-5,9), seed 7 (the total drops by the weight of each removed entry)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 2 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-SET
     PERFORM ORDER-TEXT
     MOVE "acceptance US12 36-1§5 Creating starts: a set with one entry tries it alone (no draw)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the biome check at the stub (5.1, 5.3 step 2) in quart cells
     MOVE "N" TO TL-MODE
     MOVE -5 TO WS-X
     CALL "STRUCT-QUART" USING WS-X WS-Q
     MOVE "acceptance US12 36-1§5 Creating starts: quart cell of block -5 is -2 (shift right, floor)" TO TL-CASE
     MOVE WS-Q TO TL-OBSERVED-N
     MOVE -2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -4 TO WS-X
     CALL "STRUCT-QUART" USING WS-X WS-Q
     MOVE "acceptance US12 36-1§5 Creating starts: quart cell of block -4 is -1" TO TL-CASE
     MOVE WS-Q TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     CALL "STRUCT-QUART" USING WS-X WS-Q
     MOVE "acceptance US12 36-1§5 Creating starts: quart cell of block 7 is 1" TO TL-CASE
     MOVE WS-Q TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:plains" TO WS-NAME
     PERFORM ADD-POINT
     MOVE 3 TO WS-STRUCT
     MOVE -40 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 25 TO WS-Z
     CALL "STRUCT-VALID-AT" USING WS-STRUCT WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§5 Creating starts: a plains stub of a structure whose biomes list plains is valid" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-STRUCT
     CALL "STRUCT-VALID-AT" USING WS-STRUCT WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§5 Creating starts: the same stub for a structure whose biomes are forest only is not" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the gate (empty): no start in 48 x 48 chunks
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE 0 TO WS-SEED
     MOVE "acceptance US12 36-1§5 Creating starts: no structure is gated on after a load" TO TL-CASE
     MOVE SD-GATE-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-FLAG
     MOVE "acceptance US12 36-1§5 Creating starts: so s_one is off" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM START-AREA
     MOVE "acceptance US12 36-1§5 Creating starts: with every structure off no chunk of 48 x 48 starts anything" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   every plains structure on
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "minecraft:s_two" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "minecraft:s_three" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "acceptance US12 36-1§5 Creating starts: three structures on (switching one on twice adds it once)" TO TL-CASE
     MOVE SD-GATE-COUNT TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-GATE" USING WS-KEY WS-FLAG
     MOVE "acceptance US12 36-1§5 Creating starts: s_three is on" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM START-AREA
     MOVE "acceptance US12 36-1§5 Creating starts: chunks (0..47)^2, seed 0, all plains: the number of starts" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 24 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: and which structure of which set starts where (checksum)" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 3569959 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-SEED
     PERFORM START-AREA
     MOVE "acceptance US12 36-1§5 Creating starts: seed 5, the number of starts" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 18 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: seed 5 checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 3014038 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED
     MOVE 4 TO WS-CX
     MOVE 27 TO WS-CZ
     CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-COUNT
     MOVE "acceptance US12 36-1§5 Creating starts: chunk (4,27) starts two structures (sets 3 and 4, different sets are independent)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: the stub of the first is the chunk's middle (72, 440): set 3 s_two" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SC-SET(1) * 1000000000 + SC-STRUCT(1) * 100000000 + SC-X(1) * 10000 + SC-Z(1) - 500000000
     COMPUTE TL-EXPECTED-N = 3 * 1000000000 + 2 * 100000000 + 72 * 10000 + 440 - 500000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   only s_three on: an entry that is off fails and the next in the chooser's order is tried
     CALL "STRUCT-GATE-RESET"
     MOVE "minecraft:s_three" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     PERFORM START-AREA
     MOVE "acceptance US12 36-1§5 Creating starts: only s_three on: a failed attempt is removed and the next entry tried (number of starts)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 1633653 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a biome source of forest only: s_one is the only valid structure, the others fail the biome check of the stub
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "minecraft:s_two" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:forest" TO WS-NAME
     PERFORM ADD-POINT
     CALL "STRUCT-POSSIBLE-BUILD"
     PERFORM START-AREA
     MOVE "acceptance US12 36-1§5 Creating starts: forest only: the stub's biome check rejects the attempts of the plains structures (number of starts)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 1150787 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the hook of the generation pipeline
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:plains" TO WS-NAME
     PERFORM ADD-POINT
     MOVE 0 TO CV-SEED
     INITIALIZE WS-JOB
     MOVE 19 TO J-CX
     MOVE 16 TO J-CZ
     MOVE 0 TO J-SUB
     CALL "STRUCT-GATE-RESET"
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE 0 TO SD-STARTS-SEEN
     CALL "STRUCT-STAGE-HOOK" USING WS-JOB
     MOVE "acceptance US12 36-1§5 Creating starts: the hook does nothing while no structure is gated on (chunk (19,16) is a structure chunk)" TO TL-CASE
     MOVE SD-STARTS-SEEN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5 Creating starts: and builds nothing (the possible sets are not built)" TO TL-CASE
     MOVE SD-POSS-DONE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE 3 TO J-SUB
     CALL "STRUCT-STAGE-HOOK" USING WS-JOB
     MOVE "acceptance US12 36-1§5 Creating starts: with a structure on the hook acts on the first step of the chunk only (step 3: nothing)" TO TL-CASE
     MOVE SD-STARTS-SEEN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO J-SUB
     CALL "STRUCT-STAGE-HOOK" USING WS-JOB
     MOVE "acceptance US12 36-1§5 Creating starts: step 0 makes the chunk's starts (one: set alpha, s_one) after building the possible sets" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SD-STARTS-SEEN * 10 + SD-POSS-DONE
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-STAGE-HOOK" USING WS-JOB
     MOVE "acceptance US12 36-1§5 Creating starts: the second run counts again and does not rebuild" TO TL-CASE
     MOVE SD-STARTS-SEEN TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ORDER-TEXT.
     CALL "STRUCT-ENTRY-ORDER" USING WS-SET WS-SEED WS-CX WS-CZ WS-ORDER WS-N
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-ORDER-ENTRY(WS-I) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM.
 START-AREA.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 47
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 47
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-TOTAL
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + (WS-CX * 64 + WS-CZ) * 100 + SC-SET(WS-I) * 10 + SC-STRUCT(WS-I)
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 ADD-POINT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
