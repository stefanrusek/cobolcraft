*> Implementation test of core/src/health.cob (task T500; standin-content §10.4, §10.6, §10.7): the
*> paths the US7 acceptance and contract tests leave unexecuted. A player killed by another player's
*> attack gets the death message with both names (cobolcraft.death.player [victim, attacker]); an
*> Attack does nothing from a dead attacker, on an unknown entity id, on a ground item, on the
*> attacker itself, on a player in another dimension or on a dead player; Client Command does nothing
*> for an alive player or an action other than 0. Alice (entity 1) and Bobby (entity 2) are survival
*> with the starting items, 2 blocks apart at y 101.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HEALTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ALICE-ROW           BINARY-LONG.
 01 WS-BOB-ROW             BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ZX                  BINARY-LONG VALUE 0.
 01 WS-ZY                  BINARY-LONG VALUE 0.
 01 WS-ZZ                  BINARY-LONG VALUE 0.
 01 WS-ZFACE               BINARY-LONG VALUE 0.
 01 WS-ZSEQ                BINARY-LONG VALUE 0.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-BX                  FLOAT-LONG VALUE 22.5.
 01 WS-FY                  FLOAT-LONG VALUE 101.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE -90.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ALICE-ROW
     MOVE CN-PLAYER(WS-BOB) TO WS-BOB-ROW
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-BX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT

     MOVE "test health an Attack on an unknown entity id does nothing" TO TL-CASE
     MOVE 99 TO WS-TARGET
     PERFORM ATTACK-QUIET

     MOVE "test health an Attack on a ground item does nothing" TO TL-CASE
     MOVE 5 TO WS-ACTION
     CALL "TEST-ACTION" USING WS-BOB WS-ACTION WS-ZX WS-ZY WS-ZZ WS-ZFACE WS-ZSEQ
     MOVE 3 TO WS-TARGET
     PERFORM ATTACK-QUIET

     MOVE "test health an Attack on the attacker itself does nothing" TO TL-CASE
     MOVE 1 TO WS-TARGET
     PERFORM ATTACK-QUIET

     MOVE "test health an Attack on a player in another dimension does nothing" TO TL-CASE
     MOVE 2 TO PL-DIM(WS-BOB-ROW) EN-DIM(PL-ENTITY-ROW(WS-BOB-ROW))
     MOVE 2 TO WS-TARGET
     PERFORM ATTACK-QUIET
     MOVE 1 TO PL-DIM(WS-BOB-ROW) EN-DIM(PL-ENTITY-ROW(WS-BOB-ROW))

     MOVE "test health a player killed by another player's attack gets the death message "
         & "cobolcraft.death.player with the victim's and the attacker's names" TO TL-CASE
     MOVE 1 TO PL-HEALTH(WS-BOB-ROW)
     CALL "TEST-ATTACK" USING WS-ALICE WS-TARGET
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2 | health 0 food 24 | kill 2 cobolcraft.death."
         & "player(Bobby,Alice) | chat cobolcraft.death.player(Bobby,Alice)" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT

     MOVE "test health an Attack on a dead player does nothing" TO TL-CASE
     PERFORM ATTACK-QUIET

     MOVE "test health an Attack from a dead player does nothing" TO TL-CASE
     MOVE 1 TO WS-TARGET
     CALL "TEST-ATTACK" USING WS-BOB WS-TARGET
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test health Client Command with an action other than 0 does not respawn a dead player"
         TO TL-CASE
     MOVE 1 TO WS-ACTION
     CALL "TEST-CLIENT-COMMAND" USING WS-BOB WS-ACTION
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     PERFORM CHECK

     MOVE "test health Client Command PERFORM_RESPAWN from an alive player does nothing"
         TO TL-CASE
     MOVE 0 TO WS-ACTION
     CALL "TEST-CLIENT-COMMAND" USING WS-ALICE WS-ACTION
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM CHECK
     STOP RUN.

*> Alice attacks entity WS-TARGET; nobody is sent anything.
 ATTACK-QUIET.
     CALL "TEST-ATTACK" USING WS-ALICE WS-TARGET
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     IF WS-TEXT NOT = SPACES
         MOVE WS-TEXT TO TL-OBSERVED
     END-IF
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     IF WS-TEXT NOT = SPACES
         MOVE WS-TEXT TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HEALTH.

 COPY CORETEST.
