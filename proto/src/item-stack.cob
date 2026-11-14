*> Item stack with a DataComponentPatch (docs/protocol/00-data-types.md §12.1, §12.2), on the
*> record PB-ITEMSTACK-X of contract/copy/PROTO.cpy. The older PB-PUT-ITEMSTACK and
*> PB-GET-ITEMSTACK of composites.cob (empty patch only) stay for the 001 callers.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-ITEM-STACK.
*> USING PB-BUFFER, PB-ITEMSTACK-X: Count VarInt; when Count > 0 also Item VarInt, AddedCount and
*> RemovedCount VarInts, each added component as its type VarInt and its value bytes verbatim, then
*> each removed type VarInt. Count <= 0 is the empty stack (VarInt 0, nothing more). A negative item
*> or type id, a count outside 0 to PB-ISX-MAX-COMPONENTS or a value length outside 0 to
*> PB-ISX-VALUE-MAX appends nothing and sets PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-VALID               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-ITEMSTACK-X.
     IF PB-ISX-COUNT <= 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         GOBACK
     END-IF
     MOVE 1 TO WS-VALID
     IF PB-ISX-ITEM < 0
             OR PB-ISX-ADDED-COUNT < 0 OR PB-ISX-ADDED-COUNT > PB-ISX-MAX-COMPONENTS
             OR PB-ISX-REMOVED-COUNT < 0 OR PB-ISX-REMOVED-COUNT > PB-ISX-MAX-COMPONENTS
         MOVE 0 TO WS-VALID
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
             IF PB-ISX-TYPE(WS-I) < 0 OR PB-ISX-VALUE-LENGTH(WS-I) < 0
                     OR PB-ISX-VALUE-LENGTH(WS-I) > PB-ISX-VALUE-MAX
                 MOVE 0 TO WS-VALID
             END-IF
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-REMOVED-COUNT
             IF PB-ISX-REMOVED(WS-I) < 0
                 MOVE 0 TO WS-VALID
             END-IF
         END-PERFORM
     END-IF
     IF WS-VALID = 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-ITEM
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-ADDED-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-REMOVED-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-TYPE(WS-I)
         CALL "PB-APPEND-BYTES" USING PB-BUFFER PB-ISX-VALUE(WS-I) PB-ISX-VALUE-LENGTH(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-REMOVED-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-ISX-REMOVED(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM PB-PUT-ITEM-STACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-ITEM-STACK.
*> USING PB-BUFFER, PB-ITEMSTACK-X out: the layout of PB-PUT-ITEM-STACK. 00 §12.2 leaves each
*> component's value to its own codec, so a value is read only for the types whose layout the
*> documents give (17 §1.2): VarInt for 1, 2, 3, 12, 19, 31 and 75; no payload for 4, 22 and 34;
*> Boolean for 21; Float for 7 and 54; a text component (00 §9, as PB-GET-TEXT reads it) for 6;
*> ItemEnchantments for 13 and 45 (a VarInt count of 0 to PB-ISX-VALUE-MAX, then that many pairs of
*> VarInt enchantment id and VarInt level); the book components 56 and 57 (a book whose value is over PB-ISX-VALUE-MAX bytes is
*> an error, as any value: the stack is then rejected whole).
*> The bytes of the value are kept verbatim in PB-ISX-VALUE. Any other type, a count above
*> PB-ISX-MAX-COMPONENTS or negative, a value longer than PB-ISX-VALUE-MAX or a short read sets
*> PB-ERROR, leaves PB-POS where it was and yields an all-zero record.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-START               BINARY-LONG.
 01 WS-VALUE-START         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SCRATCH             BINARY-LONG.
 01 WS-CONTAINED           BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-BOOLEAN             BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PAIRS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PAGES               BINARY-LONG.
 01 WS-STR                 PIC X(3100).
 01 WS-STR-LEN             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 3100.
 01 WS-MAX-PAGE            BINARY-LONG VALUE 1024.
 01 WS-MAX-TITLE           BINARY-LONG VALUE 32.
 01 WS-MAX-AUTHOR          BINARY-LONG VALUE 1000.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-ITEMSTACK-X.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-ITEMSTACK-X
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-COUNT
     IF PB-ISX-COUNT <= 0
         MOVE 0 TO PB-ISX-COUNT
         GOBACK
     END-IF
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-ITEM
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-ADDED-COUNT
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-REMOVED-COUNT
     IF PB-ISX-ADDED-COUNT < 0 OR PB-ISX-ADDED-COUNT > PB-ISX-MAX-COMPONENTS
             OR PB-ISX-REMOVED-COUNT < 0 OR PB-ISX-REMOVED-COUNT > PB-ISX-MAX-COMPONENTS
         MOVE 1 TO PB-ERROR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-ADDED-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-TYPE(WS-I)
         MOVE PB-POS TO WS-VALUE-START
         EVALUATE PB-ISX-TYPE(WS-I)
             WHEN 1 WHEN 2 WHEN 3 WHEN 12 WHEN 19 WHEN 31 WHEN 75
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
             WHEN 4 WHEN 22 WHEN 34
                 CONTINUE
             WHEN 21
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOLEAN
             WHEN 7 WHEN 54
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             WHEN 6
                 CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
*>           container (77, ItemContainerContents): a VarInt count of 0 to 256, then that many stacks, each a count (0 = empty) and, when
*>           not empty, item, added and removed counts of 0 (a stack with components inside a container is not read)
             WHEN 77
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-CONTAINED
                 IF WS-CONTAINED < 0 OR WS-CONTAINED > 256
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO WS-CONTAINED
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CONTAINED OR PB-ERROR = 1
                     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                     IF WS-SCRATCH > 0
                         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                         IF WS-SCRATCH NOT = 0
                             MOVE 1 TO PB-ERROR
                         END-IF
                         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                         IF WS-SCRATCH NOT = 0
                             MOVE 1 TO PB-ERROR
                         END-IF
                     END-IF
                 END-PERFORM
             WHEN 13 WHEN 45
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                 IF WS-SCRATCH < 0 OR WS-SCRATCH > PB-ISX-VALUE-MAX
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO WS-SCRATCH
                 END-IF
                 COMPUTE WS-PAIRS = WS-SCRATCH * 2
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-PAIRS OR PB-ERROR = 1
                     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                 END-PERFORM
             WHEN 56
*>               WritableBookContent: a VarInt page count (at most 100), each page a Filterable<String(1024)>: the raw string, a Boolean, and when
*>               true the filtered string (the Filterable layout is read from no document: 25 Open question 5; this is the vanilla codec shape).
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-PAGES
                 IF WS-PAGES < 0 OR WS-PAGES > 100
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO WS-PAGES
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-PAGES OR PB-ERROR = 1
                     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-PAGE WS-STR WS-CAPACITY WS-STR-LEN
                     CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOLEAN
                     IF WS-BOOLEAN = 1
                         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-PAGE WS-STR WS-CAPACITY WS-STR-LEN
                     END-IF
                 END-PERFORM
             WHEN 57
*>               WrittenBookContent: title Filterable<String(32)>, author String, generation VarInt 0 to 3, pages a VarInt count of
*>               Filterable<Component> (the component then a Boolean and the filtered component), resolved Boolean.
                 CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-TITLE WS-STR WS-CAPACITY WS-STR-LEN
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOLEAN
                 IF WS-BOOLEAN = 1
                     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-TITLE WS-STR WS-CAPACITY WS-STR-LEN
                 END-IF
                 CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-AUTHOR WS-STR WS-CAPACITY WS-STR-LEN
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-SCRATCH
                 IF WS-SCRATCH < 0 OR WS-SCRATCH > 3
                     MOVE 1 TO PB-ERROR
                 END-IF
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-PAGES
                 IF WS-PAGES < 0 OR WS-PAGES > 100
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO WS-PAGES
                 END-IF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-PAGES OR PB-ERROR = 1
                     CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
                     CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOLEAN
                     IF WS-BOOLEAN = 1
                         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
                     END-IF
                 END-PERFORM
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-BOOLEAN
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
         COMPUTE WS-LENGTH = PB-POS - WS-VALUE-START
         IF WS-LENGTH > PB-ISX-VALUE-MAX
             MOVE 1 TO PB-ERROR
         END-IF
         IF PB-ERROR = 0
             MOVE WS-LENGTH TO PB-ISX-VALUE-LENGTH(WS-I)
             MOVE WS-VALUE-START TO PB-POS
             IF WS-LENGTH > 0
                 CALL "PB-GET-BYTES" USING PB-BUFFER PB-ISX-VALUE(WS-I) WS-LENGTH
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-ISX-REMOVED-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-ISX-REMOVED(WS-I)
     END-PERFORM
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-ITEMSTACK-X
     END-IF
     GOBACK.
 END PROGRAM PB-GET-ITEM-STACK.
