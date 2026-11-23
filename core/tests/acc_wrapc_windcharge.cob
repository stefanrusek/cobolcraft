*> Acceptance test, the wind charge thrown by a player (docs/protocol/44-residual-mob-questions-8 section 8, 17 section 3.15; wrap lane C, T24214): Use Item with a wind_charge in the main hand
*> throws one charge from the player's eyes at speed 1.5 along the look direction (no gravity, no drag), owned by the player, and uses one item up (a creative player keeps the stack);
*> the charge is the player kind of 21 section 8.18 (PJ-KIND 42, PJ-I1 0: radius 1.2, knockback multiplier 1.22).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPC-WINDCHARGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROJSTATE.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
*>   Test players join in creative (which keeps the stack); this one plays in survival.
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE "wind_charge" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "wind_charge" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, WS-SLOT)
     MOVE 0 TO PL-YAW(WS-ROW) PL-PITCH(WS-ROW)
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM FIND-CHARGE
     MOVE "N" TO TL-MODE
     MOVE "acceptance 44-8 8 Use Item with a wind charge throws one charge" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 44-8 8 the charge is the player's kind (PJ-KIND 42, PJ-I1 0)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 42 * 10
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PJ > 0
         COMPUTE TL-OBSERVED-N = PJ-KIND(WS-PJ) * 10 + PJ-I1(WS-PJ)
     END-IF
     PERFORM CHECK
     MOVE "acceptance 44-8 8 its owner is the thrower" TO TL-CASE
     MOVE PL-ENTITY-ID(WS-ROW) TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PJ > 0
         MOVE PJ-OWNER(WS-PJ) TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     MOVE "acceptance 17 3.15 the speed is 1.5 (in thousandths, within the inaccuracy)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-FOUND) * EN-VX(WS-FOUND) + EN-VY(WS-FOUND) * EN-VY(WS-FOUND)
             + EN-VZ(WS-FOUND) * EN-VZ(WS-FOUND))
         COMPUTE WS-MILLI = WS-SPEED * 1000
         IF WS-MILLI > 1400 AND WS-MILLI < 1600
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     PERFORM CHECK
     MOVE "acceptance 17 3.15 it flies along the look direction (+z for yaw 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0 AND EN-VZ(WS-FOUND) > 1.0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK
     MOVE "acceptance 17 3.15 a survival player uses one wind charge up (2 became 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, WS-SLOT) TO TL-OBSERVED-N
     PERFORM CHECK
     STOP RUN.

*> FIND-CHARGE: the tracker row of the wind charges (WS-FOUND, the last) and their number (WS-COUNT); WS-PJ the projectile slot of the last one (0 none).
 FIND-CHARGE.
     MOVE 0 TO WS-FOUND WS-COUNT WS-PJ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TYPE
             ADD 1 TO WS-COUNT
             MOVE WS-I TO WS-FOUND
             CALL "PJ-FIND" USING EN-ID(WS-I) WS-PJ
         END-IF
     END-PERFORM.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-WRAPC-WINDCHARGE.
 COPY CORETEST.
 COPY BETEST.
