*> Implementation test of the piece tags and the chunk NBT of structure starts (docs/protocol/36-structures-1-model-placement-starts.md sections 6.7, 7.3 and 13.2, 13.3, 13.16; core/src/struct-start-nbt.cob):
*> the packed chunk position, an empty store writes {starts: {}, References: {}}, a start tag has the keys id, ChunkX, ChunkZ, references and Children with piece tags {id, BB, O, GD}, a start whose pieces
*> have no registry name is written as {id: INVALID}, the written structures compound loads back into the same start (key, chunk, references, pieces in order, orientation, depth) and the same references,
*> an unknown structure key is dropped, an id with capitals loads (lower-cased on read), the ids nvi, pcp, bastionremnant and runtime load as jigsaw, an unknown piece id and a piece without BB are
*> skipped, ChunkX, ChunkZ, references, O and GD default to 0, and a reference at Chebyshev distance above 8 from the loaded chunk is dropped. Structure rows are built by hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-UX                  BINARY-LONG.
 01 WS-UZ                  BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-KEY                 PIC X(80).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-BB.
    05 WS-BB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-LONGS.
    05 WS-LONG             BINARY-DOUBLE OCCURS 4 TIMES.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LIST-TYPE           BINARY-LONG VALUE 10.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-STR                 PIC X(40).
 01 WS-STRLEN              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "minecraft:alpha" TO SDT-KEY(1)
     MOVE "minecraft:beta" TO SDT-KEY(2)
     MOVE 2 TO SD-ST-COUNT
     MOVE 0 TO SDT-ADAPT(1) SDT-ADAPT(2)

*>   the packed position
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     CALL "STRUCT-PACK-CHUNK" USING WS-CX WS-CZ WS-PACKED
     MOVE "acceptance US12 36-1§7.1 packed chunk position: chunk (1, 2) is 1 | 2 << 32 = 8589934593" TO TL-CASE
     MOVE 8589934593 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE -1 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "STRUCT-PACK-CHUNK" USING WS-CX WS-CZ WS-PACKED
     MOVE "acceptance US12 36-1§7.1 packed chunk position: chunk (-1, 0) is 0xFFFFFFFF = 4294967295" TO TL-CASE
     MOVE 4294967295 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE 0 TO WS-CX
     MOVE -1 TO WS-CZ
     CALL "STRUCT-PACK-CHUNK" USING WS-CX WS-CZ WS-PACKED
     MOVE "acceptance US12 36-1§7.1 packed chunk position: chunk (0, -1) is 0xFFFFFFFF00000000 = -4294967296 as a signed long" TO TL-CASE
     MOVE -4294967296 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE -1 TO WS-CX
     MOVE -1 TO WS-CZ
     CALL "STRUCT-PACK-CHUNK" USING WS-CX WS-CZ WS-PACKED
     MOVE "acceptance US12 36-1§7.1 packed chunk position: chunk (-1, -1) is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-PACKED TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE -7 TO WS-CX
     MOVE 123456 TO WS-CZ
     CALL "STRUCT-PACK-CHUNK" USING WS-CX WS-CZ WS-PACKED
     CALL "STRUCT-UNPACK-CHUNK" USING WS-PACKED WS-UX WS-UZ
     MOVE "acceptance US12 36-1§7.1 packed chunk position: unpack gives back (-7, 123456)" TO TL-CASE
     MOVE -7 TO TL-EXPECTED-N
     MOVE WS-UX TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§7.1 packed chunk position: unpack gives back z 123456" TO TL-CASE
     MOVE 123456 TO TL-EXPECTED-N
     MOVE WS-UZ TO TL-OBSERVED-N
     PERFORM CHECK-NUM

*>   the empty store
     CALL "STRUCT-STORE-RESET"
     MOVE 0 TO WS-CX WS-CZ
     PERFORM WRITE-STRUCTURES
     MOVE "structures" TO WS-PATH
     PERFORM GET-TEXT
     MOVE "acceptance US12 36-1§7.3 chunk NBT: an empty store writes structures {starts: {}, References: {}}" TO TL-CASE
     MOVE "{starts:{},References:{}}" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   registry names of piece types (kind 3): id 0 mscorridor, jigsaw has a registry id, a builder type above 55 has none
     MOVE 0 TO WS-T
     CALL "STRUCT-PIECE-NAME" USING WS-T WS-NAME
     MOVE "acceptance US12 36-1§13.1 piece type 0 is the mineshaft corridor mscorridor" TO TL-CASE
     MOVE "mscorridor" TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 100 TO WS-T
     CALL "STRUCT-PIECE-NAME" USING WS-T WS-NAME
     MOVE "acceptance US12 36-1§6.7 a builder type without a registry name (100) has no piece name" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT

