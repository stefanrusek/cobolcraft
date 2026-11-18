*> Slime (002-lane-mobsfull-h5; docs/protocol/20 section 10 and 20.2). The size is EN-VARIANT (metadata 18, STDMOB-VARIANT-BUILD).
*>
*> Entry points:
*>   STDMOB-SLIME-SIZE USING xoro state, special multiplier (thousandths), size out     the natural size 1, 2 or 4
*>   STDMOB-SLIME-STATS USING size, health, speed milli, attack, xp out                  health size x size, speed 0.2 + 0.1 size, attack and xp size
*>   STDMOB-SLIME-INIT USING xoro state, tracker row, special                            size, variant and health of a new slime
*>   STDMOB-SLIME-MOON USING world time, chance out (thousandths)                        the surface spawn chance of the moon phase
*>   STDMOB-SLIME-SPLIT USING tracker row                                                2 to 4 children of half the size
*>   STDMOB-SLIME-DIE USING tracker row, killer player row                               drops (size 1), experience (size), the split
*>   STDMOB-ATTACK-DAMAGE USING tracker row, table row, damage out                       the melee damage of a hit (a size 1 slime deals none)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-SIZE.
*> t = nextInt(3); when t < 2 and nextDouble < 0.5 x special, t + 1; size = 2 to the power t (10, setSpawnSize).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-T                   BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SPECIAL              BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SPECIAL L-SIZE.
     CALL "XORO-NEXT-INT" USING L-STATE WS-THREE WS-T
     IF WS-T < 2
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         COMPUTE WS-P = 0.5 * L-SPECIAL / 1000
         IF WS-D < WS-P
             ADD 1 TO WS-T
         END-IF
     END-IF
     COMPUTE L-SIZE = 2 ** WS-T
     GOBACK.
 END PROGRAM STDMOB-SLIME-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-STATS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-HEALTH               BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-ATTACK               BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-HEALTH L-SPEED L-ATTACK L-XP.
     COMPUTE L-HEALTH = L-SIZE * L-SIZE
     COMPUTE L-SPEED = 200 + 100 * L-SIZE
     MOVE L-SIZE TO L-ATTACK L-XP
     GOBACK.
 END PROGRAM STDMOB-SLIME-STATS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-INIT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SIZE                BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-ATTACK              BINARY-LONG.
 01 WS-XP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SPECIAL.
     CALL "STDMOB-SLIME-SIZE" USING L-STATE L-SPECIAL WS-SIZE
     MOVE WS-SIZE TO EN-VARIANT(L-ROW)
     CALL "STDMOB-SLIME-STATS" USING WS-SIZE EN-HEALTH(L-ROW) WS-SPEED WS-ATTACK WS-XP
     GOBACK.
 END PROGRAM STDMOB-SLIME-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-MOON.
