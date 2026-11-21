*> Acceptance test of the woodland mansion template catalogue (docs/protocol/36-structures-7-woodland-mansion.md section 10; T13500): on the generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped
*> without it) every one of the 73 templates loads with the size of its family, none carries an entity, the DATA markers are exactly the table of section 10 (name, position, metadata) and the totals are
*> 10 chests, 20 Warriors, 4 Mages and 4 Groups of Allays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
*> family rows: prefix (16), first number, last number (0 and 0: the name has no number), x, y, z of the size
 01 WS-FAMILIES.
    05 FILLER PIC X(29) VALUE "1x1_a           0105007008007".
    05 FILLER PIC X(29) VALUE "1x1_as          0104007008007".
    05 FILLER PIC X(29) VALUE "corridor_floor  0000007008007".
    05 FILLER PIC X(29) VALUE "1x1_b           0105007011007".
    05 FILLER PIC X(29) VALUE "1x2_a           0109007008015".
    05 FILLER PIC X(29) VALUE "1x2_b           0105007008015".
    05 FILLER PIC X(29) VALUE "1x2_s           0102007008015".
    05 FILLER PIC X(29) VALUE "1x2_c           0104007011015".
    05 FILLER PIC X(29) VALUE "1x2_d           0105007011015".
    05 FILLER PIC X(29) VALUE "1x2_se          0101007011015".
    05 FILLER PIC X(29) VALUE "1x2_c_stairs    0000007022015".
    05 FILLER PIC X(29) VALUE "1x2_d_stairs    0000007022015".
    05 FILLER PIC X(29) VALUE "2x2_a           0104015008015".
    05 FILLER PIC X(29) VALUE "2x2_b           0105015011015".
    05 FILLER PIC X(29) VALUE "2x2_s           0101015011015".
    05 FILLER PIC X(29) VALUE "entrance        0000021019016".
    05 FILLER PIC X(29) VALUE "wall_flat       0000002008008".
    05 FILLER PIC X(29) VALUE "wall_window     0000002008008".
    05 FILLER PIC X(29) VALUE "wall_corner     0000009008002".
    05 FILLER PIC X(29) VALUE "indoors_wall_1  0000001008008".
    05 FILLER PIC X(29) VALUE "indoors_door_1  0000001008008".
    05 FILLER PIC X(29) VALUE "indoors_wall_2  0000001011008".
    05 FILLER PIC X(29) VALUE "indoors_door_2  0000001011008".
    05 FILLER PIC X(29) VALUE "carpet_south_1  0000008008003".
    05 FILLER PIC X(29) VALUE "carpet_west_1   0000003008008".
    05 FILLER PIC X(29) VALUE "carpet_south_2  0000008011003".
    05 FILLER PIC X(29) VALUE "carpet_west_2   0000003011008".
    05 FILLER PIC X(29) VALUE "carpet_north    0000005001002".
    05 FILLER PIC X(29) VALUE "carpet_east     0000002001005".
    05 FILLER PIC X(29) VALUE "roof            0000008001008".
    05 FILLER PIC X(29) VALUE "roof_front      0000004004008".
    05 FILLER PIC X(29) VALUE "roof_corner     0000004004004".
    05 FILLER PIC X(29) VALUE "roof_inner_cornr0000004004004".
    05 FILLER PIC X(29) VALUE "small_wall      0000002004008".
    05 FILLER PIC X(29) VALUE "small_wall_cornr0000002004002".
 01 WS-FAM REDEFINES WS-FAMILIES.
    05 WS-F OCCURS 35 TIMES.
       10 WS-F-PREFIX      PIC X(16).
       10 WS-F-LO          PIC 99.
       10 WS-F-HI          PIC 99.
       10 WS-F-X           PIC 999.
       10 WS-F-Y           PIC 999.
       10 WS-F-Z           PIC 999.
