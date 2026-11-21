*> Acceptance test of docs/protocol/16-commands-catalog.md §10.4 `schedule` (permission level 2) with 14a: function <id|#tag> <time> [append|replace] keeps a schedule (replace, the default, drops the earlier
*> ones of the id; a time of 0 is commands.schedule.same_tick) and tells created.function or created.tag [id, ticks, game time]; clear <id> removes them. Scheduled functions are kept, not run: no function engine exists;
*> the macro refusal cannot arise. The result is the trigger game time (clear: the number removed). Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-SCHEDULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE           BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-TICKS               BINARY-LONG.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-2              PIC -(9)9.
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
    COMPUTE WS-NUM = CW-TICKS + 10
    MOVE WS-NUM TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.schedule.created.function(foo:bar,10," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /schedule a function" TO TL-CASE
    MOVE "schedule function foo:bar 10t" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    COMPUTE WS-NUM = CW-TICKS + 5
    MOVE WS-NUM TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.schedule.created.tag(foo:tag,5," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /schedule a function tag" TO TL-CASE
    MOVE "schedule function #foo:tag 5t" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    COMPUTE WS-NUM = CW-TICKS + 20
    MOVE WS-NUM TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.schedule.created.function(foo:bar,20," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /schedule a function in seconds appended" TO TL-CASE
    MOVE "schedule function foo:bar 1s append" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    COMPUTE WS-NUM = CW-TICKS + 2
    MOVE WS-NUM TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.schedule.created.function(minecraft:plain,2," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /schedule the default namespace is minecraft" TO TL-CASE
    MOVE "schedule function plain 2t append" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /schedule time 0 is the current tick" TO TL-CASE
    MOVE "schedule function foo:bar 0t" TO WS-LINE
    MOVE "commands.schedule.same_tick()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /schedule clear removes every schedule of the id" TO TL-CASE
    MOVE "schedule clear foo:bar" TO WS-LINE
    MOVE "commands.schedule.cleared.success(2,foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /schedule clear with none left" TO TL-CASE
    MOVE "schedule clear foo:bar" TO WS-LINE
    MOVE "commands.schedule.cleared.failure(foo:bar)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "schedule function foo:bar 20t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    COMPUTE WS-NUM = CW-TICKS + 30
    MOVE WS-NUM TO WS-EDIT
    MOVE SPACES TO WS-EXPECTED
    STRING "commands.schedule.created.function(foo:bar,30," DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE ")" DELIMITED BY SIZE INTO WS-EXPECTED
    MOVE "acceptance US13 /schedule replace drops the earlier schedule of the id" TO TL-CASE
    MOVE "schedule function foo:bar 30t replace" TO WS-LINE
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /schedule clear result is the number removed" TO TL-CASE
    MOVE "schedule clear foo:bar" TO WS-LINE
    MOVE 1 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    COMPUTE WS-NUM = CW-TICKS + 10
    MOVE WS-NUM TO WS-EXPECTED-N
    MOVE "acceptance US13 /schedule result is the trigger game time" TO TL-CASE
    MOVE "schedule function foo:bar 10t" TO WS-LINE
    CALL "TA-CHECK-N" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /schedule a player below level 2 cannot run it" TO TL-CASE
    MOVE "schedule clear foo:bar" TO WS-LINE
    MOVE "command.unknown.command() |" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-SCHEDULE.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
