*> Dimension presentation of the client (docs/protocol/39-portals.md section 9, 37-nether-3 section 7, 38-end.md section 11, 12-client-rendering.md section 3): the data the
*> renderer and the sound engine read, as pure steps over CLIENT-STATE (DX-STATE of CLSTATE.cpy). The drawing itself (the portal overlay and wobble shader, the End sky box
*> and the flash sprite, the lightmap uniform) is the renderer's.
*>
*> Entry points:
*>   DIMFX-PORTAL-INSIDE USING CLIENT-STATE, inside out   1 when the local player's box (0.6 x 1.8) overlaps a nether_portal block (the CONFUSION transition)
*>   DIMFX-PORTAL-TICK USING CLIENT-STATE, inside, random (FLOAT-LONG 0 to 1)   one tick of the portal process (39 section 9)
*>   DIMFX-PORTAL-LEVEL USING CLIENT-STATE, partial tick (FLOAT-LONG), level out   the overlay and wobble intensity at the partial tick
*>   DIMFX-ENV USING CLIENT-STATE   the atmospheric fog, skybox and ambient light of the dimension and the biome at the camera
*>   DIMFX-FLASH-TICK USING CLIENT-STATE   one client tick of the End flash (38 section 11 items 1 to 3), DX-CLOCK having been advanced

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-PORTAL-INSIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-E                   FLOAT-LONG VALUE 0.00001.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INSIDE.
     MOVE 0 TO L-INSIDE
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X - 0.3 + WS-E)
     COMPUTE WS-X1 = FUNCTION INTEGER(PL-X + 0.3 - WS-E)
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y + WS-E)
     COMPUTE WS-Y1 = FUNCTION INTEGER(PL-Y + 1.8 - WS-E)
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z - 0.3 + WS-E)
     COMPUTE WS-Z1 = FUNCTION INTEGER(PL-Z + 0.3 - WS-E)
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
             PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
                 IF ST-BLOCK-NAME(ST-BLOCK(WS-STATE + 1) + 1) = "nether_portal"
                     MOVE 1 TO L-INSIDE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM DIMFX-PORTAL-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-PORTAL-TICK.
*> 39 section 9: inside, the intensity rises by 0.0125 (at most 1) and PORTAL_TRIGGER plays when it starts from 0 (volume 0.25, pitch random x 0.4 + 0.8); outside it falls
*> by 0.05 (at least 0). DX-SOUND is 1 for the one tick the sound starts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INSIDE               BINARY-LONG.
 01 L-RANDOM               FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INSIDE L-RANDOM.
     MOVE DX-PORTAL TO DX-PORTAL-OLD
     MOVE 0 TO DX-SOUND
     IF L-INSIDE = 1
         IF DX-PORTAL = 0
             MOVE 1 TO DX-SOUND
             MOVE 0.25 TO DX-SOUND-VOLUME
             COMPUTE DX-SOUND-PITCH = L-RANDOM * 0.4 + 0.8
         END-IF
         COMPUTE DX-PORTAL = FUNCTION MIN(1, DX-PORTAL + 0.0125)
     ELSE
         COMPUTE DX-PORTAL = FUNCTION MAX(0, DX-PORTAL - 0.05)
     END-IF
     GOBACK.
 END PROGRAM DIMFX-PORTAL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-PORTAL-LEVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LEVEL                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PARTIAL L-LEVEL.
     COMPUTE L-LEVEL = DX-PORTAL-OLD + (DX-PORTAL - DX-PORTAL-OLD) * L-PARTIAL
     GOBACK.
 END PROGRAM DIMFX-PORTAL-LEVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-ENV.
*> The Nether (37-3 section 7.1; 37-1 section 2.2): the fog colour is the visual/fog_color of the biome under the eye (TB-FOGC from the biome registry; #000000 when the biome
*> sets none), the fog from 10 to 96 blocks, no sky box (skybox none), ambient light #302821. The End (38 section 2 and 11): fog colour #181318, the end sky box, ambient light
*> #3f473f, no fog distances of its own. Any other dimension sets none (the overworld's sky and fog stay SKY-UPDATE's and the render distance's). Sampled at the eye, no
*> blending between biomes (open item).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO DX-FOG-SET DX-SKYBOX
     MOVE -1 TO DX-FOG-START DX-FOG-END
     MOVE 0 TO DX-AMBIENT-R DX-AMBIENT-G DX-AMBIENT-B
     EVALUATE PL-DIM-NAME
         WHEN "minecraft:the_nether"
             MOVE 1 TO DX-FOG-SET DX-SKYBOX
             MOVE 10 TO DX-FOG-START
             MOVE 96 TO DX-FOG-END
             COMPUTE WS-EX = FUNCTION INTEGER(PL-X)
             COMPUTE WS-EY = FUNCTION INTEGER(PL-Y + 1.6)
             COMPUTE WS-EZ = FUNCTION INTEGER(PL-Z)
             CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-EX WS-EY WS-EZ WS-BIOME
             COMPUTE WS-COLOUR = FUNCTION MOD(TB-FOGC(WS-BIOME + 1), 16777216)
             COMPUTE DX-AMBIENT-R = 48 / 255
             COMPUTE DX-AMBIENT-G = 40 / 255
             COMPUTE DX-AMBIENT-B = 33 / 255
         WHEN "minecraft:the_end"
             MOVE 1 TO DX-FOG-SET
             MOVE 2 TO DX-SKYBOX
             MOVE 1577752 TO WS-COLOUR
             COMPUTE DX-AMBIENT-R = 63 / 255
             COMPUTE DX-AMBIENT-G = 71 / 255
             COMPUTE DX-AMBIENT-B = 63 / 255
         WHEN OTHER
             GOBACK
     END-EVALUATE
     DIVIDE WS-COLOUR BY 65536 GIVING WS-Q
     COMPUTE DX-FOG-R = FUNCTION MOD(WS-Q, 256) / 255
     DIVIDE WS-COLOUR BY 256 GIVING WS-Q
     COMPUTE DX-FOG-G = FUNCTION MOD(WS-Q, 256) / 255
     COMPUTE DX-FOG-B = FUNCTION MOD(WS-COLOUR, 256) / 255
     GOBACK.
 END PROGRAM DIMFX-ENV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-FLASH-TICK.
