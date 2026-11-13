*> The mesh of the fluid in a cell (29a-fluids.md section 10, FluidRenderer.tesselate). MESH-SECTION calls MESH-FLUID for a cell
*> whose state holds water or lava (ST-FLUID of the state tables); the quads come back in FLUID-OUT (CLFLUID.cpy) and are added
*> to the section's meshes. Faces (10.1): the top when the cell above holds another fluid (or none), a side or the bottom when its
*> neighbour is not the same fluid and not opaque. Corner heights (10.2) are the core's FM-CORNERS over the heights of the eight
*> horizontal neighbours (a same-fluid neighbour 1.0 under the same fluid, else amount / 9; any other 0.0, or -1.0 when opaque).
*> Geometry (10.3): the top 0.001 below its corner heights with the still sprite, or with the flowing sprite turned by the flow
*> vector of 1.4 (FM-TOP-UV); the sides (flowing sprite, u 0 to 0.5, v from (1 - height) / 2 to 0.5) from the floor (0.001 when the
*> bottom is drawn) up to their corner heights, inset 0.001; no backward copy of the top (the pipeline does not cull). Colour and
*> light (10.4): the biome water colour for water, white for lava, the larger of the cell's light and the light above for every
*> face times the factor of its direction. Beside a block of the overlay classes (ST-OVERLAY) the water's side takes the overlay sprite. Not done (gap): the partial-shape
*> occlusion of a neighbour (the client has no shape of a state: an opaque neighbour hides, any other does not).
*> MESH-FLUID USING CLIENT-STATE, row, x, y (row y from the dimension's bottom), z, section y, dimension height, state id, FLUID-OUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MESH-FLUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLTINTQ.
 01 WS-DXS.
    05 WS-DX               PIC S9 OCCURS 10 TIMES.   *> north south east west north-east north-west south-east south-west up down
 01 WS-DYS.
    05 WS-DY               PIC S9 OCCURS 10 TIMES.
 01 WS-DZS.
    05 WS-DZ               PIC S9 OCCURS 10 TIMES.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-FACE-OF             PIC X(4) VALUE "3465".     *> the face (1 top, 2 bottom, 3 north, 4 south, 5 west, 6 east) of neighbours 1 to 4
 01 WS-FACE-MAP REDEFINES WS-FACE-OF.
    05 WS-FM               PIC 9 OCCURS 4 TIMES.
 01 WS-NB-OF               PIC X(4) VALUE "1243".     *> the neighbour (1 north, 2 south, 3 east, 4 west) of the faces 3 to 6
 01 WS-NB-MAP REDEFINES WS-NB-OF.
    05 WS-NBV              PIC 9 OCCURS 4 TIMES.
 01 WS-FACTORS.
    05 FILLER PIC 9V9 VALUE 1.0.
    05 FILLER PIC 9V9 VALUE 0.5.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.8.
    05 FILLER PIC 9V9 VALUE 0.6.
    05 FILLER PIC 9V9 VALUE 0.6.
 01 WS-FACTOR-TABLE REDEFINES WS-FACTORS.
    05 WS-FACTOR           PIC 9V9 OCCURS 6 TIMES.
 01 WS-NAMES.
    05 FILLER PIC X(32) VALUE "minecraft:block/water_still".
    05 FILLER PIC X(32) VALUE "minecraft:block/water_flow".
    05 FILLER PIC X(32) VALUE "minecraft:block/water_overlay".
    05 FILLER PIC X(32) VALUE "minecraft:block/lava_still".
    05 FILLER PIC X(32) VALUE "minecraft:block/lava_flow".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-SNAME            PIC X(32) OCCURS 5 TIMES.
 01 WS-SPRITES.
    05 WS-SP OCCURS 5 TIMES.
       10 WS-SP-ID         BINARY-LONG VALUE 0.
       10 WS-SP-SEEN       BINARY-LONG VALUE -1.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-OWN                 FLOAT-LONG.
 01 WS-CENTRE              FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-NONE                BINARY-LONG.
 01 WS-NEIGHBOURS.
    05 WS-N OCCURS 10 TIMES.
       10 WS-N-STATE       BINARY-LONG.
       10 WS-N-SKY         BINARY-LONG.
       10 WS-N-BLOCK       BINARY-LONG.
       10 WS-N-KIND        BINARY-LONG.
       10 WS-N-OPAQUE      BINARY-LONG.
       10 WS-N-OVERLAY     BINARY-LONG.
       10 WS-N-OWN         FLOAT-LONG.
       10 WS-N-H           FLOAT-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-A-STATE             BINARY-LONG.
 01 WS-A-SKY               BINARY-LONG.
 01 WS-A-BLOCK             BINARY-LONG.
 01 WS-A-KIND              BINARY-LONG.
 01 WS-A-AMOUNT            BINARY-LONG.
 01 WS-NAMT                BINARY-LONG.
 01 WS-OWN-STATE           BINARY-LONG.
 01 WS-OWN-SKY             BINARY-LONG.
 01 WS-OWN-BLOCK           BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DRAW.
    05 WS-DR               BINARY-LONG OCCURS 6 TIMES.
 01 WS-HN                  FLOAT-LONG.
 01 WS-HS                  FLOAT-LONG.
 01 WS-HE                  FLOAT-LONG.
 01 WS-HW                  FLOAT-LONG.
 01 WS-HNE                 FLOAT-LONG.
 01 WS-HNW                 FLOAT-LONG.
 01 WS-HSE                 FLOAT-LONG.
 01 WS-HSW                 FLOAT-LONG.
 01 WS-CNE                 FLOAT-LONG.
 01 WS-CNW                 FLOAT-LONG.
 01 WS-CSE                 FLOAT-LONG.
 01 WS-CSW                 FLOAT-LONG.
 01 WS-MIN                 FLOAT-LONG.
 01 WS-SUMX                FLOAT-LONG.
 01 WS-SUMZ                FLOAT-LONG.
 01 WS-DELTA               FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-FLOWX               FLOAT-LONG.
 01 WS-FLOWZ               FLOAT-LONG.
 01 WS-STILL               BINARY-LONG.
 01 WS-UV.
    05 WS-UVE              FLOAT-LONG OCCURS 8 TIMES.
 01 WS-TR                  FLOAT-SHORT.
 01 WS-TG                  FLOAT-SHORT.
 01 WS-TB                  FLOAT-SHORT.
 01 WS-CH                  BINARY-DOUBLE.
 01 WS-F                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SPR                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-NSPR                BINARY-LONG.
 01 WS-FLOOR               FLOAT-LONG.
 01 WS-HA                  FLOAT-LONG.
 01 WS-HB                  FLOAT-LONG.
 01 WS-PCORNER.
    05 WS-PC OCCURS 4 TIMES.
       10 WS-PX            FLOAT-LONG.
       10 WS-PY            FLOAT-LONG.
       10 WS-PZ            FLOAT-LONG.
       10 WS-PU            FLOAT-LONG.
       10 WS-PV            FLOAT-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-UOUT                FLOAT-SHORT.
 01 WS-VOUT                FLOAT-SHORT.
 01 WS-E                   FLOAT-LONG VALUE 0.001.
 01 WS-HSRC                FLOAT-LONG VALUE 0.8888889.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLFLUID.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LY                   BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-X L-Y L-Z L-LY L-HEIGHT L-STATE FLUID-OUT.
     MOVE 0 TO FO-COUNT
     IF WS-READY = 0
         MOVE 0 TO WS-DX(1) WS-DX(2) WS-DX(9) WS-DX(10)
         MOVE 1 TO WS-DX(3) WS-DX(5) WS-DX(7)
         MOVE -1 TO WS-DX(4) WS-DX(6) WS-DX(8)
         MOVE 0 TO WS-DZ(3) WS-DZ(4) WS-DZ(9) WS-DZ(10)
         MOVE -1 TO WS-DZ(1) WS-DZ(5) WS-DZ(6)
         MOVE 1 TO WS-DZ(2) WS-DZ(7) WS-DZ(8)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             MOVE 0 TO WS-DY(WS-I)
         END-PERFORM
         MOVE 1 TO WS-DY(9)
         MOVE -1 TO WS-DY(10)
         MOVE 1 TO WS-READY
     END-IF
*>   What the cell holds: the fluid kind (1 water, 2 lava; a block that is always wet counts as water) and its amount (8 for a
*>   source and for a falling column, 8 - level for levels 1 to 7).
     MOVE ST-FLUID(L-STATE + 1) TO WS-KIND
     IF WS-KIND > 2
         MOVE 1 TO WS-KIND
     END-IF
     MOVE ST-LEVEL(L-STATE + 1) TO WS-LEVEL
     MOVE 8 TO WS-AMOUNT
     IF WS-LEVEL > 0 AND WS-LEVEL < 8
         COMPUTE WS-AMOUNT = 8 - WS-LEVEL
     END-IF
     COMPUTE WS-OWN = WS-AMOUNT / 9
     INITIALIZE WS-DRAW
     MOVE 0 TO WS-NONE
*>   The neighbours: pass 1 the four sides, the cell above and below (face selection, 10.1); pass 2, only when a face is
*>   drawn, the four diagonals and the heights of the eight (the corner heights, 10.2): a cell with nothing to draw costs six reads.
     MOVE 1 TO MB-LIGHT-OFF
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2 OR WS-NONE = 1
         IF WS-PASS = 2
*>           A face is to be drawn: the light of the first look's cells is read now (the six reads of pass 1 had states only).
             MOVE 0 TO MB-LIGHT-OFF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
                 IF WS-I < 5 OR WS-I > 8
                     COMPUTE WS-NX = L-X + WS-DX(WS-I)
                     COMPUTE WS-NY = L-Y + WS-DY(WS-I)
                     COMPUTE WS-NZ = L-Z + WS-DZ(WS-I)
                     CALL "MF-AT" USING CLIENT-STATE L-ROW L-HEIGHT WS-NX WS-NY WS-NZ WS-N-STATE(WS-I)
                         WS-N-SKY(WS-I) WS-N-BLOCK(WS-I)
                 END-IF
             END-PERFORM
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
             IF (WS-PASS = 1 AND (WS-I < 5 OR WS-I > 8)) OR (WS-PASS = 2 AND WS-I > 4 AND WS-I < 9)
                 COMPUTE WS-NX = L-X + WS-DX(WS-I)
                 COMPUTE WS-NY = L-Y + WS-DY(WS-I)
                 COMPUTE WS-NZ = L-Z + WS-DZ(WS-I)
                 CALL "MF-AT" USING CLIENT-STATE L-ROW L-HEIGHT WS-NX WS-NY WS-NZ WS-N-STATE(WS-I)
                     WS-N-SKY(WS-I) WS-N-BLOCK(WS-I)
                 MOVE ST-FLUID(WS-N-STATE(WS-I) + 1) TO WS-N-KIND(WS-I)
                 IF WS-N-KIND(WS-I) > 2
                     MOVE 1 TO WS-N-KIND(WS-I)
                 END-IF
                 MOVE ST-OPAQUE(WS-N-STATE(WS-I) + 1) TO WS-N-OPAQUE(WS-I)
                 MOVE ST-OVERLAY(WS-N-STATE(WS-I) + 1) TO WS-N-OVERLAY(WS-I)
             END-IF
*>           In pass 2, for each side and diagonal: its render height (1.0 under the same fluid, else its own height; another fluid or
*>           none 0.0, an opaque block -1.0) and its own height (the flow of 1.4).
             IF WS-PASS = 2 AND WS-I < 9
                 COMPUTE WS-NX = L-X + WS-DX(WS-I)
                 COMPUTE WS-NY = L-Y + 1
                 COMPUTE WS-NZ = L-Z + WS-DZ(WS-I)
                 MOVE 0 TO WS-N-OWN(WS-I)
                 MOVE 0.0 TO WS-N-H(WS-I)
                 IF WS-N-OPAQUE(WS-I) = 1
                     MOVE -1.0 TO WS-N-H(WS-I)
                 END-IF
                 IF WS-N-KIND(WS-I) = WS-KIND
                     MOVE 8 TO WS-NAMT
                     MOVE ST-LEVEL(WS-N-STATE(WS-I) + 1) TO WS-A-AMOUNT
                     IF WS-A-AMOUNT > 0 AND WS-A-AMOUNT < 8
                         COMPUTE WS-NAMT = 8 - WS-A-AMOUNT
                     END-IF
                     COMPUTE WS-N-OWN(WS-I) = WS-NAMT / 9
                     MOVE WS-N-OWN(WS-I) TO WS-N-H(WS-I)
                     CALL "MF-AT" USING CLIENT-STATE L-ROW L-HEIGHT WS-NX WS-NY WS-NZ WS-A-STATE WS-A-SKY
                         WS-A-BLOCK
                     MOVE ST-FLUID(WS-A-STATE + 1) TO WS-A-KIND
                     IF WS-A-KIND > 2
                         MOVE 1 TO WS-A-KIND
                     END-IF
                     IF WS-A-KIND = WS-KIND
                         MOVE 1.0 TO WS-N-H(WS-I)
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-PASS = 1
*>           Face selection (10.1): the top when the fluid above is another one, a side or the bottom when its neighbour is
*>           not the same fluid and not opaque.
             IF WS-N-KIND(9) NOT = WS-KIND
                 MOVE 1 TO WS-DR(1)
             END-IF
             IF WS-N-KIND(10) NOT = WS-KIND AND WS-N-OPAQUE(10) = 0
                 MOVE 1 TO WS-DR(2)
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 IF WS-N-KIND(WS-I) NOT = WS-KIND AND WS-N-OPAQUE(WS-I) = 0
                     MOVE 1 TO WS-DR(WS-FM(WS-I))
                 END-IF
             END-PERFORM
             IF WS-DR(1) + WS-DR(2) + WS-DR(3) + WS-DR(4) + WS-DR(5) + WS-DR(6) = 0
                 MOVE 1 TO WS-NONE
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO MB-LIGHT-OFF
     IF WS-NONE = 1
         GOBACK
     END-IF
*>   Corner heights (10.2): the centre is full under the same fluid.
     MOVE WS-OWN TO WS-CENTRE
     IF WS-N-KIND(9) = WS-KIND
         MOVE 1.0 TO WS-CENTRE
     END-IF
     MOVE WS-N-H(1) TO WS-HN
     MOVE WS-N-H(2) TO WS-HS
     MOVE WS-N-H(3) TO WS-HE
     MOVE WS-N-H(4) TO WS-HW
     MOVE WS-N-H(5) TO WS-HNE
     MOVE WS-N-H(6) TO WS-HNW
     MOVE WS-N-H(7) TO WS-HSE
     MOVE WS-N-H(8) TO WS-HSW
     CALL "FM-CORNERS" USING WS-CENTRE WS-HN WS-HS WS-HE WS-HW WS-HNE WS-HNW WS-HSE WS-HSW WS-CNE WS-CNW WS-CSE WS-CSW
*>   A block above hides the top face when every corner is full.
     COMPUTE WS-MIN = FUNCTION MIN(WS-CNE, WS-CNW, WS-CSE, WS-CSW)
     IF WS-N-OPAQUE(9) = 1 AND WS-MIN >= 1
         MOVE 0 TO WS-DR(1)
     END-IF
*>   The flow vector (1.4) of the horizontal neighbours' own heights; a neighbour of another fluid does not count, an empty one
*>   that does not block counts the drop to the same fluid below it.
     MOVE 0 TO WS-SUMX WS-SUMZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-N-KIND(WS-I) = 0 OR WS-N-KIND(WS-I) = WS-KIND
             MOVE 0 TO WS-DELTA
             IF WS-N-OWN(WS-I) > 0
                 COMPUTE WS-DELTA = WS-OWN - WS-N-OWN(WS-I)
             END-IF
             IF WS-N-OWN(WS-I) = 0 AND WS-N-OPAQUE(WS-I) = 0
                 COMPUTE WS-NX = L-X + WS-DX(WS-I)
                 COMPUTE WS-NY = L-Y - 1
                 COMPUTE WS-NZ = L-Z + WS-DZ(WS-I)
                 CALL "MF-AT" USING CLIENT-STATE L-ROW L-HEIGHT WS-NX WS-NY WS-NZ WS-A-STATE WS-A-SKY WS-A-BLOCK
                 MOVE ST-FLUID(WS-A-STATE + 1) TO WS-A-KIND
                 IF WS-A-KIND > 2
                     MOVE 1 TO WS-A-KIND
                 END-IF
                 IF WS-A-KIND = WS-KIND
                     MOVE 8 TO WS-NAMT
                     MOVE ST-LEVEL(WS-A-STATE + 1) TO WS-A-AMOUNT
                     IF WS-A-AMOUNT > 0 AND WS-A-AMOUNT < 8
                         COMPUTE WS-NAMT = 8 - WS-A-AMOUNT
                     END-IF
                     COMPUTE WS-DELTA = WS-OWN - (WS-NAMT / 9 - WS-HSRC)
                 END-IF
             END-IF
             COMPUTE WS-SUMX = WS-SUMX + WS-DX(WS-I) * WS-DELTA
             COMPUTE WS-SUMZ = WS-SUMZ + WS-DZ(WS-I) * WS-DELTA
         END-IF
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-SUMX * WS-SUMX + WS-SUMZ * WS-SUMZ)
     MOVE 0 TO WS-FLOWX WS-FLOWZ
     IF WS-LEN > 0.00001
         COMPUTE WS-FLOWX = WS-SUMX / WS-LEN
         COMPUTE WS-FLOWZ = WS-SUMZ / WS-LEN
     END-IF
