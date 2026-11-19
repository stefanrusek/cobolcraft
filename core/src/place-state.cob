 *> The placed state of a block item used on a block (lane wallitems, CC-0009; docs/protocol/29 sections 9.5 and 9.6, 25 part 4 section 9.2 StandingAndWallBlockItem, and the getStateForPlacement rows of 24 parts 1 to 8
*> and 30): BLOCK-PLACE builds the placement context (PLACECTX.cpy; PLACE-CONTEXT-BUILD) and asks PLACE-STATE for the state of the cell. The block families are the table of PS-FAMILY (the key of the block, or the
*> axis property for the pillars), the standing-and-wall items (torches, signs, hanging signs, banners, skulls and heads, coral fans) are found by their wall block (PS-WALL-BLOCK).
*>
*> Entry points:
*>   PS-WALL-BLOCK USING state, wall block out (1-based block number, 0 when the state is not a standing block with a wall block), kind out (1 torch, 2 sign, 3 banner, 4 skull or head, 5 hanging sign, 6 coral fan)
*>   PS-FAMILY USING state, family out (0 none; 1 pillar, 2 slab, 3 stair, 4 face attached (lever, button, grindstone), 5 ladder and tripwire hook, 7 facing opposite the player, 8 facing the player, 9 anvil, 10 opposite the nearest
*>     looking direction, 11 the nearest looking direction, 12 the clicked face, 13 door, 14 trapdoor, 15 lantern, 16 multiface (vine, glow lichen, sculk vein, resin clump), 17 bed)
*>   PLACE-CONTEXT-BUILD USING connection id, Use Item On (PLAY-SERVERBOUND), item state, PLACE-CONTEXT out: the click, the player's view and the target cell (the clicked cell when the clicked block is replaced by the
*>     item: a replaceable block, a slab or a multiface block with room for it; else the cell on the clicked face)
*>   PS-MERGES USING PLACE-CONTEXT, state at the target, merges out: 1 when the item adds to the block at the target (a slab onto a slab that is not double, a multiface block onto one with a free face)
*>   PLACE-STATE USING PLACE-CONTEXT: sets PC-STATE and PC-FITS

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-WALL-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(48).
 01 WS-WALL                PIC X(112).
 01 WS-FULL                PIC X(48).
 01 WS-SUFFIX              PIC X(24).
 01 WS-FLAG                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-WORD                BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
*> The standing blocks whose item is a standing-and-wall item: the suffix of the key, the length of the word the wall block puts "wall_" in front of, and the kind.
 01 WS-RULES.
    05 FILLER              PIC X(24) VALUE "torch".
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              PIC X(24) VALUE "hanging_sign".
    05 FILLER              BINARY-LONG VALUE 12.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              PIC X(24) VALUE "_sign".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              PIC X(24) VALUE "_banner".
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              PIC X(24) VALUE "_skull".
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              PIC X(24) VALUE "_head".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              PIC X(24) VALUE "_fan".
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 6.
 01 WS-RULE-TABLE REDEFINES WS-RULES.
    05 WS-RULE OCCURS 7 TIMES.
       10 WS-R-SUFFIX      PIC X(24).
       10 WS-R-WORD        BINARY-LONG.
       10 WS-R-KIND        BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-WALL L-KIND.
     MOVE 0 TO L-WALL L-KIND
     IF L-STATE <= 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     CALL "PS-NAME-OF" USING L-STATE WS-NAME
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-NAME))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7 OR L-KIND > 0
         MOVE WS-R-SUFFIX(WS-I) TO WS-SUFFIX
