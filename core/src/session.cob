*> Connections of the core (contracts/core-host-api.md §2, §3; data-model §12; docs/protocol/01).
*> The connection table lives in CORE-CONNS (core/copy/CORESTATE.cpy); the connection id is the
*> row number. Inbound bytes accumulate per connection and are cut into packets with
*> PB-FRAME-DECODE; each packet is dispatched by the connection's phase. Outbound packets are
*> framed with PB-FRAME-ENCODE (compressed on network connections after Set Compression) into the
*> connection's outbound queue, which the host drains with CORE-CONN-OUTPUT.
*>
*> Internal entry points used by the phase modules:
*>   CORE-SEND USING id, packet PB-BUFFER (id + body)       queue one packet
*>   CORE-SET-PHASE USING id, phase                         switch phase (keep-alive starts in PH-CONFIG)
*>   CORE-DISCONNECT USING id                               raise the close flag
*>   CORE-SEND-DISCONNECT USING id, PB-TEXT                 phase's disconnect packet, then close
*>   CORE-BAD-PACKET USING id                               a packet that cannot be decoded (01 §5)
*>   CORE-KEEPALIVE-ANSWER USING id, Long                   a serverbound Keep Alive
*>   KEEPALIVE-PACKET-BUILD USING phase, Long, PB-BUFFER     clientbound Keep Alive packet
*>   CORE-LOG USING text area, length                       one console line

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-RESET.
*> Releases every connection's buffers and empties the connection table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1
             MOVE CN-IN(WS-ID) TO PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             MOVE CN-OUT(WS-ID) TO PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-PERFORM
     INITIALIZE CORE-CONNS
     GOBACK.
 END PROGRAM SESSION-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-OPEN.
*> USING kind (BINARY-LONG), id out (BINARY-LONG): the lowest free row in the handshake phase, or
*> 0 when every row is in use.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-ID                  BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS OR L-ID > 0
         IF CN-USED(WS-ID) = 0
             MOVE WS-ID TO L-ID
         END-IF
     END-PERFORM
     IF L-ID > 0
         INITIALIZE CN-ENTRY(L-ID)
         MOVE 1 TO CN-USED(L-ID)
         MOVE L-KIND TO CN-KIND(L-ID)
         MOVE PH-HANDSHAKE TO CN-PHASE(L-ID)
         MOVE CW-TICKS TO CN-PHASE-TICK(L-ID)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE PB-BUFFER TO CN-IN(L-ID)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE PB-BUFFER TO CN-OUT(L-ID)
     END-IF
     GOBACK.
 END PROGRAM SESSION-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-VALID.
*> USING id, valid out (BINARY-LONG 1 = a connection in use).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-VALID.
     MOVE 0 TO L-VALID
     IF L-ID >= 1 AND L-ID <= CORE-MAX-CONNS
         IF CN-USED(L-ID) = 1
             MOVE 1 TO L-VALID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SESSION-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-INPUT.
*> USING id, CORE-BUFFER: appends the received bytes to the connection's accumulator, then
*> dispatches every complete packet. A malformed frame closes the connection (01 §2, §3.3); once
*> the close flag is up, received bytes are dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CCSHIM.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-VALID               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG.
 01 WS-VALIDATE            BINARY-LONG VALUE 1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 B-BYTES                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER.
     CALL "SESSION-VALID" USING L-ID WS-VALID
     IF WS-VALID = 1 AND CN-CLOSE(L-ID) = 0 AND CB-LENGTH > 0
         MOVE CN-IN(L-ID) TO PB-BUFFER
         SET ADDRESS OF B-BYTES TO CB-ADDR
         CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BYTES CB-LENGTH
         MOVE PB-BUFFER TO CN-IN(L-ID)
         CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
         MOVE 0 TO WS-OUTCOME
         PERFORM UNTIL WS-OUTCOME NOT = 0 OR CN-CLOSE(L-ID) = 1
             MOVE -1 TO WS-THRESHOLD
             IF CN-COMPRESS(L-ID) = 1
                 MOVE CORE-COMPRESSION TO WS-THRESHOLD
             END-IF
             MOVE CN-IN(L-ID) TO PB-BUFFER
             CALL "PB-FRAME-DECODE" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-VALIDATE
                 WS-PACKET-ID WS-OUTCOME
             MOVE PB-BUFFER TO CN-IN(L-ID)
             EVALUATE WS-OUTCOME
                 WHEN 0
                     CALL "SESSION-DISPATCH" USING L-ID WS-PACKET-ID PK-BUFFER
                 WHEN 2
                     CALL "CORE-BAD-PACKET" USING L-ID
             END-EVALUATE
         END-PERFORM
         CALL "PB-FREE" USING PK-BUFFER
     END-IF
     GOBACK.
 END PROGRAM SESSION-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-DISPATCH.
