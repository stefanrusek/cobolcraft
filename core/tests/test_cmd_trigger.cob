*> Acceptance test of docs/protocol/16-commands-catalog.md §9.3 `trigger` (permission level 0) with 14a: the objective must be a trigger objective and the player's score must exist
*> and not be locked (scoreboard players enable unlocks it); a trigger locks it and adds 1, adds the value or sets the value; the result is the new value. Opal holds operator status, Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-TRIGGER.
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
    MOVE "scoreboard objectives add t trigger" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "scoreboard objectives add d dummy" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger a player with no score cannot trigger yet" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE "commands.trigger.failed.unprimed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE "commands.trigger.simple.success(t)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /trigger trigger again is locked until enabled" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE "commands.trigger.failed.unprimed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger result is the new value" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE 2 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger add" TO TL-CASE
    MOVE "trigger t add 5" TO WS-LINE
    MOVE "commands.trigger.add.success(t,5)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger add result is the new value" TO TL-CASE
    MOVE "trigger t add 3" TO WS-LINE
    MOVE 10 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger set" TO TL-CASE
    MOVE "trigger t set 4" TO WS-LINE
    MOVE "commands.trigger.set.success(t,4)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger trigger set result is the value" TO TL-CASE
    MOVE "trigger t set 9" TO WS-LINE
    MOVE 9 TO WS-EXPECTED-N
    CALL "TA-CHECK-N" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED-N
    MOVE "acceptance US13 /trigger the value is the score" TO TL-CASE
    MOVE "scoreboard players get Alice t" TO WS-LINE
    MOVE "commands.scoreboard.players.get.success(Alice,9,t)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /trigger a non-trigger objective" TO TL-CASE
    MOVE "trigger d" TO WS-LINE
    MOVE "commands.trigger.failed.invalid()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /trigger an unknown objective" TO TL-CASE
    MOVE "trigger zzz" TO WS-LINE
    MOVE "arguments.objective.notFound(zzz)" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
    MOVE "acceptance US13 /trigger the console is not a player" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE "A player is required to run this command here" TO WS-EXPECTED
    CALL "TA-CHECK-CONSOLE" USING TL-CASE WS-LINE WS-EXPECTED
    MOVE "scoreboard players enable Alice t" TO WS-LINE
    CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
    MOVE "acceptance US13 /trigger a player whose score was never made cannot trigger" TO TL-CASE
    MOVE "trigger t" TO WS-LINE
    MOVE "commands.trigger.failed.unprimed()" TO WS-EXPECTED
    CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
    GOBACK.
 END PROGRAM TEST-CMD-TRIGGER.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
