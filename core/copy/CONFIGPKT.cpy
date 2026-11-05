*> Decoded serverbound configuration packets (docs/protocol/03; 09 §3.1 configuration table), filled
*> by CONFIG-DECODE (core/src/config-phase.cob). Only the fields of the decoded packet are set; the
*> others are cleared. Text fields hold the first bytes of the value; the length is the full byte
*> length on the wire.
 01 CONFIG-SERVERBOUND.
*>  0x00 Client Information
    05 CSB-LANGUAGE           PIC X(48).          *> String(16): at most 48 UTF-8 bytes
    05 CSB-LANGUAGE-LENGTH    BINARY-LONG.
    05 CSB-VIEW-DISTANCE      BINARY-LONG.        *> Byte (signed)
    05 CSB-CHAT-VISIBILITY    BINARY-LONG.
    05 CSB-CHAT-COLORS        BINARY-LONG.
    05 CSB-MODEL-PARTS        BINARY-LONG.
    05 CSB-MAIN-HAND          BINARY-LONG.
    05 CSB-TEXT-FILTERING     BINARY-LONG.
    05 CSB-ALLOWS-LISTING     BINARY-LONG.
    05 CSB-PARTICLES          BINARY-LONG.
*>  0x02 Custom Payload: the channel; for minecraft:brand also the brand String
    05 CSB-CHANNEL            PIC X(64).
    05 CSB-CHANNEL-LENGTH     BINARY-LONG.
    05 CSB-BRAND              PIC X(64).
    05 CSB-BRAND-LENGTH       BINARY-LONG.
*>  0x04 Keep Alive
    05 CSB-KEEPALIVE          BINARY-DOUBLE.
*>  0x06 Resource Pack Response
    05 CSB-PACK-ID            PIC X(16).
    05 CSB-PACK-ACTION        BINARY-LONG.
*>  0x07 Select Known Packs: number of KnownPack entries (their values are not used)
    05 CSB-KNOWN-PACKS        BINARY-LONG.
