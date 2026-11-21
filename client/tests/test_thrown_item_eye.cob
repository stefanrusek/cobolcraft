*> T43410 (lane 002-lane-buglocate3, operator try15: "using an ender eye doesn't throw it into the air"): the core makes the eye_of_ender entity and moves it (core/tests/test_eye_real),
*> but the client drew nothing for it: ThrownItemRenderer (docs/protocol/34-entity-models-9 section 7.1) was not implemented, so the eye was invisible. The eye of ender
*> (and the snowball, egg and ender pearl, which share the renderer) is drawn as the flat model of its item (the stack of the entity, default item when none was sent:
*> ender_eye, snowball, egg, ender_pearl): the quad of the dropped item without bob and spin (0.5 wide, y -0.125 to 0.375 of the ground transform of 12 section 8.2), facing the
*> camera (billboard), scale 1.0, both sides (12 vertices), block light 15 for the eye of ender (full bright), the normal light for the others. The generated vanilla pack is
*> read from CC_GENERATED_DIR (a pass without it).
*> After the merge with lane p70e (ENTITY-THROWN-EMIT, 34-9 section 7): one quad of 6 vertices turned to the camera's yaw, its size from the document's EF9-THROWN-QUAD;
*> the default item of a type without a sent stack stays.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-THROWN-ITEM-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-FILE                PIC X(300).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-K                   BINARY-LONG.
 01 WS-ROW-N               BINARY-LONG.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 01 WS-S0                  FLOAT-SHORT VALUE 0.
 01 WS-S16                 FLOAT-SHORT VALUE 16.
 01 WS-T0                  FLOAT-SHORT VALUE 0.
 01 WS-T16                 FLOAT-SHORT VALUE 16.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-MAX-Y               FLOAT-LONG.
 01 WS-MIN-Z               FLOAT-LONG.
 01 WS-MAX-Z               FLOAT-LONG.
 01 WS-MIN-U               FLOAT-LONG.
 01 WS-MAX-U               FLOAT-LONG.
 01 WS-MIN-V               FLOAT-LONG.
 01 WS-MAX-V               FLOAT-LONG.
 01 WS-EYE-POINT.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "T43410 thrown items: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO CL-NOW-MS
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 10.5 TO WS-X WS-Z
     MOVE 64 TO WS-Y
     MOVE 0 TO WS-YAW
     MOVE 64 TO WS-ID
     MOVE SPACES TO WS-KEY
     MOVE "eye_of_ender" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     CALL "TIE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
