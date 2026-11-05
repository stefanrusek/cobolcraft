*> Framing and compression (docs/protocol/01-transport.md §2, §3; contracts/proto-api.md §2
*> "Framing"). A packet buffer holds the packet id VarInt followed by the body. Compression uses
*> cc_deflate / cc_inflate mode CC_ZLIB (shim-abi §5); a threshold < 0 means compression is off.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-FRAME-ENCODE.
*> USING frame buffer (PB-BUFFER: the frame is appended), packet buffer (PB-BUFFER: id + body, bytes
*> 1 to PB-LENGTH), threshold (BINARY-LONG). Threshold < 0: Length, packet. Packet shorter than the
*> threshold: Length, Data length 0, packet. Otherwise: Length, Data length n, zlib stream (01 §3.2).
*> A frame body above 2 097 151 bytes or a packet above 8 388 608 bytes cannot be sent: PB-ERROR of
*> the frame buffer, nothing appended.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-N                   BINARY-LONG.
 01 WS-FRAME-LENGTH        BINARY-LONG.
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-BODY-LENGTH         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE CC-ZLIB.
 01 WS-RC                  BINARY-LONG.
 01 WS-OUT-ADDR            USAGE POINTER.
 01 B-BODY                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 L-THRESHOLD            BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PK-BUFFER L-THRESHOLD.
     MOVE PK-LENGTH TO WS-N WS-BODY-LENGTH
     MOVE -1 TO WS-DATA-LENGTH
     SET WS-OUT-ADDR TO NULL
     SET ADDRESS OF B-BODY TO PK-ADDR
     EVALUATE TRUE
         WHEN L-THRESHOLD < 0
             MOVE WS-N TO WS-FRAME-LENGTH
         WHEN WS-N < L-THRESHOLD
             MOVE 0 TO WS-DATA-LENGTH
             COMPUTE WS-FRAME-LENGTH = WS-N + 1
         WHEN WS-N > 8388608
             MOVE 2097152 TO WS-FRAME-LENGTH
         WHEN OTHER
*>           zlib stream of the packet; the capacity exceeds zlib's bound, so cc_deflate never
*>           answers CC_SMALL (any other answer makes the frame unsendable).
             MOVE WS-N TO WS-DATA-LENGTH
             COMPUTE WS-CAPACITY = WS-N + WS-N / 1000 + 64
             ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-OUT-ADDR
             CALL STATIC "cc_deflate" USING BY VALUE WS-MODE BY VALUE PK-ADDR BY VALUE WS-N
                 BY VALUE WS-OUT-ADDR BY VALUE WS-CAPACITY BY REFERENCE WS-BODY-LENGTH
                 RETURNING WS-RC
             SET ADDRESS OF B-BODY TO WS-OUT-ADDR
             MOVE 1 TO WS-SIZE
             MOVE 128 TO WS-LIMIT
             PERFORM UNTIL WS-N < WS-LIMIT
                 ADD 1 TO WS-SIZE
                 MULTIPLY 128 BY WS-LIMIT
             END-PERFORM
             COMPUTE WS-FRAME-LENGTH = WS-SIZE + WS-BODY-LENGTH
                 + 2097152 * FUNCTION MIN(1, FUNCTION ABS(WS-RC))
     END-EVALUATE
     IF WS-FRAME-LENGTH > 2097151
         MOVE 1 TO PB-ERROR
     ELSE
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-FRAME-LENGTH
         IF WS-DATA-LENGTH >= 0
             CALL "PB-PUT-VARINT" USING PB-BUFFER WS-DATA-LENGTH
         END-IF
         CALL "PB-APPEND-BYTES" USING PB-BUFFER B-BODY WS-BODY-LENGTH
     END-IF
     IF WS-OUT-ADDR NOT = NULL
         FREE WS-OUT-ADDR
     END-IF
     GOBACK.
 END PROGRAM PB-FRAME-ENCODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PB-FRAME-DECODE.
