*> The core's view of the open content set's blocks (CBLOCKS.cpy; content-api section 2). BLOCKS-OPEN reads every
*> block row through CONTENT-BLOCK-OF-STATE (the same rows for the standard and the cobolcraft set), derives the
*> numeric properties the rules need once, and the lookups below turn keys and property pairs into ids without
*> any table of the game's own. Rules of derivation (see CBLOCKS.cpy): solid and opaque from the row's flags,
*> break time from its hardness, tool class from the block tags, light from its light text.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-STATE-PROPS.
*> USING state id (BINARY-LONG), text out (PIC X(160)): the property values of the state as "name=value" pairs
*> separated by commas in the block's list order (sorted by name); spaces for a state with none or an unknown state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-TEXT                 PIC X(160).
 PROCEDURE DIVISION USING L-STATE L-TEXT.
     MOVE SPACES TO L-TEXT
     CALL "CONTENT-STATE-PROPS" USING L-STATE CT-PROPS WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-NAME(WS-I))) TO WS-NAME-LENGTH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-VALUE(WS-I))) TO WS-VALUE-LENGTH
         IF WS-I > 1
             STRING "," DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
         END-IF
         STRING CTP-NAME(WS-I)(1:WS-NAME-LENGTH) "=" CTP-VALUE(WS-I)(1:WS-VALUE-LENGTH)
             DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-STATE-PROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-ID-OF.
*> USING key (PIC X(112), space padded; "minecraft:" is optional unless the cobolcraft set is open), block id out
*> (BINARY-LONG; -1 for a key the set does not hold): a search of the tables BLOCKS-OPEN built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-B                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     MOVE L-KEY TO WS-KEY
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:102) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CB-BLOCK-COUNT OR L-ID >= 0
         MOVE CB-KEY-LENGTH(WS-B) TO WS-LENGTH
         IF CB-KEY(WS-B)(1:WS-LENGTH) = WS-KEY(1:WS-LENGTH) AND WS-KEY(WS-LENGTH + 1:1) = SPACE
             COMPUTE L-ID = WS-B - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-ID-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-STATE-OF.
*> USING key (PIC X(112)), pairs (PIC X(160): "name=value" pairs separated by commas, spaces for none), state
*> out (BINARY-LONG): the state of that block whose properties are exactly the pairs; the block's default state
*> when no pair is given or none matches; 0 for a key the set does not hold.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ID                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-WANT                PIC X(164).
 01 WS-HAVE                PIC X(164).
 01 WS-PAIR                PIC X(48).
 01 WS-PAIR-LENGTH         BINARY-LONG.
 01 WS-NEEDLE              PIC X(64).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANTED              BINARY-LONG.
 01 WS-HAVE-COUNT          BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAIRS                PIC X(160).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     MOVE 0 TO L-STATE
     CALL "BLOCKS-ID-OF" USING L-KEY WS-ID
     IF WS-ID < 0
         GOBACK
     END-IF
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO L-STATE
     IF L-PAIRS = SPACES
         GOBACK
     END-IF
*>   ",pair,pair," forms of the wanted and of each state's properties, so a pair is found whole.
     MOVE SPACES TO WS-WANT
     STRING "," FUNCTION TRIM(L-PAIRS) "," DELIMITED BY SIZE INTO WS-WANT
     MOVE 0 TO WS-WANTED
     INSPECT WS-WANT TALLYING WS-WANTED FOR ALL ","
     SUBTRACT 1 FROM WS-WANTED
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-ID + 1) + CB-STATES(WS-ID + 1) - 1
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-ID + 1) BY 1 UNTIL WS-S > WS-LAST
         CALL "BLOCKS-STATE-PROPS" USING WS-S WS-TEXT
         MOVE SPACES TO WS-HAVE
         STRING "," FUNCTION TRIM(WS-TEXT) "," DELIMITED BY SIZE INTO WS-HAVE
         MOVE 0 TO WS-HAVE-COUNT
         INSPECT WS-HAVE TALLYING WS-HAVE-COUNT FOR ALL ","
         SUBTRACT 1 FROM WS-HAVE-COUNT
         MOVE 0 TO WS-MATCHED
         MOVE 2 TO WS-POINTER
         PERFORM WS-WANTED TIMES
             MOVE SPACES TO WS-PAIR
             MOVE 0 TO WS-PAIR-LENGTH
             UNSTRING WS-WANT DELIMITED BY "," INTO WS-PAIR COUNT WS-PAIR-LENGTH
                 WITH POINTER WS-POINTER
             MOVE 0 TO WS-FOUND
             MOVE SPACES TO WS-NEEDLE
             STRING "," WS-PAIR(1:WS-PAIR-LENGTH) "," DELIMITED BY SIZE INTO WS-NEEDLE
             COMPUTE WS-NEEDLE-LENGTH = WS-PAIR-LENGTH + 2
             INSPECT WS-HAVE TALLYING WS-FOUND FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH)
             IF WS-FOUND > 0
                 ADD 1 TO WS-MATCHED
             END-IF
         END-PERFORM
         IF WS-MATCHED = WS-WANTED AND WS-HAVE-COUNT = WS-WANTED
             MOVE WS-S TO L-STATE
             EXIT PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-STATE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-CHECK-ID.
