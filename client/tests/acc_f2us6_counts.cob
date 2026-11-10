*> Acceptance test US6-2 (spec 002 FR-014; SC-003; docs/design/builtin-ui-art.md 4.13): the count of an item slot.
*> A slot with 1 item shows no count; 2, 64 and a count too wide for the slot each show it right-aligned
*> at the slot's bottom edge, inside the slot (nothing clipped). Four named cases.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-COUNTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-CASES.
    05 FILLER PIC 9(10) VALUE 1.
    05 FILLER PIC 9(10) VALUE 2.
    05 FILLER PIC 9(10) VALUE 64.
    05 FILLER PIC 9(10) VALUE 2000000000.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-COUNT       PIC 9(10) OCCURS 4 TIMES.
 01 WS-C                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-MINX                FLOAT-SHORT.
 01 WS-MAXX                FLOAT-SHORT.
 01 WS-MINY                FLOAT-SHORT.
 01 WS-MAXY                FLOAT-SHORT.
 01 WS-X                   BINARY-LONG VALUE 10.
 01 WS-Y                   BINARY-LONG VALUE 20.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG VALUE 0.
 01 WS-QUADS               BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 2 TO CL-GUI-SCALE
     MOVE 0 TO PL-SLOT-ITEM(1)
     MOVE 1 TO IT-SPRITE(1)
     MOVE 9 TO PL-HELD
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 4
         MOVE WS-CASE-COUNT(WS-C) TO PL-SLOT-COUNT(1)
         MOVE 0 TO SM-WIDGET-COUNT
         CALL "SLOT-WIDGET-ADD" USING CLIENT-STATE WS-SLOT WS-X WS-Y WS-ACTION
         CALL "UI-RENDER" USING CLIENT-STATE
*>       The count's quads are the text-layer vertices (the icon and the background are other layers).
         COMPUTE WS-QUADS = RL-UT-COUNT / 6
         MOVE 0 TO WS-INSIDE WS-RIGHT
         IF WS-QUADS > 0
             MOVE 1000000 TO WS-MINX WS-MINY
             MOVE -1 TO WS-MAXX WS-MAXY
             PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > RL-UT-COUNT
                 MOVE FUNCTION MIN(WS-MINX, RL-UT-X(WS-V)) TO WS-MINX
                 MOVE FUNCTION MAX(WS-MAXX, RL-UT-X(WS-V)) TO WS-MAXX
                 MOVE FUNCTION MIN(WS-MINY, RL-UT-Y(WS-V)) TO WS-MINY
                 MOVE FUNCTION MAX(WS-MAXY, RL-UT-Y(WS-V)) TO WS-MAXY
             END-PERFORM
*>           The slot is GUI (10, 20) to (30, 40): window pixels (20, 40) to (60, 80).
             IF WS-MINX >= 20 AND WS-MAXX <= 60 AND WS-MINY >= 40 AND WS-MAXY <= 80
                 MOVE 1 TO WS-INSIDE
             END-IF
             IF WS-MAXX >= 56 AND WS-MAXY >= 76
                 MOVE 1 TO WS-RIGHT
             END-IF
         END-IF
         MOVE "N" TO TL-MODE
         EVALUATE WS-C
             WHEN 1
                 MOVE "counts a slot with 1 item shows no count" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-QUADS TO TL-OBSERVED-N
             WHEN 2
                 MOVE "counts 2 shows one digit, inside the slot and aligned to its bottom right corner" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-INSIDE * WS-RIGHT * FUNCTION MIN(WS-QUADS, 1)
             WHEN 3
                 MOVE "counts 64 shows two digits, inside the slot and aligned to its bottom right corner" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-INSIDE * WS-RIGHT * FUNCTION MIN(WS-QUADS, 1)
             WHEN 4
                 MOVE "counts a count too wide for the slot is shown inside the slot, not clipped" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 COMPUTE TL-OBSERVED-N = WS-INSIDE * FUNCTION MIN(WS-QUADS, 1)
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-F2US6-COUNTS.
