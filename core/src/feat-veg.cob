*> The vegetation families of the standard world's feature stage: which placed features the stage runs (FR-GATE) and the rules of the plants simple_block of
*> docs/protocol/35-worldgen-features-4 section 4 places (survival from 24 part 2 table 7.2, 24 part 4 sections 5.4 and 6.14; the two halves of the double plants).
*>
*> Entry points:
*>   FR-GATE USING placed feature key (PIC X(80)), flag out (BINARY-LONG): 1 when the stage runs the placed feature. With FI-GATE 0 every compiled one; with FI-GATE 1 the
*>     families of the table below (a prefix of the id): features of any other family stay off, so a family is switched on only when its features are placed whole.
*>   FV-DOUBLE-KEY USING block key (PIC X(80), with namespace), flag out: 1 for a double plant (two halves, property half).
*>   FR-SURV-OPEN: builds FEAT-SURV for the block table epoch (once per epoch).
*>   FR-CAN-SURVIVE USING state, x, y, z, ok out: the survival rule of the block of the state at the cell (the block below is read from the level).
*>   FR-SIMPLE-BLOCK USING state, x, y, z, result out: the placement of simple_block after the provider's state.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-GATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATINDEX.
*> the number of families of the table below: a new family adds a row here and raises this number
 78 FG-COUNT               VALUE 40.
*> prefix length and prefix, one family each
 01 WS-FAMILIES.
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC X(32) VALUE "minecraft:trees_".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:birch_tall".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC X(32) VALUE "minecraft:flower_".
    05 FILLER PIC 99 VALUE 24.
    05 FILLER PIC X(32) VALUE "minecraft:forest_flowers".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:patch_grass".
    05 FILLER PIC 99 VALUE 26.
    05 FILLER PIC X(32) VALUE "minecraft:patch_tall_grass".
    05 FILLER PIC 99 VALUE 26.
    05 FILLER PIC X(32) VALUE "minecraft:patch_large_fern".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:patch_bush".
    05 FILLER PIC 99 VALUE 25.
    05 FILLER PIC X(32) VALUE "minecraft:patch_dead_bush".
    05 FILLER PIC 99 VALUE 25.
    05 FILLER PIC X(32) VALUE "minecraft:patch_dry_grass".
    05 FILLER PIC 99 VALUE 25.
    05 FILLER PIC X(32) VALUE "minecraft:brown_mushroom_".
    05 FILLER PIC 99 VALUE 23.
    05 FILLER PIC X(32) VALUE "minecraft:red_mushroom_".
    05 FILLER PIC 99 VALUE 23.
    05 FILLER PIC X(32) VALUE "minecraft:patch_pumpkin".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:patch_melon".
    05 FILLER PIC 99 VALUE 25.
    05 FILLER PIC X(32) VALUE "minecraft:patch_waterlily".
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC X(32) VALUE "minecraft:seagrass_".
    05 FILLER PIC 99 VALUE 26.
    05 FILLER PIC X(32) VALUE "minecraft:patch_sugar_cane".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "minecraft:kelp_".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:sea_pickle".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:patch_berry".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "minecraft:vines".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC X(32) VALUE "minecraft:spring_".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "minecraft:lake_".
    05 FILLER PIC 99 VALUE 26.
    05 FILLER PIC X(32) VALUE "minecraft:freeze_top_layer".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "minecraft:disk_".
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC X(32) VALUE "minecraft:ice_patch".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC X(32) VALUE "minecraft:wildflowers_".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:cave_vines".
    05 FILLER PIC 99 VALUE 23.
    05 FILLER PIC X(32) VALUE "minecraft:spore_blossom".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC X(32) VALUE "minecraft:patch_cactus".
    05 FILLER PIC 99 VALUE 22.
    05 FILLER PIC X(32) VALUE "minecraft:monster_room".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:lush_caves_".
    05 FILLER PIC 99 VALUE 25.
    05 FILLER PIC X(32) VALUE "minecraft:pale_moss_patch".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:glow_lichen".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:sculk_vein".
    05 FILLER PIC 99 VALUE 20.
    05 FILLER PIC X(32) VALUE "minecraft:sculk_patch".
    05 FILLER PIC 99 VALUE 27.
    05 FILLER PIC X(32) VALUE "minecraft:pointed_dripstone".
    05 FILLER PIC 99 VALUE 27.
    05 FILLER PIC X(32) VALUE "minecraft:dripstone_cluster".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(32) VALUE "minecraft:forest_rock".
    05 FILLER PIC 99 VALUE 18.
    05 FILLER PIC X(32) VALUE "minecraft:blue_ice".
 01 WS-FAMILY-TABLE REDEFINES WS-FAMILIES.
    05 WS-FAMILY OCCURS FG-COUNT TIMES.
       10 WS-FAMILY-LENGTH    PIC 99.
       10 WS-FAMILY-PREFIX    PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FLAG.
     MOVE 1 TO L-FLAG
     IF FI-GATE = 1
         MOVE 0 TO L-FLAG
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FG-COUNT OR L-FLAG = 1
             MOVE WS-FAMILY-LENGTH(WS-I) TO WS-N
             IF L-KEY(1:WS-N) = WS-FAMILY-PREFIX(WS-I)(1:WS-N)
                 MOVE 1 TO L-FLAG
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FR-GATE.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. FV-DOUBLE-KEY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FLAG.
     MOVE 0 TO L-FLAG
     EVALUATE FUNCTION TRIM(L-KEY)
         WHEN "minecraft:tall_grass"
         WHEN "minecraft:large_fern"
         WHEN "minecraft:sunflower"
         WHEN "minecraft:lilac"
         WHEN "minecraft:rose_bush"
         WHEN "minecraft:peony"
         WHEN "minecraft:tall_seagrass"
             MOVE 1 TO L-FLAG
     END-EVALUATE
     GOBACK.
 END PROGRAM FV-DOUBLE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SURV-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CONTENT.
 COPY FEATSURV.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-KEY80               PIC X(80).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-DOUBLE              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 2048 TIMES.
 01 WS-INDEX               BINARY-LONG.
