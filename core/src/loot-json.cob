*> JSON access for the loot engine (T0436; docs/protocol/26-loot-and-predicates.md section 1): the documents of the loot tables,
*> predicates, item modifiers and named providers that LOOT-LOAD (content/src/loot.cob) keeps as elements of the shape store are
*> parsed on demand into the slots of LOOT-DOCS (core/copy/LOOTSTATE.cpy) and read node by node. A node is addressed by the pair
*> (slot, node number); node 0 means absent. A reference (a string where a document is expected, section 1) names an element of
*> the registry the field belongs to; without a namespace it is minecraft:.
*> Entry points:
*>   LOOT-DOC-GET USING registry (PIC X(48)), key (PIC X(112)), slot out (BINARY-LONG; 0 when the store holds no such element)
*>   LOOT-HOLDER USING registry (PIC X(48)), slot, node (BINARY-LONG, in and out): a string node is replaced by the root of the
*>     document it names (node 0 when there is none); any other node is left alone
*>   LOOT-J-MEMBER USING slot, node, name (PIC X(32)), member out (BINARY-LONG; 0 when the node is no object or has no member)
*>   LOOT-J-TEXT USING slot, node, text out (PIC X(112)), length out (0 when the node is no string)
*>   LOOT-J-KIND USING slot, node, kind out (PIC X(48)): the "type" member without "minecraft:" (spaces when there is none)
*>   LOOT-J-NUMBER USING slot, node, value out (FLOAT-LONG), ok out (1 when the node is a number)
*>   LOOT-J-TRUE USING slot, node, flag out (1 when the node is the literal true)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-DOC-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY CTSHAPE.
 COPY JSONDOC.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-KEY                  PIC X(112).
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-SLOT.
     MOVE 0 TO L-SLOT
     CALL "SHAPE-FIND" USING L-REGISTRY L-KEY WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LD-SLOTS OR L-SLOT > 0
         IF LDS-REGISTRY(WS-I) = L-REGISTRY AND LDS-KEY(WS-I) = L-KEY AND LDS-ADDR(WS-I) = SH-E-ADDR(WS-ROW)
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0
*>       A slot the current roll has not used is replaced (round robin); when every slot was used the next one goes.
         PERFORM VARYING WS-TRY FROM 1 BY 1 UNTIL WS-TRY > LD-SLOTS
             COMPUTE LDS-NEXT = FUNCTION MOD(LDS-NEXT, LD-SLOTS) + 1
             IF LDS-STAMP(LDS-NEXT) NOT = LDS-SERIAL
                 EXIT PERFORM
             END-IF
         END-PERFORM
         MOVE LDS-NEXT TO L-SLOT
         MOVE L-REGISTRY TO LDS-REGISTRY(L-SLOT)
         MOVE L-KEY TO LDS-KEY(L-SLOT)
         MOVE SH-E-ADDR(WS-ROW) TO LDS-ADDR(L-SLOT)
         MOVE SH-E-LENGTH(WS-ROW) TO WS-LENGTH
         SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-ROW)
         CALL "JSON-PARSE" USING LDS-DOC(L-SLOT) B-TEXT WS-LENGTH
     END-IF
     MOVE LDS-SERIAL TO LDS-STAMP(L-SLOT)
     GOBACK.
 END PROGRAM LOOT-DOC-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-MEMBER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-NAME L-MEMBER.
     MOVE 0 TO L-MEMBER
     IF L-NODE = 0
         GOBACK
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WS-LENGTH
     CALL "JSON-MEMBER" USING LDS-DOC(L-SLOT) L-NODE L-NAME WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO L-MEMBER
     GOBACK.
 END PROGRAM LOOT-J-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 01 WS-CAPACITY            BINARY-LONG VALUE 112.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(112).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH
     IF L-NODE > 0
         CALL "JSON-STRING" USING LDS-DOC(L-SLOT) L-NODE L-TEXT WS-CAPACITY L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM LOOT-J-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32) VALUE "type".
 01 WS-MEMBER              BINARY-LONG.
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 PIC X(48).
 PROCEDURE DIVISION USING L-SLOT L-NODE L-KIND.
     MOVE SPACES TO L-KIND
     CALL "LOOT-J-MEMBER" USING L-SLOT L-NODE WS-NAME WS-MEMBER
     CALL "LOOT-J-TEXT" USING L-SLOT WS-MEMBER WS-TEXT WS-LENGTH
     IF WS-TEXT(1:10) = "minecraft:"
         MOVE WS-TEXT(11:) TO L-KIND
     ELSE
         MOVE WS-TEXT TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM LOOT-J-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-NUMBER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-VALUE L-OK.
     MOVE 0 TO L-VALUE L-OK
     IF L-NODE > 0
         IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-NUMBER
             MOVE LDS-JN-NUM(L-SLOT, L-NODE) TO L-VALUE
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOT-J-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-J-TRUE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 LINKAGE SECTION.
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-NODE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-NODE > 0
         IF LDS-JN-TYPE(L-SLOT, L-NODE) = JT-TRUE
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOOT-J-TRUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-HOLDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOOTSTATE.
 COPY JSONDOC.
 01 WS-KEY                 PIC X(112).
 01 WS-TEXT                PIC X(112).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(48).
 01 L-SLOT                 BINARY-LONG.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-SLOT L-NODE.
     IF L-NODE = 0
         GOBACK
     END-IF
     IF LDS-JN-TYPE(L-SLOT, L-NODE) NOT = JT-STRING
         GOBACK
     END-IF
     CALL "LOOT-J-TEXT" USING L-SLOT L-NODE WS-TEXT WS-LENGTH
     MOVE 0 TO WS-COLON
     INSPECT WS-TEXT TALLYING WS-COLON FOR ALL ":"
     MOVE SPACES TO WS-KEY
     IF WS-COLON = 0
         STRING "minecraft:" FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-KEY
     ELSE
         MOVE WS-TEXT TO WS-KEY
     END-IF
     CALL "LOOT-DOC-GET" USING L-REGISTRY WS-KEY WS-SLOT
     IF WS-SLOT = 0
         MOVE 0 TO L-NODE
     ELSE
         MOVE WS-SLOT TO L-SLOT
         MOVE 1 TO L-NODE
     END-IF
     GOBACK.
 END PROGRAM LOOT-HOLDER.
