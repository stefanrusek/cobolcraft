*> Rabbit goals and hop control (wrap C round 4; docs/protocol/19-mobs-land-friendly-and-neutral.md section 4, 44-residual-mob-questions-4-land-animals.md section 3,
*> 18-mob-framework.md AvoidEntityGoal and MoveToBlockGoal). Per-row state is WC-ROW of WCSTATE.cpy. The speed of a goal at modifier s is (0.3 x s) squared / 0.454 (the
*> convention of the SM table, 18 section 3.2.1): 0.6 stroll 0.071, 1.0 0.198, 1.4 attack 0.389, 2.2 flee 0.959.
*>   WC-ROW-OPEN USING row                                       the entry of the row belongs to the entity in it (a stale one is cleared)
*>   RABBIT-SPEED USING modifier (thousandths), speed out (FLOAT-LONG blocks per tick)
*>   RABBIT-HOP-POWER USING modifier, above (1 when the next node or the wanted position is more than 0.5 above), power out (thousandths)
*>   RABBIT-LANDING-DELAY USING modifier, delay out              checkLandingDelay: 10 below 2.2, else 3 (the panic hop)
*>   RABBIT-SEQ USING index, value out                           0, 1, -1, 2, -2 ... (the offset sequence of MoveToBlockGoal.findNearestBlock)
*>   RABBIT-AVOID USING row, hx out, hz out, found out           RabbitAvoidEntity: Player 8, Wolf 10, Monster 4 (speed 2.2)
*>   RABBIT-RAID-FIND USING row, x out, y out, z out, found out  MoveToBlockGoal.findNearestBlock for a carrot crop (search range 16, vertical 1)
*>   RABBIT-RAID-BITE USING row                                  RaidGarden's arrival: age 0 breaks the crop with drops, else age - 1; level event 2001
*>   RABBIT-TICK USING row, hx out, hz out, walk out, modifier out   the counters, RabbitAvoidEntity (walk 1, 2.2) then RaidGarden (walk 1, 1.0)
*>   RABBIT-HOP USING row, hx, hz (changed), modifier            the jump and move controls: a hop starts when the rabbit is on the ground with a walk and jumpDelayTicks 0
*>   RABBIT-EVIL-TICK USING row, chase out                       the killer bunny (variant 99): the nearest survival player within 16 is its target, MeleeAttack 1.4
*>   RABBIT-EVIL-SCALE USING hx, hz (changed)                    the chase of the killer bunny at modifier 1.4 against the table speed of the stroll
*> Gaps: RaidGarden's speed is not in the documents (taken as 1.0), nor the maturity test or the farmland check of isValidTarget; jumpFromGround's horizontal nudge (19 section 4)
*> is ambiguous in the document and is not applied; the killer bunny has no wolf target and no HurtByTarget (the hit handler of the core reaches neutral rows only).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-ROW-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF WC-ID(L-ROW) NOT = EN-ID(L-ROW)
         INITIALIZE WC-ROW(L-ROW)
         MOVE EN-ID(L-ROW) TO WC-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM WC-ROW-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-SPEED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOD                  BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-MOD L-SPEED.
     COMPUTE L-SPEED = (0.3 * L-MOD / 1000) * (0.3 * L-MOD / 1000) / 0.454
     GOBACK.
 END PROGRAM RABBIT-SPEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-HOP-POWER.
*> The base power 0.3; 0.2 when the speed modifier is at most 0.6; 0.5 when the next path node (or, while jumping, the wanted position) is more than 0.5 above.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOD                  BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-MOD L-ABOVE L-POWER.
     MOVE 300 TO L-POWER
     IF L-MOD <= 600
         MOVE 200 TO L-POWER
     END-IF
     IF L-ABOVE = 1
         MOVE 500 TO L-POWER
     END-IF
     GOBACK.
 END PROGRAM RABBIT-HOP-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-LANDING-DELAY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOD                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-MOD L-DELAY.
     MOVE 10 TO L-DELAY
     IF L-MOD >= 2200
         MOVE 3 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RABBIT-LANDING-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-SEQ.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-VALUE.
     IF FUNCTION MOD(L-INDEX, 2) = 1
         COMPUTE L-VALUE = (L-INDEX + 1) / 2
     ELSE
         COMPUTE L-VALUE = 0 - L-INDEX / 2
     END-IF
     GOBACK.
 END PROGRAM RABBIT-SEQ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-AVOID.
