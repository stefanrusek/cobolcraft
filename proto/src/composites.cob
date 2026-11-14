*> Composite codecs (docs/protocol/00-data-types.md §9, §12, §13; 05b SlotDisplay, RecipeDisplayEntry and
*> RecipeDisplay; 05a 0x10 CommandNode; contracts/proto-api.md §2 "Composite"), on the records of
*> contract/copy/PROTO.cpy.

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
 PROGRAM-ID. PB-PUT-STYLED-TEXT.
*> USING PB-BUFFER, PB-TEXT, PB-TEXT-STYLE: PB-PUT-TEXT plus the style entries (color, italic, underlined, click_event, extra) of the style record: a text component as network NBT (00 §9.1) in CobolCraft's fixed form
*> (docs/protocol/09-cobolcraft-profile.md §1): plain = a bare String root; literal = Compound
*> {text}; translate = Compound {translate, then with: List of String when there are arguments}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROOT                BINARY-LONG VALUE -2.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-NO-NAME             PIC X VALUE SPACE.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-STRING-TYPE         BINARY-LONG VALUE 8.
 01 WS-COMPOUND-TYPE       BINARY-LONG VALUE 10.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT PB-TEXT-STYLE.
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
         CALL "PB-PUT-STYLE" USING PB-BUFFER PB-TS-COLOR PB-TS-ITALIC PB-TS-UNDERLINED
         IF PB-TS-CLICK-LENGTH > 0
             MOVE 11 TO WS-NAME-LENGTH
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER "click_event" WS-NAME-LENGTH
             MOVE 6 TO WS-NAME-LENGTH
             MOVE 15 TO WS-VALUE-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER "action" WS-NAME-LENGTH
                 "suggest_command" WS-VALUE-LENGTH
             MOVE 7 TO WS-NAME-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER "command" WS-NAME-LENGTH
                 PB-TS-CLICK PB-TS-CLICK-LENGTH
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
         IF PB-TS-EXTRA-COUNT > 0
             MOVE 5 TO WS-NAME-LENGTH
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER "extra" WS-NAME-LENGTH
                 WS-COMPOUND-TYPE PB-TS-EXTRA-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TS-EXTRA-COUNT
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NO-NAME WS-ELEMENT
                 IF PB-TSE-KIND(WS-I) = PB-TEXT-LITERAL
                     MOVE 4 TO WS-NAME-LENGTH
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER "text" WS-NAME-LENGTH
                         PB-TSE-VALUE(WS-I) PB-TSE-LENGTH(WS-I)
                 ELSE
                     MOVE 9 TO WS-NAME-LENGTH
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER "translate" WS-NAME-LENGTH
                         PB-TSE-VALUE(WS-I) PB-TSE-LENGTH(WS-I)
                 END-IF
                 CALL "PB-PUT-STYLE" USING PB-BUFFER PB-TSE-COLOR(WS-I)
                     PB-TSE-ITALIC(WS-I) PB-TSE-UNDERLINED(WS-I)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-PERFORM
             CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-STYLED-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-STYLE.
