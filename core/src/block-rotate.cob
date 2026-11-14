*> BlockState.rotate and BlockState.mirror (docs/protocol/24-block-registry-9-rotation-and-mirror.md), for the standard content set.
*> Rotation codes (the 36-2 order): 0 NONE, 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90. Mirror codes: 0 NONE, 1 LEFT_RIGHT (north and south swap),
*> 2 FRONT_BACK (east and west swap).
*>
*> Entry points:
*>   BLOCK-ROTATE-STATE USING state, rotation, result (BINARY-LONG)
*>   BLOCK-MIRROR-STATE USING state, mirror, result
*>   BLOCK-ROT-FAMILY USING key (PIC X(48)), family out (BINARY-LONG): the rule family of 24-9 section 4 for a block key (without namespace):
*>     0 none, 1 A, 2 A2, 3 B, 4 C, 5 D, 6 D2, 7 E, 8 F, 9 G, 10 H, 11 I, 12 J, 13 K, 14 L, 15 M, 16 N
*> A state that is not in the block table, a block of no family and a code of 0 give the state back. The result of a transform is memoised per state (a pure
*> function), and the property layout of the last block is kept, so a run over the states of a block parses its property list once.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROT-FAMILY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 BINARY-LONG.
 01 WS-WALL                BINARY-LONG.
 01 WS-TAIL                PIC X(96).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FAMILY               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FAMILY.
     MOVE 0 TO L-FAMILY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY TRAILING)) TO WS-LEN
*>   The key sits at the end of a 96 byte field, so a suffix test is a fixed slice whatever the key length.
     MOVE SPACES TO WS-TAIL
     MOVE L-KEY(1:WS-LEN) TO WS-TAIL(97 - WS-LEN:WS-LEN)
     MOVE 0 TO WS-WALL
     INSPECT L-KEY TALLYING WS-WALL FOR ALL "_wall_"
     EVALUATE TRUE
         WHEN L-KEY(1:11) = "cobolcraft:"
             CONTINUE