*>   the camera at the origin looking along +z (yaw 0, pitch 0): the eye of ender, no stack sent
     MOVE 0 TO WS-EYE(1) WS-EYE(2) WS-EYE(3)
     MOVE 0 TO RL-GI-COUNT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     MOVE "T43410 the eye_of_ender entity (no stack sent) is drawn: one quad of 6 vertices" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM MEASURE
     MOVE "T43410 the quad is 0.5 wide (x 10.25 to 10.75, in millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 500
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-MAX-X - WS-MIN-X) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the quad's left edge" TO TL-CASE
     MOVE 10250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MIN-X * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the quad's bottom is 0.125 below the entity position (y 63.875)" TO TL-CASE
     MOVE 63875 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MIN-Y * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the quad's top is 0.375 above it (y 64.375)" TO TL-CASE
     MOVE 64375 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MAX-Y * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 a camera looking along z: the billboard is flat in z (at the entity's z 10.5)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-MAX-Z - WS-MIN-Z) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 and at the entity's z" TO TL-CASE
     MOVE 10500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MIN-Z * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the sprite of the ender_eye item: the quad spans its whole icon in the atlas
     MOVE SPACES TO WS-KEY
     MOVE "ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-S0 WS-T0 WS-U0 WS-V0
     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-S16 WS-T16 WS-U1 WS-V1
     MOVE "T43410 the item's own icon is real (not the missing sprite 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SPRITE > 1
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the quad's u runs over the ender_eye icon (left, in 1/10000)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(FUNCTION MIN(WS-U0, WS-U1) * 10000 + 0.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MIN-U * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 (right)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(FUNCTION MAX(WS-U0, WS-U1) * 10000 + 0.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MAX-U * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the quad's v runs over the icon (top)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(FUNCTION MIN(WS-V0, WS-V1) * 10000 + 0.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MIN-V * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 (bottom)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(FUNCTION MAX(WS-V0, WS-V1) * 10000 + 0.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-MAX-V * 10000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   full bright: block light 15 whatever the sky (the clock is night here: SK-U 0), brightness 1
     MOVE "T43410 the eye of ender is full bright (brightness 1, in a dark world)" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(RL-GI-B(1) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the quad follows the camera: looking along +x (yaw 270 degrees) the quad is flat in x
     MOVE 270 TO PL-YAW
     MOVE 0 TO RL-GI-COUNT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     PERFORM MEASURE
     MOVE "T43410 a camera looking along x: the quad is flat in x" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-MAX-X - WS-MIN-X) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 and 0.5 wide in z" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-MAX-Z - WS-MIN-Z) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-YAW
*>   the snowball, egg and ender pearl use the same renderer with the normal light (0.1 at night, no block light)
     MOVE SPACES TO WS-KEY
     MOVE "snowball" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 65 TO WS-ID
     CALL "TIE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 0 TO RL-GI-COUNT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     MOVE "T43410 a snowball beside the eye adds 6 vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T43410 the snowball is not full bright (night: the cell's own light, 0; the ground items' floor of 0.1 is not the thrown items')" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(RL-GI-B(7) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-KEY
     MOVE "egg" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 66 TO WS-ID
     CALL "TIE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE SPACES TO WS-KEY
     MOVE "ender_pearl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 67 TO WS-ID
     CALL "TIE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 0 TO RL-GI-COUNT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     MOVE "T43410 the egg and the ender pearl too: 4 thrown items, 24 vertices" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a boat is not a thrown item
     MOVE SPACES TO WS-KEY
     MOVE "acacia_chest_boat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 68 TO WS-ID
     CALL "TIE-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 0 TO RL-GI-COUNT
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE-POINT
     MOVE "T43410 a boat adds nothing" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a full ground item mesh takes no more thrown item (its 6 vertices do not fit)
     COMPUTE RL-GI-COUNT = CL-MAX-GI-VERTICES - 5
     MOVE 1 TO WS-ROW-N
     CALL "ENTITY-THROWN-EMIT" USING CLIENT-STATE WS-ROW-N WS-EYE-POINT
     MOVE "T43410 a thrown item that does not fit the vertex budget is skipped" TO TL-CASE
     COMPUTE TL-EXPECTED-N = CL-MAX-GI-VERTICES - 5
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The extent of the first quad's 6 vertices (the eye of ender) in x, y, z, u and v.
 MEASURE.
     COMPUTE WS-MIN-X = RL-GI-X(1) + WS-EYE(1)
     MOVE WS-MIN-X TO WS-MAX-X
     COMPUTE WS-MIN-Y = RL-GI-Y(1) + WS-EYE(2)
     MOVE WS-MIN-Y TO WS-MAX-Y
     COMPUTE WS-MIN-Z = RL-GI-Z(1) + WS-EYE(3)
     MOVE WS-MIN-Z TO WS-MAX-Z
     MOVE RL-GI-U(1) TO WS-MIN-U
     MOVE WS-MIN-U TO WS-MAX-U
     MOVE RL-GI-V(1) TO WS-MIN-V
     MOVE WS-MIN-V TO WS-MAX-V
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 6
         PERFORM EXTEND-ONE
     END-PERFORM.

 EXTEND-ONE.
     IF RL-GI-X(WS-K) + WS-EYE(1) < WS-MIN-X
         COMPUTE WS-MIN-X = RL-GI-X(WS-K) + WS-EYE(1)
     END-IF
     IF RL-GI-X(WS-K) + WS-EYE(1) > WS-MAX-X
         COMPUTE WS-MAX-X = RL-GI-X(WS-K) + WS-EYE(1)
     END-IF
     IF RL-GI-Y(WS-K) + WS-EYE(2) < WS-MIN-Y
         COMPUTE WS-MIN-Y = RL-GI-Y(WS-K) + WS-EYE(2)
     END-IF
     IF RL-GI-Y(WS-K) + WS-EYE(2) > WS-MAX-Y
         COMPUTE WS-MAX-Y = RL-GI-Y(WS-K) + WS-EYE(2)
     END-IF
     IF RL-GI-Z(WS-K) + WS-EYE(3) < WS-MIN-Z
         COMPUTE WS-MIN-Z = RL-GI-Z(WS-K) + WS-EYE(3)
     END-IF
     IF RL-GI-Z(WS-K) + WS-EYE(3) > WS-MAX-Z
         COMPUTE WS-MAX-Z = RL-GI-Z(WS-K) + WS-EYE(3)
     END-IF
     IF RL-GI-U(WS-K) < WS-MIN-U
         MOVE RL-GI-U(WS-K) TO WS-MIN-U
     END-IF
     IF RL-GI-U(WS-K) > WS-MAX-U
         MOVE RL-GI-U(WS-K) TO WS-MAX-U
     END-IF
     IF RL-GI-V(WS-K) < WS-MIN-V
         MOVE RL-GI-V(WS-K) TO WS-MIN-V
     END-IF
     IF RL-GI-V(WS-K) > WS-MAX-V
         MOVE RL-GI-V(WS-K) TO WS-MAX-V
     END-IF.
 END PROGRAM TEST-THROWN-ITEM-EYE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TIE-SPAWN.
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
 END PROGRAM TIE-SPAWN.

 COPY CLTEST.
