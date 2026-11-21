*> Implementation test of the biome table of the open set (core/copy/CBLOCKS.cpy CORE-BIOMES; docs/protocol/10 section 7.8 lists
*> 67 biomes): the table holds at least 67 entries and the 67th is kept apart from the 64th (the subscript check of a 64 entry table aborts).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BIOME-TABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-TEXT                PIC X(8).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 67 TO CBI-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 67
         MOVE WS-I TO WS-TEXT
         MOVE WS-TEXT TO CBI-KEY(WS-I)
         MOVE WS-I TO CBI-KEY-LENGTH(WS-I)
         MOVE 1 TO CBI-PRECIPITATION(WS-I)
     END-PERFORM
     MOVE "test biome table the 67th entry is its own and the 64th is intact" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CBI-KEY-LENGTH(67) * 1000 + CBI-KEY-LENGTH(64)
     MOVE 67064 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BIOME-TABLE.
