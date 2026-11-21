*> contract_wire_server.cob play-join cases (test infrastructure; docs/protocol/09-cobolcraft-profile.md
*> §3.2). Clientbound: Login, Game Event 13 and 3, Player Position, Player Abilities (creative and
*> survival), Set Default Spawn Position, Set Time, Set Held Slot, Set Player Inventory and Container
*> Set Content (empty) equal the core's builder output for each fixture's stated inputs.
*> Serverbound: Accept Teleportation, Player Loaded, Client Tick End and play Keep Alive decode with
*> PLAY-DECODE to their stated values.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-PLAY-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-MODE                PIC 9.
 01 WS-FLYING              PIC 9.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "contract wire server play-s2c-32-login-main equals the core's Login for entity id 1, "
         & "survival, cobolcraft:main, view distance 8" TO TL-CASE
     INITIALIZE PL-ENTRY(1)
     MOVE 1 TO PL-ENTITY-ID(1)
     MOVE 0 TO PL-MODE(1)
     MOVE 1 TO PL-DIM(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-LOGIN-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-32-login-main.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-27-game-event-13-wait-chunks equals the core's Game "
         & "Event 13 value 0.0" TO TL-CASE
     MOVE 13 TO WS-NUMBER
     MOVE 0 TO WS-VALUE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-GAME-EVENT-BUILD" USING WS-NUMBER WS-VALUE PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-13-wait-chunks.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-27-game-event-03-game-mode equals the core's Game "
         & "Event 3 value 0.0 (survival)" TO TL-CASE
     MOVE 3 TO WS-NUMBER
     MOVE 0 TO WS-VALUE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-GAME-EVENT-BUILD" USING WS-NUMBER WS-VALUE PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-03-game-mode.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-49-player-position equals the core's Player Position "
         & "teleport 1 at (4.5, 54.0, 8.5) yaw -90.0 pitch 0.0" TO TL-CASE
     MOVE 1 TO WS-NUMBER
     MOVE 4.5 TO WS-X
     MOVE 54.0 TO WS-Y
     MOVE 8.5 TO WS-Z
     MOVE -90 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-POSITION-BUILD" USING WS-NUMBER WS-X WS-Y WS-Z WS-YAW WS-PITCH PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-49-player-position.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-41-player-abilities-creative equals the core's "
         & "abilities for creative, not flying" TO TL-CASE
     MOVE 1 TO WS-MODE
     MOVE 0 TO WS-FLYING
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING WS-MODE WS-FLYING PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-41-player-abilities-survival equals the core's "
         & "abilities for survival" TO TL-CASE
     MOVE 0 TO WS-MODE
     MOVE 0 TO WS-FLYING
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-ABILITIES-BUILD" USING WS-MODE WS-FLYING PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-survival.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-63-set-default-spawn-position equals the core's spawn "
         & "position of a new world: cobolcraft:main (4, 54, 8) yaw -90.0" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-SPAWN-POSITION-BUILD" USING PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-63-set-default-spawn-position.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-73-set-time equals the core's Set Time for time 6000"
         TO TL-CASE
     MOVE 6000 TO WS-TIME
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-TIME-BUILD" USING WS-TIME PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-73-set-time.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-6b-set-held-slot equals the core's Set Held Slot 0"
         TO TL-CASE
     MOVE 0 TO WS-NUMBER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-HELD-SLOT-BUILD" USING WS-NUMBER PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-6e-set-player-inventory equals the core's Set Player "
         & "Inventory slot 0, 63 x item 2" TO TL-CASE
     MOVE 0 TO WS-NUMBER
     MOVE 63 TO PB-IS-COUNT
     MOVE 2 TO PB-IS-ITEM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-INVENTORY-SLOT-BUILD" USING WS-NUMBER PB-ITEMSTACK PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-6e-set-player-inventory.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-12-container-set-content-empty equals the core's "
         & "Container Set Content of an empty inventory, state id 1" TO TL-CASE
     INITIALIZE PL-ENTRY(1)
     MOVE 1 TO PL-STATE-ID(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "core/tests/fixtures/play-s2c-12-container-set-content-empty-46.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     INITIALIZE PL-ENTRY(1)

*>   Serverbound play packets of the join decode to their stated values.
     MOVE "contract wire server play-c2s-00-accept-teleportation decodes: teleport id 1, "
         & "(4.5, 54.0, 8.5), yaw -90.0, pitch 0.0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-00-accept-teleportation.hex" TO WS-PATH
     MOVE "0 0 1 4.5 54.0 8.5 -90.0 0.0" TO TL-EXPECTED
     CALL "WIREPLAY-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-2c-player-loaded decodes (no fields)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-2c-player-loaded.hex" TO WS-PATH
     MOVE "44 0" TO TL-EXPECTED
     CALL "WIREPLAY-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-0d-client-tick-end decodes (no fields)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-0d-client-tick-end.hex" TO WS-PATH
     MOVE "13 0" TO TL-EXPECTED
     CALL "WIREPLAY-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-1c-keep-alive decodes: id 81985529216486895"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1c-keep-alive.hex" TO WS-PATH
     MOVE "28 0 81985529216486895" TO TL-EXPECTED
     CALL "WIREPLAY-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-PLAY-CASES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIREPLAY-DECODE-CASE.
*> USING fixture path, scratch PB-BUFFER, TESTLIB-ASSERT (TL-CASE and TL-EXPECTED set): loads the
*> fixture, reads the packet id and decodes the rest with PLAY-DECODE. Observed text: packet id,
*> outcome, then the decoded values of that packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PLAYPKT.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(18)9.
 01 WS-EDIT-REAL           PIC -(6)9.9.
 LINKAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH PB-BUFFER TESTLIB-ASSERT.
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-PACKET-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     EVALUATE WS-PACKET-ID
         WHEN 0
             MOVE PSB-TELEPORT-ID TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
             MOVE PSB-X TO WS-EDIT-REAL
             STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
             MOVE PSB-Y TO WS-EDIT-REAL
             STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
             MOVE PSB-Z TO WS-EDIT-REAL
             STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
             MOVE PSB-YAW TO WS-EDIT-REAL
             STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
             MOVE PSB-PITCH TO WS-EDIT-REAL
             STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
         WHEN 28
             MOVE PSB-KEEPALIVE TO WS-EDIT
             STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
                 POINTER WS-PTR
     END-EVALUATE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM WIREPLAY-DECODE-CASE.
