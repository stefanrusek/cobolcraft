*> The generic ore feature (type 31, docs/protocol/11 section 7) and scattered_ore (type 39, docs/protocol/35-worldgen-features-1 section 13) as features of the feature stage (T1292, T1293):
*> the Nether's ore placed features (ore_magma, ore_gravel_nether, ore_blackstone, ore_soul_sand, ore_nether_gold, ore_quartz and the two ancient debris ones, docs/protocol/37-nether-5 section 6)
*> run through the placement runtime like any other leaf. The overworld ores stay with the hard-coded pass of ores.cob (the stage's family gate FR-GATE keeps their placed features off).
*> Both types share the record of 13.1: targets (the pairs of FD-REPLACE-NODE: a rule test of the processors' family and the state it writes), size 0..64 and the discard chance on air exposure.
*> The row of a feature: FT-A the first pair of FD-POOL, FT-B the pairs, FT-C the size, FT-E the air test mode (0 chance <= 0: no test and no draw; 1 chance >= 1: not adjacent to air, no draw;
*> 2 otherwise: one nextFloat per accepted rule), FT-F the chance.
*> Deviations (the level's: feat-level.cob): blocks outside the chunk's columns read as air for the rule (so nothing is written there; what a blob reaches beyond the border is lost) and count as
*> not air for the air exposure test (as ores.cob's); the heightmap column scan of 11 section 7.1 step 5 is not made (every column of a Nether chunk holds the bedrock roof, so the blob's start y,
*> at most 117 + 2 + rr, never exceeds the height of any column: the scan always accepts the first column); at most 4000 positions of a blob are kept (OB-POS: the blob of size 64 is below it).
*>
*> Entry points:
*>   FD-ORE-NODE USING doc, node, first out, count out, size out, mode out, chance out (FLOAT-LONG): compiles an ore or scattered_ore object; FD-BAD (the caller makes the feature unsupported)
*>     for a missing or non-list targets, an entry the pairs' compiler refuses, a missing size or chance, a size outside 0..64 or a chance outside 0.0..1.0
*>   FR-ORE-AIR USING x, y, z, flag out: 1 when a face neighbour inside the chunk's columns is air (any air block, void air above or below the build height)
*>   FR-ORE-TRY USING random state, feature, x, y, z, placed out: the acceptance test of 11 section 7.3 at one position, the targets in list order; the first that accepts writes (flags 2)
*>   FR-ORE-BLOB USING random state, size, x, y, z: the positions of a blob of the geometry of 11 sections 7.1 and 7.2 (the overworld pass's, in list mode) in OB-NPOS, OB-POS-X/Y/Z; the
*>     geometry draws are made from the state (the angle, two nextInt(3) and one nextDouble per ball)
*>   FR-ORE USING random state, feature, x, y, z, result out: OreFeature.place (11 section 7); true when at least one block was placed
*>   FR-SCATTERED-ORE USING random state, feature, x, y, z, result out: ScatteredOreFeature.place (35-1 section 13.2); always true

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ORE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 K-SIZE                 PIC X(40) VALUE "size".
 01 K-CHANCE               PIC X(40) VALUE "discard_chance_on_air_exposure".
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-DIFF                FLOAT-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-CHANCE               FLOAT-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-FIRST L-COUNT L-SIZE L-MODE L-CHANCE.
     MOVE 0 TO L-SIZE L-MODE
     CALL "FD-REPLACE-NODE" USING JSON-DOC L-NODE L-FIRST L-COUNT
     IF FD-BAD = 1
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-SIZE WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N L-SIZE WS-OK
     IF WS-OK = 0 OR L-SIZE < 0 OR L-SIZE > 64
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-CHANCE WS-N
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-N L-CHANCE WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
*>   the range 0.0 to 1.0 and the mode, from exact differences (a FLOAT-LONG comparison with a literal is fuzzy)
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-CHANCE WS-ONE WS-DIFF
     IF WS-DIFF > 0 OR L-CHANCE < 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN WS-DIFF = 0
             MOVE 1 TO L-MODE
         WHEN L-CHANCE = 0
             MOVE 0 TO L-MODE
         WHEN OTHER
             MOVE 2 TO L-MODE
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-ORE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ORE-AIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 01 WS-N                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 6 OR L-FLAG = 1
         MOVE L-X TO WS-NX
         MOVE L-Y TO WS-NY
         MOVE L-Z TO WS-NZ
         EVALUATE WS-N
             WHEN 1
                 SUBTRACT 1 FROM WS-NX
             WHEN 2
                 ADD 1 TO WS-NX
             WHEN 3
                 SUBTRACT 1 FROM WS-NY
             WHEN 4
                 ADD 1 TO WS-NY
             WHEN 5
                 SUBTRACT 1 FROM WS-NZ
             WHEN OTHER
                 ADD 1 TO WS-NZ
         END-EVALUATE
         COMPUTE WS-LX = WS-NX - FL-CX * 16
         COMPUTE WS-LZ = WS-NZ - FL-CZ * 16
         IF WS-LX >= 0 AND WS-LX <= 15 AND WS-LZ >= 0 AND WS-LZ <= 15
             CALL "FL-GET-STATE" USING WS-NX WS-NY WS-NZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-CLASS = 1
                 MOVE 1 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-ORE-AIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ORE-TRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-PLACED.
     MOVE 0 TO L-PLACED WS-DONE
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-CUR
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= FT-B(L-FT) OR WS-DONE = 1
         COMPUTE WS-AT = FT-A(L-FT) + WS-I * 2
         MOVE FD-POOL(WS-AT) TO WS-TEST
         COMPUTE WS-AT = WS-AT + 1
         MOVE FD-POOL(WS-AT) TO WS-NEW
         CALL "FEAT-RULE-TEST" USING WS-TEST WS-CUR L-Y L-STATE WS-HIT
         IF WS-HIT = 1
*>           7.3 (b): the air exposure test only for a block the rule accepted
             MOVE 1 TO WS-PASS
             IF FT-E(L-FT) > 0
                 CALL "FR-ORE-AIR" USING L-X L-Y L-Z WS-EXPOSED
                 IF FT-E(L-FT) = 1
                     IF WS-EXPOSED = 1
                         MOVE 0 TO WS-PASS
                     END-IF
                 ELSE
                     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-U
                     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U FT-F(L-FT) WS-D
                     IF WS-D < 0 AND WS-EXPOSED = 1
                         MOVE 0 TO WS-PASS
                     END-IF
                 END-IF
             END-IF
             IF WS-PASS = 1
                 CALL "FL-SET-STATE" USING L-X L-Y L-Z WS-NEW WS-FLAGS WS-OK
                 MOVE 1 TO L-PLACED WS-DONE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-ORE-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ORE-BLOB.
*> The overworld pass's blob geometry and ball fill in list mode (OB-LIST 1, ores.cob ORE-PLACE-BLOB) over a job of its own that has no chunk: its first column is made to lie outside any chunk
*> (the heightmap column test of ORE-PLACE-BLOB is then skipped), and the last row of the ore table (OT-SIZE) carries the size for the call and is restored after it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ORE.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==WJ-==.
 01 WS-ROW                 BINARY-LONG VALUE 30.
 01 WS-SAVED               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SIZE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SIZE L-X L-Y L-Z.
     MOVE OT-SIZE(WS-ROW) TO WS-SAVED
     MOVE L-SIZE TO OT-SIZE(WS-ROW)
     MOVE 100000000 TO WJ-CX
     MOVE 1 TO OB-LIST
     MOVE 0 TO OB-NPOS
     CALL "ORE-PLACE-BLOB" USING WS-JOB L-STATE WS-ROW L-X L-Y L-Z
     MOVE 0 TO OB-LIST
     MOVE WS-SAVED TO OT-SIZE(WS-ROW)
     GOBACK.
 END PROGRAM FR-ORE-BLOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-HERE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 COPY ORE.
 COPY FEATDATA.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT WS-COUNT
     CALL "FR-ORE-BLOB" USING L-STATE FT-C(L-FT) L-X L-Y L-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OB-NPOS
         CALL "FR-ORE-TRY" USING L-STATE L-FT OB-POS-X(WS-I) OB-POS-Y(WS-I) OB-POS-Z(WS-I) WS-HERE
         ADD WS-HERE TO WS-COUNT
     END-PERFORM
     IF WS-COUNT > 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FR-ORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SCATTERED-ORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-BOUND               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-OFFSET              BINARY-LONG OCCURS 3 TIMES.
 01 WS-HERE                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     COMPUTE WS-BOUND = FT-C(L-FT) + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         MOVE WS-I TO WS-SPREAD
         IF WS-SPREAD > 7
             MOVE 7 TO WS-SPREAD
         END-IF
         MOVE WS-SPREAD TO WS-S
*>       13.2 item 2.1: the six floats in the order a1 a2 b1 b2 c1 c2; each axis offset is round((first - second) * spread), single precision, Math.round(float)
         PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-A
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-B
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-A WS-B WS-D
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D WS-A
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-S WS-P
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-D
             CALL STATIC "cc_f64_round_f32" USING BY REFERENCE WS-D WS-OFFSET(WS-AXIS)
         END-PERFORM
         COMPUTE WS-PX = L-X + WS-OFFSET(1)
         COMPUTE WS-PY = L-Y + WS-OFFSET(2)
         COMPUTE WS-PZ = L-Z + WS-OFFSET(3)
         CALL "FR-ORE-TRY" USING L-STATE L-FT WS-PX WS-PY WS-PZ WS-HERE
     END-PERFORM
     GOBACK.
 END PROGRAM FR-SCATTERED-ORE.
