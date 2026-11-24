*> Section test of 36-structures-6-ocean.md section 6.3 (ocean ruin vectors, the per-block parts): the per-block streams of the rot processor and the archaeology rule, and the
*> capped processor's shuffle, with the numbers the document prints (getSeed, the first nextFloat and nextLong of the per-position streams, F of world seed 12345, the shuffled
*> index list 0, 4, 2, 1, 5, 6, 3, 7), run through the production programs (STRUCT-POS-RANDOM, STRUCT-PROC-BLOCK of the loaded ruin list, STRUCT-PROC-FINAL). The start vectors of 6.3
*> (chunk (0,0), chunk (4,1), the corner table) are in test_struct_36_6_3. Skipped as a pass without the generated vanilla-data (CC_GENERATED_DIR, read only).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPROC.
 COPY STRUCTPLACE.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 COPY STRUCTSET.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-LIST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-GRAVEL              BINARY-LONG.
 01 WS-PROPS               PIC X(600).
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-U                   FLOAT-LONG.
 01 WS-SCALED              BINARY-LONG.
 01 WS-SEED-OUT            BINARY-DOUBLE.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-WANT-U              PIC 9(20).
 01 WS-GOT-U               PIC 9(20).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-CHANGED             PIC X(8).
 01 WS-DEC                 PIC 9.
 01 WS-WANT-CHANGED        PIC X(8) VALUE "11101100".
 01 WS-SUSP                BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
*> the per-block float cases of 6.3: x, y, z, the six digit float
 01 WS-FLOATS.
    05 FILLER PIC X(30) VALUE "+000070+000050+000020+00792293".
    05 FILLER PIC X(30) VALUE "+000000+000000+000000+00730968".
    05 FILLER PIC X(30) VALUE "+000001+000002+000003+00795369".
    05 FILLER PIC X(30) VALUE "-000005+000040+000017+00607119".
 01 WS-FLOAT-T REDEFINES WS-FLOATS.
    05 WS-FC OCCURS 4 TIMES.
       10 FC-X             PIC S9(6) SIGN LEADING SEPARATE.
       10 FC-Y             PIC S9(6) SIGN LEADING SEPARATE.
       10 FC-Z             PIC S9(6) SIGN LEADING SEPARATE.
       10 FC-F             PIC S9(8) SIGN LEADING SEPARATE.
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
         MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: no generated packs here, skipped" TO TL-CASE
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
     PERFORM SEED-CASES
     PERFORM FLOAT-CASES
     PERFORM ROT-CASES
     PERFORM LOOT-CASES
     PERFORM CAPPED-CASE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 2.1 and 6.3: getSeed(1, 2, 3) = -33674130277896, getSeed(70, 50, 20) = 28171223183139, getSeed(0, 0, 0) = 0
 SEED-CASES.
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "XORO-GET-SEED" USING WS-X WS-Y WS-Z WS-SEED-OUT
     MOVE "acceptance US12 36-6§2.1 Ruin streams: getSeed(1,2,3) is -33674130277896" TO TL-CASE
     MOVE -33674130277896 TO TL-EXPECTED-N
     MOVE WS-SEED-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 70 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 20 TO WS-Z
     CALL "XORO-GET-SEED" USING WS-X WS-Y WS-Z WS-SEED-OUT
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: getSeed(70,50,20) is 28171223183139" TO TL-CASE
     MOVE 28171223183139 TO TL-EXPECTED-N
     MOVE WS-SEED-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X WS-Y WS-Z
     CALL "XORO-GET-SEED" USING WS-X WS-Y WS-Z WS-SEED-OUT
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: getSeed(0,0,0) is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SEED-OUT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 6.3: the first nextFloat of LCG(getSeed(pos)) at four positions, to six digits
 FLOAT-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE FC-X(WS-I) TO WS-X
         MOVE FC-Y(WS-I) TO WS-Y
         MOVE FC-Z(WS-I) TO WS-Z
         CALL "STRUCT-POS-RANDOM" USING WS-X WS-Y WS-Z WS-RNG
         CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
         COMPUTE WS-SCALED ROUNDED = WS-U * 1000000
         MOVE WS-I TO WS-DEC
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-6§6.3 Ocean ruin vectors: the per-block float of position case " WS-DEC " is the document's" DELIMITED BY SIZE INTO TL-CASE
         MOVE FC-F(WS-I) TO TL-EXPECTED-N
         MOVE WS-SCALED TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

*> sets WS-KEEP for the rot processor (the first of the list WS-KEY) at the block position WS-X WS-Y WS-Z
 ROT-KEEP.
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     INITIALIZE STRUCT-SETTINGS
     MOVE WS-X TO CU-X PP-X
     MOVE WS-Y TO CU-Y PP-Y
     MOVE WS-Z TO CU-Z PP-Z
     MOVE WS-SAND TO CU-STATE
     MOVE 0 TO CU-NBT CU-LOOT CU-SEED
     CALL "STRUCT-PROC-BLOCK" USING SPL-FIRST(WS-LIST) STRUCT-PPOS STRUCT-CUR WS-KEEP STRUCT-SETTINGS.

