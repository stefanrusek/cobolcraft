*> Acceptance test of Lifetime, damage, fire, explosions (T0350; docs/protocol/41-item-entity-physics.md section 5; FR-037): the age
*> counts every tick whatever the players do, hurtServer in order (invulnerableTime, mob_griefing, damage_resistant, the integer
*> health), the 16 fire resistant items and the nether star, fireImmune, igniteForSeconds, the on_fire damage of burning items, the
*> lava rules for a resistant item and the explosion rules of the block interactions. The special items are item rows whose
*> key the test sets (the content set has none of them). Alice is far from the items at (20.5, 99, 20.5) on a stone floor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-INGOT               BINARY-LONG VALUE 4.
 01 WS-STAR                BINARY-LONG VALUE 5.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-INTERACTION         BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG VALUE 15.
 01 WS-BX                  BINARY-LONG VALUE 20.
 01 WS-BY                  BINARY-LONG VALUE 98.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 20.5.
 01 WS-Y                   FLOAT-LONG VALUE 99.
 01 WS-Z                   FLOAT-LONG VALUE 20.5.
 01 WS-V                   FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-V3                  FLOAT-LONG VALUE 0.
 01 WS-AMOUNT              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "minecraft:netherite_ingot" TO IT-KEY(WS-INGOT + 1)
     MOVE 25 TO IT-KEY-LENGTH(WS-INGOT + 1)
     MOVE "minecraft:nether_star" TO IT-KEY(WS-STAR + 1)
     MOVE 21 TO IT-KEY-LENGTH(WS-STAR + 1)
     MOVE CB-S-BLOCK(15) TO WS-BLOCK
     MOVE "minecraft:lava" TO CB-KEY(WS-BLOCK + 1)
     MOVE 14 TO CB-KEY-LENGTH(WS-BLOCK + 1)
     MOVE 0 TO CB-SOLID(WS-BLOCK + 1)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 20 TO WS-BX
     MOVE 21 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE

*>   5.1 The age counts every tick, with no player near and no condition on the chunk but being ticked.
     PERFORM SPAWN
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions the age rises by 1 every tick with no player near, and an item of "
         & "age 5999 is discarded in the next tick" TO WS-CASE
     CALL "ITT-I" USING EN-AGE(WS-ROW) WS-A
     MOVE 5999 TO EN-AGE(WS-ROW)
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "5 0" TO WS-EXPECTED
     PERFORM CHECK

*>   5.2 hurtServer: health = (int)(health - amount), discarded at 0 or below; (int)(5 - 0.5) = 4.
     PERFORM SPAWN
     MOVE 0.5 TO WS-AMOUNT
     MOVE IP-DT-OTHER TO WS-TYPE
     MOVE IP-SRC-OTHER TO WS-SOURCE
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     CALL "ITT-I" USING WS-RESULT WS-B
     MOVE 3 TO WS-AMOUNT
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-C
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-D
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a hit of 0.5 leaves health 4 (truncated), a hit of 3 health 1, "
         & "the next hit of 3 discards the item" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "4 1 1 0" TO WS-EXPECTED
     PERFORM CHECK

*>   invulnerableTime: blocks every hit but out_of_world, generic_kill and a creative player's.
     PERFORM SPAWN
     MOVE 5 TO IP-I-INVULN(WS-ROW)
     MOVE 1 TO WS-AMOUNT
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE IP-DT-OTHER TO WS-TYPE
                 MOVE IP-SRC-OTHER TO WS-SOURCE
             WHEN 2
                 MOVE IP-DT-OUT-OF-WORLD TO WS-TYPE
                 MOVE IP-SRC-OTHER TO WS-SOURCE
             WHEN 3
                 MOVE IP-DT-GENERIC-KILL TO WS-TYPE
                 MOVE IP-SRC-OTHER TO WS-SOURCE
             WHEN 4
                 MOVE IP-DT-OTHER TO WS-TYPE
                 MOVE IP-SRC-CREATIVE TO WS-SOURCE
         END-EVALUATE
         MOVE 5 TO IP-I-HEALTH(WS-ROW)
         CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
         CALL "ITT-I" USING WS-RESULT WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     END-PERFORM
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions an invulnerable item ignores ordinary damage but not out_of_world, "
         & "generic_kill or a creative player's hit" TO WS-CASE
     MOVE "0111" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM SPAWN

