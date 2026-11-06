*> Convergence acceptance test of US16 (spec.md US16-1 to US16-5; client-surface §2 world list;
*> standin-content §16.1 target rule): the Player plays worlds on their own through the client's
*> single-player host (client and core in one process over a memory connection, no server):
*> creating worlds from the world list (name typed, mode chosen), the default server rules and
*> content, every command available to the host (commands acting on another player find nobody; the
*> ban list accepts any valid name), the pause menu pausing, a world quit and opened again as it was
*> left, and a world deleted after confirming.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-SINGLE-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us16-single-player".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LOG                 PIC X(4096).
 01 WS-TEXTS               PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-SAVED-POS           PIC X(64).
 01 WS-POS                 PIC X(64).
 01 WS-SLAG                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-EXISTS              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "CV-STEP" USING CONVH

*>   US16-1 create: title, Single-player, the world list (empty), New World, the name typed over
*>   the default name, creative chosen, Create.
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO WS-E1
     MOVE WL-COUNT TO WS-E2
     MOVE ACT-NEW-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO WS-E3
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70 OR SM-EDIT-NAME-LENGTH = 0
         CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     END-PERFORM
     MOVE "Meadow" TO WS-TEXT
     MOVE 6 TO WS-LENGTH
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TEXT WS-LENGTH
     MOVE ACT-WORLD-MODE TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE WS-ALICE TO CV-HOST
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE "acceptance US16-1 given the client's main menu when the Player opens the single-player "
         & "world list and creates a world named Meadow in creative then they play it" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "list 13 worlds 0 create 14 joined 1 folder Meadow mode 1 hosting 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E4
     MOVE PL-MODE TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "list " FUNCTION TRIM(WS-E1) " worlds " FUNCTION TRIM(WS-E2) " create "
         FUNCTION TRIM(WS-E3) " joined " FUNCTION TRIM(WS-E4) " folder "
         SP-FOLDER(1:SP-FOLDER-LENGTH) " mode " FUNCTION TRIM(WS-E5) " hosting " SP-ACTIVE
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

*>   US16-2: a second world, in survival: the server defaults (hostile mobs off and view distance
*>   2 are the harness's quicker test settings), no separate server, the rules and
*>   content of a server (spawn point, starting inventory, health and food).
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-NEW-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70 OR SM-EDIT-NAME-LENGTH = 0
         CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     END-PERFORM
     MOVE "Prairie" TO WS-TEXT
     MOVE 7 TO WS-LENGTH
     CALL "CV-TYPE" USING CONVH WS-ALICE WS-TEXT WS-LENGTH
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "acceptance US16-2 given the Player opens a single-player world when they play then the "
         & "server's default settings apply with no separate server: the core runs in the client "
         & "over a memory connection" TO TL-CASE
     MOVE "joined 1 memory 1 server 0 listener 0 kind 1 host Alice combat 1 weather-dims 11 "
         & "allow 0 pack 0 description A CobolCraft server" TO TL-EXPECTED
     MOVE CV-SERVER TO WS-E1
     MOVE SP-LISTENER TO WS-E2
     MOVE WS-JOINED TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E3) " memory " CN-MEMORY(CONN-GAME) " server "
         FUNCTION TRIM(WS-E1) " listener " FUNCTION TRIM(WS-E2) " kind " CS-HOST-KIND " host "
         FUNCTION TRIM(CS-HOST-NAME) " combat " CS-PLAYER-COMBAT " weather-dims "
         CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS " allow "
         CS-ALLOW-LIST-ENFORCED " pack " CS-PACK-OFFERED " description "
         FUNCTION TRIM(CS-DESCRIPTION) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US16-2 the single-player world has the server's content and rules: a "
         & "first-time survival Player at the world spawn with the starting inventory, health 30 "
         & "and food 24" TO TL-CASE
     MOVE "mode 0 at 4.5/54.0/8.5 slots 2x64 3x64 4x64 5x64 6x64 7x64 8x64 9x64 10x1 11x1 0x0 "
         & "health 30 food 24" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE PL-MODE TO WS-E1
     CALL "POSITION-TEXT" USING CONVH WS-ALICE WS-POS
     STRING "mode " FUNCTION TRIM(WS-E1) " at " FUNCTION TRIM(WS-POS) " slots"
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE PL-SLOT-ITEM(WS-I) TO WS-E1
         MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
         IF PL-SLOT-COUNT(WS-I) = 0
             MOVE 0 TO WS-E1
         END-IF
         STRING " " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     COMPUTE WS-E1 = PL-HEALTH
     MOVE PL-FOOD TO WS-E2
     STRING " health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US16-3: every command is available to the host; acting on another player finds nobody; the
