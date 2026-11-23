 *> Ground items carry their data component patch on the wire (T9903 rest; docs/protocol 00 section 12.2 item stack with components, 41 section 1 the stack of an item entity,
*> 54 section 19.3 the glint of a dropped stack): Set Entity Data entry 0 of a loose item is the ITEM_STACK with the stack's patch (the enchantments component, type 13: a VarInt count
*> and a pair of VarInt enchantment id and level per enchantment), so the viewers' clients draw the foil. A viewer who first sees the item, the merged stack that is sent again to its
*> viewers and the stack of a row that carries no patch are checked; the packets are read back with the proto reader the client uses (PB-GET-METADATA-ENTRY-X, PB-GET-ITEM-STACK).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-PATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 6000.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-PATCH               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ENCH                BINARY-LONG VALUE 5.
 01 WS-LEVEL               BINARY-LONG VALUE 3.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-WANT-ID             BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-PATCH
     CALL "SP-ADD-ENCHANT" USING WS-PATCH WS-ENCH WS-LEVEL
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY

*>   An enchanted stack that enters the world: its viewer is sent the stack with the enchantments component (type 13: count 1, id 5, level 3) and the foil.
     MOVE "test ground item patch an enchanted drop is sent with its enchantments component and the glint" TO TL-CASE
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW WS-PATCH
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE EN-ID(WS-ROW) TO WS-WANT-ID
     PERFORM DRAIN-AND-SCAN
     MOVE "stack 2x1 comps 1 type 13 len 3 bytes 1 5 3 foil 1 error 0" TO TL-EXPECTED
     PERFORM CHECK

*>   A plain stack of the same item: no component (the empty patch is the bytes the earlier builder wrote).
     MOVE "test ground item patch a stack without a patch is sent with no component and no glint" TO TL-CASE
     COMPUTE WS-X = WS-X + 1
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW2 WS-NONE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE EN-ID(WS-ROW2) TO WS-WANT-ID
     PERFORM DRAIN-AND-SCAN
     MOVE "stack 2x1 comps 0 type 0 len 0 bytes 0 0 0 foil 0 error 0" TO TL-EXPECTED
     PERFORM CHECK

*>   A row whose item record belongs to another entity (a row filled by hand) has no patch to send: the plain stack.
     MOVE "test ground item patch a row whose item record is another entity's is built as the plain stack" TO TL-CASE
     MOVE EN-ID(WS-ROW) TO WS-WANT-ID
     COMPUTE IP-I-ID(WS-ROW) = EN-ID(WS-ROW) + 1000
     CALL "PB-RESET" USING PK-BUFFER
     CALL "GI-DATA-BUILD" USING WS-ROW PK-BUFFER
     MOVE 0 TO PK-POS
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-PACKET-ID
     PERFORM DESCRIBE-DATA
     MOVE "stack 2x1 comps 0 type 0 len 0 bytes 0 0 0 foil 0 error 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE EN-ID(WS-ROW) TO IP-I-ID(WS-ROW)
     CALL "PB-RESET" USING PK-BUFFER
     CALL "GI-DATA-BUILD" USING WS-ROW PK-BUFFER
     MOVE 0 TO PK-POS
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-PACKET-ID
     PERFORM DESCRIBE-DATA
     MOVE "test ground item patch the same row with its own record is built with the enchantments" TO TL-CASE
     MOVE "stack 2x1 comps 1 type 13 len 3 bytes 1 5 3 foil 1 error 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Two enchanted stacks of one item that merge: the merged stack (2 items) is sent again to the viewer with the enchantments.
     MOVE "test ground item patch a merged enchanted stack is sent again with its enchantments and the glint" TO TL-CASE
     COMPUTE WS-Z = WS-Z + 3
     MOVE 6 TO WS-DELAY
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW WS-PATCH
     CALL "GI-SPAWN-X" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY WS-ROW2 WS-PATCH
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO WS-WANT-ID
     PERFORM DRAIN-AND-SCAN
     MOVE "stack 2x2 comps 1 type 13 len 3 bytes 1 5 3 foil 1 error 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Drains Alice's connection and describes the last Set Entity Data (0x65) of entity WS-WANT-ID (any entity when it is 0) into WS-TEXT.
 DRAIN-AND-SCAN.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE "no data" TO WS-TEXT
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 101
             PERFORM DESCRIBE-DATA
         END-IF
     END-PERFORM.

*> One Set Entity Data of PK-BUFFER with an ITEM_STACK as entry 0 (a ground item's) of the wanted entity: the entry read as the client reads it (count, item, glint), then the stack read
*> again with its components.
 DESCRIBE-DATA.
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-ID
     MOVE PK-POS TO WS-START
     CALL "PB-GET-UBYTE" USING PK-BUFFER WS-INDEX
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-SERIALIZER
     IF WS-INDEX = 0 AND WS-SERIALIZER = 7 AND (WS-WANT-ID = 0 OR WS-ID = WS-WANT-ID)
         MOVE WS-START TO PK-POS
         CALL "PB-GET-METADATA-ENTRY-X" USING PK-BUFFER PK-METADATA-ENTRY-X
         MOVE PK-MX-IS-COUNT TO WS-E1
         MOVE PK-MX-IS-ITEM TO WS-E2
         MOVE PK-MX-IS-FOIL TO WS-E6
         MOVE PK-ERROR TO WS-E7
         MOVE WS-START TO PK-POS
         MOVE 0 TO PK-ERROR
         CALL "PB-GET-UBYTE" USING PK-BUFFER WS-INDEX
         CALL "PB-GET-VARINT" USING PK-BUFFER WS-SERIALIZER
         CALL "PB-GET-ITEM-STACK" USING PK-BUFFER PK-ITEMSTACK-X
         MOVE PK-ISX-ADDED-COUNT TO WS-E3
         MOVE PK-ISX-TYPE(1) TO WS-E4
         MOVE PK-ISX-VALUE-LENGTH(1) TO WS-E5
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         STRING "stack " FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E1) " comps " FUNCTION TRIM(WS-E3) " type " FUNCTION TRIM(WS-E4)
             " len " FUNCTION TRIM(WS-E5) " bytes " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 3
             MOVE 0 TO WS-BYTE
             IF PK-ISX-VALUE-LENGTH(1) = 3
                 COMPUTE WS-BYTE = FUNCTION ORD(PK-ISX-VALUE(1)(WS-B:1)) - 1
             END-IF
             MOVE WS-BYTE TO WS-E1
             STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-PERFORM
         STRING "foil " FUNCTION TRIM(WS-E6) " error " FUNCTION TRIM(WS-E7) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-GROUND-ITEM-PATCH.

 COPY CORETEST.
