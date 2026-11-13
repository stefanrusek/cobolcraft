*> Registry Data packets (docs/protocol/03 0x07, 04 section 3; 09 section 3.1 rule 9): one packet per registry of
*> core/copy/SYNCREG.cpy that the open content set gives entries (core 2: 20 packets and 82 entries for the
*> cobolcraft set); an empty registry gets no packet. Every entry is sent with Data present (Select Known Packs is
*> empty) as the network NBT the content set holds for it (CONTENT-REGISTRY-ENTRY).
*>
*> Entry point:
*>   REGISTRY-PACKET-BUILD USING registry number (BINARY-LONG, 0 to 31, the order of SYNCREG.cpy), PB-BUFFER (appended
*>     to): the Registry Data packet (id + body), or nothing for an empty or unknown registry.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-PACKET-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY SYNCREG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 7.
 01 WS-REGISTRY            PIC X(112).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BIOME               PIC X(24) VALUE "minecraft:worldgen/biome".
 01 WS-NBT-LENGTH          BINARY-LONG.
 01 WS-NBT-STATUS          BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NUMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER PB-BUFFER.
     IF L-NUMBER < 0 OR L-NUMBER >= REG-COUNT
         GOBACK
     END-IF
     MOVE SPACES TO WS-REGISTRY
     MOVE REG-NAME(L-NUMBER + 1) TO WS-REGISTRY
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-REGISTRY)) TO WS-NAME-LENGTH
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     IF WS-STATUS NOT = CT-OK OR WS-COUNT = 0
         GOBACK
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-REGISTRY WS-NAME-LENGTH
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-ENTRY FROM 0 BY 1 UNTIL WS-ENTRY >= WS-COUNT
         CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ENTRY WS-KEY WS-KEY-LENGTH WS-PAYLOAD
             WS-CAPACITY WS-LENGTH WS-STATUS
         CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-KEY WS-KEY-LENGTH
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
*>       The entry of a standard set is the JSON of the vanilla-data pack: a biome goes out as the network NBT of the
*>       biome codec (registry-biome.cob), as the client reads it.
         IF WS-REGISTRY = WS-BIOME AND WS-LENGTH > 0 AND WS-PAYLOAD(1:1) = "{"
             CALL "BIOME-NBT" USING WS-PAYLOAD WS-LENGTH PB-BUFFER WS-NBT-STATUS
         ELSE
             CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-PAYLOAD WS-LENGTH
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REGISTRY-PACKET-BUILD.