*>   mob_griefing false: a mob's hit is ignored, any other source is not.
     MOVE 1 TO IP-NO-MOB-GRIEFING
     MOVE IP-DT-OTHER TO WS-TYPE
     MOVE IP-SRC-MOB TO WS-SOURCE
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-A
     MOVE 0 TO IP-NO-MOB-GRIEFING
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-B
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions with mob_griefing false a mob's hit is ignored, with it true it "
         & "is accepted" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "01" TO WS-EXPECTED
     PERFORM CHECK

*>   damage_resistant: the netherite family ignores the is_fire types, not explosions or falls; the nether star the is_explosion
*>   types only.
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a netherite item ignores in_fire, lava and fireball damage but not "
         & "an explosion or a fall; a nether star ignores explosion and fireworks but burns" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         EVALUATE WS-I
             WHEN 1 MOVE IP-DT-IN-FIRE TO WS-TYPE
             WHEN 2 MOVE IP-DT-LAVA TO WS-TYPE
             WHEN 3 MOVE IP-DT-FIREBALL TO WS-TYPE
             WHEN 4 MOVE IP-DT-EXPLOSION TO WS-TYPE
             WHEN 5 MOVE IP-DT-FALL TO WS-TYPE
             WHEN 6 MOVE IP-DT-FIREWORKS TO WS-TYPE
             WHEN 7 MOVE IP-DT-BAD-RESPAWN-POINT TO WS-TYPE
             WHEN 8 MOVE IP-DT-LAVA TO WS-TYPE
         END-EVALUATE
         IF WS-I < 6
             CALL "IP-RESISTANT" USING WS-INGOT WS-TYPE WS-RESULT
         ELSE
             CALL "IP-RESISTANT" USING WS-STAR WS-TYPE WS-RESULT
         END-IF
         CALL "ITT-I" USING WS-RESULT WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     END-PERFORM
     MOVE "11100110" TO WS-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions an ordinary item resists nothing and only a netherite item is "
         & "fire immune (fireImmune is the in_fire resistance)" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-N
     MOVE WS-ITEM TO EN-ITEM(WS-ROW)
     CALL "IP-FIRE-IMMUNE" USING WS-ROW WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-A
     STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     MOVE WS-INGOT TO EN-ITEM(WS-ROW)
     CALL "IP-FIRE-IMMUNE" USING WS-ROW WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-A
     STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     MOVE WS-STAR TO EN-ITEM(WS-ROW)
     CALL "IP-FIRE-IMMUNE" USING WS-ROW WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-A
     STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     MOVE "010" TO WS-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a hit the stack resists is ignored by IP-HURT: a netherite item "
         & "takes no lava damage, a nether star none from an explosion" TO WS-CASE
     MOVE WS-INGOT TO EN-ITEM(WS-ROW)
     MOVE 4 TO WS-AMOUNT
     MOVE IP-DT-LAVA TO WS-TYPE
     MOVE IP-SRC-OTHER TO WS-SOURCE
     CALL "IP-HURT" USING WS-ROW WS-TYPE WS-AMOUNT WS-SOURCE WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-A
     MOVE WS-STAR TO EN-ITEM(WS-ROW)
     MOVE 2 TO WS-INTERACTION
     MOVE 9 TO WS-AMOUNT
     CALL "IP-EXPLODE" USING WS-ROW WS-INTERACTION WS-AMOUNT WS-RESULT
     CALL "ITT-I" USING WS-RESULT WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "00" TO WS-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   5.4 Explosions: keep and trigger-block interactions are ignored, destroy and destroy-with-decay hurt (a 5 point blast kills).
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions an item ignores explosions that keep blocks or only trigger them "
         & "and is hurt by those that destroy blocks (a blast of 5 discards it)" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE 1 TO WS-N
     MOVE 5 TO WS-AMOUNT
     PERFORM VARYING WS-INTERACTION FROM 0 BY 1 UNTIL WS-INTERACTION > 3
         PERFORM SPAWN
         CALL "IP-EXPLODE" USING WS-ROW WS-INTERACTION WS-AMOUNT WS-RESULT
         CALL "ITT-I" USING WS-RESULT WS-A
         STRING FUNCTION TRIM(WS-A) DELIMITED BY SIZE INTO WS-OBSERVED POINTER WS-N
     END-PERFORM
     MOVE "0011" TO WS-EXPECTED
     PERFORM CHECK

     PERFORM CLEAR-ITEMS
