*> Implementation test (wrap C round 4; docs 19 section 4, 44 part 4 section 3, 18 AvoidEntityGoal and MoveToBlockGoal): the rabbit's hop and move control, RabbitAvoidEntity (Player 8,
*> Wolf 10, Monster 4), RaidGarden (the ring search, the bite, mob_griefing, moreCarrotTicks) and the killer bunny's target and attack, with the walk of STDMOB-STEP.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-4-GOALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY GAMEEVENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-RABBIT-TYPE         BINARY-LONG.
 01 WS-WOLF-TYPE           BINARY-LONG.
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-GRASS               BINARY-LONG VALUE 2.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-R                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-CARROTS             PIC X(112) VALUE "minecraft:carrots".
 01 WS-FARMLAND            PIC X(112) VALUE "minecraft:farmland".
 01 WS-FARM-STATE          BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CROP-KEY            PIC X(32).
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-POWER               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-CHASE               BINARY-LONG.
 01 WS-HOPPED              BINARY-LONG.
 01 WS-LIFE                BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-PH                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CARROT-ITEM         BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-R2                  BINARY-LONG.
 01 WS-X-BEFORE            FLOAT-LONG.
 01 WS-ENV                 PIC X(1024).
 01 WS-ROOT                PIC X(1100).
 01 WS-LOOT                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   The loot tables of the content set (a world opens them with WORLD-LOOT-OPEN; the test world does not).
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV NOT = SPACES
         MOVE SPACES TO WS-ROOT
         STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
         CALL "LOOT-LOAD" USING WS-ROOT WS-STATUS
         IF WS-STATUS = 0
             MOVE 1 TO WS-LOOT
         END-IF
     END-IF
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-GRASS
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     COMPUTE WS-RX = WS-X0 + 24.5
     COMPUTE WS-RZ = WS-Z0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:rabbit" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-RABBIT-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:wolf" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WOLF-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:carrot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-CARROT-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

*>   The pure rules.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE 600 TO WS-MOD MOVE 0 TO WS-ABOVE MOVE 200 TO WS-E
             WHEN 2 MOVE 1000 TO WS-MOD MOVE 0 TO WS-ABOVE MOVE 300 TO WS-E
             WHEN 3 MOVE 1000 TO WS-MOD MOVE 1 TO WS-ABOVE MOVE 500 TO WS-E
             WHEN OTHER MOVE 0 TO WS-MOD MOVE 0 TO WS-ABOVE MOVE 200 TO WS-E
         END-EVALUATE
         CALL "RABBIT-HOP-POWER" USING WS-MOD WS-ABOVE WS-POWER
         MOVE "implementation 19§4 Rabbit: the hop power is 0.3, 0.2 at modifier 0.6 or less, 0.5 toward a higher node" TO WS-CASE
         MOVE WS-POWER TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1 MOVE 600 TO WS-MOD MOVE 10 TO WS-E
             WHEN 2 MOVE 2000 TO WS-MOD MOVE 10 TO WS-E
             WHEN OTHER MOVE 2200 TO WS-MOD MOVE 3 TO WS-E
         END-EVALUATE
         CALL "RABBIT-LANDING-DELAY" USING WS-MOD WS-DELAY
         MOVE "implementation 19§4 Rabbit: the landing delay is 10 below modifier 2.2, else 3" TO WS-CASE
         MOVE WS-DELAY TO WS-O
         PERFORM CHECK-N
     END-PERFORM
     MOVE 600 TO WS-MOD
     CALL "RABBIT-SPEED" USING WS-MOD WS-SPEED
     MOVE "implementation 19§4 Rabbit: the stroll speed 0.6 is 71 thousandths of the table" TO WS-CASE
     MOVE 71 TO WS-E
     COMPUTE WS-O = WS-SPEED * 1000
     PERFORM CHECK-N
     MOVE 2200 TO WS-MOD
     CALL "RABBIT-SPEED" USING WS-MOD WS-SPEED
     MOVE "implementation 19§4 Rabbit: the flee speed 2.2 is 959 thousandths of the table" TO WS-CASE
     MOVE 959 TO WS-E
     COMPUTE WS-O = WS-SPEED * 1000
     PERFORM CHECK-N
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         CALL "RABBIT-SEQ" USING WS-I WS-W
         COMPUTE WS-N = WS-N * 10 + WS-W + 5
     END-PERFORM
     MOVE "implementation 18§4 MoveToBlockGoal: the offsets run 0, 1, -1, 2, -2" TO WS-CASE
     MOVE 5 TO WS-E
     MOVE 5 TO WS-E
     COMPUTE WS-E = 5 * 10000 + 6 * 1000 + 4 * 100 + 7 * 10 + 3
     MOVE WS-N TO WS-O
     PERFORM CHECK-N

