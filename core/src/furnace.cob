*> The furnace, smoker and blast furnace (docs/protocol/31-block-entities-2-processing-and-redstone-containers.md section 3; 48-real-data-shapes.md
*> sections 2.3, 4.6 and 4.7; US12): the fuel evaluator, the cooking recipe lookup and the server tick of AbstractFurnaceBlockEntity.
*>
*> Fuel (3.3): the item's component `fuel` (CONTENT-ITEM-COMPONENT, the key of the row's `fuel <key>`) names the context int provider
*> `cooking/time_<key>`; the burn time is that provider evaluated for the furnace, and the speed is `cooking/speed_default`. The providers are
*> the entries of the registry context_int_provider (a number alone; `div` with `left` and a right object; `conditional` with `condition`
*> (block/fast_cooking, true for the smoker and the blast furnace), `on_true` and `on_false`, each the id of another entry that is a number).
*> The text of an entry is scanned for those members (FP-FIELD), no other provider type is evaluated.
*>
*> Recipes (3.4): the rows of RC-STORE with the serializer 14 (smelting), 16 (smoking) or 15 (blasting) whose ingredient holds the input item
*> (an item id or a #tag), the first row in the store's order; its result, cooking time and experience.
*>
*> Entry points:
*>   FP-FIELD USING text (X(2048)), length, member name (X(32)), name length, position out (1 based, the first character of the value; 0 none)
*>   BE2-PROVIDER-LOOKUP USING key (X(112), without namespace), payload out (X(2048)), length out, found out
*>   FURN-PROVIDERS-LOAD USING generated directory     loads the provider files (WORLD-CONTENT-OPEN, standard and debug sets)
*>   BE2-PROVIDER-EVAL USING payload, length, fast (1 or 0), value out (FLOAT-LONG), ok out
*>   FURN-FUEL USING item id, fast (1 or 0), burn time out (0 for no fuel), speed multiplier out (FLOAT-LONG)
*>   FURN-RECIPE USING furnace type (0 furnace, 27 smoker, 28 blast furnace), input item, row out (0 none), result item out, result count out,
*>        cooking time out, experience out (FLOAT-LONG)
*>   FURN-TICK USING block entity index, dim                    serverTick (3.5)
*>   BE-TICK-ALL                                                 FURN-TICK for every live furnace of a loaded chunk (CORE-TICK)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-FIELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEEDLE              PIC X(40).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-NAME L-NAME-LENGTH L-POS.
     MOVE 0 TO L-POS
     MOVE SPACES TO WS-NEEDLE
     STRING '"' L-NAME(1:L-NAME-LENGTH) '"' DELIMITED BY SIZE INTO WS-NEEDLE
     COMPUTE WS-NEEDLE-LENGTH = L-NAME-LENGTH + 2
     COMPUTE WS-LAST = L-LENGTH - WS-NEEDLE-LENGTH + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LAST OR L-POS > 0
         IF L-TEXT(WS-I:WS-NEEDLE-LENGTH) = WS-NEEDLE(1:WS-NEEDLE-LENGTH)
             COMPUTE L-POS = WS-I + WS-NEEDLE-LENGTH
             PERFORM UNTIL L-POS > L-LENGTH OR (L-TEXT(L-POS:1) NOT = SPACE AND L-TEXT(L-POS:1) NOT = ":")
                 ADD 1 TO L-POS
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FP-FIELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-NUMBER.
*> USING text, length, position, value out: the number at the position (up to a comma, brace, bracket or space).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-END                 BINARY-LONG.
 01 WS-TOKEN               PIC X(32).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-POS L-VALUE.
     MOVE L-POS TO WS-END
     PERFORM UNTIL WS-END > L-LENGTH OR L-TEXT(WS-END:1) = "," OR L-TEXT(WS-END:1) = "}"
             OR L-TEXT(WS-END:1) = "]" OR L-TEXT(WS-END:1) = SPACE OR WS-END - L-POS >= 31
         ADD 1 TO WS-END
     END-PERFORM
     MOVE SPACES TO WS-TOKEN
     MOVE L-TEXT(L-POS:WS-END - L-POS) TO WS-TOKEN
     COMPUTE L-VALUE = FUNCTION NUMVAL(WS-TOKEN)
     GOBACK.
 END PROGRAM FP-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-PROVIDER-LOOKUP.
*> USING key (X(112), without namespace), payload out (X(2048)), length out, found out: the text of the element `minecraft:<key>` of the registry
*> context_int_provider in the element store of the data loaders (CTSHAPE.cpy), loaded by FURN-PROVIDERS-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 01 B-TEXT                 PIC X(2048) BASED.
 01 WS-REGISTRY            PIC X(48) VALUE "context_int_provider".
 01 WS-WANT                PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAYLOAD              PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAYLOAD L-LENGTH L-FOUND.
     MOVE 0 TO L-FOUND L-LENGTH
     MOVE SPACES TO L-PAYLOAD
     MOVE SPACES TO WS-WANT
     STRING "minecraft:" FUNCTION TRIM(L-KEY) DELIMITED BY SIZE INTO WS-WANT
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-WANT WS-ROW
     IF WS-ROW > 0 AND SH-E-LENGTH(WS-ROW) <= 2048
         SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-ROW)
         MOVE SH-E-LENGTH(WS-ROW) TO L-LENGTH
         MOVE B-TEXT(1:L-LENGTH) TO L-PAYLOAD(1:L-LENGTH)
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM BE2-PROVIDER-LOOKUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-PROVIDERS-LOAD.
*> USING generated directory (X(1100)): nothing for the cobolcraft set or a closed one; loads the data files of the providers (LOOT-LOAD of <directory>/vanilla-data: the context int and float
*> providers, and the loot tables with them) into the element store when a standard set was opened; a failed load leaves no provider (a fuel
*> then burns 0) and is logged by the loader.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROOT                PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 PROCEDURE DIVISION USING L-DIR.
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT
         GOBACK
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(L-DIR) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
     CALL "LOOT-LOAD" USING WS-ROOT WS-STATUS
     GOBACK.
 END PROGRAM FURN-PROVIDERS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FP-CONDITIONAL.
