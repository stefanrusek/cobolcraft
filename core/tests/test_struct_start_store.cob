*> Implementation test of the StructureStart records, references and queries of docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 7.1, 7.4, 7.5 and 13 (T1305, T1309; core/src/struct-start.cob):
*> a start is valid with at least one piece, its box is the union of the piece boxes inflated by 12 when the structure adapts terrain, canBeReferenced is references < 1 (13.16), createReferences scans the
*> chunks within Chebyshev distance 8 (x outer, z inner) and references a chunk when the adjusted box meets its x-z square (7.4), startsForStructure answers the referenced starts in set order and skips
*> invalid ones, getStructureAt tests the adjusted box and getStructureWithPieceAt a piece box (13.11), getAllStructuresAt lists the references without a box test. Structure rows are built by hand
*> (row 1 terrain adaptation none, row 2 bury); the expected boxes and references are worked from the document's rules.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-STORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FILTER              BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-S                   BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(80).
 01 WS-EDIT                PIC -(4)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LIST.
    05 WS-START            BINARY-LONG OCCURS 64 TIMES.
 01 WS-STRUCTS.
    05 WS-STRUCT           BINARY-LONG OCCURS 64 TIMES.
 01 WS-SXS.
    05 WS-SX               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SZS.
    05 WS-SZ               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     MOVE 0 TO SDT-ADAPT(1)
     MOVE 1 TO SDT-ADAPT(2)
     MOVE 4 TO SDT-ADAPT(3)
     CALL "STRUCT-STORE-RESET"
*>   start 1: structure 1 (none) at chunk (0, 0), two pieces; start 2: structure 2 (bury) at (0, 0), one piece; start 3: structure 1 at chunk (9, 0) with a huge box
     MOVE 0 TO WS-A
     MOVE 1 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 60 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 20 TO WS-X1
     MOVE 70 TO WS-Y1
     MOVE 10 TO WS-Z1
     PERFORM DO-PIECE
     MOVE "acceptance US12 36-1§5.6 StructureStart: a start row and its first piece row are 1" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1
     COMPUTE TL-OBSERVED-N = WS-ROW * 10 + WS-P
     MOVE 11 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE WS-ROW TO WS-PR
     MOVE 6 TO WS-T
     MOVE 2 TO WS-O
     MOVE 3 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 2 TO WS-X0
     MOVE 62 TO WS-Y0
     MOVE 2 TO WS-Z0
     MOVE 8 TO WS-X1
     MOVE 66 TO WS-Y1
     MOVE 8 TO WS-Z1
     PERFORM DO-PIECE
     CALL "STRUCT-START-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
     MOVE "acceptance US12 36-1§5.6 getBoundingBox: terrain adaptation none is the union of the piece boxes, valid with pieces" TO TL-CASE
     PERFORM EDIT-BOX
     MOVE "1 0 60 0 20 70 10" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE WS-ROW TO WS-PR
     MOVE 7 TO WS-T
     MOVE -1 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 60 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 10 TO WS-X1
     MOVE 70 TO WS-Y1
     MOVE 10 TO WS-Z1
     PERFORM DO-PIECE
     CALL "STRUCT-START-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
     MOVE "acceptance US12 36-1§5.6 getBoundingBox: bury inflates the union by 12 in every direction (13.10)" TO TL-CASE
     PERFORM EDIT-BOX
     MOVE "1 -12 48 -12 22 82 22" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-S
     MOVE 9 TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE -300 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE -300 TO WS-Z0
     MOVE 300 TO WS-X1
     MOVE 90 TO WS-Y1
     MOVE 300 TO WS-Z1
     PERFORM DO-PIECE
     MOVE 3 TO WS-S
     MOVE 5 TO WS-PCX
     MOVE 5 TO WS-PCZ
     PERFORM DO-PUT
     MOVE "acceptance US12 36-1§5.6 isValid: a start without a piece is not valid and has an empty box" TO TL-CASE
     CALL "STRUCT-START-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
     PERFORM EDIT-BOX
     MOVE "0 0 0 0 0 0 0" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   canBeReferenced: references < 1
     MOVE "acceptance US12 36-1§13.16 canBeReferenced: references 0 can be referenced, after addReference 1 it cannot" TO TL-CASE
     CALL "STRUCT-START-CAN-REF" USING WS-ROW WS-A
     CALL "STRUCT-START-ADD-REF" USING WS-ROW
     CALL "STRUCT-START-CAN-REF" USING WS-ROW WS-B
     COMPUTE TL-OBSERVED-N = WS-A * 10 + WS-B
     MOVE 10 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   references of chunk (1, 0): x 16 to 31, z 0 to 15: start 1 (box x 0..20) reaches it, start 2 (inflated x -12..22) reaches it, the far start (chunk 9) does not scan
     MOVE 1 TO WS-CX MOVE 0 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: chunk (1, 0) is reached by the start of structure 1 (x to 20), the start of structure 2 (x to 22) and the far start of chunk (9, 0) (box x -300 to 90), in start order" TO TL-CASE
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM EDIT-FOR-ALL
     MOVE "3: 1@0,0 2@0,0 1@9,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
