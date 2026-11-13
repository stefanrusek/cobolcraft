*> The core's view of the open content set's blocks (CBLOCKS.cpy; content-api section 2). BLOCKS-OPEN reads every
*> block row through CONTENT-BLOCK-OF-STATE (the same rows for the standard and the cobolcraft set), derives the
*> numeric properties the rules need once, and the lookups below turn keys and property pairs into ids without
*> any table of the game's own. Rules of derivation (see CBLOCKS.cpy): solid and opaque from the row's flags,
*> break time from its hardness, tool class from the block tags, light from its light text.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-STATE-PROPS.
*> USING state id (BINARY-LONG), text out (PIC X(160)): the property values of the state as "name=value" pairs
*> separated by commas in the block's list order (sorted by name); spaces for a state with none or an unknown state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTPROPS.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-TEXT                 PIC X(160).
 PROCEDURE DIVISION USING L-STATE L-TEXT.
     MOVE SPACES TO L-TEXT
     CALL "CONTENT-STATE-PROPS" USING L-STATE CT-PROPS WS-STATUS
     IF WS-STATUS NOT = CT-OK
         GOBACK
     END-IF
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-NAME(WS-I))) TO WS-NAME-LENGTH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CTP-VALUE(WS-I))) TO WS-VALUE-LENGTH
         IF WS-I > 1
             STRING "," DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
         END-IF
         STRING CTP-NAME(WS-I)(1:WS-NAME-LENGTH) "=" CTP-VALUE(WS-I)(1:WS-VALUE-LENGTH)
             DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-POINTER
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-STATE-PROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-ID-OF.
*> USING key (PIC X(112), space padded; "minecraft:" is optional unless the cobolcraft set is open), block id out
*> (BINARY-LONG; -1 for a key the set does not hold): a search of the tables BLOCKS-OPEN built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-KEY                 PIC X(112).
 01 WS-REST                PIC X(112).
 01 WS-B                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE -1 TO L-ID
     MOVE L-KEY TO WS-KEY
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:102) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > CB-BLOCK-COUNT OR L-ID >= 0
         MOVE CB-KEY-LENGTH(WS-B) TO WS-LENGTH
         IF CB-KEY(WS-B)(1:WS-LENGTH) = WS-KEY(1:WS-LENGTH) AND WS-KEY(WS-LENGTH + 1:1) = SPACE
             COMPUTE L-ID = WS-B - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-ID-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-STATE-OF.
*> USING key (PIC X(112)), pairs (PIC X(160): "name=value" pairs separated by commas, spaces for none), state
*> out (BINARY-LONG): the state of that block whose properties are exactly the pairs; the block's default state
*> when no pair is given or none matches; 0 for a key the set does not hold.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ID                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-TEXT                PIC X(160).
 01 WS-WANT                PIC X(164).
 01 WS-HAVE                PIC X(164).
 01 WS-PAIR                PIC X(48).
 01 WS-PAIR-LENGTH         BINARY-LONG.
 01 WS-NEEDLE              PIC X(64).
 01 WS-NEEDLE-LENGTH       BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-WANTED              BINARY-LONG.
 01 WS-HAVE-COUNT          BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-PAIRS                PIC X(160).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     MOVE 0 TO L-STATE
     CALL "BLOCKS-ID-OF" USING L-KEY WS-ID
     IF WS-ID < 0
         GOBACK
     END-IF
     MOVE CB-DEFAULT-STATE(WS-ID + 1) TO L-STATE
     IF L-PAIRS = SPACES
         GOBACK
     END-IF
