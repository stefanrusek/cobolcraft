*> Acceptance test, US11 edge case core half (spec US11 edge "a dimension without weather"; tasks
*> T567; standin-content §14.2, §14.4; 09 §3.3 weather values): a player in a dimension without
*> weather is always sent the clear sequence (STOP_RAINING, rain 0.0, thunder 0.0), whatever the
*> weather of cobolcraft:main, and a change in cobolcraft:main is not sent to them. The dimension
*> without weather is cobolcraft:subroutine (DIMENSIONS.cpy row 2, has-weather flag 0, §15.1);
*> Alice is put there directly. The pair is sent by WEATHER-SEND, the
*> step of the join sequence (PLAY-ARRIVE) that a join, a respawn or an arrival by travel runs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-NO-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY WEATHER.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-ALICE-LENGTH        BINARY-LONG VALUE 5.
 01 WS-BOB-LENGTH          BINARY-LONG VALUE 3.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TIME                BINARY-LONG VALUE 1000000.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS

     MOVE "US11 edge given a hailstorm in cobolcraft:main and Alice in a dimension without weather when she is "
         & "sent the weather then nothing is sent (33 4.2: only a raining dimension has a join pair)" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     MOVE WK-HAILSTORM TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     CALL "WEATHER-LEVELS-LOAD"
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 2 TO PL-DIM(WS-ROW)
     CALL "WEATHER-SEND" USING WS-ROW
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US11 edge given Alice in a dimension without weather and Bob in cobolcraft:main when it starts to rain "
         & "in cobolcraft:main then Bob is sent the per-tick levels and the start, Alice only the start (to all "
         & "players, 4.2 C.2)" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 2 TO PL-DIM(WS-ROW)
     MOVE WK-DRIZZLE TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     MOVE 19 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT2
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT2
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-TEXT) " Bob " FUNCTION TRIM(WS-TEXT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "Alice 1 0.0 | 7 0.2 | 8 0.0 Bob 7 0.2 | 1 0.0 | 7 0.2 | 8 0.0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-NO-WEATHER.

 COPY CORETEST.