*>   chunk (2, 0) x 32 to 47: neither
     MOVE 2 TO WS-CX MOVE 0 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: chunk (2, 0) is reached only by the far start of chunk (9, 0) (the other boxes end at x 22)" TO TL-CASE
     MOVE 2 TO WS-CX
     PERFORM EDIT-FOR-ALL
     MOVE "1: 1@9,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
*>   chunk (-1, 0): x -16 to -1: only the inflated start 2
     MOVE -1 TO WS-CX MOVE 0 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: chunk (-1, 0) is reached only by the inflated box of the bury start" TO TL-CASE
     MOVE -1 TO WS-CX
     PERFORM EDIT-FOR-ALL
     MOVE "1: 2@0,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
*>   chunk (0, 1): z 16 to 31: inflated start 2 (z to 22) only
     MOVE 0 TO WS-CX MOVE 1 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: chunk (0, 1) is reached by the bury start (z to 22) only" TO TL-CASE
     MOVE 0 TO WS-CX
     MOVE 1 TO WS-CZ
     PERFORM EDIT-FOR-ALL
     MOVE "1: 2@0,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
*>   chunk (0, 0): its own chunk (both), the far start of chunk (9, 0) is outside the radius 8 scan although its box covers x -300
     MOVE 0 TO WS-CX MOVE 0 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: radius 8 only: the start held by chunk (9, 0) with a box over chunk (0, 0) is not found" TO TL-CASE
     MOVE 0 TO WS-CX WS-CZ
     PERFORM EDIT-FOR-ALL
     MOVE "2: 1@0,0 2@0,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE 8 TO WS-CX MOVE 0 TO WS-CZ PERFORM DO-REFS
     MOVE "acceptance US12 36-1§7.4 createReferences: from chunk (8, 0) the chunk (9, 0) is in the scan and its huge box references it" TO TL-CASE
     MOVE 8 TO WS-CX
     PERFORM EDIT-FOR-ALL
     MOVE "1: 1@9,0" TO TL-EXPECTED
     PERFORM CHECK-TEXT

