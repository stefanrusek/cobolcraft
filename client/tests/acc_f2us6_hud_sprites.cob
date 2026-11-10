*> Acceptance test US6-5 (spec 002 FR-013, FR-014; SC-003; 12 §5.2 to 5.4; builtin-ui-art 4.1 to 4.3): the HUD is drawn with the
*> built-in sprites, not text labels. At a 320 x 240 GUI: the crosshair sprite at (152, 112); the hotbar sprite at (69, 218) with
*> the selection frame over the held slot (68 + 20 slot, 217); the nine hotbar slots bare (the sprite carries the wells) with
*> their icons at (72 + 20 i, 221); the off-hand backing at (40, 217) while the off hand holds a stack; in survival a heart meter
*> at (69, 201) and a food meter at (242, 201) that grow right and left, no labels; in creative neither meter; the meters render
*> 15 + 9 hearts and 12 + 10 food icons (one quad each) for health 17 and food 20.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US6-HUD-SPRITES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-PATH                PIC X(256).
 01 WS-HEALTH              FLOAT-SHORT VALUE 17.0.
 01 WS-FOOD                BINARY-LONG VALUE 20.
 01 WS-I                   BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LABELS              BINARY-LONG.
 01 WS-SURVIVAL-UI         BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "contract/fixtures/wire/play-s2c-6a-set-health.hex" TO WS-PATH
     CALL "TEST-FEED" USING CLIENT-STATE WS-CONN WS-PATH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SET-HEALTH" USING CLIENT-STATE WS-CONN WS-HEALTH WS-FOOD
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 640 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO CL-CAMERA PL-OFFHAND-COUNT PL-HELD
     MOVE 0 TO CL-NOW-MS PL-HURT-UNTIL
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE "N" TO TL-MODE

     MOVE "acceptance US6-5 the built-in art has the heart, food and hotbar sprites (heart is 9 wide)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE GS-W(GSP-HEART-FULL) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE GSP-CROSSHAIR TO WS-ROW
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 the crosshair sprite is at (152, 112), 15 x 15" TO TL-CASE
     MOVE 152112015 TO TL-EXPECTED-N
     PERFORM POSITION-OF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE GSP-HOTBAR TO WS-ROW
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 the hotbar sprite is at (69, 218), 182 x 22" TO TL-CASE
     MOVE 069218182 TO TL-EXPECTED-N
     PERFORM POSITION-OF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE GSP-HOTBAR-SELECTION TO WS-ROW
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 the selection frame of slot 0 is at (68, 217), 24 x 23" TO TL-CASE
     MOVE 068217024 TO TL-EXPECTED-N
     PERFORM POSITION-OF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-HELD
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 the selection frame of slot 3 is at (128, 217)" TO TL-CASE
     MOVE 128217024 TO TL-EXPECTED-N
     PERFORM POSITION-OF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-HELD
     CALL "SCREEN-BUILD" USING CLIENT-STATE

*>   The hotbar slots: bare slot widgets (state 3), the icon cell of slot i at (72 + 20 i, 221) = widget x + 2, y + 2.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) < 9
             ADD 1 TO WS-COUNT
             IF SM-W-ARG(WS-I) = 8
                 COMPUTE WS-AT = (SM-W-X(WS-I) + 2) * 1000 + SM-W-Y(WS-I) + 2
                 IF SM-W-STATE(WS-I) NOT = 3
                     MOVE -1 TO WS-AT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 nine bare hotbar slots" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-5 the icon cell of slot 8 is at (232, 221)" TO TL-CASE
     MOVE 232221 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Off hand: backing sprite left of the hotbar and the slot beside it.
     MOVE GSP-OFFHAND-LEFT TO WS-ROW
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 an empty off hand has no backing sprite" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     IF WS-AT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO PL-OFFHAND-COUNT
     MOVE 1 TO PL-OFFHAND-ITEM
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     PERFORM FIND-SPRITE
     MOVE "acceptance US6-5 the off-hand backing is at (40, 217), 29 x 24" TO TL-CASE
     MOVE 040217029 TO TL-EXPECTED-N
     PERFORM POSITION-OF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = 37
             COMPUTE WS-AT = (SM-W-X(WS-I) + 2) * 1000 + SM-W-Y(WS-I) + 2
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 the off-hand icon cell is at (43, 221)" TO TL-CASE
     MOVE 43221 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-OFFHAND-COUNT
     CALL "SCREEN-BUILD" USING CLIENT-STATE