*> USING id, packet id, packet PB-BUFFER (PB-POS after the id). Handshake: Intention (02) moves the
*> connection to status (intent 1) or login (intents 2 and 3, handed to LOGIN-INTENTION); any other
*> packet or intent, or an Intention with bytes left over, is a decoding error (01 §5). Other
*> phases go to their module.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PROTOCOL            BINARY-LONG.
 01 WS-MAX-HOST            BINARY-LONG VALUE 255.
 01 WS-HOST                PIC X(1020).
 01 WS-HOST-CAPACITY       BINARY-LONG VALUE 1020.
 01 WS-HOST-LENGTH         BINARY-LONG.
 01 WS-PORT                BINARY-LONG.
 01 WS-INTENT              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
     EVALUATE CN-PHASE(L-ID)
         WHEN PH-HANDSHAKE
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-PROTOCOL
             CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-HOST WS-HOST WS-HOST-CAPACITY
                 WS-HOST-LENGTH
             CALL "PB-GET-USHORT" USING PB-BUFFER WS-PORT
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-INTENT
             EVALUATE TRUE
                 WHEN L-PACKET-ID NOT = 0 OR PB-ERROR = 1 OR PB-POS NOT = PB-LENGTH
                         OR WS-INTENT < 1 OR WS-INTENT > 3
                     CALL "CORE-BAD-PACKET" USING L-ID
                 WHEN WS-INTENT = 1
                     MOVE WS-PROTOCOL TO CN-PROTOCOL(L-ID)
                     MOVE WS-INTENT TO CN-INTENT(L-ID)
                     MOVE PH-STATUS TO CN-PHASE(L-ID)
                 WHEN OTHER
                     MOVE WS-PROTOCOL TO CN-PROTOCOL(L-ID)
                     MOVE WS-INTENT TO CN-INTENT(L-ID)
                     MOVE PH-LOGIN TO CN-PHASE(L-ID)
                     MOVE CW-TICKS TO CN-PHASE-TICK(L-ID)
                     CALL "LOGIN-INTENTION" USING L-ID
             END-EVALUATE
         WHEN PH-STATUS
             CALL "STATUS-PACKET" USING L-ID L-PACKET-ID PB-BUFFER
         WHEN PH-LOGIN
             CALL "LOGIN-PACKET" USING L-ID L-PACKET-ID PB-BUFFER
         WHEN PH-CONFIG
             CALL "CONFIG-PACKET" USING L-ID L-PACKET-ID PB-BUFFER
         WHEN OTHER
             CALL "PLAY-PACKET" USING L-ID L-PACKET-ID PB-BUFFER
     END-EVALUATE
     GOBACK.
 END PROGRAM SESSION-DISPATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SEND.
*> USING id, packet PB-BUFFER (id + body, bytes 1 to PB-LENGTH): appends its frame to the outbound
*> queue, compressed at CORE-COMPRESSION once CN-COMPRESS is set (01 §3; 09 §2). Nothing is queued
*> after the close flag is up.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==FR-==.
 01 WS-THRESHOLD           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PB-BUFFER.
     IF CN-CLOSE(L-ID) = 0
         MOVE -1 TO WS-THRESHOLD
         IF CN-COMPRESS(L-ID) = 1
             MOVE CORE-COMPRESSION TO WS-THRESHOLD
         END-IF
         MOVE CN-OUT(L-ID) TO FR-BUFFER
         CALL "PB-FRAME-ENCODE" USING FR-BUFFER PB-BUFFER WS-THRESHOLD
         MOVE FR-BUFFER TO CN-OUT(L-ID)
     END-IF
     GOBACK.
 END PROGRAM CORE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SET-PHASE.
