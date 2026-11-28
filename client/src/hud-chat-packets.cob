*> The chat packets of the client (docs/protocol/57-client-closures-5 sections 1.1 and 2, task T47400): System Chat (id 0x7C = 124), Player Chat (0x42 = 66), Disguised
*> Chat (0x21 = 33) and Delete Chat (0x1F = 31) as ClientPacketListener handles them. Every program reads the body of the packet from PB-BUFFER (positioned after the id).
*> The validator (2.2): a client takes the Login packet's enforcesSecureChat (HX-ENFORCES); with it true every player message is an error line, with it false (CobolCraft)
*> the message is accepted as unsigned and its trust level is NOT_SECURE (a line with the server message tag; MODIFIED needs a text that differs from the signed content and
*> a signature, which an unsigned message never has). A message of the local player on a hosted world is SECURE (no tag). Delete Chat can only find a signed line, and
*> every line the client stores is unsigned (2.6): it is read and has no effect. A sender that is not in the player list is an error line; a wrong global index is a
*> disconnect (multiplayer.disconnect.bad_chat_index). Not built: the key-based validator (57-5 open question 3: CobolCraft sends no chat sessions).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-SYSTEM-READ.
*> USING CLIENT-STATE, PB-BUFFER: System Chat (05b 0x7C): the content and the overlay flag. Overlay true is the action bar (57-5 section 3.4, animate false); false is a server
*> system line (tag 5 server message, source 3) in the chat.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-TAG                 BINARY-LONG VALUE 5.
 01 WS-SOURCE              BINARY-LONG VALUE 3.
 01 WS-ANIMATE             BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-OVERLAY
     IF PB-ERROR = 1
         GOBACK
     END-IF
     CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
     IF WS-OVERLAY = 1
         CALL "ACTIONBAR-SET" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-ANIMATE
     ELSE
         CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SOURCE
     END-IF
     GOBACK.
 END PROGRAM CHAT-SYSTEM-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-SKIP-STYLE.
*> USING PB-BUFFER: one style of a chat type decoration (a network NBT compound; 05a ChatTypeDecoration) read and not kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     IF WS-TYPE NOT = 0
         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
     END-IF
     GOBACK.
 END PROGRAM CHAT-SKIP-STYLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-DECORATION-READ.
