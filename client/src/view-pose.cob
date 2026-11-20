*> The view effects of the camera (lane bugviewbob; 12 section 6.1 steps 1 and 2, 53 section 15.2, 57-1 section 5): the hurt and death tilt and view bobbing, as one matrix
*> that the world view (render-list.cob, in every camera mode, 53 section 15.2) and the first-person hand (hand.cob) both start from. Hand sway (step 3) is not done.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIEW-POSE.
*> USING CLIENT-STATE, partial tick, M out (12 FLOAT-LONG, HAND-M-IDENT layout): the pose stack after the view effects, in the order of 12 section 6.1: the tilt
*> (outermost), then view bobbing. While the player dies (health 0 or less) rotate Z by 40 - 8000 / (min(deathTime + partial, 20) + 200) degrees; the hurt tilt
*> follows whether the player dies or not (57-1 section 5.2): t = the hurt time left over its 500 ms (10 ticks), k = sin(t^4 pi); rotate Y by -dir, Z by
*> -k 14 s, Y by +dir (dir PL-HURT-DIR, s the damageTiltStrength option, 1 by default). View bobbing (the option bobView, true when absent) with
*> w = -(walkDist + (walkDist - walkDistO) x partial) and b = lerp(partial, bobO, bob): translate (sin(w pi) b 0.5, -|cos(w pi) b|, 0), rotate Z by sin(w pi) b 3,
*> rotate X by |cos(w pi - 0.2) b| 5 degrees. At rest M is the identity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAME                PIC X(40) VALUE "bobView".
 01 WS-NAME-TILT           PIC X(40) VALUE "damageTiltStrength".
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-STRENGTH            FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-PARTIAL L-M.
     CALL "HAND-M-IDENT" USING L-M
     IF PL-HEALTH <= 0
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = 40 - 8000 / (FUNCTION MIN(PL-DEATH-TIME + L-PARTIAL, 20) + 200)
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-IF
     IF CL-NOW-MS < PL-HURT-UNTIL
         COMPUTE WS-T = FUNCTION MIN(1, (PL-HURT-UNTIL - CL-NOW-MS) / CL-HURT-MS)
         CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME-TILT WS-VALUE WS-LENGTH WS-FOUND
         MOVE 1 TO WS-STRENGTH
         IF WS-FOUND = 1 AND WS-LENGTH > 0
             COMPUTE WS-STRENGTH = FUNCTION NUMVAL(WS-VALUE(1:WS-LENGTH))
         END-IF
         COMPUTE WS-K = FUNCTION SIN(WS-T ** 4 * FUNCTION PI)
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = 0 - PL-HURT-DIR
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = 0 - WS-K * 14 * WS-STRENGTH
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         MOVE 2 TO WS-AXIS
         MOVE PL-HURT-DIR TO WS-DEG
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-IF
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF NOT (WS-FOUND = 1 AND WS-VALUE(1:5) = "false")
         COMPUTE WS-B = PL-BOB-O + L-PARTIAL * (PL-BOB - PL-BOB-O)
         COMPUTE WS-W = 0 - (PL-WALK + (PL-WALK - PL-WALK-O) * L-PARTIAL)
         COMPUTE WS-AX = FUNCTION SIN(WS-W * FUNCTION PI) * WS-B * 0.5
         COMPUTE WS-AY = 0 - FUNCTION ABS(FUNCTION COS(WS-W * FUNCTION PI) * WS-B)
         MOVE 0 TO WS-AZ
         CALL "HAND-M-TRANSLATE" USING L-M WS-AX WS-AY WS-AZ
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = FUNCTION SIN(WS-W * FUNCTION PI) * WS-B * 3
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
         MOVE 1 TO WS-AXIS
         COMPUTE WS-DEG = FUNCTION ABS(FUNCTION COS(WS-W * FUNCTION PI - 0.2) * WS-B) * 5
         CALL "HAND-M-ROTATE" USING L-M WS-AXIS WS-DEG
     END-IF
     GOBACK.
 END PROGRAM VIEW-POSE.