*> The moon timeline (10, spawn rule): 0.5 for the first 24000 ticks of the 192000 tick cycle, then 0.375, 0.25, 0.125, 0, 0.125, 0.25, 0.375.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DAY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-CHANCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-CHANCE.
     COMPUTE WS-DAY = FUNCTION MOD(L-TIME, 192000) / 24000
     EVALUATE WS-DAY
         WHEN 0 MOVE 500 TO L-CHANCE
         WHEN 1 MOVE 375 TO L-CHANCE
         WHEN 2 MOVE 250 TO L-CHANCE
         WHEN 3 MOVE 125 TO L-CHANCE
         WHEN 4 MOVE 0 TO L-CHANCE
         WHEN 5 MOVE 125 TO L-CHANCE
         WHEN 6 MOVE 250 TO L-CHANCE
         WHEN OTHER MOVE 375 TO L-CHANCE
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-SLIME-MOON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SULFUR-CUBE-INIT.
*> USING tracker row: a new sulfur cube has size 2 and health size x size = 4 (18.2 setSpawnSize: size 1 for a baby, 2 otherwise; there is no baby spawn here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 2 TO EN-VARIANT(L-ROW)
     MOVE 4 TO EN-HEALTH(L-ROW)
     GOBACK.
 END PROGRAM SULFUR-CUBE-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-SPLIT.
*> A sulfur cube (18.2) splits in exactly 2 (getSplitCount 2) and its width is 0.49 per size.
*> A dying slime of size above 1: count 2 + nextInt(3); child i (size / 2, full health) stands at x + ((i mod 2) - 0.5) w, z + ((i div 2) - 0.5) w with
*> w = half the parent width (0.52 x size / 2), y + 0.5, a random yaw (10, split on death). The draws are the hash of the entity id and the time.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ODD                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-VARIANT(L-ROW) TO WS-SIZE
     IF WS-SIZE <= 1
         GOBACK
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     MOVE 0 TO WS-CUBE
     IF SM-KEY(WS-M) = "sulfur_cube"
         MOVE 1 TO WS-CUBE
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 31 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-N = 2 + FUNCTION MOD(WS-R, 3)
     COMPUTE WS-W = 0.26 * WS-SIZE
     IF WS-CUBE = 1
         MOVE 2 TO WS-N
         COMPUTE WS-W = 0.245 * WS-SIZE
     END-IF
     COMPUTE WS-CHILD = WS-SIZE / 2
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-ODD = FUNCTION MOD(WS-I, 2)
         COMPUTE WS-HALF = WS-I / 2
         COMPUTE WS-X = EN-X(L-ROW) + (WS-ODD - 0.5) * WS-W
         COMPUTE WS-Z = EN-Z(L-ROW) + (WS-HALF - 0.5) * WS-W
         COMPUTE WS-Y = EN-Y(L-ROW) + 0.5
         COMPUTE WS-YAW = FUNCTION MOD(WS-R / 7 + WS-I * 97, 360)
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
         MOVE WS-CHILD TO EN-VARIANT(WS-ROW)
         COMPUTE EN-HEALTH(WS-ROW) = WS-CHILD * WS-CHILD
         CALL "STDMOB-VARIANT-SEND" USING WS-ROW
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-SLIME-SPLIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-DIE.
*> USING tracker row of a slime whose health reached 0, killer player row: only size 1 drops its loot (10); a player's kill gives size experience; a
*> larger slime splits (STDMOB-SLIME-SPLIT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-DIM                 BINARY-LONG.
 01 WS-NO-WOOL             BINARY-LONG VALUE -1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-LOOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KILLER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KILLER.
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 0 TO WS-LOOT
     IF SM-KEY(WS-M) = "slime" AND EN-VARIANT(L-ROW) <= 1
         MOVE 1 TO WS-LOOT
     END-IF
     IF SM-KEY(WS-M) = "magma_cube" AND EN-VARIANT(L-ROW) >= 2
         MOVE 1 TO WS-LOOT
     END-IF
     IF WS-LOOT = 1
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE L-KILLER WS-NO-WOOL
     END-IF
     IF L-KILLER > 0
         COMPUTE WS-POINTS = FUNCTION MAX(EN-VARIANT(L-ROW), 1)
         CALL "XP-AWARD" USING WS-DIM WS-X WS-Y WS-Z WS-POINTS
     END-IF
     CALL "STDMOB-SLIME-SPLIT" USING L-ROW
     GOBACK.
 END PROGRAM STDMOB-SLIME-DIE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-ATTACK-DAMAGE.
*> USING tracker row, table row, damage out: SM-ATTACK, except a slime: its size, and 0 at size 1 (it cannot deal damage, 10), plus the size of a phantom (6 + size, 12), plus 3 with Strength (EN-FX-STRENGTH, 7.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-HASH-COUNT          BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-DAMAGE.
     MOVE SM-ATTACK(L-M) TO L-DAMAGE
     IF SM-KEY(L-M) = "sulfur_cube"
         MOVE 0 TO L-DAMAGE
     END-IF
     IF SM-KEY(L-M) = "slime"
         MOVE 0 TO L-DAMAGE
         IF EN-VARIANT(L-ROW) > 1
             MOVE EN-VARIANT(L-ROW) TO L-DAMAGE
         END-IF
     END-IF
*>   A hoglin or zoglin adult hits for A / 2 + nextInt(A) (21 section 5.6; A = 6: 3 to 8), the draw from the hash of the entity id and the time.
     IF SM-KEY(L-M) = "hoglin" OR SM-KEY(L-M) = "zoglin"
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 47 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-HASH-COUNT WS-ARGS WS-R
         COMPUTE L-DAMAGE = SM-ATTACK(L-M) / 2 + FUNCTION MOD(WS-R, SM-ATTACK(L-M))
     END-IF
*>   A magma cube hits for its size + 2 at every size (21 section 5.3: getAttackDamage + 2; it can always deal damage).
     IF SM-KEY(L-M) = "magma_cube"
         COMPUTE L-DAMAGE = FUNCTION MAX(EN-VARIANT(L-ROW), 1) + 2
     END-IF
     IF SM-KEY(L-M) = "phantom"
         ADD EN-VARIANT(L-ROW) TO L-DAMAGE
     END-IF
     IF EN-FX-STRENGTH(L-ROW) NOT = 0
         ADD 3 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-ATTACK-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SLIME-RULE.
*> USING xoro state, dim, x, y, z (BINARY-LONG feet cell), reason (0 natural, 1 chunk generation, 2 spawner, 3 trial), ok out: checkSlimeSpawnRules (10).
*> Peaceful fails; the standable-block test is the full block below (3.4) and alone decides a spawner reason. Otherwise the surface alternative: a swamp or
*> mangrove swamp biome, 50 < y < 70, nextDouble below the moon chance (STDMOB-SLIME-MOON), the raw brightness at most nextInt(8). The slime-chunk
*> alternative needs the slime-chunk seed, which docs/protocol does not give (open item), so it is not tried.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY MOBSPAWN.
 01 WS-BELOW               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-CHANCE              BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SLIME               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-X L-Y L-Z L-REASON L-OK.
     MOVE 0 TO L-OK
     IF BW-DIFFICULTY = 0
         GOBACK
     END-IF
     COMPUTE WS-BELOW = L-Y - 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-BELOW L-Z WS-KIND
     IF L-REASON = 2 OR L-REASON = 3
         IF WS-KIND = 1
             MOVE 1 TO L-OK
         END-IF
         GOBACK
     END-IF
     CALL "MS6-BIOME-AT" USING L-DIM L-X L-Y L-Z WS-BIOME
     IF (SPB-NAME(WS-BIOME) = "swamp" OR SPB-NAME(WS-BIOME) = "mangrove_swamp") AND L-Y > 50 AND L-Y < 70
         MOVE CW-TIME TO WS-TIME
         CALL "STDMOB-SLIME-MOON" USING WS-TIME WS-CHANCE
         CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
         CALL "STDMOB-LIGHTS" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK
         CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
         CALL "MS6-LOCAL-LIGHT" USING WS-SKY WS-BLOCK WS-DARKEN WS-ZERO WS-LOCAL
         CALL "XORO-NEXT-INT" USING L-STATE WS-EIGHT WS-LEVEL
         IF WS-D * 1000 < WS-CHANCE AND WS-LOCAL <= WS-LEVEL AND WS-KIND = 1
             MOVE 1 TO L-OK
         END-IF
     END-IF
*>   (b) the slime-chunk alternative (20 section 10, 54 section 8.1): the chunk test on the world seed, a fresh nextInt(10) = 0, y below 40 and a floor.
     IF L-OK = 0
         COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
         COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
         CALL "M44-SLIME-CHUNK" USING WS-CX WS-CZ CW-SEED WS-SLIME
         IF WS-SLIME = 1
             CALL "XORO-NEXT-INT" USING L-STATE WS-TEN WS-LEVEL
             IF WS-LEVEL = 0 AND L-Y < 40 AND WS-KIND = 1
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SLIME-RULE.
