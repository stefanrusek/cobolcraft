*> Implementation test of docs/protocol/36-structures-3-jigsaw-assembly.md section 15 (Other entry points: generateJigsaw), on the generated vanilla data (CC_GENERATED_DIR, read only; skipped as
*> a pass without it) in a superflat world of seed 12345: JIG-GENERATE (core/src/struct-36-3.cob) with the pool minecraft:ancient_city/city_center and the start jigsaw name minecraft:city_anchor
*> (the worked example of 9.4: the anchor jigsaw ends at the position's Y minus the ground level delta 1, on the position's X and Z), keepJigsaws, the depth, an unknown pool and an unknown
*> target; /place jigsaw (CX-PLACE: success, invalid, failed, unloaded, the omitted position); and the Generate action of the jigsaw block (BE6-JIGSAW-PACKET, packet 0x1B: the start is the
*> block position plus its front, keepJigsaws from the packet; a player without game master blocks changes nothing).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY BESTATE.
 COPY STRUCTPIECE.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-POOL                PIC X(80) VALUE "minecraft:ancient_city/city_center".
 01 WS-BAD-POOL            PIC X(80) VALUE "minecraft:no_such_pool".
 01 WS-TARGET              PIC X(80) VALUE "minecraft:city_anchor".
 01 WS-BAD-TARGET          PIC X(80) VALUE "minecraft:no_such_anchor".
 01 WS-DEPTH               BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-JIGSAW              BINARY-LONG.
 01 WS-COUNT-1             BINARY-LONG.
 01 WS-COUNT-3             BINARY-LONG.
 01 WS-COUNT-A             BINARY-LONG.
 01 WS-BOX-A               PIC X(24).
 01 WS-ROW                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SNAP                PIC X(196608).
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ID-OPAL             BINARY-LONG.
 01 WS-ID-ALICE            BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-BE                  BINARY-LONG.
 01 WS-ROW-OPAL            BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 27.
 01 WS-SMALL               BINARY-LONG VALUE 4096.
 01 WS-LEVELS              BINARY-LONG.
 01 WS-KEEP-BOOL           BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-STATE-KEY           PIC X(112) VALUE "minecraft:jigsaw".
 01 WS-STATE-PAIRS         PIC X(600) VALUE "orientation=east_up".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "test struct 36-3 15 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE CN-PLAYER(WS-ID-OPAL) TO WS-ROW-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     PERFORM FIND-JIGSAW-BLOCK
     MOVE 80 TO WS-X
     MOVE -27 TO WS-Y
     MOVE 80 TO WS-Z

