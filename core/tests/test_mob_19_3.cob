*> Acceptance test (US15; docs/protocol/19 section 3 and 25.3): equine genes, foals, feeding, taming and the jump scale.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-C                  BINARY-LONG.
 01 WS-R                  BINARY-LONG.
 01 WS-D                  BINARY-LONG.
 01 WS-F1                 FLOAT-LONG.
 01 WS-F2                 FLOAT-LONG.
 01 WS-F3                 FLOAT-LONG.
 01 WS-F4                 FLOAT-LONG.
 01 WS-F5                 FLOAT-LONG.
 01 WS-F6                 FLOAT-LONG.
 01 WS-F7                 FLOAT-LONG.
 01 WS-V                  FLOAT-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-ITEM               PIC X(24).
 01 WS-FOUND              BINARY-LONG.
 01 WS-HEAL               BINARY-LONG.
 01 WS-AGE                BINARY-LONG.
 01 WS-TEMPER             BINARY-LONG.
 01 WS-LOVE               BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-FOODS.
    05 FILLER PIC X(34) VALUE "0wheat                 10002020003".
    05 FILLER PIC X(34) VALUE "0sugar                 10001030003".
    05 FILLER PIC X(34) VALUE "0hay_block             10020180000".
    05 FILLER PIC X(34) VALUE "0apple                 10003060003".
    05 FILLER PIC X(34) VALUE "0carrot                10003060003".
    05 FILLER PIC X(34) VALUE "0golden_carrot         11004060005".
    05 FILLER PIC X(34) VALUE "0golden_apple          11010240010".
    05 FILLER PIC X(34) VALUE "0enchanted_golden_apple11010240010".
    05 FILLER PIC X(34) VALUE "0red_mushroom          00000000000".
    05 FILLER PIC X(34) VALUE "3red_mushroom          10003000003".
    05 FILLER PIC X(34) VALUE "3wheat                 00000000000".
    05 FILLER PIC X(34) VALUE "1wheat                 11002010003".
    05 FILLER PIC X(34) VALUE "1hay_block             11010090006".
    05 FILLER PIC X(34) VALUE "1apple                 00000000000".
    05 FILLER PIC X(34) VALUE "2cactus                11002000000".
    05 FILLER PIC X(34) VALUE "2wheat                 00000000000".
 01 WS-FOOD-TABLE REDEFINES WS-FOODS.
    05 WS-FOOD               OCCURS 16 TIMES.
       10 WS-FD-KIND         PIC 9.
       10 WS-FD-ITEM         PIC X(22).
       10 WS-FD-FOUND        PIC 9.
       10 WS-FD-LOVE         PIC 9.
       10 WS-FD-HEAL         PIC 999.
       10 WS-FD-AGE          PIC 999.
       10 WS-FD-TEMPER       PIC 999.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-A WS-B
     CALL "M19-GENE-HEALTH" USING WS-A WS-B WS-R
     MOVE "acceptance US15 19§3.2 Genes: the lowest health draw is 15" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 7 TO WS-A
     MOVE 8 TO WS-B
     CALL "M19-GENE-HEALTH" USING WS-A WS-B WS-R
     MOVE "acceptance US15 19§3.2 Genes: the highest health draw is 30" TO WS-CASE
     MOVE 30 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-F1 WS-F2 WS-F3
     CALL "M19-GENE-JUMP" USING WS-F1 WS-F2 WS-F3 WS-V
     MOVE "acceptance US15 19§3.2 Genes: jump strength minimum 0.4" TO WS-CASE
     COMPUTE WS-E = 400000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 1 TO WS-F1 WS-F2 WS-F3
     CALL "M19-GENE-JUMP" USING WS-F1 WS-F2 WS-F3 WS-V
     MOVE "acceptance US15 19§3.2 Genes: jump strength maximum 1.0" TO WS-CASE
     COMPUTE WS-E = 1000000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 0 TO WS-F1 WS-F2 WS-F3
     CALL "M19-GENE-SPEED" USING WS-F1 WS-F2 WS-F3 WS-V
     MOVE "acceptance US15 19§3.2 Genes: movement speed minimum 0.1125" TO WS-CASE
     COMPUTE WS-E = 112500
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 1 TO WS-F1 WS-F2 WS-F3
     CALL "M19-GENE-SPEED" USING WS-F1 WS-F2 WS-F3 WS-V
     MOVE "acceptance US15 19§3.2 Genes: movement speed maximum 0.3375" TO WS-CASE
     COMPUTE WS-E = 337500
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 0.5 TO WS-F1 WS-F2 WS-F3
     CALL "M19-GENE-SPEED" USING WS-F1 WS-F2 WS-F3 WS-V
     MOVE "acceptance US15 19§3.2 Genes: movement speed at the middle draw is the base 0.225" TO WS-CASE
     COMPUTE WS-E = 225000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
