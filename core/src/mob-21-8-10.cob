*> The bat (docs/protocol/21 section 8.10; 18 sections 3.2 B and 6.8), lane p49f. Row `bat` of MOBROWS11.cpy (health 6, SM-SPAWN 16 = Bat.checkBatSpawnRules, the ambient category 3). The state is in the
*> tracker row: EN-PH-PHASE 1 = resting (metadata 16 bit 0), EN-PH-SET 1 = a target cell is set, EN-PH-TX, EN-PH-TY and EN-PH-TZ the target cell (the phantom's fields, unused by a bat). A new bat hangs
*> (MOB-BORN). STDMOB-STEP gives every bat to BAT-TICK after the environment.
*> Resting: velocity zero, y snapped to floor(y) + 1 - 0.9; the block above not a redstone conductor ends it (level event 1025, the take-off); else 1 in 200 a random head yaw (nextInt(360)) and a player (not a
*> spectator) within 4 blocks ends it too. Flying: vertical velocity x 0.6, the target cell cleared when it is not air or not above the world minimum, a new one when there is none, 1 in 30 or within 2 blocks of
*> the cell's centre: (x + nextInt(7) - nextInt(7), y + nextInt(6) - 2, z + nextInt(7) - nextInt(7)); steering v += ((sign(dx) x 0.5 - vx) x 0.1, (sign(dy) x 0.7 - vy) x 0.1, (sign(dz) x 0.5 - vz) x 0.1)
*> toward (target + (0.5, 0.1, 0.5)); yaw += wrapDegrees(atan2(vz, vx) - 90 - yaw); the air acceleration 0.02 x 0.5 along the yaw (18 section 3.2 B), the move (a solid cell stops the speed on its axis) and the
*> drag 0.91; 1 in 100 it starts resting when the block above is a redstone conductor.
*> Hurt while resting: BAT-HURT (HEALTH-MOB-DAMAGE) ends the rest first. Not done: the flap animation (a client state), that a bat is not pushable and does not push, the experience (not in the documents), the
*> head yaw as its own value (EN-YAW is the body yaw), the probability of Halloween (not in the documents).
*>
*> Entry points:
*>   BAT-SPAWN-OK USING below surface, draw, brightness, bound draw, in tag, base ok, ok out   the truth table of checkBatSpawnRules
*>   BAT-RULE-AT USING state, dim, species row, x, y, z, reason, ok out                           the rule at a cell (MS6-RULE-AT)
*>   BAT-CONDUCTOR USING dim, x, y, z, conductor out                                              1 when the block there is a redstone conductor
*>   BAT-DATA-BUILD USING row, PB-BUFFER                                                          Set Entity Data: index 16 BYTE flags
*>   BAT-DATA-SEND USING row                                                                      to the viewers
*>   BAT-HURT USING row                                                                           the rest ends
*>   BAT-TICK USING row                                                                           one tick

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-SPAWN-OK.
*> below surface: 1 when y is below the WORLD_SURFACE height of the column; draw: nextBoolean (1 = true, which fails); brightness: the raw brightness; bound draw: nextInt(4); in tag: the block
*> below is in bats_spawnable_on; base ok: checkMobSpawnRules. All must hold, in that order.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-DRAW L-BRIGHT L-BOUND L-TAG L-BASE L-OK.
     MOVE 0 TO L-OK
     IF L-BELOW = 1 AND L-DRAW = 0 AND L-BRIGHT <= L-BOUND AND L-TAG = 1 AND L-BASE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BAT-SPAWN-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-RULE-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-TAG-KEY             PIC X(112) VALUE "minecraft:base_stone_overworld".
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BELOW-SURFACE       BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND-2             BINARY-LONG VALUE 2.
 01 WS-BOUND-4             BINARY-LONG VALUE 4.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-BELOW-Y             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-IN-TAG              BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-DARK-OK             BINARY-LONG.
 01 WS-BRIGHT-OK           BINARY-LONG.
 01 WS-GRASS               BINARY-LONG.
 01 WS-SKY-OK              BINARY-LONG.
 01 WS-PRED                BINARY-LONG VALUE 1.
 01 WS-BASE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-ROW L-X L-Y L-Z L-REASON L-OK.
     MOVE 0 TO L-OK WS-BELOW-SURFACE
*>   The WORLD_SURFACE height of the column: one above the highest block that is not air.
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-TOP < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-TOP L-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-TOP
         END-IF
     END-PERFORM
     IF L-Y <= WS-TOP
         MOVE 1 TO WS-BELOW-SURFACE
     END-IF
     IF WS-BELOW-SURFACE = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-BOUND-2 WS-DRAW
     IF WS-DRAW = 1
         GOBACK
     END-IF
     CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK WS-RAW
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
     CALL "MS6-LOCAL-LIGHT" USING WS-SKY WS-BLOCK WS-DARKEN WS-ZERO WS-LOCAL
     CALL "XORO-NEXT-INT" USING L-STATE WS-BOUND-4 WS-LEVEL
     COMPUTE WS-BELOW-Y = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BELOW-Y L-Z WS-STATE
     MOVE 0 TO WS-IN-TAG
     IF WS-STATE > 0
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK-ID
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-KEY WS-BLOCK-ID WS-IN-TAG
     END-IF
*>   checkMobSpawnRules: the block below is a valid spawn floor (predicate 1 of MS6-RULE-CHECK; the spawners skip the test).
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-BELOW-Y L-Z WS-KIND
     MOVE 0 TO WS-VALID WS-PEACEFUL WS-DARK-OK WS-BRIGHT-OK WS-GRASS WS-SKY-OK
     IF WS-KIND = 1
         MOVE 1 TO WS-VALID
     END-IF
     CALL "MS6-RULE-CHECK" USING WS-PRED L-REASON WS-PEACEFUL WS-DARK-OK WS-BRIGHT-OK WS-VALID WS-GRASS WS-SKY-OK WS-BASE
     CALL "BAT-SPAWN-OK" USING WS-BELOW-SURFACE WS-DRAW WS-LOCAL WS-LEVEL WS-IN-TAG WS-BASE L-OK
     GOBACK.
 END PROGRAM BAT-RULE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-CONDUCTOR.
*> A redstone conductor (30 section 2.4): a full solid block that is not on the never list of RS1-CONDUCTOR-KIND, or one on its always list.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-LONG                PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CONDUCTOR.
     MOVE 0 TO L-CONDUCTOR
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     IF CB-SOLID(WS-BLOCK) NOT = 1
         GOBACK
     END-IF
     MOVE CB-KEY(WS-BLOCK) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG WS-BARE
     MOVE WS-BARE TO WS-NAME
     CALL "RS1-CONDUCTOR-KIND" USING WS-NAME WS-KIND
     IF WS-KIND NOT = 1
         MOVE 1 TO L-CONDUCTOR
     END-IF
     GOBACK.
 END PROGRAM BAT-CONDUCTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-DATA-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 16 TO MD-MD-INDEX
     MOVE MD-MDS-BYTE TO MD-MD-SERIALIZER
     MOVE EN-PH-PHASE(L-ROW) TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM BAT-DATA-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-DATA-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BAT-DATA-BUILD" USING L-ROW PB-BUFFER
     CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM BAT-DATA-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-WAKE.
*> USING row: the bat stops resting: the flag, the take-off level event 1025 and the new metadata.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-EVENT               BINARY-LONG VALUE 1025.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EN-PH-PHASE(L-ROW)
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-EVENT WS-X WS-Y WS-Z WS-NONE WS-NONE2
     CALL "BAT-DATA-SEND" USING L-ROW
     GOBACK.
 END PROGRAM BAT-WAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-HURT.
*> USING row: a hurt resting bat stops resting first (without the take-off event: that is for the AI's own decision; the hurt takes the damage afterwards).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "bat" AND EN-PH-PHASE(L-ROW) = 1
         MOVE 0 TO EN-PH-PHASE(L-ROW)
         CALL "BAT-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM BAT-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-MOVE.
*> USING row: the air acceleration 0.02 x 0.5 along the yaw, the move with a solid cell stopping the speed on that axis, and the drag 0.91 (18 section 3.2 B, travelFlying).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CY2                 BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-SOLID2              BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-RAD = EN-YAW(L-ROW) * FUNCTION PI / 180
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - FUNCTION SIN(WS-RAD) * 0.01
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-RAD) * 0.01
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
*>   Each axis alone: the cells at the feet and the head of the box at the new place must be free.
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) + EN-VX(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CY2 = FUNCTION INTEGER(EN-Y(L-ROW) + 0.8)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY2 WS-CZ WS-SOLID2
     IF WS-SOLID = 1 OR WS-SOLID2 = 1
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW) + EN-VY(L-ROW))
     COMPUTE WS-CY2 = FUNCTION INTEGER(EN-Y(L-ROW) + EN-VY(L-ROW) + 0.8)
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY2 WS-CZ WS-SOLID2
     IF EN-VY(L-ROW) > 0
         MOVE WS-SOLID2 TO WS-SOLID
     ELSE
         MOVE WS-SOLID TO WS-SOLID2
     END-IF
     IF WS-SOLID = 1 OR WS-SOLID2 = 1
         MOVE 0 TO EN-VY(L-ROW)
     END-IF
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE WS-CY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-CY2 = FUNCTION INTEGER(WS-Y + 0.8)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) + EN-VZ(L-ROW))
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY2 WS-CZ WS-SOLID2
     IF WS-SOLID = 1 OR WS-SOLID2 = 1
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.91
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.91
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.91
     GOBACK.
 END PROGRAM BAT-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BAT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SALT                BINARY-LONG VALUE 214.
 01 WS-B200                BINARY-LONG VALUE 200.
 01 WS-B360                BINARY-LONG VALUE 360.
 01 WS-B30                 BINARY-LONG VALUE 30.
 01 WS-B100                BINARY-LONG VALUE 100.
 01 WS-B7                  BINARY-LONG VALUE 7.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-CONDUCTOR           BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TXI                 BINARY-LONG.
 01 WS-TYI                 BINARY-LONG.
 01 WS-TZI                 BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-HEADING             FLOAT-LONG.
 01 WS-WRAP                FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     IF EN-PH-PHASE(L-ROW) = 1