*>   Hop and move control: a fresh rabbit has just landed (delay 10) and stands until the delay is over; the 11th call hops with power 0.2 at the stroll modifier.
     MOVE WS-RABBIT-TYPE TO WS-N
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE 0 TO EN-VY(WS-R)
     MOVE 0.05 TO WS-HX
     MOVE 0 TO WS-HZ
     MOVE 600 TO WS-MOD
     CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     MOVE "implementation 44-4§3 Rabbit: just landed it stands (the speed modifier is 0: no walk)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-HX * 1000
     PERFORM CHECK-N
     MOVE "implementation 44-4§3 Rabbit: just landed the jump delay is 10" TO WS-CASE
     MOVE 10 TO WS-E
     MOVE WC-JUMP-DELAY(WS-R) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-HOPPED
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 12 OR WS-HOPPED > 0
         MOVE 0.05 TO WS-HX
         CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
         IF WC-HOPPING(WS-R) = 1
             MOVE WS-I TO WS-HOPPED
         END-IF
     END-PERFORM
     MOVE "implementation 44-4§3 Rabbit: the hop starts when the delay of 10 is over (the 11th call)" TO WS-CASE
     MOVE 11 TO WS-E
     MOVE WS-HOPPED TO WS-O
     PERFORM CHECK-N
     MOVE "implementation 44-4§3 Rabbit: the hop's vertical speed is 0.2 at the stroll modifier" TO WS-CASE
     MOVE 200 TO WS-E
     COMPUTE WS-O ROUNDED = EN-VY(WS-R) * 1000
     PERFORM CHECK-N
     MOVE "implementation 44-4§3 Rabbit: in the air the walk goes on" TO WS-CASE
     MOVE 50 TO WS-E
     MOVE 0 TO EN-ON-GROUND(WS-R)
     CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     COMPUTE WS-O ROUNDED = WS-HX * 1000
     PERFORM CHECK-N
     MOVE "implementation 44-4§3 Rabbit: the hop's tick counter counts up while it is in the air" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WC-HOP-TICKS(WS-R) TO WS-O
     PERFORM CHECK-N
     MOVE 14 TO WC-HOP-TICKS(WS-R)
     CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     MOVE "implementation 44-4§3 Rabbit: the hop animation ends after 15 ticks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-HOPPING(WS-R) TO WS-O
     PERFORM CHECK-N
*>   Landing from a panic hop (modifier 2.2): the delay is 3.
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE 2200 TO WS-MOD
     MOVE 0 TO WS-HX
     CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     MOVE "implementation 44-4§3 Rabbit: landing from a flee hop (2.2) sets the delay to 3" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WC-JUMP-DELAY(WS-R) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WC-MORE-CARROT(WS-R)
     MOVE 40 TO WC-MORE-CARROT(WS-R)
     CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     MOVE "implementation 19§4 RaidGarden: moreCarrotTicks counts down by nextInt(3) (0 to 2 a tick)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WC-MORE-CARROT(WS-R) >= 38 AND WC-MORE-CARROT(WS-R) <= 40
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         CALL "RABBIT-HOP" USING WS-R WS-HX WS-HZ WS-MOD
     END-PERFORM
     MOVE "implementation 19§4 RaidGarden: moreCarrotTicks reaches 0 and stays there" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-MORE-CARROT(WS-R) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R