*>   filters: structure 2 only, and the adapting structures only (row 2 bury; row 1 none)
     MOVE 0 TO WS-CX WS-CZ
     MOVE 2 TO WS-FILTER
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ WS-FILTER WS-COUNT WS-LIST
     MOVE "acceptance US12 36-1§7.5 startsForStructure: a structure filter keeps that structure's starts" TO TL-CASE
     MOVE WS-COUNT TO WS-EDIT
     COMPUTE TL-OBSERVED-N = WS-COUNT * 10 + WS-START(1)
     MOVE 12 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ WS-NONE WS-COUNT WS-LIST
     MOVE "acceptance US12 36-1§9.2 startsForStructure with the adapting predicate (terrain_adaptation not none): only the bury start" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 10 + WS-START(1)
     MOVE 12 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   a referenced start that is invalid is skipped: chunk (5, 5) holds the invalid start 4 of structure 3; reference it by hand
     MOVE 3 TO WS-S MOVE 5 TO WS-X MOVE 5 TO WS-Z PERFORM DO-REF-ADD
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ WS-ZERO WS-COUNT WS-LIST
     MOVE "acceptance US12 36-1§7.5 startsForStructure: a referenced start without pieces is not returned" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   a reference whose start is not in the store is skipped too
     MOVE 3 TO WS-S MOVE 7 TO WS-X MOVE 7 TO WS-Z PERFORM DO-REF-ADD
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ WS-ZERO WS-COUNT WS-LIST
     MOVE "acceptance US12 36-1§7.5 startsForStructure: a reference to a chunk without that start is skipped" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   getStructureAt: adjusted box; getStructureWithPieceAt: a piece box
     MOVE -5 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "STRUCT-STRUCTURE-AT" USING WS-X WS-Y WS-Z WS-ZERO WS-ROW
     MOVE "acceptance US12 36-1§13.11 getStructureAt (-5, 60, 5): the bury start's inflated box contains it, start 2" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     CALL "STRUCT-WITH-PIECE-AT" USING WS-X WS-Y WS-Z WS-ZERO WS-ROW
     MOVE "acceptance US12 36-1§13.11 getStructureWithPieceAt (-5, 60, 5): no piece box contains it, none" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 5 TO WS-X
     MOVE 65 TO WS-Y
     CALL "STRUCT-WITH-PIECE-AT" USING WS-X WS-Y WS-Z WS-ZERO WS-ROW
     MOVE "acceptance US12 36-1§7.5 getStructureWithPieceAt (5, 65, 5): both starts have a piece there, the first reference (start 1) wins" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 2 TO WS-S CALL "STRUCT-WITH-PIECE-AT" USING WS-X WS-Y WS-Z WS-S WS-ROW
     MOVE "acceptance US12 36-1§7.5 getStructureWithPieceAt with a structure: only that structure's start, start 2" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 1 TO WS-S CALL "STRUCT-STRUCTURE-AT" USING WS-X WS-Y WS-Z WS-S WS-ROW
     MOVE "acceptance US12 36-1§7.5 getStructureAt with a structure: the structure 1 start whose box holds the block, start 1" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 90 TO WS-Y
     CALL "STRUCT-STRUCTURE-AT" USING WS-X WS-Y WS-Z WS-ZERO WS-ROW
     MOVE "acceptance US12 36-1§7.5 getStructureAt: above every box (y 90) none" TO TL-CASE
     MOVE WS-ROW TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   getAllStructuresAt: the references of the chunk, no box test (a block far from every box in the chunk is still listed)
     MOVE 15 TO WS-X MOVE 15 TO WS-Z CALL "STRUCT-ALL-AT" USING WS-X WS-Z WS-COUNT WS-STRUCTS WS-SXS WS-SZS
     MOVE "acceptance US12 36-1§7.5 getAllStructuresAt (15, 15): the references of chunk (0, 0) without a box test, four entries (two invalid or absent starts are listed too)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE "acceptance US12 36-1§7.5 getAllStructuresAt: first entry structure 1 from chunk (0, 0), second structure 2" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STRUCT(1) * 100 + WS-STRUCT(2) * 10 + WS-SX(1) + WS-SZ(2)
     MOVE 120 TO TL-EXPECTED-N
     PERFORM CHECK-NUM

*>   a replaced start loses its pieces; pieces can only be added to the start put last
     MOVE 1 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE "acceptance US12 36-1§5.6 StructureStart: putting the start of a structure and chunk again replaces it with an empty one" TO TL-CASE
     CALL "STRUCT-START-BOX" USING WS-ROW WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-VALID
     MOVE WS-VALID TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 2 TO WS-B
     MOVE SST-LOST TO WS-A
     MOVE WS-B TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 1 TO WS-X1
     MOVE 1 TO WS-Y1
     MOVE 1 TO WS-Z1
     PERFORM DO-PIECE
     MOVE "acceptance US12 36-1§6.6 builder: a piece is appended only to the start put last (older start 2 refuses, loss counted)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-P * 10 + SST-LOST - WS-A
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   junctions belong to the piece added last
     MOVE WS-ROW TO WS-PR
     MOVE 60 TO WS-T
     MOVE 2 TO WS-O
     MOVE 0 TO WS-D
     MOVE 1 TO WS-J
     MOVE -2 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 4 TO WS-X1
     MOVE 4 TO WS-Y1
     MOVE 4 TO WS-Z1
     PERFORM DO-PIECE
     MOVE WS-P TO WS-PR
     MOVE 3 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM DO-JUNC
     MOVE WS-P TO WS-PR
     MOVE 5 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 6 TO WS-Z
     PERFORM DO-JUNC
     MOVE "acceptance US12 36-1§9.2 junctions: two junctions of the last piece, in order, with the piece's jigsaw kind and ground delta" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SPC-J-N(WS-P) * 1000 + SJ-X(SPC-J-FIRST(WS-P) + 1) * 100 + SPC-JIG(WS-P) * 10 + SPC-GROUND(WS-P)
     MOVE 2508 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE SST-LOST TO WS-A
     MOVE 1 TO WS-C
     MOVE WS-C TO WS-PR
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     PERFORM DO-JUNC
     MOVE "acceptance US12 36-1§9.2 junctions: a junction for a piece that is not the last is refused and counted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-LOST - WS-A
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   full tables: the start table is emptied when a new start does not fit
     CALL "STRUCT-STORE-RESET"
     MOVE 0 TO WS-A
     PERFORM VARYING WS-B FROM 0 BY 1 UNTIL WS-B > 511
         MOVE 1 TO WS-S
     MOVE WS-B TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     END-PERFORM
     MOVE 1 TO WS-S
     MOVE 600 TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE "acceptance US12 36-1§7.1 the working set: a 513th start empties the store and is the only one left" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10 + WS-ROW
     MOVE 11 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 1 TO WS-X1
     MOVE 1 TO WS-Y1
     MOVE 1 TO WS-Z1
     PERFORM DO-PIECE
     MOVE 1 TO WS-A
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 4100
         MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 1 TO WS-X1
     MOVE 1 TO WS-Y1
     MOVE 1 TO WS-Z1
     PERFORM DO-PIECE
     END-PERFORM
     MOVE "acceptance US12 36-1§6.6 the piece table holds 4096 pieces, the rest is dropped and counted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-PIECE-COUNT
     MOVE 4096 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     CALL "STRUCT-STORE-RESET"
