*> WORLD-RECIPES-OPEN USING world type (PIC X(10): standard, cobolcraft or debug), generated directory (PIC X(1024), CS-GENERATED-DIR),
*> status out (BINARY-LONG: CT-OK, or CT-BAD-DATA when a recipe or recipe advancement file failed; the errors are on standard error): fills the
*> recipe store RC-STORE of the world's content set. A standard or debug set loads <generated directory>/vanilla-data (the folder that holds
*> data/, where the registries and tags of the same set are read) with RECIPES-LOAD, so the recipe book, crafting and ghost-recipe fill see
*> the data pack recipes and their unlock advancements (docs/protocol/27 sections 1 to 3, 5.9; 23 section 2: "recipe" is a reloadable
*> registry that CONTENT-OPEN does not load). A cobolcraft set attaches its ten built-in recipes (BUILTIN-RECIPES-LOAD). A failed load leaves
*> the store empty: the caller logs and goes on (a world is playable without recipes).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-RECIPES-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROOT                PIC X(1100).
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(10).
 01 L-DIR                  PIC X(1024).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIR L-STATUS.
     CALL "RECIPES-FREE"
     MOVE CT-OK TO L-STATUS
     IF L-TYPE = "standard" OR L-TYPE = "debug"
         MOVE SPACES TO WS-ROOT
         STRING FUNCTION TRIM(L-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-ROOT
         CALL "RECIPES-LOAD" USING WS-ROOT L-STATUS
     ELSE
         CALL "BUILTIN-RECIPES-LOAD"
     END-IF
     GOBACK.
 END PROGRAM WORLD-RECIPES-OPEN.
