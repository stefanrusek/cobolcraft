*> Entity metadata of the species flags of 002-lane-p49n (docs/protocol/20: spider 7.1, pillager 13.2, enderman 8.1, sulfur cube 18.2), one Set Entity Data packet per mob.
*> State: P49NSTATE.cpy. A species with no entry here gets no packet from these programs (STDMOB-VARIANT-BUILD holds the older ones).
*>
*>   STDMOB-FLAGS-BUILD USING tracker row, PB-BUFFER (empty): Set Entity Data (0x65) of the flags of the row: spider and cave spider index 16 BYTE (bit 0 climbing); nothing for another row.
*>   STDMOB-FLAGS-SEND USING tracker row: STDMOB-FLAGS-BUILD to the viewers of the row.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FLAGS-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY P49NSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-M                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTRIES.
    05 WS-ENTRY            OCCURS 4 TIMES.
       10 WS-INDEX         BINARY-LONG.
       10 WS-SERIALIZER    BINARY-LONG.
       10 WS-VALUE         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE 0 TO WS-N
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND PN-ID(L-ROW) = EN-ID(L-ROW)
         EVALUATE SM-KEY(WS-M)
             WHEN "spider"
             WHEN "cave_spider"
*>               The spider flags byte (20 section 7.1): index 16, bit 0 climbing.
                 ADD 1 TO WS-N
                 MOVE 16 TO WS-INDEX(WS-N)
                 MOVE MD-MDS-BYTE TO WS-SERIALIZER(WS-N)
                 MOVE PN-CLIMB(L-ROW) TO WS-VALUE(WS-N)
         END-EVALUATE
     END-IF
     IF WS-N > 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
         CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             INITIALIZE MD-METADATA-ENTRY
             MOVE WS-INDEX(WS-I) TO MD-MD-INDEX
             MOVE WS-SERIALIZER(WS-I) TO MD-MD-SERIALIZER
             MOVE WS-VALUE(WS-I) TO MD-MD-INT
             CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
         END-PERFORM
         MOVE MD-MD-END TO MD-MD-INDEX
         CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     END-IF
     GOBACK.
 END PROGRAM STDMOB-FLAGS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FLAGS-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-FLAGS-BUILD" USING L-ROW PB-BUFFER
     IF PB-LENGTH > 0
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     END-IF
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM STDMOB-FLAGS-SEND.
