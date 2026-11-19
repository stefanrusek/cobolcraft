*> Acceptance test, farmers harvest and replant, and grow crops with bone meal (docs/protocol/44 part 3 sections 2.17 and 4.1; 26 loot; 41 section 4.2; lane 002-lane-p49p, T35007): a farmer in the
*> work activity beside fully grown wheat breaks it (the loot lands as ground items that the villager picks up), plants a seed on the empty farmland and goes on to the next cell; a farmer with bone
*> meal next to growing wheat grows it; a villager that is no farmer does neither. Needs the real content (CC_GENERATED_DIR) for the loot table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-FARM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-KEY32               PIC X(32).
 01 WS-MATURE              BINARY-LONG.
 01 WS-YOUNG               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-AGE-TEXT            PIC 9.
 01 WS-ENV                 PIC X(1024).
 01 WS-ROOT                PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-LOOT                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   The loot tables of the content set (a world opens them with WORLD-LOOT-OPEN; the test world does not).
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV NOT = SPACES
         MOVE SPACES TO WS-ROOT
         STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
         CALL "LOOT-LOAD" USING WS-ROOT WS-STATUS
         IF WS-STATUS = 0
             MOVE 1 TO WS-LOOT
         END-IF
     END-IF
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
*>   Three farmland cells in a row with fully grown wheat, a composter (the farmer's job site) 3 blocks away.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         MOVE "minecraft:farmland" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-FY WS-Z0 WS-KEY WS-PAIRS
         MOVE "minecraft:wheat" TO WS-KEY
         MOVE "age=7" TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     END-PERFORM
     COMPUTE WS-Z = WS-Z0 + 3
     MOVE "minecraft:composter" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X0 WS-Y WS-Z WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     COMPUTE WS-X = WS-X0 + 1
     COMPUTE WS-Z = WS-Z0 + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-S
     MOVE "farmer" TO VL-PROF(WS-S)
     COMPUTE WS-Z = WS-Z0 + 3
     CALL "VP-CLAIM" USING WS-DIM WS-X0 WS-Y WS-Z EN-ID(WS-V)
     MOVE 2 TO VM-T(WS-S, TM-SEEDS)
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
         CALL "GROUND-ITEMS-TICK"
     END-PERFORM
     MOVE 0 TO WS-MATURE WS-YOUNG
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-ID WS-AGE WS-MAX WS-KEY32
         IF WS-ID = 1 AND WS-AGE >= 7
             ADD 1 TO WS-MATURE
         END-IF
         IF WS-ID = 1 AND WS-AGE < 7
             ADD 1 TO WS-YOUNG
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.17 the farmer harvested fully grown wheat (fewer than 3 mature cells left)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MATURE < 3
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.17 and replanted: at least one young wheat plant stands in a cell" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-YOUNG >= 1
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     IF WS-LOOT = 1
         MOVE "acceptance US15 41§4.2 the loot was picked up: the villager carries wheat" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF VM-T(WS-S, TM-WHEAT) > 0
             MOVE 1 TO WS-O
         END-IF
         CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     END-IF
     CALL "VM-HAS" USING WS-S MT-SECONDARY-JOB-SITE WS-O
     MOVE "acceptance US15 44-3§4.1 the secondary_job_site memory holds the farmland" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Bone meal: every plant is young, there is no empty farmland, the farmer has bone meal.
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         MOVE "minecraft:wheat" TO WS-KEY
         MOVE "age=1" TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     END-PERFORM
     MOVE 5 TO VM-T(WS-S, TM-BONEMEAL)
     MOVE 0 TO VM-T(WS-S, TM-SEEDS)
     MOVE 0 TO VM-T(WS-S, TM-HARVEST-OK)
     MOVE 0 TO VM-T(WS-S, TM-CELL-ON)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-ID WS-AGE WS-MAX WS-KEY32
         ADD WS-AGE TO WS-SUM
     END-PERFORM
     MOVE "acceptance US15 44-3§2.17 UseBonemeal grew the crops (the ages sum to more than 3)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-SUM > 3
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.17 and used up bone meal (fewer than 5 left)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VM-T(WS-S, TM-BONEMEAL) < 5
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A villager that is no farmer does not harvest.
     MOVE "none" TO VL-PROF(WS-S)
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         MOVE "minecraft:wheat" TO WS-KEY
         MOVE "age=7" TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     END-PERFORM
     MOVE 0 TO VM-T(WS-S, TM-CELL-ON)
     MOVE 0 TO VM-T(WS-S, TM-HARVEST-OK)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE 0 TO WS-MATURE
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 2
         COMPUTE WS-X = WS-X0 + WS-K
         CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-ID WS-AGE WS-MAX WS-KEY32
         IF WS-AGE >= 7
             ADD 1 TO WS-MATURE
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.17 a villager without the farmer profession leaves the wheat alone" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-MATURE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-FARM.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
