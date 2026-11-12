*> Acceptance test of docs/protocol/16-commands-catalog.md §4.10 `weather` (permission level 2) with 14a: clear, rain and thunder set the
*> shared weather (clear: clear time = the duration; rain: rain time, raining; thunder: rain time, raining, thundering); without a
*> duration it is drawn from the range of the kind (clear 12000..180000, rain 12000..24000, thunder 3600..15600); the result is
*> the duration or -1; the change is broadcast. Opal and Bob hold operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /weather clear with a duration: Set the weat" & "her to clear" TO TL-CASE
     MOVE "weather clear 600" TO WS-LINE
     MOVE "commands.weather.set.clear()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the other operator is sent the comm" & "and" TO TL-CASE
     MOVE "chat.type.admin(Opal,Set the weather to clear)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the clear time is 600" TO TL-CASE
     MOVE CW-CLEAR-TIME TO WS-NUM
     MOVE 600 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather it is not raining" TO TL-CASE
     MOVE CW-RAINING TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather rain with a duration: Set the weath" & "er to rain" TO TL-CASE
     MOVE "weather rain 300" TO WS-LINE
     MOVE "commands.weather.set.rain()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the rain time is 300" TO TL-CASE
     MOVE CW-RAIN-TIME TO WS-NUM
     MOVE 300 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather the clear time is 0" TO TL-CASE
     MOVE CW-CLEAR-TIME TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather it is raining" TO TL-CASE
     MOVE CW-RAINING TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather it is not thundering" TO TL-CASE
     MOVE CW-THUNDERING TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather thunder: Set the weather to rain an" & "d thunder" TO TL-CASE
     MOVE "weather thunder 100" TO WS-LINE
     MOVE "commands.weather.set.thunder()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the thunder time is the rain time, " & "100" TO TL-CASE
     MOVE CW-THUNDER-TIME TO WS-NUM
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather it is thundering" TO TL-CASE
     MOVE CW-THUNDERING TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /weather the result is the duration as given" & ": 2s is 40 ticks" TO TL-CASE
     MOVE "weather rain 2s" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 40 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather the unit s is 20 ticks" TO TL-CASE
     MOVE CW-RAIN-TIME TO WS-NUM
     MOVE 40 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather without a duration the result is -1" TO TL-CASE
     MOVE "weather clear" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE -1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather a drawn clear time is at least 1200" & "0" TO TL-CASE
     IF CW-CLEAR-TIME >= 12000 AND CW-CLEAR-TIME <= 180000
         MOVE 1 TO WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather without a duration the result is -1" & " (rain)" TO TL-CASE
     MOVE "weather rain" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE -1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather a drawn rain time is between 12000 " & "and 24000" TO TL-CASE
     IF CW-RAIN-TIME >= 12000 AND CW-RAIN-TIME <= 24000
         MOVE 1 TO WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather without a duration the result is -1" & " (thunder)" TO TL-CASE
     MOVE "weather thunder" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE -1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /weather a drawn thunder time is between 360" & "0 and 15600" TO TL-CASE
     IF CW-THUNDER-TIME >= 3600 AND CW-THUNDER-TIME <= 15600
         MOVE 1 TO WS-NUM
     ELSE
         MOVE 0 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /weather a duration below 1 is below the min" & "imum" TO TL-CASE
     MOVE "weather rain 0" TO WS-LINE
     MOVE "argument.time.tick_count_too_low(1,0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the standard kinds are clear, rain " & "and thunder only" TO TL-CASE
     MOVE "weather snow" TO WS-LINE
     MOVE "command.unknown.argument() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather a player below level 2 does not kno" & "w the command" TO TL-CASE
     MOVE "weather clear" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /weather the console prints the English text" TO TL-CASE
     MOVE "weather clear 5" TO WS-LINE
     MOVE "Set the weather to clear" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-WEATHER.

 COPY CORETEST.
 COPY CMDTEST.
