*> Test helpers of the core package (test infrastructure, excluded from coverage). COPY this after
*> the END PROGRAM of a test program; it adds these programs to the test executable:
*>   TEST-LOAD-HEX USING path (PIC X(256)), PB-BUFFER: replaces the buffer content with the bytes
*>     of a hex fixture (contracts/proto-api.md §3: whitespace-separated hex, "#" comments).
*>   TEST-SETTINGS USING CORE-SETTINGS: the operator-surface §2 defaults, with extra dimensions off
*>     (US2: only cobolcraft:main) and host kind 0 (dedicated server).
*>   TEST-OPEN-WORLD USING CORE-SETTINGS: removes build/core-test-world, then CORE-WORLD-OPEN on it
*>     (a new world: no level.dat, no region files left by an earlier test).
*>   TEST-FEED USING connection id, path (PIC X(256)): frames the fixture packet as the client
*>     would (compressed at 256 once the connection's CN-COMPRESS is set) and passes it to
*>     CORE-CONN-INPUT.
*>   TEST-FEED-BUFFER USING connection id, packet PB-BUFFER: the same for a packet built in a test.
*>   TEST-DRAIN USING connection id, stream PB-BUFFER (appended to), close-flag out: every byte the
*>     core has queued for the connection (CORE-CONN-OUTPUT until it returns no bytes or the close
*>     flag; after a close flag the connection is released).
*>   TEST-NEXT-PACKET USING stream PB-BUFFER, packet PB-BUFFER (initialised), threshold (-1 or
*>     256), packet id out, outcome out: the next packet of a drained stream (PB-FRAME-DECODE,
*>     no validation); outcome 0 packet, 1 none left, 2 malformed.
*>   TEST-SAME-AS-FIXTURE USING packet PB-BUFFER (id + body, from byte 1), path, TESTLIB-ASSERT
*>     (TL-CASE set): asserts the packet bytes equal the fixture bytes; on a difference the
*>     observed text names the first differing offset and both bytes, or both lengths.
*>   TEST-HEX-OF USING area, count (at most 512), hex out (PIC X(1024)): lowercase hex.
*>   TEST-JOIN USING name (PIC X(16)), name length, connection id out: a memory connection that
*>     logs in with that name (Intention and Hello as the client sends them), completes
*>     configuration, accepts the join teleport, acknowledges the chunk batch and sends Player
*>     Loaded; everything the core queued for it is drained and discarded.
*>   TEST-JOIN-UNDRAINED USING name, name length, connection id out: the same without the drain.
*>   TEST-ACCEPT-TELEPORT USING connection id: Accept Teleportation of the connection's last
*>     teleport id (position and rotation of its player).
*>   TEST-MOVE USING connection id, packet id (30 to 33), x, y, z (FLOAT-LONG), yaw, pitch
*>     (FLOAT-SHORT), flags (BINARY-LONG): feeds that Move Player packet (only the fields the
*>     packet id has are written).
*>   TEST-DRAIN-IDS USING connection id, text out (PIC X(1024)): drains the connection and lists
*>     the packet ids of the drained stream, a run of equal ids as <id>x<count>, separated by one
*>     space ("" when nothing was queued).
*>   TEST-USE-ON USING connection id, x, y, z, face, sequence: feeds Use Item On (main hand,
*>     cursor 0.5 on each axis).
*>   TEST-ACTION USING connection id, action, x, y, z, face, sequence: feeds Player Action.
*>   TEST-TICKS USING count: runs that many CORE-TICKs.
*>   TEST-DRAIN-BLOCKS USING connection id, text out (PIC X(1024)): drains the connection and
*>     describes each packet (Block Update, Block Destruction, Block Changed Ack, Container Set Slot
*>     and Light Update with their fields, others by id; Set Time and Recipe Book Add left out).
*>   TEST-BLOCK-AT USING x, y, z, state out: the block state of cobolcraft:main there.
*>   TEST-HELD USING connection id, slot: feeds Set Carried Item.
*>   TEST-CLICK USING connection id, slot, button, click type: feeds Container Click (container 0,
*>     the current state id, no predicted slots, empty predicted cursor).
*>   TEST-DRAIN-ENTITIES USING connection id, text out (PIC X(1024)): drains the connection and
*>     describes each packet (Add Entity, Set Entity Data, Set Entity Motion, Teleport Entity, Take
*>     Item Entity, Remove Entities and Container Set Slot with their fields, others by id; Set Time
*>     and Recipe Book Add left out), a run of equal descriptions as <description>x<count>.
*>   TEST-FIND-ENTITY USING network entity id, tracker row out (0 when no row has that id).
*>   TEST-TICKS-ANSWERED USING count: runs that many CORE-TICKs in steps of at most 100, answering
*>     after each step every pending Keep Alive of a connection in play (as a client would), so
*>     long runs do not time the connections out.
*>   TEST-CHAT USING connection id, message (PIC X(768)), byte length: feeds Chat (unsigned) as the
*>     client sends it (play-c2s-09-chat.hex layout: timestamp 1700000000000, salt 0, no signature,
*>     last seen offset 0, nothing acknowledged, checksum 0).
*>   TEST-DRAIN-CHAT USING connection id, text out (PIC X(4096)): drains the connection and lists
*>     its System Chat packets separated by " | ": plain or literal text as the text, translate as
*>     key(arg,arg...), with "[overlay]" appended when the overlay flag is set; other packets are
*>     left out.
*>   TEST-ATTACK USING connection id, target entity id: feeds Attack (05c 0x01).
*>   TEST-CLIENT-COMMAND USING connection id, action: feeds Client Command (05c 0x0C).
*>   TEST-DRAIN-HEALTH USING connection id, text out (PIC X(4096)): drains the connection and lists
*>     its health packets separated by " | ": Set Health "health <h> food <f>", Damage Event
*>     "damage <entity> type <t> source <s>", Hurt Animation "hurt <entity>", Player Combat Kill
*>     "kill <entity> key(arg,...)", System Chat "chat key(arg,...)" (plain text as the text),
*>     Respawn "respawn <dimension key> mode <m> keep <k>" and Player Position "position <x> <y>
*>     <z>" (one decimal); other packets are left out.
*>   TEST-USE-ITEM USING connection id: feeds Use Item (05c 0x43: main hand, sequence 0, yaw and
*>     pitch 0).
*>   TEST-PLAYER-COMMAND USING connection id, action: feeds Player Command (05c 0x2A) with the
*>     player's own entity id and data 0.
*>   TEST-DRAIN-HUNGER USING connection id, text out (PIC X(4096)): drains the connection and lists
*>     its hunger packets separated by " | ": Set Health "health <h> food <f>", Entity Event
*>     "event <entity> <id>" and Container Set Slot "slot <s>=<item>x<count>"; other packets are
*>     left out.
*>   TEST-PLACE-RECIPE USING connection id, recipe display id: feeds Place Recipe (05c 0x27:
*>     container 0, the display id, use max items false).
*>   TEST-DRAIN-CRAFT USING connection id, text out (PIC X(4096)): drains the connection and lists
*>     its crafting packets separated by " | ": Recipe Book Settings "settings", Recipe Book Add "book
*>     <entries> ids <display ids, space-separated> replace <0|1>" and Container Set Slot
*>     "slot <s>=<item>x<count>"; other packets are left out.
*>   TEST-DRAIN-WEATHER USING connection id, text out (PIC X(4096)): drains the connection and lists
*>     its weather Game Events (events 1, 2, 7 and 8) separated by " | " as "<event> <value>" (one
*>     decimal); other packets, and other Game Events, are left out.
*>   TEST-NBT-RENDER USING PB-BUFFER, tag type, text (PIC X(8192)), text length (appended to):
*>     renders the payload of that type at PB-POS as text and moves past it: numbers in decimal
*>     (Float and Double with three decimals), strings as they are, a List as [e,e,...], a Compound
*>     as {name:value,...} in file order, an Int Array as I[i,i,...], a Byte Array as B<count> and a
*>     Long Array as L<count>. Recursive.
*>   TEST-NBT-GET USING PB-BUFFER, root payload position, path (PIC X(128), NBT-READ-FIND form),
*>     text out (PIC X(8192)): the rendering of the tag the path names in the root compound whose
*>     payload starts at that position, or "absent".
*>   TEST-NBT-FILE USING path (PIC X(256)), PB-BUFFER (initialised), root payload position out:
*>     reads a gzip NBT file (NBT-FILE-READ) and its file root header; position -1 when unreadable.
*>   TEST-WORLD-SNAPSHOT USING text out (PIC X(8192)): the saved world state as text: time, spawn,
*>     the weather of each dimension, the allow-list flag and the names on each access list, then
*>     every mob and ground item by dimension and entity type (type, position, yaw, health, item,
*>     count, age; at most one entity of a type per dimension keeps the order stable).
*>   TEST-PLAYER-SNAPSHOT USING player row, text out (PIC X(8192)): a player's stored state as text:
*>     dimension, position, rotation, game mode, health, food, held slot, death cause and the
*>     non-empty inventory slots.
*>   TEST-CHAT-COMMAND USING connection id, command (PIC X(768), without the leading /), byte
*>     length: feeds Chat Command (05c 0x07).
*>   TEST-COMMAND USING connection id, command (PIC X(768)): the same, the length being the text
*>     without trailing spaces.
*>   TEST-SUGGEST USING connection id, transaction id, text (PIC X(768), with the leading /), byte
*>     length: feeds Command Suggestion (05c 0x0F).
*>   TEST-DRAIN-SUGGESTIONS USING connection id, text out (PIC X(4096)): drains the connection and
*>     lists its Command Suggestions packets separated by " | " as "<transaction> <start> <length>
*>     [<suggestion>,...]"; other packets are left out.
*>   TEST-DRAIN-PACKET USING connection id, packet id, packet PB-BUFFER (initialised), found out:
*>     drains the connection; the first packet with that id (id + body) is copied into the buffer.
*>   TEST-HELLO USING name (PIC X(16)), name length, connection id out: a memory connection that
*>     sends Intention (login) and Hello with that name, and nothing more.
*>   TEST-CONFIGURE USING name (PIC X(16)), name length, connection id out: TEST-HELLO, then Login
*>     Acknowledged, the client's brand, Client Information and Select Known Packs (nothing drained;
*>     configuration stops where the server waits for the client next).
*>   TEST-PACK-RESPONSE USING connection id, action (0 to 7): feeds the configuration Resource
*>     Pack Response fixture of that action (pack id 00112233-4455-6677-8899-aabbccddeeff).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-HEX.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT HEX-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD HEX-FILE.
 01 HEX-LINE               PIC X(4096).
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 01 WS-I                   BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BYTE                PIC X.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH PB-BUFFER.
     MOVE L-PATH TO WS-PATH
     CALL "PB-RESET" USING PB-BUFFER
     OPEN INPUT HEX-FILE
     IF WS-STATUS NOT = "00"
         DISPLAY "TEST-LOAD-HEX cannot open " FUNCTION TRIM(WS-PATH) " status " WS-STATUS
         STOP RUN RETURNING 2
     END-IF
     PERFORM UNTIL WS-STATUS NOT = "00"
         MOVE SPACES TO HEX-LINE
         READ HEX-FILE
         IF WS-STATUS = "00"
             MOVE 4096 TO WS-END
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4096
                 IF HEX-LINE(WS-I:1) = "#" AND WS-END = 4096
                     COMPUTE WS-END = WS-I - 1
                 END-IF
             END-PERFORM
             MOVE 1 TO WS-I
             PERFORM UNTIL WS-I > WS-END
                 IF HEX-LINE(WS-I:1) = SPACE OR HEX-LINE(WS-I:1) = X"09"
                     ADD 1 TO WS-I
                 ELSE
                     MOVE FUNCTION HEX-TO-CHAR(HEX-LINE(WS-I:2)) TO WS-BYTE
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BYTE WS-ONE
                     ADD 2 TO WS-I
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     CLOSE HEX-FILE
     GOBACK.
 END PROGRAM TEST-LOAD-HEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SETTINGS.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-SETTINGS.
     INITIALIZE CORE-SETTINGS
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 0 TO CS-EXTRA-DIMENSIONS CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED
     MOVE 0 TO CS-HOST-KIND CS-GUEST-MODE CS-GUEST-OPERATOR
     MOVE "New World" TO CS-NEW-WORLD-NAME
     GOBACK.
 END PROGRAM TEST-SETTINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPEN-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(64) VALUE Z"build/core-test-world".
 01 WS-COMMAND             PIC X(64) VALUE "rm -rf build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-SETTINGS.
     CALL "SYSTEM" USING WS-COMMAND
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     GOBACK.
 END PROGRAM TEST-OPEN-WORLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-BUFFER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-THRESHOLD           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PB-BUFFER.
     MOVE -1 TO WS-THRESHOLD
     IF CN-COMPRESS(L-ID) = 1
         MOVE 256 TO WS-THRESHOLD
     END-IF
     CALL "PB-INIT" USING FR-BUFFER WS-CAPACITY
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER WS-THRESHOLD
     SET CB-ADDR TO FR-ADDR
     MOVE FR-LENGTH TO CB-CAPACITY CB-LENGTH
     CALL "CORE-CONN-INPUT" USING L-ID CORE-BUFFER
     CALL "PB-FREE" USING FR-BUFFER
     GOBACK.
 END PROGRAM TEST-FEED-BUFFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-ID L-PATH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-FEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-AREA                PIC X(65536).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PB-BUFFER L-CLOSE.
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 65536 TO CB-CAPACITY
     MOVE 1 TO CB-LENGTH
     MOVE 0 TO L-CLOSE
     PERFORM UNTIL CB-LENGTH = 0 OR L-CLOSE = 1
         CALL "CORE-CONN-OUTPUT" USING L-ID CORE-BUFFER L-CLOSE
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-AREA CB-LENGTH
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-DRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NEXT-PACKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALIDATE            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 L-THRESHOLD            BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PK-BUFFER L-THRESHOLD L-PACKET-ID L-OUTCOME.
     CALL "PB-FRAME-DECODE" USING PB-BUFFER PK-BUFFER L-THRESHOLD WS-VALIDATE L-PACKET-ID
         L-OUTCOME
     GOBACK.
 END PROGRAM TEST-NEXT-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HEX-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-AREA                 PIC X(512).
 01 L-COUNT                BINARY-LONG.
 01 L-HEX                  PIC X(1024).
 PROCEDURE DIVISION USING L-AREA L-COUNT L-HEX.
     MOVE SPACES TO L-HEX
     COMPUTE WS-COUNT = FUNCTION MIN(L-COUNT, 512)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(L-AREA(WS-I:1)))
             TO L-HEX(WS-I * 2 - 1:2)
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-HEX-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SAME-AS-FIXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FX-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-I                   BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-EDIT                PIC Z(8)9.
 01 WS-EDIT2               PIC Z(8)9.
 01 B-GOT                  PIC X(1073741824) BASED.
 01 B-WANT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY TESTLIB.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING PB-BUFFER L-PATH TESTLIB-ASSERT.
     CALL "PB-INIT" USING FX-BUFFER WS-CAPACITY
     CALL "TEST-LOAD-HEX" USING L-PATH FX-BUFFER
     SET ADDRESS OF B-GOT TO PB-ADDR
     SET ADDRESS OF B-WANT TO FX-ADDR
     MOVE 0 TO WS-DIFF
     PERFORM VARYING WS-I FROM 1 BY 1
             UNTIL WS-I > PB-LENGTH OR WS-I > FX-LENGTH OR WS-DIFF > 0
         IF B-GOT(WS-I:1) NOT = B-WANT(WS-I:1)
             MOVE WS-I TO WS-DIFF
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE FX-LENGTH TO WS-EDIT
     STRING "equal to " FUNCTION TRIM(L-PATH) " (" FUNCTION TRIM(WS-EDIT) " bytes)"
         DELIMITED BY SIZE INTO TL-EXPECTED
     EVALUATE TRUE
         WHEN WS-DIFF > 0
             COMPUTE WS-EDIT = WS-DIFF - 1
             STRING "differs at offset " FUNCTION TRIM(WS-EDIT) ": fixture "
                 FUNCTION LOWER-CASE(FUNCTION HEX-OF(B-WANT(WS-DIFF:1))) " observed "
                 FUNCTION LOWER-CASE(FUNCTION HEX-OF(B-GOT(WS-DIFF:1)))
                 DELIMITED BY SIZE INTO TL-OBSERVED
         WHEN PB-LENGTH NOT = FX-LENGTH
             MOVE PB-LENGTH TO WS-EDIT2
             STRING "length " FUNCTION TRIM(WS-EDIT2) " (fixture " FUNCTION TRIM(WS-EDIT) ")"
                 DELIMITED BY SIZE INTO TL-OBSERVED
         WHEN OTHER
             MOVE TL-EXPECTED TO TL-OBSERVED
     END-EVALUATE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING FX-BUFFER
     GOBACK.
 END PROGRAM TEST-SAME-AS-FIXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ID.
     CALL "TEST-JOIN-UNDRAINED" USING L-NAME L-NAME-LENGTH L-ID
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-JOIN-UNDRAINED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ID.
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "TEST-JOIN-KIND" USING WS-KIND L-NAME L-NAME-LENGTH L-ID
     GOBACK.
 END PROGRAM TEST-JOIN-UNDRAINED.

