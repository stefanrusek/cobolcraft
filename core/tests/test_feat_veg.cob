*> Acceptance test of the vegetation families of the standard world (docs/protocol/35-worldgen-features-4 section 4, 24 part 2 table 7.2, 24 part 4 sections 5.4 and 6.14):
*> the family gate of the feature stage (FR-GATE), state properties of a provider state, the survival rules of the plants simple_block places (the block below in a tag, the mushroom
*> light rule at unlit feature time, the lily pad over water, seagrass on a full block) and the two halves of the double plants. The blocks are those of the standard fixture set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-VEG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATINDEX.
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
 01 WS-UP                  BINARY-LONG.
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
 01 WS-GATE-KEY            PIC X(80).
 01 WS-GATE                BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the gate: one family per prefix, unsupported features stay off
     MOVE 1 TO FI-GATE
     MOVE "minecraft:trees_plains" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: a trees_ placed feature is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:flower_default" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the flower family is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:patch_grass_plain" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the grass patches are admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:red_mushroom_normal" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the mushroom patches are admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:patch_berry_common" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the sweet berry patches are admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:seagrass_deep" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: seagrass is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:patch_sugar_cane_swamp" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the sugar cane patches are admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:kelp_warm" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: kelp is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:sea_pickle" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the sea pickle patch is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:vines" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the vines feature is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE "minecraft:classic_vines_cave_feature" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: the cave vines stay off" TO TL-CASE
     PERFORM CHECK-GATE-ZERO
     MOVE "minecraft:glow_lichen" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: an unsupported family (glow lichen) stays off" TO TL-CASE
     PERFORM CHECK-GATE-ZERO
     MOVE "minecraft:ore_coal_upper" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: an ore placed feature stays off" TO TL-CASE
     PERFORM CHECK-GATE-ZERO
     MOVE "minecraft:trees" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: a key shorter than a prefix is not admitted" TO TL-CASE
     PERFORM CHECK-GATE-ZERO
     MOVE 0 TO FI-GATE
     MOVE "minecraft:glow_lichen" TO WS-GATE-KEY
     MOVE "acceptance US12 vegetation gate: without the gate every placed feature is admitted" TO TL-CASE
     PERFORM CHECK-GATE-ONE
     MOVE 1 TO FI-GATE

*>   a standard world: the blocks of the fixture set
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "grass_block" TO WS-KEY
     PERFORM FIND-ID
     MOVE WS-WANT TO WS-ID(1)
     MOVE "minecraft:supports_vegetation" TO WS-TAG
     PERFORM PUT-TAG
     MOVE "minecraft:supports_dry_vegetation" TO WS-TAG
     MOVE "sand" TO WS-KEY
     PERFORM FIND-ID
     MOVE WS-WANT TO WS-ID(1)
     PERFORM PUT-TAG
     MOVE "minecraft:overrides_mushroom_light_requirement" TO WS-TAG
     MOVE "glass" TO WS-KEY
     PERFORM FIND-ID
     MOVE WS-WANT TO WS-ID(1)
     PERFORM PUT-TAG
     MOVE "minecraft:cannot_support_seagrass" TO WS-TAG
     MOVE "magma_block" TO WS-KEY
     PERFORM FIND-ID
     MOVE WS-WANT TO WS-ID(1)
     PERFORM PUT-TAG
     MOVE "minecraft:small_flowers" TO WS-TAG
     MOVE "poppy" TO WS-KEY
     PERFORM FIND-ID
     MOVE WS-WANT TO WS-ID(1)
     PERFORM PUT-TAG
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-FEAT-DIR
     CALL "FD-RESET"
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED

*>   flowers: the block below is in supports_vegetation
     MOVE 20 TO WS-X
     MOVE 40 TO WS-Z
     MOVE 70 TO WS-Y
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:poppy" TO WS-PFKEY
     PERFORM PLACE
     MOVE "poppy" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 35-4§4 `simple_block`: a poppy on a block of supports_vegetation is written with its state" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 21 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE "acceptance US12 35-4§4 `simple_block`: a poppy on stone (not in supports_vegetation) is refused" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM EXPECT-STATE

