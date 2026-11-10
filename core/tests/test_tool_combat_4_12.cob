*> Test of combat 4.12 (17 section 4.12, 8; core/src/tools-combat.cob): the 51 damage types with exhaustion and scaling, effects, death message types and the tags.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TOOL-COMBAT-4-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 TYPE-ROWS.
    05 FILLER PIC X(32) VALUE "cramming".
    05 FILLER PIC X(32) VALUE "dragon_breath".
    05 FILLER PIC X(32) VALUE "drown".
    05 FILLER PIC X(32) VALUE "ender_pearl".
    05 FILLER PIC X(32) VALUE "fall".
    05 FILLER PIC X(32) VALUE "fly_into_wall".
    05 FILLER PIC X(32) VALUE "freeze".
    05 FILLER PIC X(32) VALUE "generic".
    05 FILLER PIC X(32) VALUE "generic_kill".
    05 FILLER PIC X(32) VALUE "in_wall".
    05 FILLER PIC X(32) VALUE "indirect_magic".
    05 FILLER PIC X(32) VALUE "magic".
    05 FILLER PIC X(32) VALUE "on_fire".
    05 FILLER PIC X(32) VALUE "out_of_world".
    05 FILLER PIC X(32) VALUE "outside_border".
    05 FILLER PIC X(32) VALUE "stalagmite".
    05 FILLER PIC X(32) VALUE "starve".
    05 FILLER PIC X(32) VALUE "wither".
    05 FILLER PIC X(32) VALUE "sonic_boom".
    05 FILLER PIC X(32) VALUE "bad_respawn_point".
    05 FILLER PIC X(32) VALUE "explosion".
    05 FILLER PIC X(32) VALUE "player_explosion".
    05 FILLER PIC X(32) VALUE "campfire".
    05 FILLER PIC X(32) VALUE "fireball".
    05 FILLER PIC X(32) VALUE "hot_floor".
    05 FILLER PIC X(32) VALUE "in_fire".
    05 FILLER PIC X(32) VALUE "lava".
    05 FILLER PIC X(32) VALUE "sulfur_cube_hot".
    05 FILLER PIC X(32) VALUE "unattributed_fireball".
    05 FILLER PIC X(32) VALUE "arrow".
    05 FILLER PIC X(32) VALUE "cactus".
    05 FILLER PIC X(32) VALUE "dry_out".
    05 FILLER PIC X(32) VALUE "falling_anvil".
    05 FILLER PIC X(32) VALUE "falling_block".
    05 FILLER PIC X(32) VALUE "falling_stalactite".
    05 FILLER PIC X(32) VALUE "fireworks".
    05 FILLER PIC X(32) VALUE "lightning_bolt".
    05 FILLER PIC X(32) VALUE "mace_smash".
    05 FILLER PIC X(32) VALUE "mob_attack".
    05 FILLER PIC X(32) VALUE "mob_attack_no_aggro".
    05 FILLER PIC X(32) VALUE "mob_projectile".
    05 FILLER PIC X(32) VALUE "player_attack".
    05 FILLER PIC X(32) VALUE "spear".
    05 FILLER PIC X(32) VALUE "spit".
    05 FILLER PIC X(32) VALUE "sting".
    05 FILLER PIC X(32) VALUE "sweet_berry_bush".
    05 FILLER PIC X(32) VALUE "thorns".
    05 FILLER PIC X(32) VALUE "thrown".
    05 FILLER PIC X(32) VALUE "trident".
    05 FILLER PIC X(32) VALUE "wind_charge".
    05 FILLER PIC X(32) VALUE "wither_skull".
 01 TYPE-R REDEFINES TYPE-ROWS.
    05 TYPE-NAME PIC X(32) OCCURS 51 TIMES.
 01 TAG-NAMES.
    05 FILLER PIC X(32) VALUE "bypasses_armor".
    05 FILLER PIC X(32) VALUE "bypasses_effects".
    05 FILLER PIC X(32) VALUE "bypasses_enchantments".
    05 FILLER PIC X(32) VALUE "bypasses_resistance".
    05 FILLER PIC X(32) VALUE "bypasses_invulnerability".
    05 FILLER PIC X(32) VALUE "bypasses_cooldown".
    05 FILLER PIC X(32) VALUE "bypasses_shield".
    05 FILLER PIC X(32) VALUE "damages_helmet".
    05 FILLER PIC X(32) VALUE "is_fire".
    05 FILLER PIC X(32) VALUE "is_fall".
    05 FILLER PIC X(32) VALUE "is_drowning".
    05 FILLER PIC X(32) VALUE "is_freezing".
    05 FILLER PIC X(32) VALUE "is_lightning".
    05 FILLER PIC X(32) VALUE "is_explosion".
    05 FILLER PIC X(32) VALUE "is_projectile".
    05 FILLER PIC X(32) VALUE "is_player_attack".
    05 FILLER PIC X(32) VALUE "no_knockback".
    05 FILLER PIC X(32) VALUE "no_impact".
    05 FILLER PIC X(32) VALUE "no_anger".
    05 FILLER PIC X(32) VALUE "always_hurts_ender_dragons".
 01 TAG-R REDEFINES TAG-NAMES.
    05 TAG-NAME PIC X(32) OCCURS 20 TIMES.
 01 WS-KEY PIC X(48).
 01 WS-FOUND BINARY-LONG.
 01 WS-EX BINARY-LONG.
 01 WS-AL BINARY-LONG.
 01 WS-I BINARY-LONG.
 01 WS-T BINARY-LONG.
 01 WS-M BINARY-LONG.
 01 WS-FOUND-N BINARY-LONG.
 01 WS-EX-N BINARY-LONG.
 01 WS-AL-N BINARY-LONG.
 01 WS-EFFECTS PIC X(12).
 01 WS-MESSAGE PIC X(32).
 01 WS-BURN BINARY-LONG.
 01 WS-FALLV BINARY-LONG.
 01 WS-INT BINARY-LONG.
 01 WS-OTH BINARY-LONG.
 01 WS-TAGKEY PIC X(32).
 01 WS-COUNT BINARY-LONG.
 01 WS-E1 PIC -(9)9.
 01 WS-E2 PIC -(9)9.
 01 WS-E3 PIC -(9)9.
 01 WS-E4 PIC -(9)9.
 01 WS-OBS PIC X(300).
 PROCEDURE DIVISION.
     MOVE "acceptance US14 all 51 damage types are known, 32 have exhaustion 0.1 and 4 always scale with the difficulty; an unknown type is not found" TO TL-CASE
     MOVE 0 TO WS-FOUND-N WS-EX-N WS-AL-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         MOVE TYPE-NAME(WS-I) TO WS-KEY
         CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
         ADD WS-FOUND TO WS-FOUND-N
         IF WS-EX = 100
             ADD 1 TO WS-EX-N
         END-IF
         ADD WS-AL TO WS-AL-N
     END-PERFORM
     MOVE "nonexistent" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-FOUND-N TO WS-E1
     MOVE WS-EX-N TO WS-E2
     MOVE WS-AL-N TO WS-E3
     MOVE WS-FOUND TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "51 32 4 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 representative rows: fall 0 and conditional, sonic_boom 0 and always, explosion 0.1 and always, lava 0.1 and conditional, player_attack 0.1" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE "fall" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-EX TO WS-E1
     MOVE WS-AL TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "sonic_boom" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-EX TO WS-E1
     MOVE WS-AL TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "explosion" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-EX TO WS-E1
     MOVE WS-AL TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "lava" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-EX TO WS-E1
     MOVE WS-AL TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "player_attack" TO WS-KEY
     CALL "TOOL-DAMAGE-TYPE" USING WS-KEY WS-FOUND WS-EX WS-AL
     MOVE WS-EX TO WS-E1
     MOVE WS-AL TO WS-E2
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) "/" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0/0 0/1 100/1 100/0 100/0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 effects: 8 burning types, drown drowning, freeze freezing, sweet_berry_bush poking, thorns thorns; death messages fall_variants for fall and ender_pearl, intentional_game_design for bad_respawn_point" TO TL-CASE
     MOVE 0 TO WS-BURN WS-FALLV WS-INT WS-OTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         MOVE TYPE-NAME(WS-I) TO WS-KEY
         CALL "TOOL-DAMAGE-EFFECTS" USING WS-KEY WS-EFFECTS WS-MESSAGE
         IF WS-EFFECTS = "burning"
             ADD 1 TO WS-BURN
         END-IF
         IF WS-MESSAGE = "fall_variants"
             ADD 1 TO WS-FALLV
         END-IF
         IF WS-MESSAGE = "intentional_game_design"
             ADD 1 TO WS-INT
         END-IF
         IF WS-EFFECTS NOT = "-"
             ADD 1 TO WS-OTH
         END-IF
     END-PERFORM
     MOVE WS-BURN TO WS-E1
     MOVE WS-FALLV TO WS-E2
     MOVE WS-INT TO WS-E3
     MOVE WS-OTH TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "8 2 1 12" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 tag membership counts over the 51 types: bypasses_armor=19; bypasses_effects=1; bypasses_enchantments=1; bypasses_resistance=2; bypasses_invulnerability=2; bypasses_cooldown=0 and so on" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 20
         MOVE TAG-NAME(WS-T) TO WS-TAGKEY
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
             MOVE TYPE-NAME(WS-I) TO WS-KEY
             CALL "TOOL-DAMAGE-TAG" USING WS-KEY WS-TAGKEY WS-M
             ADD WS-M TO WS-COUNT
         END-PERFORM
         MOVE WS-COUNT TO WS-E1
         IF TL-OBSERVED = SPACES
             MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
         ELSE
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     END-PERFORM
     MOVE "19 1 1 2 2 0 30 3 8 3 1 1 1 4 8 3 30 1 1 4" TO TL-EXPECTED
     PERFORM CHECK-DONE

     MOVE "acceptance US14 an unknown tag has no member; a type outside a tag is not a member" TO TL-CASE
     MOVE "fall" TO WS-KEY
     MOVE "no_such_tag" TO WS-TAGKEY
     CALL "TOOL-DAMAGE-TAG" USING WS-KEY WS-TAGKEY WS-M
     MOVE WS-M TO WS-E1
     MOVE "arrow" TO WS-KEY
     MOVE "bypasses_armor" TO WS-TAGKEY
     CALL "TOOL-DAMAGE-TAG" USING WS-KEY WS-TAGKEY WS-M
     MOVE WS-M TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     PERFORM CHECK-DONE

     STOP RUN.

 CHECK-DONE.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TOOL-COMBAT-4-12.
