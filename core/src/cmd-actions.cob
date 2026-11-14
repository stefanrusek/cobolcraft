*> Actions the commands share (docs/protocol/16-commands-catalog.md; the CX- programs of core/src/cmds-*.cob call them): moving a
*> player, sending the inventory, listing the players.
*>
*> Entry points:
*>   CMD-MOVE-PLAYER USING player row, dimension row (BINARY-LONG), feet x, y, z (FLOAT-LONG): the player's feet go to that
*>     position. In another dimension it is the travel switch without a goto_pad (DIM-SWITCH: Respawn and the join sequence there,
*>     standin §15.5); in the same dimension the player is sent Player Position (a new teleport id to accept), the chunks follow and
*>     the others see the entity move. Facing is kept.
*>   CMD-SEND-INVENTORY USING player row: the player's inventory (Container Set Content of container 0, the state id raised by one)
*>   CMD-ONLINE USING count out (BINARY-LONG), table of 64 player rows out (BINARY-LONG): the players in play in the order they
*>     entered the world (PL-ENTERED)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-MOVE-PLAYER.
*> USING player row, dimension row (BINARY-LONG), feet x, y, z (FLOAT-LONG): the player's feet go to
*> that position (§16.2 rows 16 and 17). In another dimension it is the travel switch without a
*> goto_pad (DIM-SWITCH: Respawn and the join sequence there, §15.5); in the same dimension the
*> player is sent Player Position (a new teleport id to accept), the chunks follow and the others
*> see the entity move. Facing is kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ON-GROUND           BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIM L-X L-Y L-Z.
     MOVE L-ROW TO WS-ROW
     IF L-DIM NOT = PL-DIM(WS-ROW)
         CALL "DIM-SWITCH" USING WS-ROW L-DIM L-X L-Y L-Z
         GOBACK
     END-IF
     MOVE PL-CONN(WS-ROW) TO WS-CONN
     MOVE L-X TO PL-X(WS-ROW)
     MOVE L-Y TO PL-Y(WS-ROW) PL-FALL-START(WS-ROW)
     MOVE L-Z TO PL-Z(WS-ROW)
     ADD 1 TO CN-TELEPORT-ID(WS-CONN)
     MOVE 0 TO CN-TELEPORT-ACKED(WS-CONN)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-POSITION-BUILD" USING CN-TELEPORT-ID(WS-CONN) PL-X(WS-ROW) PL-Y(WS-ROW)
         PL-Z(WS-ROW) PL-YAW(WS-ROW) PL-PITCH(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     MOVE PL-ON-GROUND(WS-ROW) TO WS-ON-GROUND
     CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
         PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ON-GROUND
     GOBACK.
 END PROGRAM CMD-MOVE-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-SEND-INVENTORY.
*> USING player row: the player's inventory (Container Set Content of container 0, the state id
*> raised by one first).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE PL-STATE-ID(L-ROW) = FUNCTION MOD(PL-STATE-ID(L-ROW) + 1, 32768)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-CONTENT-BUILD" USING L-ROW PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM CMD-SEND-INVENTORY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CMD-ONLINE.
*> USING count out (BINARY-LONG), table of 64 player rows out (BINARY-LONG): the players online in
*> this world (in play), in the order they entered it (PL-ENTERED; standin §16.2 roster).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-ROWS.
    05 L-ROW               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-ROWS.
     MOVE 0 TO L-COUNT WS-LAST
     MOVE 1 TO WS-NEXT
     PERFORM UNTIL WS-NEXT = 0
         MOVE 0 TO WS-NEXT
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
             IF PL-USED(WS-ROW) = 1 AND PL-ENTERED(WS-ROW) > WS-LAST
                 IF CN-PHASE(PL-CONN(WS-ROW)) = PH-PLAY
                     IF WS-NEXT = 0 OR PL-ENTERED(WS-ROW) < WS-BEST
                         MOVE WS-ROW TO WS-NEXT
                         MOVE PL-ENTERED(WS-ROW) TO WS-BEST
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-NEXT > 0
             ADD 1 TO L-COUNT
             MOVE WS-NEXT TO L-ROW(L-COUNT)
             MOVE WS-BEST TO WS-LAST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CMD-ONLINE.

