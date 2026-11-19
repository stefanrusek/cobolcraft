*> Acceptance test (lane p49r; docs/protocol/20 section 17, 17.1, 17.2, 17.3): the creaking's freeze-when-watched rule. An inactive creaking is activated by a player who looks at it from less than 12 blocks (it
*> then targets the player and is frozen: CAN_MOVE false, no walk, no attack, metadata 16 and 17 sent); an active one stays frozen while any non-disguised player of its nearest-players list looks at it; it
*> can move when nobody looks, is deactivated when nobody attackable is listed (a creative player is not attackable), a carved pumpkin on the head hides a player from an active creaking only. The list is
*> scanned every 20 ticks (follow range 32, no spectators, nearest first). gameplay/creaking_active is true from the time of day 12600 to 23400 in the Overworld.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CREAKSTATE.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-P4                  BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(1024).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 60.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-PUMPKIN             BINARY-LONG.
 01 WS-HEALTH              FLOAT-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HAS                 BINARY-LONG.
 01 WS-MOVED               FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-SPECIES             PIC X(24).
 01 WS-SCALE               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:carved_pumpkin" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-PUMPKIN WS-ITEM-ROW WS-STATUS
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 30
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 30
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 0.5
     COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5
     MOVE WS-X TO PL-X(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE 0 TO PL-MODE(WS-PLAYER) PL-PITCH(WS-PLAYER)
     MOVE -90 TO PL-YAW(WS-PLAYER)
*>   17.3: the attribute.
     MOVE 12599 TO WS-TIME
     PERFORM ATTR
     MOVE "gameplay/creaking_active is false at 12599" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
     MOVE 12600 TO WS-TIME
     PERFORM ATTR
     MOVE "gameplay/creaking_active is true at 12600" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
     MOVE 23400 TO WS-TIME
     PERFORM ATTR
     MOVE "gameplay/creaking_active is true at 23400" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
     MOVE 23401 TO WS-TIME
     PERFORM ATTR
     MOVE "gameplay/creaking_active is false at 23401" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
     COMPUTE WS-TIME = 24000 * 7 + 18000
     PERFORM ATTR
     MOVE "gameplay/creaking_active repeats every 24000 ticks (midnight of day 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
     MOVE 18000 TO WS-TIME
     MOVE 4 TO WS-I
     CALL "CREAKING-ACTIVE-ATTR" USING WS-I WS-TIME WS-FLAG
     MOVE "gameplay/creaking_active is false in the Nether at midnight" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-FLAG
*>   17.1: an inactive creaking 10 blocks east, the player looks at it.
     COMPUTE WS-X0 = WS-X + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE WS-X0 TO EN-X(WS-MOB)
     MOVE WS-Z TO EN-Z(WS-MOB)
     CALL "CRK-FIND" USING EN-ID(WS-MOB) WS-ONE WS-SLOT
     MOVE 1000 TO CRK-SENSOR(WS-SLOT)
     CALL "CREAKING-SENSE" USING WS-MOB WS-SLOT
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     CALL "MOB-STEP" USING WS-MOB
     MOVE "a creaking 10 blocks from a player who looks at it is activated" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CRK-ACTIVE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and it targets the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and it cannot move (CAN_MOVE false)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CRK-CAN-MOVE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-HAS
     INSPECT WS-PADDED TALLYING WS-HAS FOR ALL " 101"
     MOVE "and Set Entity Data (id 101, metadata 16 and 17) was sent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   Watched, it does not move for 30 ticks.
     MOVE EN-X(WS-MOB) TO WS-MOVED
     PERFORM 30 TIMES
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "a watched creaking stays where it is for 30 ticks (hundredths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-MOVED * 100
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-MOB) * 100
     PERFORM ASSERT-LINE
