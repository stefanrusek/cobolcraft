*> Implementation test of client/src/state-tables.cob (STATE-TABLES-BUILD, STATE-TABLES-ENSURE; plan R-M):
*> the per-state opacity and block tables of the mesher are built once, from the stand-in table with no
*> content set open, from the cobolcraft set (19 states), and from the standard block table (every
*> state through CONTENT-BLOCK-OF-STATE: air, leaves, glass, slabs, stairs and water do not occlude;
*> stone and the grass block do); a built table is not built again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STATE-TABLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-E                   PIC Z(5)9.
 01 WS-KEYS.
    05 FILLER              PIC X(12) VALUE "stone".
    05 FILLER              PIC X(12) VALUE "grass_block".
    05 FILLER              PIC X(12) VALUE "oak_leaves".
    05 FILLER              PIC X(12) VALUE "glass".
    05 FILLER              PIC X(12) VALUE "oak_slab".
    05 FILLER              PIC X(12) VALUE "oak_stairs".
    05 FILLER              PIC X(12) VALUE "water".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY-NAME         PIC X(12) OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "state tables are not built after CL-INIT" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE ST-READY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE "state tables with no set open: 18 stand-in states, greystone (2) and cardstack opaque, void "
         & "and lucite (12) not, lucite is block 7" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 18 0 1 1 0 7" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING ST-READY " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE ST-COUNT TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) " " ST-OPAQUE(1) " " ST-OPAQUE(3)
         " " ST-OPAQUE(7) " " ST-OPAQUE(13) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE ST-BLOCK(13) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 5 TO ST-COUNT
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE "state tables a built table is not built again" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     MOVE ST-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "STATE-TABLES-BUILD" USING CLIENT-STATE
     MOVE "state tables from the cobolcraft set: its 19 states, the crafting bench (18) opaque, lucite "
         & "(12) not and block 7, void not" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "19 1 0 7 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE ST-COUNT TO WS-E
     STRING FUNCTION TRIM(WS-E) " " ST-OPAQUE(19) " " ST-OPAQUE(13) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE ST-BLOCK(13) TO WS-E
     STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-E) " " ST-OPAQUE(1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"

*>   The standard block table needs no packs: the set is marked open over it (the registries are not
*>   needed to look blocks up).
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL "STATE-TABLES-BUILD" USING CLIENT-STATE
     MOVE "state tables from the standard table: one row for every state of the set" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-STATE-COUNT TO TL-EXPECTED-N
     MOVE ST-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE WS-KEY-NAME(WS-I) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
         STRING FUNCTION TRIM(TL-OBSERVED) ST-OPAQUE(WS-STATE + 1) DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-PERFORM
     STRING FUNCTION TRIM(TL-OBSERVED) ST-OPAQUE(1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "state tables stone and the grass block are opaque; leaves, glass, slabs, stairs, water and "
         & "air are not" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "11000000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "state tables the block of a state is its block id" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-ID TO TL-EXPECTED-N
     MOVE ST-BLOCK(WS-STATE + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "grass_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     MOVE "state tables the name of a minecraft block of the set is kept without its namespace "
         & "(the tint sources key on it), under its block id + 1" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "grass_block" TO TL-EXPECTED
     MOVE ST-BLOCK-NAME(WS-ID + 1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fluids (29a section 1.2): water is block states 89 to 104 (level 0 to 15), lava 105 to 120; a block that is always
*>   wet (kelp) holds water and keeps its own model (3); stone holds none.
     MOVE "kelp" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE SPACES TO TL-OBSERVED
     STRING ST-FLUID(90) " " ST-LEVEL(93) " " ST-FLUID(106) " " ST-LEVEL(114) " " ST-FLUID(WS-STATE + 1) " "
         ST-FLUID(2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "state tables the fluid of a state: water source 1, water level 3 is level 03, lava source 2, lava level 8 "
         & "is 08, kelp holds water with a model (3), air none" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 03 2 08 3 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     STOP RUN.
 END PROGRAM TEST-STATE-TABLES.
