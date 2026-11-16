*> Game rule change hooks (docs/protocol/33 section 8.1): limited_crafting sends every player Game Event 12 (LIMITED_CRAFTING) with 1.0 or 0.0,
*> immediate_respawn Game Event 11 (IMMEDIATE_RESPAWN), reduced_debug_info Entity Event 22 (true) or 23 (false) about the player itself. At join the same
*> three rules are in the Login packet (PLAY-LOGIN-BUILD). The other hooks (advance_time Set Time, locator_bar, spawn_monsters) are not wired here.
*>
*> Entry point: RULE-CHANGED USING rule table entry (BINARY-LONG, the index BR-RULE-FIND gives): sends what the change of that rule implies.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RULE-CHANGED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRRULES.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ID                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 01 WS-ENTITY-EVENT        BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY.
     MOVE 0 TO WS-KIND
     EVALUATE GR-D-NAME(L-ENTRY)
         WHEN "limited_crafting"
             MOVE 1 TO WS-KIND
             MOVE 12 TO WS-EVENT
         WHEN "immediate_respawn"
             MOVE 1 TO WS-KIND
             MOVE 11 TO WS-EVENT
         WHEN "reduced_debug_info"
             MOVE 2 TO WS-KIND
     END-EVALUATE
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-VALUE
     IF GR-VALUE(L-ENTRY) NOT = 0
         MOVE 1 TO WS-VALUE
     END-IF
     MOVE 23 TO WS-ENTITY-EVENT
     IF GR-VALUE(L-ENTRY) NOT = 0
         MOVE 22 TO WS-ENTITY-EVENT
     END-IF
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-PHASE(WS-ID) = PH-PLAY AND CN-PLAYER(WS-ID) > 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             IF WS-KIND = 1
                 CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
             ELSE
                 CALL "ENTITY-EVENT-BUILD" USING PL-ENTITY-ID(CN-PLAYER(WS-ID)) WS-ENTITY-EVENT PB-BUFFER
             END-IF
             CALL "CORE-SEND" USING WS-ID PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RULE-CHANGED.
