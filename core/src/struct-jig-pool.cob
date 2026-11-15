*> Template pools and pool elements of the jigsaw assembly (docs/protocol/36-structures-3 sections 3.2, 3.3, 4.3, 5 and 6; tables in STRUCTJIG.cpy): the pools are read on demand from
*> worldgen/template_pool (FD-FETCH) with their elements and cached until JIG-RESET; an element answers its bounding box (5), its shuffled jigsaw list (4.3) and a pool its getMaxSize (6).
*> Deviations: an inline processor list of an element that is not empty (the data has none: 1439 inline lists are all empty) is read as no list; a template that is not loaded has a one cell
*> box and no jigsaw; the palette of a template with several palettes is the one chosen at the origin (no template of the jar that holds a jigsaw has more than one, 36-3 4.3).
*>
*> Entry points:
*>   JIG-RESET: empties the pools, the elements and the jigsaw records of the templates (row 1 of the elements is the empty element, row 1 of the pools minecraft:empty)
*>   JIG-POOL-FIND USING key (PIC X(80), with namespace), row out: the pool's row, 0 when no such pool (or a table is full); its fallback is read with it
*>   JIG-TPL-JIGS USING template row, first out, count out: the run of the template's jigsaw records in JX (block order)
*>   JIG-ROT-DIR USING direction, rotation, direction out: the direction turned by the rotation (the horizontal ones clockwise, up and down unchanged)
*>   JIG-EL-BOX USING element row, x, y, z (the position), rotation, box out (6 BINARY-LONG: min x y z, max x y z): getBoundingBox (5.1, 5.3, 5.5)
*>   JIG-EL-JIGS USING element row, x, y, z, rotation: STRUCT-JIG-LIST of the element at the position: the transformed jigsaws, shuffled with the start random SP-RNG (n - 1 draws) and sorted
*>     stably by selection priority, highest first (4.3); a list element gives its first sub-element's, a feature element one synthetic jigsaw, an empty element none
*>   JIG-POOL-MAXSIZE USING pool row, value out: getMaxSize (6): the largest Y span of the elements' boxes at the origin without rotation

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     ADD 1 TO JIG-GEN
     MOVE 0 TO JP-COUNT JN-USED JE-COUNT JS-COUNT JX-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         MOVE SPACES TO JT-KEY(WS-I)
     END-PERFORM
*>   the shared empty element and the pool minecraft:empty (no entries, fallback itself)
     MOVE 1 TO JE-COUNT
     MOVE 5 TO JE-KIND(1)
     MOVE 1 TO JE-PROJ(1)
     MOVE 0 TO JE-SUB-FIRST(1) JE-SUB-N(1)
     MOVE SPACES TO JE-LOC(1) JE-PROC(1) JE-FEATURE(1)
     MOVE 1 TO JP-COUNT
     MOVE "minecraft:empty" TO JP-KEY(1)
     MOVE 1 TO JP-STATUS(1) JP-FALLBACK(1)
     MOVE 0 TO JP-FIRST(1) JP-N(1) JP-TOTAL(1) JP-MAXSIZE(1)
     GOBACK.
 END PROGRAM JIG-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-EL-PARSE RECURSIVE.
