*> Implementation test (002-lane-mobsfull-h2, T2226; docs/protocol/18 section 4.7 Shared behaviours cited by the mob documents): cooldown countdown, padding, attack invalidation, timers and walk decisions of the shared behaviours.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-7.
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
     MOVE 5 TO WS-A
     CALL "COUNTDOWN-COOLDOWN" USING WS-A WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents CountDownCooldownTicks decrements the memory by 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents CountDownCooldownTicks keeps running above 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "COUNTDOWN-COOLDOWN" USING WS-A WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents CountDownCooldownTicks stops at 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents CountDownCooldownTicks leaves 0 as the value to erase" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-A
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-A
     MOVE 60 TO WS-B
     MOVE 7 TO WS-C
     CALL "DO-NOTHING-DURATION" USING WS-A WS-B WS-C WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents DoNothing lasts min + roll ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 27 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid keeps a valid target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid erases a target in another level" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid erases a target the mob can no longer attack" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-C
     MOVE 0 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid erases a dead target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 201 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid erases a target unreachable for more than 200 ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 200 TO WS-D
     MOVE 0 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid keeps a target unreachable for exactly 200 ticks" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     MOVE 1 TO WS-E
     CALL "STOP-ATTACKING-DECISION" USING WS-A WS-B WS-C WS-D WS-E WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StopAttackingIfTargetInvalid erases when the stop condition holds" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "TRY-FIND-TIMER" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents TryFindLiquid rearms with 40 when nothing was found" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "TRY-FIND-TIMER" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents TryFindLiquid rearms with 2 when it starts moving" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "TRY-FIND-TIMER" USING WS-A WS-B WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents TryFindLiquid rearms with 20 when the scan did not run" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-F1
     MOVE 5 TO WS-F2
     MOVE 0 TO WS-A
     CALL "WALK-AWAY-NEEDED" USING WS-F1 WS-F2 WS-A WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents SetWalkTargetAwayFrom flees when the memory position is closer than the distance" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "WALK-AWAY-NEEDED" USING WS-F1 WS-F2 WS-A WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents SetWalkTargetAwayFrom changes nothing when already walking away" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 36 TO WS-F1
     MOVE 0 TO WS-A
     CALL "WALK-AWAY-NEEDED" USING WS-F1 WS-F2 WS-A WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents SetWalkTargetAwayFrom ignores a distant memory position" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6.5 TO WS-F1
     MOVE 2.5 TO WS-F2
     CALL "TEMPTATION-WALK" USING WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents FollowTemptation walks when farther than the close-enough distance (2.5, squared 6.25)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-F1
     CALL "TEMPTATION-WALK" USING WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents FollowTemptation erases the walk target when close" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     CALL "CELEBRATE-DECISION" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StartCelebratingIfTargetDead celebrates a dead target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     CALL "CELEBRATE-DECISION" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StartCelebratingIfTargetDead needs a dead target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE 1 TO WS-C
     CALL "CELEBRATE-DECISION" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StartCelebratingIfTargetDead needs no celebration in progress" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-C
     MOVE 0 TO WS-B
     CALL "CELEBRATE-DECISION" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StartCelebratingIfTargetDead needs the predicate" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-B
     MOVE 0 TO WS-D
     CALL "CELEBRATE-DECISION" USING WS-A WS-B WS-C WS-D WS-O1
     MOVE "acceptance US15 18§4.7 Shared behaviours cited by the mob documents StartCelebratingIfTargetDead forgives a dead player only with forgive_dead_players" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-4-7.
