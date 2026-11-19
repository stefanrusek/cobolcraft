*> Implementation test, lane bugsign (core/src/play.cob PLAY-DECODE and PLAY-PACKET for Sign Update 0x3E, core/src/sign-edit.cob; docs/protocol/05c 0x3E, 31 part 3 sections 2.8, 2.9): the packet decodes
*> into the position, the side and four lines (a line of multi-byte characters keeps its byte length, a line above 384 code units, a cut-short packet and trailing bytes are malformed); through the core a
*> Sign Update for a position with no block entity or a block entity that is no sign changes nothing and keeps the connection open, one for a sign without the editor lock is refused, one under the lock
*> stores the lines of the side (back for side 0 and for an out-of-range side), releases the lock and sends one Block Entity Data; the editor lock ends when its player is gone or farther than 4.0
*> from the sign (SIGN-LOCK-TICK, 2.9); SIGN-ITEM-KIND names the sign applicators by item key (honeycomb, ink sac, glow ink sac, a dye with its id) and nothing else.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SIGN-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY BESTATE.
 COPY PLAYPKT.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-SMALL               BINARY-LONG VALUE 4096.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-IDS                 PIC X(512).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-N1                  PIC -(9)9.
 01 WS-N2                  PIC -(9)9.
 01 WS-N3                  PIC -(9)9.
 01 WS-N4                  PIC -(9)9.
 01 WS-N5                  PIC -(9)9.
 01 WS-ID62                BINARY-LONG VALUE 62.
 01 WS-MAX                 BINARY-LONG VALUE 384.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-LINE-1              PIC X(400).
 01 WS-LINE-2              PIC X(400).
 01 WS-LINE-3              PIC X(400).
 01 WS-LINE-4              PIC X(400).
 01 WS-LEN-1               BINARY-LONG.
 01 WS-LEN-2               BINARY-LONG.
 01 WS-LEN-3               BINARY-LONG.
 01 WS-LEN-4               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SIGN                BINARY-LONG.
 01 WS-HANGING             BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HAS-DATA            BINARY-LONG.
 01 WS-DATA-COUNT          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OTHER-UUID          PIC X(16) VALUE "0123456789abcdef".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM

*>   The decode.
     MOVE 3 TO WS-SX
     MOVE 70 TO WS-SY
     MOVE -5 TO WS-SZ
     MOVE "Hi" TO WS-LINE-1
     MOVE 2 TO WS-LEN-1
     MOVE SPACES TO WS-LINE-2
     MOVE 0 TO WS-LEN-2
     MOVE SPACES TO WS-LINE-3
     MOVE FUNCTION CHAR(196) TO WS-LINE-3(1:1)
     MOVE FUNCTION CHAR(134) TO WS-LINE-3(2:1)
     MOVE 2 TO WS-LEN-3
     MOVE "last line" TO WS-LINE-4
     MOVE 9 TO WS-LEN-4
     MOVE 1 TO WS-SIDE
     PERFORM BUILD-UPDATE
     PERFORM DECODE
     MOVE "implementation Sign Update 0x3E: decodes position and side" TO TL-CASE
     MOVE "0 3,70,-5 1" TO TL-EXPECTED
     MOVE WS-OUTCOME TO WS-N1
     MOVE PSB-BX TO WS-N2
     MOVE PSB-BY TO WS-N3
     MOVE PSB-BZ TO WS-N4
     MOVE PSB-DATA TO WS-N5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) "," FUNCTION TRIM(WS-N4) " " FUNCTION TRIM(WS-N5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "implementation Sign Update 0x3E: the byte lengths of four lines (a two-byte character is one unit)" TO TL-CASE
     MOVE "2,0,2,9" TO TL-EXPECTED
     MOVE PSB-SIGN-LENGTH(1) TO WS-N1
     MOVE PSB-SIGN-LENGTH(2) TO WS-N2
     MOVE PSB-SIGN-LENGTH(3) TO WS-N3
     MOVE PSB-SIGN-LENGTH(4) TO WS-N4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) "," FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "implementation Sign Update 0x3E: the line texts are kept" TO TL-CASE
     MOVE "Hi|last line" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING PSB-SIGN-TEXT(1)(1:2) "|" PSB-SIGN-TEXT(4)(1:9) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     CALL "PB-FREE" USING PB-BUFFER

     MOVE ALL "a" TO WS-LINE-2
     MOVE 385 TO WS-LEN-2
     PERFORM BUILD-UPDATE-RAW
     PERFORM DECODE
     MOVE "implementation Sign Update 0x3E: a line of 385 code units is malformed (outcome 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER

     MOVE SPACES TO WS-LINE-2
     MOVE 0 TO WS-LEN-2
     PERFORM BUILD-UPDATE
     MOVE 8 TO WS-I
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-I
     PERFORM DECODE
     MOVE "implementation Sign Update 0x3E: a byte left over is malformed (outcome 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER

     CALL "PB-INIT" USING PB-BUFFER WS-SMALL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID62
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-SX WS-SY WS-SZ
     PERFORM DECODE
     MOVE "implementation Sign Update 0x3E: a packet cut after the position is malformed (outcome 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER

