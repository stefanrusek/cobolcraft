*> contract_wire_server.cob mob cases (test infrastructure; task T528;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Mobs rows; standin-content §3, §12). Clientbound Add
*> Entity of each mob type equals the core's builder output for the fixture's stated inputs: a mob
*> spawned (MOB-SPAWN) with that entity id, position and yaw; the movement field is (0, 0, 0) even
*> while the mob is falling.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIRE-MOB-CASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CORESTATE.
 COPY ETIDS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY

     MOVE "contract wire server play-s2c-01-add-entity-sodgrazer equals the core's Add Entity of "
         & "the sodgrazer entity id 20 spawned at (12.5, 56.0, 3.5) with yaw 90" TO TL-CASE
     MOVE 20 TO CW-NEXT-ENTITY-ID
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 12.5 TO WS-X
     MOVE 56 TO WS-Y
     MOVE 3.5 TO WS-Z
     MOVE 90 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-ADD-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-sodgrazer.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT

     MOVE "contract wire server play-s2c-01-add-entity-abend equals the core's Add Entity of the "
         & "abend entity id 21 spawned at (-3.5, 52.0, -6.5) with yaw 180, while it falls"
         TO TL-CASE
     MOVE ET-ABEND TO WS-TYPE
     MOVE -3.5 TO WS-X
     MOVE 52 TO WS-Y
     MOVE -6.5 TO WS-Z
     MOVE 180 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE -0.048 TO EN-VY(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-ADD-BUILD" USING WS-ROW PB-BUFFER
     MOVE "contract/fixtures/wire/play-s2c-01-add-entity-abend.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIRE-MOB-CASES.
