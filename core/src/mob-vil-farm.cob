*> The farmer's work activities (docs/protocol/44 part 3 sections 2.17, 4.1 and 3.3; 41 section 4.2; lane 002-lane-p49p): HarvestFarmland and UseBonemeal over the 3 x 3 x 3 cells round the
*> villager, with the villager's picking up of the farm items that lie near it. A farmer (profession farmer, mob_griefing on, secondary_job_site present for the harvest) in the work activity with no
*> walk target picks a cell on the brain beat (VL-FARM-START: Q3-HARVEST-START, else Q3-BONEMEAL-START with the reservoir pick over the growing crops) and walks to it; every tick while a cell is
*> held (VL-FARM-STEP: Q3-HARVEST-STEP, Q3-HARVEST-RECHOOSE, Q3-HARVEST-STOP, Q3-BONEMEAL-TICK, Q3-BONEMEAL-GREW, Q3-BONEMEAL-CONTINUE) it breaks a fully grown crop with its loot (a ground item),
*> plants a seed from its inventory on empty farmland and picks another cell, or grows a crop with bone meal (GB2-CROP-BONE). The inventory is one counter per farm item in VM-T (TM-WHEAT, TM-SEEDS,
*> TM-CARROT, TM-POTATO, TM-BEET-SEEDS, TM-BEETROOT, TM-BREAD, TM-BONEMEAL; no capacity limit, planting takes the seeds in the order wheat, carrot, potato, beetroot: the slot order is not
*> modelled). Gaps: the secondary_job_site memory is refreshed on the brain beat, not every 40 ticks (VL-FARM-START), the tickCount of UseBonemeal's start is the game tick rounded down to a multiple of
*> 10, the reservoir looks at the first 8 growing crops, no level event 1505, no composter work (WorkAtComposter's bread and compost).
*>   VL-CROP-AT USING dim, x, y, z, kind out (0 not a crop, 1 wheat, 2 carrots, 3 potatoes, 4 beetroots), age out, max age out, block key out (PIC X(32), spaces for air)
*>   VL-FARM-CELLS USING row, mode (1 harvest cells, 2 growing crops), count out, table out (27 cells x, y, z)
*>   VL-FARM-PICKUP USING row, slot                 the farm items within reach go into the inventory counters
*>   VL-FARM-START USING row, slot, active activity  VL-FARM-STEP USING row, slot

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CROP-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE                BINARY-LONG.
 01 WS-TEXT                 PIC X(160).
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-AGE                   BINARY-LONG.
 01 L-MAX                   BINARY-LONG.
 01 L-KEY                   PIC X(32).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-AGE L-MAX L-KEY.
     MOVE 0 TO L-KIND L-AGE L-MAX
     CALL "PXI-KEY-AT" USING L-DIM L-X L-Y L-Z L-KEY
     EVALUATE L-KEY
         WHEN "wheat"
             MOVE 1 TO L-KIND
             MOVE 7 TO L-MAX
         WHEN "carrots"
             MOVE 2 TO L-KIND
             MOVE 7 TO L-MAX
         WHEN "potatoes"
             MOVE 3 TO L-KIND
             MOVE 7 TO L-MAX
         WHEN "beetroots"
             MOVE 4 TO L-KIND
             MOVE 3 TO L-MAX
     END-EVALUATE
     IF L-KIND > 0
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
         CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-TEXT
         COMPUTE L-AGE = FUNCTION NUMVAL(WS-TEXT(5:1))
     END-IF
     GOBACK.
 END PROGRAM VL-CROP-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-CELLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-BELOW                BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-AGE                  BINARY-LONG.
 01 WS-MAX                  BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-KEY-BELOW            PIC X(32).
 01 WS-FULL                 BINARY-LONG.
 01 WS-AIR                  BINARY-LONG.
 01 WS-FARMLAND             BINARY-LONG.
 01 WS-KIND-B               BINARY-LONG.
 01 WS-AGE-B                BINARY-LONG.
 01 WS-MAX-B                BINARY-LONG.
 01 WS-VALID                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-MODE                  BINARY-LONG.
 01 L-COUNT                 BINARY-LONG.
 01 L-TABLE.
    05 L-CELL               OCCURS 27 TIMES.
       10 L-CX              BINARY-LONG.
       10 L-CY              BINARY-LONG.
       10 L-CZ              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MODE L-COUNT L-TABLE.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 1
             PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW) + WS-DX)
                 COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW) + WS-DY)
                 COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW) + WS-DZ)
                 CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
                 MOVE 0 TO WS-VALID
                 IF L-MODE = 1
                     MOVE 0 TO WS-FULL WS-AIR WS-FARMLAND
                     IF WS-KIND > 0 AND WS-AGE >= WS-MAX
                         MOVE 1 TO WS-FULL
                     END-IF
                     IF WS-KEY = SPACES
                         MOVE 1 TO WS-AIR
                         COMPUTE WS-BELOW = WS-Y - 1
                         CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-BELOW WS-Z WS-KIND-B WS-AGE-B WS-MAX-B WS-KEY-BELOW
                         IF WS-KEY-BELOW = "farmland"
                             MOVE 1 TO WS-FARMLAND
                         END-IF
                     END-IF
                     CALL "Q3-HARVEST-CELL" USING WS-FULL WS-AIR WS-FARMLAND WS-VALID
                 ELSE
                     IF WS-KIND > 0 AND WS-AGE < WS-MAX
                         MOVE 1 TO WS-VALID
                     END-IF
                 END-IF
                 IF WS-VALID = 1
                     ADD 1 TO L-COUNT
                     MOVE WS-X TO L-CX(L-COUNT)
                     MOVE WS-Y TO L-CY(L-COUNT)
                     MOVE WS-Z TO L-CZ(L-COUNT)
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM VL-FARM-CELLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-PICKUP.
*> USING row, slot: ItemEntity pick-up by a villager (41 section 4.2, 19 section 22.6 wantsToPickUp): a ground item of a farm item within 1.3 blocks horizontally and without pickup delay goes into the counters;
*> the viewers get Take Item Entity and the entity is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY VLMEM.
 COPY PROTO.
 01 WS-READY                PIC 9 VALUE 0.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 01 WS-N                    BINARY-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-KEY                  PIC X(48).
 01 WS-KEY48                PIC X(48).
 01 WS-COUNT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = CR-LOOSE-ITEM AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-ITEM-COUNT(WS-N) > 0
                 AND EN-DELAY(WS-N) <= 0
             COMPUTE WS-DX = EN-X(WS-N) - EN-X(L-ROW)
             COMPUTE WS-DZ = EN-Z(WS-N) - EN-Z(L-ROW)
             COMPUTE WS-DY = EN-Y(WS-N) - EN-Y(L-ROW)
             IF WS-DX >= -1.3 AND WS-DX <= 1.3 AND WS-DZ >= -1.3 AND WS-DZ <= 1.3 AND WS-DY >= -1.0 AND WS-DY <= 2.0
                 MOVE IT-KEY(EN-ITEM(WS-N) + 1) TO WS-KEY48
                 IF WS-KEY48(1:10) = "minecraft:"
                     MOVE WS-KEY48(11:38) TO WS-KEY
                 ELSE
                     MOVE WS-KEY48 TO WS-KEY
                 END-IF
                 MOVE 0 TO WS-T
                 EVALUATE WS-KEY
                     WHEN "wheat"
                         MOVE TM-WHEAT TO WS-T
                     WHEN "wheat_seeds"
                         MOVE TM-SEEDS TO WS-T
                     WHEN "carrot"
                         MOVE TM-CARROT TO WS-T
                     WHEN "potato"
                         MOVE TM-POTATO TO WS-T
                     WHEN "beetroot_seeds"
                         MOVE TM-BEET-SEEDS TO WS-T
                     WHEN "beetroot"
                         MOVE TM-BEETROOT TO WS-T
                     WHEN "bread"
                         MOVE TM-BREAD TO WS-T
                     WHEN "bone_meal"
                         MOVE TM-BONEMEAL TO WS-T
                 END-EVALUATE
                 IF WS-T > 0
                     MOVE EN-ITEM-COUNT(WS-N) TO WS-COUNT
                     ADD WS-COUNT TO VM-T(L-SLOT, WS-T)
                     CALL "PB-RESET" USING PB-BUFFER
                     CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(WS-N) EN-ID(L-ROW) WS-COUNT PB-BUFFER
                     CALL "GI-VIEWERS-SEND" USING WS-N PB-BUFFER
                     MOVE 0 TO EN-ITEM-COUNT(WS-N)
                     CALL "ENTITY-REMOVE" USING WS-N
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-FARM-PICKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-GROUND.
*> USING row, slot, x, y, z of the cell: the cell is the villager's target: remembered in the timers and walked to (speed 0.5, closeness 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 01 WS-SPEED                FLOAT-LONG VALUE 0.5.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-X L-Y L-Z.
     MOVE L-X TO VM-T(L-SLOT, TM-CELL-X)
     MOVE L-Y TO VM-T(L-SLOT, TM-CELL-Y)
     MOVE L-Z TO VM-T(L-SLOT, TM-CELL-Z)
     MOVE 1 TO VM-T(L-SLOT, TM-CELL-ON)
     CALL "VL-WALK-SET" USING L-ROW L-SLOT EN-DIM(L-ROW) L-X L-Y L-Z WS-SPEED WS-ONE
     GOBACK.
 END PROGRAM VL-FARM-GROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 COPY VILSTATE.
 01 WS-RULE-NAME            PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                 BINARY-DOUBLE.
 01 WS-GRIEFING             BINARY-LONG.
 01 WS-FARMER               BINARY-LONG.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-TABLE.
    05 WS-CELL              OCCURS 27 TIMES.
       10 WS-CX             BINARY-LONG.
       10 WS-CY             BINARY-LONG.
       10 WS-CZ             BINARY-LONG.
 01 WS-MODE-HARVEST         BINARY-LONG VALUE 1.
 01 WS-MODE-GROW            BINARY-LONG VALUE 2.
 01 WS-NOW                  BINARY-LONG.
 01 WS-BOUND                BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 169.
 01 WS-SALT-2               BINARY-LONG VALUE 171.
 01 WS-TICK                 BINARY-LONG.
 01 WS-MEAL                 BINARY-LONG.
 01 WS-TARGET               BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-I                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ACT.
     IF L-ACT NOT = VA-WORK OR VL-PROF(L-SLOT) NOT = "farmer" OR VM-T(L-SLOT, TM-CELL-ON) = 1
         GOBACK
     END-IF
     CALL "VM-HAS" USING L-SLOT MT-WALK-TARGET WS-PRESENT
     IF WS-PRESENT = 1
         GOBACK
     END-IF
     MOVE CW-TICKS TO WS-NOW
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     MOVE WS-RULE TO WS-GRIEFING
     MOVE 1 TO WS-FARMER