*>   5.3 Fire: igniteForSeconds(15) is 300 ticks unless fire immune.
     PERFORM SPAWN
     CALL "IP-IGNITE" USING WS-ROW WS-SECONDS
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-A
     MOVE WS-INGOT TO EN-ITEM(WS-ROW)
     MOVE 0 TO IP-I-FIRE(WS-ROW)
     CALL "IP-IGNITE" USING WS-ROW WS-SECONDS
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-B
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions igniteForSeconds(15) sets 300 fire ticks, and nothing for a fire "
         & "immune item" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "300 0" TO WS-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   A burning item takes 1.0 on_fire damage on ticks that start with a count divisible by 20: fire 40 gives health 4 after the
*>   first tick and 3 after the 21st; an item with fire 100 dies at the fifth hit (tick 81); a fire immune item's fire goes out.
     PERFORM SPAWN
     MOVE 40 TO IP-I-FIRE(WS-ROW)
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-B
     MOVE 20 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-C
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-D
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a burning item takes 1.0 damage each time its fire count is a "
         & "multiple of 20: fire 40 gives health 4 and fire 39 after a tick, health 3 and fire 19 after 21" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "4 39 3 19" TO WS-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
     PERFORM SPAWN
     MOVE 100 TO IP-I-FIRE(WS-ROW)
     MOVE 80 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions an item that stays on fire from 100 ticks is alive with health 1 "
         & "after 80 ticks and dies at tick 81 (five hits of 1.0)" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 0" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM SPAWN
     MOVE WS-INGOT TO EN-ITEM(WS-ROW)
     MOVE 60 TO IP-I-FIRE(WS-ROW)
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions the fire of a fire immune item goes out at once and it takes no damage"
         TO WS-CASE
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0 5" TO WS-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   In lava the burning damage is skipped (the lava hits are the damage).
     PERFORM SPAWN
     MOVE 40 TO IP-I-FIRE(WS-ROW)
     MOVE 0.5 TO IP-I-LAVA-H(WS-ROW)
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a burning item in lava takes no on_fire damage that tick" TO WS-CASE
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-A
     MOVE WS-A TO WS-OBSERVED
     MOVE "5" TO WS-EXPECTED
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-ROW

*>   A netherite item lying in lava is neither ignited nor hurt.
     MOVE 98 TO WS-BY
     MOVE 14 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 20.5 TO WS-X
     MOVE 98.2 TO WS-Y
     MOVE 21.5 TO WS-Z
     PERFORM SPAWN
     MOVE WS-INGOT TO EN-ITEM(WS-ROW)
     MOVE 3 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US2 41§5 Lifetime, damage, fire, explosions a netherite item in lava is not set alight and takes no damage"
         TO WS-CASE
     CALL "ITT-I" USING IP-I-FIRE(WS-ROW) WS-A
     CALL "ITT-I" USING IP-I-HEALTH(WS-ROW) WS-B
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0 5 1" TO WS-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CLEAR-ITEMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V WS-V2 WS-V3 WS-ITEM WS-COUNT WS-DELAY WS-ROW.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-5.

 COPY CORETEST.
 COPY ITEMTEST.
