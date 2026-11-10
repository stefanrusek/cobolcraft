*> The light policies (standin-content §5.2; docs/protocol/09-cobolcraft-profile.md §3.4 rule 4;
*> §15.3), selected by the chunk's dimension (DIMENSIONS.cpy DM-LIGHT-POLICY), over the chunk cache
*> (world.cob, CELLS.cpy: light is 4 bits per cell,
*> byte 2048 + (cell - 1) div 2 + 1, an odd cell in the low nibble). DIM-LIGHT-BLOCK-ONLY has no sky light at all; otherwise sky light: 15 in every cell above its
*> column's topmost non-void block, 0 at or below it; no sideways spreading. Block light: a source of
*> level L (SB-LIGHT) has L, a non-opaque cell has L minus the length of the shortest face-adjacent
*> path from the source through non-opaque cells (never below 0), opaque cells other than sources
*> have 0, and the highest level from any source wins. Light never reaches 15 blocks from its source,
*> so a chunk's block light depends only on the sources of its 3 x 3 chunk neighbourhood; those
*> chunks are generated (not lit) to find them, and the spread walks generated cells only.
*> A block change made by a player (LIGHT-SET-BLOCK) sends the light that changed in Light Update
*> packets (09 §3.4 rule 3; LIGHT-UPDATE-BUILD).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-CHUNK.
*> USING row (BINARY-LONG): computes the sky and block light of that cached chunk and sets CK-LIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "LIGHT-SKY" USING L-ROW
     CALL "LIGHT-BLOCK" USING L-ROW
     MOVE 1 TO CK-LIT(L-ROW)
     GOBACK.
 END PROGRAM LIGHT-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-BLOCK-CHANGED.
*> USING row (BINARY-LONG) of a lit chunk in which a block changed: recomputes its sky light and the
*> block light of every lit chunk of its 3 x 3 neighbourhood (a change can only alter block light
*> within 14 blocks of itself). Unloaded and unlit chunks are left alone: they are lit on access.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "LIGHT-SKY" USING L-ROW
     MOVE CK-DIM(L-ROW) TO WS-DIM
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW > 0 AND CK-LIT(WS-ROW) = 1
                 CALL "LIGHT-BLOCK" USING WS-ROW
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-BLOCK-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SKY.
*> USING row (BINARY-LONG): the sky light of that cached chunk. Whole layers are set at once up to
*> the lowest column top, then each column from there to its own top. A dimension whose light policy
*> has no sky light (DIM-LIGHT-BLOCK-ONLY, standin §15.3) gets 0 in every cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-TOPS.
    05 WS-TOP              BINARY-LONG OCCURS 256 TIMES.
 01 WS-MIN                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE LOW-VALUES TO CE-SKYS
     IF DM-LIGHT-POLICY(CK-DIM(L-ROW)) = DIM-LIGHT-BLOCK-ONLY
         GOBACK
     END-IF
     CALL "WORLD-COLUMN-TOPS" USING L-ROW WS-TOPS
     COMPUTE WS-MIN = DM-HEIGHT(CK-DIM(L-ROW)) - 1
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         IF WS-TOP(WS-C) < WS-MIN
             MOVE WS-TOP(WS-C) TO WS-MIN
         END-IF
     END-PERFORM
     COMPUTE WS-LENGTH = DM-HEIGHT(CK-DIM(L-ROW)) * 128
     MOVE ALL X"FF" TO CE-SKYS(2049:WS-LENGTH)
     COMPUTE WS-LENGTH = (WS-MIN + 1) * 128
     IF WS-LENGTH > 0
         MOVE LOW-VALUES TO CE-SKYS(2049:WS-LENGTH)
     END-IF
*>   The light section above the dimension has sky light 15 (06 §7.1; the one below stays 0).
     COMPUTE WS-LENGTH = (DM-HEIGHT(CK-DIM(L-ROW)) / 16 + 1) * 2048 + 1
     MOVE ALL X"FF" TO CE-SKYS(WS-LENGTH:2048)
     COMPUTE WS-LOW = WS-MIN + 1
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         PERFORM VARYING WS-Y FROM WS-LOW BY 1 UNTIL WS-Y > WS-TOP(WS-C)
             COMPUTE WS-N = WS-Y * 256 + WS-C
             COMPUTE WS-B = 2048 + (WS-N - 1) / 2 + 1
             MOVE CE-SKY(WS-B) TO WS-V
             IF FUNCTION MOD(WS-N, 2) = 1
                 COMPUTE WS-HI = WS-V / 16
                 COMPUTE CE-SKY(WS-B) = WS-HI * 16
             ELSE
                 COMPUTE CE-SKY(WS-B) = FUNCTION MOD(WS-V, 16)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-BLOCK.
