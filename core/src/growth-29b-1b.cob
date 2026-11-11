*> Crops, saplings and bone meal of 29b part 1 sections 5 to 7 wired into the play path (specs 002 phase 42): the random ticks of CropBlock (6.2, 6.3) and SaplingBlock (7.1) through hook rows (GB-GROWTH-ROWS,
*> called by GB-RULES-OPEN), reading the raw brightness (LIGHT-RAW) and the level random (LEVEL-RANDOM-INT), and bone meal through Use Item On (GB-BONEMEAL-USE from BLOCK-USE-ON, 5.3). A crop is a block whose
*> key is wheat, carrots, potatoes or beetroots with the age as its only property (state index = age; the largest age is the state count minus 1); the growing ground is the block "minecraft:farmland" with its
*> moisture as its only property (state index = moisture). A sapling is `<kind>_sapling` with the stage as its only property. A sapling that reaches stage 1 and ticks again would grow its tree: the
*> tree features (35) are not built, so it stays at stage 1 (the rollback of 7.3). Not wired: bone meal on bushes (5.4), the water plant branch of 5.3, the bee goal (5.5) and every other BonemealableBlock.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-GROWTH-KIND.
*> USING block key (PIC X(48)), kind out (0 other, 1 crop, 2 sapling): the blocks of this wiring.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-KIND.
     MOVE 0 TO L-KIND
     COMPUTE WS-N = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     IF L-KEY = "minecraft:wheat" OR L-KEY = "minecraft:carrots" OR L-KEY = "minecraft:potatoes" OR L-KEY = "minecraft:beetroots"
         MOVE 1 TO L-KIND
     END-IF
     IF WS-N > 17 AND L-KEY(WS-N - 7:8) = "_sapling"
         MOVE 2 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM GB-GROWTH-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-GROWTH-ROWS.
*> USING block id, kind (1 crop, 2 sapling) (BINARY-LONG): registers the rows of one growth block unless it has them: the random-ticking marker (kind 11) and the random tick (kind 8) with effect 7 for a crop, 8 for a
*> sapling.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BUSTATE.
 01 WS-R                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-KIND.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
         IF BU-R-KIND(WS-R) = 8 AND BU-R-BLOCK(WS-R) = L-BLOCK AND BU-R-EFFECT(WS-R) > 6
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE 11 TO WS-KIND
         MOVE 0 TO WS-EFFECT
         CALL "BU-RULE-ADD" USING WS-KIND L-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
         MOVE 8 TO WS-KIND
         COMPUTE WS-EFFECT = 6 + L-KIND
         CALL "BU-RULE-ADD" USING WS-KIND L-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
     END-IF
     GOBACK.
 END PROGRAM GB-GROWTH-ROWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-CROP-RT.
