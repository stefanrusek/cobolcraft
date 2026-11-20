 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-UNKNOWN-SCAN.
*> USING old PB-BUFFER (an entities/ chunk payload at its root payload), slices (a table of 256 start and end byte offsets, in
*> the buffer), count out (BINARY-LONG): the entities of its Entities list that the core cannot hold (07 §10.7): an id the
*> open set does not name, or a type that ENTITY-NBT-ONE does not spawn (neither the ground item nor a mob). Each
*> one's compound payload bytes are the slice START + 1 to END; more than 256 are not kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY MOBS.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-LOCAL               PIC X(48).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ENTITY-TYPE         BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-SLICES.
    05 L-SLICE OCCURS 256 TIMES.
       10 L-SLICE-START    BINARY-LONG.
       10 L-SLICE-END      BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-SLICES L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "Entities" AND WS-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-LIST-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIST-COUNT OR PB-ERROR = 1
                 MOVE PB-POS TO WS-START
                 MOVE -1 TO WS-ENTITY-TYPE
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WN = "id" AND WS-INNER-TYPE = 8
                         MOVE SPACES TO WS-KEY
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                         CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > ET-COUNT
                             IF ET-KEY(WS-K) = WS-LOCAL
                                 COMPUTE WS-ENTITY-TYPE = WS-K - 1
                             END-IF
                         END-PERFORM
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-IF
                 END-PERFORM
                 IF PB-ERROR = 0 AND L-COUNT < 256
                     IF WS-ENTITY-TYPE NOT = CR-LOOSE-ITEM AND WS-ENTITY-TYPE < MOB-FIRST-TYPE
                         ADD 1 TO L-COUNT
                         MOVE WS-START TO L-SLICE-START(L-COUNT)
                         MOVE PB-POS TO L-SLICE-END(L-COUNT)
                     END-IF
                 END-IF
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-UNKNOWN-SCAN.

