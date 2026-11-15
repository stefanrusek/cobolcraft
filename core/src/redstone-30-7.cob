*> Redstone part 7 (docs/protocol/30-redstone-7-doors-lamps-bulbs-tnt.md) as programs of plain numbers (RS3- prefix), like part 6 and the RS1- helpers: the caller reads the level
*> and passes the facts; the program returns the decision. Nothing here is wired into the block-update hooks.
*> Directions are the data values 0 down, 1 up, 2 north, 3 south, 4 west, 5 east. Booleans are 0 and 1. Sound codes: 0 none, 1 open sound, 2 close sound;
*> event codes: 0 none, 1 BLOCK_OPEN, 2 BLOCK_CLOSE, 3 PRIME_FUSE. Half of a door: 0 upper, 1 lower; hinge 0 left, 1 right; half of a trapdoor 0 top, 1 bottom.
*> Positions inside a cell are thousandths.

*> ===== Section 1: shared conventions

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SOUND-BASE.
*> USING kind (1 door, trapdoor and gate, 2 copper bulb), volume, pitch base, pitch range out, all in millionths (section 1 item 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-VOLUME L-BASE L-RANGE.
     MOVE 1000000 TO L-VOLUME L-BASE
     MOVE 0 TO L-RANGE
     IF L-KIND = 1
         MOVE 900000 TO L-BASE
         MOVE 100000 TO L-RANGE
     END-IF
     GOBACK.
 END PROGRAM RS3-SOUND-BASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-PITCH.
*> USING nextFloat draw (a double), pitch out in millionths (section 1 item 2): draw * 0.1 + 0.9.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PITCH.
     COMPUTE L-PITCH ROUNDED = (L-DRAW * 0.1 + 0.9) * 1000000
     GOBACK.
 END PROGRAM RS3-DOOR-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SOUND-POSITION.
*> USING an acting player is present, x, y, z out (thousandths above the cell origin: the block centre), excluded entity out (1 the actor).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTOR                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EXCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTOR L-X L-Y L-Z L-EXCLUDED.
     MOVE 500 TO L-X L-Y L-Z
     MOVE L-ACTOR TO L-EXCLUDED
     GOBACK.
 END PROGRAM RS3-SOUND-POSITION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GAME-EVENT.
*> USING the new state is open, event out (1 BLOCK_OPEN, 2 BLOCK_CLOSE) (section 1 item 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPEN                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-OPEN L-EVENT.
     MOVE 2 TO L-EVENT
     IF L-OPEN = 1
         MOVE 1 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM RS3-GAME-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WRITE-FLAGS.
*> USING use (1 hand toggle of a door or gate, 2 redstone write, 3 trapdoor hand toggle, 4 bulb, 5 gate explosion, 6 TNT removal, 7 TNT air by hand),
*> flags out (section 1 item 4); 0 for another use.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-USE                  BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-USE L-FLAGS.
     EVALUATE L-USE
         WHEN 1
             MOVE 10 TO L-FLAGS
         WHEN 2 THRU 3
             MOVE 2 TO L-FLAGS
         WHEN 4 THRU 6
             MOVE 3 TO L-FLAGS
         WHEN 7
             MOVE 11 TO L-FLAGS
         WHEN OTHER
             MOVE 0 TO L-FLAGS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-WRITE-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SERVER-ONLY.
*> USING block (1 trapdoor, 2 gate, 3 lamp, 4 bulb, 5 door), server level, acts out (section 1 item 5): the door has no client test.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-ACTS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-SERVER L-ACTS.
     MOVE L-SERVER TO L-ACTS
     IF L-BLOCK = 5
         MOVE 1 TO L-ACTS
     END-IF
     GOBACK.
 END PROGRAM RS3-SERVER-ONLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-READS-ORIENTATION.
*> USING block, reads the orientation out (section 1 item 6): none of the blocks of this document.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-READS                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-READS.
     MOVE 0 TO L-READS
     GOBACK.
 END PROGRAM RS3-READS-ORIENTATION.

*> ===== Section 2: BlockSetType and WoodType (set type index 1 to 18 in the order of the static initializer, wood type index 1 to 13)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-INDEX.
*> USING set type name, index out (0 for an unknown name) (section 2, V3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-INDEX.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "iron"
             MOVE 1 TO L-INDEX
         WHEN "copper"
             MOVE 2 TO L-INDEX
         WHEN "gold"
             MOVE 3 TO L-INDEX
         WHEN "stone"
             MOVE 4 TO L-INDEX
         WHEN "polished_blackstone"
             MOVE 5 TO L-INDEX
         WHEN "oak"
             MOVE 6 TO L-INDEX
         WHEN "spruce"
             MOVE 7 TO L-INDEX
         WHEN "birch"
             MOVE 8 TO L-INDEX
         WHEN "acacia"
             MOVE 9 TO L-INDEX
         WHEN "cherry"
             MOVE 10 TO L-INDEX
         WHEN "jungle"
             MOVE 11 TO L-INDEX
         WHEN "dark_oak"
             MOVE 12 TO L-INDEX
         WHEN "pale_oak"
             MOVE 13 TO L-INDEX
         WHEN "poplar"
             MOVE 14 TO L-INDEX
         WHEN "crimson"
             MOVE 15 TO L-INDEX
         WHEN "warped"
             MOVE 16 TO L-INDEX
         WHEN "mangrove"
             MOVE 17 TO L-INDEX
         WHEN "bamboo"
             MOVE 18 TO L-INDEX
         WHEN OTHER
             MOVE 0 TO L-INDEX
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SETTYPE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-FLAGS.
*> USING set type index, canOpenByHand, canOpenByWindCharge, canButtonBeActivatedByArrows, plate sensitivity out (0 EVERYTHING, 1 MOBS) (section 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-WIND                 BINARY-LONG.
 01 L-ARROWS               BINARY-LONG.
 01 L-SENS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-HAND L-WIND L-ARROWS L-SENS.
     MOVE 0 TO L-HAND L-WIND L-ARROWS L-SENS
     EVALUATE L-INDEX
         WHEN 1
             MOVE 0 TO L-HAND
         WHEN 2
             MOVE 1 TO L-HAND L-WIND
         WHEN 3
             MOVE 1 TO L-WIND
         WHEN 4 THRU 5
             MOVE 1 TO L-HAND L-WIND L-SENS
         WHEN 6 THRU 18
             MOVE 1 TO L-HAND L-WIND L-ARROWS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SETTYPE-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-SOUNDS.
*> USING set type index, block SoundType out (1 IRON 2 COPPER 3 METAL 4 STONE 5 WOOD 6 CHERRY_WOOD 7 NETHER_WOOD 8 BAMBOO_WOOD), door and trapdoor
*> family out (1 iron, 2 copper, 3 wooden, 4 cherry wood, 5 nether wood, 6 bamboo wood), plate click family out (1 metal, 2 stone, 3 cherry, 4 nether,
*> 5 bamboo, 6 wooden default), button click family out (2 stone button, else as the plate) (section 2 table); all zero outside 1 to 18.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 01 L-PLATE                BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SOUND L-FAMILY L-PLATE L-BUTTON.
     MOVE 0 TO L-SOUND L-FAMILY L-PLATE L-BUTTON
     EVALUATE L-INDEX
         WHEN 1
             MOVE 1 TO L-SOUND L-FAMILY L-PLATE
         WHEN 2
             MOVE 2 TO L-SOUND L-FAMILY
             MOVE 1 TO L-PLATE
         WHEN 3
             MOVE 3 TO L-SOUND
             MOVE 1 TO L-FAMILY L-PLATE
         WHEN 4 THRU 5
             MOVE 4 TO L-SOUND
             MOVE 1 TO L-FAMILY
             MOVE 2 TO L-PLATE
         WHEN 10
             MOVE 6 TO L-SOUND
             MOVE 4 TO L-FAMILY
             MOVE 3 TO L-PLATE
         WHEN 15 THRU 16
             MOVE 7 TO L-SOUND
             MOVE 5 TO L-FAMILY
             MOVE 4 TO L-PLATE
         WHEN 18
             MOVE 8 TO L-SOUND
             MOVE 6 TO L-FAMILY
             MOVE 5 TO L-PLATE
         WHEN 6 THRU 9
             MOVE 5 TO L-SOUND
             MOVE 3 TO L-FAMILY
             MOVE 6 TO L-PLATE
         WHEN 11 THRU 14
             MOVE 5 TO L-SOUND
             MOVE 3 TO L-FAMILY
             MOVE 6 TO L-PLATE
         WHEN 17
             MOVE 5 TO L-SOUND
             MOVE 3 TO L-FAMILY
             MOVE 6 TO L-PLATE
     END-EVALUATE
     MOVE L-PLATE TO L-BUTTON
     IF L-PLATE = 1
         MOVE 2 TO L-BUTTON
     END-IF
     GOBACK.
 END PROGRAM RS3-SETTYPE-SOUNDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-SOUND-NAME.
*> USING set type index, kind (1 door, 2 trapdoor), which (1 close, 2 open), sound event name out (section 2 table); spaces outside 1 to 18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SOUND               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-PLATE               BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-BASE                PIC X(24).
 01 WS-TAIL                PIC X(6).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-INDEX L-KIND L-WHICH L-NAME.
     MOVE SPACES TO L-NAME
     CALL "RS3-SETTYPE-SOUNDS" USING L-INDEX WS-SOUND WS-FAMILY WS-PLATE WS-BUTTON
     IF WS-FAMILY > 0
         EVALUATE WS-FAMILY
             WHEN 1
                 MOVE "iron" TO WS-BASE
             WHEN 2
                 MOVE "copper" TO WS-BASE
             WHEN 3
                 MOVE "wooden" TO WS-BASE
             WHEN 4
                 MOVE "cherry_wood" TO WS-BASE
             WHEN 5
                 MOVE "nether_wood" TO WS-BASE
             WHEN 6
                 MOVE "bamboo_wood" TO WS-BASE
         END-EVALUATE
         MOVE ".open" TO WS-TAIL
         IF L-WHICH = 1
             MOVE ".close" TO WS-TAIL
         END-IF
         IF L-KIND = 1
             STRING "block." DELIMITED BY SIZE FUNCTION TRIM(WS-BASE) DELIMITED BY SIZE "_door" DELIMITED BY SIZE
                 FUNCTION TRIM(WS-TAIL) DELIMITED BY SIZE INTO L-NAME
         ELSE
             STRING "block." DELIMITED BY SIZE FUNCTION TRIM(WS-BASE) DELIMITED BY SIZE "_trapdoor" DELIMITED BY SIZE
                 FUNCTION TRIM(WS-TAIL) DELIMITED BY SIZE INTO L-NAME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-SETTYPE-SOUND-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-SINGLE.
*> USING set type index, built by the single-argument constructor out (oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar, mangrove).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SINGLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SINGLE.
     MOVE 0 TO L-SINGLE
     IF (L-INDEX >= 6 AND L-INDEX <= 9) OR (L-INDEX >= 11 AND L-INDEX <= 14) OR L-INDEX = 17
         MOVE 1 TO L-SINGLE
     END-IF
     GOBACK.
 END PROGRAM RS3-SETTYPE-SINGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SETTYPE-USES.
*> USING set type index, uses of the static field in the Blocks initializer out, used by doors, trapdoors or gates out (section 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-USES                 BINARY-LONG.
 01 L-DOORS                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-USES L-DOORS.
     MOVE 4 TO L-USES
     MOVE 1 TO L-DOORS
     EVALUATE L-INDEX
         WHEN 1
             MOVE 3 TO L-USES
         WHEN 3
             MOVE 1 TO L-USES
             MOVE 0 TO L-DOORS
         WHEN 4
             MOVE 3 TO L-USES
             MOVE 0 TO L-DOORS
         WHEN 5
             MOVE 1 TO L-USES
             MOVE 0 TO L-DOORS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SETTYPE-USES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WOOD-INDEX.
*> USING wood type name, index out (0 unknown) (section 2): oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, poplar, crimson, warped,
*> mangrove, bamboo.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-INDEX.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "oak"
             MOVE 1 TO L-INDEX
         WHEN "spruce"
             MOVE 2 TO L-INDEX
         WHEN "birch"
             MOVE 3 TO L-INDEX
         WHEN "acacia"
             MOVE 4 TO L-INDEX
         WHEN "cherry"
             MOVE 5 TO L-INDEX
         WHEN "jungle"
             MOVE 6 TO L-INDEX
         WHEN "dark_oak"
             MOVE 7 TO L-INDEX
         WHEN "pale_oak"
             MOVE 8 TO L-INDEX
         WHEN "poplar"
             MOVE 9 TO L-INDEX
         WHEN "crimson"
             MOVE 10 TO L-INDEX
         WHEN "warped"
             MOVE 11 TO L-INDEX
         WHEN "mangrove"
             MOVE 12 TO L-INDEX
         WHEN "bamboo"
             MOVE 13 TO L-INDEX
         WHEN OTHER
             MOVE 0 TO L-INDEX
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-WOOD-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WOOD-SOUNDS.
*> USING wood type index, SoundType out (5 WOOD 6 CHERRY_WOOD 7 NETHER_WOOD 8 BAMBOO_WOOD), hanging sign type out (1 HANGING_SIGN 2 CHERRY_WOOD_HANGING_SIGN
*> 3 NETHER_WOOD_HANGING_SIGN 4 BAMBOO_WOOD_HANGING_SIGN), gate family out (0 plain, 1 cherry, 2 nether, 3 bamboo), set type of the same name out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-HANGING              BINARY-LONG.
 01 L-GATE                 BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SOUND L-HANGING L-GATE L-SET.
     MOVE 0 TO L-SOUND L-HANGING L-GATE L-SET
     MOVE SPACES TO WS-NAME
     IF L-INDEX >= 1 AND L-INDEX <= 13
         MOVE 5 TO L-SOUND
         MOVE 1 TO L-HANGING
         EVALUATE L-INDEX
             WHEN 1
                 MOVE "oak" TO WS-NAME
             WHEN 2
                 MOVE "spruce" TO WS-NAME
             WHEN 3
                 MOVE "birch" TO WS-NAME
             WHEN 4
                 MOVE "acacia" TO WS-NAME
             WHEN 5
                 MOVE "cherry" TO WS-NAME
                 MOVE 6 TO L-SOUND
                 MOVE 2 TO L-HANGING
                 MOVE 1 TO L-GATE
             WHEN 6
                 MOVE "jungle" TO WS-NAME
             WHEN 7
                 MOVE "dark_oak" TO WS-NAME
             WHEN 8
                 MOVE "pale_oak" TO WS-NAME
             WHEN 9
                 MOVE "poplar" TO WS-NAME
             WHEN 10
                 MOVE "crimson" TO WS-NAME
                 MOVE 7 TO L-SOUND
                 MOVE 3 TO L-HANGING
                 MOVE 2 TO L-GATE
             WHEN 11
                 MOVE "warped" TO WS-NAME
                 MOVE 7 TO L-SOUND
                 MOVE 3 TO L-HANGING
                 MOVE 2 TO L-GATE
             WHEN 12
                 MOVE "mangrove" TO WS-NAME
             WHEN 13
                 MOVE "bamboo" TO WS-NAME
                 MOVE 8 TO L-SOUND
                 MOVE 4 TO L-HANGING
                 MOVE 3 TO L-GATE
         END-EVALUATE
         CALL "RS3-SETTYPE-INDEX" USING WS-NAME L-SET
     END-IF
     GOBACK.
 END PROGRAM RS3-WOOD-SOUNDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WOOD-GATE-NAME.
*> USING wood type index, which (1 close, 2 open), gate sound event name out (section 2); spaces outside 1 to 13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SOUND               BINARY-LONG.
 01 WS-HANGING             BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-BASE                PIC X(32).
 01 WS-TAIL                PIC X(6).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-INDEX L-WHICH L-NAME.
     MOVE SPACES TO L-NAME
     CALL "RS3-WOOD-SOUNDS" USING L-INDEX WS-SOUND WS-HANGING WS-GATE WS-SET
     IF WS-SOUND > 0
         EVALUATE WS-GATE
             WHEN 0
                 MOVE "block.fence_gate" TO WS-BASE
             WHEN 1
                 MOVE "block.cherry_wood_fence_gate" TO WS-BASE
             WHEN 2
                 MOVE "block.nether_wood_fence_gate" TO WS-BASE
             WHEN 3
                 MOVE "block.bamboo_wood_fence_gate" TO WS-BASE
         END-EVALUATE
         MOVE ".open" TO WS-TAIL
         IF L-WHICH = 1
             MOVE ".close" TO WS-TAIL
         END-IF
         STRING FUNCTION TRIM(WS-BASE) DELIMITED BY SIZE FUNCTION TRIM(WS-TAIL) DELIMITED BY SIZE INTO L-NAME
     END-IF
     GOBACK.
 END PROGRAM RS3-WOOD-GATE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK-TYPES.
*> USING block name, family out (1 door, 2 trapdoor, 3 fence gate, 0 none), index out (section 2): a door or trapdoor takes the set type of the wood in its
*> name, iron or copper (every weathering and waxed copper block); a gate takes the wood type of its name (partly inferred in the document, Open question 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL                PIC X(40).
 01 WS-BASE                PIC X(40).
 01 WS-TMP                 PIC X(40).
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-BLEN                BINARY-LONG.
 01 WS-FAM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-FAMILY               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FAMILY L-INDEX.
     MOVE FUNCTION TRIM(L-NAME) TO WS-FULL
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-NAME))
     MOVE 0 TO WS-FAM L-FAMILY L-INDEX
     MOVE SPACES TO WS-BASE
     IF WS-LEN > 9
         COMPUTE WS-START = WS-LEN - 8
         IF WS-FULL(WS-START:9) = "_trapdoor"
             MOVE 2 TO WS-FAM
             COMPUTE WS-BLEN = WS-LEN - 9
         END-IF
     END-IF
     IF WS-FAM = 0 AND WS-LEN > 11
         COMPUTE WS-START = WS-LEN - 10
         IF WS-FULL(WS-START:11) = "_fence_gate"
             MOVE 3 TO WS-FAM
             COMPUTE WS-BLEN = WS-LEN - 11
         END-IF
     END-IF
     IF WS-FAM = 0 AND WS-LEN > 5
         COMPUTE WS-START = WS-LEN - 4
         IF WS-FULL(WS-START:5) = "_door"
             MOVE 1 TO WS-FAM
             COMPUTE WS-BLEN = WS-LEN - 5
         END-IF
     END-IF
     IF WS-FAM NOT = 0
         MOVE WS-FAM TO L-FAMILY
         MOVE WS-FULL(1:WS-BLEN) TO WS-BASE
         IF WS-FAM = 3
             CALL "RS3-WOOD-INDEX" USING WS-BASE L-INDEX
         ELSE
             IF WS-BASE(1:6) = "waxed_"
                 MOVE WS-BASE(7:34) TO WS-TMP
                 MOVE WS-TMP TO WS-BASE
             END-IF
             EVALUATE TRUE
                 WHEN WS-BASE(1:8) = "exposed_"
                     MOVE WS-BASE(9:32) TO WS-TMP
                     MOVE WS-TMP TO WS-BASE
                 WHEN WS-BASE(1:10) = "weathered_"
                     MOVE WS-BASE(11:30) TO WS-TMP
                     MOVE WS-TMP TO WS-BASE
                 WHEN WS-BASE(1:9) = "oxidized_"
                     MOVE WS-BASE(10:31) TO WS-TMP
                     MOVE WS-TMP TO WS-BASE
             END-EVALUATE
             CALL "RS3-SETTYPE-INDEX" USING WS-BASE L-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-BLOCK-TYPES.

*> ===== Section 2a: block rows and delays

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK-ID.
*> USING block name, block id out, state count out (section 2a); 0 and 0 for a name not in the table (the copper blocks are a range, RS3-COPPER-RANGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
 05 FILLER PIC X(24) VALUE "oak_door".
 05 FILLER PIC 9(4) VALUE 265.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "iron_door".
 05 FILLER PIC 9(4) VALUE 308.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "spruce_door".
 05 FILLER PIC 9(4) VALUE 702.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "birch_door".
 05 FILLER PIC 9(4) VALUE 703.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "jungle_door".
 05 FILLER PIC 9(4) VALUE 704.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "acacia_door".
 05 FILLER PIC 9(4) VALUE 705.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "cherry_door".
 05 FILLER PIC 9(4) VALUE 706.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "dark_oak_door".
 05 FILLER PIC 9(4) VALUE 707.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "pale_oak_door".
 05 FILLER PIC 9(4) VALUE 708.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "mangrove_door".
 05 FILLER PIC 9(4) VALUE 709.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "poplar_door".
 05 FILLER PIC 9(4) VALUE 710.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "bamboo_door".
 05 FILLER PIC 9(4) VALUE 711.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "crimson_door".
 05 FILLER PIC 9(4) VALUE 989.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "warped_door".
 05 FILLER PIC 9(4) VALUE 990.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "oak_trapdoor".
 05 FILLER PIC 9(4) VALUE 365.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "spruce_trapdoor".
 05 FILLER PIC 9(4) VALUE 366.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "birch_trapdoor".
 05 FILLER PIC 9(4) VALUE 367.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "jungle_trapdoor".
 05 FILLER PIC 9(4) VALUE 368.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "acacia_trapdoor".
 05 FILLER PIC 9(4) VALUE 369.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "cherry_trapdoor".
 05 FILLER PIC 9(4) VALUE 370.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "dark_oak_trapdoor".
 05 FILLER PIC 9(4) VALUE 371.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "pale_oak_trapdoor".
 05 FILLER PIC 9(4) VALUE 372.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "mangrove_trapdoor".
 05 FILLER PIC 9(4) VALUE 373.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "poplar_trapdoor".
 05 FILLER PIC 9(4) VALUE 374.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "bamboo_trapdoor".
 05 FILLER PIC 9(4) VALUE 375.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "iron_trapdoor".
 05 FILLER PIC 9(4) VALUE 580.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "crimson_trapdoor".
 05 FILLER PIC 9(4) VALUE 981.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "warped_trapdoor".
 05 FILLER PIC 9(4) VALUE 982.
 05 FILLER PIC 99 VALUE 64.
 05 FILLER PIC X(24) VALUE "oak_fence_gate".
 05 FILLER PIC 9(4) VALUE 419.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "spruce_fence_gate".
 05 FILLER PIC 9(4) VALUE 682.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "birch_fence_gate".
 05 FILLER PIC 9(4) VALUE 683.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "jungle_fence_gate".
 05 FILLER PIC 9(4) VALUE 684.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "acacia_fence_gate".
 05 FILLER PIC 9(4) VALUE 685.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "cherry_fence_gate".
 05 FILLER PIC 9(4) VALUE 686.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "dark_oak_fence_gate".
 05 FILLER PIC 9(4) VALUE 687.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "pale_oak_fence_gate".
 05 FILLER PIC 9(4) VALUE 688.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "mangrove_fence_gate".
 05 FILLER PIC 9(4) VALUE 689.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "poplar_fence_gate".
 05 FILLER PIC 9(4) VALUE 690.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "bamboo_fence_gate".
 05 FILLER PIC 9(4) VALUE 691.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "crimson_fence_gate".
 05 FILLER PIC 9(4) VALUE 983.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "warped_fence_gate".
 05 FILLER PIC 9(4) VALUE 984.
 05 FILLER PIC 99 VALUE 32.
 05 FILLER PIC X(24) VALUE "redstone_lamp".
 05 FILLER PIC 9(4) VALUE 445.
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(24) VALUE "tnt".
 05 FILLER PIC 9(4) VALUE 220.
 05 FILLER PIC 99 VALUE 2.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 43 TIMES.
       10 WS-RNAME         PIC X(24).
       10 WS-RID           PIC 9(4).
       10 WS-RSTATES       PIC 99.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-STATES.
     MOVE 0 TO L-ID L-STATES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 43
         IF FUNCTION TRIM(L-NAME) = FUNCTION TRIM(WS-RNAME(WS-I))
             MOVE WS-RID(WS-I) TO L-ID
             MOVE WS-RSTATES(WS-I) TO L-STATES
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-BLOCK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-COPPER-RANGE.
*> USING family (1 door, 2 trapdoor, 3 bulb), first id, last id, states out (section 2a); zeros for another family.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-FIRST L-LAST L-STATES.
     MOVE 0 TO L-FIRST L-LAST L-STATES
     EVALUATE L-FAMILY
         WHEN 1
             MOVE 1166 TO L-FIRST
             MOVE 1173 TO L-LAST
             MOVE 64 TO L-STATES
         WHEN 2
             MOVE 1174 TO L-FIRST
             MOVE 1181 TO L-LAST
             MOVE 64 TO L-STATES
         WHEN 3
             MOVE 1190 TO L-FIRST
             MOVE 1197 TO L-LAST
             MOVE 4 TO L-STATES
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-COPPER-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-FAMILY-COUNT.
*> USING family (1 door, 2 trapdoor, 3 fence gate, 4 lamp, 5 bulb, 6 TNT), blocks of the family out (section 2a counts).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-COUNT.
     MOVE 1 TO L-COUNT
     EVALUATE L-FAMILY
         WHEN 1 THRU 2
             MOVE 22 TO L-COUNT
         WHEN 3
             MOVE 13 TO L-COUNT
         WHEN 5
             MOVE 8 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-FAMILY-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-FAMILY-STATES.
*> USING family, states of each block out (section 2a, V1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-STATES.
     MOVE 2 TO L-STATES
     EVALUATE L-FAMILY
         WHEN 1 THRU 2
             MOVE 64 TO L-STATES
         WHEN 3
             MOVE 32 TO L-STATES
         WHEN 5
             MOVE 4 TO L-STATES
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-FAMILY-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DELAY-ROW.
*> USING family, scheduled delay out (-1 none), priority out (0 NORMAL), water fluid tick possible out (section 2a delay column).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FAMILY               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-PRIORITY             BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 PROCEDURE DIVISION USING L-FAMILY L-DELAY L-PRIORITY L-WATER.
     MOVE -1 TO L-DELAY
     MOVE 0 TO L-PRIORITY L-WATER
     IF L-FAMILY = 2
         MOVE 1 TO L-WATER
     END-IF
     IF L-FAMILY = 4
         MOVE 4 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS3-DELAY-ROW.

*> ===== Section 3: DoorBlock

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-DEFAULT.
*> USING facing, half, hinge, open, powered out (section 3.1): north, lower, left, closed, unpowered.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-HINGE                BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-HALF L-HINGE L-OPEN L-POWERED.
     MOVE 2 TO L-FACING
     MOVE 1 TO L-HALF
     MOVE 0 TO L-HINGE L-OPEN L-POWERED
     GOBACK.
 END PROGRAM RS3-DOOR-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DIR-TURN.
*> USING a horizontal direction, turn (1 clockwise, 2 counter-clockwise), the turned direction out (section 3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-TURN                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-TURN L-OUT.
     EVALUATE TRUE
         WHEN L-TURN = 1 AND L-DIR = 2
             MOVE 5 TO L-OUT
         WHEN L-TURN = 1 AND L-DIR = 5
             MOVE 3 TO L-OUT
         WHEN L-TURN = 1 AND L-DIR = 3
             MOVE 4 TO L-OUT
         WHEN L-TURN = 1
             MOVE 2 TO L-OUT
         WHEN L-DIR = 2
             MOVE 4 TO L-OUT
         WHEN L-DIR = 4
             MOVE 3 TO L-OUT
         WHEN L-DIR = 3
             MOVE 5 TO L-OUT
         WHEN OTHER
             MOVE 2 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DIR-TURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-ROTATE.
*> USING facing, rotation (0 none, 1 clockwise 90, 2 180, 3 counter-clockwise 90), facing out (section 3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CW                  BINARY-LONG VALUE 1.
 01 WS-CCW                 BINARY-LONG VALUE 2.
 01 WS-TMP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-ROT L-OUT.
     MOVE L-FACING TO L-OUT
     IF L-ROT = 1
         CALL "RS3-DIR-TURN" USING L-FACING WS-CW L-OUT
     END-IF
     IF L-ROT = 2
         CALL "RS3-DIR-TURN" USING L-FACING WS-CW WS-TMP
         CALL "RS3-DIR-TURN" USING WS-TMP WS-CW L-OUT
     END-IF
     IF L-ROT = 3
         CALL "RS3-DIR-TURN" USING L-FACING WS-CCW L-OUT
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-MIRROR.
*> USING facing, hinge, mirror (0 none, 1 left-right, 2 front-back), facing out, hinge out (section 3.1): the mirror turns facing, then hinge cycles.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-HINGE                BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-OF                   BINARY-LONG.
 01 L-OH                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-HINGE L-MIRROR L-OF L-OH.
     MOVE L-FACING TO L-OF
     MOVE L-HINGE TO L-OH
     IF L-MIRROR NOT = 0
         COMPUTE L-OH = 1 - L-HINGE
     END-IF
     IF L-MIRROR = 1 AND (L-FACING = 2 OR L-FACING = 3)
         COMPUTE L-OF = 5 - L-FACING
     END-IF
     IF L-MIRROR = 2 AND (L-FACING = 4 OR L-FACING = 5)
         COMPUTE L-OF = 9 - L-FACING
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-SEED-Y.
*> USING half (0 upper, 1 lower), y, the y of the model-offset seed out (section 3.1): the lower half's y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SEED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-Y L-SEED.
     MOVE L-Y TO L-SEED
     IF L-HALF = 0
         COMPUTE L-SEED = L-Y - 1
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-SEED-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-IS-WOODEN-DOOR.
*> USING set type index, isWoodenDoor out (section 3.1): the set type's canOpenByHand.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WIND                BINARY-LONG.
 01 WS-ARROWS              BINARY-LONG.
 01 WS-SENS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-RESULT.
     CALL "RS3-SETTYPE-FLAGS" USING L-INDEX L-RESULT WS-WIND WS-ARROWS WS-SENS
     GOBACK.
 END PROGRAM RS3-IS-WOODEN-DOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-SHAPE-KEY.
*> USING facing, open, hinge, shape key out (section 3.2): the facing when closed; when open turned counter-clockwise for hinge right, clockwise for left.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CW                  BINARY-LONG VALUE 1.
 01 WS-CCW                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-HINGE                BINARY-LONG.
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-OPEN L-HINGE L-KEY.
     MOVE L-FACING TO L-KEY
     IF L-OPEN = 1 AND L-HINGE = 1
         CALL "RS3-DIR-TURN" USING L-FACING WS-CCW L-KEY
     END-IF
     IF L-OPEN = 1 AND L-HINGE = 0
         CALL "RS3-DIR-TURN" USING L-FACING WS-CW L-KEY
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-SHAPE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-SLAB.
*> USING key, min x, max x, min z, max z out in pixels (section 3.2): boxZ(16, 13, 16) on the side opposite to the key.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-MINX                 BINARY-LONG.
 01 L-MAXX                 BINARY-LONG.
 01 L-MINZ                 BINARY-LONG.
 01 L-MAXZ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MINX L-MAXX L-MINZ L-MAXZ.
     MOVE 0 TO L-MINX L-MINZ
     MOVE 16 TO L-MAXX L-MAXZ
     EVALUATE L-KEY
         WHEN 2
             MOVE 13 TO L-MINZ
         WHEN 3
             MOVE 3 TO L-MAXZ
             MOVE 0 TO L-MINZ
         WHEN 5
             MOVE 3 TO L-MAXX
         WHEN 4
             MOVE 13 TO L-MINX
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DOOR-SLAB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-PATHFIND.
*> USING type (1 land, 2 air, 3 water), open, isPathfindable out (section 3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OPEN L-RESULT.
     MOVE L-OPEN TO L-RESULT
     IF L-TYPE = 3
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-PATHFIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-PLACE-CHECK.
*> USING y, maximum y, the cell above can be replaced, placement allowed out (section 3.3 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-MAXY L-REPLACEABLE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-Y < L-MAXY AND L-REPLACEABLE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-PLACE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-PLACE-POWER.
*> USING hasNeighborSignal at the cell, at the cell above, powered out, open out (section 3.3 steps 2 and 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HERE                 BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HERE L-ABOVE L-POWERED L-OPEN.
     MOVE 0 TO L-POWERED
     IF L-HERE = 1 OR L-ABOVE = 1
         MOVE 1 TO L-POWERED
     END-IF
     MOVE L-POWERED TO L-OPEN
     GOBACK.
 END PROGRAM RS3-DOOR-PLACE-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-UPPER.
*> USING the lower half, half of the upper state out (0 upper), flags out (3, setBlockAndUpdate) (section 3.3 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOWER                BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-LOWER L-HALF L-FLAGS.
     COMPUTE L-HALF = L-LOWER - 1
     MOVE 3 TO L-FLAGS
     GOBACK.
 END PROGRAM RS3-DOOR-UPPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-SURVIVE.
*> USING half (0 upper, 1 lower), sturdy UP face below, the same door block below, canSurvive out (section 3.3 step 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HALF                 BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-HALF L-STURDY L-SAME L-RESULT.
     MOVE L-SAME TO L-RESULT
     IF L-HALF = 1
         MOVE L-STURDY TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-ITEM-WATER.
*> USING isWaterAt the cell above, water written out (else air), flags out (27 = 1 + 2 + 8 + 16) (section 3.3 item).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER-AT             BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER-AT L-WATER L-FLAGS.
     MOVE L-WATER-AT TO L-WATER
     MOVE 27 TO L-FLAGS
     GOBACK.
 END PROGRAM RS3-DOOR-ITEM-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-HINGE.
*> USING the placer's direction, A0 full, A1 full, B0 full, B1 full (full-block collision shape at the counter-clockwise and clockwise cells and above),
*> left door at A0, right door at B0, click dx, click dz in thousandths, hinge out (0 left, 1 right) (section 3.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SCORE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-A0                   BINARY-LONG.
 01 L-A1                   BINARY-LONG.
 01 L-B0                   BINARY-LONG.
 01 L-B1                   BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-HINGE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-A0 L-A1 L-B0 L-B1 L-LEFT L-RIGHT L-DX L-DZ L-HINGE.
     COMPUTE WS-SCORE = L-B0 + L-B1 - L-A0 - L-A1
     EVALUATE TRUE
         WHEN (L-LEFT = 1 AND L-RIGHT = 0) OR WS-SCORE > 0
             MOVE 1 TO L-HINGE
         WHEN (L-RIGHT = 1 AND L-LEFT = 0) OR WS-SCORE < 0
             MOVE 0 TO L-HINGE
         WHEN OTHER
             MOVE 0 TO L-HINGE
             IF (L-DIR = 4 AND L-DZ < 500) OR (L-DIR = 5 AND L-DZ > 500)
                 MOVE 1 TO L-HINGE
             END-IF
             IF (L-DIR = 2 AND L-DX > 500) OR (L-DIR = 3 AND L-DX < 500)
                 MOVE 1 TO L-HINGE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DOOR-HINGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-POWER.
*> USING hasNeighborSignal at the cell, at the other half's cell, power out (section 3.5 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HERE                 BINARY-LONG.
 01 L-OTHER                BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-HERE L-OTHER L-POWER.
     MOVE 0 TO L-POWER
     IF L-HERE = 1 OR L-OTHER = 1
         MOVE 1 TO L-POWER
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-NEIGHBOR.
*> USING power, powered, open, the update comes from the same block, then write out, sound out, event out, powered out, open out
*> (section 3.5 steps 2 to 5): flags 2 for the write.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-NEW-POWERED          BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-POWERED L-OPEN L-SAME L-WRITE L-SOUND L-EVENT L-NEW-POWERED L-NEW-OPEN.
     MOVE 0 TO L-WRITE L-SOUND L-EVENT
     MOVE L-POWERED TO L-NEW-POWERED
     MOVE L-OPEN TO L-NEW-OPEN
     IF L-SAME = 0 AND L-POWER NOT = L-POWERED
         MOVE 1 TO L-WRITE
         IF L-POWER NOT = L-OPEN
             MOVE 2 TO L-SOUND L-EVENT
             IF L-POWER = 1
                 MOVE 1 TO L-SOUND L-EVENT
             END-IF
         END-IF
         MOVE L-POWER TO L-NEW-POWERED L-NEW-OPEN
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-HALF-UPDATE.
*> USING lower half, direction of the changed neighbour (data value), the neighbour is a door, its half differs, this half can survive, result out
*> (section 3.5 updateShape): 0 default shape update, 1 the neighbour's state with this half, 2 air.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOWER                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-DIFF                 BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LOWER L-DIR L-DOOR L-DIFF L-SURVIVES L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-LOWER = 1 AND L-DIR = 1
             MOVE 2 TO L-RESULT
             IF L-DOOR = 1 AND L-DIFF = 1
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN L-LOWER = 0 AND L-DIR = 0
             MOVE 2 TO L-RESULT
             IF L-DOOR = 1 AND L-DIFF = 1
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN L-LOWER = 1 AND L-DIR = 0 AND L-SURVIVES = 0
             MOVE 2 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DOOR-HALF-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-USE.
*> USING canOpenByHand, open, result out (0 PASS, 1 SUCCESS), new open out, flags out (10), sound out, event out (section 3.6 useWithoutItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAND                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAND L-OPEN L-RESULT L-NEW-OPEN L-FLAGS L-SOUND L-EVENT.
     MOVE 0 TO L-RESULT L-FLAGS L-SOUND L-EVENT
     MOVE L-OPEN TO L-NEW-OPEN
     IF L-HAND = 1
         MOVE 1 TO L-RESULT
         MOVE 10 TO L-FLAGS
         COMPUTE L-NEW-OPEN = 1 - L-OPEN
         CALL "RS3-GAME-EVENT" USING L-NEW-OPEN L-EVENT
         MOVE L-EVENT TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-SET-OPEN.
*> USING the state is this block, its open, the wanted open, writes out (section 3.6 setOpen): at flags 10.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-WANTED               BINARY-LONG.
 01 L-WRITES               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-CURRENT L-WANTED L-WRITES.
     MOVE 0 TO L-WRITES
     IF L-BLOCK = 1 AND L-CURRENT NOT = L-WANTED
         MOVE 1 TO L-WRITES
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-SET-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-EXPLOSION.
*> USING lower half, canOpenByWindCharge, powered, toggles out (section 3.6 onExplosionHit): only the lower half, not powered.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOWER                BINARY-LONG.
 01 L-WIND                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-TOGGLES              BINARY-LONG.
 PROCEDURE DIVISION USING L-LOWER L-WIND L-POWERED L-TOGGLES.
     MOVE 0 TO L-TOGGLES
     IF L-LOWER = 1 AND L-WIND = 1 AND L-POWERED = 0
         MOVE 1 TO L-TOGGLES
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-DESTROY.
*> USING server, the player prevents drops or has no correct tool, preventDropFromBottomPart out (section 3.6 playerWillDestroy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-PREVENTS             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-PREVENTS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SERVER = 1 AND L-PREVENTS = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DOOR-RANDOM-TICK.
*> USING weathering variant, lower half, random tick acts out (section 3.6): the lower half of a weathering door only.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHERING           BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHERING L-LOWER L-TICKS.
     MOVE 0 TO L-TICKS
     IF L-WEATHERING = 1 AND L-LOWER = 1
         MOVE 1 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM RS3-DOOR-RANDOM-TICK.

*> ===== Section 4: TrapDoorBlock

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-DEFAULT.
*> USING facing, open, half, powered, waterlogged out (section 4.1): north, closed, bottom (1), unpowered, dry.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-OPEN L-HALF L-POWERED L-WATERLOGGED.
     MOVE 2 TO L-FACING
     MOVE 0 TO L-OPEN L-POWERED L-WATERLOGGED
     MOVE 1 TO L-HALF
     GOBACK.
 END PROGRAM RS3-TRAP-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-SHAPE-KEY.
*> USING facing, open, half (0 top, 1 bottom), shape key out (section 4.1): open uses facing; closed DOWN (0) for top, UP (1) for bottom.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-OPEN L-HALF L-KEY.
     MOVE L-FACING TO L-KEY
     IF L-OPEN = 0
         MOVE L-HALF TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM RS3-TRAP-SHAPE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-SLAB.
*> USING key, axis out (0 x, 1 y, 2 z), min and max in pixels out (section 4.1): boxZ(16, 13, 16) rotated to six keys.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-AXIS L-MIN L-MAX.
     MOVE 0 TO L-AXIS L-MIN
     MOVE 3 TO L-MAX
     EVALUATE L-KEY
         WHEN 2
             MOVE 2 TO L-AXIS
             MOVE 13 TO L-MIN
             MOVE 16 TO L-MAX
         WHEN 3
             MOVE 2 TO L-AXIS
         WHEN 4
             MOVE 13 TO L-MIN
             MOVE 16 TO L-MAX
         WHEN 0
             MOVE 1 TO L-AXIS
             MOVE 13 TO L-MIN
             MOVE 16 TO L-MAX
         WHEN 1
             MOVE 1 TO L-AXIS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TRAP-SLAB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-PATHFIND.
*> USING type (1 land, 2 water, 3 air), open, waterlogged, isPathfindable out (section 4.1): LAND open, WATER waterlogged, AIR open.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OPEN L-WATERLOGGED L-RESULT.
     MOVE L-OPEN TO L-RESULT
     IF L-TYPE = 2
         MOVE L-WATERLOGGED TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-TRAP-PATHFIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-PLACE.
*> USING clicked face (data value), replacing the clicked-on block, click y in thousandths, the placer's horizontal direction, signal at the clicked
*> position, the fluid is water, then facing, open, half, powered, waterlogged out (section 4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACE                 BINARY-LONG.
 01 L-REPLACING            BINARY-LONG.
 01 L-CLICK-Y              BINARY-LONG.
 01 L-PLACER               BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE L-REPLACING L-CLICK-Y L-PLACER L-SIGNAL L-WATER L-FACING L-OPEN L-HALF L-POWERED L-WATERLOGGED.
     IF L-REPLACING = 0 AND L-FACE >= 2
         MOVE L-FACE TO L-FACING
         MOVE 1 TO L-HALF
         IF L-CLICK-Y > 500
             MOVE 0 TO L-HALF
         END-IF
     ELSE
         COMPUTE L-FACING = L-PLACER + 1 - 2 * FUNCTION MOD(L-PLACER, 2)
         MOVE 0 TO L-HALF
         IF L-FACE = 1
             MOVE 1 TO L-HALF
         END-IF
     END-IF
     MOVE L-SIGNAL TO L-OPEN L-POWERED
     MOVE L-WATER TO L-WATERLOGGED
     GOBACK.
 END PROGRAM RS3-TRAP-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-USE.
*> USING canOpenByHand, result out (0 PASS, 1 SUCCESS) (section 4.3 useWithoutItem).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAND                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAND L-RESULT.
     MOVE L-HAND TO L-RESULT
     GOBACK.
 END PROGRAM RS3-TRAP-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-TOGGLE.
*> USING open, waterlogged, new open out, flags out (2), water tick scheduled out, sound out, event out (section 4.3 toggle).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPEN                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-WATER-TICK           BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-OPEN L-WATERLOGGED L-NEW-OPEN L-FLAGS L-WATER-TICK L-SOUND L-EVENT.
     COMPUTE L-NEW-OPEN = 1 - L-OPEN
     MOVE 2 TO L-FLAGS
     MOVE L-WATERLOGGED TO L-WATER-TICK
     CALL "RS3-GAME-EVENT" USING L-NEW-OPEN L-EVENT
     MOVE L-EVENT TO L-SOUND
     GOBACK.
 END PROGRAM RS3-TRAP-TOGGLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-NEIGHBOR.
*> USING server, power, powered, open, waterlogged, then write out, open out, powered out, sound out, event out, water tick out (section 4.3):
*> power at this cell only; when open differs the sound and event follow, else open is not changed again.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-NEW-POWERED          BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-WATER-TICK           BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-POWER L-POWERED L-OPEN L-WATERLOGGED L-WRITE L-NEW-OPEN L-NEW-POWERED L-SOUND L-EVENT L-WATER-TICK.
     MOVE 0 TO L-WRITE L-SOUND L-EVENT L-WATER-TICK
     MOVE L-OPEN TO L-NEW-OPEN
     MOVE L-POWERED TO L-NEW-POWERED
     IF L-SERVER = 1 AND L-POWER NOT = L-POWERED
         MOVE 1 TO L-WRITE
         MOVE L-POWER TO L-NEW-POWERED
         MOVE L-WATERLOGGED TO L-WATER-TICK
         IF L-OPEN NOT = L-POWER
             MOVE L-POWER TO L-NEW-OPEN
             CALL "RS3-GAME-EVENT" USING L-NEW-OPEN L-EVENT
             MOVE L-EVENT TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-TRAP-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-EXPLOSION.
*> USING the explosion can trigger blocks, canOpenByWindCharge, powered, toggles out (section 4.3 onExplosionHit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGERS             BINARY-LONG.
 01 L-WIND                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-TOGGLES              BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGERS L-WIND L-POWERED L-TOGGLES.
     MOVE 0 TO L-TOGGLES
     IF L-TRIGGERS = 1 AND L-WIND = 1 AND L-POWERED = 0
         MOVE 1 TO L-TOGGLES
     END-IF
     GOBACK.
 END PROGRAM RS3-TRAP-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-UPDATE-SHAPE.
*> USING waterlogged, water tick scheduled out (section 4.3 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-TICK.
     MOVE L-WATERLOGGED TO L-TICK
     GOBACK.
 END PROGRAM RS3-TRAP-UPDATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAP-RANDOM-TICK.
*> USING weathering variant, random tick acts out (section 4.3): both halves, no condition, weathering variant only.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHERING           BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHERING L-TICKS.
     MOVE L-WEATHERING TO L-TICKS
     GOBACK.
 END PROGRAM RS3-TRAP-RANDOM-TICK.

*> ===== Section 5: FenceGateBlock

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-DEFAULT.
*> USING facing, open, powered, in_wall, state count out (section 5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-IN-WALL              BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-OPEN L-POWERED L-IN-WALL L-STATES.
     MOVE 2 TO L-FACING
     MOVE 0 TO L-OPEN L-POWERED L-IN-WALL
     MOVE 32 TO L-STATES
     GOBACK.
 END PROGRAM RS3-GATE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-CONNECTS.
*> USING facing, direction, connectsToDirection out (section 5.1): the axis of the clockwise direction of facing equals the axis of the direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-DIR L-RESULT.
     MOVE 0 TO L-RESULT
     IF (L-FACING = 2 OR L-FACING = 3) AND (L-DIR = 4 OR L-DIR = 5)
         MOVE 1 TO L-RESULT
     END-IF
     IF (L-FACING = 4 OR L-FACING = 5) AND (L-DIR = 2 OR L-DIR = 3)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-CONNECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-SHAPE.
*> USING in_wall, open, outline top, collision top, support min, support max, occlusion drop out in pixels (section 5.1): an open gate has no collision and
*> no support shape (0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-WALL              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-OUTLINE              BINARY-LONG.
 01 L-COLLISION            BINARY-LONG.
 01 L-SUPPORT-MIN          BINARY-LONG.
 01 L-SUPPORT-MAX          BINARY-LONG.
 01 L-OCCLUSION            BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-WALL L-OPEN L-OUTLINE L-COLLISION L-SUPPORT-MIN L-SUPPORT-MAX L-OCCLUSION.
     MOVE 16 TO L-OUTLINE
     MOVE 0 TO L-OCCLUSION L-COLLISION L-SUPPORT-MIN L-SUPPORT-MAX
     IF L-IN-WALL = 1
         MOVE 13 TO L-OUTLINE
         MOVE 3 TO L-OCCLUSION
     END-IF
     IF L-OPEN = 0
         MOVE 24 TO L-COLLISION L-SUPPORT-MAX
         MOVE 5 TO L-SUPPORT-MIN
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-PATHFIND.
*> USING type (1 land, 2 air, 3 water), open, isPathfindable out (section 5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-OPEN L-RESULT.
     MOVE L-OPEN TO L-RESULT
     IF L-TYPE = 3
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-PATHFIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-IN-WALL.
*> USING facing, wall at west, east, north, south, in_wall out (section 5.2 step 3): the axis Z looks west and east, the axis X north and south.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-WEST                 BINARY-LONG.
 01 L-EAST                 BINARY-LONG.
 01 L-NORTH                BINARY-LONG.
 01 L-SOUTH                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-WEST L-EAST L-NORTH L-SOUTH L-RESULT.
     MOVE 0 TO L-RESULT
     IF (L-FACING = 2 OR L-FACING = 3) AND (L-WEST = 1 OR L-EAST = 1)
         MOVE 1 TO L-RESULT
     END-IF
     IF (L-FACING = 4 OR L-FACING = 5) AND (L-NORTH = 1 OR L-SOUTH = 1)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-IN-WALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-PLACE.
*> USING the signal at the clicked position, the placer's horizontal direction, powered, open, facing out (section 5.2 steps 1 and 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-DIR L-POWERED L-OPEN L-FACING.
     MOVE L-SIGNAL TO L-POWERED L-OPEN
     MOVE L-DIR TO L-FACING
     GOBACK.
 END PROGRAM RS3-GATE-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-UPDATE-SHAPE.
*> USING facing, direction of the changed neighbour, the changed neighbour is a wall, the block on the opposite side is a wall, old in_wall, then handled out
*> (1 a side neighbour, 0 the default shape update), in_wall out (section 5.2 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 01 L-OPPOSITE             BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 01 L-IN-WALL              BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-DIR L-CHANGED L-OPPOSITE L-OLD L-HANDLED L-IN-WALL.
     MOVE 0 TO L-HANDLED
     MOVE L-OLD TO L-IN-WALL
     IF ((L-FACING = 2 OR L-FACING = 3) AND (L-DIR = 4 OR L-DIR = 5)) OR ((L-FACING = 4 OR L-FACING = 5) AND (L-DIR = 2 OR L-DIR = 3))
         MOVE 1 TO L-HANDLED
         MOVE 0 TO L-IN-WALL
         IF L-CHANGED = 1 OR L-OPPOSITE = 1
             MOVE 1 TO L-IN-WALL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-UPDATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-USE.
*> USING open, facing, the player's direction, new open out, facing out, sound out, event out, flags out (10) (section 5.3 useWithoutItem): an open gate
*> closes; a closed gate turns to the player's direction when its facing is the opposite of it, then opens. No canOpenByHand test.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OPEN                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-NEW-FACING           BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-OPEN L-FACING L-PLAYER L-NEW-OPEN L-NEW-FACING L-SOUND L-EVENT L-FLAGS.
     MOVE 10 TO L-FLAGS
     MOVE L-FACING TO L-NEW-FACING
     COMPUTE L-NEW-OPEN = 1 - L-OPEN
     IF L-OPEN = 0 AND L-FACING = L-PLAYER + 1 - 2 * FUNCTION MOD(L-PLAYER, 2)
         MOVE L-PLAYER TO L-NEW-FACING
     END-IF
     CALL "RS3-GAME-EVENT" USING L-NEW-OPEN L-EVENT
     MOVE L-EVENT TO L-SOUND
     GOBACK.
 END PROGRAM RS3-GATE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-NEIGHBOR.
*> USING server, power, powered, open, then write out, powered out, open out, sound out, event out (section 5.3 neighborChanged): flags 2; the sound and
*> event when the old open differs from the power.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-NEW-POWERED          BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-POWER L-POWERED L-OPEN L-WRITE L-NEW-POWERED L-NEW-OPEN L-SOUND L-EVENT.
     MOVE 0 TO L-WRITE L-SOUND L-EVENT
     MOVE L-POWERED TO L-NEW-POWERED
     MOVE L-OPEN TO L-NEW-OPEN
     IF L-SERVER = 1 AND L-POWER NOT = L-POWERED
         MOVE 1 TO L-WRITE
         MOVE L-POWER TO L-NEW-POWERED L-NEW-OPEN
         IF L-OPEN NOT = L-POWER
             CALL "RS3-GAME-EVENT" USING L-POWER L-EVENT
             MOVE L-EVENT TO L-SOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-GATE-EXPLOSION.
*> USING the explosion can trigger blocks, powered, open, toggles out, new open out, flags out (3), sound out, event out (section 5.3 onExplosionHit):
*> the close sound if it was open else the open sound; the wind-charge flag is not consulted.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRIGGERS             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-TOGGLES              BINARY-LONG.
 01 L-NEW-OPEN             BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRIGGERS L-POWERED L-OPEN L-TOGGLES L-NEW-OPEN L-FLAGS L-SOUND L-EVENT.
     MOVE 0 TO L-TOGGLES L-FLAGS L-SOUND L-EVENT
     MOVE L-OPEN TO L-NEW-OPEN
     IF L-TRIGGERS = 1 AND L-POWERED = 0
         MOVE 1 TO L-TOGGLES
         MOVE 3 TO L-FLAGS
         COMPUTE L-NEW-OPEN = 1 - L-OPEN
         CALL "RS3-GAME-EVENT" USING L-NEW-OPEN L-EVENT
         MOVE L-EVENT TO L-SOUND
     END-IF
     GOBACK.
 END PROGRAM RS3-GATE-EXPLOSION.

*> ===== Section 6: RedstoneLampBlock

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LAMP-LIGHT.
*> USING lit, light level out (section 6): 15 when lit.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-LIGHT.
     COMPUTE L-LIGHT = 15 * L-LIT
     GOBACK.
 END PROGRAM RS3-LAMP-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LAMP-PLACE.
*> USING hasNeighborSignal at the clicked position, lit out (section 6 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-LIT.
     MOVE L-SIGNAL TO L-LIT
     GOBACK.
 END PROGRAM RS3-LAMP-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LAMP-NEIGHBOR.
*> USING server, lit, signal, action out (0 nothing, 1 schedule the turn-off tick, 2 turn on at flags 2), lit now out, tick delay out (section 6 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-LIT-NOW              BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-LIT L-SIGNAL L-ACTION L-LIT-NOW L-DELAY.
     MOVE 0 TO L-ACTION L-DELAY
     MOVE L-LIT TO L-LIT-NOW
     IF L-SERVER = 1 AND L-LIT NOT = L-SIGNAL
         IF L-LIT = 1
             MOVE 1 TO L-ACTION
             MOVE 4 TO L-DELAY
         ELSE
             MOVE 2 TO L-ACTION
             MOVE 1 TO L-LIT-NOW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-LAMP-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LAMP-TICK.
*> USING lit, signal, lit after out, write out (section 6 step 3): lit without a signal turns off at flags 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-LIT-AFTER            BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-SIGNAL L-LIT-AFTER L-WRITE.
     MOVE L-LIT TO L-LIT-AFTER
     MOVE 0 TO L-WRITE
     IF L-LIT = 1 AND L-SIGNAL = 0
         MOVE 0 TO L-LIT-AFTER
         MOVE 1 TO L-WRITE
     END-IF
     GOBACK.
 END PROGRAM RS3-LAMP-TICK.

*> ===== Section 7: copper bulbs

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-LIGHT.
*> USING weather state (0 unaffected to 3 oxidized), lit, light out (section 7.1): 15, 12, 8, 4 when lit, else 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEATHER              BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-WEATHER L-LIT L-LIGHT.
     MOVE 0 TO L-LIGHT
     IF L-LIT = 1
         EVALUATE L-WEATHER
             WHEN 0
                 MOVE 15 TO L-LIGHT
             WHEN 1
                 MOVE 12 TO L-LIGHT
             WHEN 2
                 MOVE 8 TO L-LIGHT
             WHEN 3
                 MOVE 4 TO L-LIGHT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS3-BULB-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-DEFAULT.
*> USING lit, powered, state count, conductor kind out (1 never) (section 7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-POWERED L-STATES L-CONDUCTOR.
     MOVE 0 TO L-LIT L-POWERED
     MOVE 4 TO L-STATES
     MOVE 1 TO L-CONDUCTOR
     GOBACK.
 END PROGRAM RS3-BULB-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-ON-PLACE.
*> USING the old state is the same block, server level, checkAndFlip runs out (section 7.2 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-SERVER L-RUNS.
     MOVE 0 TO L-RUNS
     IF L-SAME = 0 AND L-SERVER = 1
         MOVE 1 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM RS3-BULB-ON-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-NEIGHBOR.
*> USING server level, checkAndFlip runs out (section 7.2 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-RUNS.
     MOVE L-SERVER TO L-RUNS
     GOBACK.
 END PROGRAM RS3-BULB-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-FLIP.
*> USING lit, powered, signal, write out (flags 3), lit out, powered out, sound out (0 none, 1 turn_on, 2 turn_off) (section 7.2 step 3): a rising edge
*> toggles lit; a falling edge only clears powered.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-NEW-LIT              BINARY-LONG.
 01 L-NEW-POWERED          BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-POWERED L-SIGNAL L-WRITE L-NEW-LIT L-NEW-POWERED L-SOUND.
     MOVE 0 TO L-WRITE L-SOUND
     MOVE L-LIT TO L-NEW-LIT
     MOVE L-POWERED TO L-NEW-POWERED
     IF L-SIGNAL NOT = L-POWERED
         MOVE 1 TO L-WRITE
         MOVE L-SIGNAL TO L-NEW-POWERED
         IF L-POWERED = 0
             COMPUTE L-NEW-LIT = 1 - L-LIT
             MOVE 2 TO L-SOUND
             IF L-NEW-LIT = 1
                 MOVE 1 TO L-SOUND
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-BULB-FLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-ANALOG.
*> USING lit, weather state, comparator direction, signal out (section 7.3): 15 when lit, independent of the weather and the direction.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIT                  BINARY-LONG.
 01 L-WEATHER              BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-LIT L-WEATHER L-DIR L-SIGNAL.
     COMPUTE L-SIGNAL = 15 * L-LIT
     GOBACK.
 END PROGRAM RS3-BULB-ANALOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-VARIANT.
*> USING block name, weather state out (0 to 3), waxed out (section 7.4): the eight blocks; 0 and 0 for another name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FULL                PIC X(40).
 01 WS-BASE                PIC X(40).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-WEATHER              BINARY-LONG.
 01 L-WAXED                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-WEATHER L-WAXED.
     MOVE 0 TO L-WEATHER L-WAXED
     MOVE FUNCTION TRIM(L-NAME) TO WS-FULL
     IF WS-FULL(1:6) = "waxed_"
         MOVE 1 TO L-WAXED
         MOVE WS-FULL(7:34) TO WS-BASE
     ELSE
         MOVE WS-FULL TO WS-BASE
     END-IF
     EVALUATE FUNCTION TRIM(WS-BASE)
         WHEN "copper_bulb"
             MOVE 0 TO L-WEATHER
         WHEN "exposed_copper_bulb"
             MOVE 1 TO L-WEATHER
         WHEN "weathered_copper_bulb"
             MOVE 2 TO L-WEATHER
         WHEN "oxidized_copper_bulb"
             MOVE 3 TO L-WEATHER
         WHEN OTHER
             MOVE 0 TO L-WAXED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BULB-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BULB-RANDOM-TICK.
*> USING waxed, random tick acts out, a weathering step keeps lit and powered out (section 7.1): only the weathering class has the random tick.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WAXED                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-KEEPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WAXED L-TICKS L-KEEPS.
     COMPUTE L-TICKS = 1 - L-WAXED
     MOVE 1 TO L-KEEPS
     GOBACK.
 END PROGRAM RS3-BULB-RANDOM-TICK.

*> ===== Section 8: TNT

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-STATE.
*> USING unstable, state count, ignite odds, burn odds out (section 8.1, fire table 15 and 100).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UNSTABLE             BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-IGNITE               BINARY-LONG.
 01 L-BURN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-UNSTABLE L-STATES L-IGNITE L-BURN.
     MOVE 0 TO L-UNSTABLE
     MOVE 2 TO L-STATES
     MOVE 15 TO L-IGNITE
     MOVE 100 TO L-BURN
     GOBACK.
 END PROGRAM RS3-TNT-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-PRIME.
*> USING server level, tnt_explodes, the igniter is a player, adventure mode, canBreakBlockInAdventureMode, a primed TNT created out (section 8.2 steps 1 to 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-EXPLODES             BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-ADVENTURE            BINARY-LONG.
 01 L-CAN-BREAK            BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-EXPLODES L-PLAYER L-ADVENTURE L-CAN-BREAK L-CREATED.
     MOVE 0 TO L-CREATED
     EVALUATE TRUE
         WHEN L-SERVER = 0
             MOVE 0 TO L-CREATED
         WHEN L-EXPLODES = 0
             MOVE 0 TO L-CREATED
         WHEN L-PLAYER = 1 AND L-ADVENTURE = 1 AND L-CAN-BREAK = 0
             MOVE 0 TO L-CREATED
         WHEN OTHER
             MOVE 1 TO L-CREATED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TNT-PRIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-PRIME-RESULT.
*> USING created, sound out (1 entity.tnt.primed at volume 1.0 and pitch 1.0), event out (3 PRIME_FUSE), spawn x, y, z out in thousandths of a block above
*> the cell origin: (0.5, 0, 0.5) (section 8.2 steps 4 to 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CREATED              BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-CREATED L-SOUND L-EVENT L-X L-Y L-Z.
     MOVE 0 TO L-SOUND L-EVENT L-X L-Y L-Z
     IF L-CREATED = 1
         MOVE 1 TO L-SOUND
         MOVE 3 TO L-EVENT
         MOVE 500 TO L-X L-Z
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-PRIME-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-VELOCITY.
*> USING the nextDouble draw u, velocity x, y, z out in tenths of nanoblocks per tick (section 8.5): a = u * 6.2831854820251465, (-sin a * 0.02,
*> 0.20000000298023224, -cos a * 0.02).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   PIC S9(3)V9(18).
 01 WS-LIFT                PIC 9V9(17) VALUE 0.20000000298023224.
 LINKAGE SECTION.
 01 L-U                    FLOAT-LONG.
 01 L-VX                   BINARY-LONG.
 01 L-VY                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-U L-VX L-VY L-VZ.
     COMPUTE WS-A = L-U * 6.2831854820251465
     COMPUTE L-VX ROUNDED = 0 - FUNCTION SIN(WS-A) * 0.02 * 10000000000
     COMPUTE L-VY ROUNDED = WS-LIFT * 10000000000
     COMPUTE L-VZ ROUNDED = 0 - FUNCTION COS(WS-A) * 0.02 * 10000000000
     GOBACK.
 END PROGRAM RS3-TNT-VELOCITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-SHORT-FUSE.
*> USING the fuse, the nextInt draw, the draw bound out, the new fuse out (section 8.3 wasExploded): nextInt(max(1, fuse / 4)) + fuse / 8, integer divisions.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QUARTER             BINARY-LONG.
 01 WS-EIGHTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-FUSE                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FUSE L-DRAW L-BOUND L-NEW.
     DIVIDE L-FUSE BY 4 GIVING WS-QUARTER
     DIVIDE L-FUSE BY 8 GIVING WS-EIGHTH
     MOVE WS-QUARTER TO L-BOUND
     IF L-BOUND < 1
         MOVE 1 TO L-BOUND
     END-IF
     COMPUTE L-NEW = L-DRAW + WS-EIGHTH
     GOBACK.
 END PROGRAM RS3-TNT-SHORT-FUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-PLACE.
*> USING the old block is TNT, signal, prime succeeded, prime called out, remove out (flags 3) (section 8.3 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-PRIMED               BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD L-SIGNAL L-PRIMED L-CALLED L-REMOVE.
     MOVE 0 TO L-CALLED L-REMOVE
     IF L-OLD = 0 AND L-SIGNAL = 1
         MOVE 1 TO L-CALLED
         MOVE L-PRIMED TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-NEIGHBOR.
*> USING signal, prime succeeded, prime called out, remove out (section 8.3 neighborChanged).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-PRIMED               BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-PRIMED L-CALLED L-REMOVE.
     MOVE 0 TO L-CALLED L-REMOVE
     IF L-SIGNAL = 1
         MOVE 1 TO L-CALLED
         MOVE L-PRIMED TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-USE.
*> USING held item (0 other, 1 flint and steel, 2 fire charge), prime succeeded, server level, tnt_explodes, then result out (0 the default item-use result,
*> 1 SUCCESS, 2 PASS), air written at flags 11 out, flint and steel damaged out, fire charge consumed out, statistic out, overlay out (section 8.3 useItemOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HELD                 BINARY-LONG.
 01 L-PRIMED               BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-EXPLODES             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-CONSUME              BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 01 L-OVERLAY              BINARY-LONG.
 PROCEDURE DIVISION USING L-HELD L-PRIMED L-SERVER L-EXPLODES L-RESULT L-AIR L-DAMAGE L-CONSUME L-STAT L-OVERLAY.
     MOVE 0 TO L-RESULT L-AIR L-DAMAGE L-CONSUME L-STAT L-OVERLAY
     IF L-HELD NOT = 0
         MOVE 1 TO L-RESULT
         IF L-PRIMED = 1
             MOVE 1 TO L-AIR L-STAT
             IF L-HELD = 1
                 MOVE 1 TO L-DAMAGE
             ELSE
                 MOVE 1 TO L-CONSUME
             END-IF
         ELSE
             IF L-SERVER = 1 AND L-EXPLODES = 0
                 MOVE 2 TO L-RESULT
                 MOVE 1 TO L-OVERLAY
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-PROJECTILE.
*> USING server level, the projectile is burning, it may interact with the block, the owner is living, prime succeeded, an arrow with a pickup stack, then
*> prime called out, owner given out, stack given out, block removed out (section 8.3 onProjectileHit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-BURNING              BINARY-LONG.
 01 L-MAY                  BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-PRIMED               BINARY-LONG.
 01 L-ARROW                BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 01 L-REMOVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-BURNING L-MAY L-LIVING L-PRIMED L-ARROW L-CALLED L-OWNER L-STACK L-REMOVE.
     MOVE 0 TO L-CALLED L-OWNER L-STACK L-REMOVE
     IF L-SERVER = 1 AND L-BURNING = 1 AND L-MAY = 1
         MOVE 1 TO L-CALLED
         MOVE L-LIVING TO L-OWNER
         MOVE L-ARROW TO L-STACK
         MOVE L-PRIMED TO L-REMOVE
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-PROJECTILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-EXPLODED.
*> USING tnt_explodes, primed TNT created out, the short fuse used out, the item dropped out (section 8.3 wasExploded): no drop.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXPLODES             BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 01 L-SHORT                BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-EXPLODES L-CREATED L-SHORT L-DROPS.
     MOVE L-EXPLODES TO L-CREATED L-SHORT
     MOVE 0 TO L-DROPS
     GOBACK.
 END PROGRAM RS3-TNT-EXPLODED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-DESTROY.
*> USING server level, the player is in creative, unstable, prime called out (section 8.4 playerWillDestroy).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-UNSTABLE             BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-CREATIVE L-UNSTABLE L-CALLED.
     MOVE 0 TO L-CALLED
     IF L-SERVER = 1 AND L-CREATIVE = 0 AND L-UNSTABLE = 1
         MOVE 1 TO L-CALLED
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-REMOVAL.
*> USING caller (1 onPlace, neighborChanged or onProjectileHit, 2 the hand path, 3 fire, 4 playerWillDestroy, 5 wasExploded), prime called out, flags the caller
*> writes out (3 removeBlock, 11 air by hand, 0 the caller writes nothing itself) (section 8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALLER               BINARY-LONG.
 01 L-CALLED               BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CALLER L-CALLED L-FLAGS.
     MOVE 1 TO L-CALLED
     MOVE 0 TO L-FLAGS
     EVALUATE L-CALLER
         WHEN 1
             MOVE 3 TO L-FLAGS
         WHEN 2
             MOVE 11 TO L-FLAGS
         WHEN 5
             MOVE 0 TO L-CALLED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TNT-REMOVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-CONSTANTS.
*> USING fuse, metadata index of the fuse, explosion power in tenths, the explosion power clamp (read back), size in hundredths, eye in hundredths, tracking range,
*> update interval, fire immune, spawn y offset out (sections 8.2, 8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FUSE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-CLAMP                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-EYE                  BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-INTERVAL             BINARY-LONG.
 01 L-IMMUNE               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-FUSE L-INDEX L-POWER L-CLAMP L-SIZE L-EYE L-RANGE L-INTERVAL L-IMMUNE L-OFFSET.
     MOVE 80 TO L-FUSE
     MOVE 8 TO L-INDEX
     MOVE 40 TO L-POWER
     MOVE 128 TO L-CLAMP
     MOVE 98 TO L-SIZE
     MOVE 15 TO L-EYE
     MOVE 10 TO L-RANGE L-INTERVAL
     MOVE 1 TO L-IMMUNE
     MOVE 0 TO L-OFFSET
     GOBACK.
 END PROGRAM RS3-TNT-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-EXPLOSION-Y.
*> USING y offset out in tenths of nanoblocks (section 8.5): 0.9800000190734863 * 0.0625 = 0.0612500011920929.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-OFFSET.
     COMPUTE L-OFFSET ROUNDED = 0.9800000190734863 * 0.0625 * 10000000000
     GOBACK.
 END PROGRAM RS3-TNT-EXPLOSION-Y.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-NBT-POWER.
*> USING explosion power in tenths, written out (only when not 4.0), clamped out (0 to 128, tenths 0 to 1280) (section 8.5 NBT).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 01 L-CLAMPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-WRITTEN L-CLAMPED.
     MOVE 0 TO L-WRITTEN
     IF L-POWER NOT = 40
         MOVE 1 TO L-WRITTEN
     END-IF
     MOVE L-POWER TO L-CLAMPED
     IF L-CLAMPED < 0
         MOVE 0 TO L-CLAMPED
     END-IF
     IF L-CLAMPED > 1280
         MOVE 1280 TO L-CLAMPED
     END-IF
     GOBACK.
 END PROGRAM RS3-TNT-NBT-POWER.

*> ===== Section 9: corrections to other documents

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CORRECTION.
*> USING row (1 gate use, 2 gate explosion, 3 trapdoor pathfinding, 4 door wind charge, 5 trapdoor redstone), value a, b, c out (section 9): the corrected
*> reading as numbers: 1 the direction is the player's (1) and the gate turns only when its facing is the opposite (1); 2 the gate toggles (1) at flags 3;
*> 3 trapdoor pathfinding LAND 1, WATER 2, AIR 3 decoded; 4 lower half only (1); 5 open is left alone when it already equals the power (1); zeros otherwise.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-A L-B L-C.
     MOVE 0 TO L-A L-B L-C
     EVALUATE L-ROW
         WHEN 1
             MOVE 1 TO L-A L-B
         WHEN 2
             MOVE 1 TO L-A
             MOVE 3 TO L-B
         WHEN 3
             MOVE 1 TO L-A
             MOVE 2 TO L-B
             MOVE 3 TO L-C
         WHEN 4 THRU 5
             MOVE 1 TO L-A
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-CORRECTION.
