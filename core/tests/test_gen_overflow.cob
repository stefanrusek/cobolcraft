*> Implementation test of the chunk overflow of the feature stage (docs/design/world-types.md "Chunk borders"; core/src/gen-overflow.cob): the blocks a feature writes outside the
*> chunk being generated are recorded by the level (FL-SET-STATE), kept by the job, published by the install, routed to the neighbour chunks (written into a loaded one,
*> kept pending for an unloaded one and applied when it loads), only into air, leaves and plants, never over terrain; the bounds, the resend of a lit chunk and the reset.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-OVERFLOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY GENOVER.
 COPY GENQUEUE.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 01 WS-PTR                 USAGE POINTER.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-ROW-D               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DIM3                BINARY-LONG VALUE 3.
 01 WS-CHUNK               PIC X(304640).
 01 WS-MARKER              BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-VIEW                BASED.
    05 V-MARKER            BINARY-LONG.
    05 V-CHUNK             PIC X(304640).
    05 V-COUNT             BINARY-LONG.
    05 V-LOST              BINARY-LONG.
    05 V-ENTRY OCCURS 1024 TIMES.
       10 V-X              BINARY-LONG.
       10 V-Y              BINARY-LONG.
       10 V-Z              BINARY-LONG.
       10 V-STATE          BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
