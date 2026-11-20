*> The brewing stand as a live container menu and block entity (docs/protocol/40-menus-2 section 4, 31-2 section 4; lane p70c, T23502): MN-CFAMILY 9 (menu-container.cob), the block entity type 12 of
*> CORE-BE (slots 0 to 2 the bottles, 3 the ingredient, 4 the fuel; BE-XI 1 brewTime, 2 totalBrewTime, 3 fuel, 4 totalFuel, 6 the remembered ingredient, 7 to 9 the bottle flags; BE-XF 1 the speed). The
*> tick of every loaded brewing stand is BREW-TICK-LIVE (BE-TICK-ALL); the data slots 0 to 3 of the open menu are brewTime, fuel, totalBrewTime, totalFuel (MENU-DATA-SYNC).
*> The brewing recipes are the rows of RC-STORE with the serializer 20: RR-ING 1 the bottle item, RR-ING 2 the ingredient item, RR-RESULT-ID the output item, RR-EXTRA "<input potion> <output potion>"
*> (the potions of the input's potion_contents condition and of the output's potion_contents component, content/src/recipes.cob).
*>   BREW-IS-INPUT USING item, flag out         the item may be a bottle: it is the input item of a brewing recipe (the set brewing_input) or in the tag brewing_potion_inputs
*>   BREW-IS-REAGENT USING item, flag out       the item is the ingredient of a brewing recipe (the set brewing_reagent)
*>   BREW-STAND-FUEL USING item, uses out, speed out (FLOAT-LONG)   the brewing_fuel of a stack: blaze_powder (the only item with the component, 25-5 section 2.4), uses of brewing/uses_default and the speed
*>        of brewing/speed_default (fallbacks of 31-2 section 4.3: 0 uses, 1.0); another item has none
*>   BREW-TICK-LIVE USING block entity index, dim   the tick (31-2 section 4.5): BE2-BREW-TICK, the brew-complete level event 1035 and the has_bottle_0..2 properties of the block
*>   MENU-BREW-MAYPLACE USING own slot, item, ok out   the slot rules of 40-2 section 4.3
*>   MENU-BREW-QUICK USING row, menu slot, item out, count out   quickMoveStack (40-2 section 4.4)
*> Gaps: the crafting remainder of the fuel and the ingredient (none in the data: blaze powder and the ingredients have no remainder) is not made.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-IS-INPUT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:brewing_potion_inputs".
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-ING                 PIC X(48).
 01 WS-ING-BARE            PIC X(48).
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM L-FLAG
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT
         IF RR-SERIALIZER(WS-R) = 20
             MOVE RR-ING(WS-R, 1)(1:48) TO WS-ING
             CALL "KEY-BARE" USING WS-ING WS-ING-BARE
             IF WS-ING-BARE = WS-BARE
                 MOVE 1 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREW-IS-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-IS-REAGENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-ING                 PIC X(48).
 01 WS-ING-BARE            PIC X(48).
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT
         IF RR-SERIALIZER(WS-R) = 20
             MOVE RR-ING(WS-R, 2)(1:48) TO WS-ING
             CALL "KEY-BARE" USING WS-ING WS-ING-BARE
             IF WS-ING-BARE = WS-BARE
                 MOVE 1 TO L-FLAG
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREW-IS-REAGENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-STAND-FUEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-NAME                PIC X(112).
 01 WS-PAYLOAD             PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-VALUE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-USES                 BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ITEM L-USES L-SPEED.
     MOVE 0 TO L-USES
     MOVE 1.0 TO L-SPEED
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
     IF WS-BARE NOT = "blaze_powder"
         GOBACK
     END-IF
     MOVE "brewing/uses_default" TO WS-NAME
     CALL "BE2-PROVIDER-LOOKUP" USING WS-NAME WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH WS-FAST WS-VALUE WS-OK
         IF WS-OK = 1
             COMPUTE L-USES = FUNCTION INTEGER(WS-VALUE)
         END-IF
     END-IF
     MOVE "brewing/speed_default" TO WS-NAME
     CALL "BE2-PROVIDER-LOOKUP" USING WS-NAME WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH WS-FAST WS-VALUE WS-OK
         IF WS-OK = 1
             MOVE WS-VALUE TO L-SPEED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREW-STAND-FUEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREW-TICK-LIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-USES                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1035.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DIM.
     MOVE 0 TO WS-USES
     MOVE 1.0 TO WS-SPEED
     IF BE-SLOT-COUNT(L-INDEX, 5) > 0
         CALL "BREW-STAND-FUEL" USING BE-SLOT-ITEM(L-INDEX, 5) WS-USES WS-SPEED
     END-IF
     CALL "BE2-BREW-TICK" USING L-INDEX WS-USES WS-SPEED WS-DONE WS-CHANGED
     IF WS-DONE = 1
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-ZERO WS-ZERO2
     END-IF
     IF WS-CHANGED = 1
