*> Implementation test (002-lane-mobs, T4005; docs/protocol/18 sections 7.5 and 2.9): a standard mob that reaches 0 health does not vanish at
*> once. Its loot lands on the ground at that moment, Entity Event 3 (death) is sent to the viewers, and the row stays for 20 ticks
*> (deathTime) immobile and unhittable; at the 20th tick Entity Event 60 (poof) is sent and the row is removed (Remove Entities).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-DEATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-PORK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 10.
 01 WS-CAUSE               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-FOUND               BINARY-LONG.
 01 WS-EVENT-3             BINARY-LONG.
 01 WS-EVENT-60            BINARY-LONG.
 01 WS-BEFORE-X            FLOAT-LONG.
 01 WS-BEFORE-N            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:porkchop" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PORK WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT

*>   The lethal hit: the row stays, with 0 health, and the loot is on the ground.
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE "test stdmob death: a defeated pig stays as a dying row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-PIG) = 1 AND EN-TYPE(WS-PIG) = WS-PIG-TYPE AND EN-HEALTH(WS-PIG) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-PORK
     MOVE "test stdmob death: the loot is dropped at the moment of death" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT >= 1 AND WS-COUNT <= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     PERFORM FIND-EVENT
     MOVE "test stdmob death: the viewer is sent a packet 34 (Entity Event) at death" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dying mob takes no damage and drops no second loot.
     MOVE WS-COUNT TO WS-BEFORE-N
     MOVE 0 TO EN-HURT(WS-PIG)
     CALL "HEALTH-MOB-DAMAGE" USING WS-PIG WS-AMOUNT WS-CAUSE WS-PLAYER
     PERFORM COUNT-PORK
     MOVE "test stdmob death: a dying pig is not hit again and drops nothing more" TO TL-CASE
     MOVE WS-BEFORE-N TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   19 ticks later it is still there and has not moved; the 20th removes it.
     MOVE EN-X(WS-PIG) TO WS-BEFORE-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "MOB-STEP" USING WS-PIG
     END-PERFORM
     MOVE "test stdmob death: after 19 ticks the dying pig is still there, in place" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-PIG) = 1 AND EN-TYPE(WS-PIG) = WS-PIG-TYPE AND EN-X(WS-PIG) = WS-BEFORE-X
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     CALL "MOB-STEP" USING WS-PIG
     MOVE "test stdmob death: the 20th tick removes the pig" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-PIG) = 1 AND EN-TYPE(WS-PIG) = WS-PIG-TYPE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-ENTITIES" USING WS-CONN WS-TEXT
     PERFORM FIND-EVENT
     MOVE "test stdmob death: the poof (a packet 34) is sent at removal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FOUND
     INSPECT WS-TEXT TALLYING WS-FOUND FOR ALL "78("
     MOVE "test stdmob death: Remove Entities (packet 78) follows" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 COUNT-PORK.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > EN-COUNT
         IF EN-USED(WS-INDEX) = 1 AND EN-ITEM(WS-INDEX) = WS-PORK
             ADD EN-ITEM-COUNT(WS-INDEX) TO WS-COUNT
         END-IF
     END-PERFORM.
 FIND-EVENT.
*>   WS-FOUND = 1 when the drained text holds the token 34 (a packet id of 34 alone, between spaces).
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE WS-TEXT DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-FOUND
     INSPECT WS-PADDED TALLYING WS-FOUND FOR ALL " 34 "
     IF WS-FOUND > 0
         MOVE 1 TO WS-FOUND
     END-IF.
 END PROGRAM TEST-STDMOB-DEATH.
 COPY CORETEST.
