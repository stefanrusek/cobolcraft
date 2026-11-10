*> Block entities, part 1: the shared model and the plain containers (docs/protocol/31-block-entities-1-shared-model-and-containers.md;
*> US12 phase 44; core/copy/BESTATE.cpy). Pure and table-driven programs; the live entities are CORE-BE entries.
*>
*> Entry points of sections 1 to 4:
*>   BE-SCOPE USING event id out, type count out                      section 1: the container block event id (1), 49 types
*>   BE-TYPE-INFO USING type, key out (X(24)), key length out, operator-only out    section 3.1 and 3.2 (key "" when out of range)
*>   BE-TYPE-ID USING key (X(24)), key length, type out (-1 unknown)
*>   BE-VALID-BLOCK USING type, block key (X(48), "minecraft:..."), key length, result out (1 valid, 0 not)   section 3.1
*>   BE-CREATE USING dim, x, y, z, type, block key (X(48)), key length, index out (0 refused)   section 2.1: construction validates
*>   BE-SET-CHANGED USING index, state is air (1/0), update neighbours out (1/0)   section 2.4
*>   BE-SET-REMOVED USING index, flag                                 section 2.4 (setRemoved / clearRemoved)
*>   BE-POS-FROM-TAG USING chunk x, chunk z, tag x, y, z, x out, y out, z out, relocated out   section 2.3
*>   BE-SAVE USING index, form (0 without metadata, 1 full metadata, 2 custom only, 3 with id), PB-BUFFER   section 2.2, 4:
*>        the entries of the compound (the caller writes the begin and end tags)
*>   BE-LOAD USING index, PB-BUFFER                                   section 2.3 step 3, 4: reads the entries up to the End tag

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SCOPE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-COUNT.
     MOVE 1 TO L-EVENT
     MOVE 49 TO L-COUNT
     GOBACK.
 END PROGRAM BE-SCOPE.

*> BE-TYPE-ROW USING type, row out (X(126): key X(24), operator-only digit, family code, exact block names), the row of the table
 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TYPE-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(126) VALUE "furnace                 0 |furnace|                                                                                           ".
    05 FILLER PIC X(126) VALUE "chest                   0C|chest|                                                                                             ".
    05 FILLER PIC X(126) VALUE "trapped_chest           0 |trapped_chest|                                                                                     ".
    05 FILLER PIC X(126) VALUE "ender_chest             0 |ender_chest|                                                                                       ".
    05 FILLER PIC X(126) VALUE "jukebox                 0 |jukebox|                                                                                           ".
    05 FILLER PIC X(126) VALUE "dispenser               0 |dispenser|                                                                                         ".
    05 FILLER PIC X(126) VALUE "dropper                 0 |dropper|                                                                                           ".
    05 FILLER PIC X(126) VALUE "sign                    1S|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "hanging_sign            1H|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "mob_spawner             1 |spawner|                                                                                           ".
    05 FILLER PIC X(126) VALUE "creaking_heart          0 |creaking_heart|                                                                                    ".
    05 FILLER PIC X(126) VALUE "piston                  0 |moving_piston|                                                                                     ".
    05 FILLER PIC X(126) VALUE "brewing_stand           0 |brewing_stand|                                                                                     ".
    05 FILLER PIC X(126) VALUE "enchanting_table        0 |enchanting_table|                                                                                  ".
    05 FILLER PIC X(126) VALUE "end_portal              0 |end_portal|                                                                                        ".
    05 FILLER PIC X(126) VALUE "beacon                  0 |beacon|                                                                                            ".
    05 FILLER PIC X(126) VALUE "skull                   0K|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "daylight_detector       0 |daylight_detector|                                                                                 ".
    05 FILLER PIC X(126) VALUE "hopper                  0 |hopper|                                                                                            ".
    05 FILLER PIC X(126) VALUE "comparator              0 |comparator|                                                                                        ".
    05 FILLER PIC X(126) VALUE "banner                  0B|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "structure_block         0 |structure_block|                                                                                   ".
    05 FILLER PIC X(126) VALUE "end_gateway             0 |end_gateway|                                                                                       ".
    05 FILLER PIC X(126) VALUE "command_block           1 |command_block|chain_command_block|repeating_command_block|                                         ".
    05 FILLER PIC X(126) VALUE "shulker_box             0X|shulker_box|                                                                                       ".
    05 FILLER PIC X(126) VALUE "conduit                 0 |conduit|                                                                                           ".
    05 FILLER PIC X(126) VALUE "barrel                  0 |barrel|                                                                                            ".
    05 FILLER PIC X(126) VALUE "smoker                  0 |smoker|                                                                                            ".
    05 FILLER PIC X(126) VALUE "blast_furnace           0 |blast_furnace|                                                                                     ".
    05 FILLER PIC X(126) VALUE "lectern                 1 |lectern|                                                                                           ".
    05 FILLER PIC X(126) VALUE "bell                    0 |bell|                                                                                              ".
    05 FILLER PIC X(126) VALUE "jigsaw                  0 |jigsaw|                                                                                            ".
    05 FILLER PIC X(126) VALUE "campfire                0 |campfire|soul_campfire|                                                                            ".
    05 FILLER PIC X(126) VALUE "beehive                 0 |bee_nest|beehive|                                                                                  ".
    05 FILLER PIC X(126) VALUE "sculk_sensor            0 |sculk_sensor|                                                                                      ".
    05 FILLER PIC X(126) VALUE "calibrated_sculk_sensor 0 |calibrated_sculk_sensor|                                                                           ".
    05 FILLER PIC X(126) VALUE "sculk_catalyst          0 |sculk_catalyst|                                                                                    ".
    05 FILLER PIC X(126) VALUE "sculk_shrieker          0 |sculk_shrieker|                                                                                    ".
    05 FILLER PIC X(126) VALUE "chiseled_bookshelf      0 |chiseled_bookshelf|                                                                                ".
    05 FILLER PIC X(126) VALUE "shelf                   0F|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "brushable_block         0 |suspicious_sand|suspicious_gravel|                                                                 ".
    05 FILLER PIC X(126) VALUE "decorated_pot           0 |decorated_pot|                                                                                     ".
    05 FILLER PIC X(126) VALUE "crafter                 0 |crafter|                                                                                           ".
    05 FILLER PIC X(126) VALUE "trial_spawner           1 |trial_spawner|                                                                                     ".
    05 FILLER PIC X(126) VALUE "vault                   0 |vault|                                                                                             ".
    05 FILLER PIC X(126) VALUE "test_block              0 |test_block|                                                                                        ".
    05 FILLER PIC X(126) VALUE "test_instance_block     0 |test_instance_block|                                                                               ".
    05 FILLER PIC X(126) VALUE "copper_golem_statue     0G|                                                                                                   ".
    05 FILLER PIC X(126) VALUE "potent_sulfur           0 |potent_sulfur|                                                                                     ".

 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 49 TIMES.
       10 WS-KEY             PIC X(24).
       10 WS-OP              PIC 9.
       10 WS-FAMILY          PIC X.
       10 WS-LIST            PIC X(100).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-ROW                  PIC X(126).
 PROCEDURE DIVISION USING L-TYPE L-ROW.
     MOVE WS-ROW(L-TYPE + 1) TO L-ROW
     GOBACK.
 END PROGRAM BE-TYPE-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TYPE-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 WS-KEY             PIC X(24).
    05 WS-OP              PIC 9.
    05 WS-FAMILY          PIC X.
    05 WS-LIST            PIC X(100).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KEY L-KEY-LENGTH L-OP.
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-KEY-LENGTH L-OP
     IF L-TYPE < 0 OR L-TYPE > 48
         GOBACK
     END-IF
     CALL "BE-TYPE-ROW" USING L-TYPE WS-TAB
     MOVE WS-KEY TO L-KEY
     MOVE WS-OP TO L-OP
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY)) TO L-KEY-LENGTH
     GOBACK.
 END PROGRAM BE-TYPE-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TYPE-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-KEY-LENGTH L-TYPE.
     MOVE -1 TO L-TYPE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 48
         CALL "BE-TYPE-INFO" USING WS-I WS-KEY WS-LENGTH WS-OP
         IF WS-KEY = L-KEY AND WS-LENGTH = L-KEY-LENGTH
             MOVE WS-I TO L-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-TYPE-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-VALID-BLOCK.
