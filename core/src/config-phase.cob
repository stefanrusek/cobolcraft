*> Configuration phase (docs/protocol/03 "Configuration sequence"; 09 §3.1 configuration table, §4).
*> The order follows 03, without Server Links, Code of Conduct or Reset Chat (09 §3.1):
*>   1. On entering configuration (CONFIG-START, called by login on Login Acknowledged) the server
*>      sends, as 03's startConfiguration does: Custom Payload minecraft:brand, Update Enabled
*>      Features, then Select Known Packs, which opens the synchronize_registries task.
*>   2. The client's Select Known Packs completes that task: one Registry Data per registry with
*>      entries (18, standin §4.2), then Update Tags. No code of conduct follows. When the
*>      settings offer a pack (CS-PACK-OFFERED, FR-009), the server_resource_pack task sends
*>      Resource Pack Push (CONFIG-PACK-PUSH-BUILD) and waits for the client's Resource Pack
*>      Response for that pack id with a terminal action (03; 08 §9.2, §9.7: 0, 1, 2, 5, 6, 7; 3
*>      accepted and 4 downloaded only report progress). Declining (1) a required pack sends the
*>      configuration Disconnect cobolcraft.disconnect.pack_required (08 §9.8, standin §17);
*>      every other terminal action completes the task. Spawn preparation has nothing on the
*>      wire, so the join_world task then sends Finish Configuration (at once when no pack is
*>      offered).
*>   3. The client's Finish Configuration moves the connection to play (PLAY-JOIN).
*> The client's brand and Client Information may arrive at any time; Client Information stores the
*> view distance in the player's row. Keep Alive answers go to CORE-KEEPALIVE-ANSWER. A Resource
*> Pack Response while no pack task waits, or for another pack id, is decoded and otherwise
*> ignored: a well-behaved client is not disconnected for it. A Cookie Response
*> is unsolicited (CobolCraft never asks for cookies): Disconnect
*> multiplayer.disconnect.unexpected_query_response (09 §4, 02). A Select Known Packs outside the
*> negotiation (03: an error), a Finish Configuration before the server's, a malformed packet or
*> any other packet id closes the connection (01 §5, CORE-BAD-PACKET).
*>
*> Entry points:
*>   CONFIG-START USING connection id
*>   CONFIG-PACKET USING connection id, packet id, PB-BUFFER (PB-POS after the id)
*>   CONFIG-DECODE USING packet id, PB-BUFFER (PB-POS after the id), CONFIG-SERVERBOUND
*>     (core/copy/CONFIGPKT.cpy), outcome out (0 decoded, 1 malformed or bytes left over, 2 not a
*>     packet the phase decodes)
*>   CONFIG-BRAND-BUILD, CONFIG-FEATURES-BUILD, CONFIG-KNOWN-PACKS-BUILD, CONFIG-TAGS-BUILD,
*>   CONFIG-FINISH-BUILD USING PB-BUFFER (appended to): the clientbound packets (id + body)
*>   CONFIG-PACK-PUSH-BUILD USING CORE-SETTINGS, PB-BUFFER (appended to): Resource Pack Push 0x09
*>   CONFIG-PACK-UUID USING UUID text (PIC X(36), hyphenated hex), UUID out (PIC X(16))
*>
*> The step of each connection within the sequence is kept in CONFIG-STEPS (EXTERNAL, this module's
*> own): 1 = waiting for the client's Select Known Packs, 2 = Finish Configuration sent, 3 =
*> Resource Pack Push sent, waiting for a terminal Resource Pack Response.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-START.
*> USING connection id: the connection has just entered configuration; sends brand, Update Enabled
*> Features and Select Known Packs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE 1 TO CF-STEP(L-ID)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CONFIG-BRAND-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-FEATURES-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "CONFIG-KNOWN-PACKS-BUILD" USING PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CONFIG-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-PACKET.
*> USING connection id, packet id, PB-BUFFER: one serverbound configuration packet (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONFIGPKT.
 COPY MESSAGES.
 COPY GENQUEUE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-MSG                 BINARY-LONG.
 01 WS-PACK-UUID           PIC X(16).
 LINKAGE SECTION.
 COPY PROTO.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF L-PACKET-ID = 1
         INITIALIZE PK-TEXT
         MOVE PK-TEXT-TRANSLATE TO PK-TX-KIND
         MOVE "multiplayer.disconnect.unexpected_query_response" TO PK-TX-VALUE
         MOVE 48 TO PK-TX-LENGTH
         CALL "CORE-SEND-DISCONNECT" USING L-ID PK-TEXT
         GOBACK
     END-IF
     CALL "CONFIG-DECODE" USING L-PACKET-ID PB-BUFFER CONFIG-SERVERBOUND WS-OUTCOME
     EVALUATE TRUE
         WHEN WS-OUTCOME NOT = 0
             CALL "CORE-BAD-PACKET" USING L-ID
         WHEN L-PACKET-ID = 0
             IF CN-PLAYER(L-ID) > 0
                 MOVE CSB-VIEW-DISTANCE TO PL-VIEW-DISTANCE(CN-PLAYER(L-ID))
             END-IF
         WHEN L-PACKET-ID = 4
             CALL "CORE-KEEPALIVE-ANSWER" USING L-ID CSB-KEEPALIVE
         WHEN L-PACKET-ID = 7
             IF CF-STEP(L-ID) NOT = 1
                 CALL "CORE-BAD-PACKET" USING L-ID
             ELSE
                 MOVE 2 TO CF-STEP(L-ID)
                 CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
                 PERFORM VARYING WS-NUMBER FROM 0 BY 1 UNTIL WS-NUMBER >= 32
                     CALL "PB-RESET" USING PK-BUFFER
                     CALL "REGISTRY-PACKET-BUILD" USING WS-NUMBER PK-BUFFER
                     IF PK-LENGTH > 0
                         CALL "CORE-SEND" USING L-ID PK-BUFFER
                     END-IF
                 END-PERFORM
                 CALL "PB-RESET" USING PK-BUFFER
                 CALL "CONFIG-TAGS-BUILD" USING PK-BUFFER
                 CALL "CORE-SEND" USING L-ID PK-BUFFER
                 CALL "PB-RESET" USING PK-BUFFER
                 IF CS-PACK-OFFERED = 1
                     MOVE 3 TO CF-STEP(L-ID)
                     CALL "CONFIG-PACK-PUSH-BUILD" USING CORE-SETTINGS PK-BUFFER
                 ELSE
                     CALL "CONFIG-FINISH-BUILD" USING PK-BUFFER
                 END-IF
                 CALL "CORE-SEND" USING L-ID PK-BUFFER
                 CALL "PB-FREE" USING PK-BUFFER
             END-IF
         WHEN L-PACKET-ID = 6
             CALL "CONFIG-PACK-UUID" USING CS-PACK-ID WS-PACK-UUID
             EVALUATE TRUE
                 WHEN CF-STEP(L-ID) NOT = 3 OR CSB-PACK-ID NOT = WS-PACK-UUID
                         OR CSB-PACK-ACTION = 3 OR CSB-PACK-ACTION = 4
                     CONTINUE
                 WHEN CSB-PACK-ACTION = 1 AND CS-PACK-REQUIRED = 1
                     MOVE 0 TO CF-STEP(L-ID)
                     MOVE MK-DC-PACK-REQUIRED TO WS-MSG
                     CALL "CMD-TEXT-KEY" USING PK-TEXT WS-MSG
                     CALL "CORE-SEND-DISCONNECT" USING L-ID PK-TEXT
                 WHEN OTHER
                     MOVE 2 TO CF-STEP(L-ID)
                     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
                     CALL "CONFIG-FINISH-BUILD" USING PK-BUFFER
                     CALL "CORE-SEND" USING L-ID PK-BUFFER
                     CALL "PB-FREE" USING PK-BUFFER
             END-EVALUATE
         WHEN L-PACKET-ID = 3
             EVALUATE TRUE
                 WHEN CF-STEP(L-ID) NOT = 2
                     CALL "CORE-BAD-PACKET" USING L-ID
                 WHEN GQ-SP-STATE > 0
*>                   the world's spawn is still being searched: the join waits (CONFIG-RELEASE-HELD)
                     MOVE 4 TO CF-STEP(L-ID)
                 WHEN OTHER
                     CALL "CONFIG-JOIN" USING L-ID
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM CONFIG-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-DECODE.
*> USING packet id, PB-BUFFER (PB-POS after the id), CONFIG-SERVERBOUND out, outcome out: decodes a
*> serverbound configuration packet of 09 §3.1 (03 field tables). Client Information 0x00, Custom
*> Payload 0x02 (minecraft:brand: String(32767); another channel: opaque bytes to the end, at most
*> 32767), Finish Configuration 0x03 (no fields), Keep Alive 0x04 (Long), Resource Pack Response 0x06
*> (UUID, action ordinal 0 to 7), Select Known Packs 0x07 (at most 64 KnownPacks of three
*> String(32767)). Outcome 1 when a read fails, a value is out of range or bytes are left over.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAX-LANGUAGE        BINARY-LONG VALUE 16.
 01 WS-LANGUAGE-CAPACITY   BINARY-LONG VALUE 48.
 01 WS-MAX-STRING          BINARY-LONG VALUE 32767.
 01 WS-STRING-CAPACITY     BINARY-LONG VALUE 98301.
 01 WS-STRING              PIC X(98301).
 01 WS-STRING-LENGTH       BINARY-LONG.
 01 WS-CHANNEL-CAPACITY    BINARY-LONG VALUE 32767.
 01 WS-CHANNEL             PIC X(32767).
 01 WS-REST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 COPY CONFIGPKT.
 01 L-PACKET-ID            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-PACKET-ID PB-BUFFER CONFIG-SERVERBOUND L-OUTCOME.
     INITIALIZE CONFIG-SERVERBOUND
     MOVE 0 TO L-OUTCOME
     EVALUATE L-PACKET-ID
         WHEN 0
             CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-LANGUAGE CSB-LANGUAGE
                 WS-LANGUAGE-CAPACITY CSB-LANGUAGE-LENGTH
             CALL "PB-GET-BYTE" USING PB-BUFFER CSB-VIEW-DISTANCE
             CALL "PB-GET-VARINT" USING PB-BUFFER CSB-CHAT-VISIBILITY
             CALL "PB-GET-BOOL" USING PB-BUFFER CSB-CHAT-COLORS
             CALL "PB-GET-UBYTE" USING PB-BUFFER CSB-MODEL-PARTS
             CALL "PB-GET-VARINT" USING PB-BUFFER CSB-MAIN-HAND
             CALL "PB-GET-BOOL" USING PB-BUFFER CSB-TEXT-FILTERING
             CALL "PB-GET-BOOL" USING PB-BUFFER CSB-ALLOWS-LISTING
             CALL "PB-GET-VARINT" USING PB-BUFFER CSB-PARTICLES
         WHEN 2
             CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-CHANNEL WS-CHANNEL-CAPACITY
                 CSB-CHANNEL-LENGTH
             MOVE WS-CHANNEL TO CSB-CHANNEL
             IF CSB-CHANNEL-LENGTH = 15 AND WS-CHANNEL(1:15) = "minecraft:brand"
                 CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-STRING WS-STRING
                     WS-STRING-CAPACITY CSB-BRAND-LENGTH
                 MOVE WS-STRING TO CSB-BRAND
             ELSE
                 COMPUTE WS-REST = PB-LENGTH - PB-POS
                 IF WS-REST > 32767
                     MOVE 1 TO PB-ERROR
                 ELSE
                     MOVE PB-LENGTH TO PB-POS
                 END-IF
             END-IF
         WHEN 3
             CONTINUE
         WHEN 4
             CALL "PB-GET-LONG" USING PB-BUFFER CSB-KEEPALIVE
         WHEN 6
             CALL "PB-GET-UUID" USING PB-BUFFER CSB-PACK-ID
             CALL "PB-GET-VARINT" USING PB-BUFFER CSB-PACK-ACTION
             IF CSB-PACK-ACTION < 0 OR CSB-PACK-ACTION > 7
                 MOVE 1 TO PB-ERROR
             END-IF
         WHEN 7
             CALL "PB-GET-VARINT" USING PB-BUFFER CSB-KNOWN-PACKS
             IF CSB-KNOWN-PACKS < 0 OR CSB-KNOWN-PACKS > 64
                 MOVE 1 TO PB-ERROR
             ELSE
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CSB-KNOWN-PACKS
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
                         CALL "PB-GET-STRING" USING PB-BUFFER WS-MAX-STRING WS-STRING
                             WS-STRING-CAPACITY WS-STRING-LENGTH
                     END-PERFORM
                 END-PERFORM
             END-IF
         WHEN OTHER
             MOVE 2 TO L-OUTCOME
     END-EVALUATE
     IF L-OUTCOME = 0 AND (PB-ERROR = 1 OR PB-POS NOT = PB-LENGTH)
         MOVE 1 TO L-OUTCOME
     END-IF
     GOBACK.
 END PROGRAM CONFIG-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-BRAND-BUILD.
*> USING PB-BUFFER: Custom Payload 0x01, channel minecraft:brand, brand "cobolcraft" (09 §3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 1.
 01 WS-CHANNEL             PIC X(15) VALUE "minecraft:brand".
 01 WS-CHANNEL-LENGTH      BINARY-LONG VALUE 15.
 01 WS-BRAND               PIC X(10) VALUE "cobolcraft".
 01 WS-BRAND-LENGTH        BINARY-LONG VALUE 10.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-CHANNEL WS-CHANNEL-LENGTH
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-BRAND WS-BRAND-LENGTH WS-MAX
     GOBACK.
 END PROGRAM CONFIG-BRAND-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-FEATURES-BUILD.
*> USING PB-BUFFER: Update Enabled Features 0x0D with the one flag minecraft:vanilla (standin §4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 13.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-FEATURE             PIC X(17) VALUE "minecraft:vanilla".
 01 WS-FEATURE-LENGTH      BINARY-LONG VALUE 17.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-FEATURE WS-FEATURE-LENGTH
     GOBACK.
 END PROGRAM CONFIG-FEATURES-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-KNOWN-PACKS-BUILD.
*> USING PB-BUFFER: Select Known Packs 0x0F with an empty list (standin §4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 15.
 01 WS-COUNT               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     GOBACK.
 END PROGRAM CONFIG-KNOWN-PACKS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-TAGS-BUILD.
*> USING PB-BUFFER: Update Tags 0x0E with zero registries (standin §6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 14.
 01 WS-COUNT               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     GOBACK.
 END PROGRAM CONFIG-TAGS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-FINISH-BUILD.
*> USING PB-BUFFER: Finish Configuration 0x03 (no fields).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     GOBACK.
 END PROGRAM CONFIG-FINISH-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-PACK-PUSH-BUILD.
*> USING CORE-SETTINGS, PB-BUFFER: Resource Pack Push 0x09 (03; 09 §3.1 rows 0x09; 08 §9.7): pack
*> id CS-PACK-ID, URL CS-PACK-URL and hash CS-PACK-SHA1 (each without trailing spaces; an empty
*> hash is sent empty), Required CS-PACK-REQUIRED, Prompt present only when CS-PACK-PROMPT is not
*> empty, as a plain string text (network NBT String tag, 09 §1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 9.
 01 WS-UUID                PIC X(16).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-URL-MAX             BINARY-LONG VALUE 32767.
 01 WS-HASH-MAX            BINARY-LONG VALUE 40.
 01 WS-FLAG                BINARY-LONG.
 01 WS-SPACES              BINARY-LONG.
 01 WS-URL-REVERSED        PIC X(1024).
 01 WS-HASH-REVERSED       PIC X(40).
 01 WS-PROMPT-REVERSED     PIC X(256).
 LINKAGE SECTION.
 COPY COREAPI.
 COPY PROTO.
 PROCEDURE DIVISION USING CORE-SETTINGS PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "CONFIG-PACK-UUID" USING CS-PACK-ID WS-UUID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     MOVE FUNCTION REVERSE(CS-PACK-URL) TO WS-URL-REVERSED
     MOVE 0 TO WS-SPACES
     INSPECT WS-URL-REVERSED TALLYING WS-SPACES FOR LEADING SPACES
     COMPUTE WS-LENGTH = 1024 - WS-SPACES
     CALL "PB-PUT-STRING" USING PB-BUFFER CS-PACK-URL WS-LENGTH WS-URL-MAX
     MOVE FUNCTION REVERSE(CS-PACK-SHA1) TO WS-HASH-REVERSED
     MOVE 0 TO WS-SPACES
     INSPECT WS-HASH-REVERSED TALLYING WS-SPACES FOR LEADING SPACES
     COMPUTE WS-LENGTH = 40 - WS-SPACES
     CALL "PB-PUT-STRING" USING PB-BUFFER CS-PACK-SHA1 WS-LENGTH WS-HASH-MAX
     MOVE CS-PACK-REQUIRED TO WS-FLAG
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
     MOVE FUNCTION REVERSE(CS-PACK-PROMPT) TO WS-PROMPT-REVERSED
     MOVE 0 TO WS-SPACES
     INSPECT WS-PROMPT-REVERSED TALLYING WS-SPACES FOR LEADING SPACES
     COMPUTE WS-LENGTH = 256 - WS-SPACES
     MOVE 0 TO WS-FLAG
     IF WS-LENGTH > 0
         MOVE 1 TO WS-FLAG
     END-IF
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
     IF WS-FLAG = 1
         INITIALIZE PK-TEXT
         MOVE PK-TEXT-PLAIN TO PK-TX-KIND
         MOVE CS-PACK-PROMPT TO PK-TX-VALUE
         MOVE WS-LENGTH TO PK-TX-LENGTH
         CALL "PB-PUT-TEXT" USING PB-BUFFER PK-TEXT
     END-IF
     GOBACK.
 END PROGRAM CONFIG-PACK-PUSH-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-PACK-UUID.
*> USING UUID text (PIC X(36): 32 hex digits, either case, hyphens skipped; the server's settings
*> parser checks the form), UUID out (PIC X(16)):
*> the 16 bytes, most significant first (00 §5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(36).
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(36).
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING L-TEXT L-UUID.
     MOVE FUNCTION LOWER-CASE(L-TEXT) TO WS-TEXT
     MOVE LOW-VALUES TO L-UUID
     MOVE 1 TO WS-OUT
     MOVE 0 TO WS-VALUE WS-HALF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36 OR WS-OUT > 16
         IF WS-TEXT(WS-I:1) NOT = "-"
             IF WS-TEXT(WS-I:1) >= "a"
                 COMPUTE WS-D = FUNCTION ORD(WS-TEXT(WS-I:1)) - FUNCTION ORD("a") + 10
             ELSE
                 COMPUTE WS-D = FUNCTION ORD(WS-TEXT(WS-I:1)) - FUNCTION ORD("0")
             END-IF
             COMPUTE WS-VALUE = WS-VALUE * 16 + WS-D
             ADD 1 TO WS-HALF
             IF WS-HALF = 2
                 MOVE FUNCTION CHAR(WS-VALUE + 1) TO L-UUID(WS-OUT:1)
                 ADD 1 TO WS-OUT
                 MOVE 0 TO WS-VALUE WS-HALF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONFIG-PACK-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-JOIN.
*> USING connection id: the client's Finish Configuration is in: the connection moves to play and joins (PLAY-JOIN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-PHASE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     MOVE 0 TO CF-STEP(L-ID)
     MOVE PH-PLAY TO WS-PHASE
     CALL "CORE-SET-PHASE" USING L-ID WS-PHASE
     CALL "PLAY-JOIN" USING L-ID
     GOBACK.
 END PROGRAM CONFIG-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONFIG-RELEASE-HELD.
*> No parameters: every connection whose Finish Configuration was held while the spawn was searched (step 4) joins now (GEN-SPAWN-TICK), its player placed at
*> the spawn the search found (the world is new while the search runs, so a joining player has no position of its own).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-CLOSE(WS-ID) = 0 AND CN-PHASE(WS-ID) = PH-CONFIG AND CF-STEP(WS-ID) = 4
             MOVE CN-PLAYER(WS-ID) TO WS-ROW
             MOVE CW-SPAWN-X TO PL-X(WS-ROW)
             MOVE CW-SPAWN-Y TO PL-Y(WS-ROW) PL-FALL-START(WS-ROW)
             MOVE CW-SPAWN-Z TO PL-Z(WS-ROW)
             MOVE CW-SPAWN-YAW TO PL-YAW(WS-ROW)
             CALL "CONFIG-JOIN" USING WS-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CONFIG-RELEASE-HELD.
