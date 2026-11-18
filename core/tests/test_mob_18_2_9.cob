*> Acceptance test (lane p49a, T14516; docs/protocol/18-mob-framework.md section 2.9 Death tick, with 7.5): a killed mob stays for 20 ticks (deathTime counts
*> 0 to 20, Entity Event 3 at the death, Event 60 and removal at deathTime 20), cannot be hit meanwhile (no second death, no second experience), does not move
*> and ignores the AI; experience and loot are made at the moment of death, not at the removal.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-ORB-TYPE           BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-ROW                BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-SUM                BINARY-LONG.
 01 WS-AMOUNT             BINARY-LONG VALUE 50.
 01 WS-CAUSE              BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 9.
 01 WS-KIND               BINARY-LONG VALUE 1.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-BEFORE-X           FLOAT-LONG.
 01 WS-ORBS-AT-DEATH      BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:experience_orb" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-HURT(WS-ROW) EN-HEALTH-MILLI(WS-ROW)
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM ORB-SUM
     MOVE WS-SUM TO WS-ORBS-AT-DEATH
     MOVE "acceptance US15 18§2.9 Death tick: the experience is made at the moment of death (1 to 3 points)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SUM >= 1 AND WS-SUM <= 3
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.9 Death tick: deathTime starts at 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-COOLDOWN(WS-ROW) TO WS-O
     PERFORM CHECK-N

*>   While dying it cannot be hit and moves nowhere.
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE EN-X(WS-ROW) TO WS-BEFORE-X
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM ORB-SUM
     MOVE "acceptance US15 18§2.9 Death tick: a dying mob cannot be hit again (no second experience)" TO WS-CASE
     MOVE WS-ORBS-AT-DEATH TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§2.9 Death tick: deathTime counts one per tick" TO WS-CASE
     MOVE 7 TO WS-E
     MOVE EN-COOLDOWN(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.9 Death tick: it does not move while dying" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-ROW) = WS-BEFORE-X
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 8 BY 1 UNTIL WS-I > 19
         CALL "MOB-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 18§2.9 Death tick: at deathTime 19 it is still in the world" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 18§2.9 Death tick: at deathTime 20 it is removed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.9 Death tick: the removal makes no further experience" TO WS-CASE
     PERFORM ORB-SUM
     MOVE WS-ORBS-AT-DEATH TO WS-E
     MOVE WS-SUM TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 ORB-SUM.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             COMPUTE WS-SUM = WS-SUM + EN-ITEM(WS-I) * EN-ITEM-COUNT(WS-I)
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-9.
 COPY CORETEST.
 COPY MOBSPTEST.
