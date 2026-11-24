*> Lane bugbeitems (T42420 and on; operator try15: the dropped chest was a flat square): the same code-drawn items in a GUI slot and in the first-person hand go through the real
*> UI-RENDER and HAND-MESH. A slot holding a chest draws the chest's model into the icon layer (several quads of the chest's sprite, in the 16 pixel cell of the slot), a slot holding dirt
*> still one quad; the hand holding a chest or a banner has the model's quads (all in the sprite of the model, the banner's dyed cloth tinted by the dye's colour), where it had nothing
*> (the display of a code-drawn model was "not drawn"). The generated vanilla pack is read from CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SPECIAL-SLOTS.
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
 01 WS-CHEST               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LEN              BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-TINTED              BINARY-LONG.
 01 WS-U0                  FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-DATE                PIC X(21).
 01 WS-MMDD                PIC 9(4).
 01 WS-XMAS                BINARY-LONG.
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
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE FUNCTION CURRENT-DATE TO WS-DATE
     MOVE WS-DATE(5:4) TO WS-MMDD
     CALL "CHEST-CHRISTMAS" USING WS-MMDD WS-XMAS
     MOVE SPACES TO WS-KEY
     MOVE "chest" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CHEST WS-ITEM-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DIRT WS-ITEM-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "red_banner" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BANNER WS-ITEM-ROW WS-STATUS
     MOVE SPACES TO WS-ID
     MOVE "minecraft:entity/chest/normal" TO WS-ID
     IF WS-XMAS = 1
         MOVE "minecraft:entity/chest/christmas" TO WS-ID
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ID)) TO WS-ID-LEN
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LEN WS-SPRITE
     COMPUTE WS-U0 = AT-X(WS-SPRITE) / AT-W
     COMPUTE WS-U1 = (AT-X(WS-SPRITE) + AT-SW(WS-SPRITE)) / AT-W
     COMPUTE WS-V0 = AT-Y(WS-SPRITE) / AT-H
     COMPUTE WS-V1 = (AT-Y(WS-SPRITE) + AT-SH(WS-SPRITE)) / AT-H
*>   A slot widget (18 x 18 at 10, 10, GUI scale 2) holding the chest.
     MOVE 1 TO SM-WIDGET-COUNT
     MOVE WK-SLOT TO SM-W-KIND(1)
     MOVE 0 TO SM-W-ARG(1) SM-W-STATE(1)
     MOVE 10 TO SM-W-X(1) SM-W-Y(1)
     MOVE 18 TO SM-W-W(1) SM-W-H(1)
     MOVE 2 TO CL-GUI-SCALE
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE WS-CHEST TO PL-SLOT-ITEM(1)
     MOVE 0 TO RL-IC-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "bugbeitems a chest in a slot: its model (8 quads facing the viewer), not one flat quad" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-IC-COUNT / 6
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-IN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-IC-COUNT
         IF RL-IC-U(WS-I) >= WS-U0 - 0.00001 AND RL-IC-U(WS-I) <= WS-U1 + 0.00001
                 AND RL-IC-V(WS-I) >= WS-V0 - 0.00001 AND RL-IC-V(WS-I) <= WS-V1 + 0.00001
                 AND RL-IC-X(WS-I) >= 24 AND RL-IC-X(WS-I) <= 56 AND RL-IC-Y(WS-I) >= 24 AND RL-IC-Y(WS-I) <= 56
             ADD 1 TO WS-IN
         END-IF
     END-PERFORM
     MOVE "bugbeitems a chest in a slot: every vertex is in the chest's sprite and inside the slot's icon cell" TO TL-CASE
     MOVE RL-IC-COUNT TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-DIRT TO PL-SLOT-ITEM(1)
     MOVE 0 TO RL-IC-COUNT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "bugbeitems dirt in a slot is its cube (lane bugguiitems: 3 quads, was one flat quad)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-IC-COUNT / 6
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hand holding the chest.
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA CL-SWING-AT
     MOVE 1000000 TO CL-NOW-MS
     COMPUTE CL-HAND-ITEM = WS-CHEST + 1
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE WS-CHEST TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "bugbeitems a chest in the hand: the model's quads facing the eye (the generic path drew nothing)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HAND-COUNT > 0 AND FUNCTION MOD(RL-HAND-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-IN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HAND-COUNT
         IF RL-HAND-U(WS-I) >= WS-U0 - 0.00001 AND RL-HAND-U(WS-I) <= WS-U1 + 0.00001
                 AND RL-HAND-V(WS-I) >= WS-V0 - 0.00001 AND RL-HAND-V(WS-I) <= WS-V1 + 0.00001
             ADD 1 TO WS-IN
         END-IF
     END-PERFORM
     MOVE "bugbeitems a chest in the hand: every vertex is in the chest's sprite" TO TL-CASE
     MOVE RL-HAND-COUNT TO TL-EXPECTED-N
     MOVE WS-IN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The hand holding the red banner: the dyed cloth is tinted by the diffuse colour of red (B02E26). Since the merge with lane p70d the banner is the hand renderer's
*>   (HAND-BANNER, the arm mesh RL-HA, atlas slots made by the entity pass), no longer HAND-SPECIAL-MESH's.
     COMPUTE CL-HAND-ITEM = WS-BANNER + 1
     MOVE WS-BANNER TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 0 TO CL-HAND-KEY-COUNT CL-HAND-KEY-ITEM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 0 TO WS-TINTED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-HA-COUNT
         IF FUNCTION ABS(RL-HA-R(WS-I) - 0.6902) < 0.001 AND FUNCTION ABS(RL-HA-G(WS-I) - 0.1804) < 0.001
                 AND FUNCTION ABS(RL-HA-BLUE(WS-I) - 0.149) < 0.001
             ADD 1 TO WS-TINTED
         END-IF
     END-PERFORM
     MOVE "bugbeitems a banner in the hand: the cloth layer's quads (whole quads of 6 vertices) are red-tinted" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TINTED > 0 AND FUNCTION MOD(WS-TINTED, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SPECIAL-SLOTS.
 COPY CLTEST.
