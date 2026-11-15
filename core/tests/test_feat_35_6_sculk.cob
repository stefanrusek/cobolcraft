*> Implementation test of the sculk patch (docs/protocol/35-worldgen-features-6 section 8; core/src/feat-sculk.cob): the data features compile (type 40; a missing number, a block or tag the
*> content set lacks, a full table make the feature unsupported); patches run in hand-made worlds (a pocket in stone, the surface of a floor, a cavity, a water source, an origin that
*> already is sculk or a vein, growth rounds without spreading, more cursors than fit) and every changed cell obeys the rules of 8.3 to 8.6: only sculk, sculk_vein, sensors, shrieker, air and
*> water are written, sculk replaces stone of sculk_replaceable_world_gen only, each face of a vein touches a solid block, sensors and shriekers stand on sculk, nothing changes
*> beyond 13 blocks of the origin; origins that cannot start a patch (stone, air with no solid neighbour) give false and draw nothing; the sensor and shrieker growth, the decay and the
*> vein discharge happen in the runs. No independent model of the whole spreader is written: the cases check the rules as invariants over many seeds and the counts the runs reach.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-SCULK.
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
 COPY FEATDIR.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/sculk".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-MODEL.
    05 WS-MS               BINARY-LONG OCCURS 98304 TIMES.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OBLOCK              BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-PTEXT               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-D1                  BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-NM                  PIC X(11).
 01 WS-NL                  BINARY-LONG.
 01 WS-FACES               PIC X(6).
 01 WS-WL                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-N-STONE             BINARY-LONG.
 01 WS-N-SCULK             BINARY-LONG.
 01 WS-N-VEIN              BINARY-LONG.
 01 WS-N-SENSOR            BINARY-LONG.
 01 WS-N-SHRIEKER          BINARY-LONG.
 01 WS-N-WATER             BINARY-LONG.
 01 WS-S-SCULK             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-T-SCULK             BINARY-LONG.
 01 WS-T-VEIN              BINARY-LONG.
 01 WS-T-SENSOR            BINARY-LONG.
 01 WS-T-SHRIEKER          BINARY-LONG.
 01 WS-T-WATER             BINARY-LONG.
 01 WS-T-FIRE              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-C-LIVE              BINARY-LONG.
 01 WS-C-SENSOR            BINARY-LONG.
 01 WS-C-SHRIEKER          BINARY-LONG.
 01 WS-SAVE-LO            BINARY-DOUBLE UNSIGNED.
 01 WS-SAVE-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-NAMES.
    05 FILLER PIC X(11) VALUE "down=true".
    05 FILLER PIC X(11) VALUE "up=true".
    05 FILLER PIC X(11) VALUE "north=true".
    05 FILLER PIC X(11) VALUE "south=true".
    05 FILLER PIC X(11) VALUE "west=true".
    05 FILLER PIC X(11) VALUE "east=true".
 01 WS-NAME-T REDEFINES WS-NAMES.
    05 WS-DNAME            PIC X(11) OCCURS 6 TIMES.
 01 WS-NLEN.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 7.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 9.
    05 FILLER BINARY-LONG VALUE 9.
 01 WS-NLEN-T REDEFINES WS-NLEN.
    05 WS-DLEN             BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "core/tests/fixtures/sculk-gen" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-N-STONE
     MOVE "sculk" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-SCULK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SCULK
     MOVE "sculk_vein" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-VEIN
     MOVE "sculk_sensor" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-SENSOR
     MOVE "sculk_shrieker" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-SHRIEKER
     MOVE "fire" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-FIRE
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-T-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
*>   the data features compile
     MOVE "minecraft:sp_deep" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§8: the data feature sp_deep compiles as sculk_patch (40)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 40 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.1: charge_count, amount_per_charge, spread_attempts, growth_rounds, spread_rounds read (10, 32, 64, 0, 1)" TO WS-CASE
     COMPUTE WS-OBS = WA-I(FT-A(WS-FT), 3) * 100000000 + WA-I(FT-A(WS-FT), 4) * 1000000 + WA-I(FT-A(WS-FT), 5) * 1000 + WA-I(FT-A(WS-FT), 6) * 10 + WA-I(FT-A(WS-FT), 7)
     MOVE 1032064001 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.3: the tags of the spreader are pools (world gen replaceable, replaceable, inhibitors, fire) that are not empty" TO WS-CASE
     MOVE 1 TO WS-OBS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         IF WA-N(FT-A(WS-FT), WS-K) = 0
             MOVE 0 TO WS-OBS
         END-IF
     END-PERFORM
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:sp_no_count" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§8.1: a patch without charge_count is unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:sp_bad_full" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-6§8: a full feature table makes the patch unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   the gate
     MOVE 1 TO FI-GATE
     MOVE "minecraft:sculk_patch_deep_dark" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§8: the gate admits sculk_patch_deep_dark" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   origins that cannot start a patch: stone, and air with no solid neighbour; nothing is drawn
     MOVE "minecraft:sp_deep" TO WS-FTKEY
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 50 TO WS-OY
     MOVE 40 TO WS-OZ
     PERFORM START-RUN
     MOVE "35-6§8.2 step 1: an origin inside stone gives false, no change, no draw" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 100 + WS-CHANGED * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 66 TO WS-OY
     PERFORM START-RUN
     MOVE "35-6§8.2 step 1: air with no solid neighbour gives false, no change, no draw" TO WS-CASE
     COMPUTE WS-OBS = WS-RESULT * 100 + WS-CHANGED * 10 + WS-OK
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a pocket of air in the stone, ten seeds
     MOVE 0 TO WS-BAD WS-N-SCULK
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 50 TO WS-OY
         MOVE 40 TO WS-OZ
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         MOVE "air" TO WS-KEY
         PERFORM PUT-AT
         PERFORM SNAPSHOT
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1 OR WS-CHANGED = 0
             ADD 1 TO WS-BAD
         END-IF
         ADD WS-C-LIVE TO WS-N-SCULK
     END-PERFORM
     MOVE "35-6§8: a patch in a pocket in stone obeys the rules of the spreader (invariants, ten seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.5: and sculk was made from the stone around the pocket" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SCULK > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the surface of a floor: the cell above the sculk takes sensors and shriekers
     MOVE 0 TO WS-BAD WS-N-SENSOR WS-N-SHRIEKER WS-N-SCULK
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 30
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         ADD WS-C-SENSOR TO WS-N-SENSOR
         ADD WS-C-SHRIEKER TO WS-N-SHRIEKER
         ADD WS-C-LIVE TO WS-N-SCULK
     END-PERFORM
     MOVE "35-6§8: patches on the surface of a floor obey the rules (invariants, twenty seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.5: sculk spread over the floor and sensors were grown" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SCULK > 10 AND WS-N-SENSOR > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.5: and at least one shrieker (one growth in eleven)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SHRIEKER > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a cavity in the stone, the growth configuration (two rounds without spreading)
     MOVE "minecraft:sp_growth" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         PERFORM CARVE-CAVITY
         MOVE 24 TO WS-OX
         MOVE 51 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8: patches in a cavity, two spread rounds and two growth rounds, obey the rules (ten seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   more cursors than fit (32) and amounts over 1000
     MOVE "minecraft:sp_big" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 14
         PERFORM NEW-WORLD
         PERFORM CARVE-CAVITY
         MOVE 24 TO WS-OX
         MOVE 51 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.2: forty charges of 1500 (two cursors each, at most 32 in the list), one growth round, obey the rules (four seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a water source on the floor, and origins that already are sculk or a vein
     MOVE "minecraft:sp_deep" TO WS-FTKEY
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 40 TO WS-OZ
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         MOVE "water" TO WS-KEY
         PERFORM PUT-AT
         PERFORM SNAPSHOT
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.2 step 1: a water source on a floor starts a patch (veins waterlogged), ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 70
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 62 TO WS-OY
         MOVE 40 TO WS-OZ
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         MOVE "sculk" TO WS-KEY
         PERFORM PUT-AT
         PERFORM SNAPSHOT
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.2 step 1: an origin that is a sculk block starts a patch, sixty seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         MOVE 24 TO WS-OX
         MOVE 63 TO WS-OY
         MOVE 40 TO WS-OZ
         MOVE WS-OX TO WS-X
         MOVE WS-OY TO WS-Y
         MOVE WS-OZ TO WS-Z
         MOVE "sculk_vein" TO WS-KEY
         MOVE "down=true,east=false,north=false,south=false,up=false,waterlogged=false,west=false" TO WS-PAIRS
         PERFORM PUT-PAIRS
         PERFORM SNAPSHOT
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.2 step 1: an origin that is a vein starts a patch, ten seeds" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a cavity with lava and fire in it: lava and fire are never replaced
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 40
         PERFORM NEW-WORLD
         PERFORM CARVE-CAVITY
         MOVE "lava" TO WS-KEY
         PERFORM PUT-HAZARD-LAVA
         MOVE "fire" TO WS-KEY
         PERFORM PUT-HAZARD-FIRE
         PERFORM SNAPSHOT
         MOVE 24 TO WS-OX
         MOVE 51 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.6: in a cavity with lava and fire the veins and sculk never replace them (forty seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a cavity full of water: sculk grows waterlogged sensors under water
     MOVE 0 TO WS-BAD WS-N-SENSOR
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 40
         PERFORM NEW-WORLD
         MOVE 20 TO WS-X0
         MOVE 28 TO WS-X1
         MOVE 51 TO WS-Y0
         MOVE 55 TO WS-Y1
         MOVE 36 TO WS-Z0
         MOVE 44 TO WS-Z1
         MOVE "water" TO WS-KEY
         PERFORM FILL-BOX
         PERFORM SNAPSHOT
         MOVE 24 TO WS-OX
         MOVE 51 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         ADD WS-C-SENSOR TO WS-N-SENSOR
         ADD WS-C-SHRIEKER TO WS-N-SENSOR
     END-PERFORM
     MOVE "35-6§8.5: in a cavity full of water the patch obeys the rules (forty seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§8.5: and sensors or shriekers were grown under water" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SENSOR > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a stone pillar in a cavity with a vein on its side: when the sculk is made from the pillar top, the vein beside it loses its face toward the sculk and goes (discharge)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-SEED FROM 11 BY 1 UNTIL WS-SEED > 20
         PERFORM NEW-WORLD
         PERFORM CARVE-CAVITY
         MOVE 24 TO WS-X
         MOVE 51 TO WS-Y
         MOVE 40 TO WS-Z
         MOVE "stone" TO WS-KEY
         PERFORM PUT-AT
         MOVE 52 TO WS-Y
         PERFORM PUT-AT
         MOVE 25 TO WS-X
         MOVE "sculk_vein" TO WS-KEY
         MOVE "down=false,east=false,north=false,south=false,up=false,waterlogged=false,west=true" TO WS-PAIRS
         PERFORM PUT-PAIRS
         PERFORM SNAPSHOT
         MOVE 24 TO WS-OX
         MOVE 53 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM START-RUN
         PERFORM CHECK-RULES
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         MOVE 25 TO WS-X
         MOVE 52 TO WS-Y
         MOVE 40 TO WS-Z
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS NOT = 1 AND WS-STATE NOT = WS-S-WATER
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "35-6§8.5: a vein beside the sculk that was made loses its face and goes (ten seeds)" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   regrow: the facings of a vein whose cell holds water, and facings with nothing to attach to
     PERFORM NEW-WORLD
     MOVE 24 TO WS-OX
     MOVE 50 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE WS-OX TO WS-X
     MOVE WS-OY TO WS-Y
     MOVE WS-OZ TO WS-Z
     MOVE "water" TO WS-KEY
     PERFORM PUT-AT
     MOVE "minecraft:sp_deep" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE "111111" TO WS-FACES
     CALL "FS-REGROW" USING WS-ROW WS-OX WS-OY WS-OZ WS-FACES WS-OK
     MOVE "35-6§8.5 regrow: facings toward solid blocks give a vein (ok)" TO WS-CASE
     MOVE WS-OK TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     CALL "FL-GET-STATE" USING WS-OX WS-OY WS-OZ WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PTEXT
     MOVE 0 TO WS-TALLY
     INSPECT WS-PTEXT TALLYING WS-TALLY FOR ALL "true"
     MOVE "35-6§8.5 regrow: six faces and waterlogged in water (seven true values)" TO WS-CASE
     MOVE WS-TALLY TO WS-OBS
     MOVE 7 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 66 TO WS-OY
     MOVE "100000" TO WS-FACES
     CALL "FS-REGROW" USING WS-ROW WS-OX WS-OY WS-OZ WS-FACES WS-OK
     MOVE "35-6§8.5 regrow: a facing toward air gives false (ok 0)" TO WS-CASE
     MOVE WS-OK TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a content set without the blocks of the spreader (the cobolcraft world type): the patch is unsupported
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE "core/tests/fixtures/sculk-gen" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "FD-RESET"
     MOVE "minecraft:sp_growth" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§8: a content set without sculk blocks makes the patch unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

*> PUT-HAZARD-LAVA and PUT-HAZARD-FIRE: the block WS-KEY (lava or fire) on three cells of the cavity floor each
 PUT-HAZARD-LAVA.
     MOVE 51 TO WS-Y
     MOVE 22 TO WS-X
     MOVE 38 TO WS-Z
     PERFORM PUT-AT
     MOVE 26 TO WS-X
     MOVE 42 TO WS-Z
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     MOVE 43 TO WS-Z
     PERFORM PUT-AT
     MOVE 25 TO WS-X
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     .
 PUT-HAZARD-FIRE.
     MOVE 51 TO WS-Y
     MOVE 22 TO WS-X
     MOVE 42 TO WS-Z
     PERFORM PUT-AT
     MOVE 26 TO WS-X
     MOVE 38 TO WS-Z
     PERFORM PUT-AT
     MOVE 23 TO WS-X
     MOVE 40 TO WS-Z
     PERFORM PUT-AT
     MOVE 24 TO WS-X
     MOVE 41 TO WS-Z
     PERFORM PUT-AT
     .

 COMPILE-FT.
     MOVE 0 TO FD-BAD
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     .
*> NEW-WORLD: chunk (1, 2): stone y 40 to 62, air above, stone y 70 to 80; the snapshot is taken at once
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 40 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 70 TO WS-Y0
     MOVE 80 TO WS-Y1
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
 SNAPSHOT.
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 98304
         MOVE CE-STATE(WS-INDEX) TO WS-MS(WS-INDEX)
     END-PERFORM
     .
*> CARVE-CAVITY: air x 20..28, y 51..55, z 36..44
 CARVE-CAVITY.
     MOVE 20 TO WS-X0
     MOVE 28 TO WS-X1
     MOVE 51 TO WS-Y0
     MOVE 55 TO WS-Y1
     MOVE 36 TO WS-Z0
     MOVE 44 TO WS-Z1
     MOVE "air" TO WS-KEY
     PERFORM FILL-BOX
     PERFORM SNAPSHOT
     .
*> START-RUN: seeds the random source with WS-SEED and places the feature WS-FTKEY at (WS-OX, WS-OY, WS-OZ); WS-OK is 1 when the random state is the seeded one (nothing was drawn)
 START-RUN.
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE XR-LO TO WS-SAVE-LO
     MOVE XR-HI TO WS-SAVE-HI
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
     MOVE 1 TO WS-OK
     IF XR-LO NOT = WS-SAVE-LO OR XR-HI NOT = WS-SAVE-HI
         MOVE 0 TO WS-OK
     END-IF
     PERFORM COUNT-CHANGED
     .
*> COUNT-CHANGED: WS-CHANGED = the number of cells that differ from the snapshot
 COUNT-CHANGED.
     MOVE 0 TO WS-CHANGED
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 80
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-INDEX)
                     ADD 1 TO WS-CHANGED
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> CHECK-RULES: every changed cell obeys 8.3 to 8.6 (a violation adds one to WS-BAD); WS-C-LIVE, WS-C-SENSOR, WS-C-SHRIEKER count the sculk, sensor and shrieker cells written
 CHECK-RULES.
     MOVE 0 TO WS-C-LIVE WS-C-SENSOR WS-C-SHRIEKER
     PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 80
                 COMPUTE WS-INDEX = (WS-Y + 64) * 256 + (WS-Z - 32) * 16 + (WS-X - 16) + 1
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-MS(WS-INDEX)
                     PERFORM CHECK-CELL
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 CHECK-CELL.
     MOVE WS-MS(WS-INDEX) TO WS-OLD
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FL-BLOCK-OF" USING WS-OLD WS-OBLOCK
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     COMPUTE WS-DX = FUNCTION ABS(WS-X - WS-OX)
     COMPUTE WS-DZ = FUNCTION ABS(WS-Z - WS-OZ)
     IF WS-DX > 13 OR WS-DZ > 13
         ADD 1 TO WS-BAD
     END-IF
     IF WS-BLOCK NOT = WS-T-SCULK AND WS-BLOCK NOT = WS-T-VEIN AND WS-BLOCK NOT = WS-T-SENSOR
         AND WS-BLOCK NOT = WS-T-SHRIEKER AND WS-BLOCK NOT = WS-T-WATER AND WS-CLASS NOT = 1
         ADD 1 TO WS-BAD
     END-IF
     CALL "FL-CLASS" USING WS-OLD WS-CLASS
     IF WS-CLASS = 3 OR WS-OBLOCK = WS-T-FIRE
         ADD 1 TO WS-BAD
     END-IF
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-BLOCK = WS-T-SCULK
         ADD 1 TO WS-C-LIVE
         IF WS-OBLOCK NOT = WS-N-STONE
             ADD 1 TO WS-BAD
         END-IF
     END-IF
     IF WS-BLOCK = WS-T-SENSOR OR WS-BLOCK = WS-T-SHRIEKER
         IF WS-BLOCK = WS-T-SENSOR
             ADD 1 TO WS-C-SENSOR
         ELSE
             ADD 1 TO WS-C-SHRIEKER
         END-IF
         COMPUTE WS-NY = WS-Y - 1
         MOVE WS-X TO WS-NX
         MOVE WS-Z TO WS-NZ
         CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-OLD
         CALL "FL-BLOCK-OF" USING WS-OLD WS-OBLOCK
         IF WS-OBLOCK NOT = WS-T-SCULK
             ADD 1 TO WS-BAD
         END-IF
     END-IF
     IF WS-BLOCK = WS-T-VEIN
         PERFORM FACES-AT
         MOVE 0 TO WS-TALLY
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-FACES(WS-K:1) = "1"
                 ADD 1 TO WS-TALLY
                 COMPUTE WS-NX = WS-X + FDR-DX(WS-K)
                 COMPUTE WS-NY = WS-Y + FDR-DY(WS-K)
                 COMPUTE WS-NZ = WS-Z + FDR-DZ(WS-K)
                 CALL "FM-SOLID" USING WS-NX WS-NY WS-NZ WS-SOLID
                 IF WS-SOLID = 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-PERFORM
         IF WS-TALLY = 0
             ADD 1 TO WS-BAD
         END-IF
     END-IF
     .
*> FACES-AT: WS-FACES = the face booleans of the block state WS-STATE by direction ordinal
 FACES-AT.
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PTEXT
     MOVE "000000" TO WS-FACES
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE 0 TO WS-TALLY
         MOVE WS-DNAME(WS-K) TO WS-NM
         MOVE WS-DLEN(WS-K) TO WS-NL
         INSPECT WS-PTEXT TALLYING WS-TALLY FOR ALL WS-NM(1:WS-NL)
         IF WS-TALLY > 0
             MOVE "1" TO WS-FACES(WS-K:1)
         END-IF
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-SCULK.
 COPY CORETEST.