*>   The player looks away: it can move (and stays active), and walks towards the player.
     MOVE 90 TO PL-YAW(WS-PLAYER)
     PERFORM 20 TIMES
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "when nobody looks it can move and stays active" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CRK-CAN-MOVE(WS-SLOT) * 10 + CRK-ACTIVE(WS-SLOT)
     PERFORM ASSERT-LINE
     MOVE "and walks towards the player (x decreased)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-MOB) < WS-MOVED - 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   Looking again freezes it where it stands.
     MOVE -90 TO PL-YAW(WS-PLAYER)
     CALL "MOB-STEP" USING WS-MOB
     MOVE EN-X(WS-MOB) TO WS-MOVED
     PERFORM 10 TIMES
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "looked at again it freezes where it stands (hundredths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-MOVED * 100
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-MOB) * 100
     PERFORM ASSERT-LINE
*>   A frozen creaking next to the player does not hit: 60 ticks with the player looking at it.
     COMPUTE EN-X(WS-MOB) = WS-X + 1
     MOVE 0 TO EN-COOLDOWN(WS-MOB)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     PERFORM 60 TIMES
         CALL "MOB-STEP" USING WS-MOB
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     END-PERFORM
     MOVE "a frozen creaking next to the player does not attack in 60 ticks" TO TL-CASE
     MOVE 20000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PL-HEALTH(WS-PLAYER) * 1000
     PERFORM ASSERT-LINE
     MOVE 90 TO PL-YAW(WS-PLAYER)
     PERFORM 60 TIMES
         CALL "MOB-STEP" USING WS-MOB
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     END-PERFORM
     MOVE "and it attacks as soon as nobody looks (3 damage on Normal)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   17.1 d: a player 13 blocks away who looks at an inactive creaking does not activate it.
     MOVE -90 TO PL-YAW(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     COMPUTE WS-X0 = WS-X + 13
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     CALL "CRK-FIND" USING EN-ID(WS-MOB) WS-ONE WS-SLOT
     MOVE 1000 TO CRK-SENSOR(WS-SLOT)
     CALL "CREAKING-SENSE" USING WS-MOB WS-SLOT
     CALL "MOB-STEP" USING WS-MOB
     MOVE "looked at from 13 blocks an inactive creaking is not activated and can move" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CRK-CAN-MOVE(WS-SLOT) * 10 + CRK-ACTIVE(WS-SLOT)
     PERFORM ASSERT-LINE
*>   An active creaking stays frozen from any distance in the list (13 blocks).
     MOVE 1 TO CRK-ACTIVE(WS-SLOT)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "an active creaking is frozen by a look from 13 blocks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CRK-CAN-MOVE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A creative player is not attackable: nobody attackable in the list deactivates it.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "a creative viewer does not count: the creaking is deactivated and can move" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CRK-CAN-MOVE(WS-SLOT) * 10 + CRK-ACTIVE(WS-SLOT)
     PERFORM ASSERT-LINE
     MOVE "and its target is erased" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 0 TO PL-MODE(WS-PLAYER)
*>   An empty list deactivates an active creaking.
     MOVE 1 TO CRK-ACTIVE(WS-SLOT)
     MOVE 0 TO CRK-COUNT(WS-SLOT)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "an empty nearest-players list deactivates it" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CRK-CAN-MOVE(WS-SLOT) * 10 + CRK-ACTIVE(WS-SLOT)
     PERFORM ASSERT-LINE
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   The carved pumpkin: an active creaking ignores a masked viewer, an inactive one is still woken by it.
     COMPUTE WS-X0 = WS-X + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     CALL "CRK-FIND" USING EN-ID(WS-MOB) WS-ONE WS-SLOT
     MOVE 1000 TO CRK-SENSOR(WS-SLOT)
     CALL "CREAKING-SENSE" USING WS-MOB WS-SLOT
     MOVE WS-PUMPKIN TO MN-EQUIP-ITEM(WS-PLAYER, 4)
     MOVE 1 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 4)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "an inactive creaking is still activated by a viewer wearing a pumpkin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CRK-ACTIVE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     CALL "MOB-STEP" USING WS-MOB
     MOVE "an active creaking ignores a masked viewer: it can move" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CRK-CAN-MOVE(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 4)
     CALL "ENTITY-REMOVE" USING WS-MOB
