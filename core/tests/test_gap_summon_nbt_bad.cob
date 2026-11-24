*> Integration test (integrator, batch 11; docs/protocol/16 section 5.8): /summon of a table mob with an NBT argument that cannot be loaded as an entity (an empty Pos
*> list) still summons the mob, at the command's position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAP-SUMMON-NBT-BAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-FIND-X              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "integration US15 /summon with an NBT that cannot be loaded: the command still succeeds" TO TL-CASE
     MOVE "summon minecraft:cow 6.0 64.0 5.0 {Pos:[]}" TO WS-LINE
     MOVE "commands.summon.success(minecraft:cow)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "cow" TO WS-KEY-TEXT
     MOVE 6.0 TO WS-FIND-X
     PERFORM COUNT-MOBS
     MOVE "integration US15 /summon with an NBT that cannot be loaded: one cow stands at the command's x" TO TL-CASE
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     STOP RUN.

 COUNT-MOBS.
     MOVE 0 TO WS-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-X(WS-I) = WS-FIND-X
             COMPUTE WS-KEEP = EN-TYPE(WS-I) + 1
             IF ET-KEY(WS-KEEP) = WS-KEY-TEXT
                 ADD 1 TO WS-NUM
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-GAP-SUMMON-NBT-BAD.
 COPY CORETEST.
 COPY CMDTEST.