*> USING text, length, fast, value out, ok out: the number of the entry that on_true (fast) or on_false names.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REST                PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-PAYLOAD             PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-FAST L-VALUE L-OK.
     MOVE 0 TO L-OK L-VALUE
     MOVE "on_false" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     IF L-FAST = 1
         MOVE "on_true" TO WS-NAME
         MOVE 7 TO WS-NAME-LENGTH
     END-IF
     CALL "FP-FIELD" USING L-TEXT L-LENGTH WS-NAME WS-NAME-LENGTH WS-POS
     IF WS-POS = 0 OR L-TEXT(WS-POS:1) NOT = '"'
         GOBACK
     END-IF
     COMPUTE WS-START = WS-POS + 1
     MOVE WS-START TO WS-END
     PERFORM UNTIL WS-END > L-LENGTH OR L-TEXT(WS-END:1) = '"'
         ADD 1 TO WS-END
     END-PERFORM
     MOVE SPACES TO WS-KEY
     MOVE L-TEXT(WS-START:WS-END - WS-START) TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:102) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     CALL "BE2-PROVIDER-LOOKUP" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "FP-NUMBER" USING WS-PAYLOAD WS-LENGTH WS-FOUND L-VALUE
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM FP-CONDITIONAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE2-PROVIDER-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-LEFT                FLOAT-LONG.
 01 WS-RIGHT               FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAYLOAD              PIC X(2048).
 01 L-LENGTH               BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PAYLOAD L-LENGTH L-FAST L-VALUE L-OK.
     MOVE 0 TO L-OK L-VALUE
     MOVE 1 TO WS-FIRST
     PERFORM UNTIL WS-FIRST > L-LENGTH OR L-PAYLOAD(WS-FIRST:1) NOT = SPACE
         ADD 1 TO WS-FIRST
     END-PERFORM
     IF WS-FIRST > L-LENGTH
         GOBACK
     END-IF
     IF L-PAYLOAD(WS-FIRST:1) = "-" OR (L-PAYLOAD(WS-FIRST:1) >= "0" AND L-PAYLOAD(WS-FIRST:1) <= "9")
         CALL "FP-NUMBER" USING L-PAYLOAD L-LENGTH WS-FIRST L-VALUE
         MOVE 1 TO L-OK
         GOBACK
     END-IF
     MOVE 0 TO WS-COUNT
     INSPECT L-PAYLOAD(1:L-LENGTH) TALLYING WS-COUNT FOR ALL 'div"'
     IF WS-COUNT > 0
         MOVE "left" TO WS-NAME
         MOVE 4 TO WS-POS
         CALL "FP-FIELD" USING L-PAYLOAD L-LENGTH WS-NAME WS-POS WS-FIRST
         IF WS-FIRST > 0
             CALL "FP-NUMBER" USING L-PAYLOAD L-LENGTH WS-FIRST WS-LEFT
             CALL "FP-CONDITIONAL" USING L-PAYLOAD L-LENGTH L-FAST WS-RIGHT L-OK
             IF L-OK = 1 AND WS-RIGHT NOT = 0
                 COMPUTE L-VALUE = WS-LEFT / WS-RIGHT
             ELSE
                 MOVE 0 TO L-OK
             END-IF
         END-IF
     ELSE
         CALL "FP-CONDITIONAL" USING L-PAYLOAD L-LENGTH L-FAST L-VALUE L-OK
     END-IF
     GOBACK.
 END PROGRAM BE2-PROVIDER-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-FUEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-NAME                PIC X(32) VALUE "fuel".
 01 WS-VALUE               PIC X(100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAYLOAD             PIC X(2048).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BURN                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-FAST                 BINARY-LONG.
 01 L-BURN                 BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ITEM L-FAST L-BURN L-SPEED.
     MOVE 0 TO L-BURN
     MOVE 1 TO L-SPEED
     CALL "CONTENT-ITEM-COMPONENT" USING L-ITEM WS-NAME WS-VALUE WS-STATUS
     IF WS-STATUS NOT = CT-OK OR WS-VALUE = SPACES
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "cooking/time_" FUNCTION TRIM(WS-VALUE) DELIMITED BY SIZE INTO WS-KEY
     CALL "BE2-PROVIDER-LOOKUP" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH L-FAST WS-BURN WS-OK
         IF WS-OK = 1
             COMPUTE L-BURN = FUNCTION INTEGER(WS-BURN)
         END-IF
     END-IF
     MOVE "cooking/speed_default" TO WS-KEY
     CALL "BE2-PROVIDER-LOOKUP" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         CALL "BE2-PROVIDER-EVAL" USING WS-PAYLOAD WS-LENGTH L-FAST WS-BURN WS-OK
         IF WS-OK = 1
             MOVE WS-BURN TO L-SPEED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FURN-FUEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-RECIPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-ROW                 PIC X(270).
 01 WS-VIEW REDEFINES WS-ROW.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-TOKEN               PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-HAS                 BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-TAG-REGISTRY        PIC X(48) VALUE "item".
 01 WS-RESULT-ROW          PIC X(270).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-XP                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-TYPE L-ITEM L-ROW L-RESULT L-COUNT L-TIME L-XP.
     MOVE 0 TO L-ROW L-RESULT L-COUNT L-TIME L-XP
     EVALUATE L-TYPE
         WHEN 27
             MOVE 16 TO WS-SERIALIZER
         WHEN 28
             MOVE 15 TO WS-SERIALIZER
         WHEN OTHER
             MOVE 14 TO WS-SERIALIZER
     END-EVALUATE
     CALL "CONTENT-ITEM-BY-ID" USING L-ITEM WS-ROW WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE WS-R-KEY TO WS-KEY
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT OR L-ROW > 0
         IF RR-SERIALIZER(WS-R) = WS-SERIALIZER
             MOVE 1 TO WS-POINTER
             MOVE 0 TO WS-MATCH
             PERFORM UNTIL WS-POINTER > 800 OR WS-MATCH = 1
                 MOVE SPACES TO WS-TOKEN
                 UNSTRING RR-ING(WS-R, 1) DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
                 IF WS-TOKEN(1:10) = "minecraft:"
                     MOVE WS-TOKEN(11:102) TO WS-REST
                     MOVE WS-REST TO WS-TOKEN
                 END-IF
                 IF WS-TOKEN(1:1) = "#"
                     MOVE WS-TOKEN(2:111) TO WS-REST
                     MOVE WS-REST TO WS-TOKEN
                     CALL "CONTENT-TAG-HAS" USING WS-TAG-REGISTRY WS-TOKEN L-ITEM WS-HAS
                     MOVE WS-HAS TO WS-MATCH
                 ELSE
                     IF WS-TOKEN NOT = SPACES AND WS-TOKEN = WS-KEY
                         MOVE 1 TO WS-MATCH
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-MATCH = 1
                 MOVE WS-R TO L-ROW
             END-IF
         END-IF
     END-PERFORM
     IF L-ROW > 0
         MOVE RR-RESULT-ID(L-ROW) TO WS-TOKEN
         CALL "CONTENT-ITEM-BY-KEY" USING WS-TOKEN L-RESULT WS-RESULT-ROW WS-STATUS
         MOVE RR-RESULT-COUNT(L-ROW) TO L-COUNT
         IF L-COUNT < 1
             MOVE 1 TO L-COUNT
         END-IF
         MOVE RR-COOK-TIME(L-ROW) TO L-TIME
         MOVE RR-EXPERIENCE(L-ROW) TO L-XP
     END-IF
     GOBACK.
 END PROGRAM FURN-RECIPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-TOTAL-TIME.
*> USING recipe cooking time, speed multiplier (FLOAT-LONG), total out: totalCookTime of 3.5: ceil(time / speed) when speed > 0, else the time.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-SPEED                FLOAT-SHORT.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-SPEED L-TOTAL.
     MOVE L-TIME TO L-TOTAL
     IF L-SPEED > 0
         COMPUTE WS-Q = L-TIME / L-SPEED
         COMPUTE L-TOTAL = FUNCTION INTEGER(WS-Q)
         IF WS-Q > L-TOTAL
             ADD 1 TO L-TOTAL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FURN-TOTAL-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-SET-INPUT.
*> USING index: setItem of 3.9 for slot 0 when its stack changed: cookingTotalTime is the total of the matching recipe (200 without one),
*> cookingTimer 0, the entity marked unsaved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-XP                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE 200 TO BE-F-COOK-TOTAL(L-INDEX)
     IF BE-SLOT-COUNT(L-INDEX, 1) > 0
         CALL "FURN-RECIPE" USING BE-TYPE(L-INDEX) BE-SLOT-ITEM(L-INDEX, 1) WS-ROW WS-RESULT WS-COUNT WS-TIME WS-XP
         IF WS-ROW > 0
             CALL "FURN-TOTAL-TIME" USING WS-TIME BE-F-SPEED(L-INDEX) BE-F-COOK-TOTAL(L-INDEX)
         END-IF
     END-IF
     MOVE 0 TO BE-F-COOK(L-INDEX)
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM FURN-SET-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY CONTENT.
 01 WS-FAST                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-WAS-LIT             BINARY-LONG.
 01 WS-IS-LIT              BINARY-LONG.
 01 WS-HAS-INPUT           BINARY-LONG.
 01 WS-HAS-FUEL            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-XP                  FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-BURN                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FAMILY              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROWDATA             PIC X(270).
 01 WS-VIEW REDEFINES WS-ROWDATA.
    05 FILLER              PIC X(4).
    05 WS-R-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-INPUT-KEY           PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SPONGE              PIC X(112) VALUE "wet_sponge".
 01 WS-BUCKET              PIC X(112) VALUE "bucket".
 01 WS-WATER               PIC X(112) VALUE "water_bucket".
 01 WS-SPONGE-ID           BINARY-LONG.
 01 WS-BUCKET-ID           BINARY-LONG.
 01 WS-WATER-ID            BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-DIM.
     MOVE 0 TO WS-FAST WS-CHANGED WS-WAS-LIT WS-IS-LIT
     IF BE-TYPE(L-INDEX) = 27 OR BE-TYPE(L-INDEX) = 28
         MOVE 1 TO WS-FAST
     END-IF
     IF BE-F-LIT(L-INDEX) > 0
         MOVE 1 TO WS-WAS-LIT
         SUBTRACT 1 FROM BE-F-LIT(L-INDEX)
         IF BE-F-LIT(L-INDEX) > 0
             MOVE 1 TO WS-IS-LIT
         END-IF
     END-IF
     MOVE 0 TO WS-HAS-INPUT WS-HAS-FUEL
     IF BE-SLOT-COUNT(L-INDEX, 1) > 0
         MOVE 1 TO WS-HAS-INPUT
     END-IF
     IF BE-SLOT-COUNT(L-INDEX, 2) > 0
         MOVE 1 TO WS-HAS-FUEL
     END-IF
     IF WS-IS-LIT = 1 OR (WS-HAS-FUEL = 1 AND WS-HAS-INPUT = 1)
         IF WS-HAS-INPUT = 1
             CALL "FURN-RECIPE" USING BE-TYPE(L-INDEX) BE-SLOT-ITEM(L-INDEX, 1) WS-ROW WS-RESULT WS-COUNT WS-TIME WS-XP
             IF WS-ROW > 0
*>               canBurn (3.5): the result slot is empty, or holds the same item without a patch and has room (99, the item's maximum).
                 MOVE 1 TO WS-OK
                 IF BE-SLOT-COUNT(L-INDEX, 3) > 0
                     MOVE IT-MAX-STACK(WS-RESULT + 1) TO WS-LIMIT
                     IF WS-LIMIT > 99
                         MOVE 99 TO WS-LIMIT
                     END-IF
                     IF BE-SLOT-ITEM(L-INDEX, 3) NOT = WS-RESULT OR BE-SLOT-VAR(L-INDEX, 3) NOT = 0
                             OR BE-SLOT-COUNT(L-INDEX, 3) + WS-COUNT > WS-LIMIT
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-OK = 0
                     MOVE 0 TO BE-F-COOK(L-INDEX)
                 ELSE
                     IF WS-IS-LIT = 0
                         CALL "FURN-FUEL" USING BE-SLOT-ITEM(L-INDEX, 2) WS-FAST WS-BURN WS-SPEED
                         MOVE WS-BURN TO BE-F-LIT(L-INDEX) BE-F-LIT-TOTAL(L-INDEX)
                         MOVE WS-SPEED TO BE-F-SPEED(L-INDEX)
                         IF BE-F-COOK-TOTAL(L-INDEX) > 0 AND BE-F-COOK(L-INDEX) < BE-F-COOK-TOTAL(L-INDEX)
                             COMPUTE WS-RATIO = BE-F-COOK(L-INDEX) / BE-F-COOK-TOTAL(L-INDEX)
                             CALL "FURN-TOTAL-TIME" USING WS-TIME BE-F-SPEED(L-INDEX) BE-F-COOK-TOTAL(L-INDEX)
                             COMPUTE WS-I = FUNCTION INTEGER(WS-RATIO * BE-F-COOK-TOTAL(L-INDEX))
                             IF WS-RATIO * BE-F-COOK-TOTAL(L-INDEX) > WS-I
                                 ADD 1 TO WS-I
                             END-IF
                             MOVE WS-I TO BE-F-COOK(L-INDEX)
                         END-IF
                         IF WS-BURN > 0
*>                           Consuming the fuel (3.7): one item; the crafting remainder (a bucket for a lava bucket) is not modelled.
                             SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, 2)
                             IF BE-SLOT-COUNT(L-INDEX, 2) = 0
                                 MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 2) BE-SLOT-VAR(L-INDEX, 2)
                             END-IF
                             MOVE 1 TO WS-IS-LIT
                             MOVE 1 TO WS-CHANGED
                         END-IF
                     END-IF
                     IF WS-IS-LIT = 1
                         ADD 1 TO BE-F-COOK(L-INDEX)
                         IF BE-F-COOK(L-INDEX) >= BE-F-COOK-TOTAL(L-INDEX)
                             MOVE 0 TO BE-F-COOK(L-INDEX)
                             CALL "FURN-TOTAL-TIME" USING WS-TIME BE-F-SPEED(L-INDEX) BE-F-COOK-TOTAL(L-INDEX)
                             PERFORM FURN-FINISH
                         END-IF
                     ELSE
                         MOVE 0 TO BE-F-COOK(L-INDEX)
                     END-IF
                 END-IF
             END-IF
         ELSE
             MOVE 0 TO BE-F-COOK(L-INDEX)
         END-IF
     ELSE
         IF BE-F-COOK(L-INDEX) > 0
             COMPUTE WS-I = BE-F-COOK(L-INDEX) - 2
             IF WS-I < 0
                 MOVE 0 TO WS-I
             END-IF
             IF WS-I > BE-F-COOK-TOTAL(L-INDEX)
                 MOVE BE-F-COOK-TOTAL(L-INDEX) TO WS-I
             END-IF
             MOVE WS-I TO BE-F-COOK(L-INDEX)
         END-IF
     END-IF
     IF WS-WAS-LIT NOT = WS-IS-LIT
         MOVE 1 TO WS-CHANGED
         CALL "WORLD-GET-BLOCK" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
         CALL "BE-STATE-FIELDS" USING WS-STATE WS-FAMILY WS-DIR WS-TYPE WS-FLAG
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         CALL "BE-STATE-MAKE" USING WS-BLOCK WS-DIR WS-TYPE WS-IS-LIT WS-NEW
         IF WS-NEW NOT = WS-STATE
             CALL "BLOCK-CHANGE" USING L-DIM BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW
         END-IF
     END-IF
     IF WS-CHANGED = 1
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.

