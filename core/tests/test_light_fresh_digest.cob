*> Equivalence test (lane perfsteady): LIGHT-FRESH looked at every cell of the four borders of a chunk (4 x 16 x 384 cells, several decimal computations a cell: 20 to 40 ms a chunk, of the
*> 40 to 180 ms that a superflat chunk took to be made and lit) for light in the neighbouring chunks; it leaves out a face whose neighbour is not there or holds no block light at all.
*> The block light of 3 x 3 chunks round the player, with 50 emitters (glowstone, torches) planted at drawn places over 56 x 56 blocks (the borders of the chunks among them), is made
*> by LIGHT-CHUNK again after all nine are marked unlit: the CRC-32 of the nine block light tables is the value taken before the change (the digest). The relight is timed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-FRESH-DIGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CELLS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEYS.
    05 WS-KEY              PIC X(112) OCCURS 2 TIMES.
 01 WS-STATES.
    05 WS-STATE-OF         BINARY-LONG OCCURS 2 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CENTER              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 31337.
 01 WS-PICK                BINARY-LONG.
 01 WS-CRC                 BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-PTR                 USAGE POINTER.
 01 WS-LEN                 BINARY-DOUBLE VALUE 53248.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-LIT                 BINARY-LONG VALUE 0.
 01 WS-E                   PIC Z(19)9.
 01 WS-EXPECT              PIC X(24) VALUE "96070718".
 01 WS-ENV                 PIC X(8).
 01 WS-EMITTERS            BINARY-LONG VALUE 50.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "LF_EMITTERS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-EMITTERS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "T" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:glowstone" TO WS-KEY(1)
     MOVE "minecraft:torch" TO WS-KEY(2)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         CALL "BLOCKS-STATE-OF" USING WS-KEY(WS-I) WS-PAIRS WS-STATE-OF(WS-I)
     END-PERFORM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-EMITTERS
         PERFORM DRAW
         COMPUTE WS-X = WS-CX * 16 - 20 + FUNCTION MOD(WS-PICK, 56)
         PERFORM DRAW
         COMPUTE WS-Z = WS-CZ * 16 - 20 + FUNCTION MOD(WS-PICK, 56)
         PERFORM DRAW
         COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 3 + FUNCTION MOD(WS-PICK, 14)
         PERFORM DRAW
         COMPUTE WS-DX = 1 + FUNCTION MOD(WS-PICK, 2)
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OF(WS-DX)
     END-PERFORM
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-X WS-Z WS-ROW
             IF WS-ROW > 0
                 MOVE 0 TO CK-LIT(WS-ROW)
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-CENTER
     CALL STATIC "clock" RETURNING WS-T0
     CALL "LIGHT-CHUNK" USING WS-CENTER
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     PERFORM VARYING WS-DZ FROM -1 BY 1 UNTIL WS-DZ > 1
         PERFORM VARYING WS-DX FROM -1 BY 1 UNTIL WS-DX > 1
             COMPUTE WS-X = WS-CX + WS-DX
             COMPUTE WS-Z = WS-CZ + WS-DZ
             CALL "WORLD-FIND" USING WS-DIM WS-X WS-Z WS-ROW
             IF WS-ROW > 0
                 ADD 1 TO WS-LIT
                 SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
                 SET WS-PTR TO ADDRESS OF CE-BLOCK-LIGHTS
                 CALL STATIC "crc32" USING BY VALUE WS-CRC BY VALUE WS-PTR BY VALUE WS-LEN RETURNING WS-CRC
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-CRC TO WS-E
     DISPLAY "DIGEST block light " FUNCTION TRIM(WS-E) " chunks " WS-LIT
     MOVE WS-US TO WS-E
     DISPLAY "PERF LIGHT-CHUNK of 3 x 3 chunks us " FUNCTION TRIM(WS-E)
     MOVE "perfsteady: the block light of 3 x 3 chunks with 50 emitters is that taken before the change (CRC-32 of the nine tables)" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-CRC TO WS-E
     MOVE FUNCTION TRIM(WS-E) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "perfsteady: nine chunks were loaded round the player" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-LIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768)
     .
 END PROGRAM TEST-LIGHT-FRESH-DIGEST.
 COPY CORETEST.
 COPY MOBSPTEST.
