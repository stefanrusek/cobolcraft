*> Acceptance test of US7-5, the client half (client-surface §3 "Break / attack: Left mouse
*> button"; standin-content §3 entity sizes, §10.4 attacks: a player or mob within 4 blocks of the
*> eye; docs/protocol/09-cobolcraft-profile.md §3.3 Attack 0x01): pressing the left button while the
*> look ray from the eye (1.6 above the feet) meets a player or mob entity's collision box within 4
*> blocks, nearer than any block, sends Attack with that entity's id and starts no break. A ground
*> item, an entity out of reach or beside the ray, or one behind a block, is not attacked.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 11.2.
 01 WS-Z                   FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG VALUE 100.5.
 01 WS-FAR-Z               FLOAT-LONG VALUE 100.5.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-BX                  BINARY-LONG VALUE 0.
 01 WS-BY                  BINARY-LONG VALUE 11.
 01 WS-BZ                  BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
*>   Survival, the eye at (0.5, 11.6, 0.5) looking straight along +Z (yaw 0, pitch 0); nothing but
*>   air in front at eye height.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 7 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-abend.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 1 TO WS-ID
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-FAR WS-Y WS-FAR-Z WS-GROUND
     MOVE 20 TO WS-ID
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-FAR WS-Y WS-FAR-Z WS-GROUND
     MOVE 21 TO WS-ID
     MOVE 0.5 TO WS-X
     MOVE 3.0 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     PERFORM PRESS-LEFT
     MOVE "acceptance US7-5 client half given an abend (entity 21) 2.5 blocks ahead at eye height "
         & "when the left button is pressed then Attack with entity id 21 is sent and no break "
         & "starts" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0115" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 5.0 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-LEFT
     MOVE "US7-5 client half given the abend's box starts 4.125 blocks from the eye when the left "
         & "button is pressed then nothing is sent (out of reach)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3.5 TO WS-X
     MOVE 3.0 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-LEFT
     MOVE "US7-5 client half given the abend 3 blocks to the side of the look ray when the left "
         & "button is pressed then nothing is sent" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-FAR WS-Y WS-FAR-Z WS-GROUND
     MOVE 1 TO WS-ID
     MOVE 0.5 TO WS-X
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-LEFT
     MOVE "acceptance US7-5 client half given another player (operator entity 1) ahead within "
         & "reach when the left button is pressed then Attack with entity id 1 is sent" TO TL-CASE
     MOVE "0101" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-FAR WS-Y WS-FAR-Z WS-GROUND
     MOVE 20 TO WS-ID
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-LEFT
     MOVE "acceptance US7-5 client half given a sodgrazer (entity 20) ahead within reach when "
         & "the left button is pressed then Attack with entity id 20 is sent" TO TL-CASE
     MOVE "0114" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-FAR WS-Y WS-FAR-Z WS-GROUND
     MOVE 30 TO WS-ID
     MOVE 11.5 TO WS-Y
     MOVE 2.0 TO WS-Z
     CALL "TEST-ADD-ITEM" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-COUNT WS-ITEM
     PERFORM PRESS-LEFT
     MOVE "US7-5 client half given a ground item ahead at eye height when the left button is "
         & "pressed then nothing is sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-REMOVE-ENTITY" USING CLIENT-STATE WS-CONN WS-ID
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-STATE
     MOVE 21 TO WS-ID
     MOVE 11.2 TO WS-Y
     MOVE 3.5 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-LEFT
     MOVE "US7-5 client half given greystone at (0, 11, 2) between the eye and the abend when the "
         & "left button is pressed then the block's break starts (start destroy) instead of an "
         & "attack" TO TL-CASE
     MOVE "2900" TO TL-EXPECTED
     MOVE WS-TEXT(1:4) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PRESS-LEFT.
     CALL "TEST-LEFT" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .
 END PROGRAM ACC-US7-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LEFT.
*> USING CLIENT-STATE: one CL-STEP with the left button going down, then one with it going up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE WS-EVENT
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     MOVE CC-BUTTON-LEFT TO WS-A
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     GOBACK.
 END PROGRAM TEST-LEFT.
 COPY CLTEST.