*>   ",pair,pair," forms of the wanted and of each state's properties, so a pair is found whole.
     MOVE SPACES TO WS-WANT
     STRING "," FUNCTION TRIM(L-PAIRS) "," DELIMITED BY SIZE INTO WS-WANT
     MOVE 0 TO WS-WANTED
     INSPECT WS-WANT TALLYING WS-WANTED FOR ALL ","
     SUBTRACT 1 FROM WS-WANTED
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-ID + 1) + CB-STATES(WS-ID + 1) - 1
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-ID + 1) BY 1 UNTIL WS-S > WS-LAST
         CALL "BLOCKS-STATE-PROPS" USING WS-S WS-TEXT
         MOVE SPACES TO WS-HAVE
         STRING "," FUNCTION TRIM(WS-TEXT) "," DELIMITED BY SIZE INTO WS-HAVE
         MOVE 0 TO WS-HAVE-COUNT
         INSPECT WS-HAVE TALLYING WS-HAVE-COUNT FOR ALL ","
         SUBTRACT 1 FROM WS-HAVE-COUNT
         MOVE 0 TO WS-MATCHED
         MOVE 2 TO WS-POINTER
         PERFORM WS-WANTED TIMES
             MOVE SPACES TO WS-PAIR
             MOVE 0 TO WS-PAIR-LENGTH
             UNSTRING WS-WANT DELIMITED BY "," INTO WS-PAIR COUNT WS-PAIR-LENGTH
                 WITH POINTER WS-POINTER
             MOVE 0 TO WS-FOUND
             MOVE SPACES TO WS-NEEDLE
             STRING "," WS-PAIR(1:WS-PAIR-LENGTH) "," DELIMITED BY SIZE INTO WS-NEEDLE
             COMPUTE WS-NEEDLE-LENGTH = WS-PAIR-LENGTH + 2
             INSPECT WS-HAVE TALLYING WS-FOUND FOR ALL WS-NEEDLE(1:WS-NEEDLE-LENGTH)
             IF WS-FOUND > 0
                 ADD 1 TO WS-MATCHED
             END-IF
         END-PERFORM
         IF WS-MATCHED = WS-WANTED AND WS-HAVE-COUNT = WS-WANTED
             MOVE WS-S TO L-STATE
             EXIT PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BLOCKS-STATE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-CHECK-ID.
*> USING block id (BINARY-LONG): fatal when the id does not fit the table (CB-MAX-BLOCKS). Kept in a program of its
*> own so that a run which ends here leaves no other program's coverage skewed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FATAL               PIC X(60) VALUE Z"block tables: more blocks than the core holds".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     IF L-ID >= CB-MAX-BLOCKS
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-CHECK-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-LIMITS-CHECK.
*> USING block id, first state, state count (BINARY-LONG each): fatal when the states of the block do not fit the
*> table (CB-MAX-STATES).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-FATAL               PIC X(60) VALUE Z"block tables: more states than the core holds".
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FIRST L-COUNT.
     IF L-FIRST + L-COUNT > CB-MAX-STATES
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM BLOCKS-LIMITS-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-FILL.
*> USING block id (BINARY-LONG), row (PIC X(819), CT-BLOCK-ROW): derives the numbers of that block and fills its
*> CB-BLOCK entry and the CB-STATE entries of its states (the rules of CBLOCKS.cpy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CTPROPS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG-PICKAXE         PIC X(112) VALUE "minecraft:mineable/pickaxe".
 01 WS-TAG-SHOVEL          PIC X(112) VALUE "minecraft:mineable/shovel".
 01 WS-TAG-STONE-TIER     PIC X(112) VALUE "minecraft:needs_stone_tool".
 01 WS-TAG-IRON-TIER      PIC X(112) VALUE "minecraft:needs_iron_tool".
 01 WS-TAG-DIAMOND-TIER   PIC X(112) VALUE "minecraft:needs_diamond_tool".
 01 WS-TAGGED              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FLAGS               PIC X(149).
 01 WS-HITS                BINARY-LONG.
 01 WS-HARDNESS            FLOAT-LONG.
 01 WS-TOKEN               PIC X(41).
 01 WS-BASE                BINARY-LONG.
 01 WS-CONDITIONAL         BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIT                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ROW                  PIC X(819).
 PROCEDURE DIVISION USING L-ID L-ROW.
     MOVE L-ROW TO CT-BLOCK-ROW
     COMPUTE WS-INDEX = L-ID + 1
     CALL "BLOCKS-CHECK-ID" USING L-ID
     MOVE SPACES TO CB-KEY(WS-INDEX)
     MOVE FUNCTION TRIM(CT-BR-KEY) TO CB-KEY(WS-INDEX)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CT-BR-KEY)) TO CB-KEY-LENGTH(WS-INDEX)
     COMPUTE CB-FIRST-STATE(WS-INDEX) = FUNCTION NUMVAL(CT-BR-FIRST-STATE)
     COMPUTE CB-STATES(WS-INDEX) = FUNCTION NUMVAL(CT-BR-STATE-COUNT)
     COMPUTE CB-DEFAULT-STATE(WS-INDEX) = FUNCTION NUMVAL(CT-BR-DEFAULT-STATE)
     CALL "BLOCKS-LIMITS-CHECK" USING L-ID CB-FIRST-STATE(WS-INDEX) CB-STATES(WS-INDEX)
