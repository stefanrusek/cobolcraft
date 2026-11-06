*> contract_wire_server.cob server pack cases (test infrastructure; task T720;
*> docs/protocol/09-cobolcraft-profile.md §3.1 rows 0x09, 0x06 and 0x02 (pack required); 08 §9.7,
*> §9.8; standin-content §17). Clientbound configuration Resource Pack Push, optional and required
*> with prompt, built by CONFIG-PACK-PUSH-BUILD from the pack settings the fixtures state, equals
*> its fixture; every configuration Resource Pack Response (actions 0 to 7) decodes to the stated
*> pack id and action; the configuration Disconnect of cobolcraft.disconnect.pack_required equals
*> config-s2c-02-disconnect-pack-required.hex.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-PACK-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-I                   BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-EDIT                PIC 9.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Resource Pack Push 0x09 from the fixtures' stated pack settings.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-PACK-OFFERED
     MOVE "00112233-4455-6677-8899-aabbccddeeff" TO CS-PACK-ID
     MOVE "http://127.0.0.1:8080/pack.zip" TO CS-PACK-URL
     MOVE "da39a3ee5e6b4b0d3255bfef95601890afd80709" TO CS-PACK-SHA1
     MOVE 0 TO CS-PACK-REQUIRED
     MOVE SPACES TO CS-PACK-PROMPT
     MOVE "contract wire server config-s2c-09-resource-pack-push-optional equals the core's "
         & "Resource Pack Push (not required, no prompt)" TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-optional.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-PACK-PUSH-BUILD" USING CORE-SETTINGS PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE 1 TO CS-PACK-REQUIRED
     MOVE "Please accept the CobolCraft pack" TO CS-PACK-PROMPT
     MOVE "contract wire server config-s2c-09-resource-pack-push-required-prompt equals the "
         & "core's Resource Pack Push (required, with prompt)" TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-09-resource-pack-push-required-prompt.hex"
         TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-PACK-PUSH-BUILD" USING CORE-SETTINGS PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   Resource Pack Response 0x06, every action: "6 0 <pack id hex> <action>".
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         MOVE WS-I TO WS-EDIT
         MOVE SPACES TO TL-CASE WS-PATH TL-EXPECTED
         STRING "contract wire server config-c2s-06-resource-pack-response-" WS-EDIT
             " decodes" DELIMITED BY SIZE INTO TL-CASE
         STRING "contract/fixtures/wire/config-c2s-06-resource-pack-response-" WS-EDIT
             ".hex" DELIMITED BY SIZE INTO WS-PATH
         STRING "6 0 00112233445566778899aabbccddeeff " WS-EDIT DELIMITED BY SIZE
             INTO TL-EXPECTED
         CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT
     END-PERFORM

*>   The pack-required configuration Disconnect 0x02 (standin §17).
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "contract wire server config-s2c-02-disconnect-pack-required equals the core's "
         & "configuration Disconnect of cobolcraft.disconnect.pack_required" TO TL-CASE
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-CONFIG TO CN-PHASE(WS-ID)
     MOVE MK-DC-PACK-REQUIRED TO WS-MSG
     CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
     CALL "CORE-SEND-DISCONNECT" USING WS-ID PB-TEXT
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID ST-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/config-s2c-02-disconnect-pack-required.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "CORE-CONN-CLOSED" USING WS-ID
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PK-BUFFER

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-PACK-CASES.
