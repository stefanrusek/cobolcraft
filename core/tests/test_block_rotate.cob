*> Acceptance test of docs/protocol/24-block-registry-9-rotation-and-mirror.md (BlockState.rotate and BlockState.mirror), over the standard content set of the
*> generated packs (skipped as a pass without them): the family of every block (section 4 counts: 587 change under rotate, 511 under mirror, 699 under neither), the
*> worked examples of section 6, the full tables of 3.3 (sixteen steps), 3.9 (rails) and 3.11 (orientation), and the structural identities of section 7 over every state
*> of every block of Appendix A (four quarter turns, a turn and its inverse, a mirror twice).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-ROTATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CTPROPS.
 01 WS-IN-PROPS.
    05 WI-COUNT            BINARY-LONG.
    05 WI-ENTRY OCCURS 16 TIMES.
       10 WI-NAME          PIC X(24).
       10 WI-VALUE         PIC X(32).
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS-IN            PIC X(160).
 01 WS-PAIRS-OUT           PIC X(160).
 01 WS-WANT                PIC X(170).
 01 WS-HAVE                PIC X(170).
 01 WS-NEEDLE              PIC X(60).
 01 WS-LABEL               PIC X(80).
 01 WS-OP                  PIC X.
 01 WS-CODE                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-K48                 PIC X(48).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                 PIC -(8)9.
 01 WS-WANTED-VALUE        PIC X(32).
 01 WS-MISMATCH            PIC X(200).
 01 WS-COUNTS.
    05 WS-COUNT            BINARY-LONG OCCURS 17 TIMES.
 01 WS-CHANGED-R           BINARY-LONG.
 01 WS-CHANGED-M           BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BAD-TEXT            PIC X(200).
 01 WS-CELL                PIC X(32).
 01 WS-ROW-TEXT            PIC X(120).
 01 WS-COLUMN OCCURS 6 TIMES PIC X(32).
 01 WS-TABLE-KEY           PIC X(40).
 01 WS-TABLE-PROP          PIC X(24).
 01 WS-TABLE-ROWS.
    05 WS-TR               PIC X(120) OCCURS 12 TIMES.
 01 WS-TABLE-N             BINARY-LONG.
 01 WS-STATE-MEM           BINARY-LONG.
 01 WS-STATE2              BINARY-LONG.
 01 WS-OK                BINARY-LONG.
 01 WS-LIST                PIC X(170).
 01 WS-LISTLEN             BINARY-LONG.
 01 WS-CELL-TEXT           PIC X(200).
 01 WS-FIRST-MISS          PIC X(200).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
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
         MOVE "block rotate 24-9 no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "BLOCKS-OPEN"

