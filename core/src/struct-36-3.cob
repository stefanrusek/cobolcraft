*> JigsawPlacement.generateJigsaw (docs/protocol/36-structures-3 section 15): the jigsaw assembly started at a position of the LIVE world, the entry point of the /place jigsaw command and of the
*> Generate action of the jigsaw block (BE6-JIGSAW-GENERATE, be-31-6.cob).
*>
*> Entry point:
*>   JIG-GENERATE USING dimension row, pool key (PIC X(80), "namespace:path"), target name (PIC X(80)), maximum depth, x, y, z (the position, BINARY-LONG), keepJigsaws (0 or 1), result out:
*>     result 1 the pieces were placed (generateJigsaw's true), 0 no structure resulted (the pool has no element, no jigsaw of the element is named like the target, a pool of 0 entries; false),
*>     2 the pool is no template pool (the command's commands.place.jigsaw.invalid).
*>
*> The assembly is JIG-ASSEMBLE with the options of STRUCT-JIG-OPTS (JO-AT): a scratch structure row (the last row of the structure table) carries the arguments, that is size = the maximum
*> depth, MaxDistance 128 both ways, no heightmap, no pool alias, the zero padding (not checked), apply_waterlogging, no expansion hack; the context random is the large feature seed of the chunk that
*> holds the position (as worldgen) and the biome predicate is always true (no biome test). Every piece is then written with an unbounded write box: chunk by chunk, each chunk that a piece box
*> reaches is made ready first (WORLD-CHUNK, which may generate it), the pieces are built again (the generation of those chunks reuses the builder), and the chunk is written on a copy of its
*> cells through JIG-POST (the pivot is the position, the write box the chunk's, 14.3); the cells that differ from before are then set in the live chunk with LEVEL-SET-BLOCK, flags 18 (the
*> client is told; no shape updates), inside a light batch, and the block entities and entities the pieces asked for are made (the channels of gen-be.cob and gen-ent.cob).
*> Deviations: the dimension heights of the assembler are the overworld's (min y -64, max y 319); the jigsaw block entities that a keepJigsaws placement leaves are the defaults (the template
*> cache holds no block entity data: name, pool, target, final_state and joint are not copied).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-GENERATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY GENENT.
 78 K-CHUNKS               VALUE 1024.
 01 WS-SCRATCH-ROW         BINARY-LONG.
 01 WS-POOL                BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-CBOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==C-==.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 18.
 01 WS-BUDGET              BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-CHUNKS.
    05 WC-N                BINARY-LONG.
    05 WC-REC OCCURS K-CHUNKS TIMES.
       10 WC-X             BINARY-LONG.
       10 WC-Z             BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-SCRATCH.
    05 WS-S-STATES         PIC X(196608).
    05 WS-S-TABLE REDEFINES WS-S-STATES.
       10 WS-S-STATE       BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
    05 WS-S-REST           PIC X(108032).
 01 WS-BEFORE.
    05 WS-B-STATES         PIC X(196608).
    05 WS-B-TABLE REDEFINES WS-B-STATES.
       10 WS-B-STATE       BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-POOL                 PIC X(80).
 01 L-TARGET               PIC X(80).
 01 L-DEPTH                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KEEP                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-POOL L-TARGET L-DEPTH L-X L-Y L-Z L-KEEP L-RESULT.
     GO TO MAIN-LINE.

*> the assembly at the position: the builder holds the pieces and WS-VALID is 1 when there is a structure
 ASSEMBLE.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     IF TP-COUNT > 100 OR TP-USED > 250000 OR TN-USED > 5000 OR JE-COUNT > 1400 OR JP-COUNT > 130 OR JN-USED > 3000 OR JS-COUNT > 400
         CALL "STRUCT-TPL-RESET"
         CALL "JIG-RESET"
     END-IF
     CALL "JIG-ASSEMBLE" USING WS-SCRATCH-ROW WS-SEED WS-CX WS-CZ WS-SX WS-SY WS-SZ WS-VALID.

*> the chunk (WS-CX, WS-CZ) written on a copy of the live chunk, then the cells that changed set through the level
 PLACE-CHUNK.
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CE-CHUNK TO WS-SCRATCH
     MOVE CE-STATES TO WS-B-STATES
     SET WS-PTR TO ADDRESS OF WS-SCRATCH
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ DM-MIN-Y(L-DIM) DM-HEIGHT(L-DIM) WS-SEA
     CALL "MSP-OPEN"
     MOVE FL-MIN-Y TO SW-Y0
     MOVE 0 TO GBL-COUNT GBL-LOST GEL-COUNT GEL-LOST GEL-BOX-COUNT GEL-BOX-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         CALL "SPB-BOX-INTERSECTS" USING SP-BOX(WS-I) SP-WBOX WS-FLAG
         IF WS-FLAG = 1
             CALL "JIG-POST" USING WS-I
         END-IF
     END-PERFORM
     CALL "FL-CLOSE"
     IF WS-S-STATES NOT = WS-B-STATES
         CALL "LIGHT-BATCH-BEGIN"
         COMPUTE WS-CELLS = DM-HEIGHT(L-DIM) * 256
         PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > WS-CELLS
             IF WS-S-STATE(WS-CELL) NOT = WS-B-STATE(WS-CELL)
                 COMPUTE WS-LOCAL = WS-CELL - 1
                 COMPUTE WS-WY = DM-MIN-Y(L-DIM) + FUNCTION INTEGER(WS-LOCAL / 256)
                 COMPUTE WS-LOCAL = FUNCTION MOD(WS-LOCAL, 256)
                 COMPUTE WS-WZ = WS-CZ * 16 + FUNCTION INTEGER(WS-LOCAL / 16)
                 COMPUTE WS-WX = WS-CX * 16 + FUNCTION MOD(WS-LOCAL, 16)
                 MOVE WS-S-STATE(WS-CELL) TO WS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM WS-WX WS-WY WS-WZ WS-NEW WS-FLAGS WS-BUDGET WS-DONE
             END-IF
         END-PERFORM
         CALL "LIGHT-BATCH-END"
     END-IF
*>   the block entities and entities the pieces asked for (the channels are the generation job's: the level's lists are published as the installed ones)
     MOVE GEN-BE-LEVEL TO GB-DATA
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "GBE-APPLY" USING L-DIM WS-ROW
     MOVE GEN-ENT-LEVEL TO GE-DATA
     MOVE 0 TO GEL-COUNT GEL-LOST GEL-BOX-COUNT GEL-BOX-LOST
     CALL "GENT-APPLY" USING L-DIM WS-ROW.

 MAIN-LINE.
     MOVE 0 TO L-RESULT
     MOVE SD-MAX-STRUCTS TO WS-SCRATCH-ROW
     MOVE L-POOL TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     IF WS-POOL = 0
         MOVE 2 TO L-RESULT
         GOBACK
     END-IF
*>   the scratch row: the arguments of 15 and the constants of step 2
     MOVE L-POOL TO SDT-JIG-POOL(WS-SCRATCH-ROW)
     MOVE L-DEPTH TO SDT-JIG-SIZE(WS-SCRATCH-ROW)
     MOVE 0 TO SDT-JIG-Y(WS-SCRATCH-ROW) SDT-JIG-HACK(WS-SCRATCH-ROW) SDT-JIG-PADB(WS-SCRATCH-ROW) SDT-JIG-PADT(WS-SCRATCH-ROW)
     MOVE 0 TO SDT-JIG-LIQ(WS-SCRATCH-ROW) SDT-JIG-PADSET(WS-SCRATCH-ROW) SDT-JIG-YKIND(WS-SCRATCH-ROW) SDT-JIG-Y2(WS-SCRATCH-ROW)
     MOVE 0 TO SDT-JIG-AL-FIRST(WS-SCRATCH-ROW) SDT-JIG-AL-N(WS-SCRATCH-ROW)
     MOVE -1 TO SDT-JIG-PROJ(WS-SCRATCH-ROW)
     MOVE 128 TO SDT-JIG-HOR(WS-SCRATCH-ROW) SDT-JIG-VER(WS-SCRATCH-ROW)
     MOVE 1 TO SDT-JIG-OK(WS-SCRATCH-ROW) SDT-JIG-NAMED(WS-SCRATCH-ROW)
     MOVE L-TARGET TO SDT-JIG-NAME(WS-SCRATCH-ROW)
     MOVE 1 TO JO-AT
     MOVE L-KEEP TO JO-KEEP
     MOVE L-X TO JO-X
     MOVE L-Y TO JO-Y
     MOVE L-Z TO JO-Z
     MOVE CW-SEED TO WS-SEED
     MOVE CW-SEED TO SP-SEED
     PERFORM ASSEMBLE
     IF WS-VALID = 0
         MOVE 0 TO JO-AT JO-KEEP
         GOBACK
     END-IF
*>   the chunks that a piece box reaches: the chunks of the union of the boxes that some piece box touches
     CALL "SPB-UNION-ALL" USING WS-BOX
     COMPUTE WS-X0 = FUNCTION INTEGER(B-X0 / 16)
     COMPUTE WS-X1 = FUNCTION INTEGER(B-X1 / 16)
     COMPUTE WS-Z0 = FUNCTION INTEGER(B-Z0 / 16)
     COMPUTE WS-Z1 = FUNCTION INTEGER(B-Z1 / 16)
     MOVE 0 TO WC-N
     PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1
         PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1
             COMPUTE C-X0 = WS-CX * 16
             COMPUTE C-X1 = C-X0 + 15
             COMPUTE C-Z0 = WS-CZ * 16
             COMPUTE C-Z1 = C-Z0 + 15
             MOVE 0 TO C-Y0
             MOVE 0 TO C-Y1
             MOVE 0 TO WS-N
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT OR WS-N = 1
                 CALL "SPB-BOX-INTERSECTS-XZ" USING SP-BOX(WS-I) WS-CBOX WS-N
             END-PERFORM
             IF WS-N = 1 AND WC-N < K-CHUNKS
                 ADD 1 TO WC-N
                 MOVE WS-CX TO WC-X(WC-N)
                 MOVE WS-CZ TO WC-Z(WC-N)
             END-IF
         END-PERFORM
     END-PERFORM
*>   every chunk is made ready (the generation of a chunk may run starts of its own: the builder is not kept), then the pieces are built again
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WC-N
         CALL "WORLD-CHUNK" USING L-DIM WC-X(WS-K) WC-Z(WS-K) WS-ROW
     END-PERFORM
     MOVE L-X TO SP-PIV-X
     MOVE L-Y TO SP-PIV-Y
     MOVE L-Z TO SP-PIV-Z
     PERFORM ASSEMBLE
     CALL "DIM-SEA-LEVEL-OF" USING L-DIM WS-SEA
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WC-N
         MOVE WC-X(WS-K) TO WS-CX
         MOVE WC-Z(WS-K) TO WS-CZ
         PERFORM PLACE-CHUNK
     END-PERFORM
     MOVE 0 TO JO-AT JO-KEEP
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM JIG-GENERATE.
