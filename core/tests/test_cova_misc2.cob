*> Implementation test (coverage lane A; docs/protocol/21 section 5.5, 44 part 4 section 12; core/src/mob-21-5.cob, mob-21-hunt.cob, mob-19-13.cob): a piglin brute hit by a player targets it, the
*> piglin hunt step ignores a row that is no standard mob, does nothing when its table is full and when the piglin already has a target, and a scared armadillo whose danger memory runs out
*> unrolls (state 3 with 30 ticks).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-MISC2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY HUNT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-WALK                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE 100 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 100 TO WS-Z
*>   A piglin brute hit by a player.
     MOVE "minecraft:piglin_brute" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-TARGET(WS-ROW)
     CALL "NETHER-HURT" USING WS-ROW WS-PLAYER
     MOVE "test cova misc2 a piglin brute hit by a player takes it as its target" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE EN-TARGET(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The hunt step: a row that is no standard mob (the player's tracker row) is left alone.
     CALL "PIGLIN-HUNT-STEP" USING WS-PROW
     MOVE "test cova misc2 the hunt step of a row that is no standard mob does nothing" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-PROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   An adult piglin with a full hunt table does nothing.
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = 120
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX
         MOVE 900000 TO PH-ID(WS-I)
         ADD WS-I TO PH-ID(WS-I)
     END-PERFORM
     CALL "PIGLIN-HUNT-STEP" USING WS-ROW
     MOVE "test cova misc2 a piglin cannot join a full hunt table" TO WS-CASE
     MOVE 0 TO WS-E
     CALL "PH-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE WS-SLOT TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PH-MAX
         MOVE 0 TO PH-ID(WS-I)
     END-PERFORM
*>   With a slot, an expired timer and a target the step ends before it looks for hoglins.
     CALL "PIGLIN-HUNT-STEP" USING WS-ROW
     CALL "PH-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0 TO PH-TIMER(WS-SLOT)
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW)
     CALL "PIGLIN-HUNT-STEP" USING WS-ROW
     MOVE "test cova misc2 a piglin with a target keeps it (the hunt step ends early)" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE EN-TARGET(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A scared armadillo whose danger memory runs out this tick unrolls.
     MOVE "minecraft:armadillo" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = 140
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 2 TO EN-ARMA(WS-ROW)
     MOVE 1 TO EN-DANGER(WS-ROW)
     MOVE 7 TO EN-ARMA-SCAN(WS-ROW)
     CALL "ARMADILLO-TICK" USING WS-ROW WS-WALK
     MOVE "test cova misc2 a scared armadillo with the memory gone is unrolling (state 3)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE EN-ARMA(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A scared armadillo with danger around peeks and re-rolls its peek timer (the removed paragraphs are programs now).
     MOVE 2 TO EN-ARMA(WS-ROW)
     MOVE 90 TO EN-DANGER(WS-ROW)
     MOVE 0 TO EN-ARMA-AROUND(WS-ROW)
     MOVE 0 TO EN-ARMA-PEEK(WS-ROW)
     MOVE 1 TO EN-ON-GROUND(WS-ROW)
     CALL "ARMADILLO-TICK" USING WS-ROW WS-WALK
     MOVE "test cova misc2 a scared armadillo with danger around draws a new peek time (150 to 450)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-ARMA-PEEK(WS-ROW) >= 150 AND EN-ARMA-PEEK(WS-ROW) <= 450
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-MISC2.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