*>   Section 4: the family of every block, and the counts.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 17
         MOVE 0 TO WS-COUNT(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE CB-KEY(WS-I) TO WS-K48
         CALL "BLOCK-ROT-FAMILY" USING WS-K48 WS-FAMILY
         ADD 1 TO WS-COUNT(WS-FAMILY + 1)
     END-PERFORM
     MOVE "block rotate 24-9 §4.2 the 1286 blocks are in the table" TO TL-CASE
     MOVE "1286" TO TL-EXPECTED
     MOVE CB-BLOCK-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "block rotate 24-9 §4.2 family sizes A A2 B C D D2 E F G H I J K L M N and the 699 unchanged blocks" TO TL-CASE
     MOVE "213 3 41 1 72 1 49 42 33 1 3 3 97 4 22 2 699" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 17
         MOVE WS-COUNT(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS
     END-PERFORM
     MOVE WS-COUNT(1) TO WS-ED
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "block rotate 24-9 §4 a key of another content set and a key with a near name are not in a family" TO TL-CASE
     MOVE "cobolcraft:cardstack" TO WS-K48
     CALL "BLOCK-ROT-FAMILY" USING WS-K48 WS-FAMILY
     MOVE WS-FAMILY TO WS-ED
     MOVE "chorus_plant" TO WS-K48
     CALL "BLOCK-ROT-FAMILY" USING WS-K48 WS-FAMILY
     MOVE WS-FAMILY TO WS-ED2
     MOVE "0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Section 6, stairs.
     MOVE "stairs 1" TO WS-LABEL
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=east,half=bottom,shape=inner_left" TO WS-PAIRS-IN
     MOVE "facing=south" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "stairs 2" TO WS-LABEL
     MOVE "facing=north,shape=outer_left" TO WS-PAIRS-IN
     MOVE "facing=south,shape=outer_right" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "stairs 3" TO WS-LABEL
     MOVE "facing=north,shape=inner_left" TO WS-PAIRS-IN
     MOVE "facing=south,shape=inner_right" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "stairs 4" TO WS-LABEL
     MOVE "facing=east,shape=inner_left" TO WS-PAIRS-IN
     MOVE "facing=west,shape=inner_left" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "stairs 5" TO WS-LABEL
     MOVE "facing=east,shape=outer_right" TO WS-PAIRS-IN
     MOVE "facing=west,shape=outer_left" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "stairs 6a" TO WS-LABEL
     MOVE "facing=east,shape=inner_right" TO WS-PAIRS-IN
     MOVE "facing=east,shape=inner_right" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "stairs 6b" TO WS-LABEL
     MOVE "facing=north,shape=straight" TO WS-PAIRS-IN
     MOVE "facing=north,shape=straight" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "stairs 7 mirror left_right, then rotate counterclockwise 90" TO WS-LABEL
     MOVE "facing=south,shape=outer_left" TO WS-PAIRS-IN
     MOVE "facing=west,shape=outer_right" TO WS-PAIRS-OUT
     MOVE "B" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE

*>   Doors.
     MOVE "door 1" TO WS-LABEL
     MOVE "oak_door" TO WS-KEY
     MOVE "facing=north,hinge=left,half=lower,open=false" TO WS-PAIRS-IN
     MOVE "facing=east,hinge=left" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "door 2" TO WS-LABEL
     MOVE "facing=south,hinge=right" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     PERFORM RUN-CASE
     MOVE "door 3" TO WS-LABEL
     MOVE "facing=north,hinge=right" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "door 4" TO WS-LABEL
     MOVE "facing=east,hinge=right" TO WS-PAIRS-IN
     MOVE "facing=east,hinge=left" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE

*>   Rails.
     MOVE "rail 1 cw90" TO WS-LABEL
     MOVE "rail" TO WS-KEY
     MOVE "shape=south_east" TO WS-PAIRS-IN
     MOVE "shape=south_west" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "rail 1 cw180" TO WS-LABEL
     MOVE "shape=north_west" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "rail 1 ccw90" TO WS-LABEL
     MOVE "shape=north_east" TO WS-PAIRS-OUT
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "powered rail 4" TO WS-LABEL
     MOVE "powered_rail" TO WS-KEY
     MOVE "shape=east_west,powered=true" TO WS-PAIRS-IN
     MOVE "shape=north_south,powered=true" TO WS-PAIRS-OUT
     PERFORM RUN-CASE

*>   Chests, redstone wire, walls, fences.
     MOVE "chest 1" TO WS-LABEL
     MOVE "chest" TO WS-KEY
     MOVE "facing=north,type=left,waterlogged=false" TO WS-PAIRS-IN
     MOVE "facing=south,type=left" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "chest 2" TO WS-LABEL
     MOVE "R" TO WS-OP
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "chest 2 front_back" TO WS-LABEL
     MOVE "facing=north,type=left" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "redstone 1" TO WS-LABEL
     MOVE "redstone_wire" TO WS-KEY
     MOVE "north=side,east=up,south=none,west=none,power=7" TO WS-PAIRS-IN
     MOVE "east=side,south=up,west=none,north=none,power=7" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "redstone 2" TO WS-LABEL
     MOVE "north=none,south=side,east=up,west=none" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     PERFORM RUN-CASE
     MOVE "redstone 3" TO WS-LABEL
     MOVE "north=side,south=none,east=none,west=up" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "wall 1" TO WS-LABEL
     MOVE "cobblestone_wall" TO WS-KEY
     MOVE "north=low,east=tall,south=none,west=none,up=true" TO WS-PAIRS-IN
     MOVE "north=tall,east=none,south=none,west=low,up=true" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "wall 2" TO WS-LABEL
     MOVE "north=none,east=none,south=low,west=tall" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "moss carpet 3" TO WS-LABEL
     MOVE "pale_moss_carpet" TO WS-KEY
     MOVE "bottom=true,north=tall,east=low,south=none,west=none" TO WS-PAIRS-IN
     MOVE "east=tall,south=low,west=none,north=none,bottom=true" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "fence 1" TO WS-LABEL
     MOVE "oak_fence" TO WS-KEY
     MOVE "north=true,east=false,south=false,west=true" TO WS-PAIRS-IN
     MOVE "north=false,east=true,south=true,west=false" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "vine 2" TO WS-LABEL
     MOVE "vine" TO WS-KEY
     MOVE "up=true,north=true,east=false,south=false,west=false" TO WS-PAIRS-IN
     MOVE "up=true,east=true,north=false,south=false,west=false" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "tripwire 3" TO WS-LABEL
     MOVE "tripwire" TO WS-KEY
     MOVE "north=true,south=true,attached=true,east=false,west=false" TO WS-PAIRS-IN
     MOVE "north=true,south=true,attached=true" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE

*>   Facing: A, B, C, A2.
     MOVE "piston 1" TO WS-LABEL
     MOVE "piston" TO WS-KEY
     MOVE "facing=west,extended=false" TO WS-PAIRS-IN
     MOVE "facing=north" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "piston up under every transform" TO WS-LABEL
     MOVE "facing=up" TO WS-PAIRS-IN
     MOVE "facing=up" TO WS-PAIRS-OUT
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "hopper 2" TO WS-LABEL
     MOVE "hopper" TO WS-KEY
     MOVE "facing=east" TO WS-PAIRS-IN
     MOVE "facing=north" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "hopper down" TO WS-LABEL
     MOVE "facing=down" TO WS-PAIRS-IN
     MOVE "facing=down" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "wall torch 3 left_right" TO WS-LABEL
     MOVE "wall_torch" TO WS-KEY
     MOVE "facing=east" TO WS-PAIRS-IN
     MOVE "facing=east" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "wall torch 3 front_back" TO WS-LABEL
     MOVE "facing=west" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "trapdoor 4" TO WS-LABEL
     MOVE "oak_trapdoor" TO WS-KEY
     MOVE "facing=east,half=top,open=true" TO WS-PAIRS-IN
     MOVE "facing=south,half=top,open=true" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "bed 5" TO WS-LABEL
     MOVE "white_bed" TO WS-KEY
     MOVE "facing=north,part=head" TO WS-PAIRS-IN
     MOVE "facing=south,part=head" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "anvil 6 rotate" TO WS-LABEL
     MOVE "anvil" TO WS-KEY
     MOVE "facing=east" TO WS-PAIRS-IN
     MOVE "facing=south" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "anvil 6 mirror front_back" TO WS-LABEL
     MOVE "facing=east" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE

*>   Axis.
     MOVE "log x cw90" TO WS-LABEL
     MOVE "oak_log" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS-IN
     MOVE "axis=z" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "log y cw90" TO WS-LABEL
     MOVE "axis=y" TO WS-PAIRS-IN
     MOVE "axis=y" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "log z cw180" TO WS-LABEL
     MOVE "axis=z" TO WS-PAIRS-IN
     MOVE "axis=z" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "log z ccw90" TO WS-LABEL
     MOVE "axis=x" TO WS-PAIRS-OUT
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "log x mirror" TO WS-LABEL
     MOVE "axis=x" TO WS-PAIRS-IN
     MOVE "axis=x" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "portal x cw90" TO WS-LABEL
     MOVE "nether_portal" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS-IN
     MOVE "axis=z" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE

*>   Orientation, multiface, huge mushroom, chorus, lever, bell.
     MOVE "jigsaw cw90" TO WS-LABEL
     MOVE "jigsaw" TO WS-KEY
     MOVE "orientation=north_up" TO WS-PAIRS-IN
     MOVE "orientation=east_up" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "jigsaw left_right" TO WS-LABEL
     MOVE "orientation=south_up" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     PERFORM RUN-CASE
     MOVE "jigsaw front_back" TO WS-LABEL
     MOVE "orientation=north_up" TO WS-PAIRS-OUT
     MOVE 2 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "crafter cw90" TO WS-LABEL
     MOVE "crafter" TO WS-KEY
     MOVE "orientation=up_north" TO WS-PAIRS-IN
     MOVE "orientation=up_east" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "crafter left_right" TO WS-LABEL
     MOVE "orientation=up_south" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     PERFORM RUN-CASE
     MOVE "crafter ccw90" TO WS-LABEL
     MOVE "orientation=down_west" TO WS-PAIRS-IN
     MOVE "orientation=down_south" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "glow lichen cw90" TO WS-LABEL
     MOVE "glow_lichen" TO WS-KEY
     MOVE "north=true,up=true,east=false,south=false,west=false,down=false" TO WS-PAIRS-IN
     MOVE "east=true,north=false,up=true" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "glow lichen left_right" TO WS-LABEL
     MOVE "south=true,north=false,up=true" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     PERFORM RUN-CASE
     MOVE "mushroom ccw90" TO WS-LABEL
     MOVE "red_mushroom_block" TO WS-KEY
     MOVE "north=true,down=true,east=false,south=false,west=false,up=false" TO WS-PAIRS-IN
     MOVE "west=true,north=false,down=true" TO WS-PAIRS-OUT
     MOVE "R" TO WS-OP
     MOVE 3 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "chorus plant unchanged" TO WS-LABEL
     MOVE "chorus_plant" TO WS-KEY
     MOVE "north=true,east=false,south=false,west=false,up=false,down=false" TO WS-PAIRS-IN
     MOVE "north=true" TO WS-PAIRS-OUT
     PERFORM RUN-CASE
     MOVE "lever cw90" TO WS-LABEL
     MOVE "lever" TO WS-KEY
     MOVE "face=wall,facing=north" TO WS-PAIRS-IN
     MOVE "face=wall,facing=east" TO WS-PAIRS-OUT
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE
     MOVE "bell left_right" TO WS-LABEL
     MOVE "bell" TO WS-KEY
     MOVE "attachment=single_wall,facing=south" TO WS-PAIRS-IN
     MOVE "attachment=single_wall,facing=north" TO WS-PAIRS-OUT
     MOVE "M" TO WS-OP
     MOVE 1 TO WS-CODE
     PERFORM RUN-CASE

*>   Section 3.3: the 16 steps (rows: rotation cw90 cw180 ccw90 left_right front_back).
     MOVE "oak_sign" TO WS-TABLE-KEY
     MOVE "rotation" TO WS-TABLE-PROP
     MOVE "0 4 8 12 8 0" TO WS-TR(1)
     MOVE "1 5 9 13 7 15" TO WS-TR(2)
     MOVE "2 6 10 14 6 14" TO WS-TR(3)
     MOVE "3 7 11 15 5 13" TO WS-TR(4)
     MOVE "4 8 12 0 4 12" TO WS-TR(5)
     MOVE "5 9 13 1 3 11" TO WS-TR(6)
     MOVE "6 10 14 2 2 10" TO WS-TR(7)
     MOVE "7 11 15 3 1 9" TO WS-TR(8)
     MOVE "8 12 0 4 0 8" TO WS-TR(9)
     MOVE "9 13 1 5 15 7" TO WS-TR(10)
     MOVE "10 14 2 6 14 6" TO WS-TR(11)
     MOVE "11 15 3 7 13 5" TO WS-TR(12)
     MOVE 12 TO WS-TABLE-N
     MOVE "table 3.3 rows 0 to 11" TO WS-LABEL
     PERFORM RUN-TABLE
     MOVE "12 0 4 8 12 4" TO WS-TR(1)
     MOVE "13 1 5 9 11 3" TO WS-TR(2)
     MOVE "14 2 6 10 10 2" TO WS-TR(3)
     MOVE "15 3 7 11 9 1" TO WS-TR(4)
     MOVE 4 TO WS-TABLE-N
     MOVE "table 3.3 rows 12 to 15" TO WS-LABEL
     PERFORM RUN-TABLE
*>   Section 3.9: rails.
     MOVE "rail" TO WS-TABLE-KEY
     MOVE "shape" TO WS-TABLE-PROP
     MOVE "north_south east_west north_south east_west north_south north_south" TO WS-TR(1)
     MOVE "east_west north_south east_west north_south east_west east_west" TO WS-TR(2)
     MOVE "ascending_east ascending_south ascending_west ascending_north ascending_east ascending_west" TO WS-TR(3)
     MOVE "ascending_west ascending_north ascending_east ascending_south ascending_west ascending_east" TO WS-TR(4)
     MOVE "ascending_north ascending_east ascending_south ascending_west ascending_south ascending_north" TO WS-TR(5)
     MOVE "ascending_south ascending_west ascending_north ascending_east ascending_north ascending_south" TO WS-TR(6)
     MOVE "south_east south_west north_west north_east north_east south_west" TO WS-TR(7)
     MOVE "south_west north_west north_east south_east north_west south_east" TO WS-TR(8)
     MOVE "north_west north_east south_east south_west south_west north_east" TO WS-TR(9)
     MOVE "north_east south_east south_west north_west south_east north_west" TO WS-TR(10)
     MOVE 10 TO WS-TABLE-N
     MOVE "table 3.9 rails" TO WS-LABEL
     PERFORM RUN-TABLE
*>   Section 3.11: orientation.
     MOVE "crafter" TO WS-TABLE-KEY
     MOVE "orientation" TO WS-TABLE-PROP
     MOVE "down_east down_south down_west down_north down_east down_west" TO WS-TR(1)
     MOVE "down_north down_east down_south down_west down_south down_north" TO WS-TR(2)
     MOVE "down_south down_west down_north down_east down_north down_south" TO WS-TR(3)
     MOVE "down_west down_north down_east down_south down_west down_east" TO WS-TR(4)
     MOVE "up_east up_south up_west up_north up_east up_west" TO WS-TR(5)
     MOVE "up_north up_east up_south up_west up_south up_north" TO WS-TR(6)
     MOVE "up_south up_west up_north up_east up_north up_south" TO WS-TR(7)
     MOVE "up_west up_north up_east up_south up_west up_east" TO WS-TR(8)
     MOVE "west_up north_up east_up south_up west_up east_up" TO WS-TR(9)
     MOVE "east_up south_up west_up north_up east_up west_up" TO WS-TR(10)
     MOVE "north_up east_up south_up west_up south_up north_up" TO WS-TR(11)
     MOVE "south_up west_up north_up east_up north_up south_up" TO WS-TR(12)
     MOVE 12 TO WS-TABLE-N
     MOVE "table 3.11 orientation" TO WS-LABEL
     PERFORM RUN-TABLE

*>   Section 7: identities over every state of every block of Appendix A (and the counts of blocks that change).
     MOVE 0 TO WS-BAD
     MOVE SPACES TO WS-BAD-TEXT
     MOVE 0 TO WS-CHANGED-R
     MOVE 0 TO WS-CHANGED-M
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE CB-KEY(WS-I) TO WS-K48
         CALL "BLOCK-ROT-FAMILY" USING WS-K48 WS-FAMILY
         IF WS-FAMILY > 0
             PERFORM CHECK-BLOCK
         ELSE
             PERFORM CHECK-UNCHANGED
         END-IF
     END-PERFORM
     MOVE "block rotate 24-9 §7 every state: four quarter turns, a turn and its inverse, a mirror twice, none, the same block" TO TL-CASE
     MOVE "bad 0" TO TL-EXPECTED
     MOVE WS-BAD TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING "bad " FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-BAD-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "block rotate 24-9 §4.2 587 blocks change under rotate, 511 under mirror, the others (699) under neither" TO TL-CASE
     MOVE "587 511" TO TL-EXPECTED
     MOVE WS-CHANGED-R TO WS-ED
     MOVE WS-CHANGED-M TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A state outside the table and a block without properties come back unchanged.
     MOVE "block rotate 24-9 §1 a state that is not in the table and a block without properties are returned unchanged" TO TL-CASE
     MOVE 999999 TO WS-STATE
     MOVE 1 TO WS-K
     CALL "BLOCK-ROTATE-STATE" USING WS-STATE WS-K WS-RESULT
     MOVE WS-RESULT TO WS-ED
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS-IN
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS-IN WS-STATE
     MOVE 2 TO WS-K
     CALL "BLOCK-MIRROR-STATE" USING WS-STATE WS-K WS-RESULT
     MOVE WS-STATE TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "999999 " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-RESULT TO WS-A
     MOVE WS-A TO WS-ED2
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> RUN-CASE: the first state of WS-KEY whose properties hold WS-PAIRS-IN, transformed by WS-OP (R rotate, M mirror, B mirror then rotate; WS-CODE: the rotation 1..3
*> or the mirror 1..2; B mirrors by 1 and rotates by 3), must have the properties of WS-PAIRS-OUT changed and every other property as before.
 RUN-CASE.
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-BLOCK
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-BLOCK + 1) + CB-STATES(WS-BLOCK + 1) - 1
     MOVE SPACES TO WS-WANT
     STRING "," FUNCTION TRIM(WS-PAIRS-IN) "," DELIMITED BY SIZE INTO WS-WANT
     MOVE -1 TO WS-STATE
     MOVE CB-FIRST-STATE(WS-BLOCK + 1) TO WS-S
     PERFORM UNTIL WS-S > WS-LAST OR WS-STATE >= 0
         CALL "BLOCKS-STATE-PROPS" USING WS-S WS-HAVE
         PERFORM MATCH-STATE
         ADD 1 TO WS-S
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "block rotate 24-9 §6 example " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE "ok" TO TL-EXPECTED
     IF WS-STATE < 0
         MOVE "no state has the input properties" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ELSE
         EVALUATE WS-OP
             WHEN "R"
                 CALL "BLOCK-ROTATE-STATE" USING WS-STATE WS-CODE WS-RESULT
             WHEN "M"
                 CALL "BLOCK-MIRROR-STATE" USING WS-STATE WS-CODE WS-RESULT
             WHEN OTHER
                 MOVE 1 TO WS-A
                 CALL "BLOCK-MIRROR-STATE" USING WS-STATE WS-A WS-B
                 MOVE 3 TO WS-A
                 CALL "BLOCK-ROTATE-STATE" USING WS-B WS-A WS-RESULT
         END-EVALUATE
         PERFORM COMPARE-STATE
         MOVE WS-MISMATCH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF.

 MATCH-STATE.
     MOVE SPACES TO WS-ROW-TEXT
     STRING "," FUNCTION TRIM(WS-HAVE) "," DELIMITED BY SIZE INTO WS-ROW-TEXT
     MOVE SPACES TO WS-LIST
     STRING FUNCTION TRIM(WS-PAIRS-IN) "," DELIMITED BY SIZE INTO WS-LIST
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LIST)) TO WS-LISTLEN
     MOVE 1 TO WS-POS
     MOVE 1 TO WS-OK
     PERFORM UNTIL WS-POS > WS-LISTLEN
         MOVE SPACES TO WS-CELL
         MOVE 0 TO WS-LEN
         UNSTRING WS-LIST DELIMITED BY "," INTO WS-CELL COUNT IN WS-LEN WITH POINTER WS-POS
         MOVE SPACES TO WS-NEEDLE
         STRING "," WS-CELL(1:WS-LEN) "," DELIMITED BY SIZE INTO WS-NEEDLE
         COMPUTE WS-N = WS-LEN + 2
         MOVE 0 TO WS-TALLY
         INSPECT WS-ROW-TEXT TALLYING WS-TALLY FOR ALL WS-NEEDLE(1:WS-N)
         IF WS-TALLY = 0
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     IF WS-OK = 1
         MOVE WS-S TO WS-STATE
     END-IF.

