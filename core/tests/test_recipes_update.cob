*> Test of the Update Recipes sender of the core (docs/protocol/27 4.3, 05b 0x88; T3662; core/src/recipes-update.cob): the seven
*> property sets built from the recipe store (smithing_base, smithing_template and smithing_addition from smithing recipes,
*> furnace_input, blast_furnace_input, smoker_input and campfire_input from the cooking recipes, each the union of the ingredient items,
*> a "#" tag expanded to its members) and the stonecutter list (the ingredient as a HolderSet, the result as an item stack display,
*> at most 32 entries: the nodes of the display table). Items: greystone 2, loam 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY CTRECIPE.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E                   PIC -(9)9.
 01 WS-REGISTRY            PIC X(48).
 01 WS-TAG                 PIC X(112).
 01 WS-SET                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 0 TO RC-COUNT

     MOVE "test recipes update a tag adds its members once to the set (the block tag mineable/pickaxe: 2, 6, 9, 11, 12), an "
         & "unknown tag adds nothing" TO TL-CASE
     INITIALIZE PB-UPDATE-RECIPES
     MOVE "block" TO WS-REGISTRY
     MOVE "minecraft:mineable/pickaxe" TO WS-TAG
     MOVE 1 TO WS-SET
     CALL "RECIPES-UPDATE-TAG" USING WS-REGISTRY WS-TAG WS-SET PB-UPDATE-RECIPES
     CALL "RECIPES-UPDATE-TAG" USING WS-REGISTRY WS-TAG WS-SET PB-UPDATE-RECIPES
     MOVE "minecraft:nothing_here" TO WS-TAG
     CALL "RECIPES-UPDATE-TAG" USING WS-REGISTRY WS-TAG WS-SET PB-UPDATE-RECIPES
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(1)
         MOVE PB-UR-ITEM(1, WS-J) TO WS-E
         IF WS-J > 1
             STRING "," DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-PERFORM
     MOVE "2,6,9,11,12" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipes update the sets and the stonecutter list of a store of cooking, smithing and stonecutting recipes" TO TL-CASE
     PERFORM NEW-ROW
     MOVE 14 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     PERFORM NEW-ROW
     MOVE 15 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     PERFORM NEW-ROW
     MOVE 16 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 1)
     PERFORM NEW-ROW
     MOVE 16 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:greystone cobolcraft:loam" TO RR-ING(WS-ROW, 1)
     PERFORM NEW-ROW
     MOVE 17 TO RR-SERIALIZER(WS-ROW)
     MOVE "#cobolcraft:no_such_tag" TO RR-ING(WS-ROW, 1)
     PERFORM NEW-ROW
     MOVE 19 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:greystone" TO RR-ING(WS-ROW, 2)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:greystone" TO RR-RESULT-ID(WS-ROW)
     MOVE 2 TO RR-RESULT-COUNT(WS-ROW)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "#cobolcraft:no_such_tag" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
*>   Not stonecutter entries: a tag mixed with an item, an unknown item, an empty ingredient, an unknown result, a list of nine.
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:greystone #cobolcraft:no_such_tag" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(WS-ROW)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:no_such_item" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(WS-ROW)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(WS-ROW)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 1)
     MOVE "cobolcraft:no_such_item" TO RR-RESULT-ID(WS-ROW)
     PERFORM NEW-ROW
     MOVE 18 TO RR-SERIALIZER(WS-ROW)
     MOVE "cobolcraft:loam" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO WS-PTR
     PERFORM 9 TIMES
         STRING "cobolcraft:loam " DELIMITED BY SIZE INTO RR-ING(WS-ROW, 1) POINTER WS-PTR
     END-PERFORM
     CALL "RECIPES-UPDATE-BUILD" USING PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     PERFORM DESCRIBE
     STRING "minecraft:smithing_base=2 ; minecraft:smithing_template=3 ; minecraft:smithing_addition= ; "
         "minecraft:furnace_input=2 ; minecraft:blast_furnace_input=3,2 ; minecraft:smoker_input=2,3 ; "
         "minecraft:campfire_input= ; cuts 2 : list 3 d1 ; tag cobolcraft:no_such_tag d2 ; nodes 2 : 5/2x2 5/3x1"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "test recipes update at most 32 stonecutter entries are sent: the table holds 32 nodes" TO TL-CASE
     PERFORM 40 TIMES
         PERFORM NEW-ROW
         MOVE 18 TO RR-SERIALIZER(WS-ROW)
         MOVE "cobolcraft:loam" TO RR-ING(WS-ROW, 1)
         MOVE "cobolcraft:greystone" TO RR-RESULT-ID(WS-ROW)
         MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     END-PERFORM
     CALL "RECIPES-UPDATE-BUILD" USING PB-UPDATE-RECIPES PB-SLOT-DISPLAY-TABLE
     MOVE PB-UR-CUT-COUNT TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING "cuts " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "cuts 32" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO RC-COUNT
     STOP RUN.

 NEW-ROW.
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE "cobolcraft:test_update" TO RR-KEY(WS-ROW).

*> TL-EXPECTED is cleared by the caller's STRING target being spaces: describes the record into TL-OBSERVED.
 DESCRIBE.
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-SET-COUNT
         IF WS-I > 1
             STRING " ; " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-IF
         STRING PB-UR-KEY(WS-I)(1:PB-UR-KEY-LENGTH(WS-I)) "=" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UR-ITEM-COUNT(WS-I)
             MOVE PB-UR-ITEM(WS-I, WS-J) TO WS-E
             IF WS-J > 1
                 STRING "," DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         END-PERFORM
     END-PERFORM
     MOVE PB-UR-CUT-COUNT TO WS-E
     STRING " ; cuts " FUNCTION TRIM(WS-E) " :" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-UR-CUT-COUNT
         IF PB-UC-TAG-LENGTH(WS-I) > 0
             STRING " tag " PB-UC-TAG(WS-I)(1:PB-UC-TAG-LENGTH(WS-I)) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         ELSE
             STRING " list " DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PB-UC-INPUT-COUNT(WS-I)
                 MOVE PB-UC-INPUT(WS-I, WS-J) TO WS-E
                 IF WS-J > 1
                     STRING "," DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
                 END-IF
                 STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
             END-PERFORM
         END-IF
         MOVE PB-UC-DISPLAY(WS-I) TO WS-E
         STRING " d" FUNCTION TRIM(WS-E) " ;" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-PERFORM
     MOVE PB-SDT-COUNT TO WS-E
     STRING " nodes " FUNCTION TRIM(WS-E) " :" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-SDT-COUNT
         MOVE PB-SDN-TYPE(WS-I) TO WS-E
         STRING " " FUNCTION TRIM(WS-E) "/" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-SDN-ITEM(WS-I) TO WS-E
         STRING FUNCTION TRIM(WS-E) "x" DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
         MOVE PB-SDN-COUNT(WS-I) TO WS-E
         STRING FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-RECIPES-UPDATE.

 COPY CORETEST.