*> USING CLIENT-STATE, PB-BUFFER, keep (1 to keep it in row 16 of HX-CT, the inline decoration), 0 to read it and drop it: one ChatTypeDecoration (translation key String, a VarInt list
*> of parameters where 0 is the sender, 1 the target and 2 the content and an id outside that range is 0, the style, which is read and not kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(3000).
 01 WS-CAP                 BINARY-LONG VALUE 3000.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-KEEP                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-KEEP.
     CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX WS-KEY WS-CAP WS-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     IF WS-COUNT < 0 OR WS-COUNT > 64
         MOVE 1 TO PB-ERROR
         GOBACK
     END-IF
     IF L-KEEP = 1
         MOVE SPACES TO HX-CT-KEY(16)
         MOVE WS-KEY(1:64) TO HX-CT-KEY(16)
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO HX-CT-KEY-LEN(16)
         MOVE FUNCTION MIN(WS-COUNT, 3) TO HX-CT-PCOUNT(16)
         MOVE 0 TO HX-CT-PARAM(16, 1) HX-CT-PARAM(16, 2) HX-CT-PARAM(16, 3)
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
         IF L-KEEP = 1 AND WS-I <= 3 AND (WS-VALUE = 1 OR WS-VALUE = 2)
             MOVE WS-VALUE TO HX-CT-PARAM(16, WS-I)
         END-IF
     END-PERFORM
     CALL "CHAT-SKIP-STYLE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CHAT-DECORATION-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-BOUND-READ.
*> USING CLIENT-STATE, PB-BUFFER, chat type index out (the registry id from 0, -1 for an inline type), sender (PIC X(256)), its length, target (PIC X(256)), its length (0 when
*> absent): ChatTypeBound (05a): the holder of the chat type (a VarInt that is the registry id + 1, or 0 and the inline decoration pair: the chat decoration is kept in row 16 of HX-CT and
*> the index out is 15, the narration is read and dropped), the sender name and the optional target name as text components, rendered.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-SENDER               PIC X(256).
 01 L-SENDER-LENGTH        BINARY-LONG.
 01 L-TARGET               PIC X(256).
 01 L-TARGET-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER L-INDEX L-SENDER L-SENDER-LENGTH L-TARGET L-TARGET-LENGTH.
     MOVE SPACES TO L-SENDER L-TARGET
     MOVE 0 TO L-SENDER-LENGTH L-TARGET-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-HOLDER
     IF WS-HOLDER = 0
         MOVE 1 TO WS-KEEP
         CALL "CHAT-DECORATION-READ" USING CLIENT-STATE PB-BUFFER WS-KEEP
         MOVE 0 TO WS-KEEP
         CALL "CHAT-DECORATION-READ" USING CLIENT-STATE PB-BUFFER WS-KEEP
         MOVE 15 TO L-INDEX
     ELSE
         COMPUTE L-INDEX = WS-HOLDER - 1
     END-IF
     CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
     CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
     MOVE WS-TEXT(1:256) TO L-SENDER
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO L-SENDER-LENGTH
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-TEXT WS-LENGTH
         MOVE WS-TEXT(1:256) TO L-TARGET
         MOVE FUNCTION MIN(WS-LENGTH, 256) TO L-TARGET-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CHAT-BOUND-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-ERROR-LINE.
*> USING CLIENT-STATE, chat type index, sender (PIC X(256)), its length, target, its length: the error line of 57-5 section 2.4: the text "Chat validation error" in the decoration
*> of the chat type, with the error tag (3) and the player source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(80) VALUE "chat.validation_error".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 21.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-EMPTY2              PIC X(256) VALUE SPACES.
 01 WS-EMPTY3              PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-MSG                 PIC X(512).
 01 WS-MSG-LENGTH          BINARY-LONG.
 01 WS-BODY                PIC X(256).
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG VALUE 3.
 01 WS-SOURCE              BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-INDEX                BINARY-LONG.
 01 L-SENDER               PIC X(256).
 01 L-SENDER-LENGTH        BINARY-LONG.
 01 L-TARGET               PIC X(256).
 01 L-TARGET-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-INDEX L-SENDER L-SENDER-LENGTH L-TARGET L-TARGET-LENGTH.
     CALL "CHAT-TR" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO WS-EMPTY2 WS-ZERO2 WS-EMPTY3 WS-ZERO3 WS-MSG WS-MSG-LENGTH
     MOVE SPACES TO WS-BODY
     MOVE WS-MSG(1:256) TO WS-BODY
     CALL "CHAT-DECORATE" USING CLIENT-STATE L-INDEX L-SENDER L-SENDER-LENGTH L-TARGET L-TARGET-LENGTH
         WS-BODY WS-MSG-LENGTH WS-TEXT WS-LENGTH
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SOURCE
     GOBACK.
 END PROGRAM CHAT-ERROR-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-PLAYER-READ.
*> USING CLIENT-STATE, PB-BUFFER: Player Chat (05a 0x42): global index, sender UUID, per-sender index, optional 256 byte signature, the packed body (content String of 256,
*> timestamp, salt, up to 20 packed signatures: a VarInt, 0 followed by 256 bytes), optional unsigned content, the filter mask (VarInt kind; kind 2 has a ByteBitSet), the
*> ChatTypeBound. Steps of 57-5 section 2.2 and 2.4: the index must equal the counter (else a disconnect), the sender must be in the player list and the validator must accept,
*> else an error line (tag 3, "<sender> Chat validation error" in the decoration of the type, source 2); a fully filtered message (kind 1) is dropped; the line is
*> the unsigned content when the packet has it (and the option onlyShowSecureChat is off), else the signed content, decorated by its chat type; tag 1 (not secure) or none
*> for the local player of a hosted world; with onlyShowSecureChat on a not secure line is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-INDEX               BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-SENDER-INDEX        BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-SIGNATURE           PIC X(256).
 01 WS-SIG-LENGTH          BINARY-LONG VALUE 256.
 01 WS-CONTENT             PIC X(1024).
 01 WS-CONTENT-CAP         BINARY-LONG VALUE 1024.
 01 WS-CONTENT-MAX         BINARY-LONG VALUE 256.
 01 WS-CONTENT-LENGTH      BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-UNSIGNED            PIC X(512).
 01 WS-UNSIGNED-LENGTH     BINARY-LONG.
 01 WS-HAS-UNSIGNED        BINARY-LONG.
 01 WS-MASK-KIND           BINARY-LONG.
 01 WS-MASK-BYTES          BINARY-LONG.
 01 WS-SCRATCH             PIC X(4096).
 01 WS-TYPE-INDEX          BINARY-LONG.
 01 WS-SENDER              PIC X(256).
 01 WS-SENDER-LENGTH       BINARY-LONG.
 01 WS-TARGET              PIC X(256).
 01 WS-TARGET-LENGTH       BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BODY                PIC X(256).
 01 WS-BODY-LENGTH         BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-EMPTY2              PIC X(256) VALUE SPACES.
 01 WS-EMPTY3              PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-TAG                 BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG VALUE 2.
 01 WS-OPTION              PIC X(40) VALUE "onlyShowSecureChat".
 01 WS-OPTION-DEFAULT      BINARY-LONG VALUE 0.
 01 WS-ONLY-SECURE         BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-MSG                 PIC X(512).
 01 WS-MSG-LENGTH          BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-INDEX
     CALL "PB-GET-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SENDER-INDEX
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
     IF WS-PRESENT = 1
         CALL "PB-GET-BYTES" USING PB-BUFFER WS-SIGNATURE WS-SIG-LENGTH
     END-IF
     MOVE SPACES TO WS-CONTENT
     CALL "PB-GET-STRING" USING PB-BUFFER WS-CONTENT-MAX WS-CONTENT WS-CONTENT-CAP WS-CONTENT-LENGTH
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     IF WS-COUNT < 0 OR WS-COUNT > 20
         MOVE 1 TO PB-ERROR
         MOVE 0 TO WS-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
         IF WS-VALUE = 0
             CALL "PB-GET-BYTES" USING PB-BUFFER WS-SIGNATURE WS-SIG-LENGTH
         END-IF
     END-PERFORM
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-HAS-UNSIGNED
     MOVE 0 TO WS-UNSIGNED-LENGTH
     IF WS-HAS-UNSIGNED = 1
         CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
         CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-UNSIGNED WS-UNSIGNED-LENGTH
     END-IF
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-MASK-KIND
     IF WS-MASK-KIND = 2
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-MASK-BYTES
         IF WS-MASK-BYTES < 0 OR WS-MASK-BYTES > 4096
             MOVE 1 TO PB-ERROR
         ELSE
             IF WS-MASK-BYTES > 0
                 CALL "PB-GET-BYTES" USING PB-BUFFER WS-SCRATCH WS-MASK-BYTES
             END-IF
         END-IF
     END-IF
     CALL "CHAT-BOUND-READ" USING CLIENT-STATE PB-BUFFER WS-TYPE-INDEX WS-SENDER WS-SENDER-LENGTH WS-TARGET WS-TARGET-LENGTH
     IF PB-ERROR = 1
         GOBACK
     END-IF
*>   1. The global index (the counter counts either way): a miss ends the connection.
     MOVE HX-CHAT-INDEX TO WS-VALUE
     ADD 1 TO HX-CHAT-INDEX
     IF WS-INDEX NOT = WS-VALUE
         MOVE "multiplayer.disconnect.bad_chat_index" TO WS-KEY
         MOVE 37 TO WS-KEY-LENGTH
         CALL "CHAT-TR" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO WS-EMPTY2 WS-ZERO2 WS-EMPTY3 WS-ZERO3 WS-MSG WS-MSG-LENGTH
         CALL "CLIENT-DISCONNECT" USING CLIENT-STATE WS-CONN WS-MSG WS-MSG-LENGTH
         GOBACK
     END-IF
*>   2. The sender must be in the player list.
     MOVE 0 TO WS-FOUND WS-LOCAL
     PERFORM VARYING WS-ENTRY FROM 1 BY 1 UNTIL WS-ENTRY > PI-COUNT OR WS-FOUND = 1
         IF PI-USED(WS-ENTRY) = 1 AND PI-UUID(WS-ENTRY) = WS-UUID
             MOVE 1 TO WS-FOUND
             IF SP-ACTIVE = 1 AND PI-NAME-LENGTH(WS-ENTRY) = CL-NAME-LENGTH
                     AND PI-NAME(WS-ENTRY) = CL-NAME
                 MOVE 1 TO WS-LOCAL
             END-IF
         END-IF
     END-PERFORM
     IF WS-FOUND = 0 OR HX-ENFORCES = 1
         CALL "CHAT-ERROR-LINE" USING CLIENT-STATE WS-TYPE-INDEX WS-SENDER WS-SENDER-LENGTH WS-TARGET WS-TARGET-LENGTH
         GOBACK
     END-IF
*>   3. The line of the unsigned content when there is one, else of the signed content (a signature is dropped by the accept-unsigned validator).
     MOVE 0 TO WS-DROP
     CALL "CHAT-OPT-FLAG" USING CLIENT-STATE WS-OPTION WS-OPTION-DEFAULT WS-ONLY-SECURE
     MOVE 1 TO WS-TAG
     IF WS-LOCAL = 1
         MOVE 0 TO WS-TAG
     END-IF
     IF WS-ONLY-SECURE = 1 AND WS-TAG NOT = 0
         MOVE 1 TO WS-DROP
     END-IF
     IF WS-MASK-KIND = 1
         MOVE 1 TO WS-DROP
     END-IF
     IF WS-DROP = 1
         GOBACK
     END-IF
     MOVE SPACES TO WS-BODY
     MOVE WS-CONTENT(1:256) TO WS-BODY
     MOVE FUNCTION MIN(WS-CONTENT-LENGTH, 256) TO WS-BODY-LENGTH
     IF WS-HAS-UNSIGNED = 1
         MOVE WS-UNSIGNED(1:256) TO WS-BODY
         MOVE FUNCTION MIN(WS-UNSIGNED-LENGTH, 256) TO WS-BODY-LENGTH
     END-IF
     CALL "CHAT-DECORATE" USING CLIENT-STATE WS-TYPE-INDEX WS-SENDER WS-SENDER-LENGTH WS-TARGET WS-TARGET-LENGTH
         WS-BODY WS-BODY-LENGTH WS-TEXT WS-LENGTH
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SOURCE
     GOBACK.
 END PROGRAM CHAT-PLAYER-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-DISGUISED-READ.
*> USING CLIENT-STATE, PB-BUFFER: Disguised Chat (05a 0x21): the message component and the ChatTypeBound; always unsigned. A line of the decoration of the chat type with the
*> system tag (4), a player line (so "Commands Only" hides it, 2.5); no trust level, block test or filter.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TX-==.
 01 WS-BODY-IN             PIC X(512).
 01 WS-BODY-IN-LENGTH      BINARY-LONG.
 01 WS-BODY                PIC X(256).
 01 WS-TYPE-INDEX          BINARY-LONG.
 01 WS-SENDER              PIC X(256).
 01 WS-SENDER-LENGTH       BINARY-LONG.
 01 WS-TARGET              PIC X(256).
 01 WS-TARGET-LENGTH       BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TAG                 BINARY-LONG VALUE 4.
 01 WS-SOURCE              BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-TEXT" USING PB-BUFFER TX-TEXT
     CALL "TEXT-RENDER" USING CLIENT-STATE TX-TEXT WS-BODY-IN WS-BODY-IN-LENGTH
     CALL "CHAT-BOUND-READ" USING CLIENT-STATE PB-BUFFER WS-TYPE-INDEX WS-SENDER WS-SENDER-LENGTH WS-TARGET WS-TARGET-LENGTH
     IF PB-ERROR = 1
         GOBACK
     END-IF
     MOVE WS-BODY-IN(1:256) TO WS-BODY
     CALL "CHAT-DECORATE" USING CLIENT-STATE WS-TYPE-INDEX WS-SENDER WS-SENDER-LENGTH WS-TARGET WS-TARGET-LENGTH
         WS-BODY WS-BODY-IN-LENGTH WS-TEXT WS-LENGTH
     CALL "CHAT-LINE-ADD" USING CLIENT-STATE WS-TEXT WS-LENGTH WS-TAG WS-SOURCE
     GOBACK.
 END PROGRAM CHAT-DISGUISED-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHAT-DELETE-READ.
*> USING CLIENT-STATE, PB-BUFFER: Delete Chat (05a 0x1F): a packed signature (a VarInt, 0 followed by 256 bytes). The client finds the newest stored line with that signature;
*> it stores only unsigned lines (57-5 section 2.6), so nothing is found and nothing changes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SIGNATURE           PIC X(256).
 01 WS-LENGTH              BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     IF WS-VALUE = 0
         CALL "PB-GET-BYTES" USING PB-BUFFER WS-SIGNATURE WS-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CHAT-DELETE-READ.
