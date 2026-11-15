*> Implementation test of the features of the End (core/src/end-38c.cob; T1735, T1736; docs/protocol/38-end.md section 8 with the engines of
*> 35-worldgen-features-7 sections 8 to 10): the spike list and its key for seeds 0 and 1 (the table of 8.2), the island disc counts (10.1), the
*> platform split over chunks (6, -1) and (6, 0) (10.2), the gateway (10.4), a guarded pillar with cage, bedrock cap, fire and crystal (8.2), a chorus
*> plant (9), an island (10.1) and the podium (10.3), written into the level of one chunk (FL-OPEN); needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY ENDSPIKE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-SKIP                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-N                   BINARY-LONG.
 01 WS-CHUNK               PIC X(304640).
 01 WS-PTR                 USAGE POINTER.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MINY                BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LOOKFOR             BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-YHI                 BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-END-STONE         BINARY-LONG.
 01 WS-S-OBSIDIAN          BINARY-LONG.
 01 WS-S-BEDROCK           BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-S-FIRE              BINARY-LONG.
 01 WS-S-GATEWAY           BINARY-LONG.
 01 WS-S-PORTAL            BINARY-LONG.
 01 WS-S-DEAD              BINARY-LONG.
 01 WS-B-PLANT             BINARY-LONG.
 01 WS-B-FLOWER            BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY112              PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-ED                  PIC -(5)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-SEED
     CALL "END-SPIKE-KEY" USING WS-SEED WS-N
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike key" TO TL-CASE
     MOVE 20792 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "END-SPIKES" USING WS-SEED SPIKE-LIST
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 0 centre x" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     MOVE SP-CX(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 0 centre z" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-CZ(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 0 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 0 height" TO TL-CASE
     MOVE 94 TO TL-EXPECTED-N
     MOVE SP-H(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 0 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 1 centre x" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE SP-CX(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 1 centre z" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE SP-CZ(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 1 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 1 height" TO TL-CASE
     MOVE 91 TO TL-EXPECTED-N
     MOVE SP-H(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 1 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 2 centre x" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SP-CX(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 2 centre z" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE SP-CZ(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 2 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 2 height" TO TL-CASE
     MOVE 79 TO TL-EXPECTED-N
     MOVE SP-H(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 2 guarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-G(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 3 centre x" TO TL-CASE
     MOVE -13 TO TL-EXPECTED-N
     MOVE SP-CX(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 3 centre z" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE SP-CZ(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 3 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 3 height" TO TL-CASE
     MOVE 97 TO TL-EXPECTED-N
     MOVE SP-H(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 3 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 4 centre x" TO TL-CASE
     MOVE -34 TO TL-EXPECTED-N
     MOVE SP-CX(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 4 centre z" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE SP-CZ(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 4 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 4 height" TO TL-CASE
     MOVE 85 TO TL-EXPECTED-N
     MOVE SP-H(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 4 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 5 centre x" TO TL-CASE
     MOVE -42 TO TL-EXPECTED-N
     MOVE SP-CX(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 5 centre z" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE SP-CZ(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 5 radius" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE SP-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 5 height" TO TL-CASE
     MOVE 103 TO TL-EXPECTED-N
     MOVE SP-H(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 5 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 6 centre x" TO TL-CASE
     MOVE -34 TO TL-EXPECTED-N
     MOVE SP-CX(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 6 centre z" TO TL-CASE
     MOVE -25 TO TL-EXPECTED-N
     MOVE SP-CZ(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 6 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 6 height" TO TL-CASE
     MOVE 76 TO TL-EXPECTED-N
     MOVE SP-H(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 6 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 7 centre x" TO TL-CASE
     MOVE -13 TO TL-EXPECTED-N
     MOVE SP-CX(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 7 centre z" TO TL-CASE
     MOVE -40 TO TL-EXPECTED-N
     MOVE SP-CZ(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 7 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 7 height" TO TL-CASE
     MOVE 82 TO TL-EXPECTED-N
     MOVE SP-H(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 7 guarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-G(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 8 centre x" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SP-CX(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 8 centre z" TO TL-CASE
     MOVE -40 TO TL-EXPECTED-N
     MOVE SP-CZ(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 8 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 8 height" TO TL-CASE
     MOVE 88 TO TL-EXPECTED-N
     MOVE SP-H(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 8 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 9 centre x" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE SP-CX(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 9 centre z" TO TL-CASE
     MOVE -25 TO TL-EXPECTED-N
     MOVE SP-CZ(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 9 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 9 height" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE SP-H(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 0 spike 9 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SEED
     CALL "END-SPIKE-KEY" USING WS-SEED WS-N
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike key" TO TL-CASE
     MOVE 40152 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "END-SPIKES" USING WS-SEED SPIKE-LIST
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 0 centre x" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     MOVE SP-CX(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 0 centre z" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-CZ(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 0 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 0 height" TO TL-CASE
     MOVE 85 TO TL-EXPECTED-N
     MOVE SP-H(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 0 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 1 centre x" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE SP-CX(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 1 centre z" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE SP-CZ(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 1 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 1 height" TO TL-CASE
     MOVE 94 TO TL-EXPECTED-N
     MOVE SP-H(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 1 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 2 centre x" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SP-CX(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 2 centre z" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE SP-CZ(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 2 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 2 height" TO TL-CASE
     MOVE 76 TO TL-EXPECTED-N
     MOVE SP-H(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 2 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 3 centre x" TO TL-CASE
     MOVE -13 TO TL-EXPECTED-N
     MOVE SP-CX(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 3 centre z" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE SP-CZ(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 3 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 3 height" TO TL-CASE
     MOVE 82 TO TL-EXPECTED-N
     MOVE SP-H(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 3 guarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-G(4) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 4 centre x" TO TL-CASE
     MOVE -34 TO TL-EXPECTED-N
     MOVE SP-CX(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 4 centre z" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE SP-CZ(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 4 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 4 height" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE SP-H(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 4 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 5 centre x" TO TL-CASE
     MOVE -42 TO TL-EXPECTED-N
     MOVE SP-CX(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 5 centre z" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE SP-CZ(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 5 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 5 height" TO TL-CASE
     MOVE 91 TO TL-EXPECTED-N
     MOVE SP-H(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 5 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(6) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 6 centre x" TO TL-CASE
     MOVE -34 TO TL-EXPECTED-N
     MOVE SP-CX(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 6 centre z" TO TL-CASE
     MOVE -25 TO TL-EXPECTED-N
     MOVE SP-CZ(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 6 radius" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE SP-R(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 6 height" TO TL-CASE
     MOVE 103 TO TL-EXPECTED-N
     MOVE SP-H(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 6 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(7) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 7 centre x" TO TL-CASE
     MOVE -13 TO TL-EXPECTED-N
     MOVE SP-CX(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 7 centre z" TO TL-CASE
     MOVE -40 TO TL-EXPECTED-N
     MOVE SP-CZ(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 7 radius" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE SP-R(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 7 height" TO TL-CASE
     MOVE 88 TO TL-EXPECTED-N
     MOVE SP-H(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 7 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(8) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 8 centre x" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE SP-CX(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 8 centre z" TO TL-CASE
     MOVE -40 TO TL-EXPECTED-N
     MOVE SP-CZ(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 8 radius" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE SP-R(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 8 height" TO TL-CASE
     MOVE 97 TO TL-EXPECTED-N
     MOVE SP-H(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 8 guarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SP-G(9) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 9 centre x" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     MOVE SP-CX(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 9 centre z" TO TL-CASE
     MOVE -25 TO TL-EXPECTED-N
     MOVE SP-CZ(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 9 radius" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SP-R(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 9 height" TO TL-CASE
     MOVE 79 TO TL-EXPECTED-N
     MOVE SP-H(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified seed 1 spike 9 guarded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SP-G(10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT     MOVE -1 TO WS-SEED
     CALL "END-SPIKE-KEY" USING WS-SEED WS-N
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified spike key of seed -1 is a value 0 to 65535" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 0 AND WS-N <= 65535
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED
     MOVE 6.0 TO WS-R
     MOVE 145 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 5.5 TO WS-R
     MOVE 137 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 5.0 TO WS-R
     MOVE 109 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 4.5 TO WS-R
     MOVE 97 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 4.0 TO WS-R
     MOVE 77 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 3.5 TO WS-R
     MOVE 69 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 3.0 TO WS-R
     MOVE 45 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 2.5 TO WS-R
     MOVE 37 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 2.0 TO WS-R
     MOVE 25 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 1.5 TO WS-R
     MOVE 21 TO WS-WANT
     PERFORM CHECK-DISC
     MOVE 1.0 TO WS-R
     MOVE 9 TO WS-WANT
     PERFORM CHECK-DISC
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-PAIRS
     MOVE "stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-STONE
     MOVE "end_stone" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-END-STONE
     MOVE "obsidian" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-OBSIDIAN
     MOVE "bedrock" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-BEDROCK
     MOVE "air" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-AIR
     MOVE "fire" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-FIRE
     MOVE "end_gateway" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-GATEWAY
     MOVE "end_portal" TO WS-KEY
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-PORTAL
*>   10.2 the platform of the placed feature: chunk (6, 0) takes z 0 to 2, chunk (6, -1) takes z -2 and -1
     MOVE 6 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 100 TO WS-X
     MOVE 49 TO WS-Y
     MOVE 0 TO WS-Z
     MOVE 0 TO WS-DROP
     CALL "END-PLATFORM-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-DROP WS-DROPPED
     MOVE WS-S-OBSIDIAN TO WS-LOOKFOR
     MOVE 48 TO WS-YLO
     MOVE 48 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified platform in chunk (6, 0) has 15 obsidian at y 48" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-CX
     MOVE -1 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 100 TO WS-X
     MOVE 49 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "END-PLATFORM-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-DROP WS-DROPPED
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified platform in chunk (6, -1) has 10 obsidian at y 48" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-X
     MOVE 48 TO WS-Y
     MOVE -2 TO WS-Z
     MOVE WS-S-OBSIDIAN TO WS-WANT
     MOVE "platform corner (100, 48, -2) is obsidian" TO WS-KEY112
     PERFORM CHECK-STATE
*>   10.4 the gateway: 45 cells, 12 bedrock, the gateway block in the middle
     MOVE 6 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 100 TO WS-X
     MOVE 80 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "END-GATEWAY-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z
     MOVE WS-S-BEDROCK TO WS-LOOKFOR
     MOVE 78 TO WS-YLO
     MOVE 82 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified gateway has 12 bedrock blocks" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-X
     MOVE 80 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE WS-S-GATEWAY TO WS-WANT
     MOVE "gateway block in the middle" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 82 TO WS-Y
     MOVE WS-S-BEDROCK TO WS-WANT
     MOVE "gateway top cap (100, 82, 8) is bedrock" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 101 TO WS-X
     MOVE 81 TO WS-Y
     MOVE "gateway (101, 81, 8) is bedrock" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 82 TO WS-Y
     MOVE WS-S-AIR TO WS-WANT
     MOVE "gateway (101, 82, 8) is air" TO WS-KEY112
     PERFORM CHECK-STATE
*>   8.2 the guarded pillar of seed 0 spike 2 (centre (12, 39), radius 2, height 79) in chunk (0, 2)
     MOVE 0 TO WS-CX
     MOVE 2 TO WS-CZ
     PERFORM OPEN-CHUNK
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 61 * 256
         MOVE WS-S-STONE TO CE-STATE(WS-CELL)
     END-PERFORM
     MOVE 0 TO WS-SEED
     MOVE 5 TO WS-U
     CALL "WGR-SET-SEED" USING WS-XR WS-U
     MOVE 0 TO WS-X
     MOVE 32 TO WS-Z
     CALL "END-SPIKE-PLACE" USING WS-MODE WS-DIM WS-X WS-Z WS-SEED WS-XR CRYSTAL-LIST
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chunk (0, 2) makes one crystal" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified crystal block position is (12, 80, 39)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 12 * 1000000 + 80 * 1000 + 39
     COMPUTE TL-OBSERVED-N = EC-X(1) * 1000000 + EC-Y(1) * 1000 + EC-Z(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified crystal yaw is in [0, 360)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EC-YAW(1) >= 0 AND EC-YAW(1) < 360
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-S-OBSIDIAN TO WS-LOOKFOR
     MOVE 70 TO WS-YLO
     MOVE 70 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified pillar layer of radius 2 has 21 cells" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-X
     MOVE 78 TO WS-Y
     MOVE 39 TO WS-Z
     MOVE WS-S-OBSIDIAN TO WS-WANT
     MOVE "pillar top y 78 is obsidian" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 79 TO WS-Y
     MOVE WS-S-BEDROCK TO WS-WANT
     MOVE "cap y 79 is bedrock" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 80 TO WS-Y
     MOVE WS-S-FIRE TO WS-WANT
     MOVE "fire at y 80" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 14 TO WS-X
     MOVE 79 TO WS-Y
     MOVE "iron_bars" TO WS-KEY
     MOVE "east=false,north=true,south=true,waterlogged=false,west=false" TO WS-PAIRS
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "cage wall (14, 79, 39) has bars north and south" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 12 TO WS-X
     MOVE 82 TO WS-Y
     MOVE "east=true,north=true,south=true,waterlogged=false,west=true" TO WS-PAIRS
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "cage roof (12, 82, 39) connects every side" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 14 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 41 TO WS-Z
     MOVE WS-S-STONE TO WS-WANT
     MOVE "outside the pillar at y 60 stays" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 70 TO WS-Y
     MOVE WS-S-AIR TO WS-WANT
     MOVE "outside the pillar above y 65 is air" TO WS-KEY112
     PERFORM CHECK-STATE
*>   a chunk that does not hold a centre makes nothing
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     CALL "END-SPIKE-PLACE" USING WS-MODE WS-DIM WS-X WS-Z WS-SEED WS-XR CRYSTAL-LIST
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chunk (1, 2) holds no spike centre" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   9 a chorus plant on end stone
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM OPEN-CHUNK
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 61 * 256
         MOVE WS-S-END-STONE TO CE-STATE(WS-CELL)
     END-PERFORM
     MOVE "chorus_plant" TO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-B-PLANT
     MOVE "chorus_flower" TO WS-KEY112
     CALL "BLOCKS-ID-OF" USING WS-KEY112 WS-B-FLOWER
     MOVE "chorus_flower" TO WS-KEY
     MOVE "age=5" TO WS-PAIRS
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-S-DEAD
     MOVE 7 TO WS-X
     MOVE 61 TO WS-Y
     MOVE 7 TO WS-Z
     MOVE 11 TO WS-U
     CALL "WGR-SET-SEED" USING WS-XR WS-U
     CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-XR WS-RESULT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chorus plant grows on end stone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-CHORUS
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chorus plant has a trunk and exactly dead flowers at its tips" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT >= 3 AND WS-DEAD >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chorus plant stays within 7 blocks of its origin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     MOVE 120 TO WS-Y
     MOVE 7 TO WS-Z
     CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-XR WS-RESULT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chorus plant needs end stone below" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     MOVE 61 TO WS-Y
     MOVE 7 TO WS-Z
     CALL "END-CHORUS-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-XR WS-RESULT
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified chorus plant needs air at the origin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   10.1 an island of stacked discs under the origin
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 8 TO WS-X
     MOVE 60 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-U
     CALL "WGR-SET-SEED" USING WS-XR WS-U
     CALL "END-ISLAND-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-XR
     MOVE WS-S-END-STONE TO WS-LOOKFOR
     MOVE 60 TO WS-YLO
     MOVE 60 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified island top layer is a disc of radius 4, 5 or 6" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT = 77 OR WS-COUNT = 109 OR WS-COUNT = 145
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-YLO
     MOVE 59 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified island has layers below the top" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT >= 9
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 61 TO WS-YLO
     MOVE 255 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified island has nothing above the origin layer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   10.3 the podium, inactive then active
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM OPEN-CHUNK
     MOVE 8 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE 0 TO WS-DROP
     CALL "END-PODIUM-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-DROP WS-DROPPED
     MOVE WS-S-BEDROCK TO WS-LOOKFOR
     MOVE 0 TO WS-YLO
     MOVE 255 TO WS-YHI
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified inactive podium has 41 bedrock blocks" TO TL-CASE
     MOVE 41 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-S-END-STONE TO WS-LOOKFOR
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified inactive podium has 16 end stone blocks (the ring below)" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wall_torch" TO WS-KEY
     MOVE "facing=north" TO WS-PAIRS
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-WANT
     MOVE 8 TO WS-X
     MOVE 66 TO WS-Y
     MOVE 7 TO WS-Z
     MOVE "podium torch north of the pillar top faces north" TO WS-KEY112
     PERFORM CHECK-STATE
     MOVE 1 TO WS-DROP
     MOVE 8 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "END-PODIUM-PLACE" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-DROP WS-DROPPED
     MOVE WS-S-PORTAL TO WS-LOOKFOR
     PERFORM COUNT-IN-RANGE
     MOVE "acceptance US12 38§8 Features of the End: wiring and where each is specified active podium has 20 end portal blocks" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-DISC.
     CALL "END-ISLAND-DISC" USING WS-R WS-COUNT
     MOVE SPACES TO TL-CASE
     MOVE WS-R TO WS-ED
     STRING "acceptance US12 38§8 Features of the End: wiring and where each is specified island layer of radius "
         FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-STATE.
     CALL "END-GET" USING WS-MODE WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 38§8 Features of the End: wiring and where each is specified "
         FUNCTION TRIM(WS-KEY112) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 OPEN-CHUNK.
     MOVE LOW-VALUES TO WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     SET WS-PTR TO ADDRESS OF WS-CHUNK
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MINY WS-HEIGHT WS-SEA.
 COUNT-IN-RANGE.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         COMPUTE WS-Y = (WS-CELL - 1) / 256
         IF WS-Y >= WS-YLO AND WS-Y <= WS-YHI AND CE-STATE(WS-CELL) = WS-LOOKFOR
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.
 COUNT-CHORUS.
     MOVE 0 TO WS-COUNT WS-DEAD WS-FAR
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = WS-S-END-STONE AND CE-STATE(WS-CELL) NOT = 0
             MOVE CB-S-BLOCK(CE-STATE(WS-CELL) + 1) TO WS-BLOCK
             IF WS-BLOCK = WS-B-PLANT OR WS-BLOCK = WS-B-FLOWER
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-Z = FUNCTION MOD(WS-CELL - 1, 256) / 16
                 COMPUTE WS-X = FUNCTION MOD(WS-CELL - 1, 16)
                 IF WS-X < 0 OR WS-X > 14 OR WS-Z > 14
                     ADD 1 TO WS-FAR
                 END-IF
                 IF CE-STATE(WS-CELL) = WS-S-DEAD
                     ADD 1 TO WS-DEAD
                 END-IF
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-END-38-8.

 COPY CORETEST.
 COPY PORTALTEST.