*> USING block id (BINARY-LONG): fatal when the id does not fit the table (CB-MAX-BLOCKS). Kept in a program of its
*> own so that a run which ends here leaves no other program's coverage skewed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FATAL               PIC X(60) VALUE Z"block tables: more blocks than the core holds".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     IF L-ID >= CB-MAX-BLOCKS
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-CHECK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-LIMITS-CHECK.
*> USING block id, first state, state count (BINARY-LONG each): fatal when the states of the block do not fit the
*> table (CB-MAX-STATES).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FATAL               PIC X(60) VALUE Z"block tables: more states than the core holds".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FIRST L-COUNT.
     IF L-FIRST + L-COUNT > CB-MAX-STATES
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-LIMITS-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-LIGHT-KIND.
*> USING light text (PIC X(41), the light column of a block row), base (BINARY-LONG, the number the text starts with, 0 when it starts with no number; changed for "lit?N:0" and "lit ? N : 0"),
*> kind out (BINARY-LONG): how the light of the block's states is derived from the state (docs/protocol/24 the light column and the light notes; lane bugtorch T30010):
*>   0 the same number for every state (base)        1 base where lit is true ("N if lit, else 0", "N when `lit", "lit?N:0", "lit ? N : 0")
*>   2 base x candles where lit is true               3 base where berries is true
*>   4 copper bulb: 15, 12, 8, 4 by weathering when lit (BLOCKS-STATE-LIGHT reads it from the key)
*>   5 sea pickle: 3 + 3 x pickles when waterlogged   6 respawn anchor: charges x 15 div 4      7 light block: its level
*>   8 trial spawner by state 0, 4, 8, 8, 8, 0         9 vault by state 6, 12, 12, 12              10 glow lichen: 7 when any face is set
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST                PIC X(41).
 01 WS-NUMBER              PIC X(41).
 01 WS-HITS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(41).
 01 L-BASE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-BASE L-KIND.
     MOVE 0 TO L-KIND
     MOVE SPACES TO WS-REST WS-NUMBER
     EVALUATE TRUE
         WHEN L-TEXT(1:4) = "lit?"
             MOVE L-TEXT(5:37) TO WS-REST
             UNSTRING WS-REST DELIMITED BY ":" INTO WS-NUMBER
             COMPUTE L-BASE = FUNCTION NUMVAL(WS-NUMBER)
             MOVE 1 TO L-KIND
         WHEN L-TEXT(1:6) = "lit ? "
             MOVE L-TEXT(7:35) TO WS-REST
             UNSTRING WS-REST DELIMITED BY SPACE INTO WS-NUMBER
             COMPUTE L-BASE = FUNCTION NUMVAL(WS-NUMBER)
             MOVE 1 TO L-KIND
         WHEN L-TEXT(1:12) = "when lit: 15"
             MOVE 4 TO L-KIND
         WHEN L-TEXT(1:5) = "dead:"
             MOVE 5 TO L-KIND
         WHEN L-TEXT(1:13) = "level propert"
             MOVE 7 TO L-KIND
         WHEN L-TEXT(1:18) = "0/3/7/11/15 by cha"
             MOVE 6 TO L-KIND
         WHEN L-TEXT(1:16) = "by state: 0,4,8,"
             MOVE 8 TO L-KIND
         WHEN L-TEXT(1:16) = "by state: 6,12,1"
             MOVE 9 TO L-KIND
         WHEN L-TEXT(1:10) = "7 if any f"
             MOVE 10 TO L-KIND
         WHEN OTHER
             MOVE 0 TO WS-HITS
             INSPECT L-TEXT TALLYING WS-HITS FOR ALL "x candles"
             IF WS-HITS > 0
                 MOVE 2 TO L-KIND
                 GOBACK
             END-IF
             INSPECT L-TEXT TALLYING WS-HITS FOR ALL "when berries"
             IF WS-HITS > 0
                 MOVE 3 TO L-KIND
                 GOBACK
             END-IF
             INSPECT L-TEXT TALLYING WS-HITS FOR ALL "lit, else 0" ALL "when `lit"
             IF WS-HITS > 0
                 MOVE 1 TO L-KIND
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCKS-LIGHT-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-STATE-LIGHT.
*> USING kind (BLOCKS-LIGHT-KIND), base (BINARY-LONG), block key (PIC X(48)), properties of the state (CT-PROPS, CTPROPS.cpy), light out (BINARY-LONG): the light the state gives off.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LIT                 BINARY-LONG.
 01 WS-BERRIES             BINARY-LONG.
 01 WS-WATERLOGGED         BINARY-LONG.
 01 WS-FACES               BINARY-LONG.
 01 WS-CANDLES             BINARY-LONG.
 01 WS-PICKLES             BINARY-LONG.
 01 WS-CHARGES             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(32).
 01 WS-WEATHERED           BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-PROPS.
    05 LP-COUNT            BINARY-LONG.
    05 LP-ENTRY OCCURS 16 TIMES.
       10 LP-NAME          PIC X(24).
       10 LP-VALUE         PIC X(32).
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-BASE L-KEY L-PROPS L-LIGHT.
     MOVE 0 TO L-LIGHT WS-LIT WS-BERRIES WS-WATERLOGGED WS-FACES WS-CANDLES WS-PICKLES WS-CHARGES WS-LEVEL
     MOVE SPACES TO WS-STATE-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LP-COUNT
         EVALUATE LP-NAME(WS-I)
             WHEN "lit"
                 IF LP-VALUE(WS-I) = "true"
                     MOVE 1 TO WS-LIT
                 END-IF
             WHEN "berries"
                 IF LP-VALUE(WS-I) = "true"
                     MOVE 1 TO WS-BERRIES
                 END-IF
             WHEN "waterlogged"
                 IF LP-VALUE(WS-I) = "true"
                     MOVE 1 TO WS-WATERLOGGED
                 END-IF
             WHEN "down" WHEN "east" WHEN "north" WHEN "south" WHEN "up" WHEN "west"
                 IF LP-VALUE(WS-I) = "true"
                     ADD 1 TO WS-FACES
                 END-IF
             WHEN "candles"
                 COMPUTE WS-CANDLES = FUNCTION NUMVAL(LP-VALUE(WS-I))
             WHEN "pickles"
                 COMPUTE WS-PICKLES = FUNCTION NUMVAL(LP-VALUE(WS-I))
             WHEN "charges"
                 COMPUTE WS-CHARGES = FUNCTION NUMVAL(LP-VALUE(WS-I))
             WHEN "level"
                 COMPUTE WS-LEVEL = FUNCTION NUMVAL(LP-VALUE(WS-I))
             WHEN "trial_spawner_state" WHEN "vault_state"
                 MOVE LP-VALUE(WS-I) TO WS-STATE-TEXT
         END-EVALUATE
     END-PERFORM
     EVALUATE L-KIND
         WHEN 1
             IF WS-LIT = 1
                 MOVE L-BASE TO L-LIGHT
             END-IF
         WHEN 2
             IF WS-LIT = 1
                 COMPUTE L-LIGHT = L-BASE * WS-CANDLES
             END-IF
         WHEN 3
             IF WS-BERRIES = 1
                 MOVE L-BASE TO L-LIGHT
             END-IF
         WHEN 4
             IF WS-LIT = 1
                 MOVE 15 TO L-LIGHT
                 MOVE 0 TO WS-WEATHERED
                 INSPECT L-KEY TALLYING WS-WEATHERED FOR ALL "exposed_"
                 IF WS-WEATHERED > 0
                     MOVE 12 TO L-LIGHT
                 END-IF
                 MOVE 0 TO WS-WEATHERED
                 INSPECT L-KEY TALLYING WS-WEATHERED FOR ALL "weathered_"
                 IF WS-WEATHERED > 0
                     MOVE 8 TO L-LIGHT
                 END-IF
                 MOVE 0 TO WS-WEATHERED
                 INSPECT L-KEY TALLYING WS-WEATHERED FOR ALL "oxidized_"
                 IF WS-WEATHERED > 0
                     MOVE 4 TO L-LIGHT
                 END-IF
             END-IF
         WHEN 5
             IF WS-WATERLOGGED = 1
                 COMPUTE L-LIGHT = 3 + 3 * WS-PICKLES
             END-IF
         WHEN 6
             COMPUTE L-LIGHT = WS-CHARGES * 15 / 4
         WHEN 7
             MOVE WS-LEVEL TO L-LIGHT
         WHEN 8
             EVALUATE WS-STATE-TEXT
                 WHEN "waiting_for_players"
                     MOVE 4 TO L-LIGHT
                 WHEN "active" WHEN "waiting_for_reward_ejection" WHEN "ejecting_reward"
                     MOVE 8 TO L-LIGHT
             END-EVALUATE
         WHEN 9
             MOVE 12 TO L-LIGHT
             IF WS-STATE-TEXT = "inactive"
                 MOVE 6 TO L-LIGHT
             END-IF
         WHEN OTHER
             IF WS-FACES > 0
                 MOVE 7 TO L-LIGHT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BLOCKS-STATE-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-INSTRUMENT-OF.
