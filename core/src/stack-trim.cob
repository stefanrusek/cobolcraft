*> The armour trim of a stack (lane itemcomp3, T10605; docs/protocol/54 section 18, 27 section 3.3, 25-4 section 5): the trim component (58) holds the material holder and then the pattern holder, each a
*> VarInt registry position plus 1 (a holder written inline, 0, is not read). A handle is the patch handle of core/copy/CSTACK.cpy.
*>   REG-KEY-ID USING registry (PIC X(112)), key (PIC X(112), with minecraft:), id out (-1 for none)   the position of a key in a data registry
*>   TRIM-MATERIAL-OF USING item, material key out (PIC X(24), without minecraft:; spaces for an item that provides none)   provides_trim_material of the ingots and gems
*>   SC-TRIM-SET USING handle (in, out), material id, pattern id
*>   SC-TRIM-GET USING handle, found out, material id out, pattern id out
*>   SMITH-TRIM-RESULT USING pattern key (PIC X(112), the recipe's pattern), base item, base handle, addition item, result handle out, ok out   applyTrim: refused without a material or when the base has that trim

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REG-KEY-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-AREA                PIC X(1).
 01 WS-CAPACITY            BINARY-LONG VALUE 0.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(112).
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-ID.
     MOVE -1 TO L-ID
     CALL "CONTENT-REGISTRY-COUNT" USING L-REGISTRY WS-COUNT WS-STATUS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR L-ID >= 0
         CALL "CONTENT-REGISTRY-ENTRY" USING L-REGISTRY WS-I WS-KEY WS-KEY-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
         IF WS-KEY = L-KEY
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REG-KEY-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIM-MATERIAL-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-MATERIAL             PIC X(24).
 PROCEDURE DIVISION USING L-ITEM L-MATERIAL.
     MOVE SPACES TO L-MATERIAL
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     EVALUATE WS-KEY
         WHEN "iron_ingot"
             MOVE "iron" TO L-MATERIAL
         WHEN "copper_ingot"
             MOVE "copper" TO L-MATERIAL
         WHEN "gold_ingot"
             MOVE "gold" TO L-MATERIAL
         WHEN "netherite_ingot"
             MOVE "netherite" TO L-MATERIAL
         WHEN "diamond"
             MOVE "diamond" TO L-MATERIAL
         WHEN "emerald"
             MOVE "emerald" TO L-MATERIAL
         WHEN "lapis_lazuli"
             MOVE "lapis" TO L-MATERIAL
         WHEN "quartz"
             MOVE "quartz" TO L-MATERIAL
         WHEN "amethyst_shard"
             MOVE "amethyst" TO L-MATERIAL
         WHEN "redstone"
             MOVE "redstone" TO L-MATERIAL
         WHEN "resin_brick"
             MOVE "resin" TO L-MATERIAL
     END-EVALUATE
     GOBACK.
 END PROGRAM TRIM-MATERIAL-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-TRIM-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 58.
 01 WS-VALUE               PIC X(64).
 01 WS-POS                 BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-MATERIAL             BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-MATERIAL L-PATTERN.
     MOVE SPACES TO WS-VALUE
     MOVE 1 TO WS-POS
     COMPUTE WS-V = L-MATERIAL + 1
     CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-V
     COMPUTE WS-V = L-PATTERN + 1
     CALL "SP-VARINT-PUT" USING WS-VALUE WS-POS WS-V
     SUBTRACT 1 FROM WS-POS
     CALL "SP-SET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-POS
     GOBACK.
 END PROGRAM SC-TRIM-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SC-TRIM-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 58.
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-MATERIAL             BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-FOUND L-MATERIAL L-PATTERN.
     MOVE 0 TO L-FOUND L-MATERIAL L-PATTERN
     CALL "SP-GET-COMPONENT" USING L-HANDLE WS-TYPE WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1
         MOVE 1 TO WS-POS
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-A
         CALL "SP-VARINT-GET" USING WS-VALUE WS-POS WS-B
         IF WS-A > 0 AND WS-B > 0
             MOVE 1 TO L-FOUND
             COMPUTE L-MATERIAL = WS-A - 1
             COMPUTE L-PATTERN = WS-B - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SC-TRIM-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMITH-TRIM-RESULT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MKEY                PIC X(24).
 01 WS-REG-M               PIC X(112) VALUE "trim_material".
 01 WS-REG-P               PIC X(112) VALUE "trim_pattern".
 01 WS-KEY                 PIC X(112).
 01 WS-MAT                 BINARY-LONG.
 01 WS-PAT                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OM                  BINARY-LONG.
 01 WS-OP                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATTERN              PIC X(112).
 01 L-BASE-ITEM            BINARY-LONG.
 01 L-BASE-HANDLE          BINARY-LONG.
 01 L-ADD-ITEM             BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PATTERN L-BASE-ITEM L-BASE-HANDLE L-ADD-ITEM L-HANDLE L-OK.
     MOVE 0 TO L-OK
     MOVE L-BASE-HANDLE TO L-HANDLE
     CALL "TRIM-MATERIAL-OF" USING L-ADD-ITEM WS-MKEY
     IF WS-MKEY = SPACES
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-MKEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "REG-KEY-ID" USING WS-REG-M WS-KEY WS-MAT
     IF L-PATTERN(1:10) = "minecraft:"
         MOVE L-PATTERN TO WS-KEY
     ELSE
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(L-PATTERN) DELIMITED BY SIZE INTO WS-KEY
     END-IF
     CALL "REG-KEY-ID" USING WS-REG-P WS-KEY WS-PAT
     IF WS-MAT < 0 OR WS-PAT < 0
         GOBACK
     END-IF
     CALL "SC-TRIM-GET" USING L-BASE-HANDLE WS-FOUND WS-OM WS-OP
     IF WS-FOUND = 1 AND WS-OM = WS-MAT AND WS-OP = WS-PAT
         GOBACK
     END-IF
     CALL "SC-TRIM-SET" USING L-HANDLE WS-MAT WS-PAT
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM SMITH-TRIM-RESULT.
