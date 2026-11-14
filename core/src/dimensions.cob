*> Travel between dimensions (US12; standin-content §15.5; docs/protocol/09-cobolcraft-profile.md
*> §3.3 Dimensions rows; contracts/wire-profile.md §3.3; data-model §6 Travelling).
*>
*> Trigger (DIM-USE-PAD, from BLOCK-USE-ON in core/src/blocks.cob): Use Item On aimed at a goto_pad
*> (DIMENSIONS.cpy TRAVEL-BLOCK), with either hand and whatever is held, by an alive player in
*> either game mode. It is ignored when the player travelled in the last TRAVEL-COOLDOWN ticks, and
*> while the extra-dimensions setting is off (US12-4: the player stays where they are).
*> Walking into a goto_pad does nothing. The destination is the dimension's DM-TRAVEL-TO.
*>
*> Arrival point (DIM-ARRIVAL), in the column (X, Z) of the pad used: the destination chunk holding
*> it is loaded (generated if new); top is the y of the column's highest non-void block. When it is
*> a goto_pad the arrival pad is that block (t = top), otherwise a goto_pad is placed at t = top + 1
*> (BLOCK-CHANGE: Block Update to its viewers, light recomputed). When t + 2 is above the
*> destination's highest y the travel does not happen and nothing is placed. The player's feet
*> arrive at (X + 0.5, t + 1, Z + 0.5), yaw and pitch unchanged. No block is ever removed.
*>
*> Switch (DIM-SWITCH): the player is Travelling while it runs; a break in progress ends, eating is
*> cancelled, the fall start is reset; inventory, health, food level and game mode are kept. The
*> player is sent Respawn with the destination's spawn info and data to keep TRAVEL-KEEP (0x03),
*> then Change Difficulty and the permission level (Entity Event 24 + level; DIM-LEVEL-INFO), Player
*> Abilities, Set Held Slot, Container Set Content, Initialize Border of the destination (DIM-BORDER-SEND)
*> and the arrival part of the join sequence of the new dimension (PLAY-ARRIVE: Set Health, spawn
*> position, Set Time, the weather pair, Game Event 13, the chunk batch, Player Position), then Set
*> Experience and Set Health again (39 section 8.1 step 19; DIM-PLAYER-REFRESH). Its entity leaves the viewers of the old
*> dimension, moves, and is shown to the viewers of the new one; the player is shown what it sees
*> there. Mobs and ground items stay in their dimension.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-USE-PAD.
*> USING connection id, x, y, z (BINARY-LONG) of a goto_pad a player used: the trigger rules above,
*> then DIM-ARRIVAL and DIM-SWITCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-STATE(WS-ROW) NOT = PS-ALIVE OR CS-EXTRA-DIMENSIONS NOT = 1
         GOBACK
     END-IF
     IF PL-TRAVELLED(WS-ROW) = 1 AND CW-TICKS - PL-TRAVEL-TICK(WS-ROW) < TRAVEL-COOLDOWN
         GOBACK
     END-IF
     MOVE DM-TRAVEL-TO(PL-DIM(WS-ROW)) TO WS-DEST
     CALL "DIM-ARRIVAL" USING WS-DEST L-X L-Z WS-T
     IF WS-T < 0
         GOBACK
     END-IF
     COMPUTE WS-X = L-X + 0.5
     COMPUTE WS-Y = WS-T + 1
     COMPUTE WS-Z = L-Z + 0.5
     CALL "DIM-SWITCH" USING WS-ROW WS-DEST WS-X WS-Y WS-Z
     GOBACK.
 END PROGRAM DIM-USE-PAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-ARRIVAL.
*> USING destination dimension row, x, z, t out (BINARY-LONG): the arrival-point rule above; t is the
*> y of the arrival goto_pad, -1 when the travel does not happen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PAD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-T                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-T.
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-CHUNK" USING L-DIM WS-CX WS-CZ WS-CHUNK
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-TOP < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-TOP L-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-TOP
         END-IF
     END-PERFORM
     MOVE WS-TOP TO L-T
     IF CB-S-BLOCK(WS-STATE + 1) NOT = CR-GOTO-PAD
         ADD 1 TO L-T
     END-IF
     IF L-T + 2 > DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
         MOVE -1 TO L-T
         GOBACK
     END-IF
     IF L-T > WS-TOP
         MOVE CR-GOTO-PAD-STATE TO WS-PAD
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-T L-Z WS-PAD
     END-IF
     GOBACK.
 END PROGRAM DIM-ARRIVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-LEVEL-INFO.
*> USING player row, destination dimension row (BINARY-LONG): what a player is sent right after Respawn for a new level (39 section 8.1 steps 6 and 15):
*> Change Difficulty 0x0A (the world difficulty BW-DIFFICULTY, not locked) and the player's permission level as Entity Event 24 + level of the player's own entity
*> (without the Commands tree: the tree does not change with the dimension), then, after the join messages of the level, DIM-PLAYER-REFRESH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 10.
 01 WS-LOCKED              BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DEST.
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER BW-DIFFICULTY
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-LOCKED
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "BR-SOURCE-LEVEL" USING L-ROW WS-LEVEL
     COMPUTE WS-EVENT = 24 + WS-LEVEL
     CALL "ENTITY-EVENT-BUILD" USING PL-ENTITY-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM DIM-LEVEL-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-BORDER-SEND.