*> USING dimension row, x, y, z (BINARY-LONG): CropBlock.randomTick (6.2): the age is the state's index in its block; the speed is getGrowthSpeed (6.3) over the 3 x 3 below (farmland is class 1, 3 with moisture above 0),
*> the same crop along x and z or at a diagonal halving it; with raw brightness 9 and age below the largest the crop grows on nextInt(int(25 / speed) + 1) = 0 (one draw, only then), written with flags 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-IN.
    05 WS-CLASS            BINARY-LONG OCCURS 9 TIMES.
    05 WS-ALONG-X          BINARY-LONG.
    05 WS-ALONG-Z          BINARY-LONG.
    05 WS-DIAGONAL         BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-GROWS               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-FARM                PIC X(48) VALUE "minecraft:farmland".
 01 WS-IS-FARM             BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE CB-FIRST-STATE(WS-BLOCK + 1) TO WS-FIRST
     COMPUTE WS-AGE = WS-STATE - WS-FIRST
     COMPUTE WS-MAX = CB-STATES(WS-BLOCK + 1) - 1
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BL WS-LIGHT
     COMPUTE WS-CY = L-Y - 1
     MOVE 0 TO WS-ALONG-X WS-ALONG-Z WS-DIAGONAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         COMPUTE WS-DX = FUNCTION INTEGER((WS-I - 1) / 3) - 1
         COMPUTE WS-DZ = FUNCTION MOD(WS-I - 1, 3) - 1
         COMPUTE WS-CX = L-X + WS-DX
         COMPUTE WS-CZ = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-NB
         MOVE 0 TO WS-CLASS(WS-I)
         MOVE CB-KEY(CB-S-BLOCK(WS-NB + 1) + 1) TO WS-KEY
         IF WS-KEY = WS-FARM
             MOVE 1 TO WS-CLASS(WS-I)
             IF WS-NB > CB-FIRST-STATE(CB-S-BLOCK(WS-NB + 1) + 1)
                 MOVE 3 TO WS-CLASS(WS-I)
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-DX = FUNCTION INTEGER((WS-I - 1) / 3) - 1
         COMPUTE WS-DZ = FUNCTION MOD(WS-I - 1, 3) - 1
         IF WS-I > 4
             COMPUTE WS-DX = FUNCTION INTEGER(WS-I / 3) - 1
             COMPUTE WS-DZ = FUNCTION MOD(WS-I, 3) - 1
         END-IF
         COMPUTE WS-CX = L-X + WS-DX
         COMPUTE WS-CZ = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX L-Y WS-CZ WS-NB
         IF CB-S-BLOCK(WS-NB + 1) = WS-BLOCK
             IF WS-DX NOT = 0 AND WS-DZ = 0
                 MOVE 1 TO WS-ALONG-X
             END-IF
             IF WS-DX = 0 AND WS-DZ NOT = 0
                 MOVE 1 TO WS-ALONG-Z
             END-IF
             IF WS-DX NOT = 0 AND WS-DZ NOT = 0
                 MOVE 1 TO WS-DIAGONAL
             END-IF
         END-IF
     END-PERFORM
     CALL "GB-CROP-SPEED" USING WS-IN WS-SPEED
     MOVE 1 TO WS-DRAW
     CALL "GB-CROP-TICK" USING WS-LIGHT WS-AGE WS-MAX WS-SPEED WS-DRAW WS-BOUND WS-GROWS
     IF WS-BOUND > 0
         CALL "LEVEL-RANDOM-INT" USING WS-BOUND WS-DRAW
         CALL "GB-CROP-TICK" USING WS-LIGHT WS-AGE WS-MAX WS-SPEED WS-DRAW WS-BOUND WS-GROWS
         IF WS-GROWS = 1
             COMPUTE WS-NEW = WS-FIRST + WS-AGE + 1
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GB-CROP-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-SAPLING-RT.
*> USING dimension row, x, y, z (BINARY-LONG): SaplingBlock.randomTick (7.1): with the raw brightness of the cell above (with the sky darkening of the time, the one-argument form of 7.1) at least 9 and nextInt(7) = 0
*> the sapling advances: stage 0 is written as stage 1 with flags 260; stage 1 would grow the tree, which this core cannot place (35), so it stays.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BL                  BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SERVER              BINARY-LONG VALUE 1.
 01 WS-CAN                 BINARY-LONG VALUE 1.
 01 WS-INSIDE              BINARY-LONG VALUE 1.
 01 WS-FLOAT               FLOAT-LONG VALUE 0.
 01 WS-TICK                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SUCCESS             BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 260.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     COMPUTE WS-STAGE = WS-STATE - CB-FIRST-STATE(WS-BLOCK + 1)
     COMPUTE WS-ABOVE = L-Y + 1
     CALL "LIGHT-RAW" USING L-DIM L-X WS-ABOVE L-Z WS-SKY WS-BL WS-RAW
     CALL "WORLDSIM-DARKEN" USING L-DIM WS-DARKEN
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-BL, WS-SKY - WS-DARKEN)
     CALL "LEVEL-RANDOM-INT" USING WS-SEVEN WS-DRAW
     CALL "GB-SAPLING" USING WS-LIGHT WS-DRAW WS-STAGE WS-SERVER WS-CAN WS-INSIDE WS-FLOAT WS-TICK WS-ACTION WS-VALID WS-SUCCESS
     IF WS-TICK = 1 AND WS-STAGE = 0
         COMPUTE WS-NEW = WS-STATE + 1
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     END-IF
     GOBACK.
 END PROGRAM GB-SAPLING-RT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-BONEMEAL-USE.
