*> Acceptance test (lane p49x; docs/protocol/20 section 17, 31 section 6, 44-5 section 8): the creaking heart in the live world. BE-TICK-ALL runs the heart of every loaded chunk (the block entity
*> runner): the pale oak log test with the axis, the block state written back (an uprooted heart with its logs is awake or dormant after one runner tick: the block's own update; then the state update
*> of the body every R + 2 ticks), the protector spawned and linked for an awake heart with a player near, the comparator output 15 - floor(15 d / 32) cached in HT-SIGNAL, the teardown of the
*> protector when the attribute ends and when the heart block is broken.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CREAKSTATE.
 COPY HEARTSTATE.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-LABEL               PIC X(240).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 70.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-HEART-STATE         BINARY-LONG.
 01 WS-LOG-Y               BINARY-LONG.
 01 WS-LOG-X               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-HDX                 FLOAT-LONG.
 01 WS-HDZ                 FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-HEART-AWAKE         BINARY-LONG.
 01 WS-HEART-X             BINARY-LONG.
 01 WS-HEART-Z             BINARY-LONG.
 01 WS-LOG-Z               BINARY-LONG.
 01 WS-SIDE-HEART          BINARY-LONG.
 01 WS-SIDE-LOG            BINARY-LONG.
 01 WS-SIDE-DX             BINARY-LONG.
 01 WS-SIDE-DZ             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 35
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 35
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-HX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-HY = WS-FY + 2
     COMPUTE WS-HZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 4
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 2 TO BW-DIFFICULTY
     MOVE 14000 TO CW-TIME
     PERFORM MAKE-STATES
*>   1. The block's own update: an uprooted heart with a pale oak log of its axis on both sides is awake at night after one runner tick, dormant by day.
     MOVE WS-LOG-Y TO WS-ABOVE
     PERFORM SETUP-SCENE
     MOVE "the setup heart is uprooted (0)" TO WS-LABEL
     MOVE 0 TO WS-WANT
     PERFORM CHECK-HEART
     CALL "BE-TICK-ALL"
     MOVE "with both logs of its axis it is awake (2) after one runner tick at night" TO WS-LABEL
     MOVE 2 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE 5000 TO CW-TIME
     PERFORM SETUP-SCENE
     CALL "BE-TICK-ALL"
     MOVE "by day it is dormant (1)" TO WS-LABEL
     MOVE 1 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE 14000 TO CW-TIME
     MOVE WS-AIR TO WS-ABOVE
     PERFORM SETUP-SCENE
     PERFORM 3 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "without the log above it stays uprooted (0)" TO WS-LABEL
     MOVE 0 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE WS-LOG-X TO WS-ABOVE
     PERFORM SETUP-SCENE
     PERFORM 3 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "a log of another axis does not count: uprooted (0)" TO WS-LABEL
     MOVE 0 TO WS-WANT
     PERFORM CHECK-HEART
