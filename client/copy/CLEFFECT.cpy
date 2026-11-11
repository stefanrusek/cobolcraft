*> The 40 status effects (docs/protocol/49 section 2.4), in registry order (the wire id is the row - 1; 46 section 4):
*> key (24), category B beneficial, H harmful, N neutral (1), colour RRGGBB hex (6), English name (24). The name is the fallback of
*> the lang key effect.minecraft.<key>; a pack's lang file replaces it.
 01 EF-TABLE-DATA.
    05 FILLER PIC X(55) VALUE "speed                   B33EBFFSpeed                   ".
    05 FILLER PIC X(55) VALUE "slowness                H8BAFE0Slowness                ".
    05 FILLER PIC X(55) VALUE "haste                   BD9C043Haste                   ".
    05 FILLER PIC X(55) VALUE "mining_fatigue          H4A4217Mining Fatigue          ".
    05 FILLER PIC X(55) VALUE "strength                BFFC700Strength                ".
    05 FILLER PIC X(55) VALUE "instant_health          BF82423Instant Health          ".
    05 FILLER PIC X(55) VALUE "instant_damage          HA9656AInstant Damage          ".
    05 FILLER PIC X(55) VALUE "jump_boost              BFDFF84Jump Boost              ".
    05 FILLER PIC X(55) VALUE "nausea                  H551D4ANausea                  ".
    05 FILLER PIC X(55) VALUE "regeneration            BCD5CABRegeneration            ".
    05 FILLER PIC X(55) VALUE "resistance              B9146F0Resistance              ".
    05 FILLER PIC X(55) VALUE "fire_resistance         BFF9900Fire Resistance         ".
    05 FILLER PIC X(55) VALUE "water_breathing         B98DAC0Water Breathing         ".
    05 FILLER PIC X(55) VALUE "invisibility            BF6F6F6Invisibility            ".
    05 FILLER PIC X(55) VALUE "blindness               H1F1F23Blindness               ".
    05 FILLER PIC X(55) VALUE "night_vision            BC2FF66Night Vision            ".
    05 FILLER PIC X(55) VALUE "hunger                  H587653Hunger                  ".
    05 FILLER PIC X(55) VALUE "weakness                H484D48Weakness                ".
    05 FILLER PIC X(55) VALUE "poison                  H87A363Poison                  ".
    05 FILLER PIC X(55) VALUE "wither                  H736156Wither                  ".
    05 FILLER PIC X(55) VALUE "health_boost            BF87D23Health Boost            ".
    05 FILLER PIC X(55) VALUE "absorption              B2552A5Absorption              ".
    05 FILLER PIC X(55) VALUE "saturation              BF82423Saturation              ".
    05 FILLER PIC X(55) VALUE "glowing                 N94A061Glowing                 ".
    05 FILLER PIC X(55) VALUE "levitation              HCEFFFFLevitation              ".
    05 FILLER PIC X(55) VALUE "luck                    B59C106Luck                    ".
    05 FILLER PIC X(55) VALUE "unluck                  HC0A44DBad Luck                ".
    05 FILLER PIC X(55) VALUE "slow_falling            BF3CFB9Slow Falling            ".
    05 FILLER PIC X(55) VALUE "conduit_power           B1DC2D1Conduit Power           ".
    05 FILLER PIC X(55) VALUE "dolphins_grace          B88A3BEDolphin's Grace         ".
    05 FILLER PIC X(55) VALUE "bad_omen                N0B6138Bad Omen                ".
    05 FILLER PIC X(55) VALUE "hero_of_the_village     B44FF44Hero of the Village     ".
    05 FILLER PIC X(55) VALUE "darkness                H292721Darkness                ".
    05 FILLER PIC X(55) VALUE "trial_omen              N16A6A6Trial Omen              ".
    05 FILLER PIC X(55) VALUE "raid_omen               NDE4058Raid Omen               ".
    05 FILLER PIC X(55) VALUE "wind_charged            HBDC9FFWind Charged            ".
    05 FILLER PIC X(55) VALUE "weaving                 H78695AWeaving                 ".
    05 FILLER PIC X(55) VALUE "oozing                  H99FFA3Oozing                  ".
    05 FILLER PIC X(55) VALUE "infested                H8C9B8CInfested                ".
    05 FILLER PIC X(55) VALUE "breath_of_the_nautilus  B00FFEEBreath of the Nautilus  ".
 01 EF-TABLE REDEFINES EF-TABLE-DATA.
    05 EF-ROW OCCURS 40 TIMES.
       10 EF-ROW-KEY         PIC X(24).
       10 EF-ROW-CATEGORY    PIC X.
       10 EF-ROW-COLOUR      PIC X(6).
       10 EF-ROW-NAME        PIC X(24).
