*> Pillager patrols (docs/protocol/20 section 14.1; lane 002-lane-mobsb5, T8908). State: core/copy/PATROL.cpy.
*>   PATROL-MEMBERS USING difficulty, members out       difficulty + 1 (the document says ceil(effective difficulty) + 1; the effective difficulty is approximated by the difficulty id)
*>   PATROL-CLOSE USING dim, x, y, z, yes out           isCloseToVillage(pos, 2): a village point within 2 sections
*>   PATROL-ATTEMPT USING player row, x offset, z offset, result out   0 spawned, 1 early game, 2 near a village, 3 no ground for the first member
*>   PATROL-TICK                                        PatrolSpawner.tick (from STDMOB-SPAWN-TICK)
*> Gaps: the spawn_patrols game rule (no readable store), the mushroom_fields biome block, chunks loaded around the point, the block light limit 8 of checkPatrollingMonsterSpawnRules,
*> the heightmap (TRADER-GROUND column scan), the leader's ominous banner (item components), the patrol walk (long-distance patrol goal) and hold-ground goal, the patrol-leader
*> chance 0.06 of ordinary spawns, a patrolling mob's removeWhenFarAway at 128 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATROL-MEMBERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-DIFF                  BINARY-LONG.
 01 L-N                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFF L-N.
     COMPUTE L-N = L-DIFF + 1
     GOBACK.
 END PROGRAM PATROL-MEMBERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATROL-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-YES.
     MOVE 0 TO L-YES
     COMPUTE WS-SX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(L-Y / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX OR L-YES = 1
         IF PX-KIND(WS-I) > 0 AND PX-DIM(WS-I) = L-DIM
             IF FUNCTION ABS(FUNCTION INTEGER(PX-X(WS-I) / 16) - WS-SX) <= 2
                     AND FUNCTION ABS(FUNCTION INTEGER(PX-Y(WS-I) / 16) - WS-SY) <= 2
                     AND FUNCTION ABS(FUNCTION INTEGER(PX-Z(WS-I) / 16) - WS-SZ) <= 2
                 MOVE 1 TO L-YES
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PATROL-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATROL-ATTEMPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY PATROL.
 01 WS-KEY                  PIC X(112) VALUE "minecraft:pillager".
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-X                    BINARY-LONG.
 01 WS-Z                    BINARY-LONG.
 01 WS-Y                    BINARY-LONG.
 01 WS-GROUND               BINARY-LONG.
 01 WS-ROW                  BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-J                    BINARY-LONG.
 01 WS-STOP                 BINARY-LONG.
 01 WS-D1                   BINARY-LONG.
 01 WS-D2                   BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 76.
 01 WS-B5                   BINARY-LONG VALUE 5.
 01 WS-B1000                BINARY-LONG VALUE 1000.
 01 WS-FX                   FLOAT-LONG.
 01 WS-FY                   FLOAT-LONG.
 01 WS-FZ                   FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-PLAYER                BINARY-LONG.
 01 L-OX                    BINARY-LONG.
 01 L-OZ                    BINARY-LONG.
 01 L-RESULT                BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-OX L-OZ L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(L-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(L-PLAYER))
     CALL "PATROL-CLOSE" USING PL-DIM(L-PLAYER) WS-PX WS-PY WS-PZ WS-YES
     IF WS-YES = 1
         MOVE 2 TO L-RESULT
         GOBACK
     END-IF
     IF CW-TICKS < 120000
         MOVE 1 TO L-RESULT
         GOBACK
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "PATROL-MEMBERS" USING BW-DIFFICULTY WS-N
     COMPUTE WS-X = WS-PX + L-OX
     COMPUTE WS-Z = WS-PZ + L-OZ
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N OR WS-STOP = 1
         CALL "TRADER-GROUND" USING PL-DIM(L-PLAYER) WS-X WS-Z WS-PY WS-GROUND WS-Y
         IF WS-GROUND = 0
             MOVE 1 TO WS-STOP
             IF WS-I = 0
                 MOVE 3 TO L-RESULT
             END-IF
         ELSE
             COMPUTE WS-FX = WS-X + 0.5
             MOVE WS-Y TO WS-FY
             COMPUTE WS-FZ = WS-Z + 0.5
             CALL "MOB-SPAWN" USING PL-DIM(L-PLAYER) WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
             MOVE 0 TO WS-SLOT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PT-MAX OR WS-SLOT > 0
                 IF PT-ID(WS-J) = 0
                     MOVE WS-J TO WS-SLOT
                 END-IF
             END-PERFORM
             IF WS-SLOT > 0
                 MOVE EN-ID(WS-ROW) TO PT-ID(WS-SLOT)
                 MOVE 0 TO PT-LEADER(WS-SLOT)
                 IF WS-I = 0
                     MOVE 1 TO PT-LEADER(WS-SLOT)
                 END-IF
                 CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-D1
                 CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-D2
                 COMPUTE PT-TX(WS-SLOT) = WS-X - 500 + WS-D1
                 COMPUTE PT-TZ(WS-SLOT) = WS-Z - 500 + WS-D2
             END-IF
             CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-D1
             CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-D2
             COMPUTE WS-X = WS-X + WS-D1 - WS-D2
             CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-D1
             CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-D2
             COMPUTE WS-Z = WS-Z + WS-D1 - WS-D2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PATROL-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PATROL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PATROL.
 01 WS-SALT                 BINARY-LONG VALUE 77.
 01 WS-B1200                BINARY-LONG VALUE 1200.
 01 WS-B5                   BINARY-LONG VALUE 5.
 01 WS-B24                  BINARY-LONG VALUE 24.
 01 WS-B2                   BINARY-LONG VALUE 2.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-OX                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-SIGN                 BINARY-LONG.
 01 WS-RESULT               BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 PROCEDURE DIVISION.
     IF PT-NEXT > 0
         SUBTRACT 1 FROM PT-NEXT
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B1200 WS-DRAW
     COMPUTE PT-NEXT = PT-NEXT + 12000 + WS-DRAW
     IF FUNCTION MOD(CW-TIME, 24000) >= 12000
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-DRAW
     IF WS-DRAW NOT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) NOT = DIM-STANDARD-NETHER AND PL-DIM(WS-P) NOT = DIM-STANDARD-END
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-N WS-PICK
     ADD 1 TO WS-PICK
     MOVE 0 TO WS-K
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 64
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) NOT = DIM-STANDARD-NETHER AND PL-DIM(WS-P) NOT = DIM-STANDARD-END
             ADD 1 TO WS-K
             IF WS-K = WS-PICK
                 MOVE WS-P TO WS-N
             END-IF
         END-IF
     END-PERFORM
     IF PL-MODE(WS-N) = 3
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B24 WS-DRAW
     COMPUTE WS-OX = 24 + WS-DRAW
     CALL "XP-RANDOM" USING WS-SALT WS-B2 WS-SIGN
     IF WS-SIGN = 0
         COMPUTE WS-OX = - WS-OX
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-B24 WS-DRAW
     COMPUTE WS-OZ = 24 + WS-DRAW
     CALL "XP-RANDOM" USING WS-SALT WS-B2 WS-SIGN
     IF WS-SIGN = 0
         COMPUTE WS-OZ = - WS-OZ
     END-IF
     CALL "PATROL-ATTEMPT" USING WS-N WS-OX WS-OZ WS-RESULT
     GOBACK.
 END PROGRAM PATROL-TICK.
