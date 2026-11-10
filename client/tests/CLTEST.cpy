*> Test helpers of the client package (test infrastructure, excluded from coverage). COPY this after
*> the END PROGRAM of a test program; it adds these programs to the test executable:
*>   TEST-LOAD-HEX USING path (PIC X(256)), PB-BUFFER: replaces the buffer content with the bytes
*>     of a hex fixture (contracts/proto-api.md §3: whitespace-separated hex, "#" comments).
*>   TEST-HEX-OF USING area, count (at most 512), hex out (PIC X(1024)): lowercase hex.
*>   TEST-CAPTURE-START USING path (PIC X(256)): standard output goes to that file (no TEST line
*>     may be printed until TEST-CAPTURE-STOP).
*>   TEST-CAPTURE-STOP USING path, text out (PIC X(4096)): standard output restored; the captured
*>     lines, " | "-separated.
*>   TEST-SAME-AS-FIXTURE USING packet PB-BUFFER (id + body, from byte 1), path, TESTLIB-ASSERT
*>     (TL-CASE set): asserts the packet bytes equal the fixture bytes; on a difference the
*>     observed text names the first differing offset and both bytes, or both lengths.
*>   TEST-FEED USING CLIENT-STATE, connection, path (PIC X(256)): loads the fixture packet and
*>     hands it to PROTO-PACKET as received on that connection.
*>   TEST-SENT USING CLIENT-STATE, connection, index (1-based), packet PB-BUFFER (initialised),
*>     found out: the index-th packet queued in the connection's outbound bytes (CN-OUT, framed with
*>     CN-THRESHOLD), id + body.
*>   TEST-SENT-IDS USING CLIENT-STATE, connection, text out (PIC X(1024)): the ids of every queued
*>     packet as two hex digits, space-separated.
*>   TEST-CLEAR-SENT USING CLIENT-STATE, connection: forgets the queued outbound bytes.
*>   TEST-LOOPBACK USING CLIENT-STATE, connection, server handle out: a real loopback TCP
*>     connection: the test listens on a system-chosen port, the connection's CN-HANDLE connects
*>     to it, and the accepted server side is returned (the listener is closed again).
*>   TEST-SERVE USING server handle, path (PIC X(256)), threshold: sends the fixture packet framed
*>     as the server does (compression format when the threshold is 0 or more).
*>   TEST-SERVE-BYTES USING server handle, area, count: sends raw bytes.
*>   TEST-SERVER-READ-HEX USING server handle, text out (PIC X(1024)), threshold: like
*>     TEST-SERVER-READ, but each complete packet other than Client Tick End (0x0D) and Move
*>     Player (0x1E to 0x21) as the lowercase hex of its id and body, space-separated.
*>   TEST-SERVER-READ USING server handle, text out (PIC X(1024)), threshold: waits up to a second
*>     for data, then lists the ids of the complete packets received as two hex digits each
*>     ("closed" when the client has closed the connection).
*>   TEST-MESH-FACE USING mesh address (POINTER), vertex count, centre x, y, z (FLOAT-SHORT,
*>     section-local), found out, brightness out, u out, v out (FLOAT-SHORT): the quad (6 vertices
*>     top-left, top-right, bottom-right, top-left, bottom-right, bottom-left) whose centre is that
*>     point; u and v of its top-left corner.
*>   TEST-STEP USING CLIENT-STATE: one CL-STEP without events, 20 ms after the last.
*>   TEST-EVENTS USING CLIENT-STATE, event table (TEST-EVENT-TABLE), count: one CL-STEP with those
*>     events.
*>   TEST-EVENTS-MS USING CLIENT-STATE, event table, count, milliseconds: the same, that many ms
*>     after the last step (one clock shared by every stepping helper).
*>   TEST-TICKS USING CLIENT-STATE, count: that many CL-STEPs without events, 50 ms apart (one
*>     client tick each).
*>   TEST-KEY-TICK USING CLIENT-STATE, key code, event kind (CC-EV-KEY-DOWN or CC-EV-KEY-UP): one
*>     CL-STEP 50 ms after the last (one client tick) with that key event.
*>   TEST-PLAY USING CLIENT-STATE, server handle out: a started client (game directory
*>     build/client-test-play) in play on the world screen over a real loopback connection, the
*>     cursor captured, the player loaded at (0.5, 10, 0.5) facing +Z (yaw 0, pitch 0, on the
*>     ground, that position already sent) on a flat floor: chunks -1 to 1 by -1 to 1 hold
*>     greystone (state 2) at y 0 to 9 and sky light 15 above; Time 6000; survival with health 30
*>     and food 24 (as after Login).
*>   TEST-ENTITY USING CLIENT-STATE, entity id, text (PIC X(1024), appended): " <id> <type>
*>     <x>/<y>/<z> <yaw>/<pitch>/<head yaw> <on ground>" (4 and 1 decimals) of the replica's entity,
*>     or " <id> none".
*>   TEST-POSITION USING CLIENT-STATE, text (PIC X(1024), appended): " <x>/<y>/<z>" of the local
*>     player (4 decimals).
*>   TEST-ANGLES USING CLIENT-STATE, text (appended): " <yaw>/<pitch>" (1 decimal).
*>   TEST-SET-BLOCK USING CLIENT-STATE, x, y, z, state: sets one replica cell (the chunk row is
*>     taken when absent) and marks the chunk to be meshed.
*>   TEST-CLICK USING CLIENT-STATE, action, argument (0 = any): clicks (button 0 down and up) the
*>     centre of the first widget with that action, in one CL-STEP; found out.
*>   TEST-TYPE USING CLIENT-STATE, text (PIC X(64)), length: one CL-STEP with a text event per
*>     byte.
*>   TEST-KEY USING CLIENT-STATE, key code: one CL-STEP with the key down and up.
*>   TEST-SCREEN-TEXTS USING CLIENT-STATE, text out (PIC X(1024)): the texts of the current screen
*>     model's widgets, "|"-separated.
*>   TEST-SLEEP: waits 10 ms.
*>   TEST-CLOSE-REQUEST: queues a close-requested event (shim-abi §8 kind 9) on the open game
*>     window as the window system does: it finds the shim's window (dlsym of cc_win_window), takes
*>     the close callback the shim registered (glfwSetWindowCloseCallback hands back the previous
*>     one, which is registered again) and calls it. Test infrastructure, no test double.
*>   TEST-READ-FILE USING path (PIC X(256)), area, capacity, length out: the file's bytes (at most
*>     the capacity); length -1 when it cannot be opened.
*>   TEST-ADD-ITEM USING CLIENT-STATE, connection, entity id, x, y, z (FLOAT-LONG), count, item:
*>     hands PROTO-PACKET an Add Entity of a loose_item there (motion 0, 09 §3.3) and its Set
*>     Entity Data with that stack.
*>   TEST-TELEPORT-ENTITY USING CLIENT-STATE, connection, entity id, x, y, z (FLOAT-LONG), on
*>     ground: hands PROTO-PACKET a Teleport Entity (motion 0, angles 0, relative flags 0).
*>   TEST-TAKE-ITEM USING CLIENT-STATE, connection, collected id, collector id, amount: hands
*>     PROTO-PACKET a Take Item Entity.
*>   TEST-REMOVE-ENTITY USING CLIENT-STATE, connection, entity id: hands PROTO-PACKET a Remove
*>     Entities of that one entity.
*>   TEST-GROUND-ITEM USING CLIENT-STATE, entity id, text (PIC X(1024), appended): " <id>
*>     <count>x<item> <vx>/<vy>/<vz>" (4 decimals) of the replica's entity, or " <id> none".
*>   TEST-SYSTEM-CHAT USING CLIENT-STATE, connection, text (PIC X(64)), length: hands PROTO-PACKET
*>     a System Chat (0x7C) of that plain string text, overlay false.
*>   TEST-SET-HEALTH USING CLIENT-STATE, connection, health (FLOAT-SHORT), food: hands
*>     PROTO-PACKET a Set Health (0x6A) with saturation 0.
*>   TEST-FEED-STARTING-ITEMS USING CLIENT-STATE, connection: hands PROTO-PACKET a Container Set Content (0x12) of container 0
*>     in the 46-slot menu order (13 section 3.5), state id 1, with the starting inventory of the 001 fixture: hotbar 0 to 7 the items
*>     2 to 9 x 64, hotbar 8 the pry bar (item 10) x 1, main slot 9 (menu 9) the trowel (item 11) x 1; no cursor stack.
*>   TEST-FEED-BENCH-ITEMS USING CLIENT-STATE, connection, container id, state id: hands PROTO-PACKET a Container Set Content (0x12)
*>     of the crafting bench menu (13 section 3.5; the fixture play-s2c-12-container-set-content-crafting-bench.hex for any container
*>     id): the result 1 x cobblestone (item 62), grid slots 1 and 5 1 x oak planks (item 63), hotbar 0 (slot 37) 64 x stone (item 1).
*>   TEST-FEED-CLOSE USING CLIENT-STATE, connection, container id: hands PROTO-PACKET a Container Close (0x11) of that container.
*>   TEST-FEED-SET-SLOT USING CLIENT-STATE, connection, container id, state id, slot, count, item: hands PROTO-PACKET a Container
*>     Set Slot (0x14) with that stack (no components).
*>   TEST-FEED-DAMAGED-SLOT USING CLIENT-STATE, connection, container id, state id, slot, item, damage, max damage: hands PROTO-PACKET a
*>     Container Set Slot (0x14) of 1 of that item with the components damage (3) and max_damage (2).
*>   TEST-FEED-PLAYER-SLOT USING CLIENT-STATE, connection, player index, count, item: hands PROTO-PACKET a Set Player Inventory (0x6E).
*>   TEST-FIGURE-FACE USING CLIENT-STATE, spec (PIC X(40): label, then the eye-relative face
*>     centre x y z), text (appended): " <label> <u>/<v> <brightness>" of the entity-mesh quad
*>     with that centre (u and v of its top-left corner), or " <label> none".
*>   TEST-ENTITY-DRAWS USING CLIENT-STATE, text (appended): " <entity vertices> <draws on texture
*>     1> <empty uploads of the entity slot>" of the last render list.
*>   TEST-GAME-EVENT USING CLIENT-STATE, connection, event, value (FLOAT-SHORT): hands
*>     PROTO-PACKET a Game Event (0x27) of that event and value.
*>   TEST-SET-BIOME USING CLIENT-STATE, x, y, z, biome id: sets the replica's biome of the
*>     4 x 4 x 4 cell holding that block (its chunk loaded).
*>   TEST-SP-START USING CLIENT-STATE, game directory (PIC X(64)), length: the directory removed,
*>     then a started client (CL-INIT, name Alice, CL-START) whose single-player settings have view
*>     distance 2 and no hostile mobs (quicker joins; the rest are SP-DEFAULTS).
*>   TEST-SP-JOIN USING CLIENT-STATE, joined out: CL-STEPs 50 ms apart (at most 400) until the game
*>     connection is in play and the player loaded (PL-LOADED of an earlier join is cleared
*>     first); joined 1 when it is.
*>   TEST-NBT-TAG USING path (PIC X(256)), path length, tag name (PIC X(64)), number out
*>     (BINARY-LONG), text out (PIC X(64)): a top-level Byte or Int tag's value, or a String tag's
*>     text, of a gzip NBT file; number -999 and text "none" when the file or the tag is missing.
*>   TEST-TESTSRV-START USING directory (PIC X(256)), options (PIC X(256): further testsrv.py
*>     options such as "--chunked", "--status 404", "--oversize 5000", "--request-log <file>", or
*>     spaces), http port out, https port out (BINARY-LONG): runs tools/testsrv/testsrv.py serving
*>     that directory over HTTP and HTTPS on free 127.0.0.1 ports and waits until it listens. The
*>     test CA is created with tools/testsrv/make-ca.sh when build/testsrv/ca.pem is absent, and
*>     SSL_CERT_FILE is set to it (absolute), so cc_tls trusts the server (research R10; the shim
*>     tests do the same through shim/tests/tls_testsrv.h). One server at a time: a server still
*>     running is stopped first. Ends the test program (status 2) when the server does not start.
*>   TEST-TESTSRV-STOP: stops the server of TEST-TESTSRV-START (SIGTERM, waits until it has gone);
*>     nothing when none runs. Call it before the test program ends.

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
 PROGRAM-ID. TEST-HEX-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 B-AREA                 PIC X(512) BASED.
 LINKAGE SECTION.
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-HEX                  PIC X(1024).
 PROCEDURE DIVISION USING L-AREA L-COUNT L-HEX.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     MOVE SPACES TO L-HEX
     COMPUTE WS-COUNT = FUNCTION MIN(L-COUNT, 512)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(B-AREA(WS-I:1)))
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
 PROGRAM-ID. TEST-READ-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ACCESS              PIC X COMP-X VALUE 1.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               BINARY-CHAR UNSIGNED.
 01 WS-DUMMY               PIC X.
 01 WS-SIZE                BINARY-LONG.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-AREA L-CAPACITY L-LENGTH.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     MOVE -1 TO L-LENGTH
     CALL "CBL_OPEN_FILE" USING L-PATH WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
     IF RETURN-CODE = 0
         MOVE 0 TO WS-OFFSET WS-COUNT
         MOVE 128 TO WS-FLAGS
         CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS WS-DUMMY
         MOVE WS-OFFSET TO WS-SIZE
         MOVE FUNCTION MIN(WS-SIZE, L-CAPACITY) TO L-LENGTH
         MOVE 0 TO WS-OFFSET WS-FLAGS
         MOVE L-LENGTH TO WS-COUNT
         IF L-LENGTH > 0
             CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS B-AREA
         END-IF
         CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     END-IF
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM TEST-READ-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-PATH.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-ID
     GOBACK.
 END PROGRAM TEST-FEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-OUT.
    05 WS-OUT-ADDR         USAGE POINTER.
    05 WS-OUT-CAPACITY     BINARY-LONG.
    05 WS-OUT-LENGTH       BINARY-LONG.
    05 WS-OUT-POS          BINARY-LONG.
    05 WS-OUT-ERROR        PIC 9.
 01 B-OUT                  PIC X(1073741824) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 COPY PROTO.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-INDEX PB-BUFFER L-FOUND.
     IF WS-READY = 0
         CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING ST-BUFFER
     MOVE CN-OUT(L-CONN) TO WS-OUT
     SET ADDRESS OF B-OUT TO WS-OUT-ADDR
     IF WS-OUT-LENGTH > 0
         CALL "PB-APPEND-BYTES" USING ST-BUFFER B-OUT WS-OUT-LENGTH
     END-IF
     MOVE 0 TO L-FOUND
     MOVE 0 TO WS-OUTCOME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-INDEX OR WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PB-FRAME-DECODE" USING ST-BUFFER PB-BUFFER CN-THRESHOLD(L-CONN) WS-ZERO WS-ID
             WS-OUTCOME
     END-PERFORM