*> TEST-JOIN-NETWORK USING name, length, id out: a guest joining over a network connection
*> (CORE-CONN-NETWORK: Set Compression, then compressed frames); its output is drained and dropped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-JOIN-NETWORK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 01 WS-KIND                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ID.
     MOVE CORE-CONN-NETWORK TO WS-KIND
     CALL "TEST-JOIN-KIND" USING WS-KIND L-NAME L-NAME-LENGTH L-ID
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-JOIN-NETWORK.

*> TEST-JOIN-KIND USING connection kind, name, length, id out: opens a connection of that kind and
*> plays the client's side of login, configuration and the first chunks (output left queued).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-JOIN-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-PATH                PIC X(256).
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-NAME L-NAME-LENGTH L-ID.
     CALL "CORE-CONN-OPEN" USING L-KIND L-ID
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER L-NAME L-NAME-LENGTH WS-MAX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     CALL "TEST-ACCEPT-TELEPORT" USING L-ID
     MOVE "contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/play-c2s-2c-player-loaded.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-JOIN-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ACCEPT-TELEPORT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER CN-TELEPORT-ID(L-ID)
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER PL-X(WS-ROW)
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER PL-Y(WS-ROW)
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER PL-Z(WS-ROW)
     CALL "PB-PUT-FLOAT" USING PB-BUFFER PL-YAW(WS-ROW)
     CALL "PB-PUT-FLOAT" USING PB-BUFFER PL-PITCH(WS-ROW)
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-ACCEPT-TELEPORT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID L-X L-Y L-Z L-YAW L-PITCH L-FLAGS.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-PACKET-ID
     IF L-PACKET-ID = 30 OR L-PACKET-ID = 31
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     END-IF
     IF L-PACKET-ID = 31 OR L-PACKET-ID = 32
         CALL "PB-PUT-FLOAT" USING PB-BUFFER L-YAW
         CALL "PB-PUT-FLOAT" USING PB-BUFFER L-PITCH
     END-IF
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-FLAGS
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-IDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LAST-ID             BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
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
             IF WS-LAST-ID >= 0
                 IF WS-PTR > 1
                     STRING " " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 MOVE WS-LAST-ID TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 IF WS-RUN > 1
                     MOVE WS-RUN TO WS-EDIT
                     STRING "x" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         POINTER WS-PTR
                 END-IF
             END-IF
             MOVE WS-PACKET-ID TO WS-LAST-ID
             MOVE 1 TO WS-RUN
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-IDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-ON.
*> USING connection id, x, y, z, face, sequence (BINARY-LONG): feeds Use Item On with the main hand on
*> that block and face, cursor (0.5, 0.5, 0.5), not inside, no border hit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 66.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HALF                FLOAT-SHORT VALUE 0.5.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z L-FACE L-SEQUENCE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-FACE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-HALF
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-USE-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ACTION.
*> USING connection id, action, x, y, z, face, sequence (BINARY-LONG): feeds Player Action.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 41.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-SEQUENCE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION L-X L-Y L-Z L-FACE L-SEQUENCE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ACTION
     CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-FACE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SEQUENCE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TICKS.
