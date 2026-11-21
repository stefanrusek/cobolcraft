*> Implementation test (coverage lane A; docs/protocol/54 section 4; core/src/mob-vil-index.cob, mob-vil-brain.cob): a block table whose keys carry the "minecraft:" namespace (a bell) is indexed
*> as the meeting point and read back by the key of the block at a position without the namespace.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-VIL-KEYS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY VILPOIX.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BELL                BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY-SAVED           PIC X(48).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 150.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-OUT                 PIC X(32).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:bell" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-BELL
     COMPUTE WS-IDX = CB-S-BLOCK(WS-BELL + 1) + 1
     MOVE CB-KEY(WS-IDX) TO WS-KEY-SAVED
     MOVE "minecraft:bell" TO CB-KEY(WS-IDX)
     MOVE 0 TO PX-EPOCH
     CALL "PXI-INIT"
     MOVE "test cova vil keys a bell whose key has the namespace is indexed as kind 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PX-BKIND(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-BELL
     CALL "PXI-KEY-AT" USING WS-DIM WS-X WS-Y WS-Z WS-OUT
     MOVE "test cova vil keys the key at the bell's cell is read without the namespace" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-OUT = "bell"
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE WS-KEY-SAVED TO CB-KEY(WS-IDX)
     MOVE 0 TO PX-EPOCH
     CALL "PXI-INIT"
     CALL "PXI-KIND-OF" USING WS-DIM WS-X WS-Y WS-Z WS-KIND
     MOVE "test cova vil keys with the plain key the bell is still kind 2" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-KIND TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-VIL-KEYS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
