*> Acceptance test of docs/protocol/16-commands-catalog.md §7.3 `fillbiome` (permission level 2): both corners are quantised down to multiples of 4, the box between
*> them is limited by max_block_modifications (commands.fillbiome.toobig [max, requested]), every chunk column of the box must be loaded
*> (argument.pos.unloaded); the biome cells whose block position lies in the box and that pass `replace <filter>` take the biome, a cell already of that biome is not
*> counted, the changed chunks are marked unsaved and their biomes are sent again (Chunks Biomes 0x0D); commands.fillbiome.success.count [count, x1, y1, z1, x2, y2,
*> z2] is broadcast and the result is the number of cells; none changed is commands.fillbiome.no_changes. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-FILLBIOME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SUGGESTION-ID       BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
*>   The corners 0 100 0 and 15 110 15 quantise to 0 100 0 and 12 108 12: 4 x 3 x 4 cells.
     MOVE "acceptance US13 /fillbiome the cells of the quantised box: 48 biome entries set" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.fillbiome.success.count(48,0,100,0,12,108,12)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome the first cell holds the biome (ash_flats is id 2)" TO TL-CASE
     MOVE 0 TO WS-BX WS-BZ
     MOVE 100 TO WS-BY
     MOVE 2 TO WS-EXPECTED-N
     PERFORM ASSERT-CELL
     MOVE "acceptance US13 /fillbiome the last cell of the box" TO TL-CASE
     MOVE 12 TO WS-BX WS-BZ
     MOVE 108 TO WS-BY
     PERFORM ASSERT-CELL
     MOVE "acceptance US13 /fillbiome the cell above the box is untouched" TO TL-CASE
     MOVE 112 TO WS-BY
     MOVE 0 TO WS-BX
     PERFORM ASSERT-CELL-NOT
     MOVE "acceptance US13 /fillbiome the cell of the next chunk is untouched" TO TL-CASE
     MOVE 16 TO WS-BX
     MOVE 100 TO WS-BY
     PERFORM ASSERT-CELL-NOT
     MOVE "acceptance US13 /fillbiome the chunk is marked unsaved" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-NUM
     IF CK-CHANGED(WS-ROW) = 1
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fillbiome the same biome again: No biome entries were changed" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.fillbiome.no_changes()" TO WS-EXPECTED
     PERFORM RUN-TEXT
*>   replace <filter>.
     MOVE "acceptance US13 /fillbiome replace: only cells of the filter biome change" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 cobolcraft:upland replace cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.fillbiome.success.count(48,0,100,0,12,108,12)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome replace with a filter that no cell has" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 minecraft:plains replace cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.fillbiome.no_changes()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome replace with a tag that holds no cell biome" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 minecraft:plains replace #cobolcraft:no_such_tag" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome a tag without a namespace is in minecraft:" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 minecraft:plains replace #no_such_tag" TO WS-LINE
     PERFORM RUN-TEXT
*>   Default namespace and a single cell.
     MOVE "acceptance US13 /fillbiome a plain name is looked up in the set's namespace and minecraft: (plains)" TO TL-CASE
     MOVE "fillbiome 0 100 0 3 100 3 plains" TO WS-LINE
     MOVE "commands.fillbiome.success.count(1,0,100,0,0,100,0)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome the cell is plains (id 0)" TO TL-CASE
     MOVE 0 TO WS-BX WS-BZ
     MOVE 100 TO WS-BY
     MOVE 0 TO WS-EXPECTED-N
     PERFORM ASSERT-CELL
*>   Negative coordinates quantise down.
     MOVE "acceptance US13 /fillbiome negative corners go down to the multiple of 4" TO TL-CASE
     MOVE "fillbiome -1 100 -1 -1 100 -1 cobolcraft:ash_flats" TO WS-LINE
     MOVE "commands.fillbiome.success.count(1,-4,100,-4,-4,100,-4)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome the cell of chunk -1 -1 holds it" TO TL-CASE
     MOVE -4 TO WS-BX WS-BZ
     MOVE 2 TO WS-EXPECTED-N
     PERFORM ASSERT-CELL
*>   The corners in either order, the result value.
     MOVE "acceptance US13 /fillbiome the corners in either order: the result is the count" TO TL-CASE
     MOVE "fillbiome 8 104 8 0 100 0 cobolcraft:ash_flats" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 18 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
*>   The packet.
     MOVE "fillbiome 0 120 0 3 120 3 cobolcraft:ash_flats" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-ID-OPAL WS-LINE
     MOVE "acceptance US13 /fillbiome the viewers get the Chunks Biomes packet of the chunk, the same biomes as the cells" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     CALL "TB-BIOMES-CHECK" USING WS-ID-OPAL WS-DIM WS-CX WS-CZ WS-FOUND WS-MISMATCH
     MOVE 1 TO WS-EXPECTED-N
     MOVE WS-FOUND TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /fillbiome the packet's biomes equal the chunk's cells" TO TL-CASE
     MOVE 0 TO WS-EXPECTED-N
     MOVE WS-MISMATCH TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
