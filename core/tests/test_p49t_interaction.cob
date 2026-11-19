*> The interaction entity (docs/protocol/21 section 8.9.2; lane p49t, T39070): a player's attack stores the attack record (the player, the game time) and the attack is skipped whatever the response flag (it can never be
*> damaged: the entity stays); a right-click stores the interaction record (the player, the game time) and is consumed. INTERACTION-LAST resolves the player of either record (execute on attacker, on target):
*> 0 when the record was never set or the player is not online.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49T-INTERACTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TID                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-WIDTH               FLOAT-LONG VALUE 1.
 01 WS-HEIGHT              FLOAT-LONG VALUE 2.
 01 WS-RESPONSE            BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-WHICH               BINARY-LONG.
 01 WS-WHO                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-TIME                BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     COMPUTE WS-X = PL-X(WS-PLAYER) + 1
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "INTERACTION-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-WIDTH WS-HEIGHT WS-RESPONSE WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-TID
     MOVE 1 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 no attacker before any attack" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 no target before any interaction" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "TEST-ATTACK" USING WS-CONN WS-TID
     COMPUTE WS-NOW = CW-GAME-TIME + CW-TICKS
     MOVE 1 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 the attack is recorded: the attacker is the player" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     CALL "PJ-FIND" USING WS-TID WS-SLOT
     MOVE "acceptance US15 21§8.9.2 the attack record holds the game time of the attack" TO WS-CASE
     MOVE WS-NOW TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(PJ-POSE(WS-SLOT, 1))
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.9.2 the interaction entity is not damaged (still there, health 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-USED(WS-ROW) = 1
         MOVE EN-HEALTH(WS-ROW) TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.9.2 an attack records no interaction" TO WS-CASE
     MOVE 2 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE 0 TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
*>   A right-click: the interaction record; it is consumed (no riding, no other effect).
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-INTERACT" USING WS-CONN WS-TID WS-HAND0 WS-SNEAK0
     COMPUTE WS-NOW = CW-GAME-TIME + CW-TICKS
     MOVE 2 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 the right-click is recorded: the target is the player" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.9.2 the interaction record holds the game time of the click" TO WS-CASE
     MOVE WS-NOW TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(PJ-POSE(WS-SLOT, 2))
     PERFORM CHECK-N
*>   With response true the attack is recorded too and still does no damage.
     CALL "PJ-DROP" USING WS-ROW
     MOVE 1 TO WS-RESPONSE
     CALL "INTERACTION-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-WIDTH WS-HEIGHT WS-RESPONSE WS-ROW
     MOVE EN-ID(WS-ROW) TO WS-TID
     CALL "TEST-ATTACK" USING WS-CONN WS-TID
     MOVE 1 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 response true: the attack is recorded" TO WS-CASE
     MOVE WS-PLAYER TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§8.9.2 response true: the entity is still not damaged" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-USED(WS-ROW) = 1
         MOVE EN-HEALTH(WS-ROW) TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A record of a player who is not online resolves to nobody.
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 999999 TO PJ-I2(WS-SLOT)
     MOVE 1 TO WS-WHICH
     CALL "INTERACTION-LAST" USING WS-ROW WS-WHICH WS-WHO
     MOVE "acceptance US15 21§8.9.2 the attacker who is not online resolves to nobody (0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WHO TO WS-O
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-P49T-INTERACTION.
 COPY CORETEST.
 COPY MOBSPTEST.
