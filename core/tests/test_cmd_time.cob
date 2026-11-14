*> Acceptance test of docs/protocol/16-commands-catalog.md §4.5 `time` (permission level 2) with 14a: the one clock of the world is
*> cobolcraft:daylight (09 profile: the clock is the time of day; its total ticks are not kept, so a set wraps to the day, and
*> `time of <clock>`, `query timeline <moon|early_game>` and `repetition` are BLOCKED: no clock registry, no total ticks).
*> set <time> and set <marker> (day 1000, noon 6000, night 13000, midnight 18000: the next time after now) fail when already
*> there, add wraps the day, query gametime reads the ticks run since the world opened, pause and resume stop and start the
*> clock (the tick consults it), rate scales it; every change sends Set Time to every player. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TIME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
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
 01 WS-IDS                 PIC X(1024).
 01 WS-TICKS               BINARY-LONG VALUE 10.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /time set <time>: the clock is at 1000 ticks" TO TL-CASE
     MOVE "time set 1000" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,1000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the time of day is 1000" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 1000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /time every player is sent Set Time (115)" TO TL-CASE
     MOVE "time set 2000" TO WS-LINE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "115" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time set <time> to the time it is: Clock is" & " already set" TO TL-CASE
     MOVE "time set 2000" TO WS-LINE
     MOVE "commands.time.set.already_at_time(cobolcraft:daylight,2000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the result of set is the ticks" TO TL-CASE
     MOVE "time set 3000" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /time a time with the unit d is 24000 ticks" TO TL-CASE
     MOVE "time set 1d" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,24000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a whole day wraps to the start of the " & "day" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /time the unit s is 20 ticks" TO TL-CASE
     MOVE "time set 5s" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,100)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time -5 is no time (below the minimum) but " & "a valid marker id: no time marker found" TO TL-CASE
     MOVE "time set -5" TO WS-LINE
     MOVE "commands.time.no_time_marker_found(minecraft:-5,cobolcraft:d" & "aylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time set to 5000" TO TL-CASE
     MOVE "time set 5000" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,5000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time set <marker> moves to the next occurre" & "nce after now" TO TL-CASE
     MOVE "time set day" TO WS-LINE
     MOVE "commands.time.set.time_marker(cobolcraft:daylight,minecraft:" & "day)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time day is 1000 and the clock moved ahead " & "to it" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 1000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /time at the marker already: error" TO TL-CASE
     MOVE "time set day" TO WS-LINE
     MOVE "commands.time.set.already_at_time_marker(cobolcraft:daylight" & ",minecraft:day)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time noon is 6000" TO TL-CASE
     MOVE "time set noon" TO WS-LINE
     MOVE "commands.time.set.time_marker(cobolcraft:daylight,minecraft:" & "noon)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time noon is 6000" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 6000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /time night is 13000" TO TL-CASE
     MOVE "time set night" TO WS-LINE
     MOVE "commands.time.set.time_marker(cobolcraft:daylight,minecraft:" & "night)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time midnight is 18000, with the namespace" TO TL-CASE
     MOVE "time set minecraft:midnight" TO WS-LINE
     MOVE "commands.time.set.time_marker(cobolcraft:daylight,minecraft:" & "midnight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time midnight is 18000" TO TL-CASE
     MOVE CW-TIME TO WS-NUM
     MOVE 18000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /time an unknown marker" TO TL-CASE
     MOVE "time set nowhen" TO WS-LINE
     MOVE "commands.time.no_time_marker_found(minecraft:nowhen,cobolcra" & "ft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time add 1000 to 18000" TO TL-CASE
     MOVE "time add 1000" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,19000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time add wraps the day (the ticks shown are" & " of the day)" TO TL-CASE
     MOVE "time add 6000" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,1000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a negative add wraps backwards" TO TL-CASE
     MOVE "time add -2000" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,23000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time query gametime is the ticks run since " & "the world opened" TO TL-CASE
     MOVE 12345 TO CW-TICKS
     MOVE "time query gametime" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "commands.time.query.gametime(12345)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time query time is the ticks of the clock" TO TL-CASE
     MOVE "time query time" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "commands.time.query.absolute(cobolcraft:daylight,23000)" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the result of a query is the value" TO TL-CASE
     MOVE "time query time" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 23000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /time query timeline day is the tick within " & "the day" TO TL-CASE
     MOVE "time query timeline day" TO WS-LINE
     MOVE "commands.time.query.timeline(minecraft:day,23000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a timeline whose period is longer than" & " the day (moon) is BLOCKED and refused" TO TL-CASE
     MOVE "time query timeline moon" TO WS-LINE
     MOVE "commands.time.wrong_timeline_for_clock(minecraft:moon,cobolc" & "raft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time pause the clock" TO TL-CASE
     MOVE "time pause" TO WS-LINE
     MOVE "commands.time.pause(cobolcraft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time pausing twice: already paused" TO TL-CASE
     MOVE "time pause" TO WS-LINE
     MOVE "commands.time.pause.already_paused(cobolcraft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the paused clock does not advance" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE CW-TIME TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "23000" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time resume" TO TL-CASE
     MOVE "time resume" TO WS-LINE
     MOVE "commands.time.resume(cobolcraft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time resuming twice: already running" TO TL-CASE
     MOVE "time resume" TO WS-LINE
     MOVE "commands.time.pause.already_running(cobolcraft:daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the running clock advances one tick pe" & "r tick" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE CW-TIME TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "23010" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time rate 2" TO TL-CASE
     MOVE "time rate 2" TO WS-LINE
     MOVE "commands.time.rate(cobolcraft:daylight,2.0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the same rate again: already" TO TL-CASE
     MOVE "time rate 2" TO WS-LINE
     MOVE "commands.time.rate.already_same(cobolcraft:daylight,2.0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a clock at rate 2 advances two ticks p" & "er tick" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE CW-TIME TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "23030" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time rate back to 1" TO TL-CASE
     MOVE "time rate 1" TO WS-LINE
     MOVE "commands.time.rate(cobolcraft:daylight,1.0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a rate below 0.00001 is below the mini" & "mum" TO TL-CASE
     MOVE "time rate 0" TO WS-LINE
     MOVE "argument.float.low(1.0E-5,0.0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time a player below level 2 does not know t" & "he command" TO TL-CASE
     MOVE "time set 1" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /time the console prints the English text" TO TL-CASE
     MOVE "time set 100" TO WS-LINE
     MOVE "Set cobolcraft:daylight to 100 tick(s)" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /time time alone is incomplete" TO TL-CASE
     MOVE "time" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE "acceptance US13 /time a standard world's clock is minecraft:" & "overworld" TO TL-CASE
     MOVE "time set 5000" TO WS-LINE
     MOVE "commands.time.set.absolute(minecraft:overworld,5000)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "cobolcraft" TO CW-WORLD-TYPE
     GOBACK.
 END PROGRAM TEST-CMD-TIME.

 COPY CORETEST.
 COPY CMDTEST.
