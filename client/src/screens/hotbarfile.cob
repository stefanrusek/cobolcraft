*> The saved hotbars file hotbar.nbt (docs/protocol/40-menus-7-creative-inventory.md section 10): a gzip NBT compound with DataVersion (Int 5023, the current world data version of 07 section 7) and the
*> entries "0" to "8", each a list of nine compounds: an empty slot is the empty compound, an item the compound {id: String namespace:path (the namespace is not checked when reading; the stand-in items are cobolcraft:), count: Int}. A missing, unreadable or malformed file keeps nine
*> empty hotbars (the failures are only logged in the original, so nothing is shown here); a write that fails is ignored. The compression is gzip as for the other data files of the game folder (Open
*> question 7 of 40-7 leaves it unconfirmed); the stored data version is read and not used (no data fixer: an older version only reads what the layout above gives).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOTBAR-FILE-SAVE.
*> USING CLIENT-STATE: writes hotbar.nbt to the game directory from the nine saved hotbars (CR-HB); nothing when no game directory is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-FILE                PIC X(32) VALUE "hotbar.nbt".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COMPOUND            BINARY-LONG VALUE 10.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-VERSION             BINARY-LONG VALUE 5023.
 01 WS-NINE                BINARY-LONG VALUE 9.
 01 WS-H                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH-ID             PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-ID                  PIC X(64).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CL-GAME-DIR-LENGTH = 0
         GOBACK
     END-IF
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN
     MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VERSION
     PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 8
         MOVE WS-H TO WS-DIGIT
         MOVE SPACES TO WN
         MOVE WS-DIGIT TO WN(1:1)
         MOVE 1 TO WL
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-COMPOUND WS-NINE
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 8
             COMPUTE WS-N = WS-H * 9 + WS-J + 1
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             IF CR-HB-COUNT(WS-N) > 0
                 MOVE CR-HB-ITEM(WS-N) TO WS-ITEM
                 CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH-ID WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
                 MOVE SPACES TO WS-ID
                 STRING FUNCTION TRIM(WS-NS) ":" FUNCTION TRIM(WS-PATH-ID) DELIMITED BY SIZE INTO WS-ID
                 COMPUTE WS-ID-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NS)) + 1 + FUNCTION LENGTH(FUNCTION TRIM(WS-PATH-ID))
                 MOVE "id" TO WN
                 MOVE 2 TO WL
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID WS-ID-LENGTH
                 MOVE "count" TO WN
                 MOVE 5 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL CR-HB-COUNT(WS-N)
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-PERFORM
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-FILE-WRITE" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HOTBAR-FILE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HOTBAR-FILE-LOAD.
*> USING CLIENT-STATE: reads hotbar.nbt into the nine saved hotbars; all empty first, so a missing or bad file leaves nine empty hotbars; sets CR-HB-LOADED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-FILE                PIC X(32) VALUE "hotbar.nbt".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-INFO                PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-ITYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WN                     PIC X(16).
 01 WN-CAP                 BINARY-LONG VALUE 16.
 01 WL                     BINARY-LONG.
 01 WS-STR                 PIC X(256).
 01 WS-STR-CAP             BINARY-LONG VALUE 256.
 01 WS-STR-LEN             BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-ITEM                BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-I2                  BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH-ID             PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 81
         MOVE 0 TO CR-HB-ITEM(WS-N) CR-HB-COUNT(WS-N)
     END-PERFORM
     MOVE 1 TO CR-HB-LOADED
     IF CL-GAME-DIR-LENGTH = 0
         GOBACK
     END-IF
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME = 0
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
         MOVE 1 TO WS-TYPE
         PERFORM UNTIL WS-TYPE = 0
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
             EVALUATE TRUE
                 WHEN WS-TYPE = 0
                     CONTINUE
                 WHEN WL = 1 AND WN(1:1) >= "0" AND WN(1:1) <= "8" AND WS-TYPE = 9
                     COMPUTE WS-H = FUNCTION ORD(WN(1:1)) - FUNCTION ORD("0")
                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                         IF WS-ETYPE = 10
                             MOVE 1 TO WS-ITYPE
                             MOVE -1 TO WS-ITEM
                             MOVE 0 TO WS-CNT
                             PERFORM UNTIL WS-ITYPE = 0
                                 MOVE SPACES TO WN
                                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-ITYPE WN WN-CAP WL
                                 EVALUATE TRUE
                                     WHEN WS-ITYPE = 0
                                         CONTINUE
                                     WHEN WN = "id" AND WS-ITYPE = 8
                                         MOVE SPACES TO WS-STR
                                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-STR WS-STR-CAP WS-STR-LEN
                                         MOVE SPACES TO WS-KEY
                                         MOVE 0 TO WS-COLON
                                         PERFORM VARYING WS-I2 FROM WS-STR-LEN BY -1 UNTIL WS-I2 < 1
                                             IF WS-STR(WS-I2:1) = ":"
                                                 MOVE WS-I2 TO WS-COLON
                                             END-IF
                                         END-PERFORM
                                         IF WS-COLON > 0 AND WS-STR-LEN - WS-COLON >= 1 AND WS-STR-LEN - WS-COLON <= 16
                                             MOVE WS-STR(WS-COLON + 1:WS-STR-LEN - WS-COLON) TO WS-KEY
                                             CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY WS-ITEM
                                             MOVE 0 TO WS-ZERO
                                             CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ZERO WS-NS WS-PATH-ID WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
                                             IF WS-ITEM = 0 AND NOT (WS-KNOWN = 1 AND WS-PATH-ID = WS-KEY)
                                                 MOVE -1 TO WS-ITEM
                                             END-IF
                                         END-IF
                                     WHEN WN = "count" AND WS-ITYPE = 3
                                         CALL "PB-GET-INT" USING PB-BUFFER WS-CNT
                                     WHEN OTHER
                                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ITYPE
                                 END-EVALUATE
                             END-PERFORM
                             IF WS-I <= 9 AND WS-ITEM >= 0 AND WS-CNT > 0
                                 COMPUTE WS-N = WS-H * 9 + WS-I
                                 MOVE WS-ITEM TO CR-HB-ITEM(WS-N)
                                 MOVE WS-CNT TO CR-HB-COUNT(WS-N)
                             END-IF
                         ELSE
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                         END-IF
                     END-PERFORM
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM HOTBAR-FILE-LOAD.
