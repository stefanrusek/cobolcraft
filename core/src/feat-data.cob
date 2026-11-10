*> The feature data compiler (docs/protocol/35-worldgen-features-1 sections 1, 7, 9; 35-2; FEATDATA.cpy): the JSON of worldgen/placed_feature and worldgen/feature
*> elements, read from the open content set (registry payloads) or from a folder (FD-SET-DIR, for tests and tools), compiled into the tables of FEAT-DATA on first use.
*> A reference to another placed feature or feature is a stub (compiled when first placed); an inline object is compiled in place.
*>
*> Entry points:
*>   FD-RESET                          empties the tables and raises FD-GEN
*>   FD-SET-DIR USING root (PIC X(1100)): the folder that holds data/<namespace>/worldgen/... (used when no content set is open)
*>   FD-GET-PF USING key (PIC X(80)), index out: the placed feature of that id (a stub row when new), 0 when the table is full
*>   FD-ENSURE-PF USING index: compiles a stub placed feature (PF-STATUS 1 or 2)
*>   FD-ENSURE-FT USING index: compiles a stub feature (FT-TYPE the registry id, or -1 unsupported)
*>   FD-BLOCK-INDEX USING key (PIC X(48)), index out: the 1-based number of the block in CORE-BLOCKS, 0 when absent

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 PROCEDURE DIVISION.
     MOVE 0 TO FD-PF-COUNT FD-MD-COUNT FD-FT-COUNT FD-CH-COUNT FD-PR-COUNT FD-POOL-COUNT FD-PV-COUNT FD-BAD
     ADD 1 TO FD-GEN
     GOBACK.
 END PROGRAM FD-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SET-DIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 PROCEDURE DIVISION USING L-DIR.
     MOVE L-DIR TO FD-DIR
     GOBACK.
 END PROGRAM FD-SET-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-BLOCK-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT OR L-INDEX > 0
         MOVE CB-KEY-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN > 0 AND WS-LEN <= 48
             IF CB-KEY(WS-I)(1:WS-LEN) = L-KEY(1:WS-LEN) AND (WS-LEN = 48 OR L-KEY(WS-LEN + 1:1) = SPACE)
                 MOVE WS-I TO L-INDEX
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FD-BLOCK-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-KEY.
*> USING text (PIC X(120)), key out (PIC X(80)): the id with "minecraft:" when it has no namespace.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLON               BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(120).
 01 L-KEY                  PIC X(80).
 PROCEDURE DIVISION USING L-TEXT L-KEY.
     MOVE 0 TO WS-COLON
     INSPECT L-TEXT TALLYING WS-COLON FOR ALL ":"
     MOVE SPACES TO L-KEY
     IF WS-COLON = 0
         STRING "minecraft:" FUNCTION TRIM(L-TEXT) DELIMITED BY SIZE INTO L-KEY
     ELSE
         MOVE L-TEXT TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM FD-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-STRING.
*> USING doc, member key (PIC X(40)), object node, text out (PIC X(120)), length out: the string member of an object (0 when absent or not a string).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
  01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 120.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-KEY                  PIC X(40).
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(120).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-KEY L-NODE L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-LENGTH
     COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE L-KEY WS-KEY-LENGTH WS-N
     IF WS-N > 0
         CALL "JSON-STRING" USING JSON-DOC WS-N L-TEXT WS-CAP L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM FD-J-STRING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-MEMBER.
