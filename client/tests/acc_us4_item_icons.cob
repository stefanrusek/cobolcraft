*> Acceptance test of SC-004 for item icons (standin-content §2 icons and block item textures,
*> §1.4.1 drawing rules; 08 §10.3, §10.7): with only the built-in pack, each item's icon (the layer0
*> sprite of the generated model its definition names, as stitched into the block-and-item atlas)
*> equals client/tests/fixtures/textures/item_<name>.rgba, written by the independent Python
*> generator, pixel for pixel.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-ITEM-ICONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SW                  BINARY-LONG.
 01 WS-SH                  BINARY-LONG.
 01 WS-FIXTURE             PIC X(256).
 01 WS-ICON                PIC X(4096).
 01 WS-REFERENCE           PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-EDIT                PIC Z(5)9.
 01 B-ATLAS                PIC X(1073741824) BASED.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ITEMDEFS-LOAD" USING CLIENT-STATE
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-ITEM-COUNT
         MOVE FUNCTION MAX(IT-SPRITE(WS-I), 1) TO WS-S
         MOVE AT-X(WS-S) TO WS-SX
         MOVE AT-Y(WS-S) TO WS-SY
         MOVE AT-SW(WS-S) TO WS-SW
         MOVE AT-SH(WS-S) TO WS-SH
         MOVE LOW-VALUES TO WS-ICON
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= WS-SH OR WS-SW > 16
             COMPUTE WS-AT = ((WS-SY + WS-Y) * AT-W + WS-SX) * 4 + 1
             COMPUTE WS-ROW = WS-Y * WS-SW * 4 + 1
             COMPUTE WS-K = WS-SW * 4
             MOVE B-ATLAS(WS-AT:WS-K) TO WS-ICON(WS-ROW:WS-K)
         END-PERFORM
         MOVE SPACES TO WS-FIXTURE
         STRING "client/tests/fixtures/textures/item_" FUNCTION TRIM(CL-IT-KEY(WS-I)) ".rgba"
             DELIMITED BY SIZE INTO WS-FIXTURE
         CALL "TEST-READ-FILE" USING WS-FIXTURE WS-REFERENCE WS-CAPACITY WS-LENGTH
         MOVE 0 TO WS-DIFF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-LENGTH OR WS-DIFF > 0
             IF WS-ICON(WS-K:1) NOT = WS-REFERENCE(WS-K:1)
                 MOVE WS-K TO WS-DIFF
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE TL-EXPECTED TL-OBSERVED
         STRING "acceptance SC-004 given only the built-in pack when the icon of item cobolcraft:"
             FUNCTION TRIM(CL-IT-KEY(WS-I)) " is drawn then it equals the reference item_"
             FUNCTION TRIM(CL-IT-KEY(WS-I)) ".rgba pixel for pixel" DELIMITED BY SIZE
             INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "16 x 16, 256 pixels equal" TO TL-EXPECTED
         EVALUATE TRUE
             WHEN WS-SW NOT = 16 OR WS-SH NOT = 16 OR WS-LENGTH NOT = 1024
                 COMPUTE WS-EDIT = WS-SW * WS-SH
                 STRING "size " FUNCTION TRIM(WS-EDIT) " pixels" DELIMITED BY SIZE
                     INTO TL-OBSERVED
             WHEN WS-DIFF > 0
                 COMPUTE WS-EDIT = (WS-DIFF - 1) / 4
                 STRING "pixel " FUNCTION TRIM(WS-EDIT) " differs" DELIMITED BY SIZE
                     INTO TL-OBSERVED
             WHEN OTHER
                 MOVE TL-EXPECTED TO TL-OBSERVED
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-US4-ITEM-ICONS.
 COPY CLTEST.
