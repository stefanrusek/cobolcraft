*> Implementation test (coverage lane A; docs/protocol/35-worldgen-features-4 section 3.3; core/src/feat-tree-deco2.cob): the lowest layer of a tree that has roots (roots alone; roots and logs
*> at the same height; roots below the logs; neither), and the early exits of the decorators: a beehive whose chosen height holds no log, place_on_ground over several lowest positions,
*> the pale moss decorator with no logs and with a ground patch feature, creaking heart with no logs or a probability of 0, and shelf mushroom with probability 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-DECO2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY JSONDOC.
 COPY XORO.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT1               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(256).
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/deco2".
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
*>   Roots only: the lowest layer is the roots at the lowest y (two of the three).
     MOVE 0 TO TW-NLOG
     MOVE 3 TO TW-NRL
     MOVE 0 TO TW-RL-X(1) MOVE 5 TO TW-RL-Y(1) MOVE 0 TO TW-RL-Z(1)
     MOVE 1 TO TW-RL-X(2) MOVE 3 TO TW-RL-Y(2) MOVE 0 TO TW-RL-Z(2)
     MOVE 2 TO TW-RL-X(3) MOVE 3 TO TW-RL-Y(3) MOVE 5 TO TW-RL-Z(3)
     CALL "FR-DEC-LOWEST"
     MOVE "test cova deco2 roots alone: the lowest layer is the two roots at the lowest height" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Roots and logs at the same height: both are in the layer, the logs first.
     MOVE 1 TO TW-NRL
     MOVE 0 TO TW-RL-X(1) MOVE 4 TO TW-RL-Y(1) MOVE 0 TO TW-RL-Z(1)
     MOVE 2 TO TW-NLOG
     MOVE 1 TO TW-LOG-X(1) MOVE 4 TO TW-LOG-Y(1) MOVE 1 TO TW-LOG-Z(1)
     MOVE 2 TO TW-LOG-X(2) MOVE 5 TO TW-LOG-Y(2) MOVE 1 TO TW-LOG-Z(2)
     CALL "FR-DEC-LOWEST"
     MOVE "test cova deco2 roots and logs at the same height: both are in the lowest layer" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Roots below the logs: the roots only.
     MOVE 2 TO TW-RL-Y(1)
     CALL "FR-DEC-LOWEST"
     MOVE "test cova deco2 roots below the logs: the lowest layer is the root alone" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Neither roots nor logs: an empty layer.
     MOVE 0 TO TW-NRL TW-NLOG
     CALL "FR-DEC-LOWEST"
     MOVE "test cova deco2 neither roots nor logs: an empty lowest layer" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Early exits with the decorator row 1 slot 1 (probability 1 for the first, 0 for the heart and shelf).
     MOVE 1.0 TO TD-PROB(1, 1)
     MOVE 1.0 TO TD-F3(1, 1)
     MOVE 0 TO TD-FT(1, 1)
     CALL "FR-DEC-PALE" USING XR-STATE WS-ONE WS-SLOT1
     CALL "FR-DEC-HEART" USING XR-STATE WS-ONE WS-SLOT1
     MOVE "test cova deco2 pale moss and creaking heart without logs do nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   No logs and no roots: the beehive and place_on_ground do nothing.
     MOVE 0 TO TW-NLOG TW-NRL TW-NCAND
     CALL "FR-DEC-BEEHIVE" USING XR-STATE WS-ONE WS-SLOT1
     CALL "FR-DEC-PLACE" USING XR-STATE WS-ONE WS-SLOT1
     MOVE "test cova deco2 a beehive and place_on_ground without logs or roots add no candidates" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE TW-NCAND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Logs at y 0 and 10: the beehive's chosen height 1 to 3 holds no log.
     MOVE 2 TO TW-NLOG
     MOVE 0 TO TW-LOG-X(1) MOVE 0 TO TW-LOG-Y(1) MOVE 0 TO TW-LOG-Z(1)
     MOVE 0 TO TW-LOG-X(2) MOVE 10 TO TW-LOG-Y(2) MOVE 0 TO TW-LOG-Z(2)
     MOVE 0 TO TW-NLEAF
     CALL "FR-DEC-BEEHIVE" USING XR-STATE WS-ONE WS-SLOT1
     MOVE "test cova deco2 a beehive whose chosen height has no log places nothing (no candidates)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE TW-NCAND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Probability 0: creaking heart and shelf mushroom stop at the draw.
     MOVE 0 TO TD-PROB(1, 1)
     CALL "FR-DEC-HEART" USING XR-STATE WS-ONE WS-SLOT1
     CALL "FR-DEC-SHELF" USING XR-STATE WS-ONE WS-SLOT1
*>   A pale moss patch feature (no_op) on the lowest log: the ground patch is placed at the lowest log's top.
     MOVE '{"type": "minecraft:no_op"}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     MOVE 0 TO WS-IDX
     CALL "FD-FEAT-NODE" USING JSON-DOC WS-ONE WS-IDX
     MOVE WS-IDX TO TD-FT(1, 1)
     CALL "FR-DEC-PALE" USING XR-STATE WS-ONE WS-SLOT1
     MOVE "test cova deco2 the decorators with a no_op patch run to the end" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 1 TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   place_on_ground over several lowest positions (roots at y 3 with different x and z): the box spans them all.
     MOVE 0 TO TW-NLOG
     MOVE 2 TO TW-NRL
     MOVE 5 TO TW-RL-X(1) MOVE 3 TO TW-RL-Y(1) MOVE 5 TO TW-RL-Z(1)
     MOVE 3 TO TW-RL-X(2) MOVE 3 TO TW-RL-Y(2) MOVE 3 TO TW-RL-Z(2)
     CALL "FR-DEC-PLACE" USING XR-STATE WS-ONE WS-SLOT1
     MOVE "test cova deco2 place_on_ground over two lowest roots runs (the layer holds both)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE TW-NLL TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-DECO2.
 COPY NOSPAWN.
 COPY CORETEST.
 COPY COVATEST.
