*> Acceptance test of the placement of jigsaw pieces (docs/protocol/36-structures-3 sections 5, 12.4, 14.3; core/src/struct-jig-place.cob): the processor list of an element (5.1, 5.2: the
*> structure-block ignore, the jigsaw replacement, the element's list and the projection's gravity, the legacy order), a piece placed through the chunk window by STRUCT-PLACE-START (a
*> jigsaw becomes its final_state, an air final_state leaves the terrain of a legacy element, a piece outside the window is not written), a list element in order that stops at its first
*> failure, and the elements that write nothing here (a feature, the empty element). Runs over the standard content set of the generated packs (skipped as a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-JIGSAW-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY STRUCTPROC.
 COPY STRUCTJIG.
 COPY JIGTEST.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-LIST2               BINARY-LONG.
 01 WS-SAVE                BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-PTR                 USAGE POINTER.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-WCX                 BINARY-LONG VALUE 4.
 01 WS-WCZ                 BINARY-LONG VALUE 4.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-POOL-DIR            PIC X(1100) VALUE "core/tests/fixtures/jigpool".
 01 WS-FIRST               BINARY-LONG.
 01 WS-DIAMOND             BINARY-LONG.
 01 WS-TYPE-PIECE          BINARY-LONG VALUE 60.
 01 WS-ORIENT              BINARY-LONG VALUE -1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-BOXG.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==G-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "test struct jigsaw place no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-PROC-RESET"
     CALL "JIG-RESET"
     MOVE WS-TPL-DIR TO SD-DIR
     MOVE WS-POOL-DIR TO FD-DIR
     PERFORM PROC-CASES
     PERFORM WINDOW-CASES
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> an element row of the kind, projection and processor list key
 NEW-ELEMENT.
     ADD 1 TO JE-COUNT
     MOVE JE-COUNT TO WS-EL
     MOVE WS-ROW TO JE-KIND(WS-EL)
     MOVE 0 TO JE-SUB-FIRST(WS-EL) JE-SUB-N(WS-EL) JE-PROJ(WS-EL)
     MOVE SPACES TO JE-FEATURE(WS-EL) JE-PROC(WS-EL)
     MOVE "test:jleaf" TO JE-LOC(WS-EL).

*> 5.1, 5.2: the processors of an element
 PROC-CASES.
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 0 TO JE-PROJ(WS-EL)
     MOVE SPACES TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE "test struct jigsaw place given a single element with no list and a rigid projection when its processors are made then they are the structure-block ignore and the jigsaw replacement" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 2 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 9 AND SPP-N(SPL-FIRST(WS-LIST)) = 1 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 6
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE SP-LIST-COUNT TO WS-SAVE
     CALL "JIG-PROCS" USING WS-EL WS-LIST2
     MOVE "test struct jigsaw place given the same element when its processors are made again then it is the same list" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST2 = WS-LIST AND SP-LIST-COUNT = WS-SAVE
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 2 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 0 TO JE-PROJ(WS-EL)
     MOVE SPACES TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE "test struct jigsaw place given a legacy element with no list when its processors are made then they are the jigsaw replacement and the structure-block-and-air ignore at the end" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 2 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 6 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 9 AND SPP-N(SPL-FIRST(WS-LIST) + 1) = 2
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 1 TO JE-PROJ(WS-EL)
     MOVE "test:swap" TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE "test struct jigsaw place given a single terrain matching element with a list when its processors are made then they are ignore, replacement, the rule and the gravity" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 4 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 9 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 6 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 2) = 1
            AND SPP-TYPE(SPL-FIRST(WS-LIST) + 3) = 5 AND SPP-A(SPL-FIRST(WS-LIST) + 3) = 0 AND SPP-B(SPL-FIRST(WS-LIST) + 3) = -1
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE 2 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 1 TO JE-PROJ(WS-EL)
     MOVE "test:swap" TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE "test struct jigsaw place given a legacy terrain matching element with a list when its processors are made then they are replacement, the rule, the gravity and the ignore at the end" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 4 AND SPP-TYPE(SPL-FIRST(WS-LIST)) = 6 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 1) = 1 AND SPP-TYPE(SPL-FIRST(WS-LIST) + 2) = 5
            AND SPP-TYPE(SPL-FIRST(WS-LIST) + 3) = 9
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 0 TO JE-PROJ(WS-EL)
     MOVE "test:no_such_list" TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE "test struct jigsaw place given a list that does not exist when the processors are made then the element has none of its own" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST > 0
         IF SPL-N(WS-LIST) = 2
             MOVE 1 TO WS-FLAG
         END-IF
     END-IF
     PERFORM CHECK