*>   The secondary_job_site sensor: farmland within 4 blocks in x and z and 2 in y (44 section 4.1), only for a farmer.
     CALL "VL-FARM-SENSE" USING L-ROW L-SLOT
     CALL "VM-HAS" USING L-SLOT MT-SECONDARY-JOB-SITE WS-PRESENT
     IF WS-PRESENT = 1
         CALL "VL-FARM-CELLS" USING L-ROW WS-MODE-HARVEST WS-COUNT WS-TABLE
         COMPUTE WS-BOUND = FUNCTION MAX(WS-COUNT, 1)
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         CALL "Q3-HARVEST-START" USING WS-GRIEFING WS-FARMER WS-NOW VM-T(L-SLOT, TM-HARVEST-OK) WS-COUNT WS-DRAW WS-PICK
         IF WS-PICK > 0
             MOVE 1 TO VM-T(L-SLOT, TM-FARM-MODE)
             MOVE 0 TO VM-T(L-SLOT, TM-HARVEST-WORKED)
             CALL "VL-FARM-GROUND" USING L-ROW L-SLOT WS-CX(WS-PICK) WS-CY(WS-PICK) WS-CZ(WS-PICK)
             GOBACK
         END-IF
     END-IF
*>   UseBonemeal: bone meal in the inventory and a growing crop within the cube; the reservoir draws (nextInt(c) for the c-th crop) pick one.
     CALL "VL-FARM-CELLS" USING L-ROW WS-MODE-GROW WS-COUNT WS-TABLE
     MOVE 0 TO WS-MEAL WS-TARGET
     IF VM-T(L-SLOT, TM-BONEMEAL) > 0
         MOVE 1 TO WS-MEAL
     END-IF
     IF WS-COUNT > 0
         MOVE 1 TO WS-TARGET
     END-IF
     COMPUTE WS-TICK = WS-NOW - FUNCTION MOD(WS-NOW, 10)
     CALL "Q3-BONEMEAL-START" USING WS-TICK VM-T(L-SLOT, TM-BONE-LAST) WS-MEAL WS-TARGET WS-YES
     IF WS-YES = 1 AND WS-GRIEFING = 1
         MOVE FUNCTION MIN(WS-COUNT, 8) TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             CALL "XP-RANDOM" USING WS-SALT-2 WS-I WS-DRAW-T(WS-I)
         END-PERFORM
         CALL "Q3-RESERVOIR" USING WS-N WS-DRAWS WS-PICK
         MOVE 2 TO VM-T(L-SLOT, TM-FARM-MODE)
         MOVE 0 TO VM-T(L-SLOT, TM-BONE-WORKED)
         MOVE WS-NOW TO VM-T(L-SLOT, TM-BONE-NEXT)
         CALL "VL-FARM-GROUND" USING L-ROW L-SLOT WS-CX(WS-PICK) WS-CY(WS-PICK) WS-CZ(WS-PICK)
     END-IF
     GOBACK.
 END PROGRAM VL-FARM-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-SENSE.
