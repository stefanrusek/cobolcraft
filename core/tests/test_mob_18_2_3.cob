*> Acceptance test (lane p49a; docs/protocol/18-mob-framework.md section 2.3 LivingEntity.tick step 3, with 17 section 3.9 and 1.4 slot 12): an arrow that hurts a living target
*> adds a stuck arrow; while the count is above 0 a timer of 20 x (30 - count) ticks counts down and at 0 the count drops by one (3 arrows: 540 ticks for the first); the count is
*> sent as Set Entity Data index 12 (INT) when it changes; an arrow that does no damage (inside the hurt window) adds none. (The stinger count, the equipment detection (9.3),
*> the combat tracker and the body rotation bookkeeping of the same step are not modelled; see the lane report.)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-PIG                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-ARROW              BINARY-LONG.
 01 WS-NO-ROW             BINARY-LONG VALUE 0.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-V                  FLOAT-LONG VALUE 1.5.
 01 WS-ZERO               FLOAT-LONG VALUE 0.
 01 WS-BASE               BINARY-LONG VALUE 2000.
 01 WS-OWNER              BINARY-LONG VALUE 0.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-I                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 100 TO EN-HEALTH(WS-ROW)
     MOVE "N" TO TL-MODE

*>   Three arrows hurt the pig (the hurt window cleared between them, as the arrow code does).
     PERFORM 3 TIMES
         CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-ZERO WS-ZERO WS-BASE WS-OWNER WS-ARROW
         CALL "ARROW-HIT" USING WS-ARROW WS-ROW WS-NO-ROW
     END-PERFORM
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: three arrows that hurt leave three stuck arrows" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE EN-ARROWS(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The counter: the timer starts at 20 x (30 - 3) = 540 and is 539 after the first tick.
     CALL "M183-ARROWS-TICK" USING WS-ROW
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: the timer starts at 20 x (30 - 3) = 540 and is 539 after one tick" TO WS-CASE
     MOVE 539 TO WS-E
     MOVE EN-ARROW-TIMER(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: the count is still 3" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE EN-ARROWS(WS-ROW) TO WS-O
     PERFORM CHECK-N
     PERFORM 538 TIMES
         CALL "M183-ARROWS-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: 539 ticks in: timer 1, count 3" TO WS-CASE
     MOVE 13 TO WS-E
     COMPUTE WS-O = EN-ARROW-TIMER(WS-ROW) * 10 + EN-ARROWS(WS-ROW)
     PERFORM CHECK-N
     CALL "M183-ARROWS-TICK" USING WS-ROW
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: at 540 ticks the count drops by one to 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE EN-ARROWS(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The sent count follows the change.
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: the count last sent to the viewers is 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE EN-ARROWS-SENT(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   The next timer is 20 x (30 - 2) = 560 (started on the following tick).
     CALL "M183-ARROWS-TICK" USING WS-ROW
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: the next timer is 20 x (30 - 2) = 560, 559 after its first tick" TO WS-CASE
     MOVE 559 TO WS-E
     MOVE EN-ARROW-TIMER(WS-ROW) TO WS-O
     PERFORM CHECK-N
*>   An arrow inside the hurt window does no damage and adds none.
     MOVE 0 TO EN-ARROWS(WS-ROW)
     MOVE 0 TO WS-V
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-ZERO WS-ZERO WS-BASE WS-OWNER WS-ARROW
     CALL "ARROW-HIT" USING WS-ARROW WS-ROW WS-NO-ROW
     MOVE "acceptance US15 18§2.3 LivingEntity.tick: an arrow that does no damage sticks nowhere" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-ARROWS(WS-ROW) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-3.
 COPY CORETEST.
 COPY MOBSPTEST.
