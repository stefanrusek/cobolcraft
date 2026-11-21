*> The multiface growth feature (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 8; registry id 28, multiface_growth: glow lichen and sculk veins).
*> FD-MULTI-NODE compiles the configuration into a row of FD-WA (WA-I(1) the block (index in CORE-BLOCKS), WA-I(2) search_range, WA-I(3) can_place_on_floor, WA-I(4) can_place_on_ceiling,
*> WA-I(5) can_place_on_wall; the pool 1 the blocks of can_be_placed_on; WA-F(1) chance_of_spreading), FR-MULTI places it by 8.2.
*>
*> The face properties of the block (down, up, north, south, west, east, waterlogged) are read from the property lists of the content set once for each block table epoch (FM-TABLE);
*> a block that lacks one of the six faces is not a multiface block and the feature is unsupported. "Has a full face toward a direction" (canAttachTo) is the solid flag of the block
*> (CB-SOLID), like every feature of the stage; the support shape is not modelled. The spreader is the default configuration of 8.1 (the vein spreader of the sculk patch, 35-6 section
*> 8.6, is in feat-sculk.cob). The cells are written with flag 2; the post-processing marks of the document are not made (the generator keeps no post-processing list).
*> Step 4 follows the text: the cursor is reset to origin + d at every repetition (the document's Open question 3), so a repetition after a failed first one can only fail the same way (it
*> writes and draws nothing): one pass is run for each direction, the same result for a twentieth of the cost.
*>
*> Entry points: FD-MULTI-NODE USING doc, node, row out (FD-BAD set when the feature cannot be placed whole); FR-MULTI USING state, feature, x, y, z, result out;
*>   FM-TABLE USING op, a, mask, waterlogged, state (op 1: a = block index in, slot out, 0 for a block without the six faces; op 2: a = slot, state in, mask and waterlogged out; op 3: a = slot,
*>     mask and waterlogged in, state out; a mask is six characters "0" or "1" by direction ordinal);
*>   FM-SOLID USING x, y, z, flag out (1 when the cell holds a solid block);
*>   FM-GROWTH USING state, row, x, y, z, cell state, directions (six integers), count, result out (placeGrowthIfPossible);
*>   FM-SHUFFLE USING state, list (six integers), count (Util.shuffle).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-TABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDIR.
 01 WS-CACHE.
    05 WS-SLOT OCCURS 4 TIMES.
       10 WS-S-BLOCK        BINARY-LONG VALUE 0.
       10 WS-S-EPOCH        BINARY-LONG VALUE -1.
       10 WS-S-GOOD         BINARY-LONG VALUE 0.
       10 WS-S-FIRST        BINARY-LONG VALUE 0.
       10 WS-S-COUNT        BINARY-LONG VALUE 0.
       10 WS-S-FWD          BINARY-LONG OCCURS 128 TIMES.
       10 WS-S-MASK         PIC X(6) OCCURS 128 TIMES.
       10 WS-S-WL           BINARY-LONG OCCURS 128 TIMES.
 01 WS-NEXT                BINARY-LONG VALUE 1.
 01 WS-SL                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-TALLY               BINARY-LONG.
 01 WS-MASKV               PIC X(6).
 01 WS-WLV                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
