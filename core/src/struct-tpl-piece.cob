*> The template structure piece (docs/protocol/36-structures-2 section 6, TemplateStructurePiece) in the pieces model of STRUCTPIECE.cpy: a piece of SP-TYPE 100 keeps a template of the
*> cache, its position, rotation, mirror, pivot and processor list, and STRUCT-PLACE-START post-processes it like the mineshaft's pieces (36-1 8): through STRUCT-PLACE with the chunk's write
*> box as the settings' box, then the data markers and the jigsaw markers inside the box.
*>
*> Entry points:
*>   STRUCT-TPL-PIECE-ADD USING kind, template row, x, y, z (templatePosition), rotation, mirror, pivot x, y, z, processors, ignore waterlogging (0 or 1), aux, row out: appends a piece
*>     with the box of getBoundingBox (6.1); row 0 when the template is not loaded or the builder is full
*>   STRUCT-TPL-POST USING row: postProcess (6.2): the settings of the piece restricted to the write box, the box recomputed, placeInWorld with the start's pivot as the anchor and flags 2,
*>     the data markers (structure blocks in DATA mode: STRUCT-DATA-MARKER), then the jigsaw markers replaced by their final_state text (STRUCT-BLOCK-TEXT; an error is air)
*>   STRUCT-TPL-PRE USING row: the hook before the placement (a structure that adjusts the piece's height does it here). Kind 1 (igloo) moves the piece to
*>     the base height of its column (36-4 6.3); STRUCT-TPL-AFTER (struct-tpl-gen.cob) is called at the end of the post-processing, with the result of placeInWorld (the igloo's snow block and the
*>     restore of the saved position)
*>   STRUCT-DATA-MARKER USING row, metadata (PIC X(96)), x, y, z: handleDataMarker of the piece's kind (SP-T-KIND): 0 none; 1 igloo (36-4 6.3: "chest" turns the marker to air and gives the
*>     chest below the table chests/igloo_chest); 2 shipwreck (36-6 4.3: map_chest, treasure_chest and supply_chest give the chest below its table); 3 ocean ruin (36-6 3.5, STRUCT-RUIN-MARKER); 5 woodland mansion (36-7 7.1, MAN-MARKER)
*>   Note: 36-2 5 and 6.2 hand the placement the start's pivot as the anchor; 36-6 2.3 writes the template position twice. This code follows 36-2 (the anchor only matters to position tests).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-PIECE-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 01 WS-TYPE                BINARY-LONG VALUE 100.
 01 WS-ORIENT              BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TEMPLATE             BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PY                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-PROC                 BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-AUX                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TEMPLATE L-X L-Y L-Z L-ROT L-MIRROR L-PX L-PY L-PZ L-PROC L-LIQUID L-AUX L-ROW.
     MOVE 0 TO L-ROW
     IF L-TEMPLATE < 1 OR L-TEMPLATE > TP-COUNT
         GOBACK
     END-IF
     IF TP-STATUS(L-TEMPLATE) NOT = 1
         GOBACK
     END-IF
     CALL "STRUCT-TX-BOX" USING TP-SX(L-TEMPLATE) TP-SY(L-TEMPLATE) TP-SZ(L-TEMPLATE) L-MIRROR L-ROT L-PX L-PZ L-X L-Y L-Z WS-BOX
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX L-ROW
     IF L-ROW = 0
         GOBACK
     END-IF
     MOVE L-TEMPLATE TO SP-T-ROW(L-ROW)
     MOVE L-X TO SP-T-X(L-ROW)
     MOVE L-Y TO SP-T-Y(L-ROW)
     MOVE L-Z TO SP-T-Z(L-ROW)
     MOVE L-ROT TO SP-T-ROT(L-ROW)
     MOVE L-MIRROR TO SP-T-MIR(L-ROW)
     MOVE L-PX TO SP-T-PIV-X(L-ROW)
     MOVE L-PY TO SP-T-PIV-Y(L-ROW)
     MOVE L-PZ TO SP-T-PIV-Z(L-ROW)
     MOVE L-PROC TO SP-T-PROC(L-ROW)
     MOVE L-KIND TO SP-T-KIND(L-ROW)
     MOVE L-LIQUID TO SP-T-LIQ(L-ROW)
     MOVE L-AUX TO SP-T-AUX(L-ROW)
     GOBACK.
 END PROGRAM STRUCT-TPL-PIECE-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-PRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-OFX                 BINARY-LONG.
 01 WS-OFZ                 BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF SP-T-KIND(L-ROW) = 1