*> USING stream buffer (PB-BUFFER: received bytes, unread from PB-POS), packet buffer (PB-BUFFER,
*> initialised by the caller), threshold (BINARY-LONG, < 0 = compression off), validate (BINARY-LONG
*> 1 = reject a compressed packet below the threshold, the server side of 01 §3.3), packet id out
*> (BINARY-LONG), outcome out (BINARY-LONG):
*>   0  a packet: the packet buffer holds id + body with PB-POS after the id; the stream's PB-POS is
*>      past the frame
*>   1  need more bytes: nothing consumed (bytes already consumed are moved to the front)
*>   2  malformed: Length wider than 3 bytes, Length 0, a bad Data length, corrupt zlib data or a size
*>      mismatch (01 §2, §3.3); the caller closes the connection
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-AVAILABLE           BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-FACTOR              BINARY-LONG.
 01 WS-FRAME-LENGTH        BINARY-LONG.
 01 WS-DATA-LENGTH         BINARY-LONG.
 01 WS-MALFORMED           BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE CC-ZLIB.
 01 WS-RC                  BINARY-LONG.
 01 WS-IN-ADDR             USAGE POINTER.
 01 WS-IN-LENGTH           BINARY-LONG.
 01 WS-OUT-ADDR            USAGE POINTER.
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 B-STREAM               PIC X(1073741824) BASED.
 01 B-OUT                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 L-THRESHOLD            BINARY-LONG.
 01 L-VALIDATE             BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER PK-BUFFER L-THRESHOLD L-VALIDATE L-PACKET-ID L-OUTCOME.
     MOVE 0 TO L-PACKET-ID
     IF PB-POS = PB-LENGTH
         MOVE 0 TO PB-POS PB-LENGTH
     END-IF
     SET ADDRESS OF B-STREAM TO PB-ADDR
     COMPUTE WS-AVAILABLE = PB-LENGTH - PB-POS
     MOVE 0 TO WS-FRAME-LENGTH WS-K
     MOVE 1 TO WS-FACTOR
     MOVE 128 TO WS-BYTE
     PERFORM UNTIL WS-BYTE < 128 OR WS-K = WS-AVAILABLE OR WS-K = 3
         COMPUTE WS-BYTE = FUNCTION ORD(B-STREAM(PB-POS + WS-K + 1:1)) - 1
         ADD 1 TO WS-K
         COMPUTE WS-FRAME-LENGTH = WS-FRAME-LENGTH + FUNCTION MOD(WS-BYTE, 128) * WS-FACTOR
         MULTIPLY 128 BY WS-FACTOR
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-BYTE >= 128 AND WS-K = 3
             MOVE 2 TO L-OUTCOME
         WHEN WS-BYTE >= 128 OR WS-K + WS-FRAME-LENGTH > WS-AVAILABLE
*>           Need more: the unread bytes move to the front of the stream buffer.
             MOVE 1 TO L-OUTCOME
             IF PB-POS > 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-AVAILABLE
                     MOVE B-STREAM(PB-POS + WS-I:1) TO B-STREAM(WS-I:1)
                 END-PERFORM
                 MOVE WS-AVAILABLE TO PB-LENGTH
                 MOVE 0 TO PB-POS
             END-IF
         WHEN WS-FRAME-LENGTH = 0
             MOVE 2 TO L-OUTCOME
         WHEN OTHER
*>           A whole frame: take it, then read the Data length when compression is on.
             CALL "PB-RESET" USING PK-BUFFER
             CALL "PB-APPEND-BYTES" USING PK-BUFFER B-STREAM(PB-POS + WS-K + 1:WS-FRAME-LENGTH)
                 WS-FRAME-LENGTH
             COMPUTE PB-POS = PB-POS + WS-K + WS-FRAME-LENGTH
             MOVE 0 TO WS-MALFORMED WS-DATA-LENGTH
             IF L-THRESHOLD >= 0
                 CALL "PB-GET-VARINT" USING PK-BUFFER WS-DATA-LENGTH
             END-IF
             EVALUATE TRUE
                 WHEN WS-DATA-LENGTH < 0 OR WS-DATA-LENGTH > 8388608
                         OR (L-VALIDATE = 1 AND WS-DATA-LENGTH > 0
                             AND WS-DATA-LENGTH < L-THRESHOLD)
                     MOVE 1 TO WS-MALFORMED
                 WHEN WS-DATA-LENGTH > 0
*>                   The rest of the frame is a zlib stream of exactly that many bytes (01 §3.3).
                     ALLOCATE WS-DATA-LENGTH CHARACTERS RETURNING WS-OUT-ADDR
                     SET WS-IN-ADDR TO PK-ADDR
                     SET WS-IN-ADDR UP BY PK-POS
                     COMPUTE WS-IN-LENGTH = PK-LENGTH - PK-POS
                     CALL STATIC "cc_inflate" USING BY VALUE WS-MODE BY VALUE WS-IN-ADDR
                         BY VALUE WS-IN-LENGTH BY VALUE WS-OUT-ADDR BY VALUE WS-DATA-LENGTH
                         BY REFERENCE WS-OUT-LENGTH RETURNING WS-RC
                     IF WS-RC NOT = 0 OR WS-OUT-LENGTH NOT = WS-DATA-LENGTH
                         MOVE 1 TO WS-MALFORMED
                     ELSE
                         CALL "PB-RESET" USING PK-BUFFER
                         SET ADDRESS OF B-OUT TO WS-OUT-ADDR
                         CALL "PB-APPEND-BYTES" USING PK-BUFFER B-OUT WS-DATA-LENGTH
                     END-IF
                     FREE WS-OUT-ADDR
             END-EVALUATE
             CALL "PB-GET-VARINT" USING PK-BUFFER L-PACKET-ID
             IF WS-MALFORMED = 1 OR PK-ERROR = 1
                 MOVE 2 TO L-OUTCOME
             ELSE
                 MOVE 0 TO L-OUTCOME
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PB-FRAME-DECODE.
