*> The name tag (docs/protocol/17 section 3.7 NameTagItem.interactLivingEntity; 18 section 1.4 entity data entries 2 and 3; lane 002-lane-p46e, T27000).
*> Interact (0x1A) with a name_tag that has a custom_name on a living entity that is not a player: the entity's custom name becomes that text (EN-CNAME), the mob
*> will not despawn (EN-PERSISTENT) and a survival player's stack loses one tag. The viewers get Set Entity Data with entry 2 (OPTIONAL_COMPONENT, the name as a
*> network NBT string) and entry 3 (custom name visible, true); a client that starts tracking the entity later gets the same entries (ENTITY-VIEW-UPDATE).
*> Gaps: the name does not reach the death message of the mob, and the saved form (CustomName) is the open item of entity-mobdata.cob.
*>
*>   NAME-DATA-BUILD USING row, PB-BUFFER      Set Entity Data (0x65) with entries 2 and 3 of the custom name of the row (nothing is written for an unnamed row)
*>   NAME-DATA-SEND USING row                  that packet to every client that has the row
*>   MOB-NAME-TAG-USE USING player row, entity row, used out    1 when the held name tag named the entity

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAME-DATA-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ND-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-SERIALIZER-NAME     BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     IF EN-CNAME-LEN(L-ROW) > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
*>       Entry 2: the name as an OPTIONAL_COMPONENT holding the network NBT string tag (tag byte 8, UShort length, the bytes).
         INITIALIZE ND-METADATA-ENTRY-X
         MOVE 2 TO ND-MX-INDEX
         MOVE WS-SERIALIZER-NAME TO ND-MX-SERIALIZER
         MOVE 1 TO ND-MX-PRESENT
         MOVE FUNCTION CHAR(9) TO ND-MX-DATA(1:1)
         MOVE FUNCTION CHAR(1) TO ND-MX-DATA(2:1)
         MOVE FUNCTION CHAR(EN-CNAME-LEN(L-ROW) + 1) TO ND-MX-DATA(3:1)
         MOVE EN-CNAME(L-ROW)(1:EN-CNAME-LEN(L-ROW)) TO ND-MX-DATA(4:EN-CNAME-LEN(L-ROW))
         COMPUTE ND-MX-DATA-LENGTH = EN-CNAME-LEN(L-ROW) + 3
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER ND-METADATA-ENTRY-X
*>       Entry 3: custom name visible.
         INITIALIZE ND-METADATA-ENTRY
         MOVE 3 TO ND-MD-INDEX
         MOVE ND-MDS-BOOLEAN TO ND-MD-SERIALIZER
         MOVE 1 TO ND-MD-INT
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER ND-METADATA-ENTRY
         MOVE ND-MD-END TO ND-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER ND-METADATA-ENTRY
     END-IF
     GOBACK.
 END PROGRAM NAME-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NAME-DATA-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NAME-DATA-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM NAME-DATA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-NAME-TAG-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAMED               BINARY-LONG.
 01 WS-SERIALIZE           BINARY-LONG VALUE 1.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-APPLIED             BINARY-LONG.
 01 WS-PERSISTENT          BINARY-LONG.
 01 WS-CONSUMED            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-USED.
     MOVE 0 TO L-USED
     COMPUTE WS-SLOT = PL-HELD(L-ROW) + 1
     MOVE SPACES TO WS-NAME
     MOVE 0 TO WS-LENGTH
     CALL "SP-GET-NAME" USING PL-SLOT-VAR(L-ROW, WS-SLOT) WS-NAME WS-LENGTH
     MOVE 0 TO WS-NAMED
     IF WS-LENGTH > 0
         MOVE 1 TO WS-NAMED
     END-IF
     MOVE PL-MODE(L-ROW) TO WS-CREATIVE
     CALL "TOOL-NAMETAG-USE" USING WS-NAMED WS-SERIALIZE WS-CREATIVE WS-APPLIED WS-PERSISTENT WS-CONSUMED
     IF WS-APPLIED = 1
         MOVE SPACES TO EN-CNAME(L-ENTITY)
         MOVE WS-NAME(1:WS-LENGTH) TO EN-CNAME(L-ENTITY)(1:WS-LENGTH)
         MOVE WS-LENGTH TO EN-CNAME-LEN(L-ENTITY)
         IF WS-PERSISTENT = 1
             MOVE 1 TO EN-PERSISTENT(L-ENTITY)
         END-IF
         IF WS-CONSUMED = 1
             CALL "MOB-TAKE" USING L-ROW
         END-IF
         CALL "NAME-DATA-SEND" USING L-ENTITY
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM MOB-NAME-TAG-USE.
