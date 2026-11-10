*> Protocol codec records (specs/001-cobolcraft-complete/contracts/proto-api.md §1 and §2).
*> Contract artifact (constitution 3.3): produced from the contract document, never edited by lanes.
*> PB-BUFFER is transcribed from proto-api.md §1. The value records of the composite entry points
*> (proto-api.md §2) carry exactly the fields CobolCraft uses (wire-profile.md, standin-content §2:
*> no data components), derived from docs/protocol/00-data-types.md §9, §12, §13, 05a 0x10 Commands and
*> 05b Recipe Book Add. Every text field has an explicit byte length (UTF-8, trailing spaces kept).

 01 PB-BUFFER.                       *> growable byte buffer
    05 PB-ADDR        USAGE POINTER.
    05 PB-CAPACITY    BINARY-LONG.
    05 PB-LENGTH      BINARY-LONG.   *> bytes written
    05 PB-POS         BINARY-LONG.   *> read position (0-based)
    05 PB-ERROR       PIC 9.         *> 1 after a read past PB-LENGTH or a malformed value

*> ---------------------------------------------------------------------------------------------
*> ITEMSTACK (00 §12.1, optional form). Count 0 = empty stack: nothing else on the wire. A non-empty
*> stack is written with an empty DataComponentPatch (AddedCount 0, RemovedCount 0); a decoded stack
*> with components is malformed for CobolCraft (PB-ERROR).
 01 PB-ITEMSTACK.
    05 PB-IS-COUNT        BINARY-LONG.   *> 0 = empty
    05 PB-IS-ITEM         BINARY-LONG.   *> RegistryId<item> (standin-content §2); only if count > 0

*> ---------------------------------------------------------------------------------------------
*> TEXT (00 §9.1 network NBT text component; proto-api.md §2): a plain string tag, a compound
*> {"text":…}, or a compound {"translate":…,"with":[…]} whose arguments are plain strings.
 78 PB-TEXT-PLAIN          VALUE 0.   *> NBT string tag
 78 PB-TEXT-LITERAL        VALUE 1.   *> {"text": PB-TX-VALUE}
 78 PB-TEXT-TRANSLATE      VALUE 2.   *> {"translate": PB-TX-VALUE, "with": [PB-TX-ARG...]}
 78 PB-TEXT-MAX-ARGS       VALUE 8.
 01 PB-TEXT.
    05 PB-TX-KIND         PIC 9.
    05 PB-TX-LENGTH       BINARY-LONG.   *> bytes of PB-TX-VALUE used
    05 PB-TX-VALUE        PIC X(1024).   *> the text, or the translation key
    05 PB-TX-ARG-COUNT    BINARY-LONG.   *> translate only: 0 to PB-TEXT-MAX-ARGS ("with" omitted at 0)
    05 PB-TX-ARG          OCCURS 8 TIMES.
       10 PB-TX-ARG-LENGTH BINARY-LONG.
       10 PB-TX-ARG-VALUE  PIC X(1024).

*> ---------------------------------------------------------------------------------------------
*> ENTITY-METADATA entry (00 §13.1): one entry of a Set Entity Data list (UByte index, VarInt
*> serializer, value). The list ends with index PB-MD-END. The value field used depends on the
*> serializer: BYTE, INT, BOOLEAN and POSE in PB-MD-INT; FLOAT in PB-MD-FLOAT; ITEM_STACK in
*> PB-MD-IS-COUNT/PB-MD-IS-ITEM (same meaning as PB-ITEMSTACK; wire-profile.md §3.3 ground items).
 78 PB-MD-END              VALUE 255.
 78 PB-MDS-BYTE            VALUE 0.
 78 PB-MDS-INT             VALUE 1.
 78 PB-MDS-FLOAT           VALUE 3.
 78 PB-MDS-ITEM-STACK      VALUE 7.
 78 PB-MDS-BOOLEAN         VALUE 8.
 78 PB-MDS-POSE            VALUE 20.
 01 PB-METADATA-ENTRY.
    05 PB-MD-INDEX        BINARY-LONG.   *> 0 to 254, or PB-MD-END
    05 PB-MD-SERIALIZER   BINARY-LONG.   *> 00 §13.2 serializer id
    05 PB-MD-INT          BINARY-LONG.
    05 PB-MD-FLOAT        FLOAT-SHORT.
    05 PB-MD-IS-COUNT     BINARY-LONG.
    05 PB-MD-IS-ITEM      BINARY-LONG.

