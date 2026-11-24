*> Acceptance test of the automatic save and save-off/save-on (docs/protocol/16-commands-catalog.md §11.10, §11.11; 33 §1.1 step 6): the countdown BW-AUTOSAVE-LEFT
*> falls by 1 a tick, at 0 it restarts at 6000 and the world is saved (level.dat Time is the time at the save), unless save-off switched it off.
*> Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-AUTOSAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 COPY BRWORLD.
 01 WS-SUF                 PIC X(128).
 01 WS-PATHL               PIC X(1100).
 01 WS-PLEN                BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH2               PIC X(128).
 01 WS-BIG                 PIC X(8192).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-AUTOSAVE-LEFT
     MOVE 1000 TO CW-TIME
     CALL "CORE-TICK"
     CALL "CORE-TICK"
     PERFORM READ-SAVED
     MOVE "acceptance US13 /autosave the world is saved when the countd" & "own ends: the saved time is the time at the save" TO TL-CASE
     CONTINUE
     MOVE "1002" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /autosave the countdown restarts at 6000 aft" & "er the save" TO TL-CASE
     MOVE BW-AUTOSAVE-LEFT TO WS-NUM
     MOVE 6000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /autosave save-off switches the automatic sa" & "ving off" TO TL-CASE
     MOVE "save-off" TO WS-LINE
     MOVE "commands.save.disabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 1 TO BW-AUTOSAVE-LEFT
     MOVE 2000 TO CW-TIME
     CALL "CORE-TICK"
     PERFORM READ-SAVED
     MOVE "acceptance US13 /autosave with the saving off the countdown " & "ends without a save: the saved time stays" TO TL-CASE
     CONTINUE
     MOVE "1002" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /autosave and the countdown restarted" TO TL-CASE
     MOVE BW-AUTOSAVE-LEFT TO WS-NUM
     MOVE 6000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /autosave save-on switches it on again" TO TL-CASE
     MOVE "save-on" TO WS-LINE
     MOVE "commands.save.enabled()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 1 TO BW-AUTOSAVE-LEFT
     MOVE 3000 TO CW-TIME
     CALL "CORE-TICK"
     PERFORM READ-SAVED
     MOVE "acceptance US13 /autosave with it on again the next countdow" & "n saves" TO TL-CASE
     CONTINUE
     MOVE "3001" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> WS-TEXT: the Time tag of the saved level.dat.
 READ-SAVED.
     MOVE "/level.dat" TO WS-SUF
     CALL "PERSIST-PATH" USING WS-SUF WS-PATHL WS-PLEN
     MOVE WS-PATHL(1:256) TO WS-FILE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "Time" TO WS-PATH2
     MOVE SPACES TO WS-TEXT
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH2 WS-BIG
     MOVE WS-BIG(1:64) TO WS-TEXT
     CALL "PB-FREE" USING PB-BUFFER.
 END PROGRAM TEST-CMD-AUTOSAVE.

 COPY CORETEST.
 COPY CMDTEST.
