*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 6: the per-entity emissions that have a closed formula (partial: rows 6.2, 6.4, 6.5, 6.8,
*> 6.13 (EM3-SPELL-PARTICLES), 6.15 (P7-BASE villager), 6.18 to 6.20, 6.23, 6.26 to 6.31, 6.35 (a), 6.36 to 6.39, 6.42 (P7-BASE poof), 6.45, 6.50 to 6.52 are not here). Conventions of
*> particles-42-7.cob (draws in EM-DRAW, particles and sounds out in the rows of client/copy/CLP6EM.cpy).
*> Entry point for the integrator (inputs): P7-MOB site(X(24)) IN(16 floats) P6-EMITS. IN by site:
*>   arrow IN(in ground, in ground time, colour (-1 none), x y z, width, height) 6.1;   arrow_trail IN(in water, crit, x y z, vx vy vz) 6.1b and 6.3;   egg IN(x y z, item not empty) 6.6;
*>   enderpearl IN(x y z) 6.7;   firework IN(x y z, vy) 6.9;   shulker_bullet IN(x y z, vx vy vz) 6.10;   llama_spit IN(x y z, vx vy vz) 6.11;   fangs_crit IN(x y z, width) 6.12;
*>   witch IN(x y z, box max y) 6.14;   dolphin IN(x y z, view x y z, yaw radians) 6.16;   squid_flee IN(flee ticks, x y z) 6.21;   glow_squid IN(x y z, width, height) 6.22;
*>   ender IN(x y z, width, height, enderman) 6.24;   blaze IN(x y z, width, height) 6.25;   minecart_furnace IN(x y z) 6.32;   tnt IN(x y z) 6.33;
*>   slime_land IN(x y z, width, kind 0 none 1 item_slime 2 flame 3 sulfur_cube_goo) 6.34 (the squish sound plays);   eating IN(x y z, width, height) 6.40;
*>   ominous_spawner IN(game time, x y z) 6.43;   wolf_shake IN(shake, x y z, width, delta movement x y z) 6.44;   spawner IN(near player and display entity, x y z) 6.46;
*>   allay_hearts IN(x y z, width, height) 6.47;   bee IN(x y z, height... see the row: IN(1 has nectar flag, x y z, width, height) 6.48;   boat_bubble IN(x y z) 6.49;   ravager_roar IN(box centre x y z) 6.35 (b).
*>   For arrow the EM-COLOR of the rows is the colour; for the bee IN is (flag, x y z, height).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-MOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-PV.
    05 WS-V                FLOAT-LONG OCCURS 6 TIMES.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-BOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS.
     EVALUATE L-SITE
         WHEN "arrow" PERFORM ARROW
         WHEN "arrow_trail" PERFORM ARROW-TRAIL
         WHEN "egg" PERFORM EGG
         WHEN "enderpearl" PERFORM ENDERPEARL
         WHEN "firework" PERFORM FIREWORK
         WHEN "shulker_bullet" PERFORM SHULKER-BULLET
         WHEN "llama_spit" PERFORM LLAMA-SPIT
         WHEN "fangs_crit" PERFORM FANGS-CRIT
         WHEN "witch" PERFORM WITCH
         WHEN "dolphin" PERFORM DOLPHIN
         WHEN "squid_flee" PERFORM SQUID-FLEE
         WHEN "glow_squid" PERFORM GLOW-SQUID
         WHEN "ender" PERFORM ENDER
         WHEN "blaze" PERFORM BLAZE
         WHEN "minecart_furnace" PERFORM MINECART-FURNACE
         WHEN "tnt" PERFORM TNT
         WHEN "slime_land" PERFORM SLIME-LAND
         WHEN "eating" PERFORM EATING
         WHEN "ominous_spawner" PERFORM OMINOUS-SPAWNER
         WHEN "wolf_shake" PERFORM WOLF-SHAKE
         WHEN "spawner" PERFORM SPAWNER
         WHEN "allay_hearts" PERFORM ALLAY-HEARTS
         WHEN "bee" PERFORM BEE
         WHEN "boat_bubble" PERFORM BOAT-BUBBLE
         WHEN "ravager_roar" PERFORM RAVAGER-ROAR
     END-EVALUATE
     GO TO PROGRAM-DONE.

 ARROW.
     COMPUTE WS-CNT = 2
     IF L-I(1) NOT = 0
         COMPUTE WS-CNT = 0
         IF L-I(2) = 5 * FUNCTION INTEGER-PART(L-I(2) / 5)
             COMPUTE WS-CNT = 1
         END-IF
     END-IF
     IF L-I(3) = -1
         COMPUTE WS-CNT = 0
     END-IF
     MOVE "entity_effect" TO WS-N
     PERFORM WS-CNT TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(4) + L-I(7) * (2 * WS-A - 1) * 0.5
         COMPUTE WS-V(2) = L-I(5) + L-I(8) * WS-B
         COMPUTE WS-V(3) = L-I(6) + L-I(7) * (2 * WS-C - 1) * 0.5
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE EM-COLOR(EM-COUNT) = L-I(3)
     END-PERFORM.

 ARROW-TRAIL.
     IF L-I(1) NOT = 0
         MOVE "bubble" TO WS-N
         PERFORM 4 TIMES
             COMPUTE WS-V(1) = L-I(3) - L-I(6) * 0.25
             COMPUTE WS-V(2) = L-I(4) - L-I(7) * 0.25
             COMPUTE WS-V(3) = L-I(5) - L-I(8) * 0.25
             MOVE L-I(6) TO WS-V(4)
             MOVE L-I(7) TO WS-V(5)
             MOVE L-I(8) TO WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF
     IF L-I(2) NOT = 0
         MOVE "crit" TO WS-N
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
             COMPUTE WS-V(1) = L-I(3) + L-I(6) * WS-I / 4
             COMPUTE WS-V(2) = L-I(4) + L-I(7) * WS-I / 4
             COMPUTE WS-V(3) = L-I(5) + L-I(8) * WS-I / 4
             COMPUTE WS-V(4) = -L-I(6)
             COMPUTE WS-V(5) = -L-I(7) + 0.2
             COMPUTE WS-V(6) = -L-I(8)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.

 EGG.
     IF L-I(4) NOT = 0
         MOVE "item" TO WS-N
         PERFORM 8 TIMES
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             CALL "P6-DRAW" USING P6-EMITS WS-C
             MOVE L-I(1) TO WS-V(1)
             MOVE L-I(2) TO WS-V(2)
             MOVE L-I(3) TO WS-V(3)
             COMPUTE WS-V(4) = (WS-A - 0.5) * 0.08
             COMPUTE WS-V(5) = (WS-B - 0.5) * 0.08
             COMPUTE WS-V(6) = (WS-C - 0.5) * 0.08
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.

 ENDERPEARL.
     MOVE "portal" TO WS-N
     PERFORM 32 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         MOVE L-I(1) TO WS-V(1)
         COMPUTE WS-V(2) = L-I(2) + 2 * WS-A
         MOVE L-I(3) TO WS-V(3)
         MOVE WS-B TO WS-V(4)
         MOVE 0 TO WS-V(5)
         MOVE WS-C TO WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 FIREWORK.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     CALL "P6-DRAW" USING P6-EMITS WS-B
     MOVE "firework" TO WS-N
     MOVE L-I(1) TO WS-V(1)
     MOVE L-I(2) TO WS-V(2)
     MOVE L-I(3) TO WS-V(3)
     COMPUTE WS-V(4) = WS-A * 0.05
     COMPUTE WS-V(5) = -L-I(4) * 0.5
     COMPUTE WS-V(6) = WS-B * 0.05
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 SHULKER-BULLET.
     MOVE "end_rod" TO WS-N
     COMPUTE WS-V(1) = L-I(1) - L-I(4)
     COMPUTE WS-V(2) = L-I(2) - L-I(5) + 0.15
     COMPUTE WS-V(3) = L-I(3) - L-I(6)
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 LLAMA-SPIT.
     MOVE "spit" TO WS-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 6
         MOVE L-I(1) TO WS-V(1)
         MOVE L-I(2) TO WS-V(2)
         MOVE L-I(3) TO WS-V(3)
         COMPUTE WS-V(4) = L-I(4) * (0.4 + 0.1 * WS-I)
         MOVE L-I(5) TO WS-V(5)
         COMPUTE WS-V(6) = L-I(6) * (0.4 + 0.1 * WS-I)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 FANGS-CRIT.
     MOVE "crit" TO WS-N
     PERFORM 12 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         CALL "P6-DRAW" USING P6-EMITS WS-D
         CALL "P6-DRAW" USING P6-EMITS WS-E
         CALL "P6-DRAW" USING P6-EMITS WS-F
         COMPUTE WS-V(1) = L-I(1) + (2 * WS-A - 1) * L-I(4) * 0.5
         COMPUTE WS-V(2) = L-I(2) + 0.05 + WS-B + 1
         COMPUTE WS-V(3) = L-I(3) + (2 * WS-C - 1) * L-I(4) * 0.5
         COMPUTE WS-V(4) = (2 * WS-D - 1) * 0.3
         COMPUTE WS-V(5) = 0.3 + WS-E * 0.3
         COMPUTE WS-V(6) = (2 * WS-F - 1) * 0.3
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 WITCH.
     MOVE "witch" TO WS-N
     MOVE 0 TO WS-I
     CALL "P6-DRAW" USING P6-EMITS WS-A
     COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-A * 35) + 10
     PERFORM UNTIL WS-I >= WS-BOUND
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + WS-A * 0.13
         COMPUTE WS-V(2) = L-I(4) + 0.5 + WS-B * 0.13
         COMPUTE WS-V(3) = L-I(3) + WS-C * 0.13
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         ADD 1 TO WS-I
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-A * 35) + 10
     END-PERFORM.

 DOLPHIN.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     COMPUTE WS-S = 1.2 - 0.7 * WS-A
     MOVE "dolphin" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 2 TIMES
         COMPUTE WS-V(1) = L-I(1) - L-I(4) * WS-S + 0.3 * FUNCTION COS(L-I(7))
         COMPUTE WS-V(2) = L-I(2) - L-I(5) * WS-S
         COMPUTE WS-V(3) = L-I(3) - L-I(6) * WS-S + 0.3 * FUNCTION SIN(L-I(7))
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         COMPUTE WS-V(1) = L-I(1) - L-I(4) * WS-S - 0.3 * FUNCTION COS(L-I(7))
         COMPUTE WS-V(3) = L-I(3) - L-I(6) * WS-S - 0.3 * FUNCTION SIN(L-I(7))
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 SQUID-FLEE.
     IF L-I(1) = 10 * FUNCTION INTEGER-PART(L-I(1) / 10) + 5
         MOVE "bubble" TO WS-N
         MOVE L-I(2) TO WS-V(1)
         MOVE L-I(3) TO WS-V(2)
         MOVE L-I(4) TO WS-V(3)
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 GLOW-SQUID.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     CALL "P6-DRAW" USING P6-EMITS WS-B
     CALL "P6-DRAW" USING P6-EMITS WS-C
     MOVE "glow" TO WS-N
     COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1) * 0.6
     COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B
     COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1) * 0.6
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 ENDER.
     MOVE "portal" TO WS-N
     PERFORM 2 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         CALL "P6-DRAW" USING P6-EMITS WS-D
         CALL "P6-DRAW" USING P6-EMITS WS-E
         CALL "P6-DRAW" USING P6-EMITS WS-F
         COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1) * 0.5
         COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B
         IF L-I(6) NOT = 0
             COMPUTE WS-V(2) = WS-V(2) - 0.25
         END-IF
         COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1) * 0.5
         COMPUTE WS-V(4) = (WS-D - 0.5) * 2
         COMPUTE WS-V(5) = -WS-E
         COMPUTE WS-V(6) = (WS-F - 0.5) * 2
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 BLAZE.
     MOVE "large_smoke" TO WS-N
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     PERFORM 2 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1) * 0.5
         COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B
         COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1) * 0.5
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 MINECART-FURNACE.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF FUNCTION INTEGER-PART(WS-A * 4) = 0
         MOVE "large_smoke" TO WS-N
         MOVE L-I(1) TO WS-V(1)
         COMPUTE WS-V(2) = L-I(2) + 0.8
         MOVE L-I(3) TO WS-V(3)
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 TNT.
     MOVE "smoke" TO WS-N
     MOVE L-I(1) TO WS-V(1)
     COMPUTE WS-V(2) = L-I(2) + 0.5
     MOVE L-I(3) TO WS-V(3)
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 SLIME-LAND.
     COMPUTE WS-S = L-I(4) * 2
     MOVE SPACES TO WS-N
     EVALUATE L-I(5)
         WHEN 1 MOVE "item_slime" TO WS-N
         WHEN 2 MOVE "flame" TO WS-N
         WHEN 3 MOVE "sulfur_cube_goo" TO WS-N
     END-EVALUATE
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-I >= WS-S * 16
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         IF WS-N NOT = SPACES
             COMPUTE WS-C = WS-A * 6.2831855
             COMPUTE WS-D = WS-B * 0.5 + 0.5
             COMPUTE WS-V(1) = L-I(1) + FUNCTION SIN(WS-C) * (WS-S / 2) * WS-D
             MOVE L-I(2) TO WS-V(2)
             COMPUTE WS-V(3) = L-I(3) + FUNCTION COS(WS-C) * (WS-S / 2) * WS-D
             MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-IF
         ADD 1 TO WS-I
     END-PERFORM
     CALL "P6-DRAW" USING P6-EMITS WS-A
     CALL "P6-DRAW" USING P6-EMITS WS-A
     ADD 1 TO EM-SOUND-COUNT
     MOVE "squish" TO EM-SOUND(EM-SOUND-COUNT).

 EATING.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     CALL "P6-DRAW" USING P6-EMITS WS-B
     CALL "P6-DRAW" USING P6-EMITS WS-C
     MOVE "happy_villager" TO WS-N
     COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1)
     COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B + 0.5
     COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1)
     MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
     CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV.

 OMINOUS-SPAWNER.
     IF L-I(1) = 5 * FUNCTION INTEGER-PART(L-I(1) / 5)
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-CNT = 1 + FUNCTION INTEGER-PART(WS-A * 3)
         MOVE "ominous_spawning" TO WS-N
         PERFORM WS-CNT TIMES
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             COMPUTE WS-V(4) = 0.4 * (WS-A - WS-B)
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             COMPUTE WS-V(5) = 0.4 * (WS-A - WS-B)
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             COMPUTE WS-V(6) = 0.4 * (WS-A - WS-B)
             MOVE L-I(2) TO WS-V(1)
             MOVE L-I(3) TO WS-V(2)
             MOVE L-I(4) TO WS-V(3)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.

 WOLF-SHAKE.
     IF L-I(1) > 0.4
         COMPUTE WS-CNT = FUNCTION INTEGER-PART(FUNCTION SIN((L-I(1) - 0.4) * 3.1415927) * 7)
         MOVE "splash" TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CNT
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             COMPUTE WS-V(1) = L-I(2) + (2 * WS-A - 1) * L-I(5) * 0.5
             COMPUTE WS-V(2) = L-I(3) + 0.8
             COMPUTE WS-V(3) = L-I(4) + (2 * WS-B - 1) * L-I(5) * 0.5
             MOVE L-I(6) TO WS-V(4)
             MOVE L-I(7) TO WS-V(5)
             MOVE L-I(8) TO WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         END-PERFORM
     END-IF.

 SPAWNER.
     IF L-I(1) NOT = 0
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(2) + WS-A
         COMPUTE WS-V(2) = L-I(3) + WS-B
         COMPUTE WS-V(3) = L-I(4) + WS-C
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         MOVE "smoke" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         MOVE "flame" TO WS-N
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-IF.

 ALLAY-HEARTS.
     MOVE "heart" TO WS-N
     PERFORM 3 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(4) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(5) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(6) = WS-A * 0.02
         CALL "P6-DRAW" USING P6-EMITS WS-A
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         COMPUTE WS-V(1) = L-I(1) + L-I(4) * (2 * WS-A - 1)
         COMPUTE WS-V(2) = L-I(2) + L-I(5) * WS-B + 0.5
         COMPUTE WS-V(3) = L-I(3) + L-I(4) * (2 * WS-C - 1)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 BEE.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF L-I(1) NOT = 0 AND WS-A < 0.05
         MOVE "falling_nectar" TO WS-N
         MOVE 0 TO WS-I
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-A * 2) + 1
         PERFORM UNTIL WS-I >= WS-BOUND
             CALL "P6-DRAW" USING P6-EMITS WS-A
             CALL "P6-DRAW" USING P6-EMITS WS-B
             COMPUTE WS-V(1) = (L-I(2) - 0.3) + WS-A * 0.6
             COMPUTE WS-V(2) = L-I(3) + L-I(5) * 0.5
             COMPUTE WS-V(3) = (L-I(4) - 0.3) + WS-B * 0.6
             MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
             CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
             ADD 1 TO WS-I
             CALL "P6-DRAW" USING P6-EMITS WS-A
             COMPUTE WS-BOUND = FUNCTION INTEGER-PART(WS-A * 2) + 1
         END-PERFORM
     END-IF.

 BOAT-BUBBLE.
     CALL "P6-DRAW" USING P6-EMITS WS-A
     IF FUNCTION INTEGER-PART(WS-A * 100) = 0
         CALL "P6-DRAW" USING P6-EMITS WS-B
         CALL "P6-DRAW" USING P6-EMITS WS-C
         CALL "P6-DRAW" USING P6-EMITS WS-D
         MOVE "splash" TO WS-N
         COMPUTE WS-V(1) = L-I(1) + WS-C
         COMPUTE WS-V(2) = L-I(2) + 0.7
         COMPUTE WS-V(3) = L-I(3) + WS-D
         MOVE 0 TO WS-V(4) WS-V(5) WS-V(6)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
         ADD 1 TO EM-SOUND-COUNT
         MOVE "swim_splash" TO EM-SOUND(EM-SOUND-COUNT)
     END-IF.

 RAVAGER-ROAR.
     MOVE "poof" TO WS-N
     PERFORM 40 TIMES
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(4) = WS-A * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(5) = WS-A * 0.2
         CALL "P6-DRAW" USING P6-EMITS WS-A
         COMPUTE WS-V(6) = WS-A * 0.2
         MOVE L-I(1) TO WS-V(1)
         MOVE L-I(2) TO WS-V(2)
         MOVE L-I(3) TO WS-V(3)
         CALL "P6-EMIT" USING P6-EMITS WS-N WS-PV
     END-PERFORM.

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM P7-MOB.
