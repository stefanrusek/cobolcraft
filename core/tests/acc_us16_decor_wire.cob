*> Acceptance test, the decoration items and entities through the real play path (lane 002-lane-mobsb6, T9011): Use Item On with an armor stand, an item frame, a painting and a minecart
*> (44 part 9 sections 4.2, 5.3 and 5.4, 44 part 8 section 4), Interact on an armor stand, a frame and a furnace minecart, and Attack on an armor stand, a frame and a painting.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-DECOR-WIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-RAIL                BINARY-LONG.
 01 WS-STAND-ITEM          BINARY-LONG.
 01 WS-FRAME-ITEM          BINARY-LONG.
 01 WS-PAINT-ITEM          BINARY-LONG.
 01 WS-CART-ITEM           BINARY-LONG.
 01 WS-COAL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 1.
 01 WS-FACE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
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
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:rail" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-RAIL
     MOVE "minecraft:armor_stand" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STAND-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:item_frame" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-FRAME-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:painting" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PAINT-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:furnace_minecart" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CART-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:coal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COAL WS-ITEM-ROW WS-STATUS
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
*>   Armor stand on the floor block east of the player: face up, so it stands in the cell above.
     MOVE WS-STAND-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     COMPUTE WS-CX = WS-X0 + 3
     MOVE 1 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-GY WS-Z0 WS-FACE WS-SEQ
     MOVE 11 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US16 44-9 4.2 Use Item On with an armor stand item makes one stand" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 4.2 and uses one item of the stack" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 4.2 it stands on the clicked block (y in millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-Y0 * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Interact: an empty hand clicking the empty stand does nothing, a helmet is not worn without a kind test; use coal on a furnace cart below.
*>   Attack: two quick hits break the stand.
     MOVE EN-ID(WS-ROW) TO WS-TARGET
     CALL "TEST-ATTACK" USING WS-CONN WS-TARGET
     MOVE CW-TICKS TO WS-SLOT
     CALL "TEST-ATTACK" USING WS-CONN WS-TARGET
     MOVE "acceptance US16 44-9 4.4 two Attack packets within 5 ticks break the stand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Item frame on a wall block: clicked face north.
     PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > 1
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-CX = WS-X0 + 2 + WS-I
             COMPUTE WS-CY = WS-Y0 + WS-J
             COMPUTE WS-CZ = WS-Z0 + 2
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE WS-FRAME-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     COMPUTE WS-CX = WS-X0 + 2
     COMPUTE WS-CY = WS-Y0 + 1
     COMPUTE WS-CZ = WS-Z0 + 2
     MOVE 2 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-CZ WS-FACE WS-SEQ
     MOVE 12 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US16 44-9 5.3 Use Item On with an item frame on a wall makes a frame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Interact with a stick: the frame takes it.
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COAL WS-ITEM-ROW WS-STATUS
     MOVE WS-COAL TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE EN-ID(WS-ROW) TO PSB-TARGET
     MOVE 0 TO PSB-HAND
     MOVE 0 TO PSB-Y
     CALL "MOB-INTERACT" USING WS-CONN PLAY-SERVERBOUND
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 44-9 5.3 Interact with a stick puts it in the frame" TO TL-CASE
     MOVE WS-COAL TO TL-EXPECTED-N
     MOVE PJ-I2(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Attack: the first hit takes the stick out, the second breaks the frame.
     MOVE EN-ID(WS-ROW) TO WS-TARGET
     CALL "TEST-ATTACK" USING WS-CONN WS-TARGET
     CALL "TEST-ATTACK" USING WS-CONN WS-TARGET
     MOVE "acceptance US16 44-9 5.3 two Attack packets empty and break the frame" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Painting on the same wall (the stand-in variant is 1 x 1).
     MOVE WS-PAINT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 2 TO WS-FACE
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-CZ WS-FACE WS-SEQ
     MOVE 13 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US16 44-9 5.4 Use Item On with a painting item makes a painting" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-ROW) TO WS-TARGET
     CALL "TEST-ATTACK" USING WS-CONN WS-TARGET
     MOVE "acceptance US16 44-9 5.4 an Attack packet breaks the painting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A furnace minecart item on a rail: the cart stands on the rail.
     COMPUTE WS-CX = WS-X0 - 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y0 WS-Z0 WS-RAIL
     MOVE WS-CART-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 1 TO WS-FACE
     COMPUTE WS-CY = WS-Y0
     CALL "TEST-USE-ON" USING WS-CONN WS-CX WS-CY WS-Z0 WS-FACE WS-SEQ
     MOVE 10 TO WS-KIND
     PERFORM COUNT-KIND
     MOVE "acceptance US16 44-8 4 Use Item On with a minecart item on a rail makes a cart (kind 4, furnace)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT = 1
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
         COMPUTE TL-OBSERVED-N = 10 + PJ-I1(WS-SLOT)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Interact with coal: the cart gets 3600 ticks of fuel.
     MOVE "minecraft:coal" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-COAL WS-ITEM-ROW WS-STATUS
     MOVE WS-COAL TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE EN-ID(WS-ROW) TO PSB-TARGET
     CALL "MOB-INTERACT" USING WS-CONN PLAY-SERVERBOUND
     MOVE "acceptance US16 44-8 4.6 coal on a furnace cart gives it 3600 ticks of fuel and uses one coal" TO TL-CASE
     MOVE 36001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I3(WS-SLOT) * 10 + PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-KIND.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = WS-KIND
             ADD 1 TO WS-COUNT
             MOVE PJ-ENT(WS-I) TO WS-TARGET
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ID(WS-I) = WS-TARGET AND WS-COUNT > 0
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US16-DECOR-WIRE.
 COPY CORETEST.
 COPY MOBSPTEST.
