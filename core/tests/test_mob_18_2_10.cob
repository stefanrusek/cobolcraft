*> Acceptance test (lane p49a, T14510; docs/protocol/18-mob-framework.md section 2.10 No-AI and immobile mobs): a mob with the no-AI flag (EN-NO-AI)
*> has no goals, navigation or controls (serverAiStep is not called) and no travel (no gravity, friction or movement of its own); what is not AI still
*> runs: the baseTick fire damage and the death tick. A mob without the flag in the same place falls and strolls.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-COW                BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-FREE               BINARY-LONG.
 01 WS-STILL              BINARY-LONG.
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
 01 WS-START-Y            FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-TICK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE 6000 TO CW-TIME
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY + 3
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE WS-Y TO WS-START-Y
     MOVE "N" TO TL-MODE

*>   Without the flag a cow in the air falls in five ticks.
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-FREE
     MOVE 0 TO EN-NO-AI(WS-FREE)
     PERFORM STEP-FREE 5 TIMES
     MOVE "acceptance US15 18§2.10 No-AI: a mob without the flag falls" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-FREE) < WS-START-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   With the flag it hangs where it is: no travel, no gravity, no velocity integrated.
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-STILL
     MOVE 1 TO EN-NO-AI(WS-STILL)
     PERFORM STEP-STILL 40 TIMES
     MOVE "acceptance US15 18§2.10 No-AI: a mob with the flag does not fall" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-STILL) = WS-START-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§2.10 No-AI: and does not stroll (x and z unchanged)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-STILL) = WS-X AND EN-Z(WS-STILL) = WS-Z
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A knockback velocity is stored but not integrated.
     MOVE 0.4 TO EN-VX(WS-STILL)
     MOVE 0.4 TO EN-VY(WS-STILL)
     PERFORM STEP-STILL 5 TIMES
     MOVE "acceptance US15 18§2.10 No-AI: a stored velocity is not integrated" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-STILL) = WS-X AND EN-Y(WS-STILL) = WS-START-Y
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Fire is baseTick, not AI: the count of 40 takes 1 health on its tick.
     MOVE 20 TO EN-HEALTH(WS-STILL)
     MOVE 40 TO EN-BURN(WS-STILL)
     MOVE 0 TO EN-HURT(WS-STILL)
     PERFORM STEP-STILL
     MOVE "acceptance US15 18§2.10 No-AI: a burning mob still takes the fire damage" TO WS-CASE
     MOVE 19 TO WS-E
     MOVE EN-HEALTH(WS-STILL) TO WS-O
     PERFORM CHECK-N
*>   Death is not AI either: a defeated no-AI mob vanishes at the 20th tick.
     MOVE 0 TO EN-HEALTH(WS-STILL) EN-COOLDOWN(WS-STILL) EN-BURN(WS-STILL)
     PERFORM STEP-STILL 19 TIMES
     MOVE "acceptance US15 18§2.10 No-AI: a dying no-AI mob is there after 19 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-STILL) TO WS-O
     PERFORM CHECK-N
     PERFORM STEP-STILL
     MOVE "acceptance US15 18§2.10 No-AI: and gone after the 20th" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-STILL) TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 STEP-FREE.
     CALL "MOB-STEP" USING WS-FREE.
 STEP-STILL.
     CALL "MOB-STEP" USING WS-STILL.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-2-10.
 COPY CORETEST.
 COPY MOBSPTEST.
