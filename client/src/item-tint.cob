*> The icon colours of the item tint sources (43 section 7; lane bugguiitems, T59710): the colour a layer of an item's icon is multiplied with (ITEM-NAME-TINT, ITEM-ICON-RGB, ITEM-ICON-TINT) and the
*> flat icon of an item with its layers in those colours (ITEM-FLAT-ICON). The item definitions' `tints` of the shipped items are the table of TINT-ITEM-SOURCE (43 section 7.1); the stack's dye
*> (dyed_color) and potion (potion_contents) come from the player slot (MENU-STACK-TINT).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-POTION-FILL.
*> USING potion id (the registry `potion`, 46 section 4.3: 0 to 45), TINT-ITEM: fills the effect list of the potion (TI-EFF-COUNT, id, amplifier, visible) from 25-5 section 9.3 (the effects with their
*> amplifiers; the durations do not matter for the colour; water, mundane, thick and awkward have none), so that the potion tint source (TI-HAS-POTION 1) weighs them by 43 section 7.3. An id
*> outside the table leaves the list empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POTIONS-DATA.
    05 FILLER PIC X(42) VALUE "                                          ".
    05 FILLER PIC X(42) VALUE "                                          ".
    05 FILLER PIC X(42) VALUE "                                          ".
    05 FILLER PIC X(42) VALUE "                                          ".
    05 FILLER PIC X(42) VALUE "night_vision        0                     ".
    05 FILLER PIC X(42) VALUE "night_vision        0                     ".
    05 FILLER PIC X(42) VALUE "invisibility        0                     ".
    05 FILLER PIC X(42) VALUE "invisibility        0                     ".
    05 FILLER PIC X(42) VALUE "jump_boost          0                     ".
    05 FILLER PIC X(42) VALUE "jump_boost          0                     ".
    05 FILLER PIC X(42) VALUE "jump_boost          1                     ".
    05 FILLER PIC X(42) VALUE "fire_resistance     0                     ".
    05 FILLER PIC X(42) VALUE "fire_resistance     0                     ".
    05 FILLER PIC X(42) VALUE "speed               0                     ".
    05 FILLER PIC X(42) VALUE "speed               0                     ".
    05 FILLER PIC X(42) VALUE "speed               1                     ".
    05 FILLER PIC X(42) VALUE "slowness            0                     ".
    05 FILLER PIC X(42) VALUE "slowness            0                     ".
    05 FILLER PIC X(42) VALUE "slowness            3                     ".
    05 FILLER PIC X(42) VALUE "slowness            3resistance          2".
    05 FILLER PIC X(42) VALUE "slowness            3resistance          2".
    05 FILLER PIC X(42) VALUE "slowness            5resistance          3".
    05 FILLER PIC X(42) VALUE "water_breathing     0                     ".
    05 FILLER PIC X(42) VALUE "water_breathing     0                     ".
    05 FILLER PIC X(42) VALUE "instant_health      0                     ".
    05 FILLER PIC X(42) VALUE "instant_health      1                     ".
    05 FILLER PIC X(42) VALUE "instant_damage      0                     ".
    05 FILLER PIC X(42) VALUE "instant_damage      1                     ".
    05 FILLER PIC X(42) VALUE "poison              0                     ".
    05 FILLER PIC X(42) VALUE "poison              0                     ".
    05 FILLER PIC X(42) VALUE "poison              1                     ".
    05 FILLER PIC X(42) VALUE "regeneration        0                     ".
    05 FILLER PIC X(42) VALUE "regeneration        0                     ".
    05 FILLER PIC X(42) VALUE "regeneration        1                     ".
    05 FILLER PIC X(42) VALUE "strength            0                     ".
    05 FILLER PIC X(42) VALUE "strength            0                     ".
    05 FILLER PIC X(42) VALUE "strength            1                     ".
    05 FILLER PIC X(42) VALUE "weakness            0                     ".
    05 FILLER PIC X(42) VALUE "weakness            0                     ".
    05 FILLER PIC X(42) VALUE "luck                0                     ".
    05 FILLER PIC X(42) VALUE "slow_falling        0                     ".
    05 FILLER PIC X(42) VALUE "slow_falling        0                     ".
    05 FILLER PIC X(42) VALUE "wind_charged        0                     ".
    05 FILLER PIC X(42) VALUE "weaving             0                     ".
    05 FILLER PIC X(42) VALUE "oozing              0                     ".
    05 FILLER PIC X(42) VALUE "infested            0                     ".
 01 WS-POTIONS REDEFINES WS-POTIONS-DATA.
    05 WS-POTION           OCCURS 46 TIMES.
       10 WS-EFFECT        OCCURS 2 TIMES.
          15 WS-EFFECT-NAME PIC X(20).
          15 WS-EFFECT-AMP PIC 9.
 01 WS-E                   BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-POTION               BINARY-LONG.
 COPY CLTINTI.
 PROCEDURE DIVISION USING L-POTION TINT-ITEM.
     MOVE 0 TO TI-EFF-COUNT
     IF L-POTION >= 0 AND L-POTION <= 45
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > 2
             IF WS-EFFECT-NAME(L-POTION + 1, WS-E) NOT = SPACES
                 MOVE WS-EFFECT-NAME(L-POTION + 1, WS-E) TO WS-NAME
                 CALL "TINT-EFFECT-ID" USING WS-NAME WS-ID
                 ADD 1 TO TI-EFF-COUNT
                 MOVE WS-ID TO TI-EFF-ID(TI-EFF-COUNT)
                 MOVE WS-EFFECT-AMP(L-POTION + 1, WS-E) TO TI-EFF-AMP(TI-EFF-COUNT)
                 MOVE 1 TO TI-EFF-VISIBLE(TI-EFF-COUNT)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM TINT-POTION-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-NAME-TINT.