*>   ban list accepts any valid name.
     MOVE "acceptance US16-3 given a single-player world when the Player uses chat commands then "
         & "every command of the command set is available to them" TO TL-CASE
     MOVE "/howto" TO WS-TEXT
     MOVE 6 TO WS-LENGTH
     MOVE "Commands you may use (35):" TO TL-EXPECTED
     CALL "SP-COMMAND-EXPECT" USING CONVH WS-ALICE WS-TEXT WS-LENGTH TESTLIB-ASSERT
     MOVE "acceptance US16-3 in a world not opened to others the private-message command naming "
         & "another player reports the player-not-found message" TO TL-CASE
     MOVE "/murmur Bobby hello" TO WS-TEXT
     MOVE 19 TO WS-LENGTH
     MOVE "No player named Bobby is online" TO TL-EXPECTED
     CALL "SP-COMMAND-EXPECT" USING CONVH WS-ALICE WS-TEXT WS-LENGTH TESTLIB-ASSERT
     MOVE "acceptance US16-3 in a world not opened to others the disconnect-player command naming "
         & "another player reports the player-not-found message" TO TL-CASE
     MOVE "/eject Bobby" TO WS-TEXT
     MOVE 12 TO WS-LENGTH
     CALL "SP-COMMAND-EXPECT" USING CONVH WS-ALICE WS-TEXT WS-LENGTH TESTLIB-ASSERT
     MOVE "acceptance US16-3 the ban command naming a valid offline name records the ban"
         TO TL-CASE
     MOVE "/bar Bobby" TO WS-TEXT
     MOVE 10 TO WS-LENGTH
     MOVE "Barred Bobby" TO TL-EXPECTED
     CALL "SP-COMMAND-EXPECT" USING CONVH WS-ALICE WS-TEXT WS-LENGTH TESTLIB-ASSERT
     MOVE "acceptance US16-3 the ban list then holds the offline name" TO TL-CASE
     MOVE "/barlist" TO WS-TEXT
     MOVE 8 TO WS-LENGTH
     MOVE "Barred (1): Bobby" TO TL-EXPECTED
     CALL "SP-COMMAND-EXPECT" USING CONVH WS-ALICE WS-TEXT WS-LENGTH TESTLIB-ASSERT

*>   US16-4: the pause menu pauses the world (no core tick while it is open).
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE SP-TICKS TO WS-TICKS
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     MOVE "acceptance US16-4 given a single-player world not opened to others when the Player "
         & "opens the pause menu then the game is paused: no tick in 2 seconds" TO TL-CASE
     MOVE "screen 9 paused 1 ticks 0" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     COMPUTE WS-E2 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " SP-PAUSED " ticks " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-RESUME TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-TICKS TO WS-TICKS
     MOVE 20 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     MOVE "acceptance US16-4 back in the world the game runs again: 20 ticks in 20 frames"
         TO TL-CASE
     MOVE "screen 5 paused 0 ticks 20" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     COMPUTE WS-E2 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " SP-PAUSED " ticks " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US16-5: changes made (an item supplied, the time set, a block broken in creative, the Player
