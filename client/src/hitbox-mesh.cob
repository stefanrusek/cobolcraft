*> The entity hitboxes of F3+B (13 section 5.1 key; 34-1 section 7.5 EntityHitboxDebugRenderer): for every entity of the replica a white box outline of its
*> bounding box (centred on x and z, from the feet up) and, for a living entity, a red thin box at the eye height (eyeHeight +- 0.01 above the feet, the
*> extent of the bounding box on x and z). Eye-relative, on the white swatch of the UI atlas, translucent pipeline with depth test like the block outline.
*> What the docs leave open is listed in specs/002-client-polish/tasks/lanes/featshitbox.md (view-direction line, line width, depth behaviour, the
*> point at the entity position, the vehicle box, the dragon sub-boxes, invisibility and frustum tests, the chat line): this file draws the specified parts only.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HITBOX-BOX.
*> USING CLIENT-STATE, low corner (3 FLOAT-LONG), high corner (3 FLOAT-LONG), colour (3 FLOAT-SHORT: red, green, blue): the outline of one box (eye-relative
*> corners) as on each of the six faces four strips 1/32 block wide along its edges (as the block outline, HIGHLIGHT-MESH; a strip is never wider than the box
*> side it lies on): 24 quads, 144 vertices appended to RL-HB-VERTEX; a box that does not fit in CL-MAX-HB-VERTICES is left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-W                   FLOAT-LONG VALUE 0.03125.
 01 WS-A                   BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-STRIP               BINARY-LONG.
 01 WS-U-AXIS              BINARY-LONG.
 01 WS-V-AXIS              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-EXT                 FLOAT-LONG.
 01 WS-WU                  FLOAT-LONG.
 01 WS-WV                  FLOAT-LONG.
 01 WS-U0                  FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-P                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CORNERS             PIC X(6) VALUE "123134".
 01 WS-TU                  FLOAT-SHORT.
 01 WS-TV                  FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LO-TABLE.
    05 L-LO                FLOAT-LONG OCCURS 3 TIMES.
 01 L-HI-TABLE.
    05 L-HI                FLOAT-LONG OCCURS 3 TIMES.
 01 L-RGB-TABLE.
    05 L-RGB               FLOAT-SHORT OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-LO-TABLE L-HI-TABLE L-RGB-TABLE.
     IF RL-HB-COUNT + 144 <= CL-MAX-HB-VERTICES
         COMPUTE WS-TU = 4 / UA-W
         COMPUTE WS-TV = (UA-H - 4) / UA-H
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-U-AXIS = FUNCTION MOD(WS-A, 3) + 1
             COMPUTE WS-V-AXIS = FUNCTION MOD(WS-A + 1, 3) + 1
             COMPUTE WS-EXT = L-HI(WS-U-AXIS) - L-LO(WS-U-AXIS)
             COMPUTE WS-WU = FUNCTION MIN(WS-W, WS-EXT)
             COMPUTE WS-EXT = L-HI(WS-V-AXIS) - L-LO(WS-V-AXIS)
             COMPUTE WS-WV = FUNCTION MIN(WS-W, WS-EXT)
             PERFORM VARYING WS-SIDE FROM 0 BY 1 UNTIL WS-SIDE > 1
                 PERFORM VARYING WS-STRIP FROM 1 BY 1 UNTIL WS-STRIP > 4
