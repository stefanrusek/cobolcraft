*> Lane bugbeitems (T42430 and on): a player's use of a bell sends Block Event 1 (play packet 7) with the hit face as the click direction (31 part 4 section 4.5, RS3-BELL-HIT of
*> 30 part 8 section 8.2): not from the top or bottom face, not above 0.8124 of the block's height, then by attachment the axes of the face and of the facing equal (floor, facing north:
*> faces north and south), different (single wall and double wall) or always (ceiling); a sneaking player with an item uses the item instead. The packet carries the position, action
*> 1, the face and the block id; a click that does not ring sends none. Another block is not a bell.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BELL-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE0              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-CURSOR              FLOAT-SHORT.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-PROP                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-NEW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-EVENTS              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-PARAM               BINARY-LONG.
 01 WS-PBLOCK              BINARY-LONG.
 01 WS-CASE                PIC X(120).
 01 WS-ATT                 PIC X(16).
 01 WS-FAC                 PIC X(8).
 01 WS-WANT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BOK                 BINARY-LONG.
*> The cases: attachment, facing, face of the click, cursor y in hundredths, rings 1 or 0.
 01 WS-CASES-DATA.
    05 FILLER PIC X(32) VALUE "floor       north   3 050 1".
    05 FILLER PIC X(32) VALUE "floor       north   2 050 1".
    05 FILLER PIC X(32) VALUE "floor       north   4 050 0".
    05 FILLER PIC X(32) VALUE "floor       north   1 050 0".
    05 FILLER PIC X(32) VALUE "floor       north   0 050 0".
    05 FILLER PIC X(32) VALUE "floor       north   3 090 0".
    05 FILLER PIC X(32) VALUE "floor       south   3 050 1".
    05 FILLER PIC X(32) VALUE "floor       east    5 080 1".
    05 FILLER PIC X(32) VALUE "floor       east    3 050 0".
    05 FILLER PIC X(32) VALUE "ceiling     north   4 050 1".
    05 FILLER PIC X(32) VALUE "single_wall north   3 050 0".
    05 FILLER PIC X(32) VALUE "single_wall north   4 050 1".
    05 FILLER PIC X(32) VALUE "double_wall west    2 050 1".
    05 FILLER PIC X(32) VALUE "double_wall west    5 050 0".
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-CASE-ROW OCCURS 14 TIMES.
       10 WS-C-ATT         PIC X(12).
       10 WS-C-FAC         PIC X(8).
       10 WS-C-FACE        PIC 9.
       10 FILLER           PIC X.
       10 WS-C-CUR         PIC 999.
       10 FILLER           PIC X.
       10 WS-C-RING        PIC 9.
       10 FILLER           PIC X(5).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     MOVE "N" TO TL-MODE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 22.5
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE "minecraft:bell" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE0 = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BX = WS-X0 + 24
     COMPUTE WS-BY = WS-FLOOR + 1
     COMPUTE WS-BZ = WS-Z0 + 24
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         MOVE WS-C-ATT(WS-I) TO WS-ATT
         MOVE WS-C-FAC(WS-I) TO WS-FAC
         MOVE WS-STATE0 TO WS-STATE
         MOVE "attachment" TO WS-PROP
         MOVE SPACES TO WS-TEXT
         MOVE FUNCTION TRIM(WS-ATT) TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-TEXT WS-NEW
         MOVE WS-NEW TO WS-STATE
         MOVE "facing" TO WS-PROP
         MOVE SPACES TO WS-TEXT
         MOVE FUNCTION TRIM(WS-FAC) TO WS-TEXT
         CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-TEXT WS-NEW
         MOVE WS-NEW TO WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         MOVE WS-C-FACE(WS-I) TO WS-FACE
         COMPUTE WS-CURSOR = WS-C-CUR(WS-I) / 100
         MOVE WS-C-RING(WS-I) TO WS-WANT
         PERFORM CLICK-AND-READ
         MOVE SPACES TO TL-CASE
         STRING "bugbeitems bell use " FUNCTION TRIM(WS-ATT) " " FUNCTION TRIM(WS-FAC) " face " WS-C-FACE(WS-I) " y " WS-C-CUR(WS-I)
             ": Block Event 1 sent (1) or not (0)" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-WANT TO TL-EXPECTED-N
         MOVE WS-EVENTS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         IF WS-WANT = 1
             MOVE SPACES TO TL-CASE
             STRING "bugbeitems bell use " FUNCTION TRIM(WS-ATT) " " FUNCTION TRIM(WS-FAC) " face " WS-C-FACE(WS-I)
                 ": the packet holds the position, action 1, the face and the bell block" DELIMITED BY SIZE INTO TL-CASE
             MOVE 0 TO WS-BOK
             IF WS-PBLOCK = WS-BLOCK
                 MOVE 1 TO WS-BOK
             END-IF
             COMPUTE TL-EXPECTED-N = (WS-BX * 7 + WS-BY * 3 + WS-BZ) * 1000 + 100 + WS-FACE * 10 + 1
             COMPUTE TL-OBSERVED-N = (WS-PX * 7 + WS-PY * 3 + WS-PZ) * 1000 + WS-ACTION * 100 + WS-PARAM * 10 + WS-BOK
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
*>   A sneaking player holding an item uses the item (no ring); sneaking with an empty hand rings.
     MOVE WS-STATE0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 3 TO WS-FACE
     MOVE 0.5 TO WS-CURSOR
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-ITEM(WS-PLAYER, 1)
     PERFORM CLICK-AND-READ
     MOVE "bugbeitems bell use: a sneaking player with an item does not ring it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EVENTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CLICK-AND-READ
     MOVE "bugbeitems bell use: a sneaking player with an empty hand rings it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EVENTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CLICK-AND-READ
     MOVE "bugbeitems bell use: a standing player with an item rings it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EVENTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Another block (the stone floor) is not a bell.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     COMPUTE WS-BY = WS-FLOOR
     PERFORM CLICK-AND-READ
     MOVE "bugbeitems bell use: a click on stone sends no Block Event" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EVENTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Drains what is queued, feeds a Use Item On (cursor y WS-CURSOR) on the block, drains again and counts the Block Events (packet 7) read into WS-EVENTS; the last one's fields
*> are WS-PX .. WS-PBLOCK.
 CLICK-AND-READ.
     PERFORM DRAIN-EVENTS
     CALL "TEST-USE-BELL" USING WS-CONN WS-BX WS-BY WS-BZ WS-FACE WS-CURSOR WS-SEQ
     PERFORM DRAIN-EVENTS.

 DRAIN-EVENTS.
     MOVE 0 TO WS-EVENTS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 7
             ADD 1 TO WS-EVENTS
             CALL "PB-GET-POSITION" USING PK-BUFFER WS-PX WS-PY WS-PZ
             CALL "PB-GET-UBYTE" USING PK-BUFFER WS-ACTION
             CALL "PB-GET-UBYTE" USING PK-BUFFER WS-PARAM
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-PBLOCK
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.
 END PROGRAM TEST-BELL-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-BELL.
*> USING connection id, x, y, z, face, cursor y (FLOAT-SHORT), sequence: Use Item On with the main hand, cursor (0.5, y, 0.5), not inside, no border hit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 66.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HALF                FLOAT-SHORT VALUE 0.5.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-CURSOR               FLOAT-SHORT.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-FACE L-CURSOR L-SEQUENCE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-FACE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-CURSOR
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-USE-BELL.
 COPY CORETEST.
 COPY MOBSPTEST.
