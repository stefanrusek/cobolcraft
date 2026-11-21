*> Entity metadata entry codecs (docs/protocol 00 §13 and 46 §12): one entry of a Set Entity Data
*> list (05b 0x65) for each of the 44 serializers of 00 §13.2, in the record PB-METADATA-ENTRY-X of
*> contract/copy/PROTO.cpy (the fields each serializer uses are listed there). The entity id and the
*> packet id are the caller's; a list ends with the entry whose index is PB-MD-END.
*> A writer appends nothing and sets PB-ERROR for an entry it cannot encode; a reader that fails
*> sets PB-ERROR, leaves PB-POS where it was and yields an all-zero entry.
*> The values of COMPONENT, OPTIONAL_COMPONENT, PARTICLE, PARTICLES, OPTIONAL_GLOBAL_POS,
*> PAINTING_VARIANT and RESOLVABLE_PROFILE are kept as their wire bytes in PB-MX-DATA (at most 512).
*> For the two optional forms PB-MX-PRESENT holds the Boolean and PB-MX-DATA only the value behind
*> it (empty when absent). Both directions check that the bytes are exactly one well-formed value.
*> Limits of the record: a STRING value holds at most 256 bytes; a PAINTING_VARIANT holds only the
*> registry reference (the inline form, whose layout the documents do not give, is an error).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-MX-SKIP-STRING.
*> USING PB-BUFFER, maximum length N in characters (BINARY-LONG): skips one String(N) of 00 §3.1,
*> checking the byte length (not negative, at most 3 x N, within the data). The text itself is not
*> decoded. Anything else sets PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-MAX.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-LENGTH
     COMPUTE WS-LIMIT = 3 * L-MAX
     IF PB-ERROR = 1 OR WS-LENGTH < 0 OR WS-LENGTH > WS-LIMIT
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-SKIP" USING PB-BUFFER WS-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-MX-SKIP-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-MX-SCAN.
*> USING PB-BUFFER, serializer (BINARY-LONG): reads one value of a serializer whose bytes the entry
*> keeps verbatim, moving PB-POS past it; a malformed or cut-short value sets PB-ERROR (PB-POS is
*> then not restored). Serializer 6 and 33 are read as 5 and as a GlobalPos: their Boolean is the
*> caller's. Components are a network NBT root of a String or a Compound (00 §9.1); a PARTICLE is
*> a type and its options (PB-GET-PARTICLE); a GlobalPos is an Identifier and a Position; a
*> PAINTING_VARIANT is the Holder selector (n > 0 is a registry reference); a RESOLVABLE_PROFILE
*> is the Either of 00 §13.3 with the property map of 00 §11.2 and the four skin patch options.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NETWORK             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DATA                PIC X(64).
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-UUID                PIC X(16).
 01 WS-MAX-NAME            BINARY-LONG VALUE 16.
 01 WS-MAX-KEY             BINARY-LONG VALUE 64.
 01 WS-MAX-VALUE           BINARY-LONG VALUE 32767.
 01 WS-MAX-SIGNATURE       BINARY-LONG VALUE 1024.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SERIALIZER           BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SERIALIZER.
     EVALUATE L-SERIALIZER
         WHEN 5
         WHEN 6
             CALL "NBT-READ-ROOT" USING PB-BUFFER WS-NETWORK WS-TYPE
             IF PB-ERROR = 0 AND WS-TYPE NOT = 8 AND WS-TYPE NOT = 10
                 MOVE 1 TO PB-ERROR
             END-IF
             IF PB-ERROR = 0
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-IF
         WHEN 16
             CALL "PB-GET-PARTICLE" USING PB-BUFFER WS-TYPE WS-LENGTH WS-DATA
         WHEN 17
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             IF WS-COUNT < 0
                 MOVE 1 TO PB-ERROR
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "PB-GET-PARTICLE" USING PB-BUFFER WS-TYPE WS-LENGTH WS-DATA
             END-PERFORM
         WHEN 33
             CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-TEXT WS-CAPACITY WS-LENGTH
             CALL "PB-GET-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
         WHEN 34
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             IF WS-COUNT <= 0
                 MOVE 1 TO PB-ERROR
             END-IF
         WHEN 41
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
             IF WS-FLAG = 1
                 CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
                 CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-NAME
             ELSE
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
                 IF WS-FLAG = 1
                     CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-NAME
                 END-IF
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
                 IF WS-FLAG = 1
                     CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
                 END-IF
             END-IF
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
             IF WS-COUNT < 0 OR WS-COUNT > 16
                 MOVE 1 TO PB-ERROR
             END-IF
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-KEY
                 CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-VALUE
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
                 IF WS-FLAG = 1
                     CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-SIGNATURE
                 END-IF
             END-PERFORM