*>       igloo (36-4 6.3 steps 1 to 3): the reference point of the piece's template, the base height of its column, the position moved to h - 1 (saved in SP-F1 for STRUCT-TPL-AFTER)
         EVALUATE SP-T-AUX(L-ROW)
             WHEN 2
                 MOVE 2 TO WS-OFX
                 MOVE 4 TO WS-OFZ
             WHEN 3
                 MOVE 0 TO WS-OFX
                 MOVE 0 TO WS-OFZ
                 SUBTRACT 2 FROM WS-OFZ
             WHEN OTHER
                 MOVE 0 TO WS-OFX
                 MOVE 0 TO WS-OFZ
         END-EVALUATE
         COMPUTE WS-RX = 3 - WS-OFX
         COMPUTE WS-RZ = 0 - WS-OFZ
         CALL "STRUCT-TX-POS" USING WS-RX WS-ZERO WS-RZ SP-T-MIR(L-ROW) SP-T-ROT(L-ROW) SP-T-PIV-X(L-ROW) SP-T-PIV-Z(L-ROW) WS-OX WS-OY WS-OZ
         COMPUTE WS-OX = SP-T-X(L-ROW) + WS-OX
         COMPUTE WS-OZ = SP-T-Z(L-ROW) + WS-OZ
         CALL "STRUCT-BASE-HEIGHT" USING WS-OX WS-OZ WS-ZERO WS-H
         MOVE SP-T-Y(L-ROW) TO SP-F1(L-ROW)
         COMPUTE SP-T-Y(L-ROW) = SP-T-Y(L-ROW) + WS-H - 90 - 1
     END-IF
*>   an ocean ruin piece (kind 3) takes the adapted height of 36-6 3.5
     IF SP-T-KIND(L-ROW) = 3
         CALL "STRUCT-RUIN-PRE" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STRUCT-TPL-PRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-MARKER-LOOT.
