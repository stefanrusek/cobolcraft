*> Acceptance test of the geometry of the building's own parts (docs/protocol/36-structures-6-ocean.md section 5.9; core/src/struct-mon-build.cob MONP-WINGS, MONP-ARCHS, MONP-ENTRANCE, MONP-ROOF, MONP-LOWER, MONP-MIDDLE,
*> MONP-UPPER): the two wings, the entrance archs, the entrance wall, the roof and the lower, middle and upper walls of the building of start chunk (0, 0) in each of the four directions, alone (no water
*> clearing, no foundation, no children), over the 25 chunk windows around it with the guard chunkIntersects of every section, compared (by checksum) with the model of core/tests/fixtures/gen_monument.py, which
*> reads the rows of the document's tables and writes the loops of the text (core/tests/MONCASES.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY MONCASES.
 01 WS-CASE                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-OK                  BINARY-LONG.
 01 WS-D                   PIC 9.
 01 WS-NAME                PIC X(160).
 01 WS-ORIENT              BINARY-LONG.
 01 WS-X0                  BINARY-LONG VALUE -29.
 01 WS-Z0                  BINARY-LONG VALUE -29.
 01 WS-X1                  BINARY-LONG VALUE 28.
 01 WS-Z1                  BINARY-LONG VALUE 28.
 01 WS-Y0                  BINARY-LONG VALUE 39.
 01 WS-Y1                  BINARY-LONG VALUE 61.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 38.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 4
         MOVE MC-Q-DIR(WS-CASE) TO WS-D
         COMPUTE WS-ORIENT = FUNCTION MOD(MC-Q-DIR(WS-CASE) + 2, 4)
         CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
         CALL "SPB-RESET"
         CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
         MOVE 0 TO WS-OK WS-K
         PERFORM VARYING WS-IX FROM -2 BY 1 UNTIL WS-IX > 2
             PERFORM VARYING WS-IZ FROM -2 BY 1 UNTIL WS-IZ > 2
                 ADD 1 TO WS-K
                 MOVE WS-IX TO WS-WX
                 MOVE WS-IZ TO WS-WZ
                 CALL "MT-WINDOW" USING WS-WX WS-WZ
                 CALL "MONP-BLOCKS"
                 MOVE WS-ROW TO MP-ROW
                 MOVE 0 TO MP-XOFF MP-DESIGN MP-PILLAR
                 CALL "MONP-WINGS"
                 CALL "MONP-ARCHS"
                 CALL "MONP-ENTRANCE"
                 CALL "MONP-ROOF"
                 CALL "MONP-LOWER"
                 CALL "MONP-MIDDLE"
                 CALL "MONP-UPPER"
                 CALL "MT-HASH" USING WS-WX WS-WZ WS-HASH
                 MOVE MC-Q-HASH(WS-CASE, WS-K) TO WS-WANT
                 IF WS-HASH = WS-WANT
                     ADD 1 TO WS-OK
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO WS-NAME
         STRING "acceptance US12 36-6§5.9 Geometry of the building's own parts: direction " WS-D ", the 25 windows are the model's" DELIMITED BY SIZE INTO WS-NAME
         MOVE WS-NAME TO TL-CASE
         MOVE 25 TO TL-EXPECTED-N
         MOVE WS-OK TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     GOBACK.

 END PROGRAM TEST-STRUCT-36-6-5-9.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
