*> Acceptance test, US3-4 (spec US3 scenario 4; tasks T419; 09 §3.2 Set Chunk Cache Center, Level
*> Chunk With Light, Forget Level Chunk, Chunk Batch rows): a player (view distance 2, so a 5 x 5
*> square of chunks around the chunk of the feet) walks east across the border of chunks 0 and 1,
*> then north across the border of chunks 0 and -1. Each crossing sends Set Chunk Cache Center with
*> the new chunk, Forget Level Chunk for the 5 chunks that left the square, and one batch with the 5
*> chunks that entered it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US3-STREAMING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PACKET              BINARY-LONG VALUE 30.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 100.0.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-HIGH                BINARY-DOUBLE.
 01 WS-TWO-32              BINARY-DOUBLE VALUE 4294967296.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN

     MOVE "acceptance US3-4 given a player in chunk (0, 0) when they walk within the chunk then "
         & "no chunk packet is sent" TO TL-CASE
     MOVE 15.5 TO WS-X
     MOVE 8.5 TO WS-Z
     PERFORM MOVE-AND-LIST
     MOVE SPACES TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "acceptance US3-4 given a player walking east across the border of chunks 0 and 1 when "
         & "they move then Set Chunk Cache Center (1, 0), Forget Level Chunk for x -2 at z -2 to 2 "
         & "and a batch of the chunks x 3 at z -2 to 2 are sent" TO TL-CASE
     MOVE 16.5 TO WS-X
     PERFORM MOVE-AND-LIST
     MOVE "96(1,0) 38(-2,-2) 38(-2,-1) 38(-2,0) 38(-2,1) 38(-2,2) 12 46(3,-2) 46(3,-1) 46(3,0) "
         & "46(3,1) 46(3,2) 11(5)" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "acceptance US3-4 given a player walking north across the border of chunks 0 and -1 "
         & "when they move then Set Chunk Cache Center (1, -1), Forget Level Chunk for z 2 and a "
         & "batch of the chunks z -3 are sent" TO TL-CASE
     MOVE -0.5 TO WS-Z
     PERFORM MOVE-AND-LIST
     MOVE "96(1,-1) 38(-1,2) 38(0,2) 38(1,2) 38(2,2) 38(3,2) 12 46(-1,-3) 46(0,-3) 46(1,-3) "
         & "46(2,-3) 46(3,-3) 11(5)" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "acceptance US3-4 given those batches when the client acknowledges them then the "
         & "player has no batch pending (2 before) and its center is (1, -1)" TO TL-CASE
     PERFORM START-ROW
     MOVE PL-BATCH-PENDING(CN-PLAYER(WS-CONN)) TO WS-NUM
     PERFORM ADD-NUM
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE PL-BATCH-PENDING(CN-PLAYER(WS-CONN)) TO WS-NUM
     PERFORM ADD-NUM
     MOVE PL-CENTER-X(CN-PLAYER(WS-CONN)) TO WS-NUM
     PERFORM ADD-NUM
     MOVE PL-CENTER-Z(CN-PLAYER(WS-CONN)) TO WS-NUM
     PERFORM ADD-NUM
     MOVE "2 0 1 -1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "acceptance US3-4 given a player relocated far away when they move then every chunk "
         & "of the old square is forgotten and all 25 of the new square are sent" TO TL-CASE
     MOVE 200.5 TO WS-X
     MOVE 200.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-CONN WS-PACKET WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE "96 38x25 12 46x25 11" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     STOP RUN.

*> Moves to (WS-X, 100.0, WS-Z) in the air (no collision) and lists the drained packets: each id,
*> with the chunk coordinates for 96, 38 and 46 and the count for 11.
 MOVE-AND-LIST.
     CALL "TEST-MOVE" USING WS-CONN WS-PACKET WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     PERFORM START-ROW
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             PERFORM LIST-PACKET
         END-IF
     END-PERFORM.

 LIST-PACKET.
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF
     MOVE WS-PACKET-ID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     EVALUATE WS-PACKET-ID
         WHEN 96
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
             PERFORM ADD-FIRST
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
             PERFORM ADD-SECOND
         WHEN 46
             CALL "PB-GET-INT" USING PK-BUFFER WS-NUM
             PERFORM ADD-FIRST
             CALL "PB-GET-INT" USING PK-BUFFER WS-NUM
             PERFORM ADD-SECOND
         WHEN 38
             CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
             COMPUTE WS-LOW = FUNCTION MOD(WS-LONG, WS-TWO-32)
             COMPUTE WS-HIGH = (WS-LONG - WS-LOW) / WS-TWO-32
             IF WS-LOW >= WS-TWO-32 / 2
                 SUBTRACT WS-TWO-32 FROM WS-LOW
             END-IF
             MOVE WS-LOW TO WS-NUM
             PERFORM ADD-FIRST
             MOVE WS-HIGH TO WS-NUM
             PERFORM ADD-SECOND
         WHEN 11
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
             MOVE WS-NUM TO WS-EDIT
             STRING "(" FUNCTION TRIM(WS-EDIT) ")" DELIMITED BY SIZE INTO WS-TEXT
                 POINTER WS-PTR
     END-EVALUATE.

 ADD-FIRST.
     MOVE WS-NUM TO WS-EDIT
     STRING "(" FUNCTION TRIM(WS-EDIT) "," DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 ADD-SECOND.
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) ")" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

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
 END PROGRAM ACC-US3-STREAMING.

 COPY CORETEST.
