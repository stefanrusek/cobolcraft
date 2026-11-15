*> Acceptance test (US15; docs/protocol/18-mob-framework.md section 8.1, 19 section 2 and 3.4): a survival player uses items on animals through the real play path (Interact 0x1A
*> in; Entity Event, Set Entity Data and Container Set Slot out) and animals live their ticks: feeding starts love mode, two animals in love walk together and breed, the baby has
*> age -24000 and the baby flag, the parents are in a 6000-tick cooldown, an experience orb appears; babies grow and can be fed to grow faster; shears, buckets, bowls, eggs.
*> The world has a stone floor of 9 x 9 blocks at y = floor; the player and the animals stand on it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-BREEDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY BRWORLD.
 COPY XORO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                BINARY-LONG.
 01 WS-XHI                BINARY-LONG.
 01 WS-ZLO                BINARY-LONG.
 01 WS-ZHI                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-NEEDLE              PIC X(40).
 01 WS-HITS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-WANT-KEY            PIC X(112).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-COUNT-TOTAL         BINARY-LONG.
 01 WS-ID-A                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SLOT-ITEM           BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 4
     COMPUTE WS-XHI = WS-CX + 4
     COMPUTE WS-ZLO = WS-CZ - 4
     COMPUTE WS-ZHI = WS-CZ + 4
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE "minecraft:experience_orb" TO WS-WANT-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-WANT-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT

*> Love mode: wheat from the hand of a survival player (Animal.mobInteract: the item is used, 600 ticks of love, Entity Event 18)
     MOVE "cow" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     MOVE "wheat" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     MOVE "acceptance US15 18§8.1 Love mode and breeding: wheat on a cow uses one item" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.1 Love mode and breeding: and the cow is in love for 600 ticks because of the player" TO WS-CASE
     COMPUTE WS-EXPECT = 600 * 100 + WS-PLAYER
     COMPUTE WS-OBSERVE = EN-LOVE(WS-ROW-A) * 100 + EN-LOVE-CAUSE(WS-ROW-A)
     PERFORM CHECK-N
     MOVE SPACES TO WS-NEEDLE
     MOVE EN-ID(WS-ROW-A) TO WS-EDIT
     STRING "event " FUNCTION TRIM(WS-EDIT) " 18" DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE)
     MOVE "acceptance US15 18§8.1 Love mode and breeding: Entity Event 18 (hearts) reaches the viewer" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a cow already in love does not eat another wheat" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT

*> A second cow: wheat from a creative player is not used up but starts love; carrot is no cow food; too far away is not fed
     MOVE -2 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE EN-ID(WS-ROW-B) TO WS-ID-A
     MOVE "carrot" TO WS-ITEM-KEY
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a carrot is no cow food: nothing is used, no love" TO WS-CASE
     COMPUTE WS-EXPECT = 3 * 10
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N
     MOVE "wheat" TO WS-ITEM-KEY
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a creative player starts love and keeps the wheat" TO WS-CASE
     COMPUTE WS-EXPECT = 3 * 1000 + 600
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE 0 TO EN-LOVE(WS-ROW-B)
     MOVE 11 TO EN-Z(WS-ROW-B)
     ADD WS-CZ TO EN-Z(WS-ROW-B)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: an animal 11 blocks away is out of reach" TO WS-CASE
     COMPUTE WS-EXPECT = 3 * 10
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N
     COMPUTE EN-Z(WS-ROW-B) = WS-CZ + 0.5
     MOVE 1 TO WS-I
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-I WS-ZERO
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the off hand is not handled: nothing is used" TO WS-CASE
     COMPUTE WS-EXPECT = 3 * 10
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N
     MOVE EN-ID(PL-ENTITY-ROW(WS-PLAYER)) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE 9999 TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: interacting with the player's own entity or an entity that does not exist does nothing" TO WS-CASE
     COMPUTE WS-EXPECT = 3
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE EN-ID(WS-ROW-B) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a cow in the player's reach eats wheat and is in love" TO WS-CASE
     COMPUTE WS-EXPECT = 2 * 1000 + 600
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N

*> Breeding: the cows walk together and after 60 ticks within 3 blocks they breed
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-BABIES > 0
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW-A
         CALL "MOB-STEP" USING WS-ROW-B
         PERFORM COUNT-BABIES
     END-PERFORM
     MOVE "acceptance US15 18§8.1 Love mode and breeding: two cows in love breed within 200 ticks: exactly one baby cow" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-BABIES TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.1 Love mode and breeding: they needed 60 ticks together, no fewer" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-I > 60
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the baby has age -24000 and the baby flag" TO WS-CASE
     COMPUTE WS-EXPECT = -24000 * 10 + 1
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-BABY) * 10 + EN-VARIANT(WS-BABY)
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.1 Love mode and breeding: both parents are in the 6000-tick cooldown (minus the ticks since) and out of love" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-MOBAGE(WS-ROW-A) > 5900 AND EN-MOBAGE(WS-ROW-A) <= 6000 AND EN-MOBAGE(WS-ROW-B) > 5900 AND EN-MOBAGE(WS-ROW-B) <= 6000
             AND EN-LOVE(WS-ROW-A) = 0 AND EN-LOVE(WS-ROW-B) = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     PERFORM COUNT-ORBS
     MOVE "acceptance US15 18§8.1 Love mode and breeding: one experience orb of 1 to 7 points appears at the parents" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-ORBS >= 1 AND WS-ORBS <= 7
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "101"
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the viewer gets Set Entity Data for the baby flag and Entity Event 18 for the hearts" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-HITS > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a parent in breeding cooldown does not take wheat" TO WS-CASE
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     COMPUTE WS-EXPECT = 2
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N