*> USING the block key (PIC X(35)), the Instrument column text (PIC X(15)), the instrument number out (30-5 section 8.1): the column's name in any case; blank is harp (24 part 1: default HARP);
*> "see 5" (the dyed collections of 24 part 5 section 2) is basedrum for terracotta, hat for stained glass panes, harp for carpets and bass for banners.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-NAME                PIC X(32).
 01 WS-SOUND               PIC X(48).
 01 WS-WANT                PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(35).
 01 L-TEXT                 PIC X(15).
 01 L-INSTRUMENT           BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TEXT L-INSTRUMENT.
     MOVE 0 TO L-INSTRUMENT
     MOVE SPACES TO WS-KEY WS-WANT
     MOVE L-KEY TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-BARE))
     MOVE FUNCTION LOWER-CASE(FUNCTION TRIM(L-TEXT)) TO WS-WANT
     IF L-TEXT = "see 5"
         EVALUATE TRUE
             WHEN WS-LEN >= 11 AND WS-BARE(WS-LEN - 10:11) = "_terracotta"
                 MOVE "basedrum" TO WS-WANT
             WHEN WS-LEN >= 19 AND WS-BARE(WS-LEN - 18:19) = "_stained_glass_pane"
                 MOVE "hat" TO WS-WANT
             WHEN WS-LEN >= 6 AND WS-BARE(WS-LEN - 5:6) = "banner"
                 MOVE "bass" TO WS-WANT
             WHEN OTHER
                 MOVE "harp" TO WS-WANT
         END-EVALUATE
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 26
         CALL "RS2-NOTE-NAME" USING WS-I WS-NAME WS-SOUND
         IF WS-NAME = WS-WANT
             MOVE WS-I TO L-INSTRUMENT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-INSTRUMENT-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-PUSH-OF.