*> USING row, slot: SecondaryPoiSensor (44 section 4.1) for a farmer: farmland within 4 blocks in x and z and 2 in y of the villager's block; the memory secondary_job_site is the nearest-in-scan-order
*> farmland, or absent when there is none. Scans at most every 40 ticks (Q3-SECONDARY decides store or erase).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-FX                   BINARY-LONG.
 01 WS-FY                   BINARY-LONG.
 01 WS-FZ                   BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-AGE                  BINARY-LONG.
 01 WS-MAX                  BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-FARMER               BINARY-LONG VALUE 1.
 01 WS-ACTION               BINARY-LONG.
 01 WS-NOW                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE CW-TICKS TO WS-NOW
     IF WS-NOW < VM-T(L-SLOT, TM-SENS-SECONDARY)
         GOBACK
     END-IF
     COMPUTE VM-T(L-SLOT, TM-SENS-SECONDARY) = WS-NOW + 40
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 4
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 4
                 COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DX
                 COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DY
                 COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DZ
                 CALL "PXI-KEY-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KEY
                 IF WS-KEY = "farmland"
                     ADD 1 TO WS-COUNT
                     IF WS-COUNT = 1
                         MOVE WS-X TO WS-FX
                         MOVE WS-Y TO WS-FY
                         MOVE WS-Z TO WS-FZ
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "Q3-SECONDARY" USING WS-FARMER WS-COUNT WS-ACTION
     IF WS-ACTION = 1
         CALL "VM-AT" USING L-SLOT MT-SECONDARY-JOB-SITE EN-DIM(L-ROW) WS-FX WS-FY WS-FZ
     ELSE
         CALL "VM-ERASE" USING L-SLOT MT-SECONDARY-JOB-SITE
     END-IF
     GOBACK.
 END PROGRAM VL-FARM-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-PLACE.
