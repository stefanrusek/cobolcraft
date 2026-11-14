*> Test (US15; docs/protocol/18-mob-framework.md section 8.2; docs/protocol/19 section 6.1 and 44 part 1 section 2): the pure rules of taming and ownership in
*> core/src/mob-18-8.cob (M188-TAME-*, M188-OWNER-FAR, M188-FOLLOW, M188-SIT-TOGGLE). The live wiring is tested by acc_us15_wolf.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-8-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-TAME               BINARY-LONG.
 01 WS-SIT                BINARY-LONG.
 01 WS-FLAGS              BINARY-LONG.
 01 WS-DRAW               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-D2                 FLOAT-LONG.
 01 WS-FAR                BINARY-LONG.
 01 WS-MOVING             BINARY-LONG.
 01 WS-ACTION             BINARY-LONG.
 01 WS-CONSUMED           BINARY-LONG.
 01 WS-OWNER              BINARY-LONG.
 01 WS-NEW                BINARY-LONG.
 PROCEDURE DIVISION.
*> Metadata slot 18: bit 4 tame, bit 1 sitting pose
     MOVE 0 TO WS-TAME WS-SIT
     CALL "M188-TAME-FLAGS" USING WS-TAME WS-SIT WS-FLAGS
     MOVE "acceptance US15 18§8.2 Taming, ownership: wild standing mob has flags 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FLAGS TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-TAME
     CALL "M188-TAME-FLAGS" USING WS-TAME WS-SIT WS-FLAGS
     MOVE "acceptance US15 18§8.2 Taming, ownership: tame standing mob has flags 4" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-FLAGS TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-SIT
     CALL "M188-TAME-FLAGS" USING WS-TAME WS-SIT WS-FLAGS
     MOVE "acceptance US15 18§8.2 Taming, ownership: tame sitting mob has flags 5" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-FLAGS TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-TAME
     CALL "M188-TAME-FLAGS" USING WS-TAME WS-SIT WS-FLAGS
     MOVE "acceptance US15 18§8.2 Taming, ownership: wild sitting mob has flags 1" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FLAGS TO WS-O
     PERFORM CHECK-N
*> The taming chance: nextInt(3) == 0
     PERFORM VARYING WS-DRAW FROM 0 BY 1 UNTIL WS-DRAW > 2
         CALL "M188-TAME-TRY" USING WS-DRAW WS-OK
         MOVE "acceptance US15 18§8.2 Taming, ownership: draw 0 of 3 tames, 1 and 2 do not" TO WS-CASE
         MOVE 0 TO WS-E
         IF WS-DRAW = 0
             MOVE 1 TO WS-E
         END-IF
         MOVE WS-OK TO WS-O
         PERFORM CHECK-N
     END-PERFORM
*> shouldTryTeleportToOwner: squared distance at least 144
     MOVE 143.9 TO WS-D2
     CALL "M188-OWNER-FAR" USING WS-D2 WS-FAR
     MOVE "acceptance US15 18§8.2 Taming, ownership: squared distance 143.9 is not far" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FAR TO WS-O
     PERFORM CHECK-N
     MOVE 144 TO WS-D2
     CALL "M188-OWNER-FAR" USING WS-D2 WS-FAR
     MOVE "acceptance US15 18§8.2 Taming, ownership: squared distance 144 is far" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FAR TO WS-O
     PERFORM CHECK-N
*> FollowOwner (start 10, stop 2, teleport 12): action 0 nothing, 1 walk, 2 teleport, 3 stop
     MOVE 0 TO WS-MOVING
     MOVE 100 TO WS-D2
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: exactly 10 blocks away it does not start" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 101 TO WS-D2
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: farther than 10 blocks it starts walking" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 150 TO WS-D2
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: 12 blocks or more it teleports" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-MOVING
     MOVE 50 TO WS-D2
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: a walking pet keeps walking beyond 2 blocks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-D2
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: a walking pet stops within 2 blocks" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-MOVING
     CALL "M188-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 18§8.2 Taming, ownership: a standing pet within 2 blocks does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ACTION TO WS-O
     PERFORM CHECK-N
*> The sit order toggles when the owner uses a mob and the base interaction consumed nothing
     MOVE 0 TO WS-SIT WS-CONSUMED
     MOVE 1 TO WS-OWNER
     CALL "M188-SIT-TOGGLE" USING WS-SIT WS-CONSUMED WS-OWNER WS-NEW
     MOVE "acceptance US15 18§8.2 Taming, ownership: the owner's empty hand orders a standing pet to sit" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-SIT
     CALL "M188-SIT-TOGGLE" USING WS-SIT WS-CONSUMED WS-OWNER WS-NEW
     MOVE "acceptance US15 18§8.2 Taming, ownership: the owner's empty hand makes a sitting pet stand" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-CONSUMED
     CALL "M188-SIT-TOGGLE" USING WS-SIT WS-CONSUMED WS-OWNER WS-NEW
     MOVE "acceptance US15 18§8.2 Taming, ownership: a consumed interaction leaves the order" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-CONSUMED WS-OWNER
     CALL "M188-SIT-TOGGLE" USING WS-SIT WS-CONSUMED WS-OWNER WS-NEW
     MOVE "acceptance US15 18§8.2 Taming, ownership: a stranger does not change the order" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEW TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-8-2.