*> the tags read: key, then what a member gets (kind 1 rule 1 and single flowers, 2 tall flowers: rule 1 and a double plant, else the FS-SUP bit in the second column)
 01 WS-TAGS.
    05 FILLER PIC X(48) VALUE "minecraft:small_flowers".
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER PIC X(48) VALUE "minecraft:tall_flowers".
    05 FILLER BINARY-LONG VALUE -2.
    05 FILLER PIC X(48) VALUE "minecraft:supports_vegetation".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(48) VALUE "minecraft:supports_dry_vegetation".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(48) VALUE "minecraft:overrides_mushroom_light_requirement".
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER PIC X(48) VALUE "minecraft:supports_lily_pad".
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER PIC X(48) VALUE "minecraft:cannot_support_seagrass".
    05 FILLER BINARY-LONG VALUE 16.
 01 WS-TAG-TABLE REDEFINES WS-TAGS.
    05 WS-TAG-ROW OCCURS 7 TIMES.
       10 WS-TAG-KEY         PIC X(48).
       10 WS-TAG-KIND        BINARY-LONG.
 01 WS-BITS.
    05 WS-BIT              BINARY-LONG OCCURS 5 TIMES.
 01 WS-HAS                 BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-VINE                BINARY-LONG.
 01 WS-FACE                PIC X(40).
 01 WS-TRUE                PIC X(40) VALUE "true".
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     IF FS-EPOCH = CB-EPOCH + 1
         GOBACK
     END-IF
     MOVE 0 TO WS-VINE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE 0 TO FS-VINE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE 0 TO FS-RULE(WS-I) FS-UPPER(WS-I) FS-SUP(WS-I)
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
         EVALUATE FUNCTION TRIM(WS-FULL)
             WHEN "minecraft:short_grass"
             WHEN "minecraft:fern"
             WHEN "minecraft:bush"
             WHEN "minecraft:red_shrub"
             WHEN "minecraft:sweet_berry_bush"
             WHEN "minecraft:tall_grass"
             WHEN "minecraft:large_fern"
                 MOVE 1 TO FS-RULE(WS-I)
             WHEN "minecraft:dead_bush"
             WHEN "minecraft:short_dry_grass"
             WHEN "minecraft:tall_dry_grass"
                 MOVE 2 TO FS-RULE(WS-I)
             WHEN "minecraft:brown_mushroom"
             WHEN "minecraft:red_mushroom"
                 MOVE 3 TO FS-RULE(WS-I)
             WHEN "minecraft:lily_pad"
                 MOVE 4 TO FS-RULE(WS-I)
             WHEN "minecraft:vine"
                 MOVE WS-I TO WS-VINE
             WHEN "minecraft:seagrass"
                 MOVE 5 TO FS-RULE(WS-I)
             WHEN "minecraft:sea_pickle"
                 MOVE 6 TO FS-RULE(WS-I)
             WHEN "minecraft:tall_seagrass"
                 MOVE 7 TO FS-RULE(WS-I)
         END-EVALUATE
     END-PERFORM
