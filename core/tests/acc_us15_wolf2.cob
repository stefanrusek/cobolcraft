*> Acceptance test (US15; docs/protocol/19 section 6.1, 18 section 8.2): wolf anger by a hit of a player, alerting wolves, the owner's hurt-target defence, a tame wolf standing up when hurt, wolf armour (equip, absorb, break, repair, drop).
*> The world has a stone floor of 9 x 9 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-WOLF2.
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
 01 WS-V-BABY              BINARY-LONG.
 01 WS-V-WOOL              BINARY-LONG.
 01 WS-V-NEEDED            BINARY-LONG.
 01 WS-CAUSE-PLAYER     BINARY-LONG VALUE 3.
 01 WS-CAUSE-MOB        BINARY-LONG VALUE 7.
 01 WS-AMOUNT           BINARY-LONG.
 01 WS-ROW-D            BINARY-LONG.
 01 WS-ARMOR-ID         BINARY-LONG.
 01 WS-SCUTE-ID         BINARY-LONG.
 01 WS-WANT-ROW         BINARY-LONG.
 01 WS-COIN0            BINARY-LONG VALUE 0.
 01 WS-ELEVEN           BINARY-LONG VALUE 11.
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

*> A wild wolf hit by the player is angry at the player; a wolf of the pack nearby takes the target too
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 3 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     MOVE "wolf" TO WS-WANT-KEY
     MOVE -3 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 1 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW-A WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
     MOVE "acceptance US15 19§6.1 Wolf: a wild wolf hit by a player is angry" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-ANGER(WS-ROW-A) > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the angry wolf's target is the attacker" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-TARGET(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: a wolf nearby without a target takes the anger and the target" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     MOVE EN-TARGET(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
*> The angry wolf walks to the player and bites
     COMPUTE EN-X(WS-ROW-A) = PL-X(WS-PLAYER) + 0.5
     COMPUTE EN-Z(WS-ROW-A) = PL-Z(WS-PLAYER)
     MOVE 0 TO EN-COOLDOWN(WS-ROW-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "STDMOB-STEP" USING WS-ROW-A
     END-PERFORM
     MOVE "acceptance US15 19§6.1 Wolf: an angry wolf in reach bites the player" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
*> The anger runs out
     MOVE 1 TO EN-ANGER(WS-ROW-A)
     CALL "STDMOB-STEP" USING WS-ROW-A
     MOVE "acceptance US15 19§6.1 Wolf: the anger runs out and the target is dropped" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-ANGER(WS-ROW-A) + EN-TARGET(WS-ROW-A)
     PERFORM CHECK-N
*> A tame wolf is not angered by its owner; a sitting wolf stands up when hurt
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 1 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-C
     MOVE WS-ROW-C TO WS-ROW-A
     PERFORM MAKE-TAME
     MOVE 1 TO EN-SIT(WS-ROW-C)
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW-C WS-AMOUNT WS-CAUSE-PLAYER WS-PLAYER
     MOVE "acceptance US15 19§6.1 Wolf: a tame wolf is not angered by a hit" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-ANGER(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: any damage makes a tame sitting wolf stand" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
*> OwnerHurtTarget: the mob the owner hit is the wolf's foe; a creeper and a tame wolf of the owner are not
     PERFORM CLEAR-KILLERS
     MOVE 0 TO EN-FOE(WS-ROW-C) EN-FOE-ID(WS-ROW-C)
     MOVE "creeper" TO WS-WANT-KEY
     MOVE -2 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-D
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW-D)
     MOVE 100 TO EN-KILLER-AGE(WS-ROW-D)
     MOVE WS-ROW-C TO WS-ROW-A
     PERFORM PET-CALL
     MOVE "acceptance US15 19§6.1 Wolf: a creeper the owner hit is not attacked" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW-B)
     MOVE 100 TO EN-KILLER-AGE(WS-ROW-B)
     MOVE 1 TO EN-TAMED(WS-ROW-B)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW-B)
     PERFORM PET-CALL
     MOVE "acceptance US15 19§6.1 Wolf: a tame wolf of the owner is not attacked" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-TAMED(WS-ROW-B) EN-KILLER(WS-ROW-B)
     MOVE "zombie" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-D
     MOVE WS-PLAYER TO EN-KILLER(WS-ROW-D)
     MOVE 60 TO EN-KILLER-AGE(WS-ROW-D)
     PERFORM PET-CALL
     MOVE "acceptance US15 19§6.1 Wolf: the mob the owner hit becomes the foe (OwnerHurtTarget)" TO WS-CASE
     MOVE WS-ROW-D TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