*> USING count (BINARY-LONG): runs that many CORE-TICKs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "CORE-TICK"
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-BLOCKS.
*> USING connection id, text out (PIC X(1024)): drains the connection and describes each packet,
*> separated by one space: Block Update "8(x,y,z=state)", Block Destruction "5(entity,x,y,z=stage)",
*> Block Changed Ack "4(sequence)", Container Set Slot "20(state id,slot=itemxcount)", Light Update
*> "49(chunk x,chunk z)", any other packet its id. Set Time (0x73), sent every 20 ticks, and Recipe
*> Book Add (0x4B), sent after every inventory change (TEST-DRAIN-CRAFT shows it), are left out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID NOT = 115 AND WS-PACKET-ID NOT = 75
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
             MOVE WS-PACKET-ID TO WS-E1
             STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             EVALUATE WS-PACKET-ID
                 WHEN 8
                     CALL "PB-GET-POSITION" USING PK-BUFFER WS-X WS-Y WS-Z
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-X TO WS-E1
                     MOVE WS-Y TO WS-E2
                     MOVE WS-Z TO WS-E3
                     MOVE WS-A TO WS-E4
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) ","
                         FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ")" DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
                 WHEN 5
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-POSITION" USING PK-BUFFER WS-X WS-Y WS-Z
                     CALL "PB-GET-UBYTE" USING PK-BUFFER WS-B
                     MOVE WS-A TO WS-E1
                     MOVE WS-X TO WS-E2
                     MOVE WS-Y TO WS-E3
                     MOVE WS-Z TO WS-E4
                     MOVE WS-B TO WS-E5
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) ","
                         FUNCTION TRIM(WS-E3) "," FUNCTION TRIM(WS-E4) "=" FUNCTION TRIM(WS-E5)
                         ")" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 4
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING "(" FUNCTION TRIM(WS-E1) ")" DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
                 WHEN 20
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-SHORT" USING PK-BUFFER WS-B
                     CALL "PB-GET-ITEM-STACK" USING PK-BUFFER PK-ITEMSTACK-X
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     MOVE PK-ISX-ITEM TO WS-E3
                     MOVE PK-ISX-COUNT TO WS-E4
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "="
                         FUNCTION TRIM(WS-E3) "x" FUNCTION TRIM(WS-E4) DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
