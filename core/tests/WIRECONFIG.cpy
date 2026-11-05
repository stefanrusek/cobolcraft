*> contract_wire_server.cob cases (test infrastructure): registries and the configuration phase
*> (09 §3.1 configuration table). Clientbound: every config-s2c fixture equals the core's builder
*> output for the fixture's stated inputs (REGISTRY-PACKET-BUILD, CONFIG-*-BUILD, KEEPALIVE-PACKET-BUILD).
*> Serverbound: every config-c2s fixture of US2 decodes with CONFIG-DECODE to its stated values.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-CONFIG-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY CORESTATE.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-I                   BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-PATH                PIC X(256).
*> Registry number (standin §4.2 #) and fixture name, in the order of 09 §3.1.
 01 WS-REGISTRY-ROWS.
    05 FILLER PIC X(48) VALUE "00worldgen-biome".
    05 FILLER PIC X(48) VALUE "01chat-type".
    05 FILLER PIC X(48) VALUE "04wolf-variant".
    05 FILLER PIC X(48) VALUE "05wolf-sound-variant".
    05 FILLER PIC X(48) VALUE "06pig-variant".
    05 FILLER PIC X(48) VALUE "07pig-sound-variant".
    05 FILLER PIC X(48) VALUE "08frog-variant".
    05 FILLER PIC X(48) VALUE "09cat-variant".
    05 FILLER PIC X(48) VALUE "10cat-sound-variant".
    05 FILLER PIC X(48) VALUE "11cow-sound-variant".
    05 FILLER PIC X(48) VALUE "12cow-variant".
    05 FILLER PIC X(48) VALUE "13chicken-sound-variant".
    05 FILLER PIC X(48) VALUE "14chicken-variant".
    05 FILLER PIC X(48) VALUE "15zombie-nautilus-variant".
    05 FILLER PIC X(48) VALUE "16painting-variant".
    05 FILLER PIC X(48) VALUE "18dimension-type".
    05 FILLER PIC X(48) VALUE "19damage-type".
    05 FILLER PIC X(48) VALUE "27world-clock".
 01 WS-REGISTRY-TABLE REDEFINES WS-REGISTRY-ROWS.
    05 WS-REGISTRY-ROW OCCURS 18 TIMES.
       10 WS-ROW-NUMBER    PIC 99.
       10 WS-ROW-NAME      PIC X(46).
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Registry Data, one fixture per registry with entries (09 §3.1; standin §4.2).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 18
         MOVE SPACES TO TL-CASE WS-PATH
         STRING "contract wire server config-s2c-07-registry-data-" DELIMITED BY SIZE
             FUNCTION TRIM(WS-ROW-NAME(WS-I)) DELIMITED BY SIZE
             " equals the core's Registry Data" DELIMITED BY SIZE INTO TL-CASE
         STRING "contract/fixtures/wire/config-s2c-07-registry-data-" DELIMITED BY SIZE
             FUNCTION TRIM(WS-ROW-NAME(WS-I)) DELIMITED BY SIZE ".hex" DELIMITED BY SIZE
             INTO WS-PATH
         MOVE WS-ROW-NUMBER(WS-I) TO WS-NUMBER
         CALL "PB-RESET" USING PB-BUFFER
         CALL "REGISTRY-PACKET-BUILD" USING WS-NUMBER PB-BUFFER
         CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     END-PERFORM

*>   Clientbound configuration packets.
     MOVE "contract wire server config-s2c-01-custom-payload-brand equals the core's brand"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-01-custom-payload-brand.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-BRAND-BUILD" USING PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server config-s2c-0d-update-enabled-features equals the core's features"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-0d-update-enabled-features.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-FEATURES-BUILD" USING PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server config-s2c-0f-select-known-packs equals the core's known packs"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-0f-select-known-packs.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-KNOWN-PACKS-BUILD" USING PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server config-s2c-0e-update-tags equals the core's Update Tags"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-0e-update-tags.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-TAGS-BUILD" USING PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server config-s2c-03-finish-configuration equals the core's Finish"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-03-finish-configuration.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-FINISH-BUILD" USING PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server config-s2c-04-keep-alive equals the core's Keep Alive 123456789"
         TO TL-CASE
     MOVE "contract/fixtures/wire/config-s2c-04-keep-alive.hex" TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     MOVE PH-CONFIG TO WS-PHASE
     MOVE 123456789 TO WS-LONG
     CALL "KEEPALIVE-PACKET-BUILD" USING WS-PHASE WS-LONG PB-BUFFER
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

*>   Serverbound configuration packets decode to their stated values.
     MOVE "contract wire server config-c2s-02-custom-payload-brand decodes" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     MOVE "2 0 minecraft:brand cobolcraft" TO TL-EXPECTED
     CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server config-c2s-00-client-information decodes" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     MOVE "0 0 en_us 8 0 1 0 1 0 1 0" TO TL-EXPECTED
     CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server config-c2s-07-select-known-packs decodes" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     MOVE "7 0 0" TO TL-EXPECTED
     CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server config-c2s-03-finish-configuration decodes" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     MOVE "3 0" TO TL-EXPECTED
     CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server config-c2s-04-keep-alive decodes" TO TL-CASE
     MOVE "contract/fixtures/wire/config-c2s-04-keep-alive.hex" TO WS-PATH
     MOVE "4 0 123456789" TO TL-EXPECTED
     CALL "WIRECONFIG-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-CONFIG-CASES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRECONFIG-DECODE-CASE.
*> USING fixture path, scratch PB-BUFFER, TESTLIB-ASSERT (TL-CASE and TL-EXPECTED set): loads the
*> fixture, reads the packet id and decodes the rest with CONFIG-DECODE. Observed text: packet id,
*> outcome, then the decoded values of that packet (WIRECONFIG-RENDER).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONFIGPKT.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY TESTLIB.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH PB-BUFFER TESTLIB-ASSERT.
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "CONFIG-DECODE" USING WS-PACKET-ID PB-BUFFER CONFIG-SERVERBOUND WS-OUTCOME
     CALL "WIRECONFIG-RENDER" USING WS-PACKET-ID WS-OUTCOME CONFIG-SERVERBOUND TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM WIRECONFIG-DECODE-CASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRECONFIG-RENDER.
*> USING packet id, outcome, CONFIG-SERVERBOUND, text out (PIC X(1024)): "<id> <outcome>" and the
*> values the packet carries, separated by single spaces. Client Information: language, view
*> distance, chat visibility, chat colors, model customisation, main hand, text filtering, allows
*> listing, particle status. Custom Payload: channel, brand. Keep Alive: id. Select Known Packs:
*> count. Resource Pack Response: action.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(18)9.
 LINKAGE SECTION.
 COPY CONFIGPKT.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-PACKET-ID L-OUTCOME CONFIG-SERVERBOUND L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE L-PACKET-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     MOVE L-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     EVALUATE L-PACKET-ID
         WHEN 0
             STRING " " CSB-LANGUAGE(1:CSB-LANGUAGE-LENGTH) DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-VIEW-DISTANCE TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-CHAT-VISIBILITY TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-CHAT-COLORS TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-MODEL-PARTS TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-MAIN-HAND TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-TEXT-FILTERING TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-ALLOWS-LISTING TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE CSB-PARTICLES TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         WHEN 2
             STRING " " CSB-CHANNEL(1:FUNCTION MIN(CSB-CHANNEL-LENGTH, 64)) " "
                 CSB-BRAND(1:FUNCTION MIN(CSB-BRAND-LENGTH, 64))
                 DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         WHEN 4
             MOVE CSB-KEEPALIVE TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         WHEN 6
             MOVE CSB-PACK-ACTION TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         WHEN 7
             MOVE CSB-KNOWN-PACKS TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     END-EVALUATE
     GOBACK.
 END PROGRAM WIRECONFIG-RENDER.
