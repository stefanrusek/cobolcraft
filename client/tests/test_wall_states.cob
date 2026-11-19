 *> Real-input test of the models of the connecting blocks (lane bugfluidwalls, operator report try19 "walls don't connect"; docs/protocol/24-block-registry-7 section 8.1 (the wall
*> states: sides none, low, tall, post up), 08 section 5 (multipart blockstates)): with the generated vanilla pack on the stack (CC_GENERATED_DIR, default /tmp/cc-test/generated) and
*> the standard content set open, the state of every wall with one side low (or tall) and its post up bakes the post and one arm that reaches the block edge on that side (north z 0,
*> east x 1, south z 1, west x 0), a tall arm reaches higher than a low one, and a state with no side and no post draws nothing; fences, glass panes and iron bars, the control that
*> the operator saw connect, draw an arm on the side that is true. The client side is complete: when the core sends the states of the connections the client draws them.
*> A missing pack fails the case, never skips.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WALL-STATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POST-QUADS          BINARY-LONG.
 01 WS-QUADS               BINARY-LONG.
 01 WS-MIN-X               FLOAT-SHORT.
 01 WS-MAX-X               FLOAT-SHORT.
 01 WS-MIN-Y               FLOAT-SHORT.
 01 WS-MAX-Y               FLOAT-SHORT.
 01 WS-MIN-Z               FLOAT-SHORT.
 01 WS-MAX-Z               FLOAT-SHORT.
 01 WS-LOW-Y               FLOAT-SHORT.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-FAILED              PIC X(100).
 01 WS-PTR                 BINARY-LONG.
 01 WS-ATLAS               BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-SIDE                BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-TALL                BINARY-LONG.
*> the wall blocks of the standard set (the tag walls), and per side the weight of its property in the state index (east 108, north 36, south 12, west 1)
 01 WS-WALLS.
    05 FILLER PIC X(32) VALUE "andesite_wall".
    05 FILLER PIC X(32) VALUE "blackstone_wall".
    05 FILLER PIC X(32) VALUE "brick_wall".
    05 FILLER PIC X(32) VALUE "cinnabar_brick_wall".
    05 FILLER PIC X(32) VALUE "cinnabar_wall".
    05 FILLER PIC X(32) VALUE "cobbled_deepslate_wall".
    05 FILLER PIC X(32) VALUE "cobblestone_wall".
    05 FILLER PIC X(32) VALUE "deepslate_brick_wall".
    05 FILLER PIC X(32) VALUE "deepslate_tile_wall".
    05 FILLER PIC X(32) VALUE "diorite_wall".
    05 FILLER PIC X(32) VALUE "end_stone_brick_wall".
    05 FILLER PIC X(32) VALUE "granite_wall".
    05 FILLER PIC X(32) VALUE "mossy_cobblestone_wall".
    05 FILLER PIC X(32) VALUE "mossy_stone_brick_wall".
    05 FILLER PIC X(32) VALUE "mud_brick_wall".
    05 FILLER PIC X(32) VALUE "nether_brick_wall".
    05 FILLER PIC X(32) VALUE "polished_blackstone_brick_wall".
    05 FILLER PIC X(32) VALUE "polished_blackstone_wall".
    05 FILLER PIC X(32) VALUE "polished_cinnabar_wall".
    05 FILLER PIC X(32) VALUE "polished_deepslate_wall".
    05 FILLER PIC X(32) VALUE "polished_sulfur_wall".
    05 FILLER PIC X(32) VALUE "polished_tuff_wall".
    05 FILLER PIC X(32) VALUE "prismarine_wall".
    05 FILLER PIC X(32) VALUE "red_nether_brick_wall".
    05 FILLER PIC X(32) VALUE "red_sandstone_wall".
    05 FILLER PIC X(32) VALUE "resin_brick_wall".
    05 FILLER PIC X(32) VALUE "sandstone_wall".
    05 FILLER PIC X(32) VALUE "stone_brick_wall".
    05 FILLER PIC X(32) VALUE "sulfur_brick_wall".
    05 FILLER PIC X(32) VALUE "sulfur_wall".
    05 FILLER PIC X(32) VALUE "tuff_brick_wall".
    05 FILLER PIC X(32) VALUE "tuff_wall".
 01 WS-WALL-TABLE REDEFINES WS-WALLS.
    05 WS-WALL             PIC X(32) OCCURS 32 TIMES.
 01 WS-WEIGHTS.
    05 FILLER BINARY-LONG VALUE 36.
    05 FILLER BINARY-LONG VALUE 108.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 1.
 01 WS-WEIGHT-TABLE REDEFINES WS-WEIGHTS.
    05 WS-WEIGHT           BINARY-LONG OCCURS 4 TIMES.
 01 WS-SIDE-NAMES.
    05 FILLER PIC X(8) VALUE "north".
    05 FILLER PIC X(8) VALUE "east".
    05 FILLER PIC X(8) VALUE "south".
    05 FILLER PIC X(8) VALUE "west".
 01 WS-SIDE-TABLE REDEFINES WS-SIDE-NAMES.
    05 WS-SIDE-NAME        PIC X(8) OCCURS 4 TIMES.
 01 WS-CONTROLS.
    05 FILLER PIC X(32) VALUE "oak_fence".
    05 FILLER PIC X(32) VALUE "nether_brick_fence".
    05 FILLER PIC X(32) VALUE "glass_pane".
    05 FILLER PIC X(32) VALUE "blue_stained_glass_pane".
    05 FILLER PIC X(32) VALUE "iron_bars".
    05 FILLER PIC X(32) VALUE "copper_bars".
 01 WS-CONTROL-TABLE REDEFINES WS-CONTROLS.
    05 WS-CONTROL          PIC X(32) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE "wall states the generated vanilla pack is on the stack and holds the cobblestone sprite" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SPACES TO WS-ID
     MOVE "minecraft:block/cobblestone" TO WS-ID
     MOVE 0 TO WS-ATLAS
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID 27 WS-ATLAS
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ATLAS > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         PERFORM CHECK-WALL
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         PERFORM CHECK-CONTROL
     END-PERFORM
     STOP RUN.

