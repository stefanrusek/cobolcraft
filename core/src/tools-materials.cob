*> The tool materials (docs/protocol/17 section 2.1; US14, T2019): durability, mining speed, attack bonus, enchantability, repair
*> ingredient, the block tag whose blocks the material is incorrect for (it denies their drops) and the needs_* tiers that tag holds.
*>
*> Entry point:
*>   TOOL-MATERIAL USING material (PIC X(12): wooden, stone, copper, iron, golden, diamond, netherite), durability, mining speed,
*>     attack bonus, enchantability (BINARY-LONG each), repair ingredient (PIC X(40): an item key, or "#" and a tag), incorrect-for tag
*>     (PIC X(48)), denied needs_* tiers (PIC X(24): "stone iron diamond", "none"), found out (1 or 0; the others are 0 or blank)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-MATERIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LINES.
    05 FILLER PIC X(140) VALUE "wooden|59|2|0|15|#minecraft:wooden_tool_materials|minecraft:incorrect_for_wooden_tool|stone iron diamond".
    05 FILLER PIC X(140) VALUE "stone|131|4|1|5|#minecraft:stone_tool_materials|minecraft:incorrect_for_stone_tool|iron diamond".
    05 FILLER PIC X(140) VALUE "copper|190|5|1|13|minecraft:copper_ingot|minecraft:incorrect_for_copper_tool|iron diamond".
    05 FILLER PIC X(140) VALUE "iron|250|6|2|14|minecraft:iron_ingot|minecraft:incorrect_for_iron_tool|diamond".
    05 FILLER PIC X(140) VALUE "golden|32|12|0|22|minecraft:gold_ingot|minecraft:incorrect_for_gold_tool|stone iron diamond".
    05 FILLER PIC X(140) VALUE "diamond|1561|8|3|10|minecraft:diamond|minecraft:incorrect_for_diamond_tool|none".
    05 FILLER PIC X(140) VALUE "netherite|2031|9|4|15|minecraft:netherite_ingot|minecraft:incorrect_for_netherite_tool|none".
 01 WS-LINE-TABLE REDEFINES WS-LINES.
    05 WS-LINE             PIC X(140) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(12).
 01 WS-DURABILITY          PIC X(8).
 01 WS-SPEED               PIC X(8).
 01 WS-BONUS               PIC X(8).
 01 WS-ENCHANT             PIC X(8).
 LINKAGE SECTION.
 01 L-MATERIAL             PIC X(12).
 01 L-DURABILITY           BINARY-LONG.
 01 L-SPEED                BINARY-LONG.
 01 L-BONUS                BINARY-LONG.
 01 L-ENCHANT              BINARY-LONG.
 01 L-REPAIR               PIC X(40).
 01 L-DENY                 PIC X(48).
 01 L-TIERS                PIC X(24).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-MATERIAL L-DURABILITY L-SPEED L-BONUS L-ENCHANT L-REPAIR L-DENY L-TIERS L-FOUND.
     MOVE 0 TO L-DURABILITY L-SPEED L-BONUS L-ENCHANT L-FOUND
     MOVE SPACES TO L-REPAIR L-DENY L-TIERS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7 OR L-FOUND = 1
         MOVE SPACES TO WS-NAME
         UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME
         IF WS-NAME = L-MATERIAL
             UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-DURABILITY WS-SPEED WS-BONUS WS-ENCHANT
                 L-REPAIR L-DENY L-TIERS
             COMPUTE L-DURABILITY = FUNCTION NUMVAL(WS-DURABILITY)
             COMPUTE L-SPEED = FUNCTION NUMVAL(WS-SPEED)
             COMPUTE L-BONUS = FUNCTION NUMVAL(WS-BONUS)
             COMPUTE L-ENCHANT = FUNCTION NUMVAL(WS-ENCHANT)
             MOVE 1 TO L-FOUND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-MATERIAL.
