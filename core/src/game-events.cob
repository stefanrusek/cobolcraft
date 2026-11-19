*> Game events (lane 002-lane-p49w; docs/protocol/30-redstone-8 sections 2 and 3, 31-block-entities-8 section 3, 20 section 15.1). One emitter, one dispatch:
*>   GAME-EVENT USING dim, x, y, z (FLOAT-LONG, the event position), event name (PIC X(32), the registry name without minecraft:), source entity row (0 none), affected block state id
*>     (-1 none): Level.gameEvent. The checks every listener shares (30 section 3.5): an event with frequency 0 that is not one of the warden's two extras is dropped; a spectator source, a warden
*>     source (Warden.dampensVibrations: it never hears itself) and an item entity whose stack is in the item tag dampens_vibrations are not valid; an affected state in the block tag
*>     dampens_vibrations (wool) is not valid. Then the listeners are told: GAME-EVENT-SENSORS (the hook of the sculk sensors and the shrieker, see below) and every warden (WARDEN-HEAR).
*>   GAME-EVENT-BLOCK USING dim, bx, by, bz (BINARY-LONG), event name, player row (0 none), affected state: Level.gameEvent(player, event, pos) of a block: the position is the block
*>     centre (30 section 2.1), the source the player's entity.
*>   GAME-EVENT-AT USING event name, source entity row, affected state: Entity.gameEvent: the event at the position of the entity (a player's own position, a mob's feet) with the entity as its source.
*>   GAME-EVENT-FREQUENCY USING event name, frequency out (30 section 3.1; BE8-FREQUENCY)
*>   GAME-EVENT-LISTENS USING event name, flag out: the event is in the game event tag warden_can_listen (20 section 15.1: the 55 events of vibrations except flap, plus shriek and
*>     sculk_sensor_tendrils_clicking).
*>   GAME-EVENT-SNEAKS USING event name, flag out: the event is in ignore_vibrations_sneaking. Only step is documented (30 section 12 V9); the rest of the tag is a gap named in the lane report.
*>   GAME-EVENT-TAGGED USING dim, x, y, z, tag key (PIC X(112)), flag out: the block at the cell is in that block tag.
*>   GAME-EVENT-RAY USING dim, start xyz, end xyz (FLOAT-LONG), hit out: Level.isBlockInLine with the occludes_vibration_signals predicate: the cells the segment passes through, in order
*>     from the start cell to the end cell (a plain voxel walk: the clip algorithm itself is not in the documents, 30 Open question 5).
*>   GAME-EVENT-OCCLUDED USING dim, event xyz, listener xyz (FLOAT-LONG), occluded out: 3.6: both points snapped to their block centres; six rays start 0.00001 from the event centre along
*>     each direction (down, up, north, south, west, east); the vibration is occluded only when every ray meets a block of occludes_vibration_signals.
*> THE SHARED HOOK: GAME-EVENT-SENSORS USING dim, x, y, z (FLOAT-LONG), event name, frequency, source entity row, block state. A lane that has sculk sensors or shrieker block entities
*> (lane p46h builds VIB-POST for them) replaces the body of this one program with its dispatch; the validity checks above have already passed when it is called, and the sensors apply their own
*> listener rules (radius 8 / 16, tags, cooldown phases) behind it. Nothing else needs to change for them to hear the events the core posts.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-FREQUENCY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FREQUENCY            BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FREQUENCY.
     MOVE L-EVENT TO WS-NAME
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-EVENT))
     CALL "BE8-FREQUENCY" USING WS-NAME WS-LENGTH L-FREQUENCY
     GOBACK.
 END PROGRAM GAME-EVENT-FREQUENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-LISTENS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FREQ                BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FLAG.
     CALL "GAME-EVENT-FREQUENCY" USING L-EVENT WS-FREQ
     MOVE 0 TO L-FLAG
     IF WS-FREQ > 0 AND L-EVENT NOT = "flap"
         MOVE 1 TO L-FLAG
     END-IF
     IF L-EVENT = "shriek" OR L-EVENT = "sculk_sensor_tendrils_clicking"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-LISTENS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-SNEAKS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-EVENT = "step"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-SNEAKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-TAGGED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TAG                  PIC X(112).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TAG L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY L-TAG WS-BLOCK L-FLAG
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT-TAGGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-RAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TAG                 PIC X(112) VALUE "minecraft:occludes_vibration_signals".
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-DTX                 FLOAT-LONG.
 01 WS-DTY                 FLOAT-LONG.
 01 WS-DTZ                 FLOAT-LONG.
 01 WS-BIG                 FLOAT-LONG VALUE 1000000.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-EX L-EY L-EZ L-HIT.
     MOVE 0 TO L-HIT WS-DONE
     COMPUTE WS-CX = FUNCTION INTEGER(L-SX)
     COMPUTE WS-CY = FUNCTION INTEGER(L-SY)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-SZ)
     COMPUTE WS-FX = FUNCTION INTEGER(L-EX)
     COMPUTE WS-FY = FUNCTION INTEGER(L-EY)
     COMPUTE WS-FZ = FUNCTION INTEGER(L-EZ)
     COMPUTE WS-DX = L-EX - L-SX
     COMPUTE WS-DY = L-EY - L-SY
     COMPUTE WS-DZ = L-EZ - L-SZ
     MOVE WS-BIG TO WS-TX WS-TY WS-TZ WS-DTX WS-DTY WS-DTZ
     MOVE 0 TO WS-SX WS-SY WS-SZ
     IF WS-DX > 0
         MOVE 1 TO WS-SX
         COMPUTE WS-TX = (WS-CX + 1 - L-SX) / WS-DX
         COMPUTE WS-DTX = 1 / WS-DX
     END-IF
     IF WS-DX < 0
         MOVE -1 TO WS-SX
         COMPUTE WS-TX = (WS-CX - L-SX) / WS-DX
         COMPUTE WS-DTX = -1 / WS-DX
     END-IF
     IF WS-DY > 0
         MOVE 1 TO WS-SY
         COMPUTE WS-TY = (WS-CY + 1 - L-SY) / WS-DY
         COMPUTE WS-DTY = 1 / WS-DY
     END-IF
     IF WS-DY < 0
         MOVE -1 TO WS-SY
         COMPUTE WS-TY = (WS-CY - L-SY) / WS-DY
         COMPUTE WS-DTY = -1 / WS-DY
     END-IF
     IF WS-DZ > 0
         MOVE 1 TO WS-SZ
         COMPUTE WS-TZ = (WS-CZ + 1 - L-SZ) / WS-DZ
         COMPUTE WS-DTZ = 1 / WS-DZ
     END-IF
     IF WS-DZ < 0
         MOVE -1 TO WS-SZ
         COMPUTE WS-TZ = (WS-CZ - L-SZ) / WS-DZ
         COMPUTE WS-DTZ = -1 / WS-DZ
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-DONE = 1
         CALL "GAME-EVENT-TAGGED" USING L-DIM WS-CX WS-CY WS-CZ WS-TAG WS-TAGGED
         IF WS-TAGGED = 1
             MOVE 1 TO L-HIT WS-DONE
         END-IF
         IF WS-CX = WS-FX AND WS-CY = WS-FY AND WS-CZ = WS-FZ
             MOVE 1 TO WS-DONE
         END-IF
         IF WS-DONE = 0
             EVALUATE TRUE
                 WHEN WS-TX <= WS-TY AND WS-TX <= WS-TZ
                     IF WS-TX > WS-ONE
                         MOVE 1 TO WS-DONE
                     END-IF
                     ADD WS-SX TO WS-CX
                     ADD WS-DTX TO WS-TX
                 WHEN WS-TY <= WS-TZ
                     IF WS-TY > WS-ONE
                         MOVE 1 TO WS-DONE
                     END-IF
                     ADD WS-SY TO WS-CY
                     ADD WS-DTY TO WS-TY
                 WHEN OTHER
                     IF WS-TZ > WS-ONE
                         MOVE 1 TO WS-DONE
                     END-IF
                     ADD WS-SZ TO WS-CZ
                     ADD WS-DTZ TO WS-TZ
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GAME-EVENT-RAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-OCCLUDED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.00001.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-LZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-EX                   FLOAT-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-EZ                   FLOAT-LONG.
 01 L-LX                   FLOAT-LONG.
 01 L-LY                   FLOAT-LONG.
 01 L-LZ                   FLOAT-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-EX L-EY L-EZ L-LX L-LY L-LZ L-OCCLUDED.
     COMPUTE WS-EX = FUNCTION INTEGER(L-EX) + WS-HALF
     COMPUTE WS-EY = FUNCTION INTEGER(L-EY) + WS-HALF
     COMPUTE WS-EZ = FUNCTION INTEGER(L-EZ) + WS-HALF
     COMPUTE WS-LX = FUNCTION INTEGER(L-LX) + WS-HALF
     COMPUTE WS-LY = FUNCTION INTEGER(L-LY) + WS-HALF
     COMPUTE WS-LZ = FUNCTION INTEGER(L-LZ) + WS-HALF
     MOVE 1 TO L-OCCLUDED
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5 OR L-OCCLUDED = 0
         MOVE WS-EX TO WS-SX
         MOVE WS-EY TO WS-SY
         MOVE WS-EZ TO WS-SZ
         EVALUATE WS-D
             WHEN 0
                 SUBTRACT WS-OFFSET FROM WS-SY
             WHEN 1
                 ADD WS-OFFSET TO WS-SY
             WHEN 2
                 SUBTRACT WS-OFFSET FROM WS-SZ
             WHEN 3
                 ADD WS-OFFSET TO WS-SZ
             WHEN 4
                 SUBTRACT WS-OFFSET FROM WS-SX
             WHEN OTHER
                 ADD WS-OFFSET TO WS-SX
         END-EVALUATE
         CALL "GAME-EVENT-RAY" USING L-DIM WS-SX WS-SY WS-SZ WS-LX WS-LY WS-LZ WS-HIT
         IF WS-HIT = 0
             MOVE 0 TO L-OCCLUDED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GAME-EVENT-OCCLUDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-SENSORS.
