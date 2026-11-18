*> Pool aliases, the start height provider and the start jigsaw name of a jigsaw structure (docs/protocol/36-structures-10-ancient-city-trial-chambers-trail-ruins.md sections 2.1, 2.2 and 2.6; STRUCTALIAS.cpy,
*> STRUCTALIASMAP.cpy). A start asks for its lookup once (JIG-ALIAS-BUILD) with the origin of the start (the chunk's minimum corner at the sampled start height) and the world seed: F = LegacyRandom(seed).nextLong(),
*> the alias generator LegacyRandom(Mth.getSeed(origin) XOR F), each binding resolved in list order drawing from that one generator: direct draws nothing, random one nextInt(total weight) and the first target whose
*> cumulative weight exceeds it, random_group one such draw for the group and then every binding of the chosen group in order. An empty binding list is the identity.
*>
*> Entry points:
*>   STRUCT-ALIAS-RESET: empties the binding and option tables (called by STRUCT-RESET)
*>   STRUCT-ALIAS-READ USING JSON-DOC (the structure's file), structure row, ok out (0 when the start height is a provider this reader does not know): start_jigsaw_name, start_height (absolute, or uniform of two
*>     absolute anchors) and pool_aliases of the structure
*>   STRUCT-MTH-SEED USING x, y, z, seed out (BINARY-DOUBLE): Mth.getSeed(x, y, z)
*>   JIG-ALIAS-BUILD USING structure row, origin x, origin y, origin z, world seed (BINARY-DOUBLE), map out (STRUCTALIASMAP.cpy)
*>   JIG-ALIAS-LOOKUP USING map, key (PIC X(80)), result out (PIC X(80)): the mapped pool key, the key itself when unmapped

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ALIAS-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTALIAS.
 PROCEDURE DIVISION.
     MOVE 0 TO SDA-USED SDA-OPT-USED
     GOBACK.
 END PROGRAM STRUCT-ALIAS-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ALIAS-FILL IS RECURSIVE.
*> USING JSON-DOC, binding node, row (a row of SDA-BIND), ok out: one binding of 2.6 (direct, random or random_group) into the row; options and sub-bindings are allocated from the tables
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTALIAS.
 01 K-TYPE                 PIC X(40) VALUE "type".
 01 K-ALIAS                PIC X(40) VALUE "alias".
 01 K-TARGET               PIC X(40) VALUE "target".
 01 K-TARGETS              PIC X(40) VALUE "targets".
 01 K-GROUPS               PIC X(40) VALUE "groups".
 01 K-DATA                 PIC X(40) VALUE "data".
 01 K-WEIGHT               PIC X(40) VALUE "weight".
 LOCAL-STORAGE SECTION.
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NODE                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ELEM                BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-OPT                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-OK-SUB              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-OK.
     MOVE 1 TO L-OK
     MOVE 0 TO SDB-KIND(L-ROW) SDB-OPT-FIRST(L-ROW) SDB-OPT-N(L-ROW)
     MOVE SPACES TO SDB-ALIAS(L-ROW) SDB-TARGET(L-ROW)
     CALL "FD-J-STRING" USING JSON-DOC K-ALIAS L-NODE WS-TEXT WS-LEN
     CALL "FD-KEY" USING WS-TEXT WS-KEY
     MOVE WS-KEY TO SDB-ALIAS(L-ROW)
     CALL "FD-J-STRING" USING JSON-DOC K-TYPE L-NODE WS-TEXT WS-LEN
     EVALUATE FUNCTION TRIM(WS-TEXT)
         WHEN "minecraft:direct"
             MOVE 1 TO SDB-KIND(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-TARGET WS-NODE
             CALL "FD-J-STRING-OF" USING JSON-DOC WS-NODE WS-TEXT
             CALL "FD-KEY" USING WS-TEXT WS-KEY
             MOVE WS-KEY TO SDB-TARGET(L-ROW)
         WHEN "minecraft:random"
             MOVE 2 TO SDB-KIND(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-TARGETS WS-LIST
             MOVE 0 TO WS-N
             IF WS-LIST > 0
                 MOVE JN-COUNT(WS-LIST) TO WS-N
             END-IF
             IF WS-N = 0 OR SDA-OPT-USED + WS-N > SDA-MAX-OPTS
                 MOVE 0 TO L-OK
                 GOBACK
             END-IF
             COMPUTE SDB-OPT-FIRST(L-ROW) = SDA-OPT-USED + 1
             MOVE WS-N TO SDB-OPT-N(L-ROW)
             ADD WS-N TO SDA-OPT-USED
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
                 CALL "JSON-ELEMENT" USING JSON-DOC WS-LIST WS-I WS-ELEM
                 COMPUTE WS-OPT = SDB-OPT-FIRST(L-ROW) + WS-I
                 CALL "FD-J-MEMBER" USING JSON-DOC WS-ELEM K-DATA WS-DATA
                 CALL "FD-J-STRING-OF" USING JSON-DOC WS-DATA WS-TEXT
                 CALL "FD-KEY" USING WS-TEXT WS-KEY
                 MOVE WS-KEY TO SDO-TARGET(WS-OPT)
                 CALL "FD-J-MEMBER" USING JSON-DOC WS-ELEM K-WEIGHT WS-DATA
                 CALL "FD-J-INT" USING JSON-DOC WS-DATA SDO-WEIGHT(WS-OPT) WS-OK-SUB
                 MOVE 0 TO SDO-SUB-FIRST(WS-OPT) SDO-SUB-N(WS-OPT)
             END-PERFORM
         WHEN "minecraft:random_group"
             MOVE 3 TO SDB-KIND(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC L-NODE K-GROUPS WS-LIST
             MOVE 0 TO WS-N
             IF WS-LIST > 0
                 MOVE JN-COUNT(WS-LIST) TO WS-N
             END-IF
             IF WS-N = 0 OR SDA-OPT-USED + WS-N > SDA-MAX-OPTS
                 MOVE 0 TO L-OK
                 GOBACK
             END-IF
             COMPUTE SDB-OPT-FIRST(L-ROW) = SDA-OPT-USED + 1
             MOVE WS-N TO SDB-OPT-N(L-ROW)
             ADD WS-N TO SDA-OPT-USED
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
                 CALL "JSON-ELEMENT" USING JSON-DOC WS-LIST WS-I WS-ELEM
                 COMPUTE WS-OPT = SDB-OPT-FIRST(L-ROW) + WS-I
                 MOVE SPACES TO SDO-TARGET(WS-OPT)
                 CALL "FD-J-MEMBER" USING JSON-DOC WS-ELEM K-WEIGHT WS-DATA
                 CALL "FD-J-INT" USING JSON-DOC WS-DATA SDO-WEIGHT(WS-OPT) WS-OK-SUB
                 CALL "FD-J-MEMBER" USING JSON-DOC WS-ELEM K-DATA WS-DATA
                 MOVE 0 TO WS-M
                 IF WS-DATA > 0
                     MOVE JN-COUNT(WS-DATA) TO WS-M
                 END-IF
                 IF SDA-USED + WS-M > SDA-MAX-BINDS
                     MOVE 0 TO L-OK
                     GOBACK
                 END-IF
                 COMPUTE SDO-SUB-FIRST(WS-OPT) = SDA-USED + 1
                 MOVE WS-M TO SDO-SUB-N(WS-OPT)
                 ADD WS-M TO SDA-USED
                 PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-M
                     CALL "JSON-ELEMENT" USING JSON-DOC WS-DATA WS-J WS-SUB
                     COMPUTE WS-ROW = SDO-SUB-FIRST(WS-OPT) + WS-J
                     CALL "STRUCT-ALIAS-FILL" USING JSON-DOC WS-SUB WS-ROW WS-OK-SUB
                     IF WS-OK-SUB = 0
                         MOVE 0 TO L-OK
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN OTHER
             MOVE 0 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-ALIAS-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ALIAS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTALIAS.
 01 K-START-NAME           PIC X(40) VALUE "start_jigsaw_name".
 01 K-HEIGHT               PIC X(40) VALUE "start_height".
 01 K-TYPE                 PIC X(40) VALUE "type".
 01 K-MIN                  PIC X(40) VALUE "min_inclusive".
 01 K-MAX                  PIC X(40) VALUE "max_inclusive".
 01 K-ABSOLUTE             PIC X(40) VALUE "absolute".
 01 K-ALIASES              PIC X(40) VALUE "pool_aliases".
 01 WS-TEXT                PIC X(120).
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NODE                BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-ELEM                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-OK-ALL              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-OK.
     MOVE 1 TO L-OK
     MOVE SPACES TO SDA-START(L-ROW)
     MOVE 0 TO SDA-Y-KIND(L-ROW) SDA-Y-MIN(L-ROW) SDA-Y-MAX(L-ROW) SDA-AL-N(L-ROW)
     MOVE 1 TO SDA-AL-FIRST(L-ROW)
     CALL "FD-J-STRING" USING JSON-DOC K-START-NAME 1 WS-TEXT WS-LEN
     IF WS-TEXT NOT = SPACES
         CALL "FD-KEY" USING WS-TEXT WS-KEY
         MOVE WS-KEY TO SDA-START(L-ROW)
     END-IF
*>   start_height: {absolute: n} is the constant; {type: uniform, min_inclusive: {absolute}, max_inclusive: {absolute}} is one draw (the reader of STRUCT-JIG-READ keeps the absolute one)
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-HEIGHT WS-NODE
     IF WS-NODE > 0
         CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-MIN WS-INNER
         IF WS-INNER > 0
             MOVE 1 TO SDA-Y-KIND(L-ROW)
             CALL "FD-J-MEMBER" USING JSON-DOC WS-INNER K-ABSOLUTE WS-ELEM
             CALL "FD-J-INT" USING JSON-DOC WS-ELEM SDA-Y-MIN(L-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
             CALL "FD-J-MEMBER" USING JSON-DOC WS-NODE K-MAX WS-INNER
             CALL "FD-J-MEMBER" USING JSON-DOC WS-INNER K-ABSOLUTE WS-ELEM
             CALL "FD-J-INT" USING JSON-DOC WS-ELEM SDA-Y-MAX(L-ROW) WS-OK
             IF WS-OK = 0
                 MOVE 0 TO L-OK
             END-IF
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC 1 K-ALIASES WS-LIST
     MOVE 0 TO WS-N
     IF WS-LIST > 0
         MOVE JN-COUNT(WS-LIST) TO WS-N
     END-IF
     IF WS-N > 0
         IF SDA-USED + WS-N > SDA-MAX-BINDS
             MOVE 0 TO L-OK
             GOBACK
         END-IF
         COMPUTE SDA-AL-FIRST(L-ROW) = SDA-USED + 1
         MOVE WS-N TO SDA-AL-N(L-ROW)
         ADD WS-N TO SDA-USED
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
             CALL "JSON-ELEMENT" USING JSON-DOC WS-LIST WS-I WS-ELEM
             COMPUTE WS-ROW = SDA-AL-FIRST(L-ROW) + WS-I
             CALL "STRUCT-ALIAS-FILL" USING JSON-DOC WS-ELEM WS-ROW WS-OK-ALL
             IF WS-OK-ALL = 0
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM STRUCT-ALIAS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-MTH-SEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M31                 PIC S9(20) VALUE 2147483648.
 01 WS-M32                 PIC S9(20) VALUE 4294967296.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-XP                  PIC S9(20).
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-C                   BINARY-DOUBLE.
 01 WS-L                   BINARY-DOUBLE.
 01 WS-SQ                  PIC S9(38).
 01 WS-U                   PIC S9(38).
 01 WS-V                   PIC S9(38).
 01 WS-S                   PIC S9(38).
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-SEED.
*>   l = (int)(x * 3129871) ^ (z * 116129781L) ^ y: the first product in 32 bits (sign extended), the second in 64
     COMPUTE WS-XP = FUNCTION MOD(L-X * 3129871 + WS-M31, WS-M32) - WS-M31
     MOVE WS-XP TO WS-A
     COMPUTE WS-B = L-Z * 116129781
     MOVE L-Y TO WS-C
     MOVE WS-A TO WS-L
     CALL "CBL_XOR" USING WS-B WS-L BY VALUE 8
     CALL "CBL_XOR" USING WS-C WS-L BY VALUE 8
*>   (l * l * 42317861L + l * 11L) >> 16, 64-bit wrap
     COMPUTE WS-SQ = WS-L * WS-L
     COMPUTE WS-U = FUNCTION MOD(WS-SQ, WS-M64)
     COMPUTE WS-V = FUNCTION MOD(WS-U * 42317861 + WS-L * 11, WS-M64)
     IF WS-V >= WS-M63
         COMPUTE WS-S = WS-V - WS-M64
     ELSE
         MOVE WS-V TO WS-S
     END-IF
     COMPUTE L-SEED = FUNCTION INTEGER(WS-S / 65536)
     GOBACK.
 END PROGRAM STRUCT-MTH-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-SET.
*> USING map, alias key, target: maps the alias to the target (an earlier binding of the same alias is replaced)
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTALIASMAP.
 01 L-KEY                  PIC X(80).
 01 L-TARGET               PIC X(80).
 PROCEDURE DIVISION USING JIG-ALIAS-MAP L-KEY L-TARGET.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JA-COUNT
         IF JA-KEY(WS-I) = L-KEY
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW = 0 AND JA-COUNT < JA-MAX
         ADD 1 TO JA-COUNT
         MOVE JA-COUNT TO WS-ROW
         MOVE L-KEY TO JA-KEY(WS-ROW)
     END-IF
     IF WS-ROW > 0
         MOVE L-TARGET TO JA-TARGET(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM JIG-ALIAS-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-RESOLVE IS RECURSIVE.
*> USING binding row, generator state (BINARY-DOUBLE UNSIGNED, in and out), map: forEachResolved of 2.6
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTALIAS.
 LOCAL-STORAGE SECTION.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-ACC                 BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 COPY STRUCTALIASMAP.
 PROCEDURE DIVISION USING L-ROW L-STATE JIG-ALIAS-MAP.
     IF SDB-KIND(L-ROW) = 1
         CALL "JIG-ALIAS-SET" USING JIG-ALIAS-MAP SDB-ALIAS(L-ROW) SDB-TARGET(L-ROW)
         GOBACK
     END-IF
     MOVE 0 TO WS-TOTAL
     COMPUTE WS-LAST = SDB-OPT-FIRST(L-ROW) + SDB-OPT-N(L-ROW) - 1
     PERFORM VARYING WS-I FROM SDB-OPT-FIRST(L-ROW) BY 1 UNTIL WS-I > WS-LAST
         ADD SDO-WEIGHT(WS-I) TO WS-TOTAL
     END-PERFORM
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-TOTAL WS-DRAW
     MOVE 0 TO WS-PICK WS-ACC
     PERFORM VARYING WS-I FROM SDB-OPT-FIRST(L-ROW) BY 1 UNTIL WS-I > WS-LAST OR WS-PICK > 0
         ADD SDO-WEIGHT(WS-I) TO WS-ACC
         IF WS-ACC > WS-DRAW
             MOVE WS-I TO WS-PICK
         END-IF
     END-PERFORM
     IF SDB-KIND(L-ROW) = 2
         CALL "JIG-ALIAS-SET" USING JIG-ALIAS-MAP SDB-ALIAS(L-ROW) SDO-TARGET(WS-PICK)
         GOBACK
     END-IF
     COMPUTE WS-LAST = SDO-SUB-FIRST(WS-PICK) + SDO-SUB-N(WS-PICK) - 1
     PERFORM VARYING WS-J FROM SDO-SUB-FIRST(WS-PICK) BY 1 UNTIL WS-J > WS-LAST
         MOVE WS-J TO WS-SUB
         CALL "JIG-ALIAS-RESOLVE" USING WS-SUB L-STATE JIG-ALIAS-MAP
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTALIAS.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-F                   BINARY-DOUBLE UNSIGNED.
 01 WS-G                   BINARY-DOUBLE.
 01 WS-GU                  BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 COPY STRUCTALIASMAP.
 PROCEDURE DIVISION USING L-STRUCT L-X L-Y L-Z L-SEED JIG-ALIAS-MAP.
     MOVE 0 TO JA-COUNT
     IF SDA-AL-N(L-STRUCT) = 0
         GOBACK
     END-IF
*>   F = LegacyRandom(worldSeed).nextLong(), the generator LegacyRandom(Mth.getSeed(origin) XOR F)
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-F
     CALL "STRUCT-MTH-SEED" USING L-X L-Y L-Z WS-G
     COMPUTE WS-GU = FUNCTION MOD(WS-G + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-F WS-GU BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-STATE WS-GU
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SDA-AL-N(L-STRUCT)
         COMPUTE WS-ROW = SDA-AL-FIRST(L-STRUCT) + WS-I
         CALL "JIG-ALIAS-RESOLVE" USING WS-ROW WS-STATE JIG-ALIAS-MAP
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JIG-ALIAS-LOOKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY STRUCTALIASMAP.
 01 L-KEY                  PIC X(80).
 01 L-OUT                  PIC X(80).
 PROCEDURE DIVISION USING JIG-ALIAS-MAP L-KEY L-OUT.
     MOVE L-KEY TO L-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JA-COUNT
         IF JA-KEY(WS-I) = L-KEY
             MOVE JA-TARGET(WS-I) TO L-OUT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM JIG-ALIAS-LOOKUP.
