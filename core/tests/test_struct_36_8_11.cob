*> Acceptance test of the end city template catalogue (docs/protocol/36-structures-8-nether-and-end.md section 11.1; core/src/struct-endcity.cob ENDCITY-SIZE; T13510): on the generated vanilla-data
*> (CC_GENERATED_DIR, read only; passes as skipped without it) the 20 end_city templates load with the sizes of the table (the size table of ENDCITY-SIZE agrees with the data), none carries an
*> entity, the structure blocks of DATA mode are exactly the table (name, position, metadata) and the totals are 13 Sentry, 5 Chest and 1 Elytra markers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 COPY STRUCTDATA.
 COPY STRUCTTPL.

 01 WS-SIZES.
    05 FILLER PIC X(32) VALUE "base_floor          010004010   ".
    05 FILLER PIC X(32) VALUE "base_roof           012002012   ".
    05 FILLER PIC X(32) VALUE "second_floor_1      012008012   ".
    05 FILLER PIC X(32) VALUE "second_floor_2      012008012   ".
    05 FILLER PIC X(32) VALUE "second_roof         014002014   ".
    05 FILLER PIC X(32) VALUE "third_floor_1       014008014   ".
    05 FILLER PIC X(32) VALUE "third_floor_2       014008014   ".
    05 FILLER PIC X(32) VALUE "third_roof          016002016   ".
    05 FILLER PIC X(32) VALUE "tower_base          007007007   ".
    05 FILLER PIC X(32) VALUE "tower_piece         007004007   ".
    05 FILLER PIC X(32) VALUE "tower_top           009005009   ".
    05 FILLER PIC X(32) VALUE "fat_tower_base      013004013   ".
    05 FILLER PIC X(32) VALUE "fat_tower_middle    013008013   ".
    05 FILLER PIC X(32) VALUE "fat_tower_top       017006017   ".
    05 FILLER PIC X(32) VALUE "bridge_end          005006002   ".
    05 FILLER PIC X(32) VALUE "bridge_piece        005006004   ".
    05 FILLER PIC X(32) VALUE "bridge_steep_stairs 005007004   ".
    05 FILLER PIC X(32) VALUE "bridge_gentle_stairs005007008   ".
    05 FILLER PIC X(32) VALUE "ship                013024029   ".
    05 FILLER PIC X(32) VALUE "tower_floor         007004007   ".
 01 WS-SZ REDEFINES WS-SIZES.
    05 WS-S OCCURS 20 TIMES.
       10 WS-S-NAME        PIC X(20).
       10 WS-S-X           PIC 999.
       10 WS-S-Y           PIC 999.
       10 WS-S-Z           PIC 999.
       10 FILLER           PIC X(3).
 01 WS-MARKERS.
    05 FILLER PIC X(36) VALUE "base_floor          030209Sentry    ".
    05 FILLER PIC X(36) VALUE "base_floor          060209Sentry    ".
    05 FILLER PIC X(36) VALUE "second_floor_2      080506Sentry    ".
    05 FILLER PIC X(36) VALUE "third_floor_2       020502Sentry    ".
    05 FILLER PIC X(36) VALUE "third_floor_2       110502Sentry    ".
    05 FILLER PIC X(36) VALUE "third_floor_2       060602Chest     ".
    05 FILLER PIC X(36) VALUE "tower_top           040304Sentry    ".
    05 FILLER PIC X(36) VALUE "fat_tower_middle    020206Sentry    ".
    05 FILLER PIC X(36) VALUE "fat_tower_middle    100206Sentry    ".
    05 FILLER PIC X(36) VALUE "fat_tower_middle    060602Sentry    ".
    05 FILLER PIC X(36) VALUE "fat_tower_middle    060610Sentry    ".
    05 FILLER PIC X(36) VALUE "fat_tower_top       030211Chest     ".
    05 FILLER PIC X(36) VALUE "fat_tower_top       050213Chest     ".
    05 FILLER PIC X(36) VALUE "ship                060408Sentry    ".
    05 FILLER PIC X(36) VALUE "ship                050507Chest     ".
    05 FILLER PIC X(36) VALUE "ship                060507Elytra    ".
    05 FILLER PIC X(36) VALUE "ship                070507Chest     ".
    05 FILLER PIC X(36) VALUE "ship                080627Sentry    ".
    05 FILLER PIC X(36) VALUE "ship                041127Sentry    ".
 01 WS-MK REDEFINES WS-MARKERS.
    05 WS-M OCCURS 19 TIMES.
       10 WS-M-NAME        PIC X(20).
       10 WS-M-X           PIC 99.
       10 WS-M-Y           PIC 99.
       10 WS-M-Z           PIC 99.
       10 WS-M-META        PIC X(10).
 01 WS-BAD-LOAD            BINARY-LONG.
 01 WS-BAD-SIZE            BINARY-LONG.
 01 WS-BAD-ENT             BINARY-LONG.
 01 WS-BAD-TAB             BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SENTRY              BINARY-LONG VALUE 0.
 01 WS-CHEST               BINARY-LONG VALUE 0.
 01 WS-ELYTRA              BINARY-LONG VALUE 0.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-NONDATA             BINARY-LONG.
 01 WS-TN                  BINARY-LONG.
 01 WS-WANT                PIC X(96).
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-ON                  BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.

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
         MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:mansion" TO WS-KEY
     CALL "STRUCT-GATE" USING WS-KEY WS-ON
     MOVE 0 TO WS-BAD-LOAD WS-BAD-SIZE WS-BAD-ENT WS-BAD-TAB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE SPACES TO WS-ID
         STRING "minecraft:end_city/" FUNCTION TRIM(WS-S-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         IF WS-ROW < 1 OR TP-STATUS(WS-ROW) NOT = 1
             ADD 1 TO WS-BAD-LOAD
         ELSE
             IF TP-SX(WS-ROW) NOT = WS-S-X(WS-I) OR TP-SY(WS-ROW) NOT = WS-S-Y(WS-I) OR TP-SZ(WS-ROW) NOT = WS-S-Z(WS-I)
                 ADD 1 TO WS-BAD-SIZE
             END-IF
             IF TP-ENTITIES(WS-ROW) NOT = 0
                 ADD 1 TO WS-BAD-ENT
             END-IF
             MOVE WS-S-NAME(WS-I) TO WS-NAME
             CALL "ENDCITY-SIZE" USING WS-NAME WS-TX WS-TY WS-TZ
             IF WS-S-NAME(WS-I) NOT = "tower_floor"
                 IF WS-TX NOT = TP-SX(WS-ROW) OR WS-TY NOT = TP-SY(WS-ROW) OR WS-TZ NOT = TP-SZ(WS-ROW)
                     ADD 1 TO WS-BAD-TAB
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: all 20 end_city templates load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-LOAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: every template has the size of the table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-SIZE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: no template holds an entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: the size table of the generator agrees with the data" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-TAB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   every marker of the table is in its template once
     MOVE 0 TO WS-MISSING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         MOVE SPACES TO WS-ID
         STRING "minecraft:end_city/" FUNCTION TRIM(WS-M-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         MOVE WS-M-META(WS-I) TO WS-WANT
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
             COMPUTE WS-R = TP-BASE(WS-ROW, 1) + WS-K
             MOVE TB-NBT(WS-R) TO WS-TN
             IF WS-TN > 0 AND TN-KIND(WS-TN) = 3 AND TB-X(WS-R) = WS-M-X(WS-I) AND TB-Y(WS-R) = WS-M-Y(WS-I)
                 AND TB-Z(WS-R) = WS-M-Z(WS-I) AND TN-TEXT(WS-TN) = WS-WANT
                 ADD 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND NOT = 1
             ADD 1 TO WS-MISSING
             DISPLAY "PROBE missing " WS-M-NAME(WS-I) WS-M-X(WS-I) WS-M-Y(WS-I) WS-M-Z(WS-I) WS-M-META(WS-I)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
                 COMPUTE WS-R = TP-BASE(WS-ROW, 1) + WS-K
                 MOVE TB-NBT(WS-R) TO WS-TN
                 IF WS-TN > 0 AND TN-KIND(WS-TN) = 3
                     DISPLAY "PROBE   has " TB-X(WS-R) " " TB-Y(WS-R) " " TB-Z(WS-R) " [" FUNCTION TRIM(TN-TEXT(WS-TN)) "]"
                 END-IF
             END-PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-M-META(WS-I) = "Sentry"
                 ADD 1 TO WS-SENTRY
             WHEN WS-M-META(WS-I) = "Chest"
                 ADD 1 TO WS-CHEST
             WHEN OTHER
                 ADD 1 TO WS-ELYTRA
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: every marker of the table is in its template once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the number of DATA markers over all 20 templates
     MOVE 0 TO WS-TOTAL
     MOVE 0 TO WS-NONDATA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE SPACES TO WS-ID
         STRING "minecraft:end_city/" FUNCTION TRIM(WS-S-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
             COMPUTE WS-R = TP-BASE(WS-ROW, 1) + WS-K
             MOVE TB-NBT(WS-R) TO WS-TN
             IF WS-TN > 0 AND TN-KIND(WS-TN) = 3
                 ADD 1 TO WS-TOTAL
             END-IF
             IF WS-TN > 0 AND TN-KIND(WS-TN) = 5
                 ADD 1 TO WS-NONDATA
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: the 20 templates hold exactly 19 DATA markers" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE WS-TOTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: no structure block of another mode" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NONDATA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-11.

 COPY NOSPAWN.
 COPY CORETEST.
