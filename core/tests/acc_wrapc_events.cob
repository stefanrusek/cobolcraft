*> Acceptance test, game events of mobs and riders (docs/protocol/30-redstone-8 section 14.1.9 entity_dismount; wrap lane C, T56409). Entity.removeVehicle posts entity_dismount at the
*> vehicle's position with the rider as the source when the rider has no removal reason or one that destroys it: a vehicle that is removed throws its mob rider and its player rider off
*> (one event each), a mob rider that is removed (killed, despawned) posts it too, a player row that is removed because the connection left posts nothing.
*> The totem of undying (17 section 4.10, 30-8 14.3.8; T56404): a lethal hit on a player with a totem in either hand leaves health 1.0, uses the totem up, applies Regeneration II 900, Absorption II 100
*> and Fire Resistance I 800, sends Entity Event 35 and posts item_interact_finish; without a totem, or for damage that bypasses invulnerability (the void), the player dies.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPC-EVENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CMENU.
 COPY RULES.
 COPY GAMEEVENT.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW-NEW             BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-CHICKEN             BINARY-LONG.
 01 WS-HORSE               BINARY-LONG.
 01 WS-MOUNTED             BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG VALUE 0.
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-K                   BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-LIST                PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-HURT-RESULT         BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 01 WS-NOBODY2             BINARY-LONG VALUE 0.
 01 WS-LETHAL              BINARY-LONG VALUE 100000.
 01 WS-CAUSE-V             BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-SPACED              PIC X(1030).
 01 WS-N34                 BINARY-LONG.
 01 WS-CONN2               BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-NAME2               PIC X(16).
 01 WS-SLOT                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-ENTITY-ROW(WS-ROW) TO WS-PROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
     MOVE 0 TO PL-SNEAKING(WS-ROW)
*>   Test players join in creative; the totem needs a survival player (creative takes no damage).
     MOVE 0 TO PL-MODE(WS-ROW)

