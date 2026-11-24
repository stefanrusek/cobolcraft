*> Armor materials, armor items and the armor reduction (docs/protocol/17 section 2.5, 4.4 and 4.5; US14; T2033 to T2049).
*>
*> A material is (durability multiplier, defense per slot, enchantability, toughness, knockback resistance, repair); the durability of a
*> piece is the multiplier times the slot base (helmet 11, chestplate 16, leggings 15, boots 13, body 16). Toughness and knockback
*> resistance are in tenths here (netherite 3.0 and 0.1 are 30 and 1).
*>
*> Entry points:
*>   TOOL-ARMOR-MATERIAL USING material (PIC X(16): leather, copper, chainmail, iron, golden, diamond, netherite, turtle_scute, wolf),
*>     piece (PIC X(12): boots, leggings, chestplate, helmet, body), found out (1 or 0), durability, defense, toughness (tenths),
*>     knockback resistance (tenths), enchantability (BINARY-LONG), repair ingredient (PIC X(40))
*>   TOOL-ARMOR-ITEM USING item key (PIC X(48), "minecraft:" optional: "<material>_<piece>", "turtle_helmet" is turtle_scute's,
*>     "wolf_armor" the wolf's body), then the same outputs from found: the row of the piece's material
*>   TOOL-ARMOR-TOTAL USING worn (five PIC X(48) keys: boots, leggings, chestplate, helmet, body; blank = nothing), armor out (the sum of the
*>     defenses, at most 30), toughness out (tenths, at most 200), knockback resistance out (tenths, at most 10)
*>   TOOL-ARMOR-REDUCE USING damage (FLOAT-SHORT), armor (BINARY-LONG, floored), toughness (tenths), result out (FLOAT-SHORT): 4.5:
*>     f = 2 + T / 4, e = clamp(R - d / f, R x 0.2, 20), q = e / 25, result d x (1 - q); each step single precision

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-MATERIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LINES.
    05 FILLER PIC X(80) VALUE "leather|5|1|2|3|1|3|15|0|0|minecraft:leather".
    05 FILLER PIC X(80) VALUE "copper|11|1|3|4|2|4|8|0|0|minecraft:copper_ingot".
    05 FILLER PIC X(80) VALUE "chainmail|15|1|4|5|2|4|12|0|0|#minecraft:repairs_chain_armor".
    05 FILLER PIC X(80) VALUE "iron|15|2|5|6|2|5|9|0|0|minecraft:iron_ingot".
    05 FILLER PIC X(80) VALUE "golden|7|1|3|5|2|7|25|0|0|minecraft:gold_ingot".
    05 FILLER PIC X(80) VALUE "diamond|33|3|6|8|3|11|10|20|0|minecraft:diamond".
    05 FILLER PIC X(80) VALUE "netherite|37|3|6|8|3|19|15|30|1|minecraft:netherite_ingot".
    05 FILLER PIC X(80) VALUE "turtle_scute|25|2|5|6|2|5|9|0|0|minecraft:turtle_scute".
    05 FILLER PIC X(80) VALUE "wolf|4|3|6|8|3|11|10|0|0|minecraft:armadillo_scute".
 01 WS-LINE-TABLE REDEFINES WS-LINES.
    05 WS-LINE             PIC X(80) OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-MULT                PIC X(4).
 01 WS-BOOTS               PIC X(4).
 01 WS-LEGS                PIC X(4).
 01 WS-CHEST               PIC X(4).
 01 WS-HELMET              PIC X(4).
 01 WS-BODY                PIC X(4).
 01 WS-ENCHANT-TEXT        PIC X(4).
 01 WS-TOUGH-TEXT          PIC X(4).
 01 WS-KB-TEXT             PIC X(4).
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MATERIAL             PIC X(16).
 01 L-PIECE                PIC X(12).
 01 L-FOUND                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-DEFENSE              BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-KNOCKBACK            BINARY-LONG.
 01 L-ENCHANT              BINARY-LONG.
 01 L-REPAIR               PIC X(40).
 PROCEDURE DIVISION USING L-MATERIAL L-PIECE L-FOUND L-DURABILITY L-DEFENSE L-TOUGHNESS L-KNOCKBACK
         L-ENCHANT L-REPAIR.
     MOVE 0 TO L-FOUND L-DURABILITY L-DEFENSE L-TOUGHNESS L-KNOCKBACK L-ENCHANT
     MOVE SPACES TO L-REPAIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9 OR L-FOUND = 1
         MOVE SPACES TO WS-NAME
         UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME
         IF WS-NAME = L-MATERIAL
             UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-NAME WS-MULT WS-BOOTS WS-LEGS WS-CHEST WS-HELMET WS-BODY
                 WS-ENCHANT-TEXT WS-TOUGH-TEXT WS-KB-TEXT L-REPAIR
             MOVE 0 TO WS-BASE
             EVALUATE L-PIECE
                 WHEN "boots"
                     MOVE 13 TO WS-BASE
                     COMPUTE L-DEFENSE = FUNCTION NUMVAL(WS-BOOTS)
                 WHEN "leggings"
                     MOVE 15 TO WS-BASE
                     COMPUTE L-DEFENSE = FUNCTION NUMVAL(WS-LEGS)
                 WHEN "chestplate"
                     MOVE 16 TO WS-BASE
                     COMPUTE L-DEFENSE = FUNCTION NUMVAL(WS-CHEST)
                 WHEN "helmet"
                     MOVE 11 TO WS-BASE
                     COMPUTE L-DEFENSE = FUNCTION NUMVAL(WS-HELMET)
                 WHEN "body"
                     MOVE 16 TO WS-BASE
                     COMPUTE L-DEFENSE = FUNCTION NUMVAL(WS-BODY)
             END-EVALUATE
             IF WS-BASE > 0
                 MOVE 1 TO L-FOUND
                 COMPUTE L-DURABILITY = FUNCTION NUMVAL(WS-MULT) * WS-BASE
                 COMPUTE L-TOUGHNESS = FUNCTION NUMVAL(WS-TOUGH-TEXT)
                 COMPUTE L-KNOCKBACK = FUNCTION NUMVAL(WS-KB-TEXT)
                 COMPUTE L-ENCHANT = FUNCTION NUMVAL(WS-ENCHANT-TEXT)
             ELSE
                 MOVE SPACES TO L-REPAIR
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TOOL-ARMOR-MATERIAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHORT               PIC X(48).
 01 WS-MATERIAL            PIC X(16).
 01 WS-PIECE               PIC X(12).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-DEFENSE              BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-KNOCKBACK            BINARY-LONG.
 01 L-ENCHANT              BINARY-LONG.
 01 L-REPAIR               PIC X(40).
 PROCEDURE DIVISION USING L-KEY L-FOUND L-DURABILITY L-DEFENSE L-TOUGHNESS L-KNOCKBACK L-ENCHANT L-REPAIR.
     MOVE SPACES TO WS-SHORT WS-MATERIAL WS-PIECE
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:38) TO WS-SHORT
     ELSE
         MOVE L-KEY TO WS-SHORT
     END-IF
     UNSTRING WS-SHORT DELIMITED BY "_" INTO WS-MATERIAL WS-PIECE
     IF WS-MATERIAL = "turtle"
         MOVE "turtle_scute" TO WS-MATERIAL
     END-IF
     IF WS-MATERIAL = "wolf" AND WS-PIECE = "armor"
         MOVE "body" TO WS-PIECE
     END-IF
     CALL "TOOL-ARMOR-MATERIAL" USING WS-MATERIAL WS-PIECE L-FOUND L-DURABILITY L-DEFENSE L-TOUGHNESS
         L-KNOCKBACK L-ENCHANT L-REPAIR
     GOBACK.
 END PROGRAM TOOL-ARMOR-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-TOTAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 LINKAGE SECTION.
 01 L-WORN.
    05 L-WORN-KEY          PIC X(48) OCCURS 5 TIMES.
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-KNOCKBACK            BINARY-LONG.
 PROCEDURE DIVISION USING L-WORN L-ARMOR L-TOUGHNESS L-KNOCKBACK.
     MOVE 0 TO L-ARMOR L-TOUGHNESS L-KNOCKBACK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "TOOL-ARMOR-ITEM" USING L-WORN-KEY(WS-I) WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS
             WS-KNOCKBACK WS-ENCHANT WS-REPAIR
         ADD WS-DEFENSE TO L-ARMOR
         ADD WS-TOUGHNESS TO L-TOUGHNESS
         ADD WS-KNOCKBACK TO L-KNOCKBACK
     END-PERFORM
     COMPUTE L-ARMOR = FUNCTION MIN(L-ARMOR, 30)
     COMPUTE L-TOUGHNESS = FUNCTION MIN(L-TOUGHNESS, 200)
     COMPUTE L-KNOCKBACK = FUNCTION MIN(L-KNOCKBACK, 10)
     GOBACK.
 END PROGRAM TOOL-ARMOR-TOTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-ARMOR-REDUCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-SHORT.
 01 WS-F                   FLOAT-SHORT.
 01 WS-QUOTIENT            FLOAT-SHORT.
 01 WS-E                   FLOAT-SHORT.
 01 WS-LOW                 FLOAT-SHORT.
 01 WS-Q                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-DAMAGE               FLOAT-SHORT.
 01 L-ARMOR                BINARY-LONG.
 01 L-TOUGHNESS            BINARY-LONG.
 01 L-RESULT               FLOAT-SHORT.
 PROCEDURE DIVISION USING L-DAMAGE L-ARMOR L-TOUGHNESS L-RESULT.
     COMPUTE WS-T = L-TOUGHNESS / 10
     COMPUTE WS-F = 2.0 + WS-T / 4.0
     COMPUTE WS-QUOTIENT = L-DAMAGE / WS-F
     COMPUTE WS-E = L-ARMOR - WS-QUOTIENT
     COMPUTE WS-LOW = L-ARMOR * 0.2
     COMPUTE WS-E = FUNCTION MAX(WS-LOW, FUNCTION MIN(WS-E, 20.0))
     COMPUTE WS-Q = WS-E / 25.0
     COMPUTE L-RESULT = L-DAMAGE * (1.0 - WS-Q)
     GOBACK.
 END PROGRAM TOOL-ARMOR-REDUCE.
