*> Implementation test of the End's surface rule (core/src/end-38.cob; T1731, T1732; docs/protocol/38-end.md section 6): the rule yields end_stone for
*> every position, and the surface pass changes no block of a chunk made by END-GEN-CHUNK.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY END.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MARKER              BINARY-LONG.
 01 WS-CHUNK               PIC X(304640).
 01 WS-COPY                PIC X(196608).
 01 WS-STATE               BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 0.
 01 WS-V                   FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM END-TABLES
     CALL "END-SURFACE-STATE" USING WS-STATE
     MOVE "acceptance US12 38§6 Surface rule `minecraft:end` yields end_stone" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     MOVE CE-STATES TO WS-COPY
     CALL "END-SURFACE" USING WS-CHUNK
     MOVE 0 TO WS-SAME
     IF CE-STATES = WS-COPY
         MOVE 1 TO WS-SAME
     END-IF
     MOVE "acceptance US12 38§6 Surface rule `minecraft:end` the surface pass changes no block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 COPY ENDTEST.
