*> Acceptance test of docs/protocol/35-worldgen-features-4 section 5 (block_column: sugar cane, kelp, the truncation of a column by the allowed_placement predicate, up and down) and 35-5 sections 13.2
*> and 13.3 (the randomized_int provider of kelp and sea pickles), of the would_survive predicate of sugar cane (24 part 3 section 7.10.2) and of the sea pickle survival. The blocks are those of the standard fixture set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-COLUMN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-FEAT-DIR            PIC X(1100) VALUE "core/tests/fixtures/feat-veg".
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 77.
 01 WS-PTR                 USAGE POINTER.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-REMAIN              BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-PFKEY               PIC X(80).
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-PLANT         BINARY-LONG.
 01 WS-N-AGE               PIC 99.
 01 WS-PN                  PIC 9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "minecraft:supports_sugar_cane" TO WS-TAG
     MOVE 2 TO WS-COUNT
     MOVE "dirt" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID(1)
     MOVE "sand" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID(2)
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:supports_sugar_cane_adjacently" TO WS-TAG
     MOVE 1 TO WS-COUNT
     MOVE "frosted_ice" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID(1)
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:supports_cactus" TO WS-TAG
     MOVE 1 TO WS-COUNT
     MOVE "sand" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-ID(1)
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-FEAT-DIR
     CALL "FD-RESET"
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 70 TO WS-Y

*>   sugar cane: three blocks of age 0 up from the origin
     MOVE 17 TO WS-X
     MOVE 33 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:col_cane" TO WS-PFKEY
     PERFORM PLACE
     MOVE "acceptance US12 35-4§5 `block_column`: the result is true" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE "sugar_cane" TO WS-KEY
     MOVE "age=0" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         COMPUTE WS-YY = WS-Y + WS-I
         PERFORM READ-STATE-AT
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-4§5 `block_column`: a constant height of 3 writes three sugar canes (age 0) from the origin up" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-YY = WS-Y + 3
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-4§5 `block_column`: the cell above the column stays air" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a block in the way: the test cell one beyond the origin is the first checked, the cell at i = 1 fails, one block remains (the example of the document)
     MOVE 18 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-YY = WS-Y + 2
     PERFORM PUT-CELL-AT
     PERFORM PLACE
     MOVE "sugar_cane" TO WS-KEY
     MOVE "age=0" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-4§5 `block_column`: stone at i = 1 truncates the column to one block (the sugar cane example): the origin is written" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-YY = WS-Y + 1
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-4§5 `block_column`: the second cell of the truncated column is not written" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   downward: the origin and the cell below
     MOVE 19 TO WS-X
     MOVE "minecraft:col_down" TO WS-PFKEY
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         COMPUTE WS-YY = WS-Y - WS-I
         PERFORM READ-STATE-AT
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     COMPUTE WS-YY = WS-Y - 2
     PERFORM READ-STATE-AT
     IF WS-STATE NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 35-4§5 `block_column`: direction down writes the origin and the cell below, no more" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a total height of 0 places nothing
     MOVE 20 TO WS-X
     MOVE "minecraft:col_zero" TO WS-PFKEY
     PERFORM PLACE
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-4§5 `block_column`: a total height of 0 returns false and writes nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 1000 + WS-STATE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:col_bad_dir" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-4§5 `block_column`: a horizontal direction is not compiled: status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   kelp in a water column: h0 plants (uniform 0..9, the first draw) and the head with age 20 + nextInt(4)
     MOVE 21 TO WS-X
     MOVE 34 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 14
         COMPUTE WS-YY = WS-Y + WS-I
         PERFORM PUT-CELL-AT
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE "minecraft:col_kelp" TO WS-PFKEY
     PERFORM PLACE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 10 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-H0
     MOVE 4 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-A
     MOVE 1 TO WS-H1
     PERFORM CHECK-KELP
     MOVE "acceptance US12 35-5§13.3 kelp: a water column gets h0 kelp_plant blocks (uniform 0..9) and the kelp head at age 20 + nextInt(4)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   kelp under a shallow water column: the tip priority removes from the plant layer first. A seed whose first draw is at least 5 is searched.
     MOVE 22 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         COMPUTE WS-YY = WS-Y + WS-I
         PERFORM PUT-CELL-AT
     END-PERFORM
     MOVE 100 TO WS-SEED
     MOVE 0 TO WS-H0
     PERFORM UNTIL WS-H0 >= 5
         ADD 1 TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         MOVE 10 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-H0
     END-PERFORM
     MOVE 4 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-A
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     PERFORM PLACE
*>   the tests at y + 1 ..: water here and above; y + 4 has air above, so i = 3 fails: kept 3 of total h0 + 1
     COMPUTE WS-TOTAL = WS-H0 + 1
     COMPUTE WS-REMAIN = WS-TOTAL - 3
     MOVE WS-REMAIN TO WS-TAKE
     IF WS-TAKE > WS-H0
         MOVE WS-H0 TO WS-TAKE
     END-IF
     COMPUTE WS-REMAIN = WS-REMAIN - WS-TAKE
     COMPUTE WS-H0 = WS-H0 - WS-TAKE
     MOVE 1 TO WS-H1
     IF WS-REMAIN > 0
         MOVE 0 TO WS-H1
     END-IF
     PERFORM CHECK-KELP
     MOVE "acceptance US12 35-5§13.3 kelp: a column cut at i = 3 keeps the head and removes the plants first (prioritize_tip)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED

