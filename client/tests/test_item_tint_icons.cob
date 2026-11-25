*> Test of the item tints on the icons (lane bugguiitems, T59710; docs/protocol/43 section 7 and 7.1, 08 section 5.8 "layer n uses tint index n", 12 section 8.1): a slot of UI-RENDER holding an item of
*> the generated vanilla pack (CC_GENERATED_DIR) draws its icon quads in the colour of the tint of their layer: the leaves cube in the constant of the item definition, the grass block's top in the
*> grass colormap colour of (0.5, 1.0) while its other faces stay white, a leather helmet's layer 0 in the dye default or the stack's dyed_color with its overlay layer white, a potion's layer 0 in the colour
*> of its potion (the default blue without one) with the bottle white, a firework star's second layer in the explosion default; an apple, dirt and a spawn egg (no tints) stay white. The flat icon of an
*> item with a second layer has two quads (IS-LAYER1 of ITEM-SPRITE-OF).
*> CC-0016: the shade of a 3D cube's face (12 section 6.10, 8.1: up 1.0, east 0.7459, north 0.6797 under ITEMS_3D, worked by client/tests/fixtures/gen_item_gui.py) is in the vertex colour (vertexColor = colour.rgb
*> x lightAccum; the UI pipeline ignores the vertex brightness), so a vertex's colour is the layer's tint times its face's shade (flat icons have the shade 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-TINT-ICONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-EXP-R               BINARY-LONG.
 01 WS-EXP-G               BINARY-LONG.
 01 WS-EXP-B               BINARY-LONG.
 01 WS-GOT-R               BINARY-LONG.
 01 WS-GOT-G               BINARY-LONG.
 01 WS-GOT-B               BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MAP                 BINARY-LONG VALUE 1.
 01 WS-TEMP                COMP-2 VALUE 0.5.
 01 WS-DOWN                COMP-2 VALUE 1.0.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-TINTED              BINARY-LONG.
 01 WS-SHADE               BINARY-LONG VALUE 10000.
 01 WS-SHADE-TABLE.
    05 WS-SH               BINARY-LONG OCCURS 3 TIMES.
 01 WS-FACE-MATCH          BINARY-LONG OCCURS 3 TIMES.
 01 WS-EXP-SR              BINARY-LONG.
 01 WS-EXP-SG              BINARY-LONG.
 01 WS-EXP-SB              BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
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
     CALL "TINT-MAPS-LOAD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 1 TO CL-GUI-SCALE
     MOVE 1 TO SM-WIDGET-COUNT
     MOVE WK-SLOT TO SM-W-KIND(1)
     MOVE 0 TO SM-W-ARG(1) SM-W-STATE(1)
     MOVE 10 TO SM-W-X(1) SM-W-Y(1)
     MOVE 18 TO SM-W-W(1) SM-W-H(1)
     MOVE "N" TO TL-MODE

