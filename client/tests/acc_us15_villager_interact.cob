*> Acceptance test, the client half of right clicking a merchant (docs/protocol/05c 0x1A Interact, 40-menus-5 section 2.1; lane 002-lane-villagers, T12102): pressing the right button
*> while the look ray meets a mob within reach sends Interact (main hand, the entity id, the interaction point, the sneak state) and no Use Item On; a mob out of reach sends no Interact. The server half (the menu opening) is acc_us15_merchant_interact in core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-INTERACT.
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
 01 WS-BX                  BINARY-LONG VALUE 0.
 01 WS-BY                  BINARY-LONG VALUE 11.
 01 WS-BZ                  BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 7 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE 20 TO WS-ID
     MOVE 0.5 TO WS-X
     MOVE 3.0 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "T" TO TL-MODE
     PERFORM PRESS-RIGHT
     MOVE "acceptance US15 05c 0x1A right button on a mob 2.5 blocks ahead sends Interact (entity 20, main hand, point 0, not sneaking)" TO TL-CASE
     MOVE "1a14000000" TO TL-EXPECTED
     MOVE WS-TEXT(1:10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 05c 0x1A the right button on a mob sends nothing but the Interact" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(11:20) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5.0 TO WS-Z
     CALL "TEST-TELEPORT-ENTITY" USING CLIENT-STATE WS-CONN WS-ID WS-X WS-Y WS-Z WS-GROUND
     PERFORM PRESS-RIGHT
     MOVE "acceptance US15 05c 0x1A a mob out of reach gets no Interact" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:10) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PRESS-RIGHT.
     CALL "TEST-RIGHT" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     .
 END PROGRAM ACC-US15-VILLAGER-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RIGHT.
*> USING CLIENT-STATE: one CL-STEP with the right button going down, then one with it going up.
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
     MOVE CC-BUTTON-RIGHT TO WS-A
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     GOBACK.
 END PROGRAM TEST-RIGHT.
 COPY CLTEST.
