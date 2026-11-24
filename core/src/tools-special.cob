*> The special weapons and tools (docs/protocol/17 section 2.6; US14; T2051 to T2103): the stats the document's table lists for each,
*> read from the item's content components.
*>
*> Entry points:
*>   TOOL-SPECIAL-STATS USING item key (PIC X(48), "minecraft:" optional), found out (1 when the open set has the item), stack size, durability
*>     (0: none), enchantability (-1: no enchantable component), rarity (PIC X(12), "common" by default), repair ingredient (PIC X(40): an
*>     item key or "#" and a tag, both without "minecraft:", "none")
*>   TOOL-SPECIAL-COMPONENT USING item key, component name (PIC X(32)), value out (PIC X(100)), found out (1 or 0): a component of the
*>     content layer (the names of item-components.cob and of the generated rows)
*>   TOOL-REPAIR-NORMALIZE USING text (PIC X(40), in and out): "{phantom_membrane}", "tag wooden_tool_materials", "minecraft:copper_ingot"
*>     and "#minecraft:stone_tool_materials" become "phantom_membrane", "#wooden_tool_materials", "copper_ingot", "#stone_tool_materials"

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-REPAIR-NORMALIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(40).
 01 WS-REST                PIC X(40).
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(40).
 PROCEDURE DIVISION USING L-TEXT.
     INSPECT L-TEXT REPLACING ALL "{" BY " " ALL "}" BY " "
     MOVE FUNCTION TRIM(L-TEXT) TO WS-TEXT
     IF WS-TEXT(1:4) = "tag "
         MOVE FUNCTION TRIM(WS-TEXT(5:36)) TO WS-REST
         MOVE SPACES TO WS-TEXT
         STRING "#" FUNCTION TRIM(WS-REST) DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     IF WS-TEXT(1:11) = "#minecraft:"
         MOVE WS-TEXT(12:29) TO WS-REST
         MOVE SPACES TO WS-TEXT
         STRING "#" FUNCTION TRIM(WS-REST) DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     IF WS-TEXT(1:10) = "minecraft:"
         MOVE WS-TEXT(11:30) TO WS-REST
         MOVE WS-REST TO WS-TEXT
     END-IF
     MOVE WS-TEXT TO L-TEXT
     GOBACK.
 END PROGRAM TOOL-REPAIR-NORMALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SPECIAL-COMPONENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NAME L-VALUE L-FOUND.
     MOVE 0 TO L-FOUND
     MOVE SPACES TO L-VALUE WS-KEY
     IF L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:38) TO WS-KEY
     ELSE
         MOVE L-KEY TO WS-KEY
     END-IF
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     IF WS-STATUS = CT-OK
         CALL "CONTENT-ITEM-COMPONENT" USING WS-ID L-NAME L-VALUE WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-SPECIAL-COMPONENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TOOL-SPECIAL-STATS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-FOUND               BINARY-LONG.
 01 WS-REPAIR-NAME         PIC X(32) VALUE "repairable".
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FOUND                BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 01 L-DURABILITY           BINARY-LONG.
 01 L-ENCHANT              BINARY-LONG.
 01 L-RARITY               PIC X(12).
 01 L-REPAIR               PIC X(40).
 PROCEDURE DIVISION USING L-KEY L-FOUND L-STACK L-DURABILITY L-ENCHANT L-RARITY L-REPAIR.
     MOVE 0 TO L-FOUND L-STACK L-DURABILITY
     MOVE -1 TO L-ENCHANT
     MOVE "common" TO L-RARITY
     MOVE "none" TO L-REPAIR
     MOVE "max_stack_size" TO WS-NAME
     CALL "TOOL-SPECIAL-COMPONENT" USING L-KEY WS-NAME WS-VALUE L-FOUND
     IF L-FOUND = 1
         COMPUTE L-STACK = FUNCTION NUMVAL(WS-VALUE)
         MOVE "max_damage" TO WS-NAME
         CALL "TOOL-SPECIAL-COMPONENT" USING L-KEY WS-NAME WS-VALUE WS-FOUND
         COMPUTE L-DURABILITY = FUNCTION NUMVAL(WS-VALUE)
         MOVE "enchantable" TO WS-NAME
         CALL "TOOL-SPECIAL-COMPONENT" USING L-KEY WS-NAME WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             COMPUTE L-ENCHANT = FUNCTION NUMVAL(WS-VALUE)
         END-IF
         MOVE "rarity" TO WS-NAME
         CALL "TOOL-SPECIAL-COMPONENT" USING L-KEY WS-NAME WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-VALUE TO L-RARITY
         END-IF
         CALL "TOOL-SPECIAL-COMPONENT" USING L-KEY WS-REPAIR-NAME WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             MOVE WS-VALUE TO L-REPAIR
             CALL "TOOL-REPAIR-NORMALIZE" USING L-REPAIR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TOOL-SPECIAL-STATS.
