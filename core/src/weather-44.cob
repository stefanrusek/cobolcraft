*> Lightning from thunderstorms (docs/protocol/33 section 4.4 tickThunder; lane 002-lane-mobsb8, T9710): LIGHTNING-WEATHER-TICK (called after THROWN-TICK) draws, for every chunk within 3 chunks of a player
*> of a dimension in rain and thunder, the one in 100000 strike (XP-RANDOM); LIGHTNING-CHUNK-TICK takes that draw as a parameter (0 strikes) and picks the column; LIGHTNING-STRIKE-AT makes the bolt at the
*> bottom centre of the column's surface and, with the roll below the effective difficulty (thousandths over 100000: nextDouble < e x 0.01) and spawn_mobs on, a skeleton horse beside a visual-only bolt.
*> Gaps: the lightning rod search (POI), the living-entity retargeting, the sky light and biome precipitation test (the column's surface counts as open sky and rain), the inhabited time and moon in the
*> local difficulty (0 are used), the horse's trap behaviour is core/src/mob-skeleton-trap.cob, spawnFire.
*>
*>   LIGHTNING-CHUNK-TICK USING dim, chunk x, chunk z, draw (0 strikes)
*>   LIGHTNING-STRIKE-AT USING dim, block x, block z, trap roll (0 to 99999), bolt row out
*>   LIGHTNING-WEATHER-TICK                   no parameters

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-STRIKE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY BRWORLD.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-EFF                 BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE VALUE 0.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawn_mobs".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-TRAP                BINARY-LONG.
 01 WS-HKEY                PIC X(112) VALUE "minecraft:skeleton_horse".
 01 WS-HTYPE               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HROW                BINARY-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-VISUAL              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-ROLL L-ROW.
     CALL "DRAGON-SURFACE" USING L-DIM L-X L-Z WS-SURFACE
     MOVE WS-SURFACE TO WS-Y
     IF WS-SURFACE = 0
         MOVE 2 TO WS-Y
     END-IF
     CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY WS-TIME WS-INHABITED WS-MOON WS-EFF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     MOVE 0 TO WS-TRAP WS-VISUAL
     IF WS-RULE NOT = 0 AND L-ROLL < WS-EFF
         MOVE 1 TO WS-TRAP
     END-IF
     IF WS-TRAP = 1
         CALL "THROWN-TYPE" USING WS-HKEY WS-HTYPE
         MOVE L-X TO WS-HX
         MOVE WS-Y TO WS-HY
         MOVE L-Z TO WS-HZ
         MOVE 0 TO WS-HROW
         IF WS-HTYPE > 0
             CALL "MOB-SPAWN" USING L-DIM WS-HTYPE WS-HX WS-HY WS-HZ WS-YAW WS-HROW
         END-IF
         IF WS-HROW > 0
             MOVE 1 TO WS-VISUAL
*>           The trap horse (19 section 3.6): the trap flag set, age 0 (SKELETON-HORSE-TICK springs it when a living player is within 10 blocks).
             CALL "WC-ROW-OPEN" USING WS-HROW
             MOVE 1 TO WC-TRAP(WS-HROW)
             MOVE 0 TO WC-TRAP-TICKS(WS-HROW) EN-MOBAGE(WS-HROW)
         END-IF
     END-IF
     COMPUTE WS-BX = L-X + 0.5
     MOVE WS-Y TO WS-BY
     COMPUTE WS-BZ = L-Z + 0.5
     CALL "LIGHTNING-SPAWN" USING L-DIM WS-BX WS-BY WS-BZ WS-VISUAL L-ROW
     GOBACK.
 END PROGRAM LIGHTNING-STRIKE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-CHUNK-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAIN                BINARY-LONG.
 01 WS-THUNDER             BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9143.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 100000.
 01 WS-ROLL                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-DRAW.
     CALL "WEATHER-RAINING" USING L-DIM WS-RAIN
     CALL "WEATHER-THUNDERING" USING L-DIM WS-THUNDER
     IF WS-RAIN = 1 AND WS-THUNDER = 1 AND L-DRAW = 0
         CALL "XP-RANDOM" USING WS-SALT WS-SIXTEEN WS-DX
         CALL "XP-RANDOM" USING WS-SALT WS-SIXTEEN WS-DZ
         COMPUTE WS-X = L-CX * 16 + WS-DX
         COMPUTE WS-Z = L-CZ * 16 + WS-DZ
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-ROLL
         CALL "LIGHTNING-STRIKE-AT" USING L-DIM WS-X WS-Z WS-ROLL WS-ROW
     END-IF
     GOBACK.
 END PROGRAM LIGHTNING-CHUNK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LIGHTNING-WEATHER-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-THUNDER             BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9144.
 01 WS-BOUND               BINARY-LONG VALUE 100000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-ENTITY-ROW(WS-P) > 0
             CALL "WEATHER-RAINING" USING PL-DIM(WS-P) WS-RAIN
             CALL "WEATHER-THUNDERING" USING PL-DIM(WS-P) WS-THUNDER
             IF WS-RAIN = 1 AND WS-THUNDER = 1
                 PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
                     PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
                         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
                         IF WS-DRAW = 0
                             COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-P) / 16) + WS-DX
                             COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-P) / 16) + WS-DZ
                             CALL "LIGHTNING-CHUNK-TICK" USING PL-DIM(WS-P) WS-CX WS-CZ WS-DRAW
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LIGHTNING-WEATHER-TICK.