*> foal worked examples
     MOVE 0.5 TO WS-F1
     MOVE 0.9 TO WS-F2
     MOVE 0.4 TO WS-F3
     MOVE 1.0 TO WS-F4
     MOVE 0.9 TO WS-F5 WS-F6 WS-F7
     CALL "M19-FOAL-STAT" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-V
     MOVE "acceptance US15 19§3.2 Foal: parents 0.5 and 0.9, draws 0.9 give 0.932" TO WS-CASE
     COMPUTE WS-E = 932000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 1 TO WS-F5 WS-F6 WS-F7
     CALL "M19-FOAL-STAT" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-V
     MOVE "acceptance US15 19§3.2 Foal: draws 1 give 0.99" TO WS-CASE
     COMPUTE WS-E = 990000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 1.0 TO WS-F1 WS-F2
     CALL "M19-FOAL-STAT" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-V
     MOVE "acceptance US15 19§3.2 Foal: 1.0 and 1.0 with draws 1 reflect to 0.91" TO WS-CASE
     COMPUTE WS-E = 910000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 0.4 TO WS-F1 WS-F2
     MOVE 0 TO WS-F5 WS-F6 WS-F7
     CALL "M19-FOAL-STAT" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-V
     MOVE "acceptance US15 19§3.2 Foal: a value under the minimum reflects upward (0.49)" TO WS-CASE
     COMPUTE WS-E = 490000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
     MOVE 2.0 TO WS-F1
     MOVE 0.1 TO WS-F2
     MOVE 0.5 TO WS-F5 WS-F6 WS-F7
     CALL "M19-FOAL-STAT" USING WS-F1 WS-F2 WS-F3 WS-F4 WS-F5 WS-F6 WS-F7 WS-V
     MOVE "acceptance US15 19§3.2 Foal: parents are clamped into the range first (1.0 and 0.4 give 0.7)" TO WS-CASE
     COMPUTE WS-E = 700000
     COMPUTE WS-O ROUNDED = WS-V * 1000000
     PERFORM CHECK-N
*> feeding table
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE FUNCTION NUMVAL(WS-FD-KIND(WS-I)) TO WS-KIND
         MOVE SPACES TO WS-ITEM
         MOVE WS-FD-ITEM(WS-I) TO WS-ITEM
         CALL "M19-HORSE-FOOD" USING WS-KIND WS-ITEM WS-FOUND WS-HEAL WS-AGE WS-TEMPER WS-LOVE
         MOVE WS-ITEM TO WS-CASE
         MOVE "acceptance US15 19§3.4 Feeding table: heal, age-up and temper of the food" TO WS-CASE
         COMPUTE WS-E = WS-FD-HEAL(WS-I) * 1000000 + WS-FD-AGE(WS-I) * 1000 + WS-FD-TEMPER(WS-I)
         COMPUTE WS-O = WS-HEAL * 1000000 + WS-AGE * 1000 + WS-TEMPER
         PERFORM CHECK-N
         MOVE "acceptance US15 19§3.4 Feeding table: found and love flags of the food" TO WS-CASE
         COMPUTE WS-E = WS-FD-FOUND(WS-I) * 10 + WS-FD-LOVE(WS-I)
         COMPUTE WS-O = WS-FOUND * 10 + WS-LOVE
         PERFORM CHECK-N
     END-PERFORM
     MOVE 0 TO WS-KIND
     MOVE "wheat" TO WS-ITEM
     CALL "M19-HORSE-FOOD" USING WS-KIND WS-ITEM WS-FOUND WS-HEAL WS-AGE WS-TEMPER WS-LOVE
     MOVE "acceptance US15 19§3.4 Feeding table: wheat gives no love" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-LOVE TO WS-O
     PERFORM CHECK-N