*> USING player row, destination dimension row (BINARY-LONG): Initialize Border 0x2C of the destination level's world border (39 section 8.1 step 15; the
*> fields of 05a: centre, old size, new size, lerp time in ms, absolute maximum size, warning blocks 5, warning time 300 (33 section 7.1 defaults)).
*> A moving border sends its current size, its target and the remaining ticks (W2-B-PROGRESS counts down) as milliseconds.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 96.
 01 WS-PACKET-ID           BINARY-LONG VALUE 44.
 01 WS-WARN-BLOCKS         BINARY-LONG VALUE 5.
 01 WS-WARN-TIME           BINARY-LONG VALUE 300.
 01 WS-OLD                 FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-LERP                BINARY-DOUBLE.
 01 WS-ABSOLUTE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DEST.
     CALL "WORLDSIM-ENSURE2"
     MOVE W2-B-SIZE(L-DEST) TO WS-OLD WS-NEW
     MOVE 0 TO WS-LERP
     IF W2-B-MOVING(L-DEST) = 1
         MOVE W2-B-TO(L-DEST) TO WS-NEW
         COMPUTE WS-LERP = W2-B-PROGRESS(L-DEST) * 50
     END-IF
     MOVE W2-B-ABSOLUTE(L-DEST) TO WS-ABSOLUTE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER W2-B-CX(L-DEST)
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER W2-B-CZ(L-DEST)
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-OLD
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER WS-NEW
     CALL "PB-PUT-VARLONG" USING PB-BUFFER WS-LERP
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ABSOLUTE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-WARN-BLOCKS
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-WARN-TIME
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM DIM-BORDER-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-PLAYER-REFRESH.
*> USING player row (BINARY-LONG): the "last sent" experience and health are reset on a dimension change (39 section 8.1 step 19), so the next player tick
*> re-sends Set Experience 0x69 (progress, level, total) and Set Health 0x6A (health, food, saturation): both are sent now.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-PROGRESS            FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "XP-NEEDED" USING PL-XP-LEVEL(L-ROW) WS-NEEDED
     COMPUTE WS-PROGRESS = PL-XP-POINTS(L-ROW) / WS-NEEDED
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "SET-EXPERIENCE-BUILD" USING WS-PROGRESS PL-XP-LEVEL(L-ROW) PL-XP-TOTAL(L-ROW) PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "HEALTH-SEND" USING L-ROW
     GOBACK.
 END PROGRAM DIM-PLAYER-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-SWITCH.
*> USING player row, destination dimension row (BINARY-LONG), feet x, y, z (FLOAT-LONG): the switch
*> above, then the console line "<name> went to <dimension key>" (operator-surface §3, US13-3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-KEEP                BINARY-LONG VALUE 3.
 01 WS-ON-GROUND           BINARY-LONG VALUE 1.
 01 WS-LINE                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-DEST L-X L-Y L-Z.
     MOVE L-ROW TO WS-ROW
     MOVE PL-CONN(WS-ROW) TO WS-CONN
     CALL "MENU-FORCE-CLOSE" USING WS-ROW
     MOVE PS-TRAVELLING TO PL-STATE(WS-ROW)
     CALL "BLOCK-BREAK-END" USING WS-ROW
     CALL "HUNGER-CANCEL" USING WS-ROW
     MOVE L-DEST TO PL-DIM(WS-ROW)
     MOVE L-X TO PL-X(WS-ROW)
     MOVE L-Y TO PL-Y(WS-ROW) PL-FALL-START(WS-ROW)
     MOVE L-Z TO PL-Z(WS-ROW)
     MOVE 1 TO PL-ON-GROUND(WS-ROW) PL-TRAVELLED(WS-ROW)
     MOVE CW-TICKS TO PL-TRAVEL-TICK(WS-ROW)
     MOVE TRAVEL-KEEP TO WS-KEEP
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-RESPAWN-BUILD" USING PL-DIM(WS-ROW) PL-MODE(WS-ROW) WS-KEEP PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "DIM-LEVEL-INFO" USING WS-ROW L-DEST
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-ABILITIES-BUILD" USING PL-MODE(WS-ROW) PL-FLYING(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-HELD-SLOT-BUILD" USING PL-HELD(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "DIM-BORDER-SEND" USING WS-ROW L-DEST
     CALL "PLAY-ARRIVE" USING WS-CONN
     CALL "DIM-PLAYER-REFRESH" USING WS-ROW
     MOVE PL-ENTITY-ROW(WS-ROW) TO WS-ENTITY
     CALL "ENTITY-VIEWER-FORGET" USING WS-ROW
     CALL "ENTITY-CHANGE-DIM" USING WS-ENTITY PL-DIM(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW)
         PL-Z(WS-ROW) PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ON-GROUND
     CALL "ENTITY-VIEWER-REFRESH" USING WS-ROW
     MOVE PS-ALIVE TO PL-STATE(WS-ROW)
     MOVE SPACES TO WS-LINE
     STRING PL-NAME(WS-ROW)(1:PL-NAME-LENGTH(WS-ROW)) " went to "
         DM-KEY(L-DEST)(1:DM-KEY-LENGTH(L-DEST)) DELIMITED BY SIZE INTO WS-LINE
     COMPUTE WS-LENGTH = PL-NAME-LENGTH(WS-ROW) + 9 + DM-KEY-LENGTH(L-DEST)
     CALL "CORE-LOG" USING WS-LINE WS-LENGTH
     GOBACK.
 END PROGRAM DIM-SWITCH.
