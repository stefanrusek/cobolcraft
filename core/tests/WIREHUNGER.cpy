*> contract_wire_server.cob hunger cases (test infrastructure; tasks T504, T505;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Hunger rows; standin-content §11.2, §11.6).
*> Clientbound Entity Event (eating finished) equals the core's builder output for the fixture's
*> stated inputs; serverbound Use Item, Player Action 6 RELEASE_USE_ITEM and Player Command 1
*> START_SPRINTING and 2 STOP_SPRINTING decode with PLAY-DECODE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-HUNGER-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY RULES.
 COPY PROTO.
 COPY PLAYPKT.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-EDIT4               PIC -(9)9.
 01 WS-EDIT5               PIC -(9)9.
 01 WS-ALICE-ID            BINARY-LONG VALUE 1.
 01 WS-EVENT               BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-43-use-item decodes: hand 0, sequence 5, yaw -90, "
         & "pitch 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-43-use-item.hex" TO WS-PATH
     PERFORM DECODE
     MOVE PSB-HAND TO WS-EDIT3
     MOVE PSB-SEQUENCE TO WS-EDIT4
     STRING " hand " FUNCTION TRIM(WS-EDIT3) " sequence " FUNCTION TRIM(WS-EDIT4)
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE PSB-YAW TO WS-EDIT3
     MOVE PSB-PITCH TO WS-EDIT4
     STRING " yaw " FUNCTION TRIM(WS-EDIT3) " pitch " FUNCTION TRIM(WS-EDIT4)
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "67 0 hand 0 sequence 5 yaw -90 pitch 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-29-player-action-release-use-item decodes: action 6 "
         & "RELEASE_USE_ITEM at (0, 0, 0), face 0, sequence 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-release-use-item.hex" TO WS-PATH
     PERFORM DECODE
     MOVE PSB-ACTION TO WS-EDIT3
     STRING " action " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
         POINTER WS-PTR
     MOVE PSB-BX TO WS-EDIT3
     MOVE PSB-BY TO WS-EDIT4
     MOVE PSB-BZ TO WS-EDIT5
     STRING " at " FUNCTION TRIM(WS-EDIT3) " " FUNCTION TRIM(WS-EDIT4) " "
         FUNCTION TRIM(WS-EDIT5) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE PSB-FACE TO WS-EDIT3
     MOVE PSB-SEQUENCE TO WS-EDIT4
     STRING " face " FUNCTION TRIM(WS-EDIT3) " sequence " FUNCTION TRIM(WS-EDIT4)
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "41 0 action 6 at 0 0 0 face 0 sequence 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-2a-player-command-start-sprinting decodes: entity 1, "
         & "action 1 START_SPRINTING, data 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2a-player-command-start-sprinting.hex" TO WS-PATH
     PERFORM DECODE-COMMAND
     MOVE "42 0 entity 1 action 1 data 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-2a-player-command-stop-sprinting decodes: entity 1, "
         & "action 2 STOP_SPRINTING, data 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2a-player-command-stop-sprinting.hex" TO WS-PATH
     PERFORM DECODE-COMMAND
     MOVE "42 0 entity 1 action 2 data 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-22-entity-event-eating-finished equals the core's "
         & "Entity Event of entity 1 with event id 9 (eating finished)" TO TL-CASE
     MOVE RULE-EAT-EVENT TO WS-EVENT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-EVENT-BUILD" USING WS-ALICE-ID WS-EVENT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-22-entity-event-eating-finished.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

 DECODE.
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE WS-OUTCOME TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
         INTO TL-OBSERVED POINTER WS-PTR.

 DECODE-COMMAND.
     PERFORM DECODE
     MOVE PSB-TARGET TO WS-EDIT3
     MOVE PSB-ACTION TO WS-EDIT4
     MOVE PSB-DATA TO WS-EDIT5
     STRING " entity " FUNCTION TRIM(WS-EDIT3) " action " FUNCTION TRIM(WS-EDIT4) " data "
         FUNCTION TRIM(WS-EDIT5) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR.
 END PROGRAM WIRE-HUNGER-CASES.
