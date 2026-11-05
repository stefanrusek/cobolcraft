*> Composite codecs (docs/protocol/00-data-types.md §9, §12, §13; contracts/proto-api.md §2 "Composite"),
*> on the records of contract/copy/PROTO.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-TEXT.
*> USING PB-BUFFER, PB-TEXT: a text component as network NBT (00 §9.1) in CobolCraft's fixed form
*> (docs/protocol/09-cobolcraft-profile.md §1): plain = a bare String root; literal = Compound
*> {text}; translate = Compound {translate, then with: List of String when there are arguments}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-NO-NAME             PIC X VALUE SPACE.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-STRING-TYPE         BINARY-LONG VALUE 8.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT.
     IF PB-TX-KIND = PB-TEXT-PLAIN
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NO-NAME WS-ROOT PB-TX-VALUE PB-TX-LENGTH
     ELSE
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NO-NAME WS-ROOT
         IF PB-TX-KIND = PB-TEXT-LITERAL
             MOVE 4 TO WS-NAME-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER "text" WS-NAME-LENGTH
                 PB-TX-VALUE PB-TX-LENGTH
         ELSE
             MOVE 9 TO WS-NAME-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER "translate" WS-NAME-LENGTH
                 PB-TX-VALUE PB-TX-LENGTH
             IF PB-TX-ARG-COUNT > 0
                 MOVE 4 TO WS-NAME-LENGTH
                 CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER "with" WS-NAME-LENGTH
                     WS-STRING-TYPE PB-TX-ARG-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-ARG-COUNT
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NO-NAME WS-ELEMENT
                         PB-TX-ARG-VALUE(WS-I) PB-TX-ARG-LENGTH(WS-I)
                 END-PERFORM
                 CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
             END-IF
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-TEXT.
*> USING PB-BUFFER, PB-TEXT out: a network NBT text component. A String root is plain text; a
*> Compound root takes "text" (literal) or "translate" with optional "with" (a List of at most
*> PB-TEXT-MAX-ARGS Strings); other entries are skipped. Anything else, a text longer than 1024
*> bytes, or a compound with neither key: PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NETWORK             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS-KEY             BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 1024.
 01 WS-NAME.
    05 WS-NAME-FIRST       PIC X.
    05 FILLER              PIC X(63).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT.
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 0 TO PB-TX-LENGTH PB-TX-ARG-COUNT WS-HAS-KEY
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-NETWORK WS-TYPE
     EVALUATE WS-TYPE
         WHEN 8
             CALL "NBT-READ-STRING" USING PB-BUFFER PB-TX-VALUE WS-TEXT-CAPACITY PB-TX-LENGTH
         WHEN 10
             PERFORM WITH TEST AFTER UNTIL WS-TYPE = 0
                 MOVE SPACES TO WS-NAME
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME-FIRST
                     WS-NAME-CAPACITY WS-NAME-LENGTH
                 EVALUATE TRUE
                     WHEN WS-TYPE = 8 AND WS-NAME = "text"
                         MOVE PB-TEXT-LITERAL TO PB-TX-KIND
                         MOVE 1 TO WS-HAS-KEY
                         CALL "NBT-READ-STRING" USING PB-BUFFER PB-TX-VALUE WS-TEXT-CAPACITY
                             PB-TX-LENGTH
                     WHEN WS-TYPE = 8 AND WS-NAME = "translate"
                         MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
                         MOVE 1 TO WS-HAS-KEY
                         CALL "NBT-READ-STRING" USING PB-BUFFER PB-TX-VALUE WS-TEXT-CAPACITY
                             PB-TX-LENGTH
                     WHEN WS-TYPE = 9 AND WS-NAME = "with"
                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                         IF WS-COUNT > PB-TEXT-MAX-ARGS
                                 OR (WS-COUNT > 0 AND WS-ELEMENT-TYPE NOT = 8)
                             MOVE 1 TO PB-ERROR
                             MOVE 0 TO WS-TYPE
                         ELSE
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                                 CALL "NBT-READ-STRING" USING PB-BUFFER PB-TX-ARG-VALUE(WS-I)
                                     WS-TEXT-CAPACITY PB-TX-ARG-LENGTH(WS-I)
                             END-PERFORM
                             MOVE WS-COUNT TO PB-TX-ARG-COUNT
                         END-IF
                     WHEN WS-TYPE > 0
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-EVALUATE
             END-PERFORM
             IF WS-HAS-KEY = 0
                 MOVE 1 TO PB-ERROR
             END-IF
         WHEN OTHER
             MOVE 1 TO PB-ERROR
     END-EVALUATE
     GOBACK.
 END PROGRAM PB-GET-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-ITEMSTACK.
