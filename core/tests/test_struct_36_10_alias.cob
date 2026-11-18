*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md sections 2.1, 2.2, 2.6, 4.2, 8.1 and 8.3): Mth.getSeed (values from an
*> independent evaluation of the formula), the pool alias lookup of the trial chambers (F = LegacyRandom(seed).nextLong() = -4962768465676381896 for seed 0, the generator LegacyRandom(getSeed(origin) XOR F), the draws
*> nextInt(3), nextInt(3), nextInt(4) in binding order: the document's example of 8.3 and six more seeds and origins from the independent model) and the identity lookup without bindings, then the start of the ancient
*> city through JIG-FIND-POINT with a synthetic terrain (core/tests/JIGSEAM.cpy: no biome test, a start height that is absolute): a chunk whose start is city_center_1 at rotation NONE has the box, centre and stub
*> of 8.1 (the jigsaw city_anchor at local (13, 24, 20) lands on the origin (16 cx, -27, 16 cz): piece box (x0 - 13, -52, z0 - 20) to (x0 + 4, -22, z0 + 20) with x0 = 16 cx, z0 = 16 cz). A trial chambers start
*> draws its height uniformly from -40 to -20 (the stub's y) and builds a structure whose spawner pieces come from the aliased pools.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-10-ALIAS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTALIAS.
 COPY STRUCTALIASMAP.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY JIGTEST.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ANCIENT             BINARY-LONG.
 01 WS-TRIAL               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MTH                 BINARY-DOUBLE.
 01 WS-KEY                 PIC X(80).
 01 WS-OUT                 PIC X(80).
 01 WS-WANT-TXT            PIC X(400).
 01 WS-GOT-TXT             PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-F                   BINARY-DOUBLE UNSIGNED.
 01 WS-FS                  BINARY-DOUBLE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-LRAND               BINARY-DOUBLE UNSIGNED.
 01 WS-TRIES               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-LOC                 PIC X(96).
 01 WS-MOBS.
    05 WS-GROUP-MOB        PIC X(16) OCCURS 3 TIMES.
 01 WS-MOB-DATA.
    05 FILLER PIC X(16) VALUE "skeleton".
    05 FILLER PIC X(16) VALUE "stray".
    05 FILLER PIC X(16) VALUE "poison_skeleton".
 01 WS-MOB-TAB REDEFINES WS-MOB-DATA.
    05 WS-RANGED           PIC X(16) OCCURS 3 TIMES.
 01 WS-MELEE-DATA.
    05 FILLER PIC X(16) VALUE "zombie".
    05 FILLER PIC X(16) VALUE "husk".
    05 FILLER PIC X(16) VALUE "spider".
 01 WS-MELEE-TAB REDEFINES WS-MELEE-DATA.
    05 WS-MELEE            PIC X(16) OCCURS 3 TIMES.
 01 WS-SMALL-DATA.
    05 FILLER PIC X(16) VALUE "slime".
    05 FILLER PIC X(16) VALUE "cave_spider".
    05 FILLER PIC X(16) VALUE "silverfish".
    05 FILLER PIC X(16) VALUE "baby_zombie".
 01 WS-SMALL-TAB REDEFINES WS-SMALL-DATA.
    05 WS-SMALL            PIC X(16) OCCURS 4 TIMES.
*> seed, origin x, y, z, the three draws of the independent model
 01 WS-CASES-DATA.
    05 FILLER PIC X(48) VALUE "+0000000000000 +000000 -000030 +000000 0 0 1".
    05 FILLER PIC X(48) VALUE "+0000000012345 +000160 -000035 -000112 2 2 1".
    05 FILLER PIC X(48) VALUE "-0000000000077 -000048 -000022 +000080 2 1 1".
    05 FILLER PIC X(48) VALUE "+0000987654321 +001600 -000040 -001600 2 1 1".
    05 FILLER PIC X(48) VALUE "+0000000000000 +000016 -000031 +000032 2 2 1".
    05 FILLER PIC X(48) VALUE "+0000000424242 -001024 -000020 +002048 1 1 3".
    05 FILLER PIC X(48) VALUE "+0000000000001 +000000 -000030 +000000 1 1 3".
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-CASE OCCURS 7 TIMES.
       10 WC-SEED          PIC S9(13) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WC-X             PIC S9(6) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WC-Y             PIC S9(6) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WC-Z             PIC S9(6) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WC-A             PIC 9.
       10 FILLER           PIC X.
       10 WC-B             PIC 9.
       10 FILLER           PIC X.
       10 WC-C             PIC 9.
       10 FILLER           PIC X(4).
 01 WS-WANTX              BINARY-LONG.
 01 WS-WANTZ              BINARY-LONG.
 01 WS-KD                 PIC 9.
 01 WS-PRE                 PIC X(40) VALUE "minecraft:trial_chambers/spawner/".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-10§2.6 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     MOVE 0 TO WS-ANCIENT WS-TRIAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:ancient_city"
             MOVE WS-I TO WS-ANCIENT
         END-IF
         IF SDT-KEY(WS-I) = "minecraft:trial_chambers"
             MOVE WS-I TO WS-TRIAL
         END-IF
     END-PERFORM
     CALL "JIG-RESET"

*>   Mth.getSeed: l = (int)(x * 3129871) ^ (z * 116129781L) ^ y, (l * l * 42317861L + l * 11L) >> 16
     MOVE 0 TO WS-X WS-Z
     MOVE -30 TO WS-Y
     CALL "STRUCT-MTH-SEED" USING WS-X WS-Y WS-Z WS-MTH
     MOVE "acceptance US12 36-10§2.6 Mth.getSeed(0, -30, 0) is 581147 (the document's example)" TO TL-CASE
     MOVE 581147 TO TL-EXPECTED-N
     MOVE WS-MTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 160 TO WS-X
     MOVE -27 TO WS-Y
     MOVE -112 TO WS-Z
     CALL "STRUCT-MTH-SEED" USING WS-X WS-Y WS-Z WS-MTH
     MOVE "acceptance US12 36-10§2.6 Mth.getSeed(160, -27, -112) is 81854124156105" TO TL-CASE
     MOVE 81854124156105 TO TL-EXPECTED-N
     MOVE WS-MTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "STRUCT-MTH-SEED" USING WS-X WS-Y WS-Z WS-MTH
     MOVE "acceptance US12 36-10§2.6 Mth.getSeed(1, 2, 3) is -33674130277896" TO TL-CASE
     MOVE -33674130277896 TO TL-EXPECTED-N
     MOVE WS-MTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 9 TO WS-Z
     CALL "STRUCT-MTH-SEED" USING WS-X WS-Y WS-Z WS-MTH
     MOVE "acceptance US12 36-10§2.6 Mth.getSeed(-5, 70, 9) is -135257194846019" TO TL-CASE
     MOVE -135257194846019 TO TL-EXPECTED-N
     MOVE WS-MTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   F = LegacyRandom(0).nextLong()
     MOVE 0 TO WS-USEED
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-F
     COMPUTE WS-FS = FUNCTION MOD(WS-F + 0, WS-M64) - WS-M64
     MOVE "acceptance US12 36-10§8.3 F = LegacyRandom(0).nextLong() is -4962768465676381896" TO TL-CASE
     MOVE -4962768465676381896 TO TL-EXPECTED-N
     MOVE WS-FS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the alias lookups of the trial chambers against the independent model
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
         MOVE WC-SEED(WS-K) TO WS-SEED
         MOVE WC-X(WS-K) TO WS-X
         MOVE WC-Y(WS-K) TO WS-Y
         MOVE WC-Z(WS-K) TO WS-Z
         CALL "JIG-ALIAS-BUILD" USING WS-TRIAL WS-X WS-Y WS-Z WS-SEED JIG-ALIAS-MAP
         MOVE SPACES TO WS-WANT-TXT WS-GOT-TXT
         MOVE 1 TO WS-PTR
         COMPUTE WS-I = WC-A(WS-K) + 1
         STRING FUNCTION TRIM(WS-PRE) "ranged/" FUNCTION TRIM(WS-RANGED(WS-I)) " "
             FUNCTION TRIM(WS-PRE) "slow_ranged/" FUNCTION TRIM(WS-RANGED(WS-I)) " " DELIMITED BY SIZE INTO WS-WANT-TXT WITH POINTER WS-PTR
         COMPUTE WS-I = WC-B(WS-K) + 1
         STRING FUNCTION TRIM(WS-PRE) "melee/" FUNCTION TRIM(WS-MELEE(WS-I)) " " DELIMITED BY SIZE INTO WS-WANT-TXT WITH POINTER WS-PTR
         COMPUTE WS-I = WC-C(WS-K) + 1
         STRING FUNCTION TRIM(WS-PRE) "small_melee/" FUNCTION TRIM(WS-SMALL(WS-I)) DELIMITED BY SIZE INTO WS-WANT-TXT WITH POINTER WS-PTR
         MOVE 1 TO WS-PTR
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WS-PRE) "contents/ranged" DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-KEY WS-OUT
         STRING FUNCTION TRIM(WS-OUT) " " DELIMITED BY SIZE INTO WS-GOT-TXT WITH POINTER WS-PTR
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WS-PRE) "contents/slow_ranged" DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-KEY WS-OUT
         STRING FUNCTION TRIM(WS-OUT) " " DELIMITED BY SIZE INTO WS-GOT-TXT WITH POINTER WS-PTR
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WS-PRE) "contents/melee" DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-KEY WS-OUT
         STRING FUNCTION TRIM(WS-OUT) " " DELIMITED BY SIZE INTO WS-GOT-TXT WITH POINTER WS-PTR
         MOVE SPACES TO WS-KEY
         STRING FUNCTION TRIM(WS-PRE) "contents/small_melee" DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-KEY WS-OUT
         STRING FUNCTION TRIM(WS-OUT) DELIMITED BY SIZE INTO WS-GOT-TXT WITH POINTER WS-PTR
         MOVE WS-K TO WS-KD
         MOVE "A" TO TL-MODE
         MOVE WS-WANT-TXT TO TL-EXPECTED
         MOVE WS-GOT-TXT TO TL-OBSERVED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-10§8.3 trial chambers aliases for case " WS-KD " (model draws " WC-A(WS-K) WC-B(WS-K) WC-C(WS-K)
             "): ranged, slow_ranged, melee, small_melee" DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     END-PERFORM
     MOVE "acceptance US12 36-10§2.6 an alias map has the four keys of the trial chambers (the 3 + 1 bindings of 4.2)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE JA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:trial_chambers/chamber/end" TO WS-KEY
     CALL "JIG-ALIAS-LOOKUP" USING JIG-ALIAS-MAP WS-KEY WS-OUT
     MOVE "acceptance US12 36-10§2.6 a key that no binding names (the start pool) is its own lookup result" TO TL-CASE
     MOVE "A" TO TL-MODE
     MOVE WS-KEY TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-X WS-Z
     MOVE -27 TO WS-Y
     CALL "JIG-ALIAS-BUILD" USING WS-ANCIENT WS-X WS-Y WS-Z WS-SEED JIG-ALIAS-MAP
     MOVE "acceptance US12 36-10§2.6 a structure without bindings (the ancient city) has the identity lookup: no entry" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE JA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   8.1: the ancient city start (synthetic terrain, no biome test): a chunk whose first draw is rotation NONE and whose element is city_center_1
     MOVE 1 TO TJ-SURFACE
     MOVE 12345 TO WS-SEED
     MOVE 0 TO WS-FOUND WS-TRIES
     MOVE -7 TO WS-CZ
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 120 OR WS-FOUND = 1
         COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
         CALL "JRAND-LARGE-FEATURE-SEED" USING WS-LRAND WS-USEED WS-CX WS-CZ
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-LRAND WS-BOUND WS-ROT
         IF WS-ROT = 0
             ADD 1 TO WS-TRIES
             CALL "JIG-FIND-POINT" USING WS-ANCIENT WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
             IF WS-VALID = 1
                 MOVE JE-LOC(SP-F1(1)) TO WS-LOC
                 MOVE 0 TO WS-HIT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
                     IF WS-LOC(WS-I:13) = "city_center_1"
                         MOVE 1 TO WS-HIT
                     END-IF
                 END-PERFORM
                 IF WS-HIT = 1
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     SUBTRACT 1 FROM WS-CX
     MOVE "acceptance US12 36-10§8.1 a chunk with rotation NONE and the start element city_center_1 exists among the first chunks (searched with the document's draws)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 1
         COMPUTE WS-X0 = WS-CX * 16
         COMPUTE WS-Z0 = WS-CZ * 16
         MOVE "acceptance US12 36-10§8.1 ancient city start piece box: (x0 - 13, -52, z0 - 20) to (x0 + 4, -22, z0 + 20) for the 18 x 31 x 41 city_center_1 after the shift of 2.2 step 12" TO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF SP-X0(1) = WS-X0 - 13 AND SP-Y0(1) = -52 AND SP-Z0(1) = WS-Z0 - 20 AND SP-X1(1) = WS-X0 + 4 AND SP-Y1(1) = -22
                 AND SP-Z1(1) = WS-Z0 + 20
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US12 36-10§8.1 the stub is the centre of that box at y -27 (the origin's y: ySurf + offset.y = -51 + 24)" TO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         COMPUTE WS-WANTX = (WS-X0 - 13 + WS-X0 + 4) / 2
         COMPUTE WS-WANTZ = (WS-Z0 - 20 + WS-Z0 + 20) / 2
         IF WS-X = WS-WANTX AND WS-Y = -27 AND WS-Z = WS-WANTZ
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "acceptance US12 36-10§2.2 step 9 the start piece has the ground level delta 1 and more pieces follow it (size 7)" TO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF SP-F2(1) = 1 AND SP-COUNT > 5
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF

*>   4.1: a trial chambers start: the height is one nextInt(21) draw from -40, so the stub's y is in -40 .. -20
     MOVE 0 TO WS-FOUND
     MOVE 0 TO WS-K
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 7
         MOVE -3 TO WS-CZ
         CALL "JIG-FIND-POINT" USING WS-TRIAL WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID = 1
             ADD 1 TO WS-FOUND
             IF WS-Y < -40 OR WS-Y > -20
                 ADD 1 TO WS-K
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-10§4.1 trial chambers starts of 8 chunks: valid starts exist and each stub's y is within -40 .. -20 (the uniform start height)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0 AND WS-K = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-10-ALIAS.

 COPY JIGSEAM.
 COPY NOSPAWN.
 COPY CORETEST.