*>   Light (10.4): the larger of the cell's and the cell above's, per channel, for every face.
     CALL "MF-AT" USING CLIENT-STATE L-ROW L-HEIGHT L-X L-Y L-Z WS-OWN-STATE WS-OWN-SKY WS-OWN-BLOCK
     COMPUTE WS-SKY = FUNCTION MAX(WS-OWN-SKY, WS-N-SKY(9))
     COMPUTE WS-BLOCK = FUNCTION MAX(WS-OWN-BLOCK, WS-N-BLOCK(9))
*>   Tint (10.4): the biome water colour, white for lava.
     MOVE 1 TO WS-TR WS-TG WS-TB
     IF WS-KIND = 1
         MOVE "water_cauldron" TO TQ-NAME
         MOVE 0 TO TQ-INDEX
         MOVE 1 TO TQ-MODE
         MOVE 0 TO TQ-HALF TQ-POWER TQ-AGE
         COMPUTE TQ-X = WR-CX(L-ROW) * 16 + L-X
         COMPUTE TQ-Y = L-Y + PL-MIN-Y
         COMPUTE TQ-Z = WR-CZ(L-ROW) * 16 + L-Z
         MOVE CL-TINT-RADIUS TO TQ-RADIUS
         MOVE 4294967295 TO TQ-COLOUR
         CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE TINT-QUERY