*>   RabbitAvoidEntity: a player within 8 is fled from at the panic speed, straight away; 9 away, a creative player and one 4 blocks above are not.
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 5
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a player 5 blocks away is avoided" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: it flees away from the player at the flee speed (959)" TO WS-CASE
     MOVE 959 TO WS-E
     COMPUTE WS-O ROUNDED = WS-HX * 1000
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 9
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a player 9 blocks away is not avoided (the distance is 8)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 5
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a creative player is not avoided" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-Y(WS-PLAYER) = WS-Y + 4
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 2
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a player more than 3 blocks above is not avoided (the box is inflated by 3)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
*>   Below the player's own position: the player is exactly on top of the rabbit's cell (distance 0): flee along +x.
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-RX TO PL-X(WS-PLAYER)
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a player on the rabbit's own spot is fled from along +x" TO WS-CASE
     MOVE 959 TO WS-E
     COMPUTE WS-O = WS-HX * 1000
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
*>   A wolf within 10, a zombie within 4 (a monster), neither beyond.
     COMPUTE WS-D0 = WS-RX - 9
     CALL "MOB-SPAWN" USING WS-DIM WS-WOLF-TYPE WS-D0 WS-Y WS-RZ WS-YAW WS-W
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a wolf 9 blocks away is avoided (RabbitAvoidEntity(Wolf, 10))" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: it flees from the wolf, away from it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HX > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE EN-X(WS-W) = WS-RX - 11
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a wolf 11 blocks away is not avoided" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-W
     COMPUTE WS-D0 = WS-RX + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-D0 WS-Y WS-RZ WS-YAW WS-W
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a zombie 3 blocks away is avoided (RabbitAvoidEntity(Monster, 4))" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: it flees from the zombie toward -x" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HX < 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE EN-X(WS-W) = WS-RX + 5
     CALL "RABBIT-AVOID" USING WS-R WS-HX WS-HZ WS-FOUND
     MOVE "acceptance US15 19§4 Rabbit: a zombie 5 blocks away is not avoided" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-W

*>   RaidGarden: the ring search finds the nearest ring first; the walk, the bite and the cooldowns.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-RX)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-RZ)
     COMPUTE WS-CY = WS-FLOOR + 1
     MOVE WS-FARMLAND TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FARM-STATE
     MOVE WS-CARROTS TO WS-KEY
     MOVE "age=3" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     COMPUTE WS-W = WS-CX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-FLOOR WS-CZ WS-FARM-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-CZ WS-STATE
     COMPUTE WS-W = WS-CX + 2
     COMPUTE WS-Z = WS-CZ + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-FLOOR WS-Z WS-FARM-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-Z WS-STATE
     CALL "RABBIT-RAID-FIND" USING WS-R WS-FX WS-FY WS-FZ WS-FOUND
     MOVE "implementation 18§4 MoveToBlockGoal: the nearest ring is searched first (a crop at (2,2) before one at (3,0))" TO WS-CASE
     COMPUTE WS-E = (WS-CX + 2) * 1000 + WS-FOUND
     COMPUTE WS-O = WS-FX * 1000 + WS-FOUND
     PERFORM CHECK-N
     MOVE "implementation 18§4 MoveToBlockGoal: the target is the crop cell (z and y)" TO WS-CASE
     COMPUTE WS-E = (WS-CZ + 2) * 1000 + WS-CY
     COMPUTE WS-O = WS-FZ * 1000 + WS-FY
     PERFORM CHECK-N
*>   A crop only below the standing layer is found at the vertical offset -1 (the cell is M + (a, v - 1, b) = M + (a, -2, b)).
     COMPUTE WS-W = WS-CX + 2
     COMPUTE WS-Z = WS-CZ + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-Z WS-AIR
     COMPUTE WS-W = WS-CX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-CZ WS-AIR
     COMPUTE WS-W = WS-CX - 1
     COMPUTE WS-Z = WS-FLOOR - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-Z WS-CZ WS-STATE
     CALL "RABBIT-RAID-FIND" USING WS-R WS-FX WS-FY WS-FZ WS-FOUND
     MOVE "implementation 18§4 MoveToBlockGoal: a crop two layers down is found at the offset -1" TO WS-CASE
     COMPUTE WS-E = (WS-CX - 1) * 1000000 + (WS-FLOOR - 1) * 1000 + 1
     COMPUTE WS-O = WS-FX * 1000000 + WS-FY * 1000 + WS-FOUND
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-Z WS-CZ WS-AIR
     CALL "RABBIT-RAID-FIND" USING WS-R WS-FX WS-FY WS-FZ WS-FOUND
     MOVE "implementation 18§4 MoveToBlockGoal: with no crop within the search range nothing is found" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-W = WS-CX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-CZ WS-STATE
     COMPUTE WS-W = WS-CX + 2
     COMPUTE WS-Z = WS-CZ + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-W WS-CY WS-Z WS-STATE