*> Moving the result (3.8) and noting the recipe used (3.6).
 FURN-FINISH.
     IF BE-SLOT-COUNT(L-INDEX, 3) = 0
         MOVE WS-RESULT TO BE-SLOT-ITEM(L-INDEX, 3)
         MOVE WS-COUNT TO BE-SLOT-COUNT(L-INDEX, 3)
         MOVE 0 TO BE-SLOT-VAR(L-INDEX, 3)
     ELSE
         ADD WS-COUNT TO BE-SLOT-COUNT(L-INDEX, 3)
     END-IF
     CALL "CONTENT-ITEM-BY-ID" USING BE-SLOT-ITEM(L-INDEX, 1) WS-ROWDATA WS-STATUS
     MOVE SPACES TO WS-INPUT-KEY
     MOVE WS-R-KEY TO WS-INPUT-KEY
     IF WS-INPUT-KEY = WS-SPONGE AND BE-SLOT-COUNT(L-INDEX, 2) > 0
         CALL "CONTENT-ITEM-BY-KEY" USING WS-BUCKET WS-BUCKET-ID WS-ROWDATA WS-STATUS
         IF BE-SLOT-ITEM(L-INDEX, 2) = WS-BUCKET-ID
             CALL "CONTENT-ITEM-BY-KEY" USING WS-WATER WS-WATER-ID WS-ROWDATA WS-STATUS
             MOVE WS-WATER-ID TO BE-SLOT-ITEM(L-INDEX, 2)
         END-IF
     END-IF
     SUBTRACT 1 FROM BE-SLOT-COUNT(L-INDEX, 1)
     IF BE-SLOT-COUNT(L-INDEX, 1) = 0
         MOVE 0 TO BE-SLOT-ITEM(L-INDEX, 1) BE-SLOT-VAR(L-INDEX, 1)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF BE-F-USED-ROW(L-INDEX, WS-I) = WS-ROW
             ADD 1 TO BE-F-USED-COUNT(L-INDEX, WS-I)
             MOVE 5 TO WS-I
         ELSE
             IF BE-F-USED-ROW(L-INDEX, WS-I) = 0
                 MOVE WS-ROW TO BE-F-USED-ROW(L-INDEX, WS-I)
                 MOVE 1 TO BE-F-USED-COUNT(L-INDEX, WS-I)
                 MOVE 5 TO WS-I
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO WS-CHANGED.
 END PROGRAM FURN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE-TICK-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) > 0 AND (BE-TYPE(WS-I) = 0 OR BE-TYPE(WS-I) = 27 OR BE-TYPE(WS-I) = 28)
             CALL "FURN-TICK" USING WS-I BE-DIM(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE-TICK-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-SAVE.
*> USING index, PB-BUFFER: the keys of 3.2 after Items: the four ints, speed_multiplier, and RecipesUsed (the recipe key and its count of every
*> recipe row noted; a row of RC-STORE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CTRECIPE.
 01 WN                     PIC X(112).
 01 WL                     BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SPEED               FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "cooking_time_spent" TO WN MOVE 18 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-F-COOK(L-INDEX)
     MOVE "cooking_total_time" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-F-COOK-TOTAL(L-INDEX)
     MOVE "lit_time_remaining" TO WN
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-F-LIT(L-INDEX)
     MOVE "lit_total_time" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-F-LIT-TOTAL(L-INDEX)
     MOVE "speed_multiplier" TO WN MOVE 16 TO WL
     MOVE BE-F-SPEED(L-INDEX) TO WS-SPEED
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-SPEED
     MOVE "RecipesUsed" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF BE-F-USED-ROW(L-INDEX, WS-I) > 0
             MOVE RR-KEY(BE-F-USED-ROW(L-INDEX, WS-I)) TO WN
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WN)) TO WL
             CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL BE-F-USED-COUNT(L-INDEX, WS-I)
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM FURN-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-LOAD-KEY.
*> USING index, key (X(32)), tag type, PB-BUFFER: reads one of the furnace keys of 3.2 (a missing key keeps the default: BE-LOAD cleared them); an int or
*> float key of another tag type is skipped; RecipesUsed is cleared and filled with the recipes the store knows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CTRECIPE.
 01 WN                     PIC X(112).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 112.
 01 WS-INNER               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPEED               FLOAT-SHORT.
 01 WS-R                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-KEY L-TYPE PB-BUFFER.
     EVALUATE TRUE
         WHEN L-KEY = "RecipesUsed" AND L-TYPE = 10
             MOVE 0 TO WS-N
             INITIALIZE BE-F-USED(L-INDEX, 1) BE-F-USED(L-INDEX, 2) BE-F-USED(L-INDEX, 3) BE-F-USED(L-INDEX, 4)
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER WN WS-CAPACITY WL
                 IF WS-INNER = 0
                     EXIT PERFORM
                 END-IF
                 IF WS-INNER = 3
                     CALL "PB-GET-INT" USING PB-BUFFER WS-COUNT
                     MOVE 0 TO WS-ROW
                     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RC-COUNT OR WS-ROW > 0
                         IF RR-KEY(WS-R) = WN
                             MOVE WS-R TO WS-ROW
                         END-IF
                     END-PERFORM
                     IF WS-ROW > 0 AND WS-N < 4
                         ADD 1 TO WS-N
                         MOVE WS-ROW TO BE-F-USED-ROW(L-INDEX, WS-N)
                         MOVE WS-COUNT TO BE-F-USED-COUNT(L-INDEX, WS-N)
                     END-IF
                 ELSE
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER
                 END-IF
             END-PERFORM
         WHEN L-KEY = "speed_multiplier" AND L-TYPE = 5
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-SPEED
             MOVE WS-SPEED TO BE-F-SPEED(L-INDEX)
         WHEN L-KEY = "cooking_time_spent" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER BE-F-COOK(L-INDEX)
         WHEN L-KEY = "cooking_total_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER BE-F-COOK-TOTAL(L-INDEX)
         WHEN L-KEY = "lit_time_remaining" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER BE-F-LIT(L-INDEX)
         WHEN L-KEY = "lit_total_time" AND L-TYPE = 3
             CALL "PB-GET-INT" USING PB-BUFFER BE-F-LIT-TOTAL(L-INDEX)
         WHEN OTHER
             CALL "NBT-READ-SKIP" USING PB-BUFFER L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM FURN-LOAD-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-MAY-FUEL.