*>   2. The body (second heart tick): a protector is spawned and bound; the comparator follows its distance.
     MOVE WS-LOG-Y TO WS-ABOVE
     PERFORM SETUP-SCENE
     PERFORM 4 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM FIND-CREAKING
     MOVE "the runner spawns a protector for the awake heart with a player near" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     IF WS-CROW = 0
         STOP RUN
     END-IF
     CALL "HEART-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-ZERO WS-SLOT
     MOVE "and the heart record links it" TO WS-LABEL
     MOVE EN-ID(WS-CROW) TO TL-EXPECTED-N
     MOVE HT-LINK(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "the first signal is 15 - floor(15 d / 32) for the distance it was spawned at" TO WS-LABEL
     COMPUTE WS-HDX = EN-X(WS-CROW) - WS-HX - 0.5
     COMPUTE WS-HDZ = EN-Z(WS-CROW) - WS-HZ - 0.5
     COMPUTE WS-DIST = FUNCTION SQRT(WS-HDX * WS-HDX + (EN-Y(WS-CROW) - WS-HY) * (EN-Y(WS-CROW) - WS-HY) + WS-HDZ * WS-HDZ)
     COMPUTE TL-EXPECTED-N = 15 - FUNCTION INTEGER(15 * WS-DIST / 32)
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   The comparator output (31 section 6.6, worked example 5): 8 blocks away 12, at 0 blocks 15, 20 blocks 6 (15 - floor(300 / 32)), 32 or more 0.
     COMPUTE EN-X(WS-CROW) = WS-HX + 8.5
     COMPUTE EN-Z(WS-CROW) = WS-HZ + 0.5
     MOVE WS-HY TO EN-Y(WS-CROW)
     CALL "BE-TICK-ALL"
     MOVE "a protector 8 blocks away gives the comparator output 12" TO WS-LABEL
     MOVE 12 TO TL-EXPECTED-N
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 0.5
     CALL "BE-TICK-ALL"
     MOVE "at distance 0 it is 15" TO WS-LABEL
     MOVE 15 TO TL-EXPECTED-N
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 20.5
     CALL "BE-TICK-ALL"
     MOVE "at 20 blocks it is 6" TO WS-LABEL
     MOVE 6 TO TL-EXPECTED-N
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 33.5
     CALL "BE-TICK-ALL"
     MOVE "at 33 blocks it is 0" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   3. The attribute ends at 23401: within a body period the link is cleared, the heart is dormant and the protector tears down for 45 ticks.
     COMPUTE EN-X(WS-CROW) = WS-HX + 4.5
     MOVE 23401 TO CW-TIME
     PERFORM 27 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "after the attribute ends the heart block is dormant (1)" TO WS-LABEL
     MOVE 1 TO WS-WANT
     PERFORM CHECK-HEART
     CALL "CRK-FIND" USING EN-ID(WS-CROW) WS-ZERO WS-CSLOT
     MOVE "and the protector tears down (45 ticks)" TO WS-LABEL
     MOVE 45 TO TL-EXPECTED-N
     MOVE CRK-TEAR(WS-CSLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and the signal is 0 without a link" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-SIGNAL(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   4. Logs gone: an awake heart with no link (Peaceful: no protector) is written back as uprooted by its next body.
     MOVE 14000 TO CW-TIME
     MOVE 0 TO BW-DIFFICULTY
     MOVE WS-LOG-Y TO WS-ABOVE
     PERFORM SETUP-SCENE
     PERFORM 3 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "in Peaceful the awake heart (2) spawns nothing" TO WS-LABEL
     MOVE 2 TO WS-WANT
     PERFORM CHECK-HEART
     COMPUTE WS-NY = WS-HY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-AIR
     PERFORM 27 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     MOVE "when a log is removed the next body writes uprooted (0)" TO WS-LABEL
     MOVE 0 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE 2 TO BW-DIFFICULTY
*>   5. The heart is broken: the protector is torn down (removeProtector(null)) and the record is gone.
     MOVE WS-LOG-Y TO WS-ABOVE
     PERFORM SETUP-SCENE
     PERFORM 4 TIMES
         CALL "BE-TICK-ALL"
     END-PERFORM
     PERFORM FIND-CREAKING
     CALL "CRK-FIND" USING EN-ID(WS-CROW) WS-ZERO WS-CSLOT
     MOVE "before the break the protector is not tearing down" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE CRK-TEAR(WS-CSLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-AIR
     CALL "BE-TICK-ALL"
     MOVE "breaking the heart tears the protector down (45 ticks)" TO WS-LABEL
     MOVE 45 TO TL-EXPECTED-N
     MOVE CRK-TEAR(WS-CSLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "HEART-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-ZERO WS-SLOT
     MOVE "and the heart record is released" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   6. The axis counts: hearts along x and along z are awake with logs of their own axis.
     MOVE 14000 TO CW-TIME
     MOVE WS-HEART-X TO WS-SIDE-HEART
     MOVE WS-LOG-X TO WS-SIDE-LOG
     MOVE 1 TO WS-SIDE-DX
     MOVE 0 TO WS-SIDE-DZ
     PERFORM SIDE-SCENE
     CALL "BE-TICK-ALL"
     MOVE "a heart along x with logs of axis x on both sides is awake" TO WS-LABEL
     MOVE 2 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE WS-HEART-Z TO WS-SIDE-HEART
     MOVE WS-LOG-Z TO WS-SIDE-LOG
     MOVE 0 TO WS-SIDE-DX
     MOVE 1 TO WS-SIDE-DZ
     PERFORM SIDE-SCENE
     CALL "BE-TICK-ALL"
     MOVE "a heart along z with logs of axis z on both sides is awake" TO WS-LABEL
     MOVE 2 TO WS-WANT
     PERFORM CHECK-HEART
     MOVE WS-LOG-X TO WS-SIDE-LOG
     PERFORM SIDE-SCENE
     CALL "BE-TICK-ALL"
     MOVE "logs of axis x around a heart along z do not count: uprooted" TO WS-LABEL
     MOVE 0 TO WS-WANT
     PERFORM CHECK-HEART
*>   7. With every heart record taken, a heart that is not uprooted cannot get one and does nothing.
     MOVE WS-AIR TO WS-ABOVE
     PERFORM SETUP-SCENE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEART-AWAKE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         MOVE 1 TO HT-USED(WS-I)
         MOVE 999 TO HT-DIM(WS-I)
         MOVE WS-I TO HT-X(WS-I)
     END-PERFORM
     CALL "BE-TICK-ALL"
     CALL "HEART-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-ZERO WS-SLOT
     MOVE "with all 16 records taken the heart gets none" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and the records of hearts that have no block entity are released" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-USED(1) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     STOP RUN.

 MAKE-STATES.
     MOVE "minecraft:creaking_heart" TO WS-KEY
     MOVE "axis=y,creaking_heart_state=uprooted,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-STATE
     MOVE "minecraft:pale_oak_log" TO WS-KEY
     MOVE "axis=y" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LOG-Y
     MOVE "axis=x" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LOG-X
     MOVE "axis=z" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LOG-Z
     MOVE "minecraft:creaking_heart" TO WS-KEY
     MOVE "axis=y,creaking_heart_state=awake,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-AWAKE
     MOVE "axis=x,creaking_heart_state=uprooted,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-X
     MOVE "axis=z,creaking_heart_state=uprooted,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-Z
     .

*> The column replaced by a heart of another axis with a pale oak log on both sides along that axis (WS-SIDE-HEART, WS-SIDE-LOG, step WS-SIDE-DX, WS-SIDE-DZ).
 SIDE-SCENE.
     MOVE WS-AIR TO WS-ABOVE
     PERFORM SETUP-SCENE
     COMPUTE WS-NY = WS-HY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-AIR
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-SIDE-HEART
     COMPUTE WS-NX = WS-HX + WS-SIDE-DX
     COMPUTE WS-NZ = WS-HZ + WS-SIDE-DZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-HY WS-NZ WS-SIDE-LOG
     COMPUTE WS-NX = WS-HX - WS-SIDE-DX
     COMPUTE WS-NZ = WS-HZ - WS-SIDE-DZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-HY WS-NZ WS-SIDE-LOG
     .

*> A clean scene: no creaking, no heart records, the cells around the heart air, the heart column (log, an uprooted heart, WS-ABOVE) rebuilt.
 SETUP-SCENE.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         INITIALIZE HT-ENTRY(WS-I)
     END-PERFORM
     PERFORM VARYING WS-X FROM -3 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Y FROM -3 BY 1 UNTIL WS-Y > 3
             PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 3
                 COMPUTE WS-NX = WS-HX + WS-X
                 COMPUTE WS-NY = WS-HY + WS-Y
                 COMPUTE WS-NZ = WS-HZ + WS-Z
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-NY WS-NZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-NY = WS-HY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-LOG-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEART-STATE
     COMPUTE WS-NY = WS-HY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-ABOVE
     .

*> The state of the heart block: 0 uprooted, 1 dormant, 2 awake (9 when it is something else).
 CHECK-HEART.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-STATE
     MOVE "creaking_heart_state" TO WS-NAME
     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME WS-TEXT WS-RESULT
     EVALUATE WS-TEXT
         WHEN "uprooted"
             MOVE 0 TO WS-NUM
         WHEN "dormant"
             MOVE 1 TO WS-NUM
         WHEN "awake"
             MOVE 2 TO WS-NUM
         WHEN OTHER
             MOVE 9 TO WS-NUM
     END-EVALUATE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-NUM TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     .

 FIND-CREAKING.
     MOVE 0 TO WS-CROW
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             MOVE WS-E TO WS-CROW
         END-IF
     END-PERFORM
     .

 ASSERT-LINE.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 20§17 Creaking heart runner: " DELIMITED BY SIZE FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-17-5.
 COPY CORETEST.
 COPY MOBSPTEST.
