*> Acceptance test, US11-1 and US11-2 core half (spec US11 scenarios 1 and 2; docs/protocol/33-world-simulation.md section 4.2,
*> 4.3; 09 §3.3). Weather is the shared mechanism of 33: a new world has no weather and a joining player is sent nothing;
*> when it starts to rain (rain level above 0.2, the 20th tick of the fade) every player is sent Game Event 1, 7 and 8 at the
*> same tick; a player who joins while it rains is sent the pair in his join sequence. The schedule itself (times, draws,
*> levels) is tested in test_weather_shared. The players are creative and the hostile mobs are off.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-CYCLE.
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
 01 WS-TICKS               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TIME                BINARY-LONG VALUE 1000000.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-DEFAULT-MODE

     MOVE "acceptance US11-1 given a new world when Alice joins then the join sequence carries no weather event"
         TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-UNDRAINED" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-2 given Alice and Bob in cobolcraft:main when it starts to rain then both are sent Game "
         & "Event 1, 7, 8 at the same tick (the 20th of the fade)" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
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
     STRING "Alice " FUNCTION TRIM(WS-TEXT) " Bob " FUNCTION TRIM(WS-TEXT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "Alice 7 0.2 | 1 0.0 | 7 0.2 | 8 0.0 Bob 7 0.2 | 1 0.0 | 7 0.2 | 8 0.0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US11-2 given a hailstorm in cobolcraft:main when Bob joins then his join sequence carries "
         & "Game Event 1, 7 (1.0) and 8 (1.0)" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     MOVE WK-HAILSTORM TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     CALL "WEATHER-LEVELS-LOAD"
     CALL "TEST-JOIN-UNDRAINED" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT
     MOVE "1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-CYCLE.

 COPY CORETEST.
