*> Test of the flight of the eye of ender against the worked examples of docs/protocol/57-client-closures-2 section 2.6: the eye starts at (0, 65.6, 0) at rest;
*> a structure at (100, 0, 0) is farther than 12 blocks so the target is (12, 73.6, 0) (table of ticks 1, 2, 10, 20, 40, 60 and 81: at the 81st tick the eye is gone and its drop, an ender_eye item at the position of that tick, shows it; the velocity at 81 is not observable), a structure at (5, 0, 0) is the target itself
*> (ticks 1, 20, 40 and 81: the eye dives toward y 0). Positions and velocities are compared to four places. The ring table of the same document (section 2.2: 128 positions in
*> eight rings of 3, 6, 10, 15, 21, 28, 36 and 9, the radius of ring r in chunks 128 + 192 r plus or minus 40, the angle step 2 pi / S inside a ring) is checked on the raw ring
*> positions of STRUCT-RINGS-RAW for the seeds 0, 12345 and 987654321, and the ring seed (STRUCT-RING-SEED: the world seed, 0 in a superflat world).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EYE-RINGS-57-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROWS-TABLE.
    05 FILLER              PIC X(60) VALUE "F 1 0 656000 300 150".
    05 FILLER              PIC X(60) VALUE "F 2 300 656150 599 298".
    05 FILLER              PIC X(60) VALUE "F 10 13166 662487 2845 1403".
    05 FILLER              PIC X(60) VALUE "F 20 51876 682091 4932 2609".
    05 FILLER              PIC X(60) VALUE "F 40 120529 732626 -614 979".
    05 FILLER              PIC X(60) VALUE "F 60 119993 735345 7 402".
    05 FILLER              PIC X(60) VALUE "F 81 120000 736750 0 -345".
    05 FILLER              PIC X(60) VALUE "N 1 0 656000 125 -150".
    05 FILLER              PIC X(60) VALUE "N 20 21615 629909 NONE NONE".
    05 FILLER              PIC X(60) VALUE "N 40 50163 585340 NONE NONE".
    05 FILLER              PIC X(60) VALUE "N 81 50000 555589 NONE NONE".
 01 WS-ROWS REDEFINES WS-ROWS-TABLE.
    05 WS-ROW-TEXT         PIC X(60) OCCURS 11 TIMES.
 01 WS-KIND                PIC X.
 01 WS-TICK-TEXT           PIC X(8).
 01 WS-X-TEXT              PIC X(12).
 01 WS-Y-TEXT              PIC X(12).
 01 WS-VX-TEXT             PIC X(12).
 01 WS-VY-TEXT             PIC X(12).
 01 WS-TICK                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SX                  FLOAT-LONG VALUE 0.
 01 WS-SY                  FLOAT-LONG VALUE 65.6.
 01 WS-SZ                  FLOAT-LONG VALUE 0.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG VALUE 0.
 01 WS-TZ                  FLOAT-LONG VALUE 0.
 01 WS-SURVIVE             BINARY-LONG VALUE 1.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-DISTANCE            BINARY-LONG VALUE 32.
 01 WS-SPREAD              BINARY-LONG VALUE 3.
 01 WS-NUM                 BINARY-LONG VALUE 128.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-RAW.
    05 WS-RAW-ROW OCCURS 256 TIMES.
       10 WS-RAW-X         BINARY-LONG.
       10 WS-RAW-Z         BINARY-LONG.
       10 WS-RAW-FORK      BINARY-DOUBLE UNSIGNED.
 01 WS-SIZE-TABLE.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 15.
    05 FILLER              BINARY-LONG VALUE 21.
    05 FILLER              BINARY-LONG VALUE 28.
    05 FILLER              BINARY-LONG VALUE 36.
    05 FILLER              BINARY-LONG VALUE 9.
 01 WS-SIZES REDEFINES WS-SIZE-TABLE.
    05 WS-SIZE             BINARY-LONG OCCURS 8 TIMES.
 01 WS-RING                BINARY-LONG.
 01 WS-IN-RING             BINARY-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-WANT-COS            FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-TWO-PI              FLOAT-LONG.
 01 WS-GOOD-RADIUS         BINARY-LONG.
 01 WS-GOOD-STEP           BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-SEED-IN             BINARY-DOUBLE.
 01 WS-SEED-OUT            BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         UNSTRING WS-ROW-TEXT(WS-I) DELIMITED BY SPACE INTO WS-KIND WS-TICK-TEXT WS-X-TEXT WS-Y-TEXT WS-VX-TEXT WS-VY-TEXT
         IF WS-KIND = "F" AND WS-TICK-TEXT = "1"
             MOVE 100 TO WS-TX
             PERFORM START-EYE
         END-IF
         IF WS-KIND = "N" AND WS-TICK-TEXT = "1"
             MOVE 5 TO WS-TX
             PERFORM START-EYE
         END-IF
         COMPUTE WS-WANT = FUNCTION NUMVAL(WS-TICK-TEXT)
         PERFORM UNTIL WS-TICK >= WS-WANT
             CALL "EYE-STEP" USING WS-ROW
             ADD 1 TO WS-TICK
         END-PERFORM