*>       A colour with no alpha (a colormap not loaded) is not applied.
         IF TQ-COLOUR >= 16777216
             COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR / 65536, 256)
             COMPUTE WS-TR = WS-CH / 255
             COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR / 256, 256)
             COMPUTE WS-TG = WS-CH / 255
             COMPUTE WS-CH = FUNCTION MOD(TQ-COLOUR, 256)
             COMPUTE WS-TB = WS-CH / 255
         END-IF
     END-IF
*>   The sprites (still and flowing) of the fluid, found in the atlas and remembered while the atlas keeps them.
     COMPUTE WS-BASE = 3 * (WS-KIND - 1)
     MOVE 2 TO WS-NSPR
     IF WS-KIND = 1
         MOVE 3 TO WS-NSPR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NSPR
         COMPUTE WS-C = WS-BASE + WS-I
         IF WS-SP-SEEN(WS-C) NOT = AT-SPRITE-COUNT
             MOVE -1 TO WS-SP-SEEN(WS-C)
         END-IF
         IF WS-SP-SEEN(WS-C) > 0 AND WS-SP-ID(WS-C) > 0
             IF AT-NAME(WS-SP-ID(WS-C)) NOT = WS-SNAME(WS-C)
                 MOVE -1 TO WS-SP-SEEN(WS-C)
             END-IF
         END-IF
         IF WS-SP-SEEN(WS-C) < 0
             MOVE WS-SNAME(WS-C) TO WS-ID
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-SNAME(WS-C))) TO WS-ID-LENGTH
             CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SP-ID(WS-C)
             MOVE AT-SPRITE-COUNT TO WS-SP-SEEN(WS-C)
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FLOOR
     IF WS-DR(2) = 1
         MOVE WS-E TO WS-FLOOR
     END-IF
