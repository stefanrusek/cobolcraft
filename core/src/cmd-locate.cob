*> The structure search of /locate structure (docs/protocol/16 section 7.7: the nearest map-style structure from the source's block position, search radius 100 in
*> spacing cells, skip-existing false). The sets of the loaded structure data (struct-data.cob) that hold the structure (or a structure of the tag) and are random_spread are searched
*> in square rings of spacing cells around the source's cell; in each ring the cells' potential chunks (STRUCT-POTENTIAL) that are structure chunks (STRUCT-IS-CHUNK) and hold a start
*> of the wanted structure (STRUCT-CHUNK-STARTS: the gate, the biome check) are candidates, the first candidate in loop order (ix outer, iz inner) is the answer of a set in that ring (36-1 section 11 step 4), and the first ring in which any set answers ends the
*> search for all sets; the nearest answer of that ring wins. Concentric ring sets (strongholds) are searched by the eye of ender's code (STRUCT-NEAREST-RING, 36-1 section 11 step 3); the nearest of the ring chunks counts as a start.
*> The one-time setup the chunk workers do in their own processes (generator seed, climate points, possible structure sets) is run here when the main process has not run it (a world loaded from disk).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-STRUCT-TAG-HAS IS RECURSIVE.
*> USING tag key (PIC X(80), with namespace, no "#"), structure key (PIC X(80)), depth, flag out: 1 when data/<ns>/tags/worldgen/structure/<tag>.json lists the structure, directly or
*> through a "#" tag (read to depth 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY FDCONST.
 LOCAL-STORAGE SECTION.
 COPY JSONDOC.
 01 LS-TEXT                PIC X(65536).
 01 LS-LEN                 BINARY-LONG.
 01 LS-STATUS              BINARY-LONG.
 01 LS-AREA                PIC X(24).
 01 LS-VALUES              BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-E                   BINARY-LONG.
 01 LS-ITEM                PIC X(120).
 01 LS-ITEM-LEN            BINARY-LONG.
 01 LS-TAIL                PIC X(120).
 01 LS-CAP                 BINARY-LONG VALUE 120.
 01 LS-KEY                 PIC X(80).
 01 LS-DEPTH               BINARY-LONG.
 01 LS-VALUES-KEY          PIC X(40) VALUE "values".
 LINKAGE SECTION.
 01 L-TAG                  PIC X(80).
 01 L-STRUCT               PIC X(80).
 01 L-DEPTH                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-STRUCT L-DEPTH L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE "tags/worldgen/structure" TO LS-AREA
     CALL "STRUCT-READ" USING LS-AREA L-TAG LS-TEXT LS-LEN LS-STATUS
     IF LS-STATUS = 0
         CALL "JSON-PARSE" USING JSON-DOC LS-TEXT LS-LEN
         CALL "FD-J-MEMBER" USING JSON-DOC FC-N1 LS-VALUES-KEY LS-VALUES
         MOVE 0 TO LS-N
         IF LS-VALUES > 0
             MOVE JN-COUNT(LS-VALUES) TO LS-N
         END-IF
         COMPUTE LS-DEPTH = L-DEPTH + 1
         PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= LS-N OR L-FLAG = 1
             CALL "JSON-ELEMENT" USING JSON-DOC LS-VALUES LS-I LS-E
             MOVE SPACES TO LS-ITEM
             CALL "JSON-STRING" USING JSON-DOC LS-E LS-ITEM LS-CAP LS-ITEM-LEN
             IF LS-ITEM(1:1) = "#"
                 IF L-DEPTH < 6
                     MOVE LS-ITEM(2:119) TO LS-TAIL
                     CALL "FD-KEY" USING LS-TAIL LS-KEY
                     CALL "CXC-STRUCT-TAG-HAS" USING LS-KEY L-STRUCT LS-DEPTH L-FLAG
                 END-IF
             ELSE
                 IF LS-ITEM-LEN > 0
                     CALL "FD-KEY" USING LS-ITEM LS-KEY
                     IF LS-KEY = L-STRUCT
                         MOVE 1 TO L-FLAG
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CXC-STRUCT-TAG-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-STRUCT-WANT.
*> USING kind (1 a structure, 2 a tag), identifier with namespace (PIC X(80), without "#"), structure row (BINARY-LONG), flag out: 1 when the structure of the row is the one asked for
*> or in the tag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-KEY                 PIC X(80).
 01 WS-DEPTH               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE SDT-KEY(L-ROW) TO WS-KEY
     IF L-KIND = 1
         IF WS-KEY = L-ID
             MOVE 1 TO L-FLAG
         END-IF
     ELSE
         CALL "CXC-STRUCT-TAG-HAS" USING L-ID WS-KEY WS-DEPTH L-FLAG
     END-IF
     GOBACK.
 END PROGRAM CXC-STRUCT-WANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-STRUCT-CELL-HIT.
*> USING set row, kind, identifier, seed (BINARY-DOUBLE), chunk x, chunk z (a structure chunk of the set: STRUCT-IS-CHUNK is true), hit out: 1 when the start the generation makes in the chunk for the set
*> (STRUCT-CHUNK-STARTS-RAW: the entries in the chooser's order, the first whose generation point has a biome of the structure) is a wanted structure. The answer is that of the start list but no
*> start is built: only the validity of the entries (STRUCT-STUB-OK: the generation point and its biome, no pieces) is asked, and only as far as it decides. The first wanted entry in the order that is
*> valid is looked for first (an entry of the wrong biome costs a height and a biome lookup); the entries before it that are not wanted are asked only then, because any one of them valid is the
*> set's start instead.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-K                   BINARY-LONG.
 01 WS-SET-OK              BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-ORDER.
    05 WS-ORDER-ENTRY      BINARY-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SET L-KIND L-ID L-SEED L-CX L-CZ L-HIT.
     MOVE 0 TO L-HIT WS-ANY WS-FIRST
     CALL "FLAT-STRUCT-SET-OK" USING SS-KEY(L-SET) WS-SET-OK
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(L-SET)
         MOVE SE-STRUCT(SS-EN-FIRST(L-SET) + WS-K) TO WS-ST
         MOVE SDT-KEY(WS-ST) TO WS-KEY
         CALL "STRUCT-GATE" USING WS-KEY WS-ON
         IF WS-ON = 1
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF SS-POSSIBLE(L-SET) = 0 OR WS-ANY = 0 OR WS-SET-OK = 0
         GOBACK
     END-IF
     CALL "STRUCT-ENTRY-ORDER" USING L-SET L-SEED L-CX L-CZ WS-ORDER WS-N
*>   the first wanted entry in the order that is on in the gate and valid
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-N OR WS-FIRST > 0
         MOVE SE-STRUCT(SS-EN-FIRST(L-SET) + WS-ORDER-ENTRY(WS-K) - 1) TO WS-ST
         CALL "CXC-STRUCT-WANT" USING L-KIND L-ID WS-ST WS-WANT
         IF WS-WANT = 1
             MOVE SDT-KEY(WS-ST) TO WS-KEY
             CALL "STRUCT-GATE" USING WS-KEY WS-ON
             IF WS-ON = 1
                 CALL "STRUCT-STUB-OK" USING WS-ST L-SEED L-CX L-CZ WS-VALID
                 IF WS-VALID = 1
                     MOVE WS-K TO WS-FIRST
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-FIRST = 0
         GOBACK
     END-IF
*>   it is the set's start unless an entry before it (not wanted) is valid
     MOVE 1 TO L-HIT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K >= WS-FIRST OR L-HIT = 0
         MOVE SE-STRUCT(SS-EN-FIRST(L-SET) + WS-ORDER-ENTRY(WS-K) - 1) TO WS-ST
         CALL "CXC-STRUCT-WANT" USING L-KIND L-ID WS-ST WS-WANT
         IF WS-WANT = 0
             MOVE SDT-KEY(WS-ST) TO WS-KEY
             CALL "STRUCT-GATE" USING WS-KEY WS-ON
             IF WS-ON = 1
                 CALL "STRUCT-STUB-OK" USING WS-ST L-SEED L-CX L-CZ WS-VALID
                 IF WS-VALID = 1
                     MOVE 0 TO L-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CXC-STRUCT-CELL-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-STRUCT-SET-RING.
*> USING set row, kind, identifier, seed (BINARY-DOUBLE, the level seed reduced to signed 64 bits), source block x, source block z, ring (cells, 36-1 section 11 step 4), found out, locate x out,
*> locate z out, squared distance out (BINARY-DOUBLE): the answer of the random_spread set in ring r: the first cell on the border of the square (ix from -r to r outer, iz inner) whose potential chunk is
*> a structure chunk holding a start of the wanted structure; the later cells of the ring are not looked at, even when nearer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 01 WS-SPACING             BINARY-LONG.
 01 WS-CGX                 BINARY-LONG.
 01 WS-CGZ                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SET                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-SEED                 BINARY-DOUBLE.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-RING                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D2                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SET L-KIND L-ID L-SEED L-SX L-SZ L-RING L-FOUND L-X L-Z L-D2.
     MOVE 0 TO L-FOUND L-X L-Z L-D2
     MOVE SS-SPACING(L-SET) TO WS-SPACING
     COMPUTE WS-CGX = FUNCTION INTEGER(L-SX / 16 / WS-SPACING)
     COMPUTE WS-CGZ = FUNCTION INTEGER(L-SZ / 16 / WS-SPACING)
     MOVE L-RING TO WS-K
     COMPUTE WS-FIRST = 0 - WS-K
     PERFORM VARYING WS-I FROM WS-FIRST BY 1 UNTIL WS-I > WS-K OR L-FOUND = 1
         MOVE 1 TO WS-STEP
         IF FUNCTION ABS(WS-I) < WS-K
             COMPUTE WS-STEP = 2 * WS-K
         END-IF
         PERFORM VARYING WS-J FROM WS-FIRST BY WS-STEP UNTIL WS-J > WS-K OR L-FOUND = 1
             COMPUTE WS-CX = (WS-CGX + WS-I) * WS-SPACING
             COMPUTE WS-CZ = (WS-CGZ + WS-J) * WS-SPACING
             CALL "STRUCT-POTENTIAL" USING L-SET L-SEED WS-CX WS-CZ WS-PX WS-PZ
             CALL "STRUCT-IS-CHUNK" USING L-SET L-SEED WS-PX WS-PZ WS-FLAG
             IF WS-FLAG = 1
                 CALL "CXC-STRUCT-CELL-HIT" USING L-SET L-KIND L-ID L-SEED WS-PX WS-PZ WS-HIT
                 IF WS-HIT = 1
                     CALL "STRUCT-LOCATE-POS" USING L-SET WS-PX WS-PZ WS-X WS-Y WS-Z
                     COMPUTE WS-DX = WS-X - L-SX
                     COMPUTE WS-DZ = WS-Z - L-SZ
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                     MOVE 1 TO L-FOUND
                     MOVE WS-X TO L-X
                     MOVE WS-Z TO L-Z
                     MOVE WS-D2 TO L-D2
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CXC-STRUCT-SET-RING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CXC-STRUCT-NEAREST.
*> USING kind (1 a structure, 2 a tag), identifier (PIC X(80), with namespace, no "#"), source block x, source block z, level seed (BINARY-DOUBLE, signed: CW-SEED), found out, x out, z out,
*> squared distance out: the nearest answer over the sets of the structure data that hold a wanted structure (radius 100 cells).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY CLIMATE.
 COPY GENQUEUE.
 01 WS-RADIUS              BINARY-LONG VALUE 100.
 01 WS-READY               BINARY-LONG.
 01 WS-ORIGIN-Y            BINARY-LONG VALUE 32.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-D2                  BINARY-DOUBLE.
 01 WS-RING                BINARY-LONG.
 01 WS-ANSWERED            BINARY-LONG.
 01 WS-SPREAD-COUNT        BINARY-LONG.
 01 WS-SPREAD.
    05 WS-SPREAD-SET       BINARY-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-D2                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-KIND L-ID L-SX L-SZ L-SEED L-FOUND L-X L-Z L-D2.
     MOVE 0 TO L-FOUND L-X L-Z L-D2
*>   the setup of a world the chunk workers made chunks for (or that no chunk was made for yet): needs the generator data, else there is nothing to search
     CALL "GEN-DATA-READY" USING WS-READY
     IF WS-READY = 1 AND SD-SET-COUNT > 0
         CALL "GEN-WORLD-SETUP"
         IF CL-COUNT = 0
             CALL "OVB-BUILD"
         END-IF
         IF SD-POSS-DONE = 0
             CALL "STRUCT-POSSIBLE-BUILD"
         END-IF
     END-IF
     MOVE 0 TO WS-SPREAD-COUNT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         MOVE 0 TO WS-ANY
         IF SS-KIND(WS-S) = 0
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
                 MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
                 CALL "CXC-STRUCT-WANT" USING L-KIND L-ID WS-ST WS-WANT
                 IF WS-WANT = 1
                     MOVE 1 TO WS-ANY
                 END-IF
             END-PERFORM
             IF WS-ANY = 1
                 CALL "STRUCT-NEAREST-RING" USING WS-S L-SEED L-SX WS-ORIGIN-Y L-SZ WS-F WS-CX WS-CZ WS-X WS-LY WS-Z
                 IF WS-F = 1
                     COMPUTE WS-DX = WS-X - L-SX
                     COMPUTE WS-DZ = WS-Z - L-SZ
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                     IF L-FOUND = 0 OR WS-D2 < L-D2
                         MOVE 1 TO L-FOUND
                         MOVE WS-X TO L-X
                         MOVE WS-Z TO L-Z
                         MOVE WS-D2 TO L-D2
                     END-IF
                 END-IF
             END-IF
             MOVE 0 TO WS-ANY
         END-IF
         IF SS-KIND(WS-S) = 2
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= SS-EN-COUNT(WS-S)
                 MOVE SE-STRUCT(SS-EN-FIRST(WS-S) + WS-K) TO WS-ST
                 CALL "CXC-STRUCT-WANT" USING L-KIND L-ID WS-ST WS-WANT
                 IF WS-WANT = 1
                     MOVE 1 TO WS-ANY
                 END-IF
             END-PERFORM
         END-IF
         IF WS-ANY = 1
             ADD 1 TO WS-SPREAD-COUNT
             MOVE WS-S TO WS-SPREAD-SET(WS-SPREAD-COUNT)
         END-IF
     END-PERFORM
*>   step 4: ring r over all the random_spread sets; the first ring in which any set answers ends the search, the nearest answer of that ring (and of the concentric rings) wins
     MOVE 0 TO WS-ANSWERED
     PERFORM VARYING WS-RING FROM 0 BY 1 UNTIL WS-RING > WS-RADIUS OR WS-ANSWERED = 1
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SPREAD-COUNT
             CALL "CXC-STRUCT-SET-RING" USING WS-SPREAD-SET(WS-S) L-KIND L-ID L-SEED L-SX L-SZ WS-RING WS-F WS-X WS-Z WS-D2
             IF WS-F = 1
                 MOVE 1 TO WS-ANSWERED
                 IF L-FOUND = 0 OR WS-D2 < L-D2
                     MOVE 1 TO L-FOUND
                     MOVE WS-X TO L-X
                     MOVE WS-Z TO L-Z
                     MOVE WS-D2 TO L-D2
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CXC-STRUCT-NEAREST.