*> Ageing: a baby counts up, wheat ages it by 10 percent of the time left, at 0 it grows up
     MOVE EN-MOBAGE(WS-BABY) TO WS-N
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-BABY
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a baby's age rises by 1 a tick" TO WS-CASE
     COMPUTE WS-EXPECT = WS-N + 1
     MOVE EN-MOBAGE(WS-BABY) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE EN-MOBAGE(WS-BABY) TO WS-N
     MOVE EN-ID(WS-BABY) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     COMPUTE WS-E = 0 - WS-N
     DIVIDE WS-E BY 20 GIVING WS-E
     COMPUTE WS-E = WS-E * 0.1
     MOVE "acceptance US15 18§8.1 Love mode and breeding: wheat on a baby takes one item and ages it by 10 percent of the remaining time" TO WS-CASE
     COMPUTE WS-EXPECT = (WS-N + WS-E * 20) * 100 + 1 * 10 + 40
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-BABY) * 100 + PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-FORCED(WS-BABY)
     PERFORM CHECK-N
     MOVE -2 TO EN-MOBAGE(WS-BABY)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-BABY
     END-PERFORM
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a baby at age 0 is an adult: baby flag off, age 0" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-BABY) * 10 + EN-VARIANT(WS-BABY)
     PERFORM CHECK-N
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "101"
     MOVE "acceptance US15 18§8.1 Love mode and breeding: growing up is sent to the viewers (Set Entity Data)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE -100 TO EN-MOBAGE(WS-BABY)
     MOVE 1 TO EN-VARIANT(WS-BABY)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE EN-ID(WS-BABY) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: 100 ticks left is under a whole second of 10 percent: the wheat is used, the age does not change" TO WS-CASE
     COMPUTE WS-EXPECT = -100 * 10 + 0
     COMPUTE WS-OBSERVE = EN-MOBAGE(WS-BABY) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N

*> The cooldown counts down by 1 a tick and ends at 0
     MOVE 2 TO EN-MOBAGE(WS-ROW-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW-A
     END-PERFORM
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the cooldown ends after its last tick: the parent is an adult again" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-MOBAGE(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "wheat" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: and it can be fed again" TO WS-CASE
     COMPUTE WS-EXPECT = 600 * 10 + 1
     COMPUTE WS-OBSERVE = EN-LOVE(WS-ROW-A) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N

*> A panicking animal does not walk to its partner, and love ends when the partner is gone
     MOVE 0 TO EN-LOVE(WS-ROW-B)
     MOVE 10 TO EN-LOVE-TIME(WS-ROW-A)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: with no partner in love the BreedGoal has none" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-LOVE-PARTNER(WS-ROW-A) + EN-LOVE-TIME(WS-ROW-A)
     PERFORM CHECK-N
     MOVE 600 TO EN-LOVE(WS-ROW-A)
     MOVE 5 TO EN-FLEE(WS-ROW-A)
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-ROW-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-ROW-A)
     MOVE 5 TO EN-LOVE-PARTNER(WS-ROW-A)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW-A
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a panicking animal drops its partner" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-LOVE-PARTNER(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-FLEE(WS-ROW-A) EN-LOVE(WS-ROW-A)

*> Species: pig (carrot), chicken (seeds), horse x donkey tamed gives a mule, an untamed horse does not fall in love
     MOVE "pig" TO WS-WANT-KEY
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-C
     MOVE "carrot" TO WS-ITEM-KEY
     MOVE 1 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE EN-ID(WS-ROW-C) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a carrot on a pig starts love and is used" TO WS-CASE
     COMPUTE WS-EXPECT = 600 * 10 + 0
     COMPUTE WS-OBSERVE = EN-LOVE(WS-ROW-C) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     MOVE "horse" TO WS-WANT-KEY
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     MOVE "donkey" TO WS-WANT-KEY
     MOVE 3 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE "golden_carrot" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a golden carrot does not start the love of an untamed horse" TO WS-CASE
     COMPUTE WS-EXPECT = 2 * 10 + 0
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-LOVE(WS-ROW-A)
     PERFORM CHECK-N
     MOVE 1 TO EN-TAMED(WS-ROW-A) EN-TAMED(WS-ROW-B)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE EN-ID(WS-ROW-B) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 18§8.1 Love mode and breeding: a tamed horse and a tamed donkey eat the golden carrots and are in love" TO WS-CASE
     COMPUTE WS-EXPECT = 600 * 1000 + 600
     COMPUTE WS-OBSERVE = EN-LOVE(WS-ROW-A) * 1000 + EN-LOVE(WS-ROW-B)
     PERFORM CHECK-N
     MOVE 0 TO EN-MOBAGE(WS-BABY) EN-VARIANT(WS-BABY)
     MOVE "mule" TO WS-WANT-KEY
     PERFORM FIND-TYPE
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-BABIES > 0
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW-A
         CALL "MOB-STEP" USING WS-ROW-B
         PERFORM COUNT-BABIES
     END-PERFORM
     MOVE "acceptance US15 18§8.1 Love mode and breeding: the baby of a horse and a donkey is a mule" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-BABIES = 1 AND EN-TYPE(WS-BABY) = WS-WANT-TYPE
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 FIND-TYPE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS.

 GIVE-HELD.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1).

 COUNT-BABIES.
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-MOBAGE(WS-N) < 0 AND EN-VARIANT(WS-N) = 1
             ADD 1 TO WS-BABIES
             MOVE WS-N TO WS-BABY
         END-IF
     END-PERFORM.

 COUNT-ORBS.
     MOVE 0 TO WS-ORBS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = WS-ORB-TYPE
             ADD 1 TO WS-ORBS
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-BREEDING.
 COPY CORETEST.