*> USING id, phase: the connection's new phase. Entering configuration from login starts the
*> keep-alive clock (09 §2: the first Keep Alive after CORE-KEEPALIVE-TICKS ticks).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PHASE.
     IF L-PHASE = PH-CONFIG AND CN-PHASE(L-ID) = PH-LOGIN
         MOVE 0 TO CN-KA-PENDING(L-ID)
         COMPUTE CN-KA-DEADLINE(L-ID) = CW-TICKS + CORE-KEEPALIVE-TICKS
     END-IF
     MOVE L-PHASE TO CN-PHASE(L-ID)
     MOVE CW-TICKS TO CN-PHASE-TICK(L-ID)
     GOBACK.
 END PROGRAM CORE-SET-PHASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-DISCONNECT.
*> USING id: raises the close flag. The host closes the transport once the queued bytes are sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE 1 TO CN-CLOSE(L-ID)
     GOBACK.
 END PROGRAM CORE-DISCONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-BAD-PACKET.
*> USING id: a packet the core cannot decode, an unknown packet id or a malformed frame. 01 §5 and
*> 09 §4: the connection is closed.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "CORE-DISCONNECT" USING L-ID
     GOBACK.
 END PROGRAM CORE-BAD-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SEND-DISCONNECT.
*> USING id, PB-TEXT: the disconnect packet of the connection's phase with that reason, then the
*> close flag. Login: Login Disconnect (JSON, LOGIN-SEND-DISCONNECT); configuration: Disconnect
*> 0x02; play: Disconnect 0x20 (network NBT text, 09 §1). Handshake and status: no packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PACKET-ID           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PB-TEXT.
     EVALUATE CN-PHASE(L-ID)
         WHEN PH-LOGIN
             CALL "LOGIN-SEND-DISCONNECT" USING L-ID PB-TEXT
         WHEN PH-CONFIG
         WHEN PH-PLAY
             MOVE 2 TO WS-PACKET-ID
             IF CN-PHASE(L-ID) = PH-PLAY
                 MOVE 32 TO WS-PACKET-ID
             END-IF
             CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
             CALL "PB-PUT-VARINT" USING PK-BUFFER WS-PACKET-ID
             CALL "PB-PUT-TEXT" USING PK-BUFFER PB-TEXT
             CALL "CORE-SEND" USING L-ID PK-BUFFER
             CALL "PB-FREE" USING PK-BUFFER
     END-EVALUATE
     CALL "CORE-DISCONNECT" USING L-ID
     GOBACK.
 END PROGRAM CORE-SEND-DISCONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. KEEPALIVE-PACKET-BUILD.
