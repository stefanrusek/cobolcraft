*> Server-pushed packs (US18-6 to US18-8; 08 §9.1 to §9.8; 03 Resource Pack Push, Pop, Response):
*> PACK-PUSH handles a Resource Pack Push of the game connection: a URL that is not http or https
*> gets 5 invalid URL at once; the hash is used when it is 40 hex digits; a pack with the same id
*> replaces the earlier one; then the decision: once the Player answered for this connection, or
*> when the joined server's PackPolicy is always (1) or never (2), the pack is accepted (3
*> accepted) or declined (1 declined) at once; otherwise the prompt screen asks (pack-prompt.cob,
*> PACK-PROMPT-ANSWER keeps the answer in servers.dat). A required pack declined is only answered
*> 1 declined: the client stays connected and the server's Disconnect follows (08 §9.8).
*> PACKS-PUMP (every frame) fetches accepted packs: from the cache (cache.cob) when an unchanged one
*> is there, else over HTTP or HTTPS (http.cob) with the 08 §9.3 headers and size limit; the SHA-1
*> is checked against an expected hash; 4 downloaded follows. A failed fetch gets 2 failed
*> download and every other pack of the batch not yet applied 7 discarded. Once no pack is being
*> fetched, the downloaded ones are applied: the stack is rebuilt with them on top, the last pushed
*> highest (PACKS-RELOAD, 08 §9.6); each gets 0 successfully loaded, or 6 failed reload when it
*> cannot be used, and is left out. PACK-POP removes one pack or all (no response); disconnecting
*> removes all (SERVER-PACKS-CLEAR, from NET-CLOSE).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-PACK-RESPONSE.
*> USING PB-BUFFER, packet id (configuration 6, play 50), pack id (PIC X(16)), action (BINARY-LONG,
*> 03 Resource Pack Response ordinals): Resource Pack Response.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PACKET               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-PACKET L-UUID L-ACTION.
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-PACKET
     CALL "PB-PUT-UUID" USING PB-BUFFER L-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ACTION
     GOBACK.
 END PROGRAM CLP-PACK-RESPONSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-RESPOND.
