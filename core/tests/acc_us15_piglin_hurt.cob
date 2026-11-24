*> Acceptance test, piglin throw direction, hurt while admiring, conversion while admiring (docs/protocol/44-residual-mob-questions-6-nether.md section 3.4 and
*> BehaviorUtils.throwItem, 21 section 5.5.1; lane 002-lane-mobsb2, T7103): the barter drop flies toward the giving player at 0.3 per axis of the unit vector to
*> the player + 1 block up; damage while admiring ends the admiring, sets the 400 tick disabling and loses the ingot; a conversion while admiring drops the ingot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PIGLIN-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRWORLD.
 COPY RULES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-HELD                PIC X(24).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MILLI               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "T" TO TL-MODE
*>   A piglin five blocks east of the player, admiring a ingot given by the player.
     COMPUTE WS-X = PL-X(WS-ROW) + 5
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PROW
     MOVE "gold_ingot" TO WS-HELD
     CALL "PIGLIN-USE" USING WS-ROW WS-PROW WS-HELD WS-USED
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-LAST
     PERFORM 119 TIMES
         CALL "PIGLIN-TICK" USING WS-PROW
     END-PERFORM
     PERFORM FIND-NEWEST-ITEM
     MOVE "acceptance US15 44§3.4 the barter drop flies toward the player: vx -294/1000, vy about 59/1000, vz 0" TO TL-CASE
     MOVE "-294 0" TO TL-EXPECTED
     COMPUTE WS-MILLI = EN-VX(WS-DONE) * 1000
     MOVE WS-MILLI TO WS-E1
     COMPUTE WS-MILLI = EN-VZ(WS-DONE) * 1000
     MOVE WS-MILLI TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
*>   Hurt while admiring.
     CALL "PIGLIN-USE" USING WS-ROW WS-PROW WS-HELD WS-USED
     MOVE 6 TO WS-N
     CALL "HEALTH-MOB-DAMAGE" USING WS-PROW WS-ONE CAUSE-PLAYER WS-ROW
     MOVE "acceptance US15 44§3.4 damage ends the admiring and sets the 400 tick disabling" TO TL-CASE
     MOVE "0 400" TO TL-EXPECTED
     MOVE EN-ADMIRE(WS-PROW) TO WS-E1
     MOVE EN-ADMIRE-OFF(WS-PROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     CALL "PIGLIN-USE" USING WS-ROW WS-PROW WS-HELD WS-USED
     MOVE "acceptance US15 44§3.4 a piglin with admiring disabled refuses an ingot" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE WS-USED TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     PERFORM CHECK
*>   Conversion while admiring drops the ingot.
     MOVE 2 TO BW-DIFFICULTY
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-PROW
     CALL "PIGLIN-USE" USING WS-ROW WS-PROW WS-HELD WS-USED
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-LAST
     MOVE 301 TO EN-ZOMBIFY(WS-PROW)
     CALL "PIGLIN-ZOMBIFY" USING WS-PROW WS-DONE
     PERFORM COUNT-ITEMS
     COMPUTE WS-I = WS-N - WS-LAST
     MOVE "acceptance US15 21§5.5 converting while admiring drops the ingot as one item" TO TL-CASE
     MOVE "1 1" TO TL-EXPECTED
     MOVE WS-DONE TO WS-E1
     MOVE WS-I TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.

 FIND-NEWEST-ITEM.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ITEM-TYPE
             MOVE WS-I TO WS-DONE
         END-IF
     END-PERFORM.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-PIGLIN-HURT.
 COPY CORETEST.