*> USING PB-BUFFER, color (PIC X(12), spaces = none), italic, underlined (PIC 9, 1 = write true):
*> the style entries color (String), italic and underlined (Byte 1) of the compound being written.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-TRUE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COLOR                PIC X(12).
 01 L-ITALIC               PIC 9.
 01 L-UNDERLINED           PIC 9.
 PROCEDURE DIVISION USING PB-BUFFER L-COLOR L-ITALIC L-UNDERLINED.
     IF L-COLOR NOT = SPACES
         MOVE 5 TO WS-NAME-LENGTH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-COLOR)) TO WS-VALUE-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER "color" WS-NAME-LENGTH L-COLOR WS-VALUE-LENGTH
     END-IF
     IF L-ITALIC = 1
         MOVE 6 TO WS-NAME-LENGTH
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER "italic" WS-NAME-LENGTH WS-TRUE
     END-IF
     IF L-UNDERLINED = 1
         MOVE 10 TO WS-NAME-LENGTH
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER "underlined" WS-NAME-LENGTH WS-TRUE
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-STYLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-STYLED-TEXT.
*> USING PB-BUFFER, PB-TEXT out, PB-TEXT-STYLE out: PB-GET-TEXT plus the style entries (cleared first); a network NBT text component. A String root is plain text; a
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
 01 WS-COLOR-CAPACITY      BINARY-LONG VALUE 12.
 01 WS-COLOR-LENGTH        BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NAME.
    05 WS-NAME-FIRST       PIC X.
    05 FILLER              PIC X(63).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT PB-TEXT-STYLE.
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE 0 TO PB-TX-LENGTH PB-TX-ARG-COUNT WS-HAS-KEY PB-TS-ITALIC
         PB-TS-UNDERLINED PB-TS-CLICK-LENGTH PB-TS-EXTRA-COUNT
     MOVE SPACES TO PB-TS-COLOR
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
                     WHEN WS-TYPE = 8 AND WS-NAME = "color"
                         CALL "NBT-READ-STRING" USING PB-BUFFER PB-TS-COLOR WS-COLOR-CAPACITY
                             WS-COLOR-LENGTH
                     WHEN WS-TYPE = 1 AND WS-NAME = "italic"
                         CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                         MOVE WS-BYTE TO PB-TS-ITALIC
                     WHEN WS-TYPE = 1 AND WS-NAME = "underlined"
                         CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                         MOVE WS-BYTE TO PB-TS-UNDERLINED
                     WHEN WS-TYPE = 10 AND WS-NAME = "click_event"
                         CALL "PB-GET-CLICK" USING PB-BUFFER PB-TEXT-STYLE
                     WHEN WS-TYPE = 9 AND WS-NAME = "extra"
                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                         IF WS-COUNT > PB-TEXT-MAX-EXTRA
                                 OR (WS-COUNT > 0 AND WS-ELEMENT-TYPE NOT = 10)
                             MOVE 1 TO PB-ERROR
                             MOVE 0 TO WS-TYPE
                         ELSE
                             MOVE WS-COUNT TO PB-TS-EXTRA-COUNT
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                                 CALL "PB-GET-EXTRA" USING PB-BUFFER PB-TEXT-STYLE WS-I
                             END-PERFORM
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
 END PROGRAM PB-GET-STYLED-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-CLICK.