*> marker rows: template (8), x, y, z (2 each), metadata (16)
 01 WS-MARKERS.
    05 FILLER PIC X(30) VALUE "1x1_a4  060603ChestWest       ".
    05 FILLER PIC X(30) VALUE "1x1_as1 050101ChestWest       ".
    05 FILLER PIC X(30) VALUE "1x2_a1  030103Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_a1  030112ChestSouth      ".
    05 FILLER PIC X(30) VALUE "1x2_a3  030208Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_a8  020102Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_a9  050101Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_b1  030113Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_b2  050111Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_b3  030100ChestSouth      ".
    05 FILLER PIC X(30) VALUE "1x2_b3  030104Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_b4  040309ChestNorth      ".
    05 FILLER PIC X(30) VALUE "1x2_c3  040106Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_c3  040109Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_c3  040112Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_d2  060712ChestWest       ".
    05 FILLER PIC X(30) VALUE "1x2_d3  020210Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_d3  040210Warrior         ".
    05 FILLER PIC X(30) VALUE "1x2_d3  030303Mage            ".
    05 FILLER PIC X(30) VALUE "1x2_s1  030104ChestSouth      ".
    05 FILLER PIC X(30) VALUE "1x2_se1 030901ChestSouth      ".
    05 FILLER PIC X(30) VALUE "1x2_se1 030913ChestNorth      ".
    05 FILLER PIC X(30) VALUE "2x2_a1  120103Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_a1  020208Group of Allays ".
    05 FILLER PIC X(30) VALUE "2x2_a1  040202Group of Allays ".
    05 FILLER PIC X(30) VALUE "2x2_a1  050212Group of Allays ".
    05 FILLER PIC X(30) VALUE "2x2_a1  120212Group of Allays ".
    05 FILLER PIC X(30) VALUE "2x2_a2  090102Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b1  020108Mage            ".
    05 FILLER PIC X(30) VALUE "2x2_b1  040104Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b1  080109Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b2  020107Mage            ".
    05 FILLER PIC X(30) VALUE "2x2_b2  090108Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b2  130102Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b4  030103Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b4  040111Warrior         ".
    05 FILLER PIC X(30) VALUE "2x2_b4  030108Mage            ".
    05 FILLER PIC X(30) VALUE "2x2_b5  070700ChestSouth      ".
 01 WS-MK REDEFINES WS-MARKERS.
    05 WS-M OCCURS 38 TIMES.
       10 WS-M-NAME        PIC X(8).
       10 WS-M-X           PIC 99.
       10 WS-M-Y           PIC 99.
       10 WS-M-Z           PIC 99.
       10 WS-M-META        PIC X(16).
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-ON                  BINARY-LONG.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-NUM                 PIC 9.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-BAD-SIZE            BINARY-LONG VALUE 0.
 01 WS-BAD-LOAD            BINARY-LONG VALUE 0.
 01 WS-BAD-ENT             BINARY-LONG VALUE 0.
 01 WS-FILES               BINARY-LONG VALUE 0.
 01 WS-TOTAL-MARKS         BINARY-LONG VALUE 0.
 01 WS-CHESTS              BINARY-LONG VALUE 0.
 01 WS-WARRIORS            BINARY-LONG VALUE 0.
 01 WS-MAGES               BINARY-LONG VALUE 0.
 01 WS-ALLAYS              BINARY-LONG VALUE 0.
 01 WS-NONDATA             BINARY-LONG VALUE 0.
 01 WS-MISSING             BINARY-LONG VALUE 0.
 01 WS-EXTRA               BINARY-LONG VALUE 0.
 01 WS-HERE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EXP-HERE            BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-TN                  BINARY-LONG.
 01 WS-META                PIC X(96).
 01 WS-WANT                PIC X(96).
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
         MOVE "acceptance US12 36-7§10 no generated packs here, skipped" TO TL-CASE
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
*>   every template of every family: loaded, the size of the family, no entity
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         MOVE WS-F-LO(WS-I) TO WS-LO
         MOVE WS-F-HI(WS-I) TO WS-HI
         IF WS-LO = 0
             MOVE 1 TO WS-LO
             MOVE 1 TO WS-HI
         END-IF
         PERFORM VARYING WS-NUMBER FROM WS-LO BY 1 UNTIL WS-NUMBER > WS-HI
             MOVE SPACES TO WS-NAME
             IF WS-F-LO(WS-I) = 0
                 MOVE WS-F-PREFIX(WS-I) TO WS-NAME
             ELSE
                 MOVE WS-NUMBER TO WS-NUM
                 STRING FUNCTION TRIM(WS-F-PREFIX(WS-I)) WS-NUM DELIMITED BY SIZE INTO WS-NAME
             END-IF
