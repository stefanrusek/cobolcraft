*> Implementation test (002-lane-crashlight, T5701; core/src/light.cob LIGHT-BLOCK-CHANGED): a block change redoes only the window of 14 steps
*> around it, and the light that results is the light a full recomputation of each chunk (LIGHT-BLOCK, from every source of the 3 x 3
*> neighbourhood) gives, for sources and walls placed and removed across chunk borders, on the lowest and the highest layer; chunks that are
*> not loaded are never loaded by it and block the light; loaded chunks that are not lit are left out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-WINDOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY LIGHTWORK.
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
 01 WS-OLD                 BINARY-LONG.
 01 WS-CX0                 BINARY-LONG VALUE 0.
 01 WS-CZ0                 BINARY-LONG VALUE 0.
 01 WS-COUNT-1             BINARY-LONG.
 01 WS-COUNT-2             BINARY-LONG.
 01 WS-COUNT-3             BINARY-LONG.
 01 WS-COUNT-4             BINARY-LONG.
 01 WS-T0                  PIC X(21).
 01 WS-T1                  PIC X(21).
 01 WS-SECONDS             BINARY-LONG.
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

*>   The work of a change is the cells whose light changes: a first light in the dark, a second beside it (most cells already hold as much),
*>   a wall in the dark (no light changes), and the removal of the first (the cells lit through it are cleared and re-raised).
     MOVE 90 TO WS-CX0 WS-CZ0
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX0 WS-CZ0 WS-ROW
     MOVE 0 TO WS-BAD
     MOVE 1448 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 1448 TO WS-Z
     MOVE 13 TO WS-STATE
     MOVE 0 TO LW-CELLS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE LW-CELLS TO WS-COUNT-1
     PERFORM COMPARE-ALL
     ADD 1 TO WS-X
     MOVE 0 TO LW-CELLS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE LW-CELLS TO WS-COUNT-2
     PERFORM COMPARE-ALL
     MOVE 2 TO WS-STATE
     MOVE 1440 TO WS-X
     MOVE 1440 TO WS-Z
     MOVE 0 TO LW-CELLS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE LW-CELLS TO WS-COUNT-3
     PERFORM COMPARE-ALL
     MOVE 1448 TO WS-X
     MOVE 1448 TO WS-Z
     MOVE 0 TO WS-STATE
     MOVE 0 TO LW-CELLS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE LW-CELLS TO WS-COUNT-4
     PERFORM COMPARE-ALL
     MOVE "test light window a first light touches the cells it lights, a second one beside it touches fewer, a wall in the dark none"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT-1 > 1000 AND WS-COUNT-2 < WS-COUNT-1 AND WS-COUNT-3 < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test light window the removal of a light clears and re-raises and the nine chunks equal the full recomputation after each of these changes"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CX0 WS-CZ0

*>   A chunk loaded without its neighbours: the light stops at the border of what is loaded and nothing is loaded for it.
     MOVE 40 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO CK-LIT(WS-ROW)
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 13 TO CE-STATE(60 * 256 + 8 * 16 + 15 + 1)
     MOVE 655 TO WS-X
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

*>   A loaded neighbour that is not lit is left out by the change next to it (it takes the light when it is lit).
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
     MOVE "test light window a loaded neighbour that is not lit stays unlit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CK-LIT(WS-ROW2) TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk lit when it loads: nine loaded chunks with sources across their borders are lit one at a time, in an order that has lit and unlit
