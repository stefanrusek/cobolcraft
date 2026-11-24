*> Acceptance test of docs/protocol/42-particles-3-fluid-drip-water.md section 2 (registry, providers and render
*> layers): every row of the table (id, layer, sprite pick, override flag, frame count, class, provider,
*> section), the frame counts and the animation index consequences. Rows written from the document's table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP3IX.
 COPY TESTLIB.
 01 WS-TYPE                PIC X(24).
 01 WS-EXP                 PIC X(140).
 01 WS-OBS                 PIC X(140).
 01 WS-NAME                PIC X(160).
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OVR                 BINARY-LONG.
 01 WS-TRANS               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LIFE                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-I-D                 PIC 9.
 PROCEDURE DIVISION.
     MOVE "bubble" TO WS-TYPE
     MOVE "0030201BubbleParticle|BubbleParticle$Provider|5.1" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "sulfur_bubbles" TO WS-TYPE
     MOVE "0040201SulfurBubbleParticle|SulfurBubbleParticle$Provider|6.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_lava" TO WS-TYPE
     MOVE "0160201CoolingDripHangParticle|DripParticle$LavaHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_lava" TO WS-TYPE
     MOVE "0170201FallAndLandParticle|DripParticle$LavaFallProvider|3.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "landing_lava" TO WS-TYPE
     MOVE "0180201DripLandParticle|DripParticle$LavaLandProvider|3.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_water" TO WS-TYPE
     MOVE "0190201DripHangParticle|DripParticle$WaterHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_water" TO WS-TYPE
     MOVE "0200201FallAndLandParticle|DripParticle$WaterFallProvider|3.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "fishing" TO WS-TYPE
     MOVE "0380504WakeParticle|WakeParticle$Provider|5.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "rain" TO WS-TYPE
     MOVE "0710204WaterDropParticle|WaterDropParticle$Provider|5.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "squid_ink" TO WS-TYPE
     MOVE "0761118SquidInkParticle|SquidInkParticle$Provider|7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "underwater" TO WS-TYPE
     MOVE "0790201SuspendedParticle|SuspendedParticle$UnderwaterProvider|6.1" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "splash" TO WS-TYPE
     MOVE "0800204SplashParticle|SplashParticle$Provider|5.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "bubble_pop" TO WS-TYPE
     MOVE "0820105BubblePopParticle|BubblePopParticle$Provider|5.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "current_down" TO WS-TYPE
     MOVE "0830201WaterCurrentDownParticle|WaterCurrentDownParticle$Provider|5.6" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "bubble_column_up" TO WS-TYPE
     MOVE "0840201BubbleColumnUpParticle|BubbleColumnUpParticle$Provider|5.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "nautilus" TO WS-TYPE
     MOVE "0850201FlyTowardsPositionParticle|FlyTowardsPositionParticle$NautilusProvider|6.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dolphin" TO WS-TYPE
     MOVE "0860201SuspendedTownParticle|SuspendedTownParticle$DolphinSpeedProvider|6.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_honey" TO WS-TYPE
     MOVE "0890201DripHangParticle|DripParticle$HoneyHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_honey" TO WS-TYPE
     MOVE "0900201HoneyFallAndLandParticle|DripParticle$HoneyFallProvider|3.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "landing_honey" TO WS-TYPE
     MOVE "0910201DripLandParticle|DripParticle$HoneyLandProvider|3.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_nectar" TO WS-TYPE
     MOVE "0920201FallingParticle|DripParticle$NectarFallProvider|3.6" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_spore_blossom" TO WS-TYPE
     MOVE "0930201FallingParticle|DripParticle$SporeBlossomFallProvider|3.6" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_obsidian_tear" TO WS-TYPE
     MOVE "0980201DripHangParticle|DripParticle$ObsidianTearHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_obsidian_tear" TO WS-TYPE
     MOVE "0990201FallAndLandParticle|DripParticle$ObsidianTearFallProvider|3.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "landing_obsidian_tear" TO WS-TYPE
     MOVE "1000201DripLandParticle|DripParticle$ObsidianTearLandProvider|3.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_dripstone_lava" TO WS-TYPE
     MOVE "1050201CoolingDripHangParticle|DripParticle$DripstoneLavaHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_dripstone_lava" TO WS-TYPE
     MOVE "1060201DripstoneFallAndLandParticle|DripParticle$DripstoneLavaFallProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dripping_dripstone_water" TO WS-TYPE
     MOVE "1070201DripHangParticle|DripParticle$DripstoneWaterHangProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "falling_dripstone_water" TO WS-TYPE
     MOVE "1080201DripstoneFallAndLandParticle|DripParticle$DripstoneWaterFallProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "glow_squid_ink" TO WS-TYPE
     MOVE "1091118SquidInkParticle|SquidInkParticle$GlowInkProvider|7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "glow" TO WS-TYPE
     MOVE "1100111GlowParticle|GlowParticle$GlowSquidProvider|8" TO WS-EXP
     PERFORM CHK-ROW
     CALL "P3-INDEX-COUNT" USING WS-N
     MOVE "31 rows (30 table types and the glow class)" TO WS-NAME
     MOVE 31 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-OVR WS-TRANS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
         CALL "P3-INDEX-ROW" USING WS-I P3IX
         ADD P3-OVR TO WS-OVR
         ADD P3-LAYER TO WS-TRANS
     END-PERFORM
     MOVE "the override flag is true for exactly 3 rows (squid_ink, glow_squid_ink, glow)" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-OVR TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "only squid_ink and glow_squid_ink are TRANSLUCENT" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-TRANS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "no_such_particle" TO WS-TYPE
     CALL "P3-INDEX" USING WS-TYPE P3IX
     MOVE "an unknown type is not found" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE P3-FOUND TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   Animation indices: fishing shows (i % 4) * 3 / 4: 0, 0, 1, 2; bubble_pop (n = 5, lifetime 4): 0 1 2 3;