*>   Through the core: a sign, a hanging sign and a chest entity near the player (the entities need no block).
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-SY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-SZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE "minecraft:oak_sign" TO WS-KEY
     MOVE 18 TO WS-KEY-LENGTH
     MOVE 7 TO WS-TYPE
     CALL "BE-CREATE" USING WS-DIM WS-SX WS-SY WS-SZ WS-TYPE WS-KEY WS-KEY-LENGTH WS-SIGN
     COMPUTE WS-SX = WS-SX + 1
     MOVE "minecraft:oak_hanging_sign" TO WS-KEY
     MOVE 26 TO WS-KEY-LENGTH
     MOVE 8 TO WS-TYPE
     CALL "BE-CREATE" USING WS-DIM WS-SX WS-SY WS-SZ WS-TYPE WS-KEY WS-KEY-LENGTH WS-HANGING
     COMPUTE WS-SX = WS-SX + 1
     MOVE "minecraft:chest" TO WS-KEY
     MOVE 15 TO WS-KEY-LENGTH
     MOVE 1 TO WS-TYPE
     CALL "BE-CREATE" USING WS-DIM WS-SX WS-SY WS-SZ WS-TYPE WS-KEY WS-KEY-LENGTH WS-CHEST
     PERFORM DRAIN

     MOVE "Edit" TO WS-LINE-1
     MOVE 4 TO WS-LEN-1
     MOVE "Two" TO WS-LINE-2
     MOVE 3 TO WS-LEN-2
     MOVE SPACES TO WS-LINE-3
     MOVE 0 TO WS-LEN-3
     MOVE SPACES TO WS-LINE-4
     MOVE 0 TO WS-LEN-4
     MOVE 1 TO WS-SIDE
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW)) + 5
     PERFORM FEED-UPDATE
     PERFORM DRAIN
     MOVE "implementation Sign Update 0x3E: for a position with no block entity the connection stays open and nothing is sent" TO TL-CASE
     MOVE "0 " TO TL-EXPECTED
     MOVE WS-CLOSE TO WS-N1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW)) + 2
     PERFORM FEED-UPDATE
     PERFORM DRAIN
     MOVE "implementation Sign Update 0x3E: a chest's position is no sign, nothing is sent" TO TL-CASE
     MOVE "0 " TO TL-EXPECTED
     MOVE WS-CLOSE TO WS-N1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW))
     PERFORM FEED-UPDATE
     PERFORM DRAIN
     MOVE "implementation Sign Update 0x3E: a sign without the editor lock is not changed and nothing is sent" TO TL-CASE
     MOVE "0 0 " TO TL-EXPECTED
     MOVE BE-XI(WS-SIGN, 6) TO WS-N2
     MOVE WS-CLOSE TO WS-N1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

*>   The lock held by Alice: the front lines are stored and one Block Entity Data goes out.
     MOVE 1 TO BE-XI(WS-SIGN, 3)
     MOVE SPACES TO BE-XT(WS-SIGN, 17)
     MOVE PL-UUID(WS-ROW) TO BE-XT(WS-SIGN, 17)(1:16)
     PERFORM FEED-UPDATE
     PERFORM DRAIN
     MOVE "implementation Sign Update 0x3E: under the lock the front lines are stored, the lock is released and one Block Entity Data (6) is sent" TO TL-CASE
     MOVE "Edit|Two 0 6" TO TL-EXPECTED
     MOVE BE-XI(WS-SIGN, 3) TO WS-N1
     MOVE SPACES TO TL-OBSERVED
     STRING BE-XT(WS-SIGN, 1)(1:4) "|" BE-XT(WS-SIGN, 2)(1:3) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-IDS)
         DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

*>   The hanging sign, the back side (0): the back lines (XT 9 to 12).
     COMPUTE WS-SX = FUNCTION INTEGER(PL-X(WS-ROW)) + 1
     MOVE 1 TO BE-XI(WS-HANGING, 3)
     MOVE SPACES TO BE-XT(WS-HANGING, 17)
     MOVE PL-UUID(WS-ROW) TO BE-XT(WS-HANGING, 17)(1:16)
     MOVE 0 TO WS-SIDE
     PERFORM FEED-UPDATE
     PERFORM DRAIN
     MOVE "implementation Sign Update 0x3E: a hanging sign's back side (0) takes the lines into its back text" TO TL-CASE
     MOVE "Edit|Two 0 0 6" TO TL-EXPECTED
     MOVE BE-XI(WS-HANGING, 3) TO WS-N1
     MOVE BE-XI(WS-HANGING, 6) TO WS-N2
     MOVE SPACES TO TL-OBSERVED
     STRING BE-XT(WS-HANGING, 9)(1:4) "|" BE-XT(WS-HANGING, 10)(1:3) " " FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) " "
         FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T

