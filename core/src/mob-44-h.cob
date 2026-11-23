*> Sniffer dig cadence (002-lane-mobsa3; docs/protocol/44-residual-mob-questions-4-land-animals.md section 13).
*> M44-SNIF-PICK USING draw (nextInt(8)), behaviour out: the RunOne of the idle activity (weights SetWalkTargetFromLookTarget 2, Scenting 1, Sniffing 1, look at player 1, RandomStroll 1,
*>   DoNothing 2): draw 2 gives 2 (scenting), draw 3 gives 3 (sniffing), anything else 0 (a behaviour the walker or nothing handles).
*> M44-SNIF-CAN-SNIFF USING row, ok out: canSniff (an adult on the ground, not in love, not leashed, not a passenger; the tempted, panicking and in-water tests are not modelled).
*> M44-LIGHT-COST USING dim, x, y, z, cost out (FLOAT-LONG): getPathfindingCostFromLightLevels of the cell (44 part 1 section 4.13: the light curve minus 0.5, ambient light 0).
*> M44-ANIMAL-SCORE USING dim, x, y, z, score out (FLOAT-LONG): Animal.getWalkTargetValue: 10 when the block below is grass_block, else the light cost.
*> M44-LAND-POS USING row, h, v, found out, x, y, z out: LandRandomPos.getPos(mob, h, v) of a mob without a home (44 part 3 section 2.19 B): ten attempts, each drawing nextInt(2h + 1) - h, nextInt(2v + 1) - v and
*>   nextInt(2h + 1) - h (the sniffer's own XP-RANDOM source), the block at the mob's block plus the offset rejected outside the build height or without a stable block below (a solid cell), moved up out of
*>   solid, rejected when it is the water block or its static path type has a malus; the best Animal score wins, the earliest of equals (strictly greater), the result the block (x, y, z).
*> M44-SNIF-CAN-DIG-AT USING row, x, y, z, ok out: canDig(pos) of the block (x, y, z): in sniffer_diggable_block, not among the explored positions, and a path from the sniffer to the cell above it.
*> M44-SNIF-DIG-POS USING row, found out, x, y, z out: calculateDigPosition: LandRandomPos.getPos(mob, 10 + 2 i, 3) for i = 0 to 4; the first candidate inside the world border whose lower neighbour canDig.
*> M44-SNIF-BRAIN USING row, hx, hz out (FLOAT-LONG), walk out: one tick before SNIFFER-TICK (called by STDMOB-STEP). The sniff cooldown EN-SNIF-CD counts down. An idle sniffer (state 0) with no cooldown draws the RunOne
*>   every 5 + nextInt(16) ticks (the DoNothing(5, 20) stand-in for the other behaviours: gap); scenting and sniffing last 40 to 80 ticks (SNIFFER-SET-STATE). A sniffing sniffer whose time is
*>   up that can sniff runs calculateDigPosition: with a dig position it goes to searching (4) with the sniffing target set and walks to it at 1.25 x its speed (walk 1; Searching ends on arrival, after
*>   600 ticks or when it can no longer sniff); a sniffer in searching without a target and one whose search ended, when it can dig where it stands (the block below its head diggable, 54 section 8 tag,
*>   not explored), starts Digging with a duration of 160 + nextInt(21) ticks and Entity Event 63 (SNIFFER-DIG-START; the seed drops 120
*>   ticks in, SNIFFER-TICK), at its end the cooldown is 9600 and the sniffer rises (6) for 40 ticks (FinishedDigging) and then feels happy (1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-PICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-PICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PICK.
     MOVE 0 TO L-PICK
     IF L-DRAW = 2 OR L-DRAW = 3
         MOVE L-DRAW TO L-PICK
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-CAN-SNIFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 0 TO L-OK
     IF EN-MOBAGE(L-ROW) >= 0 AND EN-VARIANT(L-ROW) = 0 AND EN-ON-GROUND(L-ROW) = 1 AND EN-LOVE(L-ROW) = 0
             AND EN-LEASH(L-ROW) = 0 AND EN-LEASH-KNOT(L-ROW) = 0 AND EN-RIDER(L-ROW) = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-CAN-SNIFF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-DIGGABLE-AT.
*> USING row, diggable out: the block below the sniffer's head is in the tag sniffer_diggable_block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIGGABLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIGGABLE.
     MOVE 0 TO L-DIGGABLE
     CALL "SNIFFER-HEAD" USING L-ROW WS-HX WS-HZ WS-BX WS-BY WS-BZ
     CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KEY WS-LENGTH
     IF WS-LENGTH > 10
         MOVE SPACES TO WS-BARE
         MOVE WS-KEY(11:WS-LENGTH - 10) TO WS-BARE
         CALL "M44-SNIFFER-DIGGABLE" USING WS-BARE L-DIGGABLE
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-DIGGABLE-AT.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LIGHT-COST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-LIGHT         BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-AMBIENT             FLOAT-LONG VALUE 0.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COST                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-COST.
     CALL "STDMOB-LIGHTS" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK-LIGHT
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-BLOCK-LIGHT, WS-SKY - WS-DARK, 0)
     CALL "L32-PATH-COST" USING WS-LIGHT WS-AMBIENT L-COST
     GOBACK.
 END PROGRAM M44-LIGHT-COST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-ANIMAL-SCORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SCORE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SCORE.
     COMPUTE WS-BELOW = L-Y - 1
     CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-BELOW L-Z WS-KEY WS-LENGTH
     IF WS-KEY = "minecraft:grass_block"
         MOVE 10 TO L-SCORE
     ELSE
         CALL "M44-LIGHT-COST" USING L-DIM L-X L-Y L-Z L-SCORE
     END-IF
     GOBACK.
 END PROGRAM M44-ANIMAL-SCORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-LAND-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SALT                BINARY-LONG VALUE 94.
 01 WS-SPAN-H              BINARY-LONG.
 01 WS-SPAN-V              BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-SCORE               FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-H L-V L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND L-X L-Y L-Z
     MOVE -1000000 TO WS-BEST
     COMPUTE WS-SPAN-H = 2 * L-H + 1
     COMPUTE WS-SPAN-V = 2 * L-V + 1
     MOVE DM-MIN-Y(EN-DIM(L-ROW)) TO WS-MIN-Y
     COMPUTE WS-MAX-Y = WS-MIN-Y + DM-HEIGHT(EN-DIM(L-ROW)) - 1
     PERFORM 10 TIMES
         CALL "XP-RANDOM" USING WS-SALT WS-SPAN-H WS-DRAW
         COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW)) + WS-DRAW - L-H
         CALL "XP-RANDOM" USING WS-SALT WS-SPAN-V WS-DRAW
         COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW)) + WS-DRAW - L-V
         CALL "XP-RANDOM" USING WS-SALT WS-SPAN-H WS-DRAW
         COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW)) + WS-DRAW - L-H
         MOVE 1 TO WS-OK
