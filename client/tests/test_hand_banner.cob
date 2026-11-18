*> T28500 (lane 002-lane-p70d): the banner in a hand in first person (54 section 22.3; 52 section 6). STACK-BANNER keeps banner_patterns (74) of a stack into the slot (MENU-PLAYER-SET);
*> HAND-BANNER-COLOUR names the dye of a `<colour>_banner` item; BANNER-PATTERN-NAME the 43 patterns of 31-3 section 3; ENTITY-TEX-PATH gives the sprite of a pattern (code 9000 + the holder);
*> ENTITIES-MESH gives a held banner its slots of the entity atlas; HAND-MESH draws the pole, the bar, the flag, the base colour layer and one flag per pattern (6 cuboids of 36 vertices for two
*> patterns) with the dye's diffuse colour as tint (43 section 6.3: red B02E26, blue 3C44AA, white F9FFFE), each layer 0.05 pixel nearer the viewer. Expected vertices from an independent script
*> (the arm transform, the display entry of template_banner rotation (0, 90, 0) scale 0.375, the local transform (0.5, 0, 0.5) x (2/3, -2/3, -2/3), the flag turned about X by -0.0025 pi about
*> its pivot (0, -44, 0)): the first vertex of the pole, the bar, the flag and each layer, and the pole's for the off hand (the display entry mirrored). A code-drawn model that is no banner draws nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-BANNER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY PROTO.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-RED                 BINARY-LONG.
 01 WS-WHITE               BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HD                  PIC 99.
 01 WS-NAME24              PIC X(24).
 01 WS-HOLDER              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-PATH                PIC X(64).
 01 WS-INDEX               BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-NAME                PIC X(100).
 01 WS-ARG                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES VALUE 0.
 01 WS-UV.
    05 WS-U4               FLOAT-SHORT OCCURS 4 TIMES VALUE 0.
    05 WS-V4               FLOAT-SHORT OCCURS 4 TIMES VALUE 0.
 01 WS-NORMAL.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-LIGHT               FLOAT-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG VALUE 3.
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
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA PL-MODE
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "red_banner" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-RED WS-ITEM-ROW WS-STATUS
     MOVE "white_banner" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-WHITE WS-ITEM-ROW WS-STATUS
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
*>   The colour of a banner item: red 14, white 0; a stick, an unknown id and no item are none.
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-RED WS-DYE
     MOVE "T28500 a red banner item is dye 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-WHITE WS-DYE
     MOVE "T28500 a white banner item is dye 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-STICK WS-DYE
     MOVE "T28500 a stick is no banner" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5000 TO WS-ID
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ID WS-DYE
     MOVE "T28500 an unknown item is no banner" TO TL-CASE
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-ID
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ID WS-DYE
     MOVE "T28500 no item is no banner" TO TL-CASE
     MOVE WS-DYE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The pattern ids of 31-3 section 3.
     MOVE "T" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         EVALUATE WS-I
             WHEN 1 MOVE 1 TO WS-HOLDER
                    MOVE "base" TO TL-EXPECTED
             WHEN 2 MOVE 5 TO WS-HOLDER
                    MOVE "creeper" TO TL-EXPECTED
             WHEN 3 MOVE 25 TO WS-HOLDER
                    MOVE "skull" TO TL-EXPECTED
             WHEN 4 MOVE 32 TO WS-HOLDER
                    MOVE "stripe_bottom" TO TL-EXPECTED
             WHEN 5 MOVE 43 TO WS-HOLDER
                    MOVE "triangles_top" TO TL-EXPECTED
             WHEN 6 MOVE 0 TO WS-HOLDER
                    MOVE SPACES TO TL-EXPECTED
             WHEN OTHER MOVE 44 TO WS-HOLDER
                    MOVE SPACES TO TL-EXPECTED
         END-EVALUATE
         CALL "BANNER-PATTERN-NAME" USING WS-HOLDER WS-NAME24
         MOVE WS-HOLDER TO WS-HD
         MOVE SPACES TO TL-CASE
         STRING "T28500 the pattern of holder " WS-HD DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-NAME24 TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The sprite path of a pattern code.
     MOVE "banner" TO WS-NAME24
     MOVE 9032 TO WS-CODE
     CALL "ENTITY-TEX-PATH" USING WS-NAME24 WS-CODE WS-PATH
     MOVE "T28500 the sprite of holder 32 is entity/banner/stripe_bottom" TO TL-CASE
     MOVE "textures/entity/banner/stripe_bottom.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9001 TO WS-CODE
     CALL "ENTITY-TEX-PATH" USING WS-NAME24 WS-CODE WS-PATH
     MOVE "T28500 the sprite of the base layer is entity/banner/base" TO TL-CASE
     MOVE "textures/entity/banner/base.png" TO TL-EXPECTED
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   STACK-BANNER: no component; two layers (holder 32 dye 11, holder 2 dye 0); an inline pattern; a two-byte count.
     MOVE 1 TO PB-ISX-COUNT
     MOVE 0 TO PB-ISX-ADDED-COUNT
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE "T28500 a stack with no banner_patterns has no layers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-STACK-BN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 74 TO PB-ISX-TYPE(1)
     MOVE 5 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"02200B0200" TO PB-ISX-VALUE(1)(1:5)
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE "T28500 banner_patterns with two layers: the count" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-STACK-BN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28500 the holders and dyes of the two layers" TO TL-CASE
     MOVE 32110200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-STACK-BN-PAT(1) * 1000000 + PL-STACK-BN-DYE(1) * 10000 + PL-STACK-BN-PAT(2) * 100 + PL-STACK-BN-DYE(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The slot takes the layers of the stack set into it: slot 0 of the hotbar (1) and the off hand (37), and loses them with the stack.
     MOVE 0 TO WS-ARG
     MOVE 1 TO WS-COUNT
     MOVE WS-RED TO WS-ID
     MOVE 0 TO WS-DAMAGE
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE "T28500 the main hand's slot keeps the layers" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-BN-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 37 TO WS-ARG
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE "T28500 the off hand keeps the layers" TO TL-CASE
     MOVE PL-SLOT-BN-COUNT(37) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE "T28500 emptying the off hand clears its layers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-BN-COUNT(37) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ARG
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE "T28500 emptying the main hand's slot clears its layers" TO TL-CASE
     MOVE PL-SLOT-BN-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE 0 TO WS-COUNT
     CALL "MENU-STACK-PUT" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE "T28500 emptying the slot with MENU-STACK-PUT clears its layers" TO TL-CASE
     MOVE PL-SLOT-BN-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 8 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"0100026162016305" TO PB-ISX-VALUE(1)(1:8)
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE "T28500 an inline pattern is kept as a layer with holder 0 and its dye" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-STACK-BN-COUNT * 100 + PL-STACK-BN-PAT(1) * 10 + PL-STACK-BN-DYE(1) - 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"8001" TO PB-ISX-VALUE(1)(1:2)
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE "T28500 a count of 128 or more (a two-byte VarInt) keeps no layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-STACK-BN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A red banner in the main hand with two layers: stripe_bottom in blue (11) and border in white (0). The slots of the sprites and the mesh.
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 5 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"02200B0200" TO PB-ISX-VALUE(1)(1:5)
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE 0 TO WS-ARG
     MOVE 1 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-RED WS-DAMAGE
     MOVE 0 TO PL-HELD
     COMPUTE CL-HAND-ITEM = WS-RED + 1
     MOVE CL-HAND-ITEM TO CL-ATK-LAST
     MOVE 100 TO CL-ATK-TICKER
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 0 TO CL-OHAND-ITEM CL-SWING-AT CL-BOB-INIT EF-COUNT
     MOVE 3000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "banner" TO WS-KEY
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     MOVE 0 TO WS-SLOTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EA-MT-COUNT
         IF EA-MT-MODEL(WS-I) = WS-ROW
             ADD 1 TO WS-SLOTS
         END-IF
     END-PERFORM
     MOVE "T28500 a held banner with two layers takes four atlas slots (banner_base, base, two patterns)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-SLOTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28500 the banner mesh: pole, bar, flag, base layer and two patterns, 6 cuboids of 36 vertices" TO TL-CASE
     MOVE 216 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28500 the banner adds nothing to the item mesh" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-INDEX
     MOVE 0.54438 TO WS-EX
     MOVE -0.05125 TO WS-EY
     MOVE -0.73562 TO WS-EZ
     MOVE "T28500 the first vertex of the pole" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 37 TO WS-INDEX
     MOVE 0.54438 TO WS-EX
     MOVE -0.02 TO WS-EY
     MOVE -0.87625 TO WS-EZ
     MOVE "T28500 the first vertex of the bar" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 73 TO WS-INDEX
     MOVE 0.57562 TO WS-EX
     MOVE -0.01988 TO WS-EY
     MOVE -0.87625 TO WS-EZ
     MOVE "T28500 the first vertex of the flag (turned about X by -0.0025 pi)" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 109 TO WS-INDEX
     MOVE 0.57641 TO WS-EX
     MOVE -0.01987 TO WS-EY
     MOVE -0.87625 TO WS-EZ
     MOVE "T28500 the base colour layer lies 0.05 pixel in front of the flag" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 145 TO WS-INDEX
     MOVE 0.57719 TO WS-EX
     MOVE -0.01987 TO WS-EY
     MOVE -0.87625 TO WS-EZ
     MOVE "T28500 the first pattern lies 0.1 pixel in front" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 181 TO WS-INDEX
     MOVE 0.57797 TO WS-EX
     MOVE -0.01986 TO WS-EY
     MOVE -0.87625 TO WS-EZ
     MOVE "T28500 the second pattern lies 0.15 pixel in front" TO WS-NAME
     PERFORM CHECK-VERTEX
*>   Tints: the pole, bar and flag untinted; the base colour layer red; the first pattern blue; the second white.
     MOVE 1 TO WS-INDEX
     MOVE 1 TO WS-EX WS-EY WS-EZ
     MOVE "T28500 the pole is untinted" TO WS-NAME
     PERFORM CHECK-TINT
     MOVE 73 TO WS-INDEX
     MOVE "T28500 the flag with the banner sprite is untinted" TO WS-NAME
     PERFORM CHECK-TINT
     MOVE 109 TO WS-INDEX
     MOVE 0.6902 TO WS-EX
     MOVE 0.1804 TO WS-EY
     MOVE 0.1490 TO WS-EZ
     MOVE "T28500 the base colour layer is tinted red B02E26" TO WS-NAME
     PERFORM CHECK-TINT
     MOVE 145 TO WS-INDEX
     MOVE 0.2353 TO WS-EX
     MOVE 0.2667 TO WS-EY
     MOVE 0.6667 TO WS-EZ
     MOVE "T28500 the first pattern is tinted blue 3C44AA" TO WS-NAME
     PERFORM CHECK-TINT
     MOVE 181 TO WS-INDEX
     MOVE 0.9765 TO WS-EX
     MOVE 1 TO WS-EY
     MOVE 0.9961 TO WS-EZ
     MOVE "T28500 the second pattern is tinted white F9FFFE" TO WS-NAME
     PERFORM CHECK-TINT
*>   The off hand: the same banner, the display entry mirrored (rotation y -90): the pole's first vertex.
     MOVE 0 TO CL-HAND-ITEM
     MOVE 0 TO PL-SLOT-COUNT(1)
     MOVE 37 TO WS-ARG
     MOVE 1 TO WS-COUNT
     MOVE WS-RED TO WS-ID
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-ID WS-DAMAGE
     MOVE 1 TO PL-OFFHAND-COUNT
     MOVE WS-RED TO PL-OFFHAND-ITEM
     COMPUTE CL-OHAND-ITEM = WS-RED + 1
     MOVE 1 TO CL-OHAND-H CL-OHAND-OH
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28500 an off hand banner is drawn too (the empty main hand adds its arm: 72 vertices before)" TO TL-CASE
     MOVE 288 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 73 TO WS-INDEX
     MOVE -0.54438 TO WS-EX
     MOVE -0.05125 TO WS-EY
     MOVE -0.70437 TO WS-EZ
     MOVE "T28500 the off hand banner's pole (after the arm's 72 vertices) is at the left, the entry mirrored" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 0 TO PL-OFFHAND-COUNT CL-OHAND-ITEM
*>   An inline pattern draws no layer (3 cuboids and the base layer: 144); another code-drawn model (a chest) draws nothing at all.
     MOVE 1 TO PB-ISX-ADDED-COUNT
     MOVE 8 TO PB-ISX-VALUE-LENGTH(1)
     MOVE X"0100026162016305" TO PB-ISX-VALUE(1)(1:8)
     CALL "STACK-BANNER" USING PB-ITEMSTACK-X PL-STACK-BN
     MOVE 0 TO WS-ARG
     MOVE 1 TO WS-COUNT
     CALL "MENU-PLAYER-SET" USING CLIENT-STATE WS-ARG WS-COUNT WS-RED WS-DAMAGE
     COMPUTE CL-HAND-ITEM = WS-RED + 1
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28500 an inline pattern layer is not drawn: pole, bar, flag and the base layer" TO TL-CASE
     MOVE 144 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CL-HAND-ITEM = WS-CHEST + 1
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28500 a chest, another code-drawn model, draws nothing in the hand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-HA-COUNT + RL-HAND-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A held banner with no atlas slot for the banner model draws nothing.
     MOVE 0 TO EA-MT-COUNT
     COMPUTE CL-HAND-ITEM = WS-RED + 1
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28500 a banner whose sprites have no atlas slot draws nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full glint mesh of the hand (4096 vertices) takes no more quad of a foil item.
     MOVE 4092 TO RL-HG-COUNT
     MOVE 0 TO RL-HAND-COUNT
     MOVE 1 TO WS-MODE
     CALL "HAND-M-IDENT" USING WS-M
     CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-UV WS-NORMAL WS-LIGHT WS-MODE
     MOVE "T28500 a full glint mesh of the hand takes no more quad" TO TL-CASE
     MOVE 4092 TO TL-EXPECTED-N
     MOVE RL-HG-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-MODE
*>   A full arm mesh takes no more quads.
     MOVE 1020 TO RL-HA-COUNT
     CALL "HAND-M-IDENT" USING WS-M
     CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-UV WS-NORMAL WS-LIGHT WS-MODE
     MOVE "T28500 a full mesh of the arm and banner (1024 vertices) takes no more quad" TO TL-CASE
     MOVE 1020 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     STOP RUN.

*> Vertex WS-INDEX of the arm and banner mesh is at (WS-EX, WS-EY, WS-EZ) within 0.0003.
 CHECK-VERTEX.
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RL-HA-X(WS-INDEX) - WS-EX) < 0.0003 AND FUNCTION ABS(RL-HA-Y(WS-INDEX) - WS-EY) < 0.0003
             AND FUNCTION ABS(RL-HA-Z(WS-INDEX) - WS-EZ) < 0.0003
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Vertex WS-INDEX has the tint (WS-EX, WS-EY, WS-EZ) within 0.001.
 CHECK-TINT.
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RL-HA-R(WS-INDEX) - WS-EX) < 0.001 AND FUNCTION ABS(RL-HA-G(WS-INDEX) - WS-EY) < 0.001
             AND FUNCTION ABS(RL-HA-BLUE(WS-INDEX) - WS-EZ) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HAND-BANNER.

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