*>   1. A chicken with a zombie rider is removed: the vehicle's removal throws the rider off, entity_dismount at the chicken's position with the zombie as the source.
     MOVE "zombie" TO WS-KEY
     MOVE 1 TO WS-OFFSET
     PERFORM SPAWN
     MOVE WS-ROW-NEW TO WS-ZOMBIE
     MOVE "chicken" TO WS-KEY
     MOVE 2 TO WS-OFFSET
     PERFORM SPAWN
     MOVE WS-ROW-NEW TO WS-CHICKEN
     CALL "MOB-MOUNT" USING WS-ZOMBIE WS-CHICKEN WS-MOUNTED
     MOVE "acceptance 30-8 14.1.9 setup: the zombie rides the chicken" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-MOUNTED TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE GE-COUNT TO WS-BEFORE
     CALL "ENTITY-REMOVE" USING WS-CHICKEN
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.1.9 a removed vehicle posts one entity_dismount for its mob rider" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " entity_dismount" TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CHECK
     COMPUTE WS-LOG = FUNCTION MOD(GE-COUNT - 1, 128) + 1
     MOVE "acceptance 30-8 14.1.9 the dismount's source is the rider" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-ZOMBIE TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 30-8 14.1.9 the thrown rider no longer rides (EN-MOUNT 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOUNT(WS-ZOMBIE) TO TL-OBSERVED-N
     PERFORM CHECK

*>   2. A zombie rider that is removed (killed or despawned) posts entity_dismount too and leaves the chicken free.
     MOVE "chicken" TO WS-KEY
     MOVE 2 TO WS-OFFSET
     PERFORM SPAWN
     MOVE WS-ROW-NEW TO WS-CHICKEN
     CALL "MOB-MOUNT" USING WS-ZOMBIE WS-CHICKEN WS-MOUNTED
     MOVE GE-COUNT TO WS-BEFORE
     CALL "ENTITY-REMOVE" USING WS-ZOMBIE
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.1.9 a removed mob rider posts entity_dismount" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " entity_dismount" TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance 30-8 14.1.9 the vehicle of a removed rider has no rider left (EN-PASS 0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PASS(WS-CHICKEN) TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "ENTITY-REMOVE" USING WS-CHICKEN

*>   3. A horse with the player on it is removed: entity_dismount with the player as the source, and the player rides nothing any more.
     MOVE "horse" TO WS-KEY
     MOVE 2 TO WS-OFFSET
     PERFORM SPAWN
     MOVE WS-ROW-NEW TO WS-HORSE
     CALL "MOB-RIDE-START" USING WS-ROW WS-HORSE WS-STARTED
     MOVE "acceptance 30-8 14.1.9 setup: the player rides the horse" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-HORSE TO TL-EXPECTED-N
     MOVE EN-VEHICLE(WS-PROW) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE GE-COUNT TO WS-BEFORE
     CALL "ENTITY-REMOVE" USING WS-HORSE
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.1.9 a removed horse posts entity_dismount for its player rider" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " entity_dismount" TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CHECK
     COMPUTE WS-LOG = FUNCTION MOD(GE-COUNT - 1, 128) + 1
     MOVE "acceptance 30-8 14.1.9 the player is the source" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-PROW TO TL-EXPECTED-N
     MOVE GE-L-SOURCE(WS-LOG) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 30-8 14.1.9 the player no longer rides the removed horse" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VEHICLE(WS-PROW) TO TL-OBSERVED-N
     PERFORM CHECK

*>   3b. A camel's second rider (EN-RIDER2) is thrown off the same way when the vehicle is removed.
     MOVE "horse" TO WS-KEY
     MOVE 2 TO WS-OFFSET
     PERFORM SPAWN
     MOVE WS-ROW-NEW TO WS-HORSE
     MOVE WS-ROW TO EN-RIDER2(WS-HORSE)
     MOVE WS-HORSE TO EN-VEHICLE(WS-PROW)
     MOVE GE-COUNT TO WS-BEFORE
     CALL "ENTITY-REMOVE" USING WS-HORSE
     PERFORM LIST-NEW
     MOVE "acceptance 30-8 14.1.9 a removed vehicle posts entity_dismount for its second rider" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE " entity_dismount" TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CHECK
     MOVE "acceptance 30-8 14.1.9 the second rider rides nothing any more" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-VEHICLE(WS-PROW) TO TL-OBSERVED-N
     PERFORM CHECK

*>   4. The totem of undying. Alice holds two in her main hand and takes a lethal fall.
     MOVE "totem_of_undying" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, WS-SLOT)
     MOVE 2 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, WS-SLOT)
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-ROW)
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE GE-COUNT TO WS-BEFORE
     MOVE CAUSE-FALL TO WS-CAUSE-V
     CALL "HEALTH-HURT" USING WS-ROW WS-LETHAL WS-CAUSE-V WS-NOBODY WS-NOBODY2 WS-HURT-RESULT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM COUNT-EVENT-34
     MOVE "N" TO TL-MODE
     MOVE "acceptance 17 4.10 a lethal hit with a totem in the main hand leaves the player alive" TO TL-CASE
     MOVE PS-ALIVE TO TL-EXPECTED-N
     MOVE PL-STATE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 17 4.10 the totem sets health to 1.0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance 17 4.10 the totem is used up by 1 (2 became 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, WS-SLOT) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE 9 TO WS-FX
     CALL "EFFECT-LEVEL" USING WS-ROW WS-FX WS-LEVEL WS-TICKS
     MOVE "acceptance 17 4.10 Regeneration II (level 2) for 900 ticks" TO TL-CASE
     MOVE 2900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     PERFORM CHECK
     MOVE 21 TO WS-FX
     CALL "EFFECT-LEVEL" USING WS-ROW WS-FX WS-LEVEL WS-TICKS
     MOVE "acceptance 17 4.10 Absorption II (level 2) for 100 ticks" TO TL-CASE
     MOVE 2100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     PERFORM CHECK
     MOVE 11 TO WS-FX
     CALL "EFFECT-LEVEL" USING WS-ROW WS-FX WS-LEVEL WS-TICKS
     MOVE "acceptance 17 4.10 Fire Resistance I (level 1) for 800 ticks" TO TL-CASE
     MOVE 1800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-LEVEL * 1000 + WS-TICKS
     PERFORM CHECK
     MOVE "acceptance 17 4.10 the totem animation (Entity Event 35, packet 34) is sent to the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N34 TO TL-OBSERVED-N
     PERFORM CHECK
     PERFORM LIST-NEW
     MOVE "T" TO TL-MODE
     MOVE "acceptance 30-8 14.3.8 the totem posts item_interact_finish (after entity_damage)" TO TL-CASE
     MOVE " entity_damage item_interact_finish" TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CHECK
