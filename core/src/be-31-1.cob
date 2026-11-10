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
                         CALL "PNBT-STACK-WRITE" USING PB-BUFFER BE-SLOT-ITEM(L-INDEX, WS-S)
                             BE-SLOT-COUNT(L-INDEX, WS-S) BE-SLOT-VAR(L-INDEX, WS-S)
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
                     IF WS-SLOT >= 0 AND WS-SLOT <= 26 AND WS-ITEM > 0 AND WS-ICOUNT > 0
                         COMPUTE WS-S = WS-SLOT + 1
                         MOVE WS-ITEM TO WS-T-ITEM(WS-S)
                         MOVE WS-ICOUNT TO WS-T-COUNT(WS-S)
                         MOVE WS-KP TO WS-T-VAR(WS-S)
                     ELSE
                         CALL "KX-PATCH-FREE" USING WS-KP
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
         ELSE
             CALL "KX-PATCH-FREE" USING WS-T-VAR(WS-S)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-LOAD.
