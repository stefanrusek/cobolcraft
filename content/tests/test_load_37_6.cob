*> Test of the loader of docs/protocol/37-nether-6...md (T-phase 23): LOAD-37-6 USING root (PIC X(1100): the folder that
*> holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the part left
*> loaded) loads the Nether structure sets and structure definitions. Fixture tree content/tests/fixtures/load-37-6
*> (accept cases: one file per documented file shape); each reject case writes one bad file into a fresh copy of it. Case
*> names start 'acceptance US12 load 37-6 '.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-37-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REG                 PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(1100).
 01 WS-PATH                PIC X(130).
 01 WS-BODY                PIC X(700).
 01 WS-T                   PIC X(70).
 01 WS-I                   BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "a set without placement".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"structures":[{"structure":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}'.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a set without structures".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232}}                       '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement without spacing".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","separation":4,"salt":30084232},"structures":[{"structure":"minecraf'.
    05 FILLER PIC X(115) VALUE 't:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}                                     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a spacing above 4096".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":5000,"separation":4,"salt":30084232},"structures":[{"struc'.
    05 FILLER PIC X(115) VALUE 'ture":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a separation below 0".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":-1,"salt":30084232},"structures":[{"struct'.
    05 FILLER PIC X(115) VALUE 'ure":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}                       '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement without salt".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4},"structures":[{"structure":"minecraft:f'.
    05 FILLER PIC X(115) VALUE 'ortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}                                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a spread_type that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232,"spread_type":"square"},'.
    05 FILLER PIC X(115) VALUE '"structures":[{"structure":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]} '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a locate_offset that is an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232,"locate_offset":{}},"str'.
    05 FILLER PIC X(115) VALUE 'uctures":[{"structure":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a frequency above 1".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232,"frequency":2},"structur'.
    05 FILLER PIC X(115) VALUE 'es":[{"structure":"minecraft:fortress","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}          '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a placement without type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"spacing":27,"separation":4,"salt":30084232},"structures":[{"structure":"minecraft:fortress","weight"'.
    05 FILLER PIC X(115) VALUE ':2},{"structure":"minecraft:bastion_remnant","weight":3}]}                                                         '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "structures that are an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232},"structures":{}}       '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an entry without weight".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232},"structures":[{"structu'.
    05 FILLER PIC X(115) VALUE 're":"minecraft:fortress"},{"structure":"minecraft:bastion_remnant","weight":3}]}                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an entry weight of 0".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232},"structures":[{"structu'.
    05 FILLER PIC X(115) VALUE 're":"minecraft:fortress","weight":0},{"structure":"minecraft:bastion_remnant","weight":3}]}                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "an entry structure that is invalid".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure_set/bad.json".
    05 FILLER PIC X(115) VALUE '{"placement":{"type":"minecraft:random_spread","spacing":27,"separation":4,"salt":30084232},"structures":[{"structu'.
    05 FILLER PIC X(115) VALUE 're":"Not Valid","weight":2},{"structure":"minecraft:bastion_remnant","weight":3}]}                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a structure without step".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:fortress","biomes":"#minecraft:has_structure/nether_fortress","spawn_overrides":{"monster":{"bou'.
    05 FILLER PIC X(115) VALUE 'nding_box":"piece","spawns":[{"type":"minecraft:blaze","weight":10,"count":{"type":"minecraft:uniform","min_inclusi'.
    05 FILLER PIC X(115) VALUE 've":2,"max_inclusive":3}}]}}}                                                                                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a step that is no identifier".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:fortress","biomes":"#minecraft:has_structure/nether_fortress","step":"Late Step","spawn_override'.
    05 FILLER PIC X(115) VALUE 's":{"monster":{"bounding_box":"piece","spawns":[{"type":"minecraft:blaze","weight":10,"count":{"type":"minecraft:un'.
    05 FILLER PIC X(115) VALUE 'iform","min_inclusive":2,"max_inclusive":3}}]}}}                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "biomes that are a number".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:fortress","biomes":1,"step":"underground_decoration","spawn_overrides":{"monster":{"bounding_box'.
    05 FILLER PIC X(115) VALUE '":"piece","spawns":[{"type":"minecraft:blaze","weight":10,"count":{"type":"minecraft:uniform","min_inclusive":2,"ma'.
    05 FILLER PIC X(115) VALUE 'x_inclusive":3}}]}}}                                                                                               '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "spawn_overrides that are an array".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:fortress","biomes":"#minecraft:has_structure/nether_fortress","step":"underground_decoration","s'.
    05 FILLER PIC X(115) VALUE 'pawn_overrides":[]}                                                                                                '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a terrain_adaptation that is no identifier".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:nether_fossil","biomes":"#minecraft:has_structure/nether_fossil","step":"underground_decoration"'.
    05 FILLER PIC X(115) VALUE ',"terrain_adaptation":"Deep One","spawn_overrides":{},"height":{"type":"minecraft:uniform","min_inclusive":{"absolu'.
    05 FILLER PIC X(115) VALUE 'te":32},"max_inclusive":{"below_top":2}}}                                                                          '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a jigsaw without start_pool".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"size":6,"start_height":{"absolute":33},"use_expansion_hack":false,"max_distance_from_center":80}     '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a jigsaw size of 21".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"start_pool":"minecraft:bastion/starts","size":21,"start_height":{"absolute":33},"use_expansion_hack":'.
    05 FILLER PIC X(115) VALUE 'false,"max_distance_from_center":80}                                                                               '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a jigsaw without use_expansion_hack".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"start_pool":"minecraft:bastion/starts","size":6,"start_height":{"absolute":33},"max_distance_from_cen'.
    05 FILLER PIC X(115) VALUE 'ter":80}                                                                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a max_distance_from_center object with horizontal 0".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"start_pool":"minecraft:bastion/starts","size":6,"start_height":{"absolute":33},"use_expansion_hack":f'.
    05 FILLER PIC X(115) VALUE 'alse,"max_distance_from_center":{"horizontal":0}}                                                                  '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a max_distance_from_center that is a string".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"start_pool":"minecraft:bastion/starts","size":6,"start_height":{"absolute":33},"use_expansion_hack":f'.
    05 FILLER PIC X(115) VALUE 'alse,"max_distance_from_center":"far"}                                                                             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a liquid_settings that is not listed".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:jigsaw","biomes":"#minecraft:has_structure/bastion_remnant","step":"surface_structures","spawn_o'.
    05 FILLER PIC X(115) VALUE 'verrides":{},"start_pool":"minecraft:bastion/starts","size":6,"start_height":{"absolute":33},"use_expansion_hack":f'.
    05 FILLER PIC X(115) VALUE 'alse,"max_distance_from_center":80,"liquid_settings":"drain"}                                                      '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a ruined portal without setups".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal_nether","step":"surface_structur'.
    05 FILLER PIC X(115) VALUE 'es","spawn_overrides":{}}                                                                                          '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "setups that are an object".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal_nether","step":"surface_structur'.
    05 FILLER PIC X(115) VALUE 'es","spawn_overrides":{},"setups":{}}                                                                              '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a setup placement that is no identifier".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal_nether","step":"surface_structur'.
    05 FILLER PIC X(115) VALUE 'es","spawn_overrides":{},"setups":[{"placement":"Sky Hole","air_pocket_probability":0.0,"mossiness":0.0,"overgrown"'.
    05 FILLER PIC X(115) VALUE ':false,"vines":false,"can_be_cold":false,"replace_with_blackstone":true,"weight":1.0}]}                            '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a setup air_pocket_probability above 1".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal_nether","step":"surface_structur'.
    05 FILLER PIC X(115) VALUE 'es","spawn_overrides":{},"setups":[{"placement":"in_nether","air_pocket_probability":2,"mossiness":0.0,"overgrown":'.
    05 FILLER PIC X(115) VALUE 'false,"vines":false,"can_be_cold":false,"replace_with_blackstone":true,"weight":1.0}]}                             '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a setup without weight".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:ruined_portal","biomes":"#minecraft:has_structure/ruined_portal_nether","step":"surface_structur'.
    05 FILLER PIC X(115) VALUE 'es","spawn_overrides":{},"setups":[{"placement":"in_nether","air_pocket_probability":0.0,"mossiness":0.0,"overgrown'.
    05 FILLER PIC X(115) VALUE '":false,"vines":false,"can_be_cold":false,"replace_with_blackstone":true}]}                                        '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a nether_fossil without height".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{"type":"minecraft:nether_fossil","biomes":"#minecraft:has_structure/nether_fossil","step":"underground_decoration"'.
    05 FILLER PIC X(115) VALUE ',"terrain_adaptation":"beard_thin","spawn_overrides":{}}                                                           '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
    05 FILLER PIC X(60) VALUE "a structure without type".
    05 FILLER PIC X(130) VALUE "build/content-test/load-37-6/t/data/minecraft/worldgen/structure/bad.json".
    05 FILLER PIC X(115) VALUE '{}                                                                                                                 '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(115) VALUE '                                                                                                                   '.
    05 FILLER PIC X(10) VALUE '          '.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 32 TIMES.
       10 WS-CASE-LABEL    PIC X(60).
       10 WS-CASE-PATH     PIC X(130).
       10 WS-CASE-BODY     PIC X(700).
 PROCEDURE DIVISION.
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-37-6" TO WS-DIR
     CALL "LOAD-37-6" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 37-6 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-6 7 shape elements" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 37-6 0 function rows" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "worldgen/structure_set" TO WS-REG
     MOVE "minecraft:nether_complexes" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure_set" TO WS-REG
     MOVE "minecraft:nether_fossils" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure_set" TO WS-REG
     MOVE "minecraft:ruined_portals" TO WS-KEY
     MOVE "-" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure" TO WS-REG
     MOVE "minecraft:fortress" TO WS-KEY
     MOVE "fortress" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure" TO WS-REG
     MOVE "minecraft:bastion_remnant" TO WS-KEY
     MOVE "jigsaw" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure" TO WS-REG
     MOVE "minecraft:ruined_portal_nether" TO WS-KEY
     MOVE "ruined_portal" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     MOVE "worldgen/structure" TO WS-REG
     MOVE "minecraft:nether_fossil" TO WS-KEY
     MOVE "nether_fossil" TO WS-WANT-TYPE
     PERFORM FIND-CHECK
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 32
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         MOVE WS-CASE-BODY(WS-I) TO WS-BODY
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 FIND-CHECK.
     CALL "SHAPE-FIND" USING WS-REG WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-6 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-OBSERVED
     IF WS-ROW > 0
         MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-6 " FUNCTION TRIM(WS-KEY) " has its type row" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-37-6 2>/dev/null; rm -rf build/content-test/load-37-6; "
         "mkdir -p build/content-test/load-37-6 && cp -R content/tests/fixtures/load-37-6 build/content-test/load-37-6/t"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p $(dirname " FUNCTION TRIM(WS-PATH) ") && printf '%s' '" FUNCTION TRIM(WS-BODY) "' > "
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-37-6/t" TO WS-DIR
     CALL "LOAD-37-6" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-6 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 37-6 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT + WG-COUNT(WGK-FUNCTION) + WG-COUNT(WGK-NODE)
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