*> USING the block key (PIC X(35)), the Push column text (PIC X(10)), the push reaction out (0 PUSH_PULL, 1 PUSH, 2 POPPED, 3 IMMOVEABLE; 30-3 section 5.4): the column where it names one; the Push
*> column of the document rows is partly blank, so the lists of 30-3 section 5.4 decide those blocks: the IMMOVEABLE ones, and the POPPED ones the column leaves blank (the torches, buttons,
*> pressure plates, beds, doors, potted plants and the named plants and small blocks below).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IMMOVEABLE.
    05 FILLER PIC X(16) VALUE "piston".
    05 FILLER PIC X(16) VALUE "sticky_piston".
    05 FILLER PIC X(16) VALUE "piston_head".
    05 FILLER PIC X(16) VALUE "moving_piston".
    05 FILLER PIC X(16) VALUE "obsidian".
    05 FILLER PIC X(16) VALUE "nether_portal".
 01 WS-IMM-TABLE REDEFINES WS-IMMOVEABLE.
    05 WS-IMM              PIC X(16) OCCURS 6 TIMES.
 01 WS-POPPED.
    05 FILLER PIC X(20) VALUE "allium".
    05 FILLER PIC X(20) VALUE "azure_bluet".
    05 FILLER PIC X(20) VALUE "blue_orchid".
    05 FILLER PIC X(20) VALUE "brown_mushroom".
    05 FILLER PIC X(20) VALUE "bush".
    05 FILLER PIC X(20) VALUE "cactus".
    05 FILLER PIC X(20) VALUE "cactus_flower".
    05 FILLER PIC X(20) VALUE "cake".
    05 FILLER PIC X(20) VALUE "carved_pumpkin".
    05 FILLER PIC X(20) VALUE "cobweb".
    05 FILLER PIC X(20) VALUE "cornflower".
    05 FILLER PIC X(20) VALUE "dandelion".
    05 FILLER PIC X(20) VALUE "dead_bush".
    05 FILLER PIC X(20) VALUE "fern".
    05 FILLER PIC X(20) VALUE "fire".
    05 FILLER PIC X(20) VALUE "flower_pot".
    05 FILLER PIC X(20) VALUE "golden_dandelion".
    05 FILLER PIC X(20) VALUE "jack_o_lantern".
    05 FILLER PIC X(20) VALUE "ladder".
    05 FILLER PIC X(20) VALUE "lever".
    05 FILLER PIC X(20) VALUE "lily_of_the_valley".
    05 FILLER PIC X(20) VALUE "oxeye_daisy".
    05 FILLER PIC X(20) VALUE "poppy".
    05 FILLER PIC X(20) VALUE "red_mushroom".
    05 FILLER PIC X(20) VALUE "red_shrub".
    05 FILLER PIC X(20) VALUE "redstone_wire".
    05 FILLER PIC X(20) VALUE "repeater".
    05 FILLER PIC X(20) VALUE "seagrass".
    05 FILLER PIC X(20) VALUE "short_dry_grass".
    05 FILLER PIC X(20) VALUE "short_grass".
    05 FILLER PIC X(20) VALUE "snow".
    05 FILLER PIC X(20) VALUE "soul_fire".
    05 FILLER PIC X(20) VALUE "straw_bed".
    05 FILLER PIC X(20) VALUE "sugar_cane".
    05 FILLER PIC X(20) VALUE "tall_dry_grass".
    05 FILLER PIC X(20) VALUE "tall_seagrass".
    05 FILLER PIC X(20) VALUE "torch".
    05 FILLER PIC X(20) VALUE "torchflower".
    05 FILLER PIC X(20) VALUE "wall_torch".
    05 FILLER PIC X(20) VALUE "wheat".
    05 FILLER PIC X(20) VALUE "wither_rose".
    05 FILLER PIC X(20) VALUE "red_tulip".
    05 FILLER PIC X(20) VALUE "orange_tulip".
    05 FILLER PIC X(20) VALUE "white_tulip".
    05 FILLER PIC X(20) VALUE "pink_tulip".
 01 WS-POP-TABLE REDEFINES WS-POPPED.
    05 WS-POP              PIC X(20) OCCURS 44 TIMES.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(35).
 01 L-TEXT                 PIC X(10).
 01 L-PUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TEXT L-PUSH.
     MOVE 0 TO L-PUSH
     MOVE SPACES TO WS-KEY
     MOVE L-KEY TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-BARE))
     EVALUATE L-TEXT
         WHEN "PUSH"
             MOVE 1 TO L-PUSH
         WHEN "POPPED"
             MOVE 2 TO L-PUSH
         WHEN "IMMOVEABLE"
             MOVE 3 TO L-PUSH
     END-EVALUATE
     IF L-PUSH = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
             IF WS-BARE = WS-IMM(WS-I)
                 MOVE 3 TO L-PUSH
             END-IF
         END-PERFORM
     END-IF
     IF L-PUSH = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 44
             IF WS-BARE = WS-POP(WS-I)
                 MOVE 2 TO L-PUSH
             END-IF
         END-PERFORM
     END-IF
     IF L-PUSH = 0
         EVALUATE TRUE
             WHEN WS-LEN >= 7 AND WS-BARE(WS-LEN - 6:7) = "_button"
                 MOVE 2 TO L-PUSH
             WHEN WS-LEN >= 15 AND WS-BARE(WS-LEN - 14:15) = "_pressure_plate"
                 MOVE 2 TO L-PUSH
             WHEN WS-LEN >= 4 AND WS-BARE(WS-LEN - 3:4) = "_bed"
                 MOVE 2 TO L-PUSH
             WHEN WS-LEN >= 5 AND WS-BARE(WS-LEN - 4:5) = "_door"
                 MOVE 2 TO L-PUSH
             WHEN WS-LEN >= 6 AND WS-BARE(WS-LEN - 5:6) = "_torch"
                 MOVE 2 TO L-PUSH
             WHEN WS-LEN >= 7 AND WS-BARE(1:7) = "potted_"
                 MOVE 2 TO L-PUSH
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-PUSH-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-FILL.
*> USING block id (BINARY-LONG), row (PIC X(819), CT-BLOCK-ROW): derives the numbers of that block and fills its
*> CB-BLOCK entry and the CB-STATE entries of its states (the rules of CBLOCKS.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CTPROPS.
 COPY CTBSHAPE.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG-PICKAXE         PIC X(112) VALUE "minecraft:mineable/pickaxe".
 01 WS-TAG-SHOVEL          PIC X(112) VALUE "minecraft:mineable/shovel".
 01 WS-TAG-STONE-TIER     PIC X(112) VALUE "minecraft:needs_stone_tool".
 01 WS-TAG-IRON-TIER      PIC X(112) VALUE "minecraft:needs_iron_tool".
 01 WS-TAG-DIAMOND-TIER   PIC X(112) VALUE "minecraft:needs_diamond_tool".
 01 WS-TAGGED              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FLAGS               PIC X(149).
 01 WS-HITS                BINARY-LONG.
 01 WS-HARDNESS            FLOAT-LONG.
 01 WS-TOKEN               PIC X(41).
 01 WS-BASE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-CLASS               PIC X(32).
 01 WS-NAME                PIC X(48).
 01 WS-NAMES               PIC X(300).
 01 WS-PROPS               PIC X(160).
 01 WS-HAS-PROPS           BINARY-LONG.
 01 WS-ALWAYS-WET          BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-DOUBLE              BINARY-LONG.
 01 WS-EXTENDED            BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FLUID-EMPTY         BINARY-LONG.
 01 WS-PROP-DEFAULT        BINARY-LONG.
 01 WS-DAMP                BINARY-LONG.
 01 WS-PROPAGATES          BINARY-LONG.
 01 WS-USE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(819).
 PROCEDURE DIVISION USING L-ID L-ROW.
     MOVE L-ROW TO CT-BLOCK-ROW
     COMPUTE WS-INDEX = L-ID + 1
     CALL "BLOCKS-CHECK-ID" USING L-ID
     MOVE SPACES TO CB-KEY(WS-INDEX)
     MOVE FUNCTION TRIM(CT-BR-KEY) TO CB-KEY(WS-INDEX)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CT-BR-KEY)) TO CB-KEY-LENGTH(WS-INDEX)
     COMPUTE CB-FIRST-STATE(WS-INDEX) = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
     COMPUTE CB-STATES(WS-INDEX) = FUNCTION NUMVAL(CT-BR-STATE-COUNT)
     COMPUTE CB-DEFAULT-STATE(WS-INDEX) = FUNCTION NUMVAL(CT-BR-DEFAULT-STATE)
     CALL "BLOCKS-LIMITS-CHECK" USING L-ID CB-FIRST-STATE(WS-INDEX) CB-STATES(WS-INDEX)
