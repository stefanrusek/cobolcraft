*> Test of the loader of docs/protocol/36-structures-3-jigsaw-assembly.md (jigsaw structures, template pools and pool aliases (section 3)). LOAD-36-3 USING root (PIC X(1100)), status out (CT-OK, or CT-BAD-DATA
*> with every error on standard error and nothing kept): the files of content/tests/fixtures/load-36-3 load through JSON-STRICT and
*> the shape engine (shapes.cob), each accept case is an element of its registry with the type row named, and each reject case is
*> one bad file written into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-T                   PIC X(70).
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1100).
 01 WS-I                   BINARY-LONG.
 01 WS-ACCEPTS.
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:village".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:aliased".
    05 FILLER PIC X(48) VALUE "jigsaw".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(64) VALUE "minecraft:other_type".
    05 FILLER PIC X(48).
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:empty".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:village/plains/town_centers".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(64) VALUE "minecraft:mixed".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-ACCEPT-TABLE REDEFINES WS-ACCEPTS.
    05 WS-ACCEPT OCCURS 6 TIMES.
       10 WS-A-REGISTRY    PIC X(48).
       10 WS-A-KEY         PIC X(64).
       10 WS-A-TYPE        PIC X(48).
 01 WS-REJECTS.
    05 FILLER PIC X(70) VALUE "a jigsaw without start_pool".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","size":6,"start_height":{"absolute":0},"use_expansion_hack":true,"max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw without size".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","start_height":{"absolute":0},"use_expansion_hack":true,"max'.
    05 FILLER PIC X(120) VALUE '_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw with size 21".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":21,"start_height":{"absolute":0},"use_expansion_hack"'.
    05 FILLER PIC X(120) VALUE ':true,"max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw with a negative size".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":-1,"start_height":{"absolute":0},"use_expansion_hack"'.
    05 FILLER PIC X(120) VALUE ':true,"max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw without start_height".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"use_expansion_hack":true,"max_distance_from_center'.
    05 FILLER PIC X(120) VALUE '":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw without use_expansion_hack".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"max_distance_from_ce'.
    05 FILLER PIC X(120) VALUE 'nter":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw whose use_expansion_hack is a string".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE '"true","max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw without max_distance_from_center".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw with an unknown liquid_settings".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"liquid_settings":"soaked"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw with a bad start_jigsaw_name".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"start_jigsaw_name":"No Id"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw whose start_pool is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":1,"size":6,"start_height":{"absolute":0},"use_expansion_hack":true,"max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw whose project_start_to_heightmap is a number".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"project_start_to_heightmap":1}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw without biomes".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","spawn_overrides":{},"step":"surface_structures","start_pool":"minecraft:village/plains/town_'.
    05 FILLER PIC X(120) VALUE 'centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":true,"max_distance_from_center":80}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a jigsaw whose pool_aliases is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":{}}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a direct alias without target".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:direct","alias":"a:b"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a direct alias with a bad alias id".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:direct","alias":"No Id","target":"a:b"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a random alias without targets".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:random","alias":"a:b"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a random alias with a target of weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:random","alias":"a:b","targets":[{"data":"a:c","we'.
    05 FILLER PIC X(120) VALUE 'ight":0}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a random alias with a target without data".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:random","alias":"a:b","targets":[{"weight":1}]}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a random_group alias whose groups is no array".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"type":"minecraft:random_group","groups":1}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "an alias without a type".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(120) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/village_plains","spawn_overrides":{},"step":"surface_struc'.
    05 FILLER PIC X(120) VALUE 'tures","start_pool":"minecraft:village/plains/town_centers","size":6,"start_height":{"absolute":0},"use_expansion_hack":'.
    05 FILLER PIC X(120) VALUE 'true,"max_distance_from_center":80,"pool_aliases":[{"alias":"a:b"}]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool without fallback".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[]}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool without elements".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool whose elements is no array".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":{},"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool whose fallback is a number".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[],"fallback":1}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool entry without element".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"weight":1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool entry without weight".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"minecraft:village/plains/houses/a","'.
    05 FILLER PIC X(120) VALUE 'processors":"minecraft:empty","projection":"rigid"}}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool entry with weight 0".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"minecraft:village/plains/houses/a","'.
    05 FILLER PIC X(120) VALUE 'processors":"minecraft:empty","projection":"rigid"},"weight":0}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool entry with weight 151".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"minecraft:village/plains/houses/a","'.
    05 FILLER PIC X(120) VALUE 'processors":"minecraft:empty","projection":"rigid"},"weight":151}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool element without element_type".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"location":"a:b"},"weight":1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool element with a bad projection".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"a:b","projection":"sticky"},"weight"'.
    05 FILLER PIC X(120) VALUE ':1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool element with a bad location id".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"No Id","projection":"rigid"},"weight'.
    05 FILLER PIC X(120) VALUE '":1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool element with a bad override_liquid_settings".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:single_pool_element","location":"a:b","override_liquid_settings":"x"}'.
    05 FILLER PIC X(120) VALUE ',"weight":1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a list element whose elements is no array".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:list_pool_element","elements":1,"projection":"rigid"},"weight":1}],"f'.
    05 FILLER PIC X(120) VALUE 'allback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a list element with a bad sub-element".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:list_pool_element","elements":[{"location":"a:b"}],"projection":"rigi'.
    05 FILLER PIC X(120) VALUE 'd"},"weight":1}],"fallback":"minecraft:empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a feature element whose feature is a number".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '{"elements":[{"element":{"element_type":"minecraft:feature_pool_element","feature":1},"weight":1}],"fallback":"minecraft'.
    05 FILLER PIC X(120) VALUE ':empty"}'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
    05 FILLER PIC X(70) VALUE "a pool file that is an array".
    05 FILLER PIC X(48) VALUE "worldgen/template_pool".
    05 FILLER PIC X(120) VALUE '[]'.
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(120).
    05 FILLER PIC X(100).
 01 WS-REJECT-TABLE REDEFINES WS-REJECTS.
    05 WS-REJECT OCCURS 37 TIMES.
       10 WS-R-LABEL       PIC X(70).
       10 WS-R-REGISTRY    PIC X(48).
       10 WS-R-BODY        PIC X(700).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-3" TO WS-DIR
     CALL "LOAD-36-3" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-3 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-3 6 elements are kept" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-A-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-A-KEY(WS-I) TO WS-KEY
         CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-3 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-ROW > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 1 TO WS-ROW
         END-IF
         PERFORM ASSERT-NUM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 load 36-3 " FUNCTION TRIM(WS-A-REGISTRY(WS-I)) " " FUNCTION TRIM(WS-KEY) " has type row " FUNCTION TRIM(WS-A-TYPE(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-A-TYPE(WS-I) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF SH-E-TYPE(WS-ROW) > 0
             MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 37
         MOVE WS-R-LABEL(WS-I) TO WS-T
         MOVE WS-R-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-R-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     CALL "SHAPE-FREE"
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-36-3/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/load-36-3 2>/dev/null; rm -rf build/content-test/load-36-3; mkdir -p build/content-test/load-36-3 && cp -R content/tests/fixtures/load-36-3 build/content-test/load-36-3/t"
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p build/content-test/load-36-3/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) " && printf '%s' '" FUNCTION TRIM(WS-BODY)
         "' > build/content-test/load-36-3/t/data/minecraft/" FUNCTION TRIM(WS-REGISTRY) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-36-3" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-3 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-3 " FUNCTION TRIM(WS-T) " keeps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