*> One wall: the post alone, each side low, the north side tall, and the state with no post and no side.
 CHECK-WALL.
     MOVE SPACES TO WS-KEY
     MOVE WS-WALL(WS-I) TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
     COMPUTE WS-FIRST = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
     MOVE SPACES TO WS-FAILED
     MOVE 1 TO WS-PTR
     CALL "MODELS-BAKE" USING CLIENT-STATE
*>   up true, every side none, not waterlogged: the index 3 of the block's states (24-7 section 8.1)
     COMPUTE WS-STATE = WS-FIRST + 3
     PERFORM BAKE-STATE
     MOVE WS-QUADS TO WS-POST-QUADS
     IF WS-QUADS = 0
         STRING "post " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
     END-IF
     PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 4
         COMPUTE WS-STATE = WS-FIRST + 3 + WS-WEIGHT(WS-SIDE)
         PERFORM BAKE-STATE
         PERFORM CHECK-ARM
     END-PERFORM
*>   The post is 16 high and hides the arm's height: compare the arms of the states without a post (up false, index 6 more).
     COMPUTE WS-STATE = WS-FIRST + 9 + 2 * WS-WEIGHT(1)
     PERFORM BAKE-STATE
     MOVE WS-MAX-Y TO WS-TALL
     COMPUTE WS-STATE = WS-FIRST + 9 + WS-WEIGHT(1)
     PERFORM BAKE-STATE
     IF WS-TALL <= WS-MAX-Y
         STRING "tall " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
     END-IF
