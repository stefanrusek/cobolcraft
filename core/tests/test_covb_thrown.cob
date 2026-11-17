*> Implementation test (lane covB; docs/protocol/44 part 8 and 9, 21 section 7): the thrown entity layer's less common paths: THROWN-TICK dispatching every kind (cloud, eye of ender, firework,
*> lightning, minecart, wither, wither skull, dragon, dragon fireball) and freeing a record whose entity is gone, the content set without thrown entities, an unknown key, instant healing of a mob,
*> the cloud radius on use ending a cloud, victim replacement by the earliest expiry, steps of rows that are no projectile and a full projectile table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-THROWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY CONTENT.
 COPY DRAGSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZA                  FLOAT-LONG VALUE 0.
 01 WS-ZB                  FLOAT-LONG VALUE 0.
 01 WS-ZC                  FLOAT-LONG VALUE 0.
 01 WS-VX                  FLOAT-LONG VALUE 0.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-COW                 BINARY-LONG.
 01 WS-CLOUD               BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FIREWORK            BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-CART                BINARY-LONG.
 01 WS-WITHER              BINARY-LONG.
 01 WS-SKULL               BINARY-LONG.
 01 WS-DRAGON              BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-ORPHAN              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-SAVED-TYPE          BINARY-LONG.
 01 WS-RADIUS              FLOAT-LONG VALUE 1.0.
 01 WS-DURATION            BINARY-LONG VALUE -1.
 01 WS-WAIT                BINARY-LONG VALUE 0.
 01 WS-REAPP               BINARY-LONG VALUE 20.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HEAL-FX             BINARY-LONG VALUE 5.
 01 WS-SPEED-FX            BINARY-LONG VALUE 1.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-SCALE               BINARY-LONG VALUE 1000.
 01 WS-HEAD                BINARY-LONG VALUE 0.
 01 WS-DANGEROUS           BINARY-LONG VALUE 0.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-GONE                BINARY-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-SURVIVES            BINARY-LONG VALUE 1.
 01 WS-STARS               BINARY-LONG VALUE 0.
 01 WS-ATTACHED            BINARY-LONG VALUE 0.
 01 WS-LIFE                BINARY-LONG VALUE 5.
 01 WS-BOLT-VISUAL         BINARY-LONG VALUE 1.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
