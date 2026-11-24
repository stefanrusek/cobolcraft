*> Acceptance test of the optional fields of the CommonPlayerSpawnInfo that Login and Respawn carry (docs/protocol/57-client-closures-3 section 11;
*> T1765): a fresh player has no previous game mode (wire 0) and no last death location (flag 0); a game mode change stores the old mode as
*> the previous one (wire mode + 1) and leaves it alone when the mode does not change; a death stores the dimension and block position of the death
*> as the last death location (flag 1, the key, the packed position), which survives the respawn and shows in the spawn info of Login and Respawn.
*> Alice joins a cobolcraft world as a creative player at the world spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SPAWN-INFO-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY RULES.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-LINE                PIC X(800).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-MODE                PIC 9.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG VALUE 0.
 01 WS-RESPAWN             BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-SIZE            BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-GAME-MODE           BINARY-LONG.
 01 WS-PREVIOUS            BINARY-LONG.
 01 WS-DEBUG               BINARY-LONG.
 01 WS-FLAT                BINARY-LONG.
 01 WS-DEATH               BINARY-LONG.
 01 WS-DEATH-KEY           PIC X(64).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D1                 PIC 9.
 01 WS-D2                 PIC 9.
 01 WS-D3                 PIC 9.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Y              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE "T" TO TL-MODE

     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given a fresh creative player when the spawn info is built then the previous game mode and the last death are absent" TO TL-CASE
     MOVE "mode 1 previous 0 death 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE Z"gamemode survival Alice" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given a creative player when the mode changes to survival then the previous game mode is creative (wire 2)" TO TL-CASE
     MOVE "mode 0 previous 2 death 0" TO TL-EXPECTED
     PERFORM CHECK

     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given the same mode again when the command runs then the previous game mode is unchanged" TO TL-CASE
     MOVE "mode 0 previous 2 death 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE Z"gamemode adventure Alice" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given a survival player when the mode changes to adventure then the previous game mode is survival (wire 1)" TO TL-CASE
     MOVE "mode 2 previous 1 death 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE Z"gamemode survival Alice" TO WS-LINE
     CALL "CORE-CONSOLE" USING WS-LINE
     MOVE 20.5 TO PL-X(WS-ROW)
     MOVE 101.25 TO PL-Y(WS-ROW)
     MOVE -3.5 TO PL-Z(WS-ROW)
     MOVE CAUSE-FALL TO WS-CAUSE
     MOVE 0 TO PL-HEALTH(WS-ROW)
     CALL "HEALTH-DIE" USING WS-ROW WS-CAUSE WS-ATTACKER
     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given a player who dies at (20.5, 101.25, -3.5) when the spawn info is built then the last death is cobolcraft:main (20, 101, -4)" TO TL-CASE
     MOVE "mode 0 previous 3 death 1 cobolcraft:main 20 101 -4" TO TL-EXPECTED
     PERFORM CHECK

     CALL "TEST-CLIENT-COMMAND" USING WS-ALICE WS-RESPAWN
     PERFORM READ-SPAWN-INFO
     MOVE "acceptance spawn-info-state given the respawn after the death when the spawn info is built then the last death is still there" TO TL-CASE
     MOVE "mode 0 previous 3 death 1 cobolcraft:main 20 101 -4" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*>   The spawn info of Login and Respawn of the player, read back field by field into TL-OBSERVED.
 READ-SPAWN-INFO.
     MOVE PL-MODE(WS-ROW) TO WS-MODE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-SPAWN-INFO-ROW" USING WS-ROW WS-DIM WS-MODE PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-KEY WS-KEY-SIZE WS-KEY-LENGTH
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-GAME-MODE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PREVIOUS
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-DEBUG
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAT
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-DEATH
     MOVE WS-GAME-MODE TO WS-D1
     MOVE WS-PREVIOUS TO WS-D2
     MOVE WS-DEATH TO WS-D3
     MOVE SPACES TO TL-OBSERVED
     IF WS-DEATH = 1
         MOVE SPACES TO WS-DEATH-KEY
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-DEATH-KEY WS-KEY-SIZE WS-KEY-LENGTH
         CALL "PB-GET-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
         MOVE WS-X TO WS-EDIT-X
         MOVE WS-Y TO WS-EDIT-Y
         MOVE WS-Z TO WS-EDIT-Z
         STRING "mode " WS-D1 " previous " WS-D2 " death " WS-D3 " " FUNCTION TRIM(WS-DEATH-KEY) " "
             FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z)
             DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING "mode " WS-D1 " previous " WS-D2 " death " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SPAWN-INFO-STATE.

 COPY CORETEST.
