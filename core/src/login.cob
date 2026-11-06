*> Login phase of the server (docs/protocol/02 "Login phase", "Login sequence"; 09 §1, §2, §3.1, §4).
*> Offline mode only: Hello is answered at once by Set Compression (network connections) and Login
*> Finished; Login Acknowledged moves the connection to configuration. The protocol-version and
*> transfer checks of 02 are made when the Intention arrives. Also the JSON text form of 09 §1,
*> used by Login Disconnect here and by the Status Response (core/src/status.cob).
*>
*> Programs:
*>   LOGIN-INTENTION USING id                         Intention with intent 2 or 3 (from the session)
*>   LOGIN-PACKET USING id, packet id, PB-BUFFER      one login-phase packet (PB-POS after the id)
*>   LOGIN-SEND-DISCONNECT USING id, PB-TEXT          queue Login Disconnect (the caller closes)
*>   LOGIN-OFFLINE-UUID USING name area, length, uuid PIC X(16) out
*>   LOGIN-NAME-VALID USING name area, length, valid out (BINARY-LONG 1 = valid)
*>   LOGIN-HELLO-DECODE USING PB-BUFFER, name PIC X(16) out, length out, uuid out, ok out
*>   LOGIN-COMPRESSION-BUILD USING threshold, PB-BUFFER      Set Compression (appended)
*>   LOGIN-FINISHED-BUILD USING uuid, name PIC X(16), length, PB-BUFFER   Login Finished (appended)
*>   LOGIN-DISCONNECT-BUILD USING PB-TEXT, PB-BUFFER         Login Disconnect (appended)
*>   TEXT-JSON USING PB-TEXT, PB-BUFFER                      09 §1 JSON form (appended)
*>   TEXT-JSON-STRING USING PB-BUFFER, text area, length     a JSON string (appended)
*> Areas of any length are declared PIC X and read through a BASED view. Such a program is placed
*> after its callers in this file: -Wall checks a call against a program defined before it.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-INTENTION.
*> USING id: the connection is in the login phase with CN-PROTOCOL and CN-INTENT of its Intention.
*> 02 and 09 §2: intent 3 (transfer) is refused with multiplayer.disconnect.transfers_disabled; a
*> login with a protocol other than 777 is refused with multiplayer.disconnect.incompatible (client
*> version 754 or above) or multiplayer.disconnect.outdated_client (below 754), argument the server
*> version name CobolCraft. Each refusal is a Login Disconnect, then the connection is closed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 78 LOGIN-PROTOCOL          VALUE 777.
 78 LOGIN-OLDEST-NETTY      VALUE 754.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     EVALUATE TRUE
         WHEN CN-INTENT(L-ID) = 3
             MOVE "multiplayer.disconnect.transfers_disabled" TO PB-TX-VALUE
             MOVE 41 TO PB-TX-LENGTH
             CALL "CORE-SEND-DISCONNECT" USING L-ID PB-TEXT
         WHEN CN-PROTOCOL(L-ID) NOT = LOGIN-PROTOCOL
             MOVE "multiplayer.disconnect.incompatible" TO PB-TX-VALUE
             MOVE 35 TO PB-TX-LENGTH
             IF CN-PROTOCOL(L-ID) < LOGIN-OLDEST-NETTY
                 MOVE "multiplayer.disconnect.outdated_client" TO PB-TX-VALUE
                 MOVE 38 TO PB-TX-LENGTH
             END-IF
             MOVE 1 TO PB-TX-ARG-COUNT
             MOVE "CobolCraft" TO PB-TX-ARG-VALUE(1)
             MOVE 10 TO PB-TX-ARG-LENGTH(1)
             CALL "CORE-SEND-DISCONNECT" USING L-ID PB-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM LOGIN-INTENTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-PACKET.