*> USING CLIENT-STATE, pack id (PIC X(16)), action: queues the Resource Pack Response on the game
*> connection (configuration or play, by its phase).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-UUID                PIC X(16).
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-UUID                 PIC X(16).
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-UUID L-ACTION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-UUID TO WS-UUID
     MOVE L-ACTION TO WS-ACTION
     MOVE 6 TO WS-PACKET
     IF CN-PHASE(CONN-GAME) = PH-PLAY
         MOVE 50 TO WS-PACKET
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CLP-PACK-RESPONSE" USING PB-BUFFER WS-PACKET WS-UUID WS-ACTION
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM PACK-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-PUSH.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id): a Resource Pack Push (08 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-UUID                PIC X(16).
 01 WS-URL                 PIC X(32767).
 01 WS-URL-MAX             BINARY-LONG VALUE 32767.
 01 WS-URL-CAP             BINARY-LONG VALUE 32767.
 01 WS-URL-LENGTH          BINARY-LONG.
 01 WS-SHORT-URL           PIC X(1024).
 01 WS-HASH                PIC X(40).
 01 WS-HASH-MAX            BINARY-LONG VALUE 40.
 01 WS-HASH-CAP            BINARY-LONG VALUE 40.
 01 WS-HASH-LENGTH         BINARY-LONG.
 01 WS-REQUIRED            BINARY-LONG.
 01 WS-HAS-PROMPT          BINARY-LONG.
 01 WS-PROMPT              PIC X(512).
 01 WS-PROMPT-LENGTH       BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-HEX                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-POLICY              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACKET.
    05 L-ADDR              USAGE POINTER.
    05 L-CAPACITY          BINARY-LONG.
    05 L-LENGTH            BINARY-LONG.
    05 L-POS               BINARY-LONG.
    05 L-ERROR             PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACKET.
     CALL "PB-GET-UUID" USING L-PACKET WS-UUID
     MOVE SPACES TO WS-URL WS-HASH WS-PROMPT
     CALL "PB-GET-STRING" USING L-PACKET WS-URL-MAX WS-URL WS-URL-CAP WS-URL-LENGTH
     CALL "PB-GET-STRING" USING L-PACKET WS-HASH-MAX WS-HASH WS-HASH-CAP WS-HASH-LENGTH
     CALL "PB-GET-BOOL" USING L-PACKET WS-REQUIRED
     CALL "PB-GET-BOOL" USING L-PACKET WS-HAS-PROMPT
     MOVE 0 TO WS-PROMPT-LENGTH
     IF WS-HAS-PROMPT = 1
         CALL "PB-GET-TEXT" USING L-PACKET PB-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE PB-TEXT WS-PROMPT WS-PROMPT-LENGTH
     END-IF
*>   1. The URL: http or https, else 5 invalid URL.
     MOVE 0 TO WS-VALID
     IF WS-URL-LENGTH <= 1024
         MOVE WS-URL(1:1024) TO WS-SHORT-URL
         CALL "HTTP-URL-VALID" USING WS-SHORT-URL WS-URL-LENGTH WS-VALID
     END-IF
     IF WS-VALID = 0
         MOVE 5 TO WS-ACTION
         CALL "PACK-RESPOND" USING CLIENT-STATE WS-UUID WS-ACTION
         GOBACK
     END-IF
*>   2. The hash: 40 hex digits, lowercased; anything else means no expected hash.
     MOVE 0 TO WS-HEX
     INSPECT WS-HASH TALLYING WS-HEX FOR ALL "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b"
         "c" "d" "e" "f" "A" "B" "C" "D" "E" "F"
     IF WS-HEX = 40
         MOVE FUNCTION LOWER-CASE(WS-HASH) TO WS-HASH
     ELSE
         MOVE SPACES TO WS-HASH
     END-IF
*>   3. The row: the same id replaces its pack, else a new one (while there is room).
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         IF RP-UUID(WS-I) = WS-UUID
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW > 0
         CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-ROW
     END-IF
     IF RP-COUNT >= CL-MAX-SERVER-PACKS
         GOBACK
     END-IF
     ADD 1 TO RP-COUNT RP-PUSHES
     MOVE RP-COUNT TO WS-ROW
     INITIALIZE RP-PACK(WS-ROW)
     MOVE WS-UUID TO RP-UUID(WS-ROW)
     MOVE WS-SHORT-URL TO RP-URL(WS-ROW)
     MOVE WS-URL-LENGTH TO RP-URL-LENGTH(WS-ROW)
     MOVE WS-HASH TO RP-HASH(WS-ROW)
     MOVE WS-REQUIRED TO RP-REQUIRED(WS-ROW)
     MOVE WS-PROMPT(1:256) TO RP-PROMPT(WS-ROW)
     MOVE FUNCTION MIN(WS-PROMPT-LENGTH, 256) TO RP-PROMPT-LENGTH(WS-ROW)
     MOVE RP-PUSHES TO RP-NUMBER(WS-ROW)
*>   4. The decision (08 §9.1 step 3; §9.8: never accept declines a required pack too).
     MOVE 0 TO WS-POLICY
     IF RP-ENTRY-JOINED > 0
         MOVE SL-POLICY(RP-ENTRY-JOINED) TO WS-POLICY
     END-IF
     IF RP-DECISION = 0 AND WS-POLICY > 0
         MOVE WS-POLICY TO RP-DECISION
     END-IF
     EVALUATE RP-DECISION
         WHEN 1
             MOVE RPS-DOWNLOAD TO RP-STEP(WS-ROW)
             MOVE 3 TO WS-ACTION
             CALL "PACK-RESPOND" USING CLIENT-STATE WS-UUID WS-ACTION
         WHEN 2
             MOVE 1 TO WS-ACTION
             CALL "PACK-RESPOND" USING CLIENT-STATE WS-UUID WS-ACTION
             CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-ROW
         WHEN OTHER
             MOVE RPS-PROMPT TO RP-STEP(WS-ROW)
             IF SM-SCREEN NOT = SCR-PACK-PROMPT
                 MOVE SM-SCREEN TO RP-RETURN-SCREEN
                 MOVE SCR-PACK-PROMPT TO WS-SCREEN
                 CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-PUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-POP.
*> USING CLIENT-STATE, packet PB-BUFFER (PB-POS after the id): a Resource Pack Pop removes the pack
*> with that id, or every server pack without one (no response, 08 §9.2, §9.5); the packs are
*> reloaded when an applied one went.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PACKET.
    05 L-ADDR              USAGE POINTER.
    05 L-CAPACITY          BINARY-LONG.
    05 L-LENGTH            BINARY-LONG.
    05 L-POS               BINARY-LONG.
    05 L-ERROR             PIC 9.
 PROCEDURE DIVISION USING CLIENT-STATE L-PACKET.
     CALL "PB-GET-BOOL" USING L-PACKET WS-PRESENT
     IF WS-PRESENT = 0
         CALL "SERVER-PACKS-CLEAR" USING CLIENT-STATE
         GOBACK
     END-IF
     CALL "PB-GET-UUID" USING L-PACKET WS-UUID
     MOVE 0 TO WS-ACTIVE
     PERFORM VARYING WS-I FROM RP-COUNT BY -1 UNTIL WS-I < 1
         IF RP-UUID(WS-I) = WS-UUID
             IF RP-STEP(WS-I) = RPS-ACTIVE
                 MOVE 1 TO WS-ACTIVE
             END-IF
             CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-I
         END-IF
     END-PERFORM
     IF WS-ACTIVE = 1
         CALL "PACKS-RELOAD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM PACK-POP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-ROW-REMOVE.
*> USING CLIENT-STATE, server pack row: its download stopped (HTTP-RELEASE, freed) and the row
*> removed (the rows after it move up).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 COPY CLHTTP.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     IF RP-HTTP(L-ROW) NOT = NULL
         SET ADDRESS OF HTTP-REQUEST TO RP-HTTP(L-ROW)
         CALL "HTTP-RELEASE" USING HTTP-REQUEST
         FREE RP-HTTP(L-ROW)
     END-IF
     PERFORM VARYING WS-I FROM L-ROW BY 1 UNTIL WS-I >= RP-COUNT
         MOVE RP-PACK(WS-I + 1) TO RP-PACK(WS-I)
     END-PERFORM
     SUBTRACT 1 FROM RP-COUNT
     GOBACK.
 END PROGRAM PACK-ROW-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-PROMPT-ANSWER.
*> USING CLIENT-STATE, accepted (BINARY-LONG 1 accept, 0 decline): the answer holds for this
*> connection and is kept as the joined server's PackPolicy (servers.dat); each pack waiting for it
*> gets 3 accepted (and is fetched) or 1 declined; the screen shown before the prompt returns.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACCEPT               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACCEPT.
     COMPUTE RP-DECISION = 2 - L-ACCEPT
     IF RP-ENTRY-JOINED > 0
         MOVE RP-DECISION TO SL-POLICY(RP-ENTRY-JOINED)
         CALL "SERVERS-SAVE" USING CLIENT-STATE
     END-IF
     PERFORM VARYING WS-I FROM RP-COUNT BY -1 UNTIL WS-I < 1
         IF RP-STEP(WS-I) = RPS-PROMPT
             IF L-ACCEPT = 1
                 MOVE RPS-DOWNLOAD TO RP-STEP(WS-I)
                 MOVE 3 TO WS-ACTION
                 CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(WS-I) WS-ACTION
             ELSE
                 MOVE 1 TO WS-ACTION
                 CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(WS-I) WS-ACTION
                 CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-I
             END-IF
         END-IF
     END-PERFORM
     CALL "SCREEN-OPEN" USING CLIENT-STATE RP-RETURN-SCREEN
     GOBACK.
 END PROGRAM PACK-PROMPT-ANSWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-PUMP.
*> USING CLIENT-STATE: one non-blocking step of the server packs: fetching, then applying.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FETCHING            BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-FAILED              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-FAILED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT OR WS-FAILED > 0
         IF RP-STEP(WS-I) = RPS-DOWNLOAD
             CALL "PACK-FETCH" USING CLIENT-STATE WS-I WS-FAILED
         END-IF
     END-PERFORM
     IF WS-FAILED > 0
         CALL "PACK-BATCH-FAILED" USING CLIENT-STATE WS-FAILED
     END-IF
     MOVE 0 TO WS-FETCHING WS-READY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         EVALUATE RP-STEP(WS-I)
             WHEN RPS-DOWNLOAD
                 ADD 1 TO WS-FETCHING
             WHEN RPS-READY
                 ADD 1 TO WS-READY
         END-EVALUATE
     END-PERFORM
     IF WS-FETCHING = 0 AND WS-READY > 0
         CALL "PACKS-APPLY" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM PACKS-PUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-FETCH.
*> USING CLIENT-STATE, row (RPS-DOWNLOAD), failed out (the row when its fetch failed): starts the
*> fetch (the cache first, else HTTP), or advances it; a complete download whose SHA-1 matches
*> (or with no expected hash) is cached and answered 4 downloaded (RPS-READY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-HEADERS             PIC X(1024).
 01 WS-HEADERS-LENGTH      BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIMIT               BINARY-LONG VALUE 262144000.
 01 WS-HEX                 PIC X(40).
 01 B-BODY                 PIC X BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-FAILED               BINARY-LONG.
 COPY CLHTTP.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-FAILED.
     IF RP-HTTP(L-ROW) = NULL
         CALL "PACK-CACHE-FIND" USING CLIENT-STATE L-ROW WS-FOUND
         IF WS-FOUND = 1
             MOVE RPS-READY TO RP-STEP(L-ROW)
             MOVE 4 TO WS-ACTION
             CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(L-ROW) WS-ACTION
             GOBACK
         END-IF
         MOVE LENGTH OF HTTP-REQUEST TO WS-BYTES
         ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING RP-HTTP(L-ROW)
         SET ADDRESS OF HTTP-REQUEST TO RP-HTTP(L-ROW)
         CALL "CLP-OFFLINE-UUID" USING CL-NAME CL-NAME-LENGTH WS-UUID
         CALL "HTTP-PACK-HEADERS" USING CL-NAME CL-NAME-LENGTH WS-UUID WS-HEADERS
             WS-HEADERS-LENGTH
         CALL "HTTP-START" USING HTTP-REQUEST RP-URL(L-ROW) RP-URL-LENGTH(L-ROW) WS-HEADERS
             WS-HEADERS-LENGTH WS-LIMIT
     END-IF
     SET ADDRESS OF HTTP-REQUEST TO RP-HTTP(L-ROW)
     CALL "HTTP-STEP" USING HTTP-REQUEST
     EVALUATE TRUE
         WHEN HR-FAILED
             MOVE L-ROW TO L-FAILED
         WHEN HR-DONE
             SET ADDRESS OF B-BODY TO HR-BODY-ADDR
             CALL "PACK-SHA1" USING B-BODY HR-BODY-LENGTH WS-HEX
             IF RP-HASH(L-ROW) NOT = SPACES AND RP-HASH(L-ROW) NOT = WS-HEX
                 MOVE L-ROW TO L-FAILED
             ELSE
                 CALL "PACK-CACHE-STORE" USING CLIENT-STATE L-ROW B-BODY HR-BODY-LENGTH WS-HEX
                 CALL "HTTP-RELEASE" USING HTTP-REQUEST
                 FREE RP-HTTP(L-ROW)
                 MOVE RPS-READY TO RP-STEP(L-ROW)
                 MOVE 4 TO WS-ACTION
                 CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(L-ROW) WS-ACTION
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PACK-FETCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACK-BATCH-FAILED.
*> USING CLIENT-STATE, the row whose fetch failed: it gets 2 failed download; every other pack being
*> fetched or waiting to be applied gets 7 discarded (08 §9.1 step 6); all of them are removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     MOVE 2 TO WS-ACTION
     CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(L-ROW) WS-ACTION
     CALL "PACK-ROW-REMOVE" USING CLIENT-STATE L-ROW
     MOVE 7 TO WS-ACTION
     PERFORM VARYING WS-I FROM RP-COUNT BY -1 UNTIL WS-I < 1
         IF RP-STEP(WS-I) = RPS-DOWNLOAD OR RP-STEP(WS-I) = RPS-READY
             CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(WS-I) WS-ACTION
             CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PACK-BATCH-FAILED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PACKS-APPLY.
*> USING CLIENT-STATE: the downloaded packs are applied (PACKS-RELOAD with them on top); each one
*> on the stack gets 0 successfully loaded, each one that could not be used 6 failed reload and is
*> removed (then the packs are reloaded without it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 01 WS-NEW.
    05 WS-NEW-FLAG         PIC 9 OCCURS 8 TIMES.
 01 WS-ACTION              BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE ZEROS TO WS-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RP-COUNT
         IF RP-STEP(WS-I) = RPS-READY
             MOVE RPS-ACTIVE TO RP-STEP(WS-I)
             MOVE 1 TO WS-NEW-FLAG(WS-I)
         END-IF
     END-PERFORM
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE 0 TO WS-REMOVED
     PERFORM VARYING WS-I FROM RP-COUNT BY -1 UNTIL WS-I < 1
         IF WS-NEW-FLAG(WS-I) = 1
             MOVE 0 TO WS-ON
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PK-COUNT
                 IF PK-SERVER(WS-K) = WS-I
                     MOVE 1 TO WS-ON
                 END-IF
             END-PERFORM
             IF WS-ON = 1
                 MOVE 0 TO WS-ACTION
                 CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(WS-I) WS-ACTION
             ELSE
                 MOVE 6 TO WS-ACTION
                 CALL "PACK-RESPOND" USING CLIENT-STATE RP-UUID(WS-I) WS-ACTION
                 CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-I
                 MOVE 1 TO WS-REMOVED
             END-IF
         END-IF
     END-PERFORM
     IF WS-REMOVED = 1
         CALL "PACKS-RELOAD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM PACKS-APPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVER-PACKS-CLEAR.
*> USING CLIENT-STATE: every server pack removed (downloads stopped), the connection's answer
*> forgotten (08 §9.5: on disconnect, and Pop without an id); the packs are reloaded when an
*> applied one went.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-ACTIVE RP-DECISION
     PERFORM UNTIL RP-COUNT = 0
         IF RP-STEP(1) = RPS-ACTIVE
             MOVE 1 TO WS-ACTIVE
         END-IF
         CALL "PACK-ROW-REMOVE" USING CLIENT-STATE WS-ROW
     END-PERFORM
     IF WS-ACTIVE = 1
         CALL "PACKS-RELOAD" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM SERVER-PACKS-CLEAR.