*>                   The strip's rectangle in the face's two other axes.
                     MOVE L-LO(WS-U-AXIS) TO WS-U0
                     MOVE L-HI(WS-U-AXIS) TO WS-U1
                     MOVE L-LO(WS-V-AXIS) TO WS-V0
                     MOVE L-HI(WS-V-AXIS) TO WS-V1
                     EVALUATE WS-STRIP
                         WHEN 1
                             COMPUTE WS-U1 = WS-U0 + WS-WU
                         WHEN 2
                             COMPUTE WS-U0 = WS-U1 - WS-WU
                         WHEN 3
                             COMPUTE WS-V1 = WS-V0 + WS-WV
                         WHEN 4
                             COMPUTE WS-V0 = WS-V1 - WS-WV
                     END-EVALUATE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                         MOVE FUNCTION NUMVAL(WS-CORNERS(WS-K:1)) TO WS-C
                         COMPUTE WS-P(WS-A) = L-LO(WS-A) + WS-SIDE * (L-HI(WS-A) - L-LO(WS-A))
                         MOVE WS-U0 TO WS-P(WS-U-AXIS)
                         IF WS-C = 2 OR WS-C = 3
                             MOVE WS-U1 TO WS-P(WS-U-AXIS)
                         END-IF
                         MOVE WS-V0 TO WS-P(WS-V-AXIS)
                         IF WS-C >= 3
                             MOVE WS-V1 TO WS-P(WS-V-AXIS)
                         END-IF
                         ADD 1 TO RL-HB-COUNT
                         MOVE WS-P(1) TO RL-HB-X(RL-HB-COUNT)
                         MOVE WS-P(2) TO RL-HB-Y(RL-HB-COUNT)
                         MOVE WS-P(3) TO RL-HB-Z(RL-HB-COUNT)
                         MOVE WS-TU TO RL-HB-U(RL-HB-COUNT)
                         MOVE WS-TV TO RL-HB-V(RL-HB-COUNT)
                         MOVE 1 TO RL-HB-B(RL-HB-COUNT) RL-HB-A(RL-HB-COUNT)
                         MOVE 0 TO RL-HB-SKY(RL-HB-COUNT)
                         MOVE L-RGB(1) TO RL-HB-R(RL-HB-COUNT)
                         MOVE L-RGB(2) TO RL-HB-G(RL-HB-COUNT)
                         MOVE L-RGB(3) TO RL-HB-BLUE(RL-HB-COUNT)
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM HITBOX-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HITBOX-MESH.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG): fills RL-HB-VERTEX / RL-HB-COUNT for every used row of the replica that has a known box. A row of a standard world
*> (EN-VANILLA 1) has its box from the registry (EN-BOX-HALF, EN-BOX-HEIGHT, 21 section 2), its eye height 0.85 x height (21 section 2 "Eye" default;
*> 1.62 for "player") and is living unless it is a boat, raft, minecart or end crystal; a row with a zero height has no box. A row of a stand-in world
*> has the box and eye height of standin-content section 3 (operator 0.6 x 1.8 eye 1.62, loose_item 0.25 x 0.25 eye 0.2125, sodgrazer 0.9 x 0.9 eye 0.7,
*> abend 0.75 x 0.75 eye 0.5; the loose item is not living); any other stand-in type has none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 01 WS-ET                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EYE-H               FLOAT-LONG.
 01 WS-LO-TABLE.
    05 WS-LO               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI-TABLE.
    05 WS-HI               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RGB-TABLE.
    05 WS-RGB              FLOAT-SHORT OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE.
     MOVE 0 TO RL-HB-COUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         MOVE 0 TO WS-KNOWN WS-LIVING
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 1
             MOVE EN-BOX-HALF(WS-R) TO WS-HALF
             MOVE EN-BOX-HEIGHT(WS-R) TO WS-HEIGHT
             COMPUTE WS-EYE-H = 0.85 * WS-HEIGHT
             MOVE EN-KEY(WS-R) TO WS-KEY
             IF WS-KEY = "player"
                 MOVE 1.62 TO WS-EYE-H
             END-IF
             MOVE 0 TO WS-N
             INSPECT WS-KEY TALLYING WS-N FOR ALL "boat" ALL "raft" ALL "minecart" ALL "end_crystal"
             IF EN-BOX-ATTACK(WS-R) = 1 AND WS-N = 0
                 MOVE 1 TO WS-LIVING
             END-IF
             IF WS-HEIGHT > 0
                 MOVE 1 TO WS-KNOWN
             END-IF
         END-IF
         IF EN-USED(WS-R) = 1 AND EN-VANILLA(WS-R) = 0
             COMPUTE WS-ET = EN-TYPE(WS-R) + 1
             EVALUATE WS-ET
                 WHEN 1
                     MOVE 0.3 TO WS-HALF
                     MOVE 1.8 TO WS-HEIGHT
                     MOVE 1.62 TO WS-EYE-H
                     MOVE 1 TO WS-KNOWN WS-LIVING
                 WHEN 2
                     MOVE 0.125 TO WS-HALF
                     MOVE 0.25 TO WS-HEIGHT
                     MOVE 0.2125 TO WS-EYE-H
                     MOVE 1 TO WS-KNOWN
                 WHEN 3
                     MOVE 0.45 TO WS-HALF
                     MOVE 0.9 TO WS-HEIGHT
                     MOVE 0.7 TO WS-EYE-H
                     MOVE 1 TO WS-KNOWN WS-LIVING
                 WHEN 4
                     MOVE 0.375 TO WS-HALF
                     MOVE 0.75 TO WS-HEIGHT
                     MOVE 0.5 TO WS-EYE-H
                     MOVE 1 TO WS-KNOWN WS-LIVING
             END-EVALUATE
         END-IF
         IF WS-KNOWN = 1
             COMPUTE WS-LO(1) = EN-X(WS-R) - WS-HALF - L-EYE(1)
             COMPUTE WS-HI(1) = EN-X(WS-R) + WS-HALF - L-EYE(1)
             COMPUTE WS-LO(2) = EN-Y(WS-R) - L-EYE(2)
             COMPUTE WS-HI(2) = EN-Y(WS-R) + WS-HEIGHT - L-EYE(2)
             COMPUTE WS-LO(3) = EN-Z(WS-R) - WS-HALF - L-EYE(3)
             COMPUTE WS-HI(3) = EN-Z(WS-R) + WS-HALF - L-EYE(3)
             MOVE 1 TO WS-RGB(1) WS-RGB(2) WS-RGB(3)
             CALL "HITBOX-BOX" USING CLIENT-STATE WS-LO-TABLE WS-HI-TABLE WS-RGB-TABLE
             IF WS-LIVING = 1
                 COMPUTE WS-LO(2) = EN-Y(WS-R) + WS-EYE-H - 0.01 - L-EYE(2)
                 COMPUTE WS-HI(2) = EN-Y(WS-R) + WS-EYE-H + 0.01 - L-EYE(2)
                 MOVE 1 TO WS-RGB(1)
                 MOVE 0 TO WS-RGB(2) WS-RGB(3)
                 CALL "HITBOX-BOX" USING CLIENT-STATE WS-LO-TABLE WS-HI-TABLE WS-RGB-TABLE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HITBOX-MESH.