*>   17.2: the list. Four more players: a survival one at 20 blocks, an adventure one at 5, a spectator at 3, a survival one at 40 (beyond 32).
     MOVE "Alex" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-P2
     MOVE "Bo" TO WS-NAME
     MOVE 2 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-P3
     MOVE "Cy" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-P4
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-X - 40
     COMPUTE PL-X(WS-P2) = WS-X + 20
     MOVE 0 TO PL-MODE(WS-P2)
     COMPUTE PL-X(WS-P3) = WS-X + 5
     MOVE 2 TO PL-MODE(WS-P3)
     COMPUTE PL-X(WS-P4) = WS-X + 3
     MOVE 3 TO PL-MODE(WS-P4)
     MOVE WS-Y TO PL-Y(WS-P2) PL-Y(WS-P3) PL-Y(WS-P4)
     MOVE WS-Z TO PL-Z(WS-P2) PL-Z(WS-P3) PL-Z(WS-P4)
     COMPUTE WS-X0 = WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     CALL "CRK-FIND" USING EN-ID(WS-MOB) WS-ONE WS-SLOT
     CALL "CREAKING-SENSE" USING WS-MOB WS-SLOT
     MOVE "the list holds the two players within 32 blocks (not the spectator, not the one 40 away)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CRK-COUNT(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "the nearest (the adventure player at 5) comes first" TO TL-CASE
     MOVE WS-P3 TO TL-EXPECTED-N
     MOVE CRK-LIST(WS-SLOT, 1) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "then the survival player at 20" TO TL-CASE
     MOVE WS-P2 TO TL-EXPECTED-N
     MOVE CRK-LIST(WS-SLOT, 2) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   The creative player at 40 blocks walks within range: the list is only refreshed by the next scan.
     COMPUTE PL-X(WS-PLAYER) = WS-X - 10
     MOVE 1000 TO CRK-SENSOR(WS-SLOT)
     PERFORM 19 TIMES
         CALL "MOB-STEP" USING WS-MOB
         MOVE 1000 TO CRK-SENSOR(WS-SLOT)
     END-PERFORM
     MOVE "a player who came within range after the scan is not listed before the next scan" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CRK-COUNT(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 1 TO CRK-SENSOR(WS-SLOT)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "the scan of the tick brings it in" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE CRK-COUNT(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and the sensor restarts at 20 ticks" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE CRK-SENSOR(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   The strolls of the warden and the creaking are scaled by the square of their stroll modifiers (0.5 against 1.2, and 0.3).
     MOVE "warden" TO WS-SPECIES
     CALL "STDMOB-STROLL-SCALE" USING WS-SPECIES WS-SCALE
     MOVE "the warden's stroll scale is (0.5 / 1.2) squared (ten thousandths)" TO TL-CASE
     MOVE 1736 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALE * 10000
     PERFORM ASSERT-LINE
     MOVE "creaking" TO WS-SPECIES
     CALL "STDMOB-STROLL-SCALE" USING WS-SPECIES WS-SCALE
     MOVE "the creaking's stroll scale is 0.3 squared (hundredths)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALE * 100
     PERFORM ASSERT-LINE
*>   With every state slot taken a creaking has no brain: nothing happens to it.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CRK-MAX
         COMPUTE CRK-ID(WS-I) = 900000 + WS-I
     END-PERFORM
     MOVE EN-X(WS-MOB) TO WS-MOVED
     CALL "CREAKING-BRAIN" USING WS-MOB
     MOVE "a creaking without a state slot is left alone" TO TL-CASE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-MOVED * 100
     COMPUTE TL-OBSERVED-N ROUNDED = EN-X(WS-MOB) * 100
     PERFORM ASSERT-LINE
     STOP RUN.

 ATTR.
     MOVE 3 TO WS-I
     CALL "CREAKING-ACTIVE-ATTR" USING WS-I WS-TIME WS-FLAG
     .

 ASSERT-FLAG.
     MOVE WS-FLAG TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     .

 ASSERT-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "acceptance US15 20§17 Creaking: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-17-3.
 COPY CORETEST.
 COPY MOBSPTEST.
