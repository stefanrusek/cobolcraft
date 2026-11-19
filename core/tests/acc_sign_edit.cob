*> Acceptance test, lane bugsign (operator report of try15: "can't edit sign text"; docs/protocol/31 part 3 sections 2.5 to 2.9, 05a 0x3D Open Sign Editor, 05c 0x3E Sign Update, 05a 0x06 Block Entity Data):
*> a superflat world (the standard content set, cheap generation; CC_GENERATED_DIR, skipped as a pass without it). A sign placed through Use Item On opens the editor for its placer (a Block Update, then
*> Open Sign Editor with the position and the front side); Sign Update with four lines stores them in the sign block entity, releases the editor lock and sends Block Entity Data to the viewers; a
*> second Sign Update without the lock is ignored; an empty-hand click on the sign opens the editor again; honeycomb waxes the sign (no editor, no edit), dye colours the text, a glow ink sac makes
*> it glow, an ink sac takes the glow away; a sign on the side of a block opens the editor too. Sign Update is a packet the core decodes (before this lane it closed the connection).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SIGN-EDIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
 COPY BESTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==UP-==.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BE                  BINARY-LONG.
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
 01 WS-OPEN-COUNT          BINARY-LONG.
 01 WS-OPEN-X              BINARY-LONG.
 01 WS-OPEN-Y              BINARY-LONG.
 01 WS-OPEN-Z              BINARY-LONG.
 01 WS-OPEN-SIDE           BINARY-LONG.
 01 WS-DATA-COUNT          BINARY-LONG.
 01 WS-DATA-X              BINARY-LONG.
 01 WS-DATA-Y              BINARY-LONG.
 01 WS-DATA-Z              BINARY-LONG.
 01 WS-DATA-TYPE           BINARY-LONG.
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-DATA-BYTES          PIC X(4096).
 01 WS-DATA-CAP            BINARY-LONG VALUE 4096.
 01 WS-HITS                BINARY-LONG.
 01 WS-LINE-1              PIC X(384).
 01 WS-LINE-2              PIC X(384).
 01 WS-LINE-3              PIC X(384).
 01 WS-LINE-4              PIC X(384).
 01 WS-LEN-1               BINARY-LONG.
 01 WS-LEN-2               BINARY-LONG.
 01 WS-LEN-3               BINARY-LONG.
 01 WS-LEN-4               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 384.
 01 WS-ID62                BINARY-LONG VALUE 62.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance sign edit no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Sign" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-STATE TO WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-X FROM WS-BX BY 1 UNTIL WS-X > WS-BX + 13
         PERFORM VARYING WS-Z FROM WS-BZ BY 1 UNTIL WS-Z > WS-BZ + 13
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 6.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 11.5
     MOVE 180 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     PERFORM SCAN