*>       "torch" is a whole key or the last word ("soul_torch"); the other suffixes start with an underscore or are whole words of the key.
         MOVE 0 TO WS-FLAG
         IF WS-I = 1
             IF WS-NAME = "torch"
                 MOVE 1 TO WS-FLAG
             ELSE
                 MOVE "_torch" TO WS-SUFFIX
                 CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-FLAG
             END-IF
         ELSE
             IF WS-I = 2
                 MOVE "_hanging_sign" TO WS-SUFFIX
             END-IF
             CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-FLAG
         END-IF
         IF WS-FLAG = 1
             MOVE WS-R-WORD(WS-I) TO WS-WORD
             COMPUTE WS-HEAD = WS-LEN - WS-WORD
             MOVE SPACES TO WS-WALL
             IF WS-HEAD = 0
                 STRING "minecraft:wall_" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-WALL
             ELSE
                 COMPUTE WS-FROM = WS-HEAD + 1
                 STRING "minecraft:" WS-NAME(1:WS-HEAD) "wall_" WS-NAME(WS-FROM:WS-WORD) DELIMITED BY SIZE INTO WS-WALL
             END-IF
             CALL "BLOCKS-ID-OF" USING WS-WALL WS-ID
             IF WS-ID >= 0
                 COMPUTE L-WALL = WS-ID + 1
                 MOVE WS-R-KIND(WS-I) TO L-KIND
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-WALL-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-FAMILY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-CMP                 PIC X(48).
 01 WS-SUFFIX              PIC X(24).
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-COUNT               BINARY-LONG.
*> The block families by key: kind (E the whole key, S the end of the key), the key or its end, the family number of PS-FAMILY.
 01 WS-ROWS.
    05 FILLER PIC X(27) VALUE "Eladder                  05".
    05 FILLER PIC X(27) VALUE "Etripwire_hook           05".
    05 FILLER PIC X(27) VALUE "S_slab                   02".
    05 FILLER PIC X(27) VALUE "S_stairs                 03".
    05 FILLER PIC X(27) VALUE "Elever                   04".
    05 FILLER PIC X(27) VALUE "S_button                 04".
    05 FILLER PIC X(27) VALUE "Egrindstone              04".
    05 FILLER PIC X(27) VALUE "Efurnace                 07".
    05 FILLER PIC X(27) VALUE "Eblast_furnace           07".
    05 FILLER PIC X(27) VALUE "Esmoker                  07".
    05 FILLER PIC X(27) VALUE "Eloom                    07".
    05 FILLER PIC X(27) VALUE "Estonecutter             07".
    05 FILLER PIC X(27) VALUE "Electern                 07".
    05 FILLER PIC X(27) VALUE "Ebeehive                 07".
    05 FILLER PIC X(27) VALUE "Ebee_nest                07".
    05 FILLER PIC X(27) VALUE "Eend_portal_frame        07".
    05 FILLER PIC X(27) VALUE "Erepeater                07".
    05 FILLER PIC X(27) VALUE "Ecomparator              07".
    05 FILLER PIC X(27) VALUE "S_shelf                  07".
    05 FILLER PIC X(27) VALUE "S_fence_gate             08".
    05 FILLER PIC X(27) VALUE "Edecorated_pot           08".
    05 FILLER PIC X(27) VALUE "Eanvil                   09".
    05 FILLER PIC X(27) VALUE "Echipped_anvil           09".
    05 FILLER PIC X(27) VALUE "Edamaged_anvil           09".
    05 FILLER PIC X(27) VALUE "Edispenser               10".
    05 FILLER PIC X(27) VALUE "Edropper                 10".
    05 FILLER PIC X(27) VALUE "Episton                  10".
    05 FILLER PIC X(27) VALUE "Esticky_piston           10".
    05 FILLER PIC X(27) VALUE "Eobserver                11".
    05 FILLER PIC X(27) VALUE "Slightning_rod           12".
    05 FILLER PIC X(27) VALUE "Eamethyst_cluster        12".
    05 FILLER PIC X(27) VALUE "Esmall_amethyst_bud      12".
    05 FILLER PIC X(27) VALUE "Emedium_amethyst_bud     12".
    05 FILLER PIC X(27) VALUE "Elarge_amethyst_bud      12".
    05 FILLER PIC X(27) VALUE "S_door                   13".
    05 FILLER PIC X(27) VALUE "S_trapdoor               14".
    05 FILLER PIC X(27) VALUE "Elantern                 15".
    05 FILLER PIC X(27) VALUE "Esoul_lantern            15".
    05 FILLER PIC X(27) VALUE "Scopper_lantern          15".
    05 FILLER PIC X(27) VALUE "Evine                    16".
    05 FILLER PIC X(27) VALUE "Eglow_lichen             16".
    05 FILLER PIC X(27) VALUE "Esculk_vein              16".
    05 FILLER PIC X(27) VALUE "Eresin_clump             16".
    05 FILLER PIC X(27) VALUE "S_bed                    17".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 44 TIMES.
       10 WS-ROW-KIND      PIC X.
       10 WS-ROW-TEXT      PIC X(24).
       10 WS-ROW-FAMILY    PIC 99.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FAMILY.
     MOVE 0 TO L-FAMILY
     CALL "PS-NAME-OF" USING L-STATE WS-NAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 44 OR L-FAMILY > 0
         MOVE WS-ROW-TEXT(WS-I) TO WS-SUFFIX
         MOVE 0 TO WS-FLAG
         IF WS-ROW-KIND(WS-I) = "E"
             MOVE WS-SUFFIX TO WS-CMP
             IF WS-NAME = WS-CMP
                 MOVE 1 TO WS-FLAG
             END-IF
         ELSE
             CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-FLAG
         END-IF
         IF WS-FLAG = 1
             MOVE WS-ROW-FAMILY(WS-I) TO L-FAMILY
         END-IF
     END-PERFORM
