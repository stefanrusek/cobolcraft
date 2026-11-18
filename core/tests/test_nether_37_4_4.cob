*> Implementation test of the Nether's surface rules (core/src/nether-37-4.cob; T1675 to T1682; docs/protocol/37-nether-4 sections 2, 4, 5 and the worked
*> examples of section 9, world seed 0): the surface-depth random, the bedrock gradients (9 examples 2 and 3, 37-2 12.5 as a table), and the
*> rule tree at single blocks: the roof band, the wastes soul sand band and gravel (examples 5 and 6), the lava pool of the crimson forest
*> (example 7), the basalt deltas ceiling (example 8) and the bottom of the world (example 12). A noise value the document assumes is found
*> by searching the columns of seed 0 for one with that sign (the rule tests then use that column).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-4-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY NETHER.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-BIOME               BINARY-LONG.
 01 WS-SDA                 BINARY-LONG.
 01 WS-SDB                 BINARY-LONG.
 01 WS-SD                  BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-LINE                PIC X(8).
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-WHICH2              BINARY-LONG.
 01 WS-KIND2               BINARY-LONG.
 01 WS-WANT2               BINARY-LONG.
 01 WS-NAME                PIC X(60).
 01 WS-N2-SEL              BINARY-LONG VALUE 2.
 01 WS-KIND-SEL            BINARY-LONG VALUE 2.
 01 WS-TABLE-W             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM NETHER-TABLES
     CALL "NETHER-SETUP" USING WS-SEED
     PERFORM CHECK-RANDOM
     PERFORM CHECK-BEDROCK
     PERFORM CHECK-RULES
     GOBACK.

 CHECK-RANDOM.
     MOVE 0 TO WS-X WS-Z
     CALL "NETHER-AT" USING NH-FS WS-X WS-ZERO WS-Z WS-STATE
     CALL "NETHER-RAND-DOUBLE" USING WS-STATE WS-F
     MOVE "acceptance US12 37-4§9 9.4 R = P.at(0, 0, 0): first nextDouble 0.26044200501959935 (1e-15)" TO TL-CASE
     MOVE 260442005019599 TO TL-EXPECTED-N
     COMPUTE WS-SCALED = WS-F * 1000000000000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALED
     PERFORM ALLOW-ONE
     MOVE 16 TO WS-X
     MOVE -3 TO WS-Z
     CALL "NETHER-AT" USING NH-FS WS-X WS-ZERO WS-Z WS-STATE
     CALL "NETHER-RAND-DOUBLE" USING WS-STATE WS-F
     MOVE "acceptance US12 37-4§9 9.4 R = P.at(16, 0, -3): first nextDouble 0.3851230705401715 (1e-15)" TO TL-CASE
     MOVE 385123070540171 TO TL-EXPECTED-N
     COMPUTE WS-SCALED = WS-F * 1000000000000000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALED
     PERFORM ALLOW-ONE
*>   the surface depth of columns is a small number (surface noise within about +-1: 2.75 x + 3 + 0.25 r)
     MOVE 0 TO WS-W
     PERFORM VARYING WS-X FROM -20 BY 7 UNTIL WS-X > 100
         MOVE WS-X TO WS-Z
         CALL "NETHER-SURFACE-DEPTH" USING WS-X WS-Z WS-SD
         IF WS-SD < -1 OR WS-SD > 7
             ADD 1 TO WS-W
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-4§4 4.6 surface depth of 18 columns lies in -1 .. 7" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-W TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ALLOW-ONE.
     COMPUTE WS-DIFF = TL-OBSERVED-N - TL-EXPECTED-N
     IF WS-DIFF >= -1 AND WS-DIFF <= 1
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-BEDROCK.
*>   9 examples 2 and 3: (0, 1, 0) and (5, 2, 7) are bedrock; roof (0, 125, 0) is bedrock, (3, 124, 9) is not
     MOVE 1 TO WS-W
     MOVE 0 TO WS-X WS-Z
     MOVE 1 TO WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§9 9.2 floor gradient at (0, 1, 0) is true (float 0.653 < 0.8): bedrock" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 7 TO WS-Z
     MOVE 2 TO WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§9 9.2 floor gradient at (5, 2, 7) is true (float 0.542 < 0.6): bedrock" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-W
     MOVE 0 TO WS-X WS-Z
     MOVE 125 TO WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§9 9.3 roof gradient at (0, 125, 0) is false (float 0.790 >= 0.4): bedrock" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-X
     MOVE 9 TO WS-Z
     MOVE 124 TO WS-Y
     CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
     MOVE "acceptance US12 37-4§9 9.3 roof gradient at (3, 124, 9) is true (float 0.484 < 0.6): not bedrock" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-G TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   37-2 12.5: bedrock at x 0 .. 7, z 0 (B bedrock, . not): floor y 1 to 4, roof y 123 to 126 (bedrock where the roof gradient is false)
     MOVE 1 TO WS-W
     MOVE 1 TO WS-Y
     MOVE "BBBBB.BB" TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 2 TO WS-Y
     MOVE "BB..B.BB" TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 3 TO WS-Y
     MOVE "B.B.B..B" TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 4 TO WS-Y
     MOVE "........" TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 2 TO WS-W
     MOVE 123 TO WS-Y
     MOVE ".....B.." TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 124 TO WS-Y
     MOVE "B....B.." TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 125 TO WS-Y
     MOVE "BB.BBB.." TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 126 TO WS-Y
     MOVE ".BB...BB" TO WS-NAME
     PERFORM ROW-OF-BEDROCK
     MOVE 127 TO WS-Y
     MOVE "BBBBBBBB" TO WS-NAME
     PERFORM ROW-OF-BEDROCK.

 ROW-OF-BEDROCK.
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-NAME TO TL-EXPECTED
     MOVE 0 TO WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 7
         MOVE 1 TO WS-G
         IF WS-Y >= 127
             MOVE 0 TO WS-G
         ELSE
             CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
         END-IF
         COMPUTE WS-K = WS-X + 1
