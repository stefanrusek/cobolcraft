*> contract_wire_server.cob command cases (test infrastructure; task T637;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Commands rows and "Command tree", §3.2 rows 0x7C and
*> 0x20; standin-content §16, §17). Clientbound Commands for a player without and with operator
*> status, Command Suggestions, a command confirmation as System Chat and the stopping and
*> host-closed play Disconnects equal their fixtures; serverbound Chat Command and Command
*> Suggestion decode to their stated values.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CMD-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY CMDPARSE.
 COPY PLAYPKT.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OPERATOR            BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-MSG                 BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-TRANSACTION         BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Commands (0x10).
     MOVE "contract wire server play-s2c-10-commands-everyone equals the core's Commands for a "
         & "player without operator status (howto, roster, murmur: 6 nodes)" TO TL-CASE
     MOVE 0 TO WS-OPERATOR
     CALL "CMD-TREE-BUILD" USING WS-OPERATOR PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-10-commands-everyone.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "contract wire server play-s2c-10-commands-operator equals the core's Commands for a "
         & "player holding operator status (the full tree: 90 nodes)" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 1 TO WS-OPERATOR
     CALL "CMD-TREE-BUILD" USING WS-OPERATOR PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-10-commands-operator.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   Chat Command (C->S 0x07).
     MOVE "contract wire server play-c2s-07-chat-command decodes: command promote Alice (13 "
         & "bytes, no leading /)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-07-chat-command.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED POINTER WS-PTR
     MOVE PSB-MESSAGE-LENGTH TO WS-EDIT
     STRING " command " PSB-MESSAGE(1:FUNCTION MAX(PSB-MESSAGE-LENGTH, 1)) " length "
         FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "7 0 command promote Alice length 13" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Command Suggestion (C->S 0x0F) and Command Suggestions (S->C 0x0F).
     MOVE "contract wire server play-c2s-0f-command-suggestion decodes: transaction 1, text "
         & "/murmur Al (10 bytes)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0f-command-suggestion.hex" TO WS-PATH
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED POINTER WS-PTR
     MOVE PSB-TRANSACTION TO WS-EDIT
     STRING " transaction " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
         POINTER WS-PTR
     MOVE PSB-MESSAGE-LENGTH TO WS-EDIT
     STRING " text " PSB-MESSAGE(1:FUNCTION MAX(PSB-MESSAGE-LENGTH, 1)) " length "
         FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "15 0 transaction 1 text /murmur Al length 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract wire server play-s2c-0f-command-suggestions equals the core's Command "
         & "Suggestions for transaction 1, start 8, length 2, one suggestion Alice" TO TL-CASE
     MOVE 8 TO CG-START
     MOVE 2 TO CG-LENGTH
     MOVE 1 TO CG-COUNT
     MOVE "Alice" TO CG-TEXT(1)
     MOVE 5 TO CG-TEXT-LENGTH(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CMD-SUGGESTIONS-BUILD" USING WS-TRANSACTION PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-0f-command-suggestions.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   A command confirmation as System Chat (0x7C).
     MOVE "contract wire server play-s2c-7c-system-chat-command-feedback equals the core's System "
         & "Chat of cobolcraft.command.promote.done [Alice]" TO TL-CASE
     MOVE MK-PROMOTE-DONE TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CMD-TEXT-ARG" USING PB-TEXT WS-NAME WS-NAME-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "SYSTEM-CHAT-BUILD" USING PB-TEXT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-command-feedback.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   The stopping and host-closed play Disconnects (0x20, standin §17).
     MOVE "contract wire server play-s2c-20-disconnect-stopping equals the core's play Disconnect "
         & "of cobolcraft.disconnect.shutdown" TO TL-CASE
     MOVE MK-DC-SHUTDOWN TO WS-MSG
     MOVE "contract/fixtures/wire/play-s2c-20-disconnect-stopping.hex" TO WS-PATH
     PERFORM DISCONNECT-CASE
     MOVE "contract wire server play-s2c-20-disconnect-host-closed equals the core's play "
         & "Disconnect of cobolcraft.disconnect.host_closed" TO TL-CASE
     MOVE MK-DC-HOST-CLOSED TO WS-MSG
     MOVE "contract/fixtures/wire/play-s2c-20-disconnect-host-closed.hex" TO WS-PATH
     PERFORM DISCONNECT-CASE

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

*> A memory connection in play is sent the play Disconnect of message WS-MSG; its first packet
*> is compared with WS-PATH.
 DISCONNECT-CASE.
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-PLAY TO CN-PHASE(WS-ID)
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CORE-SEND-DISCONNECT" USING WS-ID PB-TEXT
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID ST-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

 END PROGRAM WIRE-CMD-CASES.
