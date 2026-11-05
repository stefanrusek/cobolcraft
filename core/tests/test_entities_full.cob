*> Implementation test of the full entity table (core/src/entities.cob ENTITY-ALLOC): with every row
*> of CORE-ENTITIES in use, allocating another is fatal (FR-012: cc_fatal, exit status 1 and the line
*> "FATAL entity table: 1024 entities"; test_entities_full.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITIES-FULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CORE-MAX-ENTITIES TO EN-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-ENTITIES
         MOVE 1 TO EN-USED(WS-I)
     END-PERFORM
     CALL "ENTITY-ALLOC" USING WS-ROW
     DISPLAY "TEST test entities full table FAIL expected=fatal observed=row " WS-ROW
     STOP RUN.
 END PROGRAM TEST-ENTITIES-FULL.

 COPY CORETEST.
