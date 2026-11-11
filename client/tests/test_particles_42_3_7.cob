*> Acceptance test of docs/protocol/42-particles-3-fluid-drip-water.md section 7 (squid ink):
*> the constructor draws, tick, size and light formulas and worked cases of the section, with the document's
*> tick, size and light formulas, and the worked examples E1 to E12 that apply. The case lines are written
*> by a script that applies the document's numbers; the expected values are the document's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-3-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLP3X.
 COPY CLP2X.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-VX2                 FLOAT-LONG.
 01 WS-VY2                 FLOAT-LONG.
 01 WS-VZ2                 FLOAT-LONG.
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EDRAWS.
    05 WS-E                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-D36S.
    05 WS-D36              FLOAT-LONG OCCURS 36 TIMES.
 01 WS-NOISES.
    05 WS-NOISE            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-VAL                 FLOAT-LONG.
 01 WS-CHK                 FLOAT-LONG.
 01 WS-VAL2                FLOAT-LONG.
 01 WS-VAL3                FLOAT-LONG VALUE 0.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PYD                 FLOAT-LONG.
 01 WS-SCALE               BINARY-DOUBLE.
 01 WS-ZERO-N              BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FLAG                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-LIFE                BINARY-LONG.
 01 WS-LIFEC               BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-ERR                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FIRED               BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-SHAPE-NAME          PIC X(12).
 01 WS-SPAWN               BINARY-LONG.
 01 WS-ARGB                BINARY-DOUBLE.
 01 WS-AIR                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO PK-COUNT
     MOVE 0 TO PX-HAS-FADE
     MOVE 0 TO PK-COUNT
     MOVE 10 TO WS-X
     MOVE 20 TO WS-Y
     MOVE 30 TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0.5 TO WS-D(WS-I)
         MOVE 0.5 TO WS-E(WS-I)
     END-PERFORM
     MOVE 0 TO WS-VX
     MOVE 0.1 TO WS-VY
     MOVE 0 TO WS-VZ
     MOVE 0 TO WS-KIND
     CALL "P3-INK-ARGB" USING WS-KIND WS-ARGB
     MOVE "7 squid_ink: argb is opaque black 0xFF000000" TO WS-NAME
     MOVE 4278190080 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ARGB
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-KIND
     CALL "P3-INK-ARGB" USING WS-KIND WS-ARGB
     MOVE "7 glow_squid_ink: argb (255, 51, 204, 153)" TO WS-NAME
     MOVE 4281584793 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ARGB
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-KIND
     CALL "P3-INK-ARGB" USING WS-KIND WS-ARGB
     CALL "P3-INK-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ARGB WS-DRAWS
     MOVE "7 squid_ink: colour black (sum)" TO WS-NAME
     COMPUTE WS-CHK = PC-RCOL + PC-GCOL + PC-BCOL
     MOVE 1000 TO WS-SCALE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 squid_ink: friction 0.92, quadSize 0.5, alpha 1 (thousandths of the sum)" TO WS-NAME
     COMPUTE WS-CHK = PC-FRICTION + PC-QUAD-SIZE + PC-ALPHA
     MOVE 1000 TO WS-SCALE
     MOVE 2420 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 squid_ink: lifetime (int)(6 / 0.6) = 10" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-LIFETIME
     PERFORM ASSERT-NUMBER
     MOVE "7 squid_ink: velocity assigned: yd 0.1" TO WS-NAME
     COMPUTE WS-CHK = PC-YD
     MOVE 1000 TO WS-SCALE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 squid_ink: no collision" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-HAS-PHYSICS
     PERFORM ASSERT-NUMBER
     MOVE "7 squid_ink: sprite from age 0 is 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-SPRITE
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-KIND
     CALL "P3-INK-ARGB" USING WS-KIND WS-ARGB
     CALL "P3-INK-NEW" USING PCL PCLX WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ARGB WS-DRAWS
     MOVE "7 glow_squid_ink: colour red 0.2 (thousandths)" TO WS-NAME
     COMPUTE WS-CHK = PC-RCOL
     MOVE 1000 TO WS-SCALE
     MOVE 200 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 glow_squid_ink: green 0.8" TO WS-NAME
     COMPUTE WS-CHK = PC-GCOL
     MOVE 1000 TO WS-SCALE
     MOVE 800 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 glow_squid_ink: blue 0.6" TO WS-NAME
     COMPUTE WS-CHK = PC-BCOL
     MOVE 1000 TO WS-SCALE
     MOVE 600 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 1 TO WS-AIR
     CALL "P3-INK-TICK" USING PCL PCLX PCL-COLLIDERS WS-AIR
     MOVE "7 ink tick in air: yd = 0.1 * 0.92 - 0.0074 = 0.0846 (1e-4)" TO WS-NAME
     COMPUTE WS-CHK = PC-YD
     MOVE 10000 TO WS-SCALE
     MOVE 846 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 0 TO WS-AIR
     MOVE 0.1 TO PC-YD
     CALL "P3-INK-TICK" USING PCL PCLX PCL-COLLIDERS WS-AIR
     MOVE "7 ink tick in water: yd = 0.1 * 0.92 = 0.092 (1e-4, no sinking)" TO WS-NAME
     COMPUTE WS-CHK = PC-YD
     MOVE 10000 TO WS-SCALE
     MOVE 920 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE 5 TO PC-AGE
     CALL "P3-INK-TICK" USING PCL PCLX PCL-COLLIDERS WS-AIR
     MOVE "7 ink tick: age 6 of 10: alpha = 1 - (6 - 5) / 10 = 0.9 (thousandths)" TO WS-NAME
     COMPUTE WS-CHK = PC-ALPHA
     MOVE 1000 TO WS-SCALE
     MOVE 900 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "7 ink tick: sprite (6 * 7) / 10 = 4" TO WS-NAME
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-SPRITE
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§7 Squid ink: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-CHK * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§7 Squid ink: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-3-7.