*>   Callers read the packet from its first byte, the id: PB-POS 0.
     IF WS-OUTCOME = 0
         MOVE 1 TO L-FOUND
         MOVE 0 TO PB-POS
     END-IF
     GOBACK.
 END PROGRAM TEST-SENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SENT-IDS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BYTE                PIC X.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-TEXT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-FOUND = 0
         CALL "TEST-SENT" USING CLIENT-STATE L-CONN WS-I PB-BUFFER WS-FOUND
         IF WS-FOUND = 1
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-ID
             MOVE FUNCTION CHAR(WS-ID + 1) TO WS-BYTE
             STRING FUNCTION TRIM(L-TEXT) " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-BYTE))
                 DELIMITED BY SIZE INTO L-TEXT
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-SENT-IDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLEAR-SENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     MOVE CN-OUT(L-CONN) TO PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     MOVE PB-BUFFER TO CN-OUT(L-CONN)
     GOBACK.
 END PROGRAM TEST-CLEAR-SENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOOPBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WAIT                BINARY-LONG VALUE 1000.
 01 WS-LISTENER            BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-HOST                PIC X(16) VALUE Z"127.0.0.1".
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG.
 01 WS-READY               PIC X(2).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-SERVER.
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE WS-LISTENER
         BY REFERENCE WS-PORT RETURNING WS-RC
     CALL STATIC "cc_net_connect" USING BY REFERENCE WS-HOST BY VALUE WS-PORT
         BY REFERENCE CN-HANDLE(L-CONN) RETURNING WS-RC
     MOVE WS-LISTENER TO WS-HANDLE
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     CALL STATIC "cc_net_accept" USING BY VALUE WS-LISTENER BY REFERENCE L-SERVER
         RETURNING WS-RC
     CALL STATIC "cc_net_close" USING BY VALUE WS-LISTENER
     GOBACK.
 END PROGRAM TEST-LOOPBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SERVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 B-FRAME                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-THRESHOLD            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-PATH L-THRESHOLD.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING FR-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "TEST-LOAD-HEX" USING L-PATH PB-BUFFER
     CALL "PB-RESET" USING FR-BUFFER
     CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER L-THRESHOLD
     SET ADDRESS OF B-FRAME TO FR-ADDR
     CALL "TEST-SERVE-BYTES" USING L-SERVER B-FRAME FR-LENGTH
     GOBACK.
 END PROGRAM TEST-SERVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SERVER-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 WS-READY-INIT          BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WAIT                BINARY-LONG VALUE 1000.
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG.
 01 WS-READY               PIC X(2).
 01 WS-RC                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-AREA                PIC X(65536).
 01 WS-AREA-CAP            BINARY-LONG VALUE 65536.
 01 WS-ID                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-BYTE                PIC X.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-THRESHOLD            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-TEXT L-THRESHOLD.
     IF WS-READY-INIT = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY-INIT
     END-IF
     MOVE SPACES TO L-TEXT
     MOVE L-SERVER TO WS-HANDLE
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_recv" USING BY VALUE L-SERVER BY REFERENCE WS-AREA
             BY VALUE WS-AREA-CAP BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0
             CALL "PB-APPEND-BYTES" USING ST-BUFFER WS-AREA WS-GOT
         END-IF
     END-PERFORM
     IF WS-RC = 4 AND ST-LENGTH = 0
         MOVE "closed" TO L-TEXT
     END-IF
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PB-FRAME-DECODE" USING ST-BUFFER PB-BUFFER L-THRESHOLD WS-ZERO WS-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             MOVE FUNCTION CHAR(WS-ID + 1) TO WS-BYTE
             STRING FUNCTION TRIM(L-TEXT) " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-BYTE))
                 DELIMITED BY SIZE INTO L-TEXT
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-SERVER-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SERVER-READ-HEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 WS-READY-INIT          BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-WAIT                BINARY-LONG VALUE 1000.
 01 WS-HANDLES.
    05 WS-HANDLE           BINARY-LONG.
 01 WS-READY               PIC X(2).
 01 WS-RC                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-AREA                PIC X(65536).
 01 WS-AREA-CAP            BINARY-LONG VALUE 65536.
 01 WS-ID                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HEX                 PIC X(1024).
 01 WS-BYTE                PIC X.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 01 L-THRESHOLD            BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-TEXT L-THRESHOLD.
     IF WS-READY-INIT = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY-INIT
     END-IF
     MOVE SPACES TO L-TEXT
     MOVE L-SERVER TO WS-HANDLE
     CALL STATIC "cc_net_poll" USING BY VALUE WS-WAIT BY REFERENCE WS-HANDLES BY VALUE WS-ONE
         BY VALUE WS-ZERO BY REFERENCE WS-READY RETURNING WS-RC
     CALL "PB-RESET" USING ST-BUFFER
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_recv" USING BY VALUE L-SERVER BY REFERENCE WS-AREA
             BY VALUE WS-AREA-CAP BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0
             CALL "PB-APPEND-BYTES" USING ST-BUFFER WS-AREA WS-GOT
         END-IF
     END-PERFORM
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "PB-RESET" USING PB-BUFFER
         CALL "PB-FRAME-DECODE" USING ST-BUFFER PB-BUFFER L-THRESHOLD WS-ZERO WS-ID WS-OUTCOME
         IF WS-OUTCOME = 0 AND WS-ID NOT = 13 AND (WS-ID < 30 OR WS-ID > 33)
             MOVE FUNCTION CHAR(WS-ID + 1) TO WS-BYTE
             STRING FUNCTION TRIM(L-TEXT) " " FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-BYTE))
                 DELIMITED BY SIZE INTO L-TEXT
             COMPUTE WS-REST = PB-LENGTH - PB-POS
             IF WS-REST > 0
                 SET ADDRESS OF B-AREA TO PB-ADDR
                 MOVE SPACES TO WS-HEX
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-REST OR WS-I > 512
                     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(B-AREA(PB-POS + WS-I:1)))
                         TO WS-HEX(WS-I * 2 - 1:2)
                 END-PERFORM
                 STRING FUNCTION TRIM(L-TEXT) FUNCTION TRIM(WS-HEX) DELIMITED BY SIZE
                     INTO L-TEXT
             END-IF
         END-IF
     END-PERFORM
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-SERVER-READ-HEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SERVE-BYTES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SENT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-AREA L-COUNT.
     CALL STATIC "cc_net_send" USING BY VALUE L-SERVER BY REFERENCE L-AREA BY VALUE L-COUNT
         BY REFERENCE WS-SENT RETURNING WS-RC
     GOBACK.
 END PROGRAM TEST-SERVE-BYTES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VERTEX-TINTS.
