*> The client side of the protocol (docs/protocol/02, 03, 04, 05a/05b/05c; 09-cobolcraft-profile.md
*> §1 to §3.2): packet builders (CLP-*), PROTO-CONNECTED (what is sent once a connection is up),
*> PROTO-PACKET (every packet received, by phase), CLIENT-DISCONNECT and the text renderers.
*> Status: Intention (status), Status Request; Status Response fills the server-list entry
*> (description, online and maximum players, version; a protocol other than 777 is incompatible),
*> Ping Request, and Pong ends the exchange. Login: Intention (login), Hello with the offline UUID;
*> Set Compression, Login Finished (Login Acknowledged, brand, Client Information), Login Disconnect.
*> Configuration: registries kept (dimension types, biome count), Select Known Packs answered with
*> an empty list, Keep Alive echoed, Finish Configuration answered. Play: Login, Player Position
*> (accepted; a correction of the local player's position), abilities (flying), spawn, time, held
*> slot, inventory, chunks into the replica and forgotten, the chunk cache centre, Chunk Batch
*> Received after each batch, Player Loaded once, Keep Alive echoed, Disconnect; entities and the
*> player list into the entity replica (entities-replica.cob). Moving: Move Player (CLP-MOVE-SEND
*> each client tick) and Player Abilities (the fly toggle). Blocks and inventory (US4): Player
*> Action, Use Item On, Set Carried Item, Container Click and Set Creative Mode Slot builders
*> (controls.cob and the inventory screen send them); Block Update, Section Blocks Update and Light
*> Update into the replica (world-replica.cob), Block Changed Ack and Block Destruction kept, the
*> inventory packets into the inventory replica (inventory-replica.cob). Chat (US6): the Chat
*> builder (screens/chat.cob sends it); System Chat into the chat history (screens/hud.cob).
*> Health (US7): the Attack builder (controls.cob sends it) and the Client Command builder (the
*> death screen's respawn control); Set Health kept for the HUD, Damage Event and Hurt Animation for
*> the local player start the hurt indication, Player Combat Kill for the local player opens the
*> death screen with its message, Respawn enters the dimension it names (as Login does: the replica
*> emptied, the world screen shown; the server sends the world again).
*> Hunger (US8): the Use Item, release-use-item Player Action and Player Command builders
*> (controls.cob sends them; the food level is the Set Health field the HUD shows); Entity Event 9
*> (eating finished) for the local player ends its eating. Entering a dimension (Login, Respawn)
*> ends sprinting and eating: the server clears both on death, respawn and travel.
*> Crafting (US10): the Place Recipe builder (screens/crafting.cob sends it); Recipe Book Add into
*> the recipe book (RECIPE-BOOK-READ). Weather (US11): the weather Game Events set the rain and
*> thunder levels and the kind they map to (weather-render.cob and sky.cob draw it); the biome
*> registry's has_precipitation is kept for where it is drawn.
*> Commands (US14): the Chat Command and Command Suggestion builders (screens/chat.cob sends them);
*> Commands into the command tree (COMMANDS-READ), Command Suggestions into the answers to the last
*> request (SUGGESTIONS-READ); Game Event 3 sets the game mode and the abilities that go with it
*> (09 §3.2 Player Abilities: creative may fly, survival may not and stops flying).
*> Server packs (US18): Resource Pack Push and Pop, configuration and play, go to packs/download.cob
*> (PACK-PUSH, PACK-POP), which answers with Resource Pack Response.
*> The programs of the packet families are split out (T2944): protocol-config.cob (handshake, status, login,
*> configuration), protocol-play.cob (play builders and readers), protocol-world.cob (entering a dimension).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROTO-CONNECTED.
*> USING CLIENT-STATE, connection: the connection is up and in CN-PHASE: a status connection sends
*> Intention (status) and Status Request, a login connection Intention (login) and Hello.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-INTENT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 1 TO WS-INTENT
     IF CN-PHASE(L-CONN) = PH-LOGIN
         MOVE 2 TO WS-INTENT
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-INTENTION" USING PB-BUFFER CN-HOST(L-CONN) CN-HOST-LENGTH(L-CONN) CN-PORT(L-CONN)
         WS-INTENT
     CALL "NET-SEND" USING CLIENT-STATE L-CONN PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     IF WS-INTENT = 1
         CALL "CLP-SIMPLE" USING PB-BUFFER WS-ZERO
     ELSE
         CALL "CLP-HELLO" USING PB-BUFFER CL-NAME CL-NAME-LENGTH
     END-IF
     CALL "NET-SEND" USING CLIENT-STATE L-CONN PB-BUFFER
     GOBACK.
 END PROGRAM PROTO-CONNECTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROTO-PACKET.
*> USING CLIENT-STATE, connection, packet PB-BUFFER (PB-POS after the id), packet id. Packets the
*> client does not use are ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO REPLACING LEADING ==PB-== BY ==OUT-==.
 COPY JSONDOC.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PHASE               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-JSON                PIC X(32767).
 01 WS-JSON-MAX            BINARY-LONG VALUE 32767.
 01 WS-JSON-CAP            BINARY-LONG VALUE 32767.
 01 WS-JSON-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-ID                  BINARY-LONG.
 01 WS-RATE                FLOAT-SHORT VALUE 9.0.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-DIM                 PIC X(64).
 01 WS-DIM-CAP             BINARY-LONG VALUE 64.
 01 WS-DIM-LENGTH          BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-PACKET              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-PACKET.
    05 L-ADDR              USAGE POINTER.
    05 L-CAPACITY          BINARY-LONG.
    05 L-LENGTH            BINARY-LONG.
    05 L-POS               BINARY-LONG.
    05 L-ERROR             PIC 9.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-PACKET L-ID.
     IF WS-READY = 0
         CALL "PB-INIT" USING OUT-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING OUT-BUFFER
     MOVE CN-PHASE(L-CONN) TO WS-PHASE
     EVALUATE TRUE
*>       ---- status (02) ----
         WHEN WS-PHASE = PH-STATUS AND L-ID = 0
             CALL "PB-GET-STRING" USING L-PACKET WS-JSON-MAX WS-JSON WS-JSON-CAP WS-JSON-LENGTH
             CALL "JSON-PARSE" USING JSON-DOC WS-JSON WS-JSON-LENGTH
             CALL "STATUS-READ" USING CLIENT-STATE JSON-DOC CN-ENTRY(L-CONN)
             CALL "CLP-PING-REQUEST" USING OUT-BUFFER CL-NOW-MS
             CALL "NET-SEND" USING CLIENT-STATE L-CONN OUT-BUFFER
         WHEN WS-PHASE = PH-STATUS AND L-ID = 1
             MOVE SLS-ANSWERED TO SL-STATUS(CN-ENTRY(L-CONN))
             CALL "NET-CLOSE" USING CLIENT-STATE L-CONN
*>       ---- login (02) ----
         WHEN WS-PHASE = PH-LOGIN AND L-ID = 0
             CALL "PB-GET-STRING" USING L-PACKET WS-JSON-MAX WS-JSON WS-JSON-CAP WS-JSON-LENGTH
             CALL "JSON-PARSE" USING JSON-DOC WS-JSON WS-JSON-LENGTH
             MOVE 1 TO WS-NODE
             CALL "JSON-TEXT-RENDER" USING CLIENT-STATE JSON-DOC WS-NODE WS-TEXT WS-LENGTH
             CALL "CLIENT-DISCONNECT" USING CLIENT-STATE L-CONN WS-TEXT WS-LENGTH
         WHEN WS-PHASE = PH-LOGIN AND L-ID = 2
             MOVE 3 TO WS-ID
             CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE L-CONN WS-ID
             MOVE PH-CONFIG TO CN-PHASE(L-CONN)
             CALL "CLP-CONFIG-START" USING CLIENT-STATE L-CONN
         WHEN WS-PHASE = PH-LOGIN AND L-ID = 3
             CALL "PB-GET-VARINT" USING L-PACKET CN-THRESHOLD(L-CONN)
*>       ---- configuration (03, 04) ----
         WHEN (WS-PHASE = PH-CONFIG AND L-ID = 2) OR (WS-PHASE = PH-PLAY AND L-ID = 32)
             CALL "PB-GET-TEXT" USING L-PACKET OUT-TEXT
             CALL "TEXT-RENDER" USING CLIENT-STATE OUT-TEXT WS-TEXT WS-LENGTH
             CALL "CLIENT-DISCONNECT" USING CLIENT-STATE L-CONN WS-TEXT WS-LENGTH
         WHEN WS-PHASE = PH-CONFIG AND L-ID = 3
             CALL "WT16-FINISH" USING CLIENT-STATE
             MOVE 3 TO WS-ID
             CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE L-CONN WS-ID
             MOVE PH-PLAY TO CN-PHASE(L-CONN)
         WHEN (WS-PHASE = PH-CONFIG AND L-ID = 4) OR (WS-PHASE = PH-PLAY AND L-ID = 45)
             CALL "PB-GET-LONG" USING L-PACKET WS-LONG
             MOVE 4 TO WS-PACKET
             IF WS-PHASE = PH-PLAY
                 MOVE 28 TO WS-PACKET
             END-IF
             CALL "CLP-KEEP-ALIVE" USING OUT-BUFFER WS-PACKET WS-LONG
             CALL "NET-SEND" USING CLIENT-STATE L-CONN OUT-BUFFER
         WHEN WS-PHASE = PH-CONFIG AND L-ID = 7
             CALL "WT16-ADD" USING CLIENT-STATE L-CONN L-PACKET L-ID
             CALL "REGISTRY-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-CONFIG AND L-ID = 14
             CALL "WT16-ADD" USING CLIENT-STATE L-CONN L-PACKET L-ID
*>       ---- server packs (03 Resource Pack Push and Pop, configuration and play; 08 §9) ----
         WHEN (WS-PHASE = PH-CONFIG AND L-ID = 9) OR (WS-PHASE = PH-PLAY AND L-ID = 82)
             CALL "PACK-PUSH" USING CLIENT-STATE L-PACKET
         WHEN (WS-PHASE = PH-CONFIG AND L-ID = 8) OR (WS-PHASE = PH-PLAY AND L-ID = 81)
             CALL "PACK-POP" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-CONFIG AND L-ID = 15
             MOVE 7 TO WS-ID
             MOVE 0 TO WS-VALUE
             CALL "PB-PUT-VARINT" USING OUT-BUFFER WS-ID
             CALL "PB-PUT-VARINT" USING OUT-BUFFER WS-VALUE
             CALL "NET-SEND" USING CLIENT-STATE L-CONN OUT-BUFFER
*>       ---- play (05a, 05b) ----
         WHEN WS-PHASE = PH-PLAY AND L-ID = 50
             CALL "PLAY-LOGIN-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 39
*>           Game Event: 3 is a game mode change; 2, 7 and 8 the weather (standin §14.4: 2 stops
*>           the rain, 7 and 8 carry the rain and thunder levels; 1 changes nothing by itself).
             CALL "PB-GET-UBYTE" USING L-PACKET WS-VALUE
             CALL "PB-GET-FLOAT" USING L-PACKET WS-FLOAT
             EVALUATE WS-VALUE
                 WHEN 3
                     MOVE WS-FLOAT TO PL-MODE
                     IF PL-MODE = 1
                         COMPUTE PL-ABILITIES = 13 + PL-FLYING * 2
                     ELSE
                         MOVE 0 TO PL-ABILITIES PL-FLYING
                     END-IF
                 WHEN 2
                     MOVE 0 TO PL-RAIN PL-THUNDER
                 WHEN 7
                     MOVE WS-FLOAT TO PL-RAIN
                 WHEN 8
                     MOVE WS-FLOAT TO PL-THUNDER
             END-EVALUATE
*>           The kind from the pair (standin §14.1): rain below 0.5 clear; else thunder below 0.5
*>           drizzle; else a hailstorm.
             EVALUATE TRUE
                 WHEN PL-RAIN < 0.5
                     MOVE WX-CLEAR TO PL-WEATHER
                 WHEN PL-THUNDER < 0.5
                     MOVE WX-DRIZZLE TO PL-WEATHER
                 WHEN OTHER
                     MOVE WX-HAILSTORM TO PL-WEATHER
             END-EVALUATE
         WHEN WS-PHASE = PH-PLAY AND L-ID = 73
*>           Player Position: CobolCraft's server sends absolute values only (relative flags 0,
*>           09 §3.2); the position is taken and accepted.
             CALL "PB-GET-VARINT" USING L-PACKET WS-ID
             CALL "PB-GET-DOUBLE" USING L-PACKET PL-X
             CALL "PB-GET-DOUBLE" USING L-PACKET PL-Y
             CALL "PB-GET-DOUBLE" USING L-PACKET PL-Z
             PERFORM 3 TIMES
                 CALL "PB-GET-DOUBLE" USING L-PACKET WS-DOUBLE
             END-PERFORM
             CALL "PB-GET-FLOAT" USING L-PACKET PL-YAW
             CALL "PB-GET-FLOAT" USING L-PACKET PL-PITCH
             MOVE 1 TO PL-POSITIONED
*>           A correction: the fall stops and the server already has this position.
             MOVE 0 TO PL-VY
             MOVE PL-X TO PL-SENT-X
             MOVE PL-Y TO PL-SENT-Y
             MOVE PL-Z TO PL-SENT-Z
             MOVE PL-YAW TO PL-SENT-YAW
             MOVE PL-PITCH TO PL-SENT-PITCH
             CALL "CLP-ACCEPT-TELEPORT" USING OUT-BUFFER WS-ID PL-X PL-Y PL-Z PL-YAW PL-PITCH
             CALL "NET-SEND" USING CLIENT-STATE L-CONN OUT-BUFFER
*>           The first position after a finished chunk batch: the spawn area has arrived, so
*>           Player Loaded now (05c 0x2C; CobolCraft's join sends the position after the initial
*>           batch, which may be the only one).
             IF PL-LOADED = 0 AND PL-BATCHES > 0
                 MOVE 1 TO PL-LOADED
                 MOVE 44 TO WS-ID
                 CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE L-CONN WS-ID
             END-IF
         WHEN WS-PHASE = PH-PLAY AND L-ID = 65
             CALL "PB-GET-BYTE" USING L-PACKET PL-ABILITIES
             CALL "PB-GET-FLOAT" USING L-PACKET PL-FLY-SPEED
             CALL "PB-GET-FLOAT" USING L-PACKET PL-WALK-SPEED
*>           Flags: 0x02 flying (the server's word on it), 0x04 may fly.
             COMPUTE WS-BIT = PL-ABILITIES / 2
             COMPUTE PL-FLYING = FUNCTION MOD(WS-BIT, 2)
         WHEN WS-PHASE = PH-PLAY AND L-ID = 99
             CALL "PB-GET-IDENTIFIER" USING L-PACKET WS-DIM WS-DIM-CAP WS-DIM-LENGTH
             CALL "PB-GET-POSITION" USING L-PACKET PL-SPAWN-X PL-SPAWN-Y PL-SPAWN-Z
         WHEN WS-PHASE = PH-PLAY AND L-ID = 115
*>           Set Time: the daylight clock's total ticks (else the game time) modulo the day.
             CALL "PB-GET-LONG" USING L-PACKET PL-TIME
             CALL "PB-GET-VARINT" USING L-PACKET WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 CALL "PB-GET-VARINT" USING L-PACKET WS-ID
                 CALL "PB-GET-VARLONG" USING L-PACKET WS-LONG
                 CALL "PB-GET-FLOAT" USING L-PACKET WS-FLOAT
                 CALL "PB-GET-FLOAT" USING L-PACKET WS-FLOAT
                 IF WS-ID = 0
                     MOVE WS-LONG TO PL-TIME
                 END-IF
             END-PERFORM
             COMPUTE PL-TIME = FUNCTION MOD(PL-TIME, 30000)
         WHEN WS-PHASE = PH-PLAY AND (L-ID = 18 OR L-ID = 20 OR L-ID = 107 OR L-ID = 110)
             CALL "INVENTORY-PACKET" USING CLIENT-STATE L-PACKET L-ID
         WHEN WS-PHASE = PH-PLAY AND L-ID = 8
             CALL "PB-GET-POSITION" USING L-PACKET WS-BX WS-BY WS-BZ
             CALL "PB-GET-VARINT" USING L-PACKET WS-VALUE
             CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-BX WS-BY WS-BZ WS-VALUE
         WHEN WS-PHASE = PH-PLAY AND L-ID = 86
             CALL "WORLD-SECTION-BLOCKS" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 49
             CALL "WORLD-LIGHT-UPDATE" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 4
             CALL "PB-GET-VARINT" USING L-PACKET CT-ACK
         WHEN WS-PHASE = PH-PLAY AND L-ID = 5
*>           Block Destruction: a breaker's progress (kept, and drawn as the crack overlay).
             CALL "PB-GET-VARINT" USING L-PACKET BD-ENTITY
             CALL "PB-GET-POSITION" USING L-PACKET BD-X BD-Y BD-Z
             CALL "PB-GET-UBYTE" USING L-PACKET BD-PROGRESS
             CALL "BREAK-OVERLAY-SET" USING CLIENT-STATE BD-ENTITY BD-X BD-Y BD-Z BD-PROGRESS
         WHEN WS-PHASE = PH-PLAY AND L-ID = 46
             CALL "REPLICA-CHUNK-LOAD" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 38
*>           Forget Level Chunk: one Long, Z in the high Int, X in the low Int.
             CALL "PB-GET-INT" USING L-PACKET WS-VALUE
             CALL "PB-GET-INT" USING L-PACKET WS-COUNT
             CALL "WORLD-FORGET" USING CLIENT-STATE WS-COUNT WS-VALUE
         WHEN WS-PHASE = PH-PLAY AND L-ID = 96
             CALL "PB-GET-VARINT" USING L-PACKET PL-CENTER-CX
             CALL "PB-GET-VARINT" USING L-PACKET PL-CENTER-CZ
         WHEN WS-PHASE = PH-PLAY AND (L-ID = 1 OR L-ID = 54 OR L-ID = 55 OR L-ID = 57
                 OR L-ID = 70 OR L-ID = 71 OR L-ID = 78 OR L-ID = 85 OR L-ID = 101
                 OR L-ID = 103 OR L-ID = 127 OR L-ID = 128)
             CALL "ENTITY-PACKET" USING CLIENT-STATE L-PACKET L-ID
         WHEN WS-PHASE = PH-PLAY AND L-ID = 124
*>           System Chat (09 §1: the overlay flag is always false): into the chat history.
             CALL "PB-GET-TEXT" USING L-PACKET OUT-TEXT
             CALL "TEXT-RENDER" USING CLIENT-STATE OUT-TEXT WS-TEXT WS-LENGTH
             CALL "CHAT-MESSAGE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH
         WHEN WS-PHASE = PH-PLAY AND L-ID = 106
             CALL "PB-GET-FLOAT" USING L-PACKET PL-HEALTH
             CALL "PB-GET-VARINT" USING L-PACKET PL-FOOD
         WHEN WS-PHASE = PH-PLAY AND (L-ID = 25 OR L-ID = 43)
*>           Damage Event or Hurt Animation: both start with the damaged entity's id.
             CALL "PB-GET-VARINT" USING L-PACKET WS-ID
             IF WS-ID = PL-ENTITY-ID
                 COMPUTE PL-HURT-UNTIL = CL-NOW-MS + CL-HURT-MS
             END-IF
         WHEN WS-PHASE = PH-PLAY AND L-ID = 34
*>           Entity Event (an Int entity id, a Byte event): 9 for the local player is eating
*>           finished (standin §11.6).
             CALL "PB-GET-INT" USING L-PACKET WS-ID
             CALL "PB-GET-BYTE" USING L-PACKET WS-VALUE
             IF WS-ID = PL-ENTITY-ID AND WS-VALUE = 9
                 MOVE 0 TO PL-EATING
             END-IF
         WHEN WS-PHASE = PH-PLAY AND L-ID = 69
*>           Player Combat Kill: the death screen shows the message (standin §10.6).
             CALL "PB-GET-VARINT" USING L-PACKET WS-ID
             CALL "PB-GET-TEXT" USING L-PACKET OUT-TEXT
             IF WS-ID = PL-ENTITY-ID
                 CALL "TEXT-RENDER" USING CLIENT-STATE OUT-TEXT SM-DEATH-CAUSE
                     SM-DEATH-CAUSE-LENGTH
                 MOVE SCR-DEATH TO WS-ID
                 CALL "SCREEN-OPEN" USING CLIENT-STATE WS-ID
             END-IF
         WHEN WS-PHASE = PH-PLAY AND L-ID = 84
             CALL "PLAY-RESPAWN-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 75
             CALL "RECIPE-BOOK-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 16
             CALL "COMMANDS-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 15
             CALL "SUGGESTIONS-READ" USING CLIENT-STATE L-PACKET
         WHEN WS-PHASE = PH-PLAY AND L-ID = 11
             ADD 1 TO PL-BATCHES
             CALL "CLP-BATCH-RECEIVED" USING OUT-BUFFER WS-RATE
             CALL "NET-SEND" USING CLIENT-STATE L-CONN OUT-BUFFER
             IF PL-LOADED = 0 AND PL-POSITIONED = 1
                 MOVE 1 TO PL-LOADED
                 MOVE 44 TO WS-ID
                 CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE L-CONN WS-ID
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PROTO-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLIENT-DISCONNECT.
*> USING CLIENT-STATE, connection, message (PIC X(512)), length: the connection ends. The game
*> connection returns the Player to the server list showing the message (the world is emptied);
*> a status connection marks its entry unreachable.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-TEXT L-LENGTH.
     CALL "NET-CLOSE" USING CLIENT-STATE L-CONN
     IF L-CONN = CONN-GAME
         MOVE L-TEXT TO SM-MESSAGE
         MOVE L-LENGTH TO SM-MESSAGE-LENGTH
         CALL "WORLD-CLEAR" USING CLIENT-STATE
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE SCR-SERVER-LIST TO WS-SCREEN
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     ELSE
         MOVE SLS-UNREACHABLE TO SL-STATUS(CN-ENTRY(L-CONN))
     END-IF
     GOBACK.
 END PROGRAM CLIENT-DISCONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEXT-RENDER.
*> USING CLIENT-STATE, PB-TEXT, text out (PIC X(512)), length out: plain and literal texts as they
*> are; a translate component through the language with its arguments (wire-profile §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLARGS.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-TEXT L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     MOVE PB-TX-VALUE(1:512) TO L-TEXT
     MOVE FUNCTION MIN(PB-TX-LENGTH, 512) TO L-LENGTH
     IF PB-TX-KIND = PB-TEXT-TRANSLATE
         MOVE PB-TX-ARG-COUNT TO LA-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-ARG-COUNT
             MOVE PB-TX-ARG-VALUE(WS-I) TO LA-TEXT(WS-I)
             MOVE FUNCTION MIN(PB-TX-ARG-LENGTH(WS-I), 256) TO LA-LENGTH(WS-I)
         END-PERFORM
         MOVE FUNCTION MIN(PB-TX-LENGTH, 80) TO WS-KEY-LENGTH
         MOVE SPACES TO WS-KEY
         MOVE PB-TX-VALUE(1:WS-KEY-LENGTH) TO WS-KEY
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS L-TEXT L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM TEXT-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. JSON-TEXT-RENDER.
*> USING CLIENT-STATE, JSON-DOC, node (a JSON text component, 00 §9.2), text out (PIC X(512)),
*> length out: a string as it is; an object's "translate" through the language with the strings of
*> "with" as arguments, else its "text".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLARGS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-FIELD               BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 512.
 01 WS-ARG-CAP             BINARY-LONG VALUE 256.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-CAP             BINARY-LONG VALUE 80.
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE JSON-DOC L-NODE L-TEXT L-LENGTH.
     MOVE SPACES TO L-TEXT
     CALL "JSON-STRING" USING JSON-DOC L-NODE L-TEXT WS-CAP L-LENGTH
     MOVE "text" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
     IF WS-FIELD > 0
         CALL "JSON-STRING" USING JSON-DOC WS-FIELD L-TEXT WS-CAP L-LENGTH
     END-IF
     MOVE "translate" TO WS-NAME
     MOVE 9 TO WS-NAME-LENGTH
     CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
     IF WS-FIELD > 0
         MOVE SPACES TO WS-KEY
         CALL "JSON-STRING" USING JSON-DOC WS-FIELD WS-KEY WS-KEY-CAP WS-KEY-LENGTH
         MOVE "with" TO WS-NAME
         MOVE 4 TO WS-NAME-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC L-NODE WS-NAME WS-NAME-LENGTH WS-FIELD
         MOVE 0 TO LA-COUNT WS-ARG
         IF WS-FIELD > 0
             MOVE JN-FIRST(WS-FIELD) TO WS-ARG
         END-IF
         PERFORM UNTIL WS-ARG = 0 OR LA-COUNT = 8
             ADD 1 TO LA-COUNT
             MOVE SPACES TO LA-TEXT(LA-COUNT)
             CALL "JSON-STRING" USING JSON-DOC WS-ARG LA-TEXT(LA-COUNT) WS-ARG-CAP
                 LA-LENGTH(LA-COUNT)
             MOVE JN-NEXT(WS-ARG) TO WS-ARG
         END-PERFORM
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS L-TEXT L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM JSON-TEXT-RENDER.
