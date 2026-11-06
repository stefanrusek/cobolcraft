*> Acceptance test, US11-1 and US11-2 core half (spec US11 scenarios 1 and 2; tasks T560;
*> standin-content §14.3, §14.4; 09 §3.3 weather values). cobolcraft:main has weather; a new world
*> starts clear with 6000 remaining ticks, and every tick takes 1 from the remaining time. At 0, with
*> r = H(0, Time) (Time after it advanced, §9.5 step 2): after clear, drizzle when r mod 100 < 70,
*> otherwise hailstorm; after drizzle or hailstorm, clear; the remaining time becomes base +
*> ((r div 100) mod span) of the new kind. Every player in the dimension is sent the kind's pair:
*> Game Event 1 (rain above 0) or 2, then 7 with the rain level, then 8 with the thunder level; the
*> pair is also sent on join. Expected values computed from the §1.4.1 hash, independently of the
*> core:
*>   H(0, 1000) = 2398782630: mod 100 = 30 -> drizzle, 2400 + (23987826 mod 2401) = 4236
*>   H(0, 1004) = 3928772780: mod 100 = 80 -> hailstorm, 1200 + (39287727 mod 1201) = 1815
*>   H(0, 1006) = 2546277355: after drizzle -> clear, 6000 + (25462773 mod 6001) = 6530
*>   H(0, 1007) = 2304156624: after hailstorm -> clear, 6000 + (23041566 mod 6001) = 9727
*> The players are creative and the world's hostile mobs are off, so nothing but the weather acts.
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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS

     MOVE "acceptance US11-1 given a new world then cobolcraft:main is clear with 6000 ticks left"
         TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM SHOW-STATE
     MOVE "kind 1 left 6000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given a new world when Alice joins then the join sequence carries "
         & "the clear pair (STOP_RAINING, rain 0.0, thunder 0.0)" TO TL-CASE
     CALL "TEST-JOIN-UNDRAINED" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE "2 0.0 | 7 0.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given 6000 ticks left when 100 ticks pass then 5900 are left, the "
         & "kind is unchanged and nothing is sent" TO TL-CASE
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 1 left 5900 sent " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given clear with 1 tick left when Time reaches 1000 (H mod 100 = 30) "
         & "then drizzle follows for 4236 ticks and Alice is sent the drizzle pair" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-CLEAR TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 999 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 2 left 4236 sent 1 0.0 | 7 1.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given clear with 1 tick left when Time reaches 1004 (H mod 100 = 80) "
         & "then a hailstorm follows for 1815 ticks and Alice is sent the hailstorm pair" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-CLEAR TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 1003 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 3 left 1815 sent 1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given drizzle with 1 tick left when Time reaches 1006 then clear "
         & "follows for 6530 ticks and Alice is sent the clear pair" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-DRIZZLE TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 1005 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 1 left 6530 sent 2 0.0 | 7 0.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given a hailstorm with 1 tick left when Time reaches 1007 then clear "
         & "follows for 9727 ticks and Alice is sent the clear pair" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-HAILSTORM TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 1006 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 1 left 9727 sent 2 0.0 | 7 0.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-1 given weather set until changed (-1 left) when 50 ticks pass then "
         & "it neither counts down nor changes" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-DRIZZLE TO CW-WEATHER-KIND(1)
     MOVE WEATHER-UNTIL-CHANGED TO CW-WEATHER-LEFT(1)
     MOVE 50 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     PERFORM SHOW-STATE-AFTER
     MOVE "kind 2 left -1 sent " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-2 given Alice and Bob in cobolcraft:main when the weather changes then "
         & "both are sent the same pair at the same tick" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
     MOVE WK-CLEAR TO CW-WEATHER-KIND(1)
     MOVE 1 TO CW-WEATHER-LEFT(1)
     MOVE 1003 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT2
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-TEXT) " Bob " FUNCTION TRIM(WS-TEXT2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "Alice 1 0.0 | 7 1.0 | 8 1.0 Bob 1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US11-2 given a hailstorm in cobolcraft:main when Bob joins then his join "
         & "sequence carries the hailstorm pair, the same as Alice's" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE WK-HAILSTORM TO CW-WEATHER-KIND(1)
     MOVE 1000 TO CW-WEATHER-LEFT(1)
     CALL "TEST-JOIN-UNDRAINED" USING WS-BOB-NAME WS-BOB-LENGTH WS-BOB
     CALL "TEST-DRAIN-WEATHER" USING WS-BOB WS-TEXT
     MOVE "1 0.0 | 7 1.0 | 8 1.0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world; creative Alice joins at the spawn point and is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-ALICE-LENGTH WS-ALICE.

*> WS-TEXT becomes "kind <k> left <n>" of cobolcraft:main.
 SHOW-STATE.
     MOVE CW-WEATHER-KIND(1) TO WS-E1
     MOVE CW-WEATHER-LEFT(1) TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "kind " FUNCTION TRIM(WS-E1) " left " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT.

*> WS-TEXT (the drained weather events) becomes "kind <k> left <n> sent <events>".
 SHOW-STATE-AFTER.
     MOVE WS-TEXT TO WS-TEXT2
     PERFORM SHOW-STATE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-TEXT(1:FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT))) " sent "
         FUNCTION TRIM(WS-TEXT2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-CYCLE.

 COPY CORETEST.
