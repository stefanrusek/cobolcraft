*> Test of flammability and the fire tick constants (17 section 3.3a; core/src/tools-fire.cob): the (ignite, burn) odds of FireBlock.bootStrap,
*> the reschedule delay 30 + nextInt(10), the burn-out chances 300 and 250 (minus 50 with increased burnout), the spread chance and age steps.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-FIRE-FLAMMABILITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(48).
 01 WS-IGNITE              BINARY-LONG.
 01 WS-BURN                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "acceptance US14 flammability (5, 5): logs, woods, stripped forms of the ten wood families, bamboo_block and coal_block" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "oak_log" TO WS-KEY
     PERFORM ODDS
     MOVE "stripped_poplar_wood" TO WS-KEY
     PERFORM ODDS
     MOVE "mangrove_wood" TO WS-KEY
     PERFORM ODDS
     MOVE "bamboo_block" TO WS-KEY
     PERFORM ODDS
     MOVE "stripped_bamboo_block" TO WS-KEY
     PERFORM ODDS
     MOVE "coal_block" TO WS-KEY
     PERFORM ODDS
     MOVE "5/5 5/5 5/5 5/5 5/5 5/5" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flammability (5, 20): planks, slabs, fences, gates, stairs of the 11 wood families, bamboo mosaic, mangrove_roots, composter, beehive" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "oak_planks" TO WS-KEY
     PERFORM ODDS
     MOVE "bamboo_slab" TO WS-KEY
     PERFORM ODDS
     MOVE "cherry_fence_gate" TO WS-KEY
     PERFORM ODDS
     MOVE "spruce_fence" TO WS-KEY
     PERFORM ODDS
     MOVE "pale_oak_stairs" TO WS-KEY
     PERFORM ODDS
     MOVE "bamboo_mosaic_stairs" TO WS-KEY
     PERFORM ODDS
     MOVE "mangrove_roots" TO WS-KEY
     PERFORM ODDS
     MOVE "composter" TO WS-KEY
     PERFORM ODDS
     MOVE "beehive" TO WS-KEY
     PERFORM ODDS
     MOVE "5/20 5/20 5/20 5/20 5/20 5/20 5/20 5/20 5/20" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flammability of the middle rows: pale moss (5, 100), target (15, 20), cave vines (15, 60), tnt, vine, glow_lichen (15, 100)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "pale_moss_carpet" TO WS-KEY
     PERFORM ODDS
     MOVE "target" TO WS-KEY
     PERFORM ODDS
     MOVE "cave_vines_plant" TO WS-KEY
     PERFORM ODDS
     MOVE "tnt" TO WS-KEY
     PERFORM ODDS
     MOVE "vine" TO WS-KEY
     PERFORM ODDS
     MOVE "glow_lichen" TO WS-KEY
     PERFORM ODDS
     MOVE "5/100 15/20 15/60 15/100 15/100 15/100" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flammability (30, 20): bookshelf, lectern, bee_nest and the wooden shelves; (30, 60): leaves, kelp block, azalea, hanging_roots, wool" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "bookshelf" TO WS-KEY
     PERFORM ODDS
     MOVE "bee_nest" TO WS-KEY
     PERFORM ODDS
     MOVE "bamboo_shelf" TO WS-KEY
     PERFORM ODDS
     MOVE "oak_leaves" TO WS-KEY
     PERFORM ODDS
     MOVE "dried_kelp_block" TO WS-KEY
     PERFORM ODDS
     MOVE "flowering_azalea" TO WS-KEY
     PERFORM ODDS
     MOVE "hanging_roots" TO WS-KEY
     PERFORM ODDS
     MOVE "lime_wool" TO WS-KEY
     PERFORM ODDS
     MOVE "red_wool_stairs" TO WS-KEY
     PERFORM ODDS
     MOVE "blue_wool_slab" TO WS-KEY
     PERFORM ODDS
     MOVE "straw_bed" TO WS-KEY
     PERFORM ODDS
     MOVE "30/20 30/20 30/20 30/60 30/60 30/60 30/60 30/60 30/60 30/60 30/60" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 flammability (60, 20): hay_block and carpets; (60, 60): bamboo, scaffolding; (60, 100): short plants and flowers" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "hay_block" TO WS-KEY
     PERFORM ODDS
     MOVE "pink_carpet" TO WS-KEY
     PERFORM ODDS
     MOVE "bamboo" TO WS-KEY
     PERFORM ODDS
     MOVE "scaffolding" TO WS-KEY
     PERFORM ODDS
     MOVE "short_grass" TO WS-KEY
     PERFORM ODDS
     MOVE "large_fern" TO WS-KEY
     PERFORM ODDS
     MOVE "dandelion" TO WS-KEY
     PERFORM ODDS
     MOVE "sweet_berry_bush" TO WS-KEY
     PERFORM ODDS
     MOVE "bush" TO WS-KEY
     PERFORM ODDS
     MOVE "60/20 60/20 60/60 60/60 60/100 60/100 60/100 60/100 60/100" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 a block not in the list is not flammable: stone, bedrock, oak_sapling" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "stone" TO WS-KEY
     PERFORM ODDS
     MOVE "bedrock" TO WS-KEY
     PERFORM ODDS
     MOVE "oak_sapling" TO WS-KEY
     PERFORM ODDS
     MOVE "0/0 0/0 0/0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 fire tick delay is 30 + nextInt(10): 30 to 39" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-A
     CALL "TOOL-FIRE-DELAY" USING WS-A WS-B
     MOVE WS-B TO WS-E1
     MOVE 9 TO WS-A
     CALL "TOOL-FIRE-DELAY" USING WS-A WS-B
     MOVE WS-B TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "30 39" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 burn-out chance is 300 on the four sides and 250 above and below, 50 less with increased_fire_burnout" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     PERFORM BURNOUT
     MOVE 1 TO WS-A
     PERFORM BURNOUT
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     PERFORM BURNOUT
     MOVE 1 TO WS-A
     PERFORM BURNOUT
     MOVE "300 250 250 200" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 spread chance (odds + 40 + 7 x difficulty) / (age + 30), halved with increased burnout; bound 100 plus 100 per row above the second" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 60 TO WS-A
     MOVE 2 TO WS-B
     MOVE 0 TO WS-C
     MOVE 0 TO WS-D
     PERFORM SPREAD
     MOVE 15 TO WS-C
     PERFORM SPREAD
     MOVE 1 TO WS-D
     PERFORM SPREAD
     MOVE 0 TO WS-A
     PERFORM SPREAD
     MOVE "3 2 1 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 spread bound is 100, plus 100 per row above the second: dy -1 to 1 give 100, dy 2 to 4 give 200 to 400" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE -1 TO WS-A
     PERFORM BOUND
     MOVE 1 TO WS-A
     PERFORM BOUND
     MOVE 2 TO WS-A
     PERFORM BOUND
     MOVE 4 TO WS-A
     PERFORM BOUND
     MOVE "100 100 200 400" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 fire ages by nextInt(3) / 2 when it ticks and by nextInt(5) / 4 when it spreads, at most 15" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 14 TO WS-A
     MOVE 2 TO WS-B
     MOVE 2 TO WS-C
     PERFORM AGE-OF
     MOVE 3 TO WS-A
     MOVE 1 TO WS-B
     PERFORM AGE-OF
     MOVE 15 TO WS-A
     MOVE 4 TO WS-B
     MOVE 4 TO WS-C
     PERFORM AGE-OF
     MOVE 3 TO WS-A
     PERFORM AGE-OF
     MOVE "15 3 15 4" TO TL-EXPECTED
     PERFORM CHECK-DONE
     STOP RUN.

 ODDS.
     CALL "TOOL-FLAMMABILITY" USING WS-KEY WS-IGNITE WS-BURN
     MOVE WS-IGNITE TO WS-E1
     MOVE WS-BURN TO WS-E2
     IF TL-OBSERVED = SPACES
         STRING FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 BURNOUT.
     CALL "TOOL-FIRE-BURNOUT" USING WS-A WS-B WS-C
     MOVE WS-C TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 BOUND.
     CALL "TOOL-FIRE-BOUND" USING WS-A WS-B
     MOVE WS-B TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 AGE-OF.
     CALL "TOOL-FIRE-AGE" USING WS-A WS-B WS-C WS-D
     MOVE WS-D TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 SPREAD.
     CALL "TOOL-FIRE-SPREAD" USING WS-A WS-B WS-C WS-D WS-IGNITE
     MOVE WS-IGNITE TO WS-E1
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-FIRE-FLAMMABILITY.
