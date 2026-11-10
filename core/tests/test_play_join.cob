*> Implementation test of the play join (core/src/play.cob; tasks T404; data-model §6, plan.md US2
*> sequence diagram, 09 §3.2 "Join sequence"). A memory connection is fed every serverbound join
*> fixture: handshake intention (login), Hello, Login Acknowledged, brand, Client Information, Select
*> Known Packs, then Finish Configuration. The clientbound play stream must be Login, Recipe Book
*> Add (09 §3.2: after Login), Player Abilities, Set Held Slot, Container Set Content, Set Default
*> Spawn Position, Set Time, the weather pair (Game Events 2, 7, 8 of a clear world), Game Event 13, Set Chunk Cache Center, Chunk Batch Start, the 25 chunks of view distance 2, Chunk Batch
*> Finished, Player Position at the spawn facing east, then Player Info Update for itself (US3-core,
*> 09 §3.2 "Join sequence"), with the spawn chunk byte-equal to
*> play-s2c-2e-level-chunk-with-light-spawn.hex. Then Accept Teleportation, Chunk Batch Received and
*> Player Loaded make the player Alive.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAY-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 B-STREAM               PIC X BASED.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-KIND                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-WANTED              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SKIP                BINARY-LONG VALUE 0.
 01 WS-LAST-ID             BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-PATH                PIC X(256).
 01 WS-TEXT                PIC X(1024).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(18)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN

     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-00-hello.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-RESET" USING PB-BUFFER
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "TEST-DRAIN" USING WS-CONN ST-BUFFER WS-CLOSE
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW

     PERFORM SEQUENCE-CASE
     PERFORM LOGIN-CASE
     PERFORM FIXTURE-CASES
     PERFORM TIME-CASE
     PERFORM STATE-CASES
     STOP RUN.

*> ---------------------------------------------------------------------------------------------
*> The packet ids of the play stream, a run of equal ids written as <id>x<count>.
 SEQUENCE-CASE.
     MOVE "test play join: after Finish Configuration the play stream is Login, Commands, Recipe "
         & "Book Add, abilities, held slot, inventory, spawn position, time, weather, Game Event 13, "
         & "chunk cache center, 25 chunks, Player Position, Player Info" TO TL-CASE
     PERFORM START-ROW
     PERFORM RESTART-STREAM
     MOVE 0 TO WS-OUTCOME WS-RUN
     MOVE -1 TO WS-LAST-ID
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME NOT = 0
             MOVE -2 TO WS-PACKET-ID
         END-IF
         IF WS-PACKET-ID = WS-LAST-ID
             ADD 1 TO WS-RUN
         ELSE
             PERFORM WRITE-RUN
             MOVE WS-PACKET-ID TO WS-LAST-ID
             MOVE 1 TO WS-RUN
         END-IF
     END-PERFORM
     MOVE "50 16 75 65 107 18 99 115 39x4 96 12 46x25 11 73 71" TO TL-EXPECTED
     PERFORM ASSERT-ROW.

 WRITE-RUN.
     IF WS-LAST-ID >= 0
         MOVE WS-LAST-ID TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         IF WS-RUN > 1
             MOVE WS-RUN TO WS-EDIT
             STRING "x" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         END-IF
         STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-IF.

*> Login: the new player's entity id, the one enabled dimension, view and simulation distance of
*> the settings, creative spawn info of cobolcraft:main.
 LOGIN-CASE.
     MOVE "test play join: Login has entity id 1, names [cobolcraft:main], max 20, view and "
         & "simulation distance 2, dimension type 0, cobolcraft:main, creative, sea level 48"
         TO TL-CASE
     PERFORM START-ROW
     MOVE 50 TO WS-WANTED
     PERFORM FIND-PACKET
     CALL "PB-GET-INT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     PERFORM ADD-KEY
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     PERFORM ADD-KEY
     CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     CALL "PB-GET-BOOL" USING PK-BUFFER WS-NUM
     COMPUTE WS-NUM = PK-LENGTH - PK-POS
     PERFORM ADD-NUM
     MOVE PK-ERROR TO WS-NUM
     PERFORM ADD-NUM
     MOVE "1 1 cobolcraft:main 20 2 2 0 cobolcraft:main 1 48 0 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW.

 ADD-KEY.
     MOVE SPACES TO WS-KEY
     CALL "PB-GET-IDENTIFIER" USING PK-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
     STRING WS-KEY(1:WS-KEY-LENGTH) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