*> USING item, result out: mayPlace of the fuel slot (40-2 section 2.3): an item with a burn time, or the empty bucket (the item key bucket).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-BURN                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "FURN-FUEL" USING L-ITEM WS-FAST WS-BURN WS-SPEED
     IF WS-BURN > 0
         MOVE 1 TO L-RESULT
     END-IF
     IF IT-KEY(L-ITEM + 1) = "bucket" OR IT-KEY(L-ITEM + 1) = "minecraft:bucket"
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FURN-MAY-FUEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FURN-ROUTE.
*> USING block entity index, item, menu slot (3 to 38), first out, end out: where quickMoveStack sends a stack of the player's inventory (40-2 2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-FAST                BINARY-LONG VALUE 0.
 01 WS-BURN                BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TIME                BINARY-LONG.
 01 WS-XP                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ITEM L-SLOT L-FIRST L-END.
     CALL "FURN-RECIPE" USING BE-TYPE(L-INDEX) L-ITEM WS-ROW WS-RESULT WS-COUNT WS-TIME WS-XP
     IF WS-ROW > 0
         MOVE 0 TO L-FIRST
         MOVE 1 TO L-END
         GOBACK
     END-IF
     CALL "FURN-FUEL" USING L-ITEM WS-FAST WS-BURN WS-SPEED
     IF WS-BURN > 0
         MOVE 1 TO L-FIRST
         MOVE 2 TO L-END
         GOBACK
     END-IF
     IF L-SLOT < 30
         MOVE 30 TO L-FIRST
         MOVE 39 TO L-END
     ELSE
         MOVE 3 TO L-FIRST
         MOVE 30 TO L-END
     END-IF
     GOBACK.
 END PROGRAM FURN-ROUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DATA-SYNC.
