*> Convergence acceptance test of US16-6 and SC-010 (spec.md US16-6; contracts/world-folder.md): a
*> single-player world folder copied to a server's ./world is served by the server program with every
*> dimension, block change, player record, mob and ground item as the single-player game left them,
*> and a server's world folder copied under saves/ opens as a single-player world as the server left
*> it. The Player is the same name (offline identity) on both sides. The single-player world is set
*> to night first (standin-content §12.4: no mob spawns at night while hostile mobs are off), so the
*> one conjured sodgrazer is the only mob.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-FOLDER-INTERCHANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us16-folder-interchange".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 34.
 01 WS-CONF                PIC X(1024) VALUE "view-distance=2|hostile-mobs=false".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-FOLDER              PIC X(80).
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LOG                 PIC X(4096).
 01 WS-LINE                PIC X(256).
 01 WS-COMMAND             PIC X(256).
 01 WS-SP-SUB              PIC X(1024).
 01 WS-SV-SUB              PIC X(1024).
 01 WS-SP-MAIN             PIC X(256).
 01 WS-SV-MAIN             PIC X(256).
 01 WS-SV-STATE            PIC X(1024).
 01 WS-SP-STATE            PIC X(1024).
 01 WS-BREAK-X             BINARY-LONG.
 01 WS-BREAK-Y             BINARY-LONG.
 01 WS-BREAK-Z             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   The single-player world: night, creative; the turf under the spawn point broken, an item
*>   thrown, a sodgrazer conjured in main; then off to the Subroutine, where a block is broken too.
     MOVE "Origin" TO WS-FOLDER
     MOVE 6 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE "/clock 16001" TO WS-TEXT
     MOVE 12 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE "/mode Alice creative" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     CALL "FI-BREAK-BELOW" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z
     MOVE CC-KEY-Q TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE "/conjure sodgrazer 12 60 12" TO WS-TEXT
     MOVE 27 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE "/supply Alice slag 3" TO WS-TEXT
     MOVE 20 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE 60 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
*>   Seen from (4, 60, 0): far enough from the thrown item not to pick it up.
     MOVE "/relocate Alice at 4 60 0" TO WS-TEXT
     MOVE 25 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-MAIN-TEXT" USING CONVH WS-ALICE WS-SP-MAIN
     MOVE "/relocate Alice at 3 60 3 subroutine" TO WS-TEXT
     MOVE 36 TO WS-LENGTH
     CALL "FI-COMMAND" USING CONVH WS-ALICE WS-TEXT WS-LENGTH WS-LOG
     MOVE 80 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-BREAK-BELOW" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-PLAYER-TEXT" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z WS-SP-SUB
     MOVE "SC-010 setup the single-player world shows the changes before it is quit" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "main: turf 0 sodgrazers 1 loose items 1" TO TL-EXPECTED
     MOVE WS-SP-MAIN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FI-QUIT" USING CONVH WS-ALICE

*>   The folder copied to a server's ./world and served by the server program.
     MOVE SPACES TO WS-COMMAND
     STRING "cp -R " WS-DIR(1:WS-DIR-LENGTH) "/Alice/saves/Origin " WS-DIR(1:WS-DIR-LENGTH)
         "/server/world" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "CV-SERVER-START" USING CONVH WS-CONF
     CALL "CV-JOIN" USING CONVH WS-ALICE CV-PORT
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-PLAYER-TEXT" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z WS-SV-SUB
     MOVE "acceptance US16-6 given a single-player world folder when an operator starts a server "
         & "with it then the Player finds their record (dimension, position, mode, inventory) "
         & "and the extra dimension's block change unchanged" TO TL-CASE
     MOVE WS-SP-SUB TO TL-EXPECTED
     MOVE WS-SV-SUB TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "relocate Alice at 4 60 0 main" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     MOVE 80 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-MAIN-TEXT" USING CONVH WS-ALICE WS-SV-MAIN
     MOVE "acceptance SC-010 the main dimension served from the single-player folder has the "
         & "block change, the mob and the ground item unchanged" TO TL-CASE
     MOVE WS-SP-MAIN TO TL-EXPECTED
     MOVE WS-SV-MAIN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The other way: the server changes the world (a block broken, items supplied), stops; its