*>   The quads (10.3): top, bottom, north, south, west, east; corners 1 and 3 are opposite.
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
         IF WS-DR(WS-F) = 1
             COMPUTE WS-C = WS-BASE + 1
             MOVE WS-SP-ID(WS-C) TO WS-SPR
             EVALUATE WS-F
                 WHEN 1
                     IF WS-FLOWX NOT = 0 OR WS-FLOWZ NOT = 0
                         COMPUTE WS-C = WS-BASE + 2
                         MOVE WS-SP-ID(WS-C) TO WS-SPR
                         CALL "FM-TOP-UV" USING WS-FLOWX WS-FLOWZ WS-STILL WS-UV
                         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                             COMPUTE WS-PU(WS-C) = WS-UVE(WS-C * 2 - 1) * 16
                             COMPUTE WS-PV(WS-C) = WS-UVE(WS-C * 2) * 16
                         END-PERFORM
                     ELSE
                         MOVE 0 TO WS-PU(1) WS-PU(2) WS-PV(1) WS-PV(4)
                         MOVE 16 TO WS-PU(3) WS-PU(4) WS-PV(2) WS-PV(3)
                     END-IF
                     MOVE 0 TO WS-PX(1) WS-PX(2) WS-PZ(1) WS-PZ(4)
                     MOVE 1 TO WS-PX(3) WS-PX(4) WS-PZ(2) WS-PZ(3)
                     COMPUTE WS-PY(1) = WS-CNW - WS-E
                     COMPUTE WS-PY(2) = WS-CSW - WS-E
                     COMPUTE WS-PY(3) = WS-CSE - WS-E
                     COMPUTE WS-PY(4) = WS-CNE - WS-E
                 WHEN 2
                     MOVE 0 TO WS-PU(1) WS-PU(2) WS-PV(1) WS-PV(4) WS-PX(1) WS-PX(2) WS-PZ(2) WS-PZ(3)
                     MOVE 16 TO WS-PU(3) WS-PU(4) WS-PV(2) WS-PV(3)
                     MOVE 1 TO WS-PX(3) WS-PX(4) WS-PZ(1) WS-PZ(4)
                     MOVE WS-E TO WS-PY(1) WS-PY(2) WS-PY(3) WS-PY(4)
                 WHEN OTHER