*> USING phase, id (BINARY-DOUBLE), packet PB-BUFFER (appended to): clientbound Keep Alive,
*> configuration 0x04 or play 0x2D, body one Long (09 §2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PACKET-ID           BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PHASE                BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-PHASE L-VALUE PB-BUFFER.
     MOVE 4 TO WS-PACKET-ID
     IF L-PHASE = PH-PLAY
         MOVE 45 TO WS-PACKET-ID
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER L-VALUE
     GOBACK.
 END PROGRAM KEEPALIVE-PACKET-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-TIMEOUT.
*> USING id: disconnects with disconnect.timeout (09 §1, 01 §7.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "disconnect.timeout" TO PB-TX-VALUE
     MOVE 18 TO PB-TX-LENGTH
     CALL "CORE-SEND-DISCONNECT" USING L-ID PB-TEXT
     GOBACK.
 END PROGRAM CORE-TIMEOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SLOW-LOGIN.
*> USING id: disconnects with multiplayer.disconnect.slow_login (Login Disconnect, 02, 09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "multiplayer.disconnect.slow_login" TO PB-TX-VALUE
     MOVE 33 TO PB-TX-LENGTH
     CALL "CORE-SEND-DISCONNECT" USING L-ID PB-TEXT
     GOBACK.
 END PROGRAM CORE-SLOW-LOGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-TICK.
*> One tick of every connection in configuration or play: at each keep-alive deadline, an
*> unanswered Keep Alive disconnects (disconnect.timeout); otherwise a new Keep Alive is sent, with
*> the tick count as its id, and the next deadline is CORE-KEEPALIVE-TICKS later (01 §7.5, 09 §2).
*> A connection still in login CORE-LOGIN-TICKS after its login Intention is disconnected with
*> multiplayer.disconnect.slow_login (02 "Login timeouts and errors", 09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-ID                  BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-CLOSE(WS-ID) = 0 AND CN-PHASE(WS-ID) = PH-LOGIN
                 AND CW-TICKS - CN-PHASE-TICK(WS-ID) >= CORE-LOGIN-TICKS
             CALL "CORE-SLOW-LOGIN" USING WS-ID
         END-IF
         IF CN-USED(WS-ID) = 1 AND CN-CLOSE(WS-ID) = 0 AND CN-PHASE(WS-ID) >= PH-CONFIG
                 AND CW-TICKS >= CN-KA-DEADLINE(WS-ID)
             IF CN-KA-PENDING(WS-ID) = 1
                 CALL "CORE-TIMEOUT" USING WS-ID
             ELSE
                 MOVE CW-TICKS TO CN-KA-ID(WS-ID)
                 MOVE 1 TO CN-KA-PENDING(WS-ID)
                 COMPUTE CN-KA-DEADLINE(WS-ID) = CW-TICKS + CORE-KEEPALIVE-TICKS
                 MOVE CN-PHASE(WS-ID) TO WS-PHASE
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "KEEPALIVE-PACKET-BUILD" USING WS-PHASE CN-KA-ID(WS-ID) PB-BUFFER
                 CALL "CORE-SEND" USING WS-ID PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SESSION-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-KEEPALIVE-ANSWER.
*> USING id, Long: a serverbound Keep Alive. The pending id clears the pending flag; a wrong id or
*> an answer with nothing pending disconnects (disconnect.timeout, 01 §7.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ID L-VALUE.
     IF CN-KA-PENDING(L-ID) = 1 AND L-VALUE = CN-KA-ID(L-ID)
         MOVE 0 TO CN-KA-PENDING(L-ID)
     ELSE
         CALL "CORE-TIMEOUT" USING L-ID
     END-IF
     GOBACK.
 END PROGRAM CORE-KEEPALIVE-ANSWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-RELEASE.
*> USING id: the connection is finished. Its player, if any, leaves; its buffers are freed and the
*> row becomes free for reuse.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     IF CN-PLAYER(L-ID) > 0
         CALL "PLAYER-LEAVE" USING CN-PLAYER(L-ID)
     END-IF
     MOVE CN-IN(L-ID) TO PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE CN-OUT(L-ID) TO PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     INITIALIZE CN-ENTRY(L-ID)
     GOBACK.
 END PROGRAM SESSION-RELEASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-OUTPUT.
*> USING id, CORE-BUFFER, close-flag out (BINARY-LONG): moves up to CB-CAPACITY queued bytes into
*> the caller's buffer (CB-LENGTH = bytes moved; PB-POS of the queue counts the bytes already
*> handed out, so a large queue is drained in linear time). close-flag = 1 when the close flag is up and the
*> queue is now empty: the connection is released and its id may be reused (core-host-api §3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-VALID               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 B-QUEUE                PIC X(1073741824) BASED.
 01 B-HOST                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER L-CLOSE.
     MOVE 0 TO CB-LENGTH L-CLOSE
     CALL "SESSION-VALID" USING L-ID WS-VALID
     IF WS-VALID = 1
         MOVE CN-OUT(L-ID) TO PB-BUFFER
         COMPUTE WS-COUNT = FUNCTION MIN(PB-LENGTH - PB-POS, CB-CAPACITY)
         IF WS-COUNT > 0
             SET ADDRESS OF B-QUEUE TO PB-ADDR
             SET ADDRESS OF B-HOST TO CB-ADDR
             MOVE B-QUEUE(PB-POS + 1:WS-COUNT) TO B-HOST(1:WS-COUNT)
             ADD WS-COUNT TO PB-POS
             MOVE WS-COUNT TO CB-LENGTH
         END-IF
         IF PB-POS = PB-LENGTH
             MOVE 0 TO PB-POS PB-LENGTH
         END-IF
         MOVE PB-BUFFER TO CN-OUT(L-ID)
         IF CN-CLOSE(L-ID) = 1 AND PB-LENGTH = 0
             MOVE 1 TO L-CLOSE
             CALL "SESSION-RELEASE" USING L-ID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SESSION-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SESSION-CLOSED.
*> USING id: the host's transport closed; the connection is released.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "SESSION-VALID" USING L-ID WS-VALID
     IF WS-VALID = 1
         CALL "SESSION-RELEASE" USING L-ID
     END-IF
     GOBACK.
 END PROGRAM SESSION-CLOSED.