*>   A pillar is any block with an axis property (RotatedPillarBlock and its relatives: logs, wood, basalt, hay, bone, chains, pillars).
     IF L-FAMILY = 0 AND L-STATE > 0
         CALL "BLOCKS-STATE-PROPS" USING L-STATE WS-PROPS
         MOVE 0 TO WS-COUNT
         INSPECT WS-PROPS TALLYING WS-COUNT FOR ALL "axis="
         IF WS-COUNT > 0
             MOVE 1 TO L-FAMILY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-FAMILY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-FACES-FREE.
*> USING state, free out (BINARY-LONG): the face properties (down, up, north, south, west, east) the state's block has that are not set, 0 for a block without face properties.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DIR-TEXT            PIC X(32).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FREE.
     MOVE 0 TO L-FREE
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
         CALL "PS-DIR-NAME" USING WS-D WS-DIR-TEXT
         MOVE WS-DIR-TEXT TO WS-NAME
         CALL "PS-GET" USING L-STATE WS-NAME WS-TEXT WS-FOUND
         IF WS-FOUND = 1 AND FUNCTION TRIM(WS-TEXT) NOT = "true"
             ADD 1 TO L-FREE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PS-FACES-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-MERGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "type".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 01 L-OLD                  BINARY-LONG.
 01 L-MERGES               BINARY-LONG.
 PROCEDURE DIVISION USING PLACE-CONTEXT L-OLD L-MERGES.
     MOVE 0 TO L-MERGES
     IF L-OLD > 0 AND L-OLD < CB-STATE-COUNT AND PC-STATE > 0 AND PC-STATE < CB-STATE-COUNT
         IF CB-S-BLOCK(L-OLD + 1) = CB-S-BLOCK(PC-STATE + 1)
             CALL "PS-FAMILY" USING PC-STATE WS-FAMILY
             EVALUATE WS-FAMILY
                 WHEN 2
                     CALL "PS-GET" USING L-OLD WS-NAME WS-TEXT WS-FOUND
                     IF FUNCTION TRIM(WS-TEXT) NOT = "double"
                         MOVE 1 TO L-MERGES
                     END-IF
                 WHEN 16
                     CALL "PS-FACES-FREE" USING L-OLD WS-FREE
                     IF WS-FREE > 0
                         MOVE 1 TO L-MERGES
                     END-IF
             END-EVALUATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-MERGES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-CLICK-REPLACES.
