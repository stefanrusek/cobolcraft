*> Section test of 36-structures-6-ocean.md section 3.5 (the ocean ruin piece: processors in order, 2.4) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without it):
*> every processor list of a piece (warm and cold, integrity 0.5 to 0.9) holds, in this order, (1) rot(integrity), (2) block_ignore of air and structure_block, (3) the archaeology rule inside capped
*> with the constant limit 5: sand to suspicious sand with append_loot archaeology/ocean_ruin_warm (warm), gravel to suspicious gravel with archaeology/ocean_ruin_cold (cold). The height of the piece
*> and the data markers are in test_struct_ruin (the adapted height over the base heights) and test_struct_36_6_6_5 (the marker effects of 6.5). Written from the document alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPROC.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-LIST                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-DELEGATE            BINARY-LONG.
 01 WS-TENTHS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT-STATE          BINARY-LONG.
 01 WS-BLOCK-KEY           PIC X(112).
 01 WS-NO-PROPS            PIC X(600) VALUE SPACES.
 01 WS-TEMP                PIC X.
 01 WS-DIGIT               PIC 9.
 01 WS-WANT-LOOT           PIC X(48).
 01 WS-BAD                 BINARY-LONG.
 01 WS-ORDER-BAD           BINARY-LONG.
 01 WS-LIMIT-BAD           BINARY-LONG.
 01 WS-RULE-BAD            BINARY-LONG.
 01 WS-ROT-BAD             BINARY-LONG.
 01 WS-LISTS               BINARY-LONG.
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
         MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO WS-BAD WS-ORDER-BAD WS-LIMIT-BAD WS-RULE-BAD WS-ROT-BAD WS-LISTS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 5 BY 1 UNTIL WS-J > 9
             PERFORM ONE-LIST
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: ten processor lists (warm and cold, integrity 0.5 to 0.9) load with three processors" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-LISTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: the processors are in the order rot, block_ignore (air and structure block), capped" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ORDER-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: the rot integrity is the piece's (the tenths of the key)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROT-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: capped has the constant limit 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LIMIT-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§3.5 Ocean ruins piece: the delegate rule turns sand (warm) or gravel (cold) into the suspicious block with append_loot of the temperature's table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RULE-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> the list of warm (WS-I 1) or cold (0) at integrity WS-J tenths
 ONE-LIST.
     IF WS-I = 1
         MOVE "w" TO WS-TEMP
         MOVE "minecraft:archaeology/ocean_ruin_warm" TO WS-WANT-LOOT
         MOVE "suspicious_sand" TO WS-BLOCK-KEY
     ELSE
         MOVE "c" TO WS-TEMP
         MOVE "minecraft:archaeology/ocean_ruin_cold" TO WS-WANT-LOOT
         MOVE "suspicious_gravel" TO WS-BLOCK-KEY
     END-IF
     MOVE WS-J TO WS-DIGIT
     MOVE SPACES TO WS-KEY
     STRING "cobolcraft:inline/ruin/" WS-TEMP "/" WS-DIGIT DELIMITED BY SIZE INTO WS-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-KEY WS-LIST
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 3
             ADD 1 TO WS-LISTS
             MOVE SPL-FIRST(WS-LIST) TO WS-FIRST
             IF SPP-TYPE(WS-FIRST) NOT = 3 OR SPP-TYPE(WS-FIRST + 1) NOT = 9 OR SPP-TYPE(WS-FIRST + 2) NOT = 4 OR SPP-N(WS-FIRST + 1) NOT = 2
                 ADD 1 TO WS-ORDER-BAD
             END-IF
             COMPUTE WS-TENTHS ROUNDED = SPP-F(WS-FIRST) * 10
             IF WS-TENTHS NOT = WS-J
                 ADD 1 TO WS-ROT-BAD
             END-IF
             IF SPP-B(WS-FIRST + 2) NOT = 1 OR SPP-C(WS-FIRST + 2) NOT = 5
                 ADD 1 TO WS-LIMIT-BAD
             END-IF
             MOVE SPP-A(WS-FIRST + 2) TO WS-DELEGATE
             MOVE SPP-A(WS-DELEGATE) TO WS-RULE
             CALL "STRUCT-TPL-STATE" USING WS-BLOCK-KEY WS-NO-PROPS WS-WANT-STATE
             IF SPP-TYPE(WS-DELEGATE) NOT = 1 OR SPP-N(WS-DELEGATE) NOT = 1 OR SPR-STATE(WS-RULE) NOT = WS-WANT-STATE
                OR SPR-MOD(WS-RULE) NOT = 3 OR SPR-LOOT(WS-RULE) NOT = WS-WANT-LOOT
                 ADD 1 TO WS-RULE-BAD
             END-IF
         END-IF
     END-IF.
 END PROGRAM TEST-STRUCT-36-6-3-5.

 COPY NOSPAWN.
 COPY CORETEST.