*>   Oak leaves: a cube of three faces, every one in the constant 48B518 of the item definition.
     MOVE "oak_leaves" TO WS-KEY
     MOVE -1 TO WS-DYE WS-POTION
     PERFORM DRAW-SLOT
     MOVE "item tint icons oak leaves: three quads" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FROM
     MOVE 18 TO WS-TO
     MOVE 72 TO WS-EXP-R
     MOVE 181 TO WS-EXP-G
     MOVE 24 TO WS-EXP-B
     PERFORM COUNT-FACES
     MOVE "item tint icons oak leaves: six vertices of 48B518 in each of the three face shades (1.0, 0.7459, 0.6797)" TO TL-CASE
     MOVE 666 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FACE-MATCH(1) * 100 + WS-FACE-MATCH(2) * 10 + WS-FACE-MATCH(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Dirt has no tints: white.
     MOVE "dirt" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE 255 TO WS-EXP-R WS-EXP-G WS-EXP-B
     MOVE 1 TO WS-FROM
     MOVE RL-IC-COUNT TO WS-TO
     PERFORM COUNT-FACES
     MOVE "item tint icons dirt: every vertex is white in its face's shade (six each of 1.0, 0.7459, 0.6797)" TO TL-CASE
     MOVE 666 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FACE-MATCH(1) * 100 + WS-FACE-MATCH(2) * 10 + WS-FACE-MATCH(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The grass block: the tinted faces are in the grass colormap colour of (0.5, 1.0) (43 section 7.1), the others white; both kinds are there.
     CALL "TINT-COLORMAP" USING WS-MAP WS-TEMP WS-DOWN WS-COLOUR
     COMPUTE WS-EXP-R = FUNCTION MOD(WS-COLOUR / 65536, 256)
     COMPUTE WS-EXP-G = FUNCTION MOD(WS-COLOUR / 256, 256)
     COMPUTE WS-EXP-B = FUNCTION MOD(WS-COLOUR, 256)
     MOVE "grass_block" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE 1 TO WS-FROM
     MOVE RL-IC-COUNT TO WS-TO
     PERFORM COUNT-COLOUR
     MOVE WS-MATCH TO WS-TINTED
     MOVE "item tint icons grass block: some vertices are in the grass colormap colour" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-TINTED > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-FACES
     COMPUTE WS-TINTED = WS-FACE-MATCH(1) + WS-FACE-MATCH(2) + WS-FACE-MATCH(3)
     MOVE "item tint icons grass block: the top (shade 1.0) and the two side overlays (0.7459, 0.6797) are in the colormap colour, six vertices each" TO TL-CASE
     MOVE 666 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FACE-MATCH(1) * 100 + WS-FACE-MATCH(2) * 10 + WS-FACE-MATCH(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 255 TO WS-EXP-R WS-EXP-G WS-EXP-B
     PERFORM COUNT-FACES
     MOVE "item tint icons grass block: the faces without a tintindex are white in their shade (none on top, six each on the two sides)" TO TL-CASE
     MOVE 66 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FACE-MATCH(1) * 100 + WS-FACE-MATCH(2) * 10 + WS-FACE-MATCH(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint icons grass block: the vertices are the tinted ones and white ones" TO TL-CASE
     MOVE RL-IC-COUNT TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-TINTED + WS-FACE-MATCH(1) + WS-FACE-MATCH(2) + WS-FACE-MATCH(3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A leather helmet: layer 0 in the dye default A06540 of the item definition, the overlay layer 1 white; a stack with dyed_color shows its colour.
     MOVE "leather_helmet" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE "item tint icons leather helmet: two flat quads (layer 0 and the overlay)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FROM
     MOVE 6 TO WS-TO
     MOVE 160 TO WS-EXP-R
     MOVE 101 TO WS-EXP-G
     MOVE 64 TO WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons undyed leather helmet: layer 0 is A06540" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-FROM
     MOVE 12 TO WS-TO
     MOVE 255 TO WS-EXP-R WS-EXP-G WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons leather helmet: the overlay layer is white" TO TL-CASE
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11546150 TO WS-DYE
     MOVE -1 TO WS-POTION
     PERFORM DRAW-SLOT
     MOVE 1 TO WS-FROM
     MOVE 6 TO WS-TO
     MOVE 176 TO WS-EXP-R
     MOVE 46 TO WS-EXP-G
     MOVE 38 TO WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons dyed leather helmet: layer 0 is the stack's B02E26" TO TL-CASE
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A potion: the stack's potion (swiftness, id 13) colours layer 0 33EBFF; a potion stack with none is the default blue 385DC6; the bottle (layer 1) is white.
     MOVE "potion" TO WS-KEY
     MOVE -1 TO WS-DYE
     MOVE 13 TO WS-POTION
     PERFORM DRAW-SLOT
     MOVE "item tint icons potion: two flat quads" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-FROM
     MOVE 6 TO WS-TO
     MOVE 51 TO WS-EXP-R
     MOVE 235 TO WS-EXP-G
     MOVE 255 TO WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons swiftness potion: layer 0 is 33EBFF" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-FROM
     MOVE 12 TO WS-TO
     MOVE 255 TO WS-EXP-R WS-EXP-G WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons potion: the bottle layer is white" TO TL-CASE
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-POTION
     PERFORM DRAW-SLOT
     MOVE 1 TO WS-FROM
     MOVE 6 TO WS-TO
     MOVE 56 TO WS-EXP-R
     MOVE 93 TO WS-EXP-G
     MOVE 198 TO WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons potion without potion_contents: layer 0 is the default 385DC6" TO TL-CASE
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The firework star: layer 0 white (constant FFFFFFFF), layer 1 the firework default 8A8A8A.
     MOVE "firework_star" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE "item tint icons firework star: two flat quads" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-IC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-FROM
     MOVE 12 TO WS-TO
     MOVE 138 TO WS-EXP-R WS-EXP-G WS-EXP-B
     PERFORM COUNT-COLOUR
     MOVE "item tint icons firework star: layer 1 is 8A8A8A" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An apple is one flat white quad with no second layer; a spawn egg has no tint; the UI tint is left at 0.
     MOVE "apple" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE 255 TO WS-EXP-R WS-EXP-G WS-EXP-B
     MOVE 1 TO WS-FROM
     MOVE RL-IC-COUNT TO WS-TO
     PERFORM COUNT-COLOUR
     MOVE "item tint icons apple: one white quad" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint icons apple: no second layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE IS-LAYER1(WS-ITEM + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pig_spawn_egg" TO WS-KEY
     PERFORM DRAW-SLOT
     MOVE 1 TO WS-FROM
     MOVE RL-IC-COUNT TO WS-TO
     PERFORM COUNT-COLOUR
     MOVE "item tint icons spawn egg (colours in its texture, no tints): one white quad" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-MATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "item tint icons the UI tint is back to 0 after the icons" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-UI-TINT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> DRAW-SLOT: the item named WS-KEY, with the dye and potion in WS-DYE and WS-POTION (-1 none), in player slot 0 drawn by UI-RENDER into an empty icon layer.
 DRAW-SLOT.
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE WS-ITEM TO PL-SLOT-ITEM(1)
     COMPUTE PL-SLOT-DYE(1) = WS-DYE + 1
     COMPUTE PL-SLOT-POTION(1) = WS-POTION + 1
     MOVE 0 TO RL-IC-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE.

*> COUNT-COLOUR: the number of vertices WS-FROM to WS-TO of the icon layer whose colour times 255 rounds to WS-EXP-R, -G, -B times the shade WS-SHADE (ten thousandths), rounded (WS-MATCH).
 COUNT-COLOUR.
     COMPUTE WS-EXP-SR = FUNCTION INTEGER(WS-EXP-R * WS-SHADE / 10000 + 0.5)
     COMPUTE WS-EXP-SG = FUNCTION INTEGER(WS-EXP-G * WS-SHADE / 10000 + 0.5)
     COMPUTE WS-EXP-SB = FUNCTION INTEGER(WS-EXP-B * WS-SHADE / 10000 + 0.5)
     MOVE 0 TO WS-MATCH
     PERFORM VARYING WS-I FROM WS-FROM BY 1 UNTIL WS-I > WS-TO
         COMPUTE WS-GOT-G ROUNDED = RL-IC-G(WS-I) * 255
         COMPUTE WS-GOT-B ROUNDED = RL-IC-BLUE(WS-I) * 255
         COMPUTE WS-GOT-R ROUNDED = RL-IC-R(WS-I) * 255
         IF WS-GOT-R = WS-EXP-SR AND WS-GOT-G = WS-EXP-SG AND WS-GOT-B = WS-EXP-SB
             ADD 1 TO WS-MATCH
         END-IF
     END-PERFORM.

*> COUNT-FACES: COUNT-COLOUR for the three shades of a cube's visible faces under ITEMS_3D (up 1.0000, east 0.7459, north 0.6797) into WS-FACE-MATCH(1 to 3); the shade is 1 again afterwards.
 COUNT-FACES.
     MOVE 10000 TO WS-SH(1)
     MOVE 7459 TO WS-SH(2)
     MOVE 6797 TO WS-SH(3)
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 3
         MOVE WS-SH(WS-F) TO WS-SHADE
         PERFORM COUNT-COLOUR
         MOVE WS-MATCH TO WS-FACE-MATCH(WS-F)
     END-PERFORM
     MOVE 10000 TO WS-SHADE.
 END PROGRAM TEST-ITEM-TINT-ICONS.
