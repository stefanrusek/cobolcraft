*> The entity model table of the real render path (client/src/entities-models.cob, entities-render.cob): which spawned vanilla
*> entity types are drawn as which model of the entity model library (docs/protocol/34-entity-models-1..8). One row per entity
*> type key (the standard set's entity_type key without namespace, content/copy/gen/entities.cpy; the replica keeps it in EN-KEY):
*>   CL-MD-KEY    entity type key; CL-MD-FAMILY the library that builds the layer: 2 EMD-LAYER (34-2 humanoids), 4 EF4-LAYER (34-4),
*>                5 EF5-LAYER (34-5), 6 EF6-LAYER (34-6), 7 EF7-LAYER (34-7), 8 EF8-LAYER (34-8); CL-MD-LAYER the ModelLayers name
*>                of the adult model (the renderer table of each document: 34-4 1.5 EF4-REGISTRY, 34-2 5.2 EMD-RENDERER, ...);
*>   CL-MD-TEXW, CL-MD-TEXH  the layer's texture size in texels (what the model's MM-TEXW and MM-TEXH hold: the texture image of any
*>                other size is sampled by the same fractions, 34-7 1.3), also the size of the missing-texture image;
*>   CL-MD-ANIM   the setupAnim program run before drawing, with the state the replica has (head pitch, head yaw relative to the body;
*>                walk animation and age in ticks are not tracked and are 0): Q quadruped (EF4-COW-ANIM, EF4-QUAD-POSE of 34-4 2.2), C creeper
*>                (EF6-CREEPER-ANIM), Z zombie and K skeleton (EMD-ANIM variants 1 and 2), D drowned, P piglin, G zombified piglin (variants 5, 3, 4), Y an eyes layer (the
*>                posed model again, full bright, 34-1 8.5), - none: the model is drawn in its rest pose;
*>   CL-MD-PATH   the texture image in the pack stack, relative to assets/minecraft/, from the renderer facts of the documents
*>                (EF6-CREEPER-TEXTURE, EMD-RENDERER, EF7-BLAZE-TEXTURE, EF8-SQUID-TEXTURE, EF6-SPIDER-TEXTURE); spaces for a type whose texture
*>                the replica cannot choose (the cow, pig and wolf textures come from a variant registry entry that the replica does not hold; a
*>                null variant is the missing texture, 34-4 2.1): it is drawn with the missing-texture image.
 78 CL-MODEL-COUNT           VALUE 28.
 01 CL-MODEL-DATA.
    05 FILLER PIC X(20) VALUE "cow".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "COW".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "Q".
    05 FILLER PIC X(64) VALUE "textures/entity/cow/cow_temperate.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "pig".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "PIG".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "Q".
    05 FILLER PIC X(64) VALUE "textures/entity/pig/pig_temperate.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "wolf".
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(24) VALUE "WOLF".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE SPACES.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "creeper".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "CREEPER".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "C".
    05 FILLER PIC X(64) VALUE "textures/entity/creeper/creeper.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "spider".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "SPIDER".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/spider/spider.png".
    05 FILLER PIC 99 VALUE 17.
    05 FILLER PIC X(20) VALUE "zombie".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "ZOMBIE".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "Z".
    05 FILLER PIC X(64) VALUE "textures/entity/zombie/zombie.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "skeleton".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "SKELETON".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "K".
    05 FILLER PIC X(64) VALUE "textures/entity/skeleton/skeleton.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "blaze".
    05 FILLER PIC 9 VALUE 7.
    05 FILLER PIC X(24) VALUE "BLAZE".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/blaze/blaze.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "squid".
    05 FILLER PIC 9 VALUE 8.
    05 FILLER PIC X(24) VALUE "SQUID".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/squid/squid.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "chicken".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "CHICKEN".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/chicken/chicken_temperate.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "sheep".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "SHEEP".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "Q".
    05 FILLER PIC X(64) VALUE "textures/entity/sheep/sheep.png".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(20) VALUE "sheep_wool".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "SHEEP_WOOL".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "Q".
    05 FILLER PIC X(64) VALUE "textures/entity/sheep/sheep_wool.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "mooshroom".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(24) VALUE "MOOSHROOM".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "Q".
    05 FILLER PIC X(64) VALUE "textures/entity/cow/mooshroom_red.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "experience_orb".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(24) VALUE " ".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "O".
    05 FILLER PIC X(64) VALUE "textures/entity/experience/experience_orb.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "arrow".
    05 FILLER PIC 9 VALUE 0.
    05 FILLER PIC X(24) VALUE " ".
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "A".
    05 FILLER PIC X(64) VALUE "textures/entity/projectiles/arrow.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "player".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "ZOMBIE".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "H".
    05 FILLER PIC X(64) VALUE "textures/entity/player/wide/steve.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "spider_eyes".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "SPIDER".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(64) VALUE "textures/entity/spider/spider_eyes.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "cave_spider".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "CAVE_SPIDER".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/spider/cave_spider.png".
    05 FILLER PIC 99 VALUE 19.
    05 FILLER PIC X(20) VALUE "cave_spider_eyes".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "CAVE_SPIDER".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(64) VALUE "textures/entity/spider/spider_eyes.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "enderman".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "ENDERMAN".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "-".
    05 FILLER PIC X(64) VALUE "textures/entity/enderman/enderman.png".
    05 FILLER PIC 99 VALUE 21.
    05 FILLER PIC X(20) VALUE "enderman_eyes".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(24) VALUE "ENDERMAN".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "Y".
    05 FILLER PIC X(64) VALUE "textures/entity/enderman/enderman_eyes.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "husk".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "HUSK".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "Z".
    05 FILLER PIC X(64) VALUE "textures/entity/zombie/husk.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "drowned".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "DROWNED".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "D".
    05 FILLER PIC X(64) VALUE "textures/entity/zombie/drowned.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "stray".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "STRAY".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "K".
    05 FILLER PIC X(64) VALUE "textures/entity/skeleton/stray.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "wither_skeleton".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "WITHER_SKELETON".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 32.
    05 FILLER PIC X VALUE "K".
    05 FILLER PIC X(64) VALUE "textures/entity/skeleton/wither_skeleton.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "piglin".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "PIGLIN".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "P".
    05 FILLER PIC X(64) VALUE "textures/entity/piglin/piglin.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "piglin_brute".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "PIGLIN_BRUTE".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "P".
    05 FILLER PIC X(64) VALUE "textures/entity/piglin/piglin_brute.png".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(20) VALUE "zombified_piglin".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(24) VALUE "ZOMBIFIED_PIGLIN".
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC 999 VALUE 64.
    05 FILLER PIC X VALUE "G".
    05 FILLER PIC X(64) VALUE "textures/entity/piglin/zombified_piglin.png".
    05 FILLER PIC 99 VALUE 0.
 01 CL-MODELS REDEFINES CL-MODEL-DATA.
    05 CL-MD OCCURS 28 TIMES.
       10 CL-MD-KEY         PIC X(20).
       10 CL-MD-FAMILY      PIC 9.
       10 CL-MD-LAYER       PIC X(24).
       10 CL-MD-TEXW        PIC 999.
       10 CL-MD-TEXH        PIC 999.
       10 CL-MD-ANIM        PIC X.
       10 CL-MD-PATH        PIC X(64).
       10 CL-MD-EXTRA       PIC 99.