*> The valid blocks of a type (31-1 section 3.1): an exact block name of its row, or a family: copper chests and copper golem
*> statues (optional waxed_, optional weathering prefix), a wood, colour or skull-kind name with one of the family suffixes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FAMILIES.
    05 FILLER PIC X(22) VALUE "S_wall_sign        10W".
    05 FILLER PIC X(22) VALUE "S_sign             05W".
    05 FILLER PIC X(22) VALUE "H_wall_hanging_sign18W".
    05 FILLER PIC X(22) VALUE "H_hanging_sign     13W".
    05 FILLER PIC X(22) VALUE "B_wall_banner      12C".
    05 FILLER PIC X(22) VALUE "B_banner           07C".
    05 FILLER PIC X(22) VALUE "X_shulker_box      12C".
    05 FILLER PIC X(22) VALUE "F_shelf            06W".
    05 FILLER PIC X(22) VALUE "K_wall_skull       11S".
    05 FILLER PIC X(22) VALUE "K_skull            06S".
    05 FILLER PIC X(22) VALUE "K_wall_head        10H".
    05 FILLER PIC X(22) VALUE "K_head             05H".
 01 FILLER REDEFINES WS-FAMILIES.
    05 WS-FAM OCCURS 12 TIMES.
       10 WS-FAM-CODE        PIC X.
       10 WS-FAM-SUFFIX      PIC X(18).
       10 WS-FAM-LENGTH      PIC 99.
       10 WS-FAM-LIST        PIC X.
 01 WS-WOODS               PIC X(120) VALUE "|oak|spruce|birch|acacia|cherry|jungle|dark_oak|pale_oak|crimson|warped|mangrove|bamboo|poplar|".
 01 WS-COLOURS             PIC X(150) VALUE "|white|orange|magenta|light_blue|yellow|lime|pink|gray|light_gray|cyan|purple|blue|brown|green|red|black|".
 01 WS-SKULLS              PIC X(40) VALUE "|skeleton|wither_skeleton|".
 01 WS-HEADS               PIC X(60) VALUE "|zombie|creeper|dragon|player|piglin|".
 01 WS-WEATHER             PIC X(30) VALUE "exposed_  weathered_oxidized_ ".
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-BASE                PIC X(48).
 01 WS-BASE-LENGTH         BINARY-LONG.
 01 WS-PROBE               PIC X(52).
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SL                  BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-CORE                PIC X(24).
 01 WS-CORE-LENGTH         BINARY-LONG.
 01 WS-ROWKEY              PIC X(24).
 01 WS-ROWLEN              BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-FAMILY              PIC X.
 01 WS-LIST                PIC X(100).
 01 WS-TAB                 PIC X(126).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KEY L-KEY-LENGTH L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-TYPE < 0 OR L-TYPE > 48 OR L-KEY-LENGTH < 12 OR L-KEY(1:10) NOT = "minecraft:"
         GOBACK
     END-IF
     COMPUTE WS-NAME-LENGTH = L-KEY-LENGTH - 10
     MOVE SPACES TO WS-NAME
     MOVE L-KEY(11:WS-NAME-LENGTH) TO WS-NAME
     CALL "BE-TYPE-ROW" USING L-TYPE WS-TAB
     MOVE WS-TAB(26:1) TO WS-FAMILY
     MOVE WS-TAB(27:100) TO WS-LIST
     MOVE SPACES TO WS-PROBE
     STRING "|" WS-NAME(1:WS-NAME-LENGTH) "|" DELIMITED BY SIZE INTO WS-PROBE
     COMPUTE WS-SL = WS-NAME-LENGTH + 2
     MOVE 0 TO WS-COUNT
     INSPECT WS-LIST TALLYING WS-COUNT FOR ALL WS-PROBE(1:WS-SL)
     IF WS-COUNT > 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
*>   Copper chest and copper golem statue: waxed_ and one weathering prefix are optional.
     IF WS-FAMILY = "C" OR WS-FAMILY = "G"
         MOVE "copper_chest" TO WS-CORE
         MOVE 12 TO WS-CORE-LENGTH
         IF WS-FAMILY = "G"
             MOVE "copper_golem_statue" TO WS-CORE
             MOVE 19 TO WS-CORE-LENGTH
         END-IF
         MOVE 1 TO WS-START
         IF WS-NAME-LENGTH > 6 AND WS-NAME(1:6) = "waxed_"
             MOVE 7 TO WS-START
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             COMPUTE WS-K = (WS-I - 1) * 10 + 1
             MOVE WS-WEATHER(WS-K:10) TO WS-ROWKEY
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROWKEY)) TO WS-ROWLEN
             COMPUTE WS-SL = WS-NAME-LENGTH - WS-START + 1
             IF WS-SL > WS-ROWLEN AND WS-NAME(WS-START:WS-ROWLEN) = WS-ROWKEY(1:WS-ROWLEN)
                 COMPUTE WS-START = WS-START + WS-ROWLEN
                 EXIT PERFORM
             END-IF
         END-PERFORM
         COMPUTE WS-SL = WS-NAME-LENGTH - WS-START + 1
         IF WS-SL = WS-CORE-LENGTH AND WS-NAME(WS-START:WS-SL) = WS-CORE(1:WS-CORE-LENGTH)
             MOVE 1 TO L-RESULT
         END-IF
         GOBACK
     END-IF