*>           the two 16-character prefixes that did not fit the table
             IF WS-NAME(1:15) = "roof_inner_corn"
                 MOVE "roof_inner_corner" TO WS-NAME
             END-IF
             IF WS-NAME(1:15) = "small_wall_corn"
                 MOVE "small_wall_corner" TO WS-NAME
             END-IF
             MOVE SPACES TO WS-ID
             STRING "minecraft:woodland_mansion/" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-ID
             CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
             ADD 1 TO WS-FILES
             IF WS-ROW < 1 OR TP-STATUS(WS-ROW) NOT = 1
                 ADD 1 TO WS-BAD-LOAD
                 DISPLAY "PROBE template not loaded: " FUNCTION TRIM(WS-ID)
             ELSE
                 IF TP-SX(WS-ROW) NOT = WS-F-X(WS-I) OR TP-SY(WS-ROW) NOT = WS-F-Y(WS-I) OR TP-SZ(WS-ROW) NOT = WS-F-Z(WS-I)
                     ADD 1 TO WS-BAD-SIZE
                     DISPLAY "PROBE size of " FUNCTION TRIM(WS-ID) " " TP-SX(WS-ROW) " " TP-SY(WS-ROW) " " TP-SZ(WS-ROW)
                 END-IF
                 IF TP-ENTITIES(WS-ROW) NOT = 0
                     ADD 1 TO WS-BAD-ENT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-7§10 the families name 73 template files" TO TL-CASE
     MOVE 73 TO TL-EXPECTED-N
     MOVE WS-FILES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 all 73 templates load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-LOAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 every template has the size of its family" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-SIZE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 no template carries an entity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   markers: every row of the table is present once in its template, and every template's number of DATA markers is its number of rows
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 38
         MOVE SPACES TO WS-ID
         STRING "minecraft:woodland_mansion/" FUNCTION TRIM(WS-M-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         MOVE WS-M-META(WS-I) TO WS-WANT
         MOVE 0 TO WS-FOUND
         IF WS-ROW >= 1 AND TP-STATUS(WS-ROW) = 1
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
                 COMPUTE WS-R = TP-BASE(WS-ROW, 1) + WS-K
                 MOVE TB-X(WS-R) TO WS-TX
                 MOVE TB-Y(WS-R) TO WS-TY
                 MOVE TB-Z(WS-R) TO WS-TZ
                 MOVE TB-NBT(WS-R) TO WS-TN
                 IF WS-TN > 0 AND TN-KIND(WS-TN) = 3 AND WS-TX = WS-M-X(WS-I) AND WS-TY = WS-M-Y(WS-I)
                     AND WS-TZ = WS-M-Z(WS-I) AND TN-TEXT(WS-TN) = WS-WANT
                     ADD 1 TO WS-FOUND
                 END-IF
             END-PERFORM
         END-IF
         IF WS-FOUND NOT = 1
             ADD 1 TO WS-MISSING
             DISPLAY "PROBE marker missing: " WS-M-NAME(WS-I) " " WS-M-X(WS-I) " " WS-M-Y(WS-I) " " WS-M-Z(WS-I)
         END-IF
         EVALUATE TRUE
             WHEN WS-M-META(WS-I)(1:5) = "Chest"
                 ADD 1 TO WS-CHESTS
             WHEN WS-M-META(WS-I)(1:7) = "Warrior"
                 ADD 1 TO WS-WARRIORS
             WHEN WS-M-META(WS-I)(1:4) = "Mage"
                 ADD 1 TO WS-MAGES
             WHEN OTHER
                 ADD 1 TO WS-ALLAYS
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-7§10 every marker of the table is in its template once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the number of DATA markers of each of the 73 templates against the rows of the table, and the other structure block modes (none)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         MOVE WS-F-LO(WS-I) TO WS-LO
         MOVE WS-F-HI(WS-I) TO WS-HI
         IF WS-LO = 0
             MOVE 1 TO WS-LO
             MOVE 1 TO WS-HI
         END-IF
         PERFORM VARYING WS-NUMBER FROM WS-LO BY 1 UNTIL WS-NUMBER > WS-HI
             MOVE SPACES TO WS-NAME
             IF WS-F-LO(WS-I) = 0
                 MOVE WS-F-PREFIX(WS-I) TO WS-NAME
             ELSE
                 MOVE WS-NUMBER TO WS-NUM
                 STRING FUNCTION TRIM(WS-F-PREFIX(WS-I)) WS-NUM DELIMITED BY SIZE INTO WS-NAME
             END-IF
             IF WS-NAME(1:15) = "roof_inner_corn"
                 MOVE "roof_inner_corner" TO WS-NAME
             END-IF
             IF WS-NAME(1:15) = "small_wall_corn"
                 MOVE "small_wall_corner" TO WS-NAME
             END-IF
             MOVE SPACES TO WS-ID
             STRING "minecraft:woodland_mansion/" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-ID
             CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
             MOVE 0 TO WS-HERE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
                 COMPUTE WS-TN = TP-BASE(WS-ROW, 1) + WS-K
                 MOVE TB-NBT(WS-TN) TO WS-TN
                 IF WS-TN > 0 AND TN-KIND(WS-TN) = 3
                     ADD 1 TO WS-HERE
                 END-IF
                 IF WS-TN > 0 AND TN-KIND(WS-TN) = 5
                     ADD 1 TO WS-NONDATA
                 END-IF
             END-PERFORM
             MOVE 0 TO WS-EXP-HERE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 38
                 IF FUNCTION TRIM(WS-M-NAME(WS-K)) = FUNCTION TRIM(WS-NAME)
                     ADD 1 TO WS-EXP-HERE
                 END-IF
             END-PERFORM
             ADD WS-HERE TO WS-TOTAL-MARKS
             IF WS-HERE NOT = WS-EXP-HERE
                 ADD 1 TO WS-EXTRA
                 DISPLAY "PROBE marker count of " FUNCTION TRIM(WS-NAME) " " WS-HERE
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-7§10 every other template has no marker, the marked ones have exactly their rows" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXTRA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 there is no structure block of another mode" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NONDATA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 38 DATA markers in all" TO TL-CASE
     MOVE 38 TO TL-EXPECTED-N
     MOVE WS-TOTAL-MARKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 10 chest markers" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-CHESTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 20 Warrior markers" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-WARRIORS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 4 Mage markers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-MAGES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§10 4 Group of Allays markers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-ALLAYS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-10.

 COPY NOSPAWN.
 COPY CORETEST.
