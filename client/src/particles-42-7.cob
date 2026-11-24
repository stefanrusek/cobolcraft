*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), sections 1 and 2: the server routing of particles
*> (ServerLevel.sendParticles) and the `/particle` command. Draws are passed in the EM-DRAW table of client/copy/CLP6EM.cpy (the conventions of
*> particles-42-6-b.cob); packets come out in client/copy/CLP7PK.cpy. A packet is expanded on the client by P6-HANDLE-PACKET (particles-42-6-i.cob).
*>
*> Entry points for the integrator (inputs):
*>   P7-RADIUS override-limiter radius(out): 512 when the first flag is true, else 32 (1.2).
*>   P7-PLAYER-SEES in-level player-block(3 integers) point(3 floats) override-limiter sees(out): the per-player test of 1.2 (same level, and the distance
*>     from the block centre to the point below the radius).
*>   P7-SITE site(PIC X(24)) IN(16 floats) P6-EMITS P7-PACKETS: the emission sites of 1.4, the packets the site sends (PS-COUNT = 0 for an unknown
*>     site). IN by site (a letter list of the entries, in order; h height, w width):
*>       player_fall (ServerPlayer.checkFallDamage)  fall distance, block x y z, state
*>       bubble_column  block x y z (draws: splash x z, bubble x z, twice)
*>       forced_age  x y z w h (draws x y z);  age_locked  x y z w h locked (draws x y z)
*>       damage_indicator  health lost, x y z h;  sweep  x y z h yaw;  armor_stand  x y z w h state (armor stand and cushion)
*>       creaking_tear_down  centre x y z, box size x y z, wood state, heart state;  squid_ink  x y z, direction x y z, glow (30 packets)
*>       mushroom_cow_stew, mushroom_cow_effect, mushroom_cow_shear  x y z h;  bucket_evaporate  x y z;  water_bottle  block x y z (draws x z)
*>       jukebox  block x y z (draw nextInt(4));  egg_eat  block x y z (draws x y z);  egg_poof  x y z (20 packets, three draws each)
*>       wolf_armor, shulker_hit, shulker_shot  x y z;  sonic_boom  chest x y z, unit direction x y z, distance to the target
*>     `LivingEntity.checkFallDamage` is P6-LANDING (particles-42-6-h.cob); the sculk catalyst is P6-CATALYST-PACKET; the rows that say "see" another
*>     section are in that section.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-RADIUS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-OVERRIDE L-RADIUS.
     MOVE 32 TO L-RADIUS
     IF L-OVERRIDE NOT = 0
         MOVE 512 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM P7-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-PLAYER-SEES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-INLEVEL              BINARY-LONG.
 01 L-BLOCK.
    05 L-B                 BINARY-LONG OCCURS 3 TIMES.
 01 L-POINT.
    05 L-PT                FLOAT-LONG OCCURS 3 TIMES.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-SEES                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INLEVEL L-BLOCK L-POINT L-OVERRIDE L-SEES.
     MOVE 0 TO L-SEES
     IF L-INLEVEL NOT = 0
         CALL "P7-RADIUS" USING L-OVERRIDE WS-RADIUS
         COMPUTE WS-DX = L-PT(1) - (L-B(1) + 0.5)
         COMPUTE WS-DY = L-PT(2) - (L-B(2) + 0.5)
         COMPUTE WS-DZ = L-PT(3) - (L-B(3) + 0.5)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF WS-D2 < WS-RADIUS * WS-RADIUS
             MOVE 1 TO L-SEES
         END-IF
     END-IF
     GOBACK.
 END PROGRAM P7-PLAYER-SEES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-ADD.
