*> Implementation test (lane p70c, T23503; docs/protocol/18 section 5.1, 54 section 7.1, 44-x2 section 1.2; core/src/mob-44-goat2.cob): the kind of a block as a path type (LIVE-BLOCK-KIND), the static path type of a cell
*> with its neighbour check (LIVE-STATIC-PATH-TYPE), walkable blocks (MOB-WALKABLE) and the goat's run-up cell (M44-RAM-RUNUP: open ground, a nearer candidate sorting first, a target that is not walkable, walls that
*> leave no candidate 4 away, a goat enclosed so that no candidate has a path).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-WALKABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-ROWS.
    05 FILLER PIC X(48) VALUE "air                             air             ".
    05 FILLER PIC X(48) VALUE "short_grass                     air             ".
    05 FILLER PIC X(48) VALUE "water                           water           ".
    05 FILLER PIC X(48) VALUE "lava                            lava            ".
    05 FILLER PIC X(48) VALUE "fire                            fire            ".
    05 FILLER PIC X(48) VALUE "soul_fire                       fire            ".
    05 FILLER PIC X(48) VALUE "cactus                          cactus          ".
    05 FILLER PIC X(48) VALUE "sweet_berry_bush                sweet_berry_bush".
    05 FILLER PIC X(48) VALUE "honey_block                     honey           ".
    05 FILLER PIC X(48) VALUE "cocoa                           cocoa           ".
    05 FILLER PIC X(48) VALUE "wither_rose                     wither_rose     ".
    05 FILLER PIC X(48) VALUE "pointed_dripstone               wither_rose     ".
    05 FILLER PIC X(48) VALUE "powder_snow                     powder_snow     ".
    05 FILLER PIC X(48) VALUE "lily_pad                        lily_pad        ".
    05 FILLER PIC X(48) VALUE "big_dripleaf                    lily_pad        ".
    05 FILLER PIC X(48) VALUE "oak_trapdoor                    trapdoor        ".
    05 FILLER PIC X(48) VALUE "oak_leaves                      leaves          ".
    05 FILLER PIC X(48) VALUE "oak_fence_gate                  fence_gate      ".
    05 FILLER PIC X(48) VALUE "oak_fence                       fence           ".
    05 FILLER PIC X(48) VALUE "cobblestone_wall                wall            ".
    05 FILLER PIC X(48) VALUE "rail                            rail            ".
    05 FILLER PIC X(48) VALUE "stone                           solid           ".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW-ENTRY OCCURS 22 TIMES.
       10 WS-ROW-KEY       PIC X(32).
       10 WS-ROW-KIND      PIC X(16).
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-FEET                BINARY-LONG VALUE 41.
 01 WS-TOP                 BINARY-LONG VALUE 42.
 01 WS-GFEET               BINARY-LONG VALUE 41.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-KIND                PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE WS-CX = WS-X0 + 24
     COMPUTE WS-CZ = WS-Z0 + 24
     MOVE "T" TO TL-MODE

