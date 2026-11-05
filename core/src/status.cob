*> Status phase of the server (docs/protocol/02 "Status phase"; 01 §7.3; 09 §2, §3.1). Status is
*> answered for any protocol version. The first Status Request gets the Status Response of 09 §2;
*> a second one closes the connection (multiplayer.status.request_handled; the status phase has no
*> disconnect packet). Ping Request gets Pong Response, then the connection is closed.
*>
*> Programs:
*>   STATUS-PACKET USING id, packet id, PB-BUFFER                 one status-phase packet
*>   STATUS-RESPONSE-BUILD USING online, description PIC X(256), PB-BUFFER   (appended)
*>   STATUS-PONG-BUILD USING time (BINARY-DOUBLE), PB-BUFFER                  (appended)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATUS-PACKET.
*> USING id, packet id, packet PB-BUFFER (PB-POS after the id). 0x00 Status Request (no fields),
*> 0x01 Ping Request (Long); anything else, or bytes left over, is undecodable (01 §5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-ONLINE              BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     EVALUATE TRUE
         WHEN L-PACKET-ID = 0 AND PB-POS = PB-LENGTH AND CN-STATUS-DONE(L-ID) = 0
             CALL "PLAYERS-ONLINE" USING WS-ONLINE
             CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
             CALL "STATUS-RESPONSE-BUILD" USING WS-ONLINE CS-DESCRIPTION PK-BUFFER
             CALL "CORE-SEND" USING L-ID PK-BUFFER
             CALL "PB-FREE" USING PK-BUFFER
             MOVE 1 TO CN-STATUS-DONE(L-ID)
         WHEN L-PACKET-ID = 0 AND PB-POS = PB-LENGTH
             CALL "CORE-DISCONNECT" USING L-ID
         WHEN L-PACKET-ID = 1
             CALL "PB-GET-LONG" USING PB-BUFFER WS-TIME
             IF PB-ERROR = 0 AND PB-POS = PB-LENGTH
                 CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
                 CALL "STATUS-PONG-BUILD" USING WS-TIME PK-BUFFER
                 CALL "CORE-SEND" USING L-ID PK-BUFFER
                 CALL "PB-FREE" USING PK-BUFFER
                 CALL "CORE-DISCONNECT" USING L-ID
             ELSE
                 CALL "CORE-BAD-PACKET" USING L-ID
             END-IF
         WHEN OTHER
             CALL "CORE-BAD-PACKET" USING L-ID
     END-EVALUATE
     GOBACK.
 END PROGRAM STATUS-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATUS-RESPONSE-BUILD.
*> USING players online (BINARY-LONG), description (PIC X(256), trailing spaces not part of it),
*> packet PB-BUFFER (appended to): Status Response, status 0x00, JSON String(32767) exactly
*> {"version":{"name":"CobolCraft","protocol":777},"players":{"max":20,"online":<n>},
*> "description":"<description>"} with no whitespace (09 §2); the description is a JSON string
*> (09 §1 literal text).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==JS-==.
 01 WS-HEAD                PIC X(77) VALUE
     '{"version":{"name":"CobolCraft","protocol":777},"players":{"max":20,"online":'.
 01 WS-HEAD-LENGTH         BINARY-LONG VALUE 77.
 01 WS-MIDDLE              PIC X(16) VALUE '},"description":'.
 01 WS-MIDDLE-LENGTH       BINARY-LONG VALUE 16.
 01 WS-BRACE               PIC X VALUE "}".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-DIGITS              PIC X(10).
 01 WS-DIGITS-LENGTH       BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 B-JSON                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ONLINE               BINARY-LONG.
 01 L-DESCRIPTION          PIC X(256).
 PROCEDURE DIVISION USING L-ONLINE L-DESCRIPTION PB-BUFFER.
     CALL "PB-INIT" USING JS-BUFFER WS-CAPACITY
     CALL "PB-APPEND-BYTES" USING JS-BUFFER WS-HEAD WS-HEAD-LENGTH
     MOVE L-ONLINE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-DIGITS
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-DIGITS-LENGTH
     CALL "PB-APPEND-BYTES" USING JS-BUFFER WS-DIGITS WS-DIGITS-LENGTH
     CALL "PB-APPEND-BYTES" USING JS-BUFFER WS-MIDDLE WS-MIDDLE-LENGTH
     MOVE 256 TO WS-LENGTH
     PERFORM UNTIL WS-LENGTH = 0
         IF L-DESCRIPTION(WS-LENGTH:1) NOT = SPACE
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-LENGTH
     END-PERFORM
     CALL "TEXT-JSON-STRING" USING JS-BUFFER L-DESCRIPTION WS-LENGTH
     CALL "PB-APPEND-BYTES" USING JS-BUFFER WS-BRACE WS-ONE
     SET ADDRESS OF B-JSON TO JS-ADDR
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-STRING" USING PB-BUFFER B-JSON JS-LENGTH WS-MAX
     CALL "PB-FREE" USING JS-BUFFER
     GOBACK.
 END PROGRAM STATUS-RESPONSE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATUS-PONG-BUILD.
*> USING time (BINARY-DOUBLE), packet PB-BUFFER (appended to): Pong Response, status 0x01, the
*> Long of the Ping Request (02).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TIME PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER L-TIME
     GOBACK.
 END PROGRAM STATUS-PONG-BUILD.