*>   a start asked again once the piece table is nearly full resets the store (the replaced start too)
     MOVE 1 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 3200
         MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 1 TO WS-X1
     MOVE 1 TO WS-Y1
     MOVE 1 TO WS-Z1
     PERFORM DO-PIECE
     END-PERFORM
     MOVE 1 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE "acceptance US12 36-1§7.1 the working set: a start put again with the piece table nearly full empties the store first" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10 + SST-PIECE-COUNT
     MOVE 10 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     MOVE 2 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 3200
         MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O
     MOVE 0 TO WS-D
     MOVE 0 TO WS-J
     MOVE 0 TO WS-G
     MOVE 0 TO WS-X0
     MOVE 0 TO WS-Y0
     MOVE 0 TO WS-Z0
     MOVE 1 TO WS-X1
     MOVE 1 TO WS-Y1
     MOVE 1 TO WS-Z1
     PERFORM DO-PIECE
     END-PERFORM
     MOVE 3 TO WS-S
     MOVE WS-ZERO TO WS-PCX
     MOVE WS-ZERO TO WS-PCZ
     PERFORM DO-PUT
     MOVE "acceptance US12 36-1§7.1 the working set: a new start with the piece table nearly full empties the store first" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-COUNT * 10 + SST-PIECE-COUNT
     MOVE 10 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
*>   the reference table keeps 2048 entries, the rest is counted
     CALL "STRUCT-STORE-RESET"
     PERFORM VARYING WS-B FROM 1 BY 1 UNTIL WS-B > 2050
         MOVE 1 TO WS-S MOVE WS-B TO WS-X MOVE 0 TO WS-Z PERFORM DO-REF-ADD
     END-PERFORM
     MOVE "acceptance US12 36-1§7.1 the reference table holds 2048 entries, two more are counted as lost" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SST-REF-COUNT * 10 + SST-LOST
     MOVE 20482 TO TL-EXPECTED-N
     PERFORM CHECK-NUM
     STOP RUN.

*> the box and valid flag as text
 EDIT-BOX.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-VALID TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-X0 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-Y0 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-Z0 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-X1 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-Y1 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-Z1 TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
    .

*> the starts that reference chunk (WS-CX, WS-CZ) as "<n>: <structure>@<cx>,<cz> ..."
 EDIT-FOR-ALL.
     CALL "STRUCT-STARTS-FOR" USING WS-CX WS-CZ WS-ZERO WS-COUNT WS-LIST
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE WS-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) ":" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > WS-COUNT
         MOVE SST-STRUCT(WS-START(WS-A)) TO WS-EDIT
         STRING " " FUNCTION TRIM(WS-EDIT) "@" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE SST-CX(WS-START(WS-A)) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) "," DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         MOVE SST-CZ(WS-START(WS-A)) TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
    .

 DO-PUT.
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW.

 DO-PIECE.
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P.

 DO-JUNC.
     CALL "STRUCT-START-JUNCTION-ADD" USING WS-PR WS-X WS-Y WS-Z.

 DO-REFS.
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ.

 DO-REF-ADD.
     CALL "STRUCT-REF-ADD" USING WS-ZERO WS-ZERO2 WS-S WS-X WS-Z.

 CHECK-TEXT.
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
