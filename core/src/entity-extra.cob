*> Entity data of the non-mob entities of lane p49f (docs/protocol/21 sections 8.5, 8.8, 8.9, 8.16): what a viewer is sent in Set Entity Data (0x65) after Add Entity, found from the entity's
*> PROJSTATE.cpy entry (PJ-KIND). The hook is ENTITY-VIEW-UPDATE (entities.cob); a change while viewers have the entity is sent by the entity's own step.
*>   ENTITY-EXTRA-NEEDED USING row, needed out          1 when the entity has entries to send
*>   ENTITY-EXTRA-DATA USING row, PB-BUFFER             the Set Entity Data packet of those entries

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-EXTRA-NEEDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-NEEDED.
     MOVE 0 TO L-NEEDED
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "bat" OR "happy_ghast" OR "axolotl"
         MOVE 1 TO L-NEEDED
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         IF PJ-KIND(WS-SLOT) = 3 OR PJ-KIND(WS-SLOT) = 41
             MOVE 1 TO L-NEEDED
         END-IF
         IF PJ-KIND(WS-SLOT) = 10 OR PJ-KIND(WS-SLOT) = 11 OR PJ-KIND(WS-SLOT) = 12 OR PJ-KIND(WS-SLOT) = 13 OR PJ-KIND(WS-SLOT) >= 44
             IF PJ-I8(WS-SLOT) > 0
                 MOVE 1 TO L-NEEDED
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-EXTRA-NEEDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-EXTRA-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "bat"
         CALL "BAT-DATA-BUILD" USING L-ROW PB-BUFFER
         GOBACK
     END-IF
     IF WS-KEY = "happy_ghast"
         CALL "HG-DATA-BUILD" USING L-ROW PB-BUFFER
         GOBACK
     END-IF
     IF WS-KEY = "axolotl"
         CALL "AXOLOTL-DATA-BUILD" USING L-ROW PB-BUFFER
         GOBACK
     END-IF
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0
         IF PJ-KIND(WS-SLOT) = 3
             CALL "CLOUD-DATA-BUILD" USING L-ROW WS-SLOT PB-BUFFER
         END-IF
         IF PJ-KIND(WS-SLOT) = 41
             CALL "OIS-DATA-BUILD" USING L-ROW PB-BUFFER
         END-IF
         IF PJ-KIND(WS-SLOT) = 10 OR PJ-KIND(WS-SLOT) = 11 OR PJ-KIND(WS-SLOT) = 12 OR PJ-KIND(WS-SLOT) = 13 OR PJ-KIND(WS-SLOT) >= 44
             CALL "DECOR-DATA-BUILD" USING L-ROW PB-BUFFER
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENTITY-EXTRA-DATA.
