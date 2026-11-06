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