*> ---------------------------------------------------------------------------------------------
*> SLOT-DISPLAY (05b SlotDisplay): the non-recursive types CobolCraft uses. empty has no body; item
*> uses PB-SD-ITEM; item_stack uses PB-SD-ITEM and PB-SD-COUNT (ItemStackTemplate without
*> components). Any other type decodes as malformed (PB-ERROR).
 78 PB-SLOT-EMPTY          VALUE 0.
 78 PB-SLOT-ITEM           VALUE 4.
 78 PB-SLOT-ITEM-STACK     VALUE 5.
 01 PB-SLOT-DISPLAY.
    05 PB-SD-TYPE         BINARY-LONG.
    05 PB-SD-ITEM         BINARY-LONG.   *> RegistryId<item>
    05 PB-SD-COUNT        BINARY-LONG.   *> item_stack only

*> ---------------------------------------------------------------------------------------------
*> RECIPE-DISPLAY (05b RecipeDisplayEntry and RecipeDisplay, crafting types only; Recipe Book Add,
*> wire-profile.md §3.3). Ingredients, result and station are SlotDisplays with the layout of
*> PB-SLOT-DISPLAY. Crafting requirements: each ingredient is a HolderSet<item> of one direct item id.
 78 PB-RECIPE-SHAPELESS    VALUE 0.
 78 PB-RECIPE-SHAPED       VALUE 1.
 78 PB-RECIPE-MAX-SLOTS    VALUE 9.
 01 PB-RECIPE-DISPLAY.
    05 PB-RD-DISPLAY-ID   BINARY-LONG.   *> RecipeDisplayId (data-model §8: index in the recipe list)
    05 PB-RD-TYPE         BINARY-LONG.   *> PB-RECIPE-SHAPELESS or PB-RECIPE-SHAPED
    05 PB-RD-WIDTH        BINARY-LONG.   *> shaped only
    05 PB-RD-HEIGHT       BINARY-LONG.   *> shaped only
    05 PB-RD-INGREDIENT-COUNT BINARY-LONG.
    05 PB-RD-INGREDIENT   OCCURS 9 TIMES.
       10 PB-RD-IN-TYPE   BINARY-LONG.
       10 PB-RD-IN-ITEM   BINARY-LONG.
       10 PB-RD-IN-COUNT  BINARY-LONG.
    05 PB-RD-RESULT.
       10 PB-RD-RES-TYPE  BINARY-LONG.
       10 PB-RD-RES-ITEM  BINARY-LONG.
       10 PB-RD-RES-COUNT BINARY-LONG.
    05 PB-RD-STATION.
       10 PB-RD-ST-TYPE   BINARY-LONG.
       10 PB-RD-ST-ITEM   BINARY-LONG.
       10 PB-RD-ST-COUNT  BINARY-LONG.
    05 PB-RD-GROUP        BINARY-LONG.   *> OptionalVarInt: 0 = no group, else group index + 1
    05 PB-RD-CATEGORY     BINARY-LONG.   *> RegistryId<recipe_book_category>
    05 PB-RD-REQ-PRESENT  PIC 9.         *> 1 = crafting requirements present
    05 PB-RD-REQ-COUNT    BINARY-LONG.
    05 PB-RD-REQ-ITEM     BINARY-LONG OCCURS 9 TIMES.

