*> Points of interest of a world in the 26.3 layout (docs/protocol/07 section 10.6): the core does not track them, so when it saves a
*> chunk the chunk's poi/ payload is rewritten with every section marked not valid (`Valid` 0) and everything else as it was; the
*> game then rescans those sections from the blocks when it loads them.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. POI-INVALIDATE.
*> USING dimension row, chunk x, chunk z (BINARY-LONG): reads the chunk's payload from the dimension's poi/ region files; when there
*> is one, writes it back with `Valid` 0 in every child of `Sections` and every other child copied unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-POI                 PIC X(8) VALUE "poi".
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY-NAME       BINARY-LONG VALUE 32.
 01 WS-SECTION-NAME        PIC X(32).
 01 WS-SECTION-LENGTH      BINARY-LONG.
 01 WS-INVALID             BINARY-LONG VALUE 0.
 01 WS-OWNED               PIC X(512) VALUE "|Valid|".
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG VALUE 1.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X BASED.
 01 WS-PATH                PIC X(1100).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-POI WS-DIR WS-LENGTH
     CALL "REGION-READ" USING WS-DIR WS-LENGTH L-CX L-CZ WK-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         GOBACK
     END-IF
     CALL "NBT-READ-ROOT" USING WK-BUFFER WS-FRAMING WS-TYPE
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM UNTIL WK-ERROR = 1
         MOVE WK-POS TO WS-START
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING WK-BUFFER WS-TYPE WN WS-CAPACITY-NAME WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "Sections" AND WS-TYPE = 10
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
             PERFORM UNTIL WK-ERROR = 1
                 MOVE SPACES TO WS-SECTION-NAME
                 CALL "NBT-READ-COMPOUND-NEXT" USING WK-BUFFER WS-INNER-TYPE WS-SECTION-NAME
                     WS-CAPACITY-NAME WS-SECTION-LENGTH
                 IF WS-INNER-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF WS-INNER-TYPE = 10
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-SECTION-NAME WS-SECTION-LENGTH
                     MOVE "Valid" TO WN
                     MOVE 5 TO WL
                     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INVALID
                     CALL "VFMT-COPY-OTHERS" USING WK-BUFFER PB-BUFFER WS-OWNED WS-MODE WS-FOUND
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 ELSE
                     CALL "NBT-READ-SKIP" USING WK-BUFFER WS-INNER-TYPE
                 END-IF
             END-PERFORM
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         ELSE
             CALL "NBT-READ-SKIP" USING WK-BUFFER WS-TYPE
             MOVE WK-POS TO WS-END
             COMPUTE WS-SIZE = WS-END - WS-START
             SET WS-POINTER TO WK-ADDR
             SET WS-POINTER UP BY WS-START
             SET ADDRESS OF B-SLICE TO WS-POINTER
             CALL "PB-APPEND-BYTES" USING PB-BUFFER B-SLICE WS-SIZE
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "REGION-WRITE" USING WS-DIR WS-LENGTH L-CX L-CZ PB-BUFFER WS-OUTCOME
     MOVE WS-DIR TO WS-PATH
     CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH
     GOBACK.
 END PROGRAM POI-INVALIDATE.