*> The packets whose fixture's stated inputs are those of a new creative player at the spawn of
*> a new world.
 FIXTURE-CASES.
     MOVE "test play join: Player Abilities equal play-s2c-41-player-abilities-creative.hex"
         TO TL-CASE
     MOVE 65 TO WS-WANTED
     MOVE "contract/fixtures/wire/play-s2c-41-player-abilities-creative.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: Set Held Slot equals play-s2c-6b-set-held-slot.hex (slot 0)"
         TO TL-CASE
     MOVE 107 TO WS-WANTED
     MOVE "contract/fixtures/wire/play-s2c-6b-set-held-slot.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: the inventory is Container Set Content equal to "
         & "play-s2c-12-container-set-content-empty-46.hex (state id 1, 46 empty slots)" TO TL-CASE
     MOVE 18 TO WS-WANTED
     MOVE "core/tests/fixtures/play-s2c-12-container-set-content-empty-46.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: Set Default Spawn Position equals "
         & "play-s2c-63-set-default-spawn-position.hex" TO TL-CASE
     MOVE 99 TO WS-WANTED
     MOVE "contract/fixtures/wire/play-s2c-63-set-default-spawn-position.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: the first Game Event is the first of the clear weather pair (a new "
         & "world is clear, standin §14.3), equal to play-s2c-27-game-event-02-stop-raining.hex"
         TO TL-CASE
     MOVE 39 TO WS-WANTED
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-02-stop-raining.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: Game Event 13, after the three weather events, equals "
         & "play-s2c-27-game-event-13-wait-chunks.hex" TO TL-CASE
     MOVE 39 TO WS-WANTED
     MOVE 3 TO WS-SKIP
     MOVE "contract/fixtures/wire/play-s2c-27-game-event-13-wait-chunks.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: Player Position at the spawn (4.5, 54.0, 8.5) facing east, teleport id "
         & "1, equals play-s2c-49-player-position.hex" TO TL-CASE
     MOVE 73 TO WS-WANTED
     MOVE "contract/fixtures/wire/play-s2c-49-player-position.hex" TO WS-PATH
     PERFORM SAME-AS-FIXTURE

     MOVE "test play join: the batch holds the spawn chunk (0, 0) equal to "
         & "play-s2c-2e-level-chunk-with-light-spawn.hex" TO TL-CASE
     PERFORM RESTART-STREAM
     MOVE 0 TO WS-OUTCOME WS-FOUND
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-FOUND = 1
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 46
             CALL "PB-GET-INT" USING PK-BUFFER WS-X
             CALL "PB-GET-INT" USING PK-BUFFER WS-Z
             IF WS-X = 0 AND WS-Z = 0
                 MOVE 1 TO WS-FOUND
             END-IF
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         CALL "PB-RESET" USING PK-BUFFER
     END-IF
     MOVE "contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT.

 SAME-AS-FIXTURE.
     PERFORM FIND-PACKET
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-PATH TESTLIB-ASSERT.

*> Set Time of a new world: game time 0, one clock (id 0) with total ticks 0, rate 1.0.
 TIME-CASE.
     MOVE "test play join: Set Time carries the world time 0 and one clock update of clock 0"
         TO TL-CASE
     PERFORM START-ROW
     MOVE 115 TO WS-WANTED
     PERFORM FIND-PACKET
     CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
     MOVE WS-LONG TO WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARINT" USING PK-BUFFER WS-NUM
     PERFORM ADD-NUM
     CALL "PB-GET-VARLONG" USING PK-BUFFER WS-LONG
     MOVE WS-LONG TO WS-NUM
     PERFORM ADD-NUM
     COMPUTE WS-NUM = PK-LENGTH - PK-POS
     PERFORM ADD-NUM
     MOVE "0 1 0 0 8" TO TL-EXPECTED
     PERFORM ASSERT-ROW.

*> The player's state through the client's replies (data-model §6).
 STATE-CASES.
     MOVE "test play join: after the join the player is Joining, one batch is pending and the "
         & "teleport is not yet accepted" TO TL-CASE
     PERFORM START-ROW
     MOVE PL-STATE(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     MOVE PL-BATCH-PENDING(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-TELEPORT-ID(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-TELEPORT-ACKED(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-PHASE(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE "0 1 1 0 4" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "contract/fixtures/wire/play-c2s-00-accept-teleportation.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "test play join: Accept Teleportation of id 1 and Chunk Batch Received accept the "
         & "teleport and the batch; the player is still Joining" TO TL-CASE
     PERFORM START-ROW
     MOVE PL-STATE(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     MOVE PL-BATCH-PENDING(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-TELEPORT-ACKED(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE "0 0 1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "contract/fixtures/wire/play-c2s-2c-player-loaded.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "test play join: Player Loaded makes the player Alive; the connection stays open and "
         & "nothing more is sent" TO TL-CASE
     PERFORM START-ROW
     MOVE PL-STATE(WS-ROW) TO WS-NUM
     PERFORM ADD-NUM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     MOVE WS-CLOSE TO WS-NUM
     PERFORM ADD-NUM
     MOVE PB-LENGTH TO WS-NUM
     PERFORM ADD-NUM
     MOVE CN-CLOSE(WS-CONN) TO WS-NUM
     PERFORM ADD-NUM
     MOVE "1 0 0 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW.

*> ---------------------------------------------------------------------------------------------
*> PB-BUFFER := a fresh copy of the drained play stream (decoding a frame consumes it).
 RESTART-STREAM.
     CALL "PB-RESET" USING PB-BUFFER
     SET ADDRESS OF B-STREAM TO ST-ADDR
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-STREAM ST-LENGTH.

*> The first packet with id WS-WANTED of the drained stream into PK-BUFFER (empty when none).
 FIND-PACKET.
     PERFORM RESTART-STREAM
     MOVE 0 TO WS-OUTCOME WS-FOUND
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-FOUND = 1
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = WS-WANTED
             IF WS-SKIP > 0
                 SUBTRACT 1 FROM WS-SKIP
             ELSE
                 MOVE 1 TO WS-FOUND
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SKIP
     IF WS-FOUND = 0
         CALL "PB-RESET" USING PK-BUFFER
     END-IF.

 START-ROW.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR.

 ADD-NUM.
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PLAY-JOIN.

 COPY CORETEST.
