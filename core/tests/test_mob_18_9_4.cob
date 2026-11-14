*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md sections 9.3 and 9.4): a freshly spawned mob is paired with the players in range in the same tick (Add Entity, then Set Entity Data of the non-default values, then Set Equipment); a mob out of range is not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-9-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO.
 COPY COREAPI.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§9.4 Sending the same data for a freshly spawned mob: a pig spawned in range is paired in the same tick, as one Add Entity (65 is not sent: no non-default data)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 200
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§9.1 Who tracks what: a pig spawned beyond the tracking range sends nothing" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " " TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 10
     CALL "ENTITY-MOVE" USING WS-PIG WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-ONE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§9.1 Who tracks what: moving it into range pairs it (Add Entity)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = PL-X(WS-PLAYER) + 200
     CALL "ENTITY-MOVE" USING WS-PIG WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-ONE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§9.1 Who tracks what: moving it out of range is a Teleport Entity (the 200 block jump does not fit a delta, 9.2) and then Remove Entities" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "128 78" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-9-4.
 COPY CORETEST.