*>       Resting: still, hanging under the ceiling (Bat.tick, then customServerAiStep).
         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
         COMPUTE WS-Y = WS-BY + 1 - 0.9
         IF EN-Y(L-ROW) NOT = WS-Y
             MOVE EN-X(L-ROW) TO WS-X
             MOVE EN-Z(L-ROW) TO WS-Z
             MOVE EN-YAW(L-ROW) TO WS-YAW
             MOVE EN-PITCH(L-ROW) TO WS-PITCH
             CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
         END-IF
         COMPUTE WS-ABOVE = WS-BY + 1
         CALL "BAT-CONDUCTOR" USING EN-DIM(L-ROW) WS-BX WS-ABOVE WS-BZ WS-CONDUCTOR
         IF WS-CONDUCTOR = 0
             CALL "BAT-WAKE" USING L-ROW
         ELSE
             CALL "XP-RANDOM" USING WS-SALT WS-B200 WS-R
             IF WS-R = 0
                 CALL "XP-RANDOM" USING WS-SALT WS-B360 WS-R
                 MOVE WS-R TO EN-YAW(L-ROW)
             END-IF
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR EN-PH-PHASE(L-ROW) = 0
                 IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3
                     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
                     COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
                     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF WS-D2 <= 16
                         CALL "BAT-WAKE" USING L-ROW
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         GOBACK
     END-IF