*>                   A stack with a component patch shows its counts: "{a<added>r<removed>}".
                     IF PK-ISX-ADDED-COUNT > 0 OR PK-ISX-REMOVED-COUNT > 0
                         MOVE PK-ISX-ADDED-COUNT TO WS-E1
                         MOVE PK-ISX-REMOVED-COUNT TO WS-E2
                         STRING "{a" FUNCTION TRIM(WS-E1) "r" FUNCTION TRIM(WS-E2) "}" DELIMITED BY SIZE
                             INTO L-TEXT POINTER WS-PTR
                     END-IF
                     STRING ")" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 49
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) ")"
                         DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-BLOCKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-AT.
*> USING x, y, z, state out (BINARY-LONG): the block state at that position of cobolcraft:main.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM L-X L-Y L-Z L-STATE
     GOBACK.
 END PROGRAM TEST-BLOCK-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HELD.
*> USING connection id, slot (BINARY-LONG): feeds Set Carried Item with that slot (Short).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-PACKET-ID           BINARY-LONG VALUE 54.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLICK.
*> USING connection id, slot, button, click type (BINARY-LONG): feeds Container Click on container 0
*> with the player's current state id, no predicted changed slots and an empty predicted cursor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BUTTON               BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-SLOT L-BUTTON L-TYPE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-STATE-ID(CN-PLAYER(L-ID))
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-BYTE" USING PB-BUFFER L-BUTTON
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-ENTITIES.
*> USING connection id, text out (PIC X(1024)): drains the connection and describes each packet,
*> separated by one space: Add Entity "1(id,type@x,y,z)", Set Entity Data "101(id=itemxcount)",
*> Set Entity Motion "103(id)", Teleport Entity "128(id)", Take Item Entity
*> "127(collected,collector,amount)", Remove Entities "78(first id)", Container Set Slot
*> "20(slot=itemxcount)", any other packet its id; Set Time (0x73) and Recipe Book Add (0x4B,
*> shown by TEST-DRAIN-CRAFT) are left out. Positions are
*> rounded to two decimals. A run of equal descriptions is written once with "x<count>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-DESC                PIC X(80).
 01 WS-LAST                PIC X(80).
 01 WS-RUN                 BINARY-LONG.
 01 WS-DPTR                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-R1                  PIC -(6)9.99.
 01 WS-R2                  PIC -(6)9.99.
 01 WS-R3                  PIC -(6)9.99.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT WS-LAST
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-RUN
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         MOVE SPACES TO WS-DESC
         MOVE 1 TO WS-DPTR
         IF WS-OUTCOME = 0 AND WS-PACKET-ID NOT = 115 AND WS-PACKET-ID NOT = 75
             MOVE WS-PACKET-ID TO WS-E1
             STRING FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-DESC POINTER WS-DPTR
             EVALUATE WS-PACKET-ID
                 WHEN 1
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-UUID" USING PK-BUFFER WS-UUID
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-X
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Y
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Z
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     COMPUTE WS-R1 ROUNDED = WS-X
                     COMPUTE WS-R2 ROUNDED = WS-Y
                     COMPUTE WS-R3 ROUNDED = WS-Z
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "@"
                         FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) "," FUNCTION TRIM(WS-R3)
                         ")" DELIMITED BY SIZE INTO WS-DESC POINTER WS-DPTR
                 WHEN 101
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-UBYTE" USING PK-BUFFER WS-B
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     CALL "PB-GET-ITEMSTACK" USING PK-BUFFER PK-ITEMSTACK
                     MOVE WS-A TO WS-E1
                     MOVE PK-IS-ITEM TO WS-E2
                     MOVE PK-IS-COUNT TO WS-E3
                     STRING "(" FUNCTION TRIM(WS-E1) "=" FUNCTION TRIM(WS-E2) "x"
                         FUNCTION TRIM(WS-E3) ")" DELIMITED BY SIZE INTO WS-DESC POINTER WS-DPTR
                 WHEN 103
                 WHEN 128
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING "(" FUNCTION TRIM(WS-E1) ")" DELIMITED BY SIZE INTO WS-DESC
                         POINTER WS-DPTR
                 WHEN 127
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-C
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     MOVE WS-C TO WS-E3
                     STRING "(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) ","
                         FUNCTION TRIM(WS-E3) ")" DELIMITED BY SIZE INTO WS-DESC POINTER WS-DPTR
                 WHEN 78
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING "(" FUNCTION TRIM(WS-E1) ")" DELIMITED BY SIZE INTO WS-DESC
                         POINTER WS-DPTR
                 WHEN 20
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-SHORT" USING PK-BUFFER WS-B
                     CALL "PB-GET-ITEMSTACK" USING PK-BUFFER PK-ITEMSTACK
                     MOVE WS-B TO WS-E1
                     MOVE PK-IS-ITEM TO WS-E2
                     MOVE PK-IS-COUNT TO WS-E3
                     STRING "(" FUNCTION TRIM(WS-E1) "=" FUNCTION TRIM(WS-E2) "x"
                         FUNCTION TRIM(WS-E3) ")" DELIMITED BY SIZE INTO WS-DESC POINTER WS-DPTR
             END-EVALUATE
         END-IF
         IF WS-DESC NOT = SPACES OR WS-OUTCOME NOT = 0
             IF WS-DESC = WS-LAST AND WS-OUTCOME = 0
                 ADD 1 TO WS-RUN
             ELSE
                 IF WS-LAST NOT = SPACES
                     IF WS-PTR > 1
                         STRING " " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     END-IF
                     STRING FUNCTION TRIM(WS-LAST) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     IF WS-RUN > 1
                         MOVE WS-RUN TO WS-E1
                         STRING "x" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO L-TEXT
                             POINTER WS-PTR
                     END-IF
                 END-IF
                 MOVE WS-DESC TO WS-LAST
                 MOVE 1 TO WS-RUN
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-ENTITIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FIND-ENTITY.
*> USING network entity id, tracker row out (BINARY-LONG): the CORE-ENTITIES row in use with that
*> id, 0 when there is none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-ID(WS-ROW) = L-ENTITY-ID
             MOVE WS-ROW TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-FIND-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TICKS-ANSWERED.
