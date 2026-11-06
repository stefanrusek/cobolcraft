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
 78 CL-PROTOCOL             VALUE 777.
 78 CL-DEFAULT-PORT         VALUE 25565.
 78 CL-GUI-SCALE            VALUE 2.
 78 CL-TICK-MS              VALUE 50.

*> UI atlas (texture 2) swatches: 8 x 8 cells below the font image, by index from 0 (x = index * 8).
 78 SW-WHITE                VALUE 0.
 78 SW-MISSING-GLYPH        VALUE 1.
 78 SW-PANEL                VALUE 2.
 78 SW-BUTTON               VALUE 3.
 78 SW-SELECTED             VALUE 4.
 78 SW-FIELD                VALUE 5.
 78 SW-COUNT                VALUE 6.

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
