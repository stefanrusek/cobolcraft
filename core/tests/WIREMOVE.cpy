*> contract_wire_server.cob movement and other-player cases (test infrastructure; tasks T412;
*> docs/protocol/09-cobolcraft-profile.md §3.2, §3.4 rules 7 and 10). Serverbound Move Player Pos,
*> Pos Rot, Rot, Status Only and Player Abilities decode with PLAY-DECODE to their stated values.
*> Clientbound Add Entity (operator), Player Info Update, Player Info Remove, Move Entity Pos, Pos
*> Rot, Rot, Rotate Head, Teleport Entity, Remove Entities and Forget Level Chunk equal the core's
*> builder output for each fixture's stated inputs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-MOVE-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 01 WS-ID                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ON-GROUND           BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ENTITY           BINARY-LONG OCCURS 16 TIMES.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-ALICE               PIC X(32) VALUE "10920508d5d83eed93d292f193afe7d7".
 01 WS-UUID                PIC X(16).
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE FUNCTION HEX-TO-CHAR(WS-ALICE) TO WS-UUID

*>   Serverbound.
     MOVE "contract wire server play-c2s-1e-move-player-pos decodes: (5.25, 54.0, 8.5), flags 1"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1e-move-player-pos.hex" TO WS-PATH
     MOVE "30 0 5.25 54.00 8.50 1" TO TL-EXPECTED
     CALL "WIREMOVE-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-1f-move-player-pos-rot decodes: (5.25, 54.0, 8.5), yaw "
         & "45.0, pitch 30.0, flags 1" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-1f-move-player-pos-rot.hex" TO WS-PATH
     MOVE "31 0 5.25 54.00 8.50 45.00 30.00 1" TO TL-EXPECTED
     CALL "WIREMOVE-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-20-move-player-rot decodes: yaw 45.0, pitch 30.0, flags 1"
         TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-20-move-player-rot.hex" TO WS-PATH
     MOVE "32 0 45.00 30.00 1" TO TL-EXPECTED
     CALL "WIREMOVE-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-21-move-player-status-only decodes: flags 3" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-21-move-player-status-only.hex" TO WS-PATH
     MOVE "33 0 3" TO TL-EXPECTED
     CALL "WIREMOVE-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-28-player-abilities decodes: flags 2 (flying)" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-28-player-abilities.hex" TO WS-PATH
     MOVE "40 0 2" TO TL-EXPECTED
     CALL "WIREMOVE-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-01-add-entity-operator equals the core's Add Entity of "
         & "Alice (entity 1, operator) at (4.5, 54.0, 8.5) yaw -90.0 pitch 0.0" TO TL-CASE
     INITIALIZE EN-ENTRY(1)
     MOVE 1 TO EN-ID(1)
     MOVE 0 TO EN-TYPE(1)
     MOVE WS-UUID TO EN-UUID(1)
     MOVE 4.5 TO EN-X(1)
     MOVE 54.0 TO EN-Y(1)
     MOVE 8.5 TO EN-Z(1)
     MOVE -90 TO EN-YAW(1)
     MOVE 0 TO EN-PITCH(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-ADD-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-operator.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     INITIALIZE EN-ENTRY(1)

     MOVE "contract wire server play-s2c-47-player-info-update equals the core's Player Info "
         & "Update of Alice" TO TL-CASE
     INITIALIZE PL-ENTRY(1)
     MOVE "Alice" TO PL-NAME(1)
     MOVE 5 TO PL-NAME-LENGTH(1)
     MOVE WS-UUID TO PL-UUID(1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAYER-INFO-UPDATE-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-47-player-info-update.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     INITIALIZE PL-ENTRY(1)

     MOVE "contract wire server play-s2c-46-player-info-remove equals the core's Player Info "
         & "Remove of Alice's UUID" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAYER-INFO-REMOVE-BUILD" USING WS-UUID PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-46-player-info-remove.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-36-move-entity-pos equals the core's Move Entity Pos of "
         & "entity 20, delta (256, 0, 0), on ground" TO TL-CASE
     MOVE 20 TO WS-ID
     MOVE 256 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     MOVE 1 TO WS-ON-GROUND
     CALL "PB-RESET" USING PB-BUFFER
     CALL "MOVE-ENTITY-POS-BUILD" USING WS-ID WS-DX WS-DY WS-DZ WS-ON-GROUND PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-36-move-entity-pos.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-37-move-entity-pos-rot equals the core's Move Entity Pos "
         & "Rot of entity 20, delta (0, 0, -256), on ground, yaw 180.0, pitch 0.0" TO TL-CASE
     MOVE 0 TO WS-DX
     MOVE -256 TO WS-DZ
     MOVE 180 TO WS-YAW
     MOVE 0 TO WS-PITCH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "MOVE-ENTITY-POS-ROT-BUILD" USING WS-ID WS-DX WS-DY WS-DZ WS-ON-GROUND WS-YAW WS-PITCH
         PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-37-move-entity-pos-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-39-move-entity-rot equals the core's Move Entity Rot of "
         & "entity 20, on ground, yaw -90.0, pitch 0.0" TO TL-CASE
     MOVE -90 TO WS-YAW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "MOVE-ENTITY-ROT-BUILD" USING WS-ID WS-ON-GROUND WS-YAW WS-PITCH PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-39-move-entity-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-55-rotate-head equals the core's Rotate Head of entity "
         & "20, head yaw -90.0" TO TL-CASE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ROTATE-HEAD-BUILD" USING WS-ID WS-YAW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-55-rotate-head.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-80-teleport-entity equals the core's Teleport Entity of "
         & "entity 1 to (100.5, 70.0, -20.5), motion 0, yaw -90.0, pitch 0.0, not on ground"
         TO TL-CASE
     MOVE 1 TO WS-ID
     MOVE 100.5 TO WS-X
     MOVE 70.0 TO WS-Y
     MOVE -20.5 TO WS-Z
     MOVE 0 TO WS-ON-GROUND
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TELEPORT-ENTITY-BUILD" USING WS-ID WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-YAW WS-PITCH
         WS-ON-GROUND PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-80-teleport-entity.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-4e-remove-entities equals the core's Remove Entities of "
         & "[10, 21]" TO TL-CASE
     MOVE 2 TO WS-COUNT
     MOVE 10 TO WS-ENTITY(1)
     MOVE 21 TO WS-ENTITY(2)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "REMOVE-ENTITIES-BUILD" USING WS-COUNT WS-IDS PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-4e-remove-entities.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-26-forget-level-chunk equals the core's Forget Level "
         & "Chunk of chunk (-9, 3)" TO TL-CASE
     MOVE -9 TO WS-DX
     MOVE 3 TO WS-DZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "FORGET-CHUNK-BUILD" USING WS-DX WS-DZ PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-26-forget-level-chunk.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-MOVE-CASES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIREMOVE-DECODE-CASE.
*> USING fixture path, scratch PB-BUFFER, TESTLIB-ASSERT (TL-CASE and TL-EXPECTED set): loads the
*> fixture, reads the packet id and decodes the rest with PLAY-DECODE. Observed text: packet id,
*> outcome, then the fields that packet has (position, yaw and pitch with two decimals, flags).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PLAYPKT.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT-REAL           PIC -(6)9.99.
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
     IF WS-PACKET-ID = 30 OR WS-PACKET-ID = 31
         MOVE PSB-X TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-Y TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-Z TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     IF WS-PACKET-ID = 31 OR WS-PACKET-ID = 32
         MOVE PSB-YAW TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
         MOVE PSB-PITCH TO WS-EDIT-REAL
         STRING " " FUNCTION TRIM(WS-EDIT-REAL) DELIMITED BY SIZE INTO TL-OBSERVED
             POINTER WS-PTR
     END-IF
     MOVE PSB-FLAGS TO WS-EDIT
     STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM WIREMOVE-DECODE-CASE.
