*> Implementation test (002-lane-mobsfull-h5; docs/protocol/20 sections 3.6 and 4.1): equipment population (tier, slot count, item keys), the baby zombie
*> (EN-VARIANT 1, metadata 16, experience x 2.5), the zombie finalize (reinforcement chance, leader), and the variant metadata packet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-MAX-TIER            BINARY-LONG.
 01 WS-MIN-TIER            BINARY-LONG.
 01 WS-MAX-SLOTS           BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-LEADERS             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY40               PIC X(40).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-NOBONUS             BINARY-LONG VALUE 0.
 01 WS-X0                  FLOAT-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
*>   Equipment roll: special multiplier 0 never gives armour; 1 gives it about 15 times in 100.
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 2 TO WS-DIFF
         MOVE 0 TO WS-SPECIAL
         CALL "STDMOB-EQUIP-ROLL" USING XR-STATE WS-DIFF WS-SPECIAL WS-TIER WS-SLOTS
         IF WS-SLOTS > 0
             ADD 1 TO WS-ANY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§3.6 Equipment population: special 0 gives no armour" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ANY WS-MAX-SLOTS WS-MAX-TIER
     MOVE 9 TO WS-MIN-TIER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 2 TO WS-DIFF
         MOVE 1000 TO WS-SPECIAL
         CALL "STDMOB-EQUIP-ROLL" USING XR-STATE WS-DIFF WS-SPECIAL WS-TIER WS-SLOTS
         IF WS-SLOTS > 0
             ADD 1 TO WS-ANY
             MOVE FUNCTION MAX(WS-MAX-SLOTS, WS-SLOTS) TO WS-MAX-SLOTS
             MOVE FUNCTION MAX(WS-MAX-TIER, WS-TIER) TO WS-MAX-TIER
             MOVE FUNCTION MIN(WS-MIN-TIER, WS-TIER) TO WS-MIN-TIER
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§3.6 Equipment population: special 1 gives armour in 15 percent of rolls" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF WS-ANY >= 30 AND WS-ANY <= 100
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§3.6 Equipment population: slots 1 to 4, tier 0 to 5" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF WS-MAX-SLOTS = 4 AND WS-MAX-TIER <= 5 AND WS-MIN-TIER = 0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Item keys: tier 0 leather ... 5 diamond, slots head, chest, legs, feet.
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-TIER
     MOVE 1 TO WS-SLOTS
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 0 head is leather" TO TL-CASE
     MOVE "minecraft:leather_helmet" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-TIER
     MOVE 2 TO WS-SLOTS
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 1 chest is copper" TO TL-CASE
     MOVE "minecraft:copper_chestplate" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-TIER
     MOVE 3 TO WS-SLOTS
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 2 legs is golden" TO TL-CASE
     MOVE "minecraft:golden_leggings" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-TIER
     MOVE 4 TO WS-SLOTS
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 3 feet is chainmail" TO TL-CASE
     MOVE "minecraft:chainmail_boots" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-TIER
     MOVE 1 TO WS-SLOTS
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 4 is iron" TO TL-CASE
     MOVE "minecraft:iron_helmet" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-TIER
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: tier 5 is diamond" TO TL-CASE
     MOVE "minecraft:diamond_helmet" TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-TIER
     CALL "STDMOB-EQUIP-KEY" USING WS-TIER WS-SLOTS WS-KEY40
     MOVE "acceptance US15 20§3.6 Equipment population: a tier above 5 gives nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-KEY40 TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Experience: a baby multiplies the reward by 2.5, truncated.
     MOVE 5 TO WS-BASE
     MOVE 1 TO WS-BABY
     CALL "STDMOB-XP-POINTS" USING WS-BASE WS-BABY WS-POINTS
     MOVE "acceptance US15 20§3.6 Equipment population: a baby zombie gives 12 experience" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-POINTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-BASE
     MOVE 0 TO WS-BABY
     CALL "STDMOB-XP-POINTS" USING WS-BASE WS-BABY WS-POINTS
     MOVE "acceptance US15 20§3.6 Equipment population: an adult gives 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-POINTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Finalize a zombie on Hard late in the world: about 5 in 100 are babies, the reinforcement chance is 0 to 0.1 (leaders more).
     MOVE 3 TO BW-DIFFICULTY
     MOVE 2000000 TO CW-GAME-TIME
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-BABIES WS-LEADERS WS-ANY
     MOVE 0 TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF EN-VARIANT(WS-ROW) = 1
             ADD 1 TO WS-BABIES
         END-IF
         IF EN-REINF(WS-ROW) > 1000
             ADD 1 TO WS-LEADERS
         END-IF
         IF EN-EQUIP(WS-ROW) > 0
             ADD 1 TO WS-ANY
         END-IF
         IF EN-HEALTH(WS-ROW) > 20
             ADD 1 TO WS-HEALTH
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "acceptance US15 20§4.1 Zombie: about 5 in 100 spawn as babies" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF WS-BABIES >= 5 AND WS-BABIES <= 40
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§4.1 Zombie: leaders have a reinforcement chance above 0.1 and more health" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF WS-LEADERS >= 1 AND WS-LEADERS <= 30 AND WS-HEALTH = WS-LEADERS
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§3.6 Equipment population: a finalized zombie sometimes wears armour" TO TL-CASE
     MOVE "no" TO TL-OBSERVED
     IF WS-ANY >= 1 AND WS-ANY <= 100
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The variant packet: a baby zombie sends Set Entity Data (0x65); an adult sends nothing.
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 20§4.1 Zombie: an adult has no variant packet" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-VARIANT(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 20§4.1 Zombie: a baby sends id 101, entity id, index 16 boolean true, end" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF PB-LENGTH >= 5 AND WS-BYTE(1) = X"65"
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-VARIANT-SEND" USING WS-ROW
     CALL "STDMOB-EQUIP-SEND" USING WS-ROW
     MOVE 12 TO EN-EQUIP(WS-ROW)
     CALL "STDMOB-EQUIP-SEND" USING WS-ROW
*>   A new viewer gets Add Entity, the variant packet and the equipment.
     MOVE SPACE TO VW-SEEN(WS-PLAYER)(WS-ROW:1)
     CALL "ENTITY-VIEW-UPDATE" USING WS-PLAYER WS-ROW
*>   Experience of a baby killed by a player (12) and of an adult variant 0 path.
     MOVE WS-X TO WS-X0
     CALL "STDMOB-XP-VARIANT" USING WS-DIM WS-X0 WS-Y WS-Z WS-TYPE WS-PLAYER EN-VARIANT(WS-ROW) WS-NOBONUS
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-XP-VARIANT" USING WS-DIM WS-X0 WS-Y WS-Z WS-TYPE WS-PLAYER EN-VARIANT(WS-ROW) WS-NOBONUS
     MOVE 0 TO WS-BASE
     CALL "STDMOB-XP-VARIANT" USING WS-DIM WS-X0 WS-Y WS-Z WS-TYPE WS-BASE EN-VARIANT(WS-ROW) WS-NOBONUS
*>   Finalize of a row that is no table mob does nothing.
     CALL "ENTITY-ALLOC" USING WS-I
     MOVE 0 TO EN-TYPE(WS-I)
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-I
     MOVE "acceptance US15 20§4.1 Zombie: finalize of a non-table row changes nothing" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VARIANT(WS-I) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-I
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-MOB-20-3-6.
 COPY CORETEST.
 COPY MOBSPTEST.
