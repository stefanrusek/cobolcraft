*> Implementation test (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 11, 44-residual-mob-questions-4-land-animals.md sections 1.4 and 10, 44-residual-mob-questions-x2-continuation.md
*> section 7.3): the tadpole grows for 24000 ticks and then becomes a frog; a slime ball ages it up by 20 x (int)((ticksLeft / 20) x 0.1) ticks (worked case 23000 -> 23100 -> 23180); a golden dandelion locks
*> and unlocks the age (locking sets it to 0); a locked tadpole does not age. A frog shoots its tongue at a slime or magma cube of size 1 (never size 2): it walks to it, within 1.75 blocks the target is pulled with
*> speed 0.75, after the 6-tick catch animation the frog eats it (10 damage), the animation ends 4 ticks later; metadata 19 holds the tongue target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TAD                 BINARY-LONG.
 01 WS-FROG                BINARY-LONG.
 01 WS-SLIME               BINARY-LONG.
 01 WS-MAGMA               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FZ0                 BINARY-LONG.
 01 WS-FX0                 BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLIMEBALL           BINARY-LONG.
 01 WS-DANDELION           BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE "N" TO TL-MODE
     MOVE "minecraft:tadpole" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TAD WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:frog" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-FROG WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:slime" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SLIME WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:magma_cube" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MAGMA WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:slime_ball" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SLIMEBALL WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:golden_dandelion" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-DANDELION WS-ITEM-ROW WS-STATUS
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0

*>   Tadpole growth.
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TAD WS-X WS-Y WS-Z WS-YAW WS-A
     MOVE "acceptance US15 minecraft:tadpole a new tadpole has age 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 5 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§11.2 Tadpole: age counts up by 1 a tick" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Feeding: 23000 -> 23100 -> 23180.
     MOVE 23000 TO EN-TAD-AGE(WS-A)
     MOVE WS-SLIMEBALL TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 44-x2§7.3 tadpole fed at 23000 is at 23100" TO TL-CASE
     MOVE 23100 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 44-x2§7.3 tadpole fed again is at 23180" TO TL-CASE
     MOVE 23180 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§11.2 Tadpole: each feeding uses one slime ball" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TAD-AGE(WS-A)
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 44-x2§7.3 a fresh tadpole fed gains 2400 ticks" TO TL-CASE
     MOVE 2400 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§11.2 Tadpole: the empty hand feeds nothing" TO TL-CASE
     MOVE 2400 TO TL-EXPECTED-N
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Golden dandelion locks (age 0) and unlocks; a locked tadpole does not age and cannot be fed.
     MOVE WS-DANDELION TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 44-x2§7.3 a golden dandelion locks the age and sets it to 0" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-LOCKED(WS-A) * 100 + EN-TAD-AGE(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§11.2 Tadpole: the lock is entity data (17)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§11.2 Tadpole: a locked tadpole does not age" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SLIMEBALL TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 19§11.2 Tadpole: a locked tadpole is not fed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-DANDELION TO PL-SLOT-ITEM(WS-PLAYER, 1)
     CALL "MOB-TADPOLE-USE" USING WS-PLAYER WS-A
     MOVE "acceptance US15 44-x2§7.3 a second golden dandelion unlocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-LOCKED(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A right click through the packet reaches the same feeding.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 1
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TAD WS-X WS-Y WS-Z WS-YAW WS-C
     MOVE WS-SLIMEBALL TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO WS-I
     MOVE 0 TO WS-N
     CALL "TEST-INTERACT" USING PL-CONN(WS-PLAYER) EN-ID(WS-C) WS-I WS-N
     MOVE "acceptance US15 minecraft:tadpole a right click with a slime ball feeds it (2400 ticks)" TO TL-CASE
     MOVE 2400 TO TL-EXPECTED-N
     MOVE EN-TAD-AGE(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-C
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3.5
     COMPUTE WS-Z = WS-Z0 + 4.5
*>   Conversion at 24000.
     MOVE 23999 TO EN-TAD-AGE(WS-A)
     MOVE EN-ID(WS-A) TO WS-N
     CALL "MOB-STEP" USING WS-A
     PERFORM FIND-FROG
     MOVE "acceptance US15 44-x2§7.3 at age 24000 the tadpole becomes a frog" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B > 0 AND EN-USED(WS-A) NOT = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-x2§7.3 the frog stands where the tadpole was" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B > 0 AND EN-X(WS-B) = WS-X AND EN-Z(WS-B) = WS-Z
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B
*>   Frog on land: a floor 48 wide around the player; the slime is 3 blocks from the frog, 20 from the player.
     COMPUTE WS-FX0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-FZ0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX0 WS-FZ0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-X = PL-X(WS-PLAYER) + 17
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-FROG WS-X WS-Y WS-Z WS-YAW WS-A
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-SLIME WS-X WS-Y WS-Z WS-YAW WS-B
     MOVE 1 TO EN-VARIANT(WS-B)
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-SLIME WS-X WS-Y WS-Z WS-YAW WS-C
     MOVE 2 TO EN-VARIANT(WS-C)
     MOVE EN-HEALTH(WS-B) TO WS-N
     MOVE 0 TO WS-I
     PERFORM UNTIL EN-TONGUE(WS-A) = 2 OR WS-I > 10
         CALL "MOB-STEP" USING WS-A
         ADD 1 TO WS-I
     END-PERFORM
     MOVE "acceptance US15 44-4§1.4 the frog targets the size-1 slime and walks to it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TONGUE(WS-A) = 2 AND EN-TONGUE-ROW(WS-A) = WS-B AND WS-I <= 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§1.4 within 1.75 blocks the target is pulled toward the frog at 0.75" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-B) < -0.7 AND EN-VX(WS-B) > -0.8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§11.1 Frog: the tongue target is entity data (19)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 5 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§1.4 the catch animation lasts 6 ticks: the slime is alive after 5" TO TL-CASE
     MOVE WS-N TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-4§1.4 after 6 ticks the frog eats it (10 damage)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 5 TIMES
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-4§1.4 the animation ends after 10 ticks and the tongue is back" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-TONGUE(WS-A) + EN-TONGUE-ROW(WS-A)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§1.4 a slime of size 2 is never eaten" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-C) TO TL-OBSERVED-N
     IF EN-HEALTH(WS-C) = 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B
     CALL "ENTITY-REMOVE" USING WS-C
*>   A target that disappears ends the tongue; a magma cube of size 1 is food too.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-MAGMA WS-X WS-Y WS-Z WS-YAW WS-B
     MOVE 1 TO EN-VARIANT(WS-B)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-4§1.4 a magma cube of size 1 is food (frog_food)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-TONGUE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 44-4§1.4 the tongue ends when the target is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TONGUE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Nothing edible within range: no tongue.
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 minecraft:frog without food in range it shoots nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TONGUE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-FROG.
     MOVE 0 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-FROG
             MOVE WS-I TO WS-B
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-19-11.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
