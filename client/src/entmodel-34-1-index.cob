*> Entity models part 1 sections 9 and 10 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the per-entity record schema (9) and the master
*> index of the 161 entity types (10).
*>   EM9-FIELD-COUNT n; EM9-FIELD-NAME index(1..19) name(X(24), spaces past the end; the hitbox and eye_height row is hitbox_eye_height);
*>   EM9-BABY-RULE name(X(24)) code (1 none, 2 separate_model, 3 transform, 4 shared_model_scaled, 0 unknown);
*>   EM9-RECORD-CHECK registry-name(X(40) with namespace) numeric-id baby-rule(X(24)) layer-id(X(60)) ok (1 valid): id 0..160, a rule of the four, a
*>   registered layer id (EM4-LAYER-FIND).
*>   EM10-COUNT n; EM10-ROW id(0..160) key(X(32)) renderer(X(150)) part(2..9; 0 and spaces past the end); EM10-FIND key id(-1 unknown);
*>   EM10-PART-COUNT part n (entity types the part 2..9 documents).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM9-FIELD-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N.
     MOVE 19 TO L-N
     GOBACK.
 END PROGRAM EM9-FIELD-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM9-FIELD-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FIELDS.
    05 FILLER PIC X(24) VALUE "registry_name".
    05 FILLER PIC X(24) VALUE "numeric_id".
    05 FILLER PIC X(24) VALUE "renderer".
    05 FILLER PIC X(24) VALUE "state_class".
    05 FILLER PIC X(24) VALUE "model_layers".
    05 FILLER PIC X(24) VALUE "texture_ids".
    05 FILLER PIC X(24) VALUE "shadow_radius".
    05 FILLER PIC X(24) VALUE "shadow_strength".
    05 FILLER PIC X(24) VALUE "name_tag_offset".
    05 FILLER PIC X(24) VALUE "hitbox_eye_height".
    05 FILLER PIC X(24) VALUE "baby_rule".
    05 FILLER PIC X(24) VALUE "layers".
    05 FILLER PIC X(24) VALUE "model_class".
    05 FILLER PIC X(24) VALUE "parts".
    05 FILLER PIC X(24) VALUE "animation".
    05 FILLER PIC X(24) VALUE "render_state_fields".
    05 FILLER PIC X(24) VALUE "render_type".
    05 FILLER PIC X(24) VALUE "scale_hooks".
    05 FILLER PIC X(24) VALUE "ids".
 01 WS-FIELDS-R REDEFINES WS-FIELDS.
    05 WS-FIELD            PIC X(24) OCCURS 19 TIMES.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-INDEX L-NAME.
     MOVE SPACES TO L-NAME
     IF L-INDEX >= 1 AND L-INDEX <= 19
         MOVE WS-FIELD(L-INDEX) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM EM9-FIELD-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM9-BABY-RULE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-CODE.
     EVALUATE L-NAME
         WHEN "none" MOVE 1 TO L-CODE
         WHEN "separate_model" MOVE 2 TO L-CODE
         WHEN "transform" MOVE 3 TO L-CODE
         WHEN "shared_model_scaled" MOVE 4 TO L-CODE
         WHEN OTHER MOVE 0 TO L-CODE
     END-EVALUATE
     GOBACK.
 END PROGRAM EM9-BABY-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM9-RECORD-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CODE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 01 L-RULE                 PIC X(24).
 01 L-LAYER                PIC X(60).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-RULE L-LAYER L-OK.
     MOVE 1 TO L-OK
     IF L-NAME(1:10) NOT = "minecraft:"
         MOVE 0 TO L-OK
     END-IF
     IF L-ID < 0 OR L-ID > 160
         MOVE 0 TO L-OK
     END-IF
     CALL "EM9-BABY-RULE" USING L-RULE WS-CODE
     IF WS-CODE = 0
         MOVE 0 TO L-OK
     END-IF
     CALL "EM4-LAYER-FIND" USING L-LAYER WS-INDEX
     IF WS-INDEX = 0
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM EM9-RECORD-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM10-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(179) VALUE "acacia_boat                 BoatRenderer(ML.ACACIA_BOAT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "acacia_chest_boat           BoatRenderer(ML.ACACIA_CHEST_BOAT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "allay                       AllayRenderer                                                                                                                                         3".
    05 FILLER PIC X(179) VALUE "area_effect_cloud           NoopRenderer                                                                                                                                          9".
    05 FILLER PIC X(179) VALUE "armadillo                   ArmadilloRenderer                                                                                                                                     5".
    05 FILLER PIC X(179) VALUE "armor_stand                 ArmorStandRenderer                                                                                                                                    2".
    05 FILLER PIC X(179) VALUE "arrow                       TippableArrowRenderer                                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "axolotl                     AxolotlRenderer                                                                                                                                       8".
    05 FILLER PIC X(179) VALUE "bamboo_chest_raft           RaftRenderer(ML.BAMBOO_CHEST_RAFT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "bamboo_raft                 RaftRenderer(ML.BAMBOO_RAFT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "bat                         BatRenderer                                                                                                                                           5".
    05 FILLER PIC X(179) VALUE "bee                         BeeRenderer                                                                                                                                           5".
    05 FILLER PIC X(179) VALUE "birch_boat                  BoatRenderer(ML.BIRCH_BOAT)                                                                                                                           8".
    05 FILLER PIC X(179) VALUE "birch_chest_boat            BoatRenderer(ML.BIRCH_CHEST_BOAT)                                                                                                                     8".
    05 FILLER PIC X(179) VALUE "blaze                       BlazeRenderer                                                                                                                                         7".
    05 FILLER PIC X(179) VALUE "block_display               DisplayRenderer.BlockDisplayRenderer                                                                                                                  9".
    05 FILLER PIC X(179) VALUE "bogged                      BoggedRenderer                                                                                                                                        2".
    05 FILLER PIC X(179) VALUE "breeze                      BreezeRenderer                                                                                                                                        6".
    05 FILLER PIC X(179) VALUE "breeze_wind_charge          WindChargeRenderer                                                                                                                                    9".
    05 FILLER PIC X(179) VALUE "camel                       CamelRenderer                                                                                                                                         4".
    05 FILLER PIC X(179) VALUE "camel_husk                  CamelHuskRenderer                                                                                                                                     4".
    05 FILLER PIC X(179) VALUE "cat                         CatRenderer                                                                                                                                           5".
    05 FILLER PIC X(179) VALUE "cave_spider                 CaveSpiderRenderer                                                                                                                                    6".
    05 FILLER PIC X(179) VALUE "cherry_boat                 BoatRenderer(ML.CHERRY_BOAT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "cherry_chest_boat           BoatRenderer(ML.CHERRY_CHEST_BOAT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "chest_minecart              MinecartRenderer(ML.CHEST_MINECART)                                                                                                                   9".
    05 FILLER PIC X(179) VALUE "chicken                     ChickenRenderer                                                                                                                                       4".
    05 FILLER PIC X(179) VALUE "cod                         CodRenderer                                                                                                                                           8".
    05 FILLER PIC X(179) VALUE "copper_golem                CopperGolemRenderer                                                                                                                                   3".
    05 FILLER PIC X(179) VALUE "command_block_minecart      MinecartRenderer(ML.COMMAND_BLOCK_MINECART)                                                                                                           9".
    05 FILLER PIC X(179) VALUE "cow                         CowRenderer                                                                                                                                           4".
    05 FILLER PIC X(179) VALUE "creaking                    CreakingRenderer                                                                                                                                      3".
    05 FILLER PIC X(179) VALUE "creeper                     CreeperRenderer                                                                                                                                       6".
    05 FILLER PIC X(179) VALUE "cushion                     CushionRenderer                                                                                                                                       9".
    05 FILLER PIC X(179) VALUE "dark_oak_boat               BoatRenderer(ML.DARK_OAK_BOAT)                                                                                                                        8".
    05 FILLER PIC X(179) VALUE "dark_oak_chest_boat         BoatRenderer(ML.DARK_OAK_CHEST_BOAT)                                                                                                                  8".
    05 FILLER PIC X(179) VALUE "dolphin                     DolphinRenderer                                                                                                                                       8".
    05 FILLER PIC X(179) VALUE "donkey                      DonkeyRenderer(LT.DONKEY_SADDLE, ML.DONKEY_SADDLE, DonkeyRenderer.Type.DONKEY, DonkeyRenderer.Type.DONKEY_BABY)                                       4".
    05 FILLER PIC X(179) VALUE "dragon_fireball             DragonFireballRenderer                                                                                                                                7".
    05 FILLER PIC X(179) VALUE "drowned                     DrownedRenderer                                                                                                                                       2".
    05 FILLER PIC X(179) VALUE "egg                         ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "elder_guardian              ElderGuardianRenderer                                                                                                                                 6".
    05 FILLER PIC X(179) VALUE "enderman                    EndermanRenderer                                                                                                                                      6".
    05 FILLER PIC X(179) VALUE "endermite                   EndermiteRenderer                                                                                                                                     6".
    05 FILLER PIC X(179) VALUE "ender_dragon                EnderDragonRenderer                                                                                                                                   7".
    05 FILLER PIC X(179) VALUE "ender_pearl                 ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "end_crystal                 EndCrystalRenderer                                                                                                                                    7".
    05 FILLER PIC X(179) VALUE "evoker                      EvokerRenderer                                                                                                                                        3".
    05 FILLER PIC X(179) VALUE "evoker_fangs                EvokerFangsRenderer                                                                                                                                   3".
    05 FILLER PIC X(179) VALUE "experience_bottle           ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "experience_orb              ExperienceOrbRenderer                                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "eye_of_ender                ThrownItemRenderer(1.0, true)                                                                                                                         9".
    05 FILLER PIC X(179) VALUE "falling_block               FallingBlockRenderer                                                                                                                                  9".
    05 FILLER PIC X(179) VALUE "fireball                    ThrownItemRenderer(3.0, true)                                                                                                                         9".
    05 FILLER PIC X(179) VALUE "firework_rocket             FireworkEntityRenderer                                                                                                                                9".
    05 FILLER PIC X(179) VALUE "fox                         FoxRenderer                                                                                                                                           5".
    05 FILLER PIC X(179) VALUE "frog                        FrogRenderer                                                                                                                                          5".
    05 FILLER PIC X(179) VALUE "furnace_minecart            MinecartRenderer(ML.FURNACE_MINECART)                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "ghast                       GhastRenderer                                                                                                                                         7".
    05 FILLER PIC X(179) VALUE "happy_ghast                 HappyGhastRenderer                                                                                                                                    4".
    05 FILLER PIC X(179) VALUE "giant                       GiantMobRenderer(6.0f)                                                                                                                                2".
    05 FILLER PIC X(179) VALUE "glow_item_frame             ItemFrameRenderer                                                                                                                                     9".
    05 FILLER PIC X(179) VALUE "glow_squid                  GlowSquidRenderer(ML.GLOW_SQUID, ML.GLOW_SQUID_BABY)                                                                                                  8".
    05 FILLER PIC X(179) VALUE "goat                        GoatRenderer                                                                                                                                          4".
    05 FILLER PIC X(179) VALUE "guardian                    GuardianRenderer                                                                                                                                      6".
    05 FILLER PIC X(179) VALUE "hoglin                      HoglinRenderer                                                                                                                                        7".
    05 FILLER PIC X(179) VALUE "hopper_minecart             MinecartRenderer(ML.HOPPER_MINECART)                                                                                                                  9".
    05 FILLER PIC X(179) VALUE "horse                       HorseRenderer                                                                                                                                         4".
    05 FILLER PIC X(179) VALUE "husk                        HuskRenderer                                                                                                                                          2".
    05 FILLER PIC X(179) VALUE "illusioner                  IllusionerRenderer                                                                                                                                    3".
    05 FILLER PIC X(179) VALUE "interaction                 NoopRenderer                                                                                                                                          9".
    05 FILLER PIC X(179) VALUE "iron_golem                  IronGolemRenderer                                                                                                                                     3".
    05 FILLER PIC X(179) VALUE "item                        ItemEntityRenderer                                                                                                                                    9".
    05 FILLER PIC X(179) VALUE "item_display                DisplayRenderer.ItemDisplayRenderer                                                                                                                   9".
    05 FILLER PIC X(179) VALUE "item_frame                  ItemFrameRenderer                                                                                                                                     9".
    05 FILLER PIC X(179) VALUE "jungle_boat                 BoatRenderer(ML.JUNGLE_BOAT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "jungle_chest_boat           BoatRenderer(ML.JUNGLE_CHEST_BOAT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "leash_knot                  LeashKnotRenderer                                                                                                                                     9".
    05 FILLER PIC X(179) VALUE "lightning_bolt              LightningBoltRenderer                                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "llama                       LlamaRenderer(ML.LLAMA, ML.LLAMA_BABY)                                                                                                                4".
    05 FILLER PIC X(179) VALUE "llama_spit                  LlamaSpitRenderer                                                                                                                                     4".
    05 FILLER PIC X(179) VALUE "magma_cube                  MagmaCubeRenderer                                                                                                                                     6".
    05 FILLER PIC X(179) VALUE "mangrove_boat               BoatRenderer(ML.MANGROVE_BOAT)                                                                                                                        8".
    05 FILLER PIC X(179) VALUE "mangrove_chest_boat         BoatRenderer(ML.MANGROVE_CHEST_BOAT)                                                                                                                  8".
    05 FILLER PIC X(179) VALUE "mannequin                   AvatarRenderer (WIDE / SLIM; mannequin map; 12 §7)                                                                                                   9".
    05 FILLER PIC X(179) VALUE "marker                      NoopRenderer                                                                                                                                          9".
    05 FILLER PIC X(179) VALUE "minecart                    MinecartRenderer(ML.MINECART)                                                                                                                         9".
    05 FILLER PIC X(179) VALUE "mooshroom                   MushroomCowRenderer                                                                                                                                   4".
    05 FILLER PIC X(179) VALUE "mule                        DonkeyRenderer(LT.MULE_SADDLE, ML.MULE_SADDLE, DonkeyRenderer.Type.MULE, DonkeyRenderer.Type.MULE_BABY)                                               4".
    05 FILLER PIC X(179) VALUE "nautilus                    NautilusRenderer                                                                                                                                      8".
    05 FILLER PIC X(179) VALUE "oak_boat                    BoatRenderer(ML.OAK_BOAT)                                                                                                                             8".
    05 FILLER PIC X(179) VALUE "oak_chest_boat              BoatRenderer(ML.OAK_CHEST_BOAT)                                                                                                                       8".
    05 FILLER PIC X(179) VALUE "ocelot                      OcelotRenderer                                                                                                                                        5".
    05 FILLER PIC X(179) VALUE "ominous_item_spawner        OminousItemSpawnerRenderer                                                                                                                            9".
    05 FILLER PIC X(179) VALUE "painting                    PaintingRenderer                                                                                                                                      9".
    05 FILLER PIC X(179) VALUE "pale_oak_boat               BoatRenderer(ML.PALE_OAK_BOAT)                                                                                                                        8".
    05 FILLER PIC X(179) VALUE "pale_oak_chest_boat         BoatRenderer(ML.PALE_OAK_CHEST_BOAT)                                                                                                                  8".
    05 FILLER PIC X(179) VALUE "panda                       PandaRenderer                                                                                                                                         5".
    05 FILLER PIC X(179) VALUE "parched                     ParchedRenderer                                                                                                                                       2".
    05 FILLER PIC X(179) VALUE "parrot                      ParrotRenderer                                                                                                                                        5".
    05 FILLER PIC X(179) VALUE "phantom                     PhantomRenderer                                                                                                                                       6".
    05 FILLER PIC X(179) VALUE "pig                         PigRenderer                                                                                                                                           4".
    05 FILLER PIC X(179) VALUE "piglin                      PiglinRenderer(ML.PIGLIN, ML.PIGLIN_BABY, ML.PIGLIN_ARMOR, ML.PIGLIN_BABY_ARMOR)                                                                      2".
    05 FILLER PIC X(179) VALUE "piglin_brute                PiglinRenderer(ML.PIGLIN_BRUTE, ML.PIGLIN_BRUTE, ML.PIGLIN_BRUTE_ARMOR, ML.PIGLIN_BRUTE_ARMOR)                                                        2".
    05 FILLER PIC X(179) VALUE "pillager                    PillagerRenderer                                                                                                                                      3".
    05 FILLER PIC X(179) VALUE "polar_bear                  PolarBearRenderer                                                                                                                                     5".
    05 FILLER PIC X(179) VALUE "poplar_boat                 BoatRenderer(ML.POPLAR_BOAT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "poplar_chest_boat           BoatRenderer(ML.POPLAR_CHEST_BOAT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "splash_potion               ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "lingering_potion            ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "pufferfish                  PufferfishRenderer                                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "rabbit                      RabbitRenderer                                                                                                                                        4".
    05 FILLER PIC X(179) VALUE "ravager                     RavagerRenderer                                                                                                                                       3".
    05 FILLER PIC X(179) VALUE "salmon                      SalmonRenderer                                                                                                                                        8".
    05 FILLER PIC X(179) VALUE "sheep                       SheepRenderer                                                                                                                                         4".
    05 FILLER PIC X(179) VALUE "shulker                     ShulkerRenderer                                                                                                                                       6".
    05 FILLER PIC X(179) VALUE "shulker_bullet              ShulkerBulletRenderer                                                                                                                                 6".
    05 FILLER PIC X(179) VALUE "silverfish                  SilverfishRenderer                                                                                                                                    6".
    05 FILLER PIC X(179) VALUE "skeleton                    SkeletonRenderer                                                                                                                                      2".
    05 FILLER PIC X(179) VALUE "skeleton_horse              UndeadHorseRenderer(LT.SKELETON_HORSE_SADDLE, ML.SKELETON_HORSE_SADDLE, UndeadHorseRenderer.Type.SKELETON, UndeadHorseRenderer.Type.SKELETON_BABY)    4".
    05 FILLER PIC X(179) VALUE "slime                       SlimeRenderer                                                                                                                                         6".
    05 FILLER PIC X(179) VALUE "small_fireball              ThrownItemRenderer(0.75, true)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "sniffer                     SnifferRenderer                                                                                                                                       5".
    05 FILLER PIC X(179) VALUE "snowball                    ThrownItemRenderer(1.0, false)                                                                                                                        9".
    05 FILLER PIC X(179) VALUE "snow_golem                  SnowGolemRenderer                                                                                                                                     3".
    05 FILLER PIC X(179) VALUE "spawner_minecart            MinecartRenderer(ML.SPAWNER_MINECART)                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "spectral_arrow              SpectralArrowRenderer                                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "spider                      SpiderRenderer                                                                                                                                        6".
    05 FILLER PIC X(179) VALUE "spruce_boat                 BoatRenderer(ML.SPRUCE_BOAT)                                                                                                                          8".
    05 FILLER PIC X(179) VALUE "spruce_chest_boat           BoatRenderer(ML.SPRUCE_CHEST_BOAT)                                                                                                                    8".
    05 FILLER PIC X(179) VALUE "squid                       SquidRenderer(ML.SQUID, ML.SQUID_BABY)                                                                                                                8".
    05 FILLER PIC X(179) VALUE "stray                       StrayRenderer                                                                                                                                         2".
    05 FILLER PIC X(179) VALUE "strider                     StriderRenderer                                                                                                                                       7".
    05 FILLER PIC X(179) VALUE "sulfur_cube                 SulfurCubeRenderer                                                                                                                                    6".
    05 FILLER PIC X(179) VALUE "tadpole                     TadpoleRenderer                                                                                                                                       5".
    05 FILLER PIC X(179) VALUE "text_display                DisplayRenderer.TextDisplayRenderer                                                                                                                   9".
    05 FILLER PIC X(179) VALUE "tnt                         TntRenderer                                                                                                                                           9".
    05 FILLER PIC X(179) VALUE "tnt_minecart                TntMinecartRenderer                                                                                                                                   9".
    05 FILLER PIC X(179) VALUE "trader_llama                LlamaRenderer(ML.TRADER_LLAMA, ML.TRADER_LLAMA_BABY)                                                                                                  4".
    05 FILLER PIC X(179) VALUE "trident                     ThrownTridentRenderer                                                                                                                                 9".
    05 FILLER PIC X(179) VALUE "tropical_fish               TropicalFishRenderer                                                                                                                                  8".
    05 FILLER PIC X(179) VALUE "turtle                      TurtleRenderer                                                                                                                                        5".
    05 FILLER PIC X(179) VALUE "vex                         VexRenderer                                                                                                                                           3".
    05 FILLER PIC X(179) VALUE "villager                    VillagerRenderer                                                                                                                                      3".
    05 FILLER PIC X(179) VALUE "vindicator                  VindicatorRenderer                                                                                                                                    3".
    05 FILLER PIC X(179) VALUE "wandering_trader            WanderingTraderRenderer                                                                                                                               3".
    05 FILLER PIC X(179) VALUE "warden                      WardenRenderer                                                                                                                                        6".
    05 FILLER PIC X(179) VALUE "wind_charge                 WindChargeRenderer                                                                                                                                    9".
    05 FILLER PIC X(179) VALUE "witch                       WitchRenderer                                                                                                                                         3".
    05 FILLER PIC X(179) VALUE "wither                      WitherBossRenderer                                                                                                                                    7".
    05 FILLER PIC X(179) VALUE "wither_skeleton             WitherSkeletonRenderer                                                                                                                                2".
    05 FILLER PIC X(179) VALUE "wither_skull                WitherSkullRenderer                                                                                                                                   7".
    05 FILLER PIC X(179) VALUE "wolf                        WolfRenderer                                                                                                                                          5".
    05 FILLER PIC X(179) VALUE "zoglin                      ZoglinRenderer                                                                                                                                        7".
    05 FILLER PIC X(179) VALUE "zombie                      ZombieRenderer                                                                                                                                        2".
    05 FILLER PIC X(179) VALUE "zombie_horse                UndeadHorseRenderer(LT.ZOMBIE_HORSE_SADDLE, ML.ZOMBIE_HORSE_SADDLE, UndeadHorseRenderer.Type.ZOMBIE, UndeadHorseRenderer.Type.ZOMBIE_BABY)            4".
    05 FILLER PIC X(179) VALUE "zombie_nautilus             ZombieNautilusRenderer                                                                                                                                8".
    05 FILLER PIC X(179) VALUE "zombie_villager             ZombieVillagerRenderer                                                                                                                                3".
    05 FILLER PIC X(179) VALUE "zombified_piglin            ZombifiedPiglinRenderer(ML.ZOMBIFIED_PIGLIN, ML.ZOMBIFIED_PIGLIN_BABY, ML.ZOMBIFIED_PIGLIN_ARMOR, ML.ZOMBIFIED_PIGLIN_BABY_ARMOR)                     2".
    05 FILLER PIC X(179) VALUE "player                      AvatarRenderer (WIDE / SLIM; 12 §7)                                                                                                                  9".
    05 FILLER PIC X(179) VALUE "fishing_bobber              FishingHookRenderer                                                                                                                                   9".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 161 TIMES.
       10 WS-KEY           PIC X(28).
       10 WS-RENDERER      PIC X(150).
       10 WS-PART          PIC 9.
 01 WS-ROW-NO              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(32).
 01 L-RENDERER             PIC X(150).
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-KEY L-RENDERER L-PART.
     MOVE SPACES TO L-KEY L-RENDERER
     MOVE 0 TO L-PART
     IF L-ID >= 0 AND L-ID <= 160
         COMPUTE WS-ROW-NO = L-ID + 1
         MOVE WS-KEY(WS-ROW-NO) TO L-KEY
         MOVE WS-RENDERER(WS-ROW-NO) TO L-RENDERER
         MOVE WS-PART(WS-ROW-NO) TO L-PART
     END-IF
     GOBACK.
 END PROGRAM EM10-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM10-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-N.
     MOVE 161 TO L-N
     GOBACK.
 END PROGRAM EM10-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM10-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   PIC X(32).
 01 WS-R                   PIC X(150).
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 160
         CALL "EM10-ROW" USING WS-I WS-K WS-R WS-P
         IF WS-K = L-KEY
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM10-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM10-PART-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   PIC X(32).
 01 WS-R                   PIC X(150).
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PART                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-PART L-N.
     MOVE 0 TO L-N
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 160
         CALL "EM10-ROW" USING WS-I WS-K WS-R WS-P
         IF WS-P = L-PART
             ADD 1 TO L-N
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM10-PART-COUNT.
