*> Implementation test of the disk feature and the rule_based state provider (docs/protocol/35-worldgen-features-5-water-and-surface.md section 5, 35-2 section 4; core/src/feat-disk.cob):
*> the data features compile (type 10; a missing target, radius or half_height, an unknown provider or too many rules make the feature unsupported); the four configured disks (gravel, clay,
*> sand with its rule of the block below, grass with its rule of the block above) change exactly the cells the document says (the circle of the drawn radius, the half height, the target blocks)
*> to the states of their providers, checked cell by cell against an independent model of the original chunk; a rule_based provider falls back when a rule's provider gives no state, and
*> a provider with no state and no fallback writes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-DISK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-SAVE                PIC X(196608).
 01 WS-SAVE-TABLE REDEFINES WS-SAVE.
    05 WS-SV               BINARY-SHORT UNSIGNED OCCURS 98304 TIMES.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RLO                 BINARY-LONG.
 01 WS-RHI                 BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ORIG                BINARY-LONG.
 01 WS-OB                  BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-S-DIRT              BINARY-LONG.
 01 WS-S-GRASS             BINARY-LONG.
 01 WS-S-GRASS-F           BINARY-LONG.
 01 WS-S-GRAVEL            BINARY-LONG.
 01 WS-S-CLAY              BINARY-LONG.
 01 WS-S-SAND              BINARY-LONG.
 01 WS-S-SANDSTONE         BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-B-DIRT              BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-CLAY              BINARY-LONG.
 01 WS-B-MUD               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-ABOVE-B             BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-SOLID-ABOVE         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     PERFORM RESOLVE
     MOVE "minecraft:disk_gravel" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§5: the data feature disk_gravel compiles as a disk (10)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 10 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§5: its half height is 2" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 2 TO WS-EXP
     PERFORM ASSERT-N

*>   gravel: dirt and grass blocks of the circle within two of the origin, radius 2 + nextInt(4)
     MOVE 1 TO WS-MODE
     MOVE 2 TO WS-RLO
     MOVE 5 TO WS-RHI
     MOVE 2 TO WS-HH
     PERFORM RUN-DISK
     MOVE "35-5§5: disk_gravel changes the cells of the circle and the half height, to gravel, as the model says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§5: and returns true having written" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 1000 + WS-CHANGED
     IF WS-CHANGED > 0
         COMPUTE WS-OBS = WS-RESULT * 1000 + 1
     END-IF
     MOVE 1001 TO WS-EXP
     PERFORM ASSERT-N

*>   clay: dirt and clay of three layers, radius 2 or 3
     MOVE "minecraft:disk_clay" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 2 TO WS-MODE
     MOVE 2 TO WS-RLO
     MOVE 3 TO WS-RHI
     MOVE 1 TO WS-HH
     PERFORM RUN-DISK
     MOVE "35-5§5: disk_clay changes dirt (not grass) in three layers to clay, as the model says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   sand: sandstone where the block below is air, else sand; an air pocket under a grass block
     MOVE "minecraft:disk_sand" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 3 TO WS-MODE
     MOVE 2 TO WS-RLO
     MOVE 6 TO WS-RHI
     MOVE 2 TO WS-HH
     PERFORM RUN-DISK
     MOVE "35-5§5: disk_sand lays sand, and sandstone over air, as the model says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   grass: dirt that has no solid or water above becomes grass (snowy false), other dirt stays dirt
     MOVE "minecraft:disk_grass" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 4 TO WS-MODE
     MOVE 2 TO WS-RLO
     MOVE 6 TO WS-RHI
     MOVE 2 TO WS-HH
     PERFORM RUN-DISK
     MOVE "35-5§5: disk_grass makes the free dirt grass_block[snowy=false] and keeps covered dirt, as the model says" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a rule whose provider gives no state is skipped, the fallback follows
     MOVE "minecraft:disk_nested" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE 1 TO WS-MODE
     MOVE 2 TO WS-RLO
     MOVE 5 TO WS-RHI
     MOVE 2 TO WS-HH
     PERFORM RUN-DISK
     MOVE "35-2§4: a rule_based provider whose rules give nothing falls back to its fallback (gravel again)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   no fallback: no state, nothing written, false
     MOVE "minecraft:disk_nofallback" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     MOVE "35-2§4: a rule_based provider with no rule that holds and no fallback writes nothing" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM COMPARE-WITH-SAVE
     MOVE "35-2§4: and the chunk is unchanged" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   the gate
     MOVE 1 TO FI-GATE
     MOVE "minecraft:disk_sand" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§5: the gate admits the disk placed features" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:ice_patch" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§5: and ice_patch" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   features that cannot be compiled whole
     MOVE "minecraft:disk_no_target" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§5: a disk without target is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:disk_bad_radius" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§5: a disk whose radius is no int provider is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:disk_no_half" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§5: a disk without half_height is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:disk_bad_provider" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-5§5: a disk with an unknown state provider is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE "minecraft:disk_many_rules" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE "35-2§4: a rule_based provider of more than 16 rules is unsupported" TO WS-CASE
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:disk_gravel2" TO WS-FTKEY
     PERFORM CHECK-BAD
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§5: a full feature table makes the disk unsupported" TO WS-CASE
     PERFORM ASSERT-N
     STOP RUN.

 CHECK-BAD.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     .
 RESOLVE.
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-DIRT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIRT
     MOVE "grass_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GRASS
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRASS
     MOVE SPACES TO WS-PAIRS
     MOVE "snowy=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-GRASS-F
     MOVE "gravel" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRAVEL
     MOVE "clay" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-CLAY
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-CLAY
     MOVE "sand" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SAND
     MOVE "sandstone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SANDSTONE
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "mud" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-MUD
     MOVE 0 TO WS-S-AIR
     .
