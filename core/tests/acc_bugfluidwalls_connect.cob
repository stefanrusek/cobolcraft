 *> Acceptance test, lane bugfluidwalls (operator report try19 "walls don't connect"; docs/protocol/24-block-registry-7 section 8.3 and 8.4 (walls), 24-block-registry-3
*> section 9.1 (fences), 24-block-registry-4 section 5.2 (panes, bars) and 24-block-registry-5 section 7.14): a superflat world of the standard content set
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated; skipped as a pass without it). Each case clears a small space, puts a support block of stone at its middle, sets
*> the blocks around the target cell (Level.setBlock with the neighbour updates), uses the item on the top face of the support, then changes the post blocks (again
*> with the neighbour updates) and compares the properties of the blocks it lists: the placed block takes its sides (none, low, tall; true, false) and its post from its
*> neighbours (placement), and a block that is already there changes when its neighbour does (updateShape).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFLUIDWALLS-CONNECT.
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
 01 WS-K                   BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-TX                  PIC X(4).
 01 WS-TY                  PIC X(4).
 01 WS-TZ                  PIC X(4).
 01 WS-TSPEC               PIC X(100).
 01 WS-CHECK-TEXT          PIC X(110).
 01 WS-CASES.
*>   label, item, three blocks set before (dx|dy|dz|spec), one block set after, two blocks checked
    05 FILLER PIC X(72) VALUE "a lone wall has a post and no arms".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[up=true,north=none,east=none,south=none,west=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a wall beside a wall connects low and both keep their post".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=none,north=none,south=none,up=true]".
    05 FILLER PIC X(110) VALUE "-1|1|0|cobblestone_wall[east=low,west=none,up=true]".
    05 FILLER PIC X(72) VALUE "a straight run of walls has no post".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=low,up=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a corner of walls has a post".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|1|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,south=low,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a wall beside a stone block connects".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=none,north=none,south=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "leaves do not connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|-1|oak_leaves".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[north=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a bottom slab does not connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|1|stone_slab[type=bottom]".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[south=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a double slab connects to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|1|stone_slab[type=double]".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[south=low]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "iron bars connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|iron_bars".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=low]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a glass pane connects to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|glass_pane".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=low]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a stone block above makes the arms tall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|2|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=tall,east=tall,up=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a wall above raises the post".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|2|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=low,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a gate across the run connects to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|oak_fence_gate[facing=north]".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=low]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a gate along the run does not connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|oak_fence_gate[facing=east]".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "another kind of wall connects to a mossy wall".
    05 FILLER PIC X(24) VALUE "sandstone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|mossy_cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|sandstone_wall[west=low]".
    05 FILLER PIC X(110) VALUE "-1|1|0|mossy_cobblestone_wall[east=low]".
    05 FILLER PIC X(72) VALUE "a stone block set beside a wall connects it".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "1|1|0|stone".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=low,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "taking the stone block away disconnects the wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "1|1|0|air".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=none,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a wall set beside a wall connects both".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[east=low]".
    05 FILLER PIC X(110) VALUE "1|1|0|cobblestone_wall[west=low]".
    05 FILLER PIC X(72) VALUE "a wall set above a straight run raises the post".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "0|2|0|cobblestone_wall".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=low,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a stone block set above a straight run makes the arms tall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "0|2|0|stone".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=tall,east=tall,up=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a fence beside a fence connects both".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "0|1|-1|oak_fence".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[north=true,south=false,east=false,west=false]".
    05 FILLER PIC X(110) VALUE "0|1|-1|oak_fence[south=true,north=false]".
    05 FILLER PIC X(72) VALUE "a wooden fence does not connect to a nether brick fence".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "0|1|-1|nether_brick_fence".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[north=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a fence beside a stone block connects".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "1|1|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[east=true,west=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a fence connects to a gate across it".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "1|1|0|oak_fence_gate[facing=north]".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[east=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a fence does not connect to leaves".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "1|1|0|oak_leaves".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[east=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a stone block set beside a fence connects it".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "-1|1|0|stone".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[west=true,east=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a glass pane beside a stone block connects".
    05 FILLER PIC X(24) VALUE "glass_pane".
    05 FILLER PIC X(48) VALUE "-1|1|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|glass_pane[west=true,east=false,north=false,south=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a glass pane does not connect to a fence".
    05 FILLER PIC X(24) VALUE "glass_pane".
    05 FILLER PIC X(48) VALUE "1|1|0|oak_fence".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|glass_pane[east=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a glass pane beside a pane connects both".
    05 FILLER PIC X(24) VALUE "glass_pane".
    05 FILLER PIC X(48) VALUE "0|1|1|blue_stained_glass_pane".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|glass_pane[south=true]".
    05 FILLER PIC X(110) VALUE "0|1|1|blue_stained_glass_pane[north=true]".
    05 FILLER PIC X(72) VALUE "iron bars beside a wall connect both".
    05 FILLER PIC X(24) VALUE "iron_bars".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|iron_bars[east=true]".
    05 FILLER PIC X(110) VALUE "1|1|0|cobblestone_wall[west=low]".
    05 FILLER PIC X(72) VALUE "a pumpkin does not connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|-1|pumpkin".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[north=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a shulker box does not connect to a wall".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|1|-1|white_shulker_box".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[north=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a block put under a wall changes nothing".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "0|0|0|dirt".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[up=true,north=none,east=none]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a block put above a fence changes nothing".
    05 FILLER PIC X(24) VALUE "oak_fence".
    05 FILLER PIC X(48) VALUE "1|1|0|stone".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "0|2|0|stone".
    05 FILLER PIC X(110) VALUE "0|1|0|oak_fence[east=true,north=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a stone block set beside a pane connects it".
    05 FILLER PIC X(24) VALUE "glass_pane".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE "-1|1|0|stone".
    05 FILLER PIC X(110) VALUE "0|1|0|glass_pane[west=true,east=false]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a sign above a straight run of walls raises the post (wall_post_override)".
    05 FILLER PIC X(24) VALUE "cobblestone_wall".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE "0|2|-1|stone".
    05 FILLER PIC X(48) VALUE "0|2|0|oak_wall_sign[facing=south]".
    05 FILLER PIC X(110) VALUE "0|1|0|cobblestone_wall[west=low,east=low,up=true]".
    05 FILLER PIC X(110) VALUE " ".
    05 FILLER PIC X(72) VALUE "a stone block placed beside a wall connects the wall".
    05 FILLER PIC X(24) VALUE "stone".
    05 FILLER PIC X(48) VALUE "-1|1|0|cobblestone_wall".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(48) VALUE " ".
    05 FILLER PIC X(110) VALUE "0|1|0|stone".
    05 FILLER PIC X(110) VALUE "-1|1|0|cobblestone_wall[east=low,up=true]".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-ROW OCCURS 37 TIMES.
       10 WS-C-LABEL       PIC X(72).
       10 WS-C-ITEM        PIC X(24).
       10 WS-C-PRE         PIC X(48) OCCURS 3 TIMES.
       10 WS-C-POST        PIC X(48).
       10 WS-C-CHECK       PIC X(110) OCCURS 2 TIMES.
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
         MOVE "acceptance connecting blocks no generated packs here, skipped" TO TL-CASE
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
     MOVE "ConnectWalls" TO CS-NEW-WORLD-NAME
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
     COMPUTE WS-PX = WS-BX + 6
     COMPUTE WS-PY = WS-FLOOR + 4
     COMPUTE WS-PZ = WS-BZ + 6
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         PERFORM RUN-CASE
     END-PERFORM
     STOP RUN.

*> One case of the table: the space cleared, the support and the blocks around it set, the item used, the post block set, the listed blocks compared.
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
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-PX WS-PY WS-PZ WS-STONE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE WS-C-PRE(WS-I, WS-K) TO WS-TEXT
         PERFORM CHANGE-BLOCK
     END-PERFORM
     MOVE FUNCTION TRIM(WS-C-ITEM(WS-I)) TO WS-KEY112
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY112 WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 5 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-USE-ON" USING WS-CONN WS-PX WS-PY WS-PZ 1 WS-SEQ
     MOVE WS-C-POST(WS-I) TO WS-TEXT
     PERFORM CHANGE-BLOCK
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE WS-C-CHECK(WS-I, WS-K) TO WS-CHECK-TEXT
         IF WS-CHECK-TEXT NOT = SPACES
             PERFORM CHECK-BLOCK
         END-IF
     END-PERFORM.

*> WS-TEXT "dx|dy|dz|spec" (the offsets from the support's cell): the block is set with its neighbour updates; blank text does nothing.
 CHANGE-BLOCK.
     IF WS-TEXT NOT = SPACES
         MOVE SPACES TO WS-TX WS-TY WS-TZ WS-SPEC
         UNSTRING WS-TEXT DELIMITED BY "|" INTO WS-TX WS-TY WS-TZ WS-SPEC
         COMPUTE WS-X = WS-PX + FUNCTION NUMVAL(WS-TX)
         COMPUTE WS-Y = WS-PY + FUNCTION NUMVAL(WS-TY)
         COMPUTE WS-Z = WS-PZ + FUNCTION NUMVAL(WS-TZ)
         PERFORM SPEC-STATE
         CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     END-IF.

*> WS-CHECK-TEXT "dx|dy|dz|key[name=value,...]": the block there has that key and those properties.
 CHECK-BLOCK.
     MOVE SPACES TO WS-TX WS-TY WS-TZ WS-TSPEC
     UNSTRING WS-CHECK-TEXT DELIMITED BY "|" INTO WS-TX WS-TY WS-TZ WS-TSPEC
     COMPUTE WS-X = WS-PX + FUNCTION NUMVAL(WS-TX)
     COMPUTE WS-Y = WS-PY + FUNCTION NUMVAL(WS-TY)
     COMPUTE WS-Z = WS-PZ + FUNCTION NUMVAL(WS-TZ)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     PERFORM OBSERVE
     MOVE SPACES TO WS-CASE
     STRING "acceptance connecting blocks: " FUNCTION TRIM(WS-C-LABEL(WS-I)) " at " FUNCTION TRIM(WS-TX) "," FUNCTION TRIM(WS-TY)
         "," FUNCTION TRIM(WS-TZ) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TSPEC) TO TL-EXPECTED
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

*> WS-OBSERVED: the block of WS-STATE and the properties the expected spec lists, as "key[name=value,...]".
 OBSERVE.
     CALL "PS-NAME-OF" USING WS-STATE WS-NAME-OUT
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-NAME-OUT) TO WS-OBSERVED
     MOVE WS-TSPEC TO WS-SPEC
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
 END PROGRAM ACC-BUGFLUIDWALLS-CONNECT.

 COPY CORETEST.
 COPY CMDTEST.
