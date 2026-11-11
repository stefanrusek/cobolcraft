*> Registry table of docs/protocol/42-particles-3-fluid-drip-water.md section 2: 31 rows of name X(24), id 999, layer 9,
*> pick 9, override 9, frames 9, provider X(52), class X(40), section X(4).
 01 P3-ROW-DATA.
    05 FILLER PIC X(127) VALUE "bubble                  0030201BubbleParticle$Provider                             BubbleParticle                          5.1 ".
    05 FILLER PIC X(127) VALUE "sulfur_bubbles          0040201SulfurBubbleParticle$Provider                       SulfurBubbleParticle                    6.4 ".
    05 FILLER PIC X(127) VALUE "dripping_lava           0160201DripParticle$LavaHangProvider                       CoolingDripHangParticle                 3.3 ".
    05 FILLER PIC X(127) VALUE "falling_lava            0170201DripParticle$LavaFallProvider                       FallAndLandParticle                     3.4 ".
    05 FILLER PIC X(127) VALUE "landing_lava            0180201DripParticle$LavaLandProvider                       DripLandParticle                        3.5 ".
    05 FILLER PIC X(127) VALUE "dripping_water          0190201DripParticle$WaterHangProvider                      DripHangParticle                        3.3 ".
    05 FILLER PIC X(127) VALUE "falling_water           0200201DripParticle$WaterFallProvider                      FallAndLandParticle                     3.4 ".
    05 FILLER PIC X(127) VALUE "fishing                 0380504WakeParticle$Provider                               WakeParticle                            5.4 ".
    05 FILLER PIC X(127) VALUE "rain                    0710204WaterDropParticle$Provider                          WaterDropParticle                       5.3 ".
    05 FILLER PIC X(127) VALUE "squid_ink               0761118SquidInkParticle$Provider                           SquidInkParticle                        7   ".
    05 FILLER PIC X(127) VALUE "underwater              0790201SuspendedParticle$UnderwaterProvider                SuspendedParticle                       6.1 ".
    05 FILLER PIC X(127) VALUE "splash                  0800204SplashParticle$Provider                             SplashParticle                          5.3 ".
    05 FILLER PIC X(127) VALUE "bubble_pop              0820105BubblePopParticle$Provider                          BubblePopParticle                       5.2 ".
    05 FILLER PIC X(127) VALUE "current_down            0830201WaterCurrentDownParticle$Provider                   WaterCurrentDownParticle                5.6 ".
    05 FILLER PIC X(127) VALUE "bubble_column_up        0840201BubbleColumnUpParticle$Provider                     BubbleColumnUpParticle                  5.5 ".
    05 FILLER PIC X(127) VALUE "nautilus                0850201FlyTowardsPositionParticle$NautilusProvider         FlyTowardsPositionParticle              6.3 ".
    05 FILLER PIC X(127) VALUE "dolphin                 0860201SuspendedTownParticle$DolphinSpeedProvider          SuspendedTownParticle                   6.2 ".
    05 FILLER PIC X(127) VALUE "dripping_honey          0890201DripParticle$HoneyHangProvider                      DripHangParticle                        3.3 ".
    05 FILLER PIC X(127) VALUE "falling_honey           0900201DripParticle$HoneyFallProvider                      HoneyFallAndLandParticle                3.4 ".
    05 FILLER PIC X(127) VALUE "landing_honey           0910201DripParticle$HoneyLandProvider                      DripLandParticle                        3.5 ".
    05 FILLER PIC X(127) VALUE "falling_nectar          0920201DripParticle$NectarFallProvider                     FallingParticle                         3.6 ".
    05 FILLER PIC X(127) VALUE "falling_spore_blossom   0930201DripParticle$SporeBlossomFallProvider               FallingParticle                         3.6 ".
    05 FILLER PIC X(127) VALUE "dripping_obsidian_tear  0980201DripParticle$ObsidianTearHangProvider               DripHangParticle                        3.3 ".
    05 FILLER PIC X(127) VALUE "falling_obsidian_tear   0990201DripParticle$ObsidianTearFallProvider               FallAndLandParticle                     3.4 ".
    05 FILLER PIC X(127) VALUE "landing_obsidian_tear   1000201DripParticle$ObsidianTearLandProvider               DripLandParticle                        3.5 ".
    05 FILLER PIC X(127) VALUE "dripping_dripstone_lava 1050201DripParticle$DripstoneLavaHangProvider              CoolingDripHangParticle                 3.3 ".
    05 FILLER PIC X(127) VALUE "falling_dripstone_lava  1060201DripParticle$DripstoneLavaFallProvider              DripstoneFallAndLandParticle            3.7 ".
    05 FILLER PIC X(127) VALUE "dripping_dripstone_water1070201DripParticle$DripstoneWaterHangProvider             DripHangParticle                        3.3 ".
    05 FILLER PIC X(127) VALUE "falling_dripstone_water 1080201DripParticle$DripstoneWaterFallProvider             DripstoneFallAndLandParticle            3.7 ".
    05 FILLER PIC X(127) VALUE "glow_squid_ink          1091118SquidInkParticle$GlowInkProvider                    SquidInkParticle                        7   ".
    05 FILLER PIC X(127) VALUE "glow                    1100111GlowParticle$GlowSquidProvider                      GlowParticle                            8   ".
 01 P3-ROWS REDEFINES P3-ROW-DATA.
    05 P3R                    OCCURS 31 TIMES.
       10 R-NAME              PIC X(24).
       10 R-ID                PIC 999.
       10 R-LAYER             PIC 9.
       10 R-PICK              PIC 9.
       10 R-OVR               PIC 9.
       10 R-FRAMES            PIC 9.
       10 R-PROVIDER          PIC X(52).
       10 R-CLASS             PIC X(40).
       10 R-SECTION           PIC X(4).
