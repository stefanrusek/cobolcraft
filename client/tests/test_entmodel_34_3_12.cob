*> Acceptance test of docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md section 12 (Master table and arm/item rules): the renderer table of the 16 entity types (renderer, layers,
*> shadow, textures, item layers), 12.1 the per-entity record fields (id, hitbox, eye height, riding offset, passenger attachment) and the arm and item rules, with the validation items 1 to 3 and 5 of
*> section 14 (cuboid counts, texture sizes, the eight scaled layers, no-hat model). Expected rows are the tables of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-3-12.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.
 01 WS-TYPE               PIC X(24).
 01 WS-FOUND              BINARY-LONG.
 01 WS-RENDERER           PIC X(32).
 01 WS-LAYERS             PIC X(100).
 01 WS-SHADOW             FLOAT-LONG.
 01 WS-TEXTURES           PIC X(100).
 01 WS-ITEM               PIC X(100).
 01 WS-MODEL2             PIC X(40).
 01 WS-HELD               PIC X(140).
 01 WS-POSE               PIC X(40).
 PROCEDURE DIVISION.
     MOVE "villager" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master villager found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master villager renderer" TO WS-NAME
     MOVE "VillagerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master villager layers" TO WS-NAME
     MOVE "adult VILLAGER, baby VILLAGER_BABY; overlay models VILLAGER_NO_HAT, VILLAGER_BABY_NO_HAT" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master villager shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master villager textures" TO WS-NAME
     MOVE "villager/villager.png, villager/villager_baby.png + overlays" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master villager item layer" TO WS-NAME
     MOVE "CrossedArmsItemLayer (GROUND item), CustomHeadLayer" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "wandering_trader" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master wandering_trader found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master wandering_trader renderer" TO WS-NAME
     MOVE "WanderingTraderRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master wandering_trader layers" TO WS-NAME
     MOVE "WANDERING_TRADER" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master wandering_trader shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master wandering_trader textures" TO WS-NAME
     MOVE "wandering_trader/wandering_trader.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master wandering_trader item layer" TO WS-NAME
     MOVE "CrossedArmsItemLayer, CustomHeadLayer" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_villager" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master zombie_villager found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master zombie_villager renderer" TO WS-NAME
     MOVE "ZombieVillagerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master zombie_villager layers" TO WS-NAME
     MOVE "adult / baby / no-hat variants / armor sets" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master zombie_villager shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master zombie_villager textures" TO WS-NAME
     MOVE "zombie_villager/zombie_villager.png, ..._baby.png + overlays" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master zombie_villager item layer" TO WS-NAME
     MOVE "humanoid ItemInHandLayer, wings, custom head" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "witch" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master witch found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master witch renderer" TO WS-NAME
     MOVE "WitchRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master witch layers" TO WS-NAME
     MOVE "WITCH (villager mesh edited, scaled 0.9375)" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master witch shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master witch textures" TO WS-NAME
     MOVE "witch/witch.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master witch item layer" TO WS-NAME
     MOVE "WitchItemLayer" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pillager" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master pillager found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master pillager renderer" TO WS-NAME
     MOVE "PillagerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master pillager layers" TO WS-NAME
     MOVE "PILLAGER (= illager mesh x 0.9375)" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master pillager shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master pillager textures" TO WS-NAME
     MOVE "illager/pillager.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master pillager item layer" TO WS-NAME
     MOVE "ItemInHandLayer always" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "vindicator" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master vindicator found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master vindicator renderer" TO WS-NAME
     MOVE "VindicatorRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vindicator layers" TO WS-NAME
     MOVE "VINDICATOR" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vindicator shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master vindicator textures" TO WS-NAME
     MOVE "illager/vindicator.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vindicator item layer" TO WS-NAME
     MOVE "when aggressive" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "evoker" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master evoker found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master evoker renderer" TO WS-NAME
     MOVE "EvokerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker layers" TO WS-NAME
     MOVE "EVOKER" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master evoker textures" TO WS-NAME
     MOVE "illager/evoker.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker item layer" TO WS-NAME
     MOVE "when casting" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "illusioner" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master illusioner found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master illusioner renderer" TO WS-NAME
     MOVE "IllusionerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master illusioner layers" TO WS-NAME
     MOVE "ILLUSIONER (hat visible)" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master illusioner shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master illusioner textures" TO WS-NAME
     MOVE "illager/illusioner.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master illusioner item layer" TO WS-NAME
     MOVE "when casting or aggressive" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "evoker_fangs" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master evoker_fangs found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master evoker_fangs renderer" TO WS-NAME
     MOVE "EvokerFangsRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker_fangs layers" TO WS-NAME
     MOVE "EVOKER_FANGS" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker_fangs shadow" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master evoker_fangs textures" TO WS-NAME
     MOVE "illager/evoker_fangs.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master evoker_fangs item layer" TO WS-NAME
     MOVE "none" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "ravager" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master ravager found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master ravager renderer" TO WS-NAME
     MOVE "RavagerRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master ravager layers" TO WS-NAME
     MOVE "RAVAGER" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master ravager shadow" TO WS-NAME
     MOVE 1.1 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master ravager textures" TO WS-NAME
     MOVE "illager/ravager.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master ravager item layer" TO WS-NAME
     MOVE "none" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "vex" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master vex found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master vex renderer" TO WS-NAME
     MOVE "VexRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vex layers" TO WS-NAME
     MOVE "VEX" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vex shadow" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master vex textures" TO WS-NAME
     MOVE "illager/vex.png, illager/vex_charging.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master vex item layer" TO WS-NAME
     MOVE "ItemInHandLayer" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "iron_golem" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master iron_golem found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master iron_golem renderer" TO WS-NAME
     MOVE "IronGolemRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master iron_golem layers" TO WS-NAME
     MOVE "IRON_GOLEM" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master iron_golem shadow" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master iron_golem textures" TO WS-NAME
     MOVE "iron_golem/iron_golem.png + 3 crack textures" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master iron_golem item layer" TO WS-NAME
     MOVE "none (flower layer)" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "snow_golem" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master snow_golem found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master snow_golem renderer" TO WS-NAME
     MOVE "SnowGolemRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master snow_golem layers" TO WS-NAME
     MOVE "SNOW_GOLEM" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master snow_golem shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master snow_golem textures" TO WS-NAME
     MOVE "snow_golem/snow_golem.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master snow_golem item layer" TO WS-NAME
     MOVE "none (head block layer)" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "copper_golem" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master copper_golem found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master copper_golem renderer" TO WS-NAME
     MOVE "CopperGolemRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master copper_golem layers" TO WS-NAME
     MOVE "COPPER_GOLEM (+ 3 statue pose layers)" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master copper_golem shadow" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master copper_golem textures" TO WS-NAME
     MOVE "copper_golem/copper_golem*.png (8 files)" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master copper_golem item layer" TO WS-NAME
     MOVE "ItemInHandLayer, antenna block, custom head" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "creaking" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master creaking found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master creaking renderer" TO WS-NAME
     MOVE "CreakingRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master creaking layers" TO WS-NAME
     MOVE "CREAKING, CREAKING_EYES" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master creaking shadow" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master creaking textures" TO WS-NAME
     MOVE "creaking/creaking.png, creaking/creaking_eyes.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master creaking item layer" TO WS-NAME
     MOVE "none" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "allay" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master allay found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "master allay renderer" TO WS-NAME
     MOVE "AllayRenderer" TO TL-EXPECTED
     MOVE WS-RENDERER TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master allay layers" TO WS-NAME
     MOVE "ALLAY" TO TL-EXPECTED
     MOVE WS-LAYERS TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master allay shadow" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-SHADOW TO WS-O
     PERFORM CHECK-NUM
     MOVE "master allay textures" TO WS-NAME
     MOVE "allay/allay.png" TO TL-EXPECTED
     MOVE WS-TEXTURES TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "master allay item layer" TO WS-NAME
     MOVE "ItemInHandLayer" TO TL-EXPECTED
     MOVE WS-ITEM TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie" TO WS-TYPE
     CALL "EM3-MASTER" USING WS-TYPE WS-FOUND WS-RENDERER WS-LAYERS WS-SHADOW WS-TEXTURES WS-ITEM
     MOVE "master: a type outside the document is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     PERFORM CHECK-NUM
     MOVE "villager" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 villager field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 2" TO WS-NAME
     MOVE 143.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 5" TO WS-NAME
     MOVE 1.62 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 villager field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "wandering_trader" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 wandering_trader field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 2" TO WS-NAME
     MOVE 145.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 5" TO WS-NAME
     MOVE 1.62 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 wandering_trader field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_villager" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 zombie_villager field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 2" TO WS-NAME
     MOVE 157.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 5" TO WS-NAME
     MOVE 1.74 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 7" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 9" TO WS-NAME
     MOVE 2.125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 zombie_villager field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "witch" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 witch field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 2" TO WS-NAME
     MOVE 148.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 5" TO WS-NAME
     MOVE 1.62 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 9" TO WS-NAME
     MOVE 2.2625 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 witch field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "pillager" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 pillager field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 2" TO WS-NAME
     MOVE 104.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 5" TO WS-NAME
     MOVE 1.6575 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 7" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 9" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 pillager field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "vindicator" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 vindicator field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 2" TO WS-NAME
     MOVE 144.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 5" TO WS-NAME
     MOVE 1.6575 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 7" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 9" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vindicator field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "evoker" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 evoker field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 2" TO WS-NAME
     MOVE 47.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 5" TO WS-NAME
     MOVE 1.6575 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 7" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 9" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "illusioner" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 illusioner field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 2" TO WS-NAME
     MOVE 69.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 3" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 4" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 5" TO WS-NAME
     MOVE 1.6575 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 7" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 9" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 illusioner field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "evoker_fangs" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 evoker_fangs field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 2" TO WS-NAME
     MOVE 48.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 3" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 4" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 5" TO WS-NAME
     MOVE 0.68 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 evoker_fangs field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ravager" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 ravager field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 2" TO WS-NAME
     MOVE 112.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 3" TO WS-NAME
     MOVE 1.95 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 4" TO WS-NAME
     MOVE 2.2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 5" TO WS-NAME
     MOVE 1.87 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 8" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 10" TO WS-NAME
     MOVE 2.2625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 ravager field 11" TO WS-NAME
     MOVE -0.0625 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "vex" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 vex field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 2" TO WS-NAME
     MOVE 142.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 3" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 4" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 5" TO WS-NAME
     MOVE 0.51875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 7" TO WS-NAME
     MOVE 0.04 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 8" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 9" TO WS-NAME
     MOVE 0.7375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 vex field 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "iron_golem" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 iron_golem field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 2" TO WS-NAME
     MOVE 71.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 3" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 4" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 5" TO WS-NAME
     MOVE 2.295 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 iron_golem field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "snow_golem" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 snow_golem field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 2" TO WS-NAME
     MOVE 124.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 3" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 4" TO WS-NAME
     MOVE 1.9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 5" TO WS-NAME
     MOVE 1.7 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 snow_golem field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "copper_golem" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 copper_golem field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 2" TO WS-NAME
     MOVE 28.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 3" TO WS-NAME
     MOVE 0.49 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 4" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 5" TO WS-NAME
     MOVE 0.8125 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 copper_golem field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creaking" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 creaking field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 2" TO WS-NAME
     MOVE 31.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 3" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 4" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 5" TO WS-NAME
     MOVE 2.3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 6" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 7" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 creaking field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "allay" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 allay field 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 2" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 3" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 4" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 5" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 6" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 7" TO WS-NAME
     MOVE 0.04 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 8" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 9" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 10" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "12.1 allay field 11" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie" TO WS-TYPE
     CALL "EM3-RECORD" USING WS-TYPE WS-OUT
     MOVE "12.1 a type outside the document is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "Villager, wandering trader" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Villager, wandering trader held-item transform" TO WS-NAME
     MOVE "crossed-arms layer: translateToArms (root, arms), rotX 0.75 rad, scale 1.07, translate (0, 0.13, -0.34), rotX pi" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Villager, wandering trader arm pose source" TO WS-NAME
     MOVE "none (arms fixed)" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Witch" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Witch held-item transform" TO WS-NAME
     MOVE "potion: head and nose chain (3.3); other items: as the villager" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Witch arm pose source" TO WS-NAME
     MOVE "none" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Illagers" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Illagers held-item transform" TO WS-NAME
     MOVE "ItemInHandLayer with translateToHand = root + arm part" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Illagers arm pose source" TO WS-NAME
     MOVE "4.2, 4.3" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Vex" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Vex held-item transform" TO WS-NAME
     MOVE "root, body, arm, scale 0.55, translate (+-0.046875, -0.15625, 0.078125)" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Vex arm pose source" TO WS-NAME
     MOVE "charging pose 6" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Copper golem" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Copper golem held-item transform" TO WS-NAME
     MOVE "root, body, arm, then the IDLE or non-IDLE branch of 9.3" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Copper golem arm pose source" TO WS-NAME
     MOVE "animations" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Allay" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Allay held-item transform" TO WS-NAME
     MOVE "11" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Allay arm pose source" TO WS-NAME
     MOVE "wing/arm math of 11" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Zombie villager" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule Zombie villager held-item transform" TO WS-NAME
     MOVE "humanoid hand transform (12 §7.5, framework sibling)" TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "arm rule Zombie villager arm pose source" TO WS-NAME
     MOVE "zombie arms 2.3" TO TL-EXPECTED
     MOVE WS-POSE TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "Ghast" TO WS-MODEL2
     CALL "EM3-ARM-RULE" USING WS-MODEL2 WS-HELD WS-POSE
     MOVE "arm rule for a model outside the document is empty" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-HELD TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer VILLAGER: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer VILLAGER_BABY: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER_BABY: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER_BABY: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VILLAGER_BABY: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER_BABY: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER_BABY: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ZOMBIE_VILLAGER_BABY: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer WITCH is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer WITCH: parts below the root" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer WITCH: cuboids" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer WITCH: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer WITCH: texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PILLAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer PILLAGER: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer PILLAGER: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer PILLAGER: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer PILLAGER: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "EVOKER_FANGS" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer EVOKER_FANGS is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer EVOKER_FANGS: parts below the root" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer EVOKER_FANGS: cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer EVOKER_FANGS: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer EVOKER_FANGS: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "RAVAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer RAVAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer RAVAGER: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer RAVAGER: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer RAVAGER: texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer RAVAGER: texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VEX" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VEX is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer VEX: parts below the root" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VEX: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VEX: texture width" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer VEX: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "IRON_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer IRON_GOLEM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer IRON_GOLEM: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer IRON_GOLEM: cuboids" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer IRON_GOLEM: texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer IRON_GOLEM: texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SNOW_GOLEM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer SNOW_GOLEM: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer SNOW_GOLEM: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer SNOW_GOLEM: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer SNOW_GOLEM: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COPPER_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COPPER_GOLEM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COPPER_GOLEM_RUNNING" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COPPER_GOLEM_RUNNING is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_RUNNING: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_RUNNING: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_RUNNING: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_RUNNING: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COPPER_GOLEM_SITTING" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COPPER_GOLEM_SITTING is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_SITTING: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_SITTING: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_SITTING: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_SITTING: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COPPER_GOLEM_STAR" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COPPER_GOLEM_STAR is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_STAR: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_STAR: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_STAR: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer COPPER_GOLEM_STAR: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "CREAKING" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer CREAKING is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer CREAKING: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer CREAKING: cuboids" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer CREAKING: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer CREAKING: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ALLAY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ALLAY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "14.1 and 14.2 validation: layer ALLAY: parts below the root" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ALLAY: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ALLAY: texture width" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "14.1 and 14.2 validation: layer ALLAY: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_NO_HAT" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER_NO_HAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "14.5 the no-hat head keeps its pose but has no cuboid" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ILLUSIONER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ILLUSIONER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "hat visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§12 Master table and arm/item rules: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§12 Master table and arm/item rules: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-3-12.