*> USING row (BINARY-LONG): the block light of that cached chunk, from every light source of its
*> 3 x 3 chunk neighbourhood that can reach it (only sections whose CK-SOURCES count is above 0 are
*> scanned for sources).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CELLS REPLACING LEADING ==CE-== BY ==CX-==.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FAR-X               BINARY-LONG.
 01 WS-FAR-Z               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE LOW-VALUES TO CE-BLOCK-LIGHTS
     MOVE CK-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-SECTIONS = DM-HEIGHT(WS-DIM) / 16
     COMPUTE WS-X0 = CK-X(L-ROW) * 16
     COMPUTE WS-Z0 = CK-Z(L-ROW) * 16
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = CK-X(L-ROW) + WS-DX
             COMPUTE WS-CZ = CK-Z(L-ROW) + WS-DZ
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
             SET ADDRESS OF CX-CHUNK TO CK-ADDR(WS-ROW)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SECTIONS
                 IF CK-SOURCES(WS-ROW, WS-S) > 0
                     COMPUTE WS-LAST = WS-S * 4096
                     COMPUTE WS-FIRST = WS-LAST - 4095
                     PERFORM VARYING WS-CELL FROM WS-FIRST BY 1 UNTIL WS-CELL > WS-LAST
                         MOVE CB-S-LIGHT(CX-STATE(WS-CELL) + 1) TO WS-LEVEL
                         IF WS-LEVEL > 0
                             COMPUTE WS-Y = (WS-CELL - 1) / 256
                             COMPUTE WS-REST = WS-CELL - 1 - WS-Y * 256
                             COMPUTE WS-Z = WS-REST / 16
                             COMPUTE WS-X = WS-CX * 16 + WS-REST - WS-Z * 16
                             COMPUTE WS-Z = WS-CZ * 16 + WS-Z
*>                           Taxicab distance from the source to the nearest cell of this chunk.
                             MOVE 0 TO WS-FAR-X WS-FAR-Z
                             IF WS-X < WS-X0
                                 COMPUTE WS-FAR-X = WS-X0 - WS-X
                             END-IF
                             IF WS-X > WS-X0 + 15
                                 COMPUTE WS-FAR-X = WS-X - WS-X0 - 15
                             END-IF
                             IF WS-Z < WS-Z0
                                 COMPUTE WS-FAR-Z = WS-Z0 - WS-Z
                             END-IF
                             IF WS-Z > WS-Z0 + 15
                                 COMPUTE WS-FAR-Z = WS-Z - WS-Z0 - 15
                             END-IF
                             IF WS-FAR-X + WS-FAR-Z < WS-LEVEL
                                 CALL "LIGHT-SPREAD" USING L-ROW WS-X WS-Y WS-Z WS-LEVEL
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SPREAD.
*> USING target row, source x, y, z (world x and z, cell y), level L (BINARY-LONG): breadth-first
*> spread of one source's light through non-opaque cells, raising the block light of the cells that
*> lie in the target chunk to the level reached there. Cells are visited at most once (a stamp per
*> cell of the 31 x 31 x 31 window around the source); chunks the spread enters are generated when
*> missing (WORLD-CHUNK-LOAD), the last one looked up is remembered.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CELLS REPLACING LEADING ==CE-== BY ==CX-==.
 01 WS-STAMP-ID            BINARY-LONG VALUE 0.
 01 WS-STAMPS.
    05 WS-STAMP            BINARY-LONG OCCURS 29791 TIMES VALUE 0.
 01 WS-QUEUE.
    05 WS-Q OCCURS 29791 TIMES.
       10 WS-QX            BINARY-LONG.
       10 WS-QY            BINARY-LONG.
       10 WS-QZ            BINARY-LONG.
       10 WS-QL            BINARY-LONG.
 01 WS-STEPS.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE -1.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 6 TIMES.
       10 WS-STEP-X        BINARY-LONG.
       10 WS-STEP-Y        BINARY-LONG.
       10 WS-STEP-Z        BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEEN-CX             BINARY-LONG.
 01 WS-SEEN-CZ             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TOP-Y               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-LEVEL.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE CK-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-TOP-Y = DM-HEIGHT(WS-DIM) - 1
     COMPUTE WS-X0 = CK-X(L-ROW) * 16
     COMPUTE WS-Z0 = CK-Z(L-ROW) * 16
     MOVE 2147483647 TO WS-SEEN-CX
     ADD 1 TO WS-STAMP-ID
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE L-X TO WS-QX(1)
     MOVE L-Y TO WS-QY(1)
     MOVE L-Z TO WS-QZ(1)
     MOVE L-LEVEL TO WS-QL(1)
     MOVE WS-STAMP-ID TO WS-STAMP(15 + 15 * 31 + 15 * 961 + 1)
     PERFORM UNTIL WS-HEAD > WS-TAIL
         MOVE WS-QX(WS-HEAD) TO WS-X
         MOVE WS-QY(WS-HEAD) TO WS-Y
         MOVE WS-QZ(WS-HEAD) TO WS-Z
         MOVE WS-QL(WS-HEAD) TO WS-L
         ADD 1 TO WS-HEAD
         IF WS-X >= WS-X0 AND WS-X <= WS-X0 + 15 AND WS-Z >= WS-Z0 AND WS-Z <= WS-Z0 + 15
             COMPUTE WS-CELL = WS-Y * 256 + (WS-Z - WS-Z0) * 16 + WS-X - WS-X0 + 1
             COMPUTE WS-B = 2048 + (WS-CELL - 1) / 2 + 1
             MOVE CE-BLOCK-LIGHT(WS-B) TO WS-V
             IF FUNCTION MOD(WS-CELL, 2) = 1
                 COMPUTE WS-HI = WS-V / 16
                 IF FUNCTION MOD(WS-V, 16) < WS-L
                     COMPUTE CE-BLOCK-LIGHT(WS-B) = WS-HI * 16 + WS-L
                 END-IF
             ELSE
                 COMPUTE WS-HI = WS-V / 16
                 IF WS-HI < WS-L
                     COMPUTE CE-BLOCK-LIGHT(WS-B) = FUNCTION MOD(WS-V, 16) + WS-L * 16
                 END-IF
             END-IF
         END-IF
         IF WS-L > 1
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
                 COMPUTE WS-NY = WS-Y + WS-STEP-Y(WS-D)
                 IF WS-NY >= 0 AND WS-NY <= WS-TOP-Y
                     COMPUTE WS-NX = WS-X + WS-STEP-X(WS-D)
                     COMPUTE WS-NZ = WS-Z + WS-STEP-Z(WS-D)
                     COMPUTE WS-W = WS-NX - L-X + 15 + (WS-NZ - L-Z + 15) * 31
                         + (WS-NY - L-Y + 15) * 961 + 1
                     IF WS-STAMP(WS-W) NOT = WS-STAMP-ID
                         MOVE WS-STAMP-ID TO WS-STAMP(WS-W)
