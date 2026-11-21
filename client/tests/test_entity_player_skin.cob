 *> Implementation test of the skin of another player on the client (T51007, T51214; docs/protocol/47 sections 2.2, 5 and 6, 12 section 7.4):
*> a player replica row draws with the skin that PLAYER-SKIN-FOR-UUID names for its UUID (the texture code is the skin index plus 1, the image is
*> textures/entity/player/<wide or slim>/<name>.png), on the slim model (3 pixel arms, row "player_slim") when the skin is slim, and shows the overlay
*> layers (hat, jacket, sleeves, pants) of the skin parts byte of Set Entity Data entry 16 (default 0: no overlay, 47 section 5.3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-PLAYER-SKIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-PLAYER-ID           BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW1                BINARY-LONG VALUE 1.
 01 WS-ROW2                BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-LAST-BYTE           BINARY-LONG.
 01 WS-PARTS               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-WIDTH-WIDE          BINARY-LONG.
 01 WS-WIDTH-SLIM          BINARY-LONG.
 01 WS-COUNT-0             BINARY-LONG.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-WIDE-MODEL          BINARY-LONG.
 01 WS-SLIM-MODEL          BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HAVE-WIDE           BINARY-LONG.
 01 WS-HAVE-SLIM           BINARY-LONG.
 01 WS-WIDTH-WIDE-0        BINARY-LONG.
 01 WS-WIDTH-SLIM-0        BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-KEY20               PIC X(20).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U PL-YAW
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     MOVE SPACES TO WS-KEY
     MOVE "player" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PLAYER-ID WS-ROW-AREA WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 10.5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 12.5 TO WS-Z
*>   Entity 5 has the UUID whose hashCode is 13 (wide skin, index 13: makena); entity 6 hashCode 0 (slim skin, index 0: alex).
     MOVE 5 TO WS-ID
     MOVE 13 TO WS-LAST-BYTE
     CALL "EPS-SPAWN" USING CLIENT-STATE WS-ID WS-PLAYER-ID WS-X WS-Y WS-Z WS-LAST-BYTE
     MOVE 6 TO WS-ID
     MOVE 0 TO WS-LAST-BYTE
     MOVE 14.5 TO WS-X
     CALL "EPS-SPAWN" USING CLIENT-STATE WS-ID WS-PLAYER-ID WS-X WS-Y WS-Z WS-LAST-BYTE

     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-ROW1 WS-MODEL
     MOVE WS-MODEL TO WS-WIDE-MODEL
     MOVE "player skin a wide UUID is drawn from the row player" TO TL-CASE
     MOVE "player" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-ROW1 WS-MODEL WS-CODE
     MOVE "N" TO TL-MODE
     MOVE "player skin a wide UUID has the texture code index + 1 (14)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player" TO WS-KEY20
     CALL "ENTITY-TEX-PATH" USING WS-KEY20 WS-CODE WS-PATH
     MOVE "T" TO TL-MODE
     MOVE "player skin the wide skin image is the makena file" TO TL-CASE
     MOVE "textures/entity/player/wide/makena.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "ENTITY-MODEL-ROW" USING CLIENT-STATE WS-ROW2 WS-MODEL
     MOVE WS-MODEL TO WS-SLIM-MODEL
     MOVE "player skin a slim UUID is drawn from the row player_slim" TO TL-CASE
     MOVE "player_slim" TO TL-EXPECTED
     MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-ROW2 WS-MODEL WS-CODE
     MOVE "N" TO TL-MODE
     MOVE "player skin a slim UUID has the texture code 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player_slim" TO WS-KEY20
     CALL "ENTITY-TEX-PATH" USING WS-KEY20 WS-CODE WS-PATH
     MOVE "T" TO TL-MODE
     MOVE "player skin the slim skin image is the alex file" TO TL-CASE
     MOVE "textures/entity/player/slim/alex.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The width of the drawn figure (arms included) in thousandths of a block. The idle arm sway (12 section 7.5) widens both alike, so the slim figure is compared with the
*>   wide one: a slim arm is 1 pixel narrower on the outer side, 2 pixels in all = 117 thousandths (0.9375 / 16 a pixel), within the thousandth rounding of the vertices.
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE RL-EN-COUNT TO WS-LAST
     CALL "EPS-WIDTHS" USING CLIENT-STATE WS-FIRST WS-LAST WS-WIDTH-WIDE WS-WIDTH-SLIM
*>   Each skin has its atlas slot of (model row, texture code): the wide skin 14 on the wide row, the slim skin 1 on the slim row.
     MOVE 0 TO WS-HAVE-WIDE WS-HAVE-SLIM
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
         IF EA-MT-MODEL(WS-S) = WS-WIDE-MODEL AND EA-MT-TEX(WS-S) = 14
             MOVE 1 TO WS-HAVE-WIDE
         END-IF
         IF EA-MT-MODEL(WS-S) = WS-SLIM-MODEL AND EA-MT-TEX(WS-S) = 1
             MOVE 1 TO WS-HAVE-SLIM
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "player skin the wide skin (code 14) has an entity atlas slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAVE-WIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player skin the slim skin (code 1) has an entity atlas slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAVE-SLIM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player skin the slim figure is 2 pixels (117 thousandths) narrower than the wide one" TO TL-CASE
     MOVE 117 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-WIDTH-WIDE - WS-WIDTH-SLIM
     IF TL-OBSERVED-N >= 112 AND TL-OBSERVED-N <= 132
         MOVE 117 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-WIDTH-WIDE TO WS-WIDTH-WIDE-0
     MOVE WS-WIDTH-SLIM TO WS-WIDTH-SLIM-0
     MOVE RL-EN-COUNT TO WS-COUNT-0

*>   Skin parts: entry 16 of every player (127: all seven bits); the six overlay cuboids add 6 x 36 vertices, and the grown sleeves widen both figures by 0.5 pixel a side.
     MOVE 5 TO WS-ID
     MOVE 127 TO WS-PARTS
     CALL "EPS-PARTS" USING CLIENT-STATE WS-ID WS-PARTS
     MOVE 6 TO WS-ID
     CALL "EPS-PARTS" USING CLIENT-STATE WS-ID WS-PARTS
     MOVE "player skin Set Entity Data entry 16 keeps the skin parts byte" TO TL-CASE
     MOVE 127 TO TL-EXPECTED-N
     MOVE EN-PARTS(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE RL-EN-COUNT TO WS-LAST
     CALL "EPS-WIDTHS" USING CLIENT-STATE WS-FIRST WS-LAST WS-WIDTH-WIDE WS-WIDTH-SLIM
     MOVE "player skin all seven parts on: six overlay cuboids of 36 vertices a player" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT-0 + 2 * 6 * 36
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player skin the sleeves (grown 0.25 pixel) widen the wide figure by 0.5 pixel (29 thousandths)" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-WIDTH-WIDE - WS-WIDTH-WIDE-0
     IF TL-OBSERVED-N >= 24 AND TL-OBSERVED-N <= 44
         MOVE 29 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "player skin the sleeves widen the slim figure by 0.5 pixel (29 thousandths)" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-WIDTH-SLIM - WS-WIDTH-SLIM-0
     IF TL-OBSERVED-N >= 24 AND TL-OBSERVED-N <= 44
         MOVE 29 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Only the hat bit (0x40): one overlay cuboid for each player.
     MOVE 64 TO WS-PARTS
     MOVE 5 TO WS-ID
     CALL "EPS-PARTS" USING CLIENT-STATE WS-ID WS-PARTS
     MOVE 6 TO WS-ID
     CALL "EPS-PARTS" USING CLIENT-STATE WS-ID WS-PARTS
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "player skin only the hat part on: one overlay cuboid a player" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT-0 + 2 * 36
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The options' skin parts (47 section 5.2): all seven on by default (127); the option modelPart_hat set to false takes the hat bit (0x40) off.
     CALL "PLAYER-PARTS-OPTIONS" USING CLIENT-STATE WS-PARTS
     MOVE "player skin the skin parts of the default options are all seven bits (127)" TO TL-CASE
     MOVE 127 TO TL-EXPECTED-N
     MOVE WS-PARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The local player's own figure (third-person camera) has its overlays by the options: 12 cuboids of 36 vertices with all seven parts, one less without the hat.
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE 0 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-COUNT-0
     MOVE 1 TO CL-CAMERA
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "player skin the local figure in the third-person view has 12 cuboids (432 vertices)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT-0 + 12 * 36
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "modelPart_hat" TO WS-OPT-NAME
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "PLAYER-PARTS-OPTIONS" USING CLIENT-STATE WS-PARTS
     MOVE "player skin the option modelPart_hat false takes the hat bit off (63)" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     MOVE WS-PARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "player skin the local figure without the hat part has 11 cuboids (396 vertices)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-COUNT-0 + 11 * 36
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-PLAYER-SKIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EPS-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), last UUID byte (the UUID is zero but for it, so its hashCode is that byte): Add Entity at rest.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16).
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
 01 L-LAST                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-LAST.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE LOW-VALUES TO WS-UUID
     MOVE FUNCTION CHAR(L-LAST + 1) TO WS-UUID(16:1)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM EPS-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EPS-PARTS.