*>   Every kind, one block each along x at feet height over the floor.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-ROW-KEY(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
         COMPUTE WS-X = WS-CX - 11 + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-CZ WS-STATE
         CALL "LIVE-BLOCK-KIND" USING WS-DIM WS-X WS-FEET WS-CZ WS-KIND
         MOVE SPACES TO TL-CASE
         STRING "test mob walkable kind of " FUNCTION TRIM(WS-ROW-KEY(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-ROW-KIND(WS-I) TO TL-EXPECTED
         MOVE WS-KIND TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-CZ WS-AIR
     END-PERFORM

*>   Static path types of the cell (cx, 41, cz+4): open ground, then beside water, a cactus, fire, lava and a pointed dripstone, over water, over lava, in the air, inside the floor.
     COMPUTE WS-Z = WS-CZ + 4
     MOVE WS-CX TO WS-X
     CALL "LIVE-STATIC-PATH-TYPE" USING WS-DIM WS-X WS-FEET WS-Z WS-TYPE
     MOVE WS-TYPE TO WS-E1
     MOVE "minecraft:water" TO WS-KEY
     PERFORM PUT-NEXT
     MOVE WS-TYPE TO WS-E2
     MOVE "minecraft:cactus" TO WS-KEY
     PERFORM PUT-NEXT
     MOVE WS-TYPE TO WS-E3
     MOVE "minecraft:fire" TO WS-KEY
     PERFORM PUT-NEXT
     MOVE WS-TYPE TO WS-E4
     MOVE SPACES TO TL-CASE
     MOVE "test mob walkable static type: open ground 2, beside water 10, beside a cactus 15, beside fire 13" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 10 15 13" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:lava" TO WS-KEY
     PERFORM PUT-NEXT
     MOVE WS-TYPE TO WS-E1
     MOVE "minecraft:pointed_dripstone" TO WS-KEY
     PERFORM PUT-NEXT
     MOVE WS-TYPE TO WS-E2
     MOVE "minecraft:water" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE WS-TYPE TO WS-E3
     MOVE "minecraft:lava" TO WS-KEY
     PERFORM PUT-BELOW
     MOVE WS-TYPE TO WS-E4
     MOVE "test mob walkable static type: beside lava 13, beside a dripstone 24, over water 9, over lava 8" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "13 24 9 8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 46 TO WS-Y
     CALL "LIVE-STATIC-PATH-TYPE" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE
     MOVE WS-TYPE TO WS-E1
     COMPUTE WS-X = WS-CX + 5
     CALL "LIVE-STATIC-PATH-TYPE" USING WS-DIM WS-X WS-FLOOR WS-Z WS-TYPE
     MOVE WS-TYPE TO WS-E2
     MOVE "test mob walkable static type: open air over open air is OPEN (1), a cell inside the floor is BLOCKED (0)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Walkable: open ground, beside water or a cactus (malus 8), over air, inside the floor.
     COMPUTE WS-Z = WS-CZ - 4
     MOVE WS-CX TO WS-X
     CALL "MOB-WALKABLE" USING WS-DIM WS-X WS-FEET WS-Z WS-OK
     MOVE WS-OK TO WS-E1
     MOVE "minecraft:water" TO WS-KEY
     PERFORM PUT-NEXT-AT-Z
     CALL "MOB-WALKABLE" USING WS-DIM WS-X WS-FEET WS-Z WS-OK
     MOVE WS-OK TO WS-E2
     MOVE 46 TO WS-Y
     CALL "MOB-WALKABLE" USING WS-DIM WS-X WS-Y WS-Z WS-OK
     MOVE WS-OK TO WS-E3
     CALL "MOB-WALKABLE" USING WS-DIM WS-X WS-FLOOR WS-Z WS-OK
     MOVE WS-OK TO WS-E4
     MOVE "test mob walkable block: open ground 1, beside water 0, over air 0, inside the floor 0" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The run-up: open ground around T = (cx - 15, 41, cz - 15), the goat 5 blocks north of it: the cell 7 blocks north.
     COMPUTE WS-CX = WS-X0 + 16
     COMPUTE WS-CZ = WS-Z0 + 20
     COMPUTE WS-GX = WS-CX
     COMPUTE WS-GZ = WS-CZ - 5
     CALL "M44-RAM-RUNUP" USING WS-DIM WS-GX WS-GFEET WS-GZ WS-CX WS-FEET WS-CZ WS-FOUND WS-SX WS-SY WS-SZ
     COMPUTE WS-DX = WS-SX - WS-CX
     COMPUTE WS-DZ = WS-SZ - WS-CZ
     MOVE WS-FOUND TO WS-E1
     MOVE WS-DX TO WS-E2
     MOVE WS-DZ TO WS-E3
     MOVE "test mob walkable run-up: the goat north of the target takes the cell 7 north of it" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 -7" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The goat 3 east of T: the east cell (7 east) is the nearest and sorts before the north one.
     COMPUTE WS-GX = WS-CX + 3
     MOVE WS-CZ TO WS-GZ
     CALL "M44-RAM-RUNUP" USING WS-DIM WS-GX WS-GFEET WS-GZ WS-CX WS-FEET WS-CZ WS-FOUND WS-SX WS-SY WS-SZ
     COMPUTE WS-DX = WS-SX - WS-CX
     COMPUTE WS-DZ = WS-SZ - WS-CZ
     MOVE WS-FOUND TO WS-E1
     MOVE WS-DX TO WS-E2
     MOVE WS-DZ TO WS-E3
     MOVE "test mob walkable run-up: the goat east of the target takes the cell 7 east of it (nearest first)" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 7 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A target on a block that is not walkable (beside water) has no run-up.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-X = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-CZ WS-STATE
     CALL "M44-RAM-RUNUP" USING WS-DIM WS-GX WS-GFEET WS-GZ WS-CX WS-FEET WS-CZ WS-FOUND WS-SX WS-SY WS-SZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-CZ WS-AIR
     MOVE "test mob walkable run-up: a target beside water is no walkable block: no run-up" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Walls (stone, two high) 3 blocks from T on all four sides: every direction stops 2 away, none is 4 away.
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = WS-CX + WS-I
         COMPUTE WS-Z = WS-CZ - 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         COMPUTE WS-Z = WS-CZ + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         COMPUTE WS-X = WS-CX - 3
         COMPUTE WS-Z = WS-CZ + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         COMPUTE WS-X = WS-CX + 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
     END-PERFORM
     COMPUTE WS-GX = WS-CX + 1
     COMPUTE WS-GZ = WS-CZ + 1
     CALL "M44-RAM-RUNUP" USING WS-DIM WS-GX WS-GFEET WS-GZ WS-CX WS-FEET WS-CZ WS-FOUND WS-SX WS-SY WS-SZ
     MOVE "test mob walkable run-up: walls 3 around the target leave no cell 4 away: no run-up" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A goat shut in by walls two high cannot reach any candidate: no run-up. T is open ground 12 north of the walls.
     COMPUTE WS-GX = WS-X0 + 40
     COMPUTE WS-GZ = WS-Z0 + 40
     COMPUTE WS-CZ = WS-GZ - 10
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         COMPUTE WS-X = WS-GX + WS-I
         COMPUTE WS-Z = WS-GZ - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-TOP WS-Z WS-STATE
         COMPUTE WS-Z = WS-GZ + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-TOP WS-Z WS-STATE
         COMPUTE WS-X = WS-GX - 1
         COMPUTE WS-Z = WS-GZ + WS-I
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-TOP WS-Z WS-STATE
         COMPUTE WS-X = WS-GX + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-TOP WS-Z WS-STATE
     END-PERFORM
     MOVE WS-GX TO WS-CX
     CALL "M44-RAM-RUNUP" USING WS-DIM WS-GX WS-GFEET WS-GZ WS-CX WS-FEET WS-CZ WS-FOUND WS-SX WS-SY WS-SZ
     MOVE "test mob walkable run-up: a goat in a walled cell reaches no candidate: no run-up" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-FOUND TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The block of WS-KEY at (cx, 41, cz+4) + 1 east: its static type is read at (cx, 41, cz+4).
 PUT-NEXT.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-Z = WS-CZ + 4
     COMPUTE WS-X = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
     MOVE WS-CX TO WS-X
     CALL "LIVE-STATIC-PATH-TYPE" USING WS-DIM WS-X WS-FEET WS-Z WS-TYPE
     COMPUTE WS-X = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-AIR
     MOVE WS-CX TO WS-X.

*> The block of WS-KEY in the floor below (cx, 41, cz+4): the static type there.
 PUT-BELOW.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-Z = WS-CZ + 4
     MOVE WS-CX TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
     CALL "LIVE-STATIC-PATH-TYPE" USING WS-DIM WS-X WS-FEET WS-Z WS-TYPE.

*> The block of WS-KEY next to (cx, 41, cz-4), to the east.
 PUT-NEXT-AT-Z.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-X = WS-CX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FEET WS-Z WS-STATE
     MOVE WS-CX TO WS-X.
 END PROGRAM TEST-MOB-WALKABLE.
 COPY CORETEST.
 COPY MOBSPTEST.