*>   up false, every side none, not waterlogged (index 6 + 3): nothing is drawn
     COMPUTE WS-STATE = WS-FIRST + 9
     PERFORM BAKE-STATE
     IF WS-QUADS > 0
         STRING "no-post " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "wall states " FUNCTION TRIM(WS-WALL(WS-I)) " post, four arms, tall arm" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     IF WS-FAILED NOT = SPACES
         MOVE WS-FAILED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The quads of the state WS-STATE (row WS-ROW) and their extents.
 BAKE-STATE.
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-ROW
     MOVE 0 TO WS-QUADS
     MOVE 9 TO WS-MIN-X WS-MIN-Y WS-MIN-Z
     MOVE -9 TO WS-MAX-X WS-MAX-Y WS-MAX-Z
     IF WS-ROW > 0
         MOVE BM-QUAD-COUNT(WS-ROW) TO WS-QUADS
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-QUADS
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                 MOVE BM-X(WS-ROW, WS-Q, WS-C) TO WS-PX
                 IF WS-PX < WS-MIN-X
                     MOVE WS-PX TO WS-MIN-X
                 END-IF
                 IF WS-PX > WS-MAX-X
                     MOVE WS-PX TO WS-MAX-X
                 END-IF
                 MOVE BM-Y(WS-ROW, WS-Q, WS-C) TO WS-PX
                 IF WS-PX < WS-MIN-Y
                     MOVE WS-PX TO WS-MIN-Y
                 END-IF
                 IF WS-PX > WS-MAX-Y
                     MOVE WS-PX TO WS-MAX-Y
                 END-IF
                 MOVE BM-Z(WS-ROW, WS-Q, WS-C) TO WS-PX
                 IF WS-PX < WS-MIN-Z
                     MOVE WS-PX TO WS-MIN-Z
                 END-IF
                 IF WS-PX > WS-MAX-Z
                     MOVE WS-PX TO WS-MAX-Z
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF.

*> The state baked above has WS-SIDE (1 north, 2 east, 3 south, 4 west) connected: more quads than the post, and the arm reaches the edge on that side.
 CHECK-ARM.
     IF WS-QUADS <= WS-POST-QUADS
         STRING FUNCTION TRIM(WS-SIDE-NAME(WS-SIDE)) " " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
     END-IF
     EVALUATE WS-SIDE
         WHEN 1
             IF WS-MIN-Z > 0.01
                 STRING "north-edge " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
             END-IF
         WHEN 2
             IF WS-MAX-X < 0.99
                 STRING "east-edge " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
             END-IF
         WHEN 3
             IF WS-MAX-Z < 0.99
                 STRING "south-edge " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
             END-IF
         WHEN OTHER
             IF WS-MIN-X > 0.01
                 STRING "west-edge " DELIMITED BY SIZE INTO WS-FAILED WITH POINTER WS-PTR
             END-IF
     END-EVALUATE.

*> A fence, a pane or bars with no side (index 31: every boolean false) against the north side true (23) and the east side true (15).
 CHECK-CONTROL.
     MOVE SPACES TO WS-KEY
     MOVE WS-CONTROL(WS-I) TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK-ID WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW TO CT-BLOCK-ROW
     COMPUTE WS-FIRST = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
     MOVE SPACES TO WS-FAILED
     MOVE 1 TO WS-PTR
     CALL "MODELS-BAKE" USING CLIENT-STATE
     COMPUTE WS-STATE = WS-FIRST + 31
     PERFORM BAKE-STATE
     MOVE WS-QUADS TO WS-POST-QUADS
     MOVE 1 TO WS-SIDE
     COMPUTE WS-STATE = WS-FIRST + 23
     PERFORM BAKE-STATE
     PERFORM CHECK-ARM
     MOVE 2 TO WS-SIDE
     COMPUTE WS-STATE = WS-FIRST + 15
     PERFORM BAKE-STATE
     PERFORM CHECK-ARM
     MOVE SPACES TO TL-CASE
     STRING "wall states control " FUNCTION TRIM(WS-CONTROL(WS-I)) " north and east arms" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "ok" TO TL-EXPECTED
     MOVE "ok" TO TL-OBSERVED
     IF WS-FAILED NOT = SPACES
         MOVE WS-FAILED TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-WALL-STATES.