*> USING doc, element object node, row out: one pool element (3.3). The projection of a list is put on its sub-elements (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 01 WS-TEXT                PIC X(120).
 01 WS-KEY                 PIC X(80).
 01 WS-LEN                 BINARY-LONG.
 01 K-TYPE                 PIC X(40) VALUE "element_type".
 01 K-PROJECTION           PIC X(40) VALUE "projection".
 01 K-LOCATION             PIC X(40) VALUE "location".
 01 K-PROCESSORS           PIC X(40) VALUE "processors".
 01 K-ELEMENTS             PIC X(40) VALUE "elements".
 01 K-FEATURE              PIC X(40) VALUE "feature".
 LOCAL-STORAGE SECTION.
 01 LS-ROW                 BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-ARRAY               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-SUBS.
    05 LS-SUB              BINARY-LONG OCCURS 32 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     GO TO MAIN-LINE.


*> location and the processor list: a name, or an inline list (read as none: the data's inline lists are empty)
 READ-SINGLE.
     CALL "FD-J-STRING" USING JSON-DOC K-LOCATION L-NODE WS-TEXT WS-LEN
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO JE-LOC(LS-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-PROCESSORS LS-NODE
     IF LS-NODE > 0
         IF JN-TYPE(LS-NODE) = JT-STRING
             CALL "FD-J-STRING-OF" USING JSON-DOC LS-NODE WS-TEXT
             CALL "FD-KEY" USING WS-TEXT WS-KEY
             MOVE WS-KEY TO JE-PROC(LS-ROW)
         END-IF
     END-IF.

*> the sub-elements are parsed first (they take rows after this one) and then listed in JS
 READ-LIST.
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-ELEMENTS LS-ARRAY
     MOVE 0 TO LS-N
     IF LS-ARRAY > 0
         PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-ARRAY) OR LS-N >= 32
             CALL "JSON-ELEMENT" USING JSON-DOC LS-ARRAY LS-I LS-NODE
             ADD 1 TO LS-N
             CALL "JIG-EL-PARSE" USING JSON-DOC LS-NODE LS-SUB(LS-N)
         END-PERFORM
     END-IF
     IF JS-COUNT + LS-N > JS-MAX
         MOVE 0 TO LS-N
     END-IF
     COMPUTE JE-SUB-FIRST(LS-ROW) = JS-COUNT + 1
     MOVE LS-N TO JE-SUB-N(LS-ROW)
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-N
         ADD 1 TO JS-COUNT
         MOVE LS-SUB(LS-I) TO JS-ELEM(JS-COUNT)
         IF LS-SUB(LS-I) > 1
             MOVE JE-PROJ(LS-ROW) TO JE-PROJ(LS-SUB(LS-I))
         END-IF
     END-PERFORM.

 MAIN-LINE.
     MOVE 1 TO L-ROW
     CALL "FD-J-STRING" USING JSON-DOC K-TYPE L-NODE WS-TEXT WS-LEN
     MOVE 0 TO LS-KIND
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:single_pool_element"
             MOVE 1 TO LS-KIND
         WHEN "minecraft:legacy_single_pool_element"
             MOVE 2 TO LS-KIND
         WHEN "minecraft:list_pool_element"
             MOVE 3 TO LS-KIND
         WHEN "minecraft:feature_pool_element"
             MOVE 4 TO LS-KIND
     END-EVALUATE
*>   an empty element, an unknown type or a full table is the shared empty element
     IF LS-KIND = 0 OR JE-COUNT >= JE-MAX
         GOBACK
     END-IF
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO LS-ROW
     MOVE LS-KIND TO JE-KIND(LS-ROW)
     MOVE 0 TO JE-PROJ(LS-ROW) JE-SUB-FIRST(LS-ROW) JE-SUB-N(LS-ROW)
     MOVE SPACES TO JE-LOC(LS-ROW) JE-PROC(LS-ROW) JE-FEATURE(LS-ROW)
     CALL "FD-J-STRING" USING JSON-DOC K-PROJECTION L-NODE WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) = "terrain_matching"
         MOVE 1 TO JE-PROJ(LS-ROW)
     END-IF
     EVALUATE LS-KIND
         WHEN 1
             PERFORM READ-SINGLE
         WHEN 2
             PERFORM READ-SINGLE
         WHEN 3
             PERFORM READ-LIST
         WHEN OTHER
             CALL "FD-J-STRING" USING JSON-DOC K-FEATURE L-NODE WS-TEXT WS-LEN
             CALL "FD-KEY" USING WS-TEXT WS-KEY
             MOVE WS-KEY TO JE-FEATURE(LS-ROW)
     END-EVALUATE
     MOVE LS-ROW TO L-ROW
     GOBACK.
 END PROGRAM JIG-EL-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-POOL-FIND RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 COPY JSONDOC.
 01 WS-REGISTRY            PIC X(32) VALUE "template_pool".
 01 WS-TEXT                PIC X(65536).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-STR                 PIC X(120).
 01 WS-FB-KEY              PIC X(80).
 01 WS-SLEN                BINARY-LONG.
 01 K-ELEMENTS             PIC X(40) VALUE "elements".
 01 K-ELEMENT              PIC X(40) VALUE "element".
 01 K-WEIGHT               PIC X(40) VALUE "weight".
 01 K-FALLBACK             PIC X(40) VALUE "fallback".
 LOCAL-STORAGE SECTION.
 01 LS-ROW                 BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-ARRAY               BINARY-LONG.
 01 LS-ENTRY               BINARY-LONG.
 01 LS-NODE                BINARY-LONG.
 01 LS-EL                  BINARY-LONG.
 01 LS-WEIGHT              BINARY-LONG.
 01 LS-WNODE               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-FALLBACK            BINARY-LONG.
 01 LS-KEY                 PIC X(80).
 01 LS-FB-KEY              PIC X(80).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     IF JE-COUNT = 0
         CALL "JIG-RESET"
     END-IF
     MOVE L-KEY TO LS-KEY
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > JP-COUNT
         IF JP-KEY(LS-I) = LS-KEY
             IF JP-STATUS(LS-I) = 1
                 MOVE LS-I TO L-ROW
             END-IF
             GOBACK
         END-IF
     END-PERFORM
     IF JP-COUNT >= JP-MAX
         GOBACK
     END-IF
     ADD 1 TO JP-COUNT
     MOVE JP-COUNT TO LS-ROW
     MOVE LS-KEY TO JP-KEY(LS-ROW)
     MOVE 2 TO JP-STATUS(LS-ROW)
     MOVE 1 TO JP-FALLBACK(LS-ROW)
     MOVE 0 TO JP-FIRST(LS-ROW) JP-N(LS-ROW) JP-TOTAL(LS-ROW)
     MOVE -1 TO JP-MAXSIZE(LS-ROW)
     MOVE SPACES TO WS-TEXT
     CALL "FD-FETCH" USING WS-REGISTRY LS-KEY WS-TEXT WS-LEN WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     IF JD-ERROR NOT = 0 OR JD-COUNT = 0
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-ELEMENTS LS-ARRAY
     IF LS-ARRAY = 0 OR JN-COUNT(LS-ARRAY) + JN-USED > JN-MAX
         GOBACK
     END-IF
     COMPUTE JP-FIRST(LS-ROW) = JN-USED + 1
     PERFORM VARYING LS-ENTRY FROM 0 BY 1 UNTIL LS-ENTRY >= JN-COUNT(LS-ARRAY)
         CALL "JSON-ELEMENT" USING JSON-DOC LS-ARRAY LS-ENTRY LS-NODE
         CALL "FD-J-MEMBER" USING JSON-DOC LS-NODE K-ELEMENT LS-EL
         CALL "FD-J-MEMBER" USING JSON-DOC LS-NODE K-WEIGHT LS-WNODE
         CALL "FD-J-INT" USING JSON-DOC LS-WNODE LS-WEIGHT LS-OK
         ADD 1 TO JN-USED
         CALL "JIG-EL-PARSE" USING JSON-DOC LS-EL JN-ELEM(JN-USED)
         MOVE LS-WEIGHT TO JN-WEIGHT(JN-USED)
         ADD LS-WEIGHT TO JP-TOTAL(LS-ROW)
     END-PERFORM
     COMPUTE JP-N(LS-ROW) = JN-USED - JP-FIRST(LS-ROW) + 1
     CALL "FD-J-STRING" USING JSON-DOC K-FALLBACK 1 WS-STR WS-SLEN
     CALL "FD-KEY" USING WS-STR WS-FB-KEY
     MOVE WS-FB-KEY TO LS-FB-KEY
     MOVE 1 TO JP-STATUS(LS-ROW)
     IF LS-FB-KEY NOT = "minecraft:empty"
         CALL "JIG-POOL-FIND" USING LS-FB-KEY LS-FALLBACK
         IF LS-FALLBACK > 0
             MOVE LS-FALLBACK TO JP-FALLBACK(LS-ROW)
         END-IF
     END-IF
     MOVE LS-ROW TO L-ROW
     GOBACK.
 END PROGRAM JIG-POOL-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-TPL-JIGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FIRST L-N.
     MOVE 0 TO L-FIRST L-N
     IF JT-KEY(L-ROW) = TP-KEY(L-ROW)
         MOVE JT-FIRST(L-ROW) TO L-FIRST
         MOVE JT-N(L-ROW) TO L-N
         GOBACK
     END-IF
     IF JX-COUNT + 128 > JX-MAX
*>       the record table is full: forget the templates' jigsaws (they are found again when asked)
         MOVE 0 TO JX-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             MOVE SPACES TO JT-KEY(WS-I)
         END-PERFORM
     END-IF
     COMPUTE L-FIRST = JX-COUNT + 1
     CALL "STRUCT-PALETTE-PICK" USING TP-PALETTES(L-ROW) WS-ZERO WS-Z2 WS-Z3 WS-INDEX
     IF WS-INDEX >= 0
         COMPUTE WS-BASE = TP-BASE(L-ROW, WS-INDEX + 1)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TP-BLOCKS(L-ROW)
             MOVE TB-NBT(WS-BASE + WS-I) TO WS-TAG
             IF WS-TAG > 0
                 IF TN-KIND(WS-TAG) = 4 AND JX-COUNT < JX-MAX
                     ADD 1 TO JX-COUNT
                     MOVE TB-X(WS-BASE + WS-I) TO JX-X(JX-COUNT)
                     MOVE TB-Y(WS-BASE + WS-I) TO JX-Y(JX-COUNT)
                     MOVE TB-Z(WS-BASE + WS-I) TO JX-Z(JX-COUNT)
                     MOVE TB-STATE(WS-BASE + WS-I) TO WS-STATE
                     CALL "STRUCT-JIG-DIRS" USING WS-STATE JX-FRONT(JX-COUNT) JX-TOP(JX-COUNT)
                     MOVE TN-JOINT(WS-TAG) TO JX-JOINT(JX-COUNT)
                     IF JX-JOINT(JX-COUNT) = 0
                         MOVE 2 TO JX-JOINT(JX-COUNT)
                         IF JX-FRONT(JX-COUNT) >= 2
                             MOVE 1 TO JX-JOINT(JX-COUNT)
                         END-IF
                     END-IF
                     MOVE WS-TAG TO JX-TAG(JX-COUNT)
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     COMPUTE L-N = JX-COUNT - L-FIRST + 1
     MOVE TP-KEY(L-ROW) TO JT-KEY(L-ROW)
     MOVE L-FIRST TO JT-FIRST(L-ROW)
     MOVE L-N TO JT-N(L-ROW)
     GOBACK.
 END PROGRAM JIG-TPL-JIGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ROT-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> clockwise 90 turns north into east into south into west into north
 01 WS-CYCLE               PIC X(4) VALUE X"02050304".
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-ROT L-OUT.
     MOVE L-DIR TO L-OUT
     IF L-DIR >= 2
         EVALUATE L-DIR
             WHEN 2
                 MOVE 0 TO WS-I
             WHEN 5
                 MOVE 1 TO WS-I
             WHEN 3
                 MOVE 2 TO WS-I
             WHEN OTHER
                 MOVE 3 TO WS-I
         END-EVALUATE
         COMPUTE WS-I = FUNCTION MOD(WS-I + L-ROT, 4)
         MOVE FUNCTION ORD(WS-CYCLE(WS-I + 1:1)) TO L-OUT
         SUBTRACT 1 FROM L-OUT
     END-IF
     GOBACK.
 END PROGRAM JIG-ROT-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-EL-BOX RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY STRUCTDATA.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-ANY                 BINARY-LONG.
 01 LS-SUB                 BINARY-LONG.
 01 LS-BOX.
    05 LS-B                BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-EL                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-BOX.
    05 L-BOX-V             BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-EL L-X L-Y L-Z L-ROT L-BOX.
     GO TO MAIN-LINE.


 TEMPLATE-BOX.
     CALL "STRUCT-TPL-LOAD" USING SD-DIR JE-LOC(L-EL) LS-ROW
     IF LS-ROW > 0
         IF TP-STATUS(LS-ROW) = 1
             CALL "STRUCT-TX-BOX" USING TP-SX(LS-ROW) TP-SY(LS-ROW) TP-SZ(LS-ROW) WS-ZERO L-ROT WS-Z2 WS-Z3 L-X L-Y L-Z L-BOX
         END-IF
     END-IF.

 MAIN-LINE.
*>   the box of a point (a feature element, a template that is not loaded, and the element that has none)
     MOVE L-X TO L-BOX-V(1) L-BOX-V(4)
     MOVE L-Y TO L-BOX-V(2) L-BOX-V(5)
     MOVE L-Z TO L-BOX-V(3) L-BOX-V(6)
     EVALUATE JE-KIND(L-EL)
         WHEN 1
             PERFORM TEMPLATE-BOX
         WHEN 2
             PERFORM TEMPLATE-BOX
         WHEN 3
             MOVE 0 TO LS-ANY
             PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JE-SUB-N(L-EL)
                 MOVE JS-ELEM(JE-SUB-FIRST(L-EL) + LS-I) TO LS-SUB
                 IF JE-KIND(LS-SUB) NOT = 5
                     CALL "JIG-EL-BOX" USING LS-SUB L-X L-Y L-Z L-ROT LS-BOX
                     IF LS-ANY = 0
                         MOVE LS-BOX TO L-BOX
                         MOVE 1 TO LS-ANY
                     ELSE
                         PERFORM VARYING LS-ROW FROM 1 BY 1 UNTIL LS-ROW > 3
                             MOVE FUNCTION MIN(L-BOX-V(LS-ROW), LS-B(LS-ROW)) TO L-BOX-V(LS-ROW)
                             MOVE FUNCTION MAX(L-BOX-V(LS-ROW + 3), LS-B(LS-ROW + 3)) TO L-BOX-V(LS-ROW + 3)
                         END-PERFORM
                     END-IF
                 END-IF
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM JIG-EL-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-EL-JIGS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-MIRROR              BINARY-LONG VALUE 0.
 01 WS-PX                  BINARY-LONG VALUE 0.
 01 WS-PZ                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-TMP.
    05 FILLER              PIC X(36).
 LINKAGE SECTION.
 01 L-EL                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EL L-X L-Y L-Z L-ROT.
     GO TO MAIN-LINE.


 TEMPLATE-JIGS.
     CALL "STRUCT-TPL-LOAD" USING SD-DIR JE-LOC(L-EL) WS-ROW
     IF WS-ROW > 0
         IF TP-STATUS(WS-ROW) = 1
             CALL "JIG-TPL-JIGS" USING WS-ROW WS-FIRST WS-N
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N OR WS-I >= JW-MAX
                 COMPUTE WS-K = WS-FIRST + WS-I
                 MOVE JX-X(WS-K) TO WS-X
                 MOVE JX-Y(WS-K) TO WS-Y
                 MOVE JX-Z(WS-K) TO WS-Z
                 CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR L-ROT WS-PX WS-PZ WS-RX WS-RY WS-RZ
                 ADD 1 TO JW-COUNT
                 COMPUTE JW-X(JW-COUNT) = L-X + WS-RX
                 COMPUTE JW-Y(JW-COUNT) = L-Y + WS-RY
                 COMPUTE JW-Z(JW-COUNT) = L-Z + WS-RZ
                 CALL "JIG-ROT-DIR" USING JX-FRONT(WS-K) L-ROT JW-FRONT(JW-COUNT)
                 CALL "JIG-ROT-DIR" USING JX-TOP(WS-K) L-ROT JW-TOP(JW-COUNT)
                 MOVE JX-JOINT(WS-K) TO JW-JOINT(JW-COUNT)
                 MOVE JX-TAG(WS-K) TO JW-TAG(JW-COUNT)
                 MOVE TN-PRIO-PLACE(JX-TAG(WS-K)) TO JW-PLACE(JW-COUNT)
                 MOVE TN-PRIO-SELECT(JX-TAG(WS-K)) TO JW-SELECT(JW-COUNT)
             END-PERFORM
*>           Util.shuffle (2.3): from the end, j = nextInt(i), swap the items at i - 1 and j
             PERFORM VARYING WS-I FROM JW-COUNT BY -1 UNTIL WS-I < 2
                 CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-I WS-J
                 ADD 1 TO WS-J
                 MOVE JW-REC(WS-I) TO WS-TMP
                 MOVE JW-REC(WS-J) TO JW-REC(WS-I)
                 MOVE WS-TMP TO JW-REC(WS-J)
             END-PERFORM
*>           the stable sort by selection priority, highest first (insertion sort: an item moves up past the lower ones)
             PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > JW-COUNT
                 MOVE WS-I TO WS-J
                 MOVE 1 TO WS-GO
                 PERFORM UNTIL WS-GO = 0
                     IF WS-J < 2
                         MOVE 0 TO WS-GO
                     ELSE
                         IF JW-SELECT(WS-J - 1) >= JW-SELECT(WS-J)
                             MOVE 0 TO WS-GO
                         ELSE
                             MOVE JW-REC(WS-J) TO WS-TMP
                             MOVE JW-REC(WS-J - 1) TO JW-REC(WS-J)
                             MOVE WS-TMP TO JW-REC(WS-J - 1)
                             SUBTRACT 1 FROM WS-J
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-IF.

 MAIN-LINE.
     MOVE 0 TO JW-COUNT
     EVALUATE JE-KIND(L-EL)
         WHEN 1
             PERFORM TEMPLATE-JIGS
         WHEN 2
             PERFORM TEMPLATE-JIGS
         WHEN 3
             IF JE-SUB-N(L-EL) > 0
                 MOVE JS-ELEM(JE-SUB-FIRST(L-EL)) TO WS-SUB
                 CALL "JIG-EL-JIGS" USING WS-SUB L-X L-Y L-Z L-ROT
             END-IF
         WHEN 4
*>           5.5: one synthetic jigsaw at the position, orientation down_south, rollable, no name, no priority
             MOVE 1 TO JW-COUNT
             MOVE L-X TO JW-X(1)
             MOVE L-Y TO JW-Y(1)
             MOVE L-Z TO JW-Z(1)
             MOVE 0 TO JW-FRONT(1) JW-TAG(1) JW-PLACE(1) JW-SELECT(1)
             MOVE 3 TO JW-TOP(1)
             MOVE 2 TO JW-JOINT(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM JIG-EL-JIGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-POOL-MAXSIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 01 WS-I                   BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-POOL                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-POOL L-VALUE.
     IF JP-MAXSIZE(L-POOL) < 0
         MOVE 0 TO JP-MAXSIZE(L-POOL)
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(L-POOL)
             MOVE JN-ELEM(JP-FIRST(L-POOL) + WS-I) TO WS-EL
             IF JE-KIND(WS-EL) NOT = 5
                 CALL "JIG-EL-BOX" USING WS-EL WS-ZERO WS-Z2 WS-Z3 WS-Z4 WS-BOX
                 MOVE FUNCTION MAX(JP-MAXSIZE(L-POOL), WS-B(5) - WS-B(2) + 1) TO JP-MAXSIZE(L-POOL)
             END-IF
         END-PERFORM
     END-IF
     MOVE JP-MAXSIZE(L-POOL) TO L-VALUE
     GOBACK.
 END PROGRAM JIG-POOL-MAXSIZE.
