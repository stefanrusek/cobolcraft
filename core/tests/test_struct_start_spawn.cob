*> Implementation test of the structure spawn overrides over the stored starts (docs/protocol/36-structures-1-model-placement-starts.md section 10 and 13.10, 13.11; core/src/struct-start-spawn.cob): the structures that
*> reference the chunk of the position are the candidates in reference order, a swamp hut (piece mode) qualifies only inside one of its piece boxes (a gap between two pieces does not, the biome's list stays: 0), a monument (full
*> mode) inside its start's box, a structure without an override entry for the category or of a kind that has none (an igloo) never, and the answer is the row of the 44-2 section 8 list of that kind and category
*> (swamp hut: monster 7, creature 8, ambient none; monument: monster 3, axolotls 4, underground water creature 5; every category of the ancient city: 9); the first qualifying structure wins; SO-LOOKUP answers
*> from the store in the overworld when no box is registered (and not in another dimension). Structure rows are built by hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTOVR.
 COPY SPAWNSEL.
 01 WS-S                   BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG VALUE 5.
 01 WS-O                   BINARY-LONG VALUE 0.
 01 WS-D                   BINARY-LONG VALUE 0.
 01 WS-J                   BINARY-LONG VALUE 0.
 01 WS-G                   BINARY-LONG VALUE 0.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KINDS.
    05 WS-K                BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "minecraft:swamp_hut" TO SDT-KEY(1)
     MOVE "minecraft:monument" TO SDT-KEY(2)
     MOVE "minecraft:igloo" TO SDT-KEY(3)
     MOVE "minecraft:ancient_city" TO SDT-KEY(4)
     MOVE "minecraft:fortress" TO SDT-KEY(5)
     MOVE "minecraft:pillager_outpost" TO SDT-KEY(6)
     MOVE "minecraft:trial_chambers" TO SDT-KEY(7)
     MOVE 0 TO SDT-ADAPT(1) SDT-ADAPT(2) SDT-ADAPT(3)
     MOVE 5 TO SDT-ADAPT(4)
     MOVE 7 TO SD-ST-COUNT
     MOVE 0 TO SO-COUNT
     CALL "STRUCT-STORE-RESET"
*>   swamp hut at chunk (0, 0): pieces (0..6, 64..68, 0..8) and (10..14, 64..68, 0..8)
     MOVE 1 TO WS-S
     MOVE 0 TO WS-PCX WS-PCZ
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 64 TO WS-Y0
     MOVE 6 TO WS-X1
     MOVE 68 TO WS-Y1
     MOVE 8 TO WS-Z1
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
     MOVE 10 TO WS-X0
     MOVE 14 TO WS-X1
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
*>   monument at chunk (0, 0): one piece (0..57, 40..60, 0..57) (it spans chunks 0 to 3)
     MOVE 2 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 40 TO WS-Y0
     MOVE 57 TO WS-X1 WS-Z1
     MOVE 60 TO WS-Y1
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
*>   an igloo at chunk (0, 0), box (0..10, 64..70, 0..10): no override kind
     MOVE 3 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 64 TO WS-Y0
     MOVE 10 TO WS-X1 WS-Z1
     MOVE 70 TO WS-Y1
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
*>   an ancient city at chunk (1, 0), terrain adaptation beard_box, one piece (20..30, -40..-30, 2..9): its start box is inflated by 12, full mode
     MOVE 4 TO WS-S
     MOVE 1 TO WS-PCX
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 20 TO WS-X0
     MOVE 2 TO WS-Z0
     MOVE -40 TO WS-Y0
     MOVE 30 TO WS-X1
     MOVE 9 TO WS-Z1
     MOVE -30 TO WS-Y1
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P
     MOVE 0 TO WS-CX WS-CZ
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ
     MOVE 1 TO WS-CX
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ
     MOVE 2 TO WS-CX
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ

*>   piece mode: inside a swamp hut piece, monster (1) and creature (2)
     MOVE 3 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE 1 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: a position inside a swamp hut piece, category monster: the swamp hut's monster list (row 7)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE 2 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: the same position, category creature: the swamp hut's creature list (row 8)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE 3 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: a category that no list of the swamp hut has (ambient): 0, the biome's list stays" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   the gap between the two pieces (x 8) does not qualify a piece-mode start
     MOVE 8 TO WS-X
     MOVE 1 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: the gap between the two swamp hut pieces (x 8) is no piece: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   full mode: the monument qualifies the whole of its box (x 8 is inside it; 12 chunks of reference: the position is in chunk 0)
     MOVE 1 TO WS-CAT
     MOVE 8 TO WS-X
     MOVE 50 TO WS-Y
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: a position inside the monument's box (full mode), monster: the monument's monster list (row 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE 4 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: the monument, category axolotls: row 4" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM CHECK
*>   a position in the chunk of the swamp hut and the monument but outside the monument's y range and the hut's pieces
     MOVE 1 TO WS-CAT
     MOVE 100 TO WS-Y
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: above every box (y 100): 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   the first candidate wins: structure 1 (the hut) is listed before the monument for chunk (0, 0); a position in both a hut piece and the monument box answers the hut
     MOVE 3 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-Y
     MOVE 64 TO WS-Y
     MOVE 45 TO WS-Y
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: a hut piece's x and z at a y only the monument covers (45): the monument qualifies, not the hut (row 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM CHECK
*>   an igloo has no override kind: its box does not answer
     MOVE 8 TO WS-X
     MOVE 66 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 66 TO WS-Y
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: inside the igloo's box and the monument's? y 66 is above the monument (60): no structure with an override qualifies (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   the ancient city's full box is inflated by 12 (terrain adaptation): x 32 is 2 beyond the piece (x 30) and inside; its list applies to every category (row 9)
     MOVE 32 TO WS-X
     MOVE -35 TO WS-Y
     MOVE 5 TO WS-Z
     MOVE 5 TO WS-CAT
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 and 5.6 spawn override: the ancient city's start box is inflated by 12: x 32 (piece to 30) qualifies, every category answers row 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE 45 TO WS-X
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: x 45 is beyond the inflated box (to 42): 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   a chunk nothing references: 0
     MOVE 500 TO WS-X
     MOVE 500 TO WS-Z
     PERFORM ASK
     MOVE "acceptance US12 36-1§10 spawn override: a chunk that no start references: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
*>   SO-LOOKUP asks the store in the overworld when no box is registered, and does not in another dimension
     MOVE 3 TO WS-X
     MOVE 65 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE 1 TO WS-CAT
     MOVE 1 TO WS-DIM
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US12 36-1§10 SO-LOOKUP in the overworld with no registered box answers from the stored starts: the swamp hut's monster list (row 7)" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE 2 TO WS-DIM
     CALL "SO-LOOKUP" USING WS-DIM WS-X WS-Y WS-Z WS-CAT WS-LIST
     MOVE "acceptance US12 36-1§10 SO-LOOKUP in another dimension does not read the stored starts: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     STOP RUN.

 ASK.
     CALL "STRUCT-SPAWN-QUERY" USING WS-X WS-Y WS-Z WS-CAT WS-LIST.

 CHECK.
     MOVE WS-LIST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-START-SPAWN.