*> COMPARE-STATE: WS-MISMATCH = "ok" when the properties of WS-RESULT are those of WS-STATE with the pairs of WS-PAIRS-OUT replaced.
 COMPARE-STATE.
     CALL "CONTENT-STATE-PROPS" USING WS-STATE CT-PROPS WS-STATUS
     MOVE CT-PROPS TO WS-IN-PROPS
     CALL "CONTENT-STATE-PROPS" USING WS-RESULT CT-PROPS WS-STATUS
     MOVE "ok" TO WS-MISMATCH
     MOVE SPACES TO WS-WANT
     STRING "," FUNCTION TRIM(WS-PAIRS-OUT) "," DELIMITED BY SIZE INTO WS-WANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
         MOVE WI-VALUE(WS-I) TO WS-WANTED-VALUE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-NAME(WS-I))) TO WS-LEN
         MOVE SPACES TO WS-NEEDLE
         STRING "," CTP-NAME(WS-I)(1:WS-LEN) "=" DELIMITED BY SIZE INTO WS-NEEDLE
         COMPUTE WS-N = WS-LEN + 2
         MOVE 0 TO WS-TALLY
         INSPECT WS-WANT TALLYING WS-TALLY FOR CHARACTERS BEFORE INITIAL WS-NEEDLE(1:WS-N)
         IF WS-TALLY < 170 - WS-N
             COMPUTE WS-POS = WS-TALLY + WS-N + 1
             MOVE SPACES TO WS-WANTED-VALUE
             UNSTRING WS-WANT DELIMITED BY "," INTO WS-WANTED-VALUE WITH POINTER WS-POS
         END-IF
         IF CTP-VALUE(WS-I) NOT = WS-WANTED-VALUE
             MOVE SPACES TO WS-MISMATCH
             STRING FUNCTION TRIM(CTP-NAME(WS-I)) " got " FUNCTION TRIM(CTP-VALUE(WS-I)) " want " FUNCTION TRIM(WS-WANTED-VALUE)
                 DELIMITED BY SIZE INTO WS-MISMATCH
             EXIT PERFORM
         END-IF
     END-PERFORM.

