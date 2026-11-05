*> contract_wire_server.cob chat cases (test infrastructure; task T479;
*> docs/protocol/09-cobolcraft-profile.md §1 "Chat is unsigned", §3.2 rows 0x09 and 0x7C). Serverbound
*> Chat (unsigned) decodes with PLAY-DECODE; clientbound System Chat (player chat line) equals the
*> core's builder output for the fixture's stated inputs (Alice, hello).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CHAT-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MESSAGE             PIC X(768) VALUE "hello".
 01 WS-MESSAGE-LENGTH      BINARY-LONG VALUE 5.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-09-chat decodes: message hello (5 bytes), signature "
         & "absent, last seen messages offset 0, nothing acknowledged" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-09-chat.hex" TO WS-PATH
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
     STRING " message " PSB-MESSAGE(1:FUNCTION MAX(PSB-MESSAGE-LENGTH, 1)) " length "
         FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "9 0 message hello length 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-7c-system-chat-chat equals the core's System Chat of the "
         & "chat line of Alice saying hello (literal <Alice> hello, overlay false)" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CHAT-LINE-BUILD" USING WS-NAME WS-NAME-LENGTH WS-MESSAGE WS-MESSAGE-LENGTH PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-7c-system-chat-chat.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-CHAT-CASES.
