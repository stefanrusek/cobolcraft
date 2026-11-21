*> Acceptance test, minecart riding, hurting and pushing (docs/protocol/44 part 8 sections 4.4.3, 4.6; lane 002-lane-mobsb8, T9720): a plain cart takes a standing player on interact (seat y +0.1875
*> less the player's attachment 0.6), the rider follows the cart each tick, a hit sets hurt time 10 and adds the damage x 10, above 40 the cart breaks (ejects the rider, drops its item) and a creative
*> hit removes it at once; the push of an entity (cart gets -d x 0.05 x s, the entity d / 4) and the cart against cart rules (aligned carts share the average, a furnace cart keeps its speed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-MINECART-RIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CART                BINARY-LONG.
 01 WS-CART2               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DROPS0              BINARY-LONG.
 01 WS-NONE-ROW            BINARY-LONG VALUE 0.
 01 WS-DROPS               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE 0 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 0 TO WS-Z
     MOVE 1 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CART
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     CALL "MINECART-USE" USING WS-PLAYER WS-CART WS-USED
     MOVE "acceptance US16 44-8 4.6 a standing player boards a plain minecart" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-USED * 10 + FUNCTION MIN(1, EN-RIDER(WS-CART))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 4.6 the rider's vehicle is the cart" TO TL-CASE
     MOVE WS-CART TO TL-EXPECTED-N
     MOVE EN-VEHICLE(WS-PROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 5 the seat is 0.1875 above the cart less the attachment 0.6 (y -0.4125)" TO TL-CASE
     MOVE 1495875 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-Y(WS-PLAYER) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MINECART-USE" USING WS-PLAYER WS-CART WS-USED
     MOVE "acceptance US16 44-8 4.6 a cart with a passenger takes no second one" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The rider follows the cart.
     MOVE 3 TO EN-X(WS-CART)
     CALL "MINECART-STEP" USING WS-CART
     MOVE "acceptance US16 44-8 4.6 the rider follows the cart's tick (x about 3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-X(WS-PLAYER) > 2.5 AND PL-X(WS-PLAYER) < 3.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hurt: the first hit of 3 sets hurt time 10 and damage 30; the second of 3 makes 60 above 40: the cart breaks, the rider is ejected and the item drops.
     CALL "PJ-FIND" USING EN-ID(WS-CART) WS-SLOT
     MOVE 3 TO WS-AMOUNT
     CALL "MINECART-HURT" USING WS-CART WS-AMOUNT WS-NONE-ROW WS-HANDLED
     MOVE "acceptance US16 44-8 2 a hit sets the hurt time to 10 and the damage to 3 x 10" TO TL-CASE
     MOVE 1030 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I4(WS-SLOT) * 100 + PJ-R3(WS-SLOT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-CART) TO WS-ID
     CALL "MINECART-HURT" USING WS-CART WS-AMOUNT WS-NONE-ROW WS-HANDLED
     MOVE 0 TO WS-I
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > PJ-MAX
         IF PJ-ENT(WS-SLOT) = WS-ID
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-8 2 damage above 40 breaks the cart" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 2 and the rider is ejected" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VEHICLE(WS-PROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Creative: a hit removes the cart at once (no drop).
     MOVE 5 TO WS-X
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CART
     MOVE EN-ID(WS-CART) TO WS-ID
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WS-AMOUNT
     CALL "MINECART-HURT" USING WS-CART WS-AMOUNT WS-PLAYER WS-HANDLED
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO WS-I
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > PJ-MAX
         IF PJ-ENT(WS-SLOT) = WS-ID
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-8 2 a creative hit removes the cart at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Chest carts take no rider.
     MOVE 2 TO WS-KIND
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CART
     CALL "MINECART-USE" USING WS-PLAYER WS-CART WS-USED
     MOVE "acceptance US16 44-8 4.6 a chest minecart is not rideable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Push of a non-cart entity (the player's tracker row): the cart gets -0.05 and the entity +0.0125 along x.
     MOVE 1 TO WS-KIND
     MOVE 20 TO WS-X
     MOVE 20 TO WS-Z
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CART
     MOVE 0 TO EN-VX(WS-CART) EN-VZ(WS-CART)
     MOVE 21 TO EN-X(WS-PROW)
     MOVE 150 TO EN-Y(WS-PROW)
     MOVE 20 TO EN-Z(WS-PROW)
     MOVE 0 TO EN-VX(WS-PROW) EN-VZ(WS-PROW)
     CALL "MINECART-PUSH" USING WS-CART WS-PROW
     MOVE "acceptance US16 44-8 4.6 the cart is pushed away from the entity (-0.05)" TO TL-CASE
     MOVE -500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 4.6 the entity is pushed a quarter of that way (+0.0125)" TO TL-CASE
     MOVE 125 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-PROW) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20.005 TO EN-X(WS-PROW)
     MOVE 0 TO EN-VX(WS-CART)
     CALL "MINECART-PUSH" USING WS-CART WS-PROW
     MOVE "acceptance US16 44-8 4.6 an entity closer than 0.01 does not push" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Two aligned carts (yaw 0 faces +x here): the average rule: mine 0.2, theirs 0: mine 0.04 + (0.1 - 0.05), theirs 0.1 + 0.05.
     MOVE 0 TO EN-YAW(WS-CART)
     MOVE 0.2 TO EN-VX(WS-CART)
     MOVE 0 TO EN-VZ(WS-CART)
     MOVE 21 TO WS-X
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-CART2
     MOVE 0 TO EN-VX(WS-CART2) EN-VZ(WS-CART2)
     CALL "MINECART-PUSH" USING WS-CART WS-CART2
     MOVE "acceptance US16 44-8 4.6 aligned carts: this cart keeps 0.2 x 0.2 + (avg - d) = 0.09" TO TL-CASE
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 4.6 the other cart gets avg + d = 0.15" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Carts at an angle (yaw 90) do not interact.
     MOVE 90 TO EN-YAW(WS-CART)
     MOVE 0.2 TO EN-VX(WS-CART)
     MOVE 0 TO EN-VX(WS-CART2)
     CALL "MINECART-PUSH" USING WS-CART WS-CART2
     MOVE "acceptance US16 44-8 4.6 carts at an angle do not interact" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Furnace rules: a plain cart pushed by a furnace cart (other): mine x 0.2 + (theirs - d), theirs x 0.95.
     MOVE 0 TO EN-YAW(WS-CART)
     CALL "PJ-FIND" USING EN-ID(WS-CART2) WS-SLOT
     MOVE 4 TO PJ-I1(WS-SLOT)
     MOVE 0.2 TO EN-VX(WS-CART)
     MOVE 0.1 TO EN-VX(WS-CART2)
     CALL "MINECART-PUSH" USING WS-CART WS-CART2
     MOVE "acceptance US16 44-8 4.6 against a furnace cart: this cart 0.2 x 0.2 + (0.1 - 0.05) = 0.09" TO TL-CASE
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 4.6 the furnace cart keeps 95 percent" TO TL-CASE
     MOVE 950 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   This cart a furnace cart and the other plain: theirs x 0.2, other.push(mine + d), mine x 0.95.
     CALL "PJ-FIND" USING EN-ID(WS-CART2) WS-SLOT
     MOVE 1 TO PJ-I1(WS-SLOT)
     CALL "PJ-FIND" USING EN-ID(WS-CART) WS-SLOT
     MOVE 4 TO PJ-I1(WS-SLOT)
     MOVE 0.2 TO EN-VX(WS-CART)
     MOVE 0.1 TO EN-VX(WS-CART2)
     CALL "MINECART-PUSH" USING WS-CART WS-CART2
     MOVE "acceptance US16 44-8 4.6 a furnace cart against a plain one: the other gets 0.1 x 0.2 + (0.2 + 0.05) = 0.27" TO TL-CASE
     MOVE 2700 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART2) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-8 4.6 and the furnace cart keeps 95 percent (0.19)" TO TL-CASE
     MOVE 1900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-CART) * 10000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The tick pushes carts in contact: the plain cart at speed pushes the cart beside it.
     MOVE 1 TO PJ-I1(WS-SLOT)
     MOVE 0 TO EN-VX(WS-CART2)
     MOVE 21.1 TO EN-X(WS-CART2)
     MOVE 20 TO EN-X(WS-CART)
     MOVE 0 TO EN-VX(WS-CART)
     CALL "MINECART-ENTITIES" USING WS-CART
     MOVE "acceptance US16 44-8 4.4.3 a cart touching another pushes it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-CART2) NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-MINECART-RIDE.
 COPY CORETEST.
 COPY MOBSPTEST.
