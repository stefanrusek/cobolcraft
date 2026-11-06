*> Acceptance test of US2-1 on the client (client-surface.md §2 servers.dat; data-model §13 server
*> list entry): given the client started, when the Player adds, edits and removes server entries on
*> the server list screen (clicks and typing through CL-STEP), then the list shows them, and after a
*> restart (a new CLIENT-STATE on the same game directory) the entries are still there.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US2-SERVER-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-NAMES               PIC X(1024).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-us2-list"
     PERFORM START-CLIENT
     MOVE ACT-MULTIPLAYER TO WS-ACTION
     PERFORM CLICK
     PERFORM LIST-NAMES
     MOVE "acceptance US2-1 given the client started when the Player opens multiplayer then the "
         & "server list is shown, empty" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2:" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "Home" TO WS-TEXT
     MOVE 4 TO WS-LENGTH
     PERFORM ADD-ENTRY
     MOVE "localhost:25570" TO WS-TEXT
     MOVE 15 TO WS-LENGTH
     PERFORM TYPE-ADDRESS-DONE
     MOVE "Other" TO WS-TEXT
     MOVE 5 TO WS-LENGTH
     PERFORM ADD-ENTRY
     MOVE "example.org" TO WS-TEXT
     MOVE 11 TO WS-LENGTH
     PERFORM TYPE-ADDRESS-DONE
     MOVE "Third" TO WS-TEXT
     MOVE 5 TO WS-LENGTH
     PERFORM ADD-ENTRY
     MOVE "example.net" TO WS-TEXT
     MOVE 11 TO WS-LENGTH
     PERFORM TYPE-ADDRESS-DONE
     PERFORM LIST-NAMES
     MOVE "acceptance US2-1 given the server list when the Player adds Home, Other and Third "
         & "(name and address) then the list shows them" TO TL-CASE
     MOVE "2:Home|Other|Third|" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Edit the first entry: a new name.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     PERFORM CLICK
     MOVE 0 TO WS-ARG
     MOVE ACT-EDIT TO WS-ACTION
     PERFORM CLICK
     MOVE "acceptance US2-1 when the Player edits an entry then its name and address fill the "
         & "edit screen" TO TL-CASE
     MOVE "Home localhost:25570" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING SM-EDIT-NAME(1:SM-EDIT-NAME-LENGTH) " " SM-EDIT-ADDR(1:SM-EDIT-ADDR-LENGTH)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-FIELD-NAME TO WS-ACTION
     PERFORM CLICK
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 4 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     MOVE "Base" TO WS-TEXT
     MOVE 4 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TEXT WS-LENGTH
     MOVE ACT-DONE TO WS-ACTION
     PERFORM CLICK
*>   Remove the second entry.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     PERFORM CLICK
     MOVE 0 TO WS-ARG
     MOVE ACT-REMOVE TO WS-ACTION
     PERFORM CLICK
     PERFORM LIST-NAMES
     MOVE "acceptance US2-1 when the Player renames Home to Base and removes Other then the list "
         & "shows Base and Third" TO TL-CASE
     MOVE "2:Base|Third|" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Restart: a new client state on the same game directory.
     PERFORM START-CLIENT
     MOVE ACT-MULTIPLAYER TO WS-ACTION
     PERFORM CLICK
     PERFORM LIST-NAMES
     MOVE "acceptance US2-1 given the entries were changed when the client starts again then the "
         & "server list still shows Base at localhost:25570 and Third" TO TL-CASE
     MOVE "2:Base|Third|localhost:25570" TO TL-EXPECTED
     STRING FUNCTION TRIM(TL-OBSERVED) SL-ADDR(1)(1:SL-ADDR-LENGTH(1)) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-CLIENT.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-us2-list" TO CL-GAME-DIR
     MOVE 26 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE.

 CLICK.
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND.

 ADD-ENTRY.
     MOVE 0 TO WS-ARG
     MOVE ACT-ADD TO WS-ACTION
     PERFORM CLICK
     MOVE ACT-FIELD-NAME TO WS-ACTION
     PERFORM CLICK
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TEXT WS-LENGTH.

 TYPE-ADDRESS-DONE.
     MOVE ACT-FIELD-ADDRESS TO WS-ACTION
     PERFORM CLICK
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TEXT WS-LENGTH
     MOVE ACT-DONE TO WS-ACTION
     PERFORM CLICK.

*> "<screen>:<name>|<name>|..." of the entries the screen model lists.
 LIST-NAMES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING FUNCTION CHAR(SM-SCREEN + 49) ":" DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-SELECT
             STRING SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) "|" DELIMITED BY SIZE
                 INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US2-SERVER-LIST.
 COPY CLTEST.