*>   Flags: solid and opaque.
     MOVE SPACES TO WS-FLAGS
     STRING " " CT-BR-FLAGS " " DELIMITED BY SIZE INTO WS-FLAGS
     MOVE 1 TO CB-SOLID(WS-INDEX) CB-OPAQUE(WS-INDEX)
     MOVE 0 TO WS-HITS
     INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL "noCollision" ALL " air "
     IF WS-HITS > 0
         MOVE 0 TO CB-SOLID(WS-INDEX) CB-OPAQUE(WS-INDEX)
     END-IF
     MOVE 0 TO WS-HITS
     INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL "noOcclusion"
     IF WS-HITS > 0
         MOVE 0 TO CB-OPAQUE(WS-INDEX)
     END-IF
     MOVE 0 TO WS-HITS CB-REPLACEABLE(WS-INDEX)
     INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL " replaceable "
     IF WS-HITS > 0
         MOVE 1 TO CB-REPLACEABLE(WS-INDEX)
     END-IF
*>   Break time from the hardness.
     COMPUTE WS-HARDNESS = FUNCTION NUMVAL(CT-BR-HARDNESS)
     IF WS-HARDNESS < 0
         MOVE -1 TO CB-BREAK-MS(WS-INDEX)
     ELSE
         COMPUTE CB-BREAK-MS(WS-INDEX) ROUNDED = WS-HARDNESS * 1000
     END-IF