*>       The 81st tick removes the eye: it drops (4 in 5) as an item at the position of that tick (the eye's own row is cleared then).
         MOVE WS-ROW TO WS-SHOWN
         IF WS-WANT = 81
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
                 IF EN-USED(WS-N) = 1 AND EN-ITEM-COUNT(WS-N) > 0
                     MOVE WS-N TO WS-SHOWN
                 END-IF
             END-PERFORM
         END-IF
         MOVE SPACES TO TL-CASE TL-OBSERVED TL-EXPECTED
         STRING "test eye 57-2 2.6 " WS-KIND " after tick " FUNCTION TRIM(WS-TICK-TEXT) " the position (x, y, 1/10000) is "
             FUNCTION TRIM(WS-X-TEXT) " " FUNCTION TRIM(WS-Y-TEXT) DELIMITED BY SIZE INTO TL-CASE
         COMPUTE WS-E1 ROUNDED = (EN-X(WS-SHOWN) - WS-SX) * 10000
         COMPUTE WS-E2 ROUNDED = EN-Y(WS-SHOWN) * 10000
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
         STRING FUNCTION TRIM(WS-X-TEXT) " " FUNCTION TRIM(WS-Y-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-VX-TEXT NOT = "NONE" AND WS-WANT < 81
             MOVE SPACES TO TL-CASE TL-OBSERVED TL-EXPECTED
             STRING "test eye 57-2 2.6 " WS-KIND " after tick " FUNCTION TRIM(WS-TICK-TEXT) " the velocity (x, y, 1/10000) is "
                 FUNCTION TRIM(WS-VX-TEXT) " " FUNCTION TRIM(WS-VY-TEXT) DELIMITED BY SIZE INTO TL-CASE
             COMPUTE WS-E1 ROUNDED = EN-VX(WS-ROW) * 10000
             COMPUTE WS-E2 ROUNDED = EN-VY(WS-ROW) * 10000
             STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
             STRING FUNCTION TRIM(WS-VX-TEXT) " " FUNCTION TRIM(WS-VY-TEXT) DELIMITED BY SIZE INTO TL-EXPECTED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM

*>   The ring table of 2.2 on the raw positions of three seeds.
     COMPUTE WS-TWO-PI = 2 * FUNCTION PI
     MOVE 0 TO WS-USEED
     PERFORM RING-CASES
     MOVE 12345 TO WS-USEED
     PERFORM RING-CASES
     MOVE 987654321 TO WS-USEED
     PERFORM RING-CASES

*>   The ring seed: the world seed, 0 in a superflat world.
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE 12345 TO WS-SEED-IN
     CALL "STRUCT-RING-SEED" USING WS-SEED-IN WS-SEED-OUT
     MOVE "N" TO TL-MODE
     MOVE "test eye 57-2 2.3 the ring seed of a standard world is its world seed" TO TL-CASE
     MOVE 12345 TO TL-EXPECTED-N
     MOVE WS-SEED-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "superflat" TO CW-WORLD-TYPE
     CALL "STRUCT-RING-SEED" USING WS-SEED-IN WS-SEED-OUT
     MOVE "test eye 57-2 2.3 the ring seed of a superflat world is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEED-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-EYE.
     MOVE 0 TO WS-TICK
     MOVE 0 TO WS-TY
     CALL "EYE-SPAWN" USING WS-DIM WS-SX WS-SY WS-SZ WS-TX WS-TY WS-TZ WS-SURVIVE WS-OWNER WS-ROW.

 RING-CASES.
     CALL "STRUCT-RINGS-RAW" USING WS-DISTANCE WS-SPREAD WS-NUM WS-USEED WS-RAW
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-RING FROM 1 BY 1 UNTIL WS-RING > 8
         MOVE 0 TO WS-GOOD-RADIUS WS-GOOD-STEP
         COMPUTE WS-BASE = 128 + 192 * (WS-RING - 1)
         PERFORM VARYING WS-IN-RING FROM 1 BY 1 UNTIL WS-IN-RING > WS-SIZE(WS-RING)
             COMPUTE WS-R1 = FUNCTION SQRT(WS-RAW-X(WS-POS) * WS-RAW-X(WS-POS) + WS-RAW-Z(WS-POS) * WS-RAW-Z(WS-POS))
             IF WS-R1 >= WS-BASE - 41 AND WS-R1 <= WS-BASE + 41
                 ADD 1 TO WS-GOOD-RADIUS
             END-IF
*>           the step from the previous position of the ring: cos and sin of the angle between them (the ring of 9 is cut from 10: its step is 2 pi / 10)
             IF WS-IN-RING = 1
                 ADD 1 TO WS-GOOD-STEP
             ELSE
                 COMPUTE WS-R2 = FUNCTION SQRT(WS-RAW-X(WS-POS - 1) * WS-RAW-X(WS-POS - 1) + WS-RAW-Z(WS-POS - 1) * WS-RAW-Z(WS-POS - 1))
                 COMPUTE WS-COS = (WS-RAW-X(WS-POS - 1) * WS-RAW-X(WS-POS) + WS-RAW-Z(WS-POS - 1) * WS-RAW-Z(WS-POS)) / (WS-R1 * WS-R2)
                 COMPUTE WS-SIN = (WS-RAW-X(WS-POS - 1) * WS-RAW-Z(WS-POS) - WS-RAW-Z(WS-POS - 1) * WS-RAW-X(WS-POS)) / (WS-R1 * WS-R2)
                 IF WS-RING = 8
                     COMPUTE WS-STEP = WS-TWO-PI / 10
                 ELSE
                     COMPUTE WS-STEP = WS-TWO-PI / WS-SIZE(WS-RING)
                 END-IF
                 COMPUTE WS-WANT-COS = FUNCTION COS(WS-STEP)
                 IF FUNCTION ABS(WS-COS - WS-WANT-COS) < 0.02 AND WS-SIN > 0
                     ADD 1 TO WS-GOOD-STEP
                 END-IF
             END-IF
             ADD 1 TO WS-POS
         END-PERFORM
         MOVE WS-RING TO WS-E1
         MOVE WS-USEED TO WS-E4
         MOVE SPACES TO TL-CASE TL-OBSERVED TL-EXPECTED
         STRING "test eye 57-2 2.2 seed " FUNCTION TRIM(WS-E4) " ring " FUNCTION TRIM(WS-E1) " has its positions within the radius range and the angle step"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-GOOD-RADIUS TO WS-E2
         MOVE WS-GOOD-STEP TO WS-E3
         STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
         MOVE WS-SIZE(WS-RING) TO WS-E2
         STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.
 END PROGRAM TEST-EYE-RINGS-57-2.

 COPY CORETEST.
 COPY MOBSPTEST.
