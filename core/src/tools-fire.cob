*> Flammability and the fire tick constants (docs/protocol/17 section 3.3a; US14; T2137). Keys are block keys without "minecraft:".
*> Entry points:
*>   TOOL-FLAMMABILITY USING key (PIC X(48)), ignite odds out, burn odds out (0, 0: not flammable). The "short plants" row of the
*>     document counts 41 blocks but names only categories: the grasses, ferns, dead bush, tall and small flowers and the named blocks
*>     below are covered; any short plant outside that list reads as not flammable (a gap recorded in the report).
*>   TOOL-FIRE-DELAY USING roll (nextInt(10)), delay out (30 + roll)
*>   TOOL-FIRE-BURNOUT USING vertical (1 above or below), increased burnout (1 or 0), chance out (300 or 250, minus 50)
*>   TOOL-FIRE-SPREAD USING ignite odds, difficulty id, fire age, increased burnout, chance out ((odds + 40 + 7 d) / (age + 30), halved)
*>   TOOL-FIRE-BOUND USING dy, bound out (100, plus (dy - 1) x 100 above dy 1)
*>   TOOL-FIRE-AGE USING age, roll, divisor, new age out (min(15, age + roll / divisor))

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FLAMMABILITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TOOLFAM.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-HITS                BINARY-LONG.
 01 WS-BASE                PIC X(48).
 01 WS-WOODS11             BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-IGNITE               BINARY-LONG.
 01 L-BURN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-IGNITE L-BURN.
     MOVE 0 TO L-IGNITE L-BURN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TF-WOODS + 1
         IF WS-I > TF-WOODS
             MOVE "bamboo" TO WS-BASE
         ELSE
             MOVE TF-WOOD(WS-I) TO WS-BASE
         END-IF
         PERFORM WOOD-ROWS
     END-PERFORM
     IF L-KEY = "bamboo_block" OR "stripped_bamboo_block" OR "coal_block"
         MOVE 5 TO L-IGNITE
         MOVE 5 TO L-BURN
     END-IF
     IF L-KEY = "bamboo_mosaic" OR "bamboo_mosaic_slab" OR "bamboo_mosaic_stairs" OR "mangrove_roots" OR "composter"
             OR "beehive"
         MOVE 5 TO L-IGNITE
         MOVE 20 TO L-BURN
     END-IF
     EVALUATE TRUE
         WHEN L-KEY = "pale_moss_block" OR "pale_moss_carpet" OR "pale_hanging_moss"
             MOVE 5 TO L-IGNITE
             MOVE 100 TO L-BURN
         WHEN L-KEY = "target"
             MOVE 15 TO L-IGNITE
             MOVE 20 TO L-BURN
         WHEN L-KEY = "cave_vines" OR "cave_vines_plant"
             MOVE 15 TO L-IGNITE
             MOVE 60 TO L-BURN
         WHEN L-KEY = "tnt" OR "vine" OR "glow_lichen"
             MOVE 15 TO L-IGNITE
             MOVE 100 TO L-BURN
         WHEN L-KEY = "bookshelf" OR "lectern" OR "bee_nest"
             MOVE 30 TO L-IGNITE
             MOVE 20 TO L-BURN
         WHEN L-KEY = "dried_kelp_block" OR "azalea" OR "flowering_azalea" OR "hanging_roots" OR "straw_bed"
             MOVE 30 TO L-IGNITE
             MOVE 60 TO L-BURN
         WHEN L-KEY = "hay_block"
             MOVE 60 TO L-IGNITE
             MOVE 20 TO L-BURN
         WHEN L-KEY = "bamboo" OR "scaffolding"
             MOVE 60 TO L-IGNITE
             MOVE 60 TO L-BURN
     END-EVALUATE
     MOVE 0 TO WS-HITS
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "_leaves " ALL "_wool " ALL "_wool_stairs " ALL "_wool_slab "
     IF WS-HITS > 0
         MOVE 30 TO L-IGNITE
         MOVE 60 TO L-BURN
     END-IF
     MOVE 0 TO WS-HITS
     INSPECT L-KEY TALLYING WS-HITS FOR ALL "_carpet "
     IF WS-HITS > 0 AND L-KEY(1:5) NOT = "pale_" AND L-KEY(1:11) NOT = "moss_carpet"
         MOVE 60 TO L-IGNITE
         MOVE 20 TO L-BURN
     END-IF
     IF L-KEY = "short_grass" OR "tall_grass" OR "short_dry_grass" OR "tall_dry_grass" OR "fern" OR "large_fern" OR "dead_bush"
             OR "sunflower" OR "lilac" OR "rose_bush" OR "peony" OR "dandelion" OR "poppy" OR "blue_orchid" OR "allium"
             OR "azure_bluet" OR "red_tulip" OR "orange_tulip" OR "white_tulip" OR "pink_tulip" OR "oxeye_daisy"
             OR "cornflower" OR "lily_of_the_valley" OR "wither_rose" OR "torchflower" OR "closed_eyeblossom"
             OR "open_eyeblossom" OR "pink_petals" OR "wildflowers" OR "leaf_litter" OR "cactus_flower"
             OR "sweet_berry_bush" OR "spore_blossom" OR "big_dripleaf" OR "small_dripleaf" OR "firefly_bush" OR "bush"
         MOVE 60 TO L-IGNITE
         MOVE 100 TO L-BURN
     END-IF
     GOBACK.

 WOOD-ROWS.
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_shelf" DELIMITED BY SIZE INTO WS-NAME
     IF L-KEY = WS-NAME
         MOVE 30 TO L-IGNITE
         MOVE 20 TO L-BURN
     END-IF
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_planks" DELIMITED BY SIZE INTO WS-NAME
     PERFORM PLANK-ROW
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_slab" DELIMITED BY SIZE INTO WS-NAME
     PERFORM PLANK-ROW
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_fence_gate" DELIMITED BY SIZE INTO WS-NAME
     PERFORM PLANK-ROW
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_fence" DELIMITED BY SIZE INTO WS-NAME
     PERFORM PLANK-ROW
     MOVE SPACES TO WS-NAME
     STRING FUNCTION TRIM(WS-BASE) "_stairs" DELIMITED BY SIZE INTO WS-NAME
     PERFORM PLANK-ROW
     IF WS-I <= TF-WOODS
         MOVE SPACES TO WS-NAME
         STRING FUNCTION TRIM(WS-BASE) "_log" DELIMITED BY SIZE INTO WS-NAME
         PERFORM LOG-ROW
         MOVE SPACES TO WS-NAME
         STRING FUNCTION TRIM(WS-BASE) "_wood" DELIMITED BY SIZE INTO WS-NAME
         PERFORM LOG-ROW
         MOVE SPACES TO WS-NAME
         STRING "stripped_" FUNCTION TRIM(WS-BASE) "_log" DELIMITED BY SIZE INTO WS-NAME
         PERFORM LOG-ROW
         MOVE SPACES TO WS-NAME
         STRING "stripped_" FUNCTION TRIM(WS-BASE) "_wood" DELIMITED BY SIZE INTO WS-NAME
         PERFORM LOG-ROW
     END-IF.

 PLANK-ROW.
     IF L-KEY = WS-NAME
         MOVE 5 TO L-IGNITE
         MOVE 20 TO L-BURN
     END-IF.

 LOG-ROW.
     IF L-KEY = WS-NAME
         MOVE 5 TO L-IGNITE
         MOVE 5 TO L-BURN
     END-IF.
 END PROGRAM TOOL-FLAMMABILITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROLL                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROLL L-DELAY.
     COMPUTE L-DELAY = 30 + L-ROLL
     GOBACK.
 END PROGRAM TOOL-FIRE-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-BURNOUT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VERTICAL             BINARY-LONG.
 01 L-INCREASED            BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-VERTICAL L-INCREASED L-CHANCE.
     IF L-VERTICAL = 1
         MOVE 250 TO L-CHANCE
     ELSE
         MOVE 300 TO L-CHANCE
     END-IF
     IF L-INCREASED = 1
         SUBTRACT 50 FROM L-CHANCE
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-BURNOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-SPREAD.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ODDS                 BINARY-LONG.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-INCREASED            BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ODDS L-DIFFICULTY L-AGE L-INCREASED L-CHANCE.
     COMPUTE L-CHANCE = (L-ODDS + 40 + 7 * L-DIFFICULTY) / (L-AGE + 30)
     IF L-INCREASED = 1
         COMPUTE L-CHANCE = L-CHANCE / 2
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-SPREAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-BOUND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DY                   BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DY L-BOUND.
     MOVE 100 TO L-BOUND
     IF L-DY > 1
         COMPUTE L-BOUND = 100 + (L-DY - 1) * 100
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-BOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-FIRE-AGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-DIVISOR              BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-ROLL L-DIVISOR L-NEW.
     COMPUTE L-NEW = L-AGE + L-ROLL / L-DIVISOR
     IF L-NEW > 15
         MOVE 15 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM TOOL-FIRE-AGE.