*>   Tool class from the block tags.
     MOVE 0 TO CB-CLASS(WS-INDEX)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-SHOVEL L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 2 TO CB-CLASS(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-PICKAXE L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 1 TO CB-CLASS(WS-INDEX)
     END-IF
*>   Tool requirement and tier (13 section 2.6).
     MOVE 0 TO CB-TOOL-REQ(WS-INDEX) CB-NEED-TIER(WS-INDEX)
     IF CT-BR-TOOL-REQUIRED(1:3) = "yes"
         MOVE 1 TO CB-TOOL-REQ(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-STONE-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 1 TO CB-NEED-TIER(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-IRON-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 2 TO CB-NEED-TIER(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-DIAMOND-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 3 TO CB-NEED-TIER(WS-INDEX)
     END-IF
*>   Light: a number first in the text, and whether it holds only where the property lit is true.
     MOVE SPACES TO WS-TOKEN
     MOVE FUNCTION TRIM(CT-BR-LIGHT) TO WS-TOKEN
     UNSTRING WS-TOKEN DELIMITED BY SPACE INTO WS-TOKEN
     MOVE 0 TO WS-BASE
     IF WS-TOKEN NOT = SPACES AND FUNCTION TEST-NUMVAL(WS-TOKEN) = 0
         COMPUTE WS-BASE = FUNCTION NUMVAL(WS-TOKEN)
     END-IF
     IF WS-BASE > 15
         MOVE 0 TO WS-BASE
     END-IF
     CALL "BLOCKS-LIGHT-KIND" USING CT-BR-LIGHT WS-BASE WS-KIND
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-INDEX) + CB-STATES(WS-INDEX) - 1
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-INDEX) BY 1 UNTIL WS-S > WS-LAST
         MOVE L-ID TO CB-S-BLOCK(WS-S + 1)
         MOVE WS-BASE TO WS-LIGHT
         IF WS-KIND > 0
             CALL "CONTENT-STATE-PROPS" USING WS-S CT-PROPS WS-STATUS
             CALL "BLOCKS-STATE-LIGHT" USING WS-KIND WS-BASE CB-KEY(WS-INDEX) CT-PROPS WS-LIGHT
         END-IF
         MOVE WS-LIGHT TO CB-S-LIGHT(WS-S + 1)
     END-PERFORM
     MOVE CB-S-LIGHT(CB-DEFAULT-STATE(WS-INDEX) + 1) TO CB-LIGHT(WS-INDEX)
*>   The sky light dampening of each state (32 section 7; the rules are L32-BLOCK-RULES'): the class, whether the occlusion shape is a full cube (canOcclude
*>   and an outline of the full cube; the outline shapes are built before the blocks, so a set without them reads every state as a full cube) and whether
*>   the state holds a fluid (waterlogged, a liquid, the plants that always stand in water).
     MOVE CT-BR-CLASS TO WS-CLASS
     MOVE SPACES TO WS-NAMES
     STRING " " CT-BR-PROPS " " DELIMITED BY SIZE INTO WS-NAMES
     MOVE 0 TO WS-HITS
     INSPECT WS-NAMES TALLYING WS-HITS FOR ALL " waterlogged[" ALL " type[" ALL " extended["
     MOVE 0 TO WS-HAS-PROPS
     IF WS-HITS > 0
         MOVE 1 TO WS-HAS-PROPS
     END-IF
     MOVE 0 TO WS-ALWAYS-WET
     IF WS-CLASS = "LiquidBlock"
         MOVE 1 TO WS-ALWAYS-WET
     END-IF
     MOVE CB-KEY(WS-INDEX) TO WS-NAME
     IF WS-NAME = "seagrass" OR "tall_seagrass" OR "kelp" OR "kelp_plant" OR "bubble_column"
         MOVE 1 TO WS-ALWAYS-WET
     END-IF
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-INDEX) BY 1 UNTIL WS-S > WS-LAST
         MOVE WS-ALWAYS-WET TO WS-WET
         MOVE 0 TO WS-DOUBLE WS-EXTENDED
         IF WS-HAS-PROPS = 1
             CALL "BLOCKS-STATE-PROPS" USING WS-S WS-PROPS
             MOVE 0 TO WS-HITS
             INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "waterlogged=true"
             IF WS-HITS > 0
                 MOVE 1 TO WS-WET
             END-IF
             MOVE 0 TO WS-HITS
             INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "type=double"
             IF WS-HITS > 0
                 MOVE 1 TO WS-DOUBLE
             END-IF
             MOVE 0 TO WS-HITS
             INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "extended=true"
             IF WS-HITS > 0
                 MOVE 1 TO WS-EXTENDED
             END-IF
         END-IF
         MOVE 1 TO WS-FULL
         IF BSH-READY = 1 AND BSH-OUT(WS-S + 1) NOT = 1
             MOVE 0 TO WS-FULL
         END-IF
         MOVE 0 TO WS-SOLID
         IF CB-OPAQUE(WS-INDEX) = 1 AND WS-FULL = 1
             MOVE 1 TO WS-SOLID
         END-IF
         COMPUTE WS-FLUID-EMPTY = 1 - WS-WET
         MOVE 0 TO WS-PROP-DEFAULT
         IF WS-FULL = 0 AND WS-FLUID-EMPTY = 1
             MOVE 1 TO WS-PROP-DEFAULT
         END-IF
         CALL "L32-BLOCK-RULES" USING WS-CLASS WS-SOLID WS-PROP-DEFAULT WS-FLUID-EMPTY WS-WET WS-DOUBLE WS-EXTENDED
             WS-DAMP WS-PROPAGATES WS-USE
*>       A block with no collision that holds no fluid lets the sky through (24 part 2 section 5.3: plants, flowers, mushrooms, torches, signs, rails, wheat, vines: 0).
*>       The class overrides of L32-BLOCK-RULES list only the classes that declare them, not the plants that inherit VegetationBlock's (tall grass, ferns, dry grass,
*>       crops, stems, hanging roots, vines, leaf litter) and whose outline is the full cube by the offset rule of 51: they come out 1 there. The cobweb (WebBlock:
*>       outline a full cube, dampening 1 by the table), leaves and the liquids keep what the rules gave.
         IF WS-DAMP = 1 AND CB-SOLID(WS-INDEX) = 0 AND WS-WET = 0
             AND WS-CLASS NOT = "LeavesBlock" AND WS-CLASS NOT = "LiquidBlock" AND WS-CLASS NOT = "WebBlock"
             MOVE 0 TO WS-DAMP
         END-IF
         MOVE WS-DAMP TO CB-S-DAMP(WS-S + 1)
     END-PERFORM
     CALL "BLOCKS-INSTRUMENT-OF" USING CT-BR-KEY CT-BR-INSTRUMENT CB-INSTRUMENT(WS-INDEX)
     CALL "BLOCKS-PUSH-OF" USING CT-BR-KEY CT-BR-PUSH CB-PUSH(WS-INDEX)
     GOBACK.
 END PROGRAM BLOCKS-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-OPEN.
