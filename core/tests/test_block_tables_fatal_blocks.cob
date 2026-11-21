*> Fatal path of BLOCKS-CHECK-ID (T0326; constitution 5.6): a block id beyond CB-MAX-BLOCKS ends the run with
*> "FATAL block tables: more blocks than the core holds". Expected outcome: the .expect file.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-TABLES-FATAL-BLOCKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ID                  BINARY-LONG VALUE 1400.
 PROCEDURE DIVISION.
     CALL "BLOCKS-CHECK-ID" USING WS-ID
     DISPLAY "BLOCKS-CHECK-ID returned"
     STOP RUN.
 END PROGRAM TEST-BLOCK-TABLES-FATAL-BLOCKS.
