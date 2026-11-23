*> T9903 (54 section 19.3): the glint of the dropped item and the framed item. The Set Entity Data entry of the stack is decoded with its data components (PB-GET-ITEM-STACK; the old reader failed for any
*> stack with a component) and the replica keeps the stack's foil (EN-STACK-FOIL: enchantments not empty, enchantment_glint_override first). A dropped item of the standard set (key `item`) with the foil adds
*> the glint layer to RL-WG-VERTEX: a flat icon one quad of each opaque texel on the front and the back, in the plane of the item's own quad, a block the faces that are drawn, at the same positions.
*> A framed item takes the same layer through its posed draw. Expected counts come from the opaque texels of stick.png in the atlas; positions are checked against the item's own vertices.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-GLINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DIR                 BINARY-LONG VALUE 2.
 01 WS-ROT                 BINARY-LONG VALUE 0.
 01 WS-STICK               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-OPAQUE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-LO-X                FLOAT-LONG.
 01 WS-HI-X                FLOAT-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
*>   The opaque texels of the stick's icon: the expected number of glint quads.
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-STICK WS-SPRITE
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     MOVE 0 TO WS-OPAQUE
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= AT-SW(WS-SPRITE)
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= AT-SW(WS-SPRITE)
             COMPUTE WS-OFF = ((AT-Y(WS-SPRITE) + WS-PY) * AT-W + AT-X(WS-SPRITE) + WS-PX) * 4 + 4
             IF FUNCTION ORD(B-ATLAS(WS-OFF:1)) > 1
                 ADD 1 TO WS-OPAQUE
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "T9903 the stick icon has opaque texels" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OPAQUE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-STRENGTH

*>   The replica decodes an enchanted stack of a dropped item (entry 8): count, item and the foil.
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 1 TO WS-ID
     CALL "GG-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 8 TO WS-INDEX
     MOVE 1 TO WS-COUNT
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE "T9903 an enchanted dropped stick is decoded: count 1, its item and the foil" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-STACK-COUNT(1) * 100000 + EN-STACK-ITEM(1) * 10 + EN-STACK-FOIL(1)
     COMPUTE TL-EXPECTED-N = 100000 + WS-STICK * 10 + 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Its glint layer: a multiple of 12 vertices, one texel quad a side, in the plane of the item's quad, with the glint strength.
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 the dropped foil stick draws its own 12 vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9903 the dropped foil stick adds 12 glint vertices a opaque texel" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 12 * WS-OPAQUE
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The plane of the item's front quad (vertices 1 2 3): every glint vertex lies in it.
     COMPUTE WS-AX = RL-GI-X(2) - RL-GI-X(1)
     COMPUTE WS-AY = RL-GI-Y(2) - RL-GI-Y(1)
     COMPUTE WS-AZ = RL-GI-Z(2) - RL-GI-Z(1)
     COMPUTE WS-BX = RL-GI-X(3) - RL-GI-X(1)
     COMPUTE WS-BY = RL-GI-Y(3) - RL-GI-Y(1)
     COMPUTE WS-BZ = RL-GI-Z(3) - RL-GI-Z(1)
     COMPUTE WS-NX = WS-AY * WS-BZ - WS-AZ * WS-BY
     COMPUTE WS-NY = WS-AZ * WS-BX - WS-AX * WS-BZ
     COMPUTE WS-NZ = WS-AX * WS-BY - WS-AY * WS-BX
     COMPUTE WS-LEN = FUNCTION SQRT(WS-NX * WS-NX + WS-NY * WS-NY + WS-NZ * WS-NZ)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-WG-COUNT
         COMPUTE WS-DIST = FUNCTION ABS((RL-WG-X(WS-I) - RL-GI-X(1)) * WS-NX + (RL-WG-Y(WS-I) - RL-GI-Y(1)) * WS-NY
             + (RL-WG-Z(WS-I) - RL-GI-Z(1)) * WS-NZ) / WS-LEN
         IF WS-DIST > 0.0001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T9903 every glint vertex of the dropped stick is in the plane of its quad" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Inside the quad: the glint's x range lies within the item's x range (the quad is 0.5 wide centred on the entity).
     MOVE RL-GI-X(1) TO WS-LO-X WS-HI-X
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 12
         IF RL-GI-X(WS-I) < WS-LO-X
             MOVE RL-GI-X(WS-I) TO WS-LO-X
         END-IF
         IF RL-GI-X(WS-I) > WS-HI-X
             MOVE RL-GI-X(WS-I) TO WS-HI-X
         END-IF
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-WG-COUNT
         IF RL-WG-X(WS-I) < WS-LO-X - 0.0001 OR RL-WG-X(WS-I) > WS-HI-X + 0.0001
             ADD 1 TO WS-BAD
         END-IF
         IF FUNCTION ABS(RL-WG-B(WS-I) - WS-STRENGTH) > 0.0001 OR RL-WG-A(WS-I) NOT = 1 OR RL-WG-SKY(WS-I) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T9903 the glint vertices stay inside the quad and have the glint strength as brightness" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The icon of the entity is ITEM-SPRITE-OF's: the glint covers the whole icon, so the quad spans the same x range as the item's own vertices (the first texel column starts at the left edge or after it).
