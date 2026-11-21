*> Implementation test (lane covB; docs/protocol/19 section 22, 20 sections 4 and 13): villager helpers with rows they do not apply to (a cow is no breeder, no golem asker), a golem
*> spot over a stained glass pane, a golem check with no spot to be found, ravagers and piglins seen by the hostile-versus-villager tick, price clamps and a ravager table that is full.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-VILLAGERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-COW2                BINARY-LONG.
 01 WS-VIL                 BINARY-LONG.
 01 WS-RAV                 BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-YES                 BINARY-LONG.
 01 WS-PARTNER             BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-PANE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SPAWNED             BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG.
 01 WS-DEMAND              BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-MAXSTACK            BINARY-LONG.
 01 WS-PRICE               BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-COW
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
*>   A cow is no villager: it cannot breed, finds no partner, has no love to tick and no breed step.
     CALL "VL-CAN-BREED-ROW" USING WS-COW WS-YES
     MOVE "covB 19 22 a cow is not a villager that can breed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-PARTNER
     CALL "VL-LOVE-PICK" USING WS-COW WS-PARTNER
     MOVE "covB 19 22 a cow finds no villager partner" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PARTNER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VL-LOVE-TICK" USING WS-COW
     CALL "VL-BREED-STEP" USING WS-COW
     MOVE "covB 19 22 the villager love and breed steps leave a cow alone" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A golem cannot appear over a stained glass pane.
     MOVE "white_stained_glass_pane" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-PANE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 5
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-PANE
     COMPUTE WS-J = WS-BY + 1
     CALL "VL-GOLEM-SPOT" USING WS-DIM WS-BX WS-J WS-BZ WS-OK
     MOVE "covB 19 22 no golem spot over a stained glass pane" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The golem check of a cow: no state, nothing spawned.
     CALL "VL-GOLEM-CHECK" USING WS-COW WS-MIN WS-SPAWNED
     MOVE "covB 19 22 a cow's golem check spawns nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SPAWNED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A villager that slept recently, high in the air with no ground to find a spot on: no golem.
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     MOVE 300 TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-VIL
     CALL "VL-FIND" USING EN-ID(WS-VIL) WS-ONE WS-SLOT
     MOVE 1000 TO CW-TICKS
     MOVE 900 TO VL-LAST-SLEPT(WS-SLOT)
     MOVE 0 TO VL-GOLEM-UNTIL(WS-SLOT)
     CALL "VL-GOLEM-CHECK" USING WS-VIL WS-MIN WS-SPAWNED
     MOVE "covB 19 22 a villager over the void finds no spot for a golem" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SPAWNED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A ravager sees villagers like an illager; a piglin whose foe is stale gives it up.
     MOVE "minecraft:ravager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-RAV
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-RAV) WS-M
     CALL "MOBVS-TICK" USING WS-RAV WS-M WS-HX WS-HZ WS-WALK
     MOVE "covB 20 13.6 the ravager's villager scan runs without a villager near (no walk)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-PIG
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-PIG) WS-M
     MOVE WS-COW TO EN-FOE(WS-PIG)
     MOVE 987654 TO EN-FOE-ID(WS-PIG)
     CALL "MOBVS-TICK" USING WS-PIG WS-M WS-HX WS-HZ WS-WALK
     MOVE "covB 20 13.6 a piglin whose foe is gone forgets it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Prices clamp: a negative demand never lowers the price, nothing costs less than 1 and a stack tops out.
     MOVE 10 TO WS-BASE
     MOVE -50 TO WS-DEMAND
     MOVE 1000 TO WS-MULT
     MOVE 0 TO WS-SPECIAL
     MOVE 64 TO WS-MAXSTACK
     CALL "VIL-PRICE" USING WS-BASE WS-DEMAND WS-MULT WS-SPECIAL WS-MAXSTACK WS-PRICE
     MOVE "covB 19 22.4 a negative demand adds nothing to the price" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-BASE
     MOVE 0 TO WS-DEMAND
     MOVE -9 TO WS-SPECIAL
     CALL "VIL-PRICE" USING WS-BASE WS-DEMAND WS-MULT WS-SPECIAL WS-MAXSTACK WS-PRICE
     MOVE "covB 19 22.4 a price never falls under 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 30 TO WS-BASE
     MOVE 2 TO WS-DEMAND
     MOVE 1000 TO WS-MULT
     MOVE 8 TO WS-SPECIAL
     MOVE 16 TO WS-MAXSTACK
     CALL "VIL-PRICE" USING WS-BASE WS-DEMAND WS-MULT WS-SPECIAL WS-MAXSTACK WS-PRICE
     MOVE "covB 19 22.4 a price never exceeds the stack size" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A full ravager table: the step of a new ravager does nothing.
     MOVE 1 TO WS-SLOT
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-SLOT = 0
         ADD 1 TO WS-I
         COMPUTE WS-J = 700000 + WS-I
         CALL "EVK-RV-FIND" USING WS-J WS-ONE WS-SLOT
     END-PERFORM
     MOVE EN-HEALTH(WS-RAV) TO WS-HEALTH0
     CALL "RAVAGER-STEP" USING WS-RAV WS-STILL
     MOVE "covB 20 13.6 with the ravager table full the step of another ravager does nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STILL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-VILLAGERS.
 COPY CORETEST.
 COPY MOBSPTEST.
