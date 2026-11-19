*> The block shape builder and the shape queries (docs/protocol/51-block-shapes.md; T4500 to T4503). BSH-BUILD fills the tables of
*> CTBSHAPE.cpy for every state of the open content set: the collision shape (what a body stands on and walks into) and the outline
*> shape (what a ray targets). The rules are by block class and property (CTBSDATA.cpy rows, interpreted here), so a lookup at run
*> time is two table reads. A block with no rule gets the default of 51 section 1.2: no collision when its flags hold noCollision
*> or air, else the full cube; the outline is the full cube except for air and liquids (empty).
*> Entry points:
*>   BSH-BUILD (no parameters): the tables from the open set (not again for a set type it has built); BSH-READY is 0 with no set open.
*>   BSH-COLL-ID, BSH-OUT-ID USING state id, shape id out (the full cube while the tables are not built).
*>   BSH-OVERLAPS USING shape id, cell x, y, z, box (6 FLOAT-LONG x1 y1 z1 x2 y2 z2 in blocks), hit out (1 when a box of the shape
*>     placed in that cell overlaps the box with positive volume, 1e-7 tolerance).
*>   BSH-TOP USING shape id, cell x, y, z, box, hit out, top out (FLOAT-LONG: the highest y of the shape boxes the box overlaps, the surface a body rests on).
*>   BSH-CLIP USING shape id, cell x, y, z, box, axis (1 x, 2 y, 3 z), distance (FLOAT-LONG, in and out): the move of the box along
*>     the axis shortened to where it meets a box of the shape (a box it already overlaps or passes does not stop it).
*>   BSH-RAY USING shape id, cell x, y, z, origin (3 FLOAT-LONG), direction (3 FLOAT-LONG), t out (FLOAT-LONG, -1 when no box is
*>     hit, else the ray parameter of the nearest entry), axis out (the axis whose plane the ray entered through).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-KEY-OF.
*> USING direction text (PIC X(16)), key out (BINARY-LONG: north 0, east 1, south 2, west 3; anything else 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(16).
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-KEY.
     EVALUATE L-TEXT
         WHEN "east"
             MOVE 1 TO L-KEY
         WHEN "south"
             MOVE 2 TO L-KEY
         WHEN "west"
             MOVE 3 TO L-KEY
         WHEN OTHER
             MOVE 0 TO L-KEY
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-KEY-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-ADD-BOXES.
*> USING box list text (PIC X(240): "x1 y1 z1 x2 y2 z2" items separated by ","; pixels, decimals allowed), key (BINARY-LONG 0 to 3: the
*> yaw, 51 section 2.1; 4 up and 5 down, 51 section 2.2), mirror (BINARY-LONG 1: y becomes 16 - y first): appends the boxes, turned, to BSC-SHAPE (at most BSH-MAX-BOXES, 16).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-POINTER             BINARY-LONG.
 01 WS-ITEM                PIC X(60).
 01 WS-BP                  BINARY-LONG.
 01 WS-NUM                 PIC X(12).
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-V                   BINARY-LONG OCCURS 6 TIMES.
 01 WS-N                   BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(240).
 01 L-KEY                  BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-KEY L-MIRROR.
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 240
         MOVE SPACES TO WS-ITEM
         UNSTRING L-TEXT DELIMITED BY "," INTO WS-ITEM WITH POINTER WS-POINTER
         IF WS-ITEM NOT = SPACES
             MOVE 1 TO WS-BP
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 MOVE SPACES TO WS-NUM
                 UNSTRING WS-ITEM DELIMITED BY ALL SPACE INTO WS-NUM WITH POINTER WS-BP
                 COMPUTE WS-V(WS-K) ROUNDED = FUNCTION NUMVAL(WS-NUM) * 1000
             END-PERFORM
             IF L-MIRROR = 1
                 COMPUTE WS-T = 16000 - WS-V(5)
                 COMPUTE WS-V(5) = 16000 - WS-V(2)
                 MOVE WS-T TO WS-V(2)
             END-IF
             MOVE WS-V(1) TO WS-N(1)
             MOVE WS-V(2) TO WS-N(2)
             MOVE WS-V(3) TO WS-N(3)
             MOVE WS-V(4) TO WS-N(4)
             MOVE WS-V(5) TO WS-N(5)
             MOVE WS-V(6) TO WS-N(6)
             EVALUATE L-KEY
                 WHEN 1
                     COMPUTE WS-N(1) = 16000 - WS-V(6)
                     MOVE WS-V(1) TO WS-N(3)
                     COMPUTE WS-N(4) = 16000 - WS-V(3)
                     MOVE WS-V(4) TO WS-N(6)
                 WHEN 2
                     COMPUTE WS-N(1) = 16000 - WS-V(4)
                     COMPUTE WS-N(3) = 16000 - WS-V(6)
                     COMPUTE WS-N(4) = 16000 - WS-V(1)
                     COMPUTE WS-N(6) = 16000 - WS-V(3)
                 WHEN 3
                     MOVE WS-V(3) TO WS-N(1)
                     COMPUTE WS-N(3) = 16000 - WS-V(4)
                     MOVE WS-V(6) TO WS-N(4)
                     COMPUTE WS-N(6) = 16000 - WS-V(1)
*>               Up and down (51 section 2.2): y becomes 16 - z and z becomes y, or y becomes z and z becomes 16 - y.
                 WHEN 4
                     COMPUTE WS-N(2) = 16000 - WS-V(6)
                     COMPUTE WS-N(5) = 16000 - WS-V(3)
                     MOVE WS-V(2) TO WS-N(3)
                     MOVE WS-V(5) TO WS-N(6)
                 WHEN 5
                     MOVE WS-V(3) TO WS-N(2)
                     MOVE WS-V(6) TO WS-N(5)
                     COMPUTE WS-N(3) = 16000 - WS-V(5)
                     COMPUTE WS-N(6) = 16000 - WS-V(2)
             END-EVALUATE
             IF BSC-N < BSH-MAX-BOXES
                 ADD 1 TO BSC-N
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                     MOVE WS-N(WS-K) TO BSC-V(BSC-N, WS-K)
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-ADD-BOXES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-INTERN.
*> USING shape id out (BINARY-LONG): the id of the shape BSC-SHAPE holds, stored when no equal shape is. 0 empty, 1 the full cube; the
*> full cube is also the answer when the 2000 shapes are used.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-H                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSC-N
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             COMPUTE WS-H = FUNCTION MOD(WS-H * 31 + BSC-V(WS-I, WS-K) + 7, 1000003)
         END-PERFORM
     END-PERFORM
     COMPUTE WS-SLOT = FUNCTION MOD(WS-H, BSH-HASH-SIZE) + 1
     MOVE 0 TO WS-FOUND
     PERFORM UNTIL WS-FOUND = 1
         MOVE BSH-HASH(WS-SLOT) TO WS-ID
         EVALUATE TRUE
             WHEN WS-ID = 0
                 MOVE 1 TO WS-FOUND
                 IF BSH-COUNT >= BSH-MAX-SHAPES
                     MOVE 1 TO L-ID
                 ELSE
                     MOVE BSC-SHAPE TO BSH-SHAPE(BSH-COUNT + 1)
                     MOVE BSH-COUNT TO L-ID
                     ADD 1 TO BSH-COUNT
                     MOVE BSH-COUNT TO BSH-HASH(WS-SLOT)
                 END-IF
             WHEN BSH-SHAPE(WS-ID) = BSC-SHAPE
                 MOVE 1 TO WS-FOUND
                 COMPUTE L-ID = WS-ID - 1
             WHEN OTHER
                 COMPUTE WS-SLOT = FUNCTION MOD(WS-SLOT, BSH-HASH-SIZE) + 1
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-INTERN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-PROPS-SPLIT.
*> USING property list text (PIC X(288), CT-BR-PROPS): fills BSP-N and the name, kind (L list, R range, B boolean), value count, low
*> value and list items of every property (16 items at most).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSRULE.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(300).
 01 WS-SPEC                PIC X(280).
 01 WS-OPEN                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SLASHES             BINARY-LONG.
 01 WS-DOTS                BINARY-LONG.
 01 WS-LOW-TEXT            PIC X(12).
 01 WS-HIGH-TEXT           PIC X(12).
 01 WS-HIGH                BINARY-LONG.
 01 WS-ITEM-POINTER        BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PROPS                PIC X(288).
 PROCEDURE DIVISION USING L-PROPS.
     MOVE 0 TO BSP-N
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 288
         MOVE SPACES TO WS-TOKEN
         UNSTRING L-PROPS DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN NOT = SPACES AND BSP-N < 16
             ADD 1 TO BSP-N
             MOVE 0 TO WS-OPEN WS-CLOSE
             INSPECT WS-TOKEN TALLYING WS-OPEN FOR CHARACTERS BEFORE INITIAL "["
             INSPECT WS-TOKEN TALLYING WS-CLOSE FOR CHARACTERS BEFORE INITIAL "]"
             COMPUTE WS-LENGTH = WS-CLOSE - WS-OPEN - 1
             MOVE SPACES TO BSP-NAME(BSP-N) WS-SPEC
             MOVE WS-TOKEN(1:WS-OPEN) TO BSP-NAME(BSP-N)
             MOVE WS-TOKEN(WS-OPEN + 2:WS-LENGTH) TO WS-SPEC
             MOVE 0 TO WS-SLASHES WS-DOTS
             INSPECT WS-SPEC TALLYING WS-SLASHES FOR ALL "/"
             INSPECT WS-SPEC TALLYING WS-DOTS FOR ALL ".."
             EVALUATE TRUE
                 WHEN WS-DOTS > 0
                     MOVE "R" TO BSP-KIND(BSP-N)
                     MOVE SPACES TO WS-LOW-TEXT WS-HIGH-TEXT
                     UNSTRING WS-SPEC DELIMITED BY ".." INTO WS-LOW-TEXT WS-HIGH-TEXT
                     COMPUTE BSP-LOW(BSP-N) = FUNCTION NUMVAL(WS-LOW-TEXT)
                     COMPUTE WS-HIGH = FUNCTION NUMVAL(WS-HIGH-TEXT)
                     COMPUTE BSP-COUNT(BSP-N) = WS-HIGH - BSP-LOW(BSP-N) + 1
                 WHEN WS-SPEC = "bool"
                     MOVE "B" TO BSP-KIND(BSP-N)
                     MOVE 2 TO BSP-COUNT(BSP-N)
                 WHEN OTHER
                     MOVE "L" TO BSP-KIND(BSP-N)
                     COMPUTE BSP-COUNT(BSP-N) = FUNCTION MIN(WS-SLASHES + 1, 16)
                     MOVE 1 TO WS-ITEM-POINTER
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BSP-COUNT(BSP-N)
                         MOVE SPACES TO BSP-ITEM(BSP-N, WS-J)
                         UNSTRING WS-SPEC DELIMITED BY "/" OR SPACE INTO BSP-ITEM(BSP-N, WS-J)
                             WITH POINTER WS-ITEM-POINTER
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-PROPS-SPLIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-PROPS-PICK.
*> USING state index (BINARY-LONG, 0 = the block's first state): fills BSP-VAL of every property with the text the state holds (the
*> index is split from the last property, stride 1, to the first; a boolean's first value is true; a range gives the number).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSRULE.
 01 WS-I                   BINARY-LONG.
 01 WS-REMAINDER           BINARY-LONG.
 01 WS-QUOTIENT            BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-NUMBER              PIC Z(8)9.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE L-INDEX TO WS-REMAINDER
     PERFORM VARYING WS-I FROM BSP-N BY -1 UNTIL WS-I < 1
         DIVIDE WS-REMAINDER BY BSP-COUNT(WS-I) GIVING WS-QUOTIENT REMAINDER WS-PICK
         MOVE WS-QUOTIENT TO WS-REMAINDER
         EVALUATE BSP-KIND(WS-I)
             WHEN "B"
                 IF WS-PICK = 0
                     MOVE "true" TO BSP-VAL(WS-I)
                 ELSE
                     MOVE "false" TO BSP-VAL(WS-I)
                 END-IF
             WHEN "R"
                 COMPUTE WS-VALUE = BSP-LOW(WS-I) + WS-PICK
                 MOVE WS-VALUE TO WS-NUMBER
                 MOVE FUNCTION TRIM(WS-NUMBER) TO BSP-VAL(WS-I)
             WHEN OTHER
                 MOVE BSP-ITEM(WS-I, WS-PICK + 1) TO BSP-VAL(WS-I)
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-PROPS-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-PROP-VALUE.
*> USING property name (PIC X(24)), value out (PIC X(16): the text the current state holds, spaces when the block has no such property).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSRULE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-VALUE                PIC X(16).
 PROCEDURE DIVISION USING L-NAME L-VALUE.
     MOVE SPACES TO L-VALUE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSP-N
         IF BSP-NAME(WS-I) = L-NAME
             MOVE BSP-VAL(WS-I) TO L-VALUE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-PROP-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-SPECIAL.
*> USING which (BINARY-LONG: 1 collision, 2 outline), code (PIC X(12)): the shape of a coded family (51 section 3.2: ST stairs, DR doors,
*> TD trapdoors, FN fences, GT fence gates, WL walls, PN panes and bars, ML vines and lichen, CH chests, BD beds, CP chorus plants, MC moss carpets) from the properties of the current state,
*> appended to BSC-SHAPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-FACING              PIC X(16).
 01 WS-HALF                PIC X(16).
 01 WS-SHAPE               PIC X(16).
 01 WS-VALUE               PIC X(16).
 01 WS-KEY                 BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NO-MIRROR           BINARY-LONG VALUE 0.
 01 WS-POST                PIC X(240).
 01 WS-ARM                 PIC X(240).
 01 WS-SIDES.
    05 FILLER              PIC X(24) VALUE "north".
    05 FILLER              PIC X(24) VALUE "east".
    05 FILLER              PIC X(24) VALUE "south".
    05 FILLER              PIC X(24) VALUE "west".
 01 WS-SIDE-TABLE REDEFINES WS-SIDES.
    05 WS-SIDE-NAME        PIC X(24) OCCURS 4 TIMES.
 01 WS-FACES.
    05 FILLER              PIC X(24) VALUE "north".
    05 FILLER              PIC X(24) VALUE "east".
    05 FILLER              PIC X(24) VALUE "south".
    05 FILLER              PIC X(24) VALUE "west".
    05 FILLER              PIC X(24) VALUE "up".
    05 FILLER              PIC X(24) VALUE "down".
 01 WS-FACE-TABLE REDEFINES WS-FACES.
    05 WS-FACE-NAME        PIC X(24) OCCURS 6 TIMES.
 01 WS-FACE-BOXES.
    05 FILLER              PIC X(240) VALUE "0 0 0 16 16 1".
    05 FILLER              PIC X(240) VALUE "15 0 0 16 16 16".
    05 FILLER              PIC X(240) VALUE "0 0 15 16 16 16".
    05 FILLER              PIC X(240) VALUE "0 0 0 1 16 16".
    05 FILLER              PIC X(240) VALUE "0 15 0 16 16 16".
    05 FILLER              PIC X(240) VALUE "0 0 0 16 1 16".
 01 WS-FACE-BOX-TABLE REDEFINES WS-FACE-BOXES.
    05 WS-FACE-BOX         PIC X(240) OCCURS 6 TIMES.
 01 WS-CHORUS-ARMS.
    05 FILLER              PIC X(240) VALUE "3 3 0 13 13 8".
    05 FILLER              PIC X(240) VALUE "8 3 3 16 13 13".
    05 FILLER              PIC X(240) VALUE "3 3 8 13 13 16".
    05 FILLER              PIC X(240) VALUE "0 3 3 8 13 13".
    05 FILLER              PIC X(240) VALUE "3 8 3 13 16 13".
    05 FILLER              PIC X(240) VALUE "3 0 3 13 8 13".
 01 WS-CHORUS-TABLE REDEFINES WS-CHORUS-ARMS.
    05 WS-CHORUS-ARM       PIC X(240) OCCURS 6 TIMES.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(240).
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-CODE                 PIC X(24).
 PROCEDURE DIVISION USING L-WHICH L-CODE.
     MOVE "facing" TO WS-NAME
     CALL "BSH-PROP-VALUE" USING WS-NAME WS-FACING
     CALL "BSH-KEY-OF" USING WS-FACING WS-KEY
     MOVE 0 TO WS-MIRROR
     EVALUATE L-CODE
         WHEN "ST"
             MOVE "half" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-HALF
             IF WS-HALF = "top"
                 MOVE 1 TO WS-MIRROR
             END-IF
             MOVE "shape" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-SHAPE
             EVALUATE WS-SHAPE
                 WHEN "inner_left"
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 3, 4)
                 WHEN "outer_right"
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 1, 4)
             END-EVALUATE
             MOVE "0 0 0 16 8 16" TO WS-TEXT
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-MIRROR
             EVALUATE WS-SHAPE
                 WHEN "outer_left"
                 WHEN "outer_right"
                     MOVE "0 8 0 8 16 8" TO WS-TEXT
                 WHEN "straight"
                     MOVE "0 8 0 16 16 8" TO WS-TEXT
                 WHEN OTHER
                     MOVE "0 8 0 16 16 8,8 8 0 16 16 16" TO WS-TEXT
             END-EVALUATE
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-MIRROR
         WHEN "DR"
             MOVE "open" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE = "true"
                 MOVE "hinge" TO WS-NAME
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 IF WS-VALUE = "right"
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 3, 4)
                 ELSE
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 1, 4)
                 END-IF
             END-IF
             MOVE "0 0 13 16 16 16" TO WS-TEXT
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-MIRROR
         WHEN "TD"
             MOVE "open" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             MOVE "half" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-HALF
             EVALUATE TRUE
                 WHEN WS-VALUE = "true"
                     MOVE "0 0 13 16 16 16" TO WS-TEXT
                 WHEN WS-HALF = "top"
                     MOVE "0 13 0 16 16 16" TO WS-TEXT
                 WHEN OTHER
                     MOVE "0 0 0 16 3 16" TO WS-TEXT
             END-EVALUATE
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
         WHEN "GT"
             MOVE "open" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             MOVE "in_wall" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-HALF
             EVALUATE TRUE
                 WHEN L-WHICH = 1 AND WS-VALUE = "true"
                     CONTINUE
                 WHEN L-WHICH = 1
                     MOVE "0 0 6 16 24 10" TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
                 WHEN WS-HALF = "true"
                     MOVE "0 0 6 16 13 10" TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
                 WHEN OTHER
                     MOVE "0 0 6 16 16 10" TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
             END-EVALUATE
         WHEN "FN"
         WHEN "PN"
             IF L-CODE = "PN"
                 MOVE "7 0 7 9 16 9" TO WS-POST
                 MOVE "7 0 0 9 16 8" TO WS-ARM
             ELSE
                 IF L-WHICH = 1
                     MOVE "6 0 6 10 24 10" TO WS-POST
                     MOVE "6 0 0 10 24 8" TO WS-ARM
                 ELSE
                     MOVE "6 0 6 10 16 10" TO WS-POST
                     MOVE "6 0 0 10 16 8" TO WS-ARM
                 END-IF
             END-IF
             CALL "BSH-ADD-BOXES" USING WS-POST WS-ZERO WS-NO-MIRROR
             PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 4
                 MOVE WS-SIDE-NAME(WS-SIDE) TO WS-NAME
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 IF WS-VALUE = "true"
                     COMPUTE WS-KEY = WS-SIDE - 1
                     CALL "BSH-ADD-BOXES" USING WS-ARM WS-KEY WS-ZERO
                 END-IF
             END-PERFORM
         WHEN "WL"
             MOVE "up" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE = "true"
                 IF L-WHICH = 1
                     MOVE "4 0 4 12 24 12" TO WS-TEXT
                 ELSE
                     MOVE "4 0 4 12 16 12" TO WS-TEXT
                 END-IF
                 CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
             END-IF
             PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 4
                 MOVE WS-SIDE-NAME(WS-SIDE) TO WS-NAME
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 MOVE SPACES TO WS-TEXT
                 EVALUATE TRUE
                     WHEN WS-VALUE = "none"
                         CONTINUE
                     WHEN L-WHICH = 1
                         MOVE "5 0 0 11 24 11" TO WS-TEXT
                     WHEN WS-VALUE = "low"
                         MOVE "5 0 0 11 14 11" TO WS-TEXT
                     WHEN OTHER
                         MOVE "5 0 0 11 16 11" TO WS-TEXT
                 END-EVALUATE
                 IF WS-TEXT NOT = SPACES
                     COMPUTE WS-KEY = WS-SIDE - 1
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
                 END-IF
             END-PERFORM
         WHEN "CH"
