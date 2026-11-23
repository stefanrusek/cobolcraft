*> The look of a villager on the wire (002-lane-villlook; docs/protocol 34-entity-models-3 section 1.5, 19 section 22, 46 section 6): the client draws the biome clothing, the
*> profession and the level badge from the VILLAGER_DATA entry of the villager (entry 19, serializer 18: type id, profession id, level), so the server sends it whenever it is not
*> the default (plains, none, level 1). The state is the side table of mob-vil.cob (VL-TYPE, VL-PROF, VL-LEVEL); the ids are those of 46 section 6.
*> Open items: the zombie villager's own villager data (20 section on conversion) is not kept by the core, so it is drawn with the default look.
*>
*>   VILLOOK-CODE USING row, type out, profession id out, level out   the look of the villager row (plains, 0, 1 for a row without state)
*>   VILLOOK-DATA USING row, PB-BUFFER                                the entry 19 when the row is a villager (always, the caller decides when to send)
*>   VILLOOK-CHANGED USING row, changed out                           1 when the look differs from the one last seen for this entity (and remember it)
*>   VILLOOK-SYNC USING row                                           a changed look is sent to the viewers (MOB-DATA-SEND); the head shake counts down
*>   VL-UNHAPPY-SHAKE USING entity row                                the unhappy counter 40 (19 section 22.4), sent as entity data 18
*>   VL-UNHAPPY-TICK USING row                                        the counter counts down 1 and every value (the final 0 too) is sent

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLOOK-CODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-PROF                 BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TYPE L-PROF L-LEVEL.
     MOVE 2 TO L-TYPE
     MOVE 0 TO L-PROF
     MOVE 1 TO L-LEVEL
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE VL-TYPE(WS-SLOT) TO L-TYPE
         MOVE VL-LEVEL(WS-SLOT) TO L-LEVEL
*>       the profession id is the one of VIL-PROF-ID (mob-vil.cob), the single mapping of the profession key to the registry id
         CALL "VIL-PROF-ID" USING VL-PROF(WS-SLOT) L-PROF
     END-IF
     GOBACK.
 END PROGRAM VILLOOK-CODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLOOK-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==VK-==.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-TYPE                BINARY-LONG.
 01 WS-PROF                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 COPY PROTO.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "villager"
         CALL "VILLOOK-CODE" USING L-ROW WS-TYPE WS-PROF WS-LEVEL
*>       The head shake (19 section 22, index 18 INT the unhappy counter): sent while it counts down and once more with the final 0.
         CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
         IF WS-SLOT > 0 AND (VL-UNHAPPY(WS-SLOT) > 0 OR VL-UNHAPPY-ZERO(WS-SLOT) = 1)
             INITIALIZE VK-METADATA-ENTRY-X
             MOVE 18 TO VK-MX-INDEX
             MOVE 1 TO VK-MX-SERIALIZER
             MOVE VL-UNHAPPY(WS-SLOT) TO VK-MX-INT
             CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER VK-METADATA-ENTRY-X
         END-IF
         INITIALIZE VK-METADATA-ENTRY-X
         MOVE 19 TO VK-MX-INDEX
         MOVE 18 TO VK-MX-SERIALIZER
         MOVE WS-TYPE TO VK-MX-INT
         MOVE WS-PROF TO VK-MX-INT-2
         MOVE WS-LEVEL TO VK-MX-INT-3
         CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER VK-METADATA-ENTRY-X
     END-IF
     GOBACK.
 END PROGRAM VILLOOK-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLOOK-CHANGED.
*> The last look seen per entity row: the entity id and type * 1000 + profession * 10 + level (0 before the first sight, which counts as a change).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SEEN.
    05 WS-SEEN-ENTRY OCCURS 1024 TIMES.
       10 WS-SEEN-ID       BINARY-LONG VALUE 0.
       10 WS-SEEN-LOOK     BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PROF                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-LOOK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CHANGED.
     MOVE 0 TO L-CHANGED
     CALL "VILLOOK-CODE" USING L-ROW WS-TYPE WS-PROF WS-LEVEL
     COMPUTE WS-LOOK = WS-TYPE * 1000 + WS-PROF * 10 + WS-LEVEL
     IF WS-SEEN-ID(L-ROW) NOT = EN-ID(L-ROW) OR WS-SEEN-LOOK(L-ROW) NOT = WS-LOOK
         MOVE 1 TO L-CHANGED
         MOVE EN-ID(L-ROW) TO WS-SEEN-ID(L-ROW)
         MOVE WS-LOOK TO WS-SEEN-LOOK(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM VILLOOK-CHANGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VILLOOK-SYNC.
*> Called once a tick for a villager: a look not seen before (the first tick, a claimed workstation, a level up) is sent to the viewers, and the head shake counts down (VL-UNHAPPY-TICK).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CHANGED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VILLOOK-CHANGED" USING L-ROW WS-CHANGED
     IF WS-CHANGED = 1
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     CALL "VL-UNHAPPY-TICK" USING L-ROW
     GOBACK.
 END PROGRAM VILLOOK-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-UNHAPPY-SHAKE.
*> USING entity row of a villager: the head shake of 19 section 22.4 (setUnhappy): the unhappy counter is 40 and goes to the viewers as entity data 18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY.
     CALL "VL-FIND" USING EN-ID(L-ENTITY) WS-NO WS-SLOT
     IF WS-SLOT > 0
         MOVE 40 TO VL-UNHAPPY(WS-SLOT)
         CALL "MOB-DATA-SEND" USING L-ENTITY
     END-IF
     GOBACK.
 END PROGRAM VL-UNHAPPY-SHAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-UNHAPPY-TICK.
*> USING entity row of a villager, once a tick: a running head shake counts down 1 and every value is sent to the viewers, the 0 that ends it too (VILLOOK-DATA carries it while
*> VL-UNHAPPY-ZERO is 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0 AND VL-UNHAPPY(WS-SLOT) > 0
         SUBTRACT 1 FROM VL-UNHAPPY(WS-SLOT)
         IF VL-UNHAPPY(WS-SLOT) = 0
             MOVE 1 TO VL-UNHAPPY-ZERO(WS-SLOT)
         END-IF
         CALL "MOB-DATA-SEND" USING L-ROW
         MOVE 0 TO VL-UNHAPPY-ZERO(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM VL-UNHAPPY-TICK.