*>   a start at chunk (3, -4) of structure 1: references 1, pieces mscorridor (type 0, orientation 2 north, depth 3) and mscrossing (type 1, no orientation, depth 0) and an unnamed one (type 100)
     MOVE 1 TO WS-S
     MOVE 3 TO WS-CX
     MOVE -4 TO WS-CZ
     MOVE 1 TO WS-REFS
     CALL "STRUCT-START-PUT" USING WS-S WS-CX WS-CZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 0 TO WS-T
     MOVE 2 TO WS-O
     MOVE 3 TO WS-D
     MOVE 0 TO WS-J WS-G
     MOVE 48 TO WS-X0
     MOVE 60 TO WS-Y0
     MOVE -64 TO WS-Z0
     MOVE 52 TO WS-X1
     MOVE 63 TO WS-Y1
     MOVE -58 TO WS-Z1
     PERFORM ADD-PIECE
     MOVE 1 TO WS-T
     MOVE -1 TO WS-O
     MOVE 0 TO WS-D
     MOVE 40 TO WS-X0
     MOVE 61 TO WS-Y0
     MOVE -70 TO WS-Z0
     MOVE 47 TO WS-X1
     MOVE 64 TO WS-Y1
     MOVE -63 TO WS-Z1
     PERFORM ADD-PIECE
     MOVE 100 TO WS-T
     PERFORM ADD-PIECE
*>   a start of structure 2 with only an unnamed piece is written as INVALID
     MOVE 2 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-CX WS-CZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     PERFORM ADD-PIECE
*>   references of chunk (3, -4): structure 1 from (3, -4) and (0, -4), structure 2 from (1, -5)
     MOVE 1 TO WS-S
     MOVE 3 TO WS-UX
     MOVE -4 TO WS-UZ
     PERFORM ADD-REF
     MOVE 2 TO WS-S
     MOVE 1 TO WS-UX
     MOVE -5 TO WS-UZ
     PERFORM ADD-REF
     MOVE 1 TO WS-S
     MOVE 0 TO WS-UX
     MOVE -4 TO WS-UZ
     PERFORM ADD-REF
     PERFORM WRITE-STRUCTURES
     MOVE "structures.starts.minecraft:alpha" TO WS-PATH
     PERFORM GET-TEXT
     MOVE "acceptance US12 36-1§13.3 start tag: id, ChunkX, ChunkZ, references and Children of the two named pieces (id, BB, O, GD and the mineshaft keys of 36-5 2.6 and 2.11); the unnamed builder piece is left out" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "{id:minecraft:alpha,ChunkX:3,ChunkZ:-4,references:1,Children:["
         "{id:minecraft:mscorridor,BB:I[48,60,-64,52,63,-58],O:2,GD:3,hr:0,sc:0,hps:0,Num:0,MST:0},"
         "{id:minecraft:mscrossing,BB:I[40,61,-70,47,64,-63],O:-1,GD:0,tf:0,D:0,MST:0}]}"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "structures.starts.minecraft:beta" TO WS-PATH
     PERFORM GET-TEXT
     MOVE "acceptance US12 36-1§13.3 an invalid start (no piece with a registry name) is {id: INVALID}" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE "{id:INVALID}" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "structures.References" TO WS-PATH
     PERFORM GET-TEXT
     MOVE "acceptance US12 36-1§7.3 References: one long array per structure (structure 1 two entries, structure 2 one)" TO TL-CASE
     MOVE "{minecraft:alpha:L2,minecraft:beta:L1}" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   load it back into an empty store
     CALL "STRUCT-STORE-RESET"
     PERFORM READ-STRUCTURES
     MOVE "acceptance US12 36-1§7.3 loading: the written structures compound reads back (outcome 0), the alpha start at chunk (3, -4) with 2 pieces and references 1, the INVALID beta start with none" TO TL-CASE
     MOVE 1 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE 2 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-PR
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 100000 + SST-N(WS-ROW) * 10000 + SST-REFS(WS-ROW) * 1000 + SST-N(WS-PR) * 100 + SST-COUNT
     MOVE 21002 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§6.7 loading: piece 2 is type 1 (mscrossing), no orientation, depth 0, box 40 61 -70 47 64 -63; piece 1 orientation 2, depth 3" TO TL-CASE
     COMPUTE WS-P = SST-FIRST(WS-ROW) + 1
     MOVE 0 TO TL-OBSERVED-N
     MOVE SST-FIRST(WS-ROW) TO WS-J
     IF SPC-TYPE(WS-P) = 1 AND SPC-ORIENT(WS-P) = -1 AND SPC-DEPTH(WS-P) = 0 AND SPC-X0(WS-P) = 40 AND SPC-Y0(WS-P) = 61
             AND SPC-Z0(WS-P) = -70 AND SPC-X1(WS-P) = 47 AND SPC-Y1(WS-P) = 64 AND SPC-Z1(WS-P) = -63
             AND SPC-ORIENT(WS-J) = 2 AND SPC-DEPTH(WS-J) = 3 AND SPC-TYPE(WS-J) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§7.3 loading: the three references come back in order (structure, source chunk): 1 (3,-4), 1 (0,-4), 2 (1,-5)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-REF-COUNT * 100000 + SSR-SX(1) * 10000 + SSR-SX(2) * 1000 + SSR-STRUCT(3) * 100 + SSR-SX(3) * 10 + 1
     COMPUTE TL-EXPECTED-N = 3 * 100000 + 3 * 10000 + 0 * 1000 + 2 * 100 + 1 * 10 + 1
     PERFORM CHECK-NUM

