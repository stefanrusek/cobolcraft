*> C glue ABI constants and record layouts (specs/001-cobolcraft-complete/contracts/shim-abi.md).
*> Contract artifact (constitution 3.3): produced from the contract document, never edited by lanes.
*> C mirror: contract/include/ccshim.h. Calls: CALL STATIC "cc_..." USING BY VALUE BINARY-LONG ...
*> BY REFERENCE buffer RETURNING BINARY-LONG (research R2); 0 is success.

*> Defined outcomes (§1, §3 to §7).
 78 CC-AGAIN                VALUE 1.
 78 CC-ADDR-IN-USE          VALUE 2.
 78 CC-UNRESOLVED           VALUE 3.
 78 CC-CLOSED               VALUE 4.
 78 CC-SMALL                VALUE 5.
 78 CC-BADDATA              VALUE 6.
 78 CC-NOTFOUND             VALUE 7.

*> Compression modes (§5).
 78 CC-ZLIB                 VALUE 0.
 78 CC-GZIP                 VALUE 1.
 78 CC-RAW                  VALUE 2.

*> Pipelines (§9).
 78 CC-PIPE-OPAQUE          VALUE 0.
 78 CC-PIPE-TRANSLUCENT     VALUE 1.
 78 CC-PIPE-UI              VALUE 2.

*> Texture ids (§9).
 78 CC-TEX-BLOCKS           VALUE 0.   *> block and item atlas
 78 CC-TEX-ENTITIES         VALUE 1.   *> entity atlas
 78 CC-TEX-UI               VALUE 2.   *> font and UI atlas
 78 CC-TEX-ENVIRONMENT      VALUE 3.   *> environment atlas

*> Vertex buffer slots of cc_vk_mesh (§9).
 78 CC-MESH-SLOT-MIN        VALUE 1.
 78 CC-MESH-SLOT-MAX        VALUE 65535.

*> Event kinds (§8).
 78 CC-EV-KEY-DOWN          VALUE 1.
 78 CC-EV-KEY-UP            VALUE 2.
 78 CC-EV-TEXT              VALUE 3.
 78 CC-EV-BUTTON-DOWN       VALUE 4.
 78 CC-EV-BUTTON-UP         VALUE 5.
 78 CC-EV-CURSOR            VALUE 6.
 78 CC-EV-SCROLL            VALUE 7.
 78 CC-EV-RESIZE            VALUE 8.
 78 CC-EV-CLOSE-REQUEST     VALUE 9.

*> Event record sizes (§8, §9).
 78 CC-EVENT-SIZE           VALUE 24.
 78 CC-VERTEX-SIZE          VALUE 28.

*> Mouse buttons (§8).
 78 CC-BUTTON-LEFT          VALUE 0.
 78 CC-BUTTON-RIGHT         VALUE 1.
 78 CC-BUTTON-MIDDLE        VALUE 2.

*> Modifier bits of event field b (GLFW_MOD_*; Ctrl+Q of client-surface.md §3).
 78 CC-MOD-SHIFT            VALUE 1.
 78 CC-MOD-CONTROL          VALUE 2.

*> GLFW key codes of every control of client-surface.md §3 (GLFW numeric values; COBOL never
*> includes GLFW headers).
 78 CC-KEY-SPACE            VALUE 32.
 78 CC-KEY-SLASH            VALUE 47.
 78 CC-KEY-1                VALUE 49.
 78 CC-KEY-2                VALUE 50.
 78 CC-KEY-3                VALUE 51.
 78 CC-KEY-4                VALUE 52.
 78 CC-KEY-5                VALUE 53.
 78 CC-KEY-6                VALUE 54.
 78 CC-KEY-7                VALUE 55.
 78 CC-KEY-8                VALUE 56.
 78 CC-KEY-9                VALUE 57.
 78 CC-KEY-A                VALUE 65.
 78 CC-KEY-C                VALUE 67.
 78 CC-KEY-D                VALUE 68.
 78 CC-KEY-E                VALUE 69.
 78 CC-KEY-Q                VALUE 81.
 78 CC-KEY-S                VALUE 83.
 78 CC-KEY-T                VALUE 84.
 78 CC-KEY-W                VALUE 87.
 78 CC-KEY-ESCAPE           VALUE 256.
 78 CC-KEY-LEFT-SHIFT       VALUE 340.
 78 CC-KEY-LEFT-CONTROL     VALUE 341.
*> Text-entry keys (chat, screens): characters arrive as CC-EV-TEXT; these keys do not.
 78 CC-KEY-ENTER            VALUE 257.
 78 CC-KEY-BACKSPACE        VALUE 259.

*> Event record (§8): 24 bytes, little-endian (native byte order of BINARY-LONG and FLOAT-SHORT
*> on arm64). cc_win_poll fills a buffer of these.
 01 CC-EVENT.
    05 CC-EV-KIND           BINARY-LONG.
    05 CC-EV-A              BINARY-LONG.
    05 CC-EV-B              BINARY-LONG.
    05 CC-EV-C              BINARY-LONG.
    05 CC-EV-X              FLOAT-SHORT.
    05 CC-EV-Y              FLOAT-SHORT.

*> Vertex (§9, research R4): 7 x float32 = 28 bytes.
 01 CC-VERTEX.
    05 CC-VX-X              FLOAT-SHORT.
    05 CC-VX-Y              FLOAT-SHORT.
    05 CC-VX-Z              FLOAT-SHORT.
    05 CC-VX-U              FLOAT-SHORT.
    05 CC-VX-V              FLOAT-SHORT.
    05 CC-VX-BRIGHTNESS     FLOAT-SHORT.
    05 CC-VX-ALPHA          FLOAT-SHORT.
