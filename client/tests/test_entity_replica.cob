*> The entity replica (client/src/entities-replica.cob, hud-packets.cob) for the entity packet set of 05a 0x01 Add Entity, 05b 0x65 Set Entity Data (the fixture with
*> one entry of each of the 44 serializers of 00 section 13.2) and 05b 0x86 Update Attributes: an entity is added with its type, position, angles and the default
*> scale attribute 1; the flags (entry 0) and the pose (entry 6) of Set Entity Data and the variant entry of a wolf (entry 23, after twenty-three other serializers) are
*> kept and a list for an entity the replica does not know changes nothing; Update Attributes keeps the scale attribute (id 30; the final value of its modifiers
*> in the order of the packet: operation 0, 1, then 2; clamped to 0.0625 .. 16) of a known entity only, and the renderer draws the model at that scale (34-1 6.3
*> state.scale), except a slime or magma cube, whose size is its entry 18.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-REPLICA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY PROTO.
 COPY PBENT.
 COPY PBATTR.
 COPY TESTLIB.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-SPAN1               FLOAT-LONG.
 01 WS-SPAN2               FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-SET-DATA            BINARY-LONG VALUE 101.
 01 WS-ATTRIBUTES          BINARY-LONG VALUE 134.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
*>   Add Entity: id 300, type 2, position (1.5, 64, -2.5), pitch 45, yaw 90, head yaw 180.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 300 TO PB-SP-ENTITY
     MOVE LOW-VALUES TO PB-SP-UUID
     MOVE 2 TO PB-SP-TYPE
     MOVE 1.5 TO PB-SP-X
     MOVE 64 TO PB-SP-Y
     MOVE -2.5 TO PB-SP-Z
     MOVE 0 TO PB-SP-MOVE-X PB-SP-MOVE-Y PB-SP-MOVE-Z
     MOVE 45 TO PB-SP-PITCH
     MOVE 90 TO PB-SP-YAW
     MOVE -180 TO PB-SP-HEAD-YAW
     MOVE 0 TO PB-SP-DATA
     CALL "PB-PUT-SPAWN-ENTITY" USING PB-BUFFER PB-SPAWN
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     MOVE 300 TO WS-ID
     CALL "ENTITY-FIND" USING CLIENT-STATE WS-ID WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "acceptance entity replica Add Entity: the entity is known" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: the type" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-TYPE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: x times 100" TO TL-CASE
     MOVE 150 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-ROW) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: z times 100" TO TL-CASE
     MOVE -250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Z(WS-ROW) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: yaw 90 degrees" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-YAW(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: pitch 45 degrees" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-PITCH(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Add Entity: the scale attribute starts at 1" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-ATTR-SCALE(WS-ROW) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Set Entity Data with one entry of each serializer (entity 300): flags 0x20 at entry 0, and the wolf's variant at entry 23 (serializer 23, id 3).
     MOVE "wolf" TO EN-KEY(WS-ROW)
     MOVE "contract/fixtures/wire/play-s2c-65-set-entity-data-all-serializers.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance entity replica Set Entity Data: the flags byte (entry 0)" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE EN-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Set Entity Data: the wolf variant entry read past 23 serializers" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-VAR(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The pose (entry 6, serializer POSE 20), built with the proto writer.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 300 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     MOVE 6 TO PB-MX-INDEX
     MOVE 20 TO PB-MX-SERIALIZER
     MOVE 5 TO PB-MX-INT
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER PB-METADATA-ENTRY-X
     MOVE PB-MD-END TO PB-MX-INDEX
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER PB-METADATA-ENTRY-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-SET-DATA
     MOVE "acceptance entity replica Set Entity Data: the pose crouching (entry 6)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A list for entity 301, which was never added, changes nothing (the flags of 300 stay).
     MOVE EN-COUNT TO WS-BEFORE
     MOVE "contract/fixtures/wire/play-s2c-65-set-entity-data-living.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance entity replica Set Entity Data of an unknown entity adds no row" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance entity replica Set Entity Data of an unknown entity leaves the others" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE EN-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Update Attributes (fixture: entity 300, max_health and movement_speed): the scale stays 1.
     MOVE "contract/fixtures/wire/play-s2c-86-update-attributes.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     MOVE "acceptance entity replica Update Attributes without a scale snapshot keeps scale 1" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-ATTR-SCALE(WS-ROW) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Update Attributes with a scale snapshot: base 2, +0.5 (operation 0), + 20 percent of the base (operation 1), x 1.5 (operation 2) = 4.5.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "PB-RESET" USING PB-BUFFER
         MOVE 300 TO PB-AT-ENTITY
         IF WS-I = 6
             MOVE 999 TO PB-AT-ENTITY
         END-IF
         MOVE 1 TO PB-AT-COUNT
         MOVE 30 TO PB-AT-ATTRIBUTE(1)
         MOVE 2 TO PB-AT-BASE(1)
         MOVE 0 TO PB-AT-MOD-COUNT(1)
         EVALUATE WS-I
             WHEN 1
                 MOVE 3 TO PB-AT-MOD-COUNT(1)
                 MOVE "minecraft:a" TO PB-AT-MOD-ID(1, 1)
                 MOVE 11 TO PB-AT-MOD-ID-LENGTH(1, 1)
                 MOVE 0.5 TO PB-AT-MOD-AMOUNT(1, 1)
                 MOVE 0 TO PB-AT-MOD-OPERATION(1, 1)
                 MOVE "minecraft:b" TO PB-AT-MOD-ID(1, 2)
                 MOVE 11 TO PB-AT-MOD-ID-LENGTH(1, 2)
                 MOVE 0.2 TO PB-AT-MOD-AMOUNT(1, 2)
                 MOVE 1 TO PB-AT-MOD-OPERATION(1, 2)
                 MOVE "minecraft:c" TO PB-AT-MOD-ID(1, 3)
                 MOVE 11 TO PB-AT-MOD-ID-LENGTH(1, 3)
                 MOVE 0.5 TO PB-AT-MOD-AMOUNT(1, 3)
                 MOVE 2 TO PB-AT-MOD-OPERATION(1, 3)
             WHEN 2
                 MOVE 100 TO PB-AT-BASE(1)
             WHEN 3
                 MOVE 0 TO PB-AT-BASE(1)
             WHEN 4
                 MOVE 1 TO PB-AT-BASE(1)
             WHEN 5
                 MOVE 26 TO PB-AT-ATTRIBUTE(1)
                 MOVE 9 TO PB-AT-BASE(1)
             WHEN OTHER
                 MOVE 7 TO PB-AT-BASE(1)
         END-EVALUATE
         CALL "PB-PUT-UPDATE-ATTRIBUTES" USING PB-BUFFER PB-ATTRIBUTES
         MOVE 0 TO PB-POS
         CALL "PROTO-PACKET" USING CLIENT-STATE WS-CONN PB-BUFFER WS-ATTRIBUTES
         MOVE "N" TO TL-MODE
         EVALUATE WS-I
             WHEN 1
                 MOVE "acceptance entity replica Update Attributes scale 2 + 0.5, + 20 percent, x 1.5 is 4.5" TO TL-CASE
                 MOVE 450 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "acceptance entity replica Update Attributes scale 100 is clamped to 16" TO TL-CASE
                 MOVE 1600 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "acceptance entity replica Update Attributes scale 0 is clamped to 0.0625" TO TL-CASE
                 MOVE 6 TO TL-EXPECTED-N
             WHEN 4
                 MOVE "acceptance entity replica Update Attributes scale 1" TO TL-CASE
                 MOVE 100 TO TL-EXPECTED-N
             WHEN 5
                 MOVE "acceptance entity replica Update Attributes of another attribute (26) keeps the scale" TO TL-CASE
                 MOVE 100 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "acceptance entity replica Update Attributes of an unknown entity changes nothing" TO TL-CASE
                 MOVE 100 TO TL-EXPECTED-N
         END-EVALUATE
         COMPUTE TL-OBSERVED-N ROUNDED = EN-ATTR-SCALE(WS-ROW) * 100
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The renderer draws the model at the scale attribute: the vertical span of a pig at scale 2 is twice that at scale 1; a slime ignores it.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO EA-MT-COUNT
         IF WS-I = 3
             MOVE "slime" TO WS-KEY
         ELSE
             MOVE "pig" TO WS-KEY
         END-IF
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         PERFORM MEASURE-SPAN
         MOVE WS-HI TO WS-SPAN1
         MOVE 2 TO EN-ATTR-SCALE(1)
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         PERFORM MEASURE-SPAN
         MOVE WS-HI TO WS-SPAN2
         MOVE "N" TO TL-MODE
         IF WS-I = 3
             MOVE "acceptance entity replica a slime is not scaled by the scale attribute (span x 100)" TO TL-CASE
             COMPUTE TL-EXPECTED-N ROUNDED = WS-SPAN1 * 100
         ELSE
             MOVE "acceptance entity replica the scale attribute multiplies the model (span x 100)" TO TL-CASE
             COMPUTE TL-EXPECTED-N ROUNDED = WS-SPAN1 * 200
             IF WS-I = 2
                 MOVE "acceptance entity replica the scale attribute multiplies the model again (span x 100)" TO TL-CASE
             END-IF
         END-IF
         COMPUTE TL-OBSERVED-N ROUNDED = WS-SPAN2 * 100
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

 MEASURE-SPAN.
     MOVE 1000 TO WS-LO
     MOVE -1000 TO WS-HI
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > RL-EN-COUNT
         IF RL-EN-Y(WS-ID) < WS-LO
             MOVE RL-EN-Y(WS-ID) TO WS-LO
         END-IF
         IF RL-EN-Y(WS-ID) > WS-HI
             MOVE RL-EN-Y(WS-ID) TO WS-HI
         END-IF
     END-PERFORM
     COMPUTE WS-HI = WS-HI - WS-LO
     MOVE 1 TO WS-ID.
 END PROGRAM TEST-ENTITY-REPLICA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
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
 END PROGRAM MM-SPAWN.

 COPY CLTEST.
