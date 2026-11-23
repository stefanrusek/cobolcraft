*> The chunk NBT of structure starts and references, and the piece tags (docs/protocol/36-structures-1-model-placement-starts.md sections 6.7 and 7.3; 07-nbt-and-anvil.md section 7; STRUCTSTART.cpy).
*> A piece tag is {id, BB (int array of 6), O (-1 or 0 south, 1 west, 2 north, 3 east), GD}; a start tag {id, ChunkX, ChunkZ, references, Children}, or {id: "INVALID"} for a start without a piece; the
*> `structures` compound of a chunk is {starts: {<structure key>: start}, References: {<structure key>: long array of packed chunk positions}}. Packed position: (x & 0xFFFFFFFF) | ((z & 0xFFFFFFFF) << 32).
*> The base fields of 6.7 and the type-specific keys of the scattered pieces, the igloo, the ruined portal, the nether fossil (36-4 10), the mineshaft pieces (36-5 2.5, 2.6, 2.11, 2.12: the room's Entrances list of
*> boxes is read into the store's SST-ENT), the stronghold pieces (36-5 3.9) and the fortress pieces (36-8 3.5) are written and read (STRUCT-PIECE-KEYS-WRITE, STRUCT-PIECE-KEY-SET, struct-piece-keys.cob); the keys
*> of the other families (36-2 to 36-3, 36-6 to 36-8) are not (the pieces are rebuilt from the seed by STRUCT-DECORATE, which is the source of truth), and a piece whose type has no registry name (a builder type of
*> the other template pieces above 55) is left out of Children, so a start that has only such pieces is written as INVALID.
*> Loading follows 7.3: a start whose key names no loaded structure is dropped, INVALID loads as an empty start, a piece with an unknown id or without BB is skipped (the rename table of 6.7 is in
*> STRUCT-ENUM-ID), ChunkX, ChunkZ and references default to 0, a reference to a chunk at Chebyshev distance above 8 from the chunk being loaded is dropped. Not loaded here: the ocean monument's regenerated piece list.
*>
*> Entry points:
*>   STRUCT-PIECE-NAME USING piece type, name out (PIC X(40), registry name, spaces when the type has none)
*>   STRUCT-PACK-CHUNK USING chunk x, chunk z, packed out (BINARY-DOUBLE); STRUCT-UNPACK-CHUNK USING packed, chunk x out, chunk z out
*>   STRUCT-STARTS-WRITE USING PB-BUFFER, chunk x, chunk z: appends the named `structures` compound of the chunk (empty compounds when the store has nothing for it)
*>   STRUCT-STARTS-READ USING PB-BUFFER, chunk x, chunk z, outcome out (0 read, 1 malformed): reads the payload of the `structures` compound at PB-POS into the store

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PIECE-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-TYPE L-NAME.
     CALL "STRUCT-ENUM-NAME" USING WS-KIND L-TYPE L-NAME
     GOBACK.
 END PROGRAM STRUCT-PIECE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PACK-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M32                 PIC 9(20) VALUE 4294967296.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-UX                  PIC 9(20).
 01 WS-UZ                  PIC 9(20).
 01 WS-V                   PIC 9(20).
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-PACKED               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-CX L-CZ L-PACKED.
     COMPUTE WS-UX = FUNCTION MOD(L-CX, WS-M32)
     COMPUTE WS-UZ = FUNCTION MOD(L-CZ, WS-M32)
     COMPUTE WS-V = WS-UX + WS-UZ * WS-M32
     IF WS-V >= WS-M63
         COMPUTE L-PACKED = WS-V - WS-M64
     ELSE
         MOVE WS-V TO L-PACKED
     END-IF
     GOBACK.
 END PROGRAM STRUCT-PACK-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-UNPACK-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M31                 PIC 9(20) VALUE 2147483648.
 01 WS-M32                 PIC 9(20) VALUE 4294967296.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-V                   PIC 9(20).
 01 WS-UX                  PIC 9(20).
 01 WS-UZ                  PIC 9(20).
 LINKAGE SECTION.
 01 L-PACKED               BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKED L-CX L-CZ.
     IF L-PACKED < 0
         COMPUTE WS-V = L-PACKED + WS-M64
     ELSE
         MOVE L-PACKED TO WS-V
     END-IF
     COMPUTE WS-UX = FUNCTION MOD(WS-V, WS-M32)
     DIVIDE WS-V BY WS-M32 GIVING WS-UZ
     IF WS-UX >= WS-M31
         COMPUTE L-CX = WS-UX - WS-M32
     ELSE
         MOVE WS-UX TO L-CX
     END-IF
     IF WS-UZ >= WS-M31
         COMPUTE L-CZ = WS-UZ - WS-M32
     ELSE
         MOVE WS-UZ TO L-CZ
     END-IF
     GOBACK.
 END PROGRAM STRUCT-UNPACK-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STARTS-WRITE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-ID                  PIC X(80).
 01 WS-IDLEN               BINARY-LONG.
 01 WS-INVALID             PIC X(7) VALUE "INVALID".
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-NONE              BINARY-LONG VALUE 0.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-BB.
    05 WS-BB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-ST                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-NAMED               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LONGS.
    05 WS-LONG             BINARY-DOUBLE OCCURS 2048 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-CX L-CZ.
     MOVE "structures" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "starts" TO WN MOVE 6 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-COUNT
         IF SST-CX(WS-I) = L-CX AND SST-CZ(WS-I) = L-CZ
             MOVE SST-STRUCT(WS-I) TO WS-ST
             MOVE SDT-KEY(WS-ST) TO WS-KEY
             COMPUTE WS-KEYLEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY TRAILING))
             MOVE 0 TO WS-NAMED
             COMPUTE WS-LAST = SST-FIRST(WS-I) + SST-N(WS-I) - 1
             PERFORM VARYING WS-P FROM SST-FIRST(WS-I) BY 1 UNTIL WS-P > WS-LAST
                 CALL "STRUCT-PIECE-NAME" USING SPC-TYPE(WS-P) WS-NAME
                 IF WS-NAME NOT = SPACES
                     ADD 1 TO WS-NAMED
                 END-IF
             END-PERFORM
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-KEY WS-KEYLEN
             IF WS-NAMED = 0
                 MOVE "id" TO WN MOVE 2 TO WL
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-INVALID WS-SEVEN
             ELSE
                 MOVE "id" TO WN MOVE 2 TO WL
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-KEY WS-KEYLEN
                 MOVE "ChunkX" TO WN MOVE 6 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SST-CX(WS-I)
                 MOVE "ChunkZ" TO WN
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SST-CZ(WS-I)
                 MOVE "references" TO WN MOVE 10 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SST-REFS(WS-I)
                 MOVE "Children" TO WN MOVE 8 TO WL
                 CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-NAMED
                 PERFORM VARYING WS-P FROM SST-FIRST(WS-I) BY 1 UNTIL WS-P > WS-LAST
                     CALL "STRUCT-PIECE-NAME" USING SPC-TYPE(WS-P) WS-NAME
                     IF WS-NAME NOT = SPACES
                         MOVE -1 TO WS-J
                         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-J
                         MOVE SPACES TO WS-ID
                         MOVE 1 TO WS-IDLEN
                         STRING "minecraft:" FUNCTION TRIM(WS-NAME TRAILING) DELIMITED BY SIZE INTO WS-ID WITH POINTER WS-IDLEN
                         SUBTRACT 1 FROM WS-IDLEN
                         MOVE "id" TO WN MOVE 2 TO WL
                         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-ID WS-IDLEN
                         MOVE SPC-X0(WS-P) TO WS-BB-N(1)
                         MOVE SPC-Y0(WS-P) TO WS-BB-N(2)
                         MOVE SPC-Z0(WS-P) TO WS-BB-N(3)
                         MOVE SPC-X1(WS-P) TO WS-BB-N(4)
                         MOVE SPC-Y1(WS-P) TO WS-BB-N(5)
                         MOVE SPC-Z1(WS-P) TO WS-BB-N(6)
                         MOVE "BB" TO WN
                         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-SIX WS-BB
                         MOVE "O" TO WN MOVE 1 TO WL
                         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SPC-ORIENT(WS-P)
                         MOVE "GD" TO WN MOVE 2 TO WL
                         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SPC-DEPTH(WS-P)
                         CALL "STRUCT-PIECE-KEYS-WRITE" USING PB-BUFFER WS-P
                         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                     END-IF
                 END-PERFORM
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "References" TO WN MOVE 10 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
*>   one long array per structure, in the order of the structure's first reference of this chunk
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SST-REF-COUNT
         IF SSR-CX(WS-I) = L-CX AND SSR-CZ(WS-I) = L-CZ
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
                 IF SSR-CX(WS-J) = L-CX AND SSR-CZ(WS-J) = L-CZ AND SSR-STRUCT(WS-J) = SSR-STRUCT(WS-I)
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 MOVE 0 TO WS-N
                 PERFORM VARYING WS-J FROM WS-I BY 1 UNTIL WS-J > SST-REF-COUNT
                     IF SSR-CX(WS-J) = L-CX AND SSR-CZ(WS-J) = L-CZ AND SSR-STRUCT(WS-J) = SSR-STRUCT(WS-I)
                             AND WS-N < 2048
                         ADD 1 TO WS-N
                         CALL "STRUCT-PACK-CHUNK" USING SSR-SX(WS-J) SSR-SZ(WS-J) WS-LONG(WS-N)
                     END-IF
                 END-PERFORM
                 MOVE SDT-KEY(SSR-STRUCT(WS-I)) TO WS-KEY
                 COMPUTE WS-KEYLEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY TRAILING))
                 CALL "NBT-WRITE-LONG-ARRAY" USING PB-BUFFER WS-KEY WS-KEYLEN WS-N WS-LONGS
             END-IF
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM STRUCT-STARTS-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-STARTS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 01 WN                     PIC X(80).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 80.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEYLEN              BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-IDLEN               BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-SCX                 BINARY-LONG.
 01 WS-SCZ                 BINARY-LONG.
 01 WS-REFS                BINARY-LONG.
 01 WS-INVALID             BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NP                  BINARY-LONG.
 01 WS-PIECES.
    05 WS-PC OCCURS 1024 TIMES.
       10 PC-TYPE          BINARY-LONG.
       10 PC-ORIENT        BINARY-LONG.
       10 PC-DEPTH         BINARY-LONG.
       10 PC-BB            BINARY-LONG OCCURS 6 TIMES.
       10 PC-KS.
          15 PC-K          BINARY-LONG OCCURS 8 TIMES.
       10 PC-TPL           PIC X(64).
       10 PC-ENT-FIRST     BINARY-LONG.
       10 PC-ENT-N         BINARY-LONG.
 01 WS-BB.
    05 WS-BB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-BB-COUNT            BINARY-LONG.
 01 WS-HAS-BB              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-PD                  BINARY-LONG.
 01 WS-PNAME               PIC X(40).
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-ORIENT-V            BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-B0                  BINARY-LONG.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-B3                  BINARY-LONG.
 01 WS-B4                  BINARY-LONG.
 01 WS-B5                  BINARY-LONG.
 01 WS-JIG                 BINARY-LONG VALUE 0.
 01 WS-LONGS.
    05 WS-LONG             BINARY-DOUBLE OCCURS 2048 TIMES.
 01 WS-LONG-CAP            BINARY-LONG VALUE 2048.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-CH-TYPE             BINARY-LONG.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-STRUCT-KEY          PIC X(80).
