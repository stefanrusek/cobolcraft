*> contract_wire_server.cob ground-item cases (test infrastructure; task T462;
*> docs/protocol/09-cobolcraft-profile.md §3.3 ground-item rows, §3.4 rule 6). Clientbound Add Entity
*> (cobolcraft:loose_item), Set Entity Data (item stack), Set Entity Motion and Take Item Entity equal
*> the core's builder output for each fixture's stated inputs; serverbound Player Action 5 DROP_ITEM
*> and 4 DROP_ALL_ITEMS decode with PLAY-DECODE (WIREBLOCK-DECODE-CASE).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-ITEM-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COLLECTOR           BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

*>   Serverbound.
     MOVE "contract wire server play-c2s-29-player-action-drop-item decodes: action 5, location "
         & "(0, 0, 0), face 0, sequence 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-drop-item.hex" TO WS-PATH
     MOVE "41 0 action 5 at 0 0 0 face 0 seq 0" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

     MOVE "contract wire server play-c2s-29-player-action-drop-all-items decodes: action 4, "
         & "location (0, 0, 0), face 0, sequence 0" TO TL-CASE
     MOVE "contract/fixtures/wire/play-c2s-29-player-action-drop-all-items.hex" TO WS-PATH
     MOVE "41 0 action 4 at 0 0 0 face 0 seq 0" TO TL-EXPECTED
     CALL "WIREBLOCK-DECODE-CASE" USING WS-PATH PB-BUFFER TESTLIB-ASSERT

*>   Clientbound.
     MOVE "contract wire server play-s2c-01-add-entity-loose-item equals the core's Add Entity of "
         & "the ground item entity id 10 spawned at (5.5, 53.25, 8.5) with motion (0, 0, 0)"
         TO TL-CASE
     MOVE 10 TO CW-NEXT-ENTITY-ID
     MOVE 5.5 TO WS-X
     MOVE 53.25 TO WS-Y
     MOVE 8.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VY WS-VZ
     MOVE 4 TO WS-ITEM
     MOVE 1 TO WS-COUNT
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-ADD-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-loose-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-65-set-entity-data-item equals the core's Set Entity Data "
         & "of entity 10 holding 1 x item 4 (turf)" TO TL-CASE
     MOVE 10 TO WS-ID
     CALL "PB-RESET" USING PB-BUFFER
     CALL "SET-ENTITY-DATA-ITEM-BUILD" USING WS-ID WS-ITEM WS-COUNT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-65-set-entity-data-item.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-67-set-entity-motion equals the core's Set Entity Motion "
         & "of entity 11 with motion (0.25, 0.12, 0.0)" TO TL-CASE
     MOVE 11 TO WS-ID
     MOVE 0.25 TO WS-VX
     MOVE 0.12 TO WS-VY
     MOVE 0 TO WS-VZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "SET-ENTITY-MOTION-BUILD" USING WS-ID WS-VX WS-VY WS-VZ PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-67-set-entity-motion.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-7f-take-item-entity equals the core's Take Item Entity "
         & "of entity 10 by collector 1, amount 1" TO TL-CASE
     MOVE 10 TO WS-ID
     MOVE 1 TO WS-COLLECTOR WS-COUNT
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TAKE-ITEM-ENTITY-BUILD" USING WS-ID WS-COLLECTOR WS-COUNT PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-7f-take-item-entity.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-ITEM-CASES.