*>   RaidGarden starts only with the mob_griefing rule on.
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     COMPUTE EN-X(WS-R) = WS-CX + 0.5
     COMPUTE EN-Z(WS-R) = WS-CZ + 0.5
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: RaidGarden does not start with mob_griefing off" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-RAID-ON(WS-R) TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   Wanting more food only when moreCarrotTicks is 0: the goal is re-rolled (200 to 399 ticks) but finds nothing.
     MOVE 30 TO WC-MORE-CARROT(WS-R)
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: RaidGarden does not start while moreCarrotTicks is above 0" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-RAID-ON(WS-R) TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: the next start of the goal is 200 + nextInt(200) ticks ahead" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WC-RAID-WAIT(WS-R) >= 200 AND WC-RAID-WAIT(WS-R) <= 399
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A second tick counts the wait down and does not look again.
     MOVE WC-RAID-WAIT(WS-R) TO WS-PH
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: the wait of the goal counts down by 1 a tick" TO WS-CASE
     COMPUTE WS-E = WS-PH - 1
     MOVE WC-RAID-WAIT(WS-R) TO WS-O
     PERFORM CHECK-N
*>   Ready to raid: the walk toward the crop at modifier 1.0.
     MOVE 0 TO WC-MORE-CARROT(WS-R) WC-RAID-WAIT(WS-R)
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: RaidGarden walks to the crop (walk 1, modifier 1.0)" TO WS-CASE
     MOVE 1001 TO WS-E
     COMPUTE WS-O = WS-WALK * 1000 + WC-RAID-ON(WS-R)
     IF WS-MOD = 1000
         ADD 1000 TO WS-O
         SUBTRACT 1000 FROM WS-O
     END-IF
     COMPUTE WS-O = WS-WALK * 1000 + WC-RAID-ON(WS-R)
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: the walk is toward the crop (+x, +z) at 0.198 along the diagonal" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HX > 0.13 AND WS-HX < 0.15 AND WS-HZ > 0.13 AND WS-HZ < 0.15 AND WS-MOD = 1000
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   Arrival: the crop of age 3 goes down to age 2, moreCarrotTicks 40, the next start 10 ticks ahead.
     COMPUTE EN-X(WS-R) = WS-CX + 2.5
     COMPUTE EN-Z(WS-R) = WS-CZ + 2.5
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     COMPUTE WS-FX = WS-CX + 2
     COMPUTE WS-FZ = WS-CZ + 2
     CALL "VL-CROP-AT" USING WS-DIM WS-FX WS-CY WS-FZ WS-KIND WS-AGE WS-MAX WS-CROP-KEY
     MOVE "acceptance US15 19§4 Rabbit: on arrival the bite takes the crop from age 3 to age 2" TO WS-CASE
     MOVE 2002 TO WS-E
     COMPUTE WS-O = WS-KIND * 1000 + WS-AGE
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: after a bite moreCarrotTicks is 40, the next start 10 and the goal ends" TO WS-CASE
     MOVE 40010 TO WS-E
     COMPUTE WS-O = WC-MORE-CARROT(WS-R) * 1000 + WC-RAID-WAIT(WS-R) * 10 + WC-RAID-ON(WS-R)
     COMPUTE WS-E = 40 * 1000 + 100
     PERFORM CHECK-N
*>   A crop of age 0 is broken with its drops: the cell is air.
     MOVE "age=0" TO WS-PAIRS
     MOVE WS-CARROTS TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FX WS-CY WS-FZ WS-STATE
     MOVE 1 TO WC-RAID-ON(WS-R)
     MOVE WS-FX TO WC-RAID-X(WS-R)
     MOVE WS-CY TO WC-RAID-Y(WS-R)
     MOVE WS-FZ TO WC-RAID-Z(WS-R)
     PERFORM COUNT-ITEMS
     MOVE WS-N TO WS-PH
     CALL "RABBIT-RAID-BITE" USING WS-R
     PERFORM COUNT-ITEMS
     CALL "VL-CROP-AT" USING WS-DIM WS-FX WS-CY WS-FZ WS-KIND WS-AGE WS-MAX WS-CROP-KEY
     MOVE "acceptance US15 19§4 Rabbit: a crop of age 0 is broken (the cell is air)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-KIND TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: the broken crop drops items" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N > WS-PH OR WS-LOOT = 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   The goal gives up when the crop is gone (or after 1200 ticks).
     MOVE 1 TO WC-RAID-ON(WS-R)
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: RaidGarden ends when the crop is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-RAID-ON(WS-R) TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-FX = WS-CX + 3
     MOVE WS-CZ TO WS-FZ
     MOVE 1 TO WC-RAID-ON(WS-R)
     MOVE WS-FX TO WC-RAID-X(WS-R)
     MOVE WS-CY TO WC-RAID-Y(WS-R)
     MOVE WS-FZ TO WC-RAID-Z(WS-R)
     MOVE 1200 TO WC-RAID-TRY(WS-R)
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: RaidGarden gives up after 1200 ticks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WC-RAID-ON(WS-R) TO WS-O
     PERFORM CHECK-N