*> Entity persistence (07 section 9.3): the entities/ region files, one payload per chunk (ENTITY-NBT-*, PERSIST-ENTITIES-*).
*> Split from persistence.cob (T0331).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-COMPOUND-KEYS.
*> USING row, position row, PB-BUFFER (inside an entity compound): the keys of one saved entity, id first, Passengers and the End tag not included: the Pos is
*> the one of the position row (the row itself, or its vehicle for a passenger, 45-1 section 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY ENKEEP.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-UUID-INTS.
    05 WS-UUID-INT         BINARY-LONG OCCURS 4 TIMES.
 01 WS-POSITION.
    05 WS-POSITION-INT     BINARY-LONG OCCURS 2 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-UNKNOWN-COUNT       BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KIND-ZERO           BINARY-LONG VALUE 0.
 01 WS-ITEM-HEALTH         BINARY-LONG VALUE 5.
 01 WS-LIVING              BINARY-LONG.
 01 WS-SLICES.
    05 WS-SLICE OCCURS 256 TIMES.
       10 WS-SLICE-START   BINARY-LONG.
       10 WS-SLICE-END     BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 01 L-POS-ROW              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-POS-ROW PB-BUFFER.
     MOVE "id" TO WN MOVE 2 TO WL
     COMPUTE WS-KIND = EN-TYPE(L-ROW) + 1
     CALL "PERSIST-NAMESPACED" USING ET-KEY(WS-KIND) ET-KEY-LENGTH(WS-KIND)
         WS-NS-KEY WS-NS-LENGTH
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
     MOVE "Pos" TO WN MOVE 3 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-X(L-POS-ROW)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Y(L-POS-ROW)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Z(L-POS-ROW)
     MOVE "Motion" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VX(L-ROW)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VY(L-ROW)
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VZ(L-ROW)
     MOVE "Rotation" TO WN MOVE 8 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-FLOAT WS-TWO
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-YAW(L-ROW)
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-PITCH(L-ROW)
*>           The Entity base keys (45 section 5, ENTITY-BASE-WRITE): the six written every time, then the conditional ones.
     CALL "ENTITY-BASE-WRITE" USING L-ROW PB-BUFFER
     IF EN-TYPE(L-ROW) = CR-LOOSE-ITEM
*>               The ItemEntity keys (45-8 section 3.1), in the table order: Health, Age and PickupDelay Shorts, then the stack.
         MOVE "Health" TO WN MOVE 6 TO WL
         CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL WS-ITEM-HEALTH
         MOVE "Age" TO WN MOVE 3 TO WL
         CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL EN-AGE(L-ROW)
         MOVE "PickupDelay" TO WN MOVE 11 TO WL
         CALL "NBT-WRITE-SHORT" USING PB-BUFFER WN WL EN-DELAY(L-ROW)
         MOVE "Item" TO WN MOVE 4 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         MOVE "id" TO WN MOVE 2 TO WL
         COMPUTE WS-KIND = EN-ITEM(L-ROW) + 1
         CALL "PERSIST-NAMESPACED" USING IT-KEY(WS-KIND) IT-KEY-LENGTH(WS-KIND)
             WS-NS-KEY WS-NS-LENGTH
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
         MOVE "count" TO WN MOVE 5 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ITEM-COUNT(L-ROW)
         IF EK-ITEM-COMP-LEN(L-ROW) > 0
             MOVE "components" TO WN MOVE 10 TO WL
             CALL "NBT-WRITE-HEADER" USING PB-BUFFER WS-T-COMPOUND WN WL
             CALL "PB-APPEND-BYTES" USING PB-BUFFER EK-ITEM-COMP-RAW(L-ROW) EK-ITEM-COMP-LEN(L-ROW)
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         CALL "ENTITY-SPX-WRITE" USING L-ROW PB-BUFFER
     ELSE
*>               A LivingEntity (45-2; an armor stand, 45-9, has no Mob keys): Health, the LivingEntity keys and the Mob keys; a TNT, falling block, boat, minecart or projectile is an Entity only.
         CALL "ENTITY-IS-LIVING" USING L-ROW WS-LIVING
         IF WS-LIVING > 0
             MOVE "Health" TO WN MOVE 6 TO WL
             MOVE EN-HEALTH(L-ROW) TO WS-FLOAT
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
             CALL "LIVING-NBT-WRITE" USING L-ROW PB-BUFFER
             IF WS-LIVING = 1
                 CALL "MOB-NBT-WRITE" USING L-ROW PB-BUFFER
                 CALL "MOBKEEP-NBT-WRITE" USING L-ROW PB-BUFFER
             ELSE
                 CALL "ARMORSTAND9-NBT-WRITE" USING L-ROW PB-BUFFER
             END-IF
         END-IF
         CALL "ENTITY8-NBT-WRITE" USING L-ROW PB-BUFFER
         CALL "ENTITY-SPX-WRITE" USING L-ROW PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM ENTITY-COMPOUND-KEYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-WRITE-MERGE.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), PB-BUFFER (appended to), old PB-BUFFER (the chunk's payload as the file
*> holds it, at its root payload), found (BINARY-LONG: 1 when the old payload is given; then the entities of it that the core
*> cannot hold, ENTITY-UNKNOWN-SCAN, are copied after the core's own, 07 §10.7): the entities/ chunk
*> payload (07 §9.3) of that chunk: DataVersion, Position [chunk x, chunk z] and Entities, one
*> compound per mob and ground item of that dimension whose position is in the chunk, in tracker
*> order: id, Pos, Motion, Rotation, the base keys fall_distance, Fire, Air, OnGround, Invulnerable, PortalCooldown and UUID (45 section 5), then Health (mobs) or Item {id, count} and Age (ground items).
*> Players are not stored here (07 §9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-UUID-INTS.
    05 WS-UUID-INT         BINARY-LONG OCCURS 4 TIMES.
 01 WS-POSITION.
    05 WS-POSITION-INT     BINARY-LONG OCCURS 2 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-UNKNOWN-COUNT       BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KIND-ZERO           BINARY-LONG VALUE 0.
 01 WS-ITEM-HEALTH         BINARY-LONG VALUE 5.
 01 WS-LIVING              BINARY-LONG.
 01 WS-PASSENGER           BINARY-LONG.
 01 WS-CHAIN-TABLE.
    05 WS-CHAIN            BINARY-LONG OCCURS 8 TIMES.
    05 WS-STARTS           BINARY-LONG OCCURS 8 TIMES.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-POS-ROW             BINARY-LONG.
 01 WS-ONE-COUNT           BINARY-LONG VALUE 1.
 01 WS-SLICES.
    05 WS-SLICE OCCURS 256 TIMES.
       10 WS-SLICE-START   BINARY-LONG.
       10 WS-SLICE-END     BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-POINTER             USAGE POINTER.
 01 B-SLICE                PIC X BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER WK-BUFFER L-FOUND.
     MOVE 0 TO WS-COUNT WS-UNKNOWN-COUNT
     IF L-FOUND = 1
         CALL "ENTITY-UNKNOWN-SCAN" USING WK-BUFFER WS-SLICES WS-UNKNOWN-COUNT
     END-IF
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         CALL "ENTITY-IS-PASSENGER" USING WS-ROW WS-PASSENGER
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ AND WS-PASSENGER = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "Position" TO WN MOVE 8 TO WL
     MOVE L-CX TO WS-POSITION-INT(1)
     MOVE L-CZ TO WS-POSITION-INT(2)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-TWO WS-POSITION
     MOVE "Entities" TO WN
     ADD WS-UNKNOWN-COUNT TO WS-COUNT
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ
*>           The entity and the passengers riding it, one inside the other (45-1 section 7: a Passengers list of the one mob that rides it, whose Pos is the vehicle's).
             MOVE WS-ROW TO WS-CHAIN(1)
             MOVE 1 TO WS-DEPTH
             PERFORM UNTIL WS-DEPTH >= 8
                 MOVE EN-PASS(WS-CHAIN(WS-DEPTH)) TO WS-NEXT
                 IF WS-NEXT = 0
                     EXIT PERFORM
                 END-IF
                 CALL "ENTITY-IS-PASSENGER" USING WS-NEXT WS-PASSENGER
                 IF WS-PASSENGER = 0 OR EN-MOUNT(WS-NEXT) NOT = WS-CHAIN(WS-DEPTH)
                     EXIT PERFORM
                 END-IF
                 ADD 1 TO WS-DEPTH
                 MOVE WS-NEXT TO WS-CHAIN(WS-DEPTH)
             END-PERFORM
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > WS-DEPTH
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
                 MOVE PB-LENGTH TO WS-STARTS(WS-D)
                 MOVE WS-CHAIN(WS-D) TO WS-POS-ROW
                 IF WS-D > 1
                     MOVE WS-CHAIN(WS-D - 1) TO WS-POS-ROW
                 END-IF
                 CALL "ENTITY-COMPOUND-KEYS" USING WS-CHAIN(WS-D) WS-POS-ROW PB-BUFFER
                 IF WS-D < WS-DEPTH
                     MOVE "Passengers" TO WN MOVE 10 TO WL
                     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-ONE-COUNT
                 END-IF
             END-PERFORM
             PERFORM VARYING WS-D FROM WS-DEPTH BY -1 UNTIL WS-D < 1
                 CALL "EXTRA-APPEND" USING WS-KIND-ZERO WS-CHAIN(WS-D) PB-BUFFER WS-STARTS(WS-D)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             END-PERFORM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > WS-UNKNOWN-COUNT
         COMPUTE WS-SIZE = WS-SLICE-END(WS-ROW) - WS-SLICE-START(WS-ROW)
         SET WS-POINTER TO WK-ADDR
         SET WS-POINTER UP BY WS-SLICE-START(WS-ROW)
         SET ADDRESS OF B-SLICE TO WS-POINTER
         CALL "PB-APPEND-BYTES" USING PB-BUFFER B-SLICE WS-SIZE
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM ENTITY-NBT-WRITE-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-IS-PASSENGER.
*> USING row, flag out (BINARY-LONG): 1 when the row is a mob that rides a mob of the tracker (EN-MOUNT with the vehicle's entity id): it is saved inside its vehicle's
*> compound, never on its own (45-1 section 7.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     IF EN-USED(L-ROW) = 1 AND EN-MOUNT(L-ROW) > 0
         IF EN-USED(EN-MOUNT(L-ROW)) = 1 AND EN-MOUNT-ID(L-ROW) = EN-ID(EN-MOUNT(L-ROW))
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-IS-PASSENGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-WRITE.
*> USING dimension row, chunk x, chunk z, PB-BUFFER: the chunk's payload with no old payload to keep (ENTITY-NBT-WRITE-MERGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER.
     CALL "ENTITY-NBT-WRITE-MERGE" USING L-DIM L-CX L-CZ PB-BUFFER WK-BUFFER WS-NONE
     GOBACK.
 END PROGRAM ENTITY-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-READ.
*> USING dimension row (BINARY-LONG), PB-BUFFER (an entities/ chunk payload at PB-POS), outcome out
*> (BINARY-LONG: 0 read, 1 malformed or refused): every entity of its Entities list enters that dimension
*> (ENTITY-NBT-ONE), each with the passengers of its Passengers list riding it (45-1 section 7.3). A payload whose DataVersion is below 5023 is refused
*> (45-1 section 1.4: the fixers are not specified); a newer one, or one without, is read as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-PASSENGERS          BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-REFUSED             BINARY-LONG.
 01 WS-PASS-AT             BINARY-LONG.
 01 WS-HOME                BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-DATA-VERSION        BINARY-LONG.
 01 WS-STACK-N             BINARY-LONG.
 01 WS-STACK.
    05 WS-STACK-ENTRY OCCURS 16 TIMES.
       10 WS-STACK-AT      BINARY-LONG.
       10 WS-STACK-ROW     BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER L-OUTCOME.
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE 0 TO WS-REFUSED
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "DataVersion" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-DATA-VERSION
                 IF WS-DATA-VERSION < 5023
                     MOVE 1 TO WS-REFUSED
                 END-IF
             WHEN WN = "Entities" AND WS-TYPE = 9 AND WS-REFUSED = 0
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     CALL "ENTITY-NBT-ONE" USING L-DIM PB-BUFFER WS-ROW WS-PASS-AT
*>                   The passengers of the entity just read, and theirs in turn: each is created, then rides its vehicle when that exists.
                     MOVE 0 TO WS-STACK-N
                     IF WS-PASS-AT > 0
                         MOVE 1 TO WS-STACK-N
                         MOVE WS-PASS-AT TO WS-STACK-AT(1)
                         MOVE WS-ROW TO WS-STACK-ROW(1)
                     END-IF
                     MOVE PB-POS TO WS-HOME
                     PERFORM UNTIL WS-STACK-N = 0 OR PB-ERROR = 1
                         MOVE WS-STACK-AT(WS-STACK-N) TO PB-POS
                         MOVE WS-STACK-ROW(WS-STACK-N) TO WS-VEHICLE
                         SUBTRACT 1 FROM WS-STACK-N
                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-PASSENGERS
                         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-PASSENGERS OR PB-ERROR = 1
                             CALL "ENTITY-NBT-ONE" USING L-DIM PB-BUFFER WS-ROW WS-PASS-AT
                             IF WS-ROW > 0 AND WS-VEHICLE > 0
                                 CALL "MOB-MOUNT" USING WS-ROW WS-VEHICLE WS-MOUNTED
                             END-IF
                             IF WS-PASS-AT > 0 AND WS-STACK-N < 16
                                 ADD 1 TO WS-STACK-N
                                 MOVE WS-PASS-AT TO WS-STACK-AT(WS-STACK-N)
                                 MOVE WS-ROW TO WS-STACK-ROW(WS-STACK-N)
                             END-IF
                         END-PERFORM
                     END-PERFORM
                     MOVE WS-HOME TO PB-POS
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE PB-ERROR TO L-OUTCOME
     IF WS-REFUSED = 1
         MOVE 1 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM ENTITY-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-ONE.
*> USING dimension row, PB-BUFFER (an entity compound payload at PB-POS, 07 §9.3): a ground item
*> (GI-SPAWN with its stack, position and motion, no pickup delay, then its Age and rotation), an item
*> frame or glow item frame (DECOR-SPAWN with its Facing, then the Item in it, 44 part 9 5.3) or a
*> mob (MOB-SPAWN with its type, position and yaw, then its health, pitch and vertical motion). An
*> entity of another type, or a malformed one, is not created.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY MOBS.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-LOCAL               PIC X(48).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-BARE                PIC X(48).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTITY-TYPE         BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-COUNT          BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-KIND-ZERO           BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-GROUND-FLAG         BINARY-LONG.
 01 WS-UUID-SET            BINARY-LONG.
 01 WS-UUID-COUNT          BINARY-LONG.
 01 WS-UUID-CAPACITY       BINARY-LONG VALUE 4.
 01 WS-UUID-INTS.
    05 WS-UUID-INT         BINARY-LONG OCCURS 4 TIMES.
 01 WS-UUID                PIC X(16).
 01 WS-VALID               BINARY-LONG.
 01 WS-FRAME-KIND          BINARY-LONG VALUE 12.
 01 WS-FRAME-KEY           PIC X(112) VALUE "minecraft:item_frame".
 01 WS-GLOW-KEY            PIC X(112) VALUE "minecraft:glow_item_frame".
 01 WS-FACING              BINARY-LONG.
 01 WS-IS-FRAME            BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 COPY PROJSTATE.
 COPY ENMOBDATA.
 COPY EBDATA.
 COPY ENKSTAGE.
 COPY LVDATA.
 COPY SPDATA.
 COPY H5DATA.
 COPY V6DATA.
 COPY A7DATA.
 COPY E8DATA.
 01 WS-SPECIES            PIC X(24).
 01 WS-SPECIES-KEY        PIC X(24).
 01 WS-COMP-CAPACITY      BINARY-LONG VALUE 512.
 01 WS-PASS-AT            BINARY-LONG.
 01 WS-DUPLICATE           BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW-OUT              BINARY-LONG.
 01 L-PASS-AT              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER L-ROW-OUT L-PASS-AT.
     MOVE 0 TO L-ROW-OUT L-PASS-AT WS-PASS-AT
     INITIALIZE EB-DATA KD-DATA LV-DATA SP-DATA H5-DATA V6-DATA A7-DATA E8-DATA
     MOVE -1 TO E8-STATE
     MOVE 80 TO E8-FUSE
     MOVE 2400 TO A7-MOIST
     MOVE 1 TO SP-LEFT SP-RIGHT
     MOVE -1 TO SP-SCUTE
     MOVE -1 TO WS-ENTITY-TYPE
     MOVE 0 TO WS-ROW
     MOVE PB-POS TO WS-START
     MOVE 0 TO WS-ITEM WS-ITEM-COUNT WS-AGE WS-DELAY WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ
     MOVE 0 TO WS-YAW WS-PITCH WS-HEALTH WS-FIRE WS-GROUND-FLAG WS-UUID-SET WS-IS-FRAME
     MOVE 300 TO WS-AIR
     MOVE 3 TO WS-FACING
     INITIALIZE MQ-DATA
     MOVE -1 TO MQ-VARIANT-INT MQ-EGG MQ-SIZE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                 EVALUATE WS-BARE
                     WHEN "item_frame"
                         MOVE 1 TO WS-IS-FRAME
                     WHEN "glow_item_frame"
                         MOVE 2 TO WS-IS-FRAME
                 END-EVALUATE
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
                     IF ET-KEY(WS-I) = WS-LOCAL OR ET-KEY(WS-I) = WS-BARE
                         COMPUTE WS-ENTITY-TYPE = WS-I - 1
                     END-IF
                 END-PERFORM
             WHEN WN = "Pos" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
             WHEN WN = "Motion" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VX
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VY
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VZ
             WHEN WN = "Rotation" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-YAW
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PITCH
             WHEN WN = "Facing" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-FACING
             WHEN WN = "Health" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-HEALTH
             WHEN WN = "Fire" AND WS-TYPE = 2
                 CALL "PB-GET-SHORT" USING PB-BUFFER WS-FIRE
             WHEN WN = "Air" AND WS-TYPE = 2
                 CALL "PB-GET-SHORT" USING PB-BUFFER WS-AIR
             WHEN WN = "OnGround" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-GROUND-FLAG
             WHEN WN = "UUID" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-UUID-CAPACITY WS-UUID-COUNT WS-UUID-INTS
                 IF WS-UUID-COUNT = 4
                     MOVE 1 TO WS-UUID-SET
                 END-IF
             WHEN WN = "Age" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-AGE
                 MOVE WS-AGE TO MQ-AGE
             WHEN WN = "Age" AND WS-TYPE = 2
                 CALL "PB-GET-SHORT" USING PB-BUFFER WS-AGE
                 MOVE WS-AGE TO MQ-AGE
             WHEN WN = "PickupDelay" AND WS-TYPE = 2
                 CALL "PB-GET-SHORT" USING PB-BUFFER WS-DELAY
             WHEN WN = "Item" AND WS-TYPE = 10
*>               ItemStack.CODEC: count is 1 when the stack holds none (45-8 section 2).
                 MOVE 1 TO WS-ITEM-COUNT
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY
                         WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "id" AND WS-INNER-TYPE = 8
                             MOVE SPACES TO WS-KEY
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY
                                 WS-KEY-LENGTH
                             CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                             CALL "KEY-BARE" USING WS-LOCAL WS-BARE
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
                                 IF IT-KEY(WS-I) = WS-LOCAL OR IT-KEY(WS-I) = WS-BARE
                                     COMPUTE WS-ITEM = WS-I - 1
                                 END-IF
                             END-PERFORM
                         WHEN WN = "count" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-ITEM-COUNT
                         WHEN WN = "components" AND WS-INNER-TYPE = 10
                             CALL "ENTITY-KEEP-SLICE" USING PB-BUFFER WS-INNER-TYPE WS-COMP-CAPACITY KD-ITEM-COMP-LEN
                                 KD-ITEM-COMP-RAW
                             IF KD-ITEM-COMP-LEN = 1
                                 MOVE 0 TO KD-ITEM-COMP-LEN
                             END-IF
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN WN = "Passengers" AND WS-TYPE = 9
*>               The passengers are loaded by ENTITY-NBT-READ once this entity exists (45-1 section 7.3): where the list starts is handed back.
                 MOVE PB-POS TO WS-PASS-AT
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             WHEN OTHER
                 CALL "ENTITY-BASE-KEY" USING PB-BUFFER WS-TYPE WN EB-DATA WS-HANDLED
                 IF WS-HANDLED = 0
                     CALL "ENTITY-KEEP-KEY" USING PB-BUFFER WS-TYPE WN KD-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "LIVING-NBT-KEY" USING PB-BUFFER WS-TYPE WN LV-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "SPECIES4-NBT-KEY" USING PB-BUFFER WS-TYPE WN SP-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "HOSTILE5-NBT-KEY" USING PB-BUFFER WS-TYPE WN H5-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "VILLAGER6-NBT-KEY" USING PB-BUFFER WS-TYPE WN V6-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "MOB-NBT-KEY" USING PB-BUFFER WS-TYPE WN MQ-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "AQUATIC7-NBT-KEY" USING PB-BUFFER WS-TYPE WN A7-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "ENTITY8-NBT-KEY" USING PB-BUFFER WS-TYPE WN E8-DATA WS-HANDLED
                 END-IF
                 IF WS-HANDLED = 0
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE PB-POS TO WS-END
*>   Pos is clamped, Motion limited and a NaN Pos or a non-finite Rotation skips the entity (45-1 sections 5 and 6).
     CALL "ENTITY-VALIDATE" USING WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-YAW WS-PITCH WS-VALID
     EVALUATE TRUE
         WHEN PB-ERROR = 1 OR WS-VALID = 0
             CONTINUE
         WHEN WS-IS-FRAME > 0 AND WS-FACING >= 2 AND WS-FACING <= 5
             IF WS-IS-FRAME = 2
                 CALL "DECOR-SPAWN" USING WS-FRAME-KIND WS-GLOW-KEY L-DIM WS-X WS-Y WS-Z WS-FACING WS-ROW
             ELSE
                 CALL "DECOR-SPAWN" USING WS-FRAME-KIND WS-FRAME-KEY L-DIM WS-X WS-Y WS-Z WS-FACING WS-ROW
             END-IF
*>           the frame's own state: the item in it (PJ-I2, 0 empty) and the glow flag (PJ-I4)
             IF WS-ROW > 0
                 CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
                 IF WS-ITEM > 0 AND WS-ITEM-COUNT > 0
                     MOVE WS-ITEM TO PJ-I2(WS-SLOT)
                 END-IF
                 IF WS-IS-FRAME = 2
                     MOVE 1 TO PJ-I4(WS-SLOT)
                 END-IF
             END-IF
         WHEN WS-IS-FRAME > 0
*>           a frame that does not face a wall direction is not made (never as a mob)
             CONTINUE
         WHEN WS-ENTITY-TYPE = CR-LOOSE-ITEM
             CALL "GI-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ITEM-COUNT
                 WS-DELAY WS-ROW
             MOVE WS-AGE TO EN-AGE(WS-ROW)
             MOVE WS-YAW TO EN-YAW(WS-ROW)
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             CALL "ENTITY-SPECIES-KEY" USING WS-ROW WS-SPECIES-KEY
             CALL "ENTITY-SPX-READ" USING PB-BUFFER WS-START WS-END WS-SPECIES-KEY KD-DATA
         WHEN WS-ENTITY-TYPE >= MOB-FIRST-TYPE
             CALL "MOB-SPAWN" USING L-DIM WS-ENTITY-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
             COMPUTE EN-HEALTH(WS-ROW) ROUNDED = WS-HEALTH
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             MOVE WS-VX TO EN-VX(WS-ROW)
             MOVE WS-VY TO EN-VY(WS-ROW)
             MOVE WS-VZ TO EN-VZ(WS-ROW)
             CALL "MOB-NBT-APPLY" USING WS-ROW MQ-DATA
             CALL "LIVING-NBT-APPLY" USING WS-ROW LV-DATA
             CALL "MOB-SPECIES-KEY" USING WS-ROW WS-SPECIES
             CALL "ENTITY-SPECIES-KEY" USING WS-ROW WS-SPECIES-KEY
             CALL "ENTITY-SPX-READ" USING PB-BUFFER WS-START WS-END WS-SPECIES-KEY KD-DATA
             MOVE MQ-SIT TO SP-SIT
             CALL "SPECIES4-NBT-APPLY" USING WS-ROW WS-SPECIES SP-DATA
             MOVE MQ-BABY TO H5-BABY
             CALL "HOSTILE5-NBT-APPLY" USING WS-ROW WS-SPECIES H5-DATA
             MOVE H5-IMMUNE TO V6-IMMUNE
             MOVE H5-TIME TO V6-TIME
             CALL "VILLAGER6-NBT-APPLY" USING WS-ROW WS-SPECIES V6-DATA
             MOVE MQ-VARIANT-INT TO A7-TROP
             MOVE MQ-AGE TO A7-AGE
             MOVE MQ-LOCKED TO A7-LOCKED
             CALL "AQUATIC7-NBT-APPLY" USING WS-ROW WS-SPECIES A7-DATA
             CALL "ENTITY8-NBT-APPLY" USING WS-ROW E8-DATA
             MOVE WS-GROUND-FLAG TO EN-ON-GROUND(WS-ROW)
             MOVE WS-FIRE TO EN-BURN(WS-ROW)
             IF WS-AIR < 300
                 COMPUTE EN-AIR-LOST(WS-ROW) = 300 - WS-AIR
             END-IF
     END-EVALUATE
     IF PB-ERROR = 0 AND WS-ROW > 0
         CALL "ENTITY-BASE-APPLY" USING WS-ROW EB-DATA
         CALL "ENTITY-KEEP-APPLY" USING WS-ROW KD-DATA
     END-IF
     IF PB-ERROR = 0 AND WS-ROW > 0 AND WS-UUID-SET = 1
         CALL "ENTITY-UUID-BYTES" USING WS-UUID-INTS WS-UUID
         MOVE WS-UUID TO EN-UUID(WS-ROW)
*>       A UUID that a loaded entity already has refuses the new one (45-1 section 6: "UUID of added entity already exists").
         MOVE 0 TO WS-DUPLICATE
         PERFORM VARYING WS-OTHER FROM 1 BY 1 UNTIL WS-OTHER > EN-COUNT
             IF WS-OTHER NOT = WS-ROW AND EN-USED(WS-OTHER) = 1 AND EN-UUID(WS-OTHER) = WS-UUID
                 MOVE 1 TO WS-DUPLICATE
             END-IF
         END-PERFORM
         IF WS-DUPLICATE = 1
             CALL "ENTITY-REMOVE" USING WS-ROW
             MOVE 0 TO WS-ROW
         END-IF
     END-IF
*>   The keys of the file's compound that the core does not model are kept for the next save of a 26.3 world (07 section 10.7).
     IF WS-ROW > 0 AND WS-IS-FRAME = 0
         CALL "EXTRA-CAPTURE" USING WS-KIND-ZERO WS-ROW PB-BUFFER WS-START WS-END
         MOVE WS-ROW TO L-ROW-OUT
     END-IF
     MOVE WS-PASS-AT TO L-PASS-AT
     GOBACK.
 END PROGRAM ENTITY-NBT-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-SAVE.
*> USING dimension row: replaces the dimension's entities/ region files: every region file there is
*> deleted, then each chunk that holds mobs or ground items gets its payload (ENTITY-NBT-WRITE). A
*> chunk whose entities all left or vanished therefore holds none after the save.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-CHUNKS.
    05 WS-CHUNK OCCURS 4096 TIMES.
       10 WS-CHUNK-X       BINARY-LONG.
       10 WS-CHUNK-Z       BINARY-LONG.
 01 WS-CHUNK-COUNT         BINARY-LONG.
 01 WS-PARTS.
    05 WS-PART             PIC X(32) OCCURS 4 TIMES.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-OLD-FOUND           BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT WS-CHUNK-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         MOVE SPACES TO WS-PATH
         STRING WS-DIR(1:WS-LENGTH) "/" WS-ENTRY(2:255) DELIMITED BY SIZE INTO WS-PATH
         IF CW-LAYOUT = 0
             CALL "CBL_DELETE_FILE" USING WS-PATH
         ELSE
*>           A world of the 26.3 layout keeps its files; the chunks that have a payload there are rewritten below.
             MOVE SPACES TO WS-PART(1) WS-PART(2) WS-PART(3) WS-PART(4)
             UNSTRING WS-ENTRY(2:255) DELIMITED BY "." INTO WS-PART(1) WS-PART(2) WS-PART(3) WS-PART(4)
             COMPUTE WS-RX = FUNCTION NUMVAL(WS-PART(2))
             COMPUTE WS-RZ = FUNCTION NUMVAL(WS-PART(3))
             PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 31
                 PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 31
                     COMPUTE WS-K = WS-RX * 32 + WS-CX
                     COMPUTE WS-I = WS-RZ * 32 + WS-CZ
                     CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-K WS-I WK-BUFFER WS-OUTCOME
                     IF WS-OUTCOME = 0 AND WS-CHUNK-COUNT < 4096
                         ADD 1 TO WS-CHUNK-COUNT
                         MOVE WS-K TO WS-CHUNK-X(WS-CHUNK-COUNT)
                         MOVE WS-I TO WS-CHUNK-Z(WS-CHUNK-COUNT)
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
                 IF WS-CHUNK-X(WS-K) = WS-CX AND WS-CHUNK-Z(WS-K) = WS-CZ
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-CHUNK-COUNT
                 MOVE WS-CX TO WS-CHUNK-X(WS-CHUNK-COUNT)
                 MOVE WS-CZ TO WS-CHUNK-Z(WS-CHUNK-COUNT)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-DIR TO WS-PATH
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
         CALL "PB-RESET" USING PB-BUFFER
         MOVE 0 TO WS-OLD-FOUND
         IF CW-LAYOUT = 1
             CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) WK-BUFFER
                 WS-OUTCOME
             IF WS-OUTCOME = 0
                 CALL "NBT-READ-ROOT" USING WK-BUFFER WS-FRAMING WS-TYPE
                 MOVE 1 TO WS-OLD-FOUND
             END-IF
         END-IF
         CALL "ENTITY-NBT-WRITE-MERGE" USING L-DIM WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
             WK-BUFFER WS-OLD-FOUND
         CALL "REGION-WRITE" USING WS-DIR WS-LENGTH WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
             WS-OUTCOME
         CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-LOAD.
*> USING dimension row: every chunk payload of every entities/ region file of the dimension
*> (r.<rx>.<rz>.mca, 32 x 32 chunks each) enters the world (ENTITY-NBT-READ). The entity tracker
*> holds every entity of the world, so they are all loaded when the world opens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-PARTS.
    05 WS-PART             PIC X(32) OCCURS 4 TIMES.
 01 WS-ABS-X               BINARY-LONG.
 01 WS-ABS-Z               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY WS-PART(1) WS-PART(2) WS-PART(3) WS-PART(4)
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         UNSTRING WS-ENTRY(2:255) DELIMITED BY "." INTO WS-PART(1) WS-PART(2) WS-PART(3)
             WS-PART(4)
         COMPUTE WS-RX = FUNCTION NUMVAL(WS-PART(2))
         COMPUTE WS-RZ = FUNCTION NUMVAL(WS-PART(3))
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 31
             PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 31
                 COMPUTE WS-ABS-X = WS-RX * 32 + WS-CX
                 COMPUTE WS-ABS-Z = WS-RZ * 32 + WS-CZ
                 CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-ABS-X WS-ABS-Z PB-BUFFER WS-OUTCOME
                 IF WS-OUTCOME = 0
                     CALL "ENTITY-NBT-READ" USING L-DIM PB-BUFFER WS-OUTCOME
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-UUID-INTS.
*> USING uuid (PIC X(16)), ints out (4 BINARY-LONG): the UUID as four big-endian signed ints, the form of the UUID key (45 section 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-INTS.
    05 L-INT               BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-UUID L-INTS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE 0 TO WS-V
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-V = WS-V * 256 + FUNCTION ORD(L-UUID((WS-I - 1) * 4 + WS-J:1)) - 1
         END-PERFORM
         IF WS-V >= 2147483648
             SUBTRACT 4294967296 FROM WS-V
         END-IF
         MOVE WS-V TO L-INT(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-UUID-INTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-UUID-BYTES.
*> USING ints (4 BINARY-LONG), uuid out (PIC X(16)): the inverse of ENTITY-UUID-INTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INTS.
    05 L-INT               BINARY-LONG OCCURS 4 TIMES.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING L-INTS L-UUID.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE L-INT(WS-I) TO WS-V
         IF WS-V < 0
             ADD 4294967296 TO WS-V
         END-IF
         PERFORM VARYING WS-J FROM 4 BY -1 UNTIL WS-J < 1
             COMPUTE WS-B = FUNCTION MOD(WS-V, 256)
             MOVE FUNCTION CHAR(WS-B + 1) TO L-UUID((WS-I - 1) * 4 + WS-J:1)
             COMPUTE WS-V = (WS-V - WS-B) / 256
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-UUID-BYTES.
