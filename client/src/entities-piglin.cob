*> The piglin's arm pose from the replica (docs/protocol/57-client-closures-1 section 3.4, 34-2 section 6, task T47300). ENTITY-PIGLIN-TICK counts the ticks of the
*> using flag (ticksUsingItem), ENTITY-PIGLIN-POSE gives the PiglinArmPose ordinal the model reads (EMD-PIGLIN-POSE-OF, the order of 34-2 section 6), the maximum charge
*> and the ticks, PIGLIN-LOVED-ITEM is the item tag piglin_loved (44-6 section 2: 25 items; its tag reference #gold_ores is not expanded: the documents do not list the
*> members of the block-item tag).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PIGLIN-TICK.
*> USING CLIENT-STATE, replica row: one client tick of a piglin's ticksUsingItem: EN-PG-USE counts up while the living entity flags (EN-LIVING, entry 8) say it uses an
*> item (bit 0) and is 0 when it does not.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF FUNCTION MOD(EN-LIVING(L-ROW), 2) = 1
         ADD 1 TO EN-PG-USE(L-ROW)
     ELSE
         MOVE 0 TO EN-PG-USE(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ENTITY-PIGLIN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-LOVED-ITEM.
*> USING item name (PIC X(40), without namespace), flag out (1 when the item is in the tag piglin_loved).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOVED-DATA.
    05 FILLER PIC X(32) VALUE "gold_block".
    05 FILLER PIC X(32) VALUE "gilded_blackstone".
    05 FILLER PIC X(32) VALUE "light_weighted_pressure_plate".
    05 FILLER PIC X(32) VALUE "gold_ingot".
    05 FILLER PIC X(32) VALUE "bell".
    05 FILLER PIC X(32) VALUE "clock".
    05 FILLER PIC X(32) VALUE "golden_carrot".
    05 FILLER PIC X(32) VALUE "glistering_melon_slice".
    05 FILLER PIC X(32) VALUE "golden_apple".
    05 FILLER PIC X(32) VALUE "enchanted_golden_apple".
    05 FILLER PIC X(32) VALUE "golden_helmet".
    05 FILLER PIC X(32) VALUE "golden_chestplate".
    05 FILLER PIC X(32) VALUE "golden_leggings".
    05 FILLER PIC X(32) VALUE "golden_boots".
    05 FILLER PIC X(32) VALUE "golden_horse_armor".
    05 FILLER PIC X(32) VALUE "golden_nautilus_armor".
    05 FILLER PIC X(32) VALUE "golden_sword".
    05 FILLER PIC X(32) VALUE "golden_spear".
    05 FILLER PIC X(32) VALUE "golden_pickaxe".
    05 FILLER PIC X(32) VALUE "golden_shovel".
    05 FILLER PIC X(32) VALUE "golden_axe".
    05 FILLER PIC X(32) VALUE "golden_hoe".
    05 FILLER PIC X(32) VALUE "raw_gold".
    05 FILLER PIC X(32) VALUE "raw_gold_block".
    05 FILLER PIC X(32) VALUE "golden_dandelion".
 01 WS-LOVED REDEFINES WS-LOVED-DATA.
    05 WS-L                PIC X(32) OCCURS 25 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         IF L-NAME = WS-L(WS-I)
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-LOVED-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-PIGLIN-POSE.
*> USING CLIENT-STATE, replica row, pose out (BINARY-LONG: 0 ATTACKING_WITH_MELEE_WEAPON, 1 CROSSBOW_HOLD, 2 CROSSBOW_CHARGE, 3 ADMIRING_ITEM, 4 DANCING, 5 DEFAULT), maximum
*> charge out (FLOAT-LONG, the state's maxCrossbowChageDuration: 25, Quick Charge is not kept by the replica), ticks using the item out (FLOAT-LONG). Dancing is entry 19, a
*> loved item in the off hand (EN-EQ 2) is the tag piglin_loved, charging is entry 18, a charged crossbow is component 51 of the crossbow in the main hand (EN-EQ 1); an
*> aggressive piglin with a melee weapon is not built (the documents do not say what a melee weapon is): that argument is always 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DANCE               BINARY-LONG.
 01 WS-LOVED               BINARY-LONG.
 01 WS-AGGR                BINARY-LONG.
 01 WS-MELEE               BINARY-LONG VALUE 0.
 01 WS-CHARGING            BINARY-LONG.
 01 WS-CHARGED             BINARY-LONG.
 01 WS-BRUTE               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-TICKS                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-POSE L-MAX L-TICKS.
     MOVE EN-PG-DANCING(L-ROW) TO WS-DANCE
     MOVE EN-PG-CHARGING(L-ROW) TO WS-CHARGING
     MOVE 0 TO WS-LOVED WS-CHARGED WS-BRUTE WS-AGGR
     IF EN-KEY(L-ROW) = "piglin_brute"
         MOVE 1 TO WS-BRUTE
     END-IF
     IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(L-ROW) / 4), 2) = 1
         MOVE 1 TO WS-AGGR
     END-IF
     IF EN-EQ(L-ROW, 2) > 0
         MOVE EN-EQ(L-ROW, 2) TO WS-ITEM
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         CALL "PIGLIN-LOVED-ITEM" USING WS-NAME WS-LOVED
     END-IF
     IF EN-EQ(L-ROW, 1) > 0 AND EN-EQ-CHARGED(L-ROW, 1) = 1
         MOVE EN-EQ(L-ROW, 1) TO WS-ITEM
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-NAME = "crossbow"
             MOVE 1 TO WS-CHARGED
         END-IF
     END-IF
     CALL "EMD-PIGLIN-POSE-OF" USING WS-DANCE WS-LOVED WS-AGGR WS-MELEE WS-CHARGING WS-CHARGED WS-BRUTE L-POSE
     MOVE 25 TO L-MAX
     MOVE EN-PG-USE(L-ROW) TO L-TICKS
     GOBACK.
 END PROGRAM ENTITY-PIGLIN-POSE.
