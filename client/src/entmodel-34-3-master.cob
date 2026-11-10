*> Entity models part 3 (docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md) section 12: the master table of the 16 entity types, the per-entity record fields of 12.1 and the arm and
*> held-item rules, as the rows of the document.
*> Entry points for the integrator (inputs): EM3-MASTER type(X(24)) found(out BINARY-LONG) renderer(X(32)) layers(X(100)) shadow(FLOAT-LONG, -1 for none) textures(X(100)) item-layer(X(100)).
*>   EM3-RECORD type(X(24)) OUT(64 FLOAT-LONG: 1 found, 2 numeric id, 3 hitbox width, 4 height, 5 eye height, 6 riding offset set, 7 riding offset, 8 passenger attachment (0 none, 1 one value, 2 one vector),
*>     9 to 11 its values y or (x y z)). EM3-ARM-RULE model(X(40)) held-item-transform(X(140)) arm-pose-source(X(40)) (spaces for a model outside the table).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-MASTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC X(32) VALUE "VillagerRenderer".
    05 FILLER PIC X(100) VALUE "adult VILLAGER, baby VILLAGER_BABY; overlay models VILLAGER_NO_HAT, VILLAGER_BABY_NO_HAT".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "villager/villager.png, villager/villager_baby.png + overlays".
    05 FILLER PIC X(100) VALUE "CrossedArmsItemLayer (GROUND item), CustomHeadLayer".
    05 FILLER PIC X(24) VALUE "wandering_trader".
    05 FILLER PIC X(32) VALUE "WanderingTraderRenderer".
    05 FILLER PIC X(100) VALUE "WANDERING_TRADER".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "wandering_trader/wandering_trader.png".
    05 FILLER PIC X(100) VALUE "CrossedArmsItemLayer, CustomHeadLayer".
    05 FILLER PIC X(24) VALUE "zombie_villager".
    05 FILLER PIC X(32) VALUE "ZombieVillagerRenderer".
    05 FILLER PIC X(100) VALUE "adult / baby / no-hat variants / armor sets".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "zombie_villager/zombie_villager.png, ..._baby.png + overlays".
    05 FILLER PIC X(100) VALUE "humanoid ItemInHandLayer, wings, custom head".
    05 FILLER PIC X(24) VALUE "witch".
    05 FILLER PIC X(32) VALUE "WitchRenderer".
    05 FILLER PIC X(100) VALUE "WITCH (villager mesh edited, scaled 0.9375)".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "witch/witch.png".
    05 FILLER PIC X(100) VALUE "WitchItemLayer".
    05 FILLER PIC X(24) VALUE "pillager".
    05 FILLER PIC X(32) VALUE "PillagerRenderer".
    05 FILLER PIC X(100) VALUE "PILLAGER (= illager mesh x 0.9375)".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "illager/pillager.png".
    05 FILLER PIC X(100) VALUE "ItemInHandLayer always".
    05 FILLER PIC X(24) VALUE "vindicator".
    05 FILLER PIC X(32) VALUE "VindicatorRenderer".
    05 FILLER PIC X(100) VALUE "VINDICATOR".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "illager/vindicator.png".
    05 FILLER PIC X(100) VALUE "when aggressive".
    05 FILLER PIC X(24) VALUE "evoker".
    05 FILLER PIC X(32) VALUE "EvokerRenderer".
    05 FILLER PIC X(100) VALUE "EVOKER".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "illager/evoker.png".
    05 FILLER PIC X(100) VALUE "when casting".
    05 FILLER PIC X(24) VALUE "illusioner".
    05 FILLER PIC X(32) VALUE "IllusionerRenderer".
    05 FILLER PIC X(100) VALUE "ILLUSIONER (hat visible)".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "illager/illusioner.png".
    05 FILLER PIC X(100) VALUE "when casting or aggressive".
    05 FILLER PIC X(24) VALUE "evoker_fangs".
    05 FILLER PIC X(32) VALUE "EvokerFangsRenderer".
    05 FILLER PIC X(100) VALUE "EVOKER_FANGS".
    05 FILLER PIC X(12) VALUE "-1.0".
    05 FILLER PIC X(100) VALUE "illager/evoker_fangs.png".
    05 FILLER PIC X(100) VALUE "none".
    05 FILLER PIC X(24) VALUE "ravager".
    05 FILLER PIC X(32) VALUE "RavagerRenderer".
    05 FILLER PIC X(100) VALUE "RAVAGER".
    05 FILLER PIC X(12) VALUE "1.1".
    05 FILLER PIC X(100) VALUE "illager/ravager.png".
    05 FILLER PIC X(100) VALUE "none".
    05 FILLER PIC X(24) VALUE "vex".
    05 FILLER PIC X(32) VALUE "VexRenderer".
    05 FILLER PIC X(100) VALUE "VEX".
    05 FILLER PIC X(12) VALUE "0.3".
    05 FILLER PIC X(100) VALUE "illager/vex.png, illager/vex_charging.png".
    05 FILLER PIC X(100) VALUE "ItemInHandLayer".
    05 FILLER PIC X(24) VALUE "iron_golem".
    05 FILLER PIC X(32) VALUE "IronGolemRenderer".
    05 FILLER PIC X(100) VALUE "IRON_GOLEM".
    05 FILLER PIC X(12) VALUE "0.7".
    05 FILLER PIC X(100) VALUE "iron_golem/iron_golem.png + 3 crack textures".
    05 FILLER PIC X(100) VALUE "none (flower layer)".
    05 FILLER PIC X(24) VALUE "snow_golem".
    05 FILLER PIC X(32) VALUE "SnowGolemRenderer".
    05 FILLER PIC X(100) VALUE "SNOW_GOLEM".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "snow_golem/snow_golem.png".
    05 FILLER PIC X(100) VALUE "none (head block layer)".
    05 FILLER PIC X(24) VALUE "copper_golem".
    05 FILLER PIC X(32) VALUE "CopperGolemRenderer".
    05 FILLER PIC X(100) VALUE "COPPER_GOLEM (+ 3 statue pose layers)".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(100) VALUE "copper_golem/copper_golem*.png (8 files)".
    05 FILLER PIC X(100) VALUE "ItemInHandLayer, antenna block, custom head".
    05 FILLER PIC X(24) VALUE "creaking".
    05 FILLER PIC X(32) VALUE "CreakingRenderer".
    05 FILLER PIC X(100) VALUE "CREAKING, CREAKING_EYES".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(100) VALUE "creaking/creaking.png, creaking/creaking_eyes.png".
    05 FILLER PIC X(100) VALUE "none".
    05 FILLER PIC X(24) VALUE "allay".
    05 FILLER PIC X(32) VALUE "AllayRenderer".
    05 FILLER PIC X(100) VALUE "ALLAY".
    05 FILLER PIC X(12) VALUE "0.4".
    05 FILLER PIC X(100) VALUE "allay/allay.png".
    05 FILLER PIC X(100) VALUE "ItemInHandLayer".
 01 WS-TAB-R REDEFINES WS-TAB.
    05 WS-E OCCURS 16 TIMES.
       10 WS-TYPE           PIC X(24).
       10 WS-RENDERER       PIC X(32).
       10 WS-LAYERS         PIC X(100).
       10 WS-SHADOW         PIC X(12).
       10 WS-TEXTURES       PIC X(100).
       10 WS-ITEM           PIC X(100).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                PIC X(24).
 01 L-FOUND               BINARY-LONG.
 01 L-RENDERER             PIC X(32).
 01 L-LAYERS               PIC X(100).
 01 L-SHADOW               FLOAT-LONG.
 01 L-TEXTURES             PIC X(100).
 01 L-ITEM                 PIC X(100).
 PROCEDURE DIVISION USING L-TYPE L-FOUND L-RENDERER L-LAYERS L-SHADOW L-TEXTURES L-ITEM.
     MOVE 0 TO L-FOUND L-SHADOW
     MOVE SPACES TO L-RENDERER L-LAYERS L-TEXTURES L-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-TYPE(WS-I) = L-TYPE
             MOVE 1 TO L-FOUND
             MOVE WS-RENDERER(WS-I) TO L-RENDERER
             MOVE WS-LAYERS(WS-I) TO L-LAYERS
             COMPUTE L-SHADOW = FUNCTION NUMVAL(WS-SHADOW(WS-I))
             MOVE WS-TEXTURES(WS-I) TO L-TEXTURES
             MOVE WS-ITEM(WS-I) TO L-ITEM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM3-MASTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-RECORD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 FILLER PIC X(24) VALUE "villager".
    05 FILLER PIC X(12) VALUE "143.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.62".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "wandering_trader".
    05 FILLER PIC X(12) VALUE "145.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.62".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "zombie_villager".
    05 FILLER PIC X(12) VALUE "157.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.74".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "-0.7".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.125".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "witch".
    05 FILLER PIC X(12) VALUE "148.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.62".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.2625".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "pillager".
    05 FILLER PIC X(12) VALUE "104.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.6575".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "-0.6".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "vindicator".
    05 FILLER PIC X(12) VALUE "144.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.6575".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "-0.6".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "evoker".
    05 FILLER PIC X(12) VALUE "47.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.6575".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "-0.6".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "illusioner".
    05 FILLER PIC X(12) VALUE "69.0".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "1.6575".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "-0.6".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "evoker_fangs".
    05 FILLER PIC X(12) VALUE "48.0".
    05 FILLER PIC X(12) VALUE "0.5".
    05 FILLER PIC X(12) VALUE "0.8".
    05 FILLER PIC X(12) VALUE "0.68".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "ravager".
    05 FILLER PIC X(12) VALUE "112.0".
    05 FILLER PIC X(12) VALUE "1.95".
    05 FILLER PIC X(12) VALUE "2.2".
    05 FILLER PIC X(12) VALUE "1.87".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "2.2625".
    05 FILLER PIC X(12) VALUE "-0.0625".
    05 FILLER PIC X(24) VALUE "vex".
    05 FILLER PIC X(12) VALUE "142.0".
    05 FILLER PIC X(12) VALUE "0.4".
    05 FILLER PIC X(12) VALUE "0.8".
    05 FILLER PIC X(12) VALUE "0.51875".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "0.04".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "0.7375".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "iron_golem".
    05 FILLER PIC X(12) VALUE "71.0".
    05 FILLER PIC X(12) VALUE "1.4".
    05 FILLER PIC X(12) VALUE "2.7".
    05 FILLER PIC X(12) VALUE "2.295".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "snow_golem".
    05 FILLER PIC X(12) VALUE "124.0".
    05 FILLER PIC X(12) VALUE "0.7".
    05 FILLER PIC X(12) VALUE "1.9".
    05 FILLER PIC X(12) VALUE "1.7".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "copper_golem".
    05 FILLER PIC X(12) VALUE "28.0".
    05 FILLER PIC X(12) VALUE "0.49".
    05 FILLER PIC X(12) VALUE "0.98".
    05 FILLER PIC X(12) VALUE "0.8125".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "creaking".
    05 FILLER PIC X(12) VALUE "31.0".
    05 FILLER PIC X(12) VALUE "0.9".
    05 FILLER PIC X(12) VALUE "2.7".
    05 FILLER PIC X(12) VALUE "2.3".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(24) VALUE "allay".
    05 FILLER PIC X(12) VALUE "2.0".
    05 FILLER PIC X(12) VALUE "0.35".
    05 FILLER PIC X(12) VALUE "0.6".
    05 FILLER PIC X(12) VALUE "0.36".
    05 FILLER PIC X(12) VALUE "1.0".
    05 FILLER PIC X(12) VALUE "0.04".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
    05 FILLER PIC X(12) VALUE "0.0".
 01 WS-TAB-R REDEFINES WS-TAB.
    05 WS-E OCCURS 16 TIMES.
       10 WS-TYPE           PIC X(24).
       10 WS-V              PIC X(12) OCCURS 10 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-TYPE L-OUT.
     MOVE 0 TO L-O(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-TYPE(WS-I) = L-TYPE
             MOVE 1 TO L-O(1)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 10
                 COMPUTE L-O(WS-K + 1) = FUNCTION NUMVAL(WS-V(WS-I, WS-K))
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM3-RECORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM3-ARM-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAB.
    05 FILLER PIC X(40) VALUE "Villager, wandering trader".
    05 FILLER PIC X(140) VALUE "crossed-arms layer: translateToArms (root, arms), rotX 0.75 rad, scale 1.07, translate (0, 0.13, -0.34), rotX pi".
    05 FILLER PIC X(40) VALUE "none (arms fixed)".
    05 FILLER PIC X(40) VALUE "Witch".
    05 FILLER PIC X(140) VALUE "potion: head and nose chain (3.3); other items: as the villager".
    05 FILLER PIC X(40) VALUE "none".
    05 FILLER PIC X(40) VALUE "Illagers".
    05 FILLER PIC X(140) VALUE "ItemInHandLayer with translateToHand = root + arm part".
    05 FILLER PIC X(40) VALUE "4.2, 4.3".
    05 FILLER PIC X(40) VALUE "Vex".
    05 FILLER PIC X(140) VALUE "root, body, arm, scale 0.55, translate (+-0.046875, -0.15625, 0.078125)".
    05 FILLER PIC X(40) VALUE "charging pose 6".
    05 FILLER PIC X(40) VALUE "Copper golem".
    05 FILLER PIC X(140) VALUE "root, body, arm, then the IDLE or non-IDLE branch of 9.3".
    05 FILLER PIC X(40) VALUE "animations".
    05 FILLER PIC X(40) VALUE "Allay".
    05 FILLER PIC X(140) VALUE "11".
    05 FILLER PIC X(40) VALUE "wing/arm math of 11".
    05 FILLER PIC X(40) VALUE "Zombie villager".
    05 FILLER PIC X(140) VALUE "humanoid hand transform (12 §7.5, framework sibling)".
    05 FILLER PIC X(40) VALUE "zombie arms 2.3".
 01 WS-TAB-R REDEFINES WS-TAB.
    05 WS-E OCCURS 7 TIMES.
       10 WS-MODEL          PIC X(40).
       10 WS-HELD           PIC X(140).
       10 WS-POSE           PIC X(40).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODEL               PIC X(40).
 01 L-HELD                PIC X(140).
 01 L-POSE                PIC X(40).
 PROCEDURE DIVISION USING L-MODEL L-HELD L-POSE.
     MOVE SPACES TO L-HELD L-POSE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         IF WS-MODEL(WS-I) = L-MODEL
             MOVE WS-HELD(WS-I) TO L-HELD
             MOVE WS-POSE(WS-I) TO L-POSE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM3-ARM-RULE.
