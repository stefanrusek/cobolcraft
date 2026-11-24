*> Species keys without behaviour (lane 002-lane-p49m; docs/protocol/45-entity-nbt-4 to 45-6; table SPXTAB.cpy, state EK-SPX and EK-BIG of ENKEEP.cpy):
*>   ENTITY-SPX-READ USING PB-BUFFER, start, end, species key (PIC X(24)), KD-DATA   reads the keys the table has for the species out of the compound payload at
*>       offset start (read again from its first key, so the order of the keys does not matter); PB-POS is left where it was
*>   ENTITY-SPX-WRITE USING row, PB-BUFFER   writes them (the key of a row of mode A at its default when the compound had none)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SPECIES-KEY.
*> USING row, key out (PIC X(24)): the entity type key of the row without its namespace (the species of SPXTAB.cpy rows); spaces for a row that is free.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-BARE                PIC X(48).
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-ROW L-KEY.
     MOVE SPACES TO L-KEY
     COMPUTE WS-INDEX = EN-TYPE(L-ROW) + 1
     IF EN-USED(L-ROW) = 1 AND WS-INDEX >= 1 AND WS-INDEX <= ET-COUNT
         CALL "KEY-BARE" USING ET-KEY(WS-INDEX) WS-BARE
         MOVE WS-BARE TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM ENTITY-SPECIES-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SPX-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SPXTAB.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HOME                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BIG                 BINARY-LONG.
 01 WS-SMALL-CAPACITY      BINARY-LONG VALUE 256.
 01 WS-BIG-CAPACITY        BINARY-LONG VALUE 1024.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-SPECIES              PIC X(24).
 COPY ENKSTAGE.
 PROCEDURE DIVISION USING PB-BUFFER L-START L-END L-SPECIES KD-DATA.
     MOVE PB-POS TO WS-HOME
     MOVE L-START TO PB-POS
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-HIT
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SPX-ROWS
             IF SPX-SPECIES(WS-R) = L-SPECIES AND SPX-KEY(WS-R) = WN AND SPX-TAG(WS-R) = WS-TYPE
                 MOVE WS-R TO WS-HIT
             END-IF
         END-PERFORM
         IF WS-HIT = 0
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         ELSE
             MOVE SPX-SLOT(WS-HIT) TO WS-SLOT
             EVALUATE WS-TYPE
                 WHEN 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                     MOVE WS-INT TO KD-SPX-NUM(WS-SLOT)
                     MOVE 1 TO KD-SPX-SET(WS-SLOT)
                 WHEN 2
                     CALL "PB-GET-SHORT" USING PB-BUFFER WS-INT
                     MOVE WS-INT TO KD-SPX-NUM(WS-SLOT)
                     MOVE 1 TO KD-SPX-SET(WS-SLOT)
                 WHEN 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                     MOVE WS-INT TO KD-SPX-NUM(WS-SLOT)
                     MOVE 1 TO KD-SPX-SET(WS-SLOT)
                 WHEN 5
                     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                     MOVE WS-FLOAT TO KD-SPX-FLT(WS-SLOT)
                     MOVE 1 TO KD-SPX-SET(WS-SLOT)
                 WHEN 4
                     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
                     MOVE WS-LONG TO KD-SPX-NUM(WS-SLOT)
                     MOVE 1 TO KD-SPX-SET(WS-SLOT)
                 WHEN 8
                     MOVE SPACES TO KD-SPX-TXT(WS-SLOT)
                     CALL "NBT-READ-STRING" USING PB-BUFFER KD-SPX-TXT(WS-SLOT) WS-SMALL-CAPACITY WS-LENGTH
                     MOVE WS-LENGTH TO KD-SPX-LEN(WS-SLOT)
                     IF WS-LENGTH > 0
                         MOVE 1 TO KD-SPX-SET(WS-SLOT)
                     END-IF
                 WHEN OTHER
                     IF WS-SLOT > 20
                         COMPUTE WS-BIG = WS-SLOT - 20
                         CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER WS-TYPE WS-BIG-CAPACITY KD-BIG-LEN(WS-BIG)
                             KD-BIG-RAW(WS-BIG)
                     ELSE
                         CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER WS-TYPE WS-SMALL-CAPACITY KD-SPX-LEN(WS-SLOT)
                             KD-SPX-TXT(WS-SLOT)
                         IF KD-SPX-LEN(WS-SLOT) > 1
                             MOVE 1 TO KD-SPX-SET(WS-SLOT)
                         END-IF
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     MOVE WS-HOME TO PB-POS
     GOBACK.
 END PROGRAM ENTITY-SPX-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SPX-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SPXTAB.
 COPY ENKEEP.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-R                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BIG                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "ENTITY-SPECIES-KEY" USING L-ROW WS-KEY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SPX-ROWS
         IF SPX-SPECIES(WS-R) = WS-KEY
             MOVE SPX-SLOT(WS-R) TO WS-SLOT
             MOVE SPX-TAG(WS-R) TO WS-TAG
             MOVE SPX-KEY(WS-R) TO WN
             COMPUTE WL = FUNCTION LENGTH(FUNCTION TRIM(WN))
             MOVE 0 TO WS-SET
             IF WS-SLOT > 20
                 COMPUTE WS-BIG = WS-SLOT - 20
                 IF EK-BIG-LEN(L-ROW, WS-BIG) > 0
                     MOVE 1 TO WS-SET
                 END-IF
             ELSE
                 MOVE EK-SPX-SET(L-ROW, WS-SLOT) TO WS-SET
             END-IF
             EVALUATE TRUE
                 WHEN SPX-MODE(WS-R) = "Z"
                     CONTINUE
                 WHEN SPX-MODE(WS-R) = "Y"
                     IF WS-SET = 1
                         CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-TAG WN WL
                         CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-BIG-RAW(L-ROW, WS-BIG) EK-BIG-LEN(L-ROW, WS-BIG)
                     ELSE
                         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
                     END-IF
                 WHEN SPX-MODE(WS-R) = "C" AND WS-SET = 0
                     CONTINUE
                 WHEN SPX-TAG(WS-R) = 5
                     MOVE SPX-DEF(WS-R) TO WS-FLOAT
                     IF WS-SET = 1
                         MOVE EK-SPX-FLT(L-ROW, WS-SLOT) TO WS-FLOAT
                     END-IF
                     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
                 WHEN SPX-TAG(WS-R) = 1 OR SPX-TAG(WS-R) = 2 OR SPX-TAG(WS-R) = 3
                     MOVE SPX-DEF(WS-R) TO WS-INT
                     IF WS-SET = 1
                         MOVE EK-SPX-NUM(L-ROW, WS-SLOT) TO WS-INT
                     END-IF
                     EVALUATE SPX-TAG(WS-R)
                         WHEN 1
                             CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
                         WHEN 2
                             CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-INT
                         WHEN OTHER
                             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
                     END-EVALUATE
                 WHEN SPX-TAG(WS-R) = 4
                     MOVE SPX-DEF(WS-R) TO WS-LONG
                     IF WS-SET = 1
                         MOVE EK-SPX-NUM(L-ROW, WS-SLOT) TO WS-LONG
                     END-IF
                     CALL "NBT-WRITE-LONG" USING PB-BUFFER WN WL WS-LONG
                 WHEN SPX-TAG(WS-R) = 8
                     MOVE SPACES TO WS-TEXT
                     MOVE SPX-TEXT(WS-R) TO WS-TEXT
                     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(SPX-TEXT(WS-R)))
                     IF WS-SET = 1
                         MOVE EK-SPX-TXT(L-ROW, WS-SLOT) TO WS-TEXT
                         MOVE EK-SPX-LEN(L-ROW, WS-SLOT) TO WS-LENGTH
                     END-IF
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TEXT WS-LENGTH
                 WHEN WS-SLOT > 4
                     CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-TAG WN WL
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-BIG-RAW(L-ROW, WS-BIG) EK-BIG-LEN(L-ROW, WS-BIG)
                 WHEN OTHER
                     CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-TAG WN WL
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-SPX-TXT(L-ROW, WS-SLOT) EK-SPX-LEN(L-ROW, WS-SLOT)
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SPX-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SPX-WRITE-Z.
*> USING row, PB-BUFFER, key (PIC X(24)): the key of the species of the row that the table marks Z, as a list of compounds: the payload read or an empty list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SPXTAB.
 COPY ENKEEP.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-R                   BINARY-LONG.
 01 WS-BIG                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 01 L-KEY                  PIC X(24).
 PROCEDURE DIVISION USING L-ROW PB-BUFFER L-KEY.
     CALL "ENTITY-SPECIES-KEY" USING L-ROW WS-SPECIES
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > SPX-ROWS
         IF SPX-SPECIES(WS-R) = WS-SPECIES AND SPX-KEY(WS-R) = L-KEY AND SPX-MODE(WS-R) = "Z"
             MOVE SPX-KEY(WS-R) TO WN
             COMPUTE WL = FUNCTION LENGTH(FUNCTION TRIM(WN))
             MOVE SPX-TAG(WS-R) TO WS-TAG
             COMPUTE WS-BIG = SPX-SLOT(WS-R) - 20
             IF EK-BIG-LEN(L-ROW, WS-BIG) > 0
                 CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-TAG WN WL
                 CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-BIG-RAW(L-ROW, WS-BIG) EK-BIG-LEN(L-ROW, WS-BIG)
             ELSE
                 CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ZERO
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SPX-WRITE-Z.
