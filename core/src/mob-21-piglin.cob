*> Piglin bartering in the live world (docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.5.1; lane 002-lane-mobsb, T7103). The rules are PIGLIN-* of
*> mob-21-barter.cob; this file keeps the state (EN-ADMIRE, EN-ADMIRE-OFF, EN-ADMIRE-PL) and acts on it. Gaps: the thrown item has the random motion of a dropped item (not thrown
*> toward the player); the book, boots and potions of the table are dropped as plain items (no soul speed enchantment, no potion contents); admiring is not cancelled by damage yet.
*>
*>   PIGLIN-USE USING player row, entity row, held item key (X(24)), used out    mobInteract: a gold ingot from an adult that is not admiring starts the admiring
*>   PIGLIN-ZOMBIFY USING entity row, converted out                              21 section 5.5: timeInOverworld counts where piglins_zombify holds (everywhere but the Nether), above 300 and not peaceful the piglin becomes a zombified piglin
*>   PIGLIN-TICK USING entity row                                                 one tick: the timers count down, the barter happens when the admiring ends

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CUR                  BINARY-LONG.
 01 WS-ADULT                BINARY-LONG.
 01 WS-ADMIRING             BINARY-LONG.
 01 WS-DISABLED             BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-ENTITY                BINARY-LONG.
 01 L-HELD                  PIC X(24).
 01 L-USED                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-HELD L-USED.
     MOVE 0 TO L-USED
     CALL "PIGLIN-CURRENCY" USING L-HELD WS-CUR
     MOVE 0 TO WS-ADULT WS-ADMIRING WS-DISABLED
     IF EN-MOBAGE(L-ENTITY) >= 0
         MOVE 1 TO WS-ADULT
     END-IF
     IF EN-ADMIRE(L-ENTITY) > 0
         MOVE 1 TO WS-ADMIRING
     END-IF
     IF EN-ADMIRE-OFF(L-ENTITY) > 0
         MOVE 1 TO WS-DISABLED
     END-IF
     CALL "PIGLIN-ADMIRE" USING WS-ADULT WS-ADMIRING WS-DISABLED WS-YES
     IF WS-CUR = 1 AND WS-YES = 1
         CALL "MOB-TAKE" USING L-ROW
         MOVE 119 TO EN-ADMIRE(L-ENTITY)
         MOVE L-ROW TO EN-ADMIRE-PL(L-ENTITY)
         MOVE 1 TO L-USED
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ZOMBIFY.
*> The Nausea of 200 ticks of the converted mob and the cancelling of the admiring (the held items) are not done: open items of T7103.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY DIMENSIONS.
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-NEW                  BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 01 L-DONE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-DONE.
     MOVE 0 TO L-DONE
     IF DM-KEY(EN-DIM(L-ENTITY)) = "minecraft:the_nether"
         MOVE 0 TO EN-ZOMBIFY(L-ENTITY)
         GOBACK
     END-IF
     ADD 1 TO EN-ZOMBIFY(L-ENTITY)
     IF EN-ZOMBIFY(L-ENTITY) > 300 AND BW-DIFFICULTY > 0
         MOVE "zombified_piglin" TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE EN-X(L-ENTITY) TO WS-X
         MOVE EN-Y(L-ENTITY) TO WS-Y
         MOVE EN-Z(L-ENTITY) TO WS-Z
         MOVE EN-YAW(L-ENTITY) TO WS-YAW
         CALL "MOB-SPAWN" USING EN-DIM(L-ENTITY) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
         CALL "ENTITY-REMOVE" USING L-ENTITY
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-ZOMBIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-ROLL            BINARY-LONG VALUE 61.
 01 WS-SALT-COUNT           BINARY-LONG VALUE 62.
 01 WS-TOTAL                BINARY-LONG VALUE 469.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-KEY                  PIC X(24).
 01 WS-KEY32                PIC X(32).
 01 WS-LO                   BINARY-LONG.
 01 WS-HI                   BINARY-LONG.
 01 WS-MOD                  BINARY-LONG.
 01 WS-SPAN                 BINARY-LONG.
 01 WS-COUNT                BINARY-LONG.
 01 WS-ITEM                 BINARY-LONG.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-DELAY                BINARY-LONG VALUE 10.
 01 WS-DROP                 BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ENTITY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY.
     CALL "PIGLIN-ZOMBIFY" USING L-ENTITY WS-DONE
     IF WS-DONE = 1
         GOBACK
     END-IF
     IF EN-ADMIRE-OFF(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE-OFF(L-ENTITY)
     END-IF
     IF EN-ADMIRE(L-ENTITY) > 0
         SUBTRACT 1 FROM EN-ADMIRE(L-ENTITY)
         IF EN-ADMIRE(L-ENTITY) = 0
             CALL "XP-RANDOM" USING WS-SALT-ROLL WS-TOTAL WS-DRAW
             CALL "PIGLIN-BARTER" USING WS-DRAW WS-KEY WS-LO WS-HI WS-MOD
             COMPUTE WS-SPAN = WS-HI - WS-LO + 1
             CALL "XP-RANDOM" USING WS-SALT-COUNT WS-SPAN WS-DRAW
             COMPUTE WS-COUNT = WS-LO + WS-DRAW
             MOVE WS-KEY TO WS-KEY32
             CALL "MERCHANT-ITEM-ID" USING WS-KEY32 WS-ITEM
             IF WS-ITEM >= 0
                 MOVE EN-X(L-ENTITY) TO WS-X
                 COMPUTE WS-Y = EN-Y(L-ENTITY) + 1
                 MOVE EN-Z(L-ENTITY) TO WS-Z
                 CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ENTITY) WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-ZERO WS-DELAY WS-DROP
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-TICK.
