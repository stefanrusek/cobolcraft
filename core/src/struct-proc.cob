*> The structure processors at run time (docs/protocol/36-structures-2 sections 7.4, 8, 9; tables of STRUCTPROC.cpy compiled by struct-proc-load.cob) and processBlockInfos.
*> Random sources are java.util.Random states (rng-java.cob): a source seeded with Mth.getSeed(pos) is a fresh one per use; the settings' shared random (PS-RANDOM-SET) is one stream.
*> Float probabilities are float32 values (the data's numbers are rounded to float32 when compiled) and u = nextFloat() is exact, so `u < p` and `u <= chance` are the Java comparisons.
*>
*> Entry points:
*>   STRUCT-PROCESS USING row, palette (0-based), origin x, y, z, anchor x, y, z, settings: processBlockInfos (7.4): the palette's records in absolute positions into PW-REC, through the
*>     settings' processor list (PS-PROCESSORS, STRUCT-PROC-LOAD); with none the records are only moved and clipped to the box
*>   STRUCT-PROC-BLOCK USING proc row, STRUCT-PPOS, STRUCT-CUR, keep out (0 when the processor removes the block), settings: one processor's processBlock
*>   STRUCT-PROC-FINAL USING proc row, origin x, y, z, anchor x, y, z, settings: finalizeProcessing over PW-REC (the `capped` processor, 9.4)
*>   STRUCT-PROC-TEST USING test row, state, STRUCT-PPOS, rng state (BINARY-DOUBLE UNSIGNED, in and out), result out: a rule test of 8.3 (RECURSIVE)
*>   STRUCT-POS-RANDOM USING x, y, z, state out (BINARY-DOUBLE UNSIGNED): a legacy source seeded with Mth.getSeed(x, y, z)
*>   STRUCT-IP-SAMPLE USING type, a, b, c, state (in and out), result out: IntProvider.sample for the types of STRUCTPROC.cpy (23 section 7.1)
*> Not here: jigsaw_replacement and lava_submerged_block (a list that holds one does not compile, STRUCTPROC.cpy); the block entity tag is not kept, so the modifiers of 8.5 only set the
*> record's nbt flag (clear, append_static and append_loot leave a tag, passthrough keeps what there was); append_loot draws its seed from the rule's source as the game does.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-POS-RANDOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "XORO-GET-SEED" USING L-X L-Y L-Z WS-SEED
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING L-STATE WS-USEED
     GOBACK.
 END PROGRAM STRUCT-POS-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RNG-OPEN.
*> USING settings, x, y, z, state out (BINARY-DOUBLE UNSIGNED): StructurePlaceSettings.getRandom(pos) (4.2), as a state the caller draws from; STRUCT-RNG-CLOSE hands a shared stream back.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY STRUCTSET.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING STRUCT-SETTINGS L-X L-Y L-Z L-STATE.
     IF PS-RANDOM-SET = 1
         MOVE PS-RANDOM TO L-STATE
     ELSE
         CALL "STRUCT-POS-RANDOM" USING L-X L-Y L-Z L-STATE
     END-IF
     GOBACK.
 END PROGRAM STRUCT-RNG-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-RNG-CLOSE.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY STRUCTSET.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING STRUCT-SETTINGS L-STATE.
     IF PS-RANDOM-SET = 1
         MOVE L-STATE TO PS-RANDOM
     END-IF
     GOBACK.
 END PROGRAM STRUCT-RNG-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-IP-SAMPLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPAN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-SLOPE               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-A L-B L-C L-STATE L-RESULT.
     MOVE L-A TO L-RESULT
     COMPUTE WS-SPAN = L-B - L-A + 1
     EVALUATE L-TYPE
         WHEN 2
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-DRAW
             COMPUTE L-RESULT = L-A + WS-DRAW
         WHEN 3
*>           min + nextInt(nextInt(span) + 1), the inner draw first
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-A
             COMPUTE WS-BOUND = WS-A + 1
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             COMPUTE L-RESULT = L-A + WS-DRAW
         WHEN 4
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-A
             COMPUTE WS-BOUND = WS-A + 1
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-B
             COMPUTE WS-BOUND = WS-B + 1
             CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             COMPUTE L-RESULT = L-A + WS-DRAW
         WHEN 5
*>           trapezoid: min L-A, max L-B, plateau L-C
             COMPUTE WS-RANGE = L-B - L-A
             IF L-C = 0 AND L-B = 0 - L-A
                 COMPUTE WS-BOUND = L-B + 1
                 CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-A
                 CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-B
                 COMPUTE L-RESULT = WS-A - WS-B
             ELSE
                 IF L-C = WS-RANGE
                     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-SPAN WS-DRAW
                     COMPUTE L-RESULT = L-A + WS-DRAW
                 ELSE
                     COMPUTE WS-BOUND = WS-RANGE - L-C
                     DIVIDE WS-BOUND BY 2 GIVING WS-SLOPE
                     COMPUTE WS-SIDE = WS-RANGE - WS-SLOPE
                     COMPUTE WS-BOUND = WS-SIDE + 1
                     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-A
                     COMPUTE WS-BOUND = WS-SLOPE + 1
                     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-B
                     COMPUTE L-RESULT = L-A + WS-A + WS-B
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-IP-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-IN-SET.
*> USING pool first, count, state, flag out: 1 when the block of the state is among the SP-POOL entries.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-COUNT L-STATE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-STATE < 0 OR L-STATE >= CB-STATE-COUNT
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     PERFORM VARYING WS-I FROM L-FIRST BY 1 UNTIL WS-I >= L-FIRST + L-COUNT
         IF SP-POOL(WS-I) = WS-BLOCK
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-IN-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-TEST RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-U                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LOCAL-STORAGE SECTION.
 01 LS-CHILD               BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEST                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 COPY STRUCTPPOS.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEST L-STATE STRUCT-PPOS L-RNG L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE LS-BLOCK = CB-S-BLOCK(L-STATE + 1) + 1
     EVALUATE SPT-TYPE(L-TEST)
         WHEN 1
             MOVE 1 TO L-RESULT
         WHEN 2
             IF LS-BLOCK = SPT-A(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 3
             IF L-STATE = SPT-A(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 4
             CALL "SP-IN-SET" USING SPT-POOL(L-TEST) SPT-N(L-TEST) L-STATE L-RESULT
         WHEN 5
*>           the draw is made only when the block matches
             IF LS-BLOCK = SPT-A(L-TEST)
                 CALL "JRAND-NEXT-FLOAT" USING L-RNG WS-U
                 MOVE SPT-F(L-TEST) TO WS-P
                 IF WS-U < WS-P
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         WHEN 6
             IF L-STATE = SPT-A(L-TEST)
                 CALL "JRAND-NEXT-FLOAT" USING L-RNG WS-U
                 MOVE SPT-F(L-TEST) TO WS-P
                 IF WS-U < WS-P
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
         WHEN 7
             IF PP-Y >= SPT-B(L-TEST) AND PP-Y <= SPT-C(L-TEST)
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 8
*>           every child, stopping at the first false; no child is true
             MOVE 1 TO L-RESULT
             MOVE SPT-CHILD(L-TEST) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 0
                 CALL "STRUCT-PROC-TEST" USING LS-CHILD L-STATE STRUCT-PPOS L-RNG LS-SUB
                 MOVE LS-SUB TO L-RESULT
                 MOVE SPT-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN 9
             MOVE SPT-CHILD(L-TEST) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 1
                 CALL "STRUCT-PROC-TEST" USING LS-CHILD L-STATE STRUCT-PPOS L-RNG LS-SUB
                 MOVE LS-SUB TO L-RESULT
                 MOVE SPT-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN OTHER
             CALL "STRUCT-PROC-TEST" USING SPT-CHILD(L-TEST) L-STATE STRUCT-PPOS L-RNG LS-SUB
             IF LS-SUB = 0
                 MOVE 1 TO L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-PROC-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-POS.
*> USING test row, STRUCT-PPOS, rng state, result out: a position test (8.4): the linear chance (8.4.1), one draw whatever the distance, passing when u <= chance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-CHANCE-D            FLOAT-LONG.
 01 WS-CHANCE              FLOAT-SHORT.
 01 WS-CHANCE-L            FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TEST                 BINARY-LONG.
 COPY STRUCTPPOS.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEST STRUCT-PPOS L-RNG L-RESULT.
     MOVE 1 TO L-RESULT
     IF SPT-TYPE(L-TEST) = 21
         GOBACK
     END-IF
     COMPUTE WS-DX = FUNCTION ABS(PP-X - PP-AX)
     COMPUTE WS-DY = FUNCTION ABS(PP-Y - PP-AY)
     COMPUTE WS-DZ = FUNCTION ABS(PP-Z - PP-AZ)
     EVALUATE TRUE
         WHEN SPT-TYPE(L-TEST) = 22
             COMPUTE WS-D = WS-DX + WS-DY + WS-DZ
         WHEN SPT-D(L-TEST) = 0
             MOVE WS-DX TO WS-D
         WHEN SPT-D(L-TEST) = 1
             MOVE WS-DY TO WS-D
         WHEN OTHER
             MOVE WS-DZ TO WS-D
     END-EVALUATE
     COMPUTE WS-T = (WS-D - SPT-B(L-TEST)) / (SPT-C(L-TEST) - SPT-B(L-TEST))
     IF WS-T < 0
         MOVE 0 TO WS-T
     END-IF
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     MOVE SPT-F(L-TEST) TO WS-MIN
     MOVE SPT-F2(L-TEST) TO WS-MAX
     COMPUTE WS-CHANCE-D = WS-MIN + WS-T * (WS-MAX - WS-MIN)
     MOVE WS-CHANCE-D TO WS-CHANCE
     MOVE WS-CHANCE TO WS-CHANCE-L
     CALL "JRAND-NEXT-FLOAT" USING L-RNG WS-U
     IF WS-U > WS-CHANCE-L
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PROC-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-RULE.
*> USING proc row, STRUCT-PPOS, STRUCT-CUR: RuleProcessor.processBlock (8.1): the first rule whose three tests pass writes its output state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-PROC                 BINARY-LONG.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 PROCEDURE DIVISION USING L-PROC STRUCT-PPOS STRUCT-CUR.
     CALL "STRUCT-POS-RANDOM" USING CU-X CU-Y CU-Z WS-RNG
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SPP-N(L-PROC) OR WS-DONE = 1
         COMPUTE WS-R = SPP-A(L-PROC) + WS-I
         CALL "STRUCT-PROC-TEST" USING SPR-IN(WS-R) CU-STATE STRUCT-PPOS WS-RNG WS-MATCH
         IF WS-MATCH = 1
*>           the location test is against the world, except always_true, which does not read it
             IF SPT-TYPE(SPR-LOC(WS-R)) NOT = 1
                 CALL "FL-GET-STATE" USING CU-X CU-Y CU-Z WS-STATE
                 CALL "STRUCT-PROC-TEST" USING SPR-LOC(WS-R) WS-STATE STRUCT-PPOS WS-RNG WS-MATCH
             END-IF
         END-IF
         IF WS-MATCH = 1 AND SPR-POS(WS-R) > 0
             CALL "STRUCT-PROC-POS" USING SPR-POS(WS-R) STRUCT-PPOS WS-RNG WS-MATCH
         END-IF
         IF WS-MATCH = 1
             MOVE SPR-STATE(WS-R) TO CU-STATE
             IF SPR-MOD(WS-R) > 0
                 MOVE 1 TO CU-NBT
                 MOVE 0 TO CU-LOOT
             END-IF
*>           append_loot (8.5): the tag keeps the table and the signed first nextLong of the rule's source as LootTableSeed
             IF SPR-MOD(WS-R) = 3
                 CALL "JRAND-NEXT-LONG" USING WS-RNG WS-LONG
                 MOVE WS-R TO CU-LOOT
                 IF WS-LONG >= 9223372036854775808
                     COMPUTE CU-SEED = WS-LONG - 18446744073709551616
                 ELSE
                     MOVE WS-LONG TO CU-SEED
                 END-IF
             END-IF
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PROC-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-KEY-STATE.
*> USING key (PIC X(48), with or without minecraft:), state out: the default state of the block; air (0) when the block is not in the table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STATE.
     MOVE 0 TO L-STATE
     CALL "FD-BLOCK-INDEX" USING L-KEY WS-INDEX
     IF WS-INDEX > 0
         MOVE CB-DEFAULT-STATE(WS-INDEX) TO L-STATE
     END-IF
     GOBACK.
 END PROGRAM SP-KEY-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-BLACKSTONE.
*> USING STRUCT-CUR: BlackstoneReplaceProcessor (9.8): the block's replacement, in its default state, with facing, half and type copied when the source has them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-TARGET              PIC X(48).
 01 WS-STATE               BINARY-LONG.
 01 WS-NAMES               PIC X(80) VALUE "facing,half,type".
 01 WS-COPIED              BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTCUR.
 PROCEDURE DIVISION USING STRUCT-CUR.
     MOVE SPACES TO WS-TARGET
     EVALUATE FUNCTION TRIM(CB-KEY(CB-S-BLOCK(CU-STATE + 1) + 1))
         WHEN "cobblestone"
         WHEN "mossy_cobblestone"
             MOVE "blackstone" TO WS-TARGET
         WHEN "stone"
             MOVE "polished_blackstone" TO WS-TARGET
         WHEN "stone_bricks"
         WHEN "mossy_stone_bricks"
             MOVE "polished_blackstone_bricks" TO WS-TARGET
         WHEN "cobblestone_stairs"
         WHEN "mossy_cobblestone_stairs"
             MOVE "blackstone_stairs" TO WS-TARGET
         WHEN "stone_stairs"
             MOVE "polished_blackstone_stairs" TO WS-TARGET
         WHEN "stone_brick_stairs"
         WHEN "mossy_stone_brick_stairs"
             MOVE "polished_blackstone_brick_stairs" TO WS-TARGET
         WHEN "cobblestone_slab"
         WHEN "mossy_cobblestone_slab"
             MOVE "blackstone_slab" TO WS-TARGET
         WHEN "smooth_stone_slab"
         WHEN "stone_slab"
             MOVE "polished_blackstone_slab" TO WS-TARGET
         WHEN "stone_brick_slab"
         WHEN "mossy_stone_brick_slab"
             MOVE "polished_blackstone_brick_slab" TO WS-TARGET
         WHEN "stone_brick_wall"
         WHEN "mossy_stone_brick_wall"
             MOVE "polished_blackstone_brick_wall" TO WS-TARGET
         WHEN "cobblestone_wall"
         WHEN "mossy_cobblestone_wall"
             MOVE "blackstone_wall" TO WS-TARGET
         WHEN "chiseled_stone_bricks"
             MOVE "chiseled_polished_blackstone" TO WS-TARGET
         WHEN "cracked_stone_bricks"
             MOVE "cracked_polished_blackstone_bricks" TO WS-TARGET
         WHEN "iron_bars"
             MOVE "iron_chain" TO WS-TARGET
     END-EVALUATE
     IF WS-TARGET NOT = SPACES
         CALL "SP-KEY-STATE" USING WS-TARGET WS-STATE
         CALL "BLOCK-STATE-COPY" USING CU-STATE WS-STATE WS-NAMES WS-COPIED
         MOVE WS-COPIED TO CU-STATE
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PROC-BLACKSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-AGE-STAIRS.
*> USING rng state, state out: a stairs state with a random facing (nextInt(4): north, east, south, west) and half (nextInt(2): top, bottom), the draws in that order (9.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FACINGS.
    05 FILLER              PIC X(32) VALUE "north".
    05 FILLER              PIC X(32) VALUE "east".
    05 FILLER              PIC X(32) VALUE "south".
    05 FILLER              PIC X(32) VALUE "west".
 01 WS-FACING-TABLE REDEFINES WS-FACINGS.
    05 WS-FACING           PIC X(32) OCCURS 4 TIMES.
 01 WS-HALVES.
    05 FILLER              PIC X(32) VALUE "top".
    05 FILLER              PIC X(32) VALUE "bottom".
 01 WS-HALF-TABLE REDEFINES WS-HALVES.
    05 WS-HALF             PIC X(32) OCCURS 2 TIMES.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-RNG L-STATE.
     CALL "SP-KEY-STATE" USING L-KEY WS-STATE
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-BOUND WS-DRAW
     MOVE "facing" TO WS-NAME
     MOVE WS-FACING(WS-DRAW + 1) TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT L-STATE
     MOVE 2 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-BOUND WS-DRAW
     MOVE "half" TO WS-NAME
     MOVE WS-HALF(WS-DRAW + 1) TO WS-TEXT
     MOVE L-STATE TO WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT L-STATE
     GOBACK.
 END PROGRAM SP-AGE-STAIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-AGE-PICK.
*> USING rng state, mossiness (FLOAT-LONG), non-mossy list (two states), mossy list (two states), state out: pick(rng, nonMossy, mossy) of 9.9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-U                   FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-MOSS                 FLOAT-LONG.
 01 L-PLAIN.
    05 L-P                 BINARY-LONG OCCURS 2 TIMES.
 01 L-MOSSY.
    05 L-M                 BINARY-LONG OCCURS 2 TIMES.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-RNG L-MOSS L-PLAIN L-MOSSY L-STATE.
     CALL "JRAND-NEXT-FLOAT" USING L-RNG WS-U
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-BOUND WS-DRAW
     IF WS-U < L-MOSS
         MOVE L-M(WS-DRAW + 1) TO L-STATE
     ELSE
         MOVE L-P(WS-DRAW + 1) TO L-STATE
     END-IF
     GOBACK.
 END PROGRAM SP-AGE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-AGE.
*> USING proc row, settings, STRUCT-CUR: BlockAgeProcessor (9.9), the draws in the order of the worked example 11.8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-U                   FLOAT-LONG.
 01 WS-MOSS                FLOAT-LONG.
 01 WS-GATE                FLOAT-LONG.
 01 WS-GATE-S              FLOAT-SHORT.
 01 WS-KEY                 PIC X(48).
 01 WS-CLASS               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-PLAIN.
    05 WS-P                BINARY-LONG OCCURS 2 TIMES.
 01 WS-MOSSY.
    05 WS-M                BINARY-LONG OCCURS 2 TIMES.
 01 WS-STAIRS-A            BINARY-LONG.
 01 WS-STAIRS-B            BINARY-LONG.
 01 WS-KEY-STAIRS          PIC X(48) VALUE "stone_brick_stairs".
 01 WS-KEY-MOSSY-STAIRS    PIC X(48) VALUE "mossy_stone_brick_stairs".
 01 WS-KEY-CRACKED         PIC X(48) VALUE "cracked_stone_bricks".
 01 WS-KEY-MOSSY-BRICKS    PIC X(48) VALUE "mossy_stone_bricks".
 01 WS-KEY-MOSSY-SLAB      PIC X(48) VALUE "mossy_stone_brick_slab".
 01 WS-KEY-MOSSY-WALL      PIC X(48) VALUE "mossy_stone_brick_wall".
 01 WS-KEY-STONE-SLAB      PIC X(48) VALUE "stone_slab".
 01 WS-KEY-BRICK-SLAB      PIC X(48) VALUE "stone_brick_slab".
 01 WS-KEY-CRYING          PIC X(48) VALUE "crying_obsidian".
 01 WS-EMPTY-NAMES         PIC X(80) VALUE SPACES.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROC                 BINARY-LONG.
 COPY STRUCTSET.
 COPY STRUCTCUR.
 PROCEDURE DIVISION USING L-PROC STRUCT-SETTINGS STRUCT-CUR.
     CALL "STRUCT-RNG-OPEN" USING STRUCT-SETTINGS CU-X CU-Y CU-Z WS-RNG
     MOVE SPP-F(L-PROC) TO WS-MOSS
     MOVE 0 TO WS-NEW WS-CLASS
     MOVE FUNCTION TRIM(CB-KEY(CB-S-BLOCK(CU-STATE + 1) + 1)) TO WS-KEY
     EVALUATE TRUE
         WHEN WS-KEY = "stone_bricks" OR WS-KEY = "stone" OR WS-KEY = "chiseled_stone_bricks"
             MOVE 1 TO WS-CLASS
         WHEN WS-KEY = "obsidian"
             MOVE 5 TO WS-CLASS
         WHEN OTHER
             CALL "SP-IN-SET" USING SPP-POOL(L-PROC) SPP-A(L-PROC) CU-STATE WS-FLAG
             IF WS-FLAG = 1
                 MOVE 2 TO WS-CLASS
             END-IF
             IF WS-CLASS = 0
                 COMPUTE WS-TARGET = SPP-POOL(L-PROC) + SPP-A(L-PROC)
                 CALL "SP-IN-SET" USING WS-TARGET SPP-B(L-PROC) CU-STATE WS-FLAG
                 IF WS-FLAG = 1
                     MOVE 3 TO WS-CLASS
                 END-IF
             END-IF
             IF WS-CLASS = 0
                 COMPUTE WS-TARGET = SPP-POOL(L-PROC) + SPP-A(L-PROC) + SPP-B(L-PROC)
                 CALL "SP-IN-SET" USING WS-TARGET SPP-C(L-PROC) CU-STATE WS-FLAG
                 IF WS-FLAG = 1
                     MOVE 4 TO WS-CLASS
                 END-IF
             END-IF
     END-EVALUATE
     EVALUATE WS-CLASS
         WHEN 1
             MOVE 0.5 TO WS-GATE
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
             IF WS-U < WS-GATE
*>               four draws build the two lists: the non-mossy stairs first
                 CALL "SP-KEY-STATE" USING WS-KEY-CRACKED WS-P(1)
                 CALL "SP-AGE-STAIRS" USING WS-KEY-STAIRS WS-RNG WS-P(2)
                 CALL "SP-KEY-STATE" USING WS-KEY-MOSSY-BRICKS WS-M(1)
                 CALL "SP-AGE-STAIRS" USING WS-KEY-MOSSY-STAIRS WS-RNG WS-M(2)
                 CALL "SP-AGE-PICK" USING WS-RNG WS-MOSS WS-PLAIN WS-MOSSY WS-NEW
             END-IF
         WHEN 2
             MOVE 0.5 TO WS-GATE
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
             IF WS-U < WS-GATE
                 CALL "SP-KEY-STATE" USING WS-KEY-MOSSY-STAIRS WS-STAIRS-A
                 CALL "BLOCK-STATE-COPY" USING CU-STATE WS-STAIRS-A WS-EMPTY-NAMES WS-M(1)
                 CALL "SP-KEY-STATE" USING WS-KEY-MOSSY-SLAB WS-M(2)
                 CALL "SP-KEY-STATE" USING WS-KEY-STONE-SLAB WS-P(1)
                 CALL "SP-KEY-STATE" USING WS-KEY-BRICK-SLAB WS-P(2)
                 CALL "SP-AGE-PICK" USING WS-RNG WS-MOSS WS-PLAIN WS-MOSSY WS-NEW
             END-IF
         WHEN 3
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
             IF WS-U < WS-MOSS
                 CALL "SP-KEY-STATE" USING WS-KEY-MOSSY-SLAB WS-STAIRS-A
                 CALL "BLOCK-STATE-COPY" USING CU-STATE WS-STAIRS-A WS-EMPTY-NAMES WS-NEW
             END-IF
         WHEN 4
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
             IF WS-U < WS-MOSS
                 CALL "SP-KEY-STATE" USING WS-KEY-MOSSY-WALL WS-STAIRS-A
                 CALL "BLOCK-STATE-COPY" USING CU-STATE WS-STAIRS-A WS-EMPTY-NAMES WS-NEW
             END-IF
         WHEN 5
             MOVE 0.15 TO WS-GATE-S
             MOVE WS-GATE-S TO WS-GATE
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
             IF WS-U < WS-GATE
                 CALL "SP-KEY-STATE" USING WS-KEY-CRYING WS-NEW
             END-IF
     END-EVALUATE
     IF WS-NEW > 0
         MOVE WS-NEW TO CU-STATE
     END-IF
     CALL "STRUCT-RNG-CLOSE" USING STRUCT-SETTINGS WS-RNG
     GOBACK.
 END PROGRAM STRUCT-PROC-AGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-U                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROC                 BINARY-LONG.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 01 L-KEEP                 BINARY-LONG.
 COPY STRUCTSET.
 PROCEDURE DIVISION USING L-PROC STRUCT-PPOS STRUCT-CUR L-KEEP STRUCT-SETTINGS.
     MOVE 1 TO L-KEEP
     MOVE CU-X TO PP-X
     MOVE CU-Y TO PP-Y
     MOVE CU-Z TO PP-Z
     EVALUATE SPP-TYPE(L-PROC)
         WHEN 1
             CALL "STRUCT-PROC-RULE" USING L-PROC STRUCT-PPOS STRUCT-CUR
         WHEN 2
*>           protected blocks: the world's block at the position
             CALL "FL-GET-STATE" USING CU-X CU-Y CU-Z WS-STATE
             CALL "SP-IN-SET" USING SPP-POOL(L-PROC) SPP-N(L-PROC) WS-STATE WS-FLAG
             IF WS-FLAG = 1
                 MOVE 0 TO L-KEEP
             END-IF
         WHEN 3
             MOVE 1 TO WS-FLAG
             IF SPP-A(L-PROC) = 1
                 CALL "SP-IN-SET" USING SPP-POOL(L-PROC) SPP-N(L-PROC) CU-STATE WS-FLAG
             END-IF
*>           no draw for a block that cannot rot
             IF WS-FLAG = 1
                 CALL "STRUCT-RNG-OPEN" USING STRUCT-SETTINGS CU-X CU-Y CU-Z WS-RNG
                 CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
                 CALL "STRUCT-RNG-CLOSE" USING STRUCT-SETTINGS WS-RNG
                 MOVE SPP-F(L-PROC) TO WS-P
                 IF WS-U > WS-P
                     MOVE 0 TO L-KEEP
                 END-IF
             END-IF
         WHEN 5
             CALL "FL-HEIGHT-OF" USING SPP-A(L-PROC) CU-X CU-Z WS-HEIGHT
             COMPUTE CU-Y = WS-HEIGHT + SPP-B(L-PROC) + PP-LY
         WHEN 6
             CALL "STRUCT-PROC-JIGSAW" USING STRUCT-CUR L-KEEP
         WHEN 9
             CALL "SP-IN-SET" USING SPP-POOL(L-PROC) SPP-N(L-PROC) CU-STATE WS-FLAG
             IF WS-FLAG = 1
                 MOVE 0 TO L-KEEP
             END-IF
         WHEN 10
             CALL "STRUCT-PROC-BLACKSTONE" USING STRUCT-CUR
         WHEN 11
             CALL "STRUCT-PROC-AGE" USING L-PROC STRUCT-SETTINGS STRUCT-CUR
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-PROC-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROC-FINAL.
*> USING proc row, origin x, y, z, anchor x, y, z, settings: finalizeProcessing. Only `capped` has one (9.4): the delegate runs, in a shuffled order, over the processed records
*> until `limit` of them have actually changed. (The original and processed lists always have the same length here: the `originals` are PW-LX..PW-LZ of the same records.)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPROC.
 COPY STRUCTPLACE.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-FACTORY             BINARY-DOUBLE UNSIGNED.
 01 WS-POSSEED             BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TMP                 BINARY-LONG.
 01 WS-APPLIED             BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ORDER.
    05 WS-O                BINARY-LONG OCCURS 65536 TIMES.
 LINKAGE SECTION.
 01 L-PROC                 BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 COPY STRUCTSET.
 PROCEDURE DIVISION USING L-PROC L-OX L-OY L-OZ L-AX L-AY L-AZ STRUCT-SETTINGS.
     IF SPP-TYPE(L-PROC) NOT = 4
         GOBACK
     END-IF
*>   maxInclusive: a constant is its value (SPP-C), every other provider has its maximum in SPP-D.
     IF SPP-B(L-PROC) = 1
         MOVE SPP-C(L-PROC) TO WS-MAX
     ELSE
         MOVE SPP-D(L-PROC) TO WS-MAX
     END-IF
     IF WS-MAX = 0 OR PW-COUNT = 0
         GOBACK
     END-IF
*>   The positional factory of a source seeded with the level seed, at the origin (9.4 step 3).
     COMPUTE WS-USEED = FUNCTION MOD(PS-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-FACTORY
     CALL "XORO-GET-SEED" USING L-OX L-OY L-OZ WS-SEED
     COMPUTE WS-POSSEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-FACTORY WS-POSSEED BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-STATE WS-POSSEED
     CALL "STRUCT-IP-SAMPLE" USING SPP-B(L-PROC) SPP-C(L-PROC) SPP-D(L-PROC) SPP-E(L-PROC) WS-STATE WS-LIMIT
     MOVE FUNCTION MIN(WS-LIMIT, PW-COUNT) TO WS-CAP
     IF WS-CAP < 1
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-COUNT
         MOVE WS-I TO WS-O(WS-I)
     END-PERFORM
*>   Util.toShuffledList: for i from n down to 2, j = nextInt(i), swap the items at i - 1 and j.
     PERFORM VARYING WS-I FROM PW-COUNT BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-I WS-J
         COMPUTE WS-K = WS-J + 1
         MOVE WS-O(WS-I) TO WS-TMP
         MOVE WS-O(WS-K) TO WS-O(WS-I)
         MOVE WS-TMP TO WS-O(WS-K)
     END-PERFORM
     MOVE 0 TO WS-APPLIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PW-COUNT OR WS-APPLIED >= WS-CAP
         MOVE WS-O(WS-I) TO WS-R
         MOVE PW-X(WS-R) TO CU-X
         MOVE PW-Y(WS-R) TO CU-Y
         MOVE PW-Z(WS-R) TO CU-Z
         MOVE PW-STATE(WS-R) TO CU-STATE
         MOVE PW-NBT(WS-R) TO CU-NBT
         MOVE PW-LOOT(WS-R) TO CU-LOOT
         MOVE PW-SEED(WS-R) TO CU-SEED
         MOVE PW-LX(WS-R) TO PP-LX
         MOVE PW-LY(WS-R) TO PP-LY
         MOVE PW-LZ(WS-R) TO PP-LZ
         MOVE L-AX TO PP-AX
         MOVE L-AY TO PP-AY
         MOVE L-AZ TO PP-AZ
         CALL "STRUCT-PROC-BLOCK" USING SPP-A(L-PROC) STRUCT-PPOS STRUCT-CUR WS-KEEP STRUCT-SETTINGS
         IF WS-KEEP = 1 AND (CU-X NOT = PW-X(WS-R) OR CU-Y NOT = PW-Y(WS-R) OR CU-Z NOT = PW-Z(WS-R)
             OR CU-STATE NOT = PW-STATE(WS-R) OR CU-NBT NOT = PW-NBT(WS-R) OR CU-LOOT NOT = PW-LOOT(WS-R))
             ADD 1 TO WS-APPLIED
             MOVE CU-X TO PW-X(WS-R)
             MOVE CU-Y TO PW-Y(WS-R)
             MOVE CU-Z TO PW-Z(WS-R)
             MOVE CU-STATE TO PW-STATE(WS-R)
             MOVE CU-NBT TO PW-NBT(WS-R)
             MOVE CU-LOOT TO PW-LOOT(WS-R)
             MOVE CU-SEED TO PW-SEED(WS-R)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PROC-FINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PROCESS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTPLACE.
 COPY STRUCTPROC.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-ONLY-INSIDE         BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PALETTE              BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 COPY STRUCTSET.
 PROCEDURE DIVISION USING L-ROW L-PALETTE L-OX L-OY L-OZ L-AX L-AY L-AZ STRUCT-SETTINGS.
     MOVE 0 TO PW-COUNT
     MOVE 1 TO WS-ONLY-INSIDE
     MOVE 1 TO WS-FIRST
     MOVE 0 TO WS-LAST
     IF PS-PROCESSORS > 0
         MOVE SPL-FIRST(PS-PROCESSORS) TO WS-FIRST
         COMPUTE WS-LAST = SPL-FIRST(PS-PROCESSORS) + SPL-N(PS-PROCESSORS) - 1
*>       A processor that evaluates the entire piece (capped) lets the blocks outside the box through the pipeline.
         PERFORM VARYING WS-P FROM WS-FIRST BY 1 UNTIL WS-P > WS-LAST
             IF SPP-TYPE(WS-P) = 4
                 MOVE 0 TO WS-ONLY-INSIDE
             END-IF
         END-PERFORM
     END-IF
     COMPUTE WS-BASE = TP-BASE(L-ROW, L-PALETTE + 1)
     MOVE L-AX TO PP-AX
     MOVE L-AY TO PP-AY
     MOVE L-AZ TO PP-AZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(L-ROW)
         MOVE TB-X(WS-BASE + WS-I) TO WS-X PP-LX
         MOVE TB-Y(WS-BASE + WS-I) TO WS-Y PP-LY
         MOVE TB-Z(WS-BASE + WS-I) TO WS-Z PP-LZ
         CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z PS-MIRROR PS-ROTATION PS-PIVOT-X PS-PIVOT-Z WS-AX WS-AY WS-AZ
         ADD L-OX TO WS-AX
         ADD L-OY TO WS-AY
         ADD L-OZ TO WS-AZ
         MOVE 1 TO WS-INSIDE
         IF WS-ONLY-INSIDE = 1
             CALL "STRUCT-IN-BOX" USING WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-INSIDE
         END-IF
         IF WS-INSIDE = 1
             MOVE WS-AX TO CU-X
             MOVE WS-AY TO CU-Y
             MOVE WS-AZ TO CU-Z
             MOVE TB-STATE(WS-BASE + WS-I) TO CU-STATE
             MOVE TB-NBT(WS-BASE + WS-I) TO CU-NBT
             MOVE 0 TO CU-LOOT CU-SEED
             MOVE 1 TO WS-KEEP
             PERFORM VARYING WS-P FROM WS-FIRST BY 1 UNTIL WS-P > WS-LAST OR WS-KEEP = 0
                 CALL "STRUCT-PROC-BLOCK" USING WS-P STRUCT-PPOS STRUCT-CUR WS-KEEP STRUCT-SETTINGS
             END-PERFORM
             IF WS-KEEP = 1
                 ADD 1 TO PW-COUNT
                 MOVE CU-X TO PW-X(PW-COUNT)
                 MOVE CU-Y TO PW-Y(PW-COUNT)
                 MOVE CU-Z TO PW-Z(PW-COUNT)
                 MOVE CU-STATE TO PW-STATE(PW-COUNT)
                 MOVE TB-STATE(WS-BASE + WS-I) TO PW-TSTATE(PW-COUNT)
                 MOVE WS-X TO PW-LX(PW-COUNT)
                 MOVE WS-Y TO PW-LY(PW-COUNT)
                 MOVE WS-Z TO PW-LZ(PW-COUNT)
                 MOVE CU-NBT TO PW-NBT(PW-COUNT)
                 MOVE CU-LOOT TO PW-LOOT(PW-COUNT)
                 MOVE CU-SEED TO PW-SEED(PW-COUNT)
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-P FROM WS-FIRST BY 1 UNTIL WS-P > WS-LAST
         CALL "STRUCT-PROC-FINAL" USING WS-P L-OX L-OY L-OZ L-AX L-AY L-AZ STRUCT-SETTINGS
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-PROCESS.
