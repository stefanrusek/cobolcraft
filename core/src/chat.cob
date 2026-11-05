*> Chat (US6; FR-013; docs/protocol/09-cobolcraft-profile.md §1 "Chat is unsigned", §3.2 rows 0x09
*> and 0x7C; 05c 0x09; 05b 0x7C).
*>
*> A Chat packet (05c 0x09, decoded by PLAY-DECODE: the message is a String of at most 256 code
*> units, so a longer one is a decoding error, 01 §5) from a player in play is broadcast at once, as
*> System Chat with the literal text `<name> message` and overlay false, to every connection in the
*> play phase that has a player, in any dimension and including the sender. Messages are handled in
*> the order the server receives them, and each is queued to every player before the next is read,
*> so every player sees them in the same order (SC-006).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SYSTEM-CHAT-BUILD.
*> USING PB-TEXT, PB-BUFFER: System Chat 0x7C (05b: the text component as network NBT, 09 §1 fixed
*> form; then Boolean overlay, always false: chat, not the action bar).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 124.
 01 WS-OVERLAY             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-OVERLAY
     GOBACK.
 END PROGRAM SYSTEM-CHAT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-LINE-BUILD.
*> USING name (PIC X(16)), name length, message (PIC X(768), UTF-8), message byte length, PB-BUFFER:
*> the System Chat of a player's chat line, the plain text `<name> message` (09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-MESSAGE              PIC X(768).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-MESSAGE L-LENGTH PB-BUFFER.
     INITIALIZE PK-TEXT
     MOVE PK-TEXT-PLAIN TO PK-TX-KIND
     MOVE 1 TO WS-PTR
     STRING "<" L-NAME(1:L-NAME-LENGTH) "> " DELIMITED BY SIZE INTO PK-TX-VALUE POINTER WS-PTR
     IF L-LENGTH > 0
         MOVE L-MESSAGE(1:L-LENGTH) TO PK-TX-VALUE(WS-PTR:L-LENGTH)
     END-IF
     COMPUTE PK-TX-LENGTH = WS-PTR - 1 + L-LENGTH
     CALL "SYSTEM-CHAT-BUILD" USING PK-TEXT PB-BUFFER
     GOBACK.
 END PROGRAM CHAT-LINE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-MESSAGE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Chat 0x09): broadcasts the sender's chat line
*> (CHAT-LINE-BUILD) to every connection in play that has a player, the sender included.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CHAT-LINE-BUILD" USING PL-NAME(WS-ROW) PL-NAME-LENGTH(WS-ROW) PSB-MESSAGE
         PSB-MESSAGE-LENGTH PB-BUFFER
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-PHASE(WS-ID) = PH-PLAY AND CN-PLAYER(WS-ID) > 0
             CALL "CORE-SEND" USING WS-ID PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CHAT-MESSAGE.
