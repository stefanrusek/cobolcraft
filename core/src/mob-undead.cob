*> The undead rules of a standard mob (002-lane-undead, T11000-T11019; docs/protocol/18 sections 2.5 and 3.2, 20 sections 3.5 and 4, 21 section 3.6).
*>   MOB-UNDEAD USING species key (PIC X(24)), entity type id (BINARY-LONG), result out   1 when the type is in the entity type tag minecraft:undead of the
*>     loaded data; without that tag the fixed members of 21 section 3.6 (skeletons, zombies, wither, phantom)
*>   MOB-SINKS USING species key, entity type id, result out   1 for an undead land mob with no float goal (20 section 4: zombie, zombie villager, husk, skeleton,
*>     stray, bogged, parched; 21: wither skeleton, zombified piglin): in water it only sinks (the +0.04 of a jump in water is never asked for)
*>   STDMOB-FIRE-BUILD USING tracker row, PB-BUFFER (empty)   Set Entity Data (0x65): metadata 0 (BYTE, the shared flags), bit 0 (on fire) set while EN-BURN > 0
*>   STDMOB-FIRE-SYNC USING tracker row   sends STDMOB-FIRE-BUILD to the viewers when the burning state differs from the last one sent (EN-FIRE-SENT)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-UNDEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-REGISTRY            PIC X(48) VALUE "entity_type".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:undead".
 01 WS-COUNT               BINARY-LONG.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 1 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 1.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-TYPE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TYPE L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "CONTENT-TAG-MEMBERS" USING WS-REGISTRY WS-TAG WS-COUNT WS-IDS WS-CAPACITY WS-STATUS
     IF WS-COUNT > 0
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-TYPE L-RESULT
         GOBACK
     END-IF
     EVALUATE L-KEY
         WHEN "skeleton" WHEN "stray" WHEN "wither_skeleton" WHEN "skeleton_horse" WHEN "bogged" WHEN "parched"
         WHEN "zombie_horse" WHEN "camel_husk" WHEN "zombie" WHEN "zombie_villager" WHEN "zombified_piglin" WHEN "zoglin" WHEN "drowned"
         WHEN "husk" WHEN "zombie_nautilus" WHEN "wither" WHEN "phantom" WHEN "giant"
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-UNDEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SINKS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-TYPE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-TYPE L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE L-KEY
         WHEN "zombie" WHEN "zombie_villager" WHEN "husk" WHEN "skeleton" WHEN "stray" WHEN "bogged" WHEN "parched"
         WHEN "wither_skeleton" WHEN "zombified_piglin"
             CALL "MOB-UNDEAD" USING L-KEY L-TYPE L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-SINKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FIRE-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 0 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE 0 TO MD-MD-INT
     IF EN-BURN(L-ROW) > 0
         MOVE 1 TO MD-MD-INT
     END-IF
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM STDMOB-FIRE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FIRE-SYNC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-BURNING             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-BURNING
     IF EN-BURN(L-ROW) > 0
         MOVE 1 TO WS-BURNING
     END-IF
     IF WS-BURNING NOT = EN-FIRE-SENT(L-ROW)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "STDMOB-FIRE-BUILD" USING L-ROW PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
         MOVE WS-BURNING TO EN-FIRE-SENT(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-FIRE-SYNC.