*> USING CLIENT-STATE, layer (PIC XX: UI, IC, UT, HL, BO, GI, HD hand, WX, EN), ok out (BINARY-LONG): 1
*> when the layer has vertices and every one has tint (1, 1, 1) and sky 0 (an untinted vertex that does
*> not follow the daylight, shim-abi section 9), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 B-LAYER BASED.
    05 B-VERTEX OCCURS 24576 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-A              FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LAYER                PIC XX.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LAYER L-OK.
     MOVE 0 TO L-OK WS-COUNT
     EVALUATE L-LAYER
         WHEN "UI"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-UI-VERTEX(1)
             MOVE RL-UI-COUNT TO WS-COUNT
         WHEN "IC"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-IC-VERTEX(1)
             MOVE RL-IC-COUNT TO WS-COUNT
         WHEN "UT"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-UT-VERTEX(1)
             MOVE RL-UT-COUNT TO WS-COUNT
         WHEN "HL"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-HL-VERTEX(1)
             MOVE RL-HL-COUNT TO WS-COUNT
         WHEN "BO"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-BO-VERTEX(1)
             MOVE RL-BO-COUNT TO WS-COUNT
         WHEN "GI"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-GI-VERTEX(1)
             MOVE RL-GI-COUNT TO WS-COUNT
         WHEN "HD"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-HAND-VERTEX(1)
             MOVE RL-HAND-COUNT TO WS-COUNT
         WHEN "WX"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-WX-VERTEX(1)
             MOVE RL-WX-COUNT TO WS-COUNT
         WHEN "EN"
             SET ADDRESS OF B-LAYER TO ADDRESS OF RL-EN-VERTEX(1)
             MOVE RL-EN-COUNT TO WS-COUNT
     END-EVALUATE
     IF WS-COUNT > 0
         MOVE 1 TO L-OK
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             IF B-R(WS-I) NOT = 1 OR B-G(WS-I) NOT = 1 OR B-BLUE(WS-I) NOT = 1 OR B-SKY(WS-I) NOT = 0
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM TEST-VERTEX-TINTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESH-VERTEX.
*> USING mesh address (POINTER), vertex count, centre x, y, z (FLOAT-SHORT, section-local), found out,
*> brightness out, u out, v out, sky out, red out, green out, blue out (FLOAT-SHORT): the raw fields of the
*> first vertex of the quad (6 vertices) whose centre is that (the vertex of 11 floats: shim-abi section 9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 B-VERTICES BASED.
    05 B-VERTEX OCCURS 1000000 TIMES.
       10 B-X              FLOAT-SHORT.
       10 B-Y              FLOAT-SHORT.
       10 B-Z              FLOAT-SHORT.
       10 B-U              FLOAT-SHORT.
       10 B-V              FLOAT-SHORT.
       10 B-B              FLOAT-SHORT.
       10 B-ALPHA          FLOAT-SHORT.
       10 B-SKY            FLOAT-SHORT.
       10 B-R              FLOAT-SHORT.
       10 B-G              FLOAT-SHORT.
       10 B-BLUE           FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ADDR                 USAGE POINTER.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    FLOAT-SHORT.
 01 L-Y                    FLOAT-SHORT.
 01 L-Z                    FLOAT-SHORT.
 01 L-FOUND                BINARY-LONG.
 01 L-BRIGHTNESS           FLOAT-SHORT.
 01 L-U                    FLOAT-SHORT.
 01 L-V                    FLOAT-SHORT.
 01 L-SKY                  FLOAT-SHORT.
 01 L-R                    FLOAT-SHORT.
 01 L-G                    FLOAT-SHORT.
 01 L-BLUE                 FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ADDR L-COUNT L-X L-Y L-Z L-FOUND L-BRIGHTNESS L-U L-V L-SKY L-R L-G
         L-BLUE.
     MOVE 0 TO L-FOUND L-BRIGHTNESS L-U L-V L-SKY L-R L-G L-BLUE
     IF L-COUNT > 0
         SET ADDRESS OF B-VERTICES TO L-ADDR
     END-IF
     PERFORM VARYING WS-Q FROM 0 BY 6 UNTIL WS-Q >= L-COUNT OR L-FOUND = 1
         COMPUTE WS-A = WS-Q + 1
         COMPUTE WS-B = WS-Q + 3
         IF FUNCTION ABS((B-X(WS-A) + B-X(WS-B)) / 2 - L-X) < 0.001
                 AND FUNCTION ABS((B-Y(WS-A) + B-Y(WS-B)) / 2 - L-Y) < 0.001
                 AND FUNCTION ABS((B-Z(WS-A) + B-Z(WS-B)) / 2 - L-Z) < 0.001
             MOVE 1 TO L-FOUND
             MOVE B-B(WS-A) TO L-BRIGHTNESS
             MOVE B-U(WS-A) TO L-U
             MOVE B-V(WS-A) TO L-V
             MOVE B-SKY(WS-A) TO L-SKY
             MOVE B-R(WS-A) TO L-R
             MOVE B-G(WS-A) TO L-G
             MOVE B-BLUE(WS-A) TO L-BLUE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-MESH-VERTEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MESH-FACE.
*> As TEST-MESH-VERTEX, but only brightness out: the drawn brightness at full daylight, max(brightness, sky).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 FLOAT-SHORT.
 01 WS-R                   FLOAT-SHORT.
 01 WS-G                   FLOAT-SHORT.
 01 WS-BLUE                FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ADDR                 USAGE POINTER.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    FLOAT-SHORT.
 01 L-Y                    FLOAT-SHORT.
 01 L-Z                    FLOAT-SHORT.
 01 L-FOUND                BINARY-LONG.
 01 L-BRIGHTNESS           FLOAT-SHORT.
 01 L-U                    FLOAT-SHORT.
 01 L-V                    FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ADDR L-COUNT L-X L-Y L-Z L-FOUND L-BRIGHTNESS L-U L-V.
     CALL "TEST-MESH-VERTEX" USING L-ADDR L-COUNT L-X L-Y L-Z L-FOUND L-BRIGHTNESS L-U L-V WS-SKY
         WS-R WS-G WS-BLUE
     IF WS-SKY > L-BRIGHTNESS
         MOVE WS-SKY TO L-BRIGHTNESS
     END-IF
     GOBACK.
 END PROGRAM TEST-MESH-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-ZERO
     GOBACK.
 END PROGRAM TEST-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EVENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MS                  BINARY-LONG VALUE 20.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EVENTS               PIC X.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EVENTS L-COUNT.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE L-EVENTS L-COUNT WS-MS
     GOBACK.
 END PROGRAM TEST-EVENTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TICKS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MS                  BINARY-LONG VALUE 50.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-COUNT.
     PERFORM L-COUNT TIMES
         CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-ZERO WS-MS
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-KEY-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 FILLER              PIC X(16).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MS                  BINARY-LONG VALUE 50.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KIND.
     INITIALIZE WS-EVENT
     MOVE L-KIND TO WS-KIND
     MOVE L-KEY TO WS-A
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     GOBACK.
 END PROGRAM TEST-KEY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EVENTS-MS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 BINARY-DOUBLE VALUE 1000000.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EVENTS               PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EVENTS L-COUNT L-MS.
     ADD L-MS TO WS-NOW
     CALL "CL-STEP" USING CLIENT-STATE L-EVENTS L-COUNT WS-NOW
     GOBACK.
 END PROGRAM TEST-EVENTS-MS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SERVER               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SERVER.
     CALL "SYSTEM" USING "rm -rf build/client-test-play"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-play" TO CL-GAME-DIR
     MOVE 22 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "NET-BUFFERS-INIT" USING CLIENT-STATE WS-CONN
     CALL "TEST-LOOPBACK" USING CLIENT-STATE WS-CONN L-SERVER
     MOVE PH-PLAY TO CN-PHASE(WS-CONN)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY PL-LOADED PL-POSITIONED IN-CAPTURED PL-ON-GROUND PL-SENT-FLAGS
     MOVE 3 TO RG-BIOMES
     MOVE 6000 TO PL-TIME
     MOVE 20 TO PL-HEALTH
     MOVE 20 TO PL-FOOD
     PERFORM VARYING WS-X FROM -16 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM -16 BY 1 UNTIL WS-Z > 31
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 9
                 CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO PL-X PL-Z PL-SENT-X PL-SENT-Z
     MOVE 10 TO PL-Y PL-SENT-Y
     MOVE 0 TO PL-YAW PL-PITCH PL-SENT-YAW PL-SENT-PITCH
     GOBACK.
 END PROGRAM TEST-PLAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-STATE.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         MOVE ALL X"FF" TO CE-SKYS
     END-IF
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     COMPUTE WS-LY = L-Y - PL-MIN-Y
     COMPUTE WS-LX = L-X - WS-CX * 16
     COMPUTE WS-LZ = L-Z - WS-CZ * 16
     COMPUTE WS-CELL = WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
     MOVE L-STATE TO CE-STATE(WS-CELL)
     IF L-STATE NOT = 0
         CALL "LIGHT-SET" USING WR-ADDR(WS-ROW) WS-KIND WS-LY WS-LX WS-LZ WS-LEVEL
     END-IF
     CALL "WORLD-DIRTY" USING CLIENT-STATE WS-CX WS-CZ
     GOBACK.
 END PROGRAM TEST-SET-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG L-FOUND.
     MOVE 0 TO WS-W L-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT OR WS-W > 0
         IF SM-W-ACTION(WS-I) = L-ACTION AND (L-ARG = 0 OR SM-W-ARG(WS-I) = L-ARG)
             MOVE WS-I TO WS-W
         END-IF
     END-PERFORM
     IF WS-W > 0
         MOVE 1 TO L-FOUND
         INITIALIZE WS-EVENTS
         MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
         MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
         MOVE CC-BUTTON-LEFT TO WS-A(1) WS-A(2)
         COMPUTE WS-X(1) = (SM-W-X(WS-W) + SM-W-W(WS-W) / 2) * CL-GUI-SCALE
         COMPUTE WS-Y(1) = (SM-W-Y(WS-W) + SM-W-H(WS-W) / 2) * CL-GUI-SCALE
         MOVE WS-X(1) TO WS-X(2)
         MOVE WS-Y(1) TO WS-Y(2)
         CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-TWO
     END-IF
     GOBACK.
 END PROGRAM TEST-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 64 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     INITIALIZE WS-EVENTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         MOVE CC-EV-TEXT TO WS-KIND(WS-I)
         COMPUTE WS-A(WS-I) = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
     END-PERFORM
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS L-LENGTH
     GOBACK.
 END PROGRAM TEST-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY.
     INITIALIZE WS-EVENTS
     MOVE CC-EV-KEY-DOWN TO WS-KIND(1)
     MOVE CC-EV-KEY-UP TO WS-KIND(2)
     MOVE L-KEY TO WS-A(1) WS-A(2)
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENTS WS-TWO
     GOBACK.
 END PROGRAM TEST-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SCREEN-TEXTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-EDIT2               PIC Z(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-SHOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SPRITE
             CONTINUE
         ELSE
             ADD 1 TO WS-SHOWN
             IF WS-SHOWN > 1
                 STRING "|" DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             END-IF
*>           A meter reads as its old label: "Health <value>/<maximum>" or "Food <value>/<maximum>" (half icons).
             IF SM-W-KIND(WS-I) = WK-METER
                 MOVE SM-W-STATE(WS-I) TO WS-EDIT
                 MOVE SM-W-ACTION(WS-I) TO WS-EDIT2
                 IF SM-W-ARG(WS-I) = 1
                     STRING "Health " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
                         INTO L-TEXT WITH POINTER WS-PTR
                 ELSE
                     STRING "Food " FUNCTION TRIM(WS-EDIT) "/" FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE
                         INTO L-TEXT WITH POINTER WS-PTR
                 END-IF
             END-IF
             IF SM-W-LENGTH(WS-I) > 0
                 STRING SM-W-TEXT(WS-I)(1:SM-W-LENGTH(WS-I)) DELIMITED BY SIZE
                     INTO L-TEXT WITH POINTER WS-PTR
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-SCREEN-TEXTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SLEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MICROS              BINARY-LONG VALUE 10000.
 PROCEDURE DIVISION.
     CALL STATIC "usleep" USING BY VALUE WS-MICROS
     GOBACK.
 END PROGRAM TEST-SLEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLOSE-REQUEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEFAULT             USAGE POINTER.
 01 WS-SYM                 USAGE POINTER.
 01 WS-NAME                PIC X(16) VALUE Z"cc_win_window".
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-CALLBACK.
    05 WS-CALLBACK-PTR     USAGE POINTER.
 01 WS-CALLBACK-PROGRAM REDEFINES WS-CALLBACK USAGE PROGRAM-POINTER.
 01 B-WINDOW               USAGE POINTER BASED.
 PROCEDURE DIVISION.
*>   RTLD_DEFAULT is (void *) -2 on macOS.
     SET WS-DEFAULT TO NULL
     SET WS-DEFAULT DOWN BY 2
     CALL STATIC "dlsym" USING BY VALUE WS-DEFAULT BY REFERENCE WS-NAME RETURNING WS-SYM
     SET ADDRESS OF B-WINDOW TO WS-SYM
     CALL STATIC "glfwSetWindowCloseCallback" USING BY VALUE B-WINDOW BY VALUE WS-NULL
         RETURNING WS-CALLBACK-PTR
     CALL STATIC "glfwSetWindowCloseCallback" USING BY VALUE B-WINDOW BY VALUE WS-CALLBACK-PTR
         RETURNING WS-SYM
     CALL WS-CALLBACK-PROGRAM USING BY VALUE B-WINDOW
     GOBACK.
 END PROGRAM TEST-CLOSE-REQUEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  PIC -(9)9.
 01 WS-TYPE                PIC -(9)9.
 01 WS-X                   PIC -(6)9.9(4).
 01 WS-Y                   PIC -(6)9.9(4).
 01 WS-Z                   PIC -(6)9.9(4).
 01 WS-YAW                 PIC -(4)9.9.
 01 WS-PITCH               PIC -(4)9.9.
 01 WS-HEAD                PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TEXT.
     CALL "ENTITY-FIND" USING CLIENT-STATE L-ID WS-ROW
     MOVE L-ID TO WS-ID
     IF WS-ROW = 0
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-ID) " none" DELIMITED BY SIZE
             INTO L-TEXT
     ELSE
         MOVE EN-TYPE(WS-ROW) TO WS-TYPE
         COMPUTE WS-X ROUNDED = EN-X(WS-ROW)
         COMPUTE WS-Y ROUNDED = EN-Y(WS-ROW)
         COMPUTE WS-Z ROUNDED = EN-Z(WS-ROW)
         COMPUTE WS-YAW ROUNDED = EN-YAW(WS-ROW)
         COMPUTE WS-PITCH ROUNDED = EN-PITCH(WS-ROW)
         COMPUTE WS-HEAD ROUNDED = EN-HEAD-YAW(WS-ROW)
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-ID) " " FUNCTION TRIM(WS-TYPE) " "
             FUNCTION TRIM(WS-X) "/" FUNCTION TRIM(WS-Y) "/" FUNCTION TRIM(WS-Z) " "
             FUNCTION TRIM(WS-YAW) "/" FUNCTION TRIM(WS-PITCH) "/" FUNCTION TRIM(WS-HEAD) " "
             EN-ON-GROUND(WS-ROW) DELIMITED BY SIZE INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-POSITION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   PIC -(6)9.9(4).
 01 WS-Y                   PIC -(6)9.9(4).
 01 WS-Z                   PIC -(6)9.9(4).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     COMPUTE WS-X ROUNDED = PL-X
     COMPUTE WS-Y ROUNDED = PL-Y
     COMPUTE WS-Z ROUNDED = PL-Z
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-X) "/" FUNCTION TRIM(WS-Y) "/"
         FUNCTION TRIM(WS-Z) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-POSITION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ANGLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 PIC -(4)9.9.
 01 WS-PITCH               PIC -(4)9.9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     COMPUTE WS-YAW ROUNDED = PL-YAW
     COMPUTE WS-PITCH ROUNDED = PL-PITCH
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-YAW) "/" FUNCTION TRIM(WS-PITCH)
         DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-ANGLES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ADD-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-DATA                BINARY-LONG VALUE 101.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID.
    05 WS-UUID-HI          PIC X(8).
    05 WS-UUID-LO          PIC X(8).
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-LONG-X REDEFINES WS-LONG PIC X(8).
 01 WS-I                   BINARY-LONG.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-ANGLE               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-ID L-X L-Y L-Z L-COUNT L-ITEM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
