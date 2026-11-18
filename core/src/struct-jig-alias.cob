*> Pool aliases of the jigsaw structures (docs/protocol/36-structures-3-jigsaw-assembly.md sections 3.4, 7 and 8.2 step 4; tables SD-AL-* of STRUCTDATA.cpy, the map JM-* of STRUCTJIG.cpy).
*> A binding is a tree node (direct, random, random_group); a start resolves the bindings in list order into one alias map with the positional random of the world seed at the start position,
*> and the assembler looks every pool key of a jigsaw (and the start pool) up in that map in one step.
*>
*> Entry points:
*>   JIG-ALIAS-PARSE USING JSON-DOC, binding object node, slot, ok out: one binding into the row SD-AL-NODE(slot) (recursive for the groups of a random_group)
*>   JIG-ALIAS-READ USING JSON-DOC (a structure file), structure row, ok out: pool_aliases into SDT-JIG-AL-FIRST and SDT-JIG-AL-N (ok 0: a malformed binding or a full table)
*>   JIG-ALIAS-ADD USING alias, target (PIC X(80)): one pair into the map; a repeated alias sets JM-DUP
*>   JIG-ALIAS-RUN USING node row, random state (BINARY-DOUBLE UNSIGNED): forEachResolved (7.1)
*>   JIG-ALIAS-BUILD USING structure row, world seed (BINARY-DOUBLE), x, y, z: PoolAliasLookup.create (7.2); an empty binding list leaves an empty map
*>   JIG-ALIAS-LOOKUP USING key, key out (PIC X(80)): the map's value for the key or the key itself (7.2 step 4)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-PARSE RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 K-TYPE                 PIC X(40) VALUE "type".
 01 K-ALIAS                PIC X(40) VALUE "alias".
 01 K-TARGET               PIC X(40) VALUE "target".
 01 K-TARGETS              PIC X(40) VALUE "targets".
 01 K-DATA                 PIC X(40) VALUE "data".
 01 K-WEIGHT               PIC X(40) VALUE "weight".
 01 K-GROUPS               PIC X(40) VALUE "groups".
 LOCAL-STORAGE SECTION.
 01 LS-KIND                BINARY-LONG.
 01 LS-ARRAY               BINARY-LONG.
 01 LS-ITEM                BINARY-LONG.
 01 LS-DATA                BINARY-LONG.
 01 LS-ELEM                BINARY-LONG.
 01 LS-WNODE               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-J                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-M                   BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-WEIGHT              BINARY-LONG.
 01 LS-INT-OK              BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-CHILD-OK            BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-SLOT L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO LS-KIND
     CALL "FD-J-STRING" USING JSON-DOC K-TYPE L-NODE WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:direct"
             MOVE 1 TO LS-KIND
         WHEN "minecraft:random"
             MOVE 2 TO LS-KIND
         WHEN "minecraft:random_group"
             MOVE 3 TO LS-KIND
     END-EVALUATE
     IF LS-KIND = 0
         MOVE 0 TO L-OK
         GOBACK
     END-IF
     MOVE LS-KIND TO AN-TYPE(L-SLOT)
     MOVE SPACES TO AN-ALIAS(L-SLOT) AN-TARGET(L-SLOT)
     MOVE 0 TO AN-FIRST(L-SLOT) AN-COUNT(L-SLOT) AN-TOTAL(L-SLOT)
     IF LS-KIND NOT = 3
         CALL "FD-J-STRING" USING JSON-DOC K-ALIAS L-NODE WS-TEXT WS-LEN
         CALL "FD-KEY" USING WS-TEXT AN-ALIAS(L-SLOT)
         IF WS-LEN = 0
             MOVE 0 TO L-OK
             GOBACK
         END-IF
     END-IF
     IF LS-KIND = 1
         CALL "FD-J-STRING" USING JSON-DOC K-TARGET L-NODE WS-TEXT WS-LEN
         CALL "FD-KEY" USING WS-TEXT AN-TARGET(L-SLOT)
         IF WS-LEN = 0
             MOVE 0 TO L-OK
         END-IF
         GOBACK
     END-IF
