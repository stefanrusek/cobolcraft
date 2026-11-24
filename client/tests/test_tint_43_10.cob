*> Acceptance test of docs/protocol/43-tint-sources.md section 10 (mob effect colours): the 40 rows in
*> registration order (raw RGB), the lookup by name, and ids outside 0 to 39 (no colour).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-EFFECTS             PIC X(240) VALUE
     "33EBFF8BAFE0D9C0434A4217FFC700F82423A9656AFDFF84551D4ACD5CAB9146F0FF990098DAC0F6F6F61F1F23C2FF66587653484D4887A363736156F87D232552A5F8242394A061CEFFFF59C106C0A44DF3CFB91DC2D188A3BE0B613844FF4429272116A6A6DE4058BDC9FF78695A99FFA38C9B8C00FFEE".
 01 WS-EFFECTS-R REDEFINES WS-EFFECTS.
    05 WS-EFF              PIC X(6) OCCURS 40 TIMES.
 01 WS-NAMES               PIC X(960) VALUE
     "speed                   slowness                haste                   " &
     "mining_fatigue          strength                instant_health          " &
     "instant_damage          jump_boost              nausea                  " &
     "regeneration            resistance              fire_resistance         " &
     "water_breathing         invisibility            blindness               " &
     "night_vision            hunger                  weakness                " &
     "poison                  wither                  health_boost            " &
     "absorption              saturation              glowing                 " &
     "levitation              luck                    unluck                  " &
     "slow_falling            conduit_power           dolphins_grace          " &
     "bad_omen                hero_of_the_village     darkness                " &
     "trial_omen              raid_omen               wind_charged            " &
     "weaving                 oozing                  infested                " &
     "breath_of_the_nautilus  ".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-ENAME            PIC X(24) OCCURS 40 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-DI                  PIC 99.
 01 WS-OUT                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 39
         MOVE WS-ID TO WS-DI
         CALL "TINT-EFFECT" USING WS-ID WS-COLOUR
         MOVE SPACES TO WS-CASE WS-EXPECT
         STRING "acceptance US11 43§10 Mob effect colours: effect " WS-DI DELIMITED BY SIZE
             INTO WS-CASE
         STRING "00" WS-EFF(WS-ID + 1) DELIMITED BY SIZE INTO WS-EXPECT
         CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
         MOVE WS-ENAME(WS-ID + 1) TO WS-NAME
         CALL "TINT-EFFECT-ID" USING WS-NAME WS-OUT
         MOVE WS-OUT TO TL-OBSERVED-N
         MOVE "acceptance US11 43§10 Mob effect colours: the name gives the id" TO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-ID TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 40 TO WS-ID
     CALL "TINT-EFFECT" USING WS-ID WS-COLOUR
     MOVE "acceptance US11 43§10 Mob effect colours: id 40 has no colour" TO WS-CASE
     MOVE "00000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE "luck_of_the_sea" TO WS-NAME
     CALL "TINT-EFFECT-ID" USING WS-NAME WS-OUT
         MOVE WS-OUT TO TL-OBSERVED-N
     MOVE "acceptance US11 43§10 Mob effect colours: an unknown name has no id" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-TINT-43-10.
 COPY TINTTEST.
