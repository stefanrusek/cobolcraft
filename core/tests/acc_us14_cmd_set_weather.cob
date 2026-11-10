*> Acceptance test, US14-2 skies (spec US14 scenario 2; FR-016; standin-content §16.2 row 25, §14.3,
*> §14.4): the set-weather command sets a dimension's weather kind for seconds x 20 ticks
*> (cobolcraft.command.skies.timed [dimension path, kind word, seconds]) or until changed, with no
*> countdown (skies.held [dimension path, kind word]); players in the dimension are sent the §14.4
*> pair; a dimension without weather gets skies.no_weather. Extra dimensions are on, hostile mobs
*> off.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-SET-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OPAL                BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONSOLE             BINARY-LONG VALUE 0.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-PATH                PIC X(256).
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEDIT               PIC -(9)9.
 01 WS-EDIT                PIC -(10)9.
 01 WS-DEDIT               PIC -(9)9.99.
 01 WS-AREA                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 when an operator sets main's weather to drizzle for 30 "
         & "seconds then the sender is sent skies.timed" TO TL-CASE
     MOVE "skies main drizzle 30" TO WS-LINE
     MOVE "cobolcraft.command.skies.timed(main,drizzle,30)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 main is drizzling with 600 ticks left (30 x 20)" TO TL-CASE
     PERFORM WEATHER-OF
     MOVE "2 600" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the shared state changes the levels by fading (33 4.3): nothing is sent at once, "
         & "and once the rain level passed 0.2 (20 ticks) the players are sent Game Event 1, 7, 8" TO TL-CASE
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE 20 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "| 1 0.0 | 7 0.2 | 8 0.0"
     MOVE SPACES TO WS-TEXT
     MOVE WS-COUNT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 setting the weather without seconds holds it until "
         & "changed: skies.held" TO TL-CASE
     MOVE "skies main hailstorm" TO WS-LINE
     MOVE "cobolcraft.command.skies.held(main,hailstorm)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE 30 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US14-2 weather held for the longest time: after 30 ticks main is still a hailstorm with "
         & "2147483617 ticks left" TO TL-CASE
     PERFORM WEATHER-OF
     MOVE "3 2147483617" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the clear kind for 1 second" TO TL-CASE
     MOVE "skies main clear 1" TO WS-LINE
     MOVE "cobolcraft.command.skies.timed(main,clear,1)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 main is clear with 20 ticks left" TO TL-CASE
     PERFORM WEATHER-OF
     MOVE "1 20" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the subroutine has no weather: skies.no_weather" TO TL-CASE
     MOVE "skies subroutine drizzle" TO WS-LINE
     MOVE "cobolcraft.command.skies.no_weather(subroutine)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 seconds out of range are an invalid argument" TO TL-CASE
     MOVE "skies main drizzle 86401" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(86401,skies <dimension> <kind> "
         & "[<seconds>])" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     STOP RUN.

*> Opal holds operator status through the world's operator list.
 JOIN-OPAL.
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OPAL.

*> Opal runs WS-LINE; WS-TEXT is the System Chat she is sent.
 OPAL-RUN.
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT.

 OPAL-CHECK.
     PERFORM OPAL-RUN
     PERFORM CHECK-TEXT.

*> The console runs WS-LINE; WS-TEXT is the console lines it printed, separated by " | ".
 CONSOLE-RUN.
     PERFORM CONSOLE-LINES
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "CMD-RUN" USING WS-CONSOLE WS-LINE WS-LENGTH
     PERFORM CONSOLE-LINES.

 CONSOLE-LINES.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 CHECK-TEXT.
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-TEXT: the weather kind and remaining ticks of cobolcraft:main.
 WEATHER-OF.
     MOVE 1 TO WS-KIND
     MOVE CW-CLEAR-TIME TO WS-EDIT
     IF CW-RAINING = 1
         MOVE 2 TO WS-KIND
         MOVE CW-RAIN-TIME TO WS-EDIT
         IF CW-THUNDERING = 1
             MOVE 3 TO WS-KIND
         END-IF
     END-IF
     MOVE WS-KIND TO WS-KEDIT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-N
     STRING FUNCTION TRIM(WS-KEDIT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N.

 END PROGRAM ACC-US14-CMD-SET-WEATHER.

 COPY CORETEST.