*>   the list table is full: no list is made
     MOVE SP-LIST-COUNT TO WS-SAVE
     MOVE SP-MAX-LISTS TO SP-LIST-COUNT
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE "test:swap" TO JE-PROC(WS-EL)
     CALL "JIG-PROCS" USING WS-EL WS-LIST
     MOVE WS-SAVE TO SP-LIST-COUNT
     MOVE "test struct jigsaw place given a full list table when the processors of a new kind of element are made then there are none" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-LIST = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> a piece in the builder: element WS-EL at (WS-X, WS-Y, WS-Z), rotation 0, box of the template at that position
 NEW-PIECE.
     MOVE WS-X TO G-X0
     MOVE WS-Y TO G-Y0
     MOVE WS-Z TO G-Z0
     COMPUTE G-X1 = WS-X + 2
     COMPUTE G-Y1 = WS-Y + 1
     COMPUTE G-Z1 = WS-Z + 2
     CALL "SPB-ADD" USING WS-TYPE-PIECE WS-ORIENT WS-ZERO WS-Z2 WS-BOXG WS-PIECE
     MOVE WS-EL TO SP-F1(WS-PIECE)
     MOVE 1 TO SP-F2(WS-PIECE)
     MOVE WS-X TO SP-T-X(WS-PIECE)
     MOVE WS-Y TO SP-T-Y(WS-PIECE)
     MOVE WS-Z TO SP-T-Z(WS-PIECE)
     MOVE 0 TO SP-T-ROT(WS-PIECE) SP-T-LIQ(WS-PIECE) SP-T-AUX(WS-PIECE).

*> WS-NAME the block key at (WS-X, WS-Y, WS-Z) of the window
 BLOCK-AT.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE SPACES TO WS-NAME
     MOVE CB-KEY(WS-BLOCK) TO WS-NAME.

*> 14.3: pieces through the window of chunk (4, 4)
 WINDOW-CASES.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-WCZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE "minecraft:diamond_block" TO WS-KEY
     CALL "GEN-BLOCK-STATE" USING WS-KEY WS-DIAMOND
