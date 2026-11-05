*> Implementation test of entity ids and the entity tracker (core/src/entities.cob; tasks T421;
*> US3-5; 09 §3.2 entity rows, §3.4 rule 7). Alice and Bob join at the spawn (view distance 2);
*> a sodgrazer entity is tracked, moved, taken out of and back into view, and removed. Each case
*> lists the packet ids Alice's client is sent.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ALICE               PIC X(16) VALUE "Alice".
 01 WS-BOB                 PIC X(16) VALUE "Bob".
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AROW                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 56.0.
 01 WS-Z                   FLOAT-LONG VALUE 3.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-ON-GROUND           BINARY-LONG VALUE 1.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-ALICE WS-FIVE WS-A
     CALL "TEST-JOIN" USING WS-BOB WS-THREE WS-B
     MOVE CN-PLAYER(WS-A) TO WS-AROW
     CALL "TEST-DRAIN-IDS" USING WS-A WS-IDS

     MOVE "test entities: network entity ids are unique per run: Alice 1, Bob 2, then 3 and 4"
         TO TL-CASE
     PERFORM START-ROW
     MOVE PL-ENTITY-ID(WS-AROW) TO WS-NUM
     PERFORM ADD-NUM
     MOVE PL-ENTITY-ID(CN-PLAYER(WS-B)) TO WS-NUM
     PERFORM ADD-NUM
     CALL "ENTITY-NEW-ID" USING WS-NUM
     PERFORM ADD-NUM
     CALL "ENTITY-NEW-ID" USING WS-NUM
     PERFORM ADD-NUM
     MOVE "1 2 3 4" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   A sodgrazer (entity id 20) at (12.5, 56.0, 3.5), chunk (0, 0).
     CALL "ENTITY-ALLOC" USING WS-ROW
     MOVE 20 TO EN-ID(WS-ROW)
     MOVE 2 TO EN-TYPE(WS-ROW)
     MOVE 1 TO EN-DIM(WS-ROW)
     MOVE 12.5 TO EN-X(WS-ROW) WS-X
     MOVE 56.0 TO EN-Y(WS-ROW)
     MOVE 3.5 TO EN-Z(WS-ROW)
     MOVE 1 TO EN-ON-GROUND(WS-ROW)

     MOVE "test entities: a player sees an entity iff same dimension and its chunk is within view "
         & "distance 2 of the player's center, and never its own entity" TO TL-CASE
     PERFORM START-ROW
     PERFORM ADD-SEES
     MOVE 47.9 TO EN-X(WS-ROW)
     PERFORM ADD-SEES
     MOVE 48.0 TO EN-X(WS-ROW)
     PERFORM ADD-SEES
     MOVE -32.0 TO EN-X(WS-ROW)
     PERFORM ADD-SEES
     MOVE -32.1 TO EN-X(WS-ROW)
     PERFORM ADD-SEES
     MOVE 12.5 TO EN-X(WS-ROW)
     MOVE 47.9 TO EN-Z(WS-ROW)
     PERFORM ADD-SEES
     MOVE 48.0 TO EN-Z(WS-ROW)
     PERFORM ADD-SEES
     MOVE 3.5 TO EN-Z(WS-ROW)
     MOVE 2 TO EN-DIM(WS-ROW)
     PERFORM ADD-SEES
     MOVE 1 TO EN-DIM(WS-ROW)
     CALL "ENTITY-SEES" USING WS-AROW PL-ENTITY-ROW(WS-AROW) WS-SEES
     MOVE WS-SEES TO WS-NUM
     PERFORM ADD-NUM
     MOVE "1 1 0 1 0 1 0 0 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test entities: tracking an entity in view sends Add Entity to both players' clients"
         TO TL-CASE
     CALL "ENTITY-TRACK" USING WS-ROW
     PERFORM START-ROW
     PERFORM ADD-ALICE-IDS
     PERFORM ADD-BOB-IDS
     MOVE "[1] [1]" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test entities: tracking it again sends nothing" TO TL-CASE
     CALL "ENTITY-TRACK" USING WS-ROW
     PERFORM START-ROW
     PERFORM ADD-ALICE-IDS
     MOVE "[]" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test entities: a small move is Move Entity Pos with the delta of "
         & "play-s2c-36-move-entity-pos.hex" TO TL-CASE
     MOVE 12.5625 TO WS-X
     PERFORM MOVE-ENTITY
     MOVE "contract/fixtures/wire/play-s2c-36-move-entity-pos.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test entities: a small move with a turn is Move Entity Pos Rot equal to "
         & "play-s2c-37-move-entity-pos-rot.hex, then Rotate Head" TO TL-CASE
     MOVE 3.4375 TO WS-Z
     MOVE 180 TO WS-YAW
     PERFORM MOVE-ENTITY
     MOVE "contract/fixtures/wire/play-s2c-37-move-entity-pos-rot.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test entities: a turn alone is Move Entity Rot equal to play-s2c-39-move-entity-rot.hex"
         & ", then Rotate Head equal to play-s2c-55-rotate-head.hex" TO TL-CASE
     MOVE -90 TO WS-YAW
     CALL "ENTITY-MOVE" USING WS-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-ON-GROUND
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-A PB-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/play-s2c-39-move-entity-rot.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "test entities: the Rotate Head after that Move Entity Rot equals "
         & "play-s2c-55-rotate-head.hex" TO TL-CASE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE "contract/fixtures/wire/play-s2c-55-rotate-head.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-B WS-IDS

     MOVE "test entities: a pitch change alone is Move Entity Rot without Rotate Head; no change "
         & "sends nothing; a move of 8 blocks or more is Teleport Entity" TO TL-CASE
     PERFORM START-ROW
     MOVE 20 TO WS-PITCH
     PERFORM MOVE-ENTITY-IDS
     PERFORM MOVE-ENTITY-IDS
     MOVE 22.5 TO WS-X
     PERFORM MOVE-ENTITY-IDS
     MOVE "[57] [] [128]" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test entities: moving out of view distance sends the move, then Remove Entities; "
         & "moving back sends Add Entity only" TO TL-CASE
     PERFORM START-ROW
     MOVE 100.5 TO WS-X
     PERFORM MOVE-ENTITY-IDS
     MOVE 12.5 TO WS-X
     PERFORM MOVE-ENTITY-IDS
     MOVE "[128 78] [1]" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test entities: removing the entity sends Remove Entities to both clients and frees "
         & "the row for reuse" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-B WS-IDS
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM START-ROW
     PERFORM ADD-ALICE-IDS
     PERFORM ADD-BOB-IDS
     MOVE EN-USED(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     CALL "ENTITY-ALLOC" USING WS-ROW2
     COMPUTE WS-NUM = WS-ROW2 - WS-ROW
     PERFORM ADD-NUM
     MOVE "[78] [78] 0 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     STOP RUN.

 MOVE-ENTITY.
     CALL "ENTITY-MOVE" USING WS-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-ON-GROUND.

 MOVE-ENTITY-IDS.
     PERFORM MOVE-ENTITY
     PERFORM ADD-ALICE-IDS.

*> The first packet Alice's client is sent equals the fixture WS-PATH; Bob's stream is emptied.
 SAME-AS-FIXTURE.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-A PB-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PK-BUFFER
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-B WS-IDS.

 ADD-SEES.
     CALL "ENTITY-SEES" USING WS-AROW WS-ROW WS-SEES
     MOVE WS-SEES TO WS-NUM
     PERFORM ADD-NUM.

 ADD-ALICE-IDS.
     CALL "TEST-DRAIN-IDS" USING WS-A WS-IDS
     PERFORM ADD-IDS.

 ADD-BOB-IDS.
     CALL "TEST-DRAIN-IDS" USING WS-B WS-IDS
     PERFORM ADD-IDS.

 ADD-IDS.
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     STRING "[" FUNCTION TRIM(WS-IDS) "]" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 START-ROW.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR.

 ADD-NUM.
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITIES.

 COPY CORETEST.