*>   the sea pickle: pickles = 1 + nextInt(4), waterlogged true, on a block that has a collision face
     MOVE 23 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM PUT-CELL-AT
     MOVE 77 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE "minecraft:pickle" TO WS-PFKEY
     PERFORM PLACE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 4 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-A
     ADD 1 TO WS-A
     MOVE SPACES TO WS-PAIRS
     MOVE WS-A TO WS-PN
     STRING "pickles=" WS-PN ",waterlogged=true" DELIMITED BY SIZE INTO WS-PAIRS
     MOVE "sea_pickle" TO WS-KEY
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-5§13.2 sea pickle: randomized_int sets pickles to 1 + nextInt(4) on sea_pickle[waterlogged=true]" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-X
     MOVE "water" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:pickle" TO WS-PFKEY
     PERFORM PLACE
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-5§13.2 sea pickle: it does not stand on water (no collision face below)" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a property the state does not have: the state is unchanged and nothing is drawn
     MOVE 25 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE "minecraft:pickle_nomatch" TO WS-PFKEY
     PERFORM PLACE
     MOVE 16 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-A
     MOVE WS-A TO WS-H0
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-A
     MOVE "sea_pickle" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-5§13.2 randomized_int: a state without the property is returned unchanged, no sample is drawn" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-STATE - WS-WANT) * 100 + WS-H0 - WS-A
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   would_survive sugar_cane: water beside the block below, a block of the adjacent tag beside it, sugar cane below
     MOVE 26 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     COMPUTE WS-X = WS-X + 1
     COMPUTE WS-YY = WS-Y - 1
     PERFORM PUT-CELL-AT
     COMPUTE WS-X = WS-X - 1
     MOVE "minecraft:cane_pred" TO WS-PFKEY
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 24§7.10.2 sugar cane: sand with water beside it passes would_survive" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 27 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 24§7.10.2 sugar cane: sand without water or an adjacent block beside it fails would_survive" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 28 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "frosted_ice" TO WS-KEY
     COMPUTE WS-X = WS-X + 1
     COMPUTE WS-YY = WS-Y - 1
     PERFORM PUT-CELL-AT
     COMPUTE WS-X = WS-X - 1
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 24§7.10.2 sugar cane: a block of supports_sugar_cane_adjacently beside the block below passes" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 29 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     COMPUTE WS-X = WS-X - 1
     COMPUTE WS-YY = WS-Y - 1
     PERFORM PUT-CELL-AT
     COMPUTE WS-X = WS-X + 1
     PERFORM PLACE
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 24§7.10.2 sugar cane: a block below that is not in supports_sugar_cane fails (water beside or not)" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO WS-X
     MOVE "sugar_cane" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 24§7.10.2 sugar cane: sugar cane below passes (a column grows)" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   cactus (29b part 4 section 4.1): sand below with open sides passes, stone below, a solid neighbour and water above fail
     MOVE "minecraft:cactus_pred" TO WS-PFKEY
     MOVE 46 TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-X = 16 + WS-I * 3
         MOVE "sand" TO WS-KEY
         IF WS-I = 2
             MOVE "stone" TO WS-KEY
         END-IF
         PERFORM PUT-BELOW
         IF WS-I = 3
             MOVE "stone" TO WS-KEY
             MOVE SPACES TO WS-PAIRS
             MOVE WS-Y TO WS-YY
             ADD 1 TO WS-X
             PERFORM PUT-CELL-AT
             SUBTRACT 1 FROM WS-X
         END-IF
         IF WS-I = 4
             MOVE "water" TO WS-KEY
             MOVE SPACES TO WS-PAIRS
             COMPUTE WS-YY = WS-Y + 1
             PERFORM PUT-CELL-AT
         END-IF
         PERFORM PLACE
         MOVE "glass" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         PERFORM WANT-STATE-PAIRS
         MOVE WS-Y TO WS-YY
         PERFORM READ-STATE-AT
         MOVE SPACES TO TL-CASE
         EVALUATE WS-I
             WHEN 1
                 MOVE "acceptance US12 29b-4§4.1 cactus: sand below and open sides passes would_survive" TO TL-CASE
                 MOVE WS-WANT TO TL-EXPECTED-N
             WHEN 2
                 MOVE "acceptance US12 29b-4§4.1 cactus: stone below fails would_survive" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "acceptance US12 29b-4§4.1 cactus: a solid horizontal neighbour fails would_survive" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "acceptance US12 29b-4§4.1 cactus: a liquid above fails would_survive" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-STATE TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   a negative height counts as 0: the layers [-1, 2] write two blocks
     MOVE 31 TO WS-X
     MOVE 44 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:col_neg" TO WS-PFKEY
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         COMPUTE WS-YY = WS-Y + WS-I
         PERFORM READ-STATE-AT
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     COMPUTE WS-YY = WS-Y + 2
     PERFORM READ-STATE-AT
     IF WS-STATE NOT = 0
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 35-4§5 `block_column`: a negative height counts as 0 (layers -1 and 2 write two blocks)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   data that is not compiled whole is unsupported (status 2): block columns, randomized_int and the noise counts with a missing or wrong field
     MOVE "minecraft:col_nolayers" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:col_5layers" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:col_badheight" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:ri_nosource" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:ri_badvalues" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:ri_wide" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:ri_badrange" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:badprop2" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:nb_noratio" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:nb_nofactor" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:nt_nolevel" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:nt_nobelow" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:nt_noabove" TO WS-PFKEY
     PERFORM CHECK-BAD
     MOVE "minecraft:col_many" TO WS-PFKEY
     PERFORM CHECK-BAD
