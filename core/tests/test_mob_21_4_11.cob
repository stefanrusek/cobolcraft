*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 section 4.11 with 3.2): the depth rules of the water mobs' spawn predicates. In a water column from sea level - 20 to sea level + 3:
*> cod, salmon, pufferfish, squid, dolphin and tropical fish pass from sea level - 13 to sea level (water below and above); the nautilus from sea level - 25 to sea level - 5; the glow squid at
*> sea level - 33 and below with brightness 0. Guardian, drowned and axolotl: tests 21 4 8, 4 9 and 4 7. The biomes of tag allows_tropical_fish_spawns_at_any_height are not listed in the docs
*> (missing doc section), so the tropical fish's any-height clause is not covered.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY DIMENSIONS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-SEA                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REASON              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 3.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "cod".
    05 FILLER PIC X(24) VALUE "salmon".
    05 FILLER PIC X(24) VALUE "pufferfish".
    05 FILLER PIC X(24) VALUE "squid".
    05 FILLER PIC X(24) VALUE "dolphin".
    05 FILLER PIC X(24) VALUE "tropical_fish".
    05 FILLER PIC X(24) VALUE "nautilus".
    05 FILLER PIC X(24) VALUE "glow_squid".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-SPECIES          PIC X(24) OCCURS 8 TIMES.
 01 WS-S                   BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-TEXT                PIC X(240).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE DM-SEA-LEVEL(WS-DIM) TO WS-SEA
     COMPUTE WS-BX = WS-X0 + 4
     COMPUTE WS-BZ = WS-Z0 + 14
     COMPUTE WS-CELL = WS-SEA - 40
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-STONE
     PERFORM VARYING WS-CELL FROM WS-SEA BY -1 UNTIL WS-CELL < WS-SEA - 39
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-WATER
     END-PERFORM
     PERFORM VARYING WS-CELL FROM WS-SEA BY 1 UNTIL WS-CELL > WS-SEA + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-WATER
     END-PERFORM
     CALL "XORO-SEED" USING WS-SEED XR-STATE
*>   Each species: the first and last y that pass, found by scanning the column from sea level - 36 to sea level + 2.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 7
         MOVE 0 TO WS-M
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
             IF SM-KEY(WS-I) = WS-SPECIES(WS-S)
                 MOVE WS-I TO WS-M
             END-IF
         END-PERFORM
         MOVE 9999 TO WS-LOW
         MOVE -9999 TO WS-HIGH
         IF WS-M > 0
             PERFORM VARYING WS-BY FROM WS-SEA BY -1 UNTIL WS-BY < WS-SEA - 36
                 CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
                 IF WS-OK = 1
                     COMPUTE WS-DEPTH = WS-SEA - WS-BY
                     COMPUTE WS-LOW = FUNCTION MIN(WS-LOW, WS-DEPTH)
                     COMPUTE WS-HIGH = FUNCTION MAX(WS-HIGH, WS-DEPTH)
                 END-IF
             END-PERFORM
             COMPUTE WS-BY = WS-SEA + 1
             CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
             IF WS-OK = 1
                 MOVE -1 TO WS-LOW
             END-IF
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§4.11 " DELIMITED BY SIZE FUNCTION TRIM(WS-SPECIES(WS-S)) DELIMITED BY SIZE " passes from the depth (below sea level) of the first number to the second"
             DELIMITED BY SIZE INTO TL-CASE
         EVALUATE WS-S
             WHEN 7
*>               nautilus: sea level - 25 to sea level - 5, that is depth 5 to 25
                 COMPUTE TL-EXPECTED-N = 5 * 100 + 25
             WHEN OTHER
*>               the surface band: sea level - 13 to sea level, depth 0 to 13
                 COMPUTE TL-EXPECTED-N = 0 * 100 + 13
         END-EVALUATE
         COMPUTE TL-OBSERVED-N = WS-LOW * 100 + WS-HIGH
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The glow squid: a sealed dark column (stone at sea level - 35 and - 30, water between): sea level - 34 and - 33 pass, sea level - 32 is too high.
     COMPUTE WS-BZ = WS-Z0 + 17
     COMPUTE WS-CELL = WS-SEA - 35
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-STONE
     COMPUTE WS-CELL = WS-SEA - 30
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-STONE
     COMPUTE WS-LOW = WS-SEA - 34
     PERFORM VARYING WS-CELL FROM WS-LOW BY 1 UNTIL WS-CELL > WS-SEA - 31
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CELL WS-BZ WS-WATER
     END-PERFORM
     MOVE 0 TO WS-M
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
         IF SM-KEY(WS-I) = "glow_squid"
             MOVE WS-I TO WS-M
         END-IF
     END-PERFORM
     COMPUTE WS-BY = WS-SEA - 34
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§4.11 glow squid: sea level - 34, dark, passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-SEA - 33
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§4.11 glow squid: sea level - 33, dark, passes" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BY = WS-SEA - 32
     CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-M WS-BX WS-BY WS-BZ WS-REASON WS-OK
     MOVE "acceptance US15 21§4.11 glow squid: sea level - 32 is above the limit: fails" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-21-4-11.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