*> USING player row: Container Set Data (05a 0x13, id 19) for every data slot of the player's open furnace menu whose value differs from the one
*> last sent (MN-CDATA): 0 lit_time_remaining, 1 lit_total_time, 2 cooking_time_spent, 3 cooking_total_time (40-2 section 2.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY BESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET-ID           BINARY-LONG VALUE 19.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-PROPERTY            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE BE-F-LIT(MN-CBE1(L-ROW)) TO WS-VALUE
             WHEN 2
                 MOVE BE-F-LIT-TOTAL(MN-CBE1(L-ROW)) TO WS-VALUE
             WHEN 3
                 MOVE BE-F-COOK(MN-CBE1(L-ROW)) TO WS-VALUE
             WHEN OTHER
                 MOVE BE-F-COOK-TOTAL(MN-CBE1(L-ROW)) TO WS-VALUE
         END-EVALUATE
         IF WS-VALUE NOT = MN-CDATA(L-ROW, WS-I)
             MOVE WS-VALUE TO MN-CDATA(L-ROW, WS-I)
             COMPUTE WS-PROPERTY = WS-I - 1
             CALL "PB-RESET" USING PB-BUFFER
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
             CALL "PB-PUT-CONTAINER-SET-DATA" USING PB-BUFFER MN-WINDOW(L-ROW) WS-PROPERTY WS-VALUE
             CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-DATA-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MENU-DATA-TICK.
*> No parameters: MENU-DATA-SYNC for every player with an open furnace menu (CORE-TICK, after the block entities ticked).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-CONN(WS-ROW) > 0 AND MN-WINDOW(WS-ROW) > 0 AND MN-CFAMILY(WS-ROW) = 8
             CALL "MENU-DATA-SYNC" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MENU-DATA-TICK.