*> the six "name=" tests and "name=true" tests by ordinal
 01 WS-HAS.
    05 FILLER PIC X(11) VALUE "down=".
    05 FILLER PIC X(11) VALUE "up=".
    05 FILLER PIC X(11) VALUE "north=".
    05 FILLER PIC X(11) VALUE "south=".
    05 FILLER PIC X(11) VALUE "west=".
    05 FILLER PIC X(11) VALUE "east=".
 01 WS-HAS-T REDEFINES WS-HAS.
    05 WS-HAS-N             PIC X(11) OCCURS 6 TIMES.
 01 WS-ON.
    05 FILLER PIC X(11) VALUE "down=true".
    05 FILLER PIC X(11) VALUE "up=true".
    05 FILLER PIC X(11) VALUE "north=true".
    05 FILLER PIC X(11) VALUE "south=true".
    05 FILLER PIC X(11) VALUE "west=true".
    05 FILLER PIC X(11) VALUE "east=true".
 01 WS-ON-T REDEFINES WS-ON.
    05 WS-ON-N              PIC X(11) OCCURS 6 TIMES.
 01 WS-HAS-LEN.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 5.
 01 WS-HAS-LEN-T REDEFINES WS-HAS-LEN.
    05 WS-HL                BINARY-LONG OCCURS 6 TIMES.
 01 WS-ON-LEN.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 9.
 01 WS-ON-LEN-T REDEFINES WS-ON-LEN.
    05 WS-OL                BINARY-LONG OCCURS 6 TIMES.
 01 WS-NM                  PIC X(11).
 01 WS-NL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-MASK                 PIC X(6).
 01 L-WL                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-A L-MASK L-WL L-STATE.
     EVALUATE L-OP
         WHEN 1
             MOVE 0 TO WS-SL
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4 OR WS-SL > 0
                 IF WS-S-BLOCK(WS-I) = L-A AND WS-S-EPOCH(WS-I) = CB-EPOCH
                     MOVE WS-I TO WS-SL
                 END-IF
             END-PERFORM
             IF WS-SL = 0
                 MOVE WS-NEXT TO WS-SL
                 COMPUTE WS-NEXT = FUNCTION MOD(WS-NEXT, 4) + 1
                 MOVE L-A TO WS-S-BLOCK(WS-SL)
                 MOVE CB-EPOCH TO WS-S-EPOCH(WS-SL)
                 MOVE CB-FIRST-STATE(L-A) TO WS-S-FIRST(WS-SL)
                 MOVE CB-STATES(L-A) TO WS-S-COUNT(WS-SL)
                 MOVE 1 TO WS-GOOD
                 IF WS-S-COUNT(WS-SL) > 128
                     MOVE 0 TO WS-GOOD
                 END-IF
                 MOVE 0 TO WS-S-GOOD(WS-SL)
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 128
                     MOVE 0 TO WS-S-FWD(WS-SL, WS-K)
                 END-PERFORM
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-S-COUNT(WS-SL) OR WS-GOOD = 0
                     COMPUTE WS-S = WS-S-FIRST(WS-SL) + WS-I - 1
                     CALL "BLOCKS-STATE-PROPS" USING WS-S WS-TEXT
                     MOVE "000000" TO WS-MASKV
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE WS-HAS-N(WS-K) TO WS-NM
                         MOVE WS-HL(WS-K) TO WS-NL
                         MOVE 0 TO WS-TALLY
                         INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL WS-NM(1:WS-NL)
                         IF WS-TALLY = 0
                             MOVE 0 TO WS-GOOD
                         END-IF
                         MOVE WS-ON-N(WS-K) TO WS-NM
                         MOVE WS-OL(WS-K) TO WS-NL
                         MOVE 0 TO WS-TALLY
                         INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL WS-NM(1:WS-NL)
                         IF WS-TALLY > 0
                             MOVE "1" TO WS-MASKV(WS-K:1)
                         END-IF
                     END-PERFORM
                     MOVE 0 TO WS-WLV
                     MOVE 0 TO WS-TALLY
                     INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL "waterlogged=true"
                     IF WS-TALLY > 0
                         MOVE 1 TO WS-WLV
                     END-IF
                     MOVE WS-MASKV TO WS-S-MASK(WS-SL, WS-I)
                     MOVE WS-WLV TO WS-S-WL(WS-SL, WS-I)
                     CALL "FM-MASK-INDEX" USING WS-MASKV WS-WLV WS-IDX
                     MOVE WS-S TO WS-S-FWD(WS-SL, WS-IDX)
                 END-PERFORM
                 MOVE WS-GOOD TO WS-S-GOOD(WS-SL)
             END-IF
             IF WS-S-GOOD(WS-SL) = 0
                 MOVE 0 TO L-A
             ELSE
                 MOVE WS-SL TO L-A
             END-IF
         WHEN 2
             COMPUTE WS-I = L-STATE - WS-S-FIRST(L-A) + 1
             MOVE "000000" TO L-MASK
             MOVE 0 TO L-WL
             IF WS-I >= 1 AND WS-I <= WS-S-COUNT(L-A)
                 MOVE WS-S-MASK(L-A, WS-I) TO L-MASK
                 MOVE WS-S-WL(L-A, WS-I) TO L-WL
             END-IF
         WHEN OTHER
             MOVE L-MASK TO WS-MASKV
             MOVE L-WL TO WS-WLV
             MOVE L-A TO WS-SL
             CALL "FM-MASK-INDEX" USING WS-MASKV WS-WLV WS-IDX
             MOVE WS-S-FWD(WS-SL, WS-IDX) TO L-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM FM-TABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-MASK-INDEX.