*>   the tags: flowers stand on supports_vegetation; the other tags are bits of the block below
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
         MOVE WS-TAG-KEY(WS-J) TO WS-KEY112
         CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-KEY112 WS-COUNT WS-IDS WS-CAP WS-STATUS
         IF WS-STATUS = CT-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 COMPUTE WS-INDEX = WS-ID(WS-I) + 1
                 IF WS-INDEX >= 1 AND WS-INDEX <= CB-BLOCK-COUNT
                     EVALUATE TRUE
                         WHEN WS-TAG-KIND(WS-J) < 0
                             MOVE 1 TO FS-RULE(WS-INDEX)
                         WHEN OTHER
                             COMPUTE WS-Q = FS-SUP(WS-INDEX) / WS-TAG-KIND(WS-J)
                             COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
                             IF WS-HAS = 0
                                 ADD WS-TAG-KIND(WS-J) TO FS-SUP(WS-INDEX)
                             END-IF
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   the upper half of a double plant: the state of the block with half upper (a block without it is no double plant)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-FULL
         MOVE WS-FULL TO WS-KEY80
         CALL "FV-DOUBLE-KEY" USING WS-KEY80 WS-DOUBLE
         IF WS-DOUBLE = 1
             MOVE WS-FULL TO WS-KEY112
             MOVE "half=upper" TO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
             IF WS-STATE NOT = CB-DEFAULT-STATE(WS-I) AND WS-STATE NOT = 0
                 MOVE WS-STATE TO FS-UPPER(WS-I)
             END-IF
         END-IF
     END-PERFORM
*>   the vine states: the default vine (every face false) with the face of each direction true
     IF WS-VINE > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             EVALUATE WS-I
                 WHEN 1
                     MOVE "up" TO WS-FACE
                 WHEN 2
                     MOVE "north" TO WS-FACE
                 WHEN 3
                     MOVE "south" TO WS-FACE
                 WHEN 4
                     MOVE "west" TO WS-FACE
                 WHEN OTHER
                     MOVE "east" TO WS-FACE
             END-EVALUATE
             CALL "FD-STATE-SET" USING CB-DEFAULT-STATE(WS-VINE) WS-FACE WS-TRUE WS-STATE WS-FOUND
             IF WS-FOUND = 1
                 MOVE WS-STATE TO FS-VINE(WS-I)
             END-IF
         END-PERFORM
     END-IF
     COMPUTE FS-EPOCH = CB-EPOCH + 1
     GOBACK.
 END PROGRAM FR-SURV-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-CAN-SURVIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATSURV.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BSTATE              BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SUP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-OK.
     MOVE 1 TO L-OK
     CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
     IF WS-BLOCK = 0
         GOBACK
     END-IF
     IF FS-RULE(WS-BLOCK) = 0
         GOBACK
     END-IF
     COMPUTE WS-YB = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-YB L-Z WS-BSTATE
     CALL "FL-BLOCK-OF" USING WS-BSTATE WS-BELOW
     CALL "FL-CLASS" USING WS-BSTATE WS-CLASS
     MOVE 0 TO WS-SUP
     IF WS-BELOW > 0
         MOVE FS-SUP(WS-BELOW) TO WS-SUP
     END-IF
     MOVE 0 TO L-OK
     EVALUATE FS-RULE(WS-BLOCK)
         WHEN 1
             COMPUTE WS-Q = WS-SUP / 1
             COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
             MOVE WS-HAS TO L-OK
         WHEN 2
             COMPUTE WS-Q = WS-SUP / 2
             COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
             MOVE WS-HAS TO L-OK
*>       a mushroom: a block that overrides the light rule, or (light 0 at feature time, below 13) a block below that is a full solid render
         WHEN 3
             COMPUTE WS-Q = WS-SUP / 4
             COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
             MOVE WS-HAS TO L-OK
             IF WS-BELOW > 0 AND (WS-CLASS = 0 OR WS-CLASS = 4)
                 IF CB-OPAQUE(WS-BELOW) = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
