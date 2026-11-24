*> Acceptance test of docs/protocol/44-residual-mob-questions-x1-continuation.md section 8.10 (Goat.finalizeSpawn; T24303 family, wrap I3 r6) as the live spawn path: STDMOB-FINALIZE draws the
*> screaming flag (nextDouble < 0.02), then for an adult nextFloat < 0.1f and only then nextBoolean (true: the left horn goes, false: the right), from the spawn's Xoroshiro stream (10 sections 2.1 to 2.3).
*> EN-WOOL: 1 screaming, 2 no left horn, 4 no right horn. Every expected value was derived in Python from the algorithm of 10 sections 2.1 to 2.3 (checked against its worked examples for seed 0:
*> the four longs, 5 doubles) with XORO-SEED(seed) first, not from this code: scratchpad/i3/goat_derive.py. A goat of MOB-SPAWN alone is plain (both horns, not screaming).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-GOAT-FIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CASE                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-BOOL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SCREAM              BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-BOTH                BINARY-LONG.
 01 WS-WANT-SEED           BINARY-LONG.
 01 WS-WANT-BABY           BINARY-LONG.
 01 WS-WANT-WOOL           BINARY-LONG.
 01 WS-WANT-LO             BINARY-DOUBLE UNSIGNED.
 01 WS-WANT-HI             BINARY-DOUBLE UNSIGNED.
 01 WS-LO-1                BINARY-DOUBLE UNSIGNED VALUE 15660737589780686759.
 01 WS-HI-1                BINARY-DOUBLE UNSIGNED VALUE 6343153857732796723.
 01 WS-LO-14               BINARY-DOUBLE UNSIGNED VALUE 2161463681202551483.
 01 WS-HI-14               BINARY-DOUBLE UNSIGNED VALUE 7552850581951953807.
 01 WS-LO-20               BINARY-DOUBLE UNSIGNED VALUE 11880166737195061399.
 01 WS-HI-20               BINARY-DOUBLE UNSIGNED VALUE 7851421936212780422.
 PROCEDURE DIVISION.
*>   ---- the two new draw operations of 10 section 2.3, on the seed 0 stream whose first four longs are listed in 10 section 2.7
     MOVE 0 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-NEXT-FLOAT" USING XR-STATE WS-FLOAT
     MOVE "acceptance US15 44-x1§8.10 nextFloat of the first long of seed 0 is 2763940 x 2^-24 (24 bits)" TO WS-CASE
     MOVE 2763940 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FLOAT * 16777216
     PERFORM CHK
     CALL "XORO-NEXT-FLOAT" USING XR-STATE WS-FLOAT
     MOVE "acceptance US15 44-x1§8.10 nextFloat of the second long is 13417506 x 2^-24" TO WS-CASE
     MOVE 13417506 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-FLOAT * 16777216
     PERFORM CHK
     MOVE 0 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-NEXT-BOOLEAN" USING XR-STATE WS-BOOL
     MOVE "acceptance US15 44-x1§8.10 nextBoolean of the first long of seed 0 (3038984756725240190, even) is false" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-BOOL TO WS-OBS
     PERFORM CHK
     CALL "XORO-NEXT-BOOLEAN" USING XR-STATE WS-BOOL
     CALL "XORO-NEXT-BOOLEAN" USING XR-STATE WS-BOOL
     CALL "XORO-NEXT-BOOLEAN" USING XR-STATE WS-BOOL
     MOVE "acceptance US15 44-x1§8.10 nextBoolean of the fourth long (2160572957309072155, odd) is true" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-BOOL TO WS-OBS
     PERFORM CHK
*>   ---- the world and a goat
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:goat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE "acceptance US15 44-x1§8.10 a goat of MOB-SPAWN alone is plain: not screaming, both horns (EN-WOOL 0)" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-WOOL(WS-ROW) TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   ---- adult goats of seeds with every state (python: seed 1 plain, 18 screaming, 14 right horn gone, 20 left horn gone, 590 screaming and left, 607 screaming and right)
     MOVE 1 TO WS-WANT-SEED
     MOVE 0 TO WS-WANT-BABY WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 1 adult: plain (EN-WOOL 0)" TO WS-CASE
     PERFORM GOAT-CASE
     MOVE 18 TO WS-WANT-SEED
     MOVE 1 TO WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 18 adult: screaming, both horns (EN-WOOL 1)" TO WS-CASE
     PERFORM GOAT-CASE
     MOVE 14 TO WS-WANT-SEED
     MOVE 4 TO WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 14 adult: nextBoolean false takes the right horn (EN-WOOL 4)" TO WS-CASE
     PERFORM GOAT-CASE
     MOVE 20 TO WS-WANT-SEED
     MOVE 2 TO WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 20 adult: nextBoolean true takes the left horn (EN-WOOL 2)" TO WS-CASE
     PERFORM GOAT-CASE
     MOVE 590 TO WS-WANT-SEED
     MOVE 3 TO WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 590 adult: screaming and the left horn gone (EN-WOOL 3)" TO WS-CASE
     PERFORM GOAT-CASE
     MOVE 607 TO WS-WANT-SEED
     MOVE 5 TO WS-WANT-WOOL
     MOVE "acceptance US15 44-x1§8.10 seed 607 adult: screaming and the right horn gone (EN-WOOL 5)" TO WS-CASE
     PERFORM GOAT-CASE
