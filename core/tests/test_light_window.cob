*> Implementation test (002-lane-crashlight, T5701; core/src/light.cob LIGHT-BLOCK-CHANGED): a block change redoes only the window of 14 steps
*> around it, and the light that results is the light a full recomputation of each chunk (LIGHT-BLOCK, from every source of the 3 x 3
*> neighbourhood) gives, for sources and walls placed and removed across chunk borders, on the lowest and the highest layer; chunks that are
*> not loaded are never loaded by it and block the light; loaded chunks that were not lit are lit by it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-WINDOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-KEPT                PIC X(53248).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW

     MOVE "test light window every change gives the light of a full recomputation of the nine chunks" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 22
         EVALUATE WS-STEP
             WHEN 1  MOVE 15 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 2  MOVE 17 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 3  MOVE 16 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 4  MOVE 16 TO WS-X MOVE 61 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 5  MOVE 16 TO WS-X MOVE 59 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 6  MOVE 16 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
             WHEN 7  MOVE 8 TO WS-X MOVE 0 TO WS-Y MOVE 8 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 8  MOVE 8 TO WS-X MOVE 1 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 9  MOVE 8 TO WS-X MOVE 255 TO WS-Y MOVE 8 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 10 MOVE 8 TO WS-X MOVE 254 TO WS-Y MOVE 9 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 11 MOVE -3 TO WS-X MOVE 60 TO WS-Y MOVE -1 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 12 MOVE -2 TO WS-X MOVE 60 TO WS-Y MOVE -1 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 13 MOVE 0 TO WS-X MOVE 60 TO WS-Y MOVE 0 TO WS-Z MOVE 16 TO WS-STATE
             WHEN 14 MOVE 15 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 14 TO WS-STATE
             WHEN 15 MOVE 15 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 16 MOVE 16 TO WS-X MOVE 62 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 17 MOVE 14 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 18 MOVE 14 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
             WHEN 19 MOVE 16 TO WS-X MOVE 61 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
             WHEN 20 MOVE 16 TO WS-X MOVE 59 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
             WHEN 21 MOVE 8 TO WS-X MOVE 1 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
             WHEN OTHER MOVE 15 TO WS-X MOVE 60 TO WS-Y MOVE 8 TO WS-Z MOVE 0 TO WS-STATE
         END-EVALUATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         PERFORM COMPARE-ALL
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk loaded without its neighbours: the light stops at the border of what is loaded and nothing is loaded for it.
     MOVE 40 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO CK-LIT(WS-ROW)
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 13 TO CE-STATE(60 * 256 + 8 * 16 + 15 + 1)
     MOVE 650 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 648 TO WS-Z
     CALL "LIGHT-BLOCK-CHANGED" USING WS-ROW WS-X WS-Y WS-Z
     MOVE "test light window a change in a chunk with no loaded neighbour lights it and loads nothing" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 15 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-NUM
     MOVE 14 TO WS-X
     PERFORM BLOCK-NUM
     MOVE 41 TO WS-CX
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW2
     MOVE WS-ROW2 TO WS-NUM
     PERFORM ADD-NUM
     MOVE "15 14 0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A loaded neighbour that was not lit is lit by the change next to it.
     MOVE 60 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO CK-LIT(WS-ROW)
     ADD 1 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW2
     MOVE 0 TO CK-LIT(WS-ROW2)
     MOVE 975 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 968 TO WS-Z
     CALL "LIGHT-BLOCK-CHANGED" USING WS-ROW WS-X WS-Y WS-Z
     MOVE "test light window a loaded neighbour that was not lit is lit" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CK-LIT(WS-ROW2) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The light of the nine chunks around chunk 0, 0 is kept, recomputed in full chunk by chunk, and compared.
 COMPARE-ALL.
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             CALL "WORLD-FIND" USING WS-DIM WS-DX WS-DZ WS-ROW2
             SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW2)
             MOVE CE-BLOCK-LIGHTS TO WS-KEPT
             CALL "LIGHT-BLOCK" USING WS-ROW2
             IF CE-BLOCK-LIGHTS NOT = WS-KEPT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM.

 BLOCK-NUM.
     COMPUTE WS-CELL = WS-Y * 256 + WS-Z * 16 + WS-X + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE WS-NUM = FUNCTION MOD(CE-BLOCK-LIGHT(WS-BYTE), 16)
     ELSE
         COMPUTE WS-NUM = CE-BLOCK-LIGHT(WS-BYTE) / 16
     END-IF
     PERFORM ADD-NUM.

 ADD-NUM.
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.
 END PROGRAM TEST-LIGHT-WINDOW.

 COPY CORETEST.