*>       isOutsideLimits, then isNotStable (the block below must be solid).
         IF WS-PY < WS-MIN-Y OR WS-PY > WS-MAX-Y
             MOVE 0 TO WS-OK
         END-IF
         IF WS-OK = 1
             COMPUTE WS-BELOW = WS-PY - 1
             CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-PX WS-BELOW WS-PZ WS-CELL
             IF WS-CELL NOT = 1
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
*>       moveUpOutOfSolid: a solid cell moves up to the first cell that is not solid (the build height ends the search).
         IF WS-OK = 1
             CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-CELL
             IF WS-CELL = 1
                 ADD 1 TO WS-PY
                 PERFORM UNTIL WS-PY > WS-MAX-Y
                     CALL "STDMOB-CELL" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-CELL
                     IF WS-CELL NOT = 1
                         EXIT PERFORM
                     END-IF
                     ADD 1 TO WS-PY
                 END-PERFORM
             END-IF
*>           The moved cell is rejected when it holds water or its static path type has a malus.
             CALL "TURTLE-IS-WATER" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-WATER
             CALL "LIVE-STATIC-PATH-TYPE" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-TYPE
             CALL "PATH-MALUS-DEFAULT" USING WS-TYPE WS-MALUS
             IF WS-WATER = 1 OR WS-MALUS NOT = 0
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             CALL "M44-ANIMAL-SCORE" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-SCORE
             IF WS-SCORE > WS-BEST
                 MOVE WS-SCORE TO WS-BEST
                 MOVE 1 TO L-FOUND
                 MOVE WS-PX TO L-X
                 MOVE WS-PY TO L-Y
                 MOVE WS-PZ TO L-Z
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-LAND-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-CAN-DIG-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIGGABLE            BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 2.
 01 WS-BUDGET              BINARY-LONG VALUE 100.
 01 WS-PATH-TABLE.
    05 WS-PATH OCCURS 128 TIMES.
       10 WS-PX            BINARY-LONG.
       10 WS-PY            BINARY-LONG.
       10 WS-PZ            BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK WS-DIGGABLE
     CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-KEY WS-LENGTH
     IF WS-LENGTH > 10
         MOVE SPACES TO WS-BARE
         MOVE WS-KEY(11:WS-LENGTH - 10) TO WS-BARE
         CALL "M44-SNIFFER-DIGGABLE" USING WS-BARE WS-DIGGABLE
     END-IF
     IF WS-DIGGABLE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-SNIF-EXP-N(L-ROW)
         IF EN-SNIF-EXP-X(L-ROW, WS-I) = L-X AND EN-SNIF-EXP-Y(L-ROW, WS-I) = L-Y AND EN-SNIF-EXP-Z(L-ROW, WS-I) = L-Z
             GOBACK
         END-IF
     END-PERFORM