*>   A standing sign placed on the top of a stone block: the placer's editor opens for the front side.
     MOVE "oak_sign" TO WS-KEY112
     PERFORM HOLD-ITEM
     COMPUTE WS-SX = WS-BX + 6
     COMPUTE WS-SY = WS-FLOOR + 1
     COMPUTE WS-SZ = WS-BZ + 6
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-FLOOR WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     CALL "BE-FIND" USING WS-DIM WS-SX WS-SY WS-SZ WS-BE
     MOVE "acceptance sign edit: an oak_sign placed on a block has a sign block entity (type 7)" TO WS-CASE
     MOVE 7 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-BE > 0
         MOVE BE-TYPE(WS-BE) TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance sign edit: placing a sign sends Open Sign Editor (0x3D) to its placer, once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OPEN-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance sign edit: Open Sign Editor names the placed sign's position and the front side (1)" TO WS-CASE
     MOVE WS-SX TO WS-N1
     MOVE WS-SY TO WS-N2
     MOVE WS-SZ TO WS-N3
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) ",1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-OPEN-X TO WS-N1
     MOVE WS-OPEN-Y TO WS-N2
     MOVE WS-OPEN-Z TO WS-N3
     MOVE WS-OPEN-SIDE TO WS-N4
     STRING FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) "," FUNCTION TRIM(WS-N4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "acceptance sign edit: a Block Update (0x08) of the sign comes before Open Sign Editor (0x3D)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "8 61"
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N

*>   Sign Update with four lines: stored, lock released, Block Entity Data sent, the connection stays open.
     MOVE "Hello" TO WS-LINE-1
     MOVE 5 TO WS-LEN-1
     MOVE "World" TO WS-LINE-2
     MOVE 5 TO WS-LEN-2
     MOVE SPACES TO WS-LINE-3
     MOVE 0 TO WS-LEN-3
     MOVE "Bye" TO WS-LINE-4
     MOVE 3 TO WS-LEN-4
     MOVE 1 TO WS-SIDE
     PERFORM SEND-UPDATE
     PERFORM SCAN
     MOVE "acceptance sign edit: Sign Update keeps the connection open (the packet was a bad packet before)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-CLOSE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance sign edit: Sign Update stores the front lines Hello / World / (empty) / Bye" TO WS-CASE
     MOVE "Hello|World||Bye" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-BE > 0
         MOVE BE-XI(WS-BE, 6) TO WS-N1
         MOVE BE-XI(WS-BE, 7) TO WS-N2
         MOVE BE-XI(WS-BE, 9) TO WS-N4
         IF WS-N1 = 5 AND WS-N2 = 5 AND WS-N4 = 3
             STRING BE-XT(WS-BE, 1)(1:5) "|" BE-XT(WS-BE, 2)(1:5) "||" BE-XT(WS-BE, 4)(1:3) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-IF
     PERFORM CHECK-T
     MOVE "acceptance sign edit: the editor lock is released after the update" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE 1 TO WS-OBSERVE
     IF WS-BE > 0
         MOVE BE-XI(WS-BE, 3) TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance sign edit: Sign Update sends Block Entity Data (0x06) for the sign to the viewers, with its text" TO WS-CASE
     MOVE "1 at sign type 7 text" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     IF WS-DATA-LENGTH > 0
         INSPECT WS-DATA-BYTES(1:WS-DATA-LENGTH) TALLYING WS-HITS FOR ALL "Hello"
     END-IF
     IF WS-DATA-COUNT = 1 AND WS-DATA-X = WS-SX AND WS-DATA-Y = WS-SY AND WS-DATA-Z = WS-SZ AND WS-DATA-TYPE = 7 AND WS-HITS > 0
         MOVE "1 at sign type 7 text" TO TL-OBSERVED
     END-IF
     PERFORM CHECK-T

*>   A second Sign Update, without the lock: ignored.
     MOVE "Evil" TO WS-LINE-1
     MOVE 4 TO WS-LEN-1
     PERFORM SEND-UPDATE
     PERFORM SCAN
     MOVE "acceptance sign edit: a Sign Update without the editor lock changes nothing" TO WS-CASE
     MOVE "Hello" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-BE > 0
         MOVE BE-XT(WS-BE, 1)(1:5) TO TL-OBSERVED
     END-IF
     PERFORM CHECK-T

*>   Right click with an empty hand: the editor opens again (Block Update, Open Sign Editor), and a new Sign Update replaces the text.
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: an empty-hand click on a sign opens the editor (0x3D) at the sign, front side" TO WS-CASE
     MOVE WS-SX TO WS-N1
     MOVE WS-SY TO WS-N2
     MOVE WS-SZ TO WS-N3
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "1:" FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) ",1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-OPEN-COUNT TO WS-N5
     MOVE WS-OPEN-X TO WS-N1
     MOVE WS-OPEN-Y TO WS-N2
     MOVE WS-OPEN-Z TO WS-N3
     MOVE WS-OPEN-SIDE TO WS-N4
     STRING FUNCTION TRIM(WS-N5) ":" FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) ","
         FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "Again" TO WS-LINE-1
     MOVE 5 TO WS-LEN-1
     PERFORM SEND-UPDATE
     PERFORM SCAN
     MOVE "acceptance sign edit: the second edit replaces the first line" TO WS-CASE
     MOVE "Again" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE BE-XT(WS-BE, 1)(1:5) TO TL-OBSERVED
     PERFORM CHECK-T

*>   Dye, glow ink sac and ink sac on the side that has text.
     MOVE "red_dye" TO WS-KEY112
     PERFORM HOLD-ITEM
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: red dye on a sign with text colours it red (dye id 14) and uses one dye up" TO WS-CASE
     MOVE "14 4" TO TL-EXPECTED
     MOVE BE-XI(WS-BE, 4) TO WS-N1
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-N2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "acceptance sign edit: dyeing the sign sends Block Entity Data and no editor" TO WS-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE WS-DATA-COUNT TO WS-N1
     MOVE WS-OPEN-COUNT TO WS-N2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE "glow_ink_sac" TO WS-KEY112
     PERFORM HOLD-ITEM
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: a glow ink sac makes the text glow" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE BE-XI(WS-BE, 5) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "ink_sac" TO WS-KEY112
     PERFORM HOLD-ITEM
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: an ink sac takes the glow away" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE BE-XI(WS-BE, 5) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Honeycomb waxes the sign: no editor for a click, and no edit.
     MOVE "honeycomb" TO WS-KEY112
     PERFORM HOLD-ITEM
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: honeycomb waxes the sign and is used up" TO WS-CASE
     MOVE "1 4" TO TL-EXPECTED
     MOVE BE-XI(WS-BE, 1) TO WS-N1
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-N2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-N1) " " FUNCTION TRIM(WS-N2) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-USE-ON" USING WS-CONN WS-SX WS-SY WS-SZ WS-FACE WS-SEQ
     PERFORM SCAN
     MOVE "acceptance sign edit: a click on a waxed sign opens no editor" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OPEN-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "Waxed" TO WS-LINE-1
     MOVE 5 TO WS-LEN-1
     PERFORM SEND-UPDATE
     PERFORM SCAN
     MOVE "acceptance sign edit: a Sign Update of a waxed sign changes nothing" TO WS-CASE
     MOVE "Again" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE BE-XT(WS-BE, 1)(1:5) TO TL-OBSERVED
     PERFORM CHECK-T

