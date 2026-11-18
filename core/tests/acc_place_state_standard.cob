 *> Acceptance test, lane wallitems (CC-0009 block placement orientation and attachment; docs/protocol/29 sections 9.5 and 9.6, 25 part 4 section 9.2, and the getStateForPlacement rows of 24 parts 1 to 8 and 30): a superflat
*> world of the standard content set (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). Each case clears a small space in the air, puts a support block (a stone block unless the case says
*> otherwise) at its middle, sets the player's view (yaw, pitch) and the item in the hand, uses the item on a face of the support block at a height of the face (Use Item On with the cursor of the case) and compares the
*> block at the target cell (or at the support's cell for blocks that replace it) with the expected block and its listed properties, "air" for nothing placed. The families: logs (axis), slabs (half, double slabs),
*> stairs (facing, half, corner shape), levers, buttons and grindstones, ladders, standing and wall signs, hanging signs, banners, skulls, coral fans, lanterns, vines and other multiface blocks, doors (hinge),
*> trapdoors, gates and the blocks that face the player (furnace, anvil, dispenser, piston, observer, repeater, pot, loom, lectern, shelf, lightning rod, amethyst cluster).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-PLACE-STATE-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY CBLOCKS.
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
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG.
 01 WS-CY                  FLOAT-SHORT.
 01 WS-CX                  FLOAT-SHORT.
 01 WS-TEXT-AREA           PIC X(4096).
 01 WS-SPEC                PIC X(120).
 01 WS-SPEC-KEY            PIC X(48).
 01 WS-SPEC-PROPS          PIC X(120).
 01 WS-PAIR                PIC X(48).
 01 WS-PAIR-NAME           PIC X(24).
 01 WS-PAIR-VALUE          PIC X(32).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-BRACKET             BINARY-LONG.
 01 WS-NAME-OUT            PIC X(48).
 01 WS-VALUE               PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-OBSERVED            PIC X(160).
 01 WS-OPOINTER            BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-PRE                 BINARY-LONG.
 01 WS-PRE-TEXT            PIC X(56).
 01 WS-PRE-X               PIC X(4).
 01 WS-PRE-Y               PIC X(4).
 01 WS-PRE-Z               PIC X(4).
 01 WS-PRE-SPEC            PIC X(120).
 01 WS-CASES.
    05 FILLER PIC X(96) VALUE "a log clicked on its top face stands up                                                         ".
    05 FILLER PIC X(32) VALUE "oak_log                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_log[axis=y]                                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a log clicked on a north face lies along z                                                      ".
    05 FILLER PIC X(32) VALUE "oak_log                         ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_log[axis=z]                                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a log clicked on an east face lies along x                                                      ".
    05 FILLER PIC X(32) VALUE "oak_log                         ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_log[axis=x]                                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "hay clicked on a west face lies along x                                                         ".
    05 FILLER PIC X(32) VALUE "hay_block                       ".
    05 FILLER PIC X(1) VALUE "4".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "hay_block[axis=x]                                                                                   ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a chain clicked on a south face lies along z                                                    ".
    05 FILLER PIC X(32) VALUE "iron_chain                      ".
    05 FILLER PIC X(1) VALUE "3".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "iron_chain[axis=z]                                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the top face is a bottom slab                                                         ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=bottom]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the underside is a top slab                                                           ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=top]                                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the upper half of a side is a top slab                                                ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "075".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=top]                                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the lower half of a side is a bottom slab                                             ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "025".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=bottom]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the middle of a side is a bottom slab                                                 ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=bottom]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the top of a bottom slab makes a double slab                                          ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_slab[type=bottom]                           ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=double]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the upper half of the side of a bottom slab makes a double slab                       ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "075".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_slab[type=bottom]                           ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=double]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the lower half of the side of a bottom slab goes beside it                            ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "025".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_slab[type=bottom]                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=bottom]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the underside of a top slab makes a double slab                                       ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_slab[type=top]                              ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=double]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab on the top of a double slab goes above it                                                ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_slab[type=double]                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=bottom]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a slab placed into the cell of a bottom slab makes a double slab                                ".
    05 FILLER PIC X(32) VALUE "oak_slab                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+0|oak_slab[type=bottom]                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_slab[type=double]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair facing the player (south)                                                               ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,half=bottom,shape=straight]                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair on the underside is upside down                                                         ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,half=top]                                                                   ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair on the upper half of a side is upside down                                              ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "075".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,half=top]                                                                   ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair facing north when the player looks north                                                ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+180".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=north,half=bottom]                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair facing west when the player looks west                                                  ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=west]                                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair facing east when the player looks east                                                  ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=east]                                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair with a stair facing east in front is an outer left corner                               ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|oak_stairs[facing=east,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=outer_left]                                                           ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair with a stair facing west in front is an outer right corner                              ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|oak_stairs[facing=west,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=outer_right]                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair with a stair facing east behind is an inner left corner                                 ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|-1|oak_stairs[facing=east,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=inner_left]                                                           ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair with a stair facing west behind is an inner right corner                                ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|-1|oak_stairs[facing=west,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=inner_right]                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair with a stair facing the same way in front stays straight                                ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|oak_stairs[facing=south,half=bottom]           ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=straight]                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair beside an upside down stair stays straight                                              ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|oak_stairs[facing=east,half=top]               ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=straight]                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lever on a top face is a floor lever facing the player                                        ".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lever[face=floor,facing=south]                                                                      ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lever on the underside is a ceiling lever                                                     ".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lever[face=ceiling,facing=south]                                                                    ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lever on a north face is a wall lever facing north                                            ".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lever[face=wall,facing=north]                                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stone button on an east face is a wall button facing east                                     ".
    05 FILLER PIC X(32) VALUE "stone_button                    ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "stone_button[face=wall,facing=east]                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a button on a top face facing west when the player looks west                                   ".
    05 FILLER PIC X(32) VALUE "oak_button                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_button[face=floor,facing=west]                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a grindstone on a south face is a wall grindstone facing south                                  ".
    05 FILLER PIC X(32) VALUE "grindstone                      ".
    05 FILLER PIC X(1) VALUE "3".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "grindstone[face=wall,facing=south]                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder on a north face faces north                                                            ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "ladder[facing=north]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder on a west face faces west                                                              ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "4".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "ladder[facing=west]                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder on a top face with nothing beside it is not placed                                     ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder on a top face with a block beside it hangs on that block                               ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "ladder[facing=north]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder on the underside is not placed                                                         ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on a top face stands (yaw 0: rotation 8)                                                 ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_sign[rotation=8]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on a top face (yaw 90: rotation 12)                                                      ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_sign[rotation=12]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on a top face (yaw 180: rotation 0)                                                      ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+180".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_sign[rotation=0]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on a top face (yaw -90: rotation 4)                                                      ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_sign[rotation=4]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on a north face is a wall sign facing north                                              ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_wall_sign[facing=north]                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on an east face is a wall sign facing east                                               ".
    05 FILLER PIC X(32) VALUE "spruce_sign                     ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "spruce_wall_sign[facing=east]                                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sign on the underside is not placed                                                           ".
    05 FILLER PIC X(32) VALUE "oak_sign                        ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign on the underside of a block hangs (yaw 0: rotation 8, attached false)            ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=8]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign on the underside (yaw 90: rotation 12)                                           ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=12]                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign on a top face with nothing above is not placed                                   ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign on a north face with a block beside it is a wall hanging sign                    ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+0|-1|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_wall_hanging_sign[facing=north]                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign on a north face with nothing beside it is not placed                             ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a banner on a top face stands (yaw 0: rotation 8)                                               ".
    05 FILLER PIC X(32) VALUE "white_banner                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "white_banner[rotation=8]                                                                            ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a banner on a north face is a wall banner facing north                                          ".
    05 FILLER PIC X(32) VALUE "white_banner                    ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "white_wall_banner[facing=north]                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a skull on a top face stands (yaw 0: rotation 0)                                                ".
    05 FILLER PIC X(32) VALUE "skeleton_skull                  ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "skeleton_skull[rotation=0]                                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a skull on a top face (yaw 90: rotation 4)                                                      ".
    05 FILLER PIC X(32) VALUE "skeleton_skull                  ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "skeleton_skull[rotation=4]                                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a skull on a north face is a wall skull facing north                                            ".
    05 FILLER PIC X(32) VALUE "skeleton_skull                  ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "skeleton_wall_skull[facing=north]                                                                   ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a head on an east face is a wall head facing east                                               ".
    05 FILLER PIC X(32) VALUE "zombie_head                     ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "zombie_wall_head[facing=east]                                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a dead coral fan on a top face stands                                                           ".
    05 FILLER PIC X(32) VALUE "dead_tube_coral_fan             ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "dead_tube_coral_fan                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a dead coral fan on a north face is a wall fan facing north                                     ".
    05 FILLER PIC X(32) VALUE "dead_tube_coral_fan             ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "dead_tube_coral_wall_fan[facing=north]                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lantern on a top face stands                                                                  ".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lantern[hanging=false]                                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lantern on the underside hangs                                                                ".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lantern[hanging=true]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lantern on a side with a block below it stands                                                ".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|-1|-1|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lantern[hanging=false]                                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lantern on a side with nothing above or below is not placed                                   ".
    05 FILLER PIC X(32) VALUE "lantern                         ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a vine on a north face holds on the block behind it                                             ".
    05 FILLER PIC X(32) VALUE "vine                            ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "vine[south=true,north=false]                                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a vine on a top face has nothing to hold on to                                                  ".
    05 FILLER PIC X(32) VALUE "vine                            ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "glow lichen on a top face holds on the block below                                              ".
    05 FILLER PIC X(32) VALUE "glow_lichen                     ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "glow_lichen[down=true,up=false]                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sculk vein on a west face holds on the block beside it                                        ".
    05 FILLER PIC X(32) VALUE "sculk_vein                      ".
    05 FILLER PIC X(1) VALUE "4".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "sculk_vein[east=true,west=false]                                                                    ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a vine added to a vine takes a second face                                                      ".
    05 FILLER PIC X(32) VALUE "vine                            ".
    05 FILLER PIC X(1) VALUE "4".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "vine[north=true]                                ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "+0|+0|-1|stone                                          ".
    05 FILLER PIC X(56) VALUE "+1|+0|+0|stone                                          ".
    05 FILLER PIC X(100) VALUE "vine[north=true,east=true]                                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door faces the player; hinge left without a wall beside it                                    ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=left]                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door next to a wall on the clockwise side has its hinge on the right                          ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "-1|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=right]                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door next to a wall on the counter-clockwise side has its hinge on the left                   ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=left]                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door facing east when the player looks east                                                   ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=east,half=lower]                                                                    ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a trapdoor on a top face is a bottom trapdoor facing the player                                 ".
    05 FILLER PIC X(32) VALUE "oak_trapdoor                    ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_trapdoor[facing=north,half=bottom]                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a trapdoor on the underside is a top trapdoor                                                   ".
    05 FILLER PIC X(32) VALUE "oak_trapdoor                    ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_trapdoor[facing=north,half=top]                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a trapdoor on the upper half of a north face lies on that face at the top                       ".
    05 FILLER PIC X(32) VALUE "oak_trapdoor                    ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "075".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_trapdoor[facing=north,half=top]                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a trapdoor on the lower half of a north face lies on that face at the bottom                    ".
    05 FILLER PIC X(32) VALUE "oak_trapdoor                    ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "025".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_trapdoor[facing=north,half=bottom]                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a trapdoor on the lower half of an east face faces east                                         ".
    05 FILLER PIC X(32) VALUE "oak_trapdoor                    ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "025".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_trapdoor[facing=east,half=bottom]                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a fence gate faces the direction of the player (south)                                          ".
    05 FILLER PIC X(32) VALUE "oak_fence_gate                  ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_fence_gate[facing=south]                                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a fence gate (player looks west)                                                                ".
    05 FILLER PIC X(32) VALUE "oak_fence_gate                  ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_fence_gate[facing=west]                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a furnace faces the player (north when the player looks south)                                  ".
    05 FILLER PIC X(32) VALUE "furnace                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "furnace[facing=north]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a furnace (player looks west: faces east)                                                       ".
    05 FILLER PIC X(32) VALUE "furnace                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "furnace[facing=east]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "an anvil faces clockwise of the player (west when the player looks south)                       ".
    05 FILLER PIC X(32) VALUE "anvil                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "anvil[facing=west]                                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a dispenser faces the player when the player looks level (north)                                ".
    05 FILLER PIC X(32) VALUE "dispenser                       ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "dispenser[facing=north]                                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a dispenser faces up when the player looks down                                                 ".
    05 FILLER PIC X(32) VALUE "dispenser                       ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+080".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "dispenser[facing=up]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a piston faces the player when the player looks level (north)                                   ".
    05 FILLER PIC X(32) VALUE "piston                          ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "piston[facing=north]                                                                                ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "an observer faces the way the player looks (south)                                              ".
    05 FILLER PIC X(32) VALUE "observer                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "observer[facing=south]                                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lightning rod faces the clicked face (north)                                                  ".
    05 FILLER PIC X(32) VALUE "lightning_rod                   ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lightning_rod[facing=north]                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "an amethyst cluster faces the clicked face (east)                                               ".
    05 FILLER PIC X(32) VALUE "amethyst_cluster                ".
    05 FILLER PIC X(1) VALUE "5".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "amethyst_cluster[facing=east]                                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a repeater faces the player (north when the player looks south)                                 ".
    05 FILLER PIC X(32) VALUE "repeater                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "repeater[facing=north]                                                                              ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a decorated pot faces the player (south)                                                        ".
    05 FILLER PIC X(32) VALUE "decorated_pot                   ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "decorated_pot[facing=south]                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a loom faces the player (north when the player looks south)                                     ".
    05 FILLER PIC X(32) VALUE "loom                            ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "loom[facing=north]                                                                                  ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lectern faces the player (north when the player looks south)                                  ".
    05 FILLER PIC X(32) VALUE "lectern                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "lectern[facing=north]                                                                               ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a bookshelf shelf faces the player                                                              ".
    05 FILLER PIC X(32) VALUE "oak_shelf                       ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_shelf[facing=north]                                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair is straight when the stair in front has a stair beside it that continues its line       ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+1|oak_stairs[facing=east,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "-1|+1|+0|oak_stairs[facing=south,half=bottom]           ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=straight]                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair is straight when the stair behind has a stair beside it that continues its line         ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|-1|oak_stairs[facing=east,half=bottom]            ".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|oak_stairs[facing=south,half=bottom]           ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=south,shape=straight]                                                             ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a stair facing east with a stair facing north in front is an outer left corner                  ".
    05 FILLER PIC X(32) VALUE "oak_stairs                      ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|oak_stairs[facing=north,half=bottom]           ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_stairs[facing=east,shape=outer_left]                                                            ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door facing west                                                                              ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=west,half=lower]                                                                    ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door beside a door on the counter-clockwise side has its hinge on the right                   ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|oak_door[facing=south,half=lower]              ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=right]                                                       ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door beside a door on the clockwise side has its hinge on the left                            ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "-1|+1|+0|oak_door[facing=south,half=lower]              ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=left]                                                        ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door between two walls takes its hinge from the click (left of the cell centre: right)        ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "-1|+1|+0|stone                                          ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=right]                                                       ".
    05 FILLER PIC X(3) VALUE "025".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a door between two walls takes its hinge from the click (right of the cell centre: left)        ".
    05 FILLER PIC X(32) VALUE "oak_door                        ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "-1|+1|+0|stone                                          ".
    05 FILLER PIC X(100) VALUE "oak_door[facing=south,half=lower,hinge=left]                                                        ".
    05 FILLER PIC X(3) VALUE "075".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a wall hanging sign beside a wall hanging sign along its axis is placed                         ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+0|-1|oak_wall_hanging_sign[facing=north]            ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_wall_hanging_sign[facing=north]                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a wall hanging sign beside a wall hanging sign across its axis is not placed                    ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+1|+0|-1|oak_wall_hanging_sign[facing=east]             ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a wall hanging sign along the player is not attached                       ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_wall_hanging_sign[facing=north]             ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=8]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a wall hanging sign across the player is attached                          ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_wall_hanging_sign[facing=north]             ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=true,rotation=12]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a ceiling hanging sign along the player is not attached                    ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_hanging_sign[attached=false,rotation=4]     ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=4]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a ceiling hanging sign across the player is attached                       ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_hanging_sign[attached=false,rotation=4]     ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=true,rotation=8]                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a ceiling hanging sign turned by an eighth is attached                     ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "oak_hanging_sign[attached=false,rotation=2]     ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|+0|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=true,rotation=8]                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a hanging sign under a stone block (yaw 180: rotation 0, not attached)                          ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+180".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=0]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a sneaking player hangs a sign attached under a stone block                                     ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=true,rotation=8]                                                          ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(96) VALUE "a hanging sign under a stone block (player looks east: rotation 4)                              ".
    05 FILLER PIC X(32) VALUE "oak_hanging_sign                ".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "-090".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_hanging_sign[attached=false,rotation=4]                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a lever put into grass with nothing to hold it is not placed                                    ".
    05 FILLER PIC X(32) VALUE "lever                           ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "short_grass                                     ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "short_grass                                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a log put on grass replaces it                                                                  ".
    05 FILLER PIC X(32) VALUE "oak_log                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "short_grass                                     ".
    05 FILLER PIC X(1) VALUE "S".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_log[axis=y]                                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a log used on an empty cell is placed on the clicked face                                       ".
    05 FILLER PIC X(32) VALUE "oak_log                         ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "air                                             ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "oak_log[axis=y]                                                                                     ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a ladder used on a ladder facing the clicked face is not placed                                 ".
    05 FILLER PIC X(32) VALUE "ladder                          ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "ladder[facing=north]                            ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+0|+1|stone                                          ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a tripwire hook on a north face faces north                                                     ".
    05 FILLER PIC X(32) VALUE "tripwire_hook                   ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "tripwire_hook[facing=north]                                                                         ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a tripwire hook on a top face with nothing beside it is not placed                              ".
    05 FILLER PIC X(32) VALUE "tripwire_hook                   ".
    05 FILLER PIC X(1) VALUE "1".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "air                                                                                                 ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
    05 FILLER PIC X(96) VALUE "a vine beside a vine that has the face stays on the face of the block                           ".
    05 FILLER PIC X(32) VALUE "vine                            ".
    05 FILLER PIC X(1) VALUE "2".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(4) VALUE "+000".
    05 FILLER PIC X(48) VALUE "stone                                           ".
    05 FILLER PIC X(1) VALUE "T".
    05 FILLER PIC X(56) VALUE "+0|+1|-1|vine[south=true]                               ".
    05 FILLER PIC X(56) VALUE "                                                        ".
    05 FILLER PIC X(100) VALUE "vine[south=true]                                                                                    ".
    05 FILLER PIC X(3) VALUE "050".
    05 FILLER PIC X(1) VALUE "0".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-ROW OCCURS 118 TIMES.
       10 WS-C-LABEL        PIC X(96).
       10 WS-C-ITEM         PIC X(32).
       10 WS-C-FACE         PIC 9.
       10 WS-C-CY           PIC 9V99.
       10 WS-C-YAW          PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-PITCH        PIC S999 SIGN LEADING SEPARATE.
       10 WS-C-SUPPORT      PIC X(48).
       10 WS-C-AT           PIC X.
       10 WS-C-PRE          PIC X(56) OCCURS 2 TIMES.
       10 WS-C-WANT         PIC X(100).
       10 WS-C-CX           PIC 9V99.
       10 WS-C-SNEAK        PIC 9.
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
         MOVE "acceptance place state standard no generated packs here, skipped" TO TL-CASE
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
     MOVE "PlaceState" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "stone" TO WS-SPEC
     PERFORM SPEC-STATE
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
     MOVE 0 TO PL-HELD(WS-PLAYER)
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT-AREA
*>   The middle of the space: the support block's cell.
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PY = WS-FLOOR + 4
     COMPUTE WS-PZ = WS-BZ + 6
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 118
         PERFORM RUN-CASE
     END-PERFORM
     STOP RUN.

