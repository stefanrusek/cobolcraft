*> Entity models part 9, section 1 the renderer registry (docs/protocol/34-entity-models-9-non-living-entities.md; written by client/tests/gen/s9_1.py from the tables of 1.1 and 1.3):
*>   EF9-RENDERER key(X(24)) class(out X(40), spaces for a type this document does not own);
*>   EF9-NOOP key(X(24)) OUT(1 1 when the renderer draws nothing (area_effect_cloud, interaction, marker));
*>   EF9-SHADOW key(X(24)) OUT(1 known, 2 shadow radius, 3 shadow strength; radius -1 = from the render state, 17.1);
*>   EF9-HITBOX key(X(24)) OUT(1 known, 2 width, 3 height, 4 eye height or -1 when the type has no eyeHeight call).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-RENDERER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-CLASS                PIC X(40).
 PROCEDURE DIVISION USING L-KEY L-CLASS.
     MOVE SPACES TO L-CLASS
     EVALUATE L-KEY
         WHEN "minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "chest_minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "furnace_minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "hopper_minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "command_block_minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "spawner_minecart"
             MOVE "MinecartRenderer" TO L-CLASS
         WHEN "tnt_minecart"
             MOVE "TntMinecartRenderer" TO L-CLASS
         WHEN "arrow"
             MOVE "TippableArrowRenderer" TO L-CLASS
         WHEN "spectral_arrow"
             MOVE "SpectralArrowRenderer" TO L-CLASS
         WHEN "trident"
             MOVE "ThrownTridentRenderer" TO L-CLASS
         WHEN "wind_charge"
             MOVE "WindChargeRenderer" TO L-CLASS
         WHEN "breeze_wind_charge"
             MOVE "WindChargeRenderer" TO L-CLASS
         WHEN "snowball"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "egg"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "ender_pearl"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "splash_potion"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "lingering_potion"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "experience_bottle"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "eye_of_ender"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "fireball"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "small_fireball"
             MOVE "ThrownItemRenderer" TO L-CLASS
         WHEN "firework_rocket"
             MOVE "FireworkEntityRenderer" TO L-CLASS
         WHEN "fishing_bobber"
             MOVE "FishingHookRenderer" TO L-CLASS
         WHEN "item"
             MOVE "ItemEntityRenderer" TO L-CLASS
         WHEN "item_frame"
             MOVE "ItemFrameRenderer" TO L-CLASS
         WHEN "glow_item_frame"
             MOVE "ItemFrameRenderer" TO L-CLASS
         WHEN "painting"
             MOVE "PaintingRenderer" TO L-CLASS
         WHEN "leash_knot"
             MOVE "LeashKnotRenderer" TO L-CLASS
         WHEN "falling_block"
             MOVE "FallingBlockRenderer" TO L-CLASS
         WHEN "tnt"
             MOVE "TntRenderer" TO L-CLASS
         WHEN "experience_orb"
             MOVE "ExperienceOrbRenderer" TO L-CLASS
         WHEN "lightning_bolt"
             MOVE "LightningBoltRenderer" TO L-CLASS
         WHEN "ominous_item_spawner"
             MOVE "OminousItemSpawnerRenderer" TO L-CLASS
         WHEN "cushion"
             MOVE "CushionRenderer" TO L-CLASS
         WHEN "block_display"
             MOVE "DisplayRenderer$BlockDisplayRenderer" TO L-CLASS
         WHEN "item_display"
             MOVE "$ItemDisplayRenderer" TO L-CLASS
         WHEN "text_display"
             MOVE "$TextDisplayRenderer" TO L-CLASS
         WHEN "area_effect_cloud"
             MOVE "NoopRenderer" TO L-CLASS
         WHEN "interaction"
             MOVE "NoopRenderer" TO L-CLASS
         WHEN "marker"
             MOVE "NoopRenderer" TO L-CLASS
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-RENDERER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-NOOP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-KEY
         WHEN "area_effect_cloud"
         WHEN "interaction"
         WHEN "marker"
             MOVE 1 TO L-O(1)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-NOOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 0 TO L-O(1)
     MOVE 0 TO L-O(2)
     MOVE 1 TO L-O(3)
     EVALUATE L-KEY
         WHEN "minecart"
         WHEN "chest_minecart"
         WHEN "furnace_minecart"
         WHEN "hopper_minecart"
         WHEN "command_block_minecart"
         WHEN "spawner_minecart"
         WHEN "tnt_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.7 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "arrow"
         WHEN "spectral_arrow"
         WHEN "trident"
         WHEN "wind_charge"
         WHEN "breeze_wind_charge"
         WHEN "snowball"
         WHEN "egg"
         WHEN "ender_pearl"
         WHEN "splash_potion"
         WHEN "lingering_potion"
         WHEN "experience_bottle"
         WHEN "eye_of_ender"
         WHEN "fireball"
         WHEN "small_fireball"
         WHEN "firework_rocket"
         WHEN "fishing_bobber"
         WHEN "item_frame"
         WHEN "glow_item_frame"
         WHEN "painting"
         WHEN "leash_knot"
         WHEN "lightning_bolt"
         WHEN "ominous_item_spawner"
         WHEN "cushion"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "item"
         WHEN "experience_orb"
             MOVE 1 TO L-O(1)
             MOVE 0.15 TO L-O(2)
             MOVE 0.75 TO L-O(3)
         WHEN "falling_block"
         WHEN "tnt"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "block_display"
         WHEN "item_display"
         WHEN "text_display"
             MOVE 1 TO L-O(1)
             MOVE -1 TO L-O(2)
             MOVE -1 TO L-O(3)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HITBOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)
     EVALUATE L-KEY
         WHEN "minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "chest_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "furnace_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "hopper_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "tnt_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "spawner_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "command_block_minecart"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.7 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "arrow"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0.13 TO L-O(4)
         WHEN "spectral_arrow"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0.13 TO L-O(4)
         WHEN "trident"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0.13 TO L-O(4)
         WHEN "wind_charge"
             MOVE 1 TO L-O(1)
             MOVE 0.3125 TO L-O(2)
             MOVE 0.3125 TO L-O(3)
             MOVE 0 TO L-O(4)
         WHEN "breeze_wind_charge"
             MOVE 1 TO L-O(1)
             MOVE 0.3125 TO L-O(2)
             MOVE 0.3125 TO L-O(3)
             MOVE 0 TO L-O(4)
         WHEN "snowball"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "egg"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "ender_pearl"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "splash_potion"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "lingering_potion"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "experience_bottle"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "eye_of_ender"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "firework_rocket"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "fishing_bobber"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "ominous_item_spawner"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "fireball"
             MOVE 1 TO L-O(1)
             MOVE 1 TO L-O(2)
             MOVE 1 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "small_fireball"
             MOVE 1 TO L-O(1)
             MOVE 0.3125 TO L-O(2)
             MOVE 0.3125 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "item"
             MOVE 1 TO L-O(1)
             MOVE 0.25 TO L-O(2)
             MOVE 0.25 TO L-O(3)
             MOVE 0.2125 TO L-O(4)
         WHEN "item_frame"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0 TO L-O(4)
         WHEN "glow_item_frame"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0 TO L-O(4)
         WHEN "painting"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "leash_knot"
             MOVE 1 TO L-O(1)
             MOVE 0.375 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE 0.0625 TO L-O(4)
         WHEN "falling_block"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.98 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "tnt"
             MOVE 1 TO L-O(1)
             MOVE 0.98 TO L-O(2)
             MOVE 0.98 TO L-O(3)
             MOVE 0.15 TO L-O(4)
         WHEN "experience_orb"
             MOVE 1 TO L-O(1)
             MOVE 0.5 TO L-O(2)
             MOVE 0.5 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "lightning_bolt"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "block_display"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "item_display"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN "text_display"
             MOVE 1 TO L-O(1)
             MOVE 0 TO L-O(2)
             MOVE 0 TO L-O(3)
             MOVE -1 TO L-O(4)
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-HITBOX.
