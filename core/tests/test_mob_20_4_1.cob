*> Implementation test (002-lane-mobsfull-h8; docs/protocol/20 section 4.1 Zombie): the baby speed modifier (+0.5 multiplied-base, so the squared walk speed
*> is 2.25 times the adult's), the zombie weapon draw (iron sword, spear or shovel in the main hand: probability 0.05 on Hard, 0.01 otherwise), Set
*> Equipment of the main hand, and reinforcements on Hard (hurtServer: chance EN-REINF, up to 50 attempts, a new zombie targets the attacker, the caller's
*> and the callee's chance are lowered by 0.05).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY PROTO.
 COPY RULES.
 COPY XORO.
 COPY TESTLIB.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-HUSK-TYPE           BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-CASE                PIC X(100).
 01 WS-EXP                 BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-RULE-ROUND          BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-HARD-HANDS          BINARY-LONG.
 01 WS-NORMAL-HANDS        BINARY-LONG.
 01 WS-SWORDS              BINARY-LONG.
 01 WS-SPEARS              BINARY-LONG.
 01 WS-SHOVELS             BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-ATTACKER            BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-FLOOR-SIZE          BINARY-LONG VALUE 65.
 01 WS-FLOOR-KIND          BINARY-LONG VALUE 1.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-VILLAGER-TYPE       BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-T                  BINARY-LONG.
 01 WS-CALLED             BINARY-LONG.
 01 WS-PIG-TYPE           BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:husk" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HUSK-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
*>   Baby speed modifier: adult 0.117 blocks a tick, baby 2.25 times that.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-ZOMBIE-TYPE WS-M
     CALL "STDMOB-SPEED" USING WS-ROW WS-M WS-SPEED
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100000
     MOVE "acceptance US15 20§4.1 Zombie: an adult walks 0.117 blocks a tick" TO WS-CASE
     MOVE 11700 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-SPEED" USING WS-ROW WS-M WS-SPEED
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100000
     MOVE "acceptance US15 20§4.1 Zombie: a baby has the baby speed modifier, 2.25 times faster" TO WS-CASE
     MOVE 26325 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "MOB-SPAWN" USING WS-DIM WS-HUSK-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-INDEX" USING WS-HUSK-TYPE WS-M
     CALL "STDMOB-SPEED" USING WS-ROW WS-M WS-SPEED
     COMPUTE WS-OBS ROUNDED = WS-SPEED * 100000
     MOVE "acceptance US15 20§4.3 Husk: a baby husk has the baby speed modifier too" TO WS-CASE
     MOVE 26325 TO WS-EXP
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Weapon draw: Hard 5 in 100, Normal 1 in 100; sword, spear and shovel all occur.
     MOVE 0 TO WS-HARD-HANDS WS-NORMAL-HANDS WS-SWORDS WS-SPEARS WS-SHOVELS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 3 TO BW-DIFFICULTY
         CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
             CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
             IF EN-HAND(WS-ROW) > 0
             ADD 1 TO WS-HARD-HANDS
         END-IF
         EVALUATE EN-HAND(WS-ROW)
             WHEN 1 ADD 1 TO WS-SWORDS
             WHEN 2 ADD 1 TO WS-SPEARS
             WHEN 3 ADD 1 TO WS-SHOVELS
         END-EVALUATE
         CALL "ENTITY-REMOVE" USING WS-ROW
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 2 TO BW-DIFFICULTY
         CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
         IF EN-HAND(WS-ROW) > 0
             ADD 1 TO WS-NORMAL-HANDS
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US15 20§4.1 Zombie: about 5 in 100 hold a weapon on Hard" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-HARD-HANDS >= 30 AND WS-HARD-HANDS <= 75
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§4.1 Zombie: about 1 in 100 hold a weapon on Normal" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-NORMAL-HANDS >= 1 AND WS-NORMAL-HANDS <= 25
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§4.1 Zombie: the draw gives sword, spear and shovel, the shovel most often" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-SWORDS > 0 AND WS-SPEARS > 0 AND WS-SHOVELS > WS-SWORDS AND WS-SHOVELS > WS-SPEARS
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Set Equipment of the main hand: id 104, entity id, slot 0 (no continuation bit), then the item stack.
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HAND(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 20§4.1 Zombie: no armour and no weapon send no equipment" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE PB-LENGTH TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO EN-HAND(WS-ROW)
     MOVE 3 TO WS-OFF
     IF EN-ID(WS-ROW) >= 128
         MOVE 4 TO WS-OFF
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE "acceptance US15 20§4.1 Zombie: a shovel alone is Set Equipment slot 0 without continuation" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 4 AND WS-BYTE(1) = X"68" AND WS-BYTE(WS-OFF) = X"00"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 12 TO EN-EQUIP(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 20§4.1 Zombie: armour pairs carry the continuation bit before the hand" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 8 AND WS-BYTE(WS-OFF) = X"85"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 9 TO EN-HAND(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 20§4.1 Zombie: an item the set does not know is sent as an empty stack" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 8 AND WS-BYTE(PB-LENGTH) = X"00"
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO EN-HAND(WS-ROW)
     CALL "STDMOB-EQUIP-SEND" USING WS-ROW
     CALL "PB-FREE" USING PB-BUFFER
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   Reinforcements on Hard: a floor of stone around the player lets the called zombies stand.
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 32
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 32
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FLOOR-SIZE WS-FY WS-FLOOR-KIND
     MOVE 3 TO BW-DIFFICULTY
*>   Reinforcements pass the monster dark check of 20 section 3.3 (54 section 12.1): night, so that the lit open ground darkens enough.
     MOVE 18000 TO CW-TIME
     COMPUTE WS-X0 = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-ROW
     MOVE 10000 TO EN-REINF(WS-ROW)
     MOVE CW-TICKS TO WS-BEFORE
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: a hit on Hard with chance 1 calls one reinforcement" TO WS-CASE
     COMPUTE WS-EXP = WS-BEFORE + 1
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§4.1 Zombie: the caller's chance falls by 0.05 (reinforcement_caller_charge)" TO WS-CASE
     MOVE 9500 TO WS-EXP
     MOVE EN-REINF(WS-ROW) TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ZOMBIE-TYPE AND WS-I NOT = WS-ROW
             MOVE WS-I TO WS-NEW
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§4.1 Zombie: a reinforcement targets the attacker, 7+ blocks from a player" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-NEW > 0
         IF EN-TARGET(WS-NEW) = WS-PLAYER AND EN-TARGET-ID(WS-NEW) = PL-ENTITY-ID(WS-PLAYER)
                 AND (FUNCTION ABS(EN-X(WS-NEW) - WS-X) >= 7 OR FUNCTION ABS(EN-Z(WS-NEW) - WS-Z) >= 7
                 OR FUNCTION ABS(EN-Y(WS-NEW) - WS-Y) >= 7)
             MOVE 1 TO WS-OBS
         END-IF
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 20§4.1 Zombie: the called zombie has the callee charge, its chance 0.05 lower" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-NEW > 0 AND EN-REINF(WS-NEW) >= 0 AND EN-REINF(WS-NEW) <= 1000
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   No reinforcement on Normal, with chance 0, or with hostile mobs off.
     MOVE 2 TO BW-DIFFICULTY
     MOVE 10000 TO EN-REINF(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: no reinforcement on Normal" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO BW-DIFFICULTY
     MOVE 0 TO EN-REINF(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: no reinforcement with chance 0" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 10000 TO EN-REINF(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: no reinforcement with hostile mobs off" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO CS-HOSTILE-MOBS
*>   A hit by no player (fire) calls nobody; a pig hurt by a player calls nobody.
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 0 TO WS-ATTACKER
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-ATTACKER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: damage with no attacker calls no reinforcement" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   A target that is no living player calls nobody; a chance of 0.0001 almost never calls; many calls from 3 blocks away must find spots in the open.
     MOVE 10000 TO EN-REINF(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 2 TO WS-ATTACKER
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-ATTACKER
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: an attacker row that is no player calls no reinforcement" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-CALLED
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         MOVE 1 TO EN-REINF(WS-ROW)
         MOVE 20 TO EN-HEALTH(WS-ROW)
         MOVE 0 TO EN-HURT(WS-ROW)
         ADD 1 TO CW-TICKS
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: a chance of 0.0001 calls nobody in 60 hits" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         MOVE 10000 TO EN-REINF(WS-ROW)
         MOVE 20 TO EN-HEALTH(WS-ROW)
         MOVE 0 TO EN-HURT(WS-ROW)
         ADD 1 TO CW-TICKS
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: 60 hits with chance 1 call at least 20 reinforcements" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-COUNT > WS-BEFORE + 20
         MOVE 1 TO WS-OBS
     END-IF
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   In full daylight no spot passes the dark check (sky light 15 against nextInt(32), brightness against the 0..7 sample): no reinforcement (54 s12.1).
     MOVE 6000 TO CW-TIME
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         MOVE 10000 TO EN-REINF(WS-ROW)
         MOVE 20 TO EN-HEALTH(WS-ROW)
         MOVE 0 TO EN-HURT(WS-ROW)
         ADD 1 TO CW-TICKS
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     END-PERFORM
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: in full daylight no reinforcement (dark check, 54 s12.1)" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 18000 TO CW-TIME
*>   In a thunderstorm the brightness is a flat 10, above every 0..7 sample: no reinforcement even at night.
     MOVE 1 TO CW-THUNDERING
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         MOVE 10000 TO EN-REINF(WS-ROW)
         MOVE 20 TO EN-HEALTH(WS-ROW)
         MOVE 0 TO EN-HURT(WS-ROW)
         ADD 1 TO CW-TICKS
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
     END-PERFORM
     MOVE 0 TO CW-THUNDERING
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: in a thunderstorm no reinforcement (flat brightness 10)" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   The rules spawn_mobs and spawn_monsters gate reinforcements (ServerLevel.isSpawningMonsters, 20 section 4.1).
     PERFORM VARYING WS-RULE-ROUND FROM 1 BY 1 UNTIL WS-RULE-ROUND > 2
         IF WS-RULE-ROUND = 1
             MOVE "spawn_monsters" TO WS-RULE-NAME
         ELSE
             MOVE "spawn_mobs" TO WS-RULE-NAME
         END-IF
         CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
         MOVE 0 TO WS-RULE-VALUE
         CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
         PERFORM COUNT-ZOMBIES
         MOVE WS-COUNT TO WS-BEFORE
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 30
             MOVE 10000 TO EN-REINF(WS-ROW)
             MOVE 20 TO EN-HEALTH(WS-ROW)
             MOVE 0 TO EN-HURT(WS-ROW)
             ADD 1 TO CW-TICKS
             CALL "HEALTH-MOB-DAMAGE" USING WS-ROW WS-DAMAGE WS-CAUSE WS-PLAYER
         END-PERFORM
         MOVE 1 TO WS-RULE-VALUE
         CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
         PERFORM COUNT-ZOMBIES
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 20§4.1 Zombie: with the rule " FUNCTION TRIM(WS-RULE-NAME) " off no reinforcement is called" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BEFORE TO WS-EXP
         MOVE WS-COUNT TO WS-OBS
         CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     END-PERFORM
*>   A pig and a row that is no table mob call nobody.
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
     PERFORM COUNT-ZOMBIES
     MOVE WS-COUNT TO WS-BEFORE
     CALL "STDMOB-REINFORCE" USING WS-NEW WS-PLAYER
     CALL "ENTITY-ALLOC" USING WS-T
     MOVE 0 TO EN-TYPE(WS-T)
     CALL "STDMOB-REINFORCE" USING WS-T WS-PLAYER
     CALL "ENTITY-REMOVE" USING WS-T
     CALL "ENTITY-REMOVE" USING WS-NEW
     PERFORM COUNT-ZOMBIES
     MOVE "acceptance US15 20§4.1 Zombie: a pig or a non-table row calls no reinforcement" TO WS-CASE
     MOVE WS-BEFORE TO WS-EXP
     MOVE WS-COUNT TO WS-OBS
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
*>   Display names (death messages): underscores become spaces and every word is capitalised.
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VILLAGER-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-NAME" USING WS-VILLAGER-TYPE WS-NAME WS-NAME-LENGTH
     MOVE "acceptance US15 20§4.2 Zombie villager: its display name is Zombie Villager" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Zombie Villager" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 20§4.2 Zombie villager: the name is 15 characters" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-NAME-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-NAME" USING WS-ZOMBIE-TYPE WS-NAME WS-NAME-LENGTH
     MOVE "acceptance US15 20§4.1 Zombie: a one-word name stays Zombie" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Zombie" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COUNT-ZOMBIES.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ZOMBIE-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-20-4-1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(100).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
