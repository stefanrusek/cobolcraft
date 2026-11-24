*> Acceptance test of docs/protocol/15-commands-framework.md §10 Execution (the part the standard commands reach; the execute clauses, forks and
*> the fork limit of §10.1 and §10.2 are BLOCKED with execute): the two game rules that size the execution context (§10.1) have their defaults,
*> the result of a command is its int (§10.2), success feedback goes to the source and, broadcast, to the other operators as chat.type.admin (§10.3),
*> the rule send_command_feedback silences both, failures ignore it, the console always accepts, a parse error and an execution error are different
*> failures (§10.4). Opal and Bob hold operator status; Alice does not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
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
 01 WS-RULE-NAME            PIC X(40).
 01 WS-RULE-VALUE           BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 15§10 Execution max_command_sequence_length " & "defaults to 65536" TO TL-CASE
     MOVE "max_command_sequence_length" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 65536 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 15§10 Execution max_command_forks defaults t" & "o 65536" TO TL-CASE
     MOVE "max_command_forks" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 65536 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 15§10 Execution send_command_feedback defaul" & "ts to true" TO TL-CASE
     MOVE "send_command_feedback" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 15§10 Execution log_admin_commands defaults " & "to true" TO TL-CASE
     MOVE "log_admin_commands" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE-VALUE
     MOVE WS-RULE-VALUE TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 15§10 Execution the result of a command is t" & "he int it returns (say: 1)" TO TL-CASE
     MOVE "say hi" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 15§10 Execution the int of msg is the number" & " of targets" TO TL-CASE
     MOVE "msg @a hi" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 15§10 Execution success feedback goes to the" & " source" TO TL-CASE
     MOVE "time set 5" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution the broadcast goes to the ot" & "her operators wrapped as chat.type.admin with the source's n" & "ame and the message" TO TL-CASE
     MOVE "chat.type.admin(Opal,Set cobolcraft:daylight to 5 tick(s))" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution a player without operator st" & "atus is sent no admin broadcast" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution the command that turns the r" & "ule off is already silent (the value is stored before the fe" & "edback is sent)" TO TL-CASE
     MOVE "gamerule send_command_feedback false" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 15§10 Execution with send_command_feedback f" & "alse a player source gets no success feedback" TO TL-CASE
     MOVE "time set 6" TO WS-LINE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution and no admin broadcast is se" & "nt either" TO TL-CASE
     MOVE SPACES TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution a failure ignores the rule" TO TL-CASE
     MOVE "time set 6" TO WS-LINE
     MOVE "commands.time.set.already_at_time(cobolcraft:daylight,6)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution the console always accepts s" & "uccess feedback" TO TL-CASE
     MOVE "time set 7" TO WS-LINE
     MOVE "Set cobolcraft:daylight to 7 tick(s)" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution a parse error is the parse f" & "ailure with its context line (two messages, 15 §4.6)" TO TL-CASE
     MOVE "frobnicate" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution the rule set back on: its fe" & "edback is sent" TO TL-CASE
     MOVE "gamerule send_command_feedback true" TO WS-LINE
     MOVE "commands.gamerule.set(send_command_feedback,true)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution an execution failure raised " & "by the command itself is a plain failure message" TO TL-CASE
     MOVE "time set soon" TO WS-LINE
     MOVE "commands.time.no_time_marker_found(minecraft:soon,cobolcraft" & ":daylight)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 15§10 Execution an exception thrown while th" & "e command resolves its targets is an execution failure witho" & "ut a context line" TO TL-CASE
     MOVE "gamemode survival Zed" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-15-10.

 COPY CORETEST.
 COPY CMDTEST.