*>   The UUID: most significant 64 bits 0, least significant the entity id (big-endian).
     MOVE LOW-VALUES TO WS-UUID
     MOVE L-ID TO WS-LONG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-LONG-X(9 - WS-I:1) TO WS-UUID-LO(WS-I:1)
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     PERFORM 3 TIMES
         CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-ANGLE
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-ADD
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE PB-METADATA-ENTRY
     MOVE 0 TO PB-MD-INDEX
     MOVE PB-MDS-ITEM-STACK TO PB-MD-SERIALIZER
     MOVE L-COUNT TO PB-MD-IS-COUNT
     MOVE L-ITEM TO PB-MD-IS-ITEM
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE PB-MD-END TO PB-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER PB-METADATA-ENTRY
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM TEST-ADD-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TELEPORT-ENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET              BINARY-LONG VALUE 128.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DZERO               FLOAT-LONG VALUE 0.
 01 WS-FZERO               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-GROUND               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-ID L-X L-Y L-Z L-GROUND.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     PERFORM 3 TIMES
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-DZERO
     END-PERFORM
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FZERO
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-FZERO
     CALL "PB-PUT-INT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-GROUND
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-TELEPORT-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TAKE-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 127.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-COLLECTED            BINARY-LONG.
 01 L-COLLECTOR            BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-COLLECTED L-COLLECTOR L-AMOUNT.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COLLECTED
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COLLECTOR
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-AMOUNT
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-TAKE-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REMOVE-ENTITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 78.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-ID.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-REMOVE-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROUND-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  PIC -(9)9.
 01 WS-COUNT               PIC -(9)9.
 01 WS-ITEM                PIC -(9)9.
 01 WS-VX                  PIC -(3)9.9(4).
 01 WS-VY                  PIC -(3)9.9(4).
 01 WS-VZ                  PIC -(3)9.9(4).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TEXT.
     CALL "ENTITY-FIND" USING CLIENT-STATE L-ID WS-ROW
     MOVE L-ID TO WS-ID
     IF WS-ROW = 0
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-ID) " none" DELIMITED BY SIZE
             INTO L-TEXT
     ELSE
         MOVE EN-STACK-COUNT(WS-ROW) TO WS-COUNT
         MOVE EN-STACK-ITEM(WS-ROW) TO WS-ITEM
         COMPUTE WS-VX ROUNDED = EN-VX(WS-ROW)
         COMPUTE WS-VY ROUNDED = EN-VY(WS-ROW)
         COMPUTE WS-VZ ROUNDED = EN-VZ(WS-ROW)
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-ID) " " FUNCTION TRIM(WS-COUNT) "x"
             FUNCTION TRIM(WS-ITEM) " " FUNCTION TRIM(WS-VX) "/" FUNCTION TRIM(WS-VY) "/"
             FUNCTION TRIM(WS-VZ) DELIMITED BY SIZE INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-GROUND-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SYSTEM-CHAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET              BINARY-LONG VALUE 124.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-TEXT L-LENGTH.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE L-TEXT TO PB-TX-VALUE
     MOVE L-LENGTH TO PB-TX-LENGTH
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-SYSTEM-CHAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-HEALTH.
*> USING CLIENT-STATE, connection, health (FLOAT-SHORT), food: hands PROTO-PACKET a Set Health
*> (0x6A) with saturation 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 106.
 01 WS-ZERO                FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-HEALTH               FLOAT-SHORT.
 01 L-FOOD                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-HEALTH L-FOOD.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-HEALTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-FOOD
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-SET-HEALTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-STARTING-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-PACKET              BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOTS               BINARY-LONG VALUE 46.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SLOTS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 45
         MOVE 0 TO WS-COUNT WS-ITEM
         IF WS-I >= 36 AND WS-I <= 43
             MOVE 64 TO WS-COUNT
             COMPUTE WS-ITEM = WS-I - 34
         END-IF
         IF WS-I = 44
             MOVE 1 TO WS-COUNT
             MOVE 10 TO WS-ITEM
         END-IF
         IF WS-I = 9
             MOVE 1 TO WS-COUNT
             MOVE 11 TO WS-ITEM
         END-IF
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
         IF WS-COUNT > 0
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ITEM
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-STARTING-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-BENCH-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-PACKET              BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SLOTS               BINARY-LONG VALUE 46.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-CONTAINER L-STATE-ID.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SLOTS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 45
         MOVE 0 TO WS-COUNT WS-ITEM
         IF WS-I = 0
             MOVE 1 TO WS-COUNT
             MOVE 62 TO WS-ITEM
         END-IF
         IF WS-I = 1 OR WS-I = 5
             MOVE 1 TO WS-COUNT
             MOVE 63 TO WS-ITEM
         END-IF
         IF WS-I = 37
             MOVE 64 TO WS-COUNT
             MOVE 1 TO WS-ITEM
         END-IF
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
         IF WS-COUNT > 0
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ITEM
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         END-IF
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-BENCH-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 17.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-CONTAINER.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-SET-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET              BINARY-LONG VALUE 20.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-CONTAINER L-STATE-ID L-SLOT L-COUNT L-ITEM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-ITEM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     END-IF
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-SET-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-DAMAGED-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET              BINARY-LONG VALUE 20.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-CONTAINER            BINARY-LONG.
 01 L-STATE-ID             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-CONTAINER L-STATE-ID L-SLOT L-ITEM L-DAMAGE L-MAX.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-CONTAINER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-STATE-ID
     CALL "PB-PUT-SHORT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ITEM
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-THREE
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-DAMAGE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-TWO
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-MAX
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-DAMAGED-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEED-PLAYER-SLOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET              BINARY-LONG VALUE 110.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-SLOT L-COUNT L-ITEM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     IF L-COUNT > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-ITEM
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     END-IF
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-FEED-PLAYER-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FIGURE-FACE.
*> USING CLIENT-STATE, spec (PIC X(40): label, then the eye-relative face centre x y z), text
*> (appended): " <label> <u>/<v> <brightness>" of the entity quad with that centre, or
*> " <label> none".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LABEL               PIC X(8).
 01 WS-SX                  PIC X(12).
 01 WS-SY                  PIC X(12).
 01 WS-SZ                  PIC X(12).
 01 WS-X                   FLOAT-SHORT.
 01 WS-Y                   FLOAT-SHORT.
 01 WS-Z                   FLOAT-SHORT.
 01 WS-FOUND               BINARY-LONG.
 01 WS-B                   FLOAT-SHORT.
 01 WS-U                   FLOAT-SHORT.
 01 WS-V                   FLOAT-SHORT.
 01 WS-ADDR                USAGE POINTER.
 01 WS-EU                  PIC 9.9(4).
 01 WS-EV                  PIC 9.9(4).
 01 WS-EB                  PIC 9.99.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SPEC                 PIC X(40).
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-SPEC L-TEXT.
     MOVE SPACES TO WS-LABEL WS-SX WS-SY WS-SZ
     UNSTRING L-SPEC DELIMITED BY ALL SPACE INTO WS-LABEL WS-SX WS-SY WS-SZ
     COMPUTE WS-X = FUNCTION NUMVAL(WS-SX)
     COMPUTE WS-Y = FUNCTION NUMVAL(WS-SY)
     COMPUTE WS-Z = FUNCTION NUMVAL(WS-SZ)
     SET WS-ADDR TO ADDRESS OF RL-EN-VERTEX(1)
     CALL "TEST-MESH-FACE" USING WS-ADDR RL-EN-COUNT WS-X WS-Y WS-Z WS-FOUND WS-B WS-U WS-V
     IF WS-FOUND = 1
         COMPUTE WS-EU ROUNDED = WS-U
         COMPUTE WS-EV ROUNDED = WS-V
         COMPUTE WS-EB ROUNDED = WS-B
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " " WS-EU "/" WS-EV " " WS-EB
             DELIMITED BY SIZE INTO L-TEXT
     ELSE
         STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-LABEL) " none" DELIMITED BY SIZE
             INTO L-TEXT
     END-IF
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-FIGURE-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-DRAWS.
*> USING CLIENT-STATE, text (appended): " <entity vertices> <draws on texture 1> <empty uploads of
*> the entity slot>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-RELEASED            BINARY-LONG.
 01 WS-EDIT                PIC Z(4)9.
 01 WS-EDIT2               PIC Z(4)9.
 01 WS-EDIT3               PIC Z(4)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT.
     MOVE 0 TO WS-DRAWS WS-RELEASED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-TEX(WS-I) = CC-TEX-ENTITIES AND RL-D-SLOT(WS-I) = MESH-SLOT-ENTITIES
             ADD 1 TO WS-DRAWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-UPLOAD-COUNT
         IF RL-U-SLOT(WS-I) = MESH-SLOT-ENTITIES AND RL-U-COUNT(WS-I) = 0
             ADD 1 TO WS-RELEASED
         END-IF
     END-PERFORM
     MOVE RL-EN-COUNT TO WS-EDIT
     MOVE WS-DRAWS TO WS-EDIT2
     MOVE WS-RELEASED TO WS-EDIT3
     STRING FUNCTION TRIM(L-TEXT) " " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " "
         FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO L-TEXT
     MOVE FUNCTION TRIM(L-TEXT) TO L-TEXT
     GOBACK.
 END PROGRAM TEST-ENTITY-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAME-EVENT.