*>   A stack of 3 is two copies: twice the glint.
     MOVE 3 TO WS-COUNT
     MOVE 8 TO WS-INDEX
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a foil stack of 3 is two copies, each with its glint" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 24 * WS-OPAQUE
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Damage only: the stack decodes (it did not) and has no glint.
     MOVE 1 TO WS-COUNT
     MOVE 2 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE "T9903 a damaged dropped stick decodes: count 1, no foil" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-STACK-COUNT(1) * 10 + EN-STACK-FOIL(1)
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a stack without the foil adds no glint" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A plain stack after an enchanted one clears the foil.
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE 0 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE "T9903 a plain stack replaces the foil of the enchanted one" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-STACK-FOIL(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A dropped block (stone): the glint faces are the faces that are drawn, at the same positions.
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STONE WS-KIND
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a dropped foil block adds a glint vertex for each vertex of the faces drawn" TO TL-CASE
     MOVE RL-GI-COUNT TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T9903 a dropped foil block draws faces" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-GI-COUNT > 0 AND FUNCTION MOD(RL-GI-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-GI-COUNT
         IF FUNCTION ABS(RL-WG-X(WS-I) - RL-GI-X(WS-I)) > 0.0001 OR FUNCTION ABS(RL-WG-Y(WS-I) - RL-GI-Y(WS-I)) > 0.0001
                 OR FUNCTION ABS(RL-WG-Z(WS-I) - RL-GI-Z(WS-I)) > 0.0001
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "T9903 the glint vertices of the block are those of its faces" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STONE WS-KIND
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a plain dropped block has no glint" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An item frame (entry 9 holds the stack): an enchanted stick glints, a plain one does not, an empty frame has no foil.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "item_frame" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 5 TO WS-ID
     CALL "GG-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 9 TO WS-INDEX
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE "T9903 an enchanted framed stick keeps its foil" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-STACK-COUNT(1) * 10 + EN-STACK-FOIL(1)
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 an enchanted framed stick draws its icon and the glint of every opaque texel" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 12 * 1000 + 12 * WS-OPAQUE
     COMPUTE TL-OBSERVED-N = RL-GI-COUNT * 1000 + RL-WG-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T9903 a plain framed stick draws no glint" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-WG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-KIND
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE 0 TO WS-COUNT
     CALL "GG-DATA" USING CLIENT-STATE WS-ID WS-INDEX WS-COUNT WS-STICK WS-KIND
     MOVE "T9903 emptying the frame clears the stack and its foil" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EN-STACK-COUNT(1) * 10 + EN-STACK-FOIL(1)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-GROUND-ITEM-GLINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GG-DATA.
*> USING CLIENT-STATE, entity id, entry index, count, item registry id, kind (0 no components, 1 enchantments with one enchantment, 2 damage): Set Entity Data with one ITEM_STACK entry
*> (serializer 7) written byte by byte (the entry writer has no components), a count of 0 being the empty stack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 01 WS-SERIALIZER          BINARY-LONG VALUE 7.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-INDEX L-COUNT L-ITEM L-KIND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SERIALIZER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-ITEM
         MOVE 0 TO WS-V
         IF L-KIND > 0
             MOVE 1 TO WS-V
         END-IF
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
         MOVE 0 TO WS-V
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
         IF L-KIND = 1
*>           component 13 (enchantments): one entry, enchantment 5 at level 3
             MOVE 13 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
             MOVE 1 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
             MOVE 5 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
             MOVE 3 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
         END-IF
         IF L-KIND = 2
*>           component 3 (damage): 7
             MOVE 3 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
             MOVE 7 TO WS-V
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-V
         END-IF
     END-IF
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE MD-MD-END TO MD-MX-INDEX
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM GG-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GG-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM GG-SPAWN.
