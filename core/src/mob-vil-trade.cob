*> A villager with a trading player stands still and looks at the player (lane 002-lane-bugtradestop, T58300; docs/protocol/44 part 3 section 3.4 LookAndFollowTradingPlayerSink,
*> 44 x2 section 10.3 TradeWithPlayerGoal (flags jump and move; start stops the navigation) and LookAtTradingPlayerGoal, 40 section 2.9). The trading player of a villager is the player
*> whose merchant window (MN-CFAMILY 29, MN-BENCH-X the entity id of the merchant) is open on it: nothing is stored, closing the window, walking away (MERCHANT-VALID) or leaving ends it.
*> While there is one, STDMOB-STEP gives the villager no walk (its walk target and its walk time stay as they are, so it walks on when the window is closed), no stroll and no push,
*> and turns it to the player (yaw, which the viewers get as the head yaw as well) with the pitch to the player's eyes.
*>   VL-TRADER USING entity row, player row out                  the player row whose merchant window is open on this entity (0 none)
*>   VL-TRADE-FACE USING entity row, player row, yaw (in/out)    the yaw facing the player (the horizontal direction from the villager to the player)
*>   VL-TRADE-PITCH USING entity row, player row                 the pitch to the player's eyes (0 for no player); sent when it differs from the one the viewers have

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRADER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-P                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PLAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     MOVE 0 TO L-PLAYER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-PLAYER > 0
         IF PL-USED(WS-P) = 1 AND MN-WINDOW(WS-P) > 0 AND MN-CFAMILY(WS-P) = 29
                 AND MN-BENCH-X(WS-P) = EN-ID(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             MOVE WS-P TO L-PLAYER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-TRADER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRADE-FACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PLAYER                BINARY-LONG.
 01 L-YAW                   FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-YAW.
     COMPUTE WS-DX = PL-X(L-PLAYER) - EN-X(L-ROW)
     COMPUTE WS-DZ = PL-Z(L-PLAYER) - EN-Z(L-ROW)
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ L-YAW
     GOBACK.
 END PROGRAM VL-TRADE-FACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-TRADE-PITCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-H                    FLOAT-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT.
 01 WS-PITCH                FLOAT-SHORT.
 01 WS-GROUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PLAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     MOVE 0 TO WS-PITCH
     IF L-PLAYER > 0
*>       The eyes are 1.62 above the feet of a player and of the adult villager or wandering trader (a baby villager is refused a window, it never trades). The pitch is
*>       -atan(dy / horizontal distance), negative looking up.
         COMPUTE WS-DX = PL-X(L-PLAYER) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(L-PLAYER) - EN-Z(L-ROW)
         COMPUTE WS-DY = PL-Y(L-PLAYER) - EN-Y(L-ROW)
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) + 0.000000001
         COMPUTE WS-PITCH = - FUNCTION ATAN(WS-DY / WS-H) * 180 / FUNCTION PI
     END-IF
     IF WS-PITCH NOT = EN-SENT-PITCH(L-ROW)
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE EN-YAW(L-ROW) TO WS-YAW
         MOVE EN-ON-GROUND(L-ROW) TO WS-GROUND
         CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     END-IF
     GOBACK.
 END PROGRAM VL-TRADE-PITCH.