*>   an unknown pool is 2, and nothing is placed for it
     MOVE 1 TO WS-DEPTH
     MOVE 0 TO WS-KEEP
     CALL "JIG-GENERATE" USING WS-DIM WS-BAD-POOL WS-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     MOVE "test struct 36-3 15 given a pool that does not exist when generated then the result is 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   no jigsaw of the start element is named like the target: false, and the chunk is as it was
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z / 16)
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CE-STATES TO WS-SNAP
     CALL "JIG-GENERATE" USING WS-DIM WS-POOL WS-BAD-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE "test struct 36-3 15 given a target no jigsaw of the start element has when generated then the result is 0 and no cell changed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     IF CE-STATES NOT = WS-SNAP
         MOVE 99 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   depth 1 with keepJigsaws: the anchor jigsaw is on (x, y - 1, z) (9.4 worked example), a jigsaw block of the template that was kept
     MOVE 1 TO WS-KEEP
     CALL "JIG-GENERATE" USING WS-DIM WS-POOL WS-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     MOVE SP-COUNT TO WS-COUNT-1
     MOVE SP-BOX(1) TO WS-BOX-A
     MOVE "test struct 36-3 15 given the city anchor and keepJigsaws when generated at 80 -27 80 then the result is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "PROBE start piece box " SP-X0(1) " " SP-Y0(1) " " SP-Z0(1) " " SP-X1(1) " " SP-Y1(1) " " SP-Z1(1) " pieces " SP-COUNT
     COMPUTE WS-I = WS-Y - 1
     PERFORM BLOCK-NAME-AT
     MOVE "test struct 36-3 15 given keepJigsaws when generated then the block on the position's y minus 1 is the jigsaw block" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "jigsaw" TO TL-EXPECTED
     MOVE FUNCTION TRIM(CB-KEY(WS-BLOCK)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     COMPUTE WS-I = WS-Y - 1
     MOVE "test struct 36-3 15 given keepJigsaws when generated then the pieces are in the world (the start piece and the ones it grew)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT-1 >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the same call again is the same assembly (the context random is the chunk's large feature seed)
     CALL "JIG-GENERATE" USING WS-DIM WS-POOL WS-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     MOVE "test struct 36-3 15 given the same arguments when generated again then the same pieces are made" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-COUNT = WS-COUNT-1 AND SP-BOX(1) = WS-BOX-A
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a deeper assembly makes more pieces
     MOVE 3 TO WS-DEPTH
     CALL "JIG-GENERATE" USING WS-DIM WS-POOL WS-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     MOVE SP-COUNT TO WS-COUNT-3
     DISPLAY "PROBE pieces at depth 1: " WS-COUNT-1 ", at depth 3: " WS-COUNT-3
     MOVE "test struct 36-3 15 given depth 3 when generated then more pieces than depth 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT-3 > WS-COUNT-1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   without keepJigsaws the jigsaw replacement processor takes the jigsaw blocks out again
     MOVE 1 TO WS-DEPTH
     MOVE 0 TO WS-KEEP
     CALL "JIG-GENERATE" USING WS-DIM WS-POOL WS-TARGET WS-DEPTH WS-X WS-Y WS-Z WS-KEEP WS-RESULT
     COMPUTE WS-I = WS-Y - 1
     PERFORM BLOCK-NAME-AT
     MOVE "test struct 36-3 15 given no keepJigsaws when generated over the kept ones then the anchor is no jigsaw block any more" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CB-KEY(WS-BLOCK) NOT = "jigsaw"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COMMANDS
     PERFORM PACKETS
     STOP RUN.

*> WS-BLOCK the CORE-BLOCKS row of the block at (WS-X, WS-I, WS-Z)
 BLOCK-NAME-AT.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-I WS-Z WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1.

*> WS-JIGSAW the default state of the jigsaw block
 FIND-JIGSAW-BLOCK.
     MOVE 0 TO WS-JIGSAW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = "jigsaw"
             MOVE CB-DEFAULT-STATE(WS-I) TO WS-JIGSAW
         END-IF
     END-PERFORM.

*> /place jigsaw: Opal is an operator
 COMMANDS.
     MOVE 10 TO WS-CX
     MOVE 10 TO WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE "test struct 36-3 15 /place jigsaw with a pool and target of the data and a position is generated at the position" TO TL-CASE
     MOVE "place jigsaw minecraft:ancient_city/city_center minecraft:city_anchor 1 160 -27 160" TO WS-LINE
     MOVE "commands.place.jigsaw.success(160,-27,160)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE 160 TO WS-X
     COMPUTE WS-I = -28
     MOVE 160 TO WS-Z
     PERFORM BLOCK-NAME-AT
     MOVE "test struct 36-3 15 /place jigsaw the anchor jigsaw is replaced (keepJigsaws is false for the command)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CB-KEY(WS-BLOCK) NOT = "jigsaw"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct 36-3 15 /place jigsaw with a pool that does not exist is invalid with the key" TO TL-CASE
     MOVE "place jigsaw minecraft:no_such_pool minecraft:city_anchor 1 160 -27 160" TO WS-LINE
     MOVE "commands.place.jigsaw.invalid(minecraft:no_such_pool)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "test struct 36-3 15 /place jigsaw with a pool without the namespace takes minecraft:" TO TL-CASE
     MOVE "place jigsaw no_such_pool minecraft:city_anchor 1 160 -27 160" TO WS-LINE
     MOVE "commands.place.jigsaw.invalid(minecraft:no_such_pool)" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "test struct 36-3 15 /place jigsaw with a target no jigsaw has fails" TO TL-CASE
     MOVE "place jigsaw minecraft:ancient_city/city_center minecraft:no_such_anchor 1 160 -27 160" TO WS-LINE
     MOVE "commands.place.jigsaw.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "test struct 36-3 15 /place jigsaw at a position in a chunk that is not loaded is argument.pos.unloaded" TO TL-CASE
     MOVE "place jigsaw minecraft:ancient_city/city_center minecraft:city_anchor 1 100000 -27 100000" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "test struct 36-3 15 /place jigsaw at a position beyond 30000000 is argument.pos.unloaded" TO TL-CASE
     MOVE "place jigsaw minecraft:ancient_city/city_center minecraft:city_anchor 1 40000000 -27 0" TO WS-LINE
     MOVE "argument.pos.unloaded()" TO WS-EXPECTED
     PERFORM RUN-TEXT
     MOVE "test struct 36-3 15 /place jigsaw without a position uses the block holding the source (the target fails there)" TO TL-CASE
     MOVE "place jigsaw minecraft:ancient_city/city_center minecraft:no_such_anchor 1" TO WS-LINE
     MOVE "commands.place.jigsaw.failed()" TO WS-EXPECTED
     PERFORM RUN-TEXT.

 RUN-TEXT.
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT.

*> the Generate action: a jigsaw block of Opal's (creative, operator) and Alice's (creative world, no operator status)
 PACKETS.
     MOVE 240 TO WS-BX
     MOVE -40 TO WS-BY
     MOVE 240 TO WS-BZ
     CALL "STRUCT-TPL-STATE" USING WS-STATE-KEY WS-STATE-PAIRS WS-JIGSAW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-JIGSAW
     CALL "BE-FIND" USING WS-DIM WS-BX WS-BY WS-BZ WS-BE
     MOVE "test struct 36-3 15 given a jigsaw block placed in the world then it has a block entity of type 31" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BE > 0
         MOVE BE-TYPE(WS-BE) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:ancient_city/city_center" TO BE-XT(WS-BE, 3)
     MOVE "minecraft:city_anchor" TO BE-XT(WS-BE, 2)
*>   Alice (no operator status) is ignored
     MOVE 1 TO WS-LEVELS
     MOVE 0 TO WS-KEEP-BOOL
     MOVE WS-ID-ALICE TO WS-I
     PERFORM FEED-GENERATE
*>   the block faces east: the start is (bx + 1, by, bz) and the anchor jigsaw is one below it
     COMPUTE WS-X = WS-BX + 1
     MOVE WS-BZ TO WS-Z
     COMPUTE WS-I = WS-BY - 1
     PERFORM BLOCK-NAME-AT
     MOVE "test struct 36-3 15 given a player without game master blocks when Jigsaw Generate arrives then nothing is placed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CB-KEY(WS-BLOCK) NOT = "jigsaw"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Opal with keepJigsaws: the anchor jigsaw is on the block in front, one lower
     MOVE 1 TO WS-KEEP-BOOL
     MOVE WS-ID-OPAL TO WS-I
     PERFORM FEED-GENERATE
     COMPUTE WS-I = WS-BY - 1
     PERFORM BLOCK-NAME-AT
     MOVE "test struct 36-3 15 given the operator in creative when Jigsaw Generate arrives with keepJigsaws then the anchor jigsaw is one below the block in front (east)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "jigsaw" TO TL-EXPECTED
     MOVE FUNCTION TRIM(CB-KEY(WS-BLOCK)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   a position with no jigsaw block entity is ignored (no change, the connection stays open)
     MOVE 250 TO WS-BX
     MOVE WS-ID-OPAL TO WS-I
     PERFORM FEED-GENERATE
     MOVE "test struct 36-3 15 given a position with no block entity when Jigsaw Generate arrives then the connection stays open" TO TL-CASE
     MOVE WS-ROW-OPAL TO TL-EXPECTED-N
     MOVE CN-PLAYER(WS-ID-OPAL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Feeds Jigsaw Generate for (WS-BX, WS-BY, WS-BZ), WS-LEVELS and WS-KEEP-BOOL from connection WS-I
 FEED-GENERATE.
     CALL "PB-INIT" USING PB-BUFFER WS-SMALL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-POSITION" USING PB-BUFFER WS-BX WS-BY WS-BZ
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-LEVELS
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-KEEP-BOOL
     CALL "TEST-FEED-BUFFER" USING WS-I PB-BUFFER.
 END PROGRAM TEST-STRUCT-36-3-15.

 COPY CORETEST.
 COPY CMDTEST.