*>   A player in range makes the rabbit flee before it raids (RabbitAvoidEntity ranks above RaidGarden) and ends the raid.
     MOVE 1 TO WC-RAID-ON(WS-R)
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-R) - 4
     MOVE EN-Z(WS-R) TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     CALL "RABBIT-TICK" USING WS-R WS-HX WS-HZ WS-WALK WS-MOD
     MOVE "acceptance US15 19§4 Rabbit: a player near ends the raid and the rabbit flees at 2.2" TO WS-CASE
     MOVE 12200 TO WS-E
     COMPUTE WS-O = WS-WALK * 10000 + WS-MOD + WC-RAID-ON(WS-R) * 100000
     COMPUTE WS-E = 1 * 10000 + 2200
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     CALL "ENTITY-REMOVE" USING WS-R

*>   The killer bunny (variant 99): the target is the nearest survival player within 16; its attack is 3 + 5.
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 99 TO EN-WOOL(WS-R)
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 6
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     CALL "RABBIT-EVIL-TICK" USING WS-R WS-CHASE
     MOVE "acceptance US15 19§4 Killer bunny: it takes the survival player 6 blocks away as its target" TO WS-CASE
     COMPUTE WS-E = WS-PLAYER * 10 + 1
     COMPUTE WS-O = EN-TARGET(WS-R) * 10 + WS-CHASE
     PERFORM CHECK-N
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "RABBIT-EVIL-TICK" USING WS-R WS-HX
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US15 19§4 Killer bunny: a player who goes creative is dropped as a target" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-TARGET(WS-R) TO WS-O
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 17
     CALL "RABBIT-EVIL-TICK" USING WS-R WS-CHASE
     MOVE "acceptance US15 19§4 Killer bunny: a player 17 blocks away is not a target (range 16)" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-TARGET(WS-R) + WS-CHASE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 6
     CALL "RABBIT-EVIL-TICK" USING WS-R WS-CHASE
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 18
     CALL "RABBIT-EVIL-TICK" USING WS-R WS-CHASE
     MOVE "acceptance US15 19§4 Killer bunny: a target that went beyond 16 blocks is dropped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-TARGET(WS-R) TO WS-O
     PERFORM CHECK-N
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-R) WS-M
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-R WS-M WS-DAMAGE
     MOVE "acceptance US15 19§4 Killer bunny: attack damage 3 + the evil modifier 5" TO WS-CASE
     MOVE 8 TO WS-E
     MOVE WS-DAMAGE TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO EN-WOOL(WS-R)
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-R WS-M WS-DAMAGE
     MOVE "acceptance US15 19§4 Rabbit: any other variant has attack damage 3" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-DAMAGE TO WS-O
     PERFORM CHECK-N
     MOVE 0.0713 TO WS-HX
     MOVE 0.0713 TO WS-HZ
     CALL "RABBIT-EVIL-SCALE" USING WS-HX WS-HZ
     MOVE "acceptance US15 19§4 Killer bunny: the chase runs at modifier 1.4 against the stroll's 0.6 (0.389)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-HX > 0.385 AND WS-HX < 0.392 AND WS-HZ > 0.385 AND WS-HZ < 0.392
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R