*>   a state with properties: the berry bush at age 3, and a property the block does not have
     MOVE 22 TO WS-X
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:berry" TO WS-PFKEY
     PERFORM PLACE
     MOVE "sweet_berry_bush" TO WS-KEY
     MOVE "age=3" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE "acceptance US12 35-4§4 `simple_block`: the provider state carries its properties (sweet_berry_bush age 3)" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 28 TO WS-X
     MOVE 38 TO WS-Z
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:berry" TO WS-PFKEY
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 29b§8 sweet berry bush: the block below must be in supports_vegetation (stone refuses it)" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 22 TO WS-X
     MOVE 40 TO WS-Z
     MOVE "minecraft:badprop" TO WS-PFKEY
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "acceptance US12 35-4§4 `simple_block`: a property the block does not have makes the feature unsupported" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a plain block without a survival rule (pumpkin) needs only a block below
     MOVE 23 TO WS-X
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:pumpkin" TO WS-PFKEY
     PERFORM PLACE
     MOVE "pumpkin" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 35-4§4 `simple_block`: a pumpkin (no survival rule) stands on any block" TO TL-CASE
     PERFORM EXPECT-STATE

*>   dry vegetation
     MOVE 24 TO WS-X
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:dry" TO WS-PFKEY
     PERFORM PLACE
     MOVE "dead_bush" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 24§7.2 plants: a dead bush on a block of supports_dry_vegetation is placed" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 25 TO WS-X
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 24§7.2 plants: a dead bush on grass is refused" TO TL-CASE
     PERFORM EXPECT-STATE

*>   mushrooms: unlit feature time, a full block below
     MOVE 26 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:mush" TO WS-PFKEY
     PERFORM PLACE
     MOVE "brown_mushroom" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 24§7.2 plants: a mushroom on a solid block is placed (light 0 at feature time)" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 27 TO WS-X
     MOVE "glass" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE "brown_mushroom" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 24§7.2 plants: a mushroom on a block of overrides_mushroom_light_requirement is placed" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 28 TO WS-X
     MOVE "ice" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 24§7.2 plants: a mushroom on a block that is neither (ice, not a full solid render) is refused" TO TL-CASE
     PERFORM EXPECT-STATE

*>   lily pad: water below, nothing wet above
     MOVE 29 TO WS-X
     MOVE "water" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:pad" TO WS-PFKEY
     PERFORM PLACE
     MOVE "lily_pad" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 24§6.14 `lily_pad`: a lily pad over water is placed" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 30 TO WS-X
     MOVE "stone" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 24§6.14 `lily_pad`: a lily pad over stone is refused" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 31 TO WS-X
     MOVE "water" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Y = WS-Y + 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     PERFORM PLACE
     MOVE "acceptance US12 24§6.14 `lily_pad`: a lily pad with water in the cell above is refused" TO TL-CASE
     PERFORM EXPECT-STATE

*>   seagrass: a full block below that is not in cannot_support_seagrass
     MOVE 16 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:sgrass" TO WS-PFKEY
     PERFORM PLACE
     MOVE "seagrass" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 24§7.2 plants: seagrass on a full block is placed" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 17 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "magma_block" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 24§7.2 plants: seagrass on a block of cannot_support_seagrass is refused" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 18 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "water" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE "acceptance US12 24§7.2 plants: seagrass over water (no full block below) is refused" TO TL-CASE
     PERFORM EXPECT-STATE

*>   double plants: both halves, the upper one only into air
     MOVE 19 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "minecraft:tall" TO WS-PFKEY
     PERFORM PLACE
     MOVE "tall_grass" TO WS-KEY
     MOVE "half=lower" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE "acceptance US12 35-4§4 `simple_block`: a double plant writes the lower half at the origin" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE "tall_grass" TO WS-KEY
     MOVE "half=upper" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-WANT TO WS-UP
     COMPUTE WS-Y = WS-Y + 1
     PERFORM READ-STATE
     COMPUTE WS-Y = WS-Y - 1
     MOVE "acceptance US12 35-4§4 `simple_block`: a double plant writes the upper half above" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-UP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "grass_block" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Y = WS-Y + 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     MOVE "minecraft:tall" TO WS-PFKEY
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 35-4§4 `simple_block`: a double plant with a block above is refused" TO TL-CASE
     PERFORM EXPECT-STATE

*>   tall seagrass in water: the upper half goes into water
     MOVE 21 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y + 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     MOVE "minecraft:tsgrass" TO WS-PFKEY
     PERFORM PLACE
     MOVE "tall_seagrass" TO WS-KEY
     MOVE "half=upper" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE WS-WANT TO WS-UP
     COMPUTE WS-Y = WS-Y + 1
     PERFORM READ-STATE
     COMPUTE WS-Y = WS-Y - 1
     MOVE "acceptance US12 35-4§4 `simple_block`: tall seagrass places its upper half into water above" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-UP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-X
     MOVE 41 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y + 1
     MOVE "stone" TO WS-KEY
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     PERFORM PLACE
     MOVE "water" TO WS-KEY
     PERFORM WANT-STATE
     MOVE "acceptance US12 35-4§4 `simple_block`: tall seagrass under stone is refused (the water stays)" TO TL-CASE
     PERFORM EXPECT-STATE