*>       Exact names first (a few of them end like a pattern of another family).
         WHEN L-KEY = "piston_head" OR "moving_piston" OR "piston" OR "sticky_piston" OR "end_rod" OR "barrel"
             OR "command_block" OR "repeating_command_block" OR "chain_command_block" OR "dispenser" OR "dropper"
             OR "observer" OR "amethyst_cluster" OR "large_amethyst_bud" OR "medium_amethyst_bud" OR "small_amethyst_bud"
             MOVE 3 TO L-FAMILY
         WHEN WS-TAIL(84:13) = "lightning_rod" OR WS-TAIL(86:11) = "shulker_box"
             MOVE 3 TO L-FAMILY
         WHEN L-KEY = "hopper"
             MOVE 4 TO L-FAMILY
         WHEN L-KEY = "anvil" OR "chipped_anvil" OR "damaged_anvil"
             MOVE 2 TO L-FAMILY
         WHEN L-KEY = "nether_portal"
             MOVE 6 TO L-FAMILY
         WHEN L-KEY = "rail" OR "powered_rail" OR "activator_rail" OR "detector_rail"
             MOVE 14 TO L-FAMILY
         WHEN L-KEY = "crafter" OR "jigsaw"
             MOVE 16 TO L-FAMILY
         WHEN L-KEY = "brown_mushroom_block" OR "red_mushroom_block" OR "mushroom_stem"
             MOVE 11 TO L-FAMILY
         WHEN L-KEY = "glow_lichen" OR "resin_clump" OR "sculk_vein"
             MOVE 12 TO L-FAMILY
         WHEN L-KEY = "redstone_wire"
             MOVE 10 TO L-FAMILY
         WHEN L-KEY = "pale_moss_carpet" OR WS-TAIL(92:5) = "_wall"
             MOVE 9 TO L-FAMILY
         WHEN L-KEY = "tripwire" OR "vine" OR "iron_bars" OR WS-TAIL(92:5) = "_bars" OR WS-TAIL(91:6) = "_fence"
             OR WS-TAIL(87:10) = "glass_pane"
             MOVE 8 TO L-FAMILY
         WHEN WS-TAIL(90:7) = "_banner" OR WS-TAIL(92:5) = "_sign" OR WS-TAIL(91:6) = "_skull"
             OR (WS-TAIL(92:5) = "_head" AND L-KEY NOT = "piston_head")
             IF WS-WALL > 0
                 MOVE 1 TO L-FAMILY
             ELSE
                 MOVE 7 TO L-FAMILY
             END-IF
         WHEN WS-TAIL(90:7) = "_stairs"
             MOVE 13 TO L-FAMILY
         WHEN WS-TAIL(92:5) = "_door"
             MOVE 15 TO L-FAMILY
         WHEN WS-TAIL(93:4) = "_log" OR WS-TAIL(92:5) = "_wood" OR WS-TAIL(90:7) = "_hyphae" OR WS-TAIL(88:9) = "froglight"
             OR WS-TAIL(91:6) = "_chain" OR WS-TAIL(90:7) = "_pillar"
             MOVE 5 TO L-FAMILY
         WHEN WS-TAIL(92:5) = "_stem" AND (L-KEY(1:7) = "crimson" OR L-KEY(1:6) = "warped" OR L-KEY(1:9) = "stripped_")
             MOVE 5 TO L-FAMILY
         WHEN L-KEY = "basalt" OR "polished_basalt" OR "deepslate" OR "muddy_mangrove_roots" OR "creaking_heart"
             OR "infested_deepslate" OR "hay_block" OR "bone_block" OR "bamboo_block" OR "stripped_bamboo_block"
             MOVE 5 TO L-FAMILY
         WHEN WS-TAIL(93:4) = "_bed" OR WS-TAIL(90:7) = "_button" OR WS-TAIL(88:9) = "_trapdoor" OR WS-TAIL(86:11) = "_fence_gate"
             OR WS-TAIL(79:18) = "_glazed_terracotta" OR WS-TAIL(91:6) = "_shelf" OR WS-TAIL(82:15) = "_coral_wall_fan"
             OR WS-TAIL(78:19) = "copper_golem_statue" OR WS-TAIL(89:8) = "campfire" OR WS-TAIL(91:6) = "_chest"
             OR WS-TAIL(90:7) = "furnace" OR WS-TAIL(87:10) = "wall_torch"
             MOVE 1 TO L-FAMILY
         WHEN L-KEY = "furnace" OR "smoker" OR "chest" OR "attached_pumpkin_stem" OR "attached_melon_stem" OR "bee_nest"
             OR "beehive" OR "bell" OR "calibrated_sculk_sensor" OR "chiseled_bookshelf" OR "decorated_pot"
             OR "end_portal_frame" OR "pink_petals" OR "wildflowers" OR "grindstone" OR "lever" OR "carved_pumpkin"
             OR "jack_o_lantern" OR "repeater" OR "cocoa" OR "comparator" OR "dried_ghast" OR "loom" OR "shelf_mushroom"
             OR "big_dripleaf" OR "big_dripleaf_stem" OR "ladder" OR "leaf_litter" OR "lectern" OR "small_dripleaf"
             OR "stonecutter" OR "tripwire_hook" OR "vault"
             MOVE 1 TO L-FAMILY
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCK-ROT-FAMILY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROT-DIR.
*> USING word (PIC X(16): a direction name), op (1 rotate, 2 mirror), code, word out (PIC X(16)): R(d) or M(d) of 24-9 section 2.3; up, down and any
*> other word are returned as they are.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east ".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west ".
 01 WS-NAMES-T REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(5) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-WORD                 PIC X(16).
 01 L-OP                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-OUT                  PIC X(16).
 PROCEDURE DIVISION USING L-WORD L-OP L-CODE L-OUT.
     MOVE L-WORD TO L-OUT
     MOVE 0 TO WS-I
     EVALUATE L-WORD
         WHEN "north"
             MOVE 1 TO WS-I
         WHEN "east"
             MOVE 2 TO WS-I
         WHEN "south"
             MOVE 3 TO WS-I
         WHEN "west"
             MOVE 4 TO WS-I
     END-EVALUATE
     IF WS-I = 0
         GOBACK
     END-IF
     IF L-OP = 1
         COMPUTE WS-I = FUNCTION MOD(WS-I - 1 + L-CODE, 4) + 1
     ELSE
         IF L-CODE = 1 AND (WS-I = 1 OR WS-I = 3)
             COMPUTE WS-I = 4 - WS-I
         END-IF
         IF L-CODE = 2 AND (WS-I = 2 OR WS-I = 4)
             COMPUTE WS-I = 6 - WS-I
         END-IF
     END-IF
     MOVE SPACES TO L-OUT
     MOVE WS-NAME(WS-I) TO L-OUT
     GOBACK.
 END PROGRAM BLOCK-ROT-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROT-VALUE.
