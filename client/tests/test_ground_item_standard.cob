*> T6601 (lane 002-lane-fixb, B3): a dropped item of a world of the standard set is the entity type `minecraft:item` (registry id 72 in
*> content/copy/gen/entities.cpy), not the stand-in type 1 (ET-LOOSE-ITEM, which a standard set gives to acacia_chest_boat), so
*> GROUND-ITEMS-MESH drew none and a boat row would have been drawn as an item. The ground-item quad is made for a row of the standard
*> set whose key is `item` (EN-VANILLA 1), and for the stand-in type 1 of a cobolcraft world (EN-VANILLA 0) only.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM-STANDARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-EYE.
    05 WS-E                FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 1 TO EN-COUNT
     MOVE 1 TO EN-USED(1)
     MOVE 72 TO EN-TYPE(1)
     MOVE 1 TO EN-VANILLA(1)
     MOVE "item" TO EN-KEY(1)
     MOVE 3 TO EN-STACK-COUNT(1)
     MOVE 4 TO EN-STACK-ITEM(1)
     MOVE 2.5 TO EN-X(1)
     MOVE 12 TO EN-Y(1)
     MOVE 4.5 TO EN-Z(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE
*>   A stack of 3 is 2 copies of the flat model, both faces, 12 vertices each (34-9 section 9.1, VANILLA-ITEMS-MESH of lane misc2).
     MOVE "T6601 a dropped item of the standard set (key item, id 72, a stack of 3) is drawn in 2 copies of 12 vertices" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The stand-in type id 1 of a standard set is a boat: no ground item.
     MOVE 1 TO EN-TYPE(1)
     MOVE "acacia_chest_boat" TO EN-KEY(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE
     MOVE "T6601 type 1 of the standard set (acacia_chest_boat) with a stack is not a ground item" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A cobolcraft world: type 1, EN-VANILLA 0.
     MOVE 0 TO EN-VANILLA(1)
     MOVE SPACES TO EN-KEY(1)
     CALL "GROUND-ITEMS-MESH" USING CLIENT-STATE WS-EYE
     MOVE "T6601 the stand-in loose_item (type 1 of a cobolcraft world) is still drawn" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RL-GI-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