*>                   A side: corner 1 and 2 at the corner heights HA and HB, 3 and 4 at the floor; inset by 0.001.
                     COMPUTE WS-C = WS-BASE + 2
                     MOVE WS-SP-ID(WS-C) TO WS-SPR
*>                   Beside a block of the overlay classes the water takes its overlay sprite (when the atlas has it).
                     MOVE WS-NBV(WS-F - 2) TO WS-C
                     IF WS-KIND = 1 AND WS-N-OVERLAY(WS-C) = 1 AND WS-SP-ID(3) > 0
                         MOVE WS-SP-ID(3) TO WS-SPR
                     END-IF
                     EVALUATE WS-F
                         WHEN 3
                             MOVE WS-CNW TO WS-HA
                             MOVE WS-CNE TO WS-HB
                             MOVE 0 TO WS-PX(1) WS-PX(4)
                             MOVE 1 TO WS-PX(2) WS-PX(3)
                             MOVE WS-E TO WS-PZ(1) WS-PZ(2) WS-PZ(3) WS-PZ(4)
                         WHEN 4
                             MOVE WS-CSE TO WS-HA
                             MOVE WS-CSW TO WS-HB
                             MOVE 1 TO WS-PX(1) WS-PX(4)
                             MOVE 0 TO WS-PX(2) WS-PX(3)
                             COMPUTE WS-PZ(1) = 1 - WS-E
                             MOVE WS-PZ(1) TO WS-PZ(2) WS-PZ(3) WS-PZ(4)
                         WHEN 5
                             MOVE WS-CSW TO WS-HA
                             MOVE WS-CNW TO WS-HB
                             MOVE 1 TO WS-PZ(1) WS-PZ(4)
                             MOVE 0 TO WS-PZ(2) WS-PZ(3)
                             MOVE WS-E TO WS-PX(1) WS-PX(2) WS-PX(3) WS-PX(4)
                         WHEN OTHER
                             MOVE WS-CNE TO WS-HA
                             MOVE WS-CSE TO WS-HB
                             MOVE 0 TO WS-PZ(1) WS-PZ(4)
                             MOVE 1 TO WS-PZ(2) WS-PZ(3)
                             COMPUTE WS-PX(1) = 1 - WS-E
                             MOVE WS-PX(1) TO WS-PX(2) WS-PX(3) WS-PX(4)
                     END-EVALUATE
                     MOVE WS-HA TO WS-PY(1)
                     MOVE WS-HB TO WS-PY(2)
                     MOVE WS-FLOOR TO WS-PY(3) WS-PY(4)
                     MOVE 0 TO WS-PU(1) WS-PU(4)
                     MOVE 8 TO WS-PU(2) WS-PU(3) WS-PV(3) WS-PV(4)
                     COMPUTE WS-PV(1) = (1 - WS-HA) * 8
                     COMPUTE WS-PV(2) = (1 - WS-HB) * 8
             END-EVALUATE
             IF WS-SPR = 0
                 MOVE 1 TO WS-SPR
             END-IF
             ADD 1 TO FO-COUNT
             MOVE AT-TRANSLUCENT(WS-SPR) TO FO-TRANSLUCENT(FO-COUNT)
             COMPUTE FO-BRIGHT(FO-COUNT) = FUNCTION MAX(WS-FACTOR(WS-F) * WS-BLOCK / 15, 0.1)
             COMPUTE FO-SKY(FO-COUNT) = WS-FACTOR(WS-F) * WS-SKY / 15
             MOVE WS-TR TO FO-R(FO-COUNT)
             MOVE WS-TG TO FO-G(FO-COUNT)
             MOVE WS-TB TO FO-B(FO-COUNT)
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
                 COMPUTE FO-X(FO-COUNT, WS-C) = L-X + WS-PX(WS-C)
                 COMPUTE FO-Y(FO-COUNT, WS-C) = L-LY + WS-PY(WS-C)
                 COMPUTE FO-Z(FO-COUNT, WS-C) = L-Z + WS-PZ(WS-C)
                 MOVE WS-PU(WS-C) TO WS-U16
                 MOVE WS-PV(WS-C) TO WS-V16
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-SPR WS-U16 WS-V16 WS-UOUT WS-VOUT
                 MOVE WS-UOUT TO FO-U(FO-COUNT, WS-C)
                 MOVE WS-VOUT TO FO-V(FO-COUNT, WS-C)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MESH-FLUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MF-AT.