*>       the floor is bedrock where its gradient is true, the roof where its gradient is false
         IF (WS-W = 1 AND WS-G = 1) OR (WS-W = 2 AND WS-G = 0)
             MOVE "B" TO TL-OBSERVED(WS-K:1)
         ELSE
             MOVE "." TO TL-OBSERVED(WS-K:1)
         END-IF
     END-PERFORM
     MOVE WS-Y TO WS-ED
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-2§12 12.5 bedrock row y " FUNCTION TRIM(WS-ED) " x 0 .. 7" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

 SET-RING.
*>   a ring of one biome around the column (WS-X, WS-Z)
     COMPUTE WS-QX = FUNCTION INTEGER((WS-X - 2) / 4) - 1
     COMPUTE WS-QZ = FUNCTION INTEGER((WS-Z - 2) / 4) - 1
     MOVE WS-QX TO NH-RING-QX
     MOVE WS-QZ TO NH-RING-QZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-BIOME TO NH-RING(WS-I)
     END-PERFORM.

 RULE-AT.
*>   the rule at (WS-X, WS-Y, WS-Z) in biome WS-BIOME with the depths WS-SDA, WS-SDB, WS-SD
     PERFORM SET-RING
     CALL "NETHER-RULE" USING WS-X WS-Y WS-Z WS-SDA WS-SDB WS-SD WS-OUT.

 FIND-COLUMN.
*>   the first x from 0 (z 5) whose noise WS-WHICH2 is at least (WS-KIND2, WS-WANT2 = 1) or below (0) the threshold, and
*>   whose noise WS-N2 (0 = none) satisfies (WS-KIND, WS-WANT) as well
     MOVE 0 TO WS-FOUND
     MOVE 5 TO WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4000 OR WS-FOUND = 1
         CALL "NETHER-NOISE-GE" USING WS-WHICH2 WS-X WS-Z WS-KIND2 WS-G
         IF WS-G = WS-WANT2
             IF WS-N2 = 0
                 MOVE 1 TO WS-FOUND
             ELSE
                 CALL "NETHER-NOISE-GE" USING WS-N2 WS-X WS-Z WS-KIND WS-G
                 IF WS-G = WS-WANT
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     SUBTRACT 1 FROM WS-X.

 EXPECT-STATE.
     MOVE WS-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-RULES.
*>   the roof band and the edges (37-4 5.1 rules 1 to 3)
     MOVE 1 TO WS-BIOME
     MOVE 0 TO WS-X WS-Z
     MOVE 5 TO WS-SDA
     MOVE 5 TO WS-SDB
     MOVE 3 TO WS-SD
     MOVE 0 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 rule 1: y 0 is always bedrock" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 127 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 rule 2: y 127 is always bedrock" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 3 TO WS-X
     MOVE 9 TO WS-Z
     MOVE 124 TO WS-Y
     MOVE 4 TO WS-BIOME
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.3 (3, 124, 9) is netherrack from rule 3, in the warped forest too" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 0 TO WS-X WS-Z
     MOVE 125 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.3 (0, 125, 0) is bedrock (gradient false)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 1 TO WS-BIOME
     MOVE 125 TO WS-Y
     MOVE 8 TO WS-X
     MOVE 0 TO WS-Z
     MOVE 5 TO WS-SDA
     MOVE 5 TO WS-SDB
     MOVE 125 TO WS-Y
     MOVE 5 TO WS-SDA