*> USING mode (1 digit to text, 2 text to digit; BINARY-LONG), kind (PIC X: L list "a/b/c", R range "lo..hi", B boolean), spec (PIC X(280): the text between the
*> brackets of the property list), low (the first value of a range), digit (BINARY-LONG), text (PIC X(32)). Mode 2 gives digit -1 for a text the property does not
*> have. The rotate and mirror rules read list properties by text and the rest by digit; BLOCK-STATE-PROP reads and writes any kind by text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POINTER             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                PIC X(40).
 01 WS-NUMBER              PIC -(8)9.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-KIND                 PIC X.
 01 L-SPEC                 PIC X(280).
 01 L-LOW                  BINARY-LONG.
 01 L-DIGIT                BINARY-LONG.
 01 L-TEXT                 PIC X(32).
 PROCEDURE DIVISION USING L-MODE L-KIND L-SPEC L-LOW L-DIGIT L-TEXT.
     IF L-MODE = 1
         MOVE SPACES TO L-TEXT
         EVALUATE L-KIND
             WHEN "B"
                 IF L-DIGIT = 0
                     MOVE "true" TO L-TEXT
                 ELSE
                     MOVE "false" TO L-TEXT
                 END-IF
             WHEN "R"
                 COMPUTE WS-I = L-LOW + L-DIGIT
                 MOVE WS-I TO WS-NUMBER
                 MOVE FUNCTION TRIM(WS-NUMBER) TO L-TEXT
             WHEN OTHER
                 MOVE 1 TO WS-POINTER
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > L-DIGIT
                     MOVE SPACES TO WS-ITEM
                     UNSTRING L-SPEC DELIMITED BY "/" OR SPACE INTO WS-ITEM WITH POINTER WS-POINTER
                 END-PERFORM
                 MOVE WS-ITEM TO L-TEXT
         END-EVALUATE
         GOBACK
     END-IF
     MOVE -1 TO L-DIGIT
     EVALUATE L-KIND
         WHEN "B"
             IF L-TEXT = "true"
                 MOVE 0 TO L-DIGIT
             END-IF
             IF L-TEXT = "false"
                 MOVE 1 TO L-DIGIT
             END-IF
         WHEN "R"
             COMPUTE L-DIGIT = FUNCTION NUMVAL(L-TEXT) - L-LOW
         WHEN OTHER
             MOVE 1 TO WS-POINTER
             MOVE 0 TO WS-I
             PERFORM UNTIL WS-POINTER > 280 OR L-DIGIT >= 0
                 MOVE SPACES TO WS-ITEM
                 UNSTRING L-SPEC DELIMITED BY "/" OR SPACE INTO WS-ITEM WITH POINTER WS-POINTER
                 IF WS-ITEM = L-TEXT
                     MOVE WS-I TO L-DIGIT
                 END-IF
                 ADD 1 TO WS-I
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCK-ROT-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROT-LAYOUT.
*> USING block id (BINARY-LONG), layout out (BLOCK-ROT-LAYOUT-AREA below): the property list of the block as the content row gives it, in the list order
*> (sorted by name; the state index is split from the last property, stride 1, to the first, 24-1 / content CONTENT-STATE-PROPS), with the slot of each
*> property a rule reads (0 for none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ROW                 PIC X(819).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(71).
    05 WS-R-PROPS          PIC X(288).
    05 FILLER              PIC X(460).
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(300).
 01 WS-OPEN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SLASHES             BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-LOW-TEXT            PIC X(12).
 01 WS-HIGH-TEXT           PIC X(12).
 01 WS-HIGH                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-LAYOUT.
    05 LY-COUNT            BINARY-LONG.
    05 LY-FACING           BINARY-LONG.
    05 LY-AXIS             BINARY-LONG.
    05 LY-ROTATION         BINARY-LONG.
    05 LY-SHAPE            BINARY-LONG.
    05 LY-HINGE            BINARY-LONG.
    05 LY-ORIENTATION      BINARY-LONG.
    05 LY-SIDE             BINARY-LONG OCCURS 4 TIMES.
    05 LY-PROP OCCURS 16 TIMES.
       10 LY-NAME          PIC X(24).
       10 LY-SPEC          PIC X(280).
       10 LY-KIND          PIC X.
       10 LY-N             BINARY-LONG.
       10 LY-LOW           BINARY-LONG.
       10 LY-STRIDE        BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-LAYOUT.
     MOVE 0 TO LY-COUNT LY-FACING LY-AXIS LY-ROTATION LY-SHAPE LY-HINGE LY-ORIENTATION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO LY-SIDE(WS-I)
     END-PERFORM
     MOVE CB-FIRST-STATE(L-BLOCK + 1) TO WS-STATE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 288
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-R-PROPS DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES
             ADD 1 TO LY-COUNT
             MOVE 0 TO WS-OPEN
             INSPECT WS-TOKEN TALLYING WS-OPEN FOR CHARACTERS BEFORE INITIAL "["
             MOVE 0 TO WS-CLOSE
             INSPECT WS-TOKEN TALLYING WS-CLOSE FOR CHARACTERS BEFORE INITIAL "]"
             COMPUTE WS-LENGTH = WS-CLOSE - WS-OPEN - 1
             MOVE SPACES TO LY-NAME(LY-COUNT) LY-SPEC(LY-COUNT)
             MOVE WS-TOKEN(1:WS-OPEN) TO LY-NAME(LY-COUNT)
             MOVE WS-TOKEN(WS-OPEN + 2:WS-LENGTH) TO LY-SPEC(LY-COUNT)
             MOVE 0 TO LY-LOW(LY-COUNT) WS-SLASHES WS-DOTS
             INSPECT LY-SPEC(LY-COUNT) TALLYING WS-SLASHES FOR ALL "/"
             INSPECT LY-SPEC(LY-COUNT) TALLYING WS-DOTS FOR ALL ".."
             EVALUATE TRUE
                 WHEN WS-SLASHES > 0
                     MOVE "L" TO LY-KIND(LY-COUNT)
                     COMPUTE LY-N(LY-COUNT) = WS-SLASHES + 1
                 WHEN WS-DOTS > 0
                     MOVE "R" TO LY-KIND(LY-COUNT)
                     MOVE SPACES TO WS-LOW-TEXT WS-HIGH-TEXT
                     UNSTRING LY-SPEC(LY-COUNT) DELIMITED BY ".." INTO WS-LOW-TEXT WS-HIGH-TEXT
                     COMPUTE LY-LOW(LY-COUNT) = FUNCTION NUMVAL(WS-LOW-TEXT)
                     COMPUTE WS-HIGH = FUNCTION NUMVAL(WS-HIGH-TEXT)
                     COMPUTE LY-N(LY-COUNT) = WS-HIGH - LY-LOW(LY-COUNT) + 1
                 WHEN OTHER
                     MOVE "B" TO LY-KIND(LY-COUNT)
                     MOVE 2 TO LY-N(LY-COUNT)
             END-EVALUATE
             EVALUATE LY-NAME(LY-COUNT)
                 WHEN "facing"
                     MOVE LY-COUNT TO LY-FACING
                 WHEN "axis"
                     MOVE LY-COUNT TO LY-AXIS
                 WHEN "rotation"
                     MOVE LY-COUNT TO LY-ROTATION
                 WHEN "shape"
                     MOVE LY-COUNT TO LY-SHAPE
                 WHEN "hinge"
                     MOVE LY-COUNT TO LY-HINGE
                 WHEN "orientation"
                     MOVE LY-COUNT TO LY-ORIENTATION
                 WHEN "north"
                     MOVE LY-COUNT TO LY-SIDE(1)
                 WHEN "east"
                     MOVE LY-COUNT TO LY-SIDE(2)
                 WHEN "south"
                     MOVE LY-COUNT TO LY-SIDE(3)
                 WHEN "west"
                     MOVE LY-COUNT TO LY-SIDE(4)
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE 1 TO WS-LENGTH
     PERFORM VARYING WS-I FROM LY-COUNT BY -1 UNTIL WS-I < 1
         MOVE WS-LENGTH TO LY-STRIDE(WS-I)
         COMPUTE WS-LENGTH = WS-LENGTH * LY-N(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCK-ROT-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-XFORM-STATE.
*> USING state, op (1 rotate, 2 mirror), code (rotation 0..3 or mirror 0..2), result. The rules of 24-9 section 3, family by family.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-MEMO-TABLE.
    05 WS-MEMO-STATE OCCURS 40000 TIMES.
       10 WS-MEMO          BINARY-LONG OCCURS 7 TIMES.
 01 WS-FAMILIES.
    05 WS-FAMILY-OF        BINARY-LONG OCCURS 1400 TIMES.
 01 WS-LAYOUT-BLOCK        BINARY-LONG VALUE -1.
 01 WS-LAYOUT.
    05 LY-COUNT            BINARY-LONG.
    05 LY-FACING           BINARY-LONG.
    05 LY-AXIS             BINARY-LONG.
    05 LY-ROTATION         BINARY-LONG.
    05 LY-SHAPE            BINARY-LONG.
    05 LY-HINGE            BINARY-LONG.
    05 LY-ORIENTATION      BINARY-LONG.
    05 LY-SIDE             BINARY-LONG OCCURS 4 TIMES.
    05 LY-PROP OCCURS 16 TIMES.
       10 LY-NAME          PIC X(24).
       10 LY-SPEC          PIC X(280).
       10 LY-KIND          PIC X.
       10 LY-N             BINARY-LONG.
       10 LY-LOW           BINARY-LONG.
       10 LY-STRIDE        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-MSLOT               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-TEXT                PIC X(32).
 01 WS-WORD                PIC X(16).
 01 WS-OUT                 PIC X(16).
 01 WS-FACING-TEXT         PIC X(32).
 01 WS-SHAPE-TEXT          PIC X(32).
 01 WS-W1                  PIC X(16).
 01 WS-W2                  PIC X(16).
 01 WS-T1                  PIC X(16).
 01 WS-T2                  PIC X(16).
 01 WS-OLD-DIGITS.
    05 WS-OLD              BINARY-LONG OCCURS 4 TIMES.
 01 WS-NEW-DIGITS.
    05 WS-NEWD             BINARY-LONG OCCURS 4 TIMES.
 01 WS-SIDE-NAMES.
    05 FILLER              PIC X(16) VALUE "north".
    05 FILLER              PIC X(16) VALUE "east".
    05 FILLER              PIC X(16) VALUE "south".
    05 FILLER              PIC X(16) VALUE "west".
 01 WS-SIDE-NAMES-T REDEFINES WS-SIDE-NAMES.
    05 WS-SIDE-NAME        PIC X(16) OCCURS 4 TIMES.
 01 WS-TARGET              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 01 WS-FLIP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-OP L-CODE L-RESULT.
     GO TO MAIN-LOGIC.

*> The digit of property slot WS-SLOT in the state's index.
 GET-DIGIT.
     DIVIDE WS-INDEX BY LY-STRIDE(WS-SLOT) GIVING WS-QUOTIENT
     COMPUTE WS-DIGIT = FUNCTION MOD(WS-QUOTIENT, LY-N(WS-SLOT)).

*> Move the index so that property WS-SLOT has digit WS-VALUE (WS-NEW tracks the index being built).
 PUT-DIGIT.
     PERFORM GET-DIGIT
     COMPUTE WS-NEW = WS-NEW + (WS-VALUE - WS-DIGIT) * LY-STRIDE(WS-SLOT).

*> The text of property WS-SLOT in the original state.
 GET-TEXT.
     PERFORM GET-DIGIT
     MOVE 1 TO WS-MODE
     CALL "BLOCK-ROT-VALUE" USING WS-MODE LY-KIND(WS-SLOT) LY-SPEC(WS-SLOT) LY-LOW(WS-SLOT) WS-DIGIT WS-TEXT.

*> Set property WS-SLOT to the text WS-TEXT (when the property has that value).
 PUT-TEXT.
     MOVE 2 TO WS-MODE
     CALL "BLOCK-ROT-VALUE" USING WS-MODE LY-KIND(WS-SLOT) LY-SPEC(WS-SLOT) LY-LOW(WS-SLOT) WS-VALUE WS-TEXT
     IF WS-VALUE >= 0
         PERFORM PUT-DIGIT
     END-IF.

*> A direction property (facing): its value goes through R or M.
 TURN-SLOT.
     PERFORM GET-TEXT
     MOVE WS-TEXT TO WS-WORD
     CALL "BLOCK-ROT-DIR" USING WS-WORD L-OP L-CODE WS-OUT
     MOVE WS-OUT TO WS-TEXT
     PERFORM PUT-TEXT.

 SWAP-AXIS.
     PERFORM GET-TEXT
     EVALUATE WS-TEXT
         WHEN "x"
             MOVE "z" TO WS-TEXT
         WHEN "z"
             MOVE "x" TO WS-TEXT
     END-EVALUATE
     PERFORM PUT-TEXT.

*> Family E: 0..15 steps (24-9 section 2.4).
 STEP-16.
     PERFORM GET-DIGIT
     COMPUTE WS-VALUE = LY-LOW(WS-SLOT) + WS-DIGIT
     EVALUATE TRUE
         WHEN L-OP = 1
             COMPUTE WS-VALUE = FUNCTION MOD(WS-VALUE + 4 * L-CODE, 16)
         WHEN L-CODE = 1
             COMPUTE WS-VALUE = FUNCTION MOD(24 - WS-VALUE, 16)
         WHEN OTHER
             COMPUTE WS-VALUE = FUNCTION MOD(16 - WS-VALUE, 16)
     END-EVALUATE
     COMPUTE WS-VALUE = WS-VALUE - LY-LOW(WS-SLOT)
     PERFORM PUT-DIGIT.

*> Families F to J: the value of the property of side d goes to the property of R(d) or M(d); up and down stay.
 MOVE-SIDES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE LY-SIDE(WS-I) TO WS-SLOT
         PERFORM GET-DIGIT
         MOVE WS-DIGIT TO WS-OLD(WS-I)
         MOVE WS-DIGIT TO WS-NEWD(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "BLOCK-ROT-DIR" USING WS-SIDE-NAME(WS-I) L-OP L-CODE WS-OUT
         PERFORM VARYING WS-TARGET FROM 1 BY 1 UNTIL WS-SIDE-NAME(WS-TARGET) = WS-OUT
             CONTINUE
         END-PERFORM
         MOVE WS-OLD(WS-I) TO WS-NEWD(WS-TARGET)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE LY-SIDE(WS-I) TO WS-SLOT
         MOVE WS-NEWD(WS-I) TO WS-VALUE
         PERFORM PUT-DIGIT
     END-PERFORM.

*> Family K (24-9 section 3.8).
 STAIRS.
     MOVE LY-FACING TO WS-SLOT
     PERFORM GET-TEXT
     MOVE WS-TEXT TO WS-FACING-TEXT
     IF L-OP = 1
         PERFORM TURN-SLOT
     ELSE
         MOVE 0 TO WS-FLIP
         IF L-CODE = 1 AND (WS-FACING-TEXT = "north" OR WS-FACING-TEXT = "south")
             MOVE 1 TO WS-FLIP
         END-IF
         IF L-CODE = 2 AND (WS-FACING-TEXT = "east" OR WS-FACING-TEXT = "west")
             MOVE 1 TO WS-FLIP
         END-IF
         IF WS-FLIP = 1
             PERFORM TURN-SLOT
             MOVE LY-SHAPE TO WS-SLOT
             PERFORM GET-TEXT
             EVALUATE TRUE
                 WHEN WS-TEXT = "inner_left" AND L-CODE = 1
                     MOVE "inner_right" TO WS-TEXT
                 WHEN WS-TEXT = "inner_right" AND L-CODE = 1
                     MOVE "inner_left" TO WS-TEXT
                 WHEN WS-TEXT = "outer_left"
                     MOVE "outer_right" TO WS-TEXT
                 WHEN WS-TEXT = "outer_right"
                     MOVE "outer_left" TO WS-TEXT
             END-EVALUATE
             PERFORM PUT-TEXT
         END-IF
     END-IF.

*> Family L (24-9 section 3.9): each end of the shape goes through R or M.
 RAIL.
     MOVE LY-SHAPE TO WS-SLOT
     PERFORM GET-TEXT
     MOVE SPACES TO WS-W1 WS-W2
     UNSTRING WS-TEXT DELIMITED BY "_" INTO WS-W1 WS-W2
     EVALUATE TRUE
         WHEN WS-W1 = "ascending"
             CALL "BLOCK-ROT-DIR" USING WS-W2 L-OP L-CODE WS-T2
             MOVE SPACES TO WS-TEXT
             STRING "ascending_" FUNCTION TRIM(WS-T2) DELIMITED BY SIZE INTO WS-TEXT
         WHEN WS-TEXT = "north_south"
             IF L-OP = 1 AND FUNCTION MOD(L-CODE, 2) = 1
                 MOVE "east_west" TO WS-TEXT
             END-IF
         WHEN WS-TEXT = "east_west"
             IF L-OP = 1 AND FUNCTION MOD(L-CODE, 2) = 1
                 MOVE "north_south" TO WS-TEXT
             END-IF
         WHEN OTHER
             CALL "BLOCK-ROT-DIR" USING WS-W1 L-OP L-CODE WS-T1
             CALL "BLOCK-ROT-DIR" USING WS-W2 L-OP L-CODE WS-T2
             IF WS-T1 = "east" OR "west"
                 MOVE WS-T1 TO WS-OUT
                 MOVE WS-T2 TO WS-T1
                 MOVE WS-OUT TO WS-T2
             END-IF
             MOVE SPACES TO WS-TEXT
             STRING FUNCTION TRIM(WS-T1) "_" FUNCTION TRIM(WS-T2) DELIMITED BY SIZE INTO WS-TEXT
     END-EVALUATE
     PERFORM PUT-TEXT.

*> Family M (24-9 section 3.10): facing turns; a mirror also toggles the hinge.
 DOOR.
     MOVE LY-FACING TO WS-SLOT
     PERFORM TURN-SLOT
     IF L-OP = 2
         MOVE LY-HINGE TO WS-SLOT
         PERFORM GET-TEXT
         IF WS-TEXT = "left"
             MOVE "right" TO WS-TEXT
         ELSE
             MOVE "left" TO WS-TEXT
         END-IF
         PERFORM PUT-TEXT
     END-IF.

*> Family N (24-9 section 3.11): both words of front_top go through R or M.
 ORIENTATION.
     MOVE LY-ORIENTATION TO WS-SLOT
     PERFORM GET-TEXT
     MOVE SPACES TO WS-W1 WS-W2
     UNSTRING WS-TEXT DELIMITED BY "_" INTO WS-W1 WS-W2
     CALL "BLOCK-ROT-DIR" USING WS-W1 L-OP L-CODE WS-T1
     CALL "BLOCK-ROT-DIR" USING WS-W2 L-OP L-CODE WS-T2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-T1) "_" FUNCTION TRIM(WS-T2) DELIMITED BY SIZE INTO WS-TEXT
     PERFORM PUT-TEXT.
 MAIN-LOGIC.
     MOVE L-STATE TO L-RESULT
     IF L-CODE = 0 OR L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     IF CB-EPOCH NOT = WS-EPOCH
         MOVE CB-EPOCH TO WS-EPOCH
         MOVE -1 TO WS-LAYOUT-BLOCK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-MAX-STATES
             PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 7
                 MOVE -1 TO WS-MEMO(WS-I, WS-SLOT)
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-MAX-BLOCKS
             MOVE -1 TO WS-FAMILY-OF(WS-I)
         END-PERFORM
     END-IF
     COMPUTE WS-MSLOT = (L-OP - 1) * 4 + L-CODE + 1
     IF WS-MEMO(L-STATE + 1, WS-MSLOT) >= 0
         MOVE WS-MEMO(L-STATE + 1, WS-MSLOT) TO L-RESULT
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     IF WS-FAMILY-OF(WS-BLOCK + 1) < 0
         MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY
         CALL "BLOCK-ROT-FAMILY" USING WS-KEY WS-FAMILY-OF(WS-BLOCK + 1)
     END-IF
     MOVE WS-FAMILY-OF(WS-BLOCK + 1) TO WS-FAMILY
*>   Families that do not move under this op (no family; A2, D and D2 ignore a mirror) keep the state.
     IF WS-FAMILY = 0 OR (L-OP = 2 AND (WS-FAMILY = 2 OR WS-FAMILY = 5 OR WS-FAMILY = 6))
         MOVE L-STATE TO WS-MEMO(L-STATE + 1, WS-MSLOT)
         GOBACK
     END-IF
     IF WS-LAYOUT-BLOCK NOT = WS-BLOCK
         CALL "BLOCK-ROT-LAYOUT" USING WS-BLOCK WS-LAYOUT
         MOVE WS-BLOCK TO WS-LAYOUT-BLOCK
     END-IF
     COMPUTE WS-INDEX = L-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
     MOVE WS-INDEX TO WS-NEW
     EVALUATE WS-FAMILY
         WHEN 1
         WHEN 2
         WHEN 3
         WHEN 4
             MOVE LY-FACING TO WS-SLOT
             PERFORM TURN-SLOT
         WHEN 5
         WHEN 6
             IF FUNCTION MOD(L-CODE, 2) = 1
                 MOVE LY-AXIS TO WS-SLOT
                 PERFORM SWAP-AXIS
             END-IF
         WHEN 7
             MOVE LY-ROTATION TO WS-SLOT
             PERFORM STEP-16
         WHEN 8
         WHEN 9
         WHEN 10
         WHEN 11
         WHEN 12
             PERFORM MOVE-SIDES
         WHEN 13
             PERFORM STAIRS
         WHEN 14
             PERFORM RAIL
         WHEN 15
             PERFORM DOOR
         WHEN OTHER
             PERFORM ORIENTATION
     END-EVALUATE
     COMPUTE L-RESULT = CB-FIRST-STATE(WS-BLOCK + 1) + WS-NEW
     MOVE L-RESULT TO WS-MEMO(L-STATE + 1, WS-MSLOT)
     GOBACK.

 END PROGRAM BLOCK-XFORM-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-ROTATE-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-ROTATION             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROTATION L-RESULT.
     CALL "BLOCK-XFORM-STATE" USING L-STATE WS-OP L-ROTATION L-RESULT
     GOBACK.
 END PROGRAM BLOCK-ROTATE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCK-MIRROR-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP                  BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-MIRROR L-RESULT.
     CALL "BLOCK-XFORM-STATE" USING L-STATE WS-OP L-MIRROR L-RESULT
     GOBACK.
 END PROGRAM BLOCK-MIRROR-STATE.