*> The three goals are tried in the order of registration (Player 8, Wolf 10, Monster 4; all priority 4): the first whose class has a living entity within its distance (the box
*> inflated by (r, 3, r) and the distance r) is the one to flee, which a creative or spectator player is not. The flee walk is straight away from it at the panic speed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-CLASS               BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-X              FLOAT-LONG.
 01 WS-BEST-Z              FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-FLEE                BINARY-LONG VALUE 2200.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-FOUND.
     MOVE 0 TO L-HX L-HZ L-FOUND WS-BEST
     PERFORM VARYING WS-CLASS FROM 1 BY 1 UNTIL WS-CLASS > 3 OR WS-BEST = 1
         EVALUATE WS-CLASS
             WHEN 1 MOVE 8 TO WS-RADIUS
             WHEN 2 MOVE 10 TO WS-RADIUS
             WHEN OTHER MOVE 4 TO WS-RADIUS
         END-EVALUATE
         COMPUTE WS-LIMIT = WS-RADIUS * WS-RADIUS
         IF WS-CLASS = 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-PLAYERS
                 IF PL-USED(WS-I) = 1 AND PL-STATE(WS-I) = PS-ALIVE AND PL-DIM(WS-I) = EN-DIM(L-ROW)
                         AND PL-MODE(WS-I) NOT = 1 AND PL-MODE(WS-I) NOT = 3
                     COMPUTE WS-DX = EN-X(L-ROW) - PL-X(WS-I)
                     COMPUTE WS-DY = EN-Y(L-ROW) - PL-Y(WS-I)
                     COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(WS-I)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF WS-D2 <= WS-LIMIT AND FUNCTION ABS(WS-DY) <= 3 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                         MOVE 1 TO WS-BEST
                         MOVE WS-D2 TO WS-BEST-D2
                         MOVE PL-X(WS-I) TO WS-BEST-X
                         MOVE PL-Z(WS-I) TO WS-BEST-Z
                     END-IF
                 END-IF
             END-PERFORM
         ELSE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
                 IF EN-USED(WS-I) = 1 AND WS-I NOT = L-ROW AND EN-DIM(WS-I) = EN-DIM(L-ROW) AND EN-HEALTH(WS-I) > 0
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-I) WS-K
                     MOVE 0 TO WS-OK
                     IF WS-K > 0
                         IF WS-CLASS = 2 AND SM-KEY(WS-K) = "wolf"
                             MOVE 1 TO WS-OK
                         END-IF
                         IF WS-CLASS = 3 AND SM-KIND(WS-K) = 1
                             MOVE 1 TO WS-OK
                         END-IF
                     END-IF
                     IF WS-OK = 1
                         COMPUTE WS-DX = EN-X(L-ROW) - EN-X(WS-I)
                         COMPUTE WS-DY = EN-Y(L-ROW) - EN-Y(WS-I)
                         COMPUTE WS-DZ = EN-Z(L-ROW) - EN-Z(WS-I)
                         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                         IF WS-D2 <= WS-LIMIT AND FUNCTION ABS(WS-DY) <= 3 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                             MOVE 1 TO WS-BEST
                             MOVE WS-D2 TO WS-BEST-D2
                             MOVE EN-X(WS-I) TO WS-BEST-X
                             MOVE EN-Z(WS-I) TO WS-BEST-Z
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF WS-BEST = 1
         MOVE 1 TO L-FOUND
         COMPUTE WS-DX = EN-X(L-ROW) - WS-BEST-X
         COMPUTE WS-DZ = EN-Z(L-ROW) - WS-BEST-Z
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         CALL "RABBIT-SPEED" USING WS-FLEE WS-SPEED
         IF WS-H > 0
             COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
             COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
         ELSE
             MOVE WS-SPEED TO L-HX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RABBIT-AVOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-RAID-FIND.