*> USING PLACE-CONTEXT, clicked state, replace out: BlockPlaceContext.replaceClicked = canBeReplaced of the clicked block for the item (29 section 9.5): the clicked block is replaced when it is replaceable (the tag
*> minecraft:replaceable) and is not the item's own block; a slab of the item's own kind is replaced by it when the click is on the face or half that is open (24 part 2 section 7.3), a multiface block of the
*> item's own kind while a face is free (24 part 4 section 6.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "type".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:replaceable".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 01 L-CLICKED              BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 PROCEDURE DIVISION USING PLACE-CONTEXT L-CLICKED L-REPLACE.
     MOVE 0 TO L-REPLACE
     IF L-CLICKED <= 0 OR L-CLICKED >= CB-STATE-COUNT OR PC-STATE <= 0 OR PC-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     IF CB-S-BLOCK(L-CLICKED + 1) NOT = CB-S-BLOCK(PC-STATE + 1)
         MOVE CB-S-BLOCK(L-CLICKED + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK L-REPLACE
         GOBACK
     END-IF
     CALL "PS-FAMILY" USING PC-STATE WS-FAMILY
     EVALUATE WS-FAMILY
         WHEN 2
             CALL "PS-GET" USING L-CLICKED WS-NAME WS-TEXT WS-FOUND
             MOVE 0 TO WS-HIGH
             IF PC-CY > 0.5
                 MOVE 1 TO WS-HIGH
             END-IF
             EVALUATE TRUE
                 WHEN FUNCTION TRIM(WS-TEXT) = "bottom" AND (PC-FACE = 1 OR (PC-FACE > 1 AND WS-HIGH = 1))
                     MOVE 1 TO L-REPLACE
                 WHEN FUNCTION TRIM(WS-TEXT) = "top" AND (PC-FACE = 0 OR (PC-FACE > 1 AND WS-HIGH = 0))
                     MOVE 1 TO L-REPLACE
             END-EVALUATE
         WHEN 16
             CALL "PS-FACES-FREE" USING L-CLICKED WS-FREE
             IF WS-FREE > 0
                 MOVE 1 TO L-REPLACE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PS-CLICK-REPLACES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLACE-CONTEXT-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CLICKED             BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 COPY PLAYPKT.
 01 L-ITEM-STATE           BINARY-LONG.
 COPY PLACECTX.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND L-ITEM-STATE PLACE-CONTEXT.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO PC-DIM
     MOVE PSB-BX TO PC-BX
     MOVE PSB-BY TO PC-BY
     MOVE PSB-BZ TO PC-BZ
     MOVE PSB-FACE TO PC-FACE
     MOVE PSB-CURSOR-X TO PC-CX
     MOVE PSB-CURSOR-Y TO PC-CY
     MOVE PSB-CURSOR-Z TO PC-CZ
     MOVE PL-YAW(WS-ROW) TO PC-YAW
     MOVE PL-PITCH(WS-ROW) TO PC-PITCH
     MOVE PL-SNEAKING(WS-ROW) TO PC-SNEAK
     CALL "PS-HDIR" USING PC-YAW PC-HDIR
     MOVE L-ITEM-STATE TO PC-STATE
     MOVE 1 TO PC-FITS
*>   The directions nearest to the look, and (replaceClicked is known below) the order with the opposite of the clicked face first.
     CALL "UI-NEAREST" USING PC-YAW PC-PITCH PC-ORDER
     MOVE PC-DIR(1) TO PC-NEAREST
     CALL "WORLD-GET-BLOCK" USING PC-DIM PC-BX PC-BY PC-BZ WS-CLICKED
     CALL "PS-CLICK-REPLACES" USING PLACE-CONTEXT WS-CLICKED PC-REPLACE
     CALL "UI-NEAREST-DIRS" USING PC-REPLACE PC-FACE PC-ORDER
     CALL "PS-DIR-STEP" USING PC-FACE WS-DX WS-DY WS-DZ
     MOVE PC-BX TO PC-X
     MOVE PC-BY TO PC-Y
     MOVE PC-BZ TO PC-Z
     IF PC-REPLACE = 0
         ADD WS-DX TO PC-X
         ADD WS-DY TO PC-Y
         ADD WS-DZ TO PC-Z
     END-IF
     GOBACK.
 END PROGRAM PLACE-CONTEXT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLACE-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-WALL                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-MERGES              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-TYPE-NAME           PIC X(24) VALUE "type".
 01 WS-TYPE-TEXT           PIC X(32).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
*>   A standing-and-wall item (torch, sign, hanging sign, banner, skull, coral fan): 25 part 4 section 9.2.
     CALL "PS-WALL-BLOCK" USING PC-STATE WS-WALL WS-KIND
     IF WS-WALL > 0
         CALL "PS-STANDWALL" USING PLACE-CONTEXT
         GOBACK
     END-IF
     CALL "PS-FAMILY" USING PC-STATE WS-FAMILY
     EVALUATE WS-FAMILY
*>       RotatedPillarBlock: the axis of the clicked face.
         WHEN 1
             MOVE "axis" TO WS-NAME
             EVALUATE TRUE
                 WHEN PC-FACE < 2
                     MOVE "y" TO WS-TEXT
                 WHEN PC-FACE < 4
                     MOVE "z" TO WS-TEXT
                 WHEN OTHER
                     MOVE "x" TO WS-TEXT
             END-EVALUATE
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
*>       SlabBlock (24 part 2 section 7.3): a double slab where the same slab is, else the half of the click.
         WHEN 2
             CALL "WORLD-GET-BLOCK" USING PC-DIM PC-X PC-Y PC-Z WS-OLD
             CALL "PS-MERGES" USING PLACE-CONTEXT WS-OLD WS-MERGES
             MOVE "double" TO WS-TYPE-TEXT
             IF WS-MERGES = 0
                 MOVE "bottom" TO WS-TYPE-TEXT
                 IF PC-FACE = 0 OR (PC-FACE > 1 AND PC-CY > 0.5)
                     MOVE "top" TO WS-TYPE-TEXT
                 END-IF
             END-IF
             CALL "PS-PUT" USING PC-STATE WS-TYPE-NAME WS-TYPE-TEXT
         WHEN 3
             CALL "PS-STAIR" USING PLACE-CONTEXT
         WHEN 4
             CALL "PS-FACE-ATTACHED" USING PLACE-CONTEXT
         WHEN 5
             CALL "PS-LADDER" USING PLACE-CONTEXT
*>       facing = the opposite of the player's horizontal direction (furnaces, loom, stonecutter, lectern, beehive, end portal frame, repeater, comparator, shelves).
         WHEN 7
             MOVE "facing" TO WS-NAME
             CALL "PS-OPP" USING PC-HDIR WS-OPP
             CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
*>       facing = the player's horizontal direction (fence gates, decorated pot).
         WHEN 8
             MOVE "facing" TO WS-NAME
             CALL "PS-DIR-NAME" USING PC-HDIR WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
*>       The anvil faces the clockwise direction of the player's.
         WHEN 9
             MOVE "facing" TO WS-NAME
             CALL "PS-CW" USING PC-HDIR WS-DIR
             CALL "PS-DIR-NAME" USING WS-DIR WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
*>       Dispenser, dropper and pistons: the opposite of the nearest looking direction; the observer: the nearest looking direction.
         WHEN 10
             MOVE "facing" TO WS-NAME
             CALL "PS-OPP" USING PC-NEAREST WS-OPP
             CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
         WHEN 11
             MOVE "facing" TO WS-NAME
             CALL "PS-DIR-NAME" USING PC-NEAREST WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
*>       Lightning rods and amethyst buds face the clicked face.
         WHEN 12
             MOVE "facing" TO WS-NAME
             CALL "PS-DIR-NAME" USING PC-FACE WS-TEXT
             CALL "PS-PUT" USING PC-STATE WS-NAME WS-TEXT
         WHEN 13
             CALL "PS-DOOR" USING PLACE-CONTEXT
         WHEN 14
             CALL "PS-TRAPDOOR" USING PLACE-CONTEXT
         WHEN 15
             CALL "PS-LANTERN" USING PLACE-CONTEXT
         WHEN 16
             CALL "PS-MULTIFACE" USING PLACE-CONTEXT
*>       BedBlock: facing = the player's horizontal direction, the head cell must be free (BED-PLACE-HEAD places the head half after the foot).
         WHEN 17
             CALL "PS-BED" USING PLACE-CONTEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM PLACE-STATE.
