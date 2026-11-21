*> Acceptance test, US14-5 core half and edge cases (spec US14 scenario 5; FR-016; docs/protocol/16 §op, deop and 15 §13): when an operator grants
*> or revokes operator status the sender is told (commands.op.success, commands.deop.success), the target is sent the Commands tree of
*> its new level at once (Entity Event 24 + level, then Commands 0x10), a repeat changes nothing, a name that never joined works through its
*> offline identity, the last operator may revoke her own status (the console keeps operator permission and can grant it again).
*> The stand-in notice and is_host cases have no counterpart in the standard texts. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-OP-CHANGE.
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
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     MOVE "acceptance US13 /op_change an operator grants operator statu" & "s: the sender is sent op.success" TO TL-CASE
     MOVE "op Alice" TO WS-LINE
     MOVE "commands.op.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change Alice is sent the permission Enti" & "ty Event (34), the Commands tree of her new level (16) at on" & "ce and the admin chat line" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-TEXT
     MOVE "34 16 124" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change granting to a player who holds it" & " changes nothing" TO TL-CASE
     MOVE "op Alice" TO WS-LINE
     MOVE "commands.op.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change Alice now holds operator status: " & "she may run an operator command" TO TL-CASE
     MOVE "time set 100" TO WS-LINE
     MOVE "commands.time.set.absolute(cobolcraft:daylight,100)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change an operator revokes: the sender i" & "s sent deop.success" TO TL-CASE
     MOVE "deop Alice" TO WS-LINE
     MOVE "chat.type.admin(Alice,Set cobolcraft:daylight to 100 tick(s)" & ") | commands.deop.success(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change Alice is sent the permission Enti" & "ty Event and the Commands tree of her new level (revoked)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-TEXT
     MOVE "34 16" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change revoking from a player who does n" & "ot hold it changes nothing" TO TL-CASE
     MOVE "deop Alice" TO WS-LINE
     MOVE "commands.deop.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change after the revoke Alice may not us" & "e an operator command" TO TL-CASE
     MOVE "time set 200" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change a name is looked up as typed: the" & " offline identity gets operator status" TO TL-CASE
     MOVE "op no-one" TO WS-LINE
     MOVE "commands.op.success(no-one)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change a valid offline player who has ne" & "ver joined works, the identity coming from the name's offlin" & "e UUID" TO TL-CASE
     MOVE "op Newbie" TO WS-LINE
     MOVE "commands.op.success(Newbie)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /op_change the last operator revokes her own" & " status: confirmed" TO TL-CASE
     MOVE "deop Opal" TO WS-LINE
     MOVE "commands.deop.success(Opal)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change after revoking her own status Opa" & "l may not use operator commands" TO TL-CASE
     MOVE "time set 5" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /op_change with no operator left the console" & " keeps operator permission and can grant it again" TO TL-CASE
     MOVE "op Opal" TO WS-LINE
     MOVE "Made Opal a server operator" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM ACC-US14-OP-CHANGE.

 COPY CORETEST.
 COPY CMDTEST.