*>   example 5: wastes, soul sand band in a column where soul_sand_layer >= -0.012
     MOVE 5 TO WS-WHICH2
     MOVE 1 TO WS-KIND2
     MOVE 1 TO WS-WANT2
     MOVE 0 TO WS-N2
     PERFORM FIND-COLUMN
     MOVE 1 TO WS-BIOME
     MOVE 3 TO WS-SD
     MOVE 20 TO WS-SDB
     MOVE 33 TO WS-Y
     MOVE 1 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.5 wastes soul sand: top block y 33, sda 1, sd 3: soul sand" TO TL-CASE
     MOVE 105 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 30 TO WS-Y
     MOVE 4 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.5 wastes soul sand: y 30, sda 4 (y + sda = 34): soul sand" TO TL-CASE
     MOVE 105 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 29 TO WS-Y
     MOVE 5 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.5 wastes soul sand: y 29, sda 5 is deeper than 1 + sd: netherrack" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 34 TO WS-Y
     MOVE 1 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.5 wastes soul sand: top block at y 34 (y + sda = 35): netherrack" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE

*>   example 6: wastes gravel where soul_sand_layer < -0.012 and gravel_layer >= -0.012
     MOVE 5 TO WS-WHICH2
     MOVE 1 TO WS-KIND2
     MOVE 0 TO WS-WANT2
     MOVE 6 TO WS-N2
     MOVE 1 TO WS-KIND
     MOVE 1 TO WS-WANT
     PERFORM FIND-COLUMN
     MOVE 1 TO WS-BIOME
     MOVE 3 TO WS-SD
     MOVE 33 TO WS-Y
     MOVE 1 TO WS-SDA
     MOVE 20 TO WS-SDB
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.6 wastes gravel: top block y 33, sd 3: gravel" TO TL-CASE
     MOVE 103 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 31 TO WS-Y
     MOVE 0 TO WS-SD
     PERFORM RULE-AT
*>   (example 6 of the document calls this block netherrack but looks at rule 7 only: the top block at y 31 with sd 0 is caught by rule 6a first)
     MOVE "acceptance US12 37-4§9 9.6 wastes y 31 with sd 0 (a hole): not gravel, lava by rule 6a" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 31 TO WS-Y
     MOVE 2 TO WS-SD
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 7b wastes y 31 with sd 2 (no hole): gravel" TO TL-CASE
     MOVE 103 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE

*>   lava of rule 6a, in any biome but the two with floor rules above it
     MOVE 1 TO WS-BIOME
     MOVE 20 TO WS-Y
     MOVE 1 TO WS-SDA
     MOVE 1 TO WS-SDB
     MOVE -1 TO WS-SD
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 6a: y 20, top block, a hole (sd -1) in the wastes: lava" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 5 TO WS-BIOME
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 5.1 6a: the same in basalt_deltas (sd < 0 skips 4b): lava" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE

*>   example 7: crimson forest, top block at y 30 with sd 0: lava; with sd 2: netherrack; at y 31 with sd 2: nylium or wart block
     MOVE 3 TO WS-BIOME
     MOVE 30 TO WS-Y
     MOVE 1 TO WS-SDA
     MOVE 30 TO WS-SDB
     MOVE 0 TO WS-SD
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.7 crimson forest y 30 sd 0: lava" TO TL-CASE
     MOVE 102 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 2 TO WS-SD
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.7 crimson forest y 30 sd 2: netherrack" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
*>   a column with netherrack noise below 0.54 and wart noise below 1.17: crimson nylium at y 31
     MOVE 3 TO WS-WHICH2
     MOVE 3 TO WS-KIND2
     MOVE 0 TO WS-WANT2
     MOVE 4 TO WS-N2
     MOVE 4 TO WS-KIND
     MOVE 0 TO WS-WANT
     PERFORM FIND-COLUMN
     MOVE 3 TO WS-BIOME
     MOVE 31 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.7 crimson forest y 31 sd 2 (wart < 1.17): crimson nylium" TO TL-CASE
     MOVE 110 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 4 TO WS-BIOME
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§5 6b warped forest y 31 sd 2 (wart < 1.17): warped nylium" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
*>   a column with netherrack noise below 0.54 and wart noise at least 1.17 (searched wider): wart block
     MOVE 3 TO WS-WHICH2
     MOVE 3 TO WS-KIND2
     MOVE 0 TO WS-WANT2
     MOVE 4 TO WS-N2
     MOVE 4 TO WS-KIND
     MOVE 1 TO WS-WANT
     PERFORM FIND-COLUMN
     IF WS-FOUND = 1
         MOVE 3 TO WS-BIOME
         PERFORM RULE-AT
         MOVE "acceptance US12 37-4§5 6c crimson forest with wart noise >= 1.17: nether wart block" TO TL-CASE
         MOVE 109 TO TL-EXPECTED-N
         PERFORM EXPECT-STATE
         MOVE 4 TO WS-BIOME
         PERFORM RULE-AT
         MOVE "acceptance US12 37-4§5 6b warped forest with wart noise >= 1.17: warped wart block" TO TL-CASE
         MOVE 107 TO TL-EXPECTED-N
         PERFORM EXPECT-STATE
     END-IF
