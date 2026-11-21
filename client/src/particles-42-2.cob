*> Particles part 2 (docs/protocol/42-particles-2-effects-fire-smoke-magic.md): section 0 resolved rules,
*> section 1 the provider and class index, section 2 the shared formulas. Random draws are passed in by
*> the caller as a table, in the document's draw order (nextFloat/nextDouble in [0, 1); nextInt(n) is
*> the integer part of draw * n), so every constructor is deterministic and testable.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-WORLD-RULE.
*> Section 0: USING world type (0 or 1), same out = 1: the world type changes which blocks, items and mobs
*> emit particles, not what a particle does once it exists (design README R2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WORLD                BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WORLD L-SAME.
     MOVE 1 TO L-SAME
     GOBACK.
 END PROGRAM P2-WORLD-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-MULTI-OWNER.
*> Section 0: USING type name, flag out (1 when another document also specifies the type), the other
*> document out ("42-3", "42-4", "42-5"). Nine types: lava, both campfire smokes, elder guardian, dolphin,
*> nautilus, glow, pause and reset mob growth, egg crack.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 01 L-OTHER                PIC X(24).
 PROCEDURE DIVISION USING L-TYPE L-FLAG L-OTHER.
     MOVE 1 TO L-FLAG
     EVALUATE L-TYPE
         WHEN "lava"
         WHEN "dolphin"
         WHEN "nautilus"
         WHEN "glow"
             MOVE "42-3" TO L-OTHER
         WHEN "campfire_cosy_smoke"
         WHEN "campfire_signal_smoke"
         WHEN "egg_crack"
             MOVE "42-4" TO L-OTHER
         WHEN "elder_guardian"
         WHEN "pause_mob_growth"
         WHEN "reset_mob_growth"
             MOVE "42-5" TO L-OTHER
         WHEN OTHER
             MOVE 0 TO L-FLAG
             MOVE SPACES TO L-OTHER
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-MULTI-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-MULTI-COUNT.
*> Section 0: USING count out: the number of types specified by more than one document (9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 9 TO L-COUNT
     GOBACK.
 END PROGRAM P2-MULTI-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-INDEX-COUNT.
*> Section 1 V1: USING count out: 41 listed types and 9 siblings, 50 rows.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 50 TO L-COUNT
     GOBACK.
 END PROGRAM P2-INDEX-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-INDEX-ROW.
*> Section 1: USING row number (1 to 50, the order of the table), P2IX out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP2TAB.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY CLP2IX.
 PROCEDURE DIVISION USING L-ROW P2IX.
     INITIALIZE P2IX
     IF L-ROW >= 1 AND L-ROW <= 50
         MOVE 1 TO P2-FOUND
         MOVE R-ID(L-ROW) TO P2-ID
         MOVE R-OVR(L-ROW) TO P2-OVR
         MOVE R-SPR(L-ROW) TO P2-SPR
         MOVE R-PICK(L-ROW) TO P2-PICK
         MOVE R-LAYER(L-ROW) TO P2-LAYER
         MOVE R-PHYS(L-ROW) TO P2-PHYS
         MOVE R-PROVIDER(L-ROW) TO P2-PROVIDER
         MOVE R-CLASS(L-ROW) TO P2-CLASS
         MOVE R-SECTION(L-ROW) TO P2-SECTION
     END-IF
     GOBACK.
 END PROGRAM P2-INDEX-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-INDEX.
*> Section 1: USING type name, P2IX out (P2-FOUND 0 for an unknown type).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP2TAB.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 COPY CLP2IX.
 PROCEDURE DIVISION USING L-TYPE P2IX.
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50 OR WS-HIT NOT = 0
         IF R-NAME(WS-I) = L-TYPE
             MOVE WS-I TO WS-HIT
         END-IF
     END-PERFORM
     IF WS-HIT = 0
         INITIALIZE P2IX
     ELSE
         CALL "P2-INDEX-ROW" USING WS-HIT P2IX
     END-IF
     GOBACK.
 END PROGRAM P2-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-IS-SIBLING.
*> Section 1: USING type name, flag out: 1 for the nine sibling types that share the classes of the listed
*> ones (infested, nautilus, dolphin, egg crack, glow, wax on, wax off, electric spark, scrape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(24).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-FLAG.
     MOVE 0 TO L-FLAG
     EVALUATE L-TYPE
         WHEN "infested"
         WHEN "nautilus"
         WHEN "dolphin"
         WHEN "egg_crack"
         WHEN "glow"
         WHEN "wax_on"
         WHEN "wax_off"
         WHEN "electric_spark"
         WHEN "scrape"
             MOVE 1 TO L-FLAG
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-IS-SIBLING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-PROVIDER-CLASSES.
*> Section 1 V2: USING distinct count out, shared out: the number of distinct provider classes among the 41
*> listed registrations (the nine siblings excluded), and 100 * the registrations of FlameParticle$Provider
*> + the registrations of SpellParticle$InstantProvider.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP2TAB.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SIBS.
    05 WS-SIB              BINARY-LONG OCCURS 50 TIMES.
 01 WS-DUP                 BINARY-LONG.
 01 WS-FLAME               BINARY-LONG.
 01 WS-INSTANT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-SHARED               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-SHARED.
     MOVE 0 TO L-COUNT WS-FLAME WS-INSTANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         CALL "P2-IS-SIBLING" USING R-NAME(WS-I) WS-SIB(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         IF WS-SIB(WS-I) = 0
             IF R-PROVIDER(WS-I) = "FlameParticle$Provider"
                 ADD 1 TO WS-FLAME
             END-IF
             IF R-PROVIDER(WS-I) = "SpellParticle$InstantProvider"
                 ADD 1 TO WS-INSTANT
             END-IF
             MOVE 0 TO WS-DUP
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
                 IF WS-SIB(WS-J) = 0 AND R-PROVIDER(WS-J) = R-PROVIDER(WS-I)
                     MOVE 1 TO WS-DUP
                 END-IF
             END-PERFORM
             IF WS-DUP = 0
                 ADD 1 TO L-COUNT
             END-IF
         END-IF
     END-PERFORM
     COMPUTE L-SHARED = WS-FLAME * 100 + WS-INSTANT
     GOBACK.
 END PROGRAM P2-PROVIDER-CLASSES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LIGHT-LEVELS.
*> Section 2.1: USING block level, sky level (0 to 15), smooth light out: block channel 16 * level in bits
*> 0 to 7, sky channel in bits 16 to 23 (equal to the packed form for whole levels).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-SKY L-LIGHT.
     COMPUTE L-LIGHT = L-BLOCK * 16 + L-SKY * 16 * 65536
     GOBACK.
 END PROGRAM P2-LIGHT-LEVELS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LIGHT-EMIT.
*> Section 2.1 E(L, f): USING light (smooth form), f (COMP: clamped to [0, 1]), light out: the block channel
*> rises by floor(f * 240), capped at 240; the sky channel is unchanged.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-F                    FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-F L-OUT.
     COMPUTE WS-F = FUNCTION MAX(0, FUNCTION MIN(1, L-F))
     COMPUTE WS-BLOCK = FUNCTION MOD(L-LIGHT, 65536)
     COMPUTE WS-ADD = FUNCTION INTEGER-PART(WS-F * 240)
     COMPUTE WS-BLOCK = FUNCTION MIN(240, WS-BLOCK + WS-ADD)
     COMPUTE L-OUT = L-LIGHT - FUNCTION MOD(L-LIGHT, 65536) + WS-BLOCK
     GOBACK.
 END PROGRAM P2-LIGHT-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-LIGHT-WITH-BLOCK.
*> Section 2.1 withBlock(L, 15): USING light, light out: the sky channel kept, the block channel 240.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-OUT.
     COMPUTE L-OUT = L-LIGHT - FUNCTION MOD(L-LIGHT, 65536) + 240
     GOBACK.
 END PROGRAM P2-LIGHT-WITH-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SIN-INDEX.
*> Section 2.2: USING x, index out = (long)(x * 10430.378350470453) masked with 65535.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-INDEX.
     COMPUTE L-INDEX = FUNCTION MOD(FUNCTION INTEGER-PART(L-X * 10430.378350470453), 65536)
     GOBACK.
 END PROGRAM P2-SIN-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-MTH-COS.
*> Section 2.2 Mth.cos: USING x, result out (f32 widened): the table entry at the sine index plus 16384.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-DOUBLE.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-COS                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-COS.
     COMPUTE WS-INDEX = FUNCTION MOD(FUNCTION INTEGER-PART(L-X * 10430.378350470453) + 16384, 65536)
     COMPUTE WS-F32 = FUNCTION SIN(WS-INDEX / 10430.378350470453)
     MOVE WS-F32 TO L-COS
     GOBACK.
 END PROGRAM P2-MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-OPT-COLOR.
*> Section 2.3: USING ARGB integer, red, green, blue, alpha out: each byte / 255.0 (the spell option's alpha
*> byte is simply unused by its caller).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ARGB                 BINARY-DOUBLE.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ARGB L-R L-G L-B L-A.
     COMPUTE L-A = FUNCTION MOD(FUNCTION INTEGER-PART(L-ARGB / 16777216), 256) / 255
     COMPUTE L-R = FUNCTION MOD(FUNCTION INTEGER-PART(L-ARGB / 65536), 256) / 255
     COMPUTE L-G = FUNCTION MOD(FUNCTION INTEGER-PART(L-ARGB / 256), 256) / 255
     COMPUTE L-B = FUNCTION MOD(L-ARGB, 256) / 255
     GOBACK.
 END PROGRAM P2-OPT-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-SPRITE-SELECT.
*> Section 2.5: USING pick (0 first, 1 age, 2 rnd), sprite count, age, lifetime, draw, index out. Age:
*> age * (n - 1) / lifetime (integer); rnd: nextInt(n) from the draw; first: 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PICK                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-PICK L-N L-AGE L-LIFETIME L-DRAW L-INDEX.
     MOVE 0 TO L-INDEX
     EVALUATE L-PICK
         WHEN 1
             CALL "PCL-SPRITE-INDEX" USING L-AGE L-LIFETIME L-N L-INDEX
         WHEN 2
             CALL "PSET-RANDOM" USING L-N L-DRAW L-INDEX
     END-EVALUATE
     GOBACK.
 END PROGRAM P2-SPRITE-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-COLLISION-CONSTANTS.
*> Section 2.6: USING maximum squared speed out (10000), freeze threshold out (the float 1e-5 widened).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-MAXSQ                FLOAT-LONG.
 01 L-FREEZE               FLOAT-LONG.
 PROCEDURE DIVISION USING L-MAXSQ L-FREEZE.
     MOVE 10000 TO L-MAXSQ
     MOVE 0.00001 TO WS-F32
     MOVE WS-F32 TO L-FREEZE
     GOBACK.
 END PROGRAM P2-COLLISION-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-COLLISION-APPLIES.
*> Section 2.6: USING hasPhysics, dx, dy, dz, flag out: 1 when collision is attempted (hasPhysics, a delta
*> that is not all zeros, squared speed below 10000).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHYS                 BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PHYS L-DX L-DY L-DZ L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-PHYS NOT = 0 AND (L-DX NOT = 0 OR L-DY NOT = 0 OR L-DZ NOT = 0)
             AND L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ < 10000
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM P2-COLLISION-APPLIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P2-FREEZE-ON-GROUND.
*> Section 2.6: USING requested dy, resolved dy, stopped out, onGround out: stoppedByCollision when the
*> requested |dy| is at least the float 1e-5 and the resolved |dy| is below it; onGround when the two differ
*> and the requested dy is negative.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-MAXSQ               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IY                   FLOAT-LONG.
 01 L-RY                   FLOAT-LONG.
 01 L-STOPPED              BINARY-LONG.
 01 L-ON-GROUND            BINARY-LONG.
 PROCEDURE DIVISION USING L-IY L-RY L-STOPPED L-ON-GROUND.
     CALL "P2-COLLISION-CONSTANTS" USING WS-MAXSQ WS-LIMIT
     MOVE 0 TO L-STOPPED L-ON-GROUND
     IF FUNCTION ABS(L-IY) >= WS-LIMIT AND FUNCTION ABS(L-RY) < WS-LIMIT
         MOVE 1 TO L-STOPPED
     END-IF
     IF L-IY NOT = L-RY AND L-IY < 0
         MOVE 1 TO L-ON-GROUND
     END-IF
     GOBACK.
 END PROGRAM P2-FREEZE-ON-GROUND.
