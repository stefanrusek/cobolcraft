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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS

     MOVE "US11 edge given a hailstorm in cobolcraft:main and Alice in a dimension without "
         & "weather when she is sent the weather then it is STOP_RAINING, rain 0.0, thunder 0.0"
         TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     MOVE WK-HAILSTORM TO CW-WEATHER-KIND(1)
     MOVE 1000 TO CW-WEATHER-LEFT(1)
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 2 TO PL-DIM(WS-ROW)
     CALL "WEATHER-SEND" USING WS-ROW
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE "2 0.0 | 7 0.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US11 edge given Alice in a dimension without weather and Bob in cobolcraft:main when "
         & "cobolcraft:main turns from clear to a hailstorm then only Bob is sent its pair" TO TL-CASE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WK-CLEAR TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 1003 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT2
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-TEXT) " Bob " FUNCTION TRIM(WS-TEXT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "Alice  Bob 1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-NO-WEATHER.

 COPY CORETEST.