*>           A chest (R-E1): single is the 14 high column; a joined half reaches into the connected half, whose direction is clockwise
*>           of the facing for the left type and counter-clockwise for the right.
             MOVE "type" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             EVALUATE WS-VALUE
                 WHEN "left"
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 1, 4)
                     MOVE "1 0 0 15 14 15" TO WS-TEXT
                 WHEN "right"
                     COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 3, 4)
                     MOVE "1 0 0 15 14 15" TO WS-TEXT
                 WHEN OTHER
                     MOVE 0 TO WS-KEY
                     MOVE "1 0 1 15 14 15" TO WS-TEXT
             END-EVALUATE
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
         WHEN "BD"
*>           A bed (R-E3): the mattress and two legs at the end away from the other half, authored for the key north (the head half's facing; the
*>           foot half's key is the opposite of its facing).
             MOVE "part" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE = "foot"
                 COMPUTE WS-KEY = FUNCTION MOD(WS-KEY + 2, 4)
             END-IF
             MOVE "0 3 0 16 9 16,0 0 0 3 3 3,13 0 0 16 3 3" TO WS-TEXT
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
         WHEN "CP"
*>           A chorus plant (R-F40): the 10 pixel node and an arm toward every side that is set (the same for the collision and the outline).
             MOVE "3 3 3 13 13 13" TO WS-TEXT
             CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
             PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 6
                 MOVE WS-FACE-NAME(WS-SIDE) TO WS-NAME
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 IF WS-VALUE = "true"
                     MOVE WS-CHORUS-ARM(WS-SIDE) TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
                 END-IF
             END-PERFORM
         WHEN "MC"
*>           Moss carpet (R-D2): the base sheet when bottom is set (the whole collision); the outline adds a sheet of 10 (low) or 16 (tall) pixels
*>           on each side that is not none, and is the full cube when it holds nothing.
             MOVE "bottom" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE = "true"
                 MOVE "0 0 0 16 1 16" TO WS-TEXT
                 CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
             END-IF
             IF L-WHICH = 2
                 PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 4
                     MOVE WS-SIDE-NAME(WS-SIDE) TO WS-NAME
                     CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                     MOVE SPACES TO WS-TEXT
                     EVALUATE WS-VALUE
                         WHEN "low"
                             MOVE "0 0 0 16 10 1" TO WS-TEXT
                         WHEN "tall"
                             MOVE "0 0 0 16 16 1" TO WS-TEXT
                     END-EVALUATE
                     IF WS-TEXT NOT = SPACES
                         COMPUTE WS-KEY = WS-SIDE - 1
                         CALL "BSH-ADD-BOXES" USING WS-TEXT WS-KEY WS-ZERO
                     END-IF
                 END-PERFORM
                 IF BSC-N = 0
                     MOVE "0 0 0 16 16 16" TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
                 END-IF
             END-IF
         WHEN "ML"
*>           No collision; the outline is a one pixel sheet on every set face, the full cube when none is set.
             IF L-WHICH = 2
                 PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 6
                     MOVE WS-FACE-NAME(WS-SIDE) TO WS-NAME
                     CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                     IF WS-VALUE = "true"
                         MOVE WS-FACE-BOX(WS-SIDE) TO WS-TEXT
                         CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
                     END-IF
                 END-PERFORM
                 IF BSC-N = 0
                     MOVE "0 0 0 16 16 16" TO WS-TEXT
                     CALL "BSH-ADD-BOXES" USING WS-TEXT WS-ZERO WS-NO-MIRROR
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-SPECIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-ADD-TEXT.
*> USING rule text (PIC X(240): N none, F the full cube, else a box list), key (BINARY-LONG 0 to 3): appends the boxes, turned by the key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NO-MIRROR           BINARY-LONG VALUE 0.
 01 WS-FULL                PIC X(240) VALUE "0 0 0 16 16 16".
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(240).
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-KEY.
     EVALUATE L-TEXT
         WHEN "N"
             CONTINUE
         WHEN "F"
             CALL "BSH-ADD-BOXES" USING WS-FULL WS-ZERO WS-NO-MIRROR
         WHEN OTHER
             CALL "BSH-ADD-BOXES" USING L-TEXT L-KEY WS-ZERO
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-ADD-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-COMPOSE.
*> USING which (BINARY-LONG: 1 collision, 2 outline), rule row (BINARY-LONG), shape id out: the shape the rule gives the current state
*> (the properties of the block are split and the state's values picked).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 COPY CTBSRULE.
 01 WS-TEXT                PIC X(240).
 01 WS-KEY                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(16).
 01 WS-A-TEXT              PIC X(12).
 01 WS-B-TEXT              PIC X(12).
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-WALL                PIC X(240).
 01 WS-FLOOR               PIC X(240).
 01 WS-CEILING             PIC X(240).
 01 WS-FACE                PIC X(16).
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-RULE L-ID.
     INITIALIZE BSC-SHAPE
     MOVE BSR-COLL(L-RULE) TO WS-TEXT
     IF L-WHICH = 2 AND BSR-OUT(L-RULE) NOT = "="
         MOVE BSR-OUT(L-RULE) TO WS-TEXT
     END-IF
     MOVE BSR-PROP(L-RULE) TO WS-NAME
     EVALUATE BSR-MODE(L-RULE)
         WHEN "K"
             CALL "BSH-SPECIAL" USING L-WHICH BSR-PROP(L-RULE)
         WHEN "Y"
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             CALL "BSH-KEY-OF" USING WS-VALUE WS-KEY
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
         WHEN "Q"
             MOVE "facing" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             CALL "BSH-KEY-OF" USING WS-VALUE WS-KEY
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
*>       R: the boxes authored for north turned to the six-direction facing (rotateAll, 51 section 2.2).
         WHEN "R"
             MOVE "facing" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             CALL "BSH-KEY-OF" USING WS-VALUE WS-KEY
             EVALUATE WS-VALUE
                 WHEN "up"
                     MOVE 4 TO WS-KEY
                 WHEN "down"
                     MOVE 5 TO WS-KEY
             END-EVALUATE
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
         WHEN "H"
             IF WS-TEXT NOT = "N"
                 MOVE SPACES TO WS-A-TEXT WS-B-TEXT
                 UNSTRING WS-TEXT DELIMITED BY SPACE INTO WS-A-TEXT WS-B-TEXT
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 COMPUTE WS-HEIGHT = (FUNCTION NUMVAL(WS-A-TEXT) + FUNCTION NUMVAL(WS-B-TEXT) * FUNCTION NUMVAL(WS-VALUE)) * 1000
                 IF WS-HEIGHT > 0
                     ADD 1 TO BSC-N
                     MOVE 16000 TO BSC-V(1, 4) BSC-V(1, 6)
                     MOVE WS-HEIGHT TO BSC-V(1, 5)
                 END-IF
             END-IF
         WHEN "A"
             MOVE "facing" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             CALL "BSH-KEY-OF" USING WS-VALUE WS-KEY
             MOVE "face" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-FACE
             MOVE SPACES TO WS-WALL WS-FLOOR WS-CEILING
             UNSTRING WS-TEXT DELIMITED BY "/" INTO WS-WALL WS-FLOOR WS-CEILING
             EVALUATE WS-FACE
                 WHEN "floor"
                     MOVE WS-FLOOR TO WS-TEXT
                 WHEN "ceiling"
                     MOVE WS-CEILING TO WS-TEXT
                 WHEN OTHER
                     MOVE WS-WALL TO WS-TEXT
             END-EVALUATE
             IF L-WHICH = 2
                 CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
             END-IF
         WHEN OTHER
             MOVE 0 TO WS-KEY
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
     END-EVALUATE
     CALL "BSH-INTERN" USING L-ID
     GOBACK.
 END PROGRAM BSH-COMPOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-INTERACTION.
*> USING block class (PIC X(32)), shape id out: the interaction shape of the current state (51 section 1.8.1; the properties of the block are split and the state's values picked):
*> the cauldrons the inside (2,4,2,14,16,14), the composter and scaffolding the full cube, the hopper its cavity (2,11,2,14,16,14) and, for a horizontal facing, the stub
*> (6,8,0,10,10,4) authored for north and turned by the facing (3.8.1); any other class the empty shape (0). It only refines the face of a targeting hit (1.8.3 item 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-TEXT                PIC X(240).
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(16).
 01 WS-KEY                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(32).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-ID.
     MOVE 0 TO L-ID
     INITIALIZE BSC-SHAPE
     EVALUATE L-CLASS
         WHEN "CauldronBlock" WHEN "LavaCauldronBlock" WHEN "LayeredCauldronBlock"
             MOVE "2 4 2 14 16 14" TO WS-TEXT
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-ZERO
             CALL "BSH-INTERN" USING L-ID
         WHEN "ComposterBlock" WHEN "ScaffoldingBlock"
             MOVE "F" TO WS-TEXT
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-ZERO
             CALL "BSH-INTERN" USING L-ID
         WHEN "HopperBlock"
             MOVE "2 11 2 14 16 14" TO WS-TEXT
             CALL "BSH-ADD-TEXT" USING WS-TEXT WS-ZERO
             MOVE "facing" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE NOT = "down"
                 CALL "BSH-KEY-OF" USING WS-VALUE WS-KEY
                 MOVE "6 8 0 10 10 4" TO WS-TEXT
                 CALL "BSH-ADD-TEXT" USING WS-TEXT WS-KEY
             END-IF
             CALL "BSH-INTERN" USING L-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-INTERACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-SHULKER.
*> USING direction (BINARY-LONG, the Direction order of 05c: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), lid progress in tenths (BINARY-LONG 0 to 10), shape id out: the
*> collision and outline shape of a shulker box with a block entity (51 section 3.8.8): the unit cube extended along the facing by q = 8 x progress pixels (the full cube
*> when the lid is closed). The shape is stored when no equal one is, so a box takes 66 shapes at most.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-TENTHS               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-TENTHS L-ID.
     INITIALIZE BSC-SHAPE
     MOVE 1 TO BSC-N
     MOVE 16000 TO BSC-V(1, 4) BSC-V(1, 5) BSC-V(1, 6)
     COMPUTE WS-Q = FUNCTION MIN(10, FUNCTION MAX(0, L-TENTHS)) * 800
     EVALUATE L-DIRECTION
         WHEN 0
             COMPUTE BSC-V(1, 2) = 0 - WS-Q
         WHEN 1
             COMPUTE BSC-V(1, 5) = 16000 + WS-Q
         WHEN 2
             COMPUTE BSC-V(1, 3) = 0 - WS-Q
         WHEN 3
             COMPUTE BSC-V(1, 6) = 16000 + WS-Q
         WHEN 4
             COMPUTE BSC-V(1, 1) = 0 - WS-Q
         WHEN OTHER
             COMPUTE BSC-V(1, 4) = 16000 + WS-Q
     END-EVALUATE
     CALL "BSH-INTERN" USING L-ID
     GOBACK.
 END PROGRAM BSH-SHULKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-LIGHT-DATA.
*> USING block class (PIC X(32)), flags text (PIC X(160): " flag flag ... " the registry flags), outline shape id, collision shape id (BINARY-LONG), occlusion shape id out,
*> dampening out, light flags out (BINARY-LONG: 1 canOcclude, 2 useShapeForLightOcclusion, 4 propagatesSkylightDown): the light data of the current state (the properties of
*> the block are split and the state's values picked), 51 section 1.8.1 items 1 to 6 and 32 section 7. canOcclude is false for a block flagged noOcclusion or noCollision; the
*> occlusion shape is then empty, else the outline evaluated with the empty context (the lectern's and the sculk shrieker's own is the collision shape); propagatesSkylightDown
*> is the default (the outline is not the full cube and the fluid is empty) with the class overrides of 32 section 7 that the registry classes name; the dampening is 15 for a
*> full-cube occlusion shape, else 0 when skylight propagates, else 1 (leaves 1, tinted glass 15); useShapeForLightOcclusion by the class list of 32 section 7.
*> Not covered: the fence and fence gate occlusion shapes (their arms are 2 wide), the classes of 32 section 7 that the registry names by another class.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(16).
 01 WS-HITS                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-USE                 BINARY-LONG.
 01 WS-PROP                BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-DAMP                BINARY-LONG.
 01 WS-OCC                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(32).
 01 L-FLAGS                PIC X(160).
 01 L-OUT                  BINARY-LONG.
 01 L-COLL                 BINARY-LONG.
 01 L-OCC                  BINARY-LONG.
 01 L-DAMP                 BINARY-LONG.
 01 L-LFLG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-FLAGS L-OUT L-COLL L-OCC L-DAMP L-LFLG.
     MOVE 1 TO WS-CAN
     MOVE 0 TO WS-HITS
     INSPECT L-FLAGS TALLYING WS-HITS FOR ALL "noOcclusion" ALL "noCollision"
     IF WS-HITS > 0
         MOVE 0 TO WS-CAN
     END-IF
     MOVE L-OUT TO WS-OCC
     EVALUATE L-CLASS
         WHEN "LecternBlock" WHEN "SculkShriekerBlock"
             MOVE L-COLL TO WS-OCC
     END-EVALUATE
     IF WS-CAN = 0
         MOVE 0 TO WS-OCC
     END-IF
*>   The fluid: a liquid block or a waterlogged state.
     MOVE 0 TO WS-FLUID
     MOVE 0 TO WS-HITS
     INSPECT L-FLAGS TALLYING WS-HITS FOR ALL "liquid"
     MOVE "waterlogged" TO WS-NAME
     CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
     IF WS-HITS > 0 OR WS-VALUE = "true"
         MOVE 1 TO WS-FLUID
     END-IF
*>   propagatesSkylightDown.
     MOVE 0 TO WS-PROP
     IF L-OUT NOT = 1 AND WS-FLUID = 0
         MOVE 1 TO WS-PROP
     END-IF
     EVALUATE L-CLASS
         WHEN "ShulkerBoxBlock" WHEN "LiquidBlock" WHEN "TintedGlassBlock" WHEN "PipeBlock"
             MOVE 0 TO WS-PROP
         WHEN "VineBlock" WHEN "MossyCarpetBlock" WHEN "HangingMossBlock" WHEN "BambooStalkBlock" WHEN "TransparentBlock"
             MOVE 1 TO WS-PROP
         WHEN "BarrierBlock" WHEN "GlowLichenBlock" WHEN "LightBlock"
             COMPUTE WS-PROP = 1 - WS-FLUID
         WHEN "WallBlock" WHEN "FenceBlock" WHEN "IronBarsBlock" WHEN "StainedGlassPaneBlock" WHEN "WeatheringCopperBarsBlock"
             COMPUTE WS-PROP = 1 - WS-FLUID
     END-EVALUATE
*>   The dampening.
     EVALUATE TRUE
         WHEN L-CLASS = "TintedGlassBlock"
             MOVE 15 TO WS-DAMP
         WHEN L-CLASS = "LeavesBlock"
             MOVE 1 TO WS-DAMP
         WHEN WS-OCC = 1
             MOVE 15 TO WS-DAMP
         WHEN WS-PROP = 1
             MOVE 0 TO WS-DAMP
         WHEN OTHER
             MOVE 1 TO WS-DAMP
     END-EVALUATE
*>   useShapeForLightOcclusion.
     MOVE 0 TO WS-USE
     EVALUATE L-CLASS
         WHEN "StairBlock" WHEN "WeatheringCopperStairBlock" WHEN "SnowLayerBlock" WHEN "DaylightDetectorBlock" WHEN "EnchantingTableBlock"
         WHEN "EndPortalFrameBlock" WHEN "FarmlandBlock" WHEN "LecternBlock" WHEN "PathBlock" WHEN "SculkSensorBlock"
         WHEN "CalibratedSculkSensorBlock" WHEN "SculkShriekerBlock" WHEN "ShelfBlock" WHEN "StonecutterBlock" WHEN "PistonHeadBlock"
             MOVE 1 TO WS-USE
         WHEN "SlabBlock" WHEN "WeatheringCopperSlabBlock"
             MOVE "type" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE NOT = "double"
                 MOVE 1 TO WS-USE
             END-IF
         WHEN "PistonBaseBlock"
             MOVE "extended" TO WS-NAME
             CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
             IF WS-VALUE = "true"
                 MOVE 1 TO WS-USE
             END-IF
     END-EVALUATE
     MOVE WS-OCC TO L-OCC
     MOVE WS-DAMP TO L-DAMP
     COMPUTE L-LFLG = WS-CAN + 2 * WS-USE + 4 * WS-PROP
     GOBACK.
 END PROGRAM BSH-LIGHT-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-FACE.
*> USING shape id, direction (BINARY-LONG: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), face shape id out: the face shape of a shape on the side of the direction (51 section 1.8.1,
*> getFaceShape): the cross-section of the shape at the plane 1e-7 block inside the cell on that side, projected on the face and stored flat on the face plane (the coordinate of
*> the direction's axis is the plane at both ends). A box takes part when it reaches the plane (it starts at 0 or lower and ends above 0 for the low sides, it ends at 16 pixels or
*> more and starts under 16 for the high sides); the empty shape has the empty face, the full cube the full square.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-AXIS                BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-DIRECTION L-FACE.
     EVALUATE L-DIRECTION
         WHEN 0 WHEN 1
             MOVE 2 TO WS-AXIS
         WHEN 2 WHEN 3
             MOVE 3 TO WS-AXIS
         WHEN OTHER
             MOVE 1 TO WS-AXIS
     END-EVALUATE
     MOVE 0 TO WS-HIGH
     IF L-DIRECTION = 1 OR L-DIRECTION = 3 OR L-DIRECTION = 5
         MOVE 1 TO WS-HIGH
     END-IF
     INITIALIZE BSC-SHAPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-SHAPE + 1)
         MOVE BSH-V(L-SHAPE + 1, WS-I, WS-AXIS) TO WS-LO
         MOVE BSH-V(L-SHAPE + 1, WS-I, WS-AXIS + 3) TO WS-HI
         MOVE 0 TO WS-OK
         IF WS-HIGH = 1
             IF WS-HI >= 16000 AND WS-LO < 16000
                 MOVE 1 TO WS-OK
             END-IF
         ELSE
             IF WS-LO <= 0 AND WS-HI > 0
                 MOVE 1 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1 AND BSC-N < BSH-MAX-BOXES
             ADD 1 TO BSC-N
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 MOVE BSH-V(L-SHAPE + 1, WS-I, WS-K) TO BSC-V(BSC-N, WS-K)
             END-PERFORM
             IF WS-HIGH = 1
                 MOVE 16000 TO BSC-V(BSC-N, WS-AXIS) BSC-V(BSC-N, WS-AXIS + 3)
             ELSE
                 MOVE 0 TO BSC-V(BSC-N, WS-AXIS) BSC-V(BSC-N, WS-AXIS + 3)
             END-IF
         END-IF
     END-PERFORM
     CALL "BSH-INTERN" USING L-FACE
     GOBACK.
 END PROGRAM BSH-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-RULES-LOAD.
*> No parameters: splits the rows of CTBSDATA.cpy into the rule table BSR-R (classes, mode, property, value, collision, outline).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSRULE.
 COPY CTBSDATA.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE BSD-COUNT TO BSR-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSD-COUNT
         MOVE SPACES TO BSR-CLASSES(WS-I) BSR-MODE(WS-I) BSR-PROP(WS-I) BSR-VAL(WS-I) BSR-COLL(WS-I) BSR-OUT(WS-I)
         UNSTRING BSD-ROW(WS-I) DELIMITED BY "~" INTO BSR-CLASSES(WS-I) BSR-MODE(WS-I) BSR-PROP(WS-I) BSR-VAL(WS-I)
             BSR-COLL(WS-I) BSR-OUT(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-RULES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-BUILD.
*> No parameters: builds the shape tables of CTBSHAPE.cpy for every state of the open set (a no-op with BSH-READY 0 when none is open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTBSHAPE.
 COPY CTBSRULE.
 01 WS-S                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-FLAGS               PIC X(160).
 01 WS-HITS                BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY2                PIC X(40).
 01 WS-OFS                 BINARY-LONG.
 01 WS-SOFS                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-LHITS               BINARY-LONG.
 01 WS-OCCV                BINARY-LONG.
 01 WS-DAMPV               BINARY-LONG.
 01 WS-LFLG                BINARY-LONG.
 01 WS-OHITS               BINARY-LONG.
 01 WS-LENGTH2             BINARY-LONG.
 01 WS-COND1               PIC X(40).
 01 WS-COND2               PIC X(40).
 01 WS-NAME2               PIC X(24).
 01 WS-WANT2               PIC X(16).
 01 WS-FIRST               BINARY-LONG.
 01 WS-STATES              BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-DEF-COLL            BINARY-LONG.
 01 WS-DEF-OUT             BINARY-LONG.
 01 WS-COLL                BINARY-LONG.
 01 WS-OUTV                BINARY-LONG.
 01 WS-MATCHES             BINARY-LONG.
 01 WS-MATCH               BINARY-LONG OCCURS 100 TIMES.
 01 WS-M                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-APPLIES             BINARY-LONG.
 01 WS-NEEDS               BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(16).
 01 WS-SLIPPERY            BINARY-LONG.
 01 WS-CLIMBABLE.
    05 FILLER              PIC X(70) VALUE "|LadderBlock|VineBlock|ScaffoldingBlock|".
    05 FILLER              PIC X(70) VALUE "|WeepingVinesBlock|WeepingVinesPlantBlock|".
    05 FILLER              PIC X(70) VALUE "|TwistingVinesBlock|TwistingVinesPlantBlock|".
    05 FILLER              PIC X(70) VALUE "|CaveVinesBlock|CaveVinesPlantBlock|".
 PROCEDURE DIVISION.
     IF CT-OPEN = 0
         MOVE 0 TO BSH-READY BSH-TYPE
         GOBACK
     END-IF
     IF BSH-READY = 1 AND BSH-TYPE = CT-SET-TYPE + 1
         GOBACK
     END-IF
     MOVE 0 TO BSH-READY
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > BSH-HASH-SIZE
         MOVE 0 TO BSH-HASH(WS-S)
     END-PERFORM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > BSH-MAX-STATES
         MOVE 0 TO BSH-COLL(WS-S) BSH-OUT(WS-S) BSH-CLIMB(WS-S) BSH-SLIP(WS-S) BSH-OFS(WS-S) BSH-CTX(WS-S)
         MOVE 0 TO BSH-SOFS(WS-S) BSH-INT(WS-S) BSH-OCC(WS-S) BSH-DAMP(WS-S) BSH-LFLG(WS-S)
     END-PERFORM
     INITIALIZE BSH-SHAPE(1) BSC-SHAPE
     MOVE 1 TO BSC-N
     MOVE 16000 TO BSC-V(1, 4) BSC-V(1, 5) BSC-V(1, 6)
     MOVE BSC-SHAPE TO BSH-SHAPE(2)
     MOVE 2 TO BSH-COUNT
     CALL "BSH-RULES-LOAD"
     MOVE 0 TO WS-ID
     CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT
         CALL "BLOCK-ROW-AT" USING WS-ID WS-ROW WS-STATUS WS-COUNT
         MOVE WS-ROW TO CT-BLOCK-ROW
         COMPUTE WS-FIRST = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
         COMPUTE WS-STATES = FUNCTION MIN(FUNCTION NUMVAL(CT-BR-STATE-COUNT), BSH-MAX-STATES - WS-FIRST)
*>       The defaults: no collision for a block flagged noCollision or air, else the full cube; the outline is empty for air and
*>       liquids and the full cube otherwise.
         MOVE SPACES TO WS-FLAGS
         STRING " " CT-BR-FLAGS " " DELIMITED BY SIZE INTO WS-FLAGS
         MOVE 1 TO WS-DEF-COLL WS-DEF-OUT
         MOVE 0 TO WS-HITS
         INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL "noCollision" ALL " air "
         IF WS-HITS > 0
             MOVE 0 TO WS-DEF-COLL
         END-IF
         MOVE 0 TO WS-HITS
         INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL " air " ALL "liquid"
         IF WS-HITS > 0
             MOVE 0 TO WS-DEF-OUT
         END-IF
*>       The rules of the block's class, in table order.
         MOVE SPACES TO WS-KEY
         STRING "|" FUNCTION TRIM(CT-BR-CLASS) "|" DELIMITED BY SIZE INTO WS-KEY
         COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(CT-BR-CLASS)) + 2
*>       A row may also name one block by its key as "=key" (the four amethyst clusters share a class and differ in size).
         MOVE SPACES TO WS-KEY2
         STRING "|=" FUNCTION TRIM(CT-BR-KEY) "|" DELIMITED BY SIZE INTO WS-KEY2
         COMPUTE WS-LENGTH2 = FUNCTION LENGTH(FUNCTION TRIM(CT-BR-KEY)) + 3
         MOVE 0 TO WS-MATCHES WS-NEEDS
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BSR-N
             MOVE 0 TO WS-HITS
             INSPECT BSR-CLASSES(WS-R) TALLYING WS-HITS FOR ALL WS-KEY(1:WS-LENGTH) ALL WS-KEY2(1:WS-LENGTH2)
             IF WS-HITS > 0
                 ADD 1 TO WS-MATCHES
                 MOVE WS-R TO WS-MATCH(WS-MATCHES)
                 IF BSR-MODE(WS-R) NOT = "S"
                     MOVE 1 TO WS-NEEDS
                 END-IF
             END-IF
         END-PERFORM
         MOVE 0 TO WS-HITS
         INSPECT WS-CLIMBABLE TALLYING WS-HITS FOR ALL WS-KEY(1:WS-LENGTH)
*>       The friction of the block (18 section 3.2).
         EVALUATE FUNCTION TRIM(CT-BR-KEY)
             WHEN "minecraft:ice"
             WHEN "minecraft:packed_ice"
             WHEN "minecraft:frosted_ice"
             WHEN "ice"
             WHEN "packed_ice"
             WHEN "frosted_ice"
                 MOVE 980 TO WS-SLIPPERY
             WHEN "minecraft:blue_ice"
             WHEN "blue_ice"
                 MOVE 989 TO WS-SLIPPERY
             WHEN "minecraft:slime_block"
             WHEN "slime_block"
                 MOVE 800 TO WS-SLIPPERY
             WHEN OTHER
                 MOVE 0 TO WS-SLIPPERY
         END-EVALUATE
*>       The model offset kind of the block (51 section 1.4): the flags offset:XZ and offset:XYZ, with the two blocks that have other limits.
         MOVE 0 TO WS-OFS
         MOVE 0 TO WS-OHITS
         INSPECT WS-FLAGS TALLYING WS-OHITS FOR ALL "offset:XYZ"
         IF WS-OHITS > 0
             MOVE 2 TO WS-OFS
         ELSE
             MOVE 0 TO WS-OHITS
             INSPECT WS-FLAGS TALLYING WS-OHITS FOR ALL "offset:XZ"
             IF WS-OHITS > 0
                 MOVE 1 TO WS-OFS
             END-IF
         END-IF
*>       The registry rows of the flowers, the grasses and the seagrass carry no offset flag, but 51 section 1.4 names them: by class.
         IF WS-OFS = 0
             EVALUATE FUNCTION TRIM(CT-BR-CLASS)
                 WHEN "FlowerBlock" WHEN "WitherRoseBlock" WHEN "TallSeagrassBlock"
                     MOVE 1 TO WS-OFS
                 WHEN "TallGrassBlock" WHEN "ShortDryGrassBlock" WHEN "TallDryGrassBlock"
                     MOVE 2 TO WS-OFS
             END-EVALUATE
         END-IF
         EVALUATE FUNCTION TRIM(CT-BR-KEY)
             WHEN "pointed_dripstone" WHEN "minecraft:pointed_dripstone" WHEN "sulfur_spike" WHEN "minecraft:sulfur_spike"
                 MOVE 3 TO WS-OFS
             WHEN "small_dripleaf" WHEN "minecraft:small_dripleaf"
                 MOVE 4 TO WS-OFS
         END-EVALUATE
*>       Only the shapes of the flower family, bamboo, the speleothems and the mangrove propagule move by the offset (51 section 1.4, R4); the
*>       model of every other offset block moves alone.
         MOVE 0 TO WS-SOFS
         IF WS-OFS > 0
             EVALUATE FUNCTION TRIM(CT-BR-CLASS)
                 WHEN "FlowerBlock" WHEN "WitherRoseBlock" WHEN "EyeblossomBlock" WHEN "BambooStalkBlock" WHEN "BambooSaplingBlock"
                 WHEN "MangrovePropaguleBlock" WHEN "PointedDripstoneBlock" WHEN "SulfurSpikeBlock"
                     MOVE 1 TO WS-SOFS
             END-EVALUATE
         END-IF
*>       The light data reads a few properties (waterlogged, type, extended) of every block that has them.
         MOVE 0 TO WS-LHITS
         INSPECT CT-BR-PROPS TALLYING WS-LHITS FOR ALL "waterlogged" ALL "type[" ALL "extended"
         IF WS-LHITS > 0
             MOVE 1 TO WS-NEEDS
         END-IF
         IF WS-NEEDS = 1
             CALL "BSH-PROPS-SPLIT" USING CT-BR-PROPS
         END-IF
         PERFORM VARYING WS-IDX FROM 0 BY 1 UNTIL WS-IDX >= WS-STATES
             MOVE WS-DEF-COLL TO WS-COLL
             MOVE WS-DEF-OUT TO WS-OUTV
             IF WS-NEEDS = 1
                 CALL "BSH-PROPS-PICK" USING WS-IDX
             END-IF
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-M FROM 1 BY 1 UNTIL WS-M > WS-MATCHES OR WS-DONE = 1
                 MOVE WS-MATCH(WS-M) TO WS-R
                 MOVE 1 TO WS-APPLIES
                 IF BSR-PROP(WS-R) NOT = SPACES AND BSR-VAL(WS-R) NOT = SPACES AND BSR-MODE(WS-R) NOT = "S"
                     MOVE BSR-PROP(WS-R) TO WS-NAME
                     CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
*>                   The value may be followed by "&name=value": a second property that must hold too.
                     MOVE SPACES TO WS-COND1 WS-COND2 WS-NAME2 WS-WANT2
                     UNSTRING BSR-VAL(WS-R) DELIMITED BY "&" INTO WS-COND1 WS-COND2
                     IF WS-VALUE NOT = WS-COND1
                         MOVE 0 TO WS-APPLIES
                     END-IF
                     IF WS-COND2 NOT = SPACES
                         UNSTRING WS-COND2 DELIMITED BY "=" INTO WS-NAME2 WS-WANT2
                         CALL "BSH-PROP-VALUE" USING WS-NAME2 WS-VALUE
                         IF WS-VALUE NOT = WS-WANT2
                             MOVE 0 TO WS-APPLIES
                         END-IF
                     END-IF
                 END-IF
                 IF WS-APPLIES = 1
                     MOVE 1 TO WS-DONE
                     MOVE 1 TO WS-WHICH
                     CALL "BSH-COMPOSE" USING WS-WHICH WS-R WS-COLL
                     MOVE 2 TO WS-WHICH
                     CALL "BSH-COMPOSE" USING WS-WHICH WS-R WS-OUTV
                 END-IF
             END-PERFORM
             COMPUTE WS-S = WS-FIRST + WS-IDX + 1
             MOVE WS-COLL TO BSH-COLL(WS-S)
             MOVE WS-OUTV TO BSH-OUT(WS-S)
             CALL "BSH-LIGHT-DATA" USING CT-BR-CLASS WS-FLAGS WS-OUTV WS-COLL WS-OCCV WS-DAMPV WS-LFLG
             MOVE WS-OCCV TO BSH-OCC(WS-S)
             MOVE WS-DAMPV TO BSH-DAMP(WS-S)
             MOVE WS-LFLG TO BSH-LFLG(WS-S)
             IF WS-HITS > 0
                 MOVE 1 TO BSH-CLIMB(WS-S)
             END-IF
             MOVE WS-SLIPPERY TO BSH-SLIP(WS-S)
             MOVE WS-OFS TO BSH-OFS(WS-S)
             MOVE WS-SOFS TO BSH-SOFS(WS-S)
             IF CT-BR-CLASS = "LightBlock"
                 MOVE 1 TO BSH-CTX(WS-S)
             END-IF
*>           Scaffolding (51 section 3.8.5): the context kind 2 is distance 0, 3 a distance other than 0 without bottom, 4 a distance other than 0 with bottom
*>           (the plate rule): BSH-SCAFFOLD-COLL decides the collision by the entity, the table holds the stable shape of the empty context.
             EVALUATE CT-BR-CLASS
                 WHEN "CauldronBlock" WHEN "LavaCauldronBlock" WHEN "LayeredCauldronBlock" WHEN "ComposterBlock" WHEN "ScaffoldingBlock" WHEN "HopperBlock"
                     CALL "BSH-INTERACTION" USING CT-BR-CLASS WS-INT
                     MOVE WS-INT TO BSH-INT(WS-S)
             END-EVALUATE
             IF CT-BR-CLASS = "ScaffoldingBlock"
                 MOVE "distance" TO WS-NAME
                 CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                 MOVE 2 TO BSH-CTX(WS-S)
                 IF WS-VALUE NOT = "0"
                     MOVE "bottom" TO WS-NAME
                     CALL "BSH-PROP-VALUE" USING WS-NAME WS-VALUE
                     MOVE 3 TO BSH-CTX(WS-S)
                     IF WS-VALUE = "true"
                         MOVE 4 TO BSH-CTX(WS-S)
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO BSH-READY
     COMPUTE BSH-TYPE = CT-SET-TYPE + 1
     GOBACK.
 END PROGRAM BSH-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-ENSURE-CUBE.
*> No parameters: stores the full cube as shape 1 when no build has (the first query before any set is open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 PROCEDURE DIVISION.
     IF BSH-N(2) = 0
         INITIALIZE BSC-SHAPE
         MOVE 1 TO BSC-N
         MOVE 16000 TO BSC-V(1, 4) BSC-V(1, 5) BSC-V(1, 6)
         MOVE BSC-SHAPE TO BSH-SHAPE(2)
     END-IF
     GOBACK.
 END PROGRAM BSH-ENSURE-CUBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-COLL-ID.
*> USING state id (BINARY-LONG), shape id out (BINARY-LONG): the collision shape of the state; the full cube for every state but 0 (the
*> void) while the tables are not built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ID.
     EVALUATE TRUE
         WHEN BSH-READY = 1 AND L-STATE >= 0 AND L-STATE < BSH-MAX-STATES
             MOVE BSH-COLL(L-STATE + 1) TO L-ID
         WHEN L-STATE = 0
             MOVE 0 TO L-ID
         WHEN OTHER
             MOVE 1 TO L-ID
*>           Before the first build the full cube is not stored yet (no set open: the stand-in states are all full cubes).
             CALL "BSH-ENSURE-CUBE"
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-COLL-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-OUT-ID.
*> USING state id (BINARY-LONG), shape id out (BINARY-LONG): the outline shape of the state (as BSH-COLL-ID for the unbuilt tables).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ID.
     EVALUATE TRUE
         WHEN BSH-READY = 1 AND L-STATE >= 0 AND L-STATE < BSH-MAX-STATES
             MOVE BSH-OUT(L-STATE + 1) TO L-ID
         WHEN L-STATE = 0
             MOVE 0 TO L-ID
         WHEN OTHER
             MOVE 1 TO L-ID
*>           Before the first build the full cube is not stored yet (no set open: the stand-in states are all full cubes).
             CALL "BSH-ENSURE-CUBE"
     END-EVALUATE
     GOBACK.
 END PROGRAM BSH-OUT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-SCAFFOLD-COLL.
*> USING state id, cell y (BINARY-LONG), entity bottom (FLOAT-LONG: the entity's y when its collision context was built), descending (BINARY-LONG 1 when the
*> entity sneaks), shape id out: the collision shape of the state for that entity (51 section 3.8.5, rule R-C20). A scaffolding state: first match of (1) the entity is
*> above the full cube of the cell (bottom > cell y + 1 - 9.999999747378752E-6) and not descending: the stable shape (the table's collision); (2) the state has a distance other
*> than 0 and bottom set (BSH-CTX 4) and the entity is above the cell one lower (bottom > cell y - 9.999999747378752E-6): the plate (0,0,0,16,2,16); (3) nothing. Any other block
*> answers its table collision. The two floats are compared as integers in nanoblocks (two FLOAT-LONG items compare with a relative tolerance).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-BOTTOM              BINARY-DOUBLE.
 01 WS-TOP                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-CELL-Y               BINARY-LONG.
 01 L-BOTTOM               FLOAT-LONG.
 01 L-DESC                 BINARY-LONG.
 01 L-SHAPE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CELL-Y L-BOTTOM L-DESC L-SHAPE.
     CALL "BSH-COLL-ID" USING L-STATE L-SHAPE
     IF L-STATE > 0 AND L-STATE < BSH-MAX-STATES
         IF BSH-CTX(L-STATE + 1) >= 2
             COMPUTE WS-BOTTOM ROUNDED = L-BOTTOM * 1000000000
             COMPUTE WS-TOP ROUNDED = (L-CELL-Y + 1) * 1000000000 - 9999.999747378752
             IF NOT (WS-BOTTOM > WS-TOP AND L-DESC = 0)
                 MOVE 0 TO L-SHAPE
                 COMPUTE WS-TOP ROUNDED = L-CELL-Y * 1000000000 - 9999.999747378752
                 IF BSH-CTX(L-STATE + 1) = 4 AND WS-BOTTOM > WS-TOP
                     INITIALIZE BSC-SHAPE
                     MOVE 1 TO BSC-N
                     MOVE 16000 TO BSC-V(1, 4) BSC-V(1, 6)
                     MOVE 2000 TO BSC-V(1, 5)
                     CALL "BSH-INTERN" USING L-SHAPE
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BSH-SCAFFOLD-COLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-OVERLAPS.
*> USING shape id, cell x, y, z (BINARY-LONG), box (6 FLOAT-LONG), hit out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-OVER                FLOAT-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-X L-Y L-Z L-BOX L-HIT.
     MOVE 0 TO L-HIT
     MOVE L-X TO WS-CELL(1)
     MOVE L-Y TO WS-CELL(2)
     MOVE L-Z TO WS-CELL(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-SHAPE + 1) OR L-HIT = 1
         MOVE 1 TO WS-INSIDE
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-LO = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A) / 16000
             COMPUTE WS-HI = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A + 3) / 16000
             COMPUTE WS-OVER = FUNCTION MIN(L-B(WS-A + 3), WS-HI) - FUNCTION MAX(L-B(WS-A), WS-LO)
             IF WS-OVER <= WS-EPSILON
                 MOVE 0 TO WS-INSIDE
             END-IF
         END-PERFORM
         MOVE WS-INSIDE TO L-HIT
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-OVERLAPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-TOP.
*> USING shape id, cell x, y, z (BINARY-LONG), box (6 FLOAT-LONG), hit out (BINARY-LONG), top out (FLOAT-LONG): hit as BSH-OVERLAPS (some box of the shape placed in the cell overlaps the box
*> with positive volume), and top the highest y among the boxes that do (the cell's y plus the box's top in sixteenths: a slab's half cell, a carpet's pixel), 0 when none: the surface a body that
*> overlaps the shape comes to rest on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-OVER                FLOAT-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-HIT                  BINARY-LONG.
 01 L-TOP                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-X L-Y L-Z L-BOX L-HIT L-TOP.
     MOVE 0 TO L-HIT
     MOVE 0 TO L-TOP
     MOVE L-X TO WS-CELL(1)
     MOVE L-Y TO WS-CELL(2)
     MOVE L-Z TO WS-CELL(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-SHAPE + 1)
         MOVE 1 TO WS-INSIDE
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-LO = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A) / 16000
             COMPUTE WS-HI = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A + 3) / 16000
             COMPUTE WS-OVER = FUNCTION MIN(L-B(WS-A + 3), WS-HI) - FUNCTION MAX(L-B(WS-A), WS-LO)
             IF WS-OVER <= WS-EPSILON
                 MOVE 0 TO WS-INSIDE
             END-IF
         END-PERFORM
         IF WS-INSIDE = 1
             COMPUTE WS-HI = WS-CELL(2) + BSH-V(L-SHAPE + 1, WS-I, 5) / 16000
             IF L-HIT = 0 OR WS-HI > L-TOP
                 MOVE WS-HI TO L-TOP
             END-IF
             MOVE 1 TO L-HIT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-CLIP.
*> USING shape id, cell x, y, z (BINARY-LONG), box (6 FLOAT-LONG), axis (BINARY-LONG 1 to 3), distance (FLOAT-LONG in and out).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-OVER                FLOAT-LONG.
 01 WS-GAP                 FLOAT-LONG.
 01 WS-ACROSS              BINARY-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BOX.
    05 L-B                 FLOAT-LONG OCCURS 6 TIMES.
 01 L-AXIS                 BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-X L-Y L-Z L-BOX L-AXIS L-DISTANCE.
     MOVE L-X TO WS-CELL(1)
     MOVE L-Y TO WS-CELL(2)
     MOVE L-Z TO WS-CELL(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-SHAPE + 1)
         MOVE 1 TO WS-ACROSS
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             IF WS-A NOT = L-AXIS
                 COMPUTE WS-LO = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A) / 16000
                 COMPUTE WS-HI = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A + 3) / 16000
                 COMPUTE WS-OVER = FUNCTION MIN(L-B(WS-A + 3), WS-HI) - FUNCTION MAX(L-B(WS-A), WS-LO)
                 IF WS-OVER <= WS-EPSILON
                     MOVE 0 TO WS-ACROSS
                 END-IF
             END-IF
         END-PERFORM
         IF WS-ACROSS = 1
             COMPUTE WS-LO = WS-CELL(L-AXIS) + BSH-V(L-SHAPE + 1, WS-I, L-AXIS) / 16000
             COMPUTE WS-HI = WS-CELL(L-AXIS) + BSH-V(L-SHAPE + 1, WS-I, L-AXIS + 3) / 16000
             EVALUATE TRUE
                 WHEN L-DISTANCE > 0
                     COMPUTE WS-GAP = WS-LO - L-B(L-AXIS + 3)
                     IF WS-GAP >= 0 - WS-EPSILON AND WS-GAP < L-DISTANCE
                         COMPUTE L-DISTANCE = FUNCTION MAX(WS-GAP, 0)
                     END-IF
                 WHEN L-DISTANCE < 0
                     COMPUTE WS-GAP = WS-HI - L-B(L-AXIS)
                     IF WS-GAP <= WS-EPSILON AND WS-GAP > L-DISTANCE
                         COMPUTE L-DISTANCE = FUNCTION MIN(WS-GAP, 0)
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-CLIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-RAY.
*> USING shape id, cell x, y, z (BINARY-LONG), origin (3 FLOAT-LONG), direction (3 FLOAT-LONG), t out (FLOAT-LONG), axis out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG.
 01 WS-FAR                 FLOAT-LONG.
 01 WS-NEAR-AXIS           BINARY-LONG.
 01 WS-CELL                FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ORG.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-DIR.
    05 L-D                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-T                    FLOAT-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-X L-Y L-Z L-ORG L-DIR L-T L-AXIS.
     MOVE -1 TO L-T
     MOVE 0 TO L-AXIS
     MOVE L-X TO WS-CELL(1)
     MOVE L-Y TO WS-CELL(2)
     MOVE L-Z TO WS-CELL(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BSH-N(L-SHAPE + 1)
         MOVE -1.0E30 TO WS-NEAR
         MOVE 1.0E30 TO WS-FAR
         MOVE 0 TO WS-NEAR-AXIS
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-LO = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A) / 16000
             COMPUTE WS-HI = WS-CELL(WS-A) + BSH-V(L-SHAPE + 1, WS-I, WS-A + 3) / 16000
             IF L-D(WS-A) = 0
                 IF L-O(WS-A) < WS-LO OR L-O(WS-A) > WS-HI
                     MOVE -1.0E30 TO WS-FAR
                 END-IF
             ELSE
                 COMPUTE WS-T1 = (WS-LO - L-O(WS-A)) / L-D(WS-A)
                 COMPUTE WS-T2 = (WS-HI - L-O(WS-A)) / L-D(WS-A)
                 IF FUNCTION MIN(WS-T1, WS-T2) > WS-NEAR
                     COMPUTE WS-NEAR = FUNCTION MIN(WS-T1, WS-T2)
                     MOVE WS-A TO WS-NEAR-AXIS
                 END-IF
                 COMPUTE WS-FAR = FUNCTION MIN(WS-FAR, FUNCTION MAX(WS-T1, WS-T2))
             END-IF
         END-PERFORM
         IF WS-NEAR <= WS-FAR AND WS-FAR >= 0 AND WS-NEAR-AXIS > 0
             COMPUTE WS-NEAR = FUNCTION MAX(WS-NEAR, 0)
             IF L-AXIS = 0 OR WS-NEAR < L-T
                 MOVE WS-NEAR TO L-T
                 MOVE WS-NEAR-AXIS TO L-AXIS
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BSH-RAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-MODEL-OFFSET.
*> USING state id, cell x, y, z (BINARY-LONG), dx, dy, dz out (FLOAT-LONG, blocks): the model offset of a block of an offset kind (51 section 1.4) at that cell; 0 for any
*> other state. h = (int)(x 3129871) sign extended, XOR z 116129781 (64 bits), XOR y with y = 0 (both kinds take the seed at y 0, so the cell's own y is unused); seed =
*> (h h 42317861 + h 11) >> 16 (64 bit wrap, arithmetic shift); dx = clamp(((seed AND 15) / 15 - 0.5) 0.5, -m, m), dz the same from (seed >> 8) AND 15, and for the XYZ
*> kinds dy = ((seed >> 4 AND 15) / 15 - 1) v; m 0.25 (0.125 for kind 3), v 0.2 (0.1 for kind 4). The divisions are in 32-bit floats.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M32                 BINARY-DOUBLE UNSIGNED VALUE 4294967296.
 01 WS-H63                 BINARY-DOUBLE UNSIGNED VALUE 9223372036854775808.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-DOUBLE UNSIGNED.
 01 WS-L                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE.
 01 WS-T                   BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   FLOAT-SHORT.
 01 WS-LIMIT               FLOAT-SHORT.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ WS-KIND
     IF L-STATE > 0 AND L-STATE < BSH-MAX-STATES
         MOVE BSH-OFS(L-STATE + 1) TO WS-KIND
     END-IF
     IF WS-KIND = 0
         GOBACK
     END-IF
     COMPUTE WS-A = FUNCTION MOD(L-X * 3129871, WS-M32)
     IF WS-A >= 2147483648
         COMPUTE WS-A = WS-A + WS-M64 - WS-M32
     END-IF
     COMPUTE WS-B = FUNCTION MOD(L-Z * 116129781, WS-M64)
     CALL "CBL_XOR" USING WS-A WS-B BY VALUE 8
     MOVE WS-B TO WS-L
     IF WS-L >= WS-H63
         COMPUTE WS-S = WS-L - WS-M64
     ELSE
         MOVE WS-L TO WS-S
     END-IF
     COMPUTE WS-T = FUNCTION MOD(WS-S * WS-S * 42317861 + WS-S * 11, WS-M64)
     IF WS-T >= WS-H63
         COMPUTE WS-S = WS-T - WS-M64
     ELSE
         MOVE WS-T TO WS-S
     END-IF
     COMPUTE WS-SEED = FUNCTION INTEGER(WS-S / 65536)
     MOVE 0.25 TO WS-LIMIT
     IF WS-KIND = 3
         MOVE 0.125 TO WS-LIMIT
     END-IF
     MOVE WS-LIMIT TO WS-MAX
     COMPUTE WS-N = FUNCTION MOD(WS-SEED, 16)
     COMPUTE WS-F = WS-N / 15
     COMPUTE L-DX = FUNCTION MAX(0 - WS-MAX, FUNCTION MIN(WS-MAX, (WS-F - 0.5) * 0.5))
     COMPUTE WS-N = FUNCTION MOD(FUNCTION INTEGER(WS-SEED / 256), 16)
     COMPUTE WS-F = WS-N / 15
     COMPUTE L-DZ = FUNCTION MAX(0 - WS-MAX, FUNCTION MIN(WS-MAX, (WS-F - 0.5) * 0.5))
     IF WS-KIND = 2 OR WS-KIND = 4
         COMPUTE WS-N = FUNCTION MOD(FUNCTION INTEGER(WS-SEED / 16), 16)
         COMPUTE WS-F = WS-N / 15
         IF WS-KIND = 4
             COMPUTE L-DY = (WS-F - 1.0) * 0.1
         ELSE
             COMPUTE L-DY = (WS-F - 1.0) * 0.2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BSH-MODEL-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSH-OFFSET.
*> USING state id, cell x, y, z (BINARY-LONG), dx, dy, dz out (FLOAT-LONG, blocks): the offset that moves the SHAPES of the block (51 section 1.4, R4): the model offset of the flower family,
*> bamboo stalk and sapling, speleothems and mangrove propagule (BSH-SOFS 1), 0 for every other state (the other offset blocks move only their drawn model, BSH-MODEL-OFFSET).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     IF L-STATE > 0 AND L-STATE < BSH-MAX-STATES
         IF BSH-SOFS(L-STATE + 1) = 1
             CALL "BSH-MODEL-OFFSET" USING L-STATE L-X L-Y L-Z L-DX L-DY L-DZ
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BSH-OFFSET.
