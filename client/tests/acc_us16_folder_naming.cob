*> Acceptance test, US16 edge case (client-surface.md §2 single-player folder names): a world created
*> with the name of an existing one gets a new folder with " (2)", then " (3)", and every one appears
*> in the world list; characters outside A-Z a-z 0-9 _ - space become _ in the folder name. Driven
*> through the title screen, the world list, the create-world screen and the pause menu.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-FOLDER-NAMING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-us16-naming".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "My World" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     PERFORM CREATE-AND-LEAVE 3 TIMES
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US16 edge given a world named like an existing one when created then a new "
         & "folder with (2) (then (3)) is used and both appear in the list" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Single-player Worlds|My World (My World)|My World (My World (2))|My World (My World "
         & "(3))|Play|Create New World|Delete|Back" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Characters outside A-Z a-z 0-9 _ - space: one _ each (é is one character of two bytes).
     MOVE SPACES TO WS-NAME
     STRING "a/b?c" FUNCTION CHAR(234) "d-e_f 9" DELIMITED BY SIZE INTO WS-NAME
     MOVE 13 TO WS-NAME-LENGTH
     MOVE ACT-BACK TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     PERFORM CREATE-AND-LEAVE
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "client-surface §2 characters outside A-Z a-z 0-9 _ - space become _ in the folder name; "
         & "the list shows the world name and the folder" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "Single-player Worlds|My World (My World)|My World (My World (2))|My World (My World "
         "(3))|a/b?c" FUNCTION CHAR(196) FUNCTION CHAR(170) "d-e_f 9 (a_b_c_d-e_f 9)|Play|"
         "Create New World|Delete|Back" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   From the title screen: Single-player, Create New World, the default name erased, WS-NAME typed,
*>   Create; once in play, Escape and Save and Leave the World (back on the title screen).
 CREATE-AND-LEAVE.
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-NEW-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 9 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     END-PERFORM
     CALL "TEST-TYPE" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND.
 END PROGRAM ACC-US16-FOLDER-NAMING.
 COPY CLTEST.