*> The shared hook (see the head of the file). USING dim, x, y, z (FLOAT-LONG), event name, frequency, source entity row, block state: no sculk listener exists in this lane, so nothing is told here.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EVENT                PIC X(32).
 01 L-FREQUENCY            BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EVENT L-FREQUENCY L-SOURCE L-STATE.
     GOBACK.
 END PROGRAM GAME-EVENT-SENSORS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 01 WS-FREQ                BINARY-LONG.
 01 WS-WARDEN              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-LISTENS             BINARY-LONG.
 01 WS-SNEAKS              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-SNEAK               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-ITEM-REGISTRY       PIC X(48) VALUE "item".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:dampens_vibrations".
 01 WS-SOURCE              BINARY-LONG.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-EVENT                PIC X(32).
 01 L-SOURCE               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EVENT L-SOURCE L-STATE.
     CALL "GAME-EVENT-FREQUENCY" USING L-EVENT WS-FREQ
     CALL "GAME-EVENT-LISTENS" USING L-EVENT WS-LISTENS
     IF WS-FREQ = 0 AND WS-LISTENS = 0
         GOBACK
     END-IF
     MOVE L-SOURCE TO WS-SOURCE
     MOVE 0 TO WS-CODE WS-OWNER WS-SNEAK
     IF WS-SOURCE > 0
         IF EN-USED(WS-SOURCE) NOT = 1
             MOVE 0 TO WS-SOURCE
         END-IF
     END-IF
     IF WS-SOURCE > 0
         MOVE EN-PLAYER(WS-SOURCE) TO WS-PLAYER
         CALL "STDMOB-INDEX" USING EN-TYPE(WS-SOURCE) WS-M
         MOVE 0 TO WS-WARDEN
         IF WS-M > 0
             IF SM-KEY(WS-M) = "warden"
                 MOVE 1 TO WS-WARDEN
             END-IF
         END-IF
         EVALUATE TRUE
             WHEN WS-PLAYER > 0
