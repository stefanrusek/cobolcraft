*> Typed accessors of the data components a stack carries in its patch (lane itemcomp, T9600 and following; docs/protocol/17 section 1.2, 46 section 8.1). The
*> patch pool (stack-patch.cob) keeps each component as the wire bytes of its value; these programs read and write the values of the components
*> the core acts on. A handle is the patch handle of core/copy/CSTACK.cpy (0 = no patch); a writer takes it in and out (interned, equal patches share one).
*>
*>   SC-ENCH-LEVEL USING handle, component type (13 enchantments or 45 stored_enchantments), id, level out   the level of one enchantment (0 none)
*>   SC-ENCH-ADD USING handle (in, out), component type, id, level                                           set one enchantment at a level (pairs by ascending id, at most 20)
*>   SC-ENCH-COUNT USING handle, component type, count out                                                    the number of enchantments the component lists
*>   SC-ENCH-NTH USING handle, component type, n (1 based), id out, level out                                  the n-th pair by ascending id (id -1 past the end)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-ENCH-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-ID L-LEVEL.
     MOVE 0 TO L-LEVEL
     CALL "SP-GET-COMPONENT" USING L-HANDLE L-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-POS > 63
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-ID
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-LEVEL
             IF WS-ID = L-ID
                 MOVE WS-LEVEL TO L-LEVEL
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SC-ENCH-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-ENCH-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "SP-GET-COMPONENT" USING L-HANDLE L-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-COUNT
         IF L-COUNT > 20
             MOVE 20 TO L-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SC-ENCH-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-ENCH-NTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-N L-ID L-LEVEL.
     MOVE -1 TO L-ID
     MOVE 0 TO L-LEVEL
     CALL "SP-GET-COMPONENT" USING L-HANDLE L-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-I > L-N OR WS-POS > 63
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-ID
             CALL "SP-VARINT-GET" USING WS-VALUE WS-POS L-LEVEL
         END-PERFORM
         IF L-N < 1 OR L-N > WS-COUNT
             MOVE -1 TO L-ID
             MOVE 0 TO L-LEVEL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SC-ENCH-NTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-ENCH-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 PIC X(64).
 01 WS-NEW                 PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PAIRS.
    05 WS-PAIR OCCURS 40 TIMES.
       10 WS-ID            BINARY-LONG.
       10 WS-LEVEL         BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-TYPE L-ID L-LEVEL.
     MOVE 0 TO WS-N
     CALL "SP-GET-COMPONENT" USING L-HANDLE L-TYPE WS-OLD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-POS > 63 OR WS-N >= 20
             ADD 1 TO WS-N
             CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-ID(WS-N)
             CALL "SP-VARINT-GET" USING WS-OLD WS-POS WS-LEVEL(WS-N)
         END-PERFORM
     END-IF
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-ID(WS-I) = L-ID
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT = 0
         ADD 1 TO WS-N
         MOVE L-ID TO WS-ID(WS-N)
         MOVE WS-N TO WS-AT
     END-IF
     MOVE L-LEVEL TO WS-LEVEL(WS-AT)
*>   Ascending id order (a selection sort of at most 21 pairs).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-N
         PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > WS-N
             IF WS-ID(WS-J) < WS-ID(WS-I)
                 MOVE WS-PAIR(WS-I) TO WS-PAIR(40)
                 MOVE WS-PAIR(WS-J) TO WS-PAIR(WS-I)
                 MOVE WS-PAIR(40) TO WS-PAIR(WS-J)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO WS-NEW
     MOVE 1 TO WS-OUT
     CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-ID(WS-I)
         CALL "SP-VARINT-PUT" USING WS-NEW WS-OUT WS-LEVEL(WS-I)
     END-PERFORM
     SUBTRACT 1 FROM WS-OUT
     CALL "SP-SET-COMPONENT" USING L-HANDLE L-TYPE WS-NEW WS-OUT
     GOBACK.
 END PROGRAM SC-ENCH-ADD.