*> jump scale
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1 MOVE 0 TO WS-A MOVE 400 TO WS-E
             WHEN 2 MOVE 45 TO WS-A MOVE 600 TO WS-E
             WHEN 3 MOVE 89 TO WS-A MOVE 795 TO WS-E
             WHEN 4 MOVE 90 TO WS-A MOVE 1000 TO WS-E
             WHEN 5 MOVE 100 TO WS-A MOVE 1000 TO WS-E
             WHEN 6 MOVE -5 TO WS-A MOVE 400 TO WS-E
         END-EVALUATE
         CALL "M19-HORSE-JUMP-SCALE" USING WS-A WS-R
         MOVE "acceptance US15 19§3.1 Jump: scale in thousandths of the jump power" TO WS-CASE
         MOVE WS-R TO WS-O
         PERFORM CHECK-N
     END-PERFORM
*> coats
     MOVE 5 TO WS-A
     MOVE 3 TO WS-B
     MOVE 6 TO WS-C
     MOVE 0 TO WS-D
     CALL "M19-FOAL-COAT" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: draw 0 takes this parent's coat" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-D
     CALL "M19-FOAL-COAT" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: draw 4 takes the other parent's coat" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 8 TO WS-D
     CALL "M19-FOAL-COAT" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: draw 8 takes the random coat" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-D
     CALL "M19-FOAL-COAT" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: draw 3 is still this parent's coat" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     MOVE 4 TO WS-B
     MOVE 2 TO WS-C
     MOVE 1 TO WS-D
     CALL "M19-FOAL-MARKINGS" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: marking draw 1 takes this parent's markings" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-D
     CALL "M19-FOAL-MARKINGS" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: marking draw 2 takes the other's" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 4 TO WS-D
     CALL "M19-FOAL-MARKINGS" USING WS-D WS-A WS-B WS-C WS-R
     MOVE "acceptance US15 19§3.3 Offspring: marking draw 4 is random" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
*> taming
     MOVE 30 TO WS-A
     MOVE 29 TO WS-B
     CALL "M19-HORSE-TAME" USING WS-A WS-B WS-R
     MOVE "acceptance US15 19§3.4 Taming: draw below the temper tames" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 30 TO WS-B
     CALL "M19-HORSE-TAME" USING WS-A WS-B WS-R
     MOVE "acceptance US15 19§3.4 Taming: draw equal to the temper does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-A WS-B
     CALL "M19-HORSE-TAME" USING WS-A WS-B WS-R
     MOVE "acceptance US15 19§3.4 Taming: temper 0 never tames" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-R TO WS-O
     PERFORM CHECK-N
     MOVE 98 TO WS-A
     MOVE 10 TO WS-B
     CALL "M19-HORSE-TEMPER" USING WS-A WS-B
     MOVE "acceptance US15 19§3.4 Temper: modifyTemper clamps at 100" TO WS-CASE
     MOVE 100 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-A
     MOVE -20 TO WS-B
     CALL "M19-HORSE-TEMPER" USING WS-A WS-B
     MOVE "acceptance US15 19§3.4 Temper: and at 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 10 TO WS-A
     MOVE 5 TO WS-B
     CALL "M19-HORSE-TEMPER" USING WS-A WS-B
     MOVE "acceptance US15 19§3.4 Temper: failed taming adds 5" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-3.