*> USING row, slot, x, y, z of an empty farmland cell: plants a seed of the inventory (wheat seeds, carrots, potatoes, beetroot seeds in that order) as a crop of age 0; seeds out (1 when planted).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-T                    BINARY-LONG.
 01 WS-KEY                  PIC X(112).
 01 WS-PAIRS                PIC X(160) VALUE "age=0".
 01 WS-STATE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-PLANTED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-X L-Y L-Z L-PLANTED.
     MOVE 0 TO L-PLANTED WS-T
     EVALUATE TRUE
         WHEN VM-T(L-SLOT, TM-SEEDS) > 0
             MOVE TM-SEEDS TO WS-T
             MOVE "minecraft:wheat" TO WS-KEY
         WHEN VM-T(L-SLOT, TM-CARROT) > 0
             MOVE TM-CARROT TO WS-T
             MOVE "minecraft:carrots" TO WS-KEY
         WHEN VM-T(L-SLOT, TM-POTATO) > 0
             MOVE TM-POTATO TO WS-T
             MOVE "minecraft:potatoes" TO WS-KEY
         WHEN VM-T(L-SLOT, TM-BEET-SEEDS) > 0
             MOVE TM-BEET-SEEDS TO WS-T
             MOVE "minecraft:beetroots" TO WS-KEY
     END-EVALUATE
     IF WS-T > 0
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
         CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-STATE
         SUBTRACT 1 FROM VM-T(L-SLOT, WS-T)
         MOVE 1 TO L-PLANTED
     END-IF
     GOBACK.
 END PROGRAM VL-FARM-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FARM-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-NOW                  BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-AGE                  BINARY-LONG.
 01 WS-MAX                  BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-KEY-BELOW            PIC X(32).
 01 WS-BELOW                BINARY-LONG.
 01 WS-KIND-B               BINARY-LONG.
 01 WS-AGE-B                BINARY-LONG.
 01 WS-MAX-B                BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-AIR                  BINARY-LONG VALUE 0.
 01 WS-PLANTED              BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-TABLE.
    05 WS-CELL              OCCURS 27 TIMES.
       10 WS-CX             BINARY-LONG.
       10 WS-CY             BINARY-LONG.
       10 WS-CZ             BINARY-LONG.
 01 WS-MODE-HARVEST         BINARY-LONG VALUE 1.
 01 WS-MODE-GROW            BINARY-LONG VALUE 2.
 01 WS-BOUND                BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 173.
 01 WS-SALT-2               BINARY-LONG VALUE 175.
 01 WS-SALT-3               BINARY-LONG VALUE 177.
 01 WS-TOOL                 BINARY-LONG VALUE 0.
 01 WS-TOOL-COUNT           BINARY-LONG VALUE 0.
 01 WS-TOOL-HANDLE          BINARY-LONG VALUE 0.
 01 WS-RADIUS-SET           BINARY-LONG VALUE 0.
 01 WS-RADIUS               FLOAT-LONG VALUE 0.
 01 WS-FOUND                BINARY-LONG.
 01 WS-HAS-CELL             BINARY-LONG VALUE 1.
 01 WS-GREW                 BINARY-LONG.
 01 WS-KEY112               PIC X(112).
 01 WS-PAIRS                PIC X(160).
 01 WS-BI.
    05 WS-BI-BLOCK          BINARY-LONG.
    05 WS-BI-AGE            BINARY-LONG.
    05 WS-BI-DRAW           BINARY-LONG.
    05 FILLER               BINARY-LONG OCCURS 13 TIMES.
 01 WS-BO.
    05 WS-BO-VALID          BINARY-LONG.
    05 WS-BO-SUCCESS        BINARY-LONG.
    05 WS-BO-NEW            BINARY-LONG.
    05 FILLER               BINARY-LONG OCCURS 13 TIMES.
 01 WS-FOUR                 BINARY-LONG VALUE 4.
 01 WS-AGE-TEXT             PIC 9.
 01 WS-DRAWS.
    05 WS-DRAW-T            BINARY-LONG OCCURS 8 TIMES.
 01 WS-I                    BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-HAS-TARGET           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     MOVE CW-TICKS TO WS-NOW
     IF VM-ACT(L-SLOT) NOT = VA-WORK
