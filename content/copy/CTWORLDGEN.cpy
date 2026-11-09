*> The world generation store of the content library (docs/protocol/10-world-generation-terrain.md sections 3.3, 4, 5, 7,
*> 9.1 and 10; 11 sections 5 and 7; 23 section 7; 37 parts 2 to 4; 43 section 5; 04 section 6). EXTERNAL: every program
*> that copies this book shares the one record. The loaders of worldgen-density.cob, worldgen-biomes.cob,
*> worldgen-settings.cob and dimensions.cob fill it from a data tree; WORLDGEN-FREE empties it. Package-private.
*>
*> Every loaded file is a function row (WGF-ROW: its kind, its element id, the root node) over a tree of nodes
*> (WGN-ROW). A node has a domain (what the node is: WGN-DOMAIN below), a type (the row of the type table of
*> worldgen-density.cob, WG-TYPE-AT; 0 for a reference to another element by id, kept in WGN-TEXT(1)), child
*> links (WGN-CHILD, filled in the order of the type's fields; 0 for a child that is left out; an array is the first
*> element, the next ones follow WGN-NEXT), numbers (WGN-NUM, doubles read with cc_f64_from_text, so each is the
*> nearest double of its text), integers (WGN-INT; a boolean is 0 or 1, an enum the 0-based position of its
*> value in the list of the type's field, an anchor two integers: the kind 1 absolute, 2 above_bottom, 3 below_top,
*> 4 relative_to_sea_level, then its value, a colour its 24 bit RGB value or -1 when the file leaves it out) and
*> texts. The slots are used in the order the fields of the type are listed (WG-TYPE-AT gives the field list).
*>
*> Domains: 1 density function, 2 surface rule, 3 surface condition, 4 ore rule test, 5 int provider, 6 float
*> provider, 7 height provider, 8 carver, 9 configured feature (only ore features are kept), 10 ore target
*> (state, rule), 11 noise settings, 12 spawn target box, 13 biome, 14 a placed feature id of a biome (WGN-INT(1)
*> the decoration step, WGN-TEXT(1) the id), 15 noise definition, 16 multi-noise biome source list, 17 dimension type.
*> Function kinds: 1 density_function (domain 1), 2 material_rule (2), 3 material_condition (3), 4 carver (8),
*> 5 feature (9), 6 noise_settings (11), 7 biome (13), 8 noise (15), 9 multi_noise_biome_source_parameter_list
*> (16), 10 dimension_type (17).
*> A spline (WSP-ROW) is a constant (WSP-N 0, WSP-CONST) or a coordinate density function (WSP-COORD, a node) with
*> WSP-N points from WPT-ROW(WSP-FIRST) on, each a location, a derivative and a spline (WPT-VALUE, a row of WSP).
 78 WGK-NODE              VALUE 1.
 78 WGK-SPLINE            VALUE 2.
 78 WGK-POINT             VALUE 3.
 78 WGK-FUNCTION          VALUE 4.
*> The used rows of the four tables (WG-ALLOC checks them against 32768, 16384, 24576 and 4096).
 01 WG-STORE EXTERNAL.
    05 WG-COUNTS.
       10 WG-COUNT          BINARY-LONG OCCURS 4 TIMES.
    05 WGN-ROW OCCURS 32768 TIMES.
       10 WGN-DOMAIN        BINARY-LONG.
       10 WGN-TYPE          BINARY-LONG.
       10 WGN-NEXT          BINARY-LONG.
       10 WGN-CHILD         BINARY-LONG OCCURS 16 TIMES.
       10 WGN-NUM           FLOAT-LONG OCCURS 10 TIMES.
       10 WGN-INT           BINARY-LONG OCCURS 12 TIMES.
       10 WGN-TEXT-1        PIC X(160).
       10 WGN-TEXT-2        PIC X(64).
    05 WSP-ROW OCCURS 16384 TIMES.
       10 WSP-COORD         BINARY-LONG.
       10 WSP-FIRST         BINARY-LONG.
       10 WSP-N             BINARY-LONG.
       10 WSP-CONST         FLOAT-LONG.
    05 WPT-ROW OCCURS 24576 TIMES.
       10 WPT-LOCATION      FLOAT-LONG.
       10 WPT-DERIVATIVE    FLOAT-LONG.
       10 WPT-VALUE         BINARY-LONG.
    05 WGF-ROW OCCURS 4096 TIMES.
       10 WGF-KIND          BINARY-LONG.
       10 WGF-KEY           PIC X(64).
       10 WGF-ROOT          BINARY-LONG.

*> The loader's own state: the label of the registry being read (error text "ERROR registry: <label> <key>: <detail>"),
*> and the start and length of the text of each number node of the file being read (WG-PARSE-DOC; indexed by node).
 01 WG-STATE EXTERNAL.
    05 WG-LABEL             PIC X(32).
    05 WG-NUM-POS           BINARY-LONG OCCURS 4096 TIMES.
    05 WG-NUM-LEN           BINARY-LONG OCCURS 4096 TIMES.
