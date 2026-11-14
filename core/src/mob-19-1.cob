*> Land friendly and neutral mobs, shared tables (docs/protocol/19-mobs-land-friendly-and-neutral.md section 1; lane 002-lane-mobsfull-h4).
*> The species of document 19 are rows of core/copy/MOB19ROWS.cpy (included by STDMOBS.cpy); the data that has no column in a row lives here.
*>
*> Entry points:
*>   M19-VARIANT-PICK USING n, priorities (16 BINARY-LONG), draw, index out     1.6  highest priority wins, one of the ties by the draw
*>   M19-FARM-VARIANT USING cold, warm, draw, variant out                       1.6  pig, cow, chicken: 0 temperate, 1 cold, 2 warm
*>   M19-FLOOR-OK USING class, key (PIC X(48)), ok out                          1.4  the block below a spawn
*>   M19-SPECIES-FLOOR USING key (PIC X(24)), class out                         1.4  the floor class of a species
*>   M19-FLOOR-AT USING dim, x, y, z, class, ok out                             1.4  the same for the block at a position

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-VARIANT-PICK.
*> USING n (the pairs whose condition holds), priorities (the priority of each pair, 16 at most), draw (a non-negative random number), index out:
*> keep the pairs of the highest priority and take the (draw mod count + 1)-th of them (1.6 steps 2 and 3). 0 when n is 0. The caller supplies a
*> uniform draw; any uniform generator is allowed (44 part 1 section 1.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-PRI.
    05 L-P                 BINARY-LONG OCCURS 16 TIMES.
 01 L-DRAW                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-PRI L-DRAW L-INDEX.
     MOVE 0 TO L-INDEX WS-COUNT
     MOVE -1 TO WS-TOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         IF L-P(WS-I) > WS-TOP
             MOVE L-P(WS-I) TO WS-TOP
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         IF L-P(WS-I) = WS-TOP
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     IF WS-COUNT > 0
         COMPUTE WS-WANT = FUNCTION MOD(L-DRAW, WS-COUNT) + 1
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
             IF L-P(WS-I) = WS-TOP
                 ADD 1 TO WS-COUNT
                 IF WS-COUNT = WS-WANT
                     MOVE WS-I TO L-INDEX
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM M19-VARIANT-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FARM-VARIANT.
*> USING cold (1 when the biome is in the tag spawns_cold_variant_farm_animals), warm (the tag spawns_warm_variant_farm_animals), draw, variant out:
*> the pig, cow and chicken variant of 1.6: temperate (priority 0, always holds), cold and warm (priority 1 when their tag holds).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-PRI.
    05 WS-P                BINARY-LONG OCCURS 16 TIMES.
 01 WS-KIND.
    05 WS-K                BINARY-LONG OCCURS 16 TIMES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-COLD                 BINARY-LONG.
 01 L-WARM                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 PROCEDURE DIVISION USING L-COLD L-WARM L-DRAW L-VARIANT.
     MOVE 1 TO WS-N
     MOVE 0 TO WS-P(1) WS-K(1)
     IF L-COLD = 1
         ADD 1 TO WS-N
         MOVE 1 TO WS-P(WS-N) WS-K(WS-N)
     END-IF
     IF L-WARM = 1
         ADD 1 TO WS-N
         MOVE 1 TO WS-P(WS-N)
         MOVE 2 TO WS-K(WS-N)
     END-IF
     CALL "M19-VARIANT-PICK" USING WS-N WS-PRI L-DRAW WS-INDEX
     MOVE WS-K(WS-INDEX) TO L-VARIANT
     GOBACK.
 END PROGRAM M19-FARM-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FLOOR-OK.
*> USING class, key (PIC X(48), with or without "minecraft:"), ok out: 1 when the block below a spawn is allowed for the floor class (1.4):
*> 1 animals_spawnable_on (grass_block); 2 rabbits (grass_block, snow, snow_block, sand); 3 foxes (grass_block, snow, snow_block, podzol,
*> coarse_dirt); 4 goats (grass_block, stone, snow, snow_block, packed_ice, gravel); 5 camels (the tag sand); 6 armadillos (grass_block,
*> the badlands terracotta, red_sand, coarse_dirt).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLOORS.
    05 FILLER PIC X(25) VALUE "1grass_block".
    05 FILLER PIC X(25) VALUE "2grass_block".
    05 FILLER PIC X(25) VALUE "2snow".
    05 FILLER PIC X(25) VALUE "2snow_block".
    05 FILLER PIC X(25) VALUE "2sand".
    05 FILLER PIC X(25) VALUE "3grass_block".
    05 FILLER PIC X(25) VALUE "3snow".
    05 FILLER PIC X(25) VALUE "3snow_block".
    05 FILLER PIC X(25) VALUE "3podzol".
    05 FILLER PIC X(25) VALUE "3coarse_dirt".
    05 FILLER PIC X(25) VALUE "4grass_block".
    05 FILLER PIC X(25) VALUE "4stone".
    05 FILLER PIC X(25) VALUE "4snow".
    05 FILLER PIC X(25) VALUE "4snow_block".
    05 FILLER PIC X(25) VALUE "4packed_ice".
    05 FILLER PIC X(25) VALUE "4gravel".
    05 FILLER PIC X(25) VALUE "5sand".
    05 FILLER PIC X(25) VALUE "5red_sand".
    05 FILLER PIC X(25) VALUE "5suspicious_sand".
    05 FILLER PIC X(25) VALUE "6grass_block".
    05 FILLER PIC X(25) VALUE "6terracotta".
    05 FILLER PIC X(25) VALUE "6white_terracotta".
    05 FILLER PIC X(25) VALUE "6yellow_terracotta".
    05 FILLER PIC X(25) VALUE "6orange_terracotta".
    05 FILLER PIC X(25) VALUE "6red_terracotta".
    05 FILLER PIC X(25) VALUE "6brown_terracotta".
    05 FILLER PIC X(25) VALUE "6light_gray_terracotta".
    05 FILLER PIC X(25) VALUE "6red_sand".
    05 FILLER PIC X(25) VALUE "6coarse_dirt".
 01 WS-FLOOR-TABLE REDEFINES WS-FLOORS.
    05 WS-ROW                 OCCURS 29 TIMES.
       10 WS-ROW-CLASS        PIC X.
       10 WS-ROW-KEY          PIC X(24).
 01 WS-I                   BINARY-LONG.
 01 WS-WANT                PIC X.
 01 WS-NAME                PIC X(24).
 LINKAGE SECTION.
 01 L-CLASS                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-KEY L-OK.
     MOVE 0 TO L-OK
     MOVE SPACES TO WS-NAME
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:24) TO WS-NAME
     ELSE
         MOVE L-KEY(1:24) TO WS-NAME
     END-IF
     MOVE FUNCTION CHAR(L-CLASS + 49) TO WS-WANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         IF WS-ROW-CLASS(WS-I) = WS-WANT AND WS-ROW-KEY(WS-I) = WS-NAME
             MOVE 1 TO L-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M19-FLOOR-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-SPECIES-FLOOR.
*> USING key (PIC X(24), the species without "minecraft:"), class out: the floor class of M19-FLOOR-OK; 1 (grass) for a species that has no own rule.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CLASS.
     EVALUATE L-KEY
         WHEN "rabbit"
             MOVE 2 TO L-CLASS
         WHEN "fox"
             MOVE 3 TO L-CLASS
         WHEN "goat"
             MOVE 4 TO L-CLASS
         WHEN "camel"
             MOVE 5 TO L-CLASS
         WHEN "armadillo"
             MOVE 6 TO L-CLASS
         WHEN OTHER
             MOVE 1 TO L-CLASS
     END-EVALUATE
     GOBACK.
 END PROGRAM M19-SPECIES-FLOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M19-FLOOR-AT.
*> USING dim, x, y, z (the cell of the block below the spawn), class, ok out: M19-FLOOR-OK for the block at the cell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CLASS L-OK.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-KEY(WS-BLOCK) TO WS-KEY
     CALL "M19-FLOOR-OK" USING L-CLASS WS-KEY L-OK
     GOBACK.
 END PROGRAM M19-FLOOR-AT.