*>               a spectator is never a valid source; the shift key with an event of ignore_vibrations_sneaking filters the player out
                 IF PL-MODE(WS-PLAYER) = 3
                     GOBACK
                 END-IF
                 MOVE WS-PLAYER TO WS-CODE
                 CALL "GAME-EVENT-SNEAKS" USING L-EVENT WS-SNEAKS
                 COMPUTE WS-FLAGS = PL-POSE-FLAGS(WS-PLAYER) / 2
                 IF WS-SNEAKS = 1 AND FUNCTION MOD(WS-FLAGS, 2) = 1
                     MOVE 1 TO WS-SNEAK
                 END-IF
             WHEN WS-WARDEN = 1
*>               Warden.dampensVibrations: the warden never hears its own events and a sculk sensor never hears it either
                 GOBACK
             WHEN WS-M > 0
                 COMPUTE WS-CODE = CORE-MAX-PLAYERS + WS-SOURCE
             WHEN EN-TYPE(WS-SOURCE) = CR-LOOSE-ITEM
*>               ItemEntity.dampensVibrations: the stack is in the item tag dampens_vibrations (wool)
                 CALL "CONTENT-TAG-HAS" USING WS-ITEM-REGISTRY WS-TAG EN-ITEM(WS-SOURCE) WS-TAGGED
                 IF WS-TAGGED = 1
                     GOBACK
                 END-IF
             WHEN OTHER