*>   squid ink (age * 7) / lifetime.
     MOVE 4 TO WS-FRAMES
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         CALL "P3-FISHING-SPRITE" USING WS-I WS-FRAMES WS-IDX
         MOVE SPACES TO WS-NAME
         MOVE WS-I TO WS-I-D
         STRING "fishing frame for i % 4 = " WS-I-D " (never frame 3)" DELIMITED BY SIZE INTO WS-NAME
         EVALUATE WS-I
             WHEN 0 MOVE 0 TO TL-EXPECTED-N
             WHEN 1 MOVE 0 TO TL-EXPECTED-N
             WHEN 2 MOVE 1 TO TL-EXPECTED-N
             WHEN OTHER MOVE 2 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-IDX TO TL-OBSERVED-N
         PERFORM ASSERT-NUMBER
     END-PERFORM
     MOVE 4 TO WS-I
     CALL "P3-FISHING-SPRITE" USING WS-I WS-FRAMES WS-IDX
     MOVE "fishing at i = 4 wraps to frame 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IDX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 5 TO WS-FRAMES
     MOVE 4 TO WS-LIFE
     PERFORM VARYING WS-AGE FROM 0 BY 1 UNTIL WS-AGE > 3
         CALL "PCL-SPRITE-INDEX" USING WS-AGE WS-LIFE WS-FRAMES WS-IDX
         MOVE SPACES TO WS-NAME
         MOVE WS-AGE TO WS-I-D
         STRING "bubble_pop shows frame " WS-I-D " on tick " WS-I-D DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-AGE TO TL-EXPECTED-N
         MOVE WS-IDX TO TL-OBSERVED-N
         PERFORM ASSERT-NUMBER
     END-PERFORM
     MOVE 0.5 TO WS-DRAW
     MOVE 1 TO WS-N
     CALL "P3-SPRITE-GET" USING WS-N WS-DRAW WS-IDX
     MOVE "get(random) of a one frame set is frame 0 (one nextInt(1) draw)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-IDX TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 CHK-ROW.
     CALL "P3-INDEX" USING WS-TYPE P3IX
     MOVE SPACES TO WS-OBS
     STRING P3-ID P3-LAYER P3-PICK P3-OVR P3-FRAMES FUNCTION TRIM(P3-CLASS) "|"
         FUNCTION TRIM(P3-PROVIDER) "|" FUNCTION TRIM(P3-SECTION)
         DELIMITED BY SIZE INTO WS-OBS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§2 Registry, providers and render layers: row " FUNCTION TRIM(WS-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-3§2 Registry, providers and render layers: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-3-2.