*>   folder opened as a single-player world.
     MOVE "supply Alice lucite 7" TO WS-LINE
     CALL "CV-SERVER-CONSOLE" USING CONVH WS-LINE
     CALL "CV-STEP" USING CONVH
     CALL "FI-BREAK-BELOW" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-PLAYER-TEXT" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z WS-SV-STATE
     CALL "CV-SERVER-STOP" USING CONVH
     MOVE SPACES TO WS-COMMAND
     STRING "cp -R " WS-DIR(1:WS-DIR-LENGTH) "/server/world " WS-DIR(1:WS-DIR-LENGTH)
         "/Alice/saves/Imported" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "Imported" TO WS-FOLDER
     MOVE 8 TO WS-FOLDER-LENGTH
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 40 TO WS-COUNT
     CALL "CV-STEPS" USING CONVH WS-COUNT
     CALL "FI-PLAYER-TEXT" USING CONVH WS-ALICE WS-BREAK-X WS-BREAK-Y WS-BREAK-Z WS-SP-STATE
     MOVE "acceptance US16-6 given a server's world folder when it is opened as a single-player "
         & "world then the Player finds it as the server left it: record, inventory, block change"
         TO TL-CASE
     MOVE WS-SV-STATE TO TL-EXPECTED
     MOVE WS-SP-STATE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FI-MAIN-TEXT" USING CONVH WS-ALICE WS-SP-MAIN
     MOVE "acceptance SC-010 the server's folder opened in single-player keeps the mob and the "
         & "ground item" TO TL-CASE
     MOVE "main: turf 0 sodgrazers 1 loose items 1" TO TL-EXPECTED
     MOVE WS-SP-MAIN TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FI-QUIT" USING CONVH WS-ALICE
     STOP RUN.
 END PROGRAM ACC-US16-FOLDER-INTERCHANGE.

*> Test helpers (test infrastructure).
*>   FI-COMMAND USING CONVH, index, text (PIC X(64)), length, log out (PIC X(4096)): the chat
*>     history cleared, the line said in chat, three more frames; the messages received.
*>   FI-BREAK-BELOW USING CONVH, index, x, y, z out: looking straight down, one attack click (a
*>     creative Player breaks at once), a few frames; the block that was aimed at.
*>   FI-PLAYER-TEXT USING CONVH, index, x, y, z, text out (PIC X(1024)): "<dimension> at <x>/<y>/<z>
*>     mode <m> cell <state at x, y, z> slots <item>x<count>..." of the client's replica.
*>   FI-MAIN-TEXT USING CONVH, index, text out (PIC X(256)): "main: turf <state at (4, 53, 8)>
*>     sodgrazers <n> loose items <n>" of the client's replica.
*>   FI-QUIT USING CONVH, index: Escape, Quit World, frames until the title screen.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-COMMAND.
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
     CALL "FI-SAY" USING CONVH L-INDEX L-TEXT L-LENGTH
     CALL "CV-STEPS" USING CONVH WS-THREE
     CALL "CV-CHAT-LOG" USING CONVH L-INDEX L-LOG
     GOBACK.
 END PROGRAM FI-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-BREAK-BELOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-BUTTON-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-BUTTON-UP.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CONVH L-INDEX L-X L-Y L-Z.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 90 TO PL-PITCH
     CALL "CV-STEP" USING CONVH
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE TG-X TO L-X
     MOVE TG-Y TO L-Y
     MOVE TG-Z TO L-Z
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH L-INDEX WS-BUTTON WS-UP
     CALL "CV-STEPS" USING CONVH WS-FIVE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     MOVE 0 TO PL-PITCH
     GOBACK.
 END PROGRAM FI-BREAK-BELOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-PLAYER-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-F1                  PIC -(4)9.9.
 01 WS-F2                  PIC -(4)9.9.
 01 WS-F3                  PIC -(4)9.9.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CONVH L-INDEX L-X L-Y L-Z L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     CALL "WORLD-CELL" USING CLIENT-STATE L-X L-Y L-Z WS-STATE WS-SKY WS-BLOCK
     COMPUTE WS-F1 ROUNDED = PL-X
     COMPUTE WS-F2 ROUNDED = PL-Y
     COMPUTE WS-F3 ROUNDED = PL-Z
     MOVE PL-MODE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     STRING FUNCTION TRIM(PL-DIM-NAME) " at " FUNCTION TRIM(WS-F1) "/" FUNCTION TRIM(WS-F2) "/"
         FUNCTION TRIM(WS-F3) " mode " FUNCTION TRIM(WS-E1) " cell " FUNCTION TRIM(WS-E2)
         " slots" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             STRING " " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FI-PLAYER-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-MAIN-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG VALUE 4.
 01 WS-Y                   BINARY-LONG VALUE 53.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MOBS                BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CONVH.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-TEXT                 PIC X(256).
 PROCEDURE DIVISION USING CONVH L-INDEX L-TEXT.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(L-INDEX)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
     MOVE 0 TO WS-MOBS WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 2
             ADD 1 TO WS-MOBS
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM
     MOVE WS-STATE TO WS-E1
     MOVE WS-MOBS TO WS-E2
     MOVE WS-ITEMS TO WS-E3
     MOVE SPACES TO L-TEXT
     STRING "main: turf " FUNCTION TRIM(WS-E1) " sodgrazers " FUNCTION TRIM(WS-E2)
         " loose items " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM FI-MAIN-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-QUIT.
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
 END PROGRAM FI-QUIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FI-SAY.
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
 END PROGRAM FI-SAY.