*>   neighbours, and every one of them equals the full recomputation (every source of the 3 x 3 neighbourhood).
     PERFORM VARYING WS-DZ FROM 70 BY 1 UNTIL WS-DZ > 72
         PERFORM VARYING WS-DX FROM 70 BY 1 UNTIL WS-DX > 72
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-DX WS-DZ WS-ROW
             SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
             MOVE LOW-VALUES TO CE-STATES
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 24
                 MOVE 0 TO CK-SOURCES(WS-ROW, WS-K)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 14
         EVALUATE WS-STEP
             WHEN 1  MOVE 1135 TO WS-X MOVE 60 TO WS-Y MOVE 1135 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 2  MOVE 1136 TO WS-X MOVE 61 TO WS-Y MOVE 1135 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 3  MOVE 1151 TO WS-X MOVE 0 TO WS-Y MOVE 1140 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 4  MOVE 1152 TO WS-X MOVE 0 TO WS-Y MOVE 1140 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 5  MOVE 1150 TO WS-X MOVE 255 TO WS-Y MOVE 1150 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 6  MOVE 1160 TO WS-X MOVE 70 TO WS-Y MOVE 1160 TO WS-Z MOVE 16 TO WS-STATE
             WHEN 7  MOVE 1167 TO WS-X MOVE 70 TO WS-Y MOVE 1167 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 8  MOVE 1166 TO WS-X MOVE 70 TO WS-Y MOVE 1167 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 9  MOVE 1166 TO WS-X MOVE 70 TO WS-Y MOVE 1167 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 10 MOVE 1140 TO WS-X MOVE 70 TO WS-Y MOVE 1167 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 11 MOVE 1160 TO WS-X MOVE 70 TO WS-Y MOVE 1150 TO WS-Z MOVE 13 TO WS-STATE
             WHEN 12 MOVE 1160 TO WS-X MOVE 71 TO WS-Y MOVE 1151 TO WS-Z MOVE 2 TO WS-STATE
             WHEN 13 MOVE 1130 TO WS-X MOVE 70 TO WS-Y MOVE 1150 TO WS-Z MOVE 13 TO WS-STATE
             WHEN OTHER MOVE 1150 TO WS-X MOVE 69 TO WS-Y MOVE 1150 TO WS-Z MOVE 2 TO WS-STATE
         END-EVALUATE
         PERFORM POKE
     END-PERFORM
     MOVE 70 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "LIGHT-CHUNK" USING WS-ROW
     MOVE 72 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "LIGHT-CHUNK" USING WS-ROW
     PERFORM VARYING WS-DZ FROM 70 BY 1 UNTIL WS-DZ > 72
         PERFORM VARYING WS-DX FROM 70 BY 1 UNTIL WS-DX > 72
             CALL "WORLD-FIND" USING WS-DIM WS-DX WS-DZ WS-ROW
             IF CK-LIT(WS-ROW) = 0
                 CALL "LIGHT-CHUNK" USING WS-ROW
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-DZ FROM 70 BY 1 UNTIL WS-DZ > 72
         PERFORM VARYING WS-DX FROM 70 BY 1 UNTIL WS-DX > 72
             CALL "WORLD-FIND" USING WS-DIM WS-DX WS-DZ WS-ROW2
             SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW2)
             MOVE CE-BLOCK-LIGHTS TO WS-KEPT
             CALL "LIGHT-BLOCK" USING WS-ROW2
             IF CE-BLOCK-LIGHTS NOT = WS-KEPT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test light window chunks lit one by one from their own sources and the borders of the lit ones equal the full recomputation"
         TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A chunk full of light sources (16 x 16 x 40 glowtubes, in a chunk with loaded neighbours) is lit in seconds.
     PERFORM VARYING WS-DZ FROM 79 BY 1 UNTIL WS-DZ > 81
         PERFORM VARYING WS-DX FROM 79 BY 1 UNTIL WS-DX > 81
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-DX WS-DZ WS-ROW
         END-PERFORM
     END-PERFORM
     MOVE 80 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 40 * 256
         MOVE 13 TO CE-STATE(WS-CELL)
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE 4096 TO CK-SOURCES(WS-ROW, WS-K)
     END-PERFORM
     MOVE 2048 TO CK-SOURCES(WS-ROW, 3)
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     CALL "LIGHT-CHUNK" USING WS-ROW
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     COMPUTE WS-SECONDS = FUNCTION MOD((FUNCTION NUMVAL(WS-T1(11:2)) * 60 + FUNCTION NUMVAL(WS-T1(13:2)))
         - (FUNCTION NUMVAL(WS-T0(11:2)) * 60 + FUNCTION NUMVAL(WS-T0(13:2))) + 3600, 3600)
     MOVE "test light window a chunk of 10240 light sources is lit in seconds" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SECONDS < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Sets the state at WS-X, WS-Y, WS-Z of a loaded chunk without lighting anything and keeps the source count of its section.
 POKE.
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW2
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW2)
     COMPUTE WS-CELL = WS-Y * 256 + (WS-Z - WS-CZ * 16) * 16 + WS-X - WS-CX * 16 + 1
     MOVE CE-STATE(WS-CELL) TO WS-OLD
     MOVE WS-STATE TO CE-STATE(WS-CELL)
     COMPUTE WS-K = (WS-CELL - 1) / 4096 + 1
     IF WS-STATE = 13 OR WS-STATE = 16
         ADD 1 TO CK-SOURCES(WS-ROW2, WS-K)
     END-IF.

*> The light of the nine chunks around chunk 0, 0 is kept, recomputed in full chunk by chunk, and compared.
 COMPARE-ALL.
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-CX = WS-CX0 + WS-DX
             COMPUTE WS-CZ = WS-CZ0 + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW2
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