*> the keys of a piece compound beyond id, BB, O and GD (the pairs STRUCT-PIECE-KEY-SET sorts out once the piece's id is known) and the values they make
 01 WS-PAIRS.
    05 WS-PAIR OCCURS 32 TIMES.
       10 PR-NAME          PIC X(24).
       10 PR-VTYPE         BINARY-LONG.
       10 PR-INT           BINARY-LONG.
       10 PR-STR           PIC X(64).
 01 WS-PAIR-N              BINARY-LONG.
 01 WS-PK-KS.
    05 WS-PK-K             BINARY-LONG OCCURS 8 TIMES.
 01 WS-PK-TPL              PIC X(64).
 01 WS-HIT                 BINARY-LONG.
 01 WS-DOOR-OK             BINARY-LONG.
 01 WS-STRONG              BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MEM-TYPE            BINARY-LONG.
 01 WS-MEM-NAME            PIC X(80).
 01 WS-NUM-INT             BINARY-LONG.
 01 WS-NUM-FLOAT           FLOAT-SHORT.
 01 WS-NUM-STR             PIC X(64).
 01 WS-STR-LEN             BINARY-LONG.
 01 WS-STR-CAP             BINARY-LONG VALUE 64.
*> the entrance boxes of the start being read (a mineshaft room's `Entrances`): the boxes of the pieces read so far, a piece's run from WS-ENT-BASE + 1, rolled back when the piece is not kept
 01 WS-ENTS.
    05 WS-ENT OCCURS 1024 TIMES.
       10 EN-B             BINARY-LONG OCCURS 6 TIMES.
 01 WS-ENT-COUNT           BINARY-LONG.
 01 WS-ENT-BASE            BINARY-LONG.
 01 WS-EL-TYPE             BINARY-LONG.
 01 WS-EL-COUNT            BINARY-LONG.
 01 WS-EL-I                BINARY-LONG.
 01 WS-EB-COUNT            BINARY-LONG.
 01 WS-EB.
    05 WS-EB-N             BINARY-LONG OCCURS 6 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-EI                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-CX L-CZ L-OUTCOME.
     CALL "STRUCT-STORE-SYNC"
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "starts" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-STYPE WN WS-CAPACITY WL
                     IF WS-STYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WS-STYPE NOT = 10
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-STYPE
                     ELSE
                         MOVE WN TO WS-STRUCT-KEY
                         CALL "STRUCT-FIND-STRUCT" USING WS-STRUCT-KEY WS-ST
*>                       the start compound: id, ChunkX, ChunkZ, references, Children
                         MOVE 0 TO WS-SCX WS-SCZ WS-REFS WS-INVALID WS-NP WS-ENT-COUNT
                         PERFORM UNTIL PB-ERROR = 1
                             MOVE SPACES TO WN
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY WL
                             IF WS-INNER-TYPE = 0
                                 EXIT PERFORM
                             END-IF
                             EVALUATE TRUE
                                 WHEN WN = "id" AND WS-INNER-TYPE = 8
                                     MOVE SPACES TO WS-ID
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-CAPACITY WS-IDLEN
                                     IF WS-ID = "INVALID"
                                         MOVE 1 TO WS-INVALID
                                     END-IF
                                 WHEN WN = "ChunkX" AND WS-INNER-TYPE = 3
                                     CALL "PB-GET-INT" USING PB-BUFFER WS-SCX
                                 WHEN WN = "ChunkZ" AND WS-INNER-TYPE = 3
                                     CALL "PB-GET-INT" USING PB-BUFFER WS-SCZ
                                 WHEN WN = "references" AND WS-INNER-TYPE = 3
                                     CALL "PB-GET-INT" USING PB-BUFFER WS-REFS
                                 WHEN WN = "Children" AND WS-INNER-TYPE = 9
                                     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                                         IF WS-ELEMENT-TYPE NOT = 10
                                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ELEMENT-TYPE
                                         ELSE
                                             MOVE -1 TO WS-PTYPE
                                             MOVE 0 TO WS-PO WS-PD WS-HAS-BB WS-PAIR-N
                                             MOVE WS-ENT-COUNT TO WS-ENT-BASE
                                             PERFORM UNTIL PB-ERROR = 1
                                                 MOVE SPACES TO WN
                                                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-CH-TYPE WN WS-CAPACITY WL
                                                 IF WS-CH-TYPE = 0
                                                     EXIT PERFORM
                                                 END-IF
                                                 EVALUATE TRUE
                                                     WHEN WN = "id" AND WS-CH-TYPE = 8
                                                         MOVE SPACES TO WS-ID
                                                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-ID WS-CAPACITY WS-IDLEN
                                                         MOVE FUNCTION LOWER-CASE(WS-ID) TO WS-ID
                                                         MOVE WS-ID(1:40) TO WS-PNAME
                                                         CALL "STRUCT-ENUM-ID" USING WS-KIND WS-PNAME WS-PTYPE
                                                     WHEN WN = "BB" AND WS-CH-TYPE = 11
                                                         MOVE 6 TO WS-BB-COUNT
                                                         CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-SIX WS-BB-COUNT WS-BB
                                                         IF WS-BB-COUNT = 6
                                                             MOVE 1 TO WS-HAS-BB
                                                         END-IF
                                                     WHEN WN = "O" AND WS-CH-TYPE = 3
                                                         CALL "PB-GET-INT" USING PB-BUFFER WS-ORIENT-V
                                                         IF WS-ORIENT-V = -1
                                                             MOVE -1 TO WS-PO
                                                         ELSE
                                                             COMPUTE WS-PO = FUNCTION ABS(FUNCTION REM(WS-ORIENT-V, 4))
                                                         END-IF
                                                     WHEN WN = "GD" AND WS-CH-TYPE = 3
                                                         CALL "PB-GET-INT" USING PB-BUFFER WS-PD
                                                     WHEN WS-CH-TYPE = 10 AND WN = "Properties"
*>                                                       the ruined portal's compound: its members are keys of the piece
                                                         PERFORM UNTIL PB-ERROR = 1
                                                             MOVE SPACES TO WS-MEM-NAME
                                                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-MEM-TYPE WS-MEM-NAME WS-CAPACITY WL
                                                             IF WS-MEM-TYPE = 0
                                                                 EXIT PERFORM
                                                             END-IF
                                                             IF (WS-MEM-TYPE = 1 OR WS-MEM-TYPE = 5) AND WS-PAIR-N < 32
                                                                 ADD 1 TO WS-PAIR-N
                                                                 MOVE WS-MEM-NAME TO PR-NAME(WS-PAIR-N)
                                                                 MOVE WS-MEM-TYPE TO PR-VTYPE(WS-PAIR-N)
                                                                 IF WS-MEM-TYPE = 1
                                                                     CALL "PB-GET-BYTE" USING PB-BUFFER PR-INT(WS-PAIR-N)
                                                                 ELSE
                                                                     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-NUM-FLOAT
                                                                     COMPUTE PR-INT(WS-PAIR-N) = FUNCTION INTEGER(WS-NUM-FLOAT * 10 + 0.5)
                                                                 END-IF
                                                             ELSE
                                                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-MEM-TYPE
                                                             END-IF
                                                         END-PERFORM
                                                     WHEN (WS-CH-TYPE = 1 OR WS-CH-TYPE = 2 OR WS-CH-TYPE = 3 OR WS-CH-TYPE = 5 OR WS-CH-TYPE = 8) AND WS-PAIR-N < 32
*>                                                       a key of the type-specific tables (STRUCT-PIECE-KEY-SET decides once the id is known); a float is kept in tenths
                                                         ADD 1 TO WS-PAIR-N
                                                         MOVE WN TO PR-NAME(WS-PAIR-N)
                                                         MOVE WS-CH-TYPE TO PR-VTYPE(WS-PAIR-N)
                                                         MOVE 0 TO PR-INT(WS-PAIR-N)
                                                         MOVE SPACES TO PR-STR(WS-PAIR-N)
                                                         EVALUATE WS-CH-TYPE
                                                             WHEN 1
                                                                 CALL "PB-GET-BYTE" USING PB-BUFFER PR-INT(WS-PAIR-N)
                                                             WHEN 2
                                                                 CALL "PB-GET-SHORT" USING PB-BUFFER PR-INT(WS-PAIR-N)
                                                             WHEN 3
                                                                 CALL "PB-GET-INT" USING PB-BUFFER PR-INT(WS-PAIR-N)
                                                             WHEN 5
                                                                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-NUM-FLOAT
                                                                 COMPUTE PR-INT(WS-PAIR-N) = FUNCTION INTEGER(WS-NUM-FLOAT * 10 + 0.5)
                                                             WHEN OTHER
                                                                 MOVE SPACES TO WS-NUM-STR
                                                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-NUM-STR WS-STR-CAP WS-STR-LEN
                                                                 MOVE WS-NUM-STR TO PR-STR(WS-PAIR-N)
                                                         END-EVALUATE
                                                     WHEN WN = "Entrances" AND WS-CH-TYPE = 9
*>                                                       the list of boxes of a mineshaft room (36-5 2.5; kept only for a room): an entry that is not an int array of six ints is skipped
                                                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-EL-TYPE WS-EL-COUNT
                                                         PERFORM VARYING WS-EL-I FROM 1 BY 1 UNTIL WS-EL-I > WS-EL-COUNT OR PB-ERROR = 1
                                                             IF WS-EL-TYPE NOT = 11
                                                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-EL-TYPE
                                                             ELSE
                                                                 MOVE 6 TO WS-EB-COUNT
                                                                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-SIX WS-EB-COUNT WS-EB
                                                                 IF WS-EB-COUNT = 6 AND WS-ENT-COUNT < 1024
                                                                     ADD 1 TO WS-ENT-COUNT
                                                                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                                                                         MOVE WS-EB-N(WS-K) TO EN-B(WS-ENT-COUNT, WS-K)
                                                                     END-PERFORM
                                                                 END-IF
                                                             END-IF
                                                         END-PERFORM
                                                     WHEN OTHER
                                                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-CH-TYPE
                                                 END-EVALUATE
                                             END-PERFORM
*>                                           the type-specific keys (36-4 10, 36-5 3.9); a stronghold piece without a valid EntryDoor does not load (36-5 3.9)
                                             MOVE 0 TO WS-PK-K(1) WS-PK-K(2) WS-PK-K(3) WS-PK-K(4) WS-PK-K(5) WS-PK-K(6) WS-PK-K(7) WS-PK-K(8)
                                             MOVE SPACES TO WS-PK-TPL
                                             MOVE 0 TO WS-DOOR-OK
                                             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-PAIR-N
                                                 CALL "STRUCT-PIECE-KEY-SET" USING WS-PTYPE PR-NAME(WS-J) PR-VTYPE(WS-J) PR-INT(WS-J) PR-STR(WS-J)
                                                     WS-PK-KS WS-PK-TPL WS-HIT
                                                 IF PR-NAME(WS-J) = "EntryDoor" AND WS-HIT = 1
                                                     MOVE 1 TO WS-DOOR-OK
                                                 END-IF
                                             END-PERFORM
                                             MOVE 0 TO WS-STRONG
                                             IF WS-PTYPE >= 19 AND WS-PTYPE <= 31 AND WS-DOOR-OK = 0
                                                 MOVE 1 TO WS-STRONG
                                             END-IF
                                             IF WS-PTYPE >= 0 AND WS-HAS-BB = 1 AND WS-NP < 1024 AND WS-STRONG = 0
                                                 ADD 1 TO WS-NP
                                                 MOVE WS-PTYPE TO PC-TYPE(WS-NP)
                                                 MOVE WS-PO TO PC-ORIENT(WS-NP)
                                                 MOVE WS-PD TO PC-DEPTH(WS-NP)
                                                 MOVE WS-PK-KS TO PC-KS(WS-NP)
                                                 MOVE WS-PK-TPL TO PC-TPL(WS-NP)
                                                 PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 6
                                                     MOVE WS-BB-N(WS-ROW) TO PC-BB(WS-NP, WS-ROW)
                                                 END-PERFORM
*>                                               the boxes of a room keep their run, those of any other piece are dropped
                                                 COMPUTE PC-ENT-FIRST(WS-NP) = WS-ENT-BASE + 1
                                                 MOVE 0 TO PC-ENT-N(WS-NP)
                                                 IF WS-PTYPE = 2
                                                     COMPUTE PC-ENT-N(WS-NP) = WS-ENT-COUNT - WS-ENT-BASE
                                                 ELSE
                                                     MOVE WS-ENT-BASE TO WS-ENT-COUNT
                                                 END-IF
                                             ELSE
                                                 MOVE WS-ENT-BASE TO WS-ENT-COUNT
                                             END-IF
                                         END-IF
                                     END-PERFORM
                                 WHEN OTHER
                                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                             END-EVALUATE
                         END-PERFORM
                         IF WS-ST > 0 AND PB-ERROR = 0
*>                           an INVALID start has no chunk of its own: it is the invalid start of the chunk being loaded
                             IF WS-INVALID = 1
                                 MOVE L-CX TO WS-SCX
                                 MOVE L-CZ TO WS-SCZ
                             END-IF
                             CALL "STRUCT-START-PUT" USING WS-ST WS-SCX WS-SCZ WS-REFS WS-ROW
                             IF WS-INVALID = 0
                                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NP
                                     MOVE PC-BB(WS-I, 1) TO WS-B0
                                     MOVE PC-BB(WS-I, 2) TO WS-B1
                                     MOVE PC-BB(WS-I, 3) TO WS-B2
                                     MOVE PC-BB(WS-I, 4) TO WS-B3
                                     MOVE PC-BB(WS-I, 5) TO WS-B4
                                     MOVE PC-BB(WS-I, 6) TO WS-B5
                                     MOVE PC-TYPE(WS-I) TO WS-PTYPE
                                     MOVE PC-ORIENT(WS-I) TO WS-PO
                                     MOVE PC-DEPTH(WS-I) TO WS-PD
                                     CALL "STRUCT-START-PIECE-ADD" USING WS-ROW WS-PTYPE WS-PO WS-PD WS-ZERO WS-ZERO2
                                         WS-B0 WS-B1 WS-B2 WS-B3 WS-B4 WS-B5 WS-PROW
                                     IF WS-PROW > 0
                                         MOVE PC-KS(WS-I) TO SPC-KS(WS-PROW)
                                         MOVE PC-TPL(WS-I) TO SPC-TPL(WS-PROW)
                                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PC-ENT-N(WS-I)
                                             COMPUTE WS-EI = PC-ENT-FIRST(WS-I) + WS-K - 1
                                             MOVE EN-B(WS-EI, 1) TO WS-B0
                                             MOVE EN-B(WS-EI, 2) TO WS-B1
                                             MOVE EN-B(WS-EI, 3) TO WS-B2
                                             MOVE EN-B(WS-EI, 4) TO WS-B3
                                             MOVE EN-B(WS-EI, 5) TO WS-B4
                                             MOVE EN-B(WS-EI, 6) TO WS-B5
                                             CALL "STRUCT-START-ENTRANCE-ADD" USING WS-PROW WS-B0 WS-B1 WS-B2 WS-B3 WS-B4 WS-B5
                                         END-PERFORM
                                     END-IF
                                 END-PERFORM
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             WHEN WN = "References" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-STYPE WN WS-CAPACITY WL
                     IF WS-STYPE = 0
                         EXIT PERFORM
                     END-IF
                     IF WS-STYPE NOT = 12
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-STYPE
                     ELSE
                         MOVE WN TO WS-STRUCT-KEY
                         CALL "STRUCT-FIND-STRUCT" USING WS-STRUCT-KEY WS-ST
                         CALL "NBT-READ-LONG-ARRAY" USING PB-BUFFER WS-LONG-CAP WS-COUNT WS-LONGS
                         IF WS-ST > 0 AND PB-ERROR = 0
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                                 CALL "STRUCT-UNPACK-CHUNK" USING WS-LONG(WS-I) WS-RX WS-RZ
                                 COMPUTE WS-DX = FUNCTION ABS(WS-RX - L-CX)
                                 COMPUTE WS-DZ = FUNCTION ABS(WS-RZ - L-CZ)
                                 IF WS-DX <= 8 AND WS-DZ <= 8
                                     CALL "STRUCT-REF-ADD" USING L-CX L-CZ WS-ST WS-RX WS-RZ
                                 END-IF
                             END-PERFORM
                         END-IF
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     MOVE PB-ERROR TO L-OUTCOME
     GOBACK.
 END PROGRAM STRUCT-STARTS-READ.