*> Wolf armour: the owner equips it
     MOVE "wolf_armor" TO WS-ITEM-KEY
     MOVE 1 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE WS-ITEM-ID TO WS-ARMOR-ID
     MOVE EN-ID(WS-ROW-C) TO WS-ID-A
     MOVE 40 TO EN-HEALTH(WS-ROW-C)
     MOVE 0 TO EN-MOBAGE(WS-ROW-C)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: the owner's wolf armour is worn by an adult wolf" TO WS-CASE
     MOVE WS-ARMOR-ID TO WS-EXPECT
     MOVE EN-WOLF-ARM(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: one armour item is used" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
*> The armour absorbs a hit: the wolf is unhurt, the item takes ceil(amount)
     MOVE 0 TO EN-HURT(WS-ROW-C)
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW-C WS-AMOUNT WS-CAUSE-MOB WS-ZERO
     MOVE "acceptance US15 19§6.1 Wolf: the armour absorbs the hit, the wolf keeps its health" TO WS-CASE
     MOVE 40 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the armour item is damaged by the amount" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE EN-WOLF-ARM-DMG(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
*> Repair with an armadillo scute while sitting: floor(64 x 0.125) = 8 points
     MOVE 30 TO EN-WOLF-ARM-DMG(WS-ROW-C)
     MOVE 1 TO EN-SIT(WS-ROW-C)
     MOVE "armadillo_scute" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a scute repairs 8 points of a sitting wolf's armour" TO WS-CASE
     MOVE 22 TO WS-EXPECT
     MOVE EN-WOLF-ARM-DMG(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the repair uses one scute and the wolf keeps sitting" TO WS-CASE
     COMPUTE WS-EXPECT = 1 * 10 + 1
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-SIT(WS-ROW-C)
     PERFORM CHECK-N
*> A standing wolf is not repaired (the hand toggles sit instead)
     MOVE 0 TO EN-SIT(WS-ROW-C)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a standing wolf's armour is not repaired" TO WS-CASE
     MOVE 22 TO WS-EXPECT
     MOVE EN-WOLF-ARM-DMG(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
*> The armour breaks; a baby is not armoured; a worn armour is not replaced; the armour drops on death
     MOVE 62 TO EN-WOLF-ARM-DMG(WS-ROW-C)
     MOVE 0 TO EN-HURT(WS-ROW-C)
     MOVE 5 TO WS-AMOUNT
     CALL "HEALTH-MOB-DAMAGE" USING WS-ROW-C WS-AMOUNT WS-CAUSE-MOB WS-ZERO
     MOVE "acceptance US15 19§6.1 Wolf: armour worn out by the hit is gone, the hit still absorbed" TO WS-CASE
     MOVE 40 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-HEALTH(WS-ROW-C) + EN-WOLF-ARM(WS-ROW-C)
     PERFORM CHECK-N
     MOVE "wolf_armor" TO WS-ITEM-KEY
     MOVE 1 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE -24000 TO EN-MOBAGE(WS-ROW-C)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a baby wolf wears no armour" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-WOLF-ARM(WS-ROW-C) + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     MOVE 0 TO EN-MOBAGE(WS-ROW-C)
     MOVE "x" TO EN-OWNER-UUID(WS-ROW-C)(1:1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: only the owner puts armour on a wolf" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-WOLF-ARM(WS-ROW-C) + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW-C)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a grown wolf wears the armour with no damage" TO WS-CASE
     COMPUTE WS-EXPECT = WS-ARMOR-ID * 10
     COMPUTE WS-OBSERVE = EN-WOLF-ARM(WS-ROW-C) * 10 + EN-WOLF-ARM-DMG(WS-ROW-C)
     PERFORM CHECK-N
     MOVE 1 TO WS-GIVE-COUNT
     MOVE "wolf_armor" TO WS-ITEM-KEY
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a wolf in armour keeps it and the second armour is not used" TO WS-CASE
     COMPUTE WS-EXPECT = WS-ARMOR-ID + 1
     COMPUTE WS-OBSERVE = EN-WOLF-ARM(WS-ROW-C) + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     CALL "WOLF-ARMOR-DROP" USING WS-ROW-C
     PERFORM COUNT-ARMOR-ITEMS
     MOVE "acceptance US15 19§6.1 Wolf: the armour drops as an item when the wolf is killed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-N TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the dropped armour is no longer worn" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-WOLF-ARM(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "WOLF-ARMOR-DROP" USING WS-ROW-C
     PERFORM COUNT-ARMOR-ITEMS
     MOVE "acceptance US15 19§6.1 Wolf: a wolf without armour drops nothing" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-N TO WS-OBSERVE
     PERFORM CHECK-N
*> Breeding: tame wolves fall in love with food at full health, sitting wolves do not mate, the pup is tame with the mixed collar
     PERFORM CLEAR-KILLERS
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 3 TO WS-DX
     MOVE 3 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     PERFORM MAKE-TAME
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 3 TO WS-DX
     MOVE 2 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE WS-ROW-B TO WS-ROW-D
     MOVE WS-ROW-A TO WS-ROW-B
     MOVE WS-ROW-D TO WS-ROW-A
     PERFORM MAKE-TAME
     MOVE WS-ROW-B TO WS-ROW-A
     MOVE 1 TO EN-COLLAR(WS-ROW-A)
     MOVE 12 TO EN-COLLAR(WS-ROW-D)
     MOVE "cooked_beef" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a tame wolf at full health fed wolf food falls in love" TO WS-CASE
     MOVE 600 TO WS-EXPECT
     MOVE EN-LOVE(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: feeding for love uses one item and does not toggle sit" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + EN-SIT(WS-ROW-A)
     PERFORM CHECK-N
     MOVE EN-ID(WS-ROW-D) TO WS-ID-A
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE 1 TO EN-SIT(WS-ROW-D)
     MOVE WS-ROW-B TO WS-ROW-A
     CALL "MOB-PARTNER" USING WS-ROW-A WS-WANT-ROW
     MOVE "acceptance US15 19§6.1 Wolf: a sitting wolf is no partner" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WANT-ROW TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-SIT(WS-ROW-D)
     CALL "MOB-PARTNER" USING WS-ROW-A WS-WANT-ROW
     MOVE "acceptance US15 19§6.1 Wolf: two tame wolves in love are partners" TO WS-CASE
     MOVE WS-ROW-D TO WS-EXPECT
     MOVE WS-WANT-ROW TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "MOB-BREED" USING WS-ROW-A WS-ROW-D
     MOVE 0 TO WS-BABY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-MOBAGE(WS-I) < 0 AND EN-VARIANT(WS-I) = 1
             MOVE WS-I TO WS-BABY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§6.1 Wolf: breeding makes a pup" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-BABY > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the pup of a tame wolf is tame, owned and at 40 health" TO WS-CASE
     MOVE 40 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-TAMED(WS-BABY) = 1 AND EN-OWNER-UUID(WS-BABY) = PL-UUID(WS-PLAYER)
         MOVE EN-HEALTH(WS-BABY) TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO WS-DRAW
     CALL "M19-SHEEP-MIX" USING WS-ZERO WS-ELEVEN WS-COIN0 WS-COLOR
     MOVE "acceptance US15 19§6.1 Wolf: the pup's collar is the mix of the parents' collars" TO WS-CASE
     COMPUTE WS-EXPECT = WS-COLOR + 1
     MOVE EN-COLLAR(WS-BABY) TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

 MAKE-TAME.
     MOVE 1 TO EN-TAMED(WS-ROW-A)
     MOVE 0 TO EN-SIT(WS-ROW-A)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW-A)
     MOVE 40 TO EN-HEALTH(WS-ROW-A).

 PET-CALL.
     MOVE 0 TO WS-HX WS-HZ WS-WALK
     CALL "PET-TICK" USING WS-ROW-A WS-HX WS-HZ WS-WALK.

 CLEAR-KILLERS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         MOVE 0 TO EN-KILLER(WS-I) EN-KILLER-AGE(WS-I) EN-TARGET(WS-I) EN-ANGER(WS-I)
     END-PERFORM.

 COUNT-ARMOR-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-ITEM(WS-I) = WS-ARMOR-ID
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 GIVE-HELD.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1).

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-WOLF2.
 COPY CORETEST.