*> USING count (BINARY-LONG): see the list above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-PACKET-ID           BINARY-LONG VALUE 28.
 01 WS-LEFT                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE L-COUNT TO WS-LEFT
     PERFORM UNTIL WS-LEFT = 0
         COMPUTE WS-STEP = FUNCTION MIN(WS-LEFT, 100)
         CALL "TEST-TICKS" USING WS-STEP
         SUBTRACT WS-STEP FROM WS-LEFT
         PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
             IF CN-USED(WS-ID) = 1 AND CN-PHASE(WS-ID) = PH-PLAY AND CN-KA-PENDING(WS-ID) = 1
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
                 CALL "PB-PUT-LONG" USING PB-BUFFER CN-KA-ID(WS-ID)
                 CALL "TEST-FEED-BUFFER" USING WS-ID PB-BUFFER
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-TICKS-ANSWERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET-ID           BINARY-LONG VALUE 9.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-TIMESTAMP           BINARY-DOUBLE VALUE 1700000000000.
 01 WS-SALT                BINARY-DOUBLE VALUE 0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BITS                BINARY-LONG VALUE 20.
 01 WS-ACK                 PIC X(3) VALUE LOW-VALUES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-MESSAGE              PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-MESSAGE L-LENGTH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-STRING" USING PB-BUFFER L-MESSAGE L-LENGTH WS-MAX
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-TIMESTAMP
     CALL "PB-PUT-LONG" USING PB-BUFFER WS-SALT
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-FIXED-BITSET" USING PB-BUFFER WS-BITS WS-ACK
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CHAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-CHAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 124
             CALL "PB-GET-TEXT" USING PK-BUFFER PK-TEXT
             CALL "PB-GET-BOOL" USING PK-BUFFER WS-OVERLAY
             IF WS-PTR > 1
                 STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
             IF PK-ERROR = 1
                 STRING "malformed" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             ELSE
                 IF PK-TX-LENGTH > 0
                     STRING PK-TX-VALUE(1:PK-TX-LENGTH) DELIMITED BY SIZE INTO L-TEXT
                         POINTER WS-PTR
                 END-IF
                 IF PK-TX-KIND = PK-TEXT-TRANSLATE
                     STRING "(" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-TX-ARG-COUNT
                         IF WS-I > 1
                             STRING "," DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         END-IF
                         IF PK-TX-ARG-LENGTH(WS-I) > 0
                             STRING PK-TX-ARG-VALUE(WS-I)(1:PK-TX-ARG-LENGTH(WS-I))
                                 DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                         END-IF
                     END-PERFORM
                     STRING ")" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 IF WS-OVERLAY = 1
                     STRING "[overlay]" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-CHAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-TARGET.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TARGET
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIENT-COMMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 12.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ACTION
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CLIENT-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-HEALTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-R1                  PIC -(5)9.9.
 01 WS-R2                  PIC -(5)9.9.
 01 WS-R3                  PIC -(5)9.9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 106
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-FLOAT" USING PK-BUFFER WS-FLOAT
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     COMPUTE WS-E1 ROUNDED = WS-FLOAT
                     MOVE WS-A TO WS-E2
                     STRING "health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2)
                         DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 25
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-C
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     MOVE WS-C TO WS-E3
                     STRING "damage " FUNCTION TRIM(WS-E1) " type " FUNCTION TRIM(WS-E2)
                         " source " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT
                         POINTER WS-PTR
                 WHEN 43
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING "hurt " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO L-TEXT
                         POINTER WS-PTR
                 WHEN 69
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING "kill " FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO L-TEXT
                         POINTER WS-PTR
                     PERFORM ADD-TEXT
                 WHEN 124
                     PERFORM SEPARATE-ENTRY
                     STRING "chat " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                     PERFORM ADD-TEXT
                 WHEN 84
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-IDENTIFIER" USING PK-BUFFER WS-KEY WS-KEY-CAPACITY
                         WS-KEY-LENGTH
                     CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-B
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-A
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-A
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-BYTE" USING PK-BUFFER WS-C
                     MOVE WS-B TO WS-E2
                     MOVE WS-C TO WS-E3
                     STRING "respawn " WS-KEY(1:FUNCTION MAX(1, WS-KEY-LENGTH)) " mode "
                         FUNCTION TRIM(WS-E2) " keep " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
                 WHEN 73
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-X
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Y
                     CALL "PB-GET-DOUBLE" USING PK-BUFFER WS-Z
                     COMPUTE WS-R1 ROUNDED = WS-X
                     COMPUTE WS-R2 ROUNDED = WS-Y
                     COMPUTE WS-R3 ROUNDED = WS-Z
                     STRING "position " FUNCTION TRIM(WS-R1) " " FUNCTION TRIM(WS-R2) " "
                         FUNCTION TRIM(WS-R3) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.

 SEPARATE-ENTRY.
     IF WS-PTR > 1
         STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
     END-IF.

 ADD-TEXT.
     CALL "PB-GET-TEXT" USING PK-BUFFER PK-TEXT
     IF PK-TX-LENGTH > 0
         STRING PK-TX-VALUE(1:PK-TX-LENGTH) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
     END-IF
     IF PK-TX-KIND = PK-TEXT-TRANSLATE
         STRING "(" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-TX-ARG-COUNT
             IF WS-I > 1
                 STRING "," DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
             IF PK-TX-ARG-LENGTH(WS-I) > 0
                 STRING PK-TX-ARG-VALUE(WS-I)(1:PK-TX-ARG-LENGTH(WS-I))
                     DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
         END-PERFORM
         STRING ")" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
     END-IF.
 END PROGRAM TEST-DRAIN-HEALTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-USE-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 67.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ANGLE               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-ANGLE
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-ANGLE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-USE-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAYER-COMMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 42.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-ENTITY-ID(CN-PLAYER(L-ID))
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ACTION
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-PLAYER-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-HUNGER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 106
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-FLOAT" USING PK-BUFFER WS-FLOAT
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     COMPUTE WS-E1 ROUNDED = WS-FLOAT
                     MOVE WS-A TO WS-E2
                     STRING "health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2)
                         DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 34
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-INT" USING PK-BUFFER WS-A
                     CALL "PB-GET-BYTE" USING PK-BUFFER WS-B
                     MOVE WS-A TO WS-E1
                     MOVE WS-B TO WS-E2
                     STRING "event " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
                         DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 20
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-SHORT" USING PK-BUFFER WS-B
                     CALL "PB-GET-ITEMSTACK" USING PK-BUFFER PK-ITEMSTACK
                     MOVE WS-B TO WS-E1
                     MOVE PK-IS-ITEM TO WS-E2
                     MOVE PK-IS-COUNT TO WS-E3
                     STRING "slot " FUNCTION TRIM(WS-E1) "=" FUNCTION TRIM(WS-E2) "x"
                         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.

 SEPARATE-ENTRY.
     IF WS-PTR > 1
         STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
     END-IF.
 END PROGRAM TEST-DRAIN-HUNGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLACE-RECIPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 39.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-RECIPE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-RECIPE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-PLACE-RECIPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-CRAFT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             EVALUATE WS-PACKET-ID
                 WHEN 75
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-COUNT
                     MOVE WS-COUNT TO WS-E1
                     STRING "book " FUNCTION TRIM(WS-E1) " ids" DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                         CALL "PB-GET-RECIPE-ENTRY" USING PK-BUFFER PK-RECIPE-ENTRY PK-SLOT-DISPLAY-TABLE
                         MOVE PK-RE-DISPLAY-ID TO WS-E1
                         STRING " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
                             INTO L-TEXT POINTER WS-PTR
                     END-PERFORM
                     CALL "PB-GET-BOOL" USING PK-BUFFER WS-A
                     MOVE WS-A TO WS-E1
                     STRING " replace " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
                         INTO L-TEXT POINTER WS-PTR
                 WHEN 77
                     PERFORM SEPARATE-ENTRY
                     STRING "settings" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 WHEN 20
                     PERFORM SEPARATE-ENTRY
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-VARINT" USING PK-BUFFER WS-A
                     CALL "PB-GET-SHORT" USING PK-BUFFER WS-B
                     CALL "PB-GET-ITEMSTACK" USING PK-BUFFER PK-ITEMSTACK
                     MOVE WS-B TO WS-E1
                     MOVE PK-IS-ITEM TO WS-E2
                     MOVE PK-IS-COUNT TO WS-E3
                     STRING "slot " FUNCTION TRIM(WS-E1) "=" FUNCTION TRIM(WS-E2) "x"
                         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-EVALUATE
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.

 SEPARATE-ENTRY.
     IF WS-PTR > 1
         STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
     END-IF.
 END PROGRAM TEST-DRAIN-CRAFT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-WEATHER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(5)9.9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 39
             CALL "PB-GET-UBYTE" USING PK-BUFFER WS-EVENT
             CALL "PB-GET-FLOAT" USING PK-BUFFER WS-FLOAT
             IF WS-EVENT = 1 OR WS-EVENT = 2 OR WS-EVENT = 7 OR WS-EVENT = 8
                 IF WS-PTR > 1
                     STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 MOVE WS-EVENT TO WS-E1
                 COMPUTE WS-E2 ROUNDED = WS-FLOAT
                 STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
                     DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-WEATHER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBT-RENDER RECURSIVE.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-INT                 BINARY-LONG.
 01 LS-LONG                BINARY-DOUBLE.
 01 LS-FLOAT               FLOAT-SHORT.
 01 LS-DOUBLE              FLOAT-LONG.
 01 LS-EDIT                PIC -(18)9.
 01 LS-FEDIT               PIC -(12)9.999.
 01 LS-TEXT                PIC X(1024).
 01 LS-LENGTH              BINARY-LONG.
 01 LS-CAPACITY            BINARY-LONG VALUE 1024.
 01 LS-TYPE                BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-INTS.
    05 LS-INT-ITEM         BINARY-LONG OCCURS 64 TIMES.
 01 LS-INT-CAPACITY        BINARY-LONG VALUE 64.
 01 LS-NUMBER              PIC X(32).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-TEXT                 PIC X(8192).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-TEXT L-LENGTH.
     MOVE SPACES TO LS-NUMBER
     EVALUATE L-TYPE
         WHEN 1
             CALL "PB-GET-BYTE" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 2
             CALL "PB-GET-SHORT" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 3
             CALL "PB-GET-INT" USING PB-BUFFER LS-INT
             MOVE LS-INT TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 4
             CALL "PB-GET-LONG" USING PB-BUFFER LS-LONG
             MOVE LS-LONG TO LS-EDIT
             MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
         WHEN 5
             CALL "PB-GET-FLOAT" USING PB-BUFFER LS-FLOAT
             COMPUTE LS-FEDIT ROUNDED = LS-FLOAT
             MOVE FUNCTION TRIM(LS-FEDIT) TO LS-NUMBER
         WHEN 6
             CALL "PB-GET-DOUBLE" USING PB-BUFFER LS-DOUBLE
             COMPUTE LS-FEDIT ROUNDED = LS-DOUBLE
             MOVE FUNCTION TRIM(LS-FEDIT) TO LS-NUMBER
         WHEN 7
             CALL "PB-GET-INT" USING PB-BUFFER LS-COUNT
             CALL "PB-SKIP" USING PB-BUFFER LS-COUNT
             MOVE LS-COUNT TO LS-EDIT
             STRING "B" FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE INTO LS-NUMBER
         WHEN 8
             CALL "NBT-READ-STRING" USING PB-BUFFER LS-TEXT LS-CAPACITY LS-LENGTH
             IF LS-LENGTH > 0
                 MOVE LS-TEXT(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                 ADD LS-LENGTH TO L-LENGTH
             END-IF
         WHEN 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER LS-TYPE LS-COUNT
             MOVE "[" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT OR PB-ERROR = 1
                 IF LS-I > 1
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 CALL "TEST-NBT-RENDER" USING PB-BUFFER LS-TYPE L-TEXT L-LENGTH
             END-PERFORM
             MOVE "]" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 10
             MOVE "{" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
             MOVE 0 TO LS-I
             PERFORM UNTIL PB-ERROR = 1
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER LS-TYPE LS-TEXT LS-CAPACITY
                     LS-LENGTH
                 IF LS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 IF LS-I > 0
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 ADD 1 TO LS-I
                 IF LS-LENGTH > 0
                     MOVE LS-TEXT(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                     ADD LS-LENGTH TO L-LENGTH
                 END-IF
                 MOVE ":" TO L-TEXT(L-LENGTH + 1:1)
                 ADD 1 TO L-LENGTH
                 CALL "TEST-NBT-RENDER" USING PB-BUFFER LS-TYPE L-TEXT L-LENGTH
             END-PERFORM
             MOVE "}" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 11
             CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER LS-INT-CAPACITY LS-COUNT LS-INTS
             MOVE "I[" TO L-TEXT(L-LENGTH + 1:2)
             ADD 2 TO L-LENGTH
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                 IF LS-I > 1
                     MOVE "," TO L-TEXT(L-LENGTH + 1:1)
                     ADD 1 TO L-LENGTH
                 END-IF
                 MOVE LS-INT-ITEM(LS-I) TO LS-EDIT
                 MOVE FUNCTION TRIM(LS-EDIT) TO LS-NUMBER
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-NUMBER)) TO LS-LENGTH
                 MOVE LS-NUMBER(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
                 ADD LS-LENGTH TO L-LENGTH
             END-PERFORM
             MOVE SPACES TO LS-NUMBER
             MOVE "]" TO L-TEXT(L-LENGTH + 1:1)
             ADD 1 TO L-LENGTH
         WHEN 12
             CALL "PB-GET-INT" USING PB-BUFFER LS-COUNT
             COMPUTE LS-I = LS-COUNT * 8
             CALL "PB-SKIP" USING PB-BUFFER LS-I
             MOVE LS-COUNT TO LS-EDIT
             STRING "L" FUNCTION TRIM(LS-EDIT) DELIMITED BY SIZE INTO LS-NUMBER
     END-EVALUATE
     IF LS-NUMBER NOT = SPACES
         MOVE FUNCTION LENGTH(FUNCTION TRIM(LS-NUMBER)) TO LS-LENGTH
         MOVE LS-NUMBER(1:LS-LENGTH) TO L-TEXT(L-LENGTH + 1:LS-LENGTH)
         ADD LS-LENGTH TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM TEST-NBT-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COMPOUND            BINARY-LONG VALUE 10.
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROOT                 BINARY-LONG.
 01 L-PATH                 PIC X(128).
 01 L-TEXT                 PIC X(8192).
 PROCEDURE DIVISION USING PB-BUFFER L-ROOT L-PATH L-TEXT.
     MOVE SPACES TO L-TEXT
     IF L-ROOT < 0
         MOVE "absent (no file)" TO L-TEXT
         GOBACK
     END-IF
     MOVE L-ROOT TO PB-POS
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-PATH)) TO WS-PATH-LENGTH
     CALL "NBT-READ-FIND" USING PB-BUFFER WS-COMPOUND L-PATH WS-PATH-LENGTH WS-TYPE
     IF WS-TYPE = 0
         MOVE "absent" TO L-TEXT
     ELSE
         MOVE 0 TO WS-LENGTH
         CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE L-TEXT WS-LENGTH
     END-IF
     MOVE L-ROOT TO PB-POS
     GOBACK.
 END PROGRAM TEST-NBT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBT-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(256).
 01 L-ROOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH PB-BUFFER L-ROOT.
     MOVE -1 TO L-ROOT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-PATH)) TO WS-LENGTH
     CALL "NBT-FILE-READ" USING L-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME = 0
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
         MOVE PB-POS TO L-ROOT
     END-IF
     GOBACK.
 END PROGRAM TEST-NBT-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-SNAPSHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-FEDIT               PIC -(6)9.999.
 01 WS-D                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(8192).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE CW-TIME TO WS-EDIT
     STRING "time " FUNCTION TRIM(WS-EDIT) " spawn" DELIMITED BY SIZE INTO L-TEXT
         WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = CW-SPAWN-X
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = CW-SPAWN-Y
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = CW-SPAWN-Z
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = CW-SPAWN-YAW
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 2
         MOVE CW-WEATHER-KIND(WS-D) TO WS-EDIT
         STRING " | weather " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
             WITH POINTER WS-PTR
         MOVE CW-WEATHER-LEFT(WS-D) TO WS-EDIT
         STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE AC-ENFORCED TO WS-EDIT
     STRING " | enforced " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
         WITH POINTER WS-PTR
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 3
         STRING " | list" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > AC-COUNT(WS-L)
             STRING " " AC-NAME(WS-L, WS-ROW)(1:AC-NAME-LENGTH(WS-L, WS-ROW)) DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 2
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 3
             PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
                 IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = WS-D
                         AND EN-TYPE(WS-ROW) = WS-T
                     MOVE WS-D TO WS-EDIT
                     STRING " | dim " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     MOVE WS-T TO WS-EDIT
                     STRING " type " FUNCTION TRIM(WS-EDIT) " at" DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     COMPUTE WS-FEDIT ROUNDED = EN-X(WS-ROW)
                     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     COMPUTE WS-FEDIT ROUNDED = EN-Y(WS-ROW)
                     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     COMPUTE WS-FEDIT ROUNDED = EN-Z(WS-ROW)
                     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     COMPUTE WS-FEDIT ROUNDED = EN-YAW(WS-ROW)
                     STRING " yaw " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     MOVE EN-HEALTH(WS-ROW) TO WS-EDIT
                     STRING " health " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     MOVE EN-ITEM(WS-ROW) TO WS-EDIT
                     STRING " item " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     MOVE EN-ITEM-COUNT(WS-ROW) TO WS-EDIT
                     STRING "x" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                     MOVE EN-AGE(WS-ROW) TO WS-EDIT
                     STRING " age " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT
                         WITH POINTER WS-PTR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-WORLD-SNAPSHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAYER-SNAPSHOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EDIT                PIC -(9)9.
 01 WS-FEDIT               PIC -(6)9.999.
 01 WS-S                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TEXT                 PIC X(8192).
 PROCEDURE DIVISION USING L-ROW L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE PL-DIM(L-ROW) TO WS-EDIT
     STRING "dim " FUNCTION TRIM(WS-EDIT) " at" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-X(L-ROW)
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-Y(L-ROW)
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-Z(L-ROW)
     STRING " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-YAW(L-ROW)
     STRING " yaw " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-PITCH(L-ROW)
     STRING " pitch " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     MOVE PL-MODE(L-ROW) TO WS-EDIT
     STRING " mode " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     COMPUTE WS-FEDIT ROUNDED = PL-HEALTH(L-ROW)
     STRING " health " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     MOVE PL-FOOD(L-ROW) TO WS-EDIT
     STRING " food " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     MOVE PL-HELD(L-ROW) TO WS-EDIT
     STRING " held " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     MOVE PL-DEATH-CAUSE(L-ROW) TO WS-EDIT
     STRING " death " FUNCTION TRIM(WS-EDIT) " inventory" DELIMITED BY SIZE INTO L-TEXT
         WITH POINTER WS-PTR
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
         IF PL-SLOT-COUNT(L-ROW, WS-S) > 0
             COMPUTE WS-EDIT = WS-S - 1
             STRING " " FUNCTION TRIM(WS-EDIT) "=" DELIMITED BY SIZE INTO L-TEXT
                 WITH POINTER WS-PTR
             MOVE PL-SLOT-ITEM(L-ROW, WS-S) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) "x" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             MOVE PL-SLOT-COUNT(L-ROW, WS-S) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-PLAYER-SNAPSHOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHAT-COMMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET-ID           BINARY-LONG VALUE 7.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COMMAND              PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-COMMAND L-LENGTH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-STRING" USING PB-BUFFER L-COMMAND L-LENGTH WS-MAX
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-CHAT-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COMMAND              PIC X(768).
 PROCEDURE DIVISION USING L-ID L-COMMAND.
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-COMMAND TRAILING))
     CALL "TEST-CHAT-COMMAND" USING L-ID L-COMMAND WS-LENGTH
     GOBACK.
 END PROGRAM TEST-COMMAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SUGGEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET-ID           BINARY-LONG VALUE 15.
 01 WS-MAX                 BINARY-LONG VALUE 32500.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TRANSACTION          BINARY-LONG.
 01 L-TEXT                 PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-TRANSACTION L-TEXT L-LENGTH.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TRANSACTION
     CALL "PB-PUT-STRING" USING PB-BUFFER L-TEXT L-LENGTH WS-MAX
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-SUGGEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-SUGGESTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-CAP                 BINARY-LONG VALUE 256.
 01 WS-WORD                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-ID L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = 15
             IF WS-PTR > 1
                 STRING " | " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
             PERFORM 3 TIMES
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-VALUE
                 MOVE WS-VALUE TO WS-EDIT
                 STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-PERFORM
             CALL "PB-GET-VARINT" USING PK-BUFFER WS-COUNT
             STRING "[" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 CALL "PB-GET-STRING" USING PK-BUFFER WS-MAX WS-WORD WS-CAP WS-LENGTH
                 CALL "PB-GET-BOOL" USING PK-BUFFER WS-HAS
                 IF WS-I > 1
                     STRING "," DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 IF WS-LENGTH > 0
                     STRING WS-WORD(1:WS-LENGTH) DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
                 IF WS-HAS NOT = 0
                     STRING "(tooltip)" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
                 END-IF
             END-PERFORM
             STRING "]" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             IF PK-ERROR = 1 OR PK-POS NOT = PK-LENGTH
                 STRING " malformed" DELIMITED BY SIZE INTO L-TEXT POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-SUGGESTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DRAIN-PACKET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER L-FOUND.
     MOVE 0 TO L-FOUND
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID ST-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR L-FOUND = 1
         CALL "TEST-NEXT-PACKET" USING ST-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-PACKET-ID
             MOVE 1 TO L-FOUND
             CALL "PB-RESET" USING PB-BUFFER
             SET ADDRESS OF B-AREA TO PK-ADDR
             CALL "PB-APPEND-BYTES" USING PB-BUFFER B-AREA PK-LENGTH
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING ST-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM TEST-DRAIN-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HELLO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-PATH                PIC X(256).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ID.
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND L-ID
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER L-NAME L-NAME-LENGTH WS-MAX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "TEST-FEED-BUFFER" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-HELLO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONFIGURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ID.
     CALL "TEST-HELLO" USING L-NAME L-NAME-LENGTH L-ID
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     GOBACK.
 END PROGRAM TEST-CONFIGURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACK-RESPONSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(256).
 01 WS-EDIT                PIC 9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ACTION.
     MOVE L-ACTION TO WS-EDIT
     MOVE SPACES TO WS-PATH
     STRING "contract/fixtures/wire/config-c2s-06-resource-pack-response-" WS-EDIT ".hex"
         DELIMITED BY SIZE INTO WS-PATH
     CALL "TEST-FEED" USING L-ID WS-PATH
     GOBACK.
 END PROGRAM TEST-PACK-RESPONSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DROP-MOVES.