*>   A navigation path from the sniffer's feet cell to the cell above the block (a path that reaches it).
     COMPUTE WS-SX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-SY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-SZ = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-TY = L-Y + 1
     CALL "STDMOB-PATH" USING EN-DIM(L-ROW) WS-SX WS-SY WS-SZ L-X WS-TY L-Z WS-HEIGHT WS-BUDGET
         WS-PATH-TABLE WS-COUNT WS-REACHED
     IF WS-COUNT > 0 AND WS-REACHED = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM M44-SNIF-CAN-DIG-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-DIG-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-V                   BINARY-LONG VALUE 3.
 01 WS-GOT                 BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FOUND L-X L-Y L-Z.
     MOVE 0 TO L-FOUND L-X L-Y L-Z
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4 OR L-FOUND = 1
         COMPUTE WS-H = 10 + 2 * WS-I
         CALL "M44-LAND-POS" USING L-ROW WS-H WS-V WS-GOT WS-PX WS-PY WS-PZ
         IF WS-GOT = 1
             CALL "PORTAL-IN-BORDER" USING EN-DIM(L-ROW) WS-PX WS-PZ WS-INSIDE
             COMPUTE WS-BELOW = WS-PY - 1
             CALL "M44-SNIF-CAN-DIG-AT" USING L-ROW WS-PX WS-BELOW WS-PZ WS-OK
             IF WS-INSIDE = 1 AND WS-OK = 1
                 MOVE 1 TO L-FOUND
                 MOVE WS-PX TO L-X
                 MOVE WS-PY TO L-Y
                 MOVE WS-PZ TO L-Z
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM M44-SNIF-DIG-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-SNIF-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 94.
 01 WS-BOUND8              BINARY-LONG VALUE 8.
 01 WS-BOUND16             BINARY-LONG VALUE 16.
 01 WS-BOUND21             BINARY-LONG VALUE 21.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-DIGGABLE            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HAPPY               BINARY-LONG VALUE 1.
 01 WS-IDLE                BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     IF EN-SNIF-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-SNIF-CD(L-ROW)
     END-IF
     EVALUATE EN-SNIF(L-ROW)
         WHEN 0
             IF EN-SNIF-T(L-ROW) > 0
                 SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             ELSE
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND8 WS-DRAW
                 CALL "M44-SNIF-PICK" USING WS-DRAW WS-PICK
                 CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
                 IF WS-PICK = 3 AND (WS-CAN = 0 OR EN-SNIF-CD(L-ROW) > 0)
                     MOVE 0 TO WS-PICK
                 END-IF
                 IF WS-PICK = 2 AND WS-CAN = 0
                     MOVE 0 TO WS-PICK
                 END-IF
                 IF WS-PICK > 0
                     MOVE WS-PICK TO WS-STATE
                     CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                 ELSE
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND16 WS-DRAW
                     COMPUTE EN-SNIF-T(L-ROW) = 5 + WS-DRAW
                 END-IF
             END-IF
         WHEN 3