*> One case of the table: the space cleared, the support and the blocks around it set, the item used, the result compared.
 RUN-CASE.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
                 COMPUTE WS-X = WS-PX + WS-DX
                 COMPUTE WS-Y = WS-PY + WS-DY
                 COMPUTE WS-Z = WS-PZ + WS-DZ
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-C-SUPPORT(WS-I) TO WS-SPEC
     PERFORM SPEC-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-PZ WS-STATE
     PERFORM VARYING WS-PRE FROM 1 BY 1 UNTIL WS-PRE > 2
         MOVE WS-C-PRE(WS-I, WS-PRE) TO WS-PRE-TEXT
         IF WS-PRE-TEXT NOT = SPACES
             UNSTRING WS-PRE-TEXT DELIMITED BY "|" INTO WS-PRE-X WS-PRE-Y WS-PRE-Z WS-PRE-SPEC
             COMPUTE WS-X = WS-PX + FUNCTION NUMVAL(WS-PRE-X)
             COMPUTE WS-Y = WS-PY + FUNCTION NUMVAL(WS-PRE-Y)
             COMPUTE WS-Z = WS-PZ + FUNCTION NUMVAL(WS-PRE-Z)
             MOVE WS-PRE-SPEC TO WS-SPEC
             PERFORM SPEC-STATE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(WS-C-ITEM(WS-I)) TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE WS-C-YAW(WS-I) TO PL-YAW(WS-PLAYER)
     MOVE WS-C-PITCH(WS-I) TO PL-PITCH(WS-PLAYER)
     MOVE WS-C-FACE(WS-I) TO WS-FACE
     MOVE WS-C-CY(WS-I) TO WS-CY
     MOVE WS-C-CX(WS-I) TO WS-CX
     MOVE WS-C-SNEAK(WS-I) TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-USE-ON-AT" USING WS-CONN WS-PX WS-PY WS-PZ WS-FACE WS-CX WS-CY WS-SEQ