*>   vines (35-4 section 7.1): the first of up, north, south, west, east with a block to attach to
     MOVE 18 TO WS-X
     MOVE 45 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Z = WS-Z - 1
     PERFORM PUT-CELL
     COMPUTE WS-Z = WS-Z + 1
     MOVE "minecraft:vines" TO WS-PFKEY
     PERFORM PLACE
     MOVE "vine" TO WS-KEY
     MOVE "east=false,north=true,south=false,up=false,west=false" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE "acceptance US12 35-4§7.1 `vines`: a block to the north gives a vine with only the north face" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 20 TO WS-X
     MOVE "air" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Y = WS-Y + 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     COMPUTE WS-X = WS-X + 1
     PERFORM PUT-CELL
     COMPUTE WS-X = WS-X - 1
     PERFORM PLACE
     MOVE "vine" TO WS-KEY
     MOVE "east=false,north=false,south=false,up=true,west=false" TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS
     MOVE "acceptance US12 35-4§7.1 `vines`: with blocks above and to the east the first direction (up) wins" TO TL-CASE
     PERFORM EXPECT-STATE
     MOVE 28 TO WS-X
     MOVE "air" TO WS-KEY
     PERFORM PUT-BELOW
     PERFORM PLACE
     MOVE "acceptance US12 35-4§7.1 `vines`: nothing to attach to returns false and writes nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 1000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 24 TO WS-X
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM PUT-CELL
     COMPUTE WS-X = WS-X + 1
     PERFORM PUT-CELL
     COMPUTE WS-X = WS-X - 1
     PERFORM PLACE
     PERFORM READ-STATE
     MOVE "acceptance US12 35-4§7.1 `vines`: an origin that is not air returns false and keeps its block" TO TL-CASE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a state outside the table has no rule
     MOVE 999999 TO WS-STATE
     CALL "FR-CAN-SURVIVE" USING WS-STATE WS-X WS-Y WS-Z WS-OK
     MOVE "acceptance US12 24§7.2 plants: a state that no block owns has no survival rule (survives)" TO TL-CASE
     MOVE WS-OK TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   tall seagrass needs water in its own cell: a lower half in air is refused although water lies above
     MOVE 29 TO WS-X
     MOVE 42 TO WS-Z
     MOVE "sand" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE "water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Y = WS-Y + 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y - 1
     MOVE "minecraft:tsgrass" TO WS-PFKEY
     PERFORM PLACE
     MOVE 0 TO WS-WANT
     MOVE "acceptance US12 35-5§13.1 tall seagrass: the lower half needs full water at its own cell: air there refuses it" TO TL-CASE
     PERFORM EXPECT-STATE
     FREE WS-PTR
     GOBACK.

 CHECK-GATE-ONE.
     CALL "FR-GATE" USING WS-GATE-KEY WS-GATE
     MOVE WS-GATE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-GATE-ZERO.
     CALL "FR-GATE" USING WS-GATE-KEY WS-GATE
     MOVE WS-GATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the id of the block WS-KEY (BLOCKS-ID-OF) in WS-WANT
 FIND-ID.
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-WANT.

*> binds the tag WS-TAG of the registry block to the one block of WS-ID(1)
 PUT-TAG.
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS.

*> the block WS-KEY (default state) one below the origin cell (WS-X, WS-Y, WS-Z)
 PUT-BELOW.
     MOVE SPACES TO WS-PAIRS
     COMPUTE WS-Y = WS-Y - 1
     PERFORM PUT-CELL
     COMPUTE WS-Y = WS-Y + 1
     MOVE 0 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK.

*> writes the block WS-KEY with the pairs WS-PAIRS at (WS-X, WS-Y, WS-Z)
 PUT-CELL.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK.

*> places the placed feature WS-PFKEY at (WS-X, WS-Y, WS-Z)
 PLACE.
     CALL "FD-GET-PF" USING WS-PFKEY WS-PF
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-ZERO WS-X WS-Y WS-Z WS-RESULT.

 WANT-STATE.
     MOVE SPACES TO WS-PAIRS
     PERFORM WANT-STATE-PAIRS.

 WANT-STATE-PAIRS.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT.

 READ-STATE.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE.

 EXPECT-STATE.
     PERFORM READ-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FEAT-VEG.
 COPY CORETEST.