*>   ---- the draw counts: the stream after the finalize equals the python stream after 2 draws (no horn), 3 draws (a horn went) or 1 draw (a baby)
     MOVE 1 TO WS-WANT-SEED
     MOVE 0 TO WS-WANT-BABY WS-WANT-WOOL
     MOVE WS-LO-1 TO WS-WANT-LO
     MOVE WS-HI-1 TO WS-WANT-HI
     MOVE "acceptance US15 44-x1§8.10 seed 1: two draws (nextDouble, nextFloat), no nextBoolean: stream lo" TO WS-CASE
     PERFORM STREAM-CASE
     MOVE 14 TO WS-WANT-SEED
     MOVE WS-LO-14 TO WS-WANT-LO
     MOVE WS-HI-14 TO WS-WANT-HI
     MOVE "acceptance US15 44-x1§8.10 seed 14: three draws (nextDouble, nextFloat, nextBoolean): stream lo" TO WS-CASE
     PERFORM STREAM-CASE
     MOVE 20 TO WS-WANT-SEED
     MOVE 1 TO WS-WANT-BABY
     MOVE WS-LO-20 TO WS-WANT-LO
     MOVE WS-HI-20 TO WS-WANT-HI
     MOVE "acceptance US15 44-x1§8.10 seed 20 baby: one draw (the horn test is for an adult), no horn lost (EN-WOOL 0): stream lo" TO WS-CASE
     PERFORM STREAM-CASE
     MOVE 0 TO WS-WANT-WOOL
     MOVE 20 TO WS-WANT-SEED
     MOVE 1 TO WS-WANT-BABY
     MOVE "acceptance US15 44-x1§8.10 seed 20 baby keeps both horns (EN-WOOL 0)" TO WS-CASE
     PERFORM GOAT-CASE
*>   ---- seeds 1 to 1000 (python: 21 screaming, 39 without the left horn, 60 without the right, none without both)
     MOVE 0 TO WS-SCREAM WS-LEFT WS-RIGHT WS-BOTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF FUNCTION MOD(EN-WOOL(WS-ROW), 2) = 1
             ADD 1 TO WS-SCREAM
         END-IF
         IF FUNCTION MOD(FUNCTION INTEGER(EN-WOOL(WS-ROW) / 2), 2) = 1
             ADD 1 TO WS-LEFT
         END-IF
         IF EN-WOOL(WS-ROW) >= 4
             ADD 1 TO WS-RIGHT
         END-IF
         IF EN-WOOL(WS-ROW) = 6 OR EN-WOOL(WS-ROW) = 7
             ADD 1 TO WS-BOTH
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-x1§8.10 seeds 1 to 1000: 21 screaming goats" TO WS-CASE
     MOVE 21 TO WS-EXP
     MOVE WS-SCREAM TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-x1§8.10 seeds 1 to 1000: 39 lose the left horn" TO WS-CASE
     MOVE 39 TO WS-EXP
     MOVE WS-LEFT TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-x1§8.10 seeds 1 to 1000: 60 lose the right horn" TO WS-CASE
     MOVE 60 TO WS-EXP
     MOVE WS-RIGHT TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 44-x1§8.10 seeds 1 to 1000: none loses both" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-BOTH TO WS-OBS
     PERFORM CHK
     STOP RUN.
 GOAT-CASE.
     MOVE WS-WANT-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     IF WS-WANT-BABY = 1
         MOVE -24000 TO EN-MOBAGE(WS-ROW)
     END-IF
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
     MOVE WS-WANT-WOOL TO WS-EXP
     MOVE EN-WOOL(WS-ROW) TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW.
 STREAM-CASE.
     MOVE WS-WANT-SEED TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     IF WS-WANT-BABY = 1
         MOVE -24000 TO EN-MOBAGE(WS-ROW)
     END-IF
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF XR-LO = WS-WANT-LO AND XR-HI = WS-WANT-HI
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK.
 CHK.
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS.
 END PROGRAM TEST-MOB-44-GOAT-FIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(200).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