*> USING mask (six characters), waterlogged, index out: the table index 1 to 128 of a face mask and the waterlogged flag (the faces count 2, 4, 8, ... from the bit of direction ordinal 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-POW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-MASK                 PIC X(6).
 01 L-WL                   BINARY-LONG.
 01 L-IDX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MASK L-WL L-IDX.
     COMPUTE L-IDX = 1 + L-WL
     MOVE 2 TO WS-POW
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         IF L-MASK(WS-K:1) = "1"
             ADD WS-POW TO L-IDX
         END-IF
         COMPUTE WS-POW = WS-POW * 2
     END-PERFORM
     GOBACK.
 END PROGRAM FM-MASK-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-SOLID.
*> USING x, y, z, flag out: 1 when the cell holds a solid block (the stand-in of "has a full face", CB-SOLID).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK > 0
         MOVE CB-SOLID(WS-BLOCK) TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FM-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-SHUFFLE.
*> USING state, list (six integers), count: Util.shuffle of the first count entries: for i = count down to 2, j = nextInt(i), swap entries i - 1 and j (a list of 0 or 1 draws nothing).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-LIST.
    05 L-E                 BINARY-LONG OCCURS 6 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-LIST L-COUNT.
     PERFORM VARYING WS-I FROM L-COUNT BY -1 UNTIL WS-I < 2
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE L-E(WS-K) TO WS-T
         MOVE L-E(WS-I) TO L-E(WS-K)
         MOVE WS-T TO L-E(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM FM-SHUFFLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-VALID.
*> USING row, x, y, z, direction ordinal, flag out: isValidStateForPlacement (8.1): false when the cell already is the block with the face of the direction, else the neighbour in
*> that direction must be a solid block (canAttachTo).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-DIR L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-D1 = L-DIR + 1
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = WA-I(L-ROW, 1)
         MOVE WA-I(L-ROW, 1) TO WS-SLOT
         CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-STATE
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "FM-TABLE" USING WS-OP2 WS-SLOT WS-MASK WS-WL WS-STATE
         IF WS-MASK(WS-D1:1) = "1"
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
     COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
     COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
     CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ L-FLAG
     GOBACK.
 END PROGRAM FM-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-PLACE-STATE.
*> USING row, x, y, z, direction ordinal, state out, ok out: getStateForPlacement (8.1): null (ok 0) when the placement is not valid; else the state of the cell when it already is the block
*> (the base), else the default state, waterlogged when the cell holds a water source; with the face of the direction set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 01 WS-OP3                 BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-DIR L-STATE L-OK.
     MOVE 0 TO L-OK L-STATE
     CALL "FM-VALID" USING L-ROW L-X L-Y L-Z L-DIR WS-VALID
     IF WS-VALID = 0
         GOBACK
     END-IF
     COMPUTE WS-D1 = L-DIR + 1
     MOVE WA-I(L-ROW, 1) TO WS-SLOT
     CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-STATE
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = WA-I(L-ROW, 1)
         CALL "FM-TABLE" USING WS-OP2 WS-SLOT WS-MASK WS-WL WS-STATE
     ELSE
         MOVE "000000" TO WS-MASK
         MOVE 0 TO WS-WL
         IF WS-BLOCK = FL-B-WATER AND WS-STATE = CB-DEFAULT-STATE(FL-B-WATER)
             MOVE 1 TO WS-WL
         END-IF
     END-IF
     MOVE "1" TO WS-MASK(WS-D1:1)
     CALL "FM-TABLE" USING WS-OP3 WS-SLOT WS-MASK WS-WL L-STATE
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM FM-PLACE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-CAN-INTO.
*> USING row, x, y, z, face ordinal, flag out: canSpreadInto of the default spreader (8.1): the cell is air, the block or a water source, and the placement of the face is valid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FACE L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO WS-OPEN
     IF WS-CLASS = 1 OR WS-BLOCK = WA-I(L-ROW, 1)
         MOVE 1 TO WS-OPEN
     END-IF
     IF WS-BLOCK = FL-B-WATER AND WS-STATE = CB-DEFAULT-STATE(FL-B-WATER)
         MOVE 1 TO WS-OPEN
     END-IF
     IF WS-OPEN = 1
         CALL "FM-VALID" USING L-ROW L-X L-Y L-Z L-FACE L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FM-CAN-INTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-SPREAD.
*> USING state, row, x, y, z, face ordinal: spreadFromFaceTowardRandomDirection (8.1) for the block just written at the cell with the face: the six directions shuffled; for each one (not on the
*> axis of the face, the face set and the direction's face not set in the state of the cell) the first spread type whose position can be spread into (same position, same plane, wrap
*> around); the block is placed there (flag 2) and the search ends.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-LIST.
    05 WS-E                BINARY-LONG OCCURS 6 TIMES.
 01 WS-N                   BINARY-LONG VALUE 6.
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-AX1                 BINARY-LONG.
 01 WS-AX2                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-OP2                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-FACE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-E(WS-I) = WS-I - 1
     END-PERFORM
     CALL "FM-SHUFFLE" USING L-STATE WS-LIST WS-N
     MOVE 0 TO WS-DONE
     COMPUTE WS-F1 = L-FACE + 1
     MOVE WA-I(L-ROW, 1) TO WS-SLOT
     CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6 OR WS-DONE = 1
         MOVE WS-E(WS-I) TO WS-DIR
         COMPUTE WS-D1 = WS-DIR + 1
         CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
         CALL "FM-TABLE" USING WS-OP2 WS-SLOT WS-MASK WS-WL WS-STATE
         COMPUTE WS-AX1 = WS-DIR / 2
         COMPUTE WS-AX2 = L-FACE / 2
         IF WS-AX1 NOT = WS-AX2 AND WS-MASK(WS-F1:1) = "1" AND WS-MASK(WS-D1:1) = "0"
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 3 OR WS-DONE = 1
                 EVALUATE WS-T
                     WHEN 1
                         MOVE L-X TO WS-PX
                         MOVE L-Y TO WS-PY
                         MOVE L-Z TO WS-PZ
                         MOVE WS-DIR TO WS-PF
                     WHEN 2
                         COMPUTE WS-PX = L-X + FDR-DX(WS-D1)
                         COMPUTE WS-PY = L-Y + FDR-DY(WS-D1)
                         COMPUTE WS-PZ = L-Z + FDR-DZ(WS-D1)
                         MOVE L-FACE TO WS-PF
                     WHEN OTHER
                         COMPUTE WS-PX = L-X + FDR-DX(WS-D1) + FDR-DX(WS-F1)
                         COMPUTE WS-PY = L-Y + FDR-DY(WS-D1) + FDR-DY(WS-F1)
                         COMPUTE WS-PZ = L-Z + FDR-DZ(WS-D1) + FDR-DZ(WS-F1)
                         COMPUTE WS-PF = FDR-OPP(WS-D1)
                 END-EVALUATE
                 CALL "FM-CAN-INTO" USING L-ROW WS-PX WS-PY WS-PZ WS-PF WS-CAN
                 IF WS-CAN = 1
                     CALL "FM-PLACE-STATE" USING L-ROW WS-PX WS-PY WS-PZ WS-PF WS-NEW WS-OK
                     IF WS-OK = 1
                         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-NEW WS-FLAGS WS-WRITTEN
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FM-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FM-GROWTH.
*> USING state, row, x, y, z, directions (six integers), count, result out: placeGrowthIfPossible (8.2): for each direction in order whose neighbour block is in can_be_placed_on the state for
*> placement is made, a null state ends the call (false), else it is written (flag 2), a float is drawn and, when it is under the chance, the spread of FM-SPREAD runs; true.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-I                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-F                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIST.
    05 L-E                 BINARY-LONG OCCURS 6 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-LIST L-COUNT L-RESULT.
     MOVE 0 TO L-RESULT WS-STOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR WS-STOP = 1
         COMPUTE WS-D1 = L-E(WS-I) + 1
         COMPUTE WS-NX = L-X + FDR-DX(WS-D1)
         COMPUTE WS-NY = L-Y + FDR-DY(WS-D1)
         COMPUTE WS-NZ = L-Z + FDR-DZ(WS-D1)
         CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING WA-START(L-ROW, 1) WA-N(L-ROW, 1) WS-BLOCK WS-IN
         IF WS-IN = 1
             MOVE 1 TO WS-STOP
             CALL "FM-PLACE-STATE" USING L-ROW L-X L-Y L-Z L-E(WS-I) WS-NEW WS-OK
             IF WS-OK = 1
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-WRITTEN
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WA-F(L-ROW, 1) WS-U
                 IF WS-F < WS-U
                     CALL "FM-SPREAD" USING L-STATE L-ROW L-X L-Y L-Z L-E(WS-I)
                 END-IF
                 MOVE 1 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FM-GROWTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-MULTI-BOOL.
*> USING doc, node, value out: 1 when the node is the boolean true (an absent node and false give 0).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE.
     MOVE 0 TO L-VALUE
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-TRUE
             MOVE 1 TO L-VALUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-MULTI-BOOL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-MULTI-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY FDCONST.
 COPY FEATDATA.
 01 WS-K-BLOCK             PIC X(40) VALUE "block".
 01 WS-K-SET               PIC X(40) VALUE "can_be_placed_on".
 01 WS-K-RANGE             PIC X(40) VALUE "search_range".
 01 WS-K-FLOOR             PIC X(40) VALUE "can_place_on_floor".
 01 WS-K-CEILING           PIC X(40) VALUE "can_place_on_ceiling".
 01 WS-K-WALL              PIC X(40) VALUE "can_place_on_wall".
 01 WS-K-CHANCE            PIC X(40) VALUE "chance_of_spreading".
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 120.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-SLOT                BINARY-LONG.
 01 WS-MASK                PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OP1                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
*>   the block: a known block with the six face properties
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BLOCK WS-E
     MOVE SPACES TO WS-TEXT
     IF WS-E > 0
         CALL "JSON-STRING" USING JSON-DOC WS-E WS-TEXT WS-CAP WS-LEN
     END-IF
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO WS-KEY48
     CALL "FD-BLOCK-INDEX" USING WS-KEY48 WA-I(WS-ROW, 1)
     IF WA-I(WS-ROW, 1) = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     MOVE WA-I(WS-ROW, 1) TO WS-SLOT
     CALL "FM-TABLE" USING WS-OP1 WS-SLOT WS-MASK WS-WL WS-STATE
     IF WS-SLOT = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-SET WS-E
     CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 WA-START(WS-ROW, 1) WA-N(WS-ROW, 1)
     MOVE 10 TO WA-I(WS-ROW, 2)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-RANGE WS-E
     IF WS-E > 0
         CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 2) WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FLOOR WS-E
     CALL "FD-MULTI-BOOL" USING JSON-DOC WS-E WA-I(WS-ROW, 3)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CEILING WS-E
     CALL "FD-MULTI-BOOL" USING JSON-DOC WS-E WA-I(WS-ROW, 4)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-WALL WS-E
     CALL "FD-MULTI-BOOL" USING JSON-DOC WS-E WA-I(WS-ROW, 5)
     MOVE 0.5 TO WA-F(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-CHANCE WS-E
     IF WS-E > 0
         CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 1) WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-MULTI-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-MULTI.
*> USING state, feature, x, y, z, result out (1 when a block was written): 8.2. The origin must be air or water; the valid directions (UP when ceiling, DOWN when floor, then NORTH, EAST,
*> SOUTH, WEST when wall) are shuffled; growth at the origin (FM-GROWTH); else for each direction d in that order the valid directions without the opposite of d, shuffled, and the cell next to
*> the origin in direction d (reset to origin + d for each of the search_range repetitions, so one pass decides): a cell that is not air, water or the block ends it, else growth is tried there.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATDIR.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-VALID.
    05 WS-V                BINARY-LONG OCCURS 6 TIMES.
 01 WS-NV                  BINARY-LONG.
 01 WS-DIRS.
    05 WS-D                BINARY-LONG OCCURS 6 TIMES.
 01 WS-DIRS2.
    05 WS-D2               BINARY-LONG OCCURS 6 TIMES.
 01 WS-N2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-GROWN               BINARY-LONG.
 01 WS-LEAVE               BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 1 AND WS-CLASS NOT = 2
         GOBACK
     END-IF
     MOVE 0 TO WS-NV
     IF WA-I(WS-ROW, 4) = 1
         ADD 1 TO WS-NV
         MOVE 1 TO WS-V(WS-NV)
     END-IF
     IF WA-I(WS-ROW, 3) = 1
         ADD 1 TO WS-NV
         MOVE 0 TO WS-V(WS-NV)
     END-IF
     IF WA-I(WS-ROW, 5) = 1
         MOVE 2 TO WS-V(WS-NV + 1)
         MOVE 5 TO WS-V(WS-NV + 2)
         MOVE 3 TO WS-V(WS-NV + 3)
         MOVE 4 TO WS-V(WS-NV + 4)
         ADD 4 TO WS-NV
     END-IF
     MOVE WS-VALID TO WS-DIRS
     CALL "FM-SHUFFLE" USING L-STATE WS-DIRS WS-NV
     CALL "FM-GROWTH" USING L-STATE WS-ROW L-X L-Y L-Z WS-DIRS WS-NV WS-GROWN
     IF WS-GROWN = 1
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NV
         COMPUTE WS-D1 = WS-D(WS-I) + 1
         MOVE FDR-OPP(WS-D1) TO WS-OPP
         MOVE 0 TO WS-N2
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-NV
             IF WS-V(WS-J) NOT = WS-OPP
                 ADD 1 TO WS-N2
                 MOVE WS-V(WS-J) TO WS-D2(WS-N2)
             END-IF
         END-PERFORM
         CALL "FM-SHUFFLE" USING L-STATE WS-DIRS2 WS-N2
         MOVE 0 TO WS-LEAVE
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WA-I(WS-ROW, 2) OR WS-LEAVE = 1
             COMPUTE WS-CX = L-X + FDR-DX(WS-D1)
             COMPUTE WS-CY = L-Y + FDR-DY(WS-D1)
             COMPUTE WS-CZ = L-Z + FDR-DZ(WS-D1)
             CALL "FL-GET-STATE" USING WS-CX WS-CY WS-CZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-BLOCK = WA-I(WS-ROW, 1)
                 CALL "FM-GROWTH" USING L-STATE WS-ROW WS-CX WS-CY WS-CZ WS-DIRS2 WS-N2 WS-GROWN
                 IF WS-GROWN = 1
                     MOVE 1 TO L-RESULT
                     GOBACK
                 END-IF
*>               a growth that failed wrote nothing and drew nothing, and the cursor is reset to origin + d for every repetition, so the repetitions that follow would repeat it: the loop ends here
                 MOVE 1 TO WS-LEAVE
             ELSE
                 MOVE 1 TO WS-LEAVE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-MULTI.
