*> Test of special use 3.1 (17 section 3.1; core/src/tools-use.cob): the axe strips, scrapes and unwaxes, the shovel flattens, the hoe
*> tills, the honeycomb waxes, the shield priority skip and the campfire extinguish rule. Faces: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-USE-3-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-KIND                PIC X(8).
 01 WS-KEY                 PIC X(48).
 01 WS-FACE                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NEW                 PIC X(48).
 01 WS-SOUND               PIC X(32).
 01 WS-PARTICLE            PIC X(16).
 01 WS-LOOT                PIC X(32).
 01 WS-UPDATE              BINARY-LONG.
 01 WS-COPY                BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-ST1                 PIC X(300).
 01 WS-ST2                 PIC X(300).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WOODS-TABLE.
    05 FILLER              PIC X(12) VALUE "oak".
    05 FILLER              PIC X(12) VALUE "dark_oak".
    05 FILLER              PIC X(12) VALUE "pale_oak".
    05 FILLER              PIC X(12) VALUE "poplar".
    05 FILLER              PIC X(12) VALUE "acacia".
    05 FILLER              PIC X(12) VALUE "cherry".
    05 FILLER              PIC X(12) VALUE "birch".
    05 FILLER              PIC X(12) VALUE "jungle".
    05 FILLER              PIC X(12) VALUE "spruce".
    05 FILLER              PIC X(12) VALUE "mangrove".
 01 WOODS REDEFINES WOODS-TABLE.
    05 WOOD                PIC X(12) OCCURS 10 TIMES.
 01 FAMILY-TABLE.
    05 FILLER              PIC X(24) VALUE "copper".
    05 FILLER              PIC X(24) VALUE "cut_copper".
    05 FILLER              PIC X(24) VALUE "cut_copper_slab".
    05 FILLER              PIC X(24) VALUE "cut_copper_stairs".
    05 FILLER              PIC X(24) VALUE "chiseled_copper".
    05 FILLER              PIC X(24) VALUE "copper_trapdoor".
    05 FILLER              PIC X(24) VALUE "copper_bars".
    05 FILLER              PIC X(24) VALUE "copper_grate".
    05 FILLER              PIC X(24) VALUE "copper_bulb".
    05 FILLER              PIC X(24) VALUE "copper_chain".
    05 FILLER              PIC X(24) VALUE "copper_lantern".
    05 FILLER              PIC X(24) VALUE "copper_golem_statue".
    05 FILLER              PIC X(24) VALUE "lightning_rod".
    05 FILLER              PIC X(24) VALUE "copper_chest".
    05 FILLER              PIC X(24) VALUE "copper_door".
 01 FAMILIES REDEFINES FAMILY-TABLE.
    05 FAMILY              PIC X(24) OCCURS 15 TIMES.
 01 LEVEL-TABLE.
    05 FILLER              PIC X(12) VALUE "exposed_".
    05 FILLER              PIC X(12) VALUE "weathered_".
    05 FILLER              PIC X(12) VALUE "oxidized_".
 01 LEVELS REDEFINES LEVEL-TABLE.
    05 LEVEL-NAME          PIC X(12) OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE "acceptance US14 axe strips oak_log to stripped_oak_log with sound item.axe.strip, no particle, the properties copied" TO TL-CASE
     MOVE "axe" TO WS-KIND
     MOVE "oak_log" TO WS-KEY
     MOVE 2 TO WS-FACE
     MOVE 0 TO WS-AIR
     PERFORM DO-TRANS
     MOVE "found 1 stripped_oak_log item.axe.strip - - 1 1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe has 25 strip rules: ten woods as log and wood, warped and crimson stem and hyphae, bamboo_block" TO TL-CASE
     MOVE 0 TO WS-COUNT
     MOVE "axe" TO WS-KIND
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > 10
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WOOD(WS-W)) "_log" DELIMITED BY SIZE INTO WS-KEY
         PERFORM COUNT-FOUND
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WOOD(WS-W)) "_wood" DELIMITED BY SIZE INTO WS-KEY
         PERFORM COUNT-FOUND
     END-PERFORM
     MOVE "warped_stem" TO WS-KEY
     PERFORM COUNT-FOUND
     MOVE "warped_hyphae" TO WS-KEY
     PERFORM COUNT-FOUND
     MOVE "crimson_stem" TO WS-KEY
     PERFORM COUNT-FOUND
     MOVE "crimson_hyphae" TO WS-KEY
     PERFORM COUNT-FOUND
     MOVE "bamboo_block" TO WS-KEY
     PERFORM COUNT-FOUND
     MOVE WS-COUNT TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "25" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe does not strip stripped logs, planks, stone or a leaves block" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "stripped_oak_log" TO WS-KEY
     PERFORM TRANS-FOUND
     MOVE "oak_planks" TO WS-KEY
     PERFORM TRANS-FOUND
     MOVE "stone" TO WS-KEY
     PERFORM TRANS-FOUND
     MOVE "crimson_planks" TO WS-KEY
     PERFORM TRANS-FOUND
     MOVE "stripped_bamboo_block" TO WS-KEY
     PERFORM TRANS-FOUND
     MOVE "0 0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe strips bamboo_block and crimson_hyphae" TO TL-CASE
     MOVE "bamboo_block" TO WS-KEY
     PERFORM DO-TRANS
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "crimson_hyphae" TO WS-KEY
     PERFORM DO-TRANS
     PERFORM JOIN-2
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 stripped_bamboo_block item.axe.strip - - 1 1|found 1 stripped_crimson_hyphae item.axe.strip - - 1 1"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe scrapes each oxidation level back one: oxidized, weathered, exposed, then the plain block (particle scrape)" TO TL-CASE
     MOVE "oxidized_cut_copper_stairs" TO WS-KEY
     PERFORM DO-TRANS
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "weathered_cut_copper_stairs" TO WS-KEY
     PERFORM DO-TRANS
     PERFORM JOIN-2
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "exposed_cut_copper_stairs" TO WS-KEY
     PERFORM DO-TRANS
     PERFORM JOIN-2
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 weathered_cut_copper_stairs item.axe.scrape scrape - 1 1|found 1 exposed_cut_copper_stairs item.axe.scrape "
         "scrape - 1 1|found 1 cut_copper_stairs item.axe.scrape scrape - 1 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe scrapes the copper block family under its own names (oxidized_copper to weathered_copper, exposed_copper to copper_block)" TO TL-CASE
     MOVE "oxidized_copper" TO WS-KEY
     PERFORM DO-TRANS
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "exposed_copper" TO WS-KEY
     PERFORM DO-TRANS
     PERFORM JOIN-2
     MOVE "found 1 weathered_copper item.axe.scrape scrape - 1 1|found 1 copper_block item.axe.scrape scrape - 1 1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe has 45 scrape rules (15 families x 3 oxidation steps) and 60 wax-off rules (15 families x 4 levels)" TO TL-CASE
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-A
     MOVE "axe" TO WS-KIND
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 15
         PERFORM VARYING WS-L FROM 0 BY 1 UNTIL WS-L > 3
             PERFORM COPPER-NAME
             PERFORM COUNT-FOUND
             MOVE SPACES TO WS-NEW
             STRING "waxed_" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-NEW
             MOVE WS-NEW TO WS-KEY
             PERFORM COUNT-FOUND-WAXED
         END-PERFORM
     END-PERFORM
     MOVE WS-COUNT TO WS-E1
     MOVE WS-A TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "45 60" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe wax off: waxed_exposed_copper to exposed_copper and waxed_copper_block to copper_block (particle wax_off)" TO TL-CASE
     MOVE "waxed_exposed_copper" TO WS-KEY
     PERFORM DO-TRANS
     MOVE TL-OBSERVED TO WS-ST1
     MOVE "waxed_copper_block" TO WS-KEY
     PERFORM DO-TRANS
     PERFORM JOIN-2
     MOVE SPACES TO TL-EXPECTED
     STRING "found 1 exposed_copper item.axe.wax_off wax_off - 1 1|found 1 copper_block item.axe.wax_off wax_off - 1 1"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 axe: the chest and door families do not update from neighbours, the other families do" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "exposed_copper_chest" TO WS-KEY
     PERFORM TRANS-UPDATE
     MOVE "waxed_oxidized_copper_door" TO WS-KEY
     PERFORM TRANS-UPDATE
     MOVE "exposed_lightning_rod" TO WS-KEY
     PERFORM TRANS-UPDATE
     MOVE "0 0 1" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 honeycomb waxes every family at every level: 60 rules, copper_block to waxed_copper_block, an already waxed or other block no" TO TL-CASE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 15
         PERFORM VARYING WS-L FROM 0 BY 1 UNTIL WS-L > 3
             PERFORM COPPER-NAME
             MOVE 1 TO WS-DIRECTION
             CALL "TOOL-WAX-KEY" USING WS-DIRECTION WS-KEY WS-NEW WS-FOUND
             ADD WS-FOUND TO WS-COUNT
         END-PERFORM
     END-PERFORM
     MOVE WS-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "copper_block" TO WS-KEY
     PERFORM WAX-ON
     MOVE "exposed_cut_copper" TO WS-KEY
     PERFORM WAX-ON
     MOVE "waxed_copper_block" TO WS-KEY
     PERFORM WAX-ON
     MOVE "stone" TO WS-KEY
     PERFORM WAX-ON
     MOVE "60 waxed_copper_block waxed_exposed_cut_copper - -" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shovel flattens grass_block, dirt, podzol, coarse_dirt, mycelium and rooted_dirt with air above (item.shovel.flatten), not the down face, not without air, not stone" TO TL-CASE
     MOVE "shovel" TO WS-KIND
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-FACE
     MOVE 1 TO WS-AIR
     MOVE "grass_block" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "podzol" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "coarse_dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "mycelium" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "rooted_dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE 0 TO WS-FACE
     MOVE "grass_block" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE 1 TO WS-FACE
     MOVE 0 TO WS-AIR
     PERFORM TRANS-NAME
     MOVE 1 TO WS-AIR
     MOVE "stone" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "dirt_path dirt_path dirt_path dirt_path dirt_path dirt_path - - -" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shovel result carries the sound item.shovel.flatten, no copied properties" TO TL-CASE
     MOVE "grass_block" TO WS-KEY
     PERFORM DO-TRANS
     MOVE "found 1 dirt_path item.shovel.flatten - - 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 hoe tills grass_block, dirt_path and dirt to farmland, coarse_dirt to dirt (item.hoe.till), air above and not the down face" TO TL-CASE
     MOVE "hoe" TO WS-KIND
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-FACE
     MOVE 1 TO WS-AIR
     MOVE "grass_block" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "dirt_path" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE "coarse_dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE 0 TO WS-FACE
     MOVE "dirt" TO WS-KEY
     PERFORM TRANS-NAME
     MOVE 1 TO WS-FACE
     MOVE 0 TO WS-AIR
     PERFORM TRANS-NAME
     MOVE "podzol" TO WS-KEY
     MOVE 1 TO WS-AIR
     PERFORM TRANS-NAME
     MOVE "farmland farmland farmland dirt - - -" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 hoe on rooted_dirt gives dirt and the loot till/rooted_dirt at the clicked face, with no air above needed, even on the down face" TO TL-CASE
     MOVE "rooted_dirt" TO WS-KEY
     MOVE 0 TO WS-FACE
     MOVE 0 TO WS-AIR
     PERFORM DO-TRANS
     MOVE "found 1 dirt item.hoe.till - till/rooted_dirt 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a shield in the off hand with the main hand used and no sneaking takes priority: the tool use is skipped" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     PERFORM SKIP-OF
     MOVE 1 TO WS-B
     PERFORM SKIP-OF
     MOVE 1 TO WS-C
     MOVE 0 TO WS-B
     PERFORM SKIP-OF
     MOVE 0 TO WS-A
     MOVE 0 TO WS-C
     PERFORM SKIP-OF
     MOVE "1 0 0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 shovel extinguishes a lit campfire or soul campfire (douses_campfires), costs 1 durability and sends level event 1009" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "campfire" TO WS-KEY
     MOVE 1 TO WS-A
     PERFORM EXTINGUISH
     MOVE "soul_campfire" TO WS-KEY
     PERFORM EXTINGUISH
     MOVE 0 TO WS-A
     PERFORM EXTINGUISH
     MOVE "stone" TO WS-KEY
     MOVE 1 TO WS-A
     PERFORM EXTINGUISH
     MOVE "1/1009/1 1/1009/1 0/0/0 0/0/0" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 JOIN-2.
     MOVE TL-OBSERVED TO WS-ST2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ST1) "|" FUNCTION TRIM(WS-ST2) DELIMITED BY SIZE INTO TL-OBSERVED.

 DO-TRANS.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     MOVE WS-FOUND TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-NEW) " " FUNCTION TRIM(WS-SOUND) " "
         FUNCTION TRIM(WS-PARTICLE) " " FUNCTION TRIM(WS-LOOT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-UPDATE TO WS-E1
     MOVE WS-COPY TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED.

 TRANS-FOUND.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     MOVE WS-FOUND TO WS-E1
     PERFORM APPEND-E1.

 TRANS-NAME.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     IF WS-FOUND = 0
         MOVE "-" TO WS-NEW
     END-IF
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-NEW) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 TRANS-UPDATE.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     MOVE WS-UPDATE TO WS-E1
     PERFORM APPEND-E1.

 APPEND-E1.
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 COUNT-FOUND.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     IF WS-FOUND = 1 AND WS-KEY(1:6) NOT = "waxed_"
         ADD 1 TO WS-COUNT
     END-IF.

 COUNT-FOUND-WAXED.
     CALL "TOOL-TRANSFORM" USING WS-KIND WS-KEY WS-FACE WS-AIR WS-FOUND WS-NEW WS-SOUND WS-PARTICLE WS-LOOT
         WS-UPDATE WS-COPY
     ADD WS-FOUND TO WS-A.

 COPPER-NAME.
     MOVE SPACES TO WS-KEY
     EVALUATE TRUE
         WHEN WS-F = 1 AND WS-L = 0
             MOVE "copper_block" TO WS-KEY
         WHEN WS-L = 0
             MOVE FAMILY(WS-F) TO WS-KEY
         WHEN OTHER
             STRING FUNCTION TRIM(LEVEL-NAME(WS-L)) FUNCTION TRIM(FAMILY(WS-F)) DELIMITED BY SIZE INTO WS-KEY
     END-EVALUATE.

 WAX-ON.
     MOVE 1 TO WS-DIRECTION
     CALL "TOOL-WAX-KEY" USING WS-DIRECTION WS-KEY WS-NEW WS-FOUND
     IF WS-FOUND = 0
         MOVE "-" TO WS-NEW
     END-IF
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-NEW) DELIMITED BY SIZE INTO TL-OBSERVED.

 SKIP-OF.
     CALL "TOOL-USE-SKIPPED" USING WS-A WS-B WS-C WS-SKIP
     MOVE WS-SKIP TO WS-E1
     PERFORM APPEND-E1.

 EXTINGUISH.
     CALL "TOOL-CAMPFIRE-DOUSE" USING WS-KEY WS-A WS-FOUND WS-B WS-C
     MOVE WS-FOUND TO WS-E1
     MOVE WS-B TO WS-E2
     MOVE SPACES TO WS-LOOT
     STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-LOOT
     MOVE WS-C TO WS-E1
     STRING FUNCTION TRIM(WS-LOOT) "/" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-LOOT
     IF TL-OBSERVED = SPACES
         MOVE WS-LOOT TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-LOOT) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-USE-3-1.
