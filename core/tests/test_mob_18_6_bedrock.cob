*> Implementation test (lane bugcreative; operator report of try15 "mobs are spawning on bedrock"; docs/protocol/44-residual-mob-questions-1 RQ-1.10, 18 section 6.8
*> and 6.9, 24 part 1 section 4.1): the block below a natural spawn must pass Block.isValidSpawn, and the blocks that set the predicate to "never" (bedrock, glass,
*> tinted and stained glass, barrier, moving piston, scaffolding, the trapdoors, the copper grate) are never a floor, though their top face is sturdy. At night under open sky the
*> zombie rule passes on stone and never on those.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-BEDROCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-CASE               PIC X(120).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-QX                 BINARY-LONG.
 01 WS-QZ                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-CHUNK              BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-PAIRS              PIC X(160).
 01 WS-NAME               PIC X(24).
 01 WS-SPECIES            PIC X(24).
 01 WS-DENIED             BINARY-LONG.
 01 WS-TYPE               BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-ZROW               BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     MOVE "zombie" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-ZROW
     COMPUTE WS-QX = WS-PX + 20
     COMPUTE WS-QZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 30
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     MOVE 18000 TO CW-TIME
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM TRY-FLOOR
     MOVE "bugcreative RQ-1.10 a zombie spawns at night on a stone floor" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:bedrock" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:glass" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:tinted_glass" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:white_stained_glass" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:barrier" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:scaffolding" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:copper_grate" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:obsidian" TO WS-KEY
     PERFORM TRY-FLOOR-ONE
*>   The blocks whose isValidSpawn is "always" are floors whatever the shape of their top.
     MOVE "minecraft:soul_sand" TO WS-KEY
     PERFORM TRY-FLOOR-ONE
     MOVE "minecraft:mud" TO WS-KEY
     PERFORM TRY-FLOOR-ONE
     MOVE "minecraft:carved_pumpkin" TO WS-KEY
     PERFORM TRY-FLOOR-ONE
*>   (A jack o'lantern lights the cell above it, so the zombie's light rule refuses there: the floor rule is asserted directly.)
     MOVE "minecraft:jack_o_lantern" TO WS-KEY
     PERFORM ALWAYS-OF
     MOVE "minecraft:redstone_lamp" TO WS-KEY
     PERFORM TRY-FLOOR-ONE
*>   Leaves, ice and magma are species tests: no zombie floor.
     MOVE "minecraft:oak_leaves" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:ice" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:frosted_ice" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:magma_block" TO WS-KEY
     PERFORM TRY-FLOOR-NONE
     MOVE "minecraft:stone" TO WS-KEY
     MOVE "zombie" TO WS-SPECIES
     MOVE 0 TO WS-E
     PERFORM DENIED-OF
     MOVE "minecraft:oak_leaves" TO WS-KEY
     MOVE "ocelot" TO WS-SPECIES
     MOVE 0 TO WS-E
     PERFORM DENIED-OF
     MOVE "parrot" TO WS-SPECIES
     PERFORM DENIED-OF
     MOVE "zombie" TO WS-SPECIES
     MOVE 1 TO WS-E
     PERFORM DENIED-OF
     MOVE "minecraft:ice" TO WS-KEY
     MOVE "polar_bear" TO WS-SPECIES
     MOVE 0 TO WS-E
     PERFORM DENIED-OF
     MOVE "zombie" TO WS-SPECIES
     MOVE 1 TO WS-E
     PERFORM DENIED-OF
     MOVE "minecraft:frosted_ice" TO WS-KEY
     MOVE "polar_bear" TO WS-SPECIES
     MOVE 0 TO WS-E
     PERFORM DENIED-OF
     MOVE "minecraft:magma_block" TO WS-KEY
     MOVE "blaze" TO WS-SPECIES
     MOVE 0 TO WS-E
     PERFORM DENIED-OF
     MOVE "zombie" TO WS-SPECIES
     MOVE 1 TO WS-E
     PERFORM DENIED-OF
     MOVE "no_such_mob" TO WS-SPECIES
     PERFORM DENIED-OF
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> The pass count of 200 seeds with the block (WS-KEY, WS-PAIRS) as the floor under the spot.
 TRY-FLOOR.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-FY TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-QX WS-BY WS-QZ WS-STATE
     PERFORM RELIGHT
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-VALID-SPOT" USING XR-STATE WS-DIM WS-ZROW WS-QX WS-Y WS-QZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
 TRY-FLOOR-NONE.
     PERFORM TRY-FLOOR
     MOVE SPACES TO WS-CASE
     STRING "bugcreative RQ-1.10 no zombie spawns on " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N.
 ALWAYS-OF.
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-FY TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-QX WS-BY WS-QZ WS-STATE
     CALL "MS6-FLOOR-ALWAYS" USING WS-DIM WS-QX WS-BY WS-QZ WS-DENIED
     MOVE SPACES TO WS-CASE
     STRING "bugcreative RQ-1.10 the floor " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE " is always valid" DELIMITED BY SIZE
         INTO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-DENIED TO WS-O
     PERFORM CHECK-N.
 DENIED-OF.
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     MOVE WS-FY TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-QX WS-BY WS-QZ WS-STATE
     CALL "MS6-FLOOR-DENIED" USING WS-DIM WS-QX WS-BY WS-QZ WS-SPECIES WS-DENIED
     MOVE SPACES TO WS-CASE
     STRING "bugcreative RQ-1.10 the floor " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE " is denied to the " DELIMITED BY SIZE
         FUNCTION TRIM(WS-SPECIES) DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-DENIED TO WS-O
     PERFORM CHECK-N.
 TRY-FLOOR-ONE.
     PERFORM TRY-FLOOR
     MOVE SPACES TO WS-CASE
     STRING "bugcreative RQ-1.10 a zombie spawns on " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N.
 RELIGHT.
     PERFORM VARYING WS-A FROM -1 BY 1 UNTIL WS-A > 1
         PERFORM VARYING WS-B FROM -1 BY 1 UNTIL WS-B > 1
             COMPUTE WS-BX = WS-CX + WS-A
             COMPUTE WS-BZ = WS-CZ + WS-B
             CALL "WORLD-FIND" USING WS-DIM WS-BX WS-BZ WS-CHUNK
             IF WS-CHUNK > 0
                 MOVE 0 TO CK-LIT(WS-CHUNK)
             END-IF
             CALL "STDMOB-READY" USING WS-DIM WS-BX WS-BZ WS-OK
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-BEDROCK.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
