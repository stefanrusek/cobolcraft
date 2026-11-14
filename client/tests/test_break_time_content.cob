*> Implementation test of the break time from the content set's block rows (CONTROLS-BREAK-TIME; plan "break
*> times for standard states"): with the standard set open, the hand break time of a state is its block's
*> hardness x 1.5 s, x 5 s when the block needs the correct tool for its drops (stone: 1.5 -> 7,500 ms; dirt: 0.5
*> -> 750 ms), and never for an unbreakable block (bedrock: -1). With no set open (or a cobolcraft one) the
*> stand-in table of standin-content 1.1 answers as before (greystone 2,250 ms, baseplate never).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-TIME-CONTENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 0.
 01 WS-MS                  BINARY-LONG.
 01 WS-E1                  PIC -(6)9.
 01 WS-E2                  PIC -(6)9.
 01 WS-E3                  PIC -(6)9.
 PROCEDURE DIVISION.
     INITIALIZE CT-SET
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 2 TO WS-STATE
     CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
     MOVE "break time with no set open: greystone (state 2) by hand takes 2,250 ms (the stand-in table)"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2250 TO TL-EXPECTED-N
     MOVE WS-MS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
     MOVE WS-MS TO WS-E1
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
     MOVE WS-MS TO WS-E2
     MOVE "bedrock" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "CONTROLS-BREAK-TIME" USING CLIENT-STATE WS-STATE WS-ITEM WS-MS
     MOVE WS-MS TO WS-E3
     MOVE "break time from the standard set: stone 7,500 ms (needs the tool), dirt 750 ms, bedrock never "
         & "(-1)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "7500 750 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN CT-STATE-COUNT
     STOP RUN.
 END PROGRAM TEST-BREAK-TIME-CONTENT.
 COPY CLTEST.
