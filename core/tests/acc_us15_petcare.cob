*> Acceptance test (US15; docs/protocol/19 sections 5.1, 5.2 and 6.1): care of tame pets through the real play path (Interact 0x1A): a hurt tame wolf eats wolf food and heals
*> 2 x nutrition, a dye of the owner sets the collar (metadata 21 of a wolf, 23 of a cat), a cat is tamed with raw cod or salmon (1 in 3, owner, sit order, events 6 and 7), a tame
*> cat heals 1 x nutrition, an ocelot trusts a player after raw fish (1 in 3, events 40 and 41, metadata 18). The world has a stone floor of 9 x 9 blocks at y = floor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PETCARE.
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
 01 WS-MDI                 BINARY-LONG.
 01 WS-MDV                 BINARY-LONG.
 01 WS-MDS                 BINARY-LONG.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
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

*> A tame wolf of the player, 10 of 40 health, holding cooked beef: the wolf eats, heals 2 x nutrition and the beef is used
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     MOVE EN-ID(WS-ROW-A) TO WS-ID-A
     MOVE 1 TO EN-TAMED(WS-ROW-A)
     MOVE 0 TO EN-SIT(WS-ROW-A)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW-A)
     MOVE 10 TO EN-HEALTH(WS-ROW-A)
     MOVE "cooked_beef" TO WS-ITEM-KEY
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a hurt tame wolf heals 2 x nutrition of cooked beef" TO WS-CASE
     MOVE 26 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the food is a real heal (more than 10 health)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-HEALTH(WS-ROW-A) > 10
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: feeding uses one item" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: feeding leaves the sit order" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*> Healing stops at 40
     MOVE 39 TO EN-HEALTH(WS-ROW-A)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: healing stops at 40 health" TO WS-CASE
     MOVE 40 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*> A wolf at full health does not eat: the hand toggles the sit order instead
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a healthy wolf does not eat" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: a healthy wolf's food use toggles the sit order" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*> Not a wolf food (an apple): nothing eaten, health stays
     MOVE 0 TO EN-SIT(WS-ROW-A)
     MOVE 10 TO EN-HEALTH(WS-ROW-A)
     MOVE "apple" TO WS-ITEM-KEY
     MOVE 3 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: an apple is no wolf food" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: an apple does not heal" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-SIT(WS-ROW-A)