*>   random: the weighted targets; random_group: the weighted groups (each a list of bindings)
     IF LS-KIND = 2
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-TARGETS LS-ARRAY
     ELSE
         CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-GROUPS LS-ARRAY
     END-IF
     MOVE 0 TO LS-N
     IF LS-ARRAY > 0
         MOVE JN-COUNT(LS-ARRAY) TO LS-N
     END-IF
     IF LS-N = 0 OR SD-AL-ECOUNT + LS-N > 192
         MOVE 0 TO L-OK
         GOBACK
     END-IF
     COMPUTE AN-FIRST(L-SLOT) = SD-AL-ECOUNT + 1
     MOVE LS-N TO AN-COUNT(L-SLOT)
     ADD LS-N TO SD-AL-ECOUNT
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= LS-N
         COMPUTE LS-E = AN-FIRST(L-SLOT) + LS-I
         CALL "JSON-ELEMENT" USING JSON-DOC LS-ARRAY LS-I LS-ITEM
         CALL "FD-J-MEMBER" USING JSON-DOC LS-ITEM K-WEIGHT LS-WNODE
         CALL "FD-J-INT" USING JSON-DOC LS-WNODE LS-WEIGHT LS-INT-OK
         IF LS-INT-OK = 0 OR LS-WEIGHT < 1
             MOVE 0 TO L-OK
             GOBACK
         END-IF
         MOVE LS-WEIGHT TO AE-WEIGHT(LS-E)
         ADD LS-WEIGHT TO AN-TOTAL(L-SLOT)
         MOVE SPACES TO AE-KEY(LS-E)
         MOVE 0 TO AE-CHILD-FIRST(LS-E) AE-CHILD-N(LS-E)
         IF LS-KIND = 2
             CALL "FD-J-STRING" USING JSON-DOC K-DATA LS-ITEM WS-TEXT WS-LEN
             CALL "FD-KEY" USING WS-TEXT AE-KEY(LS-E)
         ELSE
             CALL "FD-J-MEMBER" USING JSON-DOC LS-ITEM K-DATA LS-DATA
             MOVE 0 TO LS-M
             IF LS-DATA > 0
                 MOVE JN-COUNT(LS-DATA) TO LS-M
             END-IF
             IF SD-AL-COUNT + LS-M > 96
                 MOVE 0 TO L-OK
                 GOBACK
             END-IF
             COMPUTE AE-CHILD-FIRST(LS-E) = SD-AL-COUNT + 1
             MOVE LS-M TO AE-CHILD-N(LS-E)
             ADD LS-M TO SD-AL-COUNT
             PERFORM VARYING LS-J FROM 0 BY 1 UNTIL LS-J >= LS-M
                 COMPUTE LS-CHILD = AE-CHILD-FIRST(LS-E) + LS-J
                 CALL "JSON-ELEMENT" USING JSON-DOC LS-DATA LS-J LS-ELEM
                 CALL "JIG-ALIAS-PARSE" USING JSON-DOC LS-ELEM LS-CHILD LS-CHILD-OK
                 IF LS-CHILD-OK = 0
                     MOVE 0 TO L-OK
                     GOBACK
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 K-ALIASES              PIC X(40) VALUE "pool_aliases".
 01 WS-ARRAY               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BIND-OK             BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO SDT-JIG-AL-FIRST(L-ROW) SDT-JIG-AL-N(L-ROW) WS-N
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-ALIASES WS-ARRAY
     IF WS-ARRAY > 0
         MOVE JN-COUNT(WS-ARRAY) TO WS-N
     END-IF
     IF WS-N = 0
         GOBACK
     END-IF
     IF SD-AL-COUNT + WS-N > 96
         MOVE 0 TO L-OK
         GOBACK
     END-IF
     COMPUTE SDT-JIG-AL-FIRST(L-ROW) = SD-AL-COUNT + 1
     MOVE WS-N TO SDT-JIG-AL-N(L-ROW)
     ADD WS-N TO SD-AL-COUNT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-SLOT = SDT-JIG-AL-FIRST(L-ROW) + WS-I
         CALL "JSON-ELEMENT" USING JSON-DOC WS-ARRAY WS-I WS-ITEM
         CALL "JIG-ALIAS-PARSE" USING JSON-DOC WS-ITEM WS-SLOT WS-BIND-OK
         IF WS-BIND-OK = 0
             MOVE 0 TO L-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ALIAS                PIC X(80).
 01 L-TARGET               PIC X(80).
 PROCEDURE DIVISION USING L-ALIAS L-TARGET.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JM-COUNT
         IF JM-ALIAS(WS-I) = L-ALIAS
             MOVE 1 TO JM-DUP
         END-IF
     END-PERFORM
     IF JM-COUNT >= JM-MAX
         MOVE 1 TO JM-DUP
     END-IF
     IF JM-DUP = 0
         ADD 1 TO JM-COUNT
         MOVE L-ALIAS TO JM-ALIAS(JM-COUNT)
         MOVE L-TARGET TO JM-TARGET(JM-COUNT)
     END-IF
     GOBACK.
 END PROGRAM JIG-ALIAS-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-RUN RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 LOCAL-STORAGE SECTION.
 01 LS-NODE                BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-PICK                BINARY-LONG.
 01 LS-TOTAL               BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-NODE L-STATE.
     MOVE L-NODE TO LS-NODE
     IF AN-TYPE(LS-NODE) = 1
         CALL "JIG-ALIAS-ADD" USING AN-ALIAS(LS-NODE) AN-TARGET(LS-NODE)
         GOBACK
     END-IF
