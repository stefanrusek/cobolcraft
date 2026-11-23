*> StructureCheck (docs/protocol/36-structures-1-model-placement-starts.md section 7.6; core/src/struct-check.cob). EXTERNAL, core-private. SCL-* is loadedChunks: a chunk and the structures that
*> have a valid start in it with their references (SCL-REFS; the stored "no start" marker of the document is -1). SCF-* is featureChecks: the memoised answer of "could this structure be created in
*> this chunk" (SCF-VALUE 1 yes, 0 no). SCW-* is chunksWithoutStartsInStorage, emptied whenever it reaches 131072 entries (SC-WITHOUT-MAX), then the chunk asked for is added.
 78 SC-LOADED-MAX         VALUE 1024.
 78 SC-FEATURE-MAX        VALUE 1024.
 78 SC-WITHOUT-MAX        VALUE 131072.
 01 STRUCT-CHECK EXTERNAL.
    05 SCL-COUNT            BINARY-LONG.
    05 SCF-COUNT            BINARY-LONG.
    05 SCW-COUNT            BINARY-LONG.
    05 SCL-REC OCCURS 1024 TIMES.
       10 SCL-CX            BINARY-LONG.
       10 SCL-CZ            BINARY-LONG.
       10 SCL-N             BINARY-LONG.
       10 SCL-ENTRY OCCURS 8 TIMES.
          15 SCL-STRUCT     BINARY-LONG.
          15 SCL-REFS       BINARY-LONG.
    05 SCF-REC OCCURS 1024 TIMES.
       10 SCF-STRUCT        BINARY-LONG.
       10 SCF-CX            BINARY-LONG.
       10 SCF-CZ            BINARY-LONG.
       10 SCF-VALUE         BINARY-LONG.
    05 SCW-REC OCCURS 131072 TIMES.
       10 SCW-CX            BINARY-LONG.
       10 SCW-CZ            BINARY-LONG.