*> USING doc, object node, member key (PIC X(40)), node out (0 when absent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-OUT.
     COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE L-KEY WS-KEY-LENGTH L-OUT
     GOBACK.
 END PROGRAM FD-J-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-INT.
*> USING doc, node, value out (BINARY-LONG), ok out (1 when the node is a number).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-VALUE L-OK.
     MOVE 0 TO L-OK L-VALUE
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-NUMBER
             MOVE JN-NUM(L-NODE) TO L-VALUE
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-J-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-ANCHOR.
*> USING doc, node, kind out (1 absolute, 2 above_bottom, 3 below_top, 4 relative_to_sea_level), value out, ok out: a vertical anchor object.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER PIC X(40) VALUE "absolute".
    05 FILLER PIC X(40) VALUE "above_bottom".
    05 FILLER PIC X(40) VALUE "below_top".
    05 FILLER PIC X(40) VALUE "relative_to_sea_level".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME PIC X(40) OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KIND L-VALUE L-OK.
     MOVE 0 TO L-OK L-KIND L-VALUE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4 OR L-OK = 1
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-NAME(WS-K) WS-N
         IF WS-N > 0
             CALL "FD-J-INT" USING JSON-DOC WS-N L-VALUE L-OK
             MOVE WS-K TO L-KIND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FD-J-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-IP.
*> USING doc, node, provider out (BINARY-LONG x 4: type, a, b, c), ok out. Types: 1 constant (a), 2 uniform (a to b), 3 biased_to_bottom (a to b), 4 very_biased_to_bottom
*> (a to b), 5 trapezoid (min a, max b, plateau c). A bare number is a constant.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-MN                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 4 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-P L-OK.
     MOVE 0 TO L-OK L-V(1) L-V(2) L-V(3) L-V(4)
     IF L-NODE = 0
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) = JT-NUMBER
         MOVE 1 TO L-V(1)
         CALL "FD-J-INT" USING JSON-DOC L-NODE L-V(2) L-OK
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:constant"
         WHEN "constant"
             MOVE 1 TO L-V(1)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-VALUE WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N L-V(2) L-OK
         WHEN "minecraft:uniform"
         WHEN "uniform"
             MOVE 2 TO L-V(1)
             CALL "FD-J-RANGE" USING JSON-DOC L-NODE WS-MN WS-MX L-OK
             MOVE WS-MN TO L-V(2)
             MOVE WS-MX TO L-V(3)
         WHEN "minecraft:biased_to_bottom"
         WHEN "biased_to_bottom"
             MOVE 3 TO L-V(1)
             CALL "FD-J-RANGE" USING JSON-DOC L-NODE WS-MN WS-MX L-OK
             MOVE WS-MN TO L-V(2)
             MOVE WS-MX TO L-V(3)
         WHEN "minecraft:very_biased_to_bottom"
         WHEN "very_biased_to_bottom"
             MOVE 4 TO L-V(1)
             CALL "FD-J-RANGE" USING JSON-DOC L-NODE WS-MN WS-MX L-OK
             MOVE WS-MN TO L-V(2)
             MOVE WS-MX TO L-V(3)
         WHEN "minecraft:trapezoid"
         WHEN "trapezoid"
             MOVE 5 TO L-V(1)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N L-V(2) L-OK
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N L-V(3) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PLATEAU WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N L-V(4) WS-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-J-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-RANGE.
*> USING doc, node, minimum out, maximum out, ok out: min_inclusive and max_inclusive of a provider object.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-MIN L-MAX L-OK.
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN-INC WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N L-MIN L-OK
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-INC WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N L-MAX WS-OK
     IF WS-OK = 0
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM FD-J-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-POOL-ADD.
*> USING value (BINARY-LONG), index out: appends to the pool (0 and FD-BAD when it is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-INDEX.
     MOVE 0 TO L-INDEX
     IF FD-POOL-COUNT >= FD-MAX-POOL
         MOVE 1 TO FD-BAD
     ELSE
         ADD 1 TO FD-POOL-COUNT
         MOVE L-VALUE TO FD-POOL(FD-POOL-COUNT)
         MOVE FD-POOL-COUNT TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM FD-POOL-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TAG-BLOCKS.
*> USING tag key (PIC X(112), with namespace, no "#"), then adds the block indices of the tag to the pool: count out. The open content set resolves any
*> tag; without one only minecraft:air is known (air, cave_air, void_air); another tag sets FD-BAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(48) VALUE "minecraft:block".
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 2048 TIMES.
 01 WS-CAP                 BINARY-LONG VALUE 2048.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-AIRS.
    05 FILLER PIC X(48) VALUE "minecraft:air".
    05 FILLER PIC X(48) VALUE "minecraft:cave_air".
    05 FILLER PIC X(48) VALUE "minecraft:void_air".
 01 WS-AIR-TABLE REDEFINES WS-AIRS.
    05 WS-AIR              PIC X(48) OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-TAG                  PIC X(112).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY L-TAG L-COUNT WS-IDS WS-CAP WS-STATUS
     IF WS-STATUS = CT-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             COMPUTE WS-VALUE = WS-ID(WS-I) + 1
             CALL "FD-POOL-ADD" USING WS-VALUE WS-INDEX
         END-PERFORM
     ELSE
         MOVE 0 TO L-COUNT
         IF L-TAG = "minecraft:air"
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 MOVE WS-AIR(WS-I) TO WS-KEY48
                 CALL "FD-BLOCK-INDEX" USING WS-KEY48 WS-VALUE
                 IF WS-VALUE > 0
                     CALL "FD-POOL-ADD" USING WS-VALUE WS-INDEX
                     ADD 1 TO L-COUNT
                 END-IF
             END-PERFORM
         ELSE
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TAG-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-BLOCKS.
*> USING doc, node, mode (1 blocks: ids of blocks or "#tag" -> block indices; 2 fluids: ids water, lava, empty -> codes 2, 3, 1), pool start out, count out: a HolderSet
*> field: one id, a "#tag", or an array of ids. An unknown block or tag sets FD-BAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-TEXT                PIC X(120).
 01 WS-TEXT2               PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-TAG                 PIC X(112).
 01 WS-INDEX               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 120.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-MODE L-START L-COUNT.
     COMPUTE L-START = FD-POOL-COUNT + 1
     MOVE 0 TO L-COUNT
     IF L-NODE = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     IF JN-TYPE(L-NODE) = JT-STRING
         MOVE 1 TO WS-N
     END-IF
     IF JN-TYPE(L-NODE) = JT-ARRAY
         MOVE JN-COUNT(L-NODE) TO WS-N
     END-IF
     IF WS-N = 0 AND JN-TYPE(L-NODE) NOT = JT-ARRAY
         MOVE 1 TO FD-BAD
     END-IF
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         MOVE L-NODE TO WS-E
         IF JN-TYPE(L-NODE) = JT-ARRAY
             CALL "JSON-ELEMENT" USING JSON-DOC L-NODE WS-I WS-E
         END-IF
         MOVE SPACES TO WS-TEXT
         CALL "JSON-STRING" USING JSON-DOC WS-E WS-TEXT WS-CAP WS-LEN
         IF WS-LEN = 0
             MOVE 1 TO FD-BAD
         ELSE
             IF WS-TEXT(1:1) = "#" AND L-MODE = 1
                 MOVE SPACES TO WS-KEY
                 MOVE WS-TEXT(2:119) TO WS-TEXT2
                 CALL "FD-KEY" USING WS-TEXT2 WS-KEY
                 MOVE WS-KEY TO WS-TAG
                 CALL "FD-TAG-BLOCKS" USING WS-TAG WS-ADDED
                 ADD WS-ADDED TO L-COUNT
             ELSE
                 CALL "FD-KEY" USING WS-TEXT WS-KEY
                 IF L-MODE = 1
                     MOVE WS-KEY TO WS-KEY48
                     CALL "FD-BLOCK-INDEX" USING WS-KEY48 WS-VALUE
                 ELSE
                     EVALUATE FUNCTION TRIM(WS-KEY)
                         WHEN "minecraft:empty"
                             MOVE 1 TO WS-VALUE
                         WHEN "minecraft:water"
                         WHEN "minecraft:flowing_water"
                             MOVE 2 TO WS-VALUE
                         WHEN "minecraft:lava"
                         WHEN "minecraft:flowing_lava"
                             MOVE 3 TO WS-VALUE
                         WHEN OTHER
                             MOVE 0 TO WS-VALUE
                     END-EVALUATE
                 END-IF
                 IF WS-VALUE = 0
                     MOVE 1 TO FD-BAD
                 ELSE
                     CALL "FD-POOL-ADD" USING WS-VALUE WS-INDEX
                     ADD 1 TO L-COUNT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FD-J-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-VEC.
*> USING doc, node, x out, y out, z out, ok out: an array of three ints.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK L-X L-Y L-Z
     IF L-NODE > 0
         IF JN-TYPE(L-NODE) = JT-ARRAY AND JN-COUNT(L-NODE) = 3
             MOVE 1 TO L-OK
             CALL "JSON-ELEMENT" USING JSON-DOC L-NODE FC-N0 WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E L-X WS-OK
             CALL "JSON-ELEMENT" USING JSON-DOC L-NODE FC-N1 WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E L-Y WS-OK
             CALL "JSON-ELEMENT" USING JSON-DOC L-NODE FC-N2 WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E L-Z WS-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-J-VEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PRED-NODE IS RECURSIVE.
*> USING doc, node, predicate index out (0 when the predicate is unsupported, which also sets FD-BAD): compiles a block predicate object (35-2 section 3).
*> Supported: matching_blocks, matching_block_tag, matching_fluids, solid, inside_world_bounds, any_of, all_of, not, true, unobstructed, height_range, volume_match.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 COPY FDKEYS.
 LOCAL-STORAGE SECTION.
 01 LS-TEXT                PIC X(120).
 01 LS-LEN                 BINARY-LONG.
 01 LS-NAME                PIC X(48).
 01 LS-KEY80               PIC X(80).
 01 LS-TAG                 PIC X(112).
 01 LS-TYPE                BINARY-LONG.
 01 LS-REG                 BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-PREV                BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-A                   BINARY-LONG.
 01 LS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-INDEX.
     MOVE 0 TO L-INDEX
     IF L-NODE = 0 OR FD-PR-COUNT >= FD-MAX-PR
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE LS-TEXT LS-LEN
     MOVE SPACES TO LS-NAME
     IF LS-TEXT(1:10) = "minecraft:"
         MOVE LS-TEXT(11:48) TO LS-NAME
     ELSE
         MOVE LS-TEXT TO LS-NAME
     END-IF
     MOVE 3 TO LS-REG
     CALL "F351-REGISTRY-ID" USING LS-REG LS-NAME LS-TYPE
     ADD 1 TO FD-PR-COUNT
     MOVE FD-PR-COUNT TO LS-ROW
     INITIALIZE FD-PR(LS-ROW)
     MOVE LS-TYPE TO PR-TYPE(LS-ROW)
     COMPUTE PR-POOL(LS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-OFFSET LS-E
     IF LS-E > 0
         CALL "FD-J-VEC" USING JSON-DOC LS-E PR-OX(LS-ROW) PR-OY(LS-ROW) PR-OZ(LS-ROW) LS-OK
     END-IF
     EVALUATE LS-TYPE
         WHEN 0
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-BLOCKS LS-E
             CALL "FD-J-BLOCKS" USING JSON-DOC LS-E FC-N1 PR-POOL(LS-ROW) PR-N(LS-ROW)
         WHEN 1
             CALL "FD-J-STRING" USING JSON-DOC FK-TAG L-NODE LS-TEXT LS-LEN
             COMPUTE PR-POOL(LS-ROW) = FD-POOL-COUNT + 1
             CALL "FD-KEY" USING LS-TEXT LS-KEY80
             MOVE LS-KEY80 TO LS-TAG
             CALL "FD-TAG-BLOCKS" USING LS-TAG PR-N(LS-ROW)
         WHEN 2
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FLUIDS LS-E
             CALL "FD-J-BLOCKS" USING JSON-DOC LS-E FC-N2 PR-POOL(LS-ROW) PR-N(LS-ROW)
         WHEN 5
         WHEN 8
         WHEN 12
         WHEN 13
             CONTINUE
         WHEN 9
         WHEN 10
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PREDICATES LS-E
             MOVE 0 TO LS-PREV
             IF LS-E > 0
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-E)
                     CALL "JSON-ELEMENT" USING JSON-DOC LS-E LS-I LS-N
                     CALL "FD-PRED-NODE" USING JSON-DOC LS-N LS-CHILD
                     IF LS-PREV = 0
                         MOVE LS-CHILD TO PR-CHILD(LS-ROW)
                     ELSE
                         MOVE LS-CHILD TO PR-NEXT(LS-PREV)
                     END-IF
                     MOVE LS-CHILD TO LS-PREV
                 END-PERFORM
             END-IF
         WHEN 11
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PREDICATE LS-E
             CALL "FD-PRED-NODE" USING JSON-DOC LS-E PR-CHILD(LS-ROW)
         WHEN 14
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN-INC LS-E
             CALL "FD-J-ANCHOR" USING JSON-DOC LS-E PR-A(LS-ROW) PR-B(LS-ROW) LS-OK
             IF LS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-INC LS-E
             CALL "FD-J-ANCHOR" USING JSON-DOC LS-E PR-C(LS-ROW) PR-D(LS-ROW) LS-OK
             IF LS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 15
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN LS-E
             CALL "FD-J-VEC" USING JSON-DOC LS-E LS-X LS-Y LS-Z LS-OK
             MOVE LS-X TO PR-A(LS-ROW)
             MOVE LS-Y TO PR-B(LS-ROW)
             MOVE LS-Z TO PR-C(LS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX LS-E
             CALL "FD-J-VEC" USING JSON-DOC LS-E LS-X LS-Y LS-Z LS-A
             MOVE LS-X TO PR-D(LS-ROW)
             MOVE LS-Y TO PR-E(LS-ROW)
             MOVE LS-Z TO PR-F(LS-ROW)
             IF LS-OK = 0 OR LS-A = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MATCH LS-E
             CALL "FD-PRED-NODE" USING JSON-DOC LS-E PR-CHILD(LS-ROW)
         WHEN OTHER
             MOVE 0 TO PR-TYPE(LS-ROW)
             MOVE 1 TO FD-BAD
     END-EVALUATE
     MOVE LS-ROW TO L-INDEX
     GOBACK.
 END PROGRAM FD-PRED-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-STATE.
*> USING doc, node, state out (BINARY-LONG), ok out: a block state object {"Name": id} or {"id": id}; the default state of the block. A non-empty properties object is
*> not supported (ok 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-STATE L-OK.
     MOVE 0 TO L-OK L-STATE
     IF L-NODE = 0
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC FK-NAME L-NODE WS-TEXT WS-LEN
     IF WS-LEN = 0
         CALL "FD-J-STRING" USING JSON-DOC FK-ID L-NODE WS-TEXT WS-LEN
     END-IF
     IF WS-LEN > 0
         MOVE 1 TO L-OK
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PROPERTIES WS-N
         IF WS-N > 0
             IF JN-COUNT(WS-N) > 0
                 MOVE 0 TO L-OK
             END-IF
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PROPERTIES-UC WS-N
         IF WS-N > 0
             IF JN-COUNT(WS-N) > 0
                 MOVE 0 TO L-OK
             END-IF
         END-IF
         CALL "FD-KEY" USING WS-TEXT WS-KEY
         MOVE WS-KEY TO WS-KEY48
         CALL "GEN-BLOCK-STATE" USING WS-KEY48 L-STATE
         CALL "FD-BLOCK-INDEX" USING WS-KEY48 WS-N
         IF WS-N = 0
             MOVE 0 TO L-OK
         END-IF
*>       the double plants place two halves (a property of the state): not supported
         EVALUATE FUNCTION TRIM(WS-KEY)
             WHEN "minecraft:tall_grass"
             WHEN "minecraft:large_fern"
             WHEN "minecraft:sunflower"
             WHEN "minecraft:lilac"
             WHEN "minecraft:rose_bush"
             WHEN "minecraft:peony"
             WHEN "minecraft:tall_seagrass"
                 MOVE 0 TO L-OK
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM FD-J-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PROV-NODE.
*> USING doc, node, provider index out (0 when unsupported, with FD-BAD): a block state provider: a state object (simple), or {"type": simple | weighted | random_block}.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-INDEX.
     MOVE 0 TO L-INDEX
     IF L-NODE = 0 OR FD-PV-COUNT >= FD-MAX-PV
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-PV-COUNT
     MOVE FD-PV-COUNT TO WS-ROW
     INITIALIZE FD-PV(WS-ROW)
     COMPUTE PV-POOL(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     IF WS-LEN = 0
         CALL "FD-J-STATE" USING JSON-DOC L-NODE PV-A(WS-ROW) WS-OK
         MOVE 1 TO PV-TYPE(WS-ROW)
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     ELSE
         EVALUATE FUNCTION TRIM(WS-TEXT)
             WHEN "minecraft:simple"
             WHEN "simple"
                 MOVE 1 TO PV-TYPE(WS-ROW)
                 CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
                 CALL "FD-J-STATE" USING JSON-DOC WS-E PV-A(WS-ROW) WS-OK
                 IF WS-OK = 0
                     MOVE 1 TO FD-BAD
                 END-IF
             WHEN "minecraft:weighted"
             WHEN "weighted"
                 MOVE 2 TO PV-TYPE(WS-ROW)
                 CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-ENTRIES WS-E
                 IF WS-E = 0
                     MOVE 1 TO FD-BAD
                 ELSE
                     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
                         CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
                         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-DATA WS-D
                         CALL "FD-J-STATE" USING JSON-DOC WS-D WS-S WS-OK
                         IF WS-OK = 0
                             MOVE 1 TO FD-BAD
                         END-IF
                         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-WEIGHT WS-D
                         CALL "FD-J-INT" USING JSON-DOC WS-D WS-W WS-OK
                         IF WS-OK = 0
                             MOVE 1 TO FD-BAD
                         END-IF
                         CALL "FD-POOL-ADD" USING WS-S WS-IDX
                         CALL "FD-POOL-ADD" USING WS-W WS-IDX
                         ADD 1 TO PV-N(WS-ROW)
                     END-PERFORM
                 END-IF
             WHEN "minecraft:random_block"
             WHEN "random_block"
                 MOVE 3 TO PV-TYPE(WS-ROW)
                 CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-BLOCKS WS-E
                 CALL "FD-J-BLOCKS" USING JSON-DOC WS-E FC-N1 PV-POOL(WS-ROW) PV-N(WS-ROW)
             WHEN OTHER
                 MOVE 1 TO FD-BAD
         END-EVALUATE
     END-IF
     MOVE WS-ROW TO L-INDEX
     GOBACK.
 END PROGRAM FD-PROV-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-J-HP.
*> USING doc, node, provider out (BINARY-LONG x 6: type, inner or plateau, minimum anchor kind and value, maximum anchor kind and value), ok out. Types: 1 constant (the
*> anchor in the minimum slot), 2 uniform, 3 biased_to_bottom (inner), 4 very_biased_to_bottom (inner), 5 trapezoid (plateau). A bare anchor object is a constant.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK2                 BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-P L-OK.
     MOVE 0 TO L-OK L-V(1) L-V(2) L-V(3) L-V(4) L-V(5) L-V(6)
     IF L-NODE = 0
         GOBACK
     END-IF
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     IF WS-LEN = 0
         MOVE 1 TO L-V(1)
         CALL "FD-J-ANCHOR" USING JSON-DOC L-NODE WS-K1 WS-V1 L-OK
         MOVE WS-K1 TO L-V(3)
         MOVE WS-V1 TO L-V(4)
         GOBACK
     END-IF
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:constant"
         WHEN "constant"
             MOVE 1 TO L-V(1)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-VALUE WS-N
             CALL "FD-J-ANCHOR" USING JSON-DOC WS-N WS-K1 WS-V1 L-OK
             MOVE WS-K1 TO L-V(3)
             MOVE WS-V1 TO L-V(4)
         WHEN OTHER
             EVALUATE FUNCTION TRIM(WS-TEXT)
                 WHEN "minecraft:uniform"
                 WHEN "uniform"
                     MOVE 2 TO L-V(1)
                 WHEN "minecraft:biased_to_bottom"
                 WHEN "biased_to_bottom"
                     MOVE 3 TO L-V(1)
                 WHEN "minecraft:very_biased_to_bottom"
                 WHEN "very_biased_to_bottom"
                     MOVE 4 TO L-V(1)
                 WHEN "minecraft:trapezoid"
                 WHEN "trapezoid"
                     MOVE 5 TO L-V(1)
             END-EVALUATE
             IF L-V(1) > 0
                 CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN-INC WS-N
                 CALL "FD-J-ANCHOR" USING JSON-DOC WS-N WS-K1 WS-V1 L-OK
             MOVE WS-K1 TO L-V(3)
             MOVE WS-V1 TO L-V(4)
                 CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-INC WS-N
                 CALL "FD-J-ANCHOR" USING JSON-DOC WS-N WS-K2 WS-V2 WS-OK2
                 MOVE WS-K2 TO L-V(5)
                 MOVE WS-V2 TO L-V(6)
                 IF WS-OK2 = 0
                     MOVE 0 TO L-OK
                 END-IF
                 MOVE 1 TO L-V(2)
                 IF L-V(1) = 5
                     MOVE 0 TO L-V(2)
                     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PLATEAU WS-N
                     CALL "FD-J-INT" USING JSON-DOC WS-N L-V(2) WS-OK2
                 ELSE
                     IF L-V(1) > 2
                         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-INNER WS-N
                         IF WS-N > 0
                             CALL "FD-J-INT" USING JSON-DOC WS-N L-V(2) WS-OK2
                         END-IF
                     END-IF
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-J-HP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-MD-NODE.
*> USING doc, node: appends the modifier of a placement entry to FD-MD (kind the id of worldgen/placement_modifier_type; FD-BAD for an unsupported one).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-REG                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HM                  PIC X(32).
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-P6.
    05 WS-R6               BINARY-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE.
     IF FD-MD-COUNT >= FD-MAX-MD
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-MD-COUNT
     MOVE FD-MD-COUNT TO WS-ROW
     INITIALIZE FD-MD(WS-ROW)
     MOVE -1 TO MD-KIND(WS-ROW)
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     MOVE SPACES TO WS-NAME
     IF WS-TEXT(1:10) = "minecraft:"
         MOVE WS-TEXT(11:48) TO WS-NAME
     ELSE
         MOVE WS-TEXT TO WS-NAME
     END-IF
     MOVE 2 TO WS-REG
     CALL "F351-REGISTRY-ID" USING WS-REG WS-NAME MD-KIND(WS-ROW)
     EVALUATE MD-KIND(WS-ROW)
         WHEN 0
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PREDICATE WS-E
             CALL "FD-PRED-NODE" USING JSON-DOC WS-E MD-PR(WS-ROW)
         WHEN 1
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CHANCE WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E MD-A(WS-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 2
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CHANCE WS-E
             IF WS-E = 0
                 MOVE 1 TO FD-BAD
             ELSE
                 MOVE JN-NUM(WS-E) TO MD-F(WS-ROW)
             END-IF
         WHEN 3
             CALL "FD-J-STRING" USING JSON-DOC FK-HEIGHTMAP L-NODE WS-TEXT WS-LEN
             MOVE WS-TEXT TO WS-HM
             CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM MD-A(WS-ROW)
             MOVE -2147483648 TO MD-B(WS-ROW)
             MOVE 2147483647 TO MD-C(WS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MIN-INC WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E MD-B(WS-ROW) WS-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-INC WS-E
             IF WS-E > 0
                 CALL "FD-J-INT" USING JSON-DOC WS-E MD-C(WS-ROW) WS-OK
             END-IF
             IF MD-A(WS-ROW) < 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 4
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-WATER WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E MD-A(WS-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 5
             CONTINUE
         WHEN 6
         WHEN 9
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-COUNT WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 10
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-XZ-SIZE WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-Y-SIZE WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I + 4)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             MOVE 1 TO MD-C(WS-ROW) MD-D(WS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-EDGES WS-E
             IF WS-E > 0
                 IF JN-TYPE(WS-E) = JT-FALSE
                     MOVE 0 TO MD-C(WS-ROW)
                 END-IF
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-INTERIOR WS-E
             IF WS-E > 0
                 IF JN-TYPE(WS-E) = JT-FALSE
                     MOVE 0 TO MD-D(WS-ROW)
                 END-IF
             END-IF
         WHEN 11
             CALL "FD-J-STRING" USING JSON-DOC FK-DIRECTION L-NODE WS-TEXT WS-LEN
             EVALUATE FUNCTION TRIM(WS-TEXT)
                 WHEN "up"
                     MOVE 1 TO MD-A(WS-ROW)
                 WHEN "down"
                     MOVE -1 TO MD-A(WS-ROW)
                 WHEN OTHER
                     MOVE 1 TO FD-BAD
             END-EVALUATE
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-TARGET WS-E
             CALL "FD-PRED-NODE" USING JSON-DOC WS-E MD-PR(WS-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-ALLOWED WS-E
             IF WS-E > 0
                 CALL "FD-PRED-NODE" USING JSON-DOC WS-E MD-PR2(WS-ROW)
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-MAX-STEPS WS-E
             CALL "FD-J-INT" USING JSON-DOC WS-E MD-B(WS-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 12
             CALL "FD-J-STRING" USING JSON-DOC FK-HEIGHTMAP L-NODE WS-TEXT WS-LEN
             MOVE WS-TEXT TO WS-HM
             CALL "F351-HEIGHTMAP-ORDINAL" USING WS-HM MD-A(WS-ROW)
             IF MD-A(WS-ROW) < 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 13
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-HEIGHT WS-E
             CALL "FD-J-HP" USING JSON-DOC WS-E WS-P6 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-R6(WS-I) TO MD-P(WS-ROW, WS-I)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 14
             CONTINUE
         WHEN 15
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-X WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-Y WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I + 4)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-Z WS-E
             CALL "FD-J-IP" USING JSON-DOC WS-E WS-P4 WS-OK
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE WS-Q(WS-I) TO MD-P(WS-ROW, WS-I + 8)
             END-PERFORM
             IF WS-OK = 0
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     GOBACK.
 END PROGRAM FD-MD-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-GET-PF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FD-PF-COUNT OR L-INDEX > 0
         IF PF-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     IF L-INDEX = 0 AND FD-PF-COUNT < FD-MAX-PF
         ADD 1 TO FD-PF-COUNT
         INITIALIZE FD-PF(FD-PF-COUNT)
         MOVE L-KEY TO PF-KEY(FD-PF-COUNT)
         MOVE FD-PF-COUNT TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM FD-GET-PF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-GET-FT.
*> USING key (PIC X(80)), index out: the feature of that id (a stub row when new).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FD-FT-COUNT OR L-INDEX > 0
         IF FT-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     IF L-INDEX = 0 AND FD-FT-COUNT < FD-MAX-FT
         ADD 1 TO FD-FT-COUNT
         INITIALIZE FD-FT(FD-FT-COUNT)
         MOVE L-KEY TO FT-KEY(FD-FT-COUNT)
         MOVE FD-FT-COUNT TO L-INDEX
     END-IF
     GOBACK.
 END PROGRAM FD-GET-FT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PFREF-NODE IS RECURSIVE.
*> USING doc, node, placed feature index out: a reference to a placed feature: an id (a stub) or an inline object (compiled in place); 0 with FD-BAD otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LOCAL-STORAGE SECTION.
 01 LS-TEXT                PIC X(120).
 01 LS-LEN                 BINARY-LONG.
 01 LS-KEY                 PIC X(80).
 01 LS-CAP                 BINARY-LONG VALUE 120.
 01 LS-NUM                 PIC 9(6).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-INDEX.
     MOVE 0 TO L-INDEX
     IF L-NODE = 0
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     IF JN-TYPE(L-NODE) = JT-STRING
         MOVE SPACES TO LS-TEXT
         CALL "JSON-STRING" USING JSON-DOC L-NODE LS-TEXT LS-CAP LS-LEN
         CALL "FD-KEY" USING LS-TEXT LS-KEY
         CALL "FD-GET-PF" USING LS-KEY L-INDEX
     ELSE
         IF JN-TYPE(L-NODE) = JT-OBJECT
             MOVE FD-PF-COUNT TO LS-NUM
             MOVE SPACES TO LS-KEY
             STRING "inline#" LS-NUM DELIMITED BY SIZE INTO LS-KEY
             CALL "FD-GET-PF" USING LS-KEY L-INDEX
             IF L-INDEX > 0
                 CALL "FD-PF-NODE" USING JSON-DOC L-NODE L-INDEX
             END-IF
         END-IF
     END-IF
     IF L-INDEX = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-PFREF-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FEAT-NODE IS RECURSIVE.
*> USING doc, node, feature index (in and out: 0 allocates a row): compiles a feature object (35-1 section 9 and the leaf types listed in feat-run.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 LOCAL-STORAGE SECTION.
 01 LS-TEXT                PIC X(120).
 01 LS-LEN                 BINARY-LONG.
 01 LS-NAME                PIC X(48).
 01 LS-REG                 BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-PF                  BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-CHANCE              BINARY-LONG.
 01 LS-CH                  BINARY-LONG.
 01 LS-NC                 BINARY-LONG.
 01 LS-KIDS.
    05 LS-KID OCCURS 64 TIMES.
       10 LS-CPF            BINARY-LONG.
       10 LS-CW             BINARY-LONG.
       10 LS-CF             FLOAT-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-INDEX.
     IF L-INDEX = 0
         IF FD-FT-COUNT >= FD-MAX-FT
             MOVE 1 TO FD-BAD
             GOBACK
         END-IF
         ADD 1 TO FD-FT-COUNT
         INITIALIZE FD-FT(FD-FT-COUNT)
         MOVE FD-FT-COUNT TO L-INDEX
     END-IF
     MOVE L-INDEX TO LS-ROW
     MOVE -1 TO FT-TYPE(LS-ROW)
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE LS-TEXT LS-LEN
     MOVE SPACES TO LS-NAME
     IF LS-TEXT(1:10) = "minecraft:"
         MOVE LS-TEXT(11:48) TO LS-NAME
     ELSE
         MOVE LS-TEXT TO LS-NAME
     END-IF
     MOVE 1 TO LS-REG
     CALL "F351-REGISTRY-ID" USING LS-REG LS-NAME LS-N
     MOVE LS-N TO FT-TYPE(LS-ROW)
     MOVE 0 TO LS-NC
     EVALUATE LS-N
         WHEN 30
             CONTINUE
         WHEN 36
*>           random_selector: features (feature, chance) then default
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURES LS-E
             IF LS-E > 0
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-E)
                     CALL "JSON-ELEMENT" USING JSON-DOC LS-E LS-I LS-N
                     CALL "FD-J-MEMBER" USING JSON-DOC LS-N FK-FEATURE LS-D
                     CALL "FD-PFREF-NODE" USING JSON-DOC LS-D LS-PF
                     CALL "FD-J-MEMBER" USING JSON-DOC LS-N FK-CHANCE LS-D
                     CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
                     IF LS-D > 0
                         MOVE JN-NUM(LS-D) TO LS-CF(LS-CH)
                     END-IF
                 END-PERFORM
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-DEFAULT LS-E
             CALL "FD-PFREF-NODE" USING JSON-DOC LS-E FT-C(LS-ROW)
         WHEN 43
         WHEN 41
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURES LS-E
             IF LS-E > 0
                 IF JN-TYPE(LS-E) = JT-ARRAY
                     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-E)
                         CALL "JSON-ELEMENT" USING JSON-DOC LS-E LS-I LS-N
                         CALL "FD-PFREF-NODE" USING JSON-DOC LS-N LS-PF
                         MOVE 0 TO LS-D
                         CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
                     END-PERFORM
                 ELSE
                     CALL "FD-PFREF-NODE" USING JSON-DOC LS-E LS-PF
                     MOVE 0 TO LS-D
                     CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
                 END-IF
             ELSE
                 MOVE 1 TO FD-BAD
             END-IF
         WHEN 34
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURE-TRUE LS-E
             CALL "FD-PFREF-NODE" USING JSON-DOC LS-E LS-PF
             MOVE 0 TO LS-D
             CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURE-FALSE LS-E
             CALL "FD-PFREF-NODE" USING JSON-DOC LS-E LS-PF
             CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
         WHEN 57
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURES LS-E
             IF LS-E > 0
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-E)
                     CALL "JSON-ELEMENT" USING JSON-DOC LS-E LS-I LS-N
                     CALL "FD-J-MEMBER" USING JSON-DOC LS-N FK-DATA LS-D
                     CALL "FD-PFREF-NODE" USING JSON-DOC LS-D LS-PF
                     CALL "FD-J-MEMBER" USING JSON-DOC LS-N FK-WEIGHT LS-D
                     CALL "FD-J-INT" USING JSON-DOC LS-D LS-CHANCE LS-OK
                     MOVE 0 TO LS-D
                     CALL "FD-KID-ADD" USING LS-NC LS-KIDS LS-PF LS-D LS-CH
                     MOVE LS-CHANCE TO LS-CW(LS-CH)
                 END-PERFORM
             END-IF
         WHEN 42
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-TO-PLACE LS-E
             CALL "FD-PROV-NODE" USING JSON-DOC LS-E FT-A(LS-ROW)
         WHEN OTHER
             MOVE -1 TO FT-TYPE(LS-ROW)
             MOVE 1 TO FD-BAD
     END-EVALUATE
     IF FT-TYPE(LS-ROW) = 36 OR FT-TYPE(LS-ROW) = 43 OR FT-TYPE(LS-ROW) = 41 OR FT-TYPE(LS-ROW) = 34 OR FT-TYPE(LS-ROW) = 57
         COMPUTE FT-A(LS-ROW) = FD-CH-COUNT + 1
         MOVE LS-NC TO FT-B(LS-ROW)
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-NC
             IF FD-CH-COUNT >= FD-MAX-CH
                 MOVE 1 TO FD-BAD
             ELSE
                 ADD 1 TO FD-CH-COUNT
                 MOVE LS-CPF(LS-I) TO CH-PF(FD-CH-COUNT)
                 MOVE LS-CW(LS-I) TO CH-W(FD-CH-COUNT)
                 MOVE LS-CF(LS-I) TO CH-F(FD-CH-COUNT)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FD-FEAT-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-PF-NODE IS RECURSIVE.
*> USING doc, node, placed feature index (the row to fill): {"feature": id | object, "placement": [modifier, ...]}. The row is status 1, or 2 when anything in
*> it (or in an inline feature) is unsupported.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 LOCAL-STORAGE SECTION.
 01 LS-E                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-TEXT                PIC X(120).
 01 LS-LEN                 BINARY-LONG.
 01 LS-KEY                 PIC X(80).
 01 LS-CAP                 BINARY-LONG VALUE 120.
 01 LS-FIRST               BINARY-LONG.
 01 LS-SAVED               BINARY-LONG.
 01 LS-FT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-PF                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-PF.
     MOVE FD-BAD TO LS-SAVED
     MOVE 0 TO FD-BAD
     COMPUTE PF-MD-FIRST(L-PF) = FD-MD-COUNT + 1
     MOVE 0 TO PF-MD-COUNT(L-PF)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PLACEMENT LS-E
     IF LS-E = 0
         MOVE 1 TO FD-BAD
     ELSE
         MOVE FD-MD-COUNT TO LS-FIRST
         PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= JN-COUNT(LS-E)
             CALL "JSON-ELEMENT" USING JSON-DOC LS-E LS-I LS-N
             CALL "FD-MD-NODE" USING JSON-DOC LS-N
         END-PERFORM
         COMPUTE PF-MD-COUNT(L-PF) = FD-MD-COUNT - LS-FIRST
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FEATURE LS-E
     MOVE 0 TO LS-FT
     IF LS-E = 0
         MOVE 1 TO FD-BAD
     ELSE
         IF JN-TYPE(LS-E) = JT-STRING
             MOVE SPACES TO LS-TEXT
             CALL "JSON-STRING" USING JSON-DOC LS-E LS-TEXT LS-CAP LS-LEN
             CALL "FD-KEY" USING LS-TEXT LS-KEY
             CALL "FD-GET-FT" USING LS-KEY LS-FT
         ELSE
             CALL "FD-FEAT-NODE" USING JSON-DOC LS-E LS-FT
         END-IF
     END-IF
     MOVE LS-FT TO PF-FT(L-PF)
     IF FD-BAD = 1
         MOVE 2 TO PF-STATUS(L-PF)
     ELSE
         MOVE 1 TO PF-STATUS(L-PF)
     END-IF
     IF LS-SAVED = 1
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-PF-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FETCH.
*> USING registry (PIC X(16): "placed_feature" or "feature"), key (PIC X(80), with namespace), text area (PIC X(65536)), length out, status out (0 read, 1 absent).
*> The open content set's registry worldgen/<registry> first; else the folder of FD-SET-DIR: <dir>/data/<namespace>/worldgen/<registry>/<path>.json.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(112).
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRY-KEY           PIC X(112).
 01 WS-ENTRY-LEN           BINARY-LONG.
 01 WS-ONE                 PIC X.
 01 WS-CAP-ONE             BINARY-LONG VALUE 1.
 01 WS-CAP                 BINARY-LONG VALUE 65536.
 01 WS-LEN                 BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LEN            BINARY-LONG.
 01 WS-NS                  PIC X(40).
 01 WS-NAME                PIC X(80).
 01 WS-COLON               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(16).
 01 L-KEY                  PIC X(80).
 01 L-TEXT                 PIC X(65536).
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-KEY L-TEXT L-LENGTH L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE 0 TO L-LENGTH WS-FOUND
     MOVE SPACES TO WS-REGISTRY
     STRING "minecraft:worldgen/" FUNCTION TRIM(L-REGISTRY) DELIMITED BY SIZE INTO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     IF WS-STATUS = CT-OK AND WS-COUNT > 0
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-COUNT OR WS-FOUND = 1
             CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-I WS-ENTRY-KEY WS-ENTRY-LEN WS-ONE WS-CAP-ONE WS-LEN WS-STATUS
             IF WS-ENTRY-KEY(1:80) = L-KEY
                 MOVE 1 TO WS-FOUND
                 CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-I WS-ENTRY-KEY WS-ENTRY-LEN L-TEXT WS-CAP L-LENGTH WS-STATUS
                 IF WS-STATUS = CT-OK
                     MOVE 0 TO L-STATUS
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     IF L-STATUS = 1 AND FD-DIR NOT = SPACES
         MOVE 0 TO WS-COLON
         INSPECT L-KEY TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
         MOVE SPACES TO WS-NS WS-NAME
         MOVE L-KEY(1:WS-COLON) TO WS-NS
         MOVE L-KEY(WS-COLON + 2:79 - WS-COLON) TO WS-NAME
         MOVE SPACES TO WS-PATH
         STRING FUNCTION TRIM(FD-DIR) "/data/" FUNCTION TRIM(WS-NS) "/worldgen/" FUNCTION TRIM(L-REGISTRY) "/" FUNCTION TRIM(WS-NAME) ".json"
             DELIMITED BY SIZE INTO WS-PATH
         COMPUTE WS-PATH-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-PATH))
         CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LEN L-TEXT WS-CAP L-LENGTH WS-STATUS
         IF WS-STATUS = 0
             MOVE 0 TO L-STATUS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-FETCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ENSURE-PF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 COPY JSONDOC.
 01 WS-TEXT                PIC X(65536).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                PIC X(16) VALUE "placed_feature".
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     IF PF-STATUS(L-INDEX) NOT = 0
         GOBACK
     END-IF
     MOVE 2 TO PF-STATUS(L-INDEX)
     CALL "FD-FETCH" USING WS-KIND PF-KEY(L-INDEX) WS-TEXT WS-LEN WS-STATUS
     IF WS-STATUS = 0
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
         IF JD-ERROR = 0 AND JD-COUNT > 0
             MOVE 0 TO FD-BAD
             CALL "FD-PF-NODE" USING JSON-DOC FC-N1 L-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-ENSURE-PF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ENSURE-FT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDCONST.
 COPY FEATDATA.
 COPY JSONDOC.
 01 WS-TEXT                PIC X(65536).
 01 WS-LEN                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                PIC X(16) VALUE "feature".
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     IF FT-TYPE(L-INDEX) NOT = 0
         GOBACK
     END-IF
     MOVE -1 TO FT-TYPE(L-INDEX)
     CALL "FD-FETCH" USING WS-KIND FT-KEY(L-INDEX) WS-TEXT WS-LEN WS-STATUS
     IF WS-STATUS = 0
         CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
         IF JD-ERROR = 0 AND JD-COUNT > 0
             MOVE 0 TO FD-BAD
             MOVE L-INDEX TO WS-INDEX
             CALL "FD-FEAT-NODE" USING JSON-DOC FC-N1 WS-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-ENSURE-FT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-KID-ADD.
*> USING count (in and out), the table of children (64 x placed feature, weight, chance), placed feature, flag (0 sets weight 1), index out: appends a child
*> of the selector being compiled; more than 64 sets FD-BAD and answers index 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 01 L-NC                   BINARY-LONG.
 01 L-KIDS.
    05 L-KID OCCURS 64 TIMES.
       10 L-CPF            BINARY-LONG.
       10 L-CW             BINARY-LONG.
       10 L-CF             FLOAT-LONG.
 01 L-PF                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 01 L-CH                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NC L-KIDS L-PF L-FLAG L-CH.
     IF L-NC >= 64
         MOVE 1 TO FD-BAD
         MOVE 1 TO L-CH
     ELSE
         ADD 1 TO L-NC
         MOVE L-NC TO L-CH
         MOVE L-PF TO L-CPF(L-CH)
         MOVE 0 TO L-CF(L-CH)
         MOVE 1 TO L-CW(L-CH)
     END-IF
     GOBACK.
 END PROGRAM FD-KID-ADD.