*>   a block table of 8 blocks (all other states are air): air stone water lava oak_leaves cave_air short_grass bedrock
     MOVE 8 TO CB-BLOCK-COUNT
     MOVE 8 TO CB-STATE-COUNT
     MOVE 77 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 1 TO CB-SOLID(WS-I)
         MOVE 0 TO CB-FIRST-STATE(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-MAX-STATES
         MOVE 0 TO CB-S-BLOCK(WS-I)
         MOVE 0 TO CB-S-LIGHT(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
     END-PERFORM
     MOVE 40000 TO CB-STATE-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 0 TO CB-SOLID(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 0 TO CB-SOLID(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 0 TO CB-SOLID(4)
     MOVE "minecraft:oak_leaves" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE 0 TO CB-SOLID(6)
     MOVE "minecraft:short_grass" TO CB-KEY(7)
     MOVE 0 TO CB-SOLID(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     CALL "GEN-QUEUE-RESET"

*>   the level records the writes outside its column
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR BY CONTENT 2 BY CONTENT -1 BY CONTENT -64 BY CONTENT 384 BY CONTENT 63
     MOVE "test gen overflow a level starts without overflow" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-COUNT * 10 + FL-OV-LOST
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 31 TO WS-X
     MOVE 70 TO WS-Y
     MOVE -10 TO WS-Z
     MOVE 5 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "test gen overflow a write outside the column is still refused and counted, and recorded" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OK * 1000 + FL-DISCARDED * 100 + FL-OV-COUNT * 10 + FL-WRITES
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow the entry holds the position and the state" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-X(1) * 1000000 + FL-OV-Y(1) * 1000 - FL-OV-Z(1) * 10 + FL-OV-STATE(1)
     COMPUTE TL-EXPECTED-N = 31 * 1000000 + 70 * 1000 + 10 * 10 + 5
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 400 TO WS-Y
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE -65 TO WS-Y
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "test gen overflow a write outside the column and the build height is not recorded" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-COUNT * 10 + FL-DISCARDED
     MOVE 13 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 33 TO WS-X
     MOVE 70 TO WS-Y
     MOVE -10 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "test gen overflow a write inside the column is not recorded" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-COUNT * 10 + FL-WRITES
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 31 TO WS-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1030
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     MOVE "test gen overflow the level's list is bounded at 1024 and counts what it could not keep" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-COUNT * 100 + FL-OV-LOST
     COMPUTE TL-EXPECTED-N = 1024 * 100 + 7
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the job keeps what the level recorded
     MOVE 1 TO T-OV-COUNT
     MOVE 9 TO T-OV-LOST
     MOVE 30 TO T-OV-X(1)
     MOVE 71 TO T-OV-Y(1)
     MOVE 5 TO T-OV-Z(1)
     MOVE 4 TO T-OV-STATE(1)
     CALL "FL-OPEN" USING WS-PTR BY CONTENT 2 BY CONTENT -1 BY CONTENT -64 BY CONTENT 384 BY CONTENT 63
     MOVE 31 TO WS-X
     MOVE 72 TO WS-Y
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 3 TO FL-OV-LOST
     CALL "OV-KEEP" USING WS-JOB
     MOVE "test gen overflow the job appends the level's entries after its own and adds the lost count" TO TL-CASE
     COMPUTE TL-OBSERVED-N = T-OV-COUNT * 10000 + T-OV-LOST * 100 + T-OV-Y(2)
     COMPUTE TL-EXPECTED-N = 2 * 10000 + 12 * 100 + 72
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow the level is empty after the job took its entries" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-OV-COUNT * 10 + FL-OV-LOST
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1023 TO T-OV-COUNT
     MOVE 0 TO T-OV-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-PERFORM
     CALL "OV-KEEP" USING WS-JOB
     MOVE "test gen overflow the job's list is bounded at 1024 too" TO TL-CASE
     COMPUTE TL-OBSERVED-N = T-OV-COUNT * 100 + T-OV-LOST
     COMPUTE TL-EXPECTED-N = 1024 * 100 + 2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FL-CLOSE"

*>   the replaceable rule: air, cave air, leaves and plants yes; terrain, water, lava, bedrock and unknown states no
     PERFORM VARYING WS-STATE FROM 0 BY 1 UNTIL WS-STATE > 8
         CALL "OV-REPLACEABLE" USING WS-STATE WS-FLAG
         MOVE SPACES TO TL-CASE
         MOVE WS-STATE TO WS-EDIT
         STRING "test gen overflow the state " FUNCTION TRIM(WS-EDIT) " is replaceable by a feature from outside the chunk" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-FLAG TO TL-OBSERVED-N
         EVALUATE WS-STATE
             WHEN 0 WHEN 4 WHEN 5 WHEN 6 WHEN 8
                 MOVE 1 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE 0 TO TL-EXPECTED-N
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE -1 TO WS-STATE
     CALL "OV-REPLACEABLE" USING WS-STATE WS-FLAG
     MOVE "test gen overflow a state outside the table is not replaceable" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   routing: chunk A (0,0) generated by the main generator, B (1,0) loaded, C (2,0) and D (-1,0) not loaded
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW-A
     MOVE 1 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW-B
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW-B)
*>   cell (17, 70, 3) of B holds stone, (18, 70, 3) air
     COMPUTE WS-CELL = 70 * 256 + 3 * 16 + 1 + 1
     MOVE 1 TO CE-STATE(WS-CELL)
     MOVE 0 TO CE-STATE(WS-CELL + 1)
     MOVE 0 TO CK-CHANGED(WS-ROW-B)
     MOVE 4 TO GO-COUNT
     MOVE 17 TO GO-X(1)
     MOVE 70 TO GO-Y(1)
     MOVE 3 TO GO-Z(1)
     MOVE 4 TO GO-STATE(1)
     MOVE 18 TO GO-X(2)
     MOVE 70 TO GO-Y(2)
     MOVE 3 TO GO-Z(2)
     MOVE 4 TO GO-STATE(2)
     MOVE 33 TO GO-X(3)
     MOVE 71 TO GO-Y(3)
     MOVE 4 TO GO-Z(3)
     MOVE 4 TO GO-STATE(3)
     MOVE -1 TO GO-X(4)
     MOVE 72 TO GO-Y(4)
     MOVE 1 TO GO-Z(4)
     MOVE 5 TO GO-STATE(4)
     MOVE 6 TO GO-LOST
     MOVE 5 TO CB-S-LIGHT(5)
     CALL "OV-ROUTE" USING WS-DIM
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW-B)
     MOVE "test gen overflow a loaded neighbour takes an entry into air and marks the chunk changed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CE-STATE(WS-CELL + 1) * 10 + CK-CHANGED(WS-ROW-B)
     MOVE 41 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow a light source written into a chunk counts in its section" TO TL-CASE
     MOVE CK-SOURCES(WS-ROW-B, 5) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 5 TO WS-STATE
     CALL "OV-APPLY-ROW" USING WS-ROW-B WS-X WS-Y WS-Z WS-STATE WS-RESULT
     MOVE "test gen overflow a light source replaced by leaves is no longer counted" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 10 + CK-SOURCES(WS-ROW-B, 5)
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow an entry over terrain is not written" TO TL-CASE
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow the entries of unloaded chunks wait, and the list is empty after routing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GP-COUNT * 100 + GO-COUNT * 10 + GO-LOST
     MOVE 200 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow an unlit chunk is not marked for resend" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CK-RESEND(WS-ROW-B) * 10 + GP-FLUSH
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   loading C and D applies theirs (their cells are air from the main generator at y 71 and 72? the cell is written when replaceable)
     MOVE 2 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW-C
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW-C)
     COMPUTE WS-CELL = 71 * 256 + 4 * 16 + 1 + 1
     MOVE "test gen overflow loading the chunk applies its pending entry and drops it from the list" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CE-STATE(WS-CELL) * 100 + CK-CHANGED(WS-ROW-C) * 10 + GP-COUNT
     MOVE 411 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-CX
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW-D
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW-D)
     COMPUTE WS-CELL = 72 * 256 + 1 * 16 + 15 + 1
     MOVE "test gen overflow a negative coordinate reaches the chunk below zero" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CE-STATE(WS-CELL) * 10 + GP-COUNT
     MOVE 50 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a lit chunk is marked for resend once
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW-D
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW-D)
     MOVE 2 TO GO-COUNT
     MOVE -2 TO GO-X(1)
     MOVE 200 TO GO-Y(1)
     MOVE 2 TO GO-Z(1)
     MOVE 4 TO GO-STATE(1)
     MOVE -3 TO GO-X(2)
     MOVE 200 TO GO-Y(2)
     MOVE 3 TO GO-Z(2)
     MOVE 4 TO GO-STATE(2)
     CALL "OV-ROUTE" USING WS-DIM
     MOVE "test gen overflow a lit chunk that took entries is marked for resend once" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CK-RESEND(WS-ROW-D) * 10 + GP-FLUSH
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "OV-FLUSH"
     MOVE "test gen overflow the tick sends it again and clears the mark" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CK-RESEND(WS-ROW-D) * 10 + GP-FLUSH
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "OV-FLUSH"