*>   The other hand: nothing in the main hand, one totem in the off hand.
     MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-SLOT) PL-SLOT-ITEM(WS-ROW, WS-SLOT)
     MOVE WS-ITEM TO MN-EQUIP-ITEM(WS-ROW, 5)
     MOVE 1 TO MN-EQUIP-COUNT(WS-ROW, 5)
     MOVE 0 TO MN-EQUIP-VAR(WS-ROW, 5)
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-ROW)
     CALL "HEALTH-HURT" USING WS-ROW WS-LETHAL WS-CAUSE-V WS-NOBODY WS-NOBODY2 WS-HURT-RESULT
     MOVE "N" TO TL-MODE
     MOVE "acceptance 17 4.10 a totem in the off hand saves the player too and is used up" TO TL-CASE
     COMPUTE TL-EXPECTED-N = PS-ALIVE * 100 + 1 * 10 + 0
     COMPUTE TL-OBSERVED-N = PL-STATE(WS-ROW) * 100 + PL-HEALTH(WS-ROW) * 10 + MN-EQUIP-COUNT(WS-ROW, 5)
     PERFORM CHECK
*>   No totem left: the same hit kills.
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-ROW)
     CALL "HEALTH-HURT" USING WS-ROW WS-LETHAL WS-CAUSE-V WS-NOBODY WS-NOBODY2 WS-HURT-RESULT
     MOVE "acceptance 17 4.10 without a totem the lethal hit kills" TO TL-CASE
     MOVE PS-DEAD TO TL-EXPECTED-N
     MOVE PL-STATE(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK
*>   Bob holds a totem and falls into the void: bypasses invulnerability, the totem does not help.
     MOVE "Bob" TO WS-NAME2
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME2 WS-NAME-LENGTH WS-CONN2
     MOVE CN-PLAYER(WS-CONN2) TO WS-ROW2
     MOVE 0 TO PL-MODE(WS-ROW2)
     COMPUTE WS-SLOT = PL-HELD(WS-ROW2) + 1
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW2, WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW2, WS-SLOT)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW2, WS-SLOT)
     MOVE 20 TO PL-HEALTH(WS-ROW2)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-ROW2)
     MOVE CAUSE-VOID TO WS-CAUSE-V
     CALL "HEALTH-HURT" USING WS-ROW2 WS-LETHAL WS-CAUSE-V WS-NOBODY WS-NOBODY2 WS-HURT-RESULT
     MOVE "acceptance 17 4.10 damage that bypasses invulnerability (the void) kills despite a totem" TO TL-CASE
     MOVE PS-DEAD TO TL-EXPECTED-N
     MOVE PL-STATE(WS-ROW2) TO TL-OBSERVED-N
     PERFORM CHECK
     STOP RUN.

*> SPAWN: a mob of species WS-KEY one block in front of the player and WS-OFFSET blocks to the side; its tracker row in WS-ROW-NEW.
 SPAWN.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-PX + 0.5 + WS-OFFSET
     MOVE WS-PY TO WS-Y
     COMPUTE WS-Z = WS-PZ + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW-NEW.

*> COUNT-EVENT-34: the Entity Event packets (34, "34" or "34x<n>") of the drained ids into WS-N34.
 COUNT-EVENT-34.
     MOVE SPACES TO WS-SPACED
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N34
     INSPECT WS-SPACED TALLYING WS-N34 FOR ALL " 34 " ALL " 34x".

*> LIST-NEW: the names of the game events posted since WS-BEFORE, oldest first, each after a space, into WS-LIST.
 LIST-NEW.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM WS-BEFORE BY 1 UNTIL WS-K >= GE-COUNT
         COMPUTE WS-LOG = FUNCTION MOD(WS-K, 128) + 1
         STRING " " FUNCTION TRIM(GE-L-NAME(WS-LOG)) DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-WRAPC-EVENTS.
 COPY CORETEST.
 COPY BETEST.
