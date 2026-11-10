*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 4: the entity base emissions. Conventions of particles-42-7.cob (draws in EM-DRAW,
*> particles and sounds out in the rows of client/copy/CLP6EM.cpy). The entity helpers (getRandomX(s) = x + width (2 r - 1) s, getRandomY() = y + height r) are those of the document's
*> table; the caller fills the entity values in IN.
*> Entry point for the integrator (inputs): P7-BASE site(X(24)) IN(16 floats) P6-EMITS. IN by site:
*>   sprint        x y z, width, vx vz, clamp into the supporting block's column (0/1), block x z, block state, render shape invisible (0/1): 1 block particle (clamp to [block, block + 1]).
*>   splash        x y z, width, V x y z, k (0.2 own, 0.9 passenger): bubbles then splashes, the swim-splash sound splash_quiet below volume 0.25, else splash_high_speed (after the draws).
*>   poof          x y z, width, height: 20 particles.     drown   x y z, vx vy vz: 8 bubbles.
*>   item          x, eye y, z, pitch degrees, yaw degrees, count, stack empty, item id (EM-STATE): spawnItemParticles.
*>   effect_tick   invisible, ambient, list size, x y z, width, height: one test draw nextInt(a b); a hit picks list entry k (EM-STATE = k + 1, 1-based) and the position, velocity (1, 1, 1).
*>   teleport      old x y z, new x y z, width, height: event 46, 128 portal particles.
*>   villager      x y z, width, height, particle (1 heart, 2 angry_villager, 3 happy_villager, 4 splash): 5 particles above the entity.
*>   love          in love ticks before the tick, x y z, width, height: 1 heart when the decremented value is a multiple of 10.
*>   taming        x y z, width, height, success (heart, else smoke): 7 particles.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-BASE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VOL                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-CS                  FLOAT-LONG.
 01 WS-SN                  FLOAT-LONG.
 01 WS-TMP                 FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     EVALUATE L-SITE
         WHEN "sprint"
             PERFORM SPRINT
         WHEN "splash"
             PERFORM SPLASH
         WHEN "poof"
             PERFORM POOF
         WHEN "drown"
             PERFORM DROWN
         WHEN "item"
             PERFORM ITEM
         WHEN "effect_tick"
             PERFORM EFFECT-TICK
         WHEN "teleport"
             PERFORM TELEPORT
         WHEN "villager"
             PERFORM VILLAGER
         WHEN "love"
             PERFORM LOVE
         WHEN "taming"
             PERFORM TAMING
     END-EVALUATE
     GO TO PROGRAM-DONE.

 SPRINT.
     IF L-I(11) = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-X = L-I(1) + (WS-R - 0.5) * L-I(4)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-Z = L-I(3) + (WS-R - 0.5) * L-I(4)
         IF L-I(7) NOT = 0
             IF WS-X < L-I(8)
                 MOVE L-I(8) TO WS-X
             END-IF
             IF WS-X > L-I(8) + 1
                 COMPUTE WS-X = L-I(8) + 1
             END-IF
             IF WS-Z < L-I(9)
                 MOVE L-I(9) TO WS-Z
             END-IF
             IF WS-Z > L-I(9) + 1
                 COMPUTE WS-Z = L-I(9) + 1
             END-IF
         END-IF
         MOVE "block" TO WS-N
         MOVE WS-X TO WS-V(1)
         COMPUTE WS-V(2) = L-I(2) + 0.1
         MOVE WS-Z TO WS-V(3)
         COMPUTE WS-V(4) = -4 * L-I(5)
         MOVE 1.5 TO WS-V(5)
         COMPUTE WS-V(6) = -4 * L-I(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE EM-STATE(EM-COUNT) = L-I(10)
     END-IF.

 SPLASH.
     CALL "P6-DRAW" USING P6-EMITS WS-R
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-VOL = FUNCTION SQRT(0.2 * L-I(5) * L-I(5) + L-I(6) * L-I(6) + 0.2 * L-I(7) * L-I(7)) * L-I(8)
     IF WS-VOL > 1
         MOVE 1 TO WS-VOL
     END-IF
     COMPUTE WS-T = 1 + L-I(4) * 20
     COMPUTE WS-CNT = FUNCTION INTEGER-PART(WS-T)
     IF WS-CNT < WS-T
         ADD 1 TO WS-CNT
     END-IF
     MOVE "bubble" TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-I(1) + (2 * WS-R - 1) * L-I(4)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-I(3) + (2 * WS-R - 1) * L-I(4)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(2) = FUNCTION INTEGER(L-I(2)) + 1
         MOVE L-I(5) TO WS-V(4)
         COMPUTE WS-V(5) = L-I(6) - 0.2 * WS-R
         MOVE L-I(7) TO WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     MOVE "splash" TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(1) = L-I(1) + (2 * WS-R - 1) * L-I(4)
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-V(3) = L-I(3) + (2 * WS-R - 1) * L-I(4)
         COMPUTE WS-V(2) = FUNCTION INTEGER(L-I(2)) + 1
         MOVE L-I(5) TO WS-V(4)
         MOVE L-I(6) TO WS-V(5)
         MOVE L-I(7) TO WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM
     ADD 1 TO EM-SOUND-COUNT
     MOVE "splash_high_speed" TO EM-SOUND(EM-SOUND-COUNT)
     IF WS-VOL < 0.25
         MOVE "splash_quiet" TO EM-SOUND(EM-SOUND-COUNT)
     END-IF.

 POOF.
     MOVE "poof" TO WS-N
     PERFORM 20 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-VX
         CALL "P6-DRAW" USING P6-EMITS WS-VY
         CALL "P6-DRAW" USING P6-EMITS WS-VZ
         COMPUTE WS-VX = WS-VX * 0.02
         COMPUTE WS-VY = WS-VY * 0.02
         COMPUTE WS-VZ = WS-VZ * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1) - 10 * WS-VX
         COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B - 10 * WS-VY
         COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1) - 10 * WS-VZ
         MOVE WS-VX TO WS-V(4)
         MOVE WS-VY TO WS-V(5)
         MOVE WS-VZ TO WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 DROWN.
     MOVE "bubble" TO WS-N
     PERFORM 8 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(1) = L-I(1) + (WS-A - WS-B)
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(2) = L-I(2) + (WS-A - WS-B)
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         COMPUTE WS-V(3) = L-I(3) + (WS-A - WS-B)
         MOVE L-I(4) TO WS-V(4)
         MOVE L-I(5) TO WS-V(5)
         MOVE L-I(6) TO WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 ITEM.
     IF L-I(7) = 0
         MOVE "item" TO WS-N
         COMPUTE WS-CNT = L-I(6)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
             CALL "P6-DRAW" USING P6-EMITS WS-A
             COMPUTE WS-VX = (WS-A - 0.5) * 0.1
             CALL "P6-DRAW" USING P6-EMITS WS-A
             COMPUTE WS-VY = WS-A * 0.1 + 0.1
             MOVE 0 TO WS-VZ
             PERFORM ROTATE-V
             CALL "P6-DRAW" USING P6-EMITS WS-A
             COMPUTE WS-PY = -WS-A * 0.6 - 0.3
             CALL "P6-DRAW" USING P6-EMITS WS-A
             COMPUTE WS-PX = (WS-A - 0.5) * 0.3
             MOVE 0.6 TO WS-PZ
             PERFORM ROTATE-P
             COMPUTE WS-V(1) = L-I(1) + WS-PX
             COMPUTE WS-V(2) = L-I(2) + WS-PY
             COMPUTE WS-V(3) = L-I(3) + WS-PZ
             MOVE WS-VX TO WS-V(4)
             COMPUTE WS-V(5) = WS-VY + 0.05
             MOVE WS-VZ TO WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             COMPUTE EM-STATE(EM-COUNT) = L-I(8)
         END-PERFORM
     END-IF.

 ROTATE-V.
     COMPUTE WS-ANG = -L-I(4) * 0.017453292
     COMPUTE WS-CS = FUNCTION COS(WS-ANG)
     COMPUTE WS-SN = FUNCTION SIN(WS-ANG)
     COMPUTE WS-TMP = WS-VY * WS-CS + WS-VZ * WS-SN
     COMPUTE WS-VZ = WS-VZ * WS-CS - WS-VY * WS-SN
     MOVE WS-TMP TO WS-VY
     COMPUTE WS-ANG = -L-I(5) * 0.017453292
     COMPUTE WS-CS = FUNCTION COS(WS-ANG)
     COMPUTE WS-SN = FUNCTION SIN(WS-ANG)
     COMPUTE WS-TMP = WS-VX * WS-CS + WS-VZ * WS-SN
     COMPUTE WS-VZ = WS-VZ * WS-CS - WS-VX * WS-SN
     MOVE WS-TMP TO WS-VX.

 ROTATE-P.
     COMPUTE WS-ANG = -L-I(4) * 0.017453292
     COMPUTE WS-CS = FUNCTION COS(WS-ANG)
     COMPUTE WS-SN = FUNCTION SIN(WS-ANG)
     COMPUTE WS-TMP = WS-PY * WS-CS + WS-PZ * WS-SN
     COMPUTE WS-PZ = WS-PZ * WS-CS - WS-PY * WS-SN
     MOVE WS-TMP TO WS-PY
     COMPUTE WS-ANG = -L-I(5) * 0.017453292
     COMPUTE WS-CS = FUNCTION COS(WS-ANG)
     COMPUTE WS-SN = FUNCTION SIN(WS-ANG)
     COMPUTE WS-TMP = WS-PX * WS-CS + WS-PZ * WS-SN
     COMPUTE WS-PZ = WS-PZ * WS-CS - WS-PX * WS-SN
     MOVE WS-TMP TO WS-PX.

 EFFECT-TICK.
     COMPUTE WS-CNT = 4
     IF L-I(1) NOT = 0
         MOVE 15 TO WS-CNT
     END-IF
     IF L-I(2) NOT = 0
         COMPUTE WS-CNT = WS-CNT * 5
     END-IF
     CALL "P6-DRAW" USING P6-EMITS WS-R
     COMPUTE WS-I = FUNCTION INTEGER-PART(WS-R * WS-CNT)
     IF WS-I = 0
         CALL "P6-DRAW" USING P6-EMITS WS-R
         COMPUTE WS-I = FUNCTION INTEGER-PART(WS-R * L-I(3))
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(1) = L-I(4) + L-I(7) * (2 * WS-A - 1) * 0.5
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(2) = L-I(5) + L-I(8) * WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(3) = L-I(6) + L-I(7) * (2 * WS-A - 1) * 0.5
         MOVE 1 TO WS-V(4) WS-V(5) WS-V(6)
         MOVE "effect" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE EM-STATE(EM-COUNT) = WS-I + 1
     END-IF.

 TELEPORT.
     MOVE "portal" TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 127
         COMPUTE WS-T = WS-I / 127
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(4) = (WS-A - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(5) = (WS-A - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(6) = (WS-A - 0.5) * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(1) = L-I(1) + (L-I(4) - L-I(1)) * WS-T + (WS-A - 0.5) * L-I(7) * 2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(2) = L-I(2) + (L-I(5) - L-I(2)) * WS-T + WS-A * L-I(8)
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(3) = L-I(3) + (L-I(6) - L-I(3)) * WS-T + (WS-A - 0.5) * L-I(7) * 2
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 VILLAGER.
     MOVE "heart" TO WS-N
     EVALUATE L-I(6)
         WHEN 2 MOVE "angry_villager" TO WS-N
         WHEN 3 MOVE "happy_villager" TO WS-N
         WHEN 4 MOVE "splash" TO WS-N
     END-EVALUATE
     MOVE 5 TO WS-CNT
     MOVE 1 TO WS-T
     PERFORM AROUND-SELF.

 LOVE.
     COMPUTE WS-I = L-I(1) - 1
     IF L-I(1) > 0 AND WS-I = 10 * FUNCTION INTEGER-PART(WS-I / 10)
         MOVE "heart" TO WS-N
         MOVE 1 TO WS-CNT
         MOVE 0.5 TO WS-T
         PERFORM AROUND-SELF-AT
     END-IF.

 TAMING.
     MOVE "smoke" TO WS-N
     IF L-I(6) NOT = 0
         MOVE "heart" TO WS-N
     END-IF
     MOVE 7 TO WS-CNT
     MOVE 0.5 TO WS-T
     PERFORM AROUND-SELF.

*> villager and taming rows: the entity is at IN(1..5); the love row keeps it at IN(2..6).
 AROUND-SELF.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
         PERFORM DRAW-VELOCITY
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1)
         COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B + WS-T
         COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 AROUND-SELF-AT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
         PERFORM DRAW-VELOCITY
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(2) + L-I(5) * (2 * WS-A - 1)
         COMPUTE WS-V(2) = L-I(3) + L-I(6) * WS-B + WS-T
         COMPUTE WS-V(3) = L-I(4) + L-I(5) * (2 * WS-C - 1)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 DRAW-VELOCITY.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     COMPUTE WS-V(4) = WS-A * 0.02
     CALL "P6-DRAW" USING P6-EMITS WS-A
     COMPUTE WS-V(5) = WS-A * 0.02
     CALL "P6-DRAW" USING P6-EMITS WS-A
     COMPUTE WS-V(6) = WS-A * 0.02.

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM P7-BASE.