*>   an entry that is outside the height range of the dimension is refused, and so is the same state
     MOVE 1 TO GO-COUNT
     MOVE -2 TO GO-X(1)
     MOVE 900 TO GO-Y(1)
     MOVE 2 TO GO-Z(1)
     MOVE 4 TO GO-STATE(1)
     CALL "OV-ROUTE" USING WS-DIM
     MOVE -2 TO WS-X
     MOVE 200 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 4 TO WS-STATE
     CALL "OV-APPLY-ROW" USING WS-ROW-D WS-X WS-Y WS-Z WS-STATE WS-RESULT
     MOVE "test gen overflow an entry that changes nothing is not a write" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the pending list is bounded: the oldest GP-DROP go when it is full
     MOVE 0 TO GP-COUNT GP-LOST
     MOVE 700 TO WS-CX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8193
         MOVE WS-I TO WS-X
         MOVE 70 TO WS-Y
         MOVE 5 TO WS-Z
         CALL "OV-PEND-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     MOVE "test gen overflow a full pending list drops the oldest 1024 and counts them" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GP-COUNT * 10000 + GP-LOST
     COMPUTE TL-EXPECTED-N = 7169 * 10000 + 1024
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen overflow the oldest entries went and the newest stayed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GP-X(1) * 100000 + GP-X(GP-COUNT)
     COMPUTE TL-EXPECTED-N = 1025 * 100000 + 8193
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO GO-COUNT
     CALL "OV-RESET"
     MOVE "test gen overflow a reset forgets the pending entries and the published list" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GP-COUNT + GP-LOST + GO-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the worker's answer carries the overflow after the chunk: GEN-STANDARD-TAKE publishes it
     ALLOCATE GW-ANSWER-BYTES CHARACTERS INITIALIZED RETURNING GW-ADDR(1)
     SET ADDRESS OF WS-VIEW TO GW-ADDR(1)
     MOVE 2 TO V-COUNT
     MOVE 123 TO V-X(1)
     MOVE 9 TO V-STATE(2)
     MOVE 1 TO GQ-READY
     MOVE 3 TO GW-DIM(1)
     MOVE 5 TO GW-CX(1)
     MOVE 6 TO GW-CZ(1)
     MOVE 5 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "GEN-STANDARD-TAKE" USING WS-DIM3 WS-CX WS-CZ WS-CHUNK WS-MARKER WS-TAKEN
     MOVE "test gen overflow an answer for another chunk is not taken and gives no overflow" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-TAKEN * 10 + GO-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-CZ
     CALL "GEN-STANDARD-TAKE" USING WS-DIM3 WS-CX WS-CZ WS-CHUNK WS-MARKER WS-TAKEN
     MOVE "test gen overflow the answer of the chunk gives its overflow after the chunk" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-TAKEN * 1000000 + GO-COUNT * 100000 + GO-X(1) * 100 + GO-STATE(2)
     COMPUTE TL-EXPECTED-N = 1 * 1000000 + 2 * 100000 + 123 * 100 + 9
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GQ-READY
     FREE GW-ADDR(1)
     SET GW-ADDR(1) TO NULL

     STOP RUN.
 END PROGRAM TEST-GEN-OVERFLOW.

 COPY CORETEST.