*>                       Chunk of (nx, nz): floor division by 16.
                         IF WS-NX >= 0
                             COMPUTE WS-CX = WS-NX / 16
                         ELSE
                             COMPUTE WS-CX = (WS-NX - 15) / 16
                         END-IF
                         IF WS-NZ >= 0
                             COMPUTE WS-CZ = WS-NZ / 16
                         ELSE
                             COMPUTE WS-CZ = (WS-NZ - 15) / 16
                         END-IF
                         IF WS-CX NOT = WS-SEEN-CX OR WS-CZ NOT = WS-SEEN-CZ
                             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
                             SET ADDRESS OF CX-CHUNK TO CK-ADDR(WS-ROW)
                             MOVE WS-CX TO WS-SEEN-CX
                             MOVE WS-CZ TO WS-SEEN-CZ
                         END-IF
                         COMPUTE WS-CELL = WS-NY * 256 + (WS-NZ - WS-CZ * 16) * 16
                             + WS-NX - WS-CX * 16 + 1
                         MOVE CX-STATE(WS-CELL) TO WS-STATE
                         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
                         IF CB-OPAQUE(WS-BLK + 1) = 0
                             ADD 1 TO WS-TAIL
                             MOVE WS-NX TO WS-QX(WS-TAIL)
                             MOVE WS-NY TO WS-QY(WS-TAIL)
                             MOVE WS-NZ TO WS-QZ(WS-TAIL)
                             COMPUTE WS-QL(WS-TAIL) = WS-L - 1
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-UPDATE-BUILD.
*> USING row (BINARY-LONG) of a lit cached chunk, changed sections (PIC X(16): position s + 1 is "1"
*> when block section s changed), PB-BUFFER: Light Update 0x31 (05a: VarInt chunk x, VarInt chunk z,
*> LightData; 09 §3.4 rule 3). Only the changed sections carry light, each with both kinds: an
*> all-zero layer sets its bit in the empty mask, any other layer is an array (rule 2); every other
*> light section index has no bit in any mask. A dimension without sky light (DIM-LIGHT-BLOCK-ONLY,
*> standin §15.3) sets no sky light bit at all.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-PACKET-ID           BINARY-LONG VALUE 49.
 01 WS-LIGHTS              BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SKY-STATES.
    05 WS-SKY-STATE        BINARY-LONG OCCURS 26 TIMES.
 01 WS-BLOCK-STATES.
    05 WS-BLOCK-STATE      BINARY-LONG OCCURS 26 TIMES.
 01 WS-SKY-ARRAYS.
    05 WS-SKY-ARRAY-X      PIC X(2048) OCCURS 26 TIMES.
 01 WS-BLOCK-ARRAYS.
    05 WS-BLOCK-ARRAY-X    PIC X(2048) OCCURS 26 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANGED              PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-CHANGED PB-BUFFER.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-SECTIONS = DM-HEIGHT(CK-DIM(L-ROW)) / 16
     COMPUTE WS-LIGHTS = WS-SECTIONS + 2
     INITIALIZE WS-SKY-STATES WS-BLOCK-STATES
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         IF L-CHANGED(WS-S + 1:1) = "1"
             COMPUTE WS-BASE = WS-S * 4096
             MOVE 1 TO WS-BLOCK-STATE(WS-S + 2)
             IF DM-LIGHT-POLICY(CK-DIM(L-ROW)) NOT = DIM-LIGHT-BLOCK-ONLY
                 MOVE 1 TO WS-SKY-STATE(WS-S + 2)
             END-IF
             COMPUTE WS-BYTE = (WS-S + 1) * 2048 + 1
             IF CE-SKYS(WS-BYTE:2048) NOT = LOW-VALUES
                 MOVE 2 TO WS-SKY-STATE(WS-S + 2)
                 MOVE CE-SKYS(WS-BYTE:2048) TO WS-SKY-ARRAY-X(WS-S + 2)
             END-IF
             IF CE-BLOCK-LIGHTS(WS-BYTE:2048) NOT = LOW-VALUES
                 MOVE 2 TO WS-BLOCK-STATE(WS-S + 2)
                 MOVE CE-BLOCK-LIGHTS(WS-BYTE:2048) TO WS-BLOCK-ARRAY-X(WS-S + 2)
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER CK-X(L-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER CK-Z(L-ROW)
     CALL "LIGHT-ENCODE" USING PB-BUFFER WS-LIGHTS WS-SKY-STATES WS-SKY-ARRAYS WS-BLOCK-STATES
         WS-BLOCK-ARRAYS
     GOBACK.
 END PROGRAM LIGHT-UPDATE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHT-SET-BLOCK.
*> USING dimension row, x, y, z, state (BINARY-LONG): sets the block (WORLD-SET-BLOCK, which
*> recomputes the light of the affected chunks) and sends the light that changed (09 §3.4 rule 3):
*> the light of every lit chunk of the 3 x 3 neighbourhood is kept before the change; afterwards each
*> of them whose sky or block light differs in some section gets one Light Update with those
*> sections, to the players who see that chunk (VIEWERS-SEND).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-ANY                 PIC 9.
 01 WS-CHANGED             PIC X(24).
 01 WS-ROWS.
    05 WS-ROW              BINARY-LONG OCCURS 9 TIMES.
 01 WS-SNAPS.
    05 WS-SNAP             PIC X(106496) OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     MOVE 0 TO WS-K
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             ADD 1 TO WS-K
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "WORLD-FIND" USING L-DIM WS-X WS-Z WS-ROW(WS-K)
             IF WS-ROW(WS-K) > 0
                 IF CK-LIT(WS-ROW(WS-K)) = 1
                     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW(WS-K))
                     MOVE CE-CHUNK(196609:106496) TO WS-SNAP(WS-K)
                 ELSE
                     MOVE 0 TO WS-ROW(WS-K)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING L-DIM L-X L-Y L-Z L-STATE
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         IF WS-ROW(WS-K) > 0
             SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW(WS-K))
             MOVE ALL "0" TO WS-CHANGED
             MOVE 0 TO WS-ANY
             PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
                 COMPUTE WS-BASE = (WS-S + 1) * 2048
                 COMPUTE WS-OFF = 53248 + WS-BASE + 1
                 IF CE-SKYS(WS-BASE + 1:2048) NOT = WS-SNAP(WS-K)(WS-BASE + 1:2048)
                         OR CE-BLOCK-LIGHTS(WS-BASE + 1:2048)
                         NOT = WS-SNAP(WS-K)(WS-OFF:2048)
                     MOVE "1" TO WS-CHANGED(WS-S + 1:1)
                     MOVE 1 TO WS-ANY
                 END-IF
             END-PERFORM
             IF WS-ANY = 1
                 IF WS-READY = 0
                     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                     MOVE 1 TO WS-READY
                 END-IF
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "LIGHT-UPDATE-BUILD" USING WS-ROW(WS-K) WS-CHANGED PB-BUFFER
                 CALL "VIEWERS-SEND" USING L-DIM CK-X(WS-ROW(WS-K)) CK-Z(WS-ROW(WS-K)) WS-NONE
                     PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHT-SET-BLOCK.