*> RUN-DISK: a fresh world, the feature WS-FT placed at (24, 62, 40) with the seed WS-SEED, then the comparison with the model of WS-MODE (WS-BAD cells differ, WS-CHANGED cells changed)
 RUN-DISK.
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     COMPUTE WS-BOUND = WS-RHI - WS-RLO + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DRAW
     COMPUTE WS-R = WS-RLO + WS-DRAW
     MOVE 0 TO WS-BAD WS-CHANGED
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 56 BY 1 UNTIL WS-Y > 68
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 MOVE WS-SV(WS-INDEX) TO WS-ORIG
                 MOVE WS-ORIG TO WS-WANT
                 COMPUTE WS-DX = 24 - WS-X
                 COMPUTE WS-DZ = 40 - WS-Z
                 CALL "FL-BLOCK-OF" USING WS-ORIG WS-OB
                 MOVE 0 TO WS-TARGET
                 EVALUATE WS-MODE
                     WHEN 1
                         IF WS-OB = WS-B-DIRT OR WS-OB = WS-B-GRASS
                             MOVE 1 TO WS-TARGET
                         END-IF
                     WHEN 2
                         IF WS-OB = WS-B-DIRT OR WS-OB = WS-B-CLAY
                             MOVE 1 TO WS-TARGET
                         END-IF
                     WHEN 3
                         IF WS-OB = WS-B-DIRT OR WS-OB = WS-B-GRASS
                             MOVE 1 TO WS-TARGET
                         END-IF
                     WHEN OTHER
                         IF WS-OB = WS-B-DIRT OR WS-OB = WS-B-MUD
                             MOVE 1 TO WS-TARGET
                         END-IF
                 END-EVALUATE
                 IF WS-DX * WS-DX + WS-DZ * WS-DZ <= WS-R * WS-R AND WS-Y >= 62 - WS-HH AND WS-Y <= 62 + WS-HH AND WS-TARGET = 1
                     PERFORM MODEL-STATE
                 END-IF
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-WANT
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-STATE NOT = WS-ORIG
                     ADD 1 TO WS-CHANGED
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> MODEL-STATE: WS-WANT, the state a target cell of the original model gets (the original cells of the neighbours decide the rules: they are unchanged where they matter)
 MODEL-STATE.
     EVALUATE WS-MODE
         WHEN 1
             MOVE WS-S-GRAVEL TO WS-WANT
         WHEN 2
             MOVE WS-S-CLAY TO WS-WANT
         WHEN 3
             COMPUTE WS-INDEX = (WS-Y - 1 + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
             MOVE WS-SV(WS-INDEX) TO WS-BELOW
             MOVE WS-S-SAND TO WS-WANT
             IF WS-BELOW = WS-S-AIR
                 MOVE WS-S-SANDSTONE TO WS-WANT
             END-IF
         WHEN OTHER
             COMPUTE WS-INDEX = (WS-Y + 1 + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
             MOVE WS-SV(WS-INDEX) TO WS-ABOVE
             CALL "FL-BLOCK-OF" USING WS-ABOVE WS-ABOVE-B
             MOVE 0 TO WS-SOLID-ABOVE
             IF WS-ABOVE-B > 0 AND WS-ABOVE NOT = WS-S-AIR
                 MOVE CB-SOLID(WS-ABOVE-B) TO WS-SOLID-ABOVE
             END-IF
             IF WS-ABOVE = WS-S-WATER
                 MOVE 1 TO WS-SOLID-ABOVE
             END-IF
             MOVE WS-S-DIRT TO WS-WANT
             IF WS-SOLID-ABOVE = 0
                 MOVE WS-S-GRASS-F TO WS-WANT
             END-IF
     END-EVALUATE
     .
 COMPARE-WITH-SAVE.
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 56 BY 1 UNTIL WS-Y > 68
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-SV(WS-INDEX)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 59, dirt 60 to 62, grass_block at 63 (for the dirt-top disk_grass the top is dirt: WS-MODE 4), an air pocket under the grass at (25, 62, 40), stone above (26, 63, 40)
*> (a dirt top there) and water above (27, 63, 40); the saved copy of the states is the model; both random sources are seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 59 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 60 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "dirt" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 63 TO WS-Y0
     MOVE 63 TO WS-Y1
     MOVE "grass_block" TO WS-KEY
     IF WS-MODE = 4
         MOVE "dirt" TO WS-KEY
     END-IF
     PERFORM FILL-BOX
     MOVE 25 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE "air" TO WS-KEY
     PERFORM PUT-AT
     MOVE 26 TO WS-X
     MOVE 64 TO WS-Y
     MOVE "stone" TO WS-KEY
     PERFORM PUT-AT
     MOVE 27 TO WS-X
     MOVE "water" TO WS-KEY
     PERFORM PUT-AT
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE CE-STATES TO WS-SAVE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-DISK.
 COPY CORETEST.