*> USING id, packet id, packet PB-BUFFER (PB-POS after the id). 02 login packets:
*>   0x00 Hello: a valid name (09 §1) is accepted (LOGIN-ACCEPT); a second Hello, a name outside
*>        the rule or a packet that does not decode is a protocol error (CORE-BAD-PACKET).
*>   0x03 Login Acknowledged: after Login Finished, the connection enters configuration
*>        (CORE-SET-PHASE, then CONFIG-START); before it, a protocol error.
*>   0x02 Custom Query Answer and 0x04 Cookie Response: never solicited, so a decodable one is
*>        answered with Login Disconnect multiplayer.disconnect.unexpected_query_response (02; 09 §4).
*>   Any other id (0x01 Key: CobolCraft never sends Encryption Request) is undecodable (01 §5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==RS-==.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-OK                  BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-KEY                 PIC X(32767).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 32767.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-QUERY-MAX           BINARY-LONG VALUE 1048576.
 01 WS-COOKIE-MAX          BINARY-LONG VALUE 5120.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
     MOVE 0 TO WS-OK
     EVALUATE L-PACKET-ID
         WHEN 0
             IF CN-PLAYER(L-ID) = 0
                 CALL "LOGIN-HELLO-DECODE" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-UUID WS-OK
             END-IF
             IF WS-OK = 1
                 CALL "LOGIN-ACCEPT" USING L-ID WS-NAME WS-NAME-LENGTH
             END-IF
         WHEN 3
             IF CN-PLAYER(L-ID) > 0 AND PB-POS = PB-LENGTH
                 MOVE 1 TO WS-OK
                 MOVE PH-CONFIG TO WS-PHASE
                 CALL "CORE-SET-PHASE" USING L-ID WS-PHASE
                 CALL "CONFIG-START" USING L-ID
             END-IF
         WHEN 2
*>           Transaction id, then the rest of the packet is skipped (at most 1 048 576 bytes).
             CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
             IF PB-ERROR = 0 AND PB-LENGTH - PB-POS <= WS-QUERY-MAX
                 MOVE 1 TO WS-OK
             END-IF
         WHEN 4
*>           Key (Identifier), then an Optional ByteArray(5120).
             CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
             CALL "PB-GET-BOOL" USING PB-BUFFER WS-VALUE
             IF WS-VALUE = 1
                 CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
                 IF WS-VALUE > WS-COOKIE-MAX
                     MOVE 1 TO PB-ERROR
                 END-IF
                 CALL "PB-SKIP" USING PB-BUFFER WS-VALUE
             END-IF
             IF PB-ERROR = 0 AND PB-POS = PB-LENGTH
                 MOVE 1 TO WS-OK
             END-IF
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-OK = 0
             CALL "CORE-BAD-PACKET" USING L-ID
         WHEN L-PACKET-ID = 2 OR L-PACKET-ID = 4
             INITIALIZE RS-TEXT
             MOVE RS-TEXT-TRANSLATE TO RS-TX-KIND
             MOVE "multiplayer.disconnect.unexpected_query_response" TO RS-TX-VALUE
             MOVE 48 TO RS-TX-LENGTH
             CALL "CORE-SEND-DISCONNECT" USING L-ID RS-TEXT
     END-EVALUATE
     GOBACK.
 END PROGRAM LOGIN-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-ACCEPT.
*> USING id, name (PIC X(16)), name length: the offline login of a valid Hello (02 Offline mode).
*> A banned identity (offline UUID on the ban list) is refused with Login Disconnect
*> cobolcraft.disconnect.barred; while the world's allow-list enforcement flag is on, an identity
*> not on the allow-list is refused with cobolcraft.disconnect.not_on_guestlist (standin §17,
*> FR-010, FR-016; the connection closes and no player is created). In a world opened to others
*> (host kind 2), a network login with the host's name is refused first with
*> cobolcraft.disconnect.name_is_host [name] (US17 edge case): the host stays.
*> A player already online with that name (the same offline UUID) is replaced first: its connection
*> gets Disconnect cobolcraft.disconnect.replaced (standin §17, 09 §3.1) and its player leaves, so
*> the name is free. Then the player is created with the offline UUID; a network connection gets
*> Set Compression 256, sent uncompressed, and compression starts (09 §2); then Login Finished.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY MESSAGES.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-THRESHOLD           BINARY-LONG VALUE 256.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-FULL                PIC X(39) VALUE "ERROR login: the player table is full".
 01 WS-FULL-LENGTH         BINARY-LONG VALUE 37.
 01 WS-LIST                BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-NAME-LENGTH.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "LOGIN-OFFLINE-UUID" USING L-NAME L-NAME-LENGTH WS-UUID
     MOVE ACCESS-BANS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE 0 TO WS-MSG
     IF WS-ROW > 0
         MOVE MK-DC-BARRED TO WS-MSG
     ELSE
         MOVE ACCESS-ALLOW TO WS-LIST
         CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
         IF AC-ENFORCED = 1 AND WS-ROW = 0
             MOVE MK-DC-NOT-ON-GUESTLIST TO WS-MSG
         END-IF
     END-IF
     IF CS-HOST-KIND = 2 AND CN-KIND(L-ID) = CORE-CONN-NETWORK AND L-NAME = CS-HOST-NAME
         MOVE MK-DC-NAME-IS-HOST TO WS-MSG
     END-IF
     IF WS-MSG > 0
         CALL "CMD-TEXT-KEY" USING PB-TEXT WS-MSG
         IF WS-MSG = MK-DC-NAME-IS-HOST
             CALL "CMD-TEXT-ARG" USING PB-TEXT L-NAME L-NAME-LENGTH
         END-IF
         CALL "CORE-SEND-DISCONNECT" USING L-ID PB-TEXT
         GOBACK
     END-IF
     CALL "PLAYER-FIND-NAME" USING L-NAME L-NAME-LENGTH WS-ROW
     IF WS-ROW > 0
         MOVE PL-CONN(WS-ROW) TO WS-OLD
         INITIALIZE PB-TEXT
         MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
         MOVE "cobolcraft.disconnect.replaced" TO PB-TX-VALUE
         MOVE 30 TO PB-TX-LENGTH
         CALL "CORE-SEND-DISCONNECT" USING WS-OLD PB-TEXT
         CALL "PLAYER-LEAVE" USING WS-ROW
     END-IF
     CALL "PLAYER-CREATE" USING L-ID L-NAME L-NAME-LENGTH WS-UUID WS-ROW
     IF WS-ROW = 0
         CALL "CORE-LOG" USING WS-FULL WS-FULL-LENGTH
         CALL "CORE-DISCONNECT" USING L-ID
     ELSE
         CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
         IF CN-KIND(L-ID) = CORE-CONN-NETWORK
             CALL "LOGIN-COMPRESSION-BUILD" USING WS-THRESHOLD PK-BUFFER
             CALL "CORE-SEND" USING L-ID PK-BUFFER
             MOVE 1 TO CN-COMPRESS(L-ID)
             CALL "PB-RESET" USING PK-BUFFER
         END-IF
         CALL "LOGIN-FINISHED-BUILD" USING WS-UUID L-NAME L-NAME-LENGTH PK-BUFFER
         CALL "CORE-SEND" USING L-ID PK-BUFFER
         CALL "PB-FREE" USING PK-BUFFER
     END-IF
     GOBACK.
 END PROGRAM LOGIN-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-SEND-DISCONNECT.
*> USING id, PB-TEXT: queues Login Disconnect (login 0x00) with the JSON form of the text (09 §1).
*> Nothing else: CORE-SEND-DISCONNECT, the caller, raises the close flag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PB-TEXT.
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "LOGIN-DISCONNECT-BUILD" USING PB-TEXT PK-BUFFER
     CALL "CORE-SEND" USING L-ID PK-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM LOGIN-SEND-DISCONNECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-OFFLINE-UUID.
*> USING name (area of UTF-8 bytes), byte length (1 to 48), uuid out (PIC X(16)): the offline UUID
*> UUID.nameUUIDFromBytes("OfflinePlayer:" + name) (02 Offline mode; research R11): MD5 of the
*> bytes by a direct OpenSSL call, then byte 6 gets version 3 (high nibble 0011) and byte 8 the
*> IETF variant (high bits 10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA                PIC X(64).
 01 WS-DATA-LENGTH         BINARY-DOUBLE UNSIGNED.
 01 WS-DIGEST              PIC X(64).
 01 WS-DIGEST-LENGTH       BINARY-LONG UNSIGNED.
 01 WS-ALGORITHM           USAGE POINTER.
 01 WS-ENGINE              USAGE POINTER VALUE NULL.
 01 WS-RC                  BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 B-NAME                 PIC X(48) BASED.
 LINKAGE SECTION.
 01 L-NAME                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-UUID.
     SET ADDRESS OF B-NAME TO ADDRESS OF L-NAME
     MOVE "OfflinePlayer:" TO WS-DATA
     MOVE B-NAME(1:L-LENGTH) TO WS-DATA(15:L-LENGTH)
     COMPUTE WS-DATA-LENGTH = 14 + L-LENGTH
     CALL STATIC "EVP_md5" RETURNING WS-ALGORITHM
     CALL STATIC "EVP_Digest" USING BY REFERENCE WS-DATA BY VALUE WS-DATA-LENGTH
         BY REFERENCE WS-DIGEST BY REFERENCE WS-DIGEST-LENGTH BY VALUE WS-ALGORITHM
         BY VALUE WS-ENGINE RETURNING WS-RC
     MOVE WS-DIGEST(1:16) TO L-UUID
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION ORD(L-UUID(7:1)) - 1, 16) + 48
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO L-UUID(7:1)
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION ORD(L-UUID(9:1)) - 1, 64) + 128
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO L-UUID(9:1)
     GOBACK.
 END PROGRAM LOGIN-OFFLINE-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-HELLO-DECODE.
