*> The client side of the protocol, handshake, status, login and configuration (docs/protocol/02, 03, 04):
*> the builders CLP-SIMPLE, CLP-INTENTION, CLP-PING-REQUEST, CLP-HELLO (with the offline UUID) and
*> CLP-CONFIG-START, STATUS-READ (the Status Response into the server-list entry) and REGISTRY-READ (Registry
*> Data: dimension types and the biome registry). Split from protocol-client.cob (T2944); PROTO-PACKET there
*> dispatches to these programs.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-SIMPLE.
*> USING PB-BUFFER, packet id: a packet without fields (Status Request 0x00, Login Acknowledged and
*> Finish Configuration 0x03, Client Tick End 0x0D, Player Loaded 0x2C).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-ID.
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     GOBACK.
 END PROGRAM CLP-SIMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-INTENTION.
*> USING PB-BUFFER, host (PIC X(256)), host length, port, intent (1 status, 2 login): Intention.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PROTOCOL            BINARY-LONG VALUE CL-PROTOCOL.
 01 WS-MAX                 BINARY-LONG VALUE 255.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-HOST                 PIC X(256).
 01 L-HOST-LENGTH          BINARY-LONG.
 01 L-PORT                 BINARY-LONG.
 01 L-INTENT               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-HOST L-HOST-LENGTH L-PORT L-INTENT.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PROTOCOL
     CALL "PB-PUT-STRING" USING PB-BUFFER L-HOST L-HOST-LENGTH WS-MAX
     CALL "PB-PUT-USHORT" USING PB-BUFFER L-PORT
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-INTENT
     GOBACK.
 END PROGRAM CLP-INTENTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-PING-REQUEST.
*> USING PB-BUFFER, time (BINARY-DOUBLE): Ping Request.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING PB-BUFFER L-TIME.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER L-TIME
     GOBACK.
 END PROGRAM CLP-PING-REQUEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-HELLO.
*> USING PB-BUFFER, name (PIC X(16)), name length: Hello with the offline UUID of the name
*> (CLP-OFFLINE-UUID).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-NAME L-LENGTH.
     CALL "CLP-OFFLINE-UUID" USING L-NAME L-LENGTH WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER L-NAME L-LENGTH WS-MAX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     GOBACK.
 END PROGRAM CLP-HELLO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-OFFLINE-UUID.
*> USING name (PIC X(16)), name length, UUID out (PIC X(16)): the offline UUID of the name (MD5 of
*> "OfflinePlayer:<name>", version 3, IETF variant; 02 Offline mode).
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
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 01 L-UUID                 PIC X(16).
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-UUID.
     MOVE "OfflinePlayer:" TO WS-DATA
     MOVE L-NAME(1:L-LENGTH) TO WS-DATA(15:L-LENGTH)
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
 END PROGRAM CLP-OFFLINE-UUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CLP-CONFIG-START.