*> ---------------------------------------------------------------------------------------------
*> COMMAND-NODE (05a 0x10 CommandNode): one node of the Commands tree. Parsers used
*> (wire-profile.md §3.3): brigadier:double, brigadier:integer (NumberRange), brigadier:string
*> (string kind), game_profile (none).
 78 PB-NODE-ROOT           VALUE 0.
 78 PB-NODE-LITERAL        VALUE 1.
 78 PB-NODE-ARGUMENT       VALUE 2.
 78 PB-NODE-EXECUTABLE     VALUE 4.    *> flag bit 0x04
 78 PB-NODE-HAS-REDIRECT   VALUE 8.    *> flag bit 0x08
 78 PB-NODE-HAS-SUGGEST    VALUE 16.   *> flag bit 0x10
 78 PB-PARSER-DOUBLE       VALUE 2.
 78 PB-PARSER-INTEGER      VALUE 3.
 78 PB-PARSER-STRING       VALUE 5.
 78 PB-PARSER-GAME-PROFILE VALUE 7.
 78 PB-STRING-SINGLE-WORD  VALUE 0.
 78 PB-STRING-QUOTABLE     VALUE 1.
 78 PB-STRING-GREEDY       VALUE 2.
 78 PB-RANGE-HAS-MIN       VALUE 1.
 78 PB-RANGE-HAS-MAX       VALUE 2.
 78 PB-NODE-MAX-CHILDREN   VALUE 64.
 01 PB-COMMAND-NODE.
    05 PB-CN-FLAGS        BINARY-LONG.   *> type (flags mod 4) plus the flag bits above
    05 PB-CN-CHILD-COUNT  BINARY-LONG.
    05 PB-CN-CHILD        BINARY-LONG OCCURS 64 TIMES.   *> node indices
    05 PB-CN-REDIRECT     BINARY-LONG.   *> only with PB-NODE-HAS-REDIRECT
    05 PB-CN-NAME-LENGTH  BINARY-LONG.
    05 PB-CN-NAME         PIC X(32).     *> literal and argument nodes
    05 PB-CN-PARSER       BINARY-LONG.   *> argument nodes
    05 PB-CN-STRING-KIND  BINARY-LONG.   *> PB-PARSER-STRING
    05 PB-CN-RANGE-FLAGS  BINARY-LONG.   *> PB-PARSER-INTEGER and PB-PARSER-DOUBLE
    05 PB-CN-MIN-INT      BINARY-LONG.
    05 PB-CN-MAX-INT      BINARY-LONG.
    05 PB-CN-MIN-DOUBLE   FLOAT-LONG.
    05 PB-CN-MAX-DOUBLE   FLOAT-LONG.
    05 PB-CN-SUGGEST-LENGTH BINARY-LONG.
    05 PB-CN-SUGGEST      PIC X(64).     *> Identifier, only with PB-NODE-HAS-SUGGEST

*> =============================================================================================
*> Additions of specs/002-client-polish/contracts/wire-delta.md section 3 (T0050). Records only:
*> the records above keep their layout, so the 001 encoders and decoders are unchanged. The new
*> PB-PUT-* and PB-GET-* programs of `proto` use these.
*> =============================================================================================

