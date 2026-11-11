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
 78 CC-PIPE-CRUMBLING       VALUE 3.

*> Texture ids (§9).
 78 CC-TEX-BLOCKS           VALUE 0.   *> block and item atlas
 78 CC-TEX-ENTITIES         VALUE 1.   *> entity atlas
 78 CC-TEX-UI               VALUE 2.   *> font and UI atlas
 78 CC-TEX-ENVIRONMENT      VALUE 3.   *> environment atlas
 78 CC-TEX-PARTICLES        VALUE 4.   *> particle atlas

*> Texture wrap modes of cc_vk_texture_wrap (§9).
 78 CC-WRAP-CLAMP           VALUE 0.   *> clamp-to-edge (the default)
 78 CC-WRAP-REPEAT          VALUE 1.   *> repeat

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
 78 CC-VERTEX-SIZE          VALUE 44.

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
*> Keys named by docs/protocol/13 section 5.1 (F3 combinations) and section 7.3 (default bindings). Doc 13
*> 7.5 tabulates SDL-style scancodes (A = 4 ...); the shim reports GLFW codes, so these are GLFW values.
 78 CC-KEY-B                VALUE 66.
 78 CC-KEY-F                VALUE 70.
 78 CC-KEY-G                VALUE 71.
 78 CC-KEY-H                VALUE 72.
 78 CC-KEY-I                VALUE 73.
 78 CC-KEY-L                VALUE 76.
 78 CC-KEY-N                VALUE 78.
 78 CC-KEY-O                VALUE 79.
 78 CC-KEY-P                VALUE 80.
 78 CC-KEY-V                VALUE 86.
 78 CC-KEY-X                VALUE 88.
 78 CC-KEY-TAB              VALUE 258.
 78 CC-KEY-F1               VALUE 290.
 78 CC-KEY-F2               VALUE 291.
 78 CC-KEY-F3               VALUE 292.
 78 CC-KEY-F4               VALUE 293.
 78 CC-KEY-F5               VALUE 294.
 78 CC-KEY-F6               VALUE 295.
 78 CC-KEY-F11              VALUE 300.
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

*> Vertex (§9): 11 x float32 = 44 bytes. Colour drawn = texel x (CC-VX-R, G, B) x max(CC-VX-BRIGHTNESS,
*> CC-VX-SKY x daylight); an untinted vertex has tint 1 1 1, one that ignores the daylight has sky 0.
 01 CC-VERTEX.
    05 CC-VX-X              FLOAT-SHORT.
    05 CC-VX-Y              FLOAT-SHORT.
    05 CC-VX-Z              FLOAT-SHORT.
    05 CC-VX-U              FLOAT-SHORT.
    05 CC-VX-V              FLOAT-SHORT.
    05 CC-VX-BRIGHTNESS     FLOAT-SHORT.
    05 CC-VX-ALPHA          FLOAT-SHORT.
    05 CC-VX-SKY            FLOAT-SHORT.
    05 CC-VX-R              FLOAT-SHORT.
    05 CC-VX-G              FLOAT-SHORT.
    05 CC-VX-B              FLOAT-SHORT.

*> CALL shapes of the additions of contract/include/ccshim.h sections 9 to 12 (CALL STATIC; a COBOL
*> program cannot receive a C double, so every f64 operand is BY REFERENCE and the calls return nothing).
*> f64 items are COMP-2 (FLOAT-LONG); 32-bit integer results BINARY-LONG; 64-bit BINARY-DOUBLE.
*>   01 A USAGE FLOAT-LONG.  01 B USAGE FLOAT-LONG.  01 R USAGE FLOAT-LONG.
*>   01 I32 BINARY-LONG.  01 I64 BINARY-DOUBLE.  01 TXT PIC X(32) (z-string: ends with a NUL byte).
*>   Two operands:   CALL STATIC "cc_f64_add" USING BY REFERENCE A B R
*>                   (also sub, mul, div, fmod, min_j, max_j, copysign, pow, atan2_lib, atan2_mth)
*>   One operand:    CALL STATIC "cc_f64_floor" USING BY REFERENCE A R
*>                   (also ceil, sqrt, f32_round, signum, nextdown, next_up, abs_f32, abs_f64, log1p,
*>                   to_radians, log, sin, cos, asin, acos, sin_tab, cos_tab, fast_inv_sqrt)
*>   Text to double: CALL STATIC "cc_f64_from_text" USING BY REFERENCE TXT R
*>   Double to int:  CALL STATIC "cc_f64_to_i32" USING BY REFERENCE A I32   (also round_f32)
*>                   CALL STATIC "cc_f64_to_i64" USING BY REFERENCE A I64   (also round_f64, f64_bits)
*>   Int to double:  CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE I32 R
*>                   CALL STATIC "cc_f64_f64_from_bits" USING BY REFERENCE I64 R
*>   Three operands: CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE V LO HI R   (also clamp_f64)
*>                   CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE T A B R      (also lerp_f64)
*>   Texture (BINARY-LONG arguments BY VALUE, pixel buffer BY REFERENCE, RETURNING BINARY-LONG):
*>     CALL STATIC "cc_vk_texture_ex" USING BY VALUE TEX-ID W H BY REFERENCE RGBA BY VALUE MIP-LEVELS
*>         RETURNING RC
*>     CALL STATIC "cc_vk_texture_update" USING BY VALUE TEX-ID X Y W H BY REFERENCE RGBA RETURNING RC
*>   Daylight:       CALL STATIC "cc_vk_daylight" USING BY REFERENCE factor (FLOAT-SHORT, 0 to 1)
*>   Depth clear:    CALL STATIC "cc_vk_clear_depth"
*>   Open a path:    CALL STATIC "cc_open_path" USING BY REFERENCE OPENER-Z PATH-Z RETURNING RC
*>                   (both z-strings; 0 at once, CC-NOTFOUND when the opener cannot start)