*>               a projectile: the vibration carries its owner (31-8 section 3.5: getProjectileOwner), an arrow's EN-TARGET-ID is the owner's entity id
                 CALL "ARROW-TYPE" USING WS-ARROW
                 IF EN-TYPE(WS-SOURCE) = WS-ARROW
                     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-TARGET-ID(WS-SOURCE) AND PL-MODE(WS-P) NOT = 3
                             MOVE WS-P TO WS-OWNER
                         END-IF
                     END-PERFORM
                 END-IF
         END-EVALUATE
     END-IF
*>   the affected block state in the block tag dampens_vibrations (30 section 3.5 step 3)
     IF L-STATE > 0
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
         IF WS-TAGGED = 1
             GOBACK
         END-IF
     END-IF
     CALL "GAME-EVENT-SENSORS" USING L-DIM L-X L-Y L-Z L-EVENT WS-FREQ WS-SOURCE L-STATE
     IF WS-LISTENS = 1
         CALL "WARDEN-HEAR" USING L-DIM L-X L-Y L-Z WS-CODE WS-OWNER WS-SNEAK
     END-IF
     GOBACK.
 END PROGRAM GAME-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SOURCE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-EVENT                PIC X(32).
 01 L-PLAYER               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-EVENT L-PLAYER L-STATE.
     COMPUTE WS-X = L-BX + 0.5
     COMPUTE WS-Y = L-BY + 0.5
     COMPUTE WS-Z = L-BZ + 0.5
     MOVE 0 TO WS-SOURCE
     IF L-PLAYER > 0
         MOVE PL-ENTITY-ROW(L-PLAYER) TO WS-SOURCE
     END-IF
     CALL "GAME-EVENT" USING L-DIM WS-X WS-Y WS-Z L-EVENT WS-SOURCE L-STATE
     GOBACK.
 END PROGRAM GAME-EVENT-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-EVENT-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-STATE               BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(32).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-ROW.
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     IF EN-PLAYER(L-ROW) > 0
         MOVE PL-X(EN-PLAYER(L-ROW)) TO WS-X
         MOVE PL-Y(EN-PLAYER(L-ROW)) TO WS-Y
         MOVE PL-Z(EN-PLAYER(L-ROW)) TO WS-Z
     END-IF
     CALL "GAME-EVENT" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z L-EVENT L-ROW WS-STATE
     GOBACK.
 END PROGRAM GAME-EVENT-AT.
