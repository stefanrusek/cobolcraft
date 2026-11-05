*> Configuration phase (docs/protocol/03 "Configuration sequence"; 09 §3.1 configuration table, §4).
*> The order follows 03, without Server Links, Code of Conduct or Reset Chat (09 §3.1):
*>   1. On entering configuration (CONFIG-START, called by login on Login Acknowledged) the server
*>      sends, as 03's startConfiguration does: Custom Payload minecraft:brand, Update Enabled
*>      Features, then Select Known Packs, which opens the synchronize_registries task.
*>   2. The client's Select Known Packs completes that task: one Registry Data per registry with
*>      entries (18, standin §4.2), then Update Tags. No code of conduct and (in US2) no resource
*>      pack task follow, and spawn preparation has nothing on the wire, so the join_world task
*>      sends Finish Configuration at once.
*>   3. The client's Finish Configuration moves the connection to play (PLAY-JOIN).
*> The client's brand and Client Information may arrive at any time; Client Information stores the
*> view distance in the player's row. Keep Alive answers go to CORE-KEEPALIVE-ANSWER. A Resource
*> Pack Response (US18 owns the pack task) is decoded and otherwise ignored: no pack was offered,
*> so it changes nothing, and a well-behaved client is not disconnected for it. A Cookie Response
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
*>
*> The step of each connection within the sequence is kept in CONFIG-STEPS (EXTERNAL, this module's
*> own): 1 = waiting for the client's Select Known Packs, 2 = Finish Configuration sent.

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
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 CONFIG-STEPS EXTERNAL.
    05 CF-STEP               PIC 9 OCCURS 64 TIMES.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NUMBER              BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PB-BUFFER.
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
                 CALL "CONFIG-FINISH-BUILD" USING PK-BUFFER
                 CALL "CORE-SEND" USING L-ID PK-BUFFER
                 CALL "PB-FREE" USING PK-BUFFER
             END-IF
         WHEN L-PACKET-ID = 3
             IF CF-STEP(L-ID) NOT = 2
                 CALL "CORE-BAD-PACKET" USING L-ID
             ELSE
                 MOVE 0 TO CF-STEP(L-ID)
                 MOVE PH-PLAY TO WS-PHASE
                 CALL "CORE-SET-PHASE" USING L-ID WS-PHASE
                 CALL "PLAY-JOIN" USING L-ID
             END-IF
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
