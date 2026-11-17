*> Implementation test (coverage lane A; core/src/crafting-special.cob): the dye colour of an item whose key carries the "minecraft:" namespace, and a firework star recipe whose dye ingredient
*> lets a non-dye (stone) through is refused by the star rule (a bad ingredient: no result).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMS.
 COPY CTRECIPE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-W                   BINARY-LONG VALUE 3.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-GRID.
    05 WS-G                BINARY-LONG OCCURS 9 TIMES.
 01 WS-VARS.
    05 WS-V                BINARY-LONG OCCURS 9 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RVAR                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-SUFFIX              PIC X(8) VALUE "_dye".
 01 WS-COLOR               BINARY-LONG.
 01 WS-SAVED               PIC X(48).
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     MOVE "minecraft:white_dye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE IT-KEY(WS-ID + 1) TO WS-SAVED
     MOVE "minecraft:white_dye" TO IT-KEY(WS-ID + 1)
     CALL "CRAFT-COLOR-OF" USING WS-ID WS-SUFFIX WS-COLOR
     MOVE WS-SAVED TO IT-KEY(WS-ID + 1)
     MOVE "test cova craft the dye colour of a namespaced white_dye key is 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-COLOR TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE "crafting_special_firework_star" TO RR-KEY(WS-ROW)
     MOVE 9 TO RR-SERIALIZER(WS-ROW)
     MOVE "minecraft:diamond" TO RR-ING(WS-ROW, 1)
     MOVE "minecraft:glowstone_dust" TO RR-ING(WS-ROW, 2)
     MOVE "minecraft:gunpowder" TO RR-ING(WS-ROW, 3)
     MOVE "minecraft:stone" TO RR-ING(WS-ROW, 4)
     MOVE "minecraft:firework_star" TO RR-RESULT-ID(WS-ROW)
     MOVE 1 TO RR-RESULT-COUNT(WS-ROW)
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 9
         MOVE 0 TO WS-G(WS-N) WS-V(WS-N)
     END-PERFORM
     MOVE "minecraft:gunpowder" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ID TO WS-G(1)
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ID TO WS-G(2)
     MOVE 0 TO WS-ITEM
     CALL "CRAFT-MATCH-X" USING WS-W WS-H WS-GRID WS-VARS WS-ROW WS-ITEM WS-COUNT WS-RVAR
     MOVE "test cova craft a firework star with a stone as its dye gives no result" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ITEM TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-CRAFT.
 COPY CORETEST.
 COPY COVATEST.