*> USING PB-BUFFER (PB-POS after the packet id), name out (PIC X(16), space-filled), byte length
*> out, profile uuid out (PIC X(16)), ok out (BINARY-LONG): Hello = String(16) name, UUID (02).
*> ok = 1 when the packet decodes with no bytes left over and the name follows 09 §1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-LENGTH L-UUID L-OK.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-OK
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX L-NAME WS-CAPACITY L-LENGTH
     CALL "PB-GET-UUID" USING PB-BUFFER L-UUID
     IF PB-ERROR = 0 AND PB-POS = PB-LENGTH
         CALL "LOGIN-NAME-VALID" USING L-NAME L-LENGTH L-OK
     END-IF
     GOBACK.
 END PROGRAM LOGIN-HELLO-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-NAME-VALID.
*> USING name (area), byte length, valid out (BINARY-LONG): 1 when the name has 1 to 16 characters,
*> each A-Z, a-z, 0-9 or _ (09 §1 player names).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 B-NAME                 PIC X(16) BASED.
 LINKAGE SECTION.
 01 L-NAME                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-VALID.
     MOVE 0 TO L-VALID
     IF L-LENGTH >= 1 AND L-LENGTH <= 16
         MOVE 1 TO L-VALID
         SET ADDRESS OF B-NAME TO ADDRESS OF L-NAME
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
             IF NOT (B-NAME(WS-I:1) >= "A" AND B-NAME(WS-I:1) <= "Z")
                     AND NOT (B-NAME(WS-I:1) >= "a" AND B-NAME(WS-I:1) <= "z")
                     AND NOT (B-NAME(WS-I:1) >= "0" AND B-NAME(WS-I:1) <= "9")
                     AND B-NAME(WS-I:1) NOT = "_"
                 MOVE 0 TO L-VALID
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM LOGIN-NAME-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-COMPRESSION-BUILD.
*> USING threshold (BINARY-LONG), packet PB-BUFFER (appended to): Set Compression, login 0x03,
*> VarInt threshold (02).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-THRESHOLD            BINARY-LONG.
 PROCEDURE DIVISION USING L-THRESHOLD PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-THRESHOLD
     GOBACK.
 END PROGRAM LOGIN-COMPRESSION-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-FINISHED-BUILD.
