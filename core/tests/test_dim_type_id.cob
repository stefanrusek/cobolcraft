*> Implementation test of DIM-TYPE-ID (core/src/play.cob; docs/protocol/04 section 4: the ids of synchronized-registry entries follow the order the entries are sent):
*> the dimension type id that Login and Respawn carry is the position of the row's type key in the Registry Data of minecraft:dimension_type. With no content set
*> open the table's id stands. On the generated vanilla-data (CC_GENERATED_DIR, read only; the part is skipped without the packs) the registry lists overworld, overworld_caves,
*> the_end, the_nether, so the Nether is 3 (the table says 1, the id of overworld_caves: the client then knew the Nether as a cave overworld) and the End is 2.
*> A cobolcraft set lists cobolcraft:surface and cobolcraft:sunless (0 and 1). Found through the convergence test acc_f2us12_dimensions.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DIM-TYPE-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SET-TYPE            BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-A                   PIC -(4)9.
 01 WS-B                   PIC -(4)9.
 01 WS-C                   PIC -(4)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE DIM-STANDARD-NETHER TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-A
     MOVE "dim type id given no content set open when the Nether's id is asked then the table's id 1 stands" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the cobolcraft set
     MOVE SPACES TO WS-DIR
     MOVE "content/tests/fixtures/std" TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-SET-TYPE
     CALL "CONTENT-OPEN" USING WS-SET-TYPE WS-DIR WS-STATUS
     MOVE DIM-MAIN TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-A
     MOVE DIM-SUBROUTINE TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-B
     MOVE "dim type id given the cobolcraft set when main and the subroutine are asked then the ids are 0 and 1 (surface, sunless)" TO TL-CASE
     MOVE "0 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the generated data
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "dim type id: no generated packs here, the real data part is skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-SET-TYPE
     CALL "CONTENT-OPEN" USING WS-SET-TYPE WS-DIR WS-STATUS
     MOVE DIM-STANDARD-OVERWORLD TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-A
     MOVE DIM-STANDARD-END TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-B
     MOVE DIM-STANDARD-NETHER TO WS-ROW
     CALL "DIM-TYPE-ID" USING WS-ROW WS-ID
     MOVE WS-ID TO WS-C
     MOVE "dim type id given the generated data when the overworld, the End and the Nether are asked then the ids follow the registry order: "
         & "0, 2 and 3 (overworld, overworld_caves, the_end, the_nether)" TO TL-CASE
     MOVE "0 2 3" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DIM-TYPE-ID.
