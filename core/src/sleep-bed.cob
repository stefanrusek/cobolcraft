*> What a player in a bed looks like to the clients, and how the bed is left (lane bugbed, operator report of try16 "I can't sleep in beds"; docs/protocol/33 sections 5.1 to 5.3,
*> 53 pose SLEEPING (2), 18 section 1.4 entry 14 (the sleeping position, OPTIONAL_BLOCK_POS = serializer 11), 05a Animate (action 0 = wake up), 05c Player Command 0 STOP_SLEEPING).
*> The sleeping state itself (W2-SLEEPING, W2-SLEEP-COUNTER, the bed position W2-SLEEP-BX..BZ) is kept in WSIM2.cpy; the use of the bed is WORLDSIM-SLEEP-USE (worldsim-33b.cob).
*> Entry points:
*>   SLEEP-MESSAGE USING connection id, translation key (PIC X(40)): an overlay System Chat line (the action bar) with the translate component of the key
*>   SLEEP-ENTITY-DATA USING player row, present (BINARY-LONG), x, y, z (the head half's cell): Set Entity Data of the player's entity with entry 14 (the sleeping position or none)
*>     to everybody who sees the entity and to the player
*>   SLEEP-OCCUPIED USING dimension row, head x, y, z, occupied (0 or 1): the occupied property of both halves of the bed whose head half is there
*>   SLEEP-BEGIN USING player row, head x, y, z: the player is asleep: the bed position is kept, both halves are occupied, the pose and the sleeping position are sent
*>   SLEEP-WAKE USING player row: stopSleepInBed (5.3): when asleep, the player is awake (counter 0), the bed is free, Animate wake up is sent to everybody who sees the entity
*>     and to the player, the standing pose and no sleeping position follow
*>   SLEEP-FORGET USING player row: the player left the world asleep: the bed is free and the row is not asleep (nothing is sent)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-SEND.
*> USING player row, PB-BUFFER: the packet to every player who sees the entity of that player row and to the player itself.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VIEWER              BINARY-LONG.
 01 WS-TRACKER             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     MOVE PL-ENTITY-ROW(L-ROW) TO WS-TRACKER
     PERFORM VARYING WS-VIEWER FROM 1 BY 1 UNTIL WS-VIEWER > CORE-MAX-PLAYERS
         IF WS-VIEWER = L-ROW OR (PL-USED(WS-VIEWER) = 1 AND VW-SEEN(WS-VIEWER)(WS-TRACKER:1) = "1")
             CALL "CORE-SEND" USING PL-CONN(WS-VIEWER) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SLEEP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-MESSAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 124.
 01 WS-OVERLAY             BINARY-LONG VALUE 1.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(40).
 PROCEDURE DIVISION USING L-ID L-KEY.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE L-KEY TO PB-TX-VALUE
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY))
     MOVE WS-LENGTH TO PB-TX-LENGTH
     MOVE 0 TO PB-TX-ARG-COUNT
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-OVERLAY
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SLEEP-MESSAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-ENTITY-DATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-INDEX               BINARY-LONG VALUE 14.
 01 WS-SERIALIZER          BINARY-LONG VALUE 11.
 01 WS-END                 BINARY-LONG VALUE 255.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PRESENT L-X L-Y L-Z.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(PL-ENTITY-ROW(L-ROW))
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-INDEX
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SERIALIZER
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-PRESENT
     IF L-PRESENT = 1
         CALL "PB-PUT-POSITION" USING PB-BUFFER L-X L-Y L-Z
     END-IF
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-END
     CALL "SLEEP-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SLEEP-ENTITY-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-OCCUPIED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PART                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(24) VALUE "occupied".
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OCCUPIED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OCCUPIED.
     MOVE "false" TO WS-TEXT
     IF L-OCCUPIED = 1
         MOVE "true" TO WS-TEXT
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "BED-PART" USING WS-STATE WS-PART WS-DX WS-DZ
     IF WS-PART = 2
         CALL "PS-PUT" USING WS-STATE WS-NAME WS-TEXT
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-STATE
*>       The other half (the foot, one step against the head's facing).
         COMPUTE WS-X = L-X + WS-DX
         COMPUTE WS-Z = L-Z + WS-DZ
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X L-Y WS-Z WS-STATE
         CALL "BED-PART" USING WS-STATE WS-PART WS-DX WS-DZ
         IF WS-PART = 1
             CALL "PS-PUT" USING WS-STATE WS-NAME WS-TEXT
             CALL "BLOCK-CHANGE" USING L-DIM WS-X L-Y WS-Z WS-STATE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SLEEP-OCCUPIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-BEGIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-BED-X               FLOAT-LONG.
 01 WS-BED-Y               FLOAT-LONG.
 01 WS-BED-Z               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     MOVE 1 TO W2-SLEEPING(L-ROW)
     MOVE 0 TO W2-SLEEP-COUNTER(L-ROW)
     MOVE L-X TO W2-SLEEP-BX(L-ROW)
     MOVE L-Y TO W2-SLEEP-BY(L-ROW)
     MOVE L-Z TO W2-SLEEP-BZ(L-ROW)
     CALL "SLEEP-OCCUPIED" USING PL-DIM(L-ROW) L-X L-Y L-Z WS-YES
     CALL "POSE-UPDATE" USING L-ROW
     CALL "SLEEP-ENTITY-DATA" USING L-ROW WS-YES L-X L-Y L-Z
*>   startSleeping moves the player onto the bed: the middle of the head half at the mattress height (51 R-E3: 9 sixteenths), Player Position to the client, the others see it move.
     COMPUTE WS-BED-X = L-X + 0.5
     COMPUTE WS-BED-Y = L-Y + 0.5625
     COMPUTE WS-BED-Z = L-Z + 0.5
     CALL "CMD-MOVE-PLAYER" USING L-ROW PL-DIM(L-ROW) WS-BED-X WS-BED-Y WS-BED-Z
     GOBACK.
 END PROGRAM SLEEP-BEGIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-WAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 2.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-WAKE-UP             BINARY-LONG VALUE 0.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ZERO-X              BINARY-LONG VALUE 0.
 01 WS-ZERO-Y              BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STAND-X             FLOAT-LONG.
 01 WS-STAND-Y             FLOAT-LONG.
 01 WS-STAND-Z             FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF W2-SLEEPING(L-ROW) = 0
         GOBACK
     END-IF
     MOVE W2-SLEEP-BX(L-ROW) TO WS-X
     MOVE W2-SLEEP-BY(L-ROW) TO WS-Y
     MOVE W2-SLEEP-BZ(L-ROW) TO WS-Z
     MOVE 0 TO W2-SLEEPING(L-ROW) W2-SLEEP-COUNTER(L-ROW)
     CALL "SLEEP-OCCUPIED" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-NO
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(PL-ENTITY-ROW(L-ROW))
     CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-WAKE-UP
     CALL "SLEEP-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
*>   The player stands up beside the bed (Player Position to the client) before the pose is chosen: on the mattress the standing box would not fit.
     CALL "SLEEP-STAND-UP" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-STAND-X WS-STAND-Y WS-STAND-Z
     CALL "CMD-MOVE-PLAYER" USING L-ROW PL-DIM(L-ROW) WS-STAND-X WS-STAND-Y WS-STAND-Z
     CALL "POSE-UPDATE" USING L-ROW
     CALL "SLEEP-ENTITY-DATA" USING L-ROW WS-NO WS-ZERO-X WS-ZERO-Y WS-ZERO-Z
     GOBACK.
 END PROGRAM SLEEP-WAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SLEEP-FORGET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF W2-SLEEPING(L-ROW) = 1
         MOVE W2-SLEEP-BX(L-ROW) TO WS-X
         MOVE W2-SLEEP-BY(L-ROW) TO WS-Y
         MOVE W2-SLEEP-BZ(L-ROW) TO WS-Z
         CALL "SLEEP-OCCUPIED" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-NO
     END-IF
     MOVE 0 TO W2-SLEEPING(L-ROW) W2-SLEEP-COUNTER(L-ROW)
     GOBACK.
 END PROGRAM SLEEP-FORGET.
