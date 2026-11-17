*> Implementation test (coverage lane A; docs/protocol/21 section 8.6, 44 part 9 section 2; core/src/thrown-44d.cob): a rocket that cannot be spawned (full projectile table), a rocket attached to
*> a player that explodes with a star (the player is hurt), a victim hurt on the thrower's account, and the explosion and step of a row that is no rocket.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-FIREWORK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-VTYPE               BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 1.
 01 WS-STARS               BINARY-LONG VALUE 1.
 01 WS-ATTACHED            BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-AMOUNT              BINARY-LONG VALUE 3000.
 01 WS-H0                  BINARY-LONG.
 01 WS-HP                  FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
*>   No free projectile slot: no rocket.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 900000 TO PJ-ENT(WS-I)
         ADD WS-I TO PJ-ENT(WS-I)
     END-PERFORM
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-NONE WS-NONE2 WS-ROW
     MOVE "test cova firework a rocket cannot be spawned while the projectile table is full" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         MOVE 0 TO PJ-ENT(WS-I)
     END-PERFORM
*>   A rocket attached to the player explodes with one star: the player is hurt (D = 7).
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-ATTACHED
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-ATTACHED WS-NONE WS-ROW
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "FIREWORK-EXPLODE" USING WS-ROW
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     MOVE "test cova firework a rocket attached to the player with a star hurts the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HP < 20
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A rocket launched by the player hurts a villager on the player's account.
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-VTYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-OWNER
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DURATION WS-STARS WS-NONE WS-OWNER WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE EN-HEALTH(WS-VROW) TO WS-H0
     MOVE 0 TO EN-HURT(WS-VROW)
     CALL "FIREWORK-HURT" USING WS-SLOT WS-VROW WS-NONE WS-AMOUNT
     MOVE "test cova firework a victim of the thrower's rocket loses the 3 points" TO WS-CASE
     COMPUTE WS-E = WS-H0 - 3
     MOVE EN-HEALTH(WS-VROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Rows that are no rockets are left alone.
     CALL "FIREWORK-EXPLODE" USING WS-PROW
     CALL "FIREWORK-STEP" USING WS-PROW
     MOVE "test cova firework the explosion and the step of a row without a rocket do nothing" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-PROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-FIREWORK.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