*>   Suffix families: the part before the suffix must be a member of the family's list.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF WS-FAM-CODE(WS-I) = WS-FAMILY AND L-RESULT = 0
             MOVE WS-FAM-LENGTH(WS-I) TO WS-SL
             COMPUTE WS-BASE-LENGTH = WS-NAME-LENGTH - WS-SL
             IF WS-BASE-LENGTH > 0 AND WS-NAME(WS-BASE-LENGTH + 1:WS-SL) = WS-FAM-SUFFIX(WS-I)(1:WS-SL)
                 MOVE SPACES TO WS-PROBE
                 STRING "|" WS-NAME(1:WS-BASE-LENGTH) "|" DELIMITED BY SIZE INTO WS-PROBE
                 COMPUTE WS-SL = WS-BASE-LENGTH + 2
                 MOVE 0 TO WS-COUNT
                 EVALUATE WS-FAM-LIST(WS-I)
                     WHEN "W" INSPECT WS-WOODS TALLYING WS-COUNT FOR ALL WS-PROBE(1:WS-SL)
                     WHEN "C" INSPECT WS-COLOURS TALLYING WS-COUNT FOR ALL WS-PROBE(1:WS-SL)
                     WHEN "S" INSPECT WS-SKULLS TALLYING WS-COUNT FOR ALL WS-PROBE(1:WS-SL)
                     WHEN OTHER INSPECT WS-HEADS TALLYING WS-COUNT FOR ALL WS-PROBE(1:WS-SL)
                 END-EVALUATE
                 IF WS-COUNT > 0
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-VALID-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CREATE.
*> Construction validates the block against the type's valid set (31-1 2.1, 3.1): a refused entity gives index 0. A free CORE-BE entry
*> is cleared and filled; BE-DIM 0 makes a detached entity (no level).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE L-KEY L-KEY-LENGTH L-INDEX.
     MOVE 0 TO L-INDEX
     CALL "BE-VALID-BLOCK" USING L-TYPE L-KEY L-KEY-LENGTH WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX OR L-INDEX > 0
         IF BE-USED(WS-I) = 0
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     IF L-INDEX > 0
         INITIALIZE BE-ENTRY(L-INDEX)
         MOVE 1 TO BE-USED(L-INDEX)
         MOVE L-DIM TO BE-DIM(L-INDEX)
         MOVE L-X TO BE-X(L-INDEX)
         MOVE L-Y TO BE-Y(L-INDEX)
         MOVE L-Z TO BE-Z(L-INDEX)
         MOVE L-TYPE TO BE-TYPE(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SET-CHANGED.
*> setChanged (31-1 2.4): an entity with a level marks its chunk unsaved (BE-CHANGED) and, when the cached state is not air, asks the
*> caller to update the neighbours for the output signal. Nothing is sent to clients.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-AIR L-NEIGHBOURS.
     MOVE 0 TO L-NEIGHBOURS
     IF BE-DIM(L-INDEX) > 0
         MOVE 1 TO BE-CHANGED(L-INDEX)
         IF L-AIR = 0
             MOVE 1 TO L-NEIGHBOURS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-SET-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SET-REMOVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FLAG.
     MOVE L-FLAG TO BE-REMOVED(L-INDEX)
     GOBACK.
 END PROGRAM BE-SET-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-POS-FROM-TAG.
*> getPosFromTag (31-1 2.3): a tag position outside the chunk is relocated to the chunk's own block x and z for the offsets 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OUT-X                BINARY-LONG.
 01 L-OUT-Y                BINARY-LONG.
 01 L-OUT-Z                BINARY-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-X L-Y L-Z L-OUT-X L-OUT-Y L-OUT-Z L-MOVED.
     COMPUTE WS-OX = FUNCTION MOD(L-X, 16)
     COMPUTE WS-OZ = FUNCTION MOD(L-Z, 16)
     COMPUTE WS-TX = (L-X - WS-OX) / 16
     COMPUTE WS-TZ = (L-Z - WS-OZ) / 16
     MOVE L-X TO L-OUT-X
     MOVE L-Y TO L-OUT-Y
     MOVE L-Z TO L-OUT-Z
     MOVE 0 TO L-MOVED
     IF WS-TX NOT = L-CX OR WS-TZ NOT = L-CZ
         MOVE 1 TO L-MOVED
         COMPUTE L-OUT-X = L-CX * 16 + WS-OX
         COMPUTE L-OUT-Z = L-CZ * 16 + WS-OZ
     END-IF
     GOBACK.
 END PROGRAM BE-POS-FROM-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SAVE.
*> The save forms of 31-1 2.2 and the keys of section 4 for the container types (chest, trapped chest, shulker box, barrel).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-ID                  PIC X(40).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-FORM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FORM PB-BUFFER.
     MOVE BE-TYPE(L-INDEX) TO WS-TYPE
     IF WS-TYPE = 1 OR WS-TYPE = 2 OR WS-TYPE = 24 OR WS-TYPE = 26
         IF BE-LOCK-LENGTH(L-INDEX) > 0
             MOVE "lock" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
             MOVE "items" TO WN MOVE 5 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BE-LOCK(L-INDEX) BE-LOCK-LENGTH(L-INDEX)
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
         IF BE-NAME-LENGTH(L-INDEX) > 0
             MOVE "CustomName" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BE-NAME(L-INDEX) BE-NAME-LENGTH(L-INDEX)
         END-IF
         IF BE-LOOT-LENGTH(L-INDEX) > 0
             MOVE "LootTable" TO WN MOVE 9 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL BE-LOOT(L-INDEX) BE-LOOT-LENGTH(L-INDEX)
             IF BE-SEED(L-INDEX) NOT = 0
                 MOVE "LootTableSeed" TO WN MOVE 13 TO WL
                 CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL BE-SEED(L-INDEX)
             END-IF
         ELSE
             MOVE 0 TO WS-N
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
                 IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                     ADD 1 TO WS-N
                 END-IF
             END-PERFORM
             IF WS-N > 0 OR WS-TYPE NOT = 24
                 MOVE "Items" TO WN MOVE 5 TO WL
                 IF WS-N = 0
                     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-NONE WS-N
                 ELSE
                     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-N
                 END-IF
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
                     IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
                         COMPUTE WS-SLOT = WS-S - 1
                         MOVE "Slot" TO WN MOVE 4 TO WL
                         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-SLOT
                         CALL "KX-PATCH-KEEP" USING BE-SLOT-VAR(L-INDEX, WS-S) WS-KP
                         CALL "PNBT-STACK-WRITE" USING PB-BUFFER BE-SLOT-ITEM(L-INDEX, WS-S)
                             BE-SLOT-COUNT(L-INDEX, WS-S) WS-KP
                         CALL "KX-PATCH-FREE" USING WS-KP
                         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-IF
     IF L-FORM NOT = 2
         MOVE "components" TO WN MOVE 10 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     IF L-FORM = 1 OR L-FORM = 3
         CALL "BE-TYPE-INFO" USING WS-TYPE WS-KEY WS-KEY-LENGTH WS-OP
         MOVE SPACES TO WS-ID
         STRING "minecraft:" WS-KEY(1:WS-KEY-LENGTH) DELIMITED BY SIZE INTO WS-ID
         COMPUTE WS-ID-LENGTH = WS-KEY-LENGTH + 10
         MOVE "id" TO WN MOVE 2 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID WS-ID-LENGTH
     END-IF
     IF L-FORM = 1
         MOVE "x" TO WN MOVE 1 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-X(L-INDEX)
         MOVE "y" TO WN
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-Y(L-INDEX)
         MOVE "z" TO WN
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-Z(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-LOAD.
*> loadAdditional of the container types (31-1 2.3, section 4): absent keys read as defaults, a present LootTable hides Items, a Slot
*> outside 0 to 26 is skipped, components and the metadata keys are skipped (the caller took the position from them).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-LOOT-SEEN           BINARY-LONG.
 01 WS-CAP48               BINARY-LONG VALUE 48.
 01 WS-CAP64               BINARY-LONG VALUE 64.
 01 WS-CONTAINER           BINARY-LONG.
 01 WS-TEMP.
    05 WS-T-SLOT OCCURS 27 TIMES.
       10 WS-T-ITEM        BINARY-LONG.
       10 WS-T-COUNT       BINARY-LONG.
       10 WS-T-VAR         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE BE-TYPE(L-INDEX) TO WS-S
     MOVE 0 TO WS-CONTAINER
     IF WS-S = 1 OR WS-S = 2 OR WS-S = 24 OR WS-S = 26
         MOVE 1 TO WS-CONTAINER
     END-IF
     MOVE SPACES TO BE-LOCK(L-INDEX) BE-NAME(L-INDEX) BE-LOOT(L-INDEX)
     MOVE 0 TO BE-LOCK-LENGTH(L-INDEX) BE-NAME-LENGTH(L-INDEX) BE-LOOT-LENGTH(L-INDEX) BE-SEED(L-INDEX)
     INITIALIZE WS-TEMP
     MOVE 0 TO WS-LOOT-SEEN
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-CONTAINER = 1 AND WN = "lock" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN WS-NAME-CAPACITY WL
                     IF WS-TYPE2 = 0
                         EXIT PERFORM
                     END-IF
                     IF WN = "items" AND WS-TYPE2 = 8
                         MOVE SPACES TO BE-LOCK(L-INDEX)
                         CALL "NBT-READ-STRING" USING PB-BUFFER BE-LOCK(L-INDEX) WS-CAP48 BE-LOCK-LENGTH(L-INDEX)
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                     END-IF
                 END-PERFORM
             WHEN WS-CONTAINER = 1 AND WN = "CustomName" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER BE-NAME(L-INDEX) WS-CAP64 BE-NAME-LENGTH(L-INDEX)
             WHEN WS-CONTAINER = 1 AND WN = "LootTable" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER BE-LOOT(L-INDEX) WS-CAP64 BE-LOOT-LENGTH(L-INDEX)
                 IF BE-LOOT-LENGTH(L-INDEX) > 0
                     MOVE 1 TO WS-LOOT-SEEN
                 END-IF
             WHEN WS-CONTAINER = 1 AND WN = "LootTableSeed" AND WS-TYPE = 4
                 CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
             WHEN WS-CONTAINER = 1 AND WN = "Items" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ET WS-COUNT
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
                     CALL "PNBT-STACK-READ" USING PB-BUFFER WS-SLOT WS-ITEM WS-ICOUNT WS-KP
                     CALL "KX-PATCH-TAKE" USING WS-KP WS-HANDLE
                     CALL "KX-PATCH-FREE" USING WS-KP
                     IF WS-SLOT >= 0 AND WS-SLOT <= 26 AND WS-ITEM > 0 AND WS-ICOUNT > 0
                         COMPUTE WS-S = WS-SLOT + 1
                         MOVE WS-ITEM TO WS-T-ITEM(WS-S)
                         MOVE WS-ICOUNT TO WS-T-COUNT(WS-S)
                         MOVE WS-HANDLE TO WS-T-VAR(WS-S)
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
         IF WS-LOOT-SEEN = 0
             MOVE WS-T-ITEM(WS-S) TO BE-SLOT-ITEM(L-INDEX, WS-S)
             MOVE WS-T-COUNT(WS-S) TO BE-SLOT-COUNT(L-INDEX, WS-S)
             MOVE WS-T-VAR(WS-S) TO BE-SLOT-VAR(L-INDEX, WS-S)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-LOAD.

*> Sections 5 to 8 entry points:
*>   BE-SYNC-INFO USING type, tag kind out, packet flag out           5.2: kind 0 empty tag, 1 custom only, 2 without metadata (banner),
*>        3 spawner (custom only minus SpawnPotentials), 4 brushable, 5 campfire, 6 shelf, 7 trial spawner, 8 vault; packet 1 when the
*>        type overrides getUpdatePacket (the kinds 4 to 8 write no entries until their parts 31-4, 31-6 and 31-7 define the data)
*>   BE-DATA-PACKET USING index, PB-BUFFER, written out               5.1: Position, type id and the update tag compound
*>   BE-CHUNK-ENTRY USING index, packed xz out, y out, type out, tag present out    5.3
*>   BE-SAVE-CHUNK USING index, PB-BUFFER                             6 step 1: the full form plus keepPacked (false)
*>   BE-LOAD-CHUNK-ENTRY USING PB-BUFFER, dim, chunk x, chunk z, block key (X(48), the block at the entry's position), key length,
*>        result out (0 loaded, 1 pending (keepPacked), 2 invalid type dropped, 3 creation refused), index out    6 step 2, 2.3
*>   BE-SET-BLOCK-ENTITY USING index, state allows (1/0), result out   6 step 4
*>   BE-TICKER-FOR USING given type, expected type, result out         7
*>   BE-TICKS-ON USING type, side (0 server, 1 client), result out     7
*>   BE-OPEN-INC / BE-OPEN-DEC / BE-OPEN-RECHECK / BE-SEARCH-INFLATE  8.2 (effects in BEFX.cpy)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SYNC-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND L-PACKET.
     MOVE 0 TO L-KIND L-PACKET
     EVALUATE L-TYPE
         WHEN 20
             MOVE 2 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 7 WHEN 8 WHEN 10 WHEN 15 WHEN 16 WHEN 21 WHEN 22 WHEN 25 WHEN 31 WHEN 41 WHEN 45 WHEN 46
             MOVE 1 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 9
             MOVE 3 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 40
             MOVE 4 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 32
             MOVE 5 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 39
             MOVE 6 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 43
             MOVE 7 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 44
             MOVE 8 TO L-KIND
             MOVE 1 TO L-PACKET
         WHEN 47
             MOVE 1 TO L-PACKET
         WHEN 11
             MOVE 1 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-SYNC-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TAG-ENTRIES.
*> The entries of the update tag (31-1 5.2), by kind; kinds 4 to 8 await their parts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-FORM                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     CALL "BE-SYNC-INFO" USING BE-TYPE(L-INDEX) WS-KIND WS-PACKET
     EVALUATE WS-KIND
         WHEN 2
             MOVE 0 TO WS-FORM
             CALL "BE-SAVE" USING L-INDEX WS-FORM PB-BUFFER
         WHEN 1 WHEN 3
             MOVE 2 TO WS-FORM
             CALL "BE-SAVE" USING L-INDEX WS-FORM PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-TAG-ENTRIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DATA-PACKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-KIND                BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-BYTES               PIC X(4096) BASED.
 01 WN                     PIC X.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER L-WRITTEN.
     MOVE 0 TO L-WRITTEN
     CALL "BE-SYNC-INFO" USING BE-TYPE(L-INDEX) WS-KIND WS-PACKET
     IF WS-PACKET = 0
         GOBACK
     END-IF
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING WK-BUFFER WN WS-ROOT
     CALL "BE-TAG-ENTRIES" USING L-INDEX WK-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING WK-BUFFER
     SET ADDRESS OF WS-BYTES TO WK-ADDR
     CALL "PB-PUT-BLOCK-ENTITY-DATA" USING PB-BUFFER BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) BE-TYPE(L-INDEX)
         WS-BYTES WK-LENGTH
     CALL "PB-FREE" USING WK-BUFFER
     MOVE 1 TO L-WRITTEN
     GOBACK.
 END PROGRAM BE-DATA-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHUNK-ENTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PACKED               BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PACKED L-Y L-TYPE L-PRESENT.
     COMPUTE L-PACKED = FUNCTION MOD(BE-X(L-INDEX), 16) * 16 + FUNCTION MOD(BE-Z(L-INDEX), 16)
     MOVE BE-Y(L-INDEX) TO L-Y
     MOVE BE-TYPE(L-INDEX) TO L-TYPE
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "BE-TAG-ENTRIES" USING L-INDEX WK-BUFFER
     MOVE 0 TO L-PRESENT
     IF WK-LENGTH > 0
         MOVE 1 TO L-PRESENT
     END-IF
     CALL "PB-FREE" USING WK-BUFFER
     GOBACK.
 END PROGRAM BE-CHUNK-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SAVE-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     CALL "BE-SAVE" USING L-INDEX WS-FORM PB-BUFFER
     MOVE "keepPacked" TO WN
     MOVE 10 TO WL
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-FALSE
     GOBACK.
 END PROGRAM BE-SAVE-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-LOAD-CHUNK-ENTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-ID                  PIC X(40).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-CAP40               BINARY-LONG VALUE 40.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-BE-TYPE             BINARY-LONG.
 01 WS-SHORT               PIC X(24).
 01 WS-SHORT-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-DIM L-CX L-CZ L-KEY L-KEY-LENGTH L-RESULT L-INDEX.
     MOVE 0 TO L-RESULT L-INDEX WS-X WS-Y WS-Z WS-KEEP WS-ID-LENGTH
     MOVE SPACES TO WS-ID
     MOVE PB-POS TO WS-START
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-CAP40 WS-ID-LENGTH
             WHEN WN = "x" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-X
             WHEN WN = "y" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-Y
             WHEN WN = "z" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-Z
             WHEN WN = "keepPacked" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-KEEP
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE PB-POS TO WS-END
     IF WS-KEEP NOT = 0
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     MOVE -1 TO WS-BE-TYPE
     IF WS-ID-LENGTH > 10 AND WS-ID(1:10) = "minecraft:"
         COMPUTE WS-SHORT-LENGTH = WS-ID-LENGTH - 10
         MOVE SPACES TO WS-SHORT
         MOVE WS-ID(11:WS-SHORT-LENGTH) TO WS-SHORT
         CALL "BE-TYPE-ID" USING WS-SHORT WS-SHORT-LENGTH WS-BE-TYPE
     END-IF
     IF WS-BE-TYPE < 0
         MOVE 2 TO L-RESULT
         GOBACK
     END-IF
     CALL "BE-POS-FROM-TAG" USING L-CX L-CZ WS-X WS-Y WS-Z WS-RX WS-RY WS-RZ WS-MOVED
     CALL "BE-CREATE" USING L-DIM WS-RX WS-RY WS-RZ WS-BE-TYPE L-KEY L-KEY-LENGTH L-INDEX
     IF L-INDEX = 0
         MOVE 3 TO L-RESULT
         GOBACK
     END-IF
     MOVE WS-START TO PB-POS
     CALL "BE-LOAD" USING L-INDEX PB-BUFFER
     MOVE WS-END TO PB-POS
     GOBACK.
 END PROGRAM BE-LOAD-CHUNK-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SET-BLOCK-ENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ALLOWED L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ALLOWED = 0
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     MOVE 0 TO BE-REMOVED(L-INDEX)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF WS-I NOT = L-INDEX AND BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = BE-DIM(L-INDEX)
                 AND BE-X(WS-I) = BE-X(L-INDEX) AND BE-Y(WS-I) = BE-Y(L-INDEX) AND BE-Z(WS-I) = BE-Z(L-INDEX)
             MOVE 1 TO BE-REMOVED(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-SET-BLOCK-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TICKER-FOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GIVEN                BINARY-LONG.
 01 L-EXPECTED             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-GIVEN L-EXPECTED L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-GIVEN = L-EXPECTED
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-TICKER-FOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TICKS-ON.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-SIDE L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE TRUE
         WHEN L-TYPE = 24
             MOVE 1 TO L-RESULT
         WHEN (L-TYPE = 1 OR L-TYPE = 2 OR L-TYPE = 3) AND L-SIDE = 1
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-TICKS-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-FX-CLEAR.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY BEFX.
 PROCEDURE DIVISION USING BE-FX.
     MOVE 0 TO FX-SOUND FX-EVENT FX-TICK FX-NEIGHBOURS
     MOVE -1 TO FX-BLOCK-EVENT FX-PROP
     GOBACK.
 END PROGRAM BE-FX-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-OPEN-FX.
*> The hooks that follow a change of the opener count from OLD to NEW (31-1 8.2): onOpen on 0 to more, onClose on more to 0
*> (sound, game event, the barrel's OPEN property), then openerCountChanged (block event 1 for the chest family and the ender
*> chest; neighbour updates for the trapped chest when the count differs).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-OLD L-NEW BE-FX.
     IF L-OLD = 0 AND L-NEW > 0
         MOVE 1 TO FX-SOUND FX-EVENT
         IF BE-TYPE(L-INDEX) = 26
             MOVE 1 TO FX-PROP
         END-IF
     END-IF
     IF L-NEW = 0 AND L-OLD > 0
         MOVE 2 TO FX-SOUND FX-EVENT
         IF BE-TYPE(L-INDEX) = 26
             MOVE 0 TO FX-PROP
         END-IF
     END-IF
     IF BE-TYPE(L-INDEX) = 1 OR BE-TYPE(L-INDEX) = 2 OR BE-TYPE(L-INDEX) = 3
         MOVE L-NEW TO FX-BLOCK-EVENT
     END-IF
     IF BE-TYPE(L-INDEX) = 2 AND L-OLD NOT = L-NEW
         MOVE 1 TO FX-NEIGHBOURS
     END-IF
     GOBACK.
 END PROGRAM BE-OPEN-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-OPEN-INC.
*> incrementOpeners USING index, interaction range (thousandths), spectator flag (8.1: ignored), effects.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-RANGE L-SPECTATOR BE-FX.
     CALL "BE-FX-CLEAR" USING BE-FX
     IF BE-REMOVED(L-INDEX) = 1 OR L-SPECTATOR = 1
         GOBACK
     END-IF
     MOVE BE-OPEN-COUNT(L-INDEX) TO WS-OLD
     ADD 1 TO BE-OPEN-COUNT(L-INDEX)
     IF WS-OLD = 0
         MOVE 5 TO FX-TICK
     END-IF
     CALL "BE-OPEN-FX" USING L-INDEX WS-OLD BE-OPEN-COUNT(L-INDEX) BE-FX
     IF L-RANGE > BE-OPEN-RANGE(L-INDEX)
         MOVE L-RANGE TO BE-OPEN-RANGE(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE-OPEN-INC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-OPEN-DEC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-SPECTATOR BE-FX.
     CALL "BE-FX-CLEAR" USING BE-FX
     IF BE-REMOVED(L-INDEX) = 1 OR L-SPECTATOR = 1
         GOBACK
     END-IF
     MOVE BE-OPEN-COUNT(L-INDEX) TO WS-OLD
     SUBTRACT 1 FROM BE-OPEN-COUNT(L-INDEX)
     IF BE-OPEN-COUNT(L-INDEX) = 0
         MOVE 0 TO BE-OPEN-RANGE(L-INDEX)
     END-IF
     CALL "BE-OPEN-FX" USING L-INDEX WS-OLD BE-OPEN-COUNT(L-INDEX) BE-FX
     GOBACK.
 END PROGRAM BE-OPEN-DEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-OPEN-RECHECK.
*> recheckOpeners USING index, number of users found, the largest interaction range among them (thousandths), effects.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-USERS                BINARY-LONG.
 01 L-MAX-RANGE            BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-USERS L-MAX-RANGE BE-FX.
     CALL "BE-FX-CLEAR" USING BE-FX
     MOVE BE-OPEN-COUNT(L-INDEX) TO WS-OLD
     MOVE 0 TO BE-OPEN-RANGE(L-INDEX)
     IF L-USERS > 0
         MOVE L-MAX-RANGE TO BE-OPEN-RANGE(L-INDEX)
         MOVE 5 TO FX-TICK
     END-IF
     MOVE L-USERS TO BE-OPEN-COUNT(L-INDEX)
     CALL "BE-OPEN-FX" USING L-INDEX WS-OLD L-USERS BE-FX
     GOBACK.
 END PROGRAM BE-OPEN-RECHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SEARCH-INFLATE.
*> The container user search box is inflated by the largest range plus 4.0 (thousandths).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-INFLATE              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-INFLATE.
     COMPUTE L-INFLATE = BE-OPEN-RANGE(L-INDEX) + 4000
     GOBACK.
 END PROGRAM BE-SEARCH-INFLATE.

*> Sections 9 to 13 entry points (index = a CORE-BE entry; slots are 0-based at the interface):
*>   BE-MAX-STACK USING item maximum, result out                        9.1: min(99, the item's own maximum)
*>   BE-SET-ITEM USING index, slot, item, count, patch handle, item maximum   9.2: stores the clamped stack and calls setChanged
*>   BE-REMOVE-ITEM USING index, slot, n, item out, count out           9.2: splits up to n; BE-REMOVE-NO-UPDATE USING index, slot, item out, count out
*>   BE-IS-EMPTY USING index, result out; BE-COUNT-ITEM USING index, item, total out    9.1
*>   BE-CAN-OPEN USING index, spectator, held item key (X(48)), key length, can out, notify out    9.2, 9.3 step 3
*>   BE-LOOT-UNPACK USING index, table out (X(64)), length out, seed out, result out    9.3: hands the table to the loot engine and clears the key
*>   BE-SIGNAL USING index, second half index (0 for a single container), signal out   9.5
*>   BE-DEFAULT-NAME USING type, key out (X(32)), length out; BE-CONTAINER-SIZE USING type, size out    9.2, 10.1, 11, 12, 13.1
*>   BE-CHEST-CONNECTED USING facing (0 N, 1 E, 2 S, 3 W), type (0 single, 1 left, 2 right), dx out, dz out   10.2
*>   BE-CHEST-MERGE USING type, facing, neighbour type, neighbour facing, neighbour is the same block, neighbour has an entity,
*>        blocked at self, blocked at neighbour, ignoreBlocked, result out (0 none, 1 single, 2 double), self is first out   10.2
*>   BE-CHEST-BLOCKED USING conductor above, sitting cat, result out; BE-DOUBLE-SLOT USING slot, half out (1, 2), local slot out
*>   BE-DOUBLE-NAME USING first index, second index, name out (X(64)), length out    10.2
*>   BE-TRIGGER-EVENT USING index, event id, parameter, handled out     2.4, 8.3, 10.1, 13.3
*>   BE-LID-TICK USING index                                            10.3 (client side state)
*>   BE-TRAPPED-POWER USING index, direction (1 up), power out          10.5; BE-CHEST-SOUND USING type, facing, play out, dx out, dz out (half units)
*>   BE-ENDER-OPEN USING entity present, conductor above, result out; BE-ENDER-VALID USING active present, active valid, simple valid, result out   11
*>   BE-BARREL-SOUND USING facing (0 down, 1 up, 2 north, 3 south, 4 west, 5 east), hx, hy, hz out (half units)   12
*>   BE-SHULKER-START / BE-SHULKER-STOP USING index, spectator, effects   13.3
*>   BE-SHULKER-TICK USING index, neighbour updates out, push entities out    13.2
*>   BE-SHULKER-FACE USING item is a shulker box, placing allowed out; BE-SHULKER-CAN-OPEN USING status, lid path collides, result out;
*>   BE-SHULKER-BREAK USING creative drops prevented, empty, result out (1 drop with contents, 2 unpack the loot table)   13.1, 13.4

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-MAX-STACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX L-RESULT.
     MOVE 99 TO L-RESULT
     IF L-MAX < 99
         MOVE L-MAX TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-MAX-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SET-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-COUNT L-VAR L-MAX.
     CALL "BE-MAX-STACK" USING L-MAX WS-LIMIT
     COMPUTE WS-S = L-SLOT + 1
     MOVE L-ITEM TO BE-SLOT-ITEM(L-INDEX, WS-S)
     MOVE L-COUNT TO BE-SLOT-COUNT(L-INDEX, WS-S)
     MOVE L-VAR TO BE-SLOT-VAR(L-INDEX, WS-S)
     IF L-COUNT > WS-LIMIT
         MOVE WS-LIMIT TO BE-SLOT-COUNT(L-INDEX, WS-S)
     END-IF
     CALL "BE-SET-CHANGED" USING L-INDEX WS-AIR WS-N
     GOBACK.
 END PROGRAM BE-SET-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-REMOVE-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-WANT L-ITEM L-COUNT.
     MOVE 0 TO L-ITEM L-COUNT
     IF L-SLOT < 0 OR L-SLOT > 26 OR L-WANT <= 0
         GOBACK
     END-IF
     COMPUTE WS-S = L-SLOT + 1
     IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
         GOBACK
     END-IF
     MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO L-ITEM
     MOVE L-WANT TO L-COUNT
     IF L-COUNT > BE-SLOT-COUNT(L-INDEX, WS-S)
         MOVE BE-SLOT-COUNT(L-INDEX, WS-S) TO L-COUNT
     END-IF
     SUBTRACT L-COUNT FROM BE-SLOT-COUNT(L-INDEX, WS-S)
     IF BE-SLOT-COUNT(L-INDEX, WS-S) = 0
         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
     END-IF
     CALL "BE-SET-CHANGED" USING L-INDEX WS-AIR WS-N
     GOBACK.
 END PROGRAM BE-REMOVE-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-REMOVE-NO-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SLOT L-ITEM L-COUNT.
     COMPUTE WS-S = L-SLOT + 1
     MOVE BE-SLOT-ITEM(L-INDEX, WS-S) TO L-ITEM
     MOVE BE-SLOT-COUNT(L-INDEX, WS-S) TO L-COUNT
     MOVE 0 TO BE-SLOT-ITEM(L-INDEX, WS-S) BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
     GOBACK.
 END PROGRAM BE-REMOVE-NO-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-IS-EMPTY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-RESULT.
     MOVE 1 TO L-RESULT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0
             MOVE 0 TO L-RESULT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-IS-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-COUNT-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ITEM L-TOTAL.
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF BE-SLOT-COUNT(L-INDEX, WS-S) > 0 AND BE-SLOT-ITEM(L-INDEX, WS-S) = L-ITEM
             ADD BE-SLOT-COUNT(L-INDEX, WS-S) TO L-TOTAL
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-COUNT-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CAN-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-HELD                 PIC X(48).
 01 L-HELD-LENGTH          BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SPECTATOR L-HELD L-HELD-LENGTH L-CAN L-NOTIFY.
     MOVE 0 TO L-CAN L-NOTIFY
     EVALUATE TRUE
         WHEN BE-LOOT-LENGTH(L-INDEX) > 0 AND L-SPECTATOR = 1
             CONTINUE
         WHEN BE-LOCK-LENGTH(L-INDEX) = 0 OR L-SPECTATOR = 1
             MOVE 1 TO L-CAN
         WHEN L-HELD-LENGTH = BE-LOCK-LENGTH(L-INDEX) AND L-HELD = BE-LOCK(L-INDEX)
             MOVE 1 TO L-CAN
         WHEN OTHER
             MOVE 1 TO L-NOTIFY
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-CAN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-LOOT-UNPACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TABLE                PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TABLE L-LENGTH L-SEED L-RESULT.
     MOVE 0 TO L-RESULT L-LENGTH
     MOVE SPACES TO L-TABLE
     MOVE BE-SEED(L-INDEX) TO L-SEED
     IF BE-LOOT-LENGTH(L-INDEX) > 0
         MOVE 1 TO L-RESULT
         MOVE BE-LOOT-LENGTH(L-INDEX) TO L-LENGTH
         MOVE BE-LOOT(L-INDEX) TO L-TABLE
         MOVE SPACES TO BE-LOOT(L-INDEX)
         MOVE 0 TO BE-LOOT-LENGTH(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE-LOOT-UNPACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SIGNAL.
*> getRedstoneSignalFromContainer in single precision: f = (sum count / max stack) / size; signal = floor(f * 14) + 1 when f > 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-SUM                 FLOAT-SHORT.
 01 WS-Q                   FLOAT-SHORT.
 01 WS-F                   FLOAT-SHORT.
 01 WS-HALF                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SECOND               BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SECOND L-SIGNAL.
     MOVE 0 TO WS-SUM L-SIGNAL
     MOVE 27 TO WS-SIZE
     IF L-SECOND > 0
         MOVE 54 TO WS-SIZE
     END-IF
     PERFORM VARYING WS-HALF FROM 1 BY 1 UNTIL WS-HALF > 2
         MOVE L-INDEX TO WS-ENTRY
         IF WS-HALF = 2
             MOVE L-SECOND TO WS-ENTRY
         END-IF
         IF WS-ENTRY > 0
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
                 IF BE-SLOT-COUNT(WS-ENTRY, WS-S) > 0
                     COMPUTE WS-MAX = BE-SLOT-ITEM(WS-ENTRY, WS-S) + 1
                     MOVE IT-MAX-STACK(WS-MAX) TO WS-MAX
                     CALL "BE-MAX-STACK" USING WS-MAX WS-LIMIT
                     COMPUTE WS-Q = BE-SLOT-COUNT(WS-ENTRY, WS-S) / WS-LIMIT
                     ADD WS-Q TO WS-SUM
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     COMPUTE WS-F = WS-SUM / WS-SIZE
     IF WS-F > 0
         COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-F * 14)
         COMPUTE L-SIGNAL = WS-FLOOR + 1
     END-IF
     GOBACK.
 END PROGRAM BE-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DEFAULT-NAME.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KEY L-LENGTH.
     MOVE SPACES TO L-KEY
     EVALUATE L-TYPE
         WHEN 1 WHEN 2
             MOVE "container.chest" TO L-KEY
         WHEN 3
             MOVE "container.enderchest" TO L-KEY
         WHEN 24
             MOVE "container.shulkerBox" TO L-KEY
         WHEN 26
             MOVE "container.barrel" TO L-KEY
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-KEY)) TO L-LENGTH
     IF L-KEY = SPACES
         MOVE 0 TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BE-DEFAULT-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CONTAINER-SIZE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-SIZE.
     MOVE 0 TO L-SIZE
     IF L-TYPE = 1 OR L-TYPE = 2 OR L-TYPE = 3 OR L-TYPE = 24 OR L-TYPE = 26
         MOVE 27 TO L-SIZE
     END-IF
     GOBACK.
 END PROGRAM BE-CONTAINER-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHEST-CONNECTED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-TYPE L-DX L-DZ.
     MOVE 0 TO L-DX L-DZ
     IF L-TYPE = 0
         GOBACK
     END-IF
     IF L-TYPE = 1
         COMPUTE WS-DIR = FUNCTION MOD(L-FACING + 1, 4)
     ELSE
         COMPUTE WS-DIR = FUNCTION MOD(L-FACING + 3, 4)
     END-IF
     EVALUATE WS-DIR
         WHEN 0 MOVE -1 TO L-DZ
         WHEN 1 MOVE 1 TO L-DX
         WHEN 2 MOVE 1 TO L-DZ
         WHEN OTHER MOVE -1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-CHEST-CONNECTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHEST-MERGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-NTYPE                BINARY-LONG.
 01 L-NFACING              BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-BLOCKED-SELF         BINARY-LONG.
 01 L-BLOCKED-NEIGHBOUR    BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FACING L-NTYPE L-NFACING L-SAME L-HAS L-BLOCKED-SELF L-BLOCKED-NEIGHBOUR
         L-IGNORE L-RESULT L-FIRST.
     MOVE 0 TO L-RESULT L-FIRST
     EVALUATE TRUE
         WHEN L-IGNORE = 0 AND L-BLOCKED-SELF = 1
             CONTINUE
         WHEN L-TYPE = 0
             MOVE 1 TO L-RESULT
         WHEN NOT (L-SAME = 1 AND L-NTYPE NOT = 0 AND L-NTYPE NOT = L-TYPE AND L-NFACING = L-FACING)
             MOVE 1 TO L-RESULT
         WHEN L-IGNORE = 0 AND L-BLOCKED-NEIGHBOUR = 1
             CONTINUE
         WHEN L-HAS = 0
             MOVE 1 TO L-RESULT
         WHEN OTHER
             MOVE 2 TO L-RESULT
             IF L-TYPE = 2
                 MOVE 1 TO L-FIRST
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-CHEST-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHEST-BLOCKED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CONDUCTOR L-CAT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-CONDUCTOR = 1 OR L-CAT = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-CHEST-BLOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DOUBLE-SLOT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 01 L-LOCAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-HALF L-LOCAL.
     MOVE 1 TO L-HALF
     MOVE L-SLOT TO L-LOCAL
     IF L-SLOT >= 27
         MOVE 2 TO L-HALF
         COMPUTE L-LOCAL = L-SLOT - 27
     END-IF
     GOBACK.
 END PROGRAM BE-DOUBLE-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-DOUBLE-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-SECOND               BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-SECOND L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     EVALUATE TRUE
         WHEN BE-NAME-LENGTH(L-FIRST) > 0
             MOVE BE-NAME(L-FIRST) TO L-NAME
             MOVE BE-NAME-LENGTH(L-FIRST) TO L-LENGTH
         WHEN BE-NAME-LENGTH(L-SECOND) > 0
             MOVE BE-NAME(L-SECOND) TO L-NAME
             MOVE BE-NAME-LENGTH(L-SECOND) TO L-LENGTH
         WHEN OTHER
             MOVE "container.chestDouble" TO L-NAME
             MOVE 21 TO L-LENGTH
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-DOUBLE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TRIGGER-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-PARAM                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-EVENT L-PARAM L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-EVENT NOT = 1
         GOBACK
     END-IF
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 1 WHEN 2 WHEN 3
             MOVE 0 TO BE-SHOULD-OPEN(L-INDEX)
             IF L-PARAM > 0
                 MOVE 1 TO BE-SHOULD-OPEN(L-INDEX)
             END-IF
             MOVE 1 TO L-HANDLED
         WHEN 24
             MOVE L-PARAM TO BE-OPEN-COUNT(L-INDEX)
             IF L-PARAM = 0
                 MOVE 3 TO BE-STATUS(L-INDEX)
             END-IF
             IF L-PARAM = 1
                 MOVE 1 TO BE-STATUS(L-INDEX)
             END-IF
             MOVE 1 TO L-HANDLED
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-TRIGGER-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-LID-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-STEP                FLOAT-SHORT VALUE 0.1.
 01 WS-V                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE BE-LID(L-INDEX) TO BE-LID-OLD(L-INDEX)
     IF BE-SHOULD-OPEN(L-INDEX) = 0 AND BE-LID(L-INDEX) > 0
         COMPUTE WS-V = BE-LID(L-INDEX) - WS-STEP
         IF WS-V < 0
             MOVE 0 TO WS-V
         END-IF
         MOVE WS-V TO BE-LID(L-INDEX)
     END-IF
     IF BE-SHOULD-OPEN(L-INDEX) = 1 AND BE-LID(L-INDEX) < 1
         COMPUTE WS-V = BE-LID(L-INDEX) + WS-STEP
         IF WS-V > 1
             MOVE 1 TO WS-V
         END-IF
         MOVE WS-V TO BE-LID(L-INDEX)
     END-IF
     GOBACK.
 END PROGRAM BE-LID-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TRAPPED-POWER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DIRECTION L-POWER.
     MOVE 0 TO L-POWER
     IF L-DIRECTION = 1
         MOVE BE-OPEN-COUNT(L-INDEX) TO L-POWER
         IF L-POWER > 15
             MOVE 15 TO L-POWER
         END-IF
         IF L-POWER < 0
             MOVE 0 TO L-POWER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE-TRAPPED-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-CHEST-SOUND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-PLAY                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FACING L-PLAY L-DX L-DZ.
     MOVE 1 TO L-PLAY
     MOVE 0 TO L-DX L-DZ
     IF L-TYPE = 1
         MOVE 0 TO L-PLAY
     END-IF
     IF L-TYPE = 2
         CALL "BE-CHEST-CONNECTED" USING L-FACING L-TYPE L-DX L-DZ
     END-IF
     GOBACK.
 END PROGRAM BE-CHEST-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-ENDER-OPEN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-CONDUCTOR L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ENTITY = 1 AND L-CONDUCTOR = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-ENDER-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-ENDER-VALID.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-ACTIVE-VALID         BINARY-LONG.
 01 L-SIMPLE               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-ACTIVE-VALID L-SIMPLE L-RESULT.
     MOVE L-SIMPLE TO L-RESULT
     IF L-ACTIVE = 1
         MOVE L-ACTIVE-VALID TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-ENDER-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-BARREL-SOUND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-HX                   BINARY-LONG.
 01 L-HY                   BINARY-LONG.
 01 L-HZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-HX L-HY L-HZ.
     MOVE 0 TO L-HX L-HY L-HZ
     EVALUATE L-FACING
         WHEN 0 MOVE -1 TO L-HY
         WHEN 1 MOVE 1 TO L-HY
         WHEN 2 MOVE -1 TO L-HZ
         WHEN 3 MOVE 1 TO L-HZ
         WHEN 4 MOVE -1 TO L-HX
         WHEN OTHER MOVE 1 TO L-HX
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-BARREL-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-SPECTATOR BE-FX.
     CALL "BE-FX-CLEAR" USING BE-FX
     IF BE-REMOVED(L-INDEX) = 1 OR L-SPECTATOR = 1
         GOBACK
     END-IF
     IF BE-OPEN-COUNT(L-INDEX) < 0
         MOVE 0 TO BE-OPEN-COUNT(L-INDEX)
     END-IF
     ADD 1 TO BE-OPEN-COUNT(L-INDEX)
     MOVE BE-OPEN-COUNT(L-INDEX) TO FX-BLOCK-EVENT
     IF BE-OPEN-COUNT(L-INDEX) = 1
         MOVE 1 TO FX-SOUND FX-EVENT
     END-IF
     GOBACK.
 END PROGRAM BE-SHULKER-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 COPY BEFX.
 PROCEDURE DIVISION USING L-INDEX L-SPECTATOR BE-FX.
     CALL "BE-FX-CLEAR" USING BE-FX
     IF BE-REMOVED(L-INDEX) = 1 OR L-SPECTATOR = 1
         GOBACK
     END-IF
     SUBTRACT 1 FROM BE-OPEN-COUNT(L-INDEX)
     MOVE BE-OPEN-COUNT(L-INDEX) TO FX-BLOCK-EVENT
     IF BE-OPEN-COUNT(L-INDEX) <= 0
         MOVE 2 TO FX-SOUND FX-EVENT
     END-IF
     GOBACK.
 END PROGRAM BE-SHULKER-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-STEP                FLOAT-SHORT VALUE 0.1.
 01 WS-V                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 01 L-PUSH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NEIGHBOURS L-PUSH.
     MOVE 0 TO L-NEIGHBOURS L-PUSH
     MOVE BE-PROGRESS(L-INDEX) TO BE-PROGRESS-OLD(L-INDEX)
     EVALUATE BE-STATUS(L-INDEX)
         WHEN 0
             MOVE 0 TO BE-PROGRESS(L-INDEX)
         WHEN 1
             COMPUTE WS-V = BE-PROGRESS(L-INDEX) + WS-STEP
             MOVE WS-V TO BE-PROGRESS(L-INDEX)
             IF BE-PROGRESS-OLD(L-INDEX) = 0
                 MOVE 1 TO L-NEIGHBOURS
             END-IF
             IF BE-PROGRESS(L-INDEX) >= 1
                 MOVE 2 TO BE-STATUS(L-INDEX)
                 MOVE 1 TO BE-PROGRESS(L-INDEX)
                 MOVE 1 TO L-NEIGHBOURS
             END-IF
             MOVE 1 TO L-PUSH
         WHEN 2
             MOVE 1 TO BE-PROGRESS(L-INDEX)
         WHEN OTHER
             COMPUTE WS-V = BE-PROGRESS(L-INDEX) - WS-STEP
             MOVE WS-V TO BE-PROGRESS(L-INDEX)
             IF BE-PROGRESS-OLD(L-INDEX) = 1
                 MOVE 1 TO L-NEIGHBOURS
             END-IF
             IF BE-PROGRESS(L-INDEX) <= 0
                 MOVE 0 TO BE-STATUS(L-INDEX)
                 MOVE 0 TO BE-PROGRESS(L-INDEX)
                 MOVE 1 TO L-NEIGHBOURS
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE-SHULKER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-FACE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IS-SHULKER           BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-SHULKER L-ALLOWED.
     MOVE 1 TO L-ALLOWED
     IF L-IS-SHULKER = 1
         MOVE 0 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM BE-SHULKER-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-CAN-OPEN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-COLLIDES             BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS L-COLLIDES L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-STATUS = 0 AND L-COLLIDES = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-SHULKER-CAN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-SHULKER-BREAK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PREVENT-DROPS        BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PREVENT-DROPS L-EMPTY L-RESULT.
     MOVE 2 TO L-RESULT
     IF L-PREVENT-DROPS = 1 AND L-EMPTY = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE-SHULKER-BREAK.