*> No parameters: builds the tables of CBLOCKS.cpy from the open content set (called by CORE-WORLD-OPEN after the
*> set is opened): blocks are visited in id order by walking the state ids (CONTENT-BLOCK-OF-STATE answers the row
*> that holds a state, the next block starts after its last state). CB-EPOCH rises by one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 PROCEDURE DIVISION.
     MOVE CB-EPOCH TO WS-EPOCH
     MOVE LOW-VALUES TO CORE-BLOCKS
     COMPUTE CB-EPOCH = WS-EPOCH + 1
*>   The collision and outline shape of every state (51 block shapes; the content library's tables, built once per set type), before the blocks: the
*>   sky light dampening of a state (BLOCKS-FILL) reads its outline.
     CALL "BSH-BUILD"
     MOVE 0 TO WS-STATE
     MOVE CT-OK TO WS-STATUS
     PERFORM UNTIL WS-STATE >= CT-STATE-COUNT OR WS-STATUS NOT = CT-OK
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
         IF WS-STATUS = CT-OK
             CALL "BLOCKS-FILL" USING WS-ID WS-ROW
             ADD 1 TO WS-ID GIVING CB-BLOCK-COUNT
             COMPUTE WS-STATE = CB-FIRST-STATE(WS-ID + 1) + CB-STATES(WS-ID + 1)
             MOVE WS-STATE TO CB-STATE-COUNT
         END-IF
     END-PERFORM
*>   The roles of the cobolcraft rules, by key.
     MOVE SPACES TO WS-PAIRS
     MOVE "cobolcraft:cardstack" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-CARDSTACK
     MOVE "axis=x,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-X
     MOVE "axis=y,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Y
     MOVE "axis=z,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Z
     MOVE "axis=y,punched=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Y-PUNCHED
     MOVE "cobolcraft:glowtube" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-GLOWTUBE
     MOVE "lit=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GLOWTUBE-LIT
     MOVE "lit=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GLOWTUBE-UNLIT
     MOVE SPACES TO WS-PAIRS
     MOVE "cobolcraft:goto_pad" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-GOTO-PAD
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GOTO-PAD-STATE
     MOVE "cobolcraft:baseplate" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-BASEPLATE
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GREYSTONE
     MOVE "cobolcraft:loam" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-LOAM
     MOVE "cobolcraft:turf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-TURF
     MOVE "cobolcraft:grit" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GRIT
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-LUCITE
     MOVE "cobolcraft:slag" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-SLAG
     CALL "BIOMES-OPEN"
     GOBACK.
 END PROGRAM BLOCKS-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOMES-OPEN.
*> No parameters: fills CORE-BIOMES (CBLOCKS.cpy) from the biome registry of the open set: each entry's key and the climate of its
*> payload: network NBT (BIOME-CLIMATE; the cobolcraft set) or the entry's strict JSON, which begins with "{" (BIOME-CLIMATE-JSON;
*> a standard set; the entries are some 6000 bytes, so the area holds 64 KiB).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-REGISTRY            PIC X(112) VALUE "minecraft:worldgen/biome".
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FULL                BINARY-LONG VALUE 65536.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(65536).
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO CBI-COUNT
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT OR CBI-COUNT >= CBI-MAX
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
             WS-FULL WS-LENGTH WS-STATUS
         ADD 1 TO CBI-COUNT
         MOVE WS-KEY TO CBI-KEY(CBI-COUNT)
         MOVE WS-KEY-LENGTH TO CBI-KEY-LENGTH(CBI-COUNT)
         MOVE 0 TO CBI-PRECIPITATION(CBI-COUNT) CBI-TEMPERATURE(CBI-COUNT) CBI-FROZEN(CBI-COUNT)
         CALL "PB-RESET" USING PB-BUFFER
         EVALUATE TRUE
             WHEN WS-LENGTH > 0 AND WS-STATUS = 0 AND WS-PAYLOAD(1:1) = "{"
                 CALL "BIOME-CLIMATE-JSON" USING WS-PAYLOAD WS-LENGTH CBI-PRECIPITATION(CBI-COUNT)
                     CBI-TEMPERATURE(CBI-COUNT) CBI-FROZEN(CBI-COUNT)
             WHEN WS-LENGTH > 0 AND WS-STATUS = 0
                 CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-PAYLOAD WS-LENGTH
                 CALL "BIOME-CLIMATE" USING PB-BUFFER CBI-PRECIPITATION(CBI-COUNT) CBI-TEMPERATURE(CBI-COUNT)
                     CBI-FROZEN(CBI-COUNT)
         END-EVALUATE
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BIOMES-OPEN.