*>   A cow far from the player, for the cases that need a row without a projectile record.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 30
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
*>   An unknown entity key gives no type.
     MOVE "minecraft:no_such_entity" TO WS-KEY
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     MOVE "covB 44-8 an unknown thrown entity key has no type" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Instant healing a mob (not the potion's own undead check): a hurt cow gets healthier; other effects change nothing.
     MOVE 1 TO EN-HEALTH(WS-COW)
     CALL "THROWN-INSTANT" USING WS-COW WS-NONE WS-HEAL-FX WS-AMP WS-SCALE
     MOVE "covB 44-9 instant health heals a mob" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-HEALTH(WS-COW) > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "THROWN-INSTANT" USING WS-COW WS-NONE WS-SPEED-FX WS-AMP WS-SCALE
     MOVE "covB 44-9 an effect that is not instant health or harm is ignored by the instant path" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Rows that are no projectile: the cloud and burst steps leave them alone.
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     CALL "CLOUD-STEP" USING WS-COW
     CALL "POTION-BURST" USING WS-COW WS-NONE
     MOVE "covB 44-9 cloud and burst steps ignore a row with no projectile record" TO TL-CASE
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-COW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A cloud with a radius change on use: when the radius falls under 0.5 the cloud is used up.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-NONE WS-CLOUD
     CALL "PJ-FIND" USING EN-ID(WS-CLOUD) WS-CSLOT
     MOVE -0.7 TO PJ-ROU(WS-CSLOT)
     MOVE 1.0 TO WS-R
     MOVE 0 TO WS-GONE
     CALL "CLOUD-HIT" USING WS-CSLOT WS-COW WS-NONE WS-R WS-GONE
     MOVE "covB 44-9 3 a radius under 0.5 after the use ends the cloud" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Victims: with all 16 places taken the one with the earliest expiry is replaced.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE PJ-V-ENT(WS-CSLOT, WS-I) = 500 + WS-I
         COMPUTE PJ-V-UNTIL(WS-CSLOT, WS-I) = 100 - WS-I
     END-PERFORM
     MOVE 1000 TO PJ-V-UNTIL(WS-CSLOT, 1)
     CALL "CLOUD-VICTIM-ADD" USING WS-CSLOT WS-COW-T
     MOVE "covB 44-9 3 a full victim list replaces the earliest expiry (place 16)" TO TL-CASE
     MOVE WS-COW-T TO TL-EXPECTED-N
     MOVE PJ-V-ENT(WS-CSLOT, 16) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   THROWN-TICK frees a record whose entity is gone.
     CALL "PJ-ALLOC" USING WS-ORPHAN WS-ONE WS-SLOT
     MOVE 777777 TO PJ-ENT(WS-SLOT)
     CALL "THROWN-TICK"
     MOVE "covB 44-8 a projectile record without its entity is freed by the tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PJ-ENT(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   One of each kind, 20 blocks and more east of the player; one tick steps them all.
     COMPUTE WS-X = PL-X(WS-PLAYER) + 20
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 6
     COMPUTE WS-Z = PL-Z(WS-PLAYER) - 20
     CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-NONE WS-CLOUD
     COMPUTE WS-TX = WS-X + 5
     MOVE WS-Y TO WS-TY
     MOVE WS-Z TO WS-TZ
     CALL "EYE-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-TX WS-TY WS-TZ WS-SURVIVES WS-NONE WS-EYE
     CALL "FIREWORK-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-LIFE WS-STARS WS-ATTACHED WS-NONE WS-FIREWORK
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-BOLT-VISUAL WS-BOLT
     CALL "MINECART-SPAWN" USING WS-ONE WS-DIM WS-X WS-Y WS-Z WS-CART
     CALL "WITHER-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-WITHER
     CALL "PJ-FIND" USING EN-ID(WS-WITHER) WS-PJ
     MOVE 0 TO PJ-I1(WS-PJ)
     MOVE 100000 TO PJ-I4(WS-PJ) PJ-I5(WS-PJ)
     MOVE 1000 TO PJ-DUR(WS-PJ)
     CALL "WITHER-SHOOT" USING WS-WITHER WS-HEAD WS-TX WS-TY WS-TZ WS-DANGEROUS WS-SKULL
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-DRAGON
     MOVE "minecraft:dragon_fireball" TO WS-KEY
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY WS-DIM WS-X WS-Y WS-Z WS-VX WS-ZA WS-ZB WS-NONE WS-FIRE
     CALL "PJ-FIND" USING EN-ID(WS-FIRE) WS-PJ
     MOVE 18 TO PJ-KIND(WS-PJ)
     MOVE EN-X(WS-FIRE) TO WS-X1
     MOVE EN-X(WS-SKULL) TO WS-Y1
     CALL "PJ-FIND" USING EN-ID(WS-BOLT) WS-PJ
     MOVE 5 TO PJ-I1(WS-PJ)
     MOVE 1 TO PJ-I3(WS-PJ)
     MOVE 1 TO PJ-I2(WS-PJ)
     CALL "PJ-FIND" USING EN-ID(WS-CLOUD) WS-CSLOT
     CALL "THROWN-TICK"
     MOVE "covB 44-9 3 the tick stepped the cloud" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-TICK(WS-CSLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-EYE) WS-PJ
     MOVE "covB 21 8.12 the tick stepped the eye of ender (life 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-FIREWORK) WS-PJ
     MOVE "covB 44-8 the tick stepped the firework (age 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-BOLT) WS-PJ
     MOVE "covB 21 8.6 the tick stepped the lightning bolt (flash counter 4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PJ-I1(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 44-8 the tick stepped the minecart (it fell)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Y(WS-CART) < WS-Y
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-WITHER) WS-PJ
     MOVE "covB 21 7.2 the tick stepped the wither (tick 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-TICK(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 21 7.2 the tick stepped the wither skull (it moved)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-SKULL) NOT = WS-Y1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 21 6.4 the tick stepped the dragon (tick 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-TICK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 21 6.4 the tick stepped the dragon fireball (it flew east)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-FIRE) > WS-X1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The content set of the custom game has no thrown entities: no type, no cloud, no thrown entity, no lightning.
     MOVE CT-SET-TYPE TO WS-SAVED-TYPE
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE "minecraft:cow" TO WS-KEY
     CALL "THROWN-TYPE" USING WS-KEY WS-TYPE
     MOVE "covB 44-8 the custom content set knows no thrown entity types" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 77 TO WS-CART
     CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-NONE WS-CART
     MOVE "covB 44-9 3 no cloud is made without thrown entity types" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 77 TO WS-CART
     CALL "THROWN-SPAWN" USING WS-ONE WS-KEY WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-NONE WS-CART
     MOVE "covB 44-8 and no thrown entity either" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 77 TO WS-BOLT
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-BOLT-VISUAL WS-BOLT
     MOVE "covB 21 8.6 and no lightning bolt" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BOLT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVED-TYPE TO CT-SET-TYPE
*>   A full projectile table: nothing is spawned and the entity row is released.
     MOVE 0 TO WS-I
     MOVE 1 TO WS-SLOT
     PERFORM UNTIL WS-SLOT = 0
         ADD 1 TO WS-I
         COMPUTE WS-ORPHAN = 880000 + WS-I
         CALL "PJ-ALLOC" USING WS-ORPHAN WS-ONE WS-SLOT
     END-PERFORM
     MOVE "minecraft:dragon_fireball" TO WS-KEY
     MOVE 77 TO WS-CART
     CALL "THROWN-SPAWN" USING WS-ONE WS-KEY WS-DIM WS-X WS-Y WS-Z WS-ZA WS-ZB WS-ZC WS-NONE WS-CART
     MOVE "covB 44-8 with the projectile table full no thrown entity is made" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 77 TO WS-CART
     CALL "CLOUD-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-DURATION WS-WAIT WS-REAPP WS-NONE WS-CART
     MOVE "covB 44-9 3 nor a cloud" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-THROWN.
 COPY CORETEST.
 COPY MOBSPTEST.
