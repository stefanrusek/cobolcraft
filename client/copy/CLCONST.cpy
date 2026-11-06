*> Constants of the client program (data-model §13; contracts/shim-abi.md §9; client-surface.md).
*> Package-private: screen ids, widget kinds and actions of the screen model, the mesh slots, pipeline
*> and texture ids the client uses, face directions, and the block state table the renderer needs
*> (standin-content §1.1, §1.2: block key, properties of each state, opaque flag), transcribed.

*> Screens of the screen model (data-model §13).
 78 SCR-TITLE               VALUE 1.
 78 SCR-SERVER-LIST         VALUE 2.
 78 SCR-EDIT-SERVER         VALUE 3.
 78 SCR-CONNECTING          VALUE 4.
 78 SCR-WORLD               VALUE 5.
 78 SCR-INVENTORY           VALUE 6.
 78 SCR-CRAFTING            VALUE 7.
 78 SCR-CHAT                VALUE 8.
 78 SCR-PAUSE               VALUE 9.
 78 SCR-DEATH               VALUE 10.
 78 SCR-PACKS               VALUE 11.
 78 SCR-PACK-CONFIRM        VALUE 12.
 78 SCR-WORLD-LIST          VALUE 13.
 78 SCR-CREATE-WORLD        VALUE 14.
 78 SCR-CONFIRM-DELETE      VALUE 15.
 78 SCR-OPEN-TO-OTHERS      VALUE 16.

*> Widget kinds.
 78 WK-LABEL                VALUE 1.
 78 WK-BUTTON               VALUE 2.
 78 WK-FIELD                VALUE 3.   *> text field
 78 WK-ENTRY                VALUE 4.   *> list entry (selectable)
 78 WK-SLOT                 VALUE 5.   *> item slot: argument the slot 0 to 35 (36 = the stack on
                                       *> the cursor), state 1 = the held hotbar slot, text the count

*> Widget actions (what a click on the widget does).
 78 ACT-NONE                VALUE 0.
 78 ACT-MULTIPLAYER         VALUE 1.
 78 ACT-QUIT                VALUE 2.
 78 ACT-JOIN                VALUE 3.
 78 ACT-ADD                 VALUE 4.
 78 ACT-EDIT                VALUE 5.
 78 ACT-REMOVE              VALUE 6.
 78 ACT-BACK                VALUE 7.
 78 ACT-SELECT              VALUE 8.   *> list entry; the widget's argument is the entry index
 78 ACT-DONE                VALUE 9.
 78 ACT-CANCEL              VALUE 10.
 78 ACT-FIELD-NAME          VALUE 11.  *> focus the name field
 78 ACT-FIELD-ADDRESS       VALUE 12.  *> focus the address field
 78 ACT-RESUME              VALUE 13.
 78 ACT-DISCONNECT          VALUE 14.
 78 ACT-SLOT                VALUE 15.  *> inventory slot click; the widget's argument is the slot

*> Connections: the game connection and the server-list status ping.
 78 CONN-GAME               VALUE 1.
 78 CONN-PING               VALUE 2.
*> Connection phases.
 78 PH-NONE                 VALUE 0.
 78 PH-CONNECTING           VALUE 1.
 78 PH-STATUS               VALUE 2.
 78 PH-LOGIN                VALUE 3.
 78 PH-CONFIG               VALUE 4.
 78 PH-PLAY                 VALUE 5.

*> Server-list entry status.
 78 SLS-NONE                VALUE 0.   *> not asked yet
 78 SLS-PINGING             VALUE 1.
 78 SLS-ANSWERED            VALUE 2.
 78 SLS-UNREACHABLE         VALUE 3.

*> Mesh slots (cc_vk_mesh 1 to 65535): slot 1 is the user interface; each section of each replica
*> chunk row has an opaque and a translucent slot (MESH-SLOT-BASE + ((row - 1) * 16 + section) * 2,
*> + 1 for the translucent one).
 78 MESH-SLOT-UI            VALUE 1.
 78 MESH-SLOT-BASE          VALUE 2.
*> The entity figures of the frame (one mesh, eye-relative): above every section slot.
 78 MESH-SLOT-ENTITIES      VALUE 65000.