*>           the skin patch: three optional Identifiers, then an optional Boolean
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
                 IF WS-FLAG = 1
                     CALL "PB-MX-SKIP-STRING" USING PB-BUFFER WS-MAX-VALUE
                 END-IF
             END-PERFORM
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
             IF WS-FLAG = 1
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-FLAG
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PB-MX-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-METADATA-ENTRY-X.
*> USING PB-BUFFER, PB-METADATA-ENTRY-X: UByte index, VarInt serializer and the value, or the single
*> byte 0xFF when PB-MX-INDEX is PB-MD-END. An index outside 0 to 254, a serializer outside 0 to 43,
*> a value out of range (BYTE outside -128 to 127, a Boolean or presence flag other than 0 or 1,
*> a negative id, a STRING longer than 256 bytes, bytes that are not exactly one value of the kind)
*> sets PB-ERROR and appends nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-START               BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-MAX-STRING          BINARY-LONG VALUE 32767.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-METADATA-ENTRY-X.
     MOVE PB-LENGTH TO WS-START
     EVALUATE TRUE
         WHEN PB-MX-INDEX = PB-MD-END
             CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-MX-INDEX
             GOBACK
         WHEN PB-MX-INDEX < 0 OR PB-MX-INDEX > 254
                 OR PB-MX-SERIALIZER < 0 OR PB-MX-SERIALIZER > 43
             MOVE 1 TO PB-ERROR
             GOBACK
     END-EVALUATE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER PB-MX-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-SERIALIZER
     MOVE PB-MX-PRESENT TO WS-PRESENT
     EVALUATE PB-MX-SERIALIZER
         WHEN 0
             IF PB-MX-INT < -128 OR PB-MX-INT > 127
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-BYTE" USING PB-BUFFER PB-MX-INT
             END-IF
         WHEN 1
             CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-INT
         WHEN 2
             CALL "PB-PUT-VARLONG" USING PB-BUFFER PB-MX-LONG
         WHEN 3
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
         WHEN 4
             IF PB-MX-TEXT-LENGTH < 0 OR PB-MX-TEXT-LENGTH > 256
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-STRING" USING PB-BUFFER PB-MX-TEXT PB-MX-TEXT-LENGTH
                     WS-MAX-STRING
             END-IF
         WHEN 5
         WHEN 6
         WHEN 16
         WHEN 17
         WHEN 33
         WHEN 34
         WHEN 41
*>           a value kept as bytes: the optional forms put their Boolean first
             IF PB-MX-SERIALIZER = 6 OR PB-MX-SERIALIZER = 33
                 IF WS-PRESENT NOT = 0 AND WS-PRESENT NOT = 1
                     MOVE 1 TO PB-ERROR
                 ELSE
                     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-PRESENT
                 END-IF
             ELSE
                 MOVE 1 TO WS-PRESENT
             END-IF
             EVALUATE TRUE
                 WHEN PB-ERROR = 1
                     CONTINUE
                 WHEN PB-MX-DATA-LENGTH < 0 OR PB-MX-DATA-LENGTH > PB-MX-DATA-MAX
                     MOVE 1 TO PB-ERROR
                 WHEN WS-PRESENT = 0
                     IF PB-MX-DATA-LENGTH NOT = 0
                         MOVE 1 TO PB-ERROR
                     END-IF
                 WHEN OTHER
