*> Acceptance test of US7-4, the client half (standin-content §10.6 death and respawn, §10.7 death
*> screen texts; 08 §10.8.2 "Run Terminated", "Return to Spawn"; docs/protocol/09-cobolcraft-profile.md
*> §3.3 Player Combat Kill 0x45, Client Command 0x0C, Respawn 0x54): Player Combat Kill for the local
*> player opens the death screen with its title, the cause (the packet's message) and the respawn
*> control; Escape does not leave it; the respawn control sends Client Command action 0
*> PERFORM_RESPAWN; Respawn returns to the world screen with the replica emptied (the server sends
*> the world again). A Player Combat Kill naming another entity changes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-DEATH-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-E1                  PIC Z(4)9.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 5.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 1 TO PL-ENTITY-ID
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE "contract/fixtures/wire/play-s2c-45-player-combat-kill.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance US7-4 client half given the Player in the world when Player Combat Kill "
         & "for them arrives then the death screen shows the title, the cause and the respawn "
         & "control" TO TL-CASE
     MOVE "T" TO TL-MODE
     PERFORM SCREEN-TEXT
     MOVE "10 Run Terminated|Alice was halted by an Abend|Return to Spawn" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "US7-4 client half given the death screen when Escape is pressed then the death screen "
         & "stays (only respawning leaves it)" TO TL-CASE
     PERFORM SCREEN-TEXT
     MOVE "10 Run Terminated|Alice was halted by an Abend|Return to Spawn" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-RESPAWN TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US7-4 client half when the respawn control is used then Client Command "
         & "action 0 PERFORM_RESPAWN is sent and the death screen stays until Respawn" TO TL-CASE
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT(1:4) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0c00 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract/fixtures/wire/play-s2c-54-respawn-main.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-s2c-6a-set-health.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE "acceptance US7-4 client half when Respawn (and Set Health 30) arrives then the world "
         & "screen returns (the HUD), in cobolcraft:main, with the old world forgotten until the "
         & "server sends it again" TO TL-CASE
     PERFORM SCREEN-TEXT
     MOVE WS-STATE TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(PL-DIM-NAME) " "
         FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 |||||||||Health 20/20|Food 20/20 cobolcraft:main 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 2 TO PL-ENTITY-ID
     MOVE "contract/fixtures/wire/play-s2c-45-player-combat-kill.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "US7-4 client half given the local player is entity 2 when Player Combat Kill for "
         & "entity 1 arrives then the world screen stays" TO TL-CASE
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SCREEN-TEXT.
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     .
 END PROGRAM ACC-US7-DEATH-SCREEN.
 COPY CLTEST.