*>   The cell to look at: the support's own cell, or the cell on the clicked face.
     MOVE WS-PX TO WS-X
     MOVE WS-PY TO WS-Y
     MOVE WS-PZ TO WS-Z
     IF WS-C-AT(WS-I) = "T"
         EVALUATE WS-FACE
             WHEN 0
                 SUBTRACT 1 FROM WS-Y
             WHEN 1
                 ADD 1 TO WS-Y
             WHEN 2
                 SUBTRACT 1 FROM WS-Z
             WHEN 3
                 ADD 1 TO WS-Z
             WHEN 4
                 SUBTRACT 1 FROM WS-X
             WHEN OTHER
                 ADD 1 TO WS-X
         END-EVALUATE
     END-IF
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM OBSERVE
     MOVE SPACES TO WS-CASE
     STRING "acceptance place state standard: " FUNCTION TRIM(WS-C-LABEL(WS-I)) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-C-WANT(WS-I)) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-STATE: the state of WS-SPEC, "key[name=value,name=value]": the block's default state with each property set; 0 for a key the set does not hold.
 SPEC-STATE.
     MOVE 0 TO WS-STATE
     MOVE SPACES TO WS-SPEC-KEY WS-SPEC-PROPS
     MOVE 0 TO WS-BRACKET
     INSPECT WS-SPEC TALLYING WS-BRACKET FOR CHARACTERS BEFORE INITIAL "["
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC))
     IF WS-BRACKET < WS-LEN
         MOVE WS-SPEC(1:WS-BRACKET) TO WS-SPEC-KEY
         COMPUTE WS-LEFT = WS-LEN - WS-BRACKET - 2
         COMPUTE WS-E = WS-BRACKET + 2
         MOVE WS-SPEC(WS-E:WS-LEFT) TO WS-SPEC-PROPS
     ELSE
         MOVE FUNCTION TRIM(WS-SPEC) TO WS-SPEC-KEY
     END-IF
     MOVE SPACES TO WS-KEY112
     STRING "minecraft:" FUNCTION TRIM(WS-SPEC-KEY) DELIMITED BY SIZE INTO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-E
     IF WS-E >= 0
         MOVE CB-DEFAULT-STATE(WS-E + 1) TO WS-STATE
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-SPEC-PROPS = SPACES OR WS-POINTER > FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC-PROPS))
             MOVE SPACES TO WS-PAIR
             UNSTRING WS-SPEC-PROPS DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POINTER
             MOVE SPACES TO WS-PAIR-NAME WS-PAIR-VALUE
             UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-PAIR-NAME WS-PAIR-VALUE
             CALL "PS-PUT" USING WS-STATE WS-PAIR-NAME WS-PAIR-VALUE
         END-PERFORM
     END-IF.