*>       The properties has_bottle_0 to has_bottle_2 follow the three bottle slots; a block that is no brewing stand stays as it is (4.5 step 6).
         CALL "WORLD-GET-BLOCK" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
         CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-MASK WS-FLAG
         IF WS-FAMILY = 9
             MOVE 0 TO WS-MASK
             PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 2
                 IF BE-SLOT-COUNT(L-INDEX, WS-S + 1) > 0
                     COMPUTE WS-MASK = WS-MASK + 2 ** WS-S
                 END-IF
             END-PERFORM
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             CALL "BE-STATE-MAKE" USING WS-BLOCK WS-DIR WS-MASK WS-FLAG WS-NEW
             IF WS-NEW NOT = WS-STATE
                 CALL "BLOCK-CHANGE" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW
             END-IF
         END-IF
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM BREW-TICK-LIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BREW-MAYPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INP                 BINARY-LONG.
 01 WS-TAG                 BINARY-LONG.
 01 WS-REA                 BINARY-LONG.
 01 WS-FUEL                BINARY-LONG.
 01 WS-USES                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-CAP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ITEM L-OK.
     CALL "BREW-IS-INPUT" USING L-ITEM WS-INP
     MOVE 0 TO WS-TAG
     CALL "BREW-IS-REAGENT" USING L-ITEM WS-REA
     CALL "BREW-STAND-FUEL" USING L-ITEM WS-USES WS-SPEED
     MOVE 0 TO WS-FUEL
     IF WS-USES > 0
         MOVE 1 TO WS-FUEL
     END-IF
     CALL "MN2-BREW-MAYPLACE" USING L-SLOT WS-INP WS-TAG WS-REA WS-FUEL L-OK WS-CAP
     GOBACK.
 END PROGRAM MENU-BREW-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-BREW-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FUEL                BINARY-LONG.
 01 WS-REA                 BINARY-LONG.
 01 WS-POT                 BINARY-LONG.
 01 WS-USES                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RULE                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REV                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-FIRST2              BINARY-LONG.
 01 WS-END2                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     CALL "BREW-STAND-FUEL" USING WS-ITEM WS-USES WS-SPEED
     MOVE 0 TO WS-FUEL
     IF WS-USES > 0
         MOVE 1 TO WS-FUEL
     END-IF
     CALL "BREW-IS-REAGENT" USING WS-ITEM WS-REA
     CALL "BREW-IS-INPUT" USING WS-ITEM WS-POT
     CALL "MN2-BREW-ROUTE" USING L-SLOT WS-FUEL WS-REA WS-POT WS-RULE WS-FIRST WS-END WS-REV WS-MODE
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-END WS-REV WS-MOVED WS-VAR
*>   A fuel that fits the fuel slot ends the call at once (the tail is skipped, 4.4 rule 2); one that does not goes to the ingredient slot when it is a reagent.
     IF WS-MODE = 2
         IF WS-MOVED = 1
             CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-LEFT WS-VAR
             GOBACK
         END-IF
         CALL "MN2-BREW-FALLBACK" USING WS-REA WS-GO WS-FIRST2 WS-END2
         IF WS-GO = 1
             CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST2 WS-END2 WS-REV WS-MOVED WS-VAR
         END-IF
     END-IF
     IF WS-MOVED = 0
         GOBACK
     END-IF
     CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     GOBACK.
 END PROGRAM MENU-BREW-QUICK.
