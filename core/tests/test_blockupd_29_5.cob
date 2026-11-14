*> Test of 29 section 5, Random ticks (core/src/blockupd-29.cob; T0463): the section counts of LevelChunkSection (non-empty, randomly
*> ticking blocks, fluid, randomly ticking fluid: BR-COUNTS) that a chunk load establishes and every written state keeps
*> (the previous state decrements, the new one increments), the rule that a section is visited when a ticking count is above 0, and
*> the random tick call (the block's hook, then the fluid's). Randomly ticking blocks and fluids are rows of the hook rule table
*> (kinds 11, 12 and 13 of BUSTATE.cpy). Expected counts come from 29 section 5 and a count of the cells made here.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY BUSTATE.
 COPY BRCOUNT.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-NE                  BINARY-LONG.
 01 WS-TB                  BINARY-LONG.
 01 WS-FL                  BINARY-LONG.
 01 WS-TF                  BINARY-LONG.
 01 WS-VISIT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SUM-NE              BINARY-LONG.
 01 WS-SUM-TB              BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BRUTE-NE            BINARY-LONG.
 01 WS-BRUTE-TB            BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     COMPUTE WS-TOP = DM-MIN-Y(1) + DM-HEIGHT(1)
     COMPUTE WS-SECTIONS = DM-HEIGHT(1) / 16
     COMPUTE WS-Y = WS-TOP - 6
     COMPUTE WS-SEC = (WS-Y - DM-MIN-Y(1)) / 16
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     MOVE CR-LUCITE TO WS-L
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     CALL "BU-ENSURE"
     MOVE 11 TO WS-KIND
     MOVE WS-G TO WS-BLOCK
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: a loaded chunk's counts equal a count of its cells (every section: non-empty, "
         & "ticking blocks)" TO TL-CASE
     MOVE 4000 TO WS-X
     MOVE 5 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO WS-SUM-NE WS-SUM-TB WS-BRUTE-NE WS-BRUTE-TB
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
         ADD BR-NONEMPTY(WS-ROW, WS-S) TO WS-SUM-NE
         ADD BR-TICKING-BLOCKS(WS-ROW, WS-S) TO WS-SUM-TB
     END-PERFORM
     COMPUTE WS-I = WS-SECTIONS * 4096
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > WS-I
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-BRUTE-NE
             IF CB-S-BLOCK(CE-STATE(WS-CELL) + 1) = WS-G
                 ADD 1 TO WS-BRUTE-TB
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-SUM-NE TO WS-E1
     MOVE WS-SUM-TB TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-BRUTE-NE TO WS-E1
     MOVE WS-BRUTE-TB TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§5 Random ticks: that chunk really has ticking blocks, so the case above is not vacuous"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     IF WS-BRUTE-TB > 0 AND WS-BRUTE-NE > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE 5000 TO WS-X
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     MOVE "acceptance US12 29§5 Random ticks: writing a ticking block into air raises non-empty and ticking by 1" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     MOVE WS-NE TO WS-SUM-NE
     MOVE WS-TB TO WS-SUM-TB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     COMPUTE TL-OBSERVED-N = (WS-NE - WS-SUM-NE) * 10 + WS-TB - WS-SUM-TB
     MOVE 11 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: replacing it by a block that does not tick keeps non-empty and lowers ticking by 1"
         TO TL-CASE
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     MOVE WS-NE TO WS-SUM-NE
     MOVE WS-TB TO WS-SUM-TB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     COMPUTE TL-OBSERVED-N = (WS-NE - WS-SUM-NE) * 10 + WS-SUM-TB - WS-TB
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: writing air lowers non-empty by 1" TO TL-CASE
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     MOVE WS-NE TO WS-SUM-NE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     COMPUTE TL-OBSERVED-N = WS-SUM-NE - WS-NE
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: a block with a non-empty fluid counts in the fluid count, and in the ticking "
         & "fluid count when its fluid ticks" TO TL-CASE
     MOVE 12 TO WS-KIND
     MOVE WS-L TO WS-BLOCK
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     MOVE 13 TO WS-KIND
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     MOVE WS-FL TO WS-SUM-NE
     MOVE WS-TF TO WS-SUM-TB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     CALL "BR-GET" USING WS-DIM WS-CX WS-CZ WS-SEC WS-NE WS-TB WS-FL WS-TF
     COMPUTE TL-OBSERVED-N = (WS-FL - WS-SUM-NE) * 10 + WS-TF - WS-SUM-TB
     MOVE 11 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: a section with no ticking block or fluid is not visited, one with either is"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "BR-VISIT" USING WS-ROW WS-SEC WS-VISIT
     MOVE WS-VISIT TO TL-OBSERVED-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     CALL "BR-VISIT" USING WS-ROW WS-SEC WS-VISIT
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + WS-VISIT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     CALL "BR-VISIT" USING WS-ROW WS-SEC WS-VISIT
     COMPUTE TL-OBSERVED-N = TL-OBSERVED-N * 10 + WS-VISIT
     MOVE 11 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 29§5 Random ticks: the random tick calls the block's hook when the block ticks, then the fluid's "
         & "when the fluid ticks, and nothing for a state that does neither" TO TL-CASE
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-X WS-Y WS-Z
     MOVE 0 TO BU-TRACE-ON
     MOVE WS-GS TO WS-E1
     MOVE WS-LS TO WS-E2
     MOVE WS-X TO WS-E3
     MOVE WS-Y TO WS-E4
     STRING "G " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " 5 " FUNCTION TRIM(WS-E1) " 0 0;H "
         FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " 5 " FUNCTION TRIM(WS-E2) " 0 0;" DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BLOCKUPD-29-5.

 COPY CORETEST.
