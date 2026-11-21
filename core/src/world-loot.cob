*> The loot data of a world's content set (T0436/T0437 hook; docs/protocol/26-loot-and-predicates.md section 1; world-open, core/src/api.cob).
*> WORLD-LOOT-OPEN USING world type (PIC X(10): standard, cobolcraft or debug), generated directory (PIC X(1024), CS-GENERATED-DIR), status
*> out (BINARY-LONG: CT-OK, or CT-BAD-DATA when a table, predicate or modifier file failed its shape; the errors are on standard error):
*> it frees the shape store (SHAPE-FREE: a world open is the first loader of the store, so a second open never holds the tables of the
*> first) and, for a standard or debug set, loads <generated directory>/vanilla-data (the folder that holds data/, where the registries and
*> tags of the same set are read) with LOOT-LOAD. A cobolcraft set loads nothing: its built-in layer has no loot tables (every built-in block
*> is noLootTable), so BLOCK-DROPS finds no table and drops the stand-in yield (GI-BLOCK-YIELD). A failed load leaves nothing loaded, which is
*> the same stand-in yield: the caller logs and goes on (a world is playable without drops from tables).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LOOT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROOT                PIC X(1100).
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(10).
 01 L-DIR                  PIC X(1024).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIR L-STATUS.
     CALL "SHAPE-FREE"
     MOVE CT-OK TO L-STATUS
     IF L-TYPE = "standard" OR L-TYPE = "debug"
         MOVE SPACES TO WS-ROOT
         STRING FUNCTION TRIM(L-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
         CALL "LOOT-LOAD" USING WS-ROOT L-STATUS
     END-IF
     GOBACK.
 END PROGRAM WORLD-LOOT-OPEN.
