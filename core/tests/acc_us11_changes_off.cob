*> Acceptance test, US11-4 core half (spec US11 scenario 4; FR-009; tasks T565; standin-content
*> §14.3): while the weather-changes setting is off, the remaining time does not count down and the
*> kind does not change, so nothing is sent. With the setting on, clear with 1 tick left at Time 1000
*> would become drizzle (acc_us11_cycle).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-CHANGES-OFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY WEATHER.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES

     MOVE "acceptance US11-4 given weather changes off and clear with 1 tick left when Time "
         & "passes 1000 and 200 more ticks pass then the weather stays clear with 1 tick left and "
         & "nothing is sent" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE WK-CLEAR TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 999 TO CW-TIME
     MOVE 200 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM CHECK-STATE
     MOVE "kind 1 left 1 sent " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-4 given weather changes off and a hailstorm with 6000 ticks left when "
         & "100 ticks pass then the hailstorm stays with 6000 ticks left" TO TL-CASE
     MOVE WK-HAILSTORM TO CW-WEATHER-KIND(1)
     MOVE 6000 TO CW-WEATHER-LEFT(1)
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM CHECK-STATE
     MOVE "kind 3 left 6000 sent " TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> WS-TEXT (the drained weather events) becomes "kind <k> left <n> sent <events>".
 CHECK-STATE.
     MOVE CW-WEATHER-KIND(1) TO WS-E1
     MOVE CW-WEATHER-LEFT(1) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "kind " FUNCTION TRIM(WS-E1) " left " FUNCTION TRIM(WS-E2) " sent "
         FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-CHANGES-OFF.

 COPY CORETEST.
