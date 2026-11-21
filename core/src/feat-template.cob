*> The template feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 17; registry id 50, template): FD-TEMPLATE-NODE reads templates (a weighted list of {data: {id, rotations},
*> weight}; the rotations default to NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90) and the optional inline processors into a row of FD-WA (WA-I(1) the total weight, WA-I(2) the
*> processor list of STRUCT-PROC-INLINE or 0, WA-START(1) and WA-N(1) the slice of the pool that holds, for each template, its cache row of STRUCT-TPL-LOAD, its weight, the number of rotations
*> and their codes; FD-BAD when a template file is absent or unsupported or a field is invalid). FR-TEMPLATE places one: nextInt(total weight) picks the template, nextInt(rotations) the rotation,
*> origin = pos + unit(rotate(WEST)) * (size.x / 2) + unit(rotate(NORTH)) * (size.z / 2), then placeInWorld with flags 3 (core/src/struct-tpl-place.cob) over the level of the feature stage.
*> The settings' shared random draws nextInt(palette count) for the palette pick (one draw for a template with one palette); the pick itself stays the positional one of STRUCT-PALETTE-PICK,
*> so a template with several palettes is not exact. Deviations: the processors get no shared random (the processors of the data are deterministic rules), PS-SEED is 0, and the block entity
*> modifier append_loot of the suspicious sand is not carried (the generation channel holds containers and spawners only). The template root is SD-DIR of the structure data when it is set, else
*> the folder of FD-SET-DIR.
*>
*> Entry points: FD-TEMPLATE-NODE USING doc, node, row out; FR-TEMPLATE USING state, feature, x, y, z, result out (STRUCT-PLACE's result).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TEMPLATE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-ID                  PIC X(96).
 01 WS-ROOT                PIC X(1100).
 01 WS-TROW                BINARY-LONG.
 01 WS-NROT                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PROC                BINARY-LONG.
 01 WS-HOLD.
    05 WS-HOLD-ENTRY OCCURS 16 TIMES.
       10 WS-H-ROW         BINARY-LONG.
       10 WS-H-WEIGHT      BINARY-LONG.
       10 WS-H-NROT        BINARY-LONG.
       10 WS-H-ROT         BINARY-LONG OCCURS 4 TIMES.
 01 WS-K-TEMPLATES         PIC X(40) VALUE "templates".
 01 WS-K-ID                PIC X(40) VALUE "id".
 01 WS-K-ROTATIONS         PIC X(40) VALUE "rotations".
 01 WS-K-PROCESSORS        PIC X(40) VALUE "processors".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     IF SD-DIR = SPACES
         MOVE FD-DIR TO WS-ROOT
     ELSE
         MOVE SD-DIR TO WS-ROOT
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TEMPLATES WS-E
     MOVE 0 TO WS-COUNT WS-TOTAL
     IF WS-E = 0 OR JN-TYPE(WS-E) NOT = JT-ARRAY OR JN-COUNT(WS-E) < 1 OR JN-COUNT(WS-E) > 16
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
         CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-DATA WS-D
         CALL "FD-J-STRING" USING JSON-DOC WS-K-ID WS-D WS-TEXT WS-LEN
         MOVE WS-TEXT TO WS-ID
         CALL "STRUCT-TPL-LOAD" USING WS-ROOT WS-ID WS-TROW
         IF WS-LEN = 0 OR WS-TROW < 1
             MOVE 1 TO FD-BAD
             MOVE 0 TO WS-TROW
         ELSE
             IF TP-STATUS(WS-TROW) NOT = 1
                 MOVE 1 TO FD-BAD
             END-IF
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-WEIGHT WS-W
         CALL "FD-J-INT" USING JSON-DOC WS-W WS-R WS-OK
         IF WS-OK = 0 OR WS-R < 0
             MOVE 1 TO FD-BAD
             MOVE 0 TO WS-R
         END-IF
         ADD 1 TO WS-COUNT
         MOVE WS-TROW TO WS-H-ROW(WS-COUNT)
         MOVE WS-R TO WS-H-WEIGHT(WS-COUNT)
         ADD WS-R TO WS-TOTAL
*>       the rotations of the entry (NONE 0, CLOCKWISE_90 1, CLOCKWISE_180 2, COUNTERCLOCKWISE_90 3)
         CALL "FD-J-MEMBER" USING JSON-DOC WS-D WS-K-ROTATIONS WS-W
         IF WS-W = 0
             MOVE 4 TO WS-H-NROT(WS-COUNT)
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 COMPUTE WS-H-ROT(WS-COUNT, WS-J) = WS-J - 1
             END-PERFORM
         ELSE
             MOVE 0 TO WS-H-NROT(WS-COUNT)
             IF JN-TYPE(WS-W) NOT = JT-ARRAY OR JN-COUNT(WS-W) < 1 OR JN-COUNT(WS-W) > 4
                 MOVE 1 TO FD-BAD
             ELSE
                 PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= JN-COUNT(WS-W)
                     CALL "JSON-ELEMENT" USING JSON-DOC WS-W WS-J WS-NROT
                     CALL "FD-J-STRING-OF" USING JSON-DOC WS-NROT WS-TEXT
                     EVALUATE FUNCTION TRIM(WS-TEXT)
                         WHEN "none"
                         WHEN "minecraft:none"
                             MOVE 0 TO WS-CODE
                         WHEN "clockwise_90"
                         WHEN "minecraft:clockwise_90"
                             MOVE 1 TO WS-CODE
                         WHEN "180"
                         WHEN "clockwise_180"
                         WHEN "minecraft:180"
                         WHEN "minecraft:clockwise_180"
                             MOVE 2 TO WS-CODE
                         WHEN "counterclockwise_90"
                         WHEN "minecraft:counterclockwise_90"
                             MOVE 3 TO WS-CODE
                         WHEN OTHER
                             MOVE 0 TO WS-CODE
                             MOVE 1 TO FD-BAD
                     END-EVALUATE
                     ADD 1 TO WS-H-NROT(WS-COUNT)
                     MOVE WS-CODE TO WS-H-ROT(WS-COUNT, WS-H-NROT(WS-COUNT))
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     IF WS-TOTAL < 1
         MOVE 1 TO FD-BAD
     END-IF
     COMPUTE WA-START(WS-ROW, 1) = FD-POOL-COUNT + 1
     MOVE WS-COUNT TO WA-N(WS-ROW, 1)
     MOVE WS-TOTAL TO WA-I(WS-ROW, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "FD-POOL-ADD" USING WS-H-ROW(WS-I) WS-IDX
         CALL "FD-POOL-ADD" USING WS-H-WEIGHT(WS-I) WS-IDX
         CALL "FD-POOL-ADD" USING WS-H-NROT(WS-I) WS-IDX
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-H-NROT(WS-I)
             CALL "FD-POOL-ADD" USING WS-H-ROT(WS-I, WS-J) WS-IDX
         END-PERFORM
     END-PERFORM
*>   the optional inline processors
     MOVE 0 TO WS-PROC
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PROCESSORS WS-E
     IF WS-E > 0
         CALL "STRUCT-PROC-INLINE" USING JSON-DOC WS-E WS-PROC
         IF WS-PROC = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     MOVE WS-PROC TO WA-I(WS-ROW, 2)
     GOBACK.
 END PROGRAM FD-TEMPLATE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TEMPLATE.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-TROW                BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-NROT                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-PALETTES            BINARY-LONG.
 01 WS-HALF-X              BINARY-LONG.
 01 WS-HALF-Z              BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
*> the unit vectors (dx, dz) of WEST and of NORTH after each rotation code (0 NONE, 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90)
 01 WS-WEST-TABLE.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-WEST REDEFINES WS-WEST-TABLE.
    05 WS-W OCCURS 4 TIMES.
       10 WS-WDX           BINARY-LONG.
       10 WS-WDZ           BINARY-LONG.
 01 WS-NORTH-TABLE.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-NORTH REDEFINES WS-NORTH-TABLE.
    05 WS-N OCCURS 4 TIMES.
       10 WS-NDX           BINARY-LONG.
       10 WS-NDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE WA-I(WS-ROW, 1) TO WS-TOTAL
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TOTAL WS-DRAW
*>   the entry whose running weight first exceeds the draw (WeightedList.getRandom)
     MOVE WA-START(WS-ROW, 1) TO WS-P
     MOVE 0 TO WS-RUN WS-CHOSEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WA-N(WS-ROW, 1)
         MOVE FD-POOL(WS-P) TO WS-TROW
         MOVE FD-POOL(WS-P + 1) TO WS-WEIGHT
         MOVE FD-POOL(WS-P + 2) TO WS-NROT
         ADD WS-WEIGHT TO WS-RUN
         IF WS-CHOSEN = 0 AND WS-DRAW < WS-RUN
             MOVE WS-I TO WS-CHOSEN
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-NROT WS-DRAW
             MOVE FD-POOL(WS-P + 3 + WS-DRAW) TO WS-ROT
             MOVE WS-TROW TO WS-CHOSEN
         END-IF
         COMPUTE WS-P = WS-P + 3 + WS-NROT
     END-PERFORM
     MOVE WS-CHOSEN TO WS-TROW
     COMPUTE WS-HALF-X = TP-SX(WS-TROW) / 2
     COMPUTE WS-HALF-Z = TP-SZ(WS-TROW) / 2
     COMPUTE WS-OX = L-X + WS-WDX(WS-ROT + 1) * WS-HALF-X + WS-NDX(WS-ROT + 1) * WS-HALF-Z
     MOVE L-Y TO WS-OY
     COMPUTE WS-OZ = L-Z + WS-WDZ(WS-ROT + 1) * WS-HALF-X + WS-NDZ(WS-ROT + 1) * WS-HALF-Z
*>   the settings' random picks the palette: one draw per template (the pick of STRUCT-PLACE stays positional)
     MOVE TP-PALETTES(WS-TROW) TO WS-PALETTES
     IF WS-PALETTES > 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-PALETTES WS-DRAW
     END-IF
     MOVE WS-OX TO WS-AX
     MOVE WS-OY TO WS-AY
     MOVE WS-OZ TO WS-AZ
     INITIALIZE STRUCT-SETTINGS
     MOVE WS-ROT TO PS-ROTATION
     MOVE WA-I(WS-ROW, 2) TO PS-PROCESSORS
     CALL "STRUCT-PLACE" USING WS-TROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS L-RESULT
     GOBACK.
 END PROGRAM FR-TEMPLATE.