*>       Both behaviours belong to the work activity.
         MOVE 0 TO VM-T(L-SLOT, TM-CELL-ON)
         CALL "VL-WALK-STOP" USING L-ROW L-SLOT
         GOBACK
     END-IF
     IF FUNCTION MOD(WS-NOW + L-SLOT, 5) = 0
         CALL "VL-FARM-PICKUP" USING L-ROW L-SLOT
     END-IF
     MOVE VM-T(L-SLOT, TM-CELL-X) TO WS-X
     MOVE VM-T(L-SLOT, TM-CELL-Y) TO WS-Y
     MOVE VM-T(L-SLOT, TM-CELL-Z) TO WS-Z
     CALL "VL-BRAIN-DIST" USING L-ROW WS-X WS-Y WS-Z WS-D2
     MOVE 0 TO WS-NEAR
     IF WS-D2 <= 1
         MOVE 1 TO WS-NEAR
     END-IF
     IF VM-T(L-SLOT, TM-FARM-MODE) = 1
*>       HarvestFarmland.
         CALL "Q3-HARVEST-STEP" USING WS-HAS-CELL WS-NEAR WS-NOW VM-T(L-SLOT, TM-HARVEST-OK) VM-T(L-SLOT, TM-HARVEST-WORKED) WS-ACT
         IF WS-ACT = 1
             CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
             IF WS-KIND > 0 AND WS-AGE >= WS-MAX
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                 CALL "BLOCK-DROPS-SPAWN" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE WS-TOOL WS-TOOL-COUNT WS-TOOL-HANDLE
                     WS-RADIUS-SET WS-RADIUS WS-FOUND
                 CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AIR
             END-IF
             CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
             IF WS-KEY = SPACES
                 COMPUTE WS-BELOW = WS-Y - 1
                 CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-BELOW WS-Z WS-KIND-B WS-AGE-B WS-MAX-B WS-KEY-BELOW
                 IF WS-KEY-BELOW = "farmland"
                     CALL "VL-FARM-PLACE" USING L-ROW L-SLOT WS-X WS-Y WS-Z WS-PLANTED
                 END-IF
             END-IF
             CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
             IF WS-KIND > 0 AND WS-AGE < WS-MAX
