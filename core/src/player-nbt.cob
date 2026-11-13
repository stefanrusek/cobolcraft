*> The NBT forms of the stored player state (docs/protocol/45-entity-nbt-3-player-and-player-data.md section 3.5 and 4;
*> players/<offline-uuid>.dat, 07 section 9.2), used by PLAYER-DAT-WRITE and PLAYER-DAT-READ (core/src/player-data.cob).
*>
*> A stack is a compound of id (string), count (Int) and, when its patch is not empty, components. The components of the
*> cobolcraft files are the canonical patch of core/copy/CSTACKE.cpy: added (a list of {type: Int, value: ByteArray}, the
*> value bytes as the wire has them) and removed (an IntArray of component type ids); only a cobolcraft reader needs them.
*>
*> Entry points (the compound's begin and end tags are the caller's):
*>   PNBT-STACK-WRITE USING PB-BUFFER, item, count, patch number    id, count and components of one stack
*>   PNBT-STACK-READ USING PB-BUFFER, slot out (-1: no Slot key), item out, count out, patch number out
*>   PNBT-BOOK-WRITE USING PB-BUFFER, known row                       the recipeBook compound's keys
*>   PNBT-BOOK-READ USING PB-BUFFER, known row                        reads them (a book without both lists is ignored)
*>   PNBT-EQUIP-WRITE USING PB-BUFFER, known row                      the equipment compound's keys
*>   PNBT-EQUIP-READ USING PB-BUFFER, known row                       reads them

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-STACK-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY KNSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-I                   BINARY-LONG.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-KP                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ITEM L-COUNT L-KP.
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "PERSIST-NAMESPACED" USING IT-KEY(L-ITEM + 1) IT-KEY-LENGTH(L-ITEM + 1) WS-NS-KEY WS-NS-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
     MOVE "count" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL L-COUNT
     IF L-KP >= 1 AND L-KP <= KX-MAX-PATCHES
         IF KP-LIVE(L-KP) = 1
             MOVE "components" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
             IF KP-ADDED-COUNT(L-KP) > 0
                 MOVE "added" TO WN MOVE 5 TO WL
                 CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND KP-ADDED-COUNT(L-KP)
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KP-ADDED-COUNT(L-KP)
                     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                     MOVE "type" TO WN MOVE 4 TO WL
                     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL KP-TYPE(L-KP, WS-I)
                     MOVE "value" TO WN MOVE 5 TO WL
                     CALL "NBT-WRITE-BYTE-ARRAY" USING PB-BUFFER WN WL KP-LENGTH(L-KP, WS-I)
                         KP-VALUE(L-KP, WS-I)
                     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 END-PERFORM
                 CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
             END-IF
             IF KP-REMOVED-COUNT(L-KP) > 0
                 MOVE "removed" TO WN MOVE 7 TO WL
                 CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL KP-REMOVED-COUNT(L-KP)
                     KP-REMOVED(L-KP, 1)
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PNBT-STACK-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-COMPONENTS-READ.
*> USING PB-BUFFER (positioned inside a components compound), patch number out: a new KX-PATCH entry of the compound (0
*> when it adds and removes nothing, or KX-PATCH is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY KNSTATE.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COMPONENT-TYPE      BINARY-LONG.
 01 WS-VALUE               PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-REMOVED-CAPACITY    BINARY-LONG VALUE 8.
 01 WS-TEMP.
    05 WT-ENTRY.
       COPY CSTACKE REPLACING LEADING ==SP-== BY ==WT-==.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KP                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-KP.
     MOVE 0 TO L-KP
     INITIALIZE WT-ENTRY
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "added" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE -1 TO WS-COMPONENT-TYPE
                     MOVE 0 TO WS-LENGTH
                     MOVE SPACES TO WS-VALUE
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-NAME-CAPACITY WL
                         IF WS-INNER = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "type" AND WS-INNER = 3
                                 CALL "PB-GET-INT" USING PB-BUFFER WS-COMPONENT-TYPE
                             WHEN WN = "value" AND WS-INNER = 7
                                 CALL "NBT-READ-BYTE-ARRAY" USING PB-BUFFER WS-CAPACITY WS-LENGTH WS-VALUE
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                         END-EVALUATE
                     END-PERFORM
                     IF WS-COMPONENT-TYPE >= 0 AND WT-ADDED-COUNT < 8
                         ADD 1 TO WT-ADDED-COUNT
                         MOVE WS-COMPONENT-TYPE TO WT-TYPE(WT-ADDED-COUNT)
                         MOVE WS-LENGTH TO WT-LENGTH(WT-ADDED-COUNT)
                         MOVE WS-VALUE TO WT-VALUE(WT-ADDED-COUNT)
                     END-IF
                 END-PERFORM
             WHEN WN = "removed" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-REMOVED-CAPACITY WT-REMOVED-COUNT WT-REMOVED(1)
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WT-ADDED-COUNT > 0 OR WT-REMOVED-COUNT > 0
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > KX-MAX-PATCHES OR L-KP > 0
             IF KP-LIVE(WS-N) = 0
                 MOVE WT-ENTRY TO KX-PATCH(WS-N)
                 MOVE 1 TO KP-LIVE(WS-N)
                 MOVE WS-N TO L-KP
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PNBT-COMPONENTS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-STACK-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-LOCAL               PIC X(48).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-BARE                PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-KP                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SLOT L-ITEM L-COUNT L-KP.
     MOVE -1 TO L-SLOT
     MOVE 0 TO L-ITEM L-COUNT L-KP
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Slot" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER L-SLOT
             WHEN WN = "id" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > IT-COUNT
                     IF IT-KEY(WS-K) = WS-LOCAL OR IT-KEY(WS-K) = WS-BARE
                         COMPUTE L-ITEM = WS-K - 1
                     END-IF
                 END-PERFORM
             WHEN WN = "count" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER L-COUNT
             WHEN WN = "components" AND WS-TYPE = 10
                 CALL "PNBT-COMPONENTS-READ" USING PB-BUFFER L-KP
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM PNBT-STACK-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-EQUIP-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY KNSTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-KNOWN.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 5
         IF KX-EQUIP-COUNT(L-KNOWN, WS-S) > 0
             EVALUATE WS-S
                 WHEN 1 MOVE "feet" TO WN MOVE 4 TO WL
                 WHEN 2 MOVE "legs" TO WN MOVE 4 TO WL
                 WHEN 3 MOVE "chest" TO WN MOVE 5 TO WL
                 WHEN 4 MOVE "head" TO WN MOVE 4 TO WL
                 WHEN OTHER MOVE "offhand" TO WN MOVE 7 TO WL
             END-EVALUATE
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
             CALL "PNBT-STACK-WRITE" USING PB-BUFFER KX-EQUIP-ITEM(L-KNOWN, WS-S)
                 KX-EQUIP-COUNT(L-KNOWN, WS-S) KX-EQUIP-KP(L-KNOWN, WS-S)
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PNBT-EQUIP-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-EQUIP-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY KNSTATE.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-KNOWN.
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-S
         EVALUATE TRUE
             WHEN WN = "feet" MOVE 1 TO WS-S
             WHEN WN = "legs" MOVE 2 TO WS-S
             WHEN WN = "chest" MOVE 3 TO WS-S
             WHEN WN = "head" MOVE 4 TO WS-S
             WHEN WN = "offhand" MOVE 5 TO WS-S
         END-EVALUATE
         IF WS-S > 0 AND WS-TYPE = 10
             CALL "PNBT-STACK-READ" USING PB-BUFFER WS-SLOT WS-ITEM WS-COUNT WS-KP
             IF WS-ITEM > 0 AND WS-COUNT > 0
                 CALL "KX-PATCH-FREE" USING KX-EQUIP-KP(L-KNOWN, WS-S)
                 MOVE WS-ITEM TO KX-EQUIP-ITEM(L-KNOWN, WS-S)
                 MOVE WS-COUNT TO KX-EQUIP-COUNT(L-KNOWN, WS-S)
                 MOVE WS-KP TO KX-EQUIP-KP(L-KNOWN, WS-S)
             ELSE
                 CALL "KX-PATCH-FREE" USING WS-KP
             END-IF
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PNBT-EQUIP-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-BOOK-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY KNSTATE.
 01 WN                     PIC X(40).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-I                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-KNOWN.
     MOVE "isGuiOpen" TO WN MOVE 9 TO WL
     MOVE KX-BOOK-OPEN(L-KNOWN, 1) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isFilteringCraftable" TO WN MOVE 20 TO WL
     MOVE KX-BOOK-FILTER(L-KNOWN, 1) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isFurnaceGuiOpen" TO WN MOVE 16 TO WL
     MOVE KX-BOOK-OPEN(L-KNOWN, 2) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isFurnaceFilteringCraftable" TO WN MOVE 27 TO WL
     MOVE KX-BOOK-FILTER(L-KNOWN, 2) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isBlastingFurnaceGuiOpen" TO WN MOVE 24 TO WL
     MOVE KX-BOOK-OPEN(L-KNOWN, 3) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isBlastingFurnaceFilteringCraftable" TO WN MOVE 35 TO WL
     MOVE KX-BOOK-FILTER(L-KNOWN, 3) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isSmokerGuiOpen" TO WN MOVE 15 TO WL
     MOVE KX-BOOK-OPEN(L-KNOWN, 4) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     MOVE "isSmokerFilteringCraftable" TO WN MOVE 26 TO WL
     MOVE KX-BOOK-FILTER(L-KNOWN, 4) TO WS-VALUE
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-VALUE
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RC-COUNT
             IF KX-FLAG(L-KNOWN, WS-I) > WS-PASS - 1
                 ADD 1 TO WS-COUNT
             END-IF
         END-PERFORM
         IF WS-PASS = 1
             MOVE "recipes" TO WN MOVE 7 TO WL
         ELSE
             MOVE "toBeDisplayed" TO WN MOVE 13 TO WL
         END-IF
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RC-COUNT
             IF KX-FLAG(L-KNOWN, WS-I) > WS-PASS - 1
                 COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(RR-KEY(WS-I) TRAILING))
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT RR-KEY(WS-I) WS-KEY-LENGTH
             END-IF
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-PERFORM
     GOBACK.
 END PROGRAM PNBT-BOOK-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PNBT-BOOK-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY KNSTATE.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 40.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 112.
 01 WN                     PIC X(40).
 01 WL                     BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LISTS               BINARY-LONG.
 01 WS-FLAGS.
    05 WS-FLAG             BINARY-CHAR UNSIGNED OCCURS 4096 TIMES.
 01 WS-SETTINGS.
    05 WS-OPEN             PIC 9 OCCURS 4 TIMES.
    05 WS-FILTER           PIC 9 OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-KNOWN.
     MOVE 0 TO WS-LISTS
     INITIALIZE WS-FLAGS WS-SETTINGS
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
                 IF WS-VALUE NOT = 0
                     MOVE 1 TO WS-VALUE
                 END-IF
                 EVALUATE WN
                     WHEN "isGuiOpen" MOVE WS-VALUE TO WS-OPEN(1)
                     WHEN "isFilteringCraftable" MOVE WS-VALUE TO WS-FILTER(1)
                     WHEN "isFurnaceGuiOpen" MOVE WS-VALUE TO WS-OPEN(2)
                     WHEN "isFurnaceFilteringCraftable" MOVE WS-VALUE TO WS-FILTER(2)
                     WHEN "isBlastingFurnaceGuiOpen" MOVE WS-VALUE TO WS-OPEN(3)
                     WHEN "isBlastingFurnaceFilteringCraftable" MOVE WS-VALUE TO WS-FILTER(3)
                     WHEN "isSmokerGuiOpen" MOVE WS-VALUE TO WS-OPEN(4)
                     WHEN "isSmokerFilteringCraftable" MOVE WS-VALUE TO WS-FILTER(4)
                 END-EVALUATE
             WHEN (WN = "recipes" OR WN = "toBeDisplayed") AND WS-TYPE = 9
                 ADD 1 TO WS-LISTS
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-KEY
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT
                         IF RR-KEY(WS-K) = WS-KEY AND RR-SPECIAL(WS-K) = 0
                             IF WN = "recipes" AND WS-FLAG(WS-K) = 0
                                 MOVE 1 TO WS-FLAG(WS-K)
                             END-IF
                             IF WN = "toBeDisplayed"
                                 MOVE 2 TO WS-FLAG(WS-K)
                             END-IF
                         END-IF
                     END-PERFORM
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WS-LISTS = 2 AND PB-ERROR = 0
         MOVE 1 TO KX-BOOK-SET(L-KNOWN)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE WS-OPEN(WS-I) TO KX-BOOK-OPEN(L-KNOWN, WS-I)
             MOVE WS-FILTER(WS-I) TO KX-BOOK-FILTER(L-KNOWN, WS-I)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
             MOVE WS-FLAG(WS-I) TO KX-FLAG(L-KNOWN, WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PNBT-BOOK-READ.
