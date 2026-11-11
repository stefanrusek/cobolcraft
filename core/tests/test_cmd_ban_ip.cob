*> Acceptance test of docs/protocol/16-commands-catalog.md §11.4 `ban-ip`, §11.6 `pardon-ip` and §11.7 `banlist ips` (permission level 3, dedicated server): ban-ip <target> [<reason>] with
*> an IPv4 address adds it to the IP list (access.dat IpBans: creation time, source, forever, reason) and commands.banip.success [address, reason]
*> is broadcast; an address already listed is commands.banip.failed; a text that is no IPv4 address is commands.banip.invalid (a player's name would give
*> that player's address: BLOCKED, the core keeps no peer address; IPv6 addresses are BLOCKED); the result is the number of players disconnected (0).
*> pardon-ip removes an address (commands.pardonip.success; invalid; failed; result 1); banlist lists the IP bans after the players. Opal and Bob hold operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-BAN-IP.
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
 01 WS-SUF                 PIC X(128).
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
     MOVE "acceptance US13 /ban-ip ban-ip with an address: Banned IP 19" & "2.168.1.5: Banned by an operator." TO TL-CASE
     MOVE "ban-ip 192.168.1.5" TO WS-LINE
     MOVE "commands.banip.success(192.168.1.5,Banned by an operator.)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip the other operator is sent the comma" & "nd as chat.type.admin" TO TL-CASE
     MOVE "chat.type.admin(Opal,Banned IP 192.168.1.5: Banned by an ope" & "rator.)" TO WS-EXPECTED
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip with a reason" TO TL-CASE
     MOVE "ban-ip 10.0.0.1 griefing the spawn" TO WS-LINE
     MOVE "commands.banip.success(10.0.0.1,griefing the spawn)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /ban-ip two addresses are listed" TO TL-CASE
     MOVE AC-COUNT(4) TO WS-NUM
     MOVE 2 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban-ip an address that is already banned: N" & "othing changed. That IP is already banned" TO TL-CASE
     MOVE "ban-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.banip.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a player's name is not resolved (no " & "peer address): Invalid IP address or unknown player" TO TL-CASE
     MOVE "ban-ip Alice" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a group above 255 is invalid" TO TL-CASE
     MOVE "ban-ip 300.1.1.1" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip three groups are invalid" TO TL-CASE
     MOVE "ban-ip 1.2.3" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip five groups are invalid" TO TL-CASE
     MOVE "ban-ip 1.2.3.4.5" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip an empty group is invalid" TO TL-CASE
     MOVE "ban-ip 1..3.4" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a letter is invalid" TO TL-CASE
     MOVE "ban-ip 1.2.3.4a" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a trailing dot is invalid" TO TL-CASE
     MOVE "ban-ip 1.2.3." TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip four digits are invalid" TO TL-CASE
     MOVE "ban-ip 1.2.3.1234" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a text that is too short" TO TL-CASE
     MOVE "ban-ip 1.1" TO WS-LINE
     MOVE "commands.banip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip the result is the number of players " & "disconnected: 0" TO TL-CASE
     MOVE "ban-ip 172.16.0.9" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "acceptance US13 /ban-ip banlist ips: the count, then each en" & "try with the address, the source and the reason" TO TL-CASE
     MOVE "banlist ips" TO WS-LINE
     MOVE "commands.banlist.list(3) | commands.banlist.entry(192.168.1." & "5,Opal,Banned by an operator.) | commands.banlist.entry(10.0" & ".0.1,Opal,griefing the spawn) | commands.banlist.entry(172.1" & "6.0.9,Opal,Banned by an operator.)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip banlist players does not list addres" & "ses: There are no bans" TO TL-CASE
     MOVE "banlist players" TO WS-LINE
     MOVE "commands.banlist.none()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip the plain form lists the players and" & " then the addresses" TO TL-CASE
     MOVE "banlist" TO WS-LINE
     MOVE "commands.banlist.list(3) | commands.banlist.entry(192.168.1." & "5,Opal,Banned by an operator.) | commands.banlist.entry(10.0" & ".0.1,Opal,griefing the spawn) | commands.banlist.entry(172.1" & "6.0.9,Opal,Banned by an operator.)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip pardon-ip: Unbanned IP 10.0.0.1" TO TL-CASE
     MOVE "pardon-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.pardonip.success(10.0.0.1)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip an address that is not banned: Nothi" & "ng changed. That IP isn't banned" TO TL-CASE
     MOVE "pardon-ip 10.0.0.1" TO WS-LINE
     MOVE "commands.pardonip.failed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip a name is not an address: Invalid IP" & " address" TO TL-CASE
     MOVE "pardon-ip Alice" TO WS-LINE
     MOVE "commands.pardonip.invalid()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip the result is 1" TO TL-CASE
     MOVE "pardon-ip 192.168.1.5" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     CALL "ACCESS-DAT-WRITE"
     MOVE 0 TO AC-COUNT(4)
     CALL "ACCESS-DAT-READ"
     MOVE "acceptance US13 /ban-ip access.dat holds the IP list: the on" & "e address left is read back" TO TL-CASE
     MOVE AC-COUNT(4) TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /ban-ip a player without operator status doe" & "s not know the command" TO TL-CASE
     MOVE "ban-ip 1.2.3.4" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip the console prints the English text" TO TL-CASE
     MOVE "ban-ip 5.6.7.8 spam" TO WS-LINE
     MOVE "Banned IP 5.6.7.8: spam" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /ban-ip pardon-ip on the console" TO TL-CASE
     MOVE "pardon-ip 5.6.7.8" TO WS-LINE
     MOVE "Unbanned IP 5.6.7.8" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-BAN-IP.

 COPY CORETEST.
 COPY CMDTEST.
