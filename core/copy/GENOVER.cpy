*> The chunk overflow of the feature stage (docs/design/world-types.md "Chunk borders"; core/src/gen-overflow.cob). A feature writes only into the chunk being generated
*> (FEATLEVEL.cpy); what it writes outside is recorded by the level as (x, y, z, state), kept by the generation job (GENJOB.cpy GJ-OV), and published by the install
*> in GEN-OVERFLOW (GO-DATA, the same layout as GJ-OV: at most GO-MAX entries, GO-LOST counts what did not fit). A worker returns it after the chunk
*> (GW-ANSWER-BYTES). WORLD-CHUNK-LOAD routes the entries of a chunk it generated (OV-ROUTE): a loaded neighbour takes them at once, for any other chunk they wait in
*> GEN-PENDING (GP-MAX entries in order of arrival, the oldest GP-DROP go when it is full, GP-LOST counts them) until that chunk is loaded (OV-TAKE). GP-FLUSH counts the
*> lit chunks that changed (CK-RESEND) and that the tick sends again (OV-FLUSH). Memory of the game process only: nothing here is saved.
 78 GO-MAX                 VALUE 1024.
 78 GP-MAX                 VALUE 8192.
 78 GP-DROP                VALUE 1024.
 01 GEN-OVERFLOW EXTERNAL.
    05 GO-DATA.
       10 GO-COUNT         BINARY-LONG.
       10 GO-LOST          BINARY-LONG.
       10 GO-ENTRY OCCURS 1024 TIMES.
          15 GO-X          BINARY-LONG.
          15 GO-Y          BINARY-LONG.
          15 GO-Z          BINARY-LONG.
          15 GO-STATE      BINARY-LONG.
 01 GEN-PENDING EXTERNAL.
    05 GP-COUNT            BINARY-LONG.
    05 GP-LOST             BINARY-LONG.
    05 GP-FLUSH            BINARY-LONG.
    05 GP-ENTRY OCCURS 8192 TIMES.
       10 GP-DIM           BINARY-LONG.
       10 GP-CX            BINARY-LONG.
       10 GP-CZ            BINARY-LONG.
       10 GP-X             BINARY-LONG.
       10 GP-Y             BINARY-LONG.
       10 GP-Z             BINARY-LONG.
       10 GP-STATE         BINARY-LONG.