*>       a lily pad: water below and no fluid in the cell above
         WHEN 4
             COMPUTE WS-YA = L-Y + 1
             CALL "FL-GET-STATE" USING L-X WS-YA L-Z WS-BSTATE
             CALL "FL-CLASS" USING WS-BSTATE WS-HAS
             IF WS-CLASS = 2 AND WS-HAS NOT = 2 AND WS-HAS NOT = 3
                 MOVE 1 TO L-OK
             END-IF
*>       seagrass: a full block below that cannot-support-seagrass does not list; tall seagrass (7) also needs water in its own cell
         WHEN 5
         WHEN 7
             COMPUTE WS-Q = WS-SUP / 16
             COMPUTE WS-HAS = FUNCTION MOD(WS-Q, 2)
             IF WS-BELOW > 0 AND (WS-CLASS = 0 OR WS-CLASS = 4) AND WS-HAS = 0
                 IF CB-OPAQUE(WS-BELOW) = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
             IF FS-RULE(WS-BLOCK) = 7 AND L-OK = 1
                 CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-BSTATE
                 CALL "FL-CLASS" USING WS-BSTATE WS-CLASS
                 IF WS-CLASS NOT = 2
                     MOVE 0 TO L-OK
                 END-IF
             END-IF
*>       a sea pickle: the collision shape of the block below has a face upward (a solid block)
         WHEN 6
             IF WS-BELOW > 0 AND (WS-CLASS = 0 OR WS-CLASS = 4)
                 IF CB-SOLID(WS-BELOW) = 1
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-CAN-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SIMPLE-BLOCK.
*> USING state, x, y, z, result out (1 written): the placement of simple_block (35-4 section 4) after the provider gave its state: the block below must be a block (not air, not below
*> the level), the survival rule of the plant (FR-CAN-SURVIVE), then the write; a double plant needs air above (or water above for tall seagrass) and writes both halves.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 COPY FEATSURV.
 01 WS-YB                  BINARY-LONG.
 01 WS-YA                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-RESULT.
     CALL "FR-SURV-OPEN"
     COMPUTE WS-YB = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-YB L-Z WS-B
     CALL "FL-CLASS" USING WS-B WS-CLASS
     IF WS-CLASS = 1 OR WS-YB < FL-MIN-Y
         GOBACK
     END-IF
     CALL "FR-CAN-SURVIVE" USING L-STATE L-X L-Y L-Z WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
     IF WS-BLOCK > 0
         IF FS-UPPER(WS-BLOCK) > 0
             COMPUTE WS-YA = L-Y + 1
             CALL "FL-GET-STATE" USING L-X WS-YA L-Z WS-ABOVE
             CALL "FL-CLASS" USING WS-ABOVE WS-CLASS
             IF WS-CLASS = 1 OR (WS-CLASS = 2 AND FS-RULE(WS-BLOCK) = 7)
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z L-STATE WS-FLAGS WS-OK
                 CALL "FL-SET-STATE" USING L-X WS-YA L-Z FS-UPPER(WS-BLOCK) WS-FLAGS WS-OK
                 MOVE 1 TO L-RESULT
             END-IF
             GOBACK
         END-IF
     END-IF
     CALL "FL-SET-STATE" USING L-X L-Y L-Z L-STATE WS-FLAGS WS-OK
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-SIMPLE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-VINES.
*> USING x, y, z, result out: the vines feature (35-4 section 7.1, no draws): the origin must be air; for the directions UP, NORTH, SOUTH, WEST, EAST the first with a neighbour a vine can
*> attach to (a block with a collision face toward the vine, approximated by a solid block: leaves and logs included) gets the vine with only that face (flags 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATSURV.
 01 WS-D                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "FR-SURV-OPEN"
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 1
         GOBACK
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 5 OR L-RESULT = 1
         MOVE L-X TO WS-X
         MOVE L-Y TO WS-Y
         MOVE L-Z TO WS-Z
         EVALUATE WS-D
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
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         IF WS-BLOCK > 0 AND (WS-CLASS = 0 OR WS-CLASS = 4) AND FS-VINE(WS-D) > 0
             IF CB-SOLID(WS-BLOCK) = 1
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z FS-VINE(WS-D) WS-FLAGS WS-OK
                 MOVE 1 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-VINES.