*> 38 section 11 items 1 to 3. t = DX-CLOCK; window = t div 600, phase = t mod 600. The parameters are recomputed when the window changes (window 0 never computes them: no flash in
*> the first 600 ticks): the Java LCG seeded with the window, one nextFloat() drawn and discarded, offset = nextInt(201), duration = 100 + nextInt(min(380, 600 - offset) - 99),
*> xAngle = float(nextFloat() x 70 + -60), yAngle = float(nextFloat() x 360 + -180). The intensity is 0 outside offset to offset + duration, else the table sine (Mth.sin) of
*> float(phase - offset) x 3.1415927f / float(duration), in float. Only in the End (hasEndFlashes). The intensity of the previous tick is kept; DX-FLASH-SOUND is 1 on the
*> tick a flash starts (new above 0, old not).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WINDOW              BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-STATE               BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RAW                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PI                  FLOAT-LONG VALUE 3.1415927.
 01 WS-PI-F                FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE DX-FLASH TO DX-FLASH-OLD
     MOVE 0 TO DX-FLASH DX-FLASH-SOUND
     IF PL-DIM-NAME NOT = "minecraft:the_end"
         GOBACK
     END-IF
     DIVIDE DX-CLOCK BY 600 GIVING WS-WINDOW REMAINDER WS-PHASE
     IF WS-WINDOW NOT = DX-FLASH-WINDOW
         MOVE WS-WINDOW TO DX-FLASH-WINDOW
         MOVE WS-WINDOW TO WS-SEED
         CALL "PART-RANDOM-SEED" USING WS-SEED WS-STATE
         MOVE 24 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
         MOVE 201 TO WS-BOUND
         CALL "DIMFX-NEXT-INT" USING WS-STATE WS-BOUND WS-R
         MOVE WS-R TO DX-FLASH-OFFSET
         COMPUTE WS-BOUND = FUNCTION MIN(380, 600 - DX-FLASH-OFFSET) - 99
         CALL "DIMFX-NEXT-INT" USING WS-STATE WS-BOUND WS-R
         COMPUTE DX-FLASH-DURATION = 100 + WS-R
         CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
         COMPUTE WS-RAW = WS-VALUE / 16777216 * 70
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW WS-A
         COMPUTE WS-RAW = WS-A - 60
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW DX-FLASH-XA
         CALL "TINT-LEGACY-NEXT" USING WS-STATE WS-BITS WS-VALUE
         COMPUTE WS-RAW = WS-VALUE / 16777216 * 360
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW WS-A
         COMPUTE WS-RAW = WS-A - 180
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW DX-FLASH-YA
     END-IF
     IF WS-PHASE >= DX-FLASH-OFFSET AND WS-PHASE <= DX-FLASH-OFFSET + DX-FLASH-DURATION
             AND DX-FLASH-DURATION > 0
         COMPUTE WS-I = WS-PHASE - DX-FLASH-OFFSET
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-PI WS-PI-F
         COMPUTE WS-RAW = WS-I * WS-PI-F
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW WS-T
         COMPUTE WS-RAW = WS-T / DX-FLASH-DURATION
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-RAW WS-B
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE WS-B DX-FLASH
     END-IF
     IF DX-FLASH > 0 AND DX-FLASH-OLD = 0
         MOVE 1 TO DX-FLASH-SOUND
     END-IF
     GOBACK.
 END PROGRAM DIMFX-FLASH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMFX-NEXT-INT.
*> USING LCG state (BINARY-DOUBLE, updated), bound (BINARY-LONG, 1 to 2^30, not a power of two), result out: Random.nextInt(bound): r = next(31) mod bound, drawn again when
*> u - r + bound - 1 overflows an int.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 31.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-GUARD               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE.
 01 L-BOUND                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BOUND L-RESULT.
     MOVE 1 TO WS-GUARD
     PERFORM UNTIL WS-GUARD = 0
         CALL "TINT-LEGACY-NEXT" USING L-STATE WS-BITS WS-VALUE
         COMPUTE L-RESULT = FUNCTION MOD(WS-VALUE, L-BOUND)
         IF WS-VALUE - L-RESULT + L-BOUND - 1 < 2147483648
             MOVE 0 TO WS-GUARD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DIMFX-NEXT-INT.