*> WS-OBSERVED: the block of WS-STATE and the properties the expected text of the case lists, as "key[name=value,...]".
 OBSERVE.
     CALL "PS-NAME-OF" USING WS-STATE WS-NAME-OUT
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-NAME-OUT) TO WS-OBSERVED
     MOVE WS-C-WANT(WS-I) TO WS-SPEC
     MOVE 0 TO WS-BRACKET
     INSPECT WS-SPEC TALLYING WS-BRACKET FOR CHARACTERS BEFORE INITIAL "["
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC))
     IF WS-BRACKET < WS-LEN
         MOVE SPACES TO WS-SPEC-PROPS
         COMPUTE WS-LEFT = WS-LEN - WS-BRACKET - 2
         COMPUTE WS-E = WS-BRACKET + 2
         MOVE WS-SPEC(WS-E:WS-LEFT) TO WS-SPEC-PROPS
         MOVE 1 TO WS-POINTER
         MOVE 1 TO WS-FIRST
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OBSERVED)) TO WS-OPOINTER
         ADD 1 TO WS-OPOINTER
         STRING "[" DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-OPOINTER
         PERFORM UNTIL WS-POINTER > FUNCTION LENGTH(FUNCTION TRIM(WS-SPEC-PROPS))
             MOVE SPACES TO WS-PAIR
             UNSTRING WS-SPEC-PROPS DELIMITED BY "," INTO WS-PAIR WITH POINTER WS-POINTER
             MOVE SPACES TO WS-PAIR-NAME WS-PAIR-VALUE
             UNSTRING WS-PAIR DELIMITED BY "=" INTO WS-PAIR-NAME WS-PAIR-VALUE
             CALL "PS-GET" USING WS-STATE WS-PAIR-NAME WS-VALUE WS-FOUND
             IF WS-FIRST = 0
                 STRING "," DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-OPOINTER
             END-IF
             MOVE 0 TO WS-FIRST
             STRING FUNCTION TRIM(WS-PAIR-NAME) "=" FUNCTION TRIM(WS-VALUE) DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-OPOINTER
         END-PERFORM
         STRING "]" DELIMITED BY SIZE INTO WS-OBSERVED WITH POINTER WS-OPOINTER
     END-IF.
 END PROGRAM ACC-PLACE-STATE-STANDARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-ON-AT.
*> USING connection id, x, y, z, face, cursor x, cursor y (FLOAT-SHORT), sequence: feeds Use Item On with the main hand on that block and face, cursor (cursor x, cursor y, 0.5), not inside, no border hit.
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
 01 L-CX                   FLOAT-SHORT.
 01 L-CY                   FLOAT-SHORT.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-FACE L-CX L-CY L-SEQUENCE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-FACE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-CX
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-CY
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-USE-ON-AT.
 COPY CORETEST.
 COPY CMDTEST.
