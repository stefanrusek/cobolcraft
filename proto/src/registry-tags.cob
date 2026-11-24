*> Configuration packets of the standard world (docs/protocol/04-registry-sync.md): Registry Data
*> (configuration 0x07: registry Identifier, then a Prefixed Array of entries, each an Identifier,
*> a Boolean and, when true, one network NBT tag) and Update Tags (configuration 0x0E, play 0x89:
*> Prefixed Array of registries, each a registry Identifier and a Prefixed Array of tags, each a tag
*> Identifier and a Prefixed Array of VarInt ids). The packet id is the caller's. The HEAD programs
*> carry a registry key and a count, then the caller writes or reads that many entries or tags.
*> Entry data is the network NBT tag's bytes exactly as they go on the wire (type byte first, no
*> name): the writer checks they are one complete tag of type 1 to 12 and nothing more, the reader
*> finds the end of the tag and copies those bytes. A writer appends nothing and sets PB-ERROR for a
*> value it cannot encode; a reader that fails sets PB-ERROR, leaves PB-POS where it was and yields
*> zero lengths and counts.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-REGISTRY-DATA-HEAD.
*> USING PB-BUFFER, registry key (area), key byte length (BINARY-LONG), entry count (BINARY-LONG):
*> Identifier and VarInt count. An invalid key or a negative count is an error.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-REGISTRY             PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-REGISTRY L-LENGTH L-COUNT.
     IF L-COUNT < 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER L-REGISTRY L-LENGTH
     IF PB-ERROR = 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-REGISTRY-DATA-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-REGISTRY-DATA-HEAD.
*> USING PB-BUFFER, registry key out (area), capacity (BINARY-LONG bytes), key length out, entry
*> count out (BINARY-LONG). An invalid key, a key above the capacity, a negative count or a short
*> read is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-REGISTRY             PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-REGISTRY L-CAPACITY L-LENGTH L-COUNT.
     MOVE PB-POS TO WS-START
     MOVE 0 TO L-COUNT
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER L-REGISTRY L-CAPACITY L-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT < 0
         MOVE 1 TO PB-ERROR
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-LENGTH L-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-GET-REGISTRY-DATA-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-REGISTRY-ENTRY.
*> USING PB-BUFFER, entry key (area), key byte length, present (BINARY-LONG 0 or 1), data (area of
*> network NBT tag bytes), data byte length (BINARY-LONG): Identifier, Boolean and the data bytes
*> when present. Present needs a length of at least 1 and exactly one complete tag of a type from 1
*> to 12; any other present flag, an invalid key or a bad tag is an error. With present 0 the data
*> area and length are not looked at.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-START               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   PIC X.
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-DATA                 PIC X.
 01 L-DATA-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID L-ID-LENGTH L-PRESENT L-DATA L-DATA-LENGTH.
     MOVE PB-LENGTH TO WS-START
     IF L-PRESENT NOT = 0 AND L-PRESENT NOT = 1
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     IF L-PRESENT = 1
         IF L-DATA-LENGTH < 1
             MOVE 1 TO PB-ERROR
             GOBACK
         END-IF
         MOVE L-DATA-LENGTH TO WS-CAPACITY
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         CALL "PB-APPEND-BYTES" USING WK-BUFFER L-DATA L-DATA-LENGTH
         MOVE 0 TO WS-LENGTH
         CALL "REGISTRY-NBT-TAG" USING WK-BUFFER WS-LENGTH
         IF WK-ERROR = 1 OR WS-LENGTH NOT = L-DATA-LENGTH
             MOVE 1 TO PB-ERROR
         END-IF
         CALL "PB-FREE" USING WK-BUFFER
         IF PB-ERROR = 1
             GOBACK
         END-IF
     END-IF
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER L-ID L-ID-LENGTH
     IF PB-ERROR = 1
         MOVE WS-START TO PB-LENGTH
         GOBACK
     END-IF
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-PRESENT
     IF L-PRESENT = 1
         CALL "PB-APPEND-BYTES" USING PB-BUFFER L-DATA L-DATA-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-REGISTRY-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-REGISTRY-ENTRY.