*>   the weighted pick: nextInt(total), then the first entry whose weight exceeds what is left
     MOVE AN-TOTAL(LS-NODE) TO LS-TOTAL
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE LS-TOTAL LS-DRAW
     MOVE 0 TO LS-PICK
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= AN-COUNT(LS-NODE) OR LS-PICK > 0
         COMPUTE LS-E = AN-FIRST(LS-NODE) + LS-I
         IF LS-DRAW < AE-WEIGHT(LS-E)
             MOVE LS-E TO LS-PICK
         ELSE
             SUBTRACT AE-WEIGHT(LS-E) FROM LS-DRAW
         END-IF
     END-PERFORM
     IF AN-TYPE(LS-NODE) = 2
         CALL "JIG-ALIAS-ADD" USING AN-ALIAS(LS-NODE) AE-KEY(LS-PICK)
         GOBACK
     END-IF
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= AE-CHILD-N(LS-PICK)
         COMPUTE LS-CHILD = AE-CHILD-FIRST(LS-PICK) + LS-I
         CALL "JIG-ALIAS-RUN" USING LS-CHILD L-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTJIG.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-T                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 01 WS-G                   BINARY-DOUBLE.
 01 WS-GU                  BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SEED L-X L-Y L-Z.
     MOVE 0 TO JM-COUNT JM-DUP
     IF SDT-JIG-AL-N(L-ROW) = 0
         GOBACK
     END-IF
*>   positional(seed) of RandomSource.create(seed): the legacy generator's first nextLong is the factory seed; at(pos) is a legacy generator seeded with getSeed(pos) xor it
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-T WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-T WS-S
     CALL "XORO-GET-SEED" USING L-X L-Y L-Z WS-G
     COMPUTE WS-GU = FUNCTION MOD(WS-G + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-S WS-GU BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-STATE WS-GU
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SDT-JIG-AL-N(L-ROW)
         COMPUTE WS-NODE = SDT-JIG-AL-FIRST(L-ROW) + WS-I
         CALL "JIG-ALIAS-RUN" USING WS-NODE WS-STATE
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTJIG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(80).
 01 L-OUT                  PIC X(80).
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE L-KEY TO L-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JM-COUNT
         IF JM-ALIAS(WS-I) = L-KEY
             MOVE JM-TARGET(WS-I) TO L-OUT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-LOOKUP.
