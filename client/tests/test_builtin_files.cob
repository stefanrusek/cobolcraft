*> Implementation test of client/src/packs/builtin.cob (BUILTIN-PATH, BUILTIN-READ; 08 §10.1,
*> §10.2, §10.4 to §10.6, §10.8, §10.10): the built-in pack lists its files and serves pack.mcmeta,
*> the atlas definitions, the template and block models, the block state files, font/default.json
*> and lang/en_us.json; each file parses as JSON and holds the values of 08 §10. In the expected
*> font rows "~" stands for the backslash and a final "^" for the unused cell U+0000.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-FILES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY TESTLIB.
 01 WS-ROWS.
    05 FILLER PIC X(64) VALUE "pack.mcmeta".
    05 FILLER PIC X(48) VALUE "pack.description".
    05 FILLER PIC X(48) VALUE "CobolCraft stand-in default pack".
    05 FILLER PIC X(64) VALUE "pack.mcmeta".
    05 FILLER PIC X(48) VALUE "pack.min_format".
    05 FILLER PIC X(48) VALUE "97".
    05 FILLER PIC X(64) VALUE "pack.mcmeta".
    05 FILLER PIC X(48) VALUE "pack.max_format".
    05 FILLER PIC X(48) VALUE "97".
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(48) VALUE "sources[0].type".
    05 FILLER PIC X(48) VALUE "directory".
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(48) VALUE "sources[0].source".
    05 FILLER PIC X(48) VALUE "block".
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(48) VALUE "sources[0].prefix".
    05 FILLER PIC X(48) VALUE "block/".
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/items.json".
    05 FILLER PIC X(48) VALUE "sources[0].source".
    05 FILLER PIC X(48) VALUE "item".
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/items.json".
    05 FILLER PIC X(48) VALUE "sources[0].prefix".
    05 FILLER PIC X(48) VALUE "item/".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "textures.particle".
    05 FILLER PIC X(48) VALUE "#north".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].from[2]".
    05 FILLER PIC X(48) VALUE "0".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].to[1]".
    05 FILLER PIC X(48) VALUE "16".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.down.texture".
    05 FILLER PIC X(48) VALUE "#down".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.down.cullface".
    05 FILLER PIC X(48) VALUE "down".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.up.texture".
    05 FILLER PIC X(48) VALUE "#up".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.up.cullface".
    05 FILLER PIC X(48) VALUE "up".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.north.texture".
    05 FILLER PIC X(48) VALUE "#north".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.north.cullface".
    05 FILLER PIC X(48) VALUE "north".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.south.texture".
    05 FILLER PIC X(48) VALUE "#south".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.south.cullface".
    05 FILLER PIC X(48) VALUE "south".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.west.texture".
    05 FILLER PIC X(48) VALUE "#west".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.west.cullface".
    05 FILLER PIC X(48) VALUE "west".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.east.texture".
    05 FILLER PIC X(48) VALUE "#east".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(48) VALUE "elements[0].faces.east.cullface".
    05 FILLER PIC X(48) VALUE "east".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_box".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.particle".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.down".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.up".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.north".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.south".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.west".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(48) VALUE "textures.east".
    05 FILLER PIC X(48) VALUE "#all".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_box".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.particle".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.up".
    05 FILLER PIC X(48) VALUE "#top".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.down".
    05 FILLER PIC X(48) VALUE "#bottom".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.north".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.south".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.west".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(48) VALUE "textures.east".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_box".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.particle".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.up".
    05 FILLER PIC X(48) VALUE "#end".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.down".
    05 FILLER PIC X(48) VALUE "#end".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.north".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.south".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.west".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(48) VALUE "textures.east".
    05 FILLER PIC X(48) VALUE "#side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/baseplate.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/baseplate.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/baseplate".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/greystone.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/greystone.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/greystone".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/loam.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/loam.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/loam".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/turf.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_layered".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/turf.json".
    05 FILLER PIC X(48) VALUE "textures.top".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/turf_top".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/turf.json".
    05 FILLER PIC X(48) VALUE "textures.side".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/turf_side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/turf.json".
    05 FILLER PIC X(48) VALUE "textures.bottom".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/loam".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/grit.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/grit.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/grit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_pillar".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack.json".
    05 FILLER PIC X(48) VALUE "textures.end".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_end".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack.json".
    05 FILLER PIC X(48) VALUE "textures.side".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_side".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack_punched.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_pillar".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack_punched.json".
    05 FILLER PIC X(48) VALUE "textures.end".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_end".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack_punched.json".
    05 FILLER PIC X(48) VALUE "textures.side".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_side_punched".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/lucite.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/lucite.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/lucite".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_lit.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_lit.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/glowtube_lit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_unlit.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_unlit.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/glowtube_unlit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/ledger_tile.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/ledger_tile.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/ledger_tile".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/goto_pad.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/goto_pad.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/goto_pad".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/slag.json".
    05 FILLER PIC X(48) VALUE "parent".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/template_uniform".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/slag.json".
    05 FILLER PIC X(48) VALUE "textures.all".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/slag".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/baseplate.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/baseplate".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/greystone.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/greystone".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/loam.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/loam".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/turf.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/turf".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/grit.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/grit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/lucite.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/lucite".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/ledger_tile.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/ledger_tile".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/goto_pad.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/goto_pad".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/slag.json".
    05 FILLER PIC X(48) VALUE "variants..model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/slag".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/glowtube.json".
    05 FILLER PIC X(48) VALUE "variants.lit=true.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/glowtube_lit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/glowtube.json".
    05 FILLER PIC X(48) VALUE "variants.lit=false.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/glowtube_unlit".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=y,punched=false.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=y,punched=true.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_punched".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=z,punched=false.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=z,punched=false.x".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=z,punched=true.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_punched".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=z,punched=true.x".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=false.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=false.x".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=false.y".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=true.model".
    05 FILLER PIC X(48) VALUE "cobolcraft:block/cardstack_punched".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=true.x".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(48) VALUE "variants.axis=x,punched=true.y".
    05 FILLER PIC X(48) VALUE "90".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].type".
    05 FILLER PIC X(48) VALUE "bitmap".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].file".
    05 FILLER PIC X(48) VALUE "cobolcraft:font/ascii.png".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].height".
    05 FILLER PIC X(48) VALUE "8".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].ascent".
    05 FILLER PIC X(48) VALUE "7".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[0]".
    05 FILLER PIC X(48) VALUE " !""#$%&'()*+,-./".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[1]".
    05 FILLER PIC X(48) VALUE "0123456789:;<=>?".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[2]".
    05 FILLER PIC X(48) VALUE "@ABCDEFGHIJKLMNO".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[3]".
    05 FILLER PIC X(48) VALUE "PQRSTUVWXYZ[~]^_".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[4]".
    05 FILLER PIC X(48) VALUE "`abcdefghijklmno".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(48) VALUE "providers[0].chars[5]".
    05 FILLER PIC X(48) VALUE "pqrstuvwxyz{|}~^".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.server_list.title".
    05 FILLER PIC X(48) VALUE "Servers".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "block.cobolcraft.goto_pad".
    05 FILLER PIC X(48) VALUE "GOTO Pad".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.hud.crosshair".
    05 FILLER PIC X(48) VALUE "+".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.chat.say".
    05 FILLER PIC X(48) VALUE "<%s> %s".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.world_type.standard".
    05 FILLER PIC X(48) VALUE "Standard".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.world_type.cobolcraft".
    05 FILLER PIC X(48) VALUE "CobolCraft".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.create_world.type".
    05 FILLER PIC X(48) VALUE "World type: %s".
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(48) VALUE "cobolcraft.screen.world_list.type".
    05 FILLER PIC X(48) VALUE "Type: %s".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 118 TIMES.
       10 WS-R-FILE        PIC X(64).
       10 WS-R-PATH        PIC X(48).
       10 WS-R-VALUE       PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FAILED              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-JPATH               PIC X(48).
 01 WS-JPATH-LENGTH        BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-CAP           BINARY-LONG VALUE 64.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-EDIT                PIC -(5)9.
 01 WS-OBSERVED            PIC X(1024).
 PROCEDURE DIVISION.
     MOVE 0 TO WS-COUNT
     MOVE 1 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-FOUND = 0
         CALL "BUILTIN-PATH" USING WS-I WS-PATH WS-PATH-LENGTH WS-FOUND
         IF WS-FOUND = 1
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "builtin pack lists 243 files (08 §10.9 kinds read in this version: item textures, "
         & "models and definitions included)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 243 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-OBSERVED
     MOVE 0 TO WS-FAILED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 118
         MOVE WS-R-FILE(WS-I) TO WS-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
         MOVE WS-R-PATH(WS-I) TO WS-JPATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-JPATH)) TO WS-JPATH-LENGTH
         IF WS-R-FILE(WS-I)(1:22) = "assets/cobolcraft/lang"
             CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JPATH WS-JPATH-LENGTH WS-NODE
         ELSE
             CALL "JSON-FIND" USING JSON-DOC WS-JPATH WS-JPATH-LENGTH WS-NODE
         END-IF
         MOVE SPACES TO WS-VALUE
         MOVE 0 TO WS-VALUE-LENGTH
         IF WS-NODE > 0
             IF JN-TYPE(WS-NODE) = JT-NUMBER
                 COMPUTE WS-EDIT = JN-NUM(WS-NODE)
                 MOVE FUNCTION TRIM(WS-EDIT) TO WS-VALUE
             ELSE
                 CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-VALUE WS-VALUE-CAP WS-VALUE-LENGTH
             END-IF
         END-IF
         INSPECT WS-VALUE REPLACING ALL X"5C" BY "~" ALL X"00" BY "^"
         IF WS-VALUE NOT = WS-R-VALUE(WS-I) OR WS-FOUND NOT = 1 OR JD-ERROR = 1
             ADD 1 TO WS-FAILED
             STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-R-FILE(WS-I)) ":"
                 FUNCTION TRIM(WS-R-PATH(WS-I)) "=" FUNCTION TRIM(WS-VALUE)
                 DELIMITED BY SIZE INTO WS-OBSERVED
         END-IF
     END-PERFORM
     MOVE "builtin pack files hold the values of 08 §10 (pack.mcmeta, atlases, models, block "
         & "states, font, lang)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "all equal" TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     IF WS-FAILED = 0
         MOVE "all equal" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/cobolcraft/lang/en_us.json" TO WS-PATH
     MOVE 33 TO WS-PATH-LENGTH
     CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
     MOVE "builtin lang/en_us.json is one object of the 211 keys of 08 §10.8 and the 9 "
         & "cobolcraft.packs.* and cobolcraft.world_type.* keys of 22 §9.2 and ui §7.2, the 7 options keys, the 12 recipe book keys and the 20 menu keys of 40-3 and 40-5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 292 TO TL-EXPECTED-N
     MOVE JN-COUNT(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "pack.mcmeta" TO WS-PATH
     MOVE 11 TO WS-PATH-LENGTH
     CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-COUNT
     MOVE "assets/cobolcraft/none.json" TO WS-PATH
     MOVE 26 TO WS-PATH-LENGTH
     CALL "BUILTIN-READ" USING WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH WS-FOUND
     MOVE "builtin a path the pack does not have is not found (and nothing is read), while "
         & "pack.mcmeta is" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COUNT * 10 + WS-FOUND + WS-LENGTH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BUILTIN-FILES.
