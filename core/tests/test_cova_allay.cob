*> Implementation test (coverage lane A; docs/protocol/44 part 4 section 7; core/src/mob-44-j.cob): an allay that carries items and whose liked player is farther than 3 blocks flies to the player
*> (the fly target is the player's position at the speed factor 2.25) instead of dropping the items.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-ALLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:allay" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:emerald" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-EMERALD WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X = WS-X + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE WS-EMERALD TO EN-ALLAY-ITEM(WS-ROW)
     MOVE 2 TO EN-ALLAY-COUNT(WS-ROW)
     MOVE 0 TO EN-ALLAY-CD(WS-ROW)
     MOVE PL-UUID(WS-PLAYER) TO EN-ALLAY-LIKED(WS-ROW)
     MOVE 0 TO EN-FLY-ON(WS-ROW)
     CALL "MOB-STEP" USING WS-ROW
     MOVE "test cova allay a loaded allay far from its player starts flying to it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-FLY-ON(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova allay the fly target is the player's x (mm)" TO WS-CASE
     COMPUTE WS-E ROUNDED = PL-X(WS-PLAYER) * 1000
     COMPUTE WS-O ROUNDED = EN-FLY-X(WS-ROW) * 1000
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova allay the items are still carried (2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE EN-ALLAY-COUNT(WS-ROW) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-ALLAY.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