*>           The end of sniffing: calculateDigPosition; a position sets the sniffing target and the walk target to it (Searching).
             IF EN-SNIF-T(L-ROW) <= 1
                 CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
                 MOVE 0 TO WS-FOUND
                 IF WS-CAN = 1
                     CALL "M44-SNIF-DIG-POS" USING L-ROW WS-FOUND WS-DX WS-DY WS-DZ
                 END-IF
                 IF WS-FOUND = 1
                     MOVE 4 TO WS-STATE
                     CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                     MOVE 1 TO EN-SNIF-TON(L-ROW)
                     MOVE WS-DX TO EN-SNIF-TX(L-ROW)
                     MOVE WS-DY TO EN-SNIF-TY(L-ROW)
                     MOVE WS-DZ TO EN-SNIF-TZ(L-ROW)
                     MOVE 0 TO EN-SNIF-AGE(L-ROW)
                 END-IF
             END-IF
         WHEN 4
*>           Searching: while the target is set and the sniffer can sniff it walks to it at 1.25 x its speed; it ends on arrival, after 600 ticks or when it can no longer sniff.
             ADD 1 TO EN-SNIF-AGE(L-ROW)
             CALL "M44-SNIF-CAN-SNIFF" USING L-ROW WS-CAN
             IF EN-SNIF-TON(L-ROW) = 1
                 MOVE 0 TO WS-ARRIVED
                 IF WS-CAN = 1 AND EN-SNIF-AGE(L-ROW) <= 600
                     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
                     CALL "STDMOB-HEAD" USING L-ROW WS-M EN-SNIF-TX(L-ROW) EN-SNIF-TY(L-ROW) EN-SNIF-TZ(L-ROW) L-HX L-HZ WS-ARRIVED
                     COMPUTE L-HX = L-HX * 1.25
                     COMPUTE L-HZ = L-HZ * 1.25
                     MOVE 1 TO L-WALK
                 END-IF
                 IF WS-ARRIVED = 1 OR L-WALK = 0
                     MOVE 0 TO EN-SNIF-TON(L-ROW) L-HX L-HZ L-WALK
                 END-IF
             END-IF
             IF EN-SNIF-TON(L-ROW) = 0
                 CALL "M44-SNIF-DIGGABLE-AT" USING L-ROW WS-DIGGABLE
                 CALL "SNIFFER-CAN-DIG" USING L-ROW WS-DIGGABLE WS-OK
                 IF WS-CAN = 1 AND WS-OK = 1
                     CALL "SNIFFER-DIG-START" USING L-ROW
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND21 WS-DRAW
                     COMPUTE EN-SNIF-T(L-ROW) = 160 + WS-DRAW
                 ELSE
                     CALL "SNIFFER-SET-STATE" USING L-ROW WS-IDLE
                 END-IF
             END-IF
         WHEN 5
             SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             IF EN-SNIF-T(L-ROW) <= 0
                 MOVE 6 TO WS-STATE
                 CALL "SNIFFER-SET-STATE" USING L-ROW WS-STATE
                 MOVE 40 TO EN-SNIF-T(L-ROW)
                 MOVE 9600 TO EN-SNIF-CD(L-ROW)
             END-IF
         WHEN 6
             SUBTRACT 1 FROM EN-SNIF-T(L-ROW)
             IF EN-SNIF-T(L-ROW) <= 0
                 CALL "SNIFFER-SET-STATE" USING L-ROW WS-HAPPY
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-SNIF-BRAIN.
