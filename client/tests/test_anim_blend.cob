*> The blend of ANIM-TICK (lane perfframe): an interpolated animated sprite shows, per byte, (this picture x (1000 - share) + the next picture x share) / 1000
*> (the share of the entry's time that has passed, per mille). Eight sprites of 32 x 32 pixels with three pictures of pseudo-random bytes, entries of 7, 3 and 5
*> ticks (shares like 142 and 666), are ticked over two full cycles: every byte of the cell AN-OUT and of the atlas is compared with the formula written out here
*> byte by byte, and the cost of the ticks (CPU time, C clock()) has to stay within a bound a blend by decimal arithmetic (a quarter of a millisecond a
*> thousand bytes) does not keep.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ANIM-BLEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-A                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-BYTES               BINARY-LONG VALUE 4096.
 01 WS-TICK                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-EN                  BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-SHARE               BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-CHECKED             BINARY-LONG VALUE 0.
 01 WS-SHARED              BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE VALUE 0.
 01 WS-D9                  PIC Z(8)9.
 01 WS-D9B                 PIC Z(8)9.
 01 WS-BASE-A              BINARY-LONG.
 01 WS-BASE-B              BINARY-LONG.
 01 B-ATLAS-BYTES BASED.
    05 BT-BYTE             BINARY-CHAR UNSIGNED OCCURS 268435456 TIMES.
 01 B-PIX BASED.
    05 BP-BYTE             BINARY-CHAR UNSIGNED OCCURS 268435456 TIMES.
 01 B-OUT BASED.
    05 BO-BYTE             BINARY-CHAR UNSIGNED OCCURS 268435456 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 256 TO AT-W
     MOVE 32 TO AT-H
     ALLOCATE 32768 CHARACTERS INITIALIZED RETURNING AT-ADDR
     MOVE 8 TO AN-COUNT
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 8
         MOVE WS-A TO AN-SPRITE(WS-A)
         COMPUTE AT-X(WS-A) = (WS-A - 1) * 32
         MOVE 0 TO AT-Y(WS-A)
         MOVE 32 TO AN-FRAME-W(WS-A) AN-FRAME-H(WS-A)
         MOVE 1 TO AN-INTERPOLATE(WS-A)
         MOVE 3 TO AN-ENTRIES(WS-A)
         MOVE 15 TO AN-TOTAL(WS-A)
         MOVE -1 TO AN-CUR(WS-A)
         MOVE 0 TO AN-SEQ-INDEX(WS-A, 1)
         MOVE 7 TO AN-SEQ-TIME(WS-A, 1)
         MOVE 1 TO AN-SEQ-INDEX(WS-A, 2)
         MOVE 3 TO AN-SEQ-TIME(WS-A, 2)
         MOVE 2 TO AN-SEQ-INDEX(WS-A, 3)
         MOVE 5 TO AN-SEQ-TIME(WS-A, 3)
         ALLOCATE 12288 CHARACTERS INITIALIZED RETURNING AN-PIXELS(WS-A)
         ALLOCATE 4096 CHARACTERS INITIALIZED RETURNING AN-OUT(WS-A)
         SET ADDRESS OF B-PIX TO AN-PIXELS(WS-A)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12288
             COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
             COMPUTE BP-BYTE(WS-I) = FUNCTION MOD(WS-SEED / 65536, 256)
         END-PERFORM
     END-PERFORM
*>   Two cycles of 15 ticks.
     PERFORM VARYING WS-TICK FROM 0 BY 1 UNTIL WS-TICK > 29
         COMPUTE WS-NOW = 5000000 + WS-TICK * 50
         CALL STATIC "clock" RETURNING WS-T0
         CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-US + WS-T1 - WS-T0
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 8
             PERFORM CHECK-SPRITE
         END-PERFORM
     END-PERFORM
*>   The cost alone: 200 more ticks (the picture changes every tick: the share does).
     MOVE 0 TO WS-US
     PERFORM VARYING WS-TICK FROM 30 BY 1 UNTIL WS-TICK > 229
         COMPUTE WS-NOW = 5000000 + WS-TICK * 50
         CALL STATIC "clock" RETURNING WS-T0
         CALL "ANIM-TICK" USING CLIENT-STATE WS-NOW
         CALL STATIC "clock" RETURNING WS-T1
         COMPUTE WS-US = WS-US + WS-T1 - WS-T0
     END-PERFORM
     MOVE WS-US TO WS-D9
     DISPLAY "PERF anim-tick us for 200 ticks of 8 interpolated 32 x 32 sprites: " WS-D9
     MOVE "T" TO TL-MODE
     MOVE "test anim blend: every byte of every interpolated sprite is the per-mille blend of its two pictures" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "bad 0 checked 983040" TO TL-EXPECTED
     MOVE WS-BAD TO WS-D9
     MOVE WS-CHECKED TO WS-D9B
     STRING "bad " FUNCTION TRIM(WS-D9) " checked " FUNCTION TRIM(WS-D9B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test anim blend: shares other than 0 were shown (the blend ran)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SHARED > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test anim blend: 200 ticks of 8 blended 32 x 32 sprites take less than 150 ms of CPU time" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-US < 150000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The sprite WS-A against the formula: picture and share from the tick, the bytes of AN-OUT and of the atlas cell.
 CHECK-SPRITE.
     COMPUTE WS-POS = FUNCTION MOD(WS-TICK, 15)
     MOVE 0 TO WS-START
     MOVE 1 TO WS-EN
     PERFORM UNTIL WS-POS < WS-START + AN-SEQ-TIME(WS-A, WS-EN)
         ADD AN-SEQ-TIME(WS-A, WS-EN) TO WS-START
         ADD 1 TO WS-EN
     END-PERFORM
     COMPUTE WS-NEXT = FUNCTION MOD(WS-EN, 3) + 1
     COMPUTE WS-SHARE = (WS-POS - WS-START) * 1000 / AN-SEQ-TIME(WS-A, WS-EN)
     COMPUTE WS-KEEP = 1000 - WS-SHARE
     IF WS-SHARE > 0
         ADD 1 TO WS-SHARED
     END-IF
     SET ADDRESS OF B-PIX TO AN-PIXELS(WS-A)
     SET ADDRESS OF B-OUT TO AN-OUT(WS-A)
     SET ADDRESS OF B-ATLAS-BYTES TO AT-ADDR
     MOVE AN-SEQ-INDEX(WS-A, WS-EN) TO WS-BASE-A
     MOVE AN-SEQ-INDEX(WS-A, WS-NEXT) TO WS-BASE-B
     COMPUTE WS-BASE-A = WS-BASE-A * WS-BYTES
     COMPUTE WS-BASE-B = WS-BASE-B * WS-BYTES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-BYTES
         COMPUTE WS-EXPECT = (BP-BYTE(WS-BASE-A + WS-I) * WS-KEEP + BP-BYTE(WS-BASE-B + WS-I) * WS-SHARE) / 1000
         ADD 1 TO WS-CHECKED
         IF BO-BYTE(WS-I) NOT = WS-EXPECT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
*>   The cell of the atlas holds the same rows: row r of the sprite at byte ((r * 256 + x) * 4).
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 31
         COMPUTE WS-ROW = (WS-T * 256 + AT-X(WS-A)) * 4
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
             IF BT-BYTE(WS-ROW + WS-I) NOT = BO-BYTE(WS-T * 128 + WS-I)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-ANIM-BLEND.
 COPY CLTEST.