*> USING text (PIC X(1024), in and out): the description of TEST-DRAIN-ENTITIES / TEST-DRAIN-BLOCKS without the Teleport Entity
*> packets (the tokens "128", "128(<id>)" and "128(<id>)x<n>"), for tests whose subject is not the motion of a ground item
*> (an item's creep after a break is not what a break, a pickup or a throw test asserts: 41 section 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUT                 PIC X(1024).
 01 WS-TOKEN               PIC X(120).
 01 WS-POS                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE SPACES TO WS-OUT
     MOVE 1 TO WS-POS WS-PTR
     MOVE 0 TO WS-DONE
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(L-TEXT))
     IF WS-LEN = 0
         GOBACK
     END-IF
     PERFORM UNTIL WS-DONE = 1
         MOVE SPACES TO WS-TOKEN
         UNSTRING L-TEXT(1:WS-LEN) DELIMITED BY ALL SPACE INTO WS-TOKEN POINTER WS-POS
         IF WS-POS > WS-LEN
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-TOKEN NOT = SPACES AND WS-TOKEN NOT = "128" AND WS-TOKEN(1:4) NOT = "128("
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-OUT POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-TOKEN) DELIMITED BY SIZE INTO WS-OUT POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE WS-OUT TO L-TEXT
     GOBACK.
 END PROGRAM TEST-DROP-MOVES.