*> USING x, y, z (the marker), loot table key (PIC X(48)): RandomizableContainer.setBlockEntityLootTable(level, random, pos.below(), key): when the block below is a chest (the generation
*> window's stand-in for "has a randomizable container block entity") it takes the table and one nextLong of the piece random (SP-XR), as a request of the block entity channel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-NOTHING             PIC X(32) VALUE SPACES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LOOT                 PIC X(48).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-LOOT.
     COMPUTE WS-BELOW = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-BELOW L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     IF CB-KEY(WS-BLOCK + 1) = "chest"
         CALL "MSP-RNG-LONG" USING WS-SEED
         CALL "GBE-ADD" USING L-X WS-BELOW L-Z WS-KIND L-LOOT WS-SEED WS-NOTHING
     END-IF
     GOBACK.
 END PROGRAM STRUCT-MARKER-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-DATA-MARKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-LOOT                PIC X(48).
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-META                 PIC X(96).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-META L-X L-Y L-Z.
     MOVE SPACES TO WS-LOOT
     EVALUATE SP-T-KIND(L-ROW)
         WHEN 1
             IF L-META = "chest"
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-AIR WS-FLAGS WS-OK
                 MOVE "minecraft:chests/igloo_chest" TO WS-LOOT
             END-IF
         WHEN 3
             CALL "STRUCT-RUIN-MARKER" USING L-ROW L-META L-X L-Y L-Z
         WHEN 5
             CALL "MAN-MARKER" USING L-ROW L-META L-X L-Y L-Z
         WHEN 2
             EVALUATE L-META
                 WHEN "map_chest"
                     MOVE "minecraft:chests/shipwreck_map" TO WS-LOOT
                 WHEN "treasure_chest"
                     MOVE "minecraft:chests/shipwreck_treasure" TO WS-LOOT
                 WHEN "supply_chest"
                     MOVE "minecraft:chests/shipwreck_supply" TO WS-LOOT
             END-EVALUATE
     END-EVALUATE
     IF WS-LOOT NOT = SPACES
         CALL "STRUCT-MARKER-LOOT" USING L-X L-Y L-Z WS-LOOT
     END-IF
     GOBACK.
 END PROGRAM STRUCT-DATA-MARKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TPL-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 COPY STRUCTSET.
 01 WS-OK                  BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-SETFLAGS            BINARY-LONG VALUE 3.
 01 WS-RESULT              BINARY-LONG.
 01 WS-RELATIVE            BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-META                PIC X(96).
 01 WS-TEXT                PIC X(160).
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-T-ROW(L-ROW) TO WS-ROW
     CALL "STRUCT-TPL-PRE" USING L-ROW
*>   a ruined portal (kind 4) is placed only by the pass whose write box holds its centre, with the write box enlarged to the portal (36-4 8.4 steps 1 and 2)
     IF SP-T-KIND(L-ROW) = 4
         CALL "STRUCT-PORTAL-BEGIN" USING L-ROW WS-GO
         IF WS-GO = 0
             GOBACK
         END-IF
     END-IF
     INITIALIZE STRUCT-SETTINGS
     MOVE SP-T-MIR(L-ROW) TO PS-MIRROR
     MOVE SP-T-ROT(L-ROW) TO PS-ROTATION
     MOVE SP-T-PIV-X(L-ROW) TO PS-PIVOT-X
     MOVE SP-T-PIV-Z(L-ROW) TO PS-PIVOT-Z
     MOVE SP-T-LIQ(L-ROW) TO PS-LIQUID
     MOVE SP-T-PROC(L-ROW) TO PS-PROCESSORS
     MOVE SP-SEED TO PS-SEED
     MOVE 1 TO PS-BOX-SET
     MOVE SW-X0 TO PS-BOX(1)
     MOVE SW-Y0 TO PS-BOX(2)
     MOVE SW-Z0 TO PS-BOX(3)
     MOVE SW-X1 TO PS-BOX(4)
     MOVE SW-Y1 TO PS-BOX(5)
     MOVE SW-Z1 TO PS-BOX(6)
*>   The box of the piece, recomputed from the position (6.2 step 2).
     CALL "STRUCT-TX-BOX" USING TP-SX(WS-ROW) TP-SY(WS-ROW) TP-SZ(WS-ROW) PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z
         SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) WS-BOX
     MOVE B-X0 TO SP-X0(L-ROW)
     MOVE B-Y0 TO SP-Y0(L-ROW)
     MOVE B-Z0 TO SP-Z0(L-ROW)
     MOVE B-X1 TO SP-X1(L-ROW)
     MOVE B-Y1 TO SP-Y1(L-ROW)
     MOVE B-Z1 TO SP-Z1(L-ROW)
     CALL "STRUCT-PLACE" USING WS-ROW SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) SP-PIV-X SP-PIV-Y SP-PIV-Z
         STRUCT-SETTINGS WS-FLAGS WS-RESULT
     IF WS-RESULT = 0
         CALL "STRUCT-TPL-AFTER" USING L-ROW WS-RESULT
         GOBACK
     END-IF
*>   Data markers (6.2 step 4), in template block order.
     MOVE "minecraft:structure_block" TO WS-KEY
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) STRUCT-SETTINGS WS-KEY WS-RELATIVE
     MOVE SF-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE SF-NBT(WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 3
                 MOVE TN-TEXT(WS-TAG) TO WS-META
                 MOVE SF-X(WS-I) TO WS-X
                 MOVE SF-Y(WS-I) TO WS-Y
                 MOVE SF-Z(WS-I) TO WS-Z
                 CALL "STRUCT-DATA-MARKER" USING L-ROW WS-META WS-X WS-Y WS-Z
             END-IF
         END-IF
     END-PERFORM
*>   Jigsaw markers (6.2 step 5): the final_state text is the block, air when it does not parse.
     MOVE "minecraft:jigsaw" TO WS-KEY
     CALL "STRUCT-FILTER-BLOCKS" USING WS-ROW SP-T-X(L-ROW) SP-T-Y(L-ROW) SP-T-Z(L-ROW) STRUCT-SETTINGS WS-KEY WS-RELATIVE
     MOVE SF-COUNT TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE SF-NBT(WS-I) TO WS-TAG
         IF WS-TAG > 0
             IF TN-KIND(WS-TAG) = 4
                 MOVE TN-TEXT(WS-TAG) TO WS-TEXT
                 CALL "STRUCT-BLOCK-TEXT" USING WS-TEXT WS-STATE WS-GOOD
                 MOVE SF-X(WS-I) TO WS-X
                 MOVE SF-Y(WS-I) TO WS-Y
                 MOVE SF-Z(WS-I) TO WS-Z
                 CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-SETFLAGS WS-OK
             END-IF
         END-IF
     END-PERFORM
     CALL "STRUCT-TPL-AFTER" USING L-ROW WS-RESULT
     GOBACK.
 END PROGRAM STRUCT-TPL-POST.
