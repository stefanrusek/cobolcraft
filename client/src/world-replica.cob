*> The world replica (data-model §3 "replica: client"; docs/protocol/06): one row per chunk
*> received, holding one CE-CHUNK of contract/copy/CELLS.cpy (the cell layout of the core and the
*> client, CE-CHUNK-BYTES, allocated once per row and kept for reuse): 16-bit block state ids at
*> cell index (y - min_y) * 256 + z * 16 + x + 1, the 4-bit light of each cell in one array of 2048
*> bytes per light section (the wire form, one section below and one above the dimension), and the
*> biome ids of the 4 x 4 x 4 biome cells. The number of sections is the dimension's (PL-HEIGHT /
*> 16, at most CL-MAX-SECTIONS), the bottom is PL-MIN-Y. REPLICA-CHUNK-LOAD decodes Level Chunk With
*> Light (06 §2 to §7) with proto PB-GET-CHUNK-24, which reads the 001 form (global block palette of
*> 5 bits) and the form of the standard content (the palette width is ceillog2 of the content
*> set's state count, WR-BLOCK-BITS); state ids the content set does not know decode as void
*> (standin-content §1.2; with no set open, the ids of the stand-in table). Every section of the chunk and of its four neighbours is marked to be
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
 COPY CELLS.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BYTES               BINARY-LONG VALUE CE-CHUNK-BYTES.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-FARTHEST            BINARY-LONG.
 01 B-CELLS                PIC X(CE-CHUNK-BYTES) BASED.
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
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
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
 PROGRAM-ID. WORLD-SECTIONS.
*> USING CLIENT-STATE, sections out: the sections of the dimension (PL-HEIGHT / 16, at most
*> CL-MAX-SECTIONS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SECTIONS             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SECTIONS.
     COMPUTE L-SECTIONS = FUNCTION MIN(PL-HEIGHT / 16, CL-MAX-SECTIONS)
     GOBACK.
 END PROGRAM WORLD-SECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATE-LIMIT.
*> USING limit out: the number of block states the client knows: the open content set's, else the
*> stand-in table's (an id at or above it decodes as void).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIMIT.
     MOVE CL-STAND-STATES TO L-LIMIT
     IF CT-OPEN = 1
         MOVE CT-STATE-COUNT TO L-LIMIT
     END-IF
     GOBACK.
 END PROGRAM STATE-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-GET.
*> USING chunk (POINTER to a CE-CHUNK), kind (0 sky, 1 block), y (offset from the dimension's
*> min_y), local x, local z, level out: the 4-bit light of one cell. The cell number y * 256 +
*> z * 16 + x halved, after the section below the dimension (2048 bytes), is the byte; an even
*> cell is the low nibble.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                USAGE POINTER.
 01 L-KIND                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-KIND L-Y L-X L-Z L-LEVEL.
     SET ADDRESS OF CE-CHUNK TO L-CHUNK
     COMPUTE WS-CELL = L-Y * 256 + L-Z * 16 + L-X
     IF L-KIND = 0
         MOVE CE-SKY(CE-LIGHT-BYTES + WS-CELL / 2 + 1) TO WS-BYTE
     ELSE
         MOVE CE-BLOCK-LIGHT(CE-LIGHT-BYTES + WS-CELL / 2 + 1) TO WS-BYTE
     END-IF
     IF FUNCTION MOD(L-X, 2) = 0
         COMPUTE L-LEVEL = FUNCTION MOD(WS-BYTE, 16)
     ELSE
         COMPUTE L-LEVEL = WS-BYTE / 16
     END-IF
     GOBACK.
 END PROGRAM LIGHT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SET.
*> USING chunk (POINTER to a CE-CHUNK), kind (0 sky, 1 block), y (offset from min_y), local x, local
*> z, level (0 to 15): sets the light of one cell (LIGHT-GET names the byte).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-CELL                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                USAGE POINTER.
 01 L-KIND                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-KIND L-Y L-X L-Z L-LEVEL.
     SET ADDRESS OF CE-CHUNK TO L-CHUNK
     COMPUTE WS-CELL = L-Y * 256 + L-Z * 16 + L-X
     COMPUTE WS-INDEX = CE-LIGHT-BYTES + WS-CELL / 2 + 1
     IF L-KIND = 0
         MOVE CE-SKY(WS-INDEX) TO WS-BYTE
     ELSE
         MOVE CE-BLOCK-LIGHT(WS-INDEX) TO WS-BYTE
     END-IF
     IF FUNCTION MOD(L-X, 2) = 0
         COMPUTE WS-BYTE = WS-BYTE - FUNCTION MOD(WS-BYTE, 16) + L-LEVEL
     ELSE
         COMPUTE WS-BYTE = FUNCTION MOD(WS-BYTE, 16) + L-LEVEL * 16
     END-IF
     IF L-KIND = 0
         MOVE WS-BYTE TO CE-SKY(WS-INDEX)
     ELSE
         MOVE WS-BYTE TO CE-BLOCK-LIGHT(WS-INDEX)
     END-IF
     GOBACK.
 END PROGRAM LIGHT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REPLICA-CHUNK-LOAD.
*> USING CLIENT-STATE, packet (Level Chunk With Light after its id). A packet that does not decode
*> (PB-ERROR) leaves the replica as it was.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
 COPY CONTENT.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-HM-BITS             BINARY-LONG.
 01 WS-HM-MASK             BINARY-LONG.
 01 WS-BLOCK-BITS          BINARY-LONG.
 01 WS-BIOME-BITS          BINARY-LONG.
 01 WS-BE-MAX              BINARY-LONG VALUE 512.
 01 WS-BE-DATA-MAX         BINARY-LONG VALUE 262144.
 01 WS-BE-COUNT            BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-HM-VALUES.
    05 WS-HM               BINARY-LONG OCCURS 1536 TIMES.
 01 WS-COUNTS.
    05 WS-COUNT-ENTRY      BINARY-LONG OCCURS 128 TIMES.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 98304 TIMES.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 1536 TIMES.
 01 WS-BE-HEADS.
    05 WS-BE-HEAD          BINARY-LONG OCCURS 2560 TIMES.
 01 WS-BE-DATA             PIC X(262144).
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 26 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 26 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY        PIC X(2048) OCCURS 26 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY      PIC X(2048) OCCURS 26 TIMES.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     CALL "STATE-LIMIT" USING WS-LIMIT
*>   The bits of the heightmaps (06 §3.1: ceillog2 of height + 1) and of the global palettes.
     MOVE 0 TO WS-HM-BITS
     PERFORM UNTIL 2 ** WS-HM-BITS >= PL-HEIGHT + 1
         ADD 1 TO WS-HM-BITS
     END-PERFORM
     MOVE WR-BLOCK-BITS TO WS-BLOCK-BITS
     IF WS-BLOCK-BITS = 0
         MOVE 5 TO WS-BLOCK-BITS
         IF CT-OPEN = 1
             MOVE 0 TO WS-BLOCK-BITS
             PERFORM UNTIL 2 ** WS-BLOCK-BITS >= CT-STATE-COUNT
                 ADD 1 TO WS-BLOCK-BITS
             END-PERFORM
         END-IF
     END-IF
     MOVE 0 TO WS-BIOME-BITS
     PERFORM UNTIL 2 ** WS-BIOME-BITS >= RG-BIOMES
         ADD 1 TO WS-BIOME-BITS
     END-PERFORM
     CALL "PB-GET-CHUNK-24" USING PB-BUFFER WS-CX WS-CZ WS-SECTIONS WS-HM-BITS WS-HM-MASK
         WS-HM-VALUES WS-COUNTS WS-STATES WS-BIOMES WS-BLOCK-BITS WS-BIOME-BITS WS-BE-MAX
         WS-BE-DATA-MAX WS-BE-COUNT WS-BE-HEADS WS-BE-DATA WS-SKY-STATES WS-SKY-ARRAYS
         WS-BLOCK-STATES WS-BLOCK-ARRAYS
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
*>   Block states: an id the set does not know is void. Biome ids above 255 are kept as 255: no
*>   biome known.
     COMPUTE WS-BASE = WS-SECTIONS * 4096
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BASE
         IF WS-STATE(WS-I) >= WS-LIMIT OR WS-STATE(WS-I) < 0
             MOVE 0 TO CE-STATE(WS-I)
         ELSE
             MOVE WS-STATE(WS-I) TO CE-STATE(WS-I)
         END-IF
     END-PERFORM
     COMPUTE WS-BASE = WS-SECTIONS * 64
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BASE
         MOVE FUNCTION MIN(WS-BIOME(WS-I), 255) TO CE-BIOME(WS-I)
     END-PERFORM
*>   Light: the arrays of the wire are the replica's own layout; index 1 is the section below the
*>   dimension (06 §7.1). State 1 (an empty mask) is all 0, as the row starts; 0 says nothing.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS + 2
         COMPUTE WS-BASE = (WS-S - 1) * CE-LIGHT-BYTES + 1
         IF WS-SKY-STATE(WS-S) = 2
             MOVE WS-SKY-ARRAY(WS-S) TO CE-SKYS(WS-BASE:CE-LIGHT-BYTES)
         END-IF
         IF WS-BLOCK-STATE(WS-S) = 2
             MOVE WS-BLOCK-ARRAY(WS-S) TO CE-BLOCK-LIGHTS(WS-BASE:CE-LIGHT-BYTES)
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
 END PROGRAM REPLICA-CHUNK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-DIRTY.
*> USING CLIENT-STATE, chunk x, chunk z: every section of that chunk (when loaded) is to be meshed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     IF WS-ROW > 0
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
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
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-KIND-SKY            BINARY-LONG VALUE 0.
 01 WS-KIND-BLOCK          BINARY-LONG VALUE 1.
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
         WHEN WS-ROW = 0 OR WS-LY >= PL-HEIGHT
             CONTINUE
         WHEN OTHER
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
             COMPUTE WS-LX = L-X - WS-CX * 16
             COMPUTE WS-LZ = L-Z - WS-CZ * 16
             COMPUTE WS-CELL = WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
             MOVE CE-STATE(WS-CELL) TO L-STATE
             CALL "LIGHT-GET" USING WR-ADDR(WS-ROW) WS-KIND-SKY WS-LY WS-LX WS-LZ L-SKY
             CALL "LIGHT-GET" USING WR-ADDR(WS-ROW) WS-KIND-BLOCK WS-LY WS-LX WS-LZ L-BLOCK
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
 01 WS-SECTIONS            BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CX L-CZ L-S.
     CALL "WORLD-ROW" USING CLIENT-STATE L-CX L-CZ WS-ROW
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     IF WS-ROW > 0 AND L-S >= 1 AND L-S <= WS-SECTIONS
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
*> dimension takes the state (one the content set does not know is void); its section and those of
*> its six neighbours are to be meshed (the same section unless the cell lies on an edge).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
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
     CALL "STATE-LIMIT" USING WS-LIMIT
     IF WS-ROW > 0 AND WS-LY >= 0 AND WS-LY < PL-HEIGHT
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-CELL = WS-LY * 256 + (L-Z - WS-CZ * 16) * 16 + (L-X - WS-CX * 16) + 1
         MOVE L-STATE TO CE-STATE(WS-CELL)
         IF L-STATE < 0 OR L-STATE >= WS-LIMIT
             MOVE 0 TO CE-STATE(WS-CELL)
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
*> LightData of 06 §7 for the dimension's sections and one below and one above (the arrays are the
*> replica's own layout: an empty-mask section becomes 0, an array replaces the section's bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CELLS.
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
 01 WS-LOW                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
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
     CALL "WORLD-SECTIONS" USING CLIENT-STATE WS-SECTIONS
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     CALL "LIGHT-DECODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     IF WS-ROW > 0
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
*>       State 1 (an empty mask): every level 0; state 2: the array; state 0: unchanged.
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-LIGHTS
             COMPUTE WS-BASE = (WS-S - 1) * CE-LIGHT-BYTES + 1
             EVALUATE WS-SKY-STATE(WS-S)
                 WHEN 1
                     MOVE LOW-VALUES TO CE-SKYS(WS-BASE:CE-LIGHT-BYTES)
                 WHEN 2
                     MOVE WS-SKY-ARRAY(WS-S) TO CE-SKYS(WS-BASE:CE-LIGHT-BYTES)
             END-EVALUATE
             EVALUATE WS-BLOCK-STATE(WS-S)
                 WHEN 1
                     MOVE LOW-VALUES TO CE-BLOCK-LIGHTS(WS-BASE:CE-LIGHT-BYTES)
                 WHEN 2
                     MOVE WS-BLOCK-ARRAY(WS-S) TO CE-BLOCK-LIGHTS(WS-BASE:CE-LIGHT-BYTES)
             END-EVALUATE
             IF WS-SKY-STATE(WS-S) NOT = 0 OR WS-BLOCK-STATE(WS-S) NOT = 0
                 COMPUTE WS-LOW = WS-S - 2
*>               The section of this light section (one up) and the ones above and below, here and
*>               in the four neighbours: light section s is block section s - 1 (1-based s - 1).
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
                     PERFORM VARYING WS-N FROM WS-LOW BY 1 UNTIL WS-N > WS-S
                         CALL "WORLD-SECTION-DIRTY" USING CLIENT-STATE WS-NX WS-NZ WS-N
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WORLD-LIGHT-UPDATE.
