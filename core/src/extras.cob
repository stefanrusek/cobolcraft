*> Unmodelled keys of entities and block entities in a world of the 26.3 layout (docs/protocol/07 section 10.7, EXTRAS.cpy):
*> EXTRA-CAPTURE keeps the compound a load read, EXTRA-APPEND writes the keys the new compound lacks after the ones the core wrote.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXTRA-CAPTURE.
*> USING kind (BINARY-LONG: 0 entity, 1 block entity), row (BINARY-LONG), PB-BUFFER (the file's buffer), start, end
*> (BINARY-LONG offsets: the compound payload is the bytes start + 1 to end, End tag included): keeps them for the row when the
*> world is of the 26.3 layout and they fit EX-CAP; otherwise the row keeps nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY EXTRAS.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X(2048) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROW PB-BUFFER L-START L-END.
     COMPUTE WS-SIZE = L-END - L-START
     IF CW-LAYOUT NOT = 1 OR WS-SIZE > EX-CAP OR WS-SIZE < 1
         MOVE 0 TO WS-SIZE
     END-IF
     IF WS-SIZE > 0
         SET WS-POINTER TO PB-ADDR
         SET WS-POINTER UP BY L-START
         SET ADDRESS OF B-SLICE TO WS-POINTER
     END-IF
     IF L-KIND = 0
         MOVE WS-SIZE TO EX-E-LEN(L-ROW)
         IF WS-SIZE > 0
             MOVE B-SLICE(1:WS-SIZE) TO EX-E-DATA(L-ROW)(1:WS-SIZE)
         END-IF
     ELSE
         MOVE WS-SIZE TO EX-B-LEN(L-ROW)
         IF WS-SIZE > 0
             MOVE B-SLICE(1:WS-SIZE) TO EX-B-DATA(L-ROW)(1:WS-SIZE)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EXTRA-CAPTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EXTRA-APPEND.
*> USING kind, row, PB-BUFFER (the buffer a compound is being written into, its End tag not yet written), start (BINARY-LONG:
*> the buffer length when the compound's payload began): appends every child of the kept compound of the row whose name is
*> not among the names written since start (VFMT-COPY-OTHERS). Nothing happens when the row keeps nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXTRAS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-HOME                BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OWNED               PIC X(512).
 01 WS-OWNED-POINTER       BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG VALUE 1.
 01 WS-DATA                PIC X(2048).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-START                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ROW PB-BUFFER L-START.
     IF L-KIND = 0
         MOVE EX-E-LEN(L-ROW) TO WS-LENGTH
         MOVE EX-E-DATA(L-ROW) TO WS-DATA
     ELSE
         MOVE EX-B-LEN(L-ROW) TO WS-LENGTH
         MOVE EX-B-DATA(L-ROW) TO WS-DATA
     END-IF
     IF WS-LENGTH < 1
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
*>   The names the new compound has: read its children from START to the end of the buffer.
     MOVE PB-POS TO WS-HOME
     MOVE L-START TO PB-POS
     MOVE "|" TO WS-OWNED
     MOVE 2 TO WS-OWNED-POINTER
     PERFORM UNTIL PB-ERROR = 1 OR PB-POS >= PB-LENGTH
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         IF WS-OWNED-POINTER + WL < 500
             STRING WN(1:WL) "|" DELIMITED BY SIZE INTO WS-OWNED WITH POINTER WS-OWNED-POINTER
         END-IF
     END-PERFORM
     MOVE WS-HOME TO PB-POS
     MOVE 0 TO PB-ERROR
*>   The kept children the new compound lacks.
     CALL "PB-RESET" USING WK-BUFFER
     CALL "PB-APPEND-BYTES" USING WK-BUFFER WS-DATA WS-LENGTH
     CALL "VFMT-COPY-OTHERS" USING WK-BUFFER PB-BUFFER WS-OWNED WS-MODE WS-FOUND
     GOBACK.
 END PROGRAM EXTRA-APPEND.