*> The candidate cells in the order of MoveToBlockGoal.findNearestBlock (18 section 4): the vertical offset v 0, 1, -1; the ring radius r from 0 to 15; a over 0, 1, -1 ... up to r;
*> b is r then -r while |a| < r and 0, 1, -1 ... up to r when |a| = r; the cell is M + (a, v - 1, b). The first cell with a carrot crop is the target.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VI                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-AI                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-BLAST               BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-FOUND.
     MOVE 0 TO L-FOUND L-X L-Y L-Z
     COMPUTE WS-MX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-MY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-MZ = FUNCTION INTEGER(EN-Z(L-ROW))
     PERFORM VARYING WS-VI FROM 0 BY 1 UNTIL WS-VI > 2 OR L-FOUND = 1
         EVALUATE WS-VI
             WHEN 0 MOVE 0 TO WS-V
             WHEN 1 MOVE 1 TO WS-V
             WHEN OTHER MOVE -1 TO WS-V
         END-EVALUATE
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 15 OR L-FOUND = 1
             PERFORM VARYING WS-AI FROM 0 BY 1 UNTIL WS-AI > 2 * WS-R OR L-FOUND = 1
                 CALL "RABBIT-SEQ" USING WS-AI WS-A
                 IF FUNCTION ABS(WS-A) < WS-R
                     MOVE 1 TO WS-BLAST
                 ELSE
                     COMPUTE WS-BLAST = 2 * WS-R
                 END-IF
                 PERFORM VARYING WS-BI FROM 0 BY 1 UNTIL WS-BI > WS-BLAST OR L-FOUND = 1
                     IF FUNCTION ABS(WS-A) < WS-R
                         IF WS-BI = 0
                             MOVE WS-R TO WS-B
                         ELSE
                             COMPUTE WS-B = 0 - WS-R
                         END-IF
                     ELSE
                         CALL "RABBIT-SEQ" USING WS-BI WS-B
                     END-IF
                     COMPUTE WS-X = WS-MX + WS-A
                     COMPUTE WS-Y = WS-MY + WS-V - 1
                     COMPUTE WS-Z = WS-MZ + WS-B
                     CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND WS-AGE WS-MAX WS-KEY
                     IF WS-KIND = 2
                         MOVE 1 TO L-FOUND
                         MOVE WS-X TO L-X
                         MOVE WS-Y TO L-Y
                         MOVE WS-Z TO L-Z
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM RABBIT-RAID-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-RAID-BITE.
*> The crop at the goal's cell: age 0 is replaced by air and destroyed with its drops (the rabbit as the breaker), any other age goes down by 1; either way level event 2001 with the
*> state the crop had, moreCarrotTicks 40 and the next start of the goal 10 ticks ahead.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-TOOL                BINARY-LONG VALUE 0.
 01 WS-TOOL-COUNT          BINARY-LONG VALUE 0.
 01 WS-TOOL-HANDLE         BINARY-LONG VALUE 0.
 01 WS-RADIUS-SET          BINARY-LONG VALUE 0.
 01 WS-RADIUS              FLOAT-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 2001.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-KEY112              PIC X(112) VALUE "minecraft:carrots".
 01 WS-PAIRS               PIC X(160).
 01 WS-AGE-TEXT            PIC 9.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-KIND WS-AGE WS-MAX WS-KEY
     IF WS-KIND = 2
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-STATE
         IF WS-AGE = 0
             CALL "BLOCK-DROPS-SPAWN" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-STATE WS-TOOL
                 WS-TOOL-COUNT WS-TOOL-HANDLE WS-RADIUS-SET WS-RADIUS WS-FOUND
             CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-AIR
         ELSE
             COMPUTE WS-NEW = WS-AGE - 1
             MOVE WS-NEW TO WS-AGE-TEXT
             MOVE SPACES TO WS-PAIRS
             STRING "age=" DELIMITED BY SIZE WS-AGE-TEXT DELIMITED BY SIZE INTO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY112 WS-PAIRS WS-NEW
             CALL "WORLD-SET-BLOCK" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-NEW
         END-IF
         CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-EVENT WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-STATE WS-NONE
     END-IF
     MOVE 40 TO WC-MORE-CARROT(L-ROW)
     MOVE 10 TO WC-RAID-WAIT(L-ROW)
     MOVE 0 TO WC-RAID-ON(L-ROW)
     GOBACK.
 END PROGRAM RABBIT-RAID-BITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-TICK.