*>               Planted or still growing: another cell from the rest of the list.
                 CALL "VL-FARM-CELLS" USING L-ROW WS-MODE-HARVEST WS-COUNT WS-TABLE
                 COMPUTE WS-BOUND = FUNCTION MAX(WS-COUNT, 1)
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
                 CALL "Q3-HARVEST-RECHOOSE" USING WS-COUNT WS-DRAW WS-NOW VM-T(L-SLOT, TM-HARVEST-OK) WS-PICK
                 IF WS-PICK > 0
                     CALL "VL-FARM-GROUND" USING L-ROW L-SLOT WS-CX(WS-PICK) WS-CY(WS-PICK) WS-CZ(WS-PICK)
                 END-IF
             END-IF
         END-IF
         CALL "Q3-HARVEST-CONTINUE" USING VM-T(L-SLOT, TM-HARVEST-WORKED) WS-YES
         IF WS-YES = 0
             CALL "Q3-HARVEST-STOP" USING WS-NOW VM-T(L-SLOT, TM-HARVEST-OK) VM-T(L-SLOT, TM-HARVEST-WORKED)
             MOVE 0 TO VM-T(L-SLOT, TM-CELL-ON)
             CALL "VL-WALK-STOP" USING L-ROW L-SLOT
         END-IF
     ELSE
*>       UseBonemeal.
         CALL "Q3-BONEMEAL-TICK" USING WS-NOW VM-T(L-SLOT, TM-BONE-NEXT) WS-NEAR VM-T(L-SLOT, TM-BONE-WORKED) WS-ACT
         MOVE 1 TO WS-HAS-TARGET
         IF WS-ACT = 1 AND VM-T(L-SLOT, TM-BONEMEAL) > 0
             CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
             MOVE 0 TO WS-GREW
             IF WS-KIND > 0 AND WS-AGE < WS-MAX
                 MOVE WS-KIND TO WS-BI-BLOCK
                 MOVE WS-AGE TO WS-BI-AGE
                 CALL "XP-RANDOM" USING WS-SALT-2 WS-FOUR WS-BI-DRAW
                 CALL "GB2-CROP-BONE" USING WS-BI WS-BO
                 IF WS-BO-VALID = 1
                     MOVE 1 TO WS-GREW
                     MOVE SPACES TO WS-KEY112
                     STRING "minecraft:" DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-KEY112
                     MOVE WS-BO-NEW TO WS-AGE-TEXT
                     MOVE SPACES TO WS-PAIRS
                     STRING "age=" DELIMITED BY SIZE WS-AGE-TEXT DELIMITED BY SIZE INTO WS-PAIRS
                     CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-STATE
                     CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                     SUBTRACT 1 FROM VM-T(L-SLOT, TM-BONEMEAL)
                 END-IF
             END-IF
             CALL "Q3-BONEMEAL-GREW" USING WS-GREW WS-NOW VM-T(L-SLOT, TM-BONE-NEXT)
             IF WS-GREW = 1
                 CALL "VL-FARM-CELLS" USING L-ROW WS-MODE-GROW WS-COUNT WS-TABLE
                 MOVE FUNCTION MIN(WS-COUNT, 8) TO WS-N
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                     CALL "XP-RANDOM" USING WS-SALT-3 WS-I WS-DRAW-T(WS-I)
                 END-PERFORM
                 CALL "Q3-RESERVOIR" USING WS-N WS-DRAWS WS-PICK
                 MOVE 0 TO WS-HAS-TARGET
                 IF WS-PICK > 0
                     MOVE 1 TO WS-HAS-TARGET
                     CALL "VL-FARM-GROUND" USING L-ROW L-SLOT WS-CX(WS-PICK) WS-CY(WS-PICK) WS-CZ(WS-PICK)
                 END-IF
             END-IF
         END-IF
         CALL "Q3-BONEMEAL-CONTINUE" USING VM-T(L-SLOT, TM-BONE-WORKED) WS-HAS-TARGET WS-YES
         IF WS-YES = 0
             MOVE WS-NOW TO VM-T(L-SLOT, TM-BONE-LAST)
             MOVE 0 TO VM-T(L-SLOT, TM-CELL-ON)
             CALL "VL-WALK-STOP" USING L-ROW L-SLOT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-FARM-STEP.
