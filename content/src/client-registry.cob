*> The client's registry load from the network (content-api section 2; docs/protocol/04-registry-sync.md sections 1 to 4, 23 section 4 and
*> 6.6; world-types WT-16). CONTENT-CLIENT-REGISTRY-ADD takes the body of a Registry Data (configuration id 7)
*> or an Update Tags packet (id 14 or play id 137 shaped the same) and CONTENT-CLIENT-FINISH decides the world
*> type at Finish Configuration. The first packet opens an empty set; registries and tags go into the same
*> structures a standard set loaded from files uses (CTSTORE.cpy), so CONTENT-REGISTRY-COUNT,
*> CONTENT-REGISTRY-ENTRY, CONTENT-TAG-HAS and CONTENT-TAG-MEMBERS serve both. Entries are registered in
*> received order (ids are received indices, 04 section 4). Every entry carries Data: this client has no
*> known packs (04 section 2), so a Data-less entry fails like a missing resource. A packet that fails keeps
*> nothing. Not done here: the codec decode of entries (the payload is the NBT bytes) and the 13
*> non-empty validators of 04 section 3.2 (the caller decides what a client needs to play).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-CLIENT-REGISTRY-ADD.
*> USING packet id (BINARY-LONG: 7 Registry Data, 14 Update Tags), body (area: the bytes after the packet id),
*> body length (BINARY-LONG), status out (CT-OK, CT-BAD-DATA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-BODY                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKET-ID L-BODY L-LENGTH L-STATUS.
     IF L-PACKET-ID NOT = 7 AND L-PACKET-ID NOT = 14
         DISPLAY "ERROR registry: a client set takes packet 7 or 14, not " L-PACKET-ID UPON SYSERR
         MOVE CT-BAD-DATA TO L-STATUS
         GOBACK
     END-IF
     IF CT-OPEN = 0
         MOVE 1 TO CT-OPEN
         MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     END-IF
     IF L-PACKET-ID = 7
         CALL "CLIENT-REGISTRY-DATA" USING L-BODY L-LENGTH L-STATUS
     ELSE
         CALL "CLIENT-UPDATE-TAGS" USING L-BODY L-LENGTH L-STATUS
     END-IF
     GOBACK.
 END PROGRAM CONTENT-CLIENT-REGISTRY-ADD.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIENT-REGISTRY-DATA.
*> USING body (area), length, status out: one Registry Data packet. The new entries and payload are built
*> beside the old ones and swapped in only when the whole packet has read cleanly.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY PROTO.
 01 B-OLD-BYTES            PIC X(268435456) BASED.
 01 B-NEW-BYTES            PIC X(268435456) BASED.
 01 B-OLD-PAYLOAD          PIC X(268435456) BASED.
 01 B-NEW-PAYLOAD          PIC X(268435456) BASED.
 01 WS-DATA                PIC X(2097152).
 01 WS-DATA-CAPACITY       BINARY-LONG VALUE 2097152.
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 112.
 01 WS-REGISTRY            PIC X(112).
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD-COUNT           BINARY-LONG.
 01 WS-OLD-LENGTH          BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PAYLOAD-SIZE        BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-ENTRY-SIZE          BINARY-LONG.
 01 WS-NEW-ENTRIES         USAGE POINTER.
 01 WS-NEW-DATA            USAGE POINTER.
 01 WS-OLD-ENTRIES         USAGE POINTER.
 01 WS-OLD-DATA            USAGE POINTER.
 01 WS-TABLE               USAGE POINTER.
 01 WS-FAIL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BODY                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BODY L-LENGTH L-STATUS.
     MOVE CT-BAD-DATA TO L-STATUS
     COMPUTE WS-CAPACITY = L-LENGTH + 16
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-APPEND-BYTES" USING PB-BUFFER L-BODY L-LENGTH
     MOVE SPACES TO WS-REGISTRY
     CALL "PB-GET-REGISTRY-DATA-HEAD" USING PB-BUFFER WS-REGISTRY WS-KEY-CAPACITY WS-REGISTRY-LENGTH WS-COUNT
     IF PB-ERROR = 1
         DISPLAY "ERROR registry: Registry Data does not decode" UPON SYSERR
         CALL "PB-FREE" USING PB-BUFFER
         GOBACK
     END-IF
*>   An earlier packet of the same registry gives the entries this one is appended to.
     MOVE 0 TO WS-ROW WS-OLD-COUNT WS-OLD-LENGTH
     SET WS-OLD-ENTRIES TO NULL
     SET WS-OLD-DATA TO NULL
     IF CT-REGISTRY-ADDR NOT = NULL
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR WS-ROW > 0
             IF BR-KEY(WS-I) = WS-REGISTRY
                 MOVE WS-I TO WS-ROW
             END-IF
         END-PERFORM
     END-IF
     IF WS-ROW > 0
         MOVE BR-ENTRY-COUNT(WS-ROW) TO WS-OLD-COUNT
         MOVE BR-PAYLOAD-LENGTH(WS-ROW) TO WS-OLD-LENGTH
         SET WS-OLD-ENTRIES TO BR-ENTRY-ADDR(WS-ROW)
         SET WS-OLD-DATA TO BR-PAYLOAD-ADDR(WS-ROW)
     ELSE
         IF CT-REGISTRY-COUNT >= CT-MAX-REGISTRIES
             DISPLAY "ERROR registry: more than 64 registries" UPON SYSERR
             CALL "PB-FREE" USING PB-BUFFER
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-TOTAL = WS-OLD-COUNT + WS-COUNT
     COMPUTE WS-ENTRY-SIZE = LENGTH OF BE-ROW(1)
     COMPUTE WS-CAPACITY = WS-TOTAL * WS-ENTRY-SIZE + 1
     ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-NEW-ENTRIES
     COMPUTE WS-PAYLOAD-SIZE = WS-OLD-LENGTH + PB-LENGTH - PB-POS + 1
     ALLOCATE WS-PAYLOAD-SIZE CHARACTERS RETURNING WS-NEW-DATA
     SET ADDRESS OF B-ENTRIES TO WS-NEW-ENTRIES
     SET ADDRESS OF B-NEW-BYTES TO WS-NEW-ENTRIES
     SET ADDRESS OF B-NEW-PAYLOAD TO WS-NEW-DATA
*>   The old entries and payload move into the new buffers unchanged (their offsets stay valid).
     IF WS-OLD-COUNT > 0
         SET ADDRESS OF B-OLD-BYTES TO WS-OLD-ENTRIES
         SET ADDRESS OF B-OLD-PAYLOAD TO WS-OLD-DATA
         COMPUTE WS-CAPACITY = WS-OLD-COUNT * WS-ENTRY-SIZE
         MOVE B-OLD-BYTES(1:WS-CAPACITY) TO B-NEW-BYTES(1:WS-CAPACITY)
         MOVE B-OLD-PAYLOAD(1:WS-OLD-LENGTH) TO B-NEW-PAYLOAD(1:WS-OLD-LENGTH)
     END-IF
     MOVE WS-OLD-LENGTH TO WS-USED
     MOVE WS-OLD-COUNT TO WS-J
     MOVE 0 TO WS-FAIL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-FAIL = 1
         MOVE SPACES TO WS-KEY
         CALL "PB-GET-REGISTRY-ENTRY" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH WS-PRESENT
             WS-DATA WS-DATA-CAPACITY WS-DATA-LENGTH
         IF PB-ERROR = 1 OR WS-PRESENT = 0
             MOVE 1 TO WS-FAIL
             DISPLAY "ERROR registry: " FUNCTION TRIM(WS-REGISTRY)
                 ": an entry does not decode, or has no Data" UPON SYSERR
         ELSE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-J OR WS-FAIL = 1
                 IF BE-KEY(WS-K) = WS-KEY
                     MOVE 1 TO WS-FAIL
                     DISPLAY "ERROR registry: Adding duplicate key " FUNCTION TRIM(WS-KEY) " to registry "
                         FUNCTION TRIM(WS-REGISTRY) UPON SYSERR
                 END-IF
             END-PERFORM
             IF WS-FAIL = 0
                 ADD 1 TO WS-J
                 MOVE WS-KEY TO BE-KEY(WS-J)
                 MOVE WS-KEY-LENGTH TO BE-KEY-LENGTH(WS-J)
                 MOVE WS-USED TO BE-PAYLOAD-OFFSET(WS-J)
                 MOVE WS-DATA-LENGTH TO BE-PAYLOAD-LENGTH(WS-J)
                 MOVE WS-DATA(1:WS-DATA-LENGTH) TO B-NEW-PAYLOAD(WS-USED + 1:WS-DATA-LENGTH)
                 ADD WS-DATA-LENGTH TO WS-USED
             END-IF
         END-IF
     END-PERFORM
     IF WS-FAIL = 0 AND PB-POS NOT = PB-LENGTH
         MOVE 1 TO WS-FAIL
         DISPLAY "ERROR registry: bytes after the last entry of " FUNCTION TRIM(WS-REGISTRY) UPON SYSERR
     END-IF
     IF WS-FAIL = 1
         FREE WS-NEW-ENTRIES
         FREE WS-NEW-DATA
         CALL "PB-FREE" USING PB-BUFFER
         GOBACK
     END-IF
*>   Commit: the old buffers go, the registry's row (made now when it is the first packet) points at the new.
     IF WS-OLD-COUNT > 0
         FREE WS-OLD-ENTRIES
         FREE WS-OLD-DATA
     END-IF
     IF CT-REGISTRY-ADDR = NULL
         ALLOCATE LENGTH OF B-REGISTRIES CHARACTERS RETURNING WS-TABLE
         SET CT-REGISTRY-ADDR TO WS-TABLE
         MOVE 0 TO CT-REGISTRY-COUNT
     END-IF
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     IF WS-ROW = 0
         ADD 1 TO CT-REGISTRY-COUNT
         MOVE CT-REGISTRY-COUNT TO WS-ROW
         MOVE WS-REGISTRY TO BR-KEY(WS-ROW)
         MOVE WS-REGISTRY-LENGTH TO BR-KEY-LENGTH(WS-ROW)
     END-IF
     SET BR-ENTRY-ADDR(WS-ROW) TO WS-NEW-ENTRIES
     MOVE WS-J TO BR-ENTRY-COUNT(WS-ROW)
     SET BR-PAYLOAD-ADDR(WS-ROW) TO WS-NEW-DATA
     MOVE WS-USED TO BR-PAYLOAD-LENGTH(WS-ROW)
     CALL "PB-FREE" USING PB-BUFFER
     MOVE CT-OK TO L-STATUS
     GOBACK.

 END PROGRAM CLIENT-REGISTRY-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIENT-UPDATE-TAGS.
*> USING body (area), length, status out: one Update Tags packet. A first pass reads the whole packet to
*> check it (a failed packet keeps nothing); the second replaces the tag set of each registry it names
*> (TAGS-REMOVE-REGISTRY, then TAG-PUT per tag). Ids that do not resolve in a registry loaded in this set
*> are dropped (6.6); the ids of any other registry (a static one) are kept as sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY PROTO.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 65536 TIMES.
 01 WS-ID-CAPACITY         BINARY-LONG VALUE 65536.
 01 WS-ID-COUNT            BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 01 WS-REGISTRY-KEY        PIC X(112).
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 112.
 01 WS-REGISTRY            PIC X(48).
 01 WS-TAG-KEY             PIC X(112).
 01 WS-TAG-LENGTH          BINARY-LONG.
 01 WS-REGISTRY-COUNT      BINARY-LONG.
 01 WS-TAG-COUNT           BINARY-LONG.
 01 WS-FULL                PIC X(112).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FAIL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BODY                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BODY L-LENGTH L-STATUS.
     MOVE CT-BAD-DATA TO L-STATUS
     COMPUTE WS-CAPACITY = L-LENGTH + 16
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-APPEND-BYTES" USING PB-BUFFER L-BODY L-LENGTH
     MOVE 0 TO WS-FAIL
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2 OR WS-FAIL = 1
         MOVE 0 TO PB-POS
         CALL "PB-GET-TAGS-HEAD" USING PB-BUFFER WS-REGISTRY-COUNT
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WS-REGISTRY-COUNT OR PB-ERROR = 1
             MOVE SPACES TO WS-REGISTRY-KEY
             CALL "PB-GET-TAG-REGISTRY-HEAD" USING PB-BUFFER WS-REGISTRY-KEY WS-NAME-CAPACITY WS-REGISTRY-LENGTH
                 WS-TAG-COUNT
             IF PB-ERROR = 0
                 MOVE WS-REGISTRY-KEY TO WS-FULL
                 MOVE SPACES TO WS-REGISTRY
                 IF WS-REGISTRY-KEY(1:10) = "minecraft:"
                     MOVE WS-REGISTRY-KEY(11:38) TO WS-REGISTRY
                 ELSE
                     MOVE WS-REGISTRY-KEY(1:48) TO WS-REGISTRY
                 END-IF
                 MOVE 0 TO WS-LIMIT
            *>   WS-LIMIT: the entry count of the registry when this set holds it as a loaded registry, else -1.
                 MOVE -1 TO WS-LIMIT
                 IF CT-REGISTRY-ADDR NOT = NULL
                     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR WS-LIMIT >= 0
                         IF BR-KEY(WS-I) = WS-FULL
                             MOVE BR-ENTRY-COUNT(WS-I) TO WS-LIMIT
                         END-IF
                     END-PERFORM
                 END-IF
                 IF WS-PASS = 2
                     CALL "TAGS-REMOVE-REGISTRY" USING WS-REGISTRY
                 END-IF
                 PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > WS-TAG-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-TAG-KEY
                     CALL "PB-GET-TAG" USING PB-BUFFER WS-TAG-KEY WS-NAME-CAPACITY WS-TAG-LENGTH WS-IDS WS-ID-CAPACITY
                         WS-ID-COUNT
                     IF PB-ERROR = 0 AND WS-PASS = 2
                         MOVE 0 TO WS-KEPT
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ID-COUNT
                             IF WS-LIMIT < 0 OR WS-ID(WS-I) < WS-LIMIT
                                 ADD 1 TO WS-KEPT
                                 MOVE WS-ID(WS-I) TO WS-ID(WS-KEPT)
                             END-IF
                         END-PERFORM
                         CALL "TAG-PUT" USING WS-REGISTRY WS-TAG-KEY WS-KEPT WS-IDS WS-STATUS
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         IF PB-ERROR = 1 OR PB-POS NOT = PB-LENGTH
             MOVE 1 TO WS-FAIL
         END-IF
     END-PERFORM
     IF WS-FAIL = 1
         DISPLAY "ERROR registry: Update Tags does not decode" UPON SYSERR
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.

 END PROGRAM CLIENT-UPDATE-TAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTENT-CLIENT-FINISH.
*> USING world type out (BINARY-LONG: CT-TYPE-STANDARD or CT-TYPE-COBOLCRAFT, 0 when none was decided), status out:
*> CT-OK; CT-NOT-OPEN when no packet was added; CT-CLIENT-MISMATCH when the set holds no dimension_type entry.
*> The rule of WT-16, evaluated now and not on arrival: the type is cobolcraft when any entry keyed
*> cobolcraft:surface is present in the minecraft:dimension_type registry, else standard. The type and
*> the counts of the set are then those of that type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-DIMENSION           PIC X(112) VALUE "minecraft:dimension_type".
 01 WS-SURFACE-KEY         PIC X(112) VALUE "cobolcraft:surface".
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-STATUS.
     MOVE 0 TO L-TYPE
     IF CT-OPEN = 0
         MOVE CT-NOT-OPEN TO L-STATUS
         GOBACK
     END-IF
     MOVE CT-CLIENT-MISMATCH TO L-STATUS
     MOVE 0 TO WS-ROW WS-SURFACE
     IF CT-REGISTRY-ADDR NOT = NULL
         SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CT-REGISTRY-COUNT OR WS-ROW > 0
             IF BR-KEY(WS-I) = WS-DIMENSION
                 MOVE WS-I TO WS-ROW
             END-IF
         END-PERFORM
     END-IF
     IF WS-ROW = 0
         GOBACK
     END-IF
     IF BR-ENTRY-COUNT(WS-ROW) = 0
         GOBACK
     END-IF
     SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(WS-ROW)
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > BR-ENTRY-COUNT(WS-ROW) OR WS-SURFACE = 1
         IF BE-KEY(WS-J) = WS-SURFACE-KEY
             MOVE 1 TO WS-SURFACE
         END-IF
     END-PERFORM
     IF WS-SURFACE = 1
         MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     ELSE
         MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     END-IF
     MOVE CT-SET-TYPE TO L-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM CONTENT-CLIENT-FINISH.
