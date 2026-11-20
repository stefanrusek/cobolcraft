*> Implementation test of the worldgen block-entity channel (GENBE.cpy, core/src/gen-be.cob): requests are appended bounded (64, the rest counted), handed to the job bounded, and applied to an
*> installed chunk through BE-BLOCK-SET: a chest gets its loot table and seed (rolled at the first open), a spawner its entity id as the SpawnData key kept with the entity's extra keys, a
*> request whose position holds no block with an entity makes none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-BE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY BESTATE.
 COPY EXTRAS.
 COPY GENBE.
 COPY GENENT.
 COPY ENDGATEWAY.
 COPY GENQUEUE.
 COPY BLOCKTICK.
 01 WS-ANSWER              PIC X(350404) BASED.
 01 WS-CHUNK-OUT           PIC X(304640).
 01 WS-MARKER              BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 WS-PTR                 USAGE POINTER.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-LOOT                PIC X(48).
 01 WS-TEXT                PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-CHEST               BINARY-LONG.
 01 WS-SPAWNER             BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX2              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-ROW                 BINARY-LONG VALUE 5.
 01 WS-CELL                BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-GNUMS.
    05 WS-GNUM             PIC S9(9) SIGN LEADING SEPARATE OCCURS 3 TIMES.
    05 FILLER              PIC X(2) VALUE SPACES.
 01 WS-NEST               BINARY-LONG.
 01 WS-LIT-1               BINARY-LONG.
 01 WS-LIT-2               BINARY-LONG.
 01 WS-LIT-3               BINARY-LONG.
 01 WS-LIT-4               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-FAMOUNT             BINARY-LONG.
 01 WS-FFALLING            BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 0 TO GBL-COUNT GBL-LOST J-BE-COUNT J-BE-LOST GB-COUNT GB-LOST

*>   the level's list is bounded
     MOVE "minecraft:chests/abandoned_mineshaft" TO WS-LOOT
     MOVE SPACES TO WS-TEXT
     MOVE 77 TO WS-SEED
     MOVE 1 TO WS-KIND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 66
         MOVE WS-I TO WS-X
         CALL "GBE-ADD" USING WS-X WS-Y WS-Z WS-KIND WS-LOOT WS-SEED WS-TEXT
     END-PERFORM
     MOVE "test gen be: 66 requests: 64 kept and 2 counted as lost" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GBL-COUNT * 100 + GBL-LOST
     MOVE 6402 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: a request keeps its position, kind, loot table and seed" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GBL-X(7) * 1000 + GBL-KIND(7) * 100 + GBL-SEED(7)
     MOVE 7177 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the job's list is bounded too
     MOVE 62 TO J-BE-COUNT
     CALL "GBE-KEEP" USING WS-JOB
     MOVE "test gen be: kept into a job that has room for two: 64 in the job, 64 lost (the level's 2 lost and 62 that did not fit) and the level's list is empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = J-BE-COUNT * 10000 + J-BE-LOST * 10 + GBL-COUNT + GBL-LOST
     COMPUTE TL-EXPECTED-N = 64 * 10000 + 64 * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: the first of the entries that fit is the level's first" TO TL-CASE
     MOVE J-BE-X(63) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   application to a chunk (dimension 3, the standard overworld with min y -64; row 5, chunk (2, -1)), published as the install does
     MOVE "minecraft:chest" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-CHEST
     MOVE "minecraft:spawner" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-SPAWNER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:bee_nest" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-NEST
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE WS-PTR TO CK-ADDR(5)
     MOVE 2 TO CK-X(5)
     MOVE -1 TO CK-Z(5)
*>   chest at (35, 10, -3), spawner at (40, -5, -16), stone at (33, 0, -2)
     COMPUTE WS-CELL = (10 + 64) * 256 + (-3 + 16) * 16 + (35 - 32) + 1
     MOVE WS-CHEST TO CE-STATE(WS-CELL)
     COMPUTE WS-CELL = (-5 + 64) * 256 + (-16 + 16) * 16 + (40 - 32) + 1
     MOVE WS-SPAWNER TO CE-STATE(WS-CELL)
     COMPUTE WS-CELL = (0 + 64) * 256 + (-2 + 16) * 16 + (33 - 32) + 1
     MOVE WS-STONE TO CE-STATE(WS-CELL)
     MOVE 0 TO EG-COUNT
     MOVE 5 TO GB-COUNT