*> USING CLIENT-STATE, entity id, parts: Set Entity Data with entry 16 (BYTE, the skin parts of a player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-PARTS                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-PARTS.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 16 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE L-PARTS TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM EPS-PARTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EPS-WIDTHS.
*> USING CLIENT-STATE, first and last entity vertex, width of the figure at x below 2.5 (the wide player, 0.5 from the eye) out, width of the one above it (the slim player, 4.5 from the eye) out, in thousandths.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-LO1                 BINARY-LONG.
 01 WS-HI1                 BINARY-LONG.
 01 WS-LO2                 BINARY-LONG.
 01 WS-HI2                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-WIDE                 BINARY-LONG.
 01 L-SLIM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FIRST L-LAST L-WIDE L-SLIM.
     MOVE 999999999 TO WS-LO1 WS-LO2
     MOVE -999999999 TO WS-HI1 WS-HI2
     PERFORM VARYING WS-I FROM L-FIRST BY 1 UNTIL WS-I > L-LAST
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-X(WS-I) * 1000 + 0.5)
         IF RL-EN-X(WS-I) < 2.5
             MOVE FUNCTION MIN(WS-LO1, WS-V) TO WS-LO1
             MOVE FUNCTION MAX(WS-HI1, WS-V) TO WS-HI1
         ELSE
             MOVE FUNCTION MIN(WS-LO2, WS-V) TO WS-LO2
             MOVE FUNCTION MAX(WS-HI2, WS-V) TO WS-HI2
         END-IF
     END-PERFORM
     COMPUTE L-WIDE = WS-HI1 - WS-LO1
     COMPUTE L-SLIM = WS-HI2 - WS-LO2
     GOBACK.
 END PROGRAM EPS-WIDTHS.