*> USING CLIENT-STATE, connection: the client's opening of configuration: brand "cobolcraft" and
*> Client Information (en_us, view distance 8, full chat, colours, right hand, listing allowed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ID                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-CHANNEL             PIC X(15) VALUE "minecraft:brand".
 01 WS-CHANNEL-LENGTH      BINARY-LONG VALUE 15.
 01 WS-BRAND               PIC X(10) VALUE "cobolcraft".
 01 WS-BRAND-LENGTH        BINARY-LONG VALUE 10.
 01 WS-LANGUAGE            PIC X(5) VALUE "en_us".
 01 WS-LANGUAGE-LENGTH     BINARY-LONG VALUE 5.
 01 WS-MAX                 BINARY-LONG VALUE 32767.
 01 WS-MAX16               BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 2 TO WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-IDENTIFIER" USING PB-BUFFER WS-CHANNEL WS-CHANNEL-LENGTH
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-BRAND WS-BRAND-LENGTH WS-MAX
     CALL "NET-SEND" USING CLIENT-STATE L-CONN PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-LANGUAGE WS-LANGUAGE-LENGTH WS-MAX16
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-EIGHT
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "NET-SEND" USING CLIENT-STATE L-CONN PB-BUFFER
     GOBACK.
 END PROGRAM CLP-CONFIG-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STATUS-READ.
*> USING CLIENT-STATE, JSON-DOC (the status JSON, 09 §2), server-list entry: description (a text
*> component), players online and maximum, version name; a protocol other than 777 marks the entry
*> incompatible (US2 edge case).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-PATH                PIC X(32).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY JSONDOC.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE JSON-DOC L-ENTRY.
     MOVE "version.protocol" TO WS-PATH
     MOVE 16 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     MOVE 1 TO SL-INCOMPATIBLE(L-ENTRY)
     IF WS-NODE > 0
         IF JN-NUM(WS-NODE) = CL-PROTOCOL
             MOVE 0 TO SL-INCOMPATIBLE(L-ENTRY)
         END-IF
     END-IF
     MOVE "version.name" TO WS-PATH
     MOVE 12 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     MOVE SPACES TO SL-VERSION(L-ENTRY)
     CALL "JSON-STRING" USING JSON-DOC WS-NODE SL-VERSION(L-ENTRY) WS-CAP
         SL-VERSION-LENGTH(L-ENTRY)
     MOVE "players.online" TO WS-PATH
     MOVE 14 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     MOVE 0 TO SL-ONLINE(L-ENTRY) SL-MAX(L-ENTRY)
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO SL-ONLINE(L-ENTRY)
     END-IF
     MOVE "players.max" TO WS-PATH
     MOVE 11 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-NUM(WS-NODE) TO SL-MAX(L-ENTRY)
     END-IF
     MOVE "description" TO WS-PATH
     MOVE 11 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     CALL "JSON-TEXT-RENDER" USING CLIENT-STATE JSON-DOC WS-NODE WS-TEXT WS-LENGTH
     MOVE WS-TEXT TO SL-DESC(L-ENTRY)
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO SL-DESC-LENGTH(L-ENTRY)
     GOBACK.
 END PROGRAM STATUS-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-READ.
*> USING CLIENT-STATE, packet (Registry Data, 04): counts the packet; keeps the entries of
*> minecraft:dimension_type (name, min_y, height, has_skylight), the number of
*> minecraft:worldgen/biome entries and each biome's has_precipitation (an entry without data has
*> none) and its colour data for the tint sources (temperature, downfall and the effects' water, grass,
*> foliage and dry foliage colours and grass colour modifier, 43 section 5: TINT-BIOME-SET under the
*> biome's id, its index in the registry; minecraft:plains is the biome of an unloaded cell, TT-PLAINS);
*> every other entry's data is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-REGISTRY            PIC X(64).
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-REGISTRY-LENGTH     BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 0.
 01 WS-D                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WN                     PIC X(64).
 01 WL                     BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 COPY CLTINT.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-TEMP                COMP-2.
 01 WS-DOWN                COMP-2.
 01 WS-WATER               BINARY-DOUBLE.
 01 WS-GRASS               BINARY-DOUBLE.
 01 WS-FOLIAGE             BINARY-DOUBLE.
 01 WS-DRY                 BINARY-DOUBLE.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-MOD                 PIC X(16).
 01 WS-BIOME-ID            BINARY-LONG.
 01 WS-TYPE2               BINARY-LONG.
 01 WS-TYPE3               BINARY-LONG.
 01 WN3                    PIC X(64).
 01 WL3                    BINARY-LONG.
 01 WS-FOG                 BINARY-DOUBLE.
 01 WS-FOG-END             COMP-2.
 01 WN2                    PIC X(64).
 01 WL2                    BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-EDIT                PIC -(10)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     ADD 1 TO RG-REGISTRIES
     MOVE SPACES TO WS-REGISTRY
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-REGISTRY WS-CAP WS-REGISTRY-LENGTH
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     IF WS-REGISTRY = "minecraft:worldgen/biome"
         MOVE WS-COUNT TO RG-BIOMES
     END-IF
     IF WS-REGISTRY = "minecraft:dimension_type"
         MOVE 0 TO RG-DIM-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
         MOVE SPACES TO WS-NAME
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME WS-CAP WS-NAME-LENGTH
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-PRESENT
         MOVE 0 TO WS-D WS-B
         IF WS-REGISTRY = "minecraft:dimension_type" AND RG-DIM-COUNT < CL-MAX-DIM-TYPES
             ADD 1 TO RG-DIM-COUNT
             MOVE RG-DIM-COUNT TO WS-D
             INITIALIZE RG-DIM(WS-D)
             MOVE WS-NAME TO RG-DIM-NAME(WS-D)
*>           An entry sent without data (the vanilla entries of the known pack, a standard world) has the
*>           vanilla range: min_y -64 and height 384 for the overworld types, 0 and 256 for the nether and
*>           the end, sky light on except in the nether. Data in the packet overrides these.
             EVALUATE WS-NAME
                 WHEN "minecraft:overworld" WHEN "minecraft:overworld_caves"
                     MOVE -64 TO RG-DIM-MIN-Y(WS-D)
                     MOVE 384 TO RG-DIM-HEIGHT(WS-D)
                     MOVE 1 TO RG-DIM-HAS-SKY(WS-D)
                 WHEN "minecraft:the_nether"
                     MOVE 0 TO RG-DIM-MIN-Y(WS-D) RG-DIM-HAS-SKY(WS-D)
                     MOVE 256 TO RG-DIM-HEIGHT(WS-D)
                 WHEN "minecraft:the_end"
                     MOVE 0 TO RG-DIM-MIN-Y(WS-D)
                     MOVE 256 TO RG-DIM-HEIGHT(WS-D)
                     MOVE 1 TO RG-DIM-HAS-SKY(WS-D)
             END-EVALUATE
         END-IF
         IF WS-REGISTRY = "minecraft:worldgen/biome" AND WS-I <= CL-MAX-BIOMES
             MOVE WS-I TO WS-B
             MOVE 0 TO RG-BIOME-PRECIP(WS-B)
         END-IF
         IF WS-PRESENT = 1
             CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
             EVALUATE TRUE
                 WHEN WS-B > 0
*>                   A biome: has_precipitation (Byte), temperature and downfall (Float) and the effects
*>                   compound (water_color, grass_color, foliage_color, dry_foliage_color as a "#RRGGBB"
*>                   String or an Int, grass_color_modifier String); the other fields are skipped.
                     MOVE 0.5 TO WS-TEMP WS-DOWN
                     MOVE 4282349284 TO WS-WATER
                     MOVE -1 TO WS-GRASS WS-FOLIAGE WS-DRY
                     MOVE 0 TO WS-FOG WS-FOG-END
                     MOVE "none" TO WS-MOD
                     MOVE 1 TO WS-TYPE
                     PERFORM UNTIL WS-TYPE = 0
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAP WL
                         EVALUATE TRUE
                             WHEN WS-TYPE = 0
                                 CONTINUE
                             WHEN WN = "has_precipitation"
                                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
                                 MOVE WS-VALUE TO RG-BIOME-PRECIP(WS-B)
                             WHEN WN = "temperature"
                                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                                 MOVE WS-FLOAT TO WS-TEMP
                             WHEN WN = "downfall"
                                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                                 MOVE WS-FLOAT TO WS-DOWN
                             WHEN WN = "effects"
                                 MOVE 1 TO WS-TYPE2
                                 PERFORM UNTIL WS-TYPE2 = 0
                                     MOVE SPACES TO WN2
                                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                                     EVALUATE TRUE
                                         WHEN WS-TYPE2 = 0
                                             CONTINUE
                                         WHEN WN2 = "grass_color_modifier" AND WS-TYPE2 = 8
                                             MOVE SPACES TO WS-TEXT
                                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP
                                                 WS-TEXT-LENGTH
                                             MOVE WS-TEXT TO WS-MOD
                                         WHEN (WN2 = "water_color" OR WN2 = "grass_color"
                                                 OR WN2 = "foliage_color" OR WN2 = "dry_foliage_color")
                                                 AND (WS-TYPE2 = 8 OR WS-TYPE2 = 3)
                                             MOVE SPACES TO WS-TEXT
                                             IF WS-TYPE2 = 8
                                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP
                                                     WS-TEXT-LENGTH
                                             ELSE
                                                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                                                 MOVE WS-INT TO WS-EDIT
                                                 MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
                                                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-TEXT-LENGTH
                                             END-IF
                                             CALL "TINT-COLOR-PARSE" USING WS-KIND WS-TEXT WS-TEXT-LENGTH
                                                 WS-COLOUR WS-OK
                                             IF WS-OK = 1
                                                 EVALUATE WN2
                                                     WHEN "water_color"
                                                         MOVE WS-COLOUR TO WS-WATER
                                                     WHEN "grass_color"
                                                         MOVE WS-COLOUR TO WS-GRASS
                                                     WHEN "foliage_color"
                                                         MOVE WS-COLOUR TO WS-FOLIAGE
                                                     WHEN OTHER
                                                         MOVE WS-COLOUR TO WS-DRY
                                                 END-EVALUATE
                                             END-IF
                                         WHEN OTHER
                                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                                     END-EVALUATE
                                 END-PERFORM
                             WHEN WN = "attributes"
*>                               The environment attributes: visual/water_fog_color (a "#RRGGBB" String or an Int) and the multiply
*>                               argument (a Float) of visual/water_fog_end_distance (43 section 5); the others are skipped.
                                 MOVE 1 TO WS-TYPE2
                                 PERFORM UNTIL WS-TYPE2 = 0
                                     MOVE SPACES TO WN2
                                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE2 WN2 WS-CAP WL2
                                     EVALUATE TRUE
                                         WHEN WS-TYPE2 = 0
                                             CONTINUE
                                         WHEN WN2 = "minecraft:visual/water_fog_color" AND (WS-TYPE2 = 8 OR WS-TYPE2 = 3)
                                             MOVE SPACES TO WS-TEXT
                                             IF WS-TYPE2 = 8
                                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-CAP
                                                     WS-TEXT-LENGTH
                                             ELSE
                                                 CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                                                 MOVE WS-INT TO WS-EDIT
                                                 MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
                                                 MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT)) TO WS-TEXT-LENGTH
                                             END-IF
                                             CALL "TINT-COLOR-PARSE" USING WS-KIND WS-TEXT WS-TEXT-LENGTH
                                                 WS-COLOUR WS-OK
                                             IF WS-OK = 1
                                                 MOVE WS-COLOUR TO WS-FOG
                                             END-IF
                                         WHEN WN2 = "minecraft:visual/water_fog_end_distance" AND WS-TYPE2 = 10
                                             MOVE 1 TO WS-TYPE3
                                             PERFORM UNTIL WS-TYPE3 = 0
                                                 MOVE SPACES TO WN3
                                                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE3 WN3 WS-CAP WL3
                                                 IF WS-TYPE3 = 0
                                                     CONTINUE
                                                 ELSE
                                                     IF WN3 = "argument" AND WS-TYPE3 = 5
                                                         CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                                                         MOVE WS-FLOAT TO WS-FOG-END
                                                     ELSE
                                                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE3
                                                     END-IF
                                                 END-IF
                                             END-PERFORM
                                         WHEN OTHER
                                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE2
                                     END-EVALUATE
                                 END-PERFORM
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                         END-EVALUATE
                     END-PERFORM
                     COMPUTE WS-BIOME-ID = WS-B - 1
                     CALL "TINT-BIOME-SET" USING WS-BIOME-ID WS-TEMP WS-DOWN WS-WATER WS-GRASS
                         WS-FOLIAGE WS-DRY WS-MOD
                     CALL "TINT-BIOME-FOG" USING WS-BIOME-ID WS-FOG WS-FOG-END
                     IF WS-NAME = "minecraft:plains"
                         MOVE WS-BIOME-ID TO TT-PLAINS
                     END-IF
                 WHEN WS-D = 0
                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 WHEN OTHER
                     MOVE 1 TO WS-TYPE
                     PERFORM UNTIL WS-TYPE = 0
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAP WL
                         EVALUATE TRUE
                             WHEN WS-TYPE = 0
                                 CONTINUE
                             WHEN WN = "min_y" OR WN = "height"
                                 CALL "PB-GET-INT" USING PB-BUFFER WS-VALUE
                                 IF WN = "min_y"
                                     MOVE WS-VALUE TO RG-DIM-MIN-Y(WS-D)
                                 ELSE
                                     MOVE WS-VALUE TO RG-DIM-HEIGHT(WS-D)
                                 END-IF
                             WHEN WN = "has_skylight"
                                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-VALUE
                                 MOVE WS-VALUE TO RG-DIM-HAS-SKY(WS-D)
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                         END-EVALUATE
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REGISTRY-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT16-ADD.
*> USING CLIENT-STATE, connection, packet (Registry Data id 7 or Update Tags id 14, positioned after the
*> id), packet id: on a network game connection the packet's body goes to CONTENT-CLIENT-REGISTRY-ADD, which
*> builds the connection's content set (WT-16: world-types.md §7.4); the packet is left unread for its own
*> reader. A hosted world's connection (memory) has its set from the core: nothing is added. A set the
*> core holds open is not touched (CL-SET-OWNED says the client's own).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 B-BODY                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CONN                 BINARY-LONG.
 01 L-PACKET.
    05 L-ADDR              USAGE POINTER.
    05 L-CAPACITY          BINARY-LONG.
    05 L-LENGTH            BINARY-LONG.
    05 L-POS               BINARY-LONG.
    05 L-ERROR             PIC 9.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CONN L-PACKET L-ID.
     IF L-CONN = CONN-GAME AND CN-MEMORY(L-CONN) = 0 AND (CL-SET-OWNED = 1 OR CT-OPEN = 0)
         MOVE 1 TO CL-SET-OWNED
         SET ADDRESS OF B-BODY TO L-ADDR
         COMPUTE WS-LENGTH = L-LENGTH - L-POS
         CALL "CONTENT-CLIENT-REGISTRY-ADD" USING L-ID B-BODY(L-POS + 1:1) WS-LENGTH WS-STATUS
     END-IF
     GOBACK.
 END PROGRAM WT16-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT16-FINISH.
*> USING CLIENT-STATE (Finish Configuration of a game connection): when the client built the set, the world
*> type is decided from minecraft:dimension_type (CONTENT-CLIENT-FINISH: cobolcraft when an entry keyed
*> cobolcraft:surface is there, else standard) and kept in CL-WORLD-TYPE; the palette width and the
*> per-state tables are derived again. A set that decides nothing (no dimension type came) is closed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF CL-SET-OWNED = 1
         CALL "CONTENT-CLIENT-FINISH" USING WS-TYPE WS-STATUS
         IF WS-STATUS = CT-OK
             MOVE WS-TYPE TO CL-WORLD-TYPE
             MOVE 0 TO ST-READY WR-BLOCK-BITS
         ELSE
             CALL "CONTENT-CLOSE"
             MOVE 0 TO CL-SET-OWNED CL-WORLD-TYPE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WT16-FINISH.
