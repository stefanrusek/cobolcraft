*> Acceptance test (lane p49a; docs/protocol/20-mobs-overworld-hostile.md section 3.1 Damage scaling by difficulty): a mob's melee hit of d on a player is 0 in Peaceful,
*> min(d / 2 + 1, d) on Easy, d on Normal and d x 3 / 2 on Hard, before armor (the player here wears none).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-ZOMBIE             BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-DAMAGE             BINARY-LONG.
 01 WS-D                  BINARY-LONG.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-LOST               FLOAT-LONG.
 01 WS-CASE               PIC X(120).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         MOVE WS-D TO BW-DIFFICULTY
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         MOVE 3 TO WS-DAMAGE
         CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-ROW
         COMPUTE WS-LOST = 20 - PL-HEALTH(WS-PLAYER)
         EVALUATE WS-D
             WHEN 0 MOVE "acceptance US15 20§3.1 Damage scaling by difficulty: Peaceful takes 0 of a hit of 3" TO WS-CASE
                    MOVE 0 TO TL-EXPECTED-N
             WHEN 1 MOVE "acceptance US15 20§3.1 Damage scaling by difficulty: Easy takes min(3 / 2 + 1, 3) = 2.5 (in tenths)" TO WS-CASE
                    MOVE 25 TO TL-EXPECTED-N
             WHEN 2 MOVE "acceptance US15 20§3.1 Damage scaling by difficulty: Normal takes 3 (in tenths)" TO WS-CASE
                    MOVE 30 TO TL-EXPECTED-N
             WHEN OTHER MOVE "acceptance US15 20§3.1 Damage scaling by difficulty: Hard takes 4.5 (in tenths)" TO WS-CASE
                    MOVE 45 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-CASE TO TL-CASE
         COMPUTE TL-OBSERVED-N ROUNDED = WS-LOST * 10
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   A hit of 1 on Easy is min(1 / 2 + 1, 1) = 1: the small hit is not raised.
     MOVE 1 TO BW-DIFFICULTY
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 1 TO WS-DAMAGE
     CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-ROW
     COMPUTE WS-LOST = 20 - PL-HEALTH(WS-PLAYER)
     MOVE "acceptance US15 20§3.1 Damage scaling by difficulty: on Easy a hit of 1 stays 1" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-LOST * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-3-1.
 COPY CORETEST.
 COPY MOBSPTEST.
