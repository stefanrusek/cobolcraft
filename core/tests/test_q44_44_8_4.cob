*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 4.6, the TNT minecart (lane 002-lane-p49j-b, T24200 range): the destroy path
*> (a damage above 40 destroys it and drops tnt_minecart; an igniting source or a horizontal speed squared of 0.01 or more primes it with a random fuse of 0 to 38 and keeps it; an
*> already primed cart keeps its fuse), the shouldSourceDestroy override (an igniting source reaches destroy at a damage of 40 or less), the fall damage explosion (V11: 3 blocks
*> or more) and V10 (a furnace cart at 31000 fuel refuses another item). The other minecart rules are proven by acc_us16_minecart and acc_us16_minecart_ride.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY CONTENT.
 COPY CITEMS.
 01 WS-CASE                PIC X(200).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TNT-ITEM            BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG VALUE 0.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-IGNITES             BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-FKIND
     MOVE "minecraft:tnt_minecart" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-TNT-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 12.5
     COMPUTE WS-Y = WS-FY + 1.0625
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 0.5
     MOVE 5 TO WS-KIND

*>   A still TNT cart hit for 5 points (damage 50 above 40) is destroyed and drops one tnt_minecart item.
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE 5 TO WS-AMOUNT
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "MINECART-HURT" USING WS-ROW WS-AMOUNT WS-ATTACKER WS-HANDLED
     MOVE "acceptance US15 44-8§4.6 a still TNT cart hit for 5 is destroyed" TO WS-CASE
     MOVE 0 TO WS-E
     CALL "PJ-FIND" USING WS-ID WS-O
     PERFORM CHECK-N
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 44-8§4.6 and drops one tnt_minecart item" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ITEMS TO WS-O
     PERFORM CHECK-N

*>   A moving cart (speed squared 0.04 >= 0.01) is primed instead with a fuse of 0 to 38 and stays.
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0.2 TO EN-VX(WS-ROW)
     CALL "MINECART-HURT" USING WS-ROW WS-AMOUNT WS-ATTACKER WS-HANDLED
     MOVE "acceptance US15 44-8§4.6 a moving TNT cart is not destroyed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§4.6 it is primed with a fuse of 0 to 38" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PJ-I3(WS-SLOT) >= 0 AND PJ-I3(WS-SLOT) <= 38
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM COUNT-ITEMS
     MOVE "acceptance US15 44-8§4.6 and drops no item (still the one of before)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ITEMS TO WS-O
     PERFORM CHECK-N
*>   An already primed cart keeps its fuse (the prime is for fuse < 0 only).
     MOVE 50 TO PJ-I3(WS-SLOT)
     MOVE 5 TO WS-AMOUNT
     CALL "MINECART-HURT" USING WS-ROW WS-AMOUNT WS-ATTACKER WS-HANDLED
     MOVE "acceptance US15 44-8§4.6 a cart that is already primed keeps its fuse" TO WS-CASE
     MOVE 50 TO WS-E
     MOVE PJ-I3(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW

*>   An igniting source reaches destroy at a damage of 40 or less (shouldSourceDestroy): damage 10 primes a still cart.
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 1 TO WS-AMOUNT
     MOVE 1 TO WS-IGNITES
     CALL "MINECART-HURT-SRC" USING WS-ROW WS-AMOUNT WS-ATTACKER WS-IGNITES WS-HANDLED
     MOVE "acceptance US15 44-8§4.6 an igniting source of damage 10 primes the cart" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PJ-I3(WS-SLOT) >= 0 AND PJ-I3(WS-SLOT) <= 38
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§4.6 and it is not destroyed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW
*>   A source that does not ignite, at a damage of 40 or less: nothing happens beyond the hurt.
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 0 TO WS-IGNITES
     CALL "MINECART-HURT-SRC" USING WS-ROW WS-AMOUNT WS-ATTACKER WS-IGNITES WS-HANDLED
     MOVE "acceptance US15 44-8§4.6 a plain hit of damage 10 leaves the cart unprimed (fuse -1)" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE PJ-I3(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW

*>   V11 a fall of about 4 blocks explodes the cart on landing; a fall of 2 does not.
     COMPUTE WS-Y = WS-FY + 1 + 2
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0 OR EN-ON-GROUND(WS-ROW) = 1
         CALL "MINECART-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§4.6 V11 a TNT cart that fell 2 blocks does not explode" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§4.6 and its fall distance is back to 0 on the ground" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = FUNCTION INTEGER(EN-FALL(WS-ROW))
     PERFORM CHECK-N
     CALL "PJ-DROP" USING WS-ROW
     COMPUTE WS-Y = WS-FY + 1 + 4.5
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-ROW) = 0 OR EN-ON-GROUND(WS-ROW) = 1
         CALL "MINECART-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 44-8§4.6 V11 a TNT cart that fell 4 blocks explodes (gone)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-ROW) TO WS-O
     PERFORM CHECK-N

*>   V10 a furnace cart at 31000 ticks of fuel refuses another item (31000 + 3600 > 32000).
     MOVE 4 TO WS-KIND
     COMPUTE WS-Y = WS-FY + 1.0625
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 31000 TO PJ-I3(WS-SLOT)
     CALL "MINECART-FUEL" USING WS-ROW WS-X WS-Z WS-ADDED
     MOVE "acceptance US15 44-8§4.6 V10 fuel 31000 refuses another item" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ADDED TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 44-8§4.6 V10 and the fuel stays 31000" TO WS-CASE
     MOVE 31000 TO WS-E
     MOVE PJ-I3(WS-SLOT) TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 COUNT-ITEMS.
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-TNT-ITEM
             ADD 1 TO WS-ITEMS
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-8-4.
 COPY CORETEST.
 COPY MOBSPTEST.
