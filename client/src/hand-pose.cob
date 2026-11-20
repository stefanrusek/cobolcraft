*> The view pose and the arm poses of the first-person hand (12 section 6.1, 6.2, 6.6; 53 section 15). HAND-TICK runs one 50 ms client tick of the state the hand
*> keeps (the lagging view angles 15.3, the attack strength ticker 17 section 4.1). HAND-PREFIX builds the pose stack's first frame: the view effects (VIEW-POSE:
*> hurt and death tilt, view bobbing, 12 section 6.1 steps 1 and 2) and hand sway (step 3). HAND-ATTACK-DELAY is the full-charge delay of an item. HAND-ARM
*> applies the arm transform of 12 section 6.3 step 1 or, while an item is used, the pose of its use animation (6.6). Not done: brush and spear poses (open question 6 of 12).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-TICK.
*> USING CLIENT-STATE, held (the main-hand stack as item id + 1, 0 none): one client tick of the hand's own state. The attack strength ticker counts up and
*> restarts when the held stack differs from the last tick's, and the lagging view angles (53 section 15.3) move half way to the real ones. The walk distance and
*> the bob amount of 53 section 15.2 are the player's own (PL-WALK, PL-BOB: SMOOTH-WALK, smooth.cob), the deathTime too (PL-DEATH-TIME).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HELD                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HELD.
     IF L-HELD = CL-ATK-LAST
         ADD 1 TO CL-ATK-TICKER
     ELSE
         MOVE 0 TO CL-ATK-TICKER
         MOVE L-HELD TO CL-ATK-LAST
     END-IF
     IF CL-BOB-INIT = 0
         MOVE PL-PITCH TO CL-XBOB CL-XBOB-O
         MOVE PL-YAW TO CL-YBOB CL-YBOB-O
         MOVE 1 TO CL-BOB-INIT
         GOBACK
     END-IF
     MOVE CL-XBOB TO CL-XBOB-O
     MOVE CL-YBOB TO CL-YBOB-O
     COMPUTE CL-XBOB = CL-XBOB + (PL-PITCH - CL-XBOB) * 0.5
     COMPUTE CL-YBOB = CL-YBOB + (PL-YAW - CL-YBOB) * 0.5
     GOBACK.
 END PROGRAM HAND-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-PREFIX.
*> USING CLIENT-STATE, partial tick, M out (12 FLOAT-LONG, HAND-M-IDENT layout): the first frame of the pose stack: the view effects of 12 section 6.1 steps 1 and 2 (the hurt and
*> death tilt, then view bobbing: VIEW-POSE, view-pose.cob, the one the world view starts from too), then the sway (step 3): rotate X by (pitch - xBob) 0.1 and Y by (yaw - yBob) 0.1
*> degrees, xBob and yBob taken at the partial tick. Before the first tick the lagging angles are unknown and the sway is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LAG                 FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-PARTIAL L-M.
     CALL "VIEW-POSE" USING CLIENT-STATE L-PARTIAL L-M
     IF CL-BOB-INIT = 0
         GOBACK
     END-IF
     COMPUTE WS-LAG = CL-XBOB-O + L-PARTIAL * (CL-XBOB - CL-XBOB-O)
     MOVE 1 TO WS-AXIS
     COMPUTE WS-DEG = (PL-PITCH - WS-LAG) * 0.1
     CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     COMPUTE WS-LAG = CL-YBOB-O + L-PARTIAL * (CL-YBOB - CL-YBOB-O)
     MOVE 2 TO WS-AXIS
     COMPUTE WS-DEG = (PL-YAW - WS-LAG) * 0.1
     CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     GOBACK.
 END PROGRAM HAND-PREFIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-ATTACK-DELAY.
