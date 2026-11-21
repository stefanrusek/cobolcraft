*> Particles part 7 (docs/protocol/42-particles-7-emitters-entities-events-commands.md), section 5: mob effect particles.
*> Entry points for the integrator (inputs): P7-EFFECT-PARTICLE effect(X(32), the registry name without namespace) ambient(BINARY-LONG) particle(X(24), out, spaces for an unknown effect) argb(BINARY-DOUBLE,
*>   out: the colour of the option, alpha 255 or 38 for an ambient effect; 0 for a constant particle): 5.2. P7-EFFECT-AMBIENT IN(visible effects, ambient visible effects) OUT(the synchronised ambient flag,
*>   true when every visible effect is ambient, an empty set included): 5.1. The client emission (5.3) is the site effect_tick of P7-BASE (particles-42-7-d.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EFFECT-PARTICLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 FILLER PIC X(32) VALUE "speed".
    05 FILLER PIC 9(8) VALUE 3402751.
    05 FILLER PIC X(32) VALUE "slowness".
    05 FILLER PIC 9(8) VALUE 9154528.
    05 FILLER PIC X(32) VALUE "haste".
    05 FILLER PIC 9(8) VALUE 14270531.
    05 FILLER PIC X(32) VALUE "mining_fatigue".
    05 FILLER PIC 9(8) VALUE 4866583.
    05 FILLER PIC X(32) VALUE "strength".
    05 FILLER PIC 9(8) VALUE 16762624.
    05 FILLER PIC X(32) VALUE "instant_health".
    05 FILLER PIC 9(8) VALUE 16262179.
    05 FILLER PIC X(32) VALUE "instant_damage".
    05 FILLER PIC 9(8) VALUE 11101546.
    05 FILLER PIC X(32) VALUE "jump_boost".
    05 FILLER PIC 9(8) VALUE 16646020.
    05 FILLER PIC X(32) VALUE "nausea".
    05 FILLER PIC 9(8) VALUE 5578058.
    05 FILLER PIC X(32) VALUE "regeneration".
    05 FILLER PIC 9(8) VALUE 13458603.
    05 FILLER PIC X(32) VALUE "resistance".
    05 FILLER PIC 9(8) VALUE 9520880.
    05 FILLER PIC X(32) VALUE "fire_resistance".
    05 FILLER PIC 9(8) VALUE 16750848.
    05 FILLER PIC X(32) VALUE "water_breathing".
    05 FILLER PIC 9(8) VALUE 10017472.
    05 FILLER PIC X(32) VALUE "invisibility".
    05 FILLER PIC 9(8) VALUE 16185078.
    05 FILLER PIC X(32) VALUE "blindness".
    05 FILLER PIC 9(8) VALUE 2039587.
    05 FILLER PIC X(32) VALUE "night_vision".
    05 FILLER PIC 9(8) VALUE 12779366.
    05 FILLER PIC X(32) VALUE "hunger".
    05 FILLER PIC 9(8) VALUE 5797459.
    05 FILLER PIC X(32) VALUE "weakness".
    05 FILLER PIC 9(8) VALUE 4738376.
    05 FILLER PIC X(32) VALUE "poison".
    05 FILLER PIC 9(8) VALUE 8889187.
    05 FILLER PIC X(32) VALUE "wither".
    05 FILLER PIC 9(8) VALUE 7561558.
    05 FILLER PIC X(32) VALUE "health_boost".
    05 FILLER PIC 9(8) VALUE 16284963.
    05 FILLER PIC X(32) VALUE "absorption".
    05 FILLER PIC 9(8) VALUE 2445989.
    05 FILLER PIC X(32) VALUE "saturation".
    05 FILLER PIC 9(8) VALUE 16262179.
    05 FILLER PIC X(32) VALUE "glowing".
    05 FILLER PIC 9(8) VALUE 9740385.
    05 FILLER PIC X(32) VALUE "levitation".
    05 FILLER PIC 9(8) VALUE 13565951.
    05 FILLER PIC X(32) VALUE "luck".
    05 FILLER PIC 9(8) VALUE 5882118.
    05 FILLER PIC X(32) VALUE "unluck".
    05 FILLER PIC 9(8) VALUE 12624973.
    05 FILLER PIC X(32) VALUE "slow_falling".
    05 FILLER PIC 9(8) VALUE 15978425.
    05 FILLER PIC X(32) VALUE "conduit_power".
    05 FILLER PIC 9(8) VALUE 1950417.
    05 FILLER PIC X(32) VALUE "dolphins_grace".
    05 FILLER PIC 9(8) VALUE 8954814.
    05 FILLER PIC X(32) VALUE "bad_omen".
    05 FILLER PIC 9(8) VALUE 745784.
    05 FILLER PIC X(32) VALUE "hero_of_the_village".
    05 FILLER PIC 9(8) VALUE 4521796.
    05 FILLER PIC X(32) VALUE "darkness".
    05 FILLER PIC 9(8) VALUE 2696993.
    05 FILLER PIC X(32) VALUE "trial_omen".
    05 FILLER PIC 9(8) VALUE 1484454.
    05 FILLER PIC X(32) VALUE "raid_omen".
    05 FILLER PIC 9(8) VALUE 14565464.
    05 FILLER PIC X(32) VALUE "wind_charged".
    05 FILLER PIC 9(8) VALUE 12438015.
    05 FILLER PIC X(32) VALUE "weaving".
    05 FILLER PIC 9(8) VALUE 7891290.
    05 FILLER PIC X(32) VALUE "oozing".
    05 FILLER PIC 9(8) VALUE 10092451.
    05 FILLER PIC X(32) VALUE "infested".
    05 FILLER PIC 9(8) VALUE 9214860.
    05 FILLER PIC X(32) VALUE "breath_of_the_nautilus".
    05 FILLER PIC 9(8) VALUE 65518.
 01 WS-TAB-R REDEFINES WS-TAB.
    05 WS-E OCCURS 40 TIMES.
       10 WS-NAME           PIC X(32).
       10 WS-RGB            PIC 9(8).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-EFFECT               PIC X(32).
 01 L-AMBIENT              BINARY-LONG.
 01 L-PARTICLE             PIC X(24).
 01 L-ARGB                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-EFFECT L-AMBIENT L-PARTICLE L-ARGB.
     MOVE SPACES TO L-PARTICLE
     MOVE 0 TO L-ARGB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         IF WS-NAME(WS-I) = L-EFFECT
             MOVE "entity_effect" TO L-PARTICLE
             COMPUTE L-ARGB = 255 * 16777216 + WS-RGB(WS-I)
             IF L-AMBIENT NOT = 0
                 COMPUTE L-ARGB = 38 * 16777216 + WS-RGB(WS-I)
             END-IF
         END-IF
     END-PERFORM
     EVALUATE L-EFFECT
         WHEN "infested"
             MOVE "infested" TO L-PARTICLE
             MOVE 0 TO L-ARGB
         WHEN "oozing"
             MOVE "item_slime" TO L-PARTICLE
             MOVE 0 TO L-ARGB
         WHEN "weaving"
             MOVE "item_cobweb" TO L-PARTICLE
             MOVE 0 TO L-ARGB
         WHEN "wind_charged"
             MOVE "small_gust" TO L-PARTICLE
             MOVE 0 TO L-ARGB
         WHEN "trial_omen"
             MOVE "trial_omen" TO L-PARTICLE
             MOVE 0 TO L-ARGB
         WHEN "raid_omen"
             MOVE "raid_omen" TO L-PARTICLE
             MOVE 0 TO L-ARGB
     END-EVALUATE
     GOBACK.
 END PROGRAM P7-EFFECT-PARTICLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P7-EFFECT-AMBIENT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) = L-I(2)
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM P7-EFFECT-AMBIENT.