*>   A sign placed on the side of a stone block is a wall sign and opens the editor too.
     MOVE "oak_sign" TO WS-KEY112
     PERFORM HOLD-ITEM
     COMPUTE WS-X = WS-BX + 9
     COMPUTE WS-Z = WS-BZ + 9
     COMPUTE WS-Y = WS-FLOOR + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 3 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM SCAN
     COMPUTE WS-SZ = WS-Z + 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-SZ WS-STATE
     MOVE "oak_wall_sign" TO WS-KEY
     PERFORM FIND-STATE-BLOCK
     MOVE "acceptance sign edit: an oak_sign clicked on the south face of a block becomes an oak_wall_sign" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-E TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance sign edit: the wall sign opens the editor for its placer too (front side)" TO WS-CASE
     MOVE WS-X TO WS-N1
     MOVE WS-Y TO WS-N2
     MOVE WS-SZ TO WS-N3
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING "1:" FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) ",1" DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-OPEN-COUNT TO WS-N5
     MOVE WS-OPEN-X TO WS-N1
     MOVE WS-OPEN-Y TO WS-N2
     MOVE WS-OPEN-Z TO WS-N3
     MOVE WS-OPEN-SIDE TO WS-N4
     STRING FUNCTION TRIM(WS-N5) ":" FUNCTION TRIM(WS-N1) "," FUNCTION TRIM(WS-N2) "," FUNCTION TRIM(WS-N3) ","
         FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM CHECK-T
     STOP RUN.

*> Puts five of the item WS-KEY112 in the first hotbar slot and selects it.
 HOLD-ITEM.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER).

*> Drains what Alice was sent: WS-IDS the packet ids in order, WS-CLOSE the close flag, the Open Sign Editor packets (count, last position and side) and the last Block Entity
*> Data (count, position, type, the bytes of its compound).
 SCAN.
     MOVE SPACES TO WS-IDS
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-OPEN-COUNT WS-DATA-COUNT WS-DATA-LENGTH
     MOVE 0 TO WS-OPEN-X WS-OPEN-Y WS-OPEN-Z WS-OPEN-SIDE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
             END-IF
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-IDS POINTER WS-PTR
             IF WS-PACKET-ID = 61
                 ADD 1 TO WS-OPEN-COUNT
                 CALL "PB-GET-POSITION" USING PK-BUFFER WS-OPEN-X WS-OPEN-Y WS-OPEN-Z
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-OPEN-SIDE
             END-IF
             IF WS-PACKET-ID = 6
                 ADD 1 TO WS-DATA-COUNT
                 CALL "PB-GET-BLOCK-ENTITY-DATA" USING PK-BUFFER WS-DATA-X WS-DATA-Y WS-DATA-Z WS-DATA-TYPE WS-DATA-BYTES
                     WS-DATA-CAP WS-DATA-LENGTH
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER.

*> Feeds Sign Update (05c 0x3E): the position WS-SX, WS-SY, WS-SZ, the four lines WS-LINE-n of WS-LEN-n bytes and the side WS-SIDE.
 SEND-UPDATE.
     CALL "PB-INIT" USING UP-BUFFER WS-SMALL
     CALL "PB-PUT-VARINT" USING UP-BUFFER WS-ID62
     CALL "PB-PUT-POSITION" USING UP-BUFFER WS-SX WS-SY WS-SZ
     CALL "PB-PUT-STRING" USING UP-BUFFER WS-LINE-1 WS-LEN-1 WS-MAX
     CALL "PB-PUT-STRING" USING UP-BUFFER WS-LINE-2 WS-LEN-2 WS-MAX
     CALL "PB-PUT-STRING" USING UP-BUFFER WS-LINE-3 WS-LEN-3 WS-MAX
     CALL "PB-PUT-STRING" USING UP-BUFFER WS-LINE-4 WS-LEN-4 WS-MAX
     CALL "PB-PUT-VARINT" USING UP-BUFFER WS-SIDE
     CALL "TEST-FEED-BUFFER" USING WS-CONN UP-BUFFER
     CALL "PB-FREE" USING UP-BUFFER.

*> WS-STATE: the default state of the block WS-KEY (a key without namespace in the generated set), 0 when the table has none.
 FIND-STATE.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-STATE
         END-IF
     END-PERFORM.

*> WS-E: 1 when the state WS-STATE belongs to the block WS-KEY.
 FIND-STATE-BLOCK.
     MOVE 0 TO WS-E
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         IF FUNCTION TRIM(CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1)) = FUNCTION TRIM(WS-KEY)
             MOVE 1 TO WS-E
         END-IF
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-T.
     MOVE "T" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SIGN-EDIT.
 COPY CORETEST.
