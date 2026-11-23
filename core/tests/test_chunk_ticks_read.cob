*> Implementation test of the saved fluid ticks of a chunk read back from disk (core/src/chunk-ticks-read.cob CHUNK-TICKS-READ, called by CHUNK-NBT-READ; docs/protocol/29 sections 4.2 and 4.5; task T43521):
*> the `fluid_ticks` list of a chunk compound is read as compounds {i, t, p, x, y, z}; water and flowing water are fluid 1, lava and flowing lava fluid 2, any other fluid is dropped, a tick whose
*> position is outside the chunk is dropped by BT-UNPACK, the others become pending fluid ticks at game time + delay with the sub-tick orders -size to -1 in list order; a list of other elements is skipped;
*> at most 256 ticks are kept; a truncated chunk reads as malformed (outcome 1) and keeps no tick. The observed text is "<outcome> n=<pending fluid ticks in the chunk> | x y z fluid delay priority sub-tick order ...".
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHUNK-TICKS-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY PROTO.
 COPY BLOCKTICK.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-INT               BINARY-LONG VALUE 3.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-TK-KEY              PIC X(64).
 01 WS-TK-LEN              BINARY-LONG.
 01 WS-TK-X                BINARY-LONG.
 01 WS-TK-Y                BINARY-LONG.
 01 WS-TK-Z                BINARY-LONG.
 01 WS-TK-T                BINARY-LONG.
 01 WS-TK-P                BINARY-LONG.
 01 WS-TK-EXTRA            BINARY-LONG.
 01 WS-AX1                 BINARY-LONG VALUE 640.
 01 WS-AY1                 BINARY-LONG VALUE -64.
 01 WS-AX2                 BINARY-LONG VALUE 655.
 01 WS-AY2                 BINARY-LONG VALUE 319.
 01 WS-AZ1                 BINARY-LONG VALUE 640.
 01 WS-AZ2                 BINARY-LONG VALUE 655.
 01 WS-OBSERVED            PIC X(2048).
 01 WS-EDIT                PIC -(10)9.
 01 WS-ED1                 PIC -(10)9.
 01 WS-ED2                 PIC -(10)9.
 01 WS-ED3                 PIC -(10)9.
 01 WS-ED4                 PIC -(10)9.
 01 WS-ED5                 PIC -(10)9.
 01 WS-ED6                 PIC -(10)9.
 01 WS-ED7                 PIC -(10)9.
 01 WS-INT                 BINARY-LONG.
 01 WS-INTS.
    05 WS-INT-ITEM         BINARY-LONG OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 5000 TO CW-TICKS
     MOVE 40 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW

*>   A. water, lava, a tick outside the chunk, a stone (not a fluid), flowing lava with an unknown key in its compound: three ticks, in list order, with the delay and priority they were saved with
     MOVE "test chunk ticks read the fluid ticks of a chunk become pending fluid ticks: water 1, lava 2, the foreign position and the stone dropped, sub-tick orders -3 to -1" TO TL-CASE
     PERFORM ROOT-BEGIN
     MOVE 5 TO WS-N PERFORM LIST-BEGIN
     MOVE "minecraft:water" TO WS-TK-KEY MOVE 15 TO WS-TK-LEN
     MOVE 643 TO WS-TK-X MOVE 64 TO WS-TK-Y MOVE 645 TO WS-TK-Z MOVE 7 TO WS-TK-T MOVE 0 TO WS-TK-P MOVE 0 TO WS-TK-EXTRA
     PERFORM WRITE-TICK
     MOVE "minecraft:lava" TO WS-TK-KEY MOVE 14 TO WS-TK-LEN
     MOVE 641 TO WS-TK-X MOVE 60 TO WS-TK-Y MOVE 642 TO WS-TK-Z MOVE 0 TO WS-TK-T MOVE -1 TO WS-TK-P
     PERFORM WRITE-TICK
     MOVE "minecraft:flowing_water" TO WS-TK-KEY MOVE 23 TO WS-TK-LEN
     MOVE 656 TO WS-TK-X MOVE 64 TO WS-TK-Y MOVE 645 TO WS-TK-Z MOVE 4 TO WS-TK-T MOVE 0 TO WS-TK-P
     PERFORM WRITE-TICK
     MOVE "minecraft:stone" TO WS-TK-KEY MOVE 15 TO WS-TK-LEN
     MOVE 644 TO WS-TK-X MOVE 64 TO WS-TK-Y MOVE 645 TO WS-TK-Z MOVE 4 TO WS-TK-T MOVE 0 TO WS-TK-P
     PERFORM WRITE-TICK
     MOVE "minecraft:flowing_lava" TO WS-TK-KEY MOVE 22 TO WS-TK-LEN
     MOVE 650 TO WS-TK-X MOVE 10 TO WS-TK-Y MOVE 650 TO WS-TK-Z MOVE 3 TO WS-TK-T MOVE 2 TO WS-TK-P MOVE 1 TO WS-TK-EXTRA
     PERFORM WRITE-TICK
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 4 TO WS-LIMIT
     PERFORM READ-AND-OBSERVE
     MOVE "0 n=3 | 643 64 645 1 7 0 -3 | 641 60 642 2 0 -1 -2 | 650 10 650 2 3 2 -1" TO TL-EXPECTED
     PERFORM CHECK

*>   B. a chunk without the list has no fluid tick
     MOVE "test chunk ticks read a chunk compound without fluid_ticks keeps no tick" TO TL-CASE
     PERFORM ROOT-BEGIN
     MOVE "xPos" TO WN MOVE 4 TO WL
     MOVE 40 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-AND-OBSERVE
     MOVE "0 n=0" TO TL-EXPECTED
     PERFORM CHECK