*> USING CLIENT-STATE, row, dimension height, x, y, z (x and z of the row or one beyond it, y from the dimension's bottom), state out,
*> sky light out, block light out: any cell near a row, from the row or the loaded row beside it (none loaded: void under full sky
*> light; above the world void under full sky light, below it void and dark), as MESH-CELL gives a neighbour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-NIB                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-HEIGHT L-X L-Y L-Z L-STATE L-SKY L-BLOCK.
     MOVE 0 TO L-STATE L-BLOCK
     MOVE 15 TO L-SKY
     MOVE L-X TO WS-NX
     MOVE L-Z TO WS-NZ
     MOVE WR-CX(L-ROW) TO WS-CX
     MOVE WR-CZ(L-ROW) TO WS-CZ
     MOVE L-ROW TO WS-ROW
     IF WS-NX < 0
         ADD 16 TO WS-NX
         SUBTRACT 1 FROM WS-CX
     END-IF
     IF WS-NX > 15
         SUBTRACT 16 FROM WS-NX
         ADD 1 TO WS-CX
     END-IF
     IF WS-NZ < 0
         ADD 16 TO WS-NZ
         SUBTRACT 1 FROM WS-CZ
     END-IF
     IF WS-NZ > 15
         SUBTRACT 16 FROM WS-NZ
         ADD 1 TO WS-CZ
     END-IF
     IF WS-CX NOT = WR-CX(L-ROW) OR WS-CZ NOT = WR-CZ(L-ROW)
         CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     END-IF
     EVALUATE TRUE
         WHEN L-Y < 0
             MOVE 0 TO L-SKY
         WHEN L-Y >= L-HEIGHT OR WS-ROW = 0
             CONTINUE
         WHEN OTHER
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
             COMPUTE WS-K = L-Y * 256 + WS-NZ * 16 + WS-NX
             MOVE CE-STATE(WS-K + 1) TO L-STATE
             IF MB-LIGHT-OFF = 1
                 MOVE 0 TO L-SKY L-BLOCK
                 GOBACK
             END-IF
             DIVIDE WS-K BY 2 GIVING WS-HALF REMAINDER WS-ODD
             MOVE CE-SKY(CE-LIGHT-BYTES + WS-HALF + 1) TO WS-BYTE
             IF WS-ODD = 0
                 DIVIDE WS-BYTE BY 16 GIVING WS-NIB REMAINDER L-SKY
             ELSE
                 DIVIDE WS-BYTE BY 16 GIVING L-SKY
             END-IF
             MOVE CE-BLOCK-LIGHT(CE-LIGHT-BYTES + WS-HALF + 1) TO WS-BYTE
             IF WS-ODD = 0
                 DIVIDE WS-BYTE BY 16 GIVING WS-NIB REMAINDER L-BLOCK
             ELSE
                 DIVIDE WS-BYTE BY 16 GIVING L-BLOCK
             END-IF
*>           CC-0007 stopgap (sky-stopgap.cob): the sky light assumed where the core sent none (0); remove with it.
             IF L-SKY = 0
                 CALL "SKY-STOPGAP-LIGHT" USING CLIENT-STATE WS-ROW WS-NX L-Y WS-NZ L-SKY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MF-AT.