*> Append a packet: USING packets, name (PIC X(40)), nine floats (x y z, dx dy dz, sx sy sz), count, randomisation mode, state.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLP7PK.
 01 L-NAME                 PIC X(40).
 01 L-K.
    05 L-V                 FLOAT-LONG OCCURS 9 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING P7-PACKETS L-NAME L-K L-COUNT L-MODE L-STATE.
     ADD 1 TO PS-COUNT
     MOVE L-NAME TO PS-NAME(PS-COUNT)
     MOVE 0 TO PS-FORCE(PS-COUNT) PS-ALWAYS(PS-COUNT)
     MOVE L-V(1) TO PS-X(PS-COUNT)
     MOVE L-V(2) TO PS-Y(PS-COUNT)
     MOVE L-V(3) TO PS-Z(PS-COUNT)
     MOVE L-V(4) TO PS-DX(PS-COUNT)
     MOVE L-V(5) TO PS-DY(PS-COUNT)
     MOVE L-V(6) TO PS-DZ(PS-COUNT)
     MOVE L-V(7) TO PS-SX(PS-COUNT)
     MOVE L-V(8) TO PS-SY(PS-COUNT)
     MOVE L-V(9) TO PS-SZ(PS-COUNT)
     MOVE L-COUNT TO PS-COUNT-OF(PS-COUNT)
     MOVE L-MODE TO PS-MODE(PS-COUNT)
     MOVE L-STATE TO PS-STATE(PS-COUNT)
     GOBACK.
 END PROGRAM P7-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-SITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   PIC X(40).
 01 WS-R                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-F15                 FLOAT-LONG VALUE 0.15000000596046448.
 01 WS-K.
    05 WS-V                FLOAT-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-SITE                 PIC X(24).
 01 L-IN.
    05 L-IV                FLOAT-LONG OCCURS 16 TIMES.
 COPY CLP6EM.
 COPY CLP7PK.
 PROCEDURE DIVISION USING L-SITE L-IN P6-EMITS P7-PACKETS.
     MOVE 0 TO PS-COUNT
     MOVE 0 TO WS-MODE WS-STATE
     INITIALIZE WS-K
     EVALUATE L-SITE
         WHEN "player_fall"
             MOVE "block" TO WS-N
             COMPUTE WS-COUNT = FUNCTION INTEGER-PART(50 * L-IV(1))
             IF WS-COUNT > 200
                 MOVE 200 TO WS-COUNT
             END-IF
             IF WS-COUNT < 0
                 MOVE 0 TO WS-COUNT
             END-IF
             COMPUTE WS-V(1) = L-IV(2) + 0.5
             COMPUTE WS-V(2) = L-IV(3) + 0.5 + 0.5
             COMPUTE WS-V(3) = L-IV(4) + 0.5
             MOVE 0.3 TO WS-V(4) WS-V(5) WS-V(6)
             MOVE WS-F15 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE L-IV(5) TO WS-STATE
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "bubble_column"
             PERFORM 2 TIMES
                 MOVE "splash" TO WS-N
                 INITIALIZE WS-K
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-IV(1) + WS-R
                 COMPUTE WS-V(2) = L-IV(2) + 1
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-IV(3) + WS-R
                 MOVE 1 TO WS-V(7) WS-V(8) WS-V(9)
                 MOVE 1 TO WS-COUNT
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
                 MOVE "bubble" TO WS-N
                 INITIALIZE WS-K
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(1) = L-IV(1) + WS-R
                 COMPUTE WS-V(2) = L-IV(2) + 1
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(3) = L-IV(3) + WS-R
                 MOVE 0.01 TO WS-V(5)
                 MOVE 0.2 TO WS-V(7) WS-V(8) WS-V(9)
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             END-PERFORM
         WHEN "forced_age"
             MOVE "happy_villager" TO WS-N
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-IV(1) + L-IV(4) * (2 * WS-R - 1)
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-IV(2) + L-IV(5) * WS-R + 0.5
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-IV(3) + L-IV(4) * (2 * WS-R - 1)
             MOVE 1 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "age_locked"
             MOVE "reset_mob_growth" TO WS-N
             MOVE 0 TO WS-S
             IF L-IV(6) NOT = 0
                 MOVE "pause_mob_growth" TO WS-N
                 MOVE 0.2 TO WS-S
             END-IF
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-IV(1) + L-IV(4) * (2 * WS-R - 1)
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(2) = L-IV(2) + L-IV(5) * ((2 * WS-R - 1) * 0.2) + L-IV(5) + WS-S
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-IV(3) + L-IV(4) * (2 * WS-R - 1)
             MOVE 1 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "damage_indicator"
             IF L-IV(1) > 2
                 MOVE "damage_indicator" TO WS-N
                 COMPUTE WS-COUNT = FUNCTION INTEGER-PART(L-IV(1) * 0.5)
                 MOVE L-IV(2) TO WS-V(1)
                 COMPUTE WS-V(2) = L-IV(3) + L-IV(5) * 0.5
                 MOVE L-IV(4) TO WS-V(3)
                 MOVE 0.1 TO WS-V(4) WS-V(6)
                 MOVE 0.2 TO WS-V(7) WS-V(8) WS-V(9)
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             END-IF
         WHEN "sweep"
             MOVE "sweep_attack" TO WS-N
             COMPUTE WS-V(1) = L-IV(1) - FUNCTION SIN(L-IV(5))
             COMPUTE WS-V(2) = L-IV(2) + L-IV(4) * 0.5
             COMPUTE WS-V(3) = L-IV(3) + FUNCTION COS(L-IV(5))
             COMPUTE WS-V(4) = 0 - FUNCTION SIN(L-IV(5))
             COMPUTE WS-V(6) = FUNCTION COS(L-IV(5))
             MOVE 0 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "armor_stand"
             MOVE "block" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + L-IV(5) * 2 / 3
             MOVE L-IV(3) TO WS-V(3)
             COMPUTE WS-V(4) = L-IV(4) / 4
             COMPUTE WS-V(5) = L-IV(5) / 4
             COMPUTE WS-V(6) = L-IV(4) / 4
             MOVE 0.05 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE 10 TO WS-COUNT
             MOVE L-IV(6) TO WS-STATE
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "creaking_tear_down"
             MOVE "block_crumble" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             MOVE L-IV(2) TO WS-V(2)
             MOVE L-IV(3) TO WS-V(3)
             COMPUTE WS-V(4) = 0.3 * L-IV(4)
             COMPUTE WS-V(5) = 0.3 * L-IV(5)
             COMPUTE WS-V(6) = 0.3 * L-IV(6)
             MOVE 100 TO WS-COUNT
             MOVE L-IV(7) TO WS-STATE
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             MOVE 10 TO WS-COUNT
             MOVE L-IV(8) TO WS-STATE
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "squid_ink"
             MOVE "squid_ink" TO WS-N
             IF L-IV(7) NOT = 0
                 MOVE "glow_squid_ink" TO WS-N
             END-IF
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + 0.5
             MOVE L-IV(3) TO WS-V(3)
             MOVE L-IV(4) TO WS-V(4)
             MOVE L-IV(5) TO WS-V(5)
             MOVE L-IV(6) TO WS-V(6)
             MOVE 0.1 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE 0 TO WS-COUNT
             PERFORM 30 TIMES
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             END-PERFORM
         WHEN "mushroom_cow_stew"
             MOVE "smoke" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + L-IV(4) * 0.5
             MOVE L-IV(3) TO WS-V(3)
             MOVE 0.5 TO WS-V(4) WS-V(6)
             MOVE 0.2 TO WS-V(8)
             MOVE 2 TO WS-MODE
             MOVE 2 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "mushroom_cow_effect"
             MOVE "effect" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + L-IV(4) * 0.5
             MOVE L-IV(3) TO WS-V(3)
             MOVE 0.5 TO WS-V(4) WS-V(6)
             MOVE 0.2 TO WS-V(8)
             MOVE 2 TO WS-MODE
             MOVE 4 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "mushroom_cow_shear"
             MOVE "explosion" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + L-IV(4) * 0.5
             MOVE L-IV(3) TO WS-V(3)
             MOVE 1 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "bucket_evaporate"
             MOVE "large_smoke" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             MOVE L-IV(2) TO WS-V(2)
             MOVE L-IV(3) TO WS-V(3)
             MOVE 1 TO WS-V(4) WS-V(5) WS-V(6)
             MOVE 8 TO WS-COUNT
             MOVE 1 TO WS-MODE
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "water_bottle"
             MOVE "splash" TO WS-N
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(1) = L-IV(1) + WS-R
             COMPUTE WS-V(2) = L-IV(2) + 1
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-V(3) = L-IV(3) + WS-R
             MOVE 1 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE 5 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "jukebox"
             MOVE "note" TO WS-N
             CALL "P6-DRAW" USING P6-EMITS WS-R
             COMPUTE WS-A = FUNCTION INTEGER-PART(WS-R * 4)
             COMPUTE WS-V(1) = L-IV(1) + 0.5
             COMPUTE WS-V(2) = L-IV(2) + 1.2
             COMPUTE WS-V(3) = L-IV(3) + 0.5
             COMPUTE WS-V(4) = WS-A / 24
             MOVE 1 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE 0 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "egg_eat"
             MOVE "item" TO WS-N
             COMPUTE WS-V(1) = L-IV(1) + 0.5
             COMPUTE WS-V(2) = L-IV(2) + 0.7
             COMPUTE WS-V(3) = L-IV(3) + 0.5
             PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
                 CALL "P6-DRAW" USING P6-EMITS WS-R
                 COMPUTE WS-V(WS-A) = (WS-R - 0.5) * 0.08
             END-PERFORM
             MOVE WS-F15 TO WS-V(7) WS-V(8) WS-V(9)
             MOVE 3 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "egg_poof"
             MOVE "poof" TO WS-N
             MOVE 1 TO WS-COUNT
             PERFORM 20 TIMES
                 INITIALIZE WS-K
                 COMPUTE WS-V(1) = L-IV(1) + 0.5
                 MOVE L-IV(2) TO WS-V(2)
                 COMPUTE WS-V(3) = L-IV(3) + 0.5
                 PERFORM VARYING WS-A FROM 4 BY 1 UNTIL WS-A > 6
                     CALL "P6-DRAW" USING P6-EMITS WS-R
                     COMPUTE WS-V(WS-A) = WS-R * 0.02
                 END-PERFORM
                 MOVE WS-F15 TO WS-V(7) WS-V(8) WS-V(9)
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             END-PERFORM
         WHEN "wolf_armor"
             MOVE "item" TO WS-N
             MOVE L-IV(1) TO WS-V(1)
             COMPUTE WS-V(2) = L-IV(2) + 1
             MOVE L-IV(3) TO WS-V(3)
             MOVE 0.2 TO WS-V(4) WS-V(6)
             MOVE 0.1 TO WS-V(5) WS-V(7) WS-V(8) WS-V(9)
             MOVE 20 TO WS-COUNT
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "shulker_hit"
             MOVE "explosion" TO WS-N
             MOVE 2 TO WS-COUNT
             MOVE L-IV(1) TO WS-V(1)
             MOVE L-IV(2) TO WS-V(2)
             MOVE L-IV(3) TO WS-V(3)
             MOVE 0.2 TO WS-V(4) WS-V(5) WS-V(6)
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "shulker_shot"
             MOVE "crit" TO WS-N
             MOVE 15 TO WS-COUNT
             MOVE L-IV(1) TO WS-V(1)
             MOVE L-IV(2) TO WS-V(2)
             MOVE L-IV(3) TO WS-V(3)
             MOVE 0.2 TO WS-V(4) WS-V(5) WS-V(6)
             CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
         WHEN "sonic_boom"
             MOVE "sonic_boom" TO WS-N
             MOVE 1 TO WS-COUNT
             COMPUTE WS-A = FUNCTION INTEGER(L-IV(7)) + 6
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-A
                 INITIALIZE WS-K
                 COMPUTE WS-V(1) = L-IV(1) + WS-I * L-IV(4)
                 COMPUTE WS-V(2) = L-IV(2) + WS-I * L-IV(5)
                 COMPUTE WS-V(3) = L-IV(3) + WS-I * L-IV(6)
                 CALL "P7-ADD" USING P7-PACKETS WS-N WS-K WS-COUNT WS-MODE WS-STATE
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-SITE.