*>   kind 4: a bee nest at (36, 20, -5) with 3 occupants whose ticks in the hive are 10, 20 and 300 (GB-SEED = n x 10^9 + t1 x 10^6 + t2 x 10^3 + t3)
     COMPUTE WS-CELL = (20 + 64) * 256 + (-5 + 16) * 16 + (36 - 32) + 1
     MOVE WS-NEST TO CE-STATE(WS-CELL)
     MOVE 36 TO GB-X(5)
     MOVE 20 TO GB-Y(5)
     MOVE -5 TO GB-Z(5)
     MOVE 4 TO GB-KIND(5)
     MOVE 3010020300 TO GB-SEED(5)
     MOVE SPACES TO GB-LOOT(5) GB-TEXT(5)
*>   kind 3: the entity of an end gateway at (34, 12, -4) with the exit (7, 8, -9), not exact (flags 1)
     MOVE 34 TO GB-X(4)
     MOVE 12 TO GB-Y(4)
     MOVE -4 TO GB-Z(4)
     MOVE 3 TO GB-KIND(4)
     MOVE 1 TO GB-SEED(4)
     MOVE 7 TO WS-GNUM(1)
     MOVE 8 TO WS-GNUM(2)
     MOVE -9 TO WS-GNUM(3)
     MOVE WS-GNUMS TO GB-TEXT(4)
     MOVE 35 TO GB-X(1)
     MOVE 10 TO GB-Y(1)
     MOVE -3 TO GB-Z(1)
     MOVE 1 TO GB-KIND(1)
     MOVE -5 TO GB-SEED(1)
     MOVE "minecraft:chests/abandoned_mineshaft" TO GB-LOOT(1)
     MOVE 40 TO GB-X(2)
     MOVE -5 TO GB-Y(2)
     MOVE -16 TO GB-Z(2)
     MOVE 2 TO GB-KIND(2)
     MOVE "minecraft:cave_spider" TO GB-TEXT(2)
     MOVE 33 TO GB-X(3)
     MOVE 0 TO GB-Y(3)
     MOVE -2 TO GB-Z(3)
     MOVE 1 TO GB-KIND(3)
     MOVE "minecraft:chests/abandoned_mineshaft" TO GB-LOOT(3)
     CALL "GBE-APPLY" USING WS-DIM WS-ROW
     MOVE 35 TO WS-X
     MOVE 10 TO WS-Y
     MOVE -3 TO WS-Z
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     MOVE "test gen be: the chest request made a block entity of type chest (1)" TO TL-CASE
     MOVE BE-TYPE(WS-INDEX) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test gen be: the chest has the loot table key" TO TL-CASE
     MOVE BE-LOOT(WS-INDEX)(1:BE-LOOT-LENGTH(WS-INDEX)) TO TL-OBSERVED
     MOVE "minecraft:chests/abandoned_mineshaft" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test gen be: and the seed" TO TL-CASE
     MOVE BE-SEED(WS-INDEX) TO TL-OBSERVED-N
     MOVE -5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-X
     MOVE -5 TO WS-Y
     MOVE -16 TO WS-Z
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX2
     MOVE "test gen be: the spawner request made a block entity with the SpawnData key (52 bytes: the compound, entity and string tags with their names, the id of 21 characters, three End tags)" TO TL-CASE
     MOVE EX-B-LEN(WS-INDEX2) TO TL-OBSERVED-N
     MOVE 52 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "test gen be: its bytes hold the entity id after the string tag" TO TL-CASE
     MOVE EX-B-DATA(WS-INDEX2)(29:21) TO TL-OBSERVED
     MOVE "minecraft:cave_spider" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 36 TO WS-X
     MOVE 20 TO WS-Y
     MOVE -5 TO WS-Z
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX2
     MOVE "N" TO TL-MODE
     MOVE "test gen be: the bee nest request made a beehive entity (33) with 3 bees at 10, 20 and 300 ticks, each of minimum 600" TO TL-CASE
     COMPUTE TL-OBSERVED-N = BE-TYPE(WS-INDEX2) * 100000000000 + BE-XI(WS-INDEX2, 5) * 10000000000
         + BE-XI(WS-INDEX2, 6) * 100000000 + BE-XI(WS-INDEX2, 10) * 100000 + BE-XI(WS-INDEX2, 14) + BE-XI(WS-INDEX2, 7)
     COMPUTE TL-EXPECTED-N = 33 * 100000000000 + 3 * 10000000000 + 10 * 100000000 + 20 * 100000 + 300 + 600
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 33 TO WS-X
     MOVE 0 TO WS-Y
     MOVE -2 TO WS-Z
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     MOVE "N" TO TL-MODE
     MOVE "test gen be: a request at a stone block makes no entity" TO TL-CASE
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: a kind 3 request made one gateway entity row (no block entity of the chunk)" TO TL-CASE
     MOVE 34 TO WS-X
     MOVE 12 TO WS-Y
     MOVE -4 TO WS-Z
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     COMPUTE TL-OBSERVED-N = EG-COUNT * 10 + WS-INDEX
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: the gateway row keeps dimension, position, the exit (7, 8, -9) and not exact" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EG-DIM(1) * 100000000 + (EG-X(1) - 30) * 10000000 + (EG-Y(1) - 10) * 1000000 + (EG-Z(1) + 10) * 100000
         + EG-HAS-EXIT(1) * 10000 + EG-EXIT-X(1) * 1000 + EG-EXIT-Y(1) * 100 + (EG-EXIT-Z(1) + 20) * 10 + EG-EXACT(1)
     COMPUTE TL-EXPECTED-N = 3 * 100000000 + 4 * 10000000 + 2 * 1000000 + 6 * 100000 + 10000 + 7000 + 800 + 110
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: the list is empty after the apply" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GB-COUNT + GB-LOST
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   kind 4: a scheduled fluid tick (36 part 8 section 5.7 lava well): asked for at a lava source of the chunk it is scheduled with delay 0, at a stone block nothing is
     MOVE "minecraft:lava" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LAVA
     CALL "FLUID-OF-STATE" USING WS-LAVA WS-FLUID WS-FKIND WS-FAMOUNT WS-FFALLING
     COMPUTE WS-CELL = (3 + 64) * 256 + (-5 + 16) * 16 + (36 - 32) + 1
     MOVE WS-LAVA TO CE-STATE(WS-CELL)
     MOVE BT-COUNT TO WS-TICKS
     MOVE 2 TO GB-COUNT
     MOVE 36 TO GB-X(1)
     MOVE 3 TO GB-Y(1)
     MOVE -5 TO GB-Z(1)
     MOVE 4 TO GB-KIND(1)
     MOVE 33 TO GB-X(2)
     MOVE 0 TO GB-Y(2)
     MOVE -2 TO GB-Z(2)
     MOVE 4 TO GB-KIND(2)
     CALL "GBE-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO WS-X
     MOVE 36 TO WS-X
     MOVE 3 TO WS-Y
     MOVE -5 TO WS-Z
     CALL "BT-HAS" USING WS-DIM WS-TYPE2 WS-FLUID WS-X WS-Y WS-Z WS-INDEX
     MOVE "test gen be: a kind 4 request at a lava source scheduled one fluid tick of lava there, and none at the stone block" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-INDEX * 10 + BT-COUNT - WS-TICKS
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: lava is a fluid of the block table" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FLUID > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the worker's answer carries the requests after the overflow: GEN-STANDARD-TAKE publishes them
     ALLOCATE GW-ANSWER-BYTES CHARACTERS INITIALIZED RETURNING GW-ADDR(1)
     SET ADDRESS OF WS-ANSWER TO GW-ADDR(1)
     MOVE X"01000000" TO WS-ANSWER(321037:4)
     MOVE X"02000000" TO WS-ANSWER(327701:4)
     MOVE 1 TO GQ-READY
     MOVE 3 TO GW-DIM(1)
     MOVE 5 TO GW-CX(1)
     MOVE 6 TO GW-CZ(1)
     MOVE 5 TO WS-CX
     MOVE 6 TO WS-CZ
     CALL "GEN-STANDARD-TAKE" USING WS-DIM WS-CX WS-CZ WS-CHUNK-OUT WS-MARKER WS-TAKEN
     MOVE "test gen be: an answer of the worker brings its request list: one request published" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-TAKEN * 10 + GB-COUNT
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test gen be: and its entity request list that follows (GENENT.cpy): two requests published" TO TL-CASE
     MOVE GE-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-GEN-BE.
 COPY CORETEST.
