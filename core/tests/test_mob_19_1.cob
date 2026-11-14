*> Acceptance test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md section 1: shared tables): variant selection by priority (1.6)
*> and the floor blocks of the spawn rules (1.4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-N                  BINARY-LONG.
 01 WS-PRI.
    05 WS-P               BINARY-LONG OCCURS 16 TIMES.
 01 WS-DRAW               BINARY-LONG.
 01 WS-IDX                BINARY-LONG.
 01 WS-COLD               BINARY-LONG.
 01 WS-WARM               BINARY-LONG.
 01 WS-VARIANT            BINARY-LONG.
 01 WS-CLASS              BINARY-LONG.
 01 WS-KEY                PIC X(48).
 01 WS-KEY24              PIC X(24).
 01 WS-OK                 BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-CLS-D              PIC 9.
 01 WS-CASES.
    05 FILLER PIC X(26) VALUE "1grass_block".
    05 FILLER PIC X(26) VALUE "0dirt".
    05 FILLER PIC X(26) VALUE "2grass_block".
    05 FILLER PIC X(26) VALUE "2snow".
    05 FILLER PIC X(26) VALUE "2snow_block".
    05 FILLER PIC X(26) VALUE "2sand".
    05 FILLER PIC X(26) VALUE "0red_sand".
    05 FILLER PIC X(26) VALUE "0stone".
    05 FILLER PIC X(26) VALUE "3grass_block".
    05 FILLER PIC X(26) VALUE "3podzol".
    05 FILLER PIC X(26) VALUE "3coarse_dirt".
    05 FILLER PIC X(26) VALUE "3snow".
    05 FILLER PIC X(26) VALUE "0sand".
    05 FILLER PIC X(26) VALUE "4grass_block".
    05 FILLER PIC X(26) VALUE "4stone".
    05 FILLER PIC X(26) VALUE "4packed_ice".
    05 FILLER PIC X(26) VALUE "4gravel".
    05 FILLER PIC X(26) VALUE "4snow_block".
    05 FILLER PIC X(26) VALUE "0dirt".
    05 FILLER PIC X(26) VALUE "5sand".
    05 FILLER PIC X(26) VALUE "5red_sand".
    05 FILLER PIC X(26) VALUE "5suspicious_sand".
    05 FILLER PIC X(26) VALUE "0grass_block".
    05 FILLER PIC X(26) VALUE "6terracotta".
    05 FILLER PIC X(26) VALUE "6white_terracotta".
    05 FILLER PIC X(26) VALUE "6yellow_terracotta".
    05 FILLER PIC X(26) VALUE "6orange_terracotta".
    05 FILLER PIC X(26) VALUE "6red_terracotta".
    05 FILLER PIC X(26) VALUE "6brown_terracotta".
    05 FILLER PIC X(26) VALUE "6light_gray_terracotta".
    05 FILLER PIC X(26) VALUE "6red_sand".
    05 FILLER PIC X(26) VALUE "6coarse_dirt".
    05 FILLER PIC X(26) VALUE "6grass_block".
    05 FILLER PIC X(26) VALUE "0blue_terracotta".
    05 FILLER PIC X(26) VALUE "0sand".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-ROW           OCCURS 35 TIMES.
       10 WS-CASE-CLASS      PIC X.
       10 WS-CASE-KEY        PIC X(25).
 PROCEDURE DIVISION.
     INITIALIZE WS-PRI
     MOVE 0 TO WS-P(1)
     MOVE 1 TO WS-P(2)
     MOVE 1 TO WS-P(3)
     MOVE 0 TO WS-DRAW
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: no holding pair gives index 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-N
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: only the pairs of the highest priority stay; draw 0 picks the first of them" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-DRAW
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: draw 1 picks the second of the top pairs" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 5 TO WS-DRAW
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: the draw wraps over the remaining pairs (5 mod 2)" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-P(1)
     MOVE 0 TO WS-P(2)
     MOVE 1 TO WS-P(3)
     MOVE 1 TO WS-P(4)
     MOVE 4 TO WS-N
     MOVE 2 TO WS-DRAW
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: pairs 1, 3, 4 hold the top priority; draw 2 picks the third of them" TO WS-CASE
     MOVE 4 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-P(1)
     MOVE 0 TO WS-P(2)
     MOVE 2 TO WS-N
     MOVE 1 TO WS-DRAW
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI WS-DRAW WS-IDX
     MOVE "acceptance US15 19§1.6 Variant selection: all pairs at priority 0 are candidates" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-IDX TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-COLD WS-WARM WS-DRAW
     CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW WS-VARIANT
     MOVE "acceptance US15 19§1.6 Farm animal variant: a temperate biome gives temperate (0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-VARIANT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-COLD
     CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW WS-VARIANT
     MOVE "acceptance US15 19§1.6 Farm animal variant: a cold biome gives cold (1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-VARIANT TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-COLD
     MOVE 1 TO WS-WARM
     CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW WS-VARIANT
     MOVE "acceptance US15 19§1.6 Farm animal variant: a warm biome gives warm (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-VARIANT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-COLD
     MOVE 1 TO WS-DRAW
     CALL "M19-FARM-VARIANT" USING WS-COLD WS-WARM WS-DRAW WS-VARIANT
     MOVE "acceptance US15 19§1.6 Farm animal variant: a biome in both tags takes the second candidate on draw 1" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-VARIANT TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 35
         MOVE FUNCTION NUMVAL(WS-CASE-CLASS(WS-I)) TO WS-CLASS
         MOVE SPACES TO WS-KEY
         MOVE WS-CASE-KEY(WS-I) TO WS-KEY
         MOVE 1 TO WS-E
         IF WS-I = 2 OR WS-I = 7 OR WS-I = 8 OR WS-I = 13 OR WS-I = 19 OR WS-I = 23 OR WS-I = 34 OR WS-I = 35
             MOVE 0 TO WS-E
         END-IF
         EVALUATE TRUE
             WHEN WS-I = 2 OR WS-I = 19
                 MOVE 1 TO WS-CLASS
             WHEN WS-I = 7 OR WS-I = 8
                 MOVE 2 TO WS-CLASS
             WHEN WS-I = 13
                 MOVE 3 TO WS-CLASS
             WHEN WS-I = 23
                 MOVE 5 TO WS-CLASS
             WHEN WS-I = 34 OR WS-I = 35
                 MOVE 6 TO WS-CLASS
         END-EVALUATE
         CALL "M19-FLOOR-OK" USING WS-CLASS WS-KEY WS-OK
         MOVE SPACES TO WS-CASE
         MOVE WS-CLASS TO WS-CLS-D
         STRING "acceptance US15 19§1.4 Floor blocks: class " DELIMITED BY SIZE WS-CLS-D DELIMITED BY SIZE
             " on " DELIMITED BY SIZE WS-KEY DELIMITED BY SPACE INTO WS-CASE
         MOVE WS-OK TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:podzol" TO WS-KEY
     MOVE 3 TO WS-CLASS
     CALL "M19-FLOOR-OK" USING WS-CLASS WS-KEY WS-OK
     MOVE "acceptance US15 19§1.4 Floor blocks: a key with the minecraft: prefix is the same block" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-KEY24
         EVALUATE WS-I
             WHEN 1 MOVE "rabbit" TO WS-KEY24 MOVE 2 TO WS-E
             WHEN 2 MOVE "fox" TO WS-KEY24 MOVE 3 TO WS-E
             WHEN 3 MOVE "goat" TO WS-KEY24 MOVE 4 TO WS-E
             WHEN 4 MOVE "camel" TO WS-KEY24 MOVE 5 TO WS-E
             WHEN 5 MOVE "armadillo" TO WS-KEY24 MOVE 6 TO WS-E
             WHEN 6 MOVE "pig" TO WS-KEY24 MOVE 1 TO WS-E
             WHEN 7 MOVE "horse" TO WS-KEY24 MOVE 1 TO WS-E
             WHEN 8 MOVE "zombie" TO WS-KEY24 MOVE 1 TO WS-E
         END-EVALUATE
         CALL "M19-SPECIES-FLOOR" USING WS-KEY24 WS-CLASS
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 19§1.4 Spawn floor class of " DELIMITED BY SIZE WS-KEY24 DELIMITED BY SPACE INTO WS-CASE
         MOVE WS-CLASS TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-1.