*>   STDMOB-STEP: a killer bunny comes for the player and bites; its health 8 damage reaches the player.
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 99 TO EN-WOOL(WS-R)
     MOVE 1 TO EN-ON-GROUND(WS-R)
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 6
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         ADD 1 TO CW-TIME
         CALL "STDMOB-STEP" USING WS-R
     END-PERFORM
     MOVE "acceptance US15 19§4 Killer bunny: it hops to the player and bites" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF PL-HEALTH(WS-PLAYER) < WS-HEALTH
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R
*>   STDMOB-STEP: an ordinary rabbit flees a player in hops, farther than 8 blocks after 60 ticks, and leaves the ground.
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 3
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE WS-Y TO WS-MAXY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         ADD 1 TO CW-TIME
         CALL "STDMOB-STEP" USING WS-R
         IF EN-Y(WS-R) > WS-MAXY
             MOVE EN-Y(WS-R) TO WS-MAXY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§4 Rabbit: it flees a player in hops (it leaves the ground)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAXY > WS-Y + 0.05
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: after 60 ticks it is more than 8 blocks from the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-R) - PL-X(WS-PLAYER) > 8
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R
*>   The modifier of the goal that walks sets the hop power: flee (2.2), tempt (1.0) and breed (0.8) hop with 0.3, whose apex is 0.70 above the floor (0.2 at the stroll gives 0.36).
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 1 TO EN-ON-GROUND(WS-R)
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 3
     MOVE WS-RZ TO PL-Z(WS-PLAYER)
     MOVE WS-Y TO PL-Y(WS-PLAYER)
     MOVE 30 TO EN-FLEE(WS-R)
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-R)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-R)
     MOVE EN-X(WS-R) TO WS-X-BEFORE
     PERFORM RUN-HOPPER
     MOVE "acceptance US15 19§4 Rabbit: a hurt rabbit panics (2.2): its hops reach the apex of power 0.3" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAXY > WS-Y + 0.55 AND WS-MAXY < WS-Y + 0.8
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: a hurt rabbit panics away from the attacker" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-R) > WS-X-BEFORE + 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R
*>   Tempt: a player 6 blocks away holds a carrot; the rabbit comes (modifier 1.0) instead of fleeing from the player within 8.
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 1 TO EN-ON-GROUND(WS-R)
     COMPUTE PL-X(WS-PLAYER) = WS-RX - 6
     MOVE WS-CARROT-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1) PL-HELD(WS-PLAYER)
     MOVE EN-X(WS-R) TO WS-X-BEFORE
     PERFORM RUN-HOPPER
     MOVE "acceptance US15 19§4 Rabbit: tempted by a carrot it hops with power 0.3" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAXY > WS-Y + 0.55 AND WS-MAXY < WS-Y + 0.8
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§4 Rabbit: Tempt (priority 3) comes before RabbitAvoidEntity (4): it walks toward the player" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-X(WS-R) < WS-X-BEFORE - 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "ENTITY-REMOVE" USING WS-R
*>   Breed: two rabbits in love 5 blocks apart; the first walks to the other (modifier 0.8).
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 4.5
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-RX WS-Y WS-RZ WS-YAW WS-R
     MOVE 1 TO EN-ON-GROUND(WS-R)
     COMPUTE WS-D0 = WS-RX + 5
     CALL "MOB-SPAWN" USING WS-DIM WS-RABBIT-TYPE WS-D0 WS-Y WS-RZ WS-YAW WS-R2
     MOVE 600 TO EN-LOVE(WS-R) EN-LOVE(WS-R2)
     MOVE EN-X(WS-R) TO WS-X-BEFORE
     PERFORM RUN-HOPPER
     MOVE "acceptance US15 19§4 Rabbit: in love it hops to its partner with power 0.3" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAXY > WS-Y + 0.55 AND WS-MAXY < WS-Y + 0.8 AND EN-X(WS-R) > WS-X-BEFORE + 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     STOP RUN.
 RUN-HOPPER.
     MOVE WS-Y TO WS-MAXY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         ADD 1 TO CW-TIME
         CALL "STDMOB-STEP" USING WS-R
         IF EN-Y(WS-R) > WS-MAXY
             MOVE EN-Y(WS-R) TO WS-MAXY
         END-IF
     END-PERFORM.
 COUNT-ITEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > EN-COUNT
         IF EN-USED(WS-W) = 1 AND EN-TYPE(WS-W) = WS-ITEM-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-4-GOALS.
 COPY CORETEST.
 COPY MOBSPTEST.
