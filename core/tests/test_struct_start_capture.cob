*> Implementation test of the capture of a built start into the store (core/src/struct-start.cob STRUCT-START-CAPTURE, STRUCT-STORE-SYNC; docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 6.7
*> and 7.1): the pieces of the builder become the pieces of a start held by the chunk (a jigsaw piece, builder type 60, with the registry id of the jigsaw piece, its projection, ground level delta and the junctions it owns;
*> another piece with its own type), a start is stored once (the second capture returns the stored row and adds no piece), a builder with no piece stores nothing, and a change of the world seed or of the structure data
*> epoch empties the store before the next capture (the starts are a function of both).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-CAPTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY CARVER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIENT              BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-OUT2                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NAME                PIC X(40) VALUE "jigsaw".
 01 WS-JIGSAW              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-JIGSAW
     MOVE 5 TO SDT-ADAPT(2)
     MOVE 7 TO CV-SEED
     MOVE 1 TO SD-EPOCH
     CALL "STRUCT-STORE-SYNC"
*>   an empty builder stores nothing
     CALL "SPB-RESET"
     MOVE 2 TO WS-S
     MOVE 3 TO WS-CX
     MOVE -4 TO WS-CZ
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-OUT
     MOVE "acceptance US12 36-1§7.1 capture: a builder with no piece stores no start" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OUT * 10 + SST-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a jigsaw piece (type 60, terrain_matching, ground delta 3, two junctions) and a plain piece
     CALL "SPB-RESET"
     MOVE 60 TO WS-TYPE
     MOVE -1 TO WS-ORIENT
     MOVE 2 TO WS-DEPTH
     MOVE 40 TO A-X0
     MOVE 60 TO A-Y0
     MOVE -64 TO A-Z0
     MOVE 47 TO A-X1
     MOVE 70 TO A-Y1
     MOVE -57 TO A-Z1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-MST WS-BOX WS-ROW
     MOVE 1 TO SP-T-AUX(1)
     MOVE 3 TO SP-F2(1)
     MOVE 5 TO WS-TYPE
     MOVE 2 TO WS-ORIENT
     MOVE 1 TO WS-DEPTH
     MOVE 48 TO A-X0
     MOVE 52 TO A-X1
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-DEPTH WS-MST WS-BOX WS-ROW
     MOVE 4 TO JJ-COUNT
     MOVE 1 TO JJ-OWNER(1)
     MOVE 44 TO JJ-X(1)
     MOVE 61 TO JJ-Y(1)
     MOVE -60 TO JJ-Z(1)
     MOVE 2 TO JJ-OWNER(2)
     MOVE 99 TO JJ-X(2)
     MOVE 1 TO JJ-OWNER(3)
     MOVE 46 TO JJ-X(3)
     MOVE 62 TO JJ-Y(3)
     MOVE -61 TO JJ-Z(3)
     MOVE 9 TO JJ-OWNER(4)
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-OUT
     MOVE "acceptance US12 36-1§5.6 capture: the start of structure 2 held by chunk (3, -4) has the two pieces of the builder" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 100 + SST-N(WS-OUT) * 10 + SST-STRUCT(WS-OUT)
     MOVE 122 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§6.7 capture: the jigsaw piece has the registry id of jigsaw, jigsaw kind 2 (terrain_matching), ground delta 3, depth 2, orientation none" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SPC-TYPE(SST-FIRST(WS-OUT)) = WS-JIGSAW AND SPC-JIG(SST-FIRST(WS-OUT)) = 2 AND SPC-GROUND(SST-FIRST(WS-OUT)) = 3
             AND SPC-DEPTH(SST-FIRST(WS-OUT)) = 2 AND SPC-ORIENT(SST-FIRST(WS-OUT)) = -1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-N = SST-FIRST(WS-OUT)
     MOVE "acceptance US12 36-1§9.2 capture: the jigsaw piece keeps the junctions it owns, in order: (44, 61, -60) and (46, 62, -61), not the other owners'" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SPC-J-N(WS-N) = 2 AND SJ-X(SPC-J-FIRST(WS-N)) = 44 AND SJ-Y(SPC-J-FIRST(WS-N)) = 61 AND SJ-Z(SPC-J-FIRST(WS-N)) = -60
             AND SJ-X(SPC-J-FIRST(WS-N) + 1) = 46 AND SJ-Y(SPC-J-FIRST(WS-N) + 1) = 62 AND SJ-Z(SPC-J-FIRST(WS-N) + 1) = -61
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     ADD 1 TO WS-N
     MOVE "acceptance US12 36-1§6.7 capture: the plain piece keeps its builder type (5), orientation 2, depth 1, no jigsaw kind and no junction, box x 48 to 52" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SPC-TYPE(WS-N) = 5 AND SPC-ORIENT(WS-N) = 2 AND SPC-DEPTH(WS-N) = 1 AND SPC-JIG(WS-N) = 0 AND SPC-J-N(WS-N) = 0
             AND SPC-X0(WS-N) = 48 AND SPC-X1(WS-N) = 52
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   once: the second capture of the same start returns its row and adds nothing
     MOVE SST-PIECE-COUNT TO WS-N
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-OUT2
     MOVE "acceptance US12 36-1§7.1 capture: a start in the store is left as it is (the same row, no piece added)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OUT2 - WS-OUT) * 1000 + SST-PIECE-COUNT - WS-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the world seed changes: the store is emptied before the next capture
     MOVE 8 TO CV-SEED
     MOVE 2 TO WS-CX
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-OUT2
     MOVE "acceptance US12 36-1§7.1 a change of the world seed empties the store: only the new start is left" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10 + SST-CX(1)
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the data epoch changes: the same
     ADD 1 TO SD-EPOCH
     MOVE 5 TO WS-CX
     CALL "STRUCT-START-CAPTURE" USING WS-S WS-CX WS-CZ WS-OUT2
     MOVE "acceptance US12 36-1§7.1 a change of the structure data epoch empties the store: only the new start is left" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10 + SST-CX(1)
     MOVE 15 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-START-CAPTURE.