*> RUN-TABLE: WS-TR(1..WS-TABLE-N) are rows "input r90 r180 r270 left_right front_back" of WS-TABLE-PROP of WS-TABLE-KEY.
 RUN-TABLE.
     MOVE WS-TABLE-KEY TO WS-KEY
     MOVE SPACES TO WS-FIRST-MISS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-TABLE-N
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             MOVE SPACES TO WS-COLUMN(WS-K)
             UNSTRING WS-TR(WS-J) DELIMITED BY ALL SPACE INTO WS-COLUMN(WS-K) WITH POINTER WS-POS
         END-PERFORM
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 6
             MOVE SPACES TO WS-PAIRS-IN
             STRING FUNCTION TRIM(WS-TABLE-PROP) "=" FUNCTION TRIM(WS-COLUMN(1)) DELIMITED BY SIZE INTO WS-PAIRS-IN
             MOVE SPACES TO WS-PAIRS-OUT
             STRING FUNCTION TRIM(WS-TABLE-PROP) "=" FUNCTION TRIM(WS-COLUMN(WS-K)) DELIMITED BY SIZE INTO WS-PAIRS-OUT
             IF WS-K < 5
                 MOVE "R" TO WS-OP
                 COMPUTE WS-CODE = WS-K - 1
             ELSE
                 MOVE "M" TO WS-OP
                 COMPUTE WS-CODE = WS-K - 4
             END-IF
             MOVE WS-CODE TO WS-ED
             MOVE SPACES TO WS-LABEL
             STRING FUNCTION TRIM(WS-TABLE-KEY) " " FUNCTION TRIM(WS-COLUMN(1)) " " WS-OP FUNCTION TRIM(WS-ED)
                 DELIMITED BY SIZE INTO WS-LABEL
             PERFORM RUN-CASE-QUIET
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "block rotate 24-9 §3 " FUNCTION TRIM(WS-TABLE-KEY) " " FUNCTION TRIM(WS-TABLE-PROP) " all rows and columns"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "ok" TO TL-EXPECTED
     IF WS-FIRST-MISS = SPACES
         MOVE "ok" TO TL-OBSERVED
     ELSE
         MOVE WS-FIRST-MISS TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> RUN-CASE-QUIET: as RUN-CASE but a mismatch is collected in WS-MISMATCH (first one kept) and nothing is printed.
 RUN-CASE-QUIET.
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-BLOCK
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-BLOCK + 1) + CB-STATES(WS-BLOCK + 1) - 1
     MOVE -1 TO WS-STATE
     MOVE CB-FIRST-STATE(WS-BLOCK + 1) TO WS-S
     PERFORM UNTIL WS-S > WS-LAST OR WS-STATE >= 0
         CALL "BLOCKS-STATE-PROPS" USING WS-S WS-HAVE
         PERFORM MATCH-STATE
         ADD 1 TO WS-S
     END-PERFORM
     IF WS-STATE < 0
         MOVE "no state has the input properties" TO WS-CELL-TEXT
     ELSE
         IF WS-OP = "R"
             CALL "BLOCK-ROTATE-STATE" USING WS-STATE WS-CODE WS-RESULT
         ELSE
             CALL "BLOCK-MIRROR-STATE" USING WS-STATE WS-CODE WS-RESULT
         END-IF
         PERFORM COMPARE-STATE
         MOVE WS-MISMATCH TO WS-CELL-TEXT
     END-IF
     IF WS-CELL-TEXT NOT = "ok" AND WS-FIRST-MISS = SPACES
         STRING FUNCTION TRIM(WS-LABEL) ": " FUNCTION TRIM(WS-CELL-TEXT) DELIMITED BY SIZE INTO WS-FIRST-MISS
     END-IF.