*>   hand-built tags: defaults, lower-casing, the rename table, skipped pieces, unknown keys, far references
     CALL "STRUCT-STORE-RESET"
     MOVE 0 TO WS-CX WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
*>   beta: no chunk, references or orientation; four children
     MOVE "minecraft:beta" TO WS-KEY MOVE 14 TO WS-KEYLEN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEYLEN
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 4 TO WS-VALUE
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-TEN WS-VALUE
     MOVE "minecraft:MSCorridor" TO WS-STR MOVE 20 TO WS-STRLEN
     MOVE 1 TO WS-VALUE
     PERFORM PUT-PIECE
     MOVE "minecraft:nvi" TO WS-STR MOVE 13 TO WS-STRLEN
     PERFORM PUT-PIECE
     MOVE "minecraft:nonexistent" TO WS-STR MOVE 21 TO WS-STRLEN
     PERFORM PUT-PIECE
     MOVE "minecraft:mscrossing" TO WS-STR MOVE 20 TO WS-STRLEN
     MOVE 0 TO WS-VALUE
     PERFORM PUT-PIECE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>   gamma: not a loaded structure
     MOVE "minecraft:gamma" TO WS-KEY MOVE 15 TO WS-KEYLEN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEYLEN
     MOVE "ChunkX" TO WN MOVE 6 TO WL
     MOVE 5 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
*>   alpha: INVALID
     MOVE "minecraft:alpha" TO WS-KEY MOVE 15 TO WS-KEYLEN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEYLEN
     MOVE "id" TO WN MOVE 2 TO WL
     MOVE "INVALID" TO WS-STR MOVE 7 TO WS-STRLEN
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "References" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:alpha" TO WS-KEY MOVE 15 TO WS-KEYLEN
     MOVE 4 TO WS-VALUE
     PERFORM PUT-FAR-REFS
     MOVE "minecraft:gamma" TO WS-KEY MOVE 15 TO WS-KEYLEN
     PERFORM PUT-FAR-REFS
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-STRUCTURES
     MOVE 2 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-ZERO WS-ZERO2 WS-ROW
     MOVE 1 TO WS-S
     CALL "STRUCT-START-FIND" USING WS-S WS-ZERO WS-ZERO2 WS-PR
     MOVE "acceptance US12 36-1§7.3 loading: beta defaults to chunk (0, 0), references 0; gamma (unknown structure) is dropped; alpha INVALID loads empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 1000 + SST-REFS(WS-ROW) * 100 + SST-N(WS-PR) * 10 + WS-OUTCOME
     MOVE 2000 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§6.7 loading: MSCorridor (lower-cased) and nvi (rename to jigsaw) load, the unknown id and the piece without BB are skipped; O and GD default to 0" TO TL-CASE
     MOVE "jigsaw" TO WS-NAME
     CALL "STRUCT-ENUM-ID" USING WS-KIND WS-NAME WS-J
     COMPUTE WS-P = SST-FIRST(WS-ROW) + 1
     COMPUTE TL-OBSERVED-N = SST-N(WS-ROW) * 100000 + SPC-TYPE(SST-FIRST(WS-ROW)) * 10000 + SPC-ORIENT(SST-FIRST(WS-ROW)) * 1000
         + SPC-DEPTH(SST-FIRST(WS-ROW)) * 100 + 1
     COMPUTE TL-EXPECTED-N = 2 * 100000 + 0 * 10000 + 0 * 1000 + 0 * 100 + 1
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§6.7 loading: the second piece's type is the registry id of jigsaw" TO TL-CASE
     MOVE WS-J TO TL-EXPECTED-N
     MOVE SPC-TYPE(WS-P) TO TL-OBSERVED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§13.16 loading References: (8, -8) and (-8, 8) are kept, (9, 0) and (0, 9) beyond Chebyshev distance 8 and the unknown structure's array are dropped" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-REF-COUNT * 1000 + SSR-SX(1) * 100 + SSR-SZ(1) * 10 + SSR-SX(2)
     COMPUTE TL-EXPECTED-N = 2 * 1000 + 8 * 100 + -8 * 10 + -8
     PERFORM CHECK-NUM
