*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 1 (the renderer registry): the renderer class of each type of the 1.1 table, the three types that draw nothing (1.2 and Validation 1), the shadow radius and strength of 1.3
*> and the hitbox and eye height of each type of the 1.3 table; a type this document does not own is not known.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-KEY               PIC X(24).
 01 WS-CLASS             PIC X(40).
 PROCEDURE DIVISION.
     MOVE "minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "chest_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of chest_minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 chest_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 chest_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 chest_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 chest_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "furnace_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of furnace_minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 furnace_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 furnace_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 furnace_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 furnace_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hopper_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of hopper_minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 hopper_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 hopper_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 hopper_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 hopper_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "command_block_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of command_block_minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 command_block_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 command_block_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 command_block_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 command_block_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spawner_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of spawner_minecart" TO WS-NAME
     MOVE "MinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 spawner_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 spawner_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spawner_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spawner_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tnt_minecart" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of tnt_minecart" TO WS-NAME
     MOVE "TntMinecartRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 tnt_minecart draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 tnt_minecart shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt_minecart shadow radius" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt_minecart shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arrow" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of arrow" TO WS-NAME
     MOVE "TippableArrowRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 arrow draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 arrow shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 arrow shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 arrow shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spectral_arrow" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of spectral_arrow" TO WS-NAME
     MOVE "SpectralArrowRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 spectral_arrow draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 spectral_arrow shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spectral_arrow shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spectral_arrow shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "trident" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of trident" TO WS-NAME
     MOVE "ThrownTridentRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 trident draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 trident shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 trident shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 trident shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wind_charge" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of wind_charge" TO WS-NAME
     MOVE "WindChargeRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 wind_charge draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 wind_charge shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 wind_charge shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 wind_charge shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breeze_wind_charge" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of breeze_wind_charge" TO WS-NAME
     MOVE "WindChargeRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 breeze_wind_charge draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 breeze_wind_charge shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze_wind_charge shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze_wind_charge shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "snowball" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of snowball" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 snowball draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 snowball shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 snowball shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 snowball shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "egg" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of egg" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 egg draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 egg shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 egg shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 egg shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ender_pearl" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of ender_pearl" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 ender_pearl draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 ender_pearl shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ender_pearl shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ender_pearl shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "splash_potion" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of splash_potion" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 splash_potion draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 splash_potion shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 splash_potion shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 splash_potion shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "lingering_potion" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of lingering_potion" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 lingering_potion draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 lingering_potion shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lingering_potion shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lingering_potion shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "experience_bottle" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of experience_bottle" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 experience_bottle draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 experience_bottle shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_bottle shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_bottle shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eye_of_ender" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of eye_of_ender" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 eye_of_ender draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 eye_of_ender shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 eye_of_ender shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 eye_of_ender shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "fireball" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of fireball" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 fireball draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 fireball shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fireball shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fireball shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "small_fireball" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of small_fireball" TO WS-NAME
     MOVE "ThrownItemRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 small_fireball draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 small_fireball shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 small_fireball shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 small_fireball shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "firework_rocket" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of firework_rocket" TO WS-NAME
     MOVE "FireworkEntityRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 firework_rocket draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 firework_rocket shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 firework_rocket shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 firework_rocket shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "fishing_bobber" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of fishing_bobber" TO WS-NAME
     MOVE "FishingHookRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 fishing_bobber draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 fishing_bobber shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fishing_bobber shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fishing_bobber shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of item" TO WS-NAME
     MOVE "ItemEntityRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 item draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 item shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item shadow radius" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item shadow strength" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item_frame" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of item_frame" TO WS-NAME
     MOVE "ItemFrameRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 item_frame draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 item_frame shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_frame shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_frame shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "glow_item_frame" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of glow_item_frame" TO WS-NAME
     MOVE "ItemFrameRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 glow_item_frame draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 glow_item_frame shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_item_frame shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_item_frame shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "painting" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of painting" TO WS-NAME
     MOVE "PaintingRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 painting draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 painting shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 painting shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 painting shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "leash_knot" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of leash_knot" TO WS-NAME
     MOVE "LeashKnotRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 leash_knot draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 leash_knot shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 leash_knot shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 leash_knot shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "falling_block" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of falling_block" TO WS-NAME
     MOVE "FallingBlockRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 falling_block draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 falling_block shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 falling_block shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 falling_block shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tnt" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of tnt" TO WS-NAME
     MOVE "TntRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 tnt draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 tnt shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "experience_orb" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of experience_orb" TO WS-NAME
     MOVE "ExperienceOrbRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 experience_orb draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 experience_orb shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_orb shadow radius" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_orb shadow strength" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "lightning_bolt" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of lightning_bolt" TO WS-NAME
     MOVE "LightningBoltRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 lightning_bolt draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 lightning_bolt shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lightning_bolt shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lightning_bolt shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ominous_item_spawner" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of ominous_item_spawner" TO WS-NAME
     MOVE "OminousItemSpawnerRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 ominous_item_spawner draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 ominous_item_spawner shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ominous_item_spawner shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ominous_item_spawner shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cushion" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of cushion" TO WS-NAME
     MOVE "CushionRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 cushion draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 cushion shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cushion shadow radius" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cushion shadow strength" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block_display" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of block_display" TO WS-NAME
     MOVE "DisplayRenderer$BlockDisplayRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 block_display draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 block_display shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 block_display shadow radius" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 block_display shadow strength" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item_display" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of item_display" TO WS-NAME
     MOVE "$ItemDisplayRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 item_display draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 item_display shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_display shadow radius" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_display shadow strength" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "text_display" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of text_display" TO WS-NAME
     MOVE "$TextDisplayRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 text_display draws nothing" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 text_display shadow known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 text_display shadow radius" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 text_display shadow strength" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "area_effect_cloud" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of area_effect_cloud" TO WS-NAME
     MOVE "NoopRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 area_effect_cloud draws nothing" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "interaction" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of interaction" TO WS-NAME
     MOVE "NoopRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 interaction draws nothing" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "marker" TO WS-KEY
     MOVE SPACES TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 renderer of marker" TO WS-NAME
     MOVE "NoopRenderer" TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-NOOP" USING WS-KEY WS-OUT
     MOVE "1.2 marker draws nothing" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "chest_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 chest_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 chest_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 chest_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 chest_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "furnace_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 furnace_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 furnace_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 furnace_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 furnace_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hopper_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 hopper_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 hopper_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 hopper_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 hopper_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tnt_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 tnt_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spawner_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 spawner_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spawner_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spawner_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spawner_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "command_block_minecart" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 command_block_minecart hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 command_block_minecart width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 command_block_minecart height" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 command_block_minecart eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arrow" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 arrow hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 arrow width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 arrow height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 arrow eye height (-1 none)" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spectral_arrow" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 spectral_arrow hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spectral_arrow width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spectral_arrow height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spectral_arrow eye height (-1 none)" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "trident" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 trident hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 trident width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 trident height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 trident eye height (-1 none)" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wind_charge" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 wind_charge hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 wind_charge width" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 wind_charge height" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 wind_charge eye height (-1 none)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breeze_wind_charge" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 breeze_wind_charge hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze_wind_charge width" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze_wind_charge height" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze_wind_charge eye height (-1 none)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "snowball" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 snowball hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 snowball width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 snowball height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 snowball eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "egg" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 egg hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 egg width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 egg height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 egg eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ender_pearl" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 ender_pearl hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ender_pearl width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ender_pearl height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ender_pearl eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "splash_potion" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 splash_potion hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 splash_potion width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 splash_potion height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 splash_potion eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "lingering_potion" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 lingering_potion hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lingering_potion width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lingering_potion height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lingering_potion eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "experience_bottle" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 experience_bottle hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_bottle width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_bottle height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_bottle eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "eye_of_ender" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 eye_of_ender hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 eye_of_ender width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 eye_of_ender height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 eye_of_ender eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "firework_rocket" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 firework_rocket hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 firework_rocket width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 firework_rocket height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 firework_rocket eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "fishing_bobber" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 fishing_bobber hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fishing_bobber width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fishing_bobber height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fishing_bobber eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ominous_item_spawner" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 ominous_item_spawner hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ominous_item_spawner width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ominous_item_spawner height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 ominous_item_spawner eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "fireball" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 fireball hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fireball width" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fireball height" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 fireball eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "small_fireball" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 small_fireball hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 small_fireball width" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 small_fireball height" TO WS-NAME
     MOVE 0.3125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 small_fireball eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 item hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item width" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item height" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item eye height (-1 none)" TO WS-NAME
     MOVE 0.2125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item_frame" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 item_frame hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_frame width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_frame height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_frame eye height (-1 none)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "glow_item_frame" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 glow_item_frame hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_item_frame width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_item_frame height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 glow_item_frame eye height (-1 none)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "painting" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 painting hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 painting width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 painting height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 painting eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "leash_knot" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 leash_knot hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 leash_knot width" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 leash_knot height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 leash_knot eye height (-1 none)" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "falling_block" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 falling_block hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 falling_block width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 falling_block height" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 falling_block eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tnt" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 tnt hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt width" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt height" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 tnt eye height (-1 none)" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "experience_orb" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 experience_orb hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_orb width" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_orb height" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 experience_orb eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "lightning_bolt" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 lightning_bolt hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lightning_bolt width" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lightning_bolt height" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 lightning_bolt eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "block_display" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 block_display hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 block_display width" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 block_display height" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 block_display eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "item_display" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 item_display hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_display width" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_display height" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 item_display eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "text_display" TO WS-KEY
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 text_display hitbox known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 text_display width" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 text_display height" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 text_display eye height (-1 none)" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-KEY
     MOVE "x" TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 pig is not a type of this document" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 pig has no hitbox here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 pig has no shadow here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "boat" TO WS-KEY
     MOVE "x" TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 boat is not a type of this document" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 boat has no hitbox here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 boat has no shadow here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie" TO WS-KEY
     MOVE "x" TO WS-CLASS
     CALL "EF9-RENDERER" USING WS-KEY WS-CLASS
     MOVE "1.1 zombie is not a type of this document" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-CLASS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF9-HITBOX" USING WS-KEY WS-OUT
     MOVE "1.3 zombie has no hitbox here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SHADOW" USING WS-KEY WS-OUT
     MOVE "1.3 zombie has no shadow here" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§1: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§1: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-1.
