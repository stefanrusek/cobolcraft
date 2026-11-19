*> Acceptance test (lane p49r; docs/protocol/20 section 16.1): the breeze's stop-attacking rule (priority 0 of FIGHT). The attack target is erased when it cannot be attacked (not a survival or adventure
*> player), is not alive, or is in another level; and when it has not been "attackable ignoring line of sight within the follow range 24" for more than 100 evaluations: the brain's counter is set to 100 on every
*> evaluation that finds the target attackable, is decremented first when it does not, and the target is kept while the counter is still 0 or more. A target that was never attackable is dropped at the first
*> check (the counter starts at 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-LABEL               PIC X(160).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
*>   An attackable target at 10 blocks keeps the breeze's attention and sets the counter to 100; out of range at 40 blocks it is kept for 100 more evaluations and dropped on the 101st.
     COMPUTE WS-X0 = WS-X - 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM SET-TARGET
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "an attackable target at 10 blocks is kept" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     COMPUTE PL-X(WS-PLAYER) = WS-X + 30
     PERFORM 100 TIMES
         CALL "BREEZE-STOP-CHECK" USING WS-MOB
     END-PERFORM
     MOVE "out of range the target is still kept after 100 further evaluations" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "and dropped on the 101st" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   A target that was never attackable (out of range at the first check) is dropped at once.
     MOVE WS-X TO PL-X(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X + 30
     COMPUTE WS-X0 = WS-X - 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM SET-TARGET
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "a target that was never attackable is dropped at the first check" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   A creative player cannot be attacked: dropped at once even in range. A dead one, and one in another dimension, too.
     MOVE WS-X TO PL-X(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM SET-TARGET
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "a creative target is dropped at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     PERFORM SET-TARGET
     MOVE PS-DEAD TO PL-STATE(WS-PLAYER)
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "a dead target is dropped at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     PERFORM SET-TARGET
     COMPUTE PL-DIM(WS-PLAYER) = WS-DIM + 1
     CALL "BREEZE-STOP-CHECK" USING WS-MOB
     MOVE "a target in another dimension is dropped at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE WS-DIM TO PL-DIM(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.

 SET-TARGET.
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     .

 ASSERT-LINE.
     MOVE SPACES TO WS-LABEL
     STRING "acceptance US15 20§16.1 Breeze stop-attacking: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-16-5.
 COPY CORETEST.
 COPY MOBSPTEST.
