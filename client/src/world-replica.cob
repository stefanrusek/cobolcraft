*> The world replica (data-model §3 "replica: client"; docs/protocol/06): one row per chunk
*> received, holding its cells as the core does (CLCELLS.cpy, the layout of the core's chunks: 65536 block state
*> bytes, then sky light, then block light, cell index y * 256 + z * 16 + x + 1), then the biome
*> ids of its 4 x 4 x 4 biome cells (1024 bytes), allocated once per row and kept for reuse. WORLD-CHUNK-LOAD decodes Level Chunk With Light (06 §2 to §7) with
*> proto CHUNK-SECTION-DECODE and LIGHT-DECODE; state ids the client does not know decode as void
*> (standin-content §1.2). Every section of the chunk and of its four neighbours is marked to be
*> meshed again. WORLD-FORGET (Forget Level Chunk) and WORLD-CLEAR drop chunks and mark their mesh
*> slots to be freed. WORLD-CELL looks a cell up: outside the loaded chunks it is void under full sky
*> light; below the world it is void and dark. Changes while the world is shown (US4-7):
*> WORLD-BLOCK-SET (Block Update 0x08, and each entry of Section Blocks Update 0x56 read by
*> WORLD-SECTION-BLOCKS) sets one cell and marks its section to be meshed, with the neighbouring
*> section or chunk when the cell lies on its edge; WORLD-LIGHT-UPDATE (Light Update 0x31, 06 §8)
*> takes the light arrays it carries (an empty-mask section becomes 0) and marks those sections and
*> the ones above and below, in the chunk and its four neighbours, to be meshed.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CLEAR.
*> USING CLIENT-STATE: forgets every chunk (the rows' memory is kept for reuse; the mesh slots of
*> the chunks that were loaded are to be freed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             MOVE 1 TO WR-RELEASE(WS-R)
         END-IF
         MOVE 0 TO WR-USED(WS-R)
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-FORGET.
*> USING CLIENT-STATE, chunk x, chunk z (Forget Level Chunk): the chunk leaves the replica, its
*> mesh slots are to be freed (RENDER-LIST-BUILD) and its four neighbours are meshed again (their
*> faces toward it are now drawn).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         MOVE 0 TO WR-USED(WS-ROW)
         MOVE 1 TO WR-RELEASE(WS-ROW)
         COMPUTE WS-NX = L-CX - 1
         CALL "WORLD-DIRTY" USING CLIENT-STATE WS-NX L-CZ
         COMPUTE WS-NX = L-CX + 1
         CALL "WORLD-DIRTY" USING CLIENT-STATE WS-NX L-CZ
         COMPUTE WS-NZ = L-CZ - 1
         CALL "WORLD-DIRTY" USING CLIENT-STATE L-CX WS-NZ
         COMPUTE WS-NZ = L-CZ + 1
         CALL "WORLD-DIRTY" USING CLIENT-STATE L-CX WS-NZ
     END-IF
     GOBACK.
 END PROGRAM WORLD-FORGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-ROW.
*> USING CLIENT-STATE, chunk x, chunk z, row out (0 = not loaded).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT OR L-ROW > 0
         IF WR-USED(WS-R) = 1 AND WR-CX(WS-R) = L-CX AND WR-CZ(WS-R) = L-CZ
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-ROW-NEW.
*> USING CLIENT-STATE, chunk x, chunk z, row out: the chunk's row, or a free row taken for it
*> (cells all void and dark, biome 0); with every row in use, the row of the chunk farthest from the player.
*> A row taken from another chunk (one forgotten whose mesh slots the render list has not freed yet,
*> as after a change of dimension, or the farthest one) drops that chunk's meshes: every section
*> has no vertices and is uploaded so, which frees its slots; nothing of the old chunk is drawn.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG VALUE 197632.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-FARTHEST            BINARY-LONG.
 01 B-CELLS                PIC X(197632) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-ROW.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ L-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT OR L-ROW > 0
         IF WR-USED(WS-R) = 0
             MOVE WS-R TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW = 0 AND WR-COUNT < CL-MAX-CHUNKS
         ADD 1 TO WR-COUNT
         MOVE WR-COUNT TO L-ROW
         ALLOCATE WS-BYTES CHARACTERS RETURNING WR-ADDR(L-ROW)
     END-IF
*>   Every row taken: the chunk farthest from the player gives up its row.
     IF L-ROW = 0
         COMPUTE WS-PCX = FUNCTION INTEGER(PL-X / 16)
         COMPUTE WS-PCZ = FUNCTION INTEGER(PL-Z / 16)
         MOVE -1 TO WS-FARTHEST
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             COMPUTE WS-DISTANCE = FUNCTION ABS(WR-CX(WS-R) - WS-PCX)
                 + FUNCTION ABS(WR-CZ(WS-R) - WS-PCZ)
             IF WS-DISTANCE > WS-FARTHEST
                 MOVE WS-DISTANCE TO WS-FARTHEST
                 MOVE WS-R TO L-ROW
             END-IF
         END-PERFORM
     END-IF
     IF WR-RELEASE(L-ROW) = 1
             OR (WR-USED(L-ROW) = 1 AND (WR-CX(L-ROW) NOT = L-CX OR WR-CZ(L-ROW) NOT = L-CZ))
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             MOVE 0 TO WR-OP-COUNT(L-ROW, WS-S) WR-TR-COUNT(L-ROW, WS-S)
             MOVE 1 TO WR-UPLOAD(L-ROW, WS-S)
         END-PERFORM
     END-IF
     MOVE 1 TO WR-USED(L-ROW)
     MOVE 0 TO WR-RELEASE(L-ROW)
     MOVE L-CX TO WR-CX(L-ROW)
     MOVE L-CZ TO WR-CZ(L-ROW)
     SET ADDRESS OF B-CELLS TO WR-ADDR(L-ROW)
     MOVE LOW-VALUES TO B-CELLS
     GOBACK.
 END PROGRAM WORLD-ROW-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CHUNK-LOAD.
*> USING CLIENT-STATE, packet (Level Chunk With Light after its id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLCELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LONGS               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-LIGHTS              BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-BLOCK-BITS          BINARY-LONG VALUE 5.
 01 WS-BIOME-BITS          BINARY-LONG.
 01 WS-NON-EMPTY           BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 4096 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 64 TIMES.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 34 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 34 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY        PIC X(2048) OCCURS 34 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY      PIC X(2048) OCCURS 34 TIMES.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-INT" USING PB-BUFFER WS-CX
     CALL "PB-GET-INT" USING PB-BUFFER WS-CZ
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     SET ADDRESS OF RC-CHUNK TO WR-ADDR(WS-ROW)
*>   Heightmaps: not needed by the client.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-TYPE
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-LONGS
         COMPUTE WS-SIZE = WS-LONGS * 8
         CALL "PB-SKIP" USING PB-BUFFER WS-SIZE
     END-PERFORM
*>   Sections (the dimension type's height; global palettes: 18 block states, the biome count).
     COMPUTE WS-SECTIONS = FUNCTION MIN(PL-HEIGHT / 16, CL-MAX-SECTIONS)
     MOVE 0 TO WS-BIOME-BITS
     PERFORM UNTIL 2 ** WS-BIOME-BITS >= RG-BIOMES
         ADD 1 TO WS-BIOME-BITS
     END-PERFORM
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SIZE
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         CALL "CHUNK-SECTION-DECODE" USING PB-BUFFER WS-BLOCK-BITS WS-BIOME-BITS WS-NON-EMPTY
             WS-FLUID WS-STATES WS-BIOMES
         COMPUTE WS-BASE = WS-S * 4096
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE WS-STATE(WS-I) TO RC-STATE(WS-BASE + WS-I)
             IF WS-STATE(WS-I) >= CL-MAX-STATES OR WS-STATE(WS-I) < 0
                 MOVE 0 TO RC-STATE(WS-BASE + WS-I)
             END-IF
         END-PERFORM
*>       Biome ids above the registry's (and every id past 255) are kept as 255: no biome known.
         COMPUTE WS-BASE = WS-S * 64
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE FUNCTION MIN(WS-BIOME(WS-I), 255) TO RC-BIOME(WS-BASE + WS-I)
         END-PERFORM
     END-PERFORM
*>   Block entities: CobolCraft's content has none (standin-content §5.2), the count is 0.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
*>   Light: index 1 is the section below the world; nibble 2i is the low half of byte i.
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     CALL "LIGHT-DECODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         COMPUTE WS-BASE = WS-S * 4096
         IF WS-SKY-STATE(WS-S + 2) = 2
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2048
                 COMPUTE WS-BYTE = FUNCTION ORD(WS-SKY-ARRAY(WS-S + 2)(WS-K:1)) - 1
                 COMPUTE RC-SKY(WS-BASE + WS-K * 2 - 1) = FUNCTION MOD(WS-BYTE, 16)
                 COMPUTE RC-SKY(WS-BASE + WS-K * 2) = WS-BYTE / 16
             END-PERFORM
         END-IF
         IF WS-BLOCK-STATE(WS-S + 2) = 2
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2048
                 COMPUTE WS-BYTE = FUNCTION ORD(WS-BLOCK-ARRAY(WS-S + 2)(WS-K:1)) - 1
                 COMPUTE RC-BLOCK(WS-BASE + WS-K * 2 - 1) = FUNCTION MOD(WS-BYTE, 16)
                 COMPUTE RC-BLOCK(WS-BASE + WS-K * 2) = WS-BYTE / 16
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-CX WS-CZ
     COMPUTE WS-NX = WS-CX - 1
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-NX WS-CZ
     COMPUTE WS-NX = WS-CX + 1
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-NX WS-CZ
     COMPUTE WS-NZ = WS-CZ - 1
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-CX WS-NZ
     COMPUTE WS-NZ = WS-CZ + 1
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-CX WS-NZ
     GOBACK.
 END PROGRAM WORLD-CHUNK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-DIRTY.
*> USING CLIENT-STATE, chunk x, chunk z: every section of that chunk (when loaded) is to be meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             MOVE 1 TO WR-DIRTY(WS-ROW, WS-S)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WORLD-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CELL.
*> USING CLIENT-STATE, x, y, z (block coordinates), state out, sky light out, block light out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE L-SKY L-BLOCK.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     COMPUTE WS-LY = L-Y - PL-MIN-Y
     MOVE 0 TO L-STATE L-BLOCK
     MOVE 15 TO L-SKY
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     EVALUATE TRUE
         WHEN WS-LY < 0
             MOVE 0 TO L-SKY
         WHEN WS-ROW = 0 OR WS-LY >= PL-HEIGHT OR WS-LY > 255
             CONTINUE
         WHEN OTHER
             SET ADDRESS OF RC-CHUNK TO WR-ADDR(WS-ROW)
             COMPUTE WS-CELL = WS-LY * 256 + (L-Z - WS-CZ * 16) * 16 + (L-X - WS-CX * 16) + 1
             MOVE RC-STATE(WS-CELL) TO L-STATE
             MOVE RC-SKY(WS-CELL) TO L-SKY
             MOVE RC-BLOCK(WS-CELL) TO L-BLOCK
     END-EVALUATE
     GOBACK.
 END PROGRAM WORLD-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-SECTION-DIRTY.
*> USING CLIENT-STATE, chunk x, chunk z, section (1-based): that section, when its chunk is loaded
*> and it lies within the dimension, is to be meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-S.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     IF WS-ROW > 0 AND L-S >= 1 AND L-S <= 16
         MOVE 1 TO WR-DIRTY(WS-ROW, L-S)
     END-IF
     GOBACK.
 END PROGRAM WORLD-SECTION-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CELL-DIRTY.
*> USING CLIENT-STATE, x, y, z (block coordinates): the section holding the cell is to be meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     COMPUTE WS-S = FUNCTION INTEGER((L-Y - PL-MIN-Y) / 16) + 1
     CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-CX WS-CZ WS-S
     GOBACK.
 END PROGRAM WORLD-CELL-DIRTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-BLOCK-SET.
*> USING CLIENT-STATE, x, y, z (block coordinates), state id: the cell of a loaded chunk within the
*> dimension takes the state (one the client does not know is void); its section and those of its
*> six neighbours are to be meshed (the same section unless the cell lies on an edge).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLCELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     COMPUTE WS-LY = L-Y - PL-MIN-Y
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     IF WS-ROW > 0 AND WS-LY >= 0 AND WS-LY < PL-HEIGHT AND WS-LY <= 255
         SET ADDRESS OF RC-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-CELL = WS-LY * 256 + (L-Z - WS-CZ * 16) * 16 + (L-X - WS-CX * 16) + 1
         MOVE L-STATE TO RC-STATE(WS-CELL)
         IF L-STATE < 0 OR L-STATE >= CL-MAX-STATES
             MOVE 0 TO RC-STATE(WS-CELL)
         END-IF
         PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 6
             MOVE L-X TO WS-NX
             MOVE L-Y TO WS-NY
             MOVE L-Z TO WS-NZ
             EVALUATE WS-D
                 WHEN 1
                     SUBTRACT 1 FROM WS-NX
                 WHEN 2
                     ADD 1 TO WS-NX
                 WHEN 3
                     SUBTRACT 1 FROM WS-NY
                 WHEN 4
                     ADD 1 TO WS-NY
                 WHEN 5
                     SUBTRACT 1 FROM WS-NZ
                 WHEN 6
                     ADD 1 TO WS-NZ
             END-EVALUATE
             CALL "WORLD-CELL-DIRTY" USING CLIENT-STATE WS-NX WS-NY WS-NZ
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WORLD-BLOCK-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-SECTION-BLOCKS.
*> USING CLIENT-STATE, packet (Section Blocks Update after its id, 05b 0x56): the section position
*> (x in bits 42 to 63, z in bits 20 to 41, y in bits 0 to 19, each signed), then VarLong entries
*> state << 12 | local x << 8 | local z << 4 | local y, each set with WORLD-BLOCK-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-REST                BINARY-DOUBLE.
 01 WS-2-42                BINARY-DOUBLE VALUE 4398046511104.
 01 WS-SX                  BINARY-DOUBLE.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY               BINARY-DOUBLE.
 01 WS-STATE               BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     DIVIDE WS-LONG BY WS-2-42 GIVING WS-SX REMAINDER WS-REST
     IF WS-REST < 0
         SUBTRACT 1 FROM WS-SX
         ADD WS-2-42 TO WS-REST
     END-IF
     DIVIDE WS-REST BY 1048576 GIVING WS-SZ REMAINDER WS-SY
     IF WS-SZ >= 2097152
         SUBTRACT 4194304 FROM WS-SZ
     END-IF
     IF WS-SY >= 524288
         SUBTRACT 1048576 FROM WS-SY
     END-IF
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARLONG" USING PB-BUFFER WS-ENTRY
         DIVIDE WS-ENTRY BY 4096 GIVING WS-STATE REMAINDER WS-LOCAL
         DIVIDE WS-LOCAL BY 256 GIVING WS-X REMAINDER WS-LOW
         DIVIDE WS-LOW BY 16 GIVING WS-Z REMAINDER WS-Y
         COMPUTE WS-X = WS-SX * 16 + WS-X
         COMPUTE WS-Z = WS-SZ * 16 + WS-Z
         COMPUTE WS-Y = WS-SY * 16 + WS-Y
         CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-SECTION-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LIGHT-UPDATE.
*> USING CLIENT-STATE, packet (Light Update after its id, 06 §8): chunk x and z (VarInt), then the
*> LightData of 06 §7 for the dimension's sections and one below and one above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLCELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-LIGHTS              BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 34 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 34 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY        PIC X(2048) OCCURS 34 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY      PIC X(2048) OCCURS 34 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-CX
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-CZ
     COMPUTE WS-SECTIONS = FUNCTION MIN(PL-HEIGHT / 16, CL-MAX-SECTIONS)
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     CALL "LIGHT-DECODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS OR WS-ROW = 0
         SET ADDRESS OF RC-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-BASE = WS-S * 4096
*>       State 1 (an empty mask): every level 0; state 2: the array (nibble 2i the low half of
*>       byte i); state 0: unchanged.
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2048
             EVALUATE WS-SKY-STATE(WS-S + 2)
                 WHEN 1
                     MOVE 0 TO RC-SKY(WS-BASE + WS-K * 2 - 1) RC-SKY(WS-BASE + WS-K * 2)
                 WHEN 2
                     COMPUTE WS-BYTE = FUNCTION ORD(WS-SKY-ARRAY(WS-S + 2)(WS-K:1)) - 1
                     COMPUTE RC-SKY(WS-BASE + WS-K * 2 - 1) = FUNCTION MOD(WS-BYTE, 16)
                     COMPUTE RC-SKY(WS-BASE + WS-K * 2) = WS-BYTE / 16
             END-EVALUATE
             EVALUATE WS-BLOCK-STATE(WS-S + 2)
                 WHEN 1
                     MOVE 0 TO RC-BLOCK(WS-BASE + WS-K * 2 - 1) RC-BLOCK(WS-BASE + WS-K * 2)
                 WHEN 2
                     COMPUTE WS-BYTE = FUNCTION ORD(WS-BLOCK-ARRAY(WS-S + 2)(WS-K:1)) - 1
                     COMPUTE RC-BLOCK(WS-BASE + WS-K * 2 - 1) = FUNCTION MOD(WS-BYTE, 16)
                     COMPUTE RC-BLOCK(WS-BASE + WS-K * 2) = WS-BYTE / 16
             END-EVALUATE
         END-PERFORM
         IF WS-SKY-STATE(WS-S + 2) NOT = 0 OR WS-BLOCK-STATE(WS-S + 2) NOT = 0
*>           This section and the ones above and below, here and in the four neighbours.
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 4
                 MOVE WS-CX TO WS-NX
                 MOVE WS-CZ TO WS-NZ
                 EVALUATE WS-D
                     WHEN 1
                         SUBTRACT 1 FROM WS-NX
                     WHEN 2
                         ADD 1 TO WS-NX
                     WHEN 3
                         SUBTRACT 1 FROM WS-NZ
                     WHEN 4
                         ADD 1 TO WS-NZ
                 END-EVALUATE
                 PERFORM VARYING WS-N FROM WS-S BY 1 UNTIL WS-N > WS-S + 2
                     CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-NX WS-NZ WS-N
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-LIGHT-UPDATE.
