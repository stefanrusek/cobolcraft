*> contract_wire_server.cob weather cases (test infrastructure; task T559;
*> docs/protocol/09-cobolcraft-profile.md §3.3 weather rows and values; standin-content §14.1,
*> §14.4). Clientbound Game Event 1, 2, 7 and 8 equal the core's weather sequence builder output
*> (WEATHER-EVENT-BUILD: kind, step 1 to 3) for each fixture's stated inputs: the hailstorm
*> sequence is 1 (0.0), 7 (1.0), 8 (1.0); event 2 (0.0) is the first event of the clear sequence.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-WEATHER-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY PROTO.
 COPY WEATHER.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-KIND                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "contract wire server play-s2c-27-game-event-01-start-raining equals the core's first "
         & "weather event of cobolcraft:hailstorm (START_RAINING 0.0)" TO TL-CASE
     MOVE WK-HAILSTORM TO WS-KIND
     MOVE 1 TO WS-STEP
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-01-start-raining.hex" TO WS-PATH
     PERFORM CHECK-STEP

     MOVE "contract wire server play-s2c-27-game-event-07-rain-level equals the core's second "
         & "weather event of cobolcraft:hailstorm (RAIN_LEVEL_CHANGE 1.0)" TO TL-CASE
     MOVE 2 TO WS-STEP
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-07-rain-level.hex" TO WS-PATH
     PERFORM CHECK-STEP

     MOVE "contract wire server play-s2c-27-game-event-08-thunder-level equals the core's third "
         & "weather event of cobolcraft:hailstorm (THUNDER_LEVEL_CHANGE 1.0)" TO TL-CASE
     MOVE 3 TO WS-STEP
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-08-thunder-level.hex" TO WS-PATH
     PERFORM CHECK-STEP

     MOVE "contract wire server play-s2c-27-game-event-02-stop-raining equals the core's first "
         & "weather event of cobolcraft:clear (STOP_RAINING 0.0)" TO TL-CASE
     MOVE WK-CLEAR TO WS-KIND
     MOVE 1 TO WS-STEP
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-02-stop-raining.hex" TO WS-PATH
     PERFORM CHECK-STEP

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

 CHECK-STEP.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "WEATHER-EVENT-BUILD" USING WS-KIND WS-STEP PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT.
 END PROGRAM WIRE-WEATHER-CASES.