*> 6.3 per-block rot: the block at (70,50,20) with float 0.792293 is kept at integrity 0.8 and 0.9 and removed at 0.7 and 0.5; (0,0,0) 0.730968 kept at 0.8, removed at 0.7;
*> (-5,40,17) 0.607119 kept at 0.7, removed at 0.5
 ROT-CASES.
     MOVE "sand" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-PROPS
     CALL "STRUCT-TPL-STATE" USING WS-BLOCK-KEY WS-PROPS WS-SAND
     MOVE 70 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 20 TO WS-Z
     MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (70,50,20) float 0.792293 is kept at integrity 0.8" TO TL-CASE
     MOVE WS-KEEP TO WS-FLAG
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/w/9" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (70,50,20) is kept at integrity 0.9" TO TL-CASE
     MOVE WS-KEEP TO WS-FLAG
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/w/7" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (70,50,20) is removed at integrity 0.7" TO TL-CASE
     COMPUTE WS-FLAG = 1 - WS-KEEP
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/w/5" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (70,50,20) is removed at integrity 0.5" TO TL-CASE
     COMPUTE WS-FLAG = 1 - WS-KEEP
     PERFORM CHECK
     MOVE 0 TO WS-X WS-Y WS-Z
     MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (0,0,0) float 0.730968 is kept at integrity 0.8" TO TL-CASE
     MOVE WS-KEEP TO WS-FLAG
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/w/7" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (0,0,0) is removed at integrity 0.7" TO TL-CASE
     COMPUTE WS-FLAG = 1 - WS-KEEP
     PERFORM CHECK
     MOVE -5 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 17 TO WS-Z
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (-5,40,17) float 0.607119 is kept at integrity 0.7" TO TL-CASE
     MOVE WS-KEEP TO WS-FLAG
     PERFORM CHECK
     MOVE "cobolcraft:inline/ruin/w/5" TO WS-KEY
     PERFORM ROT-KEEP
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: (-5,40,17) is removed at integrity 0.5" TO TL-CASE
     COMPUTE WS-FLAG = 1 - WS-KEEP
     PERFORM CHECK.

*> 6.3: the LootTableSeed of a block that becomes suspicious at (70,50,20) is the first nextLong of LCG(getSeed(70,50,20)) = -3831520032679271255 (as the unsigned word 2^64 - that)
*> and F, the first nextLong of LCG(12345), is 6674089274190705457
 LOOT-CASES.
     MOVE 70 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 20 TO WS-Z
     CALL "STRUCT-POS-RANDOM" USING WS-X WS-Y WS-Z WS-RNG
     CALL "JRAND-NEXT-LONG" USING WS-RNG WS-LONG
     MOVE WS-LONG TO WS-GOT-U
     COMPUTE WS-WANT-U = WS-M64 - 3831520032679271255
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the loot seed of a suspicious block at (70,50,20) is -3831520032679271255" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-GOT-U = WS-WANT-U
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 12345 TO WS-LONG
     CALL "JRAND-SET-SEED" USING WS-RNG WS-LONG
     CALL "JRAND-NEXT-LONG" USING WS-RNG WS-LONG
     MOVE WS-LONG TO WS-GOT-U
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: F, the first nextLong of the stream of world seed 12345, is 6674089274190705457" TO TL-CASE
     MOVE 6674089274190705457 TO WS-WANT-U
     MOVE 0 TO WS-FLAG
     IF WS-GOT-U = WS-WANT-U
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> 6.3 capped shuffle: world seed 12345, template position (64,50,16), eight sand blocks: the shuffled order of the index list 0..7 is 0, 4, 2, 1, 5, 6, 3, 7, and the limit is 5, so
*> the blocks 0, 4, 2, 1, 5 become suspicious sand and 6, 3, 7 stay sand
 CAPPED-CASE.
     MOVE "suspicious_sand" TO WS-BLOCK-KEY
     MOVE SPACES TO WS-PROPS
     CALL "STRUCT-TPL-STATE" USING WS-BLOCK-KEY WS-PROPS WS-SUSP
     MOVE "cobolcraft:inline/ruin/w/8" TO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     MOVE 8 TO PW-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE PW-X(WS-I) = 64 + WS-I
         MOVE 50 TO PW-Y(WS-I)
         MOVE 16 TO PW-Z(WS-I)
         MOVE WS-SAND TO PW-STATE(WS-I)
         MOVE WS-SAND TO PW-TSTATE(WS-I)
         MOVE WS-I TO PW-LX(WS-I)
         MOVE 0 TO PW-LY(WS-I) PW-LZ(WS-I)
         MOVE 0 TO PW-NBT(WS-I) PW-LOOT(WS-I) PW-SEED(WS-I)
     END-PERFORM
     INITIALIZE STRUCT-SETTINGS
     MOVE 12345 TO PS-SEED
     COMPUTE WS-I = SPL-FIRST(WS-LIST) + 2
     MOVE 64 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 16 TO WS-Z
     MOVE 64 TO WS-AX
     MOVE 50 TO WS-AY
     MOVE 16 TO WS-AZ
     CALL "STRUCT-PROC-FINAL" USING WS-I WS-X WS-Y WS-Z WS-AX WS-AY WS-AZ STRUCT-SETTINGS
     MOVE SPACES TO WS-CHANGED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         IF PW-STATE(WS-I) = WS-SUSP
             MOVE "1" TO WS-CHANGED(WS-I:1)
         ELSE
             MOVE "0" TO WS-CHANGED(WS-I:1)
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§6.3 Ocean ruin vectors: the shuffled order 0,4,2,1,5,6,3,7 turns blocks 0,4,2,1,5 into suspicious sand" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-CHANGED = WS-WANT-CHANGED
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-36-6-6-3.

 COPY NOSPAWN.
 COPY CORETEST.