*> USING item name (PIC X(32), without the namespace), layer (the tint index of the face or the layer of the flat model), dye (the stack's dyed_color RGB, -1 none), potion (its potion id, -1 none),
*> rgb out: the colour (0 to 16777215) the source of that layer of the item's `tints` gives (TINT-ITEM-SOURCE, TINT-ITEM-COLOR; the dye of 7 `dye`, the potion colour of 7.3 from the potion's
*> effects, the `potion` default for a potion item without potion_contents); -1 when the layer has no tint (white).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINTI.
 01 WS-DYED                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-LAYER                BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LAYER L-DYE L-POTION L-RGB.
     MOVE -1 TO L-RGB
     MOVE 0 TO WS-DYED
     IF L-DYE >= 0
         MOVE 1 TO WS-DYED
     END-IF
     CALL "TINT-ITEM-SOURCE" USING L-NAME WS-DYED L-LAYER TINT-ITEM
     IF TI-TYPE > 0
         IF WS-DYED = 1
             MOVE 1 TO TI-HAS-DYE
             MOVE L-DYE TO TI-DYE-RGB
         END-IF
         IF L-POTION >= 0
             MOVE 1 TO TI-HAS-POTION
             CALL "TINT-POTION-FILL" USING L-POTION TINT-ITEM
         END-IF
         CALL "TINT-ITEM-COLOR" USING TINT-ITEM
         COMPUTE L-RGB = FUNCTION MOD(TI-COLOUR, 16777216)
     END-IF
     GOBACK.
 END PROGRAM ITEM-NAME-TINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-ICON-RGB.
*> USING CLIENT-STATE, item id, layer, dye, potion (as ITEM-NAME-TINT), rgb out: the tint colour of a layer of the item's icon, -1 for no tint: the item's name from the open set (CL-ITEM-INFO)
*> is the key of ITEM-NAME-TINT; an item of another namespace or an unknown id is untinted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-NAME32              PIC X(32).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-LAYER L-DYE L-POTION L-RGB.
     MOVE -1 TO L-RGB
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     IF WS-KNOWN = 1 AND WS-NS = "minecraft"
         MOVE WS-NAME TO WS-NAME32
         CALL "ITEM-NAME-TINT" USING WS-NAME32 L-LAYER L-DYE L-POTION L-RGB
     END-IF
     GOBACK.
 END PROGRAM ITEM-ICON-RGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-ICON-TINT.
