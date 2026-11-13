*> The client's wait for the level after Login or Respawn (docs/protocol/50 section 7): Game Event 13 starts it (PL-WAIT 1, protocol-client.cob), LOAD-WAIT-TICK ends
*> it, and Player Loaded (05c 0x2C) goes out once the close delay has passed. The camera section is "ready" here when the replica holds its chunk and the section
*> has been meshed (not dirty): this client's own equivalent of the vanilla test of a compiled, visible render section (50 section 7.2); there is no fade-in.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOAD-WAIT-TICK.
*> USING CLIENT-STATE: one client tick of the wait. PL-WAIT 1 ends (becomes 2, PL-READY-AT the clock) when more than 30 000 ms have passed since PL-WAIT-START, or, once the
*> player is positioned, when the camera (the eye, 1.62 above the position) is outside the build height, the player is a spectator (game mode 3) or is dead
*> (health 0 or less), or the section of the camera is meshed. PL-WAIT 2 ends once PL-CLOSE-DELAY ms have passed since PL-READY-AT: Player Loaded is sent, PL-LOADED is 1,
*> the delay is 0 for the next wait and the world screen shows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 44.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF PL-WAIT = 1
         MOVE 0 TO WS-READY
         IF CL-NOW-MS - PL-WAIT-START > 30000
             MOVE 1 TO WS-READY
         END-IF
         IF WS-READY = 0 AND PL-POSITIONED = 1
             COMPUTE WS-EYE = FUNCTION INTEGER(PL-Y + 1.62)
             EVALUATE TRUE
                 WHEN WS-EYE < PL-MIN-Y OR WS-EYE >= PL-MIN-Y + PL-HEIGHT
                     MOVE 1 TO WS-READY
                 WHEN PL-MODE = 3 OR PL-HEALTH <= 0
                     MOVE 1 TO WS-READY
                 WHEN OTHER
                     COMPUTE WS-CX = FUNCTION INTEGER(PL-X / 16)
                     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z / 16)
                     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
                     COMPUTE WS-SECTION = FUNCTION INTEGER((WS-EYE - PL-MIN-Y) / 16) + 1
                     IF WS-ROW > 0
                         IF WR-DIRTY(WS-ROW, WS-SECTION) = 0
                             MOVE 1 TO WS-READY
                         END-IF
                     END-IF
             END-EVALUATE
         END-IF
         IF WS-READY = 1
             MOVE 2 TO PL-WAIT
             MOVE CL-NOW-MS TO PL-READY-AT
         END-IF
     END-IF
     IF PL-WAIT = 2 AND CL-NOW-MS - PL-READY-AT >= PL-CLOSE-DELAY
         CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE WS-CONN WS-ID
         MOVE 1 TO PL-LOADED
         MOVE 0 TO PL-WAIT PL-CLOSE-DELAY
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM LOAD-WAIT-TICK.
