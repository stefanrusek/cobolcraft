*> Implementation test of CONTROLS-BREAK-TIME (client/src/controls.cob; standin-content §1.1 hand
*> break times and classes, §2 tools): the survival break time of a block state with the held item:
*> the hand time, a quarter of it with the tool of the block's class (pry bar: hard, trowel: soft),
*> unchanged for a block in no class, never (-1) for baseplate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTROLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-CASES.
    05 FILLER PIC X(24) VALUE "16 00+01950 goto_pad    ".
    05 FILLER PIC X(24) VALUE "17 10+00150 slag+pry    ".
    05 FILLER PIC X(24) VALUE "17 11+00600 slag+trowel ".
    05 FILLER PIC X(24) VALUE "04 11+00225 turf+trowel ".
    05 FILLER PIC X(24) VALUE "12 10+00450 lucite+pry  ".
    05 FILLER PIC X(24) VALUE "01 10-00001 baseplate   ".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 6 TIMES.
       10 WS-C-STATE       PIC 99.
       10 FILLER           PIC X.
       10 WS-C-ITEM        PIC 99.
       10 WS-C-MS          PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WS-C-NAME        PIC X(12).
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-C-STATE(WS-I) TO WS-STATE
         MOVE WS-C-ITEM(WS-I) TO WS-ITEM
         CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
         MOVE SPACES TO TL-CASE
         STRING "controls break time of " FUNCTION TRIM(WS-C-NAME(WS-I)) " (standin §1.1, §2)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-C-MS(WS-I) TO TL-EXPECTED-N
         MOVE WS-MS TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-CONTROLS.
 COPY CLTEST.