*>                   the bytes must be exactly one value: read them through a buffer over the field
                     SET WS-ADDR TO ADDRESS OF PB-MX-DATA
                     MOVE PB-MX-DATA-MAX TO WS-CAPACITY
                     MOVE PB-MX-DATA-LENGTH TO WS-LENGTH
                     MOVE 0 TO WS-POS WS-ERROR
                     CALL "PB-MX-SCAN" USING WS-BUFFER PB-MX-SERIALIZER
                     IF WS-ERROR = 1 OR WS-POS NOT = PB-MX-DATA-LENGTH
                         MOVE 1 TO PB-ERROR
                     ELSE
                         CALL "PB-APPEND-BYTES" USING PB-BUFFER PB-MX-DATA PB-MX-DATA-LENGTH
                     END-IF
             END-EVALUATE
         WHEN 7
             MOVE PB-MX-IS-COUNT TO WS-IS-COUNT
             MOVE PB-MX-IS-ITEM TO WS-IS-ITEM
             CALL "PB-PUT-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
         WHEN 8
             IF PB-MX-INT NOT = 0 AND PB-MX-INT NOT = 1
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-BOOL" USING PB-BUFFER PB-MX-INT
             END-IF
         WHEN 9
         WHEN 39
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(2)
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(3)
         WHEN 40
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(2)
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(3)
             CALL "PB-PUT-FLOAT" USING PB-BUFFER PB-MX-FLOAT(4)
         WHEN 10
             CALL "PB-PUT-POSITION" USING PB-BUFFER PB-MX-POS-X PB-MX-POS-Y PB-MX-POS-Z
         WHEN 11
             IF WS-PRESENT NOT = 0 AND WS-PRESENT NOT = 1
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-BOOL" USING PB-BUFFER WS-PRESENT
                 IF WS-PRESENT = 1
                     CALL "PB-PUT-POSITION" USING PB-BUFFER PB-MX-POS-X PB-MX-POS-Y
                         PB-MX-POS-Z
                 END-IF
             END-IF
         WHEN 13
             IF WS-PRESENT NOT = 0 AND WS-PRESENT NOT = 1
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-BOOL" USING PB-BUFFER WS-PRESENT
                 IF WS-PRESENT = 1
                     CALL "PB-PUT-UUID" USING PB-BUFFER PB-MX-UUID
                 END-IF
             END-IF
         WHEN 18
             IF PB-MX-INT < 0 OR PB-MX-INT-2 < 0 OR PB-MX-INT-3 < 0
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-INT
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-INT-2
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-INT-3
             END-IF
         WHEN OTHER
*>           an id of a registry or of an IdEnum, or OPTIONAL_UNSIGNED_INT's raw VarInt
             IF PB-MX-INT < 0
                 MOVE 1 TO PB-ERROR
             ELSE
                 CALL "PB-PUT-VARINT" USING PB-BUFFER PB-MX-INT
             END-IF
     END-EVALUATE
     IF PB-ERROR = 1
         MOVE WS-START TO PB-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-METADATA-ENTRY-X.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-METADATA-ENTRY-X.