*>   moved by falling into the hole) are there after quitting to the menu and opening it again.
     MOVE "/supply Alice slag 5" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "SP-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE "/clock 20000" TO WS-TEXT
     MOVE 12 TO WS-LENGTH
     CALL "SP-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE "/mode Alice creative" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "SP-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE 90 TO PL-PITCH
     CALL "CV-STEP" USING CONVH
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-KIND
     MOVE "/mode Alice survival" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "SP-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     MOVE 4 TO WS-X
     MOVE 53 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     CALL "POSITION-TEXT" USING CONVH WS-ALICE WS-SAVED-POS
     MOVE "US16-5 setup the turf under the spawn point broken in creative, the Player fallen "
         & "into the hole" TO TL-CASE
     MOVE "cell 0 at 4.5/53.0/8.5" TO TL-EXPECTED
     MOVE WS-STATE TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "cell " FUNCTION TRIM(WS-E1) " at " FUNCTION TRIM(WS-SAVED-POS) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE
     MOVE "US16-5 setup quitting the world returns to the title screen and ends hosting"
         TO TL-CASE
     MOVE "screen 1 hosting 0" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " hosting " SP-ACTIVE DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Open Prairie again from the world list (worlds in folder byte order: Meadow, Prairie).
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE "acceptance US16-1 the world list shows both worlds by name" TO TL-CASE
     MOVE "count 2 Meadow Prairie" TO TL-EXPECTED
     MOVE WL-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "count " FUNCTION TRIM(WS-E1) " " WL-NAME(1)(1:WL-NAME-LENGTH(1)) " "
         WL-NAME(2)(1:WL-NAME-LENGTH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     MOVE 0 TO WS-SLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0 AND PL-SLOT-ITEM(WS-I) = 17
             ADD PL-SLOT-COUNT(WS-I) TO WS-SLAG
         END-IF
     END-PERFORM
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     CALL "POSITION-TEXT" USING CONVH WS-ALICE WS-POS
     MOVE "acceptance US16-5 given the Player quit a single-player world to the menu when they "
         & "open it again then it is as they left it: block, position, inventory, mode, time"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "joined 1 folder Prairie cell 0 at " FUNCTION TRIM(WS-SAVED-POS)
         " slag 5 mode 0 time 1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE WS-SLAG TO WS-E3
     MOVE PL-MODE TO WS-E4
     MOVE 0 TO WS-E5
     IF PL-TIME >= 20000 AND PL-TIME < 20200
         MOVE 1 TO WS-E5
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " folder " SP-FOLDER(1:SP-FOLDER-LENGTH) " cell "
         FUNCTION TRIM(WS-E2) " at " FUNCTION TRIM(WS-POS) " slag " FUNCTION TRIM(WS-E3)
         " mode " FUNCTION TRIM(WS-E4) " time " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

*>   US16-1 open and delete: Meadow opened from the list (creative as created), quit, then deleted
*>   after confirming.
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE "acceptance US16-1 the Player opens a world from the world list" TO TL-CASE
     MOVE "joined 1 folder Meadow mode 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE PL-MODE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " folder " SP-FOLDER(1:SP-FOLDER-LENGTH) " mode "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT-MENU" USING CONVH WS-ALICE

     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-DELETE-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE SM-SCREEN TO WS-E1
     MOVE ACT-CONFIRM-DELETE TO WS-ACTION
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE SPACES TO WS-PATH
     STRING WS-DIR(1:WS-DIR-LENGTH) "/Alice/saves/Meadow/level.dat" DELIMITED BY SIZE
         INTO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-EXISTS
     MOVE "acceptance US16-1 the Player deletes a world after confirming: it leaves the list and "
         & "its folder is gone" TO TL-CASE
     MOVE "confirm 15 screen 13 count 1 Prairie gone 1" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E2
     MOVE WL-COUNT TO WS-E3
     COMPUTE WS-E4 = 1 - WS-EXISTS
     MOVE SPACES TO TL-OBSERVED
     STRING "confirm " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " count "
         FUNCTION TRIM(WS-E3) " " WL-NAME(1)(1:WL-NAME-LENGTH(1)) " gone " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-SINGLE-PLAYER.

*> Test helpers (test infrastructure).
*>   SP-QUIT-MENU USING CONVH, index: Escape (the pause menu), Quit World, frames until the title.
*>   SP-COMMAND USING CONVH, index, text (PIC X(64)), length, log out (PIC X(4096)): the client's
*>     chat history cleared, the line said in chat, three more frames; log: the messages received.
*>   SP-COMMAND-EXPECT USING CONVH, index, text, length, TESTLIB-ASSERT (TL-CASE, TL-EXPECTED set):
*>     SP-COMMAND, then asserts that one received message contains TL-EXPECTED.
*>   POSITION-TEXT USING CONVH, index, text out (PIC X(64)): "<x>/<y>/<z>" (1 decimal).
*>   FILE-EXISTS USING path (PIC X(256), space-padded), exists out (1 or 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-QUIT-MENU.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-ESCAPE.
 01 WS-ACTION              BINARY-LONG VALUE ACT-QUIT-WORLD.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-TITLE.
 01 WS-REACHED             BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX.
     CALL "CV-KEY" USING CONVH L-INDEX WS-KEY
     CALL "CV-CLICK" USING CONVH L-INDEX WS-ACTION WS-ARG WS-FOUND
     CALL "CV-UNTIL-SCREEN" USING CONVH L-INDEX WS-SCREEN WS-REACHED
     MOVE 0 TO CV-HOST
     GOBACK.
 END PROGRAM SP-QUIT-MENU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-COMMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-LOG                  PIC X(4096).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH L-LOG.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO CH-COUNT
     CALL "SP-SAY" USING CONVH L-INDEX L-TEXT L-LENGTH
     CALL "CV-STEPS" USING CONVH WS-THREE
     CALL "CV-CHAT-LOG" USING CONVH L-INDEX L-LOG
     GOBACK.
 END PROGRAM SP-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-COMMAND-EXPECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOG                 PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 COPY TESTLIB.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH TESTLIB-ASSERT.
     CALL "SP-COMMAND" USING CONVH L-INDEX L-TEXT L-LENGTH WS-LOG
     MOVE FUNCTION LENGTH(FUNCTION TRIM(TL-EXPECTED TRAILING)) TO WS-LENGTH
     MOVE 0 TO WS-COUNT
     INSPECT WS-LOG TALLYING WS-COUNT FOR ALL TL-EXPECTED(1:WS-LENGTH)
     MOVE "T" TO TL-MODE
     IF WS-COUNT > 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-LOG TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM SP-COMMAND-EXPECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POSITION-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     MOVE SPACES TO L-TEXT
     STRING FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/" FUNCTION TRIM(WS-F3)
         DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM POSITION-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FILE-EXISTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(257).
 01 WS-INFO                PIC X(16).
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-EXISTS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-EXISTS.
     MOVE LOW-VALUES TO WS-PATH
     MOVE FUNCTION TRIM(L-PATH) TO WS-PATH(1:FUNCTION LENGTH(FUNCTION TRIM(L-PATH)))
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO RETURNING WS-RC
     MOVE 0 TO L-EXISTS
     IF WS-RC = 0
         MOVE 1 TO L-EXISTS
     END-IF
     GOBACK.
 END PROGRAM FILE-EXISTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-SAY.
*> USING CONVH, index, text (PIC X(64)), length: CV-SAY, typing at most 30 characters per frame
*> (a frame takes at most 32 typed characters, CLSTATE IN-TEXT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-T                   BINARY-LONG VALUE CC-KEY-T.
 01 WS-ENTER               BINARY-LONG VALUE CC-KEY-ENTER.
 01 WS-FROM                BINARY-LONG.
 01 WS-PART                PIC X(64).
 01 WS-PART-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CONVH.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT L-LENGTH.
     CALL "CV-KEY" USING CONVH L-INDEX WS-T
     PERFORM VARYING WS-FROM FROM 1 BY 30 UNTIL WS-FROM > L-LENGTH
         COMPUTE WS-PART-LENGTH = FUNCTION MIN(30, L-LENGTH - WS-FROM + 1)
         MOVE SPACES TO WS-PART
         MOVE L-TEXT(WS-FROM:WS-PART-LENGTH) TO WS-PART
         CALL "CV-TYPE" USING CONVH L-INDEX WS-PART WS-PART-LENGTH
     END-PERFORM
     CALL "CV-KEY" USING CONVH L-INDEX WS-ENTER
     GOBACK.
 END PROGRAM SP-SAY.
