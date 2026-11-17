*> Implementation test (lane covB; docs/protocol/19 and 21): Interact (use on entity) with the mobs that have a use of their own: a villager with offers opens the merchant window and ends the
*> interaction, a zombie villager, a piglin and an armadillo with a brush each reach their use handler.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-INTERACT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY CMENU.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-GOLD                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NAMES.
    05 FILLER              PIC X(32) VALUE "minecraft:villager".
    05 FILLER              PIC X(32) VALUE "minecraft:wandering_trader".
    05 FILLER              PIC X(32) VALUE "minecraft:zombie_villager".
    05 FILLER              PIC X(32) VALUE "minecraft:piglin".
    05 FILLER              PIC X(32) VALUE "minecraft:armadillo".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(32) OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:brush" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-BRUSH WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE "minecraft:gold_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-GOLD WS-ITEM-ROW WS-STATUS
     MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 0 TO PSB-HAND PSB-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-NAME(WS-I) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-X = PL-X(WS-PLAYER) + 1.2
         MOVE PL-Y(WS-PLAYER) TO WS-Y
         MOVE PL-Z(WS-PLAYER) TO WS-Z
         CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-ROW
         IF WS-I = 1
             CALL "VL-FIND" USING EN-ID(WS-ROW) WS-ONE WS-SLOT
             MOVE "librarian" TO VL-PROF(WS-SLOT)
             MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
             MOVE 1 TO VL-O-ROW(WS-SLOT, 1)
             MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-DEMAND(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
         END-IF
         IF WS-I = 4
             MOVE WS-GOLD TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
             MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
         END-IF
         IF WS-I = 5
             MOVE WS-BRUSH TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
             MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
         END-IF
         MOVE EN-ID(WS-ROW) TO PSB-TARGET
         CALL "MOB-INTERACT" USING WS-CONN PLAY-SERVERBOUND
         IF WS-I = 4
             MOVE "covB 21 piglin a gold ingot offered by Interact starts the admiring and costs one ingot" TO TL-CASE
             MOVE 1190001 TO TL-EXPECTED-N
             COMPUTE TL-OBSERVED-N = EN-ADMIRE(WS-ROW) * 10000 + PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
         IF WS-I = 1
             MOVE "covB 19 22.4 interacting with a villager with offers opens the merchant window (type 19)" TO TL-CASE
             MOVE 19 TO TL-EXPECTED-N
             MOVE MN-TYPE(WS-PLAYER) TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "covB 19 interacting with " WS-NAME(WS-I) " leaves it alive" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-COVB-INTERACT.
 COPY CORETEST.
 COPY MOBSPTEST.
