*> CC-0014 (bug wave round 4), the model of the goat horn while it is in use (docs/protocol/58-in-use-item-models-and-arm-poses.md sections 3.2, 4.1 and 4.3, real generated vanilla pack,
*> CC_GENERATED_DIR): the definition items/goat_horn.json is a condition on using_item whose on_true is item/tooting_goat_horn, so ITEM-IN-USE-ID gives the horn a virtual item id (and every item
*> whose definition is no such condition, the bow, crossbow, shield and trident among them, its own id); ITEM-SPRITE-OF, ITEM-HAND-DISPLAY and ITEM-DISPLAY of that id read the tooting model: the table
*> of 4.3 (first person right rot (0, -55, -5) tr (-1, -2.5, -7.5) scale 1 against the plain (0, -90, 25) (1.13, 3.2, 1.13) 0.68; third person right (0, -125, 0) (-1, 2, 2) 0.5 against (0, 180, 0)
*> (0, 3, 1) 0.55; the left entries as authored). The first-person hand (HAND-EQUIP, HAND-MESH) shows the variant while the local player uses the horn of the main hand (PL-USING) and the shown stack
*> is the live one, and the mesh follows without the still-hand cache holding the plain one: against the plain mesh the front quad's diagonal is 1 / 0.68 as long, its normal turned by 35 degrees and
*> its centre moved by 0.6463 block (the differences of the table through the same arm transform, worked by scratchpad/bwb-r5). The third-person item (ENTITY-HELD-POSED on an arm frame set by hand)
*> follows the viewer's use state: the front quad's centre, the ratio of its diagonals (0.5 / 0.55) and the turn of its normal (55 degrees) are those of the table, worked from the chain of
*> 34-1 section 8.3 and 12 section 8.2 by the same script (the plain horn's centre validates the chain against test_entity_held_pose).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HORN-IN-USE-MODEL.
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
 01 WS-HORN                BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-SHIELD              BINARY-LONG.
 01 WS-BOW                 BINARY-LONG.
 01 WS-TRIDENT             BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG.
 01 WS-VID                 BINARY-LONG.
 01 WS-VID2                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-SPRITE-V            BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CTX                 BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 1.
 01 WS-E                   FLOAT-LONG.
 01 WS-EO                  FLOAT-LONG.
 01 WS-PART                FLOAT-LONG.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-EXP.
    05 WS-EV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-NAME                PIC X(100).
 01 WS-OK                  BINARY-LONG.
 01 WS-QA.
    05 WS-QAV              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-QB.
    05 WS-QBV              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIAG                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CEN-A.
    05 WS-CA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CEN-B.
    05 WS-CB               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NA.
    05 WS-NAV              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NB.
    05 WS-NBV              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-N0.
    05 WS-N0V              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-N1.
    05 WS-N1V              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C0.
    05 WS-C0V              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-C1.
    05 WS-C1V              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-SHIFT               FLOAT-LONG.
 01 WS-LEN-A               FLOAT-LONG.
 01 WS-LEN-B               FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-V1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-V2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-V3                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 20 TO PL-HEALTH
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
     MOVE "N" TO TL-MODE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE "goat_horn" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-HORN WS-ITEM-ROW WS-STATUS
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "shield" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHIELD WS-ITEM-ROW WS-STATUS
     MOVE "bow" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BOW WS-ITEM-ROW WS-STATUS
     MOVE "trident" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TRIDENT WS-ITEM-ROW WS-STATUS
     MOVE "crossbow" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CROSSBOW WS-ITEM-ROW WS-STATUS
*>   ---- the item ids ----
     CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-HORN WS-VID
     MOVE "CC-0014 model: the goat horn gets a virtual item id for its in-use variant" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VID >= 2048 - CL-USE-VIRT AND WS-VID < 2048
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-HORN WS-VID2
     MOVE "CC-0014 model: the same item gets the same virtual id again" TO TL-CASE
     MOVE WS-VID TO TL-EXPECTED-N
     MOVE WS-VID2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE WS-STICK TO WS-J
                 MOVE "a stick (no using_item node)" TO WS-NAME
             WHEN 2
                 MOVE WS-SHIELD TO WS-J
                 MOVE "a shield (on_true is a code-drawn special model)" TO WS-NAME
             WHEN 3
                 MOVE WS-BOW TO WS-J
                 MOVE "a bow (on_true is a range_dispatch)" TO WS-NAME
             WHEN 4
                 MOVE WS-TRIDENT TO WS-J
                 MOVE "a trident (a select on display_context first)" TO WS-NAME
             WHEN 5
                 MOVE WS-CROSSBOW TO WS-J
                 MOVE "a crossbow (a select on charge_type first)" TO WS-NAME
         END-EVALUATE
         CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-J WS-VID2
         MOVE SPACES TO TL-CASE
         STRING "CC-0014 model: " FUNCTION TRIM(WS-NAME) " keeps its own id" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-J TO TL-EXPECTED-N
         MOVE WS-VID2 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 2047 TO WS-J
     CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-J WS-VID2
     MOVE "CC-0014 model: a virtual id and an id out of range come back unchanged" TO TL-CASE
     MOVE 2047 TO TL-EXPECTED-N
     MOVE WS-VID2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5000 TO WS-J
     CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-J WS-VID2
     MOVE WS-J TO TL-EXPECTED-N
     MOVE "CC-0014 model: an id out of range comes back unchanged" TO TL-CASE
     MOVE WS-VID2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- the sprite and the display transforms (58 section 4.3) ----
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-HORN WS-SPRITE
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-VID WS-SPRITE-V
     MOVE "CC-0014 model: both horn models use the one texture item/goat_horn (the same sprite)" TO TL-CASE
     MOVE WS-SPRITE TO TL-EXPECTED-N
     MOVE WS-SPRITE-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-EV(1) WS-EV(3) WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE -90 TO WS-EV(2)
     MOVE 25 TO WS-EV(3)
     MOVE 1.13 TO WS-EV(4)
     MOVE 3.2 TO WS-EV(5)
     MOVE 1.13 TO WS-EV(6)
     MOVE 0.68 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "plain horn first person right (0, -90, 25) (1.13, 3.2, 1.13) 0.68" TO WS-NAME
     CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE WS-HORN WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
     MOVE 0 TO WS-EV(1)
     MOVE -55 TO WS-EV(2)
     MOVE -5 TO WS-EV(3)
     MOVE -1 TO WS-EV(4)
     MOVE -2.5 TO WS-EV(5)
     MOVE -7.5 TO WS-EV(6)
     MOVE 1 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "in-use horn first person right (0, -55, -5) (-1, -2.5, -7.5) scale 1" TO WS-NAME
     CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE WS-VID WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
     MOVE 1 TO WS-CTX
     MOVE 0 TO WS-EV(1)
     MOVE 180 TO WS-EV(2)
     MOVE 0 TO WS-EV(3) WS-EV(4)
     MOVE 3 TO WS-EV(5)
     MOVE 1 TO WS-EV(6)
     MOVE 0.55 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "plain horn third person right (0, 180, 0) (0, 3, 1) 0.55" TO WS-NAME
     CALL "ITEM-DISPLAY" USING CLIENT-STATE WS-HORN WS-CTX WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
     MOVE -125 TO WS-EV(2)
     MOVE -1 TO WS-EV(4)
     MOVE 2 TO WS-EV(5) WS-EV(6)
     MOVE 0.5 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "in-use horn third person right (0, -125, 0) (-1, 2, 2) 0.5" TO WS-NAME
     CALL "ITEM-DISPLAY" USING CLIENT-STATE WS-VID WS-CTX WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
     MOVE 2 TO WS-CTX
     MOVE 0 TO WS-EV(2)
     MOVE 0 TO WS-EV(4)
     MOVE 3 TO WS-EV(5)
     MOVE 1 TO WS-EV(6)
     MOVE 0.55 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "plain horn third person left as authored (0, 0, 0) (0, 3, 1) 0.55" TO WS-NAME
     CALL "ITEM-DISPLAY" USING CLIENT-STATE WS-HORN WS-CTX WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
     MOVE 55 TO WS-EV(2)
     MOVE -1 TO WS-EV(4)
     MOVE 2 TO WS-EV(5) WS-EV(6)
     MOVE 0.5 TO WS-EV(7) WS-EV(8) WS-EV(9)
     MOVE "in-use horn third person left as authored (0, 55, 0) (-1, 2, 2) 0.5" TO WS-NAME
     CALL "ITEM-DISPLAY" USING CLIENT-STATE WS-VID WS-CTX WS-PRESENT WS-VAL
     PERFORM CHECK-VALUES
*>   ---- the first-person hand ----
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE WS-HORN TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA CL-SWING-AT PL-USING
     MOVE 1000000 TO CL-NOW-MS
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE 1 TO CL-HAND-NOCULL
     PERFORM TEST-SHOW
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     MOVE "CC-0014 hand: not using the horn, the hand shows the plain horn" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HORN + 1
     MOVE CL-HAND-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-USING
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     MOVE "CC-0014 hand: using the horn (PL-USING), the hand shows the in-use variant" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-VID + 1
     MOVE CL-HAND-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "CC-0014 hand: the shown stack (the equip animation's) stays the horn itself" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-HORN + 1
     MOVE CL-HAND-ITEM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE CL-HAND-ITEM = WS-STICK + 1
     CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     MOVE "CC-0014 hand: while the shown stack is not the live one the plain model is shown (58 section 2.5)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-STICK + 1
     MOVE CL-HAND-SHOWN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The mesh, the plain horn and then the same frame in use (no TEST-SHOW between: the still-hand cache must not hold the plain mesh), then plain again.
     MOVE 0 TO PL-USING
     PERFORM TEST-SHOW
     CALL "HAND-MESH" USING CLIENT-STATE
     PERFORM FRONT-QUAD-A
     MOVE 1 TO PL-USING
     CALL "HAND-MESH" USING CLIENT-STATE
     PERFORM FRONT-QUAD-B
     PERFORM QUAD-METRICS
     MOVE "CC-0014 hand mesh: the in-use quad's diagonal is 1 / 0.68 of the plain one's (scale 1 against 0.68)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (1 / 0.68) * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-LEN-B / WS-LEN-A * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "CC-0014 hand mesh: the in-use quad's normal is turned by 35 degrees (rotation y -55 against -90)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = FUNCTION COS(35 * FUNCTION PI / 180) * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-DOT * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "CC-0014 hand mesh: the in-use quad's centre moved by 0.6463 block (the translation and the model's centre offset)" TO TL-CASE
     MOVE 6463 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SHIFT * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-USING
     CALL "HAND-MESH" USING CLIENT-STATE
     PERFORM FRONT-QUAD-B
     MOVE 0 TO WS-OK
     IF FUNCTION ABS(WS-CB(1) - WS-CA(1)) < 0.0001 AND FUNCTION ABS(WS-CB(2) - WS-CA(2)) < 0.0001 AND FUNCTION ABS(WS-CB(3) - WS-CA(3)) < 0.0001
         MOVE 1 TO WS-OK
     END-IF
     MOVE "CC-0014 hand mesh: after the use the plain horn's mesh is back" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- the third-person item: a horn in the right hand on an arm frame set by hand (identity axes at (0.5, 1, 0.25) of an entity at (10.5, 64, 10.5), the eye at (10, 64, 10)) ----
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE "zombie" TO EN-KEY(1)
     MOVE 10.5 TO EN-X(1) EN-Z(1)
     MOVE 64 TO EN-Y(1)
     MOVE 0 TO EN-BABY(1) EN-MOB-FLAGS(1) EN-LIVING(1) EN-USE-ACTIVE(1) EN-USE-LEFT(1)
     MOVE WS-HORN TO EN-EQ(1, 1)
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE 1 TO EN-HAND-FOK(1, WS-HAND)
         MOVE 0.5 TO EN-HAND-F(1, WS-HAND, 1)
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 2)
         MOVE 0.25 TO EN-HAND-F(1, WS-HAND, 3)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 4) EN-HAND-F(1, WS-HAND, 5) EN-HAND-F(1, WS-HAND, 6)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 7) EN-HAND-F(1, WS-HAND, 8) EN-HAND-F(1, WS-HAND, 9)
         MOVE 0 TO EN-HAND-F(1, WS-HAND, 10) EN-HAND-F(1, WS-HAND, 11) EN-HAND-F(1, WS-HAND, 12)
         MOVE 1 TO EN-HAND-F(1, WS-HAND, 4) EN-HAND-F(1, WS-HAND, 8) EN-HAND-F(1, WS-HAND, 12)
     END-PERFORM
     MOVE 1 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-HORN WS-EYE-TABLE
     PERFORM GI-FRONT-QUAD-A
     MOVE "CC-0014 held: the plain horn's front quad centre is (0.9375, 1.57969, 0.4375)" TO WS-NAME
     MOVE 0.9375 TO WS-EV(1)
     MOVE 1.57969 TO WS-EV(2)
     MOVE 0.4375 TO WS-EV(3)
     PERFORM CHECK-CENTRE-A