*> USING PB-BUFFER, key out (area), key capacity (BINARY-LONG bytes), key length out, present out
*> (BINARY-LONG 0 or 1), data out (area), data capacity (BINARY-LONG bytes), data length out: reads
*> the entry. Present data is one network NBT tag of type 1 to 12; its bytes are copied whole.
*> An invalid key, a key or a tag above its capacity, a tag that is End, malformed or cut short, or a
*> short read is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-DATA-START          BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   PIC X.
 01 L-ID-CAPACITY          BINARY-LONG.
 01 L-ID-LENGTH            BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-DATA                 PIC X.
 01 L-DATA-CAPACITY        BINARY-LONG.
 01 L-DATA-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID L-ID-CAPACITY L-ID-LENGTH L-PRESENT L-DATA
         L-DATA-CAPACITY L-DATA-LENGTH.
     MOVE PB-POS TO WS-START
     MOVE 0 TO L-DATA-LENGTH
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER L-ID L-ID-CAPACITY L-ID-LENGTH
     CALL "PB-GET-BOOL" USING PB-BUFFER L-PRESENT
     IF PB-ERROR = 0 AND L-PRESENT = 1
         MOVE PB-POS TO WS-DATA-START
         MOVE 0 TO WS-LENGTH
         CALL "REGISTRY-NBT-TAG" USING PB-BUFFER WS-LENGTH
         IF PB-ERROR = 0 AND WS-LENGTH > L-DATA-CAPACITY
             MOVE 1 TO PB-ERROR
         END-IF
         IF PB-ERROR = 0
             MOVE WS-DATA-START TO PB-POS
             CALL "PB-GET-BYTES" USING PB-BUFFER L-DATA WS-LENGTH
             MOVE WS-LENGTH TO L-DATA-LENGTH
         END-IF
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-ID-LENGTH L-PRESENT L-DATA-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PB-GET-REGISTRY-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-NBT-TAG.
*> USING PB-BUFFER, length out (BINARY-LONG): skips one network NBT tag at PB-POS (type byte and
*> payload, no name) and gives its byte length. A root of type End (0) or above 12, or a payload
*> NBT-READ-SKIP rejects: PB-ERROR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-LENGTH.
     MOVE PB-POS TO WS-START
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     IF PB-ERROR = 0 AND WS-TYPE = 0
         MOVE 1 TO PB-ERROR
     END-IF
     IF PB-ERROR = 0
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
     END-IF
     COMPUTE L-LENGTH = PB-POS - WS-START
     GOBACK.
 END PROGRAM REGISTRY-NBT-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-TAGS-HEAD.
*> USING PB-BUFFER, registry count (BINARY-LONG): VarInt. A negative count is an error.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-COUNT.
     IF L-COUNT < 0
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-PUT-TAGS-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-TAGS-HEAD.
*> USING PB-BUFFER, registry count out (BINARY-LONG). A negative count or a short read is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-COUNT.
     MOVE PB-POS TO WS-START
     CALL "PB-GET-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT < 0
         MOVE 1 TO PB-ERROR
     END-IF
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-GET-TAGS-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-TAG-REGISTRY-HEAD.
*> USING PB-BUFFER, registry key (area), key byte length, tag count (BINARY-LONG): Identifier and
*> VarInt count, the form of the Registry Data head.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-REGISTRY             PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-REGISTRY L-LENGTH L-COUNT.
     CALL "PB-PUT-REGISTRY-DATA-HEAD" USING PB-BUFFER L-REGISTRY L-LENGTH L-COUNT
     GOBACK.
 END PROGRAM PB-PUT-TAG-REGISTRY-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-TAG-REGISTRY-HEAD.
*> USING PB-BUFFER, registry key out (area), capacity (BINARY-LONG bytes), key length out, tag count
*> out (BINARY-LONG), failing as PB-GET-REGISTRY-DATA-HEAD does.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-REGISTRY             PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-REGISTRY L-CAPACITY L-LENGTH L-COUNT.
     CALL "PB-GET-REGISTRY-DATA-HEAD" USING PB-BUFFER L-REGISTRY L-CAPACITY L-LENGTH L-COUNT
     GOBACK.
 END PROGRAM PB-GET-TAG-REGISTRY-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-PUT-TAG.
*> USING PB-BUFFER, tag name (area), name byte length, ids (a table of BINARY-LONG), id count
*> (BINARY-LONG): Identifier, VarInt count and the ids as VarInts. An invalid name, a negative count or
*> a negative id is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 B-IDS-AREA BASED.
    05 B-ID                BINARY-LONG OCCURS 16777216 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-IDS                  PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-LENGTH L-IDS L-COUNT.
     MOVE PB-LENGTH TO WS-START
     SET ADDRESS OF B-IDS-AREA TO ADDRESS OF L-IDS
     MOVE 1 TO WS-VALID
     IF L-COUNT < 0
         MOVE 0 TO WS-VALID
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             IF B-ID(WS-I) < 0
                 MOVE 0 TO WS-VALID
             END-IF
         END-PERFORM
     END-IF
     IF WS-VALID = 0
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER L-NAME L-LENGTH
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "PB-PUT-VARINT" USING PB-BUFFER B-ID(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM PB-PUT-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-GET-TAG.
*> USING PB-BUFFER, tag name out (area), name capacity (BINARY-LONG bytes), name length out, ids out
*> (a table of BINARY-LONG), id capacity (BINARY-LONG entries), id count out. An invalid name, a name
*> above the capacity, a negative count, a count above the id capacity, a negative id or a short read
*> is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 B-IDS-AREA BASED.
    05 B-ID                BINARY-LONG OCCURS 16777216 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X.
 01 L-NAME-CAPACITY        BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-IDS                  PIC X.
 01 L-ID-CAPACITY          BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-NAME-CAPACITY L-LENGTH L-IDS L-ID-CAPACITY L-COUNT.
     MOVE PB-POS TO WS-START
     SET ADDRESS OF B-IDS-AREA TO ADDRESS OF L-IDS
     MOVE 0 TO L-COUNT
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER L-NAME L-NAME-CAPACITY L-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT < 0 OR L-COUNT > L-ID-CAPACITY
         MOVE 1 TO PB-ERROR
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER B-ID(WS-I)
         IF B-ID(WS-I) < 0
             MOVE 1 TO PB-ERROR
         END-IF
     END-PERFORM
     IF PB-ERROR = 1
         MOVE WS-START TO PB-POS
         MOVE 0 TO L-LENGTH L-COUNT
     END-IF
     GOBACK.
 END PROGRAM PB-GET-TAG.
