*> The definition of an enchantment read from its registry entry (docs/protocol/28 section 13, 40-3 section 3.3 step 9; lane itemcomp2, T10102): the row of the registry enchantment is the id
*> that the enchantments (13) and stored_enchantments (45) components hold.
*>   ENCH-DEF USING enchantment id, max level out, anvil cost out, weight out, supported tag out (PIC X(112), without #), exclusive set out (PIC X(112): the tag without # when the set is
*>     a tag, a single key otherwise, spaces for none), found out (1 or 0)
*>   ENCH-CAN USING enchantment id, item id, can out: the item is in the supported_items tag
*>   ENCH-COMPATIBLE USING enchantment id a, enchantment id b, ok out (1 when neither one's exclusive_set holds the other; 40-3 3.3 step 9.3)
*>   ENCH-IS-CURSE USING enchantment id, curse out: the enchantment is in the tag #minecraft:curse
*> Gap: an exclusive_set given as a list of keys is not read (the standard set uses tags); the built-in NBT entries (the cobolcraft set) have no exclusive_set read.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY JSONDOC.
 01 WS-JNAME               PIC X(32).
 01 WS-JNAME-LENGTH        BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-REGISTRY            PIC X(112) VALUE "enchantment".
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-AREA                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-PB-CAPACITY         BINARY-LONG VALUE 16384.
 01 WS-TEXT                PIC X(112).
 01 WS-TEXT-CAPACITY       BINARY-LONG VALUE 112.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ANVIL                BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 01 L-TAG                  PIC X(112).
 01 L-EXCLUSIVE            PIC X(112).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-MAX L-ANVIL L-WEIGHT L-TAG L-EXCLUSIVE L-FOUND.
     GO TO MAIN-LINE.

*> The JSON form: the numbers max_level, anvil_cost and weight, the strings supported_items and exclusive_set (a tag with its #, or a key).
 FROM-JSON.
     CALL "JSON-PARSE" USING JSON-DOC WS-AREA WS-LENGTH
     MOVE "max_level" TO WS-JNAME
     MOVE 9 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO L-MAX
     END-IF
     MOVE "anvil_cost" TO WS-JNAME
     MOVE 10 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO L-ANVIL
     END-IF
     MOVE "weight" TO WS-JNAME
     MOVE 6 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO L-WEIGHT
     END-IF
     MOVE "supported_items" TO WS-JNAME
     MOVE 15 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-STRING
         PERFORM STRING-OF-NODE
         MOVE WS-TEXT TO L-TAG
     END-IF
     MOVE "exclusive_set" TO WS-JNAME
     MOVE 13 TO WS-JNAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-JNAME WS-JNAME-LENGTH WS-NODE
     IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-STRING
         PERFORM STRING-OF-NODE
         MOVE WS-TEXT TO L-EXCLUSIVE
     END-IF.

 STRING-OF-NODE.
     MOVE SPACES TO WS-TEXT
     MOVE WS-AREA(JN-POS(WS-NODE):JN-LENGTH(WS-NODE)) TO WS-TEXT
     MOVE JN-LENGTH(WS-NODE) TO WS-TEXT-LENGTH
     PERFORM STORE-SET.

*> A holder set string: "#minecraft:tag" keeps the tag without the #, a key keeps itself.
 STORE-SET.
     IF WS-TEXT(1:1) = "#"
         MOVE WS-TEXT(2:111) TO WS-KEY
         MOVE WS-KEY TO WS-TEXT
     END-IF.

 MAIN-LINE.
     MOVE 0 TO L-MAX L-ANVIL L-WEIGHT L-FOUND
     MOVE SPACES TO L-TAG L-EXCLUSIVE
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     IF L-ID < 0 OR L-ID >= WS-COUNT
         GOBACK
     END-IF
     MOVE 1 TO L-FOUND
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY L-ID WS-KEY WS-KEY-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
*>   A data tree keeps strict JSON, the built-in set network NBT.
     IF WS-AREA(1:1) = "{"
         PERFORM FROM-JSON
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-PB-CAPACITY
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-AREA WS-LENGTH
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WS-NAME
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME WS-NAME-CAPACITY WS-NAME-LENGTH
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WS-NAME = "max_level"
                 CALL "PB-GET-INT" USING PB-BUFFER L-MAX
             WHEN WS-NAME = "anvil_cost"
                 CALL "PB-GET-INT" USING PB-BUFFER L-ANVIL
             WHEN WS-NAME = "weight"
                 CALL "PB-GET-INT" USING PB-BUFFER L-WEIGHT
             WHEN WS-NAME = "supported_items" AND WS-TYPE = 8
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAPACITY WS-TEXT-LENGTH
                 PERFORM STORE-SET
                 MOVE WS-TEXT TO L-TAG
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM ENCH-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-CAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCLUSIVE           PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ITEM L-CAN.
     MOVE 0 TO L-CAN
     CALL "ENCH-DEF" USING L-ID WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCLUSIVE WS-FOUND
     IF WS-FOUND = 1
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM L-CAN
     END-IF
     GOBACK.
 END PROGRAM ENCH-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-EXCLUDES.
*> USING enchantment id a, enchantment id b, excludes out: b is in the exclusive_set of a.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "enchantment".
 01 WS-MAX                 BINARY-LONG.
 01 WS-ANVIL               BINARY-LONG.
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-TAG                 PIC X(112).
 01 WS-EXCLUSIVE           PIC X(112).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-EXCLUDES             BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-EXCLUDES.
     MOVE 0 TO L-EXCLUDES
     CALL "ENCH-DEF" USING L-A WS-MAX WS-ANVIL WS-WEIGHT WS-TAG WS-EXCLUSIVE WS-FOUND
     IF WS-FOUND = 1 AND WS-EXCLUSIVE NOT = SPACES
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-EXCLUSIVE L-B L-EXCLUDES
     END-IF
     GOBACK.
 END PROGRAM ENCH-EXCLUDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-COMPATIBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AB                  BINARY-LONG.
 01 WS-BA                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-OK.
     CALL "ENCH-EXCLUDES" USING L-A L-B WS-AB
     CALL "ENCH-EXCLUDES" USING L-B L-A WS-BA
     MOVE 1 TO L-OK
     IF WS-AB = 1 OR WS-BA = 1
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM ENCH-COMPATIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENCH-IS-CURSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "enchantment".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:curse".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CURSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CURSE.
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ID L-CURSE
     GOBACK.
 END PROGRAM ENCH-IS-CURSE.
