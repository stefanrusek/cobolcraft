*> Implementation test (002-lane-mobsfull-h2, T2228; docs/protocol/18 section 4.8 NeutralMob): persistent anger: isAngry, timers, stopBeingAngry, loading, isAngryAt, updatePersistentAnger, playerDied and the universal anger reset.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 500 TO WS-A
     MOVE 499 TO WS-B
     CALL "NEUTRAL-IS-ANGRY" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngry: end time above 0 and above the game time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO WS-B
     CALL "NEUTRAL-IS-ANGRY" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngry is false when the end time equals the game time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE -5 TO WS-B
     CALL "NEUTRAL-IS-ANGRY" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngry is false for an end time of 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-A
     MOVE -5 TO WS-B
     CALL "NEUTRAL-IS-ANGRY" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngry is false for the -1 left by stopBeingAngry" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO WS-A
     MOVE 600 TO WS-B
     CALL "NEUTRAL-SET-TIME" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob setTimeToRemainAngry sets end time = game time + ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1600 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-A
     MOVE 8 TO WS-B
     MOVE 7 TO WS-C
     MOVE 600 TO WS-D
     CALL "NEUTRAL-STOP" USING WS-A WS-B WS-C WS-D
     MOVE "acceptance US15 18§4.8 NeutralMob stopBeingAngry clears last-hurt-by" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob stopBeingAngry clears the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-B
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob stopBeingAngry clears the anger target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-C
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob stopBeingAngry sets the end time to -1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-D
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 900 TO WS-B
     MOVE 50 TO WS-C
     MOVE 100 TO WS-D
     CALL "NEUTRAL-LOAD-TIME" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob loading reads anger_end_time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "NEUTRAL-LOAD-TIME" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob loading falls back to the legacy AngerTime applied to the game time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 150 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 1 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt is false when the mob cannot attack the entity" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt is true for a valid player when angry at all players (universal anger)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt is false for a valid player without universal anger and no match" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt is true for the persistent anger target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt at all players needs the mob to be angry" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     CALL "NEUTRAL-ANGRY-AT" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob isAngryAt at all players needs no specific anger target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 1 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead Mob anger target ends the anger (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead Mob anger target ends the anger (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead Mob anger target ends the anger (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead player anger target does not end the anger through this branch (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead player anger target does not end the anger through this branch (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a dead player anger target does not end the anger through this branch (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 1 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a new target becomes the anger target and starts the timer (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a new target becomes the anger target and starts the timer (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a new target becomes the anger target and starts the timer (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     MOVE 0 TO WS-H
     MOVE 1 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: the same target changes nothing (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: the same target changes nothing (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: the same target changes nothing (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: an anger target whose time ran out stops the anger (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: an anger target whose time ran out stops the anger (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: an anger target whose time ran out stops the anger (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 1 TO WS-G
     MOVE 1 TO WS-H
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a valid player target that can be tracked keeps the anger (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a valid player target that can be tracked keeps the anger (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a valid player target that can be tracked keeps the anger (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-F
     MOVE 0 TO WS-G
     MOVE 0 TO WS-H
     MOVE 1 TO WS-I
     MOVE 1 TO WS-J
     CALL "NEUTRAL-UPDATE" USING WS-A WS-B WS-C WS-D WS-E WS-F WS-G WS-H WS-I WS-J WS-O1 WS-O2 WS-O3
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a creative or spectator player or Peaceful stops the anger (stop)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a creative or spectator player or Peaceful stops the anger (timer)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.8 NeutralMob updatePersistentAnger: a creative or spectator player or Peaceful stops the anger (set anger target)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "NEUTRAL-PLAYER-DIED" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob playerDied: forgive_dead_players and the dead player is the anger target stops the anger" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-B
     CALL "NEUTRAL-PLAYER-DIED" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob playerDied: another player changes nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "NEUTRAL-PLAYER-DIED" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob playerDied: without forgive_dead_players nothing changes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "UNIVERSAL-ANGER-RESET-CAN-USE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob ResetUniversalAngerTargetGoal runs when universal_anger is on and a player hurt the mob" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "UNIVERSAL-ANGER-RESET-CAN-USE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob ResetUniversalAngerTargetGoal does not run without universal_anger" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "UNIVERSAL-ANGER-RESET-CAN-USE" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.8 NeutralMob ResetUniversalAngerTargetGoal needs a new hit by a player" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-8.
