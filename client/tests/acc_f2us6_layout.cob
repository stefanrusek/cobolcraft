*> Acceptance test US6-1 (spec 002 FR-013, FR-014, FR-015; SC-003; docs/design/builtin-ui-art.md 4.13.6): the menus
*> at every GUI scale from 1 to 8, at the smallest supported window (320 x 240: the GUI is never smaller than
*> that, so scale 1) and below it (the layout stays that of 320 x 240) have no clipped element (every widget,
*> a label as wide as its text, lies inside the GUI area) and no two widgets overlap (icons and overlays sit on
*> their entry by design). The GUI scale is the largest whole number the window allows, 1 to 8.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-LAYOUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-layout".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-SIZES.
    05 FILLER PIC X(8) VALUE "03200240".
    05 FILLER PIC X(8) VALUE "06400480".
    05 FILLER PIC X(8) VALUE "09600720".
    05 FILLER PIC X(8) VALUE "12800960".
    05 FILLER PIC X(8) VALUE "16001200".
    05 FILLER PIC X(8) VALUE "19201440".
    05 FILLER PIC X(8) VALUE "22401680".
    05 FILLER PIC X(8) VALUE "25601920".
    05 FILLER PIC X(8) VALUE "08540480".
    05 FILLER PIC X(8) VALUE "03000200".
 01 WS-SIZE-TABLE REDEFINES WS-SIZES.
    05 WS-SIZE OCCURS 10 TIMES.
       10 WS-SIZE-W        PIC 9(4).
       10 WS-SIZE-H        PIC 9(4).
 01 WS-SCREENS.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC 99 VALUE 16.
    05 FILLER PIC 99 VALUE 17.
 01 WS-SCREEN-TABLE REDEFINES WS-SCREENS.
    05 WS-SCREEN-ID        PIC 99 OCCURS 12 TIMES.
 01 WS-S                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FIRST               PIC X(80).
 01 WS-SCALE-WRONG         BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BOXES.
    05 WS-BOX OCCURS 64 TIMES.
       10 WS-BX0           BINARY-LONG.
       10 WS-BY0           BINARY-LONG.
       10 WS-BX1           BINARY-LONG.
       10 WS-BY1           BINARY-LONG.
       10 WS-BKIND         BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-E1                  PIC Z(3)9.
 01 WS-E2                  PIC Z(3)9.
 01 WS-E3                  PIC Z(3)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE 0 TO WS-BAD WS-SCALE-WRONG
     MOVE 1 TO LP-CONFIRM RP-COUNT
     MOVE "A server pack is offered." TO RP-PROMPT(1)
     MOVE 24 TO RP-PROMPT-LENGTH(1)
     MOVE SPACES TO WS-FIRST
     PERFORM VARYING WS-Z FROM 1 BY 1 UNTIL WS-Z > 10
         MOVE WS-SIZE-W(WS-Z) TO IN-WIN-W
         MOVE WS-SIZE-H(WS-Z) TO IN-WIN-H
         COMPUTE WS-WANT = FUNCTION MAX(1, FUNCTION MIN(8, FUNCTION MIN(IN-WIN-W / 320, IN-WIN-H / 240)))
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 12
             MOVE WS-SCREEN-ID(WS-S) TO WS-SCREEN
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
             MOVE 1 TO LP-COMPAT(1) SM-SELECTED WL-COUNT
             MOVE "A world" TO WL-NAME(1) WL-FOLDER(1)
             MOVE 7 TO WL-NAME-LENGTH(1) WL-FOLDER-LENGTH(1)
             CALL "SCREEN-BUILD" USING CLIENT-STATE
             IF CL-GUI-SCALE NOT = WS-WANT
                 ADD 1 TO WS-SCALE-WRONG
             END-IF
             COMPUTE WS-GW = FUNCTION MAX(IN-WIN-W / CL-GUI-SCALE, 320)
             COMPUTE WS-GH = FUNCTION MAX(IN-WIN-H / CL-GUI-SCALE, 240)
             PERFORM BOXES
             PERFORM CHECK
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US6-1 the GUI scale is the largest whole number the window allows, 1 to 8" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SCALE-WRONG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-1 across 12 menus and 10 window sizes no element is clipped and none overlaps "
         & "another" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-BAD > 0
         DISPLAY "FIRST " WS-FIRST
     END-IF
     STOP RUN.

*> The boxes of the screen's widgets in GUI pixels: a label is as wide as its text and a line high.
 BOXES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         MOVE SM-W-X(WS-I) TO WS-BX0(WS-I)
         MOVE SM-W-Y(WS-I) TO WS-BY0(WS-I)
         MOVE SM-W-KIND(WS-I) TO WS-BKIND(WS-I)
         COMPUTE WS-BX1(WS-I) = SM-W-X(WS-I) + SM-W-W(WS-I)
         COMPUTE WS-BY1(WS-I) = SM-W-Y(WS-I) + SM-W-H(WS-I)
         IF SM-W-KIND(WS-I) = WK-LABEL
             MOVE SM-W-TEXT(WS-I) TO WS-TEXT
             MOVE SM-W-LENGTH(WS-I) TO WS-LENGTH
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-WIDTH
             COMPUTE WS-BX1(WS-I) = SM-W-X(WS-I) + WS-WIDTH
             COMPUTE WS-BY1(WS-I) = SM-W-Y(WS-I) + FN-HEIGHT
         END-IF
     END-PERFORM.

 CHECK.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF WS-BX0(WS-I) < 0 OR WS-BY0(WS-I) < 0 OR WS-BX1(WS-I) > WS-GW OR WS-BY1(WS-I) > WS-GH
             ADD 1 TO WS-BAD
             PERFORM NOTE
         END-IF
         IF WS-BKIND(WS-I) NOT = WK-OVERLAY AND WS-BKIND(WS-I) NOT = WK-ICON
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
                 IF WS-BKIND(WS-J) NOT = WK-OVERLAY AND WS-BKIND(WS-J) NOT = WK-ICON
                         AND WS-BX0(WS-I) < WS-BX1(WS-J) AND WS-BX0(WS-J) < WS-BX1(WS-I)
                         AND WS-BY0(WS-I) < WS-BY1(WS-J) AND WS-BY0(WS-J) < WS-BY1(WS-I)
                     ADD 1 TO WS-BAD
                     PERFORM NOTE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM.

 NOTE.
     IF WS-FIRST = SPACES
         MOVE WS-SIZE-W(WS-Z) TO WS-E1
         MOVE WS-SCREEN TO WS-E2
         MOVE WS-I TO WS-E3
         STRING "window " FUNCTION TRIM(WS-E1) " screen " FUNCTION TRIM(WS-E2) " widget "
             FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-FIRST
     END-IF.
 END PROGRAM ACC-F2US6-LAYOUT.
 COPY CLTEST.
