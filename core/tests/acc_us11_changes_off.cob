*> Acceptance test, US11-4 core half (spec US11 scenario 4; FR-009; 33 section 4.2 A): while the weather-changes setting
*> (the rule advance_weather) is off, the times of the shared weather do not count down and no flag toggles, so nothing
*> new is decided; the levels (4.2 B) still follow the flags, so a set weather still fades in.
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
 01 WS-KIND                BINARY-LONG.
 01 WS-TIME                BINARY-LONG VALUE 6000.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES

     MOVE "acceptance US11-4 given weather changes off and a drizzle of 6000 ticks when 200 ticks pass then the "
         & "rain time is still 6000, the flags are as set and the rain level is 1.0 (it faded in)" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE WK-DRIZZLE TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     MOVE 200 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE CW-RAIN-TIME TO WS-E1
     MOVE CW-RAINING TO WS-E2
     COMPUTE WS-E3 = CW-RAIN-LEVEL(1) * 100
     MOVE SPACES TO TL-OBSERVED
     STRING "rain time " FUNCTION TRIM(WS-E1) " raining " FUNCTION TRIM(WS-E2) " level " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "rain time 6000 raining 1 level 100" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US11-4 given weather changes off and nothing running when 100 ticks pass then no time is drawn"
         TO TL-CASE
     CALL "WEATHER-INIT"
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE CW-RAIN-TIME TO WS-E1
     MOVE CW-THUNDER-TIME TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "rain time " FUNCTION TRIM(WS-E1) " thunder time " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "rain time 0 thunder time 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US11-CHANGES-OFF.

 COPY CORETEST.
