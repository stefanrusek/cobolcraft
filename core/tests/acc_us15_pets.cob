*> Acceptance test (US15; docs/protocol/18-mob-framework.md section 8.2, 19 section 6.1): a tame wolf (PET-TICK, STDMOB-STEP) stays where it sits, follows its owner from
*> beyond 10 blocks until within 2, teleports to an owner 12 or more blocks away, and defends its owner against a hostile mob that targets the owner. The world has a stone floor of 9 x 9 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-PETS.
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

     MOVE 0 TO WS-N
     MOVE "wolf" TO WS-WANT-KEY
     MOVE 2 TO WS-DX
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     PERFORM MAKE-TAME
*> Sitting
     MOVE 1 TO EN-SIT(WS-ROW-A)
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a sitting pet stays (walk code 2)" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE EN-X(WS-ROW-A) TO WS-FX
     COMPUTE EN-DEST-X(WS-ROW-A) = WS-CX + 4
     COMPUTE EN-DEST-Z(WS-ROW-A) = WS-CZ
     MOVE 100 TO EN-COOLDOWN(WS-ROW-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         CALL "STDMOB-STEP" USING WS-ROW-A
     END-PERFORM
     MOVE "acceptance US15 18§8.2 Taming, ownership: a sitting wolf does not walk in STDMOB-STEP" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER(WS-FX * 1000)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-X(WS-ROW-A) * 1000)
     PERFORM CHECK-N
*> Standing, owner close
     MOVE 0 TO EN-SIT(WS-ROW-A) EN-COOLDOWN(WS-ROW-A) EN-PET-MOVING(WS-ROW-A)
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a pet 2 blocks from its owner does nothing" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
*> Owner 11 blocks away: starts walking east
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW-A) + 11
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: an owner more than 10 blocks away is followed" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: the follow walk heads toward the owner" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-HX > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: the pet is walking" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EN-PET-MOVING(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*> Walking continues to 2 blocks
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW-A) + 3
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a walking pet goes on until 2 blocks" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW-A) + 1
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a pet within 2 blocks stops" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-WALK + EN-PET-MOVING(WS-ROW-A)
     PERFORM CHECK-N
*> Teleport at 13 blocks
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW-A) + 13
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a pet 12 or more blocks away teleports to its owner" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER(PL-X(WS-PLAYER) * 10)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-X(WS-ROW-A) * 10)
     PERFORM CHECK-N
*> Another owner (not online): nothing
     MOVE "x" TO EN-OWNER-UUID(WS-ROW-A)(1:1)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW-A) + 13
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a pet whose owner is not there stays" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE PL-UUID(WS-PLAYER) TO EN-OWNER-UUID(WS-ROW-A)
*> A whole walk through STDMOB-STEP: owner beyond the floor, wolf walks east
     COMPUTE EN-X(WS-ROW-A) = WS-CX - 3.5
     COMPUTE EN-Z(WS-ROW-A) = WS-CZ + 0.5
     MOVE EN-X(WS-ROW-A) TO WS-FX
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 7.5
     MOVE 0 TO EN-PET-MOVING(WS-ROW-A) EN-COOLDOWN(WS-ROW-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "STDMOB-STEP" USING WS-ROW-A
     END-PERFORM
     MOVE "acceptance US15 18§8.2 Taming, ownership: a tame wolf walks to its owner in STDMOB-STEP" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-X(WS-ROW-A) > WS-FX + 1
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
*> Defence: a hostile mob that targets the owner
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE EN-X(WS-ROW-A) = WS-CX + 0.5
     MOVE 0 TO EN-PET-MOVING(WS-ROW-A) EN-FOE(WS-ROW-A) EN-PET-CD(WS-ROW-A)
     MOVE "zombie" TO WS-WANT-KEY
     MOVE 3 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-B
     MOVE WS-PLAYER TO EN-TARGET(WS-ROW-B)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ROW-B)
     MOVE "zombie" TO WS-WANT-KEY
     MOVE -3 TO WS-DX
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-C
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a wolf takes the mob that targets its owner as its foe" TO WS-CASE
     MOVE WS-ROW-B TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: the wolf walks toward its foe" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-WALK TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE EN-HEALTH(WS-ROW-B) TO WS-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: no hit before the foe is in reach" TO WS-CASE
     MOVE WS-N TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE EN-X(WS-ROW-A) = EN-X(WS-ROW-B) - 1
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a wolf in reach bites its foe for 4" TO WS-CASE
     COMPUTE WS-EXPECT = WS-N - 4
     MOVE EN-HEALTH(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: the bite starts the 20-tick timer" TO WS-CASE
     MOVE 20 TO WS-EXPECT
     MOVE EN-PET-CD(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO EN-HURT(WS-ROW-B)
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: no second bite while the timer runs" TO WS-CASE
     COMPUTE WS-EXPECT = WS-N - 4
     MOVE EN-HEALTH(WS-ROW-B) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: the timer counts down" TO WS-CASE
     MOVE 19 TO WS-EXPECT
     MOVE EN-PET-CD(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US15 18§8.2 Taming, ownership: a mob that does not target the owner is left alone" TO WS-CASE
     MOVE 20 TO WS-EXPECT
     MOVE EN-HEALTH(WS-ROW-C) TO WS-OBSERVE
     PERFORM CHECK-N
*> A beaten foe is dropped; a sitting wolf drops its foe too
     MOVE 0 TO EN-HEALTH(WS-ROW-B)
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a defeated foe is dropped" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 20 TO EN-HEALTH(WS-ROW-B)
     PERFORM PET-CALL
     MOVE 1 TO EN-SIT(WS-ROW-A)
     PERFORM PET-CALL
     MOVE "acceptance US15 18§8.2 Taming, ownership: a pet ordered to sit drops its foe" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-FOE(WS-ROW-A) TO WS-OBSERVE
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
 END PROGRAM ACC-US15-PETS.
 COPY CORETEST.