*>   the synthetic hub of chunk (4, 4): the hub's jigsaws that ask nothing leave the terrain (diamond) where their final_state is air, the one with stone becomes stone
     MOVE "jigsaw" TO WS-NAME
     MOVE 1 TO TJ-SURFACE
     MOVE 2 TO SD-ST-COUNT
     CALL "STRUCT-ENUM-ID" USING WS-ONE WS-NAME WS-TYPE
     MOVE WS-TYPE TO SDT-TYPE(1)
     MOVE "test:start" TO SDT-JIG-POOL(1)
     MOVE 3 TO SDT-JIG-SIZE(1)
     MOVE 70 TO SDT-JIG-Y(1)
     MOVE -1 TO SDT-JIG-PROJ(1)
     MOVE 0 TO SDT-JIG-HACK(1)
     MOVE 20 TO SDT-JIG-HOR(1)
     MOVE 20 TO SDT-JIG-VER(1)
     MOVE 0 TO SDT-JIG-PADB(1) SDT-JIG-PADT(1) SDT-JIG-LIQ(1)
     MOVE 0 TO SDT-JIG-NAMED(1) SDT-JIG-PADSET(1) SDT-JIG-YKIND(1) SDT-JIG-AL-N(1)
     MOVE 1 TO SDT-JIG-OK(1)
     MOVE 4 TO WS-CX
     MOVE 4 TO WS-CZ
     CALL "JIG-FIND-POINT" USING WS-ONE WS-SEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID
     MOVE 64 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 65 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-DIAMOND WS-ONE WS-STATUS
     MOVE 66 TO WS-X
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-DIAMOND WS-ONE WS-STATUS
     MOVE 65 TO WS-X
     MOVE 66 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-DIAMOND WS-ONE WS-STATUS
     MOVE 1 TO SP-SEED
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 65 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 65 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given the hub piece when it is placed then the template's stone block is there" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "stone"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 69 TO WS-Y
     MOVE 64 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given the hub piece when it is placed then the jigsaw with final_state stone is stone" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "stone"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO WS-FIRST
     MOVE 64 TO WS-X
     MOVE 65 TO WS-Z
     PERFORM BLOCK-AT
     IF WS-NAME = "diamond_block"
         ADD 1 TO WS-FIRST
     END-IF
     MOVE 66 TO WS-X
     PERFORM BLOCK-AT
     IF WS-NAME = "diamond_block"
         ADD 1 TO WS-FIRST
     END-IF
     MOVE 65 TO WS-X
     MOVE 66 TO WS-Z
     PERFORM BLOCK-AT
     IF WS-NAME = "diamond_block"
         ADD 1 TO WS-FIRST
     END-IF
     MOVE "test struct jigsaw place given the hub piece of a legacy element when it is placed then the jigsaws whose final_state is air leave the terrain" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 65 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 62 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given the leaf piece outside the window when the start is placed then nothing is written for it" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "air"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a list element: the leaf (with the stone block at (x + 1, y + 1, z + 1)) and the empty one
     MOVE "test:listok" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW)) TO WS-EL
     CALL "SPB-RESET"
     MOVE 70 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 70 TO WS-Z
     PERFORM NEW-PIECE
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 71 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 71 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given a list element when it is placed then its template is written in order" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "stone"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a list whose first element fails stops there
     MOVE "test:listfail" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-ROW
     MOVE JN-ELEM(JP-FIRST(WS-ROW)) TO WS-EL
     CALL "SPB-RESET"
     MOVE 74 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 70 TO WS-Z
     PERFORM NEW-PIECE
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 75 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 71 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given a list whose first template is absent when it is placed then the next element is not written" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "air"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the processors of the element are run: a rule that turns stone into cobblestone
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE 0 TO JE-PROJ(WS-EL)
     MOVE "test:swap" TO JE-PROC(WS-EL)
     CALL "SPB-RESET"
     MOVE 64 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 74 TO WS-Z
     PERFORM NEW-PIECE
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE 65 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 75 TO WS-Z
     PERFORM BLOCK-AT
     MOVE "test struct jigsaw place given an element with the list test:swap when it is placed then its stone is cobblestone" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "cobblestone"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a full template cache: the template cannot be loaded and the element fails
     MOVE 1 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE "test:never_loaded" TO JE-LOC(WS-EL)
     CALL "SPB-RESET"
     MOVE 64 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 70 TO WS-Z
     PERFORM NEW-PIECE
     MOVE TP-COUNT TO WS-SAVE
     MOVE TP-MAX-TEMPLATES TO TP-COUNT
     CALL "JIG-PLACE-ONE" USING WS-PIECE WS-EL WS-FIRST
     MOVE WS-SAVE TO TP-COUNT
     MOVE "test struct jigsaw place given a full template cache when an element of another template is placed then it fails" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-FIRST = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a feature element and the empty element write nothing and fail nothing
     MOVE 4 TO WS-ROW
     PERFORM NEW-ELEMENT
     MOVE "minecraft:oak" TO JE-FEATURE(WS-EL)
     CALL "SPB-RESET"
     MOVE 64 TO WS-X
     MOVE 69 TO WS-Y
     MOVE 78 TO WS-Z
     PERFORM NEW-PIECE
     MOVE 1 TO WS-EL
     MOVE 68 TO WS-X
     PERFORM NEW-PIECE
     CALL "MSP-OPEN"
     CALL "STRUCT-PLACE-START"
     MOVE "test struct jigsaw place given a feature element and the empty element when they are placed then nothing is written" TO TL-CASE
     MOVE 65 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 79 TO WS-Z
     PERFORM BLOCK-AT
     MOVE 0 TO WS-FLAG
     IF WS-NAME = "air"
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 0 TO TJ-SURFACE.
 END PROGRAM TEST-STRUCT-JIGSAW-PLACE.

 COPY JIGSEAM.

 COPY CORETEST.
