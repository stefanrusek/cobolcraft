*> The built-in block layer of the cobolcraft world type (T0203; docs/design/standin-content.md section 1.1 and
*> 1.2, cobolcraft-standard-core.md section 5.1): twelve blocks, eighteen states (state ids 0 to 17), as rows
*> of the same CT-BLOCK-ROW shape the generated standard table has. Values are transcribed from the table of
*> core section 5.1 (columns of 24 section 7); the crafting bench (block 12, state 18) belongs to the
*> bench phase. Each line below is one row, its columns separated by "|", in the order of CT-BLOCK-ROW;
*> an empty column is blank.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-BLOCK-ROW.
*> USING block id (BINARY-LONG), row out (PIC X(684)), status out (CT-OK; CT-NOT-FOUND for an id outside 0 to 11,
*> the row left as it was), count out (BINARY-LONG: 12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(190) VALUE "0|cobolcraft:void|AirBlock||1|0|0|0.0|0.0|no|0|NONE|STONE|PUSH_PULL|HARP|replaceable noCollision noLootTable air".
    05 FILLER PIC X(190) VALUE "1|cobolcraft:baseplate|Block||1|1|1|-1.0|3600000.0|no|0|STONE|STONE|PUSH_PULL|BASEDRUM|noLootTable validSpawn:never".
    05 FILLER PIC X(190) VALUE "2|cobolcraft:greystone|Block||1|2|2|1.5|6.0|no|0|STONE|STONE|PUSH_PULL|BASEDRUM|".
    05 FILLER PIC X(190) VALUE "3|cobolcraft:loam|Block||1|3|3|0.5|0.5|no|0|DIRT|GRAVEL|PUSH_PULL|HARP|".
    05 FILLER PIC X(190) VALUE "4|cobolcraft:turf|Block||1|4|4|0.6|0.6|no|0|GRASS|GRASS|PUSH_PULL|HARP|".
    05 FILLER PIC X(190) VALUE "5|cobolcraft:grit|Block||1|5|5|0.5|0.5|no|0|SAND|SAND|PUSH_PULL|SNARE|".
    05 FILLER PIC X(190) VALUE "6|cobolcraft:cardstack|Block|axis[x/y/z] punched[true/false]|6|6|9|0.7|0.7|no|0|WOOD|WOOD|PUSH_PULL|BASS|".
    05 FILLER PIC X(190) VALUE "7|cobolcraft:lucite|TransparentBlock||1|12|12|0.3|0.3|no|0|NONE|GLASS|PUSH_PULL|HAT|noOcclusion validSpawn:never suffocating:never redstoneConductor:never".
    05 FILLER PIC X(190) VALUE "8|cobolcraft:glowtube|Block|lit[true/false]|2|13|13|0.2|0.2|no|15 if lit, else 0|COLOR_YELLOW|GLASS|PUSH_PULL|HAT|".
    05 FILLER PIC X(190) VALUE "9|cobolcraft:ledger_tile|Block||1|15|15|0.8|0.8|no|0|STONE|STONE|PUSH_PULL|BASEDRUM|".
    05 FILLER PIC X(190) VALUE "10|cobolcraft:goto_pad|Block||1|16|16|1.3|1.3|no|6|METAL|METAL|PUSH_PULL|HARP|".
    05 FILLER PIC X(190) VALUE "11|cobolcraft:slag|Block||1|17|17|0.4|0.4|no|0|NETHER|NETHERRACK|PUSH_PULL|BASEDRUM|".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-LINE             PIC X(190) OCCURS 12 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BUILT.
    05 WS-B-ID             PIC X(4).
    05 WS-B-KEY            PIC X(35).
    05 WS-B-CLASS          PIC X(32).
    05 WS-B-PROPS          PIC X(153).
    05 WS-B-COUNT          PIC X(4).
    05 WS-B-FIRST          PIC X(5).
    05 WS-B-DEFAULT        PIC X(5).
    05 WS-B-HARDNESS       PIC X(21).
    05 WS-B-BLAST          PIC X(9).
    05 WS-B-TOOL           PIC X(3).
    05 WS-B-LIGHT          PIC X(41).
    05 WS-B-MAP            PIC X(50).
    05 WS-B-SOUND          PIC X(150).
    05 WS-B-PUSH           PIC X(10).
    05 WS-B-INSTRUMENT     PIC X(15).
    05 WS-B-FLAGS          PIC X(147).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(684).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE 12 TO L-COUNT
     IF L-ID < 0 OR L-ID > 11
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-INDEX = L-ID + 1
     MOVE SPACES TO WS-BUILT
     UNSTRING WS-LINE(WS-INDEX) DELIMITED BY "|" INTO WS-B-ID WS-B-KEY WS-B-CLASS WS-B-PROPS
         WS-B-COUNT WS-B-FIRST WS-B-DEFAULT WS-B-HARDNESS WS-B-BLAST WS-B-TOOL WS-B-LIGHT WS-B-MAP
         WS-B-SOUND WS-B-PUSH WS-B-INSTRUMENT WS-B-FLAGS
     MOVE WS-BUILT TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM BUILTIN-BLOCK-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-BLOCK-TAGS.
*> No parameters: binds the built-in block tags of the cobolcraft set (cobolcraft-standard-core.md section 4.1 and 4.4;
*> members are block ids, not state ids) with TAG-PUT: the two mineable classes, replaceable, air, and
*> causes_suffocation with the four blocks_motion tags (every block but void). The crafting bench joins the
*> lists in the bench phase.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAGS.
    05 FILLER PIC X(120) VALUE "minecraft:mineable/pickaxe|2 6 9 11".
    05 FILLER PIC X(120) VALUE "minecraft:mineable/shovel|3 4 5".
    05 FILLER PIC X(120) VALUE "minecraft:replaceable|0".
    05 FILLER PIC X(120) VALUE "minecraft:air|0".
    05 FILLER PIC X(120) VALUE "minecraft:causes_suffocation|1 2 3 4 5 6 7 8 9 10 11".
    05 FILLER PIC X(120) VALUE "minecraft:blocks_motion|1 2 3 4 5 6 7 8 9 10 11".
    05 FILLER PIC X(120) VALUE "minecraft:blocks_motion_no_leaves|1 2 3 4 5 6 7 8 9 10 11".
    05 FILLER PIC X(120) VALUE "minecraft:blocks_motion_in_heightmap|1 2 3 4 5 6 7 8 9 10 11".
    05 FILLER PIC X(120) VALUE "minecraft:blocks_motion_in_heightmap_no_leaves|1 2 3 4 5 6 7 8 9 10 11".
 01 WS-TAG-TABLE REDEFINES WS-TAGS.
    05 WS-TAG-LINE         PIC X(120) OCCURS 9 TIMES.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         CALL "BUILTIN-TAG-LINE" USING WS-REGISTRY WS-TAG-LINE(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM BUILTIN-BLOCK-TAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-TAG-LINE.
*> USING registry (PIC X(48)), line (PIC X(120): the tag key, "|", the member ids separated by spaces): binds
*> the tag with TAG-PUT. Shared by the built-in block and item layers.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(64).
 01 WS-LIST                PIC X(100).
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(12).
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 32 TIMES.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-LINE                 PIC X(120).
 PROCEDURE DIVISION USING L-REGISTRY L-LINE.
     MOVE SPACES TO WS-KEY WS-LIST
     UNSTRING L-LINE DELIMITED BY "|" INTO WS-KEY WS-LIST
     MOVE 0 TO WS-COUNT
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 100
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-LIST DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES
             ADD 1 TO WS-COUNT
             COMPUTE WS-ID(WS-COUNT) = FUNCTION NUMVAL(WS-TOKEN)
         END-IF
     END-PERFORM
     CALL "TAG-PUT" USING L-REGISTRY WS-KEY WS-COUNT WS-IDS WS-STATUS
     GOBACK.
 END PROGRAM BUILTIN-TAG-LINE.
