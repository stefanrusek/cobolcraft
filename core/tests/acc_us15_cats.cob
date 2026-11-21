*> Acceptance test (US15; docs/protocol/19-mobs-land-friendly-and-neutral.md sections 5.1 and 5.2, 18 sections 4.2 and 8.2): a tame cat sits when ordered, follows its owner
*> from beyond 10 blocks until within 5 (FollowOwner 1.0, 10.0, 5.0) and teleports at 12; cats and ocelots are tempted by a player holding raw cod or salmon within 10 blocks
*> (speed 0.6, standing within 2.5, a 100-tick cooldown after the goal stops); an ocelot that does not trust runs from players within 16 blocks (0.8, sprint 1.33 within 7)
*> unless the tempt goal has a match. The world has a stone floor of 19 x 19 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-CATS.
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
 01 WS-D2                 FLOAT-LONG.
 01 WS-MOVING             BINARY-LONG.
 01 WS-ACTION             BINARY-LONG.
 01 WS-COD                BINARY-LONG.
 01 WS-STICK              BINARY-LONG.
 01 WS-CAT                BINARY-LONG.
 01 WS-OCELOT             BINARY-LONG.
 01 WS-DIST               FLOAT-LONG.
 01 WS-NEAR-HX            FLOAT-LONG.
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
     COMPUTE WS-XLO = WS-CX - 9
     COMPUTE WS-XHI = WS-CX + 9
     COMPUTE WS-ZLO = WS-CZ - 9
     COMPUTE WS-ZHI = WS-CZ + 9
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

     MOVE "raw cod" TO WS-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = "cod"
             COMPUTE WS-COD = WS-I - 1
         END-IF
         IF IT-KEY(WS-I) = "stick"
             COMPUTE WS-STICK = WS-I - 1
         END-IF
     END-PERFORM

*> The follow rule: start beyond 10 blocks, keep walking until within 5, teleport from 12
     MOVE 101 TO WS-D2
     MOVE 0 TO WS-MOVING
     CALL "CAT-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 19§5.1 Cat: a cat starts to follow its owner beyond 10 blocks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-ACTION TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 100 TO WS-D2
     CALL "CAT-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 19§5.1 Cat: within 10 blocks a standing cat stays" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-ACTION TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO WS-MOVING
     MOVE 26 TO WS-D2
     CALL "CAT-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 19§5.1 Cat: a walking cat goes on while farther than 5 blocks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-ACTION TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 25 TO WS-D2
     CALL "CAT-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 19§5.1 Cat: a walking cat stops within 5 blocks (stop distance 5.0)" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-ACTION TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 144 TO WS-D2
     CALL "CAT-FOLLOW" USING WS-D2 WS-MOVING WS-ACTION
     MOVE "acceptance US15 19§5.1 Cat: 12 blocks away it teleports to its owner" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-ACTION TO WS-OBSERVE
     PERFORM CHECK-N

*> A tame cat: sits when ordered, walks to its owner and stops 5 blocks away
     MOVE "cat" TO WS-WANT-KEY
     MOVE -3 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-CAT
     MOVE 1 TO EN-TAMED(WS-CAT)
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-CAT)
     MOVE 10 TO EN-HEALTH(WS-CAT)
     MOVE 1 TO EN-SIT(WS-CAT)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: a cat ordered to sit stays (walk code 2)" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-SIT(WS-CAT)
     COMPUTE EN-X(WS-CAT) = WS-CX - 3.5
     COMPUTE EN-Z(WS-CAT) = WS-CZ + 0.5
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 11
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: an owner 11 blocks away is followed (walk toward the owner)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE EN-X(WS-CAT) TO WS-FX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "STDMOB-STEP" USING WS-CAT
     END-PERFORM
     MOVE "acceptance US15 19§5.1 Cat: the cat walked toward its owner in STDMOB-STEP" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-X(WS-CAT) > WS-FX + 2
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: it stopped about 5 blocks from the owner, not 2 like a wolf" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     COMPUTE WS-DIST = PL-X(WS-PLAYER) - EN-X(WS-CAT)
     IF WS-DIST > 3.5 AND WS-DIST <= 5.2
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 13
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: an owner 12 or more blocks away: the cat teleports to it" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER(PL-X(WS-PLAYER) * 10)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-X(WS-CAT) * 10)
     PERFORM CHECK-N
     MOVE "x" TO EN-OWNER-UUID(WS-CAT)(1:1)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 11
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: a tame cat whose owner is not there stays" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-CAT

*> Tempt: an untamed cat walks to a player holding raw cod within 10 blocks, stands within 2.5, and cools down 100 ticks after the goal stops
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     MOVE "cat" TO WS-WANT-KEY
     MOVE -7 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-CAT
     MOVE 10 TO EN-HEALTH(WS-CAT)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: a player without food is not followed" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: the Tempt goal walks to a player holding cod within 10 blocks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: the tempt walk is at speed 0.6 (the stroll speed 0.8 scaled)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-HX > 0.05 AND WS-HX < 0.09
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 2
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: within 2.5 blocks of the tempting player the cat stands still" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 11
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: a player more than 10 blocks away does not tempt it" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: when the goal stops it cools down 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXPECT
     MOVE EN-PET-CD(WS-CAT) TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) + 5
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: no tempting during the cooldown" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§5.1 Cat: the cooldown counts down" TO WS-CASE
     MOVE 99 TO WS-EXPECT
     MOVE EN-PET-CD(WS-CAT) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-PET-CD(WS-CAT)
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: other items do not tempt" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.1 Cat: a spectator does not tempt" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "ENTITY-REMOVE" USING WS-CAT

*> Ocelot: tempted like a cat; while distrusting it runs from players within 16 blocks (walk 0.8, sprint 1.33 within 7); a trusting one does not
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     MOVE "ocelot" TO WS-WANT-KEY
     MOVE 5 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-OCELOT
     MOVE 10 TO EN-HEALTH(WS-OCELOT)
     MOVE WS-OCELOT TO WS-CAT
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: a distrusting ocelot within 7 blocks of a player runs away (sprint 1.33)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-WALK = 1 AND WS-HX > 0.3
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE WS-HX TO WS-NEAR-HX
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) - 12
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: between 7 and 16 blocks it walks away at 0.8" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-WALK = 1 AND WS-HX > 0.1 AND WS-HX < WS-NEAR-HX
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) - 17
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: a player beyond 16 blocks is not avoided" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) - 5
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: a creative player is avoided too (only a spectator is not)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: a spectator is not avoided" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO EN-TAMED(WS-OCELOT)
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: a trusting ocelot no longer avoids players" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-TAMED(WS-OCELOT)
     MOVE WS-COD TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-CAT) - 6
     PERFORM CAT-CALL
     MOVE "acceptance US15 19§5.2 Ocelot: the Tempt goal (priority 3) wins over the avoid goal (4): it walks to a player holding cod" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-WALK = 1 AND WS-HX < 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     STOP RUN.

 CAT-CALL.
     MOVE 0 TO WS-HX WS-HZ WS-WALK
     CALL "CAT-TICK" USING WS-CAT WS-HX WS-HZ WS-WALK.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-CATS.
 COPY CORETEST.