*>   tags the reader does not know are skipped: an int among the starts and among the references, an unknown key in a start, children that are not compounds, an unknown key of the structures compound
     CALL "STRUCT-STORE-RESET"
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Other" TO WN MOVE 5 TO WL
     MOVE 9 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "junk" TO WN MOVE 4 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "minecraft:alpha" TO WS-KEY MOVE 15 TO WS-KEYLEN
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEYLEN
     MOVE "Extra" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "ChunkX" TO WN MOVE 6 TO WL
     MOVE 2 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     MOVE "Children" TO WN MOVE 8 TO WL
     MOVE 3 TO WS-LIST-TYPE
     MOVE 2 TO WS-VALUE
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-LIST-TYPE WS-VALUE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-VALUE
     CALL "PB-PUT-INT" USING PB-BUFFER WS-VALUE
     MOVE 10 TO WS-LIST-TYPE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "References" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "minecraft:beta" TO WN MOVE 14 TO WL
     MOVE 7 TO WS-VALUE
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-STRUCTURES
     MOVE 1 TO WS-S
     MOVE 2 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "STRUCT-START-FIND" USING WS-S WS-CX WS-CZ WS-ROW
     MOVE "acceptance US12 36-1§7.3 loading: unknown tags are skipped (an int among starts and references, unknown keys, non-compound children): alpha at chunk (2, 0) loads empty, no reference" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OUTCOME * 1000 + SST-COUNT * 100 + SST-N(WS-ROW) * 10 + SST-REF-COUNT
     MOVE 100 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     STOP RUN.

 READ-STRUCTURES.
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE SPACES TO WN
     MOVE 32 TO WS-STRLEN
     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-STRLEN WL
     CALL "STRUCT-STARTS-READ" USING PB-BUFFER WS-CX WS-CZ WS-OUTCOME.

*> a piece compound: id WS-STR, BB (0 0 0 1 1 1) unless WS-VALUE is 0
 PUT-PIECE.
     MOVE -1 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "id" TO WN MOVE 2 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-STR WS-STRLEN
     IF WS-VALUE = 1
         MOVE "BB" TO WN
         MOVE 0 TO WS-BB-N(1) WS-BB-N(2) WS-BB-N(3)
         MOVE 1 TO WS-BB-N(4) WS-BB-N(5) WS-BB-N(6)
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
     END-IF
*>   an unknown key of a piece tag is skipped
     MOVE "Extra" TO WN MOVE 5 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-VALUE
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

*> a long array named WS-KEY of four packed positions: (9, 0), (8, -8), (-8, 8), (0, 9)
 PUT-FAR-REFS.
     MOVE 9 TO WS-UX
     MOVE 0 TO WS-UZ
     CALL "STRUCT-PACK-CHUNK" USING WS-UX WS-UZ WS-LONG(1)
     MOVE 8 TO WS-UX
     MOVE -8 TO WS-UZ
     CALL "STRUCT-PACK-CHUNK" USING WS-UX WS-UZ WS-LONG(2)
     MOVE -8 TO WS-UX
     MOVE 8 TO WS-UZ
     CALL "STRUCT-PACK-CHUNK" USING WS-UX WS-UZ WS-LONG(3)
     MOVE 0 TO WS-UX
     MOVE 9 TO WS-UZ
     CALL "STRUCT-PACK-CHUNK" USING WS-UX WS-UZ WS-LONG(4)
     CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WS-KEY WS-KEYLEN WS-VALUE WS-LONGS.

 CHECK-PACKED.
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-REF.
     CALL "STRUCT-REF-ADD" USING WS-CX WS-CZ WS-S WS-UX WS-UZ.

 ADD-PIECE.
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P.

 WRITE-STRUCTURES.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     CALL "STRUCT-STARTS-WRITE" USING PB-BUFFER WS-CX WS-CZ
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT.

 GET-TEXT.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED.

 CHECK-TEXT.
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT-NUMS.
     MOVE "A" TO TL-MODE
     MOVE FUNCTION TRIM(TL-EXPECTED) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-START-NBT.

 COPY CORETEST.