*> ---------------------------------------------------------------------------------------------
*> ITEMSTACK-X (00 12.1 and 12.2): an item stack with a DataComponentPatch. Count 0 = empty (the
*> record then holds only PB-ISX-COUNT). Component values are type-specific (00 12.2 leaves the
*> per-type content to the component's own codec): each added entry carries its value as the
*> bytes of that codec, PB-ISX-VALUE-LENGTH of PB-ISX-VALUE, written and read verbatim.
 78 PB-ISX-MAX-COMPONENTS  VALUE 32.
 78 PB-ISX-VALUE-MAX       VALUE 2048.
 01 PB-ITEMSTACK-X.
    05 PB-ISX-COUNT          BINARY-LONG.
    05 PB-ISX-ITEM           BINARY-LONG.   *> RegistryId<item>; only if count > 0
    05 PB-ISX-ADDED-COUNT    BINARY-LONG.   *> 0 to PB-ISX-MAX-COMPONENTS
    05 PB-ISX-REMOVED-COUNT  BINARY-LONG.   *> 0 to PB-ISX-MAX-COMPONENTS
    05 PB-ISX-ADDED          OCCURS 32 TIMES.
       10 PB-ISX-TYPE          BINARY-LONG. *> RegistryId<data_component_type>
       10 PB-ISX-VALUE-LENGTH  BINARY-LONG.
       10 PB-ISX-VALUE         PIC X(2048).
    05 PB-ISX-REMOVED        BINARY-LONG OCCURS 32 TIMES.

*> ---------------------------------------------------------------------------------------------
*> HASHED-STACK (00 12.4): the stack of a Container Click, with HashedPatchMap. Not present = empty.
 78 PB-HS-MAX-COMPONENTS    VALUE 32.
 01 PB-HASHED-STACK.
    05 PB-HS-PRESENT         PIC 9.         *> 0 = empty stack, nothing else
    05 PB-HS-ITEM            BINARY-LONG.
    05 PB-HS-COUNT           BINARY-LONG.
    05 PB-HS-ADDED-COUNT     BINARY-LONG.
    05 PB-HS-ADDED           OCCURS 32 TIMES.
       10 PB-HS-TYPE           BINARY-LONG.
       10 PB-HS-HASH           BINARY-LONG. *> Int CRC32C hash, signed
    05 PB-HS-REMOVED-COUNT   BINARY-LONG.
    05 PB-HS-REMOVED         BINARY-LONG OCCURS 32 TIMES.

*> ---------------------------------------------------------------------------------------------
*> METADATA-ENTRY-X (00 13, every serializer of the 13.2 table): UByte index, VarInt serializer,
*> value. Which fields are used follows the serializer's wire type:
*>   BYTE, INT, DIRECTION, BLOCK_STATE, OPTIONAL_BLOCK_STATE, POSE, every RegistryId variant,
*>   the IdEnum states, DYE_COLOR, HUMANOID_ARM, OPTIONAL_UNSIGNED_INT (the raw VarInt),
*>   BOOLEAN: PB-MX-INT; LONG: PB-MX-LONG; FLOAT, ROTATIONS (3), VECTOR3 (3), QUATERNION (4):
*>   PB-MX-FLOAT(1..n); STRING: PB-MX-TEXT; ITEM_STACK: PB-MX-STACK;
*>   BLOCK_POS and OPTIONAL_BLOCK_POS: PB-MX-POS and PB-MX-PRESENT (optional ones);
*>   OPTIONAL_LIVING_ENTITY_REFERENCE: PB-MX-UUID and PB-MX-PRESENT; VILLAGER_DATA: PB-MX-INT,
*>   PB-MX-INT-2, PB-MX-INT-3; COMPONENT, OPTIONAL_COMPONENT, PARTICLE, PARTICLES, OPTIONAL_GLOBAL_POS,
*>   PAINTING_VARIANT, RESOLVABLE_PROFILE: the value bytes verbatim in PB-MX-DATA (with PB-MX-PRESENT
*>   for the optional forms).
 78 PB-MX-DATA-MAX         VALUE 512.
 01 PB-METADATA-ENTRY-X.
    05 PB-MX-INDEX        BINARY-LONG.   *> 0 to 254, or PB-MD-END
    05 PB-MX-SERIALIZER   BINARY-LONG.   *> 00 13.2 id, 0 to 43
    05 PB-MX-INT          BINARY-LONG.
    05 PB-MX-INT-2        BINARY-LONG.
    05 PB-MX-INT-3        BINARY-LONG.
    05 PB-MX-LONG         BINARY-DOUBLE.
    05 PB-MX-FLOAT        FLOAT-SHORT OCCURS 4 TIMES.
    05 PB-MX-PRESENT      PIC 9.
    05 PB-MX-POS-X        BINARY-LONG.
    05 PB-MX-POS-Y        BINARY-LONG.
    05 PB-MX-POS-Z        BINARY-LONG.
    05 PB-MX-UUID         PIC X(16).
    05 PB-MX-TEXT-LENGTH  BINARY-LONG.
    05 PB-MX-TEXT         PIC X(256).
    05 PB-MX-STACK.
       10 PB-MX-IS-COUNT  BINARY-LONG.
       10 PB-MX-IS-ITEM   BINARY-LONG.
    05 PB-MX-DATA-LENGTH  BINARY-LONG.
    05 PB-MX-DATA         PIC X(512).

*> ---------------------------------------------------------------------------------------------
*> PALETTE-CONTAINER (06 5) in decoded form: the kind the bits byte selects, the palette, and the
*> entry values (entry index order of 06 5.4). The long packing of 06 6 is the encoder's and
*> decoder's job and never appears in the record. PB-PC-ENTRIES is 4096 for block states, 64 for
*> biomes. For PB-PC-DIRECT the values are global ids and the palette is empty; for PB-PC-SINGLE
*> the palette holds the one value and the entry values are not used.
 78 PB-PC-SINGLE           VALUE 0.
 78 PB-PC-INDIRECT         VALUE 1.
 78 PB-PC-DIRECT           VALUE 2.
 78 PB-PC-BLOCK-ENTRIES    VALUE 4096.
 78 PB-PC-BIOME-ENTRIES    VALUE 64.
 78 PB-PC-MAX-PALETTE      VALUE 256.
 01 PB-PALETTE-CONTAINER.
    05 PB-PC-KIND         BINARY-LONG.
    05 PB-PC-BITS         BINARY-LONG.   *> the bits byte as written (06 5.3)
    05 PB-PC-ENTRIES      BINARY-LONG.   *> 4096 or 64
    05 PB-PC-PALETTE-COUNT BINARY-LONG.
    05 PB-PC-PALETTE      BINARY-LONG OCCURS 256 TIMES.
    05 PB-PC-VALUE        BINARY-LONG OCCURS 4096 TIMES.

*> One section (06 4): the two counts and the two containers (same fields as PB-PALETTE-CONTAINER).
 01 PB-CHUNK-SECTION.
    05 PB-CS-NONEMPTY     BINARY-LONG.   *> Short: positions whose state is not air
    05 PB-CS-FLUID        BINARY-LONG.   *> Short: positions with a non-empty fluid state
    05 PB-CS-BLOCKS.
       10 PB-CSB-KIND         BINARY-LONG.
       10 PB-CSB-BITS         BINARY-LONG.
       10 PB-CSB-ENTRIES      BINARY-LONG.
       10 PB-CSB-PALETTE-COUNT BINARY-LONG.
       10 PB-CSB-PALETTE      BINARY-LONG OCCURS 256 TIMES.
       10 PB-CSB-VALUE        BINARY-LONG OCCURS 4096 TIMES.
    05 PB-CS-BIOMES.
       10 PB-CSI-KIND         BINARY-LONG.
       10 PB-CSI-BITS         BINARY-LONG.
       10 PB-CSI-ENTRIES      BINARY-LONG.
       10 PB-CSI-PALETTE-COUNT BINARY-LONG.
       10 PB-CSI-PALETTE      BINARY-LONG OCCURS 256 TIMES.
       10 PB-CSI-VALUE        BINARY-LONG OCCURS 64 TIMES.

*> ---------------------------------------------------------------------------------------------
*> COMMAND-NODE-X (05a 0x10 CommandNode, every parser of the registry table). Same flag constants
*> as PB-COMMAND-NODE plus PB-NODE-RESTRICTED. Parser ids are the registration order of 05a.
 78 PB-NODE-RESTRICTED     VALUE 32.   *> flag bit 0x20
 78 PB-NODE-MAX-CHILDREN-X VALUE 256.
 78 PB-CX-FLAG-SINGLE      VALUE 1.    *> entity flags byte
 78 PB-CX-FLAG-PLAYERS     VALUE 2.
 78 PB-CX-FLAG-MULTIPLE    VALUE 1.    *> score_holder flags byte
 78 PB-PX-BOOL                     VALUE 0.
 78 PB-PX-FLOAT                    VALUE 1.
 78 PB-PX-DOUBLE                   VALUE 2.
 78 PB-PX-INTEGER                  VALUE 3.
 78 PB-PX-LONG                     VALUE 4.
 78 PB-PX-STRING                   VALUE 5.
 78 PB-PX-ENTITY                   VALUE 6.
 78 PB-PX-GAME-PROFILE             VALUE 7.
 78 PB-PX-BLOCK-POS                VALUE 8.
 78 PB-PX-COLUMN-POS               VALUE 9.
 78 PB-PX-VEC3                     VALUE 10.
 78 PB-PX-VEC2                     VALUE 11.
 78 PB-PX-BLOCK-STATE              VALUE 12.
 78 PB-PX-BLOCK-PREDICATE          VALUE 13.
 78 PB-PX-ITEM-STACK               VALUE 14.
 78 PB-PX-ITEM-PREDICATE           VALUE 15.
 78 PB-PX-TEAM-COLOR               VALUE 16.
 78 PB-PX-HEX-COLOR                VALUE 17.
 78 PB-PX-COMPONENT                VALUE 18.
 78 PB-PX-STYLE                    VALUE 19.
 78 PB-PX-MESSAGE                  VALUE 20.
 78 PB-PX-NBT-COMPOUND-TAG         VALUE 21.
 78 PB-PX-NBT-TAG                  VALUE 22.
 78 PB-PX-NBT-PATH                 VALUE 23.
 78 PB-PX-OBJECTIVE                VALUE 24.
 78 PB-PX-OBJECTIVE-CRITERIA       VALUE 25.
 78 PB-PX-OPERATION                VALUE 26.
 78 PB-PX-PARTICLE                 VALUE 27.
 78 PB-PX-ANGLE                    VALUE 28.
 78 PB-PX-ROTATION                 VALUE 29.
 78 PB-PX-SCOREBOARD-SLOT          VALUE 30.
 78 PB-PX-SCORE-HOLDER             VALUE 31.
 78 PB-PX-SWIZZLE                  VALUE 32.
 78 PB-PX-TEAM                     VALUE 33.
 78 PB-PX-ITEM-SLOT                VALUE 34.
 78 PB-PX-ITEM-SLOTS               VALUE 35.
 78 PB-PX-RESOURCE-LOCATION        VALUE 36.
 78 PB-PX-FUNCTION                 VALUE 37.
 78 PB-PX-ENTITY-ANCHOR            VALUE 38.
 78 PB-PX-INT-RANGE                VALUE 39.
 78 PB-PX-FLOAT-RANGE              VALUE 40.
 78 PB-PX-DIMENSION                VALUE 41.
 78 PB-PX-GAMEMODE                 VALUE 42.
 78 PB-PX-TIME                     VALUE 43.
 78 PB-PX-RESOURCE-OR-TAG          VALUE 44.
 78 PB-PX-RESOURCE-OR-TAG-KEY      VALUE 45.
 78 PB-PX-RESOURCE                 VALUE 46.
 78 PB-PX-RESOURCE-KEY             VALUE 47.
 78 PB-PX-RESOURCE-SELECTOR        VALUE 48.
 78 PB-PX-TEMPLATE-MIRROR          VALUE 49.
 78 PB-PX-TEMPLATE-ROTATION        VALUE 50.
 78 PB-PX-HEIGHTMAP                VALUE 51.
 78 PB-PX-LOOT-TABLE               VALUE 52.
 78 PB-PX-LOOT-PREDICATE           VALUE 53.
 78 PB-PX-LOOT-MODIFIER            VALUE 54.
 78 PB-PX-CONTEXT-FLOAT-PROVIDER   VALUE 55.
 78 PB-PX-CONTEXT-INT-PROVIDER     VALUE 56.
 78 PB-PX-SLOT-SOURCE              VALUE 57.
 78 PB-PX-DIALOG                   VALUE 58.
 78 PB-PX-FEATURE                  VALUE 59.
 78 PB-PX-SWING-ANIMATION          VALUE 60.
 78 PB-PX-UUID                     VALUE 61.

 01 PB-COMMAND-NODE-X.
    05 PB-CX-FLAGS        BINARY-LONG.
    05 PB-CX-CHILD-COUNT  BINARY-LONG.
    05 PB-CX-CHILD        BINARY-LONG OCCURS 256 TIMES.
    05 PB-CX-REDIRECT     BINARY-LONG.
    05 PB-CX-NAME-LENGTH  BINARY-LONG.
    05 PB-CX-NAME         PIC X(64).
    05 PB-CX-PARSER       BINARY-LONG.   *> PB-PX-*; argument nodes
    05 PB-CX-STRING-KIND  BINARY-LONG.   *> PB-PX-STRING
    05 PB-CX-RANGE-FLAGS  BINARY-LONG.   *> float, double, integer, long
    05 PB-CX-MIN-INT      BINARY-LONG.
    05 PB-CX-MAX-INT      BINARY-LONG.
    05 PB-CX-MIN-LONG     BINARY-DOUBLE.
    05 PB-CX-MAX-LONG     BINARY-DOUBLE.
    05 PB-CX-MIN-FLOAT    FLOAT-SHORT.
    05 PB-CX-MAX-FLOAT    FLOAT-SHORT.
    05 PB-CX-MIN-DOUBLE   FLOAT-LONG.
    05 PB-CX-MAX-DOUBLE   FLOAT-LONG.
    05 PB-CX-FLAGS-BYTE   BINARY-LONG.   *> entity and score_holder property byte
    05 PB-CX-TIME-MIN     BINARY-LONG.   *> time
    05 PB-CX-REGISTRY-LENGTH BINARY-LONG.
    05 PB-CX-REGISTRY     PIC X(64).     *> resource, resource_key, resource_or_tag, ...: registry key
    05 PB-CX-SUGGEST-LENGTH BINARY-LONG.
    05 PB-CX-SUGGEST      PIC X(64).

*> ---------------------------------------------------------------------------------------------
*> SLOT-DISPLAY-TABLE (05b SlotDisplay, all eleven types): the recursive type as a table of nodes;
*> a child is the number of its node (1 to PB-SDT-COUNT), 0 = none. The table is shared by the
*> displays of one RECIPE-ENTRY.
 78 PB-SDX-EMPTY           VALUE 0.
 78 PB-SDX-ANY-FUEL        VALUE 1.
 78 PB-SDX-WITH-ANY-POTION VALUE 2.
 78 PB-SDX-ONLY-WITH-COMPONENT VALUE 3.
 78 PB-SDX-ITEM            VALUE 4.
 78 PB-SDX-ITEM-STACK      VALUE 5.
 78 PB-SDX-TAG             VALUE 6.
 78 PB-SDX-DYED            VALUE 7.
 78 PB-SDX-SMITHING-TRIM   VALUE 8.
 78 PB-SDX-WITH-REMAINDER  VALUE 9.
 78 PB-SDX-COMPOSITE       VALUE 10.
 78 PB-SDT-MAX-NODES       VALUE 32.
 01 PB-SLOT-DISPLAY-TABLE.
    05 PB-SDT-COUNT       BINARY-LONG.
    05 PB-SDT-NODE        OCCURS 32 TIMES.
       10 PB-SDN-TYPE       BINARY-LONG.
       10 PB-SDN-ITEM       BINARY-LONG.   *> item, item_stack (RegistryId<item>)
       10 PB-SDN-COUNT      BINARY-LONG.   *> item_stack
       10 PB-SDN-COMPONENT  BINARY-LONG.   *> only_with_component: RegistryId<data_component_type>
       10 PB-SDN-TAG-LENGTH BINARY-LONG.   *> tag: the HolderSet tag key
       10 PB-SDN-TAG        PIC X(64).
       10 PB-SDN-CHILD-A    BINARY-LONG.   *> source, dye, base, input, or the only child
       10 PB-SDN-CHILD-B    BINARY-LONG.   *> target, material, remainder
       10 PB-SDN-LIST-COUNT BINARY-LONG.   *> composite: 0 to 8 children
       10 PB-SDN-LIST       BINARY-LONG OCCURS 8 TIMES.
       10 PB-SDN-TRIM-LENGTH BINARY-LONG.  *> smithing_trim inline pattern: asset id
       10 PB-SDN-TRIM-ASSET PIC X(64).
       10 PB-SDN-TRIM-DECAL PIC 9.

*> ---------------------------------------------------------------------------------------------
*> RECIPE-ENTRY (05b RecipeBookAddEntry: RecipeDisplayEntry and its flags byte) for all five
*> RecipeDisplay types. Slots are nodes of a PB-SLOT-DISPLAY-TABLE. Use by type:
*>   shapeless:   PB-RE-INGREDIENT(1..count), result, station
*>   shaped:      width, height, PB-RE-INGREDIENT(1..count), result, station
*>   furnace:     ingredient = (1), fuel = (2), result, station, duration, experience
*>   stonecutter: input = (1), result, station
*>   smithing:    template, base, addition = (1..3), result, station
 78 PB-RT-SHAPELESS       VALUE 0.
 78 PB-RT-SHAPED          VALUE 1.
 78 PB-RT-FURNACE         VALUE 2.
 78 PB-RT-STONECUTTER     VALUE 3.
 78 PB-RT-SMITHING        VALUE 4.
 78 PB-RE-FLAG-NOTIFY     VALUE 1.
 78 PB-RE-FLAG-HIGHLIGHT  VALUE 2.
 78 PB-RE-REQ-MAX-LIST    VALUE 8.
 01 PB-RECIPE-ENTRY.
    05 PB-RE-DISPLAY-ID   BINARY-LONG.
    05 PB-RE-TYPE         BINARY-LONG.
    05 PB-RE-WIDTH        BINARY-LONG.
    05 PB-RE-HEIGHT       BINARY-LONG.
    05 PB-RE-INGREDIENT-COUNT BINARY-LONG.
    05 PB-RE-INGREDIENT   BINARY-LONG OCCURS 9 TIMES.
    05 PB-RE-RESULT       BINARY-LONG.
    05 PB-RE-STATION      BINARY-LONG.
    05 PB-RE-DURATION     BINARY-LONG.
    05 PB-RE-EXPERIENCE   FLOAT-SHORT.
    05 PB-RE-GROUP        BINARY-LONG.   *> OptionalVarInt: 0 = none, else group index + 1
    05 PB-RE-CATEGORY     BINARY-LONG.
    05 PB-RE-REQ-PRESENT  PIC 9.
    05 PB-RE-REQ-COUNT    BINARY-LONG.
    05 PB-RE-REQ-ITEM     BINARY-LONG OCCURS 9 TIMES.
*>   A requirement is a HolderSet<item> (T3663): the tag PB-RE-REQ-TAG(i) when PB-RE-REQ-TAG-LENGTH(i) is above 0, else the
*>   list PB-RE-REQ-LIST(i, 1..PB-RE-REQ-N(i)) of up to 8 item ids when PB-RE-REQ-N(i) is above 0, else the one item PB-RE-REQ-ITEM(i).
    05 PB-RE-REQ-ALT      OCCURS 9 TIMES.
       10 PB-RE-REQ-N          BINARY-LONG.
       10 PB-RE-REQ-LIST       BINARY-LONG OCCURS 8 TIMES.
       10 PB-RE-REQ-TAG-LENGTH BINARY-LONG.
       10 PB-RE-REQ-TAG        PIC X(64).
    05 PB-RE-FLAGS        BINARY-LONG.   *> PB-RE-FLAG-*

*> Recipe Book Settings (05b 0x4D): open and filtering for crafting, furnace, blast furnace, smoker.
 01 PB-RECIPE-BOOK-SETTINGS.
    05 PB-RBS-TYPE        OCCURS 4 TIMES.
       10 PB-RBS-OPEN       PIC 9.
       10 PB-RBS-FILTERING  PIC 9.

*> ---------------------------------------------------------------------------------------------
*> UPDATE-RECIPES (05b 0x88, docs/protocol 27 4.3; T3662): the recipe property sets (a key such as minecraft:smithing_base and
*> a list of item ids) and the stonecutter list: per entry the input HolderSet<item> (the tag PB-UC-TAG when PB-UC-TAG-LENGTH is
*> above 0, else the PB-UC-INPUT-COUNT ids of PB-UC-INPUT) and the SlotDisplay of the option, a node number of the
*> PB-SLOT-DISPLAY-TABLE the packet is written with or read into.
 78 PB-UR-MAX-SETS          VALUE 8.
 78 PB-UR-MAX-ITEMS         VALUE 256.
 78 PB-UR-MAX-CUTS          VALUE 32.
 78 PB-UR-MAX-INPUTS        VALUE 8.
 01 PB-UPDATE-RECIPES.
    05 PB-UR-SET-COUNT    BINARY-LONG.
    05 PB-UR-SET          OCCURS 8 TIMES.
       10 PB-UR-KEY-LENGTH  BINARY-LONG.
       10 PB-UR-KEY         PIC X(64).
       10 PB-UR-ITEM-COUNT  BINARY-LONG.
       10 PB-UR-ITEM        BINARY-LONG OCCURS 256 TIMES.
    05 PB-UR-CUT-COUNT    BINARY-LONG.
    05 PB-UR-CUT          OCCURS 32 TIMES.
       10 PB-UC-TAG-LENGTH  BINARY-LONG.
       10 PB-UC-TAG         PIC X(64).
       10 PB-UC-INPUT-COUNT BINARY-LONG.
       10 PB-UC-INPUT       BINARY-LONG OCCURS 8 TIMES.
       10 PB-UC-DISPLAY     BINARY-LONG.
