*> Acceptance test of MonumentBuilding.postProcess (docs/protocol/36-structures-6-ocean.md section 5.7, with the elder guardians of 5.10; core/src/struct-mon-build.cob MON-POST): six monuments (four directions of the
*> start chunk (0, 0) of world seed 12345, and two others with negative and positive start chunks) are drawn over the 25 chunk windows around the start, each window by its own pass with its own placement
*> random, and every window is compared (by checksum) with the model of core/tests/fixtures/gen_monument.py (the water clearing, the wings, the archs, the walls, the foundation columns, the stepped ring and the
*> children, core/tests/MONCASES.cpy). The window starts as a pattern of stone, ice, packed ice and blue ice (core/tests/MONTEST.cpy), so the keep rule of the water clearing and the stop of the foundation
*> columns on the solid layer at y 30 are part of the comparison. A monument asks for exactly three elder guardians (5.10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY GENENT.
 COPY MONCASES.
 01 WS-CASE                BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-OK                  BINARY-LONG.
 01 WS-EH                  BINARY-DOUBLE.
 01 WS-EN                  BINARY-LONG.
 01 WS-D                   PIC 9.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-CS                  PIC -999.
 01 WS-CS2                 PIC -999.
 01 WS-NAME                PIC X(160).
 01 WS-ORIENT              BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
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
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > MC-BUILDS
         PERFORM RUN-CASE
     END-PERFORM
     GOBACK.

 RUN-CASE.
     MOVE MC-B-CX(WS-CASE) TO WS-CX
     MOVE MC-B-CZ(WS-CASE) TO WS-CZ
     COMPUTE WS-ORIENT = FUNCTION MOD(MC-B-DIR(WS-CASE) + 2, 4)
     COMPUTE WS-X0 = WS-CX * 16 - 29
     COMPUTE WS-Z0 = WS-CZ * 16 - 29
     COMPUTE WS-X1 = WS-X0 + 57
     COMPUTE WS-Z1 = WS-Z0 + 57
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     CALL "SPB-RESET"
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     MOVE MC-B-SEED(WS-CASE) TO SP-SEED
     MOVE 0 TO WS-OK WS-EH WS-EN WS-K
     PERFORM VARYING WS-IX FROM -2 BY 1 UNTIL WS-IX > 2
         PERFORM VARYING WS-IZ FROM -2 BY 1 UNTIL WS-IZ > 2
             ADD 1 TO WS-K
             COMPUTE WS-SEED = 1100 + (WS-IX + 2) * 5 + WS-IZ + 2
             COMPUTE WS-WX = WS-CX + WS-IX
             COMPUTE WS-WZ = WS-CZ + WS-IZ
             CALL "MT-WINDOW" USING WS-WX WS-WZ
             CALL "MT-SEED" USING WS-SEED
             MOVE 0 TO GEL-COUNT GEL-LOST
             CALL "MON-POST" USING WS-ROW
             CALL "MT-HASH" USING WS-WX WS-WZ WS-HASH
             CALL "MT-ELDER-HASH" USING WS-EH WS-EN
             MOVE MC-B-HASH(WS-CASE, WS-K) TO WS-WANT
             IF WS-HASH = WS-WANT
                 ADD 1 TO WS-OK
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE MC-B-DIR(WS-CASE) TO WS-D
     MOVE WS-CX TO WS-CS
     MOVE WS-CZ TO WS-CS2
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.7 seed " MC-B-SEED(WS-CASE) " start chunk " WS-CS "," WS-CS2 " direction " WS-D ": the 25 windows are the model's" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE MC-B-ELDER-HASH(WS-CASE) TO WS-WANT
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.10 seed " MC-B-SEED(WS-CASE) " start chunk " WS-CS "," WS-CS2 " direction " WS-D ": the three elder guardians are asked for at the model's cells" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-EN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-NAME
     STRING "acceptance US12 36-6§5.10 seed " MC-B-SEED(WS-CASE) " start chunk " WS-CS "," WS-CS2 " direction " WS-D ": their cells are the model's" DELIMITED BY SIZE INTO WS-NAME
     MOVE WS-NAME TO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-EH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-STRUCT-36-6-5-7.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