*>   Meters: hearts and food, no labels.
     MOVE 0 TO WS-LABELS WS-WANT
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL
             ADD 1 TO WS-LABELS
         END-IF
         IF SM-W-KIND(WS-I) = WK-METER AND SM-W-ARG(WS-I) = 1
             COMPUTE WS-AT = SM-W-X(WS-I) * 1000000 + SM-W-Y(WS-I) * 1000 + SM-W-STATE(WS-I)
             MOVE SM-W-ACTION(WS-I) TO WS-WANT
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 the heart meter is at (69, 201) holding 17 of 20 half hearts" TO TL-CASE
     MOVE 69201017 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-5 the heart meter's maximum is 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-WANT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-AT WS-WANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-METER AND SM-W-ARG(WS-I) = 2
             COMPUTE WS-AT = SM-W-X(WS-I) * 1000000 + SM-W-Y(WS-I) * 1000 + SM-W-STATE(WS-I)
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 the food meter is at (242, 201) holding 20 half food" TO TL-CASE
     MOVE 242201020 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US6-5 the HUD has no text labels" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LABELS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A health below zero (a stale value) shows no hearts filled, never a negative count.
     MOVE -3 TO PL-HEALTH
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE -1 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-METER AND SM-W-ARG(WS-I) = 1
             MOVE SM-W-STATE(WS-I) TO WS-AT
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 a health of -3 gives a heart meter value of 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO PL-HEALTH
     CALL "SCREEN-BUILD" USING CLIENT-STATE

*>   Quads: the two meters add 10 + 9 + 10 + 10 = 39 quads (234 vertices) over the creative HUD.
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE RL-UI-COUNT TO WS-SURVIVAL-UI
*>   Which sprite fills a heart: the hearts are drawn from the last slot down to slot 0 (49 section 5.2, the order of the random numbers), so
*>   slot 9 (vertex 19) has only its container, slot 8 (vertex 25 container, 31 half) is half (health 17 = 8 full hearts and a half) and
*>   slot 7 (vertex 37 container, 43 full) is full; the first 18 vertices are the crosshair, hotbar and selection.
     COMPUTE WS-U = GS-X(GSP-HEART-VARIANT-0) / UA-W
     COMPUTE WS-V = GS-Y(GSP-HEART-VARIANT-0) / UA-H
     MOVE "acceptance US6-5 heart 8 is filled with the full sprite" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UI-U(43) > WS-U - 0.00001 AND RL-UI-U(43) < WS-U + 0.00001
             AND RL-UI-V(43) > WS-V - 0.00001 AND RL-UI-V(43) < WS-V + 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-U = GS-X(GSP-HEART-VARIANT-0 + 2) / UA-W
     COMPUTE WS-V = GS-Y(GSP-HEART-VARIANT-0 + 2) / UA-H
     MOVE "acceptance US6-5 heart 9 is filled with the half sprite" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UI-U(31) > WS-U - 0.00001 AND RL-UI-U(31) < WS-U + 0.00001
             AND RL-UI-V(31) > WS-V - 0.00001 AND RL-UI-V(31) < WS-V + 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-U = GS-X(GSP-HEART-CONTAINER) / UA-W
     COMPUTE WS-V = GS-Y(GSP-HEART-CONTAINER) / UA-H
     MOVE "acceptance US6-5 heart 10 (slot 9, drawn first) is a container alone (the next quad is slot 8's container)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF RL-UI-U(19) > WS-U - 0.00001 AND RL-UI-U(19) < WS-U + 0.00001
             AND RL-UI-V(19) > WS-V - 0.00001 AND RL-UI-V(19) < WS-V + 0.00001
             AND RL-UI-U(25) > WS-U - 0.00001 AND RL-UI-U(25) < WS-U + 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-METER
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US6-5 in creative no meter is built" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "UI-RENDER" USING CLIENT-STATE
     MOVE "acceptance US6-5 the meters render 39 quads (234 vertices) of 9 x 9 sprites" TO TL-CASE
     MOVE 234 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SURVIVAL-UI - RL-UI-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Sprite widget of row WS-ROW: WS-AT its x * 1000000 + y * 1000 + w, or 0 when there is none.
 FIND-SPRITE.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE AND SM-W-ARG(WS-I) = WS-ROW
             COMPUTE WS-AT = SM-W-X(WS-I) * 1000000 + SM-W-Y(WS-I) * 1000 + SM-W-W(WS-I)
         END-IF
     END-PERFORM
     .
*> The expected value of the asserts above is x y w in the same packing: x * 1000000 + y * 1000 + w.
 POSITION-OF.
     MOVE WS-AT TO TL-OBSERVED-N
     .
 END PROGRAM ACC-F2US6-HUD-SPRITES.

 COPY CLTEST.
