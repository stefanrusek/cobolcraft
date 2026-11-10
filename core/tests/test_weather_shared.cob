*> Test of the shared weather of 33 section 4 (core/src/weather.cob; T0359): one WeatherData for the server (clear, rain and
*> thunder times, raining and thundering flags), per-dimension levels that follow the flags by 0.01 a tick, the cycle of 4.2 A
*> (the clear countdown, the toggles, the draws from RAIN_DELAY 12000 to 180000, RAIN_DURATION 12000 to 24000, THUNDER_DELAY
*> 12000 to 180000 and THUNDER_DURATION 3600 to 15600), the weather-changes setting as the rule advance_weather (the cycle stops,
*> the levels still move), the audiences of 4.2 C and the join pair (Game Event 1, 7, 8 only while it rains). A dimension without
*> weather has no levels and is told nothing. Expected values come from 33 section 4.2, independently of the core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WEATHER-SHARED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-STATE               PIC X(256).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-RAINING             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BIG                 BINARY-LONG VALUE 100000.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-SC                  BINARY-LONG.
 01 WS-LOW                 FLOAT-SHORT.
 01 WS-SR                  BINARY-LONG.
 01 WS-SF                  BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE 1 TO CS-DEFAULT-MODE CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

     MOVE "test weather shared a new world has no weather: every time 0, no flags, and the join sends nothing"
         TO TL-CASE
     PERFORM SHOW-STATE
     MOVE FUNCTION CONCATENATE(FUNCTION TRIM(WS-STATE), " sent ", FUNCTION TRIM(WS-TEXT)) TO TL-OBSERVED
     MOVE "clear 0 thunder 0 rain 0 thundering 0 raining 0 sent" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared with 3 ticks of clear time and a storm one tick later the first tick leaves 2, "
         & "no flags and both times 0 (4.2 A.1)" TO TL-CASE
     MOVE WS-ONE TO WS-SC
     MOVE WS-ZERO TO WS-SR
     MOVE WS-ONE TO WS-SF
     MOVE WS-ONE TO WS-ST
     PERFORM SET-WEATHER
     MOVE 3 TO CW-CLEAR-TIME
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM SHOW-STATE
     MOVE WS-STATE TO TL-OBSERVED
     MOVE "clear 2 thunder 0 rain 0 thundering 0 raining 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared when the clear time ran out both times are 1; the next tick toggles both flags on (4.2 "
         & "consequences)" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM SHOW-STATE
     MOVE "clear 0 thunder 0 rain 0 thundering 1 raining 1" TO TL-EXPECTED
     MOVE WS-STATE TO TL-OBSERVED
     PERFORM CHECK

     MOVE "test weather shared the tick after a toggle draws the durations: thunder 3600 to 15600, rain 12000 to "
         & "24000 (4.2 A.2, A.3)" TO TL-CASE
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-RAIN
     IF CW-THUNDER-TIME >= 3600 AND CW-THUNDER-TIME <= 15600 AND CW-RAIN-TIME >= 12000 AND CW-RAIN-TIME <= 24000
         MOVE 1 TO WS-RAIN
     END-IF
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RAIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test weather shared with nothing running and no flags the first tick draws the delays: 12000 to 180000 "
         & "for both" TO TL-CASE
     MOVE WS-ZERO TO WS-SC
     MOVE WS-ZERO TO WS-SR
     MOVE WS-ZERO TO WS-SF
     MOVE WS-ZERO TO WS-ST
     PERFORM SET-WEATHER
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-RAIN
     IF CW-THUNDER-TIME >= 12000 AND CW-THUNDER-TIME <= 180000 AND CW-RAIN-TIME >= 12000
             AND CW-RAIN-TIME <= 180000
         MOVE 1 TO WS-RAIN
     END-IF
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RAIN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test weather shared with raining set and 19 ticks passed the rain level is 0.19, it does not rain and "
         & "only Game Event 7 was sent" TO TL-CASE
     MOVE WS-ZERO TO WS-SC
     MOVE WS-BIG TO WS-SR
     MOVE WS-ONE TO WS-SF
     MOVE WS-ZERO TO WS-ST
     PERFORM SET-WEATHER
     MOVE 0 TO CW-RAIN-LEVEL(1) CW-RAIN-LEVEL-OLD(1) CW-THUNDER-LEVEL(1)
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE 19 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "WEATHER-RAINING" USING WS-DIM WS-RAINING
     MOVE WS-RAINING TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "raining " FUNCTION TRIM(WS-E1) " events " WS-TEXT(1:5) " length "
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "raining 0 events 7 0.0 length 149" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared the 20th tick makes it rain (0.20000002 is above 0.2): Game Event 7, then 1, 7 and 8 to "
         & "all players (4.2 B, C)" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "7 0.2 | 1 0.0 | 7 0.2 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared a player who joins while it rains is sent Game Event 1, 7 with the rain level and 8 "
         & "with the thunder level times the rain level" TO TL-CASE
     MOVE 1 TO CW-RAIN-LEVEL(1)
     MOVE 1 TO CW-THUNDER-LEVEL(1)
     CALL "WEATHER-SEND" USING WS-ROW
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared a player in a dimension that cannot have weather is sent nothing, however it rains "
         & "in the first" TO TL-CASE
     MOVE 2 TO PL-DIM(WS-ROW)
     CALL "WEATHER-SEND" USING WS-ROW
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     MOVE 1 TO PL-DIM(WS-ROW)

     MOVE "test weather shared setting the weather writes the rain time into the thunder time (33 4.3) and loading "
         & "levels starts a storm at full strength (4.1)" TO TL-CASE
     MOVE 40 TO WS-RAIN
     MOVE WS-ZERO TO WS-SC
     MOVE WS-RAIN TO WS-SR
     MOVE WS-ONE TO WS-SF
     MOVE WS-ONE TO WS-ST
     PERFORM SET-WEATHER
     CALL "WEATHER-LEVELS-LOAD"
     MOVE CW-THUNDER-TIME TO WS-E1
     COMPUTE WS-E2 = CW-RAIN-LEVEL(1) * 10
     COMPUTE WS-E3 = CW-THUNDER-LEVEL(1) * 10
     COMPUTE WS-E4 = CW-RAIN-LEVEL(2) * 10
     MOVE SPACES TO TL-OBSERVED
     STRING "thunder time " FUNCTION TRIM(WS-E1) " rain level " FUNCTION TRIM(WS-E2) " thunder level "
         FUNCTION TRIM(WS-E3) " subroutine " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "thunder time 40 rain level 10 thunder level 10 subroutine 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared with the flags cleared the rain stops being rain on the 81st tick of the fade "
         & "(Game Event 2 then)" TO TL-CASE
     MOVE WS-ZERO TO WS-SC
     MOVE WS-BIG TO WS-SR
     MOVE WS-ZERO TO WS-SF
     MOVE WS-ZERO TO WS-ST
     PERFORM SET-WEATHER
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE 80 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "WEATHER-RAINING" USING WS-DIM WS-RAINING
     MOVE WS-RAINING TO WS-E1
     MOVE 1 TO WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "WEATHER-RAINING" USING WS-DIM WS-RAINING
     MOVE WS-RAINING TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "after 80: " FUNCTION TRIM(WS-E1) " after 81: " FUNCTION TRIM(WS-E2) " sent " WS-TEXT(1:7)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "after 80: 1 after 81: 0 sent 7 0.2 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test weather shared the levels stay within 0 and 1: 0.005 falling ends at 0, 0.995 rising ends at 1"
         TO TL-CASE
     MOVE 0 TO WS-SC WS-SR WS-SF WS-ST
     PERFORM SET-WEATHER
     MOVE 0.005 TO CW-RAIN-LEVEL(1) CW-THUNDER-LEVEL(1)
     CALL "WEATHER-SMOOTH" USING WS-DIM
     MOVE CW-RAIN-LEVEL(1) TO WS-LOW
     MOVE 0 TO WS-SC
     MOVE 1 TO WS-SF WS-ST
     MOVE 5 TO WS-SR
     PERFORM SET-WEATHER
     MOVE 0.995 TO CW-RAIN-LEVEL(1) CW-THUNDER-LEVEL(1)
     CALL "WEATHER-SMOOTH" USING WS-DIM
     COMPUTE TL-EXPECTED-N = 1000
     COMPUTE TL-OBSERVED-N = WS-LOW * 1000 + CW-RAIN-LEVEL(1) * 1000 + CW-THUNDER-LEVEL(1) * 1000 - 1000
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SET-WEATHER.
     CALL "WEATHER-SET" USING WS-SC WS-SR WS-SF WS-ST.

 SHOW-STATE.
     MOVE CW-CLEAR-TIME TO WS-E1
     MOVE CW-THUNDER-TIME TO WS-E2
     MOVE CW-RAIN-TIME TO WS-E3
     MOVE CW-THUNDERING TO WS-E4
     MOVE CW-RAINING TO WS-E5
     MOVE SPACES TO WS-STATE
     STRING "clear " FUNCTION TRIM(WS-E1) " thunder " FUNCTION TRIM(WS-E2) " rain " FUNCTION TRIM(WS-E3)
         " thundering " FUNCTION TRIM(WS-E4) " raining " FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO WS-STATE.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-WEATHER-SHARED.

 COPY CORETEST.