*> USING CLIENT-STATE, item id, layer, dye, potion, tint out (3 FLOAT-SHORT: red, green, blue, 0 to 1; 1 1 1 when the layer is untinted), tinted out (1 when the layer has a tint): the vertex
*> colour of a quad of that layer of the item's icon (ITEM-ICON-RGB).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RGB                 BINARY-LONG.
 01 WS-CH                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-TINT.
    05 L-T                 FLOAT-SHORT OCCURS 3 TIMES.
 01 L-TINTED               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-LAYER L-DYE L-POTION L-TINT L-TINTED.
     MOVE 1 TO L-T(1) L-T(2) L-T(3)
     MOVE 0 TO L-TINTED
     CALL "ITEM-ICON-RGB" USING CLIENT-STATE L-ITEM L-LAYER L-DYE L-POTION WS-RGB
     IF WS-RGB >= 0
         MOVE 1 TO L-TINTED
         COMPUTE WS-CH = WS-RGB / 65536
         COMPUTE L-T(1) = WS-CH / 255
         COMPUTE WS-CH = FUNCTION MOD(WS-RGB, 65536)
         COMPUTE WS-CH = WS-CH / 256
         COMPUTE L-T(2) = WS-CH / 255
         COMPUTE WS-CH = FUNCTION MOD(WS-RGB, 256)
         COMPUTE L-T(3) = WS-CH / 255
     END-IF
     GOBACK.
 END PROGRAM ITEM-ICON-TINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-FLAT-ICON.
*> USING CLIENT-STATE, item id, sprite (layer 0 of the icon: ITEM-SPRITE-OF), dye, potion, x0, y0, x1, y1 (window pixels, FLOAT-SHORT): the flat icon of an item in the icon layer (RL-UI-LAYER 2 of
*> the caller): layer 0 in the colour of the tint of its layer 0 and, where the item's model has a second layer (IS-LAYER1: the leather armour's overlay, the potion's bottle), that sprite in the
*> colour of its layer 1 (an untinted layer is white). The UI tint is left at 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-SHORT VALUE 0.
 01 WS-ZERO2               FLOAT-SHORT VALUE 0.
 01 WS-SIXTEEN             FLOAT-SHORT VALUE 16.
 01 WS-SIXTEEN2            FLOAT-SHORT VALUE 16.
 01 WS-U0                  FLOAT-SHORT.
 01 WS-V0                  FLOAT-SHORT.
 01 WS-U1                  FLOAT-SHORT.
 01 WS-V1                  FLOAT-SHORT.
 01 WS-LAYER               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-RGB                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-SPRITE               BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-POTION               BINARY-LONG.
 01 L-X0                   FLOAT-SHORT.
 01 L-Y0                   FLOAT-SHORT.
 01 L-X1                   FLOAT-SHORT.
 01 L-Y1                   FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-SPRITE L-DYE L-POTION L-X0 L-Y0 L-X1 L-Y1.
     PERFORM VARYING WS-LAYER FROM 0 BY 1 UNTIL WS-LAYER > 1
         MOVE L-SPRITE TO WS-SPRITE
         IF WS-LAYER = 1
             MOVE IS-LAYER1(L-ITEM + 1) TO WS-SPRITE
         END-IF
         IF WS-SPRITE > 0
             CALL "ITEM-ICON-RGB" USING CLIENT-STATE L-ITEM WS-LAYER L-DYE L-POTION WS-RGB
*>           RL-UI-TINT 0 means no tint, so a black tint is the next darker colour.
             MOVE 0 TO RL-UI-TINT
             IF WS-RGB >= 0
                 COMPUTE RL-UI-TINT = FUNCTION MAX(WS-RGB, 1)
             END-IF
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-ZERO WS-ZERO2 WS-U0 WS-V0
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-SIXTEEN WS-SIXTEEN2 WS-U1 WS-V1
             CALL "UI-QUAD" USING CLIENT-STATE L-X0 L-Y0 L-X1 L-Y1 WS-U0 WS-V0 WS-U1 WS-V1
         END-IF
     END-PERFORM
     MOVE 0 TO RL-UI-TINT
     GOBACK.
 END PROGRAM ITEM-FLAT-ICON.