*> USING connection id, x, y, z (BINARY-LONG), used out: BoneMealItem.useOn (5.3) for the clicked crop or sapling when the held item is bone meal: a crop below its largest age is valid and always succeeds, its age rising by
*> U(2, 5) (nextInt(4) + 2, 6.4, flags 2); a sapling in this core is always a valid target and succeeds on nextFloat < 0.45 (7.1), advancing to stage 1 (flags 260). A valid target costs one item whether or not the test
*> passed (survival and creative alike: the stack shrinks on the server, 5.3 step 2), and a level event 1505 with data 15 goes to the viewers. Anything else is not used (used 0, the item stays).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-FIRST               BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DRAW                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-NEW-AGE             BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EVENT               BINARY-LONG VALUE 1505.
 01 WS-DATA                BINARY-LONG VALUE 15.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-USED.
     MOVE 0 TO L-USED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-ROW) L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE CB-KEY(WS-BLOCK + 1) TO WS-KEY
     CALL "GB-GROWTH-KIND" USING WS-KEY WS-KIND
     MOVE CB-FIRST-STATE(WS-BLOCK + 1) TO WS-FIRST
     COMPUTE WS-AGE = WS-STATE - WS-FIRST
     COMPUTE WS-MAX = CB-STATES(WS-BLOCK + 1) - 1
     MOVE 0 TO WS-VALID
     IF WS-KIND = 1 AND WS-AGE < WS-MAX
         MOVE 1 TO WS-VALID
         CALL "LEVEL-RANDOM-INT" USING WS-FOUR WS-DRAW
         CALL "GB-CROP-BONEMEAL" USING WS-AGE WS-MAX WS-DRAW WS-VALID WS-NEW-AGE
         COMPUTE WS-NEW = WS-FIRST + WS-NEW-AGE
         MOVE 2 TO WS-FLAGS
         CALL "LEVEL-SET-BLOCK" USING PL-DIM(WS-ROW) L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
     END-IF
     IF WS-KIND = 2
         MOVE 1 TO WS-VALID
         CALL "LEVEL-RANDOM-FLOAT" USING WS-FLOAT
         IF WS-FLOAT < 0.45 AND WS-AGE = 0
             COMPUTE WS-NEW = WS-STATE + 1
             MOVE 260 TO WS-FLAGS
             CALL "LEVEL-SET-BLOCK" USING PL-DIM(WS-ROW) L-X L-Y L-Z WS-NEW WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
     END-IF
     IF WS-VALID = 1
         MOVE 1 TO L-USED
         MOVE PL-HELD(WS-ROW) TO WS-HELD
         CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         CALL "INV-SLOT-SEND" USING L-ID WS-HELD
         CALL "LEVEL-EVENT" USING PL-DIM(WS-ROW) WS-EVENT L-X L-Y L-Z WS-DATA WS-NONE
     END-IF
     GOBACK.
 END PROGRAM GB-BONEMEAL-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GB-HELD-BONEMEAL.
*> USING item id (BINARY-LONG), bone meal out: 1 when the item's key is minecraft:bone_meal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-BONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-BONE.
     MOVE 0 TO L-BONE
     IF IT-KEY(L-ITEM + 1) = "minecraft:bone_meal"
         MOVE 1 TO L-BONE
     END-IF
     GOBACK.
 END PROGRAM GB-HELD-BONEMEAL.