*>   a source state without the property: the state alone, compiled whole
     MOVE "minecraft:ri_noprops" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-2§4 randomized_int: a source whose block lacks the property compiles (the state alone)" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   has_sturdy_face up at the cell below: a full block passes, glass (no full face) and water do not
     MOVE 16 TO WS-X
     MOVE 43 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:sturdy_up" TO WS-PFKEY
     PERFORM PLACE
     MOVE "glass" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-2§3 has_sturdy_face: stone below (a full face up) passes" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-X
     MOVE "water" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE WS-Y TO WS-YY
     PERFORM READ-STATE-AT
     MOVE "acceptance US12 35-2§3 has_sturdy_face: water below has no sturdy face and fails" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:sturdy_bad" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-2§3 has_sturdy_face: a direction that is no Direction name is not compiled: status 2" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     FREE WS-PTR
     GOBACK.

*> the placed feature WS-PFKEY must be unsupported (status 2)
 CHECK-BAD.
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 35-4§5 compile errors: " FUNCTION TRIM(WS-PFKEY) " is unsupported (status 2)" DELIMITED BY SIZE INTO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the kelp column at (WS-X, WS-Z) from WS-Y: WS-H0 kelp_plant blocks, then the head at age 20 + WS-A when WS-H1 is 1 (WS-H1 is 1 for the untruncated column): WS-BAD counts the cells that differ
 CHECK-KELP.
     MOVE 0 TO WS-BAD
     MOVE "kelp_plant" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-WANT TO WS-STATE-PLANT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-H0
         COMPUTE WS-YY = WS-Y + WS-I
         PERFORM READ-STATE-AT
         IF WS-STATE NOT = WS-STATE-PLANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     IF WS-H1 = 1
         COMPUTE WS-N-AGE = WS-A + 20
         MOVE SPACES TO WS-PAIRS
         STRING "age=" WS-N-AGE DELIMITED BY SIZE INTO WS-PAIRS
         MOVE "kelp" TO WS-KEY
         PERFORM WANT-STATE-PAIRS
         COMPUTE WS-YY = WS-Y + WS-H0
         PERFORM READ-STATE-AT
         IF WS-STATE NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-IF.

*> the block WS-KEY (default state) one below the origin cell (WS-X, WS-Y, WS-Z); the origin cell air
 PUT-BELOW.
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-YY = WS-Y - 1
     PERFORM PUT-CELL-AT
     MOVE 0 TO WS-STATE
     MOVE WS-Y TO WS-YY
     CALL "FL-SET-STATE" USING WS-X WS-YY WS-Z WS-STATE WS-FLAGS WS-OK.

*> writes the block WS-KEY with the pairs WS-PAIRS at (WS-X, WS-YY, WS-Z)
 PUT-CELL-AT.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-YY WS-Z WS-STATE WS-FLAGS WS-OK.

*> places the placed feature WS-PFKEY at (WS-X, WS-Y, WS-Z)
 PLACE.
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-ZERO WS-X WS-Y WS-Z WS-RESULT.

 WANT-STATE-PAIRS.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT.

 READ-STATE-AT.
     CALL "FL-GET-STATE" USING WS-X WS-YY WS-Z WS-STATE.
 END PROGRAM TEST-FEAT-COLUMN.
 COPY CORETEST.