*> USING PB-BUFFER, PB-METADATA-ENTRY-X out: one entry; PB-MX-INDEX = PB-MD-END for the terminator
*> (nothing else read). Fields the serializer does not use are 0. A serializer outside 0 to 43, a
*> negative id, a short read, a value that is not well formed or longer than the 512 bytes of
*> PB-MX-DATA, a STRING of more than 256 bytes, or a stack with data components sets PB-ERROR,
*> leaves PB-POS where it was and yields an all-zero entry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WS-==.
 01 WS-START               BINARY-LONG.
 01 WS-VALUE-START         BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-MAX-STRING          BINARY-LONG VALUE 32767.
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER PB-METADATA-ENTRY-X.
     MOVE PB-POS TO WS-START
     INITIALIZE PB-METADATA-ENTRY-X
     CALL "PB-GET-UBYTE" USING PB-BUFFER PB-MX-INDEX
     IF PB-MX-INDEX = PB-MD-END
         GOBACK
     END-IF
     CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-SERIALIZER
     IF PB-MX-SERIALIZER < 0 OR PB-MX-SERIALIZER > 43
         MOVE 1 TO PB-ERROR
     END-IF
     IF PB-ERROR = 0
         EVALUATE PB-MX-SERIALIZER
             WHEN 0
                 CALL "PB-GET-BYTE" USING PB-BUFFER PB-MX-INT
             WHEN 1
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-INT
             WHEN 2
                 CALL "PB-GET-VARLONG" USING PB-BUFFER PB-MX-LONG
             WHEN 3
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
             WHEN 4
                 CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-STRING PB-MX-TEXT
                     WS-TEXT-CAPACITY PB-MX-TEXT-LENGTH
             WHEN 5
             WHEN 6
             WHEN 16
             WHEN 17
             WHEN 33
             WHEN 34
             WHEN 41
*>               a value kept as bytes: the optional forms start with their Boolean
                 MOVE 1 TO WS-PRESENT
                 IF PB-MX-SERIALIZER = 6 OR PB-MX-SERIALIZER = 33
                     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
                     MOVE WS-PRESENT TO PB-MX-PRESENT
                 END-IF
                 IF WS-PRESENT = 1
                     MOVE PB-POS TO WS-VALUE-START
                     CALL "PB-MX-SCAN" USING PB-BUFFER PB-MX-SERIALIZER
                     COMPUTE WS-VALUE-LENGTH = PB-POS - WS-VALUE-START
                     IF WS-VALUE-LENGTH > PB-MX-DATA-MAX
                         MOVE 1 TO PB-ERROR
                     END-IF
                     IF PB-ERROR = 0
                         MOVE WS-VALUE-START TO PB-POS
                         CALL "PB-GET-BYTES" USING PB-BUFFER PB-MX-DATA WS-VALUE-LENGTH
                         MOVE WS-VALUE-LENGTH TO PB-MX-DATA-LENGTH
                     END-IF
                 END-IF
             WHEN 7
                 CALL "PB-GET-ITEMSTACK" USING PB-BUFFER WS-ITEMSTACK
                 MOVE WS-IS-COUNT TO PB-MX-IS-COUNT
                 MOVE WS-IS-ITEM TO PB-MX-IS-ITEM
             WHEN 8
                 CALL "PB-GET-BOOL" USING PB-BUFFER PB-MX-INT
             WHEN 9
             WHEN 39
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(2)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(3)
             WHEN 40
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(1)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(2)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(3)
                 CALL "PB-GET-FLOAT" USING PB-BUFFER PB-MX-FLOAT(4)
             WHEN 10
                 CALL "PB-GET-POSITION" USING PB-BUFFER PB-MX-POS-X PB-MX-POS-Y PB-MX-POS-Z
             WHEN 11
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
                 MOVE WS-PRESENT TO PB-MX-PRESENT
                 IF WS-PRESENT = 1
                     CALL "PB-GET-POSITION" USING PB-BUFFER PB-MX-POS-X PB-MX-POS-Y
                         PB-MX-POS-Z
                 END-IF
             WHEN 13
                 CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
                 MOVE WS-PRESENT TO PB-MX-PRESENT
                 IF WS-PRESENT = 1
                     CALL "PB-GET-UUID" USING PB-BUFFER PB-MX-UUID
                 END-IF
             WHEN 18
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-INT
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-INT-2
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-INT-3
                 IF PB-MX-INT < 0 OR PB-MX-INT-2 < 0 OR PB-MX-INT-3 < 0
                     MOVE 1 TO PB-ERROR
                 END-IF
             WHEN OTHER
                 CALL "PB-GET-VARINT" USING PB-BUFFER PB-MX-INT
                 IF PB-MX-INT < 0
                     MOVE 1 TO PB-ERROR
                 END-IF
         END-EVALUATE
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         INITIALIZE PB-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM PB-GET-METADATA-ENTRY-X.
