*> The pieces of the structure start being built or placed (docs/protocol/36-structures-1 sections 5.6, 6 and 8; core/src/struct-pieces.cob, struct-place.cob). EXTERNAL, core-private,
*> memory of one generation job (a worker or the game process) only: nothing here is saved. A start is rebuilt from the seed and its chunk whenever a chunk needs it (the vanilla model of
*> 7.1 and 7.4 without chunk storage: the starts of the chunks within 8 of the chunk being generated are re-derived, each piece is placed by every chunk it touches, writing only that
*> chunk's cells), so the table is the working set of one start at a time.
*> SP-RNG is the Java LCG of the generation context (5.1); SP-XR the decoration random of the placement (8: Xoroshiro, setFeatureSeed).
*> SP-SEED is the level seed (the `capped` processor), SP-PIV-* the pivot of the start being placed (the centre x, the min y and the centre z of the first piece's box, 36-1 8), set by
*> STRUCT-PLACE-START. A template piece (SP-TYPE 100, core/src/struct-tpl-piece.cob; 36-2 6) keeps SP-T-ROW the template cache row, SP-T-X..Z the templatePosition, SP-T-ROT and SP-T-MIR the
*> placement settings' rotation and mirror (STRUCTSET.cpy codes), SP-T-PIV-* the rotation pivot, SP-T-PROC the compiled processor list (0 none), SP-T-LIQ 1 for ignore_waterlogging,
*> SP-T-KIND the structure whose hooks the piece uses (0 none) and SP-T-AUX one structure-specific number.
*> A piece: SP-TYPE the registry id of 36-1 2.4 (mineshaft: 0 corridor, 1 crossing, 2 room, 3 stairs), SP-ORIENT -1 none or the 2D data value 0 south, 1 west, 2 north, 3 east (6.7),
*> SP-DEPTH the genDepth, SP-MST the mineshaft type, SP-F1 to SP-F4 the type-specific fields (corridor: has rails, spider corridor, spider placed, sections; crossing: two floored, direction),
*> SP-ENT-FIRST and SP-ENT-N the run of the room's entrance boxes in SP-ENTRANCE.
 78 SP-MAX                VALUE 1024.
 78 SP-ENT-MAX            VALUE 256.
 01 STRUCT-PIECES EXTERNAL.
    05 SP-COUNT            BINARY-LONG.
    05 SP-LOST             BINARY-LONG.
    05 SP-ENT-COUNT        BINARY-LONG.
    05 SP-RNG              BINARY-DOUBLE UNSIGNED.
    05 SP-XR-LO            BINARY-DOUBLE UNSIGNED.
    05 SP-XR-HI            BINARY-DOUBLE UNSIGNED.
    05 SP-SEED             BINARY-DOUBLE.
    05 SP-PIV-X            BINARY-LONG.
    05 SP-PIV-Y            BINARY-LONG.
    05 SP-PIV-Z            BINARY-LONG.
    05 SP-WBOX.
       COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SW-==.
    05 SP-PIECE OCCURS 1024 TIMES.
       10 SP-TYPE          BINARY-LONG.
       10 SP-ORIENT        BINARY-LONG.
       10 SP-DEPTH         BINARY-LONG.
       10 SP-MST           BINARY-LONG.
       10 SP-F1            BINARY-LONG.
       10 SP-F2            BINARY-LONG.
       10 SP-F3            BINARY-LONG.
       10 SP-F4            BINARY-LONG.
       10 SP-ENT-FIRST     BINARY-LONG.
       10 SP-ENT-N         BINARY-LONG.
       10 SP-T-ROW         BINARY-LONG.
       10 SP-T-X           BINARY-LONG.
       10 SP-T-Y           BINARY-LONG.
       10 SP-T-Z           BINARY-LONG.
       10 SP-T-ROT         BINARY-LONG.
       10 SP-T-MIR         BINARY-LONG.
       10 SP-T-PIV-X       BINARY-LONG.
       10 SP-T-PIV-Y       BINARY-LONG.
       10 SP-T-PIV-Z       BINARY-LONG.
       10 SP-T-PROC        BINARY-LONG.
       10 SP-T-KIND        BINARY-LONG.
       10 SP-T-LIQ         BINARY-LONG.
       10 SP-T-AUX         BINARY-LONG.
       10 SP-BOX.
          COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SP-==.
    05 SP-ENTRANCE OCCURS 256 TIMES.
       COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==SE-==.