*> USING CLIENT-STATE, connection, event, value (FLOAT-SHORT): hands PROTO-PACKET a Game Event
*> (0x27): UByte event, Float value.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG VALUE 39.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-VALUE                FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-EVENT L-VALUE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-EVENT
     CALL "PB-PUT-FLOAT" USING PB-BUFFER L-VALUE
     MOVE 0 TO PB-POS
     CALL "PROTO-PACKET" USING CLIENT-STATE L-CONN PB-BUFFER WS-PACKET
     GOBACK.
 END PROGRAM TEST-GAME-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SET-BIOME.
*> USING CLIENT-STATE, x, y, z (block coordinates in a loaded chunk), biome id: sets the replica's
*> biome of the 4 x 4 x 4 cell holding that block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-BIOME.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     COMPUTE WS-LX = (L-X - WS-CX * 16) / 4
     COMPUTE WS-LZ = (L-Z - WS-CZ * 16) / 4
     COMPUTE WS-LY = (L-Y - PL-MIN-Y) / 4
     COMPUTE WS-I = WS-LY * 16 + WS-LZ * 4 + WS-LX + 1
     MOVE L-BIOME TO CE-BIOME(WS-I)
     GOBACK.
 END PROGRAM TEST-SET-BIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SP-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-COMMAND             PIC X(128).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DIR                  PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DIR L-LENGTH.
     MOVE LOW-VALUES TO WS-COMMAND
     STRING "rm -rf " L-DIR(1:L-LENGTH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE L-DIR TO CL-GAME-DIR
     MOVE L-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
*>   The tests that start a hosted world do not look at the packs banner of the title screen.
     MOVE 0 TO CL-PACKS-STATUS
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE CORE-SETTINGS TO SP-SETTINGS
     GOBACK.
 END PROGRAM TEST-SP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SP-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-JOINED               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-JOINED.
     MOVE 0 TO L-JOINED PL-LOADED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR L-JOINED = 1
         CALL "TEST-TICKS" USING CLIENT-STATE WS-ONE
         IF CN-PHASE(CONN-GAME) = PH-PLAY AND PL-LOADED = 1
             MOVE 1 TO L-JOINED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEST-SP-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NBT-TAG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 256.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-TAG                  PIC X(64).
 01 L-NUMBER               BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING L-PATH L-PATH-LENGTH L-TAG L-NUMBER L-TEXT.
     MOVE -999 TO L-NUMBER
     MOVE "none" TO L-TEXT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING L-PATH L-PATH-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME = 0
         CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
         MOVE 1 TO WS-TYPE
         PERFORM UNTIL WS-TYPE = 0
             MOVE SPACES TO WN
             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
             EVALUATE TRUE
                 WHEN WS-TYPE = 0
                     CONTINUE
                 WHEN WN = L-TAG AND WS-TYPE = 1
                     CALL "PB-GET-BYTE" USING PB-BUFFER L-NUMBER
                 WHEN WN = L-TAG AND WS-TYPE = 3
                     CALL "PB-GET-INT" USING PB-BUFFER L-NUMBER
                 WHEN WN = L-TAG AND WS-TYPE = 8
                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP WS-TEXT-LENGTH
                     MOVE SPACES TO L-TEXT
                     MOVE WS-TEXT(1:WS-TEXT-LENGTH) TO L-TEXT
                 WHEN OTHER
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
             END-EVALUATE
         END-PERFORM
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM TEST-NBT-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TESTSRV-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 TEST-TESTSRV-PID       BINARY-LONG EXTERNAL.
 01 WS-SELF                BINARY-LONG.
 01 WS-SELF-TEXT           PIC 9(9).
 01 WS-CA                  PIC X(64) VALUE Z"build/testsrv/ca.pem".
 01 WS-CA-ABS              PIC X(1024).
 01 WS-CA-PTR              USAGE POINTER.
 01 WS-READY               PIC X(256).
 01 WS-PID-FILE            PIC X(256).
 01 WS-COMMAND             PIC X(2048).
 01 WS-TEXT                PIC X(256).
 01 WS-TEXT-1 REDEFINES WS-TEXT PIC X.
 01 WS-TEXT-CAP            BINARY-LONG VALUE 256.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 50000.
 01 WS-WORDS.
    05 WS-WORD             PIC X(32) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(256).
 01 L-OPTIONS              PIC X(256).
 01 L-HTTP                 BINARY-LONG.
 01 L-HTTPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-OPTIONS L-HTTP L-HTTPS.
     CALL "TEST-TESTSRV-STOP"
     CALL "SYSTEM" USING "mkdir -p build/testsrv && (test -f build/testsrv/ca.pem"
         & " || sh tools/testsrv/make-ca.sh >/dev/null)"
     IF RETURN-CODE NOT = 0
         DISPLAY "TEST-TESTSRV-START: make-ca.sh failed"
         STOP RUN RETURNING 2
     END-IF
     MOVE LOW-VALUES TO WS-CA-ABS
     CALL STATIC "realpath" USING BY REFERENCE WS-CA BY REFERENCE WS-CA-ABS
         RETURNING WS-CA-PTR
     MOVE 0 TO WS-LENGTH
     INSPECT WS-CA-ABS TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL LOW-VALUE
     SET ENVIRONMENT "SSL_CERT_FILE" TO WS-CA-ABS(1:WS-LENGTH)
     CALL STATIC "getpid" RETURNING WS-SELF
     MOVE WS-SELF TO WS-SELF-TEXT
     MOVE SPACES TO WS-READY WS-PID-FILE WS-COMMAND
     STRING "build/testsrv/ready-" WS-SELF-TEXT DELIMITED BY SIZE INTO WS-READY
     STRING "build/testsrv/pid-" WS-SELF-TEXT DELIMITED BY SIZE INTO WS-PID-FILE
     STRING "rm -f " FUNCTION TRIM(WS-READY) " " FUNCTION TRIM(WS-PID-FILE)
         "; python3 tools/testsrv/testsrv.py --dir " FUNCTION TRIM(L-DIR)
         " --http-port 0 --https-port 0 " FUNCTION TRIM(L-OPTIONS)
         " --ready-file " FUNCTION TRIM(WS-READY) " >/dev/null 2>&1 & echo $! > "
         FUNCTION TRIM(WS-PID-FILE) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE -1 TO WS-LENGTH
     PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 200 OR WS-LENGTH > 0
         CALL STATIC "usleep" USING BY VALUE WS-MICROS
         MOVE SPACES TO WS-TEXT
         CALL "TEST-READ-FILE" USING WS-READY WS-TEXT-1 WS-TEXT-CAP WS-LENGTH
     END-PERFORM
     MOVE SPACES TO WS-WORDS
     IF WS-LENGTH > 0
         UNSTRING WS-TEXT DELIMITED BY "=" OR " " OR X"0A"
             INTO WS-WORD(1) WS-WORD(2) WS-WORD(3) WS-WORD(4)
     END-IF
     MOVE FUNCTION NUMVAL(WS-WORD(2)) TO L-HTTP
     MOVE FUNCTION NUMVAL(WS-WORD(4)) TO L-HTTPS
     MOVE SPACES TO WS-TEXT
     CALL "TEST-READ-FILE" USING WS-PID-FILE WS-TEXT-1 WS-TEXT-CAP WS-LENGTH
     MOVE FUNCTION NUMVAL(WS-TEXT) TO TEST-TESTSRV-PID
     MOVE SPACES TO WS-COMMAND
     STRING "rm -f " FUNCTION TRIM(WS-READY) " " FUNCTION TRIM(WS-PID-FILE)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     IF L-HTTP = 0 OR L-HTTPS = 0
         DISPLAY "TEST-TESTSRV-START: testsrv.py did not start"
         CALL "TEST-TESTSRV-STOP"
         STOP RUN RETURNING 2
     END-IF
     GOBACK.
 END PROGRAM TEST-TESTSRV-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TESTSRV-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 TEST-TESTSRV-PID       BINARY-LONG EXTERNAL.
 01 WS-TERM                BINARY-LONG VALUE 15.
 01 WS-PROBE               BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-MICROS              BINARY-LONG VALUE 50000.
 PROCEDURE DIVISION.
     IF TEST-TESTSRV-PID > 0
         CALL STATIC "kill" USING BY VALUE TEST-TESTSRV-PID BY VALUE WS-TERM RETURNING WS-RC
         MOVE 0 TO WS-RC
         PERFORM VARYING WS-TRIES FROM 1 BY 1 UNTIL WS-TRIES > 100 OR WS-RC NOT = 0
             CALL STATIC "usleep" USING BY VALUE WS-MICROS
             CALL STATIC "kill" USING BY VALUE TEST-TESTSRV-PID BY VALUE WS-PROBE
                 RETURNING WS-RC
         END-PERFORM
         MOVE 0 TO TEST-TESTSRV-PID
     END-IF
     GOBACK.
 END PROGRAM TEST-TESTSRV-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CAPTURE-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 CLT-SAVED-FD           BINARY-LONG EXTERNAL.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-STDOUT              BINARY-LONG VALUE 1.
 01 WS-MODE                BINARY-LONG VALUE 420.
 01 WS-FD                  BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PATH                PIC X(257).
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-PATH.
     MOVE LOW-VALUES TO WS-PATH
     STRING L-PATH DELIMITED BY SPACE INTO WS-PATH
     CALL STATIC "fflush" USING BY VALUE WS-NULL RETURNING WS-RC
     CALL STATIC "dup" USING BY VALUE WS-STDOUT RETURNING CLT-SAVED-FD
     CALL STATIC "creat" USING BY REFERENCE WS-PATH BY VALUE WS-MODE RETURNING WS-FD
     CALL STATIC "dup2" USING BY VALUE WS-FD BY VALUE WS-STDOUT RETURNING WS-RC
     CALL STATIC "close" USING BY VALUE WS-FD RETURNING WS-RC
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM TEST-CAPTURE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CAPTURE-STOP.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT OUT-FILE ASSIGN TO WS-PATH
         ORGANIZATION LINE SEQUENTIAL
         FILE STATUS WS-STATUS.
 DATA DIVISION.
 FILE SECTION.
 FD OUT-FILE.
 01 OUT-LINE               PIC X(1024).
 WORKING-STORAGE SECTION.
 01 CLT-SAVED-FD           BINARY-LONG EXTERNAL.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-STDOUT              BINARY-LONG VALUE 1.
 01 WS-RC                  BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-STATUS              PIC XX.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-TEXT                 PIC X(4096).
 PROCEDURE DIVISION USING L-PATH L-TEXT.
     CALL STATIC "fflush" USING BY VALUE WS-NULL RETURNING WS-RC
     CALL STATIC "dup2" USING BY VALUE CLT-SAVED-FD BY VALUE WS-STDOUT RETURNING WS-RC
     CALL STATIC "close" USING BY VALUE CLT-SAVED-FD RETURNING WS-RC
     MOVE L-PATH TO WS-PATH
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-AT
     OPEN INPUT OUT-FILE
     PERFORM UNTIL WS-STATUS NOT = "00"
         MOVE SPACES TO OUT-LINE
         READ OUT-FILE
         IF WS-STATUS = "00"
             IF WS-AT > 1
                 STRING " | " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-AT
             END-IF
             STRING FUNCTION TRIM(OUT-LINE TRAILING) DELIMITED BY SIZE INTO L-TEXT
                 WITH POINTER WS-AT
         END-IF
     END-PERFORM
     CLOSE OUT-FILE
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM TEST-CAPTURE-STOP.