*> CHECK-BLOCK: the identities of section 7 over every state of block WS-I (1-based), and the sets that change.
 CHECK-BLOCK.
     MOVE CB-FIRST-STATE(WS-I) TO WS-S
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-I) + CB-STATES(WS-I) - 1
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-I) BY 1 UNTIL WS-S > WS-LAST
         MOVE 0 TO WS-K
         CALL "BLOCK-ROTATE-STATE" USING WS-S WS-K WS-RESULT
         IF WS-RESULT NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         MOVE WS-S TO WS-STATE
         MOVE 1 TO WS-K
         PERFORM 4 TIMES
             CALL "BLOCK-ROTATE-STATE" USING WS-STATE WS-K WS-RESULT
             PERFORM CHECK-SAME-BLOCK
             MOVE WS-RESULT TO WS-STATE
         END-PERFORM
         IF WS-STATE NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         MOVE 1 TO WS-K
         CALL "BLOCK-ROTATE-STATE" USING WS-S WS-K WS-RESULT
         IF WS-RESULT NOT = WS-S
             MOVE 1 TO WS-A
         END-IF
         MOVE 3 TO WS-K
         CALL "BLOCK-ROTATE-STATE" USING WS-RESULT WS-K WS-STATE
         IF WS-STATE NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         MOVE 2 TO WS-K
         CALL "BLOCK-ROTATE-STATE" USING WS-S WS-K WS-RESULT
         CALL "BLOCK-ROTATE-STATE" USING WS-RESULT WS-K WS-STATE
         IF WS-STATE NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         MOVE 0 TO WS-K
         CALL "BLOCK-MIRROR-STATE" USING WS-S WS-K WS-RESULT
         IF WS-RESULT NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
             CALL "BLOCK-MIRROR-STATE" USING WS-S WS-K WS-RESULT
             PERFORM CHECK-SAME-BLOCK
             IF WS-RESULT NOT = WS-S
                 MOVE 1 TO WS-B
             END-IF
             CALL "BLOCK-MIRROR-STATE" USING WS-RESULT WS-K WS-STATE
             IF WS-STATE NOT = WS-S
                 PERFORM NOTE-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     ADD WS-A TO WS-CHANGED-R
     ADD WS-B TO WS-CHANGED-M.

*> CHECK-UNCHANGED: a block outside the table is unchanged by every transform in every state.
 CHECK-UNCHANGED.
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-I) + CB-STATES(WS-I) - 1
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-I) BY 1 UNTIL WS-S > WS-LAST
         MOVE 1 TO WS-K
         CALL "BLOCK-ROTATE-STATE" USING WS-S WS-K WS-RESULT
         IF WS-RESULT NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
         MOVE 2 TO WS-K
         CALL "BLOCK-MIRROR-STATE" USING WS-S WS-K WS-RESULT
         IF WS-RESULT NOT = WS-S
             PERFORM NOTE-BAD
         END-IF
     END-PERFORM.

 CHECK-SAME-BLOCK.
     IF WS-RESULT < CB-FIRST-STATE(WS-I) OR WS-RESULT > WS-LAST
         PERFORM NOTE-BAD
     END-IF.

 NOTE-BAD.
     ADD 1 TO WS-BAD
     IF WS-BAD-TEXT = SPACES
         MOVE WS-S TO WS-ED
         STRING FUNCTION TRIM(CB-KEY(WS-I)) " state " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-BAD-TEXT
     END-IF.