*> USING uuid (PIC X(16)), name (PIC X(16)), name byte length, packet PB-BUFFER (appended to):
*> Login Finished, login 0x02: GameProfile (UUID, String(16) name, 0 properties) and the all-zero
*> session id (02; 09 §1, §3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 2.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SESSION             PIC X(16) VALUE LOW-VALUES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-UUID                 PIC X(16).
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-UUID L-NAME L-LENGTH PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER L-UUID
     CALL "PB-PUT-STRING" USING PB-BUFFER L-NAME L-LENGTH WS-MAX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-SESSION
     GOBACK.
 END PROGRAM LOGIN-FINISHED-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOGIN-DISCONNECT-BUILD.
*> USING PB-TEXT, packet PB-BUFFER (appended to): Login Disconnect, login 0x00, the reason as a JSON
*> String(262144) in the 09 §1 JSON form.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==JS-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 262144.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 B-JSON                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT PB-BUFFER.
     CALL "PB-INIT" USING JS-BUFFER WS-CAPACITY
     CALL "TEXT-JSON" USING PB-TEXT JS-BUFFER
     SET ADDRESS OF B-JSON TO JS-ADDR
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-STRING" USING PB-BUFFER B-JSON JS-LENGTH WS-MAX
     CALL "PB-FREE" USING JS-BUFFER
     GOBACK.
 END PROGRAM LOGIN-DISCONNECT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEXT-JSON.
*> USING PB-TEXT, PB-BUFFER (appended to): the JSON form of 09 §1. A plain or literal text is a
*> JSON string; translate is {"translate":"<key>"} or {"translate":"<key>","with":["<arg>",...]}.
*> No whitespace; strings escaped by TEXT-JSON-STRING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-OPEN                PIC X(13) VALUE '{"translate":'.
 01 WS-OPEN-LENGTH         BINARY-LONG VALUE 13.
 01 WS-WITH                PIC X(9) VALUE ',"with":['.
 01 WS-WITH-LENGTH         BINARY-LONG VALUE 9.
 01 WS-COMMA               PIC X VALUE ",".
 01 WS-BRACKET             PIC X VALUE "]".
 01 WS-BRACE               PIC X VALUE "}".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT PB-BUFFER.
     IF PB-TX-KIND = PB-TEXT-TRANSLATE
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-OPEN WS-OPEN-LENGTH
         CALL "TEXT-JSON-STRING" USING PB-BUFFER PB-TX-VALUE PB-TX-LENGTH
         IF PB-TX-ARG-COUNT > 0
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-WITH WS-WITH-LENGTH
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-ARG-COUNT
                 IF WS-I > 1
                     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-COMMA WS-ONE
                 END-IF
                 CALL "TEXT-JSON-STRING" USING PB-BUFFER PB-TX-ARG-VALUE(WS-I)
                     PB-TX-ARG-LENGTH(WS-I)
             END-PERFORM
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BRACKET WS-ONE
         END-IF
         CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BRACE WS-ONE
     ELSE
         CALL "TEXT-JSON-STRING" USING PB-BUFFER PB-TX-VALUE PB-TX-LENGTH
     END-IF
     GOBACK.
 END PROGRAM TEXT-JSON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEXT-JSON-STRING.
*> USING PB-BUFFER (appended to), text (area of UTF-8 bytes), byte length (BINARY-LONG >= 0): the
*> text as a JSON string, with " and \ escaped as \" and \\ (09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-QUOTE               PIC X VALUE '"'.
 01 WS-BACKSLASH           PIC X VALUE "\".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 B-TEXT                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TEXT L-LENGTH.
     SET ADDRESS OF B-TEXT TO ADDRESS OF L-TEXT
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-QUOTE WS-ONE
     MOVE 1 TO WS-START
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         IF B-TEXT(WS-I:1) = WS-QUOTE OR B-TEXT(WS-I:1) = WS-BACKSLASH
             COMPUTE WS-COUNT = WS-I - WS-START
             CALL "PB-APPEND-BYTES" USING PB-BUFFER B-TEXT(WS-START:1) WS-COUNT
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-BACKSLASH WS-ONE
             MOVE WS-I TO WS-START
         END-IF
     END-PERFORM
     COMPUTE WS-COUNT = L-LENGTH + 1 - WS-START
     CALL "PB-APPEND-BYTES" USING PB-BUFFER B-TEXT(WS-START:1) WS-COUNT
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-QUOTE WS-ONE
     GOBACK.
 END PROGRAM TEXT-JSON-STRING.