*>   The lock of a player who is gone ends on the tick; one who stands within 4.0 keeps it; one farther away loses it.
     MOVE 1 TO BE-XI(WS-SIGN, 3)
     MOVE SPACES TO BE-XT(WS-SIGN, 17)
     MOVE WS-OTHER-UUID TO BE-XT(WS-SIGN, 17)(1:16)
     CALL "SIGN-LOCK-TICK" USING WS-SIGN
     MOVE "implementation sign editor lock 2.9: the lock of a player who is not in the world ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BE-XI(WS-SIGN, 3) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE 1 TO BE-XI(WS-SIGN, 3)
     MOVE SPACES TO BE-XT(WS-SIGN, 17)
     MOVE PL-UUID(WS-ROW) TO BE-XT(WS-SIGN, 17)(1:16)
     CALL "SIGN-LOCK-TICK" USING WS-SIGN
     MOVE "implementation sign editor lock 2.9: the lock of a player within 4.0 of the sign stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BE-XI(WS-SIGN, 3) TO TL-OBSERVED-N
     PERFORM CHECK-N
     ADD 30 TO PL-X(WS-ROW)
     CALL "SIGN-LOCK-TICK" USING WS-SIGN
     MOVE "implementation sign editor lock 2.9: the lock of a player 30 blocks away ends" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BE-XI(WS-SIGN, 3) TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "implementation sign editor lock 2.9: a sign nobody edits is left alone" TO TL-CASE
     CALL "SIGN-LOCK-TICK" USING WS-SIGN
     MOVE 0 TO TL-EXPECTED-N
     MOVE BE-XI(WS-SIGN, 3) TO TL-OBSERVED-N
     PERFORM CHECK-N

*>   The applicators by item key.
     MOVE 8 TO IT-COUNT
     MOVE "honeycomb" TO IT-KEY(2)
     MOVE 9 TO IT-KEY-LENGTH(2)
     MOVE "minecraft:glow_ink_sac" TO IT-KEY(3)
     MOVE 22 TO IT-KEY-LENGTH(3)
     MOVE "red_dye" TO IT-KEY(4)
     MOVE 7 TO IT-KEY-LENGTH(4)
     MOVE "stick" TO IT-KEY(5)
     MOVE 5 TO IT-KEY-LENGTH(5)
     MOVE "foo_dye" TO IT-KEY(6)
     MOVE 7 TO IT-KEY-LENGTH(6)
     MOVE "ink_sac" TO IT-KEY(7)
     MOVE 7 TO IT-KEY-LENGTH(7)
     MOVE "minecraft:white_dye" TO IT-KEY(8)
     MOVE 19 TO IT-KEY-LENGTH(8)
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-ITEM FROM 0 BY 1 UNTIL WS-ITEM > 8
         COMPUTE WS-I = WS-ITEM
         CALL "SIGN-ITEM-KIND" USING WS-I WS-KIND WS-DYE
         MOVE WS-KIND TO WS-N1
         MOVE WS-DYE TO WS-N2
         STRING FUNCTION TRIM(WS-N1) "/" FUNCTION TRIM(WS-N2) " " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-PERFORM
     MOVE "implementation SIGN-ITEM-KIND: none, honeycomb 4, glow ink sac 3, red dye 1 id 14, stick none, foo_dye none, ink sac 2, minecraft:white_dye 1 id 0" TO TL-CASE
     MOVE "0/-1 4/-1 3/-1 1/14 0/-1 0/-1 2/-1 1/0 0/-1" TO TL-EXPECTED
     PERFORM CHECK-T
     STOP RUN.

*> Builds Sign Update from WS-SX, WS-SY, WS-SZ, the four lines WS-LINE-n of WS-LEN-n bytes and WS-SIDE in PB-BUFFER.
 BUILD-UPDATE.
     CALL "PB-INIT" USING PB-BUFFER WS-SMALL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID62
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-SX WS-SY WS-SZ
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-1 WS-LEN-1 WS-MAX
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-2 WS-LEN-2 WS-MAX
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-3 WS-LEN-3 WS-MAX
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-4 WS-LEN-4 WS-MAX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SIDE.

*> The same with line 2 written raw (the encoder would refuse more than 384 code units): length VarInt, then the bytes.
 BUILD-UPDATE-RAW.
     CALL "PB-INIT" USING PB-BUFFER WS-SMALL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID62
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-SX WS-SY WS-SZ
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-1 WS-LEN-1 WS-MAX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-LEN-2
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-LINE-2 WS-LEN-2
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-3 WS-LEN-3 WS-MAX
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LINE-4 WS-LEN-4 WS-MAX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SIDE.

*> Decodes the packet in PB-BUFFER (from its start) with PLAY-DECODE into WS-OUTCOME.
 DECODE.
     MOVE 0 TO PB-POS
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PLAY-DECODE" USING WS-PACKET-ID PB-BUFFER PLAY-SERVERBOUND WS-OUTCOME.

 FEED-UPDATE.
     PERFORM BUILD-UPDATE
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER.

*> WS-IDS: the packet ids sent to Alice in order, without Recipe Book Add (75) and Set Time; WS-CLOSE the close flag.
 DRAIN.
     MOVE SPACES TO WS-IDS
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID NOT = 75
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
             END-IF
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-T.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-SIGN-UPDATE.
 COPY CORETEST.