*>   Flying.
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.6
     IF EN-PH-SET(L-ROW) = 1
         COMPUTE WS-TXI = FUNCTION INTEGER(EN-PH-TX(L-ROW))
         COMPUTE WS-TYI = FUNCTION INTEGER(EN-PH-TY(L-ROW))
         COMPUTE WS-TZI = FUNCTION INTEGER(EN-PH-TZ(L-ROW))
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-TXI WS-TYI WS-TZI WS-STATE
         IF WS-STATE NOT = 0 OR WS-TYI <= DM-MIN-Y(EN-DIM(L-ROW))
             MOVE 0 TO EN-PH-SET(L-ROW)
         END-IF
     END-IF
     MOVE 0 TO WS-NEW
     IF EN-PH-SET(L-ROW) = 0
         MOVE 1 TO WS-NEW
     ELSE
         CALL "XP-RANDOM" USING WS-SALT WS-B30 WS-R
         IF WS-R = 0
             MOVE 1 TO WS-NEW
         END-IF
         COMPUTE WS-DX = EN-PH-TX(L-ROW) + 0.5 - EN-X(L-ROW)
         COMPUTE WS-DY = EN-PH-TY(L-ROW) + 0.5 - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-PH-TZ(L-ROW) + 0.5 - EN-Z(L-ROW)
         IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4
             MOVE 1 TO WS-NEW
         END-IF
     END-IF
     IF WS-NEW = 1
         CALL "XP-RANDOM" USING WS-SALT WS-B7 WS-R
         CALL "XP-RANDOM" USING WS-SALT WS-B7 WS-R2
         COMPUTE EN-PH-TX(L-ROW) = WS-BX + WS-R - WS-R2
         CALL "XP-RANDOM" USING WS-SALT WS-B6 WS-R
         COMPUTE EN-PH-TY(L-ROW) = WS-BY + WS-R - 2
         CALL "XP-RANDOM" USING WS-SALT WS-B7 WS-R
         CALL "XP-RANDOM" USING WS-SALT WS-B7 WS-R2
         COMPUTE EN-PH-TZ(L-ROW) = WS-BZ + WS-R - WS-R2
         MOVE 1 TO EN-PH-SET(L-ROW)
     END-IF