*>   a column with netherrack noise >= 0.54: no nylium, netherrack
     MOVE 3 TO WS-WHICH2
     MOVE 3 TO WS-KIND2
     MOVE 1 TO WS-WANT2
     MOVE 0 TO WS-N2
     PERFORM FIND-COLUMN
     IF WS-FOUND = 1
         MOVE 3 TO WS-BIOME
         PERFORM RULE-AT
         MOVE "acceptance US12 37-4§5 6c netherrack noise >= 0.54 excludes the nylium: netherrack" TO TL-CASE
         MOVE 100 TO TL-EXPECTED-N
         PERFORM EXPECT-STATE
     END-IF

*>   example 8: a floating island of basalt deltas: bottom block y 80 (sdb 1) is basalt, top block y 90 floor
     MOVE 5 TO WS-BIOME
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Z
     MOVE 80 TO WS-Y
     MOVE 11 TO WS-SDA
     MOVE 1 TO WS-SDB
     MOVE 3 TO WS-SD
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.8 basalt deltas bottom of an island (sdb 1): basalt" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 90 TO WS-Y
     MOVE 1 TO WS-SDA
     MOVE 11 TO WS-SDB
     PERFORM RULE-AT
     CALL "NETHER-NOISE-GE" USING WS-N2-SEL WS-X WS-Z WS-KIND-SEL WS-G
     MOVE "acceptance US12 37-4§9 9.8 basalt deltas top block y 90: basalt or blackstone by the selector noise" TO TL-CASE
     IF WS-G = 1
         MOVE 101 TO TL-EXPECTED-N
     ELSE
         MOVE 104 TO TL-EXPECTED-N
     END-IF
     PERFORM EXPECT-STATE

*>   example 12: bottom of the world, basalt deltas sd 3: y 1 to 3 (sdb 2 to 4) basalt without a noise test, y 4 (sdb 5) netherrack
     MOVE 1 TO WS-W
     MOVE 5 TO WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 400
         MOVE 1 TO WS-Y
         CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
         IF WS-G = 0
             MOVE 400 TO WS-K
             MOVE 2 TO WS-Y
             CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
             IF WS-G = 0
                 MOVE 3 TO WS-Y
                 CALL "NETHER-GRADIENT-AT" USING WS-W WS-X WS-Y WS-Z WS-G
                 IF WS-G = 0
                     MOVE WS-X TO WS-K
                     MOVE 401 TO WS-X
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-K TO WS-X
     MOVE 5 TO WS-BIOME
     MOVE 3 TO WS-SD
     MOVE 59 TO WS-SDA
     MOVE 2 TO WS-SDB
     MOVE 1 TO WS-Y
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.12 bottom of the world, basalt deltas: y 1 (sdb 2) basalt" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 3 TO WS-Y
     MOVE 4 TO WS-SDB
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.12 bottom of the world, basalt deltas: y 3 (sdb 4) basalt" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 4 TO WS-Y
     MOVE 5 TO WS-SDB
     MOVE 56 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.12 bottom of the world, basalt deltas: y 4 (sdb 5) netherrack" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 1 TO WS-BIOME
     MOVE 3 TO WS-Y
     MOVE 4 TO WS-SDB
     MOVE 56 TO WS-SDA
     PERFORM RULE-AT
     MOVE "acceptance US12 37-4§9 9.12 bottom of the world, nether_wastes: y 3 stays netherrack" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     PERFORM EXPECT-STATE
     MOVE 2 TO WS-BIOME
     MOVE 3 TO WS-Y
     PERFORM RULE-AT
     CALL "NETHER-NOISE-GE" USING WS-N2-SEL WS-X WS-Z WS-KIND-SEL WS-G
     MOVE "acceptance US12 37-4§9 9.12 bottom of the world, soul_sand_valley: y 3 soul sand or soul soil" TO TL-CASE
     IF WS-G = 1
         MOVE 105 TO TL-EXPECTED-N
     ELSE
         MOVE 106 TO TL-EXPECTED-N
     END-IF
     PERFORM EXPECT-STATE.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-37-4-4.
