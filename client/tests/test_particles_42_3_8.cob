*> Acceptance test of docs/protocol/42-particles-3-fluid-drip-water.md section 8 (GlowParticle):
*> the constructor draws, tick, size and light formulas and worked cases of the section, with the document's
*> tick, size and light formulas, and the worked examples E1 to E12 that apply. The case lines are written
*> by a script that applies the document's numbers; the expected values are the document's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-3-8.
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
     MOVE 0 TO WS-VY
     MOVE 0 TO WS-VZ
     CALL "P3-GLOWCLASS-NEW" USING PCL WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-DRAWS
     MOVE "8 glow class: friction 0.96" TO WS-NAME
     COMPUTE WS-CHK = PC-FRICTION
     MOVE 1000 TO WS-SCALE
     MOVE 960 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "8 glow class: quadSize 0.15 * 0.75 = 0.1125 (1e-4)" TO WS-NAME
     COMPUTE WS-CHK = PC-QUAD-SIZE
     MOVE 10000 TO WS-SCALE
     MOVE 1125 TO TL-EXPECTED-N
     PERFORM ASSERT-SCALED
     MOVE "8 glow class: speedUp on, no collision" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-SPEED-UP * 10 + PC-HAS-PHYSICS
     PERFORM ASSERT-NUMBER
     MOVE 8 TO PC-AGE
     MOVE 17 TO PC-LIFETIME
     MOVE 0.5 TO WS-VAL
     MOVE 0 TO WS-LIGHT
     CALL "P3-GLOW-LIGHT" USING PCL WS-VAL WS-LIGHT WS-OUT
     MOVE "8 glow class light: (8.5 / 17) = 0.5 linear: block 120" TO WS-NAME
     MOVE 120 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUT
     PERFORM ASSERT-NUMBER
     CALL "P3-GLOW-TICK" USING PCL PCL-COLLIDERS
     MOVE "8 glow class tick: the base tick (age 9)" TO WS-NAME
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-AGE
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§8 GlowParticle: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SCALED.
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-CHK * WS-SCALE + 0.5)
     PERFORM ASSERT-NUMBER.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§8 GlowParticle: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-3-8.