*> USING PB-BUFFER, PB-TEXT-STYLE: the payload of a click_event compound; "command" is kept in
*> PB-TS-CLICK (other entries are skipped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-NAME.
    05 WS-NAME-FIRST       PIC X.
    05 FILLER              PIC X(63).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT-STYLE.
     PERFORM WITH TEST AFTER UNTIL WS-TYPE = 0
         MOVE SPACES TO WS-NAME
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME-FIRST
             WS-NAME-CAPACITY WS-NAME-LENGTH
         IF WS-TYPE = 8 AND WS-NAME = "command"
             CALL "NBT-READ-STRING" USING PB-BUFFER PB-TS-CLICK WS-CAPACITY PB-TS-CLICK-LENGTH
         ELSE
             IF WS-TYPE > 0
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PB-GET-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-EXTRA.
*> USING PB-BUFFER, PB-TEXT-STYLE, index: one element compound of the "extra" list into PB-TS-EXTRA(index):
*> text or translate, color, italic, underlined. A compound with neither text nor translate is
*> PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-HAS-KEY             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-COLOR-CAPACITY      BINARY-LONG VALUE 12.
 01 WS-COLOR-LENGTH        BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-NAME.
    05 WS-NAME-FIRST       PIC X.
    05 FILLER              PIC X(63).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 64.
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PB-TEXT-STYLE L-INDEX.
     MOVE 0 TO WS-HAS-KEY PB-TSE-LENGTH(L-INDEX) PB-TSE-ITALIC(L-INDEX)
         PB-TSE-UNDERLINED(L-INDEX)
     MOVE SPACES TO PB-TSE-COLOR(L-INDEX)
     MOVE PB-TEXT-LITERAL TO PB-TSE-KIND(L-INDEX)
     PERFORM WITH TEST AFTER UNTIL WS-TYPE = 0
         MOVE SPACES TO WS-NAME
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME-FIRST
             WS-NAME-CAPACITY WS-NAME-LENGTH
         EVALUATE TRUE
             WHEN WS-TYPE = 8 AND WS-NAME = "text"
                 MOVE 1 TO WS-HAS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER PB-TSE-VALUE(L-INDEX) WS-CAPACITY
                     PB-TSE-LENGTH(L-INDEX)
             WHEN WS-TYPE = 8 AND WS-NAME = "translate"
                 MOVE 1 TO WS-HAS-KEY
                 MOVE PB-TEXT-TRANSLATE TO PB-TSE-KIND(L-INDEX)
                 CALL "NBT-READ-STRING" USING PB-BUFFER PB-TSE-VALUE(L-INDEX) WS-CAPACITY
                     PB-TSE-LENGTH(L-INDEX)
             WHEN WS-TYPE = 8 AND WS-NAME = "color"
                 CALL "NBT-READ-STRING" USING PB-BUFFER PB-TSE-COLOR(L-INDEX)
                     WS-COLOR-CAPACITY WS-COLOR-LENGTH
             WHEN WS-TYPE = 1 AND WS-NAME = "italic"
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                 MOVE WS-BYTE TO PB-TSE-ITALIC(L-INDEX)
             WHEN WS-TYPE = 1 AND WS-NAME = "underlined"
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                 MOVE WS-BYTE TO PB-TSE-UNDERLINED(L-INDEX)
             WHEN WS-TYPE > 0
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WS-HAS-KEY = 0
         MOVE 1 TO PB-ERROR
     END-IF
     GOBACK.
 END PROGRAM PB-GET-EXTRA.


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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-SLOT-DISPLAY.
*> USING PB-BUFFER, PB-SLOT-DISPLAY: a 05b SlotDisplay of the types of PROTO.cpy: VarInt type, then
*> nothing (empty), the item id (item), or an ItemStackTemplate of item id, count and an empty
*> DataComponentPatch (item_stack, standin-content §2). Another type sets PB-ERROR and appends
*> nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-SLOT-DISPLAY.
     EVALUATE PB-SD-TYPE
         WHEN PB-SLOT-EMPTY
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-TYPE
         WHEN PB-SLOT-ITEM
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-TYPE
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-ITEM
         WHEN PB-SLOT-ITEM-STACK
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-TYPE
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-ITEM
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-SD-COUNT
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         WHEN OTHER
             MOVE 1 TO PB-ERROR
     END-EVALUATE
     GOBACK.
 END PROGRAM PB-PUT-SLOT-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-SLOT-DISPLAY.
*> USING PB-BUFFER, PB-SLOT-DISPLAY out: one 05b SlotDisplay; fields the type does not use are 0.
*> A type outside PROTO.cpy, an item_stack with data components or a short read sets PB-ERROR,
*> leaves PB-POS where it was and yields an all-zero display.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-SLOT-DISPLAY.
     MOVE PB-POS TO WS-START
     MOVE 0 TO PB-SD-ITEM PB-SD-COUNT
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-SD-TYPE
     EVALUATE PB-SD-TYPE
         WHEN PB-SLOT-EMPTY
             CONTINUE
         WHEN PB-SLOT-ITEM
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-SD-ITEM
         WHEN PB-SLOT-ITEM-STACK
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-SD-ITEM
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-SD-COUNT
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ADDED
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-REMOVED
             IF WS-ADDED NOT = 0 OR WS-REMOVED NOT = 0
                 MOVE 1 TO PB-ERROR
             END-IF
         WHEN OTHER
             MOVE 1 TO PB-ERROR
     END-EVALUATE
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO PB-SD-TYPE PB-SD-ITEM PB-SD-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-GET-SLOT-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-RECIPE-DISPLAY.
*> USING PB-BUFFER, PB-RECIPE-DISPLAY: a 05b RecipeDisplayEntry: VarInt display id; RecipeDisplay
*> (VarInt type; crafting_shaped adds VarInt width and height; Prefixed Array of SlotDisplay
*> ingredients; SlotDisplay result; SlotDisplay crafting station); OptionalVarInt group;
*> RegistryId category; Optional crafting requirements, each a HolderSet<item> of one item
*> (selector 2, then the item id; 09 profile). The entry flags byte of Recipe Book Add is the
*> caller's. A type other than crafting_shapeless or crafting_shaped, an ingredient or requirement
*> count outside 0 to PB-RECIPE-MAX-SLOTS, or a SlotDisplay type outside PROTO.cpy sets PB-ERROR and
*> appends nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-VALID               BINARY-LONG.
 01 WS-SLOT-TYPE           BINARY-LONG.
    88 WS-SLOT-SUPPORTED   VALUES 0 4 5.
 01 WS-SELECTOR            BINARY-LONG VALUE 2.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-RECIPE-DISPLAY.
     MOVE 1 TO WS-VALID
     IF (PB-RD-TYPE NOT = PB-RECIPE-SHAPELESS AND PB-RD-TYPE NOT = PB-RECIPE-SHAPED)
             OR PB-RD-INGREDIENT-COUNT < 0 OR PB-RD-INGREDIENT-COUNT > PB-RECIPE-MAX-SLOTS
             OR (PB-RD-REQ-PRESENT = 1
                 AND (PB-RD-REQ-COUNT < 0 OR PB-RD-REQ-COUNT > PB-RECIPE-MAX-SLOTS))
         MOVE 0 TO WS-VALID
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RD-INGREDIENT-COUNT + 2
             EVALUATE WS-I
                 WHEN PB-RD-INGREDIENT-COUNT + 1
                     MOVE PB-RD-RES-TYPE TO WS-SLOT-TYPE
                 WHEN PB-RD-INGREDIENT-COUNT + 2
                     MOVE PB-RD-ST-TYPE TO WS-SLOT-TYPE
                 WHEN OTHER
                     MOVE PB-RD-IN-TYPE(WS-I) TO WS-SLOT-TYPE
             END-EVALUATE
             IF NOT WS-SLOT-SUPPORTED
                 MOVE 0 TO WS-VALID
             END-IF
         END-PERFORM
     END-IF
     IF WS-VALID = 0
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-DISPLAY-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-TYPE
         IF PB-RD-TYPE = PB-RECIPE-SHAPED
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-WIDTH
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-HEIGHT
         END-IF
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-INGREDIENT-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RD-INGREDIENT-COUNT
             MOVE PB-RD-INGREDIENT(WS-I) TO WS-SLOT-DISPLAY
             CALL "PB-PUT-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
         END-PERFORM
         MOVE PB-RD-RESULT TO WS-SLOT-DISPLAY
         CALL "PB-PUT-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
         MOVE PB-RD-STATION TO WS-SLOT-DISPLAY
         CALL "PB-PUT-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-GROUP
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-CATEGORY
         MOVE PB-RD-REQ-PRESENT TO WS-FLAG
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
         IF PB-RD-REQ-PRESENT = 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-REQ-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RD-REQ-COUNT
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SELECTOR
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-RD-REQ-ITEM(WS-I)
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-RECIPE-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-RECIPE-DISPLAY.
*> USING PB-BUFFER, PB-RECIPE-DISPLAY out: one 05b RecipeDisplayEntry (layout as PB-PUT-RECIPE-
*> DISPLAY); fields the entry does not use are 0. A RecipeDisplay type other than crafting_shapeless
*> or crafting_shaped, an ingredient or requirement count outside 0 to PB-RECIPE-MAX-SLOTS, a
*> SlotDisplay PB-GET-SLOT-DISPLAY rejects, a requirement that is not a HolderSet of exactly one
*> item, or a short read sets PB-ERROR, leaves PB-POS where it was and yields an all-zero entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-START               BINARY-LONG.
 01 WS-SELECTOR            BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-RECIPE-DISPLAY.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-RECIPE-DISPLAY
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-DISPLAY-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-TYPE
     EVALUATE PB-RD-TYPE
         WHEN PB-RECIPE-SHAPELESS
             CONTINUE
         WHEN PB-RECIPE-SHAPED
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-WIDTH
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-HEIGHT
         WHEN OTHER
             MOVE 1 TO PB-ERROR
     END-EVALUATE
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-INGREDIENT-COUNT
     IF PB-RD-INGREDIENT-COUNT < 0 OR PB-RD-INGREDIENT-COUNT > PB-RECIPE-MAX-SLOTS
         MOVE 1 TO PB-ERROR
         MOVE 0 TO PB-RD-INGREDIENT-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RD-INGREDIENT-COUNT
         CALL "PB-GET-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
         MOVE WS-SLOT-DISPLAY TO PB-RD-INGREDIENT(WS-I)
     END-PERFORM
     CALL "PB-GET-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
     MOVE WS-SLOT-DISPLAY TO PB-RD-RESULT
     CALL "PB-GET-SLOT-DISPLAY" USING PB-BUFFER WS-SLOT-DISPLAY
     MOVE WS-SLOT-DISPLAY TO PB-RD-STATION
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-GROUP
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-CATEGORY
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
     MOVE WS-FLAG TO PB-RD-REQ-PRESENT
     IF WS-FLAG = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-REQ-COUNT
         IF PB-RD-REQ-COUNT < 0 OR PB-RD-REQ-COUNT > PB-RECIPE-MAX-SLOTS
             MOVE 1 TO PB-ERROR
             MOVE 0 TO PB-RD-REQ-COUNT
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-RD-REQ-COUNT
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-SELECTOR
             CALL "PB-GET-VARINT" USING PB-BUFFER PB-RD-REQ-ITEM(WS-I)
             IF WS-SELECTOR NOT = 2
                 MOVE 1 TO PB-ERROR
             END-IF
         END-PERFORM
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-RECIPE-DISPLAY
     END-IF
     GOBACK.
 END PROGRAM PB-GET-RECIPE-DISPLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-COMMAND-NODE.
*> USING PB-BUFFER, PB-COMMAND-NODE: one 05a 0x10 CommandNode: Byte flags; Prefixed Array of VarInt
*> children; VarInt redirect when flag 0x08 is set; for literal (type 1) and argument (type 2) nodes
*> the String name; for argument nodes the VarInt parser id, its properties (brigadier:double and
*> brigadier:integer a NumberRange: Byte flags, then the minimum and the maximum the flags announce;
*> brigadier:string a VarInt kind; game_profile none) and, when flag 0x10 is set, the Identifier
*> suggestions type. Types 0 and 3 have no stub. The node count and root index of the packet are
*> the caller's. Flags outside 0 to 255, a child count outside 0 to PB-NODE-MAX-CHILDREN, a name
*> longer than PB-CN-NAME, a parser outside PROTO.cpy, a string kind outside 0 to 2, range flags
*> outside 0 to 3 or an invalid or over-long suggestions type sets PB-ERROR and appends nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALID               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-REDIRECT            BINARY-LONG.
 01 WS-SUGGEST             BINARY-LONG.
 01 WS-HAS-MIN             BINARY-LONG.
 01 WS-HAS-MAX             BINARY-LONG.
 01 WS-MAX-NAME            BINARY-LONG VALUE 32767.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-COMMAND-NODE.
     MOVE 1 TO WS-VALID
     COMPUTE WS-TYPE = FUNCTION MOD(PB-CN-FLAGS, 4)
     DIVIDE PB-CN-FLAGS BY 8 GIVING WS-BITS
     COMPUTE WS-REDIRECT = FUNCTION MOD(WS-BITS, 2)
     DIVIDE PB-CN-FLAGS BY 16 GIVING WS-BITS
     COMPUTE WS-SUGGEST = FUNCTION MOD(WS-BITS, 2)
     DIVIDE PB-CN-RANGE-FLAGS BY 2 GIVING WS-HAS-MAX
     COMPUTE WS-HAS-MIN = FUNCTION MOD(PB-CN-RANGE-FLAGS, 2)
     IF PB-CN-FLAGS < 0 OR PB-CN-FLAGS > 255
             OR PB-CN-CHILD-COUNT < 0 OR PB-CN-CHILD-COUNT > PB-NODE-MAX-CHILDREN
         MOVE 0 TO WS-VALID
     END-IF
     IF (WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT)
             AND (PB-CN-NAME-LENGTH < 0 OR PB-CN-NAME-LENGTH > LENGTH OF PB-CN-NAME)
         MOVE 0 TO WS-VALID
     END-IF
     IF WS-TYPE = PB-NODE-ARGUMENT
         EVALUATE PB-CN-PARSER
             WHEN PB-PARSER-DOUBLE
             WHEN PB-PARSER-INTEGER
                 IF PB-CN-RANGE-FLAGS < 0 OR PB-CN-RANGE-FLAGS > 3
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN PB-PARSER-STRING
                 IF PB-CN-STRING-KIND < PB-STRING-SINGLE-WORD
                         OR PB-CN-STRING-KIND > PB-STRING-GREEDY
                     MOVE 0 TO WS-VALID
                 END-IF
             WHEN PB-PARSER-GAME-PROFILE
                 CONTINUE
             WHEN OTHER
                 MOVE 0 TO WS-VALID
         END-EVALUATE
         IF WS-SUGGEST = 1
             IF PB-CN-SUGGEST-LENGTH < 0 OR PB-CN-SUGGEST-LENGTH > LENGTH OF PB-CN-SUGGEST
                 MOVE 0 TO WS-VALID
             ELSE
                 CALL "PB-VALID-IDENTIFIER" USING PB-CN-SUGGEST PB-CN-SUGGEST-LENGTH WS-I
                 IF WS-I = 0
                     MOVE 0 TO WS-VALID
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WS-VALID = 0
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-CN-FLAGS
         CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CN-CHILD-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-CN-CHILD-COUNT
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CN-CHILD(WS-I)
         END-PERFORM
         IF WS-REDIRECT = 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CN-REDIRECT
         END-IF
         IF WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT
             CALL "PB-PUT-STRING" USING PB-BUFFER PB-CN-NAME PB-CN-NAME-LENGTH WS-MAX-NAME
         END-IF
         IF WS-TYPE = PB-NODE-ARGUMENT
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CN-PARSER
             EVALUATE PB-CN-PARSER
                 WHEN PB-PARSER-DOUBLE
                     CALL "PB-PUT-BYTE" USING PB-BUFFER PB-CN-RANGE-FLAGS
                     IF WS-HAS-MIN = 1
                         CALL "PB-PUT-DOUBLE" USING PB-BUFFER PB-CN-MIN-DOUBLE
                     END-IF
                     IF WS-HAS-MAX = 1
                         CALL "PB-PUT-DOUBLE" USING PB-BUFFER PB-CN-MAX-DOUBLE
                     END-IF
                 WHEN PB-PARSER-INTEGER
                     CALL "PB-PUT-BYTE" USING PB-BUFFER PB-CN-RANGE-FLAGS
                     IF WS-HAS-MIN = 1
                         CALL "PB-PUT-INT" USING PB-BUFFER PB-CN-MIN-INT
                     END-IF
                     IF WS-HAS-MAX = 1
                         CALL "PB-PUT-INT" USING PB-BUFFER PB-CN-MAX-INT
                     END-IF
                 WHEN PB-PARSER-STRING
                     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-CN-STRING-KIND
             END-EVALUATE
             IF WS-SUGGEST = 1
                 CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER PB-CN-SUGGEST PB-CN-SUGGEST-LENGTH
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-COMMAND-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-COMMAND-NODE.
*> USING PB-BUFFER, PB-COMMAND-NODE out: one 05a 0x10 CommandNode (layout as PB-PUT-COMMAND-NODE);
*> fields the node does not use are 0 (texts spaces). A child count outside 0 to
*> PB-NODE-MAX-CHILDREN, a name longer than PB-CN-NAME, a parser outside PROTO.cpy, a string kind
*> outside 0 to 2, range flags outside 0 to 3, an invalid or over-long suggestions type or a short
*> read sets PB-ERROR, leaves PB-POS where it was and yields an all-zero node.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-HAS-MIN             BINARY-LONG.
 01 WS-HAS-MAX             BINARY-LONG.
 01 WS-MAX-NAME            BINARY-LONG VALUE 32767.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-COMMAND-NODE.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-COMMAND-NODE
     CALL "PB-GET-UBYTE" USING PB-BUFFER PB-CN-FLAGS
     COMPUTE WS-TYPE = FUNCTION MOD(PB-CN-FLAGS, 4)
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-CN-CHILD-COUNT
     IF PB-CN-CHILD-COUNT < 0 OR PB-CN-CHILD-COUNT > PB-NODE-MAX-CHILDREN
         MOVE 1 TO PB-ERROR
         MOVE 0 TO PB-CN-CHILD-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-CN-CHILD-COUNT
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CN-CHILD(WS-I)
     END-PERFORM
     DIVIDE PB-CN-FLAGS BY 8 GIVING WS-BITS
     IF FUNCTION MOD(WS-BITS, 2) = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CN-REDIRECT
     END-IF
     IF WS-TYPE = PB-NODE-LITERAL OR WS-TYPE = PB-NODE-ARGUMENT
         MOVE LENGTH OF PB-CN-NAME TO WS-I
         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-NAME PB-CN-NAME WS-I PB-CN-NAME-LENGTH
     END-IF
     IF WS-TYPE = PB-NODE-ARGUMENT
         CALL "PB-GET-VARINT" USING PB-BUFFER PB-CN-PARSER
         EVALUATE PB-CN-PARSER
             WHEN PB-PARSER-DOUBLE
             WHEN PB-PARSER-INTEGER
                 CALL "PB-GET-UBYTE" USING PB-BUFFER PB-CN-RANGE-FLAGS
                 IF PB-CN-RANGE-FLAGS > 3
                     MOVE 1 TO PB-ERROR
                     MOVE 0 TO PB-CN-RANGE-FLAGS
                 END-IF
                 DIVIDE PB-CN-RANGE-FLAGS BY 2 GIVING WS-HAS-MAX
                 COMPUTE WS-HAS-MIN = FUNCTION MOD(PB-CN-RANGE-FLAGS, 2)
                 IF PB-CN-PARSER = PB-PARSER-DOUBLE
                     IF WS-HAS-MIN = 1
                         CALL "PB-GET-DOUBLE" USING PB-BUFFER PB-CN-MIN-DOUBLE
                     END-IF
                     IF WS-HAS-MAX = 1
                         CALL "PB-GET-DOUBLE" USING PB-BUFFER PB-CN-MAX-DOUBLE
                     END-IF
                 ELSE
                     IF WS-HAS-MIN = 1
                         CALL "PB-GET-INT" USING PB-BUFFER PB-CN-MIN-INT
                     END-IF
                     IF WS-HAS-MAX = 1
                         CALL "PB-GET-INT" USING PB-BUFFER PB-CN-MAX-INT
                     END-IF
                 END-IF
             WHEN PB-PARSER-STRING
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-CN-STRING-KIND
                 IF PB-CN-STRING-KIND < PB-STRING-SINGLE-WORD
                         OR PB-CN-STRING-KIND > PB-STRING-GREEDY
                     MOVE 1 TO PB-ERROR
                 END-IF
             WHEN PB-PARSER-GAME-PROFILE
                 CONTINUE
             WHEN OTHER
                 MOVE 1 TO PB-ERROR
         END-EVALUATE
         DIVIDE PB-CN-FLAGS BY 16 GIVING WS-BITS
         IF FUNCTION MOD(WS-BITS, 2) = 1
             MOVE LENGTH OF PB-CN-SUGGEST TO WS-I
             CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PB-CN-SUGGEST WS-I PB-CN-SUGGEST-LENGTH
         END-IF
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-COMMAND-NODE
     END-IF
     GOBACK.
 END PROGRAM PB-GET-COMMAND-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-BLOCK-DESTRUCTION.
*> USING PB-BUFFER, breaker entity id, x, y, z, stage (all BINARY-LONG): the body of Block
*> Destruction (05a 0x05, 13 2.4): VarInt entity id, Position, UByte stage. A stage of -1 is
*> written as 255 (the overlay is removed). A stage outside -1 to 255 appends nothing and sets
*> PB-ERROR. The packet id is the caller's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ENTITY L-X L-Y L-Z L-STAGE.
     IF L-STAGE < -1 OR L-STAGE > 255
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-STAGE
     GOBACK.
 END PROGRAM PB-PUT-BLOCK-DESTRUCTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-BLOCK-DESTRUCTION.
*> USING PB-BUFFER, entity id out, x, y, z out, stage out (BINARY-LONG, the UByte 0 to 255 as
*> read: 255 removes the overlay, as does any value above 9). A short read sets PB-ERROR, leaves
*> PB-POS where it was and yields zeros.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STAGE                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ENTITY L-X L-Y L-Z L-STAGE.
     MOVE PB-POS TO WS-START
     CALL "PB-GET-VARINT" USING PB-BUFFER L-ENTITY
     CALL "PB-GET-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-GET-UBYTE" USING PB-BUFFER L-STAGE
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-ENTITY L-X L-Y L-Z L-STAGE
     END-IF
     GOBACK.
 END PROGRAM PB-GET-BLOCK-DESTRUCTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-PLAYER-ACTION.
*> USING PB-BUFFER, status, x, y, z, face, sequence (all BINARY-LONG): the body of Player Action
*> (05c 0x29, 13 2.3): VarInt status, Position, UByte face, VarInt sequence. A status outside
*> 0 to 8, a face outside 0 to 5 or a negative sequence appends nothing and sets PB-ERROR.
*> The packet id is the caller's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-STATUS               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-STATUS L-X L-Y L-Z L-FACE L-SEQUENCE.
     IF L-STATUS < 0 OR L-STATUS > 8 OR L-FACE < 0 OR L-FACE > 5 OR L-SEQUENCE < 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATUS
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-FACE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     GOBACK.
 END PROGRAM PB-PUT-PLAYER-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-PLAYER-ACTION.
*> USING PB-BUFFER, status out, x, y, z out, face out, sequence out (BINARY-LONG; the face is the
*> UByte as read, 05c says the receiver takes its absolute value modulo 6). A status outside 0 to 8,
*> a negative sequence or a short read sets PB-ERROR, leaves PB-POS where it was and yields zeros.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-STATUS               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-STATUS L-X L-Y L-Z L-FACE L-SEQUENCE.
     MOVE PB-POS TO WS-START
     CALL "PB-GET-VARINT" USING PB-BUFFER L-STATUS
     CALL "PB-GET-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-GET-UBYTE" USING PB-BUFFER L-FACE
     CALL "PB-GET-VARINT" USING PB-BUFFER L-SEQUENCE
     IF L-STATUS < 0 OR L-STATUS > 8 OR L-SEQUENCE < 0
         MOVE 1 TO PB-ERROR
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-STATUS L-X L-Y L-Z L-FACE L-SEQUENCE
     END-IF
     GOBACK.
 END PROGRAM PB-GET-PLAYER-ACTION.
