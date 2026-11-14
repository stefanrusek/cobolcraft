*> Implementation test of WORLD-DIMS-SELECT (core/src/api.cob): a standard or debug world has minecraft:overworld as its only dimension
*> (min_y -64, height 384, the standard generator) and the spawn position packet names it; a cobolcraft world keeps cobolcraft:main
*> (and the extras while the setting is on). Before this every world was opened in cobolcraft:main (256 high, the stand-in generator), so a
*> standard world had a player in a dimension of another height than the client's minecraft:overworld type and no terrain of the standard set.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-DIMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-TYPE                PIC X(10).
 01 WS-ZERO                PIC 9 VALUE 0.
 01 WS-ONE                 PIC 9 VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-E1                  PIC -(5)9.
 01 WS-E2                  PIC -(5)9.
 01 WS-E3                  PIC -(5)9.
 01 WS-E4                  PIC -(5)9.
 01 B-BYTES                PIC X(256) BASED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-DIMS-SELECT" USING WS-TYPE WS-ONE
     MOVE CW-DIM-COUNT TO WS-E1
     MOVE DM-MIN-Y(CW-DIM(1)) TO WS-E2
     MOVE DM-HEIGHT(CW-DIM(1)) TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(DM-KEY(CW-DIM(1))) " " FUNCTION TRIM(WS-E2) " "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "world dims a standard world has minecraft:overworld only, -64 and 384, extras on or off" TO TL-CASE
     MOVE "1 minecraft:overworld -64 384" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "debug" TO WS-TYPE
     CALL "WORLD-DIMS-SELECT" USING WS-TYPE WS-ZERO
     MOVE CW-DIM-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(DM-KEY(CW-DIM(1))) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "world dims a debug world has minecraft:overworld only" TO TL-CASE
     MOVE "1 minecraft:overworld" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-DIMS-SELECT" USING WS-TYPE WS-ZERO
     MOVE CW-DIM-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(DM-KEY(CW-DIM(1))) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "world dims a cobolcraft world without extras has cobolcraft:main only" TO TL-CASE
     MOVE "1 cobolcraft:main" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-DIMS-SELECT" USING WS-TYPE WS-ONE
     MOVE CW-DIM-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(DM-KEY(CW-DIM(1))) " " FUNCTION TRIM(DM-KEY(CW-DIM(2)))
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "world dims a cobolcraft world with extras has main then subroutine" TO TL-CASE
     MOVE "2 cobolcraft:main cobolcraft:subroutine" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "standard" TO WS-TYPE
     CALL "WORLD-DIMS-SELECT" USING WS-TYPE WS-ZERO
     MOVE 1.5 TO CW-SPAWN-X
     MOVE 70 TO CW-SPAWN-Y
     MOVE 2.5 TO CW-SPAWN-Z
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-SPAWN-POSITION-BUILD" USING PB-BUFFER
     SET ADDRESS OF B-BYTES TO PB-ADDR
     MOVE "world dims the spawn position packet of a standard world names minecraft:overworld" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE B-BYTES(3:19) TO TL-OBSERVED
     MOVE "minecraft:overworld" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-DIMS.