*>   Flags: solid and opaque.
     MOVE SPACES TO WS-FLAGS
     STRING " " CT-BR-FLAGS " " DELIMITED BY SIZE INTO WS-FLAGS
     MOVE 1 TO CB-SOLID(WS-INDEX) CB-OPAQUE(WS-INDEX)
     MOVE 0 TO WS-HITS
     INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL "noCollision" ALL " air "
     IF WS-HITS > 0
         MOVE 0 TO CB-SOLID(WS-INDEX) CB-OPAQUE(WS-INDEX)
     END-IF
     MOVE 0 TO WS-HITS
     INSPECT WS-FLAGS TALLYING WS-HITS FOR ALL "noOcclusion"
     IF WS-HITS > 0
         MOVE 0 TO CB-OPAQUE(WS-INDEX)
     END-IF
*>   Break time from the hardness.
     COMPUTE WS-HARDNESS = FUNCTION NUMVAL(CT-BR-HARDNESS)
     IF WS-HARDNESS < 0
         MOVE -1 TO CB-BREAK-MS(WS-INDEX)
     ELSE
         COMPUTE CB-BREAK-MS(WS-INDEX) ROUNDED = WS-HARDNESS * 1000
     END-IF
*>   Tool class from the block tags.
     MOVE 0 TO CB-CLASS(WS-INDEX)
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-SHOVEL L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 2 TO CB-CLASS(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-PICKAXE L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 1 TO CB-CLASS(WS-INDEX)
     END-IF
*>   Tool requirement and tier (13 section 2.6).
     MOVE 0 TO CB-TOOL-REQ(WS-INDEX) CB-NEED-TIER(WS-INDEX)
     IF CT-BR-TOOL-REQUIRED(1:3) = "yes"
         MOVE 1 TO CB-TOOL-REQ(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-STONE-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 1 TO CB-NEED-TIER(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-IRON-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 2 TO CB-NEED-TIER(WS-INDEX)
     END-IF
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-DIAMOND-TIER L-ID WS-TAGGED
     IF WS-TAGGED = 1
         MOVE 3 TO CB-NEED-TIER(WS-INDEX)
     END-IF
*>   Light: a number first in the text, and whether it holds only where the property lit is true.
     MOVE SPACES TO WS-TOKEN
     MOVE FUNCTION TRIM(CT-BR-LIGHT) TO WS-TOKEN
     UNSTRING WS-TOKEN DELIMITED BY SPACE INTO WS-TOKEN
     MOVE 0 TO WS-BASE
     IF WS-TOKEN NOT = SPACES AND FUNCTION TEST-NUMVAL(WS-TOKEN) = 0
         COMPUTE WS-BASE = FUNCTION NUMVAL(WS-TOKEN)
     END-IF
     IF WS-BASE > 15
         MOVE 0 TO WS-BASE
     END-IF
     MOVE 0 TO WS-CONDITIONAL
     INSPECT CT-BR-LIGHT TALLYING WS-CONDITIONAL FOR ALL "lit, else 0"
     COMPUTE WS-LAST = CB-FIRST-STATE(WS-INDEX) + CB-STATES(WS-INDEX) - 1
     PERFORM VARYING WS-S FROM CB-FIRST-STATE(WS-INDEX) BY 1 UNTIL WS-S > WS-LAST
         MOVE L-ID TO CB-S-BLOCK(WS-S + 1)
         MOVE WS-BASE TO CB-S-LIGHT(WS-S + 1)
         IF WS-CONDITIONAL > 0
             MOVE 0 TO CB-S-LIGHT(WS-S + 1)
             CALL "CONTENT-STATE-PROPS" USING WS-S CT-PROPS WS-STATUS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CTP-COUNT
                 IF CTP-NAME(WS-I) = "lit" AND CTP-VALUE(WS-I) = "true"
                     MOVE WS-BASE TO CB-S-LIGHT(WS-S + 1)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE CB-S-LIGHT(CB-DEFAULT-STATE(WS-INDEX) + 1) TO CB-LIGHT(WS-INDEX)
     GOBACK.
 END PROGRAM BLOCKS-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLOCKS-OPEN.
*> No parameters: builds the tables of CBLOCKS.cpy from the open content set (called by CORE-WORLD-OPEN after the
*> set is opened): blocks are visited in id order by walking the state ids (CONTENT-BLOCK-OF-STATE answers the row
*> that holds a state, the next block starts after its last state). CB-EPOCH rises by one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-EPOCH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 PROCEDURE DIVISION.
     MOVE CB-EPOCH TO WS-EPOCH
     MOVE LOW-VALUES TO CORE-BLOCKS
     COMPUTE CB-EPOCH = WS-EPOCH + 1
     MOVE 0 TO WS-STATE
     MOVE CT-OK TO WS-STATUS
     PERFORM UNTIL WS-STATE >= CT-STATE-COUNT OR WS-STATUS NOT = CT-OK
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-ID WS-INDEX WS-ROW WS-STATUS
         IF WS-STATUS = CT-OK
             CALL "BLOCKS-FILL" USING WS-ID WS-ROW
             ADD 1 TO WS-ID GIVING CB-BLOCK-COUNT
             COMPUTE WS-STATE = CB-FIRST-STATE(WS-ID + 1) + CB-STATES(WS-ID + 1)
             MOVE WS-STATE TO CB-STATE-COUNT
         END-IF
     END-PERFORM
*>   The roles of the cobolcraft rules, by key.
     MOVE SPACES TO WS-PAIRS
     MOVE "cobolcraft:cardstack" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-CARDSTACK
     MOVE "axis=x,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-X
     MOVE "axis=y,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Y
     MOVE "axis=z,punched=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Z
     MOVE "axis=y,punched=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-CARDSTACK-Y-PUNCHED
     MOVE "cobolcraft:glowtube" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-GLOWTUBE
     MOVE "lit=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GLOWTUBE-LIT
     MOVE "lit=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GLOWTUBE-UNLIT
     MOVE SPACES TO WS-PAIRS
     MOVE "cobolcraft:goto_pad" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY CR-GOTO-PAD
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GOTO-PAD-STATE
     MOVE "cobolcraft:baseplate" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-BASEPLATE
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GREYSTONE
     MOVE "cobolcraft:loam" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-LOAM
     MOVE "cobolcraft:turf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-TURF
     MOVE "cobolcraft:grit" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-GRIT
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-LUCITE
     MOVE "cobolcraft:slag" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS CR-SLAG
     CALL "BIOMES-OPEN"
     GOBACK.
 END PROGRAM BLOCKS-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BIOMES-OPEN.
*> No parameters: fills CORE-BIOMES (CBLOCKS.cpy) from the biome registry of the open set: each entry's key and the
*> has_precipitation member of its network NBT payload.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROTO.
 01 WS-REGISTRY            PIC X(112) VALUE "minecraft:worldgen/biome".
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FULL                BINARY-LONG VALUE 4096.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO CBI-COUNT
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT OR CBI-COUNT >= CBI-MAX
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD
             WS-FULL WS-LENGTH WS-STATUS
         ADD 1 TO CBI-COUNT
         MOVE WS-KEY TO CBI-KEY(CBI-COUNT)
         MOVE WS-KEY-LENGTH TO CBI-KEY-LENGTH(CBI-COUNT)
         MOVE 0 TO CBI-PRECIPITATION(CBI-COUNT)
         CALL "PB-RESET" USING PB-BUFFER
         IF WS-LENGTH > 0
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-PAYLOAD WS-LENGTH
             MOVE 0 TO PB-POS
             CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WS-NAME
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WS-NAME WS-NAME-CAPACITY
                     WS-NAME-LENGTH
                 IF WS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF WS-NAME = "has_precipitation" AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER WS-BYTE
                     MOVE WS-BYTE TO CBI-PRECIPITATION(CBI-COUNT)
                 ELSE
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BIOMES-OPEN.