*> The item icons of the frame's slot widgets (texture 0), the slot counts drawn over them (texture 2)
*> and the target highlight outline (eye-relative, texture 2).
 78 MESH-SLOT-ICONS         VALUE 65001.
 78 MESH-SLOT-UI-TOP        VALUE 65002.
 78 MESH-SLOT-HIGHLIGHT     VALUE 65003.
*> The ground items of the frame (one mesh of item-icon billboards, eye-relative, texture 0).
 78 MESH-SLOT-GROUND-ITEMS  VALUE 65004.

*> Face directions (08 §5.4 names, block model axes of 08 §5.4.1: +x east, +y up, +z south).
 78 DIR-NONE                VALUE 0.
 78 DIR-DOWN                VALUE 1.
 78 DIR-UP                  VALUE 2.
 78 DIR-NORTH               VALUE 3.
 78 DIR-SOUTH               VALUE 4.
 78 DIR-WEST                VALUE 5.
 78 DIR-EAST                VALUE 6.

*> Limits of the client state (CLSTATE.cpy).
 78 CL-MAX-SERVERS          VALUE 32.
 78 CL-MAX-WIDGETS          VALUE 48.
 78 CL-MAX-CHUNKS           VALUE 1089.
 78 CL-MAX-SECTIONS         VALUE 16.
 78 CL-MAX-LANG             VALUE 640.
 78 CL-MAX-SPRITES          VALUE 128.
 78 CL-MAX-STATES           VALUE 18.
 78 CL-MAX-QUADS            VALUE 24.
 78 CL-MAX-DRAWS            VALUE 8192.
 78 CL-MAX-UPLOADS          VALUE 4096.
 78 CL-MAX-DIM-TYPES        VALUE 8.
 78 CL-MAX-PACKS            VALUE 16.
 78 CL-MAX-UI-VERTICES      VALUE 24576.
 78 CL-MAX-ENTITIES         VALUE 256.
 78 CL-MAX-PLAYER-INFO      VALUE 64.
 78 CL-MAX-ENTITY-VERTICES  VALUE 9216.
 78 CL-MAX-GI-VERTICES      VALUE 1536.
 78 CL-PROTOCOL             VALUE 777.
 78 CL-DEFAULT-PORT         VALUE 25565.
 78 CL-GUI-SCALE            VALUE 2.
 78 CL-TICK-MS              VALUE 50.
 78 CL-MAX-ICON-VERTICES    VALUE 1536.
 78 CL-MAX-TOP-VERTICES     VALUE 1536.
 78 CL-MAX-HL-VERTICES      VALUE 144.
 78 CL-ITEM-COUNT           VALUE 18.  *> item ids 0 to 17 (standin-content §2)
 78 CL-SLOT-SIZE            VALUE 20.  *> slot widget, GUI pixels (16-pixel icon, 2-pixel inset)
*> Block reach of the target ray, in blocks from the eye (standin-content §11.4).
 78 CL-REACH                VALUE 5.

*> Entity types (standin-content §3).
 78 ET-OPERATOR             VALUE 0.
 78 ET-LOOSE-ITEM           VALUE 1.
 78 ET-SODGRAZER            VALUE 2.
 78 ET-ABEND                VALUE 3.

*> UI atlas (texture 2) swatches: 8 x 8 cells below the font image, by index from 0 (x = index * 8).
 78 SW-WHITE                VALUE 0.
 78 SW-MISSING-GLYPH        VALUE 1.
 78 SW-PANEL                VALUE 2.
 78 SW-BUTTON               VALUE 3.
 78 SW-SELECTED             VALUE 4.
 78 SW-FIELD                VALUE 5.
 78 SW-COUNT                VALUE 6.