*> USING CLIENT-STATE, held (item id + 1, 0 none), delay out (FLOAT-LONG ticks): the full-charge delay D = 20 / A of 17 section 4.1, A the attack speed of the
*> held item (4 + its modifier; an item with no attack modifier, and the bare hand, 4: D = 5). Haste and Mining Fatigue are not read (the client keeps no effects).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ITEM                BINARY-LONG.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-KEY                 PIC X(48).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-MINING              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-HELD                 BINARY-LONG.
 01 L-DELAY                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-HELD L-DELAY.
     MOVE 5 TO L-DELAY
     IF L-HELD > 0
         COMPUTE WS-ITEM = L-HELD - 1
         CALL "CL-ITEM-INFO" USING CLIENT-STATE WS-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-NS = "minecraft"
             MOVE SPACES TO WS-KEY
             MOVE WS-PATH TO WS-KEY
             CALL "TOOL-ITEM-STATS" USING WS-KEY WS-FOUND WS-DURABILITY WS-DAMAGE WS-SPEED WS-COOLDOWN WS-MINING
             IF WS-FOUND = 1 AND WS-COOLDOWN > 0
                 COMPUTE L-DELAY = WS-COOLDOWN / 10000
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HAND-ATTACK-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-ARM.
*> USING M, side (+1 right arm, -1 left), equip offset E, kind, elapsed use ticks el, use duration d (ticks, FLOAT-LONG): M = M x the arm transform of 12 section 6.3
*> step 1 (translate (s 0.56, -0.52 - 0.6 E, -0.72)), preceded by the eating transform (kind 1) or followed by the pose of the use animation (6.6): kind 0 none,
*> 1 eating or drinking, 2 bow, 3 crossbow charging (d the charge duration), 4 trident, 5 blocking with an item that is not a shield, 6 auto spin attack, 7 a loaded
*> crossbow held in the main hand and not swinging (translate (s -0.641864, 0, 0), rotate Y s 10).
*> The use time of 6.6 is e = el - 1 (e = d - (u - f + 1) with u - f = d - el) and a = d - el + 1; B(h) is the bob of a drawn bow: with h above 0.1,
*> translate (0, sin((e - 0.1) 1.3) (h - 0.1) 0.004, 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SIDE                 BINARY-LONG.
 01 L-E                    FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ELAPSED              FLOAT-LONG.
 01 L-DURATION             FLOAT-LONG.
 PROCEDURE DIVISION USING L-M L-SIDE L-E L-KIND L-ELAPSED L-DURATION.
     COMPUTE WS-E = L-ELAPSED - 1
     IF L-KIND = 1 AND L-DURATION > 0
         COMPUTE WS-A = L-DURATION - L-ELAPSED + 1
         COMPUTE WS-T = WS-A / L-DURATION
         IF WS-T < 0.8
             MOVE 0 TO WS-X WS-Z
             COMPUTE WS-Y = FUNCTION ABS(FUNCTION COS(WS-A / 4 * FUNCTION PI) * 0.1)
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
         END-IF
         COMPUTE WS-K = 1 - WS-T ** 27
         COMPUTE WS-X = L-SIDE * WS-K * 0.6
         COMPUTE WS-Y = WS-K * -0.5
         MOVE 0 TO WS-Z
         CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = L-SIDE * WS-K * 90
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         MOVE 1 TO WS-AXIS
         COMPUTE WS-DEG = WS-K * 10
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = L-SIDE * WS-K * 30
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-IF
     COMPUTE WS-X = L-SIDE * 0.56
     COMPUTE WS-Y = -0.52 + L-E * -0.6
     MOVE -0.72 TO WS-Z
     CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
     EVALUATE L-KIND
         WHEN 2
             COMPUTE WS-X = L-SIDE * -0.2785682
             MOVE 0.18344387 TO WS-Y
             MOVE 0.15731531 TO WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 1 TO WS-AXIS
             MOVE -13.935 TO WS-DEG
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 35.3
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 3 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * -9.785
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             COMPUTE WS-T = WS-E / 20
             COMPUTE WS-H = FUNCTION MIN(1, (WS-T * WS-T + 2 * WS-T) / 3)
         WHEN 3
             COMPUTE WS-X = L-SIDE * -0.4785682
             MOVE -0.094387 TO WS-Y
             MOVE 0.05731531 TO WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 1 TO WS-AXIS
             MOVE -11.935 TO WS-DEG
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 65.3
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 3 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * -9.785
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             COMPUTE WS-H = FUNCTION MIN(1, WS-E / L-DURATION)
         WHEN 4
             COMPUTE WS-X = L-SIDE * -0.5
             MOVE 0.7 TO WS-Y
             MOVE 0.1 TO WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 1 TO WS-AXIS
             MOVE -55 TO WS-DEG
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 35.3
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 3 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * -9.785
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             COMPUTE WS-H = FUNCTION MIN(1, WS-E / 10)
         WHEN 5
             COMPUTE WS-X = L-SIDE * -0.14142136
             MOVE 0.08 TO WS-Y
             MOVE 0.14142136 TO WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 1 TO WS-AXIS
             MOVE -102.25 TO WS-DEG
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 13.365
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 3 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 78.05
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         WHEN 7
             COMPUTE WS-X = L-SIDE * -0.641864
             MOVE 0 TO WS-Y WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 10
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         WHEN 6
             COMPUTE WS-X = L-SIDE * -0.4
             MOVE 0.8 TO WS-Y
             MOVE 0.3 TO WS-Z
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
             MOVE 2 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * 65
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
             MOVE 3 TO WS-AXIS
             COMPUTE WS-DEG = L-SIDE * -85
             CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-EVALUATE
*>   The drawn weapons end alike: B(h), a push of h x 0.04 (a trident 0.2) forward, the stretch along z and the turn back by 45 degrees.
     IF L-KIND >= 2 AND L-KIND <= 4
         IF WS-H > 0.1
             MOVE 0 TO WS-X WS-Z
             COMPUTE WS-Y = FUNCTION SIN((WS-E - 0.1) * 1.3) * (WS-H - 0.1) * 0.004
             CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
         END-IF
         MOVE 0 TO WS-X WS-Y
         COMPUTE WS-Z = WS-H * 0.04
         IF L-KIND = 4
             COMPUTE WS-Z = WS-H * 0.2
         END-IF
         CALL "HAND-M-TRANSLATE" USING L-M WS-X WS-Y WS-Z
         MOVE 1 TO WS-X WS-Y
         COMPUTE WS-Z = 1 + WS-H * 0.2
         CALL "HAND-M-SCALE" USING L-M WS-X WS-Y WS-Z
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = 0 - L-SIDE * 45
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-IF
     GOBACK.
 END PROGRAM HAND-ARM.