*> Collar dye of the owner: blue (11) sets the collar, one dye is used, the sit order stays, Set Entity Data goes out
     MOVE "blue_dye" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE 0 TO WS-COUNT-ITEM
     INSPECT WS-IDS TALLYING WS-COUNT-ITEM FOR ALL "101"
     MOVE "acceptance US15 19§6.1 Wolf: a collar dye sends Set Entity Data" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT-ITEM TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the owner's blue dye sets the collar (dye id 11)" TO WS-CASE
     MOVE 12 TO WS-EXPECT
     MOVE EN-COLLAR(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: a collar dye uses one dye" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: a collar dye leaves the sit order" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 21 TO WS-MDI
     PERFORM FIND-DATA
     MOVE "acceptance US15 19§6.1 Wolf: metadata 21 is the collar colour INT 11" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     MOVE WS-MDV TO WS-OBSERVE
     PERFORM CHECK-N
*> The same colour again is not a dye use: it toggles the sit order and keeps the dye
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: the same collar colour is not used again" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: the same collar colour toggles the sit order" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*> A stranger's dye does nothing
     MOVE "x" TO EN-OWNER-UUID(WS-ROW-A)(1:1)
     MOVE "red_dye" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§6.1 Wolf: a stranger's dye keeps the collar" TO WS-CASE
     MOVE 12 TO WS-EXPECT
     MOVE EN-COLLAR(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§6.1 Wolf: a stranger's dye is not used" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N

*> An untamed cat: raw cod tames it with chance 1 in 3, each use takes one cod; the owner is the player, the sit order is on, the viewers get Entity Event 7
     MOVE "cat" TO WS-WANT-KEY
     MOVE -2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE EN-ID(WS-ROW-B) TO WS-ID-A
     MOVE "acceptance US15 19§5.1 Cat: a new cat has 10 health and is wild" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-HEALTH(WS-ROW-B) + 100 * EN-TAMED(WS-ROW-B)
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§5.1 Cat: an empty hand does not tame a wild cat" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-TAMED(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "cod" TO WS-ITEM-KEY
     MOVE 60 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE 0 TO WS-N WS-HITS
     PERFORM UNTIL EN-TAMED(WS-ROW-B) = 1 OR WS-N >= 50
         ADD 1 TO WS-N
         CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
         CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
     END-PERFORM
     MOVE "acceptance US15 19§5.1 Cat: raw cod tames the cat within 50 tries" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-TAMED(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: every try used one cod" TO WS-CASE
     COMPUTE WS-EXPECT = 60 - WS-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: taming sets the sit order and keeps 10 health" TO WS-CASE
     MOVE 11 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-SIT(WS-ROW-B) * 10 + (EN-HEALTH(WS-ROW-B) / 10)
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: the owner is the player" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     IF EN-OWNER-UUID(WS-ROW-B) NOT = PL-UUID(WS-PLAYER)
         MOVE 1 TO WS-EXPECT
     END-IF
     MOVE 0 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE SPACES TO WS-NEEDLE
     MOVE EN-ID(WS-ROW-B) TO WS-EDIT
     STRING "event " DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE " 7" DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-COUNT-ITEM
     INSPECT WS-TEXT TALLYING WS-COUNT-ITEM FOR ALL FUNCTION TRIM(WS-NEEDLE)
     MOVE "acceptance US15 19§5.1 Cat: taming sent Entity Event 7" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT-ITEM TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 18 TO WS-MDI
     MOVE WS-ROW-B TO WS-ROW-A
     PERFORM FIND-DATA
     MOVE "acceptance US15 19§5.1 Cat: metadata 18 of a tame sitting cat is 5" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     MOVE WS-MDV TO WS-OBSERVE
     PERFORM CHECK-N
*> A tame cat of the owner: raw cod heals 1 x nutrition while hurt
     MOVE 0 TO EN-SIT(WS-ROW-B)
     MOVE 4 TO EN-HEALTH(WS-ROW-B)
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-COUNT-TOTAL
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§5.1 Cat: a hurt tame cat heals 1 x nutrition of raw cod" TO WS-CASE
     MOVE 6 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: feeding a tame cat uses one cod" TO WS-CASE
     COMPUTE WS-EXPECT = WS-COUNT-TOTAL - 1
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: feeding leaves the sit order" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-SIT(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
*> Healthy tame cat with cod: sit toggles, nothing eaten
     MOVE 10 TO EN-HEALTH(WS-ROW-B)
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-COUNT-TOTAL
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§5.1 Cat: a healthy tame cat toggles the sit order and eats nothing" TO WS-CASE
     COMPUTE WS-EXPECT = 10 + WS-COUNT-TOTAL
     COMPUTE WS-OBSERVE = EN-SIT(WS-ROW-B) * 10 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
*> Cat collar: the owner's dye sets it, metadata 23
     MOVE 0 TO EN-SIT(WS-ROW-B)
     MOVE "green_dye" TO WS-ITEM-KEY
     MOVE 2 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§5.1 Cat: the owner's green dye sets the collar (dye id 13)" TO WS-CASE
     MOVE 14 TO WS-EXPECT
     MOVE EN-COLLAR(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: a collar dye uses one dye" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 23 TO WS-MDI
     MOVE WS-ROW-B TO WS-ROW-A
     PERFORM FIND-DATA
     MOVE "acceptance US15 19§5.1 Cat: metadata 23 is the collar colour INT 13" TO WS-CASE
     MOVE 13 TO WS-EXPECT
     MOVE WS-MDV TO WS-OBSERVE
     PERFORM CHECK-N

*> An ocelot: raw salmon makes it trust with chance 1 in 3 (Entity Event 41, else 40), each use takes one salmon; trust is metadata 18 BOOLEAN
     MOVE "ocelot" TO WS-WANT-KEY
     MOVE 0 TO WS-DX
     MOVE 3 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-C
     MOVE EN-ID(WS-ROW-C) TO WS-ID-A
     MOVE "salmon" TO WS-ITEM-KEY
     MOVE 60 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE 0 TO WS-N WS-HITS
     PERFORM UNTIL EN-TAMED(WS-ROW-C) = 1 OR WS-N >= 50
         ADD 1 TO WS-N
         CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
         CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
         IF EN-TAMED(WS-ROW-C) = 0
             MOVE SPACES TO WS-NEEDLE
             MOVE EN-ID(WS-ROW-C) TO WS-EDIT
             STRING "event " DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE " 40" DELIMITED BY SIZE INTO WS-NEEDLE
             MOVE 0 TO WS-COUNT-ITEM
             INSPECT WS-TEXT TALLYING WS-COUNT-ITEM FOR ALL FUNCTION TRIM(WS-NEEDLE)
             ADD WS-COUNT-ITEM TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§5.2 Ocelot: raw salmon makes it trust within 50 tries" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-TAMED(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.2 Ocelot: every try used one salmon" TO WS-CASE
     COMPUTE WS-EXPECT = 60 - WS-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE WS-N = WS-N - 1
     MOVE "acceptance US15 19§5.2 Ocelot: every failed try sent Entity Event 40" TO WS-CASE
     MOVE WS-N TO WS-EXPECT
     MOVE WS-HITS TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE SPACES TO WS-NEEDLE
     MOVE EN-ID(WS-ROW-C) TO WS-EDIT
     STRING "event " DELIMITED BY SIZE FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE " 41" DELIMITED BY SIZE INTO WS-NEEDLE
     MOVE 0 TO WS-COUNT-ITEM
     INSPECT WS-TEXT TALLYING WS-COUNT-ITEM FOR ALL FUNCTION TRIM(WS-NEEDLE)
     MOVE "acceptance US15 19§5.2 Ocelot: trust sent Entity Event 41" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT-ITEM TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 18 TO WS-MDI
     MOVE WS-ROW-C TO WS-ROW-A
     PERFORM FIND-DATA
     MOVE "acceptance US15 19§5.2 Ocelot: metadata 18 is the trusting boolean 1" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-MDV TO WS-OBSERVE
     PERFORM CHECK-N
*> A trusting ocelot ignores the salmon
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-COUNT-TOTAL
     CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
     MOVE "acceptance US15 19§5.2 Ocelot: a trusting ocelot takes no more salmon" TO WS-CASE
     MOVE WS-COUNT-TOTAL TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 1) TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> FIND-DATA: Set Entity Data as MOB-DATA-BUILD makes it for row WS-ROW-A: the value of entry WS-MDI (BOOLEAN, BYTE, INT: the int), -1 when absent
 FIND-DATA.
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW-A MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-MDV
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = WS-MDI
                 MOVE MQ-MX-INT TO WS-MDV
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING MQ-BUFFER.

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
 END PROGRAM ACC-US15-PETCARE.
 COPY CORETEST.
