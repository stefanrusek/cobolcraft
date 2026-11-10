*> Implementation test of the core's block lookups (T0325; content-api section 2, 24 part 1 section 2): world,
*> blocks and worldgen code resolves block states only through the content set. BLOCKS-OPEN builds CBLOCKS.cpy
*> from CONTENT-BLOCK-OF-STATE rows, tags and flags for either set; BLOCKS-ID-OF and BLOCKS-STATE-OF turn keys and
*> property pairs into ids; BLOCKS-STATE-PROPS renders a state's properties. The cobolcraft set is opened here
*> (the fixture trees hold no data that opens as a standard set). The last cases assert that no program of
*> core/src names a stand-in table or constant (ST-, BLK-, SB-, BL- identifiers of BLOCKS.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(64).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-B                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 01 WS-LEN                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     MOVE "N" TO TL-MODE
     MOVE "test block lookup the tables hold 13 blocks and 19 states of the built-in layer" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 13 * 100 + 19
     COMPUTE TL-OBSERVED-N = CB-BLOCK-COUNT * 100 + CB-STATE-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   One row per block: key first-state states default solid opaque light break-ms class.
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 13
         MOVE CB-KEY-LENGTH(WS-B) TO WS-LEN
         MOVE CB-FIRST-STATE(WS-B) TO WS-E1
         MOVE CB-STATES(WS-B) TO WS-E2
         MOVE CB-DEFAULT-STATE(WS-B) TO WS-E3
         MOVE CB-SOLID(WS-B) TO WS-E4
         MOVE CB-OPAQUE(WS-B) TO WS-E5
         MOVE CB-LIGHT(WS-B) TO WS-E6
         MOVE CB-BREAK-MS(WS-B) TO WS-E7
         MOVE SPACES TO TL-OBSERVED
         STRING CB-KEY(WS-B)(1:WS-LEN) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " "
             FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " "
             FUNCTION TRIM(WS-E6) " " FUNCTION TRIM(WS-E7) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE CB-CLASS(WS-B) TO WS-E1
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE "T" TO TL-MODE
         EVALUATE WS-B
             WHEN 1  MOVE "cobolcraft:void 0 1 0 0 0 0 0 0" TO TL-EXPECTED
             WHEN 2  MOVE "cobolcraft:baseplate 1 1 1 1 1 0 -1 0" TO TL-EXPECTED
             WHEN 3  MOVE "cobolcraft:greystone 2 1 2 1 1 0 1500 1" TO TL-EXPECTED
             WHEN 4  MOVE "cobolcraft:loam 3 1 3 1 1 0 500 2" TO TL-EXPECTED
             WHEN 5  MOVE "cobolcraft:turf 4 1 4 1 1 0 600 2" TO TL-EXPECTED
             WHEN 6  MOVE "cobolcraft:grit 5 1 5 1 1 0 500 2" TO TL-EXPECTED
             WHEN 7  MOVE "cobolcraft:cardstack 6 6 9 1 1 0 700 1" TO TL-EXPECTED
             WHEN 8  MOVE "cobolcraft:lucite 12 1 12 1 0 0 300 0" TO TL-EXPECTED
             WHEN 9  MOVE "cobolcraft:glowtube 13 2 13 1 1 15 200 0" TO TL-EXPECTED
             WHEN 10 MOVE "cobolcraft:ledger_tile 15 1 15 1 1 0 800 1" TO TL-EXPECTED
             WHEN 11 MOVE "cobolcraft:goto_pad 16 1 16 1 1 6 1300 0" TO TL-EXPECTED
             WHEN 12 MOVE "cobolcraft:slag 17 1 17 1 1 0 400 1" TO TL-EXPECTED
             WHEN OTHER MOVE "cobolcraft:crafting_bench 18 1 18 1 1 0 800 1" TO TL-EXPECTED
         END-EVALUATE
         MOVE SPACES TO TL-CASE
         MOVE WS-B TO WS-E2
         STRING "test block lookup block row " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

     MOVE "test block lookup state light: lit glowtube 15, unlit 0, goto_pad 6, greystone 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CB-S-LIGHT(14) TO WS-E1
     MOVE CB-S-LIGHT(15) TO WS-E2
     MOVE CB-S-LIGHT(17) TO WS-E3
     MOVE CB-S-LIGHT(3) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "15 0 6 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test block lookup state to block: state 10 is the cardstack, state 18 the bench" TO TL-CASE
     MOVE CB-S-BLOCK(10) TO WS-E1
     MOVE CB-S-BLOCK(19) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "6 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test block lookup BLOCKS-ID-OF finds a key; an unknown key is -1" TO TL-CASE
     MOVE "cobolcraft:goto_pad" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE WS-ID TO WS-E1
     MOVE "cobolcraft:nothing" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID
     MOVE WS-ID TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "10 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test block lookup BLOCKS-STATE-OF: default, by properties, unknown key" TO TL-CASE
     MOVE SPACES TO WS-PAIRS
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE "cobolcraft:cardstack" TO WS-KEY
     MOVE "axis=y,punched=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E2
     MOVE "axis=z,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E3
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E4
     MOVE "cobolcraft:glowtube" TO WS-KEY
     MOVE "lit=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E5
     MOVE "cobolcraft:nothing" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-STATE TO WS-E6
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         " " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 8 11 9 14 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test block lookup BLOCKS-STATE-PROPS renders name=value pairs in list order" TO TL-CASE
     MOVE 8 TO WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     MOVE 2 TO WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) "|" FUNCTION TRIM(WS-TEXT) "|" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "axis=y,punched=true||" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The biomes of the set (BIOMES-OPEN): key and has_precipitation of each biome id.
     MOVE "T" TO TL-MODE
     MOVE "test block lookup the biome table holds the three biomes with their precipitation" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE CBI-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CBI-COUNT
         MOVE CBI-KEY-LENGTH(WS-B) TO WS-LEN
         MOVE CBI-PRECIPITATION(WS-B) TO WS-E2
         STRING FUNCTION TRIM(TL-OBSERVED) " " CBI-KEY(WS-B)(1:WS-LEN) "=" FUNCTION TRIM(WS-E2)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "3 minecraft:plains=1 cobolcraft:upland=1 cobolcraft:ash_flats=0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No stand-in identifier of BLOCKS.cpy in any program of core/src (comment lines excluded).
     MOVE SPACES TO WS-COMMAND
     STRING "! grep -v '^ *[*]>' core/src/*.cob | grep -qE '(^|[^A-Z-])(ST|BLK|SB|BL)-[A-Z]'"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "N" TO TL-MODE
     MOVE "test block lookup no program of core/src names a stand-in table or block constant" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RETURN-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BLOCK-LOOKUP.