*>   The entity uses the horn with the main hand (entry 8 bit 0, the viewer's use state): the in-use model.
     MOVE 1 TO EN-LIVING(1) EN-USE-ACTIVE(1)
     MOVE WS-HORN TO EN-USE-ITEM(1)
     MOVE 140 TO EN-USE-LEFT(1)
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-HORN WS-EYE-TABLE
     PERFORM GI-FRONT-QUAD-B
     MOVE "CC-0014 held: the in-use horn's front quad centre (1.0128, 1.50896, 0.5)" TO WS-NAME
     MOVE 1.0128 TO WS-EV(1)
     MOVE 1.50896 TO WS-EV(2)
     MOVE 0.5 TO WS-EV(3)
     PERFORM CHECK-CENTRE-B
     PERFORM QUAD-METRICS
     MOVE "CC-0014 held: the in-use quad's diagonal is 0.5 / 0.55 of the plain one's" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = (0.5 / 0.55) * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-LEN-B / WS-LEN-A * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "CC-0014 held: the in-use quad's normal is turned by 55 degrees (rotation y -125 against 180)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = FUNCTION COS(55 * FUNCTION PI / 180) * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-DOT * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The off hand's horn is not the used stack: the plain model (the used hand is the main hand).
     MOVE 0 TO EN-EQ(1, 1)
     MOVE WS-HORN TO EN-EQ(1, 2)
     MOVE 2 TO WS-HAND
     MOVE 0 TO RL-GI-COUNT
     CALL "ENTITY-HELD-POSED" USING CLIENT-STATE WS-ID WS-HAND WS-HORN WS-EYE-TABLE
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     MOVE "CC-0014 held: the other hand's horn is drawn (12 vertices)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without a standard set open (the stand-in content) no item has a definition: the id comes back unchanged.
     MOVE 0 TO CT-OPEN
     CALL "ITEM-IN-USE-ID" USING CLIENT-STATE WS-HORN WS-VID2
     MOVE "CC-0014 model: with no standard set open the horn keeps its id" TO TL-CASE
     MOVE WS-HORN TO TL-EXPECTED-N
     MOVE WS-VID2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The hand shows the horn at full height (TEST-HAND-SHOW of test_hand_doc).
 TEST-SHOW.
     COMPUTE CL-HAND-ITEM = WS-HORN + 1
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 0 TO CL-HAND-KEY-COUNT.

*> The values of WS-VAL against WS-EXP (nine numbers, hundredths), present 1.
 CHECK-VALUES.
     MOVE 1 TO WS-OK
     IF WS-PRESENT NOT = 1
         MOVE 0 TO WS-OK
     END-IF
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 9
         IF FUNCTION ABS(WS-DV(WS-J) - WS-EV(WS-J)) > 0.001
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "CC-0014 model: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The front quad of the hand mesh (vertices 1 to 3: corners 1, 2, 3, with 3 opposite 1): centre, edge vectors for the normal and the diagonal.
 FRONT-QUAD-A.
     PERFORM GI-READ-HAND
     PERFORM STORE-A.

 FRONT-QUAD-B.
     PERFORM GI-READ-HAND
     PERFORM STORE-B.

 GI-READ-HAND.
     MOVE RL-HAND-X(1) TO WS-V1(1)
     MOVE RL-HAND-Y(1) TO WS-V1(2)
     MOVE RL-HAND-Z(1) TO WS-V1(3)
     MOVE RL-HAND-X(2) TO WS-V2(1)
     MOVE RL-HAND-Y(2) TO WS-V2(2)
     MOVE RL-HAND-Z(2) TO WS-V2(3)
     MOVE RL-HAND-X(3) TO WS-V3(1)
     MOVE RL-HAND-Y(3) TO WS-V3(2)
     MOVE RL-HAND-Z(3) TO WS-V3(3).

 GI-FRONT-QUAD-A.
     PERFORM GI-READ
     PERFORM STORE-A.

 GI-FRONT-QUAD-B.
     PERFORM GI-READ
     PERFORM STORE-B.

 GI-READ.
     MOVE RL-GI-X(1) TO WS-V1(1)
     MOVE RL-GI-Y(1) TO WS-V1(2)
     MOVE RL-GI-Z(1) TO WS-V1(3)
     MOVE RL-GI-X(2) TO WS-V2(1)
     MOVE RL-GI-Y(2) TO WS-V2(2)
     MOVE RL-GI-Z(2) TO WS-V2(3)
     MOVE RL-GI-X(3) TO WS-V3(1)
     MOVE RL-GI-Y(3) TO WS-V3(2)
     MOVE RL-GI-Z(3) TO WS-V3(3).

*> Quad A: centre (the middle of corners 1 and 3), the normal (edge 1-2 x edge 1-3, unit) and the diagonal; quad B the same.
 STORE-A.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         COMPUTE WS-CA(WS-J) = (WS-V1(WS-J) + WS-V3(WS-J)) / 2
     END-PERFORM
     COMPUTE WS-N0V(1) = (WS-V2(2) - WS-V1(2)) * (WS-V3(3) - WS-V1(3)) - (WS-V2(3) - WS-V1(3)) * (WS-V3(2) - WS-V1(2))
     COMPUTE WS-N0V(2) = (WS-V2(3) - WS-V1(3)) * (WS-V3(1) - WS-V1(1)) - (WS-V2(1) - WS-V1(1)) * (WS-V3(3) - WS-V1(3))
     COMPUTE WS-N0V(3) = (WS-V2(1) - WS-V1(1)) * (WS-V3(2) - WS-V1(2)) - (WS-V2(2) - WS-V1(2)) * (WS-V3(1) - WS-V1(1))
     COMPUTE WS-LEN-A = FUNCTION SQRT((WS-V3(1) - WS-V1(1)) ** 2 + (WS-V3(2) - WS-V1(2)) ** 2 + (WS-V3(3) - WS-V1(3)) ** 2).

 STORE-B.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         COMPUTE WS-CB(WS-J) = (WS-V1(WS-J) + WS-V3(WS-J)) / 2
     END-PERFORM
     COMPUTE WS-N1V(1) = (WS-V2(2) - WS-V1(2)) * (WS-V3(3) - WS-V1(3)) - (WS-V2(3) - WS-V1(3)) * (WS-V3(2) - WS-V1(2))
     COMPUTE WS-N1V(2) = (WS-V2(3) - WS-V1(3)) * (WS-V3(1) - WS-V1(1)) - (WS-V2(1) - WS-V1(1)) * (WS-V3(3) - WS-V1(3))
     COMPUTE WS-N1V(3) = (WS-V2(1) - WS-V1(1)) * (WS-V3(2) - WS-V1(2)) - (WS-V2(2) - WS-V1(2)) * (WS-V3(1) - WS-V1(1))
     COMPUTE WS-LEN-B = FUNCTION SQRT((WS-V3(1) - WS-V1(1)) ** 2 + (WS-V3(2) - WS-V1(2)) ** 2 + (WS-V3(3) - WS-V1(3)) ** 2).

*> The dot of the unit normals of quads A and B, the distance of their centres (and the diagonals in WS-LEN-A and WS-LEN-B).
 QUAD-METRICS.
     COMPUTE WS-D0 = FUNCTION SQRT(WS-N0V(1) ** 2 + WS-N0V(2) ** 2 + WS-N0V(3) ** 2)
     COMPUTE WS-D1 = FUNCTION SQRT(WS-N1V(1) ** 2 + WS-N1V(2) ** 2 + WS-N1V(3) ** 2)
     COMPUTE WS-DOT = (WS-N0V(1) * WS-N1V(1) + WS-N0V(2) * WS-N1V(2) + WS-N0V(3) * WS-N1V(3)) / (WS-D0 * WS-D1)
     COMPUTE WS-SHIFT = FUNCTION SQRT((WS-CB(1) - WS-CA(1)) ** 2 + (WS-CB(2) - WS-CA(2)) ** 2 + (WS-CB(3) - WS-CA(3)) ** 2).

 CHECK-CENTRE-A.
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         IF FUNCTION ABS(WS-CA(WS-J) - WS-EV(WS-J)) > 0.001
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-CENTRE-B.
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         IF FUNCTION ABS(WS-CB(WS-J) - WS-EV(WS-J)) > 0.001
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HORN-IN-USE-MODEL.