*>   Steering toward (target + (0.5, 0.1, 0.5)).
     COMPUTE WS-DX = EN-PH-TX(L-ROW) + 0.5 - EN-X(L-ROW)
     COMPUTE WS-DY = EN-PH-TY(L-ROW) + 0.1 - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-PH-TZ(L-ROW) + 0.5 - EN-Z(L-ROW)
     EVALUATE TRUE
         WHEN WS-DX > 0
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (0.5 - EN-VX(L-ROW)) * 0.1
         WHEN WS-DX < 0
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (-0.5 - EN-VX(L-ROW)) * 0.1
         WHEN OTHER
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (0 - EN-VX(L-ROW)) * 0.1
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-DY > 0
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (0.7 - EN-VY(L-ROW)) * 0.1
         WHEN WS-DY < 0
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (-0.7 - EN-VY(L-ROW)) * 0.1
         WHEN OTHER
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (0 - EN-VY(L-ROW)) * 0.1
     END-EVALUATE
     EVALUATE TRUE
         WHEN WS-DZ > 0
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (0.5 - EN-VZ(L-ROW)) * 0.1
         WHEN WS-DZ < 0
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (-0.5 - EN-VZ(L-ROW)) * 0.1
         WHEN OTHER
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (0 - EN-VZ(L-ROW)) * 0.1
     END-EVALUATE
     MOVE 0 TO WS-HEADING
     IF EN-VX(L-ROW) = 0
         IF EN-VZ(L-ROW) > 0
             MOVE 90 TO WS-HEADING
         END-IF
         IF EN-VZ(L-ROW) < 0
             MOVE -90 TO WS-HEADING
         END-IF
     ELSE
         COMPUTE WS-HEADING = FUNCTION ATAN(EN-VZ(L-ROW) / EN-VX(L-ROW)) * 180 / FUNCTION PI
         IF EN-VX(L-ROW) < 0
             COMPUTE WS-HEADING = WS-HEADING + 180
         END-IF
     END-IF
     COMPUTE WS-HEADING = WS-HEADING - 90
     COMPUTE WS-WRAP = WS-HEADING - EN-YAW(L-ROW)
     PERFORM UNTIL WS-WRAP < 180
         COMPUTE WS-WRAP = WS-WRAP - 360
     END-PERFORM
     PERFORM UNTIL WS-WRAP >= -180
         COMPUTE WS-WRAP = WS-WRAP + 360
     END-PERFORM
     COMPUTE EN-YAW(L-ROW) = EN-YAW(L-ROW) + WS-WRAP
     CALL "BAT-MOVE" USING L-ROW
     CALL "XP-RANDOM" USING WS-SALT WS-B100 WS-R
     IF WS-R = 0
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         COMPUTE WS-ABOVE = WS-BY + 1
         CALL "BAT-CONDUCTOR" USING EN-DIM(L-ROW) WS-BX WS-ABOVE WS-BZ WS-CONDUCTOR
         IF WS-CONDUCTOR = 1
             MOVE 1 TO EN-PH-PHASE(L-ROW)
             CALL "BAT-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BAT-TICK.
