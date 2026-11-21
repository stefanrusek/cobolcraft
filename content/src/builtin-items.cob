*> The built-in item layer of the cobolcraft world type (T0205; docs/design/standin-content.md section 2,
*> cobolcraft-standard-core.md sections 5.2 to 5.4): nineteen items (ids 0 to 18) as rows of the same CT-ITEM-ROW
*> shape the generated standard table has. BLOCK is the block id a block item places (standin 1.1), STACK the
*> maximum stack size, and the summary holds the default components that differ from the prototype as
*> "name value" entries separated by ", ": the tool rule ("tool <block set> <speed>"), the attack modifiers
*> of core 5.3 ("attack_damage", "attack_speed": the attribute modifier amounts), "weapon" (damage per
*> attack), "food" (nutrition; saturation is 0.0) and "consumable" (consume seconds and animation, core
*> 5.4). The crafting bench item (id 18, appended: T0218) places block 12. Each line below is one row, its
*> columns separated by "|": id, key, class, block, stack, damage, flags, summary.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-ITEM-ROW.
*> USING item id (BINARY-LONG), row out (PIC X(270)), status out (CT-OK; CT-NOT-FOUND for an id outside 0 to 18,
*> the row left as it was), count out (BINARY-LONG: 19).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(190) VALUE "0|cobolcraft:nothing|AirItem||||||".
    05 FILLER PIC X(190) VALUE "1|cobolcraft:baseplate|BlockItem|1|64|||".
    05 FILLER PIC X(190) VALUE "2|cobolcraft:greystone|BlockItem|2|64|||".
    05 FILLER PIC X(190) VALUE "3|cobolcraft:loam|BlockItem|3|64|||".
    05 FILLER PIC X(190) VALUE "4|cobolcraft:turf|BlockItem|4|64|||".
    05 FILLER PIC X(190) VALUE "5|cobolcraft:grit|BlockItem|5|64|||".
    05 FILLER PIC X(190) VALUE "6|cobolcraft:cardstack|BlockItem|6|64|||".
    05 FILLER PIC X(190) VALUE "7|cobolcraft:lucite|BlockItem|7|64|||".
    05 FILLER PIC X(190) VALUE "8|cobolcraft:glowtube|BlockItem|8|64|||".
    05 FILLER PIC X(190) VALUE "9|cobolcraft:ledger_tile|BlockItem|9|64|||".
    05 FILLER PIC X(190) VALUE "10|cobolcraft:pry_bar|||1|||tool #minecraft:mineable/pickaxe 4.0, attack_damage 3.0, attack_speed -2.8, weapon 2".
    05 FILLER PIC X(190) VALUE "11|cobolcraft:trowel|||1|||tool #minecraft:mineable/shovel 4.0, attack_damage 1.0, attack_speed -3.0, weapon 2".
    05 FILLER PIC X(190) VALUE "12|cobolcraft:grazer_flank|||32|||food 3, consumable 1.6 eat".
    05 FILLER PIC X(190) VALUE "13|cobolcraft:seared_flank|||32|||food 8, consumable 1.6 eat".
    05 FILLER PIC X(190) VALUE "14|cobolcraft:sod_cake|||16|||food 2, consumable 1.6 eat".
    05 FILLER PIC X(190) VALUE "15|cobolcraft:dump_shard|||64|||".
    05 FILLER PIC X(190) VALUE "16|cobolcraft:goto_pad|BlockItem|10|16|||".
    05 FILLER PIC X(190) VALUE "17|cobolcraft:slag|BlockItem|11|64|||".
    05 FILLER PIC X(190) VALUE "18|cobolcraft:crafting_bench|BlockItem|12|64|||".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-LINE             PIC X(190) OCCURS 19 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BUILT.
    05 WS-B-ID             PIC X(4).
    05 WS-B-KEY            PIC X(38).
    05 WS-B-CLASS          PIC X(24).
    05 WS-B-BLOCK          PIC X(4).
    05 WS-B-STACK          PIC X(2).
    05 WS-B-DAMAGE         PIC X(4).
    05 WS-B-FLAGS          PIC X(34).
    05 WS-B-COMPONENTS     PIC X(160).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(270).
 01 L-STATUS               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ROW L-STATUS L-COUNT.
     MOVE 19 TO L-COUNT
     IF L-ID < 0 OR L-ID > 18
         MOVE CT-NOT-FOUND TO L-STATUS
         GOBACK
     END-IF
     COMPUTE WS-INDEX = L-ID + 1
     MOVE SPACES TO WS-BUILT
     UNSTRING WS-LINE(WS-INDEX) DELIMITED BY "|" INTO WS-B-ID WS-B-KEY WS-B-CLASS WS-B-BLOCK
         WS-B-STACK WS-B-DAMAGE WS-B-FLAGS WS-B-COMPONENTS
     MOVE WS-BUILT TO L-ROW
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM BUILTIN-ITEM-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-ITEM-TAGS.
*> No parameters: binds the built-in item tag of the cobolcraft set (cobolcraft-standard-core.md section 4.2) with
*> TAG-PUT: enchantable/mining holds the two tools.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-LINE                PIC X(120) VALUE "minecraft:enchantable/mining|10 11".
 PROCEDURE DIVISION.
     CALL "BUILTIN-TAG-LINE" USING WS-REGISTRY WS-LINE
     GOBACK.
 END PROGRAM BUILTIN-ITEM-TAGS.