*>   Limits.
     MOVE "gamerule max_block_modifications 100" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /fillbiome a volume above the limit: Too many blocks in the specified volume (maximum 100, but specified 1521)" TO TL-CASE
     MOVE "fillbiome 0 100 0 15 110 15 minecraft:plains" TO WS-LINE
     MOVE "commands.fillbiome.toobig(100,1521)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "gamerule max_block_modifications 32768" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /fillbiome a chunk of the box that is not loaded: That position is not loaded" TO TL-CASE
     MOVE "fillbiome 1000000 100 0 1000000 100 0 minecraft:plains" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome a position beyond 30000000 blocks is not loaded either" TO TL-CASE
     MOVE "fillbiome 99999999 100 0 99999999 100 0 minecraft:plains" TO WS-LINE
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome the volume is checked before the chunks are" TO TL-CASE
     MOVE "fillbiome 0 100 0 1000000 100 0 minecraft:plains" TO WS-LINE
     MOVE "commands.fillbiome.toobig(32768,1000001)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome an unknown biome" TO TL-CASE
     MOVE "fillbiome 0 100 0 0 100 0 cobolcraft:nope" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nope,minecraft:worldgen/biome) |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome completion after the last argument offers the next words" TO TL-CASE
     MOVE "/fillbiome 0 100 0 0 100 0 minecraft:plains " TO WS-LINE
     MOVE 44 TO WS-LENGTH
     MOVE 1 TO WS-SUGGESTION-ID
     CALL "TEST-SUGGEST" USING WS-ID-OPAL WS-SUGGESTION-ID WS-LINE WS-LENGTH
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "1 44 0 [replace]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fillbiome the biome is required" TO TL-CASE
     MOVE "fillbiome 0 100 0 0 100 0" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "acceptance US13 /fillbiome a player below level 2 does not know the command" TO TL-CASE
     MOVE "fillbiome 0 100 0 0 100 0 minecraft:plains" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /fillbiome the console prints the English text" TO TL-CASE
     MOVE "fillbiome 4 100 4 4 100 4 minecraft:plains" TO WS-LINE
     MOVE "1 biome entry/entries set between 4, 100, 4 and 4, 100, 4" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The line is run by Opal and the replies are compared with WS-EXPECTED.
 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> WS-BIOME: the biome cell of the block position (WS-BX, WS-BY, WS-BZ) of dimension WS-DIM, read from the cell layout of its chunk.
 READ-CELL.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-BX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-BZ / 16)
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-LOCAL = FUNCTION INTEGER((WS-BY - DM-MIN-Y(WS-DIM)) / 16)
     COMPUTE WS-CELL = WS-LOCAL * 64 + 1
     COMPUTE WS-LOCAL = FUNCTION MOD(WS-BY - DM-MIN-Y(WS-DIM), 16)
     COMPUTE WS-LOCAL = FUNCTION INTEGER(WS-LOCAL / 4)
     COMPUTE WS-CELL = WS-CELL + WS-LOCAL * 16
     COMPUTE WS-LOCAL = FUNCTION MOD(WS-BZ, 16)
     COMPUTE WS-LOCAL = FUNCTION INTEGER(WS-LOCAL / 4)
     COMPUTE WS-CELL = WS-CELL + WS-LOCAL * 4
     COMPUTE WS-LOCAL = FUNCTION MOD(WS-BX, 16)
     COMPUTE WS-LOCAL = FUNCTION INTEGER(WS-LOCAL / 4)
     COMPUTE WS-CELL = WS-CELL + WS-LOCAL
     MOVE CE-BIOME(WS-CELL) TO WS-BIOME.

*> The cell holds the biome WS-EXPECTED-N.
 ASSERT-CELL.
     PERFORM READ-CELL
     MOVE WS-BIOME TO WS-NUM
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.

*> The cell does not hold ash_flats (id 2).
 ASSERT-CELL-NOT.
     PERFORM READ-CELL
     MOVE 0 TO WS-NUM
     IF WS-BIOME NOT = 2
         MOVE 1 TO WS-NUM
     END-IF
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.
 END PROGRAM TEST-CMD-FILLBIOME.

 COPY CORETEST.
 COPY CMDTEST.

*> TB-BIOMES-CHECK USING connection id, dimension row, chunk x, chunk z, found out (1 when the connection was sent a Chunks Biomes packet for that
*> chunk), mismatches out (the cells of the chunk, one per 4 x 4 x 4 block cube, whose id differs from the packet's): the connection's output is drained.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TB-BIOMES-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-POS                 BINARY-DOUBLE.
 01 WS-WANT-POS            BINARY-DOUBLE.
 01 WS-TWO-32              BINARY-DOUBLE VALUE 4294967296.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG VALUE 64.
 01 WS-STRATEGY            BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VALUES.
    05 WS-VALUE            BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-MISMATCH             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DIM L-CX L-CZ L-FOUND L-MISMATCH.
     MOVE 0 TO L-FOUND L-MISMATCH
     COMPUTE WS-WANT-POS = L-CZ * WS-TWO-32 + FUNCTION MOD(L-CX, WS-TWO-32)
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 13
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 CALL "PB-GET-LONG" USING PK-BUFFER WS-POS
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-LENGTH
                 IF WS-POS = WS-WANT-POS AND L-FOUND = 0
                     MOVE 1 TO L-FOUND
                     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
                         CALL "CHUNK-CONTAINER-DECODE" USING PK-BUFFER WS-VALUES WS-ENTRIES WS-STRATEGY
                             DM-BIOME-BITS(L-DIM)
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 64
                             IF WS-VALUE(WS-K) NOT = CE-BIOME(WS-S * 64 + WS-K)
                                 ADD 1 TO L-MISMATCH
                             END-IF
                         END-PERFORM
                     END-PERFORM
                 ELSE
                     ADD WS-LENGTH TO PK-POS
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TB-BIOMES-CHECK.
