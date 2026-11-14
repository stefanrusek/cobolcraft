*> The End's travel rules wired to the players (docs/protocol/38-end.md section 9, 39-portals.md section 7; T1757, T1758, T1737 to T1740): entering the End through an
*> end_portal block (the obsidian platform rebuilt with the items of the blocks it replaces dropped, arrival at (100.5, 49, 0.5) looking west, the portal sound), the
*> credits and the way out (a player who has not seen the credits gets Game Event 4 once and stays; PERFORM_RESPAWN then sends her to her respawn point or the world spawn;
*> afterwards the portal sends her there at once), the eye of ender used on an end_portal_frame (one eye used up, Level Event 1503, and with the ring complete nine
*> end_portal blocks and the global Level Event 1038) and falling out of the world in the End (4 damage a tick below y -64). The pure rules are in portal-39b.cob and
*> end-38d.cob. Not done (open items): end gateways (no block entity for them in the core: no exit position), mobs and items do not use end portals (players only), the
*> chunk ticket, wonGame and seenCredits are not saved with the player, the Respawn after the credits keeps the data kinds of every dimension switch (DIM-SWITCH), the death
*> message of the void is the command damage (no fell_out_of_world cause in RULES.cpy), the items of blocks replaced by the portal fill are not dropped.
*>
*> Entry points:
*>   END-TRAVEL-TICK                    no parameters: END-PLAYER-TICK for every player in play (CORE-TICK, after PORTAL-TICK)
*>   END-PLAYER-TICK USING player row   the cooldown, the void and the end portal block the player's box touches
*>   END-EYE-USE USING connection id, clicked state, held item, x, y, z, handled out   BLOCK-USE-ON's hook: an ender_eye on an empty end_portal_frame
*>   END-CREDITS-RESPAWN USING connection id, done out   PERFORM_RESPAWN after the credits (7.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-TRAVEL-IDS.
*> No parameters: the end_portal state and the ender_eye item id of the open set, resolved again when CB-EPOCH changes (-1 when absent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY ENDTRAVEL.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-ROW-TEXT            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     IF ET-EPOCH = CB-EPOCH
         GOBACK
     END-IF
     MOVE CB-EPOCH TO ET-EPOCH
     MOVE -1 TO ET-S-PORTAL ET-ITEM-EYE
     MOVE "end_portal" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS ET-S-PORTAL
     MOVE "ender_eye" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
     IF WS-STATUS = 0
         MOVE WS-ID TO ET-ITEM-EYE
     END-IF
     GOBACK.
 END PROGRAM END-TRAVEL-IDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-GLOBAL-EVENT.
*> USING event, x, y, z (BINARY-LONG): a Level Event with global true (the client plays it at full volume wherever it is) to every player in play.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 47.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-GLOBAL              BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-X L-Y L-Z.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LEVEL-EVENT" USING PB-BUFFER L-EVENT L-X L-Y L-Z WS-ZERO WS-GLOBAL
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM END-GLOBAL-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-EYE-USE.
*> USING connection id, clicked state, held item (0 none), x, y, z, handled out (BINARY-LONG): 39 section 7.2 for an ender_eye held over an end_portal_frame without an
*> eye (anything else is not handled, the item then acts as before): PORTAL-EYE-PLACE, one eye used up (creative included), Level Event 1503 at the frame and, when the
*> ring is complete, the global Level Event 1038 at the middle of the fill.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENDTRAVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-IS                  BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DESTROYED           BINARY-LONG.
 01 WS-EVENT-PLACE         BINARY-LONG VALUE 1503.
 01 WS-EVENT-OPEN          BINARY-LONG VALUE 1038.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-STATE L-ITEM L-X L-Y L-Z L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "END-TRAVEL-IDS"
     IF L-ITEM = 0 OR ET-ITEM-EYE < 0 OR L-ITEM NOT = ET-ITEM-EYE
         GOBACK
     END-IF
     CALL "PORTAL-FRAME-INFO" USING L-STATE WS-IS WS-EYE WS-FACING
     IF WS-IS = 0 OR WS-EYE = 1
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PORTAL-EYE-PLACE" USING PL-DIM(WS-ROW) L-X L-Y L-Z WS-RESULT WS-CX WS-CY WS-CZ WS-DESTROYED
     MOVE PL-HELD(WS-ROW) TO WS-HELD
     CALL "INV-REMOVE" USING WS-ROW WS-HELD WS-ONE
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "INV-SLOT-SEND" USING L-ID WS-HELD
     CALL "LEVEL-EVENT" USING PL-DIM(WS-ROW) WS-EVENT-PLACE L-X L-Y L-Z WS-ZERO WS-NONE
     IF WS-RESULT = 2
         COMPUTE WS-CX = WS-CX + 1
         COMPUTE WS-CZ = WS-CZ + 1
         CALL "END-GLOBAL-EVENT" USING WS-EVENT-OPEN WS-CX WS-CY WS-CZ
     END-IF
     GOBACK.
 END PROGRAM END-EYE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PLATFORM-DROPS.
*> USING dimension row: the items of the blocks that END-ARRIVE-BUILD is about to replace (a differing block that is not air in the 5 x 5 x 4 volume round
*> (100, 49, 0): its loot table's drops spawn where it stood), 38 section 9.1 item 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48) VALUE "obsidian".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TOOL                BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG VALUE 0.
 01 WS-HANDLE              BINARY-LONG VALUE 0.
 01 WS-NO-RADIUS           BINARY-LONG VALUE 0.
 01 WS-RADIUS              FLOAT-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "END-STATE-ID" USING WS-KEY WS-PAIRS WS-OBSIDIAN
     PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
         PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
             PERFORM VARYING WS-DY FROM -1 BY 1 UNTIL WS-DY > 2
                 COMPUTE WS-X = 100 + WS-DX
                 COMPUTE WS-Y = 49 + WS-DY
                 MOVE WS-DZ TO WS-Z
                 MOVE 0 TO WS-WANT
                 IF WS-DY = -1
                     MOVE WS-OBSIDIAN TO WS-WANT
                 END-IF
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-OLD
                 IF WS-OLD NOT = WS-WANT AND WS-OLD NOT = 0
                     CALL "BLOCK-DROPS-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-OLD WS-TOOL WS-COUNT WS-HANDLE
                         WS-NO-RADIUS WS-RADIUS WS-FOUND
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM END-PLATFORM-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-RETURN.
*> USING player row: the player goes to her respawn point (the spawnpoint of BRWORLD.cpy) or the world spawn of the first dimension (39 section 7.4: no sound, no ticket).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-DEST                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BR-WORLD-READY"
     IF BW-SPAWN-SET(L-ROW) = 1
         MOVE BW-SPAWN-DIM(L-ROW) TO WS-DEST
         MOVE BW-SPAWN-X(L-ROW) TO WS-X
         MOVE BW-SPAWN-Y(L-ROW) TO WS-Y
         MOVE BW-SPAWN-Z(L-ROW) TO WS-Z
         MOVE BW-SPAWN-YAW(L-ROW) TO PL-YAW(L-ROW)
         MOVE BW-SPAWN-PITCH(L-ROW) TO PL-PITCH(L-ROW)
     ELSE
         MOVE CW-DIM(1) TO WS-DEST
         MOVE CW-SPAWN-X TO WS-X
         MOVE CW-SPAWN-Y TO WS-Y
         MOVE CW-SPAWN-Z TO WS-Z
         MOVE CW-SPAWN-YAW TO PL-YAW(L-ROW)
         MOVE 0 TO PL-PITCH(L-ROW)
     END-IF
     CALL "DIM-SWITCH" USING L-ROW WS-DEST WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM END-RETURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CREDITS-RESPAWN.
*> USING connection id, done out (BINARY-LONG): Client Command PERFORM_RESPAWN of a living player who has won (wonGame, 7.5): wonGame is cleared and she goes to her
*> respawn point (END-RETURN); done 1. Anything else is not handled (done 0: a dead player's respawn is HEALTH-RESPAWN's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENDTRAVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG VALUE 1.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-DONE.
     MOVE 0 TO L-DONE
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "PORTAL-RESPAWN-ACTION" USING ET-WON(WS-ROW) WS-HEALTH WS-RESULT
     IF WS-RESULT = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
         MOVE 0 TO ET-WON(WS-ROW)
         CALL "END-RETURN" USING WS-ROW
         MOVE 1 TO L-DONE
     END-IF
     GOBACK.
 END PROGRAM END-CREDITS-RESPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-PLAYER-TICK.
*> USING player row: one tick of the End's rules for a player in play: the portal cooldown counts down; in the End below y -64 she takes 4.0 damage (END-BELOW-WORLD, 9.3);
*> an end_portal block touched by her box (0.6 x 1.8; the block's inside shape is the slab y 6/16 to 12/16) sends her to the End (PORTAL-END-INSIDE, transit time 0,
*> cooldown 10 ticks), or, in the End, shows her the credits the first time (PORTAL-CREDITS, Game Event 4) and sends her to her respawn point afterwards.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY RULES.
 COPY PROTO.
 COPY ENDTRAVEL.
 01 WS-LIVING              BINARY-LONG VALUE 1.
 01 WS-PLAYER              BINARY-LONG VALUE 1.
 01 WS-Y                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 4.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-IN-END              BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-SEND                BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MAX-X               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-MAX-Z               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.00001.
 01 WS-F                   FLOAT-LONG.
 01 WS-LOW                 FLOAT-LONG.
 01 WS-HIGH                FLOAT-LONG.
 01 WS-SLAB-LOW            FLOAT-LONG VALUE 0.375.
 01 WS-SLAB-HIGH           FLOAT-LONG VALUE 0.75.
 01 WS-ARRIVE-X            FLOAT-LONG.
 01 WS-ARRIVE-Y            FLOAT-LONG.
 01 WS-ARRIVE-Z            FLOAT-LONG.
 01 WS-ARRIVE-YAW          FLOAT-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 4.
 01 WS-VALUE               FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-COOLDOWN            BINARY-LONG VALUE 10.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "END-TRAVEL-IDS"
     IF ET-OWNER(L-ROW) NOT = PL-ENTITY-ID(L-ROW)
         INITIALIZE ET-PL(L-ROW)
         MOVE PL-ENTITY-ID(L-ROW) TO ET-OWNER(L-ROW)
     END-IF
     IF ET-COOLDOWN(L-ROW) > 0
         SUBTRACT 1 FROM ET-COOLDOWN(L-ROW)
     END-IF
     MOVE 0 TO WS-IN-END
     IF DM-KEY(PL-DIM(L-ROW)) = "minecraft:the_end"
         MOVE 1 TO WS-IN-END
     END-IF
     IF WS-IN-END = 1 AND PL-MODE(L-ROW) NOT = 3
         COMPUTE WS-Y = FUNCTION INTEGER(PL-Y(L-ROW))
         CALL "END-BELOW-WORLD" USING WS-Y WS-LIVING WS-RESULT
         IF WS-RESULT = 2
             CALL "HEALTH-DAMAGE" USING L-ROW WS-DAMAGE CAUSE-COMMAND WS-NONE WS-NONE
         END-IF
     END-IF
     IF ET-S-PORTAL < 0 OR PL-MODE(L-ROW) = 3
         GOBACK
     END-IF
*>   The cells the box touches, tested against the slab of each end_portal block.
     COMPUTE WS-F = PL-X(L-ROW) - 0.3 + WS-EPS
     COMPUTE WS-MIN-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-X(L-ROW) + 0.3 - WS-EPS
     COMPUTE WS-MAX-X = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Y(L-ROW) + WS-EPS
     COMPUTE WS-MIN-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Y(L-ROW) + 1.8 - WS-EPS
     COMPUTE WS-MAX-Y = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Z(L-ROW) - 0.3 + WS-EPS
     COMPUTE WS-MIN-Z = FUNCTION INTEGER(WS-F)
     COMPUTE WS-F = PL-Z(L-ROW) + 0.3 - WS-EPS
     COMPUTE WS-MAX-Z = FUNCTION INTEGER(WS-F)
     MOVE 0 TO WS-INSIDE
     PERFORM VARYING WS-X FROM WS-MIN-X BY 1 UNTIL WS-X > WS-MAX-X
         PERFORM VARYING WS-BY FROM WS-MIN-Y BY 1 UNTIL WS-BY > WS-MAX-Y
             PERFORM VARYING WS-Z FROM WS-MIN-Z BY 1 UNTIL WS-Z > WS-MAX-Z
                 CALL "WORLD-GET-BLOCK" USING PL-DIM(L-ROW) WS-X WS-BY WS-Z WS-STATE
                 IF WS-STATE = ET-S-PORTAL
                     COMPUTE WS-LOW = WS-BY + WS-SLAB-LOW
                     COMPUTE WS-HIGH = WS-BY + WS-SLAB-HIGH
                     COMPUTE WS-F = PL-Y(L-ROW) + 1.8
                     IF PL-Y(L-ROW) < WS-HIGH AND WS-F > WS-LOW
                         MOVE 1 TO WS-INSIDE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-INSIDE = 0
         GOBACK
     END-IF
     CALL "PORTAL-END-INSIDE" USING WS-IN-END WS-PLAYER ET-SEEN(L-ROW) WS-RESULT
     EVALUATE WS-RESULT
         WHEN 1
             CALL "PORTAL-CREDITS" USING ET-WON(L-ROW) ET-SEEN(L-ROW) WS-SEND
             IF WS-SEND = 1
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
             END-IF
         WHEN 2
             IF ET-COOLDOWN(L-ROW) > 0
                 MOVE WS-COOLDOWN TO ET-COOLDOWN(L-ROW)
             ELSE
                 MOVE WS-COOLDOWN TO ET-COOLDOWN(L-ROW)
                 PERFORM TRAVEL
             END-IF
     END-EVALUATE
     GOBACK.

*> The transfer: out of the End to her respawn point, else into the End when the world has it.
 TRAVEL.
     IF WS-IN-END = 1
         CALL "END-RETURN" USING L-ROW
     ELSE
         MOVE 0 TO WS-DEST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
             IF DM-KEY(CW-DIM(WS-I)) = "minecraft:the_end"
                 MOVE CW-DIM(WS-I) TO WS-DEST
             END-IF
         END-PERFORM
         IF WS-DEST > 0
             CALL "END-PLATFORM-DROPS" USING WS-DEST
             CALL "END-ARRIVE-BUILD" USING WS-DEST WS-DROPPED
             CALL "END-ARRIVAL" USING WS-PLAYER WS-ARRIVE-X WS-ARRIVE-Y WS-ARRIVE-Z WS-ARRIVE-YAW
             MOVE WS-ARRIVE-YAW TO PL-YAW(L-ROW)
             CALL "DIM-SWITCH" USING L-ROW WS-DEST WS-ARRIVE-X WS-ARRIVE-Y WS-ARRIVE-Z
             CALL "PORTAL-SOUND" USING PL-CONN(L-ROW)
         END-IF
     END-IF.
 END PROGRAM END-PLAYER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-TRAVEL-TICK.
*> No parameters: END-PLAYER-TICK for every player in play.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
             CALL "END-PLAYER-TICK" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM END-TRAVEL-TICK.
