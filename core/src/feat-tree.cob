*> The tree feature of the feature stage (docs/protocol/35-worldgen-features-3-tree-placers.md sections 1 to 5; feature type 51): FD-TREE-NODE compiles the data of a tree feature into FD-TR
*> (FEATDATA.cpy), FR-TREE places it, the trunk placers are in feat-tree-trunk.cob (FR-TRUNK) and the foliage placers in feat-tree-foliage.cob (FR-FOLIAGE). Supported: the trunk placers straight,
*> fancy, dark oak, giant, mega jungle, forking and upwards branching (mangrove, with its mangrove root placer: feat-tree-root.cob); the foliage placers blob, spruce, pine, acacia, fancy, jungle, mega pine and dark oak; the two and three layers feature sizes. Anything else
*> (another placer or root placer, an unknown decorator) marks the feature unsupported (FD-BAD). min_clipped_height is supported (2.2 step 6).
*> Deviations (the lane's notes, docs/design/world-types.md "Trees"): the tree is built in the grid of TREEWORK.cpy and written through the level, whose write window is one chunk: the trunk
*> stands in the chunk of its origin and the blocks that fall in a neighbouring chunk go to the overflow list and are written into that chunk when it exists (gen-overflow.cob; a neighbour's terrain is not known here);
*> the decorators trunk_vine, leave_vine and cocoa are placed after the tree (feat-tree-deco.cob), the others of the data are accepted and ignored (the beehive, the podzol ground, the leaf litter,
*> the shelf mushrooms, the moss, the creaking heart and the propagules of the mangrove: their draws are not made); the leaf distances of section 2.4 are the breadth first distances from this tree's logs through its own leaves (the hash set order of the layers
*> is not reproduced, Open question 1 there) and neighbouring blocks outside the tree do not lower them; the shape update at the edge (2.5) only schedules leaf ticks and is not run; leaves
*> are written not persistent and not waterlogged; states are the default states of the blocks, except the axis of the logs of the fancy trunk limbs; ignore_vines is not read (vines are
*> not tested in the free height scan).
*>
*> Entry points: FD-TREE-NODE USING doc, node, row out; FR-TREE USING state, feature, x, y, z, result out (1 placed).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-STATE.
*> USING doc, node, state out, block index out, ok out: a block state object {"id": ..} (properties are the default ones and are not read).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FDKEYS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-STATE L-BLOCK L-OK.
     MOVE 0 TO L-OK L-STATE L-BLOCK
     CALL "FD-J-STRING" USING JSON-DOC FK-ID L-NODE WS-TEXT WS-LEN
     IF WS-LEN = 0
         CALL "FD-J-STRING" USING JSON-DOC FK-NAME L-NODE WS-TEXT WS-LEN
     END-IF
     IF WS-LEN > 0
         CALL "FD-KEY" USING WS-TEXT WS-KEY
         MOVE WS-KEY TO WS-KEY48
         CALL "FD-BLOCK-INDEX" USING WS-KEY48 L-BLOCK
         IF L-BLOCK > 0
             CALL "GEN-BLOCK-STATE" USING WS-KEY48 L-STATE
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-LEAFPROV.
*> USING doc, node, feature row, ok out: a weighted foliage provider {"type": "minecraft:weighted", "entries": [{"data": state, "weight": n}, ...]} (35-2 section 4): the pairs (state, weight)
*> go to the pool (TR-LP-START, TR-LP-N, TR-LP-TOTAL); TR-LEAF-STATE and TR-LEAF-BLOCK are those of the first entry. A data is a block id string or a state object; the leaves of all entries must have
*> the same number of states (the distance arithmetic of the commit is shared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY CBLOCKS.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY48               PIC X(48).
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-WOK                 BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-OK.
     MOVE 0 TO L-OK
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE L-NODE WS-TEXT WS-LEN
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:weighted" AND FUNCTION TRIM(WS-TEXT) NOT = "weighted"
         GOBACK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-ENTRIES WS-E
     IF WS-E = 0
         GOBACK
     END-IF
     IF JN-TYPE(WS-E) NOT = JT-ARRAY OR JN-COUNT(WS-E) < 1 OR JN-COUNT(WS-E) > 16
         GOBACK
     END-IF
     MOVE 1 TO L-OK
     COMPUTE TR-LP-START(L-ROW) = FD-POOL-COUNT + 1
     MOVE 0 TO TR-LP-N(L-ROW) TR-LP-TOTAL(L-ROW) WS-FIRST
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E)
         CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-DATA WS-D
         MOVE 0 TO WS-STATE WS-BLOCK
         IF WS-D > 0
             IF JN-TYPE(WS-D) = JT-STRING
                 MOVE SPACES TO WS-TEXT
                 CALL "JSON-STRING" USING JSON-DOC WS-D WS-TEXT 120 WS-LEN
                 CALL "FD-KEY" USING WS-TEXT WS-KEY
                 MOVE WS-KEY TO WS-KEY48
                 CALL "FD-BLOCK-INDEX" USING WS-KEY48 WS-BLOCK
                 IF WS-BLOCK > 0
                     CALL "GEN-BLOCK-STATE" USING WS-KEY48 WS-STATE
                 END-IF
             ELSE
                 CALL "FD-TREE-STATE" USING JSON-DOC WS-D WS-STATE WS-BLOCK WS-WOK
             END-IF
         END-IF
         CALL "FD-J-MEMBER" USING JSON-DOC WS-N FK-WEIGHT WS-D
         CALL "FD-J-INT" USING JSON-DOC WS-D WS-W WS-WOK
         IF WS-BLOCK < 1 OR WS-WOK = 0 OR WS-W < 0
             MOVE 0 TO L-OK
         ELSE
             IF WS-FIRST = 0
                 MOVE WS-STATE TO TR-LEAF-STATE(L-ROW)
                 MOVE WS-BLOCK TO TR-LEAF-BLOCK(L-ROW)
                 MOVE WS-BLOCK TO WS-FIRST
             ELSE
                 IF CB-STATES(WS-BLOCK) NOT = CB-STATES(WS-FIRST)
                     MOVE 0 TO L-OK
                 END-IF
             END-IF
             CALL "FD-POOL-ADD" USING WS-STATE WS-IDX
             CALL "FD-POOL-ADD" USING WS-W WS-IDX
             ADD 1 TO TR-LP-N(L-ROW)
             ADD WS-W TO TR-LP-TOTAL(L-ROW)
         END-IF
     END-PERFORM
     IF TR-LP-TOTAL(L-ROW) < 1
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-LEAFPROV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-IP.
*> USING doc, object node, member key (PIC X(40)), provider out (4 integers like FR-INT-SAMPLE): the int provider member; an absent member is the constant 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-N                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-KEY                  PIC X(40).
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-KEY L-P.
     MOVE 1 TO L-V(1)
     MOVE 0 TO L-V(2) L-V(3) L-V(4)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE L-KEY WS-N
     IF WS-N > 0
         CALL "FD-J-IP" USING JSON-DOC WS-N L-P WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-IP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-NODE.
*> USING doc, node, row out (0 and FD-BAD when unsupported): compiles {"type": "minecraft:tree", ...} into a row of FD-TR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-K-TRUNK-PLACER      PIC X(40) VALUE "trunk_placer".
 01 WS-K-FOLIAGE-PLACER    PIC X(40) VALUE "foliage_placer".
 01 WS-K-TRUNK-PROVIDER    PIC X(40) VALUE "trunk_provider".
 01 WS-K-FOLIAGE-PROVIDER  PIC X(40) VALUE "foliage_provider".
 01 WS-K-MINIMUM-SIZE      PIC X(40) VALUE "minimum_size".
 01 WS-K-DECORATORS        PIC X(40) VALUE "decorators".
 01 WS-K-ROOT-PLACER       PIC X(40) VALUE "root_placer".
 01 WS-K-BELOW             PIC X(40) VALUE "below_trunk_provider".
 01 WS-K-BASE              PIC X(40) VALUE "base_height".
 01 WS-K-RAND-A            PIC X(40) VALUE "height_rand_a".
 01 WS-K-RAND-B            PIC X(40) VALUE "height_rand_b".
 01 WS-K-RADIUS            PIC X(40) VALUE "radius".
 01 WS-K-OFFSET            PIC X(40) VALUE "offset".
 01 WS-K-TRUNK-HEIGHT      PIC X(40) VALUE "trunk_height".
 01 WS-K-LIMIT             PIC X(40) VALUE "limit".
 01 WS-K-LOWER             PIC X(40) VALUE "lower_size".
 01 WS-K-UPPER             PIC X(40) VALUE "upper_size".
 01 WS-K-CLIPPED           PIC X(40) VALUE "min_clipped_height".
 01 WS-TAG-REPL            PIC X(112) VALUE "minecraft:replaceable_by_trees".
 01 WS-TAG-LOGS            PIC X(112) VALUE "minecraft:logs".
 01 WS-TAG-CANT            PIC X(112) VALUE "minecraft:cannot_replace_below_tree_trunk".
 01 WS-DIRT                PIC X(48) VALUE "minecraft:dirt".
 01 WS-K-UPLIM            PIC X(40) VALUE "upper_limit".
 01 WS-K-MIDDLE            PIC X(40) VALUE "middle_size".
 01 WS-K-CROWN             PIC X(40) VALUE "crown_height".
 01 WS-K-FOLIAGE-HEIGHT    PIC X(40) VALUE "foliage_height".
 01 WS-K-ATTEMPTS          PIC X(40) VALUE "leaf_placement_attempts".
 01 WS-TAG-LVS             PIC X(112) VALUE "minecraft:leaves".
 01 WS-J                   BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-HKEY                PIC X(40).
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-IP.
    05 WS-IPV              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-TR-COUNT >= 256
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-TR-COUNT
     MOVE FD-TR-COUNT TO WS-ROW
     INITIALIZE FD-TR(WS-ROW)
     MOVE WS-ROW TO L-ROW
     MOVE -1 TO TR-MINCLIP(WS-ROW)
*>   the root placer (the mangrove one)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-ROOT-PLACER WS-E
     IF WS-E > 0
         CALL "FD-TREE-ROOT-NODE" USING JSON-DOC WS-E WS-ROW
     END-IF
*>   the decorators (feat-tree-deco.cob): every registered type is accepted, the supported ones are compiled, an unknown type is unsupported
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DECORATORS WS-E
     IF WS-E > 0
         IF JN-COUNT(WS-E) > 10
             MOVE 1 TO FD-BAD
         END-IF
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JN-COUNT(WS-E) OR WS-I >= 10
             CALL "JSON-ELEMENT" USING JSON-DOC WS-E WS-I WS-N
             ADD 1 TO TR-NDEC(WS-ROW)
             CALL "FD-DECO-NODE" USING JSON-DOC WS-N WS-ROW TR-NDEC(WS-ROW)
         END-PERFORM
     END-IF
*>   the soil under the trunk
     CALL "FD-J-STRING" USING JSON-DOC WS-K-BELOW L-NODE WS-TEXT WS-LEN
     CALL "GEN-BLOCK-STATE" USING WS-DIRT TR-SOIL-STATE(WS-ROW)
     IF FUNCTION TRIM(WS-TEXT) NOT = "minecraft:soil_beneath_tree"
*>       a plain state object (the azalea tree's rooted_dirt): placeBelowTrunkBlock sets that state whatever is below the trunk
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BELOW WS-E
         CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-SOIL-STATE(WS-ROW) WS-BLOCK WS-OK
         IF WS-OK = 0
             MOVE 1 TO FD-BAD
         ELSE
             MOVE 1 TO TR-SOIL-ALWAYS(WS-ROW)
         END-IF
     END-IF
*>   the trunk placer
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRUNK-PLACER WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:straight_trunk_placer"
             MOVE 1 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:fancy_trunk_placer"
             MOVE 2 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:dark_oak_trunk_placer"
             MOVE 3 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:giant_trunk_placer"
             MOVE 4 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:mega_jungle_trunk_placer"
             MOVE 5 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:forking_trunk_placer"
             MOVE 6 TO TR-TKIND(WS-ROW)
         WHEN "minecraft:upwards_branching_trunk_placer"
             MOVE 7 TO TR-TKIND(WS-ROW)
             CALL "FD-TREE-UP-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN "minecraft:cherry_trunk_placer"
             MOVE 8 TO TR-TKIND(WS-ROW)
             CALL "FD-TREE-CHERRY-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN "minecraft:bending_trunk_placer"
             MOVE 9 TO TR-TKIND(WS-ROW)
             CALL "FD-TREE-BEND-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN "minecraft:poplar_trunk_placer"
             MOVE 10 TO TR-TKIND(WS-ROW)
             CALL "FD-TREE-POPLAR-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-BASE WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-BASE(WS-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-RAND-A WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-RA(WS-ROW) WS-OK
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-RAND-B WS-N
     CALL "FD-J-INT" USING JSON-DOC WS-N TR-RB(WS-ROW) WS-OK
*>   the states
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-TRUNK-PROVIDER WS-E
     CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-LOG-STATE(WS-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FOLIAGE-PROVIDER WS-E
     CALL "FD-TREE-STATE" USING JSON-DOC WS-E TR-LEAF-STATE(WS-ROW) TR-LEAF-BLOCK(WS-ROW) WS-OK
     IF WS-OK = 0
         CALL "FD-TREE-LEAFPROV" USING JSON-DOC WS-E WS-ROW WS-OK
     END-IF
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
*>   the feature size
     MOVE 1 TO TR-SZ-LIMIT(WS-ROW)
     MOVE 0 TO TR-SZ-LOWER(WS-ROW)
     MOVE 1 TO TR-SZ-UPPER(WS-ROW)
     MOVE 1 TO TR-SZ-UPLIM(WS-ROW)
     MOVE 1 TO TR-SZ-MID(WS-ROW)
     MOVE 0 TO TR-SZ-KIND(WS-ROW)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-MINIMUM-SIZE WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:two_layers_feature_size"
             MOVE 0 TO TR-SZ-KIND(WS-ROW)
         WHEN "minecraft:three_layers_feature_size"
             MOVE 1 TO TR-SZ-KIND(WS-ROW)
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-LIMIT WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-LIMIT(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-LOWER WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-LOWER(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-UPPER WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-UPPER(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-UPLIM WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-UPLIM(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-MIDDLE WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-SZ-MID(WS-ROW) WS-OK
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-CLIPPED WS-N
     IF WS-N > 0
         CALL "FD-J-INT" USING JSON-DOC WS-N TR-MINCLIP(WS-ROW) WS-OK
     END-IF
*>   the foliage placer
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-FOLIAGE-PLACER WS-E
     CALL "FD-J-STRING" USING JSON-DOC FK-TYPE WS-E WS-TEXT WS-LEN
     MOVE FK-HEIGHT TO WS-HKEY
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:blob_foliage_placer"
             MOVE 1 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:spruce_foliage_placer"
             MOVE 2 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:pine_foliage_placer"
             MOVE 3 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:acacia_foliage_placer"
             MOVE 4 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:fancy_foliage_placer"
             MOVE 5 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:jungle_foliage_placer"
             MOVE 6 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:mega_pine_foliage_placer"
             MOVE 7 TO TR-FKIND(WS-ROW)
             MOVE WS-K-CROWN TO WS-HKEY
         WHEN "minecraft:dark_oak_foliage_placer"
             MOVE 8 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:bush_foliage_placer"
             MOVE 9 TO TR-FKIND(WS-ROW)
         WHEN "minecraft:random_spread_foliage_placer"
             MOVE 10 TO TR-FKIND(WS-ROW)
             MOVE WS-K-FOLIAGE-HEIGHT TO WS-HKEY
             CALL "FD-J-MEMBER" USING JSON-DOC WS-E WS-K-ATTEMPTS WS-N
             CALL "FD-J-INT" USING JSON-DOC WS-N TR-ATTEMPTS(WS-ROW) WS-OK
         WHEN "minecraft:cherry_foliage_placer"
             MOVE 11 TO TR-FKIND(WS-ROW)
             CALL "FD-TREE-CHERRYF-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN "minecraft:poplar_foliage_placer"
             MOVE 12 TO TR-FKIND(WS-ROW)
             CALL "FD-TREE-POPLARF-NODE" USING JSON-DOC WS-E WS-ROW
         WHEN OTHER
             MOVE 1 TO FD-BAD
     END-EVALUATE
     MOVE 0 TO WS-N
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-HKEY TR-FH(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-RADIUS TR-RAD(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-OFFSET TR-OFF(WS-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC WS-E WS-K-TRUNK-HEIGHT TR-TH(WS-ROW)
*>   the block tags
     COMPUTE TR-REPL-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-REPL TR-REPL-N(WS-ROW)
     COMPUTE TR-LOGS-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-LOGS TR-LOGS-N(WS-ROW)
     COMPUTE TR-CANT-START(WS-ROW) = FD-POOL-COUNT + 1
     CALL "FD-TAG-BLOCKS" USING WS-TAG-CANT TR-CANT-N(WS-ROW)
*>   the leaves tag is only needed by the dark oak trunk (isAirOrLeaves, 4.5)
     IF TR-TKIND(WS-ROW) = 3
         COMPUTE TR-LVS-START(WS-ROW) = FD-POOL-COUNT + 1
         CALL "FD-TAG-BLOCKS" USING WS-TAG-LVS TR-LVS-N(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM FD-TREE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-OK.
*> USING pool start, pool count, state, ok out: the state at a position is air (class 1) or a block of the pool (a tag): validTreePos / isFree (section 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASS               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-N L-STATE L-OK.
     MOVE 0 TO L-OK
     CALL "FL-CLASS" USING L-STATE WS-CLASS
     IF WS-CLASS = 1
         MOVE 1 TO L-OK
     ELSE
         CALL "FL-BLOCK-OF" USING L-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING L-START L-N WS-BLOCK L-OK
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-CELL.
*> USING x, y, z (absolute), cell out: the grid index of TREEWORK.cpy, 0 when the position is outside the grid (which marks the tree as not fitting).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CELL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-CELL.
     COMPUTE WS-GX = L-X - TW-X0 + TW-OX
     COMPUTE WS-GY = L-Y - TW-Y0 + TW-OY
     COMPUTE WS-GZ = L-Z - TW-Z0 + TW-OX
     MOVE 0 TO L-CELL
     IF WS-GX >= 1 AND WS-GX < TW-GX - 1 AND WS-GY >= 1 AND WS-GY < TW-GY - 1 AND WS-GZ >= 1 AND WS-GZ < TW-GZ - 1
         COMPUTE L-CELL = (WS-GX * TW-GY + WS-GY) * TW-GZ + WS-GZ + 1
     ELSE
         MOVE 1 TO TW-OUT
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-LEAF.
*> USING x, y, z (absolute), state (the random source): tryPlaceLeaf (section 5.1): not on a log of this tree, and the position is valid tree space in the level; the leaf is recorded once.
*> With a weighted foliage provider every valid attempt draws the provider (nextInt(total weight), then the entry whose running weight exceeds it): a cell hit again holds a leaf, which is
*> replaceable, so it draws again and the last draw gives its state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 COPY CELLS.
 COPY FEATDATA.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "FR-TREE-CELL" USING L-X L-Y L-Z WS-CELL
     IF WS-CELL > 0
         MOVE 0 TO WS-OK
         IF TW-GRID(WS-CELL) = 0
             CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
             CALL "FR-TREE-OK" USING TW-REPL-START TW-REPL-N WS-STATE WS-OK
             IF WS-OK = 1
                 ADD 1 TO TW-NLEAF
                 MOVE L-X TO TW-LEAF-X(TW-NLEAF)
                 MOVE L-Y TO TW-LEAF-Y(TW-NLEAF)
                 MOVE L-Z TO TW-LEAF-Z(TW-NLEAF)
                 MOVE TW-LEAF-STATE0 TO TW-LEAF-S(TW-NLEAF)
                 MOVE TW-NLEAF TO TW-LEAFAT(WS-CELL)
                 MOVE 2 TO TW-GRID(WS-CELL)
                 MOVE TW-NLEAF TO WS-IDX
             END-IF
         ELSE
             IF TW-GRID(WS-CELL) = 2
                 MOVE 1 TO WS-OK
                 MOVE TW-LEAFAT(WS-CELL) TO WS-IDX
             END-IF
         END-IF
         IF WS-OK = 1 AND TW-LP-N > 0
             CALL "FR-NEXT-INT" USING L-STATE TW-LP-TOTAL WS-DRAW
             MOVE 0 TO WS-SUM WS-PICK
             PERFORM VARYING WS-E FROM 0 BY 1 UNTIL WS-E >= TW-LP-N OR WS-PICK = 1
                 COMPUTE WS-STATE = TW-LP-START + WS-E * 2
                 ADD FD-POOL(WS-STATE + 1) TO WS-SUM
                 IF WS-DRAW < WS-SUM
                     MOVE FD-POOL(WS-STATE) TO TW-LEAF-S(WS-IDX)
                     MOVE 1 TO WS-PICK
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-LEAF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-COMMIT.
*> USING feature row: gives every leaf its distance (section 2.4: the breadth first distance from the logs through the leaves, 7 for a leaf no log reaches within 6) and writes the soil
*> cells, the logs (the axis of a log with three states) and the leaves to the level.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-STRIDE              BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-LOG-BLOCK           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-HEAD WS-TAIL
     MOVE ALL "7" TO TW-DISTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         CALL "FR-TREE-CELL" USING TW-LOG-X(WS-I) TW-LOG-Y(WS-I) TW-LOG-Z(WS-I) WS-CELL
         MOVE 0 TO TW-DIST(WS-CELL)
         ADD 1 TO WS-TAIL
         MOVE WS-CELL TO TW-QUEUE(WS-TAIL)
     END-PERFORM
*>   the stride of the distance property in the state numbering of the leaves (distance, persistent, waterlogged: 28 states = 7 x 4)
     MOVE TR-LEAF-BLOCK(L-ROW) TO WS-I
     COMPUTE WS-REST = FUNCTION MOD(CB-STATES(WS-I), 7)
     MOVE 0 TO WS-STRIDE
     IF CB-STATES(WS-I) > 0 AND WS-REST = 0
         COMPUTE WS-STRIDE = CB-STATES(WS-I) / 7
     END-IF
     PERFORM UNTIL WS-HEAD >= WS-TAIL
         ADD 1 TO WS-HEAD
         MOVE TW-QUEUE(WS-HEAD) TO WS-CELL
         COMPUTE WS-D = TW-DIST(WS-CELL) + 1
         IF WS-D < 7
*>           the six neighbours: x +-1 (cells GY * GZ apart), y +-1 (GZ apart), z +-1
             PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 6
                 EVALUATE WS-DIR
                     WHEN 1
                         COMPUTE WS-NB = WS-CELL - TW-GY * TW-GZ
                     WHEN 2
                         COMPUTE WS-NB = WS-CELL + TW-GY * TW-GZ
                     WHEN 3
                         COMPUTE WS-NB = WS-CELL - TW-GZ
                     WHEN 4
                         COMPUTE WS-NB = WS-CELL + TW-GZ
                     WHEN 5
                         COMPUTE WS-NB = WS-CELL - 1
                     WHEN 6
                         COMPUTE WS-NB = WS-CELL + 1
                 END-EVALUATE
                 IF TW-GRID(WS-NB) = 2 AND TW-DIST(WS-NB) > WS-D
                     MOVE WS-D TO TW-DIST(WS-NB)
                     ADD 1 TO WS-TAIL
                     MOVE WS-NB TO TW-QUEUE(WS-TAIL)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NSOIL
         MOVE TR-SOIL-STATE(L-ROW) TO WS-STATE
         CALL "FL-SET-STATE" USING TW-SOIL-X(WS-I) TW-SOIL-Y(WS-I) TW-SOIL-Z(WS-I) WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     CALL "FL-BLOCK-OF" USING TR-LOG-STATE(L-ROW) WS-LOG-BLOCK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLOG
         MOVE TR-LOG-STATE(L-ROW) TO WS-STATE
*>       the axis of a limb log: x is the state before the default (axis y), z the one after it
         IF CB-STATES(WS-LOG-BLOCK) = 3
             COMPUTE WS-STATE = TR-LOG-STATE(L-ROW) + TW-LOG-A(WS-I)
         END-IF
         CALL "FL-SET-STATE" USING TW-LOG-X(WS-I) TW-LOG-Y(WS-I) TW-LOG-Z(WS-I) WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NLEAF
         CALL "FR-TREE-CELL" USING TW-LEAF-X(WS-I) TW-LEAF-Y(WS-I) TW-LEAF-Z(WS-I) WS-CELL
         MOVE TW-LEAF-S(WS-I) TO WS-STATE
         IF WS-STRIDE > 0
             COMPUTE WS-STEP = 7 - TW-DIST(WS-CELL)
             COMPUTE WS-STATE = TW-LEAF-S(WS-I) - WS-STEP * WS-STRIDE
         END-IF
*>       a leaf the crown replaced by a log (poplar, 5.5) is no leaf any more
         IF TW-GRID(WS-CELL) = 2
             CALL "FL-SET-STATE" USING TW-LEAF-X(WS-I) TW-LEAF-Y(WS-I) TW-LEAF-Z(WS-I) WS-STATE WS-FLAGS WS-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TREE-COMMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-SIZE.
*> USING feature row, tree height, layer y, size out: getSizeAtHeight (section 3): two layers lower_size below limit else upper_size; three layers lower_size below limit, else upper_size from
*> H - upper_limit, else middle_size.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-FROM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-H L-Y L-S.
     MOVE TR-SZ-UPPER(L-ROW) TO L-S
     COMPUTE WS-FROM = L-H - TR-SZ-UPLIM(L-ROW)
     EVALUATE TRUE
         WHEN L-Y < TR-SZ-LIMIT(L-ROW)
             MOVE TR-SZ-LOWER(L-ROW) TO L-S
         WHEN TR-SZ-KIND(L-ROW) = 1 AND L-Y < WS-FROM
             MOVE TR-SZ-MID(L-ROW) TO L-S
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-TREE-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE.
*> USING state, feature, x, y, z (the origin: the block above the ground), result out (1 placed, 0 refused): TreeFeature.place (section 2). The draws are those of 2.2 in their order (tree
*> height, foliage height, radius, the trunk's, the foliage offset and rows of each attachment), made whether or not the tree is then refused.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY TREEWORK.
 01 WS-ROW                 BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FH                  BINARY-LONG.
 01 WS-LR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.

 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-OY                  BINARY-LONG.
 01 WS-OFFY                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
*>   2.2 steps 1 to 3: the heights and the radius
     CALL "F353-TREE-HEIGHT" USING L-STATE TR-BASE(WS-ROW) TR-RA(WS-ROW) TR-RB(WS-ROW) WS-H
     EVALUATE TR-FKIND(WS-ROW)
         WHEN 2
             CALL "FR-INT-SAMPLE" USING L-STATE TR-TH(WS-ROW) WS-T
             COMPUTE WS-FH = FUNCTION MAX(4, WS-H - WS-T)
         WHEN 4
             MOVE 0 TO WS-FH
         WHEN 8
             MOVE 4 TO WS-FH
         WHEN OTHER
             CALL "FR-INT-SAMPLE" USING L-STATE TR-FH(WS-ROW) WS-FH
     END-EVALUATE
     CALL "FR-INT-SAMPLE" USING L-STATE TR-RAD(WS-ROW) WS-LR
     IF TR-FKIND(WS-ROW) = 3
         COMPUTE WS-BOUND = FUNCTION MAX(WS-H - WS-FH + 1, 1)
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         ADD WS-DRAW TO WS-LR
     END-IF
*>   step 4: the root origin (a root placer draws trunk_offset_y)
     MOVE 0 TO WS-OFFY
     IF TR-ROOT(WS-ROW) = 1
         CALL "FR-INT-SAMPLE" USING L-STATE TR-TOY(WS-ROW) WS-OFFY
     END-IF
     COMPUTE WS-OY = L-Y + WS-OFFY
*>   step 5: the build height
     COMPUTE WS-MINY = FUNCTION MIN(L-Y, WS-OY)
     COMPUTE WS-MAXY = FUNCTION MAX(L-Y, WS-OY) + WS-H + 1
     IF WS-MINY < FL-MIN-Y + 1 OR WS-MAXY > FL-MIN-Y + FL-HEIGHT
         GOBACK
     END-IF
*>   2.3: the free height
     MOVE WS-H TO WS-FREE
     COMPUTE WS-END = WS-H + 1
     PERFORM VARYING WS-YY FROM 0 BY 1 UNTIL WS-YY > WS-END OR WS-FREE < WS-H
         CALL "FR-TREE-SIZE" USING WS-ROW WS-H WS-YY WS-S
         COMPUTE WS-LO = 0 - WS-S
         PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-S OR WS-FREE < WS-H
             PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-S OR WS-FREE < WS-H
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PY = WS-OY + WS-YY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
                 CALL "FR-TREE-OK" USING TR-REPL-START(WS-ROW) TR-REPL-N(WS-ROW) WS-STATE WS-OK
                 IF WS-OK = 0
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     CALL "FR-POOL-HAS" USING TR-LOGS-START(WS-ROW) TR-LOGS-N(WS-ROW) WS-BLOCK WS-OK
                 END-IF
                 IF WS-OK = 0 AND TR-CGT-N(WS-ROW) > 0
                     CALL "FR-POOL-HAS" USING TR-CGT-START(WS-ROW) TR-CGT-N(WS-ROW) WS-BLOCK WS-OK
                 END-IF
                 IF WS-OK = 0
                     COMPUTE WS-FREE = WS-YY - 2
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-FREE < WS-H
         IF TR-MINCLIP(WS-ROW) < 0 OR WS-FREE < TR-MINCLIP(WS-ROW)
             GOBACK
         END-IF
     END-IF
*>   step 7: the roots come before the trunk (the root list is empty for a tree without a root placer: the decorators read it)
     MOVE 0 TO TW-NRL
     IF TR-ROOT(WS-ROW) = 1
         CALL "FR-ROOTS" USING L-STATE WS-ROW L-X L-Y L-Z WS-OY WS-OK
         IF WS-OK = 0
             GOBACK
         END-IF
     END-IF
*>   the work area
     MOVE L-X TO TW-X0
     MOVE WS-OY TO TW-Y0
     MOVE L-Z TO TW-Z0
     MOVE 0 TO TW-OUT TW-NLOG TW-NLEAF TW-NATT TW-NSOIL TW-NFC
     MOVE TR-REPL-START(WS-ROW) TO TW-REPL-START
     MOVE TR-REPL-N(WS-ROW) TO TW-REPL-N
     MOVE TR-LOGS-START(WS-ROW) TO TW-LOGS-START
     MOVE TR-LOGS-N(WS-ROW) TO TW-LOGS-N
     MOVE TR-LVS-START(WS-ROW) TO TW-LVS-START
     MOVE TR-LVS-N(WS-ROW) TO TW-LVS-N
     MOVE TR-CGT-START(WS-ROW) TO TW-CGT-START
     MOVE TR-CGT-N(WS-ROW) TO TW-CGT-N
     MOVE TR-LEAF-STATE(WS-ROW) TO TW-LEAF-STATE0
     MOVE TR-LP-START(WS-ROW) TO TW-LP-START
     MOVE TR-LP-N(WS-ROW) TO TW-LP-N
     MOVE TR-LP-TOTAL(WS-ROW) TO TW-LP-TOTAL
     MOVE ALL "0" TO TW-GRIDS
*>   2.2 step 8 and section 4: the soil, the logs and the attachments; step 9 and section 5: the foliage of each attachment in list order
     CALL "FR-TRUNK" USING L-STATE WS-ROW L-X WS-OY L-Z WS-FREE
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > TW-NATT
         CALL "FR-FOLIAGE" USING L-STATE WS-ROW WS-A WS-FH WS-LR
     END-PERFORM
     IF TW-OUT = 1
         GOBACK
     END-IF
*>   the level writes one chunk: the trunk stands in it (the origin is in the chunk) and the leaves outside are refused by FL-SET-STATE and kept in the overflow list (gen-overflow.cob)
     CALL "FR-TREE-COMMIT" USING WS-ROW
     IF TR-NDEC(WS-ROW) > 0
         MOVE 1 TO WS-A
         CALL "FR-DECORATE" USING L-STATE WS-ROW WS-A TR-NDEC(WS-ROW)
     END-IF
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-TREE.