*> One tick of the rabbit's own goals that rank below Breed and Tempt (the caller only calls it when neither walks): the next start of RaidGarden counts down by 1. RabbitAvoidEntity (priority 4) before RaidGarden (5). RaidGarden needs the mob_griefing rule: when its wait is over it is evaluated again at
*> 200 + nextInt(200) ticks, and starts only with moreCarrotTicks 0 and a carrot crop found; it walks to the crop at modifier 1.0, gives up after 1200 ticks and bites on arrival
*> (within 1.0 of the crop's centre).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-SALT-WAIT           BINARY-LONG VALUE 197.
 01 WS-TWO-HUNDRED         BINARY-LONG VALUE 200.
 01 WS-DRAW                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-FOLLOW              BINARY-LONG VALUE 1000.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-MOD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK L-MOD.
     MOVE 0 TO L-HX L-HZ L-WALK L-MOD
     CALL "WC-ROW-OPEN" USING L-ROW
     IF WC-RAID-WAIT(L-ROW) > 0
         SUBTRACT 1 FROM WC-RAID-WAIT(L-ROW)
     END-IF
     CALL "RABBIT-AVOID" USING L-ROW L-HX L-HZ WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO L-WALK
         MOVE 2200 TO L-MOD
         MOVE 0 TO WC-RAID-ON(L-ROW)
         GOBACK
     END-IF
     IF WC-RAID-ON(L-ROW) = 0 AND WC-RAID-WAIT(L-ROW) = 0
         CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
         IF WS-RULE = 1
             CALL "XP-RANDOM" USING WS-SALT-WAIT WS-TWO-HUNDRED WS-DRAW
             COMPUTE WC-RAID-WAIT(L-ROW) = 200 + WS-DRAW
             IF WC-MORE-CARROT(L-ROW) = 0
                 CALL "RABBIT-RAID-FIND" USING L-ROW WS-X WS-Y WS-Z WS-FOUND
                 IF WS-FOUND = 1
                     MOVE 1 TO WC-RAID-ON(L-ROW)
                     MOVE WS-X TO WC-RAID-X(L-ROW)
                     MOVE WS-Y TO WC-RAID-Y(L-ROW)
                     MOVE WS-Z TO WC-RAID-Z(L-ROW)
                     MOVE 0 TO WC-RAID-TRY(L-ROW)
                 END-IF
             END-IF
         END-IF
     END-IF
     IF WC-RAID-ON(L-ROW) = 1
         ADD 1 TO WC-RAID-TRY(L-ROW)
         CALL "VL-CROP-AT" USING EN-DIM(L-ROW) WC-RAID-X(L-ROW) WC-RAID-Y(L-ROW) WC-RAID-Z(L-ROW) WS-KIND WS-AGE WS-MAX WS-KEY
         IF WS-KIND NOT = 2 OR WC-RAID-TRY(L-ROW) > 1200
             MOVE 0 TO WC-RAID-ON(L-ROW)
         ELSE
             COMPUTE WS-DX = WC-RAID-X(L-ROW) + 0.5 - EN-X(L-ROW)
             COMPUTE WS-DZ = WC-RAID-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
             COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
             MOVE 1 TO L-WALK
             MOVE 1000 TO L-MOD
             IF WS-H <= 1 AND FUNCTION ABS(EN-Y(L-ROW) - WC-RAID-Y(L-ROW)) <= 1.5
                 CALL "RABBIT-RAID-BITE" USING L-ROW
             ELSE
                 CALL "RABBIT-SPEED" USING WS-FOLLOW WS-SPEED
                 COMPUTE L-HX = WS-DX / WS-H * WS-SPEED
                 COMPUTE L-HZ = WS-DZ / WS-H * WS-SPEED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RABBIT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-HOP.
*> The jump control and the move control (44 part 4 section 3). jumpDelayTicks counts down each tick, moreCarrotTicks by nextInt(3) (floor 0). A rabbit on the ground that was in the air on the last tick has landed: the hop
*> ends and the delay is 10, or 3 when the goal's speed modifier is 2.2 or more. On the ground with no hop it stands (the speed modifier is 0: the walk is cleared) until it
*> has a walk and the delay is 0; then it hops: vertical speed from RABBIT-HOP-POWER, entity event 1 to the viewers; the walk then goes on in the air.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 1.
 01 WS-ABOVE               BINARY-LONG VALUE 0.
 01 WS-POWER               BINARY-LONG.
 01 WS-SALT-CARROT         BINARY-LONG VALUE 193.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-MOD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-MOD.
     CALL "WC-ROW-OPEN" USING L-ROW
     IF WC-MORE-CARROT(L-ROW) > 0
         CALL "XP-RANDOM" USING WS-SALT-CARROT WS-THREE WS-DRAW
         COMPUTE WC-MORE-CARROT(L-ROW) = FUNCTION MAX(WC-MORE-CARROT(L-ROW) - WS-DRAW, 0)
     END-IF
     IF WC-JUMP-DELAY(L-ROW) > 0
         SUBTRACT 1 FROM WC-JUMP-DELAY(L-ROW)
     END-IF
     IF WC-HOPPING(L-ROW) = 1
         ADD 1 TO WC-HOP-TICKS(L-ROW)
     END-IF
     IF EN-ON-GROUND(L-ROW) = 1
         IF WC-WAS-GROUND(L-ROW) = 0
             MOVE 0 TO WC-HOPPING(L-ROW) WC-HOP-TICKS(L-ROW)
             CALL "RABBIT-LANDING-DELAY" USING L-MOD WC-JUMP-DELAY(L-ROW)
         END-IF
         IF (L-HX NOT = 0 OR L-HZ NOT = 0) AND WC-JUMP-DELAY(L-ROW) = 0
             CALL "RABBIT-HOP-POWER" USING L-MOD WS-ABOVE WS-POWER
             COMPUTE EN-VY(L-ROW) = WS-POWER / 1000
             MOVE 1 TO WC-HOPPING(L-ROW)
             MOVE 0 TO WC-HOP-TICKS(L-ROW)
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         ELSE
             MOVE 0 TO L-HX L-HZ
         END-IF
     END-IF
     IF WC-HOP-TICKS(L-ROW) >= 15
         MOVE 0 TO WC-HOPPING(L-ROW) WC-HOP-TICKS(L-ROW)
     END-IF
     MOVE EN-ON-GROUND(L-ROW) TO WC-WAS-GROUND(L-ROW)
     GOBACK.
 END PROGRAM RABBIT-HOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-EVIL-TICK.
*> The killer bunny (variant 99, EN-WOOL): NearestAttackable(Player) with the default follow range 16 (18 section 2: Mob attributes): a target that is gone, not alive, not in survival or
*> farther than 16 is dropped; without one the nearest alive survival player of the dimension within 16 is taken. The attack timer counts down as for the hostile mobs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHASE.
     MOVE 0 TO L-CHASE
     IF EN-COOLDOWN(L-ROW) > 0
         SUBTRACT 1 FROM EN-COOLDOWN(L-ROW)
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ROW) OR PL-STATE(WS-P) NOT = PS-ALIVE
                 OR PL-MODE(WS-P) NOT = 0 OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW) OR WS-D2 > 256
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
         END-IF
     END-IF
     IF EN-TARGET(L-ROW) = 0
         MOVE 0 TO WS-BEST
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                 IF WS-D2 <= 256 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                     MOVE WS-P TO WS-BEST
                     MOVE WS-D2 TO WS-BEST-D2
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST > 0
             MOVE WS-BEST TO EN-TARGET(L-ROW)
             MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
         END-IF
     END-IF
     IF EN-TARGET(L-ROW) > 0
         MOVE 1 TO L-CHASE
     END-IF
     GOBACK.
 END PROGRAM RABBIT-EVIL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RABBIT-EVIL-SCALE.
*> The walk of STDMOB-HEAD is at the table speed of the stroll (modifier 0.6); MeleeAttack runs at 1.4: the speeds are (0.3 x s) squared / 0.454 (RABBIT-SPEED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STROLL              BINARY-LONG VALUE 600.
 01 WS-ATTACK              BINARY-LONG VALUE 1400.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-HX L-HZ.
     CALL "RABBIT-SPEED" USING WS-ATTACK WS-A
     CALL "RABBIT-SPEED" USING WS-STROLL WS-S
     COMPUTE L-HX = L-HX * WS-A / WS-S
     COMPUTE L-HZ = L-HZ * WS-A / WS-S
     GOBACK.
 END PROGRAM RABBIT-EVIL-SCALE.