*> Items (standin-content §2): for item id i, row i + 1: key path (the item definition file name,
*> 08 §10.7), maximum stack size, the block state its item places (0 = places no block; cardstack
*> places its default state's block with the axis of the clicked face, §1.3), and the tool class
*> it speeds up ("H" hard, "S" soft, §2 pry_bar and trowel).
 01 CL-ITEM-DATA.
    05 FILLER PIC X(21) VALUE "nothing         0000 ".
    05 FILLER PIC X(21) VALUE "baseplate       6401 ".
    05 FILLER PIC X(21) VALUE "greystone       6402 ".
    05 FILLER PIC X(21) VALUE "loam            6403 ".
    05 FILLER PIC X(21) VALUE "turf            6404 ".
    05 FILLER PIC X(21) VALUE "grit            6405 ".
    05 FILLER PIC X(21) VALUE "cardstack       6409 ".
    05 FILLER PIC X(21) VALUE "lucite          6412 ".
    05 FILLER PIC X(21) VALUE "glowtube        6413 ".
    05 FILLER PIC X(21) VALUE "ledger_tile     6415 ".
    05 FILLER PIC X(21) VALUE "pry_bar         0100H".
    05 FILLER PIC X(21) VALUE "trowel          0100S".
    05 FILLER PIC X(21) VALUE "grazer_flank    3200 ".
    05 FILLER PIC X(21) VALUE "seared_flank    3200 ".
    05 FILLER PIC X(21) VALUE "sod_cake        1600 ".
    05 FILLER PIC X(21) VALUE "dump_shard      6400 ".
    05 FILLER PIC X(21) VALUE "goto_pad        1616 ".
    05 FILLER PIC X(21) VALUE "slag            6417 ".
 01 CL-ITEMS REDEFINES CL-ITEM-DATA.
    05 CL-IT OCCURS 18 TIMES.
       10 CL-IT-KEY         PIC X(16).
       10 CL-IT-MAX         PIC 99.
       10 CL-IT-STATE       PIC 99.
       10 CL-IT-TOOL        PIC X.

*> Blocks (standin-content §1.1, §2): for block id b, row b + 1: hand break time in milliseconds
*> (99999 = unbreakable, baseplate) and its class ("H" hard, "S" soft, space none).
 01 CL-BLOCK-DATA.
    05 FILLER PIC X(6) VALUE "00000 ".
    05 FILLER PIC X(6) VALUE "99999 ".
    05 FILLER PIC X(6) VALUE "01500H".
    05 FILLER PIC X(6) VALUE "00600S".
    05 FILLER PIC X(6) VALUE "00700S".
    05 FILLER PIC X(6) VALUE "00500S".
    05 FILLER PIC X(6) VALUE "01000H".
    05 FILLER PIC X(6) VALUE "00400 ".
    05 FILLER PIC X(6) VALUE "00300 ".
    05 FILLER PIC X(6) VALUE "01200H".
    05 FILLER PIC X(6) VALUE "02000 ".
    05 FILLER PIC X(6) VALUE "01200H".
 01 CL-BLOCKS REDEFINES CL-BLOCK-DATA.
    05 CL-BK OCCURS 12 TIMES.
       10 CL-BK-BREAK-MS    PIC 9(5).
       10 CL-BK-CLASS       PIC X.

*> Block states (standin-content §1.2): for state id s, row s + 1: block key path (the block state
*> file name, 08 §10.6), the state's properties as a variant key (sorted by name, 08 §4.2), and
*> whether the block is opaque (§1.1: occludes faces, blocks light). Block id: §1.1.
 01 CL-BLOCK-STATE-DATA.
    05 FILLER PIC X(64) VALUE "00void".
    05 FILLER PIC X(64) VALUE "11baseplate".
    05 FILLER PIC X(64) VALUE "21greystone".
    05 FILLER PIC X(64) VALUE "31loam".
    05 FILLER PIC X(64) VALUE "41turf".
    05 FILLER PIC X(64) VALUE "51grit".
    05 FILLER PIC X(64) VALUE "61cardstack axis=x,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=x,punched=false".
    05 FILLER PIC X(64) VALUE "61cardstack axis=y,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=y,punched=false".
    05 FILLER PIC X(64) VALUE "61cardstack axis=z,punched=true".
    05 FILLER PIC X(64) VALUE "61cardstack axis=z,punched=false".
    05 FILLER PIC X(64) VALUE "70lucite".
    05 FILLER PIC X(64) VALUE "81glowtube lit=true".
    05 FILLER PIC X(64) VALUE "81glowtube lit=false".
    05 FILLER PIC X(64) VALUE "91ledger_tile".
    05 FILLER PIC X(64) VALUE "A1goto_pad".
    05 FILLER PIC X(64) VALUE "B1slag".
 01 CL-BLOCK-STATES REDEFINES CL-BLOCK-STATE-DATA.
    05 CL-BS OCCURS 18 TIMES.
       10 CL-BS-BLOCK       PIC X.       *> block id in hex (0 to B)
       10 CL-BS-OPAQUE      PIC 9.
       10 CL-BS-TEXT        PIC X(62).   *> "<block path>[ <variant key>]"
