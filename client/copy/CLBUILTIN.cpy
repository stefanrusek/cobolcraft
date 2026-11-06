*> File table of the built-in pack (docs/protocol/08-resource-packs.md §10.9 kinds read in this
*> version: §10.1, §10.2, §10.3 block textures, the operator entity texture and the font image, §10.4, §10.5, §10.6, §10.8, §10.10),
*> transcribed for client/src/packs/builtin.cob. Row i: the file path; for a model its parent
*> template; the content: a texture's file stem, a model's "textures" members, a block state
*> file's "variants" members (JSON text).
 78 BI-FILE-COUNT           VALUE 50.
 78 BI-FIRST-TEXTURE        VALUE 4.
 78 BI-LAST-TEXTURE         VALUE 20.
 78 BI-TEMPLATE-BOX         VALUE 21.
 78 BI-LAST-MODEL           VALUE 37.
 78 BI-LAST-STATE           VALUE 48.
 78 BI-FONT                 VALUE 49.
 78 BI-LANG-FILE            VALUE 50.
 01 BI-FILE-DATA.
    05 FILLER PIC X(64) VALUE "pack.mcmeta".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/blocks.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
    05 FILLER PIC X(64) VALUE "assets/minecraft/atlases/items.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/baseplate.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'baseplate'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/greystone.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'greystone'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/loam.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'loam'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/turf_top.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'turf_top'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/turf_side.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'turf_side'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/grit.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'grit'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/cardstack_end.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'cardstack_end'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/cardstack_side.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'cardstack_side'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/cardstack_side_punched.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'cardstack_side_punched'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/lucite.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'lucite'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/glowtube_lit.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'glowtube_lit'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/glowtube_unlit.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'glowtube_unlit'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/ledger_tile.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'ledger_tile'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/goto_pad.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'goto_pad'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/block/slag.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'slag'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/font/ascii.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'ascii'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/textures/entity/operator.png".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE 'operator'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_box.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_uniform.json".
    05 FILLER PIC X(24) VALUE "template_box".
    05 FILLER PIC X(480) VALUE '"particle":"#all","down":"#all","up":"#all","north":"#all","south":"#all","west"'
        & ':"#all","east":"#all"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_layered.json".
    05 FILLER PIC X(24) VALUE "template_box".
    05 FILLER PIC X(480) VALUE '"particle":"#side","up":"#top","down":"#bottom","north":"#side","south":"#side",'
        & '"west":"#side","east":"#side"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/template_pillar.json".
    05 FILLER PIC X(24) VALUE "template_box".
    05 FILLER PIC X(480) VALUE '"particle":"#side","up":"#end","down":"#end","north":"#side","south":"#side","we'
        & 'st":"#side","east":"#side"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/baseplate.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/baseplate"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/greystone.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/greystone"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/loam.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/loam"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/turf.json".
    05 FILLER PIC X(24) VALUE "template_layered".
    05 FILLER PIC X(480) VALUE '"top":"cobolcraft:block/turf_top","side":"cobolcraft:block/turf_side","bottom":"'
        & 'cobolcraft:block/loam"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/grit.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/grit"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack.json".
    05 FILLER PIC X(24) VALUE "template_pillar".
    05 FILLER PIC X(480) VALUE '"end":"cobolcraft:block/cardstack_end","side":"cobolcraft:block/cardstack_side"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/cardstack_punched.json".
    05 FILLER PIC X(24) VALUE "template_pillar".
    05 FILLER PIC X(480) VALUE '"end":"cobolcraft:block/cardstack_end","side":"cobolcraft:block/cardstack_side_p'
        & 'unched"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/lucite.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/lucite"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_lit.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/glowtube_lit"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/glowtube_unlit.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/glowtube_unlit"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/ledger_tile.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/ledger_tile"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/goto_pad.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/goto_pad"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/models/block/slag.json".
    05 FILLER PIC X(24) VALUE "template_uniform".
    05 FILLER PIC X(480) VALUE '"all":"cobolcraft:block/slag"'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/baseplate.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/baseplate"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/greystone.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/greystone"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/loam.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/loam"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/turf.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/turf"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/grit.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/grit"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/cardstack.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"axis=y,punched=false":{"model":"cobolcraft:block/cardstack"},"axis=y,punched=tr'
        & 'ue":{"model":"cobolcraft:block/cardstack_punched"},"axis=z,punched=false":{"mode'
        & 'l":"cobolcraft:block/cardstack","x":90},"axis=z,punched=true":{"model":"cobolcra'
        & 'ft:block/cardstack_punched","x":90},"axis=x,punched=false":{"model":"cobolcraft:'
        & 'block/cardstack","x":90,"y":90},"axis=x,punched=true":{"model":"cobolcraft:block'
        & '/cardstack_punched","x":90,"y":90}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/lucite.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/lucite"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/glowtube.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"lit=true":{"model":"cobolcraft:block/glowtube_lit"},"lit=false":{"model":"cobol'
        & 'craft:block/glowtube_unlit"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/ledger_tile.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/ledger_tile"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/goto_pad.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/goto_pad"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/blockstates/slag.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE '"":{"model":"cobolcraft:block/slag"}'.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/font/default.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
    05 FILLER PIC X(64) VALUE "assets/cobolcraft/lang/en_us.json".
    05 FILLER PIC X(24) VALUE SPACES.
    05 FILLER PIC X(480) VALUE SPACES.
 01 BI-FILE-TABLE REDEFINES BI-FILE-DATA.
    05 BI-FILE-ROW OCCURS 50 TIMES.
       10 BI-FILE            PIC X(64).
       10 BI-PARENT          PIC X(24).
       10 BI-CONTENT         PIC X(480).