*> USING PB-BUFFER, PB-ITEMSTACK: 00 §12.1 ItemStack, optional form. Count <= 0 is the empty stack
*> (VarInt 0); otherwise count, item id and an empty DataComponentPatch (standin-content §2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-ITEMSTACK.
     IF PB-IS-COUNT <= 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-IS-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-IS-ITEM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-ITEMSTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-ITEMSTACK.
*> USING PB-BUFFER, PB-ITEMSTACK out. A count <= 0 is the empty stack (count 0, item 0, nothing more
*> read). A stack with data components is malformed for CobolCraft: PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-ITEMSTACK.
     MOVE 0 TO PB-IS-ITEM
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-IS-COUNT
     IF PB-IS-COUNT <= 0
         MOVE 0 TO PB-IS-COUNT
     ELSE
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-IS-ITEM
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-ADDED
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-REMOVED
         IF WS-ADDED NOT = 0 OR WS-REMOVED NOT = 0
             MOVE 1 TO PB-ERROR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PB-GET-ITEMSTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-ENTITY-METADATA.
*> USING PB-BUFFER, PB-METADATA-ENTRY: one 00 §13.1 entry (UByte index, VarInt serializer, value),
*> or the terminator byte 0xFF when PB-MD-INDEX is PB-MD-END. Only the serializers of PROTO.cpy
*> (BYTE, INT, FLOAT, ITEM_STACK, BOOLEAN, POSE) are encoded; another serializer or an index outside
*> 0 to 254 sets PB-ERROR and appends nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-SERIALIZER          BINARY-LONG.
    88 WS-SUPPORTED        VALUES 0 1 3 7 8 20.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-METADATA-ENTRY.
     MOVE PB-MD-SERIALIZER TO WS-SERIALIZER
     EVALUATE TRUE
         WHEN PB-MD-INDEX = PB-MD-END
             CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-MD-INDEX
         WHEN PB-MD-INDEX < 0 OR PB-MD-INDEX > 254 OR NOT WS-SUPPORTED
             MOVE 1 TO PB-ERROR
         WHEN OTHER
             CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-MD-INDEX
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MD-SERIALIZER
             EVALUATE PB-MD-SERIALIZER
                 WHEN PB-MDS-BYTE
                     CALL "PB-PUT-BYTE" USING PB-BUFFER PB-MD-INT
                 WHEN PB-MDS-INT
                 WHEN PB-MDS-POSE
                     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MD-INT
                 WHEN PB-MDS-FLOAT
                     CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MD-FLOAT
                 WHEN PB-MDS-ITEM-STACK
                     MOVE PB-MD-IS-COUNT TO WS-IS-COUNT
                     MOVE PB-MD-IS-ITEM TO WS-IS-ITEM
                     CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
                 WHEN PB-MDS-BOOLEAN
                     CALL "PB-PUT-BOOL" USING PB-BUFFER PB-MD-INT
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM PB-PUT-ENTITY-METADATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-ENTITY-METADATA.
*> USING PB-BUFFER, PB-METADATA-ENTRY out: one 00 §13.1 entry; PB-MD-INDEX = PB-MD-END for the
*> terminator (nothing else read). Value fields the serializer does not use are 0. A serializer
*> outside PROTO.cpy, a short read or a stack with data components sets PB-ERROR, leaves PB-POS
*> where it was and yields an all-zero entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-METADATA-ENTRY.
     MOVE PB-POS TO WS-START
     MOVE 0 TO PB-MD-SERIALIZER PB-MD-INT PB-MD-FLOAT PB-MD-IS-COUNT PB-MD-IS-ITEM
     CALL "PB-GET-UBYTE" USING PB-BUFFER PB-MD-INDEX
     IF PB-MD-INDEX NOT = PB-MD-END
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-MD-SERIALIZER
         EVALUATE PB-MD-SERIALIZER
             WHEN PB-MDS-BYTE
                 CALL "PB-GET-BYTE" USING PB-BUFFER PB-MD-INT
             WHEN PB-MDS-INT
             WHEN PB-MDS-POSE
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MD-INT
             WHEN PB-MDS-FLOAT
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MD-FLOAT
             WHEN PB-MDS-ITEM-STACK
                 CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
                 MOVE WS-IS-COUNT TO PB-MD-IS-COUNT
                 MOVE WS-IS-ITEM TO PB-MD-IS-ITEM
             WHEN PB-MDS-BOOLEAN
                 CALL "PB-GET-BOOL" USING PB-BUFFER PB-MD-INT
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO PB-MD-INDEX PB-MD-SERIALIZER PB-MD-INT PB-MD-FLOAT PB-MD-IS-COUNT
             PB-MD-IS-ITEM
     END-IF
     GOBACK.
 END PROGRAM PB-GET-ENTITY-METADATA.