*>   C. a list of ints is skipped and the rest of the chunk still reads
     MOVE "test chunk ticks read a fluid_ticks list of ints is skipped and the chunk reads without error" TO TL-CASE
     PERFORM ROOT-BEGIN
     MOVE "fluid_ticks" TO WN MOVE 11 TO WL
     MOVE 2 TO WS-N
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-INT WS-N
     MOVE 5 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WS-ELEMENT WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WS-ELEMENT WS-INT
     MOVE "xPos" TO WN MOVE 4 TO WL
     MOVE 40 TO WS-INT
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     PERFORM READ-AND-OBSERVE
     MOVE "0 n=0" TO TL-EXPECTED
     PERFORM CHECK

*>   D. 257 water ticks in the chunk: 256 are kept
     MOVE "test chunk ticks read at most 256 saved ticks of a chunk are kept" TO TL-CASE
     PERFORM ROOT-BEGIN
     MOVE 257 TO WS-N PERFORM LIST-BEGIN
     MOVE "minecraft:water" TO WS-TK-KEY MOVE 15 TO WS-TK-LEN
     MOVE 1 TO WS-TK-T MOVE 0 TO WS-TK-P MOVE 0 TO WS-TK-EXTRA
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 256
         COMPUTE WS-TK-X = 640 + FUNCTION MOD(WS-K, 16)
         COMPUTE WS-TK-Z = 640 + FUNCTION MOD(WS-K / 16, 16)
         MOVE 64 TO WS-TK-Y
         IF WS-K = 256
             MOVE 65 TO WS-TK-Y
         END-IF
         PERFORM WRITE-TICK
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO WS-LIMIT
     PERFORM READ-AND-OBSERVE
     MOVE "0 n=256" TO TL-EXPECTED
     PERFORM CHECK

*>   E. a truncated chunk reads as malformed and keeps no tick
     MOVE "test chunk ticks read a truncated chunk reads as malformed (outcome 1) and keeps no tick" TO TL-CASE
     PERFORM ROOT-BEGIN
     MOVE 3 TO WS-N PERFORM LIST-BEGIN
     MOVE "minecraft:water" TO WS-TK-KEY MOVE 15 TO WS-TK-LEN
     MOVE 643 TO WS-TK-X MOVE 64 TO WS-TK-Y MOVE 645 TO WS-TK-Z MOVE 7 TO WS-TK-T MOVE 0 TO WS-TK-P MOVE 0 TO WS-TK-EXTRA
     PERFORM WRITE-TICK
     PERFORM WRITE-TICK
     PERFORM WRITE-TICK
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     SUBTRACT 30 FROM PB-LENGTH
     MOVE 4 TO WS-LIMIT
     PERFORM READ-AND-OBSERVE
     MOVE "1 n=0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ROOT-BEGIN.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL.

 LIST-BEGIN.
*>   the key fluid_ticks, a list of WS-N compounds
     MOVE "fluid_ticks" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-N.

 WRITE-TICK.
*>   one saved tick compound: i, t, p, x, y, z (and a byte "extra" when WS-TK-EXTRA is 1)
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
     MOVE "i" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-TK-KEY WS-TK-LEN
     MOVE "t" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TK-T
     IF WS-TK-EXTRA = 1
         MOVE "extra" TO WN MOVE 5 TO WL
         CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-ONE
     END-IF
     MOVE "p" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TK-P
     MOVE "x" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TK-X
     MOVE "y" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TK-Y
     MOVE "z" TO WN MOVE 1 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TK-Z
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER.

 READ-AND-OBSERVE.
*>   clears the pending ticks of the chunk, reads PB-BUFFER as the chunk of WS-ROW, and writes WS-OBSERVED
     CALL "BT-CLEAR-AREA" USING WS-DIM WS-AX1 WS-AY1 WS-AZ1 WS-AX2 WS-AY2 WS-AZ2
     MOVE 0 TO PB-POS
     CALL "CHUNK-NBT-READ" USING WS-ROW PB-BUFFER WS-OUTCOME
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = WS-DIM AND BT-T-TYPE(WS-I) = 2 AND BT-T-X(WS-I) >= 640 AND BT-T-X(WS-I) <= 655
                 AND BT-T-Z(WS-I) >= 640 AND BT-T-Z(WS-I) <= 655
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " n=" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE 0 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT OR WS-K >= WS-LIMIT
         IF BT-T-DIM(WS-I) = WS-DIM AND BT-T-TYPE(WS-I) = 2 AND BT-T-X(WS-I) >= 640 AND BT-T-X(WS-I) <= 655
                 AND BT-T-Z(WS-I) >= 640 AND BT-T-Z(WS-I) <= 655
             ADD 1 TO WS-K
             COMPUTE WS-DELAY = BT-T-TRIG(WS-I) - CW-TICKS
             MOVE BT-T-X(WS-I) TO WS-ED1
             MOVE BT-T-Y(WS-I) TO WS-ED2
             MOVE BT-T-Z(WS-I) TO WS-ED3
             MOVE BT-T-ID(WS-I) TO WS-ED4
             MOVE WS-DELAY TO WS-ED5
             MOVE BT-T-PRIO(WS-I) TO WS-ED6
             MOVE BT-T-SUB(WS-I) TO WS-ED7
             STRING FUNCTION TRIM(WS-OBSERVED) " | " FUNCTION TRIM(WS-ED1) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " "
                 FUNCTION TRIM(WS-ED4) " " FUNCTION TRIM(WS-ED5) " " FUNCTION TRIM(WS-ED6) " " FUNCTION TRIM(WS-ED7)
                 DELIMITED BY SIZE INTO WS-OBSERVED
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CHUNK-TICKS-READ.

 COPY CORETEST.
